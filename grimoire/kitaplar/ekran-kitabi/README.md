# Ekran Kitabı

> *Bulanıklaşan ya da donan görüntüyü tazeleyen bir büyü*

---

## Ne Yapar?

- Ekran kartı adı, mevcut çözünürlük ve sürücü tarihini **raporlar**
- Görüntü donmaları/titremeleri için **Desktop Window Manager**'ı yeniden başlatır
  (klasik Win+Ctrl+Shift+B kısayolunun script hali)

## ⚠️ Uyarılar

- Yeniden başlatma sırasında ekran 1-2 saniye kararıp geri gelebilir, normaldir
- Donanımsal ekran kartı arızalarını çözmez, sadece yazılımsal takılmaları giderir

## 📋 Nasıl Kullanılır?

```powershell
.\ekran.ps1
.\ekran.ps1 -TestMode
```

## 🔄 Geri Dönüş (Madde 1)

Kalıcı değişiklik yapılmadığı için `-Undo` sadece bilgilendirme mesajı gösterir.

## 📁 Dosya Yapısı

```
ekran-kitabi/
├── README.md
├── ekran.ps1
├── ekran.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
