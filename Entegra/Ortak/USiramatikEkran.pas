unit USiramatikEkran;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, JvComponentBase, JvNavigationPane, ExtCtrls,
  jpeg, JvExExtCtrls, JvExtComponent, JvPanel,
  JvExControls, UTablo, GraphicEx, pngimage, UGenYanipSonenLabel;

type
  TSiramatik = class(TForm)
    Timer1: TTimer;
    PanelKayanyazi: TJvPanel;
    Label6: TLabel;
    LblPol: TLabel;
    PanelSiradaki: TJvNavPanelHeader;
    LblSiradakiHasta: TLabel;
    Image1: TImage;
    LblSirano: TGenYanipSonenPanel;
    LblHastaAdiSoyadi: TGenYanipSonenPanel;
    LblHastaDosyaNo: TGenYanipSonenPanel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelKayanYazipaint(Sender: TObject);
    procedure HastaGetir(Dosyano, Adsoyad, Sirano, SiradakiHasta: string);
    procedure TimerYeniHastaUyariTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerSiranoTimer(Sender: TObject);
    procedure PoliklinikDoktorGonder(Poliklinik, PolDoktor: string);
  private
    FPol: string;
    FDoktor: string;
    FHastaDosyano: string;
    FSiraNo: string;
    FHastaAdSoyad: string;
    FHastaSiradaki: string;
    FHastaSirano: string;
    FKayanYazi: string;
    procedure SetPol(const Value: string);
    procedure SetDoktor(const Value: string);
    procedure SetHastaDosyano(const Value: string);
    procedure SetHastaAdSoyad(const Value: string);
    procedure SetHastaSiradaki(const Value: string);
    procedure SetHastaSirano(const Value: string);
    procedure SetKayanYazi(const Value: string);

  published
    PanelUstBilgi: TJvNavPanelHeader;
    ImageLogo: TImage;
    PanelAna: TJvNavPanelHeader;
    JvNavPaneStyleManager1: TJvNavPaneStyleManager;
    ImageDoktor: TImage;
    LblDoktor: TLabel; 
    property Pol: string read FPol write SetPol;
    property Doktor: string read FDoktor write SetDoktor;
    property HastaDosyano: string read FHastaDosyano write SetHastaDosyano;
    property HastaAdSoyad: string read FHastaAdSoyad write SetHastaAdSoyad;
    property HastaSiradaki: string read FHastaSiradaki write SetHastaSiradaki;
    property HastaSirano: string read FHastaSirano write SetHastaSirano;
    property KayanYazi: string read FKayanYazi write SetKayanYazi;   
  private
    FCaption: string;
    procedure SetSadeceDurumGoster(const Value: string);
    { Private declarations }
  public
    YeniHastaUyariSayisi: integer;
    YeniHastaUyariYon: integer;
    { Public declarations }
    FAdimlar: Integer;
    FSimdikiPoz: Integer;
    constructor Create(AOwner: TComponent;EkranNo: Integer);
    property SadeceDurumGoster: string write SetSadeceDurumGoster;
  end;

var
  Siramatik: TSiramatik;

implementation
uses
  JvJVCLUtils, StrUtils, GDIPAPI,GDIPOBJ;
{$R *.dfm}

procedure TSiramatik.PanelKayanYazipaint(Sender: TObject);
var
  canv: TCanvas;
  bmp: TBitmap;
  r: TRect;
begin

  KayanYazi := RadyoIni.ReadString('GenelOpsiyon', 'KayanYazı', '');
  canv := PanelKayanyazi.Canvas;
  bmp := TBitmap.Create;
  bmp.Width := PanelKayanyazi.Width;
  bmp.Height := PanelKayanyazi.Height;
  bmp.Canvas.Font.Assign(PanelKayanyazi.Font);
  FAdimlar := bmp.Canvas.TextWidth(PanelKayanyazi.Caption) + bmp.Width;
  r := Rect(0, 0, bmp.Width, bmp.Height);
  GradientFillRect(bmp.Canvas, r, $00464646, clBlack, fdTopToBottom, 32);
  bmp.Canvas.Brush.Style := bsClear;
  bmp.Canvas.TextRect(r, bmp.Width - FSimdikiPoz, 13, PanelKayanyazi.Caption);
  PanelKayanyazi.Canvas.Draw(0, 0, bmp);
  bmp.Free;
end;

constructor TSiramatik.Create(AOwner: TComponent; EkranNo: Integer);
var
  mon : TMonitor;
begin
  inherited Create(AOwner);
  mon := Screen.Monitors[EkranNo];
  Left := mon.Left;
  Top := mon.Top;
  Width := mon.Width;
  Height := mon.Height;
  if FileExists(ExtractFilePath(ParamStr(0)) + 'sıramatik.png') then
    Image1.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'sıramatik.png');
end;

procedure TSiramatik.FormCreate(Sender: TObject);
begin

  FSimdikiPoz := 0;
  YeniHastaUyariYon := 2;

end;

procedure TSiramatik.Timer1Timer(Sender: TObject);
begin
  FSimdikiPoz := FSimdikiPoz + 5;
  if (FSimdikiPoz >= FAdimlar) then
    FSimdikiPoz := 0;
  //  PanelKayanyazi.Invalidate;
  PanelKayanYazipaint(nil);
end;

procedure TSiramatik.SetPol(const Value: string);
begin
  FPol := Value;
  LblPol.Caption := Value; 
end;

procedure TSiramatik.SetSadeceDurumGoster(const Value: string);
var
  G         : TGPGraphics;
  FontFamily: TGPFontFamily;
  Font1     : TGPFont;
  brush2    : TGPBrush;
  brushtr   : TGPBrush;
  bmp       : TPNGObject;
  r         : TGPRectF;
  xort      : Double;
  yort      : Double;
begin
  if Value <> '' then begin
    LblSirano.Visible := False;
    LblHastaAdiSoyadi.Visible := False;
    LblHastaDosyaNo.Visible := False;
    LblSiradakiHasta.Visible := False;

    bmp := TPNGObject.Create;
    bmp.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'sıramatik.png');
    G := TGPGraphics.Create(bmp.Canvas.Handle);
    FontFamily := TGPFontFamily.Create('Verdana');
    Font1 := TGPFont.Create(FontFamily, 70, FontStyleBold, UnitPixel);
    brush2 := TGPSolidBrush.Create(MakeColor(255,255,255));
    brushtr := TGPSolidBrush.Create(MakeColor(200,0,0,0));
    try
      g.FillRectangle(brushtr,0,0,bmp.Width,bmp.Height);
      g.MeasureString(Value,-1,Font1,MakePoint(1.0 * Width, 1.0* Height),r);
      xort := (Image1.Width / 2) - (r.Width / 2);
      yort := (Image1.Height / 2) - (r.Height / 2);
      G.DrawString(Value,Length(Value),Font1,MakePoint(xort,yort),brush2);
      Image1.Picture.Assign(bmp);
    finally
      G.Free;
      FontFamily.Free;
      Font1.Free;
      Brush2.Free;
      brushtr.Free;
      bmp.Free;
    end;
  end else begin
    LblSirano.Visible := True;
    LblHastaAdiSoyadi.Visible := True;
    LblHastaDosyaNo.Visible := True;
    LblSiradakiHasta.Visible := True;
    Image1.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'sıramatik.png');
  end;
end;

procedure TSiramatik.SetDoktor(const Value: string);
begin
  FDoktor := Value;
  LblDoktor.Caption := Value;
end;

procedure TSiramatik.SetHastaDosyano(const Value: string);
begin
  FHastaDosyano := Value;
  LblHastaDosyaNo.MetinDegistir := FHastaDosyano;
end;

procedure TSiramatik.SetHastaAdSoyad(const Value: string);
begin
  FHastaAdSoyad := Value;
  LblHastaAdiSoyadi.MetinDegistir := Value;
  //TimerYeniHastaUyari.Enabled := True;
end;

procedure TSiramatik.HastaGetir(Dosyano, Adsoyad, Sirano,
  SiradakiHasta: string);
begin
  HastaAdSoyad := Adsoyad;
  HastaDosyano := Dosyano;
  HastaSirano := Sirano;
  HastaSiradaki := SiradakiHasta;
  //
end;

procedure TSiramatik.SetHastaSiradaki(const Value: string);
begin
  FHastaSiradaki := Value;
  LblSiradakiHasta.Caption := Value;
end;

procedure TSiramatik.SetHastaSirano(const Value: string);
begin
  FHastaSirano := Value;
  LblSirano.Caption := FHastaSirano;
  LblSirano.Show;
end;

procedure TSiramatik.SetKayanYazi(const Value: string);
begin
  FKayanYazi := Value;
  PanelKayanyazi.Caption := FKayanYazi;
end;


procedure TSiramatik.TimerYeniHastaUyariTimer(Sender: TObject);
begin
  if YeniHastaUyariSayisi < 10 then
  begin
    LblHastaAdiSoyadi.Font.Size := LblHastaAdiSoyadi.Font.Size + YeniHastaUyariYon;
    if LblHastaAdiSoyadi.Font.Size >= 72 then
    begin
      YeniHastaUyariYon := -2;
    end;
    if LblHastaAdiSoyadi.Font.Size <= 36 then
    begin
      YeniHastaUyariYon := 2;
      inc(YeniHastaUyariSayisi);
    end;
  end else begin
    //TimerYeniHastaUyari.Enabled := False;
    YeniHastaUyariSayisi := 10;
  end;
end;

procedure TSiramatik.FormShow(Sender: TObject);
var
  Logoyolu, DoktorResimYolu: string;
begin
  YeniHastaUyariSayisi := 0;
  Logoyolu := GenotipIni.ReadString('GenelOpsiyon', 'LogoYolu', '', True);
  DoktorResimYolu := GenotipIni.ReadString('GenelOpsiyon', 'DoktorResimYolu', '', True);
  if DoktorResimYolu <> '' then
  begin
    try
      ImageDoktor.Picture.LoadFromFile(IncludeTrailingBackslash(DoktorResimYolu) + DoktorAdi + '.bmp');
    except
    end;
  end;
  if Logoyolu <> '' then
  begin
    try
      ImageLogo.Picture.LoadFromFile(IncludeTrailingBackslash(Logoyolu) + 'KurumLogo.bmp');
    except
    end;
  end;

end;

procedure TSiramatik.TimerSiranoTimer(Sender: TObject);
var
  Zaman: Integer;
begin

  if YeniHastaUyariSayisi < 10 then
  begin
    if LblSirano.Transparent then
    begin
      LblSirano.Transparent := False;
      LblSirano.Font.Color := clWhite;
      LblHastaDosyaNo.Transparent := True;
      LblHastaDosyaNo.Font.Color := clNavy;
    end
    else
    begin
      LblSirano.Transparent := True;
      LblSirano.Font.Color := clRed;
      LblHastaDosyaNo.Transparent := False;
      LblHastaDosyaNo.Font.Color := clWhite;
    end;
    inc(YeniHastaUyariSayisi)
  end
  else
  begin
    //TimerSirano.Enabled := False;
    LblSirano.Transparent := False;
    YeniHastaUyariSayisi := 0;
    Zaman := 0;
  end

end;

procedure TSiramatik.PoliklinikDoktorGonder(Poliklinik, PolDoktor: string);
begin

  Pol := Poliklinik;
  Doktor := PolDoktor;

end;

end.

