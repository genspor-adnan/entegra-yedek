-- ============================================================
-- fn_prog_pos_liste_json2 — MSSQL sp_Prog_POS_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- POS liste ekrani (UPOSListeFrame) sunucu-tarafi listeleme. Govde eski
--   TPOSListeFrame.YenileClick sorgusuyla BIREBIR: POS + BANKAHESAPLAR + BANKASUBELER + BANKALAR.
--   baslik = @Baslik (EkAlanlar) YOK SAYILIR (POS'ta zaten bos; sabit RETURNS TABLE'a
--     ek-kolon eklenemez -> P.* superset + LOGO/BANKAADI/SUBEADI doner).
--   kosullar = JSON filtreler. @Mod 3=Sik / 5=Son -> KULLANICI_ARAMA(MODUL_POS=2521); SubeYetkiList.
-- MSSQL->PG:
--   JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, bit/tinyint->smallint(=1 kalir),
--   P.* -> pos kolonlari acikca enumerate (PG kolon sirasi; app ada gore eslesir).
--   /*KA*/ (KA_SIRA kolon enjeksiyonu) -> RETURN edilmez (sabit RETURNS TABLE); Son/Sik siralamasi
--     disaridaki wrapper'da q.id ile korele KULLANICI_ARAMA subquery (demirbas/banka deseni).
--   /*SUBE*/ = SubeYetkiList (app-uretimi int-list; ~'^[0-9, ]+$' guard ile inline).
--   /*FLT*/  = Son/Sik EXISTS (kulid/modul int inline).
-- USING: yok (POS SP'de tarih/durum parametresi yok; tum filtreler guvenli inline).
-- VERI: ekspert.pos=2 satir -> DIFFERENTIAL mumkun.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_pos_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_pos_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id smallint, kodu varchar, adi varchar, turu smallint, statusu smallint,
    bankahesapid integer, nosu varchar, genellimit numeric, dahililimit numeric, kur varchar,
    dahili_limit_vadesi timestamp, skt timestamp, hesap_kesim_tarihi smallint, odeme_gun_sayisi smallint,
    yillik_ucreti numeric, alinistarihi timestamp, kapanistarihi timestamp, ozelkod varchar,
    yetkikodu varchar, durum smallint, ekleyen integer, eklemetarihi timestamp, degistiren integer,
    degistirmetarihi timestamp, bakiye numeric, subeid smallint, komisyonmasrafmerkezi integer,
    resim bytea, masrafcikis smallint, muhaktar smallint,
    logo bytea, bankaadi varchar, subeadi varchar
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_selectlist text := '';                                     -- @Baslik (EkAlanlar) YOK SAYILIR (superset base kolonlar)
    v_topn   int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);     -- SAYFALI liste: 0 = LIMIT yok
    v_mod    int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_sube   text := NULLIF(j->>'SubeYetkiList','');              -- app-uretimi int-list (GUVENILIR; yalniz SubeVarmi)
    v_kulid  int  := NULLIF(j->>'KulId','')::int;
    v_modul  int  := NULLIF(j->>'Modul','')::int;
    v_orderby text := NULLIF(j->>'OrderBy','');
    v_flt   text := '';        -- WHERE'e eklenen ek kosullar (Son/Sik EXISTS)
    v_subef text := '';        -- WHERE'e eklenen sube-yetki suzgeci
    v_body  text; q text;
BEGIN
    -- Son/Sik: kullanicinin actigi POS'lar (KULLANICI_ARAMA) suzgeci
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_flt := v_flt || ' AND EXISTS (SELECT 1 FROM kullanici_arama ka WHERE ka.kayitid=p.id AND ka.kulid='
                 || v_kulid || ' AND ka.modul=' || v_modul || ') ';
    END IF;
    -- Sube-yetki suzgeci (app-uretimi int-list; format guard -> enjeksiyon guvenli)
    IF v_sube IS NOT NULL AND v_sube ~ '^[0-9, ]+$' THEN
        v_subef := ' AND p.subeid IN (' || v_sube || ') ';
    END IF;

    v_body :=
    'select
        p.id::smallint AS id, p.kodu::varchar AS kodu, p.adi::varchar AS adi,
        p.turu::smallint AS turu, p.statusu::smallint AS statusu, p.bankahesapid::integer AS bankahesapid,
        p.nosu::varchar AS nosu, p.genellimit::numeric AS genellimit, p.dahililimit::numeric AS dahililimit,
        p.kur::varchar AS kur, p.dahili_limit_vadesi::timestamp AS dahili_limit_vadesi, p.skt::timestamp AS skt,
        p.hesap_kesim_tarihi::smallint AS hesap_kesim_tarihi, p.odeme_gun_sayisi::smallint AS odeme_gun_sayisi,
        p.yillik_ucreti::numeric AS yillik_ucreti, p.alinistarihi::timestamp AS alinistarihi,
        p.kapanistarihi::timestamp AS kapanistarihi, p.ozelkod::varchar AS ozelkod, p.yetkikodu::varchar AS yetkikodu,
        p.durum::smallint AS durum, p.ekleyen::integer AS ekleyen, p.eklemetarihi::timestamp AS eklemetarihi,
        p.degistiren::integer AS degistiren, p.degistirmetarihi::timestamp AS degistirmetarihi,
        p.bakiye::numeric AS bakiye, p.subeid::smallint AS subeid, p.komisyonmasrafmerkezi::integer AS komisyonmasrafmerkezi,
        p.resim::bytea AS resim, p.masrafcikis::smallint AS masrafcikis, p.muhaktar::smallint AS muhaktar,
        b.logo::bytea AS logo, b.bankaadi::varchar AS bankaadi, bs.subeadi::varchar AS subeadi
    from pos p
        inner join bankahesaplar bh on bh.id = p.bankahesapid
        inner join bankasubeler bs on bh.bankasubelerid = bs.id
        inner join bankalar b on b.bankakodu = bs.bankakodu
    where 1=1 ' || v_subef || v_flt;

    -- Siralama: Son/Sik -> q.id korele KULLANICI_ARAMA (KA_SIRA yerine), degilse OrderBy
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        q := 'SELECT * FROM (' || v_body || ') q ORDER BY (SELECT '
             || CASE WHEN v_mod = 5 THEN 'max(ka.degistirmetarihi)' ELSE 'max(ka.say)' END
             || ' FROM kullanici_arama ka WHERE ka.kayitid=q.id AND ka.kulid=' || v_kulid
             || ' AND ka.modul=' || v_modul || ') DESC';
    ELSIF v_orderby IS NOT NULL AND v_orderby <> '' THEN
        q := v_body || ' ORDER BY ' || v_orderby;
    ELSE
        q := v_body;
    END IF;

    -- SAYFALI liste (TSayfaliListe): MSSQL TOP (n) karsiligi
    IF v_topn > 0 THEN q := q || ' LIMIT ' || v_topn; END IF;

    RETURN QUERY EXECUTE q;
END $$;
