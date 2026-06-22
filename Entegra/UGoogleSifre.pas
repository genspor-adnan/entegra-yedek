unit UGoogleSifre;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, cxLabel, cxTextEdit, Data.DB, FireDAC.Comp.Client, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, JvDialogs, cxDBEdit;

type
  TGoogleSifreDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    dtsGoogle: TDataSource;
    tabGoogle: TFDQuery;
    EditGOOGLETAKVIMID: TcxDBTextEdit;
    cxLabel1: TcxLabel;
    EditGOOGLEKULADI: TcxDBTextEdit;
    cxLabel2: TcxLabel;
    EditGOOGLESIFRE: TcxDBTextEdit;
    cxLabel3: TcxLabel;
    BitBtn1: TBitBtn;
    JvOpenDialog1: TJvOpenDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tabGoogleNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    RehberID : integer;
  end;

var
  GoogleSifreDlg: TGoogleSifreDlg;

implementation

uses UTablo;

{$R *.dfm}

procedure TGoogleSifreDlg.BitBtn1Click(Sender: TObject);
var
 dosyaadi :string;
 p12stream : TMemoryStream;
begin
try
  p12stream:= TMemoryStream.Create;
  if JvOpenDialog1.Execute then
   begin
      tabGoogle.Edit;
      TBlobField(tabGoogle.FieldByName('GOOGLEP12DOSYA')).LoadFromFile(JvOpenDialog1.FileName);
      tabGoogle.Post;
   end;
finally
  p12stream.Free;
end;
end;

procedure TGoogleSifreDlg.CancelBtnClick(Sender: TObject);
begin
   tabGoogle.Cancel;
   Close;
end;

procedure TGoogleSifreDlg.FormShow(Sender: TObject);
begin
   TabloYenile(tabGoogle,[RehberID])
end;

procedure TGoogleSifreDlg.KaydetTusClick(Sender: TObject);
begin
    tabGoogle.Post;
    Close;
end;

procedure TGoogleSifreDlg.tabGoogleNewRecord(DataSet: TDataSet);
begin
   tabGoogle.FieldByName('REHBERID').asinteger := RehberId;
end;

end.

