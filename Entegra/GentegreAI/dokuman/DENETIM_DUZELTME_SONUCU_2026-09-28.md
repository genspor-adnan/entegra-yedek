# Denetim düzeltme sonucu — 28.09.2026

Kaynak: `DENETIM_2026-09-28.md` (tarihsel kanıt, değiştirilmedi) ve
`CLAUDE_DENETIM_DUZELTME_PROMPTU_2026-09-28.md`. Kapsam yalnız `GentegreAI/`
(istisna: kök `CLAUDE.md` / `AGENTS.md`'deki test kuralı değiştiği için
eşitlendi). Commit / push / yayın YAPILMADI.

## Özet

| # | Bulgu | Başlangıç durumu | Sonuç |
|---|---|---|---|
| 1 | Şubesiz kullanıcıda şube filtresi kalkıyor | doğrulandı | **düzeltildi ve doğrulandı** |
| 2 | Aksiyon kapısı salt okunur şubeyi atlıyor | doğrulandı | **düzeltildi ve doğrulandı** |
| 3 | Lab grafik ucunda kayıt kapsamı yok | doğrulandı (+ rapor/istem/geçmiş/dosya uçlarında da) | **ilk turda KISMİ** (doküman paylaşım/silme alternatif yolu açıktı — tekrar denetim #1); **ikinci turda düzeltildi ve doğrulandı** (aşağıda) |
| 4 | Zorunlu parola değişimi yalnız arayüzde | doğrulandı | **düzeltildi ve doğrulandı** |
| 5 | İlk parola ucunda deneme sınırı yok | doğrulandı | **düzeltildi ve doğrulandı** |
| 6 | Refresh yenilemesi atomik değil | doğrulandı (eski kodda 16 eşzamanlı istekten 15'i başarılı) | **düzeltildi ve doğrulandı** |
| 7 | Tetkik izni JWT'deki eski rolle | doğrulandı (ek roller de hiç sorulmuyordu) | **düzeltildi ve doğrulandı** |
| 8 | Göç defteri gerçek geçmişi temsil etmiyor | doğrulandı, yeniden ölçüldü | **araç hazır ve doğrulandı; paylaşılan DB uzlaştırması dış işlem bekliyor** |
| 9 | `-SadeceSema` tam şema kurmuyor | doğrulandı (020'de duruyordu) | **düzeltildi; zincir SKRS dış verisinde tasarlandığı gibi duruyor, 560+ tarihsel bağımlılık açık** |
| 10 | Göç + defter tek işlem değil | doğrulandı | **ilk turdaki "doğrulandı" YANLIŞTI**: sınıflandırıcı PL/pgSQL `end;`'i transaction sayıp normal dosyaları işlem dışı çalıştırıyordu (tekrar denetim #2). **İkinci turda düzeltildi ve doğrulandı** (aşağıda) |
| 11 | Geçici `/ben` hatası oturumu siliyor | doğrulandı | **düzeltildi ve doğrulandı** |
| 12 | Web test taklitleri sözleşmenin gerisinde | doğrulandı (21 test) | **düzeltildi ve doğrulandı** |

Hiçbir bulgu "zaten çözülmüş" çıkmadı.

**Tüm testlerin eski koda karşı kanıtı:** güvenlik bütünleşme testleri, `HEAD`
sürümünden (git metadata'sına dokunmadan `git archive` ile) derlenen API'ye karşı
da koşturuldu (`GENTEGRE_TEST_API_DLL`): **14 testin 11'i eski kodda kırmızı**,
geri kalan 3'ü (süresi dolmuş token, pasif hesap, tekrar kullanımda aile iptali)
eski kodda da doğru olan davranışın regresyon korumasıdır. Eşzamanlı yenileme testi
keskinleştirildikten sonra eski kodda **16 eşzamanlı yenilemeden 15'i başarılı
(15 ayrı dal)**, yeni kodda en fazla 1.

---

## Faz A — şube, kayıt ve rol erişimi

### Bulgu 1 — şubesiz oturum

- **Neden:** `SubeCoz` şube listesi boşken `null` döndürüyordu; `SubeYazma` null'da
  `true`; liste üreticisi yalnız `subeId` doluyken şube koşulu ekliyordu. Özel
  uçların çoğu `(@p is null or sube_id = @p)` kalıbıyla null'u "hepsi" sayıyordu
  (218 çağrı yeri) — yani sorun tek bir üreticide değildi.
- **Düzeltme:** kapı merkezi — `BaglamCozucu.CozAsync` (797 çağrı yerinin ortak
  noktası) aktif şube yoksa `403` fırlatır. İstisna gruba değil tek tek uçlara
  verilir: `SinirliOturumaAcik(SinirliOturum.Subesiz)` — `/ben`, `/parola`,
  `/subeler`, `/dil`, `/hesabim`, `/iletisim`, `/oturumlar`, `/giris-gecmisi`.
  `SubeYazma` varsayılanı artık `false`; şubesiz bağlam yazamaz. Bozuk
  `X-Sube-Id` `400` (sessizce token şubesine düşmüyor).
- **Dosyalar:** `AraKatman/IstekBaglami.cs`, `Uclar/KimlikUclari.cs`, `Servisler/KimlikServisi.cs`.
- **Önce/sonra:** son şube yetkisi kaldırılan kullanıcının token'ı şubeye bağlı
  listeyi okuyabiliyordu → aynı token'la `403 YASAK`; `/ben` `subeYazma:false`.
- **Test:** `ErisimGuvenligiTestleri.Son_sube_yetkisi_kalkinca_ayni_token_sube_verisine_erisemez`,
  `.Sube_basligi_yetkisizse_ya_da_bozuksa_reddedilir` (gerçek HTTP, izole DB).
- **Kalan risk:** `SubeleriHamAsync` bilinçli yedekleri (rol şubeleri, kişinin
  `taraf.sube_id`'si, tek şubeli kurulum) sürer: `kullanici_sube` kaydı silinen
  kişi, çalıştığı şube aktifse o şubeye düşer (ürün kararı, değiştirilmedi). Yerel
  DB'de şubesiz aktif hesap sayısı bugün **0** (rapordaki 3 hesap, bu yedeklerle
  şube buluyor).

### Bulgu 2 — yazan aksiyon

- **Neden:** `AksiyonIste` yalnız rol aksiyon yetkisini soruyordu.
- **Düzeltme:** `AksiyonIste` artık **varsayılan olarak yazma** sayılır ve
  `YazmaIste()` çağırır; okuyan aksiyon `AksiyonGorIste` ile açıkça ayrıldı. 94
  çağrı yeri tarandı: yan etkisiz olan 7'si (`GET` uçları + içeri-alma `coz`/`onizle`)
  `AksiyonGorIste`'ye çevrildi, gerisi yazma. Unutulan aksiyon açık değil kapalı kalır.
- **Dosyalar:** `IstekBaglami.cs`, `Uclar/IceriAlmaUclari.cs`, `Uclar/TeleradUclari.Fatura.cs`.
- **Önce/sonra:** salt okuma şubesinde `/api/fiyat-listesi/{id}/uret` satır yazıyordu
  → `403`, `fiyat_listesi_satir` ve `islem_log` sayıları değişmiyor; yazılabilir
  şubede aynı çağrı başarılı ve günlüğe 1 satır düşüyor.
- **Test:** `ErisimGuvenligiTestleri.Salt_okunur_subede_yazan_aksiyon_reddedilir_ve_yan_etki_birakmaz`.
- **Kalan risk:** aksiyon dışında `YetkiIste(kaynak, Gor)` ile açılıp veri yazan uç
  olabilir (ör. kullanıcıya özel sayaçlar); bu tarama yalnız `AksiyonIste` çağrıları
  üzerinde yapıldı.

### Bulgu 3 — tek kayıt erişimi

- **Neden:** özel uçlar kimliği yoldan alıp `where id = @p0` ile okuyordu.
  Denetimde yalnız grafik ucu anılmıştı; inceleme aynı açığı **lab rapor**
  (`/lab/rapor/{istemId}`), **istem detayı** (`/lab/istem/{id}`), **sonuç geçmişi**
  (`/lab/satir/{id}/gecmis`) ve **doküman içerik ucunda** buldu:
  `/api/dokuman-icerik/{id}` kimliği bilen her oturumlu kullanıcıya dosyayı veriyordu.
- **Düzeltme:** `AraKatman/KayitErisimi` — kuralı İKİNCİ KEZ yazmaz; katalogdaki
  kaynağın sayım sorgusunu (şube, `kullanici_kapsam`, portal kapsamı, hekim kısıtı,
  tetkik kısıtı) tek kimlik süzgeciyle çalıştırır. İş akışı süzgeci (`SabitKosul`)
  erişim kuralı değildir, atlanır. Kapsam dışı = var olmayanla aynı `404`.
  Grafik okuma/yükleme/değiştirme/silme, rapor, istem, geçmiş ve `lab-sonuc`
  dokümanı bu kapıdan geçer. RLS açılmadı.
- **Dosyalar:** `AraKatman/KayitErisimi.cs` (yeni), `Uclar/LabUclari.Grafik.cs`,
  `LabUclari.cs`, `LabUclari.Rapor.cs`, `Uclar/DokumanUclari.cs`, `Program.cs`.
- **Test:** `ErisimGuvenligiTestleri.Lab_grafigi_ve_bagli_uclar_baska_subenin_kaydini_vermez`
  (okuma, rapor, detay, geçmiş, dosya, PUT, DELETE, yükleme; yan etki yok; şube
  yetkisi verilince aynı kayıt açılıyor), `.Portal_hastasi_baskasinin_grafigine_ulasamaz`.
- **Kalan risk (AÇIK):** `/api/dokuman-icerik/{id}` yalnız `lab-sonuc` dokümanlarında
  kapsam denetler. Diğer kaynaklar (taraf/hasta resmi, radyoloji istem kâğıdı,
  muayene dosyası, klasör…) hâlâ yalnız oturum ister. Logo/profil resmi gibi herkese
  açık kullanımlar olduğu için toptan kapatılmadı; kaynak başına erişim haritası
  ayrı iş olarak önerilir. Diğer modüllerin (`radyoloji`, `yatan`, `dis`…) kimlikli
  özel uçları bu turda taranmadı — aynı kapı (`KayitErisimi.IsteAsync`) kullanılmalı.

### Bulgu 7 — güncel rol kümesi

- **Neden:** tetkik izni `fn_lab_tetkik_izin(tetkik, JWT.rolId, …)` — eski rol 30 dk
  geçerli, ek roller hiç sorulmuyor.
- **Düzeltme:** bağlam her istekte `fn_kullanici_rolleri`'nden ana + ek rolleri okur
  (`RolIdleri`; pasif hesapta küme boş → `401`). Yeni `fn_lab_tetkik_izin_roller`
  (923) aynı kuralı rol dizisiyle sorar; tek-rol fonksiyonu gövdeyi ona devreder.
  Liste üreticisi, istem detayı, grafik, rapor (4 sorgu), sonuç onay/giriş aynı
  fonksiyonu kullanır. Üretici rol kümesi verilmezse süzgeci yine ekler (kısıtlı
  tetkik kapalı). Önbellek: tetkik kararı önbelleksiz, rol kümesi istek başına.
- **Dosyalar:** `db/923_lab_tetkik_izin_roller.sql`, `IstekBaglami.cs`,
  `KullaniciDeposu.cs`, `SorguUretici.cs`, `ListeDeposu.cs`, `ListeUclari.cs`,
  `LabServisi.TestYetkisi.cs`, `LabUclari*.cs`.
- **Test:** `ErisimGuvenligiTestleri.Tetkik_izni_token_degil_guncel_rol_kumesinden_cozulur`
  — aynı token'la: ek rol ekle/çıkar, ana rol değiştir, kısıtı kapat; genel
  `lab.sonuc` izni ile tetkik izni birbirinin yerine geçmiyor.

## Faz B — kimlik ve oturum

### Bulgu 4 — zorunlu parola

- **Düzeltme:** `AraKatman/OturumKapisi` (kimlik doğrulamadan sonra her kimlikli
  istekte): pasif hesap `401`; `parola_degismeli = 1` iken yalnız
  `SinirliOturum.ParolaDegismeli` işaretli uçlar (`/ben`, `/parola`; `/cikis`
  anonim) çalışır, gerisi yeni hata kodu `403 PAROLA_DEGISMELI`. Durum istek başına
  DB'den okunur: bayrak token alındıktan sonra açılsa, yenileme ya da şube değişimi
  yapılsa da kapı aynı kararı verir. `/parola` artık diğer oturumları kapatıp bu
  cihaza **yeni token ikilisi** döner (eskiden 30 dk sonra kişi dışarı düşüyordu).
  Web: `PAROLA_DEGISMELI` gelince profil tazelenir, parola ekranı açılır.
- **Dosyalar:** `AraKatman/OturumKapisi.cs` (yeni), `Program.cs`, `Hata.cs`,
  `KimlikUclari.cs`, `KimlikServisi.cs`, `KullaniciDeposu.cs`; web `cekirdek.ts`,
  `sozlesme.ts`, `uclar/kimlik.ts`, `OturumBaglami.tsx`.
- **Test:** `OturumGuvenligiTestleri.Parola_degismeli_hesap_is_uclarina_arayuzu_atlayarak_da_erisemez`.
- **Kalan risk:** personel varsayılan parolası kart kimliği (ürün kararı). Kapı
  bu parolayla iş yapılmasını engeller ama kimliği bilen biri ilk girişte parolayı
  kendisi belirleyebilir — yönetici akışı için tek kullanımlık rastgele başlangıç
  parolası önerilir (karar kullanıcının).

### Bulgu 5 — ilk parola

- **Düzeltme:** ilk parola, mevcut "parolamı unuttum" altyapısına bağlandı
  (`ParolaSifirlamaServisi`): 1) `/ilk-parola/kod` `{kod, tcknSon4}` — TCKN son 4
  yalnız kayıtlı kanala 10 dk'lık 6 haneli kod göndermenin ön koşulu, cevap HER
  durumda aynı; 2) `/ilk-parola` `{kod, dogrulamaKodu, yeniParola}` — yalnız
  parolası HÂLÂ boş hesapta (koşullu UPDATE). Kod satırı işlem içinde kilitlenip
  tüketilir; parola ve oturum kapatma aynı işlemde; yazılamazsa kod tüketilmez.
  Yanlış TCKN / kod normal girişin hatalı-giriş sayacını ve kilidini işletir; IP
  başına 15 dk'da 20 başarısız anonim deneme. IP artık `UseForwardedHeaders` ile yalnız
  güvenilen proxy'den (`Guvenlik:GuvenilenProxyler`, varsayılan loopback — nginx aynı
  makinede) ve yalnız son atlamadan çözülür. "Parolamı unuttum" doğrulaması da aynı
  atomik tüketime geçti (eskiden eşzamanlı iki doğru kod iki kez parola yazabilirdi).
  Kayıtlı iletişim kanalı olmayan hesap bu yoldan açılamaz: yönetici "personel
  hesapları" ile zorunlu değişimli parola atar (sunucu kapısı Bulgu 4). Gerçek SMS
  gönderilmedi: testler kuyruğa düşen mesajı okur, bildirim işçisi kapalıdır.
- **Dosyalar:** `ParolaSifirlamaServisi.cs`, `KimlikServisi.cs` (eski TCKN-only
  yöntem kaldırıldı), `KimlikUclari.cs`, `Kimlik.cs`, `GuvenlikAyarlari.cs`,
  `Program.cs`; web `Giris.tsx` (iki adımlı ekran), `uclar/kimlik.ts`.
- **Test:** `OturumGuvenligiTestleri.Ilk_parola_tckn_son4_ile_tek_basina_belirlenemez_kod_tek_kullanimlik`,
  `.Ilk_parola_suresi_gecmis_kod_ve_es_zamanli_kullanim_tek_basari` (6 eşzamanlı
  istekte tek başarı), `.Ilk_parola_ip_esigi_asilinca_reddedilir_ve_parolali_hesaba_calismaz`.
- **Kalan risk:** `/parola-unuttum` 1. adımı `gonderildi/kanal/maskeli hedef` döndürüyor
  — hesap varlığını dolaylı gösterir (mevcut UX kararı, değiştirilmedi). Giriş ucunun
  `ILK_PAROLA` cevabı da "parolası boş hesap var" bilgisini verir (ürün kararı).

### Bulgu 6 — refresh atomikliği

- **Düzeltme:** eski satır `FOR UPDATE` ile kilitlenir, kapatılır ve yeni satır aynı
  bağlantı + işlemde yazılır; yanıt commit'ten sonra döner. Kilit altında satırın
  kapatılamaması yeni dal açmaz. Tekrar kullanımda aile iptali hata dönmeden
  **commit** edilir. Web: sekmeler arası tek yenileme (Web Locks; kilidi bekleyen
  sekme token yenilenmişse sunucuya gitmez) — sunucu koruması gevşetilmedi.
- **Dosyalar:** `OturumDeposu.cs`, `KimlikServisi.cs`; web `api/cekirdek.ts`.
- **Test:** `OturumGuvenligiTestleri.Es_zamanli_yenilemede_en_fazla_bir_gecerli_dal_olusur`
  (4 tur × 16 eşzamanlı istek, bariyerle), `.Iptal_edilmis_token_tekrar_kullanilinca_aile_kalici_iptal_edilir`,
  `.Yeni_kayit_yazilamazsa_eski_token_tukenmez` (test DB'de tetikle yazım hatası),
  `.Suresi_dolmus_token_ve_pasif_hesap_reddedilir`; web `yenilemeSekmeler.test.ts` (5).

## Faz C — web

### Bulgu 11 — geçici `/ben` hatası

- **Düzeltme:** `benHatasiSinifi` — `kesin` (401 ve refresh de reddedildi) temizler;
  `gecici` (ağ, 15 sn zaman aşımı, 5xx, yenilenemeyen 401) token'ı korur, "Yeniden
  Dene" ekranı gösterir, korumalı ekran açılmaz; `sube` (403) saklanan şubeyi bırakıp
  BİR KEZ tekrar dener. Döngü yok.
- **Dosyalar:** `kimlik/OturumBaglami.tsx`, `App.tsx`, `api/cekirdek.ts`.
- **Test:** `oturumGeciciHata.test.tsx` (10 test: 503/ağ kesintisinde refresh
  duruyor ve yeniden deneme oturumu geri yüklüyor; kesin retle temizleniyor; 403'te
  iki denemede duruyor).

### Bulgu 12 — test taklitleri

- **Düzeltme:** `test/taklit/basvuruIstem.ts` — gerçek uç nesnesine `satisfies` ile
  bağlı ortak taklit; iki test dosyası bunu kullanır. Uca fonksiyon eklenirse taklit
  DERLENMEZ. Üretim koduna fallback eklenmedi, assertion silinmedi.
- **Test:** `basvuruEkrani.test.tsx` + `basvuruKapat.test.tsx` 43/43.

## Faz D — göç ve kurulum

### Bulgu 8 — defter uzlaştırma

- **Araç:** `db/araclar/goc_uzlastir.ps1` — SALT OKUNUR (`default_transaction_read_only`).
  Her dosyanın oluşturduğu nesneleri (tablo, kolon, fonksiyon, view, indeks, tetik,
  tip, sekans) çıkarır, sonradan / aynı dosyada sonra silinen-adlandırılanları ayıklar,
  katalogda arar. Sınıflar KANIT derecesidir: `DEFTERDE` (özetsiz = doğrulanmamış),
  `DEFTER_DEGISMIS`, `ETKI_VAR`, `ETKI_KISMI`, `EKSIK`, `BELIRSIZ`.
- **Yeniden ölçüm (paylaşılan `gentegre_ai`, salt okunur):** diskte 907 dosya (906 +
  bu turun 923'ü; 924 sonra eklendi), defterde 640 kayıt. Defterde olmayan **268**
  (raporun 267'si + 923): `ETKI_VAR` 169, `ETKI_KISMI` 3, `BELIRSIZ` 96, `EKSIK` 0.
  `ETKI_KISMI`: `419_dokuman_v1` (`ix_dokuman_onay_dokuman` yok), `484_hizmet_huv_kodu`
  (`ix_hizmet_sut_kodu` yok), `923` (bu tur, bekliyor). Defterde olup diskte olmayan:
  `843_parola_sifirlama.sql` (dosya yeniden adlandırılmış olmalı).
- **Paylaşılan DB'ye uygulama — DIŞ İŞLEM BEKLİYOR** (onay gerekli, yapılmadı):
  1. `pg_dump -Fc gentegre_ai` yedeği.
  2. `goc_uygula.ps1 -Db gentegre_ai -Dosyalar 923_lab_tetkik_izin_roller.sql,924_not_valid_kisit_dogrula.sql`
     — **yeni API'yi dev DB'ye bağlamadan ÖNCE şart** (lab uçları
     `fn_lab_tetkik_izin_roller` ister).
  3. `ETKI_KISMI` iki indeks için dosya incelemesi → gerekiyorsa YENİ numaralı
     göçle indeks.
  4. `ETKI_VAR` / `BELIRSIZ` dosyalar TOPTAN deftere yazılmaz; dosya dosya inceleme
     planı (özellikle veri düzeltmesi içeren `BELIRSIZ`'ler).

### Bulgu 9 — boş kurulum

- **Düzeltme:** `kur.ps1 -SadeceSema` artık bütün zinciri kurulum sırasıyla, boş
  kurulum kipinde uygular. MSSQL aktarım listesi (`db/kurulum/aktarim_adimlari.txt`)
  ÖLÇÜLEREK çıkarıldı: bütün zincir boş DB'de koşturuldu; adı "goc" olan
  dosyaların çoğu (002, 003, 013, 018, 021, 079, 080, 081) boş stg ile sorunsuz
  çalışıyor ve sonrakilerin dayandığı şema/fonksiyonu kuruyor (003
  `fn_etiket_anahtar`'ı tanımlar, 022 kullanır) — listede yalnız `014_goc_belge`
  kaldı. `db/kurulum/000_bos_kurulum.sql` her bekleyen dosyadan önce çalışır.
- **Bulunan gerçek hata:** tohum dosyası tablo yokken kendisi patlıyordu
  (PL/pgSQL `IF` koşulunun tamamını planlar) — sunucudaki eski akış da tohumu
  boş DB'de göçlerden ÖNCE çalıştırdığı için ilk satırda kırılırdı. Düzeltildi.
- **Sonuç (izole `gentegre_ai_bos_test`):** zincir **545 dosya** uygulayıp 521'de
  (SKRS ambarı) `exit 2` ile durur; SKRS ham verisi yüklenince AYNI komut kaldığı
  yerden devam eder, 559'da (SKRS kod listeleri) tekrar `exit 2`. Kod listeleri de
  sağlanınca **560 (`skrs_klinik_brans_takas`) `ux_departman_ad` çakışmasıyla durur**:
  560 geçmişteki klinik/branş karışıklığını düzelten bir VERİ göçü ve bugünkü SKRS
  listeleriyle boş veritabanında tekrarlanamıyor. İkinci çalıştırma zararsız
  (uygulananlar atlanır, başarısız dosya işlem içinde geri alınır).
- **Açık / ileriye dönük çözüm:** tarih düzenlenmeden 560+ boş DB'de tamamlanmaz.
  Öneri: doğrulanmış bir veritabanından **şema tabanı** (`db/kurulum/taban_NNN.sql`,
  `pg_dump --schema-only` + ürün referans tohumları); boş kurulum tabanı yükler,
  ≤NNN dosyaları `yontem = 'taban'` ile işaretler ve yalnız sonrakileri uygular.
  Önkoşul: kaynağı uzlaştırılmış bir DB (Bulgu 8). "Temel kimlik/liste/kart
  sözleşmesi boş DB'de çalışır" kabulü bu yüzden **doğrulanamadı**.

### Bulgu 10 — atomik uygulama

- **Düzeltme:** tek kural iki uygulayıcıda: `db/araclar/goc_uygula.ps1` (kur.ps1 kullanır)
  ve `yayin/goc_uygula.sh` (sunucu). İşlemli dosya: `BEGIN` → advisory kilit →
  defter kontrolü → dosya → defter kaydı → `COMMIT`. Kendi `BEGIN/COMMIT`'ini taşıyan
  28 dosya metinden tespit edilir ve işlem dışı çalışır (dosya kendi işleminde
  atomik; `yontem = 'islem_disi'`). Defter: `ozet` (sha256) + `yontem`; eski kayıtlarda
  özet yok (doğrulanmamış, uydurulmadı). Çıkış kodu 0/1/2. Defter kurulumu da kilit
  altında (eşzamanlı `create if not exists` PG katalog yarışı testte yakalandı).
  Sunucu: bekleyen göç varsa önce `pg_dump` yedeği (son 5), sonra uygulayıcı; yayın
  geri alması DB'yi GERİ ALMAZ — betik ve `db/OKUBENI.md` bunu açıkça yazar.
- **Dosyalar:** `db/araclar/goc_uygula.ps1` (yeni), `yayin/goc_uygula.sh` (yeni),
  `db/kur.ps1`, `yayin/sunucu-guncelle.sh`, `yayin/yayinla.ps1`, `db/kurulum/*`.
- **Test:** `GocUygulayiciTestleri` (4 senaryo × PS/bash = 8, gerçek süreç, her test
  kendi geçici DB'si): ortada patlayan göç önceki ifadeleri ve defteri geri alır;
  başarı tek kayıt, tekrar çalıştırma yeniden uygulamaz, işlem dışı dosya işaretlenir;
  eşzamanlı iki güncelleyici tek uygulama; dış veri `exit 2` + kaldığı yerden devam.
  İki kez üst üste 8/8.
- **Kalan risk:** yayın betiği sunucuda çalıştırılmadı (üretime dağıtım yok);
  bash uygulayıcı Git Bash + docker üzerinden sınandı.

## Faz E — veri kalitesi ve bakım

- **`NOT VALID` kısıtlar (salt okunur ölçüm):** 7 kısıt. Aykırı satır:
  `ck_taraf_hasta_dogum_zorunlu` 2, `ck_taraf_hasta_cinsiyet_zorunlu` 1 (toplam 2
  farklı hasta), diğer 5'i 0. Yeni `924_not_valid_kisit_dogrula.sql`: her kısıt için
  önce aykırı satırı sayar, sıfırsa `validate constraint`, değilse dokunmaz. Hasta
  kısıtları (480) bilinçli dışarıda: eksikler ancak GERÇEK doğum tarihi/cinsiyetle
  tamamlanabilir — **açık iş** (kişisel veri rapora alınmadı). İzole DB'de: 4 kısıt
  geçerli oldu, hasta kısıtları dokunulmadı, ikinci çalıştırma atlandı.
- **Testler çözümde ve açık atlama:** test projesi `Gentegre.slnx`'te. `VeritabaniOlgusu`
  paylaşılan DB'ye sessiz düşmeyi bıraktı: yalnız `GENTEGRE_TEST_DB`, hedef adında
  `test` şart; değişken yoksa `[VtFact]`/`[VtTheory]` xUnit'te **Atlandı** (332 DB
  testi işaretlendi); `GENTEGRE_TEST_ZORUNLU=1` ya da ulaşılamayan DB → başarısız.
- **Nullable uyarıları:** API 14 → **0**, bastırma/`#pragma`/toplu `!` yok: agregat
  sorguların "her zaman tek satır" değişmezi açık `?? throw`; gerçekten null olabilen
  kayıt `404`; yanlış yere konmuş `!` (Task'a uygulanıyordu) kaldırıldı; e-Nabız
  hesabında boş adres SQL'de süzülüyor. Test projesinin kendi 10 uyarısı önceden vardı,
  dokunulmadı.
- **Rota bazlı yükleme:** 72 ekran `React.lazy` (`bilesenler/TembelSayfa.tsx`: Suspense +
  parça hata sınırı). Kabuk, giriş, parola ekranı, liste, panel hemen. Rota ağacı ve
  yetki kapıları değişmedi. Ana JS **2.494,72 kB → 1.556,24 kB**, gzip
  **644,20 kB → 423,63 kB** (−38 % / −34 %). Uyarı sınırı yükseltilmedi; ana parça
  hâlâ 1.500 kB üstünde (Liste/BelgeKarti zinciri) — sonraki bölme adayı.
- **Belgeler:** `db/GUNCEL.md` yeniden üretildi (`fn_basvuru_istem_serbest_uygula`,
  `fn_lab_tetkik_izin_roller` dahil); `api/`, `db/`, `web/`, test `OKUBENI.md`'leri ve
  API sözleşmesi §1.1/§1.2/§8 gerçek davranışla eşitlendi; eskimiş "dokuz liste /
  Faz 0 / Sıradaki" ifadeleri kaldırıldı.

## Doğrulama

| Kapı | Sonuç |
|---|---|
| `api/: dotnet build -p:OutputPath=bin/AuditFix/` | 0 hata; src 0 uyarı (önce 14); çözümde test projesinin önceden var olan 10 uyarısı |
| `api/: dotnet test tests/Gentegre.Testler …` (`GENTEGRE_TEST_DB` = izole `gentegre_ai_test`) | **577 test: 575 geçti, 2 başarısız (aşağıda, önceden var olan veri durumu), 0 atlandı, 0 `[ATLANDI]`**; gerçek DB bağlantısı `gentegre_ai_test` (+14 güvenlik bütünleşme, +8 göç uygulayıcı testi yeni) |
| Güvenlik testleri eski koda karşı | 14 testin 11'i kırmızı (beklenen) |
| `web/: npm run build` | başarılı; ana JS 1.556,24 kB (gzip 423,63 kB) |
| `web/: npm test` | **75 dosya / 736 test, hepsi geçti** (önce 73/721, 21 kırmızı) |
| Göç uygulayıcı testleri | 8/8, iki kez |

**API testlerinde önceden var olan 2 başarısızlık (kod değişikliğinden bağımsız,
VERİ durumu testi):** `StandartRolModulTestleri.Haritadaki_modul_kodlari_KATALOGDA_var`
— 908 `steril` modülünü `kurum_modul`'den sildi, C# rol şablon haritası hâlâ
`steril` diyor; `BankoSefiTestleri.Ust_yonetim_SALT_OKUMA_ama_imza_atar` — 911
`ust_yonetim` rolüne `ariza.talep` ekleme yetkisi verdi. İkisi de defter dışında
uygulanmış göçlerin ürün kuralıyla çelişmesi; karar kullanıcıya ait (kural mı
göç mü düzeltilecek). Değiştirilmedi.

**Test ortamı:** `gentegre_ai_test` = paylaşılan `gentegre_ai`'nin `pg_dump`/`pg_restore`
kopyası (okuma), 923 ve 924 yalnız burada uygulandı. `gentegre_ai_bos_test` boş
kurulum kanıtı olarak bırakıldı (silinebilir). Paylaşılan `gentegre_ai`'ye YAZILMADI.

## Dış işlem bekleyenler

1. **Dev DB'ye 923 + 924** (yedekle, `goc_uygula.ps1` ile) — yeni API derlemesi dev
   DB'ye bağlanmadan önce.
2. Defter uzlaştırma planının gözden geçirilmesi (Bulgu 8, madde 3-4).
3. İki hasta kaydının gerçek doğum tarihi/cinsiyet bilgisiyle tamamlanması → sonra
   480 kısıtları için doğrulama göçü.
4. Şema tabanı kararı (Bulgu 9).
5. Yayın: `yayinla.ps1` yeni paket içeriğiyle (goc_uygula.sh + db/kurulum) — ilk
   yayında sunucu defterine `ozet/yontem` kolonları eklenir.
6. Ürün kararları: varsayılan personel parolası, `/parola-unuttum` cevabının
   hesap varlığını göstermesi, doküman içerik ucunun kaynak başına erişim haritası,
   908/911 çelişkileri.

---

## İkinci tur — tekrar denetim bulguları (`DENETIM_TEKRAR_KONTROL_2026-09-28.md`)

### Tekrar #1 — doküman paylaşımı lab kapısını aşıyordu (düzeltildi ve doğrulandı)

- **Neden:** ilk turda kapı yalnız `/api/dokuman-icerik/{id}` ucunda ve yalnız
  `lab-sonuc` için vardı. Kart yolu (`/api/dokuman/{kart}/{kayit}/{dokuman}/...`)
  yetkiyi URL'deki kart adından çözüyor, depo yalnız doküman kimliğiyle çalışıyordu:
  `cari` yetkilisi lab dokümanına paylaşım kodu üretebiliyor, silebiliyordu; "kendi
  kartı" istisnası URL'ye bağlıydı. İnceleme DMS uçlarında (`/api/dokuman-yonetim/{id}/
  paylasim`, `tasi`, `surum`, `baglanti`, `onaya-gonder`, link/bağlantı iptali) da
  yalnız `dokuman` yetkisiyle AYNI açığı buldu.
- **Düzeltme:** `AraKatman/DokumanErisimi` — dokümanın gerçek `kaynak/kaynak_id`'si
  DB'den okunur; kart yolunda URL ile eşleşmezse 404. Kaynak türü → yetki + katalog
  kayıt kapsamı tablosu (taraf→cari/personel, stok, belge, muayene, radyoloji-istem,
  masraf-beyan, servis-ziyaret, klasör→dokuman; şube logosu ve e-Belge şablonu
  oturumlu herkese okunur); lab sonucu satır kapsamı + tetkik izni. Tanınmayan tür
  KAPALI; yetkisizlik de 404 (403 kimliğin lab dokümanı olduğunu söylerdi). İçerik,
  liste, ekle, düzenle (XSLT hedef türü dahil), varsayılan, sil, paylaşım ve bütün
  DMS kimlik uçları bu kapıdan geçer; paylaşım linki ayrıca içeriği GÖRME hakkı ister.
  "Kendi kartı" istisnası gerçek sahipliğe bağlandı.
- **Dosyalar:** `AraKatman/DokumanErisimi.cs` (yeni), `Uclar/DokumanUclari.cs`,
  `Uclar/DokumanYonetimUclari.cs`, `Program.cs`.
- **Test:** `ErisimGuvenligiTestleri.Baska_kart_yolu_altinda_lab_dokumani_paylasilamaz_silinemez_degistirilemez`
  (cari/personel/fiziksel ad yolları, paylaş/varsayılan/düzenle/sil, yan etki yok,
  kendi cari dosyası çalışıyor) ve `.Dokuman_icerigi_ve_yonetim_uclari_kaynak_yetkisi_ve_kapsami_ister`
  (lab dışı kaynakta içerik kapsamı, DMS paylaşım/taşı/sürüm, klasör dokümanı çalışıyor).
  Eski (`HEAD`) derlemeye karşı ikisi de kırmızı (saldırı `200` alıyordu), yeni kodda yeşil.
- **Davranış değişikliği:** başkasının profil fotoğrafını görmek artık `cari` ya da
  `personel` görme yetkisi (ve kayıt kapsamı) ister; yalnız `dokuman` yetkili DMS
  kullanıcısı kart kaynaklı dokümanın içeriğini göremez/paylaşamaz.
- **Kalan risk:** DMS klasör/depo özet uçları doküman ADI/sayısı düzeyinde bilgi
  vermeye devam eder (içerik değil). `/surum` içerik özetini (`hash`) istemciden alır;
  özetler dışarı verilmediği sürece başka dokümanın içeriğine bağlanamaz — ayrıca
  sınanmadı.

### Tekrar #2 — uygulayıcı PL/pgSQL `end;`'i transaction sanıyordu (düzeltildi ve doğrulandı)

- **Neden:** satır başında `end;` araması DO/fonksiyon gövdesindeki `end;`'i (ve
  `case … end;`'i) üst düzey COMMIT saydı; bu dosyalar işlem DIŞINDA çalışıp ortadaki
  hatada yarım kalıyordu (ör. `037_kisi_karti.sql`). İlk turdaki "doğrulandı" iddiası
  bu senaryoyu kapsamadığı için yanlıştı.
- **Düzeltme (iki uygulayıcıda aynı):** yorum, metin sabiti ve `$tag$` gövdesi TEK
  GEÇİŞTE ayıklanır (hangisi önce gelirse — yorumdaki `$$` gövde sanılmaz), kalan metin
  `;` ile ifadelere bölünür, ifadenin TAMAMI `BEGIN/COMMIT/ROLLBACK/END [WORK|TRANSACTION]`
  ya da `START TRANSACTION` ise işlem dışı. Ara denemede görülen iki tuzak da kapandı:
  katılmayan gruba geri başvuru (`$$` ayıklanmıyordu) ve `case … end;`. İşlem dışı
  dosyanın hata mesajı artık "yalnız kendi BEGIN/COMMIT aralığı geri alınır" diyor.
- **Ölçüm:** 907 dosyada artık **28** dosya işlem dışı sayılıyor ve hepsi gerçekten üst
  düzey `BEGIN/COMMIT` taşıyor; PS ve bash listeleri birebir aynı; 037, 426, 893, 923
  işlemli.
- **Test:** `GocUygulayiciTestleri.PLpgSQL_govdeli_dosya_ortada_patlarsa_hic_iz_birakmaz`
  (DO + fonksiyon gövdesi + `case … end;` + yorumda `$$`, ortada hata → tablo, fonksiyon,
  defter kaydı YOK) ve `.Ust_duzey_BEGIN_COMMIT_dosyasi_islem_disi_isaretlenir`, PS +
  bash. Denetçinin deney dosyası (`api/TestResults/Reaudit/migration-repro/001_yarim.sql`)
  yeni uygulayıcıyla: exit 1, tablo yok, defter 0.

### İkinci tur doğrulama

| Kapı | Sonuç |
|---|---|
| `dotnet build` (çözüm) | 0 hata; src 0 uyarı; test projesinin önceden var olan 10 uyarısı |
| `dotnet test` (`GENTEGRE_TEST_ZORUNLU=1`, izole `gentegre_ai_test`) | **583 test: 581 geçti, 2 başarısız (önceden bilinen 908/911 veri-kural çelişkisi), 0 atlandı** |
| Güvenlik + göç testleri | 28/28 (doküman 2 + göç 4 yeni) |
| Web | değişmedi (736/736, ilk tur) |

Açık kalanlar değişmedi: dev DB'ye 923+924, defter uzlaştırması, boş kurulumun
560'ta durması, iki kırmızı testin ürün kararı.
