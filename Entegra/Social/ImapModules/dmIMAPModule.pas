{
  M.Y.
  Önce Clever Internet Suite ile yazýldý
  "Clever"in SSL kütüphanesine ihtiyaç duymamasý iyi olsa da
  Kod Açýk kaynak "Indy" kütüphanesinin kullanýlmasý daha mantýklý geldi
  https://github.com/IndySockets/Indy

  "IMAP" protokolünün Telnet gibi komut setleri ile çalýþmasý kolaylýklar saðladýðýndan tercih edilmiþtir.
  bu ünite yalnýzca "IMAP4" protokolü için yazýlmýþtýr. "POP3" protokolü için ayrý bir ünite yazýlmalý

}

unit dmIMAPModule;

interface

uses
  System.SysUtils, System.Classes, IdSSLOpenSSLHeaders, IdComponent, IdIntercept, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdMessageClient, IdIMAP4, IdGlobal, uSocialCommon, uOrtakLog, IdMessage;

type
  TIMAPModule = class(TDataModule)
    IdIMAP4: TIdIMAP4;
    IdSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
    IdConnectionIntercept1: TIdConnectionIntercept;
    procedure IdConnectionIntercept1Send(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
    procedure IdConnectionIntercept1Receive(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FCertificateVerified: Boolean;
    //fPassword: string;
    //fUserName: string;
    //fServer: string;
    fRootFolder: string;
    //fUseTLS: boolean;
    //fPort: integer;
    fLastOutput: string;

    fSenderCriteria: string;
    function GetConnected: boolean;
    procedure SetConnected(const Value: boolean);
    function GetPort: word;
    procedure SetPort(const Value: Word);
    function GetPassword: string;
    function GetServer: string;
    function GetUserName: string;
    procedure SetPassword(const Value: string);
    procedure SetServer(const Value: string);
    procedure SetUserName(const Value: string);
    function GetTLS: TIdUseTLS;
    procedure SetTls(const Value: TIdUseTLS);
  published
    //property UseTLS : boolean read fUseTLS write fUseTLS;
    property Server : string read GetServer write SetServer;
    property UserName : string read GetUserName write SetUserName;
    property Password : string read GetPassword write SetPassword;
    property RootFolder : string read fRootFolder write fRootFolder;
    property Port : Word read GetPort write SetPort;
    property TLSSupport : TIdUseTLS read GetTLS write SetTls;
    property LastOutput : string read fLastOutput write fLastOutput;
    // IMAP bileþeni Connected durumuyla ayný
    property Connected : boolean read GetConnected write SetConnected;
    property SenderCriteria : string read fSenderCriteria write fSenderCriteria;
  public
    { Public declarations }
    procedure Connect;
    procedure Disconnect;
    // Arama için oluþan ' ' #32 SEARCH ile gelen ayraçlý liste TStrings türevine aktarýlýr
    // ' ' ayraçlý listeden FETCH için ',' ayraçlý string listeye dönüþtürülür
    function SearchListToFetch(_searchList : TStrings) : string; overload;
    function SearchListToFetch(_searchList : String) : string; overload;
    function ExecuteCmd( _cmd : string) : string;
    function YeniPostaID( _firstID : integer; _TargetList : TStrings) : string;
    function ParseLine(_tag,_source : string; var _target : string) : integer;
    procedure ExtractBody(_source :string; _targetList : TStrings);
    procedure SearchExt(_SearchStr : string; _OutputList : TStrings);
    procedure Search(_SearchStr : string; _outputList : TStrings);
    function GetMail( _mailID : string) : TIdMessage;
    procedure ExtractMail( _mail : TIdMessage; var aLead : recLead);
  end;

var
  IMAPModule: TIMAPModule;
  IMAPLoggerMethod : TLogMethod = nil;

resourcestring
   resBaglantiKurulmamis          = 'IMAP Baðlantýsý kurulmamýþ. "Connect" metodunu çaðýrýnýz.';
   resAktifBilesen_Degistirilemez = 'Baðlantý kurulmuþ bileþen deðeri/durumu deðiþtirilemez!';

procedure LogIMAP( _statusMessage : string);
function BytesToString(const ABuffer: TIdBytes): string;
function ImapDateToDateTime(_ImapDate : string; var _TargetDate : TDateTime) : boolean;
procedure ClearEmptyLines( _List : TStrings; const _empty : string='');

(*
{ Doc 09.01.2024

https://datatracker.ietf.org/doc/html/rfc9051
https://datatracker.ietf.org/doc/html/rfc9051#name-fetch-command

SEARCH (FROM "mail@granit.com.tr" SINCE "01-Sep-2023" BEFORE "15-Jan-2024")

ALTER TABLE SOCIAL_MEDIA
 ADD IMAP_Server varchar(128),
     IMAP_User varchar(128),
     IMAP_Passwd nvarchar(128),
     IMAP_Port int default 143,
     IMAP_TLS int default 1,
     IMAP_ToMail varchar(128),
     IMAP_RootFolder nvarchar(128) default N'INBOX'
     ;

ALTER TABLE META_Collect
 ADD IMAP_UID int;

ALTER TABLE META_Collect
  ALTER COLUMN Contact_ID varchar(64);

TLS desteði
0    utNoTLSSupport,
1    utUseImplicitTLS, // ssl iohandler req, allways tls
2    utUseRequireTLS, // ssl iohandler req, user command only accepted when in tls
3    utUseExplicitTLS // < user can choose to use tls

}
    IMAP örnekler
    ------------------------------------
    LOGIN "gentegrecrm@granit.com.tr" "þifre"   > Bilgilerle LOGIN olur         > OK, NO, BAD
    CAPABILITY                                  > IMAP sunucu yeteneklerini gösterir
    SELECT "INBOX"                              > INBOX klasörünü seçer
    EXAMINE "INBOX"                             > SELECT gibidir fakat Read-Only açar
    LIST "" *                                   > Klasörleri listeler.
    SEARCH FROM "mail@granit.com.tr"            > Gönderen "mail@granit.com.tr" olanlarýn listesini getirir. * SEARCH 215 216 225
    SEARCH (UNSEEN)                             > Henüz görülmemiþ, okunmamýþ posta listesi
    SEARCH NEW                                  > Okunmamýþ Yeni postalarýn ID biglisini getirir. * 235 EXISTS
    SEARCH (FROM "mail@granit.com.tr" UNSEEN)   > "mail@granit.com.tr" tarafýndan gönderilmiþ ve okunmamýþ postalar
    SEARCH (SENTSINCE "03-Jan-2024")            > 3-Ocak-2024 ten itibaren Arama yapar. * SEARCH 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235
    SINCE "01-Jan-2024" BEFORE "06-Jan-2024"    >
*   SEARCH (FROM "mail@granit.com.tr") UID 236:*
                                                > "mail.granit.com.tr" den gelen UID deðeri 236 ve sonrasý
    SEARCH (FROM "mail@granit.com.tr" SENTSINCE "03-Jan-2024")
                                                > 3-Ocak-2024 tarihinden itibaren "mail@granit.com.tr" tarafýndan gönderilen postalar
                                                 * SEARCH 215 216 225 235
                                                 * 236 EXISTS
                                                > ikinci kez çaðýrýldýðýnda * SEARCH 215 216 225 235 236

    UID SEARCH (FROM "mail@granit.com.tr") 236:*> UID Aramayý sequence(sýra) üzerinden yapar
    UID SEARCH (FROM "mail@granit.com.tr") UID 249:*
                                                > UID Aramayý UID(tekil numara) üzerinden yapar

    UID SEARCH HEADER Message-ID "<MwBykOwQmHkjTT9b0lTDyuMhFkCCKjhm7TuovcylTKg@www.granit.com.tr>"
                                                > * SEARCH 215

    fetch 224,225 RFC822                        > Üstteki SEARCH ile alýnan liste FETCH edilir iletiler alýnýr.
    FETCH 309 (BODY.PEEK[])                     > 309 UID numaralý ePosta "Body" gövdesini alýr
    FETCH 215 (FLAGS BODY[HEADER.FIELDS (DATE FROM MESSAGE-ID)])
    FETCH 215 (FLAGS BODY[HEADER.FIELDS (DATE FROM MESSAGE-ID)] BODY[TEXT])
                                                > * 215 FETCH (FLAGS (\Seen) BODY[HEADER.FIELDS (DATE FROM MESSAGE-ID)] {166}
                                                  Date: Fri, 5 Jan 2024 19:48:24 +0000
                                                  From: "mail@granit.com.tr" <mail@granit.com.tr>
                                                  Message-ID: <MwBykOwQmHkjTT9b0lTDyuMhFkCCKjhm7TuovcylTKg@www.granit.com.tr>

                                                   BODY[TEXT] {250}
                                                  Ýsim - Soyad: Ali ince <br/>E-Mail: ali@granit.com.tr <br/>Cep Tel: 05427478855 <br/>Cinsiyet: Erkek <br/>Þehir: istanbul <br/>Ýlçe: kadýköy <br/>Ülke: Türkiye <br/>Adresiniz: deneme <br/> <br/>Mesajýnýz: deneme mesajýdýr. <br/> <br/>

                                                  )

    FETCH 224,225 (BODY[HEADER.FIELDS(Subject)])
    FETCH 215,216,225 (BODY[TEXT])              > Ýlgili postanýn yalnýzca BODY[TEXT] içeriðini getirir
    STATUS "INBOX" (UIDNEXT MESSAGES)           > STATUS INBOX (MESSAGES 231 UIDNEXT 233) 233 adet mail var 230 tanesi görülmüþ
    UID FETCH 215,216,225 FLAGS                 > OK [PERMANENTFLAGS ()] Read-only mailbox. OK [UIDNEXT 233] Predicted next UID

  ------------------------

*)
implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
uses
    StrUtils
  ;

function ImapDateToDateTime(_ImapDate : string; var _TargetDate : TDateTime) : boolean;
var
  Lst : TStrings;
  NewStr : string;
  FS: TFormatSettings;
begin
  {Fri, 05 Jan 2024 22:48:24 +0300}
   NewStr := _ImapDate;
   NewStr := StringReplace(NewStr,',','',[rfReplaceAll]);
   NewStr := StringReplace(NewStr,' ',#13#10,[rfReplaceAll]);
   Lst := TStringList.Create;
   try
     Lst.Text := NewStr;
    { 0. Fri
      1. 05
      2. Jan
      3. 2024
      4. 22:48:24
      5. +300
     }

     FS := TFormatSettings.Create('en-US');
     // Orijinal 'Fri 05/Jan/2024 22:48:24'
     NewStr := Lst[1]+'/'+                                               // gün
               (IndexText(Lst[2],FS.ShortMonthNames)+1).ToString+'/'+    // ay
               Lst[3]+' '+                                               // yýl
               Lst[4];                                                   // saat
     // Dönüþmüþ '05/1/2024 22:48:24'
     FS.ShortDateFormat := 'dd/mm/yyyy';
     Result := TryStrToDateTime(NewStr, _TargetDate, FS);
   finally
     Lst.Free;
   end;
end;


procedure ClearEmptyLines( _List : TStrings; const _empty : string='');
var
  i : integer;
begin
   Assert(Assigned(_List));
   i := _List.Count-1;
   while i > -1 do
    begin
      if Trim(_List[i]) = _empty then // Yalnýzca boþ stringleri deðil, bazen ')' gibi String de silinmek istenir
       _List.Delete(i);
      Dec(i);
    end;
end;

{ https://www.w3schools.com/tags/ref_urlencode.ASP
  Oðuzhan YAÐMUR
  O%C4%9Fuzhan%20YA%C4%9EMUR
}
function URLDecodeString (_input : string) : string;
begin
  Result := _input;
  Result := StringReplace(Result,#$C4#$B0,'Ý',[rfReplaceAll]);
  Result := StringReplace(Result,#$C4#$B1,'ý',[rfReplaceAll]);
  Result := StringReplace(Result,#$C5#$9E,'Þ',[rfReplaceAll]);
  Result := StringReplace(Result,#$C5#$9F,'þ',[rfReplaceAll]);
  Result := StringReplace(Result,#$C4#$9E,'Ð',[rfReplaceAll]);
  Result := StringReplace(Result,#$C4#$9F,'ð',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$9C,'Ü',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$Bc,'ü',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$87,'Ç',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$A7,'ç',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$96,'Ö',[rfReplaceAll]);
  Result := StringReplace(Result,#$C3#$B6,'ö',[rfReplaceAll]);
end;

function BytesToString(const ABuffer: TIdBytes): string;
var
  lenByte : integer;
begin
  lenByte := Length( ABuffer);
  Setlength(Result , lenByte);
  SetString(Result, PAnsichar(Pointer(ABuffer)), lenByte);
  Result := URLDecodeString(Result);
end;


procedure TIMAPModule.Connect;
begin
  IdIMAP4.UseTLS := TLSSupport;
  IdIMAP4.Username := UserName;
  IdIMAP4.Host := Server;
  if Port >0 then
   IdIMAP4.Port := Port;
  IdIMAP4.Password := Password;
  // IdSSLIOHandler.DefStringEncoding := IndyTextEncoding_UTF8;
  //IdIMAP4.Login;
  try
    IdIMAP4.Connect();
    if RootFolder='' then
      RootFolder := 'INBOX';
    //ExecuteCmd('EXAMINE "'+RootFolder+'"');
    //ExecuteCmd('SELECT "'+RootFolder+'"');
    {
      ExecuteCMD yani (Send) ile yapýlan talepler, doðru sonucu dönse de, IMAP istemcinin statüsünü "Authenticated"
      olarak tuttuðu için doðrudan IMAP "SelectMailBox" tercih edilmeli
    }
    IdIMAP4.SelectMailBox(RootFolder);

  except
    on ExConnect001 : Exception do
     begin
       LogIMAP('ExConnect001 : '+ExConnect001.Message);
       raise Exception.Create('ExConnect001 : '+ExConnect001.Message);
     end;
  end;
end;

procedure TIMAPModule.DataModuleCreate(Sender: TObject);
begin
  fRootFolder := 'INBOX';
end;

procedure TIMAPModule.DataModuleDestroy(Sender: TObject);
begin
  if IdIMAP4.Connected then
    Disconnect;
end;

procedure TIMAPModule.Disconnect;
begin
   if IdIMAP4.Connected then
     IdIMAP4.Disconnect(True);
   Sleep(200);
end;

function TIMAPModule.ExecuteCmd(_cmd: string) : string;
begin
  if Not IdIMAP4.Connected then
    raise Exception.Create(resBaglantiKurulmamis);
  // Sonuç 'OK' veya 'BAD' olabilir.
  LastOutput := '';
  Result := IdIMAP4.SendCmd(_cmd, []);
end;

procedure TIMAPModule.ExtractBody(_source: string; _targetList: TStrings);
var
 msgIndex : integer;
 tmpStr : string;
begin
  _source := StringReplace(_source,'<br/>',#13#10,[rfReplaceAll]);
  _source := StringReplace(_source,'<br />',#13#10,[rfReplaceAll]);

  msgIndex := Pos('Mesajýnýz:', _source);
  if msgIndex>0 then
    begin
      tmpStr := Copy(_source, msgIndex + 10, 4096);
      Delete(_source, msgIndex + 10, 4096);
      tmpStr := TrimLeft( TrimRight( StringReplace(tmpStr, #13#10, ' ', [rfreplaceAll]) ));
      _source := _source + tmpStr;
    end;
  _targetList.Text := _source;
  ClearEmptyLines(_targetList);
end;

procedure TIMAPModule.ExtractMail(_mail: TIdMessage;var aLead: recLead);
var
  BodyStr : string;
  BodyList : TStrings;
  i: Integer;
  Il, Ilce : string;
begin
   {
     WebForm tasarýmý "Erhan Savaþeri" tarafýndan saðlanan bilgiler üzerinden þekillendi.
     Farklý müþterilerin de benzer web sayfasý veya en azýndan benzer ePosta içerikleri göndermleri saðlanmalý.
     Yani ePosa ayýklama esnasýnda "Ýsim - Soyad:" etiketi ve diðer etiketler bire-bir ayný olmalý.
     Etiketlerin ayný olmamasý durumunda aþaðýdaki kodlara ekleme yapýlmalý
   }
   // _mail içeriðini aLead record yapýsýnda aktarýr

  aLead.created_time := DateTimeToStr(_mail.Date);
  BodyStr := _mail.Body.Text;
   Il := '';
   Ilce := '';
  //UNUTMA
  LogIMAP('ExtractMail body : '+BodyStr);
  BodyList := TStringList.Create;
  try
    ExtractBody(BodyStr, BodyList);
    for i := 0 to BodyList.Count-1 do
     begin
       if aLead.FULL_NAME='' then
         ParseLine('Ýsim - Soyad:',BodyList[i], aLead.FULL_NAME);

       if aLead.EMAIL='' then
         ParseLine('E-Mail:',BodyList[i], aLead.EMAIL);

       if aLead.PHONE='' then
         ParseLine('Cep Tel:',BodyList[i], aLead.PHONE);

       if aLead.GENDER='' then
         ParseLine('Cinsiyet:',BodyList[i], aLead.GENDER);

       if Il='' then
         ParseLine('Þehir:',BodyList[i], Il);

       if Ilce='' then
         ParseLine('Ýlçe:',BodyList[i], Ilce);

       if aLead.COUNTRY='' then
         ParseLine('Ülke:',BodyList[i], aLead.COUNTRY);

       if aLead.STREET_ADDRESS='' then
         ParseLine('Adresiniz:',BodyList[i], aLead.STREET_ADDRESS);

       if aLead.NOT1='' then
         ParseLine('Mesajýnýz:',BodyList[i], aLead.NOT1);

     end;

    Il := FirstUpperCase(Il);
    Ilce := FirstUppercase(Ilce);
    aLead.COUNTRY := FirstUppercase(aLead.COUNTRY);

    if (UpperCase(aLead.GENDER[1])='M') or (UpperCase(aLead.GENDER[1])='E') then
      aLead.GENDER := 'E';

    if (UpperCase(aLead.GENDER[1])='F') or (UpperCase(aLead.GENDER[1])='K') then
      aLead.GENDER := 'K';

    //if (Ilce<>'') then
    //  aLead.CITY := Il + '/'+Ilce;
    aLead.CITY := Il;
    aLead.TOWN := Ilce;


  finally
    BodyList.Free;
  end;

end;

function TIMAPModule.GetConnected: boolean;
begin
   Result := IdIMAP4.Connected;
end;

function TIMAPModule.GetMail(_mailID: string):  TIdMessage;
{var
  execStr : string;
}
begin

  Result := TIdMessage.Create(Self);
  Result.Clear;
  try
    IdIMAP4.UIDRetrieve(_mailId, Result);
    LogIMAP('GetMail mailID = '+_mailID);
  except
    on ExGetMail001 : Exception do
     begin
       LogIMAP('ExGetMail001 : '+ExGetMail001.Message);
       raise Exception.Create('ExGetMail001 : '+ExGetMail001.Message);
     end;
  end;
  {
  execStr := ExecuteCmd('FETCH '+_mailID+' (FLAGS BODY[HEADER.FIELDS (DATE FROM MESSAGE-ID SUBJECT)] BODY[TEXT])');
  if execStr='OK' then
   begin
      Result := LastOutput;
      IdIMAP4.UIDRetrieve(_mailId, msg);
   end;
   }
end;

function TIMAPModule.GetPassword: string;
begin
   Result := IdIMAP4.Password;
end;

function TIMAPModule.GetPort: Word;
begin
   Result := IdIMAP4.Port;
end;

function TIMAPModule.GetServer: string;
begin
  Result := IdIMAP4.Host;
end;

function TIMAPModule.GetTLS: TIdUseTLS;
begin
  Result := IdIMAP4.UseTLS;
end;

function TIMAPModule.GetUserName: string;
begin
  Result := IdIMAP4.Username;
end;

procedure TIMAPModule.IdConnectionIntercept1Receive(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
begin
  //
  LastOutput := LastOutput + BytesToString(ABuffer);
end;

procedure TIMAPModule.IdConnectionIntercept1Send(ASender: TIdConnectionIntercept; var ABuffer: TIdBytes);
begin
   //LogSending.Lines.Add(BytesToString(ABuffer));
end;

function TIMAPModule.ParseLine(_tag, _source: string; var _target : string): integer;
begin
   if Pos(_tag, _source)=1 then
    begin
       _target := TrimRight( TrimLeft( Copy(_source,Length(_tag)+1,4096) ));
       Result :=1;
    end
     else
      Result := 0;
end;

function TIMAPModule.SearchListToFetch(_searchList: TStrings): string;
var
 i : integer;
begin
  Result := '';
  for i := 0 to _searchList.Count-1 do
   begin
     Result := Result + _searchList[i];
     if i<_searchList.Count-1 then
       Result := Result + ',';
   end;
end;

procedure TIMAPModule.Search(_SearchStr: string; _outputList: TStrings);
begin
  if not IdIMAP4.Connected then
    raise Exception.Create(resBaglantiKurulmamis);
  raise Exception.Create('IdIMPA4 üzerinden arama yapýlmýyor!');
  {
  srcInfo.FieldName := '';
  IdIMAP4.UIDSearchMailBox( [srcInfo] );
  }
end;

procedure TIMAPModule.SearchExt(_SearchStr: string; _OutputList: TStrings);
var
  testRes : string;
  Output  : string;
begin

  try
   try
     testRes := ExecuteCmd(_SearchStr);
     Sleep(30);
     if testRes = 'OK' then
      begin
        Output := LastOutput;
        if Pos('* SEARCH'#13#10,Output)=1 then
         begin
                { // böyle bir output gelmiþ olabilir yani, Hiç bir sonuç dönmedi anlamý taþýr
                * SEARCH
                C4 OK Search completed (0.001 + 0.000 secs).
                }
           Output := '';
         end
         else
         begin
            Delete(Output, 1, 9{* SEARCH });
            Delete(Output, Pos(#13,Output),4096);
            Output := StringReplace(Output,' ',#13#10, [rfReplaceAll]);
         end;
      end;
   except
     on ExIMAPsearch001 : Exception do
      begin
        Output := '';
        raise Exception.Create('ExIMASearchExt001 : '+ExIMAPsearch001.Message);
      end;
   end;
  finally
     _OutputList.Text := Output;
  end;
end;

function TIMAPModule.SearchListToFetch(_searchList: String): string;
var
 tmpList : TStrings;
begin
  tmpList := TStringList.Create;
  try
    tmpList.Delimiter:= ' ';
    tmpList.DelimitedText := _searchList;

    Result := SearchListToFetch(tmpList);
  finally
    tmpList.Free;
  end;
end;

procedure TIMAPModule.SetConnected(const Value: boolean);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
   IdIMAP4.Connect();
end;

procedure TIMAPModule.SetPassword(const Value: string);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
  IdIMAP4.Password := Value;
end;

procedure TIMAPModule.SetPort(const Value: Word);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
   IdIMAP4.Port := Value;
end;

procedure TIMAPModule.SetServer(const Value: string);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
  IdIMAP4.Host := Value;
end;

procedure TIMAPModule.SetTls(const Value: TIdUseTLS);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
  IdIMAP4.UseTLS := Value;
end;

procedure TIMAPModule.SetUserName(const Value: string);
begin
  if IdIMAP4.Connected then
    raise Exception.Create(resAktifBilesen_Degistirilemez);
  IdIMAP4.Username := Value;
end;



function TIMAPModule.YeniPostaID(_firstID: integer; _TargetList: TStrings): string;
begin
   // ExecuteCmd('SEARCH)
end;

procedure LogIMAP( _statusMessage : string);
begin
  if Assigned(IMAPLoggerMethod) then
    IMAPLoggerMethod(_statusMessage);
end;


end.
