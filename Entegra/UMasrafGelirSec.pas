unit UMasrafGelirSec;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, cxCustomData,
  cxStyles, cxTL, cxMaskEdit, cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL,
  cxControls, cxTLData, DB, FireDAC.Comp.Client, ComCtrls, ToolWin, StdCtrls, ExtCtrls, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxFilter, dxScrollbarAnnotations, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TMasrafGelirSecDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LabelAdi: TLabel;
    Label4: TLabel;
    LabelBarkod: TLabel;
    AraKod: TEdit;
    AraStokAdi: TEdit;
    Adet: TEdit;
    UpDown1: TUpDown;
    AraBarkod: TEdit;
    ToolBar3: TToolBar;
    SecTus: TToolButton;
    ToolButton4: TToolButton;
    KapatlTus: TToolButton;
    TabMasrafListe: TFDQuery;
    DtsMasrafListe: TDataSource;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    PopupMenu1: TPopupMenu;
    ListeyiYenile1: TMenuItem;
    ComboSube: TcxImageComboBox;
    LabelSube: TLabel;
    cxDBTreeList1cxDBTreeListSUBE: TcxDBTreeListColumn;
    procedure SecTusClick(Sender: TObject);
    procedure KapatlTusClick(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListeyiYenile1Click(Sender: TObject);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboSubePropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    procedure AraBul;
  public
    { Public declarations }
    GelirMi, EskiGelirMi : SmallInt;
    SQLKomut:String;
    BaslikSecilebilir : Boolean;
  end;

var
  MasrafGelirSecDlg: TMasrafGelirSecDlg;


implementation
Uses Utablo, UVeriMotor;

{$R *.dfm}


procedure TMasrafGelirSecDlg.AraBul;
var s:string;
begin

      if ((AraKod.Text <> '') or (AraStokAdi.Text <> '') or (AraBarkod.Text <> '')) then begin
          s := '';
          if AraStokAdi.Text <> '' then
             s := ' and (AD LIKE ''%' + AraStokAdi.Text + '%'') order by AD '
          else if AraKod.Text <> '' then
             s := ' and (KOD LIKE ''%' + AraKod.Text + '%'') order by KOD '
          else if AraBarkod.Text <> '' then
             s := ' and (BARKOD = ' + AraBarkod.Text + ') ';
      end else
         s:=' order by KOD ';

      TabMasrafListe.Close;
      TabMasrafListe.SQL.Text :=  '';
      TabMasrafListe.SQL.Add(SQLKomut);
      if Gelirmi in[0,1] then
        TabMasrafListe.SQL.Add(' and M.DURUM=1 and  M.GELIRMI = '+IntToStr(Gelirmi));

      if (SubeVarmi)and(ComboSube.EditValue<1) then
           TabMasrafListe.SQL.Add(' and (M.SUBEID ='+VarToStr(ComboSube.EditValue)+' or M.SUBEID = 0) ');
      TabMasrafListe.SQL.Add(s);
      TabMasrafListe.Open;
end;

procedure TMasrafGelirSecDlg.AraKodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if Key = 38 then
    TabMasrafListe.Prior
  else if Key = 40 then
    TabMasrafListe.next
  else if (Key = 13)and(TabMasrafListe.RecordCount>0) then
     SecTus.Click
  else
    AraBul;
end;

procedure TMasrafGelirSecDlg.ComboSubePropertiesEditValueChanged(Sender: TObject);
begin
  AraBul;
end;

procedure TMasrafGelirSecDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
   SecTus.Click;
end;

procedure TMasrafGelirSecDlg.FormShow(Sender: TObject);
var K :Word;
begin
   if SQLKomut='' then begin
      // ROOTKOD = KOD'un son '.' oncesi (ust kategori). MSSQL CHARINDEX/LEN + alias= -> PG strpos
      //   (arg TERS) / LENGTH + AS. Sorgu dogrudan .Open (routed DEGIL) -> motor-dalli yaz.
      if AktifVeriMotor = vmPG then
        SQLKomut := ' select REVERSE(SUBSTRING(REVERSE(M.KOD),strpos(REVERSE(M.KOD),''.'')+1,LENGTH(M.KOD)-(strpos(REVERSE(M.KOD),''.'')-1))) AS ROOTKOD, '
      else
        SQLKomut := ' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(M.KOD),CHARINDEX(''.'',REVERSE(M.KOD),1)+1,LEN(M.KOD)-(CHARINDEX(''.'',REVERSE(M.KOD),1)-1))), ';
      SQLKomut := SQLKomut +
                 ' M.ID,M.KOD,M.AD,M.DURUM,M.TUR,M.KDV,F.FIYAT,F.KUR,M.SUBEID '+
                 ' from MASRAFGELIR M left outer join FIYATLAR F on M.ID=F.HIZMETID and F.FIYATADI=1 WHERE 1=1 ';
   end;

   ComboSube.Visible := SubeVarmi;
   labelSube.Visible := SubeVarmi;
   cxDBTreeList1cxDBTreeListSUBE.Visible := SubeVarmi;
   if SubeVarmi then
      ComboSube.EditValue := SubeId;

   if GelirMi=1 then
      Caption := 'Gelir Seçimi Ekranı'
   else if GelirMi=0 then
      Caption := 'Masraf Seçimi Ekranı'
   else
      Caption := 'Masraf/Gelir Seçimi Ekranı';



  K:=0;
  AraKodKeyUp(Self, K, []);
end;

procedure TMasrafGelirSecDlg.KapatlTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TMasrafGelirSecDlg.ListeyiYenile1Click(Sender: TObject);
var K :Word;
begin
   K:=0;
  AraKodKeyUp(Self, K, []);
end;

procedure TMasrafGelirSecDlg.SecTusClick(Sender: TObject);
begin
  if cxDBTreeList1.SelectionCount = 1 then begin
     if (not BaslikSecilebilir)and(cxDBTreeList1.Selections[0].HasChildren) then
        raise Exception.Create('Başlık değil Detay seçmelisiniz!')
     else
        ModalResult := mrOk;
      {else begin
        if Gelirmi=16 then
           raise Exception.Create('Detay değil Başlık seçmelisiniz!')
        else
           ModalResult := mrOk;}
  end
  else
    raise Exception.Create('Sadece bir seçim yapabilirsiniz!')

  // if TabMasrafListe.FieldByName('BASLIK').AsBoolean then
  //    raise Exception.Create('Başlık değil detay işlem seçmelisiniz!');

end;

end.

