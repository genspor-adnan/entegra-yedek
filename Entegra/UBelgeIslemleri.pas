unit UBelgeIslemleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Utablo, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, FireDAC.Comp.Client, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin,UBinarySave,PrjConst,
  dxSkinLondonLiquidSky,ZLIBEX, cxLookAndFeels, cxLookAndFeelPainters,
  cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TBelgeIslemleriDlg = class(TForm)
    ToolBar1: TToolBar;
    BelgeEkleTus: TToolButton;
    BelgeSilTus: TToolButton;
    BelgeGorTus: TToolButton;
    GridBelgeDBTableViewImaj: TcxGridDBTableView;
    GridBelgeLevel1: TcxGridLevel;
    GridBelge: TcxGrid;
    TabImaj: TFDQuery;
    DtsImaj: TDataSource;
    GridBelgeDBTableViewImajBELGEADI: TcxGridDBColumn;
    GridBelgeDBTableViewImajTUR: TcxGridDBColumn;
    GridBelgeDBTableViewImajBELGE: TcxGridDBColumn;
    GridBelgeDBTableViewImajACIKLAMA: TcxGridDBColumn;
    OpenDialog1: TOpenDialog;
    ToolButton2: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SaveDialog1: TSaveDialog;
    procedure BelgeEkleTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DtsImajStateChange(Sender: TObject);
    procedure BelgeSilTusClick(Sender: TObject);
    procedure BelgeGorTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure GridBelgeDBTableViewImajDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Yeri:  SmallInt;
    Yer_ID : Integer;
  end;

var
  BelgeIslemleriDlg: TBelgeIslemleriDlg;

implementation
  Uses LocOnFly;

{$R *.dfm}

procedure TBelgeIslemleriDlg.BelgeEkleTusClick(Sender: TObject);
var
 // FS: TFileStream;
  str : string;
begin
   if OpenDialog1.Execute then begin
      Tablo.Query1.Close;
      Str := ExtractFileName(OpenDialog1.FileName);
      //bELGENÝN ÝÇERÝÐÝ KutugeYaz proceduru içinde dolduruluyor
      Tablo.Query1.SQL.Text:= ' INSERT INTO IMAJ (YERI,YER_ID,BELGEADI,BELGE,EKLEYEN,SUBEID) '+
      'VALUES('''+IntToStr(Yeri)+''','+IntToStr(Yer_ID)+','''+STR+''',:PBELGE,'''+Kullanan+''','+IntToStr(SubeId)+')';
      KutugeYaz(Tablo.Query1, OpenDialog1.FileName);
      TabImaj.Close;
      TabImaj.Open;
   end;
end;

procedure TBelgeIslemleriDlg.BelgeGorTusClick(Sender: TObject);
begin
   KutuktenOku(TabImaj,'BELGE', 'BELGEADI', True);
end;

procedure TBelgeIslemleriDlg.BelgeSilTusClick(Sender: TObject);
begin
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
  TabImaj.Delete;
end;
end;

procedure TBelgeIslemleriDlg.DtsImajStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsImaj.State = dsEdit;
   IptalTus.visible := DtsImaj.State = dsEdit;
   BelgeEkleTus.visible := DtsImaj.State <> dsEdit;
   BelgeSilTus.visible := DtsImaj.State <> dsEdit;
   BelgeGorTus.visible := DtsImaj.State <> dsEdit;
end;

procedure TBelgeIslemleriDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  Tablo.GridTurkcelestir;

end;

procedure TBelgeIslemleriDlg.FormShow(Sender: TObject);
begin
  TabImaj.DisableControls;
  TabImaj.Close;
  TabImaj.Params[0].Value := Yeri;
  TabImaj.Params[1].Value := Yer_ID;
  TabImaj.Open;
  TabImaj.EnableControls;
end;

procedure TBelgeIslemleriDlg.GridBelgeDBTableViewImajDblClick(Sender: TObject);
var
  Stream_ : TStream;
  tempfile : TFileStream;
  fs : TMemoryStream;
begin
  Stream_ := TStream.Create;
  fs := TMemoryStream.Create;
  Stream_:= TabImaj.CreateBlobStream(TabImaj.FieldByName('BELGE'), bmRead);
  Stream_.Position:=0;
  //fs.Position:=0;
  ZDecompressStream( Stream_,fs);
  fs.Position:=0;
  SaveDialog1.Title := 'Belge Kaydetme';
  SaveDialog1.DefaultExt := ExtractFileExt(TabImaj.FieldByName('BELGEADI').AsString);
  SaveDialog1.Filter:=ExtractFileExt(TabImaj.FieldByName('BELGEADI').AsString)+' dosyasý'+'|*'+ExtractFileExt(TabImaj.FieldByName('BELGEADI').AsString);
  SaveDialog1.InitialDir := GetEnvironmentVariable('%USERPROFILE%')+'\Desktop';
  SaveDialog1.FileName := ExtractFileName(TabImaj.FieldByName('BELGEADI').AsString);
  if SaveDialog1.Execute then begin
    try
      try
        tempfile:= TFileStream.Create(SaveDialog1.FileName, fmCreate );
        tempfile.CopyFrom( fs, fs.Size  );
      except
        on EInOutError do
          MessageDlg('File I/O error.', mtError, [mbOk], 0);
      end;
    finally
      fs.Free;
      Stream_.Free;
      tempfile.Free;
    end;
  end;
end;

procedure TBelgeIslemleriDlg.IptalTusClick(Sender: TObject);
begin
  TabImaj.Cancel;
end;

procedure TBelgeIslemleriDlg.KaydetTusClick(Sender: TObject);
begin
  TabImaj.post;
end;

end.





