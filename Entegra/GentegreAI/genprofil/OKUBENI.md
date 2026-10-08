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
- **Tek bağlantı ekranı.** Adres, kullanıcı ve parola aynı formda alınır
  (`Giris.tsx`). Önce adres sorup kullanıcıyı ikinci ekranda istemek teknisyene
  aynı işi iki adımda yaptırıyor, yanlış adres de ancak ikinci ekranda hata
  veriyordu. Giriş tutmazsa form bilgilerle birlikte geri gelir ve nedeni
  yazar. **Parola saklanmaz**, yalnız adres hatırlanır.
- **Adres önce kurulur.** Oturum sağlayıcısı mount olunca `/ben` çağırıyor; taban
  adresi belirlenmeden açmak isteği yanlış sunucuya gönderirdi. Sunucu değişince
  `key={adres}` ile oturum ve ekran sıfırdan kurulur - eski kurumun kullanıcısı,
  profili ve menüsü yeni bağlantıya taşınmasın.
- **"Kaydet ve Çık" gerçekten kaydeder.** `KurumTipiAyarlari` ana kaydetme
  işlevini `kaydetBagla` ile veriyor; şerit onu çağırır, başarılıysa çıkar.
  Kayıt hata verirse **çıkılmaz** - ekran hatayı gösterir, teknisyen düzeltir;
  sessizce çıkmak değişikliği kaybettirirdi. Yanındaki "Kaydetmeden Çık" adıyla
  ne yaptığını söylüyor. (Önceki sürümde bu düğme yalnız oturumu kapatıyordu;
  adı kaydettiğini söylerken kaydetmemesi yanlış izlenim veriyordu.)
- **Mesaj katmanı da paylaşılır** (`MesajKatmani`). Dinleyici kurulmazsa
  `mesaj()` tarayıcının `alert`ine, `onay()` `confirm`e düşer; `paraSor()` ise
  sessizce `null` döner - profil ekranının bir sorusu hiç sorulmamış sayılırdı.
- Araçtaki kod yalnız *kabuk*: bağlantı ekranı (`Giris`), üst şerit (`Ust`),
  oturum/kaydet akışı (`Profil`) ve vekil. İş kuralları (doğrulama, yetki,
  şube) paylaşılan ekranda.
- `vekil.mjs` düz JS: aynı ara katmanı hem Vite dev sunucusu (`vite.config.ts`)
  hem üretim sunucusu (`sunucu.mjs`) kullanıyor. Tipi `vekil.d.mts`'de.
- Vekil yalnız `http`/`https` hedeflerine gider ve `dist` dışına çıkan yol
  isteklerini reddeder.

## Doğrulama

Lab kurulumuna bağlanıp test edildi: `http://46.36.201.170/genotipai/lab` →
giriş → Kurum Profili sekmeleri (🏥 Profil · 🌳 Menü Düzeni · 👥 Roller · 🗄 Data
Kullanımı …) ve o kurulumun menü düzeni (242 pasif satır, Merkez/Ankara şubeleri)
göründü.
