-- =============================================================================
--  1006 - DEMİRBAŞ KARTI SEKMELERİ: ZİMMET GEÇMİŞİ, BAKIM / SERVİS, AMORTİSMAN
--
--  Kullanıcı (09.10.2026): "ERP'de demirbaş kartının sekmelerini doldur".
--  Mockup: Ekranlar/demirbas_karti.html (Amortisman · Zimmet / Tutanak ·
--  Bakım / Kalibrasyon). Üç sekme 216'dan beri yer tutucuydu.
--
--  ZİMMET GEÇMİŞİ = demirbas_hareket (723). Tablo vardı ama ERP'de hiçbir
--    yol yazmıyordu - kartta zimmet kişisi değişince iz kalmıyordu. Hareket
--    artık TETİKLE yazılır: zimmet / lokasyon kartta değiştiği anda, hangi
--    ekrandan değiştiği fark etmeksizin. Elle satır girilen bir geçmiş,
--    karttaki güncel zimmetle çelişebilirdi; tetikle ikisi aynı işlemde
--    yazılır. Zimmet veriş / iade satırı TUTANAK NUMARASI alır (mockup
--    "TUT.2026-0088"): imzalı çıktının numarası.
--    Hareket kodları (723'e ek): 9 zimmet iadesi. 1 = veriş (ya da başka
--    kişiye devir), 2 = yer değişikliği aynen kalır.
--
--  AMORTİSMAN = hesaplanır, saklanmaz. Girdi kartta: alış tutarı, alış
--    tarihi (216) + yöntem, faydalı ömür, başlangıç (bu göç). Tablo bir
--    görünümden gelir; ayrı bir tablo, kartta tutar düzeltilince eskiyen
--    ikinci bir kopya olurdu.
--    VUK: normal yöntemde oran 1/ömür; azalan bakiyelerde oran bunun 2 katı,
--    en çok %50, son yılda kalan değerin tamamı ayrılır. Tam yıl ayrılır
--    (demirbaşta kıst amortisman yok). Durum muhasebe kaydını DEĞİL takvimi
--    gösterir: ERP'de amortisman fişi henüz üretilmiyor, "işlendi" demek
--    yanlış olurdu.
--
--  BAKIM / SERVİS = demirbas_is_emri (723). Kartta ayrı tablo AÇILMADI:
--    HBYS'deki Bakım / Arıza ekranı aynı tabloyu kullanıyor; iki tablo aynı
--    cihazın servis geçmişini ikiye bölerdi. Göçte değişiklik yok, sekme
--    katalogda (KartKatalogu.Demirbas).
-- =============================================================================

-- ---------------------------------------------------------------- hareket --
alter table public.demirbas_hareket
  add column if not exists eski_lokasyon smallint,
  add column if not exists yeni_lokasyon smallint,
  add column if not exists tutanak_no    varchar(30) not null default '';

create or replace function public.fn_demirbas_hareket_yaz()
returns trigger language plpgsql as $tg$
declare
    v_eski_zimmet integer;
    v_eski_lok    smallint;
    v_tip         smallint;
    v_tutanak     varchar(30) := '';
    v_yil         text;
begin
    if tg_op = 'UPDATE' then
        v_eski_zimmet := old.zimmet_taraf_id;
        v_eski_lok    := old.lokasyon;
    end if;
    if new.zimmet_taraf_id is not distinct from v_eski_zimmet
       and new.lokasyon is not distinct from v_eski_lok then
        return null;
    end if;

    v_tip := case
        when new.zimmet_taraf_id is distinct from v_eski_zimmet
            then case when new.zimmet_taraf_id is null then 9 else 1 end
        else 2 end;

    if v_tip in (1, 9) then
        -- Yıl içinde artan sıra; eşzamanlı iki zimmet aynı numarayı almasın.
        perform pg_advisory_xact_lock(hashtext('demirbas_tutanak'));
        v_yil := to_char(current_date, 'YYYY');
        select 'TUT.' || v_yil || '-' || lpad((count(*) + 1)::text, 4, '0')
          into v_tutanak
          from public.demirbas_hareket
         where tutanak_no like 'TUT.' || v_yil || '-%';
    end if;

    insert into public.demirbas_hareket
        (demirbas_id, hareket, eski_zimmet_id, yeni_zimmet_id,
         eski_lokasyon, yeni_lokasyon, tutanak_no, ekleyen)
    values
        (new.id, v_tip, v_eski_zimmet, new.zimmet_taraf_id,
         v_eski_lok, new.lokasyon, v_tutanak,
         coalesce(case when tg_op = 'UPDATE' then new.degistiren end, new.ekleyen, 0));
    return null;
end;
$tg$;

drop trigger if exists tg_demirbas_hareket on public.demirbas;
create trigger tg_demirbas_hareket
  after insert or update of zimmet_taraf_id, lokasyon on public.demirbas
  for each row execute function public.fn_demirbas_hareket_yaz();

-- GERİYE DÖNÜK: bugün zimmetli olup hiç hareketi olmayan demirbaşa tek bir
--   veriş satırı. Tarihi alış (yoksa kayıt) tarihi; tutanak numarası verilmez
--   - o tarihte üretilmiş bir tutanak yok.
insert into public.demirbas_hareket
    (demirbas_id, zaman, hareket, yeni_zimmet_id, yeni_lokasyon, aciklama, ekleyen)
select d.id, coalesce(d.alis_tarihi::timestamptz, d.ekleme_tarihi), 1,
       d.zimmet_taraf_id, d.lokasyon, 'Geçmişten devralınan zimmet', 0
  from public.demirbas d
 where d.zimmet_taraf_id is not null
   and not exists (select 1 from public.demirbas_hareket h where h.demirbas_id = d.id);

create or replace view public.v_demirbas_zimmet as
select h.id,
       h.demirbas_id,
       h.zaman,
       h.hareket                                            as tip,
       -- İadede kişi, malı GERİ VEREN (eski zimmetli) kişidir.
       case when h.hareket = 9 then h.eski_zimmet_id else h.yeni_zimmet_id end as kisi_id,
       coalesce(h.yeni_lokasyon, h.eski_lokasyon)           as lokasyon,
       h.tutanak_no,
       h.aciklama
  from public.demirbas_hareket h;

-- -------------------------------------------------------------- amortisman --
alter table public.demirbas
  add column if not exists amortisman_yontem    smallint not null default 1,
  add column if not exists amortisman_omur_yil  smallint,
  add column if not exists amortisman_baslangic date;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'ck_demirbas_amortisman_yontem') then
        alter table public.demirbas add constraint ck_demirbas_amortisman_yontem
            check (amortisman_yontem in (1, 2));
    end if;
    if not exists (select 1 from pg_constraint where conname = 'ck_demirbas_amortisman_omur') then
        alter table public.demirbas add constraint ck_demirbas_amortisman_omur
            check (amortisman_omur_yil is null or amortisman_omur_yil between 1 and 50);
    end if;
end $$;

create or replace view public.v_demirbas_amortisman as
with recursive girdi as (
    select d.id as demirbas_id,
           d.alis_tutari::numeric(18,2) as tutar,
           d.amortisman_omur_yil::int   as omur,
           d.amortisman_yontem          as yontem,
           extract(year from coalesce(d.amortisman_baslangic, d.alis_tarihi))::int as ilk_yil
      from public.demirbas d
     where coalesce(d.alis_tutari, 0) > 0
       and coalesce(d.amortisman_omur_yil, 0) > 0
       and coalesce(d.amortisman_baslangic, d.alis_tarihi) is not null
), satir as (
    select g.demirbas_id, 1 as sira, g.ilk_yil as yil, g.tutar, g.omur, g.yontem,
           a.ayrilan as amortisman, a.ayrilan as birikmis
      from girdi g
     cross join lateral (select case
             when g.omur = 1 then g.tutar
             when g.yontem = 2 then round(g.tutar * least(2.0 / g.omur, 0.5), 2)
             else round(g.tutar / g.omur, 2) end as ayrilan) a
    union all
    select s.demirbas_id, s.sira + 1, s.yil + 1, s.tutar, s.omur, s.yontem,
           a.ayrilan, s.birikmis + a.ayrilan
      from satir s
     cross join lateral (select case
             -- SON YIL KALANI SIFIRLAR: yuvarlama kuruşları ve azalan
             --   bakiyede hiç bitmeyen kuyruk son yılda kapanır.
             when s.sira + 1 = s.omur then s.tutar - s.birikmis
             when s.yontem = 2 then round((s.tutar - s.birikmis) * least(2.0 / s.omur, 0.5), 2)
             else round(s.tutar / s.omur, 2) end as ayrilan) a
     where s.sira < s.omur
)
select s.yil                         as id,
       s.demirbas_id,
       s.yil,
       s.amortisman::numeric(18,2)   as amortisman,
       s.birikmis::numeric(18,2)     as birikmis,
       (s.tutar - s.birikmis)::numeric(18,2) as net_deger,
       -- 1 geçmiş yıl · 2 cari yıl · 3 gelecek yıl (takvim, muhasebe kaydı değil)
       (case when s.yil < extract(year from current_date) then 1
             when s.yil = extract(year from current_date) then 2
             else 3 end)::smallint   as durum
  from satir s;
