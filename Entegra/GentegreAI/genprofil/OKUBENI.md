# GenProfil — kurum profili bakım aracı

Teknisyen aracı: **hangi kurumun sunucusuna** bağlanacağını girişte yazarsın,
kullanıcı/parola ile bağlanır, o kurulumun **kurum profilini** açar; düzenler,
kaydeder, çıkarsın. Web ürününe girip menüde profil aramaya gerek kalmaz.

```bash
npm install
npm run dev     # http://localhost:5174 (geliştirme)
npm run build   # dist/
npm run basla   # dist'i kendi sunucusuyla servis eder (http://localhost:5174)
```

## Kurallar

- **Ekran kopyalanmaz, paylaşılır.** Kurum profili ekranı, API istemcisi, oturum
  yönetimi ve tema `../web/src` içinden `@web` takma adıyla gelir. İki ayrı
  profil ekranı iki ayrı davranış demekti; buradaki kod yalnız *kabuk*: adres
  girişi, giriş formu ve üst şerit.
- **Vekil (proxy) zorunlu, CORS ayarı değil.** Tarayıcı hep GenProfil'in kendi
  kaynağına istek atar; hedef adres `/vekil/<base64url(adres)>/api/...` yolunun
  içinde taşınır ve Node tarafı (`vekil.mjs`) hedefe iletir. Böylece bağlanılan
  sunucuda **CORS listesine aracın adresini eklemek gerekmez** - araç her kurumun
  sunucusuna olduğu gibi bağlanır. Adresin yolda taşınması bilinçli: istemci
  yalnız API tabanını değiştirir, istek gönderen ortak kod hiç değişmez.
- **Adres önce alınır.** Oturum sağlayıcısı mount olunca `/ben` çağırıyor; taban
  adresi belirlenmeden açmak isteği yanlış sunucuya gönderirdi.
- **Kaydetme ekranın kendisinde.** Üstteki "Kaydet ve çık" yalnız oturumu kapatır;
  profil ekranı kendi Kaydet düğmelerini taşır. Araç, ekranın kurallarını
  (doğrulama, yetki, şube) tekrar yazmaz.
- `vekil.mjs` düz JS: aynı ara katmanı hem Vite dev sunucusu (`vite.config.ts`)
  hem üretim sunucusu (`sunucu.mjs`) kullanıyor. Tipi `vekil.d.mts`'de.
- Vekil yalnız `http`/`https` hedeflerine gider ve `dist` dışına çıkan yol
  isteklerini reddeder.

## Doğrulama

Lab kurulumuna bağlanıp test edildi: `http://46.36.201.170/genotipai/lab` →
giriş → Kurum Profili sekmeleri (🏥 Profil · 🌳 Menü Düzeni · 👥 Roller · 🗄 Data
Kullanımı …) ve o kurulumun menü düzeni (242 pasif satır, Merkez/Ankara şubeleri)
göründü.
