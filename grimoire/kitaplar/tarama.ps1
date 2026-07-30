# Tarama Scripti - Sistemin mevcut durumunu gösterir
# Bu script SADECE okuma yapar, değişiklik yapmaz

function Get-SistemDurumu {
    # RAM Durumu
    $ram = Get-CimInstance -ClassName Win32_OperatingSystem
    $ramToplam = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)
    $ramBos = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)
    $ramKullanim = [math]::Round(($ramToplam - $ramBos) / $ramToplam * 100, 1)
    
    # İşlemci Durumu
    $cpu = Get-CimInstance -ClassName Win32_Processor
    try {
        $cpuKullanim = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples.CookedValue
    } catch {
        $cpuKullanim = ($cpu | Measure-Object -Property LoadPercentage -Average).Average
    }
    
    # Disk Durumu
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
    
    # Arka Plan İşlemleri
    $islemSayisi = (Get-Process).Count
    $buyukIslemler = Get-Process | Where-Object {$_.WorkingSet64 -gt 100MB} | 
        Sort-Object WorkingSet64 -Descending | 
        Select-Object -First 10 Name, @{N='MB';E={[math]::Round($_.WorkingSet64/1MB,0)}}
    
    # Sonuç
    [PSCustomObject]@{
        RAM = @{
            Toplam = $ramToplam
            Bos = $ramBos
            KullanimOrani = $ramKullanim
        }
        CPU = @{
            Model = $cpu.Name
            KullanimOrani = [math]::Round($cpuKullanim, 1)
        }
        Disk = $disk | ForEach-Object {
            [PSCustomObject]@{
                Harf = $_.DeviceID
                Toplam = [math]::Round($_.Size / 1GB, 1)
                Bos = [math]::Round($_.FreeSpace / 1GB, 1)
            }
        }
        Islem = @{
            ToplamIslem = $islemSayisi
            BuyukIslemler = $buyukIslemler
        }
    }
}

# Çalıştır
$tarama = Get-SistemDurumu

# Göster
Write-Host "`n=== SISTEM DURUMU TARAMASI ===" -ForegroundColor Cyan
Write-Host "`n--- RAM ---" -ForegroundColor Yellow
Write-Host "Toplam: $($tarama.RAM.Toplam) GB"
Write-Host "Boş: $($tarama.RAM.Bos) GB"
Write-Host "Kullanım: %$($tarama.RAM.KullanimOrani)" -ForegroundColor $(if($tarama.RAM.KullanimOrani -gt 80){"Red"}elseif($tarama.RAM.KullanimOrani -gt 60){"Yellow"}else{"Green"})

Write-Host "`n--- İŞLEMCİ ---" -ForegroundColor Yellow
Write-Host "Model: $($tarama.CPU.Model)"
Write-Host "Kullanım: %$($tarama.CPU.KullanimOrani)" -ForegroundColor $(if($tarama.CPU.KullanimOrani -gt 80){"Red"}elseif($tarama.CPU.KullanimOrani -gt 60){"Yellow"}else{"Green"})

Write-Host "`n--- DİSK ---" -ForegroundColor Yellow
$tarama.Disk | ForEach-Object {
    Write-Host "$($_.Harf) - Toplam: $($_.Toplam) GB | Boş: $($_.Bos) GB"
}

Write-Host "`n--- İŞLEMLER ---" -ForegroundColor Yellow
Write-Host "Toplam İşlem Sayısı: $($tarama.Islem.ToplamIslem)"
Write-Host "`nEn Çok Bellek Kullanan İlk 10 İşlem:"
$tarama.Islem.BuyukIslemler | Format-Table -AutoSize

# Sonucu döndür
$tarama
