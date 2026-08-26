-- ============================================================================
--  Gentegre AI — FIRMA BILGILERI (e-Belgede gonderici taraf)
--  165_firma_bilgileri.sql
--
--  Kullanici: "firma bilgilerini ekle" + mockup: Ekranlar/firma_bilgileri.html
--
--  NEDEN: e-Belge gonderiminde GONDERICI TARAF (supplierParty) zorunlu -
--  unvan, VKN, vergi dairesi, adres, il/ilce. `sube` tablosunda bu alanlarin
--  cogu vardi ama duzenlenecek EKRAN yoktu; Merkez subede unvan ve VKN disinda
--  her sey bostu ve gonderim dogrulamasi bu yuzden duruyordu.
--
--  SUBE = GONDERICI: cok subeli firmada fatura hangi subeden kesildiyse ONUN
--  adresi ve gonderici etiketi gider. Tek subeli kurulumda Merkez tek kayittir
--  ve "firma bilgileri" odur - ayri bir firma tablosu acilmadi.
--
--  MOCKUP'TAKI EK ALANLAR: firma kimligi (tur, NACE, kurulus, sermaye, oda) ve
--  iletisim (KEP, GSM). KEP e-Belge ile dogrudan ilgili; telefon tek alan
--  + GSM yeterli (kullanici).
--
--  MOCKUP'TA OLUP BILEREK ALINMAYANLAR (kullanici karari): "Yetkili / İmza",
--  "Faaliyet" (sektor/SGK/calisan), "Kayıt Bilgisi" ve "Sevkiyat / Fatura
--  Adresleri" bloklari.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------- firma kimligi -----
alter table public.sube
    add column if not exists firma_turu       varchar(40)  not null default '',
    add column if not exists nace_kodu        varchar(20)  not null default '',
    add column if not exists kurulus_tarihi   date         null,
    add column if not exists sermaye          numeric(18,2) not null default 0,
    add column if not exists ticaret_odasi    varchar(120) not null default '',
    add column if not exists oda_sicil_no     varchar(40)  not null default '';

-- ------------------------------------------------------------ iletisim -----
alter table public.sube
    add column if not exists gsm              varchar(30)  not null default '',
    -- KEP: e-Belge ve resmi yazismada kullanilan kayitli elektronik posta.
    add column if not exists kep_adresi       varchar(120) not null default '',
    add column if not exists bolge            varchar(60)  not null default '';

comment on column public.sube.kep_adresi is
  'Kayitli Elektronik Posta - resmi bildirim adresi (165).';
comment on column public.sube.unvan is
  'e-Belgede gorunen RESMI unvan; `ad` ic kullanim icin kisa addir (165).';

-- ------------------------------------------------- gonderici taraf gorunumu -
-- e-Belge JSON ureticisi gonderici bilgisini TEK yerden okusun; hangi alanin
--   nereden geldigi (sube -> firma) burada kapali kalir.
create or replace view public.v_ebelge_gonderici as
    select s.id as sube_id,
           coalesce(nullif(btrim(s.unvan), ''), s.ad)      as unvan,
           regexp_replace(coalesce(s.vkno, ''), '\D', '', 'g') as vkno,
           btrim(coalesce(s.vd, ''))                       as vergi_dairesi,
           btrim(coalesce(s.adres, ''))                    as adres,
           btrim(coalesce(s.ilce, ''))                     as ilce,
           btrim(coalesce(s.il, ''))                       as il,
           coalesce(nullif(btrim(s.ulke), ''), 'Türkiye')  as ulke,
           btrim(coalesce(s.posta_kodu, ''))               as posta_kodu,
           btrim(coalesce(s.telefon, ''))                  as telefon,
           btrim(coalesce(s.eposta, ''))                   as eposta,
           btrim(coalesce(s.web, ''))                      as web,
           btrim(coalesce(s.mersis_no, ''))                as mersis_no,
           btrim(coalesce(s.ticaret_sicil_no, ''))         as ticaret_sicil_no,
           btrim(coalesce(s.efatura_alias, ''))            as gonderici_alias,
           -- Gonderim dogrulamasi tek kosulda: zorunlu alanlar tam mi.
           (coalesce(nullif(btrim(s.unvan), ''), s.ad) <> ''
            and regexp_replace(coalesce(s.vkno, ''), '\D', '', 'g') <> ''
            and btrim(coalesce(s.vd, '')) <> ''
            and btrim(coalesce(s.adres, '')) <> ''
            and btrim(coalesce(s.il, '')) <> '')           as ebelge_hazir
      from public.sube s;

comment on view public.v_ebelge_gonderici is
  'e-Belge gonderici tarafi (supplierParty) - sube kaydindan tek bicimde (165).';

-- ------------------------------------------------------------------ yetki ---
insert into public.yetki (kod, ad, grup, tur, sira)
select 'sube', 'Firma / Şube', 'yonetim', 0, 70
 where not exists (select 1 from public.yetki where kod = 'sube');

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 1
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici' and y.kod = 'sube'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'salt_okur' and y.kod = 'sube'
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

do $$
declare v_hazir boolean; v_unvan text;
begin
    select ebelge_hazir, unvan into v_hazir, v_unvan
      from public.v_ebelge_gonderici where sube_id = (select min(id) from public.sube);
    raise notice '165 tamam: firma alanlari eklendi. Varsayilan sube "%" - e-Belge bilgileri %.',
                 v_unvan, case when v_hazir then 'TAM' else 'EKSIK (adres/il/vergi dairesi girilmeli)' end;
end $$;
