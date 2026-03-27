unit UBankaKredileriListeTanimlariFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 05/01/2010 09:06:08}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  CategoryButtons, ExtCtrls, ImgList, PngImageList, dxSkinsCore, dxSkinLondonLiquidSky, cxLabel;

type
  TBankaKredileriListeTanimlariFrame = class(TFrame,IAramaBilgiFrame)
    KredilerMenu: TCategoryButtons;

    procedure KredilerMenuCategories0Items0Click(Sender: TObject);
    procedure KredilerMenuCategories0Items1Click(Sender: TObject);
    procedure KredilerMenuCategories1Items1Click(Sender: TObject);
    procedure KredilerMenuCategories1Items3Click(Sender: TObject);
    procedure KredilerMenuCategories1Items4Click(Sender: TObject);
    procedure KredilerMenuCategories1Items0Click(Sender: TObject);
    procedure KredilerMenuCategories2Items0Click(Sender: TObject);
   private
    { Private declarations }
    FFrameBilgi: TAramaFrameBilgi;
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
    procedure SetFrameBilgi(AValue: TAramaFrameBilgi);
    function GetFrameBilgi : TAramaFrameBilgi;
 public
    { Public declarations }
      published
    property FrameBilgi : TAramaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UBankaKredileriListeFrame, UTeminatMektuplariListeFrame,UPOSListeFrame, UKrediKartiListeFrame,
  UVadeliHesaplarListeFrame,  UDokumGirisFrame,UGenelGirisSayfasiFrame,FetaKurulusSiniflari,//, UBankaCekleriListeFrame,
  UDBSListeFrame, UBankalarListeFrame ,Utablo, LocOnFly;

{$R *.dfm}

{ TBankaKredileriListeTanimlariFrame }

procedure TBankaKredileriListeTanimlariFrame.Baslatildi;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TBankaKredileriListeTanimlariFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TBankaKredileriListeTanimlariFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TBankaKredileriListeTanimlariFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TBankaKredileriListeTanimlariFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TBankaKredileriListeTanimlariFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TBankaKredileriListeTanimlariFrame.Gorunmez;
begin

end;

procedure TBankaKredileriListeTanimlariFrame.GorunmezOlacak;
begin

end;

procedure TBankaKredileriListeTanimlariFrame.Gorunur;
begin

end;

procedure TBankaKredileriListeTanimlariFrame.GorunurOlacak;
begin

end;

procedure TBankaKredileriListeTanimlariFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;
procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories0Items0Click(Sender: TObject);
begin
   {if KrediHesapMakineDlg = nil then
      Application.CreateForm(TKrediHesapMakineDlg, KrediHesapMakineDlg);
   KrediHesapMakineDlg.btnAktar.Visible := False;
   KrediHesapMakineDlg.showmodal;  }
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories0Items1Click(Sender: TObject);
begin
//   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TBankaKredileriListeFrame).Ornek as TBankaKredileriListeFrame do begin
//   end;
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories1Items0Click(Sender: TObject);
begin
   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TPOSListeFrame).Ornek as TPOSListeFrame do begin

   end;

//             <IcerikSekme Adi="POS Tanýmlarý" Tip="TPOS" AramaTipi="TAramaYokFrame"/>
//		  <IcerikSekme Adi="POS Tanýmlarý Liste" Tip="TPOSListeFrame" AramaTipi="TAramaYokFrame" AramaPropertyAdi="Arama"/>
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories1Items1Click(Sender: TObject);
begin
   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKrediKartiListeFrame).Ornek as TKrediKartiListeFrame do begin
  end;
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories1Items3Click(Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TTeminatMektuplariListeFrame).Ornek as TTeminatMektuplariListeFrame do begin
  end;
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories1Items4Click(Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TDBSListeFrame).Ornek as TDBSListeFrame do begin
  end;
end;

procedure TBankaKredileriListeTanimlariFrame.KredilerMenuCategories2Items0Click(Sender: TObject);
begin
  //Vadeli Hesap
   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TVadeliHesaplarListeFrame).Ornek as TVadeliHesaplarListeFrame do begin

   end;
end;

procedure TBankaKredileriListeTanimlariFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
  procedure sil(i:smallint; Kod:String);
  var j:smallint;
  begin
     j:=0;
     while j < KredilerMenu.Categories[i].Items.Count do begin
        if KredilerMenu.Categories[i].Items[j].Hint=Kod then begin
           KredilerMenu.Categories[i].Items[j].Destroy;
           exit;
        end;
        inc(j);
     end;
  end;
begin
  FFrameBilgi := AValue;
  //haklar ve hukuklar
  //kategoriview
//  if not Tablo.YetkiVarmi(253110,YetkiTur_Gorme) then
//     Sil(0, '253110');  //kredi hesap makinesi
//  if not Tablo.YetkiVarmi(253120,YetkiTur_Gorme) then
//     Sil(0, '253120');   //nakit krediler

  if not Tablo.YetkiVarmi(2521,YetkiTur_Gorme) then
     Sil(0, '2521');//POS
  if not Tablo.YetkiVarmi(253130,YetkiTur_Gorme) then
     Sil(0, '253130');
  if not Tablo.YetkiVarmi(253140,YetkiTur_Gorme) then
     Sil(0, '253140');//Çek Koçaný
  if not Tablo.YetkiVarmi(253150,YetkiTur_Gorme) then
     Sil(0, '253150');  //Teminat Mektubu
  if not Tablo.YetkiVarmi(253160,YetkiTur_Gorme) then
     Sil(0, '253160'); //doðrudan borçlanma

  if not Tablo.YetkiVarmi(2541,YetkiTur_Gorme) then
     Sil(0, '2541');    //Vadeli Hesap

  //if KredilerMenu.Categories[2].Items.Count=0 then
  //   KredilerMenu.Categories[2].Destroy;
  if KredilerMenu.Categories[1].Items.Count=0 then
     KredilerMenu.Categories[1].Destroy;
  if KredilerMenu.Categories[0].Items.Count=0 then
     KredilerMenu.Categories[0].Destroy;
end;

procedure TBankaKredileriListeTanimlariFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaKredileriListeTanimlariFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TBankaKredileriListeTanimlariFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TBankaKredileriListeTanimlariFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TBankaKredileriListeTanimlariFrame);
end.
