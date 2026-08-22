-- ============================================================================
--  Gentegre AI — SIPARIS / IRSALIYE / FATURA donusumu (F8 sema adimi)
--  082_belge_donusum.sql
--
--  SIPARIS AYRI TABLO DEGILDIR: belge turleridir (9 alis siparisi, 19 satis
--    siparisi) - irsaliye (10/14) ve fatura (11/15) ile AYNI tablo, ayni
--    BelgeDeposu, ayni satir yapisi. Legacy'de de tek FATBASLIK'ti. Ayri tablo
--    acmak ayni akisi ikiye bolerdi (iki kayit yolu, iki numara sayaci, iki
--    stok/cari yazici).
--
--  ZATEN VARDI: belge.kaynak_tur/kaynak_id (baslik bagi) ve
--    belge_satir.kaynak_tur/kaynak_id (SATIR bagi, indeksli) - kismi donusumun
--    tasiyicisi. EKSIK olan yalniz "ne kadari kapandi" takibi ve donusum
--    fonksiyonuydu; bu dosya onu ekler.
--
--  Kapatma tek yerde (TRIGGER) tutulur: hedef satir yazilinca/silinince kaynak
--    satirin kapatilan_miktar'i guncellenir. Uygulama koduna birakilirsa bir
--    yerde unutulur ve "kalan" sessizce yanlislasir.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------- satir kapatma alanlari ----
alter table public.belge_satir add column if not exists kapatilan_miktar numeric(24,6) not null default 0;

alter table public.belge_satir drop column if exists kalan_miktar;
alter table public.belge_satir
    add column kalan_miktar numeric(24,6)
    generated always as (miktar - kapatilan_miktar) stored;

comment on column public.belge_satir.kapatilan_miktar is
  'Bu satirdan turetilmis (irsaliye/fatura) hedef satirlarin toplam miktari. Trigger ile guncellenir - elle yazilmaz.';

-- --------------------------------------------------- baslik kapanma durumu ----
alter table public.belge add column if not exists kapanma_durum smallint not null default 0;

comment on column public.belge.kapanma_durum is
  '0 acik, 1 kismi donusturuldu, 2 tamamen kapandi. Satir toplamlarindan trigger ile turetilir.';

create index if not exists ix_belge_kapanma on public.belge (tur, kapanma_durum)
    where kapanma_durum < 2;

-- ------------------------------------------------------------- trigger ----
-- kaynak_tur = 30 -> kaynak "belge_satir" (eski TabNo_FATBASLIK ailesi; belge
--   satirindan belge satirina turetme). Diger kaynak turleri (88 stok vb.)
--   kapatma sayacini ETKILEMEZ.
-- Etkilenen kaynak satirin sayacini + basliginin kapanma durumunu yeniden hesaplar.
create or replace function public.fn_belge_satir_kapatma_tazele(p_satir_id integer)
returns void
language plpgsql
as $$
declare v_belge integer;
begin
    if p_satir_id is null or p_satir_id = 0 then return; end if;

    update public.belge_satir k
       set kapatilan_miktar = coalesce((
               select sum(h.miktar) from public.belge_satir h
                where h.kaynak_tur = 30 and h.kaynak_id = k.id), 0)
     where k.id = p_satir_id
       and k.kapatilan_miktar is distinct from coalesce((
               select sum(h.miktar) from public.belge_satir h
                where h.kaynak_tur = 30 and h.kaynak_id = k.id), 0)
    returning k.belge_id into v_belge;

    if v_belge is null then
        select belge_id into v_belge from public.belge_satir where id = p_satir_id;
    end if;
    if v_belge is null then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (select case
                     when count(*) = 0                                          then 0
                     when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0 then 2
                     when sum(s.kapatilan_miktar) > 0                            then 1
                     else 0
                   end as durum
              from public.belge_satir s where s.belge_id = v_belge) x
     where b.id = v_belge
       and b.kapanma_durum is distinct from x.durum;
end $$;

-- OLD/NEW erisimi TG_OP'a gore korunur (INSERT'te OLD, DELETE'te NEW atanmamistir).
create or replace function public.fn_belge_satir_kapatma()
returns trigger
language plpgsql
as $$
begin
    if tg_op in ('UPDATE', 'DELETE') and old.kaynak_tur = 30 then
        perform public.fn_belge_satir_kapatma_tazele(old.kaynak_id);
    end if;
    if tg_op in ('INSERT', 'UPDATE') and new.kaynak_tur = 30 then
        perform public.fn_belge_satir_kapatma_tazele(new.kaynak_id);
    end if;
    return null;                      -- after trigger; donus degeri kullanilmaz
end $$;

drop trigger if exists trg_belge_satir_kapatma_i on public.belge_satir;
create trigger trg_belge_satir_kapatma_i after insert on public.belge_satir
    for each row execute function public.fn_belge_satir_kapatma();

drop trigger if exists trg_belge_satir_kapatma_u on public.belge_satir;
create trigger trg_belge_satir_kapatma_u after update of miktar, kaynak_id, kaynak_tur on public.belge_satir
    for each row execute function public.fn_belge_satir_kapatma();

drop trigger if exists trg_belge_satir_kapatma_d on public.belge_satir;
create trigger trg_belge_satir_kapatma_d after delete on public.belge_satir
    for each row execute function public.fn_belge_satir_kapatma();

-- --------------------------------------------------- acik satir gorunumu ----
create or replace view public.v_belge_acik_satir as
select s.id            as satir_id,
       s.belge_id,
       b.tur           as belge_tur,
       kt.ad           as belge_tur_adi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.belge_dovizi,
       b.sube_id,
       s.sira,
       s.tur           as satir_tur,
       s.stok_id, st.kod as stok_kodu, st.ad as stok_adi,
       s.hizmet_id, s.masraf_id,
       s.aciklama,
       s.miktar,
       s.kapatilan_miktar,
       s.kalan_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       b.kapanma_durum
  from public.belge_satir s
  join public.belge b  on b.id = s.belge_id
  left join public.kasa_islem_turu kt on kt.kod = b.tur
  left join public.stok st on st.id = s.stok_id
 where s.kalan_miktar > 0
   and b.durum = 0;                 -- yalniz KESIN belgeler donusturulebilir (taslak/iptal degil)

comment on view public.v_belge_acik_satir is
  'Donusturulmeyi bekleyen satirlar (siparis -> irsaliye -> fatura). Donusum ekraninin ve "acik siparis" raporunun kaynagi.';

-- ------------------------------------------- turden stok etkisi bayragi ----
-- Irsaliye -> fatura donusumunde stok TEKRAR dusulmemeli (irsaliyede dusuldu).
--   Karar kodda if/else yerine katalogda: hangi tur stogu etkiler?
alter table public.kasa_islem_turu add column if not exists stok_etkiler smallint not null default 0;

comment on column public.kasa_islem_turu.stok_etkiler is
  '1 ise bu belge turu stok_durum''u degistirir. Irsaliye 1, faturasi 0 (mal zaten irsaliyeyle cikti) - cift dusme boyle engellenir.';

update public.kasa_islem_turu set stok_etkiler = 1 where kod in (4, 6, 10, 14, 20, 109, 119);
update public.kasa_islem_turu set stok_etkiler = 0 where kod in (9, 19, 105, 13, 17, 8);
-- Fatura/fis: irsaliyesiz kesilirse stogu etkiler; irsaliyeden turediyse
--   fn_belge_donustur bunu "kaynak satir var" diye zaten atlar.
update public.kasa_islem_turu set stok_etkiler = 1 where kod in (11, 12, 15, 16);

-- ------------------------------------------- belge turu adlari (Turkce) ----
-- 073 seed'i ASCII yazilmisti; bu adlar listede/ekranda gorunuyor.
update public.kasa_islem_turu set ad = v.ad from (values
    (1,  'Açılış Fişi'),      (4,  'Diğer Çıkış Fişi'),  (6,  'Üretim'),
    (8,  'Gider Pusulası'),   (9,  'Alış Siparişi'),     (10, 'Alış İrsaliyesi'),
    (11, 'Alış Faturası'),    (12, 'Alış Fişi'),         (13, 'Alacak Tahakkuku'),
    (14, 'Satış İrsaliyesi'), (15, 'Satış Faturası'),    (16, 'Satış Fişi'),
    (17, 'Borç Tahakkuku'),   (19, 'Satış Siparişi'),    (20, 'Stok Transferi'),
    (105,'Stoktan Talep'),    (109,'Gelen Konsinye'),    (119,'Giden Konsinye')
) as v(kod, ad) where kasa_islem_turu.kod = v.kod and kasa_islem_turu.ad <> v.ad;

-- ------------------------------------------------------ mevcut veriyi kur ----
-- Gecmis belgelerde kaynak_id zaten dolu olabilir; sayaci bir kez hesapla.
update public.belge_satir k
   set kapatilan_miktar = coalesce((
           select sum(coalesce(h.miktar, 0)) from public.belge_satir h
            where h.kaynak_tur = 30 and h.kaynak_id = k.id), 0)
 where exists (select 1 from public.belge_satir h
                where h.kaynak_tur = 30 and h.kaynak_id = k.id);

update public.belge b
   set kapanma_durum = x.durum
  from (select s.belge_id,
               case when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0 then 2
                    when sum(coalesce(s.kapatilan_miktar, 0)) > 0                then 1
                    else 0 end as durum
          from public.belge_satir s group by s.belge_id) x
 where x.belge_id = b.id and b.kapanma_durum <> x.durum;

-- ------------------------------------------------------------- dogrulama ----
do $$
declare v_acik integer; v_kismi integer; v_kapali integer; v_sip integer;
begin
    select count(*) into v_acik   from public.v_belge_acik_satir;
    select count(*) into v_kismi  from public.belge where kapanma_durum = 1;
    select count(*) into v_kapali from public.belge where kapanma_durum = 2;
    select count(*) into v_sip    from public.belge where tur in (9, 19);
    raise notice '082 tamam: acik satir %, kismi belge %, kapali belge % | siparis belgesi %',
                 v_acik, v_kismi, v_kapali, v_sip;
end $$;
