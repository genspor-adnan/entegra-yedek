unit UPaylasim;

interface
uses Windows, SysUtils;

type
  TPay = class(TObject)
  private
    fhnd: integer;
    fadr: pointer;
  public
    ZatenVar: Boolean;
    constructor Create(isim: pchar);   dynamic;
    destructor  Destroy;               override;
    property    Addr: pointer read fadr;
  end;
var
  Pay:TPay;

Procedure MemAc;
function MemReadString:String;
Procedure MemWriteString(Yaz:String);
Procedure MemKapat;
implementation

function MemReadString:String;
var s : PChar;
begin
   s := Pay.Addr;
   if s='' then s:='0';
   MemReadString := s;
end;

Procedure MemWriteString(Yaz:String);
var s : PChar;
begin
   s := Pay.Addr;
//   s[0] :=Yaz[1];
   StrPCopy(s,Yaz);
end;

Procedure MemAc;
begin
   Pay:=TPay.Create('GenoMedics');
end;

Procedure MemKapat;
begin
   Pay.Free;
end;
{
procedure TForm1.Button1Click(Sender: TObject);
var s : PChar;
begin
   s := Pay.Addr;
   s[0] :='A';
end;

procedure TForm1.Button2Click(Sender: TObject);
var s : PChar;
    q : String;
begin
   s := Pay.Addr;
   q:=s;
   showmessage(q);
end;
}

{ TPay }

constructor TPay.Create(isim: Pchar);
begin
  fhnd:=CreateFileMapping($FFFFFFFF,nil,PAGE_READWRITE+SEC_COMMIT,0,4096,isim);
  if(fhnd=0)then raise Exception.Create('Paylaşım alanı oluşturulamadı');
  if((fhnd<>0)and(GetLastError()=ERROR_ALREADY_EXISTS))then ZatenVar:=true;
  fadr:=MapViewOfFile(fhnd,FILE_MAP_WRITE+FILE_MAP_READ,0,0,4096);
  if(fadr=nil)then raise Exception.Create('Paylaşım alanı haritalanamadı');
//  if ZatenVar then showmessage('ZatenVar');
end;

destructor TPay.Destroy;
begin
  UnMapViewOfFile(fadr);
  CloseHandle(fhnd);
  inherited;
end;

end.
