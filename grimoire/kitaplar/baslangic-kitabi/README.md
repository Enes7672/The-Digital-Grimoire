# Başlangıç Kitabı

> *Bilgisayarını gereksiz yükten kurtaran bir büyü*

---

## Ne Yapar?

- Windows açılışında otomatik başlayan uygulamaları **listeler**
- Seçtiğin uygulamaları başlangıçtan **kaldırır** (registry `Run` anahtarından)
- Uygulamaların kendisini **silmez**, sadece otomatik açılmalarını durdurur

## ⚠️ Uyarılar

- Hangi uygulamanın ne işe yaradığından emin değilsen kaldırma, önce araştır
- Antivirüs gibi kritik güvenlik yazılımlarını kapatmamaya dikkat et

## 📋 Nasıl Kullanılır?

```powershell
.\baslangic.ps1              # Listele ve seç
.\baslangic.ps1 -TestMode    # Sadece göster, değişiklik yapma
.\baslangic.ps1 -Undo        # Son değişikliği geri al
```

## 🔄 Geri Dönüş (Madde 1)

Kaldırma öncesi ilgili registry anahtarı `.reg` dosyası olarak yedeklenir.
`-Undo` bu yedeği geri içe aktarır.

## 📁 Dosya Yapısı

```
baslangic-kitabi/
├── README.md
├── baslangic.ps1
├── baslangic.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
