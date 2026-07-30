# Yazıcı Kitabı

> *Sıkışan kağıtları değil, sıkışan kuyruğu açan bir büyü*

---

## Ne Yapar?

- Yazıcıları ve **Print Spooler** servisinin durumunu gösterir
- Kuyrukta bekleyen (sıkışmış) dosya sayısını raporlar
- Onayınla kuyruğu **yedekleyip** temizler, Spooler'ı yeniden başlatır

## ⚠️ Uyarılar

- Kuyruktaki bekleyen yazdırma işleri iptal olur (yedeklenir ama gerçek yazdırma
  işlemi devam etmez); acil bir belge yazdırıyorsan önce onu bitir
- Yönetici hakları gerektirir

## 📋 Nasıl Kullanılır?

```powershell
.\yazici.ps1
.\yazici.ps1 -TestMode
.\yazici.ps1 -Undo
```

## 🔄 Geri Dönüş (Madde 1)

Temizlik öncesi kuyruktaki dosyalar yedeklenir. `-Undo` bu dosyaları kuyruğa
geri koyar ve Spooler'ı yeniden başlatır (not: bazı yazıcı sürücüleri geri konan
işi otomatik olarak yeniden işleme almayabilir).

## 📁 Dosya Yapısı

```
yazici-kitabi/
├── README.md
├── yazici.ps1
├── yazici.bat
└── LOG.md
```

---
*Büyüyü çalıştırmadan önce Grimoire Yasa Kitabı'nı (../../YASA.md) okuyunuz.*
