unit UUnits;

interface

uses FireDAC.Comp.Client, Data.DB, ComCtrls, SysUtils, Variants, Controls, Windows, Vcl.Forms  ;

procedure YorumDuzenleIslemi(TabNotlar : TFDQuery; RehberID:Integer);
procedure YorumEkleIslemi(TabRehber,TabNotlar:TFDQuery; RehberID:Integer);
procedure YorumSilIslemi(TabNotlar : TFDQuery; RehberID:Integer);
function MasrafSilmeIslemi(MasrafId:Integer):Boolean;

implementation

uses UGirisKutusuEx, UTablo, PrjConst, FetaKurulusSiniflari, UVeriMotor;

procedure YorumEkleIslemi(TabRehber,TabNotlar : TFDQuery; RehberID:Integer);
var MemoNot, Tarih, Tur:Variant;
    ctrls: TGirdiDenetimleri;
begin
   MemoNot:= '';
   Tarih := Tablo.GENINI.BugunTrh;
   Tur:=11;
   ctrls := TGirdiDenetimleri.Create
     .ImageComboBox(AWTuru,@Tur,Tablo.FDCnn,'select DEGER, ANAHTAR from GENINI where BOLUM=-22035 ',False,nil)
     .DateTimePicker(KontrolTarihi+':', @Tarih,dtkDate)
     .Memo(AWNotlar , @MemoNot);
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls) = mrOk then begin
      if Trim(VarToStr(MemoNot))<>'' then begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO GOREVYORUM(GOREVID,TUR,TARIH,YORUM,EKLEYEN)VALUES('+IntToStr(RehberID)+','+VarToStr(Tur)+
           ','''+formatdatetime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn',Tarih)+''','''+StringReplace(Trim(MemoNot),'''',' ',[rfreplaceall])+''','+Kullanan+') ',[],[]);
         Tabloyenile(TabNotlar,[RehberID]);
         TabNotlar.First;
      end;
   end;
end;

procedure YorumDuzenleIslemi(TabNotlar : TFDQuery; RehberID:Integer);
var MemoNot, Tarih, Tur:Variant;
    ctrls: TGirdiDenetimleri;
begin
   MemoNot:= TabNotlar.FieldByName('YORUM').AsString;
   Tarih := TabNotlar.FieldByName('TARIH').AsDateTime;
   Tur:=TabNotlar.FieldByName('TUR').AsInteger;
   ctrls := TGirdiDenetimleri.Create
     .ImageComboBox(AWTuru,@Tur,Tablo.FDCnn,'select DEGER, ANAHTAR from GENINI where BOLUM=-22035 ',False,nil)
     .DateTimePicker(KontrolTarihi+':', @Tarih,dtkDate)
     .Memo(AWNotlar , @MemoNot);
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,ctrls) = mrOk then begin
      if Trim(VarToStr(MemoNot))<>'' then begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE GOREVYORUM SET TUR='+VarToStr(Tur)+',TARIH='''+formatdatetime('mm'+FormatSettings.DateSeparator+'dd'+FormatSettings.DateSeparator+'yyyy hh:nn', Tarih)+''', YORUM='''+StringReplace(Trim(MemoNot),'''',' ',[rfreplaceall])+''' WHERE ID='+TabNotlar.Fields[0].AsString, [], []);
         Tabloyenile(TabNotlar,[]);
      end;
   end;
end;

procedure YorumSilIslemi(TabNotlar : TFDQuery; RehberID:Integer);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'DELETE FROM GOREVYORUM WHERE ID='+TabNotlar.Fields[0].AsString, [], []);
      Tabloyenile(TabNotlar,[]);
   end;
end;

function MasrafSilmeIslemi(MasrafId:Integer):Boolean;
// SILME ARTIK SUNUCUDA: sp_Api_MasrafGelir_Sil_Json (GenDepoUpdate129, modul 58).
//   Engel kurallari (kasa/belge/fatura satiri/butce) fn_Prog_Silme_Engel(58);
//   FIYATLAR satirlari + kart TEK transaction. Eskiden log HIC yazilmiyordu ->
//   silinen masraf/gelir Geri Al ile geri gelmiyordu.
//   Doner True: cagiran dataset'i tazelemeli (kayit SUNUCUDA silindi).
begin
  Result := False;
  if MasrafId <= 0 then Exit;
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
    Tablo.ApiSilCagir('sp_Api_MasrafGelir_Sil_Json', MasrafId);
    Result := True;
  end;
end;

end.



