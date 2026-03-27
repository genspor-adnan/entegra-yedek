unit UGoogleSyncBus;

interface
uses InvokeRegistry, Rio,UTablo, SOAPHTTPClient,XSBuiltIns,DateUtils,SysUtils,
  System.Types;
  //  GenGoogleSyncService,
procedure GoogleRIOYenile;
//function GoogleOlayKaydet(LoginBilgi: CalendarLogin2; OlayDetay: CalendarEvent2 ) :string;
//function OlayKaydet(TakvimID:string;KullaniciAdi:string;Sifre:string;Baslik,Lokasyon,Aciklama:string;Bas,Bit:TDatetime;GoogleP12Dosya: TByteDynArray):string;
//function OlaySil(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayID:string):Boolean;
//function OlayDegistir(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayId:string;Baslik,Aciklama:string):string;
//function OlayGetir(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayId:string):CalendarEvent;
function GoogleLoginBilgi(takvimid,takvimmailadr: string; securityfile: TByteDynArray): GenGoogleSyncService.CalendarLogin;
function GoogleOlayBilgi(BolumId, OlayId, aciklama, Konum, Hasta, Tel, Baslik : string; Tarih: TDatetime; sure :Integer): GenGoogleSyncService.CalendarEvent;
implementation


procedure GoogleRIOYenile;
begin
  if HTTPRioGoogleSync = nil then
    HTTPRioGoogleSync:= THTTPRIO.Create(Tablo);
  GoogleSynServis:= GetIGenGoogleSyncService(False,GenGoogleEndPoint,HTTPRioGoogleSync);
end;

function GoogleOlayKaydet(LoginBilgi: CalendarLogin2; OlayDetay: CalendarEvent2 ) :string;
begin
   GoogleRIOYenile;
   Result:= GoogleSynServis.InsertCalendarEvent(LoginBilgi,OlayDetay )
end;

function GoogleLoginBilgi(takvimid,takvimmailadr: string; securityfile: TByteDynArray): GenGoogleSyncService.CalendarLogin;
begin
    Result:= GenGoogleSyncService.CalendarLogin.Create;
    Result.CalendarID:= takvimid;
    Result.ServiceAccountMailAddress:= takvimmailadr;
    Result.P12SecurityFile:= securityfile;
end;
function GoogleOlayBilgi(BolumId, OlayId, aciklama, Konum, Hasta, Tel, Baslik : string; Tarih: TDatetime; sure :Integer): GenGoogleSyncService.CalendarEvent;
begin
   Result:= GenGoogleSyncService.CalendarEvent.Create;
   Result.Description:= aciklama;
   Result.Id:= OlayId;
   Result.Location:= Konum;
   Result.PatientName:= Hasta;
   Result.PatientPhone:= Tel;
   Result.SectionId:= BolumId;
   Result.StartDate:= TXSDateTime.Create;
   Result.StartDate.AsDateTime:= Tarih;
   Result.Period:= sure;
   Result.Summary:= Hasta;
end;

//function OlayKaydet(TakvimID:string;KullaniciAdi:string;Sifre:string;Baslik,Lokasyon,Aciklama:string;Bas,Bit:TDatetime;GoogleP12Dosya: TByteDynArray):string;
//var
//  Login : GenGoogleSyncService.CalendarLogin;
//  Olay  : CalendarEvent;
//  Http  : THTTPRIO;
//  Servis : IGenGoogleSyncService;
//begin
////Http := THTTPRIO.Create(nil);
////Servis := GetIGenGoogleSyncService(False,GenGoogleEndPoint,Http);
////Login := CalendarLogin.Create;
////Olay  := CalendarEvent.Create;
////Login.CalendarID := TakvimID;
////Login.ServiceAccountMailAddress := 'adnan odabaþý';//KullaniciAdi;
////Login.UserPassword := 'odabasi';//Sifre;
////
////Olay.Title := Baslik;
////Olay.Content := Aciklama;
////Olay.Locations := Lokasyon;
////Olay.StartDate := TXSDateTime.Create;
////Olay.StartDate.AsDateTime := bas;
//////Olay.StartDate.AsDateTime := IncMinute(DpBas.Date , Str2Dakika(TpBas.Text));
////Olay.EndDate := TXSDateTime.Create;
////Olay.EndDate.AsDateTime := bit;
//////Olay.EndDate.AsDateTime := IncMinute(DpBit.Date , Str2Dakika(TpBit.Text));
//// try
////   result := Servis.InsertCalendarEvent(login,Olay);
//// except
////    on e: exception do begin
////      Abort;
////    end;
//// end;
//end;
//function OlaySil(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayID:string):Boolean;
////  var
////  Login : CalendarLogin;
////  Olay  : CalendarEntry;
////  Http  : THTTPRIO;
////  Servis : IGenGoogleSyncService;
//begin
////  Http := THTTPRIO.Create(nil);
////  Servis := GetIGenGoogleSyncService(False,GenGoogleEndPoint,Http);
////  Login := CalendarLogin.Create;
////  Login.CalendarID := TakvimID;
////  Login.UserName := KullaniciAdi;
////  Login.UserPassword := (Sifre);
////  try
////   result := Servis.DeleteCalendarEvent(Login,OlayID);
////  except
////    on e: exception do begin
////      Abort;
////    end;
////  end;
//end;
//
//function OlayDegistir(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayId:string;Baslik,Aciklama:string):string;
////  var
////  Login : CalendarLogin;
////  Olay  : CalendarEntry;
////  Http  : THTTPRIO;
////  Servis : IGenGoogleSyncService;
//begin
////  Http := THTTPRIO.Create(nil);
////  Servis := GetIGenGoogleSyncService(False,GenGoogleEndPoint,Http);
////  Login := CalendarLogin.Create;
////  Login.CalendarID := TakvimID;
////  Login.UserName := KullaniciAdi;
////  Login.UserPassword := Sifre;
////  try
////   result := Servis.UpdateCalendarEvent(Login,OlayID,Baslik,Aciklama);
////  except
////    on e: exception do begin
////      Abort;
////    end;
////  end;
//end;
//
//function OlayGetir(TakvimID:string;KullaniciAdi:string;Sifre:String;OlayId:string):CalendarEntry;
////  var
////  Login : CalendarLogin;
////  Olay  : CalendarEntry;
////  Http  : THTTPRIO;
////  Servis : IGenGoogleSyncService;
//begin
////  Http := THTTPRIO.Create(nil);
////  Servis := GetIGenGoogleSyncService(False,GenGoogleEndPoint,Http);
////  Login := CalendarLogin.Create;
////  Login.CalendarID := TakvimID;
////  Login.UserName := KullaniciAdi;
////  Login.UserPassword := Sifre;
////  try
////   result := Servis.GetCalendarEvent(Login,OlayID);
////  except
////    on e: exception do begin
////      Abort;
////    end;
////  end;
//
//end;




end.
