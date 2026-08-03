-- sp_Prog_Kasa_Hareket_Json2 PG portu (kasa hareket listesi; UKasa ListeSPJson).
--   4 kaynak UNION ALL: KASA (taban) + FATBASLIK (CheckFat) + CEKHAREKET (CheckCekSenet) + SENETLER.
--   Tarih [>= BasDT, < BitDT); sube suzgeci digit-guard'li; HESAPKODU/HESAPADI HESAPTURU CASE.
--   @Baslik yok sayilir. Kolonlar UNION ile sabit -> RETURNS TABLE net.
DROP FUNCTION IF EXISTS public.fn_prog_kasa_hareket_json2(text, text);
CREATE FUNCTION public.fn_prog_kasa_hareket_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  id int, kayittarih timestamp, aksiyontarih timestamp, tur smallint, belgeno varchar,
  rehberid int, carikod varchar, cariad varchar, aciklama varchar, hesapid int,
  hesapkodu varchar, hesapadi varchar, borc numeric, alacak numeric, doviz_tutari numeric,
  kasa smallint, onay smallint, ekleyen int, masrafkod varchar, masrafad varchar, kur varchar,
  geridonusid int, durum smallint, faturaid int, ceksenetid int, krediid int, yeri int, yerid int,
  ozelkod varchar, subeid smallint)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb,'{}'::jsonb);
  v_cal1 date := NULLIF(j->>'Cal1','')::date;
  v_cal2 date := NULLIF(j->>'Cal2','')::date;
  v_baszaman text := COALESCE(NULLIF(j->>'BasZaman',''),'00:00:00');
  v_bitzaman text := COALESCE(NULLIF(j->>'BitZaman',''),'23:59');
  v_eklegun int := COALESCE(NULLIF(j->>'EkleGun','')::int,0);
  v_checkkasa int := COALESCE(NULLIF(j->>'CheckKasa','')::int,0);
  v_checkplan int := COALESCE(NULLIF(j->>'CheckPlan','')::int,0);
  v_checkfat int := COALESCE(NULLIF(j->>'CheckFat','')::int,0);
  v_checkcek int := COALESCE(NULLIF(j->>'CheckCekSenet','')::int,0);
  v_subekasa text := NULLIF(j->>'SubeKasaList','');
  v_subecek text := NULLIF(j->>'SubeCekList','');
  v_subeid int := COALESCE(NULLIF(j->>'SubeId','')::int,0);
  v_basdt timestamp; v_bitdt timestamp;
  fkasa text := ''; ffat text := ''; fcek text := '';
  q text;
BEGIN
  v_basdt := (v_cal1::text || ' ' || v_baszaman)::timestamp;
  v_bitdt := ((v_cal2 + v_eklegun)::text || ' ' || v_bitzaman)::timestamp;
  IF v_subeid > 0 THEN
    fkasa := ' and K.SUBEID = '||v_subeid; ffat := ' and F.SUBEID = '||v_subeid; fcek := ' and C.SUBEID = '||v_subeid;
  ELSE
    IF v_subekasa IS NOT NULL AND v_subekasa ~ '^[0-9, -]+$' THEN
      fkasa := ' and K.SUBEID in ('||v_subekasa||')'; ffat := ' and F.SUBEID in ('||v_subekasa||')';
    END IF;
    IF v_subecek IS NOT NULL AND v_subecek ~ '^[0-9, -]+$' THEN
      fcek := ' and C.SUBEID in ('||v_subecek||')';
    END IF;
  END IF;

  q := 'Select K.ID, K.ISLEMTARIHI, K.PLANTARIHI, K.TUR::smallint, cast(K.BELGENO as varchar), K.REHBERID,
    R.KOD, R.FIRMA, K.ACIKLAMA, K.HESAPID,
    (case K.HESAPTURU
       when ''B'' then (select HESAPKODU from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
       when ''K'' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)
       when ''H'' then (select KASAKODU from KASALAR K2 where K2.ID=K.HESAPID)||coalesce('' (''||(select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)||'')'','''')
       when ''P'' then (select KODU from POS P where P.ID=K.HESAPID)
       when ''V'' then (select KODU from KREDIKARTI KK where KK.ID=K.HESAPID)
       when ''R'' then (select KREDIKODU from KREDILER KR where KR.ID=K.HESAPID)
       when ''M'' then (select KOD from MASRAFGELIR M where M.ID=K.HESAPID) end)::varchar,
    (case K.HESAPTURU
       when ''B'' then (select HESAPADI from BANKAHESAPLAR BH where BH.ID=K.HESAPID)
       when ''K'' then (select KASAADI from KASALAR K2 where K2.ID=K.HESAPID)
       when ''H'' then (select KASAADI from KASALAR K2 where K2.ID=K.HESAPID)||coalesce('' (''||(select ADI from PARA_KUPON PK where PK.ID=K.CEKSENETID)||'')'','''')
       when ''P'' then (select ADI from POS P where P.ID=K.HESAPID)
       when ''V'' then (select ADI from KREDIKARTI KK where KK.ID=K.HESAPID)
       when ''R'' then (select ADI from KREDILER KR where KR.ID=K.HESAPID)
       when ''M'' then (select AD from MASRAFGELIR M where M.ID=K.HESAPID) end)::varchar,
    (case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,54,58,59) and coalesce(K.HESAPTURU,'''')<>'''' then K.ALACAK else K.BORC end)::numeric,
    (case when K.TUR in (1,2,40,41,42,43,44,45,46,47,48,51,52,53,54,58,59) and coalesce(K.HESAPTURU,'''')<>'''' then K.BORC else K.ALACAK end)::numeric,
    K.DOVIZ_TUTARI::numeric, K.KASA::smallint, K.ONAY::smallint, K.EKLEYEN, MG.KOD::varchar, MG.AD::varchar, K.KUR::varchar, K.GERIDONUSID,
    null::smallint, K.FATURAID, K.CEKSENETID, K.KREDIID, K.YERI::integer, K.YERID::integer, ''''::varchar, K.SUBEID::smallint
    FROM KASA K left outer join REHBER R on R.ID=K.REHBERID left outer join MASRAFGELIR MG on MG.ID=K.MASRAFID
    Where K.ISLEMTARIHI >= '||quote_literal(v_basdt)||' and K.ISLEMTARIHI < '||quote_literal(v_bitdt)||fkasa;
  IF v_checkkasa = 0 THEN q := q || ' and not(K.TUR between 21 and 39)'; END IF;
  IF v_checkplan = 0 THEN q := q || ' and not(K.TUR between 61 and 79)'; END IF;

  IF v_checkfat = 1 THEN
    q := q || ' UNION ALL SELECT F.ID, F.FATURATARIH, F.FATURATARIH, F.TUR::smallint, F.FATURANO::varchar, F.REHBERID, R.KOD, R.FIRMA, F.ACIKLAMA,
      (case when F.YERI=3 then abs(F.REHBERID) else null end),
      (case when F.YERI=3 then (select KASAKODU from KASALAR where ID=abs(F.REHBERID)) else null end)::varchar,
      (case when F.YERI=3 then (select KASAADI from KASALAR where ID=abs(F.REHBERID)) else null end)::varchar,
      (case when F.TUR in (15,16,17,110) then F.FATURA_TUTARI else 0.0 end)::numeric,
      (case when F.TUR in (8,11,12,13) then F.FATURA_TUTARI else 0.0 end)::numeric,
      F.DOVIZ_TUTARI::numeric, 0::smallint, null::smallint, F.EKLEYEN, MG.KOD::varchar, MG.AD::varchar, F.KUR::varchar, null::int,
      null::smallint, F.ID, null::int, null::int,
      (case when F.KASATAKIPID is not null then 401 else null end)::integer, F.KASATAKIPID::integer, F.OZELKOD::varchar, F.SUBEID::smallint
      FROM FATBASLIK F left outer join REHBER R on R.ID=F.REHBERID left outer join MASRAFGELIR MG on MG.ID=F.MASRAFID
      Where F.TUR not in (2,6,10,14,20) and coalesce(F.DURUM,0)<>6 and F.FATURATARIH >= '||quote_literal(v_basdt)||' and F.FATURATARIH < '||quote_literal(v_bitdt)||ffat;
  END IF;

  IF v_checkcek = 1 THEN
    q := q || ' UNION ALL SELECT CH.ID, CH.TARIH, C.VADE,
      (case when CH.ISLEM between 130 and 139 and C.CEKSENET=101 then 23
            when CH.ISLEM between 140 and 149 and C.CEKSENET=103 then 33
            when CH.ISLEM between 130 and 139 and C.CEKSENET=121 then 24
            when CH.ISLEM between 140 and 149 and C.CEKSENET=321 then 34 else 0 end)::smallint,
      cast(CH.BELGENO as varchar), CH.REHBERID, R.KOD, R.FIRMA,
      (G.ANAHTAR||'' ''||coalesce(CH.ACIKLAMA,''''))::varchar,
      null::int, C.KOD::varchar, (select HESAPADI from HESAPPLANI where HESAPKODU=C.KOD)::varchar,
      (case when CH.ISLEM in(131,132,133,134,135,136,137,138,140) then C.TUTAR else 0 end)::numeric,
      (case when CH.ISLEM in(130,141) then C.TUTAR else 0 end)::numeric,
      0::numeric, 0::smallint, null::smallint, C.EKLEYEN, M.KOD::varchar, M.AD::varchar, C.KUR::varchar, null::int, null::smallint, C.FATURAID,
      C.ID, null::int, null::int, null::int, C.OZELKOD::varchar, C.SUBEID::smallint
      FROM CEKLER C inner join CEKHAREKET CH on C.ID=CH.CEKSENETLERID
        inner join GENINI G on G.BOLUM=-1005 and G.DIL=-1 and G.DEGER=CH.ISLEM
        left outer join REHBER R on R.ID=CH.REHBERID
        left outer join BANKAHESAPLAR BH on BH.ID=CH.BANKAHESAPLARID
        left outer join MASRAFGELIR M on M.ID=C.MASRAFID
      Where CH.ISLEM in(130,131,132,133,134,135,137,138,140,141) and CH.TARIH >= '||quote_literal(v_basdt)||' and CH.TARIH < '||quote_literal(v_bitdt)||fcek;
    q := q || ' UNION ALL SELECT C.ID, C.TARIH, C.VADE, C.TUR::smallint, C.MAKBUZNO::varchar, C.REHBERID, R.KOD, R.FIRMA, C.ACIKLAMA,
      null::int, C.KOD::varchar, null::varchar,
      (case when C.TUR=34 then C.TUTAR else 0 end)::numeric,
      (case when C.TUR=24 then C.TUTAR else 0 end)::numeric,
      0::numeric, 0::smallint, null::smallint, C.EKLEYEN, MG.KOD::varchar, MG.AD::varchar, C.KUR::varchar, null::int, null::smallint, C.FATURAID,
      null::int, null::int, null::int, null::int, C.OZELKOD::varchar, C.SUBEID::smallint
      FROM SENETLER C inner join REHBER R on R.ID=C.REHBERID left outer join MASRAFGELIR MG on MG.ID=C.MASRAFID
      Where C.TARIH >= '||quote_literal(v_basdt)||' and C.TARIH < '||quote_literal(v_bitdt)||fcek;
  END IF;

  RETURN QUERY EXECUTE q;
END $$;
