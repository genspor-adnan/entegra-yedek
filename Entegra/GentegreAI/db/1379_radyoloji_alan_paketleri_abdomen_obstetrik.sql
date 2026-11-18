-- =============================================================================
--  1379 - RADYOLOJİ HAZIR ALAN PAKETLERİ: TÜM ABDOMEN USG + OBSTETRİK USG; MEME MR -> BI-RADS YAPISAL
--
--  Kullanıcı (18.11.2026): "radyoloji için kontrol et yapısal raporlar hangileri daha da eklenebilir mi" ->
--  "1, 2 ve 3'ü yap". KOSUYOLU istem sıklığında paketi olmayan en çok tetkik.
--
--  ABDOMEN-US: karaciğer boyutu / ekojenite (hepatosteatoz derecesi) / fokal lezyon, safra kesesi ve yolları,
--    pankreas, dalak, böbrekler, mesane, serbest sıvı. Hesap yok (seçimler hekimin).
--  OBSTETRIK-US: gebelik haftası, kalp atımı, prezentasyon, CRL, BPD / HC / AC / FL, tahmini fetal ağırlık
--    (web: Hadlock 1985 formülü - HC+AC+FL, yoksa BPD+AC+FL, yoksa AC+FL), persentil (HEKİM seçer), amniyon
--    sıvısı AFI / en derin cep ve değerlendirme (web: ACOG eşikleri - AFI <= 5 ya da en derin cep < 2 cm
--    oligohidramnios; AFI >= 24 ya da en derin cep >= 8 cm polihidramnios), plasenta.
--  Desen yalnız ŞABLON ADINA bakar (fn_rad_alan_paketi_uyar): abdomen paketinde adında US / USG geçmesi aranır -
--    "TÜM BATIN (ERKEK)" adı MR şablonunda da var. Adında modalite olmayan USG şablonuna paket kartta "Paketten
--    ekle" ile eklenir. Obstetrik paket tek fetüs içindir (ikiz şablonlar hariç).
--  MEME MR: BI-RADS formu MR'ı destekliyor (1194, web birads.ts 'mr') ama şablonlar işaretli değildi. Adında MEME
--    ve MR geçen, modalitesi MR, henüz yapısal olmayan şablonlar yapisal_tur = 1 alır - yalnız "Giriş = Yapısal"
--    seçeneğini açar, metne dokunmaz. Paket içerikleri kurumun düzenleyebileceği başlangıç kümesidir. İdempotent.
-- =============================================================================
begin;
create temp table _p (kod varchar(40), ad varchar(120), modalite smallint, bolge smallint, desen varchar(300),
                      haric varchar(300), aciklama text) on commit drop;
insert into _p values
  ('ABDOMEN-US', 'Tüm / üst abdomen USG', 3, 3,
   '(ABDOMEN|BATIN).*(^|[^A-Z])(US|USG|ULTRASON)([^A-Z]|$)|(^|[^A-Z])(US|USG)([^A-Z]|$).*(ABDOMEN|BATIN)',
   'DOPPLER|(^|[^A-Z])(BT|MR|MRG)([^A-Z]|$)',
   'Karaciğer boyutu, ekojenite (hepatosteatoz derecesi), fokal lezyon; safra kesesi ve yolları, pankreas, dalak, böbrekler, mesane, serbest sıvı.'),
  ('OBSTETRIK-US', 'Obstetrik USG (biyometri)', 3, 3, 'OBSTE?R?TRIK|GEBELIK|FETAL|BIYOMETRI',
   'IKIZ|EKO ?KARDIYO',
   'Gebelik haftası, kalp atımı, prezentasyon, CRL, BPD / HC / AC / FL, tahmini fetal ağırlık (Hadlock, otomatik), persentil, AFI / en derin cep ve değerlendirme (otomatik), plasenta.');
insert into public.radyoloji_alan_paket (kod, ad, modalite, bolge, desen, haric_desen, aciklama)
select kod, ad, modalite, bolge, desen, haric, aciklama from _p
on conflict (kod) do update set ad = excluded.ad, modalite = excluded.modalite, bolge = excluded.bolge,
       desen = excluded.desen, haric_desen = excluded.haric_desen, aciklama = excluded.aciklama;

create temp table _a (paket varchar(40), sira smallint, grup varchar(40), kod varchar(40), ad varchar(80), tip smallint,
                      secenek varchar(400), kalip varchar(300), sifir varchar(300), birim varchar(20)) on commit drop;
insert into _a values
-- ======================================================== TÜM ABDOMEN USG
  ('ABDOMEN-US', 1, 'Karaciğer', 'kc_boyut', 'Karaciğer boyutu (MKL)', 2, '',
   'Karaciğer midklaviküler hatta {değer} mm ölçülmüştür.', '', 'mm'),
  ('ABDOMEN-US', 2, 'Karaciğer', 'kc_ekojenite', 'Parankim ekojenitesi', 1,
   'Normal|Grade 1 hepatosteatoz|Grade 2 hepatosteatoz|Grade 3 hepatosteatoz|Kaba heterojen (kronik parankim hastalığı)',
   'Karaciğer parankiminde {değer} ile uyumlu görünüm izlenmiştir.', 'Karaciğer parankim ekojenitesi normaldir.', ''),
  ('ABDOMEN-US', 3, 'Karaciğer', 'kc_lezyon', 'Fokal lezyon', 1,
   'Yok|Basit kist|Hemanjiyom ile uyumlu lezyon|Solid lezyon (ileri inceleme önerilir)|Multipl lezyon',
   'Karaciğerde {değer} izlenmiştir.', 'Karaciğerde fokal lezyon izlenmemiştir.', ''),
  ('ABDOMEN-US', 4, 'Karaciğer', 'kc_lezyon_boyut', 'Lezyon boyutu', 5, '', 'Lezyon {değer} mm boyutundadır.', '', ''),
  ('ABDOMEN-US', 10, 'Safra', 'sk', 'Safra kesesi', 1,
   'Normal|Kolelitiazis|Safra çamuru (sludge)|Polip|Duvar kalınlaşması|Akut kolesistit bulguları|Kolesistektomi sonrası',
   'Safra kesesi değerlendirmesi: {değer}.', 'Safra kesesi normal görünümdedir.', ''),
  ('ABDOMEN-US', 11, 'Safra', 'sk_tas_boyut', 'En büyük taş / polip', 2, '', 'En büyüğü {değer} mm boyutundadır.', '', 'mm'),
  ('ABDOMEN-US', 12, 'Safra', 'koledok', 'Koledok çapı', 2, '', 'Koledok çapı {değer} mm ölçülmüştür.', '', 'mm'),
  ('ABDOMEN-US', 13, 'Safra', 'safra_yolu', 'İntrahepatik safra yolları', 1, 'Normal|Dilate',
   'İntrahepatik safra yolları dilatedir.', 'İntrahepatik safra yolları normal çaptadır.', ''),
  ('ABDOMEN-US', 20, 'Pankreas / dalak', 'pankreas', 'Pankreas', 1,
   'Normal|Görüntülenemedi (barsak gazı)|Hipoekoik ödemli|Kistik lezyon|Solid lezyon',
   'Pankreas: {değer}.', 'Pankreas izlenebilen kesimleri normaldir.', ''),
  ('ABDOMEN-US', 21, 'Pankreas / dalak', 'dalak', 'Dalak boyutu', 2, '', 'Dalak uzun aksı {değer} mm ölçülmüştür.', '', 'mm'),
  ('ABDOMEN-US', 22, 'Pankreas / dalak', 'dalak_parankim', 'Dalak parankimi', 1, 'Normal|Splenomegali|Fokal lezyon|Aksesuar dalak',
   'Dalakta {değer} izlenmiştir.', 'Dalak parankimi homojendir.', ''),
  ('ABDOMEN-US', 30, 'Böbrekler', 'sag_bobrek', 'Sağ böbrek', 1,
   'Normal|Grade 1 hidronefroz|Grade 2 hidronefroz|Grade 3 hidronefroz|Taş|Basit kist|Parankim ekojenitesi artmış',
   'Sağ böbrekte {değer} izlenmiştir.', 'Sağ böbrek boyut ve parankim ekojenitesi normaldir.', ''),
  ('ABDOMEN-US', 31, 'Böbrekler', 'sol_bobrek', 'Sol böbrek', 1,
   'Normal|Grade 1 hidronefroz|Grade 2 hidronefroz|Grade 3 hidronefroz|Taş|Basit kist|Parankim ekojenitesi artmış',
   'Sol böbrekte {değer} izlenmiştir.', 'Sol böbrek boyut ve parankim ekojenitesi normaldir.', ''),
  ('ABDOMEN-US', 40, 'Pelvis / periton', 'mesane', 'Mesane', 1, 'Normal|Duvar kalınlaşması|Taş|Kitle|Yeterince dolu değil',
   'Mesane: {değer}.', 'Mesane duvarı düzgün, lümeni anekoiktir.', ''),
  ('ABDOMEN-US', 41, 'Pelvis / periton', 'serbest_sivi', 'Serbest sıvı', 1, 'Yok|Minimal|Orta|Fazla',
   'Batın içinde {değer} miktarda serbest sıvı izlenmiştir.', 'Batın içinde serbest sıvı izlenmemiştir.', ''),
-- ======================================================== OBSTETRİK USG
  ('OBSTETRIK-US', 1, 'Gebelik', 'gebelik_hafta', 'Gebelik haftası (SAT / ilk USG)', 2, '',
   'Son adet tarihine / ilk USG''ye göre gebelik {değer} haftalıktır.', '', 'hafta'),
  ('OBSTETRIK-US', 2, 'Gebelik', 'kalp_atimi', 'Fetal kalp atımı', 1, 'Var|Yok',
   'Fetal kalp atımı {değer}.', '', ''),
  ('OBSTETRIK-US', 3, 'Gebelik', 'fkh', 'Fetal kalp hızı', 2, '', 'Fetal kalp hızı {değer} atım/dk ölçülmüştür.', '', 'atım/dk'),
  ('OBSTETRIK-US', 4, 'Gebelik', 'prezentasyon', 'Prezentasyon', 1, 'Baş|Makat|Transvers|Değişken',
   'Fetüs {değer} prezentasyondadır.', '', ''),
  ('OBSTETRIK-US', 10, 'Biyometri', 'crl', 'CRL (baş-popo mesafesi)', 2, '', 'CRL {değer} mm ölçülmüştür.', '', 'mm'),
  ('OBSTETRIK-US', 11, 'Biyometri', 'bpd', 'BPD', 2, '', 'BPD {değer} mm.', '', 'mm'),
  ('OBSTETRIK-US', 12, 'Biyometri', 'hc', 'HC (baş çevresi)', 2, '', 'HC {değer} mm.', '', 'mm'),
  ('OBSTETRIK-US', 13, 'Biyometri', 'ac', 'AC (karın çevresi)', 2, '', 'AC {değer} mm.', '', 'mm'),
  ('OBSTETRIK-US', 14, 'Biyometri', 'fl', 'FL (femur uzunluğu)', 2, '', 'FL {değer} mm.', '', 'mm'),
  ('OBSTETRIK-US', 15, 'Biyometri', 'efw', 'Tahmini fetal ağırlık (Hadlock)', 2, '',
   'Hadlock formülüne göre tahmini fetal ağırlık {değer} gramdır.', '', 'g'),
  ('OBSTETRIK-US', 16, 'Biyometri', 'efw_persentil', 'Ağırlık persentili', 1,
   '10-90. persentil (gebelik haftasıyla uyumlu)|10. persentilin altında (küçük)|90. persentilin üstünde (büyük)',
   'Tahmini fetal ağırlık {değer} ile uyumludur.', '', ''),
  ('OBSTETRIK-US', 20, 'Amniyon / plasenta', 'afi', 'AFI (amniyotik sıvı indeksi)', 2, '', 'AFI {değer} cm ölçülmüştür.', '', 'cm'),
  ('OBSTETRIK-US', 21, 'Amniyon / plasenta', 'sdp', 'En derin cep', 2, '', 'En derin amniyon cebi {değer} cm.', '', 'cm'),
  ('OBSTETRIK-US', 22, 'Amniyon / plasenta', 'amniyon', 'Amniyon sıvısı', 1, 'Normal|Oligohidramnios|Polihidramnios',
   'Amniyon sıvısı miktarı {değer} ile uyumludur.', 'Amniyon sıvısı miktarı normaldir.', ''),
  ('OBSTETRIK-US', 23, 'Amniyon / plasenta', 'plasenta', 'Plasenta yerleşimi', 1,
   'Anterior|Posterior|Fundal|Lateral|Aşağı yerleşimli (low-lying)|Plasenta previa',
   'Plasenta {değer} yerleşimlidir.', '', ''),
  ('OBSTETRIK-US', 24, 'Amniyon / plasenta', 'plasenta_grade', 'Plasenta grade', 1, 'Grade 0|Grade 1|Grade 2|Grade 3',
   'Plasenta {değer} olarak değerlendirilmiştir.', '', '');

delete from public.radyoloji_alan_paket_alan a using public.radyoloji_alan_paket p, _p
 where a.paket_id = p.id and p.kod = _p.kod;
insert into public.radyoloji_alan_paket_alan (paket_id, sira, grup, alan_kod, alan_ad, tip, secenekler, birim,
                                              kalip, sifir_kalip, hedef_bolum, zorunlu, rapora_bas)
select p.id, a.sira, a.grup, a.kod, a.ad, a.tip, a.secenek, a.birim, a.kalip, a.sifir, 'Bulgular', 0, 0
  from _a a join public.radyoloji_alan_paket p on p.kod = a.paket;

-- MEME MR -> BI-RADS yapısal (yalnız işaretsiz, adı MEME + MR, modalite MR).
create temp table _meme on commit drop as
select id from public.radyoloji_sablon
 where coalesce(yapisal_tur, 0) = 0 and modalite = 2
   and translate(upper(ad), 'ÇĞİÖŞÜ', 'CGIOSU') ~ 'MEME|MAMMA|BREAST'
   and translate(upper(ad), 'ÇĞİÖŞÜ', 'CGIOSU') ~ '(^|[^A-Z])(MR|MRG|MRI)([^A-Z]|$)';
update public.radyoloji_sablon set yapisal_tur = 1, degistirme_tarihi = now() where id in (select id from _meme);
do $$ begin raise notice '1379: % meme MR şablonu BI-RADS yapısal girişe açıldı.', (select count(*) from _meme); end $$;

commit;
