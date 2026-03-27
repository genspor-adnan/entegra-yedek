unit URaporServis;

interface

Uses Windows,SysUtils,Classes,JvJCLUtils,IndySockTransport,Rio, SOAPHTTPClient,
  InvokeRegistry,SOAPHTTPTrans,OPConvert, WinInet,XSBuiltIns,uTablo,IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, ECXMLParser, UFastRap, FetaKurulusSiniflari,
  IdHTTP, fetautil;

  //Const
  //RaporiumUrl = 'http://genlisans.genyazilim.com/Raporium/Raporium.asmx';
  //http://genlisans.genyazilim.com/Raporium/Raporium.asmx

function DokumanSorgula(var FXml : TECXMLParser; versiyon:string; dokumid, islemNo:smallint):string;
procedure RaporUpdate;
  //Iptal Kodu (Doktor iptal ederse 0, Hasta iptal ederse veya gerceklesmezse 1)
function MemoryStreamToString(M: TMemoryStream): String;

var
  KurumKodu: string;
  GönderilecekVeri : TMemoryStream;
  PostData : TMemoryStream;
  IdHTTP1 : THTTPRIO;
  XmlListe, XmlRapor : TECXMLParser;
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


  function DokumanSorgula(var FXml : TECXMLParser; versiyon:string; dokumid, islemNo:smallint):string;
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
  //IdHttp1.ProxyParams.ProxyPort := 8888;
  //IdHttp1.ProxyParams.ProxyServer:='localhost';
  IdHttp1.HTTPOptions := [];
  DonenDeger :=   TStringList.Create();
  ResponseStream := TMemoryStream.Create;
  InputStringList := TStringList.Create;



  XMLString :=
   // '<?xml version=“1.0” encoding=“utf-8” ?>                  '+
    '  <Raporium>                                          '+
    '    <versiyon>'+Versiyon+'</versiyon>      '+
    '    <dokumid>'+IntToStr(dokumid)+'</dokumid>             '+
    '    <islemNo>'+IntToStr(islemNo)+'</islemNo>             '+
    '  </Raporium>    ';
{XMLString := '<Raporium>   '+
'<versiyon>0</versiyon>   '+
'<dokumid>48</dokumid>      '+
'<islemNo>1</islemNo>      '+
'</Raporium>          ';   }

InputStringList.Add(XMLString);
    try
     IdHttp1.Request.Accept := '*/*';
     IdHttp1.Request.ContentType := 'text/xml; charset=utf-8';
      //IdHTTP1.Post('http://'+GenYazilimIPAdress+':8090/Gentegre/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);
      //IdHTTP1.Post('http://genlisans.genyazilim.com/Gentegredokum/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);

      //Result:=MemoryStreamToString(ResponseStream);
      //GelenCevap:= IdHttp1.ResponseText;

      IdHTTP1.Post('http://genlisans.genyazilim.com:8090/GentegreDokuman/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);

      //XMLString:=MemoryStreamToString(ResponseStream);
      //xmlstream:= TStringStream.Create(XMLString,TEncoding.UTF8);
      if (Assigned(FXml)) then
      FreeAndNil(FXml);
      FXml:= TECXMLParser.Create(nil);
      ResponseStream.Position :=0;
      FXml.LoadFromStream(ResponseStream,TEncoding.UTF8);

//a := XmlListe.Root.NamedItem['DOKUMLER1'];
//s:= a[0].Text;

//XmlListe.SaveToFile('D:\GenDokuman\denemeliste2.frd');
     // XML2Rapor(XmlListe,'');

      //Result:= XMLString;

      GelenCevap:= IdHttp1.ResponseText;
    except
          on E: Exception do
          GelenCevap:=  E.Message;
    end;
    ResponseStream.Free;
    InputStringList.Free;
  end;

  procedure RaporUpdate;
  var i:smallint;
      Ekle : Boolean;
  begin        //http://genlisans.genyazilim.com:8090/Gentegrelisans/GentegreLisans.asmx/LisansCevirUpdate
      //DokumanSorgula('1.1', StrToDateTime('01/01/2013'), 379, 4)
      //Önce bu verssiyondan düşük rapor listesini alalım
      DokumanSorgula(XmlListe,'0',0,2);
      for a in XmlListe.Root do begin
        ad := A.Text;
        i:=pos(',',Ad);
        ID:=copy(Ad,1,i-1);
        Vers := copy(Ad,i+1, revpos(',',Ad)-i-1);
        Tablo.TablodanSorguAc(1,'select ID, VERSIYON from DOKUMLER where RAPORNO='+ID+' and MODUL>''-''');//bu döküm varmı
        if (Tablo.Query1.RecordCount>0) then begin
           if Tablo.Query1.Fields[1].AsString=Vers then
              Ekle := False
           else begin
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsString]);
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsString]);
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsString]);
              Ekle := True;
           end;
        end
        else
          Ekle := True;

        if Ekle then begin
           DokumanSorgula(XmlRapor,'0',StrToInt(ID),1);
           //XmlRapor.SaveToFile('D:\GenDokuman\deneme'+ID+'.frd');
           XML2Rapor(XmlRapor);
        end;
      end;
  end;

end.



