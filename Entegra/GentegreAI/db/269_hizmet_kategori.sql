-- 269: HİZMETE KATEGORİ + kurum sözleşmesinde iskonto kalktı (kullanıcı:
-- "hem stok hem de hizmet kalemleri için kategori istiyorum ve bu kampanyada
-- da kullanılacak", "kurum kartta artık iskontoya gerek yok kaldır").
--
-- Kategori tablosu ORTAK: stok `stok.kategori` ile bağlıydı, hizmet hiç
-- bağlanmamıştı (eski `hizmet.grubu` kolonu tamamen boş). Kampanya satırı
-- "şu kategoriden %20" derken hizmetleri de kapsayabilsin diye hizmet de aynı
-- ağaca bağlanıyor - ikinci bir kategori tablosu açmak, aynı ağacı iki kez
-- yönetmek olurdu.

alter table public.hizmet add column if not exists kategori integer
  references public.kategori(id);
comment on column public.hizmet.kategori is
  'Hizmetin kategorisi (269) - stokla ORTAK kategori ağacı; kampanya satırı ikisini de süzer.';

create index if not exists ix_hizmet_kategori on public.hizmet (kategori)
  where kategori is not null;

-- Kurumun genel iskontosu KALKTI: indirim artık kampanya satırlarında.
alter table public.taraf_kurum drop column if exists iskonto_yuzde;
