# Güvenlik Kitabı

> *Kalkanın hâlâ ayakta olup olmadığını gösteren bir büyü*

---

## Ne Yapar?

- Windows Defender **gerçek zamanlı koruma** durumunu ve imza güncelliğini gösterir
- **Güvenlik Duvarı** profillerinin (Etki Alanı/Özel/Genel) açık olup olmadığını raporlar
- Onayınla **hızlı tarama** başlatır
- Kapalı bulunan güvenlik duvarı profillerini **açar**

## ⚠️ Uyarılar

- Bu kitap **hiçbir koruma özelliğini kapatmaz**, sadece açık olmayanı açar
- Üçüncü parti antivirüs kullanıyorsan Defender bilgisi sınırlı gelebilir

## 📋 Nasıl Kullanılır?

```powershell
.\guvenlik.ps1
.\guvenlik.ps1 -TestMode
```

## 🔄 Geri Dönüş (Madde 1)

Bu kitap sadece koruma açar/tarama başlatır; kapatma işlemi yapmadığı için
`-Undo` geri alınacak bir şey olmadığını bildirir.

## 📁 Dosya Yapısı

```
guvenlik-kitabi/
├── README.md
├── guvenlik.ps1
├── guvenlik.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
