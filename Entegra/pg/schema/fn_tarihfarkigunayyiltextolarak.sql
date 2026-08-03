CREATE OR REPLACE FUNCTION public.fn_tarihfarkigunayyiltextolarak(baslangic timestamp, bitis timestamp)
RETURNS varchar
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    d1 date;
    d2 date;
    sign_text text := '';
    years int;
    months int;
    days int;
BEGIN
    IF baslangic IS NULL OR bitis IS NULL THEN
        RETURN NULL;
    END IF;

    d1 := baslangic::date;
    d2 := bitis::date;

    IF d2 < d1 THEN
        sign_text := '-';
        d1 := bitis::date;
        d2 := baslangic::date;
    END IF;

    years := date_part('year', age(d2, d1))::int;
    months := date_part('month', age(d2, d1))::int;
    days := date_part('day', age(d2, d1))::int;

    RETURN sign_text || years::text || ' yil ' || months::text || ' ay ' || days::text || ' gun';
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_tarihfarkigunayyiltextolarak(baslangic timestamp with time zone, bitis timestamp)
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT public.fn_tarihfarkigunayyiltextolarak(baslangic::timestamp, bitis);
$$;

CREATE OR REPLACE FUNCTION public.fn_tarihfarkigunayyiltextolarak(baslangic timestamp, bitis timestamp with time zone)
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT public.fn_tarihfarkigunayyiltextolarak(baslangic, bitis::timestamp);
$$;

CREATE OR REPLACE FUNCTION public.fn_tarihfarkigunayyiltextolarak(baslangic timestamp with time zone, bitis timestamp with time zone)
RETURNS varchar
LANGUAGE sql
STABLE
AS $$
    SELECT public.fn_tarihfarkigunayyiltextolarak(baslangic::timestamp, bitis::timestamp);
$$;
