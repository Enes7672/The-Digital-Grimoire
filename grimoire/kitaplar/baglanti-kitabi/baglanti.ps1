# ============================================
# BAĞLANTI KİTABI - Ana Büyü Scripti
# ============================================
# WiFi ve internet bağlantı sorunlarını çözer
# ============================================

param(
    [switch]$TestMode,
    [switch]$Undo
)

# ============================================
# HAZIRLIK
# ============================================

$Script:KitapAdi = "Bağlantı Kitabı"
$Script:ScriptKlasor = Split-Path -Parent $MyInvocation.MyCommand.Path

# Ortak fonksiyonları yükle
. (Join-Path $ScriptKlasor "..\utils.ps1")

# ============================================
# GERİ ALMA - Sadece bu kitaba özel mantık
# ============================================

function Baglanti-GeriAl {
    param($Yedek)
    
    # DNS geri yükleme
    $dnsYedek = Join-Path $Yedek.FullName "dns-ayarlari.json"
    if (Test-Path $dnsYedek) {
        $eskiDNS = Get-Content -Path $dnsYedek -Raw | ConvertFrom-Json
        try {
            $arayuz = Get-NetAdapter | Where-Object { $_.Name -eq $eskiDNS.InterfaceAlias }
            if ($arayuz) {
                Set-DnsClientServerAddress -InterfaceIndex $arayuz.ifIndex -ServerAddresses $eskiDNS.OncekiDNS
                Write-Basari "DNS geri yüklendi: $($eskiDNS.OncekiDNS -join ', ')"
            }
        } catch {
            Write-Durum "DNS geri yüklenemedi: $_" "Yellow"
        }
    }
    
    # Hotspot kapatma
    try { netsh wlan stop hostednetwork 2>$null } catch { }
}

# ============================================
# WiFi TARAMASI (Native PowerShell cmdlet)
# ============================================

function WiFi-Tarama {
    Write-Baslik "📡 WiFi AĞ TARAMASI"
    
    # Native WiFi cmdlet'leri ile tarama (locale bağımsız)
    $wifiAdapter = Get-NetAdapter -Physical | Where-Object { 
        $_.InterfaceDescription -match "Wi-Fi|WiFi|WLAN|Wireless" -and $_.Status -eq "Up" 
    } | Select-Object -First 1
    
    if (-not $wifiAdapter) {
        Write-Durum "WiFi adaptörü bulunamadı veya kapalı" "Red"
        Write-Durum "WiFi adaptörünü kontrol edin" "Yellow"
        return $null
    }
    
    Write-Durum "WiFi Adaptörü: $($wifiAdapter.Name)" "Green"
    Write-Durum "Durum: $($wifiAdapter.Status)" "Green"
    Write-Durum "Hız: $($wifiAdapter.LinkSpeed)" "White"
    
    # Mevcut WiFi profilini al (native cmdlet)
    Write-Host ""
    Write-Durum "Mevcut Bağlantı:" "Cyan"
    
    try {
        $wifiProfile = Get-NetWiFiProfile -InterfaceAlias $wifiAdapter.Name -ErrorAction Stop
        
        Write-Durum "  Ağ Adı (SSID): $($wifiProfile.WirelessProfileName)" "Green"
        
        # Sinyal gücünü al
        $baglanti = Get-NetAdapter | Where-Object { $_.Name -eq $wifiAdapter.Name }
        if ($baglanti) {
            # RadioType ve sinyal için netsh'e fallback (native cmdlet'te sinyal yok)
            $sinyalCikti = netsh wlan show interfaces 2>$null
            if ($sinyalCikti -match "(\d+)%" -and $sinyalCikti -match "Signal") {
                $sinyal = [int]$Matches[1]
                $renk = if($sinyal -gt 70){"Green"}elseif($sinyal -gt 40){"Yellow"}else{"Red"}
                Write-Durum "  Sinyal Gücü: %$sinyal" $renk
            }
        }
        
        Write-Durum "  Güvenlik: $($wifiProfile.Authentication)" "White"
    } catch {
        # Fallback: netsh ile dene (locale bağımlı ama çalışır)
        $wifiProfile = netsh wlan show interfaces 2>$null
        if ($wifiProfile -match "(?:SSID|Ağ Adı)\s*:\s*(.+)") {
            Write-Durum "  Ağ Adı: $($Matches[1].Trim())" "Green"
        }
    }
    
    # Tüm ağları tara (netsh fallback ile)
    Write-Host ""
    Write-Durum "Yakındaki Tüm Ağlar:" "Cyan"
    
    $agListesi = @()
    
    # Yöntem 1: WlanAPI ile tarama (daha güvenilir)
    try {
        # Native WiFi profile'ları listele
        $tumProfiller = netsh wlan show profiles 2>$null
        foreach ($satir in $tumProfiller) {
            if ($satir -match "(?:All User Profile|Tüm Kullanıcı Profili|Profil)\s*:\s*(.+)") {
                $agListesi += [PSCustomObject]@{
                    SSID = $Matches[1].Trim()
                    Sinyal = 0  # Sinyal gücü için ek tarama gerekir
                    Güvenlik = "Bilinmiyor"
                }
            }
        }
    } catch {
        # Sessizce geç
    }
    
    # Yöntem 2: Mevcut ağları tara (sinyal gücü ile)
    $tumAglar = netsh wlan show networks mode=bssid 2>$null
    $simdikiAg = $null
    
    foreach ($satir in $tumAglar) {
        # Universal parsing (farklı diller için)
        if ($satir -match "SSID\s+\d*\s*:\s*(.+)" -or $satir -match "Ağ Adı\s*\d*\s*:\s*(.+)") {
            $simdikiAg = [PSCustomObject]@{
                SSID = $Matches[1].Trim()
                Sinyal = 0
                Güvenlik = "Bilinmiyor"
            }
        }
        if ($satir -match "(\d+)%" -and $simdikiAg) {
            $simdikiAg.Sinyal = [int]$Matches[1]
        }
        if ($simdikiAg -and $simdikiAg.Sinyal -gt 0) {
            $agListesi += $simdikiAg
            $simdikiAg = $null
        }
    }
    
    if ($agListesi.Count -gt 0) {
        $agListesi | Sort-Object { $_.Sinyal } -Descending | 
            ForEach-Object {
                $renk = if($_.Sinyal -gt 70){"Green"}elseif($_.Sinyal -gt 40){"Yellow"}else{"Red"}
                Write-Durum "  $($_.SSID) - Sinyal: %$($_.Sinyal) - Güvenlik: $($_.Güvenlik)" $renk
            }
    } else {
        Write-Durum "Yakınlarda ağ bulunamadı" "Yellow"
    }
    
    return @{
        Adapter = $wifiAdapter
        MevcutAg = $agListesi | Where-Object { $_.Sinyal -gt 0 } | Select-Object -First 1
        TumAglar = $agListesi
    }
}

# ============================================
# BAĞLANTI TANILAMASI
# ============================================

function Baglanti-Tanılama {
    Write-Baslik "🔧 BAĞLANTI TANILAMASI"
    
    $sorunlar = @()
    
    # 1. İnternet bağlantısı kontrolü
    Write-Durum "İnternet bağlantısı kontrol ediliyor..." "Yellow"
    $ping = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet -ErrorAction SilentlyContinue
    
    if ($ping) {
        Write-Basari "İnternet bağlantısı aktif"
    } else {
        Write-Durum "İnternet bağlantısı yok" "Red"
        $sorunlar += "İnternet yok"
    }
    
    # 2. DNS kontrolü
    Write-Durum "DNS çözümleme kontrol ediliyor..." "Yellow"
    $dns = Resolve-DnsName -Name "google.com" -ErrorAction SilentlyContinue
    
    if ($dns) {
        Write-Basari "DNS çözümleme çalışıyor"
    } else {
        Write-Durum "DNS çözümleme başarısız" "Red"
        $sorunlar += "DNS sorunu"
    }
    
    # 3. Gateway kontrolü
    Write-Durum "Ağ geçidi (gateway) kontrol ediliyor..." "Yellow"
    $gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | 
        Select-Object -First 1 NextHop
    
    if ($gateway) {
        $gatewayPing = Test-Connection -ComputerName $gateway.NextHop -Count 1 -Quiet -ErrorAction SilentlyContinue
        if ($gatewayPing) {
            Write-Basari "Ağ geçidine erişim var ($($gateway.NextHop))"
        } else {
            Write-Durum "Ağ geçidine erişim yok" "Red"
            $sorunlar += "Gateway sorunu"
        }
    }
    
    # 4. WiFi adaptörü durumu
    Write-Durum "WiFi adaptörü kontrol ediliyor..." "Yellow"
    $wifi = Get-NetAdapter -Name "*Wi-Fi*","*WiFi*" -ErrorAction SilentlyContinue | 
        Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    
    if ($wifi) {
        Write-Basari "WiFi adaptörü aktif ($($wifi.LinkSpeed))"
    } else {
        Write-Durum "WiFi adaptörü kapalı veya sorunlu" "Red"
        $sorunlar += "WiFi adaptörü sorunu"
    }
    
    return $sorunlar
}

# ============================================
# ÇÖZÜM ÖNERİLERİ
# ============================================

function Cozum-Onerileri {
    param($Sorunlar)
    
    Write-Baslik "💡 ÇÖZÜM ÖNERİLERİ"
    
    if ($Sorunlar.Count -eq 0) {
        Write-Basari "Bağlantınızda sorun görünmüyor!"
        Write-Durum "Sorun devam ederse modemi yeniden başlatmayı deneyin." "Gray"
        return @()
    }
    
    $oneriler = @()
    
    if ($Sorunlar -contains "İnternet yok") {
        Write-Durum "1. Modeminizi yeniden başlatın" "Yellow"
        Write-Durum "2. WiFi'yi kapatıp açın" "Yellow"
        Write-Durum "3. Uçak modunu açıp kapatın" "Yellow"
        $oneriler += "Modem-yeniden-baslatma"
    }
    
    if ($Sorunlar -contains "DNS sorunu") {
        Write-Durum "DNS ayarlarını değiştirebilirim:" "Yellow"
        Write-Durum "  Mevcut: Varsayılan (ISP DNS)" "Gray"
        Write-Durum "  Önerilen 1: Google DNS (8.8.8.8 / 8.8.4.4)" "Green"
        Write-Durum "  Önerilen 2: Cloudflare DNS (1.1.1.1)" "Green"
        $oneriler += "DNS-degisiklik"
    }
    
    if ($Sorunlar -contains "Gateway sorunu") {
        Write-Durum "1. Modeme fiziksel olarak yakın olun" "Yellow"
        Write-Durum "2. Modemi yeniden başlatın" "Yellow"
        Write-Durum "3. Kablo bağlantısını kontrol edin" "Yellow"
    }
    
    if ($Sorunlar -contains "WiFi adaptörü sorunu") {
        Write-Durum "1. WiFi adaptörünü devre dışı bırakıp tekrar etkinleştirin" "Yellow"
        Write-Durum "2. Ağ sürücülerini güncelleyin" "Yellow"
        Write-Durum "3. Ağ sıfırlaması yapın (son çare)" "Yellow"
        $oneriler += "WiFi-sıfırlama"
    }
    
    return $oneriler
}

# ============================================
# DNS DEĞİŞİKLİĞİ
# ============================================

function DNS-Degistir {
    param([bool]$TestModu)
    
    Write-Baslik "🌐 DNS DEĞİŞİKLİĞİ"
    
    if ($TestModu) {
        Test-Baslat -KitapAdi $KitapAdi
        Write-Durum "Test modunda DNS değiştirilmez" "Magenta"
        Write-Durum "Değiştirilecek DNS: 8.8.8.8 / 8.8.4.4 (Google)" "Gray"
        Test-Bitir -KitapAdi $KitapAdi
        return
    }
    
    # Mevcut DNS'i kaydet (geri dönüş için)
    $mevcutDNS = Get-DnsClientServerAddress -AddressFamily IPv4 | 
        Where-Object { $_.ServerAddresses.Count -gt 0 } | 
        Select-Object -First 1
    
    # Yedek oluştur
    $yedekYolu = Yedek-Olustur -KitapAdi $KitapAdi -Aciklama "DNS değişikliği öncesi" -Dosyalar @()
    
    if ($yedekYolu -and $mevcutDNS) {
        @{
            InterfaceAlias = $mevcutDNS.InterfaceAlias
            OncekiDNS = $mevcutDNS.ServerAddresses
        } | ConvertTo-Json | Set-Content -Path (Join-Path $yedekYolu "dns-ayarlari.json") -Encoding UTF8
    }
    
    Write-Durum "DNS ayarları değiştiriliyor..." "Yellow"
    
    try {
        # Tüm aktif arayüzleri bul
        $arayuzler = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        
        foreach ($arayuz in $arayuzler) {
            Set-DnsClientServerAddress -InterfaceIndex $arayuz.ifIndex -ServerAddresses @("8.8.8.8", "8.8.4.4")
            Write-Basari "DNS değiştirildi: $($arayuz.Name)"
        }
        
        # DNS önbelleğini temizle
        Clear-DnsClientCache
        
        Write-Basari "DNS değişikliği tamamlandı!"
        Write-Durum "Yeni DNS: 8.8.8.8 (Google)" "Green"
        Log-Yaz -KitapAdi $KitapAdi -Islem "DNS Değişikliği" -Detay "Google DNS (8.8.8.8) ayarlandı"
    } catch {
        Write-Durum "DNS değiştirilemedi: $_" "Red"
    }
}

# ============================================
# HOTSPOT OLUŞTURMA
# ============================================

function Hotspot-Kur {
    param([bool]$TestModu)
    
    Write-Baslik "📡 HOTSPOT OLUŞTURMA"
    
    if (-not (Test-Yonetici)) {
        Write-Durum "Hotspot oluşturmak için yönetici hakları gerekir" "Red"
        return
    }
    
    if ($TestModu) {
        Test-Baslat -KitapAdi $KitapAdi
        Write-Durum "Test modunda hotspot oluşturulmaz" "Magenta"
        Write-Durum "Oluşturulacak hotspot:" "Gray"
        Write-Durum "  Ağ Adı: [Kullanıcı girecek]" "Gray"
        Write-Durum "  Şifre: [Kullanıcı girecek]" "Gray"
        Test-Bitir -KitapAdi $KitapAdi
        return
    }
    
    Write-Durum "Hotspot ayarları:" "Cyan"
    $ssid = Read-Host "  Ağ adı (SSID)"
    $sifre = Read-Host "  Şifre (en az 8 karakter)" -AsSecureString
    
    # Şifre doğrulama
    $sifreMetin = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sifre))
    
    if ($sifreMetin.Length -lt 8) {
        Write-Durum "Şifre en az 8 karakter olmalı!" "Red"
        return
    }
    
    Write-Host ""
    Write-Durum "Bu hotspot'u oluşturacak:" "Yellow"
    Write-Durum "  Ağ Adı: $ssid" "White"
    Write-Durum "  Şifre: **** (gizli)" "White"
    Write-Uyari "Bu işlem mevcut internet bağlantınızı paylaşır"
    
    $onay = Onay-Al -Baslik "Hotspot Onayı" -Islemler @(
        "Hotspot ağı oluşturulacak",
        "İnternet bağlantısı paylaşılacak"
    )
    
    if ($onay -ne "Uygula") {
        Write-Durum "Hotspot oluşturma iptal edildi" "Gray"
        return
    }
    
    try {
        netsh wlan set hostednetwork mode=allow ssid=$ssid key=$sifreMetin
        netsh wlan start hostednetwork
        Write-Basari "Hotspot başarıyla oluşturuldu!"
        Write-Durum "Diğer cihazlar '$ssid' ağına bağlanabilir" "Green"
        Log-Yaz -KitapAdi $KitapAdi -Islem "Hotspot Oluşturma" -Detay "Ağ: $ssid"
    } catch {
        Write-Durum "Hotspot oluşturulamadı: $_" "Red"
    }
}

# ============================================
# ANA AKIŞ
# ============================================

Clear-Host
Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      📡 BAĞLANTI KİTABI 📡           ║" -ForegroundColor Cyan
Write-Host "║    WiFi Gücünü Eline Al              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan

if ($Undo) {
    GeriAl-Yap -KitapAdi $KitapAdi -GeriAlmaIslemler @(
        "DNS ayarları eski haline döndürülecek",
        "Hotspot kapatılacak"
    ) -GeriAlmaLogigi { param($Yedek) Baglanti-GeriAl -Yedek $Yedek }
    Write-Host "`nBir tuşa basın..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

$testModu = $false
$wifiDurumu = WiFi-Tarama
$sorunlar = Baglanti-Tanılama
$oneriler = Cozum-Onerileri -Sorunlar $sorunlar

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  Ne yapmak istersin?" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [H] - Hotspot oluştur" -ForegroundColor Cyan
Write-Host "  [D] - DNS değiştir (Google DNS)" -ForegroundColor Cyan
Write-Host "  [T] - Test modu" -ForegroundColor Magenta
Write-Host "  [Ç] - Çıkış" -ForegroundColor Gray
Write-Host ""

$secim = Read-Host "Seçiminiz"

switch ($secim.ToUpper()) {
    "H" {
        Hotspot-Kur -TestModu $testModu
    }
    "D" {
        DNS-Degistir -TestModu $testModu
    }
    "T" {
        $testModu = $true
        Write-Host "`n🧪 Test modu aktif" -ForegroundColor Magenta
        # İşlemleri test modunda göster
        if ($sorunlar.Count -gt 0) {
            Write-Durum "Test: following sorunlar bulundu:" "Magenta"
            $sorunlar | ForEach-Object { Write-Durum "  - $_" "Gray" }
        }
    }
    default {
        Write-Host "`nÇıkış yapılıyor..." -ForegroundColor Gray
    }
}

Write-Host "`nBir tuşa basın..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
