-- ============================================================================
--  Gentegre AI — MUKELLEF BILGILERI SUBEYE TASINIYOR
--  171_sube_ebelge_mukellef.sql
--
--  Kullanici: "satis belgesi ayarlarindaki e-Belge ayarlarini sube kayit ekrani
--  e-Belge sekmesine tasi" — kapsam: MUKELLEF bilgileri (kullanici secimi).
--
--  NEDEN SUBEYE: 169'da sube kendi kimligiyle ya da merkezin kimligiyle
--  gonderebiliyor. Entegrator hesabi MUKELLEFE aittir - ayri VKN'li sube ayri
--  kullanici/sifre ile baglanir. Bunlar firma geneli `referans` anahtarlarinda
--  dururken cok mukellefli kurulum imkansizdi.
--
--  TASINANLAR (referans -> sube):
--    ebelge.vkn            -> sube.vkno              (zaten kimlik VKN'si; ayri tutulmaz)
--    ebelge.entegrator     -> sube.entegrator_id
--    ebelge.kullanici      -> sube.entegrator_kullanici
--    ebelge.sifre          -> sube.entegrator_sifre
--    ebelge.test_aktif     -> sube.test_ortami
--    ebelge.test_kullanici -> sube.test_kullanici
--    ebelge.test_sifre     -> sube.test_sifre
--
--  YERINDE KALANLAR (firma geneli davranis, mukellefe bagli degil):
--    ebelge.aktif (ana salter), efatura.* / eirsaliye.* (sabit notlar, senaryo,
--    gelen belge alma, URL'ler), seri kurallari, XSLT sablonlari.
--
--  ENTEGRATOR ID: kart combo'lari kod tablosundan "id, ad, aktif" okur ve id'yi
--  SAYI bekler; katalogun anahtari ise metin kod. Tabloya sabit sayisal id
--  eklendi - kod hala birincil anahtar, id yalnizca arayuz secimi icin.
--
--  SIFRE: bugun referansta da duz metin duruyordu; tasima sirasinda sifreleme
--  EKLENMEDI (ayri is - butun gizli ayarlari birlikte ele almak gerekir).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------- entegrator sayisal id ----
alter table public.ebelge_entegrator
    add column if not exists id smallint;

update public.ebelge_entegrator set id = v.id
  from (values ('izibiz', 1::smallint), ('uyumsoft', 2::smallint), ('edm', 3::smallint),
               ('sovos', 4::smallint), ('veriban', 5::smallint), ('elogo', 6::smallint),
               ('nes', 7::smallint), ('turkcell', 8::smallint), ('digitalp', 9::smallint),
               ('mysoft', 10::smallint), ('diger', 99::smallint)) as v(kod, id)
 where public.ebelge_entegrator.kod = v.kod
   and public.ebelge_entegrator.id is distinct from v.id;

create unique index if not exists ux_ebelge_entegrator_id on public.ebelge_entegrator(id);

comment on column public.ebelge_entegrator.id is
  'Arayuz secimi icin sabit sayisal kod; birincil anahtar hala `kod` (171).';

-- Kart combo kaynagi: kod tablosu sozlesmesi (id, ad, aktif). Gorunum
--   DUSURULUP kurulur: 167'de id kolonu metin kodtu, tip degisiyor.
drop view if exists public.v_ebelge_entegrator_lookup;
create view public.v_ebelge_entegrator_lookup as
    -- id INTEGER: kod tablosu okuyucusu GetInt32 kullanir; smallint ya da
    --   varchar donen gorunum kart acilisinda 500 veriyor (153 ile ayni tuzak).
    select e.id::int as id, e.ad, e.aktif
      from public.ebelge_entegrator e
     where e.id is not null
     order by e.sira, e.ad;

-- ------------------------------------------------------ sube kolonlari -----
alter table public.sube
    add column if not exists entegrator_id    smallint     not null default 0,
    add column if not exists entegrator_sifre varchar(200) not null default '',
    -- Test ortami SUBE BAZLI: bir mukellef canliya gecmisken digeri hala testte
    --   olabilir (yeni acilan sube).
    add column if not exists test_ortami      smallint     not null default 0,
    add column if not exists test_kullanici   varchar(120) not null default '',
    add column if not exists test_sifre       varchar(200) not null default '';

comment on column public.sube.entegrator_id is
  'Bu mukellefin e-Belge entegratoru (ebelge_entegrator.id) - 171.';
comment on column public.sube.test_ortami is
  '1 ise belgeler entegratorun TEST ucuna gider (171).';

-- ----------------------------------------------------------------- goc -----
-- Mevcut firma geneli degerler VARSAYILAN subeye tasinir; diger subeler
--   dokunulmaz (kendi hesaplarini girecekler ya da merkezin kimligini
--   kullanacaklar - 169).
do $$
declare
    v_sube integer := (select id from public.sube where varsayilan = 1 and aktif = 1
                        order by id limit 1);
    v_kod  text;
    v_id   smallint;
begin
    if v_sube is null then
        select min(id) into v_sube from public.sube;
    end if;
    if v_sube is null then
        raise notice '171: sube kaydi yok, goc atlandi.';
        return;
    end if;

    v_kod := btrim(coalesce((select deger from public.referans where anahtar = 'ebelge.entegrator'), ''));
    select e.id into v_id from public.ebelge_entegrator e where e.kod = v_kod;

    update public.sube s
       set entegrator_id    = coalesce(v_id, s.entegrator_id),
           entegrator_kod   = coalesce(nullif(v_kod, ''), s.entegrator_kod),
           entegrator_kullanici =
               coalesce(nullif(btrim((select deger from public.referans where anahtar = 'ebelge.kullanici')), ''),
                        s.entegrator_kullanici),
           entegrator_sifre =
               coalesce(nullif(btrim((select deger from public.referans where anahtar = 'ebelge.sifre')), ''),
                        s.entegrator_sifre),
           test_ortami      =
               case when coalesce((select deger from public.referans where anahtar = 'ebelge.test_aktif'), '0') = '1'
                    then 1 else s.test_ortami end,
           test_kullanici   =
               coalesce(nullif(btrim((select deger from public.referans where anahtar = 'ebelge.test_kullanici')), ''),
                        s.test_kullanici),
           test_sifre       =
               coalesce(nullif(btrim((select deger from public.referans where anahtar = 'ebelge.test_sifre')), ''),
                        s.test_sifre),
           -- VKN: sube kaydinda bos ise ayardan alinir. Doluysa DOKUNULMAZ -
           --   subenin kendi kimligi ayardaki firma VKN'sinden ustundur.
           vkno = case when coalesce(btrim(s.vkno), '') = ''
                       then coalesce(nullif(btrim((select deger from public.referans where anahtar = 'ebelge.vkn')), ''), s.vkno)
                       else s.vkno end
     where s.id = v_sube;

    raise notice '171: mukellef bilgileri sube %e tasindi (entegrator=%).', v_sube, coalesce(v_kod, '-');
end $$;

-- Tasinan anahtarlar referanstan SILINIR: iki yerde durursa hangisinin gecerli
--   oldugu belirsiz kalir ve eski ayar ekrani yanlis bilgiyi gostermeye devam eder.
delete from public.referans
 where anahtar in ('ebelge.vkn', 'ebelge.entegrator', 'ebelge.kullanici', 'ebelge.sifre',
                   'ebelge.test_aktif', 'ebelge.test_kullanici', 'ebelge.test_sifre');

-- ------------------------------------------- sube bazli entegrator cozumu ---
-- 167'deki firma geneli fonksiyonlarin sube bazli halleri. Eski imzalar
--   KALDIRILIR: ayar anahtarlari silindigi icin bos deger dondururlerdi.
drop function if exists public.fn_ebelge_entegrator();
drop function if exists public.fn_ebelge_url(boolean);

-- Kimlik hangi subedeyse (169) entegrator hesabi da onundur: merkezin kimligiyle
--   gonderen sube, merkezin entegrator hesabini kullanir.
create or replace function public.fn_ebelge_entegrator(p_sube_id integer default null)
returns text language sql stable as $$
    select coalesce(
        (select nullif(btrim(e.kod), '')
           from public.sube s
           join public.v_ebelge_gonderici g on g.sube_id = s.id
           join public.sube ki on ki.id = g.kimlik_sube_id
           left join public.ebelge_entegrator e on e.id = ki.entegrator_id
          where s.id = coalesce(p_sube_id, (select id from public.sube
                                             where varsayilan = 1 and aktif = 1
                                             order by id limit 1))),
        '')
$$;

comment on function public.fn_ebelge_entegrator(integer) is
  'Subenin e-Belge entegrator kodu; kimlik merkezden geliyorsa merkezin hesabi (171).';

-- Mukellef hesabi: kullanici/sifre + hangi ortam. Gonderim istemcisi bunu okur.
create or replace function public.fn_ebelge_hesap(p_sube_id integer default null)
returns table (entegrator varchar, kullanici varchar, sifre varchar,
               test_mi boolean, url varchar, kimlik_sube_id integer)
language sql stable as $$
    select e.kod,
           case when ki.test_ortami = 1 then ki.test_kullanici else ki.entegrator_kullanici end,
           case when ki.test_ortami = 1 then ki.test_sifre     else ki.entegrator_sifre     end,
           ki.test_ortami = 1,
           -- Uc nokta: ayarda elle girilmis URL varsa o, yoksa katalog varsayilani.
           coalesce(
             nullif(btrim((select r.deger from public.referans r
                            where r.anahtar = case when ki.test_ortami = 1
                                                   then 'efatura.test_url' else 'efatura.uretim_url' end)), ''),
             case when ki.test_ortami = 1 then e.test_url else e.uretim_url end,
             '')::varchar,
           ki.id
      from public.sube s
      join public.v_ebelge_gonderici g on g.sube_id = s.id
      join public.sube ki on ki.id = g.kimlik_sube_id
      left join public.ebelge_entegrator e on e.id = ki.entegrator_id
     where s.id = coalesce(p_sube_id, (select id from public.sube
                                        where varsayilan = 1 and aktif = 1 order by id limit 1))
$$;

comment on function public.fn_ebelge_hesap(integer) is
  'Subenin e-Belge entegrator hesabi: kod, kullanici/sifre (test ya da uretim), uc nokta (171).';

-- --------------------------------------------------------------- dagitici ---
-- Entegrator artik BELGENIN SUBESINDEN cozulur.
create or replace function public.fn_ebelge_gonderim_govdesi(
        p_belge_id integer, p_entegrator text default null)
returns table (entegrator varchar, bicim smallint, govde jsonb)
language plpgsql stable as $$
declare
    v_sube integer;
    v_kod  text;
    e      record;
    v_json jsonb;
begin
    select bl.sube_id into v_sube from public.belge bl where bl.id = p_belge_id;

    v_kod := coalesce(nullif(btrim(p_entegrator), ''), public.fn_ebelge_entegrator(v_sube));

    if coalesce(v_kod, '') = '' then
        raise exception 'Bu şube için entegratör seçilmemiş. Yönetim › Firma Bilgileri › e-Belge''den seçin.';
    end if;

    select * into e from public.ebelge_entegrator where kod = v_kod;
    if not found then
        raise exception '"%" tanımlı bir entegratör değil.', v_kod;
    end if;
    if e.aktif <> 1 then
        raise exception '"%" entegratörü pasif.', e.ad;
    end if;
    if coalesce(btrim(e.govde_fn), '') = '' then
        raise exception '% için gönderim gövdesi üreteci henüz yazılmadı; şu an yalnızca İzibiz gönderimi yapılabiliyor.', e.ad;
    end if;

    execute format('select %s($1)', e.govde_fn) into v_json using p_belge_id;

    return query select e.kod, e.gonderim_bicimi, v_json;
end $$;

comment on function public.fn_ebelge_gonderim_govdesi(integer, text) is
  'e-Belge gonderim govdesi: belgenin subesine ait entegratorun adaptorunu cagirir (171).';

do $$
declare r record;
begin
    for r in select s.id, s.ad, public.fn_ebelge_entegrator(s.id) as ent,
                    (select h.test_mi from public.fn_ebelge_hesap(s.id) h) as test_mi
               from public.sube s order by s.id loop
        raise notice '171: sube % (%) entegrator=% test=%', r.id, r.ad,
                     coalesce(nullif(r.ent, ''), '-'), r.test_mi;
    end loop;
    raise notice '171 tamam: mukellef bilgileri sube bazli.';
end $$;
