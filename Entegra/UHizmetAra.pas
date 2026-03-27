unit UHizmetAra;

interface

uses
  Windows,  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, Menus, FireDAC.Comp.Client,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, StdCtrls, ToolWin,
  ExtCtrls, cxImageComboBox, cxContainer, cxTextEdit, cxMaskEdit,
  cxDropDownEdit,PrjConst,
  cxDBEdit, dxSkinLondonLiquidSky, cxCurrencyEdit, cxTL, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxDBTL, cxTLData, cxPC, cxImage, cxLabel, cxLookAndFeels,
  cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxNavigator, dxSkinLiquidSky,
  dxBarBuiltInMenu, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint;

type
  THizmetAraDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    LabelAdi: TLabel;
    LabelBirim: TLabel;
    Label4: TLabel;
    LabelYer: TLabel;
    AraKod: TEdit;
    AraStokAdi: TEdit;
    Adet: TEdit;
    UpDown1: TUpDown;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    DataSource1: TDataSource;
    QueryIslem: TFDQuery;
    PopupUcret: TPopupMenu;
    Y00: TMenuItem;
    Y10: TMenuItem;
    Y15: TMenuItem;
    Y20: TMenuItem;
    Y25: TMenuItem;
    Y30: TMenuItem;
    Y35: TMenuItem;
    Y40: TMenuItem;
    Y45: TMenuItem;
    Ozel: TMenuItem;
    N2: TMenuItem;
    ExceleGnder1: TMenuItem;
    N1: TMenuItem;
    HepsiniSil1: TMenuItem;
    PopupMenu1: TPopupMenu;
    IsleminUcretiniSorMenu: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyleRepository2: TcxStyleRepository;
    cxStyle2: TcxStyle;
    cxStyleRepository3: TcxStyleRepository;
    SKTAzKalanRenk: TcxStyle;
    SKTGecenRenk: TcxStyle;
    MinimumStokRenk: TcxStyle;
    AraBarkod: TEdit;
    LabelBarkod: TLabel;
    ToolBar3: TToolBar;
    SecTus: TToolButton;
    KapatlTus: TToolButton;
    ToolButton2: TToolButton;
    YeniHizmetTus: TToolButton;
    YeniStokTus: TToolButton;
    ToolButton4: TToolButton;
    comboBirim: TcxImageComboBox;
    cbStokDepo: TcxImageComboBox;
    cxPageControl1: TcxPageControl;
    shtHizmetAra: TcxTabSheet;
    shtStokAra: TcxTabSheet;
    DBGrid1: TcxGrid;
    tvStokAraListeview: TcxGridDBTableView;
    tvStokAraListeviewKOD: TcxGridDBColumn;
    tvStokAraListeviewAD: TcxGridDBColumn;
    tvStokAraListeviewTUR: TcxGridDBColumn;
    tvStokAraListeviewSKT: TcxGridDBColumn;
    tvStokAraListeviewADET: TcxGridDBColumn;
    tvStokAraListeviewANABIRIM: TcxGridDBColumn;
    tvStokAraListeviewFIYAT: TcxGridDBColumn;
    tvStokAraListeviewKUR: TcxGridDBColumn;
    tvStokAraListeviewMINSTOK: TcxGridDBColumn;
    DBGrid1Level1: TcxGridLevel;
    TabMasrafListe: TFDQuery;
    DtsMasrafListe: TDataSource;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn;
    LogoResim: TcxImage;
    cxLabel1: TcxLabel;
    LabelEklenen: TcxLabel;
    MemoIadeUrunAra: TMemo;
    tvStokAraListeviewMARKA: TcxGridDBColumn;
    tvStokAraListeviewMODEL: TcxGridDBColumn;
    lbFiyatAdi: TcxLabel;
    cbFiyatAdi: TcxImageComboBox;
    TabPaketListe: TFDQuery;
    procedure AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure KapatlTusClick(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure RadioHizmetClick(Sender: TObject);
    procedure YeniStokTusClick(Sender: TObject);
    procedure QueryIslemAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure AraBarkodKeyPress(Sender: TObject; var Key: Char);
    procedure cxPageControl1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure QueryIslemAfterOpen(DataSet: TDataSet);
    procedure cbFiyatAdiPropertiesEditValueChanged(Sender: TObject);
  private
    PaketEkleniyor:Boolean;
    { Private declarations }
    procedure AraBul(TabloAdi, Kod, Ad, Grup: String);
  public
    Hizmetler,Stoklar,TutarGoster,
    { Public declarations }
    Tur, HizmetAraCagiran: SmallInt;
    FiyatAdTut:String[25];
    //DepoKaydiYapildi : Boolean;
    TabFatura, TabFatBaslik: TFDQuery;
  end;

var
  HizmetAraDlg: THizmetAraDlg;

  //// 0  : tüm stoklar , 1: secili depoya ait stoklar , 2: stok sayim ekraný
implementation

uses Utablo, UGirisKutusuEx, UFaturaWizard, UResim;//,LocOnFly;
{$R *.dfm}

var
  TopAramaSayi: String[25];
  FiyatGoster, StokKontrol: Boolean;

procedure THizmetAraDlg.AraBarkodKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then begin
      AraBul('HIZMETLER', 'KOD', 'HIZMETADI', 'GRUP');
      if QueryIslem.RecordCount=1 then //bulundu
         SecTus.Click;
      AraBarkod.Text := '';
   end;
end;

procedure THizmetAraDlg.AraBul(TabloAdi, Kod, Ad, Grup: String);
var
  Brkd, FiyatG: String;
  st2, stx, s, st: String;
  Gelirmi:string[1];
  procedure StokSorguTamamla;
  begin
    if AraBarkod.Text <> '' then
      st := ' and (S.BARKOD = ''' + AraBarkod.Text + ''') '
    else begin
      if (AraKod.Text <> '') then begin
        if RadioButton1.Checked then
          st := st + ' and (S.KOD LIKE ''' + AraKod.Text + '%'') '
        else
          st := st + ' and (S.KOD LIKE ''%' + AraKod.Text + '%'') ';
      end;
      if AraStokAdi.Text <> '' then begin
        if RadioButton1.Checked then
          st := st + ' and (S.STOKADI LIKE ''' + AraStokAdi.Text + '%'') '
        else
          st := st + ' and (S.STOKADI LIKE ''%' + AraStokAdi.Text + '%'') ';
      end;
    end;
    QueryIslem.SQL.Text := QueryIslem.SQL.Text + st;
    if AraStokAdi.Text <> '' then
       QueryIslem.SQL.Text := QueryIslem.SQL.Text + ' Order by 3'
    else
       QueryIslem.SQL.Text := QueryIslem.SQL.Text + ' Order by 1';
    QueryIslem.open;
  end;
  procedure HizmetSorguTamamla;
  begin
    if AraBarkod.Text <> '' then
      st := ' and (M.BARKOD = ''' + AraBarkod.Text + ''') '
    else begin
      if (AraKod.Text <> '') then begin
        if RadioButton1.Checked then
          st := st + ' and (M.KOD LIKE ''' + AraKod.Text + '%'') '
        else
          st := st + ' and (M.KOD LIKE ''%' + AraKod.Text + '%'') ';
      end;
      if AraStokAdi.Text <> '' then begin
        if RadioButton1.Checked then
          st := st + ' and (M.AD LIKE ''' + AraStokAdi.Text + '%'') '
        else
          st := st + ' and (M.AD LIKE ''%' + AraStokAdi.Text + '%'') ';
      end;
    end;
    TabMasrafListe.SQL.Text := TabMasrafListe.SQL.Text + st;
    if AraStokAdi.Text <> '' then
       TabMasrafListe.SQL.Text := TabMasrafListe.SQL.Text + ' Order by M.AD'
    else
       TabMasrafListe.SQL.Text := TabMasrafListe.SQL.Text + ' Order by M.KOD';
    TabMasrafListe.open;
  end;
begin  //   HizmetAraCagiran 0 : giren fat, 1 çýkýþ fatura 2: sayým tutanaðý 3 : demirbaþ 4:transfer  5:teklif  6:servis
  if (not showing)or(FiyatAdTut = '') then
     exit;
  QueryIslem.SQL.Clear;
  if cxPageControl1.ActivePageIndex = 0 then     //  Hizmet
  begin
    TabMasrafListe.Close;
    if Tur in [9, 10, 11, 12, 13] then
       Gelirmi:='0'
    else
       Gelirmi:='1';
    TabMasrafListe.SQL.Text :=  '';
    TabMasrafListe.SQL.Add(' select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))), '+
                           ' URUNID=M.ID,M.KOD,M.AD,M.DURUM,M.TUR,M.KDV,F.FIYAT,F.KUR from MASRAFGELIR M ');
    TabMasrafListe.SQL.Add(' left outer join FIYATLAR F on M.ID=F.HIZMETID and F.FIYATADI='+FiyatAdTut+' '+
                           ' WHERE  GELIRMI = '+Gelirmi);
    HizmetSorguTamamla;
  end;

  if (Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme)) and (cxPageControl1.ActivePageIndex = 1) then begin // Burada Stok Seçimi var
    if cbStokDepo.EditValue=null then
       raise Exception.Create('Önce Depo Seçin!');
    if FiyatGoster then
      FiyatG := ', convert(varchar(18), convert(money, isnull(FIYAT,0.0)))+'' ''+isnull(DOVIZ,'' TL'')AS FIYAT  '
    else
      FiyatG := '';

     //   HizmetAraCagiran 0 : giren fat, 1 çýkýþ fatura 2: sayým tutanaðý 3 : demirbaþ
     //     4:transfer  5:teklif  6:servis   7 : iade alýþ fiþi
     //tüm stoklar gelicek
     //elimizdeki stoklar gelicek
    //tvStokAraListeviewFIYAT.Visible := HizmetAraCagiran in [0,1,5,6];
    case HizmetAraCagiran of
      0, 2, 3, 5, 6:
        begin // stoklar tablosu tamamen gelecek
          QueryIslem.SQL.Text := ' Select distinct ' + TopAramaSayi + ' S.ID as URUNID, S.KOD, STOKADI AS AD, ' +
             ' cast(''STOK'' as varchar(5)) AS TUR, ''1900-01-01'' as SKT, ' +
             ' 0 AS ADET,ANABIRIM, BIRIM2, isnull(MINSTOK,0) as MINSTOK,MASRAFID,KDV, SF.FIYAT, ' +
             ' SF.KUR, S.IZLEME, TIPI, StokMarka.ANAHTAR STOKMARKA, StokModel.ANAHTAR STOKMODEL '+
             ' From STOKLAR S (nolock) left outer join STOKFIYAT SF on S.ID=SF.STOKID and FIYATADI=' + FiyatAdTut +' '+
             ' LEFT OUTER JOIN GENINI StokMarka ON  StokMarka.DEGER = CONVERT(VARCHAR(10),S.MARKA) AND StokMarka.BOLUM ='+inttostr(Ops_StokKart_Marka)+' '+
             ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,'+inttostr(Ops_StokKart_Marka)+'+convert(varchar(10),S.MARKA)) '+
             ' where S.DURUM=1 and (SF.BIRIM='+vartostr(comboBirim.EditValue)+') ';
          StokSorguTamamla;
        end;
      1, 4: //çýkýþ fat ve transfer
        begin // seçili depodaki stoklar gelecek
          QueryIslem.SQL.Text := ' Select distinct ' + TopAramaSayi + ' S.ID as URUNID, S.KOD, STOKADI AS AD, ' +
            ' cast(''STOK'' as varchar(5)) AS TUR, ISNULL(SD.SKT,''1900-01-01'') AS SKT, ' +
            ' isnull(SD.KALAN,0) AS ADET,ANABIRIM, BIRIM2, isnull(MINSTOK,0) as MINSTOK,MASRAFID,KDV, FIYAT=isnull(SF.FIYAT,0), ' +
            ' KUR=isnull(SF.KUR,'''+CariDoviz+'''), S.IZLEME, TIPI ,StokMarka.ANAHTAR STOKMARKA, StokModel.ANAHTAR STOKMODEL'+
            ' From STOKLAR S (nolock) LEFT OUTER JOIN STOKFIYAT SF (nolock) on S.ID = SF.STOKID ' +
            ' LEFT OUTER JOIN STOKDURUM SD ON SD.STOKID = S.ID '+
            ' LEFT OUTER JOIN GENINI StokMarka ON  StokMarka.DEGER = CONVERT(VARCHAR(10),S.MARKA) AND StokMarka.BOLUM ='+inttostr(Ops_StokKart_Marka)+' '+
            ' LEFT OUTER JOIN GENINI StokModel ON StokModel.DEGER = S.MODEL AND StokModel.BOLUM=convert(int,'+inttostr(Ops_StokKart_Marka)+'+convert(varchar(10),S.MARKA)) '+
            ' where S.DURUM=1 and SF.BIRIM='+vartostr(comboBirim.EditValue)+' ' +
            ' AND SD.DEPOID = ' + inttostr(cbStokDepo.EditValue) + ' ' + ' AND FIYATADI = ' + FiyatAdTut +' '+
            '  ';
          if StokDurumKontrolKurali=0 then  //stok eksiye düþmesine izin yoksa stokdurumu 0 olanlar listeye gelmesin.
           QueryIslem.SQL.Add(' AND isnull(SD.KALAN,0) > 0 ');
          StokSorguTamamla;
        end;
      7 : //iade fiþi ise
        begin
           QueryIslem.Close;
           QueryIslem.SQL.Text:= MemoIadeUrunAra.Text;
           if RadioButton1.Checked then
             TabloYenile(QueryIslem,[TabFatBaslik.FieldByName('REHBERID').AsInteger,AraKod.Text+'%',AraStokAdi.Text+'%', AraBarkod.Text])
           else
             TabloYenile(QueryIslem,[TabFatBaslik.FieldByName('REHBERID').AsInteger,'%'+AraKod.Text+'%','%'+AraStokAdi.Text+'%', AraBarkod.Text])
        end;
    end;
  end;
end;

procedure THizmetAraDlg.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 38 then
    QueryIslem.Prior
  else if Key = 40 then
    QueryIslem.next
    // else if (Key = 13)or(Key = 9)or((Tedit(Sender).Name='AraStokAdi')and(length(AraStokAdi.Text)<3)) then exit
  else
    AraBul('HIZMETLER', 'KOD', 'HIZMETADI', 'GRUP');
end;

procedure THizmetAraDlg.cbFiyatAdiPropertiesEditValueChanged(Sender: TObject);
begin
    FiyatAdTut:= cbFiyatAdi.EditValue;
    AraBul('HIZMETLER', 'KOD', 'HIZMETADI', 'GRUP');
end;

procedure THizmetAraDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
   if cxDBTreeList1.Selections[0].HasChildren=False then
      SecTus.Click;
end;

procedure THizmetAraDlg.cxPageControl1Change(Sender: TObject);
var K : Word;
begin
   case cxPageControl1.ActivePageIndex of
     0 : if not TabMasrafListe.Active then
           AraKodKeyUp(Self, K, []);
     1 : begin
          if (cbStokDepo.EditValue = null)and(TcxImageComboBoxProperties(cbStokDepo.Properties).Items.Count>0) then
             cbStokDepo.ItemIndex := 0;
          if not QueryIslem.Active then
             AraKodKeyUp(Self, K, []);
         end;
   end;
end;

procedure THizmetAraDlg.YeniStokTusClick(Sender: TObject);
begin
  Tablo.StokSihirbazBaslat('E', 1, -1,-1,0);
end;

procedure THizmetAraDlg.SecTusClick(Sender: TObject);
var
  s: String[15];
  SKT, Fiyat: Variant;
  urunid: integer;
  TabEkle : TFDQuery;
procedure StokCikisIslemi;
var
  stokbirimmiktar : Double;
  begin
    stokbirimmiktar := Tablo.StokCarpan(QueryIslem.FieldByName('URUNID').AsInteger, comboBirim.EditValue) * strtoint(Adet.Text);
    // Stokta yeterli ürün var mý
    if QueryIslem.FieldByName('ADET').AsFloat < stokbirimmiktar then
    begin
      if not (Tablo.StokCikisYapilabilirmi(stokbirimmiktar,QueryIslem.FieldByName('ADET').AsFloat)) then
       begin
        TabFatura.Cancel;
        if AraBarkod.Text<>'' then
         AraBarkod.Text:='';
        abort;
       end;
    end;
    TabFatura.FieldByName('SKT').Value := QueryIslem.FieldByName('SKT').Value;
  end;
procedure StokGirisIslemi;
  begin
    if cbStokDepo.EditValue>=1 then begin
      if QueryIslem.FieldByName('IZLEME').AsInteger = 2 then // skt takibi
        if TGirisKutusuEx.BilgiAlEx(QueryIslem.FieldByName('AD').AsString + ' için SKT Bilgisi', TGirdiDenetimleri.Create.DateTimePicker('SKT Giriniz', @SKT)) <> mrOk then
          Abort
        else
          TabFatura.FieldByName('SKT').Value := SKT;
    end;
  end;
function UrunVarsaArttir : Boolean;
  begin
    Result:=False;
    //Eðer daha önce girilmiþse onun sayýsýný artýralým
    if (cxPageControl1.ActivePage= shtStokAra) and   (HizmetAraCagiran in [1,2,4]) then begin //(not (TabFatBaslik.FieldByName('TUR').AsInteger in [10,11,12])) then  //stok çýkýþý ise skt dahil olacak
      // stok çýkýþý yapýlýyorsa skt ye göre ve birime göre de arasýn
      if TabFatura.Locate('KOD;SKT;BIRIM',VarArrayOf([TabEkle.FieldByName('KOD').AsString,TabEkle.FieldByName('SKT').AsDateTime,comboBirim.Properties.Items[comboBirim.ItemIndex].Value]),[]) then begin
        Result:=True;
        TabFatura.Edit;
        TabFatura.FieldByName('ADET').AsFloat := TabFatura.FieldByName('ADET').AsFloat + StrToFloat(Adet.Text);
        TabFatura.Post;
      end
    end else begin
      if TabFatura.Locate('KOD;BIRIM',VarArrayOf([TabEkle.FieldByName('KOD').AsString,comboBirim.Properties.Items[comboBirim.ItemIndex].Value]),[]) then begin
        Result:=True;
        TabFatura.Edit;
        TabFatura.FieldByName('ADET').AsFloat := TabFatura.FieldByName('ADET').AsFloat + StrToFloat(Adet.Text);
        TabFatura.Post;
      end
    end;
  end;
begin
//   HizmetAraCagiran 0 : giren fat, 1 çýkýþ fatura 2: sayým tutanaðý 3 : demirbaþ 4:transfer  5:teklif  6:servis
//  7 : iade fiþ
  if HizmetAraCagiran = 2 then
 {$REGION 'SAYIMTUTANAK KONTROLLERÝ'}
  begin // sayým tutanaðý ekranýndan çaðrýldýysa
    if QueryIslem.FieldByName('IZLEME').AsInteger = 2 then // skt takibi
      if TGirisKutusuEx.BilgiAlEx(QueryIslem.FieldByName('AD').AsString + ' için SKT Bilgisi', TGirdiDenetimleri.Create.DateTimePicker('SKT Giriniz', @SKT)) <> mrOk then
        Abort;


    TabFatura.Append;
    TabFatura.FieldByName('STOKID').AsInteger := QueryIslem.FieldByName('URUNID').AsInteger;
    TabFatura.FieldByName('SAYIMMIKTAR').AsFloat := StrToFloat(Adet.Text);
    TabFatura.FieldByName('IZLEME').AsInteger:= QueryIslem.FieldByName('IZLEME').AsInteger;
    if SKT > 0 then
      TabFatura.FieldByName('SKT').Value := SKT;

    TabFatura.Post;

  end
{$ENDREGION}
  else begin
     if cxPageControl1.ActivePage = shtHizmetAra then begin
        if cxDBTreeList1.Selections[0].HasChildren=True then
           raise Exception.Create('Baþlýk deðil detay iþlem seçmelisiniz!');
        TabEkle := TabMasrafListe;
     end else
        TabEkle := QueryIslem;
     if TabEkle.RecordCount < 1 then // 0 veya 1 ise fatura ekranýndan çaðrýlmýþ
        raise Exception.Create('Önce girilecek hizmet veya ürünü seçin!');
     if (HizmetAraCagiran in [1,2,3,4])and(cxPageControl1.ActivePageIndex = 1)and(cbStokDepo.Text = '') then
        raise Exception.Create('Depoyu seçin!');

   {$REGION 'ÝadeFiþi Kontrolü'}
     if HizmetAraCagiran = 7 then
      begin
        if  StrToFloat(Adet.Text)*Tablo.StokCarpan(QueryIslem.FieldByName('URUNID').AsInteger, comboBirim.EditValue ) > QueryIslem.FieldByName('ADET').AsFloat  then
          begin
            Application.MessageBox('Geri Almak istediðiniz ürün miktarý çýkýlan miktardan fazla olamaz','U Y A R I',MB_OK+ MB_ICONWARNING);
            Abort;
          end;
      end;
   {$ENDREGION}
     if not( UrunVarsaArttir ) then begin
        TabFatura.Append;
        TabFatura.FieldByName('URUNID').AsInteger := TabEkle.FieldByName('URUNID').AsInteger;
        TabFatura.FieldByName('KOD').AsString := TabEkle.FieldByName('KOD').AsString;
        TabFatura.FieldByName('AD').AsString := TabEkle.FieldByName('AD').AsString;
        if comboBirim.EditValue <> null then
          TabFatura.FieldByName('BIRIM').AsInteger := comboBirim.EditValue
        else
          TabFatura.FieldByName('BIRIM').AsInteger := 0;
        //miktar hesaplamasý için tür ve birim bilgisi mutlaka adetten önce atanmalý
        if cxPageControl1.ActivePage= shtStokAra then begin
           TabFatura.FieldByName('TUR').AsInteger := 1;//Stok iþlemleri için tür 1 olmalý //TabEkle.FieldByName('TIPI').AsInteger;        // türün stok olduðunu belirtiyor
           if (comboBirim.EditValue<>TabEkle.FieldByName('ANABIRIM').AsInteger) and
              (comboBirim.EditValue<>TabEkle.FieldByName('BIRIM2').AsInteger )  then begin
               Application.MessageBox('Seçmiþ olduðunuz birim bilgisi bu ürün için kullanýlamaz','H A T A', MB_OK+MB_ICONERROR);
               TabFatura.Cancel;
               Abort;
           end;
        end;
        // miktar hesaplamasý için adetten önce tür ve birim bilgisi mutlaka atanmýþ olmalý
        TabFatura.FieldByName('ADET').AsFloat := StrToFloat(Adet.Text);
        TabFatura.FieldByName('KDV').AsInteger := TabEkle.FieldByName('KDV').AsInteger;
        if (HizmetAraCagiran in [0,1]) and (cxPageControl1.ActivePage= shtStokAra)  then //giriþ çýkýþ faturalarýnda izleme alaný dolacak
          TabFatura.FieldByName('IZLEME').AsInteger:=TabEkle.FieldByName('IZLEME').AsInteger;
        if cxPageControl1.ActivePageIndex = 1 then begin
           if HizmetAraCagiran in [0,1,2,3,4,7] then begin
             ResimGetir(TabEkle.FieldByName('URUNID').AsInteger,71, TabEkle.FieldByName('URUNID').AsInteger, LogoResim);
             LogoResim.Visible := LogoResim.Picture<>nil;
             if Tur in [0, 9, 10, 11, 12] then
               StokGirisIslemi
             else
               StokCikisIslemi;
             if (HizmetAraCagiran in [0,1,2,3,4,7])and(cbStokDepo.Enabled) then begin//demekki ilk kez çýkýþ yapýlýyor; bunu kaydedelim bir daha depo adý depiþemesin
                cbStokDepo.Enabled := False;
                TabFatBaslik.Refresh;
                TabFatBaslik.Edit;
                if Tur in [0, 9, 10, 11, 12] then
                   s:='GIRISDEPO'
                else
                   s:='CIKISDEPO';
                TabFatBaslik.FieldByName(s).AsInteger := cbStokDepo.EditValue;
                TabFatBaslik.Post;
             end;
           end;
        end else begin
          TabFatura.FieldByName('MIKTAR').AsFloat := StrToFloat(Adet.Text);
        end;
        TabFatura.FieldByName('ISKONTO').AsFloat := 0;
        TabFatura.FieldByName('KDV').AsInteger := TabEkle.FieldByName('KDV').AsInteger;
        TabFatura.FieldByName('KUR').AsString:= TabEkle.FieldByName('KUR').AsString;
        if HizmetAraCagiran <>4 then
        s := TabEkle.FieldByName('FIYAT').AsString // 10 TL
        else
        s:='0';
        if ((s = '-1')or(s='') or (Tur in [9,10,11,12,13]))then begin // fiyat sorulacak
          if (TGirisKutusuEx.BilgiAlEx('Ürün Fiyatýný Giriniz('+TabEkle.FieldByName('KUR').AsString+')', TGirdiDenetimleri.Create.CurrencyEdit('Fiyatýný girin('+TabEkle.FieldByName('KUR').AsString+')', @Fiyat,Tablo.GENINI.ReadInteger(Ops_FaturaOpsiyon_OndalikDijitSayTut,2))) = mrOk) then
            s := Trim(Fiyat)
          else begin
            TabFatura.Cancel;
            Abort;
          end;
        end;
        TabFatura.FieldByName('BIRIMFIYAT').AsCurrency := StrToFloatDef(s, -1);
        TabFatura.Post;
     end;
  end;
{$REGION 'Ekraný Yenile'}
  if TabEkle<>nil then
   urunid := TabEkle.FieldByName('URUNID').AsInteger;

  AraKod.Text := '';
  AraStokAdi.Text  := '';
  AraBarkod.Text  := '';
  Adet.Text := '1';
  LabelEklenen.Caption := TabFatura.FieldByName('AD').AsString;
//  AraStokAdi.SetFocus;
  QueryIslem.Close;
  if QueryIslem.SQL.Text <> '' then begin
    QueryIslem.open;
    QueryIslem.Locate('URUNID', urunid, [loPartialKey]);
  end;
{$ENDREGION}

end;

procedure THizmetAraDlg.KapatlTusClick(Sender: TObject);
begin
  Close;
end;

procedure THizmetAraDlg.QueryIslemAfterOpen(DataSet: TDataSet);
begin
  tvStokAraListeview.ApplyBestFit(nil);
end;

procedure THizmetAraDlg.QueryIslemAfterScroll(DataSet: TDataSet);
begin
  //if cxPageControl1.ActivePageIndex = 1 then
  //  comboBirim.EditValue := QueryIslem.FieldByName('ANABIRIM').AsInteger;
end;

procedure THizmetAraDlg.RadioHizmetClick(Sender: TObject);
begin
  tvStokAraListeviewSKT.Visible := cxPageControl1.ActivePage = shtStokAra;
  tvStokAraListeviewADET.Visible := cxPageControl1.ActivePage = shtStokAra;
  tvStokAraListeviewANABIRIM.Visible := cxPageControl1.ActivePage = shtStokAra;
  tvStokAraListeviewMINSTOK.Visible := cxPageControl1.ActivePage = shtStokAra;
  AraBul('HIZMETLER', 'KOD', 'HIZMETADI', 'GRUP');
end;

procedure THizmetAraDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   GenRegIni.RegWriteString('', 'FaturaAramaTipi', IntToStr(cxPageControl1.ActivePageIndex), 'C');
end;

procedure THizmetAraDlg.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  HizmetAraCagiran := 0;
  StokKontrol := False;
  FiyatGoster := True;
  FiyatAdTut := '1';
  cbFiyatAdi.EditValue:=1;
  TopAramaSayi := ' top 100 ';
  LabelBarkod.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  AraBarkod.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  shtStokAra.TabVisible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  LabelBirim.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  comboBirim.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  LabelYer.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  cbStokDepo.Visible := Tablo.YetkiVarmi(MODUL_Stok,YetkiTur_Gorme);
  RadioHizmetClick(Self);
  cbStokDepo.Properties.Items := Tablo.imgComboboxInit('SELECT ID, DEPOADI FROM DEPOLAR WHERE DURUM=1 ORDER BY 2').Items;

  Tablo.GENINI.ReadImageSection(Ops_StokKart_Anabirim,comboBirim.Properties.Items);
  (tvStokAraListeviewANABIRIM.Properties as TcxImageComboBoxProperties).Items := comboBirim.Properties.Items;
  if comboBirim.Properties.Items.Count < 1 then
    ShowMessage('Sisteme birim tanýmý girin (Adet vb..)')
  else
    comboBirim.ItemIndex := 0;

  // StokKart_Anabirim
end;

procedure THizmetAraDlg.FormShow(Sender: TObject);
begin    //   HizmetAraCagiran 0 : giren fat, 1 çýkýþ fatura 2: sayým tutanaðý 3 : demirbaþ 4:transfer  5:teklif  6:servis
    // sayým tutanaðý ekraný veya transfer ekraný formu caðýrmýþsa hizmet aramasý yapýlmasýn
  if HizmetAraCagiran in[0,2,5] then //burqada fiyat gözükmeyecek..
    FiyatGoster:=False;
  cbFiyatAdi.Visible:= FiyatGoster;
  lbFiyatAdi.Visible:= FiyatGoster;
  tvStokAraListeviewFIYAT.Visible:= FiyatGoster;
  cxDBTreeList1cxDBTreeListColumn3.Visible:= FiyatGoster;
  if HizmetAraCagiran in [2,4] then
     shtHizmetAra.TabVisible:=False
  else begin
      shtHizmetAra.TabVisible:=True;
      if GenRegIni.RegReadString('', 'FaturaAramaTipi', '0', 'C') = '0' then
         cxPageControl1.ActivePageIndex := 0
      else
         cxPageControl1.ActivePageIndex := 1;
      cxPageControl1Change(Self);
  end;
   tvStokAraListeviewSKT.Visible:= HizmetAraCagiran in [1,2,4]; // TabFatBaslik.FieldByName('TUR').AsInteger in [10,11,12];
  AraBul('HIZMETLER', 'KOD', 'HIZMETADI', 'GRUP');
  HizmetAraDlg.Left:= Screen.Width- HizmetAraDlg.Width;
  HizmetAraDlg.Height:= Round(Screen.Height / 2);
  HizmetAraDlg.Top:= Round(Screen.Height / 2) - Round ((Screen.Height / 2) *0.20 );
end;

end.


