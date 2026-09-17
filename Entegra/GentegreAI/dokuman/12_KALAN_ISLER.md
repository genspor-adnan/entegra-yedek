# Kalan İşler

Bu liste `00_TARIHCE.md`'deki her turun sonuna dağılmış "Kalan" notlarının
toplanmış ve **canlı veriyle doğrulanmış** hâlidir. Tarihçe *ne yapıldığını*
anlatır; burası *ne yapılmadığını*.

Son güncelleme: **17.09.2026**, `db/766` sonrası.

Doğrulama yöntemi: maddeler dev veritabanına (docker `gentegre-pg18`) ve
koda bakılarak yazıldı; sayılar o anki gerçek durumdur. Bir maddeyi
kapatmadan önce sayının hâlâ geçerli olduğu kontrol edilmeli.

---

## 1. Kurulum adımları (kod işi yok)

Bunlar kodda eksik olan bir şey değil; kurulumda girilecek veri.

| # | İş | Bugünkü durum |
|---|---|---|
| 1.1 | **Bildirim sağlayıcısı tanımlanmalı** — Genel Ayarlar > Entegrasyon Hesapları > "E-Posta (SMTP) Sağlayıcı" ya da "SMS Sağlayıcı". `ayarlar.bildirim_kanal` zorunlu (1 SMS · 2 e-posta). | `bildirim_kanal` ayarlı hesap: **0**. Hesap yokken gönderim başarısız oluyor ve `bildirim_log`a sebep yazılıyor. |
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
| 3.3 | **Avans mahsubu bordroya bağlanmalı.** Bordro modülü olmadığı için kesintiler ekrandan elle işaretleniyor. `personel_avans_kesinti.donem` (yyyy-mm) bordro gelince bağlanmak üzere hazır. | — |
| 3.4 | **Onaylanan izinde randevuların toplu taşınması / iptali.** Bugün izin onaylanınca hekimin planı kapanıyor ve yeni randevu engelleniyor, ama **o güne daha önce alınmış randevular yerinde kalıyor**. | `randevu.izinli_hekim` ayarı **0** (engelle). |
| 3.5 | **Resmî tatilde klinik planını kapatma ayarı.** Tatil tablosu var, plana etkisi yok. | `referans`ta tatille ilgili ayar: **yok**. |
| 3.6 | **Onay akışı ayarları mockup'ının kalan sekmeleri.** `Ekranlar/Ayarlar/onay_akis_ayarlari.html` beş sekmeli; karşılığı olarak akış tanımı (`/onay-akis`) ve vekâlet (`/onay-vekalet`) ekranları yapıldı. Kalan sekmeler yapılmadı. | — |
| 3.7 | **Masraf beyanında fiş/fatura GÖRSELİ bağlanmıyor.** 764 belge NUMARASINI zorunlu kıldı ama görselin kendisi yüklenemiyor. Doküman modülü `kaynak` + `kaynak_id` ile her kayda ek bağlayabiliyor; eksik olan bu yolu masraf kartına açmak. Numara denetim için yeter demiyoruz - fişin fotoğrafı olmadan uzaktan onaylayan âmir belgeyi göremiyor. | — |
| 3.8 | **Belge talebinde yazının KENDİSİ üretilmiyor.** 765 talebi ve hazırlık/teslim akışını izliyor; metni İK elle yazıyor. Şablondan (kurum anteti + personel bilgisi + amaca göre metin) PDF üretmek ayrı bir iş - form motoru (740) ve doküman modülü ikisi de hazır, bağlanmadı. | Bugün "hazırlandı" bir işaret, üretilmiş bir belge değil. |
| 3.9 | **`beyan_no` / `talep_no` / `avans_no` üretilmiyor** - üçü de boş kalıyor. Numara üretme altyapısı VAR (`fn_numara_sablonu_bul`, `fn_numara_onek_yilli`, `numara_sablonu` tablosu) ama bu üç modül kullanmıyor; listeler ve gelen kutusu `#id`'ye düşüyor. | `v_onay_kutusu` zaten `coalesce(nullif(no,''), '#'||id)` ile yazılmıştı - numara gelince kendiliğinden görünür. |

---

## 4. Teknik borç

| # | İş | Not |
|---|---|---|
| 4.1 | **`LogTabloId` modül-içi gruplamaları.** 757 modüller-arası çakışmaların tamamını ayıkladı; **7 kod** bilinçli gruplama olarak muafiyet listesinde (`LogTabloIdTestleri.GruplananKodlar`): göz ölçümleri, göz işlemleri, göz görüntüleme, yatış izlemleri, yatış order, diş seansı, medula raporu. Bu kodlarda `tablo_id + kayit_id` hâlâ tek kaydı göstermiyor. | Çakışma değil, tercih. Ayırmak 20+ yeni numara demek. |
| 4.2 | **757'de taşınamayan üç log bağı.** `kullanici_sube` ve `zamanli_is` tablolarında `id` kolonu yok; bir log satırının onlara ait olup olmadığı ölçülemiyor. Kod tarafında numaraları ayrıldı (904 → 1297, 962 → 1289) ama **geçmiş satırlar eski numarada**. | Aynı numaradaki `lab_istem_satir` da bu yüzden taşınmadı. |
| 4.3 | **755'te taşınamayan avans log satırları.** 907 ile yazılmış satırların hangisinin avans hangisinin hasta olduğu satırdan anlaşılmıyordu; dev'deki avans-şekilli satırlar silindi, gerçek hasta satırları yerinde. Müşteride 753 hiç yayınlanmadığı için sorun yok. | Kapalı sayılabilir; kayıt için burada. |
| 4.4 | **Eski 10 "vazgeçildi" bildirim satırı.** 13-16 Eylül'den kalma randevu/panik bildirimleri, alıcıları gerçek görünen telefon numaraları. Sağlayıcı tanımlanınca **yeniden gönderilmesi istenmiyor**; durum 6 oldukları için işçi almıyor. | Silinecekse ayrı karar. |
| 4.5 | **`entegrasyon_hesap.sifre` düz metin.** SMTP/SMS şifresi şifrelenmeden saklanıyor (`BildirimHesaplari` doğrudan okuyor). En azından uygulama şifresi (app password) kullanılmalı; kalıcı çözüm şifreleme. | — |

---

## 5. Onay omurgası — kapandı

Kayıt için: 738-763 arasında tamamlandı, açık iş kalmadı.

- Altı akış tek motorda: satınalma talebi, izin, masraflı onarım, avans,
  iskonto, doküman sürümü (`onay_akis`: **6 kayıt**).
- Modüllerin kendi zincir tabloları düştü (`satinalma_onay`, `dokuman_onay`,
  `dokuman_onay_adim`, `dokuman_akis`, `dokuman_akis_adim`).
- Kısmi onay (ölçüyü düşürerek onaylama) karar ucunun genel alanı.
- Gelen kutusu, vekâlet, hatırlatma, bildirim ve gecikme takibi ortak.
- `LogTabloIdTestleri` yeni çakışmayı derlemeden değil testten geri çeviriyor.
- Sözlü onayın yazılı teyidi takip ediliyor (`v_onay_sozlu`,
  `onay.sozlu_takip`, `/adim/{id}/yaziliya`).
- **Sekiz akış** (764/765 ile): satınalma talebi, izin, masraflı onarım,
  avans, iskonto, doküman sürümü, **masraf beyanı**, **belge talebi**.
- Masraf beyanında **ödeme bilerek yok** (kullanıcı kararı, 17.09.2026):
  zincir onayla biter, muhasebe dışarıda öder. Bu bir eksik değil, karar -
  ödeme izi istenirse avanstaki `kasa_islem` deseni hazır.
- Belge talebinde **otomatik onay ayarla** (`ik.belge_talep_otomatik`,
  varsayılan açık): zincir hiç kurulmaz, talep onaylı doğar. Red yolu açık.
