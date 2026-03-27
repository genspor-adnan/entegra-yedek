unit UCariEkle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, JvExControls, JvButton, JvNavigationPane, cxMemo,
  cxTextEdit, cxLabel, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TCariEkleDlg = class(TForm)
    cxLabel4: TcxLabel;
    EditMusteri: TcxTextEdit;
    cxLabel1: TcxLabel;
    EditCepTel: TcxTextEdit;
    cxLabel2: TcxLabel;
    EditIstel: TcxTextEdit;
    cxLabel3: TcxLabel;
    EditEvTel: TcxTextEdit;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    EditIlce: TcxTextEdit;
    EditAdres: TcxMemo;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    KaydetTus: TJvNavPanelButton;
    cxLabel7: TcxLabel;
    EditEPosta: TcxTextEdit;
    cxLabel8: TcxLabel;
    EditIl: TcxTextEdit;
    cxLabel9: TcxLabel;
    MemoNotlar: TcxMemo;
    procedure KapatTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RehberId : Integer;
  end;

var
  CariEkleDlg: TCariEkleDlg;


implementation

uses UTablo, FetaKurulusSiniflari;

{$R *.dfm}

procedure TCariEkleDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult:=mrCancel
end;

procedure TCariEkleDlg.KaydetTusClick(Sender: TObject);
var Kod:String;
   procedure Ekle(Bilgi, VarsayDeger:String);
   begin
      veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO REHBERBILGI([YERI],[YER_ID],[SIRA],[ETIKET],[BILGI],EKLEYEN,SUBEID)  '+
         ' SELECT YERI=1,YER_ID='+Tablo.Query2.Fields[0].AsString+',SIRA,ETIKET,BILGI='''+Bilgi+''', EKLEYEN='+Kullanan+
         ', SUBEID='+IntToStr(SubeId)+' FROM REHBERAYAR RA inner join REHBERVARSAYILAN RV on RA.VARSAYILAN=RV.NO and  RA.YERI=1 and RV.YERI=1 and RV.NO='+VarsayDeger,[], []);
   end;
begin
   Kod:=tablo.KodBulmaSihirbazi(120, 'HESAPPLANI','HESAPKODU', 'HESAPADI', 'REHBER', 'KOD',StrToInt(VarToStrDef(120,'0')));

   Tablo.TablodanSorguAc(1,' insert into REHBER (KOD,FIRMA,STATU,GRUP,DURUM,NOTLAR,EKLEYEN,SUBEID)values '+
     ' ('''+ Kod + ''','''+Trim(EditMusteri.text)+''',0,120,1,'''+MemoNotlar.Text+''','+Kullanan+','+IntToStr(SubeID)+') SELECT SCOPE_IDENTITY()');

   RehberId := Tablo.Query1.fields[0].AsInteger;

   Tablo.TablodanSorguAc(2,'INSERT INTO REHBERILETISIM([REHBERID],[AD] ,[VARSAYILAN],[AKTIF],[SUBEID]) '+
     ' values ('+ IntToStr(RehberId)  + ',''Merkez'',1,1,' +IntToStr(SubeID)+') SELECT SCOPE_IDENTITY()');

   if Trim(EditCepTel.Text)<>'' then Ekle(Trim(EditCepTel.Text),'42');
   if Trim(EditIstel.Text)<>'' then Ekle(Trim(EditIstel.Text),'40');
   if Trim(EditEvTel.Text)<>'' then Ekle(Trim(EditEvTel.Text),'44');
   if Trim(EditAdres.Text)<>'' then Ekle(Trim(EditAdres.Text),'2');
   if Trim(EditIlce.Text)<>'' then Ekle(Trim(EditIlce.Text),'6');
   if Trim(EditIl.Text)<>'' then Ekle(Trim(EditIl.Text),'8');
   if Trim(EditEPosta.Text)<>'' then Ekle(Trim(EditEPosta.Text),'46');
   ModalResult:=mrOk;
end;

end.


