-- ============================================================================
--  Gentegre AI — LAB İSTEMİNDEN AÇILAN ÜCRET SATIRLARININ ONARIMI
--  680_lab_istem_satir_onarim.sql
--
--  Kullanıcı: "başvuru 3990 da ücreti tıklayıp fiyat ekranı açtım ama birim
--  fiyat boş geldi… lab istemden yapılan kayıtta sorunlar var."
--
--  Dış kurum / lab istemi akışı `belge_satir`'a yalnız MATRAHI yazıyordu:
--  `birim_fiyat_kdvli`, `doviz_birim_fiyat`, `doviz_tutari` ve `teslim_tarihi`
--  boş kalıyordu. Kart yolundan yazılan satırda hepsi dolu - aynı satır iki
--  yoldan iki türlü doğuyordu. Ekranda sonucu: kalem penceresi fiyatı 0
--  okuyor (döviz fiyatı 0'dı), grid tarihi "—" gösteriyordu.
--
--  Kodu düzeltmek YENİ satırları kurtarır; bu betik ESKİLERİ onarır.
--  Yalnız KANITLANABİLİR biçimde eksik olanlara dokunur: brüt/döviz alanı 0
--  ama matrah > 0 olan satırlar. Dolu bir değeri asla ezmez.
-- ============================================================================
\set ON_ERROR_STOP on

update public.belge_satir s
   set birim_fiyat_kdvli = round(s.birim_fiyat * (1 + coalesce(s.kdv, 0) / 100.0), 4)
 where coalesce(s.birim_fiyat_kdvli, 0) = 0
   and s.birim_fiyat > 0;

update public.belge_satir s
   set doviz_birim_fiyat = s.birim_fiyat,
       doviz_tutari = s.tutar,
       doviz_kuru = case when coalesce(s.doviz_kuru, 0) > 0 then s.doviz_kuru else 1 end,
       doviz_cinsi = case when coalesce(nullif(s.doviz_cinsi, ''), '') = ''
                          then 'TL' else s.doviz_cinsi end
 where coalesce(s.doviz_birim_fiyat, 0) = 0
   and s.birim_fiyat > 0;

-- İşlem tarihi: satırın kendi eklenme zamanı (belgenin tarihi değil - kalem
--   gün içinde eklenmiş olabilir ve grid o saati gösteriyor).
update public.belge_satir s
   set teslim_tarihi = s.ekleme_tarihi
 where s.teslim_tarihi is null
   and s.tur = 2
   and exists (select 1 from public.belge b
                where b.id = s.belge_id and b.tur = 19 and b.tipi = 30);

do $$
begin
    raise notice '680 tamam: eksik brut/doviz/tarih alanlari dolduruldu.';
end $$;
