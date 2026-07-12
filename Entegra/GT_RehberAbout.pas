unit GT_RehberAbout;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky, cxControls,
  cxContainer, cxEdit, cxLabel, cxGraphics, cxLookAndFeels, Variants,
  cxLookAndFeelPainters, UDestekdlg, PrjConst, FetaKurulusSiniflari, Dialogs,
  UGirisKutusuEx, WS_Destek, Soap.InvokeRegistry, Soap.Rio, SiteMarket,
  Soap.SOAPHTTPClient, dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  System.Net.URLClient;

type
  TAboutBox = class(TForm)
    Panel2: TPanel;
    Label1: TcxLabel;
    Panel3: TPanel;
    Label2: TcxLabel;
    Image1: TImage;
    Label3: TcxLabel;
    Button3: TButton;
    btnGuncellemeler: TButton;
    Button5: TButton;
    Label5: TcxLabel;
    TerminallerTus: TButton;
    MemoSQL: TMemo;
    btnRaporium: TButton;
    Label4: TcxLabel;
    BtnDestek: TButton;
    HTTPRIO1: THTTPRIO;
    BtnUnitTests: TButton;
    procedure btnGuncellemelerClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure TerminallerTusClick(Sender: TObject);
    procedure btnRaporiumClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnDestekClick(Sender: TObject);
    procedure BtnUnitTestsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses UVersiyon, UMailYaz, Utablo, UGenSifre, URaporium, LocOnFly, UUnitTests;

{$R *.DFM}
procedure TAboutBox.btnRaporiumClick(Sender: TObject);
begin
  Application.CreateForm(TRaporiumDlg, RaporiumDlg);
  RaporiumDlg.ShowModal;
  RaporiumDlg.Destroy;
end;

procedure TAboutBox.BtnDestekClick(Sender: TObject);
var
  Destek : DestekSoap;
  KayitKontrol: Boolean;
  MusteriKodu: Variant;
  Rehber: REH2;
  Kod,TeklifURL:String;
begin
  TeklifURL := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'http://genlisans.genyazilim.com')+':8090';
  Destek := GetDestekSoap(False,'http://'+TeklifURL+'/Destek/Destek.asmx?WSDL',HTTPRIO1);
  Tablo.TablodanSorguAc(1,'SELECT * FROM GENINI WHERE BOLUM='+IntToStr(Destekdlg_MusteriKodu));
  if Tablo.Query1.IsEmpty then begin
    if TGirisKutusuEx.BilgiAlEx(BGMusteri_kodu_gir, TGirdiDenetimleri.Create.Edit(BGMusteri_kodu, @MusteriKodu)) = mrOk then begin
      if Pos('-',MusteriKodu) > 0 then begin
        Kod := Copy(MusteriKodu,0,Pos('-',MusteriKodu)-1);
        Kod := Kod+'-'+Sifre(Kod);
        if Kod = MusteriKodu then begin
          Rehber := Destek.FirmaKontrol(MusteriKodu);
          if (Rehber <> nil) and (Rehber.ID > 0) then begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'INSERT INTO GENINI (BOLUM, ANAHTAR, DEGER, DIL, SIRA) '+
                       'VALUES(&BOLUM,&ANAHTAR,&DEGER,-1,1)',['&BOLUM','&ANAHTAR','&DEGER'],[Destekdlg_MusteriKodu,Rehber.FIRMA,Rehber.ID]);
          end
          else begin
            Application.MessageBox(PChar(ABMusteri_no_yok),PChar(Uyari),MB_OK);
            ModalResult := mrNone;
            Exit;
          end;
        end
        else begin
          Application.MessageBox(PChar(ABHatali_kod), PWideChar(PrjConst.Uyari), MB_OK);
          ModalResult := mrNone;
          Exit;
        end;
      end
      else begin
        Application.MessageBox(PChar(ABHatali_kod), PWideChar(PrjConst.Uyari), MB_OK);
        ModalResult := mrNone;
        Exit;
      end;
    end
    else
    begin
      ModalResult := mrNone;
      Exit;
    end;
  end;

  if Destekdlg = nil then Application.CreateForm(TDestekdlg, Destekdlg);
  Destekdlg.ShowModal;
  ModalResult := mrNone;
  FreeAndNil(Destekdlg);
end;

procedure TAboutBox.btnGuncellemelerClick(Sender: TObject);
begin
//  if Super then begin
    Application.CreateForm(TVersiyonDlg, VersiyonDlg);
    VersiyonDlg.ShowModal;
    VersiyonDlg.Destroy;
//   end
//   else
//      showmessage('Bu bölüme girmeye yetkili değilsiniz..');
end;

procedure TAboutBox.BtnUnitTestsClick(Sender: TObject);
begin
  StartTest;
end;

procedure TAboutBox.Button5Click(Sender: TObject);
begin
  WinExec('dxDiag', SW_SHOW);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);
  if Sektor in [Sektor_Cafe, Sektor_Rest] then
     Caption := 'GenoRes Restaurant Yönetim Sistemi';
end;

procedure TAboutBox.TerminallerTusClick(Sender: TObject);
{var
  Suan:TDateTime;
  MusNo:variant;
  i,DenemeLoginSay: Integer;
  resStream: TResourceStream;
  Etiketler, Bilgiler: TArrayOfString;
  ASiteMarketSoap:SiteMarketSoap;
  LisansliModuller:Moduller2;
  DBSidNumber:string; }
begin
  //Suan := Tablo.GENINI.BugunTrh;
  //if TGirisKutusuEx.BilgiAlEx(BGLisans_no_gir, TGirdiDenetimleri.Create.Edit(BGLisans_no_yetkili_ara, @MusNo)) = mrOk then begin
   // if MusNo <> '' then begin
      //try
      if Application.MessageBox(PChar(LisansSilinecek), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
        //ASiteMarketSoap := SiteMarket.GetSiteMarketSoap(False,'http://genlisans.genyazilim.com/Market/SiteMarket.asmx?WSDL',Tablo.HTTPRIOLisans);
        //LisansliModuller := ASiteMarketSoap.StockSelect1(VarToStr(MusNo),ServerSidNumber);
        //if (LisansliModuller <> nil) and (LisansliModuller.Hata = '') then begin
          VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from GENINI where BOLUM like ''-1009_''',[],[]);
          {Tablo.GENINI.WriteString(Ops_LsnsKurumKodu,VarToStr(MusNo));
          Tablo.GENINI.WriteString(Ops_Server_Sid_Number,ServerSidNumber);
          Tablo.GENINI.WriteDateTimeS(Ops_LsnsSKT,LisansliModuller.SKT.AsDateTime);
          Tablo.GENINI.WriteString(Ops_LsnsKulSay,UGenSifre.Sifre(IntToStr(LisansliModuller.LisansSayisi)));
          Tablo.GENINI.WriteDateTimeS(Ops_SonLsnsCtrlTarihi,Suan);
          Tablo.GENINI.WriteDateTimeS(Ops_SonrakiLsnsCtrlTarihi,Suan+LisansliModuller.LisansKontrolGun);
          Tablo.GENINI.WriteBoolean(Ops_LsnsGnclleme,LisansliModuller.Guncelleme);
          Tablo.GENINI.WriteInteger(Ops_DenemeLoginSay,0);
          for I := 0 to Length(LisansliModuller.ModulListesi)-1 do begin
            if LisansliModuller.ModulListesi[I].ModulDurumu then begin
              VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update MODUL set L=HashBytes(''SHA1'', '''+ServerSidNumber+'''+cast(MODULID as varchar(20))) where MODULID like '''+LisansliModuller.ModulListesi[I].OzelKod+'%'' ',[],[]);
              Tablo.GENINI.WriteString(Ops_DenemeLoginKalan,UGenSifre.Sifre('-1'));
              Tablo.GENINI.WriteString(Ops_DenemeLoginSay,UGenSifre.Sifre('-1'));
            end else
              VeriTabani.BasitKomutÇalıştır(Tablo.FDCnn,'update MODUL set L='''' where MODULID like '''+LisansliModuller.ModulListesi[I].OzelKod+'%'' ',[],[]);
          end;   }
          RestartProgram := True;
          Tablo.ProgramiSonlandir;
        end;
        //end else if LisansliModuller.Hata <> '' then begin
          //ShowMessage(LisansliModuller.Hata);
        //end;
      //except
        //on E: Exception do
         // ShowMessage(E.Message);
      //end;
    //end;
  //end;
end;

end.



