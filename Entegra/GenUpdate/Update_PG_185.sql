-- #pg
-- ============================================================
-- Update_PG_185.sql   (PostgreSQL)
-- Ihracat fatura geneli navlun/sigorta alanlari
-- ============================================================

CREATE TABLE IF NOT EXISTS fatbaslik_user(
    id int not null primary key references fatbaslik(id),
    sevkbilgisi text null,
    ekleyen int null,
    eklemetarihi timestamp null default now(),
    degistiren int null,
    degistirmetarihi timestamp null
);

ALTER TABLE fatbaslik_user
    ADD COLUMN IF NOT EXISTS navlun_tutari numeric(18,4),
    ADD COLUMN IF NOT EXISTS sigorta_tutari numeric(18,4);

DO $$
BEGIN
    RAISE NOTICE 'Update_PG_185: navlun/sigorta kolonlari hazirlandi; MSSQL eski satir JSON backfill PG pilotta uygulanmadi.';
END $$;
