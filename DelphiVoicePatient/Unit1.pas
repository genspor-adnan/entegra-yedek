unit Unit1;

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.SysUtils, System.Classes, Vcl.Forms,
  Vcl.StdCtrls, Vcl.Controls, Vcl.Dialogs, ComObj, ActiveX, SpeechLib_TLB;

type
  TForm1 = class(TForm, ISpeechRecoContextEvents)
    btnBasla: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBaslaClick(Sender: TObject);
  private
    // SAPI nesneleri
    FRecognizer: ISpeechRecognizer;
    FRecoContext: ISpeechRecoContext;
    FGrammar: ISpeechRecoGrammar;
    FCookie: Integer;

    // Kayıt durumu
    FAd, FSoyad, FTelefon: string;
    FKayitVarmi: Boolean;
    FOutFile: string;

    procedure Log(const S: string);
    procedure YeniHasta;
    procedure SetAd(const S: string);
    procedure SetSoyad(const S: string);
    procedure SetTelefon(const S: string);
    procedure KaydetVeCik;

    // --- ISpeechRecoContextEvents ---
    procedure StartStream(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure EndStream(StreamNumber: Integer; StreamPosition: OleVariant; StreamReleased: WordBool); safecall;
    procedure Bookmark(StreamNumber: Integer; StreamPosition: OleVariant; BookmarkId: OleVariant; Options: SpeechBookmarkOptions); safecall;
    procedure SoundStart(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure SoundEnd(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure PhraseStart(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure Recognition(StreamNumber: Integer; StreamPosition: OleVariant; RecognitionType: SpeechRecognitionType; const Result: ISpeechRecoResult); safecall;
    procedure Hypothesis(StreamNumber: Integer; StreamPosition: OleVariant; const Result: ISpeechRecoResult); safecall;
    procedure PropertyNumberChange(StreamNumber: Integer; StreamPosition: OleVariant; const PropertyName: WideString; NewNumberValue: Integer); safecall;
    procedure PropertyStringChange(StreamNumber: Integer; StreamPosition: OleVariant; const PropertyName, NewStringValue: WideString); safecall;
    procedure FalseRecognition(StreamNumber: Integer; StreamPosition: OleVariant; const Result: ISpeechRecoResult); safecall;
    procedure Interference(StreamNumber: Integer; StreamPosition: OleVariant; Interference: SpeechInterference); safecall;
    procedure RequestUI(StreamNumber: Integer; StreamPosition: OleVariant; const UIType: WideString); safecall;
    procedure RecognizerStateChange(StreamNumber: Integer; StreamPosition: OleVariant; NewState: SpeechRecognizerState); safecall;
    procedure Adaptation(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure RecognitionForOtherContext(StreamNumber: Integer; StreamPosition: OleVariant); safecall;
    procedure AudioLevel(StreamNumber: Integer; StreamPosition: OleVariant; AudioLevel: Integer); safecall;
    procedure EnginePrivate(StreamNumber: Integer; StreamPosition: OleVariant; EngineData: OleVariant); safecall;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  CoInitialize(nil);
  FCookie := 0;
  FKayitVarmi := False;
  FOutFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'hastalar.tsv';
  Memo1.Clear;
  Memo1.Lines.Add('Hazır. "Başla"ya tıklayın.');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if FCookie <> 0 then
    InterfaceDisconnect(FRecoContext, ISpeechRecoContextEvents, Self, FCookie);
  FGrammar := nil;
  FRecoContext := nil;
  FRecognizer := nil;
  CoUninitialize;
end;

procedure TForm1.btnBaslaClick(Sender: TObject);
begin
  try
    FRecognizer := CoSpSharedRecognizer.Create;
    FRecoContext := FRecognizer.CreateRecoContext;
    InterfaceConnect(FRecoContext, ISpeechRecoContextEvents, Self, FCookie);
    FGrammar := FRecoContext.CreateGrammar(0);
    FGrammar.DictationLoad(EmptyParam);
    FGrammar.DictationSetState(SGDSActive);
    Log('Dinleniyor... Komutlar: "yeni hasta", "adı ...", "soyadı ...", "telefonu ...", "bitti"');
  except
    on E: Exception do
      Log('Hata: ' + E.Message);
  end;
end;

// ---------------- Yardımcılar ----------------

procedure TForm1.Log(const S: string);
begin
  Memo1.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + S);
end;

procedure TForm1.YeniHasta;
begin
  FAd := '';
  FSoyad := '';
  FTelefon := '';
  FKayitVarmi := True;
  Log('Yeni hasta kaydı başlatıldı.');
end;

procedure TForm1.SetAd(const S: string);
begin
  FAd := S.Trim;
  Log('Ad: ' + FAd);
end;

procedure TForm1.SetSoyad(const S: string);
begin
  FSoyad := S.Trim;
  Log('Soyad: ' + FSoyad);
end;

function OnlyDigits(const S: string): string;
var
  ch: Char;
begin
  Result := '';
  for ch in S do
    if CharInSet(ch, ['0'..'9']) then
      Result := Result + ch;
end;

procedure TForm1.SetTelefon(const S: string);
begin
  FTelefon := OnlyDigits(S);
  Log('Telefon: ' + FTelefon);
end;

procedure TForm1.KaydetVeCik;
var
  L, Old: TStringList;
  Satir: string;
  BaslikYaz: Boolean;
begin
  if not FKayitVarmi then
  begin
    Log('Kaydedilecek bir kayıt yok.');
    Application.Terminate;
    Exit;
  end;

  BaslikYaz := not FileExists(FOutFile);
  Satir := FAd + #9 + FSoyad + #9 + FTelefon;

  if BaslikYaz then
  begin
    L := TStringList.Create;
    try
      L.Add('Ad'#9'Soyad'#9'Telefon');
      L.Add(Satir);
      L.SaveToFile(FOutFile, TEncoding.UTF8);
    finally
      L.Free;
    end;
  end
  else
  begin
    Old := TStringList.Create;
    try
      Old.LoadFromFile(FOutFile, TEncoding.UTF8);
      Old.Add(Satir);
      Old.SaveToFile(FOutFile, TEncoding.UTF8);
    finally
      Old.Free;
    end;
  end;

  Log('Kaydedildi: ' + FOutFile);
  Application.Terminate;
end;

// -------------- SAPI Eventleri --------------

procedure TForm1.Recognition(StreamNumber: Integer; StreamPosition: OleVariant;
  RecognitionType: SpeechRecognitionType; const Result: ISpeechRecoResult);
var
  txt, low: string;

  function AfterKeyword(const key: string): string;
  var p: Integer;
  begin
    p := Pos(key, low);
    if p > 0 then
      Result := txt.Substring(p - 1 + key.Length).Trim
    else
      Result := '';
  end;

begin
  if Result = nil then Exit;
  txt := Result.GetText(0, -1, True);
  low := txt.ToLower;

  Log('Algılandı: ' + txt);

  if low.Contains('yeni hasta') then
  begin
    YeniHasta;
    Exit;
  end;

  if low.StartsWith('adı ') or low.Contains(' adı ') then
  begin
    SetAd(AfterKeyword('adı '));
    Exit;
  end;

  if low.StartsWith('soyadı ') or low.Contains(' soyadı ') then
 begin
    SetSoyad(AfterKeyword('soyadı '));
    Exit;
  end;

  if low.StartsWith('telefonu ') or low.Contains(' telefonu ') then
  begin
    SetTelefon(AfterKeyword('telefonu '));
    Exit;
  end;

  if low.Contains('bitti') then
  begin
    KaydetVeCik;
    Exit;
  end;
end;

procedure TForm1.StartStream(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.EndStream(StreamNumber: Integer; StreamPosition: OleVariant; StreamReleased: WordBool); begin end;
procedure TForm1.Bookmark(StreamNumber: Integer; StreamPosition: OleVariant; BookmarkId: OleVariant; Options: SpeechBookmarkOptions); begin end;
procedure TForm1.SoundStart(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.SoundEnd(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.PhraseStart(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.Hypothesis(StreamNumber: Integer; StreamPosition: OleVariant; const Result: ISpeechRecoResult); begin end;
procedure TForm1.PropertyNumberChange(StreamNumber: Integer; StreamPosition: OleVariant; const PropertyName: WideString; NewNumberValue: Integer); begin end;
procedure TForm1.PropertyStringChange(StreamNumber: Integer; StreamPosition: OleVariant; const PropertyName, NewStringValue: WideString); begin end;
procedure TForm1.FalseRecognition(StreamNumber: Integer; StreamPosition: OleVariant; const Result: ISpeechRecoResult); begin end;
procedure TForm1.Interference(StreamNumber: Integer; StreamPosition: OleVariant; Interference: SpeechInterference); begin end;
procedure TForm1.RequestUI(StreamNumber: Integer; StreamPosition: OleVariant; const UIType: WideString); begin end;
procedure TForm1.RecognizerStateChange(StreamNumber: Integer; StreamPosition: OleVariant; NewState: SpeechRecognizerState); begin end;
procedure TForm1.Adaptation(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.RecognitionForOtherContext(StreamNumber: Integer; StreamPosition: OleVariant); begin end;
procedure TForm1.AudioLevel(StreamNumber: Integer; StreamPosition: OleVariant; AudioLevel: Integer); begin end;
procedure TForm1.EnginePrivate(StreamNumber: Integer; StreamPosition: OleVariant; EngineData: OleVariant); begin end;

end.