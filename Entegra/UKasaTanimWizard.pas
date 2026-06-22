unit UKasaTanimWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, cxGraphics, cxCheckBox, cxDBEdit, cxCurrencyEdit,
  cxImageComboBox, cxMaskEdit, cxDropDownEdit, cxTextEdit, cxControls,
  cxContainer, cxEdit, cxLabel, cxDBLabel, StdCtrls, DB, FireDAC.Comp.Client, frxClass,
  frxDBSet, Menus, JvWizard, JvExControls, dxSkinLondonLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinLiquidSky, cxButtonEdit, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TKasaTanimWizardDlg = class(TForm)
    WizardKontrol: TJvWizard;
    GirisEkr: TJvWizardWelcomePage;
    PopupMenu1: TPopupMenu;
    AcilisKaydiMenu: TMenuItem;
    KasaYenileMenu: TMenuItem;
    N1: TMenuItem;
    BtnKasalarnToplamlarnYenile1: TMenuItem;
    frxKasalar: TfrxDBDataset;
    DtsKasalar: TDataSource;
    TabKasalar: TFDQuery;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label4: TcxLabel;
    Label6: TcxLabel;
    Label7: TcxLabel;
    Label8: TcxLabel;
    Label9: TcxLabel;
    Label13: TcxLabel;
    DBText1: TcxDBLabel;
    EditKASAKODU: TcxDBTextEdit;
    EditKASAADI: TcxDBTextEdit;
    ComboKUR: TcxDBComboBox;
    EditHESAPACIKLAMA: TcxDBTextEdit;
    EditOZELKOD: TcxDBTextEdit;
    EditYETKIKODU: TcxDBTextEdit;
    ComboDURUM: TcxDBImageComboBox;
    cxDBCheckBox1: TcxDBCheckBox;
    DevirFiiGir1: TMenuItem;
    N2: TMenuItem;
    cxLabel1: TcxLabel;
    ComboKasaTuru: TcxDBImageComboBox;
    EditBakiye: TcxDBCurrencyEdit;
    cxLabel2: TcxLabel;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    ComboPersonel: TcxButtonEdit;
    LabelPersonel: TcxLabel;
    LabelREHBERID: TcxDBLabel;
    procedure AcilisKaydiMenuClick(Sender: TObject);
    procedure TabKasalarAfterPost(DataSet: TDataSet);
    procedure TabKasalarBeforePost(DataSet: TDataSet);
    procedure TabKasalarNewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure WizardKontrolFinishButtonClick(Sender: TObject);
    procedure WizardKontrolCancelButtonClick(Sender: TObject);
    procedure TabKasalarBeforeEdit(DataSet: TDataSet);
    procedure ComboSubePropertiesCloseUp(Sender: TObject);
    procedure ComboSubeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure ComboKasaTuruPropertiesChange(Sender: TObject);
    procedure ComboPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    IslemOp:Char;
    Cagiran, KasaID : Integer
  end;

var
  KasaTanimWizardDlg:  TKasaTanimWizardDlg;

implementation

uses UAcilisKaydi, Utablo,PrjConst,LocOnFly;

{$R *.dfm}

procedure TKasaTanimWizardDlg.AcilisKaydiMenuClick(Sender: TObject);
begin
   try
     if DtsKasalar.State IN [dsInsert,dsEdit] then
        TabKasalar.Post;
   finally
    Tablo.AcilisiFisiEkraniBaslat(2,TMenuItem(Sender).Tag, TabKasalar.FieldByname('ID').AsString,TabKasalar.FieldByname('KASAKODU').AsString,TabKasalar.FieldByname('KASAADI').AsString, TabKasalar.FieldByName('KUR').AsString, 0, Tablo.GENINI.BugunTrhSaat);
   end;
end;

procedure TKasaTanimWizardDlg.ComboKasaTuruPropertiesChange(Sender: TObject);
begin
   LabelPersonel.Visible := ComboKasaTuru.EditingValue=195;
   comboPersonel.Visible := LabelPersonel.Visible;
   LabelREHBERID.Visible := LabelPersonel.Visible;
end;

procedure TKasaTanimWizardDlg.ComboPersonelPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  ID:integer;
begin
   if AButtonIndex=0 then begin
       ID:=Tablo.RehberAra_IDGetir(335);
       if ID > 0 then begin
          ComboPersonel.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
          TabKasalar.Edit;
          TabKasalar.FieldByName('REHBERID').Value := ID;
       end;
   end
   else begin
       ComboPersonel.Text := '';
       TabKasalar.FieldByName('REHBERID').Value := 0;
   end;
end;

procedure TKasaTanimWizardDlg.ComboSubeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  ComboSube.EditValue := 0;
end;

procedure TKasaTanimWizardDlg.ComboSubePropertiesCloseUp(Sender: TObject);
begin
  ComboSube.EditValue := Tablo.SubeGetir(Tablo.GENINI.ReadInteger(Ops_OpsiyonKasa_GorunecekSubelerKasa,0),ComboSube.EditValue);
end;

procedure TKasaTanimWizardDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then
      LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.;
   Tablo.WizardTurkcelestir(WizardKontrol);
   ComboKUR.Enabled := DovizTakibi;
end;

procedure TKasaTanimWizardDlg.FormShow(Sender: TObject);
begin
   Tablo.GENINI.ReadSection(Ops_KURLAR,ComboKur.Properties);   // KURLAR
   EditBakiye.Visible := Tablo.YetkiVarmi(230101,YetkiTur_Gorme);
   cxLabel2.Visible := Tablo.YetkiVarmi(230101,YetkiTur_Gorme);
   Tabloyenile(TabKasalar, [KasaId]);
   if not SubeVarmi then begin
      LblSube.Visible:=False;
      ComboSube.Visible:=False;
   end;
   if IslemOp = 'E' then
      TabKasalar.Append
   else
      ComboPersonel.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', TabKasalar.FieldByName('REHBERID').Value);
end;

procedure TKasaTanimWizardDlg.TabKasalarAfterPost(DataSet: TDataSet);
begin
  if islemOp='D' then
     Tablo.LogIslemleri(TabNo_KASA,TabKasalar.Fields[0].AsInteger, 4, TabKasalar);

  // if YeniKayit then  //Eğer yeni kayıtsa otomatik olarak 0 miktarlı açılış fişi oluştursun
  //    Tablo.KasaKaydet(2001,StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh)),0,'Açılış Fişi',
  //                  TabKasalar.FieldByName('ID').AsInteger, ComboKur.Text,'', 0,0,0,0,-1, -1,-1,-1,-1, SubeId,' ');

end;

procedure TKasaTanimWizardDlg.TabKasalarBeforeEdit(DataSet: TDataSet);
begin
if LogGun >0 then
   Tablo.OncekiLogBelirle(TabKasalar);
end;

procedure TKasaTanimWizardDlg.TabKasalarBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsKasalar);
  if not BoslukKontrol(EditKASAKODU.text, KTWKasaKodu) then Abort;
  if not BoslukKontrol(EditKASAADI.text, KTWKasaAdı) then Abort;
  if not BoslukKontrol(ComboKUR.text, KTWParaBirimi) then Abort;
  if comboPersonel.Visible then
    if not BoslukKontrol(comboPersonel.text, 'Personel Bilgisi Boş Bırakılamaz!') then Abort;
end;

procedure TKasaTanimWizardDlg.TabKasalarNewRecord(DataSet: TDataSet);
begin
   TabKasalar.FieldByName('KUR').AsString := CariDoviz;
   TabKasalar.FieldByName('DURUM').AsBoolean := True;//ComboDURUM.Items[0];
   TabKasalar.FieldByName('GUNLUKAKSIYONDAGOSTER').AsBoolean := True;
   EditKASAKODU.SetFocus;
   TabKasalar.FieldByName('KASAKODU').AsString := Tablo.KodBulmaSihirbazi(100, 'HESAPPLANI', 'HESAPKODU', 'HESAPADI', 'KASALAR', 'KASAKODU');
   TabKasalar.FieldByName('SUBEID').AsInteger := SubeId;
   TabKasalar.FieldByName('EKLEYEN').Value := Kullanan;
   TabKasalar.FieldByName('REHBERID').Value := 0;
   YeniKayit := True;
end;

procedure TKasaTanimWizardDlg.WizardKontrolCancelButtonClick(Sender: TObject);
begin
   TabKasalar.Cancel;
end;

procedure TKasaTanimWizardDlg.WizardKontrolFinishButtonClick(Sender: TObject);
begin
   if TabKasalar.State in [dsInsert, dsEdit] then begin
      TabKasalar.Post;
      KasaID := TabKasalar.Fields[0].asInteger;
   end;
   ModalResult := mrOk;
end;

end.

