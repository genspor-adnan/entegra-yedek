unit UTerazi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxDropDownEdit,
  Dialogs, ComCtrls, ToolWin, dxSkinsCore, dxSkinLondonLiquidSky, JvExControls, JvButton, JvNavigationPane, cxLabel, cxEdit, cxTextEdit, cxCurrencyEdit, ExtCtrls, cxControls, cxContainer, cxListBox, CPort, StdCtrls,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTeraziDlg = class(TForm)
    ListBoxDara: TcxListBox;
    PanelButtomRight: TPanel;
    Panel1: TPanel;
    Panel4: TPanel;
    cxCurrencyEdit1: TcxCurrencyEdit;
    cxCurrencyEdit2: TcxCurrencyEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxCurrencyEdit3: TcxCurrencyEdit;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    KaydetTus: TJvNavPanelButton;
    cxLabel10: TcxLabel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    JvNavPanelButton1: TJvNavPanelButton;
    JvNavPanelButton2: TJvNavPanelButton;
    ComPort: TComPort;
    cxLabel1: TcxLabel;
    EditDaraToplam: TcxCurrencyEdit;
    cxLabel5: TcxLabel;
    LabelComport: TcxCurrencyEdit;
    EditNetTarti: TcxCurrencyEdit;
    cxLabel6: TcxLabel;
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvNavPanelButton2Click(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JvNavPanelButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Gr_Kg_Cevir : Boolean;
  end;

var
  TeraziDlg: TTeraziDlg;

implementation

{$R *.dfm}

uses Utablo, PrjConst,LocOnFly, UHizliGiris, Fetautil, UHizliGirisIsk;
var
   DaraKodList :TcxCustomComboBoxProperties;
   ToplamDara : Real;
   Okunan : String;

procedure TTeraziDlg.ComPortRxChar(Sender: TObject; Count: Integer);
var
  Str : String[25];
  s : String;
  c:char;
  i, p, bas:integer;
  Buffer: PChar;
begin       //ST,GS- 64.680,kg      dönen deðer
               //     s 64.680
               //ST,GS 15    iki satýr halinde geliyor
               //4.020,kg
  ComPort.ReadStr(s, 25);
  //Memo1.Lines.Add(IntToStr(Count)+'s>' + s);
  Okunan := Okunan+s;   //2 satýr halinde okuduðu için sonu kg olana kadar topluyoruz
  if Length(Okunan)>14 then begin
  //if Pos('kg', Okunan)>0 then begin
      //Memo1.Lines.Add('Oku>' + Okunan);
      Str := '';
      for I := 0 to Length(Okunan)-1 do begin
        c:=Okunan[i];
        if (Ord(c) in [48..57])or(Ord(c) = 46) then  //0..9 veya . ise
            Str := Str + c;
      end;

     // Memo1.Lines.Add('->'+str);

     // Str:='ST,GS- 64.660,kg';
       Str:=StringReplace(Str,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
       Str:=StringReplace(Str,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
       LabelComport.Value := StrToFloatDef(Str,0);
       EditNetTarti.Value := LabelComport.Value - EditDaraToplam.Value;
       Okunan:='';
  end;
end;

procedure TTeraziDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DaraKodList.Free;
  DaraKodList := nil;
  if ComPort.Connected then
     ComPort.Close;
end;

procedure TTeraziDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTeraziDlg.FormShow(Sender: TObject);
var str : string;
begin
   Okunan:='';
   if DaraKodList = nil then
      DaraKodList := TcxCustomComboBoxProperties.Create(nil)
   else
      DaraKodList.Items.Clear;
    ListBoxDara.Clear;
    //ListBoxDara.Items.Add('Toplam 0 gr');
    ToplamDara := 0;
    EditDaraToplam.Value := ToplamDara;
    Tablo.GENINI.ReadSection(Ops_HizliSatisDaraKod, DaraKodList);
    Gr_Kg_Cevir := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_Terazi_Kg_Cevir, True);

    if DaraKodList.Items.Count = 0 then
       raise Exception.Create(DaraKodGirilmemis);

 // Terazi varmý
  if GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C') <> '' then begin

     ComPort.Port := Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziPort) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'COM1');

     if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziBoudRare) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'9600')='9600' then
       ComPort.BaudRate := br9600
     else
       ComPort.BaudRate := br4800;

     if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziDataBits) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'8')='8' then
       ComPort.DataBits := dbEight
     else
       ComPort.DataBits := dbSeven;

     if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziStopBits) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'1')='1' then
       ComPort.StopBits := sbOneStopBit
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziStopBits) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'2')='2' then
       ComPort.StopBits := sbTwoStopBits
     else
       ComPort.StopBits := sbOne5StopBits;

     if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziParity) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None') = 'None' then
       ComPort.Parity.Bits := prNone
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziParity) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='Even' then
       ComPort.Parity.Bits := prEven
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziParity) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='Mark' then
       ComPort.Parity.Bits := prMark
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziParity) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='Odd' then
       ComPort.Parity.Bits := prOdd
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziParity) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='Space' then
       ComPort.Parity.Bits := prSpace;

     if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziFlowControl) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None') = 'None' then
       ComPort.FlowControl.FlowControl := fcNone
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziFlowControl) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='Custom' then
       ComPort.FlowControl.FlowControl := fcCustom
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziFlowControl) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='HardWare' then
       ComPort.FlowControl.FlowControl := fcHardware
     else if Tablo.GENINI.ReadString(StrToInt(IntToStr(Ops_HizliGiris_TeraziFlowControl) + GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanTerazi', '', 'C')),'None')='SoftWare' then
       ComPort.FlowControl.FlowControl := fcSoftware;

    if ComPort.Connected then
      ComPort.Close
    else
      ComPort.Open;
  end;
end;

procedure TTeraziDlg.JvNavPanelButton1Click(Sender: TObject);
var Adet, secilen : Integer;
    s : string;
begin

   secilen := ListBoxDara.ItemIndex;
   if secilen < 0 then
      secilen := ListBoxDara.Items.Count-1;
   if Application.MessageBox(PChar(ListBoxDara.Items[secilen]+IptalEdilsinmi),PCHAR(Onay),MB_YESNO + MB_ICONINFORMATION)=ID_YES then begin
      s:= ListBoxDara.Items[secilen];
      Adet := StrToIntDef(Copy(s,1,pos('X',s)-2),1);
      Delete(s,1,pos('X',s)+1);
      ListBoxDara.Items.Delete(secilen);
      if ListBoxDara.Items.Count=0 then
         ToplamDara := 0
      else
         ToplamDara := ToplamDara-(Adet*StrToFloatDef(s,0));
      EditDaraToplam.Value := ToplamDara;
      EditNetTarti.Value := LabelComport.Value - EditDaraToplam.Value;
   end;
end;

procedure TTeraziDlg.JvNavPanelButton2Click(Sender: TObject);
var s : string;
    i : Integer;
    Adet : Real;
    SonucListe: TStringList;
begin
  //dara kodlarýndan liste için sql oluþturulur
  s:='';
  for i := 0 to DaraKodList.Items.Count - 1 do begin
    if i > 0 then s:=s+'or';
    s := s + ('(KOD like '''+DaraKodList.Items[i]+'.%'' )');
  end;
  SonucListe := TStringList.Create;
  if Tablo.HizliGirisListedenBilgiGetir('Dara (Boþ Aðýrlýk) Seçimi','select ID, STOKADI,BIRIM2MIKTAR from STOKLAR where '+s+' union all select ID=-1, STOKADI=''Elle Giriþ'',BIRIM2MIKTAR=null',SonucListe,False,[False, True, True],[])then begin
     Adet:=AdetGetir('Adet giriniz','1',0, 0, False);
     if SonucListe[0]='-1' then //elle giriþ
        s:=FloatToStr(AdetGetir('Dara (Boþ Aðýrlýk) Giriniz', '100', 0, 0, False))
     else
        s:= SonucListe[2];
     ListBoxDara.Items.Add(FloatToStr(Adet)+' X '+s);
     ToplamDara := ToplamDara + Adet*StrToFloat(s);
     //ListBoxDara.Items[0] := 'Toplam '+FloatToStr(ToplamDara)+' gr';
     EditDaraToplam.Value := ToplamDara;
  end;
  SonucListe.Free;
  EditNetTarti.Value := LabelComport.Value - EditDaraToplam.Value;
end;

procedure TTeraziDlg.JvNavPanelButton3Click(Sender: TObject);
begin
   ComPort.Close;
end;

procedure TTeraziDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TTeraziDlg.KaydetTusClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

end.
