-- ============================================================================
--  Gentegre AI — Ayar yardim metinleri ("?" balonlari)
--  157_ayar_yardim.sql
--
--  GENEL KURAL (kullanici): "opsiyonlarda edit'in yanina (?) isareti koy ve
--  aciklamayi icine yaz." Aciklama ekranin altinda paragraf olarak durmaz;
--  alanin yanindaki (?) ikonuna basilinca cikar.
--
--  Ikon metni OLMAYAN anahtarda HIC gorunmez (YardimIkonu): bos balon acan bir
--  "?" gurultudur. Bu yuzden 37 ayar sessizce ikonsuz kaliyordu - hepsi burada.
--
--  YENI AYAR EKLEYEN: `public.referans`a satir eklerken buraya da bir yardim
--  metni yaz; yoksa kullanici alanin ne ise yaradigini ekranda goremez.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function pg_temp.yardim(p_anahtar text, p_baslik text, p_metin text)
returns void language plpgsql as $$
begin
    insert into public.help (anahtar, baslik, metin)
    values ('ayar.' || p_anahtar, p_baslik, p_metin)
    on conflict (anahtar, dil) do update
       set baslik = excluded.baslik, metin = excluded.metin;
end $$;

-- ------------------------------------------------------------ belge girisi --
select pg_temp.yardim('belge.duzenleme_gun', 'Belge düzenleme süresi',
 'Kesilmiş bir belge, belge tarihinden kaç gün sonrasına kadar düzenlenebilir. '
 'Süre dolduktan sonra belge kilitlenir; düzeltmek için iptal edip yeniden kesmek gerekir. '
 '0 = düzenleme tamamen kapalı, -1 = süre sınırı yok. '
 'e-Belge gönderilmiş ya da faturalanmış belge bu süreden bağımsız olarak kilitlidir.');

select pg_temp.yardim('belge.satis.vade_gun', 'Satışta varsayılan vade',
 'Yeni satış belgesi açıldığında vade alanına önerilen gün sayısı. '
 'Kartta değiştirilebilir; buradaki değer yalnızca başlangıç önerisidir.');
select pg_temp.yardim('belge.alis.vade_gun', 'Alışta varsayılan vade',
 'Yeni alış belgesi açıldığında vade alanına önerilen gün sayısı. '
 'Kartta değiştirilebilir.');
select pg_temp.yardim('belge.satis.varsayilan_seri', 'Satışta varsayılan seri',
 'Yeni satış belgesinin seri alanına önerilen değer. '
 'Numaranın kendisi (ön ek, başlangıç, hane) buradan DEĞİL, '
 'Genel Ayarlar › Belge No ekranından gelir.');
select pg_temp.yardim('belge.alis.varsayilan_seri', 'Alışta varsayılan seri',
 'Yeni alış belgesinin seri alanına önerilen değer. Alış faturasının numarası '
 'tedarikçinin numarasıdır; bizim serimiz yalnızca iç takip içindir.');

-- --------------------------------------------------------------- kasa ------
select pg_temp.yardim('kasa.duzenleme_gun', 'Tahsilat / ödeme kilitlenmesi',
 'Gerçekleşmiş tahsilat/ödeme, işlem tarihinden bu kadar gün sonra kilitlenir ve '
 'düzeltilemez; düzeltme yerine iptal edilip yeniden girilir. '
 '0 = düzeltme tamamen kapalı, -1 = süre sınırı yok. '
 'Kapanmış muhasebe dönemi bu ayardan bağımsız olarak her zaman kilitlidir.');
select pg_temp.yardim('kasa.kurus_farki_siniri', 'Kuruş farkı sınırı',
 'Döviz dönüşümünde iki taraf arasında kalan küçük fark bu tutara kadar '
 'otomatik olarak kur farkı hesabına yazılır. Daha büyük farklar işlemi durdurur - '
 'çünkü o artık yuvarlama değil, girilen tutarlarda bir hatadır.');

-- ------------------------------------------------- e-Belge / entegratör -----
select pg_temp.yardim('ebelge.aktif', 'e-Belge kullanımda (ana şalter)',
 'Bu kutu KAPALIYKEN hiçbir belge GİB''e gönderilmez; e-Fatura, e-Arşiv, '
 'e-İrsaliye ve e-SMM ayarları kaydedilir ama işlemez. '
 'AÇIKKEN satış faturasının numarasını biz vermeyiz: numara alanı "0" kalır ve '
 'gerçek numarayı entegratör verir. Kapalıyken numara Belge No şablonundan gelir.');
select pg_temp.yardim('ebelge.entegrator', 'Entegratör',
 'e-Belge gönderimini yapan özel entegratör firması. '
 'Servis adresleri her belge türünün kendi sekmesinde tanımlanır.');
select pg_temp.yardim('ebelge.vkn', 'Vergi / kimlik numarası',
 'e-Belge gönderiminde göndericiyi tanıtan vergi numarası (tüzel kişide 10, '
 'gerçek kişide 11 hane). Entegratördeki hesabın tanımlı olduğu numarayla aynı olmalı.');
select pg_temp.yardim('ebelge.kullanici', 'Entegratör kullanıcısı',
 'Entegratörün verdiği kullanıcı adı. Bu hesabın e-Belge dışında bir yetkisi olmamalı.');
select pg_temp.yardim('ebelge.sifre', 'Entegratör şifresi',
 'Entegratör hesabının şifresi. DİKKAT: şifre sunucuda düz metin saklanır, '
 'yalnızca ekranda gizlenir. Şifreyi değiştirdiğinizde buradan da güncelleyin, '
 'yoksa gönderim sessizce başarısız olur.');
select pg_temp.yardim('ebelge.test_aktif', 'Test ortamı',
 'Açıkken belgeler entegratörün TEST servisine gider; kesilen belgeler RESMİ DEĞİLDİR '
 've GİB''e ulaşmaz. Kurulum doğrulandıktan sonra kapatmayı unutmayın - '
 'açık kalırsa müşteriye giden fatura hiç düzenlenmemiş sayılır.');
select pg_temp.yardim('ebelge.test_kullanici', 'Test kullanıcısı',
 'Test ortamı için ayrı kullanıcı adı. Test kapalıyken kullanılmaz.');
select pg_temp.yardim('ebelge.test_sifre', 'Test şifresi',
 'Test ortamı şifresi (düz metin saklanır). Test kapalıyken kullanılmaz.');

-- ------------------------------------------------------------- e-Fatura ----
select pg_temp.yardim('efatura.gelen_al', 'Gelen faturaları al',
 'Açıkken tedarikçilerin kestiği e-Faturalar entegratörden düzenli olarak çekilir '
 've alış belgesi olarak listelenir.');
select pg_temp.yardim('efatura.senaryo', 'Varsayılan senaryo',
 'Yeni e-Faturanın GİB profili. TEMEL: alıcı yanıt veremez, fatura gönderildiği anda kabul edilmiş sayılır. '
 'TİCARİ: alıcı 8 gün içinde kabul/ret yanıtı verebilir. '
 'İLAÇ / TIBBİ CİHAZ: ilaç ve tıbbi cihaz satışının zorunlu profili. '
 'Belge kartından tek tek değiştirilebilir.');
select pg_temp.yardim('efatura.ihracat_gonder', 'İhracat faturaları',
 'Açıkken ihracat faturaları da e-Fatura olarak gönderilir (ihracat profili). '
 'Kapalıysa ihracat faturası kağıt/başka yolla düzenlenir.');
select pg_temp.yardim('efatura.uretim_url', 'Üretim servis adresi',
 'Entegratörün CANLI e-Fatura servis adresi. Test kutusu kapalıyken bu adres kullanılır.');
select pg_temp.yardim('efatura.test_url', 'Test servis adresi',
 'Entegratörün test e-Fatura servis adresi. Yalnızca "Test ortamı" açıkken kullanılır.');
select pg_temp.yardim('efatura.sabit_notlar', 'Sabit notlar',
 'Her e-Faturaya otomatik eklenen not metni (banka bilgisi, yasal ibare gibi). '
 'Belgeye özel notlar bunun yerine geçmez, ikisi birlikte gider.');

-- -------------------------------------------------------------- e-Arşiv ----
select pg_temp.yardim('earsiv.aktif', 'e-Arşiv',
 'e-Fatura mükellefi OLMAYAN müşterilere kesilen faturalar e-Arşiv olarak düzenlenir. '
 'Kapalıysa bu müşterilere kağıt fatura kesilir.');
select pg_temp.yardim('earsiv.uretim_url', 'Üretim (giden) adresi',
 'Canlı e-Arşiv gönderim adresi.');
select pg_temp.yardim('earsiv.gelen_url', 'Üretim (gelen) adresi',
 'Canlı e-Arşiv sorgulama/gelen belge adresi.');
select pg_temp.yardim('earsiv.test_url', 'Test (giden) adresi',
 'Test e-Arşiv gönderim adresi. Yalnızca "Test ortamı" açıkken kullanılır.');
select pg_temp.yardim('earsiv.sabit_notlar', 'Sabit notlar',
 'Her e-Arşiv faturasına otomatik eklenen not metni.');

-- ----------------------------------------------------------- e-İrsaliye ----
select pg_temp.yardim('eirsaliye.aktif', 'e-İrsaliye',
 'Açıkken satış irsaliyeleri GİB''e elektronik gönderilir ve irsaliye numarasını '
 'entegratör verir (numara alanı "0" kalır). Kapalıyken irsaliye numarası '
 'Belge No şablonundan gelir. Ana şalter (e-Belge kullanımda) kapalıysa bu ayar işlemez.');
select pg_temp.yardim('eirsaliye.gelen_al', 'Gelen irsaliyeleri al',
 'Açıkken tedarikçilerin gönderdiği e-İrsaliyeler entegratörden çekilir.');
select pg_temp.yardim('eirsaliye.gib_alias', 'GİB portal adresi (alias)',
 'e-İrsaliye gönderiminde kullanılan GİB etiket adresi '
 '(örn. urn:mail:defaultgb@firma.com.tr). Entegratörün tanımladığı etiketle aynı olmalı.');
select pg_temp.yardim('eirsaliye.uretim_url', 'Üretim servis adresi',
 'Canlı e-İrsaliye servis adresi.');
select pg_temp.yardim('eirsaliye.test_url', 'Test servis adresi',
 'Test e-İrsaliye servis adresi. Yalnızca "Test ortamı" açıkken kullanılır.');
select pg_temp.yardim('eirsaliye.sabit_notlar', 'Sabit notlar',
 'Her e-İrsaliyeye otomatik eklenen not metni.');

-- ---------------------------------------------------------------- e-SMM ----
select pg_temp.yardim('esmm.aktif', 'e-Serbest Meslek Makbuzu',
 'Serbest meslek erbabının düzenlediği makbuzun elektronik hali. '
 'Yalnızca serbest meslek faaliyeti varsa açılır.');
select pg_temp.yardim('esmm.uretim_url', 'Üretim servis adresi', 'Canlı e-SMM servis adresi.');
select pg_temp.yardim('esmm.test_url', 'Test servis adresi',
 'Test e-SMM servis adresi. Yalnızca "Test ortamı" açıkken kullanılır.');
select pg_temp.yardim('esmm.sabit_notlar', 'Sabit notlar',
 'Her e-SMM''ye otomatik eklenen not metni.');

-- ------------------------------------------------------------- guvenlik ----
select pg_temp.yardim('guvenlik.parola_gecerlilik_gun', 'Parola geçerlilik süresi',
 'Parola bu kadar gün sonra süresi dolmuş sayılır ve kullanıcıdan yenisi istenir. '
 '0 = parola hiç eskimez.');

do $$
declare v_eksik integer;
begin
    select count(*) into v_eksik
      from public.referans r
      left join public.help h on h.anahtar = 'ayar.' || r.anahtar
     where h.anahtar is null;
    raise notice '157 tamam: yardim metni olmayan ayar sayisi = %', v_eksik;
end $$;
