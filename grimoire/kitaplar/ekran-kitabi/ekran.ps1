# ============================================
# EKRAN KİTABI - Ana Büyü Scripti
# ============================================
# Ekran kartı ve çözünürlük bilgisini raporlar,
# görüntü sorunları için Masaüstü Pencere Yöneticisini
# (DWM) yeniden başlatır
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Ekran Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

function Ekran-Tarama {
    Write-Baslik "🖥️ EKRAN VE EKRAN KARTI DURUMU"
    $kartlar = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue
    foreach ($k in $kartlar) {
        Write-Durum "$($k.Name)" "Cyan"
        Write-Durum "  Çözünürlük: $($k.CurrentHorizontalResolution)x$($k.CurrentVerticalResolution)" "White"
        Write-Durum "  Sürücü Tarihi: $($k.DriverDate)" "White"
        Write-Durum "  Durum: $($k.Status)" "White"
    }
    $dwm = Get-Service -Name "UxSms" -ErrorAction SilentlyContinue
    if ($dwm) { Write-Durum "Desktop Window Manager: $($dwm.Status)" "Gray" }
}

if ($Undo) {
    Write-Uyari "Bu kitap sadece görüntü servisini yeniden başlatır, kalıcı bir değişiklik yapmaz."
    Write-Durum "Geri alınacak bir şey yok." "Gray"
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

Ekran-Tarama

$islemler = @(
    "Desktop Window Manager (görüntü kompozisyon) yeniden başlatılacak",
    "Bu işlem ekranın 1-2 saniye kararıp geri gelmesine neden olabilir"
)
$onay = Onay-Al -Baslik "Görüntü Sürücüsünü Tazele" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Hiçbir servis yeniden başlatılmadı" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

Restart-Service -Name "UxSms" -Force -ErrorAction SilentlyContinue
Write-Basari "Desktop Window Manager yeniden başlatıldı"

Log-Yaz -KitapAdi $KitapAdi -Islem "Görüntü Tazeleme" -Detay "DWM (UxSms) servisi yeniden başlatıldı"
Write-Basari "Büyü tamamlandı! Bu işlem geçicidir ve kalıcı bir değişiklik yapmadı."
