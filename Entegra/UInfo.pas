unit UInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxMaskEdit, cxDropDownEdit, cxCalendar,  DateUtils,
  cxTextEdit, System.JSON, Vcl.ExtCtrls, Winapi.CommCtrl, Winapi.UxTheme;

type
  TInfoDlg = class(TForm)
    LvGecmis: TListView;
    LvDetay: TListView;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditEkleyen: TcxTextEdit;
    EditEklemeTrh: TcxDateEdit;
    EditDegistiren: TcxTextEdit;
    EditDegistirmeTrh: TcxDateEdit;
    cxButton1: TcxButton;
    procedure FormShow(Sender: TObject);
    procedure LvGecmisSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure LvGecmisCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    FJsonlar: TStringList;     // LvGecmis ile paralel: her kaydin BILGI json'u
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
  LW, LAlan, LDeger, LT, LO: Integer;
begin
  // --- Sol grid: gecmis (Tarih | Olay | Tipi) ---
  if LvGecmis.Columns.Count = 0 then
  begin
    with LvGecmis.Columns.Add do Caption := 'Tarih';
    with LvGecmis.Columns.Add do Caption := 'B'#$00F6'l'#$00FC'm';   // Bölüm: Başlık / Detay
    with LvGecmis.Columns.Add do Caption := 'Tipi';    // Ekleme/Değiştirme/Silme
  end;
  LW := LvGecmis.ClientWidth - 24;
  if LW < 160 then LW := 160;
  LT := LW * 6 div 12;   // Tarih genis
  LO := LW * 3 div 12;
  LvGecmis.Columns[0].Width := LT;
  LvGecmis.Columns[1].Width := LO;
  LvGecmis.Columns[2].Width := LW - LT - LO;

  // --- Sag grid: detay (Alan | Önceki | Sonraki) ---
  if LvDetay.Columns.Count = 0 then
  begin
    with LvDetay.Columns.Add do Caption := 'Alan';
    with LvDetay.Columns.Add do Caption := #$00D6'nceki';   // Önceki
    with LvDetay.Columns.Add do Caption := 'Sonraki';
  end;
  LW := LvDetay.ClientWidth - 24;
  if LW < 180 then LW := 180;
  LAlan  := LW * 2 div 12;
  LDeger := LW * 5 div 12;
  LvDetay.Columns[0].Width := LAlan;
  LvDetay.Columns[1].Width := LDeger;
  LvDetay.Columns[2].Width := LW - LAlan - LDeger;
end;

// Grid basliginin (header) OS temasini kaldirir -> klasik GRI baslik zemini.
procedure HeaderGriYap(ALV: TListView);
var
  H: HWND;
begin
  if (ALV = nil) or (not ALV.HandleAllocated) then Exit;
  H := HWND(SendMessage(ALV.Handle, LVM_GETHEADER, 0, 0));
  if H <> 0 then
    SetWindowTheme(H, '', '');
end;

procedure TInfoDlg.FormShow(Sender: TObject);
begin
   SutunlariHazirla;
   HeaderGriYap(LvGecmis);   // baslik zemini gri (ikisi de)
   HeaderGriYap(LvDetay);

   // Ust bilgi (ekleyen/degistiren). Tabloda bu kolonlar yoksa sessiz gec (crash yok).
   try
     Tablo.TablodanSorguAc(1,'select EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI from '+TabloAd+' where ID ='+IntToStr(ID));
     EditEkleyen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('EKLEYEN').AsInteger);
     EditDegistiren.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('DEGISTIREN').AsInteger);
     EditEklemeTrh.EditValue := Tablo.Query1.FieldByName('EKLEMETARIHI').AsDateTime;
     if YearOf(Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime) > 2000  then
        EditDegistirmeTrh.EditValue := Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime;
   except
   end;

   LogGecmisiYukle;
end;

// ISLEMLOG (yillik LOG<yyyy> birlesim view'i) uzerinden bu kaydin islem gecmisini
// solda tarih listesine yukler. Her satirin BILGI json'u FJsonlar'da, islem tipi
// LvGecmis satirinin Data'sinda (islem tipi) tutulur.
procedure TInfoDlg.LogGecmisiYukle;
var
  LSQL, LSat, LGorunum: string;
  LTip, LTabloID, LUstT: Integer;
  LUstK: Int64;
begin
  if not Assigned(FJsonlar) then FJsonlar := TStringList.Create;
  FJsonlar.Clear;
  LvGecmis.Items.Clear;
  LvDetay.Items.Clear;
  if ID <= 0 then Exit;

  // ISLEMLOG (synonym -> GENDEPO view) kullanilabilir mi? Henuz hic log yazilmamis
  // / view olusmamis olabilir. sys.synonyms + OBJECT_ID sorgusu HIC hata vermez;
  // yoksa sessiz cikariz -> exception olmaz (IDE debugger'inda da patlamaz).
  try
    Tablo.TablodanSorguAc(1,
      'select ISVAR=case when exists(select 1 from sys.synonyms s ' +
      'where s.name=''ISLEMLOG'' and OBJECT_ID(s.base_object_name) is not null) ' +
      'then 1 else 0 end');
    if Tablo.Query1.Fields[0].AsInteger = 0 then Exit;
  except
    Exit;
  end;

  // 1) Acilan kaydin ait oldugu MASTER (ust) anahtarini bul. Kayit master ise
  //    ust=kendisi; detay (ör. FATURA satiri) ise ust=FATBASLIK. Boylece nereden
  //    acilirsa acilsin ayni butun (master+detay) gorulur.
  LUstT := TabloNo;   // varsayilan: kendisi master
  LUstK := ID;
  try
    Tablo.TablodanSorguAc(1,
      'select top 1 USTTABLOID, USTKAYITID from ISLEMLOG ' +
      'where TABLOID=' + IntToStr(TabloNo) + ' and KAYITID=' + IntToStr(ID) +
      ' order by ID desc');
    if not Tablo.Query1.Eof then
    begin
      if not Tablo.Query1.FieldByName('USTTABLOID').IsNull then
        LUstT := Tablo.Query1.FieldByName('USTTABLOID').AsInteger;
      if not Tablo.Query1.FieldByName('USTKAYITID').IsNull then
        LUstK := Tablo.Query1.FieldByName('USTKAYITID').AsLargeInt;
    end;
  except
    Exit;   // ISLEMLOG view yoksa / erisim yoksa sessiz gec
  end;

  // 2) Ust altindaki TUM loglar. Master (TABLOID=USTTABLOID) USTTE, detaylar altta;
  //    her grup icinde en yeni ustte. TABLOLAR ile TABLOID->GORUNUM (Başlık/Detay).
  LSQL := 'select i.TARIH, i.ISLEMTIPI, i.TABLOID, t.GORUNUM, ' +
          'cast(DECOMPRESS(i.BILGI) as nvarchar(max)) as BILGI_JSON ' +
          'from ISLEMLOG i left join TABLOLAR t on t.TABLOID = i.TABLOID ' +
          'where i.USTKAYITID=' + IntToStr(LUstK);
  if LUstT > 0 then
    LSQL := LSQL + ' and i.USTTABLOID=' + IntToStr(LUstT);
  // Tarihe gore AZALAN (en yeni ustte); ayni tarihte master (Başlık) detaydan once.
  LSQL := LSQL + ' order by i.TARIH desc, case when i.TABLOID=i.USTTABLOID then 0 else 1 end, i.ID desc';

  try
    Tablo.TablodanSorguAc(1, LSQL);
  except
    Exit;
  end;

  while not Tablo.Query1.Eof do
  begin
    LTip := Tablo.Query1.FieldByName('ISLEMTIPI').AsInteger;
    LTabloID := Tablo.Query1.FieldByName('TABLOID').AsInteger;
    LGorunum := Tablo.Query1.FieldByName('GORUNUM').AsString;
    // Olay = TABLOLAR gorunum adi (Başlık/Detay); yoksa tablo kodu.
    LSat := LGorunum;
    if (LSat = '') and (LTabloID <> LUstT) then
      LSat := '[' + IntToStr(LTabloID) + ']';
    with LvGecmis.Items.Add do
    begin
      Caption := FormatDateTime('dd.mm.yyyy hh:nn',
                   Tablo.Query1.FieldByName('TARIH').AsDateTime);   // Tarih
      SubItems.Add(LSat);          // Olay
      SubItems.Add(IslemAd(LTip)); // Tipi
      Data := TObject(NativeInt(LTip));
    end;
    FJsonlar.Add(Tablo.Query1.FieldByName('BILGI_JSON').AsString);
    Tablo.Query1.Next;
  end;

  if LvGecmis.Items.Count > 0 then
    LvGecmis.Items[0].Selected := True;   // OnSelectItem -> detay dolar
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

procedure TInfoDlg.LvGecmisSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if not Selected then Exit;
  if (Item = nil) or (Item.Index < 0) or (Item.Index >= FJsonlar.Count) then
  begin
    LvDetay.Items.Clear;
    Exit;
  end;
  DetayGoster(FJsonlar[Item.Index], Integer(NativeInt(Item.Data)));
end;

// Satir rengi islem tipine gore: Ekleme yesil, Silme kirmizi, Degistirme mavi.
procedure TInfoDlg.LvGecmisCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  case Integer(NativeInt(Item.Data)) of
    0: Sender.Canvas.Font.Color := clRed;     // Silme
    1: Sender.Canvas.Font.Color := clGreen;   // Ekleme
    2: Sender.Canvas.Font.Color := clBlue;    // Değiştirme
  else
    Sender.Canvas.Font.Color := clWindowText;
  end;
  DefaultDraw := True;
end;

procedure TInfoDlg.FormDestroy(Sender: TObject);
begin
  FJsonlar.Free;
end;

end.
