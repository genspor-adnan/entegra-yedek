-- =====================================================================
--  636_hasta_belge_numara_gorunumu.sql
--  HASTA BELGELERİ GRİDİ AYARSIZ TÜRLERİ DE GÖSTERİR.
--
--  Grid `numara_sablonu` satırlarını listeliyordu; şablon satırı yalnız
--  Dosya No ve Protokol No için vardı. Sonuç: kullanıcı Muayene No, Reçete
--  No, Lab İstem No ve Radyoloji satırlarını gridde göremiyor, "eklenmemiş"
--  sanıyordu - üç ayrı istek bu yüzden geldi. Oysa türler "＋ Yeni"
--  penceresindeki seçim kutusunda duruyordu; ekran bunu söylemiyordu.
--
--  Görünüm artık TÜR LİSTESİNDEN başlar: ayarı olmayan tür de bir satır
--  olarak görünür, `id = 0` ve alanları boş. Ekran o satıra tıklayınca
--  "yeni" kartını türü seçili açar.
--
--  AYARI OLAN TÜRÜN BİRDEN FAZLA SATIRI OLABİLİR (152: "şu tarihten
--  itibaren" kuralı) - hepsi listelenir, boş satır yalnız HİÇ ayarı
--  olmayan türe eklenir.
-- =====================================================================

create or replace view public.v_numara_hasta_belge as
  -- Tanımlı şablon satırları.
  select n.id, n.tur, t.ad as tur_adi, t.sira,
         n.baslama_tarihi, n.on_ek, n.baslama_no, n.hane,
         n.sube_id, n.elle_girilir, n.durum
    from public.numara_sablonu n
    join public.v_numara_turu_kimlik t on t.id = n.tur
union all
  -- Hiç ayarlanmamış türler: id 0, alanlar boş. Grid "bu numara için ayar
  --   yok" demeyi başka türlü söyleyemiyordu.
  --
  -- DURUM NULL, 0 DEĞİL: 0 "Pasif" demektir ve rozet kırmızı "Pasif"
  --   yazardı - ayarsız bir tür pasif değildir, hiç ayarlanmamıştır. NULL
  --   hücreyi boş bırakır. Aynısı "elle girilir" için de geçerli.
  select 0, t.id, t.ad, t.sira,
         null::date, ''::varchar, ''::varchar, 0,
         null::integer, null::smallint, null::smallint
    from public.v_numara_turu_kimlik t
   where not exists (select 1 from public.numara_sablonu n where n.tur = t.id);

comment on view public.v_numara_hasta_belge is
  '636: Hasta Belgeleri numaralandirma gridi. Ayari olmayan tur de satir '
  'olarak gorunur (id 0) - yoksa kullanici turun var oldugunu goremiyordu.';

do $kontrol$
begin
    raise notice '636 tamam: % satir (% tanimli, % ayarsiz)',
        (select count(*) from public.v_numara_hasta_belge),
        (select count(*) from public.v_numara_hasta_belge where id > 0),
        (select count(*) from public.v_numara_hasta_belge where id = 0);
end $kontrol$;
