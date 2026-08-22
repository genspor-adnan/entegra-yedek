-- ============================================================================
--  Gentegre AI — Belge donusumu: kapatma sayaci duzeltmesi + etki bayraklari
--  086_belge_donusum_kurallar.sql  (F8)
--
--  082 kapatma sayacini kurdu ama iki eksigi vardi:
--
--  1) IPTAL EDILEN hedef belge kalani SERBEST BIRAKMIYORDU. Trigger "bu satirdan
--     turetilmis tum satirlarin toplami" diyordu; faturayi iptal edince (durum=2)
--     satirlari duruyor, dolayisiyla siparis "kapali" kaliyor ve bir daha
--     faturalanamiyordu. Sayac artik yalniz IPTAL OLMAYAN hedefleri sayar ve
--     belge.durum degisince sayaclar tazelenir.
--
--  2) SIPARIS STOK VE CARI ETKILIYORDU. BelgeDeposu tur'e bakmadan her kesin
--     belgede stok_durum guncelliyor ve cari hareket yaziyordu; siparis bir
--     TAAHHUTTUR - ne mal cikar ne cari borclanir. Turler artik bunu VERI olarak
--     tasiyor (stok_etkiler / cari_etkiler) ve uygulama katalogtan okur.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------- cari etki bayragi ----
alter table public.kasa_islem_turu add column if not exists cari_etkiler smallint not null default 1;

comment on column public.kasa_islem_turu.cari_etkiler is
  '1 ise bu belge turu cari hesabi borclandirir/alacaklandirir (mali_hareket yazilir). Siparis/teklif/talep TAAHHUTTUR - 0.';

-- Taahhut ve depo-ici belgeler cariyi ETKILEMEZ.
update public.kasa_islem_turu set cari_etkiler = 0
 where kod in (9, 19, 105, 6, 20, 4, 2, 1) and cari_etkiler <> 0;

-- Siparis stok da dusurmez (082'de 0'a cekilmisti; teyit).
update public.kasa_islem_turu set stok_etkiler = 0 where kod in (9, 19, 105) and stok_etkiler <> 0;

-- ------------------------------------------- kapatma sayaci: iptal harici ----
create or replace function public.fn_belge_satir_kapatma_tazele(p_satir_id integer)
returns void
language plpgsql
as $$
declare
    v_belge integer;
    v_yeni  numeric(24,6);
begin
    if p_satir_id is null or p_satir_id = 0 then return; end if;

    -- IPTAL (durum=2) hedef satirlari sayilmaz: iptal edilen fatura kaynagin
    --   kalanini geri birakmali, yoksa siparis sonsuza dek "kapali" kalir.
    select coalesce(sum(h.miktar), 0) into v_yeni
      from public.belge_satir h
      join public.belge hb on hb.id = h.belge_id
     where h.kaynak_tur = 30 and h.kaynak_id = p_satir_id and hb.durum <> 2;

    update public.belge_satir k
       set kapatilan_miktar = v_yeni
     where k.id = p_satir_id and k.kapatilan_miktar is distinct from v_yeni
    returning k.belge_id into v_belge;

    if v_belge is null then
        select belge_id into v_belge from public.belge_satir where id = p_satir_id;
    end if;
    if v_belge is null then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (select case
                     when count(*) = 0                                            then 0
                     when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0  then 2
                     when sum(s.kapatilan_miktar) > 0                              then 1
                     else 0
                   end as durum
              from public.belge_satir s where s.belge_id = v_belge) x
     where b.id = v_belge
       and b.kapanma_durum is distinct from x.durum;
end $$;

-- Hedef belge IPTAL edilince (ya da iptali geri alininca) kaynak satirlarin
--   sayaci tazelenmeli - satir tablosuna dokunulmadigi icin satir trigger'i
--   bunu goremez.
create or replace function public.fn_belge_durum_kapatma()
returns trigger
language plpgsql
as $$
declare r record;
begin
    if old.durum = new.durum then return null; end if;
    for r in select distinct s.kaynak_id from public.belge_satir s
              where s.belge_id = new.id and s.kaynak_tur = 30 and s.kaynak_id > 0 loop
        perform public.fn_belge_satir_kapatma_tazele(r.kaynak_id);
    end loop;
    return null;
end $$;

drop trigger if exists trg_belge_durum_kapatma on public.belge;
create trigger trg_belge_durum_kapatma after update of durum on public.belge
    for each row execute function public.fn_belge_durum_kapatma();

-- ------------------------------------------------ donusum zinciri gorunumu ----
-- Bir belgenin nereden geldigi / nereye donustugu tek sorguda.
create or replace view public.v_belge_donusum as
select k.belge_id            as kaynak_belge_id,
       kb.tur                as kaynak_tur,
       kt.ad                 as kaynak_tur_adi,
       kb.belge_no           as kaynak_belge_no,
       kb.belge_tarihi       as kaynak_tarih,
       k.id                  as kaynak_satir_id,
       k.miktar              as kaynak_miktar,
       k.kapatilan_miktar,
       k.kalan_miktar,
       h.belge_id            as hedef_belge_id,
       hb.tur                as hedef_tur,
       ht.ad                 as hedef_tur_adi,
       hb.belge_no           as hedef_belge_no,
       hb.belge_tarihi       as hedef_tarih,
       hb.durum              as hedef_durum,
       h.id                  as hedef_satir_id,
       h.miktar              as hedef_miktar,
       coalesce(st.kod, '')  as stok_kodu,
       coalesce(st.ad, k.aciklama) as kalem_adi,
       kb.taraf_id, kb.taraf_unvan, kb.sube_id
  from public.belge_satir k
  join public.belge kb  on kb.id = k.belge_id
  left join public.kasa_islem_turu kt on kt.kod = kb.tur
  left join public.belge_satir h on h.kaynak_tur = 30 and h.kaynak_id = k.id
  left join public.belge hb on hb.id = h.belge_id
  left join public.kasa_islem_turu ht on ht.kod = hb.tur
  left join public.stok st on st.id = k.stok_id
 where exists (select 1 from public.belge_satir x where x.kaynak_tur = 30 and x.kaynak_id = k.id)
    or k.kapatilan_miktar > 0;

comment on view public.v_belge_donusum is
  'Siparis -> irsaliye -> fatura zinciri (satir bazli). Kaynak satirin hangi hedef satirlara bolundugu ve her hedefin durumu.';

-- ------------------------------------------------------------ kod listesi ----
insert into public.kod_liste (kod, ad) values ('belge.kapanma_durum', 'Belge Kapanma Durumu')
on conflict (kod) do update set ad = excluded.ad;

insert into public.kod_deger (liste_id, deger, ad, sira)
select l.id, v.deger, v.ad, v.sira
  from public.kod_liste l,
       (values (0, 'Açık', 10), (1, 'Kısmi Dönüştü', 20), (2, 'Kapandı', 30)) as v(deger, ad, sira)
 where l.kod = 'belge.kapanma_durum'
on conflict (liste_id, deger, dil) do update set ad = excluded.ad;

-- ------------------------------------------------------- mevcut veriyi kur ----
do $$
declare v_tazele integer := 0; r record;
begin
    for r in select distinct k.id from public.belge_satir k
              where exists (select 1 from public.belge_satir h
                             where h.kaynak_tur = 30 and h.kaynak_id = k.id) loop
        perform public.fn_belge_satir_kapatma_tazele(r.id);
        v_tazele := v_tazele + 1;
    end loop;
    raise notice '086: % kaynak satirin sayaci tazelendi', v_tazele;
end $$;

do $$
declare v_s integer; v_c integer; v_a integer;
begin
    select count(*) into v_s from public.kasa_islem_turu where stok_etkiler = 1;
    select count(*) into v_c from public.kasa_islem_turu where cari_etkiler = 0;
    select count(*) into v_a from public.v_belge_acik_satir;
    raise notice '086 tamam: stok etkileyen tur %, cari etkilemeyen tur %, acik satir %', v_s, v_c, v_a;
end $$;
