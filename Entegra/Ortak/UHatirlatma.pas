unit UHatirlatma;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxCalendar, cxCheckBox, ComCtrls, UFDCompatHelpers, StdCtrls,
  Mask, DBCtrls, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid,
  Grids, DBGrids, Buttons, ExtCtrls, DateUtils, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter;

type
  THatirlatmaDlg = class(TForm)
    Panel1: TPanel;
    Label5: TLabel;
    HATIRLATMA_TURU: TDBComboBox;
    sbIslemSec: TSpeedButton;
    Label6: TLabel;
    ISLEM: TDBEdit;
    Panel2: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    IlkGelis_Gun: TDBComboBox;
    IlkGelis_Periyot: TDBComboBox;
    CheckTekrar: TDBCheckBox;
    Panel3: TPanel;
    DtsCagri: TDataSource;
    TabCagri: TADOQuery;
    PanelTekrar: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    GELISSIKLIGI_SAYI: TDBComboBox;
    GELISSIKLIGI_PERIYOT: TDBComboBox;
    SEANS_SAYISI: TDBComboBox;
    Panel4: TPanel;
    Label7: TLabel;
    sbCagiranSec: TSpeedButton;
    Label11: TLabel;
    CAGIRAN_BOLUM: TDBEdit;
    CAGIRAN_DR: TDBEdit;
    DURUM: TDBComboBox;
    Panel5: TPanel;
    Label12: TLabel;
    GridCagri: TDBGrid;
    TabCagriDetay: TADOQuery;
    DtsCagriDetay: TDataSource;
    Label13: TLabel;
    cxGridCagriDetay: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGridCagriDetayDBColumn1: TcxGridDBColumn;
    cxGridCagriDetayDBColumn2: TcxGridDBColumn;
    cxGridCagriDetayDBColumn3: TcxGridDBColumn;
    ngCagriDetay: TDBNavigator;
    MonthCalendar1: TMonthCalendar;
    PanelTarih: TPanel;
    TarihTus: TSpeedButton;
    Label14: TLabel;
    ZAMAN_ASIMI: TDBComboBox;
    Label15: TLabel;
    SONLANMA_SAYI: TDBComboBox;
    SONLANMA_PERIYOT: TDBComboBox;
    sbYeni: TSpeedButton;
    sbIptal: TSpeedButton;
    sbKaydet: TSpeedButton;
    sbSil: TSpeedButton;
    sbMesajSec: TSpeedButton;
    rbSeans: TRadioButton;
    rbZamanli: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure CheckTekrarClick(Sender: TObject);
    procedure sbIslemSecClick(Sender: TObject);
    procedure sbCagiranSecClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function Gun(AnTarih: TDateTime; xsay: Integer; per: string): TDateTime;
    procedure TarihTusClick(Sender: TObject);
    procedure MonthCalendar1dbClick(Sender: TObject);
    procedure TabCagriAfterScroll(DataSet: TDataSet);
    procedure IlkGelis_GunChange(Sender: TObject);
    procedure TabCagriAfterPost(DataSet: TDataSet);
    procedure TabCagriDetayNewRecord(DataSet: TDataSet);
    procedure DtsCagriDetayStateChange(Sender: TObject);
    procedure DtsCagriStateChange(Sender: TObject);
    procedure sbMesajSecClick(Sender: TObject);
    procedure TabCagriBeforePost(DataSet: TDataSet);
    procedure TabCagriBeforeDelete(DataSet: TDataSet);
    procedure sbYeniClick(Sender: TObject);
    procedure sbSilClick(Sender: TObject);
    procedure sbKaydetClick(Sender: TObject);
    procedure sbIptalClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TabCagriDetayBeforePost(DataSet: TDataSet);
    procedure TabCagriBeforeEdit(DataSet: TDataSet);
    procedure TabCagriAfterOpen(DataSet: TDataSet);
    procedure rbSeansClick(Sender: TObject);
    procedure TabCagriNewRecord(DataSet: TDataSet);

  private
    { Private declarations }
    procedure TusBelirle;
    procedure TarihGuncelle(TarihIc: TDatetime);
    procedure Ekle(Tar: TDateTime);
    procedure Temizle(ID: integer);
    procedure SeansTarihiHesapla(HatTur: string; IlkTarih1: TDateTime; Seans, xsay: integer; per: string; SonTarih1: TDateTime; SeansMi: Boolean);
  public
    { Public declarations }
  end;

var
  HatirlatmaDlg: THatirlatmaDlg;
  HAT_KAYITNO, HAT_GSMNO, HazirMesaj: string;


implementation


uses UAraIslem, UTablo, Udoktor, UCombo, UTabDok, FetaUtil, UIslemAra,
  UHatSMSSec;
var
  IlkTarih: TDateTime;
  DrKod, DoktorListesi: string;
  YeniEklenenCagri: Boolean;


{$R *.DFM}

procedure THatirlatmaDlg.FormCreate(Sender: TObject);
begin
//  CAGIRAN_BOLUM.Text := Uzmanlik;
//  HazirMesaj := AjandaIni.ReadString('Opsiyonlar', 'SMSVarsayilanMesaj', '');
  DrKod:='';  HazirMesaj:='';
  Tablo.Query1.close;
  Tablo.Query1.SQL.Text := 'Select DEGER from AJANDAINI where BOLUM =''Opsiyonlar'' and ANAHTAR=''SMSVarsayilanMesaj'' ';
  Tablo.Query1.Open;
  HazirMesaj := Tablo.Query1.Fields[0].AsString;

  Tablo.Query1.close;
  Tablo.Query1.SQL.Text := 'Select DOKTORKOD from ' + DokListesi + ' where DOKTOR =''' + KullanAdi + '''';
  Tablo.Query1.Open;
  DrKod := Tablo.Query1.Fields[0].AsString;
  CheckTekrarClick(SeLF);
end;

procedure THatirlatmaDlg.CheckTekrarClick(Sender: TObject);
begin
  PanelTekrar.Visible := CheckTekrar.Checked;
end;

procedure THatirlatmaDlg.sbIslemSecClick(Sender: TObject);
begin
  if IslemAraDlg = nil then begin
    Application.CreateForm(TIslemAraDlg, IslemAraDlg);
  end;
  IslemAraDlg.ShowModal;
  if IslemAraDlg.ModalResult = mrOK then begin
    if not (TabCagri.State in [dsedit, dsinsert]) then
      TabCagri.Edit;
    TabCagri.FieldByName('ISLEMKODU').AsString := IslemAraDlg.TabIslem.FieldBYNAME('KOD').AsString;
    TabCagri.FieldByName('ISLEMADI').AsString := IslemAraDlg.TabIslem.FieldBYNAME('ISLEMADI').AsString;
  end;
end;

procedure THatirlatmaDlg.sbCagiranSecClick(Sender: TObject);
begin
  Application.CreateForm(TDoktorDlg, DoktorDlg);
  DoktorDlg.DBNavigator.VisibleButtons := [];
  DoktorDlg.ShowModal;
  if DoktorDlg.ModalResult <> mrOK then exit;
  if TabCagri.State = dsbrowse then
    TabCagri.Edit;
  TabCagri.FieldByName('CAGIRAN_DR').AsString := DoktorDlg.TabDoktor.Fields[0].AsString;
  TabCagri.FieldByName('CAGIRAN_BOLUM').AsString := DoktorDlg.TabDoktor.Fields[2].AsString;
  DoktorDlg.Destroy;
end;

{
Function THatirlatmaDlg.Gun(I1: Integer; s2: string): Integer;
  begin
    if pos('Hafta', s2) > 0 then Gun := I1 * 7
    else if pos('Ay', s2) > 0 then Gun := I1 * 30
    else if pos('Yýl', s2) > 0 then Gun := I1 * 365
    else Gun := I1;
  end;
}

procedure THatirlatmaDlg.FormShow(Sender: TObject);
begin
  TabCagri.Close;
  TabCagri.Parameters[0].Value := HAT_KAYITNO;
//  TabCagri.Parameters[1].Value := TabloDokum.Modul;
  TabCagri.Open;
end;

procedure THatirlatmaDlg.TarihGuncelle(TarihIc: TDatetime);
begin
  PanelTarih.Caption := FormatDateTime('dd mmm yyyy dddd', TarihIc);
end;

procedure THatirlatmaDlg.TarihTusClick(Sender: TObject);
begin
  MonthCalendar1.Date := IlkTarih;
  MonthCalendar1.Visible := not MonthCalendar1.Visible;
end;

function GunHesapla(Tarih: TDateTime): integer;
var
  trh, bgntrh: Tdatetime;
begin
  trh := STRTODATE(formatdatetime('dd/mm/yyyy', tarih));
  bgntrh := StrToDate(formatdatetime('dd/mm/yyyy', GenotipIni.BugunTrh));
  GunHesapla := round(TRH - bgntrh);
end;

procedure THatirlatmaDlg.MonthCalendar1dbClick(Sender: TObject);
begin
  MonthCalendar1.Visible := False;
  IlkTarih := MonthCalendar1.Date;
  if TabCagri.State = dsbrowse then
    TabCagri.Edit;
  TabCagri.FieldByName('ILKGELIS_GUN').AsInteger := GunHesapla(IlkTarih);
  TabCagri.FieldByName('ILKGELIS_PERIYOT').AsString := 'Gün';
  TabCagri.fieldbyname('ILKCAGRITARIHI').asdatetime := IlkTarih;
  TarihGuncelle(IlkTarih);

end;

procedure THatirlatmaDlg.TabCagriAfterScroll(DataSet: TDataSet);
begin
  TabCagriDetay.Close;
  TabCagriDetay.Parameters[0].Value := TabCagri.fieldbyname('ID').AsInteger;
  TabCagriDetay.Open;
  IlkTarih := TabCagri.fieldbyname('ILKCAGRITARIHI').asdatetime;
  rbseans.OnClick := nil;
  rbZamanli.OnClick := nil;
  rbSeans.Checked := TabCagri.FieldByName('SEANSLI').AsBoolean = true;
  rbZamanli.Checked := not TabCagri.FieldByName('SEANSLI').AsBoolean = true;
  TarihGuncelle(IlkTarih);
  TusBelirle;
  rbseans.OnClick := rbSeansClick;
  rbZamanli.OnClick := rbSeansClick;

end;

function THatirlatmaDlg.Gun(AnTarih: TDateTime; xsay: Integer; per: string): TDateTime;
begin
  if pos('Hafta', per) > 0 then Gun := IncWeek(AnTarih, xsay)
  else if pos('Ay', per) > 0 then Gun := IncMonth(AnTarih, xsay)
  else if pos('Yýl', per) > 0 then Gun := IncYear(AnTarih, xsay)
  else if pos('Gün', per) > 0 then Gun := IncDay(AnTarih, xsay);
end;

procedure THatirlatmaDlg.IlkGelis_GunChange(Sender: TObject);
var
  say: integer; periyot: string;
begin
  try
    say := strtoint(ILKGELIS_GUN.text);
  except
  end;
  if IlkGelis_Periyot.text = '' then
    TabCagri.fieldbyname('ILKGELIS_PERIYOT').AsString := 'Gün';
  //    IlkGelis_Periyot.itemindex := IlkGelis_Periyot.Items.IndexOf('Gün');
  periyot := ILKGELIS_PERIYOT.text;
  try
    IlkTarih := Gun(GenotipIni.BugunTrh, say, periyot);
    if TabCagri.State = dsBrowse then
      TabCagri.Edit;
    TabCagri.fieldbyname('ILKCAGRITARIHI').asdatetime := IlkTarih;
    TarihGuncelle(IlkTarih);
  except
  end;
end;

procedure THatirlatmaDlg.Temizle(ID: integer);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' Delete from HATHAR where ISNULL(SMSSTATU,0)=0 AND HAT_ID=' + IntToStr(ID) + ' AND CAGRITARIH >= ''' + FormatDateTime('yyyy-mm-dd', GenotipIni.BugunTrh) + '''';
  Tablo.Query1.ExecSQL;
end;

procedure THatirlatmaDlg.Ekle(Tar: TDatetime);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' INSERT INTO HATHAR ( HAT_ID , CAGRITARIH ) VALUES (' + TabCagri.Fieldbyname('ID').AsString +
    ',''' + FormatDateTime('yyyy-mm-dd', Tar) + ''')';
  Tablo.Query1.ExecSQL;
  Tablo.LogIslemleri('HATHAR', 'Ekleme', Tablo.Query1, true, false, false, false);

end;

procedure THatirlatmaDlg.SeansTarihiHesapla(HatTur: string; IlkTarih1: TDateTime; Seans, xsay: integer; per: string; SonTarih1: TDateTime; SeansMi: boolean);
var
  Tarih: TDateTime;
begin
  Tarih := Gun(IlkTarih1, xsay, per);
//      showmessage('ilktarih:'+formatdatetime('yyyy-mm-dd',ilktarih1));
//      showmessage('sontarih:'+formatdatetime('yyyy-mm-dd',sontarih1));
  if Seansmi then
  begin
    while Seans - 1 > 0 do
    begin
      Ekle(Tarih);
      Tarih := Gun(Tarih, xsay, per);
      Dec(Seans);
//      showmessage(' seans tarih:'+formatdatetime('yyyy-mm-dd',tarih));
    end;
  end
  else
  begin
    while (Tarih <= SonTarih1) do
    begin
      Ekle(Tarih);
      Tarih := Gun(Tarih, xsay, per);
//      showmessage(' seans tarih:'+formatdatetime('yyyy-mm-dd',tarih));
    end;
  end;
end;

procedure THatirlatmaDlg.TabCagriAfterPost(DataSet: TDataSet);
var ilktar: TDatetime;
  HatTur: string; IlkTarih1: TDateTime; Seans, xsay: integer; per: string; SonTarih1: TDateTime; Seansmi: boolean;
  ID: integer;
begin
  if YeniEklenenCagri then begin
    Tablo.LogIslemleri('HATIRLATMA', 'Ekleme', TabCagri, true, false, false, false);
  end
  else
    Tablo.LogIslemleri('HATIRLATMA', 'Deðiþ', TabCagri, true, false, false, false);

  ID := TabCagri.Fieldbyname('ID').AsInteger;
  TabCagri.Close;
  TabCagri.Open;
  TabCagri.Locate('ID', ID, []);

  if (not YeniEklenenCagri) then
    if Application.MessageBox(PChar(TabCagri.FieldByName('ISLEMADI').AsString + ' için çaðrý tarihleri yeniden düzenlensin mi?'),
      'O N A Y', mb_YesNo) <> IDYes then abort;

  Temizle(TabCagri.Fieldbyname('ID').AsInteger);
  Ekle(IlkTarih);
  if TabCagri.Fieldbyname('TEKRARLI').AsBoolean then
  begin
    HatTur := TabCagri.Fieldbyname('HATIRLATMATURU').AsString;
    Seans := TabCagri.Fieldbyname('SEANS_SAYISI').AsInteger;
    xsay := TabCagri.Fieldbyname('GELISSIKLIGI_SAYI').AsInteger;
    per := TabCagri.Fieldbyname('GELISSIKLIGI_PERIYOT').AsString;
    Seansmi := TabCagri.Fieldbyname('SEANSLI').AsBoolean;
    SonTarih1 := Gun(GenotipIni.BugunTrh, TabCagri.Fieldbyname('SONLANMA_SAYI').AsInteger, TabCagri.Fieldbyname('SONLANMA_PERIYOT').AsString);

    SeansTarihiHesapla(HatTur, IlkTarih, Seans, xsay, per, SonTarih1, seansmi);
  end;
end;


procedure THatirlatmaDlg.TabCagriDetayNewRecord(DataSet: TDataSet);
begin
  TabCagriDetay.Fieldbyname('HAT_ID').AsInteger := TabCagri.Fieldbyname('ID').AsInteger;
end;

procedure THatirlatmaDlg.DtsCagriDetayStateChange(Sender: TObject);
begin
  if DtsCagriDetay.State = dsBrowse then
    ngCagriDetay.VisibleButtons := []
  else
    ngCagriDetay.VisibleButtons := [nbPost, nbCancel];
end;

procedure THatirlatmaDlg.DtsCagriStateChange(Sender: TObject);
begin

  sbyeni.Enabled := DtsCagri.State = dsBrowse;
  sbSil.Enabled := DtsCagri.State = dsBrowse;
  sbKaydet.Enabled := DtsCagri.State in [dsedit, dsinsert];
  sbIptal.Enabled := DtsCagri.State in [dsedit, dsinsert];

  if sbSil.Enabled then
    sbSil.Enabled := DtsCagri.DataSet.RecordCount > 0;


end;

procedure THatirlatmaDlg.sbMesajSecClick(Sender: TObject);
begin
  if HatSMSSecDlg = nil then
    Application.CreateForm(THatSMSSecDlg, HatSMSSecDlg);

    HatSMSSecDlg.cbHazirMesaj.ItemIndex := HatSMSSecDlg.cbHazirMesaj.Items.IndexOf(TabCagri.FieldByName('MSGSABLONADI').AsString);
    HatSMSSecDlg.mMesaj.Text := TabCagri.FieldByName('MESAJ').AsString;

  HatSMSSecDlg.ShowModal;
  if HatSMSSecDlg.ModalResult = mrok then
  begin
    if TabCagri.State = dsBrowse then
      TabCagri.Edit;
    TabCagri.FieldByName('MESAJ').AsString := HatSMSSecDlg.mMesaj.Text;
    TabCagri.FieldByName('MSGSABLONADI').AsString := HatSMSSecDlg.cbHazirMesaj.Items[HatSMSSecDlg.cbHazirMesaj.itemindex];
  end;
end;

procedure THatirlatmaDlg.TabCagriBeforePost(DataSet: TDataSet);
var Sontarih1: TDateTime;
begin
  YeniEklenenCagri := False;
  if (not (TabCagri.Fieldbyname('ISLEMADI').AsString <> '')) then
  begin
    Application.MessageBox('Ýþlem seçiniz.', 'U Y A R I', MB_ICONWARNING);
    sbIslemSec.Click;
    abort;
  end;

  if TabCagri.state = dsInsert then
    if (not GunHesapla(IlkTarih) >= 0) then
    begin
      Application.MessageBox('Ýlk geliþ zamaný belirleyiniz (Geçmiþ tarihe hatýrlatma tanýmlanamaz).', 'U Y A R I', MB_ICONWARNING);
      IlkGelis_Gun.SetFocus;
      abort;
    end;

  if TabCagri.Fieldbyname('TEKRARLI').AsBoolean then
  begin

    if (not (TabCagri.Fieldbyname('GELISSIKLIGI_SAYI').AsInteger > 0)) or (TabCagri.Fieldbyname('GELISSIKLIGI_PERIYOT').AsString = '') then
    begin
      Application.MessageBox('Geliþ periyodu belirleyiniz.', 'U Y A R I', MB_ICONWARNING);
      GELISSIKLIGI_SAYI.SetFocus;
      abort;
    end;

    if rbseans.Checked then begin
      if (not (TabCagri.Fieldbyname('SEANS_SAYISI').AsInteger > 0)) then
      begin
        Application.MessageBox('Seans sayýsý veya sonlanma zamaný belirleyiniz.', 'U Y A R I', MB_ICONWARNING);
        SEANS_SAYISI.SetFocus;
        abort;
      end;
    end
    else begin
      SonTarih1 := Gun(GenotipIni.BugunTrh, TabCagri.Fieldbyname('SONLANMA_SAYI').AsInteger, TabCagri.Fieldbyname('SONLANMA_PERIYOT').AsString);
      if (not (sontarih1 > GenotipIni.BugunTrh)) then begin
        Application.MessageBox('Seans sayýsý veya sonlanma zamaný belirleyiniz.', 'U Y A R I', MB_ICONWARNING);
        SONLANMA_SAYI.SetFocus;
        abort;
      end;
    end;
  end;

  if TabCagri.FieldByName('DURUM').AsString = 'Aktif' then
  begin
    if HatSMSSecDlg = nil then
      Application.CreateForm(THatSMSSecDlg, HatSMSSecDlg);
//    HatSMSSecDlg.cbHazirMesaj.ItemIndex := HatSMSSecDlg.cbHazirMesaj.Items.IndexOf(TabCagri.FieldByName('MSGSABLONADI').AsString);
//    HatSMSSecDlg.mMesaj.Text := TabCagri.FieldByName('MESAJ').AsString;

    if  not (TabCagri.state = dsEdit) then begin
      HatSMSSecDlg.cbHazirMesaj.ItemIndex := HatSMSSecDlg.cbHazirMesaj.Items.IndexOf(HazirMesaj);
      HatSMSSecDlg.cbHazirMesajChange(nil);
      YeniEklenenCagri := False;
    end
    else begin
      HatSMSSecDlg.cbHazirMesaj.ItemIndex := HatSMSSecDlg.cbHazirMesaj.Items.IndexOf(TabCagri.FieldByName('MSGSABLONADI').AsString);
      HatSMSSecDlg.mMesaj.Text := TabCagri.FieldByName('MESAJ').AsString;
    end;

    HatSMSSecDlg.ShowModal;
    if HatSMSSecDlg.ModalResult = mrok then
    begin
      TabCagri.FieldByName('MESAJ').AsString := HatSMSSecDlg.mMesaj.Text;
      TabCagri.FieldByName('MSGSABLONADI').AsString := HatSMSSecDlg.cbHazirMesaj.Items[HatSMSSecDlg.cbHazirMesaj.itemindex];
    end;
  end;
  TabCagri.FieldByName('SEANSLI').AsBoolean := rbSeans.Checked;

  if TabCagri.state = dsEdit then exit;
  YeniEklenenCagri := True;
//  TabCagri.FieldByName('KAYITNO').AsString := HAT_KAYITNO;
//  TabCagri.FieldByName('MODUL').AsString := TabloDokum.Modul;
//  TabCagri.FieldByName('OLUSTURMATARIHI').AsDateTime := GenotipIni.BugunTrh;
//  TabCagri.FieldByName('KULLANICI').AsString := Kullanan;

end;

procedure THatirlatmaDlg.TabCagriBeforeDelete(DataSet: TDataSet);
begin
  if Application.MessageBox(PChar(TabCagri.FieldByName('ISLEMADI').AsString + ' için tanýmlanmýþ olan çaðrý bilgisi silinecektir. Emin misiniz?'),
    'O N A Y', mb_YesNo) <> IDYes then abort;

//  Tablo.Query1.Close;
//  Tablo.Query1.SQL.Text := 'Delete From HATHAR Where HAT_ID=' + TabCagri.FIELDBYNAME('ID').AsString;
//  Tablo.Query1.ExecSQL;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select *  From HATHAR Where HAT_ID=' + TabCagri.FIELDBYNAME('ID').AsString;
  Tablo.Query1.open;

  while not tablo.Query1.Eof do begin
    Tablo.LogIslemleri('HATHAR', 'Silme', tablo.Query1, true, false, false, false);
    Tablo.Query1.Delete;
  end;


  Tablo.LogIslemleri('HATIRLATMA', 'Silme', TabCagri, true, false, false, false);


end;

procedure THatirlatmaDlg.sbYeniClick(Sender: TObject);
begin
  TabCagri.Insert;
  sbIslemSec.Click;
  HATIRLATMA_TURU.SetFocus;
end;

procedure THatirlatmaDlg.sbSilClick(Sender: TObject);
begin
  TabCagri.Delete;
end;

procedure THatirlatmaDlg.sbKaydetClick(Sender: TObject);
begin
  TabCAgri.Post;
end;

procedure THatirlatmaDlg.sbIptalClick(Sender: TObject);
begin
  tabcagri.Cancel;
end;

procedure THatirlatmaDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
var i: integer;
begin
  if (DtsCagri.State in [dsinsert, dsedit]) or (DtsCagriDetay.State in [dsinsert, dsedit]) then
  begin
    i := Application.MessageBox(PChar('Deðiþiklikler kaydedilsin mi ?'), 'O N A Y', MB_YESNOCANCEL);
    case i of
      IDYes:
        begin
          if DtsCagri.State <> dsBrowse then
            TabCagri.Post;
          if DtsCagriDetay.State <> dsBrowse then
            TabCagriDetay.Post;
        end;
      IDCANCEL:
        begin
          Action := caNone;
        end;
    end;
  end;

end;

procedure THatirlatmaDlg.TabCagriDetayBeforePost(DataSet: TDataSet);
begin
  TabCagriDetay.FieldByName('GELDI').AsBoolean := false;

  if (not TabCagriDetay.FieldByName('GELISTARIH').IsNull) then
    TabCagriDetay.FieldByName('GELDI').AsBoolean := True;
end;

procedure THatirlatmaDlg.TabCagriBeforeEdit(DataSet: TDataSet);
begin
  Tablo.OncekiLogBelirle(TabCagri);
end;

procedure THatirlatmaDlg.TabCagriAfterOpen(DataSet: TDataSet);
begin
  TabCagriAfterScroll(nil);
end;

procedure THatirlatmaDlg.TusBelirle;
begin
  SEANS_SAYISI.Enabled := rbSeans.Checked;
  SONLANMA_SAYI.Enabled := not rbSeans.Checked;
  SONLANMA_PERIYOT.Enabled := not rbSeans.Checked;
end;

procedure THatirlatmaDlg.rbSeansClick(Sender: TObject);
begin
  if tabcagri.state = dsbrowse then
    TabCagri.Edit;
  TabCagri.FieldByName('SEANSLI').AsBoolean := True;
  TusBelirle;
end;

procedure THatirlatmaDlg.TabCagriNewRecord(DataSet: TDataSet);
begin
  TabCagri.FieldByName('ILKCAGRITARIHI').Value := strtodate(formatdatetime('dd/mm/yyyy', incmonth(GenotipIni.BugunTrh, 1)));
  TabCagri.FieldByName('KAYITNO').AsString := HAT_KAYITNO;
  TabCagri.FieldByName('MODUL').AsString := TabloDokum.Modul;
  TabCagri.FieldByName('OLUSTURMATARIHI').AsDateTime := GenotipIni.BugunTrh;
  TabCagri.FieldByName('KULLANICI').AsString := Kullanan;
  TabCagri.FieldByName('TEKRARLI').AsBoolean := False;
  TabCagri.FieldByName('DURUM').AsString := 'Aktif';
end;

end.


