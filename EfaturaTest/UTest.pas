unit UTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit;

type
  TTablo = class(TForm)
    cxTextEdit1: TcxTextEdit;
    cxButton1: TcxButton;
    cxComboBox1: TcxComboBox;
    Ent_Sifre1: TcxTextEdit;
    Ent_Kullanici1: TcxTextEdit;
    Ent_Addr1: TcxTextEdit;
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
    function EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string):smallint;
  public
    { Public declarations }
  end;

var
  Tablo: TTablo;
  EFaturaKullanimda : Smallint;
  Ent_Kullanici, Ent_Sifre, Ent_Addr : String;
implementation

{$R *.dfm}

uses Gentegre.UI.EFatura.FirmaAra;

procedure TTablo.cxButton1Click(Sender: TObject);
var sonuc : integer;
begin
   Ent_Kullanici := Ent_Kullanici1.Text;
   Ent_Sifre := Ent_Sifre1.Text;
   Ent_Addr := Ent_Addr1.Text;
   sonuc := EFaturami(1,true, cxTextEdit1.text);
   showmessage(IntToStr(sonuc));
end;



function TTablo.EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string):smallint;
var
   //Etiketler, Bilgiler: TArrayOfString;
   fa : TEFaturaFirmaAra;
   Function BireyKurum(Birey, Kurum : smallint) : smallint;
   begin
         if Length(VNO) = 10 then //þirketse
         Result := Kurum
      else if Length(VNO)=11 then //þahýs ise
         Result := Birey;
  end;
begin   //  EFaturaKullanimda 0:yok 1:e-fat 11:e-fat + e-arþ
   EFaturaKullanimda := 1;
   Result := 0;
   VNo := StringReplace( Vno, ' ','',[rfReplaceAll]);
   if not (Length(VNo) in [10,11]) then begin
      //UyariGoster(Uyari,'Geçersiz Vergi No! Faturayý Ýptal edin; Vergi No düzeltip tekrar deneyin!',1);
      showmessage('Geçersiz Vergi No! Faturayý Ýptal edin; Vergi No düzeltip tekrar deneyin!');
      exit;
   end;

           (*
   if EFaturaKullanimda=0 then
      exit
   else if CarideEFatura then begin//caride efatura kullanýyor iþaretliyse direk kurum için 1, þahýs için 21 yazýp geçelim
         Result := BireyKurum(21, 1);
         exit;
   end;  *)

//   Tablo.RehberEkBilgileriniGetir(RehID, 2, [RehVars_Vergi_No], Etiketler, Bilgiler);
//   VNo := StringReplace( Bilgiler[0], ' ','',[rfReplaceAll]);


    FAddr := Ent_Addr;
    fa := TEFaturaFirmaAra.Create(nil);
    fa.KullaniciAdi := Ent_Kullanici;//'sahinleryapi';
    fa.Sifre := Ent_Sifre;//'SHN102030Q';
    try
    if fa.FirmaVarMi(VNo) then //entegratör firmadan tarama yaparýz
       Result := 1
    else
       Result := 0;
    except                     ////entegratör firmaya baðlanamazsak veri tabanýndan tarama yaparýz
//      if 'SELECT * FROM EFATURA.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''',[],[]) then
      //26/03/2021 AO EFATURA veri tabanýndan bulunan, INSTITUTIONS tablosuna, InvoiceType eklenmiþtir.
      // 1 -> E-Fatura mükellefi, 2 -> E-Ýrsaliye mükellefi, 3 -> E-Arþiv mükellefi
(*      TablodanSorguAc(1, 'SELECT * FROM '+EFaturaDB+'.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''');
      if Tablo.Query1.RecordCount > 0 then begin
         if trim(Tablo.Query1.FieldByName('InvoiceType').AsString) = '1' then  //Alias arþiv iþarteli ise
            Result := 1
         else
            Result := 0
      end
      else
         Result := 0; *)
    end;
    fa.Free;

(*    if Result = 1 then begin //  sorgu dolu dönmüþse caride e-faturalý diye iþaretle
       Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, ' update REHBER set EFATURA = 1 where ID = '+IntToStr(RehID) ,[],[]);
       Result := BireyKurum(21, 1);
    end else if Result = 0 then  //  sorgu boþ dönmüþse
       case EFaturaKullanimda of
        1 : ; //eðer sadece efat kullanýlýyor ve  kaðýt fat demektir
        11: //eðer efat + earþ kullanýlýyor ise bakarýz
              Result := BireyKurum(31, 11);
       end;               *)
end;


end.
