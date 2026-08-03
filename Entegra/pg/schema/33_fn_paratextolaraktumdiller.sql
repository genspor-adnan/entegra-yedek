-- fn_ParaTextOlarakTumDiller PG portu (MSSQL dbo.* karsiligi).
--   @Dil=-1 Turkce -> fn_moneytotext (portlu, [[pg-alanolustur-fn-moneytotext]]).
--   @Dil=-2 English -> MSSQL fn_Num_ToWords; PG'ye portlanmadi (makbuz -1 kullanir) -> '' (bos).
--   Diger -> ''. Makbuz toplam satiri (tabMakbuzToplam) YAZIYLATOPLAMDOVIZ icin cagirir.
CREATE OR REPLACE FUNCTION public.fn_paratextolaraktumdiller(
  tutar numeric, parabirimi varchar, kurusbirimi varchar, opsiyon integer, dil integer)
RETURNS varchar
AS $$
begin
  if dil = -1 then
    return public.fn_moneytotext(coalesce(tutar,0), parabirimi, opsiyon);   -- Turkce (numeric overload)
  else
    return '';   -- -2 (English/fn_Num_ToWords) ve digerleri: portlanmadi
  end if;
end $$ language plpgsql immutable;
