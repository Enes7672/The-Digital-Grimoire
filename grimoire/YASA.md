# Grimoire Yasa Kitabı

> *Bu kitapta yazanlar kesin emirlerdir. Hiçbir büyü bu kuralları ihlal edemez.*

---

## Madde 1: Geri Dönüş Hakkı

Her büyü **geri alınabilir** olmalıdır. Kullanıcı her işlem sonrası 
"Bu değişikliği geri al" seçeneğine sahip olmalıdır.

## Madde 2: Bilgi Edinme Hakkı

Büyü çalıştırılmadan önce kullanıcıya şunlar **açıkça** söylenmelidir:
- Bu büyü ne yapacak?
- Hangi dosyalara/sistemlere müdahale edecek?
- Ne kadar sürecek?
- Geri dönüşü var mı?

## Madde 3: Onay Zorunluluğu

Hiçbir değişiklik yapan büyü **kullanıcı onayı olmadan** çalışmaz.
Otomatik sadece **okuma ve analiz** işlemleri yapılabilir.

## Madde 4: Yasak Büyüler

Aşağıdaki işlemler **ASLA** yapılmaz:

- ❌ Kişisel dosyaları silme veya taşıma
- ❌ Sistem dosyalarına müdahale
- ❌ Şifre veya parola erişimi
- ❌ Kayıt defteri (registry) kritik değişiklikleri
- ❌ Ağ yapılandırmasını bozma
- ❌ Geri alınamayan işlemler
- ❌ Üçüncü parti yazılım yükleme (kullanıcı onayı olmadan)

## Madde 5: Yedekleme Zorunluluğu

Değişiklik yapan her büyüden **önce**:
- Etkilenen dosyaların yedeği alınır
- Yedek "grimoir-yedekler/" klasörüne kaydedilir
- Yedek adı tarih ve saat içermelidir

## Madde 6: Log Tutma

Her büyü çalıştırıldığında bir **LOG.md** dosyasına şu bilgiler yazılır:
- Tarih ve saat
- Çalıştırılan büyü
- Yapılan değişiklikler
- Onay durumu
- Geri dönüş varsa, nasıl yapılacağı

## Madde 7: Test Modu

Her büyüde bir **test modu** bulunmalıdır:
- Test modu: Sadece ne yapacağını gösterir, değişiklik yapmaz
- Uygulama modu: Gerçek değişikliği yapar
- Kullanıcı önce test modunu görmeli, sonra onaylamalı

## Madde 8: Sorumluluk Reddi

Bu grimoir **educational** amaçlıdır. 
Kullanıcı kendi sorumluluğunda çalıştırır.
Büyüler test edilmiş olsa da, her sistem farklıdır.

---

*Bu yasa kitabı tüm grimoir boyunca geçerlidir. 
Hiçbir kitap bu kuralları atlayamaz.*
