unit UParaBilgi;    //AYDİNOZBEY@HOTMAIL

interface

function DrKod_Getir(Kodu, DrKod : String): String ;
procedure Iskonto_Getir(Kr, Kodu : String; var Fiyat : String; var Isk : Real;var IskMik:Currency);
procedure Kampanya_Isk_Getir(Kr, Kodu : String; var Isk_Goster:String; var Isk : Real;var IskMik:Currency);
procedure ParaBilgiGetir(Kod, Tur : String; var Ad, Dr,Birim, OzelKod,ButceKodu, MuhKodu, Grup, Sor: String; Tarih : TDateTime; var KDV :Integer; var Isk : Real; var Birimfiyat:Currency; Kurum,KDVDurum:String;UcretSor:Boolean);
procedure KatkiBilgiGetir(Kod, Tur : String; var Ad, Dr,Birim, OzelKod, ButceKodu, MuhKodu, Grup: String; Tarih : TDateTime; var KDV :Integer; var Isk : Real; var Birimfiyat :Currency; Kurum, KDVDurum:String;UcretSor:Boolean);
function DoktorPayi_Getir(Kodu, DrKodu, Tur,Birim, Gece, Belge, Kurum : String; Adet, kdv : Real; BirFiyatAdet, Tutar : Currency;DrSec:SmallInt;var Sonuc:SmallInt):Currency;
function DoktorPayiKDVDusur(DNO, GNO, KOD : String; DOKPAYI : Currency; KDV:SmallInt): Currency;

var
SonKampKod : String[20];

implementation
Uses UTablo, Sysutils, UMesaj, FetaUtil, UUcrAra, DB,WinTypes,Forms, UListe, Controls;

var st : String;

function DoktorPayi_Getir(Kodu, DrKodu, Tur, Birim, Gece, Belge, Kurum : String; Adet,kdv : Real; BirFiyatAdet, Tutar : Currency;DrSec:SmallInt;var Sonuc:SmallInt):Currency;
var  carp : real;
     DP:Currency;
     DrSecimi,KurumGrubu : String;
begin
   DrSecimi := ' and (isnull(DRSEC,'''')='''' or isnull(DRSEC,'''')=';
   if DrSec = 1 then
      DrSecimi := DrSecimi+'''DR'')'
   else
      DrSecimi := DrSecimi+'''DR2'')';
   Sonuc:=0;
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select DURUM, GRUBU From KURUM Where Kurum='''+Kurum+'''';
   Tablo.Query3.Open;
   if Tablo.Query3.Fields[0].AsString='Resmi' then begin
      DoktorPayi_Getir:=0;
      exit;
   end;
   KurumGrubu := Tablo.Query3.Fields[1].AsString;
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text :=' Select SIRASI = CASE WHEN KOD=''*TÜM*'' THEN 1 ELSE 2 END,KOD, YUZDE, ISKONTODAN, KDV, KURUM,'+
                           ' GUNGECE,TUR,isnull(FIX,0) as FIX,ALT, BELGE From DOKYUZDE Where DOKTORKOD = '''+DrKodu+''' ';
   if KurumKontrolu then Tablo.Query3.SQL.Add(' and (KURUM IS NULL OR KURUM ='''' OR KURUM='''+Kurum+''')');
   if KurumGrubuKontrolu then Tablo.Query3.SQL.Add(' and (KURUMGRUBU IS NULL OR KURUMGRUBU ='''' OR KURUMGRUBU='''+KurumGrubu+''')');
   if TurKontrolu then Tablo.Query3.SQL.Add(' and (TUR IS NULL OR TUR='''' OR TUR='''+Tur+''')');
   if BelgeKontrolu then Tablo.Query3.SQL.Add(' and (BELGE IS NULL OR BELGE='''' OR BELGE='''+Belge+''')');
   if GunGeceKontrolu then Tablo.Query3.SQL.Add(' and (GUNGECE IS NULL OR  GUNGECE='''' OR GUNGECE='''+Gece+''')');
   if TutarKontrolu then Tablo.Query3.SQL.Add(' and '+FloatToStr(Tutar)+'/'+FloatToStr((100.0+kdv)/100.0)+'>=ALT ');
   if Dr2Kontrolu then Tablo.Query3.SQL.Add(DrSecimi);
   Tablo.Query3.SQL.Add(' and (KOD=''*TÜM*'' ');
   St:='';
   repeat
     //if st <> '' then Tablo.Query3.SQL.Add(' or ');
     if pos('.', Kodu)>0 then begin
        st := St+copy(Kodu, 1, pos('.', Kodu)-1);
        Delete(Kodu, 1, pos('.', Kodu));
     end else begin
        st := St+Kodu;
        Kodu := '';
     end;
     if (st<>'')and(st<>'K')and(st[length(st)]='K')and(Kodu='') then begin
         Tablo.Query3.SQL.Add(' or KOD='''+St+'''');
         st := copy(st, 1, length(st)-1);
     end;
     Tablo.Query3.SQL.Add(' or KOD='''+St+'''');
     if Kodu<>'' then St := St+'.';
   Until Kodu='';
   if KurumOncelikli then
      Tablo.Query3.SQL.Add(') ORDER BY 1, TUR, KURUM, KURUMGRUBU, KOD, GUNGECE, ALT') //Tekdende böyle
   else
      Tablo.Query3.SQL.Add(') ORDER BY 1, TUR, KOD, KURUM, KURUMGRUBU, GUNGECE, ALT');//Uğurlu hast.de böyle
   Tablo.Query3.open;
   Tablo.Query3.Last;
   if Tablo.Query3.RecordCount > 0 then begin
      if Tablo.Query3.FieldByName('FIX').AsFloat > 0 then //oran 1000 den büyük demek ki sabit fiyat
         DoktorPayi_Getir := Tablo.Query3.FieldByName('FIX').AsFloat * Adet
      else begin
         if (Tablo.Query3.Fields[4].AsString{KDV}= 'HARİÇ') then
            carp := 1+(KDV/100)
         else if (Tablo.Query3.Fields[4].AsString{KDV}= 'F.LI HARİÇ') then begin
            carp := 1;
            Sonuc:= 3;
         end else
            carp := 1;

         if (Tur = 'HAK') and (Birim<>'') and (BirFiyatAdet<0.01) then begin ////Ek katkı var demektir diğer doktorlar için;
             BirFiyatAdet := StrToFloat(Birim);
             Tutar :=  BirFiyatAdet*Adet;
         end;


         if Tablo.Query3.Fields[3].AsString{İsk} = 'ETKİLENMEZ' then
            DP := (BirFiyatAdet/carp)*Tablo.Query3.Fields[2].AsFloat/100
         else
            DP := ((Tutar/carp)*Tablo.Query3.Fields[2].AsFloat)/100;

         DoktorPayi_Getir := Duyarlilik_Cur(DP);
      end
  end else
       DoktorPayi_Getir := 0;
end;

function DoktorPayiKDVDusur(DNO, GNO, KOD : String; DOKPAYI : Currency; KDV:SmallInt): Currency;
begin
   Tablo.Query5.Close;
   Tablo.Query5.SQL.Text := 'Select KOD,KDV from FATURA WHERE DOSYANO = '''+DNO+''''+
                      ' AND GELISNO = '+GNO+' and KOD='''+KOD+'''';
   Tablo.Query5.Open;
   if Tablo.Query5.RecordCount>0 then
      DOKPAYI:= DOKPAYI / (1+(KDV/100));

   DoktorPayiKDVDusur := DOKPAYI;
end;

procedure Iskonto_Getir(Kr, Kodu : String; var Fiyat : String; var Isk : Real;var IskMik:Currency);
begin
  Isk:= 0;
  IskMik:= 0.0;
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'Select KOD, isnull(ISKONTO,0.0), FIYAT, isnull(TUTAR,0.0) From KURUMISK Where '+
                     ' KURUM = '''+Kr+''''+
                     ' and KOD=''*TÜM*'' UNION Select KOD, isnull(ISKONTO,0.0), FIYAT, isnull(TUTAR,0.0) From KURUMISK Where '+
                     ' KURUM = '''+Kr+''''+' and (';
  St:='';
  repeat
    if st <> '' then Tablo.Query3.SQL.Add(' or ');
    if pos('.', Kodu)>0 then begin
       st := St+copy(Kodu, 1, pos('.', Kodu)-1);
       Delete(Kodu, 1, pos('.', Kodu));
    end else begin
       st := St+Kodu;
       Kodu := '';
    end;
    Tablo.Query3.SQL.Add(' KOD='''+St+'''');
    if Kodu<>'' then St := St+'.';
  Until Kodu='';
  Tablo.Query3.SQL.Add(') ORDER BY KOD');
  Tablo.Query3.open;
  Tablo.Query3.Last;
  if Tablo.Query3.RecordCount > 0 then begin //tutar
     if Tablo.Query3.Fields[3].AsFloat>0 then
        IskMik := Tablo.Query3.Fields[3].AsCurrency
     else
        Isk:= Tablo.Query3.Fields[1].AsFloat;
     Fiyat := Tablo.Query3.Fields[2].AsString;
  end
  else
     Fiyat := '';
end;

procedure Kampanya_Isk_Getir(Kr, Kodu : String; var Isk_Goster:String; var Isk : Real;var IskMik:Currency);
var Kampanya_turu, Kod1:String;
    bulundu : boolean;
         function Kampanya_Turunu_Getir : String;
         begin
            Application.CreateForm(TListeDlg, ListeDlg);
            ListeDlg.Label1.Caption := 'Kampanya Seçin';
            while not   Tablo.Query3.eof do begin
                ListeDlg.ListAmac.Items.Add(Tablo.Query3.Fields[6].AsString);
                Tablo.Query3.next;
            end;
            ListeDlg.ListAmac.ItemIndex := 0;
            if ListeDlg.ListAmac.Items.count > 1 then
               ListeDlg.ShowModal;
            if ListeDlg.ModalResult <> mrOK then
               result := '-1'
            else if ListeDlg.ListAmac.Items.count = 0 then
               result := ''
            else
               result := ListeDlg.ListAmac.Items[ListeDlg.ListAmac.ItemIndex];
            ListeDlg.Destroy;
         end;
begin
  Kod1 := Kodu;
  Isk:= 0;
  IskMik:= 0.0;
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'Select KURUM, KOD, isnull(ISKONTO,0.0), isnull(MIKTAR,0.0), ISK_GOSTER, SOR,KAMPANYA_ADI From KAMPANYA K, KAMPANYADETAY D Where '+
                     ' K.KNO = D.KNO AND '''+FormatDateTime('MM/DD/YYYY',GenotipIni.BugunTrh)+''' BETWEEN K.BASLAMA_TARIHI AND K.BITIS_TARIHI '+
                     ' AND (KURUM = '''+Kr+''' or isnull(KURUM,'''')='''') and isnull(K.DURUM,'''')<>''PASİF'' and isnull(D.DURUM,'''')<>''PASİF'' and KOD=''*TÜM*''  '+
                     ' UNION All Select KURUM, KOD, isnull(ISKONTO,0.0), isnull(MIKTAR,0.0), ISK_GOSTER, SOR,KAMPANYA_ADI From KAMPANYA K, KAMPANYADETAY D Where '+
                     ' K.KNO = D.KNO AND '''+FormatDateTime('MM/DD/YYYY',GenotipIni.BugunTrh)+''' BETWEEN K.BASLAMA_TARIHI AND K.BITIS_TARIHI '+
                     ' AND (KURUM = '''+Kr+''' or isnull(KURUM,'''')='''') and isnull(K.DURUM,'''')<>''PASİF'' and isnull(D.DURUM,'''')<>''PASİF'' and (';
  St:='';
  repeat
    if st <> '' then Tablo.Query3.SQL.Add(' or ');
    if pos('.', Kodu)>0 then begin
       st := St+copy(Kodu, 1, pos('.', Kodu)-1);
       Delete(Kodu, 1, pos('.', Kodu));
    end else begin
       st := St+Kodu;
       Kodu := '';
    end;
    Tablo.Query3.SQL.Add(' KOD='''+St+'''');
    if Kodu<>'' then St := St+'.';
  Until Kodu='';
  Tablo.Query3.SQL.Add(') ORDER BY 1, 2');
  Tablo.Query3.open;
  if Tablo.Query3.RecordCount>1 then //Aynı anda birden fazla kampanya var
     Kampanya_turu := Kampanya_Turunu_Getir; //bunlardan birini seçtirelim
  if Kampanya_turu = '-1' then begin
     Isk := 0;
     exit;
  end;

  Tablo.Query3.first;
  bulundu := False;
  while (not bulundu)and(not Tablo.Query3.Eof) do
     if Kampanya_turu = Tablo.Query3.Fields[6].AsString then  //seçilen kampanyayı uygulayalım
        bulundu :=True
     else
        Tablo.Query3.next;

  if (SonKampKod <> Kod1)and(Tablo.Query3.Fields[5].AsString='E') then begin//Kampanya uygulansın mı??? hemen soralım
     SonKampKod := Kod1;
     if Application.MessageBox(PChar(Tablo.Query3.Fields[6].AsString+' Kampanyası uygulansın mı?'),'O N A Y', MB_YESNO) <> idYES then begin
        Isk := 0;
        exit;
     end;
  end;

  if Tablo.Query3.RecordCount > 0 then begin //tutar
     if Tablo.Query3.Fields[3].AsFloat>0 then
        IskMik := Tablo.Query3.Fields[3].AsCurrency
     else
        Isk:= Tablo.Query3.Fields[2].AsFloat;
     Isk_Goster := Tablo.Query3.Fields[4].AsString;
  end
  else
    Isk:=0;
end;

function DrKod_Getir(Kodu, DrKod : String): String;
var Noktasiz : String[20];
    bulundu  : boolean;
begin
   if pos('.',Kodu)>0 then Noktasiz := copy(Kodu,1,pos('.',Kodu)-1)
   else Noktasiz := Kodu;
   bulundu := false;
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := ' Select KOD, DR From KODDR Where KOD like '''+Noktasiz+'%'' ORDER BY KOD desc';
   Tablo.Query3.open;
   while (not bulundu) and (not Tablo.Query3.eof) do begin
     if pos(Tablo.Query3.Fields[0].AsString, Kodu)>0 then
        bulundu := True
     else
        Tablo.Query3.next;
   end;

   if bulundu then
      DrKod_Getir := Tablo.Query3.Fields[1].AsString
   else
      DrKod_Getir := DrKod;
end;

procedure ParaBilgiGetir(Kod, Tur : String; var Ad, Dr,Birim, OzelKod, ButceKodu, MuhKodu, Grup, Sor: String; Tarih : TDateTime; var KDV :Integer; var Isk : Real; var Birimfiyat :Currency; Kurum, KDVDurum:String;UcretSor:Boolean);
var s, SaklaFiyatAdi, Carpan, tt : String[20];
    MesajOkunan, GecFiyat, Isk_Goster: string;
    KDVOrani : SmallInt;
    Isk_Kamp : Real;
    Fiyat1, Fiyat2, IskMik : currency;
    function FiyatGetir(FiyatAdi:String):Currency;
              function DovizKuru :Currency;
              begin
                Tablo.Query1.Close;
                Tablo.Query1.SQL.Text := 'Select '+tt+' From DOVIZ where CINSI='''+s +''' and TARIH='''+FormatDateTime('MM/DD/YYYY',Tarih)+'''';
                Tablo.Query1.Open;
                if Tablo.Query1.Fields[0].AsString <> '' then
                   DovizKuru :=  Tablo.Query1.Fields[0].AsFloat
                else
                   DovizKuru := 0;
              end;
    begin
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'Select FIYATADI, SEC, KATSAYI, CARPAN From FIYATLAR Where KOD='''+Kod+''''+
                           ' and FIYATADI = '''+FiyatAdi+'''';
        Tablo.Query2.open;
        Carpan := Tablo.Query2.FieldByName('CARPAN').AsString;

        if Tablo.Query2.FieldByName('KATSAYI').AsFloat = -1 then begin
           Carpan:='';
           if UcretSor then begin
              if MesajStrAl(Ad,'Ücreti Giriniz :','E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
                 Fiyat1 := StrToFloat(MesajOkunan)
              else
                 Fiyat1 := 0;
           end
           else Fiyat1 := 0;
        end
        else if Tablo.Query2.FieldByName('KATSAYI').AsFloat = -2 then begin //2.fiyat uygulanıyor....
           Tablo.Query2.Close;
           Tablo.Query2.SQL.Text := ' Select FIYATLAR.FIYATADI, SEC, isnull(KATSAYI,0) AS KATSAYI, isnull(CARPAN,1) as CARPAN '+
                                    ' From FIYATLAR, KURUM '+
                                    ' Where KOD='''+Kod+''''+
                                    ' and KURUM.KURUM = '''+Kurum+''''+
                                    ' and FIYATLAR.FIYATADI = KURUM.FIYATADI2 ';
           Tablo.Query2.open;
           Fiyat1 := Tablo.Query2.FieldByName('KATSAYI').AsFloat*Tablo.Query2.FieldByName('CARPAN').AsFloat;
        end
        else
           Fiyat1 := Tablo.Query2.FieldByName('KATSAYI').AsFloat;

        if (Tablo.Query2.FieldByName('CARPAN').AsFloat > 1)or(Tablo.Query2.FieldByName('SEC').AsString = '*') then  //TTB veya Dövizse Birime yaz
           Birim := FloatToStr(Fiyat1)
        else if Tablo.Query2.FieldByName('SEC').AsString = 'S' then begin //SSK lı Birime yaz Birim fiyatı sıfırla
           Birim := FloatToStr(Fiyat1);
           Fiyat1:=0;
        end;

        if Tablo.Query2.FieldByName('SEC').AsString = '*' then begin//Demekki döviz..
                s := Tablo.Query2.FieldByName('FIYATADI').AsString;
                s := copy(s,pos('(',s)+1,pos(')',s)-pos('(',s)-1);

                if pos('YABANCI', Kurum)>0 then
                   tt := 'EFALIS'
                else
                   tt := 'SATIS';

                Fiyat1 := Fiyat1*DovizKuru;
             end
        else if (Tablo.Query2.FieldByName('SEC').AsString = '$')or(Tablo.Query2.FieldByName('SEC').AsString = '€') then begin//Demekki döviz..
                Birim := FloatToStr(Fiyat1)+Tablo.Query2.FieldByName('SEC').AsString;
                s := Tablo.Query2.FieldByName('SEC').AsString;
                tt := 'SATIS';
                Fiyat1 := Fiyat1*DovizKuru;
        end else
            if Carpan <> '' then
               Fiyat1 := Fiyat1*StrToFloat(Carpan);

        if IskMik > 0 then begin
           Fiyat1 := IskMik;
           Isk := 0;
        end;
        FiyatGetir := Fiyat1;
    end;
begin
     if FiyatAdi='x!' then
        UcretAraDlg.FiyatDegistir;
     if Tarih<StrToDatetime('01/01/2000') then Tarih := GenotipIni.BugunTrh;
     Tablo.Query1.Close;
     if (Tur = 'STOK')or(Tur = 'ECZ') then
        Tablo.Query1.SQL.Text := 'Select KOD,STOKADI,GRUBU,OZELKOD,BUTCEKODU,KDV,MUHKODU,SOR From '+Tur+'KART Where KOD='''+Kod+''''
     else
        Tablo.Query1.SQL.Text := 'Select KOD,ISLEMADI,GRUP,OZELKOD,BUTCEKODU,KDV,MUHKODU,TUR,BIRIM,SOR From ISLEMLER Where KOD='''+Kod+'''';
     Tablo.Query1.open;
     if Tablo.Query1.FieldByName('KDV').AsString = '' then begin
        Birimfiyat := 0;
        exit;
        //raise exception.Create(Kod+' '+Ad+' işleminin KDV oranı bulunamadı..')
     end else
        KDVOrani := Tablo.Query1.FieldByName('KDV').AsInteger;
     //Adını Getir
     Ad := Tablo.Query1.Fields[1].AsString;
     //Dr.Kodunu Getir
     Dr := DrKod_Getir(Kod, Dr);

     //Muhasebe Kodunu Getir
     OzelKod := Tablo.Query1.FieldByName('OZELKOD').AsString;
     MuhKodu := Tablo.Query1.FieldByName('MUHKODU').AsString;
     ButceKodu := Tablo.Query1.FieldByName('BUTCEKODU').AsString;
     Sor := Tablo.Query1.FieldByName('SOR').AsString;
     if (Tur <> 'STOK')and(Tur <> 'ECZ') then begin
        Tur     := Tablo.Query1.FieldByName('TUR').AsString;
        Grup    := Tablo.Query1.FieldByName('GRUP').AsString
     end;
        //KDV - İskonto Getir
     KDV := Tablo.Query1.FieldByName('KDV').AsInteger;
     if (Tur <> 'STOK')and(Tur <> 'ECZ')and(Tablo.Query1.FieldByName('BIRIM').AsString = 'Seanslı') then
        Grup := 'Seanslı';

//     if PaketKod <> '' then
//        Isk := Iskonto_Getir(Kurum, PaketKOD, GecFiyat)
//     else

     Iskonto_Getir(Kurum, Kod, GecFiyat, Isk, IskMik);


     if GecFiyat<>'' then begin
        SaklaFiyatAdi := FiyatAdi;
        FiyatAdi := GecFiyat;
     end;
     //Fiyatını Getir
     if (Tur = 'STOK')or(Tur = 'ECZ') then begin
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'Select FIYATADI, FIYAT  From '+Tur+'FIYAT Where KOD='''+Kod+''' '+
                           'and (FIYATADI = '''+FiyatAdi+''' or FIYATADI = '''' or FIYATADI is NULL) and BIRIM ='''+Birim+'''';
        Tablo.Query2.open; //hem o fiyatla hem de boş fiyat adıyla 2 ayrı kayıt bulunmuşsa öncelik fiyatadına
        if (Tablo.Query2.RecordCount > 1)and(Tablo.Query2.Fields[0].AsString <> FiyatAdi) then
            Tablo.Query2.next;
        Birimfiyat := Tablo.Query2.Fields[1].AsFloat;
        if Birimfiyat = -1 then begin
           if UcretSor then begin
              if MesajStrAl(Ad,'Ücreti Giriniz :','E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
                 Birimfiyat := StrToFloat(MesajOkunan)
              else
                 Birimfiyat := 0;
           end
           else Birimfiyat := 0;
        end;
     end
     else begin
        if pos('<>', FiyatAdi)>0 then begin //Poliklinik-TTB iki fiyat var; düşük olanı seçilecek
           BirimFiyat := FiyatGetir(copy(FiyatAdi,1,pos('<>', FiyatAdi)-1));
           Fiyat2 := FiyatGetir(copy(FiyatAdi, pos('<>', FiyatAdi)+2, length(FiyatAdi)-pos('<>', FiyatAdi)));
           if Fiyat2 <  BirimFiyat*(100-Isk)/100 then begin
              BirimFiyat := Fiyat2;
              Isk := 0;
           end;
        end else
           BirimFiyat := FiyatGetir(FiyatAdi);
     end;

     if Kampanya then begin
         Kampanya_Isk_Getir(Kurum, Kod, Isk_Goster, Isk_Kamp, IskMik);
         if (Isk_Kamp > 0.0)or(IskMik > 0.0)then begin
             if (Isk_Goster='E') then begin //
                 if IskMik > 0.01 then
                    Isk := (IskMik / BirimFiyat)*100.0
                 else
                    Isk := Isk_Kamp
             end
             else begin
                 if IskMik > 0.01 then
                    BirimFiyat := BirimFiyat - IskMik
                 else
                    BirimFiyat := BirimFiyat * (100.0-Isk_Kamp) /100.0
             end;
         end;
     end;

     if KDVDurum = 'Hariç' then begin
        BirimFiyat := BirimFiyat / (1+(KDVOrani/100));
        KDV := 0;
     end;

     if GecFiyat <> '' then
        FiyatAdi := SaklaFiyatAdi;
end;




procedure KatkiBilgiGetir(Kod, Tur : String; var Ad, Dr,Birim, OzelKod, ButceKodu, MuhKodu, Grup: String; Tarih : TDateTime; var KDV :Integer; var Isk : Real; var Birimfiyat :Currency; Kurum, KDVDurum:String;UcretSor:Boolean);
var //s, SaklaFiyatAdi, Carpan : String[20];
    KDVOrani : SmallInt;
    MesajOkunan : String;
begin
     Tablo.Query1.Close;
     if (Tur = 'STOK')or(Tur = 'ECZ') then
        Tablo.Query1.SQL.Text := 'Select KOD,GRUBU,OZELKOD,BUTCEKODU,KDV,MUHKODU From '+Tur+'KART Where KOD='''+Kod+''''
     else
        Tablo.Query1.SQL.Text := 'Select KOD,GRUP,OZELKOD,BUTCEKODU,KDV,MUHKODU,TUR From ISLEMLER Where KOD='''+Kod+'''';
     Tablo.Query1.open;
     if Tablo.Query1.FieldByName('KDV').AsString = '' then
        raise exception.Create(Ad+' işleminin KDV oranı bulunamadı..')
     else
        KDVOrani := Tablo.Query1.FieldByName('KDV').AsInteger;
     //Adını Getir
     Ad := 'KATKI PAYI';
     //Dr.Kodunu Getir
     Dr := DrKod_Getir(Kod, Dr);

     //Muhasebe Kodunu Getir
     OzelKod := Tablo.Query1.FieldByName('OZELKOD').AsString;
     MuhKodu := Tablo.Query1.FieldByName('MUHKODU').AsString;
     ButceKodu := Tablo.Query1.FieldByName('BUTCEKODU').AsString;
     if (Tur <> 'STOK')and(Tur <> 'ECZ') then begin
        Tur     := Tablo.Query1.FieldByName('TUR').AsString;
        Grup    := Tablo.Query1.FieldByName('GRUP').AsString
     end;
     KDV := Tablo.Query1.FieldByName('KDV').AsInteger;

     //Fiyatını Getir
     if (Tur = 'STOK')or(Tur = 'ECZ') then begin
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'Select FIYAT From '+Tur+'FIYAT Where KOD='''+Kod+''' '+
                                 'and FIYATADI = '''+KatkiAdi+''' and BIRIM ='''+Birim+'''';
        Tablo.Query2.open;
        if Tablo.Query2.Fields[0].AsString='' then
           BirimFiyat := -9.0 // katkı yok
        else
           Birimfiyat := Tablo.Query2.Fields[0].AsFloat;
     end
     else begin
        Birim := '';
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'Select KATSAYI,CARPAN From FIYATLAR Where KOD='''+Kod+''''+
                           ' and FIYATADI = '''+KatkiAdi+'''';
        Tablo.Query2.open;

        if Tablo.Query2.Fields[0].AsString='' then
           BirimFiyat := -9.0 // katkı yok
        else
           if Tablo.Query2.Fields[0].AsFloat = -1 then begin
              if UcretSor then begin
                 if MesajStrAl(Ad,'Ücreti Giriniz :','E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then begin
                    if MesajOkunan='' then MesajOkunan:='-9';
                    BirimFiyat := StrToFloat(MesajOkunan);
                 end
                 else
                    BirimFiyat := -9.0;
              end
              else BirimFiyat := 0;
           end
           else if Tablo.Query2.Fields[1].AsString<>'' then
              BirimFiyat := Tablo.Query2.Fields[0].AsCurrency*Tablo.Query2.Fields[1].AsCurrency
           else
              BirimFiyat := Tablo.Query2.Fields[0].AsCurrency;
     end;
   end;

end.
