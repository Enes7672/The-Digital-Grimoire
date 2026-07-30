# Güncelleme Kitabı

> *Takılan güncellemeleri çözen bir büyü*

---

## Ne Yapar?

- Windows Update servislerinin (`wuauserv`, `bits`, `cryptsvc`) durumunu gösterir
- `SoftwareDistribution` önbellek klasörünün boyutunu raporlar
- Onayınla önbelleği **sıfırlar** (klasörleri silmez, `.old` uzantısıyla yeniden adlandırır — Windows yenisini otomatik oluşturur)

## ⚠️ Uyarılar

- Yönetici hakları gerektirir
- İşlem sırasında servisler kısa süreliğine durur, normaldir

## 📋 Nasıl Kullanılır?

```powershell
.\guncelleme.ps1
.\guncelleme.ps1 -TestMode
.\guncelleme.ps1 -Undo
```

## 🔄 Geri Dönüş (Madde 1)

`.old` olarak yeniden adlandırılan klasörler `-Undo` ile eski isimlerine döndürülür.

## 📁 Dosya Yapısı

```
guncelleme-kitabi/
├── README.md
├── guncelleme.ps1
├── guncelleme.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
