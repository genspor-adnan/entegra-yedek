unit UGenNotificationUtils;

interface
Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, StdCtrls, IdHTTP, MSXML_TLB, UFDCompatHelpers, Ucombo, forms, XMLDoc, XMLIntf,
  IdSMTP, IdMessage,IdExplicitTLSClientServerBase, IdAttachmentFile, IdSSLOpenSSL, Prjconst,
  IdText,Generics.Collections, DB, ComObj, ComCtrls;

{$REGION 'SMS Tip Tanýmlarý'}
type
  TSmsHesapBigileri = record
    HesapId : Integer;
    SMSKullaniciAdi: string;
    SMSSifre: string;
    SMSBaslik: string;
    SMSServisSaglayici: integer;
  end;
type
  TSmsKontorSonucu = record
    KontorMiktari: string;
    HataKodu: string;
    Mesaj: string;
  end;
  type
  TSmsMesaj = record
    Id: integer;
    Numara: string;
    Mesaj: string;
  end;
type
  TSmsMesajSonuc = record
    HataKodu: string;
    Mesaj: string;
    MesajRefNo: string;
  end;
{$ENDREGION}

{$REGION 'Eposta Tip Tanýmlarý'}
  type
    TEpostaHesapAyarlari = record
     HesapId : integer;
     GonderenAdi : string;
     EpostaAdresi : string;
     KullaniciAdi : string;
     Parola : string;
     Sunucu : string;
     Port   : string;
     KimlikDogrulama : Boolean;
     Sifreleme : integer;
  end;

  type TEpostaGonderimSonuc = record
      GonderimBasarili : boolean ;
      SonucMesaji : string
    end;

  TEpostaAlici = class(TObject)
  private
    FEmail: string;
    FAdi: string;
  public
    class procedure ListeyeYukle(AAlicilar: string; hedef: TList<TEpostaAlici>);
    class procedure VerisetineKaydet(liste: TList<TEpostaAlici>; AVeriSeti: TDataSet);
  published
    property Adi: string read FAdi write FAdi;
    property Email: string read FEmail write FEmail;
  end;

{$ENDREGION}


function SMSHesapBilgileriGetir(HesapId:integer): TSmsHesapBigileri;
function SMSKontorSorgula(HesapId:integer): TSmsKontorSonucu;
function SMSDurumSorgula(SMSID:integer):string;
function SMSGonder(SMSHesapId: Integer; Mesajlar: array of TSmsMesaj; Bastar, Bittar: TDateTime; Zamanli: boolean; Yer :Integer; anahtar:string; RehberID:integer ): TSmsMesajSonuc;


function EPostaHesapBilgileriniGetir(HesapId:integer): TEpostaHesapAyarlari;

function EpostaGonderOutlook(EpostaHesapBilgisi: TEpostaHesapAyarlari; EpostaKonu:string;EpostaMesaj : String;
         ADosyalar: TList<string>; AliciListesi : TList<TEpostaAlici>; Yer: integer; Anahtar: String; RehberID:integer):TEpostaGonderimSonuc;
//function EpostaGonder(EpostaHesapBilgisi: TEpostaHesapAyarlari; EpostaKonu:string; EpostaMesaj : string;
//         ADosyalar: TList<string>; AliciListesi : TList<TEpostaAlici>; smtp : TIdSMTP ; iohSSLTLS: TIdSSLIOHandlerSocketOpenSSL; Yer: integer; Anahtar: String; RehberId:integer):TEpostaGonderimSonuc;
function EpostaGonderRapor(EpostaHesapBilgisi: TEpostaHesapAyarlari; EpostaKonu:string; EpostaMesaj : string;
         ADosyalar: TList<string>; AliciListesi, CCListesi : TList<TEpostaAlici>; smtp : TIdSMTP ; iohSSLTLS: TIdSSLIOHandlerSocketOpenSSL; Yer: integer; Anahtar: String; RehberId:integer):TEpostaGonderimSonuc;


const
  SMSServis_PostaGuvercini = 1;
  SMSServis_SMSNext = 2;
  SMSServis_Biotekno = 3;

implementation

Uses Utablo,
     FetaClassExtensions,
     UBinarySave,
     FetaKurulusSiniflari;

{$REGION 'SMS Ýþlemleri'}
function TelFormatla(Tel: string): string;
var
  s, Gtel: string; index,i,l: Integer;
  Kod: TStrings;
begin
  //  Kod:=TStringList.Create;
  Kod := TStringList.Create;

{$IFDEF GENOTIP}
  GenotipIni.ReadSection('GSMTelKod', Kod);
{$ELSE IFDEF ENTEGRA}
   l:=0;
   for I := 500 to 599 do
   begin
   kod.Add(inttostr(i));
   Inc(l);
   end;
//   RehberIni.ReadSection('GSMTelKod', Kod);
{$ENDIF}


  for index := 1 to Length(Tel) do
  begin
    s := Copy(Tel, index, 1);
    if (s[1] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
      Gtel := Gtel + s[1];
  end;
  case Length(Gtel) of
    0..9: TelFormatla := '0';
    10:
      if pos(copy(Gtel, 1, 3), Kod.CommaText) <> 0 then
        TelFormatla := '90' + Gtel
      else
        TelFormatla := '0';
    11: if copy(GTel, 1, 1) = '0' then
      begin
        if (pos(Copy(Gtel, 2, 3), Kod.CommaText) <> 0) then
          TelFormatla := '90' + copy(Gtel, 2, 10)
        else
          TelFormatla := '0';
      end
      else
        TelFormatla := '0';

    12: if Copy(Gtel, 1, 2) = '90' then
      begin
        if (pos(Copy(Gtel, 3, 3), Kod.CommaText) <> 0) then
          TelFormatla := GTel
        else
          TelFormatla := '0';
      end
      else
        TelFormatla := '0';
    13..99: TelFormatla := '0';
  end;

end;

function SMSHesapBilgileriGetir(HesapId:integer): TSmsHesapBigileri;
begin
  with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT * FROM SMSHESAPLARI WHERE ID = '+inttostr(HesapId) ,[], [] ) do
  try
    CommandTimeout:=0;
    Open;
  if IsEmpty then
    Result.HesapId:=-99
  else
    begin
      Result.HesapId:= HesapId;
      Result.SMSKullaniciAdi:= FieldByName('SMSKULLANICIADI').AsString;
      Result.SMSSifre:= FieldByName('SMSSIFRE').AsString;
      Result.SMSBaslik:= FieldByName('SMSBASLIK').AsString;
      Result.SMSServisSaglayici:= FieldByName('SMSSERVISI').AsInteger;
    end;
  finally
   Free
  end;


end;

function SMSKontorSorgula(HesapId:integer): TSmsKontorSonucu;
var
  HTTPReq: TXMLHTTPRequest;
  XMLStructe, DonusBilgisi: TStringList;
  //DonusBilgisi:String;
  link: string;
  Donen: TSmsKontorSonucu;
  InHttp: TIdHTTP;
  Dizin: string;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  InsertRes : String;
  SMSHesapBilgileri:TSmsHesapBigileri;
begin
  //3422800016
  // gen16tip
  XMLStructe := TStringList.create;
  DonusBilgisi := TStringList.Create;
  SMSHesapBilgileri:= SMSHesapBilgileriGetir(HesapId);

  if SMSHesapBilgileri.SMSServisSaglayici = SMSServis_SMSNext then
  begin
    try
      XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
        '<Main><UserName>' + SMSHesapBilgileri.SMSKullaniciAdi + '</UserName><PassWord>' + SMSHesapBilgileri.SMSSifre + '</PassWord></Main>';
      HTTPReq := TXMLHTTPRequest.Create(nil);
      HTTPReq.open('post', 'http://secure.smsnext.com/developer/bulksmsv2/queryKontor.asp', False);
      //ID:1310411
      HTTPReq.send(XMLStructe.Text);
      DonusBilgisi.Text := HTTPReq.responseText;
    finally
      XMLStructe.free;
      HTTPReq.free;
    end;
    if copy(DonusBilgisi.Strings[0], 1, 2) = 'WP' then
    begin
      //Hata Oluþtu demektir bunlarý bi alalým
      //Dönen Hata kodlarý
      //WP:00  Hatalý Kullanýcý Adý yada Þifresi
      //WP:01  Geçersiz IP Adresi
      //WX:02  Kontörlu Hesap Deðil
      //WX:03  Kontör Hatasý
      //WP:90   XML Hatasý
      Donen.HataKodu := copy(DonusBilgisi.Strings[0], 4, 2);
      if Donen.HataKodu = '00' then
        Donen.Mesaj := 'Hatalý Kullanýcý Adý yada Þifresi'
      else if Donen.HataKodu = '01' then
        Donen.Mesaj := 'Geçersiz IP Adresi'
      else if Donen.HataKodu = '02' then
        Donen.Mesaj := 'Kontörlü Hesap Deðil'
      else if Donen.HataKodu = '03' then
        Donen.Mesaj := 'Kontör Hatasý'
      else if Donen.HataKodu = '90' then
        Donen.Mesaj := 'XML Hatasý';
      Donen.KontorMiktari := '0';
    end
    else
    begin
      // Hata Yoksa Kontör miktarýný ve mesajýný oluþturalým
      Donen.HataKodu := '-1';
      Donen.KontorMiktari := DonusBilgisi.Strings[0];
      Donen.Mesaj := 'Kontör Son kullaným tarihi :' + copy(DonusBilgisi.Strings[1], 7, 2) + '/' + copy(DonusBilgisi.Strings[1], 5, 2) + '/' + copy(DonusBilgisi.Strings[1], 1, 4);
    end;
  end // if SMSHesapBilgileri.SMSServisSaglayici = 'SmsNext'

  else if SMSHesapBilgileri.SMSServisSaglayici = SMSServis_Biotekno then
  begin
    //Dönen Kodlar
    //20 Geçersiz  xml file
    //10 Kullanýcý Kodu / Þifresi hatalý
    //90 Sistem hatasý
    InHttp := TIdHTTP.Create(nil);
    //HTTPReq:=TXMLHTTPRequest.Create(nil);
    link := 'http://biotekno.biz:8080/SMS-Web/examine?username=' + SMSHesapBilgileri.SMSKullaniciAdi + '&password=' + SMSHesapBilgileri.SMSSifre + '&type=charge';
    DonusBilgisi.Text := InHttp.Get(link);

    //ID:1310411
    //HTTPReq.send(XMLStructe.Text);
   // DonusBilgisi.Text := HTTPReq.responseText;
    Donen.KontorMiktari := DonusBilgisi.Text;
    Donen.HataKodu := '';
    Donen.Mesaj := DonusBilgisi.Text;

  end //else if SMSHesapBilgileri.SMSServisSaglayici = 'BioTekno'

  else if SMSHesapBilgileri.SMSServisSaglayici = SMSServis_PostaGuvercini  then
  begin
    { 3.2. KREDÝ
  <?xml version="1.0"?>
  <!ELEMENT CREDIT-Response (ERROR | BALANCE)>
  <!ELEMENT ERROR (#PCDATA)>

  <!ELEMENT BALANCE EMPTY>
  <!ATTLIST BALANCE
  res CDATA #REQUIRED
  >

  3.2.1 ÖRNEK KREDÝ CEVAP
  CREDIT-BalRequest sonrasýnda sunucudan gelebilecek cevap aþaðýdadýr. Res deðeri mevcut kredinizi verir.

  <CREDIT-Response>
     <BALANCE res="0" />
  </CREDIT-Response>
    }
    try

      //Gönderilecek xml oluþturuluyor..
      XMLStructe.Text := //'<?xml version="1.0" encoding="ISO-8859-9"?>' +
        '<CREDIT-BalRequest>' +
        '<CLIENT user="' + SMSHesapBilgileri.SMSKullaniciAdi + '" pwd="' + SMSHesapBilgileri.SMSSifre + '"/>'+
        '<BALANCE req="1" />' ;
      XMLStructe.Text := XMLStructe.Text + '</CREDIT-BalRequest>';

      HTTPReq := TXMLHTTPRequest.Create(nil);
      HTTPReq.open('post', 'http://www.postaguvercini.com/api_xml/Cre_balreq.asp ', False);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #13, '', [rfReplaceAll]);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #10, '', [rfReplaceAll]);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]);
      //Baþlýk Kýsmý standart bilgilerin hazýrlanmasý unicede olarak Ýsmail ACET 2010-09-16
      HTTPReq.setRequestHeader('Content-Type: text/xml','<?xml version="1.0" encoding="windows-1254"?>');
      HTTPReq.send(XMLStructe.Text);
      if not DirectoryExists('XML') then
        MkDir('XML');
      dizin := ExtractFileDir(Application.ExeName) + '\XML\' + FormatDateTime('yyyymmddhhnn', Now) + '-PostaGuvercinisms.xml';
      XMLStructe.SaveToFile(dizin);

      DonusBilgisi.Text := StringReplace(HTTPReq.responseText, #13, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #10, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #13#10, '', [rfReplaceAll]);
    finally
      XMLStructe.free;
      HTTPReq.free;
    end;

    if pos('<ERROR>', DonusBilgisi.Text) > 0 then
    begin
      //Hatavar
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'<CREDIT-Response><ERROR>','',[rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'</ERROR></CREDIT-Response>','',[rfReplaceAll]);
      Donen.Mesaj :=  DonusBilgisi.Text;
    end
    else
    begin

      Tablo.XMLDocument2.XML.Text := DonusBilgisi.Text;
      Tablo.XMLDocument2.Active := True;
      StartItemNode := Tablo.XMLDocument2.DocumentElement.ChildNodes.FindNode('BALANCE');
      ANode := StartItemNode;
      repeat
        InsertRes := ANode.Attributes['res'];
        ANode := ANode.NextSibling;
      until ANode = nil;
      // Hata Yoksa mesaj referansýný  ve mesajýný oluþturalým
      Donen.HataKodu := '-1';
      Donen.Mesaj :=  '';
      Donen.KontorMiktari :=  InsertRes ;
    end;
  end;
  Result := Donen;
end;

procedure PostaGuverciniDurumSorgula(SMSID, SMSHesapID: integer ;MesajReferansNo:string);
var
  HTTPReq: TXMLHTTPRequest;
  XMLStructe, DonusBilgisi: TStringList;
  Kontrol: string;
  SMSHesapBilgileri : TSmsHesapBigileri;
  procedure SMSDurumGuncelle(durum:Integer;durumaciklama:string);
   begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'UPDATE SMSLER SET DURUM = '+inttostr(durum)+' , '+
                                    ' DURUMACIKLAMA ='''+durumaciklama+''' '+
                                    'WHERE ID = '+inttostr(SMSID),[],[]
                                   );
   end;
begin
   SMSHesapBilgileri:= SMSHesapBilgileriGetir(SMSHesapID);
   try
    //Baþlýk Kýsmý standart bilgilerin hazýrlanmasý
    XMLStructe.Text := //'<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<SMS-StaRequest>' +
      '<CLIENT user="' + SMSHesapBilgileri.SMSKullaniciAdi + '" pwd="' + SMSHesapBilgileri.SMSSifre + '"/>' +
      '  <STATUS id="' + MesajReferansNo + '" />';
    XMLStructe.Text := XMLStructe.Text + '</SMS-StaRequest>';


      HTTPReq := TXMLHTTPRequest.Create(nil);
      HTTPReq.open('post', 'http://www.postaguvercini.com/api_xml/Sms_stareq.asp ', False);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #13, '', [rfReplaceAll]);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #10, '', [rfReplaceAll]);
      XMLStructe.Text := StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]);
      //Baþlýk Kýsmý standart bilgilerin hazýrlanmasý unicede olarak Ýsmail ACET 2010-09-16
      HTTPReq.setRequestHeader('Content-Type: text/xml','<?xml version="1.0" encoding="windows-1254"?>');
      HTTPReq.send(XMLStructe.Text);
      DonusBilgisi.Text := StringReplace(HTTPReq.responseText, #13, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #10, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #13#10, '', [rfReplaceAll]);

      kontrol := Copy(DonusBilgisi.Text, pos('res="', DonusBilgisi.text) + 5,
       (pos('|', DonusBilgisi.text) - (pos('res="', DonusBilgisi.text) + 5)));


      case StrToInt(Kontrol) of
       110 : SMSDurumGuncelle(-1,'Kredi Yüklemesini Bekliyor');
       120 : SMSDurumGuncelle(1,'Gönderilme saatini Bekliyor');
       200 : SMSDurumGuncelle(1,'SMSC ye gönderilmek üzere');
       300 : SMSDurumGuncelle(1,'SMSC ye gönderildi');
       400 : SMSDurumGuncelle(9,'Baþarýlý');
       401 : SMSDurumGuncelle(9,'Alýcýya gönderilecek');
       402 : SMSDurumGuncelle(-1,'Alýcýya ulaþmadý');
       403 : SMSDurumGuncelle(-1,'Alýcýya ulaþmadý(Zaman Aþýmý)');
       404 : SMSDurumGuncelle(-1,'Alýcýya ulaþmadý(Bilinmeyen Hata)');
       405 : SMSDurumGuncelle(-1,'Alýcýya ulaþmadý(Sistem Hatasý)');
       406 : SMSDurumGuncelle(-1,'Alýcýya ulaþmadý(SMS Kapalý)');
       410 : SMSDurumGuncelle(-1,'Mesaj SMSC de bulunmadý');
       420 : SMSDurumGuncelle(-1,'Mesaj sunucuda bulunamadý');
       -20 : SMSDurumGuncelle(-1,'Bu mesaj size ait deðil');
      -201 : SMSDurumGuncelle(-1,'Silindi(Geçersiz Cep No)');
      -202 : SMSDurumGuncelle(-1,'Silindi(Mesaj Tekrarý)');
      -203 : SMSDurumGuncelle(-1,'Silindi(Geçersiz son gönderim tarihi)');
      -205 : SMSDurumGuncelle(-1,'Silindi(Mesaj çok uzun)');
      -207 : SMSDurumGuncelle(-1,'Silindi(SMSC reddetti)');
      -210 : SMSDurumGuncelle(-1,'Silindi(Zaman Aþýmý)');
      -220 : SMSDurumGuncelle(-1,'Silindi(Yetersiz kredi zaman aþýmý)');
      -222 : SMSDurumGuncelle(-1,'Silindi(Abone mesajýn bloke edilmesi tercih ettiðinden)');
      -250 : SMSDurumGuncelle(-1,'Silindi(Müþteri tarafýndan)');
      -260 : SMSDurumGuncelle(-1,'Silindi(Fatura Borcu)');
      else
       if (StrToInt(Kontrol)>=-201) and (StrToInt(Kontrol)<= -299) then
         SMSDurumGuncelle(-1,'Silindi(Fatura Borcu)');

      end;

    finally
      XMLStructe.free;
      HTTPReq.free;
    end; //Try End
end;

function SMSDurumSorgula(SMSID:integer):string;
begin
  with Veritabani.SorguBaslat( Tablo.FDCnn, 'SELECT S.*, H.SMSSERVISI FROM SMSLER S INNER JOIN SMSHESAPLAR H ON H.ID = S.HESAPID WHERE S.ID='+inttostr(SMSID),[], [] ) do
  try
      CommandTimeout:=0;
      Open;
      if not IsEmpty then
       begin
         case FieldByName('SMSSERVISI').AsInteger of
           SMSServis_PostaGuvercini : PostaGuverciniDurumSorgula(FieldByName('ID').AsInteger, FieldByName('HESAPID').AsInteger, FieldByName('SMSREFERANSNO').AsString);
         end;
       end
      else
       begin
         Result:='SMS Kaydý Bulunamadý';
       end;

  finally
    Free;
  end;


end;

function SMSGonder(SMSHesapId: Integer; Mesajlar: array of TSmsMesaj; Bastar, Bittar: TDateTime; Zamanli: boolean; Yer :Integer; anahtar:string;RehberID:integer ): TSmsMesajSonuc;
var
 ZamanEk, dizin: string;
 XMLDoc : TXMLDocument;
 SMSHesapBilgileri : TSmsHesapBigileri;
 DonusBilgisi,XMLStructure : TStringList;
 x, SMSServis : integer;
 HTTPReq: TXMLHTTPRequest;
 donen: TSmsMesajSonuc;
 StartItemNode, ANode: IXMLNode;
 InsertID, InsertRes: widestring;
 procedure SMSTablosunaIsle(TelefonNo,smsmesaji,smsreferansno:string; smsdurumId:integer;smsdurum:string );
 begin
    with Veritabani.SorguBaslat( Tablo.FDCnn, '' ,[], [] ) do
    try
        CommandTimeout:=0;
        SQL.Text:=' INSERT INTO  SMSLER ( HESAPID,REHID ,GSMNO ,GONDERIMTARIHI ,MESAJMETNI ,SMSREFERANSNO '+
            ',DURUM ,DURUMACIKLAMA ,YER , ANAHTAR, BASLANGICTARIHI, BITISTARIHI ) '+
            ' VALUES ('+ IntToStr(SMSHesapBilgileri.HesapId)+','+inttostr(RehberId)+','''+TelefonNo+''', GETDATE(),'''+smsmesaji+''','''+smsreferansno+''', '+
            '  '+inttostr(smsdurumid)+','''+smsdurum+''','+inttostr(yer)+','''+anahtar+''','+
            ''''+formatdatetime('yyyy-mm-dd hh:nn',Bastar)+''','''+formatdatetime('yyyy-mm-dd hh:nn',Bittar)+'''  ) ';
      ExecSQL;
    finally
      Free;
    end;
 end;
 procedure PostaGuverciniSMS;
 var
  i:integer;
  begin
    ZamanEk := '';
    if Zamanli then
      ZamanEk := 'dt="' + FormatDateTime('yyyy/mm/dd hh:nn', Bastar) + '" dt2="' + FormatDateTime('yyyy/mm/dd hh:nn', Bittar) + '"'
    else
      ZamanEk := 'dt="' + FormatDateTime('yyyy/mm/dd hh:nn', Now) + '"';

    //Baþlýk Kýsmý standart bilgilerin hazýrlanmasý
    XMLStructure.Text := //'<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<SMS-InsRequest>' +
      '<CLIENT user="' + SMSHesapBilgileri.SMSKullaniciAdi + '" pwd="' + SMSHesapBilgileri.SMSSifre + '"/>';

    // ShowMessage('Gönderim için mesajlar oluþturuluyor .');  //Döngü ile dizideki mesaj ve numaralarý alalým
    for i := 0 to High(Mesajlar) do
    begin
      if Telformatla(mesajlar[i].Numara) <> '0' then
      begin
        if copy(Mesajlar[i].Numara, 1, 2) = '90' then
          Mesajlar[i].Numara := copy(Mesajlar[i].Numara, 3, length(Mesajlar[i].Numara) - 2);
        XMLStructure.Text := XMLStructure.Text + '<INSERT to="' + Mesajlar[i].Numara + '" text="' + Mesajlar[i].Mesaj + '" ' + ZamanEk + '/>'
      end else
      begin
       XMLStructure.Text := XMLStructure.Text + '<INSERT to="' + Mesajlar[i].Numara + '" text="' + 'Tel no hatalý' + '" ' + ZamanEk + '/>'

      end;
    end;
   // ShowMessage('Gönderim için mesajlar oluþturuluyor Bitti.') ;
    XMLStructure.Text := XMLStructure.Text + '</SMS-InsRequest>';
    try
    try
      HTTPReq := TXMLHTTPRequest.Create(nil);
      HTTPReq.open('post', 'http://www.postaguvercini.com/api_xml/Sms_insreq.asp ', False);
      XMLStructure.Text := StringReplace(XMLStructure.Text, #13, '', [rfReplaceAll]);
      XMLStructure.Text := StringReplace(XMLStructure.Text, #10, '', [rfReplaceAll]);
      XMLStructure.Text := StringReplace(XMLStructure.Text, #13#10, '', [rfReplaceAll]);
      //Baþlýk Kýsmý standart bilgilerin hazýrlanmasý unicode olarak
      HTTPReq.setRequestHeader('Content-Type: text/xml','<?xml version="1.0" encoding="windows-1254"?>');

      HTTPReq.send(XMLStructure.Text);

      if not DirectoryExists('XML') then
        MkDir('XML');
      dizin := ExtractFileDir(Application.ExeName) + '\XML\' + FormatDateTime('yyyymmddhhnnsszzz', Now) + '-PostaGuvercinisms.xml';
      XMLStructure.SaveToFile(dizin);

      DonusBilgisi.Text := StringReplace(HTTPReq.responseText, #13, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #10, '', [rfReplaceAll]);
      DonusBilgisi.Text := StringReplace(DonusBilgisi.Text, #13#10, '', [rfReplaceAll]);

    finally
      XMLStructure.free;
      HTTPReq.free;
    end; //Try End
    except
     DonusBilgisi.Text:='XmlExcept';
    end;
   // ShowMessage('Mesaj karþýya gönderildi.') ;  //ShowMessage(DonusBilgisi.Text);
    {
               Hata Numarasý	Açýklama
               ERR1010	Ýstek Hatasý. Veritabaný baðlantý iþlemi yapýlamadý
               ERR1020	Ýstek Hatasý. Veritabanýna baðlanamadý.
               ERR1030	Ýstek Hatasý. Ýstek tarihçe kaydý tutalamadý.
               ERR1040	Ýstek Hatasý. Ýstek tarihçe kayýt numarasý alýnamadý.
               ERR1050	Ýstek Hatasý. Ýstek deðerlendirilemedi. (Hatalý istek formatý)
                }
    if (pos('<ERROR>', DonusBilgisi.Text) > 0) or (DonusBilgisi.Text='XmlExcept') then
    begin
      //Hatavar
      if pos('ERR1050', DonusBilgisi.Text) > 0 then
      begin

        Donen.HataKodu := 'ERR1050';
        donen.Mesaj := 'Ýstek Hatasý. Ýstek deðerlendirilemedi. (Hatalý istek formatý)';
      end
      else if pos('ERR1040', DonusBilgisi.Text) > 0 then
      begin

        Donen.HataKodu := 'ERR1040';
        donen.Mesaj := 'Ýstek Hatasý. Ýstek tarihçe kayýt numarasý alýnamadý.';
      end
      else if pos('ERR1030', DonusBilgisi.Text) > 0 then
      begin

        Donen.HataKodu := 'ERR1030';
        donen.Mesaj := 'Ýstek Hatasý. Ýstek tarihçe kaydý tutalamadý.';
      end
      else if pos('ERR1020', DonusBilgisi.Text) > 0 then
      begin

        Donen.HataKodu := 'ERR1020';
        donen.Mesaj := 'Ýstek Hatasý. Veritabanýna baðlanamadý.';
      end
      else if pos('ERR1010', DonusBilgisi.Text) > 0 then
      begin
        Donen.HataKodu := 'ERR1010';
        donen.Mesaj := 'Ýstek Hatasý. Veritabaný baðlantý iþlemi yapýlamadý';
      end
      else if pos('Program kurulumunun kaydi yapilmamis.', DonusBilgisi.Text) > 0 then
      begin
        Donen.HataKodu := 'ERRKURULUS';
        donen.Mesaj := 'Program kurulumunun kaydi yapilmamis.Program saticiniz ile temasa gecip programi tekrar kurmalisiniz.';
      end else  if DonusBilgisi.Text='XmlExcept' then
      begin
        Donen.HataKodu := 'GEN01';
        Donen.Mesaj := 'XmlExcept'
      end
      else
        Donen.Mesaj := 'Gönderim Baþarýsýz';
    end
    else
    begin

   // ShowMessage('Gelen döküman okunuyor.');
      XMLDoc:= TXMLDocument.Create(Tablo);
      XMLDoc.XML.Text:= DonusBilgisi.Text;
      //Tablo.XMLDocument1.XML.Text := DonusBilgisi.Text;
      //ShowMessage( Tablo.XMLDocument1.XML.Text);
      x := 0;
      XMLDoc.Active := True;
      StartItemNode := XMLDoc.DocumentElement.ChildNodes.FindNode('INSERT');
      ANode := StartItemNode;
      repeat
        InsertID := ANode.Attributes['id'];
        InsertRes := ANode.Attributes['res'];
        //      ShowMessage(Inttostr(Mesajlar[x].Id)+'--'+  Mesajlar[x].Numara+ ' numara için  Id= '+ InsertID + ' '+ InsertRes);
        if Mesajlar[x].Id <> -1 then
         SMSTablosunaIsle(Mesajlar[x].Numara, Mesajlar[x].Mesaj,InsertID,0,'' );
          //TekliMesajReferansGuncelle(SubeID,Mesajlar[x].Id, Mesajlar[x].Numara, InsertID);
        inc(x);

        ANode := ANode.NextSibling;
      until ANode = nil;
      // Hata Yoksa mesaj referansýný  ve mesajýný oluþturalým
      Donen.HataKodu := '-1';
      donen.MesajRefNo := InsertID;
      Donen.Mesaj := 'Gönderildi';

    //ShowMessage('Gelen döküman okunuyor.bitti');
    end;

   Result := Donen;
  end;
begin
   XMLStructure:= TStringList.Create;
   DonusBilgisi:=  TStringList.Create;
   SMSHesapBilgileri:= SMSHesapBilgileriGetir(SMSHesapId);


   case SMSHesapBilgileri.SMSServisSaglayici of
      SMSServis_PostaGuvercini: PostaGuverciniSMS;
   end;

    FreeAndNil( DonusBilgisi);
    FreeAndNil(XMLDoc);
end;
{$ENDREGION}

{$REGION 'EPosta Ýþlemleri'}

class procedure TEpostaAlici.ListeyeYukle(AAlicilar: string; hedef: TList<TEpostaAlici>);
var
  lst: TStringList;
  receipt: TStringList;
  I, J: Integer;
  item: TEpostaAlici;
begin
  // alýcýlarý ayýr
  lst := Dize.StringListOlarak(AAlicilar, '|');
  try
    for I := 0 to lst.Count - 1 do begin
      receipt := Dize.StringListOlarak(lst[i], ',');
      try
        for J := 0 to receipt.Count - 1 do begin
          if ((J mod 2) = 0) then begin
            item := TEpostaAlici.Create;
            item.Adi := receipt[J];
          end else begin
            item.Email := receipt[J];
            hedef.Add(item);
          end;
        end;
      finally
        receipt.Free;
      end;
    end;
  finally
    lst.Free;
  end;
end;

class procedure TEpostaAlici.VerisetineKaydet(liste: TList<TEpostaAlici>;  AVeriSeti: TDataSet);
var
  i: Integer;
  rcp: array of Variant;
begin
  if (liste.Count = 0) then
    Exit;
  SetLength(rcp, liste.Count);
  for i := 0 to liste.Count - 1 do
  begin
    rcp[i] := liste[i].Adi + ',' + liste[i].Email;
  end;
  AVeriSeti.AsString['AlýcýListesi'] := Dize.Birlestir('|', rcp);
end;

function EPostaHesapBilgileriniGetir(HesapId:integer): TEpostaHesapAyarlari;
begin

  with Veritabani.SorguBaslat( Tablo.FDCnn, '' ,[], [] ) do
  try
      CommandTimeout:=0;
      SQL.Text:= 'SELECT * FROM EPOSTAHESAPLARI WHERE ID ='+ IntToStr(HesapId);
      Open;

      if not IsEmpty then
       begin
           Result.HesapId:= FieldByName('ID').AsInteger;
           Result.GonderenAdi:= FieldByName('GONDEREN').AsString;
           Result.EpostaAdresi:= FieldByName('EPOSTAADRESI').AsString;
           Result.KullaniciAdi:= FieldByName('KULLANICIADI').AsString;
           Result.Parola:= FieldByName('SIFRE').AsString;
           Result.Sunucu:= FieldByName('MAILSUNUCU').AsString;
           Result.Port:= FieldByName('PORT').AsString;
           Result.KimlikDogrulama:= FieldByName('KIMLIKDOGRULAMA').AsBoolean;
           Result.Sifreleme:= FieldByName('SIFRELEME').AsInteger
       end
      else
       Result.HesapId:=-1;

  finally
      Free;
  end;


end;

function EpostaGonderOutlook(EpostaHesapBilgisi: TEpostaHesapAyarlari; EpostaKonu:string;EpostaMesaj : String;
         ADosyalar: TList<string>; AliciListesi : TList<TEpostaAlici>; Yer: integer; Anahtar: String; RehberId:integer):TEpostaGonderimSonuc;
//
//  I: Integer;
const
  olMailItem = 0;
var
  Outlook, msg: OleVariant;
  alici : TEpostaAlici;
  dosya : string;
  durum:integer;
begin
   //
{  if EpostaHesapBilgisi.HesapId = -1 then
   begin
     Result.GonderimBasarili:=False;
     Result.SonucMesaji:='Geçerli Bir Eposta Hesabý Seçiniz';
   end
  else}
  if AliciListesi.Count=0 then
   begin
     Result.GonderimBasarili:=False;
     Result.SonucMesaji:='Alýcý listesinde en az bir alýcý olmalýdýr.';
   end
 else
  begin
      try
        Outlook := GetActiveOleObject('Outlook.Application');
      except
        Outlook := CreateOleObject('Outlook.Application');
       end;

      msg := Outlook.CreateItem(olMailItem);
      //alýcýlar
      for alici in AliciListesi do begin
          msg.Recipients.Add(alici.Email)
      end;
      msg.Subject := EpostaKonu;
//      msg.From.Name := EpostaHesapBilgisi.GonderenAdi;
//      msg.From.Address := EpostaHesapBilgisi.EpostaAdresi;
//      msg.CharSet := 'UTF-8';
      msg.Body := EpostaMesaj;
//      msg.Body := 'Welcome to my homepage: http/://www.scalabium.com';
      //ekli dosyalar
      if ADosyalar<>nil then begin
          for dosya in ADosyalar do
            //TIdAttachmentFile.Create(msg.MessageParts,dosya);
            msg.Attachments.Add(dosya);
      end;
      //þimdi gönderelim
      try
        try
           msg.Send;
           Result.GonderimBasarili:=True;
          //Log(rg.Adi,'Gönderildi');
        except on e: Exception do
         begin
           Result.GonderimBasarili:=False;
           Result.SonucMesaji:= e.Message;
         end;
          //Log('','Hata','Mail gönderilemedi! -> ' + e.Message);
        end;
      finally
         Outlook := Unassigned;
      end;
  end;
end;


function EpostaGonderRapor(EpostaHesapBilgisi: TEpostaHesapAyarlari; EpostaKonu:string;EpostaMesaj : String;
ADosyalar: TList<string>; AliciListesi, CCListesi : TList<TEpostaAlici>; smtp : TIdSMTP ; iohSSLTLS: TIdSSLIOHandlerSocketOpenSSL; Yer: integer; Anahtar: String; RehberID:integer):TEpostaGonderimSonuc;

var
  msg : TIdMessage;
  alici : TEpostaAlici;
  dosya : string;
  HtmlPart:TIdText;
  ImagePart: TIdAttachmentFile;
  I: Integer;
  s: TStringStream;
  tr : TRichEdit;
  Attachment : TIdAttachmentfile;
begin
  if EpostaHesapBilgisi.HesapId=-1 then begin
     Result.GonderimBasarili:=False;
     Result.SonucMesaji:=GecerliEPosta;
  end else if AliciListesi.Count=0 then begin
     Result.GonderimBasarili:=False;
     Result.SonucMesaji:=EPosta_Enazbiralici;
  end else begin
    msg := TIdMessage.Create(nil);
    msg.ContentType:='multipart/related; type="text/html"';
    //msg.ContentType:='multipart/related; type="text/richtext"';
    msg.Subject := EpostaKonu;
    msg.From.Address := EpostaHesapBilgisi.EpostaAdresi;
    msg.From.Name := EpostaHesapBilgisi.GonderenAdi;
    //msg.CharSet := 'iso-8859-9';
    msg.CharSet := 'UTF-8';
    msg.ContentType :=  'multipart/mixed';
    HtmlPart := TIdText.Create(msg.MessageParts);
    HtmlPart.ContentType := 'text/html';
    HtmlPart.Body.LoadFromFile(EpostaMesaj);
    HtmlPart .CharSet := 'UTF-8';
    if ADosyalar<>nil then begin
      for dosya in ADosyalar do
      ImagePart := TIdAttachmentFile.Create(msg.MessageParts, dosya);
    end;
    for alici in AliciListesi do
      with msg.Recipients.Add do begin
        if alici.Adi = '''''' then
           Name := Address
        else
           Name := alici.Adi;
        Address := alici.Email;
      end;
    if CCListesi<>nil then
      for alici in CCListesi do
        with msg.CCList.Add do begin
          if alici.Adi = '''''' then
             Name := Address
          else
             Name := alici.Adi;
          Address := alici.Email;
        end;

    if (EpostaHesapBilgisi.Sifreleme = 0) then begin
      smtp.UseTLS := TIdUseTLS.utNoTLSSupport;
      smtp.IOHandler := nil;
    end else begin
      smtp.IOHandler := iohSSLTLS;
      if StrToInt(EpostaHesapBilgisi.Port)=465 then
        smtp.UseTLS := utUseImplicitTLS
      else
        smtp.UseTLS := utUseExplicitTLS;
      if (EpostaHesapBilgisi.Sifreleme = 1) then
        iohSSLTLS.SSLOptions.Method := sslvTLSv1
      else if (EpostaHesapBilgisi.Sifreleme = 2) then
        iohSSLTLS.SSLOptions.Method := sslvSSLv2
      else if (EpostaHesapBilgisi.Sifreleme = 3) then
        iohSSLTLS.SSLOptions.Method := sslvSSLv3
      else if (EpostaHesapBilgisi.Sifreleme = 4) then
        iohSSLTLS.SSLOptions.Method := sslvSSLv23;
      iohSSLTLS.Port := StrToInt(EpostaHesapBilgisi.Port);
    end;
    smtp.Host := EpostaHesapBilgisi.Sunucu;
    smtp.Port := StrToInt(EpostaHesapBilgisi.Port);
    smtp.Username := EpostaHesapBilgisi.KullaniciAdi;
    smtp.Password := EpostaHesapBilgisi.Parola;
    try
      try
        smtp.Connect;
        smtp.Send(msg);
        Result.GonderimBasarili:=True;
      except
        on e: Exception do begin
         Result.GonderimBasarili:=False;
         Result.SonucMesaji:= e.Message;
        end;
      end;
    finally
      if (smtp.Connected) then smtp.Disconnect;
        FreeAndNil(msg);
    end;
  end;
end;



{$ENDREGION}

end.



