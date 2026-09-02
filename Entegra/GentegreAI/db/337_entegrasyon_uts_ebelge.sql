-- 337: ÜTS ve e-Fatura HESAPLARI ENTEGRASYON EKRANINA TAŞINIYOR.
--
-- Kullanıcı: "şube ayarlarındaki ÜTS'yi de buraya taşı", "şube ayarlarındaki
-- e-fatura hesabı de buraya taşı", "en üstte e-Fatura olsun."
--
-- 336 ortak sözleşmeyi kurdu (`entegrasyon_hesap`: kod + şube + ortam) ama iki
-- entegrasyon hâlâ kendi yerinde duruyordu:
--   * ÜTS      -> `uts_hesap` (şube kartı > ÜTS sekmesi)
--   * e-Belge  -> `sube` kolonları (şube kartı > e-Belge > Mükellef Hesabı)
-- Aynı iş üç ekranda üç ayrı düzenle yapılıyordu; test/canlı ayrımı da üç
-- farklı şekilde çözülmüştü (uts_hesap.test_ortami, sube.test_ortami,
-- entegrasyon_hesap.test_mi).
--
-- TAŞINAN YALNIZ HESAP (kimlik) BİLGİSİDİR. Şubede kalanlar:
--   * gönderici kimliği (unvan/VKN/alias/Mersis, `v_ebelge_gonderici`, 169),
--   * mükellefiyet bayrakları (e-Fatura / e-Arşiv / e-İrsaliye / e-SMM, 172),
--   * varsayılan seri.
-- Bunlar hesap değil BELGENİN kimliğidir; entegratör hesabı değişse de aynı
-- kalırlar.
--
-- TEST/CANLI: 336 deseni korunur - test ve canlı AYRI SATIRDIR. Eski tek satır
-- (canlı alanlar + test alanları + "test ortamı" bayrağı) iki satıra bölünür;
-- hangisinin kullanılacağını `aktif` söyler. Kurum canlıya geçerken test
-- hesabını silmez, satırı pasife alır.
\set ON_ERROR_STOP on

-- ------------------------------------------------------- şema genişletme ---
-- ÜTS sistem token'ı 200 karakterden uzun (e-imza ile üretilen JWT); şifre
--   kolonu metne çevrilir. Diğer servisler etkilenmez.
alter table public.entegrasyon_hesap
    alter column sifre type text;

-- E-BELGE'YE ÖZGÜ TEK ALAN TİPLİ KOLON, jsonb DEĞİL: entegratör kartta
--   AÇILIR LİSTEDEN seçilir (v_ebelge_entegrator_lookup) ve `ayarlar` jsonb'si
--   için jenerik kartta seçim arayüzü yok. Öteki servislerde boş (0) kalır.
alter table public.entegrasyon_hesap
    add column if not exists entegrator_id smallint not null default 0;

comment on column public.entegrasyon_hesap.entegrator_id is
  'e-Belge entegratörü (ebelge_entegrator.id) - yalnız kod = EBELGE satırlarında (337).';

-- --------------------------------------------------------- seçim listesi ---
-- Sıra kullanıcı isteği: e-Fatura en üstte.
create or replace view public.v_entegrasyon_kod_lookup as
    select v.id, v.ad, 1 as aktif, v.sira
      from (values ('EBELGE', 'e-Fatura / e-Belge Entegratörü', 1),
                   ('UTS',    'ÜTS (Ürün Takip Sistemi)',       2),
                   ('SKRS',   'SKRS / Sağlık.NET Kod Sunucusu', 3),
                   ('ENABIZ', 'e-Nabız',                        4),
                   ('MEDULA', 'MEDULA (SGK)',                   5),
                   ('SMS',    'SMS Sağlayıcı',                  6)) v(id, ad, sira)
     order by v.sira;

comment on view public.v_entegrasyon_kod_lookup is
  'Entegrasyon secim listesi (336/337) - kodlar METIN; sira: e-Fatura en ustte.';

-- ============================================================== ÜTS GÖÇÜ ===
-- Eski satır: (kurum_no + token) canlı, (test_kurum_no + test_token) test,
--   hangisinin kullanıldığı test_ortami. İkisi de doluysa iki satır olur;
--   yalnız kullanılan ortam aktif işaretlenir.
insert into public.entegrasyon_hesap
       (kod, ad, sube_id, aktif, test_mi, kurum_kodu, sifre, ayarlar, aciklama)
select 'UTS', 'ÜTS - ' || s.ad, u.sube_id,
       -- Eski kayıtta "aktif" ile "test ortamı" karşılıklı dışlanan seçimdi;
       --   yeni düzende ortam satırın kendisidir, aktif = kullanılan satır.
       case when u.test_ortami = 0 then 1 else 0 end,
       0, u.kurum_no, u.token,
       case when coalesce(u.baz_sube_id, 0) > 0
            then jsonb_build_object('baz_sube_id', u.baz_sube_id)
            else '{}'::jsonb end,
       'ÜTS hesabı şube kartından taşındı (337).'
  from public.uts_hesap u
  join public.sube s on s.id = u.sube_id
 where coalesce(btrim(u.kurum_no), '') <> '' or coalesce(btrim(u.token), '') <> ''
on conflict (kod, coalesce(sube_id, 0), test_mi) do nothing;

insert into public.entegrasyon_hesap
       (kod, ad, sube_id, aktif, test_mi, kurum_kodu, sifre, ayarlar, aciklama)
select 'UTS', 'ÜTS (test) - ' || s.ad, u.sube_id,
       case when u.test_ortami = 1 then 1 else 0 end,
       1, u.test_kurum_no, u.test_token,
       case when coalesce(u.baz_sube_id, 0) > 0
            then jsonb_build_object('baz_sube_id', u.baz_sube_id)
            else '{}'::jsonb end,
       'ÜTS test hesabı şube kartından taşındı (337).'
  from public.uts_hesap u
  join public.sube s on s.id = u.sube_id
 where coalesce(btrim(u.test_kurum_no), '') <> '' or coalesce(btrim(u.test_token), '') <> ''
on conflict (kod, coalesce(sube_id, 0), test_mi) do nothing;

-- --------------------------------------------------------- fn_uts_hesap ----
-- Çözüm sırası (227'deki baz şube yönlendirmesi korunuyor, artık `ayarlar`
--   içinden okunuyor):
--   1) istenen şubenin satırı, 2) kurum geneli satır (şube boş),
--   3) varsayılan şubenin satırı.
create or replace function public.fn_uts_hesap(p_sube_id integer default null)
returns table (kurum_no varchar, token text, test_mi boolean, url varchar)
language sql stable as $$
    with vars as (
        select (select id from public.sube
                 where varsayilan = 1 and aktif = 1 order by id limit 1) as varsayilan_id
    ),
    istenen as (
        select coalesce(p_sube_id, (select varsayilan_id from vars)) as id
    ),
    -- Baz şube yönlendirmesi: istenen şubenin ÜTS satırı başka şubeyi
    --   gösteriyorsa hesap oradan okunur (0 / boş = kendisi).
    hedef as (
        select coalesce(
                 (select nullif((h.ayarlar->>'baz_sube_id')::int, 0)
                    from public.entegrasyon_hesap h
                    join istenen i on i.id = h.sube_id
                   where h.kod = 'UTS' and h.aktif = 1
                   order by h.id limit 1),
                 (select id from istenen)) as id
    ),
    h as (
        select x.*
          from public.entegrasyon_hesap x
         where x.kod = 'UTS' and x.aktif = 1
           and (x.sube_id = (select id from hedef)
                or x.sube_id is null
                or x.sube_id = (select varsayilan_id from vars))
         order by case when x.sube_id = (select id from hedef) then 0
                       when x.sube_id is null                  then 1
                       else 2 end, x.id
         limit 1
    )
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
      from h
$$;

comment on function public.fn_uts_hesap(integer) is
  'Subenin UTS hesabi (337): entegrasyon_hesap kod=UTS - sube satiri, yoksa '
  'kurum geneli, yoksa varsayilan sube; baz_sube_id yonlendirmesi korunur.';

-- ========================================================== e-BELGE GÖÇÜ ===
-- Kaynak: sube.entegrator_id / entegrator_kullanici / entegrator_sifre (canlı)
--   ve test_kullanici / test_sifre (test); hangisinin kullanıldığı
--   sube.test_ortami.
insert into public.entegrasyon_hesap
       (kod, ad, sube_id, aktif, test_mi, kullanici_adi, sifre, entegrator_id, aciklama)
select 'EBELGE', 'e-Fatura - ' || s.ad, s.id,
       case when s.test_ortami = 0 then 1 else 0 end,
       0, s.entegrator_kullanici, s.entegrator_sifre, s.entegrator_id,
       'e-Belge entegratör hesabı şube kartından taşındı (337).'
  from public.sube s
 where coalesce(btrim(s.entegrator_kullanici), '') <> ''
    or coalesce(btrim(s.entegrator_sifre), '') <> ''
on conflict (kod, coalesce(sube_id, 0), test_mi) do nothing;

insert into public.entegrasyon_hesap
       (kod, ad, sube_id, aktif, test_mi, kullanici_adi, sifre, entegrator_id, aciklama)
select 'EBELGE', 'e-Fatura (test) - ' || s.ad, s.id,
       case when s.test_ortami = 1 then 1 else 0 end,
       1, s.test_kullanici, s.test_sifre, s.entegrator_id,
       'e-Belge test hesabı şube kartından taşındı (337).'
  from public.sube s
 where coalesce(btrim(s.test_kullanici), '') <> ''
    or coalesce(btrim(s.test_sifre), '') <> ''
on conflict (kod, coalesce(sube_id, 0), test_mi) do nothing;

-- ------------------------------------------------------- fn_ebelge_hesap ---
-- KİMLİK ŞUBESİ değişmedi (169): belge hangi mükellefin kimliğiyle çıkıyorsa
--   hesap da onun; hesap satırı artık entegrasyon_hesap'ta.
create or replace function public.fn_ebelge_hesap(p_sube_id integer default null)
returns table (entegrator varchar, kullanici varchar, sifre varchar,
               test_mi boolean, url varchar, kimlik_sube_id integer)
language sql stable as $$
    with vars as (
        select (select id from public.sube
                 where varsayilan = 1 and aktif = 1 order by id limit 1) as varsayilan_id
    ),
    kimlik as (
        select g.kimlik_sube_id as id
          from public.sube s
          join public.v_ebelge_gonderici g on g.sube_id = s.id
         where s.id = coalesce(p_sube_id, (select varsayilan_id from vars))
    ),
    -- VARSAYILAN SUBEYE DUSULMEZ (UTS'ten farki): e-Belge'de "merkezin
    --   kimligiyle gonder" karari 169'da ust_sube_id ile zaten veriliyor.
    --   Hesabi sessizce merkeze dusurmek, kendi VKN'siyle gonderen subeyi
    --   baskasinin entegrator hesabina bagalardi. Kurum geneli satir (sube
    --   bos) acik bir tercihtir, o kullanilir.
    h as (
        select x.*
          from public.entegrasyon_hesap x
         where x.kod = 'EBELGE' and x.aktif = 1
           and (x.sube_id = (select id from kimlik) or x.sube_id is null)
         order by case when x.sube_id is null then 1 else 0 end, x.id
         limit 1
    )
    select e.kod,
           h.kullanici_adi,
           h.sifre::varchar,
           h.test_mi = 1,
           -- Üç nokta: satırın kendi adresi, sonra firma geneli ayar, sonra
           --   entegratör kataloğunun varsayılanı.
           coalesce(
             nullif(btrim(case when h.test_mi = 1 then h.test_url else h.url end), ''),
             nullif(btrim((select r.deger from public.referans r
                            where r.anahtar = case when h.test_mi = 1
                                                   then 'efatura.test_url'
                                                   else 'efatura.uretim_url' end)), ''),
             case when h.test_mi = 1 then e.test_url else e.uretim_url end,
             '')::varchar,
           (select id from kimlik)
      from h
      left join public.ebelge_entegrator e on e.id = h.entegrator_id
$$;

comment on function public.fn_ebelge_hesap(integer) is
  'Subenin e-Belge entegrator hesabi (337): kimlik subesi 169''dan, hesap '
  'entegrasyon_hesap kod=EBELGE satirindan (sube / kurum geneli / varsayilan).';

-- ------------------------------------------------- eski yerler devre dışı --
-- uts_hesap ARTIK OKUNMUYOR. Silinmiyor: göç doğrulanana kadar veri elde
--   kalsın (bir sonraki temizlik göçünde düşürülecek).
do $$ begin
    if to_regclass('public.uts_hesap') is not null
       and to_regclass('public.uts_hesap_337_yedek') is null then
        execute 'alter table public.uts_hesap rename to uts_hesap_337_yedek';
        execute 'comment on table public.uts_hesap_337_yedek is '
             || '''DEVRE DISI (337): UTS hesabi entegrasyon_hesap kod=UTS satirina tasindi.''';
    end if;
end $$;

-- sube'deki entegratör kolonları da artık okunmuyor; kart alanları
--   kaldırıldı. Kolonlar duruyor (aynı gerekçe) - yalnız yorumları işaretlendi.
comment on column public.sube.entegrator_id is
  'DEVRE DISI (337): entegrasyon_hesap kod=EBELGE satirina tasindi.';
comment on column public.sube.entegrator_kullanici is
  'DEVRE DISI (337): entegrasyon_hesap.kullanici_adi.';
comment on column public.sube.entegrator_sifre is
  'DEVRE DISI (337): entegrasyon_hesap.sifre.';
comment on column public.sube.test_ortami is
  'DEVRE DISI (337): ortam artik entegrasyon_hesap.test_mi (ayri satir).';
comment on column public.sube.test_kullanici is
  'DEVRE DISI (337): entegrasyon_hesap test satirinin kullanici_adi.';
comment on column public.sube.test_sifre is
  'DEVRE DISI (337): entegrasyon_hesap test satirinin sifre alani.';

do $$
declare r record;
begin
    for r in select kod, sube_id, test_mi, aktif, ad from public.entegrasyon_hesap
              where kod in ('UTS', 'EBELGE') order by kod, sube_id, test_mi loop
        raise notice '337: % sube=% ortam=% aktif=% (%)',
            r.kod, r.sube_id, case when r.test_mi = 1 then 'TEST' else 'CANLI' end,
            r.aktif, r.ad;
    end loop;
    raise notice '337 tamam: UTS + e-Belge hesaplari entegrasyon_hesap''ta.';
end $$;
