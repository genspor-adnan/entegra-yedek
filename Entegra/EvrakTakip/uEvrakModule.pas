unit uEvrakModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, cxImageList, cxGraphics, Data.DB;

type
  TdmEvrakModule = class(TDataModule)
    ImagesEvrak: TcxImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmEvrakModule: TdmEvrakModule;

function BlobEkle( _BlobStream : TStream; _HedefAlan : TField) : integer; overload;
function BlobEkle( _FileName : string; _HedefAlan : TField) : integer; overload;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function BlobEkle( _BlobStream : TStream; _HedefAlan : TField) : integer;
var
  BlobField : TFDQuery;
begin
  try
    _BlobStream.Position := 0;
    (_HedefAlan as TBlobField).LoadFromStream(_BlobStream);
    Result := _BlobStream.Size;
  except
    Result := -1;
  end;
end;

function BlobEkle( _FileName : string; _HedefAlan : TField) : integer; overload;
var
  DosyaStream : TFileStream;
begin
  DosyaStream := TFileStream.Create(_FileName, fmOpenRead or fmShareDenyNone);
  try
    try
      Result := BlobEkle(DosyaStream, _HedefAlan);
    except
      Result := -1;
    end;
  finally
    DosyaStream.Free;
  end;

end;
end.


