# The-Digital-Grimoire

# The Digital Grimoire

> *Bilgisayarın için büyülü çözümler*

Bilgisayarın mı yavaşladı? Isındı mı? WiFi'n mi çekmiyor? 
Bu grimoir'da her soruna bir "büyü" var.

## Nasıl Kullanılır?

1. Grimoir'ı klonla
2. Soruna uygun kitabı seç
3. Kitabın README'sini oku
4. Scripti çalıştır (onay verdikten sonra)

## Kitaplar

| Kitap | Sorun | Durum |
|-------|-------|-------|
| Nefes Kitabı | Yavaşlama / Isınma | ✅ Hazır |
| Bağlantı Kitabı | WiFi Sorunları | ✅ Hazır |
| Depolama Kitabı | Disk Doluluğu | ✅ Hazır |

## 🔧 Parametre Desteği

Tüm scriptler parametre ile çalıştırılabilir:

```powershell
# Normal kullanım
.\nefes.ps1

# Test modu (değişiklik yapmaz, sadece gösterir)
.\nefes.ps1 -TestMode

# Geri alma (son işlemi geri alır)
.\nefes.ps1 -Undo
```

## 🛡️ Güvenlik Özellikleri

Bu projedeki tüm scriptler şu güvenlik özelliklerine sahiptir:

- ✅ **Geri Dönüş Hakkı (Madde 1)**: Her işlem geri alınabilir
- ✅ **Bilgi Edinme Hakkı (Madde 2)**: Ne yapacağı uygulama öncesi gösterilir
- ✅ **Onay Zorunluluğu (Madde 3)**: Kullanıcı onayı olmadan değişiklik yapılmaz
- ✅ **Yasak Büyüler (Madde 4)**: Kişisel dosyalara dokunulmaz
- ✅ **Yedekleme (Madde 5)**: Değişiklik öncesi otomatik yedekleme
- ✅ **Log Tutma (Madde 6)**: Tüm işlemler kaydedilir
- ✅ **Test Modu (Madde 7)**: Önce test, sonra uygulama

## 📁 Proje Yapısı

```
The Digital Grimoire/
├── README.md                    # Bu dosya
├── YASA.md                      # Güvenlik kuralları (10 madde)
├── GRIMOIRE-LOG.md              # Merkezi işlem günlüğü
└── kitaplar/
    ├── utils.ps1                # Ortak yardımcı fonksiyonlar
    ├── nefes-kitabi/            # RAM temizleme, arka plan askıya alma
    ├── baglanti-kitabi/         # WiFi tarama, tanılama, hotspot
    └── depolama-kitabi/         # Disk tarama, büyük dosya bulma, temizlik
```

## 📜 Yasa Kitabı

Tüm büyüleri çalıştırmadan önce **YASA.md** dosyasını okuyun.
Bu dosyada 10 temel güvenlik kuralı vardır.

## Lisans

MIT - Özgürce kullan, paylaş, geliştir.
