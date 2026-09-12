-- =====================================================================
--  585_kdv_oranlari.sql
--  Hizmet ve stok kartlarında BOŞ kalan KDV oranı doldurulur.
--
--  Kullanıcı: ücretleme arama ekranında KDV sütunu hep "%0" görünüyordu.
--  Sebep veri: kartlar SUT/SKRS katalog aktarımıyla toplu yüklendi, o
--  kaynakta KDV yok; kolon varsayılanı da 0. Elle açılan stok kartı %20 ile
--  geliyor (kart varsayılanı), toplu yüklenenler o yoldan geçmedi.
--
--  Oranlar:
--    · hizmet (muayene/tetkik/işlem)            -> %10
--    · stok, Tıbbi Malzeme / İlaç dalı altında  -> %10
--    · diğer stoklar (ticari mal, demirbaş…)    -> %20
--
--  YALNIZ KDV = 0 OLAN SATIR: müşterinin bilerek girdiği bir oran ezilmez.
--  Gerçekten %0 ile çalışan bir kalem varsa (istisna kapsamı) bu betik onu da
--  değiştirir - bu yüzden önce yedek alınır, geri dönüş tek UPDATE.
--
--  TEKRAR ÇALIŞTIRILABİLİR: ikinci çalıştırmada güncellenecek satır kalmaz.
-- =====================================================================

-- Yedek: yalnız dokunulacak satırların ESKI degeri.
create table if not exists public._yedek_kdv_585 (
    tur     text    not null,          -- 'hizmet' | 'stok'
    id      integer not null,
    kdv     smallint not null,
    primary key (tur, id)
);

insert into public._yedek_kdv_585 (tur, id, kdv)
select 'hizmet', h.id, h.kdv from public.hizmet h where coalesce(h.kdv, 0) = 0
on conflict do nothing;

insert into public._yedek_kdv_585 (tur, id, kdv)
select 'stok', s.id, s.kdv from public.stok s where coalesce(s.kdv, 0) = 0
on conflict do nothing;

-- HIZMET: sağlık hizmeti %10.
update public.hizmet set kdv = 10 where coalesce(kdv, 0) = 0;

-- STOK: tıbbi malzeme / ilaç dalı %10, gerisi %20. Dal ADLA bulunur (müşteri
--   kendi ağacını kurar), alt dallar zincirle kapsanır.
update public.stok s
   set kdv = case
                when exists (
                     select 1 from public.fn_kategori_ust_zinciri(s.kategori) z
                     join public.kategori k on k.id = z.id
                    where public.fn_ara_metin(k.ad) like '%tibbi malzeme%'
                       or public.fn_ara_metin(k.ad) like '%ilac%')
                then 10 else 20 end
 where coalesce(s.kdv, 0) = 0;
