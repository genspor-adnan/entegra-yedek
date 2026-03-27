unit UMailGonderim;

interface
uses
  SysUtils,Classes,Generics.Collections,Variants,
  UTablo,UGenNotificationUtils,UBinarySave,FetaKurulusSiniflari;

function PostayiGonder(Baslik,Icerik:string; EpostaAlicilar,EPostaAlicilarCC:TList<TEpostaAlici>; EkliDosyalar:TList<string>; Yer,YerID,RehberID:integer):string;
function ServisPostaGonder(ServisID,HareketID:integer;IcMail:boolean=True):string;




implementation


function PostayiGonder(Baslik,Icerik:string; EpostaAlicilar,EPostaAlicilarCC:TList<TEpostaAlici>; EkliDosyalar:TList<string>; Yer,YerID,RehberID:integer):string;
var
   Body : TStringStream;
   DosyaAdi: String;
begin
  Body := TStringStream.Create();
  Body.WriteString(Icerik);
  DosyaAdi := GetEnvironmentVariable('Temp')+'\Temp-'+IntToStr(Yer)+'-'+IntToStr(YerID)+'-'+IntToStr(RehberID)+'.html';
  Body.SaveToFile(DosyaAdi);
  try
    Result := EpostaGonderRapor(
                    EPostaHesapBilgileriniGetir(EpostaHesapID),
                    Baslik, DosyaAdi, EkliDosyalar, EPostaAlicilar, EPostaAlicilarCC,
                    Tablo.IdSMTP1, Tablo.iohSSLTLS,
                    Yer,IntToStr(YerID),RehberID).SonucMesaji;
  finally
    FreeAndNil(Body);
  end;
end;

function ServisPostaGonder(ServisID,HareketID:integer;IcMail:boolean=True):string;
var
   Konu, KimeAdr,BilgiAdr, AtacDosya, RaporAdi, SonucMesaj, DosyaAdi,s, Trh : string;
   EpostaAlicilar, EPostaAlicilarCC : TList<TEpostaAlici>;
   gmail : dmailadresleri;
   BodyStr,DetayStr : string;
   Body : TStringStream;
   EkDosya:TList<string>;
   YorumEkleyen : integer;

begin
  EPostaAlicilar := TList<TEpostaAlici>.Create;
  EPostaAlicilarCC := TList<TEpostaAlici>.Create;
  EkDosya := TList<string>.Create;
  Tablo.TablodanSorguAc(1,'select *,EKIPMANAD=case when S.DEMIRBAS=1 then (select DEMIRBASADI from DEMIRBAS D where D.ID=S.EKIPMANID) else (select AD from EKIPMANLAR E  where E.ID=S.EKIPMANID) end from SERVIS S where ID='+IntToStr(ServisID));
  Tablo.TablodanSorguAc(2,'select * from SERVISHAREKET where ID='+IntToStr(HareketID));
  Tablo.TablodanSorguAc(3,'select SB.ID,SERVISID,SB.SERVISLISTEID, KOD = cast(SB.SERVISTUR as varchar(5))+''.''+(select KOD from SERVISLISTE SL where SL.ID=SB.SERVISLISTEID), '+
                          'GRUP=(select top 1 ANAHTAR from GENINI G WHERE BOLUM=-3015 and DEGER=SB.SERVISTUR), '+
                          'AD=(select AD from SERVISLISTE SL where SL.ID=SB.SERVISLISTEID), '+
                          'SB.ACIKLAMA, SB.COZUM ,SB.USTID, SB.SNO '+
                          'from SERVISBILGI SB '+
                          'where SB.SERVISTUR <>200 and SERVISID='+IntToStr(ServisID));

  if (IcMail)and(StrToIntDef(Tablo.Query2.FieldByName('UYARITURU').AsString,0)>0) then begin//personel
    Tablo.TablodanSorguAc(0,'select * from MAILSABLON where MODULID=83 and ID='+Tablo.Query2.FieldByName('UYARITURU').AsString);
    KimeAdr := Tablo.MailAdresiBul(1,Tablo.Query2.FieldByName('PERSONEL').AsInteger);
    if KimeAdr='' then
       Exit
    else
       TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query2.FieldByName('PERSONEL').AsInteger)+','+KimeAdr, EPostaAlicilar);
  end else if not(IcMail)and(StrToIntDef(Tablo.Query2.FieldByName('DISUYARITURU').AsString,0)>0) then begin //ilgili yada cari
    Tablo.TablodanSorguAc(0,'select * from MAILSABLON where MODULID=83 and ID='+Tablo.Query2.FieldByName('DISUYARITURU').AsString);
    if StrToIntDef(Tablo.Query1.FieldByName('MUS_ILGILI').AsString,0) > 0 then begin//ilgili seçilmiş mi
      KimeAdr := Tablo.MailAdresiBul(2,Tablo.Query1.FieldByName('MUS_ILGILI').AsInteger);
      if KimeAdr<>'' then
        TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',Tablo.Query1.FieldByName('MUS_ILGILI').AsInteger)+','+KimeAdr, EPostaAlicilar);
    end;
    if KimeAdr='' then  begin //ilgilide bişi yoksa carinin eposta adresine bakıcaz
      KimeAdr := Tablo.MailAdresiBul(1,Tablo.Query1.FieldByName('REHBERID').AsInteger);
      if KimeAdr<>'' then
        TEpostaAlici.ListeyeYukle(Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query1.FieldByName('REHBERID').AsInteger)+','+KimeAdr, EPostaAlicilar)
      else
        Exit;
    end;
  end else
    Exit;
  if Tablo.Query0.RecordCount<1 then
    Exit;
  BodyStr := Tablo.Query0.FieldByName('ICERIK').AsString;
  Konu := Tablo.Query0.FieldByName('KONU').AsString;
  if IcMail then begin//iç personel
    Konu := StringReplace(Konu,'@@KONU@@','Servis Atama(No:'+Tablo.Query1.FieldByName('SERVISNO').AsString+')',[rfReplaceAll]);
    BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query2.FieldByName('PERSONEL').AsInteger),[rfReplaceAll]);
  end else if not(IcMail) then begin //dış firma
    Konu := StringReplace(Konu,'@@KONU@@','Servis Bilgilendirme('+Tablo.Query1.FieldByName('KONUSU').AsString+')',[rfReplaceAll]);
    if StrToIntDef(Tablo.Query1.FieldByName('MUS_ILGILI').AsString,0) > 0 then
      BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD',Tablo.Query1.FieldByName('MUS_ILGILI').AsInteger),[rfReplaceAll])
    else
      BodyStr := StringReplace(BodyStr,'@@ADSOYAD@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query1.FieldByName('REHBERID').AsInteger),[rfReplaceAll]);
  end;
  BodyStr := StringReplace(BodyStr,'@@FIRMA@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query1.FieldByName('REHBERID').AsInteger),[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@URUN@@',Tablo.Query1.FieldByName('EKIPMANAD').AsString+' - '+Tablo.Query1.FieldByName('SERINO').AsString,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@TUR@@',Tablo.GENINI.AnahtarGetir(-3002,Tablo.Query1.FieldByName('KABUL_SEKLI').AsInteger,-1),[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@PERSONEL@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query2.FieldByName('PERSONEL').AsInteger),[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@EKLEYEN@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query2.FieldByName('EKLEYEN').AsInteger),[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@MUS_ILGILI@@',Tablo.AciklamaGetir('REHBER','FIRMA',Tablo.Query1.FieldByName('MUS_ILGILI').AsInteger),[rfReplaceAll]);
  if Tablo.Query1.FieldByName('MUS_ILGILI').AsString <> '' then begin
    tablo.TablodanSorguAc(9, 'select TOKEN from KULLANICI where REHBERID='+Tablo.Query1.FieldByName('MUS_ILGILI').AsString);
    if Tablo.Query9.Fields[0].AsString<>'' then
       BodyStr := StringReplace(BodyStr,'@@TOKEN@@',Tablo.Query9.Fields[0].AsString,[rfReplaceAll]);
  end;
  BodyStr := StringReplace(BodyStr,'@@SERVISID@@',Tablo.Query1.FieldByName('ID').AsString,[rfReplaceAll]);
  BodyStr := StringReplace(BodyStr,'@@ILGILIID@@',Tablo.Query1.FieldByName('MUS_ILGILI').AsString,[rfReplaceAll]);

  if Tablo.Query1.FieldByName('ACIL').AsBoolean then
    DetayStr := DetayStr + '<b> ACİL! </b> '+'<br/>';
  if Tablo.Query1.FieldByName('ONEMLI').AsBoolean then
    DetayStr := DetayStr + '<b> Önemli! </b> '+'<br/>';
  if Tablo.Query1.FieldByName('DISSERVIS').AsBoolean then
    DetayStr := DetayStr + ' Dış Servis  '+'<br/>';

  DetayStr := DetayStr + '<b>  Konusu : </b> '+Tablo.Query1.FieldByName('KONUSU').AsString+'<br/>';
  DetayStr := DetayStr + '<b>  Durum : </b> '+VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'select ANAHTAR from GENINI where BOLUM=-3007 and DEGER='+Tablo.Query2.FieldByName('DURUM').AsString+' and DIL=-1',[],[],True))+'<br/>';

  if Tablo.Query2.FieldByName('ACIKLAMA').AsString <> '' then
    DetayStr := DetayStr + '<b>  Not : </b> '+ Tablo.Query2.FieldByName('ACIKLAMA').AsString+'<br/>';
  if Tablo.Query3.RecordCount>0 then begin
    DetayStr := DetayStr + ' <br/> <b>  GENEL: </b> <br/>';
    Tablo.Query3.First;
    while not Tablo.Query3.Eof do begin
      DetayStr := DetayStr + '<b> '+Tablo.Query3.FieldByName('KOD').AsString+' - '+Tablo.Query3.FieldByName('GRUP').AsString+' - '+Tablo.Query3.FieldByName('AD').AsString+'</b> '+'<br/>';
      if Tablo.Query3.FieldByName('ACIKLAMA').AsString <> '' then
        DetayStr := DetayStr + '<b> Açıklama : </b><i>'+Tablo.Query3.FieldByName('ACIKLAMA').AsString+'</i>'+'<br/>';
      if Tablo.Query3.FieldByName('COZUM').AsString <> '' then
        DetayStr := DetayStr + '<b> Çözüm    : </b><i>'+Tablo.Query3.FieldByName('COZUM').AsString+'</i>'+'<br/>';
      Tablo.Query3.Next;
    end;
  end;

  BodyStr := StringReplace(BodyStr,'@@DETAY@@',DetayStr,[rfReplaceAll]);
  EkDosya := TList<String>.Create;
  //DosyalarEkle; //bu bölüm servis için kullanılmayacak.
  Body := TStringStream.Create();
  Body.WriteString(BodyStr);
  DosyaAdi := GetEnvironmentVariable('Temp')+'\Temp'+Tablo.Query2.FieldByName('ID').AsString+'.html';
  Body.SaveToFile(DosyaAdi);
  try
    SonucMesaj := PostayiGonder(Konu,BodyStr,EPostaAlicilar,EPostaAlicilarCC,EkDosya,TabNo_SERVIS,
                                Tablo.Query1.FieldByName('ID').AsInteger,
                                Tablo.Query1.FieldByName('REHBERID').AsInteger);
  finally
    FreeAndNil(EPostaAlicilar);
    FreeAndNil(EPostaAlicilarCC);
    FreeAndNil(EkDosya);
  end;
end;

end.



