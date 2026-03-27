unit UTalimatOnay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, StdCtrls, ExtCtrls, cxGridLevel, cxClasses, cxControls,ShellAPI,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid,Utablo,UAnaForm, UFDCompatHelpers, DBCtrls, JvDBImage, cxContainer, cxLabel,
  cxDBLabel, cxCurrencyEdit,UBinarySave, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, cxNavigator;

type
  TTalimatOnayDlg = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    BtnOnay: TButton;
    BtnRet: TButton;
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
    TabOzet: TFDQuery;
    DtsOzet: TDataSource;
    cxDBLabel3: TcxDBLabel;
    cxDBLabel4: TcxDBLabel;
    cxDBLabel6: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    cxGrid1DBTableView1FIRMA: TcxGridDBColumn;
    cxGrid1DBTableView1ALACAK: TcxGridDBColumn;
    cxGrid1DBTableView1KUR: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    Panel3: TPanel;
    cxDBLabel1: TcxDBLabel;
    cxDBLabel5: TcxDBLabel;
    JvDBImage1: TJvDBImage;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel7: TcxDBLabel;
    cxDBLabel8: TcxDBLabel;
    BtnBelge: TButton;
    LabelParmakIzi: TcxLabel;
    procedure BtnOnayClick(Sender: TObject);
    procedure BtnRetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnBelgeClick(Sender: TObject);
  private
    { Private declarations }
  public
  AktiviteID:Integer;
    { Public declarations }
  end;

var
  TalimatOnayDlg: TTalimatOnayDlg;

implementation

{$R *.dfm}

procedure TTalimatOnayDlg.BtnOnayClick(Sender: TObject);
begin
(*  Aktivite_Durum	37871	Plan	0
    Aktivite_Durum	37872	Yeni	1
    Aktivite_Durum	37873	Ertelendi	2
    Aktivite_Durum	37874	Devam Ediyor	3
    Aktivite_Durum	37875	Ýptal	4
    Aktivite_Durum	37876	Tamamlandý	9  *)
  Tablo.TalimatSureciDegistir(AktiviteID,9);
  ModalResult:=mrOk;
end;

procedure TTalimatOnayDlg.BtnRetClick(Sender: TObject);
begin
  Tablo.TalimatSureciDegistir(AktiviteID,4);
  ModalResult:=mrAbort;
end;

procedure TTalimatOnayDlg.BtnBelgeClick(Sender: TObject);
var
  Stream_ :TStream;
  tempfile : TFileStream;
begin
  Tablo.TablodanSorguAc(1,'SELECT * from TALIMATBELGELER where TALIMATID='+TabOzet.FieldByName('TALIMATID').AsString+' order by ID desc');

  Stream_ := TStream.Create;
  Stream_:= Tablo.Query1.CreateBlobStream(Tablo.Query1.FieldByName('BELGE'), bmRead);
  Stream_.Position:=0;
  tempfile:= TFileStream.Create(GetEnvironmentVariable('Temp')+'\'+Tablo.Query1.FieldByName('BELGEADI').AsString, fmCreate );
  tempfile.CopyFrom( Stream_, Stream_.Size  );
  Stream_.Free;
  tempfile.Free;
  ShellExecute(0,'open',pchar(GetEnvironmentVariable('Temp')+'\'+Tablo.Query1.FieldByName('BELGEADI').AsString),nil,nil,SW_SHOWNORMAL);

  //KutuktenOku(Tablo.Query1,'BELGE','BELGEADI');
end;

procedure TTalimatOnayDlg.FormShow(Sender: TObject);
Var
  TalimatID,Tur:Integer;
begin
  Tablo.TablodanSorguAc(2,'Select * from AKTIVITELER where ID='+inttostr(AktiviteID));
  TalimatID:=Tablo.Query2.FieldByName('TALIMATID').AsInteger;
  Tur:= Tablo.Query2.FieldByName('TURU').AsInteger;
  case Tur of
    -1: begin //onay süreci
          BtnOnay.Caption:='Onay';
          BtnRet.Caption:='Ret';
        end;
    -2: begin //imza süreci
          BtnOnay.Caption:='Ýmza';
          BtnRet.Caption:='Ret';
        end;
    -3: begin //Gönderim Süreci
          BtnOnay.Caption:='Gönder';
          BtnRet.Caption:='Ýptal';
        end;
    -4: begin //Gönderim Süreci
          BtnOnay.Caption:='Akýbet Al';
          BtnRet.Caption:='Ýptal';
        end;
  end;
  TabOzet.Close;
  TabOzet.Parameters[0].Value:=TalimatID;
  TabOzet.Open;
  TabKasa.Close;
  TabKasa.Parameters[0].Value:=TalimatID;
  TabKasa.Open;
end;

end.


