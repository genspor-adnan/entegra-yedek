unit UTakip;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Utablo, dxSkinsCore, dxSkinscxPCPainter, Menus, cxLookAndFeelPainters, cxGraphics, cxCustomData, cxStyles, cxTL, cxLabel, cxTextEdit, cxTLdxBarBuiltInMenu, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxCheckBox, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, cxInplaceContainer, cxMemo, StdCtrls, cxButtons, cxMaskEdit, cxDropDownEdit, cxCalendar, ComCtrls, ToolWin, cxContainer, ExtCtrls, cxPC,
  cxSpinEdit,UItsAraclari,PrjConst,UitsBusiness,FetaKurulusSiniflari,
   cxButtonEdit, cxImageComboBox, CheckLst, cxTLData, cxCheckListBox,
    cxListBox, Grids, DBGrids,UBekletme, dxSkinLondonLiquidSky, cxDBTL, dxSkinLiquidSky,
  dxBarBuiltInMenu, cxLookAndFeels, cxNavigator, dxCore, cxDateUtils;

  type
    TKareKodType = record
      UrunNumarası : string;
      UrunSeriNumarası : string;
      Lotno : string;
      SonKullanım : string;
    end;

type
  TTakipDlg = class(TForm)
    Pgizlem: TcxPageControl;
    TsKarekod: TcxTabSheet;
    pgKareKod: TcxPageControl;
    shtKareKodGiris: TcxTabSheet;
    Panel2: TPanel;
    memoKareKodlar: TcxMemo;
    cxLabel1: TcxLabel;
    shtKareKodDuzeltSil: TcxTabSheet;
    Panel1: TPanel;
    editKareKod: TcxTextEdit;
    cxLabel2: TcxLabel;
    TsSeriNo: TcxTabSheet;
    dtsKareKodListesi: TDataSource;
    tabKareKodListesi: TFDQuery;
    DtsKareKodGoster: TDataSource;
    QryKareKodGoster: TFDQuery;
    pgSeriNo: TcxPageControl;
    shtSeriNoGiris: TcxTabSheet;
    memoSeriNolar: TcxMemo;
    cxLabel15: TcxLabel;
    memoHataliSeriNo: TcxMemo;
    lblHataliSeriNo: TcxLabel;
    shtSeriNoDuzeltSil: TcxTabSheet;
    Panel5: TPanel;
    editSeriNo: TcxTextEdit;
    cxLabel16: TcxLabel;
    edGarantiSure: TcxSpinEdit;
    lblGarantiSure: TcxLabel;
    dtsSeriNoListesi: TDataSource;
    tabSeriNoListesi: TFDQuery;
    pnlAlt: TPanel;
    Lbl1: TcxLabel;
    lblKayitSayisi: TcxLabel;
    lblHataMesaj: TcxLabel;
    cxLabel3: TcxLabel;
    lblGerekliSayi: TcxLabel;
    TbAletCubugu: TToolBar;
    btnKaydet: TToolButton;
    ToolButton10: TToolButton;
    btnIptal: TToolButton;
    BtnKapat: TToolButton;
    gridSeriNoListesi: TcxGrid;
    tvSeriNoListesi: TcxGridDBTableView;
    clmSeriNoSec: TcxGridDBColumn;
    clmSeriNo: TcxGridDBColumn;
    clmGarantiBitis: TcxGridDBColumn;
    cxGridDBColumn1: TcxGridDBColumn;
    gridSeriNoListesiLevel1: TcxGridLevel;
    tabSeriNoListesiID: TAutoIncField;
    tabSeriNoListesiGIRISTURU: TWordField;
    tabSeriNoListesiSTOKID: TIntegerField;
    tabSeriNoListesiGIRFATBASID: TIntegerField;
    tabSeriNoListesiGIRFATURAID: TIntegerField;
    tabSeriNoListesiURUNBARKOD: TStringField;
    tabSeriNoListesiSIRANO: TStringField;
    tabSeriNoListesiSERINO: TStringField;
    tabSeriNoListesiCIKISTURU: TWordField;
    tabSeriNoListesiCIKFATBASID: TIntegerField;
    tabSeriNoListesiCIKFATURAID: TIntegerField;
    tabSeriNoListesiGARANTIBITIS: TDateTimeField;
    tabSeriNoListesiIZLEMTURU: TWordField;
    tabSeriNoListesiONAY: TBooleanField;
    tabSeriNoListesiSONKULLANIM: TDateTimeField;
    tabSeriNoListesiLOTNO: TStringField;
    Panel4: TPanel;
    TreeListKareKod: TcxTreeList;
    TlcUrunAdi: TcxTreeListColumn;
    cxTreeList1Column2: TcxTreeListColumn;
    cxTreeList1Column3: TcxTreeListColumn;
    cxTreeList1Column4: TcxTreeListColumn;
    cxTreeList1Column5: TcxTreeListColumn;
    cxTreeList1Column6: TcxTreeListColumn;
    Panel6: TPanel;
    cxLabel10: TcxLabel;
    txtGln: TcxTextEdit;
    TxtFirma: TcxTextEdit;
    cxButton1: TcxButton;
    cxLabel11: TcxLabel;
    TsUretimEkle: TcxTabSheet;
    Panel3: TPanel;
    cxLabel4: TcxLabel;
    EdtUrunSiraNoBaslangic: TcxTextEdit;
    cxLabel5: TcxLabel;
    EdtUrunLotNo: TcxTextEdit;
    cxLabel6: TcxLabel;
    DtUrunSonKullanim: TcxDateEdit;
    EdtUrunAdet: TcxTextEdit;
    cxLabel7: TcxLabel;
    BtnUrunEkle: TcxButton;
    EdtUrunBarkodNumarasi: TcxTextEdit;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    TxtTransferNo: TcxTextEdit;
    BtnUrunGetir: TcxButton;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    CmbUrunUrunCinsi: TcxImageComboBox;
    CmbUrunUretimTipi: TcxImageComboBox;
    DtUrunUretimTarihi: TcxDateEdit;
    cxLabel14: TcxLabel;
    Panel7: TPanel;
    TxtUrunAraSiraNo: TcxTextEdit;
    cxLabel17: TcxLabel;
    BtnUrunArama: TcxButton;
    Panel8: TPanel;
    GridUretimCxDBTableView1: TcxGridDBTableView;
    GridUretimCxLevel1: TcxGridLevel;
    GridUretimCx: TcxGrid;
    TabUretim: TFDQuery;
    DtsUretim: TDataSource;
    Panel9: TPanel;
    Memo1: TMemo;
    TabAyniKayit: TFDQuery;
    DtsAyniKayit: TDataSource;
    MemoCreate: TMemo;
    cxLabel18: TcxLabel;
    TabUretimURUNBARKOD: TStringField;
    TabUretimSIRANO: TStringField;
    TabUretimSONKULLANIM: TDateTimeField;
    TabUretimLOTNO: TStringField;
    GridUretimCxDBTableView1URUNBARKOD: TcxGridDBColumn;
    GridUretimCxDBTableView1SIRANO: TcxGridDBColumn;
    GridUretimCxDBTableView1LOTNO: TcxGridDBColumn;
    GridUretimCxDBTableView1SONKULLANIM: TcxGridDBColumn;
    cxLabel19: TcxLabel;
    cxLabel20: TcxLabel;
    EdtUrunSabit: TcxTextEdit;
    CmbUrunHane: TcxComboBox;
    cxLabel21: TcxLabel;
    LblEnSonSira: TcxLabel;
    GridUretimStandart: TDBGrid;
    GridAyniKayit: TDBGrid;
    Panel10: TPanel;
    gridKareKodListesi: TcxGrid;
    tvKarekodListesi: TcxGridDBTableView;
    clmKareKodSec: TcxGridDBColumn;
    clmSiraNo: TcxGridDBColumn;
    clmLotno: TcxGridDBColumn;
    clmSonKullanma: TcxGridDBColumn;
    gridKareKodListesiLevel1: TcxGridLevel;
    Panel11: TPanel;
    TabUretimSatis: TFDQuery;
    DtsUretimSatis: TDataSource;
    TabUretimSatisURUNBARKOD: TStringField;
    TabUretimSatisSIRANO: TStringField;
    TabUretimSatisLOTNO: TStringField;
    TabUretimSatisSONKULLANIM: TDateTimeField;
    TabUretimSatisURETIMTARIHI: TDateTimeField;
    MemoTempOlustur: TMemo;
    TabUretimSatisUYARI: TStringField;
    TabSatisEkle: TFDQuery;
    TsUretimDuzenleCikis: TcxTabSheet;
    Panel12: TPanel;
    Panel13: TPanel;
    cxLabel22: TcxLabel;
    EdtSiraNoEkleme: TcxTextEdit;
    TabKarekodSatilacakListesi: TFDQuery;
    AutoIncField1: TAutoIncField;
    StringField1: TStringField;
    StringField2: TStringField;
    DateTimeField2: TDateTimeField;
    StringField4: TStringField;
    DtsKarekodSatilacakListesi: TDataSource;
    TabKarekodSatilacakListesiURETIMTARIHI: TDateField;
    cxLabel24: TcxLabel;
    EdtSSCC: TcxTextEdit;
    GridUretimSatis: TcxGrid;
    TvUretimSAtis: TcxGridDBTableView;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    GlUretimSatis: TcxGridLevel;
    BtnUretim: TToolButton;
    vUretimSAtisColumn1: TcxGridDBColumn;
    TabUretimSatisID: TIntegerField;
    ToolBar1: TToolBar;
    BtnCikar: TToolButton;
    ToolButton2: TToolButton;
    BtnPaket: TToolButton;
    cxButton2: TcxButton;
    procedure editSeriNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure clmSeriNoSecPropertiesChange(Sender: TObject);
    procedure clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
    procedure pgSeriNoChange(Sender: TObject);
    procedure dtsSeriNoListesiStateChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure memoSeriNolarPropertiesEditValueChanged(Sender: TObject);
    procedure tabSeriNoListesiBeforeEdit(DataSet: TDataSet);
    procedure tabSeriNoListesiBeforePost(DataSet: TDataSet);
    procedure BtnKapatClick(Sender: TObject);
    procedure cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure btnKaydetClick(Sender: TObject);
    procedure UniqueIslem(IzlemTuru:Integer);
    procedure HatalilariEkle(Unique, HataMesaji:string;IzlemTuru : Integer);
    function BosSatirKontrol(IzlemTuru:Integer):Boolean;
    function AyniUniqueVarmi(IzlemTuru:Integer):Boolean;
    function TablodaAyniUniqueVarmi(IzlemTuru:Integer):Boolean;
    procedure UniqueGir(IzlemTuru:Integer);
    procedure UniqueCık(IzlemTuru:Integer);
    function YeterliUniqueSecildimi(IzlemTuru:Integer):Boolean;
    procedure UniqueGirisCikisDuzenle(IzlemTuru:Integer);
    procedure memoSeriNolarPropertiesChange(Sender: TObject);
    function IsInteger(S: String) : Boolean;
    function AyniKarekoddanVar(SeriNo, UrunKodu: string):string;
    procedure clmKareKodSecPropertiesEditValueChanged(Sender: TObject);
    procedure clmKareKodSecPropertiesChange(Sender: TObject);
    procedure BtnUrunGetirClick(Sender: TObject);
    procedure BtnUrunEkleClick(Sender: TObject);
    function SiraNoArtir(Serino: String; adet: Integer): TStringList;
    function SiraNoEkGetir(SiraNo :String):string;
    function SiraNoRakamGetir(SiraNo :string):integer;
    procedure tabKareKodListesiAfterPost(DataSet: TDataSet);
    function  KareKodParcala(KareKod: string) : TKareKodType;
    procedure tabKareKodListesiBeforeEdit(DataSet: TDataSet);
    procedure tabKareKodListesiBeforePost(DataSet: TDataSet);
    procedure TreeListeUrunEkle(Urunler: array of TKareKodType);
    procedure TreeListKareKodDataChanged(Sender: TObject);
    procedure tvKarekodListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure dtsKareKodListesiStateChange(Sender: TObject);
    procedure tvSeriNoListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    function GlnVarmi(IzlemTuru: Integer): Boolean;
    procedure cxButton1Click(Sender: TObject);
    procedure txtGlnPropertiesChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure editKareKodKeyPress(Sender: TObject; var Key: Char);
    function SiraOlusturmaKontrol:Boolean;
    procedure BekletmeyiIlerlet(i: Integer; DlgBaslik,LabelText: string; Dlg: TBekletmeDlg);
    procedure EdtSSCCKeyPress(Sender: TObject; var Key: Char);
    procedure TabUretimAfterScroll(DataSet: TDataSet);
    procedure BtnUretimClick(Sender: TObject);
    procedure BtnCikarClick(Sender: TObject);
    procedure DtsUretimSatisDataChange(Sender: TObject; Field: TField);
    procedure memoKareKodlarKeyPress(Sender: TObject; var Key: Char);
    procedure EdtSiraNoEklemeKeyPress(Sender: TObject; var Key: Char);
    procedure cxButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TabStokBoyutBeforeOpen(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TakipDlg: TTakipDlg;
  TakipUniqueSayisi,
  TakipCagiranBaslikId,
  TakipCagiranSatirId,
  TakipCagiranTur,
  TakipCagiranUrunId : Integer;
  KareKodlar : array of TKareKodType;
  _Hata : string;
  Takipislemturu,OncekiUnique : string; //İşlem Türleri  = G : giriş, C: Çıkış, D: Düzelt , S:Sil  , GD: GirişDüzel, CD : Çıkış Düzelt
  TakipizlemTuru : Byte;  //İzlem Türleir  = 0 : izlenmiyor , 1 : SeriNo , 2 : sKT , 3 : Karekod , 4 : ?
  TakipGLN : string;
  TakipDepoID,TakipCikisDepoID : Integer;
  TakipCagiranLotno : string;
  RehberId : Integer;
implementation
 Uses LocOnFly,UTablo,UVeriMotor;
{$R *.dfm}

procedure TTakipDlg.BekletmeyiIlerlet(i: Integer; DlgBaslik,LabelText: string; Dlg: TBekletmeDlg);
begin
  Dlg.LabelUstTaraf.caption := LabelText;
  Dlg.LabelUstTaraf.Refresh;
  Dlg.Caption:=   DlgBaslik;
  while Dlg.cxProgressBar1.Position < i do
  begin
    Dlg.cxProgressBar1.Position := Dlg.cxProgressBar1.Position + 1;
    Dlg.cxProgressBar1.Refresh;
    sleep(25);
  end;
end;

function TTakipDlg.IsInteger(S: String) : Boolean;
var
aNo,err:integer;
begin
val(S,aNo,err);
if err=0 then result:=true else
result:=false;
end;

function TTakipDlg.AyniKarekoddanVar(SeriNo, UrunKodu: string):string;
begin
if (Serino<>'') and (UrunKodu<>'') then
begin
Tablo.Query6.close;
Tablo.Query6.SQL.Text:= '';
Tablo.Query6.SQL.add(' SELECT R.FIRMA+'' dan ''+convert(varchar(20),FB.TARIH,120)+'' tarihli alınan faturada ''+AD+'' isimli ürün aynı karekod a sahipdir.'' as MESAJ FROM ');
Tablo.Query6.SQL.add(' (SELECT * FROM STOKID KK WHERE KK.SIRANO = '''+SeriNo+''' AND KK.URUNBARKOD = '''+UrunKodu+''' ) AS DD ');
Tablo.Query6.SQL.add(' ,FATURA F,FATBASLIK FB ,REHBER R WHERE DD.GIRFATURAID = F.ID AND FB.ID=DD.GIRFATBASID AND FB.ID=F.FATBASID AND R.ID=FB.REHBERID ');
tablo.Query6.Open;
Result :=Tablo.Query6.FieldByName('MESAJ').AsString;
end else Result := '';
end;  //Eklendi

function TTakipDlg.AyniUniqueVarmi(IzlemTuru: Integer): Boolean;
var
 i : Integer;
begin
  if IzlemTuru=1 then  //SeriNo
     begin
     memoHataliSeriNo.Lines.Clear;
     Result:=False;
     for i := 0 to memoSeriNolar.Lines.Count - 1 do
        begin
           if  (memoSeriNolar.Lines.IndexOf(memoSeriNolar.Lines[i])>=0) and (memoSeriNolar.Lines.IndexOf(memoSeriNolar.Lines[i])<>i) then
              begin
                Result:=True;
                HatalilariEkle(memoSeriNolar.Lines[i],'Seri Numarası Listesinde tekrar eden seri numaraları var, Lütfen kontrol ediniz',IzlemTuru);
//              abort;
              end;
        end;
     end
  else
  if IzlemTuru=3 then //Karekod
   begin
     Result:=False;
     for i := 0 to memoKareKodlar.Lines.Count - 1 do
        begin
           Tablo.Query1.Close;
           Tablo.Query1.SQL.Text:= 'SELECT ID FROM STOKID WHERE  ISNULL(CIKFATBASID,0)=0 AND   URUNBARKOD = '''+KareKodlar[i].UrunNumarası+''' AND SIRANO = '''+KareKodlar[i].UrunSeriNumarası+''' ';
           Tablo.Query1.Open;
            if not tablo.Query1.IsEmpty then
              begin
                Result:=True;
                HatalilariEkle(TreeListKareKod.Items[i].Texts[1],'Listede tekrar eden seri numaraları var, Lütfen kontrol ediniz',IzlemTuru);
                abort;
              end;

           if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
              begin
                Result:=True;
                HatalilariEkle(TreeListKareKod.Items[i].Texts[1],'Listede tekrar eden seri numaraları var, Lütfen kontrol ediniz',IzlemTuru);
                abort;
              end;
        end;
   end;
end;

function TTakipDlg.BosSatirKontrol(IzlemTuru:integer):Boolean;
var
 i : Integer;

begin
Result:=False;


if IzlemTuru=1 then
begin
  for i := 0 to memoSeriNolar.Lines.Count - 1 do
  begin
    if StringReplace( memoSeriNolar.Lines[i],' ','',[rfReplaceAll]) = '' then
     begin
      Result:=True;
      lblHataMesaj.Caption:= 'Listede Boş Satır var, Lütfen Kontrol ediniz.';
      abort;
     end;
  end;
end
else
if IzlemTuru=3 then
begin
  for i := 0 to memoKareKodlar.Lines.Count - 1 do
  begin
    if StringReplace( memoKareKodlar.Lines[i],' ','',[rfReplaceAll]) = '' then
     begin
      Result:=True;
      lblHataMesaj.Caption:= 'Listede Boş Satır var, Lütfen Kontrol ediniz.';
      abort;
     end;
  end;
end;

end;
function TTakipDlg.SiraNoArtir(Serino: String; adet: Integer): TStringList;
var
Metin,Rakamlar,Harfler : string;
I,Bulunan,ErrorCode:Integer;
begin
Metin := Serino;
  Rakamlar:='';
  for i:=1 to length(Metin) do
  begin
    if Metin[i] in ['0'..'9']  then
    begin
      if (Metin[i]='0') and (length(rakamlar)=0) then  Harfler:= Harfler+Metin[i] else
      Rakamlar:=Rakamlar+Metin[i]
    end
    else
      Harfler:= Harfler+Metin[i]
  end;

  Val(Rakamlar,Bulunan,ErrorCode);
  Result := tstringlist.create;
  Result.Capacity := adet;
  for I := 0 to adet-1 do
  begin
  Result.add(Harfler + IntToStr(Bulunan + I ));
  end;
end;


function TTakipDlg.SiraNoEkGetir(SiraNo: String): string;
var
Metin,Rakamlar,Harfler : string;
I :Integer;
begin
Metin := SiraNo;
Rakamlar := '' ;
  for i:=1 to length(Metin) do
  begin
    if Metin[i] in ['0'..'9']  then
    begin
      if (Metin[i]='0') and (length(rakamlar)=0) then  Harfler:= Harfler+Metin[i] else
      Rakamlar:=Rakamlar+Metin[i]
    end
    else
      Harfler:= Harfler+Metin[i]
  end;
  Result := Harfler;
end;

function TTakipDlg.SiraNoRakamGetir(SiraNo: string): integer;
var
Metin,Rakamlar,Harfler : string;
I,Bulunan,ErrorCode:Integer;
begin
Metin := SiraNo;
  Rakamlar:='';
  for i:=1 to length(Metin) do
  begin
    if Metin[i] in ['0'..'9']  then
    begin
      if (Metin[i]='0') and (length(rakamlar)=0) then  Harfler:= Harfler+Metin[i] else
      Rakamlar:=Rakamlar+Metin[i]
    end
    else
      Harfler:= Harfler+Metin[i]
  end;
  Val(Rakamlar,Bulunan,ErrorCode);
  Result := Bulunan;
end;

function TTakipDlg.SiraOlusturmaKontrol:Boolean;
begin
// Sırano oluşturmadan önce yapılacak kontroller
Result := True;
if (EdtUrunSabit.Text='') then begin ShowMessage('Sıra numarası öneki boş olamaz.'); Result:=False; end;
if (CmbUrunHane.Text='') then begin ShowMessage('Sıra numarası kaç hane olduğunu girilmemiş.'); Result:=False;  end;
if (EdtUrunSiraNoBaslangic.Text='') then begin ShowMessage('Sıra numarası başlangıç numrası girilmemiş.'); Result:=False; end;
if  IsInteger(EdtUrunSiraNoBaslangic.Text) then begin ShowMessage('Sıra başlangış numarası harf içeremez.'); Result:=False;  end;




end;

procedure TTakipDlg.tabKareKodListesiAfterPost(DataSet: TDataSet);
begin
if dtsKareKodListesi.State in [dsEdit,dsInsert] then
begin
if  ( Takipislemturu = 'G' ) then
tabKareKodListesi.FieldByName('MALALINANGLN').AsString:= TakipGLN;
if  ( Takipislemturu = 'C' ) then
tabKareKodListesi.FieldByName('MALSATILANGLN').AsString:= TakipGLN;

end;
end;

procedure TTakipDlg.tabKareKodListesiBeforeEdit(DataSet: TDataSet);
begin
OncekiUnique:=TabKareKodListesi.FieldByName('URUNBARKOD').AsString+tabKareKodListesi.FieldByName('SIRANO').AsString;
end;
procedure TTakipDlg.TabStokBoyutBeforeOpen(DataSet: TDataSet);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := '';
  Tablo.Query1.SQL.Text
end;

procedure TTakipDlg.TabUretimAfterScroll(DataSet: TDataSet);
begin
lblKayitSayisi.Caption := IntToStr(TabUretim.RecordCount);
end;

procedure TTakipDlg.TreeListeUrunEkle(Urunler: array of TKareKodType);
var
I:Integer;
NewNode ,ChildNode: TcxTreeListNode;
begin
TreeListKareKod.Clear;
  for I := 0 to Length(Urunler) do
    begin
    NewNode := TreeListKareKod.Add;
    NewNode.Texts[0] := Urunler[I].UrunNumarası;
    NewNode.Texts[1] := Urunler[I].UrunSeriNumarası;
    NewNode.Texts[2] := Urunler[I].Lotno;
    NewNode.Texts[3] := Urunler[I].SonKullanım;
    end;
    for I := 1 to  Length(Urunler)  do
    begin
    if TreeListKareKod.Items[I].Texts[1] = TreeListKareKod.Items[I-1].Texts[1] then
      begin
      ChildNode := TreeListKareKod.AddChild(TreeListKareKod.Items[I], nil);
      ChildNode.Expand(True);
      ChildNode.Texts[0] := 'KareKod Tekrarı';
      end;
    end;
end;

procedure TTakipDlg.TreeListKareKodDataChanged(Sender: TObject);
begin
lblKayitSayisi.Caption:= IntToStr(TreeListKareKod.Count);
end;

procedure TTakipDlg.tvKarekodListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKFATURAID');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '') and
           (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '0')
         then
            AStyle := tablo.cxStSerinoCikilmis;
end;

procedure TTakipDlg.tvSeriNoListesiStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;
begin
    AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKFATURAID');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '') and
           (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '0')
         then
            AStyle := tablo.cxStSerinoCikilmis;
end;

procedure TTakipDlg.txtGlnPropertiesChange(Sender: TObject);
var
s:string;
begin
s:='select R.FIRMA from REHBERAYAR RA ,REHBERBILGI RB ,REHBER R where RA.VARSAYILAN=81 AND RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI AND R.ID=RB.YER_ID AND BILGI = $1' ;
 with Veritabani.SorguBaslat( Tablo.FDCnn, s,['$1'],[TcxTextEdit(Sender).Text]   ) do
   try
    ResourceOptions.CmdExecTimeout :=0;
    Open;
    TxtFirma.Text :=  FieldByName('FIRMA').AsString;
   finally
     Free;
   end;

end;

procedure TTakipDlg.tabKareKodListesiBeforePost(DataSet: TDataSet);
begin
  if OncekiUnique<>tabKareKodListesi.FieldByName('URUNBARKOD').AsString+tabKareKodListesi.FieldByName('SIRANO').AsString then
  begin
   Tablo.Query5.Close;
   Tablo.Query5.sql.Clear;
   Tablo.Query5.SQL.Add('SELECT * FROM STOKID SI INNER JOIN KAREKOD KD ON KD.STOKIDID=SI.ID  WHERE KD.ALIM_DURUM = ''00000-Doğru Bildirim.'' ');
   Tablo.Query5.SQL.Add(' AND SI.URUNBARKOD + SI.SIRANO  = '''+OncekiUnique+''' ');
   Tablo.Query5.Open;
   if not Tablo.Query5.IsEmpty then
    begin
    Application.MessageBox('Ürünün alım bildirimi yapılmış.Değiştirmek için alımı iptal etmeniz gerekmektedir.','H A T A',MB_ICONERROR+MB_OK);
    Abort;
    end;
  end;
  if OncekiUnique<>tabKareKodListesi.FieldByName('URUNBARKOD').AsString+tabKareKodListesi.FieldByName('SIRANO').AsString then
  begin
   Tablo.Query5.Close;
   Tablo.Query5.sql.Clear;
   Tablo.Query5.SQL.Add('SELECT * FROM STOKID SI INNER JOIN KAREKOD KD ON KD.STOKIDID=SI.ID  WHERE SATIS_DURUM = ''00000-Doğru Bildirim.'' ');
   Tablo.Query5.SQL.Add(' AND SI.URUNBARKOD + SI.SIRANO  = '''+OncekiUnique+'''  ');
   Tablo.Query5.Open;
   if not Tablo.Query5.IsEmpty then
    begin
    Application.MessageBox('Ürünün satış bildirimi yapılmış.Değiştirmek için satışı iptal etmeniz gerekmektedir.','H A T A',MB_ICONERROR+MB_OK);
    Abort;
    end;
  end;
  if OncekiUnique<>tabKareKodListesi.FieldByName('URUNBARKOD').AsString+tabKareKodListesi.FieldByName('SIRANO').AsString then
   begin
     if (TakipCagiranTur in [7,10, 11, 12]) and (tabKareKodListesi.FieldByName('CIKFATURAID').AsInteger>0 ) then
      begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış değiştirilemez','H A T A',MB_ICONERROR+MB_OK);
        Abort;
      end;
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM STOKID SI WHERE '+
                              ' SI.SIRANO = '''+tabKareKodListesi.FieldByName('SIRANO').AsString+''' '+
                              ' AND SI.URUNBARKOD = '''+tabKareKodListesi.FieldByName('URUNBARKOD').AsString+''' '+
                              ' AND SI.ID <>'+tabKareKodListesi.FieldByName('ID').AsString+' ';
      Tablo.Query5.Open;
     if not Tablo.Query5.IsEmpty then
      begin
         Application.MessageBox(PChar(tabKareKodListesi.FieldByName('URUNBARKOD').AsString+' numaralı bu ürün için daha önce kullanılmış, tekrar girilemez') ,'H A T A',MB_ICONERROR+ MB_OK);
         Abort;
      end;
   end;
   if (OncekiUnique<>tabKareKodListesi.FieldByName('URUNBARKOD').AsString+tabKareKodListesi.FieldByName('SIRANO').AsString)
   then
    _Hata := AyniKarekoddanVar(tabKareKodListesi.FieldByName('SIRANO').AsString,tabKareKodListesi.FieldByName('URUNBARKOD').AsString);
    if _Hata<>'' then
    begin
      Application.MessageBox(pchar(_Hata),'H A T A',MB_ICONERROR+MB_OK);
      Abort;
    end;
end;

procedure TTakipDlg.BtnUretimClick(Sender: TObject);
begin
 IzlemTuruUretimIse := True;
 ModalResult:=mrOk;
end;

procedure TTakipDlg.BtnUrunEkleClick(Sender: TObject);
var
  I: Integer;
  Rakamlar  : Char;
  NewNode,ChildNode : TcxTreeListNode;
  DiziSiraNolar : TStringList;
begin
 Application.CreateForm(TBekletmeDlg, BekletmeDlg);
 BekletmeDlg.Show;
 BekletmeyiIlerlet(20,'SıraNo Üretme İşlemi','Sırano Üretimine başlanıyor...',BekletmeDlg);
 IzlemTuruUretimIse := True;
 if not SeriNoKontrol then Abort;
 TreeListKareKod.Clear;
 DiziSiraNolar := TStringList.Create;
 DiziSiraNolar.Capacity := strtoint(EdtUrunAdet.Text);
   if IsInteger(EdtUrunAdet.Text)  then
   begin
     TabAyniKayit.Close;
     TabAyniKayit.ParamByName('BARKOD').Value:=EdtUrunBarkodNumarasi.Text;
     TabAyniKayit.ParamByName('SIRABASLA').Value:=EdtUrunSiraNoBaslangic.Text;
     TabAyniKayit.ParamByName('ADET').Value:=StrToInt(EdtUrunAdet.Text);
     TabAyniKayit.ParamByName('SIRAEK').Value:=EdtUrunSabit.Text;
     BekletmeyiIlerlet(40,'SıraNo Üretme İşlemi','Sırano kontrol işlemleri başlanıyor...',BekletmeDlg);
     TabAyniKayit.Open;
     BekletmeyiIlerlet(60,'SıraNo Üretme İşlemi','Sırano kontrol işlemleri bitti...',BekletmeDlg);
     if TabAyniKayit.Eof then
     begin
     TabUretim.Close;
     TabUretim.ParamByName('GIRISTURU').Value:=TakipCagiranTur;
     TabUretim.ParamByName('STOKID').Value:=TakipCagiranUrunId;
     TabUretim.ParamByName('SONKULLANIM').Value:=DtUrunSonKullanim.Date;
     TabUretim.ParamByName('LOTNO').Value:=EdtUrunLotNo.Text;
     TabUretim.ParamByName('URETIMTIPI').Value:=CmbUrunUretimTipi.EditingValue;
     TabUretim.ParamByName('URUNCINSI').Value:=CmbUrunUrunCinsi.EditingValue;
     TabUretim.ParamByName('URETIMTARIHI').Value:=DtUrunUretimTarihi.Date;
     TabUretim.ParamByName('GLN').Value:= TakipGLN;
     BekletmeyiIlerlet(80,'SıraNo Üretme İşlemi','Sırano kayıtarı oluşturuluyor...',BekletmeDlg);
     TabUretim.Open;
     BekletmeyiIlerlet(100,'SıraNo Üretme İşlemi','Sırano kayıtarı oluştu...',BekletmeDlg);
     end;
     //TabUretim.Close;
     //TabUretim.Open;
     lblKayitSayisi.Caption := IntToStr(TabUretim.RecordCount);
   end
   else
   ShowMessage(Its_Islem_Secilen_Adet_Gecerli_Degil);
   BekletmeDlg.Close;
end;

procedure TTakipDlg.BtnCikarClick(Sender: TObject);
begin
Tablo.Query1.Close;
Tablo.Query1.SQL.Text:='DELETE FROM GECICI_EKLENECEK_KAREKOD WHERE STOKIDID = '+TabUretimSatis.FieldByName('ID').AsString+' ';
Tablo.Query1.ExecSQL;

TabUretimSatis.Close;
TabUretimSatis.Open;
end;

procedure TTakipDlg.BtnKapatClick(Sender: TObject);
begin
if TakipizlemTuru = 3 then
  begin
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := 'DELETE FROM KAREKOD WHERE  STOKIDID IN (SELECT ID FROM STOKID WHERE GIRFATBASID=99999)';
    Tablo.Query5.ExecSQL;
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := 'DELETE FROM STOKID WHERE GIRFATBASID=99999';
    Tablo.Query5.ExecSQL;
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := '  IF EXISTS (select * from sys.objects where type =''U'' AND name =''GECICI_EKLENECEK_KAREKOD'')';
    Tablo.Query5.SQL.add('BEGIN   DROP TABLE GECICI_EKLENECEK_KAREKOD END');
    Tablo.Query5.ExecSQL;
  end;
  ModalResult:= mrCancel;
  Close;
end;

procedure TTakipDlg.btnKaydetClick(Sender: TObject);
begin
UniqueIslem(TakipizlemTuru);
end;

procedure TTakipDlg.BtnUrunGetirClick(Sender: TObject);
var
PtsIstek : TPTSAlimIstek;
Yanit : TGenelYanit;
GelenHataKodu : string;
begin
PtsIstek := TPTSAlimIstek.Create;
PtsIstek.FR := GLNFirma; // GLN No : 8680001407743
PtsIstek.TRANSFERID := TxtTransferNo.Text;
GelenHataKodu := XMLGelenIsle(XMLGonderPts(PtsIstek),PtsIstek.Urunler);
if GelenHataKodu<>'' then
Application.MessageBox(PChar(GelenHataKodu),PChar(Uyari), MB_OK+ MB_ICONWARNING);
end;

procedure TTakipDlg.clmKareKodSecPropertiesChange(Sender: TObject);
begin
if ( Takipislemturu = 'GD' ) and
     (tabKareKodListesi.FieldByName('CIKFATURAID').AsInteger>0) and
     (clmKareKodSec.EditValue='True') then
   begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış, Değişiklik yapılamaz','H A T A',MB_ICONERROR+MB_OK);
        clmKareKodSec.EditValue:='False';
        clmSiraNo.Editing:=False;
        Abort;
   end;
end;

procedure TTakipDlg.clmKareKodSecPropertiesEditValueChanged(Sender: TObject);
begin
//  if clmKareKodSec.EditValue='True' then
//     begin
//     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)+1);
     //lblGerekliSayi.Caption:= IntToStr(strtoint(lblGerekliSayi.Caption)+1);
//     end
//   else
//   begin
//     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)-1);
     //lblGerekliSayi.Caption:= IntToStr(strtoint(lblGerekliSayi.Caption)+1);
//   end;
end;

procedure TTakipDlg.clmSeriNoSecPropertiesChange(Sender: TObject);
begin
  if (Takipislemturu='GD')and(tabSeriNoListesi.FieldByName('CIKFATURAID').AsInteger>0)and(clmSeriNoSec.EditValue='True')then begin
    Application.MessageBox('Bu ürünün çıkışı yapılmış, Değişiklik yapılamaz','H A T A',MB_ICONERROR+MB_OK);
    clmSeriNoSec.EditValue:='False';
    Abort;
  end;
end;

procedure TTakipDlg.clmSeriNoSecPropertiesEditValueChanged(Sender: TObject);
begin
   if clmSeriNoSec.EditValue='True' then
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)+1)
   else
     lblKayitSayisi.Caption:= IntToStr(strtoint(lblKayitSayisi.Caption)-1);
end;

procedure TTakipDlg.cxButton1Click(Sender: TObject);
Var
Etiketler ,Bilgiler: TArrayOfString;
begin
   RehberId := Tablo.RehberAra_IDGetir(-1);
   if RehberId>0 then begin
     Tablo.RehberEkBilgileriniGetir(RehberId,2,[81],Etiketler,Bilgiler);
     TakipGLN :=   Bilgiler[0];
     txtGln.Text    :=  Bilgiler[0];
   end;
end;

procedure TTakipDlg.cxButton2Click(Sender: TObject);
var
Barkod : string;
begin
  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text:='SELECT GTIN,LOTNUMARASI,SUBSTRING(CONVERT(VARCHAR(10),convert(datetime,SONKULLANIMTARIHI,102),112),3,6) AS BARKODTARIH,SIRANO FROM ITS_PTS_GELEN_URUN ' +
                       'WHERE  LOTNUMARASI = '''+TakipCagiranLotno+''' and  GIRFATBASID ='+IntToStr(TakipCagiranBaslikId)+'  ';
  Tablo.Query4.Open;

 Tablo.Query4.First;
  while not Tablo.Query4.Eof do
  begin
  Barkod := '01'+Tablo.Query4.FieldByName('GTIN').asstring+'21'+Tablo.Query4.FieldByName('SIRANO').asstring+'17'+
  Tablo.Query4.FieldByName('BARKODTARIH').asstring+'10'+Tablo.Query4.FieldByName('LOTNUMARASI').asstring;
  memoKareKodlar.Lines.Add(Barkod);
  Tablo.Query4.Next;
  end;


end;

procedure TTakipDlg.cxGridDBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
 AColumn : TcxGridColumn;
begin
      AColumn := (Sender as TcxGridDBTableView).GetColumnByFieldName('CIKFATURAID');
      if AColumn <> nil then
        if (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '') and
           (VarToStr(Sender.DataController.GetValue(ARecord.RecordIndex,AColumn.Index)) > '0')
        then
            AStyle := tablo.cxStSerinoCikilmis;
end;

procedure TTakipDlg.dtsKareKodListesiStateChange(Sender: TObject);
begin
btnIptal.Enabled:= dtsKareKodListesi.State in [dsEdit,dsInsert];
end;

procedure TTakipDlg.dtsSeriNoListesiStateChange(Sender: TObject);
begin
  btnIptal.Enabled:= dtsSeriNoListesi.State in [dsEdit,dsInsert];


end;

procedure TTakipDlg.DtsUretimSatisDataChange(Sender: TObject; Field: TField);
begin
lblKayitSayisi.Caption := IntToStr(TabUretimSatis.RecordCount);
end;

procedure TTakipDlg.editKareKodKeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then
   begin
      lblKayitSayisi.Caption:='0';
      tabKareKodListesi.Close;
      tabKareKodListesi.SQL.Text:= 'SELECT * FROM STOKID WHERE  STOKID = '+ IntToStr(TakipCagiranUrunId)+' '+
                                  ' AND ISNULL(SIRANO,'''') LIKE '''+editKareKod.Text+'%''  ';
      if Takipislemturu = 'C' then // çıkışı yapılmamış seri numaraları
       tabKareKodListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) = 0 AND ISNULL(CIKFATURAID,0) = 0')
      else if (Takipislemturu = 'CD') and ( TakipCagiranTur in [14, 15, 16] ) then // çıkılan KareKodlar üzerinde düzeltme yapılacaksa
       tabKareKodListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) > 0 AND ISNULL(CIKFATURAID,0) = '+inttostr(TakipCagiranSatirId))
      else if (Takipislemturu = 'GD') and ( TakipCagiranTur in [10, 11, 12] ) then // Girilen KareKodlar üzerinde düzeltme yapılacaksa
       tabKareKodListesi.SQL.Add(' AND ISNULL(GIRISTURU,0) > 0 AND ISNULL(GIRFATBASID,0) = '+inttostr(TakipCagiranBaslikId)+' AND ISNULL(GIRFATURAID,0) = '+inttostr(TakipCagiranSatirId));
      tabKareKodListesi.Open;
    end;
end;

procedure TTakipDlg.editSeriNoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var _depo:Integer;
begin
  if Key = 38 then
    tabSeriNoListesi.Prior
  else if Key = 40 then
    tabSeriNoListesi.next
  else
   begin
      lblKayitSayisi.Caption:='0';
      tabSeriNoListesi.Close;
      if (Takipislemturu = 'GD') or (Takipislemturu = 'G') or (Takipislemturu='T') then
      _depo := TakipDepoID;
      if (Takipislemturu = 'CD') or (Takipislemturu = 'C') then
      _depo := TakipCikisDepoID;

      tabSeriNoListesi.SQL.Text:= 'SELECT * FROM STOKID WHERE STOKID = '+ IntToStr(TakipCagiranUrunId)+' '+
                          ' AND SERINO LIKE '''+editSeriNo.Text+'%'' AND DEPOID='+IntToStr(_depo)+'   ';

      if Takipislemturu = 'C' then // çıkışı yapılmamış seri numaraları
       tabSeriNoListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) = 0 AND ISNULL(CIKFATURAID,0) = 0')
      else if (Takipislemturu = 'CD') and ( TakipCagiranTur in [14, 15, 16] ) then // çıkılan seri nolar üzerinde düzeltme yapılacaksa
       tabSeriNoListesi.SQL.Add(' AND ISNULL(CIKISTURU,0) > 0 AND ISNULL(CIKFATURAID,0) = '+inttostr(TakipCagiranSatirId))
      else if (Takipislemturu = 'GD') and ( TakipCagiranTur in [10, 11, 12] ) then // Girilen seri nolar üzerinde düzeltme yapılacaksa
       tabSeriNoListesi.SQL.Add(' AND ISNULL(GIRISTURU,0) > 0 AND ISNULL(GIRFATURAID,0) = '+inttostr(TakipCagiranSatirId))
      else if (Takipislemturu = 'GD') and ( TakipCagiranTur = 7 ) then // Sayım  düzenleme yapılacaksa
       tabSeriNoListesi.SQL.Add(' AND ISNULL(GIRISTURU,0) > 0 ');

      tabSeriNoListesi.Open;
   end;
end;

procedure TTakipDlg.EdtSiraNoEklemeKeyPress(Sender: TObject; var Key: Char);
var
Karekod : TKareKodType;
begin
 if (Key=#13) and (Length(EdtSiraNoEkleme.Text) <= 20) then
   begin
    TabSatisEkle.Close;
    TabSatisEkle.ParamByName('SIRANO').Value :=  EdtSiraNoEkleme.Text;
    TabSatisEkle.ParamByName('STOKID').Value :=  TakipCagiranUrunId;
    TabSatisEkle.ExecSQL;
    TabUretimSatis.Close;
    TabUretimSatis.Open;
   end;
 if (Key=#13) and (Length(EdtSiraNoEkleme.Text) > 20) then
   begin
    Karekod := KareKodParcala(EdtSiraNoEkleme.Text);
    EdtSiraNoEkleme.Text:='';
    TabSatisEkle.Close;
    TabSatisEkle.ParamByName('SIRANO').Value :=  Karekod.UrunSeriNumarası;
    TabSatisEkle.ParamByName('BARKOD').Value :=  Karekod.UrunNumarası;
    TabSatisEkle.ExecSQL;
    TabUretimSatis.Close;
    TabUretimSatis.Open;
   end;
end;

procedure TTakipDlg.EdtSSCCKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then begin
     //sscc numarasına göre gelecek kayıtlar

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:=' WITH AltKirilim(ID,USTID) AS'+
    '(	SELECT ID,-1 FROM ITS_TASIMA_BIRIMI WHERE SSCC = '''+EdtSSCC.Text+''' '+
	  ' UNION ALL '   +
	  '  SELECT itb.ID,itb.USTID FROM ITS_TASIMA_BIRIMI itb  '+
    ' INNER JOIN AltKirilim t ON (itb.USTID = t.ID) AND (t.ID <> t.USTID) ) '+
    ' SELECT S.ID,S.SIRANO,S.STOKID,  '+
    ' (SELECT '+DbUst(1)+'SSCC FROM ITS_TASIMA_BIRIMI TB WHERE TB.ID=S.TASIMA_BIRIMI_ID '+DbSinir(1)+') FROM STOKID S '+
		'	INNER JOIN ITS_PAKET P ON P.ID = S.PAKETID '+
		'	WHERE ISNULL(S.CIKFATBASID,0)=0 ' +
		'	AND S.TASIMA_BIRIMI_ID IN       ' +
    '  (SELECT DISTINCT itb.ID FROM ITS_TASIMA_BIRIMI itb INNER JOIN AltKirilim a ON itb.ID = a.ID)  ';
    Tablo.Query1.Open;

    if Tablo.Query1.IsEmpty then
    begin
      ShowMessage('Etiket numarasında ürün bulunmuyor');
      Abort;
    end;
    Tablo.Query1.First;
    while not Tablo.Query1.Eof   do Begin
      TabSatisEkle.Close;
      TabSatisEkle.ParamByName('SIRANO').Value := Tablo.Query1.FieldByName('SIRANO').AsString ;
      TabSatisEkle.ParamByName('STOKID').Value := Tablo.Query1.FieldByName('STOKID').AsString ;
      TabSatisEkle.ExecSQL;
      Tablo.Query1.Next;
    End;
    TabUretimSatis.Close;
    TabUretimSatis.Open;
  end;
end;

procedure TTakipDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//if stUretimEkle.Showing then
//IzlemTuruUretimIse := True else IzlemTuruUretimIse := False;
end;

procedure TTakipDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakipDlg.FormShow(Sender: TObject);
var
 k:Char;
 ks:Word;
begin
  k:= #13;
  BtnUretim.Visible := False;
  BtnPaket.Visible := False;
  Pgizlem.HideTabs := True;
  pgKareKod.HideTabs := True;
  lblHataMesaj.Caption:='';
  TsKarekod.Visible := False;
  TsKarekod.TabVisible := False;
  TsSeriNo.Visible := False;
  TsSeriNo.TabVisible := False;
  if TakipizlemTuru = 1 then begin //SeriNo
    TsSeriNo.Visible:=True;
    TsSeriNo.TabVisible:=True;
  end else if TakipizlemTuru = 3 then begin //Karekod
    TsKarekod.Visible:=True;
    TsKarekod.TabVisible:=True;
    txtGln.Text:= TakipGLN;
  end;
  lblGerekliSayi.Caption:= IntToStr(TakipUniqueSayisi);
  if (Takipislemturu = 'GD') or (Takipislemturu = 'CD') then begin
     btnKaydet.Caption:=' Çıkar';
    if TakipizlemTuru=3 then
      editKareKodKeyPress(Self,k)
    else if TakipizlemTuru=1 then begin
      editSeriNoKeyUp(Self,ks,[]);
    end;
  end else if (Takipislemturu = 'T') then begin
    btnKaydet.Caption:=' Transfer Et';
    if TakipizlemTuru=3 then
      editKareKodKeyPress(Self,k)
    else if TakipizlemTuru=1 then begin
      editSeriNoKeyUp(Self,ks,[]);
    end;
  end else if (Takipislemturu='C') then begin
    if TakipCagiranTur=20 then
      btnKaydet.Caption:=' Tamam'
    else
     btnKaydet.Caption:=' Çıkar';
    if TakipizlemTuru=3 then begin
      TabKarekodSatilacakListesi.Close;
      TabKarekodSatilacakListesi.ParamByName('STOKID').Value :=  TakipCagiranUrunId;
      TabKarekodSatilacakListesi.Open;
      BtnPaket.Visible := True;
    end else if TakipizlemTuru=1 then begin
      editSeriNoKeyUp(Self,ks,[]);
    end;
    Tablo.Query6.Close;
    Tablo.Query6.SQL := MemoTempOlustur.Lines;
    Tablo.Query6.ExecSQL;
  end else begin
    btnKaydet.Caption:=' Kaydet';
    tablo.Query3.Close;
    Tablo.Query3.SQL.Text:='SELECT SIRANO FROM STOKID ORDER BY ID DESC';
    Tablo.Query3.Open;
    shtSeriNoDuzeltSil.TabVisible := True;
    LblEnSonSira.Caption:=Tablo.Query3.FieldByName('SIRANO').AsString;
    EdtUrunAdet.Text:= IntToStr(TakipUniqueSayisi);
  end;
  //seritakipsayısı 0 gönderilirse sadece grid üzerinden seri no düzeltme işlemi yapılabilir.
  if TakipizlemTuru=1 then begin
    Tablo.Query6.Close;
    Tablo.Query6.SQL.Text:= 'SELECT GARANTISURESI FROM STOKLAR WHERE ID='+inttostr(TakipCagiranUrunId)+' ';
    Tablo.Query6.Open;
    edGarantiSure.Value:= Tablo.Query6.Fields[0].AsInteger;
  end;
  if TakipizlemTuru=3 then begin
    Tablo.Query6.Close;
    Tablo.Query6.SQL := MemoCreate.Lines;
    Tablo.Query6.ExecSQL;
    DtUrunUretimTarihi.Date:= Now;
    BtnUretim.Visible := True;
  end;
end;

procedure TTakipDlg.HatalilariEkle(Unique, HataMesaji: string;IzlemTuru : Integer);
var
I:Byte;
ChildNode : tcxtreelistnode;
begin
  lblHataMesaj.Visible:=True;
  lblHataMesaj.Caption:= HataMesaji;
  if IzlemTuru=1 then begin  //SeriNo
    lblHataliSeriNo.Visible:= Unique<>'' ;
    memoHataliSeriNo.Visible:=Unique<>'';
    if Unique<>'' then
      memoHataliSeriNo.Lines.Add(Unique);
  end;
  if IzlemTuru=3 then //Karekod
  begin
  //for I := 0 to  TreeListKareKod.Count -1 do
  //begin
   // if TreeListKareKod.Items[I].Texts[1] = Unique then
   // begin
   // ChildNode := TreeListKareKod.AddChild(TreeListKareKod.Items[I], nil);
   // ChildNode.Texts[0] := HataMesaji;
   // end;
      LblHataliSeriNo.Visible:= Unique<>'' ;
      memoHataliSeriNo.Visible:=Unique<>'';
   //end;
  end;
end;

procedure TTakipDlg.memoKareKodlarKeyPress(Sender: TObject; var Key: Char);
var
 i : Integer;
NewNode, ChildNode : TcxTreeListNode;
begin
  if Key = #13 then begin
    lblKayitSayisi.Caption:='0';
    setLength(KareKodlar,memoKareKodlar.Lines.Count);
    TreeListKareKod.Clear;
    for i := 0 to memoKareKodlar.Lines.Count - 1 do
     begin
      if StringReplace(memoKareKodlar.Lines[i],' ','',[rfReplaceAll])<>'' then
       begin
        lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
        KareKodlar[i] := KareKodParcala(memoKareKodlar.Lines[i]);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text:= 'SELECT ID FROM STOKID WHERE  ISNULL(CIKFATBASID,0)=0 AND URUNBARKOD = '''+KareKodlar[i].UrunNumarası+''' AND SIRANO = '''+KareKodlar[i].UrunSeriNumarası+''' ';
        Tablo.Query1.Open;
        NewNode := TreeListKareKod.Add;
        NewNode.Texts[0] := KareKodlar[i].UrunNumarası;
        NewNode.Texts[1] := KareKodlar[i].UrunSeriNumarası;
        NewNode.Texts[2] := KareKodlar[i].Lotno;
        NewNode.Texts[3] := KareKodlar[i].SonKullanım;
        if  (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])>=0) and (memoKareKodlar.Lines.IndexOf(memoKareKodlar.Lines[i])<>i) then
          begin
            ChildNode := TreeListKareKod.AddChild(NewNode, nil);
            ChildNode.Expand(False);
            ChildNode.Texts[0] := 'KareKod Tekrarı';
          end;
        if not Tablo.Query1.IsEmpty then
          begin
            ChildNode := TreeListKareKod.AddChild(NewNode, nil);
            ChildNode.Expand(False);
            ChildNode.Texts[0] := 'Daha önce Eklenmiş';
          end;
       end;
     end;
  end;

end;

function TTakipDlg.KareKodParcala(KareKod: string) : TKareKodType;
  var
    strEan,strSN,str17,str10 ,strGen:string;
    PosSpecialChr,PosSpecialChrSKT:Integer;
function PosChrSKT(str:string):Integer;
 var
  Pos17:Integer;AStr:string;
  TopPos:Integer;
 begin
  AStr:=str;
  TopPos:=0;
  Repeat
    Pos17:=Pos('17',Astr);
    if (pos17>0) then begin
     if Copy(Astr,Pos17+8,2)='10' then begin
      TopPos:=TopPos+pos17;
      result:=TopPos;
      Break;
     end
     else begin
          TopPos:=TopPos+pos17+1;// 17 yi aradan çıkaracağımız için 7 hiç hesaplanmadığından pozisyonu 1 arttırıyoruz.
          Astr:=Copy(AStr,pos17+2,1000);
     end;
    end
    else
      result:=0;
  Until pos17=0
 end; //Eklendi

begin
  if Copy(KareKod,1,2)='01' then
  begin
      PosSpecialChrSKT:= PosChrSKT(KareKod);
    if PosSpecialChrSKT>0 then
      strGen:=KareKod
    else
      strGen:='';
    strEan:= Copy(strGen,4,13);
    Result.UrunNumarası := '0'+strEan;
    strSN:=Copy(strGen,19,PosSpecialChrSKT-19 );//Pos( Char(119),strGen)
    Result.UrunSeriNumarası := Trim(strSN);
    str17:=Copy(strGen,PosSpecialChrSKT+2,6 );
    if str17<>'' then
     Result.SonKullanım:=Copy(str17,5,2)+'/'+Copy(str17,3,2)+'/'+'20'+Copy(str17,1,2)
    else
     Result.SonKullanım:='';
    str10:=Copy(strGen,PosSpecialChrSKT+10,length(strGen)-1);
    Result.Lotno:= trim(str10);
    strGen := '';
  end
  else
  begin
    result.UrunNumarası := '';
    result.UrunSeriNumarası := '';
    result.Lotno := '';
    result.SonKullanım := '';
  end;
end;


procedure TTakipDlg.memoSeriNolarPropertiesChange(Sender: TObject);
var
 i : Integer;
begin
  lblKayitSayisi.Caption:='0';
  for i := 0 to memoSeriNolar.Lines.Count - 1 do
   begin
    if StringReplace(memoSeriNolar.Lines[i],' ','',[rfReplaceAll])<>'' then
     lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
   end;
end;

procedure TTakipDlg.memoSeriNolarPropertiesEditValueChanged(Sender: TObject);
var
 i : Integer;
begin
  lblKayitSayisi.Caption:='0';
  for i := 0 to memoSeriNolar.Lines.Count - 1 do
   begin
    if StringReplace(memoSeriNolar.Lines[i],' ','',[rfReplaceAll])<>'' then
     lblKayitSayisi.Caption:= IntToStr( strtoint(lblKayitSayisi.Caption)+1 );
   end;
end;

procedure TTakipDlg.pgSeriNoChange(Sender: TObject);
var
 k : Word;
begin
  if pgSeriNo.ActivePage= shtSeriNoGiris then
   memoSeriNolarPropertiesEditValueChanged(Self)
  else
     editSeriNoKeyUp(Self,k,[]);
end;

procedure TTakipDlg.UniqueIslem(IzlemTuru:Integer);
begin
  if IzlemTuru=1 then //SeriNo
  begin
  if shtSeriNoDuzeltSil.TabVisible then
   begin
     if dtsSeriNoListesi.State in [dsEdit,dsInsert] then
      tabSeriNoListesi.Post;
   end;
  memoHataliSeriNo.Visible:=False;
  lblHataliSeriNo.Visible:=False;
  lblHataMesaj.Caption:='';
  if (Takipislemturu ='GD') or (Takipislemturu ='CD')  then
     clmSeriNo.Editing:= True // sadece düzeltme parametresi ile çağırılırsa ilgili kayıt düzeltilebilir.
  else
   clmSeriNo.Editing:= False;

   clmGarantiBitis.Editing:= clmSeriNo.Editing;
   edGarantiSure.Visible:= Takipislemturu='G';
   lblGarantiSure.Visible:= edGarantiSure.Visible;
  end else if IzlemTuru=3 then //Karekod
  begin
  if shtKareKodDuzeltSil.TabVisible then
   begin
     if dtsKareKodListesi.State in [dsEdit,dsInsert] then
      tabKareKodListesi.Post;
   end;

  lblHataMesaj.Caption:='';
  if (Takipislemturu ='GD') or (Takipislemturu ='CD')  then
     clmSiraNo.Editing:= True // sadece düzeltme parametresi ile çağırılırsa ilgili kayıt düzeltilebilir.
  else
   clmSiraNo.Editing:= False;
  // clmLotno.Editing:= clmSeriNo.Editing;
  end;

{$REGION 'UniqueGiriş'}
  if Takipislemturu= 'G' then
   begin // Yeni Seri No Girişi
     if IzlemTuru=1 then
      if memoSeriNolar.Lines.Count <> TakipUniqueSayisi then
       begin
         HatalilariEkle('','Listedeki sayı gereken sayıdan farklı, lütfen kontrol ediniz',IzlemTuru);
         abort;
       end;
     if IzlemTuru=3 then
      if StrToInt(lblKayitSayisi.Caption) <> TakipUniqueSayisi then
       begin
         HatalilariEkle('','Listedeki sayı gereken sayıdan farklı, lütfen kontrol ediniz',IzlemTuru);
         abort;
       end;

      if BosSatirKontrol(IzlemTuru)  then abort;
      if AyniUniqueVarmi(IzlemTuru)   then Abort;
      if TablodaAyniUniqueVarmi(IzlemTuru) and IzlemTuruUretimIse then abort;
      if IzlemTuru=3 then
      if GlnVarmi(IzlemTuru) and IzlemTuruUretimIse then Abort;

       //tüm kontrolleri geciyorsa seri no girişi yapılabilir
      if not IzlemTuruUretimIse then
      UniqueGir(IzlemTuru);

      ModalResult:=mrOk;
   end
{$ENDREGION}
 else
{$REGION 'UniqueÇıkış'}
 if Takipislemturu = 'C' then
   begin
      if not (YeterliUniqueSecildimi(IzlemTuru)) then abort;
       UniqueCık(IzlemTuru);
      ModalResult:=mrOk;
   end
{$ENDREGION}
{$REGION 'Giriş-Çıkış Düzeltme'}
 else
 if (Takipislemturu = 'GD') or (Takipislemturu = 'CD') then
    begin
    if not (YeterliUniqueSecildimi(IzlemTuru)) then abort;
       UniqueGirisCikisDuzenle(IzlemTuru);
       ModalResult:= mrOk;
    end

{$ENDREGION}
{$REGION 'Transfer'}
 else
  if Takipislemturu='T' then
  begin
   if not (YeterliUniqueSecildimi(IzlemTuru)) then abort;
       UniqueCık(IzlemTuru);
       ModalResult:= mrOk;
  end;
{$ENDREGION}
end;

function TTakipDlg.YeterliUniqueSecildimi(IzlemTuru: Integer): Boolean;
 begin
      Result:=True;
      if lblKayitSayisi.Caption<>lblGerekliSayi.Caption then
       begin
         HatalilariEkle('','Seçilen Sayısı gereken sayıdan farklı, lütfen kontrol ediniz',IzlemTuru);
         Result:=False;
       end;
 end;

function TTakipDlg.GlnVarmi(IzlemTuru: Integer): Boolean;
var
 i: Integer;
begin
  Result:=False;
  if TakipGLN<>'' then
  begin
  Result:=False;
  end else
  BEGin
  Result:= True; lblHataMesaj.Caption:='Firma GLN numarası bulunmamaktadır.';
  End;
end;


function TTakipDlg.TablodaAyniUniqueVarmi(IzlemTuru: Integer): Boolean;
var
 i: Integer;
begin
  Result:=False;
  if IzlemTuru=1 then //SeriNo
  begin
  memoHataliSeriNo.Lines.Clear;
  for i := 0 to memoSeriNolar.Lines.Count - 1 do
   begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM STOKID WHERE STOKID = '+IntToStr(TakipCagiranUrunId)+' AND SERINO = '''+memoSeriNolar.Lines[i]+''' ';
      Tablo.Query5.Open;
      if not Tablo.Query5.IsEmpty then
       begin
         Result:=True;
         HatalilariEkle(memoSeriNolar.Lines[i],'Aynı ürün için listedeki seri numaraları daha önce kullanılmıştır. Lütfen kontrol ediniz',IzlemTuru);
       end;
   end;
  end;
  if IzlemTuru=3 then //KareKod
  begin
  for i := 0 to memoKareKodlar.Lines.Count - 1 do
   begin
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM STOKID WHERE STOKID = '+IntToStr(TakipCagiranUrunId)+' AND  URUNBARKOD = '''+TreeListKareKod.Items[i].Texts[0]+'''  AND SIRANO = '''+TreeListKareKod.Items[i].Texts[1]+''' ';
      Tablo.Query5.Open;
      if not Tablo.Query5.IsEmpty then
       begin
         Result:=True;
         HatalilariEkle(TreeListKareKod.Items[i].Texts[1],'Aynı ürün için listedeki seri numaraları daha önce kullanılmıştır. Lütfen kontrol ediniz',IzlemTuru);
       end;
   end;
  end;
end;

procedure TTakipDlg.tabSeriNoListesiBeforeEdit(DataSet: TDataSet);
begin
OncekiUnique:= tabSeriNoListesi.FieldByName('SERINO').AsString;
end;

procedure TTakipDlg.tabSeriNoListesiBeforePost(DataSet: TDataSet);
begin
  if OncekiUnique<>tabSeriNoListesi.FieldByName('SERINO').AsString then
   begin
     if (TakipCagiranTur in [7, 10, 11, 12]) and (tabSeriNoListesi.FieldByName('CIKFATURAID').AsInteger>0 ) then
      begin
        Application.MessageBox('Bu ürünün çıkışı yapılmış, Seri Numarası değiştirilemez','H A T A',MB_ICONERROR+MB_OK);
        Abort;
      end;
      Tablo.Query5.Close;
      Tablo.Query5.SQL.Text:= 'SELECT * FROM STOKID WHERE '+
                              ' STOKID = '+IntToStr(TakipCagiranUrunId)+' AND SERINO = '''+tabSeriNoListesi.FieldByName('SERINO').AsString+''' '+
                              ' AND ID <>'+tabSeriNoListesi.FieldByName('ID').AsString+' ';
      Tablo.Query5.Open;
     if not Tablo.Query5.IsEmpty then
      begin
         Application.MessageBox(PChar(tabSeriNoListesi.FieldByName('SERINO').AsString+' seri numarası bu ürün için daha önce kullanılmış, tekrar girilemez') ,'H A T A',MB_ICONERROR+ MB_OK);
         Abort;
      end;
   end;
end;

procedure TTakipDlg.UniqueCık(IzlemTuru: Integer);
var
i:Integer;
begin
if IzlemTuru=1 then //SeriNo
begin
    tabSeriNoListesi.First;
    i:=0;
    while not (tabSeriNoListesi.Eof) do
     begin
       if clmSeriNoSec.EditValue='True' then
        begin
         faturaurunserinolar[i]:= tabSeriNoListesi.FieldByName('SERINO').AsString;
         i:=i+1;
        end;
     // Tablo.UniqueCikis(TakipCagiranTur,TakipizlemTuru,TakipCagiranUrunId, TakipCagiranBaslikId, TakipCagiranSatirId,tabSeriNoListesi.FieldByName('SERINO').AsString,'');
      TabSeriNoListesi.Next;
     end;
end else
  if (IzlemTuru=3) then //and (TabUretimSatis.RecordCount<=0)  then //Karekod
  begin
    TabUretimSatis.FetchAll;
    SetLength(FaturaUrunKareKodlar,TabUretimSatis.RecordCount);
    TabUretimSatis.First;
    i:=0;
    while not (TabUretimSatis.Eof) do
     begin
          FaturaUrunKareKodlar[i].UrunNumarası:= TabUretimSatis.FieldByName('URUNBARKOD').AsString;
          FaturaUrunKareKodlar[i].UrunSeriNumarası := TabUretimSatis.FieldByName('SIRANO').AsString;
        i:=i+1;
        TabUretimSatis.Next;
     end;

  end;
end;

procedure TTakipDlg.UniqueGir(IzlemTuru: Integer);
var
   i : integer;
begin
if IzlemTuru=1 then //SeriNo
  begin
     //fatura id si yeni kayıt sırasında oluşmamış olduğu için diziye atıyoruz, after post ta dizinden giriş kayıtları oluşuyor
     faturaurungarantisuresi:= edGarantiSure.Value;
     for i := 0 to memoSeriNolar.Lines.Count - 1 do
        faturaurunserinolar[i]:= memoSeriNolar.Lines[i];
    //Tablo.SeriNoGiris(SeriTakipCagiranTur,SeriTakipCagiranUrunId,SeriTakipCagiranBaslikId,SeriTakipCagiranSatirId,memoSeriNolar.Lines[i]);
  end;
  if (IzlemTuru=3)  then //Karekod
  begin
     for i := 0 to TreeListKareKod.Count - 1 do
     begin
      FaturaUrunKareKodlar[i].UrunSeriNumarası:= TreeListKareKod.Items[i].Texts[1];
      FaturaUrunKareKodlar[i].UrunNumarası:= TreeListKareKod.Items[i].Texts[0];
      FaturaUrunKareKodlar[i].Lotno:= TreeListKareKod.Items[i].Texts[2];
      FaturaUrunKareKodlar[i].SonKullanım:= TreeListKareKod.Items[i].Texts[3];
     end;
  end;

end;

procedure TTakipDlg.UniqueGirisCikisDuzenle(IzlemTuru:Integer);
begin
     if IzlemTuru=1 then //SeriNo
     begin
      tabSeriNoListesi.First;
      while not (tabSeriNoListesi.Eof) do
       begin
        if (clmSeriNoSec.EditValue='True') then
         begin
         if (Takipislemturu = 'GD') then
           Tablo.UniqueSil(TakipCagiranUrunId,TakipCagiranTur,TakipCagiranBaslikId,
           TakipCagiranSatirId,0,0,0,tabSeriNoListesi.FieldByName('SERINO').AsString,'','',IzlemTuru)
         else
           Tablo.UniqueSil(TakipCagiranUrunId,0,0,0,TakipCagiranTur,TakipCagiranBaslikId,
           TakipCagiranSatirId,tabSeriNoListesi.FieldByName('SERINO').AsString,'','',IzlemTuru);
        end;
        tabSeriNoListesi.Next;
       end;
     end;
     if IzlemTuru=3 then //Karekod
     begin
       tabKareKodListesi.First;
      while not (tabKareKodListesi.Eof) do
       begin
        if (clmKareKodSec.EditValue='True') then
         begin
         if (Takipislemturu = 'GD') then
           Tablo.UniqueSil(TakipCagiranUrunId,TakipCagiranTur,0,
           TakipCagiranBaslikId,TakipCagiranSatirId,0,0,'',tabKareKodListesi.FieldByName('URUNBARKOD').AsString,tabKareKodListesi.FieldByName('SIRANO').AsString,IzlemTuru)
         else
           Tablo.UniqueSil(TakipCagiranUrunId,0,TakipCagiranTur,0,0,
           TakipCagiranBaslikId,TakipCagiranSatirId,'',tabKareKodListesi.FieldByName('URUNBARKOD').AsString,tabKareKodListesi.FieldByName('SIRANO').AsString,IzlemTuru);
         end;
        tabKareKodListesi.Next;
       end;

     end;

end;
end.





