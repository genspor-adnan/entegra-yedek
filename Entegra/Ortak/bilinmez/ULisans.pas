unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, BHDInfo, piKeyPass, ComCtrls, ToolWin, UCombo,
  ImgList;

type
  TLisansDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Bevel1: TBevel;
    ToolBar1: TToolBar;
    CancelBtn: TToolButton;
    OKBtn: TToolButton;
    piKeyPass1: TpiKeyPass;
    BHDInfo1: TBHDInfo;
    LBKayitNo: TLabel;
    txtS1: TEdit;
    txtS2: TEdit;
    txtS3: TEdit;
    txtS4: TEdit;
    txtS5: TEdit;
    txtS6: TEdit;
    txtS7: TEdit;
    txtS8: TEdit;
    DemoBtn: TToolButton;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    function File_GetCreationDate(FileName: string): TDateTime;
    function Kontrol: boolean;
    procedure KodUret();
    function SifreCoz(): boolean;
    procedure txtS1Change(Sender: TObject);
    procedure DemoBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LisansKontrolu;
  end;

var
  LisansDlg: TLisansDlg;
  Sifre,Saat:String;

implementation

{$R *.DFM}

uses UTablo, uEncrypt, MD5;
var s1, s2, LisansNo, LisansTar: string[30];
  i, uz: smallint;
  Kapat: boolean;

function TLisansDlg.SifreCoz(): boolean;
var
str4,str3,Str2,Tarih:String;
TarKatSayi,Say:integer;
begin
  str3 := '';
  tarih := Label3.Caption;
  TarKatSayi := strtoint(tarih[1] + tarih[2] + tarih[4] + tarih[5] + tarih[7] + tarih[8] + tarih[9] + tarih[10]);
  Str2 := Encrypt(trim(LBKayitNo.Caption), 60713);
  say := length(str2);
  for i := 0 to say do
    str3 := str3 + inttostr(TarKatSayi * ord(str2[i]) + 35 - TarKatSayi * 5);
  Str4 := MD5.StrMD5(str3);
  sifre := txtS1.Text + txtS2.Text + txtS3.Text + txtS4.Text + txtS5.Text + txtS6.Text + txtS7.Text + txtS8.Text;
  if Sifre <> str4 then
  begin
//   Application.MessageBox('Aktivasyon kodunu yanlış girdiniz.', 'Uyarı !!!', 64);
    txtS1.SetFocus;
    exit;
  end;
end;

procedure TLisansDlg.KodUret();
var
  Str1: string;
  SaKatSayi, Say: integer;
begin
  Label3.Caption := datetostr(File_GetCreationDate(Application.ExeName));
  LBKayitNo.Caption := '';
  Saat := timetostr(time);
  SaKatSayi := StrToInt(saat[1] + saat[2] + saat[4] + saat[5] + saat[7] + saat[8]);
  say := length(s1);
  for i := 1 to Say do
    Str1 := str1 + inttostr(SaKatSayi * ord(s1[i]) * 2 - SaKatSayi - 35);
  str1 := md5.StrMD5(str1);
  say := 0;
  for i := 1 to length(str1) do
  begin
    LBKayitNo.Caption := LBKayitNo.Caption + str1[i];
    if ((i mod 4) = 0) and (i < 32) then
      LBKayitNo.Caption := LBKayitNo.Caption + '-';
  end;
//  Edit1.SetFocus;
end;

function TLisansDlg.File_GetCreationDate(FileName: string): TDateTime;
var
  SearchRec: TSearchRec;
  DT: TFileTime;
  ST: TSystemTime;
begin
  Result := 0;
  if not FileExists(FileName) then Exit;
  try
    SysUtils.FindFirst(FileName, faAnyFile, SearchRec);
    try
      FileTimeToLocalFileTime(SearchRec.FindData.ftCreationTime, DT);
      FileTimeToSystemTime(DT, ST);
      Result := SystemTimeToDateTime(ST);
    finally
      SysUtils.FindClose(SearchRec);
    end;
  except
    Result := 0;
  end;
end;

function TLisansDlg.Kontrol: boolean;
var
//Dongu
  i: integer;
//------------------------
  Saat: string;
  SaKatSayi: integer;
  TarKatSayi: integer;
  Say: integer;
  UrunKod, Str1, Str2, Str3, Str4: string;
  ActiveKod: string;
  Tarih: string;
//HDD
  VolumeSerialNumber: DWORD;
  MaximumComponentLength: DWORD;
  FileSystemFlags: DWORD;
  HDDNo: string;
label
  cik;
begin
  result := true;
//Tarih
//tarih:='27.08.2004';
  tarih := datetostr(File_GetCreationDate(Application.ExeName));
  TarKatSayi := strtoint(tarih[1] + tarih[2] + tarih[4] + tarih[5] + tarih[7] + tarih[8] + tarih[9] + tarih[10]);
//-------------
//  GetVolumeInformation('C:\', nil, 0, @VolumeSerialNumber, MaximumComponentLength, FileSystemFlags, nil, 0);
//WIN98
//  HDDNo := IntToHex(HiWord(VolumeSerialNumber), 4) + '-' + IntToHex(LoWord(VolumeSerialNumber), 4);
//WINXP
//  HDDNo := GetIdeSerialNumber;
//-----------------------------------------------------------------------------------------------------
  HDDNo := s1;

  Saat := Decrypt(GenRegIni.RegReadString('', 'Saat7', '', RgstryLC), 33762);
  ActiveKod := Decrypt(GenRegIni.RegReadString('', 'LisansNo7', '', RgstryLC), 26733);
  if (trim(saat) = '') or (trim(ActiveKod) = '') then
    goto cik;
  SaKatSayi := StrToInt(saat[1] + saat[2] + saat[4] + saat[5] + saat[7] + saat[8]);
  say := length(hddno);
  for i := 1 to Say do
    Str1 := str1 + inttostr(SaKatSayi * ord(hddno[i]) * 2 - SaKatSayi - 35);
  str1 := md5.StrMD5(str1);
  say := 0;
  urunkod := '';
  for i := 1 to length(str1) do
  begin
    UrunKod := UrunKod + str1[i];
    if ((i mod 4) = 0) and (i < 32) then
      UrunKod := UrunKod + '-';
  end;
  Str2 := Encrypt(trim(UrunKod), 60713);
  say := length(str2);
  for i := 0 to say do
    str3 := str3 + inttostr(TarKatSayi * ord(str2[i]) + 35 - TarKatSayi * 5);
  Str4 := MD5.StrMD5(str3);
  if trim(ActiveKod) <> trim(str4) then
  begin
    Cik:
    result := false;
//    Application.MessageBox('Bu ürün active edilmemiştir.' + chr(10) + chr(13) + 'Lütfen ELMAS Tasarım ve Yazılım ile Temasa Geçiniz. ' + chr(10) + chr(13) + '( GSM : 0537 456 60 74 - 0505 524 72 39,40)', 'Uyarı !!!', 64);
//    Application.Terminate;
  end;

end;

procedure TLisansDlg.LisansKontrolu;
begin
{  LisansNo := GenRegIni.RegReadString('', 'LisansNo7', 'xxx', RgstryLC);
  LisansTar := GenRegIni.RegReadString('', 'LisansTarih7', '01' + DATESEPARATOR + '01' + DATESEPARATOR + '2000 00:00:00', RgstryLC);
  if LisansTar = '' then LisansTar := FormatDateTime('dd/mm/yyyy hh:mm:ss', tarihbul);
  if pos(DATESEPARATOR, LisansTar) = 0 then //farklıysa
    LisansTar := copy(LisansTar, 1, 2) + DATESEPARATOR + copy(LisansTar, 4, 2) + DATESEPARATOR + copy(LisansTar, 7, 20);}
  Application.CreateForm(TLisansDlg, LisansDlg);

  if not Kontrol then
  begin
     // LisansTar := FormatDateTime('dd/mm/yyyy hh:mm:ss', tarihbul);
    LisansDlg.ShowModal;
    if LisansDlg.ModalResult = mrCancel then
    begin
      LisansDlg.Destroy;
      halt;
    end
    else
      LisansDlg.Destroy;
  end
  else
    LisansDlg.Destroy;

end;

procedure TLisansDlg.FormCreate(Sender: TObject);
{  function Artir(s: string): string;
  begin
    for i := 1 to 16 do
      if s[i] < '9' then
        s[i] := Chr(Ord(s[i]) + 1)
      else
        s[i] := '0';
    Artir := s;
  end;}
var
  Saat, ActiveKodu: string;

begin
  bhdinfo1.Execute;
  s1 := trim(bhdinfo1.SerialNumber);

  {Saat := Decrypt(GenRegIni.RegReadString('', 'Saat7', '', RgstryLC), 33762);
  ActiveKodu := Decrypt(GenRegIni.RegReadString('', 'LisansNo7', '', RgstryLC), 26733);

  if (ActiveKodu = '') or (saat = '') then
    KodUret;}

  if not Kontrol then
    KodUret;
{  s2 := '';

  for i := 1 to length(s1) do
    if (s1[i] >= '0') and (s1[i] < '9') then
      s2 := s2 + s1[i]
    else
      s2 := s2 + IntToStr(Ord(s1[i]) + 65);

  uz := length(s2); //YMQEPREP
  if uz > 16 then
    s2 := copy(s2, 1, 16)
  else
    for i := 1 to 16 - uz do
      s2 := s2 + intToStr(i);

  if DATESEPARATOR = '/' then
    piKeyPass1.date := StrToDateTime(LisansTar);
  try
    label3.caption := DateTimeToStr(piKeyPass1.date);
  except
  end;
  label5.caption := copy(s2, 1, 4);
  label8.caption := copy(s2, 5, 4);
  label9.caption := copy(s2, 9, 4);
  label10.caption := copy(s2, 13, 4);

  piKeyPass1.Key := Artir(s2);
  piKeyPass1.execute;    }
end;

procedure TLisansDlg.OKBtnClick(Sender: TObject);
begin
  if //(uppercase(Edit1.Text) <> 'DEMO') and
    //(Edit1.Text <> '070896281100') and
    //(piKeyPass1.ResultKey <> Edit1.Text)
    SifreCoz
  then
  begin
    Kapat := False;
    Showmessage('Geçersiz Lisans...');
  end
  else
  begin
    GenRegIni.RegWriteString('','Saat7',Encrypt(saat,33762),RgstryLC);
    GenRegIni.RegWriteString('','LisansNo7',Encrypt(Sifre,26733),RgstryLC);
    Kapat := True;
    ModalResult := mrOK;
  end;
end;

procedure TLisansDlg.CancelBtnClick(Sender: TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
  Close;
end;

procedure TLisansDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not Kapat then CanClose := FALSE;
end;

procedure TLisansDlg.Label4DblClick(Sender: TObject);
begin
  bhdinfo1.Execute;
//  Edit1.Text := bhdinfo1.SerialNumber;
end;

procedure TLisansDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then OKBtn.Click;
end;

procedure TLisansDlg.txtS1Change(Sender: TObject);
Var
Seri:Tobject;
Adi:String;
No:integer;
begin
(sender as tedit).Text:=UpperCase((sender as tedit).Text);
(sender as tedit).SelStart:=length((sender as tedit).Text);
if (copy((sender as TEdit).Name,5,1)<>'8') and (length((sender as tedit).Text)=4) then
begin
  no:=strtoint(copy((sender as TEdit).Name,5,1))+1;
  adi:=copy((sender as TEdit).Name,1,length((sender as TEdit).Name)-1);
  seri:=FindComponent(adi + inttostr(no));
  (seri as TEdit).SetFocus;
end;

end;

procedure TLisansDlg.DemoBtnClick(Sender: TObject);
begin
Demo:=true;
Kapat := True;
ModalResult := mrOK;
end;

end.

