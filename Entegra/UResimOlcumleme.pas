unit UResimOlcumleme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxLabel, cxTrackBar, cxControls,
  cxContainer, cxEdit, cxImage, ExtCtrls, jpeg, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue;

type
  TResimOlcumlemeDlg = class(TForm)
    Panel1: TPanel;
    Rsm: TcxImage;
    cxTrackBar1: TcxTrackBar;
    cxLabel1: TcxLabel;
    cxTrackBar2: TcxTrackBar;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    LabelAlan: TcxLabel;
    TamamTus: TcxButton;
    procedure cxTrackBar1PropertiesChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TamamTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DosyaAdi : string;
    PictureOrj, Picture1 : TJpegImage;
  end;

var
  ResimOlcumlemeDlg: TResimOlcumlemeDlg;
function ResimOlcumleme(Dosya:string):String;
function ResimKucult(Dosya:string; IstenenSize:Integer):String;

implementation

{$R *.dfm}
uses Fetautil, IdGlobalProtocols;

//Alttaki küçültme fonksiyonu verilen resmi, istenen büyüklüðe dönüþtürür
function ResimKucult(Dosya:string; IstenenSize:Integer):String;
var Resim : TJpegImage;
    Yuzde : Integer;
begin
   Yuzde := Round(FileSizeByName(Dosya)/1024);

   Yuzde := Round((IstenenSize / (FileSizeByName(Dosya)/1024))*100);
   Resim := TJpegImage.Create;
   Resim.LoadFromFile(Dosya);
   ResizeJPG(Resim, Yuzde, 100);
   Resim.SaveToFile('resim.jpg');
   Resim.destroy;
   Result := 'resim.jpg'
end;

function ResimOlcumleme(Dosya:string):String;
begin
    Application.CreateForm(TResimOlcumlemeDlg, ResimOlcumlemeDlg);
    ResimOlcumlemeDlg.DosyaAdi := Dosya;
    ResimOlcumlemeDlg.ShowModal;
    if ResimOlcumlemeDlg.ModalResult = mrOk then
       Result := 'resim.jpg'
    else
       Result := '';
    ResimOlcumlemeDlg.Destroy;
end;

procedure TResimOlcumlemeDlg.cxTrackBar1PropertiesChange(Sender: TObject);
begin
//   ResizeJPG(DosyaAdi, 'c:\resim.jpg', cxTrackBar1.Position, cxTrackBar2.Position);
   Picture1 := TJpegImage.Create;
   Picture1.Assign(PictureOrj);
   LabelAlan.Caption := IntToStr(ResizeJPG(Picture1, cxTrackBar1.Position, cxTrackBar2.Position))+' KB';
   //Rsm.Picture.LoadFromFile('c:\resim.jpg');
   Rsm.Picture.Graphic := Picture1;
   Picture1.destroy;

   //LabelAlan.Caption :=  FloatToStr(FileSizeByName('c:\resim.jpg')/1024)+' KB';

end;

procedure TResimOlcumlemeDlg.FormShow(Sender: TObject);
begin
   PictureOrj := TJpegImage.Create;
   PictureOrj.LoadFromFile(DosyaAdi);
   //Rsm.Picture.LoadFromFile(DosyaAdi);
   Rsm.Picture.Graphic := PictureOrj;
    LabelAlan.Caption :=  FloatToStr(FileSizeByName(DosyaAdi)/1024)+' KB';
end;

procedure TResimOlcumlemeDlg.TamamTusClick(Sender: TObject);
begin
   Rsm.Picture.SaveToFile('resim.jpg');
end;

end.
