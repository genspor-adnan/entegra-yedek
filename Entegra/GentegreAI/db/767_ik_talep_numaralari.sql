-- ============================================================================
--  Gentegre AI — AVANS / MASRAF / BELGE TALEBİ NUMARALARI
--  767_ik_talep_numaralari.sql
--
--  Kullanıcı: "beyan_no talep_no avans_no numaralarını üret" +
--             "genel opsiyona ekle numara kısmına ekle".
--
--  753/764/765 üç tabloya `avans_no` · `beyan_no` · `talep_no` kolonu koymuş
--  ama hiçbirini DOLDURMAMIŞTI: üçü de boş kalıyor, listeler ve gelen kutusu
--  `#id`'ye düşüyordu. Numara üretme altyapısı 152'den beri duruyor
--  (`numara_sablonu` + `fn_numara_kimlik_uret`); eksik olan yalnız tür kodu
--  ve şablon satırıydı.
--
--  ============ TÜR KODLARI 906-908 ====================================
--  `numara_sablonu.tur` belge/kasa türü kataloğudur; BELGE OLMAYAN kayıtlar
--  358'den beri 900+ kendi kodunu alıyor (900 hasta dosya, 901 lab,
--  902 muayene, 903 radyoloji, 904 e-Nabız, 905 reçete). Sıradaki üç boş
--  numara alındı:
--
--      906 Avans No · 907 Masraf Beyan No · 908 Belge Talep No
--
--  ============ AYARLAR EKRANINDA GÖRÜNÜR ==============================
--  `v_numara_turu_ik` görünümü Genel Ayarlar › Numaralama sekmesine yeni bir
--  grid olarak bağlanıyor (`numara-ik` kartı). Şablonu kurum kendisi
--  düzenler: ön ek, hane, başlangıç, şube - ve isterse "elle yazsın" der.
--
--  Ön ekler yıl İÇERMİYOR: sayaç sürekli artar. Yıllı ön ek (`AV-{YYYY}-`)
--  isteyen kurum ekranda değiştirir; `fn_numara_onek_yilli` ön ekte yıl
--  görürse sayacı her yıl baştan akıtır. Varsayılanı yılsız seçtik çünkü
--  bu üç talep türünde numara yıl içinde değil ÖMÜR BOYU tekil olmalı -
--  personel "geçen yılki 12 numaralı avansım" diyebilmeli.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------- 1
--  TÜR LİSTESİ (ekranın "Numara Türü" açılır listesi)
create or replace view public.v_numara_turu_ik as
select 906 as id, 'Avans No'::varchar          as ad, 1::smallint as aktif
union all
select 907,       'Masraf Beyan No'::varchar,       1::smallint
union all
select 908,       'Belge Talep No'::varchar,        1::smallint;

comment on view public.v_numara_turu_ik is
  'IK talep numaralari (767): 906 avans, 907 masraf beyani, 908 belge talebi.';

-- ---------------------------------------------------------------------- 2
--  ŞABLONLAR — sistem üretir (`elle_girilir = 0`).
--  `hane` TÜRETİLMİŞ kolon: `baslama_no`nun uzunluğundan gelir, elle
--  yazılmaz (152). '000001' = 6 hane, 1'den başlar.
insert into public.numara_sablonu (tur, baslama_tarihi, on_ek, baslama_no,
                                   sube_id, durum, elle_girilir, aciklama)
select x.tur, current_date, x.on_ek, '000001', 0, 1, 0, x.aciklama
  from (values
    (906::smallint, 'AV-'::varchar, 'Personel avans numarasi (767)'::varchar),
    (907::smallint, 'MB-'::varchar, 'Masraf beyan numarasi (767)'::varchar),
    (908::smallint, 'BT-'::varchar, 'Belge talep numarasi (767)'::varchar)
  ) as x(tur, on_ek, aciklama)
 where not exists (select 1 from public.numara_sablonu s where s.tur = x.tur);

-- ---------------------------------------------------------------------- 3
--  GEÇMİŞ KAYITLARA NUMARA VERİLMİYOR.
--
--  Numara, kaydın RESMÎLEŞTİĞİ anda kesilir (onaya gönderildiğinde). Var
--  olan kayıtlara toplu numara dağıtmak, hiç kesilmemiş bir numarayı
--  sonradan uydurmak olurdu: iki kurulumda aynı avans farklı numara alır ve
--  "12 numaralı avans" cümlesi kuruma göre değişirdi.
--
--  Dev ortamında zaten numarasız kayıt yok (test verileri silindi); gerçek
--  kurulumda eski kayıtlar numarasız kalır ve listede `#id` görünür -
--  `v_onay_kutusu` bunu 753'ten beri `coalesce(nullif(no, ''), '#'||id)`
--  ile zaten karşılıyor.
-- ---------------------------------------------------------------------- 4

do $$
declare v_sablon int; v_numarasiz int;
begin
    select count(*) into v_sablon from public.numara_sablonu where tur between 906 and 908;
    select (select count(*) from public.personel_avans where coalesce(avans_no, '') = '')
         + (select count(*) from public.personel_masraf where coalesce(beyan_no, '') = '')
         + (select count(*) from public.personel_belge_talep where coalesce(talep_no, '') = '')
      into v_numarasiz;
    raise notice '767 tamam: % sablon kuruldu. Numarasiz mevcut kayit: % '
                 '(bilerek dokunulmadi).', v_sablon, v_numarasiz;
end $$;

-- ---------------------------------------------------------------------- 5
--  AYARLAR GRİDİNİN KAYNAĞI
--     Tedarik gridiyle AYNI desen: şablonu olan türler + UNION ile ŞABLONSUZ
--     türler (`id = 0`). Ayarsız türü hiç göstermemek, kullanıcının o
--     numaranın var olduğunu bilmemesi demekti - "avans numarası neden boş"
--     sorusunun cevabı ekranda görünmüyordu.
--
--     `v_numara_turu_ik`de `sira` yok; tür id'si sırayı zaten veriyor
--     (906-908) ve üç satırlık bir listede ayrı sıra kolonu fazlalık.
create or replace view public.v_numara_ik as
select n.id,
       n.tur,
       t.ad                     as tur_adi,
       n.tur::smallint          as sira,
       n.baslama_tarihi,
       n.on_ek,
       n.baslama_no,
       n.hane,
       n.sube_id,
       n.elle_girilir,
       n.durum
  from public.numara_sablonu n
  join public.v_numara_turu_ik t on t.id = n.tur
union all
select 0                        as id,
       t.id                     as tur,
       t.ad                     as tur_adi,
       t.id::smallint           as sira,
       null::date               as baslama_tarihi,
       ''::varchar              as on_ek,
       ''::varchar              as baslama_no,
       0                        as hane,
       null::integer            as sube_id,
       null::smallint           as elle_girilir,
       null::smallint           as durum
  from public.v_numara_turu_ik t
 where not exists (select 1 from public.numara_sablonu n where n.tur = t.id);

comment on view public.v_numara_ik is
  '767: Genel Ayarlar > Belge No > IK Talepleri gridi. Sablonsuz tur de '
  'id = 0 satiri olarak cizilir - ayarsiz numara gorunmez kalmasin.';
