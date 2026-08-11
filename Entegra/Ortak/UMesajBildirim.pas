unit UMesajBildirim;
{
  Sag alt kosede acilan kucuk mesaj bildirimi ("toast").

  - Windows tepsi balonu DEGIL: kendi formumuz; yazi tipi/renk uygulamayla ayni
    olsun ve TIKLAYINCA ilgili sohbeti acabilelim diye.
  - Birden fazla bildirim ust uste YIGILIR (en yenisi altta).
  - Belirtilen sure sonunda kendiliginden kapanir; fare uzerindeyken kapanmaz.
  - SES burada CALINMAZ - cagiran karar verir (sessize alinan sohbetler icin
    bildirim gorunur ama ses cikmaz; bkz. UAnaForm.MesajSayiYaz / "Sesli").

  Kullanim:
    MesajBildirimGoster('Ahmet Yılmaz', 'Toplantı 15:00''e alındı', 12, BildirimTiklandi);
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons;

type
  // Bildirime tiklaninca cagrilir; AKanalId = ilgili sohbet
  TBildirimTiklamaOlayi = procedure(AKanalId: Integer) of object;

  TMesajBildirimFormu = class(TForm)
  private
    FKanalId: Integer;
    FTikla: TBildirimTiklamaOlayi;
    FZaman: TTimer;
    FKalanMs: Integer;
    FBaslik: TLabel;
    FMetin: TLabel;
    FKapat: TSpeedButton;
    procedure ZamanTik(Sender: TObject);
    procedure GovdeyeTikla(Sender: TObject);
    procedure KapatTikla(Sender: TObject);
    procedure FareGirdi(Sender: TObject);
    procedure FareCikti(Sender: TObject);
  protected
    // Alan bildirimleri metotlardan ONCE gelmeli (E2169) -> ayri bolum
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Olustur(const ABaslik, AMetin: string; AKanalId: Integer;
      ATikla: TBildirimTiklamaOlayi; ASureMs: Integer); reintroduce;
    destructor Destroy; override;
  end;

// Bildirim gosterir. ASureMs = ekranda kalma suresi (varsayilan 6 sn).
procedure MesajBildirimGoster(const ABaslik, AMetin: string; AKanalId: Integer;
  ATikla: TBildirimTiklamaOlayi = nil; ASureMs: Integer = 6000);

// Acik tum bildirimleri kapatir (or. mesajlasma ekrani acilinca).
procedure MesajBildirimleriKapat;

implementation

var
  GAcikBildirimler: TList = nil;   // ekranda duran formlar (yiginlama icin)

const
  CGenislik = 320;
  CYukseklik = 84;
  CBosluk = 8;

procedure Yerlestir;
// Acik bildirimleri sag alta, alttan yukari dogru dizer.
var
  i, LAlt: Integer;
  LF: TMesajBildirimFormu;
  LAlan: TRect;
begin
  if GAcikBildirimler = nil then Exit;
  LAlan := Screen.WorkAreaRect;                 // gorev cubugunu ortmesin
  LAlt := LAlan.Bottom - CBosluk;
  for i := GAcikBildirimler.Count - 1 downto 0 do
  begin
    LF := TMesajBildirimFormu(GAcikBildirimler[i]);
    LF.Left := LAlan.Right - CGenislik - CBosluk;
    LF.Top := LAlt - LF.Height;
    Dec(LAlt, LF.Height + CBosluk);
  end;
end;

{ TMesajBildirimFormu }

procedure TMesajBildirimFormu.CreateParams(var Params: TCreateParams);
// Gorev cubugunda GORUNMESIN ve odagi CALMASIN: arac penceresi + NOACTIVATE.
//   (ShowInTaskBar/TShowInTaskbar bu birimde gorunmuyor; dogrusu zaten pencere
//     stilini dogrudan vermek.)
begin
  inherited   CreateParams(Params);
  Params.ExStyle  := Params.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;
  Params.WndParent := 0;
end;


constructor TMesajBildirimFormu.Olustur(const ABaslik, AMetin: string; AKanalId: Integer;
  ATikla: TBildirimTiklamaOlayi; ASureMs: Integer);
begin
  inherited CreateNew(Application);
  FKanalId := AKanalId;
  FTikla := ATikla;
  FKalanMs := ASureMs;

  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  Position := poDesigned;
  Width := CGenislik;
  Height := CYukseklik;
  Color := $00FFFFFF;

  // Ince cerceve hissi: kenarlik yerine renkli sol serit
  with TShape.Create(Self) do
  begin
    Parent := Self;
    Align := alLeft;
    Width := 4;
    Brush.Color := $004CAF25;                   // WhatsApp yesili
    Pen.Style := psClear;
  end;

  FBaslik := TLabel.Create(Self);
  FBaslik.Parent := Self;
  FBaslik.SetBounds(14, 10, CGenislik - 44, 18);
  FBaslik.Font.Name := 'Segoe UI';
  FBaslik.Font.Size := 10;
  FBaslik.Font.Style := [fsBold];
  FBaslik.Font.Color := $00202020;
  FBaslik.Caption := ABaslik;
  FBaslik.Cursor := crHandPoint;
  FBaslik.OnClick := GovdeyeTikla;

  FMetin := TLabel.Create(Self);
  FMetin.Parent := Self;
  FMetin.SetBounds(14, 32, CGenislik - 28, 44);
  FMetin.AutoSize := False;
  FMetin.WordWrap := True;
  FMetin.Font.Name := 'Segoe UI';
  FMetin.Font.Size := 9;
  FMetin.Font.Color := $00505050;
  FMetin.Caption := AMetin;
  FMetin.Cursor := crHandPoint;
  FMetin.OnClick := GovdeyeTikla;

  FKapat := TSpeedButton.Create(Self);
  FKapat.Parent := Self;
  FKapat.Flat := True;
  FKapat.SetBounds(CGenislik - 26, 6, 20, 20);
  FKapat.Font.Name := 'Segoe UI';
  FKapat.Font.Size := 10;
  FKapat.Caption := #$00D7;
  FKapat.OnClick := KapatTikla;

  OnClick := GovdeyeTikla;
  OnMouseEnter := FareGirdi;
  OnMouseLeave := FareCikti;

  FZaman := TTimer.Create(Self);
  FZaman.Interval := 200;
  FZaman.OnTimer := ZamanTik;
  FZaman.Enabled := True;

  if GAcikBildirimler = nil then GAcikBildirimler := TList.Create;
  GAcikBildirimler.Add(Self);
  Yerlestir;

  // Odagi CALMADAN goster: kullanici yazarken bildirimin klavyeyi almamasi sart
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  Visible := True;
end;

destructor TMesajBildirimFormu.Destroy;
begin
  if GAcikBildirimler <> nil then
  begin
    GAcikBildirimler.Remove(Self);
    Yerlestir;
  end;
  inherited;
end;

procedure TMesajBildirimFormu.ZamanTik(Sender: TObject);
begin
  Dec(FKalanMs, FZaman.Interval);
  if FKalanMs <= 0 then
  begin
    FZaman.Enabled := False;
    Release;                                   // olay icinde Free etme
  end;
end;

procedure TMesajBildirimFormu.FareGirdi(Sender: TObject);
begin
  FZaman.Enabled := False;                     // fare ustundeyken kapanmasin
end;

procedure TMesajBildirimFormu.FareCikti(Sender: TObject);
begin
  if FKalanMs < 1500 then FKalanMs := 1500;    // okumaya firsat
  FZaman.Enabled := True;
end;

procedure TMesajBildirimFormu.GovdeyeTikla(Sender: TObject);
var
  LTikla: TBildirimTiklamaOlayi;
  LKanal: Integer;
begin
  LTikla := FTikla;
  LKanal := FKanalId;
  FZaman.Enabled := False;
  Release;
  if Assigned(LTikla) then LTikla(LKanal);
end;

procedure TMesajBildirimFormu.KapatTikla(Sender: TObject);
begin
  FZaman.Enabled := False;
  Release;
end;

procedure MesajBildirimGoster(const ABaslik, AMetin: string; AKanalId: Integer;
  ATikla: TBildirimTiklamaOlayi; ASureMs: Integer);
begin
  // Ekrani doldurmasin: en fazla 3 bildirim dursun, en eskisi kapansin
  while (GAcikBildirimler <> nil) and (GAcikBildirimler.Count >= 3) do
    TMesajBildirimFormu(GAcikBildirimler[0]).Release;

  TMesajBildirimFormu.Olustur(ABaslik, AMetin, AKanalId, ATikla, ASureMs);
end;

procedure MesajBildirimleriKapat;
var
  i: Integer;
begin
  if GAcikBildirimler = nil then Exit;
  for i := GAcikBildirimler.Count - 1 downto 0 do
    TMesajBildirimFormu(GAcikBildirimler[i]).Release;
end;

initialization

finalization
  if GAcikBildirimler <> nil then
  begin
    GAcikBildirimler.Free;
    GAcikBildirimler := nil;
  end;

end.
