# GentegreAI kod inceleme raporu — tüm proje

Tarih: 30.10.2026. İncelenen sürüm: `pg-migration` dalı, commit `ce5e83e` + çalışma ağacındaki commit edilmemiş radyoloji/rol değişiklikleri (1199–1200 göçleri dahil). Önceki rapor: [KOD_INCELEME_RAPORU_2026-10-28.md](KOD_INCELEME_RAPORU_2026-10-28.md) — oradaki B01–B07 düzeltmeleri yerinde doğrulandı ve burada yeniden sayılmadı.

## Değerlendirme

**Çekirdek doğru kurulmuş; sorun, çekirdeğin kurallarını kullanmayan özel uçların sayısı.** Liste/kart yolu (katalog + `SorguUretici` + `KayitErisimi`) istek metnini SQL'e sokmuyor, yetkiyi istek başına çözüyor, para matematiğini tek yerde tutuyor, oturum modeli (hash'li refresh, atomik rotation, aile iptali) ve yayın hattı (sınırlı DB rolü, göç uygulayıcı) sağlam. Ancak 1.218 ucun büyük bölümü bu kapılardan geçmeyen "özel uç"; bunlarda aynı dört hata sistematik olarak tekrar ediyor:

1. **Kayıt kapsamı yok** — `YetkiIste` sonrası `where id = @p0`. Kurum içinde başka şubenin, portalda başka hastanın/kurumun kaydı kimlik tahminiyle okunup yazılıyor. En ağır hâli portal rollerinde (hasta, dış doktor, dış kurum, firma yetkilisi): **her hastanın klinik özeti ve TCKN/telefon→hasta çözümü açık (K01, K02).**
2. **Oku-sonra-yaz, kilit ve etkilenen-satır kontrolü yok** — çift tık/iki kullanıcı → çift kasa çıkışı, çift stok düşümü, çift fatura, çift SMS (yaklaşık 30 dosya).
3. **Belge hattı ile bağ güncellemesi ayrı transaction** — `BelgeDeposu.KaydetAsync` kendi işleminde commit ediyor; kaynak satırın "faturalandı/düşüldü" bağı sonra, koşulsuz yazılıyor. Transaction alan overload var, yalnız bir dosya kullanıyor.
4. **Denetim izi eksik** — üretim, reçete, muayene tanı, kod listesi, gebe izlem gibi modüllerde silme/değişiklik logu yok ya da DELETE'ten sonra, yalnız id ile.

Operasyon tarafında iki yapısal açık var: IP tabanlı kurulumlar düz HTTP'de (token ve hasta verisi şifresiz), ve docker arkasında istemci IP'si okunmadığı için IP tabanlı sınırlar bütün kurumu tek istemci sayıyor.

Sayılar: **2 P0, 24 P1, 33 P2, 33 P3.** P0 ve P1'ler müşteri kullanımına açılmadan önce ele alınmalı. Bulgular kod okumasıyla saptandı; bir bölümü dev veritabanında sorguyla doğrulandı (DOĞRULANDI), bir bölümü kodda açık ama çalışma zamanında denenmedi (OLASI). Canlı sistemde saldırı denenmedi.

## Kapsam ve yöntem

Dokuz alan paralel incelendi, her alanın bulguları ikinci bir okumayla doğrulandı; P0/P1'lerin tamamı kaynak satırında yeniden kontrol edildi:

| Alan | Kapsam | Yöntem |
|---|---|---|
| Güvenlik | AraKatman (7 dosya), kimlik/oturum servisleri, 26 anonim uç, `{id}` örneklemesi 14 dosya | tam okuma + dev DB yetki sorguları |
| API uçları A–K | 139 dosya (~47k satır) | tam okuma, tetik/kısıt DB'den |
| API uçları L–Z | 112 dosya (~40k satır); 90 yazma dosyası tam, 22 icmal grep | tam okuma |
| Çekirdek | `SorguUretici`, katalog (310 kaynak betikle tarandı), `BelgeHesap`, `DegerCevirici`, sözleşme | tam okuma |
| Veri + Servisler | `Gentegre.Veri` tamamı, 9 arka plan işçisi, entegrasyonlar | tam okuma; Lab/Sigorta/UTS servisleri yalnız grep |
| Web çekirdek | `api/*`, oturum bağlamı, grid/form, belge, çıktı, hatırlatma | tam okuma; GenGrid/GenForm kısmi |
| Web modüller | ~35 dosya satır satır (radyoloji, muayene, İK, KYS, diş, icmal, liste tanımları) + sistematik grep | hedefli okuma |
| DB | 1184 göç (1100+ idempotentlik), 297 tetik, 679 fonksiyon, indeks/FK/collation sayımları | pg_catalog sorguları |
| Yayın / yapılandırma / test | `yayin/*`, nginx, `Program.cs`, appsettings, 133 test dosyası | tam okuma |

Kapsam dışı: canlı sunucu (SSH yapılmadı), müşteri verisi, yük testi, bağımlılık CVE taraması, Delphi uygulaması, `Servisler/LabServisi*`/`KulturServisi` iç kapsam kontrolleri (bu yüzden bazı lab uçları OLASI). Uygulama kodu bu inceleme için değiştirilmedi.

## Bulgular — P0

### K01 — P0: Portal kullanıcısı her hastanın klinik özetini okuyabiliyor

**Yer:** `api/src/Gentegre.Api/Uclar/HastaUclari.cs:70-78` (`GET /api/hasta/{id}/kart-ozeti`).

Uç yalnız `YetkiIste("hasta", Gor)` kontrol edip `where t.id = @p0` ile okuyor; `KayitErisimi`, şube ya da portal kapsamı yok. Dev DB'de `hasta_portali`, `dis_doktor`, `dis_istem_kurumu` rollerinin hepsinde `hasta.gor = 1`. Dönen veri: doğum tarihi, cinsiyet, kan grubu, alerjiler (etken adlarıyla), kronik tanılar, aktif ilaçlar, bakiye, son başvuru/hekim, sonraki randevu. Kimlikler ardışık; bütün hasta tabanı taranabilir. Aynı dosyada `RadyolojiKayitKapisi`'nin `/hasta/{id}` dalı doğru deseni zaten uyguluyor.

**Düzeltme:** `/api/hasta` grubuna endpoint filtresi (`erisim.IsteAsync(baglam, "hasta", id, …)`); portal türü > 0 ise yalnız kendi kaydı. **Doğrulama:** DOĞRULANDI (kod + DB yetki sorgusu).

### K02 — P0: `/api/hasta/mukerrer` TCKN / telefon / e-posta → hasta kimliği çözücü, portala açık

**Yer:** `HastaUclari.cs:56-67`, `KimlikBulAsync` 165-170, `TelefonBulAsync` 172-180.

Aynı `hasta.gor` yetkisiyle `vkno=`, `cepTel=`, `eposta=` parametresine karşılık id, ad soyad, kod ve doğum tarihi dönüyor. Kart ekranının mükerrer kontrolü için tasarlanmış; portal rolleri de erişiyor. Telefon listesiyle toplu tarama mümkün.

**Düzeltme:** `baglam.PortalTuru > 0` ise 404; ucu `hasta.ekle/degistir` yetkisine bağla (mükerrer kontrolü kayıt açan kişinin işi). **Doğrulama:** DOĞRULANDI.

## Bulgular — P1

### K03 — P1: `personel-hesap?sifirla=true` bütün personel parolalarını bilinen değere çekiyor

**Yer:** `KimlikUclari.cs:229-238` → `Servisler/KimlikServisi.cs:338-351` → `Gentegre.Veri/Depolar/KullaniciDeposu.cs:225-237`.

Yetki yalnız `personel` Değiştir (İK, başhekim, hastane müdürü…). `sifirla=true` dolu parolaları da kart id'sine çevirir; tek istisna `kod = 'admin'`. `parola_degismeli=1` engel değil: `/parola` sınırlı oturuma açık. Oturumlar kapatılmıyor, log yok. **Senaryo:** İK görevlisi ucu çağırır → yönetici rolündeki kullanıcıya id'siyle girer, parolasını değiştirir.

**Düzeltme:** `sifirla` dalını ayrı aksiyon koduna ve `kullanici` Değiştir'e bağla; tek kişi zorunlu; çağıranın rolünden yüksek/sistem rollerini hariç tut; parolayı boşaltıp kodlu ilk-parola akışına düşür (`KullaniciYonetimUclari` zaten öyle yapıyor); oturumları kapat; logla. **Doğrulama:** DOĞRULANDI.

### K04 — P1: Yönetim uçlarında "hedef daha yetkili" koruması yok

**Yer:** `KullaniciYonetimUclari.cs:40-78` (`/{id}/parola-sifirla`), `:133-170` (`/{id}/durum`, yalnız `id == baglam.KullaniciId` engeli).

`bilgi_islem` (`kullanici.degistir`) admin dahil herkesi pasife alabilir, parolasını boşaltabilir. Zincir (OLASI): personel kartından cep telefonu değiştir → parola sıfırla → ilk-parola kodu saldırgana gider.

**Düzeltme:** Hedefin rol kümesi çağıranınkinden geniş/eşit ise 403; `yonetici` rolü ve `admin` kodu için ayrı yetki; iletişim bilgisi değişiminde kodu eski kanala da bildir. **Doğrulama:** DOĞRULANDI (pasife alma/sıfırlama).

### K05 — P1: Lab uçları portal rollerine başka hastanın istemini açıyor

**Yer:** `LabUclari.cs:634-660` (`GET /lab/basvuru/{belgeId}/istemler`), `LabUclari.Numune.cs:125-145` (`GET /lab/numune/barkod/{barkod}`).

İkisi de yalnız `YetkiIste` + doğrudan `where`; portal rollerinde `lab.gor` ve `lab.numune.gor` var. Barkod `fn_lab_barkod_uret` ile ardışık (YY + 8 haneli sayaç + kontrol hanesi) → tahmin edilebilir; yanıtta hasta adı ve istem no var. Aynı dosyadaki `GET /lab/istem/{id}` kapıdan geçiyor — tutarsızlık.

**Düzeltme:** `erisim.IsteAsync(baglam, "belge"/"lab-istem", …)`; barkod ucunda numuneden istem id'yi okuyup kapıdan geçir. **Doğrulama:** DOĞRULANDI.

### K06 — P1: Teleradyoloji dış kurum portalı başka kurumun isteğini (hasta TCKN dahil) okuyor

**Yer:** `TeleradUclari.cs:30` (grupta filtre yok), `TeleradUclari.Bakanlik.cs:32-60` (`/istek/{id}/bakanlik`), `:199` (`/teslim/{id}/iz`), `:236` (`/gelen/{id}`).

`dis_istem_kurumu` rolünde `teleradyoloji.gor/ekle/degistir = 1`. Uçlar `hastaTckn`, `isteyenHekimTckn`, `accessionNo`, `studyUid`, WADO adresi dönüyor. Radyoloji grubuna eklenen `RadyolojiKayitKapisi` benzeri filtre telerad grubunda yok — B02'nin eksik kalan yarısı.

**Düzeltme:** `/api/telerad` grubuna istek/gelen/teslim kimliklerini bağlı istek üzerinden `KayitErisimi`'ne geçiren filtre. **Doğrulama:** DOĞRULANDI (kod).

### K07 — P1: İSG portalı başka firmanın çalışan sağlık kaydını okuyor

**Yer:** `IsgUclari.cs:83-89` (`/isg/firma/{id}`), `:122-128` (`/isg/calisan/{id}`).

`firma_yetkilisi` rolünde `isg.firma.gor` ve `isg.calisan.gor` var; uçlar `row_to_json(v_isg_calisan)` ile satırın tamamını (TCKN, periyodik muayene) `where id = @p0` ile dönüyor; `PortalKimlik` kullanılmıyor.

**Düzeltme:** `erisim.IsteAsync(baglam, "isg-calisan"/"isg-firma", id)`; portal türü 2 için firma koşulu katalogda yoksa tanımla. **Doğrulama:** DOĞRULANDI.

### K08 — P1: Docker arkasında istemci IP'si okunmuyor — IP sınırları tüm kurumu tek istemci sayıyor

**Yer:** `Program.cs:235-241` (KnownProxies yalnız `Guvenlik:GuvenilenProxyler`, varsayılan boş = loopback), `yayin/yayinla.ps1:276-283` (Production ayarında yok), `yayin/sunucu-guncelle.sh:165-170` (konteyner bridge ağında), `Servisler/ParolaSifirlamaServisi.cs:292-301`.

Konteyner içinde `RemoteIpAddress` docker ağ geçidi (172.x.0.1) olur, loopback değil → ForwardedHeaders XFF'yi yok sayar. İlk-parola/sıfırlama IP eşiği (15 dk'da 20 hata) bütün kurulum için ortak sayaca döner; `giris_denemesi.ip`, `son_giris_ip`, `islem_log.ip`, `oturumlar.buCihaz` anlamsız. Bütünleşme testleri loopback'te koştuğu için fark görünmüyor. **Senaryo:** Saldırgan anonim parola ucuna 20 hatalı istek atar → 15 dk boyunca o kurumda kimse parola sıfırlayamaz; KVKK erişim günlüğünde gerçek istemci yok.

**Düzeltme:** Production ayarına `Guvenlik:GuvenilenProxyler` = docker ağ geçidi (ya da `KnownNetworks` 172.16.0.0/12); `X-Forwarded-Proto` da işlensin; açılışta "proxy arkasında ama güvenilen proxy yok" uyarısı. Sunucuda `select distinct ip from giris_denemesi` ile doğrula. **Doğrulama:** DOĞRULANDI (yapılandırma); çalışma zamanı OLASI.

### K09 — P1: IP tabanlı kurulumlar düz HTTP üzerinde

**Yer:** `yayin/yayinla.ps1:5-6, 277, 357`; `yayin/nginx-ikili.conf`, `nginx-feta.conf`, `nginx-zone.conf`, `nginx-medx.conf`, `nginx-bilim.conf` (TLS yok); TLS yalnız `nginx-gentegreai.conf` alan adı bloklarında.

FETA/ZONE/MEDX/BILIM ve `/genotipai` profilleri `http://46.36.201.170/<yol>/` üzerinden kullanılıyor; JWT, parola, hasta ve finans verisi şifresiz. Üretim CORS listesi de `http://`. Alan adı bloğu da `listen 80`'i kapatmıyor (HTTPS'e zorlama Cloudflare ayarına bırakılmış). Ek etki: `navigator.locks` yalnız güvenli bağlamda var → sekmeler arası tek yenileme bu kurulumlarda çalışmıyor (bkz. K23).

**Düzeltme:** IP sitesine sertifika + 80→443 yönlendirme, HSTS; müşteri adreslerini `https://<kod>.gentegreai.com` ile sınırla. **Doğrulama:** DOĞRULANDI (repo parçaları; sunucudaki ana server bloğu repoda değil).

### K10 — P1: Gizli ayar dosyası ve DB yedekleri sunucuda herkese okunur

**Yer:** `yayin/sunucu-guncelle.sh:154-159` (`appsettings.Gizli.json` yazılıp ardından `chmod -R a+rX "$KOK/api"`), `:138` (`api.onceki` kopyası), `:87-88` (`yedek/` pg_dump çıktıları varsayılan umask), `:165-170` (konteyner root), `yayin/panel-hazirla.sh:56` (ev dizini `o+x`).

`.jwt_imza_anahtari` ve `.db_uygulama_parolasi` 600 ama ikisinin kopyası olan `appsettings.Gizli.json` 644; ev dizini `o+x` olduğu için yolu bilen her yerel süreç (ör. ele geçirilmiş nginx) okur. Hasta verisi ve parola hash'leri içeren dökümler de aynı durumda. Bu betik bu oturumda (B01/B07) yazıldı; hata bize ait.

**Düzeltme:** `docker run --user "$(id -u):$(id -g)"`; Gizli.json ve `yedek/` 600/700; `chmod -R a+rX` yerine yalnız web/; `api.onceki`'yi 700 dizine al. **Doğrulama:** DOĞRULANDI (betik); fiili izinler sunucuda doğrulanmalı.

### K11 — P1: PostgreSQL süper kullanıcı parolası betik varsayılanlarında

**Yer:** `yayin/yayinla.ps1:70` (`-DbParola` varsayılanı; yorum: sunucu parolası yerelle aynı), `db/kur.ps1:35,38`, `db/araclar/goc_uygula.ps1:43`, `goc_uzlastir.ps1:43`, `aktar_ek.ps1`, `xslt_aktar.ps1`; `Gentegre.Api.csproj:14` (`appsettings*.json` publish'e giriyor).

Depoya erişen herkes üretim `postgres` parolasını biliyor; B07 ile getirilen sınırlı rol, süper kullanıcı parolası dolaşımda olduğu sürece boşa çıkar. (`appsettings.json`'un kendisi git'te izlenmiyor — doğrulandı; parola betik varsayılanlarında.)

**Düzeltme:** Sunucuda `ALTER ROLE postgres PASSWORD` ile değiştir; betiklerde varsayılanı kaldır (zorunlu parametre / ortam değişkeni); `appsettings.Development.json`'u publish dışına al. **Doğrulama:** DOĞRULANDI.

### K12 — P1: Belge hattı + bağ güncellemesi ayrı transaction → çift fatura / çift stok düşümü

**Yer:** A–K: `AmeliyathaneUclari.Fatura.cs:253-281, 410-426`; `EczaneUclari.IadeImha.cs:129-184, 322-335`; `Servisler/GelenBelgeAktar.cs:48-68, 155-181`; `IcmalUclari.cs:250-259`; `BiyomedikalUclari.cs:522-533`; `BasvuruIstemUclari.cs:301-305`. L–Z: `SatinalmaUclari.Siparis.cs:206-254`; `RadyolojiUclari.cs:375-430, 437-523, 609-622`; `LabUclari.cs:140-233`; `RadyolojiUclari.SarfVeKontrast.cs:194-208`; `UretimUclari.cs:904-1016`.

On bir yerde aynı desen: bağsız satırlar kilitsiz okunur → `BelgeDeposu.KaydetAsync` kendi bağlantısında commit eder → `update … set belge_id/durum … where id = @p0` ayrı, koşulsuz. Arada hata ya da eşzamanlı istek → aynı kalemler ikinci kez faturalanır, stok ikinci kez düşer, kuruma iki fatura. Ameliyathane'de eşleştirme anahtarı kullanıcı tarafından düzenlenebilen `aciklama`. DB'de koruyucu kısıt yok (`ameliyat_sarf`, `eczane_imha.belge_id`, `kurum_icmal` kontrol edildi). Transaction alan `KaydetAsync(baglanti, islem, …)` overload'ı var; yalnız `StokSayimUclari` kullanıyor.

**Düzeltme:** Belge yazımı ve bağ güncellemesi tek transaction (overload); kaynak satırı `for update`; bağ update'ine eski durum koşulu + etkilenen 0 ise geri al. **Doğrulama:** DOĞRULANDI.

### K13 — P1: Oku-sonra-yaz, koşulsuz UPDATE → para/sayaç/stok çift işlenir

**Yer:** `AvansUclari.cs:242-313` (öde: kasa_islem insert + koşulsuz update), `:335-357`; `UretimUclari.cs:322-351` (başlat, `durum = 2` koşulu yok); `AiUclari.cs:420-465`; `FtrUclari.cs:322-334` (`kalan_hak - 1` her çağrıda); `AmeliyathaneUclari.cs:296-299, 367-371`; `AcilUclari.cs:510-524`; `GozUclari.Goruntuleme.cs:213-231`; `CagriUclari.Akis.cs:127-190` (iki görev + iki SMS); `SatinalmaUclari.Siparis.cs:347-432` (ceza `ceza_islendi` oku-yaz, `Tutar` aralık denetimi yok), `:557-577` (kabul, unique yok); `SterilUclari.Islem.cs:70-101` (sayaç, unique yok); `PatolojiUclari.cs:60-96`; `YatanUclari.Emar.cs:176-221, 252-279`; `Servisler/OnayMotoru.cs:265-330` (basamak kararı: onay ve ret aynı anda).

Durum bellekte okunur, UPDATE `where id = @p0` ile yazılır, etkilenen satır bakılmaz, kilit yok. İyi örnekler kodda var: `AriziUclari`, `BankaHareketUclari:179`, `KonsultasyonUclari`, `MusteriRiskIcmalUclari`.

**Düzeltme:** `update … where id=@p0 and durum=@beklenen` + `n==0 → IsKurali`; ya da başta `select … for update`; bağımlı insert'ler aynı transaction'da ve güncellemeden sonra. **Doğrulama:** DOĞRULANDI (Avans, Üretim, AiUclari, Satınalma, Steril bizzat); OnayMotoru OLASI.

### K14 — P1: Banko kapanış / gün sonu yarışta çift fark fişi; tutanak no `max+1`

**Yer:** `BankoOturumUclari.cs:507-539` (onayla), `:642-674` (gün sonu), `:954-992` (`FarkFisiAsync`), `:1029-1038` (`TutanakNoAsync`).

UPDATE'ler durum koşulsuz; `FarkFisiAsync` her çağrıda yeni `kasa_islem` yazıp `fark_islem_id`'yi koşulsuz ezer → ikinci fiş birincinin bağını alır, ilki sahipsiz kalır. `tutanak_no` üzerinde benzersiz indeks yok (DB'de doğrulandı). Fark fişi `durum = 1` (Planlı) yazılıyor; gün sonu/ekstre `islem_durum = 2` süzdüğü için kasa bakiyesine girmiyor olabilir (niyet OLASI).

**Düzeltme:** Durum koşullu update; fişi yalnız `fark_islem_id is null` iken yaz; tutanak için sequence/advisory lock; fark fişi durumunu netleştir. **Doğrulama:** DOĞRULANDI (çift fiş, tutanak) / OLASI (durum niyeti).

### K15 — P1: Kasa dağıtım / avans mahsup: şube kapsamı yok, satır–belge bağı doğrulanmıyor, log yok

**Yer:** `KasaUclari.cs:359-468` (`/{id}/dagitim`), `:507-567` (`/avans-mahsup`), `:572-607` (`/avans-mahsup/iptal`).

Dosyanın öteki uçları `SubeKontrolAsync` kullanıyor; bu üçü kullanmıyor — herhangi şubenin kasa işlemi id ile dağıtılır, mahsup edilir, mahsubu silinir. Elle dağıtımda `BelgeSatirId`'nin `belgeId`'ye ait olduğu kontrol edilmiyor (tetik `tg_kasa_dagitim_kontrol` de bakmıyor) → tahsilat başka belgenin satırına yazılabilir. `k.durum` okunur ama kullanılmaz. ISLEMLOG yok.

**Düzeltme:** `SubeKontrolAsync`; satır id'lerini `belge_satir.belge_id = @belge` ile süz; `durum = 2` şartı; `for update`; log. **Doğrulama:** DOĞRULANDI.

### K16 — P1: Yazma uçları `Islem.Gor` ile çalışıyor → salt-okuma şubesinde / yalnız görüntüleme yetkisiyle kayıt

**Yer:** `GozUclari.Surec.cs:140-153` (`/akis/{id}/muayene` → muayene + goz_muayene INSERT, muayene no tüketir), `:166-187`; `PatolojiUclari.cs:165, 181` (`ek-{karar}` — ek inceleme onay/ret kararı); `CagriUclari.Akis.cs:53-59, 290-299`; `DisUclari.Lab.cs:188-194`; `EntegrasyonUclari.cs:222-247`; `EnabizMesajUclari.cs:135-163`; `MedulaUclari.cs:103` (müstehaklık → kuyruk + provizyon yazar); `SigortaUclari.cs:169`; `LabUclari.cs:281`; `MuayeneUclari.OzelNot.cs:43`.

`YetkiIste(x, Islem.Gor)` `YazmaIste()` çağırmıyor (`IstekBaglami.cs:110`) — `kullanici_sube.yazma = 0` kuralı atlanır.

**Düzeltme:** `Islem.Ekle/Degistir` ya da `AksiyonIste`; bilinçli istisnada en az `baglam.YazmaIste()`. **Doğrulama:** DOĞRULANDI.

### K17 — P1: Radyoloji konsültasyon cevabı kapsam dışı kaydı kimlikle güncelliyor

**Yer:** `RadyolojiUclari.OnayVeBulgu.cs:302-314`.

`konsultasyonId` sorgu parametresi; `update radyoloji_konsultasyon … where id = @p0` — yol kimliğiyle (`istem_id`) bağ ve `durum = 1` koşulu yok. `RadyolojiKayitKapisi` yalnız yol kimliğine bakar; kapsamdaki bir istem + başka şubenin konsültasyon id'si → başka şubenin görüşü değiştirilir. Dönmüş kayıt da ezilir.

**Düzeltme:** `where id=@p0 and istem_id=@istem and durum=1`, 0 satır → 404. **Doğrulama:** DOĞRULANDI.

### K18 — P1: eMAR doz uygulama: şube saati ile UTC karşılaştırılıyor → zamanında doz "gecikmiş"

**Yer:** `YatanUclari.Emar.cs:192-201`; `Gentegre.Cekirdek/Saat.cs:66` (`Simdi` = şube duvar saati, Kind=Unspecified); istemci `DozUygulamaModali.tsx:74` (`uygulananZaman` göndermiyor).

`zaman = istek.UygulananZaman ?? Saat.Simdi`; `doz.planlanan` timestamptz UTC okunur; `zaman > planlanan.AddMinutes(30)` → İstanbul'da her doz 3 saat "geç" → 400 "gecikme sebebi yazılmalı". Hemşire ya uyduruk sebep yazar ya doz kaydedilemez.

**Düzeltme:** `Saat.An` (UTC) kullan ya da gecikmeyi SQL'de hesapla (`/order/{id}/ozet` zaten öyle). Aynı sınıf karışıklık için `Saat.Simdi`'nin C# tarafında timestamptz ile karşılaştırıldığı yerler taranmalı. **Doğrulama:** DOĞRULANDI.

### K19 — P1: Filtre/sıralama beyaz listesi "görünür kolon" değil "tüm katalog" — gizli alan sızıntısı

**Yer:** `Gentegre.Cekirdek/Katalog/SorguUretici.cs:351` (`Kosul`), `:453` (`Sirala`); `Uclar/ListeUclari.cs:33-46, 238-244` (yalnız SELECT kolonları `AlanOkunur` ile süzülüyor).

Alan yetkisi SELECT'e uygulanıyor; WHERE/ORDER BY tam katalogdan çözülüyor. `stok.maliyet` gizli olan kullanıcı `{"filtre":{"alan":"maliyet","op":"buyuk","deger":1000}}` ile ikili arama yapar, `sirala` ile sıralı listeyi okur; sayım/toplam aynı koşulu taşıdığı için değer kuruşa kadar çıkarılır. Döküm yolu doğru (`DokumDogrulayici.cs:23-26`).

**Düzeltme:** `SorguUretici`'ye görünür kolon kümesini ver; `Kosul`/`Sirala`/`Toplam` o kümeden çözsün, görünmeyen alan → 400. **Doğrulama:** DOĞRULANDI (kod; dev DB'de alan yetki satırı 0 olduğundan canlı denenmedi).

### K20 — P1: Göç defteri 51 dosya geride; 1192 dev'de hiç uygulanmamış

**Yer:** `public.goc_gecmisi` (1.134 kayıt) ↔ `db/*.sql` (1.184 dosya); `db/1192_aktarim_siparis.sql`.

Defterde olmayan 51 dosya: 1098–1140 bloğunun tamamı + 1152, 1153, 1155, 1157, 1164, 1167, 1168, 1192. Ellisi elle (`psql -f`) uygulanmış (nesneler DB'de var); **1192 hiç uygulanmamış** (`stg.siparis`, `fn_aktar_ek_siparis` yok). `goc_uygula.ps1` çalıştırılırsa 50 dosyayı yeniden koşturur. Dev'de Delphi sipariş aktarımı çalışmaz.

**Düzeltme:** 1192'yi uygula; 50 dosya için `goc_uzlastir.ps1` ile deftere işle (OKUBENI'nin 13.10 yöntemi). **Doğrulama:** DOĞRULANDI (comm + to_regclass).

### K21 — P1: Muayene Özeti "Kaydet" sürümsüz gidiyor — sunucu her zaman 400 döner

**Yer:** `web/src/bilesenler/MuayeneOzetiModal.tsx:65`; `KartUclari.cs:237-239`.

`api.kartGuncelle('muayene', id, { kart: { bulguOzet } })` — `surum` yok; sunucu sürümsüz güncellemeyi reddediyor. Özet hiç kaydedilemiyor. Modal kartı okumadığı için elinde sürüm yok.

**Düzeltme:** Açılışta `kartOku` ile sürümü al, `{ surum, kart }` gönder. **Doğrulama:** DOĞRULANDI.

### K22 — P1: Boş kritik bulgu bildirimi onay kapısını geçiyor

**Yer:** `web/src/sayfalar/RadyolojiRapor.tsx:450-456`; `RadyolojiUclari.OnayVeBulgu.cs:170-197` (`istek.Bulgu ?? ""`, `BildirilenAd ?? ""`); `db/809_bakanlik_rapor_parcalari.sql:206-213` (`count(*) > 0`).

İstemci doğrulamıyor, sunucu boş satır yazıyor, onay fonksiyonu yalnız satır var mı diye bakıyor. "Kime, hangi yolla, ne zaman haber verildi" kaydı boş kalır; rapor onaylanır.

**Düzeltme:** Sunucuda `Bulgu` ve `BildirilenAd` boşsa 400; fonksiyonda `bildirilen_ad <> ''`. **Doğrulama:** DOĞRULANDI.

### K23 — P1: Sekmeler arası tek yenileme HTTP kurulumlarda devre dışı; refresh reddinde ekran ölü kalıyor

**Yer:** `web/src/api/cekirdek.ts:66-92` (`navigator.locks` yalnız güvenli bağlamda), `:114` (`oturum.temizle(); return false` — kimseye haber yok), `kimlik/OturumBaglami.tsx:113-117`.

IP/HTTP kurulumlarda iki sekme aynı anda 401 alırsa ikisi de aynı refresh ile `/kimlik/yenile`'ye gider → sunucu tekrar kullanım sayar, aile iptal, iki sekme de düşer. Refresh reddedildiğinde token'lar silinir ama kabuk açık kalır; her istek 401; kullanıcı F5'e kadar ölü ekranda, yazdığı kart verisi gider.

**Düzeltme:** `localStorage` tabanlı kilit + `storage` olayı yedeği (K09 çözülse de); temizle sonrası `OTURUM_TAZELE_OLAYI` yayınla → giriş ekranı + uyarı. **Doğrulama:** DOĞRULANDI.

### K24 — P1: Alerji listesi okunamazsa band yeşil "Alerji: yok" diyor

**Yer:** `web/src/bilesenler/MuayeneSekmesiz.tsx:31-36` (`catch { return [] }`), `:149`; `MuayeneBaglamSeridi.tsx:51-57, 191-193`; `recete/ReceteKarti.tsx:110-111`.

`hasta-alerji` isteği başarısız olunca (ağ, 403, 500) boş dizi döner; band olumlu rozet basar, reçete kartında rozetler sessizce kaybolur. "Bilinmiyor" ile "yok" ayrılmıyor; hekim penisilin yazabilir. Sunucu tarafı reçete uyarısı kısmen telafi eder.

**Düzeltme:** Hata durumunu `null` döndür; bandda "Alerji: ?" uyarı rozeti + yeniden dene; yeşil yalnız başarılı boş yanıtta. **Doğrulama:** DOĞRULANDI (kod).

### K25 — P1: Cihaz klasör taraması `.alindi` dosyalarını yeniden okuyor

**Yer:** `Servisler/CihazServisi.cs:210, 245`.

`Directory.EnumerateFiles(c.KlasorYolu).Take(200)` uzantı süzgeci yok; arşiv klasörü tanımsız cihazda işlenen dosya `.alindi` olarak yerinde kalır → sonraki tur aynı dosyayı okur, `.alindi.alindi` yapar. Kontrol numarası (MSH-10) üretmeyen cihazda aynı sonuç her turda yeniden kaydedilir; `Take(200)` dolunca yeni dosya sıraya giremez.

**Düzeltme:** `.alindi` ile bitenleri süz; tercihen `alindi/` alt klasörüne taşı. **Doğrulama:** DOĞRULANDI.

### K26 — P1: Kurum içi özel uçların çoğunda hâlâ kayıt kapsamı yok (B02'nin yalnız radyolojide kapanmış hâli)

**Yer (okuma):** `MuayeneUclari.Sekme.cs:72-88`, `MuayeneUclari.Tani.cs:23-60`, `MuayeneUclari.OlcumGecmisi.cs:146-153`, `MuayeneUclari.Yz.cs`, `MuayeneUclari.OzelNot.cs`, `LabUclari.Mikrobiyoloji.cs:40-47, 191`, `LabUclari.Sonuc.cs:41-98`, `LabUclari.DisLaboratuvar.cs:98`, `YatanUclari.Izlem.cs:205-258, 263, 283-364`, `EntegrasyonUclari.cs` (7 uç), `EFaturaUclari.cs:201-212`. **Yer (yazma):** `EczaneUclari.cs:189-593` ve `.IadeImha.cs`; `GozUclari.*` (Akis.cs:60-90 `/akis/cagir` id'siz çağrıda tüm şubelerin bekleyenini çağırır; Surec, Goruntuleme, Gozluk, Cizim, Dikte, Muayene); `CagriUclari.*`; `AcilUclari.cs:305-662`; `AmeliyathaneUclari.cs:267-803`; `BelgeUclari.cs:354-397 /dagit, 503-525 /rezerve, 544-570 /termin` (`BelgeYazmaIsteAsync` kapısından geçmiyor); `BankaHareketUclari.cs:175-197`; `BasvuruIstemUclari.cs:175-315`; `BelgeTalebiUclari.cs:275-456`; `BiyomedikalUclari.cs`; `BzbhUclari.cs`; `GelenBelgeUclari` `/yanit`, `/aktar`, `/ubl`; `FtrUclari`; `FormUclari.cs:148-349`; `HastaBorcTakipUclari.cs:215-266`; `CocukIzlemUclari.cs:89`; `ReceteUclari.cs:201-270`.

Yaklaşık 40 dosyada `YetkiIste` + `where id = @p0`. Aynı dosyaların GET listeleri şube süzerken yazma uçları süzmüyor. B şubesi eczacısı A şubesinin iade/imha kaydını ilerletir; kapsamı daraltılmış kullanıcı kapsam dışı hastanın tanısını siler. İzlenecek örnekler: `BankoOturumUclari` (`sube_id = @p1` her yazmada), `KasaUclari.SubeKontrolAsync`, `CalismaPlaniUclari.Kart` (`KayitErisimi.GorunurAsync`), `RadyolojiKayitKapisi`.

**Düzeltme:** Grup başına `IEndpointFilter` (muayene → `muayene`, lab kültür/sonuç → satırdan `lab-istem`, yatış → `yatis`, eczane/göz/acil/ameliyathane kendi kaynakları); `BelgeUclari`'nin üç ucunda `BelgeYazmaIsteAsync`. **Doğrulama:** Muayene/Lab/Yatan/Eczane/Göz/Belge DOĞRULANDI; servis destekli uçlar OLASI.

## Bulgular — P2

### K27 — P2: SGK Ek-4/A yükleme adresi sunucu tarafında kısıtsız GET (SSRF)
**Yer:** `KatalogUclari.cs:217-231` → `Servisler/SgkIlacListesi.cs:55-60`. `istek.Adres` şema/host kısıtı olmadan çekiliyor; `katalog` Değiştir yetkisiyle iç ağa istek attırılır (`http://169.254.169.254/…`, `http://localhost:5432`). Aynı dosyada ICD/ilaç yüklemeleri transaction'sız ve logsuz. **Düzeltme:** `https://*.sgk.gov.tr` allow-list, yönlendirme kapalı, özel IP reddi. **DOĞRULANDI.**

### K28 — P2: Entegrasyon hesap şifreleri DB'de düz metin
**Yer:** `entegrasyon_hesap.sifre text`; `EBelgeIstemcisi.cs:44-56`, `EnabizGonderimi.cs:413-414`, `AsmedSaglayici.cs:73-80`, `BildirimGondericileri.cs:122`; `fn_ebelge_hesap` ham şifre döner. e-Belge, e-Nabız, SMS, SMTP, sigorta, Garanti kimlikleri yedekte/salt-okur erişimde açık. **Düzeltme:** Sunucu anahtarıyla simetrik şifreleme, tek çözücü. **DOĞRULANDI.**

### K29 — P2: Ortak panel girişi access+refresh token'ı DB'de düz metin saklıyor
**Yer:** `KimlikUclari.cs:24-46`, `db/1190_giris_kodu.sql`. `giris_kodu.yanit` jsonb'de ham 30 günlük refresh; kullanılmayan kodun oturumu açık kalır; DB yedeği = geçerli oturum. **Düzeltme:** Token'ı `/kullan` anında üret ya da kodla türetilmiş anahtarla şifrele; kullanılmayan kodun ailesini süre sonunda iptal et. **DOĞRULANDI.**

### K30 — P2: Girişte hesap varlığı sızıyor; `/giris` için hız sınırı yok; 5 hata kilit = kilitleme DoS
**Yer:** `KimlikServisi.cs:53-98`; `nginx-gentegreai.conf:82` (limit_req yalnız panel); `Program.cs` (AddRateLimiter yok). Pasif/kilitli/ILK_PAROLA mesajları parola doğrulanmadan dönüyor; `EsnekBulAsync` ad soyad/cep/e-posta kabul ediyor. Hesap kilidi tek savunma → personel adlarıyla 5 denemede herkes kilitlenir (K08 ile IP sınırı zaten çalışmıyor). **Düzeltme:** Tek genel mesaj; nginx `limit_req` + ASP.NET `RateLimiter`; kilit yerine artan gecikme. **DOĞRULANDI.**

### K31 — P2: Diş ücret satırları belge toplamını `fn_belge_diptoplam` dışında hesaplıyor
**Yer:** `DisUclari.Plan.cs:383-408`, `DisUclari.Seans.cs:178-200`. KDV ayrıştırması inline, `belge.matrah/genel_toplam` `sum(tutar)` ile doğrudan yazılıyor — kural ihlali, iki doğruluk kaynağı. Ayrıca `UretimUclari.cs:527-602` maliyet kapanışında `belge_satir` doğrudan güncelleniyor, dip toplam tazelenmiyor. **Düzeltme:** `BelgeDeposu.ToplamlariYazAsync`/`fn_belge_diptoplam`. **DOĞRULANDI.**

### K32 — P2: İstemciden gelen şube/hedef id doğrulanmadan yazılıyor
**Yer:** `IskontoOnayUclari.cs:93-134` (belgeId kapsamsız, `sube_id = baglam.SubeId` belgenin değil); `KurumProfilUclari.cs:105-152` (`istek.SubeId` `baglam.Subeler` ile karşılaştırılmıyor → yetkisiz şubenin ürün modu değiştirilir); `EnabizGunSonuUclari.cs:187, 207`; `BankoOturumUclari.cs:657` (`TeslimAlanId` keyfi). **Düzeltme:** `baglam.Subeler.Any(s => s.Id == istek.SubeId)` kapısı. **DOĞRULANDI.**

### K33 — P2: Silme/değişiklik logu eksik ya da kurala aykırı
**Yer:** Log hiç yok: `UretimUclari` (13 yazma ucu), `ReceteUclari`, `MuayeneUclari.Tani.cs:47-63` (yorum "log tek yoldan" der), `GebeIzlemUclari` (LogDeposu enjekte edilmemiş), `KodListeUclari.cs:60-138`, `AsiUclari.cs:76-188`, `EFaturaUclari.cs:124-171`, `AiKontorUclari.cs:217-244`, `BasvuruIstemUclari.cs:175-222`, `IceriAlmaUclari.cs:249-290`, `KatalogUclari`, `IcmalUclari.cs:161-262`, `GozUclari.Dikte.cs:143-158`, `KasaUclari` dağıtım/mahsup, `DokumanDeposu.cs:325-350` (doküman silme), istem DELETE'leri (`RadyolojiUclari.cs:310-336`, `LabUclari.cs:603-630`), `PrimUclari`, `MesajUclari`. DELETE'ten sonra / yalnız id: `MasrafBeyaniUclari.cs:160-167`, `TeknikServisUclari.cs:755-760`, `StokSayimUclari.cs:336-338`, `LabUclari.Grafik.cs:147-149`, `FtrUclari.cs:137-144`, `DisUclari.SeansKart.cs:194-225`, `AriziUclari.Takip.cs:309-334`. Log ayrı bağlantıda (transaction dışı): `EczaneUclari.IadeImha.cs:236, 359`, `FtrUclari.cs:134, 365`, `FormUclari`, `FiyatListesiUclari.cs:96, 347, 714`, `AmeliyathaneUclari.Fatura.cs:283, 450`. **Düzeltme:** Kural: `LogIslemi.Sil` tam satırla DELETE'ten önce, `YazAsync(baglanti, islem, …)` ile aynı transaction'da (PlanliGider `__detaylar` deseni). **DOĞRULANDI.**

### K34 — P2: Kilitli/tamamlanmış kayda yazma
**Yer:** `MuayeneUclari.Sekme.cs:28-63, 201-266, 274-303` ve `Tani.cs:125-193` (durum 3 muayeneye tanı/bulgu; yalnız `vucut-semasi` kontrol ediyor — e-Nabız 103 paketi sonrası kayıt değişir); `RadyolojiUclari.OnayVeBulgu.cs:145-167` (addendum: kaynak onaylı mı bakılmıyor, addendum'un addendum'u, tx yok); `UretimUclari` rezerve/fire iptal emirde; `FtrUclari.cs:137-144` kapalı program. **Düzeltme:** Ortak `…AcikIsteAsync` (for update + durum kapısı). **DOĞRULANDI.**

### K35 — P2: Reçete imzası iki uçta farklı davranıyor
**Yer:** `ReceteUclari.cs:344-398` (FOR UPDATE, `hasta_ilac` yazar, hash yok) vs `MedulaUclari.Recete.cs:31-55` (kilitsiz, hash yazar, `hasta_ilac` yazmaz). **Düzeltme:** Tek imza yolu. **DOĞRULANDI.**

### K36 — P2: Çok adımlı yazmalar transaction'sız
**Yer:** `CagriUclari.Akis` (/baslat, /kapat, /kalite), `CagriUclari.Giden`, `DisUclari.Seans` (`BasvuruAcAsync islem=null`), `DisUclari.Akis`, `DokumanYonetimUclari.cs:81-125, 239-258, 290-306`, `GebeIzlemUclari:202-300`, `HastaBorcTakipUclari.cs:194-232`, `IsgUclari.cs:257-265`, `KullaniciYonetimUclari.cs:53-71, 133-171`, `KurumProfilUclari`, `KatalogUclari`, `EntegrasyonUclari.cs:296-306` (SKRS: delete + sayfa insert), `BelgeUclari /dagit:372-392`, `FormUclari /aktar:234-258`, `SterilUclari.Islem.cs` (tüm akışlar), `PatolojiUclari.cs:60-96`, `RadyolojiUclari.Cihaz.cs:335-366`. **DOĞRULANDI.**

### K37 — P2: Arka plan kuyrukları kilitsiz / kurtarma eksik
**Yer:** `MedulaServisi.cs:134-146`, `EnabizMesajServisi.cs:113-121`, `GozCihazServisi.cs:52-60`, `TeleradTeslimServisi.cs:96-101` (select … limit kilitsiz; zamanlı iş + ekranın "şimdi gönder"i aynı satırı iki kez işler — gerçek Medula'da çift provizyon); `BildirimDeposu.cs:168-178` + `BildirimIscisi.cs:50-62` (askıda kalan kurtarma `ekleme_tarihi`ne bakar, yalnız açılışta → iki örnekte çift SMS); `HatirlatmaIscisi.cs:41-96` (kilitli işlem içinde `KuyrugaEkleAsync` ayrı bağlantıyla autocommit); `ZamanliIsIscisi.cs:376-425` (takılı `calisiyor=1` yalnız açılışta serbest; yorum "6 saat" der). Doğru örnekler: `fn_enabiz_siradakiler`, `BildirimDeposu.SiradakileriAlAsync`. **Düzeltme:** `update … where id in (select … for update skip locked) returning`; `gonderim_bas` kolonu; kurtarmayı `TurAsync`'e taşı. **DOĞRULANDI/OLASI.**

### K38 — P2: MLLP dinleyicileri: sınırsız tampon, zaman aşımı ve IP süzgeci yok
**Yer:** `CihazDinleyici.cs:92-121`, `TeleradOruDinleyici.cs:107-137`. Çerçeve sonu gelmeden `biriken` sınırsız büyür (O(n²) tarama), `ReadAsync` süre sınırı yok, bağlantı sayısı sınırsız. Ağdaki herhangi bir istemci API sürecini düşürebilir (lab sonuçları da alınamaz). **Düzeltme:** Azami çerçeve (4 MB), boşta zaman aşımı, izinli IP listesi. **DOĞRULANDI.**

### K39 — P2: Detay yazımında salt-okunur alan sessizce yutuluyor; zorunlu alan yalnız INSERT'te
**Yer:** `KartDeposu.Detay.cs:199` (`continue`, `AlanYazilir` yok); `KartUclari.cs:707` (`if (yeni)` zorunlu denetimi — PUT ile `null` göndererek boşaltılabilir). §3.2 "sessiz yoksayma yok" ve §8 "yetkisiz alan yazmada 403" ihlali. **DOĞRULANDI / OLASI.**

### K40 — P2: `BelgeHesap` alan aralığı denetlemiyor
**Yer:** `BelgeHesap.cs:30-38`, `BelgeDeposu.Yazma.cs:303-352`; `belge_satir` CHECK'lerde yok. `iskonto > 100` → negatif tutar; negatif adet "iade" gibi geçer; `fn_belge_diptoplam` toplar. **Düzeltme:** `BelgeHesap.Dogrula` + CHECK `iskonto between 0 and 100`. **OLASI.**

### K41 — P2: Tarih üst sınırı yalnız `arasinda`+`tarih` tipinde gün sonuna uzatılıyor
**Yer:** `SorguUretici.cs:416-418, 433-436`; `web/src/bilesenler/gridSorgu.ts:49-50` (tek uç → `kucukEsit`). Yalnız bitiş girilince son günün hareketleri, sayım ve dip toplam eksik; `zaman` tipinde `arasinda` bile +1 gün almıyor. **DOĞRULANDI.**

### K42 — P2: `kullanici_kapsam` (YETKIALANI) yalnız 13 kaynakta; hasta/klinik kaynaklarda yok
**Yer:** `KaynakKatalogu.Cari.cs:946-962` (`hasta`: KapsamKolonu yok), `SorguUretici.cs:313` (kolon yoksa kapsam sessizce uygulanmaz). 310 kaynaktan hasta verisi taşıyıp ne `KapsamKolonu` ne `PortalKosullari` olan ~60 kaynak (muayene, recete, hasta-alerji/ilac/kronik — bunlarda `SubeKolonu` da yok —, yatan*, acil*, goz*, dis*, ftr*, gebelik*, medula*, patoloji*, radyoloji-kritik/konsultasyon/teslim, onam, enabiz-paket). Portal kuralı olmayan kaynak kapalı (iyi); kapsam kuralı "varsa uygula" (kötü). **Düzeltme:** Hasta taşıyan kaynaklara `KapsamKolonu`; kapsam tanımlıyken kolonu olmayan hasta kaynağını `false`a düşür. **OLASI (dev'de kapsam 0 satır).**

### K43 — P2: `hesap_yetki` zaman kolonları saat dilimsiz `timestamp` — 1097 kuralından sapma
**Yer:** `db/1161_kasa_v3.sql:44`; DB'deki tek iki `timestamp` kolonu bunlar (1.802 timestamptz'ye karşı). API havuzu `Timezone=<şube dilimi>` (`VeriKaynagi.cs:34`) → API'den yerel saat, psql/göçten UTC yazılır. **Düzeltme:** Yeni göçte `timestamptz`'ye çevir (1097 kalıbı). **DOĞRULANDI.**

### K44 — P2: 1197 istisnalı cinsiyet gerekçe yolunda YAŞ kuralı da atlanıyor
**Yer:** `db/1197_hizmet_cinsiyet_istisna.sql:104, 126` (`return new` fn çağrılmadan). `fn_hizmet_uygunluk` cinsiyet VE yaş denetler; kısa devre ikisini birden kapatıyor. Bu göç bu oturumda yazıldı; hata bize ait. **Düzeltme:** İstisna yalnız cinsiyet dalını sustursun (`p_cinsiyet_atla`). **DOĞRULANDI.**

### K45 — P2: `GUNCEL.md` güncel değil
**Yer:** `db/GUNCEL.md` (26.10) vs `1197` (dört yeniden tanım: `fn_hizmet_uygunluk`, `tg_belge_satir_uygunluk`, `tg_radyoloji_istem_uygunluk`, `v_hizmet_lookup`). **Düzeltme:** `araclar/guncel_indeks.ps1`. **DOĞRULANDI.**

### K46 — P2: FK'sız referans kolonları ve indekssiz FK'lar
**Yer:** 651 `_id` kolonu FK'sız (`acil_basvuru.sube_id`, `muayene.sube_id/personel_id`, `recete.sube_id/hekim_id`, `yatis.sube_id`, `enabiz_paket.hasta_id`, `belge_satir.taraf_id`, `oturum.sube_id`…); 663 FK kolonunda öncü indeks yok (`ilac.stok_id` 23k satır, `rol_yetki.yetki_id` 9k, `oturum.onceki_oturum_id` 6k, `*.sube_id`). Çekirdek tablolar indeksli. **Düzeltme:** `not valid` FK + ayrı `validate`; `sube_id` indeksleri. **DOĞRULANDI (sayım).**

### K47 — P2: `belge_satir` üzerinde 14 satır tetiği
Satır başına 2–3 ek sorgu; 500 satırlık aktarımda 7.000+ tetik çağrısı. **Düzeltme:** `WHEN (old.x is distinct from new.x)` koşulları. **OLASI (süre ölçülmedi).**

### K48 — P2: Nginx uygulama bloklarında güvenlik başlığı yok
**Yer:** `nginx-gentegreai.conf:101-132`, `nginx-ikili.conf`, `nginx-feta.conf`, profiller. `X-Frame-Options`, `nosniff`, `Referrer-Policy`, CSP, HSTS yok (panelde kısmen var). **DOĞRULANDI.**

### K49 — P2: Yayın geri alma yolu `set -e` ile atlanabilir; web sağlığı karara bağlı değil
**Yer:** `sunucu-guncelle.sh:32, 175, 183-198, 211-212`. `docker restart` hatası betiği düşürür; `api/` değişmiş, geri alma bloğuna ulaşılmaz. Web paketi bozuksa yayın "TAMAM" biter. Yeni şema açan göçte uygulama rolü erişemez → 500, ama sağlık kontrolü (401) geçer. **OLASI.**

### K50 — P2: Portal daveti parola politikasını ve şube atamasını atlıyor
**Yer:** `PortalDavetUclari.cs:112-114` (`< 6`; politika 8), `:188-192` (şube yoksa sabit 1). **DOĞRULANDI.**

### K51 — P2: GarantiOrnek kimliksiz banka taklidi demo/eğitim ortamında gerçek VKN/IBAN döner
**Yer:** `GarantiOrnekUclari.cs:41-55, 117-151`. `genel.ortam in (demo, egitim)` ile açık; jeton ucu her kimliği kabul eder; gerçek `taraf.vkno`, `taraf_banka.iban`, açık `belge_no` döner. **Düzeltme:** Yalnız Development + kurgu veri. **DOĞRULANDI (mekanizma) / OLASI (etki).**

### K52 — P2: Açık form doğrulama sayacı yarışla aşılır; hasta borç SMS kuyruğu atomik değil
**Yer:** `FormUclari.cs:395-407` (`deneme + 1` bellekte; doğum yılı boşsa atlanır; sabit zamanlı karşılaştırma yok); `HastaBorcTakipUclari.cs:194-209, 227-232`. **DOĞRULANDI.**

### K53 — P2: Web: liste/kart yüklemesinde yarış; ekrana özel zorunluluk yalnız istemcide; yoklama yükü
**Yer:** `grid/useListeVerisi.ts:89-112`, `GenForm.tsx:546-693`, `RadyolojiRapor.tsx:173-225` (iptal/sıra yok → eski yanıt yeniyi ezer; hızlı tetkik geçişinde hasta A'nın metni hasta B'nin ekranına); `kartDogrulama.ts:16-18, 49-54`, `Liste.tsx:1494`, `ListeKarti.tsx:724, 733, 1565` (zorunluluk sunucuda yok); `useTaleplerimOzeti.ts` (20 sn × 4–5 istek), `Mesajlar.tsx` (8 sn), `CagriOperator.tsx` (5 sn) — `document.hidden` yok, hata `catch {}`, geri çekilme yok. **DOĞRULANDI.**

### K54 — P2: Web: `htmlTemizle` kara liste + aynı köken yazdırma penceresi
**Yer:** `bilesenler/htmlGuvenlik.ts:19-34`; `ebelgeIslem.ts`, `efaturaIslem.ts`. DOMParser→`outerHTML` yeniden serileştirme mXSS vektörlerine açık; kaçan tek payload `localStorage`'daki refresh token'ı alır. Bu dosya bu oturumda (B03) yazıldı. **Düzeltme:** `<iframe sandbox srcdoc>` (opak köken) ya da DOMPurify. **OLASI (yapısal).**

### K55 — P2: Web: radyoloji/İK/diş ekranlarında iş kuralı ve atomiklik sorunları
**Yer:** `RadyolojiRapor.tsx:402-408, 442-448` ("Onayla ve İmzala" onay sorusu ve çift-tık koruması yok), `:734-735` (şablon seçimi `guvenli` yok, `''` → şablon 0 → 404); `ik/MasrafKarti.tsx:197-227` (kayıt dört ayrı istek, yarım kalınca ikinci Kaydet hata verir); `dis/DisSeansKarti.tsx:161, 218, 343` (seans ücreti istemcide); `ik/AvansKarti.tsx:119-128` ve `IzinTalepKarti.tsx:264-269` (kesinti planı / kalan bakiye istemci kopyası); `belgeKaydet.ts:135-243` (15+ iş kuralı istemcide, sunucudan ayrışmış); `BelgeKarti.tsx:911-923` ve `IskontoTalepModali.tsx:59-100` (önizleme toplamı açık borç/iskonto kararına giriyor). **DOĞRULANDI/OLASI.**

### K56 — P2: Testler paylaşılan sabit veriye bağlı; duman testi sabit beklemeli
**Yer:** `AkilciIstemTestleri.cs:25,49`, `SterilTestleri.cs:23-33`, `BaglamsalYardimTestleri.cs:28`, `DisKurumBasvurusuTestleri.cs:28`, `PaketUcretSatiriTestleri.cs:32`, `ModelTestleri.cs:47`, `OneriTestleri.cs:29`, `RehberTestleri.cs:26`, `MuayeneSablonYetkiTestleri.cs:25` (`sube_id = 1`, kullanıcı 1); `web/duman/menu.duman.ts:62-70` (7 sabit `waitForTimeout`, admin ile koşar). **DOĞRULANDI.**

### K57 — P2: Üretim modülü: maliyet kapanışı tekrarlanabilir, hiç log yok
**Yer:** `UretimUclari.cs:527-602` (`uretim_maliyet(emir_id)` unique yok), tüm dosya (`LogDeposu` 0). **DOĞRULANDI.**

### K58 — P2: Satınalma kabul/ceza ve sterilizasyon sayacı yarışı
**Yer:** `SatinalmaUclari.Siparis.cs:557-577, 347-432`; `SterilUclari.Islem.cs:70-101`. Benzersiz kısıt yokluğu DB'de doğrulandı. (K13'ün özel hâlleri; ayrı iş kalemi olarak listelendi.) **DOĞRULANDI.**

### K59 — P2: Yatan izlem kapsam yok; doz atla/uygula kilitsiz
**Yer:** `YatanUclari.Izlem.cs:205-258, 283-364` (`yatisId` gövdeden); `YatanUclari.Emar.cs:176-221, 252-279`. **DOĞRULANDI.**

## Bulgular — P3

| # | Yer | Sorun | Doğrulama |
|---|---|---|---|
| K60 | `CagriUclari.Webhook.cs:17-28, 60-66` | Santral anahtarı query string'de (erişim loglarına düşer); `dis_ref` araması şube süzgeçsiz; `kayit_url` doğrulanmadan saklanıyor | DOĞRULANDI |
| K61 | `web/src/api/cekirdek.ts:42-56`; DB `guvenlik.jwt_dakika = 480` | Token'lar `localStorage`'da, access 8 saat; CSP yok | DOĞRULANDI |
| K62 | `Gentegre.Veri/VeriHatasi.cs`; `MernisUclari.cs:82`, `CariVknUclari.cs:161`, `MedulaUclari.Kuyruk.cs:144` + 4 yer | Kısıt adları / dış servis istisna metinleri istemciye ham gidiyor | DOĞRULANDI |
| K63 | `KayitErisimi.cs:36` | `SabitKosul` düşürülüyor — `hasta` kapısında `t.grup = 101` kalkar; `banko-oturum` "kendi kaydı" kuralı kayıt kapısında yok | OLASI |
| K64 | `SorguUretici.cs:454, 137-141`; `Sozlesme/Liste.cs:10` | Bilinmeyen `sirala`/`toplam` sessiz düşer; `istek.Grup` hiç kullanılmıyor | DOĞRULANDI |
| K65 | `SorguUretici.cs:398-407, 337-347` | `icinde` dizisi / yaprak sayısı sınırsız → 65.535 parametre → 500 + `hata_log`'a tam SQL | OLASI |
| K66 | `DegerCevirici.cs:192-196` | `kod` tipinde sayıya çevrilemeyen metin → 22P02 → 500 | OLASI |
| K67 | `RandevuUclari.Seri.cs:71, 100` | DB'den okunan `dilim` tırnak temizlenerek enterpolasyon (parametre tercih edilmeli) | DOĞRULANDI |
| K68 | `BankoOturumUclari.cs:1029`, `GozUclari.Cizim:218`, `GozUclari.Surec:125`, `DisUclari.Plan:120/390`, `DisUclari.Seans:184`, `KodListeUclari:78` | `max(…)+1` sayaç kilitsiz | DOĞRULANDI |
| K69 | `KasaGunSonuUclari.cs:191-238, 289-291`, `GozUclari.*`, `AktarimUclari:186`, `fn_kasa_gun_kilidi`; `AmeliyathaneUclari:167`, `KaliteIcmalUclari:130-181` | Sabit `'Europe/Istanbul'` ve `ToLocalTime()` — şube dilimi kuralı ihlali | DOĞRULANDI |
| K70 | `EBelgeGelen.cs:101-110` | Tutar metni her zaman TR biçim sayılıyor (`"1234.50"` → 123450) | OLASI |
| K71 | `EBelgeGelen.cs:295-301`, `TitckIlacGuncelleme.cs:56,92,202,281` | Zip/XLSX okumada boyut sınırı yok | OLASI |
| K72 | `GelenBelgeAktar.cs:191-230` | Tedarikçi kartı select-sonra-insert, benzersiz kısıt yok → çift cari | OLASI |
| K73 | `EnabizGonderimi.cs:530-536` | `OperationCanceledException` "BAGLANTI" hatası sayılıp `deneme+1` | DOĞRULANDI |
| K74 | `LogDeposu.cs:100-109` | `DateOnly`/`DateTimeOffset` biçimi `DateTime`'dan farklı | OLASI |
| K75 | `ModelSaglayici.cs:225-233, 259`; `YzTaniOnerisi.cs:103-128` | Klinik serbest metin bulut sağlayıcıya gidebilir; kod kapısı yok (anonimleştirme iyi) | OLASI |
| K76 | `RadyolojiUclari.OnayVeBulgu.cs:390-396` | Hatırlatma istem bazlı kapanıyor — addendum gönderimi ana raporun bildirimini de kapatır | OLASI |
| K77 | `RadyolojiUclari.Cihaz.cs:335-366` | `/kapatma` tx/log yok; `/kapat` aynı işi doğru yapıyor — biri kaldırılmalı | DOĞRULANDI |
| K78 | `ebelge_seri`, `numara_sablonu`, `taraf_kullanici` | Çift `degistirme_tarihi` tetiği; `stok_barkod_yedek_145`'te tetik kalmış | DOĞRULANDI |
| K79 | 14 tetik fonksiyonu | `errcode`'suz `raise exception` (P0001) — API iş kuralı/iç hata ayrımı tutarsız | DOĞRULANDI |
| K80 | `stok_lot_durum_islenen.tek_satir` | Gerçek tabloda tek `boolean` kolon (kural: smallint) | DOĞRULANDI |
| K81 | 1150–1168, 1198, 1199, 1200 | `\set ON_ERROR_STOP on` başlığı yok (elle `psql -f`'de sessiz geri alma) | DOĞRULANDI |
| K82 | 91 `_yedek_*` tablosu, 57 MB | Saklama politikası yok; uygulama rolüne açık | DOĞRULANDI |
| K83 | `fn_aktarim_esitle` | Kolon adları `quote_ident`'siz (girdi sabit; savunma derinliği) | DOĞRULANDI |
| K84 | `db/1194:…` | Örnek şablon işaretlemesi `kod` ile (kurum şablonu aynı kodu taşıyabilir) | OLASI |
| K85 | `uygulama-rolu.sql:35-36, 49-65` | Yalnız `public`/`stg`; `postgres`/`template1` CONNECT açık; parola düz literal (log_statement=all'da günlüğe) | DOĞRULANDI |
| K86 | `sunucu-guncelle.sh:42, 163-177` | `aspnet:10.0` kayan etiket, `docker pull` yok — taban imaj yaması alınmaz | DOĞRULANDI |
| K87 | `Program.cs:324-333`; `yayinla.ps1:277` | Anonim `/api/saglik` PG sürümünü sızdırır; üretim CORS'ta `http://localhost` | DOĞRULANDI |
| K88 | `yayinla.ps1:341` | Uzak betik kopyası ssh çıkış kodu kontrolsüz (eski betikle yeni paket) | DOĞRULANDI |
| K89 | `IskontoKurallariTestleri.cs:71-86`, `TeleradGelenTestleri`, `TeleradSohbetTestleri`, `UretimAnahtariTestleri.cs:19-23` | Assert'siz / yalnız "istisna atmadı" testler | DOĞRULANDI |
| K90 | `web`: `EnabizButonu.tsx:57-61`; `csv.ts:20-23`; `useListeVerisi.ts:153-157`; `Kabuk.tsx:83, 336`; `OturumBaglami.tsx:147-151`; KYS 7 yerel `kacis` | `opener` kalıyor (tabnabbing); CSV formül enjeksiyonu; 10.000 satırda sessiz kesme; yutulan hatalar; çıkış/şube sekmeler arası senkron değil; `htmlGuvenlik.h` yerine kopyalar | DOĞRULANDI |
| K91 | `listeTanimlari.Ticari.ts:749, 755, 781` | `banko-oturum`, `banko-onay`, `vezne-icmali` `urunModu` yok → ERP'de "Kayıt Kabul" grubu | OLASI |
| K92 | `IcmallerSekmesi.tsx:84-93` | Faturalama döngüsünde kısmi başarı bildirilmiyor, liste tazelenmiyor | DOĞRULANDI |

## Tekrarlayan desenler (düzeltmeyi tek seferde planlamak için)

| Desen | Yer sayısı | Referans uygulama |
|---|---|---|
| Özel uçta kayıt kapsamı yok (`YetkiIste` + `where id`) | ~45 dosya | `RadyolojiKayitKapisi`, `KasaUclari.SubeKontrolAsync`, `CalismaPlaniUclari.Kart` |
| Oku-sonra-yaz, koşulsuz UPDATE, kilit yok | ~30 dosya | `MusteriRiskIcmalUclari`, `AriziUclari`, `KonsultasyonUclari`, `BabsIcmal` |
| Belge hattı + bağ ayrı transaction | 11 yer | `StokSayimUclari` (`KaydetAsync(baglanti, islem, …)`) |
| Denetim logu yok / DELETE'ten sonra / ayrı bağlantıda | ~25 dosya | `PlanliGiderUclari` (`__detaylar`), `DevirUclari` (RETURNING ile eski satır) |
| `Islem.Gor` ile yazma | 10 uç | `SiparisIcmal` (Gor + `YazmaIste`) |
| `max(…)+1` sayaç | 7 yer | sequence / `pg_advisory_xact_lock` |
| Sabit `'Europe/Istanbul'` / `Saat.Simdi` vs timestamptz | ~12 yer | `HatirlatmaUclari` (UTC + şube dilimi doğru) |
| Arka plan kuyruğu kilitsiz seçim | 4 servis | `fn_enabiz_siradakiler`, `BildirimDeposu.SiradakileriAlAsync` |

## İyi kurulmuş parçalar

- **SQL enjeksiyonu yok.** 251 uç dosyasında istek metni hiçbir yerde SQL'e girmiyor; beş interpolasyon noktası sabit/beyaz liste kaynaklı. `SorguUretici` alan adını `Kolon()`, operatörü `Gecerlidir`, değerleri `@pN` ile bağlıyor; `{kullanici}`/`{sube}` yer tutucuları da parametre.
- **Oturum modeli:** refresh yalnız SHA-256 özet, atomik rotation (`FOR UPDATE`, tek işlem), tekrar kullanımda aile iptali, `OturumKapisi` her istekte aktif/parola/rol/aile kontrolü; JWT doğrulaması tam (issuer/audience/lifetime/skew 30 sn), üretimde zayıf anahtar reddi.
- **Yetki token'a gömülmüyor**, istek başına `fn_kullanici_yetkileri`; `X-Sube-Id` doğrulanıyor; portal kuralı olmayan kaynak varsayılan kapalı; `DokumanErisimi`/`KayitErisimi` doğru desen.
- **Para matematiği** tamamen `decimal`, `MidpointRounding.ToEven`, Delphi ile birebir; çekirdekte hiç `double` yok; dip toplam tek fonksiyondan.
- **Veri katmanı disiplinli:** 1.116 `AcAsync`'in tamamı `await using`; 9 arka plan işçisi tek bayrakla kapanıyor, tur hatası işçiyi düşürmüyor; XSLT `DtdProcessing.Prohibit`; TLS doğrulaması hiçbir yerde kapatılmamış; bcrypt 12.
- **Referans uygulamalar kodda var:** `MusteriRiskIcmalUclari` (kilit + xmin 409 + alan bazlı log + silme logu önce), `StokSayimUclari` (tek tx), `BankoOturumUclari` genel tasarımı, `AiKontorUclari.SiparisSonuclandirAsync` (idempotent ödeme), `RadyolojiUclari` kaydet/durum (B04/B06 sonrası).
- **DB:** SECURITY DEFINER 0; fonksiyon DDL'leri yalnız geçici tablolarda (uygulama rolüyle tam uyumlu); veri onarımları yedekli ve kanıt tabanlı; göç uygulayıcı advisory kilitli tek işlem + ön yedek; tetik mesajlarının tamamı Türkçe.
- **Yayın:** B07 uygulaması (rol kısıtları her yayında yeniden, PUBLIC CONNECT kapalı, nesne sahipliği denetimi), kalite kapısı aynı rolle; `gizli/` git dışı; hata ara katmanı `izlemeNo`.
- **Testler:** `[VtFact]` açık "atlandı", zorunlu kipte kırmızı, test DB adı zorunluluğu; güvenlik testleri gerçek süreçte negatif senaryolarla (başka şube, portal, eski sürüm, iptal edilen aile); web yenileme akışı davranış testli.

## Çalıştırılan doğrulamalar

Bu inceleme kod okuması ve dev DB (`gentegre_ai`, PG 18.6) salt-okunur sorgularıyla yapıldı; inceleme için test koşulmadı. Aynı gün içinde çalışma ağacının mevcut hâliyle alınan son sonuçlar: API 871/871 (sınırlı DB rolüyle, test DB), web 1.003/1.003, duman testi yeşil. Yeşil testler yukarıdaki bulguların çoğunu kapsamıyor: yarış, kapsam dışı kayıt, portal okuma ve işçi davranışları için test yok.

## Önerilen düzeltme sırası

1. **Portal kapatma (K01, K02, K05, K06, K07)** — `/api/hasta`, `/api/lab`, `/api/telerad`, `/api/isg` gruplarına `RadyolojiKayitKapisi` benzeri filtreler; `mukerrer`'i yazma yetkisine bağla. Kabul: portal hesabıyla başka hastanın `kart-ozeti`, barkod, telerad istek, İSG çalışan → 404.
2. **Hesap ele geçirme (K03, K04)** — `personel-hesap?sifirla` yolunu kısıtla; rol hiyerarşisi kapısı. Kabul: İK yetkisiyle yönetici parolası sıfırlanamaz.
3. **Ağ/operasyon (K08, K09, K10, K11)** — güvenilen proxy ayarı, TLS, dosya izinleri, parola rotasyonu. Bunlar sunucuda işlem ister.
4. **Para/stok bütünlüğü (K12, K13, K14, K15)** — tx overload'ına geçiş ve durum koşullu UPDATE'ler; kasa dağıtım kapsamı. Kabul: çift istek testinde tek fiş/tek düşüm.
5. **Kurum içi kapsam (K16, K17, K26)** — grup filtreleri; `Gor` ile yazan uçlar.
6. **Klinik doğruluk (K18, K22, K24, K21, K25)** — eMAR saat, kritik bulgu doğrulaması, alerji "bilinmiyor", muayene özeti sürümü, cihaz klasörü.
7. **Çekirdek (K19, K41, K39, K40)** ve **DB hijyeni (K20, K43, K44, K45, K46)**.
8. P2/P3 kalanlar modül bazında, "tekrarlayan desenler" tablosundaki referans uygulamalar esas alınarak.

Her düzeltmeye izole DB ile olumsuz senaryo testi eklenmeli (başka şube/başka hasta/portal/eski sürüm/çift istek); mevcut yeşil test sayısı bu sınırların korunduğunu tek başına göstermiyor.
