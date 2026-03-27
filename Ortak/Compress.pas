unit Compress;

interface

uses
  SysUtils, Classes, Controls,Dialogs, zlib,Forms;

type
  TProcess = procedure(Sender: TObject; Process:integer) of object;
  TCompress = class(TComponent)
  private
    { Private declarations }
    FKaynakDosya:TFileName;
    FHedefDosya:TFileName;
    FProcess:TProcess;

    Procedure SetKaynakDosya(const Value:TFileName);
    function  GetKaynakDosya: TFileName;
    Procedure SetHedefDosya(const Value:TFileName);
    function  GetHedefDosya: TFileName;
    Procedure Process(Sender:TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
     function Compress:Byte;
     function DeCompress:Byte;
  published
    { Published declarations }
     Function CompressFile(FileName,CompressedFileName:String): Byte;
     Function  DecompressFile(FileName,DeCompressedFileName:String):Byte;
     property KaynakDosya:TFileName read GetKaynakDosya   write SetKaynakDosya;
     property HedefDosya:TFileName read GetHedefDosya   write SetHedefDosya;
     property OnProcess:TProcess read FProcess write FProcess;
  end;


procedure Register;

var
  InFile,OutFile:TFileStream;
  Comp:TCompressionStream;
  DeComp:TDeCompressionStream;
  Buffer:Array[0..4095] Of Byte; //bu açmak için kullanacaðýmýz geçici bir buffer
  Count:Integer;


implementation


procedure Register;
begin
  RegisterComponents('CompDecomp', [TCompress]);
end;

constructor TCompress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

Function TCompress.Compress:byte;
begin
  Result:=CompressFile(FKaynakDosya,FHedefDosya);
end;

Function TCompress.DeCompress:byte;
begin
  Result:=DecompressFile(FKaynakDosya,FHedefDosya);
end;

function TCompress.GetKaynakDosya: TFileName;
begin
 Result := FKaynakDosya;
end;

Procedure TCompress.SetKaynakDosya(const Value:TFileName);
begin
  FKaynakDosya:=value;
end;

function TCompress.GetHedefDosya: TFileName;
begin
 Result := FHedefDosya;
end;

Procedure TCompress.SetHedefDosya(const Value:TFileName);
begin
  FHedefDosya:=value;
end;

Procedure TCompress.Process(Sender:TObject);
var
Hesap:integer;
begin
Hesap:=(InFile.Position*100) div InFile.Size;
if Assigned(FProcess) then
  if InFile.Position<InFile.Size then
    FProcess(self,Hesap)
  else
    FProcess(self,0);
end;

Function TCompress.DecompressFile(FileName,DeCompressedFileName:String):Byte;

{
DeCompressFile
Dosya sýkýþtýrmak için kullanýlýr
FileName            : Sýkýþtýrýlmýþ dosyanýn adý.
DeCompressedFileName  : Açýlan
    dosyanýn kaydedileceði dosya adý.
Sonuç :
  00: Baþarýlý
  01: Giriþ dosyasý açýlamadý. (Dosya yok, kullanýmda, yada hafýza yetersiz)
  02: Çýkýþ dosyasý yaratýlamadý. (Yazma hakký yok,
    dosya adý hatalý yada hafýza yetersiz)
  03: Açma stream'i yaratýlamadý. (Hafýza yetersiz)
  04: Açma iþlemi baþarýsýz oldu. (Hafýza yetersiz)
}

Begin
  Try
    InFile:=TFileStream.Create(FileName,fmOpenRead);

    // Sýkýþtýrýlmýþ dosya açýlýyor
  Except
    //Dosyayý açamadýk. Hata verip
  //  çýkacaðýz.
    Result:=01;
    Exit;

  End;
  Try
    OutFile:=TFileStream.Create(DeCompressedFileName,
    fmCreate);
    // Kaydedilecek dosya yaratýlýyor
  Except
    // Çýkýþ dosyasý yaratýlamadý. Hata verip çýkacaðýz.
    Result:=02;
    InFile.Free;
     //Açtýðýmýz stream'i kapamayý unutmuyoruz.
    Exit;
  End;

  Try
    DeComp:=TDeCompressionStream.Create(InFile);
    // Açma iþlemi için kullanýlacak olan
    //stream yaratýlýyor.
    // Decompression sýnýfýnýn dolayýsý ile DeComp'un özelliði
    // bu stream'den bilgi okunurken otomatik olarak okunma
    //anýnda
    //bilgi açýlýr. Bu stream'in kodunu zlib.pas dosyasýnda bulabilirsiniz.
  Except
    //Dosyalar
  //  ile ilgili bir problemimiz yok, ama sýkýþtýrma iþlemini
    //gerçekleþtiremedik. Hata verip çýkýyoruz.
    Result:=03;
    InFile.Free;
      // Açtýðýmýz tüm stream'leri kapýyoruz.
    OutFile.Free;

    Exit;
  End;
  Result:=00; //Sonucu herþey iyiymiþ gibi ayarlýyoruz.
  //Açma iþlemi için farklý bir yöntem
  //  kullanmak zorundayýz. Çünkü
  //DeComp bilgiyi biz okurken açtýðý için boyutunu önceden hesaplamýyor.
  //Bu yüzden ya dosya boyunu dosyayý
 //   sýkýþtýrýrken (ki bu dosya adýda eklendiði
  //zaman benim sevdiðim ve kullandýðým teknik oluyor.)
  //dosyanýn en baþýna ekleyeceðiz,
 //   yada bir hata alana kadar bu stream'den
  //okumaya devam edeceðiz (buda zlib ile bereber gelen örnek programdaki teknik)
  //ben burada basit olduðu
 //   için ikinci tekniði kullanacaðým.
  Repeat
    Try
      DeComp.OnProgress:=Process;
      Count:= DeComp.Read(Buffer,SizeOf(Buffer));
      //Okuyabildiðimiz kadar veriyi okuyoruz. Count
   // okuduðumuz toplam
      //byte sayýsýný tutuyor.
      If Count<>
    0 Then OutFile.WriteBuffer(Buffer,
    Count);
      //Eðer veri okuyabildiysek (ki verilerin sonuna gelene kadar okuyacaðýz)

    //bunu OutFile'a yazýyoruz.
    Except
      Result:=04;
      Count:=0;

      //Hata oluþtu. Hata kodunu ayarlýyoruz, ve count'u döngüden çýkmak için sýfýrlýyoruz.
    End;

  Until Count=0;
  // Ýþte iþimiz bitti. Artýk açýlmýþ
 //   dosyayý elde ettik. (Tabi hata almadýysak)
  //tabiki OutFile Free method'unu çaðýrýna dek bu dosyanýn disk üzerine yazýldýðýndan
  //emin olamayýz.
 //   Yine önce Decomp'u býrakýyoruz.
  DeComp.Free;
  InFile.Free;
  OutFile.Free;

End;

Function TCompress.CompressFile(FileName,CompressedFileName:String): Byte;
{
CompressFile
Dosya
    sýkýþtýrmak için kullanýlýr
FileName            : Sýkýþtýrýlacak olan dosyanýn adý.
CompressedFileName  : Sýkýþtýrýlmýþ dosyanýn kaydedileceði dosya adý.
Sonuç :
  00:
    Baþarýlý
  01: Giriþ dosyasý açýlamadý. (Dosya yok, kullanýmda, yada hafýza yetersiz)
  02: Çýkýþ dosyasý yaratýlamadý. (Yazma hakký yok, dosya adý hatalý yada hafýza yetersiz)
  03: Sýkýþtýrma
    stream'i yaratýlamadý. (Hafýza yetersiz)
  04: Sýkýþtýrma baþarýsýz oldu. (Hafýza yetersiz)

}
Begin
  ShowMessage(CompressedFileName);
  Try
    InFile:=TFileStream.Create(FileName,fmOpenRead);

    // Sýkýþtýrýlacak dosya açýlýyor
  Except
    //Dosyayý açamadýk. Hata verip
    //çýkacaðýz.
    Result:=01;
    Exit;

  End;
  Try
    OutFile:=TFileStream.Create(CompressedFileName,
    fmCreate);
    // Kaydedilecek dosya yaratýlýyor
  Except
    // Çýkýþ dosyasý yaratýlamadý. Hata verip çýkacaðýz.
    Result:=02;
    InFile.Free;
     //Açtýðýmýz stream'i kapamayý unutmuyoruz.
    Exit;
  End;

  Try
    Comp:=TCompressionStream.Create(clMax,OutFile);

    // Sýkýþtýrma için kullanýlacak olan stream yaratýlýyor.
    // bu stream'in kodunu zlib.pas dosyasýnda bulabilirsiniz.

    // stream'ler ile ilgili daha detaylý bilgi için
    // Delphi help'te TStream konusunu aratýn.
  Except

    //Dosyalar ile ilgili bir problemimiz yok, ama sýkýþtýrma iþlemini
    //gerçekleþtiremedik. Hata verip çýkýyoruz.
    Result:=03;
    InFile.Free;  // Açtýðýmýz tüm stream'leri kapýyoruz.
    OutFile.Free;

    Exit;
  End;
  Result:=00; //Sonucu herþey iyiymiþ gibi ayarlýyoruz.
  Try
    FProcess(self,0);
    comp.OnProgress:=Process;
    Comp.CopyFrom(InFile,0);
    // InFile stream'inin içeriðini sonuna kadar Comp'a kopyalýyoruz.
    //TCompression sýnýfýnýn
   // dolayýsý ile Comp'un özelliði içine yazýlmasý
    //sýrasýnda yazýlan bilgiyi otomatik olarak sýkýþtýrmasýdýr. Yani bu
    //kopyalama sýrasýnda ayný
  //  zamanda bilgiyi sýkýþtýrmýþta olduk.
    //Kolay deðilmi ?
    //Eðer Comp.OnProgress event'ýna bir procedure atayacak olursanýz
   // ayný
    //zamanda iþlemin devamý sýrasýnda otomatik olarak belirli aralýklarla
    //istediðiniz bir procedure'ü çalýþtýrabilirsiniz. Bu da size bir
    //progressbar'ý
    //ilerletmeniz için yardýmcý olur.
  Except
    Result:=04; //Beklediðimiz olmadý. Sonucu hataya göre ayarlýyoruz.
  End;
  // Ýþte iþimiz bitti. Artýk sýkýþtýrýlmýþ bir dosya elde ettik. (Tabi hata almadýysak)
  //tabiki OutFile Free method'unu
   // çaðýrýna dek bu dosyanýn disk üzerine yazýldýðýndan
  //emin olamayýz. Burada dikkat etmeniz gereken bir nokta daha var. Comp siz onu
  //yok edene dek
 //   OutFilew Stream'ini kullanacaktýr. Dolayýsý ile önce Comp'u daha sonra
  //OutFile'ý kapatmak zorundasýnýz.
  Comp.Free;
  InFile.Free;

  OutFile.Free;
  if Assigned(Fprocess) then
    FProcess(self,100);
  Application.ProcessMessages;
  if Assigned(Fprocess) then
    FProcess(self,0);
End;



end.
