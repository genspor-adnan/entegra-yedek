program gs1test;
{$APPTYPE CONSOLE}
uses System.SysUtils, System.StrUtils, UGS1Barkod in 'UGS1Barkod.pas';
procedure Dene(const Ad, Barkod: string);
var B: TGS1Bilgi; T: string;
begin
  if GS1Coz(Barkod, B) then
  begin
    case B.Tur of
      btGS1Tam: T := 'GS1Tam';
      btGS1UrunNo: T := 'UrunNo';
      btGS1LotSkt: T := 'LotSkt';
      btDuzUrunNo: T := 'Duz';
    else T := '?';
    end;
    Writeln(Format('%-14s %-8s urun=%-15s lot=%-18s seri=%-10s skt=%s uretim=%s',
      [Ad, T, B.UrunNo, B.Lot, B.SeriNo,
       IfThen(B.SktVar, FormatDateTime('dd.mm.yyyy', B.Skt), '-'),
       IfThen(B.UretimVar, FormatDateTime('dd.mm.yyyy', B.Uretim), '-')]));
  end
  else
    Writeln(Format('%-14s COZULEMEDI: %s', [Ad, Barkod]));
end;
begin
  // Etiket: NUMEN MicroFrame, LOT 34220004, (17)280331 (10)34220004 (91)001
  Dene('NUMENetiket', '17280331103422000491001');
  Dene('NUMENkarekod','0106958698034224' + '17280331' + '10' + '34220004' + '91' + '001');
  Dene('MICROFRAME1', '0106958698034224');
  Dene('MICROFRAME2', '17280331103419000391004');
  Dene('MICROFRAME1b','0106958698034156');
  Dene('MICROFRAME2b','17280507103415000491001');
  Dene('microfinish1','0106958698035177');
  Dene('microfinish2','17270610103517000391018');
  Dene('CERENOVUS',   '01108867040828422022172806181025F188AV');
  Dene('Bilim1',      '(01) 8681489789024 (10) 262900  (17) 2031.06.25');
  Dene('Bilim2',      '(01) 8681489739128 (10) G-PBL3210233233 (17) 2029.03.20');
  Dene('Bilim5',      '(01) 8681489700159 (10) PBL4812230419  (17) 2028.07.15  (11) 2023.07.15');
  Dene('Bilim6',      '(01) 8681489702177 (11) 01.01.2025 (17) 01.01.2030 (10) ABC001');
  Dene('BilimGSli',   '01' + '08681489700159' + '10PBL4812230419' + #29 + '17280715' + '11230715');
  Dene('BilimGSsiz',  '01' + '08681489700159' + '10PBL4812230419' + '17280715' + '11230715');
  Dene('SeriliKarekod','01' + '08681489700159' + '17280715' + '21' + 'SN-00042');
  Dene('DuzEAN',      '8681489789024');
  Dene('Bozuk',       'ABC-XYZ');
  Readln;
end.
