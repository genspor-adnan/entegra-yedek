DROP FUNCTION IF EXISTS public.fn_prg_servis_yeni(int, int, int, text, timestamp, text, int, int);
CREATE FUNCTION public.fn_prg_servis_yeni(
    p_rehberid int,
    p_subeid int,
    p_ekleyen int,
    p_konusu text,
    p_tarih timestamp,
    p_notlar text DEFAULT '',
    p_yeri int DEFAULT 0,
    p_yer_id int DEFAULT 0
)
RETURNS TABLE(id int)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
    v_kocanno int;
    v_servisseri varchar(20);
    v_servisno varchar(20);
    v_basldurumu int;
    v_servisid int;
    v_subeyazi varchar(2);
BEGIN
    SELECT b.kocanno, b.belgeseri, b.belgeno
      INTO v_kocanno, v_servisseri, v_servisno
      FROM fn_belgenogetir(83, p_subeid, 0, p_tarih) b
      LIMIT 1;

    SELECT min(g.deger) INTO v_basldurumu
      FROM genini g
      WHERE g.bolum = -3007;

    v_subeyazi := lpad(abs(p_subeid)::text, 2, '0');

    INSERT INTO servis(
        baslamatarihi, rehberid, kocanno, servisseri, servisno, konusu, durum, subeid, ekleyen,
        kapsam, tarih, ackapa, yeri, yerid, acil, onemli, disservis, demirbas, fiyat_listesi, depo, notlar
    )
    VALUES(
        p_tarih, p_rehberid, v_kocanno::varchar, v_servisseri, v_servisno, p_konusu, v_basldurumu::smallint, p_subeid::smallint, p_ekleyen::smallint,
        1, p_tarih, 0, p_yeri, p_yer_id, 0, 0, 0, 0,
        COALESCE((SELECT g.deger FROM genini g WHERE g.bolum = ('-77'||v_subeyazi||'05')::int LIMIT 1), 0)::smallint,
        COALESCE((SELECT g.deger FROM genini g WHERE g.bolum = -1006 LIMIT 1), 0)::smallint,
        p_notlar
    )
    RETURNING servis.id INTO v_servisid;

    INSERT INTO servishareket(servisid, baslama, personel, durum, acilis, kapanis, ekleyen)
    VALUES(v_servisid, p_tarih, p_ekleyen, v_basldurumu::smallint, 1, 0, p_ekleyen::smallint);

    RETURN QUERY SELECT v_servisid;
END;
$$;
