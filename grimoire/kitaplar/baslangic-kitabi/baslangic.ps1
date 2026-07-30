# ============================================
# BAŞLANGIÇ KİTABI - Ana Büyü Scripti
# ============================================
# Açılışta otomatik başlayan uygulamaları listeler
# ve seçilenleri güvenli şekilde (geri alınabilir) durdurur
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Başlangıç Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$RunAnahtarlari = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

function Baslangic-Tarama {
    Write-Baslik "🔍 BAŞLANGIÇ UYGULAMALARI TARANIYOR"
    $liste = @()
    foreach ($anahtar in $RunAnahtarlari) {
        if (Test-Path $anahtar) {
            $degerler = Get-Item $anahtar
            foreach ($ad in $degerler.Property) {
                $liste += [PSCustomObject]@{
                    Ad     = $ad
                    Komut  = $degerler.GetValue($ad)
                    Anahtar = $anahtar
                }
            }
        }
    }
    $i = 1
    foreach ($item in $liste) {
        Write-Durum "[$i] $($item.Ad) -> $($item.Komut)" "White"
        $i++
    }
    if ($liste.Count -eq 0) { Write-Durum "Kayıtlı başlangıç uygulaması bulunamadı" "Gray" }
    return $liste
}

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @("Son yedeklenen Run anahtarı .reg dosyası içe aktarılacak") -GeriAlmaLogigi {
        param($yedek)
        $regDosya = Get-ChildItem -Path $yedek.FullName -Filter "*.reg" | Select-Object -First 1
        if ($regDosya) {
            reg import "$($regDosya.FullName)" | Out-Null
            Write-Basari "Başlangıç kayıtları geri yüklendi: $($regDosya.Name)"
        } else {
            Write-Uyari "Yedekte .reg dosyası bulunamadı"
        }
    }
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

$liste = Baslangic-Tarama
if ($liste.Count -eq 0) { exit }

Write-Host ""
$secimler = Read-Host "Durdurmak istediğiniz uygulamaların numaralarını virgülle girin (örn: 1,3) veya boş bırakın"
if ([string]::IsNullOrWhiteSpace($secimler)) {
    Write-Durum "İşlem yapılmadı" "Gray"
    exit
}
$secilenIndeksler = $secimler -split "," | ForEach-Object { [int]$_.Trim() - 1 }
$secilenler = @()
foreach ($idx in $secilenIndeksler) {
    if ($idx -ge 0 -and $idx -lt $liste.Count) { $secilenler += $liste[$idx] }
}

if ($secilenler.Count -eq 0) { Write-Uyari "Geçerli seçim yok"; exit }

$islemler = $secilenler | ForEach-Object { "'$($_.Ad)' başlangıçtan kaldırılacak (registry değeri silinecek)" }
$onay = Onay-Al -Baslik "Başlangıç Uygulamalarını Kaldır" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Hiçbir şey silinmedi, sadece gösterildi" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

# Her bir anahtarı .reg olarak yedekle (Madde 5) sonra sil
$yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Başlangıç uygulamaları kaldırılmadan önce Run anahtarı yedeği" -Dosyalar @()
foreach ($anahtar in ($RunAnahtarlari | Select-Object -Unique)) {
    $kisayolAd = ($anahtar -replace '[:\\]', '_')
    $regYolu = Join-Path $yedekYolu "$kisayolAd.reg"
    $regPath = $anahtar -replace "HKCU:", "HKEY_CURRENT_USER" -replace "HKLM:", "HKEY_LOCAL_MACHINE"
    reg export "$regPath" "$regYolu" /y 2>$null | Out-Null
}

foreach ($item in $secilenler) {
    Remove-ItemProperty -Path $item.Anahtar -Name $item.Ad -ErrorAction SilentlyContinue
    Write-Basari "Kaldırıldı: $($item.Ad)"
}

Log-Yaz -KitapAdi $KitapAdi -Islem "Başlangıç Temizliği" -Detay "$($secilenler.Count) uygulama kaldırıldı"
Write-Basari "Büyü tamamlandı! Geri almak için: .\baslangic.ps1 -Undo"
