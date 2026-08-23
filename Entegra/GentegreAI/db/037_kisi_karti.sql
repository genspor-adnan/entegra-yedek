-- ============================================================================
--  Gentegre AI — Kisi karti (kisi_karti.html / kisi_listesi.html mockuplari)
--  037_kisi_karti.sql
--
--  Kisiler ayri tablo DEGIL - taraf.bag_id yorumunun (001_sema_taraf.sql: "Ilgili
--  kisi / sube kaydinin bagli oldugu taraf, eski REHBERILETISIM.REHBERID") izinden
--  giderek kisi=1 olan taraf satirlaridir. Kapsam kararlastirildi: temel kimlik/
--  iletisim (rol/yetki-seviyesi/KVKK/etiket/iliski-skoru/foto/aktivite-gecmisi YOK).
-- ============================================================================
\set ON_ERROR_STOP on

-- gorev: is unvani/gorevi (mockup "Ünvan / Görev", ör. "Satınalma Müdürü") - taraf.unvan
--   ile KARISTIRILMASIN, o zaten kisi icin "Ad Soyad" gorunen adi tutuyor (asagidaki
--   tetikleyici ile otomatik uretiliyor).
-- departman: kod_liste secimi (BOLUM -2251, "Ops_Bizim_Departman" - PrjConst.pas),
--   taraf_personel.departman ile AYNI kod listesini kullanir - kullanici "İK'da da
--   kullanacağız" dedi, tek liste iki modulde de gecerli olsun diye taraf'a eklendi
--   (taraf_personel'un kendi departman kolonuna DOKUNULMADI, ileride birlestirme ayri is).
alter table public.taraf add column if not exists gorev varchar(100);
alter table public.taraf add column if not exists departman smallint;

comment on column public.taraf.gorev is 'Kisi icin is unvani/gorevi (ör. Satınalma Müdürü). Sadece kisi=1 rollerinde kullanilir.';
comment on column public.taraf.departman is 'kod_liste (taraf.departman, eski BOLUM -2251) - taraf_personel.departman ile ayni liste.';

update public.kod_liste set kod = 'taraf.departman', ad = 'Departman' where eski_bolum = -2251;

-- ------------------------------------------------------- kisi.unvan otomatik ----
-- taraf.unvan NOT NULL; kisi kartinda kullanici Ad+Soyad girer, "Ad Soyad" birlesimi
-- unvan'a YAZILIR (grid/arama zaten unvan uzerinden calisiyor - ix_taraf_unvan_*).
create or replace function public.fn_taraf_kisi_unvan_ata() returns trigger as $$
begin
    if new.kisi = 1 and coalesce(trim(new.ad), '') <> '' then
        new.unvan := trim(coalesce(new.ad, '') || ' ' || coalesce(new.soyad, ''));
    end if;
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_taraf_kisi_unvan_ata on public.taraf;
create trigger trg_taraf_kisi_unvan_ata
    before insert or update on public.taraf
    for each row execute function public.fn_taraf_kisi_unvan_ata();

-- ------------------------------------------------------- bagli cari lookup ----
-- KartKatalogu'nun genel KodTablosu mekanizmasi "select id, ad from X where aktif=1"
-- bekliyor (bkz. KartDeposu.KodTablosuSecenekleriAsync) - taraf'in kendi kolon adlari
-- (unvan/durum) uymadigi icin ince bir gorunum.
create or replace view public.v_cari_lookup as
    select id, unvan as ad, case when durum = 1 then 1 else 0 end as aktif
    from public.taraf
    where musteri = 1 or tedarikci = 1;

comment on view public.v_cari_lookup is
  'Kisi kartinin "Bagli Cari" KodTablosu secimi icin (id/ad/aktif sozlesmesi).';

