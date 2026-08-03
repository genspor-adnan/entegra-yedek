-- ============================================================================
-- fn_GT_Tatilmi / fn_GT_UygunTarihBul PG portu (MSSQL dbo.* karsiligi)
--   Cek/kasa odeme tarihini tatil gunlerinden kaydirmak icin kullanilir.
--   MSSQL fn_GT_Tatilmi Ramazan/Kurban Bayrami'ni CONVERT(nchar,@Tarih,131)
--   (Hicri takvim, style 131) ile bulur. PG'de Hicri yok -> Kuwaiti tabular
--   algoritma + 1 gun (SQL Server style 131 = Kuwaiti +1). 2025-2027 boyunca
--   MSSQL fn_GT_Tatilmi=1 gun listesiyle BIREBIR dogrulandi (iki bayram dahil).
-- ============================================================================

-- Gregoryen -> Hicri (Kuwaiti tabular; SQL Server style 131 icin +1 gun).
CREATE OR REPLACE FUNCTION public.fn_gt_hicri(gd date, out hy int, out hm int, out hd int)
AS $$
declare jdn bigint; l bigint; n bigint; j bigint;
begin
  jdn := to_char(gd,'J')::bigint + 1;   -- Julian Day + 1 (style 131 uyumu)
  l := jdn - 1948440 + 10632;
  n := (l - 1) / 10631;
  l := l - 10631*n + 354;
  j := ((10985 - l)/5316)*((50*l)/17719) + (l/5670)*((43*l)/15238);
  l := l - ((30 - j)/15)*((17719*j)/50) - (j/16)*((15238*j)/43) + 29;
  hm := (24*l)/709;
  hd := (l - (709*hm)/24)::int;
  hy := (30*n + j - 30)::int;
end $$ language plpgsql immutable;

-- Verilen tarih tatil mi? (1/0). Cumartesi/pazar + sabit resmi + hicri bayram.
CREATE OR REPLACE FUNCTION public.fn_gt_tatilmi(atarih timestamp)
RETURNS smallint
AS $$
declare gd date := atarih::date; hm int; hd int;
begin
  if extract(dow from gd) in (0,6) then return 1; end if;    -- pazar(0)/cumartesi(6)
  select h.hm, h.hd into hm, hd from public.fn_gt_hicri(gd) h;
  if hm=10 and hd in (2,3,4)       then return 1; end if;    -- Ramazan Bayrami 1-3
  if hm=12 and hd in (10,11,12,13) then return 1; end if;    -- Kurban Bayrami 1-4
  -- Sabit Gregoryen bayramlar: Yilbasi / 23 Nisan / 19 Mayis / 30 Agustos / 29 Ekim
  if to_char(gd,'MM-DD') in ('01-01','04-23','05-19','08-30','10-29') then return 1; end if;
  return 0;
end $$ language plpgsql immutable;

-- Tatilse OnceSonra (>0 sonraki, <0 onceki) yonunde ilk is gununu bulur.
CREATE OR REPLACE FUNCTION public.fn_gt_uyguntarihbul(atarih timestamp, oncesonra integer)
RETURNS timestamp
AS $$
declare yt timestamp := atarih;
begin
  if oncesonra <> 0 then
    while public.fn_gt_tatilmi(yt) = 1 loop
      yt := yt + (oncesonra || ' day')::interval;
    end loop;
  end if;
  return yt;
end $$ language plpgsql immutable;
