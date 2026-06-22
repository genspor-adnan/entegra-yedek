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
  Buffer:Array[0..4095] Of Byte; //bu açmak için kullanacağımız geçici bir buffer
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
Dosya sıkıştırmak için kullanılır
FileName            : Sıkıştırılmış dosyanın adı.
DeCompressedFileName  : Açılan
    dosyanın kaydedileceği dosya adı.
Sonuç :
  00: Başarılı
  01: Giriş dosyası açılamadı. (Dosya yok, kullanımda, yada hafıza yetersiz)
  02: Çıkış dosyası yaratılamadı. (Yazma hakkı yok,
    dosya adı hatalı yada hafıza yetersiz)
  03: Açma stream'i yaratılamadı. (Hafıza yetersiz)
  04: Açma işlemi başarısız oldu. (Hafıza yetersiz)
}

Begin
  Try
    InFile:=TFileStream.Create(FileName,fmOpenRead);

    // Sıkıştırılmış dosya açılıyor
  Except
    //Dosyayı açamadık. Hata verip
  //  çıkacağız.
    Result:=01;
    Exit;

  End;
  Try
    OutFile:=TFileStream.Create(DeCompressedFileName,
    fmCreate);
    // Kaydedilecek dosya yaratılıyor
  Except
    // Çıkış dosyası yaratılamadı. Hata verip çıkacağız.
    Result:=02;
    InFile.Free;
     //Açtığımız stream'i kapamayı unutmuyoruz.
    Exit;
  End;

  Try
    DeComp:=TDeCompressionStream.Create(InFile);
    // Açma işlemi için kullanılacak olan
    //stream yaratılıyor.
    // Decompression sınıfının dolayısı ile DeComp'un özelliği
    // bu stream'den bilgi okunurken otomatik olarak okunma
    //anında
    //bilgi açılır. Bu stream'in kodunu zlib.pas dosyasında bulabilirsiniz.
  Except
    //Dosyalar
  //  ile ilgili bir problemimiz yok, ama sıkıştırma işlemini
    //gerçekleştiremedik. Hata verip çıkıyoruz.
    Result:=03;
    InFile.Free;
      // Açtığımız tüm stream'leri kapıyoruz.
    OutFile.Free;

    Exit;
  End;
  Result:=00; //Sonucu herşey iyiymiş gibi ayarlıyoruz.
  //Açma işlemi için farklı bir yöntem
  //  kullanmak zorundayız. Çünkü
  //DeComp bilgiyi biz okurken açtığı için boyutunu önceden hesaplamıyor.
  //Bu yüzden ya dosya boyunu dosyayı
 //   sıkıştırırken (ki bu dosya adıda eklendiği
  //zaman benim sevdiğim ve kullandığım teknik oluyor.)
  //dosyanın en başına ekleyeceğiz,
 //   yada bir hata alana kadar bu stream'den
  //okumaya devam edeceğiz (buda zlib ile bereber gelen örnek programdaki teknik)
  //ben burada basit olduğu
 //   için ikinci tekniği kullanacağım.
  Repeat
    Try
      DeComp.OnProgress:=Process;
      Count:= DeComp.Read(Buffer,SizeOf(Buffer));
      //Okuyabildiğimiz kadar veriyi okuyoruz. Count
   // okuduğumuz toplam
      //byte sayısını tutuyor.
      If Count<>
    0 Then OutFile.WriteBuffer(Buffer,
    Count);
      //Eğer veri okuyabildiysek (ki verilerin sonuna gelene kadar okuyacağız)

    //bunu OutFile'a yazıyoruz.
    Except
      Result:=04;
      Count:=0;

      //Hata oluştu. Hata kodunu ayarlıyoruz, ve count'u döngüden çıkmak için sıfırlıyoruz.
    End;

  Until Count=0;
  // İşte işimiz bitti. Artık açılmış
 //   dosyayı elde ettik. (Tabi hata almadıysak)
  //tabiki OutFile Free method'unu çağırına dek bu dosyanın disk üzerine yazıldığından
  //emin olamayız.
 //   Yine önce Decomp'u bırakıyoruz.
  DeComp.Free;
  InFile.Free;
  OutFile.Free;

End;

Function TCompress.CompressFile(FileName,CompressedFileName:String): Byte;
{
CompressFile
Dosya
    sıkıştırmak için kullanılır
FileName            : Sıkıştırılacak olan dosyanın adı.
CompressedFileName  : Sıkıştırılmış dosyanın kaydedileceği dosya adı.
Sonuç :
  00:
    Başarılı
  01: Giriş dosyası açılamadı. (Dosya yok, kullanımda, yada hafıza yetersiz)
  02: Çıkış dosyası yaratılamadı. (Yazma hakkı yok, dosya adı hatalı yada hafıza yetersiz)
  03: Sıkıştırma
    stream'i yaratılamadı. (Hafıza yetersiz)
  04: Sıkıştırma başarısız oldu. (Hafıza yetersiz)

}
Begin
  ShowMessage(CompressedFileName);
  Try
    InFile:=TFileStream.Create(FileName,fmOpenRead);

    // Sıkıştırılacak dosya açılıyor
  Except
    //Dosyayı açamadık. Hata verip
    //çıkacağız.
    Result:=01;
    Exit;

  End;
  Try
    OutFile:=TFileStream.Create(CompressedFileName,
    fmCreate);
    // Kaydedilecek dosya yaratılıyor
  Except
    // Çıkış dosyası yaratılamadı. Hata verip çıkacağız.
    Result:=02;
    InFile.Free;
     //Açtığımız stream'i kapamayı unutmuyoruz.
    Exit;
  End;

  Try
    Comp:=TCompressionStream.Create(clMax,OutFile);

    // Sıkıştırma için kullanılacak olan stream yaratılıyor.
    // bu stream'in kodunu zlib.pas dosyasında bulabilirsiniz.

    // stream'ler ile ilgili daha detaylı bilgi için
    // Delphi help'te TStream konusunu aratın.
  Except

    //Dosyalar ile ilgili bir problemimiz yok, ama sıkıştırma işlemini
    //gerçekleştiremedik. Hata verip çıkıyoruz.
    Result:=03;
    InFile.Free;  // Açtığımız tüm stream'leri kapıyoruz.
    OutFile.Free;

    Exit;
  End;
  Result:=00; //Sonucu herşey iyiymiş gibi ayarlıyoruz.
  Try
    FProcess(self,0);
    comp.OnProgress:=Process;
    Comp.CopyFrom(InFile,0);
    // InFile stream'inin içeriğini sonuna kadar Comp'a kopyalıyoruz.
    //TCompression sınıfının
   // dolayısı ile Comp'un özelliği içine yazılması
    //sırasında yazılan bilgiyi otomatik olarak sıkıştırmasıdır. Yani bu
    //kopyalama sırasında aynı
  //  zamanda bilgiyi sıkıştırmışta olduk.
    //Kolay değilmi ?
    //Eğer Comp.OnProgress event'ına bir procedure atayacak olursanız
   // aynı
    //zamanda işlemin devamı sırasında otomatik olarak belirli aralıklarla
    //istediğiniz bir procedure'ü çalıştırabilirsiniz. Bu da size bir
    //progressbar'ı
    //ilerletmeniz için yardımcı olur.
  Except
    Result:=04; //Beklediğimiz olmadı. Sonucu hataya göre ayarlıyoruz.
  End;
  // İşte işimiz bitti. Artık sıkıştırılmış bir dosya elde ettik. (Tabi hata almadıysak)
  //tabiki OutFile Free method'unu
   // çağırına dek bu dosyanın disk üzerine yazıldığından
  //emin olamayız. Burada dikkat etmeniz gereken bir nokta daha var. Comp siz onu
  //yok edene dek
 //   OutFilew Stream'ini kullanacaktır. Dolayısı ile önce Comp'u daha sonra
  //OutFile'ı kapatmak zorundasınız.
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
