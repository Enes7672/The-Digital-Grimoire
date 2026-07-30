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
| [Nefes Kitabı](kitaplar/nefes-kitabi/README.md) | Yavaşlama / Isınma | ✅ Hazır |
| [Bağlantı Kitabı](kitaplar/baglanti-kitabi/README.md) | WiFi Sorunları | ✅ Hazır |
| [Depolama Kitabı](kitaplar/depolama-kitabi/README.md) | Disk Doluluğu | ✅ Hazır |
| [Başlangıç Kitabı](kitaplar/baslangic-kitabi/README.md) | Açılışta Gereksiz Uygulamalar | ✅ Hazır |
| [Batarya Kitabı](kitaplar/batarya-kitabi/README.md) | Pil Ömrü | ✅ Hazır |
| [Güncelleme Kitabı](kitaplar/guncelleme-kitabi/README.md) | Windows Update Takılmaları | ✅ Hazır |
| [Ses Kitabı](kitaplar/ses-kitabi/README.md) | Ses / Mikrofon Sorunları | ✅ Hazır |
| [Ekran Kitabı](kitaplar/ekran-kitabi/README.md) | Görüntü / Ekran Kartı Sorunları | ✅ Hazır |
| [Güvenlik Kitabı](kitaplar/guvenlik-kitabi/README.md) | Antivirüs / Güvenlik Duvarı Durumu | ✅ Hazır |
| [Yazıcı Kitabı](kitaplar/yazici-kitabi/README.md) | Sıkışan Yazdırma Kuyruğu | ✅ Hazır |

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
├── YASA.md                      # Güvenlik kuralları (8 madde)
├── GRIMOIRE-LOG.md              # Merkezi işlem günlüğü (otomatik oluşur)
├── grimoir-yedekler/            # Otomatik yedekler (otomatik oluşur)
└── kitaplar/
    ├── utils.ps1                # Ortak yardımcı fonksiyonlar
    ├── tarama.ps1                # Bağımsız sistem durumu tarayıcı (salt okunur)
    ├── nefes-kitabi/             # RAM temizleme, arka plan askıya alma
    ├── baglanti-kitabi/          # WiFi tarama, tanılama, hotspot
    ├── depolama-kitabi/          # Disk tarama, büyük dosya bulma, temizlik
    ├── baslangic-kitabi/         # Açılış uygulamalarını listeleme/kaldırma
    ├── batarya-kitabi/           # Pil durumu, güç planı tasarrufu
    ├── guncelleme-kitabi/        # Windows Update önbelleği sıfırlama
    ├── ses-kitabi/               # Ses servisleri yeniden başlatma
    ├── ekran-kitabi/             # Görüntü/DWM tazeleme
    ├── guvenlik-kitabi/          # Defender/Güvenlik Duvarı kontrolü
    └── yazici-kitabi/            # Yazdırma kuyruğu temizliği
```

## 📜 Yasa Kitabı

Tüm büyüleri çalıştırmadan önce **YASA.md** dosyasını okuyun.
Bu dosyada 8 temel güvenlik kuralı vardır.

## Lisans

MIT - Özgürce kullan, paylaş, geliştir.
