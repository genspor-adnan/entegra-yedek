unit uTanimGrid_AntetFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, FireDAC.Comp.Client, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, cxContainer,
  cxImage, cxDBEdit, cxButtonEdit, cxMemo, cxRichEdit, cxDBRichEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, Vcl.StdCtrls;

type
  TEvrakTanimAntetFrame = class(TEvrakTanimGridFrame)
    qryLookupBirimKodu: TFDQuery;
    dsBirimKodu: TDataSource;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    lookupBirimKodu: TcxDBLookupComboBox;
    Label3: TLabel;
    editBaslik: TcxDBRichEdit;
    editResimDosya: TcxDBButtonEdit;
    Label2: TLabel;
    ImageResim: TcxDBImage;
    Label5: TLabel;
    editAltResimDosya: TcxDBButtonEdit;
    Label6: TLabel;
    ImageAltResim: TcxDBImage;
    ViewTanimID: TcxGridDBColumn;
    ViewTanimBIRIM_ID: TcxGridDBColumn;
    ViewTanimANTET_METIN: TcxGridDBColumn;
    ViewTanimANTET_RESIM_IMAGE: TcxGridDBColumn;
    ViewTanimALT_ANTET_RESIM_DOSYA: TcxGridDBColumn;
    Label4: TLabel;
    procedure ImageAltResimDblClick(Sender: TObject);
    procedure ImageResimDblClick(Sender: TObject);
    procedure editResimDosyaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure editAltResimDosyaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
    function BlobEklendi( _Gen, _Yuk : integer; _DosyaAdi : string; _FieldName : string) : boolean;
    procedure ResimBlobGoster( _FieldName : string);
  public
    { Public declarations }
    procedure Startup; override;
  end;

var
  EvrakTanimAntetFrame: TEvrakTanimAntetFrame;

implementation

{$R *.dfm}

uses
  uImageView,
  GraphicEx
  ;

function UygunResim( _Gen, _Yuk : integer; _Stream : TStream) : boolean;
var
  Pic : TPicture;
  GraphicClass: TGraphicExGraphicClass;
  Graphic: TGraphic;

begin
  //
   Result := False;
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
      Result :=  (Pic.Width <= _Gen) and ( Pic.Height<= _Yuk);
   finally
     Pic.Free;
     { Graphic nesnesi burada Free edilmesin,
       bu yordamı çağıran "BlobEklendi" DosyaStream Free edilecek!
     //if Assigned(Graphic) then
     //  Graphic.Free;
     }
   end;
end;
{ TEvrakTanimAntetFrame }

function TEvrakTanimAntetFrame.BlobEklendi(_Gen, _Yuk : integer;_DosyaAdi, _FieldName: string) : boolean;
var
  DosyaStream : TFileStream;
begin
   Result := False;
   DosyaStream := TFileStream.Create(_DosyaAdi, fmOpenRead or fmShareDenyNone);
   try
     if UygunResim(_Gen, _Yuk, DosyaStream) then
     begin
       editResimDosya.Text := OpenDialog1.FileName;
       DosyaStream.Position := 0;
       (qryEvrak.FieldByName(_FieldName) as TBlobField).LoadFromStream(DosyaStream);
       Result := True;
       end
     else
       Application.MessageBox(PWideChar('Resim boyutu Geçersiz'#13#10+_Gen.ToString+' piksel Genişlik, '+_Yuk.ToString+' piksel Yükseklik ile sınırlıdır'), PWideChar('Uyarı'),  MB_OK + MB_ICONASTERISK);
   finally
        DosyaStream.Free;
   end;
end;

procedure TEvrakTanimAntetFrame.editAltResimDosyaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if qryEvrak.State = dsBrowse then
    qryEvrak.Edit;

  if AButtonIndex=0 then
  begin
    if OpenDialog1.Execute then
     begin
       if BlobEklendi(770, 58, OpenDialog1.FileName, 'ALT_ANTET_RESIM_IMAGE') then
         qryEvrak.FieldByName('ALT_ANTET_RESIM_DOSYA').AsString := OpenDialog1.FileName;
         //editAltResimDosya.Text := OpenDialog1.FileName;
     end;
  end
   else
   begin
     qryEvrak.FieldByName('ALT_ANTET_RESIM_DOSYA').AsString := '';
     //editAltResimDosya.Text := '';
     (qryEvrak.FieldByName('ALT_ANTET_RESIM_IMAGE') as TBlobField).Clear;
   end;
end;

procedure TEvrakTanimAntetFrame.editResimDosyaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if qryEvrak.State = dsBrowse then
    qryEvrak.Edit;

  if AButtonIndex=0 then
  begin
    if OpenDialog1.Execute then
     begin
       if BlobEklendi(770, 180, OpenDialog1.FileName, 'ANTET_RESIM_IMAGE') then
         qryEvrak.FieldByName('ANTET_RESIM_DOSYA').AsString := OpenDialog1.FileName;
         //editResimDosya.Text := OpenDialog1.FileName;
     end;
  end
   else
   begin
       qryEvrak.FieldByName('ANTET_RESIM_DOSYA').AsString := '';
      //editResimDosya.Text := '';
      (qryEvrak.FieldByName('ANTET_RESIM_IMAGE') as TBlobField).Clear;
   end;
end;

procedure TEvrakTanimAntetFrame.ImageAltResimDblClick(Sender: TObject);
begin
  //inherited;
  ResimBlobGoster('ALT_ANTET_RESIM_IMAGE');
end;

procedure TEvrakTanimAntetFrame.ImageResimDblClick(Sender: TObject);
begin
  //inherited;
  ResimBlobGoster('ANTET_RESIM_IMAGE');
end;

procedure TEvrakTanimAntetFrame.ResimBlobGoster(_FieldName: string);
var
   StreamMem : TMemoryStream;
begin
   if (Not qryEvrak.FieldByName(_FieldName).IsBlob) or (qryEvrak.FieldByName(_FieldName).IsNull)then
     Exit;

   StreamMem := TMemoryStream.Create;
   try
     (qryEvrak.FieldByName(_FieldName) as TBlobField).SaveToStream(StreamMem);
     StreamMem.Position := 0;
     uImageView.ResimGoster(StreamMem);
   finally
      StreamMem.Free;
   end;

end;

procedure TEvrakTanimAntetFrame.Startup;
begin
  SetActions([actKaydet, actSil, actYeniKayit]);
  inherited;
  qryLookupBirimKodu.Open;
end;

end.

