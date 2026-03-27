unit UKrediHesapMakineDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics,
  cxLookAndFeelPainters, dxSkinscxPCPainter, cxStyles, cxCustomData, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxCurrencyEdit, Menus, FireDAC.Comp.Client,
  cxPC, StdCtrls, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls,
  ToolWin, cxSpinEdit, cxDropDownEdit, cxCalendar, cxGroupBox, cxRadioGroup,
  cxMaskEdit, cxTextEdit, cxContainer, cxLabel, Buttons, ExtCtrls,frxclass, Utablo,
  frxDBSet, cxButtons, cxLookAndFeels, dxCore, cxDateUtils, cxNavigator,
  cxPCdxBarPopupMenu, dxSkinLiquidSky, dxBarBuiltInMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;
type
  TKrediHesapMakineDlg = class(TForm, IPopupDialog)
    Panel1: TPanel;
    Yenilebtn: TSpeedButton;
    Label13: TcxLabel;
    Label12: TcxLabel;
    Label1: TcxLabel;
    Label2: TcxLabel;
    LabelBSMV: TcxLabel;
    LabelKKDFOrani: TcxLabel;
    EditTutar: TcxCurrencyEdit;
    EditBSMVOrani: TcxCurrencyEdit;
    EditKKDFOrani: TcxCurrencyEdit;
    ComboKurFat: TcxComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LabelDonem: TcxLabel;
    RadioGroupTatil: TcxRadioGroup;
    RadioGroupDonem: TcxRadioGroup;
    DateTimePickerOdemeBasl: TcxDateEdit;
    TaksitSay: TcxSpinEdit;
    LabelKDV: TcxLabel;
    EditKDV: TcxSpinEdit;
    ToolBar2: TToolBar;
    cxGrid2: TcxGrid;
    PlanTview: TcxGridDBTableView;
    ColumnSozId: TcxGridDBColumn;
    ColumnTarih: TcxGridDBColumn;
    ColumnTAKSIT: TcxGridDBColumn;
    PlanTviewKDVSIZ: TcxGridDBColumn;
    ColumnANAPARA: TcxGridDBColumn;
    ColumnFAIZ: TcxGridDBColumn;
    ColumnKKDF: TcxGridDBColumn;
    ColumnBSMV: TcxGridDBColumn;
    ColumnBAKIYE: TcxGridDBColumn;
    ColumnKur: TcxGridDBColumn;
    ColumnACIKLAMA: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    MemoSQLKredi: TMemo;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    MemoSQLLeasing: TMemo;
    ToolBar1: TToolBar;
    SilTus: TToolButton;
    btnAktar: TToolButton;
    ToolButton1: TToolButton;
    btnIptal: TToolButton;
    DtsOdemeTakvimi: TDataSource;
    TabOdemeTakvimi: TFDQuery;
    PopupMenu2: TPopupMenu;
    Excel1: TMenuItem;
    Text1: TMenuItem;
    HTML1: TMenuItem;
    XML1: TMenuItem;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    MenuItem1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    MenuItem2: TMenuItem;
    EMail1: TMenuItem;
    MenuItem3: TMenuItem;
    ToolButton2: TToolButton;
    frxOdemeTakvimi: TfrxDBDataset;
    ToolButton3: TToolButton;
    LabelSatis: TcxLabel;
    EditSatis: TcxCurrencyEdit;
    FaizOraniAy: TcxCurrencyEdit;
    FaizOraniYil: TcxCurrencyEdit;
    procedure YenilebtnClick(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure btnAktarClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure FaizOraniAyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KrediHesapMakineDlg: TKrediHesapMakineDlg;

implementation

uses Math, Fetautil, UFastRap, UGenelAnaSekmeFrame, URaporAraclari, UGirisKutusuEx,PrjConst,LocOnFly;

{$R *.dfm}

procedure TKrediHesapMakineDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxOdemeTakvimi);
end;

function TKrediHesapMakineDlg.EkranAdiAl: string;
begin
   if cxPageControl1.ActivePageIndex=0 then
      Result := 'KrediHesapDlg'
   else
      Result := 'LesingHesapDlg';
end;

procedure TKrediHesapMakineDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;


procedure TKrediHesapMakineDlg.btnAktarClick(Sender: TObject);
begin
   if (not TabOdemeTakvimi.Active)OR(TabOdemeTakvimi.RecordCount < 1) then
       ShowMessage(KDOdemeTakvimiHesaplanmamis)
   else if (cxPageControl1.ActivePageIndex=1)and(EditSatis.Text='') then
       ShowMessage(KDSatisTutariGirilmemis)
   else
       ModalResult := mrOk;
end;

procedure TKrediHesapMakineDlg.btnIptalClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TKrediHesapMakineDlg.FaizOraniAyClick(Sender: TObject);
var FaizOrani, bol : Real;
  Bilgi: Variant;
  ctrls: TGirdiDenetimleri;
begin
   //Efektif faiz oraný bulma formülü :  r = [ (1+i/n)^n ] - 1,  i:nominalfaiz  n:period
  if TcxButton(Sender).Name = 'FaizOraniAy' then
     Bilgi := FaizOraniAy.Value
  else
     Bilgi := FaizOraniYil.Value;

  ctrls := TGirdiDenetimleri.Create.CurrencyEdit(KDBasitFaizOrani, @Bilgi,4);    //.Edit(KDBasitFaizOrani, @Bilgi);
  if TGirisKutusuEx.BilgiAlEx(TcxButton(Sender).HelpKeyword+ KDBasitFaizOrani, ctrls) = mrOk then begin
      if trim(Bilgi) = '' then
      begin
        MessageDlg((KDOranBosOlamaz), mtError, [mbOK], 0);
        Exit;
      End
      else
      begin
        Bilgi:=StringReplace(Bilgi,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
        Bilgi:=StringReplace(Bilgi,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
        FaizOrani := StrToFloatDef(Bilgi,0);
        bol := FaizOrani/100.0;
        bol := bol+1.0;
        if TcxButton(Sender).Name = 'FaizOraniAy' then begin
           FaizOraniAy.Value := FaizOrani;// FExtToStr(FaizOrani,6);
           FaizOraniYil.Value := (power(bol, 12.0)-1.0)*100.0;
        end else begin
           FaizOraniYil.Value := FaizOrani;//FExtToStr(FaizOrani,6);
           FaizOraniAy.Value := (power(bol, (1/12.0))-1.0)*100.0;
        end;
      end;
  end;
end;

procedure TKrediHesapMakineDlg.cxPageControl1Change(Sender: TObject);
var
  ra: string;
  aktifFrame : TGenelAnaSekmeFrame;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := aktifFrame.pmDokumAyarlar;
  PopupMenuYaz.Images := aktifFrame.ImageList1;

 if cxPageControl1.ActivePageIndex = 1  then begin  //  'Leasing'
       PlanTview.GetColumnByFieldName('TAKSIT').Caption := KDKDVliKira;
       PlanTview.GetColumnByFieldName('KDVSIZ').Visible := True;
       PlanTview.GetColumnByFieldName('KKDF').Visible := False;
       PlanTview.GetColumnByFieldName('BSMV').Visible := False;
       EditBSMVOrani.Visible := False;
       LabelBSMV.Visible := False;
       EditKKDFOrani.Visible := False;
       LabelKKDFOrani.Visible := False;
       EditKDV.Visible := True;
       LabelKDV.Visible := True;
       LabelDonem.Visible := True;
       RadioGroupDonem.Visible := True;
       EditSatis.Visible := True;
       LabelSatis.Visible := True;
   end else begin
       PlanTview.GetColumnByFieldName('TAKSIT').Caption := KDTaksit;
       PlanTview.GetColumnByFieldName('KDVSIZ').Visible := False;
       PlanTview.GetColumnByFieldName('KKDF').Visible := True;
       PlanTview.GetColumnByFieldName('BSMV').Visible := True;
       EditBSMVOrani.Visible := True;
       LabelBSMV.Visible := True;
       EditKKDFOrani.Visible := True;
       LabelKKDFOrani.Visible := True;
       EditKDV.Visible := False;
       LabelKDV.Visible := False;
       LabelDonem.Visible := False;
       RadioGroupDonem.Visible := False;
       EditSatis.Visible := False;
       LabelSatis.Visible := False;
   end;
end;

procedure TKrediHesapMakineDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.GridTurkcelestir;
   cxPageControl1.ActivePageIndex := 0;
   ComboKurFat.ItemIndex := (ComboKurFat.RepositoryItem.Properties as TcxComboBoxProperties).Items.IndexOf(CariDoviz);
   DateTimePickerOdemeBasl.Date := SysUtils.IncMonth(Tablo.GENINI.BugunTrh, 1);
   cxPageControl1Change(Self);
end;

procedure TKrediHesapMakineDlg.SilTusClick(Sender: TObject);
begin
   DateTimePickerOdemeBasl.Date := Tablo.GENINI.BugunTrh;
   TaksitSay.Value := 1;
   EditTutar.Value := 0;
   FaizOraniAy.Value:= 0;
   TabOdemeTakvimi.Close;
end;

procedure TKrediHesapMakineDlg.YenilebtnClick(Sender: TObject);
var s: string;
    TutarStr,bsmv, kkdf : string[20];
    i : SmallInt;
   procedure Kredi;
   begin
       TabOdemeTakvimi.Close;
{       if EditBSMVOrani.Text <> '' then
          bsmv := Float_ToStr(EditBSMVOrani.Value
       else
          bsmv := '0';
       if EditKKDFOrani.Text <> '' then
          kkdf := EditKKDFOrani.Value
       else
          kkdf := '0';}

       case RadioGroupTatil.ItemIndex of
         1: i:=-1;
         2: i:=1;
         else i:=0;
       end;
       s:='  SET @TAKSITSAY='+IntToStr(TAKSITSay.Value)+
        ' SET @BASLANGIC= '''+Formatdatetime('yyyy-mm-dd',DateTimePickerOdemeBasl.Date)+''''+
        ' SET @BAKIYE= '+StringReplace(Float_ToStr(EditTutar.Value), ',', '.', [])+
        ' SET @KUR= '''+ComboKurFat.Text+''''+
        ' SET @FAIZORANI = '+ Float_ToStr(FaizOraniAy.Value)+
        ' SET @BSMVORANI = '+ StringReplace(Float_ToStr(EditBSMVOrani.Value), ',', '.', [])+
        ' SET @KKDFORANI = '+ StringReplace(Float_ToStr(EditKKDFOrani.Value), ',', '.', [])+
        ' SET @ONCESONRA = '+ IntToStr(i);

       TabOdemeTakvimi.SQL.Text:= STRingreplace(MemoSQLKredi.text,'SQLKOMUT',s, []);
       TabOdemeTakvimi.Open;
       PlanTview.ApplyBestFit(nil);
   end;

   procedure Leasing;
   begin
       if EditSatis.Text = '' then
          raise Exception.Create(KDSatisTutariGirilmemis);

       case RadioGroupTatil.ItemIndex of
         1: i:=-1;
         2: i:=1;
         else i:=0;
       end;
       TabOdemeTakvimi.Close;
       s:='  SET @TAKSITSAY='+IntToStr(TAKSITSay.Value)+
        ' SET @BASLANGIC= '''+Formatdatetime('yyyy-mm-dd',DateTimePickerOdemeBasl.Date)+''''+
        ' SET @BAKIYE= '+StringReplace(Float_ToStr(EditTutar.Value), ',', '.', [])+
        ' SET @KUR= '''+ComboKurFat.Text+''''+
        ' SET @FAIZORANI = '+ Float_ToStr(FaizOraniAy.Value*12.0) +
        ' SET @KDV = '+ StringReplace(Float_ToStr(EditKDV.Value), ',', '.', [])+
        ' SET @ONCESONRA = '+ IntToStr(i)+               //  -1 : onceki günlere gider, 1: sonraki günlere gider
        ' SET @DONEM = '+ IntToStr(RadioGroupDonem.ItemIndex)+               //  0 : dönembaþý, 1: dönem sonu
        ' SET @SATIS = '+StringReplace(Float_ToStr(EditSatis.Value), ',', '.', []);

       TabOdemeTakvimi.SQL.Text:= STRingreplace(MemoSQLLeasing.text,'SQLKOMUT',s, []);
       //Memo1.text := TabOdemeTakvimi.SQL.Text;
       TabOdemeTakvimi.Open;
       PlanTview.ApplyBestFit(nil);
   end;
begin
   //sqlde hata çýkýyor virgülü nokta yapalým
  // StringReplace(TutarStr, ',', '.', []);
   if cxPageControl1.ActivePageIndex = 1 then   //  'Leasing'
      Leasing
   else
      Kredi;
end;

end.

