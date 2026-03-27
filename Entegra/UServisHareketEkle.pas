unit UServisHareketEkle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, dxBarBuiltInMenu, cxContainer, cxEdit, Vcl.Menus,
  Vcl.ComCtrls, dxCore, cxDateUtils, Vcl.StdCtrls, cxTextEdit, cxImageComboBox,
  cxSpinEdit, cxDropDownEdit, cxCalendar, cxButtons, cxButtonEdit, cxCheckBox,
  cxCurrencyEdit, cxMaskEdit, cxLabel, Vcl.ExtCtrls, cxPC, Data.DB,
  FireDAC.Comp.Client, cxDBEdit, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxNavigator, cxDBData, cxRichEdit, OfficePopupMenu,
  cxGridLevel, cxGridCustomTableView, cxGridCardView, cxGridDBCardView,
  cxClasses, cxGridCustomView, cxGridCustomLayoutView, cxGrid, cxMemo,DateUtils ,
  Vcl.ToolWin, cxGridCustomPopupMenu, cxGridPopupMenu, dxCoreGraphics,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TServisHareketDlg = class(TForm)
    PanelMusteri: TPanel;
    cxPageControl1: TcxPageControl;
    PanelAlt: TPanel;
    ButtonKaydet: TcxButton;
    TabSheetServisEkle: TcxTabSheet;
    ButtonKapat: TcxButton;
    LabelMusteri: TcxLabel;
    LabelServisNo: TcxLabel;
    TabSheetYorumMedya: TcxTabSheet;
    TabYorum: TFDQuery;
    DtsYorum: TDataSource;
    cxGridPopupYorumlar: TcxGridPopupMenu;
    PopupYorumlar: TPopupMenu;
    YorumDzenle1: TMenuItem;
    PopupYorumuSil: TMenuItem;
    N4: TMenuItem;
    DkmanGster1: TMenuItem;
    DokumanFormunuA1: TMenuItem;
    DkmanSil1: TMenuItem;
    ToolBarYorum: TToolBar;
    YorumEkleTus: TToolButton;
    YorumSil: TToolButton;
    YorumDuzenle: TToolButton;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    labelFileName: TcxLabel;
    GridYorum: TcxGrid;
    GridYorumDBCardView1: TcxGridDBCardView;
    GridYorumDBCardView1EKLEMETARIHI: TcxGridDBCardViewRow;
    GridYorumDBCardView1YAZAN: TcxGridDBCardViewRow;
    GridYorumDBCardViewATAC: TcxGridDBCardViewRow;
    GridYorumDBCardView1DOKUMANAD: TcxGridDBCardViewRow;
    GridYorumDBCardView1YORUM: TcxGridDBCardViewRow;
    GridYorumLevel1: TcxGridLevel;
    YorumAtacMenu: TOfficePopupMenu;
    MenuKlasordenEkle: TMenuItem;
    MenuTarayacidanEkle: TMenuItem;
    ButtonAtama: TcxButton;
    MainMenu1: TMainMenu;
    PanelServis: TPanel;
    PanelProje: TPanel;
    cxLabel25: TcxLabel;
    EditProje: TcxButtonEdit;
    Panel3: TPanel;
    cxLabel3: TcxLabel;
    CBServisTuru: TcxImageComboBox;
    Panel2: TPanel;
    CheckBoxDISSERVIS: TcxCheckBox;
    CheckBoxACIL: TcxCheckBox;
    CheckBoxOnemli: TcxCheckBox;
    cxLabel2: TcxLabel;
    Panel11: TPanel;
    cxLabel22: TcxLabel;
    EditEkipman: TcxButtonEdit;
    Panel12: TPanel;
    cxLabel23: TcxLabel;
    EditKonu: TcxButtonEdit;
    Panel10: TPanel;
    cxLabel21: TcxLabel;
    EditIlgili: TcxButtonEdit;
    cxLabel1: TcxLabel;
    ComboBasvuru: TcxImageComboBox;
    DateTarih: TcxDateEdit;
    cxLabel5: TcxLabel;
    ButtonYeniHareket: TcxButton;
    ButtonYeniServis: TcxButton;
    TabHareket: TFDQuery;
    cxPageControl2: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    Panel13: TPanel;
    cxLabel24: TcxLabel;
    ComboDurum: TcxImageComboBox;
    cxLabel28: TcxLabel;
    EditAciklama: TcxButtonEdit;
    Panel15: TPanel;
    CheckBasla: TcxCheckBox;
    PanelBaslaSag: TPanel;
    ComboSureDak: TcxComboBox;
    ComboSureSaat: TcxComboBox;
    cxLabel4: TcxLabel;
    DateBaslaDak: TcxComboBox;
    DateBaslaSaat: TcxComboBox;
    DateBasla: TcxDateEdit;
    Panel16: TPanel;
    DateBitis: TcxDateEdit;
    DateBitisDak: TcxComboBox;
    DateBitisSaat: TcxComboBox;
    CheckBitis: TcxCheckBox;
    Panel1: TPanel;
    EditPersonel: TcxButtonEdit;
    LabelSorumlu: TcxLabel;
    CheckKapali: TcxCheckBox;
    ComboSureGun: TcxComboBox;
    cxLabel6: TcxLabel;
    LabelSID: TcxLabel;
    cxLabel8: TcxLabel;
    LabelHID: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure EditAciklamaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditKonuPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BeditPersonelPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditUrunPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ButtonKaydetClick(Sender: TObject);
    procedure EditIlgiliPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure YorumEkleTusClick(Sender: TObject);
    procedure YorumSilClick(Sender: TObject);
    procedure YorumDuzenleClick(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure MenuKlasordenEkleClick(Sender: TObject);
    procedure MenuTarayacidanEkleClick(Sender: TObject);
    procedure YorumDzenle1Click(Sender: TObject);
    procedure DkmanGster1Click(Sender: TObject);
    procedure DkmanSil1Click(Sender: TObject);
    procedure PopupYorumuSilClick(Sender: TObject);
    procedure DokumanFormunuA1Click(Sender: TObject);
    procedure CBServisTuruPropertiesEditValueChanged(Sender: TObject);
    procedure CheckBitisClick(Sender: TObject);
    procedure CheckBaslaClick(Sender: TObject);
    procedure ButtonAtamaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonYeniHareketClick(Sender: TObject);
    procedure ButtonKapatClick(Sender: TObject);
    procedure ButtonYeniServisClick(Sender: TObject);
    procedure CheckKapaliPropertiesChange(Sender: TObject);
    procedure cxPageControl1Change(Sender: TObject);
    procedure ComboSureGunPropertiesChange(Sender: TObject);
    procedure DateBitisPropertiesChange(Sender: TObject);
  private
    { Private declarations }
    function KayitKontrol:boolean;
    function ZamanGetir(DateEdit1 : TcxDateEdit; Saat, Dak : string) : TDateTime;
    procedure BitisHesapla;
    procedure SureHesapla;
  public
    { Public declarations }
    Cagiran,ServisID,HareketID,RehberId : integer;
    IslemOp : char;
  end;

var
  ServisHareketDlg: TServisHareketDlg;

implementation

uses FetaUtil, PrjConst, UTablo, UGirisKutusuEx, FetaKurulusSiniflari, UGorevDlg;

{$R *.dfm}

var TurBilgisi:string;
    KaydetSecildi, Aciliyor, SureHesaplaniyor : Boolean;


procedure TServisHareketDlg.BeditPersonelPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  Tablo.EditButtonaREHBERGonder(TcxButtonEdit(Sender),335,AButtonIndex,nil,'');
end;

procedure TServisHareketDlg.EditAciklamaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := EditAciklama.Text;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(BGAciklama_gir, @Bilgi)) = mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      EditAciklama.Text := VarToStr(Bilgi);
end;

procedure TServisHareketDlg.EditIlgiliPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonIlgili(tcxButtonEdit(Sender), AButtonIndex, nil, RehberId);
end;

procedure TServisHareketDlg.EditKonuPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Bilgi:Variant;
begin
   Bilgi := EditKonu.Text;
   if TGirisKutusuEx.BilgiAlEx(YeniBilgiGirisi, TGirdiDenetimleri.Create.Memo(AWKonusu, @Bilgi)) = mrOk then    //.Edit(FWToplamTutariGir, @Tutar
      EditKonu.Text := VarToStr(Bilgi);
end;

procedure TServisHareketDlg.EditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaPROJEIDGonder(EditProje, nil, AButtonIndex,ProjeSecimi, RehberId);
end;

procedure TServisHareketDlg.EditUrunPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EkipmanSec(EditEkipman, AButtonIndex, RehberId);
end;



procedure TServisHareketDlg.BtnMesajGonderClick(Sender: TObject);
begin
  Tablo.GridYorumBtnMesajGonder(MemoChat, labelFileName, TabNo_SERVISHAREKET, HareketId, RehberId,TabYorum);
end;

function Kontrol(s:string; Max:integer):string;
var i : integer;
begin
   i:=StrToIntDef(s,0);
   if (i<0)or(i>Max) then
       result:='00'
   else
       result:=inttostr(i)
end;


function TServisHareketDlg.KayitKontrol:boolean;
var sServis, sHareket, Aciklama,str : string;
    Bas,Bit : String;
    belgeno : TBelgeNo;
    Ba,Bi:integer;
begin
  Result := False;
  if CheckBitis.Checked then begin
     if not CheckBasla.Checked then begin
        ShowMessage(BGBaslangic_tarih_gir);
        Exit;
     end else begin

        str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',DateBasla.Date)+' '+Kontrol(DateBaslaSaat.Text,23)+':'+Kontrol(DateBaslaDak.Text,59);
        DateBasla.Date:=StrToDateTimeDef(str, now);
        str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',DateBitis.Date)+' '+Kontrol(DateBitisSaat.Text,23)+':'+Kontrol(DateBitisDak.Text,59);
        DateBitis.Date:=StrToDateTimeDef(str, now);

        if DateBasla.Date > DateBitis.Date then begin
           ShowMessage(GWBitTarihKucukSecilemez);
           Exit;
        end;
     end;
  end;


  if Cagiran in [0,1,4] then begin //ekleme ve değişmede servis güncellenir atamada güncellenmez
      if not BoslukKontrol(EditEkipman.text, SERWServis_Ekipman) then Exit;
      if not BoslukKontrol(EditKonu.text, KontrolKonusu) then Exit;
      if not BoslukKontrol(EditIlgili.text, BildirimYapan) then Exit;

//      innn := Abs(StrToInt(BoolToStr(CheckBoxACIL.Checked)));

      sServis := 'update SERVIS set TARIH=$TARIH$,REHBERID=$REHBERID$,MUS_ILGILI=$MUS_ILGILI$,EKIPMANID=$EKIPMANID$,TURU=$TURU$,KONUSU=$KONUSU$,PROJEID=$PROJEID$,KABUL_SEKLI=$KABUL_SEKLI$,'+
                 'DISSERVIS=$DISSERVIS$,ACIL=$ACIL$,ONEMLI=$ONEMLI$,ACKAPA=$ACKAPA$ where ID='+IntToStr(ServisID);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, sServis, ['$TARIH$','$REHBERID$','$MUS_ILGILI$','$EKIPMANID$','$TURU$','$KONUSU$','$PROJEID$','$KABUL_SEKLI$','$DISSERVIS$','$ACIL$','$ONEMLI$','$ACKAPA$'],
          [FormatDateTime('yyyy-mm-dd hh:nn',DateTarih.Date),RehberId, EditIlgili.Tag,EditEkipman.Tag,CBServisTuru.EditValue,EditKonu.Text,EditProje.Tag,ComboBasvuru.EditValue, Abs(StrToInt(BoolToStr(CheckBoxDISSERVIS.Checked))),
           Abs(StrToInt(BoolToStr(CheckBoxACIL.Checked))), Abs(StrToInt(BoolToStr(CheckBoxOnemli.Checked))),Abs(StrToInt(BoolToStr(CheckKapali.Checked)))]);
  end;
  if not BoslukKontrol(EditPersonel.text, 'Personel') then Exit;
  if CheckBasla.Checked then
     Bas:=''''+ FormatDateTime('yyyy-mm-dd',DateBasla.Date)+' '+Kontrol(DateBaslaSaat.Text,23)+':'+Kontrol(DateBaslaDak.Text,59)+''''
  else
     Bas:= 'null';
  if CheckBitis.Checked then
     Bit:=''''+ FormatDateTime('yyyy-mm-dd',DateBitis.Date)+' '+Kontrol(DateBitisSaat.Text,23)+':'+Kontrol(DateBitisDak.Text,59)+''''
  else
     Bit:= 'null';
  Aciklama := EditAciklama.Text;
//  sHareket := 'update SERVISHAREKET set BASLASEC=$BASLASEC$,BASLAMA=$BASLAMA$,BITISSEC=$BITISSEC$,BITIS=$BITIS$,DURUM=$DURUM$,ACIKLAMA=$ACIKLAMA$,PERSONEL=$PERSONEL$,DEGISTIREN=$DEGISTIREN$,DEGISTIRMETARIHI=getdate()'+
//             ' where ID='+IntToStr(HareketID);
  sHareket := 'update SERVISHAREKET set BASLASEC=$BASLASEC$,BASLAMA='+Bas+',BITISSEC=$BITISSEC$,BITIS='+Bit+',DURUM=$DURUM$,ACIKLAMA=$ACIKLAMA$,PERSONEL=$PERSONEL$,DEGISTIREN=$DEGISTIREN$,DEGISTIRMETARIHI=getdate()'+
             ' where ID='+IntToStr(HareketID);
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, sHareket, ['$BASLASEC$','$BASLAMA$','$BITISSEC$','$BITIS$','$DURUM$','$ACIKLAMA$','$PERSONEL$','$DEGISTIREN$'],
//         [Abs(StrToInt(BoolToStr(CheckBasla.Checked))),VarToStr(Bas),Abs(StrToInt(BoolToStr(CheckBitis.Checked))),VarToStr(Bit),
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, sHareket, ['$BASLASEC$','$BITISSEC$','$DURUM$','$ACIKLAMA$','$PERSONEL$','$DEGISTIREN$'],
         [Abs(StrToInt(BoolToStr(CheckBasla.Checked))),Abs(StrToInt(BoolToStr(CheckBitis.Checked))),
         ComboDurum.EditValue,Aciklama,EditPersonel.Tag, Kullanan]);
  Result:=True;
end;
procedure TServisHareketDlg.ButtonAtamaClick(Sender: TObject);
begin
   KaydetSecildi := True;
   if KayitKontrol then
      ModalResult:=mrAll;
end;

procedure TServisHareketDlg.ButtonKapatClick(Sender: TObject);
begin
   KaydetSecildi := False;
end;

procedure TServisHareketDlg.ButtonKaydetClick(Sender: TObject);
begin
   KaydetSecildi := True;
  if KayitKontrol then
     ModalResult:=mrOk;
end;

procedure TServisHareketDlg.CBServisTuruPropertiesEditValueChanged(Sender: TObject);
begin
   if (Tablo.GENINI.ReadBoolean(Ops_Servis_TureDurum, False))and(CBServisTuru.EditingValue<>null) then
      TurBilgisi:=' and TUR='+IntToStr(CBServisTuru.EditingValue) //eğer opsiyonda servis türüne göre durumlar gelsin seçiliyse
   else
      TurBilgisi:='';
   comboDurum.Properties.Items := Tablo.ComboDurumDoldur(ServisID,HareketID, TurBilgisi);
end;

function TServisHareketDlg.ZamanGetir(DateEdit1 : TcxDateEdit; Saat, Dak : string) : TDateTime;
begin
{  str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateEdit1)+' '+Kontrol(DateEdit1.Text,23)+':'+Kontrol(DateEdit1.Text,59);
  Result := StrToDateTimeDef(str, now);
  Result := IncHour(Result, StrToIntDef(Saat, 0));
  Result := IncMinute(Result, StrToIntDef(Dak, 0));}
end;

(*
  str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',DateBasla.Date)+' '+Kontrol(DateBaslaSaat.Text,23)+':'+Kontrol(DateBaslaDak.Text,59);
  Baslama:=StrToDateTimeDef(str, now);
  DateBitis.Date := IncHour(Baslama, StrToIntDef(ComboSureSaat.Text,0));
  DateBitis.Date := IncMinute(DateBitis.Date,StrToIntDef(ComboSureDak.Text,0));
  DateBitisSaat.text := FormatDateTime('hh', DateBitis.Date);
  DateBitisDak.text  := FormatDateTime('nn', DateBitis.Date);
*)
procedure TServisHareketDlg.BitisHesapla;
var Baslama:TDateTime;
   str:string;
begin
   if (DateBitis.Visible)and(SureHesaplaniyor=False) then begin
      str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',DateBasla.Date)+' '+Kontrol(DateBaslaSaat.Text,23)+':'+Kontrol(DateBaslaDak.Text,59);
      Baslama:=StrToDateTimeDef(str, now);
      DateBitis.Date := IncDay(Baslama, StrToIntDef(ComboSureGun.Text,0));
      DateBitis.Date := IncHour(DateBitis.Date, StrToIntDef(ComboSureSaat.Text,0));
      DateBitis.Date := IncMinute(DateBitis.Date,StrToIntDef(ComboSureDak.Text,0));
      DateBitisSaat.text := FormatDateTime('hh', DateBitis.Date);
      DateBitisDak.text  := FormatDateTime('nn', DateBitis.Date);
   end;
end;

procedure TServisHareketDlg.SureHesapla;
var Sure:TDateTime;
    myYear, myMonth, myDay, myHour, myMin,MySec, MyS : Word;
    str:string;
begin
   if (DateBasla.Visible)and(DateBitis.Visible) then begin
      Sure := DateBitis.Date - DateBasla.Date;
      DecodeDateTime(Sure, myYear, myMonth, myDay, myHour, myMin, MySec, MyS);
      SureHesaplaniyor := True;
      ComboSureGun.text := format('%.2d', [TarihFarki(DateToStr(DateBasla.Date),DateToStr(DateBitis.Date))]);
      ComboSureSaat.text := FormatDateTime('hh', Sure);//format('%.2d', [myHour]);
      ComboSureDak.text := FormatDateTime('nn', Sure);//format('%.2d', [myMin]);
      SureHesaplaniyor := False;
   end;
end;

procedure TServisHareketDlg.CheckBitisClick(Sender: TObject);
begin
   DateBitis.Visible := CheckBitis.Checked;
   DateBitisSaat.Visible := CheckBitis.Checked;
   DateBitisDak.Visible := CheckBitis.Checked;
   BitisHesapla;
   (*if DateBitis.Visible then begin
      str:=FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy',DateBasla.Date)+' '+Kontrol(DateBaslaSaat.Text,23)+':'+Kontrol(DateBaslaDak.Text,59);
      Baslama:=StrToDateTimeDef(str, now);
      DateBitis.Date := IncDay(Baslama, StrToIntDef(ComboSureGun.Text,0));
      DateBitis.Date := IncHour(DateBitis.Date, StrToIntDef(ComboSureSaat.Text,0));
      DateBitis.Date := IncMinute(DateBitis.Date,StrToIntDef(ComboSureDak.Text,0));
      DateBitisSaat.text := FormatDateTime('hh', DateBitis.Date);
      DateBitisDak.text  := FormatDateTime('nn', DateBitis.Date);

      (*DateBitis := ZamanGetir(DateBasla.Date, ComboSureSaat.Text, ComboSureDak.Text);
      DateBitisSaat.text := FormatDateTime('hh', DateBitis.Date);
      DateBitisDak.text  := FormatDateTime('nn', DateBitis.Date);
   end;*)
end;

procedure TServisHareketDlg.CheckKapaliPropertiesChange(Sender: TObject);
begin
   if (Aciliyor)or(not CheckKapali.Checked) then exit;

   if (CheckBasla.Checked=False)or(CheckBitis.Checked=False) then begin
       ShowMessage(BGBaslangic_tarih_gir+' '+DWBitisTarihiGir);
       Exit;
   end;

   Tablo.TablodanSorguAc(1, 'select count(*) from VServisHareket where ID<>'+IntToStr(HareketId)+' and SERVISID='+IntToStr(ServisId)+' and (BASLASEC=0 or BITISSEC=0) ');
   if (Tablo.Query1.Fields[0].AsInteger>0)and
      (Application.MessageBox(PChar(Mailbulunamadiadresekle),PWideChar(PrjConst.Onay),MB_ICONQUESTION+MB_YESNO) = IDYES) then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update SERVISHAREKET set BASLASEC=1,BASLAMA=GetDate() '+
           ' where SERVISID='+IntToStr(ServisId)+' and BASLASEC=0',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update SERVISHAREKET set BITISSEC=1,BITIS=GetDate()'+
           ' where SERVISID='+IntToStr(ServisId)+' and BITISSEC=0',[],[]);
   end;

end;

procedure TServisHareketDlg.ComboSureGunPropertiesChange(Sender: TObject);
begin
   BitisHesapla;
end;

procedure TServisHareketDlg.cxPageControl1Change(Sender: TObject);
begin
   if cxPageControl1.ActivePageIndex=1 then
      Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
end;

procedure TServisHareketDlg.ButtonYeniHareketClick(Sender: TObject);
begin
   KaydetSecildi := True;
   if KayitKontrol then
      ModalResult:=mrRetry;
end;

procedure TServisHareketDlg.ButtonYeniServisClick(Sender: TObject);
begin
   KaydetSecildi := True;
   if KayitKontrol then
      ModalResult:=mrIgnore;
end;

procedure TServisHareketDlg.CheckBaslaClick(Sender: TObject);
begin
   PanelBaslaSag.Visible := CheckBasla.Checked;
   if PanelBaslaSag.Visible then begin
      DateBasla.Date := Tablo.GENINI.BugunTrhSaat;
      DateBaslaSaat.text := FormatDateTime('hh', DateBasla.Date);
      DateBaslaDak.text  := FormatDateTime('nn', DateBasla.Date);
   end;
end;

procedure TServisHareketDlg.DateBitisPropertiesChange(Sender: TObject);
begin
   DateBitis.Date := StrToDateTime( FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateBitis.Date)
      +' '+Kontrol(DateBitisSaat.Text,23)+':'+Kontrol(DateBitisDak.Text,59));
   SureHesapla;
end;

procedure TServisHareketDlg.DkmanGster1Click(Sender: TObject);
begin
  Tablo.GridYorumDokumaniGor(GridYorumDBCardView1);
end;

procedure TServisHareketDlg.DkmanSil1Click(Sender: TObject);
begin
   if (TabYorum.RecordCount>0)and((TamYetkili)or(Kullanan = TabYorum.FieldByName('EKLEYEN').AsString)) then begin
       Tablo.DokumanSil(True,TabYorum.FieldByName('DOKUMANID').AsInteger,1,-1);
       Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
   end;
end;

procedure TServisHareketDlg.DokumanFormunuA1Click(Sender: TObject);
begin
  Tablo.DokumanSihirbazBaslat( 'D', 0, TabYorum.FieldByName('DOKUMANID').AsInteger,Tablo.GENINI.ReadInteger(Ops_OpsiyonServis_VarsayilanKlasor,-2),0,TabNo_GOREVYORUM,TabYorum.FieldByName('ID').AsInteger,RehberId)
end;

procedure TServisHareketDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if (IslemOp='E')and(KaydetSecildi=False) then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from GOREVYORUM where TUR=183 AND GOREVID  = &Id ',['&Id'], [HareketId]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVISHAREKET where ID  = &Id ',['&Id'], [HareketId]);
      if Cagiran=0 then
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from SERVIS where ID  = &Id ',['&Id'], [ServisId]);
   end;
end;

procedure TServisHareketDlg.FormShow(Sender: TObject);
   procedure BilgiAktar;
   begin
       ServisID := TabHareket.FieldByName('SERVISID').AsInteger;
       DateTarih.Date := TabHareket.FieldByName('TARIH').AsDateTime;
       LabelServisNo.Caption :=  TabHareket.FieldByName('SERVISNO').AsString;
       LabelSID.Caption :=  IntToStr(ServisID);
       LabelHID.Caption :=  IntToStr(HareketID);
       LabelMusteri.Caption :=  TabHareket.FieldByName('FIRMA').AsString;
       EditIlgili.Tag :=  TabHareket.FieldByName('MUS_ILGILI').AsInteger;
       EditIlgili.Text :=  TabHareket.FieldByName('MUS_ILGILIAD').AsString;
       EditEkipman.Tag :=  TabHareket.FieldByName('EKIPMANID').AsInteger;
       EditEkipman.Text :=  TabHareket.FieldByName('EKIPMANAD').AsString;
       ComboBasvuru.EditValue :=  TabHareket.FieldByName('KABUL_SEKLI').AsInteger;
       CheckBoxDISSERVIS.Checked :=  TabHareket.FieldByName('DISSERVIS').AsBoolean;
       CheckBoxACIL.Checked :=  TabHareket.FieldByName('ACIL').AsBoolean;
       CheckBoxOnemli.Checked :=  TabHareket.FieldByName('ONEMLI').AsBoolean;

       EditKonu.Text :=  TabHareket.FieldByName('KONUSU').AsString;
       CBServisTuru.EditValue :=  TabHareket.FieldByName('TURU').AsInteger;
       ComboDurum.EditValue :=  TabHareket.FieldByName('DURUM').AsInteger;
       CBServisTuru.Tag :=  TabHareket.FieldByName('TURU').AsInteger;
       CBServisTuru.Text := Tablo.AciklamaGetir('GENINI','ANAHTAR', TabHareket.FieldByName('TURU').AsInteger, ' DIL=-1 AND BOLUM=-3006 AND DEGER' );
       EditProje.Tag:=  TabHareket.FieldByName('PROJEID').AsInteger;
       EditProje.Text:=  TabHareket.FieldByName('PROJEAD').AsString;
       CheckKapali.Checked    :=  TabHareket.FieldByName('ACKAPA').AsBoolean;
       CheckBasla.Checked    :=  TabHareket.FieldByName('BASLASEC').AsBoolean;
       CheckBitis.Checked    :=  TabHareket.FieldByName('BITISSEC').AsBoolean;
   end;

   procedure BosKayitEkle;
   var sServis : string;
      belgeno : TBelgeNo;
   begin
     if Cagiran in [0,4] then begin //yeni servis ise veya seris kopyalama
        if Cagiran = 0 then begin
           DateTarih.Date := Tablo.GENINI.BugunTrhSaat;
           CBServisTuru.ItemIndex := 0;
           ComboBasvuru.ItemIndex := 0;
           ComboDurum.ItemIndex := 0;
        end;
        Tablo.ServisOlustur(0,'',0,0,0,Windows_Hareket_Giris);   //Windows_Donusum
     end;
   end;

    procedure Renkli(Renk:TColor);
    begin
       EditProje.Style.Color := Renk;
       CBServisTuru.Style.Color := Renk;
       ComboBasvuru.Style.Color := Renk;
       DateTarih.Style.Color := Renk;
       EditEkipman.Style.Color := Renk;
       EditKonu.Style.Color := Renk;
       EditIlgili.Style.Color := Renk;
       EditIlgili.Style.Color := Renk;
    end;
begin
   cxPageControl1.ActivePageIndex:=0;
   KaydetSecildi := False;
   Aciliyor:=True;
   SureHesaplaniyor:=False;

   // HAREKET.FieldByName('SERVISID').AsInteger, HAREKET.FieldByName('ID').AsInteger
   TabloYenile(TabHareket,[HareketId]);
   if RehberId = -999 then
      RehberId := TabHareket.FieldByName('REHBERID').AsInteger;
   PanelMusteri.Tag := RehberId;
   if IslemOp='E' then begin
      if Cagiran=1 then
         ServisId:=TabHareket.FieldByName('SERVISID').AsInteger;
      BosKayitEkle;
      LabelMusteri.Caption := Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId);
      EditPersonel.Tag:=  StrToInt(Kullanan);
      EditPersonel.Text:= Tablo.AciklamaGetir('REHBER', 'FIRMA', StrToInt(Kullanan));
      CheckBasla.Checked := False;
      CheckBitis.Checked := False;
      if Cagiran = 1 then //hareket eklenecekse
         BilgiAktar;
   end
   else if IslemOp='D' then begin
       BilgiAktar;
       HareketID := TabHareket.FieldByName('ID').AsInteger;
       EditAciklama.Text :=  TabHareket.FieldByName('ACIKLAMA').AsString;
       CheckBasla.Checked := TabHareket.FieldByName('BASLASEC').AsBoolean;
       if CheckBasla.Checked then begin
          DateBasla.Date :=  TabHareket.FieldByName('BASLAMATARIHI').AsDateTime;
          DateBaslaSaat.text := FormatDateTime('hh', DateBasla.Date);
          DateBaslaDak.text  := FormatDateTime('nn', DateBasla.Date);
       end;
       CheckBitis.Checked := TabHareket.FieldByName('BITISSEC').AsBoolean;
       if CheckBitis.Checked then begin
          DateBitis.Date :=  TabHareket.FieldByName('BITISTARIHI').AsDateTime;
          DateBitisSaat.text := FormatDateTime('hh', DateBitis.Date);
          DateBitisDak.text  := FormatDateTime('nn', DateBitis.Date);
          SureHesapla;
       end;

       EditPersonel.Tag:=  TabHareket.FieldByName('PERSONEL').AsInteger;
       EditPersonel.Text:=  TabHareket.FieldByName('PERSONELAD').AsString;
   end;

    if Cagiran = 2 then begin //atama ise
       CheckBasla.Checked:=False;
       CheckBitis.Checked:=False;
       EditPersonel.Tag:=0;
       EditPersonel.Text:='';
       PanelServis.Visible:=False;
       ButtonAtama.Visible:=False;
       CheckKapali.Visible:=False;
       LabelSorumlu.Caption:='Atanan';
       Height := 372;
       CBServisTuruPropertiesEditValueChanged(Self);
    end;
    if Cagiran in [2,3,4] then begin //atama ve yeni hareket ve yeni servis ise
       EditAciklama.Text:='';
       EditKonu.Text:='';
    end;

    PanelProje.Visible := ((IslemOp='E') and (Cagiran=0))or  //ilk servis ekleniyorsa
                           (EditProje.Text<>''); //veya proje bilgisi varsa görünsün


    PanelServis.Enabled := (IslemOp='E') and (Cagiran in [0,4]);//or  //ilk servis ekleniyorsa veya yeni servis kopyalandıysa
                           //((IslemOp='E') and (Cagiran=1)and(TabHareket.FieldByName('SERVISEKLEYEN').AsInteger=TabHareket.FieldByName('HAREKETEKLEYEN').AsInteger))or
                           //((IslemOp='D')and(TabHareket.FieldByName('SERVISEKLEYEN').AsInteger=TabHareket.FieldByName('HAREKETEKLEYEN').AsInteger));
    if PanelServis.Enabled then begin
       Renkli(clWhite);
       TabSheetServisEkle.Caption := 'Servis Ekleme'
    end else begin
       Renkli($00E9E9E9);
       TabSheetServisEkle.Caption := 'Servis Bilgisi'
    end;

    if comboDurum.ItemIndex < 0 then
       CBServisTuruPropertiesEditValueChanged(Self);
    Aciliyor:=False;
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
end;

procedure TServisHareketDlg.MenuKlasordenEkleClick(Sender: TObject);
begin
 Tablo.GridYorumBtnDosyaGonder(labelFileName, BtnMesajGonder);
end;

procedure TServisHareketDlg.MenuTarayacidanEkleClick(Sender: TObject);
begin
   Tablo.GridDokumanTara(labelFileName, BtnMesajGonder);
end;

procedure TServisHareketDlg.PopupYorumuSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_SERVISHAREKET, HareketId, TabYorum);
end;

procedure TServisHareketDlg.YorumDuzenleClick(Sender: TObject);
begin
   Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_SERVISHAREKET);
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   //TabHareketlerAfterScroll( TabHareketler);
end;

procedure TServisHareketDlg.YorumDzenle1Click(Sender: TObject);
begin
   Tablo.GridYorumYorumuDuzenle(GridYorumDBCardView1, TabNo_SERVISHAREKET);
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   //TabHareketlerAfterScroll( TabHareketler);
   Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
end;

procedure TServisHareketDlg.YorumEkleTusClick(Sender: TObject);
begin
   YorumEkleIslemi(TabNo_SERVISHAREKET, HareketId, TabYorum);
   //Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, TabHareketler.FieldByName('ID').AsInteger]);
   //TabHareketlerAfterScroll( TabHareketler);
   Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
end;

procedure TServisHareketDlg.YorumSilClick(Sender: TObject);
begin
   Tablo.GridYorumuSil(TabNo_SERVISHAREKET, HareketId, TabYorum);
   Tabloyenile(TabYorum,[TabNo_SERVISHAREKET, HareketId]);
end;

end.



