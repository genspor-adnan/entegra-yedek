unit UCekler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, Menus, FireDAC.Comp.Client, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxButtonEdit, cxDBEdit, cxMaskEdit, cxSpinEdit, StdCtrls, DBCtrls,
  cxContainer, cxTextEdit, cxCurrencyEdit, ExtCtrls, ComCtrls, Mask, Buttons,
  Grids, DBGrids, cxDropDownEdit, cxCalendar, cxImageComboBox,UGentegreFrameYonetimi,
  cxLookAndFeelPainters, cxButtons, UCekAramaFrame,USenetAramaFrame,
  dxSkinsCore, dxSkinscxPCPainter,UFrameYoneticisi, frxClass, ToolWin,
  frxDBSet, cxMemo, cxLabel, cxDBLabel, cxImage, cxRichEdit,
  dxSkinLondonLiquidSky;

type
  TCekDlg = class(TFrame, IIcerikBilgiFrame, IBilgiFrame, IAracCubuguDestegi)
    Panel5: TPanel;
    DtsCekler: TDataSource;
    TabCekler: TFDQuery;
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    YaziciYaz: TToolButton;
    btnKapat: TToolButton;
    ToolButton4: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    TabBankalar: TFDQuery;
    DtsBankalar: TDataSource;
    ResimTus: TToolButton;
    Bevel1: TBevel;
    Bevel4: TBevel;
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label5: TLabel;
    Label10: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    EditCARIKOD: TcxButtonEdit;
    ComboKUR: TcxDBComboBox;
    EditOZELKOD: TcxDBTextEdit;
    EditYETKIKODU: TcxDBTextEdit;
    EditSERINO: TcxDBTextEdit;
    EditODEMEYERI: TcxDBTextEdit;
    EditACIKLAMA: TcxDBTextEdit;
    EditKEFIL: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    ComboTUR: TcxDBImageComboBox;
    DateKesideTarihi: TcxDBDateEdit;
    EditTUTAR: TcxDBCurrencyEdit;
    cxDBTextEdit1: TcxDBTextEdit;
    ComboHITAP: TcxDBImageComboBox;
    LabelCARIAD: TcxLabel;
    Logo: TcxDBImage;
    LabelSubeKodu: TcxDBLabel;
    LabelSubeAdi: TcxDBLabel;
    DateTARIH: TcxDBDateEdit;
    CekImaj: TcxDBImage;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    BtnCekTarihcesi: TcxButton;
    cxGridTarihceDBTableView1: TcxGridDBTableView;
    cxGridTarihceLevel1: TcxGridLevel;
    cxGridTarihce: TcxGrid;
    DtsCekHareketler: TDataSource;
    TabCekHareketler: TFDQuery;
    cxGridTarihceDBTableView1TARIH: TcxGridDBColumn;
    cxGridTarihceDBTableView1NEREYE: TcxGridDBColumn;
    cxGridTarihceDBTableView1ACIKLAMA: TcxGridDBColumn;
    BtnCiroEkle: TcxButton;
    cxGridTarihceDBTableView1ISLEM: TcxGridDBColumn;
    BtnCiroSil: TcxButton;
    Label2: TLabel;
    EditBORDRO: TcxDBTextEdit;
    Label1: TLabel;
    EditKOD: TcxDBTextEdit;
    frxCekler: TfrxDBDataset;
    procedure DtsCeklerStateChange(Sender: TObject);
    procedure EditCARIKODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ComboDURUMPropertiesChange(Sender: TObject);
    procedure TabCeklerBeforePost(DataSet: TDataSet);
    procedure TabCeklerAfterPost(DataSet: TDataSet);
    procedure FrameResize(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure LogoClick(Sender: TObject);
    procedure TabCeklerAfterScroll(DataSet: TDataSet);
    procedure CekImajClick(Sender: TObject);
    procedure TabCeklerBeforeEdit(DataSet: TDataSet);
    procedure BtnCekTarihcesiClick(Sender: TObject);
    procedure BtnCiroEkleClick(Sender: TObject);
    procedure TabCekHareketlerAfterScroll(DataSet: TDataSet);
    procedure BtnCiroSilClick(Sender: TObject);
  private
    { Private declarations }
    { IBilgiFrame üyeleri            }
    FFrameBilgi : TIcerikFrameBilgi;
    FKapatEylemi: TNotifyEvent;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);
    { Gezinme ve yazdırma desteği }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    procedure GezinmeBagla(ADBNavigator : TDBNavigator);
    procedure YazdirmayaHazirla(AFastReport : TfrxReport);
    function EkranAdiAl : string;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure CekEkranInit(ACekId: Integer);
    property KapatEylemi : TNotifyEvent read FKapatEylemi write FKapatEylemi;
  end;

implementation

{$R *.dfm}
Uses UVeriMotor, Utablo, UReharadlg, UAnaForm, FetaClassExtensions, UAramaYokFrame,
  UFastRap, UBankaSecimi,PrjConst, UKasaWizard, UResim,UCekWizard,UCekKocanWizard,UCekHareketWizard,
  FetaKurulusSiniflari,UGenelAnaSekmeFrame;

var
   EskiRehberID : Integer;
Resourcestring
    CekKasaHareketiHatasi=  'Tahsilatı bulunan çek kaydı silinemez!';
    CekHareketHareketiHatasi =  'Hareket görmüş çek kaydı silinemez!';


procedure TCekDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
   s := YaziciYaz.Caption;
   Delete(s, pos('&',s), 1);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'CekDlg', s)
end;

procedure TCekDlg.Baslatildi;
begin

end;

procedure TCekDlg.BtnCekTarihcesiClick(Sender: TObject);
begin
  if DtsCekler.State in [dsEdit,dsInsert] then
     raise Exception.Create('Lütfen Kayıt İşlemini Tamamlayın.')
  Else
     cxGridTarihce.Visible := Not cxGridTarihce.Visible;
  BtnCiroEkle.Visible := cxGridTarihce.Visible;
  BtnCiroSil.Visible := cxGridTarihce.Visible;
  if BtnCiroEkle.Visible = True then begin
     TabCekHareketler.Close;
     if AktifVeriMotor = vmPG then TabCekHareketler.SQL.Text := PgSqlCevir(TabCekHareketler.SQL.Text);
     TabCekHareketler.Params[0].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Params[1].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Params[2].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Open;
  end;
  //BtnCiroSil.Visible := TabCekHareketler.RecordCount>1; //açılış kaydı her çekte geliyor..

end;

procedure TCekDlg.BtnCiroEkleClick(Sender: TObject);
begin
   Application.CreateForm(TCekHareketDlg,CekHareketDlg);
   CekHareketDlg.IslemTuru:='';
   CekHareketDlg.CeksenetID:=TabCekler.FieldByName('ID').Value;

   CekHareketDlg.ShowModal;
   CekHareketDlg.Destroy;
   TabCekler.Close;
   TabCekler.Open;
   TabCekHareketler.Close;
   if AktifVeriMotor = vmPG then TabCekHareketler.SQL.Text := PgSqlCevir(TabCekHareketler.SQL.Text);
   TabCekHareketler.Params[0].Value:=TabCekler.FieldByName('ID').AsInteger;
   TabCekHareketler.Params[1].Value:=TabCekler.FieldByName('ID').AsInteger;
   TabCekHareketler.Params[2].Value:=TabCekler.FieldByName('ID').AsInteger;
   TabCekHareketler.Open;
end;

procedure TCekDlg.BtnCiroSilClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'delete from CEKHAREKET where CEKSENETLERID = '+TabCekler.FieldByName('ID').asstring+' and ID = '+TabCekHareketler.FieldByName('SIRALAMA').asstring;
     if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
     Tablo.Query1.ExecSQL;
     TabCekHareketler.Close;
     if AktifVeriMotor = vmPG then TabCekHareketler.SQL.Text := PgSqlCevir(TabCekHareketler.SQL.Text);
     TabCekHareketler.Params[0].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Params[1].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Params[2].Value:=TabCekler.FieldByName('ID').AsInteger;
     TabCekHareketler.Open;
  end;
end;

procedure TCekDlg.btnKapatClick(Sender: TObject);
begin
  if Assigned(FKapatEylemi) then
     FKapatEylemi(Self);
end;

procedure TCekDlg.CekImajClick(Sender: TObject);
begin
   if TabCekler.State in [dsEdit, dsInsert] then
      TabCekler.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.Yeri := 21;
   ResimDlg.YerId := TabCekler.Fields[0].AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
   TabResim.Close;
   if AktifVeriMotor = vmPG then TabResim.SQL.Text := PgSqlCevir(TabResim.SQL.Text);
   TabResim.Params[0].Value := TabCekler.Fields[0].AsInteger;
   TabResim.Open;

end;

procedure TCekDlg.CekEkranInit(ACekId: Integer);
begin
  TabCekler.Close;
  if ACekId <> -1 then begin
    if ACekId = -2 then
      TabCekler.SQL.Text := 'SELECT '+DbUst(1)+'*  FROM CEKLER ORDER BY ID DESC '+DbSinir(1)
    else begin
      TabCekler.SQL.Text := 'SELECT *   FROM CEKLER WHERE ID = :ID';
      if AktifVeriMotor = vmPG then TabCekler.SQL.Text := PgSqlCevir(TabCekler.SQL.Text);
      TabCekler.Params.ParamByName('ID').AsInteger := ACekId;
    end;
  end else { Yani -1 -> Boş Çek senet ekranı için boş bir query }
    TabCekler.SQL.Text := 'SELECT '+DbUst(0)+' * FROM CEKLER '+DbSinir(0);
  TabCekler.Open;
end;

procedure TCekDlg.ComboDURUMPropertiesChange(Sender: TObject);
begin
  if ComboDURUM.ItemIndex = -1 then Exit;
    case ComboDURUM.Properties.Items[ComboDURUM.ItemIndex].Value of
      1,2,6,7,8 : begin
                //LabelIlgiliKod.Caption := 'İlgili Cari Hesap Kodu';
                //EditILGILIKOD.Enabled := False;
          end;
      3 : begin //LabelIlgiliKod.Caption := 'İlgili Cari Hesap Kodu';
                //EditILGILIKOD.Enabled := True;
          end;
      4,5 : begin //LabelIlgiliKod.Caption := 'İlgili Bankanın Kodu';
                //EditILGILIKOD.Enabled := True;
          end;
    end;
end;

constructor TCekDlg.Create(AOwner: TComponent);
begin
  inherited;
  RehberIni.ReadSection('KURLAR', ComboKUR.Properties.Items);
end;

destructor TCekDlg.Destroy;
begin

  inherited;
end;

procedure TCekDlg.DtsCeklerStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsCekler, EkleTus,SilTus,KaydetTus,IptalTus);
end;

procedure TCekDlg.EditCARIKODPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
   ID := Tablo.RehberAra_IDGetir(-1);
   if ID > 0 then begin
      TabCekler.Edit;
      TabCekler.FieldByName('REHBERID').AsInteger := ID;
      TabCeklerAfterScroll(TabCekler);
   end;
end;

procedure TCekDlg.EkleTusClick(Sender: TObject);
var    TN : TTreeNode;
begin
   if KasaWizardDlg = nil then
     Application.CreateForm(TKasaWizardDlg, KasaWizardDlg);
   KasaWizardDlg.WizardKontrol.SelectFirstPage;
   KasaWizardDlg.KasaTarihi.Date := RehberIni.BugunTrh;
   KasaWizardDlg.PanelSag.Visible := False;
   KasaWizardDlg.MenuMusTree.Items.clear;
   TN := KasaWizardDlg.MenuMusTree.Items.Add(nil,'Alınan Çek');
   TN.selectedIndex := 23;
   TN := KasaWizardDlg.MenuMusTree.Items.Add(nil,'Verilen Çek');
   TN.selectedIndex := 33;
   KasaWizardDlg.ShowModal;
   if KasaWizardDlg.modalresult = mrOK then
      CekEkranInit(KasaWizardDlg.Tag);
   KasaWizardDlg.destroy;
//   TabCekler.Append;
end;

function TCekDlg.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TCekDlg.EkranYazdir(Sender: TObject);
begin

end;

procedure TCekDlg.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekDlg.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TCekDlg.FrameResize(Sender: TObject);
begin
  btnKapat.Left := Width - btnKapat.Width - 5;
end;

function TCekDlg.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TCekDlg.GetKapatilabilir: Boolean;
begin

end;

function TCekDlg.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TCekDlg.GezinmeBagla(ADBNavigator: TDBNavigator);
begin
//  ADBNavigator.DataSource := DtsCekler;
end;

procedure TCekDlg.Gorunmez;
begin

end;

procedure TCekDlg.GorunmezOlacak;
begin

end;

procedure TCekDlg.Gorunur;
begin
  cxGridTarihce.Visible := False;
  BtnCiroEkle.Visible:=False;
  BtnCiroSil.Visible:=False;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).ImageList1;
end;

procedure TCekDlg.GorunurOlacak;
begin

end;



procedure TCekDlg.IptalTusClick(Sender: TObject);
begin
   TabCekler.Cancel;
end;

procedure TCekDlg.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TCekDlg.KaydetTusClick(Sender: TObject);
begin
   TabCekler.Post;
end;

procedure TCekDlg.LogoClick(Sender: TObject);
var Cagiran : SmallInt;
    HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
begin
   Application.CreateForm(TBankaSecimDlg, BankaSecimDlg);
   if ComboTUR.ItemIndex < 2 then
      BankaSecimDlg.Cagiran := 4//4; //müşteri (genel) banka lastesi gelsin
   else
      BankaSecimDlg.Cagiran := 21;// bizim hesap listemiz
   BankaSecimDlg.ShowModal;
   if BankaSecimDlg.ModalResult = mrOk then begin
      TabCekler.Edit;
      TabCekler.FieldByname('BANKASUBELERID').AsString := BankaSecimDlg.TabSubeler.FieldByname('SUBEID').AsString;
      TabCeklerAfterScroll(TabCekler);
      if ComboTUR.ItemIndex >= 2 then //bizim çekimiz; hesapno yu da dolduralım
         TabCekler.FieldByname('HESAPNO').AsString := BankaSecimDlg.TabSubeler.FieldByname('HESAPNO').AsString;
   end;
   BankaSecimDlg.Destroy;

{   if ComboTUR.ItemIndex < 2 then
      Cagiran := 4   //4; //müşteri (genel) banka lastesi gelsin
   else
      Cagiran := 21; // bizim hesap listemiz

   if Tablo.BankaHesapEkrani(Cagiran, HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
      TabCekler.Edit;
      TabCekler.FieldByname('BANKASUBELERID').AsString := HESAPID;
      if ComboTUR.ItemIndex >= 2 then //bizim çekimiz; hesapno yu da dolduralım
         TabCekler.FieldByname('HESAPNO').AsString := HESAPNO;
   end;}
end;

procedure TCekDlg.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TCekDlg.SilTusClick(Sender: TObject);
begin
   if Tablo.CekSil(TabCekler.FieldByName('ID').asInteger) then
      btnKapat.click;
end;

procedure TCekDlg.TabCekHareketlerAfterScroll(DataSet: TDataSet);
Var
  Sira:Integer;
begin
  sira := TabCekHareketler.FieldByName('SIRALAMA').AsInteger;
  if (Sira = 0) or (Sira = 2000000001) then
     BtnCiroSil.Enabled := False
  Else Begin
     BtnCiroSil.Enabled := True;
     BtnCiroSil.Visible := True;
  End;
end;

procedure TCekDlg.TabCeklerAfterPost(DataSet: TDataSet);
begin
   if EskiRehberID <>  TabCekler.FieldByName('REHBERID').AsInteger then begin
      Tablo.Query1.Close;    //resimlerisilinir
      Tablo.Query1.SQL.Text := ' update IMAJ set YER_ID='+TabCekler.Fields[0].AsString + ' where YERI = 21 and YER_ID='+IntToStr(EskiRehberID);
      if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
      Tablo.Query1.ExecSQL;
   end;

   if SeriNoKontrol then
      Tablo.Uyarilar_Cek(TabCekler.FieldByName('HESAPNO').AsString);
  cxGridTarihce.Visible := False;
  BtnCiroEkle.Visible := False;
  BtnCiroSil.Visible:=False;

end;

procedure TCekDlg.TabCeklerAfterScroll(DataSet: TDataSet);
var CARIKOD, CARIUNVAN : string;
begin
  TabBankalar.Close;
  if AktifVeriMotor = vmPG then TabBankalar.SQL.Text := PgSqlCevir(TabBankalar.SQL.Text);
  TabBankalar.Params[0].Value := TabCekler.FieldByName('BANKASUBELERID').AsInteger;
  TabBankalar.Open;
  TabResim.Close;
  if AktifVeriMotor = vmPG then TabResim.SQL.Text := PgSqlCevir(TabResim.SQL.Text);
  TabResim.Params[0].Value := TabCekler.Fields[0].AsInteger;
  TabResim.Open;
  Tablo.RehberBilgisiGetir(TabCekler.FieldByName('REHBERID').AsInteger, CARIKOD, CARIUNVAN );
  EditCARIKOD.Text := CARIKOD;
  LabelCARIAD.Caption  := CARIUNVAN;
  cxGridTarihce.Visible := False;
  BtnCiroEkle.Visible:=False;
  BtnCiroSil.Visible:=False;
end;

procedure TCekDlg.TabCeklerBeforeEdit(DataSet: TDataSet);
begin
   EskiRehberID :=  TabCekler.FieldByName('REHBERID').AsInteger;
end;

procedure TCekDlg.TabCeklerBeforePost(DataSet: TDataSet);
var s : string;
    function Kontrol(Alan, Ad : String) : Boolean;
    Begin
      if TabCekler.FieldByName(Alan).AsString='' then
      Begin
        Application.MessageBox(PChar(Ad+' boş bırakılamaz .'),'U Y A R I',MB_OK+MB_ICONERROR);
        Result := False;
      End
      else
        Result := True;
    end;
begin
  //yeni çek girişleri için çek serino kontrolü
  if DtsCekler.State=dsInsert then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:=' select * from CEKLER where SERINO = '+inttostr(StrToIntDef(EditSERINO.Text, 0));
    if AktifVeriMotor = vmPG then Tablo.Query1.SQL.Text := PgSqlCevir(Tablo.Query1.SQL.Text);
    Tablo.Query1.Open;
    if Tablo.Query1.RecordCount>0 then
      raise Exception.Create(kullanilmisserino);
  end;
  if not Kontrol('BANKASUBELERID', 'Banka') then abort;
  if not Kontrol('REHBERID', 'Cari Kod') then abort;
  //if not Kontrol('BORDRO', 'Bordro') then abort;
  if not Kontrol('SERINO', 'Seri No') then abort;
  if not Kontrol('KOD', 'Kod') then abort;
  if not Kontrol('ODEMEYERI', 'Keşide Yeri') then abort;
  if not Kontrol('VADE', 'Keşide Tarihi') then abort;
  if not Kontrol('TUTAR', 'Tutar') then abort;
  if (SeriNoKontrol)and(ComboTUR.ItemIndex in [2,3]) then begin//Verdiğimiz çekse serino kontrolu var
     if TabCekler.State = dsInsert then
        s:='-1'
     else
        s := TabCekler.FieldByName('ID').AsString;
  //   if not Tablo.CekSenetBilgiKontrolu(TextHESAPID.Text, EditSERINO.Text, s)then abort;
  end;
  TabCekler.FieldByName('DEGISTIREN').AsString := Kullanan;
  TabCekler.FieldByName('DEGISTIRMETARIHI').AsDateTime := RehberIni.BugunTrh;
end;

procedure TCekDlg.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TCekDlg.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TCekDlg.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TCekDlg.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TCekDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxCekler);
end;

procedure TCekDlg.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TCekDlg);
end.







