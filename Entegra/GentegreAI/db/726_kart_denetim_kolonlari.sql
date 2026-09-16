-- =====================================================================
--  726_kart_denetim_kolonlari.sql
--  722/723/724 tablolarına generic KART çerçevesinin beklediği denetim
--  kolonları: `ekleyen` · `degistiren` (+ eksik olan `ekleme_tarihi` /
--  `degistirme_tarihi`).
--
--  NEDEN GEREKLİ — ŞEMA HATASI DEĞİL, SÖZLEŞME EKSİĞİ. Kart deposu her
--    insert'e `ekleyen`, her update'e `degistiren` yazar
--    (`KartDeposu.cs` / `KartDeposu.Detay.cs`): kolon yoksa kart
--    kaydedilemez - test sırasında
--    `42703: column "ekleyen" of relation "eczane_imha_satir" does not exist`
--    ile düştü. 722-724 yazılırken bu tablolara UÇTAN yazılacağı varsayılmış,
--    sonradan generic karta bağlandılar.
--
--  DETAY SATIRI DA DENETLENİR. "Bu imha satırını kim ekledi", "bu ölçümü kim
--    değiştirdi" - imha tutanağında ve kalibrasyon ölçümünde bunlar üst
--    kaydın değil SATIRIN sorusudur. Üst kayıttaki `ekleyen` yanıtlamaz:
--    tutanağı açan ile satırı ekleyen aynı kişi olmayabilir.
--
--  VARSAYILAN 0, NOT NULL: mevcut satırlar "bilinmiyor" (0) olur. NULL
--    bırakmak, sonradan her okumada üç durumlu (kim / bilinmiyor / yok)
--    bir alan üretirdi.
-- =====================================================================

do $$
declare
  -- Kart ya da kart DETAYI olarak generic çerçeveden yazılan tablolar.
  t text;
  tablolar text[] := array[
    -- Eczane (722)
    'eczane_doz', 'eczane_iade', 'eczane_hazirlama_kalem', 'eczane_imha_satir',
    'kontrollu_sayim', 'kontrollu_sayim_satir',
    -- Biyomedikal (723)
    'demirbas_belge', 'demirbas_kalibrasyon_olcum',
    'demirbas_is_emri_madde', 'demirbas_is_emri_parca',
    -- Satınalma (724)
    'satinalma_talep_satir', 'satinalma_onay', 'satinalma_kabul',
    'satinalma_teklif_kriter', 'satinalma_teklif_firma', 'satinalma_teklif_yanit',
    'tedarikci_sozlesme_fiyat', 'tedarikci_olay'
  ];
begin
  foreach t in array tablolar loop
    execute format('alter table public.%I add column if not exists ekleyen integer not null default 0', t);
    execute format('alter table public.%I add column if not exists degistiren integer not null default 0', t);
    execute format('alter table public.%I add column if not exists ekleme_tarihi timestamptz not null default now()', t);
    -- DEĞİŞTİRME TARİHİ NULL OLABİLİR: "hiç değiştirilmedi" ile "şimdi
    --   değiştirildi" aynı şey değil; default koysaydık her satır
    --   doğduğu anda değiştirilmiş görünürdü.
    execute format('alter table public.%I add column if not exists degistirme_tarihi timestamptz', t);
  end loop;
end $$;

-- Üst kayıtları da tamamla: bunlar zaten `ekleyen` taşıyordu, eksikleri
--   `degistiren` / `degistirme_tarihi` idi (kart GÜNCELLEMESİ için şart).
alter table public.eczane_doz               add column if not exists degistirme_tarihi timestamptz;
alter table public.eczane_iade              add column if not exists degistirme_tarihi timestamptz;
alter table public.kontrollu_sayim          add column if not exists degistirme_tarihi timestamptz;
alter table public.satinalma_kabul          add column if not exists degistirme_tarihi timestamptz;
alter table public.tedarikci_olay           add column if not exists degistirme_tarihi timestamptz;

-- KONTROLLÜ DEFTER ve FATURA KONTROL kart DEĞİL (defter satırı silinemez,
--   fatura kontrolü uçtan işlenir) ama ileride bir uç `degistiren` yazmak
--   isterse kolon dursun - denetim defterinde eksik alan, sonradan
--   eklenemeyen bir alandır.
alter table public.kontrollu_defter         add column if not exists degistiren integer not null default 0;
alter table public.kontrollu_defter         add column if not exists degistirme_tarihi timestamptz;
alter table public.satinalma_fatura_kontrol add column if not exists degistiren integer not null default 0;
alter table public.satinalma_fatura_kontrol add column if not exists degistirme_tarihi timestamptz;
alter table public.tedarikci_belge          add column if not exists degistiren integer not null default 0;
alter table public.tedarikci_belge          add column if not exists degistirme_tarihi timestamptz;
alter table public.demirbas_hareket         add column if not exists ekleme_tarihi timestamptz not null default now();
