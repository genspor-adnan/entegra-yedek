-- ============================================================================
--  Konsolide GenUpdate 66-169 — PostgreSQL portu
--  04_Silme_API_PG.sql  (MSSQL karsiligi: 04_Silme_API.sql)
--
--  Iki eksigi kapatir:
--
--  1) BASIT KART ENGELLERI (modul 46 kredi karti / 58 masraf-gelir /
--     69 POS / 480 kasa). PG portu bu kartlari HIC engel kontrolu yapmadan
--     siliyordu; ustelik acilis satirlarini (KASA.TUR IN (1,2)) da siliyor.
--     Yani hareket gormus bir kart silinebiliyor, hareket satirlari yetim
--     kaliyordu. MSSQL fn_Prog_Silme_Engel matrisindeki kurallar:
--         46  : KASA HESAPTURU='V' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)
--         69  : KASA HESAPTURU='P' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)
--         480 : KASA HESAPTURU='K' AND HESAPID={ID} AND ISNULL(TUR,0) <> 1
--         58  : KASA.MASRAFID / FATBASLIK.MASRAFID / FATURA(TUR=0).URUNID / BUTCE.MASRAFID
--
--  2) SILME MATRISI TVF'leri. PG'de yalnizca kart satiri (sira 900) vardi:
--     detay 124->16, detay_ek 40->4, engel 55->7, engel_ek 12->5.
--     Silme kodu matrisi okumadigi icin islevsel etkisi yoktu ama "kural tek
--     yerde" ilkesi kirilmisti; asagidaki tanimlar MSSQL ile BIREBIR ayni.
--     (Kosul metinleri T-SQL yazimindadir; ISNULL/LEN gibi cagrılar PG'de
--      pg/schema/03_uyumluluk_fonksiyonlari.sql sayesinde de calisir.)
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------- 1) BASIT KART ENGEL ----
CREATE OR REPLACE FUNCTION public.fn_api_basit_kart_sil_json(p_modul integer, kosullar text DEFAULT '{}'::text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar, '')::jsonb, '{}'::jsonb);
  v_kayitid integer := NULLIF(j->>'KayitId', '')::integer;
  v_kulid integer := COALESCE(NULLIF(j#>>'{Oturum,KulId}', '')::integer, 0);
  v_subeid integer := COALESCE(NULLIF(j#>>'{Oturum,SubeId}', '')::integer, 0);
  v_ip varchar(45) := LEFT(COALESCE(j#>>'{Oturum,Ip}', ''), 45);
  v_ist varchar(64) := LEFT(COALESCE(j#>>'{Oturum,Istasyon}', ''), 64);
  v_karttablo text;
  v_var integer;
  v_loglanan integer := 0;
  v_silinen integer := 0;
  v_n integer := 0;
BEGIN
  IF v_kayitid IS NULL OR v_kayitid <= 0 THEN
    RAISE EXCEPTION 'KayitId zorunlu.' USING ERRCODE = 'P0001';
  END IF;

  v_karttablo := CASE p_modul
    WHEN 58 THEN 'MASRAFGELIR'
    WHEN 69 THEN 'POS'
    WHEN 46 THEN 'KREDIKARTI'
    WHEN 480 THEN 'KASALAR'
    ELSE NULL
  END;

  IF v_karttablo IS NULL THEN
    RAISE EXCEPTION 'Bu basit kart silme portu modul % desteklemiyor.', p_modul USING ERRCODE = 'P0001';
  END IF;

  EXECUTE format('select 1 from public.%I where id=$1 limit 1', lower(v_karttablo))
    INTO v_var
    USING v_kayitid;

  IF COALESCE(v_var, 0) = 0 THEN
    RAISE EXCEPTION 'Kayit bulunamadi.' USING ERRCODE = 'P0001';
  END IF;

  -- ---- ENGEL KURALLARI (MSSQL fn_Prog_Silme_Engel / _Ek ile ayni) ----------
  IF p_modul = 46 THEN
    IF EXISTS (SELECT 1 FROM kasa
                WHERE hesapturu = 'V' AND hesapid = v_kayitid
                  AND COALESCE(tur, 0) NOT IN (1, 2)) THEN
      RAISE EXCEPTION 'Bu kredi kartı için girilmiş kasa hareketi var, silinemez.' USING ERRCODE = 'P0001';
    END IF;

  ELSIF p_modul = 69 THEN
    IF EXISTS (SELECT 1 FROM kasa
                WHERE hesapturu = 'P' AND hesapid = v_kayitid
                  AND COALESCE(tur, 0) NOT IN (1, 2)) THEN
      RAISE EXCEPTION 'Bu POS için girilmiş kasa hareketi var, silinemez.' USING ERRCODE = 'P0001';
    END IF;

  ELSIF p_modul = 480 THEN
    IF EXISTS (SELECT 1 FROM kasa
                WHERE hesapturu = 'K' AND hesapid = v_kayitid
                  AND COALESCE(tur, 0) <> 1) THEN
      RAISE EXCEPTION 'Bu kasa için girilmiş hareket var, silinemez.' USING ERRCODE = 'P0001';
    END IF;

  ELSIF p_modul = 58 THEN
    IF EXISTS (SELECT 1 FROM kasa WHERE masrafid = v_kayitid)
       OR EXISTS (SELECT 1 FROM fatbaslik WHERE masrafid = v_kayitid)
       OR EXISTS (SELECT 1 FROM fatura WHERE tur = 0 AND urunid = v_kayitid) THEN
      RAISE EXCEPTION 'Bu masraf/gelir hareket görmüş, silinemez.' USING ERRCODE = 'P0001';
    END IF;
    IF EXISTS (SELECT 1 FROM butce WHERE masrafid = v_kayitid) THEN
      RAISE EXCEPTION 'Bütçe kaydı var, önce bütçeyi silin.' USING ERRCODE = 'P0001';
    END IF;
  END IF;

  -- Kart logu once.
  v_n := public.fn_api_log_yaz_ic(p_tablo := v_karttablo, p_kosul := 'ID=@pB', p_kosulpar := v_kayitid,
                                 p_tabno := p_modul, p_usttabno := p_modul, p_ustid := v_kayitid,
                                 p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                 p_islemtipi := 0::smallint);
  v_loglanan := v_loglanan + COALESCE(v_n, 0);

  IF p_modul = 58 THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'FIYATLAR', p_kosul := 'HIZMETID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 58, p_usttabno := 58, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);

    DELETE FROM fiyatlar WHERE hizmetid = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM masrafgelir WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 69 THEN
    v_n := public.fn_api_log_yaz_ic(p_tablo := 'POSORAN', p_kosul := 'POSID=@pB', p_kosulpar := v_kayitid,
                                   p_tabno := 69, p_usttabno := 69, p_ustid := v_kayitid,
                                   p_kulid := v_kulid, p_subeid := v_subeid, p_ip := v_ip, p_istasyon := v_ist,
                                   p_islemtipi := 0::smallint);
    v_loglanan := v_loglanan + COALESCE(v_n, 0);
    -- KASA baglari icin desteklenen kosulu log helper'a sokmadan burada kart loguyla yetiniyoruz.
    DELETE FROM posoran WHERE posid = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kasa WHERE hesapturu = 'P' AND hesapid = v_kayitid AND tur IN (1,2);
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM pos WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 46 THEN
    DELETE FROM kasa WHERE hesapturu = 'V' AND hesapid = v_kayitid AND tur IN (1,2);
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kredikarti WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;

  ELSIF p_modul = 480 THEN
    DELETE FROM kasa WHERE hesapturu = 'K' AND hesapid = v_kayitid AND tur = 1;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
    DELETE FROM kasalar WHERE id = v_kayitid;
    GET DIAGNOSTICS v_n = ROW_COUNT; v_silinen := v_silinen + v_n;
  END IF;

  RETURN jsonb_build_object(
    'Sonuc', 1,
    'Modul', p_modul,
    'KayitId', v_kayitid,
    'SilinenSatir', v_silinen,
    'Loglanan', v_loglanan
  )::text;
END;
$function$;

-- ------------------------------------------ 2) SILME MATRISI (MSSQL ile birebir) ----
-- Bu blok MSSQL fn_Prog_Silme_* TVF ciktisindan uretildi (Konsolide 66-169).

CREATE OR REPLACE FUNCTION public.fn_prog_silme_detay()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, tabloid integer)
LANGUAGE sql IMMUTABLE AS $$
  SELECT * FROM (VALUES
    (18,10,'IMAJ','YERI=18 AND YER_ID={ID}',42),
    (18,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=18 AND GOREVID={ID}))',42),
    (18,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=18 AND GOREVID={ID})',321),
    (18,40,'GOREVYORUM','TUR=18 AND GOREVID={ID}',210),
    (18,50,'DEMIRBAS_TUTANAK_DETAY','DEMIRBASID={ID}',375),
    (18,60,'AMORTISMAN_ORAN','ID={ID}',373),
    (18,70,'DEMIRBAS_USER','ID={ID}',18),
    (18,900,'DEMIRBAS','ID={ID}',18),
    (33,10,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=33 AND MODULID={ID})',42),
    (33,20,'DOKUMAN','MODUL=33 AND MODULID={ID}',321),
    (33,30,'ANIMSAT','TUR=1 AND ID={ID}',33),
    (33,40,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID={ID}))',42),
    (33,50,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE GOREVID={ID})',321),
    (33,60,'GOREVYORUM','GOREVID={ID}',210),
    (33,70,'GOREVKULLANICI','TUR=11 AND LISTGOREVID={ID}',33),
    (33,900,'GOREVLER','ID={ID}',33),
    (46,10,'KASA','HESAPTURU=''V'' AND HESAPID={ID} AND TUR IN (1,2)',40),
    (46,900,'KREDIKARTI','ID={ID}',46),
    (58,10,'FIYATLAR','HIZMETID={ID}',58),
    (58,900,'MASRAFGELIR','ID={ID}',58),
    (69,10,'POSORAN','POSID={ID}',69),
    (69,20,'KASA','HESAPTURU=''P'' AND HESAPID={ID} AND TUR IN (1,2)',40),
    (69,900,'POS','ID={ID}',69),
    (70,10,'IMAJ','YERI=70 AND YER_ID={ID}',42),
    (70,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=70 AND GOREVID={ID}))',42),
    (70,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=70 AND GOREVID={ID})',321),
    (70,40,'GOREVYORUM','TUR=70 AND GOREVID={ID}',210),
    (70,50,'REHBERBILGI','YERI=70 AND YER_ID={ID}',372),
    (70,60,'PROJEASAMA','PROJEID={ID}',371),
    (70,900,'PROJELER','ID={ID}',70),
    (71,10,'REHBERBILGI','YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})',76),
    (71,20,'REHBERILETISIM','REHBERID={ID}',75),
    (71,30,'REHBERBILGIRESIM','REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})',516),
    (71,40,'REHBERBILGI','YERI IN (2,3) AND YER_ID={ID}',76),
    (71,50,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID}))',42),
    (71,60,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=71 AND GOREVID={ID})',321),
    (71,70,'GOREVYORUM','TUR=71 AND GOREVID={ID}',210),
    (71,80,'IMAJ','YERI=71 AND YER_ID={ID}',42),
    (71,90,'REHBERALIAS','REHBERID={ID}',513),
    (71,100,'REHBERTEMSILCI','REHBERID={ID}',514),
    (71,110,'REHBERPERSONEL','REHBERID={ID}',515),
    (71,120,'KULLANICI','REHBERID={ID}',52),
    (71,130,'REHBERBILGI','YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))',76),
    (71,140,'REHBERILETISIM','REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})',75),
    (71,150,'REHBER','GRUP=334 AND BAGID={ID}',71),
    (71,160,'REHBER_USER','ID={ID}',504),
    (71,170,'GENINI','BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))',71),
    (71,900,'REHBER','ID={ID}',71),
    (73,10,'REHBERBILGI','YERI=1 AND YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID={ID})',76),
    (73,20,'REHBERILETISIM','REHBERID={ID}',75),
    (73,30,'REHBERBILGIRESIM','REHBERBILGIID IN (SELECT ID FROM REHBERBILGI WHERE YERI IN (1,2,3) AND YER_ID={ID})',516),
    (73,40,'REHBERBILGI','YERI=3 AND YER_ID={ID}',86),
    (73,50,'REHBERBILGI','YERI=2 AND YER_ID={ID}',76),
    (73,60,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID}))',42),
    (73,70,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=73 AND GOREVID={ID})',321),
    (73,80,'GOREVYORUM','TUR=73 AND GOREVID={ID}',210),
    (73,90,'IMAJ','YERI=71 AND YER_ID={ID}',42),
    (73,100,'PERS_HAREKET','REHBERID={ID} AND TUR=1',78),
    (73,110,'KULLANICI','REHBERID={ID}',52),
    (73,120,'REHBERALIAS','REHBERID={ID}',513),
    (73,130,'REHBERTEMSILCI','REHBERID={ID}',514),
    (73,140,'REHBERPERSONEL','REHBERID={ID}',515),
    (73,150,'REHBERBILGI','YER_ID IN (SELECT ID FROM REHBERILETISIM WHERE REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID}))',76),
    (73,160,'REHBERILETISIM','REHBERID IN (SELECT ID FROM REHBER WHERE GRUP=334 AND BAGID={ID})',75),
    (73,170,'REHBER','GRUP=334 AND BAGID={ID}',71),
    (73,180,'REHBER_USER','ID={ID}',504),
    (73,190,'GENINI','BOLUM IN (SELECT CAST(''-100'' + CAST(v.n AS varchar(2)) + CAST({ID} AS varchar(20)) AS bigint) FROM (VALUES(54),(55),(56),(57),(58),(59),(60),(61),(62),(63),(64),(65),(66),(67),(68),(69)) v(n))',73),
    (73,900,'REHBER','ID={ID}',73),
    (83,10,'IMAJ','YERI=83 AND YER_ID={ID}',42),
    (83,20,'SERVISDETAY','SERVISID={ID}',183),
    (83,30,'SERVISBILGI','SERVISID={ID}',183),
    (83,40,'SERVISDETAYPERSONEL','SERVISID={ID}',430),
    (83,50,'SERVISASAMA','SERVISID={ID}',183),
    (83,60,'GOREVKULLANICI','TUR=12 AND LISTGOREVID={ID}',183),
    (83,70,'SERVISHAREKET_USER','ID IN (SELECT ID FROM SERVISHAREKET WHERE SERVISID={ID})',183),
    (83,80,'SERVISHAREKET','SERVISID={ID}',183),
    (83,90,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID}))',42),
    (83,100,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=83 AND GOREVID={ID})',321),
    (83,110,'GOREVYORUM','TUR=83 AND GOREVID={ID}',210),
    (83,120,'SERVIS_USER','ID={ID}',83),
    (83,900,'SERVIS','ID={ID}',83),
    (91,10,'REHBERBILGI','YERI IN (130,131) AND YER_ID={ID}',76),
    (91,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=91 AND GOREVID={ID}))',42),
    (91,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=91 AND GOREVID={ID})',321),
    (91,40,'GOREVYORUM','TUR=91 AND GOREVID={ID}',210),
    (91,50,'SIPARISDETAY','SIPARISID={ID}',92),
    (91,60,'SIPARIS_USER','ID={ID}',505),
    (91,900,'SIPARIS','ID={ID}',91),
    (97,10,'IMAJ','YERI=80 AND YER_ID={ID}',42),
    (97,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID}))',42),
    (97,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=97 AND GOREVID={ID})',321),
    (97,40,'GOREVYORUM','TUR=97 AND GOREVID={ID}',210),
    (97,50,'TEKLIFDETAY','TEKLIFID={ID}',98),
    (97,60,'TEKLIF_USER','ID={ID}',97),
    (97,900,'TEKLIF','ID={ID}',97),
    (170,10,'IMAJ','YERI=170 AND YER_ID={ID}',42),
    (170,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=170 AND GOREVID={ID}))',42),
    (170,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=170 AND GOREVID={ID})',321),
    (170,40,'GOREVYORUM','TUR=170 AND GOREVID={ID}',210),
    (170,50,'REHBERBILGI','YERI=70 AND YER_ID={ID}',372),
    (170,60,'PROJEASAMA','PROJEID={ID}',371),
    (170,900,'PROJELER','ID={ID}',170),
    (315,10,'IMAJ','YERI=21 AND YER_ID={ID}',42),
    (315,20,'CEKHAREKET','CEKSENETLERID={ID}',317),
    (315,900,'CEKLER','ID={ID}',315),
    (316,10,'IMAJ','YERI=21 AND YER_ID={ID}',42),
    (316,20,'CEKHAREKET','CEKSENETLERID={ID}',317),
    (316,900,'CEKLER','ID={ID}',316),
    (318,10,'IMAJ','YERI=21 AND YER_ID={ID}',42),
    (318,20,'CEKHAREKET','CEKSENETLERID={ID}',317),
    (318,900,'CEKLER','ID={ID}',318),
    (319,10,'IMAJ','YERI=21 AND YER_ID={ID}',42),
    (319,20,'CEKHAREKET','CEKSENETLERID={ID}',317),
    (319,900,'CEKLER','ID={ID}',319),
    (321,10,'IMAJ','YERI=1 AND YER_ID={ID}',42),
    (321,20,'DOKUMANYETKI','YERI=321 AND YERID={ID}',321),
    (321,30,'REHBERBILGI','YERI=321 AND YER_ID={ID}',76),
    (321,40,'DOKUMANGECMIS','DOKUMANID={ID}',374),
    (321,50,'DOKUMANILGILI','DOKUMANID={ID}',321),
    (321,60,'DOKUMANBILDIRIM','DOKUMANID={ID}',321),
    (321,70,'DOKUMANKISAYOL','DOKUMANID={ID}',321),
    (321,900,'DOKUMAN','ID={ID}',321),
    (480,10,'KASA','HESAPTURU=''K'' AND HESAPID={ID} AND TUR=1',43),
    (480,900,'KASALAR','ID={ID}',480)
  ) AS t(modul,sira,tablo,kosul,tabloid);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_detay_ek()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, tabloid integer)
LANGUAGE sql IMMUTABLE AS $$
  SELECT * FROM (VALUES
    (88,10,'IMAJ','YERI BETWEEN 71 AND 72 AND YER_ID={ID}',42),
    (88,20,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID}))',42),
    (88,30,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=88 AND GOREVID={ID})',321),
    (88,40,'GOREVYORUM','TUR=88 AND GOREVID={ID}',210),
    (88,50,'STOKFIYAT','STOKID={ID}',346),
    (88,60,'ISORTAGI','STOKID={ID}',88),
    (88,70,'STOKESDEGER','STOKID={ID}',344),
    (88,80,'STOKBARKOD','STOKID={ID}',340),
    (88,90,'STOKBOYUTKOMBINASYON','STOKID={ID}',342),
    (88,100,'STOKSEVIYE','STOKID={ID}',88),
    (88,110,'STOKMUHASEBE','STOKID={ID}',88),
    (88,120,'STOKCEVRIM','STOKID={ID}',88),
    (88,130,'EKIPMANLAR','URUNID={ID}',88),
    (88,140,'PAKETDETAY','PAKETID={ID}',88),
    (88,150,'PAKETDETAY','URUNID={ID} AND STOK=1',88),
    (88,160,'REHBERBILGI','YERI=88 AND YER_ID={ID}',76),
    (88,170,'STOKLAR_USER','ID={ID}',508),
    (88,900,'STOKLAR','ID={ID}',88),
    (138,10,'URETIMRECETEOPR','URETIMRECETEID={ID}',155),
    (138,20,'URETIMRECETEDETAY','URETIMRECETEID={ID}',139),
    (138,900,'URETIMRECETE','ID={ID}',138),
    (140,10,'IMAJ','YERI=1 AND YER_ID IN (SELECT ID FROM DOKUMAN WHERE MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))',42),
    (140,20,'DOKUMAN','MODUL=210 AND MODULID IN (SELECT ID FROM GOREVYORUM WHERE TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))',321),
    (140,30,'GOREVYORUM','TUR=142 AND GOREVID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})',210),
    (140,40,'URETIMOLCUMDETAY','URETIMOLCUMID IN (SELECT ID FROM URETIMOLCUM WHERE OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})))',525),
    (140,50,'URETIMOLCUM','OPERASYONPERSONELID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))',524),
    (140,52,'URETIMOPERASONPERSONEL_USER','ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))',526),
    (140,55,'URETIMOPERASYONPERSONEL_USER','ID IN (SELECT ID FROM URETIMOPERASYONPERSONEL WHERE OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID}))',511),
    (140,60,'URETIMOPERASYONPERSONEL','OPERASYONID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})',146),
    (140,70,'URETIMOPERASYONMALIYET','URETIMEMRIID={ID}',522),
    (140,80,'URETIMOPERASYONFASON','URETIMEMRIID={ID}',523),
    (140,90,'URETIMOPERASYON','URETIMEMRIID={ID}',142),
    (140,100,'URETIMEMRIDETAY','URETIMEMRIID={ID}',141),
    (140,110,'URETIMEMRI_USER','ID={ID}',510),
    (140,900,'URETIMEMRI','ID={ID}',140),
    (520,10,'STOKIZLEME','BELGETUR=99 AND BASLIKID={ID}',367),
    (520,20,'STOKLOKASYON','DURUM=0 AND BELGETUR=99 AND BASLIKID={ID}',520),
    (520,30,'FATURA','FATBASID IN (SELECT ID FROM FATBASLIK WHERE TUR=7 AND ANAKAYITID={ID})',132),
    (520,40,'FATBASLIK','TUR=7 AND ANAKAYITID={ID}',29),
    (520,900,'STOKSAYIM','ID={ID}',520)
  ) AS t(modul,sira,tablo,kosul,tabloid);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_engel()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, mesaj text)
LANGUAGE sql IMMUTABLE AS $$
  SELECT * FROM (VALUES
    (18,10,'KALIBRASYON','SELECT 1 FROM KALIBRASYON WHERE DEMIRBASID={ID}','Bu demirbaşa ait kalibrasyon kaydı var, silinemez.'),
    (18,20,'GOREVLER','SELECT 1 FROM GOREVLER WHERE YER=18 AND YER_ID={ID}','Bu demirbaşa bağlı iş/görev var, silinemez.'),
    (18,30,'SERVIS','SELECT 1 FROM SERVIS WHERE DEMIRBAS=1 AND EKIPMANID={ID}','Bu demirbaşa ait servis kaydı var, silinemez.'),
    (46,10,'KASA','SELECT 1 FROM KASA WHERE HESAPTURU=''V'' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)','Bu kredi kartı için girilmiş kasa hareketi var, silinemez.'),
    (58,10,'KASA','SELECT 1 FROM KASA WHERE MASRAFID={ID}','Bu masraf/gelir hareket görmüş, silinemez.'),
    (58,20,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE MASRAFID={ID}','Bu masraf/gelir hareket görmüş, silinemez.'),
    (58,30,'FATURA','SELECT 1 FROM FATURA WHERE TUR=0 AND URUNID={ID}','Bu masraf/gelir hareket görmüş, silinemez.'),
    (58,40,'BUTCE','SELECT 1 FROM BUTCE WHERE MASRAFID={ID}','Bütçe kaydı var, önce bütçeyi silin.'),
    (69,10,'KASA','SELECT 1 FROM KASA WHERE HESAPTURU=''P'' AND HESAPID={ID} AND ISNULL(TUR,0) NOT IN (1,2)','Bu POS için girilmiş kasa hareketi var, silinemez.'),
    (70,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}','Bu projeye ait belge var, silinemez.'),
    (70,20,'KASA','SELECT 1 FROM KASA WHERE PROJEID={ID}','Bu projeye ait kasa hareketi var, silinemez.'),
    (70,30,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE PROJEID={ID}','Bu projeye ait çek hareketi var, silinemez.'),
    (70,40,'GOREVLER','SELECT 1 FROM GOREVLER WHERE PROJEID={ID}','Bu projeye ait iş/görev var, silinemez.'),
    (70,50,'TEKLIF','SELECT 1 FROM TEKLIF WHERE PROJEID={ID}','Bu projeye ait teklif var, silinemez.'),
    (70,60,'SIPARIS','SELECT 1 FROM SIPARIS WHERE PROJEID={ID}','Bu projeye ait sipariş var, silinemez.'),
    (71,10,'KULLANICI','SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1','Yönetici kullanıcı silinemez.'),
    (71,20,'KASA','SELECT 1 FROM KASA WHERE REHBERID={ID}','Bu cariye ait kasa/plan verisi var, silinemez.'),
    (71,30,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}','Bu cariye ait fatura verisi var, silinemez.'),
    (71,40,'CEKLER','SELECT 1 FROM CEKLER WHERE REHBERID={ID}','Bu cariye ait çek verisi var, silinemez.'),
    (71,50,'SENETLER','SELECT 1 FROM SENETLER WHERE REHBERID={ID}','Bu cariye ait senet verisi var, silinemez.'),
    (71,60,'PERS_HAREKET','SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID}','Bu karta ait personel bilgisi var, silinemez.'),
    (71,70,'BANKAHESAPLAR','SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}','Bu cariye ait banka hesabı var, silinemez.'),
    (71,80,'PROJELER','SELECT 1 FROM PROJELER WHERE REHBERID={ID}','Bu cariye ait proje var, silinemez.'),
    (71,90,'AKTIVITELER','SELECT 1 FROM AKTIVITELER WHERE MUSTERIID={ID}','Bu cariye ait aktivite var, silinemez.'),
    (71,100,'TEKLIF','SELECT 1 FROM TEKLIF WHERE REHBERID={ID}','Bu cariye ait teklif var, silinemez.'),
    (71,110,'SIPARIS','SELECT 1 FROM SIPARIS WHERE REHBERID={ID}','Bu cariye ait sipariş var, silinemez.'),
    (71,120,'SERVIS','SELECT 1 FROM SERVIS WHERE REHBERID={ID}','Bu cariye ait servis kaydı var, silinemez.'),
    (71,130,'SOZLESMELER','SELECT 1 FROM SOZLESMELER WHERE REHBERID={ID}','Bu cariye ait sözleşme var, silinemez.'),
    (71,140,'SATINALMA','SELECT 1 FROM SATINALMA WHERE REHBERID={ID}','Bu cariye ait satınalma kaydı var, silinemez.'),
    (71,150,'URETIMEMRI','SELECT 1 FROM URETIMEMRI WHERE REHBERID={ID}','Bu cariye ait üretim emri var, silinemez.'),
    (71,160,'ISEMRI','SELECT 1 FROM ISEMRI WHERE REHBERID={ID}','Bu cariye ait iş emri var, silinemez.'),
    (71,170,'REHBER','SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ( EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))','Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.'),
    (73,10,'KULLANICI','SELECT 1 FROM KULLANICI K INNER JOIN ROLLER R ON R.ID=K.ROLID WHERE K.REHBERID={ID} AND ISNULL(R.TY,0)=1','Yönetici kullanıcı silinemez.'),
    (73,20,'KASA','SELECT 1 FROM KASA WHERE REHBERID={ID}','Bu personele ait kasa hareketi var, silinemez.'),
    (73,30,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE REHBERID={ID}','Bu personele ait belge var, silinemez.'),
    (73,40,'PERS_HAREKET','SELECT 1 FROM PERS_HAREKET WHERE REHBERID={ID} AND ISNULL(TUR,0)<>1','Bu personele ait hareket kaydı var, silinemez.'),
    (73,50,'BANKAHESAPLAR','SELECT 1 FROM BANKAHESAPLAR WHERE REHBERID={ID}','Bu personele ait banka hesabı var, silinemez.'),
    (73,60,'SERVIS','SELECT 1 FROM SERVIS WHERE REHBERID={ID}','Bu personele ait servis kaydı var, silinemez.'),
    (73,70,'REHBER','SELECT 1 FROM REHBER K WHERE K.GRUP=334 AND K.BAGID={ID} AND ( EXISTS(SELECT 1 FROM SIPARIS s WHERE s.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM TEKLIF t WHERE t.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM SERVIS v WHERE v.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM GOREVLER g WHERE g.MUS_ILGILI=K.ID OR g.MUS_ILGILI2=K.ID) OR EXISTS(SELECT 1 FROM EKIPMANREHBER e WHERE e.MUS_ILGILI=K.ID) OR EXISTS(SELECT 1 FROM DOKUMAN d WHERE d.ILGILIID=K.ID) OR EXISTS(SELECT 1 FROM TEKLIFFINANSAL f WHERE f.ILGILIID=K.ID))','Bu karta bağlı ilgili kişi belgelerde kullanılmış, silinemez.'),
    (83,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE SERVISID={ID}','Bu servisten belge oluşturulmuş, silinemez.'),
    (91,10,'FATURA','SELECT 1 FROM FATURA F INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R   ON R.DonusumTuru=F.YERI AND R.KaynakDetayTablo=''SIPARISDETAY''  AND R.KalanHedefTablo=''FATURA'' WHERE F.YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID={ID})','Bu sipariş belgeye dönüştürülmüş, silinemez.'),
    (91,20,'SIPARISDETAY','SELECT 1 FROM SIPARISDETAY SD INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R   ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''SIPARISDETAY''  AND R.KalanHedefTablo=''SIPARISDETAY'' WHERE SD.YERID IN (SELECT ID FROM SIPARISDETAY WHERE SIPARISID={ID})','Bu talep siparişe dönüştürülmüş, silinemez.'),
    (97,10,'SIPARISDETAY','SELECT 1 FROM SIPARISDETAY SD INNER JOIN dbo.fn_Prog_BelgeDonusum_Rota() R   ON R.DonusumTuru=SD.YERI AND R.KaynakDetayTablo=''TEKLIFDETAY'' WHERE SD.YERID IN (SELECT ID FROM TEKLIFDETAY WHERE TEKLIFID={ID})','Bu teklif siparişe dönüştürülmüş, silinemez.'),
    (170,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE PROJEID={ID}','Bu fırsata ait belge var, silinemez.'),
    (170,20,'KASA','SELECT 1 FROM KASA WHERE PROJEID={ID}','Bu fırsata ait kasa hareketi var, silinemez.'),
    (170,30,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE PROJEID={ID}','Bu fırsata ait çek hareketi var, silinemez.'),
    (170,40,'GOREVLER','SELECT 1 FROM GOREVLER WHERE PROJEID={ID}','Bu fırsata ait iş/görev var, silinemez.'),
    (170,50,'TEKLIF','SELECT 1 FROM TEKLIF WHERE PROJEID={ID}','Bu fırsata ait teklif var, silinemez.'),
    (315,10,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1','Bu çek/senet hareket görmüş, silinemez.'),
    (316,10,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1','Bu çek/senet hareket görmüş, silinemez.'),
    (318,10,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1','Bu çek/senet hareket görmüş, silinemez.'),
    (319,10,'CEKHAREKET','SELECT 1 FROM CEKHAREKET WHERE CEKSENETLERID={ID} GROUP BY CEKSENETLERID HAVING COUNT(*)>1','Bu çek/senet hareket görmüş, silinemez.'),
    (321,10,'DOKUMANKISAYOL','SELECT 1 FROM DOKUMANKISAYOL WHERE DOKUMANID={ID}','Bu dokümanın kısayolu var, önce kısayolları kaldırın.'),
    (321,20,'SOZLESMELER','SELECT 1 FROM SOZLESMELER WHERE YERI=321 AND YER_ID={ID}','Bu dokümana bağlı sözleşme var, silinemez.'),
    (480,10,'KASA','SELECT 1 FROM KASA WHERE HESAPTURU=''K'' AND HESAPID={ID} AND ISNULL(TUR,0)<>1','Bu kasa için girilmiş hareket var, silinemez.')
  ) AS t(modul,sira,tablo,kosul,mesaj);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_silme_engel_ek()
RETURNS TABLE(modul integer, sira integer, tablo text, kosul text, mesaj text)
LANGUAGE sql IMMUTABLE AS $$
  SELECT * FROM (VALUES
    (88,10,'STOKSAYIMKALEMLERI','SELECT 1 FROM STOKSAYIMKALEMLERI WHERE STOKID={ID}','Bu stok sayımda kullanılmış, silinemez.'),
    (88,20,'FATURA','SELECT 1 FROM FATURA WHERE TUR=1 AND URUNID={ID}','Bu stok faturada kullanılmış, silinemez.'),
    (88,30,'SIPARISDETAY','SELECT 1 FROM SIPARISDETAY WHERE TUR=1 AND URUNID={ID}','Bu stok siparişte kullanılmış, silinemez.'),
    (88,40,'TEKLIFDETAY','SELECT 1 FROM TEKLIFDETAY WHERE TUR=1 AND URUNID={ID}','Bu stok teklifte kullanılmış, silinemez.'),
    (88,50,'STOKIZLEME','SELECT 1 FROM STOKIZLEME WHERE STOKID={ID}','Bu stokun lot/seri hareketi var, silinemez.'),
    (88,60,'URETIMRECETE','SELECT 1 FROM URETIMRECETE WHERE STOKID={ID}','Bu stok üretim reçetesinde kullanılmış, silinemez.'),
    (88,70,'STOKDURUM','SELECT 1 FROM STOKDURUM WHERE STOKID={ID} AND ISNULL(KALAN,0)<>0','Bu stokun depo bakiyesi var, silinemez.'),
    (138,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=138 AND YERID={ID}','Bu reçeteden üretim fişi oluşturulmuş, silinemez.'),
    (138,20,'URETIMEMRI','SELECT 1 FROM URETIMEMRI WHERE RECETEID={ID}','Bu reçete üretim emrinde kullanılmış, silinemez.'),
    (138,30,'URETIMRECETEDETAY','SELECT 1 FROM URETIMRECETEDETAY WHERE URETIMRECETEID={ID} AND ISNULL(ANAURUN,0)=0','Önce Reçete detayını silin!'),
    (140,10,'FATBASLIK','SELECT 1 FROM FATBASLIK WHERE TUR=6 AND YERI=142 AND YERID IN (SELECT ID FROM URETIMOPERASYON WHERE URETIMEMRIID={ID})','Bu üretim emrinden üretim fişi oluşturulmuş, silinemez.'),
    (520,10,'STOKSAYIMKALEMLERI','SELECT 1 FROM STOKSAYIMKALEMLERI WHERE SAYIMID={ID}','Bu sayımın kalemleri var, önce kalemleri silin.')
  ) AS t(modul,sira,tablo,kosul,mesaj);
$$;
