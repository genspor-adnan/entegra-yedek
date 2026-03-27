unit UTalimatlarListeFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 21/02/2010 23:05:30}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus, UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons,DB, UFDCompatHelpers,ToolWin, ExtCtrls,ShellAPI,
  UBankalarAramaFrame, cxStyles, dxSkinsCore, ZLibEx,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxImageComboBox, cxCurrencyEdit, cxSplitter, cxDropDownEdit,UTalimatOnay,
  cxCalendar, cxCheckBox, cxPC, frxClass, frxDBSet, UTalimatAramaFrame, DBCtrls,Utablo,
  cxLookAndFeels, cxNavigator, cxPCdxBarPopupMenu, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxBarBuiltInMenu;

type
  TTalimatlarListeFrame = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IPopupDialog )//IAracCubuguDestegi)
    DtsTalimatlar: TDataSource;
    TabTalimatlar: TFDQuery;
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    cxGrid: TcxGrid;
    GridTview: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    SilTus: TToolButton;
    PageControlSekme: TcxPageControl;
    PageSurec: TcxTabSheet;
    PageDetay: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGridDetay: TcxGridDBTableView;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    cxGrid1DBTableView1VADE: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    cxGrid1DBTableView1HESAPADI: TcxGridDBColumn;
    cxGrid1DBTableView1Column1: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    cxSplitter1: TcxSplitter;
    cxGrid2: TcxGrid;
    cxGridSurec: TcxGridDBTableView;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TabSurec: TFDQuery;
    DtsSurec: TDataSource;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    cxGridSurecPERSONEL: TcxGridDBColumn;
    cxGridSurecSURECTURU: TcxGridDBColumn;
    cxGridSurecDURUM: TcxGridDBColumn;
    cxGridDetayFIRMA: TcxGridDBColumn;
    cxGridDetayPLANTARIHI: TcxGridDBColumn;
    cxGridDetayACIKLAMA: TcxGridDBColumn;
    cxGridDetayCIKAN: TcxGridDBColumn;
    cxGridDetayKUR: TcxGridDBColumn;
    cxGridDetayAD: TcxGridDBColumn;
    GridTviewODEMETARIHI: TcxGridDBColumn;
    GridTviewTALIMATADI: TcxGridDBColumn;
    GridTviewDURUM: TcxGridDBColumn;
    GridTviewTutar: TcxGridDBColumn;
    GridTviewKur: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    AkibetAl: TMenuItem;
    PageBelge: TcxTabSheet;
    TabBelge: TFDQuery;
    DtsBelge: TDataSource;
    cxGrid3: TcxGrid;
    cxGridDBTableViewBelge: TcxGridDBTableView;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    cxGridDBTableViewBelgeBELGEADI: TcxGridDBColumn;
    cxGridDBTableViewBelgeSUREC: TcxGridDBColumn;
    cxGridDBTableViewBelgeDURUM: TcxGridDBColumn;
    cxGridDBTableViewBelgeEKLEMETARIHI: TcxGridDBColumn;
    cxGridDBTableViewBelgeColumn1: TcxGridDBColumn;
    SaveDialog1: TSaveDialog;
    cxGridDetayDURUM: TcxGridDBColumn;
    procedure YeniTusClick(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SilTusClick(Sender: TObject);
    procedure TabTalimatlarAfterOpen(DataSet: TDataSet);
    procedure TabTalimatlarAfterScroll(DataSet: TDataSet);
    procedure PageControlSekmePageChanging(Sender: TObject;
      NewPage: TcxTabSheet; var AllowChange: Boolean);
    procedure GridTviewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure AkibetAlClick(Sender: TObject);
    procedure cxGridDBTableViewBelgeDblClick(Sender: TObject);
    procedure GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure cxGridDBTableViewBelgeStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FArama      : TTalimatAramaFrame;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    procedure SetArama(const Value: TTalimatAramaFrame);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
    Procedure ComboIcerikOlustur(SQLText:string;Combo:TcxImageComboBoxProperties);
    procedure PageChange(NewPg:TcxTabSheet);

  public
    { Public declarations }
  published
    property Arama      : TTalimatAramaFrame read FArama write SetArama;
  end;

implementation

uses UAnaForm,FetaKurulusSiniflari, FetaClassExtensions, PrjConst, UFastRap, URaporAraclari,
UGenelAnaSekmeFrame, UKasalarListeFrame ,UTalimatWizard,UBinarySave,LocOnFly;

{$R *.dfm}

{ TTalimatlarListeFrame }


function TTalimatlarListeFrame.EkranAdiAl: string;
begin
  Result := 'TalimatListeFrame';
end;

procedure TTalimatlarListeFrame.Baslatildi;
var ra : string;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   SilTus.visible := TabTalimatlar.Active;
   PageControlSekme.ActivePageIndex := 1;
   //GridTview.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\TalimatlarGridi',true,False,[gsoUseFilter],'TalimatlarGridi');
   Tablo.GridAyarRestore('TalimatlarGridi',GridTview );

   Tablo.GridTurkcelestir;

end;

Procedure TTalimatlarListeFrame.ComboIcerikOlustur(SQLText:string;Combo:TcxImageComboBoxProperties);
Begin
  Combo.Items.Clear;
  Tablo.TablodanSorguAc(1,Sqltext);
  while not Tablo.Query1.eof do begin
    with Combo.Items.Add do begin
      Description:=Tablo.Query1.Fields[0].Value;
      Value:=Tablo.Query1.Fields[1].Value;
    end;
    Tablo.Query1.Next;
  end;
End;

procedure TTalimatlarListeFrame.cxGridDBTableViewBelgeDblClick(Sender: TObject);
var
  Stream_ : TStream;
  tempfile : TFileStream;
  fs : TMemoryStream;
begin
  Stream_ := TStream.Create;
  fs := TMemoryStream.Create;
  Stream_:= TabBelge.CreateBlobStream(TabBelge.FieldByName('BELGE'), bmRead);
  Stream_.Position:=0;
  //fs.Position:=0;
  ZDecompressStream( Stream_,fs);
  fs.Position:=0;
  SaveDialog1.Title := 'Belge Kaydetme';
  SaveDialog1.DefaultExt := ExtractFileExt(TabBelge.FieldByName('BELGEADI').AsString);
  SaveDialog1.Filter:=ExtractFileExt(TabBelge.FieldByName('BELGEADI').AsString)+' dosyasý'+'|*'+ExtractFileExt(TabBelge.FieldByName('BELGEADI').AsString);
  SaveDialog1.InitialDir := GetEnvironmentVariable('%USERPROFILE%')+'\Desktop';
  SaveDialog1.FileName := ExtractFileName(TabBelge.FieldByName('BELGEADI').AsString);
  if SaveDialog1.Execute then begin
    try
      try
        tempfile:= TFileStream.Create(SaveDialog1.FileName, fmCreate );
        tempfile.CopyFrom( fs, fs.Size  );
      except
        on EInOutError do
          MessageDlg('File I/O error.', mtError, [mbOk], 0);
      end;
    finally
      fs.Free;
      Stream_.Free;
      tempfile.Free;
    end;
  end;
end;

procedure TTalimatlarListeFrame.cxGridDBTableViewBelgeStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TTalimatlarListeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TTalimatlarListeFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTalimatlarListeFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTalimatlarListeFrame.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTalimatlarListeFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TTalimatlarListeFrame.Gorunmez;
begin

end;

procedure TTalimatlarListeFrame.GorunmezOlacak;
begin

end;

procedure TTalimatlarListeFrame.Gorunur;
begin
end;

procedure TTalimatlarListeFrame.GorunurOlacak;
begin

end;

procedure TTalimatlarListeFrame.GridTviewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGrid;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridTview;
AnaForm.pmGridStil.Tags.Values[cxGrid.Name]:='TalimatlarGridi';
end;

procedure TTalimatlarListeFrame.GridTviewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  SiradakiAktiviteID:Integer;
begin
  //süreçte sýradaki adýma ilerlenir..
  PageControlSekme.ActivePage:=PageSurec;
  TabSurec.First;
  if TabSurec.FieldByName('DURUM').AsInteger=9 then
    TabSurec.Next;
  if TabSurec.FieldByName('SORUMLU').value = Kullanan then begin
    Application.CreateForm(TTalimatOnayDlg, TalimatOnayDlg);
    TalimatOnayDlg.AktiviteID := TabSurec.FieldByName('ID').AsInteger;
    TalimatOnayDlg.ShowModal;
    TalimatOnayDlg.Free;
  end else
    raise Exception.Create(SurecAdimindakiKullanici);
  //PageControlSekme.ActivePage:=PageBelge;
  //TabBelge.Locate('SUREC;DURUM',VarArrayOf([0,1]),[]);
  //cxGridDBTableViewBelgeDblClick(Self);
//  KutuktenOku(TabTalimatlar,'BELGE','BELGEADI');
  //Tablo.TablodanSorguAc(5,'select * from AKTIVITELER where TALIMATID='+TabTalimatlar.FieldByName('ID').AsInteger+'');
  //Tablo.AktiviteGoster('D',nil,Tablo.Query5.FieldByName('ID').AsInteger,Tablo.Query5.FieldByName('ID').AsInteger,-2,Tablo.GENINI.BugunTrh);
end;

procedure TTalimatlarListeFrame.GridTviewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
  var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name,AStyle,Sender,ARecord);
end;

procedure TTalimatlarListeFrame.YazdirmayaHazirla(AFastReport: TfrxReport);
begin

end;

procedure TTalimatlarListeFrame.Kapatiliyor(var AKapansin: Boolean);
begin
end;

procedure TTalimatlarListeFrame.PageChange(NewPg:TcxTabSheet);
begin
  if NewPg=nil then
     NewPg:=PageControlSekme.ActivePage;
  if NewPg=PageSurec then begin
    TabSurec.Close;
    TabSurec.Parameters[0].Value:=TabTalimatlar.Fields[0].Value;
    TabSurec.Open;
  end else if NewPg=PageDetay then begin
    TabDetay.Close;
    TabDetay.Parameters[0].Value:=TabTalimatlar.Fields[0].Value;
    TabDetay.Open;
  end else if NewPg=PageBelge then begin
    TabBelge.Close;
    TabBelge.Parameters[0].Value:=TabTalimatlar.Fields[0].Value;
    TabBelge.Open;
  end;
end;

procedure TTalimatlarListeFrame.PageControlSekmePageChanging(Sender: TObject;
  NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  PageChange(NewPage);
end;

procedure TTalimatlarListeFrame.AkibetAlClick(Sender: TObject);
var
  akibetsonucu:Integer;
begin
  if (Tablo.TalimatinAkibetiniAl(TabTalimatlar.FieldByName('ID').AsInteger,akibetsonucu))and(akibetsonucu=1) then begin
    //

  end;
end;

procedure TTalimatlarListeFrame.AraKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then
    TabTalimatlar.Prior
  else if Key = 40 then
    TabTalimatlar.next
  else begin
    if (FArama.Calendar1.EditValue<>null)and(FArama.Calendar2.EditValue<>null) then
      TabloYenile(TabTalimatlar,[FormatDateTime('yyyy-mm-dd hh:nn',FArama.Calendar1.Date),FormatDateTime('yyyy-mm-dd hh:nn',FArama.Calendar2.Date)]);
  end;
  PageChange(Nil);
end;

procedure TTalimatlarListeFrame.SetArama(const Value: TTalimatAramaFrame);
var k : word;
begin
  FArama := Value;
  with FArama do begin
    k := 0;
    Self.AraKodKeyUp(Self, k, []);
  end;
end;

procedure TTalimatlarListeFrame.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTalimatlarListeFrame.SilTusClick(Sender: TObject);
Var
  TalimatID:Integer;
  SQLText:string;
  Key: Word;
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then  begin
    TalimatID:=TabTalimatlar.FieldByName('ID').AsInteger;
    //Seçili Talimat bankaya gönderilmiþ mi??? gönderilmiþse sildirmeyiz...
    Tablo.Query4.Close;
    Tablo.Query4.SQL.Text := 'Select * from AKTIVITELER where SONUC<>0 and TALIMATID='+inttostr(TalimatID);
    Tablo.Query4.Open;
    if Tablo.Query4.RecordCount>0 then Begin
       raise Exception.Create(TalimatSilinemez);
    End Else begin
      SQLText:='Delete from TALIMATLAR where ID='+inttostr(TalimatID);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,SQLText,[],[]);
      SQLText:='Delete from TALIMATBELGELER where TALIMATID='+inttostr(TalimatID);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,SQLText,[],[]);
      SQLText:='Delete from AKTIVITELER where TALIMATID='+inttostr(TalimatID);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,SQLText,[],[]);
      SQLText:='Delete from TALIMATDETAY where TALIMATID='+inttostr(TalimatID);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,SQLText,[],[]);
    end;
    AraKodKeyUp(Self, Key, []);
  end;
end;

procedure TTalimatlarListeFrame.TabTalimatlarAfterOpen(DataSet: TDataSet);
begin
   SilTus.Visible := TabTalimatlar.RecordCount>0;
end;

procedure TTalimatlarListeFrame.TabTalimatlarAfterScroll(DataSet: TDataSet);
begin
    PageChange(Nil);
end;

procedure TTalimatlarListeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTalimatlarListeFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTalimatlarListeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTalimatlarListeFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TTalimatlarListeFrame.YeniTusClick(Sender: TObject);
var ID:Integer;
    Key: Word;
begin
    Application.CreateForm(TTalimatWizardDlg, TalimatWizardDlg);
    TalimatWizardDlg.TalimatID := 0;
    TalimatWizardDlg.ShowModal;
    TalimatWizardDlg.Destroy;
    AraKodKeyUp(Self, Key, []);
end;

initialization
  RegisterClass(TTalimatlarListeFrame);
end.


