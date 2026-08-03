-- fn_MoneyToText (MSSQL dbo.fn_MoneyToText) PG portu: tutari yaziyla (Turkce) verir.
--   Girdi: currency='1234.56' (nokta ondalik), buyukkur='TL'/'Lira'/'€'/'Euro'/'$'/'Dolar',
--   opsiyon: 0=tam (deger+birim+kurus+altbirim), 1=yalniz deger+birim, 2=yalniz kurus+altbirim.
--   SIPARIS/FATBASLIK YAZIYLATOPLAM alaninda kullanilir.

-- Yardimci: yalniz-rakam grup-string'i Turkce yaziya cevirir (MSSQL loop mantiginin birebir portu).
CREATE OR REPLACE FUNCTION public.fn_moneytotext_oku(p_num varchar)
RETURNS varchar
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
  s varchar := coalesce(p_num, '');
  v_uz int; v_yuzde int; v_t int; v_k int; v_index int; v_sayi varchar; v_hane varchar;
  r varchar := '';
BEGIN
  if s = '' then return ''; end if;
  v_uz := length(s) % 3;
  if v_uz <> 0 then s := repeat('0', 3 - v_uz) || s; end if;
  v_yuzde := length(s) / 3;
  v_t := v_yuzde;
  v_k := 1;
  while v_k <= length(s) loop
    v_index := cast(substring(s, v_k, 1) as int);
    if (v_k % 3) = 1 then          -- yuzler
      v_sayi := case v_index when 1 then 'YÜZ ' when 2 then 'İKİ YÜZ ' when 3 then 'ÜÇ YÜZ '
                  when 4 then 'DÖRT YÜZ ' when 5 then 'BEŞ YÜZ ' when 6 then 'ALTI YÜZ '
                  when 7 then 'YEDİ YÜZ ' when 8 then 'SEKİZ YÜZ ' when 9 then 'DOKUZ YÜZ ' else '' end;
    elsif (v_k % 3) = 2 then       -- onlar
      v_sayi := case v_index when 1 then 'ON ' when 2 then 'YİRMİ ' when 3 then 'OTUZ '
                  when 4 then 'KIRK ' when 5 then 'ELLİ ' when 6 then 'ALTMIŞ '
                  when 7 then 'YETMİŞ ' when 8 then 'SEKSEN ' when 9 then 'DOKSAN ' else '' end;
    else                           -- birler
      v_sayi := case v_index when 1 then 'BİR ' when 2 then 'İKİ ' when 3 then 'ÜÇ '
                  when 4 then 'DÖRT ' when 5 then 'BEŞ ' when 6 then 'ALTI '
                  when 7 then 'YEDİ ' when 8 then 'SEKİZ ' when 9 then 'DOKUZ ' else '' end;
    end if;
    r := r || v_sayi;
    v_k := v_k + 1;
    if (v_k % 3) = 1 then          -- grup bitti -> hane eki (BİN/MİLYON/...)
      v_hane := case v_t when 1 then '' when 2 then 'BİN ' when 3 then 'MİLYON '
                  when 4 then 'MİLYAR ' when 5 then 'TRİLYON ' when 6 then 'KATRİLYON ' else '' end;
      r := r || v_hane;
      v_t := v_t - 1;
    end if;
  end loop;
  return r;
END;
$$;

-- NOT: opsiyon 'integer' (smallint DEGIL): cagiranlar 3. arg'i integer geciyor; PG
--   fonksiyon cozumunde integer->smallint IMPLICIT degil (assignment) -> "does not exist".
--   integer imzasi smallint cagricilarini da karsilar (smallint->integer implicit genisleme).
CREATE OR REPLACE FUNCTION public.fn_moneytotext(currency varchar, buyukkur varchar, opsiyon integer DEFAULT 0)
RETURNS varchar
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
  v_buyuk varchar := coalesce(buyukkur, '');
  v_kucuk varchar := '';
  v_int   varchar;
  v_kurus varchar;
  v_pos   int;
  v_deger varchar := '';
  v_kyed  varchar := '';
  v_sonuc varchar := '';
BEGIN
  -- birim adlari
  if v_buyuk = 'TL' then v_buyuk := 'Lira'; v_kucuk := 'Kuruş';
  elsif v_buyuk = 'Lira' then v_kucuk := 'Kuruş';
  elsif v_buyuk = '€' then v_buyuk := 'Euro'; v_kucuk := 'Sent';
  elsif v_buyuk = 'Euro' then v_kucuk := 'Sent';
  elsif v_buyuk = '$' then v_buyuk := 'Dolar'; v_kucuk := 'Sent';
  elsif v_buyuk = 'Dolar' then v_kucuk := 'Sent';
  end if;

  v_pos := position('.' in coalesce(currency, ''));
  if v_pos = 0 then
    v_int := coalesce(currency, '');
    v_kurus := '';
  else
    v_int := left(currency, v_pos - 1);
    v_kurus := substring(currency from v_pos + 1 for 2);
  end if;

  v_deger := public.fn_moneytotext_oku(v_int);
  v_kyed  := public.fn_moneytotext_oku(v_kurus);

  if v_deger like 'BİR BİN%' then          -- 'BİR BİN...' -> 'BİN...'
    v_deger := 'BİN' || substring(v_deger from 8);
  end if;
  -- Turkce kucuk harf: I->ı, İ->i (translate ile; standart lower I->i verirdi -> 'alti' yerine 'altı')
  if v_deger <> '' then v_deger := upper(left(v_deger,1)) || lower(translate(substring(v_deger from 2), 'Iİ', 'ıi')); end if;
  if v_kyed  <> '' then v_kyed  := upper(left(v_kyed,1))  || lower(translate(substring(v_kyed  from 2), 'Iİ', 'ıi')); end if;

  if opsiyon = 0 then
    if v_kyed <> '' then v_sonuc := v_deger || ' ' || v_buyuk || ' ' || v_kyed || ' ' || v_kucuk;
    else v_sonuc := v_deger || ' ' || v_buyuk; end if;
  elsif opsiyon = 1 then
    if v_deger <> '' then v_sonuc := v_deger || ' ' || v_buyuk; else v_sonuc := ''; end if;
  elsif opsiyon = 2 then
    if v_kyed <> '' then v_sonuc := v_kyed || ' ' || v_kucuk; else v_sonuc := ''; end if;
  end if;

  return v_sonuc;
END;
$$;

-- Overload: MSSQL money/numeric -> varchar implicit cast PG'de YOK. SIPARIS/FATBASLIK
--   fn_MoneyToText(TUTAR numeric, KUR, 0) cagirir -> numeric'i '1234.56' formatina cevirip delege et.
CREATE OR REPLACE FUNCTION public.fn_moneytotext(currency numeric, buyukkur varchar, opsiyon integer DEFAULT 0)
RETURNS varchar LANGUAGE sql IMMUTABLE AS $$
  select public.fn_moneytotext(to_char(coalesce(currency,0), 'FM9999999999999990.00'), buyukkur, opsiyon);
$$;
