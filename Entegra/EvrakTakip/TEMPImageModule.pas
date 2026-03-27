unit TEMPImageModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, cxImageList, cxGraphics;

type
  TTdmIMAGEmodule = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TdmIMAGEmodule: TTdmIMAGEmodule;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
