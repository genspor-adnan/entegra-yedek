unit QRBarCode;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  QuickRpt, Barcode, DB;

type
  TQRBarCode = class(TQRPrintable)
  private
    { Private declarations }
    FBarCode: TBarCode;
    FDataSet : TDataSet;
    FDataField: string;
    FTextDataField: string;
    function GetText: string;
    procedure SetText(Value: string);
    function GetModul: Integer;          //En dar çizginin geniþliði
    procedure SetModul(Value: Integer);  // "  "      "
    function GetRatio: Double;
    procedure SetRatio(Value: Double);
    function GetBarTip: TBarCodeType;
    procedure SetBarTip(Value: TBarCodeType);
    function GetChecksum: Boolean;
    procedure SetChecksum(Value: Boolean);
    function GetAngle: Double;
    procedure SetAngle(Value: Double);
    function GetShowText: Boolean;
    procedure SetShowText(Value: Boolean);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Print(OfsX, OfsY : integer); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadVisible(Reader : TReader); virtual;
    procedure WriteDummy(Writer : TWriter); virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Text: string read GetText write SetText;
    property Modul: Integer read GetModul write SetModul;
    property Ratio: Double read GetRatio write SetRatio;
    property BarTip: TBarCodeType read GetBarTip write SetBarTip
      default bcCode_2_5_interleaved;
    property Checksum: Boolean read GetChecksum write SetChecksum default False;
    property Angle: Double read GetAngle write SetAngle;
    property ShowText: Boolean read GetShowText write SetShowText default False;
    property DataSet: TDataSet read FDataSet write FDataSet;
    property DataField: string read FDataField write FDataField;
    property TextDataField: string read FTextDataField write FTextDataField;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('QReport', [TQRBarCode]);
end;

procedure TQRBarCode.Paint;
begin
  FBarCode.Height := Self.Height;
  FBarCode.Left := 0;
  FBarCode.Top := 0;
  if Text <> '' then
    FBarCode.DrawBarcode(Canvas)
  else Canvas.Rectangle(0, 0, Width, Height);
end;

procedure TQRBarCode.Print(OfsX, OfsY : integer);
begin
  if Assigned(FDataSet) then begin
    if (FDataField <> '') then FBarCode.Text := FDataSet.FieldByName(FDataField).AsString;
    //if (FTextDataField <> '') then FBarCode.ShowText := FDataSet.FieldByName(FTextDataField).AsString;
  end;
  FBarCode.Height := QRPrinter.YSize(Size.Height);
  FBarCode.Left := QRPrinter.XPos(OfsX + Size.Left);
  FBarCode.Top := QRPrinter.YPos(OfsY + Size.Top);
  if Text <> '' then
    FBarCode.DrawBarcode(QRPrinter.Canvas)
  else QRPrinter.Canvas.Rectangle(FBarCode. Left, FBarCode.Top,
    FBarCode.Left + QRPrinter.XSize(Size.Width), FBarCode.Top +
      QRPRinter.YSize(Size.Height));
end;

procedure TQRBarCode.DefineProperties(Filer: TFiler);
begin
  Filer.DefineProperty('Visible', ReadVisible, WriteDummy, False);
  inherited DefineProperties(Filer);
end;

procedure TQRBarCode.ReadVisible(Reader : TReader);
begin
  Enabled := Reader.ReadBoolean;
end;

procedure TQRBarCode.WriteDummy(Writer : TWriter);
begin
end;

procedure TQRBarCode.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

constructor TQRBarCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBarCode := TBarcode.Create(Self);
  Width := 121;
  Height := 25;
end;

destructor TQRBarCode.Destroy;
begin
  FBarCode := nil;
  inherited Destroy;
end;

function TQRBarCode.GetText: string;
begin
  Result := FBarCode.Text;
end;

procedure TQRBarCode.SetText(Value: string);
begin
  FBarCode.Text := Value;
end;

function TQRBarCode.GetModul: Integer;
begin
  Result := FBarCode.Modul;
end;

procedure TQRBarCode.SetModul(Value: Integer);
begin
  FBarCode.Modul := Value;
end;

function TQRBarCode.GetRatio: Double;
begin
  Result := FBarCode.Ratio;
end;

procedure TQRBarCode.SetRatio(Value: Double);
begin
  FBarCode.Ratio := Value;
end;

function TQRBarCode.GetBarTip: TBarcodeType;
begin
  Result := FBarCode.Typ;
end;

procedure TQRBarCode.SetBarTip(Value: TBarcodeType);
begin
  FBarCode.Typ := Value;
end;

function TQRBarCode.GetChecksum: Boolean;
begin
  Result := FBarCode.Checksum;
end;

procedure TQRBarCode.SetChecksum(Value: Boolean);
begin
  FBarCode.Checksum := Value;
end;

function TQRBarCode.GetAngle: Double;
begin
  Result := FBarCode.Angle;
end;

procedure TQRBarCode.SetAngle(Value: Double);
begin
  FBarCode.Angle := Value;
end;

function TQRBarCode.GetShowText: Boolean;
begin
  Result := FBarCode.ShowText;
end;

procedure TQRBarCode.SetShowText(Value: Boolean);
begin
  FBarCode.Showtext := Value;
end;

end.
