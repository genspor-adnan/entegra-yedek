# Kalan İşler

Bu liste `00_TARIHCE.md`'deki her turun sonuna dağılmış "Kalan" notlarının
toplanmış ve **canlı veriyle doğrulanmış** hâlidir. Tarihçe *ne yapıldığını*
anlatır; burası *ne yapılmadığını*.

Son güncelleme: **17.09.2026**, `db/771` sonrası.

Doğrulama yöntemi: maddeler dev veritabanına (docker `gentegre-pg18`) ve
koda bakılarak yazıldı; sayılar o anki gerçek durumdur. Bir maddeyi
kapatmadan önce sayının hâlâ geçerli olduğu kontrol edilmeli.

---

## 1. Kurulum adımları (kod işi yok)

Bunlar kodda eksik olan bir şey değil; kurulumda girilecek veri.

| # | İş | Bugünkü durum |
|---|---|---|
| 1.1 | **Bildirim sağlayıcısı tanımlanmalı** — Genel Ayarlar › Entegrasyon Hesapları › "E-Posta (SMTP) Sağlayıcı" ya da "SMS Sağlayıcı". `ayarlar.bildirim_kanal` zorunlu (1 SMS · 2 e-posta). | `bildirim_kanal` ayarlı hesap: **0**. Hesap yokken gönderim başarısız oluyor ve `bildirim_log`a sebep yazılıyor. |
| 1.2 | **Alıcıların iletişim bilgisi girilmeli** (`taraf_kullanici.eposta` / `cep_tel`). Boş olan kişi için bildirim satırı açılmıyor, günlüğe uyarı düşüyor. | İletişim bilgisi olan aktif kullanıcı: **5**. Vekâlet denemesinde `admin` ve `e2e` dolduruldu; kalan onaylayanlar hâlâ boş. |
| 1.3 | **Dinî bayram tarihleri Diyanet takvimiyle doğrulanmalı** (`resmi_tatil.dogrulandi = 1` yapılmalı). Tarihler hicrî takvime bağlı olduğu için algoritmayla üretilmedi. | Doğrulanmamış: **17 tarih** (2026-2027). |
| 1.4 | **2028 ve sonrası tatil takvimi girilmeli.** Millî tatiller ekrandan üretilir (`/tatil/uret/{yil}`), dinî bayramlar elle. | En yüksek tatil yılı: **2027**. |

---

## 2. Omurgada duran ama hiç kullanılmamış yetenekler

Onay omurgası bunları destekliyor; hiçbir akış kullanmıyor.

**Bloke:** e-imza (2.3) kütüphane seçimini bekliyor - başlanmamalı.

| # | Yetenek | Bugünkü durum |
|---|---|---|
| 2.1 | ~~**Vekâlet**~~ — **17.09.2026'da gerçek veriyle denendi ve çalışıyor.** Engel, karar, gelen kutusu ve bildirim dört yönüyle doğrulandı. | Kayıt: **1** (E2E Test Kullanicisi → Sistem Yoneticisi, 17.09-17.10). Deneme verisi **bilerek bırakıldı**. |
| 2.2 | ~~**Sözlü onay** takibi~~ — **763'te kapandı.** `v_onay_sozlu` görünümü, `onay.sozlu_takip` günlük işi (09:30) ve `/api/onay/adim/{id}/yaziliya` ucu geldi. | Kullanım hâlâ **0** (kimse sözlü onay vermedi) ama artık verilirse takip ediliyor. |
| 2.3 | **e-İmza** (`onay_akis_adim.e_imza_zorunlu`) — kolon var, akış tanımı ekranından işaretlenebilir. **KÜTÜPHANE BEKLENİYOR** (17.09.2026, kullanıcı kararı): PAdES/TSA kütüphanesi seçilmeden veri modeli ve uçlar yazılmayacak - önce yazıp sonra kütüphaneye uydurmak, imza biçimini kodun değil kodu imza biçiminin belirlemesi gereken bir yerde tersine çevirirdi. Tasarım hazır: `dokuman/02_EIMZA_LAB.md` (`belge_imza` tablosu, imza aracı zinciri, toplu imza, addendum). | İşaretli adım: **0**. İmza atma/doğrulama akışı **hiç yazılmadı**; bayrak bugün hiçbir şey yapmıyor. |

---

## 3. Modüllerde yarım kalanlar

| # | İş | Not |
|---|---|---|
| 3.1 | **Doküman: klasör / bölüm sorumlusu basamağı.** 419'da `dinamik` üç değer tanımlamıştı (1 sahip · 2 klasör sorumlusu · 3 bölüm sorumlusu); yalnız 1 uygulanmış. 758 taşımada uydurulmadı. | Bugün o adımlar rol basamağı olarak duruyor ve **kimseye atanmıyor**: `dokuman.%` akışında `sahip_turu = 1` olan **2 adım**. |
| 3.2 | **Doküman ve iskontoda rol bazlı basamak yetkisi.** Akış adımlarının `rol` alanı bu iki akışta kullanılmıyor; karar yetkisi tek kod (`dokuman.onay`, `belge.iskonto_onay_*`). Rol ayrımı gerekirse `OnayUclari.AksiyonKodu` ve `OnayBildirimi.AksiyonKodu`'na dal eklenmeli (**ikisi birden**, biri eksikse bildirim sessizce kesilir). | — |
| 3.3 | **Avans mahsubu bordroya bağlanmalı.** Bordro modülü olmadığı için kesintiler ekrandan elle işaretleniyor. `personel_avans_kesinti.donem` (yyyy-mm) bordro gelince bağlanmak üzere hazır. | **768 bu maddeyi büyüttü:** maaş yazısındaki tutar da bordrodan gelmiyor, İK talebin `maas_tutar` alanına elle giriyor. Bordro geldiğinde iki yer birden bağlanmalı. |
| 3.4 | **Onaylanan izinde randevuların toplu taşınması / iptali.** Bugün izin onaylanınca hekimin planı kapanıyor ve yeni randevu engelleniyor, ama **o güne daha önce alınmış randevular yerinde kalıyor**. | `randevu.izinli_hekim` ayarı **0** (engelle). |
| 3.5 | **Resmî tatilde klinik planını kapatma ayarı.** Tatil tablosu var, plana etkisi yok. | `referans`ta tatille ilgili ayar: **yok**. |
| 3.6 | **Onay akışı ayarları mockup'ının kalan sekmeleri.** `Ekranlar/Ayarlar/onay_akis_ayarlari.html` beş sekmeli; karşılığı olarak akış tanımı (`/onay-akis`) ve vekâlet (`/onay-vekalet`) ekranları yapıldı. Kalan sekmeler yapılmadı. | — |
| 3.10 | **Antette LOGO yok — hiçbir çıktıda.** `sube.logo` (bytea) ve `dokuman` kaynağı `sube` (`belge_turu`: Logo / Kaşe / İmza / Antet) 193'ten beri duruyor; göz şeması, döküm baskısı ve 768'in belge yazısı **üçü de** yalnız metin antet çiziyor. Resmî yazıda kurum logosu beklenir. | Tek ekranın değil, ortak bir çıktı bileşeninin işi. Bugün veri de boş: logolu şube **0**, `kaynak = sube` doküman **1** (türü boş). |
| 3.11 | **Belge talebinde `teslim_sekli` işlevsiz.** Alan doldurulup saklanıyor (1 elden · 2 e-posta · 3 kargo) ama hiçbir davranışı değiştirmiyor: "e-Posta" seçilse bile yazı kendiliğinden gönderilmiyor, İK elle iletiyor. | 768 metni ürettiğine göre gönderim artık mümkün - `bildirim` kuyruğu ve şablon altyapısı hazır, eksik olan yalnız ek/gövde olarak yazının bağlanması. **1.1** (sağlayıcı hesabı) ön koşul. |

**Bu turda kapananlar.** Kayıt için, ayrıntı tarihçede:

| # | İş | Kapanış |
|---|---|---|
| 3.7 | Masraf beyanında fiş/fatura görseli | Doküman modülü masraf kartına açıldı (`kaynak = masraf-beyan`); fiş-satır bağı ayrı tablo değil, dokümanın `belge_turu` alanı. |
| 3.8 | Belge talebinde yazının kendisi | **768** — `belge_yazi_sablonu` + `fn_belge_talep_yazi`; `/hazirla` metni **dondurur**, şablon sonradan değişse de belge değişmez. Yazdırma `/belge-talep/yazi/{id}`, şablonlar Genel Ayarlar › Belge Yazıları. |
| 3.9 | `beyan_no` / `talep_no` / `avans_no` | **767** — tür kodları 906-908, ön ekler `AV-`/`MB-`/`BT-`. Geçmiş kayıtlara numara **verilmedi**; onlar `#id` görünmeye devam eder. |

---

## 4. Teknik borç

| # | İş | Not |
|---|---|---|
| 4.1 | **`LogTabloId` modül-içi gruplamaları.** 757 modüller-arası çakışmaların tamamını ayıkladı; **7 kod** bilinçli gruplama olarak muafiyet listesinde (`LogTabloIdTestleri.GruplananKodlar`): göz ölçümleri, göz işlemleri, göz görüntüleme, yatış izlemleri, yatış order, diş seansı, medula raporu. Bu kodlarda `tablo_id + kayit_id` hâlâ tek kaydı göstermiyor. | Çakışma değil, tercih. Ayırmak 20+ yeni numara demek. |
| 4.2 | **757'de taşınamayan üç log bağı.** `kullanici_sube` ve `zamanli_is` tablolarında `id` kolonu yok; bir log satırının onlara ait olup olmadığı ölçülemiyor. Kod tarafında numaraları ayrıldı (904 → 1297, 962 → 1289) ama **geçmiş satırlar eski numarada**. | Aynı numaradaki `lab_istem_satir` da bu yüzden taşınmadı. |
| 4.3 | **755'te taşınamayan avans log satırları.** 907 ile yazılmış satırların hangisinin avans hangisinin hasta olduğu satırdan anlaşılmıyordu; dev'deki avans-şekilli satırlar silindi, gerçek hasta satırları yerinde. Müşteride 753 hiç yayınlanmadığı için sorun yok. | Kapalı sayılabilir; kayıt için burada. |
| 4.4 | **Eski 10 "vazgeçildi" bildirim satırı.** 13-16 Eylül'den kalma randevu/panik bildirimleri, alıcıları gerçek görünen telefon numaraları. Sağlayıcı tanımlanınca **yeniden gönderilmesi istenmiyor**; durum 6 oldukları için işçi almıyor. | Bugün de **10**. Silinecekse ayrı karar. |
| 4.5 | **`entegrasyon_hesap.sifre` düz metin.** SMTP/SMS şifresi şifrelenmeden saklanıyor (`BildirimHesaplari` doğrudan okuyor). En azından uygulama şifresi (app password) kullanılmalı; kalıcı çözüm şifreleme. | **1.1** yapılmadan önce karara bağlanmalı - ilk gerçek şifre girildiği anda borç canlıya geçer. |
| 4.6 | ~~**Para biçimi yerel ayara (`lc_numeric`) bağlıydı.**~~ — **769/770/771'de kapandı.** Biçim `fn_para_tr`de: ayıraç şablonda literal, sonra `translate`. `fn_ebelge_html` (769), `fn_belge_talep_yazi` (770), `fn_lab_kultur_ozet` (771) bağlandı. | 436'da bağlarken **gizli bir kusur** çıktı: `translate` yalnız virgülü çeviriyordu, küsuratlı sayıda ondalık ayıracı grup ayıracıyla aynı işarete düşüyordu (`1.234.5`). Testi de eklendi. Yürürlükte `G`/`D` kullanan nesne kalmadı. |

---

## 5. Onay omurgası — kapandı

Kayıt için: 738-768 arasında tamamlandı, açık iş kalmadı.

- **Sekiz akış** tek motorda (`onay_akis`: **8 kayıt**): satınalma talebi, izin,
  masraflı onarım, avans, iskonto, doküman sürümü, masraf beyanı, belge talebi.
- Modüllerin kendi zincir tabloları düştü (`satinalma_onay`, `dokuman_onay`,
  `dokuman_onay_adim`, `dokuman_akis`, `dokuman_akis_adim`).
- Kısmi onay (ölçüyü düşürerek onaylama) karar ucunun genel alanı.
- Gelen kutusu, vekâlet, hatırlatma, bildirim ve gecikme takibi ortak.
- `LogTabloIdTestleri` yeni çakışmayı derlemeden değil testten geri çeviriyor.
- Sözlü onayın yazılı teyidi takip ediliyor (`v_onay_sozlu`,
  `onay.sozlu_takip`, `/adim/{id}/yaziliya`).
- Masraf beyanında **ödeme bilerek yok** (kullanıcı kararı, 17.09.2026):
  zincir onayla biter, muhasebe dışarıda öder. Bu bir eksik değil, karar -
  ödeme izi istenirse avanstaki `kasa_islem` deseni hazır.
- Belge talebinde **otomatik onay ayarla** (`ik.belge_talep_otomatik`,
  varsayılan açık): zincir hiç kurulmaz, talep onaylı doğar. Red yolu açık.
- Belge talebinde asıl iş onay değil **hazırlamak**: 768'den beri "hazırlandı"
  bir işaret değil, üretilmiş ve dondurulmuş metin.
