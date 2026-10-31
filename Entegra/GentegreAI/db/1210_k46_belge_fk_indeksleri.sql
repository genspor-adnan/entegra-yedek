\set ON_ERROR_STOP on
-- ============================================================================
--  1210 — K46/K47: belge ve belge_satir'a bakan FK kolonlarına indeks
--
--  1209 ölçümü: 500 satırlık DELETE'in kalan 145 ms'si belge_satir'ı referans
--  eden 39 alt tablonun FK denetimi (her biri alt tabloyu tam tarıyor;
--  dev DB'de küçük, canlıda büyür). 1208 yalnız dev'de satırı olan FK'ları
--  aldı; burada belge(id) / belge_satir(id)'yi gösteren tüm indekssiz FK
--  kolonları - başvuru silme / satır silme / belge birleştirme hepsini
--  denetler. Tablo bu kurulumda yoksa atlanır; yeniden koşulabilir.
-- ============================================================================
begin;

do $$
declare
    r record;
begin
    for r in
        select * from (values
        ('acil_basvuru', 'belge_id'),
        ('ameliyat', 'belge_id'),
        ('ameliyat_sarf', 'cikis_belge_id'),
        ('bzbh_bildirim', 'belge_id'),
        ('cocuk_izlem', 'belge_id'),
        ('demirbas_is_emri_parca', 'belge_id'),
        ('dis_lab_isemri', 'alis_belge_satir_id'),
        ('dis_seans', 'belge_id'),
        ('dis_seans_islem', 'belge_satir_id'),
        ('dis_seans_sarf', 'sarf_belge_id'),
        ('eczane_hazirlama', 'belge_id'),
        ('eczane_iade', 'belge_id'),
        ('eczane_imha', 'belge_id'),
        ('enabiz_erisim', 'belge_id'),
        ('enabiz_mesaj', 'belge_id'),
        ('ftr_program', 'belge_id'),
        ('gebe_izlem', 'belge_id'),
        ('gebelik_sonuc', 'belge_id'),
        ('goz_goruntuleme', 'belge_satir_id'),
        ('goz_islem', 'belge_id'),
        ('goz_islem', 'ucret_belge_satir_id'),
        ('iskonto_talep_satir', 'belge_satir_id'),
        ('konsultasyon', 'belge_id'),
        ('kontrollu_defter', 'belge_id'),
        ('kurum_icmal', 'belge_id'),
        ('lab_dis_gonderim', 'fatura_belge_id'),
        ('lab_istem', 'belge_id'),
        ('medula_rapor', 'belge_id'),
        ('pat_gonderim', 'fatura_belge_id'),
        ('radyoloji_konsultasyon', 'belge_satir_id'),
        ('satinalma_fatura_kontrol', 'siparis_belge_id'),
        ('satinalma_kabul', 'siparis_belge_id'),
        ('satinalma_talep_satir', 'belge_satir_id'),
        ('sevk', 'belge_id'),
        ('stok_sayim', 'cikis_belge_id'),
        ('stok_sayim', 'giris_belge_id'),
        ('tedarikci_olay', 'belge_id'),
        ('telerad_istek', 'fatura_belge_id'),
        ('yatis', 'belge_id')
        ) v(tablo, kolon)
    loop
        if to_regclass('public.' || r.tablo) is null then continue; end if;
        if not exists (select 1 from information_schema.columns
                        where table_schema = 'public' and table_name = r.tablo and column_name = r.kolon) then
            continue;
        end if;
        execute format('create index if not exists %I on public.%I (%I)',
                       'ix_' || r.tablo || '_' || r.kolon, r.tablo, r.kolon);
    end loop;
end $$;

commit;
