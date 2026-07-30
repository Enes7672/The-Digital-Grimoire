# ============================================
# BATARYA KİTABI - Ana Büyü Scripti
# ============================================
# Pil sağlığını raporlar ve güç planını
# geçici olarak tasarruf moduna alır
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Batarya Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

function Batarya-Tarama {
    Write-Baslik "🔋 BATARYA DURUMU"
    $pil = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if (-not $pil) {
        Write-Uyari "Bu cihazda pil algılanmadı (masaüstü bilgisayar olabilir)"
        return $null
    }
    Write-Durum "Şarj Yüzdesi: %$($pil.EstimatedChargeRemaining)" "Cyan"
    Write-Durum "Durum: $($pil.BatteryStatus)" "Cyan"

    $aktifPlan = powercfg /getactivescheme
    Write-Durum "Aktif Güç Planı: $aktifPlan" "White"

    return $pil
}

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @("Önceki güç planı geri yüklenecek") -GeriAlmaLogigi {
        param($yedek)
        $bilgiDosyasi = Join-Path $yedek.FullName "yedek-bilgi.json"
        $jsonDosya = Join-Path $yedek.FullName "guc-plani.json"
        if (Test-Path $jsonDosya) {
            $eskiGuid = (Get-Content $jsonDosya -Raw | ConvertFrom-Json).Guid
            powercfg /setactive $eskiGuid
            Write-Basari "Önceki güç planı geri yüklendi"
        } else {
            Write-Uyari "Yedek bulunamadı"
        }
    }
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

$pil = Batarya-Tarama
if (-not $pil) { exit }

$islemler = @(
    "Aktif güç planı 'Güç Tasarrufu' moduna geçirilecek (geri alınabilir)",
    "Ekran zaman aşımı kısaltılacak (pil tasarrufu için)"
)
$onay = Onay-Al -Baslik "Pil Tasarrufu Uygula" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Güç planı değiştirilmedi" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

# Mevcut planı yedekle
$eskiGuidRaw = (powercfg /getactivescheme) -match '([0-9a-fA-F-]{36})'
$eskiGuid = $Matches[1]
$yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Güç planı değişmeden önce yedek" -Dosyalar @()
@{ Guid = $eskiGuid } | ConvertTo-Json | Set-Content -Path (Join-Path $yedekYolu "guc-plani.json") -Encoding UTF8

# Güç Tasarrufu planına geç (Windows dahili GUID)
powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a
powercfg /change monitor-timeout-dc 3

Write-Basari "Güç planı 'Güç Tasarrufu' olarak ayarlandı"
Log-Yaz -KitapAdi $KitapAdi -Islem "Pil Tasarrufu" -Detay "Güç planı değiştirildi, eski GUID: $eskiGuid"
Write-Basari "Büyü tamamlandı! Geri almak için: .\batarya.ps1 -Undo"
