-- 703: CİHAZDAN GELEN ÖLÇÜMÜN KAYNAK MESAJI.
--
-- Cihaz mesajı ayrıştırıcısı (691 şemasının eksik kalan yarısı) ölçümü hasta
-- dosyasına yazıyor. İki şey gerekiyor:
--
--   * İZ: "bu 19,5 mmHg nereden geldi" sorusunun cevabı. Ölçüm satırında
--     `kaynak = 3 (Cihaz)` yazıyor ama HANGİ mesajdan geldiği yazmıyordu;
--     sürücü yanlış ayrıştırdığında hangi satırların şüpheli olduğu
--     bulunamazdı.
--
--   * MÜKERRER KORUMASI: aynı mesaj ikinci kez işlendiğinde (sürücü
--     düzeltildi, kuyruk yeniden çalıştı) ölçüm ikinci kez yazılmamalı.
--     Benzersiz indeks bunu veritabanında garanti eder - "önce sil sonra yaz"
--     deseni, araya giren bir hata durumunda hastayı ölçümsüz bırakırdı.
--
-- GÖZ BAZLI BENZERSİZLİK: bir mesaj iki gözün ölçümünü birden taşıyor
-- ("IOP R 19.5 L 18.0"), yani mesaj başına bir değil GÖZ BAŞINA bir satır.

alter table public.goz_refraksiyon
  add column if not exists cihaz_mesaj_id bigint references public.goz_cihaz_mesaj(id);
alter table public.goz_tonometri
  add column if not exists cihaz_mesaj_id bigint references public.goz_cihaz_mesaj(id);
alter table public.goz_goruntuleme
  add column if not exists cihaz_mesaj_id bigint references public.goz_cihaz_mesaj(id);

create unique index if not exists ux_goz_refraksiyon_mesaj
  on public.goz_refraksiyon (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null;
create unique index if not exists ux_goz_tonometri_mesaj
  on public.goz_tonometri (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null;
create unique index if not exists ux_goz_goruntuleme_mesaj
  on public.goz_goruntuleme (cihaz_mesaj_id, goz) where cihaz_mesaj_id is not null;

comment on column public.goz_refraksiyon.cihaz_mesaj_id is
  'Ölçümü üreten cihaz mesajı (703). Sürücü hatasında şüpheli satırları bulmayı '
  've mesajın ikinci kez işlenmesinde mükerrer yazımı engellemeyi sağlar.';

-- İŞLENMEMİŞ MESAJ KUYRUĞU: gece işi ve "yeniden işle" düğmesi bu indeksi
--   kullanır. Sahipsiz (2) mesajlar da kuyrukta kalır - hasta sonradan
--   eşleşebilir (muayene açılır, protokol düzeltilir).
create index if not exists ix_goz_mesaj_kuyruk
  on public.goz_cihaz_mesaj (zaman) where islem_durum in (0, 2);
