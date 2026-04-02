unit XMLColorHelpers;

interface

uses
  Graphics;

function XMLColorToDelphiColor( XMLColor : String ) : TColor;
function DelphiColorToXMLColor( DelphiColor : TColor ) : String;

implementation

uses
  SysUtils;

function XMLColorToDelphiColor( XMLColor : String ) : TColor;
var
  s : String;
  i : Integer;
begin
  s := '';

  for i := 1 to Length(XMLColor) do
    case XMLColor[i] of
      '0'..'9',
      'a'..'f',
      'A'..'F' : s := s + XMLColor[i];
    end;

  s := StringOfChar('0', 6 - Length(s)) + s;

  s := s + copy(s, 1, 2);
  s := copy(s, 5, 2) + s;

  Delete(s, 3,2);
  Delete(s, 5,2);

  s := '$' + s;

  Result := StrToIntDef(s, 0);
end;

function DelphiColorToXMLColor( DelphiColor : TColor ) : String;
var
  s : String;
begin
  s := IntToHex(DelphiColor, 6);

  s := s + copy(s, 1, 2);
  s := copy(s, 5, 2) + s;

  Delete(s, 3,2);
  Delete(s, 5,2);

  s := '#' + s;

  Result := s;
end;

end.
