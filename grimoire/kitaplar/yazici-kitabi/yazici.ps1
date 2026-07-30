# ============================================
# YAZICI KİTABI - Ana Büyü Scripti
# ============================================
# Sıkışan yazdırma kuyruğunu güvenli şekilde
# (yedekleyerek) temizler
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Yazıcı Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$SpoolKlasor = "$env:windir\System32\spool\PRINTERS"

function Yazici-Tarama {
    Write-Baslik "🖨️ YAZICI VE KUYRUK DURUMU"
    $yaziciServis = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue
    Write-Durum "Print Spooler servisi: $($yaziciServis.Status)" "Cyan"

    $yazicilar = Get-Printer -ErrorAction SilentlyContinue
    foreach ($y in $yazicilar) { Write-Durum "$($y.Name) - $($y.PrinterStatus)" "White" }

    $isler = Get-ChildItem -Path $SpoolKlasor -ErrorAction SilentlyContinue
    Write-Durum "Kuyrukta bekleyen dosya sayısı: $($isler.Count)" "White"
    return $isler
}

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @("Yedeklenen yazdırma kuyruğu dosyaları geri konulacak") -GeriAlmaLogigi {
        param($yedek)
        Stop-Service -Name "Spooler" -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path $yedek.FullName -Exclude "yedek-bilgi.json" -ErrorAction SilentlyContinue | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $SpoolKlasor -Force -ErrorAction SilentlyContinue
        }
        Start-Service -Name "Spooler" -ErrorAction SilentlyContinue
        Write-Basari "Kuyruk dosyaları geri kondu ve Spooler yeniden başlatıldı"
    }
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

$isler = Yazici-Tarama
if ($isler.Count -eq 0) {
    Write-Durum "Sıkışmış bir yazdırma işi görünmüyor" "Gray"
    exit
}

$islemler = @(
    "Print Spooler servisi durdurulacak",
    "Kuyruktaki $($isler.Count) dosya önce yedeklenip sonra temizlenecek",
    "Print Spooler servisi yeniden başlatılacak"
)
$onay = Onay-Al -Baslik "Sıkışan Yazdırma Kuyruğunu Temizle" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Kuyruk temizlenmedi" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

Stop-Service -Name "Spooler" -Force
$dosyaYollari = $isler | ForEach-Object { $_.FullName }
$yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Yazdırma kuyruğu temizlenmeden önce" -Dosyalar $dosyaYollari

foreach ($dosya in $isler) {
    Remove-Item -Path $dosya.FullName -Force -ErrorAction SilentlyContinue
}
Start-Service -Name "Spooler"

Write-Basari "$($isler.Count) kuyruk dosyası temizlendi, Spooler yeniden başlatıldı"
Log-Yaz -KitapAdi $KitapAdi -Islem "Kuyruk Temizliği" -Detay "$($isler.Count) dosya yedeklenip temizlendi: $yedekYolu"
Write-Basari "Büyü tamamlandı! Geri almak için: .\yazici.ps1 -Undo"
