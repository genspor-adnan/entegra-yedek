-- ============================================================================
--  Gentegre AI — IRSALIYE CARI HESABI ETKILEMEZ
--  136_irsaliye_cari_etkilemez.sql
--
--  Kullanici kurali: "cari ekstreye belge olarak FIS / FATURA / TAHAKKUK gelir."
--  Irsaliye (ve konsinye) mal hareketidir - fatura kesilene kadar cari borc/
--  alacak dogurmaz. Katalogta ise 10/14/109/119 turleri `cari_etkiler=1` idi;
--  sonuclari:
--
--    - Ekstrede FATURA yerine IRSALIYE goruluyordu.
--    - Irsaliyeden fatura turetilince fatura cari yazmiyordu (cift sayimi
--      onlemek icin atlaniyor), yani resmi belge ekstrede HIC yoktu.
--
--  Bu goc katalog bayraklarini duzeltir ve mevcut irsaliye cari satirlarini
--  onarir. Onarim IKI DALLI - hicbir bakiye kendiliginden degismesin diye:
--
--    a) Irsaliyeden fatura/fis/tahakkuk TURETILMISSE cari satiri hedef belgeye
--       TASINIR (tur + belge_id guncellenir). Bakiye aynen kalir, ekstrede
--       artik resmi belge gorunur.
--    b) Turetilmemisse (mal cikti, faturasi kesilmedi) satir YEDEKLENIP silinir:
--       yeni kurala gore o cari borc/alacak henuz dogmamistir.
--
--  Yedek: mali_hareket_irsaliye_yedek_136 (geri alinabilsin).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------------ yedek ----
create table if not exists public.mali_hareket_irsaliye_yedek_136 (
    id           integer primary key,
    tur          smallint,
    belge_id     integer,
    taraf_id     integer,
    borc         numeric(19,4),
    alacak       numeric(19,4),
    yerel_borc   numeric(19,4),
    yerel_alacak numeric(19,4),
    doviz_cinsi  varchar(6),
    islem        varchar(10) not null,   -- 'tasindi' | 'silindi'
    hedef_belge  integer,
    tarih        timestamp not null default now()::timestamp
);

-- Onarim TEK ISLEMDE: yariya kalirsa cari bakiyesi tutarsiz kalirdi.
begin;

-- Irsaliye cari satiri -> ondan turetilmis (kaynak_tur=30) ilk belge.
-- `on commit drop` DEGIL: psql her ifadeyi kendi islemiyle calistirdiginda
--   tablo sonraki ifadeye kadar yasamiyordu.
create temporary table gecici_irsaliye_cari as
select m.id            as mali_hareket_id,
       m.tur           as eski_tur,
       m.belge_id      as eski_belge_id,
       m.taraf_id, m.borc, m.alacak, m.yerel_borc, m.yerel_alacak, m.doviz_cinsi,
       (select h.id  from public.belge h
         where h.kaynak_tur = 30 and h.kaynak_id = m.belge_id and h.durum = 0
         order by h.id limit 1) as hedef_belge_id,
       (select h.tur from public.belge h
         where h.kaynak_tur = 30 and h.kaynak_id = m.belge_id and h.durum = 0
         order by h.id limit 1) as hedef_tur
  from public.mali_hareket m
 where m.tur in (10, 14, 109, 119);

insert into public.mali_hareket_irsaliye_yedek_136
    (id, tur, belge_id, taraf_id, borc, alacak, yerel_borc, yerel_alacak,
     doviz_cinsi, islem, hedef_belge)
select mali_hareket_id, eski_tur, eski_belge_id, taraf_id, borc, alacak,
       yerel_borc, yerel_alacak, doviz_cinsi,
       case when hedef_belge_id is null then 'silindi' else 'tasindi' end,
       hedef_belge_id
  from gecici_irsaliye_cari
on conflict (id) do nothing;

-- a) Turetilmis belgesi olan satirlar TASINIR.
update public.mali_hareket m
   set belge_id = g.hedef_belge_id,
       tur      = g.hedef_tur
  from gecici_irsaliye_cari g
 where m.id = g.mali_hareket_id
   and g.hedef_belge_id is not null;

-- b) Turetilmemis irsaliyelerin cari satiri SILINIR.
delete from public.mali_hareket m
 using gecici_irsaliye_cari g
 where m.id = g.mali_hareket_id
   and g.hedef_belge_id is null;

-- --------------------------------------------------------------- katalog ----
-- Irsaliye / konsinye: STOK etkiler, CARI etkilemez.
update public.kasa_islem_turu
   set cari_etkiler = 0,
       cari_ekstre  = 0,
       bakiye_dahil = 0
 where kod in (10, 14, 109, 119);

comment on column public.kasa_islem_turu.cari_etkiler is
  'Belge cari hesap hareketi yazar mi (136: irsaliye/konsinye yazmaz - fatura/fis/tahakkuk yazar).';

drop table if exists gecici_irsaliye_cari;
commit;

do $$
declare v_tasinan integer; v_silinen integer; v_kalan integer;
begin
    select count(*) into v_tasinan from public.mali_hareket_irsaliye_yedek_136 where islem = 'tasindi';
    select count(*) into v_silinen from public.mali_hareket_irsaliye_yedek_136 where islem = 'silindi';
    select count(*) into v_kalan   from public.mali_hareket where tur in (10, 14, 109, 119);
    raise notice '136 tamam: % satir hedef belgeye tasindi, % satir silindi, irsaliye cari satiri kalan %',
                 v_tasinan, v_silinen, v_kalan;
end $$;
