unit UIsEmriPersonelZaman;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxDBEdit, cxDropDownEdit, cxCalendar, cxButtonEdit,
  cxImageComboBox, cxTextEdit, cxMaskEdit, cxSpinEdit, cxTimeEdit, cxLabel, cxDBLabel,
  cxGroupBox, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Data.DB, FireDAC.Comp.Client,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,DateUtils,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxBarBuiltInMenu,
  cxPC, Vcl.Menus, cxCustomData, cxStyles, dxScrollbarAnnotations, cxTL,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, cxButtons,
  cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges, cxDBData,
  Vcl.ComCtrls, Vcl.ToolWin, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxCurrencyEdit, cxMemo, dxCoreGraphics, cxScrollBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TIsEmriPersonelZamanDlg = class(TForm)
    ServisHarPanelAlt: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    DtsUretimOperasyonPersonel: TDataSource;
    TabUretimOperasyonPersonel: TFDQuery;
    PageControlUst: TcxPageControl;
    TabSheetCalisma: TcxTabSheet;
    GroupDetay: TcxGroupBox;
    GrpBaslama: TcxGroupBox;
    cxLabel2: TcxLabel;
    TimeBASLA: TcxDBTimeEdit;
    TimeBITIS: TcxDBTimeEdit;
    cxLabel6: TcxLabel;
    cxLabel4: TcxLabel;
    TimeMOLA: TcxDBTimeEdit;
    DateBASLA: TcxDBDateEdit;
    DateBITIS: TcxDBDateEdit;
    TabSheetOlcum: TcxTabSheet;
    Panel1: TPanel;
    PanelBaslik: TPanel;
    cxGroupBox1: TcxGroupBox;
    Panel3: TPanel;
    GridOlcumDetay: TcxGrid;
    GridOlcumDetayView: TcxGridDBTableView;
    GridOlcumDetayViewID: TcxGridDBColumn;
    GridOlcumDetayViewKALITESABLONID: TcxGridDBColumn;
    GridOlcumDetayViewADI: TcxGridDBColumn;
    GridOlcumDetayViewTESTID: TcxGridDBColumn;
    GridOlcumDetayViewBIRIM: TcxGridDBColumn;
    GridOlcumDetayViewTOLERANSDEGERI: TcxGridDBColumn;
    GridOlcumDetayViewOLCUALETI: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    ToolBar1: TToolBar;
    OlcumDetayKaydet: TToolButton;
    OlcumDetayIptal: TToolButton;
    GridOlcumDetayViewDEGERI: TcxGridDBColumn;
    GridOlcumDetayViewSAPMA: TcxGridDBColumn;
    TabOlcum: TFDQuery;
    DtsOlcum: TDataSource;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxGridDBTableViewTARIH: TcxGridDBColumn;
    TabOlcumID: TAutoIncField;
    TabOlcumOPERASYONID: TIntegerField;
    TabOlcumOPERASYONPERSONELID: TIntegerField;
    TabOlcumTARIH: TSQLTimeStampField;
    TabOlcumKONUSU: TWideStringField;
    TabOlcumPERSONEL: TIntegerField;
    TabOlcumLOKASYON: TIntegerField;
    TabOlcumKAYNAK: TIntegerField;
    TabOlcumADET: TFloatField;
    TabOlcumBIRIM: TIntegerField;
    TabOlcumACIKLAMA: TWideStringField;
    TabOlcumEKLEYEN: TSmallintField;
    TabOlcumEKLEMETARIHI: TSQLTimeStampField;
    TabOlcumDEGISTIREN: TSmallintField;
    TabOlcumDEGISTIRMETARIHI: TSQLTimeStampField;
    TabOlcumSORUMLUADI: TWideStringField;
    TabOlcumLOKASYONADI: TWideStringField;
    TabOlcumKAYNAKADI: TWideStringField;
    TabOlcumDetay: TFDQuery;
    DtsOlcumDetay: TDataSource;
    GridOlcumDetayViewNOMINAL: TcxGridDBColumn;
    GridOlcumDetayViewALARM: TcxGridDBColumn;
    TabOlcumDURUM: TWordField;
    cxGridDBTableView1DURUM: TcxGridDBColumn;
    TabOlcumALARM: TSmallintField;
    cxGridDBTableView1ALARM: TcxGridDBColumn;
    OlcumDetayYeni: TToolButton;
    OlcumDetaySil: TToolButton;
    PopupMenuOlcum: TPopupMenu;
    Nominal2OlculenMenu: TMenuItem;
    Panel4: TPanel;
    ToolBarSol: TToolBar;
    OlcumEkleBtn: TToolButton;
    OlcumSilBtn: TToolButton;
    OlcumKaydetBtn: TToolButton;
    OlcumIptalBtn: TToolButton;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    EditOlcumKonusu: TcxDBButtonEdit;
    EditOlcumSorumlu: TcxButtonEdit;
    EditOlcumLokasyon: TcxButtonEdit;
    cxLabel14: TcxLabel;
    EditOlcumKaynak: TcxButtonEdit;
    cxLabel15: TcxLabel;
    cxLabel16: TcxLabel;
    EditADET: TcxDBTextEdit;
    ComboBIRIM: TcxDBImageComboBox;
    cxLabel18: TcxLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxLabel17: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxDBTimeEdit1: TcxDBTimeEdit;
    ComboDURUM: TcxDBImageComboBox;
    cxLabel11: TcxLabel;
    cxGridDBTableView1KONUSU: TcxGridDBColumn;
    TabSheetEkAlan111: TcxTabSheet;
    TabSheetEkAlan222: TcxTabSheet;
    GridOlcumDetayViewLIMITYAZI: TcxGridDBColumn;
    Panel2: TPanel;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    EditKonusu: TcxDBButtonEdit;
    EditPersonel: TcxButtonEdit;
    EditLokasyon: TcxButtonEdit;
    cxLabel5: TcxLabel;
    EditKaynak: TcxButtonEdit;
    cxLabel7: TcxLabel;
    cxLabel9: TcxLabel;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxLabel10: TcxLabel;
    EditACIKLAMA: TcxDBMemo;
    EkAlanlarCalisma: TPanel;
    TabSheetEkAlan1: TPanel;
    TabSheetEkAlan2: TPanel;
    procedure EditKonusuPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabUretimOperasyonPersonelNewRecord(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabUretimOperasyonPersonelBeforeEdit(DataSet: TDataSet);
    procedure TabUretimOperasyonPersonelBeforePost(DataSet: TDataSet);
    procedure TabOlcumNewRecord(DataSet: TDataSet);
    procedure OlcumEkleBtnClick(Sender: TObject);
    procedure OlcumKaydetBtnClick(Sender: TObject);
    procedure OlcumIptalBtnClick(Sender: TObject);
    procedure OlcumSilBtnClick(Sender: TObject);
    procedure EditOlcumKonusuPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditOlcumSorumluPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditOlcumLokasyonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditOlcumKaynakPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DtsOlcumStateChange(Sender: TObject);
    procedure TabOlcumAfterPost(DataSet: TDataSet);
    procedure TabOlcumAfterScroll(DataSet: TDataSet);
    procedure TabOlcumDetayBeforePost(DataSet: TDataSet);
    procedure TabOlcumBeforeDelete(DataSet: TDataSet);
    procedure DtsOlcumDetayStateChange(Sender: TObject);
    procedure Nominal2OlculenMenuClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure GridOlcumDetayViewDEGERIGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure GridOlcumDetayViewDEGERIGetDisplayText(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AText: string);
    procedure GridOlcumDetayViewSAPMAGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure GridOlcumDetayViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure PageControlUstChange(Sender: TObject);
  private
    { Private declarations }
    procedure Konusu(KonuId:integer; Tablo1:TFDQuery);
    procedure Sorumlu(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
    procedure Lokasyon(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
    procedure Kaynak(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
  public
    { Public declarations }
    OperasyonId, Id, Cagiran, UrtReceteKltId : Integer;
    IslemOp : char;
  end;

var
  IsEmriPersonelZamanDlg: TIsEmriPersonelZamanDlg;

implementation

{$R *.dfm}

uses LocOnFly, UTablo, prjconst, FetaKurulusSiniflari, FetaClassExtensions, UAnaForm;

var
   OncekiPersonel:Integer;
   EkAlanOlustuCal, EkAlanOlustu, EkAlanOlustu2, IlkDefa : boolean;

procedure TIsEmriPersonelZamanDlg.Lokasyon(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim);
   if LokID>0 then begin
      Edit1.Tag := LokID;
      Edit1.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',LokID);
      Tablo1.Edit;
      Tablo1.FieldByName('LOKASYON').Value:=LokID;
   end;
end;

procedure TIsEmriPersonelZamanDlg.Nominal2OlculenMenuClick(Sender: TObject);
begin
   TabOlcumDetay.First;
   while not TabOlcumDetay.eof do begin
       if TabOlcumDetay.FieldByName('DEGERI').AsString='' then begin
          TabOlcumDetay.Edit;
          TabOlcumDetay.FieldByName('DEGERI').Value := TabOlcumDetay.FieldByName('NOMINAL').Value;
          TabOlcumDetay.Post;
       end;
       TabOlcumDetay.Next;
   end;
end;

procedure TIsEmriPersonelZamanDlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Lokasyon(EditLokasyon, TabUretimOperasyonPersonel);
end;

procedure TIsEmriPersonelZamanDlg.EditOlcumLokasyonPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Lokasyon(EditOlcumLokasyon, TabOlcum);
end;

procedure TIsEmriPersonelZamanDlg.Kaynak(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
var
  LokID:Integer;
begin
   LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Uretim_Kaynak);
   if LokID>0 then begin
      Edit1.Tag := LokID;
      Edit1.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',LokID);
      Tablo1.Edit;
      Tablo1.FieldByName('KAYNAK').Value:=LokID;
   end;
end;

procedure TIsEmriPersonelZamanDlg.cxButtonEdit2PropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
   Kaynak(EditKaynak, TabUretimOperasyonPersonel);
end;

procedure TIsEmriPersonelZamanDlg.EditOlcumKaynakPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Kaynak(EditOlcumKaynak, TabOlcum);
end;

procedure TIsEmriPersonelZamanDlg.DtsOlcumDetayStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsOlcumDetay, OlcumDetayYeni, OlcumDetaySil, OlcumDetayKaydet, OlcumDetayIptal);
end;

procedure TIsEmriPersonelZamanDlg.DtsOlcumStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsOlcum, OlcumEkleBtn, OlcumSilBtn, OlcumKaydetBtn, OlcumIptalBtn);
end;

procedure TIsEmriPersonelZamanDlg.Konusu(KonuId:integer; Tablo1:TFDQuery);
var
  LokID:Integer;
begin
   LokID := Tablo.LokasyonAra_IDGetir(KonuId);
   if LokID > 0 then begin
      Tablo1.Edit;
      Tablo1.FieldByName('KONUSU').Value := Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', LokID);;
   end;
end;

procedure TIsEmriPersonelZamanDlg.EditKonusuPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Konusu(Lokasyon_Uretim_Konu, TabUretimOperasyonPersonel);
end;

procedure TIsEmriPersonelZamanDlg.EditOlcumKonusuPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Konusu(Lokasyon_Uretim_OlcumKonu, TabOlcum);
end;

procedure TIsEmriPersonelZamanDlg.Sorumlu(Edit1:TcxButtonEdit; Tablo1:TFDQuery);
var
  RehID:integer;
begin
  RehID := Tablo.RehberAra_IDGetir(335, False, 33062010);
  if RehID>0 then begin
    Edit1.Tag := RehID;
    Edit1.Text := Tablo.AciklamaGetir('REHBER','FIRMA',RehID);
    Tablo1.Edit;
    Tablo1.FieldByName('PERSONEL').AsInteger := RehID;
  end;
end;

procedure TIsEmriPersonelZamanDlg.EditPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Sorumlu(EditPersonel, TabUretimOperasyonPersonel);
end;

procedure TIsEmriPersonelZamanDlg.EditOlcumSorumluPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
   Sorumlu(EditOlcumSorumlu, TabOlcum);
end;

procedure TIsEmriPersonelZamanDlg.FormActivate(Sender: TObject);
begin
   IlkDefa := True;
   PageControlUstChange(Self);
end;

procedure TIsEmriPersonelZamanDlg.FormCreate(Sender: TObject);
var Ad:string;
    yeniduzentTR : TFormatSettings;
  procedure SekmeIslem(Ops:Integer;Tab1:TcxTabSheet);
  begin
      Ad := Tablo.GENINI.ReadString(Ops, '');
      if Ad='' then
         Tab1.TabVisible := False
      else
         Tab1.Caption := Ad;
  end;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //Tablo.WizardTurkcelestir(WizardKontrol);

  SekmeIslem(Ops_EditIsEmriSekme1, TabSheetEkAlan111);
  SekmeIslem(Ops_EditIsEmriSekme2, TabSheetEkAlan222);


// Bölgesel Ayarlar

 (* yeniduzentTR := TFormatSettings.Create;
  yeniduzentTR.DecimalSeparator := '.';
  yeniduzentTR.ThousandSeparator := ',';
  //yeniduzentTR.CurrencyDecimals := 2;
  System.SysUtils.FormatSettings := yeniduzentTR;*)
end;

procedure TIsEmriPersonelZamanDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Tur : integer;
  ctrlPos : TPoint;
  clientPos : TPoint;
  Strin : String;
  ctrl  : TWinControl;
begin
  clientPos := Self.ScreenToClient(Mouse.CursorPos);
  ctrl := FindVCLWindow(Mouse.CursorPos);
  ctrlPos := ctrl.ScreenToClient(Mouse.CursorPos);
  if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('E')) then  begin   //Yeni Bileşen Ekle

      if Assigned(ctrl) then begin
         OutputDebugString(PChar(ctrl.Name));

         Tablo.AlanlarDlgBaslat('E',1,-1,abs(ctrlPos.X), abs(ctrlPos.Y), -1,FindComponent(ctrl.Name),TIsEmriPersonelZamanDlg(Self), DtsUretimOperasyonPersonel);
         Tablo.AlanOlustur(TIsEmriPersonelZamanDlg(Self), -1,DtsUretimOperasyonPersonel);
      end;
  end else if (Shift = [ssAlt,ssCtrl]) and (Key = Ord('D')) then begin//Bileşen Düzenle
      Tablo.AlanlarDlgBaslat('D',1,0, abs(ctrlPos.X), abs(ctrlPos.Y), 0, FindComponent(ctrl.Name),TIsEmriPersonelZamanDlg(Self), DtsUretimOperasyonPersonel);
      Tablo.AlanOlustur(TIsEmriPersonelZamanDlg(Self), -1,DtsUretimOperasyonPersonel);
  end;
end;

procedure TIsEmriPersonelZamanDlg.FormShow(Sender: TObject);
begin
   PageControlUst.ActivePageIndex := 0;
   EkAlanOlustuCal := False;
   EkAlanOlustu := False;
   EkAlanOlustu2:= False;
   Tablo.GridAyarRestore('IsEmriKaliteGridi', GridOlcumDetayView);

   TabloYenile(TabUretimOperasyonPersonel,[Id]);
   case IslemOp of
     'E': TabUretimOperasyonPersonel.Append;
     'D':begin
            EditPersonel.Text := TabUretimOperasyonPersonel.FieldByName('SORUMLUADI').AsString;
            EditLokasyon.Text := TabUretimOperasyonPersonel.FieldByName('LOKASYONADI').AsString;
            EditKaynak.Text := TabUretimOperasyonPersonel.FieldByName('KAYNAKADI').AsString;
         end;
   end;
   Height := 500;

end;

procedure TIsEmriPersonelZamanDlg.GridOlcumDetayViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridOlcumDetay;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridOlcumDetayView;
  AnaForm.pmGridStil.Tags.Values[GridOlcumDetay.Name]:='IsEmriKaliteGridi';
end;

procedure TIsEmriPersonelZamanDlg.GridOlcumDetayViewDEGERIGetDisplayText(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AText: string);
//var
//  tmpAdo : TFDQuery;
begin
   // AText := AText;
end;

procedure TIsEmriPersonelZamanDlg.GridOlcumDetayViewDEGERIGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
var
  Paramlar: TArrayOfString;
  Degerler: TArrayOfVariant;
begin
  //SetLength(Paramlar, 2);
  //SetLength(Degerler, 2);
  //Paramlar[0] := ':PRehID';
  //Paramlar[1] := ':PSubeID';
  //Degerler[0] := RehberID;
  //Degerler[1] := SubeID;
  tablo.RepositorydenPropertyAl(AProperties, Sender{BTableItem}, Paramlar, Degerler);
end;

procedure TIsEmriPersonelZamanDlg.GridOlcumDetayViewSAPMAGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  tablo.RepositorydenPropertyAl(AProperties, Sender{BTableItem}, [], []);
end;

procedure TIsEmriPersonelZamanDlg.IptalTusClick(Sender: TObject);
begin
   TabUretimOperasyonPersonel.Cancel;
end;

procedure TIsEmriPersonelZamanDlg.KaydetTusClick(Sender: TObject);
//var Bitis
begin
   //önce bakalım başlama bitiş 24 saatten fazla olmamalı
   if HoursBetween(DateBITIS.Date - TimeMOLA.Time,
                         DateBASLA.Date) > 23 then begin

      ShowMessage('24 saat veya daha fazla iş süresi geçersizdir!');
      exit;
   end;


   if TabUretimOperasyonPersonel.State in [dsEdit, dsInsert] then begin
      TabUretimOperasyonPersonel.Post;
      if OncekiPersonel <> TabUretimOperasyonPersonel.FieldByName('PERSONEL').AsInteger then
         Tablo.UretimPersoneliYayinIslemleri('URETIMOPERASYONPERSONEL', Tabno_URETIMOPERASYONPERSONEL, TabUretimOperasyonPersonel.FieldByName('ID').AsInteger,
               OncekiPersonel, TabUretimOperasyonPersonel.FieldByName('PERSONEL').AsInteger, -38);
   end;
   Close;
end;

procedure TIsEmriPersonelZamanDlg.OlcumEkleBtnClick(Sender: TObject);
begin
   TabOlcum.Append;
end;

procedure TIsEmriPersonelZamanDlg.OlcumIptalBtnClick(Sender: TObject);
begin
   TabOlcum.Cancel;
end;

procedure TIsEmriPersonelZamanDlg.OlcumKaydetBtnClick(Sender: TObject);
begin
   TabOlcum.Post;
end;

procedure TIsEmriPersonelZamanDlg.OlcumSilBtnClick(Sender: TObject);
begin
     if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
       TabOlcum.Delete;
     end;
end;

procedure TIsEmriPersonelZamanDlg.PageControlUstChange(Sender: TObject);
   procedure Olustur(var EkOlustu : boolean; var EkEkr : TPanel); //  TcxTabSheet     TComponent
   var
    i:integer;
    component, MyClass: TComponent;
   begin
       IlkDefa := False;
       EkOlustu:=True;
       Tablo.AlanOlustur(TIsEmriPersonelZamanDlg(Self), -1, DtsUretimOperasyonPersonel);

 //AO 05.07.2025 kaldırıldı
      // MyClass := TComponent.Create(Self);
       try
             for i := 0 to TWinControl(EkEkr).ControlCount-1 do
                 if (FindComponent(TWinControl(EkEkr).Controls[i].Name).ClassType <> TcxLabel) and (FindComponent(TWinControl(EkEkr).Controls[i].Name).ClassType <> TcxDBLabel) then
                     TcxControl(TWinControl(EkEkr).Controls[i]).SetFocus;

       finally
        // MyClass.Free;
       end;
   end;
begin
 {
   case PageControlUst.ActivePageIndex of
   0 : if (IlkDefa)and(EkAlanOlustuCal=False) then
          Olustur(EkAlanOlustuCal, EkAlanlarCalisma);
   1 : begin
         TabloYenile(TabOlcum,[TabUretimOperasyonPersonel.FieldByName('ID').AsInteger]);
         PanelBaslik.Caption := #214'l'#231#252'm Say'#305's'#305' : ' + IntToStr(TabOlcum.RecordCount)
       end;
   2 : if (IlkDefa)and(EkAlanOlustu=False) then
       Olustur(EkAlanOlustu, TabSheetEkAlan1);
   3 : if (IlkDefa)and(EkAlanOlustu2=False) then
        Olustur(EkAlanOlustu2, TabSheetEkAlan2);
  end;
}
   if PageControlUst.ActivePage=TabSheetOlcum then begin
      TabloYenile(TabOlcum,[TabUretimOperasyonPersonel.FieldByName('ID').AsInteger]);
      PanelBaslik.Caption := #214'l'#231#252'm Say'#305's'#305' : ' + IntToStr(TabOlcum.RecordCount)
   end
   else if (PageControlUst.ActivePage = TabSheetCalisma)and(EkAlanOlustuCal=False)and(IlkDefa) then
       Olustur(EkAlanOlustuCal, EkAlanlarCalisma)
   else if (PageControlUst.ActivePage = TabSheetEkAlan111)and(EkAlanOlustu=False)and(IlkDefa) then
       Olustur(EkAlanOlustu, TabSheetEkAlan1)
   else if (PageControlUst.ActivePage = TabSheetEkAlan222)and(EkAlanOlustu2=False)and(IlkDefa) then
        Olustur(EkAlanOlustu2, TabSheetEkAlan2)

end;

procedure TIsEmriPersonelZamanDlg.TabOlcumAfterPost(DataSet: TDataSet);
begin
   if TabOlcumDetay.recordcount < 1 then begin
      if TabUretimOperasyonPersonel.FieldByName('YERID').AsString ='' then
         ShowMessage('Şablon Bulunamadı!')
      else begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into URETIMOLCUMDETAY(URETIMOLCUMID, KALITESABLONDETAYID,OLCUALETI,EKLEYEN) '+
         ' select '+TabOlcum.FieldByName('ID').AsString+', ID, OLCUALETI,'+Kullanan+' from KALITESABLONDETAY KSD where YER=20 and '+
         ' KSD.YERID='+TabUretimOperasyonPersonel.FieldByName('YERID').AsString+' order by ID ',[],[]);
         TabloYenile(TabOlcumDetay, [TabOlcum.FieldByName('ID').AsInteger]);
      end;
   end;
end;

procedure TIsEmriPersonelZamanDlg.TabOlcumAfterScroll(DataSet: TDataSet);
begin
   if TabOlcum.recordcount > 0 then begin

      EditOlcumSorumlu.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TabOlcum.FieldByName('PERSONEL').AsInteger);
      EditOlcumLokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA',TabOlcum.FieldByName('LOKASYON').AsInteger);
      EditOlcumKaynak.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA', TabOlcum.FieldByName('KAYNAK').AsInteger);
      TabloYenile(TabOlcumDetay, [TabOlcum.FieldByName('ID').AsInteger]);
     // GridOlcumDetayView.ApplyBestFit(nil);
   end;
end;

procedure TIsEmriPersonelZamanDlg.TabOlcumBeforeDelete(DataSet: TDataSet);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from URETIMOLCUMDETAY where URETIMOLCUMID='+TabOlcum.FieldByName('ID').AsString,[],[]);
end;

procedure TIsEmriPersonelZamanDlg.TabOlcumDetayBeforePost(DataSet: TDataSet);
var deg, nom, lalt, lust : extended;
    floatStr : string;
    function cevir(deger : string):extended;
    begin
       if FormatSettings.DecimalSeparator = ',' then
          result := StrToFloatDef(StringReplace(deger, '.', ',', []),0)
       else
          result := StrToFloatDef(StringReplace(deger, ',', '.',[]),0);
    end;
begin
   //
// Giriş 13 yani virgüllü değilse boş
   if TabOlcumdetay.FieldByName('DEGERI').AsString='' {or(TabOlcumdetay.FieldByName('DEGERI').AsFloat=0.0)} then begin
       TabOlcumdetay.FieldByName('SAPMA').AsString :='';   //Value := 0.0;
       TabOlcumdetay.FieldByName('ALARM').Value := 0;
   end
   else case TabOlcumdetay.FieldByName('GIRIS').AsInteger of
       1,4 : begin//yazı, combo
           TabOlcumdetay.FieldByName('DEGERI').AsString := Trim(TabOlcumdetay.FieldByName('DEGERI').AsString);
           if TabOlcumdetay.FieldByName('DEGERI').Value =  TabOlcumdetay.FieldByName('NOMINAL').Value then
              TabOlcumdetay.FieldByName('ALARM').Value := 1
           else
              TabOlcumdetay.FieldByName('ALARM').Value := 2;
       end;
       13:begin // currency
             deg := cevir(TabOlcumdetay.FieldByName('DEGERI').AsString);
             nom := cevir(TabOlcumdetay.FieldByName('NOMINAL').AsString);
             lalt:= cevir(TabOlcumdetay.FieldByName('LIMITALT').AsString);
             lust:= cevir(TabOlcumdetay.FieldByName('LIMITUST').AsString);
             floatStr := FloatToStrF(deg-nom, ffFixed,6, 2);
             TabOlcumdetay.FieldByName('SAPMA').AsString := StringReplace(floatStr , ',', '.',[]);
//             if ((TabOlcumdetay.FieldByName('DEGERI').Value) >=  (TabOlcumdetay.FieldByName('NOMINAL').Value-TabOlcumdetay.FieldByName('LIMITALT').Value)) and
//                ((TabOlcumdetay.FieldByName('DEGERI').Value) <=  (TabOlcumdetay.FieldByName('NOMINAL').Value+TabOlcumdetay.FieldByName('LIMITUST').Value)) then
             if ((deg) >=  (nom - lalt)) and
                ((deg) <=  (nom + lust)) then
                 TabOlcumdetay.FieldByName('ALARM').Value := 1
             else
                 TabOlcumdetay.FieldByName('ALARM').Value := 2
       end;
   end;
end;

procedure TIsEmriPersonelZamanDlg.TabOlcumNewRecord(DataSet: TDataSet);
begin
   TabOlcum.FieldByName('OPERASYONID').AsInteger := OperasyonId;
   TabOlcum.FieldByName('DURUM').AsInteger := 0;
   TabOlcum.FieldByName('BIRIM').AsInteger := 51;
   TabOlcum.FieldByName('OPERASYONPERSONELID').AsInteger := TabUretimOperasyonPersonel.FieldByName('ID').AsInteger;
   TabOlcum.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrhSaat;
   TabOlcum.FieldByName('EKLEYEN').AsString := Kullanan;
end;

procedure TIsEmriPersonelZamanDlg.TabUretimOperasyonPersonelBeforeEdit(DataSet: TDataSet);
begin
  OncekiPersonel := TabUretimOperasyonPersonel.FieldByName('PERSONEL').AsInteger;
end;

procedure TIsEmriPersonelZamanDlg.TabUretimOperasyonPersonelBeforePost(DataSet: TDataSet);
var bas, bit : string[10];
begin
   //Eğer başlama ve bitişin tarihleri baştaki tarihten farklı ise baştaki tarih atanmalıdır
   if FormatDateTime('dd/mm/yyyy', TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime) <> FormatDateTime('dd/mm/yyyy', TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime) then begin
      bas := FormatDateTime('hh:nn', TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime);
      bit := FormatDateTime('hh:nn', TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime);
      //bas := GridIsZamanView.DataController.Values[RecIdx, ColIdx];

      //TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime := TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime+StrToDateTime(bas);
      //TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime := TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime+StrToDateTime(bit);
   end;

   if TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime - TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime>0.001 then
      TabUretimOperasyonPersonel.FieldByName('DURUM').AsInteger := 9;
end;

procedure TIsEmriPersonelZamanDlg.TabUretimOperasyonPersonelNewRecord(DataSet: TDataSet);
begin
   TabUretimOperasyonPersonel.FieldByName('OPERASYONID').AsInteger := OperasyonId;
   //TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime := Tablo.GENINI.BugunTrh;
 //  TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime := TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime ;
 //  TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime := TabUretimOperasyonPersonel.FieldByName('TARIH').AsDateTime ;
   TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime := Tablo.GENINI.BugunTrhSaat;
   TabUretimOperasyonPersonel.FieldByName('BITIS').AsDateTime := TabUretimOperasyonPersonel.FieldByName('BASLAMA').AsDateTime;
   TabUretimOperasyonPersonel.FieldByName('MOLA').AsDateTime := StrToDateTime('30'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+'1899 00:00');
   TabUretimOperasyonPersonel.FieldByName('DURUM').AsInteger := 0;
   TabUretimOperasyonPersonel.FieldByName('YER').AsInteger := Cagiran;
   TabUretimOperasyonPersonel.FieldByName('YERID').AsInteger := UrtReceteKltId;
   TabUretimOperasyonPersonel.FieldByName('EKLEYEN').AsString := Kullanan;
   OncekiPersonel := 0;
end;


end.



