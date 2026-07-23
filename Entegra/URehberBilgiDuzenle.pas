unit URehberBilgiDuzenle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxTextEdit, cxCheckBox, FireDAC.Comp.Client, FireDAC.Stan.Param, cxContainer, cxMemo,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ToolWin, ComCtrls, cxLabel,
  cxMaskEdit, cxDropDownEdit, cxDBEdit, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TRehberBilgiDuzenleDlg = class(TForm)
    ToolBar1: TToolBar;
    GridKurIlet: TcxGrid;
    GridDetayView: TcxGridDBTableView;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    GridDetayViewColumn1: TcxGridDBColumn;
    GridDetayViewColumnsec: TcxGridDBColumn;
    cxGridDetay: TcxGridLevel;
    SQLDetay: TcxMemo;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure cxGridDBColumn4GetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure FormShow(Sender: TObject);
    procedure GridDetayViewEditChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    EkleDetay:Boolean;
    { Private declarations }
  public
    Yeri,YerID:Integer;
    Bolum:String;
    { Public declarations }
  end;

var
  RehberBilgiDuzenleDlg: TRehberBilgiDuzenleDlg;

implementation

uses Utablo,UCariFonksiyonlar,UGirisKutusuEx,FetaKurulusSiniflari,PrjConst,LocOnFly, UVeriMotor, UDFMPG;

{$R *.dfm}

procedure TRehberBilgiDuzenleDlg.cxGridDBColumn4GetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
  Tablo.RepositorydenPropertyAl(AProperties);
end;

procedure TRehberBilgiDuzenleDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;
end;

procedure TRehberBilgiDuzenleDlg.FormShow(Sender: TObject);
begin
  EkleDetay:=False;
  TabDetay.Close;
  TabDetay.CachedUpdates := True;
  if AktifVeriMotor = vmPG then TabDetay.SQL.Text := SQL_PG_RehberDetay88
  else TabDetay.SQL.Text := StringReplace(SQLDetay.Text, ':SPID', IntToStr(SPID), [rfReplaceAll]);
  TabDetay.Params[0].Value := Yeri;
  TabDetay.Params[1].Value := YerID;
  TabDetay.Params[2].Value := Bolum;
  TabDetay.Open;
  EkleDetay:=False;
end;

procedure TRehberBilgiDuzenleDlg.GridDetayViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  Qry:TFDQuery;
  ctrls: TGirdiDenetimleri;
  sql: Variant;
begin
  if ACellViewInfo.Item.Index=0 then begin //tıklanan etiket mi
    Qry:=(Sender as TcxGridDBTableView).DataController.DataSource.DataSet as TFDQuery;
    if Trim(Qry.FieldByName('KAYNAK').AsString)<>'' then begin
      if Pos('select',LowerCase(Qry.FieldByName('KAYNAK').AsString))>0 then begin
        sql:=Qry.FieldByName('KAYNAK').AsString;
        ctrls := TGirdiDenetimleri.Create.Memo(Qry.FieldByName('ETIKET').AsString,@sql);
        if TGirisKutusuEx.BilgiAlEx(yenisorgugirin,ctrls) = mrOk then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERAYAR set KAYNAK=&Sql where ETIKET=&Etiket and GIRIS=&Giris  ',['&Sql','&Etiket','&Giris'],[sql,Qry.FieldByName('ETIKET').AsString,Qry.FieldByName('GIRIS').AsInteger]);
        end;
      end else if Qry.FieldByName('GIRIS').AsInteger in [4,6,8,9] then begin //combo
        Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and ANAHTAR='''+qry.FieldByName('KAYNAK').AsString+'''');
        Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger);

      end;
      Qry.Close;
      Qry.Open;
    end;
  end;

end;

procedure TRehberBilgiDuzenleDlg.GridDetayViewEditChanged(
  Sender: TcxCustomGridTableView; AItem: TcxCustomGridTableItem);
begin
  EkleDetay:=True;
end;

procedure TRehberBilgiDuzenleDlg.ToolButton1Click(Sender: TObject);
begin
  if EkleDetay then
     Ekle(TabDetay,Yeri,YerID,'Değiş');
  ModalResult := mrOk;
end;

procedure TRehberBilgiDuzenleDlg.ToolButton2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.








