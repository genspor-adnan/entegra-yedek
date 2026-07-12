unit UHizliGirisIsk;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit,
  cxTextEdit, cxCurrencyEdit, JvExControls, JvButton, JvNavigationPane, cxLabel,
  Utablo, StdCtrls, cxRadioGroup,FetaKurulusSiniflari,Fetautil, ExtCtrls, Menus,
  cxLookAndFeelPainters, cxButtons, cxGraphics, cxLookAndFeels, Vcl.ComCtrls, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue;

type
  THizliGirisIsk = class(TForm)
    Panel1: TPanel;
    BtnNum1: TJvNavPanelButton;
    BtnNum8: TJvNavPanelButton;
    BtnNum7: TJvNavPanelButton;
    BtnNum6: TJvNavPanelButton;
    BtnNum4: TJvNavPanelButton;
    BtnNum5: TJvNavPanelButton;
    BtnNum2: TJvNavPanelButton;
    BtnNum3: TJvNavPanelButton;
    BtnNum9: TJvNavPanelButton;
    BtnNum0: TJvNavPanelButton;
    BtnNumComma: TJvNavPanelButton;
    BtnNumEnter: TJvNavPanelButton;
    BtnNumMinus: TJvNavPanelButton;
    BtnNumPlus: TJvNavPanelButton;
    BtnNumx: TJvNavPanelButton;
    BtnNumSls: TJvNavPanelButton;
    BtnNumBspc: TJvNavPanelButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Editadet: TcxTextEdit;
    LabelAdet: TcxLabel;
    LabelAdet2: TcxLabel;
    Editadet2: TcxTextEdit;
    EditTutar: TcxCurrencyEdit;
    LabelKur: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    EditYuzde: TcxCurrencyEdit;
    cxLabel4: TcxLabel;
    EditIskontosuz: TcxCurrencyEdit;
    EditIskonto: TcxCurrencyEdit;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    EditFiyat: TcxCurrencyEdit;
    LabelPBirimi: TcxLabel;
    cxLabel7: TcxLabel;
    LabelUrunKod: TcxLabel;
    cxLabel8: TcxLabel;
    LabelUrunAd: TcxLabel;
    LabelKdvsiz: TcxLabel;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    procedure BtnNumSlsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure YuzdeIskontoHesapla;
    procedure TutarIskontoHesapla;
    procedure EditTutarPropertiesEditValueChanged(Sender: TObject);
    procedure EditYuzdePropertiesEditValueChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditadetKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Editadet2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditYuzdeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditTutarKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cxCurrencyEdit1PropertiesEditValueChanged(Sender: TObject);
    procedure EditFiyatKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure KapatTusClick(Sender: TObject);


  private
    TusBasili:Boolean;
    EnterSay:Integer;
    Birim2Miktar:Real;
    { Private declarations }
  public
    { Public declarations }
    Cagiran,UrunId,Anabirim,KDVOrani :Integer; //1:İskonto  2:Adet
    Stokmu,YazilacakKDVDurum:Boolean;
  end;

var
  HizliGirisIsk: THizliGirisIsk;

   function AdetGetir(Baslik,Miktar : string; UrunId, Anabirim :Integer;Stokmu:boolean ):Real;

implementation
Uses UVeriMotor, UHizliGiris, UHizliGirisAnaMenu,prjconst,LocOnFly;
{$R *.dfm}

function AdetGetir(Baslik,Miktar : string; UrunId, Anabirim :Integer;Stokmu:boolean ):Real;
begin
    Application.CreateForm(THizliGirisIsk, HizliGirisIsk);
    HizliGirisIsk.Caption := Baslik;
    HizliGirisIsk.Cagiran := 0;
    HizliGirisIsk.Editadet.Text := Miktar;
    HizliGirisIsk.UrunId:= UrunId;
    HizliGirisIsk.Anabirim := Anabirim;//Anabirim ör:adet için 51 yazılır procedurede adet diye başlığayazılır
    HizliGirisIsk.Stokmu := Stokmu;
    HizliGirisIsk.ShowModal;
    if (HizliGirisIsk.ModalResult = mrOk)and(HizliGirisIsk.Editadet.Text<>'') then
        Result := StrToFloatDef(HizliGirisIsk.Editadet.Text,1)
    else
        Result := -9999;
    FreeAndNil(HizliGirisIsk);
end;


procedure THizliGirisIsk.BtnNumSlsClick(Sender: TObject);
begin
  if (Sender as TJvNavPanelButton).Caption = 'Ent' then
      ModalResult := mrOk
  else if not TusBasili then begin
    //(Sender as TJvNavPanelButton).Down := True;
    if (Sender as TJvNavPanelButton).Tag=55 then begin //geri tuşu
      if EditYuzde.Focused then
        if EditYuzde.SelLength>0 then
          EditYuzde.ClearSelection
        else
          EditYuzde.Text := Copy(EditYuzde.Text,1,Length(EditYuzde.Text)-1)
      else if EditTutar.Focused then
        if EditTutar.SelLength>0 then
          EditTutar.ClearSelection
        else
          EditTutar.Text := Copy(EditTutar.Text,1,Length(EditTutar.Text)-1)
      else if Editadet.Focused then
        if Editadet.SelLength>0 then
          Editadet.ClearSelection
        else
          Editadet.Text := Copy(Editadet.Text,1,Length(Editadet.Text)-1)
      else if Editadet2.Focused then
        if Editadet2.SelLength>0 then
          Editadet2.ClearSelection
        else
          Editadet2.Text := Copy(Editadet2.Text,1,Length(Editadet2.Text)-1)
      else if EditFiyat.Focused then
        if EditFiyat.SelLength>0 then
          EditFiyat.ClearSelection
        else
          EditFiyat.Text := Copy(EditFiyat.Text,1,Length(EditFiyat.Text)-1);
    end else begin
      if EditYuzde.Focused then begin
        EditYuzde.ClearSelection;
        EditYuzde.Text := EditYuzde.Text+(Sender as TJvNavPanelButton).Caption;
      end else if EditTutar.Focused then begin
        EditTutar.ClearSelection;
        EditTutar.Text := EditTutar.Text+(Sender as TJvNavPanelButton).Caption;
      end else if Editadet.Focused then begin
        Editadet.ClearSelection;
        Editadet.Text := Editadet.Text+(Sender as TJvNavPanelButton).Caption;
      end
      else if Editadet2.Focused then begin
        Editadet2.ClearSelection;
        Editadet2.Text := Editadet2.Text+(Sender as TJvNavPanelButton).Caption;
      end
      else if EditFiyat.Focused then begin
        EditFiyat.ClearSelection;
        EditFiyat.Text := EditFiyat.Text+(Sender as TJvNavPanelButton).Caption;
      end;
    end;
    if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      EnterSay:=0;
      if EditYuzde.Focused then begin
        EditYuzde.SetFocus;
        EditYuzde.SelStart:= Length(EditYuzde.Text);
        EditYuzde.PostEditValue;
      end else if EditTutar.Focused then begin
        EditTutar.SetFocus;
        EditTutar.SelStart:= Length(EditTutar.Text);
        EditTutar.PostEditValue;
      end else if Editadet.Focused then begin
        Editadet.SetFocus;
        Editadet.SelStart:= Length(Editadet.Text);
        Editadet.PostEditValue;
      end else if Editadet2.Focused then begin
        Editadet2.SetFocus;
        Editadet2.SelStart:= Length(Editadet2.Text);
        Editadet2.PostEditValue;
      end else if EditFiyat.Focused then begin
        EditFiyat.SetFocus;
        EditFiyat.SelStart:= Length(EditFiyat.Text);
        EditFiyat.PostEditValue;
      end;
    end;
  end;
end;

procedure THizliGirisIsk.EditYuzdeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
     ModalResult := mrOk
  else
     EditYuzde.PostEditValue;
end;

procedure THizliGirisIsk.EditYuzdePropertiesEditValueChanged(Sender: TObject);
begin
  YuzdeIskontoHesapla;
end;

procedure THizliGirisIsk.cxCurrencyEdit1PropertiesEditValueChanged(Sender: TObject);
begin
  if YazilacakKDVDurum then
    LabelKdvsiz.Caption := 'KDV Hariç '+FCurrToStr(EditFiyat.EditValue*(100/(100+KDVOrani)))
  else begin
    LabelKdvsiz.Caption := 'KDV Dahil '+FCurrToStr(EditFiyat.EditValue*((100+KDVOrani)/100));
    LabelKdvsiz.Visible := True;
  end;
end;

procedure THizliGirisIsk.Editadet2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Editadet2.PostEditValue;
  if Key = VK_RETURN then
     ModalResult := mrOk
  else if Editadet2.Text<>'' then
     Editadet.Text:=FloatToStr(StrToFloatDef(Editadet2.Text,1) * Birim2Miktar);
end;

procedure THizliGirisIsk.EditadetKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Editadet.PostEditValue;
  if Key=VK_RETURN then
     ModalResult := mrOk
  else if (Editadet2.Visible)and(Editadet.Text<>'') then
     Editadet2.Text:=FormatFloat('####0'+FormatSettings.DecimalSeparator+'##',(StrToFloatDef(Editadet.Text,1) / Birim2Miktar));
end;

procedure THizliGirisIsk.EditFiyatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditFiyat.PostEditValue;
  if Key=VK_RETURN then
    ModalResult := mrOk
  else
    cxCurrencyEdit1PropertiesEditValueChanged(self);
end;

procedure THizliGirisIsk.EditTutarKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditTutar.PostEditValue;
  if Key=VK_RETURN then
     ModalResult := mrOk
  else
     EditTutar.PostEditValue;
end;

procedure THizliGirisIsk.EditTutarPropertiesEditValueChanged(Sender: TObject);
begin
  TutarIskontoHesapla;
end;

procedure THizliGirisIsk.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  BtnNumComma.Caption:=FormatSettings.Decimalseparator;
  LabelKur.Caption := CariDoviz;
  LabelPBirimi.Caption := CariDoviz;
end;

procedure THizliGirisIsk.FormShow(Sender: TObject);
begin
  PageControl1.ActivePageIndex := Cagiran;
  case Cagiran of
    0 : begin  //Adet sekmesi
       Editadet.setFocus;
       Editadet.SelectAll;
    end;
    1 : begin  //İsk / Tutar sekmesi
       EditTutar.SetFocus;
       EditTutar.SelectAll;
    end;
    2 : begin  //Tutar sekmesi
       EditFiyat.setFocus;
       EditFiyat.SelectAll;
       if YazilacakKDVDurum=False then
         LabelKdvsiz.Visible := False;
    end;
  end;

  if Stokmu then begin
      Tablo.TablodanSorguAc(1,'select ANAHTAR from GENINI where BOLUM=-2702 and DEGER = '+IntToStr(Anabirim));
      LabelAdet.Caption:= Tablo.Query1.Fields[0].AsString;
    if Satista2birimGelsin then begin
      Tablo.TablodanSorguAc(1,'select BIRIM2, BIRIM2MIKTAR, BIRIM2AD=(select '+DbUst(1)+'ANAHTAR from GENINI where BOLUM=-2702 and BIRIM2=DEGER and DIL=-1 '+DbSinir(1)+') '+
                 '  from STOKLAR  where ID= '+IntToStr(UrunId));
      if Anabirim<>Tablo.Query1.FieldByName('BIRIM2').AsInteger then begin
        LabelAdet2.Visible := True;
        Editadet2.Visible := True;
        LabelAdet2.Caption:= Tablo.Query1.FieldByName('BIRIM2AD').AsString;
        Birim2Miktar := Tablo.Query1.FieldByName('BIRIM2MIKTAR').AsFloat;
      end;
    end
  end;
end;

procedure THizliGirisIsk.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure THizliGirisIsk.YuzdeIskontoHesapla;
begin
  EditTutar.Properties.OnEditValueChanged := nil;
  EditIskonto.EditValue := EditIskontosuz.EditValue*(EditYuzde.EditValue/100);
  EditTutar.EditValue := EditIskontosuz.EditValue-EditIskonto.EditValue;
  EditTutar.Properties.OnEditValueChanged := EditTutarPropertiesEditValueChanged;
end;

procedure THizliGirisIsk.TutarIskontoHesapla;
begin
  EditYuzde.Properties.OnEditValueChanged := nil;
  if (EditTutar.EditValue>(EditIskontosuz.EditValue+0.01)) and (HizliGirisDlg.FazlaIskontoYapabilir=False) then
   begin //round edilince küsüratlar patladığı için 0.01 eklenerek kontrol ediliyor!!
     Application.MessageBox(PChar(HGSatistan_Buyuk_iskonto_yapilamaz), PChar(HataPrj), MB_OK+ MB_ICONWARNING);
     EditTutar.EditValue:= EditIskontosuz.EditValue;
     Abort;
   end;
  EditIskonto.EditValue := EditIskontosuz.EditValue-EditTutar.EditValue;
  EditYuzde.EditValue := (EditIskonto.EditValue/EditIskontosuz.EditValue)*100;
  EditYuzde.Properties.OnEditValueChanged := EditYuzdePropertiesEditValueChanged;
end;


end.
