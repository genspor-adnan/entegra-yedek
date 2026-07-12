{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
{-------------------------------------------------------------------------------
************************************GENYAZILIM**********************************
Sms i�lemleri i�in kullan�lan unit
----------------------------------------------
De�i�iklikler
----------------------------------------------
26/10/2006 Olu�turma
Ayhan �ALI�KAN- Necdet �etinkaya

�pu�lar�
--------------------------------------
Mesaj g�nderilen XML dosyalar�, EXE nin bulundu�u root ta XML klas�r�ne kaydediliyor.

-------------------------------------------------------------------------------}

unit USMSIslemleri;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Dialogs, StdCtrls, IdHTTP, UFDCompatHelpers, Ucombo, forms, XMLDoc, XMLIntf, ComObj;

type TSmsKontorSonucu = record
    KontorMiktari: string;
    HataKodu: string;
    Mesaj: string;
  end;
type TSmsMesajSonuc = record
    HataKodu: string;
    Mesaj: string;
    MesajRefNo: string;
  end;
type TSmsKullaniciBigileri = record
    SMSKullaniciAdi: string;
    SMSSifre: string;
    SMSBaslik: string;
    SMSServisSaglayici: string;
  end;
type TSmsMesaj = record
    Id :integer;
    Numara: string;
    Mesaj: string;
  end;


function MesajMetni(Mesaj: string): string;
function TelFormatla(Tel: string): string;
function SMSKontorSorgula(): TSmsKontorSonucu;
function TopluSmsAt(Mesajlar: array of TSmsMesaj;  Bastar, Bittar: TDateTime; Zamanli: boolean): TSmsMesajSonuc;
function SMSHesapBilgileri: TSmsKullaniciBigileri;
procedure SMSGonderiKontrolToplu(MesajReferansNo, Servis: string);
function SMSGonderiKontrolTek(MesajReferansNo, Servis: string): string;
procedure TekliMesajReferansGuncelle(Id :integer ; Numara ,MesRefNo :string  );

var
  GSMTelKod: TStringList;

  ESHesapIni: TIni;
implementation

uses Math, UTablo, UVeriMotor;


function TelFormatla(Tel: string ): string;
var
  s, Gtel: string; index: Integer;
  Kod: TStrings;
begin
//  Kod:=TStringList.Create;
  Kod := TStringList.Create;
  RehberIni.ReadSection('GSMTelKod', Kod);

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
    11: if copy(GTel, 1, 1) = '0' then begin
        if (pos(Copy(Gtel, 2, 3), Kod.CommaText) <> 0) then
          TelFormatla := '90' + copy(Gtel, 2, 10)
        else
          TelFormatla := '0';
      end
      else TelFormatla := '0';

    12: if Copy(Gtel, 1, 2) = '90' then begin
        if (pos(Copy(Gtel, 3, 3), Kod.CommaText) <> 0) then
          TelFormatla := GTel
        else
          TelFormatla := '0';
      end
      else TelFormatla := '0';
    13..99: TelFormatla := '0';
  end;

end;

function MesajMetni(Mesaj: string): string;
var prm, prmdeger: string;
  i: integer;
begin
{
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text := 'select DOSYANO ,RTRIM(LTRIM(AD)),LTRIM(RTRIM(SOYAD)) ,ILETKANALI,' +
    'CEPTEL ,EPOSTA,ACIKLAMA,SONGELTARIH ,' +
    'SONGELBOLUM, CAGRITARIH, CAGIRANBOLUM ,CAGIRANKISI,SABLONID ' +
    'FROM CAGRI ' +
    'WHERE ID = ' + IntToStr(ID);
  Tablo.Query6.Open;

  for i := Tablo.Query6.FieldCount - 2 downto 0 do
  begin
    prm := '@Param' + IntToStr(i + 1);
    prmdeger := Tablo.Query6.Fields[i].AsString;
    mesaj := StringReplace(mesaj, prm, prmdeger, [rfReplaceAll, rfIgnoreCase]);
  end;
  }
  {-------------------------------------
  UYGUNSUZ KARAKTERLER�N ELENMES�
  --------------------------------------}

  mesaj := StringReplace(mesaj, '�', 'C', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'G', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'I', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'O', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'S', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'U', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'u', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'c', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'i', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 's', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'g', [rfReplaceAll]);
  mesaj := StringReplace(mesaj, '�', 'o', [rfReplaceAll]);
  Result := mesaj;

end;


function SMSHesapBilgileri: TSmsKullaniciBigileri;
begin
  if ESHesapIni = nil then
    ESHesapIni := TIni.Create('AJANDAINI', Tablo.IniSQL);

  Result.SMSKullaniciAdi := ESHesapIni.ReadString('SMSsecenekler', 'SmsKullanici', '');
  Result.SMSSifre := ESHesapIni.ReadString('SMSsecenekler', 'SmsSifre', '');
  Result.SMSBaslik := ESHesapIni.ReadString('SMSsecenekler', 'SmsBaslik', '');
  Result.SMSServisSaglayici := ESHesapIni.ReadString('SMSsecenekler', 'SMSSaglayici', 'BioTekno')
end;


function SMSKontorSorgula: TSmsKontorSonucu;
var
  HTTPReq: OleVariant;
  XMLStructe, DonusBilgisi: TStringList;
      //DonusBilgisi:String;
  link: string;
  Donen: TSmsKontorSonucu;
  InHttp: TIdHTTP;
begin
      //3422800016
      // gen16tip
  XMLStructe := TStringList.create;
  DonusBilgisi := TStringList.Create;
  if SMSHesapBilgileri.SMSServisSaglayici = 'SmsNext' then
  begin
    try
      XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
        '<Main><UserName>' + SMSHesapBilgileri.SMSKullaniciAdi + '</UserName><PassWord>' + SMSHesapBilgileri.SMSSifre + '</PassWord></Main>';
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://secure.smsnext.com/developer/bulksmsv2/queryKontor.asp', False);
            //ID:1310411
      HTTPReq.send(XMLStructe.Text);
      DonusBilgisi.Text := HTTPReq.responseText;
    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end;
    if copy(DonusBilgisi.Strings[0], 1, 2) = 'WP' then
    begin
                  //Hata Olu�tu demektir bunlar� bi alal�m
                  //D�nen Hata kodlar�
                  //WP:00  Hatal� Kullan�c� Ad� yada �ifresi
                  //WP:01  Ge�ersiz IP Adresi
                  //WX:02  Kont�rlu Hesap De�il
                  //WX:03  Kont�r Hatas�
                  //WP:90   XML Hatas�
      Donen.HataKodu := copy(DonusBilgisi.Strings[0], 4, 2);
      if Donen.HataKodu = '00' then
        Donen.Mesaj := 'Hatal� Kullan�c� Ad� yada �ifresi'
      else if Donen.HataKodu = '01' then
        Donen.Mesaj := 'Ge�ersiz IP Adresi'
      else if Donen.HataKodu = '02' then
        Donen.Mesaj := 'Kont�rl� Hesap De�il'
      else if Donen.HataKodu = '03' then
        Donen.Mesaj := 'Kont�r Hatas�'
      else if Donen.HataKodu = '90' then
        Donen.Mesaj := 'XML Hatas�';
      Donen.KontorMiktari := '0';
    end
    else
    begin
                  // Hata Yoksa Kont�r miktar�n� ve mesaj�n� olu�tural�m
      Donen.HataKodu := '-1';
      Donen.KontorMiktari := DonusBilgisi.Strings[0];
      Donen.Mesaj := 'Kont�r Son kullan�m tarihi :' + copy(DonusBilgisi.Strings[1], 7, 2) + '/' + copy(DonusBilgisi.Strings[1], 5, 2) + '/' + copy(DonusBilgisi.Strings[1], 1, 4);
    end;
  end // if SMSHesapBilgileri.SMSServisSaglayici = 'SmsNext'

  else if SMSHesapBilgileri.SMSServisSaglayici = 'BioTekno' then
  begin
            //D�nen Kodlar
            //20 Ge�ersiz  xml file
            //10 Kullan�c� Kodu / �ifresi hatal�
            //90 Sistem hatas�
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

  end; //else if SMSHesapBilgileri.SMSServisSaglayici = 'BioTekno'

  Result := Donen;

end;


function TopluSmsAt(Mesajlar: array of TSmsMesaj; Bastar, Bittar: TDateTime; Zamanli: boolean): TSmsMesajSonuc;
var
  HTTPReq: OleVariant;
  XMLStructe, DonusBilgisi: TStringList;
  i,x: Integer;
  donen: TSmsMesajSonuc;
  dizin,  QueryOrtak,yedek,ZamanEk: string;
   StartItemNode : IXMLNode;
  ANode : IXMLNode;
  InsertID, InsertRes:  widestring;

begin
  XMLStructe := TStringList.create;
  DonusBilgisi := TStringList.Create;
  if SMSHesapBilgileri.SMSServisSaglayici = 'SmsNext' then
  begin
          //Ba�l�k K�sm� standart bilgilerin haz�rlanmas�
    XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<MainmsgBody xmlns:sql=''urn:schemas-microsoft-com:xml-sql'' xmlns:updg=''urn:schemas-microsoft-com:xml-updategram''>' +
      '<UserName>' + SMSHesapBilgileri.SMSKullaniciAdi + '</UserName>' +
      '<PassWord>' + SMSHesapBilgileri.SMSSifre + '</PassWord>' +
      '<Developer>1521</Developer>' +
      '<Version>xVer.2.0</Version>' +
      '<Originator>' + SMSHesapBilgileri.SMSBaslik + '</Originator>' +
      '<Messages>';
          //D�ng� ile dizideki mesaj ve numaralar� alal�m
    for i := 0 to High(Mesajlar) do
    begin
      if Telformatla(mesajlar[i].Numara) <> '0' then
      begin
        XMLStructe.Text := XMLStructe.Text +
          '<Message>' +
          '<Msgbody>' + Mesajlar[i].Mesaj + '</Msgbody>' +
          '<Number>' + Mesajlar[i].Numara + '</Number>' +
          '<SDate>' + FormatDateTime('ddmmyyyyhhnnss' ,Bastar) + '</SDate>' +
          '<EDate>' + FormatDateTime('ddmmyyyyhhnnss' ,Bittar) + '</EDate>' +
          '</Message>';
      end;
    end;
    XMLStructe.Text := XMLStructe.Text +
      '</Messages>' +
      '</MainmsgBody>';
    try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://secure.smsnext.com/developer/Bulksmsv2/sendsmsmulti.asp', False);
      HTTPReq.send(StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]));
      if not DirectoryExists('XML') then
        MkDir('XML');
      dizin := ExtractFileDir(Application.ExeName) + '\XML\' + FormatDateTime('yyyymmddhhnn', Now) + '-SmsNextsms.xml';
      XMLStructe.SaveToFile(dizin);
      DonusBilgisi.Text := HTTPReq.responseText;
    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End

    if copy(DonusBilgisi.Strings[0], 1, 2) <> 'ID' then
    begin
              //Hata Olu�tu demektir bunlar� bi alal�m
              //D�nen Hata kodlar
              //WP:00	Kullan�c� ad� yada �ifresi hatal�
              //WP:04	Developer  Yanl��
              //WP:05	Hatal� Originator
              //WP:14	Mesaj metni girilmemi�
              //WP:15	GSM numaras� girilmemi�
              //WP:90	Xml hatas�
              //CR:22	Ayl�k limit adedi girilmemi�
              //CR:27	Ayl�k limiti kalmam��
              //CP:00	Kont�r hatas�
      Donen.HataKodu := copy(DonusBilgisi.Strings[0], 1, 5);
      if Donen.HataKodu = 'WP:00' then
        Donen.Mesaj := 'Hatal� Kullan�c� Ad� yada �ifresi'
      else if Donen.HataKodu = 'WP:04' then
        Donen.Mesaj := 'Developer Yanl��'
      else if Donen.HataKodu = 'WP:05' then
        Donen.Mesaj := 'Hatal� Ba�l�k'
      else if Donen.HataKodu = 'WP:15' then
        Donen.Mesaj := 'GSM numaras� girilmemi�'
      else if Donen.HataKodu = 'WP:14' then
        Donen.Mesaj := 'Mesaj metni girilmemi�'
      else if Donen.HataKodu = 'WP:90' then
        Donen.Mesaj := 'XML Hatas�'
      else if Donen.HataKodu = 'CR:22' then
        Donen.Mesaj := 'Ayl�k limit adedi girilmemi�'
      else if Donen.HataKodu = 'CR:27' then
        Donen.Mesaj := 'Ayl�k limiti kalmam��'
      else if Donen.HataKodu = 'CP:00' then
        Donen.Mesaj := 'Kont�r hatas�'
      else
        Donen.Mesaj := 'G�nderim Ba�ar�s�z';
    end
    else
    begin
            // Hata Yoksa mesaj referans�n�  ve mesaj�n� olu�tural�m
      Donen.HataKodu := '-1';
      donen.MesajRefNo := trim(copy(DonusBilgisi.Strings[0], 4, 100));
      Donen.Mesaj := 'G�nderildi'    ;
      if donen.HataKodu = '-1' then
      begin
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'UPDATE CAGRI SET ' +
        ' STATU = 1 ,' +
        ' MSGREFERANS = ''' + donen.MesajRefNo + ''',' +
        ' SERVIS = ''' + SMSHesapBilgileri.SMSServisSaglayici + '''' +
        ' WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    ISNULL(MSGREFERANS,''0'') =''0'' and CEPTEL<>''0'' and [ID] IN (' +
        '       Select '+DbUst(1000)+'[ID] from CAGRI ' +
        '       Where  SEC= 1 AND  ' +
        '         ILETKANALI = ''SMS''  AND ' +
        '         STATU = 0 ' +
        '       ORDER BY [ID] '+DbSinir(1000)+ ')';

      Tablo.Query3.ExecSQL;
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'UPDATE CAGRI SET ' +
        ' STATU = -1 ,' +
        ' SONUC = ''Hatal�'' ,' +
        ' MSGREFERANS = '''',' +
        ' SERVIS = '''' ' +
        ' WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    CEPTEL=''0'' and [ID] IN (' +
        '       Select '+DbUst(1000)+'[ID] from CAGRI ' +
        '       Where  SEC= 1 AND  ' +
        '         ILETKANALI = ''SMS''  AND ' +
        '         STATU = 0 ' +
        '       ORDER BY [ID] '+DbSinir(1000)+ ')';

      Tablo.Query3.ExecSQL;

      Tablo.Query2.Close;
      Tablo.Query2.SQL.Clear;
      Tablo.Query2.SQL.Add('INSERT INTO SMSPOSTA(KAYITNO,AD,SOYAD,ILETITURU, TELEFON, TARIH, GONDERIMTARIHI ');
      Tablo.Query2.SQL.Add(', MODUL,MESAJ, SONUC, MSGREFERANSKOD, SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, GONDEREN )');
      Tablo.Query2.SQL.Add(' select DOSYANO,AD,SOYAD,''SMS'',CEPTEL,CAGRITARIH,KAYITARIHI ');
      Tablo.Query2.SQL.Add(',''J'',MESAJ,SONUC,MSGREFERANS,SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, KULLANICI  ');

      QueryOrtak := ' from CAGRI  ' +
        '    WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    ISNULL(MSGREFERANS,''0'') <>''0'' ' +
        '    AND ( STATU=''1'' OR STATU=''-1'') ';

      Tablo.Query2.SQL.Add(QueryOrtak);
      Tablo.Query2.ExecSQL;

      Tablo.Query2.Close;
      Tablo.Query2.SQL.text := ' delete ';
      TAblo.Query2.SQL.Add(QueryOrtak);

      Tablo.Query2.ExecSQL;

    end //if donen.HataKodu = '-1' then









    end;

  end //if SMSHesapBilgileri.SMSServisSaglayici = 'SmsNext' then
  else if SMSHesapBilgileri.SMSServisSaglayici = 'BioTekno' then
  begin
          //Biotekno i�in ba�l�k bilgisini ayarl�yoruz
    XMLStructe.Text := '<?xml version="1.0" encoding="iso-8859-9" ?>' +
      '<message-context type="mmmgsd">' +
      '<username>' + smsHesapBilgileri.SMSKullaniciAdi + '</username>' +
      '<password>' + smsHesapBilgileri.SMSSifre + '</password>' +
      '<outbox-name>' + smsHesapBilgileri.SMSBaslik + '</outbox-name>' +
      '<reference>0</reference>' +
      '<start-date>' + FormatDateTime('ddmmyyyyhhnnss' ,Bastar) + '</start-date>' +
      '<expire-date>' +FormatDateTime('ddmmyyyyhhnnss' , Bittar) + '</expire-date>';
          //<message>
          //<gsmno>90532XXXYYZZ</gsmno>
          //<text>test message one</text>
          //</message>
          //D�ng� ile dizideki mesaj ve numaralar� alal�m
    for i := 0 to High(Mesajlar) do
    begin
      if Telformatla(mesajlar[i].Numara) <> '0' then
      begin
        XMLStructe.Text := XMLStructe.Text +
          '<message>' +
          '<gsmno>' + Mesajlar[i].Numara + '</gsmno>' +
          '<message-type>0</message-type>' +
          '<text>' + Mesajlar[i].Mesaj + '</text>' +
          '</message>';
      end;
    end;
    XMLStructe.Text := XMLStructe.Text + '</message-context>';
    try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://www.biotekno.biz:8080/SMS-Web/xmlsms', False);
              //ID:1310411
      HTTPReq.send(StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]));
      if not DirectoryExists('XML') then
        MkDir('XML');
      dizin := ExtractFileDir(Application.ExeName) + '\XML\' + FormatDateTime('yyyymmddhhnn', Now) + '-BioTeknosms.xml';
      XMLStructe.SaveToFile(dizin);
//      XMLStructe.SaveToFile('\XML'+FormatDateTime('yyyymmddhhnn', Now) + '-BioTeknosms.xml');
      DonusBilgisi.Text := HTTPReq.responseText;
    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End
          //20 Ge�ersiz  xml file
          //10 Kullan�c� Kodu / �ifresi hatal�
          //11 Kont�r Yetersiz
          //81 Sms limiti ge�ildi.
          //90 Sistem hatas�
          //00 Ba�ar�l�
    donen.HataKodu := Copy(DonusBilgisi.Text, 1, 2);
    if donen.HataKodu = '20' then
      donen.Mesaj := 'Ge�ersiz  xml dosyas�'
    else if donen.HataKodu = '10' then
      donen.Mesaj := 'Kullan�c� Kodu / �ifresi hatal�'
    else if donen.HataKodu = '11' then
      donen.Mesaj := 'Kont�r yetersiz'
    else if donen.HataKodu = '81' then
      donen.Mesaj := 'SMS limiti ge�ildi'
    else if donen.HataKodu = '90' then
      donen.Mesaj := 'Sistem hatas�'
    else if donen.HataKodu = '00' then
    begin
      donen.HataKodu := '-1';
      donen.Mesaj := 'G�nderildi';
      donen.MesajRefNo := Copy(DonusBilgisi.Text, 4, length(DonusBilgisi.Text) - 5);

         if donen.HataKodu = '-1' then
      begin
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'UPDATE CAGRI SET ' +
        ' STATU = 1 ,' +
        ' MSGREFERANS = ''' + donen.MesajRefNo + ''',' +
        ' SERVIS = ''' + SMSHesapBilgileri.SMSServisSaglayici + '''' +
        ' WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    ISNULL(MSGREFERANS,''0'') =''0'' and CEPTEL<>''0'' and [ID] IN (' +
        '       Select '+DbUst(1000)+'[ID] from CAGRI ' +
        '       Where  SEC= 1 AND  ' +
        '         ILETKANALI = ''SMS''  AND ' +
        '         STATU = 0 ' +
        '       ORDER BY [ID] '+DbSinir(1000)+ ')';

      Tablo.Query3.ExecSQL;
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'UPDATE CAGRI SET ' +
        ' STATU = -1 ,' +
        ' SONUC = ''Hatal�'' ,' +
        ' MSGREFERANS = '''',' +
        ' SERVIS = '''' ' +
        ' WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    CEPTEL=''0'' and [ID] IN (' +
        '       Select '+DbUst(1000)+'[ID] from CAGRI ' +
        '       Where  SEC= 1 AND  ' +
        '         ILETKANALI = ''SMS''  AND ' +
        '         STATU = 0 ' +
        '       ORDER BY [ID] '+DbSinir(1000)+ ')';

      Tablo.Query3.ExecSQL;

      Tablo.Query2.Close;
      Tablo.Query2.SQL.Clear;
      Tablo.Query2.SQL.Add('INSERT INTO SMSPOSTA(KAYITNO,AD,SOYAD,ILETITURU, TELEFON, TARIH, GONDERIMTARIHI ');
      Tablo.Query2.SQL.Add(', MODUL,MESAJ, SONUC, MSGREFERANSKOD, SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, GONDEREN )');
      Tablo.Query2.SQL.Add(' select DOSYANO,AD,SOYAD,''SMS'',CEPTEL,CAGRITARIH,KAYITARIHI ');
      Tablo.Query2.SQL.Add(',''J'',MESAJ,SONUC,MSGREFERANS,SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, KULLANICI  ');

      QueryOrtak := ' from CAGRI  ' +
        '    WHERE ' +
        '    SEC = ''1'' AND ' +
        '    ILETKANALI = ''SMS'' and  ' +
        '    ISNULL(MSGREFERANS,''0'') <>''0'' ' +
        '    AND ( STATU=''1'' OR STATU=''-1'') ';

      Tablo.Query2.SQL.Add(QueryOrtak);
      Tablo.Query2.ExecSQL;

      Tablo.Query2.Close;
      Tablo.Query2.SQL.text := ' delete ';
      TAblo.Query2.SQL.Add(QueryOrtak);

      Tablo.Query2.ExecSQL;

    end //if donen.HataKodu = '-1' then





    end
    else
      donen.Mesaj := 'G�nderim ba�ar�s�z';
  end //else  if SMSHesapBilgileri.SMSServisSaglayici = 'BioTekno' then
  else if SMSHesapBilgileri.SMSServisSaglayici = 'PostaG�vercini'      then
  begin
     if Zamanli  then
         ZamanEk := 'dt="'+FormatDateTime('yyyy/mm/dd hh:nn',Bastar)+'" dt2="'+FormatDateTime('yyyy/mm/dd hh:nn',Bittar)+'"'
     else
       ZamanEk:='dt="'+FormatDateTime('yyyy/mm/dd hh:nn',Now)+'"';


     //Ba�l�k K�sm� standart bilgilerin haz�rlanmas�
    XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<SMS-InsRequest>' +
      '<CLIENT user="'+SMSHesapBilgileri.SMSKullaniciAdi+'" pwd="'+SMSHesapBilgileri.SMSSifre +'"/>'  ;

          //D�ng� ile dizideki mesaj ve numaralar� alal�m
    for i := 0 to High(Mesajlar) do
    begin
      if Telformatla(mesajlar[i].Numara) <> '0' then
      begin
        If copy( Mesajlar[i].Numara,1,2) = '90' then
          Mesajlar[i].Numara :=  copy( Mesajlar[i].Numara,3,length( Mesajlar[i].Numara)-2) ;
        XMLStructe.Text := XMLStructe.Text + '<INSERT to="'+Mesajlar[i].Numara+ '" text="'+Mesajlar[i].Mesaj+'" '+ ZamanEk+ '/>'
      end;
    end;
    XMLStructe.Text := XMLStructe.Text +  '</SMS-InsRequest>';
    try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://www.postaguvercini.com/api_xml/Sms_insreq.asp ', False);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#13,'', [rfReplaceAll]);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#10,'', [rfReplaceAll]);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#13#10,'', [rfReplaceAll]);
      HTTPReq.send(XMLStructe.Text);
      if not DirectoryExists('XML') then
        MkDir('XML');
      dizin := ExtractFileDir(Application.ExeName) + '\XML\' + FormatDateTime('yyyymmddhhnn', Now) + '-PostaGuvercinisms.xml';
      XMLStructe.SaveToFile(dizin);

      DonusBilgisi.Text :=   StringReplace( HTTPReq.responseText ,#13,'', [rfReplaceAll]);
      DonusBilgisi.Text :=   StringReplace( DonusBilgisi.Text ,#10,'', [rfReplaceAll]);
      DonusBilgisi.Text :=   StringReplace( DonusBilgisi.Text ,#13#10,'', [rfReplaceAll]);
  //    DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'</SMS-Response>','',[rfReplaceAll]);
   //   DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'<SMS-Response>','',[rfReplaceAll]);




    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End

   {
              Hata Numaras�	A��klama
              ERR1010	�stek Hatas�. Veritaban� ba�lant� i�lemi yap�lamad�
              ERR1020	�stek Hatas�. Veritaban�na ba�lanamad�.
              ERR1030	�stek Hatas�. �stek tarih�e kayd� tutalamad�.
              ERR1040	�stek Hatas�. �stek tarih�e kay�t numaras� al�namad�.
              ERR1050	�stek Hatas�. �stek de�erlendirilemedi. (Hatal� istek format�)
               }
       if   pos ('<ERROR>',DonusBilgisi.Text) > 0   then
       begin
            //Hatavar
              if  pos('ERR1050',DonusBilgisi.Text) > 0 then
              begin

                  Donen.HataKodu:='ERR1050';
                  donen.Mesaj :='�stek Hatas�. �stek de�erlendirilemedi. (Hatal� istek format�)';
              end
              else if  pos('ERR1040',DonusBilgisi.Text) > 0 then
              begin

                  Donen.HataKodu:='ERR1040';
                  donen.Mesaj :='�stek Hatas�. �stek tarih�e kay�t numaras� al�namad�.';
              end
              else if  pos('ERR1030',DonusBilgisi.Text) > 0 then
              begin

                  Donen.HataKodu:='ERR1030';
                  donen.Mesaj :='�stek Hatas�. �stek tarih�e kayd� tutalamad�.';
              end
              else if  pos('ERR1020',DonusBilgisi.Text) > 0 then
              begin

                  Donen.HataKodu:='ERR1020';
                  donen.Mesaj :='�stek Hatas�. Veritaban�na ba�lanamad�.';
              end
              else if  pos('ERR1010',DonusBilgisi.Text) > 0 then
              begin
                  Donen.HataKodu:='ERR1010';
                  donen.Mesaj :='�stek Hatas�. Veritaban� ba�lant� i�lemi yap�lamad�';
              end
              else
                  Donen.Mesaj := 'G�nderim Ba�ar�s�z';
       end
    else
    begin
    Tablo.XMLDocument1.XML.Text:= DonusBilgisi.Text;
    //ShowMessage( Tablo.XMLDocument1.XML.Text);
     x:=0;
   Tablo.XMLDocument1.Active:=True;
   StartItemNode:=Tablo.XMLDocument1.DocumentElement.ChildNodes.FindNode('INSERT');
    ANode :=   StartItemNode;
    repeat
      InsertID := ANode.Attributes['id'];
      InsertRes := ANode.Attributes['res'];
//      ShowMessage(Inttostr(Mesajlar[x].Id)+'--'+  Mesajlar[x].Numara+ ' numara i�in  Id= '+ InsertID + ' '+ InsertRes);
      if Mesajlar[x].Id <> -1 then
        TekliMesajReferansGuncelle(Mesajlar[x].Id,Mesajlar[x].Numara,InsertID)   ;
      inc(x);

      ANode := ANode.NextSibling;
    until ANode = nil;
      // Hata Yoksa mesaj referans�n�  ve mesaj�n� olu�tural�m
      Donen.HataKodu := '-1';
      donen.MesajRefNo := InsertID;
      Donen.Mesaj := 'G�nderildi'
    end;

  end;


  Result := Donen;
end;

procedure SMSGonderiKontrolToplu(MesajReferansNo, Servis: string);
var link, vbNumara, vbGrupId, cevap1, satir: string;
  cevap: TStrings;
  vbStatu: string[2];
  Kontrol:string;
  InHttp: TIdHTTP;
  i,sayi: integer;
  XMLStructe, DonusBilgisi: TStringList;
  HTTPReq: OleVariant;
begin
  cevap := TStringList.Create;
  XMLStructe := TStringList.create;
  DonusBilgisi := TStringList.Create;


  if ((Servis = 'BioTekno')  AND  (SMSHesapBilgileri.SMSServisSaglayici =  Servis ))  then
  begin
    InHttp := TIdHTTP.Create(nil);
    link := 'http://www.biotekno.biz:8080/SMS-Web/xmlreport?username=' + SMSHesapBilgileri.SMSKullaniciAdi + '&password=' + SMSHesapBilgileri.SMSSifre + '&groupid=' + MesajReferansNo + '&status=5';
    cevap.Text := InHttp.Get(link);
//    cevap.SaveToFile('Sorgulama_' + MesajReferansNo + '.txt');
            //Hata varm� yokmu kontrol edelim
            //g�nderdi�imiz mesaj �d gelmiyorsa hata olu�tu demektir
    if copy(cevap.text, 1, 15) <> MesajReferansNo then
    begin
//      ShowMessage(cevap.Text);
    end
    else
    begin
      for i := 0 to cevap.Count - 1 do
      begin
                  //1(ba�ar�l�)  g�nderilen mesajlar�n sorgulamas�nda,
                  //2(beklemede) g�nderimi hen�z ula�mam��
                  //3(hatal�)  hatal� telefon numaras�
                  //4(zaman a��m�) Art�k g�nderilmeye denenmeyecek
                  //5(hepsi) b�t�n stat� kodlular d�nd�r�l�r i�in kullan�l�r.
        vbGrupId := copy(cevap.Strings[i], 1, 15);
        vbNumara := copy(cevap.Strings[i], 17, 12);
        vbStatu := copy(cevap.Strings[i], 30, 1);

        if vbStatu = '1' then
        begin
                      //statuy� 9 yani g�nderim ba�ar�l�
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
            'STATU = 9 ,' +
            'SONUC = ''Ba�ar�l�''' +
            'WHERE ' +
            'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
            ' TELEFON   =''' + vbNumara + '''';
          Tablo.Query1.ExecSQL;
        end else if vbStatu = '3' then
        begin
                      //statuy� -1 yani g�nderim hatal�
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
            'STATU = -1 ,' +
            'SONUC = ''Hatal�''' +
            'WHERE ' +
            'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
            ' TELEFON   =''' + vbNumara + '''';
          Tablo.Query1.ExecSQL;
        end else if vbStatu = '4' then
        begin
                      //statuy� -1 yani g�nderim hatal�
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
            'STATU = -1 ,' +
            'SONUC = ''Zaman A��m�''' +
            'WHERE ' +
            'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
            ' TELEFON   =''' + vbNumara + '''';
          Tablo.Query1.ExecSQL;
        end
      end; //for end
    end; // else copy(cevap.text,1,15) <> MesajReferansNo then
  end //if Servis = 'Biotekno' then

  else if ( (Servis = 'SmsNext' ) AND  (SMSHesapBilgileri.SMSServisSaglayici =  Servis ))then
  begin
    {
              <MainReportRoot>
              <UserName> User ID</UserName>
              <PassWord>Password</PassWord>
              <MsgID> 123456</MsgID>
              </MainReportRoot>
    }
    XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<MainReportRoot>' +
      '<UserName>' + SMSHesapBilgileri.SMSKullaniciAdi + '</UserName>' +
      '<PassWord>' + SMSHesapBilgileri.SMSSifre + '</PassWord>' +
      '<MsgID>' + MesajReferansNo + '</MsgID></MainReportRoot>';

    try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://secure.smsnext.com/developer/bulksmsv2/bulkreport.asp', False);
              //ID:1310411
      HTTPReq.send(StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]));
//  XMLStructe.SaveToFile(FormatDateTime('yyyymmddhhnn', Now) + '-SmsNextsms.xml');
      DonusBilgisi.Text := HTTPReq.responseText;
//      DonusBilgisi.SaveToFile('Sorgulama_' + MesajReferansNo + '.txt');
    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End
//    if trim(copy(DonusBilgisi.Text, 0, pos(' ', DonusBilgisi.text))) <> MesajReferansNo then
//    begin
//      ShowMessage(cevap.Text);
//    end
//    else
//    begin
    for i := 0 to DonusBilgisi.Count - 1 do
    begin
      // (2: pending 3 : delivered 4 : bad message 5 : rejected 6 : expired )
       // showmessage(  inttostr(pos(' ',DonusBilgisi.text)) +' '+DonusBilgisi.text );
      satir := DonusBilgisi.Strings[i];
        //GrupIdyi bulal�m
      vbGrupId := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));
        //Numaray� bulal�m
      vbNumara := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));
        //Stat�y� bulal�m
      vbStatu := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));

      if vbStatu = '3' then
      begin
                      //statuy� 9 yani g�nderim ba�ar�l�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = 9 ,' +
          'SONUC = ''Ba�ar�l�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
          ' TELEFON   =''' + vbNumara + '''';
        Tablo.Query1.ExecSQL;
      end else if vbStatu = '4' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Hatal�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
          ' TELEFON   =''' + vbNumara + '''';
        Tablo.Query1.ExecSQL;
      end else if vbStatu = '5' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Reddedildi''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
          ' TELEFON   =''' + vbNumara + '''';
        Tablo.Query1.ExecSQL;
      end
      else if vbStatu = '6' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Zaman A��m�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + vbGrupId + ''' AND ' +
          ' TELEFON   =''' + vbNumara + '''';
        Tablo.Query1.ExecSQL;
      end
    end; //for end
//    end; // else copy(cevap.text,1,15) <> MesajReferansNo then


  end  //Servis = 'SmsNext' then
      else if(( Servis = 'PostaG�vercini' )AND  (SMSHesapBilgileri.SMSServisSaglayici =  Servis )) then
      begin
       //Ba�l�k K�sm� standart bilgilerin haz�rlanmas�
    XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<SMS-StaRequest>' +
      '<CLIENT user="'+SMSHesapBilgileri.SMSKullaniciAdi+'" pwd="'+SMSHesapBilgileri.SMSSifre +'"/>' +
     '  <STATUS id="'+MesajReferansNo+'" />'    ;
     XMLStructe.Text := XMLStructe.Text +  '</SMS-StaRequest>';


        try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://www.postaguvercini.com/api_xml/Sms_stareq.asp ', False);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#13,'', [rfReplaceAll]);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#10,'', [rfReplaceAll]);
      XMLStructe.Text := StringReplace( XMLStructe.Text ,#13#10,'', [rfReplaceAll]);
      HTTPReq.send(XMLStructe.Text);


      DonusBilgisi.Text :=   StringReplace( HTTPReq.responseText ,#13,'', [rfReplaceAll]);
      DonusBilgisi.Text :=   StringReplace( DonusBilgisi.Text ,#10,'', [rfReplaceAll]);
      DonusBilgisi.Text :=   StringReplace( DonusBilgisi.Text ,#13#10,'', [rfReplaceAll]);
  //    DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'</SMS-Response>','',[rfReplaceAll]);
   //   DonusBilgisi.Text := StringReplace(DonusBilgisi.Text,'<SMS-Response>','',[rfReplaceAll]);
     // vbStatu:=inttostr(pos('res="', DonusBilgisi.text));
    kontrol:=Copy(DonusBilgisi.Text , pos('res="', DonusBilgisi.text)+5, (pos('|', DonusBilgisi.text)- (pos('res="', DonusBilgisi.text)+5 ))   );



    if Kontrol = '400' then
      begin
                      //statuy� 9 yani g�nderim ba�ar�l�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = 9 ,' +
          'SONUC = ''Ba�ar�l�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
      else if Kontrol = '402' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Al�c�ya Ula�mad�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
      else if Kontrol = '410' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Mesaj SMSC de bulunamad�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
       else if Kontrol = '420' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Mesaj sunucuda bulunamad�''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
      else if Kontrol = '-20' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Bu mesaj size a ait de�il''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo  +'''';
        Tablo.Query1.ExecSQL;
      end
      else if Kontrol = '-201' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Ge�ersiz cep no.)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
       else if Kontrol = '-202' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Mesaj tekrar�)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
         else if Kontrol = '-203' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Ge�ersiz son g�nderim tarihi)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
          else if Kontrol = '-205' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Mesaj �ok uzun)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo  +'''';
        Tablo.Query1.ExecSQL;
      end
          else if Kontrol = '-207' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Smsc redetti)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
          else if Kontrol = '-210' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Zaman a��m�)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
             else if Kontrol = '-220' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Yetersiz kredi zaman a��m�)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
            else if Kontrol = '-222' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (Abone mesaj�n bloke edilmesi tercih etti�inden)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
               else if (strtoint( Kontrol) >= -201 ) and  (strtoint(kontrol)<=-299) then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi (M��teri taraf�ndan)''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end
               else if Kontrol = '-220' then
      begin
                      //statuy� -1 yani g�nderim hatal�
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'UPDATE SMSPOSTA SET ' +
          'STATU = -1 ,' +
          'SONUC = ''Silindi1''' +
          'WHERE ' +
          'MSGREFERANSKOD = ''' + MesajReferansNo +'''' ;
        Tablo.Query1.ExecSQL;
      end

    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End


      end;


end;

function SMSGonderiKontrolTek(MesajReferansNo, Servis: string): string;
var link, vbNumara, vbGrupId, cevap1, satir: string;
  cevap: TStrings;
  vbStatu: string[2];
  InHttp: TIdHTTP;
  i: integer;
  XMLStructe, DonusBilgisi: TStringList;
  HTTPReq: OleVariant;
begin
  cevap := TStringList.Create;
  XMLStructe := TStringList.create;
  DonusBilgisi := TStringList.Create;
  if Servis = 'BioTekno' then
  begin
    InHttp := TIdHTTP.Create(nil);
    link := 'http://www.biotekno.biz:8080/SMS-Web/xmlreport?username=' + SMSHesapBilgileri.SMSKullaniciAdi + '&password=' + SMSHesapBilgileri.SMSSifre + '&groupid=' + MesajReferansNo + '&status=5';
    cevap.Text := InHttp.Get(link);
//    cevap.SaveToFile('Sorgulama_' + MesajReferansNo + '.txt');
            //Hata varm� yokmu kontrol edelim
            //g�nderdi�imiz mesaj �d gelmiyorsa hata olu�tu demektir
    if copy(cevap.text, 1, 15) <> MesajReferansNo then
    begin
//      ShowMessage(cevap.Text);
    end
    else
    begin
      for i := 0 to cevap.Count - 1 do
      begin
                  //1(ba�ar�l�)  g�nderilen mesajlar�n sorgulamas�nda,
                  //2(beklemede) g�nderimi hen�z ula�mam��
                  //3(hatal�)  hatal� telefon numaras�
                  //4(zaman a��m�) Art�k g�nderilmeye denenmeyecek
                  //5(hepsi) b�t�n stat� kodlular d�nd�r�l�r i�in kullan�l�r.
        vbGrupId := copy(cevap.Strings[i], 1, 15);
        vbNumara := copy(cevap.Strings[i], 17, 12);
        vbStatu := copy(cevap.Strings[i], 30, 1);

        if vbStatu = '1' then
        begin
          Result := 'Ba�ar�l�';
        end else if vbStatu = '2' then
        begin
          Result := 'Beklemede';
        end else if vbStatu = '3' then
        begin
          Result := 'Hatal�';
        end else if vbStatu = '4' then
        begin
          Result := 'Zaman A��m�';
        end
        else Result := '';
      end; //for end
    end; // else copy(cevap.text,1,15) <> MesajReferansNo then
  end //if Servis = 'Biotekno' then
  else if Servis = 'SmsNext' then
  begin
    {
              <MainReportRoot>
              <UserName> User ID</UserName>
              <PassWord>Password</PassWord>
              <MsgID> 123456</MsgID>
              </MainReportRoot>
    }
    XMLStructe.Text := '<?xml version="1.0" encoding="ISO-8859-9"?>' +
      '<MainReportRoot>' +
      '<UserName>' + SMSHesapBilgileri.SMSKullaniciAdi + '</UserName>' +
      '<PassWord>' + SMSHesapBilgileri.SMSSifre + '</PassWord>' +
      '<MsgID>' + MesajReferansNo + '</MsgID></MainReportRoot>';

    try
      HTTPReq := CreateOleObject('MSXML2.XMLHTTP.6.0');
      HTTPReq.open('post', 'http://secure.smsnext.com/developer/bulksmsv2/bulkreport.asp', False);
              //ID:1310411
      HTTPReq.send(StringReplace(XMLStructe.Text, #13#10, '', [rfReplaceAll]));
//      XMLStructe.SaveToFile(FormatDateTime('yyyymmddhhnn', Now) + '-SmsNextsms.xml');
      DonusBilgisi.Text := HTTPReq.responseText;
//      DonusBilgisi.SaveToFile('Sorgulama_' + MesajReferansNo + '.txt');
    finally
      XMLStructe.free;
      HTTPReq := Unassigned;
    end; //Try End
//    if trim(copy(DonusBilgisi.Text, 0, pos(' ', DonusBilgisi.text))) <> MesajReferansNo then
//    begin
//      ShowMessage(DonusBilgisi.Text);
//    end
//    else
//    begin
    for i := 0 to DonusBilgisi.Count - 1 do
    begin
      // (2: pending 3 : delivered 4 : bad message 5 : rejected 6 : expired )
       // showmessage(  inttostr(pos(' ',DonusBilgisi.text)) +' '+DonusBilgisi.text );
      satir := DonusBilgisi.Strings[i];
        //GrupIdyi bulal�m
      vbGrupId := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));
        //Numaray� bulal�m
      vbNumara := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));
        //Stat�y� bulal�m
      vbStatu := trim(copy(satir, 0, pos(' ', satir)));
      delete(satir, 1, pos(' ', satir));

      if vbStatu = '2' then begin
        Result := 'Beklemede';
      end else if vbStatu = '3' then
      begin
        Result := 'Ba�ar�l�';
      end else if vbStatu = '4' then
      begin
        Result := 'Hatal�';
      end else if vbStatu = '5' then
      begin
        Result := 'Reddedildi';
      end
      else if vbStatu = '6' then
      begin
        Result := 'Zaman A��m�'
      end
      else Result := '';
    end; //for end
//    end; // else copy(cevap.text,1,15) <> MesajReferansNo then
  end //Servis = 'SmsNext' then
  else Result := '';

end;

procedure TekliMesajReferansGuncelle(Id :integer ; Numara ,MesRefNo :string  );
begin


 Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'UPDATE CAGRI SET ' +
        ' STATU = 1 ,' +
        ' MSGREFERANS = ''' + MesRefNo + ''',' +
        ' SERVIS = ''' + SMSHesapBilgileri.SMSServisSaglayici + '''' +
        ' WHERE ' +
        '       [ID] =  '+IntToStr( Id)   ;
       Tablo.Query3.ExecSQL;

      Tablo.Query2.Close;
      Tablo.Query2.SQL.Clear;
      Tablo.Query2.SQL.Add('INSERT INTO SMSPOSTA(KAYITNO,AD,SOYAD,ILETITURU, TELEFON, TARIH, GONDERIMTARIHI ');
      Tablo.Query2.SQL.Add(', MODUL,MESAJ, SONUC, MSGREFERANSKOD, SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, GONDEREN )');
      Tablo.Query2.SQL.Add(' select DOSYANO,AD,SOYAD,''SMS'',CEPTEL,CAGRITARIH,KAYITARIHI ');
      Tablo.Query2.SQL.Add(',''J'',MESAJ,SONUC,MSGREFERANS,SERVIS,STATU,EPOSTA,ACIKLAMA,SONGELTARIH, SONGELBOLUM ');
      Tablo.Query2.SQL.Add(', CAGIRANBOLUM, CAGIRANKISI, SEC, SABLONID, SABLONADI, KULLANICI  ');
      Tablo.Query2.SQL.Add(' FROM CAGRI ');
      Tablo.Query2.SQL.Add(' WHERE ');
      Tablo.Query2.SQL.Add(' [ID] =  ' +IntToStr( Id)   );
      Tablo.Query2.ExecSQL;


      
end;

end.


