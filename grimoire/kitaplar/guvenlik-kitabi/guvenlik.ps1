# ============================================
# GÜVENLİK KİTABI - Ana Büyü Scripti
# ============================================
# Windows Defender ve Güvenlik Duvarı durumunu
# raporlar, kapalıysa açmayı ve hızlı tarama önerir
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Güvenlik Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

function Guvenlik-Tarama {
    Write-Baslik "🛡️ GÜVENLİK DURUMU"
    $defender = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defender) {
        Write-Durum "Gerçek Zamanlı Koruma: $($defender.RealTimeProtectionEnabled)" "Cyan"
        Write-Durum "Son Hızlı Tarama: $($defender.QuickScanEndTime)" "White"
        Write-Durum "İmza Güncel mi: $($defender.AntivirusSignatureAge) gün önce güncellendi" "White"
    } else {
        Write-Uyari "Windows Defender bilgisi alınamadı (üçüncü parti antivirüs olabilir)"
    }

    $guvenlikDuvari = Get-NetFirewallProfile -ErrorAction SilentlyContinue
    foreach ($profil in $guvenlikDuvari) {
        Write-Durum "Güvenlik Duvarı [$($profil.Name)]: $($profil.Enabled)" "White"
    }
    return @{ Defender = $defender; Firewall = $guvenlikDuvari }
}

if ($Undo) {
    Write-Uyari "Bu kitap sadece tarama yapar ve kapalı korumaları açar; güvenlik ayarlarını kapatmaz."
    Write-Durum "Bu yüzden geri alınacak bir değişiklik bulunmuyor." "Gray"
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

$durum = Guvenlik-Tarama

$islemler = @("Windows Defender ile hızlı tarama başlatılacak (birkaç dakika sürebilir)")
$kapaliProfil = $durum.Firewall | Where-Object { $_.Enabled -eq $false }
if ($kapaliProfil) {
    $islemler += "Kapalı olan güvenlik duvarı profilleri açılacak: $($kapaliProfil.Name -join ', ')"
}

$onay = Onay-Al -Baslik "Güvenlik Kontrolü Uygula" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Tarama başlatılmadı, ayar değiştirilmedi" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

if ($kapaliProfil) {
    foreach ($p in $kapaliProfil) {
        Set-NetFirewallProfile -Name $p.Name -Enabled True
        Write-Basari "$($p.Name) güvenlik duvarı profili açıldı"
    }
}

Write-Durum "Hızlı tarama başlatılıyor (arka planda devam edecek)..." "Cyan"
try { Start-MpScan -ScanType QuickScan -ErrorAction Stop } catch { Write-Uyari "Tarama başlatılamadı: $_" }

Log-Yaz -KitapAdi $KitapAdi -Islem "Güvenlik Kontrolü" -Detay "Hızlı tarama başlatıldı, güvenlik duvarı kontrol edildi"
Write-Basari "Büyü tamamlandı! Tarama arka planda devam ediyor."
