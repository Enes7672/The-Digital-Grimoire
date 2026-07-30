# ============================================
# GRIMOIRE ORTAK YARDIMCI FONKSİYONLAR
# ============================================
# Tüm kitaplar bu dosyadaki fonksiyonları kullanır
# ============================================

$Script:GrimoireKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:AnaKlasor = Split-Path -Parent $GrimoireKlasor
$Script:YedekKlasor = Join-Path $AnaKlasor "grimoir-yedekler"
$Script:MerkeziLog = Join-Path $AnaKlasor "GRIMOIRE-LOG.md"

# ============================================
# YAZI YARDIMCILARI
# ============================================

function Write-Baslik {
    param([string]$Metin)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $Metin" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Durum {
    param([string]$Metin, [string]$Renk = "White")
    Write-Host "  → $Metin" -ForegroundColor $Renk
}

function Write-Hata {
    param([string]$Metin)
    Write-Host "  ❌ $Metin" -ForegroundColor Red
}

function Write-Basari {
    param([string]$Metin)
    Write-Host "  ✅ $Metin" -ForegroundColor Green
}

function Write-Uyari {
    param([string]$Metin)
    Write-Host "  ⚠️  $Metin" -ForegroundColor Yellow
}

# ============================================
# LOG SİSTEMİ (Madde 6)
# ============================================

function Log-Yaz {
    param(
        [string]$KitapAdi,
        [string]$Islem,
        [string]$Detay = ""
    )
    
    $tarih = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logGirdisi = @"

## [$tarih] - $KitapAdi
- **İşlem:** $Islem
- **Detay:** $Detay
- **Kullanıcı:** $env:USERNAME
- **Bilgisayar:** $env:COMPUTERNAME

"@
    
    # Merkezi log
    if (-not (Test-Path $Script:MerkeziLog)) {
        $baslik = @"
# 📜 Grimoire Merkezi İşlem Günlüğü

> Bu dosya tüm büyü işlemlerini kaydeder. Otomatik olarak güncellenir.

"@
        Set-Content -Path $Script:MerkeziLog -Value $baslik -Encoding UTF8
    }
    
    Add-Content -Path $Script:MerkeziLog -Value $logGirdisi -Encoding UTF8
    
    # Kitaba özel log (çağıran scriptin kendi klasörüne yazılır, ör: nefes-kitabi/LOG.md)
    $kitapKlasoru = if ($Script:ScriptKlasor) { $Script:ScriptKlasor } else { $Script:GrimoireKlasor }
    $kitapLog = Join-Path $kitapKlasoru "LOG.md"
    if (-not (Test-Path $kitapLog)) {
        $kitapBaslik = @"
# $KitapAdi - İşlem Günlüğü

> Bu dosya otomatik olarak güncellenir.

"@
        Set-Content -Path $kitapLog -Value $kitapBaslik -Encoding UTF8
    }
    
    Add-Content -Path $kitapLog -Value $logGirdisi -Encoding UTF8
}

# ============================================
# YEDEKLEME SİSTEMİ (Madde 5)
# ============================================

function Yedek-Olustur {
    param(
        [string]$KitapAdi,
        [string]$Aciklama,
        [array]$Dosyalar = @()
    )
    
    # Yedek klasörünü oluştur (DOSYA OLMASA BİLE)
    if (-not (Test-Path $Script:YedekKlasor)) {
        New-Item -ItemType Directory -Path $Script:YedekKlasor -Force | Out-Null
    }
    
    $tarih = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $yedekAdi = "${KitapAdi}_${tarih}"
    $yedekYolu = Join-Path $Script:YedekKlasor $yedekAdi
    
    New-Item -ItemType Directory -Path $yedekYolu -Force | Out-Null
    
    # Yedek bilgi dosyası (her zaman oluştur)
    $bilgi = @{
        Kitap = $KitapAdi
        Tarih = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Aciklama = $Aciklama
        Dosyalar = $Dosyalar
    }
    $bilgi | ConvertTo-Json | Set-Content -Path (Join-Path $yedekYolu "yedek-bilgi.json") -Encoding UTF8
    
    # Dosyaları kopyala (varsa)
    foreach ($dosya in $Dosyalar) {
        if (Test-Path $dosya) {
            $hedef = Join-Path $yedekYolu (Split-Path $dosya -Leaf)
            Copy-Item -Path $dosya -Destination $hedef -Force
        }
    }
    
    Log-Yaz -KitapAdi $KitapAdi -Islem "Yedekleme" -Detay "$($Dosyalar.Count) dosya yedeklendi: $yedekYolu"
    
    return $yedekYolu
}

function Yedek-GeriYukle {
    param(
        [string]$KitapAdi,
        [string]$YedekYolu
    )
    
    if (-not (Test-Path $YedekYolu)) {
        Write-Hata "Yedek bulunamadı: $YedekYolu"
        return $false
    }
    
    $bilgiDosyasi = Join-Path $YedekYolu "yedek-bilgi.json"
    if (-not (Test-Path $bilgiDosyasi)) {
        Write-Hata "Yedek bilgi dosyası bulunamadı"
        return $false
    }
    
    $bilgi = Get-Content -Path $bilgiDosyasi -Raw | ConvertFrom-Json
    
    foreach ($dosya in $bilgi.Dosyalar) {
        $kaynak = Join-Path $yedekYolu (Split-Path $dosya -Leaf)
        if (Test-Path $kaynak) {
            Copy-Item -Path $kaynak -Destination $dosya -Force
            Write-Basari "Geri yüklendi: $dosya"
        }
    }
    
    Log-Yaz -KitapAdi $KitapAdi -Islem "Geri Yükleme" -Detay "$YedekYolu geri yüklendi"
    
    return $true
}

function Yedek-Listele {
    param([string]$KitapAdi = "")
    
    if (-not (Test-Path $Script:YedekKlasor)) {
        Write-Durum "Henüz yedek yok" "Gray"
        return @()
    }
    
    $yedekler = Get-ChildItem -Path $Script:YedekKlasor -Directory | 
        Where-Object { $KitapAdi -eq "" -or $_.Name -like "${KitapAdi}*" } |
        Sort-Object Name -Descending
    
    if ($yedekler.Count -eq 0) {
        Write-Durum "Uygun yedek bulunamadı" "Gray"
        return @()
    }
    
    Write-Baslik "📦 MEVCUT YEDEKLER"
    
    $i = 1
    foreach ($yedek in $yedekler) {
        $bilgiDosyasi = Join-Path $yedek.FullName "yedek-bilgi.json"
        if (Test-Path $bilgiDosyasi) {
            $bilgi = Get-Content -Path $bilgiDosyasi -Raw | ConvertFrom-Json
            Write-Durum "[$i] $($yedek.Name)" "Cyan"
            Write-Durum "    Tarih: $($bilgi.Tarih)" "Gray"
            Write-Durum "    Açıklama: $($bilgi.Aciklama)" "Gray"
            Write-Durum "    Dosya Sayısı: $($bilgi.Dosyalar.Count)" "Gray"
            $i++
        }
    }
    
    return $yedekler
}

# ============================================
# GERİ ALMA SİSTEMİ (Madde 1) - TEK YER
# ============================================

function GeriAl-Yap {
    param(
        [string]$KitapAdi,
        [string[]]$GeriAlmaIslemler,
        [scriptblock]$GeriAlmaLogigi
    )
    
    Write-Baslik "🔄 $KitapAdi - GERİ ALMA"
    
    $yedekler = Yedek-Listele -KitapAdi $KitapAdi
    
    if ($yedekler.Count -eq 0) {
        Write-Durum "Geri alınacak yedek bulunamadı" "Yellow"
        return $false
    }
    
    $sonYedek = $yedekler[0]
    $bilgi = Get-Content -Path (Join-Path $sonYedek.FullName "yedek-bilgi.json") -Raw | ConvertFrom-Json
    
    Write-Durum "Son yedek: $($sonYedek.Name)" "Cyan"
    Write-Durum "Tarih: $($bilgi.Tarih)" "Gray"
    
    $onay = Onay-Al -Baslik "Geri Al Onayı" -Islemler $GeriAlmaIslemler
    if ($onay -ne "Uygula") {
        Write-Durum "Geri alma iptal edildi" "Gray"
        return $false
    }
    
    if ($GeriAlmaLogigi) {
        & $GeriAlmaLogigi $sonYedek
    }
    
    Log-Yaz -KitapAdi $KitapAdi -Islem "Geri Alma" -Detay "Geri alma tamamlandı"
    Write-Basari "Geri alma tamamlandı!"
    return $true
}

function Geri-Al-Onay {
    param(
        [string]$IslemAdi,
        [string]$Aciklama
    )
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  🔄 GERİ ALMA İŞLEMİ" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Durum "İşlem: $IslemAdi" "Cyan"
    Write-Durum "Açıklama: $Aciklama" "Gray"
    Write-Host ""
    Write-Uyari "Bu işlem geri alınacaktır!"
    Write-Host ""
    
    $onay = Read-Host "Devam edilsin mi? (E/H)"
    return ($onay.ToUpper() -eq "E")
}

# ============================================
# TEST MODU (Madde 7)
# ============================================

function Test-Baslat {
    param([string]$KitapAdi)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "  🧪 TEST MODU - $KitapAdi" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Durum "Test modunda hiçbir değişiklik yapılmaz" "Magenta"
    Write-Durum "Sadece ne yapacağı gösterilir" "Magenta"
    Write-Host ""
}

function Test-Bitir {
    param([string]$KitapAdi)
    
    Write-Host ""
    Write-Durum "Test modu tamamlandı. Hiçbir değişiklik yapılmadı." "Magenta"
    Log-Yaz -KitapAdi $KitapAdi -Islem "Test Modu" -Detay "Test modu çalıştırıldı, değişiklik yok"
}

# ============================================
# YÖNETİCİ KONTROLÜ
# ============================================

function Test-Yonetici {
    $yonetici = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $yonetici) {
        Write-Hata "Bu büyü yönetici hakları gerektirir!"
        Write-Uyari "PowerShell'i 'Yönetici olarak Çalıştır' seçeneği ile açın."
    }
    
    return $yonetici
}

# ============================================
# ONAY SİSTEMİ (Madde 3)
# ============================================

function Onay-Al {
    param(
        [string]$Baslik,
        [string[]]$Islemler,
        [switch]$TestModuVar
    )
    
    Write-Baslik "📋 $Baslik"
    
    Write-Durum "Yapılacak işlemler:" "Cyan"
    foreach ($islem in $Islemler) {
        Write-Durum "  • $islem" "White"
    }
    
    Write-Host ""
    Write-Uyari "Hiçbir kişisel dosyanız silinmeyecek veya değiştirilmeyecek"
    Write-Uyari "Tüm değişiklikler geri alınabilir"
    
    Write-Host ""
    Write-Host "  [E] - Evet, uygula" -ForegroundColor Green
    Write-Host "  [H] - Hayır, iptal et" -ForegroundColor Red
    if ($TestModuVar) {
        Write-Host "  [T] - Sadece test et (değişiklik yapma)" -ForegroundColor Magenta
    }
    Write-Host ""
    
    $secim = Read-Host "Seçiminiz"
    
    switch ($secim.ToUpper()) {
        "E" { return "Uygula" }
        "H" { return "Iptal" }
        "T" { return "Test" }
        default { return "Iptal" }
    }
}
