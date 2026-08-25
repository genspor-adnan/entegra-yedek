-- ============================================================================
--  Gentegre AI — SIPARIS REZERVASYONU
--  142_siparis_rezervasyon.sql
--
--  Satis siparisi bir TAAHHUTTUR: mal henuz cikmadi ama baskasina satilmamali.
--  Rezervasyon, siparis satirinin KALAN miktarini depoda AYIRIR:
--
--      kullanilabilir = kalan - rezerve
--
--  Stok DUSMEZ (o irsaliyede olur); yalniz "soz verilmis" miktar gorunur.
--  Boylece 1000 adetlik stogun 400'u siparise baglandiysa yeni siparis 600
--  gorur - ayni mali iki musteriye satip sonra birine "yok" demek biter.
--
--  IKI YERDE tutulur, ikisi de gerekli:
--    belge_satir.rezerve  - bu satirdan ne kadar ayrildi (satir bazli izleme,
--                           kismi cozme ve iptal buradan hesaplanir)
--    stok_durum.rezerve   - stok x depo TOPLAMI (arama/liste tek okumada
--                           kullanilabilir miktari gosterebilsin)
--
--  COZULME kendiliginden: satir irsaliye/faturaya donusunce kapatilan_miktar
--  artar, rezerve otomatik olarak KALANA cekilir (fn_belge_satir_rezerve_kirp).
--  Boylece "hem rezerve hem sevk edilmis" cift sayim olusamaz.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.stok_durum
    add column if not exists rezerve numeric(24,6) not null default 0;

alter table public.belge_satir
    add column if not exists rezerve numeric(24,6) not null default 0;

comment on column public.stok_durum.rezerve is
  'Siparislere ayrilmis miktar (142). Kullanilabilir = kalan - rezerve. Stok DUSMEZ.';
comment on column public.belge_satir.rezerve is
  'Bu siparis satirindan ayrilan miktar (142). Donusunce kalana kirpilir.';

-- --------------------------------------------------- depo toplamini tazele ----
-- Tek dogruluk kaynagi satirlardir; stok_durum.rezerve onlardan TURETILIR.
create or replace function public.fn_stok_rezerve_tazele(p_stok_id integer, p_depo_id integer)
returns void
language plpgsql
as $$
begin
    if p_stok_id is null or p_depo_id is null then return; end if;

    insert into public.stok_durum (stok_id, depo_id, rezerve)
    values (p_stok_id, p_depo_id, 0)
    on conflict (stok_id, depo_id) do nothing;

    update public.stok_durum d
       set rezerve = coalesce((
             select sum(s.rezerve)
               from public.belge_satir s
               join public.belge b on b.id = s.belge_id
              where s.stok_id = p_stok_id
                and coalesce(s.cikis_depo_id, b.cikis_depo_id) = p_depo_id
                and s.rezerve > 0
                and b.durum = 0), 0)
     where d.stok_id = p_stok_id and d.depo_id = p_depo_id;
end $$;

-- ------------------------------------------- rezerve KALANA kirpma (cozulme) --
-- Satir sevk edildikce (kapatilan_miktar artar) rezerve kendiliginden duser.
create or replace function public.fn_belge_satir_rezerve_kirp(p_satir_id integer)
returns void
language plpgsql
as $$
declare r record;
begin
    select s.id, s.stok_id, s.rezerve, s.kalan_miktar,
           coalesce(s.cikis_depo_id, b.cikis_depo_id) as depo_id
      into r
      from public.belge_satir s
      join public.belge b on b.id = s.belge_id
     where s.id = p_satir_id;
    if not found or coalesce(r.rezerve, 0) = 0 then return; end if;

    if r.rezerve > greatest(r.kalan_miktar, 0) then
        update public.belge_satir
           set rezerve = greatest(r.kalan_miktar, 0)
         where id = r.id;
        perform public.fn_stok_rezerve_tazele(r.stok_id, r.depo_id);
    end if;
end $$;

-- ------------------------------------------------------ belge rezervasyonu ----
-- p_ac = true  -> acik (kalani olan) STOK satirlari kalan miktar kadar rezerve
-- p_ac = false -> rezerv kaldirilir
create or replace function public.fn_belge_rezerve(p_belge_id integer, p_ac boolean)
returns integer
language plpgsql
as $$
declare
    -- Degisken adlari tablo alias'lariyla CAKISMAMALI: `b`/`s` kullanilinca
    --   PL/pgSQL sorgudaki alias'i degiskene cozup "record is not assigned"
    --   veriyordu (ilk surumde yasandi).
    v_belge record;
    r       record;
    v_adet  integer := 0;
begin
    select id, tur, durum, cikis_depo_id into v_belge
      from public.belge where id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadi: %', p_belge_id using errcode = 'GK422';
    end if;
    if v_belge.durum <> 0 then
        raise exception 'Yalnız kesinleşmiş belge rezerve edilebilir (taslak/iptal değil).'
            using errcode = 'GK422';
    end if;
    -- Rezervasyon SIPARISE ozgudur: irsaliye/fatura mali zaten cikariyor,
    --   ayrica ayirmak ayni miktari iki kez dusmek olurdu.
    if v_belge.tur not in (9, 19) then
        raise exception 'Rezervasyon yalnız siparişlerde yapılır.' using errcode = 'GK422';
    end if;

    for r in
        select bs.id, bs.stok_id, bs.kalan_miktar,
               coalesce(bs.cikis_depo_id, v_belge.cikis_depo_id) as depo_id
          from public.belge_satir bs
         where bs.belge_id = p_belge_id and bs.stok_id is not null
    loop
        update public.belge_satir
           set rezerve = case when p_ac then greatest(r.kalan_miktar, 0) else 0 end
         where id = r.id;
        perform public.fn_stok_rezerve_tazele(r.stok_id, r.depo_id);
        v_adet := v_adet + 1;
    end loop;

    return v_adet;
end $$;

comment on function public.fn_belge_rezerve(integer, boolean) is
  'Siparis satirlarinin kalan miktarini depoda rezerve eder / kaldirir (142).';

-- --------------------------------------- kapatma sayacina rezerve kirpma ----
-- Satir sevk edildikce rezerve KENDILIGINDEN cozulsun: kapatma sayacini suren
--   fonksiyonun sonuna kirpma eklenir. Uygulama koduna birakilirsa bir yol
--   (donusum / satir silme / iptal) mutlaka unutulur ve rezerve stokta asili
--   kalirdi.
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
                     when count(*) = 0                                            then 0
                     when sum(case when s.kalan_miktar > 0 then 1 else 0 end) = 0  then 2
                     when sum(s.kapatilan_miktar) > 0                              then 1
                     else 0
                   end as durum
              from public.belge_satir s where s.belge_id = v_belge) x
     where b.id = v_belge
       and b.kapanma_durum is distinct from x.durum;

    -- 142: sevk edilen miktar kadar rezerv cozulur (kalanin ustune cikamaz).
    perform public.fn_belge_satir_rezerve_kirp(p_satir_id);
end $$;

-- ------------------------------------------------------------- gorunum ----
-- Kullanilabilir miktar: arama ve listelerin okudugu tek yer.
create or replace view public.v_stok_kullanilabilir as
select d.stok_id, d.depo_id, d.kalan, d.rezerve,
       d.kalan - d.rezerve as kullanilabilir
  from public.stok_durum d;

comment on view public.v_stok_kullanilabilir is
  'Depodaki kalan, rezerve ve kullanilabilir (kalan - rezerve) miktar (142).';

do $$
declare v_rez numeric;
begin
    select coalesce(sum(rezerve), 0) into v_rez from public.stok_durum;
    raise notice '142 tamam: rezerve kolonlari + fn_belge_rezerve; toplam rezerve %', v_rez;
end $$;
