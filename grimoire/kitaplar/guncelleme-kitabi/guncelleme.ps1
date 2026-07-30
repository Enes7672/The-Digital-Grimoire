# ============================================
# GÜNCELLEME KİTABI - Ana Büyü Scripti
# ============================================
# Windows Update takılma sorunlarını tanılar
# ve önbelleği (SoftwareDistribution) sıfırlar
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

$Script:KitapAdi = "Güncelleme Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptKlasor "..\utils.ps1")

if (-not (Test-Yonetici)) {
    Write-Host "`nDevam etmek için bir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$SoftDist = "$env:windir\SoftwareDistribution"
$CatRoot2 = "$env:windir\System32\catroot2"
$Servisler = @("wuauserv", "bits", "cryptsvc")

function Guncelleme-Tarama {
    Write-Baslik "🔍 WINDOWS UPDATE DURUMU"
    foreach ($s in $Servisler) {
        $servis = Get-Service -Name $s -ErrorAction SilentlyContinue
        if ($servis) {
            Write-Durum "$($servis.DisplayName): $($servis.Status)" "Cyan"
        }
    }
    if (Test-Path $SoftDist) {
        $boyut = (Get-ChildItem $SoftDist -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Durum "SoftwareDistribution boyutu: $([math]::Round($boyut,1)) MB" "White"
    }
}

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @("Yeniden adlandırılan klasörler eski isimlerine döndürülecek") -GeriAlmaLogigi {
        param($yedek)
        foreach ($s in $Servisler) { Stop-Service -Name $s -Force -ErrorAction SilentlyContinue }
        if (Test-Path "$SoftDist.old") {
            Remove-Item $SoftDist -Recurse -Force -ErrorAction SilentlyContinue
            Rename-Item "$SoftDist.old" $SoftDist
        }
        if (Test-Path "$CatRoot2.old") {
            Remove-Item $CatRoot2 -Recurse -Force -ErrorAction SilentlyContinue
            Rename-Item "$CatRoot2.old" $CatRoot2
        }
        foreach ($s in $Servisler) { Start-Service -Name $s -ErrorAction SilentlyContinue }
        Write-Basari "Önceki güncelleme önbelleği geri yüklendi"
    }
    exit
}

if ($TestMode) { Test-Baslat -KitapAdi $KitapAdi }

Guncelleme-Tarama

$islemler = @(
    "wuauserv, bits, cryptsvc servisleri durdurulacak",
    "SoftwareDistribution klasörü '.old' olarak yeniden adlandırılıp Windows'un yenisini oluşturmasına izin verilecek",
    "catroot2 klasörü aynı şekilde yeniden adlandırılacak",
    "Servisler yeniden başlatılacak"
)
$onay = Onay-Al -Baslik "Windows Update Önbelleğini Sıfırla" -Islemler $islemler -TestModuVar:$TestMode

if ($onay -eq "Iptal") { Write-Durum "İşlem iptal edildi" "Gray"; exit }

$gercekTest = ($onay -eq "Test") -or $TestMode
if ($gercekTest) {
    Write-Durum "[TEST MODU] Hiçbir klasör/servis değiştirilmedi" "Magenta"
    Test-Bitir -KitapAdi $KitapAdi
    exit
}

Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "Update önbelleği sıfırlanmadan önce (klasörler .old olarak yeniden adlandırıldı)" -Dosyalar @() | Out-Null

foreach ($s in $Servisler) {
    Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    Write-Durum "$s durduruldu" "Yellow"
}

if (Test-Path $SoftDist) { Rename-Item $SoftDist "$SoftDist.old" -Force -ErrorAction SilentlyContinue }
if (Test-Path $CatRoot2) { Rename-Item $CatRoot2 "$CatRoot2.old" -Force -ErrorAction SilentlyContinue }

foreach ($s in $Servisler) {
    Start-Service -Name $s -ErrorAction SilentlyContinue
    Write-Durum "$s yeniden başlatıldı" "Green"
}

Write-Basari "Windows Update önbelleği sıfırlandı"
Log-Yaz -KitapAdi $KitapAdi -Islem "Update Sıfırlama" -Detay "SoftwareDistribution ve catroot2 yeniden adlandırıldı"
Write-Basari "Büyü tamamlandı! Geri almak için: .\guncelleme.ps1 -Undo"
