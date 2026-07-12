unit UDokumanKaydet;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, UTablo,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, Vcl.StdCtrls, cxButtons,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light;

type
  TDokumanKaydetDlg = class(TForm)
    uygulamaAdiLabel: TLabel;
    KapatTus: TcxButton;
    UstuneKaydetTus: TcxButton;
    RevizeKaydetTus: TcxButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure KapatTusClick(Sender: TObject);
    procedure RevizeKaydetTusClick(Sender: TObject);
    procedure UstuneKaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    DokumanId, Tur, GecmisId:Integer;
    DokumanAdi:String;
    DokumanTarih:TDateTime;
  end;

var
  DokumanKaydetDlg: TDokumanKaydetDlg;

implementation

{$R *.dfm}
uses prjconst, FetaKurulusSiniflari, UBinarySave, ULog, UVeriMotor;

procedure TDokumanKaydetDlg.RevizeKaydetTusClick(Sender: TObject);
var Kayit : boolean;
begin
   if DokumanTarih = FileAge(DokumanAdi) then
       showmessage('Dokümanda değişiklik yapılıp kaydedilmemiş!')
    else begin
        Tablo.TablodanSorguAc(8,' select D.ID, D.AD, I.SURUM, TARIH=I.DEGISTIRMETARIHI, SORUMLU=I.REHBERID, I.ONAYLAYACAK, I.ONAY from DOKUMAN D '+
            ' INNER JOIN IMAJ I ON I.ID = (select '+DbUst(1)+'ID from IMAJ where YERI=1 AND YER_ID=D.ID order by ID desc '+DbSinir(1)+') where D.ID='+IntToStr(DokumanId) );
        Kayit := Tablo.RevizeIslemleri(Tablo.Query8, DokumanAdi, Tablo.Query8.FieldByName('AD').asstring);
//        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANGECMIS where DOKUMANID=' + IntToStr(DokumanId) + ' and TUR=0 ', [], []);

       if Kayit then
           Tablo.DokumanTarihceEkle(DokumanID,Belge_revize, 1);

        Tablo.DokumanTarihceKapat(GecmisId, 1);
        KapatTus.Click;
        if Kayit then
           Showmessage(Kaydedildi);
    end;
end;

procedure TDokumanKaydetDlg.FormShow(Sender: TObject);
var s:string;
    isltipi:smallint;
begin
   DokumanTarih := FileAge(DokumanAdi);
   UstuneKaydetTus.Visible := Tur > 1;
   RevizeKaydetTus.Visible := Tur = 3;

   Tablo.DokumanTarihceEkle(DokumanID,Belge_goruldu, 2);
end;

procedure TDokumanKaydetDlg.KapatTusClick(Sender: TObject);
var s:string;
    isltipi:smallint;
begin
//   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANGECMIS where DOKUMANID=' + IntToStr(DokumanId) + ' and TUR=0 ', [], []);

   if Tur=1 then
      Tablo.DokumanTarihceKapat(GecmisId, 2);
   //Tablo.DokumanTarihceEkle(DokumanID,'Belge kilitlendi ',0);
//   Tablo.DokumanBildirimDuyuruAc(Tur, DokumanID, DokumanAdi);
      Tablo.TablodanSorguAc(9,'SELECT REHBERID FROM DOKUMANBILDIRIM WHERE DOKUMANID='+inttostr( DokumanID));
      Tablo.DuyuruYayinla(Tablo.Query9, 'Doküman Görme / '+DokumanAdi, '"'+DokumanAdi+'" dokümanı üzerinde '+ DateTimeToStr ( Tablo.GENINI.BugunTrhSaat) + ' tarihinde "'+KullanAdi+'" kullanıcısı tarafından görme işlemi gerçekleştirilmiştir.');
   close;

{   if (DokumanAdi='')or(DeleteFile(DokumanAdi)) then
      close
   else
      RaiseLastOSError
   }
end;

procedure TDokumanKaydetDlg.UstuneKaydetTusClick(Sender: TObject);
//var DokumanImajId : integer;
begin
    if DokumanTarih = FileAge(DokumanAdi) then
       showmessage('Dokümanda değişiklik yapılıp kaydedilmemiş!')
    else begin
        Tablo.TablodanSorguAc(1, 'select max(ID) from IMAJ where YERI=1 and YER_ID='+IntToStr(DokumanId)); //revizeler varsa son dokümana kayıt etsin

        Tablo.Query0.Close;
        // YENI: icerigi ONCE DOSYA deposuna guncelle (mode'dan BAGIMSIZ; ekleme de her modda
        //  DOSYA'ya gidiyor -> duzenleme de gitmeli). UstuneKaydet UPDATE oldugundan KutugeYaz
        //  DOSYA'ya yonlenmez; klasor modunda ise DOSYAID'yi bayat birakip eski icerigi
        //  gosterirdi. DOSYA yoksa (FILESTREAM kapali) eski mode-bazli yola dus.
        if not ULog.DosyaIleImajGuncelle(Tablo.Query1.Fields[0].AsInteger, DokumanAdi, Kullanan) then begin
           if Dokuman_Kayit_Yeri=0 then begin
              Tablo.Query0.SQL.Text := 'update IMAJ set ICDIS=0, DEGISTIRMETARIHI=getdate(), DEGISTIREN='+Kullanan+', BELGE=:PBelge, DOSYAID=NULL where ID='+ Tablo.Query1.Fields[0].AsString;
              KutugeYaz(Tablo.Query0, DokumanAdi);
           end else begin
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update IMAJ set ICDIS=1, DEGISTIRMETARIHI=getdate(), DEGISTIREN='+Kullanan+', DOSYAID=NULL where ID='+ Tablo.Query1.Fields[0].AsString, [], []);
              Tablo.BelgeEkleme(DokumanAdi, -99, 1, Tablo.Query1.Fields[0].AsInteger, nil);
           end;
        end;
//        Tablo.DokumanTarihceEkle(DokumanId,'Belge değiştirildi',5);
//        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DOKUMANGECMIS where DOKUMANID=' + IntToStr(DokumanId) + ' and TUR=0 ', [], []);
        Tablo.DokumanTarihceEkle(DokumanID,Belge_degisti, 5);
        Tablo.DokumanTarihceKapat(GecmisId, 5);
        KapatTus.Click;
        Showmessage(Kaydedildi);
    end;
end;

end.


