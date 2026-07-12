unit UKYDenetimWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, cxControls, cxContainer, cxEdit,
  cxLabel, cxDBLabel, JvWizard, JvExControls, StdCtrls, cxButtons, ExtCtrls, DB,
  FireDAC.Comp.Client, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, DateUtils,
  cxDataStorage, cxDBData, cxImageComboBox, ComCtrls, ToolWin, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxImage, cxDBEdit, cxTextEdit, cxMemo, cxMaskEdit,
  cxDropDownEdit, cxSpinEdit, cxButtonEdit, cxCheckBox, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCalendar,
  cxLookAndFeels, dxSkinLiquidSky, cxNavigator, cxGroupBox, dxBarBuiltInMenu, Utablo,
  JvNavigationPane, cxPC, cxHyperLinkEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, cxGridCardView,
  cxGridDBCardView, cxGridCustomLayoutView, OfficePopupMenu,
  cxGridCustomPopupMenu, cxGridPopupMenu, cxRichEdit, dxCoreGraphics,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKYDenetimWizardDlg = class(TForm)
    WizardKontrol: TJvWizard;
    PageDOF: TJvWizardInteriorPage;
    TabDenetim: TFDQuery;
    DtsDenetim: TDataSource;
    OpenDialog1: TOpenDialog;
    cxGroupBox1: TcxGroupBox;
    ComboTipi: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    editKALITENO: TcxDBTextEdit;
    cxLabel8: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    EditTalepEden: TcxButtonEdit;
    DateTarih: TcxDBDateEdit;
    ComboKATEGORI: TcxDBImageComboBox;
    LabelKategori: TcxLabel;
    EditADI: TcxDBTextEdit;
    cxLabel12: TcxLabel;
    MemoKONUSU: TcxDBMemo;
    cxLabel13: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    cxLabel11: TcxLabel;
    EditSorumlu: TcxButtonEdit;
    cxLabel5: TcxLabel;
    DateBASLAMATARIHI: TcxDBDateEdit;
    cxLabel3: TcxLabel;
    cxLabel15: TcxLabel;
    DateBITISTARIHI: TcxDBDateEdit;
    cxGroupBox3: TcxGroupBox;
    EditDepartman: TcxButtonEdit;
    BeditProje: TcxButtonEdit;
    cxLabel7: TcxLabel;
    LabelKurum: TcxLabel;
    ComboKurum: TcxButtonEdit;
    cxLabel9: TcxLabel;
    EditDenetci: TcxButtonEdit;
    PageControl1: TcxPageControl;
    TabSheetSonuc: TcxTabSheet;
    TabSheetDOF: TcxTabSheet;
    SheetYorum: TcxTabSheet;
    MemoSONUC: TcxDBMemo;
    TabDOF: TFDQuery;
    DtsDOF: TDataSource;
    Panel9: TPanel;
    ToolBar1: TToolBar;
    IlgiliEkleTus: TToolButton;
    IlgiliSilTus: TToolButton;
    ToolButton6: TToolButton;
    IlgiliDuzenleTus: TToolButton;
    JvNavPanelHeader5: TJvNavPanelHeader;
    GridDOF: TcxGrid;
    GridDOFView: TcxGridDBTableView;
    GridDOFViewDOFNO: TcxGridDBColumn;
    GridDOFViewTARIH: TcxGridDBColumn;
    GridDOFViewKONU: TcxGridDBColumn;
    GridDOFViewKATEGORI: TcxGridDBColumn;
    GridDOFViewBIRIM: TcxGridDBColumn;
    GridDOFViewDURUM: TcxGridDBColumn;
    GridDOFLevel3: TcxGridLevel;
    DtsIlgili: TDataSource;
    TabIlgili: TFDQuery;
    TabIlgiliDOKUMANILGILIID: TIntegerField;
    TabIlgiliAD: TWideStringField;
    TabIlgiliKLASOR: TWideStringField;
    PopupDokuman: TPopupMenu;
    DokDizindenMenu: TMenuItem;
    N10: TMenuItem;
    DokListedenMenu: TMenuItem;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    procedure FormShow(Sender: TObject);
    procedure btnDOFClick(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure TabDenetimNewRecord(DataSet: TDataSet);
    procedure Kaydet;
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure LabelKategoriClick(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditDenetciPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSorumluPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTalepEdenPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
    procedure ComboFaaliyetPropertiesChange(Sender: TObject);
    procedure IlgiliEkleTusClick(Sender: TObject);
    procedure IlgiliDuzenleTusClick(Sender: TObject);
    procedure IlgiliSilTusClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure GridYorumDBCardView1CellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure PopupYorumlarPopup(Sender: TObject);
  private
    { Private declarations }
  public
    Cagiran: Integer;
    DOF_ID: Integer;
    IslemOp: Char;
    { Public declarations }
  end;

var
  KYDenetimWizardDlg: TKYDenetimWizardDlg;

implementation

uses UVeriMotor, PrjConst,  UResim, UBinarySave, URehberAyar, FetaKurulusSiniflari, Fetautil, UCariFonksiyonlar,
     UKYDuzelticiVeOnleyiciFaalListeDlg, UAnaForm;
{$R *.dfm}

procedure TKYDenetimWizardDlg.BeditProjePropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaPROJEIDGonder(BeditProje, TabDenetim, AButtonIndex,ProjeSecimi, TabDenetim.FieldByName('REHBERID').AsInteger);
end;

procedure TKYDenetimWizardDlg.IlgiliDuzenleTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('D', 0, TabDOF.FieldByName('ID').AsInteger) > -99 then
     TabloYenile(TabDOF,[TabDenetim.FieldByName('ID').AsInteger]);
end;

procedure TKYDenetimWizardDlg.IlgiliEkleTusClick(Sender: TObject);
begin
  if DOFSihirbazBaslat('E', 0,-1, Tabno_KaliteDenetim, TabDenetim.FieldByName('ID').AsInteger) > -99 then
     TabloYenile(TabDOF,[TabDenetim.FieldByName('ID').AsInteger]);
end;

procedure TKYDenetimWizardDlg.IlgiliSilTusClick(Sender: TObject);
begin
   DofSil(TabDOF.FieldByName('ID').AsInteger);
   TabloYenile(TabDOF,[TabDenetim.FieldByName('ID').AsInteger]);
end;

procedure TKYDenetimWizardDlg.EditDenetciPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
///  st : Tstringlist;
  ID : Integer;
begin
    if ComboTipi.EditValue=1 then begin    //iç denetim ise kendi personelimiz
       ID := Tablo.RehberAra_IDGetir(335);
       if ID > 0 then begin
          TabDenetim.Edit;
          TabDenetim.FieldByName('DENETCI').AsInteger := ID;
          EditDenetci.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
       end
    end
    else //dış denetimse kurumun personeli
       Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, TabDenetim);
end;

procedure TKYDenetimWizardDlg.ComboFaaliyetPropertiesChange(Sender: TObject);
begin
   ComboKurum.Visible := ComboTipi.EditValue = 2;
   LabelKurum.Visible := ComboKurum.Visible;
end;

procedure TKYDenetimWizardDlg.btnDOFClick(Sender: TObject);
begin
  WizardKontrol.ActivePage := PageDOF;
end;

procedure TKYDenetimWizardDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, Tabno_KaliteDenetim, TabDenetim.FieldByName('ID').AsInteger, TabDenetim.FieldByName('REHBERID').AsInteger,TabYorum);
end;

procedure TKYDenetimWizardDlg.cxButtonEdit1PropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
var
   ID : Integer;
begin
   if AButtonIndex = 0 then begin
      ID := Tablo.RehberAra_IDGetir(-1);
      if ID > -2 then begin
         TabDenetim.Edit;
         TabDenetim.FieldByName('REHBERID').AsInteger := ID;
         ComboKurum.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID); ;
      end;
   end else begin
      TabDenetim.Edit;
      TabDenetim.FieldByName('REHBERID').Value := 0 ;
      ComboKurum.Text  := '';
   end;
end;

procedure TKYDenetimWizardDlg.cxGridDBColumn4GetPropertiesForEdit(Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TKYDenetimWizardDlg.LabelKategoriClick(Sender: TObject);
begin
   tablo.GeniniBaslat(Ops_KYDenetimKategori);
   tablo.GENINI.ReadImageSection(Ops_KYDenetimKategori, tablo.RepKYDenetimKategori.Properties.Items);
end;

procedure TKYDenetimWizardDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
   Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TKYDenetimWizardDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TKYDenetimWizardDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TKYDenetimWizardDlg.DkmanSil1Click(Sender: TObject);
begin
  if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
    Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
    Tabloyenile(TabYorum,[Tabno_KaliteDenetim, TabDenetim.FieldByName('ID').AsInteger]);
  end;
end;

procedure TKYDenetimWizardDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger, -999)
end;

procedure TKYDenetimWizardDlg.EditSorumluPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var  ID : Integer;
begin
   if AButtonIndex = 0 then begin
      ID := Tablo.RehberAra_IDGetir(335);
      if ID > 0 then begin
         TabDenetim.Edit;
         TabDenetim.FieldByName('SORUMLU').AsInteger := ID;
        EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      end;
   end else begin
      TabDenetim.Edit;
      TabDenetim.FieldByName('SORUMLU').Value := 0 ;
      EditSorumlu.Text  := '';
   end;
end;

procedure TKYDenetimWizardDlg.EditDepartmanPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex,1, TabDenetim, 'DEPARTMAN');
end;

procedure TKYDenetimWizardDlg.EditTalepEdenPropertiesButtonClick(  Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
   if AButtonIndex = 0 then begin
      ID := Tablo.RehberAra_IDGetir(335);
      if ID > 0 then
      begin
        TabDenetim.Edit;
        TabDenetim.FieldByName('TALEPEDEN').AsInteger := ID;
        EditTalepEden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
      end;
   end else begin
      TabDenetim.Edit;
      TabDenetim.FieldByName('TALEPEDEN').Value := 0 ;
      EditTalepEden.Text  := '';
   end;
end;

procedure TKYDenetimWizardDlg.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := 0;
  case IslemOp of
    'E':
      begin
        TabDenetim.Close;
        TabDenetim.SQL.Text := 'select * from KALITEDENETIM where 1=2';
        TabDenetim.Open;
        TabDenetim.Append;
        TabDenetim.Post;
        TabDenetim.Edit;
        ComboDURUM.EditValue := 1; // ComboDurum.Properties.Items[0].Value;
        DateTarih.Date := Today;
      end;
    'D','K':
      begin
        TabDenetim.Close;
        TabDenetim.SQL.Text := 'select * from KALITEDENETIM where ID=:ID';
        TabDenetim.Params.Clear;
        with TabDenetim.Params.Add do
        begin
          Name := 'ID';
          DataType := ftInteger;
          ParamType := ptInput;
          AsInteger := DOF_ID;
        end;
        TabDenetim.Open;
        // TabloYenile(TabDenetimDetay,[DOF_ID]);
        if TabDenetim.FieldByName('TALEPEDEN').AsString <> '' then
           EditTalepEden.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDenetim.FieldByName('TALEPEDEN').AsInteger);
        if TabDenetim.FieldByName('REHBERID').AsString <> '' then //kurum
           ComboKurum.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDenetim.FieldByName('REHBERID').AsInteger);
        if TabDenetim.FieldByName('DENETCI').AsString <> '' then
              EditDenetci.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDenetim.FieldByName('DENETCI').AsInteger);
        if TabDenetim.FieldByName('SORUMLU').AsString <> '' then
           EditSorumlu.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabDenetim.FieldByName('SORUMLU').AsInteger);
        if TabDenetim.FieldByName('DEPARTMAN').AsString <> '' then begin
           Tablo.TablodanSorguAc(1,'select SUBEID,DEPARTMAN=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 '+DbSinir(1)+'),'+
              ' GOREV=(SELECT '+DbUst(1)+'ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 '+DbSinir(1)+') '+
              ' from ROLLER ROL where ROL.ID='+TabDenetim.FieldByName('DEPARTMAN').AsString);
           EditDepartman.text := Tablo.Query1.Fields[1].AsString+' / '+Tablo.Query1.Fields[2].AsString;
        end;


        if (TabDenetim.FieldByName('PROJEID').Value <> null) and (TabDenetim.FieldByName('PROJEID').AsInteger>0) then begin
          Tablo.TablodanSorguAc(9,'select ID,AD=isnull(PROJEKODU,'''')+'' / ''+isnull(PROJEADI,'''') from PROJELER where ID='+TabDenetim.FieldByName('PROJEID').AsString);
          if Tablo.Query9.RecordCount>0 then begin
            BeditProje.Text := Tablo.Query9.FieldByName('AD').AsString;
            BeditProje.Tag := Tablo.Query9.FieldByName('ID').AsInteger;
          end;
        end;

      end;
  end;
  PageControl1.ActivePageIndex := 0;
  TabloYenile(TabDOF,[TabDenetim.FieldByName('ID').AsInteger]);
  Tabloyenile(TabYorum,[Tabno_KaliteDenetim, TabDenetim.FieldByName('ID').AsInteger]);
end;

procedure TKYDenetimWizardDlg.GridYorumDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  Tablo.GridYorumCellDblClick(Sender,ACellViewInfo,AButton,AShift,AHandled);
end;

procedure TKYDenetimWizardDlg.PageDOFExitPage(Sender: TObject; const FromPage: TJvWizardCustomPage);
begin
  Kaydet;
end;

procedure TKYDenetimWizardDlg.PopupYorumlarPopup(Sender: TObject);
begin
    DkmanGster1.Visible := TabYorum.FieldByName('DOKUMANID').AsString<>'';
    DokumanFormunuA1.Visible := DkmanGster1.Visible;
    DkmanSil1.Visible := DkmanGster1.Visible;
end;

procedure TKYDenetimWizardDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(Tabno_KaliteDenetim, TabDenetim.FieldByName('ID').AsInteger, TabYorum);
end;

procedure TKYDenetimWizardDlg.TabDenetimNewRecord(DataSet: TDataSet);
begin
  TabDenetim.FieldByName('EKLEYEN').Value := strtoint(Kullanan);
  TabDenetim.FieldByName('SUBEID').Value := SubeID;
  TabDenetim.FieldByName('DURUM').AsInteger := 1;
  TabDenetim.FieldByName('TIPI').AsInteger := 1;
  TabDenetim.FieldByName('TARIH').Value := Tablo.GENINI.BugunTrhSaat;
  TabDenetim.FieldByName('BASLAMATARIHI').Value := TabDenetim.FieldByName('TARIH').Value;
  TabDenetim.FieldByName('DENETIMNO').AsString := Tablo.IDdenNumaraGetir('KALITEDENETIM',5);
end;

procedure TKYDenetimWizardDlg.Kaydet;
begin
  if TabDenetim.Active then
     if TabDenetim.State in [dsEdit, dsInsert] then
        TabDenetim.Post;
end;

procedure TKYDenetimWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
  if IslemOp in ['E', 'K'] then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from KALITEDENETIM where ID=&DokID', ['&DokID'], [TabDenetim.FieldByName('ID').AsInteger]);
end;

procedure TKYDenetimWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
  if not BoslukKontrol(ComboTipi.text, 'Tipi') then Abort;
  //if not BoslukKontrol(ComboBolum.text, 'Birim') then Abort;
  if not BoslukKontrol(EditTalepEden.text, 'Talep Eden') then Abort;
  if not BoslukKontrol(ComboDURUM.text, 'Durum') then Abort;
  //if not BoslukKontrol(EditSorumlu.text, 'DÖF Sorumlusu') then Abort;
  if not BoslukKontrol(EditADI.text, 'Denetim Adı') then Abort;

  Kaydet;

  ModalResult := mrOk;
  end;

procedure TKYDenetimWizardDlg.YorumDzenle1Click(Sender: TObject);
begin
  Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, Tabno_KaliteDenetim);
end;

end.



