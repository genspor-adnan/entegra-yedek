unit UCokluSecim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, StdCtrls, Buttons, ExtCtrls, FireDAC.Comp.Client ,UTablo, cxCheckBox, Menus, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TCokluSecimDlg = class(TForm)
    Panel1: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ADOQuery1: TFDQuery;
    DataSource1: TDataSource;
    cxGrid1DBTableView1SEC: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    mnSe1: TMenuItem;
    mnKaldr1: TMenuItem;
    SeimiTersevir1: TMenuItem;
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure mnSe1Click(Sender: TObject);
    procedure mnKaldr1Click(Sender: TObject);
    procedure SeimiTersevir1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CokluSecimDlg: TCokluSecimDlg;

implementation
   Uses LocOnFly;
{$R *.dfm}

procedure TCokluSecimDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TCokluSecimDlg.IptalTusClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCokluSecimDlg.KaydetTusClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TCokluSecimDlg.mnKaldr1Click(Sender: TObject);
begin
  if (ADOQuery1.Active)and(ADOQuery1.Recordcount>0) then begin
    ADOQuery1.First;
    while not ADOQuery1.eof do begin
      cxGrid1DBTableView1SEC.EditValue := False;
      ADOQuery1.Next;
    end;
  end;
end;

procedure TCokluSecimDlg.mnSe1Click(Sender: TObject);
begin
  if (ADOQuery1.Active)and(ADOQuery1.Recordcount>0) then begin
    ADOQuery1.First;
    while not ADOQuery1.eof do begin
      cxGrid1DBTableView1SEC.EditValue := True;
      ADOQuery1.Next;
    end;
  end;
end;

procedure TCokluSecimDlg.SeimiTersevir1Click(Sender: TObject);
begin
  if (ADOQuery1.Active)and(ADOQuery1.Recordcount>0) then begin
    ADOQuery1.First;
    while not ADOQuery1.eof do begin
      cxGrid1DBTableView1SEC.EditValue := not cxGrid1DBTableView1SEC.EditValue;
      ADOQuery1.Next;
    end;
  end;
end;

end.

