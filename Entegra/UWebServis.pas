unit UWebServis;

interface

Uses Windows,SysUtils,Classes,JvJCLUtils,(*IndySockTransport,*)Rio, SOAPHTTPClient,
  InvokeRegistry,SOAPHTTPTrans,OPConvert, WinInet,XSBuiltIns,uTablo,IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, ECXMLParser, UFastRap, FetaKurulusSiniflari,
  IdHTTP, fetautil, UGenSifre, prjconst;

function SQLKomut(var FXml : TECXMLParser; Komut:string; islemNo:smallint):string;
procedure SQLServis;
  //Iptal Kodu (Doktor iptal ederse 0, Hasta iptal ederse veya gerceklesmezse 1)
function MemoryStreamToString(M: TMemoryStream): String;

var
  KurumKodu: string;
  GönderilecekVeri : TMemoryStream;
  PostData : TMemoryStream;
  IdHTTP1 : THTTPRIO;
  XmlListe : TECXMLParser;
  a : TXMLItem;
  //s : string;
  Ad,ID,Vers:String;


implementation
  function MemoryStreamToString(M: TMemoryStream): String;
var
  NewCapacity: Longint;
begin
   SetString(Result, PAnsiChar(M.Memory), M.Size)
end;


function SQLKomut(var FXml : TECXMLParser; Komut:string; islemNo:smallint):string;
  var
    GonderilecekString ,GelenCevap : String;
    DonenDeger:TStringlist;
    ResponseStream: TMemoryStream;
    InputStringList : TStringList;
    IdHttp1 : TIDHTTP;
    XMLString : string;
    xmlstream : TStringStream;

begin
    IdHttp1 :=   TIDHTTP.Create(nil);

    if ProxyAdres<>'' then begin
       IdHTTP1.ProxyParams.ProxyServer:=ProxyAdres;
       IdHTTP1.ProxyParams.ProxyPort:=StrToIntDef(ProxyPort,0);
    end;
    IdHttp1.HTTPOptions := [];



    DonenDeger :=   TStringList.Create();
    ResponseStream := TMemoryStream.Create;
    InputStringList := TStringList.Create;



    XMLString :=
     // '<?xml version=“1.0” encoding=“utf-8” ?>                  '+
      ' <SqlCommit> '+
      '  <SQL>'+Komut+'</SQL>'+
      ' <TURU>'+IntToStr(islemNo)+'</TURU> '+
      ' </SqlCommit> ';


    InputStringList.Add(XMLString);
    try
       IdHttp1.Request.Accept := '*/*';
       //IdHttp1.Request.ContentType := 'text/xml; charset=utf-8';
       IdHttp1.Request.ContentType := 'text/xml';
       IdHTTP1.Post('http://'+Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com')+'/GentegeSQLCOMMIT/SQLCommit.asmx/SQLCommitApply', InputStringList, ResponseStream);
        if (Assigned(FXml)) then
            FreeAndNil(FXml);
        FXml:= TECXMLParser.Create(nil);
        ResponseStream.Position :=0;
        FXml.LoadFromStream(ResponseStream,TEncoding.UTF8);
        GelenCevap:= IdHttp1.ResponseText;
      except
            on E: Exception do
            GelenCevap:=  E.Message;
      end;
      ResponseStream.Free;
      InputStringList.Free;
end;

procedure SQLServis;
var
   Komut : String;
begin
   Komut := Sifre( '   select ICERIK from HELP where MODULID=1112 ');
//   Komut := Sifre( '   select top 1 ID from rehber where FIRMA like ''A%'' ORDER BY 1 DESC');
   SQLKomut(XmlListe,Komut,2);
//   XmlListe.SaveToFile('D:\Raporium\komutlar.txt');
   for a in XmlListe.Root do begin
      //a := XmlListe.Root.NamedItem['Xml'];
      if a.Count > 0 then begin
         komut := a[0].Name;
         komut := a[0].Text;
      end
      else
         break;
    end;
end;

end.

