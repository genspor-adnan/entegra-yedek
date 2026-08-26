-- Gentegre PG migration
-- Belge donusum MSSQL sp_Prog_* adlari icin PG uyumluluk katmani.
-- PG pilotta ana donusum yolu fn_api_belge_donusum_json icinde birlestirilmistir.

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_uygula_json2(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql VOLATILE AS $$
  SELECT public.fn_api_belge_donusum_json(kosullar);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_dogrula(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT public.fn_api_donusum_kontrol_json(kosullar);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_kaynakbelge(baslik text DEFAULT '', kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_data jsonb;
BEGIN
  SELECT COALESCE(jsonb_agg(to_jsonb(x)), '[]'::jsonb)
    INTO v_data
  FROM public.fn_prog_belgedonusum_kaynak_json2(baslik, kosullar) x;

  RETURN jsonb_build_object('Sonuc', 1, 'Data', v_data)::text;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_hedefbelge(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT public.fn_api_donusum_rapor_json(kosullar);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_kopukzincir_rapor(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT public.fn_api_donusum_rapor_json(kosullar);
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_donusum_satiradetkontrol(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE sql STABLE AS $$
  SELECT public.fn_api_donusum_kontrol_json(kosullar);
$$;

-- MSSQL'de ana islem icinden cagrilan parca prosedurleri. PG pilotta parcalara
-- ayrilmadi; tek basina cagrilirsa sessiz basarili saymak veri tutarliligi icin riskli.
CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_kaydet(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  RAISE EXCEPTION 'PG pilotta BelgeDonusum_Kaydet ayri adim degil; fn_prog_belgedonusum_uygula_json2 / fn_api_belge_donusum_json kullanin.' USING ERRCODE='P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_izlemeaktar(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  RAISE EXCEPTION 'PG pilotta BelgeDonusum_IzlemeAktar ayri adim olarak desteklenmiyor; ana donusum fonksiyonunu kullanin.' USING ERRCODE='P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_uretimaktar(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  RAISE EXCEPTION 'PG pilotta BelgeDonusum_UretimAktar ayri adim olarak desteklenmiyor; ana donusum fonksiyonunu kullanin.' USING ERRCODE='P0001';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_prog_belgedonusum_sonlandir(kosullar text DEFAULT '{}')
RETURNS text
LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  RAISE EXCEPTION 'PG pilotta BelgeDonusum_Sonlandir ayri adim olarak desteklenmiyor; ana donusum fonksiyonunu kullanin.' USING ERRCODE='P0001';
END;
$$;
