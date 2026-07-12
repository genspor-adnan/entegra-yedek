{
#### MODUL KOD Listesi ####

Modul1	Ajanda
Modul2	Ameliyat
Modul3	Anket
Modul4	Diyaliz
Modul5	DoğanBebek
Modul6	Evrak Defteri
Modul7	Evrak Takip
Modul8	Fatura Takip
Modul9	GARS
Modul10	Gen95
Modul11	GenLAB
Modul12	GenMedula
Modul13	GenScan
Modul14	Genspor
Modul15	Gentegre
Modul16	Giykimbil
Modul17	Hızlı Giriş
Modul18	KamuLab
Modul19	Kayıtkabul
Modul20	Kullanan
Modul21	Lab
Modul22	LIS - Cihaz bağlantısı
Modul23	LISNET
Modul24	Medula Entegrasyon
Modul25	Muayene
Modul26	Persona
Modul27	Radyoloji
Modul28	Randevu
Modul29	Servis
Modul30	Stok
Modul31	Sıramatik
Modul32	Tüp Bebek
Modul33	Yönlendirme
Modul34	İşyeri Hekimliği
Modul35	Magic SAS
Modul36	Muhasebe Entegrasyonu

}

unit ULisans;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, BHDInfo, piKeyPass, ComCtrls, ToolWin, UCombo,
  Buttons, cxControls, cxContainer, cxEdit, cxTextEdit, UGenSifre, LisansWs,
  InvokeRegistry, Rio, SOAPHTTPClient, jpeg;

type
  TLisansDlg = class(TForm)
    Label6: TLabel;
    ToolBar1: TToolBar;
    CancelBtn: TToolButton;
    OKBtn: TToolButton;
    Label10: TLabel;
    piKeyPass1: TpiKeyPass;
    BHDInfo1: TBHDInfo;
    LblLisans: TLabel;
    Label11: TLabel;
    LblLisansMsg: TLabel;
    Label12: TLabel;
    BtnLisans: TSpeedButton;
    Image1: TImage;
    TxtTerminal: TcxTextEdit;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BtnLisansClick(Sender: TObject);
  private

  public


  end;

var
  LisansDlg: TLisansDlg;


procedure LisansKntrl;

implementation

{$R *.DFM}

uses UTablo, DB, DateUtils, FetaUtil;
var s1, s2, LisansNo, LisansTar: string[30];
  BilgisayarAdi:array [0..127] of char;
  i, uz: smallint;
  Kapat: boolean;
  lisansHata, lisansDevam: smallint;
  lisansMesaj, lisansTerminal, lisansKey, lisansMac: string;
  AcikLisans: string;
  lisansSayisi: integer;
  lisansbilgi: array[1..100] of string;
  GunTarihi: Tdate;
   //Lisanssrv: LisansServiceSoap;

procedure LisansKntrl;
var s, s2: string;
  SonLisansTarihi: TDate;
  Items: TStrings;
  lws: smallint;


begin
  Items := tstringlist.Create;
  lisansKey := '';
  lws := 1;

    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text := 'select * from sysobjects where name = ''GENOTIP''';
    Tablo.Query2.Open;
    if Tablo.Query2.RecordCount=0 then
       raise Exception.Create('Öncelikle Lisanslama Modülünü çalıştırmalısınız..');

  // Makinenin MAC i Şirkete ait Bir MAC olarak kayıtlı mı?
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'select * from GENOTIP WHERE CAST(SABIT as INT) >= ''10000'' AND cast(DEGER as varchar(2000)) = ''' + Sifre(StringReplace(GetMACAdress, '-', '', [rfReplaceAll])) + '''';
  Tablo.Query3.Open;

  // Şirkete ait herhangi bir MAC adresi mi?
  if (Tablo.Query3.RecordCount = 0) then
  begin

  // Sistemdeki SonLisansTarihi Alınıyor...
    Tablo.Query5.Close;
    Tablo.Query5.SQL.Text := 'Select * from GENOTIP WHERE SABIT = ''55''';
    Tablo.Query5.Open;
    Tablo.Query5.First;

  //SonLisansTarihi := StrToDate(DeSifre(Tablo.Query5.FieldByName('DEGER').AsString));

  // Sistemde var olan Açık Lisans Bilgisi alınıyor.
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'select *, convert(datetime,convert(varchar(10),GETDATE(),103),103) as BUGUN from GENOTIP WHERE SABIT = ''50''';
    Tablo.Query3.Open;

  // Sistemde var olan Açık Lisans Bilgisi alınıyor.
    s := DeSifre(Tablo.Query3.FieldByName('DEGER').AsString);

    lisansMac := copy(s, 1, 12);
    Delete(s, 1, 12);
    Items.CommaText := StringReplace(s, ';', ',', [rfreplaceall]);

    GunTarihi := Tablo.Query3.FieldByName('BUGUN').AsDateTime;



  // Sistemde var olan Kapalı Lisans Bilgisi alınıyor.
    Tablo.Query2.Close;
    Tablo.Query2.SQL.Text := 'select * from GENOTIP WHERE SABIT = ''51''';
    Tablo.Query2.Open;

    s2 := DeSifre(Tablo.Query2.FieldByName('DEGER').AsString);

    Items.CommaText := StringReplace(s, ';', ',', [rfreplaceall]);

    lisansSayisi := StrToInt(Items.Values['LisansSayisi']);

  //  Sistemin çalışması için izin var mı?
    if Items.Values['YazilimCalissin'] = '1' then
    begin
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text := 'SELECT * FROM GENOTIP WHERE SABIT >= ''1000'' AND	cast(DEGER as varchar(250)) = cast(''' + Sifre(StringReplace(GetMACAdress, '-', '', [rfReplaceAll])) + ''' as varchar(250)) AND DURUM <> ''0''';
      Tablo.Query4.Open;
      Tablo.Query4.First;

      // Terminal kayıtlı mı?
      if Tablo.Query4.RecordCount <> 0 then
      begin
        // Modul Yetkisi Var mı?
        if Items.Values[LisansModul] = '1' then
        begin
          // Lisans Web Service'ten tekrar alınması gerekiyor mu?
//          if (GunTarihi > StrToDate(DeSifre(Tablo.Query5.FieldByName('DEGER').AsString))) and (LisansModul = 'Modul19') then
          if ((DaysBetween(GunTarihi, StrToDate(DeSifre(Tablo.Query5.FieldByName('DEGER').AsString)))) >= StrToInt(Items.Values['LisansSorgulamaSuresi'])) and (LisansModul = 'Modul19') then
          begin
            try
              // Web service'ten dönen değer ile Lisans Güncellenecek...
              AcikLisans := Lisanssrv.AcikLisans(StrToInt(Items.Values['KurumKod1']), StrToInt(Items.Values['KurumKod2']), lisansMac);

              // Sistemdeki KapalıLisans'taki Server MAC ile Merkezden alınan AçıkLisans'tak, MAC ler tutuyormu?
              if copy(AcikLisans, 1, 12) = copy(s2, 1, 12) then
              begin
                lws := 1;
                Tablo.Query3.Close;
                Tablo.Query3.SQL.Text := 'UPDATE GENOTIP SET DEGER = ''' + Sifre(AcikLisans) + ''' WHERE SABIT = ''50'' ';
                Tablo.Query3.ExecSQL;

                Tablo.Query3.Close;
                Tablo.Query3.SQL.Text := 'UPDATE GENOTIP SET DEGER = ''' + Sifre(DateToStr(GunTarihi)) + ''' WHERE SABIT = ''55'' ';
                Tablo.Query3.ExecSQL;

              end
              else
                lws := 0

            except
              lws := 1;
            end;
          end; // Lisans Web Service'ten tekrar alınması gerekiyor mu?

          // Web serviceten dönen değer veya hiç sorgulamadan durum lisans kontrolü yapmaya müsait olduğunu belirtirse...
          if lws = 1 then
          begin
            if Items.Values['SatisTipi'] = '2' then
            begin
              if GunTarihi - StrToDateTime(Items.Values['LisansTarihi']) <= StrToInt(Items.Values['LisansSuresi']) then
              begin // Demo Süresi içerisinde ise.
                lisansHata := 1;
                lisansMesaj := 'Demo süresinin dolmasına '; //+ StrToInt(Items.Values['LisansSuresi']) - (GunTarihi-StrToDateTime(Items.Values['LisansTarihi'])) + ' gün kalmıştır.';
                lisansDevam := 1;
                lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
              end
              else // Demo süresi dolmuş ise....
              begin
                lisansHata := 1;
                lisansMesaj := 'Demo süresi dolmuştur.';
                lisansDevam := 0;
                lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
              end;
            end
            else // Satış Türü "KİRA" ise...
              if Items.Values['SatisTipi'] = '1' then
              begin
                if GunTarihi - StrToDateTime(Items.Values['LisansTarihi']) <= StrToInt(Items.Values['LisansSuresi']) then
                begin // Kira süresi içerisinde ise
                  if StrToInt(Items.Values['LisansSuresi']) - (GunTarihi - StrToDateTime(Items.Values['LisansTarihi'])) >= StrToInt(Items.Values['UyariGunSayisi']) then
                  begin //  Kira Uyarı Opsiyon Günü süresi içersine girilmemiş ise...
                    lisansHata := 0;
                    lisansMesaj := 'Geçerli süre içerisinde.';
                    lisansDevam := 1;
                    lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                    lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
                  end
                  else //  Kira Uyarı Opsiyon Günü süresi içersine gelinmiş ise...
                  begin
                    lisansHata := 1;
                    lisansMesaj := 'Lisans süresinin dolmasına ' + IntToStr(StrToInt(Items.Values['LisansSuresi']) - trunc((GunTarihi - StrToDateTime(Items.Values['LisansTarihi'])))) + ' gün kalmıştır.';
                    lisansDevam := 1;
                    lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                    lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
                  end;
                end
                else // Kira süresi dolmuş ise
                begin
                  lisansHata := 1;
                  lisansMesaj := 'Lisans süresi dolmuştur.';
                  lisansDevam := 0;
                  lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                  lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
                end;
              end
              else
                if Items.Values['SatisTipi'] = '0' then // Satış Türü "SATIŞ" ise...
                begin
                  lisansHata := 0;
                  lisansMesaj := 'Satış';
                  lisansDevam := 1;
                  lisansTerminal := DeSifre(Tablo.Query4.fieldByName('SABITTEXT').AsString);
                  lisansKey := Tablo.Query4.fieldByName('DEGER').AsString;
                end;
          end
          else // WEB Service ten dönen değerler çalışma iznini 0 yapmış. Sistem Server'ı ile GEnSERVER daki MAC ler farklı...
          begin
            lisansHata := 1;
            lisansMesaj := 'Server ayarlarınız değişmiş. Lütfen GenoTIP ile görüşünüz.' + #13 + #10 + 'Yeni bir lisans almanız gerekebilir.';
            lisansDevam := -2;
            lisansTerminal := BilgisayarAdi;//'---';
            lisansKey := '---';
          end;
        end
        else  //  Modul kullanma için izin var mı? Yoksa......
        begin
          lisansHata := 1;
          lisansMesaj := 'Bu modülü kullanma lisansınız yoktur.';
          lisansDevam := -2;
          lisansTerminal := BilgisayarAdi;//'---';
          lisansKey := Sifre(StringReplace(GetMACAdress, '-', '', [rfReplaceAll]));
        end;
      end
      else // Terminal sisteme tanımlı değil ise...
      begin
        lisansHata := 1;
        lisansMesaj := 'Bu terminal sistemde kayıtlı değil.';
        lisansDevam := -1;
        lisansTerminal := BilgisayarAdi;//'---';
        lisansKey := Sifre(StringReplace(GetMACAdress, '-', '', [rfReplaceAll])); ;
      end;
    end
    else // Lisans Bilgilerinde YAzılım Çalışma izni kapalı olarak kayıtlı....
    begin
      lisansHata := 1;
      lisansMesaj := 'Sistemin çalışma izni yok. GenoTIP ile irtibata geçmeniz gerekmektedir.' + #13 + #10 + 'Lisans MAC : ' + lisansMac;
      lisansDevam := -2;
      lisansTerminal := BilgisayarAdi;//'---';
      lisansKey := '---';
    end;
  end
  else // Şirkete ait herhangi bir MAC adresi bağlanmaya çalışırsa direk devam edecek...
  begin
    lisansHata := 0;
    lisansMesaj := 'MAC Adresi Şirkete ait olarak tanımlı.';
    lisansDevam := 1;
    lisansTerminal := BilgisayarAdi;//'---';
    lisansKey := '---';
  end;

  Application.CreateForm(TLisansDlg, LisansDlg);

  if (lisansHata <> 0) then
  begin
     // LisansTar := FormatDateTime('dd/mm/yyyy hh:mm:ss', now);
    LisansDlg.ShowModal;
    LisansDlg.LblLisansMsg.Caption := lisansMesaj;
    if LisansDlg.ModalResult = mrCancel then
    begin
      LisansDlg.Destroy;
      halt;
    end
    else
      LisansDlg.Destroy;
  end
  else if LisansDlg <> nil then LisansDlg.Destroy;


end;


procedure TLisansDlg.FormCreate(Sender: TObject);
var
  s: dword;
  function Artir(s: string): string;
  begin
    for i := 1 to 16 do
      if s[i] < '9' then
        s[i] := Chr(Ord(s[i]) + 1)
      else
        s[i] := '0';
    Artir := s;
  end;
begin
{
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'exec p_gen_code '''+ Tablo.GetMACAdress +'''';
  Tablo.Query3.open;
 }
  //s := SizeOf(u);
  //GetUserName(u, s);
  s := SizeOf(BilgisayarAdi);
  GetComputerName(BilgisayarAdi, s);
  LblLisans.Caption := lisansKey;

  {
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'exec p_gen_lisanskontrol '''+Tablo.Query3.Fieldbyname('SONUC').AsString+''',''502''';
  Tablo.Query2.open;

  }
  if lisansTerminal = '' then
     TxtTerminal.Text := BilgisayarAdi
  else
     TxtTerminal.Text := lisansTerminal;
  LblLisansMsg.Caption := lisansMesaj;
  LblLisansMsg.Left := 2;
  LblLisansMsg.Width := (self.Width) - 10;

  if lisansDevam <> -1 then
  begin
    BtnLisans.Visible := False;
    TxtTerminal.Enabled := False;
    if lisansDevam = -2 then
    begin
      TxtTerminal.Visible := False;
      Label11.Visible := False;
      Label12.Visible := False;
      LblLisans.Visible := False;
    end;
  end;
 {////////////// Yeni lisans için kapatıyorum

   bhdinfo1.Execute;
   s1:=trim(bhdinfo1.SerialNumber);
   s2 := '';

   for i := 1 to length(s1) do
     if (s1[i]>='0')and(s1[i]<'9') then
        s2 := s2+s1[i]
     else
        s2 := s2+IntToStr(Ord(s1[i])+65);

   uz := length(s2);   //YMQEPREP
   if uz > 16 then
      s2 := copy(s2, 1, 16)
   else
      for i := 1 to 16-uz do
        s2:=s2+intToStr(i);

   if DATESEPARATOR='/' then
   piKeyPass1.date := StrToDateTime(LisansTar);
   try
     label3.caption := DateTimeToStr(piKeyPass1.date);
   except
   end;
   label5.caption := copy(s2,1,4);
   label8.caption := copy(s2,5,4);
   label9.caption := copy(s2,9,4);
   label10.caption := copy(s2,13,4);

   piKeyPass1.Key := Artir(s2);
   piKeyPass1.execute;

   }

end;

procedure TLisansDlg.OKBtnClick(Sender: TObject);
begin
 { Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'exec p_gen_code '''+ Tablo.GetMACAdress +'''';
  Tablo.Query3.open;

  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'exec p_gen_lisanskontrol '''+Tablo.Query3.Fieldbyname('SONUC').AsString+''',''502''';
  Tablo.Query2.open;
  }
  if lisansDevam <> 1 then
  begin
    Kapat := true;
    ModalResult := mrCancel;
    Close;
  end
  else
  begin
    Kapat := True;
    ModalResult := mrOK;
  end;
end;

procedure TLisansDlg.CancelBtnClick(Sender: TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
  Close;
end;

procedure TLisansDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not Kapat then CanClose := FALSE;
end;

procedure TLisansDlg.Label4DblClick(Sender: TObject);
begin
  bhdinfo1.Execute;
  Edit1.Text := bhdinfo1.SerialNumber;
end;

procedure TLisansDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then OKBtn.Click;
end;

procedure TLisansDlg.BtnLisansClick(Sender: TObject);
begin
  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text := 'Select count(*) SAYI, ISNULL(MAX(SABIT),''1000'') as MAXNO from GENOTIP WHERE DURUM <> 0 AND SABIT >= ''1000''';
  Tablo.Query2.open;

  if lisansSayisi > Tablo.Query2.FieldByName('SAYI').AsInteger then
  begin
    Tablo.Query3.Close;
    Tablo.Query3.SQL.Text := 'Select * from GENOTIP WHERE SABIT >= ''1000'' AND cast(SABITTEXT as varchar(1000)) = ''' + Sifre(TxtTerminal.Text) + '''';
    Tablo.Query3.Open;


    if Tablo.Query3.RecordCount <> 0 then
    begin
      lisansDevam := 0;
      LblLisansMsg.Width := 250;
      LblLisansMsg.Caption := 'Bu isimde kayıtlı terminal var.';
      BtnLisans.Visible := True;
      TxtTerminal.Enabled := True;
    end
    else
    begin

      Tablo.Query3.close;
      Tablo.Query3.SQL.Text := 'INSERT INTO GENOTIP(SABITTEXT, SABIT, DEGER, DURUM) ' +
        ' VALUES (''' + Sifre(TxtTerminal.Text) + ''',''' + IntToStr(Tablo.Query2.FieldByName('MAXNO').AsInteger + 1) + ''',' +
        '''' + LblLisans.Caption + ''',1)';
      Tablo.Query3.ExecSQL;
      lisansDevam := 1;
      LblLisansMsg.Width := 250;
      LblLisansMsg.Caption := 'Terminal kaydedildi.';
      BtnLisans.Visible := false;
      TxtTerminal.Enabled := False;
    end;
  end
  else
  begin
    LblLisansMsg.Width := 250;
    LblLisansMsg.Caption := 'Terminal limitiniz dolu.';
  end;


end;

end.

