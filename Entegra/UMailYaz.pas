unit UMailYaz;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, DB, FireDAC.Comp.Client, InvokeRegistry, Rio,
  SOAPHTTPClient,XSBuiltIns, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  System.Net.URLClient;

type
  TMailGonderDlg = class(TForm)
    ADOQuery1: TFDQuery;
    OpenDialog1: TOpenDialog;
    HTTPRIOLisans: THTTPRIO;
    Panel2: TPanel;
    GroupBox3: TGroupBox;
    Label5: TcxLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    MemoSorunlar: TMemo;
    ListEkler: TListBox;
    GroupBox2: TGroupBox;
    SpeedButton1: TSpeedButton;
    Label6: TcxLabel;
    ComboGonderen: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TcxLabel;
    Label4: TcxLabel;
    Label2: TcxLabel;
    Label3: TcxLabel;
    Label7: TcxLabel;
    LabelTesisKodu: TcxLabel;
    LabelTesisAdi: TcxLabel;
    LabelIstekNo: TcxLabel;
    Label8: TcxLabel;
    Label9: TcxLabel;
    Label10: TcxLabel;
    EditKonu: TEdit;
    ComboSube: TComboBox;
    ComboKime: TComboBox;
    ComboOncelik: TComboBox;
    ComboMesajTipi: TComboBox;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MailGonderDlg: TMailGonderDlg;

implementation
  Uses
  UTablo,lisansws,PrjConst,LocOnFly;

{$R *.dfm}

procedure TMailGonderDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:='SELECT KULLANICIADI FROM KULLAN ORDER BY 1';
  Tablo.Query2.Open;

  While not Tablo.Query2.Eof do
    begin
      ComboGonderen.Items.Add(Tablo.Query2.Fields[0].AsString);
      Tablo.Query2.Next;
    end;

//  LabelTesisKodu.Caption:= ReherIni.ReadString('MEDULA','TesisKodu','');
//  LabelTesisAdi.Caption := ReherIni.ReadString('GenelOpsiyon','KURUMADI','');
//  LabelIstekNo.Caption:= IntToStr( ReherIni.ReadInteger('GenelOpsiyon','MailÝstekNo',1));
//
//  ReherIni.ReadSectionValues('GenoTIPPersonel',ComboKime.Items);
  ComboGonderen.ItemIndex:= ComboGonderen.Items.IndexOf(KullanAdi);

end;



procedure TMailGonderDlg.SpeedButton1Click(Sender: TObject);
var
 webservis:  LisansServiceSoap;
 Istekno:  WideString;
 sonuc : widestring;

begin
  if ComboSube.Text='' then
   begin
     Application.MessageBox(PChar(Subebilgisigir),PChar(Uyari), MB_OK+MB_ICONINFORMATION);
     ComboSube.SetFocus;
     abort;
   end;

   if ComboKime.Text='' then
    begin
      Application.MessageBox(PChar(Kimebilgisigir),PChar(Uyari), MB_OK+MB_ICONINFORMATION);
      ComboKime.SetFocus;
      abort;
    end;
   if ComboMesajTipi.Text='' then
    begin
      Application.MessageBox(PChar(Mesajturugir),PChar(Uyari), MB_OK+MB_ICONINFORMATION);
      ComboMesajTipi.SetFocus;
      abort;
    end;
   if ComboOncelik.Text='' then
    begin
      Application.MessageBox(PChar(Oncelikgir),PChar(Uyari), MB_OK+MB_ICONINFORMATION);
      ComboOncelik.SetFocus;
      abort;
    end;
   if ComboGonderen.Text='' then
    begin
      Application.MessageBox(PChar(Gonderengir),PChar(Uyari), MB_OK+MB_ICONINFORMATION);
      ComboGonderen.SetFocus;
      abort;
    end;

    try
     {
       gönderim iþlemi için gerekli kod buraya
      }
     webservis := GetLisansServiceSoap(false, '', HTTPRIOLisans);
     Istekno:=LabelIstekNo.Caption;
     webservis.MesajKaydet( '' , Istekno, '', ComboGonderen.Text, ComboMesajTipi.Text, EditKonu.Text, MemoSorunlar.Lines.Text, ComboOncelik.Text, ComboSube.Text , ComboKime.Text );

      // gönderimden sonra istek numarasýnýn arttýrýlmasý
  //   ReherIni.Writeinteger('GenelOpsiyon','MailÝstekNo',strtoint(LabelIstekNo.Caption)+1);

      Application.MessageBox(PChar(Gonderildi),PChar(Bilgi),MB_OK+ MB_ICONINFORMATION);

    except
      Application.MessageBox(PChar(Gonderim_tamam),PChar(Uyari),MB_OK+MB_ICONERROR);
    end;
end;


procedure TMailGonderDlg.SpeedButton2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
     ListEkler.Items.Add(OpenDialog1.FileName);
end;

procedure TMailGonderDlg.SpeedButton3Click(Sender: TObject);
begin
   if ListEkler.Items.Count = 0 then exit;
               
  if ListEkler.ItemIndex>=0 then
   begin
      if Application.MessageBox(PChar(Listedencikarilsinmi),PChar(Onay),MB_YESNO+MB_ICONQUESTION)=ID_YES then
        ListEkler.Items.Delete(ListEkler.ItemIndex);
   end;
end;

end.

