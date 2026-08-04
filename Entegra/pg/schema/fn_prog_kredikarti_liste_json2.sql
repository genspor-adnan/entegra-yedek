-- ============================================================
-- fn_prog_kredikarti_liste_json2 — MSSQL sp_Prog_KrediKarti_Liste_Json2 PG portu
--   Kredi karti liste (UKrediKartiListeFrame.YenileClick). Govde eski istemci-taban
--   sorgusuyla BIREBIR: KK.* + SKT1(sktay/sktyil) + B.LOGO/BANKAADI + BS.SUBEADI,
--   bankahesaplar->bankasubeler->bankalar zinciri, sube filtresi, Son/Sik.
--   @Baslik (EkAlanlar) YOK SAYILIR (KrediKarti'da bos; sabit RETURNS TABLE'a ek-kolon eklenemez).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join (Son/Sik), sube WHERE, ORDER (Son/Sik->ka).
--   MSSQL->PG: EXISTS+MAX(KA_SIRA) -> INNER JOIN + ORDER BY ka.say/ka.degistirmetarihi
--     (kasalar/demirbas deseni; KA_SIRA cikti kolonu EKLENMEZ), CAST(..varchar)+'/' -> ::text||'/',
--     ISNULL->COALESCE, SUBEID IN(int-list) guard '^[0-9, -]+$'.
--   Hesapli kolonlar (skt1/logo/bankaadi/subeadi) RETURNS tipine EXPLICIT ::cast.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_kredikarti_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_kredikarti_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id smallint, kodu varchar(20), adi varchar(50), hamili varchar(50), turu smallint, tipi smallint,
    bankahesapid integer, nosu varchar(20), tanimli_kisi varchar(50), genellimit numeric, dahililimit numeric,
    kur varchar(5), dahili_limit_vadesi timestamp, skt timestamp, hesap_kesim_tarihi smallint,
    odeme_gun_sayisi smallint, nakit_faizorani double precision, alisveris_faizorani double precision,
    gecikme_faizorani double precision, uyar smallint, uyarigun smallint, otomatik_odeme smallint,
    odeme_bankahesapid integer, yillik_ucreti numeric, alinistarihi timestamp, kapanistarihi timestamp,
    ozelkod varchar(20), yetkikodu varchar(10), durum smallint, ekleyen integer, eklemetarihi timestamp,
    degistiren integer, degistirmetarihi timestamp, bakiye numeric, sktay smallint, sktyil smallint,
    subeid smallint, muhaktar smallint,
    skt1 text, logo bytea, bankaadi varchar(50), subeadi varchar(50)
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);   -- SAYFALI liste: 0 = LIMIT yok
    v_subelist  text := NULLIF(j->>'SubeYetkiList','');
    q text; w text := ' WHERE 1=1 '; joinka text := ''; ordr text := '';
BEGIN
    -- Son/Sik: kullanicinin actigi kartlar (KULLANICI_ARAMA) — suzgec + siralama
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=kk.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- Sube yetki filtresi (app-uretimi int listesi; guvenli guard)
    IF v_subelist IS NOT NULL AND v_subelist ~ '^[0-9, -]+$' THEN
        w := w || ' AND kk.subeid IN ('||v_subelist||') ';
    END IF;

    -- Siralama (MSSQL: Mod 3/5 -> KA_SIRA DESC; yoksa OrderBy varsa; yoksa siralamasiz)
    IF v_mod = 5 THEN ordr := ' ORDER BY ka.degistirmetarihi DESC';
    ELSIF v_mod = 3 THEN ordr := ' ORDER BY ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := ' ORDER BY ' || v_orderby;
    END IF;

    q := 'SELECT kk.*,
            (kk.sktay::text||''/''||kk.sktyil::text)::text AS skt1,
            b.logo::bytea AS logo, b.bankaadi::varchar(50) AS bankaadi, bs.subeadi::varchar(50) AS subeadi
          FROM kredikarti kk
            LEFT JOIN bankahesaplar bh ON bh.id=kk.bankahesapid
            LEFT JOIN bankasubeler bs ON bh.bankasubelerid=bs.id
            LEFT JOIN bankalar b ON b.bankakodu=bs.bankakodu '
         || joinka || w || ordr;
    -- SAYFALI liste (TSayfaliListe): MSSQL TOP (n) karsiligi
    IF v_topn > 0 THEN q := q || ' LIMIT ' || v_topn; END IF;
    RETURN QUERY EXECUTE q;
END $$;
