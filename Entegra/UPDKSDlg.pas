﻿unit UPDKSDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DateUtils,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxPC,
  cxControls, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, ComCtrls, ToolWin,
  cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls,
  cxCheckBox, cxDropDownEdit, cxCalendar,UGentegreFrameYonetimi,ComObj,
  cxTextEdit, cxMaskEdit, cxContainer, cxLabel, StdCtrls, FireDAC.Comp.Client, cxTimeEdit,
  cxButtonEdit, cxImageComboBox, Menus, frxClass,UTablo,
  frxDBSet, cxGridBandedTableView, cxGridDBBandedTableView,
  cxLookAndFeelPainters, cxRadioGroup, cxGroupBox, cxDBEdit, dxSkinLiquidSky, cxPCdxBarPopupMenu, cxLookAndFeels, cxNavigator, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
    TSaat = record
    KolonIndex: Integer;
    Baslangic: TDateTime;
    Bitis: TDateTime;
    Sure: Integer;
    end;

    TPDKSDlg = class(TForm , IPopupDialog)
    PageControlPDKS: TcxPageControl;
    TabSheetGenel: TcxTabSheet;
    TabSheetGrafik: TcxTabSheet;
    PDKSListeTV: TcxGridDBTableView;
    PDKSListeLevel1: TcxGridLevel;
    PDKSListe: TcxGrid;
    ToolBar9: TToolBar;
    ToolButton1: TToolButton;
    BtnKapat: TToolButton;
    Panel1: TPanel;
    TarihBas: TcxDateEdit;
    TarihBit: TcxDateEdit;
    TabPDKS: TFDQuery;
    dtsTabPDKS: TDataSource;
    PDKSListeTVGIRIS: TcxGridDBColumn;
    PDKSListeTVCIKIS: TcxGridDBColumn;
    PDKSListeTVSUBEID: TcxGridDBColumn;
    PDKSListeTVGIRISSAAT: TcxGridDBColumn;
    PDKSListeTVCIKISSAAT: TcxGridDBColumn;
    PDKSListeTVFIRMA: TcxGridDBColumn;
    PDKSListeTVVARGIRISCIKIS: TcxGridDBColumn;
    PDKSListeTVGUNADI: TcxGridDBColumn;
    ComboPersonel: TcxButtonEdit;
    cxLabel3: TcxLabel;
    PDKSListeTVGIRFARK: TcxGridDBColumn;
    PDKSListeTVCIKFARK: TcxGridDBColumn;
    PDKSListeTVCALFARK: TcxGridDBColumn;
    PDKSListeTVCALSURE: TcxGridDBColumn;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    YaziciYaz: TToolButton;
    frxTabPDKS: TfrxDBDataset;
    GridPDKSGrafik: TcxGrid;
    GridPDKSGrafikBandedTV: TcxGridDBBandedTableView;
    cxSaatKolonAdSoyad: TcxGridDBBandedColumn;
    cxSaatKolonGiris: TcxGridDBBandedColumn;
    cxSaatKolonCikis: TcxGridDBBandedColumn;
    cxSaatKolon7: TcxGridDBBandedColumn;
    cxSaatKolon8: TcxGridDBBandedColumn;
    cxSaatKolon9: TcxGridDBBandedColumn;
    cxSaatKolon10: TcxGridDBBandedColumn;
    cxSaatKolon11: TcxGridDBBandedColumn;
    cxSaatKolon12: TcxGridDBBandedColumn;
    cxSaatKolon13: TcxGridDBBandedColumn;
    cxSaatKolon14: TcxGridDBBandedColumn;
    cxSaatKolon15: TcxGridDBBandedColumn;
    cxSaatKolon16: TcxGridDBBandedColumn;
    cxSaatKolon17: TcxGridDBBandedColumn;
    cxSaatKolon18: TcxGridDBBandedColumn;
    cxSaatKolon19: TcxGridDBBandedColumn;
    cxSaatKolon20: TcxGridDBBandedColumn;
    cxSaatKolon21: TcxGridDBBandedColumn;
    cxSaatKolon22: TcxGridDBBandedColumn;
    cxGridLevel1: TcxGridLevel;
    cxSaatKolonGUNADI: TcxGridDBBandedColumn;
    cxSaatKolonTARIH: TcxGridDBBandedColumn;
    GroupBox1: TGroupBox;
    RbGirisGec: TcxRadioButton;
    RbGirisErken: TcxRadioButton;
    RbGirisTumu: TcxRadioButton;
    GroupBox2: TGroupBox;
    RbCikisTumu: TcxRadioButton;
    RbCikisErken: TcxRadioButton;
    RbCikisGec: TcxRadioButton;
    CbCikisNull: TcxCheckBox;
    PmSagClick: TPopupMenu;
    GrupA1: TMenuItem;
    GrupKapa1: TMenuItem;
    LblSube: TcxLabel;
    ComboSube: TcxImageComboBox;
    ToolBarCihazYoksa: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    ToolButton3: TToolButton;
    PmYeniEkle: TPopupMenu;
    MenuItemTekEkle: TMenuItem;
    MenuItemTumEkle: TMenuItem;
    PDKSListeTVID: TcxGridDBColumn;
    N4: TMenuItem;
    HepsiniSe1: TMenuItem;
    mnKaldr1: TMenuItem;
    SeimiTersevir1: TMenuItem;
    btnGiris: TToolButton;
    btnCikis: TToolButton;
    cxLabel1: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    PDKSListeTVDURUM: TcxGridDBColumn;
    ComboDurum: TcxImageComboBox;
    cxLabel2: TcxLabel;
    PDKSListeTVREHBERID: TcxGridDBColumn;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    TOPLAM: TFDQuery;
    DtsTOPLAM: TDataSource;
    TOPLAMDURUM: TWordField;
    TOPLAMSAYI: TIntegerField;
    GiriSaatDzenle1: TMenuItem;
    kSaatDzenle1: TMenuItem;
    DurumDegisMenu: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    Panel2: TPanel;



    function EkranAdiAl: string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure BtnKapatClick(Sender: TObject);
    procedure ComboKabuledenPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure YenileClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure cxSaatKolon7CustomDrawCell(Sender: TcxCustomGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo;
      var ADone: Boolean);
    procedure cxSaatKolon9GetCellHint(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord;
      ACellViewInfo: TcxGridTableDataCellViewInfo;
      const AMousePos: TPoint; var AHintText: TCaption;
      var AIsHintMultiLine: Boolean; var AHintTextRect: TRect);
    procedure PDKSListeTVCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridPDKSGrafikBandedTVCanFocusRecord
      (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure TarihBasPropertiesCloseUp(Sender: TObject);
    procedure GrupKapa1Click(Sender: TObject);
    procedure MenuItemTekEkleClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure PDKSListeTVCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure HepsiniSe1Click(Sender: TObject);
    procedure btnGirisClick(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure ComboDurumPropertiesEditValueChanged(Sender: TObject);
    procedure TabPDKSAfterOpen(DataSet: TDataSet);
    procedure PmSagClickPopup(Sender: TObject);
  private
    Saatler: array of TSaat;
    function KolonIndex2Saat(Index: Integer): TSaat;
    procedure SaatlerDiziCalistir;
    procedure GirisCikisSaatGir(Tags: integer);
    procedure IlkGirisYenileClick(Sender: Tobject);
    procedure TekKayitYenileClick(Sender: Tobject);
    { Private declarations }
  public
    { Public declarations }
    RehberId, Cagiran: integer;
    VardiyaTuru: string;

  end;

var
  PDKSDlg: TPDKSDlg;
  EkranAdi: string;
  Secilenindex, Secilenler: TStringList;

implementation

Uses
   PrjConst, UFastRap, URaporAraclari, UAnaForm, FetaClassExtensions,FetaClassExtensionsConsts, UGenelAnaSekmeFrame, FetaKurulusSiniflari, UGirisKutusuEx;
{$R *.dfm}
var
  KartNoKontrol : boolean;
procedure TPDKSDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  if dtsTabPDKS.State in [dsInsert, dsEdit] then
    TabPDKS.Post;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdi, s); // EkranAdi
end;

procedure TPDKSDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxTabPDKS);
end;

function TPDKSDlg.EkranAdiAl: string;
begin
  Result := 'PDKSDlg';
end;

procedure TPDKSDlg.btnGirisClick(Sender: TObject);
begin
  if PDKSListeTV.DataController.GetSelectedCount <> 0 then
      GirisCikisSaatGir(TToolButton(Sender).Tag);
end;

procedure TPDKSDlg.MenuClick(Sender: TObject);
begin
  if PDKSListeTV.DataController.GetSelectedCount <> 0 then
      GirisCikisSaatGir(TMenuItem(Sender).Tag);
end;

procedure TPDKSDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;

procedure TPDKSDlg.ComboDurumPropertiesEditValueChanged(Sender: TObject);
Var
 i,PERSID,Recordindex:Integer;
begin
  if ComboDurum.EditValue<>0 then begin
     if PDKSListeTV.DataController.GetSelectedCount<>0 then begin
        for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
          Recordindex:=PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          PERSID:=PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS Set DURUM='''+ComboDurum.EditValue+''' '+
          ' WHERE ID='+IntToStr(PERSID)+' ',[],[]);
        end;
        ComboDurum.ItemIndex:=0;
        YenileClick(sender);
     end else begin
       YenileClick(sender);
     end;
  end else begin
    YenileClick(sender);
  end;
end;

procedure TPDKSDlg.ComboKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  if AButtonIndex = 0 then
  begin
    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then
    begin
      ComboPersonel.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      ComboPersonel.Tag := ID;
    end;
  end
  else if AButtonIndex = 1 then
  begin
    ComboPersonel.Text := '';
    ComboPersonel.Tag := -99;
  end;
  YenileClick(Sender);
end;

function TPDKSDlg.KolonIndex2Saat(Index: Integer): TSaat;
var
  I: Integer;
begin
  for I := 0 to Length(Saatler) - 1 do
    if Saatler[i].KolonIndex = Index then
    begin
      Exit(Saatler[i]);
    end;
end;

procedure TPDKSDlg.MenuItemTekEkleClick(Sender: TObject);
var trh:TDateTime;
begin
 case TMenuItem(Sender).Tag of
    2:begin
         if ComboPersonel.Text<>'' then begin
            trh := TarihBas.Date;
            while trh<=TarihBit.Date do begin
              Tablo.PDKSEkle(True,Trh,0,ComboPersonel.Tag, KartNoKontrol);
              Trh := Trh+1;
            end;
           //TekKayitYenileClick(sender);
           YenileClick(Sender);
         end else begin
           ShowMessage('Personel Seçiniz !');
         end;
    end;
    3:begin
       Tablo.PDKSEkle(True,TarihBas.Date,0,0, KartNoKontrol);
       YenileClick(Sender);
     end;
 end;
 YenileClick(Sender);
end;

procedure TPDKSDlg.PDKSListeTVCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := PDKSListe;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := PDKSListeTV;
  AnaForm.pmGridStil.Tags.Values[PDKSListe.Name] := 'PDKSGridi';
end;

procedure TPDKSDlg.PDKSListeTVCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if ACellViewInfo.Item = PDKSListeTVGIRISSAAT then begin
    GirisCikisSaatGir(53);
  end else if ACellViewInfo.Item = PDKSListeTVCIKISSAAT then begin
    GirisCikisSaatGir(54);
  end;
end;

procedure TPDKSDlg.PmSagClickPopup(Sender: TObject);
begin
  MenuItemTekEkle.Visible := (TarihBas.Date<=Tablo.GENINI.BugunTrh)and(TarihBas.Date<=Tablo.GENINI.BugunTrh);
  MenuItemTumEkle.Visible := MenuItemTekEkle.Visible
end;

Procedure TPDKSDlg.GirisCikisSaatGir(Tags:integer);
var
  i,PERSID,Recordindex : integer;
  Saat,Tarih ,GirisCikisSaat  : variant;
begin
    case Tags of
     1..20:begin     //Çoklu Seçimli olacak
          for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
             Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID := PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set DURUM = '+IntToStr(Tags)+' Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
          YenileClick(Self);
      end;
      53:begin
          //Çoklu Seçimli olacak
          Saat:='09:00:00';
          if TGirisKutusuEx.BilgiAlEx('Yeni bilgi girişi.', TGirdiDenetimleri.Create.DateTimePicker('Giriş Saati Gir.', @Saat,dtkTime)) <> mrOk then
             Abort;

          for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
             GirisCikisSaat:= Saat;
             Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID := PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
             Tarih  := FormatDateTime('yyyy-mm-dd 00:00:00',StrToDateTime(PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVGIRIS.Index]));
             GirisCikisSaat := FormatDateTime('yyyy-mm-dd hh:nn:ss',VarToDateTime(Tarih)+StrToFloat(vartoStr(GirisCikisSaat)));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set DURUM = 1 , GIRIS ='''+vartoStr(GirisCikisSaat)+''' Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
          YenileClick(Self);
      end;
      54:begin
         Saat:='18:00:00';
         if TGirisKutusuEx.BilgiAlEx('Yeni bilgi girişi.', TGirdiDenetimleri.Create.DateTimePicker('Çıkış Saati Gir.', @Saat,dtkTime)) <> mrOk then
          Abort;

          for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
             GirisCikisSaat:= Saat;
             Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID :=PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
             Tarih  := FormatDateTime('yyyy-mm-dd 00:00:00',StrToDateTime(PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVGIRIS.Index]));
             GirisCikisSaat := FormatDateTime('yyyy-mm-dd hh:nn:ss',VarToDateTime(Tarih)+StrToFloat(vartoStr(GirisCikisSaat)));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set CIKIS ='''+vartoStr(GirisCikisSaat)+''' Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
         YenileClick(Self);
      end;
    end;
end;

procedure TPDKSDlg.SaatlerDiziCalistir;
begin
  SetLength(Saatler, 17);

  Saatler[0].KolonIndex := cxSaatKolon7.Index;
  Saatler[0].Baslangic := StrToTime('07:00');
  Saatler[0].Bitis := StrToTime('07:59:59');
  Saatler[0].Sure := 60;

  Saatler[1].KolonIndex := cxSaatKolon8.Index;
  Saatler[1].Baslangic := StrToTime('08:00');
  Saatler[1].Bitis := StrToTime('08:59:59');
  Saatler[1].Sure := 60;

  Saatler[2].KolonIndex := cxSaatKolon9.Index;
  Saatler[2].Baslangic := StrToTime('09:00');
  Saatler[2].Bitis := StrToTime('09:59:59');
  Saatler[2].Sure := 60;

  Saatler[3].KolonIndex := cxSaatKolon10.Index;
  Saatler[3].Baslangic := StrToTime('10:00');
  Saatler[3].Bitis := StrToTime('10:59:59');
  Saatler[3].Sure := 60;

  Saatler[4].KolonIndex := cxSaatKolon11.Index;
  Saatler[4].Baslangic := StrToTime('11:00');
  Saatler[4].Bitis := StrToTime('11:59:59');
  Saatler[4].Sure := 60;

  Saatler[5].KolonIndex := cxSaatKolon12.Index;
  Saatler[5].Baslangic := StrToTime('12:00');
  Saatler[5].Bitis := StrToTime('12:59:59');
  Saatler[5].Sure := 60;

  Saatler[6].KolonIndex := cxSaatKolon13.Index;
  Saatler[6].Baslangic := StrToTime('13:00');
  Saatler[6].Bitis := StrToTime('13:59:59');
  Saatler[6].Sure := 60;

  Saatler[7].KolonIndex := cxSaatKolon14.Index;
  Saatler[7].Baslangic := StrToTime('14:00');
  Saatler[7].Bitis := StrToTime('14:59:59');
  Saatler[7].Sure := 60;

  Saatler[8].KolonIndex := cxSaatKolon15.Index;
  Saatler[8].Baslangic := StrToTime('15:00');
  Saatler[8].Bitis := StrToTime('15:59:59');
  Saatler[8].Sure := 60;

  Saatler[9].KolonIndex := cxSaatKolon16.Index;
  Saatler[9].Baslangic := StrToTime('16:00');
  Saatler[9].Bitis := StrToTime('16:59:59');
  Saatler[9].Sure := 60;

  Saatler[10].KolonIndex := cxSaatKolon17.Index;
  Saatler[10].Baslangic := StrToTime('17:00');
  Saatler[10].Bitis := StrToTime('17:59:59');
  Saatler[10].Sure := 60;

  Saatler[11].KolonIndex := cxSaatKolon18.Index;
  Saatler[11].Baslangic := StrToTime('18:00');
  Saatler[11].Bitis := StrToTime('18:59:59');
  Saatler[11].Sure := 60;

  Saatler[12].KolonIndex := cxSaatKolon19.Index;
  Saatler[12].Baslangic := StrToTime('19:00');
  Saatler[12].Bitis := StrToTime('19:59:59');
  Saatler[12].Sure := 60;

  Saatler[13].KolonIndex := cxSaatKolon20.Index;
  Saatler[13].Baslangic := StrToTime('20:00');
  Saatler[13].Bitis := StrToTime('20:59:59');
  Saatler[13].Sure := 60;

  Saatler[14].KolonIndex := cxSaatKolon21.Index;
  Saatler[14].Baslangic := StrToTime('21:00');
  Saatler[14].Bitis := StrToTime('21:59:59');
  Saatler[14].Sure := 60;

  Saatler[15].KolonIndex := cxSaatKolon22.Index;
  Saatler[15].Baslangic := StrToTime('22:00');
  Saatler[15].Bitis := StrToTime('22:59:59');
  Saatler[15].Sure := 60;
end;
procedure TPDKSDlg.SilTusClick(Sender: TObject);
var
  i,Recordindex,PERSID:integer;
begin
//Silme olayını yap
  if Application.MessageBox('Seçili satırlar silinsin mi ?',PChar(Uyari),MB_YESNO) = mrYes then begin

    for I := 0 to PDKSListeTV.DataController.GetSelectedCount - 1 do begin
      Recordindex := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
      PERSID :=PDKSListeTV.DataController.Values[Recordindex,PDKSListeTVID.Index];
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from PERS_PDKS Where ID ='+IntToStr(PERSID)+' ',[],[]);
    end;
    YenileClick(Sender);
  end;
end;

procedure TPDKSDlg.TabPDKSAfterOpen(DataSet: TDataSet);
begin
   PDKSListeTV.ApplyBestFit(nil);
end;

procedure TPDKSDlg.TarihBasPropertiesCloseUp(Sender: TObject);
begin
  TarihBit.Date := TarihBas.Date;
  YenileClick(Sender);
end;

procedure TPDKSDlg.GridPDKSGrafikBandedTVCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
//  AnaForm.cxGridPopupMenu1.Grid := GridPDKSGrafik;
//  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridPDKSGrafikBandedTV;
//  AnaForm.pmGridStil.Tags.Values[GridPDKSGrafik.Name] := 'PDKSGrafikGridi';
end;

procedure TPDKSDlg.GrupKapa1Click(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0:PDKSListeTV.DataController.Groups.FullCollapse;
    1:PDKSListeTV.DataController.Groups.FullExpand;
  end;
end;

procedure TPDKSDlg.HepsiniSe1Click(Sender: TObject);
var
  srid: string;
  i, j, Rekortindeks, CaountSay: integer;
begin
  case TMenuItem(Sender).Tag of
    5:begin
      PDKSListeTV.Controller.SelectAll;
    end;
    6:begin
      PDKSListeTV.Controller.ClearSelection;
    end;
    7:begin

      Secilenindex := TStringList.Create;
      Secilenler := TStringList.Create;
      if PDKSListeTV.Controller.SelectedRecordCount > 0 then begin
        Secilenindex.Clear;
        Secilenler.Clear;
        for I := 0 to PDKSListeTV.Controller.SelectedRecordCount - 1 do
        Begin
          Rekortindeks := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
          Secilenler.Add(IntToStr(i+PDKSListeTV.DataController.Values[Rekortindeks,PDKSListeTVID.Index]));
        End;

        PDKSListeTV.Controller.SelectAll;
        CaountSay := PDKSListeTV.Controller.SelectedRecordCount;
        for I := 0 to CaountSay - 1 do
        begin
          Rekortindeks := PDKSListeTV.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
            srid := IntToStr(i+PDKSListeTV.DataController.Values[Rekortindeks,PDKSListeTVID.Index]);
          for j := 0 to Secilenler.Count - 1 do begin
            if srid = Secilenler.Strings[j] then begin
              Secilenindex.Add(IntToStr(Rekortindeks));
            end;
          end;
        end;
        for I := 0 to Secilenindex.Count - 1 do begin
          PDKSListeTV.ViewData.Records[StrToInt(Secilenindex.Strings[i])].Selected := False;
        end;
      end;
      Secilenindex.Free;
      Secilenler.Free;
    end;
  end;

end;

procedure TPDKSDlg.cxSaatKolon7CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  r: TRect;
  c: Integer;
  giris: TDateTime;
  cikis: TDateTime;
  buKolonSaat: TSaat;
  girisFark: Integer;
  cikisFark: Integer;
  sol: Integer;
  sag: Integer;
  kolonOran: Double;
  DeneKolBas, DeneGiris, DeneCikis: string;
begin
  c := ACanvas.Brush.Color;
  ACanvas.FillRect(AViewInfo.ClientBounds, c);
  ADone := True;
  if VarIsNull(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonCikis.Index]) then
  begin
    if DayOfTheWeek(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonGiris.Index]) = 7 then
    begin
      r.Left := AViewInfo.ClientBounds.Left;
      r.Right := AViewInfo.ClientBounds.Right;
      r.Top := AViewInfo.ClientBounds.Top + 2;
      r.Bottom := AViewInfo.ClientBounds.Bottom - 2;
      ACanvas.FillRect(r, clBtnFace);
      ACanvas.Brush.Color := c;
    end;
    Exit;
  end;
  giris := Frac(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonGiris.Index]);
  cikis := Frac(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonCikis.Index]);
  buKolonSaat := KolonIndex2Saat(AViewInfo.Item.Index);
  sag := AViewInfo.ClientBounds.Left;
  sol := AViewInfo.ClientBounds.Left;
  kolonOran := (AViewInfo.ClientBounds.Right - AViewInfo.ClientBounds.Left) / buKolonSaat.Sure;
  if (giris >= buKolonSaat.Baslangic) then
  begin
    if (giris <= buKolonSaat.Bitis) then
    begin
      if cikis >= buKolonSaat.Baslangic then
      begin
        if cikis <= buKolonSaat.Bitis then
        begin
          // giriş çıkış saatleri bizim kolon içerisinde olduğunu belirtiyor
          girisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, giris));
          cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
          sol := AViewInfo.ClientBounds.Left + Trunc(girisFark * kolonOran);
          sag := AViewInfo.ClientBounds.Left + Trunc(cikisFark * kolonOran);
        end
        else
        begin
          // yani çıkış saati bizim bitiş saatinden sonra
          girisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, giris));
          sol := AViewInfo.ClientBounds.Left + Trunc(girisFark * kolonOran);
          sag := AViewInfo.ClientBounds.Right;
        end;
      end
      else
      begin
        // bu demek oluyor ki bu istenmeyen bir durum
      end;
    end
    else
    begin
      // bu blok çizilmeyecek çünkü bizim bloğu kapsamıyor!
      sol := AViewInfo.ClientBounds.Left;
      sag := sol;
    end;
  end
  else
  begin
    if giris { 09.03 } <= buKolonSaat.Bitis { 17.59 } then
    begin
      if cikis { 13.10 } <= buKolonSaat.Bitis { 17.59 } then
      begin
        if cikis { 13.10 } >= buKolonSaat.Baslangic { 10:00 } then
        begin
          // giriş çıkış saatleri bizim kolon içerisinde olduğunu belirtiyor
          cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
          sol := AViewInfo.ClientBounds.Left;
          sag := AViewInfo.ClientBounds.Left + Trunc(cikisFark * kolonOran);
        end
        else
        begin
          // istenmeyen durum
        end;
      end
      else
      begin
        sag := AViewInfo.ClientBounds.Right;
        sol := AViewInfo.ClientBounds.Left;
      end;
    end
    else
    begin

    end;
  end;

  r.Left := sol;
  r.Right := sag;
  r.Top := AViewInfo.ClientBounds.Top + 2;
  r.Bottom := AViewInfo.ClientBounds.Bottom - 2;
  ACanvas.FillRect(r, clMenuHighlight);
  ACanvas.Brush.Color := c;

  DeneKolBas := DateTimeToStr(buKolonSaat.Baslangic);

  /// ////////////////////////////İzinlileri boya
  {
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:='select * from PERS_IZIN WHERE PERKOD=:A0 and BASTAR=:A1 and isnull(NOTU,'''') <> ''Pazar Tatili.'' and IZINTUR in(''ÜCRETLİ SAAT İZNİ'',''ÜCRETSİZ SAAT İZNİ'')  order by BASSAAT';
    Tablo.Query1.Params[0].Value:=AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonPerkod.Index];
    Tablo.Query1.Params[1].Value:=DateToStr(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonGiris.Index]);
    Tablo.Query1.Open;

    Tablo.Query1.First;
    while not Tablo.Query1.Eof do begin
    if DateToStr(Tablo.Query1.FieldByName('BASTAR').AsDateTime)=DateToStr(AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonGiris.Index]) then begin

    if Tablo.Query1.FieldByName('IZINTUR').AsString='ÜCRETLİ SAAT İZNİ' then begin
    giris := Frac(Tablo.Query1.FieldByName('BASSAAT').AsDateTime);
    cikis := Frac(Tablo.Query1.FieldByName('BITSAAT').AsDateTime);
    DeneGiris:=DateTimeToStr(giris);
    DeneCikis:=DateTimeToStr(cikis);
    if ( giris >= buKolonSaat.Baslangic ) then begin
    if (giris <= buKolonSaat.Bitis) then begin
    if cikis >= buKolonSaat.Baslangic then begin
    if cikis <= buKolonSaat.Bitis then begin
    //Aynı hücrede başlayıp bitenler için
    girisFark := Trunc( MinuteSpan(buKolonSaat.Baslangic,giris));
    cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
    sol := AViewInfo.ClientBounds.Left + Trunc( girisFark * kolonOran );
    sag := AViewInfo.ClientBounds.Left + Trunc( cikisFark * kolonOran );
    end else
    begin
    //Bi sonraki hücrede bitenler için girer.
    girisFark := Trunc( MinuteSpan(buKolonSaat.Baslangic,giris));
    sol := AViewInfo.ClientBounds.Left + Trunc( girisFark * kolonOran );
    sag := AViewInfo.ClientBounds.Right;
    end;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clGreen);
    ACanvas.Brush.Color := c;
    end;
    end;
    end else
    begin }
  // if giris {09.03} <= buKolonSaat.Bitis {17.59} then begin
  // if cikis {13.10} <= buKolonSaat.Bitis {17.59} then begin
  // if cikis {13.10} >= buKolonSaat.Baslangic {10:00} then begin
  { giriş çıkış saatleri bizim kolon içerisinde olduğunu belirtiyor
    cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
    sol := AViewInfo.ClientBounds.left + Trunc( cikisFark * kolonOran );
    sag := AViewInfo.ClientBounds.left;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clGreen);
    ACanvas.Brush.Color := c;
    end else begin
    // istenmeyen durum
    end;
    end else
    begin
    sol := AViewInfo.ClientBounds.left;
    sag := AViewInfo.ClientBounds.right;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clGreen);
    ACanvas.Brush.Color := c;
    end;
    end;
    end;


    end else if Tablo.Query1.FieldByName('IZINTUR').AsString='ÜCRETSİZ SAAT İZNİ' then begin

    giris := Frac(Tablo.Query1.FieldByName('BASSAAT').AsDateTime);
    cikis := Frac(Tablo.Query1.FieldByName('BITSAAT').AsDateTime);
    if ( giris >= buKolonSaat.Baslangic ) then begin
    if (giris <= buKolonSaat.Bitis) then begin
    if cikis >= buKolonSaat.Baslangic then begin
    if cikis <= buKolonSaat.Bitis then begin
    //Aynı hücrede başlayıp bitenler için
    girisFark := Trunc( MinuteSpan(buKolonSaat.Baslangic,giris));
    cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
    sol := AViewInfo.ClientBounds.Left + Trunc( girisFark * kolonOran );
    sag := AViewInfo.ClientBounds.Left + Trunc( cikisFark * kolonOran );
    end else
    begin
    //Bi sonraki hücrede bitenler için girer.
    girisFark := Trunc( MinuteSpan(buKolonSaat.Baslangic,giris));
    sol := AViewInfo.ClientBounds.Left + Trunc( girisFark * kolonOran );
    sag := AViewInfo.ClientBounds.Right;
    end;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clYellow);
    ACanvas.Brush.Color := c;
    end;
    end ;
    end else
    begin }
  // if giris {09.03} <= buKolonSaat.Bitis {17.59} then begin
  // if cikis {13.10} <= buKolonSaat.Bitis {17.59} then begin
  // if cikis {13.10} >= buKolonSaat.Baslangic {10:00} then begin
  // giriş çıkış saatleri bizim kolon içerisinde olduğunu belirtiyor
  { cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
    sol := AViewInfo.ClientBounds.left + Trunc( cikisFark * kolonOran );
    sag := AViewInfo.ClientBounds.left;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clYellow);
    ACanvas.Brush.Color := c;
    end else begin
    // istenmeyen durum
    end;

    end else begin
    sol := AViewInfo.ClientBounds.left;
    sag := AViewInfo.ClientBounds.right;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clYellow);
    ACanvas.Brush.Color := c;
    end;
    end;
    end;

    end;
    end;
    Tablo.Query1.Next;
    end;
    }
  /// ////////////////////////////İzinlileri boya

  { ///////////////////Geç kalınmış Girişleri Kırmızıya Boya

    if giris > AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonVardiyaGiris.Index] then begin
    if ( giris >= buKolonSaat.Baslangic ) then begin
    if (giris <= buKolonSaat.Bitis) then begin
    sol := AViewInfo.ClientBounds.Left ;
    sag := AViewInfo.ClientBounds.Left + Trunc( girisFark * kolonOran );
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clRed);
    ACanvas.Brush.Color := c;
    end else    begin
    if buKolonSaat.Baslangic >= AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonVardiyaGiris.Index] then begin
    sag := AViewInfo.ClientBounds.Right;
    sol := AViewInfo.ClientBounds.Left;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clRed);
    ACanvas.Brush.Color := c;
    end;

    end;
    end;
    end;
    ///////////////////Geç kalınmış Girişleri Kırmızıya Boya
    }
  /// ///////////////// Çıkışları kırmızı boya
  // if cikis < AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonVardiyaCikis.Index] then begin
  // if cikis {13.10} <= buKolonSaat.Bitis {17.59} then begin
  // if cikis {13.10} >= buKolonSaat.Baslangic {10:00} then begin
  // giriş çıkış saatleri bizim kolon içerisinde olduğunu belirtiyor
  { cikisFark := Trunc(MinuteSpan(buKolonSaat.Baslangic, cikis));
    sol := AViewInfo.ClientBounds.Left + Trunc(cikisFark * kolonOran ) ;
    sag := AViewInfo.ClientBounds.Right ;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clRed);
    ACanvas.Brush.Color := c;
    end else begin
    if buKolonSaat.Bitis <= AViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonVardiyaCikis.Index] then begin
    sag := AViewInfo.ClientBounds.Right;
    sol := AViewInfo.ClientBounds.Left;
    r.Left := sol;
    r.Right := sag;
    r.Top := AViewInfo.ClientBounds.Top+2;
    r.Bottom := AViewInfo.ClientBounds.Bottom-2;
    ACanvas.FillRect(r,clRed);
    ACanvas.Brush.Color := c;
    end;
    end;
    end;
    end;
    ///////////////////////Çıkışları kırmızı boya }
end;

procedure TPDKSDlg.cxSaatKolon9GetCellHint(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; ACellViewInfo: TcxGridTableDataCellViewInfo;
  const AMousePos: TPoint; var AHintText: TCaption; var AIsHintMultiLine: Boolean; var AHintTextRect: TRect);
begin
  if VarIsNull(ACellViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonCikis.Index]) then
    Exit;
  AHintText := 'Giriş ' + Copy(ACellViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonGiris.Index], 12, 5) + ' / Çıkış ' + Copy(ACellViewInfo.RecordViewInfo.GridRecord.Values[cxSaatKolonCikis.Index],  12, 5);

end;

procedure TPDKSDlg.FormCreate(Sender: TObject);
begin
  ToolBarCihazYoksa.Visible := not PDKSCihazVarmi;
  SaatlerDiziCalistir;
end;

procedure TPDKSDlg.FormShow(Sender: TObject);
var
  ra: string;
  aktifFrame: TGenelAnaSekmeFrame;
  i:smallint;
begin
  KartNoKontrol := Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_KartNoTakipTuru, False);
  if ComboPersonel.Text<>'' then
     TarihBas.Date := StrToDate(FormatdateTime('01'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh))
  else
     TarihBas.Date := Tablo.GENINI.BugunTrh;
  TarihBit.Date := Tablo.GENINI.BugunTrh;


  ComboSube.EditValue :=SubeId;
  LblSube.Visible:=SubeVarmi;
  ComboSube.Visible:=SubeVarmi;
  PDKSListeTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PDKSGridi',true,false,[gsoUseFilter],'PDKSGridi');
  GridPDKSGrafikBandedTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\PDKSGrafikGridi',true,false,[gsoUseFilter],'PDKSGrafikGridi');
  PageControlPDKS.ActivePage := TabSheetGenel;


  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.FrameBul(TGenelAnaSekmeFrame).Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);

  YaziciYaz.Caption   := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  {ComboDurum.Properties.Items:=Tablo.imgComboboxInit('SELECT DEGER,ANAHTAR FROM dbo.GENINI WHERE BOLUM=-2211 ORDER BY ANAHTAR').Items;
  ComboDurum.Properties.Items.Insert(0);
  ComboDurum.Properties.Items[0].Description:='';
  ComboDurum.Properties.Items[0].Value:=0;
  ComboDurum.ItemIndex:=0; }
  for i := 0 to Tablo.RepPDKSDurum.Properties.Items.Count-1 do
      PmSagClick.Items[7].ItemOperation(moAdd, Tablo.RepPDKSDurum.Properties.Items[i].Description, MenuClick,0,'',Tablo.RepPDKSDurum.Properties.Items[i].Value);

  if SubeVarmi then
     ComboSube.ItemIndex:=0;

  if (not TabPDKS.Active)or(TabPDKS.RecordCount=0) then
     YenileClick(Self);
end;

procedure TPDKSDlg.TekKayitYenileClick(Sender:Tobject);
var
  sql:String;
begin
{  sql:= 'SELECT' + #13#10 +
        'PP.ID,R.FIRMA,R.ID AS REHBERID,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.SUBEID,PP.DURUM,' + #13#10 +
        '(convert(varchar,PV.GIRIS,108) +'' / ''+convert(varchar,PV.CIKIS,108)) as VARGIRISCIKIS,' + #13#10 +
        'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.GIRIS),''00:00''),' + #13#10 +
        'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)),''00:00''),' + #13#10 +
        'CALFARK= CASE WHEN  charindex(''*'',dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)))=0 THEN' + #13#10 +
        'dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE ''00:00'' END,' + #13#10 +
        'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00'')' + #13#10 +
        'from PERS_PDKS PP' + #13#10 +
        'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID' + #13#10 +
        'left outer join PERS_VARDIYATANIM PV on' + #13#10 +
        'PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN' + #13#10 +
        'PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) Where AY = 0 and ' + #13#10 +
        'R.ID='''+VarToStr(ComboPersonel.Tag)+''' and ';
  Sql := Sql + ' AND (PP.GIRIS between CONVERT(DATETIME,''' + FormatDateTime('yyyy-mm-dd', TarihBas.Date) + ' 00:00:00'',102) ' +
      ' and CONVERT(DATETIME,''' + FormatDateTime('yyyy-mm-dd', TarihBit.Date)+ ' 23:59:59'',102))';      }
end;

procedure TPDKSDlg.IlkGirisYenileClick(Sender:Tobject);
var
  sql:String;
begin            {
  sql :=  'SELECT' + #13#10 +
          'PP.ID,R.FIRMA,R.ID AS REHBERID,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.SUBEID,PP.DURUM,' + #13#10 +
          '(convert(varchar,PV.GIRIS,108) +'' / ''+convert(varchar,PV.CIKIS,108)) as VARGIRISCIKIS,' + #13#10 +
          'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.GIRIS),''00:00''),' + #13#10 +
          'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)),''00:00''),' + #13#10 +
          'CALFARK= CASE WHEN  charindex(''*'',dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)))=0 THEN' + #13#10 +
          'dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE ''00:00'' END,' + #13#10 +
          'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00'')' + #13#10 +
          'from PERS_PDKS PP' + #13#10 +
          'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID' + #13#10 +
          'left outer join PERS_VARDIYATANIM PV on' + #13#10 +
          'PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN' + #13#10 +
          'PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) Where AY = 0 and PP.REHBERID <> 0 ' + #13#10 +
          'ORDER BY R.FIRMA,PP.GIRIS,PP.CIKIS ';
  TabPDKS.Close;
  TabPDKS.SQL.Text:=sql;
  TabPDKS.Open; }
end;

procedure TPDKSDlg.YenileClick(Sender: TObject);
var
  Sql1 : String;
begin
   case Cagiran of
    0:begin         ///RehAraDlgden çağırılıyor.
        {Caption := '    ' + Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:='SELECT FIRMA FROM REHBER WHERE ID='+inttostr(RehberId)+' ';
        Tablo.Query1.Open;
        ComboPersonel.Text:=Tablo.Query1.FieldByName('FIRMA').AsString;
        ComboPersonel.Tag:=RehberId;}
        //MenuItem2.Visible:=False;
        GridPDKSGrafikBandedTV.Bands[0].Width := 222;
        ComboPersonel.Enabled := False;
      end;
    1:Begin      ///Genel PDKS formudur.
       //MenuItem2.Visible:=True;
      End;
   end;

   Sql1 := 'SELECT' + #13#10 +
              'PP.ID,R.FIRMA,R.ID AS REHBERID,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.SUBEID,PP.DURUM,' + #13#10 +
              '(convert(varchar,PV.GIRIS,108) +'' / ''+convert(varchar,PV.CIKIS,108)) as VARGIRISCIKIS,' + #13#10 +
              'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.GIRIS),''00:00''),' + #13#10 +
              'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)),''00:00''),' + #13#10 +
              'CALFARK= CASE WHEN  charindex(''*'',dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)))=0 THEN' + #13#10 +
              'dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE ''00:00'' END,' + #13#10 +
              'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00''),' + #13#10 +
              'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00'')' + #13#10 +
              'from PERS_PDKS PP' + #13#10 +
              'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID' + #13#10 +
              'left outer join PERS_VARDIYATANIM PV on' + #13#10 +
              'PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN' + #13#10 +
              'PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) Where AY = 0 ';
   if ComboPersonel.Text <> '' then
      Sql1 := Sql1 + ' and PP.REHBERID = ' + IntToStr(ComboPersonel.Tag) + '  '
   else
      Sql1 := Sql1 + ' and PP.REHBERID <> 0  ';

  Sql1 := Sql1 + ' AND (PP.GIRIS between CONVERT(DATETIME,''' + FormatDateTime('mm-dd-yyyy', TarihBas.Date) + ' 00:00:00'',102) ' +
       ' and CONVERT(DATETIME,''' + FormatDateTime('mm-dd-yyyy', TarihBit.Date)+ ' 23:59:59'',102))';

  if RbGirisTumu.Checked = False then begin
     if RbGirisErken.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.GIRIS) > CONVERT(Time,PP.GIRIS) and convert(Time,PP.GIRIS) <> ''00:00'''
     else if RbGirisGec.Checked Then
             Sql1 := Sql1 + ' and convert(Time,PV.GIRIS) < CONVERT(Time,PP.GIRIS)';
  end;

  if RbCikisTumu.Checked =False then begin
     if RbCikisErken.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.CIKIS) > CONVERT(Time,PP.CIKIS)'
     else if RbCikisGec.Checked  then
        Sql1 := Sql1 + ' and convert(Time,PV.CIKIS) < CONVERT(Time,PP.CIKIS)';
  end;

  if CbCikisNull.Checked then
     Sql1 := Sql1 + ' and PP.CIKIS <> '''' ';

  if (SubeVarmi)and(ComboSube.EditValue <> 0) then
      Sql1 := Sql1 + ' and PP.SUBEID = '+VarToStr(ComboSube.EditValue)+'  ';

  if (VarToStr(ComboDurum.EditValue)<>'')and(VarToStr(ComboDurum.EditValue)<>'0') then
     Sql1:=Sql1+ ' and PP.DURUM = '+VarToStr(ComboDurum.EditValue)+' ';

  TabPDKS.Sql.Text := Sql1 + ' ORDER BY R.FIRMA,PP.GIRIS,PP.CIKIS ';
  TabloYenile(TabPDKS, []);

  TOPLAM.close;
  TOPLAM.SQL.Text := 'select DURUM, SAYI=count(ID) from PERS_PDKS where GIRIS between '''+FormatDateTime('yyyy-mm-dd 00:00', TarihBas.Date)+''' and '+
      ''''+FormatDateTime('yyyy-mm-dd 23:59', TarihBit.Date)+''' ';
  if CbCikisNull.Checked then
     TOPLAM.SQL.Add(' and CIKIS <> '''' ');
  if (SubeVarmi)and(ComboSube.EditValue)<>0 then
      TOPLAM.SQL.Add(' and SUBEID = '+VarToStr(ComboSube.EditValue));
  if (VarToStr(ComboDurum.EditValue)<>'')and(VarToStr(ComboDurum.EditValue)<>'0') then
     TOPLAM.SQL.Add(' and DURUM = '+VarToStr(ComboDurum.EditValue));
  if ComboPersonel.Text <> '' then
     TOPLAM.SQL.Add(' and REHBERID = ' + IntToStr(ComboPersonel.Tag));
  TOPLAM.SQL.Add(' group by DURUM ');

  TabloYenile(TOPLAM, []);

end;

end.





