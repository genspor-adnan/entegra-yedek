unit UInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxMaskEdit, cxDropDownEdit, cxCalendar,  DateUtils,
  cxTextEdit, System.JSON;

type
  TInfoDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditEkleyen: TcxTextEdit;
    EditEklemeTrh: TcxDateEdit;
    EditDegistiren: TcxTextEdit;
    EditDegistirmeTrh: TcxDateEdit;
    cxButton1: TcxButton;
    LabelGecmis: TLabel;
    LstTarihler: TListBox;
    LvDetay: TListView;
    procedure FormShow(Sender: TObject);
    procedure LstTarihlerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FJsonlar: TStringList;     // LstTarihler ile paralel: her kaydin BILGI json'u
    procedure SutunlariHazirla;
    procedure LogGecmisiYukle;
    procedure DetayGoster(const ABilgiJSON: string; ATip: Integer);
  public
    TabloAd: String;
    ID: Integer;
    TabloNo: Integer;          // ISLEMLOG.TABLOID filtresi (LOG.TABLOID / TabNo_*)
  end;

var
  InfoDlg: TInfoDlg;

implementation

   uses UTablo;
{$R *.dfm}

function IslemAd(ATip: Integer): string;
begin
  case ATip of
    0: Result := 'Silme';
    1: Result := 'Ekleme';
    2: Result := 'De'#$011F'i'#$015F'tirme';   // Değiştirme
  else
    Result := '?';
  end;
end;

function JsonDeger(V: TJSONValue): string;
begin
  if V = nil then
    Result := ''
  else if V is TJSONString then
    Result := TJSONString(V).Value
  else
    Result := V.ToString;
end;

procedure TInfoDlg.SutunlariHazirla;
var
  LW, LAlan, LDeger: Integer;
begin
  if LvDetay.Columns.Count = 0 then
  begin
    with LvDetay.Columns.Add do Caption := 'Alan';
    with LvDetay.Columns.Add do Caption := #$00D6'nceki';   // Önceki
    with LvDetay.Columns.Add do Caption := 'Sonraki';
  end;
  // Grid genisligine gore: Alan dar (~2/12), Onceki/Sonraki genis-esit (~5/12).
  // Dikey kaydirma cubugu payi dusulur.
  LW := LvDetay.ClientWidth - 24;
  if LW < 180 then LW := 180;
  LAlan  := LW * 2 div 12;
  LDeger := LW * 5 div 12;
  LvDetay.Columns[0].Width := LAlan;
  LvDetay.Columns[1].Width := LDeger;
  LvDetay.Columns[2].Width := LW - LAlan - LDeger;
end;

procedure TInfoDlg.FormShow(Sender: TObject);
begin
   SutunlariHazirla;

   Tablo.TablodanSorguAc(1,'select EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI from '+TabloAd+' where ID ='+IntToStr(ID));

   EditEkleyen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('EKLEYEN').AsInteger);
   EditDegistiren.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('DEGISTIREN').AsInteger);
   EditEklemeTrh.EditValue := Tablo.Query1.FieldByName('EKLEMETARIHI').AsDateTime;
   if YearOf(Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime) > 2000  then
      EditDegistirmeTrh.EditValue := Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime;

   LogGecmisiYukle;
end;

// ISLEMLOG (yillik LOG<yyyy> birlesim view'i) uzerinden bu kaydin islem gecmisini
// solda tarih listesine yukler. Her satirin BILGI json'u FJsonlar'da, islem tipi
// LstTarihler.Items.Objects'te tutulur.
procedure TInfoDlg.LogGecmisiYukle;
var
  LSQL: string;
  LTip: Integer;
begin
  if not Assigned(FJsonlar) then FJsonlar := TStringList.Create;
  FJsonlar.Clear;
  LstTarihler.Clear;
  LvDetay.Items.Clear;
  if ID <= 0 then Exit;

  LSQL := 'select TARIH,ISLEMTIPI,' +
          'cast(DECOMPRESS(BILGI) as nvarchar(max)) as BILGI_JSON ' +
          'from ISLEMLOG where KAYITID=' + IntToStr(ID);
  if TabloNo > 0 then
    LSQL := LSQL + ' and TABLOID=' + IntToStr(TabloNo);
  LSQL := LSQL + ' order by TARIH desc';

  try
    Tablo.TablodanSorguAc(1, LSQL);
  except
    Exit;   // ISLEMLOG view yoksa / erisim yoksa sessiz gec
  end;

  while not Tablo.Query1.Eof do
  begin
    LTip := Tablo.Query1.FieldByName('ISLEMTIPI').AsInteger;
    LstTarihler.Items.AddObject(
      FormatDateTime('dd.mm.yyyy hh:nn', Tablo.Query1.FieldByName('TARIH').AsDateTime) +
        '   ' + IslemAd(LTip),
      TObject(NativeInt(LTip)));
    FJsonlar.Add(Tablo.Query1.FieldByName('BILGI_JSON').AsString);
    Tablo.Query1.Next;
  end;

  if LstTarihler.Count > 0 then
  begin
    LstTarihler.ItemIndex := 0;
    LstTarihlerClick(nil);
  end;
end;

// Secili kaydin BILGI json'unu 3 sutunlu grid'e doker: Alan | Onceki | Sonraki.
//   Degisiklik: {"ALAN":{"e":..,"y":..}}  Tek deger: ekle->Sonraki, sil->Onceki.
procedure TInfoDlg.DetayGoster(const ABilgiJSON: string; ATip: Integer);
var
  LParsed: TJSONValue;
  LObj: TJSONObject;
  LPair: TJSONPair;
  LVal: TJSONValue;
  LItem: TListItem;
  LOnc, LSon: string;
begin
  LvDetay.Items.BeginUpdate;
  try
    LvDetay.Items.Clear;
    if Trim(ABilgiJSON) = '' then Exit;
    LParsed := TJSONObject.ParseJSONValue(ABilgiJSON);
    if not (LParsed is TJSONObject) then
    begin
      if LParsed <> nil then LParsed.Free;
      Exit;
    end;
    try
      LObj := TJSONObject(LParsed);
      for LPair in LObj do
      begin
        LVal := LPair.JsonValue;
        if LVal is TJSONObject then
        begin
          LOnc := JsonDeger(TJSONObject(LVal).GetValue('e'));
          LSon := JsonDeger(TJSONObject(LVal).GetValue('y'));
        end
        else
        begin
          if ATip = 0 then  // silme -> eski deger Onceki'de
          begin
            LOnc := JsonDeger(LVal);
            LSon := '';
          end
          else              // ekleme/diger -> deger Sonraki'de
          begin
            LOnc := '';
            LSon := JsonDeger(LVal);
          end;
        end;
        LItem := LvDetay.Items.Add;
        LItem.Caption := LPair.JsonString.Value;   // Alan
        LItem.SubItems.Add(LOnc);                   // Onceki
        LItem.SubItems.Add(LSon);                   // Sonraki
      end;
    finally
      LParsed.Free;
    end;
  finally
    LvDetay.Items.EndUpdate;
  end;
end;

procedure TInfoDlg.LstTarihlerClick(Sender: TObject);
var
  LIdx: Integer;
begin
  LIdx := LstTarihler.ItemIndex;
  if (LIdx < 0) or (LIdx >= FJsonlar.Count) then
  begin
    LvDetay.Items.Clear;
    Exit;
  end;
  DetayGoster(FJsonlar[LIdx], Integer(NativeInt(LstTarihler.Items.Objects[LIdx])));
end;

procedure TInfoDlg.FormDestroy(Sender: TObject);
begin
  FJsonlar.Free;
end;

end.
