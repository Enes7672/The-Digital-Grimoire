# Batarya Kitabı

> *Pilinin son nefesini uzatan bir büyü*

---

## Ne Yapar?

- Pil **şarj yüzdesini** ve sağlık durumunu gösterir
- Aktif **güç planını** raporlar
- Onayınla güç planını **"Güç Tasarrufu"** moduna geçirir
- Ekran zaman aşımını kısaltarak pil tüketimini azaltır

## ⚠️ Uyarılar

- Masaüstü bilgisayarlarda pil algılanamaz, script bunu bildirir ve çıkar
- Güç planı değişikliği **tamamen geri alınabilir**

## 📋 Nasıl Kullanılır?

```powershell
.\batarya.ps1
.\batarya.ps1 -TestMode
.\batarya.ps1 -Undo
```

## 🔄 Geri Dönüş (Madde 1)

Değişiklik öncesi aktif güç planının GUID'i yedeklenir, `-Undo` ile eski plana dönülür.

## 📁 Dosya Yapısı

```
batarya-kitabi/
├── README.md
├── batarya.ps1
├── batarya.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
