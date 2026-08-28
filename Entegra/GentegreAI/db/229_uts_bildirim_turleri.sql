-- ============================================================================
--  Gentegre AI — ÜTS EK BİLDİRİM TÜRLERİ
--  229_uts_bildirim_turleri.sql
--
--  Üretim / İthalat / Kayıp-HEK / İmha-Bertaraf bildirimleri (kullanıcı):
--  tür kod listesine 4 değer. Servis yolları koda gömülü (UtsServisi.Turler);
--  alan sözleşmeleri PDF s24 (üretim), s27 (ithalat), s74 (hekZayiat TUR
--  seçenekleri), s83 (imha GRK seçenekleri + zorunlu belge no).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.deger * 10, 1
  from (values (4, 'Üretim'), (5, 'İthalat'),
               (6, 'Kayıp / HEK'), (7, 'İmha / Bertaraf')) v(deger, ad)
  join public.kod_liste l on l.kod = 'uts.bildirim_tur'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

do $$ begin
    raise notice '229 tamam: uts.bildirim_tur += Uretim/Ithalat/HEK/Imha.';
end $$;
