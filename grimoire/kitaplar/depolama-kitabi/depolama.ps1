# ============================================
# DEPOLAMA KİTABI - Ana Büyü Scripti
# ============================================
# Disk doluluğu sorunlarını çözer
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

# ============================================
# HAZIRLIK
# ============================================

$Script:KitapAdi = "Depolama Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ortak fonksiyonları yükle
. (Join-Path $ScriptKlasor "..\utils.ps1")

# Çöp Kutusu için VisualBasic assembly
Add-Type -AssemblyName Microsoft.VisualBasic

# ============================================
# YARDIMCI FONKSİYON: Dosyayı Çöp Kutusuna Gönder
# ============================================

function CopKutusune-Gonder {
    param([string]$DosyaYolu)
    
    try {
        if (Test-Path $DosyaYolu) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($DosyaYolu, 'OnlyRecycleBin', 'SendToRecycleBin')
            return $true
        }
    } catch {
        Write-Durum "  Dosya çöp kutusuna gönderilemedi: $DosyaYolu" "Yellow"
    }
    return $false
}

# ============================================
# GERİ ALMA - Sadece bu kitaba özel mantık
# ============================================

function Depolama-GeriAl {
    param($Yedek)
    
    # Çöp kutusunu aç
    try {
        Invoke-Item "shell:recycleBinFolder"
        Write-Basari "Çöp kutusu açıldı"
    } catch {
        explorer.exe shell:recycleBinFolder
    }
    
    # Windows Update servisini başlat
    try {
        $wu = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
        if ($wu -and $wu.Status -eq "Stopped") {
            Start-Service -Name wuauserv -ErrorAction Stop
            Write-Basari "Windows Update yeniden başlatıldı"
        }
    } catch {
        Write-Durum "Windows Update başlatılamadı" "Yellow"
    }
}

# ============================================
# DİSK KULLANIM TARAMASI
# ============================================

function Disk-Tarama {
    Write-Baslik "💾 DİSK KULLANIM TARAMASI"
    
    $diskler = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
    
    foreach ($disk in $diskler) {
        $toplamGB = [math]::Round($disk.Size / 1GB, 1)
        $bosGB = [math]::Round($disk.FreeSpace / 1GB, 1)
        $kullanimOrani = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 1)
        
        Write-Host "`n  📁 Disk $($disk.DeviceID)" -ForegroundColor Cyan
        Write-Durum "Toplam: $toplamGB GB"
        Write-Durum "Boş: $bosGB GB"
        Write-Durum "Kullanım: %$kullanimOrani" -ForegroundColor $(if($kullanimOrani -gt 90){"Red"}elseif($kullanimOrani -gt 70){"Yellow"}else{"Green"})
        
        # Bar gösterimi
        $barUzunluk = 30
        $doluBar = [math]::Round($kullanimOrani / 100 * $barUzunluk)
        $bosBar = $barUzunluk - $doluBar
        $bar = "█" * $doluBar + "░" * $bosBar
        Write-Host "  [$bar] %$kullanimOrani" -ForegroundColor $(if($kullanimOrani -gt 90){"Red"}elseif($kullanimOrani -gt 70){"Yellow"}else{"Green"})
    }
    
    return $diskler
}

# ============================================
# BÜYÜK DOSYA TARAMASI
# ============================================

function Buyuk-Dosyalar {
    param([string]$DiskHarfi = "C:", [bool]$TestModu)
    
    Write-Baslik "🔍 BÜYÜK DOSYA TARAMASI"
    
    if ($TestModu) {
        Write-Durum "Test modunda tarama yapılır ama dosyalar gösterilmez" "Magenta"
        return @()
    }
    
    # Tarama seçeneği sun
    Write-Durum "Tarama türü seçin:" "Cyan"
    Write-Host "  [1] Hızlı - Sadece masaüstü, indirmeler, belgeler" -ForegroundColor White
    Write-Host "  [2] Orta - Sadece kullanıcı klasörü" -ForegroundColor White
    Write-Host "  [3] Tam - Tüm disk (yavaş olabilir)" -ForegroundColor White
    Write-Host ""
    
    $taramaSecimi = Read-Host "Seçiminiz (1/2/3)"
    
    switch ($taramaSecimi) {
        "1" {
            $taramaYollari = @(
                "$env:USERPROFILE\Desktop",
                "$env:USERPROFILE\Downloads",
                "$env:USERPROFILE\Documents"
            )
            $taramaAdi = "Hızlı (Masaüstü, İndirmeler, Belgeler)"
        }
        "3" {
            $taramaYollari = @("${DiskHarfi}\")
            $taramaAdi = "Tam Disk"
        }
        default {
            $taramaYollari = @("$env:USERPROFILE")
            $taramaAdi = "Kullanıcı Klasörü"
        }
    }
    
    Write-Durum "Tarama: $taramaAdi" "Yellow"
    Write-Uyari "100MB'den büyük dosyalar aranıyor..."
    Write-Host ""
    
    $buyukDosyalar = @()
    $toplamSure = 0
    
    foreach ($yol in $taramaYollari) {
        if (-not (Test-Path $yol)) { continue }
        
        Write-Durum "Taranıyor: $yol" "Gray"
        
        $sure = Measure-Command {
            $dosyalar = Get-ChildItem -Path $yol -Recurse -File -ErrorAction SilentlyContinue | 
                Where-Object { $_.Length -gt 100MB } |
                Sort-Object Length -Descending |
                Select-Object -First 20 |
                ForEach-Object {
                    [PSCustomObject]@{
                        Dosya = $_.FullName
                        Boyut = "$([math]::Round($_.Length / 1MB, 0)) MB"
                        BoyutByte = $_.Length
                        Tarih = $_.LastWriteTime
                    }
                }
            $buyukDosyalar += $dosyalar
        }
        $toplamSure += $sure.TotalSeconds
    }
    
    Write-Durum "Tarama süresi: $([math]::Round($toplamSure, 1)) saniye" "Gray"
    
    if ($buyukDosyalar.Count -gt 0) {
        $buyukDosyalar = $buyukDosyalar | Sort-Object BoyutByte -Descending | Select-Object -First 20
        Write-Basari "Bulunan büyük dosyalar ($($buyukDosyalar.Count) adet):"
        $buyukDosyalar | ForEach-Object {
            Write-Host "    $($_.Dosya)" -ForegroundColor Gray
            Write-Host "      Boyut: $($_.Boyut) | Son Erişim: $($_.Tarih)" -ForegroundColor DarkGray
        }
    } else {
        Write-Basari "100MB'den büyük dosya bulunamadı"
    }
    
    return $buyukDosyalar
}

# ============================================
# GEREKSİZ DOSYA TARAMASI
# ============================================

function Gereksiz-Dosyalar {
    param([bool]$TestModu)
    
    Write-Baslik "🗑️  GEREKSİZ DOSYA TARAMASI"
    
    $gereksizler = @()
    
    # 1. Geçici dosyalar
    Write-Durum "Geçici dosyalar taranıyor..." "Yellow"
    $tempKlasor = $env:TEMP
    try {
        $tempDosyalar = Get-ChildItem -Path $tempKlasor -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }  # Sadece 7 günden eski dosyalar
        $tempBoyut = ($tempDosyalar | Measure-Object -Property Length -Sum).Sum / 1MB
        
        $gereksizler += [PSCustomObject]@{
            Tur = "Geçici Dosyalar"
            Konum = $tempKlasor
            Dosyalar = @($tempDosyalar | ForEach-Object { $_.FullName })
            DosyaSayisi = @($tempDosyalar).Count
            BoyutMB = [math]::Round($tempBoyut, 0)
            Guvenli = $true
            Silinebilir = $true
        }
        
        Write-Durum "  Geçici dosyalar: $([math]::Round($tempBoyut, 0)) MB ($(@($tempDosyalar).Count) dosya)" "White"
    } catch {
        Write-Durum "  Geçici dosya taraması başarısız" "Yellow"
    }
    
    # 2. Windows Update önbelleği (GÜVENLİK KONTROLÜ İLE)
    Write-Durum "Windows Update önbelleği taranıyor..." "Yellow"
    $wuKlasor = "C:\Windows\SoftwareDistribution\Download"
    
    # Windows Update'in çalışıp çalışmadığını kontrol et
    $wuServis = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    $wuCalisiyor = $wuServis -and $wuServis.Status -eq "Running"
    
    if ($wuCalisiyor) {
        Write-Durum "  ⚠️  Windows Update çalışıyor - temizlik yapılmayacak" "Yellow"
    } else {
        try {
            $wuDosyalar = Get-ChildItem -Path $wuKlasor -Recurse -File -ErrorAction SilentlyContinue
            $wuBoyut = ($wuDosyalar | Measure-Object -Property Length -Sum).Sum / 1MB
            
            $gereksizler += [PSCustomObject]@{
                Tur = "Windows Update Önbelleği"
                Konum = $wuKlasor
                Dosyalar = @($wuDosyalar | ForEach-Object { $_.FullName })
                DosyaSayisi = @($wuDosyalar).Count
                BoyutMB = [math]::Round($wuBoyut, 0)
                Guvenli = $true
                Silinebilir = $true
                ServisGerektir = "wuauserv"
            }
            
            Write-Durum "  Windows Update: $([math]::Round($wuBoyut, 0)) MB ($(@($wuDosyalar).Count) dosya)" "White"
        } catch {
            Write-Durum "  Windows Update taraması başarısız" "Yellow"
        }
    }
    
    # 3. Thumbnails
    Write-Durum "Küçük resim önbelleği taranıyor..." "Yellow"
    $thumbKlasor = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
    try {
        $thumbDosyalar = Get-ChildItem -Path $thumbKlasor -Filter "thumbcache_*" -File -ErrorAction SilentlyContinue
        $thumbBoyut = ($thumbDosyalar | Measure-Object -Property Length -Sum).Sum / 1MB
        
        $gereksizler += [PSCustomObject]@{
            Tur = "Küçük Resim Önbelleği"
            Konum = $thumbKlasor
            Dosyalar = @($thumbDosyalar | ForEach-Object { $_.FullName })
            DosyaSayisi = @($thumbDosyalar).Count
            BoyutMB = [math]::Round($thumbBoyut, 0)
            Guvenli = $true
            Silinebilir = $true
        }
        
        Write-Durum "  Küçük resimler: $([math]::Round($thumbBoyut, 0)) MB ($(@($thumbDosyalar).Count) dosya)" "White"
    } catch {
        Write-Durum "  Küçük resim taraması başarısız" "Yellow"
    }
    
    # Toplam
    $toplamBoyut = ($gereksizler | Measure-Object -Property BoyutMB -Sum).Sum
    Write-Host ""
    Write-Basari "Toplam temizlenebilir alan: $([math]::Round($toplamBoyut, 0)) MB"
    
    return $gereksizler
}

# ============================================
# TEMİZLİK ONAY
# ============================================

function Temizlik-Onayla {
    param($Gereksizler)
    
    Write-Baslik "🧹 TEMİZLİK PLANI"
    
    Write-Durum "Temizlenebilecek dosyalar:" "Cyan"
    Write-Host ""
    
    foreach ($gereksiz in $Gereksizler) {
        if ($gereksiz.Silinebilir) {
            Write-Durum "  ✅ $($gereksiz.Tur): $($_.BoyutMB) MB ($($_.DosyaSayisi) dosya)" "Green"
        }
    }
    
    Write-Host ""
    Write-Uyari "Dosyalar Çöp Kutusu'na gönderilecek (kalıcı silme yok)"
    Write-Uyari "Çöp Kutusu'ndan geri yükleyebilirsiniz"
    Write-Uyari "Kişisel dosyalarınız ETKİLENMEYECEK"
    
    return (Onay-Al -Baslik "Temizlik Onayı" -Islemler @(
        "Geçici dosyalar Çöp Kutusu'na gönderilecek",
        "Windows Update önbelleği Çöp Kutusu'na gönderilecek",
        "Küçük resim önbelleği Çöp Kutusu'na gönderilecek"
    ))
}

# ============================================
# TEMİZLİK UYGULAMA (Madde 1 & 5 UYUMLU)
# ============================================

function Temizlik-Uygula {
    param($Gereksizler, [bool]$TestModu)
    
    if ($TestModu) {
        Test-Baslat -KitapAdi $KitapAdi
        Write-Durum "Test modunda temizlik yapılmaz" "Magenta"
        Write-Durum "Temizlenecek dosyalar:" "Gray"
        foreach ($gereksiz in $Gereksizler) {
            if ($gereksiz.Silinebilir) {
                Write-Durum "  - $($gereksiz.Tur): $($gereksiz.BoyutMB) MB ($($gereksiz.DosyaSayisi) dosya)" "Gray"
            }
        }
        Test-Bitir -KitapAdi $KitapAdi
        return
    }
    
    Write-Baslik "🧹 TEMİZLİK UYGULANIYOR"
    
    # Yedekleme: Temizlenecek dosyaların listesini kaydet (Madde 5)
    $tumDosyalar = @()
    foreach ($gereksiz in $Gereksizler) {
        if ($gereksiz.Silinebilir -and $gereksiz.Dosyalar) {
            $tumDosyalar += $gereksiz.Dosyalar
        }
    }
    
    if ($tumDosyalar.Count -gt 0) {
        $yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Temizlik öncesi dosya listesi" -Dosyalar @()
        
        # Dosya listesini ayrıca kaydet (geri dönüş için)
        if ($yedekYolu) {
            $tumDosyalar | ConvertTo-Json | Set-Content -Path (Join-Path $yedekYolu "temizlenen-dosyalar.json") -Encoding UTF8
            
            # Yedek bilgisine ekle
            $bilgiDosyasi = Join-Path $yedekYolu "yedek-bilgi.json"
            $bilgi = Get-Content -Path $bilgiDosyasi -Raw | ConvertFrom-Json
            $bilgi | Add-Member -NotePropertyName "TemizlenenDosyaSayisi" -NotePropertyValue $tumDosyalar.Count -Force
            $bilgi | ConvertTo-Json | Set-Content -Path $bilgiDosyasi -Encoding UTF8
        }
        
        Write-Durum "Yedekleme tamamlandı: $($tumDosyalar.Count) dosya listelendi" "Green"
    }
    
    $temizlenenToplam = 0
    $temizlenenDosyaSayisi = 0
    
    foreach ($gereksiz in $Gereksizler) {
        if (-not $gereksiz.Silinebilir -or $gereksiz.BoyutMB -eq 0) {
            continue
        }
        
        Write-Durum "$($gereksiz.Tur) temizleniyor..." "Yellow"
        
        try {
            switch ($gereksiz.Tur) {
                "Geçici Dosyalar" {
                    # Geçici dosyaları Çöp Kutusu'na gönder
                    foreach ($dosyaYolu in $gereksiz.Dosyalar) {
                        if (CopKutusune-Gonder -DosyaYolu $dosyaYolu) {
                            $temizlenenDosyaSayisi++
                        }
                    }
                }
                "Çöp Kutusu" {
                    # Çöp kutusu boşaltılmaz (Madde 1: Geri dönüş hakkı)
                    # Sadece kullanıcıya bilgi ver
                    Write-Durum "  ℹ️  Çöp kutusu boşaltılmadı (geri dönüş hakkı)" "Gray"
                }
                "Windows Update Önbelleği" {
                    # GÜVENLİK KONTROLÜ: Servisi durdurmadan önce kontrol et
                    $wuServis = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
                    if ($wuServis -and $wuServis.Status -eq "Running") {
                        # Bekleyen işlem var mı kontrol et
                        $wuIslemler = Get-Process -Name "wuauclt","WaMediaManager","TiWorker" -ErrorAction SilentlyContinue
                        if ($wuIslemler) {
                            Write-Durum "  ⚠️  Windows Update işlemi çalışıyor, atlanıyor" "Yellow"
                            continue
                        }
                        Write-Durum "  ⚠️  Windows Update servisi çalışıyor, atlanıyor" "Yellow"
                        continue
                    }
                    
                    # Servisi durdur
                    try {
                        Stop-Service -Name wuauserv -Force -ErrorAction Stop
                        Start-Sleep -Seconds 3  # Servisin tamamen durmasını bekle
                        
                        # Kontrol et
                        $wuServis = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
                        if ($wuServis.Status -ne "Stopped") {
                            Write-Durum "  Windows Update servisi durmadı, atlanıyor" "Yellow"
                            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
                            continue
                        }
                    } catch {
                        Write-Durum "  Windows Update durdurulamadı: $_" "Yellow"
                        continue
                    }
                    
                    # Dosyaları Çöp Kutusu'na gönder
                    foreach ($dosyaYolu in $gereksiz.Dosyalar) {
                        if (CopKutusune-Gonder -DosyaYolu $dosyaYolu) {
                            $temizlenenDosyaSayisi++
                        }
                    }
                    
                    # Servisi yeniden başlat
                    try {
                        Start-Service -Name wuauserv -ErrorAction Stop
                        Write-Basari "Windows Update servisi yeniden başlatıldı"
                    } catch {
                        Write-Durum "  Windows Update başlatılamadı: $_" "Yellow"
                    }
                }
                "Küçük Resim Önbelleği" {
                    # Küçük resimleri Çöp Kutusu'na gönder
                    foreach ($dosyaYolu in $gereksiz.Dosyalar) {
                        if (CopKutusune-Gonder -DosyaYolu $dosyaYolu) {
                            $temizlenenDosyaSayisi++
                        }
                    }
                }
            }
            
            $temizlenenToplam += $gereksiz.BoyutMB
            Write-Basari "$($gereksiz.Tur) temizlendi"
        } catch {
            Write-Durum "$($gereksiz.Tur) temizlenemedi: $_" "Red"
        }
    }
    
    Write-Host ""
    Write-Basari "Temizlik tamamlandı!"
    Write-Durum "Toplam temizlenen: $([math]::Round($temizlenenToplam, 0)) MB ($temizlenenDosyaSayisi dosya)" "Green"
    Write-Host ""
    Write-Durum "💡 Dosyalar Çöp Kutusu'nda. Geri yüklemek için:" "Cyan"
    Write-Durum "   .\depolama.ps1 -Undo" "White"
    
    # Log yaz
    Log-Yaz -KitapAdi $KitapAdi -Islem "Temizlik" -Detay "$([math]::Round($temizlenenToplam, 0)) MB temizlendi, $temizlenenDosyaSayisi dosya Çöp Kutusu'na gönderildi"
}

# ============================================
# ANA AKIŞ
# ============================================

Clear-Host
Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      💾 DEPOLAMA KİTABI 💾           ║" -ForegroundColor Cyan
Write-Host "║      Diskini Boşalt                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @(
        "Çöp kutusu açılacak",
        "Windows Update servisi yeniden başlatılacak"
    ) -GeriAlmaLogigi { param($Yedek) Depolama-GeriAl -Yedek $Yedek }
    Write-Host "`nBir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$testModu = $false
$diskler = Disk-Tarama
$buyukDosyalar = Buyuk-Dosyalar -DiskHarfi "C:" -TestModu $TestMode
$gereksizler = Gereksiz-Dosyalar -TestModu $TestMode

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  Ne yapmak istersin?" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [T] - Gereksiz dosyaları temizle" -ForegroundColor Green
Write-Host "  [B] - Büyük dosyaları göster" -ForegroundColor Cyan
Write-Host "  [M] - Test modu" -ForegroundColor Magenta
Write-Host "  [Ç] - Çıkış" -ForegroundColor Gray
Write-Host ""

$secim = Read-Host "Seçiminiz"

switch ($secim.ToUpper()) {
    "T" {
        $onay = Temizlik-Onayla -Gereksizler $gereksizler
        if ($onay -eq "Uygula") {
            Temizlik-Uygula -Gereksizler $gereksizler -TestModu $testModu
        } else {
            Write-Durum "Temizlik iptal edildi." "Gray"
            Log-Yaz -KitapAdi $KitapAdi -Islem "İptal" -Detay "Kullanıcı temizliği iptal etti"
        }
    }
    "B" {
        Write-Host ""
        Write-Durum "Büyük dosyalar listelendi." "Cyan"
    }
    "M" {
        $testModu = $true
        Write-Host "`n🧪 Test modu aktif" -ForegroundColor Magenta
    }
    default {
        Write-Host "`nÇıkış yapılıyor..." -ForegroundColor Gray
    }
}

Write-Host "`nBir tuşa basın..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
