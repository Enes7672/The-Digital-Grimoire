# Depolama Kitabı

> *Diskini boşaltan kadim bir büyü*

---

## Ne Yapar?

Bu büyü, **disk doluluğu** sorunlarını çözer:
- Disk **kullanımını** analiz eder
- **Büyük dosyaları** bulur
- **Gereksiz dosyaları** temizler
- **Çöp kutusu**nu boşaltmaz (geri dönüş hakkı için kasıtlı olarak dokunulmaz)
- Windows Update önbelleği ve küçük resim önbelleği için temizlik sunar

## ⚠️ Uyarılar

- Bu büyü **sadece okuma** yapabilir (temizlik için onay gerekir)
- Hiçbir **kişisel dosyanızı silmez**
- Sadece **güvenli** dosyaları temizler (geçici, önbellek)
- Temizlenen dosyalar **Çöp Kutusu'na** gönderilir, kalıcı silinmez

## 📋 Nasıl Kullanılır?

```powershell
# Normal kullanım
.\depolama.ps1

# Test modu (değişiklik yapmaz)
.\depolama.ps1 -TestMode

# Geri alma (temizliği geri al)
.\depolama.ps1 -Undo
```

Ya da doğrudan `depolama.bat` dosyasına çift tıklayabilirsiniz.

## 🔍 Büyü Aşamaları

1. **Tarama**: Disk durumunu ve büyük dosyaları gösterir
2. **Analiz**: Hangi dosyaların temizlenebileceğini belirler
3. **Plan**: Temizlik planını sunar
4. **Onay**: Siz onay verirsiniz
5. **Uygulama**: Seçili dosyaları Çöp Kutusu'na gönderir

## 🔄 Geri Dönüş (Madde 1)

```powershell
.\depolama.ps1 -Undo
```

Bu komut:
- Çöp Kutusu'nu açar (dosyaları manuel geri yükleyebilmeniz için)
- Windows Update servisini yeniden başlatır (durdurulmuşsa)

## 🧪 Test Modu (Madde 7)

```powershell
.\depolama.ps1 -TestMode
```

## 📝 Log (Madde 6)

Her kullanım hem kendi `LOG.md`'sine hem de merkezi `GRIMOIRE-LOG.md` dosyasına kaydedilir.

## 🛡️ Güvenlik (Madde 5)

- Temizlik öncesi dosya listesi yedeklenir (`grimoir-yedekler/` klasörü)
- Windows Update çalışıyorsa ilgili temizlik ATLANIR
- Dosyalar kalıcı silinmez, Çöp Kutusu'na gönderilir

## 📁 Dosya Yapısı

```
depolama-kitabi/
├── README.md           # Bu dosya
├── depolama.ps1         # Ana büyü (parametre destekli)
├── depolama.bat         # Çift tıkla çalıştırma kısayolu
└── LOG.md               # İşlem geçmişi
```

---

*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
