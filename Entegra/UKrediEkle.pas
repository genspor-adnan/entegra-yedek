unit UKrediEkle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, cxControls, cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit,
  ComCtrls, StdCtrls, dxSkinsCore, dxSkinLondonLiquidSky, cxLabel, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, dxCore, cxDateUtils, cxMaskEdit,
  cxDropDownEdit, cxCalendar, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TKrediEkleDlg = class(TForm)
    Label8: TcxLabel;
    Label9: TcxLabel;
    Label10: TcxLabel;
    Label11: TcxLabel;
    EditRef: TcxTextEdit;
    EditAcik: TcxTextEdit;
    EditTutar: TcxCurrencyEdit;
    KapatTus: TSpeedButton;
    SpeedButton1: TSpeedButton;
    DateTimePickerOdemeBasl: TcxDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure EditRefExit(Sender: TObject);
  private
    { Private declarations }
  public
      KrediID:Integer;
    { Public declarations }
  end;

var
  KrediEkleDlg: TKrediEkleDlg;

implementation

uses Utablo,PrjConst,LocOnFly;
{$R *.dfm}

procedure TKrediEkleDlg.EditRefExit(Sender: TObject);
begin
   EditAcik.Text := EditRef.Text + ' Ref. Nolu Alýnan kredi '
end;

procedure TKrediEkleDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   DateTimePickerOdemeBasl.Date := Tablo.GENINI.BugunTrhSaat;
end;

procedure TKrediEkleDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
   Close;
end;

procedure TKrediEkleDlg.SpeedButton1Click(Sender: TObject);
begin
   if not BoslukKontrol(EditRef.Text, 'Referans No') then begin EditRef.SetFocus; Abort; end ;
   if not BoslukKontrol(EditTutar.Text, 'Tutar') then  begin EditTutar.SetFocus;Abort; end ;
   if not BoslukKontrol(EditAcik.Text, 'Açýklama') then begin EditAcik.SetFocus; Abort; end ;

   Tablo.TablodanSorguAc(1,'select KREDIREFERANSNO from KREDIROTATIF where KREDIID='+IntToStr(KrediID)+' and KREDIREFERANSNO='''+EditRef.Text+'''');
   if Tablo.Query1.RecordCount > 0 then
      raise Exception.Create(BYapilmis_islem);
   ModalResult := mrOk;
end;

end.
