-- 310: Cekim oncesi KONTROL LISTESI (mockup radyoloji_istem_karti.html).
--
-- Kullanici: "istem ekraninin eksik kisimlarini tamamla". Mockup'taki kontrol
-- listesi bir guvenlik kaydidir: MR'da metal/pil, BT ve mamografide gebelik,
-- kontrastli tetkikte alerji/kreatinin sorulmadan hasta cihaza alinmaz.
--
-- NEDEN TABLO: sorular MODALITEYE gore degisir ve zamanla degisir (yeni cihaz,
-- yeni protokol). Koda gomulu bir liste, soruyu degistirmek icin surum
-- gerektirirdi; ayrica "kim, ne zaman yanitladi" izi tutulamazdi - bu iz
-- adli/kalite denetiminde istenen asil seydir.
--
-- KURAL TETIKTE: zorunlu sorular yanitlanmadan istem "Cekildi" (durum 2)
-- yapilamaz. Kurali arayuze birakmak, ayni kaydi guncelleyen baska bir yolun
-- (jenerik kart guncelleme, toplu aksiyon, ileride servis) kurali atlamasi
-- demek olurdu.

-- ------------------------------------------------------------- soru katalogu --
create table if not exists public.radyoloji_kontrol_soru (
  id            integer generated always as identity primary key,
  -- null = TUM modaliteler icin sorulur (or. onam).
  modalite      smallint,
  soru          varchar(200) not null,
  -- 1 = evet/hayir, 2 = serbest deger (or. kreatinin mg/dL).
  yanit_tipi    smallint not null default 1,
  zorunlu       smallint not null default 1,
  sira          integer  not null default 0,
  aktif         smallint not null default 1
);

comment on table public.radyoloji_kontrol_soru is
  'Cekim oncesi guvenlik sorulari (310) - modaliteye gore.';
comment on column public.radyoloji_kontrol_soru.modalite is
  'Hangi modalitede sorulur; null = hepsinde.';

create index if not exists ix_rad_kontrol_soru_mod
    on public.radyoloji_kontrol_soru (modalite) where aktif = 1;

-- --------------------------------------------------------------- yanitlar --
create table if not exists public.radyoloji_kontrol (
  id            integer generated always as identity primary key,
  istem_id      integer not null references public.radyoloji_istem(id) on delete cascade,
  soru_id       integer not null references public.radyoloji_kontrol_soru(id),
  yanit         varchar(120) not null default '',
  kaydeden      integer,
  kayit_zamani  timestamp not null default (now())::timestamp,
  constraint ux_rad_kontrol unique (istem_id, soru_id)
);

comment on table public.radyoloji_kontrol is
  'Istem bazinda kontrol listesi yanitlari (310): kim, ne zaman, ne yanitladi.';

create index if not exists ix_rad_kontrol_istem on public.radyoloji_kontrol (istem_id);

-- ------------------------------------------------------------ soru tohumu --
-- Modalite kodlari (283): 1 BT, 2 MR, 3 USG, 4 Rontgen, 5 Mamografi, 6 DEXA,
--   7 Anjiyo, 8 Skopi.
insert into public.radyoloji_kontrol_soru (modalite, soru, yanit_tipi, zorunlu, sira)
select v.modalite, v.soru, v.yanit_tipi, v.zorunlu, v.sira
  from (values
    -- MR: metal/pil hayati onemde; klostrofobi sedasyon planlamasi icin.
    (2::smallint, 'Gebelik / gebelik şüphesi var mı?',            1::smallint, 1::smallint, 10),
    (2::smallint, 'Metal implant, kalp pili, koklear implant?',   1::smallint, 1::smallint, 20),
    (2::smallint, 'Klostrofobi / sedasyon ihtiyacı?',             1::smallint, 0::smallint, 30),
    (2::smallint, 'Onam formu alındı mı?',                        1::smallint, 1::smallint, 40),
    -- BT: gebelik (doz) + kontrast guvenligi.
    (1::smallint, 'Gebelik / gebelik şüphesi var mı?',            1::smallint, 1::smallint, 10),
    (1::smallint, 'Kontrast madde alerjisi var mı?',              1::smallint, 1::smallint, 20),
    (1::smallint, 'Kreatinin değeri (mg/dL)',                     2::smallint, 0::smallint, 30),
    (1::smallint, 'Onam formu alındı mı?',                        1::smallint, 1::smallint, 40),
    -- Mamografi ve rontgen/skopi: gebelik.
    (5::smallint, 'Gebelik / emzirme durumu var mı?',             1::smallint, 1::smallint, 10),
    (4::smallint, 'Gebelik / gebelik şüphesi var mı?',            1::smallint, 1::smallint, 10),
    (8::smallint, 'Gebelik / gebelik şüphesi var mı?',            1::smallint, 1::smallint, 10),
    -- Anjiyo: girisimsel - alerji, kanama ve onam.
    (7::smallint, 'Gebelik / gebelik şüphesi var mı?',            1::smallint, 1::smallint, 10),
    (7::smallint, 'Kontrast madde alerjisi var mı?',              1::smallint, 1::smallint, 20),
    (7::smallint, 'Kan sulandırıcı kullanıyor mu?',               1::smallint, 1::smallint, 30),
    (7::smallint, 'Onam formu alındı mı?',                        1::smallint, 1::smallint, 40)
  ) as v(modalite, soru, yanit_tipi, zorunlu, sira)
 where not exists (
   select 1 from public.radyoloji_kontrol_soru s
    where s.modalite is not distinct from v.modalite and s.soru = v.soru);

-- ------------------------------------------------------------------ tetik --
-- Zorunlu sorular yanitlanmadan "Cekildi" (durum 2) olamaz. Durum 2'den
-- ILERI gecislerde (rapor, onay) tekrar bakilmaz: kontrol cekim anina aittir.
create or replace function public.tg_radyoloji_cekim_kontrolu()
returns trigger language plpgsql as $$
declare
  v_eksik text;
begin
  if new.durum >= 2 and coalesce(old.durum, 0) < 2 then
    select string_agg(s.soru, ', ' order by s.sira)
      into v_eksik
      from public.radyoloji_kontrol_soru s
      left join public.radyoloji_kontrol k
             on k.soru_id = s.id and k.istem_id = new.id
     where s.aktif = 1 and s.zorunlu = 1
       and (s.modalite is null or s.modalite = new.modalite)
       and coalesce(btrim(k.yanit), '') = '';

    if v_eksik is not null then
      raise exception 'Çekim öncesi kontrol listesi tamamlanmadan "Çekildi" işaretlenemez. Eksik: %', v_eksik
        using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists tr_radyoloji_cekim_kontrolu on public.radyoloji_istem;
create trigger tr_radyoloji_cekim_kontrolu
  before update on public.radyoloji_istem
  for each row execute function public.tg_radyoloji_cekim_kontrolu();

comment on function public.tg_radyoloji_cekim_kontrolu() is
  'Zorunlu kontrol sorulari yanitlanmadan istem cekildi isaretlenemez (310).';
