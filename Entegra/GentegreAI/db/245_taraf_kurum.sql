-- 245: HASTANIN BAĞLI OLDUĞU KURUM (kullanıcı: "tarafa bağlı 1:1 taraf_kurum
-- aç; hastanın bağlı olduğu kurum - sponsor/ödeyen - buradan gelsin;
-- türleri: Özel (kendi), ÖSS (özel sağlık sigortası), SGK").
--
-- 1:1 uzantı (id = taraf.id) - taraf_hasta / taraf_personel ile aynı desen.
-- "Kim ödeyecek" bilgisi: Özel'de hastanın kendisi, ÖSS'de sigorta şirketi
-- (kurum_id → taraf), SGK'da devlet (kurum_id boş kalabilir).

create table if not exists public.taraf_kurum (
  id                integer  not null primary key references public.taraf(id) on delete cascade,
  tur               smallint not null default 1,      -- 1 Özel / 2 ÖSS / 3 SGK
  kurum_id          integer  references public.taraf(id),   -- ÖSS: sigorta şirketi
  police_no         varchar(40)  not null default '',
  gecerlilik        date,
  kapsam            varchar(200) not null default '',  -- teminat/kapsam notu
  aciklama          varchar(300) not null default '',
  ekleyen           integer  not null default 0,
  ekleme_tarihi     timestamp not null default now()::timestamp,
  degistiren        integer  not null default 0,
  degistirme_tarihi timestamp
);

comment on table public.taraf_kurum is
  'Hastanın sponsoru/ödeyeni (245): Özel (kendi) / ÖSS (sigorta) / SGK.';

create index if not exists ix_taraf_kurum_kurum on public.taraf_kurum (kurum_id)
  where kurum_id is not null;

insert into public.kod_liste (kod, ad)
select 'taraf.kurum_turu', 'Kurum Türü'
 where not exists (select 1 from public.kod_liste where kod = 'taraf.kurum_turu');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  cross join (values (1, 'Özel (Kendi)'),
                     (2, 'ÖSS (Özel Sağlık Sigortası)'),
                     (3, 'SGK')) as v(deger, ad)
 where l.kod = 'taraf.kurum_turu'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id);
