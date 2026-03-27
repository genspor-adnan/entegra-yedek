unit UDokumAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 18/01/2010 14:17:46}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, CategoryButtons, ImgList, DB,
  UFrameYoneticisi;

type
  TDokumAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    dokumListesi: TCategoryButtons;
    procedure dokumListesiButtonClicked(Sender: TObject;
      const Button: TButtonItem);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    FDokumEkranAdi : string;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);

    procedure YerBilgileriniTemizle(ACategory : TButtonCategory);
    procedure TumYerBilgileriniTemizle;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure DokumleriYerlestir(ADokumEkranAdi : string = '';Stndrt:smallint=1;Durum:smallint=9);
  end;

implementation

uses  Utablo, UDokum, UMultiDataSetEvent, FetaClassExtensions,LocOnFly;

{$R *.dfm}

type
  PYerBilgisi = ^TYerBilgisi;
  TYerBilgisi = record
    RaporAdi : ShortString;
  end;


{ TDokumAramaFrame }

procedure TDokumAramaFrame.Baslatildi;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

constructor TDokumAramaFrame.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TDokumAramaFrame.Destroy;
begin
  TumYerBilgileriniTemizle;
  dokumListesi.Categories.Clear;

  inherited;
end;



procedure TDokumAramaFrame.DokumleriYerlestir(ADokumEkranAdi : string; Stndrt, Durum:smallint);
var
  genelKat : TButtonCategory;
  idx      : Integer;
  Tamam    : Boolean;
  yb       : PYerBilgisi;
begin
  if ADokumEkranAdi <> '' then
     FDokumEkranAdi := ADokumEkranAdi;
  TumYerBilgileriniTemizle;
  dokumListesi.Categories.Clear;
  genelKat := dokumListesi.Categories.Add;
  genelKat.Caption := 'Genel';
  genelKat.GradientColor := $004080FF;
  genelKat.Color := clWhite;
  genelKat.Collapsed := True;
  with (FFramebilgi.IcerikFrameYoneticisi.FrameBul(TDokumDlg).Baslat.Ornek as TDokumDlg) do begin
    DokumTabloAc(ADokumEkranAdi, Stndrt, Durum);
  end;

  with (FFramebilgi.IcerikFrameYoneticisi.FrameBul(TDokumDlg).Ornek as TDokumDlg).TabDokum.CloneThis do
  try
    open;
    if eof then   //Eðer tablo boþsa sayfayý direk açsýn
       with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TDokumDlg).Git.Ornek as TDokumDlg do
         DtsDokumler.DataSet := TabDokum
    else begin
      while not Eof do
      begin
        Tamam := True;

          if FieldByName('GRUBU').AsString = '' then
            with genelKat.Items.Add do begin
              Caption := FieldByName('RAPORADI').AsString;
              New(yb);
              Data := yb;
              yb^.RaporAdi := Caption;
              ImageIndex := 0;
            end
          else
          begin
            idx := dokumListesi.Categories.IndexOf(FieldByName('GRUBU').AsString);
            if idx <> -1 then begin
              with dokumListesi.Categories[idx].Items.Add do begin
                Caption := FieldByName('RAPORADI').AsString;
                ImageIndex := 0;
                New(yb);
                Data := yb;
                yb^.RaporAdi := Caption;
              end;
            end else begin
              with dokumListesi.Categories.Add do begin
                Caption := FieldByName('GRUBU').AsString;
                GradientColor := $004080FF;
                Color := clWhite;
                Collapsed := True;
                with Items.Add do begin
                  Caption := FieldByName('RAPORADI').AsString;
                  New(yb);
                  Data := yb;
                  yb^.RaporAdi := Caption;
                  ImageIndex := 0;
                end;
              end;
            end;
          end;
        Next;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TDokumAramaFrame.dokumListesiButtonClicked(Sender: TObject;
  const Button: TButtonItem);
begin
  with FFrameBilgi.IcerikFrameYoneticisi.FrameBul(TDokumDlg).Git.Ornek as TDokumDlg do begin
    DtsDokumler.DataSet := TabDokum;
    TabDokum.Locate('RAPORADI',PYerBilgisi(Button.Data)^.RaporAdi,[]);
  end;
end;



procedure TDokumAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDokumAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumAramaFrame.Gorunmez;
begin

end;

procedure TDokumAramaFrame.GorunmezOlacak;
begin

end;

procedure TDokumAramaFrame.Gorunur;
begin

end;

procedure TDokumAramaFrame.GorunurOlacak;
begin

end;

procedure TDokumAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumAramaFrame.TumYerBilgileriniTemizle;
var
  i : Integer;
begin
  for I := 0 to dokumListesi.Categories.Count - 1 do
    YerBilgileriniTemizle(dokumListesi.Categories[i]);
end;

procedure TDokumAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDokumAramaFrame.YerBilgileriniTemizle(ACategory : TButtonCategory);
var
  i : Integer;
  p : PYerBilgisi;
begin
  for I := 0 to ACategory.Items.Count - 1 do begin
    p := ACategory.Items[i].Data;
    if Assigned(p) then
      Dispose(p);
    ACategory.Items[i].Data := nil;
  end;
end;

initialization
  RegisterClass(TDokumAramaFrame);
end.
