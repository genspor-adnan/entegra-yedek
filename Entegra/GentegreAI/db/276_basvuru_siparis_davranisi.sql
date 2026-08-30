-- 276: BAŞVURU = SATIŞ SİPARİŞİ (kullanıcı: "başvuru belge türünü satış
-- siparişi türü ile aynı yap; başvurudaki işlemler normal alınan
-- siparişlerimizdir").
--
-- İstemci başvuruyu (tür 30) zaten sipariş gibi çiziyordu (belgeTuru.ts
-- SIPARIS_TURLERI = 9, 19, 30) ama TÜR TANIMI sipariş değildi: cari_etkiler,
-- fis_mi, cari/hesap ekstre ve bakiye_dahil AÇIKTI. Sonuç: hasta daha hizmeti
-- almadan başvuru cari bakiyeye giriyor, ekstrede görünüyor ve muhasebe fişi
-- üretiyordu. Sipariş bir TAAHHÜTTÜR; mali hareket faturada doğar.
--
-- Tanım 19'dan (Satış Siparişi) KOPYALANIR - ileride sipariş davranışı
-- değişirse ikisi ayrışmasın diye tek tek değer yazmak yerine satır kopyası.

do $$
declare
  v_etki integer;
begin
  update public.kasa_islem_turu h
     set yon              = s.yon,
         grup             = s.grup,
         ana_hesap_turu   = s.ana_hesap_turu,
         karsi_hesap_turu = s.karsi_hesap_turu,
         cari_zorunlu     = s.cari_zorunlu,
         kalem_turu       = s.kalem_turu,
         plan_mi          = s.plan_mi,
         cari_ekstre      = s.cari_ekstre,
         hesap_ekstre     = s.hesap_ekstre,
         bakiye_dahil     = s.bakiye_dahil,
         fis_mi           = s.fis_mi,
         fis_turu         = s.fis_turu,
         stok_etkiler     = s.stok_etkiler,
         cari_etkiler     = s.cari_etkiler,
         makbuz_seri      = s.makbuz_seri,
         sira             = s.sira + 1          -- siparişin hemen ardında
    from public.kasa_islem_turu s
   where h.kod = 30 and s.kod = 19;
  get diagnostics v_etki = row_count;
  raise notice '276: tur 30 (Başvuru) satış siparişi davranışına alındı (% satır).', v_etki;
end $$;

-- --------------------------------------------------- geçmişin temizlenmesi --
-- Eski tanımla üretilmiş mali hareketler ve muhasebe fişleri KALIRSA cari
-- bakiye ve mizan yanlış durur. Silmeden önce YEDEKLENİR: müşteri veritabanında
-- da çalışacak bir betikte geri dönüşü olmayan silme yapılmaz.

create table if not exists public.mali_hareket_yedek_276 as
select * from public.mali_hareket where tur = 30;

create table if not exists public.belge_fis_yedek_276 as
select id as belge_id, muhasebe_fis_id
  from public.belge
 where tur = 30 and coalesce(muhasebe_fis_id, 0) <> 0;

do $$
declare
  v_mh integer := 0;
  v_fis integer := 0;
begin
  delete from public.mali_hareket where tur = 30;
  get diagnostics v_mh = row_count;

  -- Başvurudan doğmuş muhasebe fişleri: önce belgenin bağı koparılır, sonra
  --   fiş ve satırları silinir (satırlar cascade değilse elle).
  create temporary table _fis_276 on commit drop as
  select distinct muhasebe_fis_id as id
    from public.belge
   where tur = 30 and coalesce(muhasebe_fis_id, 0) <> 0;

  update public.belge set muhasebe_fis_id = null where tur = 30;

  delete from public.muhasebe_fis_satir where fis_id in (select id from _fis_276);
  delete from public.muhasebe_fis      where id     in (select id from _fis_276);
  get diagnostics v_fis = row_count;

  raise notice '276: % mali hareket, % muhasebe fişi temizlendi (yedekler: mali_hareket_yedek_276 / belge_fis_yedek_276).',
               v_mh, v_fis;
end $$;
