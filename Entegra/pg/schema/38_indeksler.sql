-- PG migration ikincil indeksleri (migration YALNIZ PK'lari kurdu -> FK/filtre kolonlarinda
--   indeks yok -> korelasyonlu subquery'ler seq-scan. fn_prog_alissatis_irsfatfiskons_json2
--   1100ms -> 3.7ms). Idempotent. Cloud + docker ekspert'e uygulanir.
-- NOT: bu SADECE bilinen yavas sorgunun indeksleri; TAM kapsam icin MSSQL'in tum ikincil
--   indeksleri PG'ye tasinmali (ayri gorev).
CREATE INDEX IF NOT EXISTS ix_fatura_fatbasid    ON FATURA(FATBASID);
CREATE INDEX IF NOT EXISTS ix_fatura_yerid       ON FATURA(YERID);
CREATE INDEX IF NOT EXISTS ix_fatbaslik_tur_tarih ON FATBASLIK(TUR, FATURATARIH);
CREATE INDEX IF NOT EXISTS ix_isemri_yeri_yerid  ON ISEMRI(YERI, YERID);
