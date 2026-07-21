-- ============================================================
-- fn_prog_fisler_liste_json2 — MSSQL sp_Prog_Fisler_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Fis listesi (2 param: baslik = SELECT ek-kolon fragmenti / app-uretimi;
--   kosullar = JSON filtreler). Govde = eski TFislerListeFrame.JvTimer1Timer:
--   base 'SELECT DISTINCT fb.* FROM fatbaslik fb' + kosullu fatura/stoklar join
--   + WHERE fb.tur=@Tur + tarih/sube/depo/tipi/stok suzgecleri.
-- @Mod: 1=Tum 3=Sik 4=Filtre/normal 5=Son. Mod 3/5 = KULLANICI_ARAMA (Son/Sik),
--   tarih/depo/tipi/stok suzgecleri UYGULANMAZ, yalniz fb.tur korunur.
-- @Baslik (EkAlanlar) YOK SAYILIR: PG sabit RETURNS TABLE'a ek-kolon eklenemez
--   (dokuman/pdks/stok/demirbas deseni); base fatbaslik.* superset'i doner.
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, LIKE(CI)->ILIKE
--   quote_literal('%'||v||'%'), bit/tinyint->smallint(int). SP'de TOP/LIMIT YOK -> eklenmedi.
-- KA_SIRA hesapli kolonu (SP'de select'e eklenip ORDER BY icin kullanilir) PG'de
--   RETURNS TABLE'a sigmaz; onun yerine Mod 3/5'te DIS sarma + korelasyonlu skaler
--   subquery ile ORDER BY (SELECT DISTINCT + ORDER-BY-non-select-col yasagini asar).
-- Metin/tarih filtreleri quote_literal (param-juggling yok), int filtreler ::int inline
--   (SP-birebir, injection yok); OrderBy app-uretimi/guvenilir (SP de ham inline eder).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_fisler_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_fisler_liste_json2(p_baslik text DEFAULT '', p_kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, tarih timestamp, tur smallint, tipi smallint, rehberid integer, projeid integer,
    aktiviteid integer, anakayitid integer, faturatarih timestamp, kocanno integer, faturaseri varchar,
    faturano varchar, girisdepo smallint, cikisdepo smallint, baslik varchar, adres varchar, ilce varchar,
    il varchar, vd varchar, vno varchar, kdvdurum varchar, lotno varchar, fatura_gon_tarihi timestamp,
    fatura_matrahi numeric, kdv_tutari numeric, ekvergi numeric, fatura_tutari numeric, kur varchar,
    doviz_tutari numeric, doviz_cinsi varchar, kasa smallint, onay smallint, sayfa smallint, masrafid smallint,
    aciklama varchar, isyeri smallint, bolum smallint, fatura_maliyeti_ort numeric, saticikodu integer,
    durum smallint, irsaliye_tipi smallint, odemeplani smallint, ozelkod varchar, yetkikodu varchar,
    fiyat_listesi smallint, stokisk double precision, vade smallint, r smallint, irsaliyeno varchar,
    irsaliyetarih timestamp, planid integer, ekleyen integer, eklemetarihi timestamp, degistiren integer,
    degistirmetarihi timestamp, kasatakipid integer, detaybolumu varchar, dovizkur numeric,
    acik_kapali smallint, dil smallint, sayfasay smallint, rehberiletid integer, subeid smallint,
    baglifaturaid integer, muhaktar smallint, aktarmatarihi timestamp, yeri smallint, yerid integer,
    lokasyon integer, onaylayan integer, girissube smallint, zarfid integer, irsaliyeli smallint,
    merkezid integer, efaturadurum smallint, donusumturu integer, yazdirildi smallint, efaturasonuc smallint,
    senaryo smallint, ekstredekullan smallint, giriskaynak smallint, rapordoviz varchar, faturadovizi varchar,
    servisid integer, aciklama2 varchar, demirbasid integer, ozelkod2 varchar, pozno integer,
    atlantis_fatbasid integer, sanal smallint
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(p_kosullar, '')::jsonb, '{}'::jsonb);
    v_mod        int  := COALESCE(NULLIF(j->>'Mod', '')::int, 4);
    v_tur        int  := COALESCE(NULLIF(j->>'Tur', '')::int, 0);
    v_faturajoin int  := COALESCE(NULLIF(j->>'FaturaJoin', '')::int, 0);
    v_tarihbas   text := NULLIF(j->>'TarihBas', '');
    v_tarihbit   text := NULLIF(j->>'TarihBit', '');
    v_subeid     int  := NULLIF(j->>'SubeId', '')::int;
    v_depoid     int  := NULLIF(j->>'DepoId', '')::int;
    v_tipi       int  := NULLIF(j->>'Tipi', '')::int;
    v_stokara    text := NULLIF(j->>'StokAra', '');
    v_kod        text := NULLIF(j->>'Kod', '');
    v_kulid      int  := NULLIF(j->>'KulId', '')::int;
    v_modul      int  := NULLIF(j->>'Modul', '')::int;
    v_orderby    text := NULLIF(j->>'OrderBy', '');
    v_join text := '';   -- kosullu fatura/stoklar join
    v_filt text := '';   -- WHERE ek kosullar
    v_inner text;
    v_sql text;
BEGIN
    IF v_mod IN (3, 5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        -- Son(5)/Sik(3): kullanicinin actigi fisler (EXISTS suzgec). Tarih/depo/tipi/stok
        -- suzgecleri UYGULANMAZ (gecmis tum kayitlar), yalniz fb.tur korunur.
        v_filt := v_filt || ' AND EXISTS (SELECT 1 FROM kullanici_arama ka WHERE ka.kayitid = fb.id AND ka.kulid = '
                  || v_kulid || ' AND ka.modul = ' || v_modul || ') ';
    ELSE
        -- Tum(1)/Filtre(4): eski JvTimer1Timer suzgecleri birebir.
        IF v_faturajoin = 1 OR v_kod IS NOT NULL THEN
            v_join := ' INNER JOIN fatura ft ON ft.fatbasid = fb.id LEFT OUTER JOIN stoklar s ON ft.urunid = s.id ';
        END IF;
        IF v_tarihbas IS NOT NULL THEN
            v_filt := v_filt || ' AND fb.faturatarih >= ' || quote_literal(v_tarihbas) || '::timestamp ';
        END IF;
        IF v_tarihbit IS NOT NULL THEN
            v_filt := v_filt || ' AND fb.faturatarih <= ' || quote_literal(v_tarihbit) || '::timestamp ';
        END IF;
        IF v_subeid IS NOT NULL AND v_subeid > 0 THEN
            v_filt := v_filt || ' AND fb.subeid = ' || v_subeid || ' ';
        END IF;
        IF v_depoid IS NOT NULL AND v_depoid > 0 THEN
            v_filt := v_filt || CASE WHEN v_tur = 3 THEN ' AND fb.girisdepo = ' ELSE ' AND fb.cikisdepo = ' END
                      || v_depoid || ' ';
        END IF;
        IF v_tipi IS NOT NULL AND v_tipi > 0 THEN
            v_filt := v_filt || ' AND fb.tipi = ' || v_tipi || ' ';
        END IF;
        IF v_stokara IS NOT NULL THEN
            v_filt := v_filt || ' AND s.stokadi ILIKE ' || quote_literal('%' || v_stokara || '%') || ' ';
        END IF;
        IF v_kod IS NOT NULL THEN
            v_filt := v_filt || ' AND (s.kod ILIKE ' || quote_literal('%' || v_kod || '%')
                      || ' OR s.urunno ILIKE ' || quote_literal('%' || v_kod || '%') || ') ';
        END IF;
    END IF;

    v_inner := 'SELECT DISTINCT fb.* FROM fatbaslik fb' || v_join
               || ' WHERE fb.tur = ' || v_tur || v_filt;

    IF v_mod IN (3, 5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        -- Dis sarma: SELECT DISTINCT + ORDER-BY-non-select-col yasagini asar.
        v_sql := 'SELECT sub.* FROM (' || v_inner || ') sub ORDER BY (SELECT '
                 || CASE WHEN v_mod = 5 THEN 'max(ka.degistirmetarihi)' ELSE 'max(ka.say)' END
                 || ' FROM kullanici_arama ka WHERE ka.kayitid = sub.id AND ka.kulid = ' || v_kulid
                 || ' AND ka.modul = ' || v_modul || ') DESC NULLS LAST';
    ELSIF v_orderby IS NOT NULL THEN
        v_sql := v_inner || ' ORDER BY ' || v_orderby;
    ELSE
        v_sql := v_inner || ' ORDER BY fb.faturatarih DESC';
    END IF;

    RETURN QUERY EXECUTE v_sql;
END $$;
