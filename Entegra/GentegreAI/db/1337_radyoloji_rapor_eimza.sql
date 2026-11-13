-- 1337 - Radyoloji raporu e-İMZA (kullanıcı 13.11.2026: "radyoloji raporlarını e-imza ile imzalamak gerekiyor",
--   "eimza çipi doktorun bilgisayarına da takılıp imzalanabilir veya serverda sabit usb de takılı da olabilir",
--   "medula için xades xml enveloping imzalama yapıyoruz.. imzalama aracı bunu yapıyor zaten").
--
-- İMZA ARACI: GenSigner (Sign-Server, Quarkus; depoda Entegra/Sign-Server) - PKCS#11 akıllı kart, XAdES-BASELINE-B
--   ENVELOPING (DSS). Girdi: belge base64 + mimeType; çıktı: imzalı XML (belgenin aslı base64 olarak içinde).
--   İki kip (entegrasyon_hesap kod EIMZA, ayarlar.kip):
--     'istemci' : kart hekimin bilgisayarında, GenSigner orada (http://localhost:51919); tarayıcı imzalatır, API'ye
--                 imzalı XML gelir. PIN sunucuya hiç gelmez.
--     'sunucu'  : kart sunucuda (sabit USB), GenSigner sunucuda; hekim PIN'i girer, API GenSigner'a iletir, PIN
--                 saklanmaz. url = GenSigner adresi, sifre = X-Api-Key.
--
-- İMZALANAN BELGE: raporun ÇIKTI HTML'i (RadyolojiRaporBelgesi, stil gömülü; Teletıp ORU da aynı HTML'i taşır,
--   1334). İmzalı XML merkezi doküman deposuna (dokuman kaynak 'radyoloji-rapor', kaynak_id rapor) yazılır; rapor
--   satırı imza zamanı / imzalayan / sertifika / belge özetini taşır. İmza ONAYLA adımının parçasıdır: imza gelince
--   rapor onaylanır ve kilitlenir; EIMZA hesabı aktifken imzasız onay yoktur.
\set ON_ERROR_STOP on
begin;

alter table public.radyoloji_rapor
    add column if not exists imza_zamani     timestamptz,
    add column if not exists imzalayan_id    integer,
    add column if not exists imza_sertifika  varchar(200),
    add column if not exists imza_dokuman_id integer,
    add column if not exists imza_ozet       varchar(64);
comment on column public.radyoloji_rapor.imza_zamani     is '1337: e-imza zamanı (XAdES enveloping, GenSigner)';
comment on column public.radyoloji_rapor.imzalayan_id    is '1337: imzayı atan kullanıcı (taraf_kullanici)';
comment on column public.radyoloji_rapor.imza_sertifika  is '1337: sertifika CN + seri (kartın kimliği)';
comment on column public.radyoloji_rapor.imza_dokuman_id is '1337: imzalı XML (dokuman, kaynak radyoloji-rapor)';
comment on column public.radyoloji_rapor.imza_ozet       is '1337: imzalanan HTML''in sha256 (hex) - sonradan karşılaştırma';

-- Entegrasyon seçim listesi: 337'nin aynısı + e-İmza.
create or replace view public.v_entegrasyon_kod_lookup as
    select v.id, v.ad, 1 as aktif, v.sira
      from (values ('EBELGE', 'e-Fatura / e-Belge Entegratörü', 1),
                   ('UTS',    'ÜTS (Ürün Takip Sistemi)',       2),
                   ('SKRS',   'SKRS / Sağlık.NET Kod Sunucusu', 3),
                   ('ENABIZ', 'e-Nabız',                        4),
                   ('MEDULA', 'MEDULA (SGK)',                   5),
                   ('SMS',    'SMS Sağlayıcı',                  6),
                   ('EIMZA',  'e-İmza (GenSigner)',             7)) v(id, ad, sira)
     order by v.sira;
comment on view public.v_entegrasyon_kod_lookup is
  'Entegrasyon secim listesi (336/337, 1337 EIMZA) - kodlar METIN; sira: e-Fatura en ustte.';

commit;
