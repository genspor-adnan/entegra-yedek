-- sp_Prog_Teklif_Liste_Json2 PG portu (teklif listesi; UTeklifListeDlg ListeSPJson).
--   TEKLIF.* (69 kolon acikca) + 19 hesapli. @Baslik(@SelectList) yok sayilir (sabit RETURNS TABLE).
--   MSSQL first-match: SELECT T.* ONCE gelir -> dup adlar (HAZIRLAYAN, ONAYLAYAN) T.* kazanir,
--   hesapli R2.FIRMA/R4.FIRMA icin AYRI adlar (hazirlayanad; onaylayan-name ATLANIR - MSSQL'de T.* wins).
--   TEKLIFTUR=80 sabit. Dinamik: @Mod 3/5 KULLANICI_ARAMA, tarih/text-ILIKE/turu/stok/durum filtreleri, TOP->LIMIT.
DROP FUNCTION IF EXISTS public.fn_prog_teklif_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_teklif_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
  id integer, tarih timestamp, rehberid integer, revizeid integer, teklifno varchar, durumtarihi timestamp,
  turu smallint, konusu varchar, durum smallint, olasilik smallint, gecerlilik_suresi smallint, teslim_suresi smallint,
  hazirlayan integer, mus_ilgili integer, kdvdurum varchar, teklif_matrahi numeric, kdv_tutari numeric,
  iskonto_tutari numeric, iskonto_yuzde double precision, teklif_tutari numeric, kur varchar, doviz_tutari numeric,
  doviz_kuru varchar, kasa smallint, teslim_sekli smallint, odeme smallint, onay smallint, onaytarihi timestamp,
  onaylayan integer, ustbilgi text, altbilgi text, ozelkod varchar, yetkikodu varchar, bilgi smallint,
  fiyat_listesi smallint, vade smallint, aciklama varchar, ekleyen integer, eklemetarihi timestamp, degistiren integer,
  degistirmetarihi timestamp, projeid integer, rehberiletid integer, subeid smallint, masrafid smallint, dovizkur numeric,
  sablonid integer, ustbilgi2 text, altbilgi2 text, tekliftur smallint, tekliftipi integer, teklifseri varchar,
  kocanno integer, donusumturu integer, yazdirildi smallint, sonuc smallint, cariid integer, sebebi smallint,
  kayipfiyati numeric, kayipkur varchar, giriskaynak smallint, disonay integer, onaylayacak integer, servisid integer,
  teklif_dovizi varchar, doviz_matrahi numeric, doviz_kdv_tutari numeric, doviz_iskonto_tutari numeric, pozno integer,
  projekodu varchar, projeadi varchar, carikod varchar, firma varchar, hazirlayanad varchar, mus_ilgiliad varchar,
  verilensiparis text, alinansiparis text, teklifgunsayisi integer, durumgunsayisi integer, teslimtarihi timestamp,
  onaylayacak2 varchar, gecerlilik_kalan integer, disonayci varchar, sonucad varchar, sebebiad varchar,
  prj_durum smallint, prj_sonuc smallint, prj_sebebi smallint)
LANGUAGE plpgsql STABLE AS $$
#variable_conflict use_column
DECLARE
  j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb,'{}'::jsonb);
  v_topn int := COALESCE(NULLIF(j->>'TopN','')::int,0);
  v_mod int := COALESCE(NULLIF(j->>'Mod','')::int,4);
  v_tarihbas date := NULLIF(j->>'TarihBas','')::date;
  v_tarihbit date := NULLIF(j->>'TarihBit','')::date;
  v_hazirlayan text := NULLIF(j->>'Hazirlayan','');
  v_musteri text := NULLIF(j->>'Musteri','');
  v_konusu text := NULLIF(j->>'Konusu','');
  v_turu int := NULLIF(j->>'Turu','')::int;
  v_belgeno text := NULLIF(j->>'BelgeNo','');
  v_stok text := NULLIF(j->>'Stok','');
  v_durumu int := NULLIF(j->>'Durumu','')::int;
  v_revize int := COALESCE(NULLIF(j->>'Revize','')::int,0);
  v_kabul int := COALESCE(NULLIF(j->>'Kabul','')::int,0);
  v_red int := COALESCE(NULLIF(j->>'Reddedilenler','')::int,0);
  v_subeyetki text := NULLIF(j->>'SubeYetkiList','');
  v_hazzor int := NULLIF(j->>'HazirlayanZorunlu','')::int;
  v_subezor int := NULLIF(j->>'SubeZorunlu','')::int;
  v_kulid int := NULLIF(j->>'KulId','')::int;
  v_modul int := NULLIF(j->>'Modul','')::int;
  v_orderby text := NULLIF(j->>'OrderBy','');
  q text; joinka text := ''; ordr text; dr text; aa text := '';
BEGIN
  q := 'SELECT t.id,t.tarih,t.rehberid,t.revizeid,t.teklifno,t.durumtarihi,t.turu,t.konusu,t.durum,t.olasilik,
    t.gecerlilik_suresi,t.teslim_suresi,t.hazirlayan,t.mus_ilgili,t.kdvdurum,t.teklif_matrahi,t.kdv_tutari,
    t.iskonto_tutari,t.iskonto_yuzde,t.teklif_tutari,t.kur,t.doviz_tutari,t.doviz_kuru,t.kasa,t.teslim_sekli,
    t.odeme,t.onay,t.onaytarihi,t.onaylayan,t.ustbilgi,t.altbilgi,t.ozelkod,t.yetkikodu,t.bilgi,t.fiyat_listesi,
    t.vade,t.aciklama,t.ekleyen,t.eklemetarihi,t.degistiren,t.degistirmetarihi,t.projeid,t.rehberiletid,t.subeid,
    t.masrafid,t.dovizkur,t.sablonid,t.ustbilgi2,t.altbilgi2,t.tekliftur,t.tekliftipi,t.teklifseri,t.kocanno,
    t.donusumturu,t.yazdirildi,t.sonuc,t.cariid,t.sebebi,t.kayipfiyati,t.kayipkur,t.giriskaynak,t.disonay,
    t.onaylayacak,t.servisid,t.teklif_dovizi,t.doviz_matrahi,t.doviz_kdv_tutari,t.doviz_iskonto_tutari,t.pozno,
    p.projekodu::varchar, p.projeadi::varchar, r1.kod::varchar, r1.firma::varchar, r2.firma::varchar, rp.firma::varchar,
    (case when 412 in (select yeri from siparisdetay where yerid in (select id from teklifdetay where teklifid=t.id)) then ''Var'' else '''' end)::text,
    (case when 413 in (select yeri from siparisdetay where yerid in (select id from teklifdetay where teklifid=t.id)) then ''Var'' else '''' end)::text,
    (now()::date - t.tarih::date)::integer,
    (now()::date - t.durumtarihi::date)::integer,
    (select min(teslimtarihi) from teklifdetay where teklifid=t.id)::timestamp,
    r3.firma::varchar,
    (case when coalesce(t.gecerlilik_suresi,0)=0 then 0 else ((t.tarih + make_interval(days=>t.gecerlilik_suresi))::date - now()::date) end)::integer,
    rp2.firma::varchar,
    (select anahtar from genini where bolum=-2911 and deger=t.sonuc and dil=-1)::varchar,
    (select anahtar from genini where bolum=-2912 and deger=t.sebebi and dil=-1)::varchar,
    p.durum::smallint, p.sonuc::smallint, p.sebebi::smallint
    FROM TEKLIF t
      left outer join REHBER r1 on r1.id=t.rehberid
      left outer join REHBER r2 on r2.id=t.hazirlayan
      left outer join REHBER rp on rp.id=t.mus_ilgili
      left outer join PROJELER p on p.id=t.projeid
      left outer join REHBER r3 on t.onaylayacak=r3.id
      left outer join REHBER r4 on t.onaylayan=r4.id
      left outer join REHBER rp2 on t.disonay=rp2.id ';

  IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
    q := q || ' inner join KULLANICI_ARAMA ka on ka.kayitid=t.id and ka.kulid='||v_kulid||' and ka.modul='||v_modul||' ';
  END IF;

  q := q || ' WHERE 1=1 ';
  IF v_tarihbas IS NOT NULL AND v_tarihbit IS NOT NULL THEN
    q := q || ' and (t.tarih between '||quote_literal(v_tarihbas)||' and '||quote_literal(v_tarihbit)||') ';
  END IF;
  IF v_hazirlayan IS NOT NULL THEN q := q || ' and r2.firma ilike '||quote_literal(v_hazirlayan||'%')||' '; END IF;
  IF v_musteri IS NOT NULL THEN q := q || ' and r1.firma ilike '||quote_literal(v_musteri||'%')||' '; END IF;
  IF v_konusu IS NOT NULL THEN q := q || ' and t.konusu ilike '||quote_literal(v_konusu||'%')||' '; END IF;
  IF v_belgeno IS NOT NULL THEN q := q || ' and coalesce(t.teklifno,'''') ilike '||quote_literal('%'||v_belgeno||'%')||' '; END IF;
  IF v_turu IS NOT NULL AND v_turu > 0 THEN q := q || ' and t.turu='||v_turu||' '; END IF;
  IF v_stok IS NOT NULL THEN
    q := q || ' and exists(select 1 from teklifdetay td
        left outer join stoklar s on s.id=td.urunid and td.tur=1
        left outer join masrafgelir mg on mg.id=td.urunid and td.tur=0
       where td.teklifid=t.id and (s.stokadi ilike '||quote_literal('%'||v_stok||'%')||
        ' or s.kod ilike '||quote_literal('%'||v_stok||'%')||
        ' or mg.ad ilike '||quote_literal('%'||v_stok||'%')||
        ' or mg.kod ilike '||quote_literal('%'||v_stok||'%')||')) ';
  END IF;

  IF v_durumu IS NOT NULL AND v_durumu > 0 THEN
    dr := v_durumu::text;
    IF v_revize=1 THEN dr := dr||',5'; END IF;
    IF v_kabul=1 THEN dr := dr||',7'; END IF;
    IF v_red=1 THEN dr := dr||',6'; END IF;
    q := q || ' and t.durum in ('||dr||') ';
  ELSE
    IF v_revize=0 THEN aa := '5'; END IF;
    IF v_kabul=0 THEN aa := CASE WHEN aa='' THEN '7' ELSE aa||',7' END; END IF;
    IF v_red=0 THEN aa := CASE WHEN aa='' THEN '6' ELSE aa||',6' END; END IF;
    IF aa <> '' THEN q := q || ' and t.durum not in ('||aa||') ';
    ELSE q := q || ' and t.durum not in (-1) '; END IF;
  END IF;

  IF v_subeyetki IS NOT NULL AND v_subeyetki ~ '^[0-9, -]+$' THEN q := q || ' and t.subeid in ('||v_subeyetki||') '; END IF;
  IF v_hazzor IS NOT NULL THEN q := q || ' and t.hazirlayan='||v_hazzor||' '; END IF;
  IF v_subezor IS NOT NULL THEN q := q || ' and t.subeid='||v_subezor||' '; END IF;
  q := q || ' and t.tekliftur=80 ';

  IF v_mod=5 THEN ordr := 'ka.degistirmetarihi desc';
  ELSIF v_mod=3 THEN ordr := 'ka.say desc';
  ELSIF v_orderby IS NULL THEN ordr := 't.tarih';
  ELSE ordr := v_orderby; END IF;
  q := q || ' ORDER BY '||ordr;
  IF v_topn > 0 THEN q := q || ' LIMIT '||v_topn; END IF;

  RETURN QUERY EXECUTE q;
END $$;
