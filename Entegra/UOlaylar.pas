unit UOlaylar;

   //TUR : 1-Bilgi, 2-Uyarý, 3-Hata
   // KAYNAK : 1 : Sistem
   // KATEGORI : 1 Cari, 2 Kasa, 3 Banka, 4 Fatura, 5 ÇekSenet, 6 Stok, 7 Teklif


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, Menus, FireDAC.Comp.Client, StdCtrls, DBCtrls, Buttons, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls, cxImageComboBox,
  cxContainer, cxTextEdit, cxMemo, cxDBEdit, cxCheckBox, dxSkinsCore,
  dxSkinscxPCPainter, dxSkinLondonLiquidSky, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TOlaylarDlg = class(TForm)
    Panel2: TPanel;
    GridTakvim: TcxGrid;
    TakvimView: TcxGridDBTableView;
    cxGridLevel4: TcxGridLevel;
    Panel1: TPanel;
    KapatTus: TSpeedButton;
    DBNavigator1: TDBNavigator;
    DtsOlaylar: TDataSource;
    TabOlaylar: TFDQuery;
    PopupMenu1: TPopupMenu;
    BaslatMenu: TMenuItem;
    N1: TMenuItem;
    IslemBittiMenu: TMenuItem;
    N2: TMenuItem;
    TemditliYenileMenu: TMenuItem;
    N3: TMenuItem;
    VadeBozMenu: TMenuItem;
    cxgrdbclmnTakvimViewTUR: TcxGridDBColumn;
    cxgrdbclmnTakvimViewKAYNAK: TcxGridDBColumn;
    cxgrdbclmnTakvimViewMESAJ: TcxGridDBColumn;
    cxgrdbclmnTakvimViewDURUM: TcxGridDBColumn;
    cxgrdbclmnTakvimViewEKLEYEN: TcxGridDBColumn;
    cxgrdbclmnTakvimViewEKLEMETARIHI: TcxGridDBColumn;
    cxgrdbclmnTakvimViewDEGISTIREN: TcxGridDBColumn;
    cxgrdbclmnTakvimViewDEGISTIRMETARIHI: TcxGridDBColumn;
    akvimViewColumnKATEGORI: TcxGridDBColumn;
    TabMesaj: TFDQuery;
    DtsMesaj: TDataSource;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    cxMemo1: TcxDBMemo;
    cxDBMemo1: TcxDBMemo;
    Label1: TcxLabel;
    Label2: TcxLabel;
    cxCheckBox1: TcxCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure KapatTusClick(Sender: TObject);
    procedure DtsOlaylarStateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabOlaylarAfterScroll(DataSet: TDataSet);
    procedure cxCheckBox1PropertiesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OlaylarDlg: TOlaylarDlg;

implementation
  uses
 LocOnFly,PrjConst,utablo;
{$R *.dfm}

procedure TOlaylarDlg.cxCheckBox1PropertiesChange(Sender: TObject);
begin
    TabOlaylar.Close;
    TabOlaylar.SQL.Text := 'select * from OLAYLAR ';
    if not cxCheckBox1.Checked then
       TabOlaylar.SQL.Add(' where DURUM=1 ');
    TabOlaylar.SQL.Add(' order by ID desc');
    TabOlaylar.Open;
end;

procedure TOlaylarDlg.DtsOlaylarStateChange(Sender: TObject);
begin
 if DtsOlaylar.State in [dsEdit, dsInsert] then
    DBNavigator1.VisibleButtons := [nbPost, nbCancel]
  else
    DBNavigator1.VisibleButtons := [nbInsert, nbDelete];
end;

procedure TOlaylarDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
   OlaylarDlg := nil;
end;

procedure TOlaylarDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   cxCheckBox1PropertiesChange(Self);

   Tablo.GridTurkcelestir;

end;

procedure TOlaylarDlg.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure TOlaylarDlg.TabOlaylarAfterScroll(DataSet: TDataSet);
begin
   TabMesaj.Close;
   TabMesaj.Params[0].Value := TabOlaylar.FieldByName('MESAJ').AsInteger;
   TabMesaj.Open;
end;

end.



