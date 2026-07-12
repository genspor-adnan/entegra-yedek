unit UCombo;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls, FireDAC.Comp.Client, Registry, Dialogs, DBCtrls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxImageComboBox, cxGraphics, cxControls;
//Dialogs,Controls ComCtrls, ToolWin;

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
    IptalTus: TBitBtn;
    KaydetTus: TBitBtn;
    SiralaTus: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure SiralaTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TIni = class(TObject)
  private
    { Kümeleme }
    FBolumList : TStringList;
    function GetValueWithDefault(ABolum, AAnahtar, ADeger: string): string;
    procedure ListeyiDoldur;
    procedure ListeyiSil;
    function ListedeAra(ABolum,AAnahtar,Varsayilan: string;AOnBellekKullanma: Boolean = False): string;
    procedure ListedenCikar(ABolum,AAnahtar: string);
    procedure ListeyeEkle(ABolum,AAnahtar,ADeger: string);
    procedure BenzersizBolumleriGetir(AHedefListe: TStrings);
    procedure BenzersizBolumAnahtarlariniGetir(ABolum: string;AHedefListe: TStrings);
    procedure BolumSil(ABolum: string);
    procedure AnahtarSil(ABolum,AAnahtar: string);
    function BolumVarMi(ABolum: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    Dosya: string;
    IniSQL: TFDQuery;
    constructor Create(DosyaAdi: string; IniSQL1: TFDQuery);
    destructor Destroy; override;
    procedure WriteString(Bolum, Anahtar, Deger: string);
    procedure WriteInteger(Bolum, Anahtar: string; Deger: Integer);
    procedure WriteBool(Bolum, Anahtar: string; Deger: Boolean);
    procedure WriteSectionValues(Bolum: string;KeysValues: TStrings);
    function ReadString(Bolum, Anahtar, Deger: string;AOnbellekKullanma: Boolean = False): string;
    function ReadInteger(Bolum, Anahtar: string; Deger: Integer;AOnbellekKullanma: Boolean = False): Integer;
    function ReadBool(Bolum, Anahtar: string; Deger: Boolean;AOnbellekKullanma: Boolean = False): Boolean;
    procedure ReadSectionValues(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True;clearList: Boolean = True);
    procedure ReadSectionDeger(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
    procedure ReadSectionDeger2(Bolum: string; Anahtar: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
    procedure ReadSection(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True;clearList: Boolean = True; BosEkle: Boolean=False);
    procedure ReadImageSection(Bolum: string; Liste: TcxImageComboBoxProperties;AOnbellekKullanma: Boolean = True;clearList: Boolean = True; BosEkle: Boolean=False);
    procedure ReadSectionAnahtar(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
    procedure ReadSections(Liste: TStrings;AOnbellekKullanma: Boolean = True);
    procedure EraseSection(Bolum: string);
    procedure EraseSimilarSections(Bolum: string);
    // Added by NoDoubt 07/05/2008 16:41:51
    function ReadLines(Bolum, Anahtar: string): string;
    procedure WriteLines(Bolum,Anahtar : string;Lines: TStrings);overload;
    procedure WriteLines(Bolum,Anahtar,Lines: string);overload;
    //-------------------------------------------
    function SectionExists(Bolum: string): Boolean;
    procedure DeleteKey(Bolum, Anahtar: string);
    function BugunTrh: TDateTime;
    function BugunTrhSaat: TDateTime;
    function SistemTrh : TDateTime;
    property ValueWithDefault[ABolum,AAnahtar,ADeger: string]: string read GetValueWithDefault;default;
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
    function RegReadInteger(Bolum, Anahtar: string; Def: Integer; lc: Char): Integer;
    procedure RegDelete(Bolum: string; lc: Char);

  end;


var
  ListeAyarlaDlg: TListeAyarlaDlg;
{$IFNDEF NO_UTABLO}
procedure InileriAyarlama(Ini: TIni);
function ComboIniDuzenle(AnahtarKelime1: string; Ini1: TIni): integer;
function imgComboboxInit (komut: string): TcxImageComboBoxProperties;
{$ENDIF}

implementation
uses UListe,FetaUtil,LocOnFly,PrjConst,UVeriMotor,
{$IFNDEF NO_UTABLO}
UTablo, UMesaj,
{$ENDIF}

DB ;//,LocOnFly;    jhk
{$R *.DFM}
var
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

procedure TRegIni.RegDelete(Bolum : string; lc: Char);
var SystemIni: TRegistry;
begin
  SystemIni := TRegistry.Create;
  if lc = 'L' then
    SystemIni.RootKey := HKEY_LOCAL_MACHINE
  else
  SystemIni.RootKey := HKEY_CURRENT_USER;
 // SystemIni.OpenKeyReadOnly('SOFTWARE\' + RegKey + '\Gridler\' + Bolum);
  try
    SystemIni.DeleteKey(Bolum);
  except
    Showmessage(lc + Silinemedi);
  end;
  SystemIni.Free;
end;

function TRegIni.RegReadInteger(Bolum, Anahtar: string; Def: Integer;
  lc: Char): Integer;
var SystemIni: TRegistry;
  s: Integer;
begin
  SystemIni := TRegistry.Create;
  try
    if lc = 'L' then
      SystemIni.RootKey := HKEY_LOCAL_MACHINE
    else
      SystemIni.RootKey := HKEY_CURRENT_USER;

    SystemIni.OpenKeyReadOnly('SOFTWARE\' + RegKey + '\' + Bolum);

    if SystemIni.ValueExists(Anahtar) then
      s := SystemIni.ReadInteger(Anahtar)
    else
      s := Def;
    Result := s;
  finally
    SystemIni.Free;
  end;
end;

function TRegIni.RegReadString(Bolum, Anahtar, Def: string; lc: Char): string;
var SystemIni: TRegistry;
  s: string;
begin
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
    Showmessage(lc + Yazilamadi);
  end;
  SystemIni.Free;
end;

{$IFNDEF NO_UTABLO}
procedure InileriAyarlama(Ini: TIni);
var Secilen: string;
  Ind: SmallInt;
begin
  Ind := 0;
  repeat
    Application.CreateForm(TListeDlg, ListeDlg);
    try
      Ini.ReadSections(ListeDlg.ListAmac.Items);
      ListeDlg.ListAmac.Items.Add(' *** YENİ ***');
      ListeDlg.ListAmac.ItemIndex := Ind;
      ListeDlg.ShowModal;
      Ind := ListeDlg.ListAmac.ItemIndex;
      if ListeDlg.ModalResult = idOK then
        Secilen := ListeDlg.ListAmac.Items[ListeDlg.ListAmac.ItemIndex]
      else
        Secilen := '';
      if Secilen = ' *** YENİ ***' then begin
        Secilen := '';
        MesajStrAl('', 'Bölüm Adını Giriniz : ', 'E', nil, Secilen, '', 'E', nil, Secilen);
      end;
      if Secilen <> '' then
        ComboIniDuzenle(Secilen, Ini);
    finally
      ListeDlg.Free;
      ListeDlg := nil;
    end;
  until Secilen = ''
end;
{$ENDIF}
function ComboIniDuzenle(AnahtarKelime1: string; Ini1: TIni): integer;
begin
  Application.CreateForm(TListeAyarlaDlg, ListeAyarlaDlg);
  AnahtarKelime := AnahtarKelime1;
  Ini := Ini1;
  ComboIniDuzenle := ListeAyarlaDlg.Showmodal;
  ListeAyarlaDlg.Free;
end;

function imgComboboxInit (komut: string): TcxImageComboBoxProperties;
var i : integer;
    cmbList : TcxImageComboBoxProperties;
begin
    i:=0;
    TABLO.Query3.Close;
    Tablo.Query3.SQL.Text:= komut;
    Tablo.Query3.Open;

    cmbList:=TcxImageComboBoxProperties.Create(nil);

    while not Tablo.Query3.Eof do begin
      cmbList.Items.Add;
      cmbList.Items[i].Description := Tablo.Query3.Fields[1].AsString;
      cmbList.Items[i].Value := Tablo.Query3.Fields[0].AsString;
      Inc(i);
      Tablo.Query3.Next;
    end;

    Result:= cmbList;
    cmbList.Free;
end;


procedure TListeAyarlaDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
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
// ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
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
{$IFNDEF NO_UTABLO}
  if TBitBtn(Sender).Name = 'EkleTus' then
    MesajOkunan := ''
  else
    MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
    if TBitBtn(Sender).Name = 'EkleTus' then
      ListBox1.Items.Add(MesajOkunan)
    else
      ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
{$ENDIF}
end;

procedure TListeAyarlaDlg.KaydetTusClick(Sender: TObject);
var i, yer: integer;
begin
  Ini.EraseSection(AnahtarKelime);
  for i := 0 to ListBox1.Items.Count - 1 do begin
    if pos('Varsayılan:',ListBox1.Items[i])>0 then
    ListBox1.Items[i]:=StringReplace(ListBox1.Items[i],'Varsayılan: ','',[]);
    yer := pos('=', ListBox1.Items[i]);
    if yer = 0 then
      Ini.WriteString(AnahtarKelime, ListBox1.Items[i], '')
    else
      Ini.WriteString(AnahtarKelime, copy(ListBox1.Items[i], 1, yer - 1), copy(ListBox1.Items[i], yer + 1, length(ListBox1.Items[i])))
  end;
end;

function RegReadString(Anahtar, Def: string; lc: Char): string;
var SystemIni: TRegistry;
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
var SystemIni: TRegistry;
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
    Showmessage(lc + Yazilamadi);
  end;
  SystemIni.Free;
end;

procedure TListeAyarlaDlg.SiralaTusClick(Sender: TObject);
begin
  ListBox1.Sorted := False;
  ListBox1.Sorted := True;
end;

{ TIni v2 }
constructor TIni.Create(DosyaAdi: string; IniSQL1: TFDQuery);
begin
  Dosya := DosyaAdi;
  IniSQL := IniSQL1;
  FBolumList := TStringList.Create;
  ListeyiDoldur;
end;

function TIni.SistemTrh : TDateTime;
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'select '+DbSimdi;   // MSSQL: getdate() | PG: now()
  IniSQL.Open;
  SistemTrh := IniSQL.Fields[0].AsDateTime;
end;

//    function TIni.BugunTrh: TDateTime;
//    begin
//    {$IFNDEF NO_UTABLO}
//      if BuBilgTarihi then
//        BugunTrh := now
//      else begin
//    {$ENDIF}
//        BugunTrh := SistemTrh;
//    {$IFNDEF NO_UTABLO}
//      end;
//    {$ENDIF}
//    end;
//     }

function TIni.BugunTrh : TDateTime;
var trh : TDateTime;
begin
    if OzelTarihKullan then
       Trh := OzelTarih
    else if BuBilgTarihi then
       Trh := now
    else
       Trh := SistemTrh;
    Result := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Trh));
end;

function TIni.BugunTrhSaat : TDateTime;
var trh : TDateTime;
begin
    if OzelTarihKullan then
       Trh := OzelTarih
    else if BuBilgTarihi then
       Trh := now
    else
       Trh := SistemTrh;
    Result := Trh;
end;

destructor TIni.Destroy;
begin
  ListeyiSil;
  FBolumList.Free;
  inherited;
end;

procedure TIni.WriteString(Bolum, Anahtar, Deger: string);
begin
  try
    IniSQL.Connection.StartTransaction;
    IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + '''';
    IniSQL.ExecSQL;
    IniSQL.SQL.Text := 'Insert Into ' + Dosya + ' (BOLUM, ANAHTAR, DEGER)Values(''' + Bolum + ''',''' + Anahtar + ''',''' + Deger + ''')';
    IniSQL.ExecSQL;
    IniSQL.Connection.Commit;
    ListedenCikar(Bolum,Anahtar);
    ListeyeEkle(Bolum,Anahtar,Deger);
  except
    IniSQL.Connection.Rollback;
    MessageDlg(Format('Seçenek değeri yazılamadı !. Yapılan değişiklikler geri alındı.'+
      ' [Bölüm][Anahtar][Değer]-[%s][%s][%s]',[Bolum,Anahtar,Deger]),mtError,[mbOK],0);
  end;
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

function TIni.ReadString(Bolum, Anahtar, Deger: string;AOnbellekKullanma: Boolean = False): string;
begin
  Result := ListedeAra(Bolum,Anahtar,Deger,AOnbellekKullanma);
end;

function TIni.ReadInteger(Bolum, Anahtar: string; Deger: Integer;AOnbellekKullanma: Boolean = False): Integer;
begin
  ReadInteger := StrToInt(ReadString(Bolum, Anahtar, IntToStr(Deger),AOnbellekKullanma))
end;

function TIni.ReadBool(Bolum, Anahtar: string; Deger: Boolean;AOnbellekKullanma: Boolean = False): Boolean;
var s: string[1];
begin
  if Deger then s := '1' else s := '0';
  ReadBool := ReadString(Bolum, Anahtar, s,AOnbellekKullanma) = '1'
end;

procedure TIni.ReadSectionValues(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True;clearList: Boolean = True);
var
  i,j : Integer;
  anahtarlar: TStringList;
  degerler : TStringList;
begin
  if clearList then Liste.Clear;
  if (not AOnbellekKullanma) then begin
    i := FBolumList.IndexOf(TurkishUppercaseString(Bolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    for i := 0 to anahtarlar.Count - 1 do begin
      degerler := TStringList(anahtarlar.Objects[i]);
      for j := 0 to degerler.Count - 1 do begin
        if degerler[j] <> '' then begin
          if StrToIntDef(degerler[j],51)>50 then  //serkan
             Liste.Add(anahtarlar[i] + '=' + degerler[j])
        end else
          Liste.Add(anahtarlar[i]);
      end;
    end;
  end else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select ANAHTAR, DEGER from ' + Dosya + ' WITH (NOLOCK)  Where BOLUM=''' + Bolum + ''' Order by SIRANO';
    IniSQL.Open;
    if clearList then Liste.Clear;
    while not IniSQL.eof do begin
      if IniSQL.Fields[1].AsString <> '' then begin
        if StrToIntDef(IniSQL.Fields[1].AsString,51)>50 then  //serkan
           Liste.Add(IniSQL.Fields[0].AsString + '=' + IniSQL.Fields[1].AsString)
        else
           Liste.Add('Varsayılan: '+IniSQL.Fields[0].AsString+ '=' + IniSQL.Fields[1].AsString);//serkan
      end else
        Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;
end;

procedure TIni.ReadSectionDeger(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
var
  i,j : Integer;
  anahtarlar: TStringList;
  degerler : TStringList;
begin
  if (not AOnbellekKullanma) then begin
    i := FBolumList.IndexOf(TurkishUppercaseString(Bolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    for i := 0 to anahtarlar.Count - 1 do begin
      degerler := TStringList(anahtarlar.Objects[i]);
      for j := 0 to degerler.Count - 1 do begin
        Liste.Add(degerler[j]);
      end;
    end;
  end else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select DEGER from ' + Dosya + ' WITH (NOLOCK) Where BOLUM=''' + Bolum + ''' Order by SIRANO';
    IniSQL.Open;
    Liste.Clear;
    while not IniSQL.eof do begin
      Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;
end;

procedure TIni.ReadSectionDeger2(Bolum: string; Anahtar: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
var
  i,j : Integer;
  anahtarlar: TStringList;
  degerler : TStringList;
begin
  if (not AOnbellekKullanma) then begin
    i := FBolumList.IndexOf(TurkishUppercaseString(Bolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    i := anahtarlar.IndexOf(TurkishUppercaseString(Anahtar));
    if (i = -1) then Exit;
    degerler := TStringList(anahtarlar.Objects[i]);
    for j := 0 to degerler.Count - 1 do begin
      Liste.Add(anahtarlar[i] + '=' + degerler[j]);
    end;
  end else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select DEGER from ' + Dosya + ' WITH (NOLOCK) Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + ''' Order by SIRANO';
    IniSQL.Open;
    Liste.Clear;
    while not IniSQL.eof do begin
      Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;

end;

procedure TIni.ReadSections(Liste: TStrings;AOnbellekKullanma: Boolean = True);
begin
  Liste.Clear;
  if (not AOnbellekKullanma) then begin
    BenzersizBolumleriGetir(Liste);
  end
  else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select distinct BOLUM from ' + Dosya + ' WITH (NOLOCK) Order by BOLUM';
    IniSQL.Open;
    Liste.Clear;
    while not IniSQL.eof do begin
      Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;
end;

procedure TIni.ReadSection(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True;clearList: Boolean = True;BosEkle: Boolean=False);
var
  i : Integer;
  anahtarlar: TStringList;
begin
  if clearList then Liste.Clear;
  if not AOnbellekKullanma then begin
    i := FBolumList.IndexOf(TurkishUppercaseString(Bolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    for i := 0 to anahtarlar.Count - 1 do
      Liste.Add(anahtarlar[i]);
  end else begin
   IniSQL.Close;
   IniSQL.SQL.Text := 'Select ANAHTAR FROM ' + Dosya + ' WITH (NOLOCK) Where BOLUM=''' + Bolum + ''' Order by SIRANO';
   IniSQL.Open;
    if BosEkle then
      Liste.Add('');
    while not IniSQL.eof do begin
      Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;
end;

procedure TIni.ReadImageSection(Bolum: string; Liste: TcxImageComboBoxProperties;AOnbellekKullanma: Boolean = True;clearList: Boolean = True; BosEkle: Boolean=False);
var
  i : Integer;
  anahtarlar: TStringList;
 // cmbList : TcxImageComboBoxProperties;
begin
  if clearList then Liste.Items.Clear;
  if not AOnbellekKullanma then begin
    i := FBolumList.IndexOf(TurkishUppercaseString(Bolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    for i := 0 to anahtarlar.Count - 1 do begin
      Liste.Items.Add;
      Liste.Items[i].Description:=anahtarlar[i];
      Liste.Items[i].Value:=i;
//      Liste.Items.Add(anahtarlar[i]);
      end
  end else begin
    IniSQL.Close;
    IniSQL.SQL.Text:='';

    if BosEkle then
    IniSQL.SQL.Text:= 'SELECT '''' AS ANAHTAR, 0 AS DEGER UNION ALL ';
    IniSQL.SQL.Text :=IniSQL.SQL.Text+ 'Select ANAHTAR, DEGER FROM ' + Dosya + ' WITH (NOLOCK) Where BOLUM=''' + Bolum + ''' Order by 1';
    IniSQL.Open;
    i:=0;
    while not IniSQL.eof do begin
      Liste.Items.Add;
      Liste.Items[i].Description:=IniSQL.Fields[0].AsString;
      Liste.Items[i].Value:=IniSQL.Fields[1].AsString;
      Inc(i);
      IniSQL.Next;
    end;
  end;
  Liste.ImmediatePost:=True;
end;

procedure TIni.ReadSectionAnahtar(Bolum: string; Liste: TStrings;AOnbellekKullanma: Boolean = True);
//birden fazla aynı adla anahtar varsa distinct yaparak getirir
begin
  Liste.Clear;
  if (not AOnbellekKullanma) then begin
    BenzersizBolumAnahtarlariniGetir(Bolum,liste);
  end else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select ANAHTAR, min(SIRANO) from ' + Dosya + ' WITH (NOLOCK) Where BOLUM=''' + Bolum + ''' group by ANAHTAR order by 2';
    IniSQL.Open;
    Liste.Clear;
    while not IniSQL.eof do begin
      Liste.Add(IniSQL.Fields[0].AsString);
      IniSQL.Next;
    end;
  end;
end;

procedure TIni.WriteSectionValues(Bolum: string; KeysValues: TStrings);
var
  i : integer;
begin
  EraseSection(Bolum);
  with IniSQL do
    begin
      Close;
      SQL.Text := Format('SELECT '+DbUst(1)+'BOLUM,ANAHTAR,DEGER FROM %s WITH (NOLOCK) '+DbSinir(1),[Dosya]);
      Open;
      for i := 0 to KeysValues.Count - 1 do
        begin
          Append;
          FieldByName('BOLUM').AsString := Bolum;
          FieldByName('ANAHTAR').AsString := KeysValues.Names[i];
          FieldByName('DEGER').AsString := KeysValues.ValueFromIndex[i];
          Post;
          ListeyeEkle(Bolum,KeysValues.Names[i],KeysValues.ValueFromIndex[i]);
        end;
    end;
end;

procedure TIni.EraseSection(Bolum: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + '''';
  //IniSQL.SQL.Text := 'delete FROM REHERINI WHERE BOLUM=''' + Bolum + '''';
  IniSQL.ExecSQL;
  BolumSil(Bolum);
end;

function TIni.SectionExists(Bolum: string): Boolean;
begin
  Result := BolumVarMi(Bolum);
end;

procedure TIni.DeleteKey(Bolum, Anahtar: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'Delete From ' + Dosya + ' Where BOLUM=''' + Bolum + ''' and ANAHTAR=''' + Anahtar + '''';
  IniSQL.ExecSQL;
  AnahtarSil(Bolum,Anahtar);
end;

function TIni.GetValueWithDefault(ABolum, AAnahtar,
  ADeger: string): string;
begin
  Result := ReadString(ABolum,AAnahtar,ADeger);
end;

function TIni.ReadLines(Bolum, Anahtar: string): string;
var
  liste : TStringList;
  i     : Integer;
begin
  Result := '';
  liste := TStringList.Create;
  try
    ReadSectionDeger2(Bolum,Anahtar,liste);
    for i := 0 to liste.Count - 1 do begin
      if (liste[i] <> '') then begin
        if liste[i][Length(liste[i])] = #15 then
          Result := Result + Copy(liste[i], 1, Length(liste[i]) - 1)
        else
          Result := Result + liste[i] + #13#10;
      end else Result := Result + #13#10;
    end;
  finally
    liste.Free;
  end;
end;

procedure TIni.WriteLines(Bolum, Anahtar: string; Lines: TStrings);

procedure SaveLine(ATable: TDataSet;ALine: string);
begin
  if (Length(ALine) > ATable.FieldByName('DEGER').DataSize) then begin
    while (ALine <> '') do begin
      ATable.Append;
        ATable.FieldByName('BOLUM').AsString := Bolum;
        ATable.FieldByName('ANAHTAR').AsString := Anahtar;
        ATable.FieldByName('DEGER').AsString := Copy(ALine, 1, ATable.FieldByName('DEGER').DataSize - 2) + #15;
      ATable.Post;
      ListeyeEkle(Bolum,Anahtar,ATable.FieldByName('DEGER').AsString);
      Delete(ALine, 1, ATable.FieldByName('DEGER').DataSize - 2);
    end;
  end else begin
    ATable.Append;
      ATable.FieldByName('BOLUM').AsString := Bolum;
      ATable.FieldByName('ANAHTAR').AsString := Anahtar;
      ATable.FieldByName('DEGER').AsString := ALine;
    ATable.Post;
    ListeyeEkle(Bolum,Anahtar,ATable.FieldByName('DEGER').AsString);
  end;
end;
var
  i : Integer;
  tmpTable: TFDQuery;
begin
  tmpTable := TFDQuery.Create(nil);
  try
    i := 0;
    tmpTable.Connection := IniSql.Connection;
    tmpTable.SQL.Text := 'DELETE FROM ' + Dosya +
      ' WHERE (BOLUM=:BOLUM) AND (ANAHTAR=:ANAHTAR)';
    tmpTable.ParamByName('BOLUM').AsString := Bolum;
    tmpTable.ParamByName('ANAHTAR').AsString := Anahtar;
    tmpTable.Connection.StartTransaction;
    try
      tmpTable.ExecSQL;
      i := 1;
      tmpTable.Connection.Commit;
    except
      if tmpTable.Connection.InTransaction then
        tmpTable.Connection.Rollback;
      raise;
    end;
  finally
    tmpTable.Free;
  end;
  if i = 0 then Exit;
  AnahtarSil(Bolum,Anahtar);
  tmpTable := TFDQuery.Create(nil);
  tmpTable.Connection := IniSql.Connection;
  tmpTable.SQL.Text := 'SELECT '+DbUst(0)+'* FROM ' + Dosya+' '+DbSinir(0);
  with tmpTable do
  try
    Open;
    for i := 0 to Lines.Count - 1 do begin
      SaveLine(tmpTable,Lines[i]);
    end;
  finally
    Free;
  end;
end;

procedure TIni.WriteLines(Bolum, Anahtar, Lines: String);
var
  tmp : TStringList;
begin
  tmp := TStringList.Create;
  try
    tmp.Text := Lines;
    WriteLines(Bolum,Anahtar,tmp);
  finally
    tmp.Free;
  end;
end;


procedure TIni.ListeyiDoldur;
begin
  with IniSql do begin
    Close;
    Sql.Text := 'SELECT * FROM ' + Dosya + ' ORDER BY SIRANO';
    Open;
    while not Eof do begin
      ListeyeEkle(
        FieldByName('BOLUM').AsString,
        FieldByName('ANAHTAR').AsString,
        FieldByName('DEGER').AsString);
      Next;
    end;
  end;
end;

procedure TIni.ListeyiSil;
var
  i : Integer;
begin
  for i := FBolumList.Count - 1 downto 0 do
    BolumSil(FBolumList[i]);
end;

function TIni.ListedeAra(ABolum, AAnahtar,Varsayilan: string;
  AOnBellekKullanma: Boolean = False): String;
var
  i : Integer;
  anahtarlar: TStringList;
  degerler  : TStringList;
begin
  if (not AOnBellekKullanma) then begin
    Result := Varsayilan;
    i := FBolumList.IndexOf(TurkishUppercaseString(ABolum));
    if (i = -1) then Exit;
    anahtarlar := TStringList(FBolumList.Objects[i]);
    i := anahtarlar.IndexOf(TurkishUppercaseString(AAnahtar));
    if (i = -1) then exit;
    degerler := TStringList(anahtarlar.Objects[i]);
    if (degerler.Count > 0) then Result := degerler[0];
  end
  else begin
    IniSQL.Close;
    IniSQL.SQL.Text := 'Select DEGER from ' + Dosya + ' WITH (NOLOCK)  Where BOLUM=''' + ABolum + ''' and ANAHTAR=''' + AAnahtar + '''';
    IniSQL.Open;
    if not IniSQL.eof then
      Result := IniSQL.Fields[0].AsString
    else
      Result := Varsayilan;
  end;
end;

procedure TIni.ListeyeEkle(ABolum, AAnahtar, ADeger: string);
var
  idx : Integer;
  blmtrk: string;
  anatrk: string;
  anahtarlar: TStringList;
  degerler  : TStringList;
begin
  { Kümeleme Yapılıyor }
  blmtrk := TurkishUppercaseString(ABolum);
  anatrk := TurkishUppercaseString(AAnahtar);
  idx := FBolumList.IndexOf(blmtrk);
  if (idx = -1) then begin
    { Bölüm bulunamadı }
    anahtarlar := TStringList.Create;
    FBolumList.AddObject(blmtrk,anahtarlar);
    degerler := TStringList.Create;
    anahtarlar.AddObject(anatrk,degerler);
  end else begin
    { Bölüm var }
    anahtarlar := TStringList(FBolumList.Objects[idx]);
    idx := anahtarlar.IndexOf(anatrk);
    if (idx = -1) then begin
      { Anahtar yok }
      degerler := TStringList.Create;
      anahtarlar.AddObject(anatrk,degerler);
    end else begin
      { Anahtar var }
      degerler := TStringList(anahtarlar.Objects[idx]);
    end;
  end;
  degerler.Add(ADeger);
end;

procedure TIni.ListedenCikar(ABolum, AAnahtar: string);
var
  i : Integer;
  anahtarlar,degerler: TStringList;
  anatrk : string;
begin
  i := FBolumList.IndexOf(TurkishUppercaseString(ABolum));
  anatrk := TurkishUppercaseString(AAnahtar);
  if (i = -1) then Exit;
  anahtarlar := TStringList(FBolumList.Objects[i]);
  i := anahtarlar.IndexOf(anatrk);
  if ( i = -1 ) then Exit;
  degerler := TStringList(anahtarlar.Objects[i]);
  degerler.Free;
  anahtarlar.Delete(i);
end;

procedure TIni.BenzersizBolumleriGetir(AHedefListe: TStrings);
begin
  AHedefListe.Assign(FBolumList);
end;

procedure TIni.BenzersizBolumAnahtarlariniGetir(ABolum: string;AHedefListe: TStrings);
var
  i : Integer;
  anahtarlar: TStringList;
begin
  i := FBolumList.IndexOf(TurkishUppercaseString(ABolum));
  if (i = -1) then Exit;
  anahtarlar := TStringList(FBolumList.Objects[i]);
  for i := 0 to anahtarlar.Count - 1 do
    AHedefListe.Add(anahtarlar[i]);
end;

procedure TIni.BolumSil(ABolum: string);
var
  i : Integer;
  j : Integer;
  anahtarlar : TStringList;
begin
  i := FBolumList.IndexOf(TurkishUppercaseString(ABolum));
  if (i = -1) then Exit;
  anahtarlar := TStringList(FBolumList.Objects[i]);
  for j := 0 to anahtarlar.Count - 1 do
    anahtarlar.Objects[j].Free;
  anahtarlar.Free;
  FBolumList.Delete(i);
end;

function TIni.BolumVarMi(ABolum: string): Boolean;
begin
  Result := FBolumList.IndexOf(TurkishUppercaseString(ABolum)) > -1;
end;

procedure TIni.AnahtarSil(ABolum, AAnahtar: string);
var
  i : Integer;
  j : Integer;
  anahtarlar : TStringList;
begin
  i := FBolumList.IndexOf(TurkishUppercaseString(ABolum));
  if (i = -1) then Exit;
  anahtarlar := TStringList(FBolumList.Objects[i]);
  i := anahtarlar.IndexOf(TurkishUppercaseString(AAnahtar));
  if (i = -1) then Exit;
  anahtarlar.Objects[i].Free;
  anahtarlar.Delete(i);
end;
procedure TIni.EraseSimilarSections(Bolum: string);
begin
  IniSQL.Close;
  IniSQL.SQL.Text := 'delete FROM ' + Dosya + ' WHERE (case patindex(''%[^-10-9]%'', DEGER) when 0 then cast(ABS(DEGER) as Int) else 99 end ) > 50 AND BOLUM like''' + Bolum + '%''';
  IniSQL.ExecSQL;
end;

end.




