unit UServisDetayPersonel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxTextEdit, cxButtonEdit, cxMaskEdit, cxDropDownEdit, cxCalendar,
  cxDBEdit, ComCtrls, ToolWin, cxControls, cxContainer, cxEdit, cxLabel,
  cxSpinEdit, cxCheckBox, FireDAC.Comp.Client, DB, cxTimeEdit, cxPC, cxGraphics,
  cxImageComboBox, cxTrackBar, cxDBTrackBar,DateUtils, dxSkinsCore,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TServisDetayPersonelDlg = class(TForm)
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    ToolBarProblem: TToolBar;
    BtnProblemKaydet: TToolButton;
    BtnProblemIptal: TToolButton;
    BEPersonel: TcxButtonEdit;
    cxLabel6: TcxLabel;
    CheckTamamlanma: TcxDBCheckBox;
    SpinPuan: TcxDBSpinEdit;
    EditAciklama: TcxDBTextEdit;
    cxLabel5: TcxLabel;
    BEKod: TcxDBButtonEdit;
    cxLabel8: TcxLabel;
    EditAd: TcxDBTextEdit;
    LabelSureFarki: TcxLabel;
    cxLabel7: TcxLabel;
    SpinSure: TcxDBSpinEdit;
    ComboSUREBIRIMI: TcxDBImageComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    DateBasTar: TcxDBDateEdit;
    DateBitTar: TcxDBDateEdit;
    CbBasSaat: TcxComboBox;
    CbBasDk: TcxComboBox;
    CbBitSaat: TcxComboBox;
    CbBitDk: TcxComboBox;
    procedure BEPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnProblemIptalClick(Sender: TObject);
    procedure BtnProblemKaydetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BEKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DateBasTarPropertiesEditValueChanged(Sender: TObject);
    procedure DateBitTarPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboSUREBIRIMIPropertiesEditValueChanged(Sender: TObject);
    procedure ComboSUREBIRIMIPropertiesCloseUp(Sender: TObject);
    procedure CbBasSaatPropertiesEditValueChanged(Sender: TObject);
    procedure CbBitSaatPropertiesEditValueChanged(Sender: TObject);
  private
    procedure SUREChange(Sender: TField);
    procedure BITTARChange(Sender: TField);
    procedure BASTARChange(Sender: TField);
    procedure SUREBIRIMIChange(Sender: TField);
    procedure CombolariAyarla(TarihAlani: TField);
    function BiriminDakikaKarsiligi(Birim: Integer): Integer;
    { Private declarations }
  public
    TempDts:TDataSource;
    Sablon:Boolean;
    { Public declarations }

  end;

var
  ServisDetayPersonelDlg: TServisDetayPersonelDlg;

implementation

uses Utablo,PrjConst,LocOnFly, Math;

{$R *.dfm}

procedure TServisDetayPersonelDlg.BtnProblemIptalClick(Sender: TObject);
begin
    if (TempDts.DataSet as TFDQuery).State in [dsEdit,dsInsert] then begin
    DateBasTar.Properties.OnEditValueChanged := nil;
    DateBitTar.Properties.OnEditValueChanged := nil;
    (TempDts.DataSet as TFDQuery).FieldByName('SURE').OnChange := nil;
    (TempDts.DataSet as TFDQuery).FieldByName('SUREBIRIMI').OnChange := nil;
    (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').OnChange := nil;
    (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').OnChange := nil;
    CbBitSaat.Properties.OnEditValueChanged := nil;
    CbBitDk.Properties.OnEditValueChanged := nil;
    CbBasSaat.Properties.OnEditValueChanged := nil;
    CbBasDk.Properties.OnEditValueChanged := nil;
    (TempDts.DataSet as TFDQuery).Cancel;
  end;
  ModalResult := mrCancel;
end;

procedure TServisDetayPersonelDlg.BtnProblemKaydetClick(Sender: TObject);
begin
  if (EditAd.Text='')and(TempDts.Name='DtsServisIslemDetay') then begin
    ShowMessage(SERAd_Gir);
  end else begin
    (TempDts.DataSet as TFDQuery).Post;
    ModalResult := mrOk;
  end;
end;

procedure TServisDetayPersonelDlg.ComboSUREBIRIMIPropertiesCloseUp(
  Sender: TObject);
begin
  ComboSUREBIRIMI.PostEditValue;
end;

procedure TServisDetayPersonelDlg.ComboSUREBIRIMIPropertiesEditValueChanged(
  Sender: TObject);
begin
  case ComboSUREBIRIMI.EditValue of
    10:begin //dakika
         SpinSure.Properties.MaxValue := 60;
       end;
    11:begin //saat
         SpinSure.Properties.MaxValue := 24;
       end;
    12:begin //gün
         SpinSure.Properties.MaxValue := 360;
       end;
  end;
end;

procedure TServisDetayPersonelDlg.DateBasTarPropertiesEditValueChanged(
  Sender: TObject);
var Sure:Integer;
begin


  if (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').Value = Null then
    if ((TempDts.DataSet as TFDQuery).FieldByName('SURE').AsString<>'')
    and((TempDts.DataSet as TFDQuery).FieldByName('SUREBIRIMI').AsString<>'')
    then begin

       (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime :=DateBasTar.EditValue+
                   ((TempDts.DataSet as TFDQuery).FieldByName('SURE').AsInteger*BiriminDakikaKarsiligi((TempDts.DataSet as TFDQuery).FieldByName('SUREBIRIMI').AsInteger) /1440);
    end;
  if ((TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsString<>'') And ((TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsString<>'') then begin
    Tablo.TablodanSorguAc(6,'select dbo.fn_TarihFarkiGunAyYilSaatDakikaTextOlarak('''+formatdatetime('YYYY-MM-DD HH:NN',DateBasTar.Date)+''','''+formatdatetime('YYYY-MM-DD HH:NN',DateBitTar.Date)+''')');
    LabelSureFarki.Caption := StringReplace(Tablo.Query6.Fields[0].AsString,'var','',[rfReplaceAll]);
  end;


end;
procedure TServisDetayPersonelDlg.DateBitTarPropertiesEditValueChanged(
  Sender: TObject);
begin
  if (DateBasTar.EditValue>0) And (DateBasTar.EditValue>0) then begin
    Tablo.TablodanSorguAc(6,'select dbo.fn_TarihFarkiGunAyYilSaatDakikaTextOlarak('''+formatdatetime('YYYY-MM-DD HH:NN',DateBasTar.Date)+''','''+formatdatetime('YYYY-MM-DD HH:NN',DateBitTar.Date)+''')');
    LabelSureFarki.Caption := StringReplace(Tablo.Query6.Fields[0].AsString,'var','',[rfReplaceAll]);
  end;
end;

procedure TServisDetayPersonelDlg.BEKodPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  SQLText:string;
  st:TStringList;
begin
  SQLText := 'select KOD,AD from SERVISDETAYPERSONEL SD where isnull(SERVISID,0)<=0 and TUR='
        +TempDts.DataSet.FieldByName('TUR').AsString+' and URUNID='
        +TempDts.DataSet.FieldByName('URUNID').AsString;
  st:=TStringList.Create;
  if Tablo.ListedenBilgiGetir('Detay Listesi',SqlText,st,[]) then begin
    TempDts.DataSet.FieldByName('KOD').AsString:=St[0];
    TempDts.DataSet.FieldByName('AD').AsString:=St[1];
  end;
  st.Free;
end;

procedure TServisDetayPersonelDlg.BEPersonelPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  PersonelID:Integer;
begin
  PersonelID := Tablo.RehberAra_IDGetir(335);
  if PersonelID>0 then begin
    BEPersonel.Tag := PersonelID;
    TempDts.DataSet.FieldByName('PERSONELREHBERID').AsInteger := PersonelID;
    BEPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',PersonelID);
  end;
end;

procedure TServisDetayPersonelDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Sablon:=False;
end;

procedure TServisDetayPersonelDlg.FormShow(Sender: TObject);
var TarihAlani:TField;
begin
  TarihAlani:=(TempDts.DataSet as TFDQuery).FieldByName('BASTAR');
  TarihAlani:=(TempDts.DataSet as TFDQuery).FieldByName('BITTAR');


  DateBasTar.DataBinding.DataSource := TempDts;
  DateBitTar.DataBinding.DataSource := TempDts;
  EditAciklama.DataBinding.DataSource := TempDts;
  SpinPuan.DataBinding.DataSource := TempDts;
  CheckTamamlanma.DataBinding.DataSource := TempDts;
  EditAd.DataBinding.DataSource := TempDts;
  BEKod.DataBinding.DataSource := TempDts;
  SpinSure.DataBinding.DataSource := TempDts;
  ComboSUREBIRIMI.DataBinding.DataSource := TempDts;
  if(StrToIntDef(VarToStrDef(TempDts.DataSet.FieldByName('PERSONELREHBERID').Value,'0'),0)<1)and(BEPersonel.Visible=True)then begin
    BEPersonelPropertiesButtonClick(Self,0);
  end else
    BEPersonel.Text := Tablo.AciklamaGetir('REHBER','FIRMA',TempDts.DataSet.FieldByName('PERSONELREHBERID').Value);
  if TempDts.DataSet.FieldByName('SUREBIRIMI').AsString='' then
    TempDts.DataSet.FieldByName('SUREBIRIMI').AsInteger := 11;
  if Sablon then begin
    EditAd.Properties.ReadOnly := False;
    if ((TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsString<>'') And ((TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsString<>'') then begin
      Tablo.TablodanSorguAc(6,'select dbo.fn_TarihFarkiGunAyYilSaatDakikaTextOlarak('''+formatdatetime('YYYY-mm-DD HH:NN',DateBasTar.Date)+''','''+formatdatetime('YYYY-mm-DD HH:NN',DateBitTar.Date)+''')');
      LabelSureFarki.Caption := StringReplace(Tablo.Query6.Fields[0].AsString,'var','',[rfReplaceAll]);
    end;
  end else begin
    EditAd.Properties.ReadOnly := True;
    DateBasTar.Properties.OnEditValueChanged := DateBasTarPropertiesEditValueChanged;
    DateBitTar.Properties.OnEditValueChanged := DateBitTarPropertiesEditValueChanged;
    (TempDts.DataSet as TFDQuery).FieldByName('SURE').OnChange := SUREChange;
    (TempDts.DataSet as TFDQuery).FieldByName('SUREBIRIMI').OnChange := SUREBIRIMIChange;
    (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').OnChange := BITTARChange;
    (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').OnChange := BASTARChange;
    CbBitSaat.Properties.OnEditValueChanged := CbBitSaatPropertiesEditValueChanged;
    CbBitDk.Properties.OnEditValueChanged := CbBitSaatPropertiesEditValueChanged;
    CbBasSaat.Properties.OnEditValueChanged := CbBasSaatPropertiesEditValueChanged;
    CbBasDk.Properties.OnEditValueChanged := CbBasSaatPropertiesEditValueChanged;
    if (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsString='' then
       (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsDateTime:=Tablo.GENINI.BugunTrhSaat;
    if (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsString='' then
       (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime:=Tablo.GENINI.BugunTrhSaat;
  TarihAlani:=(TempDts.DataSet as TFDQuery).FieldByName('BASTAR');
  TarihAlani:=(TempDts.DataSet as TFDQuery).FieldByName('BITTAR');
    CombolariAyarla((TempDts.DataSet as TFDQuery).FieldByName('BASTAR'));
    CombolariAyarla((TempDts.DataSet as TFDQuery).FieldByName('BITTAR'));
    DateBitTarPropertiesEditValueChanged(Self);
  end;
end;

function TServisDetayPersonelDlg.BiriminDakikaKarsiligi(Birim:Integer):Integer;
Begin
  case Birim of
    10:Result:=1;
    11:Result:=60;
    12:Result:=1440;
  else
    Result:=0
  end;
End;

procedure TServisDetayPersonelDlg.SUREChange(Sender: TField);
var Qry:TFDQuery;
begin
  Qry:=TempDts.DataSet as TFDQuery;
  if (Qry.FieldByName('BASTAR').AsString<>'')and(Qry.FieldByName('SUREBIRIMI').AsString<>'') then begin
    Qry.FieldByName('BITTAR').OnChange := Nil;
    Qry.FieldByName('BITTAR').AsDateTime := IncMinute(Qry.FieldByName('BASTAR').AsDateTime,Qry.FieldByName('SURE').Value*BiriminDakikaKarsiligi(Qry.FieldByName('SUREBIRIMI').AsInteger));
    Qry.FieldByName('BITTAR').OnChange := BITTARChange;
    CombolariAyarla(Qry.FieldByName('BITTAR'));
  end;
end;

procedure TServisDetayPersonelDlg.SUREBIRIMIChange(Sender: TField);
var Qry:TFDQuery;
begin
  Qry:=TempDts.DataSet as TFDQuery;
  if (Qry.FieldByName('BASTAR').AsString<>'')and(Qry.FieldByName('BITTAR').AsString<>'')and(Qry.FieldByName('SUREBIRIMI').AsString<>'') then begin
    Qry.FieldByName('SURE').Value := 0;
  end;
end;

procedure TServisDetayPersonelDlg.BASTARChange(Sender: TField);
var Qry:TFDQuery;
begin
  CombolariAyarla(Sender);
  Qry:=TempDts.DataSet as TFDQuery;
  if (Qry.FieldByName('BASTAR').AsString<>'')and(Qry.FieldByName('BITTAR').AsString<>'')and(Qry.FieldByName('SUREBIRIMI').AsString<>'') then begin
    Qry.FieldByName('BITTAR').OnChange := Nil;
    Qry.FieldByName('BITTAR').Value := IncMinute(Qry.FieldByName('BASTAR').AsDateTime,Qry.FieldByName('SURE').Value*BiriminDakikaKarsiligi(Qry.FieldByName('SUREBIRIMI').AsInteger));//MinuteSpan(Qry.FieldByName('BASTAR').AsDateTime,Qry.FieldByName('BITTAR').AsDateTime)/Qry.FieldByName('SUREBIRIMI').Value;
    Qry.FieldByName('BITTAR').OnChange := BITTARChange;
    CombolariAyarla(Qry.FieldByName('BITTAR'));
  end;
end;

procedure TServisDetayPersonelDlg.BITTARChange(Sender: TField);
var Qry:TFDQuery;
    BasTar, BitTar : TDateTime;
begin
  CombolariAyarla(Sender);
  Qry:=TempDts.DataSet as TFDQuery;
  if (Qry.FieldByName('BASTAR').AsString<>'')and(Qry.FieldByName('BITTAR').AsString<>'')and(Qry.FieldByName('SUREBIRIMI').AsString<>'') then begin
    if Qry.FieldByName('BASTAR').Value>Qry.FieldByName('BITTAR').Value then begin
      ShowMessage(SERYanlis_tarih);
      Qry.FieldByName('BITTAR').OnChange := Nil;
      Qry.FieldByName('BITTAR').Value := IncMinute(Qry.FieldByName('BASTAR').AsDateTime,Qry.FieldByName('SURE').Value*BiriminDakikaKarsiligi(Qry.FieldByName('SUREBIRIMI').AsInteger));
      Qry.FieldByName('BITTAR').OnChange := BITTARChange;
    end else begin
      Qry.FieldByName('SURE').OnChange := Nil;
      BasTar := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yy hh:nn', Qry.FieldByName('BASTAR').AsDateTime));
      BitTar := StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yy hh:nn', Qry.FieldByName('BITTAR').AsDateTime));
      Qry.FieldByName('SURE').Value := StrToFloatDef(FormatFloat('0.##', MinuteSpan(BasTar, BitTar)/BiriminDakikaKarsiligi(Qry.FieldByName('SUREBIRIMI').AsInteger)),1);
      Qry.FieldByName('SURE').OnChange := SUREChange;
    end;
  end;
end;

procedure TServisDetayPersonelDlg.CbBasSaatPropertiesEditValueChanged(
  Sender: TObject);
begin
  if Sender=CbBasSaat then
    (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsDateTime := RecodeHour((TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsDateTime,CbBasSaat.EditValue)
  else if Sender=CbBasDk then
    (TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsDateTime := RecodeMinute((TempDts.DataSet as TFDQuery).FieldByName('BASTAR').AsDateTime,CbBasDk.EditValue);
end;

procedure TServisDetayPersonelDlg.CbBitSaatPropertiesEditValueChanged(
  Sender: TObject);
begin
  if Sender=CbBitSaat then
    (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime := RecodeHour((TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime,CbBitSaat.EditValue)
  else if Sender=CbBitDk then
    (TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime := RecodeMinute((TempDts.DataSet as TFDQuery).FieldByName('BITTAR').AsDateTime,CbBitDk.EditValue);
end;

procedure TServisDetayPersonelDlg.CombolariAyarla(TarihAlani:TField);
var Qry:TFDQuery;
begin
  Qry:=TempDts.DataSet as TFDQuery;
  if (TarihAlani=Qry.FieldByName('BASTAR'))and(CbBasSaat<>nil) then begin
    CbBasSaat.Properties.OnEditValueChanged := nil;
    CbBasDk.Properties.OnEditValueChanged := nil;
    CbBasSaat.EditValue := HourOf(Qry.FieldByName('BASTAR').AsDateTime);
    CbBasDk.EditValue := MinuteOf(Qry.FieldByName('BASTAR').AsDateTime);
    CbBasSaat.Properties.OnEditValueChanged := CbBasSaatPropertiesEditValueChanged;
    CbBasDk.Properties.OnEditValueChanged := CbBasSaatPropertiesEditValueChanged;
  end else if (TarihAlani=Qry.FieldByName('BITTAR'))and(CbBitSaat<>nil) then begin
    CbBitSaat.Properties.OnEditValueChanged := nil;
    CbBitDk.Properties.OnEditValueChanged := nil;
    CbBitSaat.EditValue := HourOf(Qry.FieldByName('BITTAR').AsDateTime);
    CbBitDk.EditValue := MinuteOf(Qry.FieldByName('BITTAR').AsDateTime);
    CbBitSaat.Properties.OnEditValueChanged := CbBitSaatPropertiesEditValueChanged;
    CbBitDk.Properties.OnEditValueChanged := CbBitSaatPropertiesEditValueChanged;
  end;
end;

end.

