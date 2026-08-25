-- ============================================================================
--  Gentegre AI — BARKODLAR AMBALAJ BIRIMLERINE TASINIYOR
--  144_barkod_birime_tasi.sql
--
--  Kullanici: "ambalaj birimleri yeterli, ayrica birim/barkod'a gerek yok."
--
--  Iki yapi ayni seyi anlatiyordu: `stok_barkod` (barkod + barkod_birimi) ve
--  143'te gelen `stok_birim` (birim + carpan + barkod). Barkod zaten BIRIME
--  aittir - "1 kutunun barkodu" ile "1 adedin barkodu" farklidir - dolayisiyla
--  dogru yeri birim satiridir. Iki listeyi ayri tutmak, ayni birimin iki farkli
--  yerde barkodlanmasina ve hangisinin dogru oldugunun bilinmemesine yol acardi.
--
--  VERI SILINMEZ: `stok_barkod` tablosu oldugu gibi duruyor (1419 satir), yalniz
--  KARTTAN kalkiyor. Buradaki is, barkodlari birim satirlarina KOPYALAMAK.
--
--  Carpan bilinmiyor: eski kayitta yalnizca "hangi birim" yaziyordu, "kac ana
--  birim eder" yazmiyordu. Yeni acilan satirlara 1 yazilir ve aciklamaya
--  "144 goc" notu dusulur - kullanici gercek ambalaji (1 kutu = 12) kartta
--  duzeltir. 1 yazmak, sessizce yanlis bir carpan uydurmaktan iyidir: 1 zaten
--  "cevrim yok" demektir, eski davranisin aynisi.
-- ============================================================================
\set ON_ERROR_STOP on

begin;

-- 1) Birim satiri VARSA ve barkodu bossa doldur.
update public.stok_birim sb
   set barkod = b.barkod
  from public.stok_barkod b
 where b.stok_id = sb.stok_id
   and b.barkod_birimi = sb.birim
   and coalesce(btrim(sb.barkod), '') = ''
   and coalesce(btrim(b.barkod), '')  <> '';

-- 2) Birim satiri YOKSA ac (carpan 1 - bkz. baslik notu).
insert into public.stok_birim (stok_id, birim, carpan, barkod, aciklama, ekleyen)
select b.stok_id, b.barkod_birimi, 1, btrim(b.barkod), '144 göç: barkod', 0
  from public.stok_barkod b
 where coalesce(btrim(b.barkod), '') <> ''
   and b.barkod_birimi is not null
   and not exists (select 1 from public.stok_birim sb
                    where sb.stok_id = b.stok_id and sb.birim = b.barkod_birimi)
on conflict (stok_id, birim) do nothing;

commit;

do $$
declare v_barkod integer; v_birim integer; v_tasinan integer;
begin
    select count(*) into v_barkod from public.stok_barkod where btrim(barkod) <> '';
    select count(*) into v_birim  from public.stok_birim;
    select count(*) into v_tasinan from public.stok_birim where btrim(barkod) <> '';
    raise notice '144 tamam: % barkod kaydi, % birim satiri (% tanesi barkodlu). stok_barkod SILINMEDI.',
                 v_barkod, v_birim, v_tasinan;
end $$;
