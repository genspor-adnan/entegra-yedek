-- =====================================================================
--  721_ameliyat_belge_satir_fk.sql
--  AMELİYATIN ÜCRET SATIRI BAĞLARINA GERÇEK YABANCI ANAHTAR.
--
--  720 `ameliyat_islem.belge_satir_id` ve `ameliyat_sarf.belge_satir_id`
--  kolonlarını FK'SIZ açmıştı. Yanlıştı ve testi (KorunanSatirTestleri) de
--  atlatıyordu - tam da test etmesi gereken hatayı:
--
--    Belge kaydetme satırları SİLER ve YENİDEN YAZAR. FK yokken silme
--    sorunsuz geçer, bizim `belge_satir_id` değerimiz yok olmuş bir satırı
--    göstermeye devam eder. Sonuç sessizdir ve daha kötüdür: "bu işlem
--    faturalandı" diyen bağ artık hiçbir şeye bakmıyordur, tekrar faturalama
--    da kalemi "zaten aktarılmış" sayıp atlar - ameliyatın ücreti belgeden
--    düşer ve kimse fark etmez.
--
--  FK + `KorunanSatirSql` birlikte doğru davranışı verir: satır silinmez,
--  yerinde kalır, bağ geçerli kalır (radyoloji isteminde olduğu gibi).
--
--  NO ACTION (varsayılan) BİLEREK: CASCADE olsaydı, belge satırı silindiğinde
--    ameliyatın işlem satırı da silinirdi - klinik kayıt, faturanın yan etkisi
--    olarak yok olamaz. SET NULL da yanlış: "faturalandı" bilgisi sessizce
--    kaybolurdu. Doğru yanıt satırı hiç sildirmemektir.
-- =====================================================================

do $fk$
begin
    if not exists (select 1 from pg_constraint
                    where conname = 'ameliyat_islem_belge_satir_id_fkey') then
        alter table public.ameliyat_islem
          add constraint ameliyat_islem_belge_satir_id_fkey
          foreign key (belge_satir_id) references public.belge_satir(id);
    end if;

    if not exists (select 1 from pg_constraint
                    where conname = 'ameliyat_sarf_belge_satir_id_fkey') then
        alter table public.ameliyat_sarf
          add constraint ameliyat_sarf_belge_satir_id_fkey
          foreign key (belge_satir_id) references public.belge_satir(id);
    end if;
end $fk$;

-- Korunan satır sorgusu bu tabloları arayacak: aramanın ucuz olması için
--   indeks. Kısmi - sorgu yalnız DOLU değerleri arıyor.
create index if not exists ix_ameliyat_islem_belge_satir
  on public.ameliyat_islem (belge_satir_id) where belge_satir_id is not null;
create index if not exists ix_ameliyat_sarf_belge_satir
  on public.ameliyat_sarf (belge_satir_id) where belge_satir_id is not null;
