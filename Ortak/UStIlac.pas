unit UStIlac;
interface
uses dbtables, SysUtils, DB;

procedure StokDurumunuGunle(GirCik : String; TabHareket, TabIlacDurum, TabStDurum,TabStKart, TabIlacKart:TTable);
procedure OncekiGIRCIKBelirle(TabHareket : TDataSet);

var
  OncekiStIlacKod : String[20];

implementation

var
  OncekiGIRCIKAdet : Real;

function GirisCikisHesaplandi(TabHareket, TabStKart, TabIlacKart:TTable) : Boolean;
var TabKart : TTable;
    GirCikAdet : real;
begin
   GirisCikisHesaplandi := False;

   if TabHareket.FieldByName('TUR').AsString = 'ECZ' then
      TabKart := TabIlacKart
   else
      TabKart := TabStKart;

  GirCikAdet := TabHareket.FieldByName('ADET').AsFloat;

  try
   if not TabKart.FindKey([TabHareket.FieldByName('KOD').AsString]) then Exit;
   if TabHareket.FieldByName('BIRIM').AsString = TabKart.FieldByName('ANABIRIM').AsString then
      GirCikAdet := GirCikAdet
   else if TabHareket.FieldByName('BIRIM').AsString = TabKart.FieldByName('BIRIM2').AsString then
      GirCikAdet := GirCikAdet * TabKart.FieldByName('BIRIM2MIKTAR').AsFloat
   else if TabHareket.FieldByName('BIRIM').AsString = TabKart.FieldByName('BIRIM3').AsString then
      GirCikAdet := GirCikAdet * TabKart.FieldByName('BIRIM3MIKTAR').AsFloat
   else raise Exception.Create('Birimler uyuþmuyor. Stok kartýndan düzeltiniz..');
  except
     raise Exception.Create('Birimler de adetler belirtilmemiþ. Stok kartýndan düzeltiniz..');
  end;
  TabHareket.FieldByName('MIKTAR').AsFloat := GirCikAdet;
  GirisCikisHesaplandi := True;
end;

procedure StokDurumunuGunle(GirCik : String; TabHareket, TabIlacDurum, TabStDurum,TabStKart, TabIlacKart:TTable);
var TabDurum : TTable;
begin
//   TabFatGHarADET.Value := GirenCikanAdet(TabFatGHarGIREN.Value);
//   Adet := GirenCikanAdet(Adet);

   if TabHareket.FieldByName('TUR').AsString = 'ECZ' then
      TabDurum := TabIlacDurum
   else
      TabDurum := TabStDurum;

   TabDurum.Refresh;
   if TabDurum.FindKey([TabHareket.FieldByName('KOD').AsString]) then begin
      TabDurum.Edit;

      if GirCik = 'Giriþ' then begin
         if GirisCikisHesaplandi(TabHareket, TabStKart, TabIlacKart) then
            TabDurum.FieldByName('GIREN').AsFloat := TabDurum.FieldByName('GIREN').AsFloat + TabHareket.FieldByName('MIKTAR').AsFloat
      end
      else if GirCik = 'GiriþSilme' then
          TabDurum.FieldByName('GIREN').AsFloat := TabDurum.FieldByName('GIREN').AsFloat - TabHareket.FieldByName('MIKTAR').AsFloat
      else if GirCik = 'GiriþDeðiþ' then begin
            if GirisCikisHesaplandi(TabHareket, TabStKart, TabIlacKart) then
              TabDurum.FieldByName('GIREN').AsFloat := TabDurum.FieldByName('GIREN').AsFloat + TabHareket.FieldByName('MIKTAR').AsFloat-OncekiGIRCIKAdet
         end
      else if GirCik = 'Çýkýþ' then begin
            if GirisCikisHesaplandi(TabHareket, TabStKart, TabIlacKart) then
               TabDurum.FieldByName('CIKAN').AsFloat := TabDurum.FieldByName('CIKAN').AsFloat + TabHareket.FieldByName('MIKTAR').AsFloat
          end
      else if GirCik = 'ÇýkýþSilme' then
          TabDurum.FieldByName('CIKAN').AsFloat := TabDurum.FieldByName('CIKAN').AsFloat - TabHareket.FieldByName('MIKTAR').AsFloat
      else if GirCik = 'ÇýkýþDeðiþ' then begin
             if GirisCikisHesaplandi(TabHareket, TabStKart, TabIlacKart) then
            TabDurum.FieldByName('CIKAN').AsFloat := TabDurum.FieldByName('CIKAN').AsFloat + TabHareket.FieldByName('MIKTAR').AsFloat-OncekiGIRCIKAdet;
         end;
      TabDurum.FieldByName('KALAN').AsFloat := TabDurum.FieldByName('GIREN').AsFloat - TabDurum.FieldByName('CIKAN').AsFloat;
      TabDurum.Post;
   end;
end;

procedure OncekiGIRCIKBelirle(TabHareket : TDataSet);
begin
   OncekiStIlacKod := TabHareket.FieldByName('KOD').AsString;
   OncekiGIRCIKAdet := TabHareket.FieldByName('MIKTAR').AsFloat;
end;

end.
