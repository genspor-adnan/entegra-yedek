unit uCamera;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, clipbrd, jpeg, VCap;

type
  TCamera = class(TForm)
    Panel1: TPanel;
    BTNKapat: TSpeedButton;
    Video: TVideoCapture;
    img: TImage;
    procedure BTNKapatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function ResimKaydet(PERKOD: integer; GirisCikis: string): boolean;
    function OpenVideo(Driver: string): boolean;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Camera: TCamera;

implementation

uses
  uTablo,uAyarForm;

{$R *.dfm}

function TCamera.ResimKaydet(PERKOD: integer; GirisCikis: string): boolean;
var
  DosyaAdi: string;
  BMP: TImage;
  TResim: TJPEGImage;
begin
  DosyaAdi := SResimYol + '\' + GirisCikis + inttostr(PERKOD) + '.jpg';

 { if Video.ToClipboard then
 // begin
    bmp := TImage.Create(nil);
    TResim := TJPEGImage.Create;
    bmp.picture.bitmap.assign(clipboard);
//BMP.Picture.SaveToFile(DosyaAdi);
    TResim.assign(bmp.Picture.Bitmap);
    TResim.SaveToFile(DosyaAdi);
    TResim.Free;
    BMP.Free;
 // end; }

end;

function TCamera.OpenVideo(Driver: string): boolean;
var
  i: integer;
  BmpHead: TBitmapInfo;
begin
  if driver <> '' then
  begin
    result := false;
    for i := 0 to camera.video.VCapModeCount - 1 do
    begin
      if Driver <> format('%d - %s', [i, camera.video.VCapName]) then
        continue;
      video.SetVCapMode(i);
      if video.StartPreview then
      begin
        Video.ChooseDevices(Driver, '', True);
        result := true;
      img.picture.bitmap.width :=BmpHead.bmiHeader.biWidth ;
      img.picture.bitmap.height:=BmpHead.bmiHeader.biHeight;
      end;
    end;
    {for i := 0 to camera.video.CapDrivers.count - 1 do
    begin
      if Driver <> format('%d - %s', [i, camera.video.CapDrivers.strings[i]]) then
        continue;
      video.OpenVideo(i);
      if video.IsOpen then
      begin
        CapGetVideoFormat(video.CapWnd, @BmpHead, sizeof(BmpHead));
        result := true;
      img.picture.bitmap.width :=BmpHead.bmiHeader.biWidth ;
      img.picture.bitmap.height:=BmpHead.bmiHeader.biHeight;
      end;
    end;   }
  end
  else
    result := false;
end;

procedure TCamera.BTNKapatClick(Sender: TObject);
begin
  Close;
end;

procedure TCamera.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TCamera.FormCreate(Sender: TObject);
var
  config: TGraphConfig;
  s: string;
begin
   { if not Video.Init then
    begin
      Showmessage('Video baþlatýlamadý!' +
        'Sorun görüntü aygýtlarýndan kaynaklanýyor olabilir');
      Abort;
    end
    else
    begin
      // Video ayarlarýný uygula
      config := TGraphConfig.Create;
      try
        config.Clear;
        config.WantAudioPreview := False;
        config.WantBitmaps := True;
        config.WantPreview := True;
        config.WantCapture := True;
        config.UseTempFile := True;
       // config.VCapSource :=  GenotipIni.ReadString('OPSIYONLAR', 'CAMERA', '');
        config.WantAudio := False;
        config.WantDVAudio := False;
      //GenRegIni.RegReadString('VideoAudio', 'GoruntuAygiti', '', 'C');
       // if StrToBool(GenRegIni.RegReadString('VideoAudio', 'SesiKaydet','False', 'C')) then
       // begin
       //   config.ACapSource := GenRegIni.RegReadString('VideoAudio', 'SesAygiti', '', 'C');
       //   s := GenRegIni.RegReadString('VideoAudio', 'SesSýkýþtýrma', '', 'C');
       //   if (s <> '') then
       //     config.AComp := s;
       //   config.WantAudio := True;
       //   config.WantDVAudio := True;
       // end
       // else
       // begin
       //   config.WantAudio := False;
       //   config.WantDVAudio := False;
       // end;
       // s := GenotipIni.ReadString('VideoAudio', 'GörüntüSýkýþtýrma', '');
       // if (s <> '') then   config.VComp := s;
       // s := GenotipIni.ReadString('VideoAudio', 'PikselBicimi', '6');
       // config.PixelFormat := TPixelFormat(StrToIntDef(s, 6));
       // s := GenotipIni.ReadString('VideoAudio', 'DVCozunurlugu', '0');
        config.DVResolution := TDVResolution(StrToIntDef(s, 0));
        config.VCompState := '';
        Video.RestoreGraph(config);
      finally
        config.free;
      end;
  end    }
end;

procedure TCamera.FormShow(Sender: TObject);
begin
{  Video.SetVCapMode(AyarlarForm.CBSurucu.ItemIndex);
  Video.StartPreview;  }
end;

end.
