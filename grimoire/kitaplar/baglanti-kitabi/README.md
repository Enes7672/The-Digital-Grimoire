# Bağlantı Kitabı

> *WiFi'nin gücünü eline alan eski bir büyü*

---

## Ne Yapar?

Bu büyü, **WiFi ve internet bağlantı** sorunlarını çözer:
- WiFi **sinyal gücünü** analiz eder
- **Mevcut ağları** tarar ve güçlerini gösterir
- Bağlantı sorunlarını **tanılar**
- Gerekirse **hotspot** (erişim noktası) oluşturur
- DNS ayarlarını **optimize** eder

## ⚠️ Uyarılar

- Bu büyü **sadece okuma** ve **analiz** yapabilir (hotspot ve DNS değişikliği hariç)
- Hotspot oluşturma **kullanıcı onayı** gerektirir
- DNS değişiklikleri **geri alınabilir**
- Hiçbir ağa **otomatik bağlanmaz**

## 📋 Nasıl Kullanılır?

```powershell
# Normal kullanım
.\baglanti.ps1

# Test modu (değişiklik yapmaz)
.\baglanti.ps1 -TestMode

# Geri alma (DNS ve hotspot değişikliklerini geri al)
.\baglanti.ps1 -Undo
```

Ya da doğrudan `baglanti.bat` dosyasına çift tıklayabilirsiniz.

## 🔍 Büyü Aşamaları

1. **Tarama**: Mevcut WiFi ağlarını ve güçlerini gösterir
2. **Tanılama**: Bağlantı sorununu belirler
3. **Plan**: Çözüm önerilerini sunar
4. **Onay**: Siz onay verirsiniz
5. **Uygulama**: Seçtiğiniz çözümü uygular

## 🔄 Geri Dönüş (Madde 1)

```powershell
.\baglanti.ps1 -Undo
```

Bu komut:
- DNS ayarlarını eski haline döndürür
- Hotspot'u kapatır (açık ise)

## 🧪 Test Modu (Madde 7)

```powershell
.\baglanti.ps1 -TestMode
```

## 📝 Log (Madde 6)

Her kullanım hem kendi `LOG.md`'sine hem de merkezi `GRIMOIRE-LOG.md` dosyasına kaydedilir.

## 📁 Dosya Yapısı

```
baglanti-kitabi/
├── README.md           # Bu dosya
├── baglanti.ps1         # Ana büyü (parametre destekli)
├── baglanti.bat         # Çift tıkla çalıştırma kısayolu
└── LOG.md               # İşlem geçmişi
```

---

*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
