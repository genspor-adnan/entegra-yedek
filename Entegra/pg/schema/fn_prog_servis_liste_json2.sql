-- ============================================================
-- fn_prog_servis_liste_json2 — MSSQL sp_Prog_Servis_Liste_Json2 PG portu
--   Servis liste. Kaynak view: VServisListesi (PG: vservislistesi). SELECT S.* (view'in tum kolonlari).
--   @Baslik (EkAlanlar) YOK SAYILIR (sabit RETURNS TABLE'a ek-kolon eklenemez; superset dondur).
--   Dinamik: @Mod 3/5 KULLANICI_ARAMA join (Son/Sik), WHERE (no/kategori/konu/urun/musteri/sube/serino/
--            cbListe kapsam/durum/sorumlu/kapali-tarih), ORDER, TOP->LIMIT.
--   MSSQL->PG: LIKE(CI)->ILIKE quote_literal, ISNULL->COALESCE, bit->smallint, GETDATE()->current_date,
--     ROUND(CAST(dt AS float))-gun-esitligi -> dt::date=current_date, TOP->LIMIT.
--   VIEW BAGIMLILIGI: vservislistesi (+ fn_serviskisiler, vservishareket, v_servis_hareket_ozet) kurulu olmali.
--   NOT: @Pasif JSON'da tanimli ama MSSQL govdesinde de kullanilmiyor -> port'ta da yok.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_servis_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_servis_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, baslamatarihi timestamp, rehberid integer, servisno varchar, konusu varchar, durum smallint,
    mus_ilgili integer, bitistarihi timestamp, serino varchar, kasa smallint, fiyat_listesi smallint,
    ozelkod varchar, yetkikodu varchar, notlar varchar, ekipmanrehberid integer, depo smallint, lokasyonid integer,
    planlanan_matrahi numeric, planlanan_tutar numeric, planlanan_kur varchar, planlanan_doviz_tutari numeric,
    planlanan_doviz_kuru numeric, planlanan_kdv_tutari numeric, uygulanan_matrahi numeric, uygulanan_tutar numeric,
    uygulanan_kur varchar, uygulanan_doviz_tutari numeric, uygulanan_doviz_kuru numeric, uygulanan_kdv_tutari numeric,
    sorumlu integer, kabul_eden integer, kabul_sekli smallint, teslim_alan integer, teslim_eden integer,
    teslim_tarihi timestamp, teslim_sekli smallint, teslim_kargo_no varchar, onaysekli smallint, onaytarihi timestamp,
    onaylayan integer, onayalan integer, subeid smallint, ekleyen smallint, eklemetarihi timestamp, degistiren smallint,
    degistirmetarihi timestamp, kapsam smallint, detaybolumu varchar, acil smallint, disservis smallint, tarih timestamp,
    ekipmanid integer, teslimnotu varchar, ackapa smallint, demirbas smallint, yeri integer, yerid integer, turu smallint,
    onaylayacak integer, disonay integer, servisadresi integer, kocanno varchar, servisseri varchar, onemli smallint,
    projeid integer, giriskaynak smallint, yildiz smallint, baslama timestamp, bitis timestamp, toplam_sure text,
    calisma_suresi text, sorun_tipi varchar, sorun_aciklama varchar, sorun_sonucu varchar, kabul_edenad varchar,
    kategoriad varchar, ekipmanad varchar, firma varchar, sorumluad varchar, mus_ilgiliad varchar, lokasyon varchar,
    onaylayanad varchar, teslim_alanad varchar, onaysekliad varchar, faturatarih timestamp, faturano varchar,
    fatura_tutari numeric, servis_adresi varchar
)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 0);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_servisno  text := NULLIF(j->>'ServisNo','');
    v_servisnoid int := NULLIF(j->>'ServisNoId','')::int;
    v_kategoriad text := NULLIF(j->>'KategoriAd','');
    v_konusu    text := NULLIF(j->>'Konusu','');
    v_urun      text := NULLIF(j->>'Urun','');
    v_musteri   text := NULLIF(j->>'Musteri','');
    v_serinom   text := NULLIF(j->>'SeriNo','');
    v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
    v_cbliste   int  := NULLIF(j->>'cbListe','')::int;
    v_kullanan  int  := NULLIF(j->>'Kullanan','')::int;
    v_subeidf   int  := NULLIF(j->>'SubeID','')::int;
    v_durum     int  := NULLIF(j->>'Durum','')::int;
    v_durumvar  int  := COALESCE(NULLIF(j->>'DurumVar','')::int, 0);
    v_sorumlutag int := COALESCE(NULLIF(j->>'SorumluTag','')::int, 0);
    v_kapali    int  := COALESCE(NULLIF(j->>'Kapali','')::int, 0);
    v_tamamlanan int := NULLIF(j->>'Tamamlanan','')::int;
    v_kapalitarih text := NULLIF(j->>'KapaliTarih','');
    v_tarihbas  text := NULLIF(j->>'TarihBas','');
    v_tarihbit  text := NULLIF(j->>'TarihBit','');
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := NULLIF(j->>'Modul','')::int;
    v_orderby   text := NULLIF(j->>'OrderBy','');
    q text; w text := ' WHERE 1=1 '; joinka text := ''; ordr text := ''; lim text := '';
    kajoin boolean := false;
BEGIN
    IF v_topn > 0 THEN lim := ' LIMIT ' || v_topn; END IF;
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        kajoin := true;
        joinka := ' INNER JOIN kullanici_arama ka ON ka.kayitid=s.id AND ka.kulid='||v_kulid||' AND ka.modul='||v_modul||' ';
    END IF;

    -- EditNo: SERVISNO prefix-LIKE (+ sayisal ise S.ID). Varsa asagidaki Kapali/tarih blogu atlanir.
    IF v_servisno IS NOT NULL THEN
        w := w || ' AND ((s.servisno ILIKE '||quote_literal(v_servisno||'%')||')';
        IF v_servisnoid IS NOT NULL AND v_servisnoid <> 0 THEN
            w := w || ' OR (s.id='||v_servisnoid||')';
        END IF;
        w := w || ')';
    END IF;

    -- EditKategori (kategori adi ile esitlik; CI icin ILIKE)
    IF v_kategoriad IS NOT NULL THEN
        w := w || ' AND (SELECT ad FROM kategori k WHERE k.id=s.ekipmanid) ILIKE '||quote_literal(v_kategoriad)||' ';
    END IF;
    -- AraKonusu
    IF v_konusu IS NOT NULL THEN
        w := w || ' AND s.konusu ILIKE '||quote_literal('%'||v_konusu||'%')||' ';
    END IF;
    -- editUrun (ekipman adi)
    IF v_urun IS NOT NULL THEN
        w := w || ' AND (SELECT ad FROM ekipmanlar e WHERE e.id=s.ekipmanid) ILIKE '||quote_literal('%'||v_urun||'%')||' ';
    END IF;
    -- AraMusteri (FIRMA view kolonu)
    IF v_musteri IS NOT NULL THEN
        w := w || ' AND s.firma ILIKE '||quote_literal('%'||v_musteri||'%')||' ';
    END IF;
    -- Sube yetkisi (app-uretimi int listesi; guvenli guard)
    IF v_subeyetki IS NOT NULL AND v_subeyetki ~ '^[0-9, ]+$' THEN
        w := w || ' AND s.subeid IN ('||v_subeyetki||') ';
    END IF;
    -- EditSerino prefix-LIKE
    IF v_serinom IS NOT NULL THEN
        w := w || ' AND s.serino ILIKE '||quote_literal(v_serinom||'%')||' ';
    END IF;

    -- cbListe (personel/departman/sube kapsami)
    IF v_cbliste = 1 THEN        -- Aktif Servislerim (biten hareketi olmayan)
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE COALESCE(sh.bitissec,0)=0 AND sh.servisid=s.id AND sh.personel='||v_kullanan||') ';
    ELSIF v_cbliste = 2 THEN     -- Ilgili Olduklarim
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE sh.servisid=s.id AND sh.personel='||v_kullanan||') ';
    ELSIF v_cbliste = 5 THEN     -- Departman Servisleri
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE sh.servisid=s.id AND sh.personel IN '
             || ' (SELECT r.id FROM rehber r INNER JOIN roller rol ON r.sinif=rol.id '
             || '  WHERE rol.departman=(SELECT rol2.departman FROM rehber r2 INNER JOIN roller rol2 ON r2.sinif=rol2.id '
             || '  WHERE r2.id='||v_kullanan||'))) ';
    ELSIF v_cbliste = 8 THEN     -- Sube Servislerim
        w := w || ' AND s.subeid='||v_subeidf||' ';
    END IF;

    -- AraDurumu (dogrudan S.DURUM esitligi)
    IF v_durumvar = 1 THEN
        w := w || ' AND s.durum='||v_durum||' ';
    END IF;
    -- AraDurumu + EditSorumlu kombinasyonu (hareket bazli EXISTS)
    IF v_durumvar = 1 AND v_sorumlutag > 0 THEN
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE sh.servisid=s.id AND sh.durum='||v_durum||' AND sh.personel='||v_sorumlutag||') ';
    ELSIF v_durumvar = 0 AND v_sorumlutag > 0 THEN
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE sh.servisid=s.id AND sh.personel='||v_sorumlutag||') ';
    ELSIF v_durumvar = 1 AND v_sorumlutag = 0 THEN
        w := w || ' AND EXISTS (SELECT 1 FROM vservishareket sh WHERE sh.servisid=s.id AND sh.durum='||v_durum||') ';
    END IF;

    -- Kapali/tarih blogu: yalnizca ServisNo bosken
    IF v_servisno IS NULL THEN
        IF v_kapali = 1 THEN
            IF v_tamamlanan = 1 THEN            -- bugun (MSSQL gun-esitligi ROUND(float) -> ::date)
                w := w || ' AND (COALESCE(s.ackapa,0)=0 OR s.baslamatarihi::date = current_date) ';
            ELSIF v_tamamlanan = 19000 THEN     -- iki tarih arasi
                w := w || ' AND (COALESCE(s.ackapa,0)=0 OR (s.baslamatarihi BETWEEN '||quote_literal(v_tarihbas)||'::timestamp AND '||quote_literal(v_tarihbit)||'::timestamp)) ';
            ELSE                                -- son 1 ay / 1 yil vb.
                w := w || ' AND (COALESCE(s.ackapa,0)=0 OR s.baslamatarihi >= '||quote_literal(v_kapalitarih)||'::timestamp) ';
            END IF;
        ELSE
            w := w || ' AND s.ackapa = 0 ';
        END IF;
    END IF;

    -- Son/Sik siralamasi (yalnizca KA join kuruldugunda)
    IF kajoin AND v_mod = 5 THEN ordr := 'ka.degistirmetarihi DESC';
    ELSIF kajoin AND v_mod = 3 THEN ordr := 'ka.say DESC';
    ELSIF v_orderby IS NOT NULL THEN ordr := v_orderby;
    END IF;

    q := 'SELECT s.* FROM vservislistesi s ' || joinka || w;
    IF ordr <> '' THEN q := q || ' ORDER BY ' || ordr; END IF;
    q := q || lim;

    RETURN QUERY EXECUTE q;
END $$;
