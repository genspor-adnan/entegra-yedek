-- =====================================================================
--  627_muayene_cikis_sekli.sql
--  ÇIKIŞ ŞEKLİ MUAYENENİN ALANI OLDU.
--
--  USS 106'da `CIKIS_SEKLI` ZORUNLU: yazılmayınca "E1014 ... eksik
--  elemanlar var: CIKIS_SEKLI" ile paket reddediliyor (canlı deneme,
--  paket 652). Alan SKRS kodlu olduğu için kodsuz da yazılamaz - yani
--  gerçek bir değer üretmek gerekiyor, boş geçmek seçenek değil.
--
--  Yerelde kaynak kolon yoktu; "yatış/taburcu modülü gelince" diye
--  bekletiliyordu. Oysa AYAKTA muayenenin de bir çıkışı var: hasta
--  muayene bitince ya evine gider ya sevk edilir. Karar HEKİMİNDİR ve
--  muayene kaydına aittir.
--
--  VARSAYILAN 7 (İYİLEŞEREK ÇIKIŞ/TABURCU): poliklinik muayenesinin
--  olağan sonu. Sevk, ölüm, tedaviyi reddetme gibi haller istisnadır ve
--  hekim muayene kartından seçer. Varsayılanı boş bırakmak, her muayeneyi
--  gönderilemez yapardı; "DİĞER" (98) seçmek ise bilgi taşımayan bir kod
--  göndermek olurdu.
-- =====================================================================

alter table public.muayene
  add column if not exists cikis_sekli smallint not null default 7;

comment on column public.muayene.cikis_sekli is
  '627: SKRS CIKIS SEKLI (kod_deger[cikis.sekli]). USS 106 CIKIS_SEKLI '
  'alani - zorunlu. Varsayilan 7 (iyilesderek cikis/taburcu).';

-- Tamamlanmış muayeneler de bildirilebilsin: hepsi olağan çıkışla kapandı.
update public.muayene set cikis_sekli = 7 where cikis_sekli = 0;

do $$
begin
    raise notice '627 tamam: % muayenede cikis sekli',
        (select count(*) from public.muayene where cikis_sekli <> 0);
end $$;
