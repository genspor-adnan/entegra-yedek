-- E-Belge seri kurallari: eski virgullu seri opsiyonlarini satir bazli GENINI yapisina tasir.
-- Eski:
--   -24093 E-Fatura seriler
--   -24094 E-Arsiv seriler
--   -24096 E-Irsaliye seriler
-- Yeni:
--   BOLUM = -24130/-24131/-24133, ANAHTAR = SERI,SENARYO,KULLANICIID, DEGER = benzersiz kural no, DIL = -1

declare @Map table(EskiBolum int not null, YeniBolum int not null);
insert into @Map(EskiBolum, YeniBolum)
values
  (-24093, -24130),
  (-24094, -24131),
  (-24096, -24133);

update GENINI
set ANAHTAR = replace(ANAHTAR, '|', ',')
where BOLUM in (-24130, -24131, -24133)
  and DIL = -1
  and ANAHTAR like '%|%';

;with Kaynak as (
  select
    M.YeniBolum,
    Sira = row_number() over(partition by M.YeniBolum order by G.SIRA, G.ANAHTAR),
    Seri = ltrim(rtrim(X.N.value('.','nvarchar(100)')))
  from GENINI G
  inner join @Map M on M.EskiBolum = G.BOLUM
  cross apply (
    select cast('<x><v>' + replace(
      replace(
      replace(
      replace(isnull(G.ANAHTAR,''), '&', '&amp;'),
      '<', '&lt;'),
      '>', '&gt;'),
      ',', '</v><v>') + '</v></x>' as xml) as XMLData
  ) D
  cross apply D.XMLData.nodes('/x/v') X(N)
  where G.DIL = 0
    and ltrim(rtrim(X.N.value('.','nvarchar(100)'))) <> ''
),
Tekil as (
  select YeniBolum, Seri, Sira = min(Sira)
  from Kaynak
  group by YeniBolum, Seri
),
Eklenecek as (
  select
    T.YeniBolum,
    T.Seri,
    Sira = row_number() over(partition by T.YeniBolum order by T.Sira, T.Seri)
  from Tekil T
  where not exists(
    select 1
    from GENINI G
    where G.BOLUM = T.YeniBolum
      and G.DIL = -1
      and G.ANAHTAR = T.Seri + N',0,0'
  )
),
SonSira as (
  select M.YeniBolum, SonSira = isnull(max(G.SIRA), 0)
  from @Map M
  left join GENINI G on G.BOLUM = M.YeniBolum and G.DIL = -1
  group by M.YeniBolum
),
SonDeger as (
  select M.YeniBolum, SonDeger = isnull(max(abs(G.DEGER)), 0)
  from @Map M
  left join GENINI G on G.BOLUM = M.YeniBolum and G.DIL = -1
  group by M.YeniBolum
)
insert into GENINI(BOLUM, ANAHTAR, DEGER, DIL, SIRA)
select
  E.YeniBolum,
  E.Seri + N',0,0',
  D.SonDeger + E.Sira,
  -1,
  S.SonSira + E.Sira
from Eklenecek E
inner join SonSira S on S.YeniBolum = E.YeniBolum
inner join SonDeger D on D.YeniBolum = E.YeniBolum;

select
  EBELGETURU = case BOLUM
    when -24130 then N'E-Fatura'
    when -24131 then N'E-Arşiv'
    when -24133 then N'E-İrsaliye'
    else convert(nvarchar(20), BOLUM)
  end,
  SERI = left(ANAHTAR, charindex(',', ANAHTAR + ',') - 1),
  SENARYO = try_convert(int, parsename(replace(ANAHTAR, ',', '.'), 2)),
  KULLANICIID = try_convert(int, parsename(replace(ANAHTAR, ',', '.'), 1)),
  KURALNO = DEGER,
  SIRA
from GENINI
where BOLUM in (-24130, -24131, -24133)
  and DIL = -1
order by BOLUM, SIRA, ANAHTAR;
