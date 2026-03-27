unit UParaDegisiklik;
  //giren tutar bizim kullandýðýmýz para birimi olup çýkan tutar onun döviz karþýlýðýdýr..
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  cxGraphics, cxMaskEdit, cxDropDownEdit, cxControls,
  cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit, StdCtrls, ExtCtrls,Fetautil,
  JvExExtCtrls, JvExtComponent, JvPanel, cxLabel, DB, cxDBEdit, Math,
  cxLookAndFeelPainters, cxGroupBox, cxRadioGroup, dxSkinLondonLiquidSky,
  cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray;

type
  TParaDegisiklikDlg = class(TForm)
    AltPanel: TJvPanel;
    iptalButton: TButton;
    tamamButton: TButton;
    UstPanel: TJvPanel;
    Label1: TLabel;
    BaslikLabel: TLabel;
    JvPanel1: TJvPanel;
    cxRadioGroup1: TcxRadioGroup;
    EditKulKur: TcxCurrencyEdit;
    cxLabel2: TcxLabel;
    PanelTutar: TPanel;
    LabelKur: TcxLabel;
    LabelTutar: TcxLabel;
    EditTutar: TcxCurrencyEdit;
    ComboKur: TcxComboBox;
    EditDovTutar: TcxCurrencyEdit;
    ComboDovKur: TcxComboBox;
    cxLabel1: TcxLabel;
    LabelDovizTuru: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure LabelDovizTuruClick(Sender: TObject);
    procedure tamamButtonClick(Sender: TObject);
    procedure ADOQuery1BeforePost(DataSet: TDataSet);
    procedure DovizKuruHesapla;
    procedure cxRadioGroup1PropertiesChange(Sender: TObject);
    procedure ComboDovKurPropertiesCloseUp(Sender: TObject);
    procedure ComboKurPropertiesEditValueChanged(Sender: TObject);
    procedure ComboDovKurPropertiesEditValueChanged(Sender: TObject);
    procedure EditKulKurPropertiesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function GoruntuDuzenle(AKur: Extended): Extended;
    { Private declarations }
  public
  TabloAdi,TutarAlan:string;
  ID:Integer;
  GirenKur, CikanKur : string;
  GirenTutar, CikanTutar : Extended;
  KurTarihi : TDateTime;
    { Public declarations }
  end;

var
  ParaDegisiklikDlg: TParaDegisiklikDlg;

implementation

uses Utablo,PrjConst,FetaKurulusSiniflari,FetaClassExtensions,LocOnFly;

{$R *.dfm}

procedure TParaDegisiklikDlg.LabelDovizTuruClick(Sender: TObject);
begin
  if LabelDovizTuru.Tag=0 then begin
     cxLabel1.Visible:=True;
     EditDovTutar.Visible:=True;
     ComboDovKur.Visible:=True;
     LabelDovizTuru.Tag:=1;
     ComboKur.Enabled:=False;
     EditTutar.Enabled:=False;
     cxRadioGroup1.visible:=True;
     cxLabel2.visible:=True;
     EditKulKur.visible:=True;
     cxRadioGroup1.Reset;
  end else begin
     cxLabel1.Visible:=False;
     EditDovTutar.Visible:=False;
     ComboDovKur.Visible:=False;
     LabelDovizTuru.Tag:=0;
     ComboKur.Enabled:=True;
     EditTutar.Enabled:=True;
     ComboDovKur.Text := '';
     EditDovTutar.Text:='';
     cxRadioGroup1.visible:=False;
     cxLabel2.visible:=False;
     EditKulKur.visible:=False;
  end;
  if ComboKur.Text = '' then begin
     ComboDovKur.Text := CariDoviz;
     ComboDovKur.EditValue := CariDoviz;
     DovizKuruHesapla;
  end;
end;

procedure TParaDegisiklikDlg.ADOQuery1BeforePost(DataSet: TDataSet);
begin
  if EditDovTutar.text='' then
     EditDovTutar.EditValue:=0;
  if ComboDovKur.visible = False then
     ComboDovKur.EditValue:='';
  if EditDovTutar.Visible=false then
     EditDovTutar.EditValue:=0;
end;

procedure TParaDegisiklikDlg.ComboDovKurPropertiesCloseUp(Sender: TObject);
begin
  DovizKuruHesapla;
  cxRadioGroup1PropertiesChange(Self);
  EditKulKurPropertiesChange(self);
end;

procedure TParaDegisiklikDlg.ComboDovKurPropertiesEditValueChanged(
  Sender: TObject);
begin
  EditDovTutar.Enabled := ComboDovKur.Text<>'';
  cxRadioGroup1.Enabled := ComboDovKur.Text<>'';
  EditKulKur.Enabled := ComboDovKur.Text<>'';
end;

procedure TParaDegisiklikDlg.ComboKurPropertiesEditValueChanged(Sender: TObject);
Var I:Integer;
begin
  ComboDovKur.Properties.Items.Clear;
  for I := 0 to ComboKur.Properties.Items.Count - 1 do Begin
      if ComboKur.Properties.Items[I]<>ComboKur.text then
         ComboDovKur.Properties.Items.add(ComboKur.Properties.Items[I]);
  End;
  //LabelDovizTuruClick(Self);
end;

procedure TParaDegisiklikDlg.cxRadioGroup1PropertiesChange(Sender: TObject);
begin
  cxRadioGroup1.Enabled := cxRadioGroup1.Properties.Items[1].Value <> Null;
  if cxRadioGroup1.ItemIndex>=0 then begin
     EditKulKur.value := GoruntuDuzenle(cxRadioGroup1.Properties.Items[cxRadioGroup1.ItemIndex].Value);
     EditKulKur.Hint := FExtToStr(cxRadioGroup1.Properties.Items[cxRadioGroup1.ItemIndex].Value);
  end;
end;

function TParaDegisiklikDlg.GoruntuDuzenle(AKur:Extended):Extended;
begin
  if ComboKur.Text = CariDoviz then
    Result := 1/AKur
  else
    Result := AKur;
  {if AKur>1 then
    Result := AKur
  else if AKur>0 then
    Result := 1/AKur
  else
    Result := 0; }
end;

procedure TParaDegisiklikDlg.DovizKuruHesapla;
var
  alis,satis,efal,efsat:Extended;
Begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:='SELECT TOP 1 FARK=ABS(DATEDIFF(HOUR,GETDATE(),TARIH)),* from DOVIZ where CINSI = '''+ComboKur.Text+''' order by 1';
    Tablo.Query1.Open;
    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text:='SELECT TOP 1 FARK=ABS(DATEDIFF(HOUR,GETDATE(),TARIH)),* from DOVIZ where CINSI = '''+ComboDovKur.Text+''' order by 1';
    Tablo.Query2.Open;
  if Tablo.Query1.RecordCount=0 then  Begin
    if Tablo.Query2.RecordCount=0 then  Begin
      //raise Exception.Create('Ýþleminize devam edebilmek için lütfen bir kur seçiniz!');
    End Else if Tablo.Query2.RecordCount=1 then begin
      cxRadioGroup1.Caption:='1'+Tablo.Query2.FieldByName('CINSI').AsString+' = ...TL' ;
      alis:= Tablo.Query2.FieldByName('ALIS').AsFloat ;
      satis:= Tablo.Query2.FieldByName('SATIS').AsFloat ;
      efal:= Tablo.Query2.FieldByName('EFALIS').AsFloat ;
      efsat:= Tablo.Query2.FieldByName('EFSATIS').AsFloat ;
    end;
  End Else if Tablo.Query1.RecordCount=1 then begin
    if Tablo.Query2.RecordCount=0 then  Begin
      cxRadioGroup1.Caption:='1'+Tablo.Query1.FieldByName('CINSI').AsString+' = ...TL';
      alis:= (Tablo.Query1.FieldByName('ALIS').AsFloat) ;
      satis:= (Tablo.Query1.FieldByName('SATIS').AsFloat) ;
      efal:= (Tablo.Query1.FieldByName('EFALIS').AsFloat) ;
      efsat:= (Tablo.Query1.FieldByName('EFSATIS').AsFloat) ;
    End Else if Tablo.Query2.RecordCount=1 then begin
      cxRadioGroup1.Caption:='1'+Tablo.Query1.FieldByName('CINSI').AsString+' = ...'+Tablo.Query2.FieldByName('CINSI').AsString  ;
      alis:= (Tablo.Query1.FieldByName('ALIS').AsFloat)/(Tablo.Query2.FieldByName('ALIS').AsFloat) ;
      satis:= (Tablo.Query1.FieldByName('SATIS').AsFloat)/(Tablo.Query2.FieldByName('SATIS').AsFloat) ;
      efal:= (Tablo.Query1.FieldByName('EFALIS').AsFloat)/(Tablo.Query2.FieldByName('EFALIS').AsFloat) ;
      efsat:= (Tablo.Query1.FieldByName('EFSATIS').AsFloat)/(Tablo.Query2.FieldByName('EFSATIS').AsFloat) ;
    end;
  end;
  cxRadioGroup1.Properties.Items[0].Caption:= NDAlis+ FExtToStr(GoruntuDuzenle(alis),4);
  cxRadioGroup1.Properties.Items[0].Value:= alis;
  cxRadioGroup1.Properties.Items[1].Caption:= NDSatis+ FExtToStr(GoruntuDuzenle(satis),4);
  cxRadioGroup1.Properties.Items[1].Value:= satis;
  cxRadioGroup1.Properties.Items[2].Caption:= NDEfAlis+ FExtToStr(GoruntuDuzenle(efal),4);
  cxRadioGroup1.Properties.Items[2].Value:= efal;
  cxRadioGroup1.Properties.Items[3].Caption:= NDEfSatis+ FExtToStr(GoruntuDuzenle(efsat),4);
  cxRadioGroup1.Properties.Items[3].Value:= efsat;
End;

procedure TParaDegisiklikDlg.EditKulKurPropertiesChange(Sender: TObject);
begin
    if ComboKur.Text=CariDoviz then begin
      EditDovTutar.EditValue:= EditTutar.EditValue/EditKulKur.Value;
      EditKulKur.Hint := FExtToStr(1/EditKulKur.Value);
    end else begin
      EditDovTutar.EditValue:= EditTutar.EditValue*EditKulKur.Value;   //??
      EditKulKur.Hint := FExtToStr(EditKulKur.Value);
    end;
    CikanTutar := EditDovTutar.EditValue;

end;

procedure TParaDegisiklikDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
end;

procedure TParaDegisiklikDlg.FormShow(Sender: TObject);
begin
  ComboKur.Text := GirenKur;
  EditTutar.EditValue := GirenTutar;
  EditTutar.PostEditValue;
  ComboDovKur.Text := CikanKur;
  EditDovTutar.EditValue := CikanTutar;
  EditDovTutar.PostEditValue;
  //daha önce döviz girilmiþse göster...
  //if CikanTutar > 0 then begin
     LabelDovizTuru.Tag:=0;
     LabelDovizTuruClick(Self);
  //end;
  ComboDovKurPropertiesEditValueChanged(Self);
  if (ComboDovKur.Visible=True) and (ComboDovKur.ItemIndex > -1) then
     ComboDovKurPropertiesCloseUp(Self);
  cxRadioGroup1.Enabled := cxRadioGroup1.Properties.Items[1].Value <> Null;

end;

procedure TParaDegisiklikDlg.tamamButtonClick(Sender: TObject);
begin
  GirenTutar := EditTutar.Value;
  GirenKur := ComboKur.Text;
  if ComboDovKur.Visible = False then  begin
     CikanKur := GirenKur;
     CikanTutar := GirenTutar;
  end else begin
     CikanKur := ComboDovKur.Text;
     CikanTutar := EditDovTutar.Value;
  end;
end;

end.

