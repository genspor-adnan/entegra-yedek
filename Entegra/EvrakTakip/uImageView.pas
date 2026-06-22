unit uImageView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.DBCtrls, MBDBImage, Vcl.StdCtrls, Vcl.ExtCtrls, GraphicEx;

type
  TfrmImageView = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Panel1: TPanel;
    buttonKapat: TButton;
    procedure buttonKapatClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ResimGoster( _Stream : TStream);

implementation

{$R *.dfm}

procedure ResimGoster( _Stream : TStream);
var
  Pic : TPicture;
  GraphicClass: TGraphicExGraphicClass;
  Graphic: TGraphic;
  frmImageView : TfrmImageView;
begin
   Pic := TPicture.Create;
   GraphicClass := FileFormatList.GraphicFromContent(_Stream);

   if GraphicClass = nil then
     Pic.LoadFromStream(_Stream)
   else
      begin
        Graphic := GraphicClass.Create;
        Graphic.LoadFromStream(_Stream);
        Pic.Graphic := Graphic;
      end;

   try
     frmImageView := TfrmImageView.Create(Application);
     frmImageView.Image1.Width := Pic.Width;
     frmImageView.Image1.Height := Pic.Height;
     frmImageView.Image1.Picture.Assign(Pic);
     frmImageView.ShowModal;
   finally
     frmImageView.Free;
     Pic.Free;
     { Graphic nesnesi burada Free edilmesin,
       bu yordamı çağıran "BlobEklendi" DosyaStream Free edilecek!
     //if Assigned(Graphic) then
     //  Graphic.Free;
     }
   end;

end;

procedure TfrmImageView.buttonKapatClick(Sender: TObject);
begin
  Close;
end;

end.
