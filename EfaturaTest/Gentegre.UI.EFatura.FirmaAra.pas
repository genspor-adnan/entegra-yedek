unit Gentegre.UI.EFatura.FirmaAra;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Soap.InvokeRegistry, Soap.Rio,
  Soap.SOAPHTTPClient, cxGraphics, cxControls, cxLookAndFeels, cxButtons,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, Vcl.Graphics,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, dxCore,
  cxEdit, cxNavigator, Data.DB, cxDBData, dxmdaset, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, System.Classes,
  cxGridDBTableView, cxGrid, cxContainer, Vcl.ComCtrls, Vcl.StdCtrls,
  cxDateUtils, cxCheckBox, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, Vcl.ExtCtrls, EFaturaOIB, Vcl.Menus, dxSkinLondonLiquidSky, dxSkinLiquidSky, dxSkinBlack, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, QNB_EFat_Service;

type

  TEFaturaFirmaAra = class(TForm)
    tblViewFirmalar: TcxGridDBTableView;
    grdFirmalarLevel1: TcxGridLevel;
    grdFirmalar: TcxGrid;
    memTable: TdxMemData;
    memTableDataSource: TDataSource;
    memTableVERGINO: TStringField;
    memTableEPOSTA: TStringField;
    memTableUNVAN: TStringField;
    memTableTYPE: TStringField;
    memTableKAYITTARIHI: TStringField;
    memTableBIRIM: TStringField;
    tblViewFirmalarRecId: TcxGridDBColumn;
    tblViewFirmalarVERGINO: TcxGridDBColumn;
    tblViewFirmalarEPOSTA: TcxGridDBColumn;
    tblViewFirmalarUNVAN: TcxGridDBColumn;
    tblViewFirmalarTYPE: TcxGridDBColumn;
    tblViewFirmalarKAYITTARIHI: TcxGridDBColumn;
    tblViewFirmalarBIRIM: TcxGridDBColumn;
    Panel1: TPanel;
    btnAra: TcxButton;
    txtVergiNo: TcxTextEdit;
    txtUnvan: TcxTextEdit;
    Label1: TLabel;
    Label2: TLabel;
    HTTPRIOEfat: THTTPRIO;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAraClick(Sender: TObject);
  private
    { Private declarations }
    FOturumAcildi: Boolean;
    FOturumId: string;
    FServis: EFaturaOIBPort;
    FServisQNB: ConnectorService;
    //FServisLogo:GetIPostBoxService
    FSifre: string;
    FKullaniciAdi: string;
    function IstekBasligi: REQUEST_HEADERType;
    function OturumAc: Boolean;
    procedure FirmaListeleSonucAyikla(ASonuc: array of GIBUSER);
    procedure FirmaAra;

  public
    { Public declarations }

    function FirmaVarMi(AVergiNo: string;AUnvan: string = ''): Boolean;
    function FirmaBul(AVergiNo: string;AUnvan: string = ''): CheckUserResponse;
    procedure FirmalariTemizle(AFirmalar: array of GIBUSER);
    procedure OturumKapat;

    //property Addr: string read FAddr write FAddr;
    property KullaniciAdi: string read FKullaniciAdi write FKullaniciAdi;
    property Sifre: string read FSifre write FSifre;
  end;

var
  EFaturaFirmaAra: TEFaturaFirmaAra;
  ProxyAdres : string;
  ServisSaglayici : Integer;
  FAddr: String;
implementation

{$R *.dfm}

uses Soap.XSBuiltIns,DateUtils;//, Utablo,LocOnFly,PrjConst;

function GetComputerNameFromWindows: string;
var
  iLen: Cardinal;
begin
  iLen := MAX_COMPUTERNAME_LENGTH + 1;         // From Windows.pas
  Result := StringOfChar(#0, iLen);
  GetComputerName(PChar(Result), iLen);
  SetLength(Result, iLen);
end;

procedure TEFaturaFirmaAra.btnAraClick(Sender: TObject);
begin
  FirmaAra;
end;

procedure TEFaturaFirmaAra.FirmaListeleSonucAyikla(
  ASonuc: array of GIBUSER);
var
  i : Integer;
  firma: GIBUSER;
begin
  memTable.DisableControls;
  while memTable.RecordCount > 0 do
    memTable.Delete;
  for i := 0 to Length(ASonuc) - 1 do begin
    firma := ASonuc[i];
    memTable.Append;
    memTableVERGINO.AsString := firma.IDENTIFIER;
    memTableEPOSTA.AsString := firma.ALIAS;
    memTableUNVAN.AsString := firma.TITLE;
    memTableTYPE.AsString := firma.TYPE_;
    memTableKAYITTARIHI.AsString := firma.REGISTER_TIME;
    memTableBIRIM.AsString := firma.UNIT_;
    memTable.Post;
  end;
  memTable.EnableControls;
end;

procedure TEFaturaFirmaAra.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
//A  if ProxyAdres<>'' then
//A     HTTPRIOEfat.HTTPWebNode.Proxy := ProxyAdres+':'+ProxyPort;
  ServisSaglayici := 1;

//  HTTPRIOEfat.HTTPWebNode.GetHTTPReqResp.UserName:= 'genotip';
//  HTTPRIOEfat.HTTPWebNode.GetHTTPReqResp.Password:= 'fetagen';

  case ServisSaglayici of
   1 : FServis := GetEFaturaOIBPort(False,FAddr,HTTPRIOEfat);
   2 : FServisQNB := GetEFaturaQNBPort(False,'',HTTPRIOEfat);
  end;

  FKullaniciAdi := '';
  FSifre := '';
  memTable.Open;
  //Tablo.GridTurkcelestir;
end;

procedure TEFaturaFirmaAra.FormDestroy(Sender: TObject);
begin
  OturumKapat;
  FServis := nil;
end;

function TEFaturaFirmaAra.IstekBasligi: REQUEST_HEADERType;
begin
  Result := REQUEST_HEADERType.Create;
  with Result do begin
    SESSION_ID := FOturumId;
    CLIENT_TXN_ID := '-1';
    INTL_TXN_ID := -1;
    INTL_PARENT_TXN_ID := -1;
    REASON := 'NA';
    APPLICATION_NAME := 'Gentegre';
    HOSTNAME := GetComputerNameFromWindows;
    CHANNEL_NAME := 'I2I';
    SIMULATION_FLAG := 'N';
  end;
end;

procedure TEFaturaFirmaAra.FirmaAra;
var
  request: CheckUserRequest;
  response: CheckUserResponse;
begin
  if OturumAc then begin
    request := CheckUserRequest.Create;
    try
      request.REQUEST_HEADER := IstekBasligi;
      request.USER := GIBUSER.Create;
      if txtVergiNo.Text <> '' then
        request.USER.IDENTIFIER := txtVergiNo.Text;
      if txtUnvan.Text <> '' then
        request.USER.TITLE := txtUnvan.Text;
      response := FServis.CheckUser(request);
      FirmaListeleSonucAyikla(response);
      FirmalariTemizle(response);
    finally
      request.Free;
    end;
  end;
end;

function TEFaturaFirmaAra.FirmaBul;
var
  request: CheckUserRequest;
begin
  if OturumAc then begin
    request := CheckUserRequest.Create;
    try
      request.REQUEST_HEADER := IstekBasligi;
      request.USER := GIBUSER.Create;
      if AVergiNo <> '' then
        request.USER.IDENTIFIER := AVergiNo;
      if AUnvan <> '' then
        request.USER.TITLE := AUnvan;
      if (AVergiNo ='') AND (AUnvan='') then begin
        SetLength(Result,0);
        Exit;
      end;

      Result := FServis.CheckUser(request);
    finally
      request.Free;
    end;
  end;
end;

procedure TEFaturaFirmaAra.FirmalariTemizle(AFirmalar: array of GIBUSER);
var
  i: Integer;
begin
  for i := 0 to Length(AFirmalar) - 1 do begin
    AFirmalar[i].Free;
  end;
end;

function TEFaturaFirmaAra.FirmaVarMi;
var
  response: CheckUserResponse;
begin
  response := FirmaBul(AVergiNo,AUnvan);
  Result := Length(response) > 0;
  FirmalariTemizle(response);
end;

function TEFaturaFirmaAra.OturumAc: Boolean;
var
  request: LoginRequest;
  response: LoginResponse;
begin
  Result := False;
  if FOturumAcildi then Exit(True);
  request := LoginRequest.Create;
  response := nil;
  try
    request.REQUEST_HEADER := REQUEST_HEADERType.Create;
    request.REQUEST_HEADER.SESSION_ID := '-1';
    request.USER_NAME := FKullaniciAdi;
    request.PASSWORD := FSifre;
    response := FServis.Login(request);
    if (response.SESSION_ID <> '') then begin
      FOturumAcildi := True;
      FOturumId := response.SESSION_ID;
      Result := True;
    end;
  finally
    request.Free;
    if Assigned(response) then
      FreeAndNil(response);
  end;
end;

procedure TEFaturaFirmaAra.OturumKapat;
var
  request: LogoutRequest;
  response: LogoutResponse;
begin
  if not FOturumAcildi then Exit;
  request := LogoutRequest.Create;
  try
    request.REQUEST_HEADER := REQUEST_HEADERType.Create;
    request.REQUEST_HEADER.SESSION_ID := FOturumId;
    response := FServis.Logout(request);
    if response.REQUEST_RETURN.RETURN_CODE = 0 then begin
      FOturumAcildi := False;
      FOturumId := '';
    end;
  finally
    FreeAndNil(request);
    if Assigned(response) then
      FreeAndNil(response);
  end;
end;

end.
