-- ============================================================
-- fn_prog_cari_liste_json2 — MSSQL sp_Prog_Cari_Liste_Json2 PG portu
-- ------------------------------------------------------------
-- Cari/Rehber liste ekrani. Iki param: @Baslik (SubSelectGetir ile app-uretimi SELECT
--   kolon fragmenti) + @Kosullar (JSON filtreler). MSSQL SP TAMAMEN dinamik SQL kurar.
--
-- PG UYARLAMA NOTU (onemli): app 'SELECT * FROM fn_prog_cari_liste_json2(:Baslik,:Kosullar)'
--   cagirir -> PG fonksiyonu SABIT RETURNS TABLE yapisina sahip olmali; dinamik @Baslik ile
--   kolon SAYISI degistirilemez (record dondurmeden). Bu yuzden @Baslik'i enjekte etmek
--   yerine, SubSelectGetir'in uretebilecegi TUM kolonlarin BIRLESIMI (base + analiz + detay)
--   sabit RETURNS TABLE olarak dondurulur; grid ihtiyaci olan kolonlari (BorcAlacakKolonlari/
--   CheckDetay ile) gorunur/gizli yapar. (10_fn_prog_dokuman_liste_json2 ile ayni desen.)
--   -> @Baslik param'i kabul edilir ama govdede KULLANILMAZ (parite: satir kumesi ayni).
--
-- @Variant SATIR KUMESINI degistirir: Variant=1 (analiz/BA) FROM = finansal hareket
--   agregasyonu INNER JOIN REHBER (yalniz hareketi olan cariler); Variant=0 FROM = REHBER R
--   (tum cariler). Iki dal ayri kurulur, ikisi de ayni 38-kolon SUPERSET'i doldurur
--   (yoklar NULL). Analiz kolonlari yalniz Variant=1'de gercek; detay kolonlari Variant=0'da.
--
-- MSSQL->PG: JSON_VALUE->->>, ISNULL/TRY_CAST->COALESCE/NULLIF+cast, bit->smallint(=1),
--   TOP N->LIMIT N, TOP1 subquery->ORDER BY..LIMIT 1, OUTER APPLY->LEFT JOIN LATERAL,
--   LIKE(CI)->ILIKE, N'%'+x+'%'->quote_literal('%'||x||'%'), CONVERT(datetime,style)->to_char,
--   ''+cast(x as varchar)->||, getdate()->now(). Metin filtreler quote_literal (injection yok);
--   int filtreler ::int parse edilip inline; SubeList app-uretimi int-listesi inline.
-- ============================================================
DROP FUNCTION IF EXISTS public.fn_prog_cari_liste_json2(text, text);
CREATE FUNCTION public.fn_prog_cari_liste_json2(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS TABLE(
    id integer, kod varchar, firma varchar, adsoyad text, fatbaslik text,
    grup smallint, temas integer, sektor smallint, kategori smallint, sinif integer,
    durum smallint, ozelkod varchar, temsilciad text,
    toplam_borc numeric, toplam_alacak numeric, kur text, bakiye numeric,
    takipte numeric, irsaliye numeric,
    altsektor text, iller text, adres text, ilce text, il text, ulke text, gsm text,
    vergino text, bolge smallint, altbolge text, subeid smallint, notlar text,
    yetkikodu varchar, muhkodu varchar, eklemetarihi timestamp,
    sonaktivitekonusu text, sonaktivitetarihi text, sonsatbelgetarihi text, sonsattutari numeric
)
LANGUAGE plpgsql STABLE AS $fn$
DECLARE
    j jsonb := COALESCE(NULLIF(kosullar,'')::jsonb, '{}'::jsonb);
    v_variant   int  := COALESCE(NULLIF(j->>'Variant','')::int, 0);
    v_topn      int  := COALESCE(NULLIF(j->>'TopN','')::int, 200);
    v_mod       int  := COALESCE(NULLIF(j->>'Mod','')::int, 4);
    v_ilgili    int  := COALESCE(NULLIF(j->>'IlgiliArama','')::int, 0);
    v_kulid     int  := NULLIF(j->>'KulId','')::int;
    v_modul     int  := COALESCE(NULLIF(j->>'Modul','')::int, 22);
    v_arafirma   text := NULLIF(j->>'AraFirma','');
    v_arayetkili text := NULLIF(j->>'AraYetkili','');
    v_arakod     text := NULLIF(j->>'AraKod','');
    v_araozelkod text := NULLIF(j->>'AraOzelKod','');
    v_arailler   text := NULLIF(j->>'Arailler','');
    v_temsilciad text := NULLIF(j->>'TemsilciAd','');
    v_temsilciid int  := NULLIF(j->>'TemsilciID','')::int;
    v_grupid     int  := NULLIF(j->>'GrupID','')::int;
    v_bolgeid    int  := NULLIF(j->>'BolgeID','')::int;
    v_kategoriid int  := NULLIF(j->>'KategoriID','')::int;
    v_sinifid    int  := NULLIF(j->>'SinifID','')::int;
    v_pasifler   int  := COALESCE(NULLIF(j->>'Pasifler','')::int, 0);
    v_aksiyon    int  := COALESCE(NULLIF(j->>'AksiyonFrame','')::int, 0);
    v_potansiyel int  := COALESCE(NULLIF(j->>'Potansiyel','')::int, 0);
    v_subelist   text := NULLIF(j->>'SubeList','');
    v_teksubetum int  := COALESCE(NULLIF(j->>'TekSubeTum','')::int, 0);
    v_subeid     int  := NULLIF(j->>'SubeId','')::int;
    v_ekipman    int  := COALESCE(NULLIF(j->>'EkipmanFiltre','')::int, 0);
    v_analizw    int  := COALESCE(NULLIF(j->>'AnalizWhere','')::int, 0);
    v_ordercol   int  := COALESCE(NULLIF(j->>'OrderCol','')::int, 0);
    v_bastarih   text := to_char(now(),'YYYY') || '-01-01 00:00:00';
    v_sel   text;   -- kolon projeksiyonu (variant'a gore)
    v_from  text;   -- FROM iskeleti (variant'a gore)
    v_pcond text;   -- P (ilgili) join kosulu
    v_trail text;   -- ortak trailing joinler (R2, X1)
    v_sql   text;
BEGIN
    -- ilgili (yetkili) join kosulu — @IlgiliArama app'te param
    v_pcond := ' left outer join rehber p on r.id = p.bagid and 1 = case when '
             || v_ilgili || ' = 1 then 1 when ' || v_ilgili
             || ' = 0 and coalesce(p.statu,1) = 1 then 1 else 0 end ';

    -- ortak trailing joinler (R2 temsilci, X1 = OUTER APPLY top1 REHBERBILGI)
    v_trail := '
        left outer join rehber r2 on r2.id = r.temsilci
        left join lateral ( select rb.bilgi from rehberbilgi rb
              inner join rehberayar ra on ra.yeri = 2 and ra.sira = rb.sira and ra.yeri = rb.yeri and ra.varsayilan = 10
              where rb.yer_id = r.id limit 1 ) x1 on true ';

    IF v_variant = 1 THEN
        -- ---- analiz/BA dali: agregasyon INNER JOIN REHBER ----
        v_sel := '
            r.id::int, r.kod::varchar, r.firma::varchar,
            coalesce(p.firma, (select pa.firma from rehber pa where pa.bagid = r.id and pa.grup = 334 order by pa.statu desc, pa.id limit 1))::text as adsoyad,
            x1.bilgi::text as fatbaslik,
            r.grup::smallint, r.temas::int, r.sektor::smallint, r.kategori::smallint, r.sinif::int, r.durum::smallint, r.ozelkod::varchar,
            r2.firma::text as temsilciad,
            dsa.toplam_borc::numeric, dsa.toplam_alacak::numeric, dsa.kur::text,
            (dsa.toplam_borc - dsa.toplam_alacak)::numeric as bakiye, dsa.takipte::numeric, dsa.irsaliye::numeric,
            null::text as altsektor, null::text as iller, null::text as adres, null::text as ilce, null::text as il,
            null::text as ulke, null::text as gsm, null::text as vergino, r.bolge::smallint, null::text as altbolge,
            r.subeid::smallint, null::text as notlar, r.yetkikodu::varchar, r.muhkodu::varchar, r.eklemetarihi::timestamp,
            null::text as sonaktivitekonusu, null::text as sonaktivitetarihi, null::text as sonsatbelgetarihi, null::numeric as sonsattutari ';

        v_from := '
        from (
            select rehberid,
                   sum(coalesce(borc,0))       as toplam_borc,
                   sum(coalesce(alacak,0))     as toplam_alacak,
                   abs(sum(coalesce(takipte,0)))  as takipte,
                   abs(sum(coalesce(irsaliye,0))) as irsaliye,
                   coalesce(kur,''TL'')        as kur
            from (
                select rehberid,
                       sum(case when ekstredekullan=1 then doviz_tutari else f.fatura_tutari end) as borc,
                       0 as alacak,
                       case when ekstredekullan=1 then doviz_cinsi else kur end as kur,
                       0 as takipte, 0 as irsaliye
                from fatbaslik f
                where coalesce(f.durum,0)<>6 and (f.tur in (15,16,17)) and faturatarih >= ''' || v_bastarih || '''
                group by f.rehberid, case when ekstredekullan=1 then doviz_cinsi else kur end
                union all
                select fb.rehberid, 0 as borc, 0 as alacak,
                       case when fb.ekstredekullan = 1 then fb.doviz_cinsi else fb.kur end as kur,
                       0 as takipte,
                       cast(sum(case when fb.ekstredekullan = 1 then case when f.doviz_kuru <> ''TL'' then f.doviz_birimfiyat * (1 - iskonto / 100.0) * (f.adet - coalesce(f1.fatura_adet, 0)) * (1 + coalesce(f.kdv, 10) / 100.0) else ((f.iskontolubrmfiyat * (f.adet - coalesce(f1.fatura_adet, 0)) * (1 + coalesce(f.kdv, 10) / 100.0)))/fb.dovizkur end else f.iskontolubrmfiyat * (f.adet - coalesce(f1.fatura_adet, 0)) * (1 + coalesce(f.kdv, 10) / 100.0) end) as numeric(18,2)) as irsaliye
                from fatbaslik fb
                     inner join fatura f on f.fatbasid = fb.id
                     left join (select yerid, sum(adet) as fatura_adet from fatura where yeri in (411,424) group by yerid ) f1 on f1.yerid = f.id
                where coalesce(fb.durum, 0) <> 6 and fb.tur = 14
                group by fb.rehberid, fb.ekstredekullan, fb.doviz_cinsi, fb.kur
                union all
                select rehberid, 0 as borc,
                       sum(case when ekstredekullan=1 then doviz_tutari else f.fatura_tutari end) as alacak,
                       case when ekstredekullan=1 then doviz_cinsi else kur end as kur,
                       0 as takipte, 0 as irsaliye
                from fatbaslik f
                where coalesce(f.durum,0)<>6 and (f.tur in (8,11,12,13)) and faturatarih >= ''' || v_bastarih || '''
                group by f.rehberid, case when ekstredekullan=1 then doviz_cinsi else kur end
                union all
                select rehberid,
                       sum(case when coalesce(k.borc,0)>0 and ekstredekullan=1 then k.doviz_tutari else k.borc end) as borc,
                       sum(case when coalesce(k.alacak,0)>0 and ekstredekullan=1 then k.doviz_tutari else k.alacak end) as alacak,
                       case when ekstredekullan=1 then doviz_kuru else kur end as kur,
                       0 as takipte, 0 as irsaliye
                from kasa k
                where tur not between 60 and 79 and islemtarihi >= ''' || v_bastarih || '''
                group by k.rehberid, case when ekstredekullan=1 then doviz_kuru else kur end
                union all
                select ch.rehberid,
                       sum(case when ch.islem in(140,131,132,133,134,137) then (case when ch.ekstredekullan=1 then ch.tutar else coalesce(c.tutar,0) end) else 0 end) as borc,
                       sum(case when ch.islem in(130,141) then (case when ch.ekstredekullan=1 then ch.tutar else coalesce(c.tutar,0) end) else 0 end) as alacak,
                       case when ch.ekstredekullan=1 then ch.kur else coalesce(c.kur,''TL'') end as kur,
                       0 as takipte, 0 as irsaliye
                from cekler c inner join cekhareket ch on c.id=ch.ceksenetlerid
                where ch.islem in(130,131,132,134,137,140,141) and ch.tarih >= ''' || v_bastarih || '''
                group by ch.rehberid, ch.islem, ch.ekstredekullan, case when ch.ekstredekullan=1 then ch.kur else coalesce(c.kur,''TL'') end
                union all
                select c.rehberid, 0 as borc, 0 as alacak,
                       case when c.ekstredekullan=1 then c.doviz_kuru else coalesce(c.kur,''TL'') end as kur,
                       sum(case when c.tur in(131,132,133,134,137) then (case when c.ekstredekullan=1 then c.doviz_tutari else coalesce(c.tutar,0) end) else 0 end)
                         - sum(case when c.tur in(130) then (case when c.ekstredekullan=1 then c.doviz_tutari else coalesce(c.tutar,0) end) else 0 end) as takipte,
                       0 as irsaliye
                from cekler c
                where c.ceksenet in (101,121) and c.tur in (130,131,132,133,134,135,138)
                      and exists(select 1 from cekhareket ch where ch.ceksenetlerid = c.id)
                group by c.rehberid, c.ekstredekullan, c.doviz_kuru, coalesce(c.kur,''TL'')
                union all
                select rehberid, 0 as borc,
                       sum(case when ekstredekullan=1 then s.doviz_tutari else tutar end) as alacak,
                       case when ekstredekullan=1 then s.doviz_kuru else kur end as kur,
                       0 as takipte, 0 as irsaliye
                from senetler s
                where tur = 24 and tarih >= ''' || v_bastarih || '''
                group by s.rehberid, case when ekstredekullan=1 then s.doviz_kuru else kur end
                union all
                select rehberid,
                       sum(case when ekstredekullan=1 then s.doviz_tutari else tutar end) as borc,
                       0 as alacak,
                       case when ekstredekullan=1 then s.doviz_kuru else kur end as kur,
                       0 as takipte, 0 as irsaliye
                from senetler s
                where tur = 34 and tarih >= ''' || v_bastarih || '''
                group by s.rehberid, case when ekstredekullan=1 then s.doviz_kuru else kur end
            ) as asd
            group by rehberid, kur
        ) as dsa
            inner join rehber r on dsa.rehberid = r.id '
            || v_pcond || v_trail;
    ELSE
        -- ---- normal dal: FROM REHBER R (tum cariler), detay kolonlari gercek ----
        v_sel := '
            r.id::int, r.kod::varchar, r.firma::varchar,
            coalesce(p.firma, (select pa.firma from rehber pa where pa.bagid = r.id and pa.grup = 334 order by pa.statu desc, pa.id limit 1))::text as adsoyad,
            x1.bilgi::text as fatbaslik,
            r.grup::smallint, r.temas::int, r.sektor::smallint, r.kategori::smallint, r.sinif::int, r.durum::smallint, r.ozelkod::varchar,
            r2.firma::text as temsilciad,
            null::numeric as toplam_borc, null::numeric as toplam_alacak, null::text as kur,
            null::numeric as bakiye, null::numeric as takipte, null::numeric as irsaliye,
            (select g.anahtar from genini g where g.dil=-1 and g.deger = r.altsektor and g.bolum = cast(''-2204''||cast(r.sektor as varchar(10)) as int))::text as altsektor,
            x1.bilgi::text as iller,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=1 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=ri.id and ra.varsayilan=2 limit 1)::text as adres,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=1 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=ri.id and ra.varsayilan=6 limit 1)::text as ilce,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=1 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=ri.id and ra.varsayilan=8 limit 1)::text as il,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=1 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=ri.id and ra.varsayilan=9 limit 1)::text as ulke,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=1 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=ri.id and ra.varsayilan=42 limit 1)::text as gsm,
            (select rb.bilgi from rehberbilgi rb inner join rehberayar ra on ra.yeri=2 and ra.sira=rb.sira and ra.yeri=rb.yeri inner join rehberiletisim ri on r.id=ri.rehberid and ri.varsayilan=1 where rb.yer_id=r.id and ra.varsayilan=22 limit 1)::text as vergino,
            r.bolge::smallint,
            (select g.anahtar from genini g where g.dil=-1 and g.deger = r.altbolge and g.bolum = cast(''-2210''||cast(r.bolge as varchar(10)) as int))::text as altbolge,
            r.subeid::smallint,
            (select gy.yorum from gorevyorum gy where r.id=gy.gorevid and gy.tur=11 order by gy.tarih desc limit 1)::text as notlar,
            r.yetkikodu::varchar, r.muhkodu::varchar, r.eklemetarihi::timestamp,
            (select konusu from gorevler a where a.rehberid=r.id order by bitistarihi desc limit 1)::text as sonaktivitekonusu,
            (select to_char(bitistarihi,''MM/DD/YYYY'') from gorevler a where a.rehberid=r.id order by bitistarihi desc limit 1)::text as sonaktivitetarihi,
            (select to_char(faturatarih,''DD/MM/YYYY'') from fatbaslik f where f.tur in (10,11,12,14,15,16) and f.rehberid=r.id order by faturatarih desc limit 1)::text as sonsatbelgetarihi,
            (select fatura_tutari from fatbaslik f where f.tur in (10,11,12,14,15,16) and f.rehberid=r.id order by faturatarih desc limit 1)::numeric as sonsattutari ';

        v_from := ' from rehber r ' || v_pcond || v_trail;
    END IF;

    v_sql := ' select ' || v_sel || v_from;

    -- @Mod=3/5: Son/Sik -> KULLANICI_ARAMA inner join
    IF v_mod IN (3,5) AND v_kulid IS NOT NULL AND v_modul IS NOT NULL THEN
        v_sql := v_sql || ' inner join kullanici_arama ka on ka.kayitid = r.id and ka.kulid = '
               || v_kulid || ' and ka.modul = ' || v_modul || ' ';
    END IF;

    -- ortak WHERE cekirdegi
    v_sql := v_sql || ' where r.grup<>334 and r.grup<>335 and r.id > 1 ';

    -- @Mod bazli WHERE
    IF v_mod = 4 THEN
        IF v_arafirma IS NOT NULL THEN
            v_sql := v_sql || ' and ( r.firma ILIKE ' || quote_literal('%'||v_arafirma||'%')
                   || ' or x1.bilgi ILIKE ' || quote_literal('%'||v_arafirma||'%') || ' ) ';
        END IF;
        IF v_arayetkili IS NOT NULL THEN
            v_sql := v_sql || ' and p.firma ILIKE ' || quote_literal('%'||v_arayetkili||'%') || ' ';
        END IF;
        IF v_arakod IS NOT NULL THEN
            v_sql := v_sql || ' and r.kod ILIKE ' || quote_literal('%'||v_arakod||'%') || ' ';
        END IF;

        IF v_aksiyon = 1 AND v_potansiyel = 0 THEN
            v_sql := v_sql || ' and r.grup = 1 ';
        ELSE
            IF v_grupid IS NOT NULL AND v_grupid > 0 THEN
                v_sql := v_sql || ' and r.grup = ' || v_grupid || ' ';
            ELSE
                v_sql := v_sql || ' and r.grup<>334 and r.grup<>335 ';
            END IF;
            IF v_potansiyel = 0 THEN
                v_sql := v_sql || ' and r.grup > 1 ';
            END IF;
        END IF;

        IF v_bolgeid IS NOT NULL AND v_bolgeid > 0 THEN
            v_sql := v_sql || ' and r.bolge = ' || v_bolgeid || ' ';
        END IF;
        IF v_arailler IS NOT NULL THEN
            v_sql := v_sql || ' and x1.bilgi = ' || quote_literal(v_arailler) || ' ';
        END IF;
        IF v_temsilciad IS NOT NULL THEN
            IF v_temsilciid IS NOT NULL AND v_temsilciid > 0 THEN
                v_sql := v_sql || ' and r.temsilci = ' || v_temsilciid || ' ';
            ELSE
                v_sql := v_sql || ' and r2.firma ILIKE ' || quote_literal(v_temsilciad||'%') || ' ';
            END IF;
        END IF;
        IF v_pasifler = 0 THEN
            v_sql := v_sql || ' and r.durum > 0 ';
        END IF;
        IF v_subelist IS NOT NULL THEN
            v_sql := v_sql || ' and r.subeid in(' || v_subelist || ') ';
        END IF;
        IF v_kategoriid IS NOT NULL AND v_kategoriid > 0 THEN
            v_sql := v_sql || ' and r.kategori = ' || v_kategoriid || ' ';
        END IF;
        IF v_sinifid IS NOT NULL AND v_sinifid > 0 THEN
            v_sql := v_sql || ' and r.sinif = ' || v_sinifid || ' ';
        END IF;
        IF v_araozelkod IS NOT NULL THEN
            v_sql := v_sql || ' and r.ozelkod ILIKE ' || quote_literal(v_araozelkod||'%') || ' ';
        END IF;
        IF v_teksubetum = 1 THEN
            v_sql := v_sql || ' and r.temsilci = ' || COALESCE(v_kulid,0) || ' ';
        ELSIF v_teksubetum = 10 THEN
            v_sql := v_sql || ' and r.subeid = ' || COALESCE(v_subeid,0) || ' ';
        END IF;
        IF v_ekipman = 1 THEN
            v_sql := v_sql || ' and r.id in (select distinct rehberid from ekipmanrehber) ';
        END IF;

        -- BA analiz where (dsa.* agregasyon kolonlari)
        IF v_analizw IN (1,3) THEN
            v_sql := v_sql || ' and r.id is not null and ((coalesce(dsa.toplam_borc,0.0) - coalesce(dsa.toplam_alacak,0.0)) > 1.0 or dsa.takipte > 1.0 or dsa.irsaliye > 1.0) ';
        ELSIF v_analizw IN (2,4) THEN
            v_sql := v_sql || ' and r.id is not null and (coalesce(dsa.toplam_alacak,0.0) - coalesce(dsa.toplam_borc,0.0)) > 1.0 ';
        END IF;
    ELSIF v_mod = 1 THEN
        IF v_pasifler = 0 THEN
            v_sql := v_sql || ' and r.durum > 0 ';
        END IF;
        IF v_subelist IS NOT NULL THEN
            v_sql := v_sql || ' and r.subeid in(' || v_subelist || ') ';
        END IF;
        IF v_aksiyon = 1 THEN
            v_sql := v_sql || ' and r.grup = 1 ';
        ELSE
            v_sql := v_sql || ' and r.grup > 1 ';
        END IF;
        v_sql := v_sql || ' and r.grup <> 334 ';
    ELSIF v_mod IN (3,5) THEN
        IF v_subelist IS NOT NULL THEN
            v_sql := v_sql || ' and r.subeid in(' || v_subelist || ') ';
        END IF;
        IF v_aksiyon = 1 THEN
            v_sql := v_sql || ' and r.grup = 1 ';
        ELSE
            v_sql := v_sql || ' and r.grup > 1 ';
        END IF;
        v_sql := v_sql || ' and r.grup <> 334 ';
    END IF;

    -- ORDER BY (CRM sarmalama satir kumesini degistirmez -> atlanir)
    IF v_mod = 5 THEN
        v_sql := v_sql || ' order by ka.degistirmetarihi desc ';
    ELSIF v_mod = 3 THEN
        v_sql := v_sql || ' order by ka.say desc ';
    ELSIF v_mod = 1 THEN
        v_sql := v_sql || ' order by 1 ';
    ELSIF v_mod = 4 THEN
        IF v_variant = 1 THEN
            v_sql := v_sql || ' order by kur ';
        ELSIF v_ordercol = 1 THEN
            v_sql := v_sql || ' order by kod ';
        ELSE
            v_sql := v_sql || ' order by firma ';
        END IF;
    END IF;

    -- @Top (SP her zaman top(TopN) uygular; TopN>0)
    IF v_topn > 0 THEN
        v_sql := v_sql || ' limit ' || v_topn;
    END IF;

    RETURN QUERY EXECUTE v_sql;
END $fn$;
