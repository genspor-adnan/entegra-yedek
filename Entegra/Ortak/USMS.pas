unit USMS;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Mask, Buttons, Db, UFDCompatHelpers, ComCtrls, Grids, DBGrids,
  IdMessage, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase, IdSMTP,dateutils;

type
  TSmsDlg = class(TForm)
    Label2: TLabel;
    lbKalKarakter: TLabel;
    gbZamanli: TGroupBox;
    lbBaslangicTarihi: TLabel;
    dtpBaslangic: TDateTimePicker;
    dtpBaslangicSaat: TDateTimePicker;
    lbBitisTarihi: TLabel;
    dtpBitis: TDateTimePicker;
    dtpBitisSaat: TDateTimePicker;
    rgZamanlama: TRadioGroup;
    rgTercih: TRadioGroup;
    Panel1: TPanel;
    Panel3: TPanel;
    TabControl1: TTabControl;
    mMesaj: TMemo;
    EditGSMNo: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    sbGonder: TSpeedButton;
    Panel5: TPanel;
    DBGrid1: TDBGrid;
    TabSMS: TADOQuery;
    DtsSMS: TDataSource;
    cbHazirMesaj: TComboBox;
    Label4: TLabel;
    sbKaydet: TSpeedButton;
    Label5: TLabel;
    EditEPosta: TEdit;
    InMailGonderme: TIdSMTP;
    IdEpostaMesaj: TIdMessage;
    procedure SpeedButton2Click(Sender: TObject);
    procedure mMesajChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);


    procedure rgZamanlamaClick(Sender: TObject);
    procedure sbGonderClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure dtpBaslangicChange(Sender: TObject);
    procedure cbHazirMesajDblClick(Sender: TObject);
    procedure cbHazirMesajChange(Sender: TObject);
    procedure sbKaydetClick(Sender: TObject);
    procedure cbHazirMesajDropDown(Sender: TObject);
    procedure rgTercihClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SMSAt;
    procedure EpostaAt;
  end;

var
  SmsDlg: TSmsDlg;
  tussay: integer;
  XmlBody, XmlHeader, XmlTum, SMSMesaj1: TStrings;
  vbReferans, vbDosyano, ad, soyad, kulllanici: string[50];
  vbHata: smallint;
  vbBasTarZaman, vbBitTarZaman: TDateTime;
  GondermeZamanli: boolean;
  ILETI_KAYITNO, ILETI_GSMNO, ILETI_EPOSTA, SMSSonucMSG,EpostaSonucMsg: string;

implementation
uses Utablo, USMSIslemleri, UHazirSMS, umesaj, UCombo, URaporAraclari,PrjConst,LocOnFly;

var
  AjandaIni: TIni;

{$R *.DFM}

procedure TSmsDlg.SpeedButton2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TSmsDlg.mMesajChange(Sender: TObject);
begin
  lbKalKarakter.Caption := IntToStr(160 - Length(mMesaj.Text));

end;

procedure TSmsDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
if AjandaIni=nil then
  AjandaIni := TIni.Create('AJANDAINI', tablo.IniSQL);
end;


procedure TSmsDlg.rgZamanlamaClick(Sender: TObject);
begin
  if rgZamanlama.ItemIndex = 0 then
    gbZamanli.Visible := False
  else
    gbZamanli.Visible := True;
end;


procedure TSmsDlg.EpostaAt;
var    hata: boolean;
//       lTextPart: TIdText;
//       lImagePart: TIdAttachmentFile;


begin
  hata := false;

  InMailGonderme.Host := AjandaIni.ReadString('EpostaSecenekler', 'EPostaServer', '');
  InMailGonderme.Username := AjandaIni.ReadString('EpostaSecenekler', 'EPostaKullanici', '');
  IdEpostaMesaj.MessageParts.Clear;

  IdEpostaMesaj.Body.Text := mMesaj.Text;
  IdEpostaMesaj.From.Text := AjandaIni.ReadString('EpostaSecenekler', 'EPostaKullanici', '');
  IdEpostaMesaj.Sender.Name := AjandaIni.ReadString('EpostaSecenekler', 'EPostaGonderen', '');
  IdEpostaMesaj.Recipients.EMailAddresses := EditEPosta.Text;
  IdEpostaMesaj.Subject := '';

  if AjandaIni.ReadBool('EpostaSecenekler', 'EpostaDogrulama', False) then
  begin
    InMailGonderme.AuthType := satDefault;
    InMailGonderme.Password := AjandaIni.ReadString('EpostaSecenekler', 'EPostaParola', '');
  end
  else
    InMailGonderme.AuthType := satNone;

  IdEpostaMesaj.ContentType := 'multipart/mixed';
  InMailGonderme.Connect;

  try
    InMailGonderme.Send(IdEpostaMesaj);

  except
    on E: Exception do
    begin
      hata := true;
      if pos('unknown', E.Message) > 0 then
         EpostaSonucMsg:='Hatalý Mail adresi'
      else
        EpostaSonucMsg:='Baþarýsýz';
    end;
  end;
  InMailGonderme.Disconnect;

  if not (hata) then begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'INSERT INTO [SMSPOSTA]([KAYITNO], [TELEFON], [TARIH], [GONDERIMTARIHI], [MODUL], [MESAJ], [SONUC], [GONDEREN], [MSGREFERANSKOD], [SERVIS] ,[ILETITURU],[EPOSTA],STATU,[SUBEID])' +
      ' VALUES(:PRM1,:PRM2,:PRM3,:PRM4,:PRM5,:PRM6,:PRM7,:PRM8,:PRM9,:PRM10,:PRM11,:PRM12,:PRM13,:PRM14 )';

    Tablo.Query1.Parameters.ParamByName('PRM1').Value := ILETI_KAYITNO;
    Tablo.Query1.Parameters.ParamByName('PRM2').Value := '';
    Tablo.Query1.Parameters.ParamByName('PRM3').Value := FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh);
    Tablo.Query1.Parameters.ParamByName('PRM4').Value := FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh);
    Tablo.Query1.Parameters.ParamByName('PRM5').Value := TRaporAraclari.Modul;
    Tablo.Query1.Parameters.ParamByName('PRM6').Value := mMesaj.Text;
    Tablo.Query1.Parameters.ParamByName('PRM7').Value := 'Gönderildi';
    Tablo.Query1.Parameters.ParamByName('PRM8').Value := Kullanan;
    Tablo.Query1.Parameters.ParamByName('PRM9').Value := '';
    Tablo.Query1.Parameters.ParamByName('PRM10').Value := '';
    Tablo.Query1.Parameters.ParamByName('PRM11').Value := 'E-Posta';
    Tablo.Query1.Parameters.ParamByName('PRM12').Value := EditEPosta.Text;
    Tablo.Query1.Parameters.ParamByName('PRM13').Value := 1;
    Tablo.Query1.Parameters.ParamByName('PRM14').Value := SubeId;
    Tablo.Query1.ExecSQL;
    EpostaSonucMsg:='Gönderildi';
  end;

end;

procedure TSmsDlg.SMSAt;
var MesajIcerik,  GSMNo: string;
  MesajKumesi: array of TSmsMesaj;
  sonuc: TSmsMesajSonuc;

begin
  if rgZamanlama.ItemIndex = 1 then //Zamanlý SMS gönderilmesi
  begin
    GondermeZamanli := True;
//      vbBasTarZaman :=     dtpBaslangic.Date + dtpBaslangicSaat.Time;
  //    vbBitTarZaman := dtpBitis.Date + dtpBitisSaat.Time;

      vbBasTarZaman := EncodeDateTime(YearOf(dtpBaslangic.Date ),MonthOf(dtpBaslangic.Date),DayOf(dtpBaslangic.Date) ,HourOf(dtpBaslangicSaat.Time),MinuteOf(dtpBaslangicSaat.Time),SecondOf(dtpBaslangicSaat.Time),MilliSecondOf(dtpBaslangicSaat.Time)) ;
      vbBitTarZaman := EncodeDateTime(YearOf(dtpBitis.Date ),MonthOf(dtpBitis.Date),DayOf(dtpBitis.Date) ,HourOf(dtpBitisSaat.Time),MinuteOf(dtpBitisSaat.Time),SecondOf(dtpBitisSaat.Time),MilliSecondOf(dtpBitisSaat.Time)) ;


//    vbBasTarZaman := FormatDateTime('ddmmyyyy', dtpBaslangic.Date) + FormatDateTime('hhnnss', dtpBaslangicSaat.Time);
 //   vbBitTarZaman := FormatDateTime('ddmmyyyy', dtpBitis.Date) + FormatDateTime('hhnnss', dtpBitisSaat.Time);
  end
  else
    GondermeZamanli := False;

  GSMNo := TelFormatla(EditGSMNo.Text);
  SetLength(MesajKumesi, 1);
  MesajIcerik := MesajMetni(mMesaj.Text);
  MesajKumesi[0].Mesaj := MesajIcerik;
  MesajKumesi[0].Numara := GSMNo;
  MesajKumesi[0].Id := -1;

  Sonuc := TopluSmsAt(MesajKumesi, vbBasTarZaman, vbBitTarZaman, GondermeZamanli);
  // Hata yoksa tabloya atalým.
  if sonuc.HataKodu = '-1' then
  begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'INSERT INTO [SMSPOSTA]([KAYITNO], [TELEFON], [TARIH], [GONDERIMTARIHI], [MODUL], [MESAJ], [SONUC], [GONDEREN], [MSGREFERANSKOD], [SERVIS] ,[ILETITURU],[EPOSTA],STATU,[SUBEID])' +
      ' VALUES(:PRM1,:PRM2,:PRM3,:PRM4,:PRM5,:PRM6,:PRM7,:PRM8,:PRM9,:PRM10,:PRM11,:PRM12 ,:PRM13,:PRM14)';

    Tablo.Query1.Parameters.ParamByName('PRM1').Value := ILETI_KAYITNO;
    Tablo.Query1.Parameters.ParamByName('PRM2').Value := GSMNo;
    Tablo.Query1.Parameters.ParamByName('PRM3').Value := FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrh);
    Tablo.Query1.Parameters.ParamByName('PRM4').Value := FormatDateTime('yyyy-mm-dd', dtpBaslangic.Date) ;
    Tablo.Query1.Parameters.ParamByName('PRM5').Value := TRaporAraclari.Modul;
    Tablo.Query1.Parameters.ParamByName('PRM6').Value := MesajIcerik;
    Tablo.Query1.Parameters.ParamByName('PRM7').Value := '';
    Tablo.Query1.Parameters.ParamByName('PRM8').Value := Kullanan;
    Tablo.Query1.Parameters.ParamByName('PRM9').Value := sonuc.MesajRefNo;
    Tablo.Query1.Parameters.ParamByName('PRM10').Value := SMSHesapBilgileri.SMSServisSaglayici;
    Tablo.Query1.Parameters.ParamByName('PRM11').Value := 'SMS';
    Tablo.Query1.Parameters.ParamByName('PRM12').Value := '';
    Tablo.Query1.Parameters.ParamByName('PRM13').Value := 1;
    Tablo.Query1.Parameters.ParamByName('PRM14').Value := SubeId;
    Tablo.Query1.ExecSQL;
  end;
  SMSSonucMSG := sonuc.Mesaj;
end;

procedure TSmsDlg.sbGonderClick(Sender: TObject);
var GsmNo: string;
  HataMesaji, SonucMesaji: TStringList;

  function EpostaKontrol: boolean;
  begin
    if pos('@', EditEPosta.Text) <> 0 then
      result := True
    else
      result := False;
  end;

  function GSMNoKontrol: boolean;
  begin
    if TelFormatla(EditGSMNo.Text) <> '0' then
      result := True
    else
      result := False;

  end;

begin
// **************  HATALI VEYA EKSÝK ALANLAR KONTROL EDÝLÝYOR ****************
  HataMesaji := TStringList.Create;
  HataMesaji.Clear;
  if rgtercih.ItemIndex = 0 then
  begin
    if Trim(EditGSMNo.Text) = '' then
      HataMesaji.Add('GSM numarasý alaný boþ.')
    else if not GSMNoKontrol then
      HataMesaji.Add('GSM numarasý hatalý.');

    if Length(mMesaj.Text) > 160 then
      HataMesaji.Add('Mesaj uzunluðu kapasiteden fazla.')
  end

  else if rgtercih.ItemIndex = 1 then
  begin
    if trim(EditEPosta.Text) = '' then
      HataMesaji.Add('E-Posta adresi boþ.')
    else if not EpostaKontrol then
      HataMesaji.Add('E-Posta adresi geçersiz.');
  end
  else
  begin
    if Trim(EditGSMNo.Text) = '' then
      HataMesaji.Add('GSM numarasý alaný boþ.')
    else if not GSMNoKontrol then
      HataMesaji.Add('GSM numarasý hatalý.');

    if trim(EditEPosta.Text) = '' then
      HataMesaji.Add('E-Posta adresi boþ.')
    else if not EpostaKontrol then
      HataMesaji.Add('E-Posta adresi geçersiz.');

    if Length(mMesaj.Text) > 160 then
      HataMesaji.Add('Mesaj uzunluðu kapasiteden fazla.')
  end;

  if trim(mMesaj.Text) = '' then
    HataMesaji.Add('Mesaj içeriði boþ.');

  if HataMesaji.Text <> '' then
  begin
    Application.MessageBox(pchar(HataMesaji.text), PCHAR(Uyari), MB_OK + MB_ICONWARNING);
    HataMesaji.Free;
    Abort;
  end;
  HataMesaji.Free;
// **************  HATALI VEYA EKSÝK ALANLAR KONTROL EDÝLÝYOR **************** SONU
// **************  HATA YOK ÝSE GÖNDERÝM ÝÞLEMÝ BAÞLIYOR ****************

  if rgTercih.ItemIndex = 0 then begin // Tercih SMS
    SMSAt;
    Application.MessageBox(pchar(SMSSonucMSG), PCHAR(Bilgi), MB_OK + MB_ICONINFORMATION);
  end   else if rgTercih.ItemIndex = 1 then begin // Tercih E-Posta
    EPostaAt;
    Application.MessageBox(pchar(EpostaSonucMsg), PCHAR(Bilgi),MB_OK);
    SMSAt;
    Application.MessageBox(pchar('SMS     : '+ SMSSonucMSG+#13+#10 + 'E-Posta : '+EpostaSonucMsg), PCHAR(Bilgi), MB_OK + MB_ICONINFORMATION);
  end;
// **************  HATA YOK ÝSE GÖNDERÝM ÝÞLEMÝ BAÞLIYOR **************** SONU

 Self.Close;
end;

procedure TSmsDlg.FormShow(Sender: TObject);
Var Durum:String;
    Statu:integer;
begin
  mMesaj.MaxLength := 160;
  lbKalKarakter.Visible := True;
  dtpBaslangic.Date := Date;
  dtpBaslangicSaat.Time := Time;
  dtpBitis.Date := Date;
  dtpBitisSaat.Time := Time;
  rgZamanlama.ItemIndex := 0;
  mMesajChange(nil);

  EditGSMNo.Text := ILETI_GSMNO;
  EditEPosta.Text := ILETI_EPOSTA;
  TabSMS.Close;
  TabSMS.LockType := ltOptimistic;
  TabSMS.Parameters[0].Value := ILETI_KAYITNO;
  TabSMS.Open;

  while not TabSMS.Eof do
  begin
    if (TabSMS.FieldByName('ILETITURU').AsString = 'SMS') and ((TabSMS.FieldByName('SONUC').AsString = '') or (TabSMS.FieldByName('SONUC').AsString = 'Beklemede')) then
    begin
      TabSMS.Edit;
      try
        Durum:=SMSGonderiKontrolTek(TabSMS.FieldByName('MSGREFERANSKOD').AsString, TabSMS.FieldByName('SERVIS').AsString);
        if Durum='Baþarýlý' then Statu:=9
        else if Durum='Hatalý' then Statu:=-1
        else if Durum='Zaman Aþýmý' then Statu:=-1
        else if Durum='Reddedildi' then Statu:=-1
        else Statu:=1;

        TabSMS.FieldByName('SONUC').AsString :=Durum;
        TabSMS.FieldByName('STATU').AsInteger :=Statu;

        TabSMS.Post;
      except
        TabSMS.Cancel;
      end;
    end;
    TabSMS.Next;
  end;
  TabSMS.Close;
  TabSMS.LockType := ltReadOnly;
  TabSMS.Open;

  mmesaj.SetFocus;
end;

procedure TSmsDlg.dtpBaslangicChange(Sender: TObject);
begin
  dtpBitis.Date := dtpBaslangic.Date;
end;

procedure TSmsDlg.cbHazirMesajDblClick(Sender: TObject);
begin
  if HazirSMSDlg = nil then
    Application.CreateForm(THazirSMSDlg, HazirSMSDlg);
  HazirSMSDlg.showmodal;

end;

procedure TSmsDlg.cbHazirMesajChange(Sender: TObject);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select MESAJ FROM SMSPOSTAHAZMESAJ where BASLIK=''' + cbHazirMesaj.Text + '''';
  Tablo.Query1.Open;
  mMesaj.Text := Tablo.Query1.Fields[0].AsString;
end;

procedure TSmsDlg.sbKaydetClick(Sender: TObject);
var msgbaslik: boolean; Baslik: string;
begin
  if mMesaj.Text = '' then exit;
  msgbaslik := False;
  while not msgbaslik do begin
    if MesajStrAl('Hazýr Mesaj', 'Mesaj Baþlýðý Giriniz :', 'E', nil, Baslik, '', 'E', nil, Baslik) then
    begin
      if Baslik = '' then
        raise Exception.Create(MsgBaslikYaz);

      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'select * FROM SMSPOSTAHAZMESAJ WHERE BASLIK=''' + Baslik + '''';
      tablo.Query2.Open;
      if tablo.Query2.RecordCount > 0 then begin
        if Application.MessageBox(PCHAR(MsgUzerinekayitedilsinmi), PCHAR(Uyari), MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'update SMSPOSTAHAZMESAJ set MESAJ=''' + mMesaj.Text + ''' WHERE BASLIK=''' + Baslik + '''';
          tablo.Query2.ExecSQL;
          msgbaslik := True;
        end //if Application.MessageBox
        else
          msgbaslik := False;
      end // if tablo.Query2.RecordCount > 0 then begin
      else
      begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'INSERT INTO SMSPOSTAHAZMESAJ (BASLIK,MESAJ,DURUM,SUBEID ) ' +
          ' VALUES (''' + Baslik + ''',''' + mMesaj.Text + ''',''Aktif'','+IntToStr(SubeId)+')';
        Tablo.Query1.ExecSQL;
        msgbaslik := True;
      end; // not if tablo.Query2.RecordCount > 0 then
    end; // if MesajStrAl('') then
  end; //  While


end;

procedure TSmsDlg.cbHazirMesajDropDown(Sender: TObject);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select DISTINCT BASLIK FROM SMSPOSTAHAZMESAJ WHERE durum=''Aktif'' order BY BASLIK';
  Tablo.Query1.Open;
  cbHazirMesaj.Clear;
  while not tablo.Query1.Eof do
  begin
    cbHazirMesaj.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.next;
  end;

end;

procedure TSmsDlg.rgTercihClick(Sender: TObject);
begin
  if rgTercih.ItemIndex = 1 then begin
    rgZamanlama.Visible := False;
    gbZamanli.Visible := False;
    mMesaj.MaxLength := 0;
    lbKalKarakter.Visible := False;
  end else begin
    rgZamanlama.Visible := True;
    rgZamanlama.ItemIndex := 0;
    mMesaj.MaxLength := 160;
    lbKalKarakter.Visible := True; ;
  end;

end;

end.


