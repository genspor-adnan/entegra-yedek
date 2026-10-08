-- =====================================================================
-- 985 - BANKO TANIMI: banko, banko_pos, banko_cihaz
--
-- Kullanici 08.10.2026: "vezne yerine Banko kullan.. Banko listesi ve
--   Banko karti icin sekmeler acilan mockup yap", "banko tanimi yaparken
--   oraya bagli POS listesi de girilebilmeli", "banko taniminda kullanici
--   olmaz", "opsiyonel olarak banko sorumlusu onay verince banko
--   acilabilir".
-- Tasarim: Ekranlar/Kayit Kabul/banko_tanimi_v2.html
--
-- BANKO = FIZIKSEL NOKTA: kasasi, POS'u ve donanimi olan yer. Personeli
--   YOKTUR - kim calisacagi oturum acilisinda belirlenir (banko +
--   gorevli). Tanima personel listesi koymak her vardiya ve her izinde
--   tanimi duzenlemek olurdu; kimin tahsilat yapabilecegi ROLDEN gelir.
--
-- KASASIZ BANKO OLABILIR (tur = 2, "Danisma"): karsilama bankosu
--   yonlendirir, tahsilat yapmaz - hesap_id, POS ve oturum beklenmez. Bu
--   yuzden hesap_id uzerinde CHECK YOK: kart doldurulurken turu secip
--   hesabi henuz secmemis kullaniciya veritabani hatasi dondurmek yerine
--   alan serbest birakildi.
-- =====================================================================

create table if not exists public.banko (
    id                  serial primary key,
    kod                 varchar(20)  not null,
    ad                  varchar(120) not null,
    sube_id             integer      not null,
    -- 1 = Kayit kabul + kasa, 2 = Danisma (kasasiz), 3 = Numune kabul + kasa,
    -- 4 = Yalniz kasa (banko kasiyeri)
    tur                 smallint     not null default 1,
    konum               varchar(160) not null default '',
    dahili              varchar(20)  not null default '',

    -- ---------------------------------------------------- kasa / muhasebe
    hesap_id            integer,
    -- Gun sonunda kasada BIRAKILACAK tutar; kalani teslim edilir ve bu
    --   tutar yarinin devri olur.
    devir_tutar         numeric(18,2) not null default 0,
    doviz_kabul         smallint     not null default 0,

    -- -------------------------------------------------------- varsayilanlar
    fiyat_listesi_id    integer,
    -- Tahsilat ekraninda secili gelen odeme turu (kod_liste: tahsilat turu).
    varsayilan_odeme    smallint     not null default 0,
    -- VARSAYILAN POS BANKONUN KENDI POS'UDUR: banko_pos.varsayilan = 1
    --   satiri tasir, burada ikinci bir kolon tutulmaz - iki yerde
    --   tutulsa biri digerini yalanlardi.
    fis_yazici          varchar(80)  not null default '',

    -- -------------------------------------------------------------- sinirlar
    nakit_ust_sinir     numeric(18,2) not null default 0,  -- 0 = sinir yok
    tek_islem_ust_sinir numeric(18,2) not null default 0,
    para_ustu_kasasi    numeric(18,2) not null default 0,
    -- Saat kolonu varchar 'HH:MM' (semanin diger saat kolonlariyla ayni).
    gun_sonu_saat       varchar(5)   not null default '',

    -- ------------------------------------------------------- islem kurallari
    -- ONAYLAR OPSIYONEL VE AYRI: kucuk kurumda her sabah onay beklemek
    --   bankoyu durdurur, buyuk kurumda devir farkinin imzasi gerekir.
    --   Yaygin tercih acilisi serbest birakip teslimi imzaya baglamak,
    --   varsayilanlar da oyle.
    acilis_onay         smallint     not null default 0,
    gun_sonu_onay       smallint     not null default 1,
    fis_zorunlu         smallint     not null default 1,
    tahsilatsiz_basvuru smallint     not null default 1,
    kismi_tahsilat      smallint     not null default 0,
    iade_onay           smallint     not null default 1,
    kupur_dokumu        smallint     not null default 1,

    aciklama            varchar(400) not null default '',
    aktif               smallint     not null default 1,
    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now(),
    degistiren          integer      not null default 0,
    degistirme_tarihi   timestamptz
);

-- Kod SUBE ICINDE benzersiz: iki sube de "BNK-01" kullanabilir, merkezin
--   numarasi subeyi baglamaz.
create unique index if not exists banko_kod_benzersiz
    on public.banko (sube_id, upper(kod));
create index if not exists banko_sube_ix on public.banko (sube_id, aktif);

-- ---------------------------------------------------------- banko_pos ----
-- TAHSILATTA YALNIZ O BANKONUN POS'U LISTELENIR (kullanici): yan bankonun
--   terminaline cekilen kart o bankonun gun sonunu tutturmaz, gorevlinin
--   onunde olmayan cihazi listelemek de yalniz hata uretir. Arizali cihaz
--   (durum <> 1) da listelenmez.
create table if not exists public.banko_pos (
    id                  serial primary key,
    banko_id            integer      not null references public.banko(id),
    banka_id            integer,
    terminal_no         varchar(30)  not null default '',
    seri_no             varchar(40)  not null default '',
    uye_isyeri_no       varchar(30)  not null default '',
    -- 1 = Ethernet, 2 = USB, 3 = Seri port, 4 = Entegre degil (manuel)
    baglanti_tur        smallint     not null default 1,
    adres               varchar(60)  not null default '',
    port                integer,
    taksit_min          smallint     not null default 0,
    taksit_max          smallint     not null default 0,
    yabanci_kart        smallint     not null default 0,
    -- POS TAHSILATI KASAYA NAKIT GIRMEZ: kendi banka hesabina yazilir ve
    --   mutabakati ekstreyle yapilir; gun sonu sayimi yalniz nakit
    --   uzerinden. Bu ayrim olmadan her gun sayim farki cikardi.
    hesap_id            integer,
    komisyon_oran       numeric(6,3) not null default 0,
    valor_gun           smallint     not null default 0,
    varsayilan          smallint     not null default 0,
    -- 1 = Calisiyor, 2 = Ulasilamiyor / ariza, 3 = Pasif
    durum               smallint     not null default 1,
    aciklama            varchar(300) not null default '',
    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now(),
    degistiren          integer      not null default 0,
    degistirme_tarihi   timestamptz
);

create index if not exists banko_pos_banko_ix on public.banko_pos (banko_id, durum);
-- BANKODA TEK VARSAYILAN: ikinci varsayilan isaretlenirse tahsilat ekrani
--   hangisini secili getirecegini bilemezdi.
create unique index if not exists banko_pos_varsayilan_tek
    on public.banko_pos (banko_id) where varsayilan = 1;
-- Ayni terminal iki bankoda olamaz (cihaz fiziksel olarak tek yerde).
create unique index if not exists banko_pos_terminal_benzersiz
    on public.banko_pos (upper(terminal_no)) where terminal_no <> '';

-- -------------------------------------------------------- banko_cihaz ----
-- Fis yazici, kimlik/barkod okuyucu. Bakim, ariza ve garanti DEMIRBAS
--   kartinda izlenir (demirbas_id); burada yalniz "hangi cihaz bu bankoda"
--   bilgisi durur - iki yerde cihaz gecmisi tutmak ikisini de guvenilmez
--   yapardi.
create table if not exists public.banko_cihaz (
    id                  serial primary key,
    banko_id            integer      not null references public.banko(id),
    -- 1 = Fis yazici, 2 = Kimlik okuyucu, 3 = Barkod okuyucu,
    -- 4 = Kart okuyucu, 5 = El terminali, 99 = Diger
    tur                 smallint     not null default 1,
    ad                  varchar(80)  not null default '',
    model               varchar(120) not null default '',
    baglanti            varchar(60)  not null default '',
    demirbas_id         integer,
    durum               smallint     not null default 1,
    aciklama            varchar(300) not null default '',
    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now(),
    degistiren          integer      not null default 0,
    degistirme_tarihi   timestamptz
);

create index if not exists banko_cihaz_banko_ix on public.banko_cihaz (banko_id);

-- VARSAYILAN RADYO DAVRANISI: yeni varsayilan isaretlenince digerleri
--   kendiliginden birakilir. Partial unique index guvenlik agi olarak
--   kaliyor, ama kullaniciyi "once oburunun isaretini kaldir" adimina
--   zorlamak gereksiz: "varsayilan" zaten tek secimli bir alan.
create or replace function public.tg_banko_pos_varsayilan()
returns trigger language plpgsql as $$
begin
  if new.varsayilan = 1 then
    update public.banko_pos
       set varsayilan = 0, degistirme_tarihi = now()
     where banko_id = new.banko_id and id <> new.id and varsayilan = 1;
  end if;
  return new;
end $$;

drop trigger if exists tg_banko_pos_varsayilan on public.banko_pos;
create trigger tg_banko_pos_varsayilan
  before insert or update of varsayilan on public.banko_pos
  for each row execute function public.tg_banko_pos_varsayilan();

-- ------------------------------------------------------------- lookup ----
create or replace view public.v_banko_lookup as
select b.id,
       (b.kod || ' - ' || b.ad)::varchar(160) as ad,
       b.aktif,
       b.sube_id
  from public.banko b;

-- -------------------------------------------------------------- yetki ----
-- GRUP "Kasa": banko bir kasa noktasi, yetki matrisinde hesap ve kasa
--   isleminin yaninda durur. Grubu bos birakmak onu matrisin dibine
--   gruplanmamis olarak dusururdu.
insert into public.yetki (kod, ad, grup, tur, sira)
select 'banko', 'Bankolar', 'Kasa', 0, 455
 where not exists (select 1 from public.yetki where kod = 'banko');

update public.yetki set grup = 'Kasa', sira = 455
 where kod = 'banko' and (grup = '' or grup is null);

-- YONETICI: yetkiler tek tek yazili (joker satir yok), yeni yetki eklenince
--   yoneticiye de yazilmali - yoksa ekran yoneticiye bile 403 doner.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'banko'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'yonetici';

-- Banko Sorumlusu tanimi duzenler, Banko Gorevlisi ve Kasiyeri gorur:
--   bankoyu kuran kisi kasa hesabini ve POS'u belirliyor, bu bir ayar
--   isidir - gorevlinin kendi bankosunun sinirlarini degistirmesi
--   denetimi anlamsiz kilardi.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 0, 0
  from public.rol r, public.yetki y
 where r.kod = 'kayit_kabul_sorumlu' and y.kod = 'banko'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 0, 0, 0, 0
  from public.rol r, public.yetki y
 where r.kod in ('kayit_kabul', 'vezne', 'danisma') and y.kod = 'banko'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

update public.rol set yetki_surumu = yetki_surumu + 1
 where kod in ('kayit_kabul_sorumlu', 'kayit_kabul', 'vezne', 'danisma');

do $$
begin
  raise notice '985: banko / banko_pos / banko_cihaz hazir, yetki "banko" tanimli';
end $$;
