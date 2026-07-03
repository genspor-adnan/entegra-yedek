unit UGirisKutusuEx;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Contnrs, ComCtrls, JvExExtCtrls, JvExtComponent, cxEditRepositoryItems,
  JvPanel, ImgList, cxImageComboBox, UFDCompatHelpers, DB, PngImageList, JvExControls, cxTextEdit, cxCurrencyEdit,
  JvButton, JvNavigationPane,UTouchKeyboardWindow, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxCore,
  cxDateUtils, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxSpinEdit, cxTimeEdit, System.ImageList, FireDAC.Comp.Client;

type

  TComboSelectionChanged = reference to procedure(AForm: TForm);

  TGirdiDenetimi = class;

  TGirdiDenetimleri = class;

  TDenetimTürü = (dtBilinmeyen,dtEdit,dtMemo,dtRichEdit, dtComboBox,dtDateTimePicker,dtImageComboBox, dtCurrencyEdit);

  TGirisKutusuEx = class(TForm)
    GridPaneli: TGridPanel;
    UstPanel: TJvPanel;
    AltPanel: TJvPanel;
    iptalButton: TButton;
    tamamButton: TButton;
    Label1: TLabel;
    BaslikLabel: TLabel;
    JvNavPanelButton1: TJvNavPanelButton;
    PngImageList1: TPngImageList;
    procedure FormDestroy(Sender: TObject);
    procedure tamamButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FGirdiDenetimleri : TGirdiDenetimleri;
    Klavye1:TKeyboardWindow;
    FDenetimSay : Integer;
  public
    { Public declarations }
    class function BilgiAl(ABaşlık: string;AGirdiler: TGirdiDenetimleri): TGirisKutusuEx;
    class function BilgiAlEx(ABaşlık: string;AGirdiler: TGirdiDenetimleri): TModalResult;
  end;

  TGirdiDenetimi = class(TObject)
  private
    FBaşlık: string;
    FDenetimTürü: TDenetimTürü;
    FVariant : PVariant;
    FGirdiBileşeni : TWinControl;
    FLabel : TLabel;
    FSatirYuksekligi : Integer;
    procedure SetBaşlık(const Value: string);
  protected
  public
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri: PVariant);virtual;
    destructor Destroy;override;
    function Hazırla(AGirisKutusu: TGirisKutusuEx;AEvSahibi : TGridPanel): TGirdiDenetimi;virtual;
    procedure HazırlamaBitti;Virtual;
    procedure DeğişkeneAktar;virtual;abstract;
    property Başlık: string read FBaşlık write SetBaşlık;
    property DenetimTürü : TDenetimTürü read FDenetimTürü;
  end;

  TEditDenetimi = class(TGirdiDenetimi)
  public
    function Hazırla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri : PVariant);override;
  end;

  TCurrencyEditDenetimi = class(TGirdiDenetimi)
  private
    FOndalikBasamakSay: SmallInt;
  public
    function Hazırla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri : PVariant; AOndalikBasamakSay:SmallInt);reintroduce;
  end;

  TMemoDenetimi = class(TGirdiDenetimi)
  public
    function Hazırla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri : PVariant);override;
  end;

  TRichEditDenetimi = class(TGirdiDenetimi)
  public
    function Hazırla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri : PVariant);override;
  end;

  TComboBoxDenetimi = class(TGirdiDenetimi)
  private
    FComboBoxStyle: TComboBoxStyle;
    FComboItemIndexKullan: Boolean;
    FListe: TStrings;
    FGenislik: Integer;   // 0 => varsayilan 210
    FOnSelectionChanged : TComboSelectionChanged;
    procedure SetComboBoxStyle(const Value: TComboBoxStyle);
    procedure OnComboSelectionChanged(Sender: TObject);
  public
    function Hazırla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;

    procedure DeğişkeneAktar; override;
    constructor Create(ABaşlık: string; ABaşlangıçDeğeri : PVariant;
      AListe : TStrings = nil; AComboŞekli : TComboBoxStyle = csDropDown;
      AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil;
      AGenislik: Integer = 0);reintroduce;
    procedure HazırlamaBitti; override;
    property ComboŞekli : TComboBoxStyle read FComboBoxStyle write SetComboBoxStyle;
    property ComboItemIndexKullan: Boolean read FComboItemIndexKullan write FComboItemIndexKullan;
    property Liste : TStrings read FListe write FListe;
  end;

  TDateTimePickerDenetimi = class(TGirdiDenetimi)
  private
    FDateTimeTürü: TDateTimeKind;
    FDateTimeBiçimi: string;
    procedure SetDateTimeBiçimi(const Value: string);
    procedure SetDateTimeTürü(const Value: TDateTimeKind);
    procedure cxDateEdit1PropertiesEditValueChanged(Sender: TObject);
  public
    constructor Create(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
      ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '');reintroduce;
    function Hazırla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    property DateTimeTürü : TDateTimeKind read FDateTimeTürü write SetDateTimeTürü;
    property DateTimeBiçimi : string read FDateTimeBiçimi write SetDateTimeBiçimi;
  end;

  TImageComboBoxDenetimi = class(TGirdiDenetimi)
  private
    FListeSQL: string;
    FImageList: TCustomImageList;
    FIndexiKullan: Boolean;
    FBağlantı : TFDConnection;
    procedure SetImageList(const Value: TCustomImageList);
    procedure SetListeSQL(const Value: string);
  public
    constructor Create(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
      ABağlantı: TFDConnection;
      AListeSql: string;AIndexiKullan: Boolean = False;AImageList: TCustomImageList = nil);reintroduce;
    function Hazırla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeğişkeneAktar; override;
    property ImageList : TCustomImageList read FImageList write SetImageList;
    property ListeSQL : string read FListeSQL write SetListeSQL;
    property IndexiKullan : Boolean read FIndexiKullan write FIndexiKullan;
  end;

  TGirdiDenetimleri = class(TObject)
  private
    FGirdiDenetimleri : TObjectList;
  public
    constructor Create;
    destructor Destroy;override;
    function Edit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TGirdiDenetimleri;
    function CurrencyEdit(ABaşlık: string; ABaşlangıçDeğeri : PVariant; OndalikBasamakSay:SmallInt): TGirdiDenetimleri;
    function Memo(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TGirdiDenetimleri;
    function RichEdit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TGirdiDenetimleri;
    function ComboBox(ABaşlık: string; ABaşlangıçDeğeri : PVariant;
        AListe : TStrings = nil; AComboŞekli : TComboBoxStyle = csDropDown;
        AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil;
        AGenislik: Integer = 0): TGirdiDenetimleri;
    function DateTimePicker(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
        ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
        TGirdiDenetimleri;
    function ImageComboBox(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
        ABağlantı: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
        AImageList: TCustomImageList = nil) : TGirdiDenetimleri;
    property GirdiDenetimleri : TObjectList read FGirdiDenetimleri;
  end;

var
  GirisKutusuEx: TGirisKutusuEx;

  { Denetim işlevleri }

  /// <summary>
  /// Standard Edit nesnesi ekler
  /// </summary>
  /// <param name="ABaşlık">Bileşenin kenarında görünecek olan başlık</param>
  /// <param name="ABaşlangıçDeğeri">Bileşen için gerekli olan ve ekran kapandıktan sonra bileşenin değerinin aktarılacağı variant pointer</param>
  /// <exception cref="EAccessViolation"><param name="ABaşlangıçDeğeri"/> parametresi nil olduğunda bu istisna fırlatılır</exception>
  /// <returns>TEditDenetimi</returns>
  function __Edit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TEditDenetimi;
  function __CurrencyEdit(ABaşlık: string;ABaşlangıçDeğeri : PVariant; OndalikBasamakSay:SmallInt): TCurrencyEditDenetimi;
  function __Memo(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TMemoDenetimi;
  function __RichEdit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TRichEditDenetimi;
  /// <summary>
  /// Standard ComboBox nesnesi ekler
  /// </summary>
  /// <param name="ABaşlık">Bileşenin kenarında görünecek olan başlık</param>
  /// <param name="ABaşlangıçDeğeri">Bileşen için gerekli olan ve ekran kapandıktan sonra bileşenin değerinin aktarılacağı variant pointer</param>
  /// <param name="AListe">ComboBox nesnesini doldurmak için kullanılacak TStrings den türetilmiş liste örneği</param>
  /// <param name="AComboŞekli">ComboBox'ın nasıl davranacağını belirleyen parametre</param>
  /// <param name="AComboBoxItemIndexKullan">Dönüş değeri için ItemIndex mi yoksa Text özelliği mi kullanılacağını belirten parametre</param>
  /// <exception cref="EAccessViolation"><param name="ABaşlangıçDeğeri"/> parametresi nil olduğunda bu istisna fırlatılır</exception>
  /// <returns>TComboBoxDenetimi</returns>
  function __ComboBox(ABaşlık: string; ABaşlangıçDeğeri : PVariant;
        AListe : TStrings = nil; AComboŞekli : TComboBoxStyle = csDropDown;
        AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil;
        AGenislik: Integer = 0): TComboBoxDenetimi;
  /// <summary>
  /// Standard DateTimePicker nesnesi ekler
  /// </summary>
  /// <param name="ABaşlık">Bileşenin kenarında görünecek olan başlık</param>
  /// <param name="ABaşlangıçDeğeri">Bileşen için gerekli olan ve ekran kapandıktan sonra bileşenin değerinin aktarılacağı variant pointer</param>
  /// <param name="ADateTimeTürü">Zaman mı yoksa tarih mi düzenlenecek onu belirten parametre</param>
  /// <param name="ADateTimeBiçimi">dtkCustom seçildiğinde istenen biçimin belirtileceği parametre</param>
  /// <exception cref="EAccessViolation"><param name="ABaşlangıçDeğeri"/> parametresi nil olduğunda bu istisna fırlatılır</exception>
  /// <returns></returns>
  function __DateTimePicker(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
        ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
        TDateTimePickerDenetimi;
  /// <summary>
  /// DevExpress firmasının TcxImageComboBox bileşenini ekler
  /// </summary>
  /// <param name="ABaşlık">Bileşenin kenarında görünecek olan başlık</param>
  /// <param name="ABaşlangıçDeğeri">Bileşen için gerekli olan ve ekran kapandıktan sonra bileşenin değerinin aktarılacağı variant pointer</param>
  /// <param name="ABağlantı"><see cref="AListeSql"/> parametresinin çalıştırılacağı bağlantı örneği</param>
  /// <param name="AListeSql">Properties.Items özelliğini doldurmak için kullanılacak sql ifadesi</param>
  /// <param name="AIndexiKullan">Dönüş değeri için ItemIndex mi yoksa Properties.Items[x].Value değeri mi kullanılacağını belirten parametre</param>
  /// <param name="AImageList">Listelenirken kullanılacak TCustomImageList bileşeni.Bunun için sql sorgusunda 3 ncü bir alan dönmesi gerekir.</param>
  /// <returns>TDateTimePickerDenetimi</returns>
  function __ImageComboBox(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
        ABağlantı: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
        AImageList: TCustomImageList = nil) : TImageComboBoxDenetimi;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, Fetautil,LocOnFly,PrjConst;

{$R *.dfm}

function __Edit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TEditDenetimi;
begin
  Result := TEditDenetimi.Create(ABaşlık,ABaşlangıçDeğeri);
end;

function __CurrencyEdit(ABaşlık: string;ABaşlangıçDeğeri : PVariant; OndalikBasamakSay:SmallInt): TCurrencyEditDenetimi;
begin
  Result := TCurrencyEditDenetimi.Create(ABaşlık, ABaşlangıçDeğeri, OndalikBasamakSay);
end;

function __Memo(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TMemoDenetimi;
begin
  Result := TMemoDenetimi.Create(ABaşlık,ABaşlangıçDeğeri);
end;

function __RichEdit(ABaşlık: string;ABaşlangıçDeğeri : PVariant): TRichEditDenetimi;
begin
  Result := TRichEditDenetimi.Create(ABaşlık,ABaşlangıçDeğeri);
end;

function __ComboBox(ABaşlık: string; ABaşlangıçDeğeri : PVariant;
      AListe : TStrings = nil; AComboŞekli : TComboBoxStyle = csDropDown;
      AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil;
      AGenislik: Integer = 0): TComboBoxDenetimi;
begin
  Result := TComboBoxDenetimi.Create(ABaşlık,ABaşlangıçDeğeri,AListe, AComboŞekli,AComboBoxItemIndexKullan, ASelectionChanged, AGenislik);
end;


function __DateTimePicker(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
      ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
      TDateTimePickerDenetimi;
begin
    Result := TDateTimePickerDenetimi.Create(ABaşlık, ABaşlangıçDeğeri, ADateTimeTürü, ADateTimeBiçimi);
end;

function __ImageComboBox(ABaşlık: string;ABaşlangıçDeğeri: PVariant;
      ABağlantı: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
      AImageList: TCustomImageList = nil) : TImageComboBoxDenetimi;
begin
  Result := TImageComboBoxDenetimi.Create(ABaşlık,ABaşlangıçDeğeri,ABağlantı, AListeSQL, AIndexiKullan,AImageList);
end;                          


{ TGirdiDenetimi }

constructor TGirdiDenetimi.Create(ABaşlık: string; ABaşlangıçDeğeri: PVariant);
begin
  FVariant := ABaşlangıçDeğeri;
  FBaşlık := ABaşlık;
  FDenetimTürü := dtBilinmeyen;
  FSatirYuksekligi := 20;
end;

destructor TGirdiDenetimi.Destroy;
begin
  inherited;
end;

function TGirdiDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;AEvSahibi : TGridPanel): TGirdiDenetimi;
var
  idx : Integer;
begin
  with AEvSahibi.RowCollection.Add do begin
    SizeStyle := ssAbsolute;
    Value := 15;
  end;
  with AEvSahibi.RowCollection.Add do begin
    SizeStyle := ssAbsolute;
    Value := FSatirYuksekligi;
  end;
  FLabel := TLabel.Create(AGirisKutusu);
  FLabel.Parent := AEvSahibi;
  FLabel.Caption := FBaşlık;
  FLabel.Align := alLeft;
  FLabel.Width:=600;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 2] := FLabel;
end;

procedure TGirdiDenetimi.HazırlamaBitti;
begin

end;

procedure TGirdiDenetimi.SetBaşlık(const Value: string);
begin
  FBaşlık := Value;
end;

class function TGirisKutusuEx.BilgiAl(ABaşlık: string; AGirdiler: TGirdiDenetimleri): TGirisKutusuEx;
var
  denetim : Pointer;
begin
  Result := TGirisKutusuEx.Create(Application);
  Result.FGirdiDenetimleri := AGirdiler;
  for denetim in Result.FGirdiDenetimleri.GirdiDenetimleri  do begin
    TGirdiDenetimi(denetim).Hazırla(Result,Result.GridPaneli);
  end;
  for denetim in Result.FGirdiDenetimleri.GirdiDenetimleri  do begin
    TGirdiDenetimi(denetim).HazırlamaBitti;
  end;
  Result.BaslikLabel.Caption := ABaşlık;
  Result.Caption := ABaşlık;
end;

class function TGirisKutusuEx.BilgiAlEx(ABaşlık: string;
  AGirdiler: TGirdiDenetimleri): TModalResult;
begin
  with BilgiAl(ABaşlık,AGirdiler) do
  try
    Result := ShowModal;
  finally
    Free;
  end;
end;

procedure TGirisKutusuEx.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Klavye1<>nil then
    FreeAndNil(Klavye1);
end;

procedure TGirisKutusuEx.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TGirisKutusuEx.FormDestroy(Sender: TObject);
begin
  FGirdiDenetimleri.Free;
end;

procedure TGirisKutusuEx.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=27 then
     if Klavye1<>Nil then
        FreeAndNil(Klavye1);
end;

procedure TGirisKutusuEx.FormShow(Sender: TObject);
var
  i : Integer;
  w : Integer;
begin
  w := 0;
  for I := 0 to FGirdiDenetimleri.GirdiDenetimleri.Count - 1 do begin
    w := w + TGirdiDenetimi( FGirdiDenetimleri.FGirdiDenetimleri[i]).FSatirYuksekligi + 15;
  end;
  Height := UstPanel.Height + AltPanel.Height + w + 80;//50
//  Height := UstPanel.Height + AltPanel.Height + 100 + ((
//    FGirdiDenetimleri.GirdiDenetimleri.Count div 2) * 35);
end;

procedure TGirisKutusuEx.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;

end;

procedure TGirisKutusuEx.tamamButtonClick(Sender: TObject);
var
  denetim: TGirdiDenetimi;
  I: Integer;
begin
  //
  for I := 0 to FGirdiDenetimleri.GirdiDenetimleri.Count - 1 do begin
    denetim := TGirdiDenetimi(FGirdiDenetimleri.GirdiDenetimleri[i]);
    denetim.DeğişkeneAktar;
  end;
  ModalResult := mrOK;
end;

{ TEditDenetimi }

constructor TEditDenetimi.Create(ABaşlık: string; ABaşlangıçDeğeri: PVariant);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FDenetimTürü := dtEdit;
end;

procedure TEditDenetimi.DeğişkeneAktar;
begin
  FVariant^ := TcxTextEdit(FGirdiBileşeni).Text;
end;

function TEditDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TcxTextEdit.Create(AGirisKutusu);
  with TcxTextEdit(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
      Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TCurrencyEditDenetimi }

constructor TCurrencyEditDenetimi.Create(ABaşlık: string; ABaşlangıçDeğeri: PVariant; AOndalikBasamakSay:SmallInt);
begin
  inherited Create(ABaşlık, ABaşlangıçDeğeri);
  FDenetimTürü := dtCurrencyEdit;
  FOndalikBasamakSay := AOndalikBasamakSay;
end;

procedure TCurrencyEditDenetimi.DeğişkeneAktar;
begin
  FVariant^ := TcxCurrencyEdit(FGirdiBileşeni).Value;
end;

function TCurrencyEditDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TcxCurrencyEdit.Create(AGirisKutusu);
  with TcxCurrencyEdit(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    FormatDuzenle(Properties, FOndalikBasamakSay);
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
       Value := FVariant^;
      //Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TMemoDenetimi }


constructor TMemoDenetimi.Create(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FDenetimTürü := dtMemo;
end;

procedure TMemoDenetimi.DeğişkeneAktar;
begin
  FVariant^ := TMemo(FGirdiBileşeni).Text;
end;

function TMemoDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  FSatirYuksekligi := 210;
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TMemo.Create(AGirisKutusu);
  with TMemo(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Height := 230;
    Width := 550;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
      Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TRichEditDenetimi }

constructor TRichEditDenetimi.Create(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FDenetimTürü := dtRichEdit;
end;

procedure TRichEditDenetimi.DeğişkeneAktar;
var
  memStream: TMemoryStream;
  strList: TStringList;
  Abc:Variant;
  j:integer;
begin
  memStream := TMemoryStream.Create;
  strList := TStringList.Create;

  try
    TRichEdit(FGirdiBileşeni).Lines.SaveToStream(memStream );
    memStream.Position := 0;
    strList.LoadFromStream(memStream);
    for j := 0 to strList.count - 1 do
     Abc:=Abc +strList.Strings[j];

    FVariant^ :=Abc; //strList.Text;
  finally
    memStream.Free;
    strList.Free;
  end;
end;

function TRichEditDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  FSatirYuksekligi := 210;
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TRichEdit.Create(AGirisKutusu);
  with TRichEdit(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    PlainText := False;
    Height := 230;
    Width := 550;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
      Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TComboBoxDenetimi }

constructor TComboBoxDenetimi.Create(ABaşlık: string;
  ABaşlangıçDeğeri : PVariant;AListe : TStrings = nil;
  AComboŞekli : TComboBoxStyle = csDropDown;
  AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil;
  AGenislik: Integer = 0);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FDenetimTürü := dtComboBox;
  FComboBoxStyle := AComboŞekli;
  FComboItemIndexKullan := AComboBoxItemIndexKullan;
  FListe := AListe;
  FGenislik := AGenislik;
  FOnSelectionChanged := ASelectionChanged;
end;

procedure TComboBoxDenetimi.DeğişkeneAktar;
begin
  if FComboItemIndexKullan then
    FVariant^ := TComboBox(FGirdiBileşeni).ItemIndex
  else
    FVariant^ := TComboBox(FGirdiBileşeni).Text;
end;

function TComboBoxDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
var
  i : Integer;
  idx : Integer;
  selTxt: string;
begin
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TComboBox.Create(AGirisKutusu);
  with TComboBox(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    if FGenislik > 0 then Width := FGenislik else Width := 210;
    Style := FComboBoxStyle;
    OnChange := OnComboSelectionChanged;
    if Assigned(FVariant) then
      selTxt := VarToStr(FVariant^);
    idx := -1;
    if Assigned(FListe) then begin
      for i := 0 to FListe.Count - 1 do begin
        Items.Add(FListe[i]);
        if (FComboBoxStyle = csDropDownList) AND (selTxt = FListe[i]) and (idx = -1) then begin
          idx := i;
        end;
      end;
    end;
    if (FComboBoxStyle = csDropDownList) then
      ItemIndex := idx
    else
      Text := selTxt;

    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

procedure TComboBoxDenetimi.HazırlamaBitti;
begin
  inherited;
  OnComboSelectionChanged(nil);
end;

procedure TComboBoxDenetimi.OnComboSelectionChanged(Sender: TObject);
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(TForm(TComboBox(FGirdiBileşeni).Owner));
end;

procedure TComboBoxDenetimi.SetComboBoxStyle(const Value: TComboBoxStyle);
begin
  FComboBoxStyle := Value;
  TComboBox(FGirdiBileşeni).Style := Value;
end;

{ TDateTimePickerDenetimi }

constructor TDateTimePickerDenetimi.Create(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant; ADateTimeTürü: TDateTimeKind;
  ADateTimeBiçimi: string);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FDenetimTürü := dtDateTimePicker;
  FDateTimeBiçimi := ADateTimeBiçimi;
  FDateTimeTürü := ADateTimeTürü;
end;

procedure TDateTimePickerDenetimi.DeğişkeneAktar;
begin
  FVariant^ := TcxDateEdit(FGirdiBileşeni).EditValue;
end;

procedure TDateTimePickerDenetimi.cxDateEdit1PropertiesEditValueChanged(Sender: TObject);
begin
  (Sender as TcxDateEdit).PostEditValue;
end;

function TDateTimePickerDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TcxDateEdit.Create(AGirisKutusu);
  with TcxDateEdit(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    Properties.DisplayFormat := FDateTimeBiçimi;
    Properties.EditFormat := FDateTimeBiçimi;
    Properties.AssignedValues.DisplayFormat := True;
    Properties.AssignedValues.EditFormat := True;
    Properties.ImmediatePost := True;
    Properties.onEditValueChanged := cxDateEdit1PropertiesEditValueChanged;
    //Properties.InputKind := ikStandard;
    Properties.Kind := ckDateTime;
    if Assigned(FVariant) then
      Date := VarToDateTime(FVariant^);
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
  end;

  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

procedure TDateTimePickerDenetimi.SetDateTimeBiçimi(const Value: string);
begin
  FDateTimeBiçimi := Value;
  TDateTimePicker(FGirdiBileşeni).Format := Value;
end;

procedure TDateTimePickerDenetimi.SetDateTimeTürü(const Value: TDateTimeKind);
begin
  FDateTimeTürü := Value;
  TDateTimePicker(FGirdiBileşeni).Kind := Value;
end;

{ TImageComboBox }

constructor TImageComboBoxDenetimi.Create(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant; ABağlantı: TFDConnection;
  AListeSql: string;AIndexiKullan: Boolean;
  AImageList: TCustomImageList);
begin
  inherited Create(ABaşlık,ABaşlangıçDeğeri);
  FListeSQL := AListeSQL;
  FImageList := AImageList;
  FIndexiKullan := AIndexiKullan;
  FDenetimTürü := dtImageComboBox;
  FBağlantı := ABağlantı;
end;

procedure TImageComboBoxDenetimi.DeğişkeneAktar;
var
  idx : Integer;
begin
  idx := TcxImageComboBox(FGirdiBileşeni).ItemIndex;
  if FIndexiKullan then
    FVariant^ := idx
  else if idx > -1 then
    FVariant^ := TcxImageComboBox(FGirdiBileşeni).Properties.Items[idx].Value
  else
    FVariant^ := idx;
end;

function TImageComboBoxDenetimi.Hazırla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
var
  lst : TcxImageComboBoxItems;
  qry : TADOQuery;
begin
  inherited Hazırla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileşeni := TcxImageComboBox.Create(AGirisKutusu);
  with TcxImageComboBox(FGirdiBileşeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    Properties.Items.Clear;
    Properties.Images := FImageList;
    lst := Properties.Items;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    with FetaKurulusSiniflari.Veritabani.SorguBaslat(FBağlantı,FListeSQL,[],[]) do
    try
      Open;
      qry := CurrentInstance as TADOQuery;
      while not Eof do begin
        with lst.Add do begin
          Description := qry.AsString[1];
          Value := qry.AsString[0];
        end;
        Next;
      end;
    finally
      Free;
    end;
    EditValue := FVariant^;
    PostEditValue;
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileşeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate; 
end;

procedure TImageComboBoxDenetimi.SetImageList(const Value: TCustomImageList);
begin
  FImageList := Value;
  TcxImageComboBox(FGirdiBileşeni).Properties.Images := Value;
end;

procedure TImageComboBoxDenetimi.SetListeSQL(const Value: string);
var
  lst : TcxImageComboBoxItems;
  qry : TADOQuery;
begin
  FListeSQL := Value;
  with TcxImageComboBox(FGirdiBileşeni) do begin
    Properties.Items.Clear;
    lst := Properties.Items;
    with FetaKurulusSiniflari.Veritabani.SorguBaslat(FBağlantı,FListeSQL,[],[]) do
    try
      Open;
      qry := CurrentInstance as TADOQuery;
      while not Eof do begin
        with lst.Add do begin
          Description := qry.AsString[1];
          if qry.FieldCount > 2 then
            ImageIndex := qry.AsInteger[2];
          Value := qry.AsString[0];
        end;
        Next;
      end;
    finally
      Free;
    end;
    //EditValue := -99;
    //PostEditValue;
  end;
end;

{ TGirdiDenetimleri }

function TGirdiDenetimleri.ComboBox(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant; AListe: TStrings;
  AComboŞekli: TComboBoxStyle;
  AComboBoxItemIndexKullan: Boolean;ASelectionChanged : TComboSelectionChanged;
  AGenislik: Integer): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__ComboBox(ABaşlık,ABaşlangıçDeğeri,
    AListe,AComboŞekli,AComboBoxItemIndexKullan,ASelectionChanged,AGenislik));
end;

constructor TGirdiDenetimleri.Create;
begin
  FGirdiDenetimleri := TObjectList.Create;
end;

function TGirdiDenetimleri.DateTimePicker(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant; ADateTimeTürü: TDateTimeKind;
  ADateTimeBiçimi: string): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__DateTimePicker(ABaşlık,ABaşlangıçDeğeri,
    ADateTimeTürü, ADateTimeBiçimi));
end;


destructor TGirdiDenetimleri.Destroy;
begin
  FGirdiDenetimleri.Free;
  inherited;
end;
function TGirdiDenetimleri.Edit(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__Edit(ABaşlık,ABaşlangıçDeğeri));
end;

function TGirdiDenetimleri.CurrencyEdit(ABaşlık: string; ABaşlangıçDeğeri: PVariant; OndalikBasamakSay:SmallInt): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__CurrencyEdit(ABaşlık,ABaşlangıçDeğeri,OndalikBasamakSay));
end;

function TGirdiDenetimleri.Memo(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__Memo(ABaşlık,ABaşlangıçDeğeri));
end;

function TGirdiDenetimleri.RichEdit(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__RichEdit(ABaşlık,ABaşlangıçDeğeri));
end;

function TGirdiDenetimleri.ImageComboBox(ABaşlık: string;
  ABaşlangıçDeğeri: PVariant; ABağlantı: TFDConnection;
  AListeSql: string; AIndexiKullan: Boolean;
  AImageList: TCustomImageList): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__ImageComboBox(ABaşlık,ABaşlangıçDeğeri,
    ABağlantı, AListeSql, AIndexiKullan, AImageList));
end;

end.



