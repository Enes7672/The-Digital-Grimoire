# ============================================
# NEFES KİTABI - Ana Büyü Scripti
# ============================================
# Bu büyü, bilgisayarın nefes almasını sağlar
# RAM temizler, arka plan işlemlerini askıya alır
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

# ============================================
# HAZIRLIK
# ============================================

$Script:KitapAdi = "Nefes Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ortak fonksiyonları yükle
. (Join-Path $ScriptKlasor "..\utils.ps1")

# Yönetici hakları kontrolü
if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

# ============================================
# GERİ ALMA - Sadece bu kitaba özel mantık
# ============================================

function Nefes-GeriAl {
    param($Yedek)
    
    # Askıya alınan servisleri başlat
    $servisler = @("SearchIndexer", "BITS", "wuauserv", "SysMain")
    foreach ($servis in $servisler) {
        try {
            $durum = Get-Service -Name $servis -ErrorAction SilentlyContinue
            if ($durum -and $durum.Status -eq "Stopped") {
                Start-Service -Name $servis -ErrorAction SilentlyContinue
                Write-Basari "Servis yeniden başlatıldı: $servis"
            }
        } catch {
            Write-Durum "Servis başlatılamadı: $servis" "Yellow"
        }
    }
}

# ============================================
# SİSTEM TARAMASI
# ============================================

function Sistem-Tarama {
    Write-Baslik "🔍 SİSTEM TARAMASI"
    
    # RAM Durumu (düzeltilmiş)
    $ram = Get-CimInstance -ClassName Win32_OperatingSystem
    $ramToplamGB = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)
    $ramBosGB = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)
    $ramKullanimOrani = [math]::Round(($ramToplamGB - $ramBosGB) / $ramToplamGB * 100, 1)
    
    # İşlemci Durumu (Get-Counter bazı sistemlerde sayaç hatası verebildiği için CIM tabanlı ölçüme geçildi)
    try {
        $cpuKullanim = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
    } catch {
        $cpuKullanim = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    }
    
    # İşlemler
    $islemSayisi = (Get-Process).Count
    $buyukIslemler = Get-Process | Where-Object {$_.WorkingSet64 -gt 50MB} | 
        Sort-Object WorkingSet64 -Descending | Select-Object -First 5
    
    # Cache boyutu
    $tempKlasor = $env:TEMP
    $cacheBoyutMB = 0
    try {
        $cacheBoyutMB = [math]::Round((Get-ChildItem -Path $tempKlasor -Recurse -ErrorAction SilentlyContinue | 
            Measure-Object -Property Length -Sum).Sum / 1MB, 0)
    } catch {
        # Hata olursa 0 kabul et
    }
    
    # Sonuçları göster
    Write-Durum "RAM Kullanımı: %$ramKullanimOrani ($ramBosGB GB boş / $ramToplamGB GB)" $(if($ramKullanimOrani -gt 80){"Red"}elseif($ramKullanimOrani -gt 60){"Yellow"}else{"Green"})
    Write-Durum "İşlemci Kullanımı: %$([math]::Round($cpuKullanim, 1))" $(if($cpuKullanim -gt 80){"Red"}elseif($cpuKullanim -gt 60){"Yellow"}else{"Green"})
    Write-Durum "Açık İşlem Sayısı: $islemSayisi" $(if($islemSayisi -gt 200){"Yellow"}else{"Green"})
    Write-Durum "Geçici Dosya Boyutu: $cacheBoyutMB MB" $(if($cacheBoyutMB -gt 1000){"Yellow"}else{"Green"})
    
    # Düzeltilmiş hashtable yapısı
    return @{
        RAMToplam = $ramToplamGB
        RAMBos = $ramBosGB
        RAMKullanim = $ramKullanimOrani
        CPUKullanim = $cpuKullanim
        IslemSayisi = $islemSayisi
        CacheBoyut = $cacheBoyutMB
        BuyukIslemler = $buyukIslemler
    }
}

# ============================================
# NEFES BUYUSU - PLAN GÖSTERME
# ============================================

function Nefes-PlanGoster {
    param($TaramaSonucu)
    
    Write-Baslik "💨 NEFES BUYUSU - PLAN"
    
    Write-Durum "Bu büyü şunları yapacak:" "Cyan"
    Write-Host ""
    
    $islemler = @()
    
    # 1. RAM Temizliği
    if ($TaramaSonucu.RAMKullanim -gt 60) {
        Write-Durum "✅ RAM Temizliği - Sistem önbelleği temizlenecek" "Green"
        $islemler += "RAM temizliği (sistem önbelleği)"
    } else {
        Write-Durum "⏭️  RAM Temizliği - Zaten yeterli boş alan var" "Gray"
    }
    
    # 2. Geçici Dosya Temizliği
    if ($TaramaSonucu.CacheBoyut -gt 500) {
        Write-Durum "✅ Geçici Dosya Temizliği - $($TaramaSonucu.CacheBoyut) MB temizlenecek" "Green"
        $islemler += "Geçici dosya temizliği ($($TaramaSonucu.CacheBoyut) MB)"
    } else {
        Write-Durum "⏭️  Geçici Dosya Temizliği - Çok az dosya var" "Gray"
    }
    
    # 3. İşlem Askıya Alma
    if ($TaramaSonucu.IslemSayisi -gt 150) {
        Write-Durum "✅ Ağır İşlemleri Askıya Alma - Seçili servisler durdurulacak" "Green"
        $islemler += "Ağır arka plan servislerini askıya alma"
    } else {
        Write-Durum "⏭️  İşlem Askıya Alma - İşlem sayısı normal" "Gray"
    }
    
    return $islemler
}

# ============================================
# NEFES BUYUSU - UYGULAMA
# ============================================

function Nefes-Uygula {
    param($TaramaSonucu, [bool]$TestModu)
    
    if ($TestModu) {
        Test-Baslat -KitapAdi $KitapAdi
        $islemler = Nefes-PlanGoster -TaramaSonucu $TaramaSonucu
        Test-Bitir -KitapAdi $KitapAdi
        return
    }
    
    Write-Baslik "💨 NEFES BUYUSU UYGULANIYOR"
    
    # Yedekleme (Madde 5) - Servis durumlarını kaydet
    $servisDurumlari = @()
    $servisler = @("SearchIndexer", "BITS", "wuauserv", "SysMain")
    foreach ($servis in $servisler) {
        $durum = Get-Service -Name $servis -ErrorAction SilentlyContinue
        if ($durum) {
            $servisDurumlari += [PSCustomObject]@{
                Adi = $servis
                oncekiDurum = $durum.Status
            }
        }
    }
    
    # Yedek oluştur
    $yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Nefes büyüası öncesi servis durumları" -Dosyalar @()
    
    # Yedek bilgisine servis durumlarını ekle
    if ($yedekYolu) {
        $servisDurumlari | ConvertTo-Json | Set-Content -Path (Join-Path $yedekYolu "servis-durumlari.json") -Encoding UTF8
    }
    
    # 1. RAM Temizliği (EmptyWorkingSet ile daha etkili)
    if ($TaramaSonucu.RAMKullanim -gt 60) {
        Write-Durum "RAM temizleniyor..." "Yellow"
        
        # .NET GC çalıştır
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        
        # EmptyWorkingSet API ile processes'lerin working set'ini küçült
        try {
            Add-Type @"
using System;
using System.Runtime.InteropServices;
public class ProcessAPI {
    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr hwProc);
}
"@
            # Sistem dışı kritik olmayan işlemler
            $korunanIslemler = @("csrss", "dwm", "lsass", "services", "svchost", "wininit", "winlogon")
            
            $islemSayisi = 0
            Get-Process | Where-Object { 
                $_.ProcessName -notin $korunanIslemler -and $_.Id -ne 4
            } | ForEach-Object {
                try {
                    [ProcessAPI]::EmptyWorkingSet($_.Handle) | Out-Null
                    $islemSayisi++
                } catch {
                    # Erişim reddedilirse sessizce geç
                }
            }
            
            Write-Basari "RAM temizliği tamamlandı ($islemSayisi işlem)"
            Log-Yaz -KitapAdi $KitapAdi -Islem "RAM Temizliği" -Detay "EmptyWorkingSet ile $islemSayisi işlemin working set'i küçültüldü"
        } catch {
            Write-Basari "RAM temizliği tamamlandı (sadece GC)"
            Log-Yaz -KitapAdi $KitapAdi -Islem "RAM Temizliği" -Detay "Sadece .NET GC çalıştırıldı"
        }
    }
    
    # 2. Geçici Dosya Temizliği (Çöp Kutusu'na gönder - Madde 1 uyumlu)
    if ($TaramaSonucu.CacheBoyut -gt 500) {
        Write-Durum "Geçici dosyalar temizleniyor..." "Yellow"
        
        # Çöp Kutusu için VisualBasic assembly
        Add-Type -AssemblyName Microsoft.VisualBasic
        
        $tempKlasor = $env:TEMP
        $silinenBoyut = 0
        
        Get-ChildItem -Path $tempKlasor -Recurse -ErrorAction SilentlyContinue | 
            Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
            ForEach-Object {
                try {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName, 'OnlyRecycleBin', 'SendToRecycleBin')
                    $silinenBoyut += $_.Length
                } catch {
                    # Çöp kutusuna gönderilemezse sessizce geç
                }
            }
        
        Write-Basari "Geçici dosya temizliği tamamlandı ($([math]::Round($silinenBoyut/1MB, 0)) MB)"
        Write-Durum "Dosyalar Çöp Kutusu'na gönderildi" "Gray"
        Log-Yaz -KitapAdi $KitapAdi -Islem "Geçici Dosya Temizliği" -Detay "$([math]::Round($silinenBoyut/1MB, 0)) MB Çöp Kutusu'na gönderildi"
    }
    
    # 3. Ağır İşlemleri Askıya Alma
    if ($TaramaSonucu.IslemSayisi -gt 150) {
        Write-Durum "Ağır arka plan işlemleri askıya alınıyor..." "Yellow"
        
        foreach ($servis in @("SearchIndexer", "BITS", "SysMain")) {
            try {
                $mevcutDurum = Get-Service -Name $servis -ErrorAction SilentlyContinue
                if ($mevcutDurum -and $mevcutDurum.Status -eq "Running") {
                    Stop-Service -Name $servis -Force -ErrorAction SilentlyContinue
                    Write-Durum "  Askıya alındı: $servis" "Gray"
                }
            } catch {
                # Devam et
            }
        }
        
        Write-Basari "İşlem askıya alma tamamlandı"
        Log-Yaz -KitapAdi $KitapAdi -Islem "İşlem Askıya Alma" -Detay "SearchIndexer, BITS, SysMain durduruldu"
    }
    
    # SONUÇ
    Write-Baslik "✨ NEFES BUYUSU TAMAMLANDI"
    
    # Yeni durum
    $yeniRam = Get-CimInstance -ClassName Win32_OperatingSystem
    $yeniRamBosGB = [math]::Round($yeniRam.FreePhysicalMemory / 1MB, 2)
    $yeniIslem = (Get-Process).Count
    
    Write-Durum "Önceki boş RAM: $($TaramaSonucu.RAMBos) GB" "Gray"
    Write-Durum "Şu anki boş RAM: $yeniRamBosGB GB" "Green"
    Write-Durum ""
    Write-Durum "Önceki işlem sayısı: $($TaramaSonucu.IslemSayisi)" "Gray"
    Write-Durum "Şu anki işlem sayısı: $yeniIslem" "Green"
    Write-Host ""
    
    Write-Durum "💡 İpucu: Bilgisayarı yeniden başlattığınızda her şey normale döner." "Cyan"
    Write-Durum "💡 İpucu: Geri almak için: .\nefes.ps1 -Undo" "Cyan"
    
    Log-Yaz -KitapAdi $KitapAdi -Islem "Büyü Tamamlandı" -Detay "RAM: $($TaramaSonucu.RAMBos)GB -> ${yeniRamBosGB}GB, İşlem: $($TaramaSonucu.IslemSayisi) -> $yeniIslem"
}

# ============================================
# ANA AKIŞ
# ============================================

Clear-Host
Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       💨 NEFES KİTABI 💨              ║" -ForegroundColor Cyan
Write-Host "║    Bilgisayarını Nefes Aldır          ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @(
        "Askıya alınan servisler yeniden başlatılacak"
    ) -GeriAlmaLogigi { param($Yedek) Nefes-GeriAl -Yedek $Yedek }
    Write-Host "`nBir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$tarama = Sistem-Tarama
$islemler = Nefes-PlanGoster -TaramaSonucu $tarama

if ($islemler.Count -eq 0) {
    Write-Durum "Bilgisayarın zaten iyi durumda! Büyü gerekmiyor." "Green"
} else {
    $onay = Onay-Al -Baslik "Nefes Büyüsü Onayı" -Islemler $islemler -TestModuVar
    
    switch ($onay) {
        "Uygula" { Nefes-Uygula -TaramaSonucu $tarama -TestModu $false }
        "Test"   { Nefes-Uygula -TaramaSonucu $tarama -TestModu $true }
    }
}

Write-Host "`nBir tuşa basın..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
