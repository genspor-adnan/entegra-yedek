unit UDemirbasAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar,UKodAgaci,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, DB,PrjConst,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, DateUtils, cxLookAndFeelPainters, cxButtons,
  cxLookAndFeels, dxCore, cxDateUtils, dxSkinLiquidSky, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint;
type
  TDemirbasAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    YenileTus: TSpeedButton;
    cxLabel7: TcxLabel;
    AraSeriNo: TcxTextEdit;
    LabelPNO: TcxLabel;
    AraDemirbasNo: TcxTextEdit;
    Label2: TcxLabel;
    Label6: TcxLabel;
    Label8: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel1: TcxLabel;
    AraLokasyonbtne: TcxButtonEdit;
    AraZimmetAlanbtne: TcxButtonEdit;
    AraKategoribtne: TcxButtonEdit;
    AraDurumu: TcxImageComboBox;
    Label7: TcxLabel;
    AraDemirbasAdi: TcxTextEdit;
    cbPasiflerideGoster: TcxCheckBox;

    procedure AraKabuledenPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxLabel7Click(Sender: TObject);
    procedure AraLokasyonbtnePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure AraZimmetAlanbtnePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure AraKategori2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure AraZimmetAlanbtneKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    procedure CombolariDoldur(SQLText: string;
  ComboAdi: TcxComboBox);
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
    KodAgaciLokasyonDlg,KodAgaciKategoriDlg:TKodAgaciDlg;
    { Public declarations }
  end;

implementation


{$R *.dfm}
uses Utablo,LocOnFly;
{ TDemirbasAramaFrame }

procedure TDemirbasAramaFrame.AraKabuledenPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin

end;

procedure TDemirbasAramaFrame.AraKategori2PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
    sqltext:='select ROOTKOD=case when CHARINDEX(''-'',TMYSKOD,1)=0 then ''-'' else REVERSE( SUBSTRING(REVERSE(TMYSKOD),CHARINDEX(''-'',REVERSE(TMYSKOD),1)+1,LEN(TMYSKOD)-(CHARINDEX(''-'',REVERSE(TMYSKOD),1)-1))) end,ACIKLAMA=STOKADI,KOD=TMYSKOD,ID from DEMIRBAS_URUN' ;
    if Tablo.KodAgacindanSec(KodAgaciKategoriDlg,sqltext,True,True,False,True,LokID,LokKod,LokAciklama,slist,[],[],[],[],[]) then begin
      AraKategoribtne.Tag:=LokID;
      AraKategoribtne.Text:=LokAciklama;
    end;
  end else if AButtonIndex=1 then begin
    AraKategoribtne.Tag:=0;
    AraKategoribtne.Text:='';
  end;
end;

procedure TDemirbasAramaFrame.AraLokasyonbtnePropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  if AButtonIndex = 0 then begin
//    sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Genel)+' and REHBERID=-1' ;
//    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,[],['TUR'],[IntToStr(Lokasyon_Genel)],['Kod','Açýklama',''],[True,True,False]) then begin
    sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID,YERI,YERID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEMIRBAS)+' and YERID=0'; //and TUR='+IntToStr(Lokasyon_Genel)+' and REHBERID=-1' ;
    if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR','YERI','YERID'],[IntToStr(Lokasyon_Demirbas),TabNo_DEMIRBAS,0],['Kod','Açýklama',''],[True,True,False,False,False]) then begin
      AraLokasyonbtne.Tag:=LokID;
      AraLokasyonbtne.Text:=LokAciklama;
    end;
  end else if AButtonIndex = 1 then begin
      AraLokasyonbtne.Tag:=0;
      AraLokasyonbtne.Text:='';
  end;
end;

procedure TDemirbasAramaFrame.AraZimmetAlanbtneKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TDemirbasAramaFrame.AraZimmetAlanbtnePropertiesButtonClick( Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
begin
   if AButtonIndex = 0 then begin
      ID := Tablo.RehberAra_IDGetir(335);
      if ID>0 then begin
         TcxButtonEdit(Sender).Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
         TcxButtonEdit(Sender).Tag:=ID;
      end
  end
  else
  begin
    TcxButtonEdit(Sender).Text:='';
    TcxButtonEdit(Sender).Tag:=0;
  end;
end;

procedure TDemirbasAramaFrame.Baslatildi;
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDemirbasAramaFrame.cxLabel7Click(Sender: TObject);
begin
  AraSeriNo.Text:='';
  AraDemirbasNo.Text:='';
  AraDurumu.ItemIndex:=-1;
  AraZimmetAlanbtne.Text:='';
  AraLokasyonbtne.Text:='';
  AraKategoribtne.Text:='';
end;

procedure TDemirbasAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDemirbasAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDemirbasAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TDemirbasAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDemirbasAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDemirbasAramaFrame.Gorunmez;
begin

end;

procedure TDemirbasAramaFrame.GorunmezOlacak;
begin

end;

procedure TDemirbasAramaFrame.Gorunur;
begin
end;

procedure TDemirbasAramaFrame.CombolariDoldur(SQLText: string;
  ComboAdi: TcxComboBox);
begin
   Tablo.TablodanSorguAc(1,SQLText);
   ComboAdi.Properties.Items.Clear;
   Tablo.Query1.First;
   ComboAdi.Properties.Items.Add('');
  while not Tablo.Query1.Eof do begin
    ComboAdi.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.Next;
  end;
end;
procedure TDemirbasAramaFrame.GorunurOlacak;
begin

end;

procedure TDemirbasAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDemirbasAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDemirbasAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDemirbasAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDemirbasAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDemirbasAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TDemirbasAramaFrame);
end.


