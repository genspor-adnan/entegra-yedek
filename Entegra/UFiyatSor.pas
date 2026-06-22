unit UFiyatSor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxGraphics, cxMaskEdit, cxDropDownEdit,
  StdCtrls, cxButtons, cxControls, cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit,
  Utablo, cxLabel, JvExControls, JvButton, JvNavigationPane, ExtCtrls, UHizliGiris,
  dxSkinsCore, dxSkinLondonLiquidSky, cxLookAndFeels, dxSkinLiquidSky, cxPC,
  cxDBEdit, cxCheckBox, dxSkinscxPCPainter, dxBarBuiltInMenu, cxPCdxBarPopupMenu,
  cxButtonEdit, cxSpinEdit, cxImageComboBox, cxRadioGroup, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  cxCalendar, cxGridLevel, cxGridCardView, cxGridDBCardView,
  cxGridCustomLayoutView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, FireDAC.Comp.Client,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.ComCtrls, dxCore, cxDateUtils, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  dxCoreGraphics;

type
  TFiyatSorDlg = class(TForm)
    AltPanelStokAdi: TPanel;
    cxPageControl1: TcxPageControl;
    SheetFiyatlandirma: TcxTabSheet;
    SheetDetay: TcxTabSheet;
    Panel1: TPanel;
    cxLabel9: TcxLabel;
    Panel2: TPanel;
    cxLabel10: TcxLabel;
    Panel3: TPanel;
    cxLabel11: TcxLabel;
    PanelTevkifat: TPanel;
    cxLabel13: TcxLabel;
    ComboTevkifatOrani: TcxImageComboBox;
    PanelOzelKod: TPanel;
    cxLabel14: TcxLabel;
    PanelUst: TPanel;
    Bevel1: TBevel;
    cxLabel8: TcxLabel;
    ComboKur: TcxComboBox;
    EditDovizBirimFiyat: TcxCurrencyEdit;
    EditKurDegeri: TcxCurrencyEdit;
    PanelAlt: TPanel;
    EkleTus: TcxButton;
    EditVade: TcxSpinEdit;
    cxLabel17: TcxLabel;
    EditOzelKod: TcxTextEdit;
    EditKampanya: TcxButtonEdit;
    EditMasrafMerkezi: TcxButtonEdit;
    CheckKur: TcxCheckBox;
    CheckDovizBirimFiyat: TcxCheckBox;
    SheetBilgi: TcxTabSheet;
    TabSonTeklifler: TFDQuery;
    DtsSonTeklifler: TDataSource;
    TabUretim: TFDQuery;
    DtsUretim: TDataSource;
    tabMaliyetler: TFDQuery;
    DtsMaliyetler: TDataSource;
    TabStokDurumDetay: TFDQuery;
    DtsStokDurumDetay: TDataSource;
    TabSonSatislar: TFDQuery;
    DtsSonSatislar: TDataSource;
    TabSonAlislar: TFDQuery;
    DtsSonAlislar: TDataSource;
    cxGrid1: TcxGrid;
    cxGrid1DBTableViewDurum: TcxGridDBTableView;
    cxGrid1DBTableViewDurumTIP: TcxGridDBColumn;
    cxGrid1DBTableViewDurumADET: TcxGridDBColumn;
    cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn;
    cxGrid1DBCardViewAlislar: TcxGridDBCardView;
    cxGrid1DBCardViewAlislarBASLIK: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarFATURATARIH: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarMIKTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarBIRIMTUTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarKUR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow;
    cxGrid1DBCardViewAlislarDOVIZ_KURU: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislar: TcxGridDBCardView;
    cxGrid1DBCardViewSatislarBASLIK: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarFATURATARIH: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarMIKTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarBIRIMTUTAR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarKUR: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarBIRIMTUTARDOVIZ: TcxGridDBCardViewRow;
    cxGrid1DBCardViewSatislarDOVIZ_KURU: TcxGridDBCardViewRow;
    cxGrid1DBTableViewMaliyetler: TcxGridDBTableView;
    cxGrid1DBTableViewMaliyetlerTUR: TcxGridDBColumn;
    cxGrid1DBTableViewMaliyetlerMALIYET: TcxGridDBColumn;
    cxGrid1DBTableViewMaliyetlerKUR: TcxGridDBColumn;
    cxGrid1DBTableViewUretim: TcxGridDBTableView;
    cxGrid1DBTableViewUretimKOD: TcxGridDBColumn;
    cxGrid1DBTableViewUretimSTOKADI: TcxGridDBColumn;
    cxGrid1DBTableViewUretimMIKTAR: TcxGridDBColumn;
    cxGrid1DBTableViewUretimKALAN: TcxGridDBColumn;
    cxGrid1DBTableViewTeklif: TcxGridDBTableView;
    cxGrid1DBTableViewTeklifColumnBASLIK: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnTARIH: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnMIKTAR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnBIRIMTUTAR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnKUR: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnBIRIMTUTARDOVIZ: TcxGridDBColumn;
    cxGrid1DBTableViewTeklifColumnDOVIZ_KURU: TcxGridDBColumn;
    cxGrid1LevelDepoDurumu: TcxGridLevel;
    cxGrid1LevelSonAlislar: TcxGridLevel;
    cxGrid1LevelSonSatislar: TcxGridLevel;
    cxGrid1LevelMaliyetler: TcxGridLevel;
    cxGrid1LevelUretim: TcxGridLevel;
    cxGrid1LevelTeklif: TcxGridLevel;
    CheckStoktan: TcxCheckBox;
    PanelAciklama: TPanel;
    Bevel5: TBevel;
    PanelToplamTutar: TPanel;
    cxLabel6: TcxLabel;
    EditToplamTutar: TcxCurrencyEdit;
    CheckTutar: TcxCheckBox;
    Bevel6: TBevel;
    PanelIskonto: TPanel;
    EditIsk2: TcxCurrencyEdit;
    EditIsk1: TcxCurrencyEdit;
    cxLabel3: TcxLabel;
    Bevel4: TBevel;
    PanelMiktar: TPanel;
    Bevel3: TBevel;
    LabelBirim: TcxLabel;
    ArtirTus: TcxButton;
    AzaltTus: TcxButton;
    EditMiktar: TcxCurrencyEdit;
    PanelBirimFiyat: TPanel;
    CheckKDV: TcxCheckBox;
    ComboKDV: TcxComboBox;
    cxLabel16: TcxLabel;
    EditBirimFiyat: TcxCurrencyEdit;
    CheckBirimFiyat: TcxCheckBox;
    Bevel2: TBevel;
    Panel8: TPanel;
    Bevel7: TBevel;
    EditAciklama: TcxButtonEdit;
    cxLabel5: TcxLabel;
    cxLabel1: TcxLabel;
    BeditPersonel: TcxButtonEdit;
    cxLabel2: TcxLabel;
    Panel7: TPanel;
    cxLabel4: TcxLabel;
    EditMasrafKalemi: TcxButtonEdit;
    SqlMemoMasrafKalemi: TMemo;
    Panel6: TPanel;
    Bevel8: TBevel;
    EditProje: TcxButtonEdit;
    cxLabel7: TcxLabel;
    LabelCoklu: TcxLabel;
    PanelTeslimTarihi: TPanel;
    Bevel9: TBevel;
    cxLabel12: TcxLabel;
    EditTeslimTarihi: TcxDateEdit;
    PanelEkipman: TPanel;
    cxLabel15: TcxLabel;
    EditEkipman: TcxButtonEdit;
    PanelPozNo: TPanel;
    cxLabel18: TcxLabel;
    EditPozNo: TcxCurrencyEdit;
    PanelResimGoster: TPanel;
    cxLabel19: TcxLabel;
    CheckResimGoster: TcxCheckBox;
    PanelYuzey: TPanel;
    cxLabel20: TcxLabel;
    cxLabel21: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel23: TcxLabel;
    cxLabel24: TcxLabel;
    EditEN: TcxCurrencyEdit;
    EditBOY: TcxCurrencyEdit;
    EditYuzey: TcxCurrencyEdit;
    EditSAYI: TcxCurrencyEdit;
    CheckMedyaEkle: TcxCheckBox;
    Panel9: TPanel;
    cxLabel25: TcxLabel;
    EditOzelKod2: TcxTextEdit;
    PanelStokAdi: TcxLabel;
    procedure ArtirTusClick(Sender: TObject);
    procedure AzaltTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditDovizBirimFiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditBirimFiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditMiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditIsk1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboKurPropertiesCloseUp(Sender: TObject);
    procedure EditKurDegeriKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditKampanyaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditMasrafKalemiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboKDVPropertiesCloseUp(Sender: TObject);
    procedure CheckTutarClick(Sender: TObject);
    procedure CheckDovizBirimFiyatClick(Sender: TObject);
    procedure CheckKurClick(Sender: TObject);
    procedure CheckBirimFiyatClick(Sender: TObject);
    procedure cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet;
      var AllowChange: Boolean);
    procedure cxGrid1ActiveTabChanged(Sender: TcxCustomGrid;
      ALevel: TcxGridLevel);
    procedure BeditPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditMasrafKlemiPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure Hesapla;
    procedure LabelCokluClick(Sender: TObject);
    procedure EditEkipmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditAciklamaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditENKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure AcKapa;
  public
    { Public declarations }
    var AKur : String;
        AKurDegeri : Extended;
        AKDV, Tur : Smallint;
        RehberId,StokId,UrunTur : Integer;
        Trh : TDateTime;
  end;

var
  FiyatSorDlg: TFiyatSorDlg;

implementation

uses
  Fetautil,FetaKurulusSiniflari,FetaClassExtensions,PrjCOnst,LocOnFLy, UGirisKutusuEx, math;

{$R *.dfm}
var
  KurDegeriBos, IptalBasildi, BaslikCheckEnable:Boolean;

procedure TFiyatSorDlg.ArtirTusClick(Sender: TObject);
begin
  EditMiktar.Value := EditMiktar.Value + 1;
  Hesapla;
end;

procedure TFiyatSorDlg.AzaltTusClick(Sender: TObject);
begin
  if (EditMiktar.Value < 1.0)and(EditMiktar.Value >= 0.0) then
    EditMiktar.Value := 0
  else if True then
    EditMiktar.Value := EditMiktar.Value -1;
  Hesapla;
end;

procedure TFiyatSorDlg.BeditPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TFiyatSorDlg.AcKapa;
begin
  EditDovizBirimFiyat.enabled :=CheckDovizBirimFiyat.Checked;
  EditKurDegeri.enabled := CheckKur.Checked;
  EditBirimFiyat.enabled := CheckBirimFiyat.Checked;
end;

procedure TFiyatSorDlg.CheckBirimFiyatClick(Sender: TObject);
begin
  if BaslikCheckEnable then begin
    BaslikCheckEnable:= False;
    CheckKur.Checked:= not CheckBirimFiyat.Checked;
    CheckDovizBirimFiyat.Checked:= True;
    AcKapa;
    BaslikCheckEnable:= True;
  end;
end;

procedure TFiyatSorDlg.CheckDovizBirimFiyatClick(Sender: TObject);
begin
  if BaslikCheckEnable then begin
    BaslikCheckEnable:= False;
    CheckBirimFiyat.Checked:= not CheckDovizBirimFiyat.checked;
    CheckKur.Checked:= True;
    AcKapa;
    BaslikCheckEnable:= True;
  end;
end;

procedure TFiyatSorDlg.CheckKurClick(Sender: TObject);
begin
  if BaslikCheckEnable then begin
    BaslikCheckEnable:= False;
    CheckDovizBirimFiyat.Checked:= not CheckKur.checked;
    CheckBirimFiyat.Checked:= True;
    AcKapa;
    BaslikCheckEnable:= True;
  end;
end;

procedure TFiyatSorDlg.CheckTutarClick(Sender: TObject);
begin
  EditToplamTutar.Enabled := CheckTutar.Checked;
  CheckDovizBirimFiyat.enabled := not CheckTutar.Checked;
  CheckKur.enabled:= not CheckTutar.Checked;
  CheckBirimFiyat.enabled:= not CheckTutar.Checked;
  if CheckTutar.Checked then begin
    EditToplamTutar.SetFocus;
    BaslikCheckEnable:= False;
    CheckDovizBirimFiyat.Checked := False;
    CheckBirimFiyat.Checked:= False;
    CheckKur.Checked:= True;
    AcKapa;
    BaslikCheckEnable:= True;
  end else if PanelUst.Visible then
    ComboKurPropertiesCloseUp(Self)
  else begin
    EditBirimFiyat.Enabled := True;
    EditBirimFiyat.SetFocus;
  end;
end;

procedure TFiyatSorDlg.ComboKDVPropertiesCloseUp(Sender: TObject);
begin
  AKDV := ComboKDV.EditValue;
end;

procedure TFiyatSorDlg.ComboKurPropertiesCloseUp(Sender: TObject);
begin
  BaslikCheckEnable := False;
  CheckDovizBirimFiyat.enabled := ComboKur.EditValue <> CariDoviz;
  CheckKur.enabled:= ComboKur.EditValue <> CariDoviz;
  CheckBirimFiyat.enabled:= ComboKur.EditValue <> CariDoviz;
  CheckDovizBirimFiyat.checked := (ComboKur.EditValue <> CariDoviz)and(not CheckTutar.Checked);
  CheckKur.checked := ComboKur.EditValue <> CariDoviz;
  CheckBirimFiyat.checked:= ComboKur.EditValue = CariDoviz;
  AcKapa;
  BaslikCheckEnable := True;
  if ComboKur.EditValue = CariDoviz then begin
    EditDovizBirimFiyat.EditValue:=0;
    EditKurDegeri.EditValue := 0;
    if EditBirimFiyat.Enabled then
       EditBirimFiyat.SetFocus
  end else begin
    if ComboKur.EditValue=AKur then
       EditKurDegeri.EditValue := AKurDegeri
    else
       EditKurDegeri.EditValue := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00',Trh), ComboKur.EditValue, Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
    EditBirimFiyat.EditValue := EditDovizBirimFiyat.EditValue * EditKurDegeri.EditValue;
    if EditDovizBirimFiyat.Enabled then
       EditDovizBirimFiyat.SetFocus;
  end;
  Hesapla;
end;

procedure TFiyatSorDlg.cxGrid1ActiveTabChanged(Sender: TcxCustomGrid; ALevel: TcxGridLevel);
begin
  if (UrunTur=1)and(StokId > 0) then begin
    if ALevel = cxGrid1LevelSonalislar then
       TabloYenile(TabSonAlislar,[StokId,1,0])
    else if ALevel = cxGrid1LevelSonSatislar then
       TabloYenile(TabSonSatislar,[StokId,1,0])
    else if ALevel = cxGrid1LevelDepoDurumu then
       TabloYenile(TabStokDurumDetay,[StokId,0])
    else if ALevel = cxGrid1LevelMaliyetler then
       TabloYenile(tabMaliyetler,[StokId])
    else if ALevel = cxGrid1LevelUretim then
       TabloYenile(tabUretim,[StokId])
    else if ALevel = cxGrid1LevelTeklif then
       TabloYenile(TabSonTeklifler,[StokId,1,0]);
  end else if (UrunTur=0)and(StokId > 0) then begin
    if ALevel = cxGrid1LevelSonalislar then
       TabloYenile(TabSonAlislar,[StokId,0,0])
    else if ALevel = cxGrid1LevelSonSatislar then
       TabloYenile(TabSonSatislar,[StokId,0,0])
    else if ALevel = cxGrid1LevelTeklif then
       TabloYenile(TabSonTeklifler,[StokId,0,0]);
    TabStokDurumDetay.Close;
    tabMaliyetler.Close;
    TabUretim.Close;
  end else begin
    TabSonAlislar.Close;
    TabSonSatislar.Close;
    TabStokDurumDetay.Close;
    tabMaliyetler.Close;
    TabUretim.Close;
  end;
end;

procedure TFiyatSorDlg.cxPageControl1PageChanging(Sender: TObject; NewPage: TcxTabSheet; var AllowChange: Boolean);
begin
  if NewPage=SheetDetay then begin
    EditKampanya.Text := Tablo.AciklamaGetir('KAMPANYA','ADI', EditKampanya.Tag);
    EditMasrafMerkezi.Text := Tablo.AciklamaGetir('SRMMERKEZI', 'MERKEZADI', EditMasrafMerkezi.Tag);
    EditMasrafKalemi.Text := Tablo.AciklamaGetir('MASRAFGELIR', 'AD', EditMasrafKalemi.Tag);
  end else if NewPage=SheetBilgi then
    cxGrid1ActiveTabChanged(cxGrid1,cxGrid1.ActiveLevel)
  else if NewPage=SheetFiyatlandirma then
    BeditPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA', BeditPersonel.Tag);
end;

procedure TFiyatSorDlg.EditAciklamaPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := EditAciklama.Text;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) = mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      EditAciklama.Text := VarToStr(Bilgi);
end;

procedure TFiyatSorDlg.EditBirimFiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if EditDovizBirimFiyat.visible then begin
    if ComboKur.EditValue = CariDoviz then   //TL ise
      EditDovizBirimFiyat.Value := 0
    else begin
      if CheckDovizBirimFiyat.checked then
        EditKurDegeri.Value := EditBirimFiyat.Value / EditDovizBirimFiyat.Value
      else
        EditDovizBirimFiyat.Value := EditBirimFiyat.Value / EditKurDegeri.Value;
    end;
  end;
  Hesapla;
end;

procedure TFiyatSorDlg.EditDovizBirimFiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CheckKur.checked then
    EditBirimFiyat.Value := EditDovizBirimFiyat.Value * EditKurDegeri.Value
  else
    EditKurDegeri.Value  := EditBirimFiyat.Value / EditDovizBirimFiyat.Value;
  Hesapla;
end;

procedure TFiyatSorDlg.EditEkipmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EkipmanSec(EditEkipman, AButtonIndex, RehberId);
end;

procedure TFiyatSorDlg.EditENKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   EditYuzey.Value := (EditEN.Value * EditBOY.Value)/1000000;
   EditMiktar.Value :=  EditYuzey.Value * EditSAYI.Value;
end;

procedure TFiyatSorDlg.EditIsk1KeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  EditIsk2.Enabled := EditIsk1.Value>0;
  Hesapla;
end;

procedure TFiyatSorDlg.EditKampanyaPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
  EditKampanya.Tag := Tablo.KampanyaSor(RehberId, StokId ,Tur);
  EditKampanya.Text := Tablo.AciklamaGetir('KAMPANYA','ADI', EditKampanya.Tag);
end;

procedure TFiyatSorDlg.EditKurDegeriKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CheckDovizBirimFiyat.checked then
    EditBirimFiyat.Value := RoundTo( EditDovizBirimFiyat.Value * EditKurDegeri.Value, -2)
  else
    EditDovizBirimFiyat .Value  := EditBirimFiyat.Value / EditKurDegeri.Value;
  Hesapla;
end;

procedure TFiyatSorDlg.EditMasrafKalemiPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var
  st: Tstringlist;
  Gelirmi :Smallint;
begin
  if Tur in [0, 3, 8, 10, 11, 12] then
    Gelirmi := 0
  else
    Gelirmi := 1;
  st := Tstringlist.create;
  if Tablo.ListedenBilgiGetir('Sorumluluk Merkezi seçiniz','SELECT ID,MERKEZKODU,MERKEZADI FROM SRMMERKEZI where GELIRMI='+inttoStr(Gelirmi)+' and MERKEZADI like ''%<ara>%'' ',  st, []) then begin
    EditMasrafMerkezi.Tag := StrToInt(st.Strings[0]);
    EditMasrafMerkezi.Text := st.Strings[2];
  end;
  st.Free;
end;

procedure TFiyatSorDlg.EditMasrafKlemiPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText: string;
  Gelirmi :Smallint;
begin
  if AButtonIndex = 0 then begin
    //eğer proje seçilmişse ve o projeye girilmiş bütçe var ise o bütçe kalemlerinden masraf kalemi seçilir
     if (EditProje.Tag > 0)and
        (Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM PROJEBUTCE WHERE PROJEID='+IntToStr(EditProje.Tag),[],[])) then
        SqlText := SqlMemoMasrafKalemi.Text+ ' and PROJEID='+IntToStr( EditProje.Tag )
     else
        SqlText := '';

    if Tablo.MasrafMerkeziSecimEkrani(Gelirmi, MASRAFID, MASRAFKODU, MASRAFMERKEZI,SqlText) then begin
       EditMasrafKalemi.Tag := StrToInt(MASRAFID);
       EditMasrafKalemi.Text :=MASRAFMERKEZI ;
    end;
  end else if AButtonIndex = 1 then begin
       EditMasrafKalemi.Tag := 0;
       EditMasrafKalemi.Text := '';
  end;
end;

procedure TFiyatSorDlg.Hesapla;
begin
  if CheckTutar.Checked then begin
     EditBirimFiyat.Value := ((EditToplamTutar.Value / EditMiktar.Value) / ((100-EditIsk2.Value)/100)/((100-EditIsk1.Value)/100));
     if (EditDovizBirimFiyat.Visible)and(ComboKur.EditValue <> CariDoviz) then
         EditDovizBirimFiyat.value := EditBirimFiyat.Value / EditKurDegeri.Value;
  end else
     EditToplamTutar.Value := ((EditBirimFiyat.Value * EditMiktar.Value) * ((100-EditIsk1.Value)/100)*((100-EditIsk2.Value)/100));

{  if EnBoyHesaplamaAktif = True then begin
     EditOzelKod.Text := '';
     EditOzelKod2.Text := '';
  end;  }
end;

procedure TFiyatSorDlg.LabelCokluClick(Sender: TObject);
begin
  //if TabKasa.State  in [dsEdit,dsInsert] then
  //   TabKasa.Post;
//  Tablo.ProjeMaliyetIslemleri(TabNo_FATURA, TabKasa.Fields[0].AsInteger,TabKasa.FieldByName('REHBERID').AsInteger, Tur)
end;

procedure TFiyatSorDlg.EditMiktarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=38 then
    ArtirTus.Click
  else if Key=40 then
    AzaltTus.Click
  else begin
    Hesapla;
  end;
end;

procedure TFiyatSorDlg.EditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaPROJEIDGonder(EditProje, nil, AButtonIndex,ProjeSecimi, RehberId);
end;

procedure TFiyatSorDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   IptalBasildi := True;
end;

procedure TFiyatSorDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if  (EditDovizBirimFiyat.Text = '')or(EditBirimFiyat.Text = '')or(EditMiktar.Text = '') then begin
       ShowMessage(STBilgi_alani_doldur);
       CanClose := False;
  end;
  if (EditDovizBirimFiyat.Text = '-')or(EditBirimFiyat.Text = '-')or(EditMiktar.Text = '-')then begin
      ShowMessage(STYanlis_karakter);
      CanClose := False;
  end;
  if (ModalResult=mrOk)and(EditBirimFiyat.Value=0)and(TUR<>20)and(TUR<>101)and(TUR<>105) then
      CanClose := Application.MessageBox('Fiyat sıfır olarak eklenecektir. Onaylıyor musunuz?',PChar(Uyari),MB_YESNO+MB_ICONQUESTION)=mrYes;
end;

procedure TFiyatSorDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  cxPageControl1.ActivePage := SheetFiyatlandirma;
  FormatDuzenle(EditDovizBirimFiyat.Properties,Tablo.RepCurrencyBF.Properties.DecimalPlaces);
  FormatDuzenle(EditBirimFiyat.Properties,Tablo.RepCurrencyBF.Properties.DecimalPlaces);
  FormatDuzenle(EditMiktar.Properties,Tablo.RepCurrencyAdetGenel.Properties.DecimalPlaces);
  Trh := Tablo.GENINI.BugunTrhSaat;
  CheckStoktan.Visible := TamYetkili;
end;

procedure TFiyatSorDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=27 then
     ModalResult := mrCancel
  else if Key=13 then
     ModalResult := mrOK;
end;

procedure TFiyatSorDlg.FormShow(Sender: TObject);
var chng:boolean;
begin

  //LabelCoklu.Visible := BelgeGiderKalemi > 3;
  if EditBirimFiyat.EditValue < 0 then
     EditBirimFiyat.EditValue := 0;
  if (Tur in [12,16]) then  //ilk defa fiş giriliyorsa kdv işaretli olsun, değişimde işaretsiz olsun
      CheckKDV.Checked := (KDVDahil_Isaretli)and(EditBirimFiyat.EditValue=0); //
  cxGrid1LevelDepoDurumu.Visible := (UrunTur=1) and (tablo.YetkiVarmi(24801001,YetkiTur_Gorme,False));
  cxGrid1LevelSonAlislar.Visible := (tablo.YetkiVarmi(24801002,YetkiTur_Gorme,False));
  cxGrid1LevelSonSatislar.Visible := (tablo.YetkiVarmi(24801003,YetkiTur_Gorme,False));
  cxGrid1LevelMaliyetler.Visible :=  (UrunTur=1) and (tablo.YetkiVarmi(24801004,YetkiTur_Gorme,False));
  cxGrid1LevelUretim.Visible :=  (UrunTur=1) and (tablo.YetkiVarmi(24801005,YetkiTur_Gorme,False));
  cxGrid1LevelTeklif.Visible :=  (tablo.YetkiVarmi(24801006,YetkiTur_Gorme,False));

  SheetBilgi.Visible := tablo.YetkiVarmi(248010,YetkiTur_Gorme,False);
  SheetBilgi.TabVisible := SheetBilgi.Visible;

  SheetDetay.Visible := tablo.YetkiVarmi(248011,YetkiTur_Gorme,False);
  SheetDetay.TabVisible := SheetDetay.Visible;

  EditProje.Text := Tablo.AciklamaGetir('PROJELER','PROJEKODU', EditProje.Tag);
  Tablo.TablodanSorguAc(1,'select ER.EKIPMANID, E.AD, ER.SERINO  from EKIPMANREHBER ER inner join EKIPMANLAR E on E.ID=ER.EKIPMANID where ER.ID='+IntToStr(EditEkipman.Tag));
  EditEkipman.Text := Tablo.Query1.Fields[1].AsString;


    ComboKurPropertiesCloseUp(Self);
 {17.11.2024 AO if PanelUst.Visible then
     ComboKurPropertiesCloseUp(Self) }

    if (PanelBirimFiyat.Visible)and(EditBirimFiyat.enabled) then
       EditBirimFiyat.SetFocus;
    //else
    //   EditMiktar.SetFocus;



  PanelUst.Visible := DovizTakibi;
  if(TUR in [20,101,105])or(not Tablo.YetkiVarmi(2431,1,False)) then begin  //stoktalebi veya satınalma talebi veya tutarlar gözükmesin denirse;
    PanelUst.Visible := False;
    PanelBirimFiyat.Visible := False;
    PanelIskonto.Visible := False;
    PanelToplamTutar.Visible := False;
    PanelOzelKod.Visible := False;
  end;

  PanelTeslimTarihi.Visible := TUR in [9,19,20,101,105];
  PanelEkipman.Visible := TUR in [14,15,19,100];
  PanelTevkifat.Visible :=TUR in [10,11,12,14,15];

  PanelYuzey.Visible := EnBoyHesaplamaAktif;




  chng := True;
  cxPageControl1PageChanging(nil,SheetFiyatlandirma,chng);

end;

end.


