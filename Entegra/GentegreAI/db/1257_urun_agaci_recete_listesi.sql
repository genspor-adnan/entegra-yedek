-- =============================================================================
--  1257  ÜRÜN AĞACI (REÇETE) LİSTESİ - seviyeye göre (mockup urun_agaci_listesi_v2.html)
--
--  Kullanıcı 04.11.2026: "ürün ağacı listesini mockup'a göre düzenle (sayı kutularını, butonları falan ekle)".
--
--  Basit: "Üretilebilir" (stok kaç partiye yeter) - fn_urun_agaci_uretilebilir.
--  Denetimli: reçete ONAY AKIŞI - 0 taslak · 1 onayda · 2 onaylı (yürürlükte) · 3 kilitli (yeni sürüm onaylanınca eski).
--    Onaylama e-imzalı (parola + gerekçe), aksiyon yetkisi uretim.recete.onay, dört göz (onaya gönderen ≠ onaylayan),
--    ECN no (ECN-YYYY-NNN) ve yürürlük tarihi; onaysız reçeteden üretim emri açılmaz. Pasife alma gerekçeli.
--  Veri yapısı yine tek: basit / standart kurulumda kolonlar boş kalır, web gizler.
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.urun_agaci
    add column if not exists onay_durum     smallint not null default 0,
    add column if not exists onaya_gonderen integer,
    add column if not exists onaya_gonderme timestamp with time zone,
    add column if not exists onaylayan      integer,
    add column if not exists onay_tarihi    timestamp with time zone,
    add column if not exists onay_gerekce   varchar(500),
    add column if not exists ecn_no         varchar(30),
    add column if not exists yururluk       date,
    add column if not exists pasif_neden    varchar(300);

comment on column public.urun_agaci.onay_durum is
  'Reçete onay akışı (denetimli seviye, 1257): 0 taslak · 1 onayda · 2 onaylı / yürürlükte · 3 kilitli (eski onaylı sürüm). Basit / standartta 0 kalır.';
comment on column public.urun_agaci.ecn_no is 'Mühendislik değişiklik no (ECN-YYYY-NNN), onayda verilir (1257).';

create index if not exists ix_urun_agaci_onay on public.urun_agaci (onay_durum) where onay_durum = 1;

-- ------------------------------------------------------------ üretilebilir --
-- Reçetenin 1 çıktısı için stok kaç kez yetiyor: bileşen başına (kalan - rezerve) / net gerekli, en küçüğü × çıktı.
--   Depo: satırın deposu, yoksa reçetenin sarf deposu, o da yoksa bütün depolar. Bileşeni olmayan reçete null (boş).
create or replace function public.fn_urun_agaci_uretilebilir(p_agac_id integer)
returns numeric
language sql stable as $function$
    with a as (select id, cikti_miktar, sarf_depo_id from public.urun_agaci where id = p_agac_id),
    s as (select s.bilesen_stok_id,
                 coalesce(s.depo_id, a.sarf_depo_id)                         as depo_id,
                 s.miktar * (1 + coalesce(s.fire_yuzde, 0) / 100)             as gerekli
            from public.urun_agaci_satir s
            join a on a.id = s.agac_id),
    k as (select s.gerekli,
                 (select coalesce(sum(d.kalan - coalesce(d.rezerve, 0)), 0)
                    from public.stok_durum d
                   where d.stok_id = s.bilesen_stok_id
                     and (s.depo_id is null or d.depo_id = s.depo_id))         as kalan
            from s)
    select case when (select count(*) from k) = 0 then null
                else greatest(0, floor(min(case when k.gerekli <= 0 then 999999 else k.kalan / k.gerekli end)))
                     * coalesce((select cikti_miktar from a), 1) end
      from k;
$function$;

comment on function public.fn_urun_agaci_uretilebilir(integer) is
  'Reçeteden mevcut stokla üretilebilecek mamul miktarı (1257, liste "Üretilebilir" kolonu / "Malzeme eksik" cipi).';

-- ------------------------------------------------------------------- yetki --
-- Reçete onayı aksiyon yetkisi (uretim.fis.serbest deseni): "uretim" yetkisi olan roller aynı hakla alır.
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select v.kod, v.ad, k.grup, v.tur, k.sira + v.art, k.urun_modu, k.modul
  from public.yetki k
  cross join (values ('uretim.recete.onay', 'Reçete (ürün ağacı) onayı - e-imza', 1::smallint, 6)) as v(kod, ad, tur, art)
 where k.kod = 'uretim'
on conflict (kod) do update set ad = excluded.ad, grup = excluded.grup, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yl.id, ry.gor, ry.ekle, ry.degistir, ry.sil, '', ry.kapsam, 0
  from public.yetki yk
  join public.yetki yl on yl.kod = 'uretim.recete.onay'
  join public.rol_yetki ry on ry.yetki_id = yk.id and ry.gor = 1
 where yk.kod = 'uretim'
on conflict (rol_id, yetki_id) do nothing;

do $$ begin raise notice '1257 tamam: urun_agaci onay akışı kolonları, fn_urun_agaci_uretilebilir, uretim.recete.onay'; end $$;
