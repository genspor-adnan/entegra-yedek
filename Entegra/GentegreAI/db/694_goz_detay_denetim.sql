-- 694: GÖZ DETAY TABLOLARINA DENETİM KOLONLARI (ekleyen / degistiren).
--
-- 691 bu tabloları "ölçüm satırı, denetim kolonu gerekmez" diye açmıştı. Yanlış
-- çıktı: kart detay yazıcısı (KartDeposu.Detay) HER detay satırına `ekleyen`,
-- her güncellemeye `degistiren` yazar — platformun sözleşmesi bu ve tek bir
-- kart için esnetilecek bir şey değil. Kolonlar olmayınca ölçüm sekmeleri
-- KAYDEDİLEMİYORDU:
--
--     42703: column "ekleyen" of relation "goz_gorme" does not exist
--
-- Hata ancak ilk gerçek yazma denemesinde ortaya çıktı: okuma ve liste yolları
-- bu kolonlara dokunmuyor, kart açılıyor, ölçümler görünüyordu.
--
-- Denetim kolonu ayrıca KLİNİK bir gerekliliktir: "bu GİB ölçümünü kim girdi,
-- sonra kim değiştirdi" sorusunun cevabı hasta dosyasında durmalı. Ölçüm
-- satırının kaynağı (`kaynak` = hekim/tekniker/cihaz) NE ölçtüğünü söyler,
-- `ekleyen` ise KİMİN kaydettiğini - ikisi farklı sorulardır.

do $$
declare
  t text;
begin
  foreach t in array array[
      -- goz_muayene detayları (ölçümler)
      'goz_gorme', 'goz_refraksiyon', 'goz_tonometri', 'goz_on_segment',
      'goz_fundus', 'goz_motilite', 'goz_ek_test',
      -- goz_goruntuleme detayları
      'goz_goruntuleme_olcum', 'goz_biyometri',
      -- goz_islem detayları
      'goz_enjeksiyon', 'goz_lazer', 'goz_ameliyat', 'goz_ameliyat_kontrol',
      'goz_islem_malzeme',
      -- kart olarak da açılabilen ikincil tablolar
      'goz_islem_protokol', 'goz_ziyaret_istasyon', 'goz_cihaz_mesaj'
    ]
  loop
    execute format(
      'alter table public.%I
         add column if not exists ekleyen integer not null default 0,
         add column if not exists ekleme_tarihi timestamptz not null default now(),
         add column if not exists degistiren integer not null default 0,
         add column if not exists degistirme_tarihi timestamptz', t);
  end loop;
end $$;

-- Kontakt lens kartında `degistiren` eksikti (691'de yalnız `ekleyen` vardı):
--   reçete düzeltilebilir bir kayıttır, kimin düzelttiği kalmalı.
alter table public.goz_kontakt_lens
  add column if not exists degistiren integer not null default 0,
  add column if not exists degistirme_tarihi timestamptz;

comment on column public.goz_gorme.ekleyen is
  'Ölçümü KAYDEDEN kullanıcı (694). `kaynak` kolonu ölçümü KİMİN/NEYİN aldığını '
  'söyler (hekim/tekniker/cihaz); ikisi ayrı sorudur.';
