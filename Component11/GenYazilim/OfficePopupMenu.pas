unit OfficePopupMenu;

{

****************************************************************
TOfficePopupMenu Office 2007 style customizable popup menu component
(C) 2008 by Henning Schaefer <henning.schaefer@gmail.com>.
All Rights reserved.

This component is based on the work of Zarko Gajic describing the
implementation of OwnerDraw Office-Style menus at

http://delphi.about.com/od/vclusing/a/2007ownerdraw.htm

Parts of the source code have been taken from the JEDI Code Library
(http://www.delphi-jedi.org). You may use, change, re-use and redistribute
both the component and it's source code if you include credits to Zarko, the
JEDI project and me within the source file provided users of the derived
component are not charged for using it.

This component is released as freeware. Redistribution on any media
is allowed as long as this notice is kept and no charge is collected.

Comments and suggestions are much appreciated.
****************************************************************

}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, ImgList, StdCtrls;

type TMenuAppearance = class(TPersistent)
     private
       privGradient1Start: TColor;
       privGradient1End: TColor;
       privGradient2Start: TColor;
       privGradient2End: TColor;

       privMarginX: Byte;
       privMarginY: Byte;
       privSeparatorLeading: Byte;
       privGutterWidth: Byte;

       privSeparatorBackgroundColor: TColor;
       privSeparatorLineColor: TColor;
       privGutterColor: TColor;
       privItemBackgroundColor: TColor;
       privItemSelectedColor: TColor;
       privFontColor: TColor;
       privFontDisabledColor: TColor;
     public
       procedure BecomeDefault;
       procedure BecomeLuna;
       procedure BecomeObsidian;
       procedure BecomeSilver;
       procedure BecomeVista;
     published
       property Gradient1Start: TColor read privGradient1Start write privGradient1Start;
       property Gradient1End: TColor read privGradient1End write privGradient1End;
       property Gradient2Start: TColor read privGradient2Start write privGradient2Start;
       property Gradient2End: TColor read privGradient2End write privGradient2End;

       property MarginX: Byte read privMarginX write privMarginX;
       property MarginY: Byte read privMarginY write privMarginY;
       property SeparatorLeading: Byte read privSeparatorLeading write privSeparatorLeading;
       property GutterWidth: Byte read privGutterWidth write privGutterWidth;

       property SeparatorBackgroundColor: TColor read privSeparatorBackgroundColor write privSeparatorBackgroundColor;
       property SeparatorLineColor: TColor read privSeparatorLineColor write privSeparatorLineColor;
       property GutterColor: TColor read privGutterColor write privGutterColor;
       property ItemBackgroundColor: TColor read privItemBackgroundColor write privItemBackgroundColor;
       property ItemSelectedColor: TColor read privItemSelectedColor write privItemSelectedColor;
       property FontColor: TColor read privFontColor write privFontColor;
       property FontDisabledColor: TColor read privFontDisabledColor write privFontDisabledColor;
     end;

type TMenuStyle = (msDefault, msOffice2007Luna, msOffice2007Obsidian, msOffice2007Silver, msVista);

type TGradientDirection = (gdVertical, gdHorizontal);

type
  TOfficePopupMenu = class(TPopupMenu)
  private
    { Private-Deklarationen }
    privOfficeDesign: boolean;
    privAppearance: TMenuAppearance;
    privMenuStyle: TMenuStyle;

    procedure SetOfficeDesign(design: boolean);
    function GetOfficeDesign: boolean;
    procedure SetAppearance(appearance: TMenuAppearance);
    function GetAppearance: TMenuAppearance;
    procedure SetStyle(style: TMenuStyle);
    function GetStyle: TMenuStyle;

    procedure SetHandlers(Root: TMenuItem);
    procedure RemoveHandlers(Root: TMenuItem);

    procedure DoPopup(sender: TObject); override;
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;
    procedure MeasureSeparator(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure SeparatorDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure MenuItemMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure MenuItemDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure DrawCheckedItem(FMenuItem: TMenuItem; Selected,
      HasImgLstBitmap: boolean; ACanvas: TCanvas; CheckedRect: TRect);
  published
    { Published-Deklarationen }
    procedure PopupAtCursor;
    property OfficeDesign: boolean read GetOfficeDesign write SetOfficeDesign;
    property Appearance: TMenuAppearance read GetAppearance write SetAppearance;
    property Style: TMenuStyle read GetStyle write SetStyle;
  end;

procedure Register;

implementation

{$R OfficePopupMenu.dcr}

uses types, Math;

procedure TMenuAppearance.BecomeDefault;
begin
MarginX := 4;
MarginY := 2;
SeparatorLeading := 6;
GutterWidth := 26;
SeparatorBackgroundColor := $00eee7dd;
SeparatorLineColor       := $00c5c5c5;
GutterColor               := $00eeeee9;
ItemBackgroundColor      := $00fafafa;
ItemSelectedColor        := $00e6d5cb;
FontColor                 := $006e1500;
FontDisabledColor        := $00dec5d8;
Gradient1Start            := $00efe8e4;
Gradient1End              := $00dec5b8;
Gradient2Start            := $00d8baab;
Gradient2End              := $00efe8e4;
end;

procedure TMenuAppearance.BecomeLuna;
begin
MarginX := 4;
MarginY := 2;
SeparatorLeading := 6;
GutterWidth := 36;
SeparatorBackgroundColor := clWhite;
SeparatorLineColor       := $00C5C5C5;
GutterColor               := $00F2DAC2;
ItemBackgroundColor      := clWhite;
ItemSelectedColor        := clNavy;
FontColor                 := clNavy;
FontDisabledColor        := clSilver;
Gradient1Start            := $00EBFDFF;
Gradient1End              := $00ABEBFF;
Gradient2Start            := $0069D6FF;
Gradient2End              := $0096E4FF;
end;

procedure TMenuAppearance.BecomeObsidian;
begin
MarginX := 4;
MarginY := 2;
SeparatorLeading := 6;
GutterWidth := 36;
SeparatorBackgroundColor := clWhite;
SeparatorLineColor       := $00C5C5C5;
GutterColor               := $00676767;
ItemBackgroundColor      := clWhite;
ItemSelectedColor        := $00464646;
FontColor                 := $00464646;
FontDisabledColor        := clSilver;
Gradient1Start            := $00EBFDFF;
Gradient1End              := $00ABEBFF;
Gradient2Start            := $0069D6FF;
Gradient2End              := $0096E4FF;
end;

procedure TMenuAppearance.BecomeSilver;
begin
MarginX := 4;
MarginY := 2;
SeparatorLeading := 6;
GutterWidth := 36;
SeparatorBackgroundColor := clWhite;
SeparatorLineColor       := $00C5C5C5;
GutterColor               := $00e0e4e7;
ItemBackgroundColor      := clWhite;
ItemSelectedColor        := $004c535c;
FontColor                 := $004c535c;
FontDisabledColor        := clSilver;
Gradient1Start            := $00EBFDFF;
Gradient1End              := $00ABEBFF;
Gradient2Start            := $0069D6FF;
Gradient2End              := $0096E4FF;
end;

procedure TMenuAppearance.BecomeVista;
begin
MarginX := 2;
MarginY := 2;
SeparatorLeading := 2;
GutterWidth := 28;
SeparatorBackgroundColor := $00E0E0E0;
SeparatorLineColor       := clWhite;
GutterColor               := $00f0f0f0;
ItemBackgroundColor      := $00f0f0f0;
ItemSelectedColor        := clNone;
FontColor                 := clBlack;
FontDisabledColor        := clSilver;
Gradient1Start            := $00F4F1EB;
Gradient1End              := $00F3EBDA;
Gradient2Start            := $00F3EBDA;
Gradient2End              := $00F4F1EB;
end;

constructor TOfficePopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  privAppearance := TMenuAppearance.Create;
  Appearance.BecomeDefault;
end;

destructor TOfficePopupMenu.Destroy;
begin
  privAppearance.Free;
  inherited;
end;

procedure TOfficePopupMenu.DoPopup(sender: TObject);
begin
  inherited;
  if privOfficeDesign = true then
    SetHandlers(Items)
  else
    RemoveHandlers(Items);
end;

procedure TOfficePopupMenu.PopupAtCursor;
begin
  self.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TOfficePopupMenu.SetOfficeDesign(design: boolean);
begin
  privOfficeDesign := design;
  if privOfficeDesign = true then
    SetHandlers(Items)
  else
    RemoveHandlers(Items);
end;

function TOfficePopupMenu.GetOfficeDesign: boolean;
begin
  result := privOfficeDesign;
end;

procedure TOfficePopupMenu.SetAppearance(appearance: TMenuAppearance);
begin
  if Assigned(privAppearance) then
    privAppearance.Free;  
  privAppearance := appearance;
end;

function TOfficePopupMenu.GetAppearance: TMenuAppearance;
begin
  result := privAppearance;
end;

procedure TOfficePopupMenu.SetStyle(style: TMenuStyle);
begin
  privMenuStyle := style;
  case ord(style) of
    0: Appearance.BecomeDefault;
    1: Appearance.BecomeLuna;
    2: Appearance.BecomeObsidian;
    3: Appearance.BecomeSilver;
    4: Appearance.BecomeVista;
  end;
end;

function TOfficePopupMenu.GetStyle: TMenuStyle;
begin
  result := privMenuStyle;
end;

procedure TOfficePopupMenu.SetHandlers(Root: TMenuItem);
var i: Word;
begin
  self.OwnerDraw := true;
  if Root.Count > 0 then begin
    for i := 0 to Root.Count - 1 do begin
      if Root[i].Caption = '-' then begin
        Root[i].OnMeasureItem := MeasureSeparator;
        Root[i].OnDrawItem := SeparatorDrawItem;
      end else begin
        Root[i].OnMeasureItem := MenuItemMeasureItem;
        Root[i].OnDrawItem := MenuItemDrawItem;
        if (Root[i].Count > 0) then
          SetHandlers(Root[i]);
      end;
    end;
  end;
end;

procedure TOfficePopupMenu.RemoveHandlers(Root: TMenuItem);
var i: Word;
begin
  self.OwnerDraw := false;
  if Root.Count > 0 then begin
    for i := 0 to Root.Count - 1 do begin
      Root[i].OnDrawItem := nil;
      Root[i].OnMeasureItem := nil;
      if (Root[i].Count > 0) then
        RemoveHandlers(Root[i]);
    end;
  end;
end;

function FillGradient(DC: HDC; ARect: TRect; ColorCount: Integer;
  StartColor, EndColor: TColor; ADirection: TGradientDirection): Boolean;
var
  StartRGB: array [0..2] of Byte;
  RGBKoef: array [0..2] of Double;
  Brush: HBRUSH;
  AreaWidth, AreaHeight, I: Integer;
  ColorRect: TRect;
  RectOffset: Double;
begin
  RectOffset := 0;
  Result := False;
  if ColorCount < 1 then
    Exit;
  StartColor := ColorToRGB(StartColor);
  EndColor := ColorToRGB(EndColor);
  StartRGB[0] := GetRValue(StartColor);
  StartRGB[1] := GetGValue(StartColor);
  StartRGB[2] := GetBValue(StartColor);
  RGBKoef[0] := (GetRValue(EndColor) - StartRGB[0]) / ColorCount;
  RGBKoef[1] := (GetGValue(EndColor) - StartRGB[1]) / ColorCount;
  RGBKoef[2] := (GetBValue(EndColor) - StartRGB[2]) / ColorCount;
  AreaWidth := ARect.Right - ARect.Left;
  AreaHeight :=  ARect.Bottom - ARect.Top;
  case ADirection of
    gdHorizontal:
      RectOffset := AreaWidth / ColorCount;
    gdVertical:
      RectOffset := AreaHeight / ColorCount;
  end;
  for I := 0 to ColorCount - 1 do
  begin
    Brush := CreateSolidBrush(RGB(
      StartRGB[0] + Round((I + 1) * RGBKoef[0]),
      StartRGB[1] + Round((I + 1) * RGBKoef[1]),
      StartRGB[2] + Round((I + 1) * RGBKoef[2])));
    case ADirection of
      gdHorizontal:
        SetRect(ColorRect, Round(RectOffset * I), 0, Round(RectOffset * (I + 1)), AreaHeight);
      gdVertical:
        SetRect(ColorRect, 0, Round(RectOffset * I), AreaWidth, Round(RectOffset * (I + 1)));
    end;
    OffsetRect(ColorRect, ARect.Left, ARect.Top);
    FillRect(DC, ColorRect, Brush);
    DeleteObject(Brush);
  end;
  Result := True;
end;


procedure TOfficePopupMenu.MeasureSeparator(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
var
  SeparatorHint: string;
  item: TMenuItem;
  r: TRect;
begin
  item := TMenuItem(sender);
  SeparatorHint := item.Hint;

  //Separator with text:
  if SeparatorHint <> '' then
  begin
    //Initialize
    r := rect(0, 0, 0, 0);
    ACanvas.Font.Style := [fsBold];

    //Make windows calculate needed space
    Height := drawText(ACanvas.Handle, PChar(SeparatorHint), length(SeparatorHint), r, DT_CALCRECT or DT_LEFT or DT_EXTERNALLEADING);
    width := r.Right - r.Left;

    //Give some extra room for padding:
    inc(Height, Appearance.MarginY*4);
    inc(Width,  Appearance.MarginX*2 + Appearance.SeparatorLeading);
  end
  else
  //Plain old separator:
  begin
    //Fixed height and width:
    height := 4;
    width := 10;
  end;
end;

//
// Drawing a menuseparator
//
procedure TOfficePopupMenu.SeparatorDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  hintStr: string;
  item: TMenuItem;
  r: TRect;
  hasGutter: boolean;
begin
  item := TMenuItem(sender);
  hasGutter := True;//item.GetImageList <> nil;

  //Background:
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := Appearance.SeparatorBackgroundColor;
  ACanvas.FillRect(ARect);

  //Lines:
  ACanvas.Pen.Color := Appearance.SeparatorLineColor;
  ACanvas.Polyline([point(ARect.Left, ARect.Bottom-2), point(ARect.Right, ARect.Bottom-2)]);
  ACanvas.Pen.Color := Appearance.ItemBackgroundColor;
  ACanvas.Polyline([point(ARect.Left, ARect.Bottom-1), point(ARect.Right, ARect.Bottom-1)]);

  //Text
  hintStr := item.Hint;
  if hintStr <> '' then
  begin
    //Text:
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Style := [fsBold];
    ACanvas.Font.Color := Appearance.FontColor;
    r.Left := ARect.Left + Appearance.MarginX;
    if hasGutter then
      inc(r.Left, Appearance.SeparatorLeading);
    r.Right := ARect.Right - Appearance.MarginX;
    r.Top := ARect.Top;
    r.Bottom := ARect.Bottom;
    DrawText(ACanvas.Handle, PChar(hintStr), length(hintStr), r, DT_LEFT or DT_EXTERNALLEADING or DT_SINGLELINE	or DT_VCENTER);
  end
  else if hasGutter then
  begin
   //Gutter
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := Appearance.GutterColor;
    r := ARect;
    r.Right := Appearance.GutterWidth;
    ACanvas.FillRect(r);

    ACanvas.Pen.Color := Appearance.SeparatorLineColor;
    ACanvas.Polyline([point(r.Right, r.top), point(r.Right, r.Bottom)]);
  end;
end;

//
// Measure a menuitems width and height
//
procedure TOfficePopupMenu.MenuItemMeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
var
  item: TMenuItem;

  captionStr: string;
  captionRect: TRect;
  captionHeight: integer;
  captionWidth: integer;

  hintStr: string;
  hintRect: TRect;
  hintHeight: integer;
  hintWidth: integer;

  shortCutStr: string;
  shortCutRect: TRect;
  shortCutHeight: integer;
  shortCutWidth: integer;
begin
  item := TMenuItem(sender);

  //Caption
  captionStr := item.Caption;
  captionRect := rect(0, 0, 0, 0);
  ACanvas.Font.Style := [fsBold];

  captionHeight := DrawText(ACanvas.Handle, PChar(captionStr), length(captionStr), captionRect, DT_CALCRECT or DT_LEFT or DT_EXTERNALLEADING);
  captionWidth  := captionRect.Right - captionRect.Left;

  //Shortcut:
  shortCutStr := ShortCutToText(item.ShortCut);
  if shortCutStr <> '' then
  begin
    shortCutRect := rect(0, 0, 0, 0);
    shortCutHeight := DrawText(ACanvas.Handle, PChar(shortCutStr), length(shortCutStr), shortCutRect, DT_CALCRECT or DT_RIGHT or DT_EXTERNALLEADING);
    shortCutWidth := shortCutRect.Right - shortCutRect.Left;
    inc(captionWidth, shortCutWidth + Appearance.MarginX*2);
  end;

  //Hint:
  hintRect := rect(0, 0, 0, 0);
  hintStr := item.Hint;
  ACanvas.Font.Style := [];

  hintHeight := DrawText(ACanvas.Handle, PChar(hintStr), length(hintStr), hintRect, DT_CALCRECT or DT_LEFT or DT_EXTERNALLEADING);
  hintWidth  := hintRect.Right - hintRect.Left;

  width := Max(captionWidth, hintWidth) + Appearance.MarginX*2;
  //if item.GetImageList <> nil then
    inc(width, Appearance.GutterWidth);

  height := captionHeight + hintHeight + Appearance.MarginY*4;
end;

//
// Drawing a menuitem
//
procedure TOfficePopupMenu.MenuItemDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  i: integer;
  hintStr: string;
  captionStr: string;
  shortCutStr: string;
  r: TRect;
  offset: integer;
  selRgn: HRGN;
  fillRgn: HRGN;
  hasGutter: boolean;
  item: TMenuItem;
begin
  item := TMenuItem(sender);
  hintStr := item.Hint;
  captionStr := item.Caption;
  hasGutter := True;//item.GetImageList <> nil;

  //Caption-hight:
  ACanvas.Font.Style := [fsBold];
  r := rect(0, 0, 0, 0);
  offset := DrawText(ACanvas.Handle, PChar(captionStr), length(captionStr), r, DT_CALCRECT or DT_EXTERNALLEADING or DT_TOP);

  //Backgrount
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := Appearance.ItemBackgroundColor;
  ACanvas.FillRect(ARect);

  //Gutter
  if hasGutter then
  begin
    ACanvas.Brush.Style := bsSolid;
    ACanvas.Brush.Color := Appearance.GutterColor;
    r := ARect;
    r.Right := Appearance.GutterWidth;
    ACanvas.FillRect(r);

    ACanvas.Pen.Color := Appearance.SeparatorLineColor;
    ACanvas.Polyline([point(r.Right, r.top), point(r.Right, r.Bottom)]);
  end;

  //Selection
  if selected then
  begin
    //Set a rounded rectangle as clip-region
    selRgn := CreateRoundRectRgn(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, 3, 3);
    SelectClipRgn(ACanvas.Handle, selRgn);

    if hintStr <> '' then
    begin
      //First gradient - caption
      r := ARect;
      r.Bottom := r.Top + offset + Appearance.MarginY*2;
      FillGradient(ACanvas.Handle, r, 256, Appearance.Gradient1Start, Appearance.Gradient1End, gdVertical);

      //Second gradient - description
      r.Top := r.Bottom;
      r.Bottom := ARect.Bottom;
      FillGradient(ACanvas.Handle, r, 256, Appearance.Gradient2Start, Appearance.Gradient2End, gdVertical);
    end
    else
    begin
      //Only one gradient under captoin
      r := ARect;
      FillGradient(ACanvas.Handle, r, 256, Appearance.Gradient1Start, Appearance.Gradient1End, gdVertical);
    end;

    //Release clipregion
    SelectClipRgn(ACanvas.Handle, 0);

    //Outline selection
    ACanvas.Pen.Color := Appearance.SeparatorLineColor;
    ACanvas.Brush.Style := bsClear;
    ACanvas.RoundRect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, 3, 3);
  end;

  //Caption
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Style := [fsBold];
  if item.Enabled then
    ACanvas.Font.Color := Appearance.FontColor
  else
    ACanvas.Font.Color := Appearance.FontDisabledColor;
  r.Left := ARect.Left + Appearance.MarginX;
  if hasGutter then
    inc(r.Left, Appearance.GutterWidth);
  r.Right := ARect.Right - Appearance.MarginX;
  r.Top := ARect.Top + Appearance.MarginY;
  r.Bottom := ARect.Bottom;
  DrawText(ACanvas.Handle, PChar(captionStr), length(captionStr), r, DT_LEFT or DT_EXTERNALLEADING or DT_TOP);

  //Shortcut
  shortCutStr := ShortCutToText(item.ShortCut);
  if shortCutStr <> '' then
  begin
    DrawText(ACanvas.Handle, PChar(shortCutStr), length(shortCutStr), r, DT_RIGHT or DT_EXTERNALLEADING or DT_TOP);
  end;

  //Hint
  ACanvas.Font.Style := [];
  if item.Enabled then
    ACanvas.Font.Color := Appearance.FontColor
  else
    ACanvas.Font.Color := Appearance.FontDisabledColor;
  r.Left := ARect.Left + Appearance.MarginX;
  if hasGutter then
    inc(r.Left, Appearance.GutterWidth);
  r.Right := ARect.Right - Appearance.MarginX;
  r.Top := ARect.Top + offset + Appearance.MarginY*2;
  r.Bottom := ARect.Bottom;
  DrawText(ACanvas.Handle, PChar(hintStr), length(hintStr), r, DT_LEFT or DT_EXTERNALLEADING or DT_TOP);
  DrawCheckedItem(item,Selected,False,ACanvas,Rect(ARect.Left+15,ARect.Top+5,ARect.Left + 25,ARect.Top+ 15));
  //Icon
  if (item.ImageIndex >= 0) and (item.GetImageList <> nil) then
  begin
    item.GetImageList.Draw(ACanvas, ARect.Left + Appearance.MarginX, ARect.Top + Appearance.MarginY, item.ImageIndex);
  end;
end;

procedure Register;
begin
  RegisterComponents('Win32', [TOfficePopupMenu]);
end;

procedure TOfficePopupMenu.DrawCheckedItem(FMenuItem: TMenuItem; Selected,
  HasImgLstBitmap: boolean; ACanvas: TCanvas; CheckedRect: TRect);
var
  X1, X2: integer;
begin
  if FMenuItem.RadioItem then
  begin
    if FMenuItem.Checked then
    begin

      ACanvas.Pen.color := Appearance.ItemSelectedColor;
      if selected then
        ACanvas.Brush.Color := Appearance.ItemBackgroundColor
      else
        ACanvas.Brush.Color := Appearance.GutterColor;
      ACanvas.Brush.Style := bsSolid;
      if HasImgLstBitmap then
      begin
        ACanvas.RoundRect(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom,
          6, 6);
      end
      else
      begin
        ACanvas.Ellipse(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
      end;
    end;
  end
  else
  begin
    if (FMenuItem.Checked) then
      if (not HasImgLstBitmap) then
      begin
        ACanvas.Pen.color := Appearance.ItemSelectedColor;
      if selected then
        ACanvas.Brush.Color := Appearance.ItemBackgroundColor
      else
        ACanvas.Brush.Color := Appearance.GutterColor;
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Rectangle(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
        ACanvas.Pen.color := clBlack;
        x1 := CheckedRect.Left + 1;
        x2 := CheckedRect.Top + 5;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 2;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 2;
        x2 := CheckedRect.Top + 5;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 2;
        x2 := CheckedRect.Top + 4;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Left + 5;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.LineTo(x1, x2);
           //-----------------

        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 3;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Right + 2;
        x2 := CheckedRect.Top - 1;
        ACanvas.LineTo(x1, x2);
           //--
        x1 := CheckedRect.Left + 4;
        x2 := CheckedRect.Bottom - 2;
        ACanvas.MoveTo(x1, x2);

        x1 := CheckedRect.Right - 2;
        x2 := CheckedRect.Top + 3;
        ACanvas.LineTo(x1, x2);

      end
      else
      begin
        ACanvas.Pen.color := Appearance.ItemSelectedColor;
        if selected then
          ACanvas.Brush.Color := Appearance.ItemBackgroundColor
        else
          ACanvas.Brush.Color := Appearance.GutterColor;
        ACanvas.Brush.Style := bsSolid;
        ACanvas.Rectangle(CheckedRect.Left, CheckedRect.Top,
          CheckedRect.Right, CheckedRect.Bottom);
      end;
  end;
end;

end.
