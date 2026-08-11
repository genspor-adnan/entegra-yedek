-- ============================================================
-- fn_belgenogetir — MSSQL dbo.sp_BelgeNoGetir PG portu (belge/kocan numara uretimi)
-- ------------------------------------------------------------
-- App: exec [dbo].[sp_BelgeNoGetir] @IslemTur,@SubeID,@Kocanno,@BTarihi
--   -> PgExecCevir -> SELECT * FROM fn_belgenogetir(...). SiradakiBelgeNumarasi (Utablo) cagirir.
-- IslemTur -> UstTur grupla; Kocanno=0/-99 ise KOCANAYARLARI'dan sec; -3333 ise max(ID)+1; aksi
--   ilgili tablodaki max(numerik belgeno)+1 (fallback BASLANGICNO); -101/-102/-103 SEQUENCE (seq_<kocan>).
-- MSSQL isnumeric(X)=1 -> PG X ~ '^\d+$' (belge no tam sayi dizisi). convert(decimal)->cast numeric.
-- NOT: seq_<kocanno> sequence'leri PG pilotta yoksa -101/-102/-103 turu hata verir (e-belge kocan yolu).
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_belgenogetir(int, int, int, timestamp);
CREATE FUNCTION public.fn_belgenogetir(
    p_islemtur int, p_subeid int, p_kocanno int DEFAULT 0, p_btarihi timestamp DEFAULT '2000-01-01')
RETURNS TABLE(kocanno int, belgeseri varchar, belgeno varchar)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_akocanno int; v_abelgeseri varchar(5) := ''; v_abelgeno varchar(20);
  v_usttur int; v_dijitsay int := 0; v_baslano varchar(25); v_bastarihi timestamp;
  -- MERKEZI SAYAC (GenDepoUpdate135/136 karsiligi): GENINI -24121 = 1 ise atomik tahsis
  v_sayac boolean; v_kapsam text; v_kosul text; v_basla bigint; v_trh text;
BEGIN
  v_sayac := coalesce((SELECT g.DEGER FROM GENINI g WHERE g.BOLUM = -24121 LIMIT 1), 0) = 1;
  v_usttur := CASE
    WHEN p_islemtur IN (21,22,23,24,25,26,27,28,29,88,130,141,142) THEN -101
    WHEN p_islemtur IN (31,32,33,34,35,36,37,38,98,125,131,137,140) THEN -102
    WHEN p_islemtur IN (40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
                        132,133,134,135,136,138,139,143,144,145,146,147,148,149) THEN -103
    ELSE p_islemtur END;

  IF p_kocanno IN (0, -99) THEN
    SELECT k.KOCANNO INTO v_akocanno FROM KOCANAYARLARI k
      WHERE k.SUBEID = p_subeid AND k.TUR = v_usttur LIMIT 1;
  ELSE
    v_akocanno := p_kocanno;
  END IF;

  IF v_akocanno = -3333 THEN
    v_abelgeseri := '';
    IF v_usttur IN (3,4,6,8,10,11,12,14,15,16,20,39,110,116,119,222) THEN
      SELECT cast(max(f.ID)+1 as varchar) INTO v_abelgeno FROM FATBASLIK f;
    ELSIF v_usttur IN (9,19,101,105) THEN
      SELECT cast(max(s.ID)+1 as varchar) INTO v_abelgeno FROM SIPARIS s;
    ELSIF v_usttur = 83 THEN
      SELECT cast(max(sv.ID)+1 as varchar) INTO v_abelgeno FROM SERVIS sv;
    ELSIF v_usttur IN (80,81) THEN
      SELECT cast(max(t.ID)+1 as varchar) INTO v_abelgeno FROM TEKLIF t;
    ELSIF v_usttur = 250 THEN
      SELECT cast(max(d.ID)+1 as varchar) INTO v_abelgeno FROM DOKUMAN d;
    ELSE
      SELECT cast(max(ks.ID)+1 as varchar) INTO v_abelgeno FROM KASA ks;
    END IF;
  ELSIF v_akocanno <> 0 THEN
    SELECT k.SERINO, k.BASLANGICNO, length(k.BASLANGICNO), k.BASLANGICTARIHI
      INTO v_abelgeseri, v_baslano, v_dijitsay, v_bastarihi
      FROM KOCANAYARLARI k
      WHERE k.SUBEID = p_subeid AND k.TUR = v_usttur AND k.KOCANNO = v_akocanno;

    v_basla  := coalesce(CASE WHEN v_baslano ~ '^[0-9]+$' THEN v_baslano::bigint END, 1);
    v_kapsam := 'T' || v_usttur::text || '|K' || v_akocanno::text;
    v_trh    := '''' || to_char(coalesce(v_bastarihi, '1900-01-01'::timestamp), 'YYYY-MM-DD HH24:MI:SS') || '''';

    IF v_usttur IN (3,4,6,8,10,11,12,14,15,16,20,39,110,116,119,222) THEN
      IF v_sayac THEN
        v_kosul := 'FATURATARIH >= ' || v_trh || ' AND TUR = ' || v_usttur::text || ' AND KOCANNO = ' || v_akocanno::text || ' AND FATURANO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('fatbaslik','faturano', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(f.FATURANO as numeric))+1 as varchar) FROM FATBASLIK f
              WHERE f.FATURATARIH >= v_bastarihi AND f.TUR = v_usttur AND f.KOCANNO = v_akocanno
                AND f.FATURANO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur IN (9,19,101,105) THEN
      IF v_sayac THEN
        v_kosul := 'SIPARISTARIH >= ' || v_trh || ' AND KOCANNO = ' || v_akocanno::text || ' AND SIPARISNO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('siparis','siparisno', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(s.SIPARISNO as numeric))+1 as varchar) FROM SIPARIS s
              WHERE s.SIPARISTARIH >= v_bastarihi AND s.KOCANNO = v_akocanno
                AND s.SIPARISNO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur = 83 THEN
      IF v_sayac THEN
        v_kosul := 'TARIH >= ' || v_trh || ' AND KOCANNO = ''' || v_akocanno::text || ''' AND SERVISNO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('servis','servisno', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(sv.SERVISNO as numeric))+1 as varchar) FROM SERVIS sv
              WHERE sv.TARIH >= v_bastarihi AND sv.KOCANNO = v_akocanno::varchar  -- SERVIS.KOCANNO PG'de varchar
                AND sv.SERVISNO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur IN (80,81) THEN
      IF v_sayac THEN
        v_kosul := 'TARIH >= ' || v_trh || ' AND KOCANNO = ' || v_akocanno::text || ' AND TEKLIFNO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('teklif','teklifno', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(t.TEKLIFNO as numeric))+1 as varchar) FROM TEKLIF t
              WHERE t.TARIH >= v_bastarihi AND t.KOCANNO = v_akocanno
                AND t.TEKLIFNO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur = 166 THEN  -- uretim emri
      IF v_sayac THEN
        v_kosul := 'TALEPTARIHI >= ' || v_trh || ' AND EMIRNO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('uretimemri','emirno', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(u.EMIRNO as numeric))+1 as varchar) FROM URETIMEMRI u
              WHERE u.TALEPTARIHI >= v_bastarihi AND u.EMIRNO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur = 250 THEN
      IF v_sayac THEN
        v_kosul := 'EKLEMETARIHI >= ' || v_trh || ' AND BELGENO ~ ''^[0-9]+$''';
        SELECT s.no INTO v_abelgeno FROM fn_prog_siradakino('dokuman','belgeno', v_kapsam, v_kosul, v_basla, 1, 0, true, true) s;
      ELSE
      SELECT coalesce((SELECT cast(max(cast(d.BELGENO as numeric))+1 as varchar) FROM DOKUMAN d
              WHERE d.EKLEMETARIHI >= v_bastarihi AND d.BELGENO ~ '^\d+$'), v_baslano) INTO v_abelgeno;
      END IF;
    ELSIF v_usttur IN (-103,-102,-101) THEN
      v_abelgeno := cast(nextval('seq_' || v_akocanno::text) as varchar);
    END IF;
  END IF;

  IF v_abelgeno IS NOT NULL AND length(v_abelgeno) < v_dijitsay THEN
    v_abelgeno := lpad(v_abelgeno, v_dijitsay, '0');
  END IF;

  RETURN QUERY SELECT v_akocanno, v_abelgeseri, v_abelgeno;
END;
$$;
