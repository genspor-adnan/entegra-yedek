unit UGenSifre;
(**************************************************** )
15 Haziran 2007 Cuma Gürkan DÝRÝCE
Þifreleme Uniti
Þifreleme aþaðýdaki þekilde kurgulanmýþtýr

--Þifrelenecek metin
Gürkan

--Þifrelenmek için tüm karaktrlerin sayýsal deðerlerin XOR yapýlýyor
G^ü^r^k^a^n = X

    G  ü  r  k  a  n    -- Metin
    X  X  X  X  X  X    -- X ve
+   1  2  3  4  5  6    -- Dizinin indisiyle toplanýyor
--------------------    -- Her bir karakter için 2 bytelýk alan oluyor.
   2f R4 G3 2T 4R 3E    -- Çýkan sonuç
^   X  X  X  X  X  X    -- X ile XOR yapýlýyor
---------------------
   Re RF HJ JK tV FC (X^170)  -- Çýkan bilginin sonuna X'in 170 ile XOR yapýlmýþ hali yerleþtiriliyor

(*****************************************************)

interface
uses SysUtils;
function Sifre(s :string) :string;
function DeSifre(s :string) :string;

implementation

function Sifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin

  X := 0;
  for i := 1 to Length(s) do
  begin
    // Tüm karakterler için XOR deðeri belirleniyor.
    X := X xor Ord(s[i]);
  end;
  for i := 1 to Length(s) do
  begin
    // Her bir karakterin sayýsal karþýlýðýna X ve dizi indisi ekleniyor ve
    // X ile XOR yapýlýyor
    r := r + IntToHex((Ord(s[i]) + (X + i)) xor X, 4)
  end;
  // Þifreli Metinin sonuna X 170 ile XOR yapýlarak Ekleniyor.
  Result := r + IntToHex(X xor 170, 2);
end;

function DeSifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin

  try
    if s = '' then exit;
    s:=trim(s);
    r := '';
    // Þifrelenmiþ metinin sonundaki X deðeri Alýnýyor
    X := StrToInt('$' + Copy(s, length(s) - 1, 2));
    // Þifrelenmiþ metinin sonuna 170 ile XOR yapýlarak eklendiði için XOR ile
    // yeniden açýlýyor.
    X := X xor 170;
    // Þifrelenmiþ metnin sonundaki X bilgisi siliniyor.
    Delete(s, length(s) - 1, 2);
    // Her bir 4 karaktekter 1 karaktere karþýlýk geliyor. Bu yüzden döngüde
    // karakter sayýsý/4 kadar çevrim oluyor
    for i := 1 to Length(s) div 4 do
    begin
      // 4'er karakter alýnarak tamsayýya çeviriliyor ardýndan X ile XOR
      // yapýlarak X ve dizinin indisi çýkarýlýyor. Sonucunda kalan karakter
      // deþifre metine ekleniyor.
      r := r + chr((StrToInt('$' + copy(s, (4 * (i - 1) + 1), 4)) xor X) - (X + i));
    end;
  finally
    result := r;
  end;
end;

end.

