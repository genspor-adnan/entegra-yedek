-- =============================================================================
--  1143  DELPHI AKTARIMI - EK MODÜLLER: KİMLİK KOLONLARI + KAYNAK (stg) TABLOLARI
--
--  Kullanıcı (22.10.2026): FETA müşterisi Delphi'yi bırakıp web'e geçiyor; çekirdek
--  ERP'nin (cari/stok/belge/kasa - 1081..1142) yanında görevler + aktiviteler,
--  dökümanlar + ekler + e-Belge geçmişi, personel + kullanıcılar, çek/senet, teklif,
--  hesap planı ve demirbaş da taşınacak.
--
--  Bu modüller SÜREKLİ aktarıma (ajan, Change Tracking) girmez: Delphi kapanırken
--  bir kez aktarılır (db/araclar/aktar_ek.ps1: goc_al.ps1 ile MSSQL -> stg, sonra
--  public.fn_aktar_ek()). Tekrar çalıştırmak güvenlidir - her satır Delphi
--  kimliğiyle (aktarim_kaynak = 1, aktarim_tablo, aktarim_id) eşlenir, aynı satır
--  ikinci kez yazılmaz.
--
--  1) Hedef tablolara 1080'deki kimlik kolonları + benzersiz index.
--  2) stg tabloları: goc_al.ps1 PG'deki stg kolonlarını okur ve MSSQL'den YALNIZ
--     onları çeker - burada aktarımın kullandığı kolonlar tanımlanır.
--  Fonksiyonlar 1144..1148'de, toplu çağrı 1149'da.
-- =============================================================================

begin;

do $$
declare t text;
begin
    foreach t in array array[
        'taraf_personel', 'personel_izin', 'personel_hareket',
        'gorev', 'mesaj_sohbet', 'mesaj', 'hatirlatma',
        'dokuman', 'dokuman_klasor', 'dokuman_surum', 'dokuman_iliski',
        'e_belge', 'e_belge_mesaj',
        'cek_senet', 'cek_senet_hareket',
        'demirbas', 'hesap_plani']
    loop
        if to_regclass('public.' || t) is null then
            raise notice '1143: % yok, atlandi', t;
            continue;
        end if;
        execute format('alter table public.%I add column if not exists aktarim_kaynak smallint', t);
        execute format('alter table public.%I add column if not exists aktarim_tablo varchar(30)', t);
        execute format('alter table public.%I add column if not exists aktarim_id bigint', t);
        execute format(
            'create unique index if not exists %I on public.%I (aktarim_kaynak, aktarim_tablo, aktarim_id) '
            'where aktarim_kaynak is not null', 'ux_' || t || '_aktarim', t);
    end loop;
end $$;

-- Delphi'de EKLEYEN / DEGISTIREN / SORUMLU / ATAYAN / PERSONEL kolonları kullanıcının
--   REHBER kimliğini tutar (KULLANICI.ID değil). Web'de kullanıcı = taraf.
create or replace function public.fn_aktarim_kisi_id(p_rehberid bigint)
returns integer language sql stable as $f$
    select case when coalesce(p_rehberid, 0) > 0 then public.fn_aktarim_web_id('taraf', 'REHBER', p_rehberid) end
$f$;
comment on function public.fn_aktarim_kisi_id(bigint) is
    '1143: Delphi REHBER kimliği (kullanıcı / personel / sorumlu) -> web taraf id; 0/boş/bilinmeyen -> null.';

create schema if not exists stg;

-- ------------------------------------------------------- kullanıcı / personel ---
create table if not exists stg.kullanici (
    id integer, rehberid integer, sifre varchar(200), kod varchar(60), rolid integer, durum smallint,
    ekleyen integer, eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp,
    subeid smallint, dil smallint, token uuid, mobil smallint, soru smallint, cevap varchar(200),
    sifredegisme timestamp, skinadi varchar(100));
create table if not exists stg.roller (
    id integer, rol varchar(100), durum smallint, ekleyen integer, eklemetarihi timestamp,
    degistiren integer, degistirmetarihi timestamp, subeid smallint, ustid integer, ty smallint,
    departman smallint, gorevid smallint);

drop table if exists stg.rehberpersonel;
create table stg.rehberpersonel (
    id integer, rehberid integer, adsoyad varchar(200), varsayilan smallint, notlar text,
    aktif smallint, subeid smallint, eklemetarihi timestamp);
drop table if exists stg.personelizin;
create table stg.personelizin (
    id integer, rehberid integer, izinbaslangic timestamp, izinbitis timestamp, hak smallint,
    izinverenrehberid integer, izinturu varchar(20), vekil integer, aciklama text, ekleyen integer,
    eklemetarihi timestamp, subeid smallint, donem integer, birim smallint, izinligunsayisi numeric(10,2));
drop table if exists stg.pers_hareket;
create table stg.pers_hareket (
    id integer, rehberid integer, tarih timestamp, tur smallint, aciklama text, rolid integer, meslekid integer);

-- ------------------------------------------------------------- görev / CRM ---
drop table if exists stg.gorevler;
create table stg.gorevler (
    id integer, listeid integer, konusu varchar(500), baslamatarihi timestamp, bitistarihi timestamp,
    rehberid integer, mus_ilgili integer, projeid integer, bayrak smallint, ackapa smallint, durum smallint,
    animsat smallint, ekleyen integer, eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp,
    turu smallint, giriskaynak smallint);
drop table if exists stg.gorevkullanici;
create table stg.gorevkullanici (id integer, listgorevid integer, tur smallint, rehberid integer);
drop table if exists stg.gorevyorum;
create table stg.gorevyorum (
    id integer, gorevid integer, tur smallint, yorum text, ekleyen integer, eklemetarihi timestamp,
    tarih timestamp, atac smallint, zenginmetin smallint);
drop table if exists stg.aktiviteler;
create table stg.aktiviteler (
    id integer, turu smallint, musteriid integer, baslamatarihi timestamp, bitistarihi timestamp,
    animsatmatarihi timestamp, konusu varchar(500), sorumlu integer, durum smallint, projeid integer,
    notlar text, atayan integer, oncelik smallint, tamamlanmaorani smallint, ekleyen integer,
    eklemetarihi timestamp, degistiren integer, degistirmetarihi timestamp, tipi smallint, subeid smallint);
drop table if exists stg.aktivitenotlar;
create table stg.aktivitenotlar (
    id integer, aktiviteid integer, tarih timestamp, aciklama text, ekleyen integer, eklemetarihi timestamp);
drop table if exists stg.animsat;
create table stg.animsat (tarih timestamp, tur integer, id integer, personel integer);

-- ------------------------------------------------- döküman / ek / e-Belge ---
drop table if exists stg.dokuman;
create table stg.dokuman (
    id integer, belgeno varchar(100), durum smallint, yon smallint, kategori varchar(200), ad varchar(500),
    konu varchar(1000), tur smallint, rehberid integer, modul integer, modulid integer, klasor integer,
    gecerlilik_tarihi timestamp, ekleyen integer, eklemetarihi timestamp, degistiren integer,
    degistirmetarihi timestamp, subeid smallint, gizlilikderecesi smallint, anahtar varchar(1000),
    tarih timestamp);
drop table if exists stg.dokumanklasor;
create table stg.dokumanklasor (
    id integer, ustid integer, tur smallint, ad varchar(300), subeid smallint, durum smallint);
-- IMAJ içeriği: aktar_ek.ps1 BELGE'yi okur, ZLib ise açar, ICDIS=1 ise diskteki
--   .OBJ'yi okur; `icerik` HAM dosyadır. `kaynak_yok` = içerik bulunamadı.
drop table if exists stg.imaj;
create table stg.imaj (
    id integer, varsayilan smallint, rehberid integer, icdis smallint, yeri smallint, yer_id integer,
    durum smallint, belgeno smallint, surum varchar(50), tur smallint, belgeadi varchar(500),
    aciklama varchar(1000), ekleyen integer, eklemetarihi timestamp, subeid smallint, belgeturu varchar(100),
    boyut numeric(20,0), icerik bytea, kaynak_yok smallint default 0);
drop table if exists stg.ebelge;
create table stg.ebelge (
    id bigint, fatbaslikid integer, rehberid integer, belgeturu smallint, yon smallint, uuid varchar(64),
    belgeno varchar(50), gondericialias varchar(250), alicialias varchar(250), durum smallint, api_json text,
    ubl_xml text, ekleyen integer, eklemetarihi timestamp, degistirmetarihi timestamp,
    servis_durum_kodu varchar(100), servis_durum_adi varchar(250), gib_durum_kodu varchar(50),
    gib_durum_aciklama varchar(500), yanit_durum_kodu varchar(100), yanit_durum_adi varchar(250),
    ubl_xml_zip bytea);
drop table if exists stg.ebelgemesaj;
create table stg.ebelgemesaj (
    id bigint, ebelgeid bigint, yon smallint, islemturu smallint, mesajtipi smallint, mesaj text,
    httpkodu integer, serviskodu varchar(50), hatakodu varchar(100), hatamesaji text, eklemetarihi timestamp,
    onceki_durum_kodu varchar(100), yeni_durum_kodu varchar(100));

-- ------------------------------------------------------------- çek / senet ---
drop table if exists stg.cekler;
create table stg.cekler (
    id integer, kod varchar(50), rehberid integer, tur smallint, durum smallint, tarih timestamp,
    makbuzno varchar(50), odemeyeri varchar(200), vade timestamp, tutar numeric(19,4), kur varchar(10),
    hesapno varchar(100), serino bigint, aciklama varchar(500), doviz_tutari numeric(19,4),
    doviz_kuru varchar(10), hesapid integer, borclu varchar(200), subeid smallint, projeid integer,
    ceksenet smallint, ekstredekullan smallint, eklemetarihi timestamp);
drop table if exists stg.cekhareket;
create table stg.cekhareket (
    id integer, ceksenetlerid integer, tarih timestamp, islem smallint, rehberid integer,
    bankahesaplarid integer, aciklama varchar(500), subeid smallint, belgeno varchar(50),
    doviz_tutari numeric(19,4), doviz_kuru varchar(10), tutar numeric(19,4), kur varchar(10),
    ekstredekullan smallint, projeid integer, eklemetarihi timestamp);

-- --------------------------------------------- teklif / hesap planı / demirbaş ---
drop table if exists stg.teklif;
create table stg.teklif (
    id integer, tarih timestamp, rehberid integer, revizeid integer, teklifno varchar(50), turu smallint,
    konusu varchar(500), durum smallint, gecerlilik_suresi smallint, teslim_suresi smallint, kdvdurum varchar(20),
    teklif_matrahi numeric(19,4), kdv_tutari numeric(19,4), iskonto_tutari numeric(19,4),
    teklif_tutari numeric(19,4), kur varchar(10), doviz_tutari numeric(19,4), doviz_kuru varchar(10),
    vade smallint, aciklama varchar(1000), projeid integer, rehberiletid integer, subeid smallint,
    dovizkur numeric(19,6), teklifseri varchar(20), kocanno integer, eklemetarihi timestamp, ekleyen integer);
drop table if exists stg.teklifdetay;
create table stg.teklifdetay (
    id integer, teklifid integer, alternatifno smallint, urunid integer, tur smallint, aciklama varchar(1000),
    adet numeric(19,4), birim varchar(20), miktar numeric(19,4), birimfiyat numeric(19,6), iskonto float8,
    iskonto2 float8, kdv smallint, tutar numeric(19,4), kur varchar(10), doviz_tutari numeric(19,4),
    doviz_kuru varchar(10), doviz_birimfiyat numeric(19,6), dovizkurdegeri numeric(19,6), masrafid integer,
    siralama integer);
drop table if exists stg.hesapplani;
create table stg.hesapplani (
    id integer, hesapkodu varchar(50), hesapadi varchar(300), kur varchar(10), aciklama varchar(500),
    durum smallint, subeid smallint);
drop table if exists stg.demirbas;
create table stg.demirbas (
    id integer, stokid integer, stokkodu varchar(50), serino varchar(100), durum smallint, notlar text,
    rehberid integer, subeid smallint, demirbasno varchar(50), demirbasadi varchar(300), barkod varchar(100),
    eklemetarihi timestamp);

commit;
