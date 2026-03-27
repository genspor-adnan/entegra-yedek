unit UIskontoDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  Vcl.ComCtrls, Vcl.ToolWin, FireDAC.Comp.Client, Vcl.Menus, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TIskontoDlg = class(TForm)
    TabIskonto: TFDQuery;
    DtsIskonto: TDataSource;
    ToolBar4: TToolBar;
    BtnSonucYeni: TToolButton;
    BtnSonucSil: TToolButton;
    BtnDuzenle: TToolButton;
    gridIskonto: TcxGrid;
    gridIskontoView: TcxGridDBTableView;
    gridIskontoLevel1: TcxGridLevel;
    Menu1: TPopupMenu;
    UrunMenu: TMenuItem;
    UrunKategorisiMenu: TMenuItem;
    N1: TMenuItem;
    Hizmet1: TMenuItem;
    HizmetKategorisi1: TMenuItem;
    TabIskontoID: TIntegerField;
    TabIskontoKAMPANYAID: TIntegerField;
    TabIskontoANAHTAR: TWideStringField;
    TabIskontoSID: TIntegerField;
    TabIskontoKOD: TWideStringField;
    TabIskontoSTOKADI: TWideStringField;
    TabIskontoMIKTAR: TFloatField;
    TabIskontoDURUM: TBooleanField;
    gridIskontoViewANAHTAR: TcxGridDBColumn;
    gridIskontoViewKOD: TcxGridDBColumn;
    gridIskontoViewSTOKADI: TcxGridDBColumn;
    gridIskontoViewMIKTAR: TcxGridDBColumn;
    gridIskontoViewDURUM: TcxGridDBColumn;
    TumUrunlerMenu: TMenuItem;
    TumHizmetlerMenu: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure UrunKategorisiMenuClick(Sender: TObject);
    procedure BtnSonucSilClick(Sender: TObject);
    procedure BtnDuzenleClick(Sender: TObject);
    procedure UrunMenuClick(Sender: TObject);
    procedure TumUrunlerMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure IskInsert(Tur,UrunId:Integer);
  public
    { Public declarations }
    RehberId:Integer;
  end;

var
  IskontoDlg: TIskontoDlg;

implementation

{$R *.dfm}

uses UTablo, UKategori, FetaKurulusSiniflari, UGirisKutusuEx, PrjConst, UStokHizmetAra,LocOnFly;

procedure TIskontoDlg.BtnDuzenleClick(Sender: TObject);
var
  ctrls: TGirdiDenetimleri;
  Oran:Variant;
begin
  Oran := TabIskonto.FieldByName('MIKTAR').AsString;
  ctrls := TGirdiDenetimleri.Create.Edit(BGIskonto_orani,@Oran);
  if TGirisKutusuEx.BilgiAlEx(BGBilgi,ctrls) = mrOk then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update KAMPANYACARI set MIKTAR='+VarToStr(Oran)+' where ID='+TabIskonto.FieldByName('ID').AsString,[],[]);
     TabloYenile( TabIskonto, [RehberId]);
  end;
end;

procedure TIskontoDlg.BtnSonucSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KAMPANYACARI where ID='+TabIskonto.FieldByName('ID').AsString,[],[]);
     TabloYenile( TabIskonto, [RehberId]);
  end;
end;

procedure TIskontoDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TIskontoDlg.FormShow(Sender: TObject);
begin
   TabloYenile( TabIskonto, [RehberId]);
end;

procedure TIskontoDlg.IskInsert(Tur,UrunId:Integer);
var
  ctrls: TGirdiDenetimleri;
  Oran:Variant;
begin
      Tablo.TablodanSorguAc(1,'select ID from KAMPANYACARI where KAMPANYAID='+IntToStr(Tur)+' and REHBERID='+IntToStr(RehberId)+' and URUNID='+IntToStr(UrunId));
      if Tablo.Query1.RecordCount>0 then
         raise Exception.Create(ekli);
      Oran := '0';
      ctrls := TGirdiDenetimleri.Create.Edit(BGIskonto_orani,@Oran);
      if TGirisKutusuEx.BilgiAlEx(BGBilgi,ctrls) = mrOk then begin
         if TabIskonto.State in [dsEdit, dsInsert] then //tablo insert modunda ise kapatırız
            TabIskonto.Cancel;
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into KAMPANYACARI (KAMPANYAID,REHBERID,URUNID,MIKTAR,DURUM,EKLEYEN)values'+
            '(&KAMPANYAID,&REHBERID,&URUNID,&MIKTAR,&DURUM,&EKLEYEN)',['&KAMPANYAID','&REHBERID','&URUNID','&MIKTAR','&DURUM','&EKLEYEN'],
            [Tur,RehberId,UrunId,VarToStr(Oran),1,Kullanan]);
         TabloYenile( TabIskonto, [RehberId]);
      end;
end;

procedure TIskontoDlg.TumUrunlerMenuClick(Sender: TObject);
begin
     IskInsert(TMenuItem(Sender).Tag, 0);
end;

procedure TIskontoDlg.UrunMenuClick(Sender: TObject);
var AraDlg: TStokHizmetAraDlg;
begin
  if AraDlg=nil then
    Application.CreateForm(TStokHizmetAraDlg,AraDlg);
  AraDlg.FatBasID:=-1;
  AraDlg.RehberID:=-1;
  AraDlg.TabDetayGiris:=TabIskonto;
  AraDlg.KalanAdetGetir:=False;
  AraDlg.FiyatlariGetir:=False;
  AraDlg.cbFiyatAdi.EditValue := 0;
  AraDlg.GirisCikis:=FWCikis;
  AraDlg.cbStokDepo.EditValue:=0;
  AraDlg.cbStokDepo.Enabled := False;
  AraDlg.stokhizmetaracagirantur := TabNo_SERVISDETAYPERSONEL;
  AraDlg.BtnSec.OnClick := AraDlg.SadeceTurVeUrunIDGonder;

  AraDlg.ShowModal;
  if AraDlg.ModalResult=MrOk then
     case TMenuItem(Sender).Tag of
      -1  : IskInsert(-1, AraDlg.TabStokListe.FieldByName('ID').Asinteger);
      -11 : IskInsert(-11, AraDlg.TabHizmetListe.FieldByName('ID').Asinteger);
     end;
  FreeAndNil(AraDlg);
end;

procedure TIskontoDlg.UrunKategorisiMenuClick(Sender: TObject);

begin
   Application.CreateForm(TKategoriDlg, KategoriDlg);
   KategoriDlg.ShowModal;
   if KategoriDlg.ModalResult = mrOk then
      IskInsert(TMenuItem(Sender).Tag, KategoriDlg.KATEGORI.fieldbyname('ID').asinteger);
end;

end.



