unit UOpsiyonDokuman;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxLookAndFeelPainters, cxSpinEdit,
  cxGroupBox, cxRadioGroup, cxTextEdit, cxMaskEdit, cxButtonEdit, cxControls, cxContainer,
  cxEdit, cxLabel, StdCtrls, Buttons, ExtCtrls,UKodAgaci, cxGraphics,
  cxLookAndFeels, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.Menus, cxButtons, dxSkinLiquidSky, cxCheckBox,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinscxPCPainter, dxBarBuiltInMenu, cxPC,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, dxCoreGraphics;

type
  TOpsiyonDokumanDlg = class(TForm)
    OpenDialog1: TOpenDialog;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    Panel1: TPanel;
    LabelDosyaToplam: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    GroupBox4: TGroupBox;
    LabelDizin: TcxLabel;
    Label9: TcxLabel;
    DokumanDizin: TcxButtonEdit;
    cxLabel5: TcxLabel;
    DokumanOrtami: TcxRadioGroup;
    cxLabel6: TcxLabel;
    DokumanBoyut: TcxSpinEdit;
    cxLabel1: TcxLabel;
    LabelDosyaSay: TcxLabel;
    KlasorVTAktarTus: TcxButton;
    VarsayilanKlasor: TcxButtonEdit;
    VarsayilanKlasorGiden: TcxButtonEdit;
    CheckTarayiciKullanimda: TcxCheckBox;
    PanelDizinDikkat: TPanel;
    cxLabel7: TcxLabel;
    cxLabel8: TcxLabel;
    cxButton1: TcxButton;
    cxLabel4: TcxLabel;
    Panel2: TPanel;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    ComboRevizeMiktar: TcxComboBox;
    cxLabel14: TcxLabel;
    DosyaMigrasyonTus: TcxButton;
    procedure DosyaMigrasyonTusClick(Sender: TObject);
    procedure DokumanDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DokumanOrtamiPropertiesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure VarsayilanKlasorPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure VarsayilanKlasorGidenPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButton1Click(Sender: TObject);
    procedure KlasorVTAktarTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonDokumanDlg: TOpsiyonDokumanDlg;

implementation

uses Utablo,PrjConst,FetaKurulusSiniflari, UDosyaMigrasyon ;

{$R *.dfm}

procedure TOpsiyonDokumanDlg.DosyaMigrasyonTusClick(Sender: TObject);
begin
   if DosyaMigrasyonDlg = nil then
      Application.CreateForm(TDosyaMigrasyonDlg, DosyaMigrasyonDlg);
   DosyaMigrasyonDlg.ShowModal;
end;

procedure TOpsiyonDokumanDlg.cxButton1Click(Sender: TObject);
const komut =
' exec sp_configure ''show advanced options'', 1 RECONFIGURE;' + #13#10 +
' exec sp_configure ''Ole Automation Procedures'',1 RECONFIGURE;' + #13#10 +
' EXEC sp_configure ''Ad Hoc Distributed Queries'', 1 RECONFIGURE;'+ #13#10 +
' EXEC sp_configure ''xp_cmdshell'', 1;';
begin
   //dokumanlar� diske kaydetebilmek i�in sql'e configurasyon yap�yoruz
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, komut,[],[]);
end;

procedure TOpsiyonDokumanDlg.DokumanDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if OpenDialog1.Execute then
     DokumanDizin.Text:=ExtractFileDir(OpenDialog1.FileName);
end;

procedure TOpsiyonDokumanDlg.DokumanOrtamiPropertiesChange(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1, 'select count(*),sum(boyut) from IMAJ where ICDIS='+IntToStr(DokumanOrtami.ItemIndex));
   LabelDosyaSay.Caption := Tablo.Query1.fields[0].asstring;
   LabelDosyaToplam.Caption := Tablo.Query1.fields[1].asstring+' KB';
   DokumanDizin.Enabled := DokumanOrtami.ItemIndex=1;
   PanelDizinDikkat.Visible := DokumanOrtami.ItemIndex=1;

   if DokumanOrtami.ItemIndex=0 then begin
      LabelDizin.Caption := TVeritabaniAdi;
      DokumanDizin.Text := '.';
      KlasorVTAktarTus.Caption := 'Klasör --> VT Aktar';
   end else begin
      LabelDizin.Caption := TDizinAdi;
      DokumanDizin.Text :=  Tablo.GENINI.ReadString(Ops_Dokuman_Dizin,'c:\GenDokuman\'); // Dokuman Dizin
      KlasorVTAktarTus.Caption := 'VT --> Klasör Aktar';
   end;

end;

procedure TOpsiyonDokumanDlg.FormCreate(Sender: TObject);
begin
   DokumanOrtami.ItemIndex := Tablo.GENINI.ReadInteger(Ops_Dokuman_Kayit_Yeri,1); // Dokuman Kayit_Yeri
   if DokumanOrtami.ItemIndex=0 then
      DokumanDizin.Text :=  Tablo.GENINI.ReadString(Ops_VeriTabaniAdi,'.') // Dokuman Dizin
   else
      DokumanDizin.Text :=  Tablo.GENINI.ReadString(Ops_Dokuman_Dizin,'c:\GenDokuman\'); // Dokuman Dizin
   DokumanBoyut.Value:= Tablo.GENINI.ReadInteger(Ops_Dokuman_MaxBoyut,1000); // Dokuman MaxBoyut
   DokumanOrtamiPropertiesChange(Self);
   tablo.TablodanSorguAc(8,'SELECT ID FROM DOKUMANKLASOR  WHERE AD = '+'''E-Posta''');
   VarsayilanKlasor.tag:=Tablo.GENINI.ReadInteger(Ops_Dokuman_GelenKutusu,tablo.Query8.FieldByName('ID').AsInteger);
   VarsayilanKlasor.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasor.tag);
   VarsayilanKlasorGiden.tag:=Tablo.GENINI.ReadInteger(Ops_Dokuman_GidenKutusu,tablo.Query8.FieldByName('ID').AsInteger);
   VarsayilanKlasorGiden.text:= TABLO.AciklamaGetir('DOKUMANKLASOR','AD',VarsayilanKlasorGiden.tag);
   CheckTarayiciKullanimda.Checked := Tablo.GENINI.ReadBoolean(Ops_Dokuman_TarayiciKullanimda, False);
   ComboRevizeMiktar.ItemIndex := Tablo.GENINI.ReadInteger(Ops_Dokuman_RevizeMiktar, 0);

end;

procedure TOpsiyonDokumanDlg.KaydetTusClick(Sender: TObject);
begin
   Dokuman_Kayit_Yeri := DokumanOrtami.ItemIndex;
   Tablo.GENINI.WriteInteger(Ops_Dokuman_Kayit_Yeri, Dokuman_Kayit_Yeri);  // Dokuman Kayit_Yeri
   if DokumanOrtami.ItemIndex=0 then
      Tablo.GENINI.WriteString(Ops_VeriTabaniAdi, DokumanDizin.Text) // Dokuman Dizin
   else begin
      if (DokumanDizin.Text<>'')and(DokumanDizin.Text[Length(DokumanDizin.Text)]<>'\') then
          DokumanDizin.Text := DokumanDizin.Text + '\';
      Tablo.GENINI.WriteString(Ops_Dokuman_Dizin,DokumanDizin.Text);  // Dokuman Dizin
   end;

   Tablo.GENINI.WriteInteger(Ops_Dokuman_MaxBoyut,DokumanBoyut.Value);  // Dokuman MaxBoyut
   MaxDosyaBuyuklugu := DokumanBoyut.Value;
   Tablo.GENINI.WriteInteger(Ops_Dokuman_GelenKutusu,VarsayilanKlasor.Tag);//  OpsiyonServis  VarsayilanKlasor Dokuman i�in
   Tablo.GENINI.WriteInteger(Ops_Dokuman_GidenKutusu,VarsayilanKlasorGiden.Tag);//  OpsiyonServis  VarsayilanKlasor Dokuman i�in
   Tablo.GENINI.WriteBoolean(Ops_Dokuman_TarayiciKullanimda, CheckTarayiciKullanimda.Checked);
   Tablo.GENINI.WriteInteger(Ops_Dokuman_RevizeMiktar, ComboRevizeMiktar.ItemIndex);
end;

procedure TOpsiyonDokumanDlg.KlasorVTAktarTusClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1, 'select ID from IMAJ where ICDIS<>'+IntToStr(DokumanOrtami.ItemIndex)+ ' order by 1 desc');
   LabelDosyaSay.Caption := Tablo.Query1.fields[0].asstring;
   while not Tablo.Query1.Eof do begin
      if DokumanOrtami.ItemIndex=0 then begin
         try
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+Tablo.Query1.Fields[0].AsString+' ,@SONUC OUTPUT '+
             'update IMAJ set BELGE=@SONUC, ICDIS=0 where ID=' + Tablo.Query1.Fields[0].AsString, [],[]);
           except

           end;
      end else begin
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text:='DECLARE @BELGE varbinary(MAX) SELECT @BELGE=cast(:PBELGE as VARBINARY(MAX))'+
             ' EXEC [sp_Imaj_Kaydetme] '+Tablo.Query1.Fields[0].AsString+',@BELGE ';
             //' update IMAJ set BELGE=null, ICDIS=1 where ID=' + Tablo.Query1.Fields[0].AsString;
//        Tablo.Query5.Params[0].LoadFromStream(CompressedStream_ , ftBlob);
        //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select BELGE from IMAJ where ID='+Tablo.Query1.Fields[0].AsString,[],[],True)
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'select BELGE from IMAJ where ID='+Tablo.Query1.Fields[0].AsString;
        Tablo.Query2.Open;
        Tablo.Query5.Params[0].Assign(Tablo.Query2.Fields[0]);
        Tablo.Query5.ExecSQL;
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update IMAJ set BELGE=null, ICDIS=1  where ID=' + Tablo.Query1.Fields[0].AsString, [],[]);
      end;
      Tablo.Query1.next;
   end;
   DokumanOrtamiPropertiesChange(Self);
   Showmessage(BAktarim_tamam);
end;

procedure TOpsiyonDokumanDlg.VarsayilanKlasorGidenPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','A��klama'],[true,False]) then begin
      VarsayilanKlasorGiden.Text:=LokAciklama;
      VarsayilanKlasorGiden.Tag:=LokID;

    end;
  end;
end;



procedure TOpsiyonDokumanDlg.VarsayilanKlasorPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
KodAgaciLokasyonDlg: TKodAgaciDlg;
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
    sqltext:='select ID,ROOTKOD=USTID, KOD=ID,ACIKLAMA=AD FROM DOKUMANKLASOR WHERE ID >0 ORDER BY USTID ' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[Tablo.repDokumanKlasor,nil],[],[],['Klasor','A��klama'],[true,False]) then begin
      VarsayilanKlasor.Text:=LokAciklama;
      VarsayilanKlasor.Tag:=LokID;

    end;
  end;
end;
end.






