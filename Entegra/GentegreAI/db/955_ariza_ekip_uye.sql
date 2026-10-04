-- ============================================================================
--  Gentegre AI — ARIZA EKİP ÜYELİĞİ + NÖBETÇİ
--  955_ariza_ekip_uye.sql
--
--  Kullanıcı: "talep yaptığımız birim / kişinin bundan hızlı ve pratik şekilde
--  haberi olması ve gerekli aksiyonu alabilmesi lazım" → mockup
--  Ekranlar/Taleplerim/gelen_talepler.html onaylandı.
--
--  Arıza kategorisi → ekip (ariza_kategori_ekip) vardı ama ekibin KİMLER
--  olduğu yoktu; iş ya herkese ya kimseye düşüyordu.
--
--  KURAL (fn_ariza_ekip_alicilari):
--    • Ekibin aktif üyesi varsa iş YALNIZ üyelere düşer.
--    • Üyesi tanımsız ekipte rolünde `ariza` değiştirme yetkisi olan herkese
--      (eski davranış - kurulum ilk gün boş kalmasın).
--    • ACİL SMS: nöbetçi(ler); nöbetçi yoksa yukarıdaki alıcılar.
--  Yalnız dev docker'a uygulanır.
-- ============================================================================

create table if not exists public.ariza_ekip_uye (
    ekip          smallint    not null,
    kullanici_id  integer     not null references public.taraf_kullanici (id) on delete cascade,
    nobetci       smallint    not null default 0,
    aktif         smallint    not null default 1,
    ekleyen       integer     not null default 0,
    ekleme_tarihi timestamptz not null default now(),
    primary key (ekip, kullanici_id),
    constraint ck_ariza_ekip_uye_nobetci check (nobetci in (0, 1)),
    constraint ck_ariza_ekip_uye_aktif check (aktif in (0, 1))
);
create index if not exists ix_ariza_ekip_uye_kullanici on public.ariza_ekip_uye (kullanici_id) where aktif = 1;

comment on table public.ariza_ekip_uye is
  '955: arıza ekibinin üyeleri ve nöbetçisi. Üyesi olan ekipte iş yalnız üyelere düşer.';

-- ---------------------------------------------- ekibe yetkili kullanıcılar
create or replace function public.fn_ariza_ekip_alicilari(p_ekip smallint, p_yalniz_nobetci boolean default false)
returns setof integer language sql stable as $fn$
    with uye as (
        select u.kullanici_id, u.nobetci
          from public.ariza_ekip_uye u
          join public.taraf_kullanici k on k.id = u.kullanici_id and k.aktif = 1
         where u.ekip = p_ekip and u.aktif = 1
    ), yetkili as (
        select k.id
          from public.taraf_kullanici k
         where k.aktif = 1
           and exists (select 1 from public.rol_yetki ry
                         join public.yetki y on y.id = ry.yetki_id
                        where y.kod = 'ariza' and ry.degistir = 1
                          and (ry.rol_id = k.rol_id
                               or ry.rol_id in (select kr.rol_id from public.kullanici_rol kr
                                                 where kr.kullanici_id = k.id)))
    )
    -- nöbetçi istendiyse ve varsa yalnız nöbetçi
    select kullanici_id from uye where p_yalniz_nobetci and nobetci = 1
    union
    select kullanici_id from uye
     where not (p_yalniz_nobetci and exists (select 1 from uye where nobetci = 1))
    union
    select id from yetkili
     where not exists (select 1 from uye)
$fn$;

comment on function public.fn_ariza_ekip_alicilari is
  '955: ekibin işi kime düşer - aktif üyeler; üyesiz ekipte ariza yetkilileri. '
  'p_yalniz_nobetci: acil SMS için nöbetçi (yoksa tüm alıcılar).';

-- ---------------------------------------------- ayar ekranı yetkisi: ariza
do $$
begin
    raise notice '955 tamam: ekip üyesi %, örnek alıcı (Biyomedikal) %',
        (select count(*) from public.ariza_ekip_uye),
        (select count(*) from public.fn_ariza_ekip_alicilari(1::smallint));
end $$;
