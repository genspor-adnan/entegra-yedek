unit UDemirbasDurumDegis;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils,
  dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky, cxLabel, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxImageComboBox, UTablo, PrjConst,
  dxSkinscxPCPainter, dxBarBuiltInMenu, cxMemo, cxPC, cxButtonEdit, FetaKurulusSiniflari,
  cxCurrencyEdit, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, Data.DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView, UKodAgaci,
  cxGridTableView, cxGridDBTableView, cxGrid, FireDAC.Comp.Client, Vcl.Menus,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TDemirbasDurumDegisDlg = class(TForm)
    edTarih: TcxDateEdit;
    lblTarih: TcxLabel;
    lbAlanPersonel: TcxLabel;
    lbVerenPersonel: TcxLabel;
    cxPageControl1: TcxPageControl;
    SheetAlisBelgesi: TcxTabSheet;
    SheetSatisBelgesi: TcxTabSheet;
    SheetCariBilgi: TcxTabSheet;
    SheetAciklama: TcxTabSheet;
    MemoAciklama: TcxMemo;
    EditLokasyon: TcxButtonEdit;
    EdBelgeNo: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cbAlBelgeTipi: TcxImageComboBox;
    lbAlBelgeTipi: TcxLabel;
    DateAlBelge: TcxDateEdit;
    cxLabel3: TcxLabel;
    CurAlTutar: TcxCurrencyEdit;
    cxLabel4: TcxLabel;
    cbAlKur: TcxComboBox;
    cbVerBelgeTipi: TcxImageComboBox;
    cxLabel5: TcxLabel;
    DateVerBelge: TcxDateEdit;
    cxLabel6: TcxLabel;
    CurVerTutar: TcxCurrencyEdit;
    cxLabel7: TcxLabel;
    cbVerKur: TcxComboBox;
    BeditMusteri: TcxButtonEdit;
    BeditMusteriIlgili: TcxButtonEdit;
    lbMusteri: TcxLabel;
    lbMusIlgili: TcxLabel;
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cbDurum: TcxImageComboBox;
    cxLabel10: TcxLabel;
    SheetDemirbas: TcxTabSheet;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    tabDemirbas: TFDQuery;
    dtsDemirbas: TDataSource;
    cxGrid1DBTableView1ID: TcxGridDBColumn;
    cxGrid1DBTableView1DEMIRBASNO: TcxGridDBColumn;
    cxGrid1DBTableView1DEMIRBASADI: TcxGridDBColumn;
    cxGrid1DBTableView1SERINO: TcxGridDBColumn;
    PopupDemirbas: TPopupMenu;
    Seilidemirbalistedenkart1: TMenuItem;
    BeditVerenPersonel: TcxButtonEdit;
    BeditAlanPersonel: TcxButtonEdit;
    procedure BeditMusteriIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure BeditMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Seilidemirbalistedenkart1Click(Sender: TObject);
    procedure BeditAlanPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditLokasyonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    DemirbasTutanakID :integer;
  public
    { Public declarations }
    Aksiyon:integer;
  end;

var
  DemirbasDurumDegisDlg: TDemirbasDurumDegisDlg;

implementation

{$R *.dfm}

//ACILIS-Alıs Belgesi
//KAPANIS-Satıs Belgesi
//OTOKAPAT-Cari Sor
//TARIHIDESOR-CariPersonelSor



procedure TDemirbasDurumDegisDlg.BeditAlanPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,Nil,'');
end;

procedure TDemirbasDurumDegisDlg.BeditMusteriIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, nil, BeditMusteri.Tag);
end;

procedure TDemirbasDurumDegisDlg.Seilidemirbalistedenkart1Click(
  Sender: TObject);
begin
  if (tabDemirbas.Active) and (tabDemirbas.RecordCount>0) then begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DEMIRBAS_TUTANAK_DETAY where ID='+tabDemirbas.FieldByName('ID').AsString,[],[]);
    TabloYenile(tabDemirbas,[DemirbasTutanakID]);
  end;
end;

procedure TDemirbasDurumDegisDlg.BeditMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var RehID:integer;
begin
  RehID := Tablo.RehberAra_IDGetir(0);
  if RehID>0 then begin
    BeditMusteriIlgili.Tag := 0;
    BeditMusteriIlgili.Text := '';
    BeditMusteri.Tag := RehID;
    BeditMusteri.Text := Tablo.AciklamaGetir('REHBER','FIRMA',RehID);
  end;
end;

procedure TDemirbasDurumDegisDlg.EditLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
begin
  if AButtonIndex = 0 then begin
     LokID:=Tablo.LokasyonAra_IDGetir(Lokasyon_Genel);
     if LokID>0 then begin
        EditLokasyon.Tag:=LokID;
        EditLokasyon.Text:=Tablo.AciklamaGetir('LOKASYON', 'ACIKLAMA', LokID);
     end;
  end else begin
      EditLokasyon.Text:='';
      EditLokasyon.Tag:=0;
  end;
end;

procedure TDemirbasDurumDegisDlg.FormCreate(Sender: TObject);
begin
  DemirbasTutanakID := 0;
end;

procedure TDemirbasDurumDegisDlg.FormShow(Sender: TObject);
begin
  if DemirbasTutanakID=0 then begin
    SheetDemirbas.Visible := False;
    SheetDemirbas.TabVisible := False;
  end else begin
    SheetDemirbas.Visible := True;
    SheetDemirbas.TabVisible := True;
    TabloYenile(tabDemirbas,[DemirbasTutanakID]);
  end;

  if Aksiyon in [11,12,13] then begin //Yeni giriş devir/satın/kira ise değiştirilebilir
     cbDurum.RepositoryItem := nil;
     DemirbasDurumDegisDlg.cbDurum.Properties.Items := Tablo.imgComboboxInit('select KAYNAKDURUM, ANAHTAR from DURUMBAGLANTI DB inner join GENINI G on DB.BOLUM=G.BOLUM '+
                 ' and DB.HEDEFDURUM=G.DEGER where DB.AKTIF=1 and G.DIL=-1 and DB.BOLUM=-2801 and DB.KAYNAKDURUM BETWEEN 11 AND 13  order by 1 ').Items;
     cbDurum.Enabled := True;
  end else begin
     cbDurum.RepositoryItem := Tablo.repDemirbasAksiyon;
     cbDurum.Enabled := False;
  end;
  cbDurum.EditValue := Aksiyon;

  if SheetDemirbas.TabVisible then
    cxPageControl1.ActivePage := SheetDemirbas
  else if SheetAlisBelgesi.TabVisible then
    cxPageControl1.ActivePage := SheetAlisBelgesi
  else if SheetSatisBelgesi.TabVisible then
    cxPageControl1.ActivePage := SheetSatisBelgesi
  else if SheetAciklama.TabVisible then
    cxPageControl1.ActivePage :=SheetAciklama
  else
    cxPageControl1.ActivePage := SheetCariBilgi;
end;

end.



