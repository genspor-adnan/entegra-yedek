unit uTanimGrid_MetaBilgileri;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimGridFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, System.Actions, Vcl.ActnList, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, Vcl.Buttons, Vcl.StdCtrls;

type
  TEvrakTanimMetaBilgileriFrame = class(TEvrakTanimGridFrame)
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EvrakTanimMetaBilgileriFrame: TEvrakTanimMetaBilgileriFrame;

implementation

{$R *.dfm}

end.

