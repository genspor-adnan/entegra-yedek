-- 338: ENTEGRASYON HESABINA "BAZ ALINACAK ŞUBE".
--
-- Kullanıcı: "bir alan daha eklenmeli 'Baz Alınacak Şube' - hangi şube varsa
-- onun hesabı kullanılır." (Şubenin zorunlu olması da konuşuldu; kullanıcı
-- kararı: "boş = Tümü kalsın" - kurum geneli hesap satırı duruyor.)
--
-- Bugüne kadar "şubenin kendi satırı yoksa kurum geneli satıra düş" ÖRTÜK tek
-- kuraldı; hangi şubenin hangi hesapla çalıştığı ekranda görünmüyordu. Yeni
-- alan 227'deki (depo / ÜTS) desenin aynısı:
--   * `baz_sube_id` (0 = Kendisi) - şube başka bir şubenin hesabını
--     kullanacaksa bu AÇIKÇA satıra yazılır.
-- Çözüm sırası: kendi satırı -> baz şubenin satırı -> kurum geneli (şube boş)
-- satır -> [yalnız ÜTS] varsayılan şube.
\set ON_ERROR_STOP on

-- ------------------------------------------------------- baz şube kolonu ---
-- FK YOK: 0 gerçek şube değil ("Kendisi") - 227 deseniyle aynı.
alter table public.entegrasyon_hesap
    add column if not exists baz_sube_id integer not null default 0;

comment on column public.entegrasyon_hesap.baz_sube_id is
  'Hesabi baz alinacak sube (338): 0 = kendisi. Dolu ise bu subenin islemleri '
  'o subenin hesabiyla (kullanici/sifre/token) gider.';

-- 337'de ÜTS göçü baz şubeyi `ayarlar` jsonb'sine yazmıştı; artık tipli kolon.
update public.entegrasyon_hesap
   set baz_sube_id = coalesce(nullif((ayarlar->>'baz_sube_id')::int, 0), 0),
       ayarlar     = ayarlar - 'baz_sube_id'
 where ayarlar ? 'baz_sube_id';

-- ------------------------------------------------- ortak hesap çözücüsü ----
-- Tek çözüm noktası: ÜTS, e-Belge ve ekran kolonları aynı kuralı kullansın.
--   1) şubenin aktif satırı; satırda baz şube varsa (0 değilse) HEDEF o şube,
--   2) hedef şubenin aktif satırı,
--   3) kurum geneli satır (şube boş = "Tümü"),
--   4) yoksa ve p_varsayilana_dus = 1 ise varsayılan şubenin satırı.
-- Tek sıçrama (227 ile aynı): baz şubenin de bazı varsa izlenmez, zincir
--   kurmak yanlış yapılandırmada sonsuz döngü riski taşır.
create or replace function public.fn_entegrasyon_hesap_id(
        p_kod             varchar,
        p_sube_id         integer default null,
        p_varsayilana_dus smallint default 0)
returns integer
language sql stable as $$
    with vars as (
        select (select id from public.sube
                 where varsayilan = 1 and aktif = 1 order by id limit 1) as varsayilan_id
    ),
    istenen as (
        select coalesce(p_sube_id, (select varsayilan_id from vars)) as id
    ),
    kendi as (
        select h.id, h.baz_sube_id
          from public.entegrasyon_hesap h
          join istenen i on i.id = h.sube_id
         where h.kod = p_kod and h.aktif = 1
         order by h.id limit 1
    ),
    hedef as (
        select coalesce((select nullif(k.baz_sube_id, 0) from kendi k),
                        (select id from istenen)) as id
    )
    select coalesce(
             -- Baz şube gösterilmişse ORANIN satırı; gösterilmemişse kendi satırı.
             (select h.id from public.entegrasyon_hesap h
               where h.kod = p_kod and h.aktif = 1
                 and h.sube_id = (select id from hedef)
               order by h.id limit 1),
             -- Kurum geneli satır: şubesi boş bırakılan hesap "Tümü" demektir
             --   (kullanıcı kararı) - şubenin kendi satırı yoksa bu kullanılır.
             (select h.id from public.entegrasyon_hesap h
               where h.kod = p_kod and h.aktif = 1 and h.sube_id is null
               order by h.id limit 1),
             case when p_varsayilana_dus = 1
                  then (select h.id from public.entegrasyon_hesap h
                         where h.kod = p_kod and h.aktif = 1
                           and h.sube_id = (select varsayilan_id from vars)
                         order by h.id limit 1)
             end)
$$;

comment on function public.fn_entegrasyon_hesap_id(varchar, integer, smallint) is
  'Subenin entegrasyon hesabi (338): kendi satiri -> baz sube satiri -> kurum '
  'geneli (sube bos) -> (istenirse) varsayilan sube. Tek sicrama.';

-- --------------------------------------------------------- fn_uts_hesap ----
-- ÜTS'te varsayılan şubeye düşülür (223/227 davranışı korunuyor).
create or replace function public.fn_uts_hesap(p_sube_id integer default null)
returns table (kurum_no varchar, token text, test_mi boolean, url varchar)
language sql stable as $$
    select h.kurum_kodu::varchar,
           h.sifre,
           h.test_mi = 1,
           coalesce(
             nullif(btrim(case when h.test_mi = 1 then h.test_url else h.url end), ''),
             nullif(btrim((select r.deger from public.referans r
                            where r.anahtar = case when h.test_mi = 1
                                                   then 'uts.test_url'
                                                   else 'uts.uretim_url' end)), ''),
             case when h.test_mi = 1
                  then 'https://utstest.saglik.gov.tr'
                  else 'https://utsuygulama.saglik.gov.tr' end)::varchar
      from public.entegrasyon_hesap h
     where h.id = public.fn_entegrasyon_hesap_id('UTS', p_sube_id, 1::smallint)
$$;

comment on function public.fn_uts_hesap(integer) is
  'Subenin UTS hesabi (338): fn_entegrasyon_hesap_id ile cozulur (kendi / baz '
  'sube / varsayilan sube), URL satirdan ya da referans ayarindan.';

-- ------------------------------------------------------- fn_ebelge_hesap ---
-- e-Belge'de VARSAYILAN ŞUBEYE düşülmez (kurum geneli satır kullanılır):
--   "merkezin kimliğiyle gönder" kararı 169'da (kimlik şubesi), hesap kararı
--   satırın baz şubesinde ya da kurum geneli satırda AÇIKÇA verilir. Sessizce
--   varsayılan şubenin hesabına düşmek, kendi VKN'siyle gönderen şubeyi
--   başkasının entegratör hesabına bağlardı.
create or replace function public.fn_ebelge_hesap(p_sube_id integer default null)
returns table (entegrator varchar, kullanici varchar, sifre varchar,
               test_mi boolean, url varchar, kimlik_sube_id integer)
language sql stable as $$
    with kimlik as (
        select g.kimlik_sube_id as id
          from public.sube s
          join public.v_ebelge_gonderici g on g.sube_id = s.id
         where s.id = coalesce(p_sube_id, (select id from public.sube
                                            where varsayilan = 1 and aktif = 1
                                            order by id limit 1))
    )
    select e.kod,
           h.kullanici_adi,
           h.sifre::varchar,
           h.test_mi = 1,
           coalesce(
             nullif(btrim(case when h.test_mi = 1 then h.test_url else h.url end), ''),
             nullif(btrim((select r.deger from public.referans r
                            where r.anahtar = case when h.test_mi = 1
                                                   then 'efatura.test_url'
                                                   else 'efatura.uretim_url' end)), ''),
             case when h.test_mi = 1 then e.test_url else e.uretim_url end,
             '')::varchar,
           (select id from kimlik)
      from public.entegrasyon_hesap h
      left join public.ebelge_entegrator e on e.id = h.entegrator_id
     where h.id = public.fn_entegrasyon_hesap_id(
                      'EBELGE', (select id from kimlik), 0::smallint)
$$;

comment on function public.fn_ebelge_hesap(integer) is
  'Subenin e-Belge hesabi (338): kimlik subesi 169''dan, hesap '
  'fn_entegrasyon_hesap_id ile (kendi / baz sube; varsayilana DUSULMEZ).';

do $$
declare r record;
begin
    for r in select h.kod, h.sube_id, coalesce(s.ad, 'Tümü') as ad,
                    h.baz_sube_id, h.test_mi, h.aktif
               from public.entegrasyon_hesap h
               left join public.sube s on s.id = h.sube_id
              order by h.kod, h.sube_id nulls first, h.test_mi loop
        raise notice '338: % sube=% baz=% ortam=% aktif=%',
            r.kod, r.ad, r.baz_sube_id,
            case when r.test_mi = 1 then 'TEST' else 'CANLI' end, r.aktif;
    end loop;
    raise notice '338 tamam: baz sube alani (sube bos = Tumu korundu).';
end $$;
