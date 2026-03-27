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
    class function BilgiAl(ABaþlýk: string;AGirdiler: TGirdiDenetimleri): TGirisKutusuEx;
    class function BilgiAlEx(ABaþlýk: string;AGirdiler: TGirdiDenetimleri): TModalResult;
  end;

  TGirdiDenetimi = class(TObject)
  private
    FBaþlýk: string;
    FDenetimTürü: TDenetimTürü;
    FVariant : PVariant;
    FGirdiBileþeni : TWinControl;
    FLabel : TLabel;
    FSatirYuksekligi : Integer;
    procedure SetBaþlýk(const Value: string);
  protected
  public
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri: PVariant);virtual;
    destructor Destroy;override;
    function Hazýrla(AGirisKutusu: TGirisKutusuEx;AEvSahibi : TGridPanel): TGirdiDenetimi;virtual;
    procedure HazýrlamaBitti;Virtual;
    procedure DeðiþkeneAktar;virtual;abstract;
    property Baþlýk: string read FBaþlýk write SetBaþlýk;
    property DenetimTürü : TDenetimTürü read FDenetimTürü;
  end;

  TEditDenetimi = class(TGirdiDenetimi)
  public
    function Hazýrla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri : PVariant);override;
  end;

  TCurrencyEditDenetimi = class(TGirdiDenetimi)
  private
    FOndalikBasamakSay: SmallInt;
  public
    function Hazýrla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri : PVariant; AOndalikBasamakSay:SmallInt);reintroduce;
  end;

  TMemoDenetimi = class(TGirdiDenetimi)
  public
    function Hazýrla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri : PVariant);override;
  end;

  TRichEditDenetimi = class(TGirdiDenetimi)
  public
    function Hazýrla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri : PVariant);override;
  end;

  TComboBoxDenetimi = class(TGirdiDenetimi)
  private
    FComboBoxStyle: TComboBoxStyle;
    FComboItemIndexKullan: Boolean;
    FListe: TStrings;
    FOnSelectionChanged : TComboSelectionChanged;
    procedure SetComboBoxStyle(const Value: TComboBoxStyle);
    procedure OnComboSelectionChanged(Sender: TObject);
  public
    function Hazýrla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;

    procedure DeðiþkeneAktar; override;
    constructor Create(ABaþlýk: string; ABaþlangýçDeðeri : PVariant;
      AListe : TStrings = nil; AComboÞekli : TComboBoxStyle = csDropDown;
      AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil);reintroduce;
    procedure HazýrlamaBitti; override;
    property ComboÞekli : TComboBoxStyle read FComboBoxStyle write SetComboBoxStyle;
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
    constructor Create(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
      ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '');reintroduce;
    function Hazýrla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
    property DateTimeTürü : TDateTimeKind read FDateTimeTürü write SetDateTimeTürü;
    property DateTimeBiçimi : string read FDateTimeBiçimi write SetDateTimeBiçimi;
  end;

  TImageComboBoxDenetimi = class(TGirdiDenetimi)
  private
    FListeSQL: string;
    FImageList: TCustomImageList;
    FIndexiKullan: Boolean;
    FBaðlantý : TFDConnection;
    procedure SetImageList(const Value: TCustomImageList);
    procedure SetListeSQL(const Value: string);
  public
    constructor Create(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
      ABaðlantý: TFDConnection;
      AListeSql: string;AIndexiKullan: Boolean = False;AImageList: TCustomImageList = nil);reintroduce;
    function Hazýrla(AGirisKutusu: TGirisKutusuEx;
      AEvSahibi: TGridPanel): TGirdiDenetimi; override;
    procedure DeðiþkeneAktar; override;
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
    function Edit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TGirdiDenetimleri;
    function CurrencyEdit(ABaþlýk: string; ABaþlangýçDeðeri : PVariant; OndalikBasamakSay:SmallInt): TGirdiDenetimleri;
    function Memo(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TGirdiDenetimleri;
    function RichEdit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TGirdiDenetimleri;
    function ComboBox(ABaþlýk: string; ABaþlangýçDeðeri : PVariant;
        AListe : TStrings = nil; AComboÞekli : TComboBoxStyle = csDropDown;
        AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil): TGirdiDenetimleri;
    function DateTimePicker(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
        ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
        TGirdiDenetimleri;
    function ImageComboBox(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
        ABaðlantý: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
        AImageList: TCustomImageList = nil) : TGirdiDenetimleri;
    property GirdiDenetimleri : TObjectList read FGirdiDenetimleri;
  end;

var
  GirisKutusuEx: TGirisKutusuEx;

  { Denetim iþlevleri }

  /// <summary>
  /// Standard Edit nesnesi ekler
  /// </summary>
  /// <param name="ABaþlýk">Bileþenin kenarýnda görünecek olan baþlýk</param>
  /// <param name="ABaþlangýçDeðeri">Bileþen için gerekli olan ve ekran kapandýktan sonra bileþenin deðerinin aktarýlacaðý variant pointer</param>
  /// <exception cref="EAccessViolation"><param name="ABaþlangýçDeðeri"/> parametresi nil olduðunda bu istisna fýrlatýlýr</exception>
  /// <returns>TEditDenetimi</returns>
  function __Edit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TEditDenetimi;
  function __CurrencyEdit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant; OndalikBasamakSay:SmallInt): TCurrencyEditDenetimi;
  function __Memo(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TMemoDenetimi;
  function __RichEdit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TRichEditDenetimi;
  /// <summary>
  /// Standard ComboBox nesnesi ekler
  /// </summary>
  /// <param name="ABaþlýk">Bileþenin kenarýnda görünecek olan baþlýk</param>
  /// <param name="ABaþlangýçDeðeri">Bileþen için gerekli olan ve ekran kapandýktan sonra bileþenin deðerinin aktarýlacaðý variant pointer</param>
  /// <param name="AListe">ComboBox nesnesini doldurmak için kullanýlacak TStrings den türetilmiþ liste örneði</param>
  /// <param name="AComboÞekli">ComboBox'ýn nasýl davranacaðýný belirleyen parametre</param>
  /// <param name="AComboBoxItemIndexKullan">Dönüþ deðeri için ItemIndex mi yoksa Text özelliði mi kullanýlacaðýný belirten parametre</param>
  /// <exception cref="EAccessViolation"><param name="ABaþlangýçDeðeri"/> parametresi nil olduðunda bu istisna fýrlatýlýr</exception>
  /// <returns>TComboBoxDenetimi</returns>
  function __ComboBox(ABaþlýk: string; ABaþlangýçDeðeri : PVariant;
        AListe : TStrings = nil; AComboÞekli : TComboBoxStyle = csDropDown;
        AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil): TComboBoxDenetimi;
  /// <summary>
  /// Standard DateTimePicker nesnesi ekler
  /// </summary>
  /// <param name="ABaþlýk">Bileþenin kenarýnda görünecek olan baþlýk</param>
  /// <param name="ABaþlangýçDeðeri">Bileþen için gerekli olan ve ekran kapandýktan sonra bileþenin deðerinin aktarýlacaðý variant pointer</param>
  /// <param name="ADateTimeTürü">Zaman mý yoksa tarih mi düzenlenecek onu belirten parametre</param>
  /// <param name="ADateTimeBiçimi">dtkCustom seçildiðinde istenen biçimin belirtileceði parametre</param>
  /// <exception cref="EAccessViolation"><param name="ABaþlangýçDeðeri"/> parametresi nil olduðunda bu istisna fýrlatýlýr</exception>
  /// <returns></returns>
  function __DateTimePicker(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
        ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
        TDateTimePickerDenetimi;
  /// <summary>
  /// DevExpress firmasýnýn TcxImageComboBox bileþenini ekler
  /// </summary>
  /// <param name="ABaþlýk">Bileþenin kenarýnda görünecek olan baþlýk</param>
  /// <param name="ABaþlangýçDeðeri">Bileþen için gerekli olan ve ekran kapandýktan sonra bileþenin deðerinin aktarýlacaðý variant pointer</param>
  /// <param name="ABaðlantý"><see cref="AListeSql"/> parametresinin çalýþtýrýlacaðý baðlantý örneði</param>
  /// <param name="AListeSql">Properties.Items özelliðini doldurmak için kullanýlacak sql ifadesi</param>
  /// <param name="AIndexiKullan">Dönüþ deðeri için ItemIndex mi yoksa Properties.Items[x].Value deðeri mi kullanýlacaðýný belirten parametre</param>
  /// <param name="AImageList">Listelenirken kullanýlacak TCustomImageList bileþeni.Bunun için sql sorgusunda 3 ncü bir alan dönmesi gerekir.</param>
  /// <returns>TDateTimePickerDenetimi</returns>
  function __ImageComboBox(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
        ABaðlantý: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
        AImageList: TCustomImageList = nil) : TImageComboBoxDenetimi;

implementation

uses FetaKurulusSiniflari, FetaClassExtensions, Fetautil,LocOnFly,PrjConst;

{$R *.dfm}

function __Edit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TEditDenetimi;
begin
  Result := TEditDenetimi.Create(ABaþlýk,ABaþlangýçDeðeri);
end;

function __CurrencyEdit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant; OndalikBasamakSay:SmallInt): TCurrencyEditDenetimi;
begin
  Result := TCurrencyEditDenetimi.Create(ABaþlýk, ABaþlangýçDeðeri, OndalikBasamakSay);
end;

function __Memo(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TMemoDenetimi;
begin
  Result := TMemoDenetimi.Create(ABaþlýk,ABaþlangýçDeðeri);
end;

function __RichEdit(ABaþlýk: string;ABaþlangýçDeðeri : PVariant): TRichEditDenetimi;
begin
  Result := TRichEditDenetimi.Create(ABaþlýk,ABaþlangýçDeðeri);
end;

function __ComboBox(ABaþlýk: string; ABaþlangýçDeðeri : PVariant;
      AListe : TStrings = nil; AComboÞekli : TComboBoxStyle = csDropDown;
      AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil): TComboBoxDenetimi;
begin
  Result := TComboBoxDenetimi.Create(ABaþlýk,ABaþlangýçDeðeri,AListe, AComboÞekli,AComboBoxItemIndexKullan, ASelectionChanged);
end;


function __DateTimePicker(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
      ADateTimeTürü : TDateTimeKind = dtkDate; ADateTimeBiçimi : string = '') :
      TDateTimePickerDenetimi;
begin
    Result := TDateTimePickerDenetimi.Create(ABaþlýk, ABaþlangýçDeðeri, ADateTimeTürü, ADateTimeBiçimi);
end;

function __ImageComboBox(ABaþlýk: string;ABaþlangýçDeðeri: PVariant;
      ABaðlantý: TFDConnection; AListeSql: string;AIndexiKullan: Boolean = False;
      AImageList: TCustomImageList = nil) : TImageComboBoxDenetimi;
begin
  Result := TImageComboBoxDenetimi.Create(ABaþlýk,ABaþlangýçDeðeri,ABaðlantý, AListeSQL, AIndexiKullan,AImageList);
end;                          


{ TGirdiDenetimi }

constructor TGirdiDenetimi.Create(ABaþlýk: string; ABaþlangýçDeðeri: PVariant);
begin
  FVariant := ABaþlangýçDeðeri;
  FBaþlýk := ABaþlýk;
  FDenetimTürü := dtBilinmeyen;
  FSatirYuksekligi := 20;
end;

destructor TGirdiDenetimi.Destroy;
begin
  inherited;
end;

function TGirdiDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;AEvSahibi : TGridPanel): TGirdiDenetimi;
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
  FLabel.Caption := FBaþlýk;
  FLabel.Align := alLeft;
  FLabel.Width:=600;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 2] := FLabel;
end;

procedure TGirdiDenetimi.HazýrlamaBitti;
begin

end;

procedure TGirdiDenetimi.SetBaþlýk(const Value: string);
begin
  FBaþlýk := Value;
end;

class function TGirisKutusuEx.BilgiAl(ABaþlýk: string; AGirdiler: TGirdiDenetimleri): TGirisKutusuEx;
var
  denetim : Pointer;
begin
  Result := TGirisKutusuEx.Create(Application);
  Result.FGirdiDenetimleri := AGirdiler;
  for denetim in Result.FGirdiDenetimleri.GirdiDenetimleri  do begin
    TGirdiDenetimi(denetim).Hazýrla(Result,Result.GridPaneli);
  end;
  for denetim in Result.FGirdiDenetimleri.GirdiDenetimleri  do begin
    TGirdiDenetimi(denetim).HazýrlamaBitti;
  end;
  Result.BaslikLabel.Caption := ABaþlýk;
  Result.Caption := ABaþlýk;
end;

class function TGirisKutusuEx.BilgiAlEx(ABaþlýk: string;
  AGirdiler: TGirdiDenetimleri): TModalResult;
begin
  with BilgiAl(ABaþlýk,AGirdiler) do
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
    denetim.DeðiþkeneAktar;
  end;
  ModalResult := mrOK;
end;

{ TEditDenetimi }

constructor TEditDenetimi.Create(ABaþlýk: string; ABaþlangýçDeðeri: PVariant);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FDenetimTürü := dtEdit;
end;

procedure TEditDenetimi.DeðiþkeneAktar;
begin
  FVariant^ := TcxTextEdit(FGirdiBileþeni).Text;
end;

function TEditDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TcxTextEdit.Create(AGirisKutusu);
  with TcxTextEdit(FGirdiBileþeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
      Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TCurrencyEditDenetimi }

constructor TCurrencyEditDenetimi.Create(ABaþlýk: string; ABaþlangýçDeðeri: PVariant; AOndalikBasamakSay:SmallInt);
begin
  inherited Create(ABaþlýk, ABaþlangýçDeðeri);
  FDenetimTürü := dtCurrencyEdit;
  FOndalikBasamakSay := AOndalikBasamakSay;
end;

procedure TCurrencyEditDenetimi.DeðiþkeneAktar;
begin
  FVariant^ := TcxCurrencyEdit(FGirdiBileþeni).Value;
end;

function TCurrencyEditDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx; AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TcxCurrencyEdit.Create(AGirisKutusu);
  with TcxCurrencyEdit(FGirdiBileþeni) do begin
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
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TMemoDenetimi }


constructor TMemoDenetimi.Create(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FDenetimTürü := dtMemo;
end;

procedure TMemoDenetimi.DeðiþkeneAktar;
begin
  FVariant^ := TMemo(FGirdiBileþeni).Text;
end;

function TMemoDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  FSatirYuksekligi := 210;
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TMemo.Create(AGirisKutusu);
  with TMemo(FGirdiBileþeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Height := 230;
    Width := 550;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    if Assigned(FVariant) then
      Text := VarToStr(FVariant^);
  end;
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TRichEditDenetimi }

constructor TRichEditDenetimi.Create(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FDenetimTürü := dtRichEdit;
end;

procedure TRichEditDenetimi.DeðiþkeneAktar;
var
  memStream: TMemoryStream;
  strList: TStringList;
  Abc:Variant;
  j:integer;
begin
  memStream := TMemoryStream.Create;
  strList := TStringList.Create;

  try
    TRichEdit(FGirdiBileþeni).Lines.SaveToStream(memStream );
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

function TRichEditDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  FSatirYuksekligi := 210;
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TRichEdit.Create(AGirisKutusu);
  with TRichEdit(FGirdiBileþeni) do begin
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
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

{ TComboBoxDenetimi }

constructor TComboBoxDenetimi.Create(ABaþlýk: string;
  ABaþlangýçDeðeri : PVariant;AListe : TStrings = nil;
  AComboÞekli : TComboBoxStyle = csDropDown;
  AComboBoxItemIndexKullan : Boolean = False;ASelectionChanged : TComboSelectionChanged = nil);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FDenetimTürü := dtComboBox;
  FComboBoxStyle := AComboÞekli;
  FComboItemIndexKullan := AComboBoxItemIndexKullan;
  FListe := AListe;
  FOnSelectionChanged := ASelectionChanged;
end;

procedure TComboBoxDenetimi.DeðiþkeneAktar;
begin
  if FComboItemIndexKullan then
    FVariant^ := TComboBox(FGirdiBileþeni).ItemIndex
  else
    FVariant^ := TComboBox(FGirdiBileþeni).Text;
end;

function TComboBoxDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
var
  i : Integer;
  idx : Integer;
  selTxt: string;
begin
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TComboBox.Create(AGirisKutusu);
  with TComboBox(FGirdiBileþeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
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
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

procedure TComboBoxDenetimi.HazýrlamaBitti;
begin
  inherited;
  OnComboSelectionChanged(nil);
end;

procedure TComboBoxDenetimi.OnComboSelectionChanged(Sender: TObject);
begin
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(TForm(TComboBox(FGirdiBileþeni).Owner));
end;

procedure TComboBoxDenetimi.SetComboBoxStyle(const Value: TComboBoxStyle);
begin
  FComboBoxStyle := Value;
  TComboBox(FGirdiBileþeni).Style := Value;
end;

{ TDateTimePickerDenetimi }

constructor TDateTimePickerDenetimi.Create(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant; ADateTimeTürü: TDateTimeKind;
  ADateTimeBiçimi: string);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FDenetimTürü := dtDateTimePicker;
  FDateTimeBiçimi := ADateTimeBiçimi;
  FDateTimeTürü := ADateTimeTürü;
end;

procedure TDateTimePickerDenetimi.DeðiþkeneAktar;
begin
  FVariant^ := TcxDateEdit(FGirdiBileþeni).EditValue;
end;

procedure TDateTimePickerDenetimi.cxDateEdit1PropertiesEditValueChanged(Sender: TObject);
begin
  (Sender as TcxDateEdit).PostEditValue;
end;

function TDateTimePickerDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
begin
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TcxDateEdit.Create(AGirisKutusu);
  with TcxDateEdit(FGirdiBileþeni) do begin
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

  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate;
end;

procedure TDateTimePickerDenetimi.SetDateTimeBiçimi(const Value: string);
begin
  FDateTimeBiçimi := Value;
  TDateTimePicker(FGirdiBileþeni).Format := Value;
end;

procedure TDateTimePickerDenetimi.SetDateTimeTürü(const Value: TDateTimeKind);
begin
  FDateTimeTürü := Value;
  TDateTimePicker(FGirdiBileþeni).Kind := Value;
end;

{ TImageComboBox }

constructor TImageComboBoxDenetimi.Create(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant; ABaðlantý: TFDConnection;
  AListeSql: string;AIndexiKullan: Boolean;
  AImageList: TCustomImageList);
begin
  inherited Create(ABaþlýk,ABaþlangýçDeðeri);
  FListeSQL := AListeSQL;
  FImageList := AImageList;
  FIndexiKullan := AIndexiKullan;
  FDenetimTürü := dtImageComboBox;
  FBaðlantý := ABaðlantý;
end;

procedure TImageComboBoxDenetimi.DeðiþkeneAktar;
var
  idx : Integer;
begin
  idx := TcxImageComboBox(FGirdiBileþeni).ItemIndex;
  if FIndexiKullan then
    FVariant^ := idx
  else if idx > -1 then
    FVariant^ := TcxImageComboBox(FGirdiBileþeni).Properties.Items[idx].Value
  else
    FVariant^ := idx;
end;

function TImageComboBoxDenetimi.Hazýrla(AGirisKutusu: TGirisKutusuEx;
  AEvSahibi: TGridPanel): TGirdiDenetimi;
var
  lst : TcxImageComboBoxItems;
  qry : TADOQuery;
begin
  inherited Hazýrla(AGirisKutusu,AEvSahibi);
  Result := Self;
  FGirdiBileþeni := TcxImageComboBox.Create(AGirisKutusu);
  with TcxImageComboBox(FGirdiBileþeni) do begin
    Parent := AEvSahibi;
    Align := alLeft;
    Width := 210;
    Properties.Items.Clear;
    Properties.Images := FImageList;
    lst := Properties.Items;
    Name := 'Denetim' + IntToStr(AGirisKutusu.FDenetimSay);
    AGirisKutusu.FDenetimSay := AGirisKutusu.FDenetimSay + 1;
    with FetaKurulusSiniflari.Veritabani.SorguBaslat(FBaðlantý,FListeSQL,[],[]) do
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
  AEvSahibi.ControlCollection.Controls[1,AEvSahibi.RowCollection.Count - 1] := FGirdiBileþeni;
  AEvSahibi.Realign;
  AEvSahibi.Invalidate; 
end;

procedure TImageComboBoxDenetimi.SetImageList(const Value: TCustomImageList);
begin
  FImageList := Value;
  TcxImageComboBox(FGirdiBileþeni).Properties.Images := Value;
end;

procedure TImageComboBoxDenetimi.SetListeSQL(const Value: string);
var
  lst : TcxImageComboBoxItems;
  qry : TADOQuery;
begin
  FListeSQL := Value;
  with TcxImageComboBox(FGirdiBileþeni) do begin
    Properties.Items.Clear;
    lst := Properties.Items;
    with FetaKurulusSiniflari.Veritabani.SorguBaslat(FBaðlantý,FListeSQL,[],[]) do
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

function TGirdiDenetimleri.ComboBox(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant; AListe: TStrings;
  AComboÞekli: TComboBoxStyle;
  AComboBoxItemIndexKullan: Boolean;ASelectionChanged : TComboSelectionChanged): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__ComboBox(ABaþlýk,ABaþlangýçDeðeri,
    AListe,AComboÞekli,AComboBoxItemIndexKullan,ASelectionChanged));
end;

constructor TGirdiDenetimleri.Create;
begin
  FGirdiDenetimleri := TObjectList.Create;
end;

function TGirdiDenetimleri.DateTimePicker(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant; ADateTimeTürü: TDateTimeKind;
  ADateTimeBiçimi: string): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__DateTimePicker(ABaþlýk,ABaþlangýçDeðeri,
    ADateTimeTürü, ADateTimeBiçimi));
end;


destructor TGirdiDenetimleri.Destroy;
begin
  FGirdiDenetimleri.Free;
  inherited;
end;
function TGirdiDenetimleri.Edit(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__Edit(ABaþlýk,ABaþlangýçDeðeri));
end;

function TGirdiDenetimleri.CurrencyEdit(ABaþlýk: string; ABaþlangýçDeðeri: PVariant; OndalikBasamakSay:SmallInt): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__CurrencyEdit(ABaþlýk,ABaþlangýçDeðeri,OndalikBasamakSay));
end;

function TGirdiDenetimleri.Memo(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__Memo(ABaþlýk,ABaþlangýçDeðeri));
end;

function TGirdiDenetimleri.RichEdit(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__RichEdit(ABaþlýk,ABaþlangýçDeðeri));
end;

function TGirdiDenetimleri.ImageComboBox(ABaþlýk: string;
  ABaþlangýçDeðeri: PVariant; ABaðlantý: TFDConnection;
  AListeSql: string; AIndexiKullan: Boolean;
  AImageList: TCustomImageList): TGirdiDenetimleri;
begin
  Result := Self;
  FGirdiDenetimleri.Add(__ImageComboBox(ABaþlýk,ABaþlangýçDeðeri,
    ABaðlantý, AListeSql, AIndexiKullan, AImageList));
end;

end.



