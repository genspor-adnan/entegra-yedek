unit UPaketDetayV2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls ,PackageDetailV2Svc,SOAPHTTPClient;

type
  TPaketDetayV2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure PaketDetayGetir;
  public
    { Public declarations }
  end;

var
  PaketDetayV2: TPaketDetayV2;




implementation

uses UTablo;


{$R *.dfm}

procedure TPaketDetayV2.Button1Click(Sender: TObject);
begin
//






end;

procedure TPaketDetayV2.PaketDetayGetir;
var
PaketDetay :  PackageDetail;
PaketDetayCevap : packageDetailResponse;
PaketDetayIstek : packageDetailRequest;
Http :THTTPRIO;
begin

 {
  PaketDetayIstek := packageDetailRequest.Create;
  PaketDetayIstek.startDate    := FormatDateTime('yyyy-MM-dd',FBelgeTarihi); //Baþlangýç Tarihi
  PaketDetayIstek.endDate      := //Bitiþ Tarihi
  PaketDetayIstek.bringNotReceivedTransferInfo :=  //Daha önce alýnmýþ paketlerin cevaba dahil edilmesini saðlar. True
  PaketDetayIstek.sender       :=  //Gönderen paydaþ gln
  PaketDetayIstek.receiver     :=  //Alan paydaþ gln



  //ITSHesapBilgileriGetir(ITSHesapID);
  Http := THTTPRIO.Create(nil);
  Http.HTTPWebNode.OnBeforePost := Tablo.GenericPTSHTTPReqRespBeforePost ;
  PaketDetay := GetPackageDetail(False,'http://its.saglik.gov.tr/ReferenceServices/Stakeholder',Http);
   try
     PaketDetayCevap:=PaketDetay.receivePackageDetails(PaketDetayIstek);
   except
      on e: exception do begin
        Abort;
      end;
   end;


       }



//
end;

end.
