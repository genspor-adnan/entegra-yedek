unit UStokDurumDetay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxContainer,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxImage,
  Vcl.ExtCtrls, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxCheckBox, Vcl.Imaging.Jpeg, cxCurrencyEdit, cxLabel, dxSkinLiquidSky, Vcl.StdCtrls, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TStokDurumDetayDlg = class(TForm)
    TabStokDurumDetay: TFDQuery;
    DtsStokDurumDetay: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    cxImageComboBox1: TcxImageComboBox;
    GridResim: TcxGrid;
    GridResimView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    GridFirIlet: TcxGridLevel;
    LogoResim: TcxImage;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    Panel3: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableViewDurum: TcxGridDBTableView;
    cxGrid1DBTableViewDurumTIP: TcxGridDBColumn;
    cxGrid1DBTableViewDurumADET: TcxGridDBColumn;
    cxGrid1DBTableViewDurumBIRIM: TcxGridDBColumn;
    cxGrid1LevelDepoDurumu: TcxGridLevel;
    Panel4: TPanel;
    EditFiyat: TcxCurrencyEdit;
    cxLabel1: TcxLabel;
    LabelAd: TcxLabel;
    TabDepoIzlemDetay: TFDQuery;
    DtsDepoIzlemDetay: TDataSource;
    TabStokCevrimleri: TFDQuery;
    DtsStokCevrimleri: TDataSource;
    MemoBoyutCik: TMemo;
    MemoSKTCik: TMemo;
    MemoSerinoCik: TMemo;
    cxGrid1LevelIzlem: TcxGridLevel;
    cxGrid1LevelDonusum: TcxGridLevel;
    cxGrid1DBTableViewIzlem: TcxGridDBTableView;
    cxGrid1DBTableViewDonusum: TcxGridDBTableView;
    cxGrid1DBTableViewDonusumADET1: TcxGridDBColumn;
    cxGrid1DBTableViewDonusumBIRIM1: TcxGridDBColumn;
    cxGrid1DBTableViewDonusumADET2: TcxGridDBColumn;
    cxGrid1DBTableViewDonusumBIRIM2: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure TabResimAfterScroll(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     StokID,VarsDepo:integer;
  end;

var
  StokDurumDetayDlg: TStokDurumDetayDlg;

implementation

uses
  utablo,LocOnFly;

{$R *.dfm}


procedure TStokDurumDetayDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TStokDurumDetayDlg.FormShow(Sender: TObject);
begin
  cxImageComboBox1.EditValue := VarsDepo;
  cxImageComboBox1.PostEditValue;
  TabloYenile(TabResim,[StokID]);

  Tablo.TablodanSorguAc(1,'select isnull(FIYAT,0) from STOKFIYAT F inner join STOKLAR S on S.ID=F.STOKID and S.ANABIRIM=F.BIRIM where S.ID='+IntToStr(StokID));
  EditFiyat.Value := Tablo.Query1.Fields[0].AsCurrency;
  TabloYenile(TabStokCevrimleri,[StokID]);
end;

procedure TStokDurumDetayDlg.TabResimAfterScroll(DataSet: TDataSet);
var Pic : TJpegImage;
begin
   if TabResim.RecordCount=0 then
      LogoResim.Picture.Graphic:= nil
   else begin
      Pic := TJpegImage.Create;
      Pic.LoadFromStream(TabResim.CreateBlobStream(TabResim.FieldByName('BELGE'),bmread));
      LogoResim.Picture.Graphic := Pic;
      Pic.Free;
   end;

end;

procedure TStokDurumDetayDlg.cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
begin
  TabloYenile(TabStokDurumDetay,[StokID,cxImageComboBox1.EditValue]);
  Tablo.TablodanSorguAc(1,'select IZLEME from STOKLAR where ID='+IntToStr(StokID));
  if Tablo.Query1.RecordCount=1 then begin
    if (Tablo.Query1.Fields[0].Value <> null)and(Tablo.Query1.Fields[0].AsInteger>0) then begin
      TabDepoIzlemDetay.SQL.Text := 'declare @StokID int, @DepoID int set @StokID='+IntToStr(StokID)+' set @DepoID='+VarToStr(cxImageComboBox1.EditValue);
      case Tablo.Query1.Fields[0].Value of
        1,3:TabDepoIzlemDetay.SQL.Add(MemoSerinoCik.Text);
        2:TabDepoIzlemDetay.SQL.Add(MemoSKTCik.Text);
        4:TabDepoIzlemDetay.SQL.Add(MemoBoyutCik.Text);
      end;
    end;
  end;
  TabloYenile(TabDepoIzlemDetay,[]);
end;

end.

