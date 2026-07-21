CREATE OR REPLACE VIEW public.ililce AS
select ilno, ilceno, iladi, ilceadi
from (
    select ilno, ilno as ilceno, iladi, cast(null as varchar) as ilceadi
    from iller
    union all
    select ilc.ilno, ilc.ilceno, il.iladi, ilc.ilceadi
    from ilceler ilc
    inner join iller il on il.ilno = ilc.ilno
) as ililce;
