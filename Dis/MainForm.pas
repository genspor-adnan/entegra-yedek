unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  System.JSON, System.IOUtils, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TToothStatus = (tsNone, tsHealthy, tsCaries, tsFilled, tsRoot, tsCrown, tsImplant, tsFracture, tsMissing);
  TViewMode = (vmDentist, vmPatient);

  TToothItem = class
  public
    FDI: Integer;
    Universal: Integer;
    Rect: TRect;
    Status: TToothStatus;
    Selected: Boolean;
  end;

  TFormMain = class(TForm)
    TopPanel: TPanel;
    CmbView: TComboBox;
    BtnExport: TButton;
    BtnImport: TButton;
    BtnReset: TButton;
    RightPanel: TPanel;
    LblSel: TLabel;
    MemoJSON: TMemo;
    Paint: TPaintBox;
    Popup: TPopupMenu;
    miHealthy: TMenuItem;
    miCaries: TMenuItem;
    miFilled: TMenuItem;
    miRoot: TMenuItem;
    miCrown: TMenuItem;
    miImplant: TMenuItem;
    miFracture: TMenuItem;
    miSep: TMenuItem;
    miMissing: TMenuItem;
    miClear: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PaintPaint(Sender: TObject);
    procedure PaintMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MenuStatusClick(Sender: TObject);
    procedure CmbViewChange(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    procedure BtnImportClick(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
  private
    Teeth: TObjectList<TToothItem>;
    FView: TViewMode;
    SelectedTooth: TToothItem;
    FDI2Uni: TDictionary<Integer,Integer>;
    procedure BuildFDIMap;
    procedure BuildLayout;
    procedure DrawOdontogram;
    function  ToothAt(const P: TPoint): TToothItem;
    procedure SetSelected(T: TToothItem);
    procedure UpdateInfo;
    function  StatusToken(S: TToothStatus): string;
    function  TokenStatus(const S: string): TToothStatus;
    function  StatusNameTR(S: TToothStatus): string;
    procedure ApplyStatus(T: TToothItem; NewStatus: TToothStatus; ToggleMissing: Boolean = False);
    procedure DumpJSON;
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

{=========================== Form ===========================}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Caption := 'Dental Diyagram (Delphi 12 – VCL)';
  Teeth := TObjectList<TToothItem>.Create(True);
  FDI2Uni := TDictionary<Integer,Integer>.Create;

  // Görsel dokunuþlar
  Color := $0F1722;
  TopPanel.Color := $0D1620;
  RightPanel.Color := $121A22;
  MemoJSON.Color := $0F1722;
  MemoJSON.Font.Color := $DFE7EF;
  LblSel.Font.Color := $9FB0C3;

  // ComboBox
  CmbView.Items.Text := 'Hekim görünümü (FDI)' + sLineBreak + 'Hasta görünümü (ayna)';
  CmbView.ItemIndex := 0;
  FView := vmDentist;

  BuildFDIMap;
  BuildLayout;
  DumpJSON;

  DoubleBuffered := True;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  BuildLayout;
end;

{=========================== Veri ===========================}

procedure TFormMain.BuildFDIMap;
const
  MapArr: array[0..31] of Integer =
    (18,17,16,15,14,13,12,11, 21,22,23,24,25,26,27,28,
     38,37,36,35,34,33,32,31, 41,42,43,44,45,46,47,48);
var
  I: Integer;
begin
  FDI2Uni.Clear;
  for I := Low(MapArr) to High(MapArr) do
    FDI2Uni.AddOrSetValue(MapArr[I], I+1);
end;

procedure TFormMain.BuildLayout;
const
  UPPER_DENTIST: array[0..15] of Integer =
    (18,17,16,15,14,13,12,11, 21,22,23,24,25,26,27,28);
  LOWER_DENTIST: array[0..15] of Integer =
    (48,47,46,45,44,43,42,41, 31,32,33,34,35,36,37,38);
var
  Upper, Lower: TArray<Integer>;
  I, ToothW, ToothH, MarginX, Step, Cx, Cy, BaseTop, BaseBot, Amp, n: Integer;

  function Clone(const A: array of Integer): TArray<Integer>;
  var j: Integer;
  begin
    SetLength(Result, Length(A));
    for j := 0 to High(A) do
      Result[j] := A[j];
  end;

  function Rev(const A: array of Integer): TArray<Integer>;
  var j, len: Integer;
  begin
    len := Length(A);
    SetLength(Result, len);
    for j := 0 to len-1 do
      Result[j] := A[len-1-j];
  end;

var
  TI: TToothItem;
begin
  Teeth.Clear;

  if FView = vmDentist then
  begin
    Upper := Clone(UPPER_DENTIST);
    Lower := Clone(LOWER_DENTIST);
  end
  else
  begin
    Upper := Rev(UPPER_DENTIST);
    Lower := Rev(LOWER_DENTIST);
  end;

  ToothW := 38; ToothH := 50;
  MarginX := 50;
  Step := Max(1, (Paint.ClientWidth - MarginX*2) div 17); // 16 diþ + kenar
  BaseTop := 160;
  BaseBot := Max(BaseTop + 200, Paint.ClientHeight - 160);
  Amp := 32;
  n := 16;

  // üst sýra
  for I := 0 to n-1 do
  begin
    Cx := MarginX + Step*(I+1);
    Cy := BaseTop + Round(Sin(I/(n-1)*Pi) * (-Amp));
    TI := TToothItem.Create;
    TI.FDI := Upper[I];
    if FDI2Uni.ContainsKey(TI.FDI) then TI.Universal := FDI2Uni[TI.FDI];
    TI.Status := tsNone;
    TI.Rect := Rect(Cx - ToothW div 2, Cy - ToothH div 2, Cx + ToothW div 2, Cy + ToothH div 2);
    Teeth.Add(TI);
  end;

  // alt sýra
  for I := 0 to n-1 do
  begin
    Cx := MarginX + Step*(I+1);
    Cy := BaseBot + Round(Sin(I/(n-1)*Pi) * (Amp));
    TI := TToothItem.Create;
    TI.FDI := Lower[I];
    if FDI2Uni.ContainsKey(TI.FDI) then TI.Universal := FDI2Uni[TI.FDI];
    TI.Status := tsNone;
    TI.Rect := Rect(Cx - ToothW div 2, Cy - ToothH div 2, Cx + ToothW div 2, Cy + ToothH div 2);
    Teeth.Add(TI);
  end;

  Paint.Invalidate;
  UpdateInfo;
end;

{=========================== Çizim ===========================}

procedure RoundRectA(Canvas: TCanvas; const R: TRect; Radius: Integer; ColorFill, ColorStroke: TColor; AlphaFill: Byte = 255);
begin
  // basit alfa simülasyonu
  if AlphaFill < 255 then
    Canvas.Brush.Color := RGB(
      GetRValue(ColorFill) * AlphaFill div 255,
      GetGValue(ColorFill) * AlphaFill div 255,
      GetBValue(ColorFill) * AlphaFill div 255)
  else
    Canvas.Brush.Color := ColorFill;

  Canvas.Pen.Color := ColorStroke;
  Canvas.Pen.Width := 2;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Radius, Radius);
end;

procedure DrawCenteredText(Canvas: TCanvas; X, Y: Integer; const S: string; Color: TColor);
var
  W, H: Integer;
begin
  Canvas.Font.Color := Color;
  W := Canvas.TextWidth(S);
  H := Canvas.TextHeight(S);
  Canvas.TextOut(X - W div 2, Y - H div 2, S);
end;

function StatusColorDot(S: TToothStatus): TColor;
begin
  case S of
    tsHealthy:   Result := RGB(36,161,72);
    tsCaries:    Result := RGB(218,30,40);
    tsFilled:    Result := RGB(15,98,254);
    tsRoot:      Result := RGB(138,63,252);
    tsCrown:     Result := RGB(212,175,55);
    tsImplant:   Result := RGB(135,148,167);
    tsFracture:  Result := RGB(255,126,182);
  else
    Result := clNone;
  end;
end;

procedure TFormMain.DrawOdontogram;
var
  C: TCanvas;
  TItem: TToothItem;
  R: TRect;
  cx, cy: Integer;
  dot: TColor;
begin
  C := Paint.Canvas;
  C.Brush.Color := $121A22;
  C.FillRect(Paint.ClientRect);

  // kýlavuz çizgiler
  C.Pen.Color := $1C2734;
  C.Pen.Style := psDot;
  C.MoveTo(50, 200); C.LineTo(Paint.ClientWidth-50, 200);
  C.MoveTo(50, Paint.ClientHeight-200); C.LineTo(Paint.ClientWidth-50, Paint.ClientHeight-200);
  C.Pen.Style := psSolid;

  C.Font.Color := $DFE7EF;
  for TItem in Teeth do
  begin
    R := TItem.Rect;

    // seçili çerçeve
    if TItem.Selected then
    begin
      C.Pen.Color := RGB(87,180,255);
      C.Pen.Width := 3;
      C.Brush.Style := bsClear;
      C.RoundRect(R.Left-4, R.Top-4, R.Right+4, R.Bottom+4, 12, 12);
      C.Pen.Width := 2;
    end;

    // diþ gövdesi
    if TItem.Status = tsMissing then
      RoundRectA(C, R, 10, RGB(210,210,210), RGB(90,90,90), 180)
    else
      RoundRectA(C, R, 10, RGB(255,253,245), RGB(59,75,95));

    // etiketler
    DrawCenteredText(C, (R.Left+R.Right) div 2, R.Bottom + 12, IntToStr(TItem.FDI), $9FB0C3);
    DrawCenteredText(C, (R.Left+R.Right) div 2, R.Top - 10, IntToStr(TItem.Universal), $B9C7D6);

    // durum iþaretleri
    cx := (R.Left+R.Right) div 2;
    cy := (R.Top+R.Bottom) div 2;

    if TItem.Status = tsMissing then
    begin
      C.Pen.Color := RGB(218,30,40);
      C.Pen.Width := 3;
      C.MoveTo(R.Left+4, R.Top+4); C.LineTo(R.Right-4, R.Bottom-4);
      C.MoveTo(R.Left+4, R.Bottom-4); C.LineTo(R.Right-4, R.Top+4);
      C.Pen.Width := 2;
    end
    else
    begin
      dot := StatusColorDot(TItem.Status);
      if dot <> clNone then
      begin
        C.Brush.Color := dot; C.Pen.Color := dot;
        C.Ellipse(cx-4, cy-4, cx+4, cy+4);
      end;

      if TItem.Status = tsCrown then
      begin
        C.Pen.Color := RGB(212,175,55);
        C.MoveTo(R.Left+6, R.Top+10);
        C.LineTo(cx, R.Top-6);
        C.LineTo(R.Right-6, R.Top+10);
      end
      else if TItem.Status = tsImplant then
      begin
        C.Pen.Color := RGB(135,148,167);
        C.MoveTo(cx, R.Top+10); C.LineTo(cx, R.Bottom-10);
        C.MoveTo(cx-6, R.Bottom-16); C.LineTo(cx+6, R.Bottom-16);
        C.MoveTo(cx-6, R.Bottom-24); C.LineTo(cx+6, R.Bottom-24);
        C.MoveTo(cx-6, R.Bottom-32); C.LineTo(cx+6, R.Bottom-32);
      end
      else if TItem.Status = tsFracture then
      begin
        C.Pen.Color := RGB(255,126,182);
        C.MoveTo(R.Left+6, R.Top+6); C.LineTo(R.Right-6, R.Bottom-6);
      end;
    end;
  end;

  // alt ipucu
  C.Font.Color := $9FB0C3;
  C.TextOut(10, Paint.ClientHeight-22, 'Ýpucu: Sol týk seçer, Sað týk menü, Shift + Sol týk = Eksik/Var');
end;

procedure TFormMain.PaintPaint(Sender: TObject);
begin
  DrawOdontogram;
end;

{=========================== Etkileþim ===========================}

function TFormMain.ToothAt(const P: TPoint): TToothItem;
var
  TI: TToothItem;
begin
  Result := nil;
  for TI in Teeth do
    if PtInRect(TI.Rect, P) then
      Exit(TI);
end;

procedure TFormMain.SetSelected(T: TToothItem);
var
  X: TToothItem;
begin
  for X in Teeth do X.Selected := False;
  SelectedTooth := T;
  if Assigned(T) then T.Selected := True;
  UpdateInfo;
  Paint.Invalidate;
end;

procedure TFormMain.PaintMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TI: TToothItem;
begin
  TI := ToothAt(Point(X,Y));
  if not Assigned(TI) then Exit;

  case Button of
    mbLeft:
      if ssShift in Shift then
        ApplyStatus(TI, tsMissing, True)
      else
        SetSelected(TI);
    mbRight:
      begin
        SetSelected(TI);
        Popup.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
      end;
  end;
end;

procedure TFormMain.MenuStatusClick(Sender: TObject);
var
  S: TToothStatus;
begin
  if not Assigned(SelectedTooth) then Exit;
  S := TToothStatus((Sender as TMenuItem).Tag);
  ApplyStatus(SelectedTooth, S);
end;

procedure TFormMain.ApplyStatus(T: TToothItem; NewStatus: TToothStatus; ToggleMissing: Boolean);
begin
  if ToggleMissing then
  begin
    if T.Status = tsMissing then T.Status := tsNone
    else T.Status := tsMissing;
  end
  else
    T.Status := NewStatus;

  Paint.Invalidate;
  UpdateInfo;
  DumpJSON;
end;

procedure TFormMain.CmbViewChange(Sender: TObject);
begin
  if CmbView.ItemIndex = 0 then FView := vmDentist else FView := vmPatient;
  BuildLayout;
  DumpJSON;
end;

{=========================== Bilgi & JSON ===========================}

function TFormMain.StatusToken(S: TToothStatus): string;
begin
  case S of
    tsHealthy:  Result := 'healthy';
    tsCaries:   Result := 'caries';
    tsFilled:   Result := 'filled';
    tsRoot:     Result := 'root';
    tsCrown:    Result := 'crown';
    tsImplant:  Result := 'implant';
    tsFracture: Result := 'fracture';
    tsMissing:  Result := 'missing';
  else
    Result := '';
  end;
end;

function TFormMain.TokenStatus(const S: string): TToothStatus;
begin
  if S='healthy' then Exit(tsHealthy);
  if S='caries' then Exit(tsCaries);
  if S='filled' then Exit(tsFilled);
  if S='root' then Exit(tsRoot);
  if S='crown' then Exit(tsCrown);
  if S='implant' then Exit(tsImplant);
  if S='fracture' then Exit(tsFracture);
  if S='missing' then Exit(tsMissing);
  Result := tsNone;
end;

function TFormMain.StatusNameTR(S: TToothStatus): string;
begin
  case S of
    tsHealthy:  Result := 'Saðlýklý';
    tsCaries:   Result := 'Çürük';
    tsFilled:   Result := 'Dolgu';
    tsRoot:     Result := 'Kanal';
    tsCrown:    Result := 'Kuron';
    tsImplant:  Result := 'Ýmplant';
    tsFracture: Result := 'Kýrýk';
    tsMissing:  Result := 'Eksik';
  else
    Result := '—';
  end;
end;

procedure TFormMain.UpdateInfo;
var
  txt: string;
begin
  if Assigned(SelectedTooth) then
    txt := Format('Seçili diþ: FDI %d  |  Universal %d  |  Durum: %s',
      [SelectedTooth.FDI, SelectedTooth.Universal, StatusNameTR(SelectedTooth.Status)])
  else
    txt := 'Seçili diþ: —';
  LblSel.Caption := txt;
end;

procedure TFormMain.DumpJSON;
var
  Root, ObjState, O: TJSONObject;
  TI: TToothItem;
  VView: string;
begin
  Root := TJSONObject.Create;
  try
    if FView = vmDentist then VView := 'dentist' else VView := 'patient';
    Root.AddPair('view', VView);

    ObjState := TJSONObject.Create;
    Root.AddPair('state', ObjState);

    for TI in Teeth do
    begin
      if TI.Status = tsNone then Continue;
      O := TJSONObject.Create;
      O.AddPair('status', StatusToken(TI.Status));
      ObjState.AddPair(IntToStr(TI.FDI), O);
    end;

    // okunaklý JSON
 //   MemoJSON.Lines.Text := TJson.Format(Root);
  finally
    Root.Free;
  end;
end;

{=========================== Dosya Ýþleri ===========================}

procedure TFormMain.BtnExportClick(Sender: TObject);
var
  FN: string;
begin
  FN := TPath.Combine(TPath.GetDocumentsPath, 'dental-state.json');
  if PromptForFileName(FN, 'JSON|*.json', 'json', 'Kaydet', '', True) then
    TFile.WriteAllText(FN, MemoJSON.Lines.Text, TEncoding.UTF8);
end;

procedure TFormMain.BtnImportClick(Sender: TObject);
var
  FN, S, ViewStr: string;
  Root, StateObj, Entry: TJSONObject;
  Pair: TJSONPair;
  TI: TToothItem;
  FDI: Integer;
  JV, V: TJSONValue;
begin
  FN := TPath.Combine(TPath.GetDocumentsPath, 'dental-state.json');
  if not PromptForFileName(FN, 'JSON|*.json', 'json', 'Aç', '', False) then Exit;

  S := TFile.ReadAllText(FN, TEncoding.UTF8);
  Root := TJSONObject(TJSONObject.ParseJSONValue(S));
  try
    if Root = nil then raise Exception.Create('Geçersiz JSON');

    // görünüm
    JV := Root.Values['view'];
    if Assigned(JV) then ViewStr := JV.Value else ViewStr := 'dentist';
    if SameText(ViewStr, 'patient') then
    begin
      FView := vmPatient; CmbView.ItemIndex := 1;
    end
    else
    begin
      FView := vmDentist; CmbView.ItemIndex := 0;
    end;

    // tüm durumlarý temizle
    for TI in Teeth do TI.Status := tsNone;

    // durumlar
    V := Root.Values['state'];
    if (V <> nil) and (V is TJSONObject) then
    begin
      StateObj := TJSONObject(V);
      for Pair in StateObj do
      begin
        FDI := StrToIntDef(Pair.JsonString.Value, 0);
        Entry := Pair.JsonValue as TJSONObject;
        if Entry <> nil then
        begin
          JV := Entry.Values['status'];
          for TI in Teeth do
            if TI.FDI = FDI then
            begin
              if Assigned(JV) then
                TI.Status := TokenStatus(JV.Value)
              else
                TI.Status := tsNone;
              Break;
            end;
        end;
      end;
    end;

    BuildLayout;
    DumpJSON;
  finally
    Root.Free;
  end;
end;

procedure TFormMain.BtnResetClick(Sender: TObject);
var
  TI: TToothItem;
begin
  for TI in Teeth do
  begin
    TI.Status := tsNone;
    TI.Selected := False;
  end;
  SelectedTooth := nil;
  Paint.Invalidate;
  UpdateInfo;
  DumpJSON;
end;

end.

