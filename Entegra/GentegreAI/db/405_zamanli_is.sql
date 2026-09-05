-- ============================================================================
--  405 - ZAMANLI ISLER (Faz 0, ortak platform)
--
--  TITCK ilac listesi haftalik yayinlaniyor; birinin her hafta dugmeye basmasi
--  gerekiyordu. Ayni ihtiyac sirada bekleyen isler icin de var (SKRS senkronu,
--  e-Nabiz kuyrugu tazeleme, donem kapanis hatirlatmasi) - bu yuzden tek bir
--  ise degil, KUCUK BIR ZAMANLAYICIYA baglaniyor.
--
--  Tablo isin NE ZAMAN calisacagini ve SON DURUMUNU tutar; isin KENDISI kodda
--  (ZamanliIsler kayit defteri). Boylece kod bilmeyen bir satir eklenip
--  "calismiyor" diye aranmaz - bilinmeyen kod calistirilmaz, sebebi yazilir.
--
--  KILIT: isci satiri "calisiyor = 1" yapip alir; iki sunucu ayni isi ayni
--  anda calistirmaz. Yarida kalan (servis coktu) 6 saat sonra serbest kalir.
-- ============================================================================

create table if not exists public.zamanli_is (
    kod           varchar(40)  primary key,
    ad            varchar(120) not null,
    aktif         smallint     not null default 1,
    -- 1 saatlik · 2 gunluk · 3 haftalik · 4 aylik
    periyot       smallint     not null default 3,
    -- haftalikta 1 Pazartesi .. 7 Pazar; aylikta ayin gunu (1-28)
    gun           smallint     not null default 1,
    saat          smallint     not null default 4,
    dakika        smallint     not null default 0,
    sonraki       timestamp,
    son_calisma   timestamp,
    calisiyor     smallint     not null default 0,
    calisma_bas   timestamp,
    basarili      smallint     not null default 0,
    son_sonuc     varchar(400) not null default '',
    sure_ms       integer      not null default 0,
    aciklama      varchar(300) not null default '',
    ekleyen       integer      not null default 0,
    ekleme_tarihi timestamp    not null default now(),
    degistiren    integer      not null default 0,
    degistirme_tarihi timestamp
);

comment on table public.zamanli_is is
    'Zamanli isler (405): ne zaman calisacagi ve son durumu. Isin kendisi kodda (ZamanliIsler).';

create index if not exists ix_zamanli_is_sira on public.zamanli_is(aktif, sonraki);

-- Kurulumda gelen is: TITCK ilac listesi, HAFTALIK (Pazartesi 04:00).
--   Gece calisir - liste 23 bin satir ve mesai icinde katalogu kilitlemesin.
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aciklama)
select 'titck.ilac', 'TİTCK ilaç listesi güncelleme', 3, 1, 4, 0,
       'TİTCK Ruhsatlı Beşerî Tıbbî Ürünler Listesi''nin en güncel sürümünü indirir ve ilaç kataloğunu tazeler.'
 where not exists (select 1 from public.zamanli_is where kod = 'titck.ilac');

-- Yetki: zamanli islerin gorulmesi/yonetilmesi yonetim isidir.
insert into public.yetki (kod, ad, grup, sira, urun_modu)
select 'zamanli_is', 'Zamanlanmış işler', 'yonetim', 74, 0
 where not exists (select 1 from public.yetki where kod = 'zamanli_is');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select 1, y.id, 1, 1, 1, 1
  from public.yetki y
 where y.kod = 'zamanli_is'
   and not exists (select 1 from public.rol_yetki r where r.rol_id = 1 and r.yetki_id = y.id);

update public.rol set yetki_surumu = yetki_surumu + 1 where id = 1;
