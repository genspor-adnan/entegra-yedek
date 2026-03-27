unit USonlandir;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxSchedulerStorage,
  cxSchedulerCustomControls, cxSchedulerDateNavigator, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxContainer, cxEdit, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, cxDropDownEdit,
  cxSpinEdit, cxTimeEdit, cxLabel, cxTextEdit, cxMaskEdit, cxImageComboBox,
  cxDateNavigator, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TSonlandirDlg = class(TForm)
    Panel2: TPanel;
    dateBaslama: TcxDateNavigator;
    DateBitis: TcxDateNavigator;
    ComboSonuc: TcxImageComboBox;
    cxLabel1: TcxLabel;
    TimeBaslama: TcxTimeEdit;
    TimeBitis: TcxTimeEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    ComboGun: TcxComboBox;
    cxLabel5: TcxLabel;
    ComboSaat: TcxComboBox;
    cxLabel6: TcxLabel;
    ComboDakika: TcxComboBox;
    cxLabel7: TcxLabel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure dateBaslamaClick(Sender: TObject);
    procedure DateBitisClick(Sender: TObject);
    procedure ComboDakikaPropertiesCloseUp(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SonlandirDlg: TSonlandirDlg;

implementation

{$R *.dfm}
uses UTablo, DateUtils, prjconst;

procedure TSonlandirDlg.ComboDakikaPropertiesCloseUp(Sender: TObject);
var ToplamTarih:TDateTime;
begin
   ToplamTarih := Datebaslama.Date + Timebaslama.Time;
   ToplamTarih := IncDay(ToplamTarih, StrToIntDef(ComboGun.Text, 0));
   ToplamTarih := IncHour(ToplamTarih, StrToIntDef(ComboSaat.Text, 0));
   ToplamTarih := IncMinute(ToplamTarih, StrToIntDef(ComboDakika.Text, 0));
   DateBitis.Date := ToplamTarih;
   TimeBitis.Time := StrTotime(FormatdateTime('hh:nn:ss', ToplamTarih));
end;

procedure TSonlandirDlg.dateBaslamaClick(Sender: TObject);
begin
   if DateBitis.Date < Datebaslama.Date then
      DateBitis.Date := Datebaslama.Date;
   DateBitisClick(Self);
end;

procedure TSonlandirDlg.DateBitisClick(Sender: TObject);
var a:string;
begin      // 001g 00s 00d
   Tablo.TablodanSorguAc(1,' select dbo.fn_TarihFarkiFormatli('''+FormatDateTime('yyyy-mm-dd hh:nn:ss', dateBaslama.Date+TimeBaslama.Time)+''','''+
         FormatDateTime('yyyy-mm-dd hh:nn:ss', DateBitis.Date+TimeBitis.Time)+''')');
   a:=Tablo.Query1.Fields[0].AsString;
   ComboGun.Text := copy(a,1,3);
   ComboSaat.Text:=copy(a,6,2);
   ComboDakika.Text:=copy(a,10,2);

end;

procedure TSonlandirDlg.IptalTusClick(Sender: TObject);
begin
   ModalResult:=mrCancel;
end;

procedure TSonlandirDlg.KaydetTusClick(Sender: TObject);
begin
   ModalResult:=mrOK;
end;

end.
