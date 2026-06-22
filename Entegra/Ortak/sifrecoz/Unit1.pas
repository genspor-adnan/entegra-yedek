unit Unit1;

interface

uses
  uEncrypt,md5,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  HDDNo,Str1,Str2,Str3,Str4:String;
  SaKatSayi,TarKatSayi:longint;

implementation

{$R *.dfm}
procedure TForm1.Button1Click(Sender: TObject);
var
Say:integer;
i:integer;
tarih:String;
begin
Str1:='';Str2:='';Str3:='';Str4:='';
tarih:=edit2.Text;
TarKatSayi:=strtoint(tarih[1]+tarih[2]+tarih[4]+tarih[5]+tarih[7]+tarih[8]+tarih[9]+tarih[10]);
str1:=edit1.Text;
str2:=Encrypt(str1,60713);
say:=length(str2);
for i:=0 to say do
  str3:=str3+inttostr(TarKatSayi*ord(str2[i])+35-TarKatSayi*5);
str4:=md5.StrMD5(str3);
Edit3.Text :=str4;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
VolumeSerialNumber : DWORD;
MaximumComponentLength : DWORD;
FileSystemFlags : DWORD;
SerialNumber : string;
begin
GetVolumeInformation('C:\',nil,0,@VolumeSerialNumber,MaximumComponentLength,FileSystemFlags,nil,0);
SerialNumber := IntToHex(HiWord(VolumeSerialNumber), 4) + '-' +IntToHex(LoWord(VolumeSerialNumber), 4);
HDDNo:=SerialNumber;
end;

end.
