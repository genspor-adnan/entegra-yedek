-- 305: DIS DOKTOR (sevk eden hekim) - goruntuleme merkezine hasta gonderen
-- kurum DISI hekimlerin kaydi.
--
-- Kullanici: "cari altina Dış Doktor listesi de oluşturmamız gerekiyor.. yine
-- taraf ve taraf_personel kullanırız.. taraf_personel de bir alanla iç/dış
-- ayrımı yapılabilir."
--
-- NEDEN AYRI TABLO DEGIL: dis hekim de bir KISIDIR - adi, telefonu, adresi,
-- vergi kimligi taraf'ta zaten var; mesleki bilgisi (brans, tescil no)
-- taraf_personel'in isi. Ayri tablo acmak ayni alanlari ikinci kez tanimlamak
-- ve "bu hekim hem bizde calisiyor hem disaridan sevk ediyor" durumunu
-- imkansiz kilmak olurdu.
--
-- RADYOLOJI ILE BAGI: radyoloji_istem.istek_hekim_id zaten taraf'a bakiyor.
-- Dis istemde bugune kadar SERBEST METIN (dis_hekim_ad) yaziliyordu; artik
-- kayitli dis hekim SECILEBILIYOR, boylece "hangi hekim kac hasta gonderdi"
-- sorusu cevaplanabilir. Serbest metin ALANI KALIYOR: bir kerelik gelen,
-- kaydedilmeye degmeyen hekim icin.

alter table public.taraf_personel
  -- 0 = kurum personeli (varsayilan), 1 = DIS hekim (baska kurumda calisir).
  add column if not exists dis_hekim smallint not null default 0,
  add column if not exists brans     varchar(80)  not null default '',
  -- Calistigi kurum: cari olarak KAYITLIYSA id, degilse serbest metin.
  --   Ikisi birden tutuluyor cunku sevk eden hastanelerin cogu bizim cari
  --   listemizde yok - ad yazilabilmeli ama kayitliysa baglanabilmeli.
  add column if not exists kurum_id  integer references public.taraf(id),
  add column if not exists kurum_ad  varchar(200) not null default '',
  add column if not exists tescil_no varchar(30)  not null default '';

comment on column public.taraf_personel.dis_hekim is
  'Dis hekim mi (305): 0 kurum personeli, 1 disaridan hasta gonderen hekim.';
comment on column public.taraf_personel.kurum_ad is
  'Calistigi kurumun adi - cari kaydi yoksa serbest metin (305).';

create index if not exists ix_taraf_personel_dis_hekim
    on public.taraf_personel (dis_hekim) where dis_hekim = 1;

-- ------------------------------------------------------------ kod listesi --
insert into public.kod_liste (kod, ad)
select 'hekim.brans', 'Hekim Branşı'
 where not exists (select 1 from public.kod_liste where kod = 'hekim.brans');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.deger, 1
  from public.kod_liste l
 cross join (values
    (1,  'Ortopedi ve Travmatoloji'), (2,  'Nöroloji'),
    (3,  'Beyin ve Sinir Cerrahisi'), (4,  'Genel Cerrahi'),
    (5,  'İç Hastalıkları'),          (6,  'Kardiyoloji'),
    (7,  'Göğüs Hastalıkları'),       (8,  'Üroloji'),
    (9,  'Kadın Hastalıkları ve Doğum'), (10, 'Çocuk Sağlığı ve Hastalıkları'),
    (11, 'Fizik Tedavi ve Rehabilitasyon'), (12, 'Kulak Burun Boğaz'),
    (13, 'Göz Hastalıkları'),         (14, 'Genel Pratisyen'),
    (99, 'Diğer')
  ) as v(deger, ad)
 where l.kod = 'hekim.brans'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- --------------------------------------------------------------- lookup'lar --
-- Dis hekim secim listesi (radyoloji dis istem ekrani + ileride sevk kayitlari).
create or replace view public.v_dis_hekim_lookup as
select t.id,
       t.unvan as ad,
       coalesce(nullif(p.kurum_ad, ''), coalesce(k.unvan, '')) as kurum,
       coalesce(kd.ad, '') as brans,
       t.durum as aktif
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
  left join public.taraf k on k.id = p.kurum_id
  left join public.kod_liste kl on kl.kod = 'hekim.brans'
  left join public.kod_deger kd on kd.liste_id = kl.id
                               and kd.deger::text = nullif(p.brans, '')
 where p.dis_hekim = 1 and coalesce(t.durum, 1) = 1;

comment on view public.v_dis_hekim_lookup is
  'Kayitli DIS hekimler (305) - sevk eden doktor secimlerinde kullanilir.';
