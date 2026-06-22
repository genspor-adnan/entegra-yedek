unit UTabDok;

//{$I genyazilim.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, UCombo, Menus, stdctrls, buttons, comctrls, ImgList, UFDCompatHelpers,
  OfficePopupMenu, cxButtons;


type
  TTabloDokum = class(TDataModule)
    Table1: TADOTable;
    DataSource2: TDataSource;
    PopupListe: TOfficePopupMenu;
    PopupSagTusMenu: TOfficePopupMenu;
    Ayarlar1: TMenuItem;
    MenuItem1: TMenuItem;
    KopyalaYeni1: TMenuItem;
    AdDegistir: TMenuItem;
    Sil1: TMenuItem;
    TabKosul3: TADOTable;
    N1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Query1: TADOQuery;
    TabDokum: TADOQuery;
    TabDokum2: TADOQuery;
    MsjKontr: TADOQuery;
    Query2: TADOQuery;
    EkAyarlar: TMenuItem;
    TabKosul: TADOQuery;
    VarsaylanYap1: TMenuItem;
    Dkmkaydet1: TMenuItem;
    DkmAlText1: TMenuItem;
    Komut: TADOQuery;
    SaveDialog1: TSaveDialog;
    QueryRapor: TADOQuery;
    ImageList1: TImageList;
    N2: TMenuItem;
    yeniDokumMenuItem: TMenuItem;
    FastRepPopUpSagTusMenu: TOfficePopupMenu;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    procedure TabDokumBeforeEdit(DataSet: TDataSet);
    procedure TabDokumBeforePost(DataSet: TDataSet);
    procedure TabDokumBeforeDelete(DataSet: TDataSet);
    procedure TabKosulBeforePost(DataSet: TDataSet);
    procedure PopupSagTusMenuPopup(Sender: TObject);
    procedure KopyalaYeni1Click(Sender: TObject);
    procedure AdDegistirClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure Ayarlar1Click(Sender: TObject);
    procedure TabloDokumCreate(Sender: TObject);
    procedure PopupListePopup(Sender: TObject);
    procedure TabKosul3BeforePost(DataSet: TDataSet);
    procedure TabKosul3BeforeInsert(DataSet: TDataSet);
    procedure TabKosul3AfterInsert(DataSet: TDataSet);
    procedure TabDokumNewRecord(DataSet: TDataSet);
    procedure TabDokumAfterPost(DataSet: TDataSet);
    procedure EkAyarlarClick(Sender: TObject);
    procedure TabKosulNewRecord(DataSet: TDataSet);
    procedure TabKosulBeforeEdit(DataSet: TDataSet);
    procedure TabKosulAfterPost(DataSet: TDataSet);
    procedure VarsaylanYap1Click(Sender: TObject);
    procedure DataSource2DataChange(Sender: TObject; Field: TField);
    procedure Dkmkaydet1Click(Sender: TObject);
    procedure DkmAlText1Click(Sender: TObject);
    procedure yeniDokumMenuItemClick(Sender: TObject);
    procedure TabKosulRecordsetCreate(DataSet: TDataSet);
    procedure TabDokumRecordsetCreate(DataSet: TDataSet);
    procedure MenuItem2Click(Sender: TObject);
    function FormAdiGetir: string;    
  private
    { Private declarations }
//    function FormAdiGetir: string;
  public
    Ini: TIni;
    EnSonSecilenDokum: TMenuItem;
    Modul, AliasAdi, KullanAdi: string[30];
    EkranYaz, YaziciYaz: TToolButton;
    procedure GenelRaporSecClick(Sender: TObject);
    procedure SQLRaporEkle(Target: TDataSet; Source, RaporAdi: string);
    procedure EkranYaziciInit(EkranYaz1, YaziciYaz1: TToolButton);
    /// <summary>
    ///   Belirtilen form adına göre EkranYaz1 ve YaziciYaz1 araç butonların ayarlar.
    ///  <param name="FormAdi">İstenilen form adı</param>
    ///  <param name="EkranYaz1">Ön izleme butonunun örneği</param>
    ///  <param name="YaziciYaz1">Yazdırma butonunun örneği</param>
    /// </summary>
    procedure EkranYaziciInitEx(FormAdi: string;EkranYaz1, YaziciYaz1: TToolButton);
    function PopUpMenuIslemleri(Menu1: TMenu; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string): TMenuItem;
    function MenuIslemleri(Menu1: TMenuItem; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; ResimNo: SmallInt): TMenuItem;
    procedure RaporSecClick(Sender: TObject);
    procedure InidenOku(Baslik: string; EkranYaz1, YaziciYaz1: TButton);
    procedure Ekran_Yazici_Islemi(Sender: TObject);
    procedure RaporTabloSec(Table1: TADOTable; DataSource1: TDataSource; Anahtar: string);
    procedure RaporTabloBagla(Table1, Table2: TADOQuery; ParSay: ShortInt; Alan: string; Tip: Char);
    function BorcRengi(Dosyano, GelisNo: string): TColor;
    procedure Tasima(Tablo, AlanAd, YeniEkranAdi: string; TabDst: TDataSet);
    procedure IniAyarla(Baslik, Islem: string);
    procedure Ekran_Yazici_IslemiEx(ARaporAdi: string;AOnIzleme: Boolean);
  end;

  TOzelYazdirmaBilgisi = class
  private
    FFormAdi: string;
  published
  public
    property FormAdi : string read FFormAdi write FFormAdi;
  end;

var
  TabloDokum: TTabloDokum;
  FSesDosya: string;
implementation

uses UAnaForm, UTablo, UMesaj, qrexpr, URapSyf, UDokum,
  FetaUtil,FetaKurulusSiniflari,FetaClassExtensions; //  UFastRap,  UAyar,
  // UAnaListe,
  //UDokSart{$IFNDEF PROJECT_INTEGRATION}{$ENDIF}
   //, Utxrapor;

{$R *.DFM}
//var
///  QuantDokum : TQuantGrid;

type
  TQREvEtiAdresFunction = class(TQREvElementFunction)
  public
    function Calculate: TQREvResult; override;
  end;

  TQREvKosulFunction = class(TQREvElementFunction)
  public
    function Calculate: TQREvResult; override;
  end;

var
  OncekiRaporAdi: string;
  i, SNo: integer;
  RaporAdi, Alan: string;
  Satir, S: string;
  FList: TStringList;
  YeniKayit: Boolean;
  // buton Tag değeri 100 olduğu zaman PopupListePopup bu değere bakar değilse Screen.ActiveForm.Name e bakar
  // Ayrıca EkranYaziciInitEx kullanılmalı
  OzelFormAdi : string;






procedure TTabloDokum.GenelRaporSecClick(Sender: TObject);
var buldu: boolean;
begin
  s := TMenuItem(Sender).Caption;
  Delete(s, pos('&', s), 1);
  EnSonSecilenDokum := TMenuItem(Sender);
  buldu := False;

  TabloDokum.TabDokum.DisableControls;
  TabloDokum.TabDokum.first;
  while (not TabloDokum.TabDokum.eof) and (not buldu) do
    if TabloDokum.TabDokum.Fields[0].AsString = s then
      buldu := True
    else
      TabloDokum.TabDokum.next;

  if DokumDlg = nil then begin
//      QuantDokum := TQuantGrid.Create(Application);
    Application.CreateForm(TDokumDlg, DokumDlg);
  end else
    DokumDlg.Show;
  if not TabloDokum.TabDokum.IsEmpty then
    DokumDlg.SartlarOlustur;
//   AnaForm.InitYeniEkranToolbar(DokumDlg.DtsDokumler, 'Liste', 'DokumDlg');
  TabloDokum.TabDokum.EnableControls;
end;

procedure TTabloDokum.RaporTabloSec(Table1: TADOTable; DataSource1: TDataSource; Anahtar: string);
begin
  Table1.MasterSource := DataSource1;
  Table1.MasterFields := Anahtar;
  Table1.IndexFieldNames := Anahtar;
  Table1.Open;
end;

procedure TTabloDokum.RaporTabloBagla(Table1, Table2: TADOQuery; ParSay: ShortInt; Alan: string; Tip: Char);
begin
  Table1.Close;
  for i := 0 to ParSay - 1 do
    Table1.Parameters[i].value := Table2.Parameters[i].value;
  if Alan <> '' then
    case Tip of
      'S': Table1.Parameters[ParSay].Value := Table2.FieldByName(Alan).AsString;
      'I': Table1.Parameters[ParSay].Value := Table2.FieldByName(Alan).AsInteger;
    end;
   //      Table1.Parameters[ParSay].Assign(Table2.FieldByName(Alan));
  Table1.Open;
end;

procedure TTabloDokum.EkranYaziciInit(EkranYaz1, YaziciYaz1: TToolButton);
var stlist: TStringList;
  s: string[50];
begin
  if (FetaUtil.ProgramTerminating) then Exit;
  EkranYaz := EkranYaz1;
  YaziciYaz := YaziciYaz1;
  while PopUpListe.Items.Count <> 0 do
    PopUpListe.Items.Delete(0);
  stlist := TStringList.Create;

  if Screen.ActiveForm = nil then
  begin
   exit;
   stlist.free;
  end;
  Ini.ReadSection(FormAdiGetir, stlist);
  if stlist.Count > 0 then begin
    EkranYaz.Style := tbsDropDown;
    YaziciYaz.Style := tbsDropDown;
    EkranYaz.DropdownMenu := TabloDokum.PopupListe;
    YaziciYaz.DropdownMenu := TabloDokum.PopupListe;
    PopupListe.OnPopUp := PopupListePopup;
  end else begin
    EkranYaz.Style := tbsButton;
    YaziciYaz.Style := tbsButton;
    EkranYaz.DropdownMenu := nil;
    YaziciYaz.DropdownMenu := nil;
  end;
  stlist.Free;
  s := Ini.ReadString(FormAdiGetir, 'VARSAYILAN', 'x');
  if s <> 'x' then EkranYaz.Caption := s;
  if s <> 'x' then YaziciYaz.Caption := s;
end;

procedure TTabloDokum.InidenOku;
var stlist: TStringList;
begin
  stlist := TStringList.Create;
  while PopUpListe.Items.Count <> 0 do
    PopUpListe.Items.Delete(0);
  Ini.ReadSection(Baslik, stlist);
  for i := 0 to stlist.count - 1 do
    if stlist.strings[i] <> 'VARSAYILAN' then
      PopUpMenuIslemleri(PopUpListe, TabloDokum.RaporSecClick, 'Ekle', stlist.strings[i], '');
  stlist.Free;
end;

procedure TTabloDokum.Ekran_Yazici_Islemi(Sender: TObject);
begin
  s := TButton(Sender).Caption + '_';
  Delete(s, pos('&', s), 1);
  if (TBitBtn(Sender).Name = 'EkranYaz') or (TBitBtn(Sender).Name = 'SevkEkran') or (TBitBtn(Sender).Name = 'SPDEsViziteEkran') or (TBitBtn(Sender).Name = 'SPDYakinViziteEkran') or (TBitBtn(Sender).Name = 'BtnBaskiOniz') then
    RapSyf.DokumYap(0, s)
  else
    RapSyf.DokumYap(1, s);
//  if AnaForm.EkranYaz.Style = tbsDropDown then
//    Ini.WriteString(FormAdiGetir, 'VARSAYILAN', EkranYaz.Caption);
end;

function TTabloDokum.PopUpMenuIslemleri(Menu1: TMenu; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string): TMenuItem;
var
  NewItem: TMenuItem;
  i: integer;
  silindi: boolean;
  bas: string[20];
begin
  if IslemTuru = 'Ekle' then begin
    NewItem := TMenuItem.Create(Menu1);
    NewItem.Caption := Baslik1;
    NewItem.OnClick := RaporSecClick;
//      c := copy(Baslik1,1,1);
//      NewItem.ShortCut := ShortCut(Word(c), [ssCtrl, ssAlt]);
    Menu1.Items.Add(NewItem);
    PopUpMenuIslemleri := NewItem;
  end
  else if IslemTuru = 'Sil' then begin
    silindi := False; i := 0;
    if Menu1.Items.Count > 0 then begin
      while (not silindi) or (i < Menu1.Items.count) do begin
        bas := Menu1.Items[i].caption;
        Delete(bas, pos('&', bas), 1);
        if bas = Baslik1 then begin
          Menu1.Items.Delete(i); //     Menu1.Items.Remove(Menu1.Items[i]);
          silindi := True;
        end;
        inc(i);
      end
    end;
  end
  else if IslemTuru = 'Degistir' then begin
    i := 0;
    while i < Menu1.Items.count do begin
      bas := Menu1.Items[i].caption;
      Delete(bas, pos('&', bas), 1);
      if bas = Baslik1 then
        Menu1.Items[i].caption := Baslik2;
      inc(i);
    end;
  end
end;

function TTabloDokum.MenuIslemleri(Menu1: TMenuItem; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; ResimNo: SmallInt): TMenuItem;
var
  NewItem: TMenuItem;
  i: integer;
  silindi: boolean;
  bas: string[25];
begin
  
  if IslemTuru = 'Ekle' then begin
//      if Trim(Grubu)<>'' then
//         NewItem := NewSubMenu(Grubu);
    if Menu1.count > 3 then
      NewItem := TMenuItem.Create(Menu1.Items[0])
    else
      NewItem := TMenuItem.Create(Menu1);
    NewItem.Caption := Baslik1;
    NewItem.ImageIndex := ResimNo;
//      NewItem.Name := 'MN' + Baslik1;
    NewItem.OnClick := RaporSecClick;
    Menu1.Add(NewItem);
    MenuIslemleri := NewItem;
  end
  else if IslemTuru = 'Sil' then begin
    silindi := False; i := 0;
    while (not silindi) or (i < Menu1.count) do begin
      bas := Menu1.Items[i].caption;
      Delete(bas, pos('&', bas), 1);
      if bas = Baslik1 then begin
        Menu1.Delete(i); //Menu1.Remove(Menu1.Items[i]);
        silindi := True;
      end;
      inc(i);
    end
  end
  else if IslemTuru = 'Degistir' then begin
    i := 0;
    while i < Menu1.count do begin
      if Menu1.Items[i].caption = Baslik1 then
        Menu1.Items[i].caption := Baslik2;
      inc(i);
    end;
  end
end;

procedure TTabloDokum.MenuItem2Click(Sender: TObject);
begin

    s := TcxButton(FastRepPopUpSagTusMenu.PopupComponent).Caption ;

    Delete(s, pos('&', s), 1);
//    FastRaporDlg.frxReport1.DataSets.Clear;

{   if not AnaListe.RaporSorgusu.Active then
    AnaListe.RaporSorgusu.Open;

    FastRaporDlg.frxReport1.DataSets.Add(AnaListe.frxRaporSorgusu);
    FastRaporDlg.FastRaporDesign(AnaListe.shtIsListesi.Name,s);
}

end;

procedure TTabloDokum.TabDokumNewRecord(DataSet: TDataSet);
begin
  TabDokum.FieldByName('MODUL').AsString := Modul;
  Yenikayit := True;
end;

procedure TTabloDokum.TabDokumRecordsetCreate(DataSet: TDataSet);
begin
  // ADO Recordset ayari FireDAC tarafinda kullanilmiyor.
end;

procedure TTabloDokum.TabDokumBeforeEdit(DataSet: TDataSet);
begin
  Yenikayit := False;
  OncekiRaporAdi := TabDokum.FieldByName('RAPORADI').AsString;
end;

procedure TTabloDokum.TabDokumBeforePost(DataSet: TDataSet);
begin
  if TabDokum.FieldByName('RAPORADI').AsString = '' then
    raise Exception.Create('Rapor Adı Dolu Olmalı!');
  if assigned(DokumSartDlg) then
    TabDokum.fieldbyname('SQL').AsString := DokumSartDlg.SQLMemo.Text;
end;

procedure TTabloDokum.TabDokumAfterPost(DataSet: TDataSet);
var //buldu : boolean;
  Bookmark: TBookmark;
begin
  if Yenikayit then begin
    MenuIslemleri(AnaForm.GenelDokumler, RaporSecClick, 'Ekle', TabDokum.FieldByName('RAPORADI').AsString, '', -1);
    Bookmark := TabDokum.GetBookmark;
    TabDokum.Close;
    TabDokum.Open;
    TabDokum.GotoBookmark(Bookmark);
    TabDokum.FreeBookmark(Bookmark);
  end else
    if OncekiRaporAdi <> TabDokum.FieldByName('RAPORADI').AsString then begin
      TabloDokum.MenuIslemleri(AnaForm.GenelDokumler, RaporSecClick, 'Degistir', OncekiRaporAdi, TabDokum.FieldByName('RAPORADI').AsString, -1);
      Query1.Close;
      Query1.SQL.Text := 'Update KOSULLAR  Set RAPORADI = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''' +
        ' Where RAPORADI = ''' + OncekiRaporAdi + '''';
      Query1.ExecSQL;
      DokumDlg.DtsDokumlerDataChange(Self, TabKosul.Fields[0]);

      Query1.Close;
      Query1.SQL.Text := 'Update AYARLAR  Set RAPORADI = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''' +
        ' Where RAPORADI = ''' + OncekiRaporAdi + '''';
      Query1.ExecSQL;

      Query1.Close;
      Query1.SQL.Text := 'Update KULHAR Set EKRAN = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''' +
        ' Where EKRAN = ''' + OncekiRaporAdi + '''';
      Query1.ExecSQL;
    end;
end;

procedure TTabloDokum.TabDokumBeforeDelete(DataSet: TDataSet);
begin
  Query1.Close;
  Query1.SQL.Text := 'Select RAPORADI From KOSULLAR where RAPORADI = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''';
  Query1.Open;
  if not Query1.IsEmpty then
    raise exception.Create('Önce Koşulları Silmelisiniz...');
  Query1.Close;
  Query1.SQL.Text := 'Delete From AYARLAR where RAPORADI = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''';
  Query1.ExecSQL;
  Query1.Close;
  Query1.SQL.Text := 'Delete from KULHAR Where EKRAN = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''';
  Query1.ExecSQL;

//   TabloDokum.MenuIslemleri(AnaForm.GenelDokumler, RaporSecClick, 'Sil', TabDokum.FieldByName('RAPORADI').AsString, '');
end;

procedure TTabloDokum.TabKosulNewRecord(DataSet: TDataSet);
begin
  YeniKayit := True;
  TabKosul.Fields[0].AsString := TabDokum.Fields[0].AsString;
  Query1.Close;
  Query1.SQL.Text := 'Select MAX(SIRANO) from KOSULLAR WHERE RAPORADI = ''' + TabDokum.FieldByName('RAPORADI').AsString + '''';
  Query1.Open;
  if Query1.FieldS[0].AsString = '' then
    TabKosul.Fields[1].AsInteger := 1
  else
    TabKosul.Fields[1].AsInteger := Query1.FieldS[0].AsInteger + 1;
end;

procedure TTabloDokum.TabKosulRecordsetCreate(DataSet: TDataSet);
begin
  // ADO Recordset ayari FireDAC tarafinda kullanilmiyor.
end;

procedure TTabloDokum.TabKosulBeforePost(DataSet: TDataSet);
begin
  if (TabKosul.FieldByName('BAGLAC').AsString = '') or
    (TabKosul.FieldByName('TABLO').AsString = '') or
    (TabKosul.FieldByName('ALAN').AsString = '') or
    (TabKosul.FieldByName('ESITLIK').AsString = '') then
    raise Exception.Create('BAGLAC, TABLO, ALAN, ESITLIK Dolu Olmalı!');
end;

procedure TTabloDokum.PopupSagTusMenuPopup(Sender: TObject);
var s: string[30];
begin
  if Modul = 'K' then s := 'Genotip-Ayarlar'
  else if Modul = 'M' then s := 'Mua-Ayarlar'
  else if Modul = 'L' then s := 'Lab-Ayarlar'
  else if Modul = 'R' then s := 'Ran-Ayarlar'
  else if Modul = 'G' then s := 'Rad-Ayarlar';

{$IFNDEF YENIKULLANICIBILGIKONTROLU}

if (Tablo.KullaniciBilgisi(KullanAdi, s)) and
 (not (Tablo.TabKulHar.FieldByName('GORME').AsString = '1')) then
{$ELSE}
  if (Tablo.KullaniciBilgisi(KullanAdi, s)) and  (not (KullaniciBilgi.Gorme[''] = '1')) then
{$ENDIF}
    raise exception.Create('Ayarları değiştirmeye yetkili değilsiniz!!');
  s := EkranYaz.Caption;
   Delete(s, pos('&', s), 1);
  if FormAdiGetir = 'DokumDlg' then begin
    if s = 'Etiket' then
      s := 'Etiket_'
    else
      s := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString
  end
  else //TToolButton((TPopUpMenu
    s := TButton(PopupSagTusMenu.PopupComponent).Caption;
  PopupSagTusMenu.Items[0].Caption := s + ' Döküm Ayarları';
  PopupSagTusMenu.Items[1].Caption := s + ' Döküm Word Ayarları';
  PopupSagTusMenu.Items[2].Caption := s + ' Varsayılan Yap';
  PopupSagTusMenu.Items[4].Caption := s + ' Dökümünü Kopyala';
  PopupSagTusMenu.Items[5].Caption := s + ' Döküm Adını Değiştir';
  PopupSagTusMenu.Items[6].Caption := s + ' Dökümünü Sil';
//   PopupSagTusMenu.Items[7].Caption := s + ' Dökümü kaydet (Text)';
end;

procedure TTabloDokum.IniAyarla(Baslik, Islem: string);
begin
  if Islem = 'Ekle' then begin
    if Ini.ReadString(FormAdiGetir, Baslik, '_x_') = '_x_' then
      Ini.WriteString(FormAdiGetir, Baslik, '');
  end
  else if Islem = 'Sil' then begin
    Ini.DeleteKey(FormAdiGetir, Baslik)
  end
end;

procedure TTabloDokum.Tasima(Tablo, AlanAd, YeniEkranAdi: string; TabDst: TDataSet);
begin
  TabDokum2.Close;
  TabDokum2.SQL.Text := 'Select * From ' + Tablo + ' Where RAPORADI = ''' + AlanAd + '''';
  TabDokum2.Open;
  TabDokum2.first;
  while not TabDokum2.eof do begin
    TabDst.Insert;
    TabDst.Fields[0].ASString := YeniEkranAdi;
    for i := 1 to TabDst.Fields.Count - 1 do
      TabDst.Fields[i].AsString := TabDokum2.Fields[i].AsString;
    TabDst.Post;
    TabDokum2.Next;
  end;
end;

procedure TTabloDokum.KopyalaYeni1Click(Sender: TObject);
var YeniEkranAdi, EskiEkranAdi: string;
begin
  s := EkranYaz.Caption;
  Delete(s, pos('&', s), 1);
  YeniEkranAdi := s;
  MesajStrAl('', 'Yeni Döküm Adını Giriniz :', 'E', nil, YeniEkranAdi, '', 'E', nil, YeniEkranAdi);
  if YeniEkranAdi = '' then exit;

  if FormAdiGetir = 'DokumDlg' then begin
    TabDokum2.Close;
    TabDokum2.SQL.Text := 'Select * From DOKUMLER Where RAPORADI = ''' + YeniEkranAdi + '''';
    TabDokum2.Open;
    if not TabloDokum.TabDokum2.IsEmpty then
      raise Exception.Create('Bu adla kayıtlı döküm var!!!');
    EskiEkranAdi := TabDokum.FieldByName('RAPORADI').ASString;
    Tasima('DOKUMLER', EskiEkranAdi, YeniEkranAdi, TabDokum);
    TabDokum.Close; TabDokum.Open;
    RapTablo.Kosullar.Open;
    Tasima('KOSULLAR', EskiEkranAdi, YeniEkranAdi, RapTablo.Kosullar);

    RapTablo.Ayarlar.Close;
    RapTablo.Ayarlar.SQL.Text := 'Select * from Ayarlar Where RAPORADI = ''' + YeniEkranAdi + ''' ORDER BY SIRANO';
    RapTablo.Ayarlar.Open;
    Tasima('AYARLAR', EskiEkranAdi, YeniEkranAdi, RapTablo.Ayarlar);
    MenuIslemleri(AnaForm.GenelDokumler, RaporSecClick, 'Ekle', YeniEkranAdi, '', -1);
  end else begin
    IniAyarla(YeniEkranAdi, 'Ekle');
      //IniAyarla(s, 'Sil');
    YeniEkranAdi := YeniEkranAdi + '_';
    RapTablo.Ayarlar.Close;
    RapTablo.Ayarlar.SQL.Text := 'Select * from Ayarlar Where RAPORADI = ''' + YeniEkranAdi + ''' ORDER BY SIRANO';
    RapTablo.Ayarlar.Open;
    Tasima('AYARLAR', s + '_', YeniEkranAdi, RapTablo.Ayarlar);
    YeniEkranAdi := copy(YeniEkranAdi, 1, length(YeniEkranAdi) - 1);
    if EkranYaz.Style = tbsButton then
      TabloDokum.PopUpMenuIslemleri(PopupListe, RaporSecClick, 'Ekle', s, '');
    TabloDokum.PopUpMenuIslemleri(PopupListe, RaporSecClick, 'Ekle', YeniEkranAdi, '');
    EkranYaziciInit(EkranYaz, YaziciYaz);
  end;
  MessageDlg('Döküm başarıyla kopyalandı',mtInformation,[mbOK],0);
end;

procedure TTabloDokum.AdDegistirClick(Sender: TObject);
var YeniEkranAdi: string;
begin
  s := EkranYaz.Caption;
  Delete(s, pos('&', s), 1);
  YeniEkranAdi := s;
  MesajStrAl('', 'Yeni Döküm Adını Giriniz :', 'E', nil, YeniEkranAdi, '', 'E', nil, YeniEkranAdi);
  if YeniEkranAdi = '' then exit;

  if FormAdiGetir = 'DokumDlg' then begin
    TabloDokum.TabDokum.Edit;
    TabloDokum.TabDokum.FieldByName('RAPORADI').ASString := YeniEkranAdi;
    TabloDokum.TabDokum.Post;
  end else begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Update Ayarlar  Set RAPORADI = ''' + YeniEkranAdi + '_''' +
      ' Where RAPORADI = ''' + s + '_''';
    Tablo.Query1.ExecSQL;

    TabloDokum.PopUpMenuIslemleri(PopupListe, RaporSecClick, 'Degistir', s, YeniEkranAdi);
    EkranYaz.Caption := YeniEkranAdi;
    YaziciYaz.Caption := YeniEkranAdi;
    IniAyarla(YeniEkranAdi, 'Ekle');
    IniAyarla(s, 'Sil');
  end;
  //ShowMessage('İşlem Sona Erdi....');
end;

procedure TTabloDokum.Sil1Click(Sender: TObject);
begin
  if MessageDlg(EkranYaz.Caption + ' Dökümünü silmek istediğinizden emin misiniz?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYES then exit;

  if FormAdiGetir = 'DokumDlg' then
    TabloDokum.TabDokum.delete
  else begin
    s := EkranYaz.Caption;
    Delete(s, pos('&', s), 1);
    IniAyarla(s, 'Sil');
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := 'Delete From AYARLAR where RAPORADI=''' + s + '_''';
    Tablo.Query5.ExecSQL;
    TabloDokum.PopUpMenuIslemleri(PopupListe, RaporSecClick, 'Sil', s, '');
    if PopupListe.Items.Count > 0 then
      RaporSecClick(PopupListe.Items[0]);
    EkranYaziciInit(EkranYaz, YaziciYaz);
  end;
  ShowMessage('İşlem Sona Erdi....');
end;

procedure TTabloDokum.Ayarlar1Click(Sender: TObject);
var s: string[25];
begin
  if PopupSagTusMenu.PopupComponent is TToolButton then
    s := TToolButton(PopupSagTusMenu.PopupComponent).Caption
  else
    s := AnaForm.EkranYaz.Caption;
  Delete(s, pos('&', s), 1);
  if (FormAdiGetir = 'DokumDlg') and (s = 'Liste') then begin //TButton(PopupSagTusMenu.PopupComponent).Caption
    s := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString;
    Delete(s, pos('&', s), 1);
    RapTablo.Ayarlar.Close;
    RapTablo.Ayarlar.SQL.Text := 'select * from AYARLAR where RAPORADI =''' + s + '''';
    RapTablo.Ayarlar.Open;
    if RapTablo.Ayarlar.IsEmpty then
      if MessageDlg('Döküm ayarları bulunamadı. Oluşturulsun mu?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYES then
        DokumDlg.IlkSayfaYapisiOlustur
  end
  else
    s := TButton(PopupSagTusMenu.PopupComponent).Caption + '_';
  Delete(s, pos('&', s), 1);
  if PopupSagTusMenu.PopupComponent is TToolButton then
    AyarlarDlgEkran(s,TToolButton(PopupSagTusMenu.PopupComponent))
  else
    AyarlarDlgEkran(s,Anaform.EkranYaz);    
end;

procedure TTabloDokum.RaporSecClick(Sender: TObject);
begin
  EkranYaz.Caption := TMenuItem(Sender).Caption;
  YaziciYaz.Caption := TMenuItem(Sender).Caption;
{  aaa := TMenuItem(Sender).GetParentComponent;
   aaa := aaa.GetParentComponent;
   if TButton(PopupListe.PopupComponent).Name = 'YaziciYaz' then
       YaziciYaz.Click
   else
       EkranYaz.Click;}
end;

//***************

function TQREvEtiAdresFunction.Calculate: TQREvResult;
  procedure SyeIlave(st: string; Tur: char);
  begin
    case Tur of
      'A': if TabloDokum.Query1.FieldByName(st).AsString <> '' then
          S := S + TabloDokum.Query1.FieldByName(st).AsString;
      'B': S := S + st;
    end;
  end;
//Ana Program
begin
  Result.Kind := resError;
  if ArgList.Count = 1 then begin
    RaporAdi := Argument(0).StrResult;
    TabloDokum.TabDokum2.Close;
    TabloDokum.TabDokum2.SQL.Text := 'Select * From DOKUMLER Where RAPORADI = ''' + RaporAdi + '''';
    TabloDokum.TabDokum2.Open;
    FList := TStringList.Create;
    FList.Assign(TabloDokum.TabDokum2.FieldByName('ETIKETLIST'));
    S := '';
    for i := 0 to FList.Count - 1 do begin
      Satir := FList[i];
      while pos('{', Satir) > 0 do begin
        Alan := Copy(Satir, 1, Pos('{', Satir) - 1);
        Delete(Satir, 1, Pos('{', Satir));
        SyeIlave(Alan, 'B');
        Alan := Copy(Satir, 1, Pos('}', Satir) - 1);
        Delete(Satir, 1, Pos('}', Satir));
        SyeIlave(Alan, 'A');
      end;
      SyeIlave(Satir, 'B');
      S := S + ''#$D#$A;
    end;
//      while pos(''#$D#$D#$A,S) > 0 do
//         delete(S, pos(''#$D#$D#$A,S), 2);
    FList.Free;
    Result.StrResult := S;
    Result.Kind := resString;
  end;
end;

function TQREvKosulFunction.Calculate: TQREvResult;
var KosulNo: integer;
begin
  Result.Kind := resError;
  if ArgList.Count = 1 then begin
    KosulNo := Argument(0).IntResult;
    TabloDokum.TabKosul.First;
    for i := 1 to KosulNo - 1 do
      TabloDokum.TabKosul.next;
    Result.StrResult := TabloDokum.TabKosul.FieldByName('DEGER').AsString;
    Result.Kind := resString;
  end;
end;

procedure TTabloDokum.TabloDokumCreate(Sender: TObject);
begin
  //THOUSANDSEPARATOR := ',';
  //DECIMALSEPARATOR  := '.';
  //DATESEPARATOR  := '/';

  if TabloDokum.AliasAdi = '' then
    TabloDokum.AliasAdi := 'GENOTIP';
  EnSonSecilenDokum := nil;
  RegisterQRFunction(TQREvEtiAdresFunction, 'EtiAdres', 'EtiAdres(RAPORADI)|' + 'Kart Adrese Göre Adres Dönderir', 'FETA Bilgisayar', '7NNNNN');
  RegisterQRFunction(TQREvKosulFunction, 'Kosul', 'Kosul(KosulNo)|' + 'Kart Adrese Göre Adres Dönderir', 'FETA Bilgisayar', '7NNNNN');
end;

procedure TTabloDokum.PopupListePopup(Sender: TObject);
var stlist: TStringList;
  item: TMenuItem;
begin
  if EkranYaz.Style = tbsButton then exit;

  while PopUpListe.Items.Count <> 0 do
    PopUpListe.Items.Delete(0);
  stlist := TStringList.Create;

  Ini.ReadSection(FormAdiGetir, stlist);
  if stlist.count > 0 then
    for i := 0 to stlist.count - 1 do
      if stlist.strings[i] <> 'VARSAYILAN' then begin
        item := PopUpMenuIslemleri(PopUpListe, TabloDokum.RaporSecClick, 'Ekle', stlist.strings[i], '');
        item.Hint := 'Kullanıcı Tanımlı Belge';
        item.ImageIndex := 9;
      end;
  stlist.Free;
end;

procedure TTabloDokum.TabKosul3BeforePost(DataSet: TDataSet);
begin
  if (TabKosul3.FieldByName('BAGLAC').AsString = '') or
    (TabKosul3.FieldByName('TABLO').AsString = '') or
    (TabKosul3.FieldByName('ALAN').AsString = '') or
    (TabKosul3.FieldByName('ESITLIK').AsString = '') then
    raise Exception.Create('BAGLAC, TABLO, ALAN, ESITLIK Dolu Olmalı!');
end;

procedure TTabloDokum.TabKosul3BeforeInsert(DataSet: TDataSet);
begin
  TabKosul3.Last;
  if TabKosul3.IsEmpty then
    SNo := 1
  else
    SNo := TabKosul3.FieldByName('SIRANO').AsInteger + 1;
end;

procedure TTabloDokum.TabKosul3AfterInsert(DataSet: TDataSet);
begin
  TabKosul3.FieldByName('RAPORADI').AsString := 'Hasta Cari_';
  TabKosul3.FieldByName('SIRANO').AsInteger := SNo;
end;

procedure TTabloDokum.SQLRaporEkle(Target: TDataSet; Source, RaporAdi: string);
begin
  TabloDokum.Query1.Close;
  TabloDokum.Query1.SQL.Text := ' Select * from ' + Source +
    ' Where RAPORADI = ''' + RaporAdi + '''';
  TabloDokum.Query1.Open;
  TabloDokum.Query1.first;
  while not TabloDokum.Query1.eof do begin
    Target.Append;
    for i := 0 to TabloDokum.Query1.Fields.Count - 1 do
      Target.Fields[i].AsVariant := TabloDokum.Query1.Fields[i].AsVariant;
    try
      if Source = 'DOKUMLER' then
        Target.FieldByName('MODUL').AsString := TabloDokum.Modul;
      Target.Post;
    except
      on e: Exception do ShowMessage(e.Message);
    end;
    TabloDokum.Query1.next;
  end;
end;

procedure TTabloDokum.EkAyarlarClick(Sender: TObject);
var s: string[25];
begin
  if PopupSagTusMenu.PopupComponent is TToolButton then
    AyarlarDlgEkran(s,TToolButton(PopupSagTusMenu.PopupComponent))
  else
    AyarlarDlgEkran(s,Anaform.EkranYaz);
{   AktifEkran := AnaForm.ActiveMDIChild.Name;
   TxRapor.TXTextControl1.Text:='';
   s := AnaForm.EkranYaz.Caption;
   Delete(s, pos('&',s), 1);
   TxRapor.RaporAdi:= s;
   TxRapor.WindowState := wsMaximized;
   TxRapor.Tagi := 3;
   TxRapor.TxRaporInit;
   TxRapor.Show;}
end;

procedure TTabloDokum.TabKosulBeforeEdit(DataSet: TDataSet);
var bm: TBookmark;
begin
  YeniKayit := False;
  //bm := DataSet.GetBookmark;
  //DataSet.Refresh;
  //DataSet.GotoBookmark(bm);
end;

procedure TTabloDokum.TabKosulAfterPost(DataSet: TDataSet);
begin
  if YeniKayit then begin
    TabKosul.Close;
    TabKosul.Open;
  end;
end;

procedure TTabloDokum.VarsaylanYap1Click(Sender: TObject);
begin
//  if Assigned(TetkikDlg) then begin
//    if TetkikDlg.Showing then
//      S:=TetkikDlg.EkranYaz.Caption;
//      end
//  else
  s := AnaForm.EkranYaz.Caption;
  Delete(s, pos('&', s), 1);
  Ini.WriteString(FormAdiGetir, 'VARSAYILAN', s);
end;

function TTabloDokum.BorcRengi(Dosyano, GelisNo: string): TColor;
begin
  BorcRengi := $00C8D7AA;

  Query2.Close;
  Query2.SQL.Text := 'Select TEDAVI From GELISLER WHERE DOSYANO = ''' + Dosyano + '''' +
    ' AND GELISNO = ' + GelisNo;
  Query2.Open;

  if Query2.Fields[0].AsString = 'Yatarak' then begin
    BorcRengi := $00DFD99F;
    exit;
  end;

  Query2.Close;
  Query2.SQL.Text := 'Select GELISNO, TARIH, TUR, TAHSIL, VADE From TAHSILAT Where DOSYANO = ''' + Dosyano + '''' +
    ' and GELISNO = ' + GelisNo;
  Query2.Open;
  if Query2.IsEmpty then begin // Hiç tahsilat bilgisi yoksa

    BorcRengi := $008080FF;
    exit;
  end;

  Query2.Close;
  Query2.SQL.Text := 'Select GELISNO, TARIH, TUR, TAHSIL, VADE From TAHSILAT Where DOSYANO = ''' + Dosyano + '''' +
    ' and GELISNO = ' + GelisNo +
    ' and KALAN>1 and (TUR = ''SENET'' or TUR = ''ÇEK'' or TUR = ''TAKST'' or TUR = ''AÇIK'')';
  Query2.Open;
  if not Query2.IsEmpty then begin
//    while not Query2.eof do begin
    if (Query2.Fields[4].AsString <> '') then begin
      if Query2.Fields[4].AsDateTime < Date then //vadesi dolmuşsa
        BorcRengi := $008080FF;
    end
    else begin
      BorcRengi := $008080FF;
      exit;
    end;
///       Query2.Next;
  end;
end;

procedure TTabloDokum.DataSource2DataChange(Sender: TObject; Field: TField);
begin
  DokumDlg.lbToplamSayi.Caption := '';
  if DokumDlg.ToplamSayi.Checked then
    DokumDlg.lbToplamSayi.Caption := 'Toplam kayıt sayısı : ' + INTTOSTR(TabloDokum.DataSource2.DataSet.RecordCount);
end;

procedure TTabloDokum.Dkmkaydet1Click(Sender: TObject);
begin
//   s:=TToolButton((TMenuItem(Sender).GetParentComponent)).Caption;
   //s := EkranYaz.Caption;
  s := TButton(PopupSagTusMenu.PopupComponent).Caption;
  Delete(s, pos('&', s), 1);
  DokumDlg.DokumuKaydet(s);
end;

procedure TTabloDokum.DkmAlText1Click(Sender: TObject);
var str: string;
  Memo1: TMemo;
begin
  GetDir(0, str);
  TabloDokum.OpenDialog1.InitialDir := str;
  TabloDokum.OpenDialog1.Title := 'Rapor Alma/Ekleme';
  if TabloDokum.OpenDialog1.Execute then begin
    Memo1 := TMemo.Create(Application);
    Name := 'Memo1';
    Memo1.Parent := AnaForm;
    Memo1.Lines.LoadFromFile(TabloDokum.OpenDialog1.FileName);
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := Memo1.Lines.Text;
        // Tablo.Query1.SQL.Text := StringReplace(Tablo.Query1.SQL.Text, #0,' ' ,[rfReplaceAll]);
    Tablo.Query1.ExecSQL;
    Memo1.Free;
    str := ExtractFileName(OpenDialog1.FileName);
    if pos('.', str) > 0 then
      str := copy(str, 1, pos('.', str) - 1);
    TabloDokum.PopUpMenuIslemleri(PopupListe, RaporSecClick, 'Ekle', str, '');
    IniAyarla(str, 'Ekle');
  end;
end;

procedure TTabloDokum.Ekran_Yazici_IslemiEx(ARaporAdi: string;AOnIzleme: Boolean);
begin
  s := ARaporAdi + '_';
  Delete(s, pos('&', s), 1);
  if AOnIzleme then
    RapSyf.DokumYap(0, s)
  else
    RapSyf.DokumYap(1, s);

end;

procedure TTabloDokum.EkranYaziciInitEx(FormAdi: string; EkranYaz1,
  YaziciYaz1: TToolButton);
var stlist: TStringList;
  s: string[50];
begin
  if (FetaUtil.ProgramTerminating) then Exit;
  EkranYaz := EkranYaz1;
  YaziciYaz := YaziciYaz1;
  while PopUpListe.Items.Count <> 0 do
    PopUpListe.Items.Delete(0);
  stlist := TStringList.Create;
  OzelFormAdi := FormAdi;
  if Screen.ActiveForm = nil then exit;
  Ini.ReadSection(FormAdi, stlist);
  if stlist.Count > 0 then begin
    EkranYaz.Style := tbsDropDown;
    YaziciYaz.Style := tbsDropDown;
    EkranYaz.DropdownMenu := TabloDokum.PopupListe;
    YaziciYaz.DropdownMenu := TabloDokum.PopupListe;
    PopupListe.OnPopUp := PopupListePopup;
  end else begin
    EkranYaz.Style := tbsButton;
    YaziciYaz.Style := tbsButton;
    EkranYaz.DropdownMenu := nil;
    YaziciYaz.DropdownMenu := nil;
  end;
  stlist.Free;
  s := Ini.ReadString(FormAdi, 'VARSAYILAN', 'x');
  if s <> 'x' then EkranYaz.Caption := s;
  if s <> 'x' then YaziciYaz.Caption := s;

end;

function TTabloDokum.FormAdiGetir: string;
begin
  case EkranYaz.Tag of
    100 : Result := OzelFormAdi;
    0   : Result := Screen.ActiveForm.Name;
  else
    Result := TOzelYazdirmaBilgisi(EkranYaz.Tag).FormAdi;
  end;
end;

procedure TTabloDokum.yeniDokumMenuItemClick(Sender: TObject);
var
  s : string;
begin
  MesajStrAl('', 'Yeni Dökümün Adını Girin : ', 'E', nil, s, '', 'E', nil, s);
  if s <> '' then IniAyarla(s, 'Ekle');
  EkranYaziciInit(EkranYaz,YaziciYaz);
  
end;

end.






