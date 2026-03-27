unit UServisAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, DB,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, DateUtils,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinLiquidSky, dxCore, cxDateUtils,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TServisAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    CheckKapali: TcxCheckBox;
    AraMusteri: TcxButtonEdit;
    cxLabel22: TcxLabel;
    cxLabel1: TcxLabel;
    YenileTus: TSpeedButton;
    EditSerino: TcxTextEdit;
    AraKonusu: TcxComboBox;
    LabelSeriNo: TcxLabel;
    cxLabel3: TcxLabel;
    EditNo: TcxTextEdit;
    cxLabel4: TcxLabel;
    cxLabel6: TcxLabel;
    AraDurumu: TcxImageComboBox;
    editUrun: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditKategori: TcxButtonEdit;
    lbl6: TcxLabel;
    EditSorumlu: TcxButtonEdit;
    ComboTamamlanan: TcxImageComboBox;
    cbListe: TcxImageComboBox;
    cxLabel2: TcxLabel;
    PanelTarih: TPanel;
    AraTarihBas: TcxDateEdit;
    AraTarihBit: TcxDateEdit;
    cxLabel5: TcxLabel;
    cxLabel7: TcxLabel;
    procedure AraMusteriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxLabel7Click(Sender: TObject);
    procedure AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKategoriPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSorumluPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditSorumluKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckKapaliPropertiesChange(Sender: TObject);
    procedure ComboTamamlananPropertiesEditValueChanged(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
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
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses Utablo, PrjConst,LocOnFly, UKategori;
{ TServisAramaFrame }

procedure TServisAramaFrame.AraMusteriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TServisAramaFrame.AraMusteriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),-1,AButtonIndex,nil,'');
end;

procedure TServisAramaFrame.Baslatildi;
   procedure Ekle(Idx, Deger : Integer; Aciklama:String);
   begin
      //cbliste := TcxImageComboBoxProperties.Create(Self);
      cbListe.Properties.Items.Add;
      cbListe.Properties.Items[Idx].Value := Deger;
      cbListe.Properties.Items[Idx].Description := Aciklama;
   end;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   if Sektor = Sektor_OtomotivServis then
      LabelSeriNo.Caption := 'Plaka No';

   // 1:sadece kendi  5:departman 10:þube --100:tüm
   Tablo.TablodanSorguAc(2, 'select isnull((select BILGI from YETKIEK Y inner join ROLLER R on R.ID=Y.ROLID inner join KULLANICI K on R.ID=K.ROLID '+
                            ' WHERE Y.MODULID = 3001 and K.REHBERID='+Kullanan+'),0)');
   Ekle(0, 1, 'Aktif Servislerim');
   Ekle(1, 2, 'Ýlgili Olduklarým');
   if (TamYetkili)or(Tablo.Query2.Fields[0].AsInteger>1) then
      Ekle(2, 5, 'Depertman Servisleri');
   if (TamYetkili)or(Tablo.Query2.Fields[0].AsInteger>5) then
      Ekle(3, 8, 'Þube Servisleri');
   if (TamYetkili)or(Tablo.Query2.Fields[0].AsInteger>10) then
      Ekle(4, 9, 'Bütün Servisler');


   //EditSorumlu.Tag := StrToIntDef(GenRegIni.RegReadString('ServisOpsiyon', 'EditSorumluTag', '0', 'C'), 0);
   //EditSorumlu.Text := GenRegIni.RegReadString('ServisOpsiyon', 'EditSorumluText', '', 'C');
end;

procedure TServisAramaFrame.CheckKapaliPropertiesChange(Sender: TObject);
begin
  if ComboTamamlanan.ItemIndex = -1 then
     ComboTamamlanan.ItemIndex := 0;
  ComboTamamlanan.Visible := CheckKapali.Checked;
  if (PanelTarih.Visible)and(CheckKapali.Checked=False) then
     PanelTarih.Visible:=False;
end;

procedure TServisAramaFrame.ComboTamamlananPropertiesEditValueChanged(Sender: TObject);
begin
  PanelTarih.Visible := ComboTamamlanan.EditValue = 19000;
  AraTarihBit.Date := EndOfTheDay(Tablo.GENINI.BugunTrh);
  AraTarihBas.Date := AraTarihBit.Date-30;
end;

procedure TServisAramaFrame.cxLabel7Click(Sender: TObject);
begin
  EditNo.Text := '';
  AraDurumu.ItemIndex := -1;
  EditKategori.Tag := 0;
  EditKategori.Text :='';
  AraKonusu.Text := '';
  EditSerino.Text := '';
  editUrun.Text := '';
  AraMusteri.Text := '';
  CheckKapali.Checked := False;
end;

procedure TServisAramaFrame.EditKategoriPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if AButtonIndex = 0 then begin
     Application.CreateForm(TKategoriDlg, KategoriDlg);
     KategoriDlg.Cagiran:=2;
     KategoriDlg.StokKartinSubesi := SubeId;
     KategoriDlg.ShowModal;
     if KategoriDlg.ModalResult = mrOk then begin
        EditKategori.Tag := KategoriDlg.KATEGORI.fieldbyname('ID').asinteger;
        EditKategori.Text := KategoriDlg.KATEGORI.fieldbyname('AD').asstring;
     end;
     KategoriDlg.destroy;
  end else if AButtonIndex = 1 then begin
        EditKategori.Tag := 0;
        EditKategori.Text := '';
  end;
end;

procedure TServisAramaFrame.EditSorumluKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TServisAramaFrame.EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var  ID: Integer;
begin
  if AButtonIndex=0 then
    ID := Tablo.RehberAra_IDGetir(335);
  if ID>0 then begin
    EditSorumlu.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    EditSorumlu.Tag:=ID;
  end else begin
    EditSorumlu.Text:='';
    EditSorumlu.Tag:=0;
  end;

   //GenRegIni.RegWriteString('ServisOpsiyon', TcxButtonEdit(Sender).Name+'Tag',  IntToStr(TcxButtonEdit(Sender).Tag), 'C');
   //GenRegIni.RegWriteString('ServisOpsiyon', TcxButtonEdit(Sender).Name+'Text',  TcxButtonEdit(Sender).Text, 'C');
end;

procedure TServisAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TServisAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TServisAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TServisAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TServisAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TServisAramaFrame.Gorunmez;
begin

end;

procedure TServisAramaFrame.GorunmezOlacak;
begin

end;

procedure TServisAramaFrame.Gorunur;
begin

end;

procedure TServisAramaFrame.GorunurOlacak;
begin

end;

procedure TServisAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TServisAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TServisAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TServisAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TServisAramaFrame);
end.


