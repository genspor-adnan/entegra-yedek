-- =====================================================================
-- 470 - ÖDEME DAĞILIMI AYRI TABLOYA: belge_satir_dagilim (1:1)
--
-- Kullanıcı: "dağılımları belge_satir'da istemiyorum; 1:1 bağlı
-- belge_satir_dagilim tablosu oluşturup orada takip etsen."
--
-- BUGÜN satır iki kovaya bölünüyor (kurum_tutar / hasta_tutar). Excel modeli
-- (Dosya/KurumAltKurum.xlsx) BEŞ kova istiyor:
--   1 hasta_provizyon   ÖSS provizyonundan sonra hastaya kalan
--   2 sgk               SGK payı (tahakkuk)
--   3 oss               özel sigorta payı (fatura)
--   4 hasta_ek_katki    hastane ek katkısı / özel hasta bedeli
--   5 sgk_katilim_payi  SGK katılım payı - CİRO DIŞI, SGK'ya emanet
--
-- TSS/Karma'da satırda İKİ fiyat listesi çalışır (SUT + TTB); ikisi de
-- saklanır, aksi hâlde provizyon sonrası dağılım yeniden hesaplanamaz.
--
-- DEĞİŞMEZ: belge_satir.tutar = sgk + oss + hasta_provizyon + hasta_ek_katki.
-- Katılım payı bu toplamın DIŞINDA - hastadan tahsil edilir ama hastanenin
-- geliri değildir (473'te SGK carisine emanet yazılır).
--
-- KOVALAR MATRAH (KDV hariç) tutulur (kullanıcı); KDV dahil görünümler
-- 323'teki gibi türetilir - prim/tahsilat/dönüşüm yeniden yazılmaz.
--
-- Eski `belge_satir` pay kolonları BU GÖÇTE DÜŞMEZ: API kesme yayınından
-- sonra 474'te düşer. Arada iki yol da okunabilir olmalı.
-- =====================================================================

insert into public.kod_liste (kod, ad)
select 'belge.pay', 'Ödeme Payı'
 where not exists (select 1 from public.kod_liste where kod = 'belge.pay');

do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'belge.pay';
    insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
    select v_liste, v.deger, 0, v.ad, v.deger * 10, 1
      from (values (1, 'Hasta payı (provizyon sonrası)'),
                   (2, 'SGK payı'),
                   (3, 'Özel sigorta payı'),
                   (4, 'Hasta ek katkısı'),
                   (5, 'SGK katılım payı (ciro dışı)')) as v(deger, ad)
    on conflict (liste_id, deger, dil) do update
        set ad = excluded.ad, aktif = 1;
end $$;

create table if not exists public.belge_satir_dagilim (
    belge_satir_id       integer primary key
        references public.belge_satir(id) on delete cascade,
    -- ROTA: hangi kural işledi. Saklanır çünkü sözleşme sonradan değişse de
    --   kapanmış satır kendi kuralıyla okunmalı.
    rota                 smallint not null default 1,
    -- Çözülen liste fiyatları (matrah): SUT ve TTB/HUV.
    sgk_liste            numeric(19,4) not null default 0,
    huv_liste            numeric(19,4) not null default 0,
    -- BEŞ KOVA.
    sgk                  numeric(19,4) not null default 0,
    oss                  numeric(19,4) not null default 0,
    hasta_provizyon      numeric(19,4) not null default 0,
    hasta_ek_katki       numeric(19,4) not null default 0,
    sgk_katilim_payi     numeric(19,4) not null default 0,
    -- Kapatma (dönüşüm) ve tahsilat, kova kova.
    sgk_kapatilan        numeric(19,4) not null default 0,
    oss_kapatilan        numeric(19,4) not null default 0,
    hasta_provizyon_kapatilan numeric(19,4) not null default 0,
    hasta_ek_katki_kapatilan  numeric(19,4) not null default 0,
    sgk_tahsil           numeric(19,4) not null default 0,
    oss_tahsil           numeric(19,4) not null default 0,
    hasta_provizyon_tahsil numeric(19,4) not null default 0,
    hasta_ek_katki_tahsil  numeric(19,4) not null default 0,
    sgk_katilim_tahsil   numeric(19,4) not null default 0,
    sgk_provizyon_no     varchar(60) not null default '',
    sgk_provizyon_durum  smallint not null default 0,
    oss_provizyon_satir_id integer,
    -- ELLE sabitlenmiş dağılıma tazeleme DOKUNMAZ: kullanıcı bilerek
    --   yazdıysa fiyat listesi değişince silinmemeli.
    elle                 smallint not null default 0,
    ekleyen              integer not null default 0,
    ekleme_tarihi        timestamp not null default now(),
    degistiren           integer,
    degistirme_tarihi    timestamp
);

comment on table public.belge_satir_dagilim is
  'Satırın ödeme dağılımı (470), belge_satir ile 1:1. tutar = sgk+oss+hasta_provizyon+hasta_ek_katki; katılım payı hariç.';
comment on column public.belge_satir_dagilim.sgk_katilim_payi is
  'SGK katılım payı: hastadan tahsil edilir, CİRO DEĞİLDİR - SGK''ya emanet (473).';

create index if not exists ix_dagilim_sgk
    on public.belge_satir_dagilim (belge_satir_id) where sgk > 0;
create index if not exists ix_dagilim_oss
    on public.belge_satir_dagilim (belge_satir_id) where oss > 0;

-- ------------------------------------------------------------------ rota --
-- 1 Özel · 2 ÖSS · 3 TSS · 4 Karma · 5 SGK.
-- Karma'da hasta SGK katkısını kullanmak istemezse rota ÖSS'ye döner:
--   tüm provizyon TTB üzerinden yürür, sgk ve katılım 0 kalır (kullanıcı).
create or replace function public.fn_dagilim_rota(
    p_tur        smallint,
    p_alt_kurum  smallint default 0,
    p_sgk_kullan smallint default 1)
returns smallint
language sql immutable as $$
    select case
        when coalesce(p_tur, 1) = 1 then 1::smallint
        when p_tur = 3 then 5::smallint
        when p_tur = 2 then case coalesce(p_alt_kurum, 201)
                                 when 202 then 3::smallint
                                 when 203 then case when coalesce(p_sgk_kullan, 1) = 1
                                                    then 4::smallint else 2::smallint end
                                 else 2::smallint end
        else 1::smallint end;
$$;

comment on function public.fn_dagilim_rota(smallint, smallint, smallint) is
  'Ödeme rotası (470): 1 Özel · 2 ÖSS · 3 TSS · 4 Karma · 5 SGK. Karma''da sgk_kullan=0 ise ÖSS gibi işler.';

-- Prim planı KABA grupla çalışır (hasta / kurum); ince kod beş kovadır.
create or replace function public.fn_dagilim_pay_grubu(p_pay smallint)
returns smallint
language sql immutable as $$
    select case p_pay when 1 then 1::smallint   -- hasta
                      when 4 then 1::smallint   -- hasta
                      when 2 then 2::smallint   -- kurum
                      when 3 then 2::smallint   -- kurum
                      else 0::smallint end;     -- katılım: prim üretmez
$$;

-- --------------------------------------------------------------- dağıtım --
-- Excel'deki beş rotanın tamamı burada. Fonksiyon SAF: girdi tutar ve liste
--   fiyatları, çıktı beş kova. Provizyon geldiyse (p_sgk_prov / p_oss_prov)
--   liste fiyatı yerine ONAYLANAN tutar geçerlidir.
--
-- ROTA 1/2/4'te satırın liste fiyatı ANA tutardır, kovalar onu böler.
-- ROTA 3/5'te kovalar TOPLANIR ve satır tutarı olur (SUT + TTB + ek katkı).
--
-- TSS'de fark YUTULUR (kullanıcı: "fark yutulur, oss = onaylanan"): sigorta
--   HUV'dan az onaylarsa aradaki fark hastaya yazılmaz.
create or replace function public.fn_belge_satir_dagit(
    p_rota                smallint,
    p_tutar               numeric,
    p_sgk_liste           numeric default 0,
    p_huv_liste           numeric default 0,
    p_ek_katki            numeric default 0,
    p_sgk_katilim         numeric default 0,
    p_sgk_prov            numeric default null,
    p_oss_prov            numeric default null,
    p_varsayilan_karsilama numeric default 0)
returns table (tutar numeric, sgk numeric, oss numeric,
               hasta_provizyon numeric, hasta_ek_katki numeric,
               sgk_katilim_payi numeric)
language plpgsql immutable as $$
declare
    v_tutar   numeric := round(coalesce(p_tutar, 0), 2);
    v_sgkl    numeric := round(coalesce(p_sgk_liste, 0), 2);
    v_huv     numeric := round(coalesce(p_huv_liste, 0), 2);
    v_ek      numeric := round(coalesce(p_ek_katki, 0), 2);
    v_katilim numeric := round(coalesce(p_sgk_katilim, 0), 2);
    v_sgk     numeric := 0;
    v_oss     numeric := 0;
    v_hasta   numeric := 0;
    v_taban   numeric;
begin
    if p_rota = 1 then
        -- ÖZEL: hastanın kendi ödediği iş. Tamamı ek katkı kovasında.
        return query select v_tutar, 0::numeric, 0::numeric, 0::numeric, v_tutar, 0::numeric;

    elsif p_rota = 2 then
        -- ÖSS: liste fiyatı ana; sigorta karşılama oranı kadarını öder,
        --   kalanı hastanın provizyon payıdır.
        v_oss := round(coalesce(p_oss_prov,
                                v_tutar * coalesce(p_varsayilan_karsilama, 0) / 100), 2);
        v_oss := least(greatest(v_oss, 0), v_tutar);
        v_hasta := v_tutar - v_oss;
        return query select v_tutar, 0::numeric, v_oss, v_hasta, 0::numeric, 0::numeric;

    elsif p_rota = 3 then
        -- TSS: SGK SUT'u öder, tamamlayıcı sigorta TTB farkını üstlenir,
        --   hastane ek katkısı hastaya kalır. Satır tutarı bu üçünün TOPLAMI.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_oss := round(coalesce(p_oss_prov, v_huv), 2);
        v_tutar := round(v_sgk + v_oss + v_ek, 2);
        return query select v_tutar, v_sgk, v_oss, 0::numeric, v_ek, v_katilim;

    elsif p_rota = 4 then
        -- KARMA: TTB ana tutar. SGK SUT kadarını öder; tamamlayıcı poliçe
        --   kalanın onayladığı kadarını, artan hastaya kalır.
        v_tutar := case when v_huv > 0 then v_huv else v_tutar end;
        v_sgk := least(round(coalesce(p_sgk_prov, v_sgkl), 2), v_tutar);
        v_taban := v_tutar - v_sgk;
        v_oss := least(round(coalesce(p_oss_prov, v_taban), 2), v_taban);
        v_hasta := v_tutar - v_sgk - v_oss;
        return query select v_tutar, v_sgk, v_oss, v_hasta, 0::numeric, v_katilim;

    else
        -- SGK: SUT bedeli + hastane ek katkısı. Satır tutarı ikisinin toplamı.
        v_sgk := round(coalesce(p_sgk_prov, v_sgkl), 2);
        v_tutar := round(v_sgk + v_ek, 2);
        return query select v_tutar, v_sgk, 0::numeric, 0::numeric, v_ek, v_katilim;
    end if;
end $$;

comment on function public.fn_belge_satir_dagit is
  'Satır tutarını beş kovaya böler (470, Dosya/KurumAltKurum.xlsx). Rota 1/2/4 fiyatı böler, 3/5 kovaları toplar.';

-- ------------------------------------------------------------- denge tetiği --
-- Kova toplamı satır tutarını tutmalı. Ertelenmiş: yazıcı önce satırı, sonra
--   dağılımı yazıyor - satır satır kontrol, ara durumda patlardı.
create or replace function public.tg_belge_satir_dagilim_denge()
returns trigger language plpgsql as $$
declare v_tutar numeric; v_toplam numeric;
begin
    select round(s.tutar, 2) into v_tutar
      from public.belge_satir s where s.id = new.belge_satir_id;
    if v_tutar is null then return new; end if;

    v_toplam := round(new.sgk + new.oss + new.hasta_provizyon + new.hasta_ek_katki, 2);
    if abs(v_tutar - v_toplam) > 0.005 then
        raise exception 'Dağılım satır tutarını tutmuyor: satır % , kovalar % (fark %).',
              v_tutar, v_toplam, v_tutar - v_toplam;
    end if;
    return new;
end $$;

drop trigger if exists tg_belge_satir_dagilim_denge on public.belge_satir_dagilim;
create constraint trigger tg_belge_satir_dagilim_denge
    after insert or update on public.belge_satir_dagilim
    deferrable initially deferred
    for each row execute function public.tg_belge_satir_dagilim_denge();

-- ------------------------------------------------------------- veri göçü --
create table if not exists public._yedek_belge_satir_pay_470 as
select id, kurum_tutar, hasta_tutar, karsilama, kurum_kapatilan, hasta_kapatilan,
       kurum_tahsil, hasta_tahsil, pay, provizyon_no, now() as yedek_tarihi
  from public.belge_satir where false;

insert into public._yedek_belge_satir_pay_470
     (id, kurum_tutar, hasta_tutar, karsilama, kurum_kapatilan, hasta_kapatilan,
      kurum_tahsil, hasta_tahsil, pay, provizyon_no, yedek_tarihi)
select s.id, s.kurum_tutar, s.hasta_tutar, s.karsilama, s.kurum_kapatilan,
       s.hasta_kapatilan, s.kurum_tahsil, s.hasta_tahsil, s.pay, s.provizyon_no, now()
  from public.belge_satir s
 where not exists (select 1 from public._yedek_belge_satir_pay_470 y where y.id = s.id);

-- Eski iki kova beş kovaya: kurum payı SGK'da sgk, diğerinde oss; hasta payı
--   karşılama oranı VARSA provizyon payı, yoksa ek katkı. Ciro değişmez.
insert into public.belge_satir_dagilim
       (belge_satir_id, rota, sgk_liste, huv_liste, sgk, oss,
        hasta_provizyon, hasta_ek_katki, sgk_katilim_payi,
        sgk_kapatilan, oss_kapatilan, hasta_provizyon_kapatilan,
        hasta_ek_katki_kapatilan, sgk_tahsil, oss_tahsil,
        hasta_provizyon_tahsil, hasta_ek_katki_tahsil, sgk_provizyon_no)
select s.id,
       public.fn_dagilim_rota(coalesce(k.tur, 1)::smallint,
                              coalesce(bb.alt_kurum, 0)::smallint,
                              coalesce(bb.sgk_kullan, 1)::smallint),
       case when k.tur = 3 then coalesce(s.kurum_tutar, 0) else 0 end,
       case when k.tur = 3 then 0 else coalesce(s.kurum_tutar, 0) end,
       case when k.tur = 3 then coalesce(s.kurum_tutar, 0) else 0 end,
       case when k.tur = 3 then 0 else coalesce(s.kurum_tutar, 0) end,
       case when coalesce(s.karsilama, 0) > 0 then coalesce(s.hasta_tutar, 0) else 0 end,
       -- EK KATKI = ARTAN. Eski satırların çoğunda pay hiç hesaplanmamıştır
       --   (ERP belgeleri, kurumsuz başvurular): tutarın tamamı hastanındır.
       --   Farkı buraya yazmak ciroyu korur ve denge tetiğini sağlar.
       round(coalesce(s.tutar, 0)
             - coalesce(s.kurum_tutar, 0)
             - case when coalesce(s.karsilama, 0) > 0 then coalesce(s.hasta_tutar, 0)
                    else 0 end, 2),
       0,
       case when k.tur = 3 then coalesce(s.kurum_kapatilan, 0) else 0 end,
       case when k.tur = 3 then 0 else coalesce(s.kurum_kapatilan, 0) end,
       case when coalesce(s.karsilama, 0) > 0 then coalesce(s.hasta_kapatilan, 0) else 0 end,
       case when coalesce(s.karsilama, 0) > 0 then 0 else coalesce(s.hasta_kapatilan, 0) end,
       case when k.tur = 3 then coalesce(s.kurum_tahsil, 0) else 0 end,
       case when k.tur = 3 then 0 else coalesce(s.kurum_tahsil, 0) end,
       case when coalesce(s.karsilama, 0) > 0 then coalesce(s.hasta_tahsil, 0) else 0 end,
       case when coalesce(s.karsilama, 0) > 0 then 0 else coalesce(s.hasta_tahsil, 0) end,
       coalesce(s.provizyon_no, '')
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.belge_basvuru bb on bb.id = b.id
  left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
 where not exists (select 1 from public.belge_satir_dagilim d
                    where d.belge_satir_id = s.id)
on conflict (belge_satir_id) do nothing;

-- Satır PAY kodu da ince kod uzayına: 1 -> 1/4, 2 -> 2/3 (aynı kural).
update public.belge_satir s
   set pay = case when s.pay = 2 then (case when k.tur = 3 then 2 else 3 end)
                  when s.pay = 1 then (case when coalesce(s.karsilama, 0) > 0 then 1 else 4 end)
                  else s.pay end
  from public.belge b
  left join public.belge_basvuru bb on bb.id = b.id
  left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
 where b.id = s.belge_id
   and s.pay in (1, 2)
   and exists (select 1 from public._yedek_belge_satir_pay_470 y
                where y.id = s.id and y.pay = s.pay);

do $$
begin
    raise notice '470 tamam: % satir dagilimi yazildi (% belge satiri)',
        (select count(*) from public.belge_satir_dagilim),
        (select count(*) from public.belge_satir);
end $$;
