unit UCombo;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls, UFDCompatHelpers, DBTables, Registry, Dialogs, Mask, DBCtrls,
  cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxDBEdit, ToolWin, ComCtrls;

type
  TListeAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    ListBox1: TListBox;
    Label1: TLabel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TIni = class(TObject)
  private
    { Private declarations }
  public
    { Public declarations }
    Dosya: string;
    IniSQL: TADOQuery;
    constructor Create(DosyaAdi: string; IniSQL1: TADOQuery);
    destructor Destroy; override;
    procedure WriteString(Bolum, Anahtar, Deger: string);
    procedure WriteInteger(Bolum, Anahtar: string; Deger: Integer);
    procedure WriteBool(Bolum, Anahtar: string; Deger: Boolean);
    function ReadString(Bolum, Anahtar, Deger: string): string;
    function ReadInteger(Bolum, Anahtar: string; Deger: Integer): Integer;
    function ReadBool(Bolum, Anahtar: string; Deger: Boolean): Boolean;
    procedure ReadSectionValues(Bolum: string; Liste: TStrings);
    procedure ReadSectionDeger(Bolum: string; Liste: TStrings);
    procedure ReadSection(Bolum: string; Liste: TStrings);
    procedure ReadSectionAnahtar(Bolum: string; Liste: TStrings);
    procedure ReadSections(Liste: TStrings);
    procedure EraseSection(Bolum: string);
    function SectionExists(Bolum: string): Boolean;
    procedure DeleteKey(Bolum, Anahtar: string);
    function BugunTrh : TDateTime;
  end;

  TRegIni = class(TObject)
  private
    { Private declarations }
  public
    { Public declarations }
    RegKey: string;
    constructor Create(RegKey1: string);
    destructor Destroy; override;
    procedure RegWriteString(Bolum, Anahtar, Deger: string; lc: Char);
    function RegReadString(Bolum, Anahtar, Def: string; lc: Char): string;
  end;


var
  ListeAyarlaDlg: TListeAyarlaDlg;
procedure InileriAyarlama(Ini: TIni);
function ComboIniDuzenle(AnahtarKelime1: string; Ini1: TIni): integer;

implementation
uses UListe, UTablo, UMesaj,DB, UAnaForm, FetaUtil;


{$R *.DFM}
var
  j: integer;
  AnahtarKelime: string;
  Ini: TIni;

constructor TRegIni.Create(RegKey1: string);
begin
  RegKey := RegKey1;
end;

destructor TRegIni.Destroy;
begin
  inherited;
end;

function TRegIni.RegReadString(Bolum, Anahtar, Def: string; lc: Char): string;
var SystemIni: TRegistry;
  s: string;
begin
  if DebugMode then LogaEkle( 'SystemIni := TRegistry.Create;');
  SystemIni := TRegistry.Create;
  if lc = 'L' then
    SystemIni.RootKey := HKEY_LOCAL_MACHINE
  else
    SystemIni.RootKey := HKEY_CURRENT_USER;

  SystemIni.OpenKeyReadOnly('SOFTWARE\' + RegKey + '\' + Bolum);
  s := '';
  s := SystemIni.ReadString(Anahtar);
  if s = '' then s := Def;
  RegReadString := s;
  SystemIni.Free;
end;

procedure TRegIni.RegWriteString(Bolum, Anahtar, Deger: string; lc: Char);
var SystemIni: TRegistry;
begin
  SystemIni := TRegistry.Create;
  if lc = 'L' then
    SystemIni.RootKey := HKEY_LOCAL_MACHINE
  else
    SystemIni.RootKey := HKEY_CURRENT_USER;
  SystemIni.OpenKey('SOFTWARE\' + RegKey + '\' + Bolum, True);
  try
    SystemIni.WriteString(Anahtar, Deger);
  except
    Showmessage(lc + ' ye yazılamadı...');
  end;
  SystemIni.Free;
end;

procedure InileriAyarlama(Ini: TIni);
var Secilen: string;
  Ind: SmallInt;
begin
  Ind := 0;
  repeat
    Application.CreateForm(TListeDlg, ListeDlg);
    Ini.ReadSections(ListeDlg.ListAmac.Items);
    ListeDlg.ListAmac.Items.Add(' *** YENİ ***');
    ListeDlg.ListAmac.ItemIndex := Ind;
    ListeDlg.ShowModal;
    Ind := ListeDlg.ListAmac.ItemIndex;
    if ListeDlg.ModalResult = idOK then
      Secilen := ListeDlg.ListAmac.Items[ListeDlg.ListAmac.ItemIndex]
    else
      Secilen := '';
    ListeDlg.Destroy;

    if Secilen = ' *** YENİ ***' then begin
      Secilen := '';
      MesajStrAl('', 'Bölüm Adını Giriniz : ', 'E', nil, Secilen, '', 'E', nil, Secilen);
    end;
    if Secilen <> '' then
      ComboIniDuzenle(Secilen, Ini);
  until Secilen = ''
end;

function ComboIniDuzenle(AnahtarKelime1: string; Ini1: TIni): integer;
begin
  Application.CreateForm(TListeAyarlaDlg, ListeAyarlaDlg);
  AnahtarKelime := AnahtarKelime1;
  Ini := Ini1;
  ComboIniDuzenle := ListeAyarlaDlg.Showmodal;
  ListeAyarlaDlg.Free;
end;

procedure TListeAyarlaDlg.FormShow(Sender: TObject);
begin
//   Ini.ReadSection(AnahtarKelime, ListBox1.Items);
  Ini.ReadSectionValues(AnahtarKelime, ListBox1.Items);
  ListBox1.ItemIndex := 0;
end;

procedure TListeAyarlaDlg.UstTusClick(Sender: TObject);
begin
  if (ListBox1.Items.Count < 2) or (ListBox1.ItemIndex = 0) then exit;
  ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex - 1);
//   ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
end;

procedure TListeAyarlaDlg.AltTusClick(Sender: TObject);
begin
  if (ListBox1.Items.Count < 2) or (ListBox1.ItemIndex = ListBox1.Items.Count - 1) then exit;
  ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex + 1);
//   ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
end;

procedure TListeAyarlaDlg.SilTusClick(Sender: TObject);
begin
  if ListBox1.Items.Count = 0 then exit;
  ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

procedure TListeAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan: string;
begin
  if TBitBtn(Sender).Name = 'EkleTus' then
    MesajOkunan := ''
  else
    MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
    if TBitBtn(Sender).Name = 'EkleTus' then
      ListBox1.Items.Add(MesajOkunan)
    else
      ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
end;

procedure TListeAyarlaDlg.BitBtn2Click(Sender: TObject);
var i, yer: integer;
begin
  Ini.EraseSection(AnahtarKelime);
  for i := 0 to ListBox1.Items.Count - 1 do begin
    yer := pos('=', ListBox1.Items[i]);
    if yer = 0 then
      Ini.WriteString(AnahtarKelime, ListBox1.Items[i], '')
    else
      Ini.WriteString(AnahtarKelime, copy(ListBox1.Items[i], 1, yer - 1), copy(ListBox1.Items[i], yer + 1, length(ListBox1.Items[i])))
  end;
end;

constructor TIni.Create(DosyaAdi: string; IniSQL1: TADOQuery);
begin
  Dosya := DosyaAdi;
  IniSQL := IniSQL1;
end;

destructor TIni.Destroy;
begin
  inherited;
end;

function TIni.BugunTrh : TDateTime;
begin
   if BuBilgTarihi then
      BugunTrh := now
   else begin
      IniSQL.Close;
      IniSQL.SQL.Text := 'select GetDate()';
      IniSQL.Open;
      BugunTrh := IniSQL.Fields[0].AsDateTime;
   end;
end;

procedure TIni.WriteString(Bolum, Anahtar, Deger: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + '''';
  IniSQL.ExecSQL;
  IniSQL.Close;
  IniSQL.SQL.Text := 'Insert Into ' + Dosya + ' (BOLUM, ANAHTAR, DEGER)Values(''' + Bolum + ''',''' + Anahtar + ''',''' + Deger + ''')';
  IniSQL.ExecSQL;
end;

procedure TIni.WriteInteger(Bolum, Anahtar: string; Deger: Integer);
begin
  WriteString(Bolum, Anahtar, IntToStr(Deger))
end;

procedure TIni.WriteBool(Bolum, Anahtar: string; Deger: Boolean);
var s: string[1];
begin
  if Deger then s := '1' else s := '0';
  WriteString(Bolum, Anahtar, s)
end;

function TIni.ReadString(Bolum, Anahtar, Deger: string): string;
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select DEGER from ' + Dosya + ' Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + '''';
  IniSQL.Open;
  IniSQL.first;
  if not IniSQL.eof then
    ReadString := IniSQL.Fields[0].AsString
  else
    ReadString := Deger;
end;

function TIni.ReadInteger(Bolum, Anahtar: string; Deger: Integer): Integer;
begin
  ReadInteger := StrToInt(ReadString(Bolum, Anahtar, IntToStr(Deger)))
end;

function TIni.ReadBool(Bolum, Anahtar: string; Deger: Boolean): Boolean;
var s: string[1];
begin
  if Deger then s := '1' else s := '0';
  ReadBool := ReadString(Bolum, Anahtar, s) = '1'
end;

procedure TIni.ReadSectionValues(Bolum: string; Liste: TStrings);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select ANAHTAR, DEGER from ' + Dosya + ' Where BOLUM=''' + Bolum + ''' Order by SIRANO';
  IniSQL.Open;
  Liste.Clear;
  while not IniSQL.eof do begin
    if IniSQL.Fields[1].AsString <> '' then
      Liste.Add(IniSQL.Fields[0].AsString + '=' + IniSQL.Fields[1].AsString)
    else
      Liste.Add(IniSQL.Fields[0].AsString);
    IniSQL.Next;
  end;
end;

procedure TIni.ReadSectionDeger(Bolum: string; Liste: TStrings);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select DEGER from ' + Dosya + ' Where BOLUM=''' + Bolum + ''' Order by SIRANO';
  IniSQL.Open;
  Liste.Clear;
  while not IniSQL.eof do begin
    Liste.Add(IniSQL.Fields[0].AsString);
    IniSQL.Next;
  end;
end;

procedure TIni.ReadSections(Liste: TStrings);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select distinct BOLUM from ' + Dosya + ' Order by BOLUM';
  IniSQL.Open;
  Liste.Clear;
  while not IniSQL.eof do begin
    Liste.Add(IniSQL.Fields[0].AsString);
    IniSQL.Next;
  end;
end;

procedure TIni.ReadSection(Bolum: string; Liste: TStrings);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select ANAHTAR from ' + Dosya + ' Where BOLUM=''' + Bolum + ''' Order by SIRANO';
  IniSQL.Open;
  Liste.Clear;
  while not IniSQL.eof do begin
    Liste.Add(IniSQL.Fields[0].AsString);
    IniSQL.Next;
  end;
end;

procedure TIni.ReadSectionAnahtar(Bolum: string; Liste: TStrings);
//birden fazla aynı adla anahtar varsa distinct yaparak getirir
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select ANAHTAR, min(SIRANO) from ' + Dosya + ' Where BOLUM=''' + Bolum + ''' group by ANAHTAR order by 2';
  IniSQL.Open;
  Liste.Clear;
  while not IniSQL.eof do begin
    Liste.Add(IniSQL.Fields[0].AsString);
    IniSQL.Next;
  end;
end;

procedure TIni.EraseSection(Bolum: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + '''';
  IniSQL.ExecSQL;
end;

function TIni.SectionExists(Bolum: string): Boolean;
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Select count(*) from ' + Dosya + ' Where BOLUM=''' + Bolum + '''';
  IniSQL.Open;
  SectionExists := IniSQL.Fields[0].AsInteger > 0;
end;

procedure TIni.DeleteKey(Bolum, Anahtar: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + '''';
  IniSQL.ExecSQL;
end;

function RegReadString(Anahtar, Def: string; lc: Char): string;
var
  SystemIni: TRegistry;
  s: string;
begin
  SystemIni := TRegistry.Create;
  if lc = 'L' then
    SystemIni.RootKey := HKEY_LOCAL_MACHINE
  else
    SystemIni.RootKey := HKEY_CURRENT_USER;

  SystemIni.OpenKeyReadOnly('SOFTWARE\GENPER');
  s := '';
  s := SystemIni.ReadString(Anahtar);
  if s = '' then s := Def;
  RegReadString := s;
  SystemIni.Free;
end;

procedure RegWriteString(Bolum, Anahtar: string; lc: Char);
var
  SystemIni: TRegistry;
begin
  SystemIni := TRegistry.Create;
  if lc = 'L' then
    SystemIni.RootKey := HKEY_LOCAL_MACHINE
  else
    SystemIni.RootKey := HKEY_CURRENT_USER;
  SystemIni.OpenKey('SOFTWARE\GENPER', True);
  try
    SystemIni.WriteString(Bolum, Anahtar);
  except
    Showmessage(lc + ' ye yazılamadı...');
  end;
  SystemIni.Free;
end;

procedure TListeAyarlaDlg.SpeedButton1Click(Sender: TObject);
begin
  ListBox1.Sorted := False;
  ListBox1.Sorted := True;
end;

end.

