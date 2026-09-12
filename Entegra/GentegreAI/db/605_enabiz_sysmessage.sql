-- =====================================================================
--  605_enabiz_sysmessage.sql
--  e-NABIZ PAKETI GERÇEK USS ŞEMASINA HAZIRLANIYOR.
--
--  Gönderim gövdesi bugüne kadar yer tutucuydu (`GonderimPaketi`/`Alanlar`).
--  Gerçek şema rehber.enabiz.gov.tr'den çıkarıldı - dokuman/09_ENABIZ_USS_SEMASI.md.
--  USS gövdesinin bizim tablolarda karşılığı olmayan üç özelliği var:
--
--  1. HİYERARŞİ. Alanlar düz değil, veri seti/grup içinde yaşıyor:
--         recordData > HASTA_KIMLIK_BILGILERI > ADRES_BILGISI > ACIK_ADRES
--     `uss_alan` artık YOL taşır, "/" ile ayrılmış:
--         'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES'
--     Yol kolonun kendisinde durur; ayrı bir düzey tablosu açmak, tek bir
--     paket şemasını iki yerden okumak demekti.
--
--  2. SKRS KODLARI. Kimi alanlar düz değer değil, kodlanmış değer taşır:
--         <CINSIYET version="1" codeSystemGuid="784d..." code="E" value="Erkek" />
--     Bunun için iki kolon eklendi. `skrs_sistem` boşsa alan düz yazılır
--     (`<AD value="..." />`), doluysa kod öznitelikleri de eklenir.
--
--  3. SİLME PAKETİ. 101'in iptali ayrı bir pakettir: 301 Hasta Kayıt Silme.
--     Tek alanı, 101 yanıtında dönen SYSTakipNo'dur. O numarayı saklamak için
--     `enabiz_paket.sys_takip_no` açıldı - `uss_paket_id` alanı gönderim
--     yanıtının ham kimliği için duruyor, takip numarası ise İŞ anahtarıdır:
--     sonraki bütün paketler (103 muayene, 106 çıkış, 301 silme) onu taşır.
-- =====================================================================

-- ------------------------------------------------------- 1) SKRS kodları ----
alter table public.enabiz_paket_alan
  add column if not exists skrs_kod    varchar(30)  not null default '',
  add column if not exists skrs_sistem varchar(60)  not null default '',
  add column if not exists skrs_surum  varchar(10)  not null default '1';

comment on column public.enabiz_paket_alan.skrs_sistem is
  'SKRS codeSystemGuid - DOLUYSA alan kodlanmis yazilir (code/value/version), '
  'bossa duz deger (605).';

-- --------------------------------------------------------- 2) takip no ----
alter table public.enabiz_paket
  add column if not exists sys_takip_no varchar(64) not null default '';

comment on column public.enabiz_paket.sys_takip_no is
  '101 yanitinda donen SYSTakipNo (605). Sonraki paketler ve 301 silme bunu '
  'kullanir; basvuruyla birlikte saklanmasi USS kilavuzunun sarti.';

create index if not exists ix_enabiz_paket_takip
    on public.enabiz_paket (sys_takip_no) where sys_takip_no <> '';

-- --------------------------------------------------- 3) 301 silme paketi ----
-- Kaynak türü 101 ile AYNI (basvuru): silme de basvuruya ait bir islemdir.
insert into public.enabiz_paket_turu (kod, ad, uss_paket_kodu, uss_surum, aktif)
select 'HASTA_KABUL_SIL', 'Hasta Kayıt Silme', '301', '2.2', 1
 where not exists (select 1 from public.enabiz_paket_turu where uss_paket_kodu = '301');

do $$
begin
    raise notice '605 tamam: skrs kolonlari, sys_takip_no, 301 turu (% adet tur)',
        (select count(*) from public.enabiz_paket_turu);
end $$;
