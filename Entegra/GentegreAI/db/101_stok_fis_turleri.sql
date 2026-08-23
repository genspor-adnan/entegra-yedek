-- ============================================================================
--  Gentegre AI — Giriş Fişi / Çıkış Fişi (stok fişleri)
--  101_stok_fis_turleri.sql
--
--  Depo hareketi olup KARSI TARAFI OLMAYAN belgeler: fire, sarf, imha, sayim
--  farki... Irsaliye gibi calisirlar (stok oynar, miktar+birim fiyat girilir)
--  ama CARI YOKTUR. Muhasebe fisi URETIRLER (fis_mi=1): mal stoktan cikip
--  gidere / stoga girip gelire yazilir - karsiligi cari degil, sonuc hesabidir.
--
--  Turler:
--    3 = Giriş Fişi  (stoga GIRER)  - gocte zaten kullaniliyordu (8 kayit),
--                                     katalogda tanimi yoktu, simdi acildi.
--    4 = Çıkış Fişi  (stoktan CIKAR) - katalogda "Diğer Çıkış Fişi" idi,
--                                      adi sadelestirildi (3 kayit).
--
--  TIPI (belge.tipi) fisin SEBEBINI tasir - muhasebe hesabi buna gore secilecek
--  (F7, fn_belge_fisle): or. imha/fire gider, sayim fazlasi gelir.
--  UYARI: gocten gelen 11 kayitta tipi 1/17/99 gibi ESKI kodlar var; asagidaki
--  listede olmayan degerler ekranlarda "Diğer" gorunur.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- turler ----
insert into public.kasa_islem_turu
    (kod, ad, grup, yon, cari_zorunlu, kalem_turu, plan_mi, cari_ekstre,
     hesap_ekstre, bakiye_dahil, fis_mi, fis_turu, sira, aktif,
     stok_etkiler, cari_etkiler)
values (3, 'Giriş Fişi', 'belge', 1, 0, 0, 0, 0, 0, 0, 1, 1, 30, 1, 1, 0)
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, yon = excluded.yon,
       fis_mi = excluded.fis_mi, stok_etkiler = excluded.stok_etkiler,
       cari_etkiler = excluded.cari_etkiler, cari_zorunlu = excluded.cari_zorunlu;

update public.kasa_islem_turu
   set ad = 'Çıkış Fişi', yon = -1, fis_mi = 1,
       stok_etkiler = 1, cari_etkiler = 0, cari_zorunlu = 0
 where kod = 4;

-- --------------------------------------------------------- tip listeleri ----
-- Fisin sebebi. Giris ve cikis AYRI liste: ayni sebep iki tarafta olmaz
-- (sayim fazlasi yalniz girise, sarf yalniz cikisa aittir).
insert into public.kod_liste (kod, ad)
values ('belge.giris_fis_tipi', 'Giriş Fişi Tipi'),
       ('belge.cikis_fis_tipi', 'Çıkış Fişi Tipi')
on conflict (kod) do nothing;

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select kl.id, d.deger, d.ad, d.sira, 1
  from public.kod_liste kl
  join (values (1, 'Fire', 10),
               (2, 'Sayım Fazlası', 20),
               (9, 'Diğer', 90)) as d(deger, ad, sira) on true
 where kl.kod = 'belge.giris_fis_tipi'
   and not exists (select 1 from public.kod_deger k
                    where k.liste_id = kl.id and k.deger = d.deger);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select kl.id, d.deger, d.ad, d.sira, 1
  from public.kod_liste kl
  join (values (1, 'Sarf', 10),
               (2, 'İmha (Bozuk / SKT Geçmiş)', 20),
               (3, 'Kayıp', 30),
               (4, 'Fire', 40),
               (5, 'Sayım Eksiği', 50),
               (9, 'Diğer', 90)) as d(deger, ad, sira) on true
 where kl.kod = 'belge.cikis_fis_tipi'
   and not exists (select 1 from public.kod_deger k
                    where k.liste_id = kl.id and k.deger = d.deger);

do $$
declare r record; v_g integer; v_c integer;
begin
    for r in select kod, ad, stok_etkiler, cari_etkiler, fis_mi
               from public.kasa_islem_turu where kod in (3, 4) order by kod
    loop
        raise notice '101: tur % (%) stok=% cari=% fis=%',
                     r.kod, r.ad, r.stok_etkiler, r.cari_etkiler, r.fis_mi;
    end loop;
    select count(*) into v_g from public.kod_deger kd
      join public.kod_liste kl on kl.id = kd.liste_id where kl.kod = 'belge.giris_fis_tipi';
    select count(*) into v_c from public.kod_deger kd
      join public.kod_liste kl on kl.id = kd.liste_id where kl.kod = 'belge.cikis_fis_tipi';
    raise notice '101: giris tipi % adet, cikis tipi % adet', v_g, v_c;
end $$;
