-- =====================================================================
-- 987 - BANKO OTURUMU (vardiya): acilis -> onay -> gun ici -> gun sonu
--                                sayimi -> teslim -> kapanis
--
-- Kullanici 08.10.2026: "banko vardiya yi da mockup gibi yap".
-- Tasarim: Ekranlar/Kayit Kabul/banko_oturum_akisi_v2.html
--
-- OTURUM = BANKO + GOREVLI. Banko taniminda kullanici yok; sabah acilista
--   uygun banko secilir ve oturum GIRIS YAPAN kullanicinin adiyla baslar.
--   Yalniz kullaniciyi tutmak "hangi kasadan", yalniz bankoyu tutmak "kim
--   saydi" sorusunu cevapsiz birakirdi.
--
-- DEVIR ELLE YAZILMAZ: acilistaki sistem devri onceki oturumun
--   `kasada_birakilan` degeridir (fn_banko_devir). Elle yazilabilse
--   kasadaki para ile kayit arasindaki bag kopardi.
--
-- FARK ACILISTA YAZILIR: devir ile sayim tutmuyorsa fark kapanista degil
--   ACILISTA kaydedilir - sonraki gorevli baskasinin farkini devralmasin.
-- =====================================================================

create table if not exists public.banko_oturum (
    id                  bigserial primary key,
    banko_id            integer      not null references public.banko(id),
    sube_id             integer      not null,
    -- Gorevli: oturumu acan kullanici.
    kullanici_id        integer      not null,
    vardiya             varchar(30)  not null default '',
    -- 1 = acilis onayi bekliyor, 2 = acik, 3 = teslime gonderildi
    -- (kapanis onayi bekliyor), 4 = kapandi, 5 = acilis reddedildi
    durum               smallint     not null default 1,

    acilis_talep_ts     timestamptz  not null default now(),
    acilis_ts           timestamptz,
    kapanis_talep_ts    timestamptz,
    kapanis_ts          timestamptz,

    -- ------------------------------------------------------------ acilis
    devir_tutar         numeric(18,2) not null default 0,   -- sistem
    acilis_sayim        numeric(18,2) not null default 0,   -- kasada bulunan
    acilis_fark         numeric(18,2) not null default 0,   -- sayim - devir
    acilis_not          varchar(400) not null default '',
    acilis_onay_id      integer,
    acilis_onay_ts      timestamptz,
    red_neden           varchar(400) not null default '',

    -- ---------------------------------------------------------- gun sonu
    kapanis_sayim       numeric(18,2) not null default 0,
    -- Olmasi gereken nakit, KAPANIS ANINDA dondurulur: hareketlerden
    --   turetilen deger sonradan bir duzeltme fisiyle degisirse kapanmis
    --   oturumun farki kendiliginden oynardi.
    kapanis_beklenen    numeric(18,2) not null default 0,
    kapanis_fark        numeric(18,2) not null default 0,
    -- 1 para ustu hatasi, 2 eksik tahsilat, 3 fazla tahsilat,
    -- 4 kayit dışı odeme, 5 sayim hatasi, 99 diger
    fark_neden          smallint     not null default 0,
    fark_aciklama       varchar(600) not null default '',
    -- Fark AYRI FISLE muhasebelesir: kasa bakiyesi sayimla esitlenir, fark
    --   gecmisi bozulmaz.
    fark_islem_id       integer,

    kasada_birakilan    numeric(18,2) not null default 0,   -- yarinin devri
    teslim_edilen       numeric(18,2) not null default 0,
    teslim_alan_id      integer,
    kapanis_onay_id     integer,
    kapanis_onay_ts     timestamptz,
    tutanak_no          varchar(30)  not null default '',

    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now(),
    degistiren          integer      not null default 0,
    degistirme_tarihi   timestamptz
);

-- BIR BANKODA TEK CANLI OTURUM: ikinci oturum acilsa iki gorevli ayni
--   kasadan islem yapar ve gun sonu sayimi kime ait olacagi belirsiz kalir.
create unique index if not exists banko_oturum_canli_banko
    on public.banko_oturum (banko_id) where durum in (1, 2, 3);
-- BIR GOREVLI TEK CANLI OTURUM: ayni kisi iki bankoda ayni anda calismaz;
--   tahsilat hangi kasaya yazilacagi belirsiz olurdu.
create unique index if not exists banko_oturum_canli_kullanici
    on public.banko_oturum (kullanici_id) where durum in (1, 2, 3);
create index if not exists banko_oturum_banko_ix
    on public.banko_oturum (banko_id, durum, acilis_ts desc);
create index if not exists banko_oturum_sube_ix
    on public.banko_oturum (sube_id, durum);

-- --------------------------------------------------------- kupur dokumu --
-- Sayim kupur dokumuyle yapilir (banko ayari `kupur_dokumu`): "7.140 saydim"
--   demek ile "20x200 + 22x100 + ..." demek denetimde ayni sey degil.
create table if not exists public.banko_oturum_kupur (
    id                  bigserial primary key,
    oturum_id           bigint       not null references public.banko_oturum(id) on delete cascade,
    -- 1 = acilis sayimi, 2 = kapanis sayimi
    asama               smallint     not null default 2,
    birim               numeric(10,2) not null,
    adet                integer      not null default 0,
    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now()
);

create index if not exists banko_oturum_kupur_ix
    on public.banko_oturum_kupur (oturum_id, asama);

-- ------------------------------------------- kasa islemi -> oturum bagi --
-- Her tahsilat satiri oturum numarasini tasir: "parayi kim, hangi kasadan
--   aldi" sorusu tek kolonla cevaplanir. Eski satirlarda NULL kalir -
--   oturum oncesi donem.
alter table public.kasa_islem add column if not exists oturum_id bigint;
create index if not exists kasa_islem_oturum_ix
    on public.kasa_islem (oturum_id) where oturum_id is not null;

-- ------------------------------------------------------------- devir ----
-- Bankonun sistem devri: en son KAPANMIS oturumun kasada biraktigi tutar.
--   Hic oturum yoksa 0 - ilk acilista kasa bos kabul edilir, gorevli
--   sayimi girer ve fark acilista yazilir.
create or replace function public.fn_banko_devir(p_banko_id integer)
returns numeric language sql stable as $$
  select coalesce((select o.kasada_birakilan
                     from public.banko_oturum o
                    where o.banko_id = p_banko_id and o.durum = 4
                    order by o.kapanis_ts desc nulls last, o.id desc
                    limit 1), 0)::numeric(18,2);
$$;

-- ------------------------------------------------------- oturum ozeti ----
-- Sayaclar HAREKETLERDEN turetilir, oturum satirinda tutulmaz: iki yerde
--   tutulsa biri digerini yalanlardi. Nakit/POS ayrimi islem TURUNUN ana
--   hesap turunden gelir (K = kasa/nakit, P = POS, B = banka/havale) -
--   POS ve havale kasada para olarak DURMAZ, sayima girmez.
create or replace view public.v_banko_oturum_ozet as
select o.id,
       o.banko_id, b.kod as banko_kod, b.ad as banko_ad, b.hesap_id,
       b.acilis_onay, b.gun_sonu_onay, b.kupur_dokumu, b.devir_tutar as banko_devir_hedef,
       o.sube_id, o.kullanici_id, o.vardiya, o.durum,
       o.acilis_talep_ts, o.acilis_ts, o.kapanis_talep_ts, o.kapanis_ts,
       o.devir_tutar, o.acilis_sayim, o.acilis_fark, o.acilis_not,
       o.acilis_onay_id, o.acilis_onay_ts, o.red_neden,
       o.kapanis_sayim, o.kapanis_beklenen, o.kapanis_fark, o.fark_neden,
       o.fark_aciklama, o.fark_islem_id, o.kasada_birakilan, o.teslim_edilen,
       o.teslim_alan_id, o.kapanis_onay_id, o.kapanis_onay_ts, o.tutanak_no,
       coalesce(h.nakit, 0)::numeric(18,2)   as nakit_tahsilat,
       coalesce(h.nakit_iade, 0)::numeric(18,2) as nakit_iade,
       coalesce(h.pos, 0)::numeric(18,2)     as pos_tutar,
       coalesce(h.banka, 0)::numeric(18,2)   as banka_tutar,
       coalesce(h.adet, 0)                   as islem_adet,
       (o.devir_tutar + o.acilis_fark + coalesce(h.nakit, 0) - coalesce(h.nakit_iade, 0))
         ::numeric(18,2)                     as beklenen_nakit
  from public.banko_oturum o
  join public.banko b on b.id = o.banko_id
  left join (
        select k.oturum_id,
               sum(case when t.ana_hesap_turu = 'K' and t.yon > 0 then k.yerel_tutar else 0 end) as nakit,
               sum(case when t.ana_hesap_turu = 'K' and t.yon < 0 then k.yerel_tutar else 0 end) as nakit_iade,
               sum(case when t.ana_hesap_turu = 'P' then k.yerel_tutar else 0 end)               as pos,
               sum(case when t.ana_hesap_turu = 'B' then k.yerel_tutar else 0 end)               as banka,
               count(*)                                                                          as adet
          from public.kasa_islem k
          join public.kasa_islem_turu t on t.kod = k.tur
         -- IPTAL EDILEN ISLEM SAYILMAZ (durum 9): iptal fisi kasadan para
         --   cikmadigi icin sayimda da yoktur.
         where k.oturum_id is not null and k.durum <> 9
         group by k.oturum_id) h on h.oturum_id = o.id;

-- -------------------------------------------------------------- yetki ----
-- ONAY KUYRUGU EKRAN YETKISI (tur 0), aksiyon degil: ekran yetkileri tur 0
--   olmak zorunda - istemci `yetki('kod')` ile rotayi ve menu satirini tur 0
--   listesinden cozuyor, tur 1 (aksiyon) kodu orada hic gorunmuyor ve ekran
--   sessizce acilmiyordu. "Onaylayabilir" ayrimi bu ekranin yetkisidir:
--   oturum acan herkes onaylayamaz.
insert into public.yetki (kod, ad, grup, tur, sira)
select v.kod, v.ad, 'Kasa', v.tur, v.sira
  from (values
    ('banko_oturum',            'Banko Oturumu',   0::smallint, 456::smallint),
    ('banko_onay',              'Banko Onayları',  0::smallint, 457::smallint),
    ('banko_oturum.yeniden_ac', 'Kapanmış oturumu yeniden aç', 1::smallint, 458::smallint)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

-- Yonetici: yetkiler tek tek yazili, yeni yetki ona da verilmeli.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and (y.kod in ('banko_oturum', 'banko_onay') or y.kod like 'banko_oturum.%')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- Banko Sorumlusu: oturum acar/kapatir VE onaylar.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'kayit_kabul_sorumlu'
   and y.kod in ('banko_oturum', 'banko_onay', 'banko_oturum.yeniden_ac')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- Banko Gorevlisi ve Kasiyeri: oturum acar, sayim girer; ONAYLAMAZ
--   (kendi oturumunu onaylamak denetimi anlamsiz kilardi).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod in ('kayit_kabul', 'vezne') and y.kod = 'banko_oturum'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

update public.rol set yetki_surumu = yetki_surumu + 1
 where kod in ('yonetici', 'kayit_kabul_sorumlu', 'kayit_kabul', 'vezne');

do $$
begin
  raise notice '987: banko_oturum / banko_oturum_kupur / v_banko_oturum_ozet / fn_banko_devir hazir';
end $$;
