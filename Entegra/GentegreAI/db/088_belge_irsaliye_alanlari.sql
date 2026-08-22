-- ============================================================================
--  Gentegre AI — Irsaliye kartinin eksik alanlari
--  088_belge_irsaliye_alanlari.sql
--
--  Ekranlar/satis_irsaliye_karti.html mockup'indaki baslik alanlarinin biri
--  disinda hepsi zaten `belge` tablosunda vardi (irsaliye_no, irsaliye_tarihi,
--  cikis_depo_id, satici_id, taraf_adres*, taraf_vd/vkno, belge_dovizi,
--  doviz_kuru, tipi, kaynak_tur/id, kapanma_durum, efatura_durum).
--
--  Eksik olan TESLIM SEKLI: e-Irsaliye'de GIB'in bekledigi bir alan ve sevkiyat
--  planlamasinin girdisi. Kod listesi olarak eklenir (serbest metin degil):
--  raporlarda gruplanabilsin ve e-Belge XML'ine sabit kodla gitsin.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge add column if not exists teslim_sekli smallint not null default 0;

comment on column public.belge.teslim_sekli is
  '0 belirtilmemis / 1 alici adresine teslim / 2 alici kendi araciyla / 3 kargo-nakliye / 4 depoda teslim / 5 yurt disi sevk. Kod listesi: belge.teslim_sekli.';

insert into public.kod_liste (kod, ad) values ('belge.teslim_sekli', 'Teslim Şekli')
on conflict (kod) do update set ad = excluded.ad;

insert into public.kod_deger (liste_id, deger, ad, sira)
select l.id, v.deger, v.ad, v.sira
  from public.kod_liste l,
       (values (0, 'Belirtilmemiş', 10),
               (1, 'Alıcı adresine teslim', 20),
               (2, 'Alıcı kendi aracıyla', 30),
               (3, 'Kargo / nakliye firması', 40),
               (4, 'Depoda teslim', 50),
               (5, 'Yurt dışı sevk', 60)
       ) as v(deger, ad, sira)
 where l.kod = 'belge.teslim_sekli'
on conflict (liste_id, deger, dil) do update set ad = excluded.ad;

-- Depo lookup: kartlarda depo secimi id yazarak degil ADIYLA yapilir.
create or replace view public.v_depo_lookup as
select d.id, d.ad, 1::smallint as aktif, coalesce(d.sube_id, 0) as sube_id
  from public.depo d
 order by d.ad;

comment on view public.v_depo_lookup is
  'Belge kartlarinda cikis/giris deposu secimi icin (GenLookup kaynagi).';

do $$
declare v_d integer; v_t integer;
begin
    select count(*) into v_d from public.v_depo_lookup;
    select count(*) into v_t from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
     where l.kod = 'belge.teslim_sekli';
    raise notice '088 tamam: depo %, teslim sekli kodu %', v_d, v_t;
end $$;
