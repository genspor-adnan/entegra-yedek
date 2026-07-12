unit UBarkodYazdir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, frxClass, frxDBSet, FireDAC.Comp.Client, ComCtrls, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxControls, cxGridCustomView, cxGrid, ToolWin, Menus, Utablo, cxSpinEdit,
  ExtCtrls, StdCtrls, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxImageComboBox, dxSkinLiquidSky, dxSkinscxPCPainter, dxSkinsCore, PrjConst, cxLookAndFeelPainters, cxButtons, cxLabel,
  cxLookAndFeels, dxSkinLondonLiquidSky, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TBarkodYazdirDlg = class(TForm, IPopupDialog)
    GridBarkod: TcxGrid;
    GridBarkodDBTableView4: TcxGridDBTableView;
    GridBarkodLevel8: TcxGridLevel;
    TabBarkodYazdir: TFDQuery;
    DtsBarkodYazdir: TDataSource;
    frxBarkodYazdir: TfrxDBDataset;
    ToolBar3: TToolBar;
    YaziciYaz: TToolButton;
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
    TabBarkodYazdirDetay: TFDQuery;
    DtsBarkodYazdirDetay: TDataSource;
    frxBarkodYazdirDetay: TfrxDBDataset;
    PanelBarkod: TPanel;
    ComboBoyutKategoriler: TcxImageComboBox;
    Label1: TLabel;
    MemoBoyutIzleme: TMemo;
    PanelIzleme: TPanel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    LabelTakipSayisi: TcxLabel;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBoyutKategorilerPropertiesEditValueChanged(Sender: TObject);
    procedure TabBarkodYazdirAfterPost(DataSet: TDataSet);
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
  public

    TakipCagiranTur,TakipCagiranBaslikId,TakipCagiranSatirId,TakipCagiranUrunId :Integer;
    TakipUniqueSayisi :Extended;
    StokID,GDepoID,CDepoID:Integer;
    TarihID:TDateTime;
    IslemOp:String;
    { Public declarations }
  end;

var
  BarkodYazdirDlg: TBarkodYazdirDlg;

implementation

uses
  UFastRap, UGenelAnaSekmeFrame, URaporAraclari, Fetautil, FetaKurulusSiniflari,LocOnFly,UVeriMotor;

{$R *.dfm}

procedure TBarkodYazdirDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
  DokumAdi: String[30];
begin
  if TabBarkodYazdir.State in [dsEdit, dsInsert] then
    TabBarkodYazdir.Post;
  //burada detay satırlarını oluşturuyoruz..
  DokumAdi := YaziciYaz.Caption;
  Delete(DokumAdi, Pos('&', DokumAdi), 1);
  AFastReport.EnabledDataSets.Clear;
  if Tablo.SQL_Komutlu_Yazdirma(TForm(ToolBar3.Owner),DokumAdi,EkranAdiAl,frxBarkodYazdir) then
    AFastReport.EnabledDataSets.Add(frxBarkodYazdir)
  else begin
    AFastReport.EnabledDataSets.Add(frxBarkodYazdir);
    AFastReport.EnabledDataSets.Add(frxBarkodYazdirDetay);
    AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  end;
end;

procedure TBarkodYazdirDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, Pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TBarkodYazdirDlg.ComboBoyutKategorilerPropertiesEditValueChanged(Sender: TObject);
begin
  FormShow(Self);
end;

procedure TBarkodYazdirDlg.cxButton1Click(Sender: TObject);

begin
  if TabBarkodYazdir.State in [dsEdit,dsInsert] then
    TabBarkodYazdir.Post;
  Tablo.TablodanSorguAc(8,'select sum(MIKTAR) from ##STOKBOYUTDURUMLAR_'+IntToStr(SPID)+'_ ');
  if Tablo.Query8.Fields[0].AsFloat<>TakipUniqueSayisi then begin
    ShowMessage(BRfazla_giris_uyarisi);
    Abort;
  end;


  Tablo.Query7.Close;
  Tablo.Query7.SQL.Text := ' delete from STOKBOYUTHAREKET where TUR='+IntToStr(TakipCagiranTur)+' and BASLIKID='+IntToStr(TakipCagiranBaslikId)+' and SATIRID in(0,'+IntToStr(TakipCagiranSatirId)+')';
  Tablo.Query7.SQL.Add(' insert into STOKBOYUTHAREKET (STOKID,TUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,STOKBOYUTKOMBINASYONID,MIKTAR,EKLEYEN,EKLEMETARIHI,SUBEID) ');
  Tablo.Query7.SQL.Add(' select '+IntToStr(StokID)+','+IntToStr(TakipCagiranTur)+','+IntToStr(TakipCagiranBaslikId)+','+IntToStr(TakipCagiranSatirId)+','+IntToStr(GDepoID)+','+IntToStr(CDepoID)+',ID,MIKTAR,'+Kullanan+',GetDate(),'+IntToStr(SubeId));
  Tablo.Query7.SQL.Add(' from ##STOKBOYUTDURUMLAR_'+IntToStr(SPID)+'_ ');
  Tablo.Query7.SQL.Add(' where MIKTAR <> 0 ');
  Tablo.Query7.ExecSQL;
  ModalResult := mrOk;
end;

procedure TBarkodYazdirDlg.cxButton2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TBarkodYazdirDlg.EkranAdiAl: string;
begin
  Result := 'Barkod Yazdırma';
end;

procedure TBarkodYazdirDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TarihID := Tablo.GENINI.BugunTrhSaat;

  Tablo.GridTurkcelestir;

  end;

procedure TBarkodYazdirDlg.FormShow(Sender: TObject);
var
  aktifFrame: TGenelAnaSekmeFrame;
  ra: string;
  Sonuc: Variant;
  i:Integer;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.Frame[1].Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra,aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;
  TabBarkodYazdir.Close;
  PanelBarkod.Visible := IslemOp = 'Y';
  ToolBar3.Visible := IslemOp = 'Y';
  if IslemOp <> 'Y' then  begin
    LabelTakipSayisi.Caption := 'Gerekli Kayıt Sayısı='+FormatFloat('0.0',TakipUniqueSayisi);
    Caption := 'Boyut İzleme';
    if IslemOp <> 'I' then
      PanelIzleme.Visible := True;
  end;
  if IslemOp='Y' then begin //Yazdırma
    if ComboBoyutKategoriler.EditValue<>null then begin
      TabBarkodYazdir.sql.Text := ' delete from BARKODYAZDIR where TARIHID='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihID)+''' and EKLEYEN='+Kullanan;
      TabBarkodYazdir.sql.Add(' insert into BARKODYAZDIR(TARIHID,STOKID,STOKBOYUTKOMBINASYONID,BARKODAYARID,BARKOD,ACIKLAMA,MIKTAR,EKLEYEN,EKLEMETARIHI) ');
      TabBarkodYazdir.sql.Add(' select '''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihID)+''',S.ID,SBK.ID,BA.ID,SB.BARKOD,ACIKLAMA=isnull(G1.ANAHTAR,'''') +'' ''+isnull(G2.ANAHTAR,'''') +'' ''+isnull(G3.ANAHTAR,''''),0,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihID)+''' ');
      TabBarkodYazdir.sql.Add(' from STOKLAR  S inner join                                                                ');
      TabBarkodYazdir.sql.Add(' 	STOKBOYUTKOMBINASYON SBK on S.ID=SBK.STOKID inner join                                  ');
      TabBarkodYazdir.sql.Add(' 	STOKBARKOD SB on S.ID=SB.STOKID and SB.YERI= 342 and SB.YERID=SBK.ID left outer join    ');
      TabBarkodYazdir.sql.Add(' 	BARKODAYARLAR BA on BA.ID=SB.BARKODTIPI left outer join                                 ');
      TabBarkodYazdir.sql.Add(' 	GENINI G1 on SBK.BOLUM1=G1.BOLUM and SBK.DEGER1=G1.DEGER and G1.DIL=-1 left outer join  ');
      TabBarkodYazdir.sql.Add(' 	GENINI G2 on SBK.BOLUM2=G2.BOLUM and SBK.DEGER2=G2.DEGER and G2.DIL=-1 left outer join  ');
      TabBarkodYazdir.sql.Add(' 	GENINI G3 on SBK.BOLUM3=G3.BOLUM and SBK.DEGER3=G3.DEGER and G3.DIL=-1 ');
      TabBarkodYazdir.sql.Add(' where S.ID='+IntToStr(StokID)+' and BA.ID='+VarToStr(ComboBoyutKategoriler.EditValue));
      TabBarkodYazdir.ExecSQL;
      TabBarkodYazdir.Close;
      TabBarkodYazdir.sql.Text := ' select ID,ACIKLAMA,BARKOD,MIKTAR from BARKODYAZDIR where TARIHID='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihID)+''' and EKLEYEN='+Kullanan;
      TabBarkodYazdir.Open;
    end;
    Sonuc := veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select '+DbUst(1)+'BARKODTIPI from STOKBARKOD where STOKID=&StokID order by  VARSAYILAN desc '+DbSinir(1),['&StokID'],[StokID],True);
    if (VarToStr(Sonuc)<>'')and(VarToStr(ComboBoyutKategoriler.EditValue)='') then begin
      ComboBoyutKategoriler.EditValue := Sonuc;
      ComboBoyutKategoriler.PostEditValue;
    end;
    TabBarkodYazdirDetay.Close;
    //TODO: Yanl�� sorgu mu BARKODYAZDIR tablosundan m� al�nmal�
    TabBarkodYazdirDetay.SQL.Text := 'select * from [dbo].[fn_BarkodBaskiDetay] ('+IntToStr(StokID)+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',TarihID)+''','+Kullanan+','+IntToStr(Dil)+') ';
    TabBarkodYazdirDetay.Open;
    GridBarkodDBTableView4.DataController.CreateAllItems(True);
    if GridBarkodDBTableView4.GetColumnByFieldName('ID')<>nil then
      GridBarkodDBTableView4.GetColumnByFieldName('ID').Destroy;
    GridBarkodDBTableView4.ApplyBestFit(nil);
    GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Summary.FooterKind := skSum;
  end else begin //Görme ekleme değiştirme
  //tmp tablo alan listesi:
  //	ID int,STOKID int,ACIKLAMA nvarchar(200),GDEPODURUM float,CDEPODURUM float,EKLENECEK float,CIKARILACAK float
    TabBarkodYazdir.sql.Text := StringReplace(MemoBoyutIzleme.Lines.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;;
    TabBarkodYazdir.Params[0].Value := StokID; //stokıd
    TabBarkodYazdir.Params[1].Value := GDepoID; //depoid
    TabBarkodYazdir.Params[2].Value := CDepoID; //depoid
    TabBarkodYazdir.Params[3].Value := Dil; //dil
    TabBarkodYazdir.Params[4].Value := TakipCagiranTur;
    TabBarkodYazdir.Params[5].Value := TakipCagiranBaslikId;
    TabBarkodYazdir.Params[6].Value := TakipCagiranSatirId;
    TabBarkodYazdir.ExecSQL;
    TabBarkodYazdir.Close;
    TabBarkodYazdir.sql.Text := 'select * from ##STOKBOYUTDURUMLAR_'+IntToStr(SPID)+'_';
    TabBarkodYazdir.Open;
    GridBarkodDBTableView4.DataController.CreateAllItems(True);
    if GridBarkodDBTableView4.ColumnCount>0 then begin
      GridBarkodDBTableView4.GetColumnByFieldName('STOKID').Visible := False;
      GridBarkodDBTableView4.GetColumnByFieldName('ID').Visible := False;
      GridBarkodDBTableView4.GetColumnByFieldName('ACIKLAMA').Options.Editing := False;
      GridBarkodDBTableView4.GetColumnByFieldName('ACIKLAMA').Caption := SDStokAciklama;
      GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Options.Editing := False;
      GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Options.Editing := False;
      if IslemOp='I' then begin //I izleme, G giriş, C çıkış
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Visible := False;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Visible := False;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Caption := SDStokDurum;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Summary.FooterKind := skSum;
      end else if (IslemOp = 'C') or (IslemOp = 'CD')  then begin
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Visible := False;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Summary.FooterKind := skSum;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Caption := SDStokCikisDepo;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Caption := SDStokCikartma;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Summary.FooterKind := skSum;
      end else if (IslemOp = 'G') or (IslemOp = 'GD')  then begin
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Summary.FooterKind := skSum;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Visible := False;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Caption := SDStokGirisDepo;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Caption := SDStokEkleme;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Summary.FooterKind := skSum;

      end else if IslemOp='T' then begin
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Summary.FooterKind := skSum;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Summary.FooterKind := skSum;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Visible := True;
        GridBarkodDBTableView4.GetColumnByFieldName('GDEPODURUM').Caption := SDStokGirisDepo;
        GridBarkodDBTableView4.GetColumnByFieldName('CDEPODURUM').Caption := SDStokCikisDepo;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Caption := SDStokTiransfer;
        GridBarkodDBTableView4.GetColumnByFieldName('MIKTAR').Summary.FooterKind := skSum;
      end;
    end;
    for I := 0 to GridBarkodDBTableView4.ColumnCount - 1 do
      GridBarkodDBTableView4.Columns[i].MinWidth := 100;
    GridBarkodDBTableView4.ApplyBestFit(nil);
  end;
end;

procedure TBarkodYazdirDlg.TabBarkodYazdirAfterPost(DataSet: TDataSet);
begin
  if IslemOp = 'Y' then begin //Yazdırma
    TabloYenile(TabBarkodYazdirDetay,[]);
  end;

end;



end.



