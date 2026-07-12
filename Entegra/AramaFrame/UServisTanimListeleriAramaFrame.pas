unit UServisTanimListeleriAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar, UTablo,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, DB,UKodAgaci,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, DateUtils, CategoryButtons;

type
  TServisTanimListeleriAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PanelServisTur: TPanel;
    ServisListeTurleri: TCategoryButtons;
    YenileTus: TSpeedButton;
    procedure ServisListeTurleriButtonClicked(Sender: TObject; const Button: TButtonItem);
    procedure ServisListeTurleriCategoryClicked(Sender: TObject; const Category: TButtonCategory);
    procedure TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
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
    procedure YeniBtnClick(Sender: TObject);
    procedure DegisClick(Sender: TObject);
    procedure SilbtnClick(Sender: Tobject);

  public
    { Public declarations }
    KADlg:TKodAgaciDLG;
    VarsHint:String;
  end;

implementation

{$R *.dfm}

uses UVeriMotor, UServisListeDlg,UEkipmanListeDlg,FetaKurulusSiniflari, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform,
JclSysInfo,UGirisKutusuEx,UServisIslemDetaylari,LocOnFly,PrjConst;
{ TServisTanimListeleriAramaFrame }

procedure TServisTanimListeleriAramaFrame.Baslatildi;
var
   i:Integer;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

  for I := ServisListeTurleri.Categories[0].Items.Count-1 downto 0 do
    ServisListeTurleri.Categories[0].Items[I].Destroy;

  Tablo.TablodanSorguAc(9,'select * from GENINI where BOLUM='+IntToStr(Ops_Servis_Genel_Icerik)+' and DIL='+IntToStr(Dil)+' order by SIRA ');
  Tablo.Query9.First;
  while not Tablo.Query9.Eof do begin
    With ServisListeTurleri.Categories[0].Items.Add do begin
      Caption := Tablo.Query9.FieldByName('ANAHTAR').AsString;
      Hint := Tablo.Query9.FieldByName('DEGER').AsString;
      ImageIndex := 9;
    end;
    Tablo.Query9.Next;
  end;
  Tablo.FBtnIndex := -1;
  TumTusResimleriniDegistir(ServisListeTurleri,9);

  ServisListeTurleri.Categories[0].Collapsed:=False;
  ServisListeTurleri.Visible := True;
  PanelServisTur.Visible:=True;
  PanelServisTur.height :=222;
end;

procedure TServisTanimListeleriAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TServisTanimListeleriAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TServisTanimListeleriAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TServisTanimListeleriAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TServisTanimListeleriAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TServisTanimListeleriAramaFrame.Gorunmez;
begin

end;

procedure TServisTanimListeleriAramaFrame.GorunmezOlacak;
begin

end;

procedure TServisTanimListeleriAramaFrame.Gorunur;
begin

end;

procedure TServisTanimListeleriAramaFrame.GorunurOlacak;
begin

end;

procedure TServisTanimListeleriAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TServisTanimListeleriAramaFrame.ServisListeTurleriButtonClicked(Sender: TObject; const Button: TButtonItem);
var
  ServisListeID:integer;
  SLKod,SLAd,SQLText:String;
  slist : TStringList;
begin
  if ServisListeTurleri.Categories[1].Items[0]=Button then begin
    application.createform(TServisIslemDetaylariDlg,ServisIslemDetaylariDlg);
    ServisIslemDetaylariDlg.ShowModal;
    FreeAndNil(ServisIslemDetaylariDlg);
  end else begin
    if not JclSysInfo.GetKeyState(VK_CONTROL) then
      TumTusResimleriniDegistir(Button.CategoryButtons,10);
     VarsHint:=Button.Hint;
    if Button.ImageIndex = 9 then
      Button.ImageIndex :=10
    else
      Button.ImageIndex :=9;
    Tablo.FBtnIndex := Button.Index;

    SQLText:=  ' select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' ' +
       ' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) '+
       ' end,KOD,AD,SERVISTUR,ID from SERVISLISTE where 1=1 and SERVISTUR = '''+ Button.Hint + ''' ';
    application.createform(TKodAgaciDlg,KADlg);
    KADlg.YeniTus.OnClick := YeniBtnClick;
    KADlg.SilTus.OnClick:=SilbtnClick;
    KADlg.cxDBTreeList1.OnDblClick:=DegisClick;
    KADlg.cxDBTreeList1.OptionsSelection.CellSelect := False;                                   // Tablo.RepServisDetayGruplari
    Tablo.KodAgacindanSec(KADlg,SQLText,True,True,False,True,ServisListeID,SLKod,SLAd,slist,[nil,nil,nil],['SERVISTUR'],[StrToInt(Button.Hint)],['Kod','Açıklama',''],[True,True,False],False);
    Button.ImageIndex :=10;
    VarsHint:='';
    FreeAndNil(KADlg);
  end;
end;
procedure TServisTanimListeleriAramaFrame.YeniBtnClick(Sender: TObject);
var
  Kod,Aciklama,ComDeger:Variant;
  ctrls: TGirdiDenetimleri;
  liste:TStrings;
  BaslangicStr,BasDetay:String;
begin
  liste:=nil;
  liste:=TStringList.Create;
  liste.Add('Başlık');
  liste.Add('Detay');
  ComDeger:='Detay';
  Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'KOD from SERVISLISTE where SERVISTUR='+VarsHint+'  order by LEN(KOD) '+DbSinir(1));
  BaslangicStr := Tablo.Query1.Fields[0].AsString;
  if BaslangicStr='' then
    BaslangicStr:='Yok'
  else if pos('.',BaslangicStr) > 0  then
    BaslangicStr:=Copy(BaslangicStr,1,pos('.',BaslangicStr));
  Kod := Tablo.ServisKodBulmaSihirbazi(BaslangicStr, 'SERVISLISTE', 'KOD', 'AD','SERVISLISTE' ,'KOD');
  ctrls:=TGirdiDenetimleri.Create.Edit(KontrolKod,@Kod).Edit(BGAciklama_gir,@Aciklama).ComboBox((Seciniz),@ComDeger,liste);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls)<> mrOK  then
    Abort;
  if  liste.Strings[0]=ComDeger then
    BasDetay :='1'
  else if  liste.Strings[1]=ComDeger then begin
    BasDetay :='0'
  end else begin
    ShowMessage(SERBaslik_belirtin);
    exit;
  end;
  veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into SERVISLISTE (SERVISTUR,KOD,AD,DIGITSAY,BASLIK,SUBEID) values('''+VarsHint+''','''+Kod+''','''+Aciklama+''',3,'+BasDetay+','+inttoStr(SubeId)+') ',[],[]);
  KADlg.TabKodAgaci.Close;
  KADlg.TabKodAgaci.Open;
end;
procedure TServisTanimListeleriAramaFrame.SilbtnClick(Sender:Tobject);
begin
  Tablo.TablodanSorguAc(2,'Select * from SERVISLISTE Where ID='''+KADlg.TabKodAgaci.FieldByName('ID').AsString+''' and KOD='''+KADlg.TabKodAgaci.FieldByName('KOD').AsString+''' and SERVISTUR='+VarsHint+' ');
  if Tablo.Query2.RecordCount=1 then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Delete from SERVISLISTE Where ID='+KADlg.TabKodAgaci.FieldByName('ID').AsString+' and KOD='''+KADlg.TabKodAgaci.FieldByName('KOD').AsString+''' and SERVISTUR='+VarsHint+' ',[],[]);
  KADlg.TabKodAgaci.Close;
  KADlg.TabKodAgaci.Open;
end;

procedure TServisTanimListeleriAramaFrame.DegisClick(Sender: TObject);
var
  Kod,Aciklama,ComDeger:Variant;
  ctrls:TGirdiDenetimleri;
  BasDetay:String;
  liste:TStrings;
begin
  liste:=nil;
  liste:=TStringList.Create;
  liste.Add('Başlık');
  liste.Add('Detay');

  Tablo.TablodanSorguAc(1,'select KOD,ACIKLAMA,BASLIK from SERVISLISTE where  ID='+KADlg.TabKodAgaci.FieldByName('ID').AsString+' and SERVISTUR='+VarsHint+'  order by LEN(KOD)');
  Kod:=Tablo.Query1.FieldByName('KOD').AsString;
  Aciklama:=Tablo.Query1.FieldByName('ACIKLAMA').AsString;
  if Tablo.Query1.FieldByName('BASLIK').AsBoolean then
    ComDeger:='Başlık'
   else
    ComDeger:='Detay';
  ctrls:=TGirdiDenetimleri.Create.Edit(KontrolKod,@Kod).Edit(BGAciklama_gir,@Aciklama).ComboBox((Seciniz),@ComDeger,liste);
  if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls)<> mrOK  then
    Abort;
  if  liste.Strings[0]=ComDeger then
    BasDetay :='1'
  else if  liste.Strings[1]=ComDeger then begin
    BasDetay :='0'
  end else  begin
    ShowMessage(SERBaslik_belirtin);
    exit;
  end;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SERVISLISTE set KOD='''+Kod+''' , ACIKLAMA ='''+Aciklama+''' ,BASLIK ='+BasDetay+' where ID='+KADlg.TabKodAgaci.FieldByName('ID').AsString+' and SERVISTUR='+VarsHint+' ',[],[]);
  KADlg.TabKodAgaci.Close;
  KADlg.TabKodAgaci.Open;
end;
procedure TServisTanimListeleriAramaFrame.TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
var i:Integer;
begin
  for I := 0 to Menu.Categories[0].Items.Count - 1 do
    Menu.Categories[0].items[i].ImageIndex:=ImajIndex;
end;
procedure TServisTanimListeleriAramaFrame.ServisListeTurleriCategoryClicked(Sender: TObject; const Category: TButtonCategory);
begin
 Category.Collapsed := not Category.Collapsed;
end;

procedure TServisTanimListeleriAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TServisTanimListeleriAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisTanimListeleriAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TServisTanimListeleriAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TServisTanimListeleriAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TServisTanimListeleriAramaFrame);
end.




