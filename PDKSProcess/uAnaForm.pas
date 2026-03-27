unit uAnaForm;

interface

uses
  uTablo, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms,
  Dialogs, StdCtrls, DB, ADODB, CPort, DBCtrls, Menus, ExtCtrls, CPortCtl,
  Grids, DBGrids, ShellApi, ComCtrls, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,cxgridExportlink,
  cxGridCustomPopupMenu, cxGridPopupMenu, XPMenu, MMSystem, Buttons, ToolWin,
  cxSplitter, uFingerPrint, RFID_103_485IO_DLL, uAnvizProtokol, OleCtrls,
  AKSREADERLib_TLB, zkemkeeper_TLB, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinXmas2008Blue, dxSkinscxPCPainter, FKAttendLib_TLB,ComObj,
  cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator;

type
  TAnaForm = class(TForm)
    Panel1: TPanel;
    BTNAc: TButton;
    ComLed1: TComLed;
    ComLed2: TComLed;
    Panel2: TPanel;
    DBText1: TDBText;
    PopupMenu1: TPopupMenu;
    Seaenekler1: TMenuItem;
    SeriPortAyarlar2: TMenuItem;
    N1: TMenuItem;
    ProgramA1: TMenuItem;
    N2: TMenuItem;
    Kapat1: TMenuItem;
    Label1: TLabel;
    Timer1: TTimer;
    LBTarSa: TLabel;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    MainMenu1: TMainMenu;
    MNSecenek: TMenuItem;
    SeriPortAyarlar1: TMenuItem;
    cxGridPopupMenu1: TcxGridPopupMenu;
    Timer2: TTimer;
    ProgramAyarlar1: TMenuItem;
    Opsiyonlar1: TMenuItem;
    Yardm1: TMenuItem;
    Hakknda1: TMenuItem;
    LBHata: TLabel;
    BTNKamera: TSpeedButton;
    ResimPanel: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    IMGIRIS: TImage;
    IMCIKIS: TImage;
    BTNResim: TSpeedButton;
    izinler: TMenuItem;
    GenelDokumler: TMenuItem;
    MNDonemAktar: TMenuItem;
    N3: TMenuItem;
    Panel3: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1FIRMA: TcxGridDBColumn;
    cxGrid1DBTableView1GIRIS: TcxGridDBColumn;
    cxGrid1DBTableView1CIKIS: TcxGridDBColumn;
    cxGrid1DBTableView1VARGIRIS: TcxGridDBColumn;
    cxGrid1DBTableView1VARCIKIS: TcxGridDBColumn;
    tvGirCik: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel4: TPanel;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    TVGirCikSICILNO: TcxGridDBColumn;
    TVGirCikADI: TcxGridDBColumn;
    TVGirCikSOYADI: TcxGridDBColumn;
    TVGirCikDEPARTMAN: TcxGridDBColumn;
    TVGirCikGIRIS: TcxGridDBColumn;
    TVGirCikCIKIS: TcxGridDBColumn;
    TVGirCikVARDIYA: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    DBText2: TDBText;
    Memo1: TMemo;
    Edit1: TEdit;
    cxSplitter3: TcxSplitter;
    Timer3: TTimer;
    ComPort1: TComPort;
    Timer4: TTimer;
    tmrSupremaTarama: TTimer;
    lblMesaj: TLabel;
    tmrOkuyucu2: TTimer;
    SpeedButton1: TSpeedButton;
    btnVerileriAl: TSpeedButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    dtpVerileriAl: TDateTimePicker;
    FkAttendSorgula: TTimer;
    SbAttendVeriAl: TSpeedButton;
    MemoTemizle: TTimer;
    tmrOkuyucuAktar: TTimer;
    Panel5: TPanel;
    PERS_PDKSDBTableView1: TcxGridDBTableView;
    PERS_PDKSLevel1: TcxGridLevel;
    PERS_PDKS: TcxGrid;
    dtsqry1: TDataSource;
    qry1: TADOQuery;
    qry1ID: TAutoIncField;
    qry1PERKOD: TIntegerField;
    qry1KARTNO: TStringField;
    qry1GIRIS: TDateTimeField;
    qry1CIKIS: TDateTimeField;
    qry1VARDIYA: TStringField;
    qry1VARGIRIS: TStringField;
    qry1VARCIKIS: TStringField;
    qry1VARCALSURE: TStringField;
    qry1IGIRIS: TDateTimeField;
    qry1ICIKIS: TDateTimeField;
    qry1IVARDIYA: TStringField;
    qry1IVARGIRIS: TStringField;
    qry1IVARCIKIS: TStringField;
    qry1IVARCALSURE: TStringField;
    qry1GEC_MAZERET: TStringField;
    qry1ERKEN_MAZERET: TStringField;
    qry1UCRETLISAAT: TStringField;
    qry1UCRETSIZSAAT: TStringField;
    qry1GIRFARK: TStringField;
    qry1CIKFARK: TStringField;
    qry1CALSURE: TStringField;
    qry1CALFARK: TStringField;
    qry1IZINVEREN: TStringField;
    qry1ACIKLAMA: TStringField;
    qry1ADI: TStringField;
    qry1SOYADI: TStringField;
    PERS_PDKSDBTableView1ID: TcxGridDBColumn;
    PERS_PDKSDBTableView1PERKOD: TcxGridDBColumn;
    PERS_PDKSDBTableView1KARTNO: TcxGridDBColumn;
    PERS_PDKSDBTableView1GIRIS: TcxGridDBColumn;
    PERS_PDKSDBTableView1CIKIS: TcxGridDBColumn;
    PERS_PDKSDBTableView1VARDIYA: TcxGridDBColumn;
    PERS_PDKSDBTableView1VARGIRIS: TcxGridDBColumn;
    PERS_PDKSDBTableView1VARCIKIS: TcxGridDBColumn;
    PERS_PDKSDBTableView1VARCALSURE: TcxGridDBColumn;
    PERS_PDKSDBTableView1UCRETLISAAT: TcxGridDBColumn;
    PERS_PDKSDBTableView1UCRETSIZSAAT: TcxGridDBColumn;
    PERS_PDKSDBTableView1GIRFARK: TcxGridDBColumn;
    PERS_PDKSDBTableView1CIKFARK: TcxGridDBColumn;
    PERS_PDKSDBTableView1CALSURE: TcxGridDBColumn;
    PERS_PDKSDBTableView1CALFARK: TcxGridDBColumn;
    PERS_PDKSDBTableView1IZINVEREN: TcxGridDBColumn;
    PERS_PDKSDBTableView1ACIKLAMA: TcxGridDBColumn;
    PERS_PDKSDBTableView1ADI: TcxGridDBColumn;
    PERS_PDKSDBTableView1SOYADI: TcxGridDBColumn;
    qry2: TADOQuery;
    CZKEMYemekhane: TCZKEM;
    CZKEMPDKS: TCZKEM;
    FKAttend: TFKAttend;
    FKAttendy: TFKAttend;
    procedure ComPort1RxChar(Sender: TObject; Count: Integer);
    procedure KartKontrolYemek(KARTID: string; OkuyucuNo: integer);
    procedure KartKontrol(KARTID: string; OkuyucuNo: integer);
    procedure KartKontrolZamanli(KartID: string; OkuyucuNo: integer; Tarih: String);
    procedure CihazdanAl(Kartno, Tarih: string);
    procedure FormCreate(Sender: TObject);
    procedure BTNAcClick(Sender: TObject);
    procedure SeriPortAyarlar1Click(Sender: TObject);
    procedure ProgramA1Click(Sender: TObject);
    procedure Kapat1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure cxGrid1DBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure Timer2Timer(Sender: TObject);
    function GetFileVersiyon(): string;
    procedure AddInfo(const s: string);
    procedure TrayIpucu(s: string);
    procedure ProgramAyarlar1Click(Sender: TObject);
    procedure Hakknda1Click(Sender: TObject);
    procedure BTNKameraClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BTNResimClick(Sender: TObject);
    procedure EkranYazClick(Sender: TObject);
    procedure YeniDonemAlgila();
    function KartOku(PortNo, OkuyucuNo: integer): Boolean;
    function HataVarmi(oku1: string): string;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Timer3Timer(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure tmrSupremaTaramaTimer(Sender: TObject);
    function HIDokuyucuBaslat(czkem: TCZKEM; PortNumarasi: integer): integer;
    function CZKEMTCPIPOkuyucuBaslat(czkem: TCZKEM; IPNUMBER, PortNumber: String): integer;
    function ATTENDOkuyucuBaslat(Attend: TFKAttend; IPNUMBER, PortNumber: String; Timeout: integer; ProtocolType: integer; Netpassword: integer; Lisance: integer): integer;

    procedure ReadDeviceStatus(czkem: TCZKEM);

    procedure ReadDeviceStatusAttend(Attend: TFKAttend);

    procedure CZKEMPDKSHIDNum(ASender: TObject; CardNumber: Integer);
    procedure tmrOkuyucu2Timer(Sender: TObject);
    procedure GenelDokumlerClick(Sender: TObject);
    procedure CZKEMYemekhaneHIDNum(ASender: TObject; CardNumber: Integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure CZKEMYemekhaneConnected(Sender: TObject);
    procedure CZKEMPDKSVerify(ASender: TObject; UserID: Integer);
    procedure btnVerileriAlClick(Sender: TObject);
    function SaveGLogs(): integer;
    procedure FkAttendKaydet();
    procedure SbAttendVeriAlClick(Sender: TObject);
    function AttendConvertDatetime(apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec: integer): string;
    procedure AttendLogAl(Attend: TFKAttend; Tarih: TDatetime);
    procedure FkAttendSorgulaTimer(Sender: TObject);
    procedure MemoTemizleTimer(Sender: TObject);
    procedure tmrOkuyucuAktarTimer(Sender: TObject);
    procedure CZKEMPDKSAttTransactionEx(ASender: TObject;
      const EnrollNumber: WideString; IsInValid, AttState, VerifyMethod, Year,
      Month, Day, Hour, Minute, Second, WorkCode: Integer);

  private
    { Private declarations }
  public
    procedure Isle;
    procedure ParmakIziMesajGonder(pkt: string);
    procedure ParmakIziGenelMesaj(pkt: string);
    procedure SeriPortAyarKaydet();
    procedure portuAc;
    procedure Query1EOF(Tarih:Tdatetime);
  end;

var
  AnaForm: TAnaForm;
  GECSURE: integer;
  STR: string;
  tray: PNotifyIconData;
  SonOkunan: string;
  DevID: integer;
  Commport: integer;
  VeriBasTarih,VeriBitTarih:TDateTime;

const
  StatusNames: array [1 .. 12] of string = ('Tatal administrator', 'Tatal users', 'Tatal FP', 'Tatal Password', 'Tatal manage record', 'Tatal In and out record', 'Nominal FP number', 'Nominal user number', 'Nominal In and out record number', 'Remain FP number', 'Remain user number', 'Remain In and out record number');

implementation

uses unit2, GT_About,
  DateUtils, uCamera, uAyarForm, Math, Uizin, UVeriAl, UTanim;
{$R *.dfm}

procedure TAnaForm.SeriPortAyarKaydet();
var
  BaudRate: Integer;
  ComPort: string;
  DataBit: integer;
begin
  BaudRate := Tablo.BaudRateYaz;
  ComPort := ComPort1.Port;
  // ComLed1.ComPort.DataBits:=db;
  // DataBit:=ComLed1.
end;

procedure TAnaForm.KartKontrolYemek(KARTID: string; OkuyucuNo: integer);
begin
  Tablo.sp_KARTOKU_YEMEK.Close;
  Tablo.sp_KARTOKU_YEMEK.Parameters.ParamByName('@SURE').Value := OkumaAra;
  Tablo.sp_KARTOKU_YEMEK.Parameters.ParamByName('@KARTID').Value := TRim(KARTID);
  Tablo.sp_KARTOKU_YEMEK.Parameters.ParamByName('@MAXVAR').Value := MaxVar;
  Tablo.sp_KARTOKU_YEMEK.Parameters.ParamByName('@OKUYUCU_NO').Value := OkuyucuNo;
  Tablo.sp_KARTOKU_YEMEK.Open;

  {
    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:='p_KARTOKU ''' + KARTID + ''',' +inttostr(okumaara) + ',' + inttostr(MaxVar);
    Tablo.Query2.ExecSQL;
    }
  Tablo.TabYemekhane.Close;
  Tablo.TabYemekhane.Open;
  Tablo.TabYemekhane.Last;
  // showmessage(str);
  CardAnswer(PortNe, OkuyucuNo, '+3' + DBText2.Caption + '#', 1000);
  if (pos('SÜRE DOLMADI', Tablo.sp_KARTOKU_YEMEK.Fields[0].AsString) > 0) and (SSure <> '') then
    PlaySound(PChar(SSure), 0, SND_FILENAME + SND_ASYNC)
  else if (pos('KAHVALTI', Tablo.sp_KARTOKU_YEMEK.Fields[0].AsString) > 0) and (SGiris <> '') then
  begin
    PlaySound(PChar(SGiris), 0, SND_FILENAME + SND_ASYNC);

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Select TOP 1 ID from PERS_YEMEKHANE ORDER BY SABAH DESC';
    Tablo.Query1.Open;
    // Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger,'SABAH' );
  end
  else if (pos('ÖÐLE YEMEÐÝ', Tablo.sp_KARTOKU_YEMEK.Fields[0].AsString) > 0) and (SGiris <> '') then
  begin
    PlaySound(PChar(SGiris), 0, SND_FILENAME + SND_ASYNC);
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Select top 1 ID from PERS_YEMEKHANE ORDER BY OGLEN DESC';
    Tablo.Query1.Open;
    // Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger,'OGLEN' );
  end
  else if (pos('AKÞAM YEMEÐÝ', Tablo.sp_KARTOKU_YEMEK.Fields[0].AsString) > 0) and (SGiris <> '') then
  begin
    PlaySound(PChar(SGiris), 0, SND_FILENAME + SND_ASYNC);
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Select top 1 ID from PERS_YEMEKHANE ORDER BY AKSAM DESC';
    Tablo.Query1.Open;
    // Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger,'AKSAM' );
  end
  else if (pos('GEÇERSÝZ KART', Tablo.sp_KARTOKU_YEMEK.Fields[0].AsString) > 0) and (SGecersiz <> '') then
    PlaySound(PChar(SGecersiz), 0, SND_FILENAME + SND_ASYNC);

  STR := '';
  // Tablo.TabStatusAfterScroll(Tablo.TabStatus);
end;

procedure TAnaForm.CihazdanAl(Kartno, Tarih: string);
begin
  try
    Tablo.Query6.Close;
    Tablo.Query6.SQL.Text := 'INSERT INTO PERS_CIHAZ_ALINAN (CIHAZKOD,KARTNO,TARIH) VALUES (''1'',''' + Kartno + ''',''' + Tarih + ''') ';
    Tablo.Query6.ExecSQL;
  except
    ShowMessage('Aktarým hata oluþtu');
  end;
end;


procedure TAnaForm.KartKontrolZamanli(KartID: string; OkuyucuNo: integer; Tarih: string);
Var
  DonenSonuc : String;
begin

///    Tablo.sp_KARTOKU.Fields[0].AsString olan yerler DonenSonuc olarak deðiþtirildi.
  if Tablo.cnn.Connected then
  begin

    try
//      Tablo.sp_KARTOKU.Close;
//      Tablo.sp_KARTOKU.SQL.Text := 'exec p_KARTOKU ''' + TRim(KartID) + ''',' + IntToStr(OkumaAra) + ',' + IntToStr(MaxVar) + ',' + IntToStr(OkuyucuNo) + ',''' + Tarih + ''' ';
//      Tablo.sp_KARTOKU.Open;
      DonenSonuc := Tablo.PERS_PDKSyeKayit(KartID,Tarih,OkuyucuNo,OkumaAra);
    except

    end;

  end
  else
  begin
    // Baðlantý yok demektir bu
    Tablo.GeciciKartEkle(TRim(KARTID));
  end;

  try
    Tablo.TabStatus.Close;
    Tablo.TabStatus.Open;
    Tablo.TabStatus.Last;
  except
  end;
  // showmessage(str);
  try
    CardAnswer(PortNe, OkuyucuNo, '+3' + DBText1.Caption + '#', 1000);
    if (pos('SÜRE DOLMADI', DonenSonuc ) > 0) and (SSure <> '') then
    begin
      PlaySound(PChar(SSure), 0, SND_FILENAME + SND_ASYNC);
    end
    else if (pos('GÝRÝÞ YAPTI', DonenSonuc ) > 0) and (SGiris <> '') then
    begin
      PlaySound(PChar(SGiris), 0, SND_FILENAME + SND_ASYNC);

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select TOP 1 ID from PERS_PDKS ORDER BY GIRIS DESC';
      Tablo.Query1.Open;
      Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger, 'GIRIS');
      ORelay(PortNe, OkuyucuNo, 2);
    end
    else if (pos('ÇIKIÞ YAPTI', DonenSonuc) > 0) and (SCikis <> '') then
    begin
      PlaySound(PChar(SCikis), 0, SND_FILENAME + SND_ASYNC);
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select top 1 ID from PERS_PDKS ORDER BY CIKIS DESC';
      Tablo.Query1.Open;
      Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger, 'CIKIS');
      ORelay(PortNe, OkuyucuNo, 2);
    end
    else if (pos('GEÇERSÝZ KART', DonenSonuc) > 0) and (SGecersiz <> '') then
      PlaySound(PChar(SGecersiz), 0, SND_FILENAME + SND_ASYNC);
  except
  end;
  STR := '';
  try
    Tablo.TabStatusAfterScroll(Tablo.TabStatus);
  except
  end;
end;

function HexToStrInt(): string;

begin

end;

function TAnaForm.KartOku(PortNo, OkuyucuNo: integer): Boolean;
var
  Oku, oku1: string;
  Hata: string;
begin
  if OkuyucuTur = 2 then
    oku1 := CheckCard(PortNo, OkuyucuNo, 1000)
  else
    oku1 := inttostr(OGetCardID(PortNo, OkuyucuNo));
  Hata := HataVarmi(oku1);
  LBHata.Caption := Hata;
  if (Hata = '') and ((pos('x', oku1) = 1) or (OkuyucuTur = 4)) and (oku1 <> '') then
  begin
    if OkuyucuTur <> 4 then
      Oku := copy(oku1, 3, length(oku1))
    else
      Oku := oku1;
  end
  else
  begin
    Result := False;
    exit;
  end;
  Memo1.Lines.Add('okuyucu:' + IntToStr(OkuyucuNo));
  Memo1.Lines.Add('SonOkunan:' + SonOkunan);
  Memo1.Lines.Add('oku1:' + oku1);
  Memo1.Lines.Add('oku:' + Oku);
  if (SonOkunan <> Oku) then
  begin
    try
      if (OkuyucuNo = ReaderNo) or (OkuyucuNo = YReaderNo) then
      begin
        if OkuyucuTur <> 4 then
          KartKontrol(FloatToStr(StrToInt64('$' + Oku)), OkuyucuNo)
        else
          KartKontrol(Oku, OkuyucuNo);
      end
      else
      begin
        KartKontrolYemek(inttostr(StrToInt('$' + Oku)), OkuyucuNo);
      end;
      SonOkunan := Oku;
      Result := True;
    except
      on E: Exception do
        LBHata.Caption := 'Hata : ' + E.Message;
    end;
  end
  else
    Result := False;
  Application.ProcessMessages;
end;

procedure TAnaForm.MemoTemizleTimer(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TAnaForm.YeniDonemAlgila();
begin
  //
end;

procedure TAnaForm.TrayIpucu(s: string);
var
  i: Integer;
begin
  for i := 0 to 63 do
    tray.szTip[i] := #0;
  for i := 0 to length(s) do
    tray.szTip[i] := s[i + 1];
end;

procedure TAnaForm.AddInfo(const s: string);
begin
  Memo1.Lines.Add(s);
  Memo1.Refresh;
end;

procedure TAnaForm.ReadDeviceStatus;
var
  s: widestring;
  ErrorCode, Value, i, dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond: integer;
begin
  if czkem.GetFirmwareVersion(devid, s) then
    AddInfo('Firmware Version: ' + s)
  else
  begin
    czkem.GetLastError(ErrorCode);
    AddInfo(format('! GetFirmwareVersion ErrorNo.=%d', [ErrorCode]));
  end;
  if czkem.GetSerialNumber(devid, s) then
    AddInfo('Serial Number: ' + s)
  else
  begin
    czkem.GetLastError(ErrorCode);
    AddInfo(format('! GetSerialNumber ErrorNo.=%d', [ErrorCode]));
  end;

  if czkem.GetProductCode(devid, s) then
    AddInfo('ProductCode: ' + s)
  else
  begin
    czkem.GetLastError(ErrorCode);
    AddInfo(format('! GetProductCode ErrorNo.=%d', [ErrorCode]));
  end;

  if czkem.GetDeviceTime(devid, dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond) then
    AddInfo(format('DeviceTime=%d-%d-%d %d:%d:%d', [dwYear, dwMonth, dwDay, dwHour, dwMinute, dwSecond]))
  else
  begin
    czkem.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceTime ErrorNo.=%d', [ErrorCode]));
  end;

  for i := 1 to length(StatusNames) do
    if czkem.GetDeviceStatus(devid, i, Value) then
      AddInfo(format('%s: %d', [StatusNames[i], Value]))
    else
    begin
      czkem.GetLastError(ErrorCode);
      AddInfo(format('! GetDeviceStatus(%d) ErrorNo.=%d', [i, ErrorCode]));
    end;
end;

procedure TAnaForm.ReadDeviceStatusAttend(Attend: TFKAttend);
var
  s: integer;
  ErrorCode: integer;
begin
  if Attend.GetDeviceStatus(1, s) = 1 then
    AddInfo('The number of managers existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(2, s) = 1 then
    AddInfo('The number of general users existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(3, s) = 1 then
    AddInfo('The number of fingerprint data existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(4, s) = 1 then
    AddInfo('The number of password data existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(5, s) = 1 then
    AddInfo('The number of new management data existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(6, s) = 1 then
    AddInfo('The number of new Income/Outgoing existing-data. : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(7, s) = 1 then
    AddInfo('The number of the entire management existing –data. : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(8, s) = 1 then
    AddInfo('The number of the entire Income/Outgoing existing-data. : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
  if Attend.GetDeviceStatus(9, s) = 1 then
    AddInfo('The number of card data existing currently : ' + inttostr(s))
  else
  begin
    Attend.GetLastError(ErrorCode);
    AddInfo(format('! GetDeviceStatus ErrorNo.=%d', [ErrorCode]));
  end;
end;

function TAnaForm.HIDokuyucuBaslat(czkem: TCZKEM; PortNumarasi: integer): integer;
var
  ErrorCode: integer;
  c: Boolean;
  comstr: string;
begin
  if BTNAc.Tag = 1 then
  begin
    Adim('Port Kapatýlýyor');
    czkem.RefreshData(DevID);
    czkem.EnableDevice(DevID, True);
    czkem.Disconnect;
    BTNAc.Tag := 0;
    BTNAc.Caption := 'BAÞLAT';
    Adim('Port kapatýldý');
  end
  else
  begin
    Adim('Port Açýlýyor');
    Adim('  devid := 1;');
    // kastamon ugurlu bu cihazdan iki tane kullanýyor  pdks de device id 1 olmalý
    // yemekhane için device id 2 olmasý gerekiyor yoksa device connected=0 hatasý dönüyor
    devid := 1;
    Adim('  czkem.SetCommPassword(0);');
    czkem.SetCommPassword(0);
    Adim('  comstr := ''COM' + IntToStr(PortNumarasi) + '''');
    comstr := 'COM' + IntToStr(PortNumarasi);
    if pos('COM', uppercase(comstr)) = 1 then
    begin
      Adim('  Comport ile baðlanýyor');
      Commport := PortNumarasi;
      czkem.Commport := Commport;
      c := czkem.Connect_Com(Commport, DevID, BoudRate);
      Adim('  Comport ile baðlanma bitti');
    end
    else
    begin
      Adim('  TCP/IP ile baðlanýyor');
      c := czkem.Connect_net(comstr, devid);
      devid := 1;
    end;
    if c then
    begin
      Adim('  AddInfo(''Device Connected.'');');
      AddInfo('Device Connected.');
      ReadDeviceStatus(czkem);
      BTNAc.Tag := 1;
      BTNAc.Caption := 'BÝTÝR';
      Adim('    Connected bitti');
    end
    else
    begin
      Adim('  Hata Oluþtu');
      czkem.GetLastError(ErrorCode);
      Adim('  Hata:' + format('! ConnectDevice ErrorNo.=%d', [ErrorCode]));
      AddInfo(format('! ConnectDevice ErrorNo.=%d', [ErrorCode]));
    end;
    AddInfo(' ');
  end;
end;

function TAnaForm.GetFileVersiyon(): string;
var
  s: string;
  n, Len: DWORD;
  Buf: PChar;
  Value: PChar;
begin
  s := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(s), n);
  Buf := AllocMem(n);
  GetFileVersionInfo(PChar(s), 0, n, Buf);
  VerQueryValue(Buf, 'StringFileInfo\041F04E6\FileVersion', Pointer(Value), Len);
  FreeMem(Buf, n);
  Result := Value;
end;

procedure TAnaForm.KartKontrol(KARTID: string; OkuyucuNo: integer);
begin
  if Tablo.cnn.Connected then
  begin
    try
      Tablo.sp_KARTOKU.Close;
      Tablo.sp_KARTOKU.SQL.Text := 'exec p_KARTOKU ''' + TRim(KARTID) + ''',' + IntToStr(OkumaAra) + ',' + IntToStr(MaxVar) + ',' + IntToStr(OkuyucuNo);
      Tablo.sp_KARTOKU.Open;
    except

    end;
  end
  else
  begin
    // Baðlantý yok demektir bu
    Tablo.GeciciKartEkle(TRim(KARTID));
  end;

  {
    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:='p_KARTOKU ''' + KARTID + ''',' +inttostr(okumaara) + ',' + inttostr(MaxVar);
    Tablo.Query2.ExecSQL;
    }
  try
    Tablo.TabStatus.Close;
    Tablo.TabStatus.Open;
    Tablo.TabStatus.Last;
  except
  end;
  // showmessage(str);
  try
    CardAnswer(PortNe, OkuyucuNo, '+3' + DBText1.Caption + '#', 1000);
    if (pos('SÜRE DOLMADI', Tablo.sp_KARTOKU.Fields[0].AsString) > 0) and (SSure <> '') then
    begin
      PlaySound(PChar(SSure), 0, SND_FILENAME + SND_ASYNC);
    end
    else if (pos('GÝRÝÞ YAPTI', Tablo.sp_KARTOKU.Fields[0].AsString) > 0) and (SGiris <> '') then
    begin
      PlaySound(PChar(SGiris), 0, SND_FILENAME + SND_ASYNC);

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select TOP 1 ID from PERS_PDKS ORDER BY GIRIS DESC';
      Tablo.Query1.Open;
      Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger, 'GIRIS');
      ORelay(PortNe, OkuyucuNo, 2);
    end
    else if (pos('ÇIKIÞ YAPTI', Tablo.sp_KARTOKU.Fields[0].AsString) > 0) and (SCikis <> '') then
    begin
      PlaySound(PChar(SCikis), 0, SND_FILENAME + SND_ASYNC);
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select top 1 ID from PERS_PDKS ORDER BY CIKIS DESC';
      Tablo.Query1.Open;
      Camera.ResimKaydet(Tablo.Query1.Fields[0].AsInteger, 'CIKIS');
      ORelay(PortNe, OkuyucuNo, 2);
    end
    else if (pos('GEÇERSÝZ KART', Tablo.sp_KARTOKU.Fields[0].AsString) > 0) and (SGecersiz <> '') then
      PlaySound(PChar(SGecersiz), 0, SND_FILENAME + SND_ASYNC);
  except
  end;
  STR := '';
  try
    Tablo.TabStatusAfterScroll(Tablo.TabStatus);
  except
  end;
end;

procedure TAnaForm.ComPort1RxChar(Sender: TObject; Count: Integer);
var
  STR1: string;
  sonuc: string;
  id: string;
begin
  ComPort1.ReadStr(STR1, Count);
  STR := STR + STR1;
  if OkuyucuTur <> 5 then
  begin
    if OkuyucuTur <> 3 then
    begin
      if pos(#13, STR) > 0 then
        if ReaderNo = 128 then
          KartKontrol(copy(STR, 1, pos(#13, STR) - 1), ReaderNo)
        else
          KartKontrolYemek(copy(STR, 1, pos(#13, STR) - 1), ReaderNo)
    end
    else
    begin
      isle();
    end;
  end
  else
  begin // anvis parmak izi okuyucu...
    if pos(')', STR) > 0 then
    begin
      id := inttostr(AnvizParmakOku(STR));
      if ReaderNo = 128 then
        KartKontrol(id, ReaderNo)
      else
        KartKontrolYemek(id, ReaderNo);
    end;
  end;
  sonuc := ParmakIziOkuyucu(ComPort1, STR1);
  { if sonuc='basla' then
    Timer3.Enabled:=true;
    if sonuc <> '0' then
    begin
    Memo1.Lines.Add(sonuc);
    if ReaderNo = 128 then
    KartKontrol(copy(sonuc,6,maxint), ReaderNo)
    else
    KartKontrolYemek(copy(sonuc,6,maxint), ReaderNo)
    end; }
end;

procedure TAnaForm.FormCreate(Sender: TObject);
begin
  dtpVerileriAl.DateTime := Now;
  Adim('Caption ');
  // Caption := 'PDKS Giriþ-Çýkýþ Kontrol (ver.' + GetFileVersiyon + ')';
  GECSURE := 1;
  getmem(tray, 500);
  tray.cbSize := tray.cbSize;
  tray.uCallbackMessage := $200;
  TrayIpucu(Caption);
  tray.Wnd := Handle;
  tray.uFlags := 7;
  tray.uID := 7;
  Adim('');
  tray.hIcon := Application.icon.Handle;
  Shell_NotifyIcon(0, tray);
  LBTarSa.Caption := Tablo.QTarSa.fieldbyname('TarSa').AsString;
  SonOkunan := '';
  if (OkuyucuTur = 0) or (OkuyucuTur = 1) or (OkuyucuTur = 3) then
    ComLed1.ComPort := ComPort1
  else
    ComLed1.ComPort := nil;

  Memo1.Visible := HaraketListe;
  Adim('Anaform create bitti');
  izinler.Visible := IzinGirisi;
  if HizmetBas then
    BTNAcClick(BTNAc);
  if SimgeDur then
    Close;

  FkAttendSorgula.Interval := CalismaAraligi;
  if OkuyucuTur = 9 then
  begin
    SbAttendVeriAl.Visible := True;
    dtpVerileriAl.Visible := True;
  end
  else
  begin
    SbAttendVeriAl.Visible := False;
    dtpVerileriAl.Visible := False;
  end;

  if (OkuyucuTur = 8) or (OkuyucuTur = 10) then
    btnVerileriAl.Visible := True
  else
    btnVerileriAl.Visible := False;

    //Tablolo.YeniEklenenlerSQL;
//    qry1.Close;
//    qry1.Open;
end;

function TAnaForm.ATTENDOkuyucuBaslat(Attend: TFKAttend; IPNUMBER, PortNumber: String; Timeout: integer; ProtocolType: integer; Netpassword: integer; Lisance: integer): integer;
var
  ErrorCode: integer;
  c: Boolean;
  comstr: string;
  ResultCode: Integer;
begin
  if BTNAc.Tag = 1 then
  begin
    Adim('Port Kapatýlýyor');
    // Attend.dRefreshData(DevId);
    Attend.EnableDevice(0);
    // anEnabledFlag=0 forbids the operation with a message “Working…” prompted;
    // anEnabledFlag=1 allows it with the normal display shown.
    Attend.Disconnect;
    BTNAc.Tag := 0;
    BTNAc.Caption := 'BAÞLAT';
    Adim('Port kapatýldý');
  end
  else
  begin
    Adim('Port Açýlýyor');
    Adim('  devid := 1;');
    // kastamon ugurlu bu cihazdan iki tane kullanýyor  pdks de device id 1 olmalý
    // yemekhane için device id 2 olmasý gerekiyor yoksa device connected=0 hatasý dönüyor
    devid := 1;
    Adim('  Attend.SetCommPassword(0);');
    // Attend.SetCommPassword(0);
    Adim('  TCP/IP ile baðlanýyor');
    ResultCode := Attend.ConnectNet(ReaderNo, IPNUMBER, strtoint(PortNumber), Timeout, ProtocolType, Netpassword, Lisance);
    devid := 1;
    if ResultCode = RUN_SUCCESS then
    begin
     // ComLed1.State := lsOn;
      FkAttendSorgula.Enabled := True;
      Adim('  AddInfo(''Device Connected.'');');
      AddInfo('Baðlantý Baþlangýç Durum : ' + ReturnResultPrint(ResultCode));
      AddInfo('Device Connected.');
      ReadDeviceStatusAttend(Attend);
      BTNAc.Tag := 1;
      BTNAc.Caption := 'BÝTÝR';
      Adim('    Connected bitti');
    end
    else
    begin
      Adim('  Hata Oluþtu');
      Attend.GetLastError(ErrorCode);
      FkAttendSorgula.Enabled := False;
    //  ComLed1.State := lsOff;
      AddInfo('Baðlantý Baþlangýç Durum : ' + ReturnResultPrint(ResultCode));
      Adim('  Hata:' + format('! ConnectDevice ErrorNo.=%d', [ResultCode]));
      AddInfo(format('! ConnectDevice ErrorNo.=%d', [ResultCode]));
      AddInfo('! ConnectDevice =%d' + ReturnResultPrint(ResultCode));

    end;
    AddInfo(' ');
  end;

  //
end;

procedure TAnaForm.BTNAcClick(Sender: TObject);
var
  Okunan: string;
  OkumaGecikme: integer;
  HexCode: string;
  dongu: Boolean;
  saattar: string;
  i: integer;
begin
  Oku := False;
  oku1 := False;
  okumabasla := False;
  okubellek1 := False;
  okubellek2 := False;
  FPCevaplama1 := False;
  uFingerPrint.Memo := Memo1;
  Adim('OkuyucuTur=' + IntToStr((OkuyucuTur)));
  if BTNAc.Caption = 'BAÞLAT' then
  begin
    BTNAc.Caption := 'BÝTÝR';
  //  ComLed1.State := lsOn;
    if (OkuyucuTur = 0) or (OkuyucuTur = 1) or (OkuyucuTur = 3) then
    // ComboBox in index deðerleri...
    begin
      portuAc;
      if OkuyucuTur = 3 then
      begin
        ParmakIziGenelMesaj(FPCihazAdresleri);
        {
          SendCommand(ComPort1, '');
          oku1:=true;
          while BTNAc.Caption <> 'BAÞLAT' do
          begin
          if (oku) and (ParmakIzihazir) then
          begin
          If not okubellek1 then
          begin
          ComPort1.Close;
          portuAc;
          HexCode:=CihazAdres + ' 04 00 00 00 00 00 00 00 00 00';
          HexCode:= HexCode + ' ' + ToplamBul(HexCode) + ' 0A';
          ComPort1.WriteStr(HexToStr( HexCode) );
          dongu:=false;
          while not dongu do
          begin
          if gelen<>'' then
          If StrToHex( gelen[Length(gelen)] )='0A' then
          dongu:=true;
          Application.ProcessMessages;
          end;
          okubellek1:=true;
          If not okubellek2 then
          begin
          HexCode:=CihazAdres + ' EB 00 00 00 00 00 00 00 00 00';
          HexCode:= HexCode + ' ' + ToplamBul(HexCode) + ' 0A';
          ComPort1.WriteStr(HexToStr( HexCode) );
          dongu:=false;
          while not dongu do
          begin
          if gelen<>'' then
          If StrToHex( gelen[Length(gelen)] )='0A' then
          dongu:=true;
          Application.ProcessMessages;
          end;
          okubellek2:=true;
          end;
          end;
          if (okubellek1) and (okubellek2) then
          begin
          BTNAc.Caption:='BAÞLAT';
          tmrSupremaTarama.Enabled := True;
          ParmakIziOkumayaBasla := True;
          end;
          {
          begin
          ComPort1.Close;
          portuAc;
          HexCode:=CihazAdres + ' 04 00 00 00 00 00 00 00 00 00';
          HexCode:= HexCode + ' ' + ToplamBul(HexCode) + ' 0A';
          ComPort1.WriteStr(HexToStr( HexCode) );
          dongu:=false;
          gelen:='';
          while not dongu do
          begin
          if gelen<>'' then
          If StrToHex( gelen[Length(gelen)] )='0A' then
          dongu:=true;
          For i:=0 to 10 do
          begin
          Sleep(50);
          Application.ProcessMessages;
          end;
          end;
          end;
          end;
          Application.ProcessMessages;
          end;
          }
      end;
    end
    else if OkuyucuTur = 2 then
    begin
      BTNAc.Caption := 'BÝTÝR';
     // ComLed1.State := lsOn;
      OpenPort(PortNe);
      OkumaGecikme := GENINI.ReadInteger(Ops_OKUMAGECIKME, 500);
      Memo1.Lines.Add('okuma gecikme : ' + inttostr(OkumaGecikme));
      tmrOkuyucu2.Enabled := True;
      tmrOkuyucu2.Interval := OkumaGecikme;
    end
    else if OkuyucuTur = 4 then
    begin
      BTNAc.Caption := 'BÝTÝR';
     // ComLed1.State := lsOn;
      OOpenPort(PortNe);
      OkumaGecikme := GENINI.ReadInteger(Ops_OKUMAGECIKME, 500);
      Memo1.Lines.Add('okuma gecikme : ' + inttostr(OkumaGecikme));
      while BTNAc.Caption = 'BÝTÝR' do
      begin
        KartOku(PortNe, ReaderNo);
        sleep(OkumaGecikme);
        // KartOku(YPortNe, YReaderNo);
        // Sleep(OkumaGecikme);
        Application.ProcessMessages;
        if Application.Terminated then
          break;
      end;
    end
    else if OkuyucuTur = 5 then // anviz parmak izi okuyucu;
    begin
      portuAc;
      //ComLed1.State := lsOn;
      ComPort1.WriteStr(anBaslat);
      saattar := anTarih + copy(inttostr(yearof(Now)), 3, 2) + ',' + inttostr(MonthOf(Now)) + ',' + IntToStr(DayOf(Now)) + ')';
      ComPort1.WriteStr(saattar);
      saattar := anSaat + inttostr(HourOf(Now)) + ',' + inttostr(MinuteOf(Now)) + ',' + IntToStr(SecondOf(Now)) + ')';
      ComPort1.WriteStr(saattar);
      ComPort1.WriteStr(anBaslat);
    end
    else if (OkuyucuTur = 6) then
    begin
      Adim('S200 PDKSVARMI-2');
      if Pdks then
      begin
        Adim('S200 PDKSVARMI var');
        HIDokuyucuBaslat(CZKEMPDKS, PortNe);
        Adim('S200 HIDokuyucuBaslatPDKS çalýþtýrýldý');
      end;
      Adim('S200 YemekhaneVARMI');

      if GENINI.ReadBoolean(Ops_YemekhaneVARMI, False) then
        if Yemekhane then
        begin
          Adim('S200 YemekhaneVARMI var');
          HIDokuyucuBaslat(CZKEMYemekhane, YPortNe);
          Adim('S200 HIDokuyucuBaslatYemekhane çalýþtýrýldý');
        end;
    end
    else if (OkuyucuTur = 7) then
    begin
      Adim('X680 PDKSVARMI-2');
      if Pdks then
      begin
        Adim('X680 PDKSVARMI var');
        HIDokuyucuBaslat(CZKEMPDKS, PortNe);
        Adim('X680  çalýþtýrýldý');
      end;

      Adim('X680 YemekhaneVARMI');
      if GENINI.ReadBoolean(Ops_YemekhaneVARMI, False) then
        if Yemekhane then
        begin
          Adim('X680 YemekhaneVARMI var');
          HIDokuyucuBaslat(CZKEMYemekhane, YPortNe);
          Adim('X680  çalýþtýrýldý');
        end;
    end
    else if (OkuyucuTur = 8) then // CZKEMTCPIP TCP IP baðlantý
    begin
      Adim('A-10 PDKSVARMI-2');
      if Pdks then
      begin
        Adim('A10 PDKSVARMI var');
        CZKEMTCPIPOkuyucuBaslat(CZKEMPDKS, IpNe, YonPortNe);
        Adim('A10  çalýþtýrýldý');
      end;
      Adim('A10 YemekhaneVARMI');
      if GENINI.ReadBoolean(Ops_YemekhaneVARMI, False) then
        if Yemekhane then
        begin
          Adim('A10 YemekhaneVARMI var');
          CZKEMTCPIPOkuyucuBaslat(CZKEMYemekhane, YIpNe, YYonPortNe);
          Adim('A10  çalýþtýrýldý');
        end;
    end;
    if (OkuyucuTur = 9) then // FKAttend TCP IP baðlantý
    begin
      Adim('FKAttend PDKSVARMI');

      if Pdks then
      begin
        Adim('FKAttend PDKSVARMI var');
        ATTENDOkuyucuBaslat(FKAttend, IpNe, YonPortNe, TimeoutNe, UDPne, PassNe, LISANS_NUMARASI);
        Adim('FKAttend  çalýþtýrýldý');
      end;
      Adim('FKAttend YemekhaneVARMI');
      if GENINI.ReadBoolean(Ops_YemekhaneVARMI, False) then
        if Yemekhane then
        begin
          Adim('FKAttend YemekhaneVARMI var');
          ATTENDOkuyucuBaslat(FKAttendy, YIpNe, YYonPortNe, YTimeoutNe, YUDPne, YPassNe, LISANS_NUMARASI);
          Adim('FKAttend  çalýþtýrýldý');
        end;
        CZKEMPDKS.RegEvent(Devid,32767);
    end;
       if (OkuyucuTur = 10) then // CZKEMTCPIP TCP IP baðlantý   SSR_*..
    begin
      Adim('MP PDKSVARMI-2');
      if Pdks then
      begin
        Adim('MP PDKSVARMI var');
        CZKEMTCPIPOkuyucuBaslat(CZKEMPDKS, IpNe, YonPortNe);
        Adim('MP  çalýþtýrýldý');
      end;
      Adim('MP YemekhaneVARMI');
      if GENINI.ReadBoolean(Ops_YemekhaneVARMI, False) then
        if Yemekhane then
        begin
          Adim('MP YemekhaneVARMI var');
          CZKEMTCPIPOkuyucuBaslat(CZKEMYemekhane, YIpNe, YYonPortNe);
          Adim('MP  çalýþtýrýldý');
        end;
        CZKEMPDKS.RegEvent(Devid,32767);
    end;

  end
  else
  begin
    if (OkuyucuTur = 0) or (OkuyucuTur = 1) or (OkuyucuTur = 3) or (OkuyucuTur = 5) then
    begin
      BTNAc.Caption := 'BAÞLAT';
     // ComLed1.State := lsOff;
      ComPort1.Connected := False;
      Oku := False;
    end
    else if OkuyucuTur in [2, 4] then
    begin
      BTNAc.Caption := 'BAÞLAT';
    //  ComLed1.State := lsOff;
      if OkuyucuTur = 2 then
        ClosePort(PortNe)
      else
        OClosePort(PortNe);
    end
    else if OkuyucuTur in [6] then
    begin
      BTNAc.Caption := 'BAÞLAT';
     // ComLed1.State := lsOff;
      Adim('S200 PDKSVARMI-1');
      if Pdks then
      begin
        Adim('S200 PDKSVARMI var');
        HIDokuyucuBaslat(CZKEMPDKS, PortNe);
        Adim('S200 HIDokuyucuBaslatPDKS çalýþtýrýldý');
      end;

      Adim('S200 YemekhaneVARMI');
      if Yemekhane then
      begin
        Adim('S200 YemekhaneVARMI var');
        HIDokuyucuBaslat(CZKEMYemekhane, YPortNe);
        Adim('S200 HIDokuyucuBaslatYemekhane çalýþtýrýldý');
      end;
    end
    else if OkuyucuTur in [8] then
    begin
      BTNAc.Caption := 'BAÞLAT';
      Adim('A10 PDKSVARMI-1');
      if Pdks then
      begin
        Adim('A10 PDKSVARMI var');
        CZKEMPDKS.RefreshData(DevID);
        CZKEMPDKS.EnableDevice(DevID, True);
        CZKEMPDKS.Disconnect;
        Adim('A10 bitir çalýþtýrýldý');
      end;

      Adim('A10 YemekhaneVARMI');
      if Yemekhane then
      begin
        CZKEMYemekhane.RefreshData(DevID);
        CZKEMYemekhane.EnableDevice(DevID, True);
        CZKEMYemekhane.Disconnect;
      end;
    end

    else if OkuyucuTur = 9 then
    begin
      BTNAc.Caption := 'BAÞLAT';
      Adim('FKAttend PDKSVARMI-1');
      if Pdks then
      begin
        Adim('FKAttend PDKSVARMI var');
        FKAttend.Refresh;
        FKAttend.Disconnect;
        FkAttendSorgula.Enabled := False;
      //  ComLed1.State := lsOff;
        Adim('FKAttend bitir çalýþtýrýldý');
      end;
      Adim('FKAttendy YemekhaneVARMI');
      if Yemekhane then
      begin
        FKAttendy.Refresh;
        FKAttendy.Disconnect;
        FkAttendSorgula.Enabled := False;
    //    ComLed1.State := lsOff;
        Adim('FKAttendy bitir çalýþtýrýldý');
      end;
    end else if  OkuyucuTur in [10] then
    begin
      BTNAc.Caption := 'BAÞLAT';
      Adim('MP PDKSVARMI-1');
      if Pdks then
      begin
        Adim('MP PDKSVARMI var');
        CZKEMPDKS.RefreshData(DevID);
        CZKEMPDKS.EnableDevice(DevID, True);
        CZKEMPDKS.Disconnect;
        Adim('MP bitir çalýþtýrýldý');
      end;

      Adim('MP YemekhaneVARMI');
      if Yemekhane then
      begin
        CZKEMYemekhane.RefreshData(DevID);
        CZKEMYemekhane.EnableDevice(DevID, True);
        CZKEMYemekhane.Disconnect;
      end;

    end;

    tmrSupremaTarama.Enabled := False;
  end;
end;

procedure TAnaForm.SeriPortAyarlar1Click(Sender: TObject);
begin
  // comPort1.LoadSettings(stRegistry, 'software\genper\');
  // Böyle deðil de þöyle olmasý gerekiyormuþ :D Tamamdýr bu
  // comPort1.LoadSettings(stRegistry, '\software\genper\');
  ComPort1.LoadSettings(stRegistry, '\software\GENTEGRE2\genper\');
  ComPort1.ShowSetupDialog;
  ComPort1.StoreSettings(stRegistry, '\software\GENTEGRE2\genper\');
end;

procedure TAnaForm.ProgramA1Click(Sender: TObject);
begin
  AnaForm.show;
end;

procedure TAnaForm.Kapat1Click(Sender: TObject);
begin
  if Application.MessageBox('Programdan çýkmak istediðinize emin misiniz ?', 'Uyarý !!!', 36) = 6 then
  begin
    Shell_NotifyIcon(2, tray);
    FreeMem(tray);
    Application.Terminate;
  end;

end;

procedure TAnaForm.FkAttendKaydet;
begin
  /// Kaydeyt iþelemi yapýlacak
end;

procedure TAnaForm.FkAttendSorgulaTimer(Sender: TObject);
begin
  if Pdks then
    AttendLogAl(FKAttend, Now);
  if Yemekhane then
    AttendLogAl(FKAttendy, Now);

end;

procedure TAnaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := canone;
  AnaForm.Hide;
end;

procedure TAnaForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  a, b: integer;
begin
  // $201 sol tuþ basýldý
  // $202 sol tuþ býrakýlsý
  // $203 çift týklandý
  // $204 sað tuþ basýldý
  // $205 sað tuþ býrakýldý
  // $206 sað tuþ çift týklandý

  if X = $203 then
    AnaForm.show;
  if X = $205 then
  begin
    a := mouse.CursorPos.X;
    b := mouse.CursorPos.Y;
    PopupMenu1.Popup(a, b);
  end;
end;

procedure TAnaForm.Timer1Timer(Sender: TObject);
begin
  Adim('Timer1Timer');
  Tablo.QTarSa.Close;
  Tablo.QTarSa.Open;
  LBTarSa.Caption := Tablo.QTarSa.fieldbyname('TarSa').AsString;
  Adim('Timer1Timer bitti');
end;

procedure TAnaForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  { if BTNAc.Caption='BAÞLAT' THEN
    Exit;
    STR:=STR + key;
    if length(str)=7 then
    KartKontrol(trim(str)); }
end;

procedure TAnaForm.cxGrid1DBTableView1CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  val: string;
begin
  val := VarAsType(AViewInfo.GridRecord.DisplayTexts[tvGirCik.Index], varString);
  if val = 'GÝRÝÞ' then
  begin
    ACanvas.Canvas.Font.Color := clNavy;
    ACanvas.Canvas.Brush.Color := clMoneyGreen;
  end
  else
  begin
    ACanvas.Canvas.Font.Color := clRed;
    ACanvas.Canvas.Brush.Color := clInfoBk;
  end;

  SetBkMode(ACanvas.Canvas.Handle, TRANSPARENT);

  ACanvas.DrawText(AViewInfo.GridRecord.DisplayTexts[AViewInfo.Item.Index], AViewInfo.Bounds, 0);
end;

procedure TAnaForm.Timer2Timer(Sender: TObject);
begin
  Adim('Timer2Timer ');
  if SCameraEkran then
    BTNKameraClick(BTNKamera);
  ResimPanel.Visible := SResim;
  Timer2.Enabled := False;
  Adim('Timer2Timer bitti');

end;

procedure TAnaForm.ProgramAyarlar1Click(Sender: TObject);
begin
  Application.CreateForm(TAyarlarForm, AyarlarForm);
  AyarlarForm.showmodal;
  AyarlarForm.destroy;
end;

procedure TAnaForm.Hakknda1Click(Sender: TObject);
begin
  Application.CreateForm(TAboutBox, AboutBox);
  AboutBox.showmodal;
end;

procedure TAnaForm.BTNKameraClick(Sender: TObject);
begin
  Camera.show;
end;

procedure TAnaForm.FormResize(Sender: TObject);
begin
  BTNKamera.Left := Panel1.Width - BTNKamera.Width - BTNResim.Width - 1;
  BTNResim.Left := Panel1.Width - BTNResim.Width;
end;

procedure TAnaForm.BTNResimClick(Sender: TObject);
begin
  ResimPanel.Visible := not ResimPanel.Visible;
end;

procedure TAnaForm.btnVerileriAlClick(Sender: TObject);
begin
  Application.CreateForm(TFrmVeriAktarým, FrmVeriAktarým);
  FrmVeriAktarým.showmodal;
  FrmVeriAktarým.destroy;
  //SaveGLogs();
end;

function TAnaForm.SaveGLogs(): integer;
var
  dwEnrollNumber,dwEMachineNumber,dwTMachineNumber, dwMachineNumber, dwInOutMode, dwVerifyMode,
  dwYear, dwMonth, dwDay, dwHour, dwMinute,dwSecond,dwWorkCode,PCACOUNT,PSCOUNT: Integer;
  TTarih: TDateTime;
  Tarih : TDate;
  SonTarih: string;
  Saat :TTime;
  S: String;
  LogBilgiler: array of TLogbilgileri;
  I,Hata,AraHt: Integer;
  TimeStr,Name,Password,dsEnrollNumber:WideString;
  Enabled:WordBool;
begin
//  Tablo.Query2.Close;
//  Tablo.Query2.SQL.Text := 'SELECT COUNT(*) FROM PERS_CIHAZ_ALINAN';
//  Tablo.Query2.open;
//   if Tablo.Query2.Fields[0].AsInteger=0 then
//     PCACOUNT:=10000
//   else
//     PCACOUNT:=Tablo.Query2.Fields[0].AsInteger;
//  Memo1.Lines.Add('PCACOUNT : '+IntToStr(PCACOUNT)+'');
//  Tablo.Query3.Close;
//  Tablo.Query3.SQL.Text := 'SELECT COUNT(*) FROM PER_SABIT';
//  Tablo.Query3.open;
//   if Tablo.Query3.RecordCount>0 then
//     PSCOUNT:=Tablo.Query3.Fields[0].AsInteger
//   else
//     PSCOUNT:=0;
//  Memo1.Lines.Add('PSCOUNT : '+IntToStr(PSCOUNT)+'');
//  Result := 0;

  //SetLength(LogBilgiler, PCACOUNT+PSCOUNT);

  Setlength(logBilgiler,100000);
  Memo1.Lines.Add('SetLength yapýlýyor. ' );
  if OkuyucuTur=10 then begin
    if CZKEMPDKS.ReadGeneralLogData(DevId) then
     while CZKEMPDKS.SSR_GetGeneralLogData(DevId, dsEnrollNumber, dwVerifyMode, dwInOutMode,
            dwYear,dwMonth, dwDay, dwHour, dwMinute,dwSecond,dwWorkCode) do begin
        Tarih :=EncodeDate(dwYear, dwMonth, dwDay);
        Saat := EncodeTime(dwHour, dwMinute, dwSecond, 0);
        TTarih := Tarih + Saat;
        Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor . ');
        if dsEnrollNumber<>'' then begin
          Memo1.Lines.Add('Kayýt No : ' +inttostr(Result));
          LogBilgiler[Result].Kod := StrToInt(dsEnrollNumber);
          Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor.Kod: '+dsEnrollNumber );
          Memo1.Lines.Add('Önce LogBilgiler geçiçiye alýnýyor.ReaderNo: '+IntToStr(DevID) );
          LogBilgiler[Result].ReaderNo := IntToStr(DevID);
          Memo1.Lines.Add('sonra LogBilgiler geçiçiye alýnýyor.ReaderNo: '+IntToStr(DevID) );
          Memo1.Lines.Add('Önce LogBilgiler geçiçiye alýnýyor.TTarih: '+DateTimeToStr(ttarih));
          LogBilgiler[Result].Tarih := TTarih;
          Memo1.Lines.Add('Sonra LogBilgiler geçiçiye alýnýyor.TTarih: '+DateTimeToStr(ttarih) );
          inc(Result);

        end;

     end;
  end else
  begin
    if CZKEMPDKS.ReadGeneralLogData(DevId) then
     while CZKEMPDKS.GetGeneralLogData(dwMachineNumber, dwTMachineNumber,
      dwEnrollNumber, dwEMachineNumber, dwVerifyMode, dwInOutMode, dwYear,
      dwMonth, dwDay, dwHour, dwMinute) do begin

      Tarih :=EncodeDate(dwYear, dwMonth, dwDay);
      Saat := EncodeTime(dwHour, dwMinute, dwSecond, 0);
        if TimeToStr(Saat) = ''  then
        begin showmessage('deneme') end;
      TTarih := Tarih + Saat ;
      Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor . ');
      LogBilgiler[Result].Kod := dwEnrollNumber;
       Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor.Kod: '+dsEnrollNumber );
      LogBilgiler[Result].ReaderNo := IntToStr(DevID);
      Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor.ReaderNo: '+IntToStr(DevID) );
      LogBilgiler[Result].Tarih := TTarih;
      Memo1.Lines.Add('LogBilgiler geçiçiye alýnýyor.TTarih: '+dsEnrollNumber );
      inc(Result);
     end;
  end;

  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'Truncate table PERS_CIHAZ_ALINAN';
  Tablo.Query5.ExecSQL;
  SonTarih:='2100-01-01';
    for I := 0 to length(LogBilgiler) - 1 do
    begin
      if LogBilgiler[I].ReaderNo <> '' then      //Cihaz kontrol
      begin

         CihazdanAl(IntToStr(LogBilgiler[I].Kod), FormatDateTime('yyyy-mm-dd hh:nn:ss', LogBilgiler[I].Tarih));
         Memo1.Lines.Add('LogBilgiler Dataya yazýlýyor alýnýyor.kod: '+IntToStr(LogBilgiler[I].Kod) +'------> '+FormatDateTime('yyyy-mm-dd hh:nn:ss', LogBilgiler[I].Tarih) );
      end;
    end;
//  for I := 0 to length(LogBilgiler) - 1 do
//  begin
//    if LogBilgiler[I].ReaderNo <> '' then      //Cihaz kontrol
//    begin
//    //Son yazýlan
//       Query1EOF(LogBilgiler[I].Tarih);
//       Tablo.Query1.First;
//         while not Tablo.Query1.Eof do begin
//          CihazdanAl(Tablo.Query1.Fields[0].AsString, FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih));
//          Tablo.Query1.Next;
//         end;
//
//       if DayOfWeek(LogBilgiler[I].Tarih)=7 then begin
//
//          LogBilgiler[I].Tarih:=LogBilgiler[I].Tarih+1;
//
//         Query1EOF(LogBilgiler[I].Tarih);
//         Tablo.Query1.First;
//         while not Tablo.Query1.Eof do begin
//          CihazdanAl(Tablo.Query1.Fields[0].AsString, FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih));
//
//           Tablo.Query2.Close;
//           Tablo.Query2.SQL.Text:='Select PERKOD from PERS_IZINYIL Where PERKOD=:A0';
//           tablo.Query2.Parameters[0].Value:=Tablo.Query1.Fields[1].AsString;
//           Tablo.Query2.Open;
//          if Tablo.Query2.RecordCount<1 then begin
//           Tablo.Query5.Close;
//           Tablo.Query5.SQL.Text:='insert into PERS_IZINYIL(PERKOD,YIL,IZINTUR,GELDIGI_YERDEN_KALAN,TOPLAM) values(:A0,:A1,:A2,:A3,:A4)';
//           tablo.Query5.Parameters[0].Value:= Tablo.Query1.Fields[1].AsString;
//           tablo.Query5.Parameters[1].Value:= YearOf(LogBilgiler[I].Tarih);
//           tablo.Query5.Parameters[2].Value:= 'ÜCRETLÝ GÜN ÝZNÝ';
//           tablo.Query5.Parameters[3].Value:= 0;
//           tablo.Query5.Parameters[4].Value:= 30;
//           Tablo.Query5.ExecSQL;
//          end;
//
//          //Pazar günü notu düþülecek.
//
//            Tablo.Query4.Close;
//            Tablo.Query4.SQL.Text:='Delete from PERS_IZIN where PERKOD=:A0 and IZINTUR=:A1 and AITYIL=:A2 and BASTAR=:A3 and BITTAR=:A4 and TOPLAMIZIN=:A5 and NOTU=:A6';
//            tablo.Query4.Parameters[0].Value:= Tablo.Query1.Fields[1].AsString;
//            tablo.Query4.Parameters[1].Value:='ÜCRETLÝ GÜN ÝZNÝ';
//            tablo.Query4.Parameters[2].Value:=YearOf(LogBilgiler[I].Tarih);
//            tablo.Query4.Parameters[3].Value:=FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih);
//            tablo.Query4.Parameters[4].Value:=FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih);
//            tablo.Query4.Parameters[5].Value:='1';
//            tablo.Query4.Parameters[6].Value:='Pazar Tatili.';
//            Tablo.Query4.ExecSQL;
//
//            Tablo.Query3.Close;
//            Tablo.Query3.SQL.Text:='insert into PERS_IZIN(PERKOD,IZINTUR,AITYIL,BASTAR,BITTAR,TOPLAMIZIN,NOTU) values(:A0,:A1,:A2,:A3,:A4,:A5,:A6)';
//            tablo.Query3.Parameters[0].Value:= Tablo.Query1.Fields[1].AsString;
//            tablo.Query3.Parameters[1].Value:='ÜCRETLÝ GÜN ÝZNÝ';
//            tablo.Query3.Parameters[2].Value:= YearOf(LogBilgiler[I].Tarih);
//            tablo.Query3.Parameters[3].Value:= FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih);
//            tablo.Query3.Parameters[4].Value:= FormatDateTime('yyyy-mm-dd 00:00:00', LogBilgiler[I].Tarih);
//            tablo.Query3.Parameters[5].Value:='1';
//            tablo.Query3.Parameters[6].Value:='Pazar Tatili.';
//            Tablo.Query3.ExecSQL;
//          Tablo.Query1.Next;
//         end;
//       end;
//       //Son yazýlan
//    end;
//  end;

  // ShowMessage('Veriler aktarýldý.');
  Memo1.Lines.SaveToFile('deneme.txt');
 end;

procedure TAnaForm.Query1EOF(Tarih:TDateTime);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='Select KARTNO,PERKOD from PERS_KART pk Where pk.KARTNO not in(Select KARTNO from PERS_CIHAZ_ALINAN Where TARIH between :A0 and :A1) ';
  Tablo.Query1.Parameters[0].Value:= FormatDateTime('yyyy-mm-dd 00:00:00',Tarih);
  Tablo.Query1.Parameters[1].Value:= FormatDateTime('yyyy-mm-dd 23:59:00',Tarih);
  Tablo.Query1.Open;
end;
procedure TAnaForm.EkranYazClick(Sender: TObject);
begin
  //
end;

function TAnaForm.HataVarmi(oku1: string): string;
var
  Hata: string;
begin

  if oku1 = '3000' then
    Hata := 'Genel Hata'
  else if oku1 = '3010' then
    Hata := 'Hatalý port parametresi'
  else if oku1 = '3011' then
    Hata := 'Port daha önceden açýlmýþ'
  else if oku1 = '3012' then
    Hata := 'Port kapatýlamadý'
  else if oku1 = '3013' then
    Hata := 'Aranan port makinada tanýmsýz'
  else if oku1 = '3014' then
    Hata := 'Port aktif deðil'
  else if oku1 = '3020' then
    Hata := 'Hatalý okuyucu parametresi'
  else if oku1 = '3021' then
    Hata := 'Aranan okuyucu bulunamadý'
  else if oku1 = '3022' then
    Hata := 'Okuyucu cevap vermiyor'
  else if oku1 = '3023' then
    Hata := 'Yanlýþ Okuyucu'
  else if oku1 = '3030' then
    Hata := 'Hatalý resim parametresi'
  else if oku1 = '3031' then
    Hata := 'Resim boyutlarý hatalý'
  else if oku1 = '3032' then
    Hata := 'Resim dosyasý bulunamadý'
  else if oku1 = '3033' then
    Hata := 'Timeout parametresi yanlýþ'
  else if oku1 = '3040' then
    Hata := 'Metin parametresi boyutu hatalý'
  else if oku1 = '3050' then
    Hata := 'Desteklenmeyen haberleþme hýzý'
  else if oku1 = '3060' then
    Hata := 'Hatalý parametre'
  else if oku1 = '3061' then
    Hata := 'Kart yok'
  else if oku1 = '3062' then
    Hata := 'Hatalý Kart'
  else if oku1 = '3070' then
    Hata := 'Röle paremetresi hatalý'
  else if oku1 = '3080' then
    Hata := 'Sektor parameteresi hatalý'
  else if oku1 = '3081' then
    Hata := 'Block parametresi hatalý'
  else if oku1 = '3090' then
    Hata := 'Þifre hatasý'
  else if oku1 = '3091' then
    Hata := 'Veri çok uzun'
  else if oku1 = '3100' then
    Hata := 'Kapi Açýk'
  else if (pos('ERROR', oku1) > 0) then
    Hata := oku1
  else
    Hata := '';
  Result := Hata;
end;

procedure TAnaForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    KartKontrol(Edit1.Text, ReaderNo);
    Edit1.Text := '';
    Edit1.SetFocus;
  end;
end;

procedure TAnaForm.Timer3Timer(Sender: TObject);
begin
  Adim('Timer3Timer');
  Timer3.Enabled := False;
  ComPort1.Close;
  portuAc;
  Oku := True;
  ParmakOku(ComPort1, True, False);
  Adim('Timer3Timer bitti');
end;

procedure TAnaForm.Timer4Timer(Sender: TObject);
begin
  SonOkunan := '';
end;

procedure TAnaForm.ParmakIziMesajGonder;
begin
  pkt := CihazAdres + pkt;
  pkt := pkt + ' ' + ToplamBul(pkt) + ' 0A';
  STR := '';
  ComPort1.WriteStr(HexToStr(pkt));
end;

procedure TAnaForm.ParmakIziGenelMesaj(pkt: string);
begin
  STR := '';
  ComPort1.WriteStr(HexToStr(pkt));
end;

procedure TAnaForm.tmrSupremaTaramaTimer(Sender: TObject);
begin
  Adim('tmrSupremaTaramaTimer ');
  ComPort1.Close;
  portuAc;
  ParmakIziMesajGonder(FPHazirla1);
  tmrSupremaTarama.Enabled := False;
  Adim('tmrSupremaTaramaTimer bitti');

end;

procedure TAnaForm.Isle;
var
  AcikPkt, pkt, pktTipi: string;
  FPID: string;
begin

  AcikPkt := StrToHex(STR);

  // Cihazlar Adreslerini Gönderiyorlar
  if length(STR) = 4 then
  begin
    pkt := copy(STR, 1, 3); // Cihazýn Adresi bu 3 karakterde bulunuyor
    if ToplamBul(StrToHex(pkt)) = StrToHex(copy(STR, 4, 1)) then
    begin
      CihazAdres := StrToHex(pkt);
      ParmakIziMesajGonder(FPBasla1);
    end;
  end
  else if length(STR) = 15 then // Diðer Ýletiþim Paketleri
  begin

    pkt := copy(STR, 1, 13);

    if ToplamBul(StrToHex(pkt)) = StrToHex(copy(STR, 14, 1)) then
    begin

      pktTipi := StrToHex(STR[4] + STR[5]);

      if pktTipi = FPBasla1Cevap then
      begin
        if FPCevaplama1 then
          ParmakIziMesajGonder(FPHazirla2)
        else
        begin
          ParmakIziMesajGonder(FPBasla2);
          FPCevaplama1 := True;
        end;
      end
      else if pktTipi = FPBasla2Cevap then
        ParmakIziMesajGonder(FPBasla3)
      else if pktTipi = FPBasla3Cevap then
        ParmakIziMesajGonder(FPBasla4)
      else if pktTipi = FPBasla4Cevap then
        ParmakIziMesajGonder(FPHazirla1)
      else if pktTipi = FPHazirla2Cevap then
      begin
        ParmakIziMesajGonder(FPSorgula);
      end
      else if pktTipi = FPSorgulaCevap then
      begin
        ParmakIziMesajGonder(FPSorgula);
      end
      else
      begin
        tmrSupremaTarama.Interval := 1000;
        tmrSupremaTarama.Enabled := False;
        tmrSupremaTarama.Enabled := True;
      end;
    end;
  end
  else if length(STR) = 50 then
  begin
    KartKontrol(inttostr((ord(STR[40]) * 255 + ord(STR[39]))), ReaderNo);
    tmrSupremaTarama.Interval := 1000;
    tmrSupremaTarama.Enabled := False;
    tmrSupremaTarama.Enabled := True;
  end;

end;

procedure TAnaForm.CZKEMPDKSAttTransactionEx(ASender: TObject;
  const EnrollNumber: WideString; IsInValid, AttState, VerifyMethod, Year,
  Month, Day, Hour, Minute, Second, WorkCode: Integer);
var
  TTarih,Tarih,Saat: string;
begin
  Tarih :=DateToStr(EncodeDate(Year, Month, Day));
  Saat := TimeToStr(EncodeTime(Hour, Minute, 0, 0));
  TTarih := Tarih + ' ' + Saat;
  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'Delete from PERS_PDKS WHERE KARTNO=:A0 and GIRIS=:A1  ';
  Tablo.Query5.Parameters[0].Value:=EnrollNumber;
  Tablo.Query5.Parameters[1].Value:=FormatDateTime('yyyy-mm-dd 00:00:00',strtodatetime(Tarih));
  Tablo.Query5.ExecSQL;

  Anaform.KartKontrolZamanli(EnrollNumber,1,FormatDateTime('yyyy-mm-dd hh:nn:00',strtodatetime(TTarih)));

  CZKEMPDKS.RegEvent(DevID,32767);

end;

procedure TAnaForm.CZKEMPDKSHIDNum(ASender: TObject; CardNumber: Integer);
begin
//  KartKontrol(inttostr(CardNumber), ReaderNo);
end;

procedure TAnaForm.CZKEMPDKSVerify(ASender: TObject; UserID: Integer);
begin
//  KartKontrol(IntToStr(UserID), ReaderNo)
end;

function TAnaForm.CZKEMTCPIPOkuyucuBaslat(czkem: TCZKEM; IPNUMBER, PortNumber: String): integer;
var
  ErrorCode: integer;
  c: Boolean;
  comstr: string;
begin
  if BTNAc.Tag = 1 then
  begin
    Adim('Port Kapatýlýyor');
    czkem.RefreshData(DevID);
    czkem.EnableDevice(DevID, True);
    czkem.Disconnect;
    BTNAc.Tag := 0;
    BTNAc.Caption := 'BAÞLAT';
    Adim('Port kapatýldý');
  end
  else
  begin
    Adim('Port Açýlýyor');
    Adim('  devid := 1;');
    // kastamon ugurlu bu cihazdan iki tane kullanýyor  pdks de device id 1 olmalý
    // yemekhane için device id 2 olmasý gerekiyor yoksa device connected=0 hatasý dönüyor
    devid := 1;
    Adim('  czkem.SetCommPassword(0);');
    czkem.SetCommPassword(0);
    Adim('  TCP/IP ile baðlanýyor');
    c := czkem.Connect_net(IPNUMBER, strtoint(PortNumber));
    devid := 1;
    if c then
    begin
      Adim('  AddInfo(''Device Connected.'');');
      AddInfo('Device Connected.');
      ReadDeviceStatus(czkem);
      BTNAc.Tag := 1;
      BTNAc.Caption := 'BÝTÝR';
      Adim('    Connected bitti');
    end
    else
    begin
      Adim('  Hata Oluþtu');
      czkem.GetLastError(ErrorCode);
      Adim('  Hata:' + format('! ConnectDevice ErrorNo.=%d', [ErrorCode]));
      AddInfo(format('! ConnectDevice ErrorNo.=%d', [ErrorCode]));
    end;
    AddInfo(' ');
  end;
  //
end;

procedure TAnaForm.portuAc;
begin
  ComPort1.Close;
  try
    ComPort1.LoadSettings(stRegistry, '\software\GENTEGRE2\genper\');
    ComPort1.Open;
  except
    ShowMessage('Comport Açýlamadý');
  end;
end;

procedure TAnaForm.tmrOkuyucu2Timer(Sender: TObject);
begin
  Okuyucu2YedekPort := not Okuyucu2YedekPort;
  if Okuyucu2YedekPort then
    KartOku(YPortNe, YReaderNo)
  else
    KartOku(PortNe, ReaderNo);
end;

procedure TAnaForm.tmrOkuyucuAktarTimer(Sender: TObject);
begin
  tmrOkuyucuAktar.Interval:=CalismaAraligi;
//   SaveGLogs();

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' SELECT R.FIRMA,PC.ID,RB.BILGI,PC.TARIH,PC.KAYITTARIH FROM REHBERBILGI RB (nolock) '+
     ' INNER JOIN REHBERAYAR RA (nolock) ON RA.YERI=3 and RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI '+
     ' LEFT OUTER JOIN REHBER R (NOLOCK) ON R.ID=RB.YER_ID '+
     ' left outer join PERS_CIHAZ_ALINAN PC (nolock) on PC.KARTNO=RB.BILGI' +
     ' WHERE RA.VARSAYILAN=90 and PC.TARIH BETWEEN CONVERT(DATETIME,:TARIH1,120) AND CONVERT(DATETIME,:TARIH2,120)' + ' ORDER BY PC.ID ';
  Tablo.Query1.Parameters[0].Value := FormatDateTime('yyyy-mm-dd 00:01:00', Now());
  Tablo.Query1.Parameters[1].Value := FormatDateTime('yyyy-mm-dd 23:59:59', Now());
  Tablo.Query1.Open;

  Tablo.Query1.First;
  while not Tablo.Query1.Eof do
  begin
    KartKontrolZamanli(Tablo.Query1.fieldbyname('BILGI').AsString, 1, FormatDateTime('yyyy-mm-dd hh:nn:00', Tablo.Query1.fieldbyname('TARIH').AsDateTime));

    Tablo.Query1.Next
  end;
end;

procedure TAnaForm.GenelDokumlerClick(Sender: TObject);
begin
  IzinDlg.showmodal;
end;

procedure TAnaForm.CZKEMYemekhaneConnected(Sender: TObject);
begin
//  ShowMessage('Baðlandý');
end;

procedure TAnaForm.CZKEMYemekhaneHIDNum(ASender: TObject; CardNumber: Integer);
begin
  KartKontrolYemek(inttostr(CardNumber), YReaderNo);
end;

procedure TAnaForm.SpeedButton1Click(Sender: TObject);
begin
  Tablo.TabStatus.Close;
  Tablo.TabStatus.Open;
end;

procedure TAnaForm.SbAttendVeriAlClick(Sender: TObject);

begin
  FkAttendSorgula.Enabled := False;

  if Pdks then
    AttendLogAl(FKAttend, dtpVerileriAl.Date);
  if Yemekhane then
    AttendLogAl(FKAttendy, dtpVerileriAl.Date);

  FkAttendSorgula.Enabled := True;
end;

function TAnaForm.AttendConvertDatetime(apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec: integer): string;
begin
  Result := IntToStr(apnDay) + '/' + IntToStr(apnMonth) + '/' + IntToStr(apnYear) + ' ' + IntToStr(apnHour) + ':' + IntToStr(apnMinute) + ':' + IntToStr(apnSec);
end;

procedure TAnaForm.AttendLogAl(Attend: TFKAttend; Tarih: TDatetime);

var
  apnEnrollNumber, apnVerifyMode, apnInOutMode, ResultCode, ErrorCode: integer;
  apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec: integer;
  apYear, apMonth, apDay: word;
  apnDateTime: TDatetime;
  GetGeneralLogData_1Error: Integer;
  EnableDiveceError: Integer;
  LoadGeneralLogDataError: Integer;
  KayýtZamani: TDatetime;
begin
  EnableDiveceError := Attend.EnableDevice(0); // Cihazý kilitle
  Memo1.Lines.Add('Cihazý kilitle : ' + ReturnResultPrint(EnableDiveceError));
  if EnableDiveceError = RUN_SUCCESS then
  begin
    LoadGeneralLogDataError := FKAttend.LoadGeneralLogData(0);
    // Kaydedilmiþ bütün verileri okuma izni verir.(0)
    Memo1.Lines.Add('Datalarý yükle : ' + ReturnResultPrint(LoadGeneralLogDataError));
    if LoadGeneralLogDataError = RUN_SUCCESS then
    begin
      // Cihazda veri kalmayýncaya kadar dön
      repeat
        GetGeneralLogData_1Error := Attend.GetGeneralLogData_1(apnEnrollNumber, apnVerifyMode, apnInOutMode, apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec);
        KayýtZamani := strtodatetime(AttendConvertDatetime(apnYear, apnMonth, apnDay, apnHour, apnMinute, apnSec));
        // Memo1.Lines.Add('Gelen Datalar : ' + ReturnResultPrint
        // (GetGeneralLogData_1Error) + IntToStr(apnEnrollNumber)
        // + '  ' + VerifyModeResultPrint(apnVerifyMode)
        // + '  ' + IOModeResultPrint(apnInOutMode)
        // + '  ' + AttendConvertDatetime(apnYear, apnMonth, apnDay, apnHour,
        // apnMinute, apnSec) + ' ');

        DecodeDate(Tarih, apYear, apMonth, apDay);
        if (apYear = apnYear) and (apMonth = apnMonth) and (apDay = apnDay) then
          KartKontrolZamanli(IntToStr(apnEnrollNumber), ReaderNo, FormatDateTime('yyyy-mm-dd hh:nn:00', KayýtZamani));
        if GetGeneralLogData_1Error = RUNERR_DATAARRAY_END then
          break;
      until (1 = 2);
    end;
  end;
  EnableDiveceError := Attend.EnableDevice(1); // Cihazý Aç
  Memo1.Lines.Add('Cihazý Aç : ' + ReturnResultPrint(EnableDiveceError));
end;

end.
