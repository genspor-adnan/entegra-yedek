unit GenoTIP.Controls.QRWPRichText;

interface
uses
  QuickRpt,Windows,Classes,WPRTEPaint,WPCTRRich,WPRTEDefs,Graphics,QRPrntr,Messages,SysUtils,DB,
  System.Generics.Collections, FetaKurulusSiniflari;
type

  TWPLineInfo = class
  public
    LineYStart : Integer;
    LineHeight : Integer;
    LineBottom : Integer;

    constructor Create(AY,AHeight: Integer);

    function Inside(AY: Integer): Boolean;
  end;

  TWPPageInfo = class
  private
    FPageNo: Integer;
    FLines: TObjectList<TWPLineInfo>;
    FPaintPage: TWPRTFEnginePaintPages;
    FRtfPage: TWPVirtPage;
    FHeight: Integer;
    FPageMetafile: TMetafile;
    FTotalDrawn: Integer;
    FIsDrawFinished: Boolean;

    function FindLine(AY: Integer): TWPLineInfo;
    procedure AddLine(AY,AH: Integer);

    procedure WriteState(AWriter: TBinaryWriter);
    procedure ReadState(AReader: TBinaryReader);

  public
    constructor Create(AMemo: TWPRTFEnginePaint;APageNo: Integer);
    destructor Destroy; override;
    function Draw(ADest: TRect;ACanvas: TCanvas;var AAvailableSpace: Integer): Boolean;
    function CanDraw( AAvailableSpace: Integer ): Boolean;
    procedure Reset;
    property PageNo: Integer read FPageNo;
    property PaintPage: TWPRTFEnginePaintPages read FPaintPage;
    property RtfPage: TWPVirtPage read FRtfPage;
    property Height: Integer read FHeight;
    property IsDrawFinished : Boolean read FIsDrawFinished;
  end;

  TQRWPRichText = class(TQRPrintable)
  private
    FAutoStretch: boolean;
    FMemo: TWPRTFEnginePaint;
    FCurrentPage : Integer;
    FMaxHeight: Extended;
    FPages: TObjectList<TWPPageInfo>;
    FState: TStateHistory;
    FSizeTopApplied: Boolean;
    FUseKerning :Boolean;
  protected
    procedure GeneratePages(ADC: HDC);
    procedure Print(OfsX: Integer; OfsY: Integer); override;
    function WpHeight(AValue: Integer): Integer;
    procedure Paint; override;
    function GetTotalHeight: Integer;
    function GetTotalDrawnHeight: Integer;
    function AllPagesAreDrawn: Boolean;
    procedure ResetPages;

    procedure SaveState;
    procedure RestoreState;

  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    procedure GetExpandedHeight(var newheight: Extended); override;
    procedure LoadRtfText(ARtf:string);
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(AFile:string);

  published
    property AutoStretch : boolean read FAutoStretch write FAutoStretch;
    property MaxHeight : Extended read FMaxHeight write FMaxHeight;
    property UseKerning : boolean read FUseKerning write FUseKerning;
  end;

  TQRDBWPRichText = class(TQRWPRichText)
  private
    Field : TField;
    FDataField : string;
    FDataSet : TDataSet;
    FRecNo   : Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetDataSet(Value : TDataSet);
    procedure Prepare; override;
    procedure UnPrepare; override;
    procedure Print(OfsX: Integer; OfsY: Integer); override;

  public
    procedure GetFieldString( var DataStr : string);override;
  published
    property DataField : string read FDataField write FDataField;
    property DataSet : TDataSet read FDataSet write SetDataSet;
  end;

procedure Register;

implementation
uses
  Math, QRCtrls, Vcl.Printers, UGtpLibrary;

var
  cnt: Integer = 1;

{ TQRWPRichText }

function TQRWPRichText.AllPagesAreDrawn: Boolean;
var
  pi : TWPPageInfo;
begin
  Result := True;
  for pi in FPages do begin
    if (not pi.FIsDrawFinished) then Exit(False);
  end;
end;

constructor TQRWPRichText.Create(AOwner: TComponent);
begin
  inherited;
  FMemo := TWPRTFEnginePaint.Create(Self);
  FPages := nil;
  FState := TStateHistory.Create;

end;

destructor TQRWPRichText.Destroy;
begin
  FMemo.Free;
  FState.Free;
  if Assigned(FPages) then
    FreeAndNil( FPages );
  inherited;
end;

procedure TQRWPRichText.GeneratePages;
var
  pi: TWPPageInfo;
  i : Integer;
begin
  if Assigned(FPages) then Exit;
  FPages := TObjectList<TWPPageInfo>.Create;
  for i := 0 to FMemo.PaintPageCount - 1 do begin
    pi := TWPPageInfo.Create(FMemo,i);
    FPages.Add(pi);
  end;
end;

procedure TQRWPRichText.GetExpandedHeight(var newheight: Extended);
var
  _paintPage : TWPRTFEnginePaintPages;
  rtfPage    : TWPVirtPage;
  i          : Integer;
  totalHeight: Extended;
begin
  totalHeight := 0;
  for i := 0 to FMemo.PaintPageCount - 1 do begin
    FMemo.GetPaintPage(i,_paintPage,rtfPage);
    totalHeight := totalHeight + _paintPage.LastPrintedYPos;
  end;
  newheight := (totalHeight + Size.Height) * QRPrinter.YFactor;
end;

function TQRWPRichText.GetTotalDrawnHeight: Integer;
var
  pi : TWPPageInfo;
begin
  Result := 0;
  for pi in FPages do begin
    Result := Result + pi.FTotalDrawn;
  end;
end;

function TQRWPRichText.GetTotalHeight: Integer;
var
  pi : TWPPageInfo;
begin
  Result := 0;
  for pi in FPages do begin
    Result := Result + pi.FHeight;
  end;
end;

procedure TQRWPRichText.LoadFromFile(AFile: string);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create( AFile, fmOpenRead or fmShareDenyNone );
  try
    LoadFromStream(fs);
  finally
    fs.Free;
  end;
end;

procedure TQRWPRichText.LoadFromStream(AStream: TStream);
begin
  FMemo.RTFData.Clear;
  FMemo.LoadFromStream(AStream,False);
  FMemo.Margins.Left := 0;
  FMemo.Margins.Top := 0;
  FMemo.Margins.Right := 0;
  FMemo.Margins.Bottom := 0;
  FMemo.ReformatAll;
  if Assigned(FPages) then
    FreeAndNil( FPages );
end;

procedure TQRWPRichText.LoadRtfText(ARtf: string);
var
  str : TStringStream;
begin
  str := TStringStream.Create(ARtf);
  try
    LoadFromStream(str);
  finally
    str.Free;
  end;
end;

procedure TQRWPRichText.Paint;
var
  _paintPage      : TWPRTFEnginePaintPages;
  rtfPage         : TWPVirtPage;
begin
  inherited;

  FMemo.GetPaintPage( 0, _paintPage, rtfPage );

  FMemo.Draw( Canvas,
      0,
      0,
      Height + _paintPage.MarginTop,
      WPScreenPixelsPerInch,
      WPScreenPixelsPerInch,
      0 );

end;

procedure TQRWPRichText.Print(OfsX, OfsY: Integer);

  procedure DrawOntoCanvas(ACanvas: TCanvas;ADestRect: TRect);
  label
    loop1;
  var
    _height: Integer;
    pi: TWPPageInfo;
  begin
    pi := FPages[FCurrentPage];

  loop1:

    LogLn('DrawOntoCanvas(%d, %d, %d, %d)',[ADestRect.Left,ADestRect.Top,ADestRect.Width,ADestRect.Height]);

    _height := ADestRect.Height;

    if ( pi.Draw( ADestRect, ACanvas, _height ) ) then begin

      Inc( FCurrentPage );

      if ( FCurrentPage >= FPages.Count ) then begin
        PrintFinished := True;
        Exit;
      end;

      pi := FPages[ FCurrentPage ];

      if ( _height < ADestRect.Height ) and ( pi.CanDraw( ADestRect.Height - _height ) ) then begin
        ADestRect.Top := ADestRect.Top + _height;

        goto loop1;
      end;

    end;

    LogLn('Drawn Height: %d',[ _height ]);

     ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Color :=clred;
    ACanvas.Rectangle(ADestRect);

  end;
var
  HasExpanded     : boolean;
  Expanded        : extended;
  parentBand      : TQRCustomBand;
  _hdc            : HDC;
  remainingHeight : Integer;
  requiredSpace   : Extended;

  RTFImage        : TQRImage;
  OldMapMode      : Integer;
  _canvas         : TCanvas;
  saveFont        : TFont;
  availableSpace  : Extended;
  r               : TRect;
  _height         : Integer;
  pi              : TWPPageInfo;

begin
  saveFont := TFont.Create;
  saveFont.Assign(ParentReport.QRPrinter.Canvas.Font);

  _hdc := ParentReport.QRPrinter.PrinterHandle;
  if (ParentReport.QRPrinter.Destination = qrdMetafile) then
    _hdc := ParentReport.QRPrinter.Canvas.Handle;

  GeneratePages( _hdc );

  _canvas := TCanvas.Create;
  _canvas.Handle := _hdc;

  OldMapMode := SetMapMode( ParentReport.QRPrinter.Canvas.Handle, MM_TEXT );

  r := Rect(
    QRPrinter.XPos( OfsX + Size.Left ),
    QRPrinter.YPos( OfsY + Size.Top ),
    QRPrinter.XPos( OfsX + Size.Left + Size.Width ),
    QRPrinter.YPos( OfsY + Size.Top + Size.Height ) );

  if (PrintFinished) then begin
    ResetPages;
    FCurrentPage := 0;
  end;

  HasExpanded := false;
  Expanded := 0;

  remainingHeight := ( GetTotalHeight - GetTotalDrawnHeight );

  parentBand := TQRCustomBand(Parent);

  availableSpace := parentBand.Size.Height + parentBand.Expanded;

  if ( QRPrinter.YSize( Size.Top ) < 0 ) then begin
    if ( FCurrentPage = 0 ) and not FSizeTopApplied then begin
      // ilk sayfa ise ve top deðeri eksi bir deðer ise ilk sayfayý biraz daha aþaðýdan baþlatýyoruz
      FPages[FCurrentPage].FTotalDrawn := FPages[FCurrentPage].FTotalDrawn - QRPrinter.YSize( Size.Top );
      remainingHeight := remainingHeight + QRPrinter.YSize( Size.Top );
      FSizeTopApplied := True;
    end;
  end
  else
    // 0 veya büyükse bu bizim alaný daraltmamýz gerektiðini söylüyor
    availableSpace := availableSpace - Size.Top;

  if ( ParentReport.Exporting ) then
    // export ediliyorsa durumunu saklamalýyýz
    // çünkü burada yapýlanlarý tekrar etmemiz gerekiyor
    SaveState;

  if FAutoStretch then begin
    PrintFinished := False;
    // boþ alan çizilmesi gereken alandan küçük mü?
    if ( QRPrinter.YSize( availableSpace ) < remainingHeight ) then begin
      // bandý geri kalan boþluk kadar geniþlet
      requiredSpace := ParentReport.AvailableSpace - parentBand.Size.Length - parentBand.Expanded;
      if ( MaxHeight > 0 ) then begin
        // max height verilmiþ ise
        // gerekli alandan kýrpmamýz gerekiyor
        if ( ( availableSpace + requiredSpace ) > MaxHeight ) then
          requiredSpace := MaxHeight - availableSpace;
      // ayrýlan alan bizim istediðimizden büyük mü ?
      end else if ( GetTotalHeight < QRPrinter.YSize( requiredSpace + availableSpace ) ) then begin
        // o zaman istenilen boyuta getir
        requiredSpace := Round( GetTotalHeight / QRPrinter.YFactor ) + availableSpace;
      end;

      parentBand.ExpandBand( requiredSpace, Expanded, HasExpanded );
      // mevcut boþluðuda buna göre geniþlet, eðer size.top > 0 ise bunu bu boþluktan çýkar
      availableSpace := availableSpace + requiredSpace;

      r.Bottom := QRPrinter.YPos( OfsY + availableSpace );
    end;

    DrawOntoCanvas( _canvas, r );

    _height := GetTotalDrawnHeight;

  end else begin

    r.Bottom := QRPrinter.YPos( OfsY + availableSpace );

    _height := r.Height;

    pi := FPages[FCurrentPage];
    pi.Draw(
      r,
      _canvas,
      _height );


    PrintFinished := True;
  end;

  _canvas.Handle := 0;
  _canvas.Free;

  if (ParentReport.Exporting) then begin
    RTFImage := TQRImage.create(nil);
    try
      r.Offset(-r.Left,-r.Top);

      RTFImage.AutoSize := True;
      RTFImage.Tag := 0;
      RTFImage.Picture.Bitmap.Width := r.Width;
      RTFImage.Picture.Bitmap.Height := r.Height;

      RestoreState;

      DrawOntoCanvas( RTFImage.Picture.Bitmap.Canvas, r );

      RTFImage.Size.Left := Size.Left;
      RTFImage.Size.Top := Size.Top;
      RTFImage.Width := r.Width;
      RTFImage.Height := r.Height;

      TQRExportFilter(ParentReport.ExportFilter)
        .AcceptGraphic(
          QRPrinter.XPos(  OfsX + Size.Left ),
          QRPrinter.YPos( OfsY + Size.Top ), RTFImage ) ;
    finally
      RTFImage.Free;
    end;
  end;

  ParentReport.QRPrinter.Canvas.Font.Assign(saveFont);
  saveFont.Free;

  SetMapMode(ParentReport.QRPrinter.Canvas.Handle, OldMapMode);

end;

procedure TQRWPRichText.ResetPages;
var
  pi : TWPPageInfo;
begin
  for pi in FPages do begin
    pi.Reset;
  end;
  FSizeTopApplied := False;
end;

procedure TQRWPRichText.RestoreState;
var
  pi : TWPPageInfo;
begin
  FState.PopPosition;
  FCurrentPage := FState.Reader.ReadInt32;
  for pi in FPages do begin
    pi.ReadState( FState.Reader );
  end;
end;

procedure TQRWPRichText.SaveState;
var
  pi : TWPPageInfo;
begin
  FState.PushPosition;
  FState.Writer.Write(FCurrentPage);
  for pi in FPages do begin
    pi.WriteState( FState.Writer );
  end;
end;

function TQRWPRichText.WpHeight(AValue: Integer): Integer;
begin
  Result := MulDiv(AValue,FMemo.CurrentYPixelsPerInch,WPScreenPixelsPerInch);
end;

{ TQRDBWPRichText }

procedure TQRDBWPRichText.GetFieldString(var DataStr: string);
begin
  if IsEnabled then
  begin
    Prepare;
    if assigned(Field) then
    begin
      try
        if (Field is TMemoField) or (Field is TBlobField) then
        begin
          DataStr := TMemoField(Field).AsString;
        end
        else
          if (Field is TStringField) then
            if not (Field is TBlobField) then
              DataStr := Field.DisplayText
            else
              DataStr := Field.AsString;
      except
        DataStr := '';
      end;
    end
    else
      DataStr := '';
  end;

end;

procedure TQRDBWPRichText.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
    if AComponent=FDataSet then
      FDataSet := nil;

end;

procedure TQRDBWPRichText.Prepare;
begin
  inherited;
  if assigned(FDataSet) then
  begin
    Field := FDataSet.FindField(FDataField);
    if (Field is TBlobField) or (Field is TMemoField) then
    begin
      Caption := '';
    end;
  end else
    Field := nil;



end;


procedure TQRDBWPRichText.Print(OfsX, OfsY: Integer);
var
  stream : TMemoryStream;
begin
  if Assigned(Field) then
    if ( FRecNo <> Field.DataSet.RecNo ) then begin
      if (Field is TMemoField) then begin
        LoadRtfText(TMemoField(Field).AsString);
      end else if Field is TBlobField then begin
        stream := TMemoryStream.Create;
        try
          TBlobField(Field).SaveToStream(stream);
          stream.Position := 0;
          LoadFromStream(stream);
        finally
          stream.Free;
        end;
      end;
      FRecNo := Field.DataSet.RecNo;
    end;
  inherited;
  if PrintFinished then FRecNo := 0;

end;

procedure TQRDBWPRichText.SetDataSet(Value: TDataSet);
begin
  FDataSet := Value;
  if Value<>nil then
    Value.FreeNotification(self);
end;

procedure TQRDBWPRichText.UnPrepare;
begin
  Field := nil;
  inherited;

end;

procedure Register;
begin
  RegisterComponents('QReport',[TQRWPRichText,TQRDBWPRichText]);
end;

{ TWPPageInfo }

procedure TWPPageInfo.AddLine(AY, AH: Integer);
var
  li : TWPLineInfo;
begin
  for li in FLines do begin
    if (AY = li.LineYStart) then Exit;
  end;
  li := TWPLineInfo.Create(AY,AH);
  FLines.Add(li);
end;

function TWPPageInfo.CanDraw( AAvailableSpace: Integer ): Boolean;
var
  li: TWPLineInfo;
  y : Integer;
begin
  y := FTotalDrawn + AAvailableSpace;
  li := FindLine( FTotalDrawn );
  Result := Assigned( li ) and ( li.LineBottom <= y );
end;

constructor TWPPageInfo.Create(AMemo: TWPRTFEnginePaint; APageNo: Integer);
var
  lineIdx   : Integer;
  y         : Integer;
  h         : Integer;
  ln        : TWPVirtPageImageLineRef;
  c         : TMetafileCanvas;
begin
  FPageNo := APageNo;
  AMemo.GetPaintPage( FPageNo, FPaintPage, FRtfPage );
  FLines := TObjectList<TWPLineInfo>.Create;
  for lineIdx := 0 to FRtfPage.LineCount - 1 do begin
    rtfPage.GetLine( lineIdx, ln );
    y := Round( ( ln.y / FRtfPage.YPixelsPerInch * WPScreenPixelsPerInch ) - FPaintPage.MarginTop );
    h := Round( ln.h  / rtfPage.YPixelsPerInch * WPScreenPixelsPerInch );
    AddLine(y,h);
  end;

  FPageMetafile := TMetafile.Create;
  FPageMetafile.Width := FPaintPage.Width - FPaintPage.MarginRight;
  FPageMetafile.Height := FPaintPage.LastPrintedYPos;

  FHeight := FPaintPage.LastPrintedYPos;

  FTotalDrawn := 0;

  c := TMetafileCanvas.Create( FPageMetafile, 0 );
  try
    AMemo.PaintRTFPage(
      FPageNo,
      -FPaintPage.MarginLeft,
      -FPaintPage.MarginTop,
      0,
      0,
      c,
      [wppWhiteIsTransparent, wppNoHeaderFooter],
      0,
      0,
      -1,
      -1,
      [ wpNoXMargins, wpNoYMargins],
      FRtfPage );
  finally
    c.Free;
  end;

  //FPageMetafile.SaveToFile('c:\page' + IntToStr(FPageNo) + '.emf');

end;

destructor TWPPageInfo.Destroy;
begin
  FLines.Free;
  FPageMetafile.Free;
  inherited;
end;

function TWPPageInfo.Draw;

  procedure DrawStretched(AMetaFile: TMetafile; ADest: TRect;ATarget: TCanvas;ASrc: TRect);
  var
    Rgn: HRGN;
     X  : Integer;
    Y  : Integer;
  begin
    Rgn := CreateRectRgnIndirect(ADest);
    try
      X := ADest.Left - ASrc.Left;
      Y := ADest.Top - ASrc.Top;
      SelectClipRgn( ATarget.Handle, Rgn );
      ATarget.Draw(X,Y,AMetaFile);
      SelectClipRgn( ATarget.Handle, 0 );
    finally
      DeleteObject(Rgn);
    end;
  end;

  function AdjustBottom(ABottom: Integer): Integer;
  var
    li: TWPLineInfo;
    i : Integer;
  begin
    Result := ABottom;
    for I := FLines.Count - 1 downto 0 do
    begin
      li := FLines[i];
      if ( ABottom >= li.LineBottom ) then begin
        if ( I = ( FLines.Count - 1 ) ) then
          Exit( FHeight )
        else
          Exit( li.LineBottom );
      end;
    end;
  end;

var
  _bottom : Integer;
begin

  _bottom := AdjustBottom( FTotalDrawn + AAvailableSpace);

  AAvailableSpace:= _bottom - FTotalDrawn;

  if ( ADest.Height > AAvailableSpace) then
    ADest.Height := AAvailableSpace;

  LogLn('Page(%d),top:%d, bottom:%d, ', [FPageNo,FTotalDrawn, _bottom]);

  DrawStretched( FPageMetafile, ADest, ACanvas,
    Rect( 0, FTotalDrawn, FPageMetafile.Width, _bottom ) );

  FTotalDrawn := FTotalDrawn + AAvailableSpace;

  Result := FTotalDrawn = FHeight;

  FIsDrawFinished := Result;
end;

function TWPPageInfo.FindLine(AY: Integer): TWPLineInfo;
var
  li : TWPLineInfo;
begin
  Result := nil;
  for li in FLines do begin
    if (AY >= li.LineYStart) and ( AY <= li.LineBottom ) then
      Exit( li );
  end;
end;

procedure TWPPageInfo.ReadState( AReader: TBinaryReader );
begin
  FTotalDrawn := AReader.ReadInt32;
end;

procedure TWPPageInfo.Reset;
begin
  FTotalDrawn := 0;
  FIsDrawFinished := False;
end;

procedure TWPPageInfo.WriteState(AWriter: TBinaryWriter);
begin
  AWriter.Write( FTotalDrawn );
end;

{ TWPLineInfo }

constructor TWPLineInfo.Create(AY, AHeight: Integer);
begin
  LineYStart := AY;
  LineHeight := AHeight;
  LineBottom := AY + AHeight;
end;

function TWPLineInfo.Inside(AY: Integer): Boolean;
begin
  Result := ( AY > LineYStart ) and ( AY < LineBottom );
end;

end.
