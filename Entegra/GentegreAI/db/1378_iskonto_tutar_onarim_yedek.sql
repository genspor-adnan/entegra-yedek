-- =============================================================================
--  1378 - İSKONTO TUTAR ONARIMI: YEDEK TABLOSU
--
--  1377'ye kadar iskonto kararı (dijital zincir / sözlü onay) satıra yalnız ORANI yazıyordu; tutar, ödeme dağılımı
--  ve belgenin dip toplamı kart yeniden kaydedilene kadar eski kaldı. Onarım para hesabının tek kaynağını
--  (BelgeHesap.SatirTutari) kullanmak zorunda olduğu için SQL'de değil API açılışında çalışır
--  (Servisler/IskontoTutarOnarici): yalnız tutarı hesapla tutmayan, onaylı (durum 1) ve KİLİTLİ satırlara dokunur,
--  belgeye dönüşmüş satırı ATLAR (o tutarla belge kesilmiş - elle karar), iptal belgeye dokunmaz.
--
--  Bu tablo dokunulan her satırın ÖNCEKİ hâlini tutar (geri dönüş ve denetim için). Betik idempotent.
-- =============================================================================

create table if not exists public._yedek_iskonto_tutar_1378 (
    id               bigserial primary key,
    tarih            timestamptz not null default now(),
    talep_id         integer not null,
    belge_id         integer not null,
    belge_satir_id   integer not null,
    eski_tutar       numeric,
    eski_tutar_kdvli numeric,
    eski_doviz_tutari numeric,
    eski_dagilim     jsonb,
    eski_genel_toplam numeric
);

comment on table public._yedek_iskonto_tutar_1378 is
  '1378: IskontoTutarOnarici dokunmadan önceki satır / dağılım / dip toplam (iskonto kararı tutarı yenilemiyordu)';
