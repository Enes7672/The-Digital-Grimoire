# ============================================
# SES KİTABI - Ana Büyü Scripti
# ============================================
# Ses cihazlarını listeler, ses servislerini
# yeniden başlatarak ses/mikrofon sorunlarını çözer
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Ses Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$SesServisleri = @("Audiosrv", "AudioEndpointBuilder")

function Ses-Tarama {
    Write-Baslik "🔊 SES CİHAZLARI VE SERVİSLERİ"
    $cihazlar = Get-CimInstance -ClassName Win32_SoundDevice -ErrorAction SilentlyContinue
    foreach ($c in $cihazlar) {
        Write-Durum "$($c.Name) - Durum: $($c.Status)" "Cyan"
    }
    foreach ($s in $SesServisleri) {
        $servis = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($servis) { Write-Durum "$($servis.DisplayName): $($servis.Status)" "White" }
    }
}

if ($Undo) {
    Write-Uyari "Bu kitap sadece servisleri yeniden başlatır, kalıcı bir değişiklik yapmaz."
    Write-Durum "Geri alınacak bir şey yok. Servisleri tekrar başlatmak için normal modda çalıştırabilirsiniz." "Gray"
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

Ses-Tarama

$islemler = @(
    "Windows Audio (Audiosrv) servisi yeniden başlatılacak",
    "Windows Audio Endpoint Builder servisi yeniden başlatılacak"
)
$onay = Onay-Al -Baslik "Ses Servislerini Yeniden Başlat" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Servisler yeniden başlatılmadı" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

foreach ($s in $SesServisleri) {
    Restart-Service -Name $s -Force -ErrorAction SilentlyContinue
    Write-Basari "$s yeniden başlatıldı"
}

Log-Yaz -KitapAdi $KitapAdi -Islem "Ses Servisleri Yeniden Başlatma" -Detay "Audiosrv ve AudioEndpointBuilder yeniden başlatıldı"
Write-Basari "Büyü tamamlandı! Bu işlem zararsız ve geçicidir, kalıcı bir değişiklik yapmadı."
