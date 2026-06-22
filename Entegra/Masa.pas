unit Masa;

interface

uses
  Windows, math, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,stdctrls,
  ExtCtrls;

type


  TMasaTipi = ( mtDikdortgen, mtDaire );

  TMasa = class(TShape)
  private
    FMasaAdi  : String;
    FTipi     : TMasaTipi;
    FKapasite : Integer;
    FKenar1   : Integer;
    FKenar2   : Integer;
    FKenar3   : Integer;
    FKenar4   : Integer;
    FMasa1    : TMasa;
    FMasa2    : TMasa;
    FMasa3    : TMasa;
    FMasa4    : TMasa;
    FDurum    : String;
    FBirlestir: Boolean;
    FSiparisler : TStrings;
    Procedure SetKapasite(Value : integer);
    Procedure KenarlariTopla ;
    Procedure SetKenar1(Value : integer);
    Procedure SetKenar2(Value : integer);
    Procedure SetKenar3(Value : integer);
    Procedure SetKenar4(Value : integer);
    Procedure SetTipi(Value : TMasaTipi);
    Procedure MasalariYerlestir;
    Procedure SetMasa1(value : TMasa );
    Procedure SetMasa2(value : TMasa );
    Procedure SetMasa3(value : TMasa );
    Procedure SetMasa4(value : TMasa );
    procedure SetMasaAdi(const Value: String);
    function GetMasaAd: TStrings;
    procedure SetMasaAdlari(const Value: TStrings);
    procedure SetSiparisler(const Value: TStrings);
    procedure SetDurum(const Value: String);
    procedure SetBirlestir(const Value: Boolean);
  protected
    Procedure SandalyeCiz( S , X1, Y1, X2, Y2 : Integer );
    procedure Paint; override;
  public
    property Canvas;
    property Birlestir  : Boolean   Read FBirlestir  Write SetBirlestir default False;
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer);override;
    procedure Assign(Source: TPersistent); override;
    Function Siparis (Index : Integer ) : TStrings;
    Function SandalyeP(SandalyeNo, W, H : integer):tpoint;

  published

    property MasaAdi    : String    Read FMasaAdi    Write SetMasaAdi  ;
    property Tipi       : TMasaTipi Read FTipi       Write SetTipi     default mtDikdortgen;
    property Kapasite   : Integer   Read FKapasite   Write SetKapasite default 4;
    property Kenar1     : Integer   Read FKenar1     Write SetKenar1   default 1;
    property Kenar2     : Integer   Read FKenar2     Write SetKenar2   default 1;
    property Kenar3     : Integer   Read FKenar3     Write SetKenar3   default 1;
    property Kenar4     : Integer   Read FKenar4     Write SetKenar4   default 1;
    property Durum      : String    Read FDurum      Write SetDurum    ;
    property Masa1      : TMasa     Read FMasa1      Write SetMasa1    default nil;
    property Masa2      : TMasa     Read FMasa2      Write SetMasa2    default nil;
    property Masa3      : TMasa     Read FMasa3      Write SetMasa3    default nil;
    property Masa4      : TMasa     Read FMasa4      Write SetMasa4    default nil;
    ProPerty MasaAdlari : TStrings  Read GetMasaAd   Write SetMasaAdlari;
    ProPerty Siparisler : TStrings  Read FSiparisler Write SetSiparisler;

    property Font;
    property OnClick;
    property OnDblClick;

  end;
  function AraMasa1( m :TMasa; Form :Tform ) : Tmasa;
  function AraMasa2(m: TMasa; Form :Tform): Tmasa;
  function AraMasa3(m: TMasa; Form :Tform): Tmasa;
  function AraMasa4(m: TMasa; Form :Tform): Tmasa;
  function BosAd(nab:String;c:TComponent):String ;
  function MasaBul(MasaAdi:String; c:TWinControl):TMasa;
  function SayimiInt(s:String):Boolean;
  Procedure SandalyeleriYerlestir(ms : TMasa; W,H:Integer);

Procedure Parcala(st : String; var s:TStringList);

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Gurkan', [TMasa]);
end;

Procedure Parcala(st : String; var s:TStringList);
begin
   s.clear;
   while Pos(',', st)>0 do begin
         s.Add(copy(st, 1, Pos(',', st)-1));
         Delete(st, 1, Pos(',', st));
   end;
   s.add(st);
end;
Procedure SandalyeleriYerlestir(ms : TMasa; W,H:Integer);
var m : TMemo;
    s : TScrollBox;
    l : TLabel;
    i : integer;
begin

  for i := 0 to 100 do
  begin
    if ms.Parent.FindComponent( ms.Name+'_s'+IntToStr(i)) <> nil then
       ms.Parent.FindComponent( ms.Name+'_s'+IntToStr(i)).free;
  end;

  for i := 0 to ms.Kapasite do
  begin
    s := TScrollBox.Create( ms.parent );
    l := TLabel.Create( ms.Parent );
    m := TMemo.Create( ms.Parent );

    ms.parent.InsertControl(s);
    s.InsertControl(m);
    s.InsertControl(l);

    s.Name:=ms.Name+'_s'+ IntToStr(i);
    m.Name:=ms.Name+'_m'+ IntToStr(i);
    l.Name:=ms.Name+'_l'+ IntToStr(i);

    if i = 0 then l.Caption := 'Masa'
    else          l.Caption := inttostr(i)+' nolu Sandalye';
    l.Font.Style:=[fsbold];
    l.Font.Color:=clHighlight;

    s.Width  := W ;
    s.Height := H ;
    s.VertScrollBar.Size := 35 ;
    s.BorderStyle:=bsNone;

    m.BorderStyle := bsNone;
    m.Font.Style:=[];
    m.WordWrap:=False;
    m.Lines.Assign( ms.Siparis( i ) );
    m.Height := m.Lines.Count * ms.Canvas.TextHeight('1');
    m.Width  := s.Width - s.VertScrollBar.Size - 4;
    m.Top:=l.Height;

    if m.Height + m.top < s.Height then
    begin
      s.Height := m.Height + m.Top;
      m.Width  := W;
    end;

    s.Top  := ms.SandalyeP(i,s.Width,s.Height).y ; // - s.Height div 2;
    s.Left := ms.SandalyeP(i,s.Width,s.Height).x ; // - s.Width  div 2;

  end;

end;

function SayimiInt(s:String):Boolean;
var  I, Code: Integer;
begin
  Val( s, I, Code);
  Result := Code = 0 ;
  if I=0 then Result := Code = 0 ;
end;

function BosAd(nab:String;c:TComponent):String ;
var
  i : integer;
begin
  for i := 0 to maxint do
  begin
    if c.FindComponent(nab+inttostr(i)) = nil then break;
  end;
  Result:=nab+IntToStr(i);
end;
function MasaBul(MasaAdi:String; c:TWinControl):TMasa;
var i : integer;
begin
  Result:=nil;
  for i := 0 to C.ComponentCount-1 do
    if  (C.Components[i] is TMasa) then
    begin
      if TMasa(C.Components[i]).MasaAdi = MasaAdi then
      begin
        Result := TMasa(C.Components[i]);
        Exit;
      end;
    end;
end;
function AraMasa1(m: TMasa; Form :Tform): Tmasa;
var i : integer;
  tmpmasa:tmasa;
begin
  Result := nil;
  for i := 0 to Form.ComponentCount-1 do
  begin
    tmpmasa := nil;
    if Form.Components[i] is TMasa then
      tmpmasa:= TMasa(Form.Components[i]);
    if tmpmasa = m   then continue;
    if tmpmasa = nil then continue;
    if not tmpmasa.Visible then continue;
    if ( (tmpmasa.Left - 5) < m.Left ) and
       ( (tmpmasa.Left + 5) > m.Left ) and
       ( (tmpmasa.Top + tmpmasa.Height - 5) < m.Top ) and
       ( (tmpmasa.Top + tmpmasa.Height + 5) > m.Top )
    then
    begin
      Result := tmpmasa;
      exit;
    end;
  end;
end;
function AraMasa2(m: TMasa; Form :Tform): Tmasa;
var i : integer;
  tmpmasa:tmasa;
begin
  Result := nil;
  for i := 0 to Form.ComponentCount-1 do
  begin
    tmpmasa := nil;
    if Form.Components[i] is TMasa then
      tmpmasa:= TMasa(Form.Components[i]);
    if tmpmasa = m   then continue;
    if tmpmasa = nil then continue;
    if not tmpmasa.Visible then continue;
    if ( (tmpmasa.Left - 5) < m.Left + m.Width ) and
       ( (tmpmasa.Left + 5) > m.Left + m.Width ) and
       ( (tmpmasa.Top  - 5) < m.Top ) and
       ( (tmpmasa.Top  + 5) > m.Top )
    then
    begin
      Result := tmpmasa;
      exit;
    end;
  end;
end;

function AraMasa3(m: TMasa; Form :Tform): Tmasa;
var i : integer;
  tmpmasa:tmasa;
begin
  Result := nil;
  for i := 0 to Form.ComponentCount-1 do
  begin
    tmpmasa := nil;
    if Form.Components[i] is TMasa then
      tmpmasa:= TMasa(Form.Components[i]);
    if tmpmasa = m   then continue;
    if tmpmasa = nil then continue;
    if not tmpmasa.Visible then continue;
    if ( (tmpmasa.Left - 5) < m.Left ) and
       ( (tmpmasa.Left + 5) > m.Left ) and
       ( (tmpmasa.Top  - 5) < m.Top + m.Height ) and
       ( (tmpmasa.Top  + 5) > m.Top + m.Height )
    then
    begin
      Result := tmpmasa;
      exit;
    end;
  end;
end;

function AraMasa4(m: TMasa; Form :Tform): Tmasa;
var i : integer;
  tmpmasa:tmasa;
begin
  Result := nil;
  for i := 0 to Form.ComponentCount-1 do
  begin
    tmpmasa := nil;
    if Form.Components[i] is TMasa then
      tmpmasa:= TMasa(Form.Components[i]);
    if tmpmasa = m   then continue;
    if tmpmasa = nil then continue;
    if not tmpmasa.Visible then continue;
    if ( (tmpmasa.Left - tmpmasa.Width - 5) < m.Left ) and
       ( (tmpmasa.Left - tmpmasa.Width + 5) > m.Left ) and
       ( (tmpmasa.Top  - 5) < m.Top ) and
       ( (tmpmasa.Top  + 5) > m.Top )
    then
    begin
      Result := tmpmasa;
      exit;
    end;
  end;
end;
{ TMasa }

procedure TMasa.Assign(Source: TPersistent);
begin
  inherited;
  if not (Source is TMasa) then Exit;
  Kapasite := (Source as TMasa).Kapasite;
  Kenar1 := (Source as TMasa).Kenar1 ;
  Kenar2 := (Source as TMasa).Kenar2 ;
  Kenar3 := (Source as TMasa).Kenar3 ;
  Kenar4 := (Source as TMasa).Kenar4 ;
end;

constructor TMasa.Create(AOwner: TComponent);
begin
  inherited;
  Brush.Color:=$00D0E1F9;
  FSiparisler:=TStringList.Create;
  FKapasite:=4;
  FKenar1:=1;
  FKenar2:=1;
  FKenar3:=1;
  FKenar4:=1;
end;

function TMasa.GetMasaAd: TStrings;
var st:TStrings;
begin
  st:=TStringList.Create;
  st.CommaText:=MasaAdi;
  Result:=st;
end;

procedure TMasa.KenarlariTopla;
begin
  if Tipi = mtDikdortgen then
    FKapasite:= Kenar1+Kenar2+Kenar3+Kenar4;
  while Siparisler.Count <= FKapasite+1 do
    Siparisler.Add('');
end;

procedure TMasa.MasalariYerlestir;
begin
  if not Birlestir then exit ;
  if Masa1 <> nil then
  begin
    if Masa1.Top <> Top - Masa1.Height then
      Masa1.Top := Top - Masa1.Height;
    if Masa1.Left <> Left then
      Masa1.Left := Left;
  end;
  if Masa2 <> nil then
  begin
    if  Masa2.Top <> Top then
      Masa2.Top := Top ;
    if  Masa2.Left <> Left + Width then
      Masa2.Left := Left + Width;
  end;
  if Masa3 <> nil then
  begin
    if Masa3.Top <> Top+Height then
      Masa3.Top := Top+Height;
    if Masa3.Left <> Left then
      Masa3.Left := Left ;
  end;
  if Masa4 <> nil then
  begin
    if Masa4.Top <> Top then
      Masa4.Top := Top;
    if Masa4.Left <> Left-Masa4.Width then
      Masa4.Left := Left-Masa4.Width ;
  end;
end;

Function TMasa.SandalyeP(SandalyeNo, W, H : integer):tpoint;
var
  W2, H2, X, Y, XA, YA, i,sn : integer;
begin
  W2:=W DIV 2;
  H2:=H DIV 2;
  sn:=0;
  if sn = SandalyeNo then
  begin
    Result.X:=Width  div 2-W2;
    Result.Y:=Height div 2-H2;
  end;
  case Tipi of
    mtDikdortgen :
    begin
      XA := Width  div (Kenar1+1);
      X:=XA;
      for i := 1 to Kenar1 do
      begin
        inc(sn);
        if sn = SandalyeNo then
        begin
          Result.X:=X-w2;
          Result.Y:=1;
        end;
        inc(X,XA);
      end;
      YA := Height div (Kenar2+1);
      Y:=YA;
      for i := 1 to Kenar2 do
      begin
        inc(sn);
        if sn = SandalyeNo then
        begin
          Result.X:=Width-W-1;
          Result.Y:=Y-h2;
        end;
        inc(Y,YA);
      end;
      XA := Width  div (Kenar3+1);
      X := Width - XA;
      for i := 1 to Kenar3 do
      begin
        inc(sn);
        if sn = SandalyeNo then
        begin
          Result.X:=X-W2;
          Result.Y:=Height-H-1;
        end;
        dec(X,XA);
      end;
      YA := Height div (Kenar4+1);
      Y := Height - YA;
      for i := 1 to Kenar4 do
      begin
        inc(sn);
        if sn = SandalyeNo then
        begin
          Result.X:=1;
          Result.Y:=Y-H2;
        end;
        dec(Y,YA);
      end;
    end;
    mtDaire :
    begin
      for i := 0 to Kapasite -1 do
      begin
        X := Width  div 2 - round( cos( Pi*( i * 360 / kapasite +90 ) /180)* min(Width-w,Height-h) / 2  );
        Y := Height div 2 - round( sin( Pi*( i * 360 / kapasite +90 ) /180)* min(Width-w,Height-h) / 2  );
        SandalyeCiz(i+1, X-w2,Y-h2,X+w2,Y+h2);
        if sn = SandalyeNo then
        begin
          Result.X:=X;
          Result.Y:=Y;
        end;
      end;
    end;
  end;
  Result.X:=Result.X+Left;
  Result.Y:=Result.Y+Top;

end;

procedure TMasa.Paint;
var
  W, H, W2, H2, X, Y, XA, YA, i,sn : integer;
begin
  inherited;
  Canvas.Font.Assign(Font);
  W:=10;
  H:=10;
  W2:=5;
  H2:=5;
  case Tipi of
    mtDikdortgen :
    begin
      XA := Width  div (Kenar1+1);
      X:=XA;
      sn:=0;
      for i := 1 to Kenar1 do
      begin
        inc(sn);
        SandalyeCiz(sn, X-w2,0,X+w2,H);
        inc(X,XA);
      end;
      YA := Height div (Kenar2+1);
      Y:=YA;
      for i := 1 to Kenar2 do
      begin
        inc(sn); 
        SandalyeCiz(sn, Width-W,Y-h2,Width,Y+h2);
        inc(Y,YA);
      end;
      XA := Width  div (Kenar3+1);
      X := Width - XA;
      for i := 1 to Kenar3 do
      begin
        inc(sn);
        SandalyeCiz(sn, X-w2,Height-H,X+w2,Height);
        dec(X,XA);
      end;
      YA := Height div (Kenar4+1);
      Y := Height - YA;
      for i := 1 to Kenar4 do
      begin
        inc(sn);
        SandalyeCiz(sn, 0,Y-h2,W,Y+h2);
        dec(Y,YA);
      end;
    end;
    mtDaire :
    begin
      for i := 0 to Kapasite -1 do
      begin
        X := Width  div 2 - round( cos( Pi*( i * 360 / kapasite +90 ) /180)* min(Width-w,Height-h) / 2  );
        Y := Height div 2 - round( sin( Pi*( i * 360 / kapasite +90 ) /180)* min(Width-w,Height-h) / 2  );
        SandalyeCiz(i+1, X-w2,Y-h2,X+w2,Y+h2);
      end;
    end;
  end;
  Canvas.TextOut(Width div 2 - ( Canvas.TextWidth(MasaAdi) div 2 ), Height div 2 - ( Canvas.TextHeight(MasaAdi) div 2 ) , MasaAdi);
end;

procedure TMasa.SandalyeCiz(S ,X1, Y1, X2, Y2: Integer);
begin
  Canvas.Rectangle(X1, Y1, X2, Y2);
end;

procedure TMasa.SetBirlestir(const Value: Boolean);
begin
  FBirlestir := Value;
end;

procedure TMasa.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  MasalariYerlestir;
end;

procedure TMasa.SetDurum(const Value: String);
begin
  FDurum := Value;
end;

procedure TMasa.SetKapasite(Value: integer);
begin
  if Value < 0 then
    raise Exception.Create('Kapasite negatif değerli olamaz');
  case Tipi of
    mtDikdortgen : KenarlariTopla;
    mtDaire      : FKapasite:=Value;
  else ;
  end;
  while Siparisler.Count <= FKapasite + 1 do
    Siparisler.Add('');
  Paint;
end;

procedure TMasa.SetKenar1(Value: integer);
begin
  if Tipi = mtDaire then exit;
  if Value < 0 then
    raise Exception.Create('Kenar negatif değerli olamaz');
  FKenar1:=Value;
  KenarlariTopla;
  Paint;
end;

procedure TMasa.SetKenar2(Value: integer);
begin
  if Value < 0 then
    raise Exception.Create('Kenar negatif değerli olamaz');
  FKenar2:=Value;
  KenarlariTopla;
  Paint;
end;

procedure TMasa.SetKenar3(Value: integer);
begin
  if Value < 0 then
    raise Exception.Create('Kenar negatif değerli olamaz');
  FKenar3:=Value;
  KenarlariTopla;
  Paint;
end;

procedure TMasa.SetKenar4(Value: integer);
begin
  if Value < 0 then
    raise Exception.Create('Kenar negatif değerli olamaz');
  FKenar4:=Value;
  KenarlariTopla;
  Paint;
end;

procedure TMasa.SetMasa1(value: tmasa);
begin
  if value = Self then exit;
  FMasa1 := value ;
  if FMasa1 <> nil then
  begin
    if FMasa1 = FMasa2 then begin FMasa1:=nil; exit; end;
    if FMasa1 = FMasa3 then begin FMasa1:=nil; exit; end;
    if FMasa1 = FMasa4 then begin FMasa1:=nil; exit; end;
    if FMasa1.Masa3 <>  self then
      FMasa1.Masa3 :=  self;
  end;
  MasalariYerlestir;
end;

procedure TMasa.SetMasa2(value: tmasa);
begin
  if value = Self then exit;
  FMasa2 := value ;
  if FMasa2 <> nil then
  begin
    if FMasa2 = FMasa1 then begin FMasa2:=nil; exit; end;
    if FMasa2 = FMasa3 then begin FMasa2:=nil; exit; end;
    if FMasa2 = FMasa4 then begin FMasa2:=nil; exit; end;
    if FMasa2.Masa4 <>  self then
      FMasa2.Masa4 :=  self;
  end;
  MasalariYerlestir;
end;

procedure TMasa.SetMasa3(value: tmasa);
begin
  if value = Self then exit;
  FMasa3 := value ;
  if FMasa3 <> nil then
  begin
    if FMasa3 = FMasa1 then begin FMasa3:=nil; exit; end;
    if FMasa3 = FMasa2 then begin FMasa3:=nil; exit; end;
    if FMasa3 = FMasa4 then begin FMasa3:=nil; exit; end;
    if FMasa3.Masa1 <> self then
      FMasa3.Masa1 :=  self;
  end;
   MasalariYerlestir;
end;

procedure TMasa.SetMasa4(value: tmasa);
begin
  if value = Self then exit;
  FMasa4 := value ;
  if FMasa4 <> nil then
  begin
    if FMasa4 = FMasa1 then begin FMasa4:=nil; exit; end;
    if FMasa4 = FMasa2 then begin FMasa4:=nil; exit; end;
    if FMasa4 = FMasa3 then begin FMasa4:=nil; exit; end;
    if FMasa4.Masa2 <>  self then
     FMasa4.Masa2 :=  self;
  end;
   MasalariYerlestir;
end;
function StringListSayisalCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  if SayimiInt( List[Index1] ) and  SayimiInt( List[Index2] ) Then
    Result := StrToInt(List[Index1]) - StrToInt(List[Index2])
  else
    Result := AnsiCompareText(List[Index1],
                              List[Index2]);
end;
procedure TMasa.SetMasaAdi(const Value: String);
var
  i : integer;
  sl: TStringList; // Sorted List manaaaasında
begin
  if  Parent <> nil then
  for i := 0 to parent.ComponentCount-1 do
    if  (parent.Components[i] is TMasa) and (parent.Components[i]<>self) then
    begin
      if TMasa(parent.Components[i]).MasaAdi = Value then Exit;  //raise Exception.Create('Bu adda bir masa zaten mevcut')
    end;
  sl := TStringList.Create;
  sl.CommaText := Value;
  sl.CustomSort( StringListSayisalCompare );
  FMasaAdi := sl.CommaText;
  sl.free;
  paint;
end;

procedure TMasa.SetMasaAdlari(const Value: TStrings);
begin
  MasaAdi := Value.CommaText;
end;



procedure TMasa.SetSiparisler(const Value: TStrings);
begin
  FSiparisler := Value;
end;

procedure TMasa.SetTipi(Value: TMasaTipi);
begin
  FTipi:=Value;
  if Value = mtDaire then
    Shape := stEllipse;
  if Value = mtDikdortgen then
    Shape := stRoundRect;
  Paint;
end;

function TMasa.Siparis(Index: Integer): TStrings;
var
  st : TStringList;
begin
  st := TStringList.Create;
  if index<Siparisler.Count then
    st.CommaText := Siparisler[index];
    //Parcala(Siparisler[index],st);
  Result := st;
end;
begin
end.
