# Nefes Kitabı

> *Bilgisayarın nefes almasını sağlayan eski bir büyü*

---

## Ne Yapar?

Bu büyü, bilgisayarın **nefes almasını** sağlar:
- **RAM**'i temizler (boşaltır)
- **Arka plan** işlemlerini askıya alır
- **Önbellek** (cache) dosyalarını temizler
- **İşlemci** yükünü azaltır

## ⚠️ Uyarılar

- Bu büyü **geçicidir** - bilgisayarı yeniden başlattığında eski haline döner
- **Oyun veya ağır uygulama** çalıştırırken çalıştırmanız önerilir
- Büyü sonrası bilgisayar biraz **yavaş tepki** verebilir (normal)

## 📋 Nasıl Kullanılır?

```powershell
# Normal kullanım
.\nefes.ps1

# Test modu (değişiklik yapmaz)
.\nefes.ps1 -TestMode

# Geri alma (son işlemi geri al)
.\nefes.ps1 -Undo
```

Ya da doğrudan `nefes.bat` dosyasına çift tıklayabilirsiniz.

## 🔍 Büyü Aşamaları

1. **Tarama**: Sistemin mevcut durumunu gösterir
2. **Plan**: Ne yapacağını açıklar
3. **Onay**: Siz onay verirsiniz
4. **Uygulama**: Büyüyü uygular
5. **Sonuç**: Önce/sonra karşılaştırma

## 🔄 Geri Dönüş (Madde 1)

Büyü sonrası her şeyi geri almak için:
```powershell
.\nefes.ps1 -Undo
```

Bu komut:
- Askıya alınan servisleri (SearchIndexer, BITS, SysMain) yeniden başlatır
- Yedek varsa geri yükler

## 🧪 Test Modu (Madde 7)

Değişiklik yapmadan ne yapacağını görmek için:
```powershell
.\nefes.ps1 -TestMode
```

## 📝 Log (Madde 6)

Her kullanım hem kendi `LOG.md`'sine hem de merkezi `GRIMOIRE-LOG.md` dosyasına kaydedilir.

## 📁 Dosya Yapısı

```
nefes-kitabi/
├── README.md           # Bu dosya
├── nefes.ps1            # Ana büyü (parametre destekli)
├── nefes.bat            # Çift tıkla çalıştırma kısayolu
└── LOG.md               # İşlem geçmişi
```

---

*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
