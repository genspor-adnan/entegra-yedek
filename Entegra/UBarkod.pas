unit UBarkod;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,UTouchKeyboardWindow,
  dxSkinLondonLiquidSky, dxGDIPlusClasses, cxImage, cxLabel, JvExControls,
  JvButton, JvNavigationPane, cxTextEdit, JvTimer, Data.DB, FireDAC.Comp.Client,
  cxDBLabel, cxDBEdit, cxCurrencyEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;

type
  TBarkodDlg = class(TForm)
    StokAra: TcxTextEdit;
    JvNavPanelButton1: TJvNavPanelButton;
    cxImage1: TcxDBImage;
    LabelAD: TcxDBLabel;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    LblOnay: TcxLabel;
    JvTimer1: TJvTimer;
    TabStok: TFDQuery;
    DtsStok: TDataSource;
    cxDBLabel1: TcxDBLabel;
    cxImage2: TcxImage;
    cxDBCurrencyEdit1: TcxDBCurrencyEdit;
    procedure KapatTusClick(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure StokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Klavye1 : TKeyboardWindow;
  public
    { Public declarations }
  end;

var
  BarkodDlg: TBarkodDlg;

implementation
uses UTablo, UHizliGirisAnaMenu, LocOnFly;

{$R *.dfm}

procedure TBarkodDlg.FormCreate(Sender: TObject);
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TBarkodDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := 500;//Top + Height;

  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

procedure TBarkodDlg.JvTimer1Timer(Sender: TObject);
var i : Integer;
    Ara : string[45];
begin
   JvTimer1.Enabled := False;
   Ara := Trim(StokAra.text);
   if Ara <> '' then begin
       TabStok.SQL.Text := 'select S.ID,S.KOD,S.STOKADI,MARKA,MODEL,ANABIRIM,SIPARISID=-1, BARKOD , S.RESIM,S.OZELKOD,SF.FIYAT,SF.KUR  from STOKLAR S ';
       TabStok.SQL.add(' inner join KATEGORI K on K.ID=S.KATEGORI left outer join STOKBARKOD B on S.ID=B.STOKID and B.VARSAYILAN=1 and S.ANABIRIM=B.BARKODBIRIMI ');
       TabStok.SQL.add(' inner join STOKFIYAT SF on S.ID=SF.STOKID and SF.FIYATADI='+IntToStr(VarsSatisFiyatID));
       if OzelKodGoster then
         TabStok.SQL.add(' where (S.KOD like '''+Ara+'%'' OR S.STOKADI+isnull(S.OZELKOD,'''') like ''%'+Ara+'%'' ')
       else
         TabStok.SQL.add(' where (S.KOD like '''+Ara+'%'' OR S.STOKADI like ''%'+Ara+'%'' ');
       TabStok.SQL.add(' or ( LEN('''+Ara+'%'')=14 and substring('''+Ara+'%'',1,12) like replace(replace(substring(BARKOD,1,12),''#'',''_''),''$'',''_'')) or (replace(replace(BARKOD,''#'',''_''),''$'',''_'') like '''+Ara+'%'' )' );
       TabStok.SQL.add(' or ( '''+Ara+''' like replace(replace(replace(BARKOD,''O'',''_''),''P'',''_''),''Q'',''_'') ) '); //boyut barkodlarý

       //TabStok.SQL.add(' or B.BARKOD like '''+Ara+'%'' ');
       TabStok.SQL.add(')and S.DURUM = 1 ');
       //BURADA hangi kod listes belirtilmiþse onun içinde arama yapýlýr
       {if KategoriBasKodList.Items.Count > 0 then begin
           TabStok.SQL.add(' and (');
           for i := 0 to KategoriBasKodList.Items.Count - 1 do begin
               if i > 0 then
                  TabStok.SQL.Add('or');
               TabStok.SQL.Add('(K.KOD like '''+KategoriBasKodList.Items[i]+'%'')');
           end;
           TabStok.SQL.Add(')');
       end;}
       TabStok.open;
   end;
end;

procedure TBarkodDlg.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure TBarkodDlg.StokAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   JvTimer1.Enabled := False;
   JvTimer1.Interval := 700;
   JvTimer1.Enabled := True;
end;

end.

