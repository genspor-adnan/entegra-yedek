unit uSocialListFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs
  , Utablo
  , uFrameYoneticisi
  , UGentegreFrameYonetimi, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, cxImageList, cxGraphics, System.Actions,
  Vcl.ActnList, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, Vcl.Menus, cxStyles, cxClasses, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils, Vcl.StdCtrls, cxButtons, cxLabel,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, Vcl.Buttons, Vcl.Imaging.jpeg, dxActivityIndicator, dxStatusBar,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges, dxScrollbarAnnotations, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridCustomView, cxGrid
  , System.SyncObjs
  , fbCommon
  , uSocialCommon
  , fbClasses
  , fbDataModule
  , dmIMAPModule
  , IdExplicitTLSClientServerBase
  , cxCheckBox, dxmdaset, cxCalc
  , uSocialAramaFrame, cxImageComboBox, dxGDIPlusClasses
 ;

type

  TSocialMediaFrame =class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    cxMetaImages: TcxImageList;
    ActionList1: TActionList;
    actStartStop: TAction;
    actIceriAl: TAction;
    qryMetaCollect: TFDQuery;
    qryMetaCollectID: TIntegerField;
    qryMetaCollectContact_ID: TStringField;
    qryMetaCollectContact_Name: TWideStringField;
    qryMetaCollectContact_Phone: TStringField;
    qryMetaCollectContact_Phone2: TStringField;
    qryMetaCollectContatc_eMail: TStringField;
    qryMetaCollectContact_Address: TWideStringField;
    qryMetaCollectContact_City: TWideStringField;
    qryMetaCollectContact_Country: TWideStringField;
    qryMetaCollectContact_Gender: TStringField;
    qryMetaCollectLast_Update: TDateTimeField;
    qryMetaCollectNOT1: TWideStringField;
    qryMetaCollectFB_Support: TBooleanField;
    qryMetaCollectInsta_Support: TBooleanField;
    qryMetaCollectWhatsapp_Support: TBooleanField;
    qryMetaCollectImport_Date: TDateTimeField;
    qryMetaCollectImported: TBooleanField;
    dsMetaCollect: TDataSource;
    tabSocialConfig: TFDQuery;
    cxStyleRepo: TcxStyleRepository;
    cxStyleHeader: TcxStyle;
    cxStyleContactID: TcxStyle;
    cxStyle_Odd: TcxStyle;
    cxStyle_Even: TcxStyle;
    popupMeta: TPopupMenu;
    PotansiyelMterilistesineEkle1: TMenuItem;
    Panel3: TPanel;
    Image1: TImage;
    dxStatusBar1: TdxStatusBar;
    dxStatusBar1Container0: TdxStatusBarContainerControl;
    labelInfo: TLabel;
    dxStatusBar1Container1: TdxStatusBarContainerControl;
    IndicatorDots: TdxActivityIndicator;
    GridMetaCRM: TcxGrid;
    MetaView: TcxGridDBTableView;
    MetaViewID: TcxGridDBColumn;
    MetaViewContact_ID: TcxGridDBColumn;
    MetaViewContact_Name: TcxGridDBColumn;
    MetaViewContact_Phone: TcxGridDBColumn;
    MetaViewContact_Phone2: TcxGridDBColumn;
    MetaViewContact_eMail: TcxGridDBColumn;
    MetaViewContact_Gender: TcxGridDBColumn;
    MetaViewContact_City: TcxGridDBColumn;
    MetaViewContact_Address: TcxGridDBColumn;
    MetaViewNOT1: TcxGridDBColumn;
    MetaViewContact_Country: TcxGridDBColumn;
    MetaViewImported: TcxGridDBColumn;
    MetaViewImport_Date: TcxGridDBColumn;
    Level1: TcxGridLevel;
    qryMetaCollectContact_RehberID: TIntegerField;
    MetaViewContact_RehberID: TcxGridDBColumn;
    qryMetaCollectTemas: TStringField;
    MetaViewTemas: TcxGridDBColumn;
    qryMetaCollectMeta_Class: TIntegerField;
    cxStyle_Aktarilmis: TcxStyle;
    MetaViewLast_Update: TcxGridDBColumn;
    MetaViewMeta_Class: TcxGridDBColumn;
    actPasifYap: TAction;
    actAktifYap: TAction;
    KaydGereksizOlarakaretle1: TMenuItem;
    GereksizDeilOlarakaretle1: TMenuItem;
    N1: TMenuItem;
    qryMetaCollectDurum: TBooleanField;
    MetaViewDurum: TcxGridDBColumn;
    cxStyle_Pasif: TcxStyle;
    qryMetaCollectUID: TAutoIncField;
    actRehberKontrol: TAction;
    AktarlmRehberKaytlarnDenetle1: TMenuItem;
    N2: TMenuItem;
    qryMetaCollectIMAP_UID: TIntegerField;
    qryMetaCollectContact_Town: TWideStringField;
    MetaViewContact_Town: TcxGridDBColumn;
    MetaViewUID: TcxGridDBColumn;
    MetaViewFB_Support: TcxGridDBColumn;
    MetaViewInsta_Support: TcxGridDBColumn;
    MetaViewWhatsapp_Support: TcxGridDBColumn;
    MetaViewIMAP_UID: TcxGridDBColumn;
    MetaViewSelect: TcxGridDBColumn;
    procedure actIceriAlExecute(Sender: TObject);
    procedure actIceriAlUpdate(Sender: TObject);
    procedure MetaSELECTPropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
    procedure dxMemCollect_REMOVECalcFields(DataSet: TDataSet);
    procedure MetaSELECTPropertiesChange(Sender: TObject);
    procedure qryMetaCollectCalcFields(DataSet: TDataSet);
    procedure LabelTumKayitlarClick(Sender: TObject);
    procedure AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure YenileTusClick(Sender: TObject);
    procedure ComboSinifPropertiesCloseUp(Sender: TObject);
    procedure FiltreAcKapat;
    procedure PasifKayitlaAcKapat;
    procedure GruplamaKayitlaAcKapat;

    procedure AramaYap( _dateStart : TcxDateEdit = Nil; _dateEnd : TcxDateEdit = Nil);
    procedure MetaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure actPasifYapUpdate(Sender: TObject);
    procedure actPasifYapExecute(Sender: TObject);
    procedure actAktifYapUpdate(Sender: TObject);
    procedure actAktifYapExecute(Sender: TObject);
    procedure MedyaYenile(Sender: TObject);
    procedure actRehberKontrolExecute(Sender: TObject);
    procedure MetaViewCanSelectRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);

  private
    { Private declarations }
    FFrameBilgi: TIcerikFrameBilgi;
    Conversations : TFbItems;
    Messages : TFbItems;
    PageForms,
    FormLeads : TFbItems;
    fInitialized: boolean;
    fAppID: string;
    fPageID: string;
    fAppSecret: string;
    fPageToken: string;
    fAppName: string;
    fPasifKayitGoster : boolean;
    FBThreadEvent : TEvent;
    FArama : TSocialAramaFrame;
    fLoggToFile: boolean;
    fIPort: Word;
    fITLSS: integer;
    fIPassword: string;
    fIRoot: string;
    fIUsername: string;
    fIServer: string;
    fIToMail: string;
    fMetaUpdatePeriod: integer;
    procedure LogSocialMedia(_Message : string; _Provider : string = 'SOCIAL_META');
    procedure SetControlsStatus(_Status : boolean);
    procedure DoWorkIceriAktar;
    procedure DoWorkMessages;
    procedure DoWorkImapMails;

    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    procedure TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure LabelSonArananlarClick(Sender: TObject);

    {**}
    procedure Baslatildi;
    {**}
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function GetKapatilabilir: Boolean;
    function GetFrameBilgi: TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue: TIcerikFrameBilgi);
    procedure SetArama(const Value: TSocialAramaFrame);
    procedure AdoToMem;
    procedure AktarilmislariEslestir;
    procedure ThreadBitti(Sender: TObject);
    function MetaZamanUygunmu : boolean;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;                 {m.y Özel iþlerimiz olacaktýr}
    destructor Destroy; override;

    procedure SetupMeta(_AppID, _AppSecret, _AppName, _PageID, _PageToken : string; _UpdatePeriod : integer);
    procedure SetupIMAP(_IServer, _IUsername, _IPassword, _IRoot, _IToMail : string; _IPort : word; _ITLSS : integer);
    property Initialized : boolean read fInitialized write fInitialized;
    // Meta üyeleri
    property AppID : string read fAppID write fAppID;
    property AppName : string read fAppName write fAppName;
    property AppSecret : string read fAppSecret write fAppSecret;
    property PageID : string read fPageID write fPageID;
    property PageToken : string read fPageToken write fPageToken;
    property MetaUpdatePeriod : integer read fMetaUpdatePeriod write fMetaUpdatePeriod;
    //IMAP üyeleri
    property IServer   : string    read fIServer    write fIServer;
    property IUsername : string    read fIUsername  write fIUsername;
    property IPassword : string    read fIPassword  write fIPassword;
    property IRoot     : string    read fIRoot      write fIRoot;
    property IToMail   : string    read fIToMail    write fIToMail;
    property IPort     : Word      read fIPort      write fIPort;
    property ITLSS     : integer   read fITLSS      write fITLSS;
  published
    property Arama : TSocialAramaFrame read FArama write SetArama;
    property LoggToFile : boolean read fLoggToFile write fLoggToFile;

  end;

implementation

{$R *.dfm}
uses
    LocOnFly
  , PrjConst
  , System.DateUtils
  , cxGridDBDataDefinitions
  , Winapi.ActiveX
  , IdMessage
  , IdIMAP4
  , uOrtakLog
  {$IFDEF 3Dparty}
  , uUtility_my
  {$ENDIF 3Dparty}
  ;

const
  constActInfo : array [False..True] of string= ('','Güncelleniyor');




{ TSocialMeidaFrame }


function QS( _str : string) : string;
begin
    Result := QuotedStr(_str);
end;

function IsEmptyVar(V : Variant) : Boolean;
begin
  Result:=False;
  If VarIsNull(V) or
   VarIsEmpty(V) or
    (VarToStr(V)='') or
    VarIsClear(V) then
    Result:=True;
end;

function VarToString(V : Variant):String;
begin
  if IsEmptyVar(V) then
    Result :=''
  else
  Result:=V;
end;

function VarToBool(V : Variant):Boolean;
begin
  if IsEmptyVar(V) then
    Result := False
  else
  Result:=V;
end;


procedure TSocialMediaFrame.actIceriAlExecute(Sender: TObject);
begin
   // Ýçeri Al
    DoWorkIceriAktar;
end;

procedure TSocialMediaFrame.actIceriAlUpdate(Sender: TObject);
var i : integer;
begin
   // Kayýt Alýndý mý ALýnmadý mý
   //TAction(Sender).Enabled := {(MetaView.Controller.SelectedRowCount>0) and} (MetaView.Datacontroller.FocusedDataRowIndex>-1);
   {//UNUTMA
   for i := 0 to MetaView.Controller.SelectedRowCount-1 do
    begin
      if MetaView.Controller.SelectedRows[i].Values[0] = True then
        begin
           TAction(Sender).Enabled := True;
           Exit;
        end;
    end;
    }

    if MetaView.Controller.SelectedRowCount=1 then
     begin
       TAction(Sender).Enabled := (Not MetaView.Controller.SelectedRows[i].Values[MetaViewImported.Index]) and
                                  (VarToStr(MetaView.Controller.SelectedRows[i].Values[MetaViewContact_Name.Index])<>'')
                                   ;
     end
      else
        TAction(Sender).Enabled := MetaView.Controller.SelectedRowCount>0;

    //TAction(Sender).Enabled := False;
end;



procedure TSocialMediaFrame.actAktifYapExecute(Sender: TObject);
var
  UID : Integer;
begin
  //
  UID := VarToInt(Metaview.Controller.SelectedRows[0].Values[MetaViewUID.Index]);// dxMemCollectUID.AsInteger;
  Tablo.FDCnn.ExecSQL('UPDATE META_Collect SET Durum=1 WHERE UID='+UID.ToString);
  AramaYap();
end;

procedure TSocialMediaFrame.actAktifYapUpdate(Sender: TObject);
begin
  Taction(Sender).Enabled := (qryMetaCollect.State = dsBrowse) and  (Metaview.Controller.SelectedRowCount>0) and (VarToBool(Metaview.Controller.SelectedRows[0].Values[MetaViewDurum.Index]) = False);
end;

procedure TSocialMediaFrame.actPasifYapExecute(Sender: TObject);
var
  UID : Integer;
begin
  //
  UID := VarToInt(Metaview.Controller.SelectedRows[0].Values[MetaViewUID.Index]);
  Tablo.FDCnn.ExecSQL('UPDATE META_Collect SET Durum=0 WHERE UID='+UID.ToString);
  AramaYap();
end;

procedure TSocialMediaFrame.actPasifYapUpdate(Sender: TObject);
begin
  Taction(Sender).Enabled := (qryMetaCollect.State = dsBrowse) and  (Metaview.Controller.SelectedRowCount>0) and (VarToBool(Metaview.Controller.SelectedRows[0].Values[MetaViewDurum.Index]) = True);
end;

procedure TSocialMediaFrame.actRehberKontrolExecute(Sender: TObject);
begin
  //
  AktarilmislariEslestir;
  AramaYap();
end;

procedure TSocialMediaFrame.AdoToMem;
begin
  // qryMetaCollect ADO dataset'ten dxMemCollect Memory dataset'e aktarým.
  raise Exception.Create('Buraya girmemeliydi');
  (*
  dxMemCollect.DisableControls;
  try
    qryMetaCollect.Close;
    try
       while dxMemCollect.RecordCount>0 do
           dxMemCollect.Delete;
        qryMetaCollect.Open;
        dxMemCollect.LoadFromDataSet(qryMetaCollect);
        {$IFDEF 3Dparty} _LogEkle('ADOTOMEM', qryMetaCollect.RecordCount.ToString+ ' Kayýt Aktarýldý'); {$endif}

    except
        on ExAdoToMem001 : Exception do
         begin
           {$IFDEF 3Dparty} _LogEkle('DBHATASI', 'ExAdoToMem001 : '+ExAdoToMem001.Message); {$endif}
         end;
    end;
  finally
    qryMetaCollect.Close;
    dxMemCollect.EnableControls;
  end;
  *)
end;

procedure TSocialMediaFrame.AktarilmislariEslestir;
begin
   {
     META_Collect Contact_RehberID eþleþtirilmiþ, fakat zaman içinde "REHBER" tablosundan silinmiþ olabilir.
     Dolayýsýyla Ýçeri alýnmýþ gibi görünmeye devam edecektir.
     Form baþlatýlýdðýnda veya "Yenileme" sonrasinda mutlaka güncellenmeli
   }

   Tablo.FDCnn.ExecSQL('UPDATE META_Collect SET Contact_RehberID = (SELECT ID FROM REHBER WHERE ID= Contact_RehberID)');
   Tablo.FDCnn.ExecSQL('UPDATE META_Collect SET Import_Date = Null where Contact_RehberID is Null');
end;


procedure TSocialMediaFrame.AraFirmaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  //if Length(FArama.AraFirma.Text)>2 then
   AramaYap;
end;

procedure TSocialMediaFrame.AramaYap( _dateStart : TcxDateEdit = Nil; _dateEnd : TcxDateEdit = Nil);
var
  filterText : string;
  startStr,
  endStr : string;
  Filter_Date : string;
  Filter_Unvan : string;
  Filter_Sehir : string;
  Filter_Ulke : string;
begin
  //qryMetaCollect.Filter

   Filter_Unvan := '';
   Filter_Date := '';
   Filter_Sehir := '';
   Filter_Ulke := '';

  if _dateStart=nil then
    _dateStart := FArama.dateStart;
  if _dateEnd = nil then
    _dateEnd := FArama.dateEnd;

  startStr := VarToString(_dateStart.EditValue);
  endStr := VarToString(_dateEnd.EditValue);
  if (startStr <> '') and (endStr <> '') then
   begin
    if VarToDateTime(_dateStart.EditValue) > VarToDateTime(_dateEnd.EditValue) then
      _dateStart.EditValue := _dateEnd.EditValue;
   end;

   startStr := VarToString(_dateStart.EditValue);

   if startStr <> '' then
   startStr := QuotedStr( FormatDateTime('yyyy-mm-dd',VarToDateTime(_dateStart.EditValue)) );

   if endStr <> '' then
     endStr := QuotedStr( FormatDateTime('yyyy-mm-dd',VarToDateTime(_dateEnd.EditValue)) );

   filterText := ' 1=1 ';

   {Unvan Filtresi}
   if FArama.AraFirma.Text<>'' then
      Filter_Unvan := ' Contact_Name LIKE '+QS(FArama.AraFirma.Text+'%');

   {Þehir Filtresi}
   if FArama.AraSehir.Text<>'' then
      Filter_Sehir := ' Contact_City LIKE '+QS(FArama.AraSehir.Text+'%');

   {Ülke Filtresi}
   if FArama.AraUlke.Text<>'' then
      Filter_Ulke := ' Contact_Country LIKE '+QS(FArama.AraUlke.Text+'%');


   {Tarih Filtresi}
   if (startStr <> '') then
    begin
      if endStr <> '' then
        Filter_Date := '(Last_Update BETWEEN '+startStr +' AND '+endStr+')'
      else
       Filter_Date := ' Last_Update >= '+ startStr
    end
     else
     if endStr <> '' then
       Filter_Date := ' Last_Update <= '+ endStr;

   {Filtrelerden Filtre Oluþtur}
   if Filter_Unvan<>'' then
    filterText := filterText + ' AND '+Filter_Unvan;

   if Filter_Sehir<>'' then
    filterText := filterText + ' AND '+Filter_Sehir;

   if Filter_Ulke<>'' then
    filterText := filterText + ' AND '+Filter_Ulke;

   if Filter_Date<>'' then
    filterText := filterText + ' AND '+Filter_Date;

   if Not fPasifKayitGoster then
     filterText :=  filterText + ' AND Durum = 1 '
       else
         filterText :=  filterText + ' AND Durum in (0,1) ';

   {Final Filtre}
   filterText := ' WHERE '+ filterText;

   qryMetaCollect.SQL.Text := 'SELECT * FROM META_Collect ' + filterText;
   qryMetaCollect.Close;
   qryMetaCollect.Open;
   //AdoToMem;
end;

procedure TSocialMediaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  AktarilmislariEslestir;
  if qryMetaCollect.State in [dsInActive] then
    qryMetaCollect.Open;

  {
  if dxMemCollect.State in [dsInActive] then
    dxMemCollect.Open;

  while dxMemCollect.RecordCount>0 do
    dxMemCollect.Delete;
  }
  AramaYap();
end;

procedure TSocialMediaFrame.ComboSinifPropertiesCloseUp(Sender: TObject);
begin
  AramaYap;
end;

constructor TSocialMediaFrame.Create(AOwner: TComponent);
begin
  inherited;
  fPasifKayitGoster := False;
  fLoggToFile := False;
  {$IFDEF 3Dparty}fLoggToFile := True;{$ENDIF}
  FacebookLoggerMethod := LogSocialMedia; // her hangi bir method eþitlenebilir.
  IMAPLoggerMethod := LogSocialMedia;
  Initialized := False;
  tabSocialConfig.Open;
  Conversations := TFbItems.Create;
  Messages := TFbItems.Create;
  FormLeads := TFbItems.Create;
  PageForms :=  TFbItems.Create;
  IMAPModule := Nil;
  try
    if Tablo.GENINI.ReadBoolean(Ops_SocialMedia_Meta, False) then
      SetupMeta(
           tabSocialConfig['FB_APPID']
          ,tabSocialConfig['FB_AppSecret']
          ,'~uygulama'
          ,tabSocialConfig['FB_PageID']
          ,tabSocialConfig['FB_PageAccessToken']
          ,tabSocialConfig.FieldByName('MetaUpdatePeriod').AsInteger
        );

    if Tablo.GENINI.ReadBoolean(Ops_SocialMedia_IMAP, False) then
      SetupIMAP(
           tabSocialConfig['IMAP_Server']
          ,tabSocialConfig['IMAP_User']
          ,tabSocialConfig['IMAP_Passwd']
          ,tabSocialConfig['IMAP_RootFolder']
          ,tabSocialConfig['IMAP_ToMail']
          ,tabSocialConfig['IMAP_Port']
          ,tabSocialConfig['IMAP_TLS']
      );

    qryMetaCollect.Open;

  finally
    tabSocialConfig.Close;
  end;
  //Memo1.Lines.Append('Created');
end;


destructor TSocialMediaFrame.Destroy;
begin
  if Assigned(FBThreadEvent) then
    FBThreadEvent.SetEvent;
  Conversations.Free;
  Messages.Free;
  FormLeads.Free;
  PageForms.Free;
  if Assigned(IMAPModule) then
    IMAPModule.Free;
  inherited;
end;

procedure TSocialMediaFrame.DoWorkIceriAktar;
  procedure AddParam(_target: TFDParams; const _name: string; _dataType: TFieldType;
    _size: integer; _paramType: TParamType = ptInput);
  var
    AParameter: TFDParam;
  begin
    AParameter := _target.Add;
    AParameter.Name := _name;
    AParameter.DataType := _dataType;
    AParameter.Size := _size;
    AParameter.ParamType := _paramType;
  end;

var
  qryKayitSorgula : TFDQuery;
  qryKayitUpdate : TFDQuery;
  ColIndex : Integer;
  MetaID : string;
  Firma  : string;
  Temas,
  Sinif  : integer;
  Temsilci, Ekleyen : Integer;
  ePosta,
  Tel1,
  Tel2   : string;
  Adres,
  Adres_Il, Adres_Ilce, Adres_Ulke : string;
  Tarih_Iletisim : TDateTime;
  Not_TarihSt : string;
  NotYorum : string;
  Fb_Support, Insta_Support : boolean;
  Rehber_Potansiyel_Proc: TFDStoredProc;
  donguSecim : integer;
  ADataController: TcxGridDBDataController;
  RehberID : integer;
  gridRow : TcxCustomGridRow;
begin
   // Ýçeri Al
   {$ifdef 3Dparty}
   for donguSecim := 0 to MetaView.Controller.SelectedRowCount-1 do
    begin
       gridRow := MetaView.Controller.SelectedRows[donguSecim];

       LogSocialMedia( Format('%-18s %-48s %-64s',
                       [
                       MetaViewImported.Index.ToString+ ':'+VarToStr(gridRow.Values[MetaViewImported.Index]),
                       MetaViewContact_Name.Index.ToString+ ':'+VarToStr(gridRow.Values[MetaViewContact_Name.Index]),
                       MetaViewContact_eMail.Index.ToString+':'+ VarToStr(gridRow.Values[MetaViewContact_eMail.Index])
                       ]
                       )
                       );
    end;

   exit;
  {$endif}

  Screen.Cursor := crHourGlass;
  qryKayitSorgula := TFDQuery.Create(Self);
  //Rehber_Potansiyel_Proc
  Rehber_Potansiyel_Proc := TFDStoredProc.Create(Self);
   try
      //Rehber_Potansiyel_Proc
      Rehber_Potansiyel_Proc.Name := 'Rehber_Potansiyel_Proc';
      Rehber_Potansiyel_Proc.Connection := Tablo.FDCnn;
      Rehber_Potansiyel_Proc.StoredProcName := 'SP_REHBER_POTANSIYEL_INSERT;1';
      AddParam(Rehber_Potansiyel_Proc.Params, '@FIRMA',          ftWideString, 44);
      AddParam(Rehber_Potansiyel_Proc.Params, '@SINIF',          ftInteger,    10);
      AddParam(Rehber_Potansiyel_Proc.Params, '@TEMSILCI',       ftInteger,    10);
      AddParam(Rehber_Potansiyel_Proc.Params, '@EKLEYEN',        ftInteger,    10);
      AddParam(Rehber_Potansiyel_Proc.Params, '@TEMAS',          ftInteger,    10);
      AddParam(Rehber_Potansiyel_Proc.Params, '@EPOSTA',         ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@CEPTEL',         ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@YABANCIULKETEL', ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@ADRES',          ftWideString, 255);
      AddParam(Rehber_Potansiyel_Proc.Params, '@ILCE',           ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@IL',             ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@ULKE',           ftWideString, 100);
      AddParam(Rehber_Potansiyel_Proc.Params, '@NOTTARIHI',      ftDateTime,   0);
      AddParam(Rehber_Potansiyel_Proc.Params, '@YORUM',          ftWideString, 1073741823);
      AddParam(Rehber_Potansiyel_Proc.Params, '@ResultID',       ftInteger,    10, ptOutput);

       {Selected kayýtlar için dönecek}

       qryKayitSorgula.Connection := Tablo.FDCnn;
       qryKayitUpdate := TFDQuery.Create(Self);
       qryKayitUpdate.SQL.Text := 'SELECT * FROM META_Collect WHERE 1=0';
       qryKayitUpdate.Connection := Tablo.FDCnn;

      try

         for donguSecim := 0 to MetaView.Controller.SelectedRowCount-1 do
          begin
             gridRow := MetaView.Controller.SelectedRows[donguSecim];
             // Daha önce aktarýlmýþlar tekrar aktarýlmýyor!
             if Not gridRow.Values[MetaViewImported.Index] then
              if (VarToString( gridRow.Values[MetaViewContact_Name.Index] )<>'') then
              begin
                Firma :=  VarToString( gridRow.Values[MetaViewContact_Name.Index] );
                ePosta := VarToString( gridRow.Values[MetaViewContact_eMail.Index] );
                Tel1 := VarToString( gridRow.Values[MetaViewContact_Phone.Index] );
                Tel2 := VarToString( gridRow.Values[MetaViewContact_Phone2.Index] );
                Adres := VarToString( gridRow.Values[MetaViewContact_Address.Index] );
                Adres_Il := VarToString( gridRow.Values[MetaViewContact_City.Index] );
                Adres_Ilce := VarToString( gridRow.Values[MetaViewContact_Town.Index] );
                Adres_Ulke := VarToString( gridRow.Values[MetaViewContact_Country.Index] );
                Tarih_Iletisim := VarToDateTime( gridRow.Values[MetaViewLast_Update.Index] );
                Not_TarihSt := VarToString( gridRow.Values[MetaViewLast_Update.Index] );
                //if Not_TarihSt<>'' then
                //  Not_TarihSt := FormatDateTime('yyyy-mm-dd hh:nn:ss',dxMemCollect.FieldByName('Last_Update').AsDateTime);
                NotYorum := VarToString( gridRow.Values[MetaViewNOT1.Index] );
                if Not TryStrToInt(Kullanan, Ekleyen) then
                  Ekleyen := -1;
                //Ekleyen := KullananID; //-1; //Ekleyen Kullanýcý Uygulamayý Açan kiþi olmalý
                Temsilci := -1; // Henüz atanmýþ kimse yok
                Sinif := 0;
                if VarToInt( gridRow.Values[MetaViewMeta_Class.Index]) = 1 then // Meta_Class > Messenger
                   Sinif := 9 // GENINI Bolum = -2203, Deger = 9, ANAHTAR = Meta Messenger
                  else
                   if VarToInt( gridRow.Values[MetaViewMeta_Class.Index]) = 2 then // Meta_Class > Meta Forms
                     Sinif := 8  // GENINI Bolum = -2203, Deger = 8, ANAHTAR = Meta Forms
                    else
                     if VarToInt( gridRow.Values[MetaViewMeta_Class.Index]) = 3 then // Meta_Class > Web Forms
                       Sinif := 10; // GENINI Bolum = -2203, Deger = 10, ANAHTAR = Web Form

                Temas := Sinif;

                Rehber_Potansiyel_Proc.Params.ParamByName('@FIRMA').Value := (Firma);
                Rehber_Potansiyel_Proc.Params.ParamByName('@SINIF').Value := Sinif;
                Rehber_Potansiyel_Proc.Params.ParamByName('@TEMSILCI').Value := Temsilci;
                Rehber_Potansiyel_Proc.Params.ParamByName('@EKLEYEN').Value := Ekleyen;
                Rehber_Potansiyel_Proc.Params.ParamByName('@TEMAS').Value :=  Temas;
                Rehber_Potansiyel_Proc.Params.ParamByName('@EPosta').Value := (ePosta);
                Rehber_Potansiyel_Proc.Params.ParamByName('@CEPTEL').Value := (Tel1);
                Rehber_Potansiyel_Proc.Params.ParamByName('@YABANCIULKETEL').Value := (Tel2);
                Rehber_Potansiyel_Proc.Params.ParamByName('@ADRES').Value := (Adres);
                Rehber_Potansiyel_Proc.Params.ParamByName('@ILCE').Value := (Adres_Ilce);
                Rehber_Potansiyel_Proc.Params.ParamByName('@IL').Value := (Adres_Il);
                Rehber_Potansiyel_Proc.Params.ParamByName('@ULKE').Value := (Adres_Ulke);
                if Not_TarihSt='' then
                  Rehber_Potansiyel_Proc.Params.ParamByName('@NOTTARIHI').Value := varNull
                 else
                  Rehber_Potansiyel_Proc.Params.ParamByName('@NOTTARIHI').Value := Tarih_Iletisim;// QS(Not_TarihSt);
                Rehber_Potansiyel_Proc.Params.ParamByName('@YORUM').Value := (NotYorum);
                Rehber_Potansiyel_Proc.ExecProc;
                RehberID := Rehber_Potansiyel_Proc.Params.ParamByName('@ResultID').Value;

                { Memory Dataset verilerinden "Rehber_Potansiyel_Proc" çalýþtýrldý
                  "META_Collect". RehberID ve Import_Date güncellenmeli
                }
                qryKayitUpdate.SQL.Text := 'SELECT * FROM META_Collect WHERE Contact_ID='+
                                               QS( VarToString( gridRow.Values[MetaViewContact_ID.Index] ) );
                qryKayitUpdate.Open;
                if qryKayitUpdate.RecordCount>0 then
                 begin
                   qryKayitUpdate.Edit;
                   qryKayitUpdate.FieldByName('Contact_RehberID').AsInteger := RehberID;
                   qryKayitUpdate.FieldByName('Import_Date').AsDateTime := Now;
                   qryKayitUpdate.Post;
                 end;
                qryKayitUpdate.Close;

              end;// Not Imported
          end;  // for donguSecim

      except
           on ExMetaCollect001 : exception do
            begin
             {$IFDEF 3DParty} _LogEkle('META_CRM',ExMetaCollect001.Message); {$ENDIF}
               ShowMessage('META_CRM'#13#10+ExMetaCollect001.Message);
             end;
      end;

    finally
      qryKayitSorgula.Free;
      Rehber_Potansiyel_Proc.Free;
      AramaYap;//AdoToMem;
      //dxMemCollect.EnableControls;
      Screen.Cursor := crDefault;
    end;

end;

procedure TSocialMediaFrame.DoWorkImapMails;
var
  tempConn     : TFDConnection;
  qryData       : TFDQuery;
  sonUID        : integer;
  SearchList,
  List          : TStrings;
  msg           : TIdMessage;
  SearchStr     : string;
  i             : integer;
  aLeadData     : recLead;
  aDateTime     : TDateTime;
  //storeItem     : TIdIMAP4StoreDataItem;
begin
  //
  labelInfo.Caption := 'Mails Modül oluþturuluyor.';
  if Not Assigned(ImapModule) then
    ImapModule := TImapModule.Create(Self);
  {$IFDEF 3DParty} LogSocialMedia('* Entry..DoWorkImapMails','SOCIAL_IMAP'); {$ENDIF}

  ImapModule.Server := IServer;
  ImapModule.UserName := IUsername;
  ImapModule.Password := IPassword;
  ImapModule.Port := IPort;
  ImapModule.TLSSupport :=  TIdUseTLS(ITLSS);

  { MulitThread yordamlar ADO baðlantýsý için ayrý bir kopyasýyla çalýþacaktýr
    MainThread içinde kullanýdýðýmýz ADOconnection beklenmeyen sonuçlara ve programýn donmasýna neden olur
    Geçici olarak yeni bir ADOconnection ile çalýþýlacaktýr.
  }

  CoInitialize(nil);
  tempConn := TFDConnection.Create(Nil);

  try
    tempConn.Params.Assign(Tablo.FDCnn.Params);
    tempConn.LoginPrompt := False;
    tempConn.Connected := True;
    labelInfo.Caption := 'Mails sorgusu hazýrlanýyor';
    qryData:= TFDQuery.Create(Self);
    //IMAP_UID max deðeri alýnýyor
    qryDATA.SQL.Text := 'SELECT ISNULL(MAX(IMAP_UID), 0) from META_Collect';
    {$IFDEF 3DParty}LogSocialMedia('* qryDATA.SQL.Text = '+qryDATA.SQL.Text,'SOCIAL_IMAP');{$ENDIF}
    qryData.Connection := tempConn;
    qryDATA.Open;
    sonUID := qryData.Fields[0].AsInteger;
    qryData.Close;
    {Hiç kaydedilmiþ IMAP_UID deðeri yoksa "0" gelecektir, bu koþulda ilk IMAP_UID deðeri en az "1" olmalý
     Aksi durumda Son Kaydedilmiþ IMAP_UID deðerinden devam etmeli }
    if (sonUID = 0) then
      sonUID := sonUID + 1;
    List := TStringList.Create;

    SearchList := TStringList.Create;

    ImapModule.Connect;
    if ImapModule.Connected then
     begin
       {$IFDEF 3DParty} LogSocialMedia('* IMAP..Connected','SOCIAL_IMAP'); {$ENDIF}
       labelInfo.Caption := 'Mails IMAP4 yeni postalar sorgulanýyor';
       qryData.SQL.Text := 'SELECT * FROM META_Collect';
       qryData.Open;

       SearchStr := 'UID SEARCH ';
       if IToMail<>'' then
         SearchStr := SearchStr + '(FROM "'+IToMail+'") ';
      {UID numarasýndan önce "UID" deyimi çok önemli!
       UID SEARCH 267:* yazýlmasý halinde Sequence numarasýndan baþlar
       UID SEARCH UID 267:* yazýlmasý UID numarasýndan baþlar. istenen þey!
      }
       SearchStr := SearchStr + 'UID '+sonUID.ToString+':*';
       {$IFDEF 3DParty} LogSocialMedia('SEARCH STR = '+SearchStr,'SOCIAL_IMAP'); {$ENDIF}
       {
        UID SEARCH UID 267:*
        Arama kriterlerine uygun Liste oluþtu
       }
       ImapModule.SearchExt(SearchStr, SearchList);
       ClearEmptyLines(SearchList);
       { Arama Listesi kadar döngü kurulup
         Postalar UID ile FETCH edilmeli
         Tüm Listeyi tek seferde FETCH etmek te mümkün. FAKAT!!!!
         Tüm postalarýn toplu halde gelmesi durumunda Uzun bir string dönebilir!!
       }
       {$IFDEF 3DParty} LogSocialMedia('Search Result >> '+ StringReplace( SearchList.Text,#13#10,', ',[rfReplaceAll] ), 'SOCIAL_IMAP'); {$ENDIF}
       for i := 0 to SearchList.Count-1 do
         begin
           labelInfo.Caption := 'Mails ('+SearchList[i]+') ePosta Verisi alýnýyor';
           msg := ImapModule.GetMail(SearchList[i]);
           ImapModule.IdIMAP4.UIDStoreFlags([SearchList[i]], sdReplace, [mfSeen] );
           {$IFDEF 3DParty} LogSocialMedia(i.ToString+' Mail ['+SearchList[i]+'] ID = '+msg.MsgId+' ('+msg.Subject+')  UID ['+msg.UID+'] ' +msg.Body.Text, 'SOCIAL_IMAP'); {$ENDIF}
           Sleep(300);

           if msg.From.Address = IToMail then
            begin
               aLeadData := Default(recLead);

               ImapModule.ExtractMail(msg, aLeadData);
              //AddToDatabase;

               aLeadData.created_time := DateTimeToStr(msg.Date);
               aDateTime := msg.Date;
               aLeadData.id := UnQuote(msg.MsgId);

               if (aLeadData.id<>'') and (aLeadData.FULL_NAME<>'') then
                begin
                  if qryData.Locate('Contact_ID', aLeadData.id, []) then
                  begin
                    qryData.Edit;
                    qryData.FieldByName('IMAP_UID').AsInteger := SearchList[i].ToInteger;
                    qryData.Post;
                  end
                  else
                    begin
                    qryData.Append;
                    qryData.FieldByName('IMAP_UID').AsInteger := SearchList[i].ToInteger;
                    qryData.FieldByName('ID').AsInteger := qryData.RecordCount + 1;
                    qryData.FieldByName('Contact_ID').AsString := aLeadData.id;

                    qryData.FieldByName('Meta_Class').AsInteger := 3;   //3=IMAP Web Form

                    qryData.FieldByName('Contact_Name').AsString := aLeadData.FULL_NAME;
                    qryData.FieldByName('Contact_Phone').AsString := aLeadData.PHONE;
                    qryData.FieldByName('Contact_Phone2').AsString := aLeadData.PHONE2;
                    qryData.FieldByName('Contatc_eMail').AsString := aLeadData.EMAIL;
                    qryData.FieldByName('Contact_Address').AsString := aLeadData.STREET_ADDRESS;
                    qryData.FieldByName('Contact_Gender').AsString := aLeadData.GENDER;
                    qryData.FieldByName('Contact_City').AsString := aLeadData.CITY;
                    qryData.FieldByName('Contact_Country').AsString := aLeadData.COUNTRY;
                    qryData.FieldByName('Contact_Town').AsString := aLeadData.TOWN;
                    qryData.FieldByName('Last_Update').AsDateTime := aDateTime;
                    qryData.FieldByName('NOT1').AsString := aLeadData.NOT1;
                    qryData.Post;
                  end;
                end;
            end; // if msg.From.Address = IToMail
         end; // for i := 0 to SearchList.Count-1 do
     end // if ImapModule.Connected then
       else
       begin
         labelInfo.Caption := 'IMAP ePosta baðlantýsý saðlanamadý!';
         raise Exception.Create('IMAP ePosta baðlantýsý saðlanamadý!');
       end;

  finally
    labelInfo.Caption := 'Posta iþleme tamamlandý';
    if Assigned(ImapModule) then
     begin
       if ImapModule.Connected then
         ImapModule.Disconnect;
       FreeAndNil(ImapModule);
       {$IFDEF 3DParty} LogSocialMedia('ImapModule Freed', 'SOCIAL_IMAP'); {$endif}
     end;
    tempConn.Free;
    qryData.Free;
    CoUninitialize();
    List.Free;
    SearchList.Free;
  end;

end;

procedure TSocialMediaFrame.DoWorkMessages;
var
  LongLiveToken : string;
  i, y          : integer;
  aMessageData : TMessageDataRec;
  aLeadData    : recLead;
  aDateTime    : TDateTime;
  tempConn     : TFDConnection;
  qryMeta      : TFDQuery;

begin

  if PageID='' then
    raise Exception.Create('Sayfa ID tanýmsýz doðru bilgileri tanýmlayýnýz');

  { MulitThread yordamlar ADO baðlantýsý için ayrý bir kopyasýyla çalýþacaktýr
    MainThread içinde kullanýdýðýmýz ADOconnection beklenmeyen sonuçlara ve programýn donmasýna neden olur
    Geçici olarak yeni bir ADOconnection ile çalýþýlacaktýr.
  }
  tempConn := TFDConnection.Create(Nil);

  tempConn.Params.Assign(Tablo.FDCnn.Params);
  tempConn.LoginPrompt := False;
  qryMeta := TFDQuery.Create(Nil);
  qryMeta.Connection := tempConn;
  CoInitialize(nil);
  {$IFDEF 3DParty} LogSocialMedia('actStartStop.Enabled := False'); {$ENDIF}
  try

    Sleep(500);

    tempConn.Connected := True;

    LongLiveToken := GetLongLiveUserAccesToken(AppID, AppSecret, PageToken);
    if Pos('ERROR',LongLiveToken)=0 then
    begin
    {$IFDEF 3DParty}LogSocialMedia('1.LongLiveToken alýndý'); {$ENDIF}

    {$REGION 'Conversations'}
    Conversations.Clear;
    labelInfo.Caption := 'Messenger verileri alnýyor';
    GetConversationsList(PageID,'MESSENGER',LongLiveToken, Conversations);
    {$IFDEF 3DParty}LogSocialMedia('2.GetConversationsList MESSENGER Sonrasý');{$ENDIF}
    labelInfo.Caption := 'Instagram verileri alnýyor';
    GetConversationsList(PageID,'INSTAGRAM',LongLiveToken, Conversations);
      {$IFDEF 3DParty}LogSocialMedia('3.GetConversationsList INSTAGRAM Sonrasý');{$ENDIF}

    qryMeta.SQL.Text := 'SELECT * FROM META_Collect';
    qryMeta.Open;
    {$IFDEF 3DParty}LogSocialMedia('3.1.qryMeta.Open...');{$ENDIF}
    {$IFDEF 3DParty}LogSocialMedia('4.qryMetaCollect.Open');{$ENDIF}
      for i := 0 to Conversations.Count-1 do
       begin
         Messages.Clear;
         GetMessagesList( Conversations[i].ItemId ,Conversations[i].Platform, LongLiveToken, Messages );
         {$IFDEF 3DParty}LogSocialMedia(' 5.['+i.ToString+']. GetMessagesList');{$ENDIF}
         for y := 0 to Messages.Count-1 do
            begin
              labelInfo.Caption := 'Messenger/Instagram verileri iþleniyor ('+i.ToString+')';
              aMessageData := GetMessageData(Messages[y].ItemId,'id,created_time,from,to,message', Messages[y].Platform, LongLiveToken);
              {$IFDEF 3DParty}LogSocialMedia('  6.['+i.ToString+'].['+y.ToString+'] GetMessageData');{$ENDIF}
              if (aMessageData.message_UserName<>'') and (aMessageData.from_id<>'') then
              begin
                // Contact_ID benzeri kayýt olmamalý
                if qryMeta.Locate('Contact_ID', aMessageData.from_id, []) then
                    qryMeta.Edit
                else
                  begin
                     qryMeta.Append;
                     qryMeta.FieldByName('ID').AsInteger := qryMeta.RecordCount + 1;
                     qryMeta.FieldByName('Contact_ID').AsString := aMessageData.from_id;
                  end;
                {Messenger}
                qryMeta.FieldByName('Meta_Class').AsInteger := 1;   //1=Messenger

                if qryMeta.FieldByName('Contact_Name').AsString='' then
                  qryMeta.FieldByName('Contact_Name').AsString := aMessageData.message_UserName;
                if qryMeta.FieldByName('Contact_Phone').AsString='' then
                  qryMeta.FieldByName('Contact_Phone').AsString := aMessageData.message_Phone;
                if qryMeta.FieldByName('Contatc_eMail').AsString='' then
                  qryMeta.FieldByName('Contatc_eMail').AsString := aMessageData.message_email;

                System.DateUtils.TryISO8601ToDate(aMessageData.created_time, aDateTime);
                qryMeta.FieldByName('Last_Update').AsDateTime := aDateTime;

                //if Messages[y].Platform='MESSENGER' then
                  qryMeta.FieldByName('FB_Support').AsBoolean := True;
                //if Messages[y].Platform='INSTAGRAM' then
                //  qryMeta.FieldByName('Insta_Support').AsBoolean := True;
                if aMessageData.Title<>'' then
                  qryMeta.FieldByName('NOT1').AsString := aMessageData.Title
                   else
                     qryMeta.FieldByName('NOT1').AsString := aMessageData.message;
                end;// if aMessageData.message_UserName<>''
            end;
       end;
      {$ENDREGION}

     {--}
      {$IFDEF 3DParty}LogSocialMedia('META FormLeads Section');{$ENDIF}

      {$REGION 'FormLeads'}
      labelInfo.Caption := 'Forms Listesi alýnýyor verileri alnýyor';
      if PageForms.Count<1 then
        GetFormsByPage( PageID, LongLiveToken, PageForms);

      {$IFDEF 3DParty}LogSocialMedia('PageForms.Count = '+PageForms.Count.ToString);{$ENDIF}

      for i := 0 to PageForms.Count-1 do
      begin
        labelInfo.Caption := 'Forms('+i.ToString+') '+PageForms[i].Text+' locale : '+PageForms[i].Locale;

        if PageForms[i].Status then
        begin
          FormLeads.Clear;
          labelInfo.Caption := 'Forms('+i.ToString+') '+PageForms[i].Text+' locale : '+PageForms[i].Locale+' Etkileþim alýnýyor...';
          GetLeadsByForm(PageForms[i].ItemId, LongLiveToken, FormLeads);
          {$IFDEF 3DParty}LogSocialMedia(' 7.GetLeadsByForm['+i.ToString+'] ItemId = '+PageForms[i].ItemId);{$ENDIF}

          for y := 0 to FormLeads.Count-1 do
           begin
            //if FormLeads[y].Status = true then
            // begin
               labelInfo.Caption := 'Forms('+i.ToString+') '+PageForms[i].Text+' Etkileþim : ('+y.ToString+') Verisi alýnýyor';
               aLeadData := GetLeadData(FormLeads[y].ItemId, LongLiveToken);
               {$IFDEF 3DParty}LogSocialMedia(' 7.'+i.ToString+'.'+y.ToString+'.GetLeadData['+y.ToString+'] ItemId = '+FormLeads[y].ItemId);{$ENDIF}
               // Contact_ID benzeri kayýt olmamalý
               if aLeadData.id<>'' then
                begin
                  if qryMeta.Locate('Contact_ID', aLeadData.id, []) then
                    qryMeta.Edit
                  else
                    begin
                      qryMeta.Append;
                      qryMeta.FieldByName('ID').AsInteger := qryMeta.RecordCount + 1;
                      qryMeta.FieldByName('Contact_ID').AsString := aLeadData.id;
                    end;
                  {MetaForms}
                  qryMeta.FieldByName('Meta_Class').AsInteger := 2;   //1=MetaForms

                  qryMeta.FieldByName('Contact_Name').AsString := aLeadData.FULL_NAME;
                  qryMeta.FieldByName('Contact_Phone').AsString := aLeadData.PHONE;
                  qryMeta.FieldByName('Contact_Phone2').AsString := aLeadData.PHONE2;
                  qryMeta.FieldByName('Contatc_eMail').AsString := aLeadData.EMAIL;
                  qryMeta.FieldByName('Contact_Address').AsString := aLeadData.STREET_ADDRESS;
                  qryMeta.FieldByName('Contact_Gender').AsString := aLeadData.GENDER;
                  qryMeta.FieldByName('Contact_City').AsString := aLeadData.CITY;
                  qryMeta.FieldByName('Contact_Country').AsString := aLeadData.COUNTRY;
                  qryMeta.FieldByName('FB_Support').AsBoolean := True;
                  System.DateUtils.TryISO8601ToDate(aLeadData.created_time, aDateTime);
                  qryMeta.FieldByName('Last_Update').AsDateTime := aDateTime;
                  qryMeta.FieldByName('NOT1').AsString := aLeadData.NOT1;
                  qryMeta.Post;
                  {$IFDEF 3DParty}LogSocialMedia(' 7. Post Data');{$ENDIF}
                end; // if aLeadData.id<>'' then
             //end;
           end; // for y := 0 to FormLeads.Count-1 do
         end; // if PageForms[i].Status then
      end; // for i := 0 to PageForms.Count-1 do
      {$ENDREGION}

    end;

  finally
    qryMeta.Close;
    tempConn.Close;
    qryMeta.Free;
    {$IFDEF 3DParty}LogSocialMedia(' End. qryMetaCollect.Closed');{$ENDIF}

    tempConn.Free;
    CoUninitialize();
    labelInfo.Caption := '';
    Tablo.GENINI.WriteDateTime(Ops_SocialMedia_MetaGuncelleme, Now);
    {}       // META_Collect ADO Veritabaný dxMemCollect Memory tabloya aktarýlacak !
    //AdoToMem; Bunu Thread bitiminde çaðýr
    {}
  end;
end;

procedure TSocialMediaFrame.dxMemCollect_REMOVECalcFields(DataSet: TDataSet);
begin
  if DataSet.FieldByName('Contact_RehberID').AsString<>'' then
   DataSet.FieldByName('Imported').AsBoolean := True
  else
   DataSet.FieldByName('Imported').AsBoolean  := False;

   DataSet.FieldByName('Temas').AsString := 'Medya';
end;

procedure TSocialMediaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TSocialMediaFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TSocialMediaFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure TSocialMediaFrame.FiltreAcKapat;
begin
  if Assigned(FArama) then
     MetaView.FilterRow.Visible := FArama.CheckFilreSatiri.Checked;
end;

function TSocialMediaFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TSocialMediaFrame.GetKapatilabilir: Boolean;
begin
  //
  Result := False;
end;

procedure TSocialMediaFrame.Gorunmez;
begin

end;

procedure TSocialMediaFrame.GorunmezOlacak;
begin

end;

procedure TSocialMediaFrame.Gorunur;
begin

end;

procedure TSocialMediaFrame.GorunurOlacak;
begin

end;

procedure TSocialMediaFrame.GruplamaKayitlaAcKapat;
begin
  if Assigned(FArama) then
     MetaView.OptionsView.GroupByBox := FArama.CheckGroupBox.Checked;
end;

procedure TSocialMediaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TSocialMediaFrame.LabelSonArananlarClick(Sender: TObject);
begin
//1
end;

procedure TSocialMediaFrame.LabelTumKayitlarClick(Sender: TObject);
begin
  //2
  if Assigned(FArama) then
   begin
     FArama.AraFirma.Text := '';
     FArama.dateStart.Text := '';
     FArama.dateEnd.Text := '';
     FArama.ComboSinif.Text := '';
     FArama.comboTemsilci.Text := '';
     FArama.AraSehir.Text := '';
     FArama.AraUlke.Text := '';
     AramaYap();
   end;
end;

procedure TSocialMediaFrame.LogSocialMedia(_Message: string; _Provider : string = 'SOCIAL_META');
begin
   if Not LoggToFile then
     Exit;
   {$IFDEF 3Dparty}
     _LogEkle(_Provider,_Message);
   {$endif}
end;

procedure TSocialMediaFrame.MedyaYenile(Sender: TObject);
var
  hand  : THandle;
  Trd : TThread;
  SosyalEklentiler : array[0..9] of boolean;
  MetaGuncellemeUygunmu : boolean;
begin
  // DoWork...
   FillChar(SosyalEklentiler, 10 , false);

   {
   if (Sender is TToolbutton) and (TToolbutton(Sender).Name = 'buttonYenile' ) then
      FillChar(SosyalEklentiler, 10 , True)
    else
     if (Sender is TMenuItem) then
       SosyalEklentiler[TMenuItem(Sender).Tag] := true;
   }
   FillChar(SosyalEklentiler, 10 , True);
  {
    Meta Verileri sürekli sorgulanmasýn , OPT/CRM Meta sekmesinde parametrik bir deðere baðlý olarak,
    Zaman aralýðýna uygun davransýn (15, 30, 120 dakika vs)

    GENINI "Ops_SocialMedia_MetaGuncelleme" anahtarý ile kaydedilen Dakika aralýðýna uygunluðu gözetlenecektir.
    Uygun Zaman gelmemiþ ise boþuna META verilerini çekmesin
  }
  MetaGuncellemeUygunmu := MetaZamanUygunmu;

  if SosyalEklentiler[1] then
    SosyalEklentiler[1] := MetaGuncellemeUygunmu;
   {$IFDEF 3DParty} LogSocialMedia('SosyalEklentiler[1] ='+BoolToStr(SosyalEklentiler[1], True)); {$ENDIF}

  if Assigned(FBThreadEvent) then
     FBThreadEvent.Free;

  SetControlsStatus( True );

  // UNUTMA remark kaldýrýlacak

  //(1) Meta iþleri yapýlacak
   if Tablo.GENINI.ReadBoolean(Ops_SocialMedia_Meta, False) and Initialized and SosyalEklentiler[1] then
    begin
      try
        FBThreadEvent := TEvent.Create;
        Trd:=  TThread.CreateAnonymousThread(
            procedure
            begin
              try
                DoWorkMessages();
              finally
                FBThreadEvent.SetEvent;
              end;
            end);

         //Trd.OnTerminate := ThreadBitti;
         Trd.Start;
          hand := FBThreadEvent.Handle;
          while MsgWaitForMultipleObjects(1, hand, False, INFINITE, QS_ALLINPUT) = (WAIT_OBJECT_0 + 1) do
          begin
            IndicatorDots.Active := True;
            IndicatorDots.Update;
            Application.ProcessMessages;
          end;
      finally
        FBThreadEvent.Free;
        FBThreadEvent := Nil;
        Trd := Nil;
       end;
      labelInfo.Caption := 'Meta Güncelleme Tamamlandý';

    end;

    if Not MetaZamanUygunmu then
      labelInfo.Caption := 'Güncelleme zaman kýstasý uygulandý';
    Sleep(1000);


    // (2) IMAP (WebForm) veri okuma
    if Tablo.GENINI.ReadBoolean(Ops_SocialMedia_IMAP, False) and SosyalEklentiler[2] then
    begin
      try
        FBThreadEvent := TEvent.Create;
        Trd:=  TThread.CreateAnonymousThread(
            procedure
            begin
              try
                DoWorkImapMails();
              finally
                FBThreadEvent.SetEvent;
              end;
            end);
         Trd.Start;
          hand := FBThreadEvent.Handle;
          while MsgWaitForMultipleObjects(1, hand, False, INFINITE, QS_ALLINPUT) = (WAIT_OBJECT_0 + 1) do
          begin
            IndicatorDots.Active := True;
            IndicatorDots.Update;
            Application.ProcessMessages;
          end;
      finally
        FBThreadEvent.Free;
        FBThreadEvent := Nil;
        Trd := Nil;
       end;
      labelInfo.Caption := '"Web Form" IMAP Güncelleme Tamamlandý';
      Sleep(1000);
    end;

    SetControlsStatus( False );
    Application.ProcessMessages;

    AktarilmislariEslestir;
    qryMetaCollect.Close;
    qryMetaCollect.Open;
    //AdoToMem;
end;

procedure TSocialMediaFrame.ThreadBitti(Sender: TObject);
begin
  {$IFDEF 3DParty}LogSocialMedia('Thread Sonlandý');{$ENDIF}
  labelInfo.Caption := 'Güncelleme Tamamlandý';
end;

procedure TSocialMediaFrame.MetaSELECTPropertiesChange(Sender: TObject);
begin
 (*
 if TcxCheckBox(Sender).Checked then
  begin
    if (dxMemCollect.FieldByName('Imported').AsBoolean) {or (dxMemCollect.FieldByName('Import_Date').AsString<>'')} then
      TcxCheckBox(Sender).Checked := False;
  end;
  }
  *)
end;

procedure TSocialMediaFrame.MetaSELECTPropertiesValidate(Sender: TObject; var DisplayValue: Variant;
  var ErrorText: TCaption; var Error: Boolean);
begin
  (*
  if (dxMemCollect.FieldByName('Imported').AsBoolean) {or (dxMemCollect.FieldByName('Import_Date').AsString<>'')} then
     begin
        Error := True;
        ErrorText := 'Daha önce içeri alýnmýþ bir kayýt Seçilemez';
        dxMemCollect.Cancel;
     end;
  *)
end;

procedure TSocialMediaFrame.MetaViewCanSelectRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  {
  if (ARecord.Values[1] = True) then
   begin
     AAllow := False;
     Exit;
   end;

  if ARecord.Values[0] = True then
   begin
     AAllow := True;
     ARecord.Values[0] := False;
     Exit;
   end;
  AAllow := (ARecord.Values[1] = False) or (VarToString(ARecord.Values[1])='');
  if AAllow then
   ARecord.Values[0] := True;
   }
end;

procedure TSocialMediaFrame.MetaViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
   {Gruplama yapýldýðýnda hata olmasýn, çünkü Gruplama anýna Grup Satýrý için AItem NULL gelecetir}
   if Not Assigned(AItem) then
     Exit;

   // Imported = Ýçeri aktarýlmýþ ise
   //if VarToBool(ARecord.Values[1])=True then
   if VarToBool(ARecord.Values[MetaViewImported.Index])=True then
     AStyle := cxStyle_Aktarilmis
      else
        AStyle := Nil;

   // Durum = Pasif ise
   if AStyle = nil then
     if VarToBool(ARecord.Values[ MetaViewDurum.Index ]) = False then
       AStyle := cxStyle_Pasif
        else
          AStyle := Nil;

end;

function TSocialMediaFrame.MetaZamanUygunmu: boolean;
var
  INITarih : TDateTime;
begin
   INITarih := Tablo.GENINI.ReadDateTime(Ops_SocialMedia_MetaGuncelleme, 0);
   if INITarih = 0 then
    begin
      Result := True;
      {$IFDEF 3DParty}LogSocialMedia('INI Tanýmý olmadýðýndan Varsayýlan TRUE');{$ENDIF}
    end
    else
     begin
       Result := Now > IncMinute(INITarih, MetaUpdatePeriod);
       {$IFDEF 3DParty}LogSocialMedia('MetaUpdatePeriod = '+MetaUpdatePeriod.ToString+' + INITarih ='+IncMinute(INITarih, MetaUpdatePeriod).ToString('yyyy-MM-dd HH:mm:ss')+' Result = '+BoolToStr(Result, True));{$ENDIF}
     end;
end;

procedure TSocialMediaFrame.PasifKayitlaAcKapat;
begin
 if Assigned(FArama) then
  begin
    fPasifKayitGoster := FArama.CheckPasifKayitlar.Checked;
    AramaYap();
  end;
end;

procedure TSocialMediaFrame.qryMetaCollectCalcFields(DataSet: TDataSet);
begin
  if DataSet.FieldByName('Contact_RehberID').AsString<>'' then
   DataSet.FieldByName('Imported').AsBoolean := True
  else
   DataSet.FieldByName('Imported').AsBoolean  := False;
   {
   if (DataSet.FieldByName('FB_Support').AsBoolean) or
      (DataSet.FieldByName('Insta_Support').AsBoolean) or
      (DataSet.FieldByName('Whatsapp_Support').AsBoolean) then
      }
   DataSet.FieldByName('Temas').AsString := 'Medya';
end;

procedure TSocialMediaFrame.SetArama(const Value: TSocialAramaFrame);
begin
  FArama := Value;
end;

procedure TSocialMediaFrame.SetControlsStatus(_Status : boolean);
begin
    IndicatorDots.Active := _Status; //actStartStop.Checked;
    labelInfo.Caption := constActInfo[_Status{actStartStop.Checked}];

    if Assigned( FArama) then
     begin
       FArama.buttonYenile.Enabled := Not _Status;
       FArama.ToolBar6.Refresh;

     end;
end;

procedure TSocialMediaFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TSocialMediaFrame.SetupIMAP(_IServer, _IUsername, _IPassword, _IRoot, _IToMail: string; _IPort: word; _ITLSS: integer);
begin
   IServer   :=  _IServer;
   IUsername :=  _IUsername;
   IPassword :=  _IPassword;
   IRoot     :=  _IRoot;
   IToMail   :=  _IToMail;
   IPort     :=  _IPort;
   ITLSS     :=  _ITLSS;
end;

procedure TSocialMediaFrame.SetupMeta(_AppID, _AppSecret, _AppName, _PageID, _PageToken : string; _UpdatePeriod : integer);
begin
  AppID := _AppID;
  AppSecret := _AppSecret;
  AppName := _AppName;
  PageID := _PageID;
  PageToken := _PageToken;
  MetaUpdatePeriod := _UpdatePeriod;
  if MetaUpdatePeriod < 10 then
    MetaUpdatePeriod := 10;

  if (AppId='') or (AppSecret='') or (PageID='') or (PageToken='') then
    raise Exception.Create('Parametreler boþ olamaz!');
   if AppName='' then
     AppName := 'DefaultApp';
   {
   editAPP.Text := AppName+' | '+AppID;
   editAppSecret.Text := AppSecret;
   editPageID.Text := PageID;
   //memoToken.Lines.Text := PageToken;
   }
   Initialized := True;

end;

procedure TSocialMediaFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TSocialMediaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TSocialMediaFrame.TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TSocialMediaFrame.YaziciYazdir(Sender: TObject);
begin
//
end;

procedure TSocialMediaFrame.YenileTusClick(Sender: TObject);
begin
 // Filtrele;
  AramaYap;
end;

initialization

  RegisterClass(TSocialMediaFrame);

end.




