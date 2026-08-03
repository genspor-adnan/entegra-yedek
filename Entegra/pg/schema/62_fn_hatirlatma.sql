-- ============================================================================
-- fn_tarihfarkigunayyilsaatdakikatextolarak (helper) + fn_prg_islistesihatirlatma
-- MSSQL: fn_TarihFarkiGunAyYilSaatDakikaTextOlarak (loop-based fark->Turkce metin),
--        sp_Prg_IsListesiHatirlatma (@Kullanici) -> ANIMSAT+GOREVLER animsat listesi.
-- NOT: birebir; helper saat/dk sinir-sayimi floor ile yaklasik (goruntu metni, onemsiz fark).
-- ============================================================================
DROP FUNCTION IF EXISTS fn_tarihfarkigunayyilsaatdakikatextolarak(timestamp, timestamp);
CREATE OR REPLACE FUNCTION fn_tarihfarkigunayyilsaatdakikatextolarak(t1 timestamp, t2 timestamp)
RETURNS varchar(100) LANGUAGE plpgsql AS $$
DECLARE v_yil int:=0; v_ay int:=0; v_gun int:=0; v_saat int:=0; v_dk int:=0;
        v_sonuc varchar(100):=''; v_ek varchar(10); v_tmp timestamp;
BEGIN
  IF t1>t2 THEN v_tmp:=t1; t1:=t2; t2:=v_tmp; v_ek:='geçti.'; ELSE v_ek:='var.'; END IF;
  WHILE ((extract(year from t2)-extract(year from t1))*12 + (extract(month from t2)-extract(month from t1))) >= 12 LOOP
    t1:=t1+interval '1 year'; v_yil:=v_yil+1;
  END LOOP;
  WHILE (t2::date - t1::date) >= 30 LOOP
    t1:=t1+interval '1 month'; v_ay:=v_ay+1;
  END LOOP;
  WHILE floor(extract(epoch from (t2-t1))/3600) >= 24 LOOP
    t1:=t1+interval '1 day'; v_gun:=v_gun+1;
  END LOOP;
  WHILE floor(extract(epoch from (t2-t1))/60) >= 60 LOOP
    t1:=t1+interval '1 hour'; v_saat:=v_saat+1;
  END LOOP;
  WHILE floor(extract(epoch from (t2-t1))) >= 60 LOOP
    t1:=t1+interval '1 minute'; v_dk:=v_dk+1;
  END LOOP;
  IF v_yil>0  THEN v_sonuc:=v_sonuc||v_yil::text||' Yıl '; END IF;
  IF v_ay>0   THEN v_sonuc:=v_sonuc||v_ay::text||' Ay '; END IF;
  IF v_gun>0  THEN v_sonuc:=v_sonuc||v_gun::text||' Gün '; END IF;
  IF v_saat>0 THEN v_sonuc:=v_sonuc||v_saat::text||' Saat '; END IF;
  IF v_dk>0   THEN v_sonuc:=v_sonuc||v_dk::text||' Dakika '; END IF;
  v_sonuc:=v_sonuc||v_ek;
  RETURN v_sonuc;
END $$;

-- ---------------------------------------------------------------- fn_prg_islistesihatirlatma
DROP FUNCTION IF EXISTS fn_prg_islistesihatirlatma(integer);
CREATE OR REPLACE FUNCTION fn_prg_islistesihatirlatma(p_kullanici integer)
RETURNS TABLE("ID" integer,"TARIH" timestamp,"KONUSU" varchar(500),"YaziTarih" varchar(100))
LANGUAGE sql AS $$
  SELECT DISTINCT ID, TARIH, KONUSU, "YaziTarih" FROM (
    SELECT A.ID::int, A.TARIH::timestamp, G.KONUSU::varchar(500),
           fn_tarihfarkigunayyilsaatdakikatextolarak(now()::timestamp, G.BASLAMATARIHI::timestamp)::varchar(100) AS "YaziTarih"
    FROM ANIMSAT A
      INNER JOIN GOREVLER G ON A.ID=G.ID AND A.TUR=1
      INNER JOIN GOREVKULLANICI GK1 ON G.ID=GK1.LISTGOREVID AND GK1.TUR=11 AND GK1.REHBERID=coalesce(A.PERSONEL,p_kullanici)
    WHERE A.TARIH<now() AND GK1.REHBERID=p_kullanici
    UNION ALL
    SELECT A.ID::int, A.TARIH::timestamp, G.KONUSU::varchar(500),
           fn_tarihfarkigunayyilsaatdakikatextolarak(now()::timestamp, G.BASLAMATARIHI::timestamp)::varchar(100)
    FROM ANIMSAT A
      INNER JOIN GOREVLER G ON A.ID=G.ID AND G.EKLEYEN=coalesce(A.PERSONEL,p_kullanici)
    WHERE A.TARIH<now()
      AND NOT EXISTS (SELECT 1 FROM GOREVKULLANICI GK1 INNER JOIN GOREVLER G2 ON G2.ID=GK1.LISTGOREVID AND GK1.TUR=11 AND A.ID=G2.ID)
      AND G.EKLEYEN=p_kullanici
  ) XX
  ORDER BY 1 DESC;
$$;
