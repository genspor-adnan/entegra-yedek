-- ============================================================================
--  Gentegre AI — ŞUBENİN YEREL AYARLARI
--  666_sube_yerel_ayarlar.sql
--
--  Kullanıcı: "yerel ülke adı ve kodunu ve saat farkını ve para birimini şube
--  ayarlarına gir ve şubeye göre onları kullan" + "yerel ülke türkiye değilse
--  kimlik no ve telefon kontrolü yapma"
--
--  NEDEN ŞUBEDE: kurum profilinde tek bir para birimi vardı (`kurum_profil.
--  para_birimi = 'TL'`) ve ülke yalnız ADRES METNİydi ("Turkiye"). Yurt
--  dışında şubesi olan bir kurumda bu üç şey şubeden şubeye değişir: Berlin
--  şubesi avro tahsil eder, Almanya saatiyle çalışır ve orada T.C. kimlik
--  numarası diye bir kavram yoktur. Kurum geneline koymak, ikinci şubeyi
--  açan kurumu "hangisini yazayım" ikilemine sokardı.
--
--  DÖRT KOLON:
--   · ulke_kod     ISO 3166 iki harf ('TR') — MAKİNE için. `ulke` metni
--     ("Türkiye", "Turkiye", "TÜRKİYE"…) karar vermek için güvenilmez;
--     doğrulama kuralları bu koda bakar.
--   · telefon_kodu '+90' — telefon kutusunun açılış kodu.
--   · zaman_dilimi 'Europe/Istanbul' — IANA adı, SAAT FARKI DEĞİL: "+03:00"
--     yazmak yaz saati uygulayan ülkelerde yılda iki kez yanlış olurdu.
--   · para_birimi  'TRY' — ISO 4217. Eski `kurum_profil.para_birimi` 'TL'
--     yazıyor; 'TL' ISO kodu değildir ve biçimlendirici (Intl) tanımaz.
--
--  KİMLİK/TELEFON KONTROLÜ: `ulke_kod = 'TR'` dışındaki şubelerde T.C. kimlik
--  numarası ve Türkiye telefon biçimi kontrolü YAPILMAZ (uygulama tarafında).
--  Alman hastanın 11 haneli TCKN'si olmaz; kontrolü açık bırakmak kaydı
--  imkânsız kılar, "boş geç" demek ise veriyi kaybettirirdi.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.sube add column if not exists ulke_kod     varchar(2)  not null default 'TR';
alter table public.sube add column if not exists telefon_kodu varchar(6)  not null default '+90';
alter table public.sube add column if not exists zaman_dilimi varchar(40) not null default 'Europe/Istanbul';
alter table public.sube add column if not exists para_birimi  varchar(3)  not null default 'TRY';

comment on column public.sube.ulke_kod is
  'ISO 3166-1 alpha-2 (666). Dogrulama kurallari BUNA bakar - `ulke` metni '
  'serbest yazim oldugu icin karar veremez. TR disinda TCKN/telefon bicim '
  'kontrolu uygulanmaz.';
comment on column public.sube.telefon_kodu is
  'Subenin varsayilan telefon ulke kodu, ornek +90 (666).';
comment on column public.sube.zaman_dilimi is
  'IANA zaman dilimi adi, ornek Europe/Istanbul (666). Sabit saat farki DEGIL: '
  'yaz saati uygulayan ulkelerde offset yilda iki kez degisir.';
comment on column public.sube.para_birimi is
  'ISO 4217 kodu, ornek TRY/EUR/USD (666). Subenin varsayilan para birimi - '
  'belgenin kendi dovizi ayri alandir.';

-- ---------------------------------------------------------------------------
--  MEVCUT ŞUBELER: adres metnindeki ülkeden çıkarım. Tanınmayan ülkede
--  VARSAYILAN (TR) kalır - yanlış tahminde bulunup Türkiye'deki bir şubeyi
--  yurt dışı saymak, TCKN kontrolünü sessizce kapatırdı.
-- ---------------------------------------------------------------------------
update public.sube s
   set ulke_kod = v.iso, telefon_kodu = v.tel, zaman_dilimi = v.tz, para_birimi = v.para
  from (values
        ('TR', '+90',  'Europe/Istanbul', 'TRY', '^(turkiye|türkiye|turkey|tc|tr)$'),
        ('DE', '+49',  'Europe/Berlin',   'EUR', '^(almanya|deutschland|germany|de)$'),
        ('NL', '+31',  'Europe/Amsterdam','EUR', '^(hollanda|netherlands|nl)$'),
        ('GB', '+44',  'Europe/London',   'GBP', '^(ingiltere|birlesik krallik|united kingdom|uk|gb)$'),
        ('AZ', '+994', 'Asia/Baku',       'AZN', '^(azerbaycan|azerbaijan|az)$'),
        ('US', '+1',   'America/New_York','USD', '^(abd|amerika|usa|us)$')
       ) as v(iso, tel, tz, para, desen)
 where lower(trim(coalesce(s.ulke, ''))) ~ v.desen
   and s.ulke_kod = 'TR' and s.para_birimi = 'TRY';   -- yalniz DOKUNULMAMIS satirlar

do $$
begin
    raise notice '666 tamam: % sube · dagilim: %',
        (select count(*) from public.sube),
        (select string_agg(x.ulke_kod || '=' || x.n::text, ', ' order by x.ulke_kod)
           from (select ulke_kod, count(*) as n from public.sube group by ulke_kod) x);
end $$;

-- ---------------------------------------------------------------------------
--  KULLANICININ ŞUBELERİ: yerel ayarlar da dönsün (665'teki fonksiyon genişler;
--  imza aynı sırada kalır, yeni kolonlar SONA eklenir).
-- ---------------------------------------------------------------------------
drop function if exists public.fn_kullanici_subeleri(integer);

create function public.fn_kullanici_subeleri(p_kullanici_id integer)
returns table (sube_id integer, ad varchar, varsayilan smallint, yazma smallint,
               ulke_kod varchar, telefon_kodu varchar, zaman_dilimi varchar,
               para_birimi varchar)
language sql stable as $$
    select s.id, s.ad,
           max(case when kr.ana = 1 then rs.varsayilan else 0 end)::smallint,
           max(rs.yazma)::smallint,
           min(s.ulke_kod), min(s.telefon_kodu), min(s.zaman_dilimi), min(s.para_birimi)
      from public.fn_kullanici_rolleri(p_kullanici_id) kr
      join public.rol_sube rs on rs.rol_id = kr.rol_id
      join public.sube s      on s.id = rs.sube_id and s.aktif = 1
     group by s.id, s.ad
$$;

comment on function public.fn_kullanici_subeleri(integer) is
  'Kullanicinin subeleri: rollerin birlesimi, yazma hakki en genis olan, '
  'varsayilan sube ANA ROLden (665/234) + subenin yerel ayarlari (666).';
