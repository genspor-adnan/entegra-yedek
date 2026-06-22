unit UGenSifre;
(**************************************************** )
15 Haziran 2007 Cuma Gürkan DİRİCE
Şifreleme Uniti
Şifreleme aşağıdaki şekilde kurgulanmıştır

--Şifrelenecek metin
Gürkan

--Şifrelenmek için tüm karaktrlerin sayısal değerlerin XOR yapılıyor
G^ü^r^k^a^n = X

    G  ü  r  k  a  n    -- Metin
    X  X  X  X  X  X    -- X ve
+   1  2  3  4  5  6    -- Dizinin indisiyle toplanıyor
--------------------    -- Her bir karakter için 2 bytelık alan oluyor.
   2f R4 G3 2T 4R 3E    -- Çıkan sonuç
^   X  X  X  X  X  X    -- X ile XOR yapılıyor
---------------------
   Re RF HJ JK tV FC (X^170)  -- Çıkan bilginin sonuna X'in 170 ile XOR yapılmış hali yerleştiriliyor

(*****************************************************)

interface
uses SysUtils;
function Sifre(s :string) :string;
function DeSifre(s :string) :string;

implementation
{
function Sifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin
  X := 0;
  for i := 1 to Length(s) do
  begin
    // Tüm karakterler için XOR değeri belirleniyor.
    X := X xor Ord(s[i]);
  end;
  for i := 1 to Length(s) do
  begin
    // Her bir karakterin sayısal karşılığına X ve dizi indisi ekleniyor ve
    // X ile XOR yapılıyor
    r := r + IntToHex((Ord(s[i]) + (X + i)) xor X, 4)
  end;
  // Şifreli Metinin sonuna X 170 ile XOR yapılarak Ekleniyor.
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
    r := '';
    // Şifrelenmiş metinin sonundaki X değeri Alınıyor
    X := StrToInt('$' + Copy(s, length(s) - 1, 2));
    // Şifrelenmiş metinin sonuna 170 ile XOR yapılarak eklendiği için XOR ile
    // yeniden açılıyor.
    X := X xor 170;
    // Şifrelenmiş metnin sonundaki X bilgisi siliniyor.
    Delete(s, length(s) - 1, 2);
    // Her bir 4 karaktekter 1 karaktere karşılık geliyor. Bu yüzden döngüde
    // karakter sayısı/4 kadar çevrim oluyor
    for i := 1 to Length(s) div 4 do
    begin
      // 4'er karakter alınarak tamsayıya çeviriliyor ardından X ile XOR
      // yapılarak X ve dizinin indisi çıkarılıyor. Sonucunda kalan karakter
      // deşifre metine ekleniyor.
      r := r + chr((StrToInt('$' + copy(s, (4 * (i - 1) + 1), 4)) xor X) - (X + i));
    end;
  finally
    result := r;
  end;
end;
}
 function Sifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin
  X := 0;
  for i := 1 to Length(s) do
  begin
    // Tüm karakterler için XOR değeri belirleniyor.
    X := X xor Ord(s[i]);
  end;
  for i := 1 to Length(s) do
  begin
    // Her bir karakterin sayısal karşılığına X ve dizi indisi ekleniyor ve  // X ile XOR yapılıyor
    r := r + IntToHex((Ord(s[i]) + (X + i)) xor X, 4)
  end;
  // Şifreli Metinin sonuna X 170 ile XOR yapılarak Ekleniyor.
  Result := r + IntToHex(X xor 170, 2);
end;

function DeSifre(s :string) :string;
var
  i :Integer;
  X :Byte;
  r :string;
begin
  try
    if s = '' then
      exit;
    r := '';
    // Şifrelenmiş metinin sonundaki X değeri Alınıyor
    X := StrToInt('$' + Copy(s, length(s) - 1, 2));
    // Şifrelenmiş metinin sonuna 170 ile XOR yapılarak eklendiği için XOR ile // yeniden açılıyor.
    X := X xor 170;
    // Şifrelenmiş metnin sonundaki X bilgisi siliniyor.
    Delete(s, length(s) - 1, 2);
    // Her bir 4 karaktekter 1 karaktere karşılık geliyor. Bu yüzden döngüde // karakter sayısı/4 kadar çevrim oluyor
    for i := 1 to Length(s) div 4 do
    begin
      // 4'er karakter alınarak tamsayıya çeviriliyor ardından X ile XOR  // yapılarak X ve dizinin indisi çıkarılıyor. Sonucunda kalan karakter
      // deşifre metine ekleniyor.
      r := r + chr((StrToInt('$' + copy(s, (4 * (i - 1) + 1), 4)) xor X) - (X + i));
    end;
  finally
    result := r;
  end;
end;
end.

