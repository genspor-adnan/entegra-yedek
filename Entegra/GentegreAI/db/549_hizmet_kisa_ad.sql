-- =====================================================================
--  549_hizmet_kisa_ad.sql
--  HİZMETE KISA AD: listede Ad'ın solunda, aramada ÖNCELİKLİ alan.
--
--  Kullanıcı: "hizmetler listesinde ad'ın soluna Kısa Ad ekle, aramada
--  öncelik ona olsun; başvuruda ücretlemede stok/hizmet ara listesinde de
--  görünecek ve aranacak."
--
--  NEDEN: katalog SKRS'den kurulduğu için hizmet adları resmî ve uzun
--  ("COXİELLA BURNETİİ (Q FEVER) IFA FAZ I+FAZ II IGG"). Ücretleme ekranında
--  kalem arayan görevli bu adı yazmıyor - kurumda o tetkiğin bilinen kısa adı
--  ne ise onu yazıyor. Kısa ad, resmî adın YERİNE GEÇMEZ: fatura, rapor ve
--  e-Nabız hâlâ `ad` kolonunu kullanır.
--
--  BOŞ BAŞLAR: kısa ad zorunlu değil, kurum doldurdukça anlam kazanır.
--  Boş kısa ad aramayı bozmaz - arama her iki alana birden bakar.
-- =====================================================================

alter table public.hizmet
    add column if not exists kisa_ad varchar(60) not null default '';

comment on column public.hizmet.kisa_ad is
  'Kurumun gunluk dilde kullandigi kisa ad (549). Resmi ad `ad` kolonunda '
  'kalir; kisa ad yalniz arama ve ekran kolaylığı icindir.';

-- ARAMA INDEKSI: 027'deki desenin aynısı - `fn_ara_metin` üzerinden trigram.
--   Arama bu ifadeyle gittiği için düz bir b-tree indeksi kullanılmazdı.
create index if not exists ix_hizmet_kisa_ad_trgm
    on public.hizmet using gin (public.fn_ara_metin(kisa_ad) gin_trgm_ops);
