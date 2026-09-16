-- 718: HEKİM ÇALIŞMA PLANI (kullanıcı: "çalışma planını projeye ekle ·
-- randevu verilebilir checklerini iptal et ve buraya bağla").
--
-- Mockup: Ekranlar/Muayene/hekim_calisma_plani.html. "Randevu verilebilir"
-- bayrakları (taraf.randevu_verilebilir, departman.randevu_verilebilir) iki
-- anlam taşıyordu (randevu alır / kayıt kabulde görünür) ve şube-gün-kanal
-- bağlamı yoktu. Yerine: hekim × şube × bölüm × gün/saat × kanal ŞABLONU
-- (her hafta kendiliğinden tekrar eder) + İSTİSNA (izin, kongre, saat
-- değişikliği, ek mesai). Haftalık plan elle çizilmez, türetilir
-- (fn_hekim_calisma_bloklari). Hekim "randevu verilebilir" = aktif şablonu
-- var (fn_hekim_planli); bölüm = o bölümde aktif şablon var (fn_bolum_planli).
-- Bayrak kolonları DURUR (göç izi), hiçbir ekran/sorgu okumaz; var olan
-- işaretli hekimler için randevu ayarlarından (randevu_bolum_ayar > genel)
-- varsayılan şablon üretilir - hiçbir hekim listeden düşmez.

-- ================================================================= tablolar ==
create table if not exists public.hekim_calisma_sablon (
    id               integer generated always as identity primary key,
    sube_id          integer references public.sube(id),          -- null = tüm şubeler
    hekim_id         integer not null references public.taraf(id),
    departman_id     integer not null references public.departman(id),
    ad               varchar(80)  not null default '',
    gunler           varchar(20)  not null default '1,2,3,4,5',    -- 1 Pzt … 7 Paz (randevu.calisma_gunleri biçimi)
    bas1             varchar(5)   not null default '09:00',       -- 'HH:MM' (generic kart metin yazar)
    bit1             varchar(5)   not null default '12:30',
    bas2             varchar(5),
    bit2             varchar(5),
    slot_dk          smallint     not null default 15,
    kanallar         varchar(20)  not null default 'B,P,C',        -- B banko · P portal · C çağrı merkezi
    gunluk_kota      smallint     not null default 0,              -- 0 = sınırsız (blok kapasitesi)
    portal_yuzde     smallint     not null default 0,
    kontrol_yuzde    smallint     not null default 0,
    tekrar           smallint     not null default 1,              -- 1 her hafta · 2 iki haftada bir
    gecerli_bas      date         not null default current_date,
    gecerli_bit      date,                                         -- null = süresiz
    aktif            smallint     not null default 1,
    aciklama         varchar(300) not null default '',
    ekleyen          integer      not null default 0,
    ekleme_tarihi    timestamptz  not null default now(),
    degistiren       integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint ck_hcs_saat check (bas1 < bit1 and (nullif(bas2, '') is null or (nullif(bit2, '') is not null and bas2 < bit2 and bas2 >= bit1))),
    constraint ck_hcs_tekrar check (tekrar in (1, 2))
);
create index if not exists ix_hcs_hekim on public.hekim_calisma_sablon (hekim_id, aktif);
create index if not exists ix_hcs_departman on public.hekim_calisma_sablon (departman_id, aktif);

create table if not exists public.hekim_calisma_istisna (
    id               integer generated always as identity primary key,
    sube_id          integer references public.sube(id),          -- null = tüm şubeler
    hekim_id         integer not null references public.taraf(id),
    departman_id     integer references public.departman(id),     -- null = hekimin tüm bölümleri
    tur              smallint     not null default 1,              -- calisma.istisna_tur
    bas_tarih        date         not null,
    bit_tarih        date         not null,
    saat_bas         varchar(5),                                   -- 3 saat değişikliği / 4 ek mesai ('HH:MM')
    saat_bit         varchar(5),
    slot_dk          smallint,
    kanallar         varchar(20),
    aciklama         varchar(300) not null default '',
    durum            smallint     not null default 1,              -- 1 onaylı · 0 bekliyor · 2 iptal
    ekleyen          integer      not null default 0,
    ekleme_tarihi    timestamptz  not null default now(),
    degistiren       integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint ck_hci_tarih check (bas_tarih <= bit_tarih),
    constraint ck_hci_saat check (tur not in (3, 4) or (nullif(saat_bas, '') is not null and nullif(saat_bit, '') is not null and saat_bas < saat_bit))
);
create index if not exists ix_hci_hekim on public.hekim_calisma_istisna (hekim_id, bas_tarih, bit_tarih);

-- Randevusuz kabul alan bölüm (acil, lab, radyoloji): plan gerektirmez, kayıt
--   kabul / başvuru bölüm listesinde hep görünür.
alter table public.departman add column if not exists randevusuz_kabul smallint not null default 0;

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('calisma.istisna_tur', 'Çalışma İstisnası Türü'),
    ('calisma.tekrar',      'Çalışma Planı Tekrarı')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('calisma.istisna_tur', 1, 'İzin'), ('calisma.istisna_tur', 2, 'Kongre / eğitim'),
    ('calisma.istisna_tur', 3, 'Saat değişikliği'), ('calisma.istisna_tur', 4, 'Ek mesai'),
    ('calisma.istisna_tur', 5, 'Kapalı'),
    ('calisma.tekrar', 1, 'Her hafta'), ('calisma.tekrar', 2, 'İki haftada bir')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================ yetkiler ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif, modul)
select 'randevu.plan', 'Çalışma planı (hekim × şube × bölüm)', 'Randevu', 0, 31, 1, 'randevu'
 where not exists (select 1 from public.yetki where kod = 'randevu.plan');
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'randevu.plan'
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- ============================================================= fonksiyonlar ==
-- Hekimin bugün itibarıyla geçerli aktif şablonu var mı? (= "randevu verilebilir")
create or replace function public.fn_hekim_planli(p_hekim integer) returns smallint
language sql stable as $$
    select case when exists (
        select 1 from public.hekim_calisma_sablon s
         where s.hekim_id = p_hekim and s.aktif = 1
           and (s.gecerli_bit is null or s.gecerli_bit >= current_date)) then 1 else 0 end::smallint
$$;

-- Bölümde plan var mı ya da randevusuz kabul alıyor mu? (= "randevu bölümü")
create or replace function public.fn_bolum_planli(p_departman integer) returns smallint
language sql stable as $$
    select case when exists (
        select 1 from public.hekim_calisma_sablon s
         where s.departman_id = p_departman and s.aktif = 1
           and (s.gecerli_bit is null or s.gecerli_bit >= current_date)) then 1 else 0 end::smallint
$$;

-- TÜRETİLEN PLAN: şablon + istisna → tarih aralığındaki bloklar.
--   kaynak: 1 şablon · 2 istisna (saat değişikliği / ek mesai) · 3 kapalı (izin/kongre/kapalı; bas/bit null)
create or replace function public.fn_hekim_calisma_bloklari(
    p_sube integer, p_bas date, p_bit date, p_hekim integer default null, p_departman integer default null)
returns table (
    hekim_id integer, hekim varchar, sube_id integer, departman_id integer, departman varchar,
    gun date, saat_bas time, saat_bit time, slot_dk smallint, kanallar varchar, kaynak smallint,
    istisna_tur smallint, sablon_id integer, istisna_id integer, aciklama varchar)
language sql stable as $$
    with g as (select d::date as gun from generate_series(p_bas, p_bit, interval '1 day') d),
    sab as (
        select s.*, g.gun
          from public.hekim_calisma_sablon s
          join g on g.gun >= s.gecerli_bas and (s.gecerli_bit is null or g.gun <= s.gecerli_bit)
         where s.aktif = 1
           and (p_sube = 0 or s.sube_id is null or s.sube_id = p_sube)
           and (p_hekim is null or s.hekim_id = p_hekim)
           and (p_departman is null or s.departman_id = p_departman)
           and (',' || s.gunler || ',') like ('%,' || extract(isodow from g.gun)::text || ',%')
           and (s.tekrar = 1 or (((g.gun - s.gecerli_bas) / 7) % 2) = 0)),
    bl as (
        select s.hekim_id, coalesce(s.sube_id, p_sube) as sube_id, s.departman_id, s.gun,
               s.bas1::time as saat_bas, s.bit1::time as saat_bit, s.slot_dk, s.kanallar, s.id as sablon_id from sab s
        union all
        select s.hekim_id, coalesce(s.sube_id, p_sube), s.departman_id, s.gun,
               s.bas2::time, s.bit2::time, s.slot_dk, s.kanallar, s.id from sab s where nullif(s.bas2, '') is not null),
    ist as (
        select i.*, g.gun
          from public.hekim_calisma_istisna i
          join g on g.gun between i.bas_tarih and i.bit_tarih
         where i.durum = 1
           and (p_sube = 0 or i.sube_id is null or i.sube_id = p_sube)
           and (p_hekim is null or i.hekim_id = p_hekim)
           and (p_departman is null or i.departman_id is null or i.departman_id = p_departman)),
    ezilen as (   -- izin / kongre / kapalı / saat değişikliği o günün şablon bloklarını kaldırır
        select b.* from bl b
         where exists (select 1 from ist i
                        where i.hekim_id = b.hekim_id and i.gun = b.gun and i.tur in (1, 2, 3, 5)
                          and (i.departman_id is null or i.departman_id = b.departman_id)
                          and (i.sube_id is null or i.sube_id = b.sube_id)))
    select b.hekim_id, t.unvan as hekim, b.sube_id, b.departman_id, d.ad as departman, b.gun, b.saat_bas, b.saat_bit, b.slot_dk, b.kanallar,
           1::smallint, null::smallint, b.sablon_id, null::integer, ''::varchar
      from bl b join public.taraf t on t.id = b.hekim_id join public.departman d on d.id = b.departman_id
     where not exists (select 1 from ezilen e where e.sablon_id = b.sablon_id and e.gun = b.gun and e.saat_bas = b.saat_bas)
    union all   -- saat değişikliği (3) ve ek mesai (4): yeni blok
    select i.hekim_id, t.unvan, coalesce(i.sube_id, p_sube),
           coalesce(i.departman_id, (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1),
                    (select s.departman_id from public.hekim_calisma_sablon s where s.hekim_id = i.hekim_id and s.aktif = 1 order by s.id limit 1)),
           coalesce(d.ad, ''), i.gun, i.saat_bas::time, i.saat_bit::time,
           coalesce(i.slot_dk, (select b.slot_dk from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1), 15),
           coalesce(i.kanallar, 'B'), 2::smallint, i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id
      left join public.departman d on d.id = coalesce(i.departman_id,
           (select b.departman_id from bl b where b.hekim_id = i.hekim_id and b.gun = i.gun limit 1))
     where i.tur in (3, 4)
    union all   -- kapalı günler (izin / kongre / kapalı): görünsün, slot üretmesin
    select i.hekim_id, t.unvan, coalesce(i.sube_id, p_sube), coalesce(i.departman_id, 0), coalesce(d.ad, ''), i.gun,
           null::time, null::time, 0::smallint, ''::varchar, 3::smallint, i.tur, null::integer, i.id, i.aciklama
      from ist i join public.taraf t on t.id = i.hekim_id left join public.departman d on d.id = i.departman_id
     where i.tur in (1, 2, 5)
     order by gun, hekim, saat_bas
$$;

-- ================================================================ görünümler ==
create or replace view public.v_sube_lookup as
select id, ad, aktif from public.sube;

create or replace view public.v_hekim_calisma_sablon as
select s.id, s.sube_id, coalesce(sb.ad, 'Tüm şubeler') as sube_adi, s.hekim_id, t.unvan as hekim_adi,
       s.departman_id, d.ad as departman_adi, s.ad, s.gunler, s.bas1, s.bit1, s.bas2, s.bit2, s.slot_dk, s.kanallar,
       s.gunluk_kota, s.portal_yuzde, s.kontrol_yuzde, s.tekrar, s.gecerli_bas, s.gecerli_bit, s.aktif, s.aciklama,
       (s.bas1 || '–' || s.bit1 || case when nullif(s.bas2, '') is not null then ' · ' || s.bas2 || '–' || s.bit2 else '' end)::varchar(40) as saat,
       (select string_agg(case g when '1' then 'Pzt' when '2' then 'Sal' when '3' then 'Çar' when '4' then 'Per'
                                 when '5' then 'Cum' when '6' then 'Cmt' when '7' then 'Paz' end, ' ' order by g)
          from unnest(string_to_array(s.gunler, ',')) g)::varchar(40) as gun_adlari
  from public.hekim_calisma_sablon s
  join public.taraf t on t.id = s.hekim_id
  join public.departman d on d.id = s.departman_id
  left join public.sube sb on sb.id = s.sube_id;

create or replace view public.v_hekim_calisma_istisna as
select i.id, i.sube_id, coalesce(sb.ad, 'Tüm şubeler') as sube_adi, i.hekim_id, t.unvan as hekim_adi,
       i.departman_id, coalesce(d.ad, 'Tüm bölümler') as departman_adi, i.tur, i.bas_tarih, i.bit_tarih, i.saat_bas, i.saat_bit,
       i.slot_dk, i.kanallar, i.aciklama, i.durum,
       (select count(*) from public.randevu r
         where r.hekim_id = i.hekim_id and r.durum in (1, 2) and r.baslangic::date between i.bas_tarih and i.bit_tarih
           and (i.tur in (1, 2, 5) or (i.tur = 3 and r.baslangic::time < i.saat_bas::time)))::int as etkilenen_randevu
  from public.hekim_calisma_istisna i
  join public.taraf t on t.id = i.hekim_id
  left join public.departman d on d.id = i.departman_id
  left join public.sube sb on sb.id = i.sube_id;

-- ================================================ bayrak → şablon (bir kez) ==
-- İşaretli her hekim için departmanına bir şablon: saatler randevu_bolum_ayar
--   (hekim satırı > bölüm satırı) yoksa genel referans; öğle arası varsa iki blok.
do $$
declare
    r record; v_bas text; v_bit text; v_ob text; v_ok text; v_slot int; v_gun text;
begin
    for r in
        select t.id as hekim_id, t.departman::integer as departman_id
          from public.taraf t
         where t.personel = 1 and t.randevu_verilebilir = 1 and coalesce(t.durum, 1) = 1
           and t.departman is not null
           and exists (select 1 from public.departman d where d.id = t.departman)
           and not exists (select 1 from public.hekim_calisma_sablon s where s.hekim_id = t.id)
    loop
        select coalesce(h.baslangic_saat, b.baslangic_saat, (select deger from public.referans where anahtar = 'randevu.baslangic_saat'), '09:00'),
               coalesce(h.bitis_saat,     b.bitis_saat,     (select deger from public.referans where anahtar = 'randevu.bitis_saat'), '18:00'),
               nullif(coalesce(h.ogle_baslangic, b.ogle_baslangic, (select deger from public.referans where anahtar = 'randevu.ogle_baslangic')), ''),
               nullif(coalesce(h.ogle_bitis,     b.ogle_bitis,     (select deger from public.referans where anahtar = 'randevu.ogle_bitis')), ''),
               coalesce(h.slot_dk, b.slot_dk, nullif((select deger from public.referans where anahtar = 'randevu.slot_dk'), '')::int, 15),
               coalesce(nullif(h.calisma_gunleri, ''), nullif(b.calisma_gunleri, ''), (select deger from public.referans where anahtar = 'randevu.calisma_gunleri'), '1,2,3,4,5')
          into v_bas, v_bit, v_ob, v_ok, v_slot, v_gun
          from (select 1) x
          left join public.randevu_bolum_ayar h on h.departman_id = r.departman_id and h.hekim_id = r.hekim_id and h.aktif = 1
          left join public.randevu_bolum_ayar b on b.departman_id = r.departman_id and b.hekim_id is null and b.aktif = 1;
        insert into public.hekim_calisma_sablon (hekim_id, departman_id, ad, gunler, bas1, bit1, bas2, bit2, slot_dk, aciklama)
        values (r.hekim_id, r.departman_id, 'Standart hafta', v_gun,
                v_bas, case when v_ob is not null and v_ok is not null then v_ob else v_bit end,
                case when v_ob is not null and v_ok is not null then v_ok end,
                case when v_ob is not null and v_ok is not null then v_bit end,
                v_slot, 'randevu verilebilir bayrağından üretildi (711)');
    end loop;
end $$;

-- Randevu verilen ama hekimsiz bölümler (acil, lab...) → randevusuz kabul.
update public.departman d set randevusuz_kabul = 1
 where d.randevu_verilebilir = 1 and d.durum = 1
   and not exists (select 1 from public.hekim_calisma_sablon s where s.departman_id = d.id);

-- ================================================ lookup'lar bayraktan plana ==
create or replace view public.v_hekim_lookup as
select id, unvan as ad, case when coalesce(durum, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
 where personel = 1 and public.fn_hekim_planli(t.id) = 1;

create or replace view public.v_randevu_bolum_lookup as
select id, case when kod = '' then ad::text else kod || ' - ' || ad end as ad, durum as aktif
  from public.departman d
 where public.fn_bolum_planli(d.id) = 1 or d.randevusuz_kabul = 1;

create or replace view public.v_basvuru_hekim as
 select t.id, t.unvan as ad, coalesce(t.kod, '') as kod,
        regexp_replace(coalesce(t.cep_tel, '') || ' ' || coalesce(t.telefon, ''), '[^0-9]', '', 'g') as telefon_ham,
        coalesce(t.departman::integer, 0) as bolum_id,
        coalesce((select regexp_replace(d.ad, '^—\s*', '') from public.departman d where d.id = t.departman), '') as bolum_adi,
        (select count(*) from public.belge_basvuru bb join public.belge b on b.id = bb.id
          where bb.personel_id = t.id and b.tur = 19 and b.tipi = 30 and b.belge_tarihi::date = current_date) as bugun_basvuru,
        coalesce(t.durum::integer, 1) as durum, 1::smallint as dis_mi
   from public.taraf t join public.taraf_personel p on p.id = t.id
  where t.personel = 1 and p.dis_hekim = 1 and public.fn_basvuru_hekim_dis_mi(0) = 1
 union all
 select t.id, t.unvan, coalesce(t.kod, ''),
        regexp_replace(coalesce(t.cep_tel, '') || ' ' || coalesce(t.telefon, ''), '[^0-9]', '', 'g'),
        coalesce(t.departman::integer, 0),
        coalesce((select regexp_replace(d.ad, '^—\s*', '') from public.departman d where d.id = t.departman), ''),
        (select count(*) from public.belge_basvuru bb join public.belge b on b.id = bb.id
          where bb.personel_id = t.id and b.tur = 19 and b.tipi = 30 and b.belge_tarihi::date = current_date),
        coalesce(t.durum::integer, 1), 0::smallint
   from public.taraf t
  where t.personel = 1 and public.fn_hekim_planli(t.id) = 1 and public.fn_basvuru_hekim_dis_mi(0) = 0;

create or replace view public.v_rad_hekim_lookup as
select t.id,
       trim(coalesce(t.unvan, '') ||
            case when coalesce(h.brans, '') <> '' then ' · ' || h.brans
                 when coalesce(kd.ad, '') <> '' then ' · ' || kd.ad else '' end ||
            case when coalesce(h.dis_mi::integer, 0) = 1 or coalesce(p.dis_hekim::integer, 0) = 1 then ' (dış)' else '' end)::varchar(200) as ad,
       case when coalesce(t.durum::integer, 1) = 1 then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hekim h on h.id = t.id
  left join public.taraf_personel p on p.id = t.id
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id and kd.deger::text = nullif(p.brans, '')
 where t.hekim = 1 or (t.personel = 1 and public.fn_hekim_planli(t.id) = 1) or coalesce(p.dis_hekim::integer, 0) = 1;
