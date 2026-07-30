# Ses Kitabı

> *Sessiz kalan hoparlörlere ses veren bir büyü*

---

## Ne Yapar?

- Ses çıkışı cihazlarını ve durumlarını **listeler**
- Windows Audio ve Audio Endpoint Builder servislerinin durumunu gösterir
- Onayınla bu servisleri **yeniden başlatır** (klasik "ses gitti" sorununun en yaygın çözümü)

## ⚠️ Uyarılar

- Yeniden başlatma sırasında birkaç saniyeliğine ses kesilir, normaldir
- Donanımsal arızaları (bozuk hoparlör, kablo vb.) çözmez

## 📋 Nasıl Kullanılır?

```powershell
.\ses.ps1
.\ses.ps1 -TestMode
```

## 🔄 Geri Dönüş (Madde 1)

Bu büyü kalıcı bir değişiklik yapmaz (sadece servis yeniden başlatma), bu yüzden `-Undo`
özel bir işlem yapmaz — sadece bilgilendirme mesajı gösterir.

## 📁 Dosya Yapısı

```
ses-kitabi/
├── README.md
├── ses.ps1
├── ses.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
