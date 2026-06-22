unit UMekanMasaGor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, FireDAC.Comp.Client, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons,
  dxSkinsCore, cxControls, cxContainer, cxEdit, cxLabel, dxSkinLondonLiquidSky,
  ComCtrls, cxListView, cxListBox, JvExControls, JvButton, JvNavigationPane, cxImage, ExtCtrls, JvExComCtrls, JvDateTimePicker,
  cxGraphics, cxLookAndFeels, JvMenus, JvTimer, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, frxClass, frxDBSet, cxTimeEdit,
  cxCurrencyEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxDBEdit,
  cxTextEdit, cxMemo, cxCheckBox, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, cxButtonEdit,
  cxCalendar, dxCore, cxDateUtils;

type
  TShape = class(ExtCtrls.TShape); //interposer class
  TMekanMasaGorDlg = class(TForm)
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    RezervasyonTus: TJvNavPanelButton;
    PaketTus: TJvNavPanelButton;
    RezTarih: TJvDateTimePicker;
    MasaTus: TJvNavPanelButton;
    JvPopupMenu1: TJvPopupMenu;
    MasaDegistirMenu: TMenuItem;
    N2: TMenuItem;
    MasaBirlestirMenu: TMenuItem;
    MasaAyirMenu: TMenuItem;
    JvPopupMenu2: TJvPopupMenu;
    SubeSecimMenu: TMenuItem;
    StatusBar1: TStatusBar;
    JvTimer1: TJvTimer;
    PanelBirlesen: TJvNavPanelHeader;
    SonTus: TJvNavPanelButton;
    DtsSiparis: TDataSource;
    TabSiparis: TFDQuery;
    frxAktiviteRapor: TfrxDBDataset;
    PanelPaket: TPanel;
    PanelPaketBaslik: TJvNavPanelHeader;
    YeniTus: TJvNavPanelButton;
    DuzenleTus: TJvNavPanelButton;
    SilTus: TJvNavPanelButton;
    PaketTarih: TJvDateTimePicker;
    gridSiparis: TcxGrid;
    tvSiparis: TcxGridDBTableView;
    gridSiparisLevel1: TcxGridLevel;
    tvSiparisID: TcxGridDBColumn;
    tvSiparisSiparisNo: TcxGridDBColumn;
    tvSiparisMusteri: TcxGridDBColumn;
    tvSiparisSaat: TcxGridDBColumn;
    tvSiparisSure: TcxGridDBColumn;
    tvSiparisCikisSaati: TcxGridDBColumn;
    tvSiparisTutar: TcxGridDBColumn;
    tvSiparisDurum: TcxGridDBColumn;
    tvSiparisKurye: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    JvNavPanelButton1: TJvNavPanelButton;
    KuryeTus: TJvNavPanelButton;
    TahsilatTus: TJvNavPanelButton;
    PanelAlt: TPanel;
    Label8: TLabel;
    cxDBMemo1: TcxDBMemo;
    MemoAdres: TcxDBMemo;
    cxLabel3: TLabel;
    cxLabel4: TLabel;
    cxLabel5: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    cxLabel2: TLabel;
    cxDBImageComboBox1: TcxDBButtonEdit;
    cxDBTextEdit1: TcxDBButtonEdit;
    CheckTumListe: TcxCheckBox;
    MemoPaketSQL: TMemo;
    IptalTus: TJvNavPanelButton;
    cxLabel1: TLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxLabel6: TLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    ZeminResim: TcxImage;
    tvSiparisTeslimTarihi: TcxGridDBColumn;
    cxDBMemo3: TcxDBMemo;
    cxLabel7: TLabel;
    cxLabel9: TLabel;
    Label1: TLabel;
    DateTeslim: TcxDateEdit;
    Panel2: TPanel;
    Panel1: TPanel;
    PopupMenuSiparis: TJvPopupMenu;
    TumListeyi: TMenuItem;
    MterikartnSil1: TMenuItem;
    N1: TMenuItem;
    procedure MekanMasaCreate;
    procedure MekanMasaDestroy;
    procedure MekanListele(SecSubeId:Integer);
    function  MekanIdBul(mekan:string):integer;
    procedure FormShow(Sender: TObject);
    procedure IsimGiris;
    procedure Shape1Click(Sender: TObject);
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure MekanClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure PaketTusClick(Sender: TObject);
    procedure RezervasyonTusClick(Sender: TObject);
    procedure RezTarihChange(Sender: TObject);
    procedure MasaDegistirMenuClick(Sender: TObject);
    procedure MasaBirlestirMenuClick(Sender: TObject);
    procedure SonTusClick(Sender: TObject);
    procedure MasaAyirMenuClick(Sender: TObject);
    procedure JvPopupMenu2Popup(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure PaketTarihChange(Sender: TObject);
    procedure DuzenleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KuryeTusClick(Sender: TObject);
    procedure TabSiparisAfterOpen(DataSet: TDataSet);
    procedure IptalTusClick(Sender: TObject);
    procedure cxDBMemo3Click(Sender: TObject);
    procedure cxDBMemo1Click(Sender: TObject);
    procedure cxDBTextEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxDBImageComboBox1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure MemoAdresClick(Sender: TObject);
    procedure DateTeslimPropertiesCloseUp(Sender: TObject);
    procedure tvSiparisSelectionChanged(Sender: TcxCustomGridTableView);
    procedure TumListeyiClick(Sender: TObject);
    procedure MterikartnSil1Click(Sender: TObject);
  private
     SeciliSekil : TShape;
     //BirlesikEnKucukSekil : TJvNavPanelButton;
     MasaAksiyon : Smallint; //1:masa a?ma 2:rez 3:de?i?tirme 4:birle?tirme
     function MasaBilgiGetir(Query1:TFDQuery):string;
     function MasaBul(MasaNo:SmallInt):TShape;
//     procedure MasaNoYaz(SeciliSekil:TShape);
     procedure MasaBosalt;

    { Private declarations }
  public
     { Public declarations }
  end;

  TLabelShape = class(TShape)
  private
    FCaption: string;
      procedure SetCaption(const Value: string);
  protected
    procedure Paint; override;
  published
    property Caption: string read FCaption write SetCaption;
  end;

var
  MekanMasaGorDlg: TMekanMasaGorDlg;

implementation

uses UMekanMasaDizayn, UMasaSor, Utablo, UHizliGiris,FetaKurulusSiniflari, PrjConst, UHizliGirisAnaMenu,
     URezervasyon, Fetautil,UKullaniciGiris, UCallerId, UResim, UGirisKutusuEx;

{$R *.dfm}

var
  d,KisiSaySor, RezervasyonVar, CheckGarsonAdi,CheckKisiSay,CheckAcilisZamani,CheckGecenZaman,CheckMasaTutar  :boolean;
  MekanID,GarsonAdiSor,BirlesNo :integer;  //,BirlesenDoluMasaMinNo
  BirlesenDoluMasaList, MasaBilgiList : TStringList;
  RenkMasaBos,RenkMasaDolu,RenkMasaRezerve,RenkMasaHesap, RenkMasaBirles : TColor;

procedure TMekanMasaGorDlg.MasaBosalt;
var i : SmallInt;
    BirlesimNo : smallint;
begin
    //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0,GARSON=0,KISISAY=0,TUTAR=0.0,BIRLESIM=null where BIRLESIM='+IntToStr(SeciliSekil.HelpContext),[],[]);
    //e?er birle?ik masa ise t?m masalar bo? hale getirilir
    if SeciliSekil.HelpContext > 0 then begin// birle?ik masa ise
       BirlesimNo := SeciliSekil.HelpContext;//bu birle?im numars?n? al?p
       for i:=0 to ComponentCount-1 do       // dola?arak renkleri de?i?tirelim
            if (Components[i] is TShape)and(TShape(Components[i]).HelpContext=BirlesimNo)  Then begin
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0,GARSON=0,KISISAY=0,TUTAR=0.0,BIRLESIM=null where ID='+IntToStr(TShape(Components[i]).Tag),[],[]);
               TShape(Components[I]).Brush.Color := RenkMasaBos;
               TShape(Components[I]).HelpContext := 0 ;
            end
    end else begin //tek masa ise
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0,GARSON=0,KISISAY=0,TUTAR=0.0 where ID='+IntToStr(SeciliSekil.Tag),[],[]);
       SeciliSekil.Brush.Color := RenkMasaBos;
    end;
end;

procedure TMekanMasaGorDlg.Shape1Click(Sender: TObject);
var i, sonuc : SmallInt;
   function RezervasyonIslemi : SmallInt;
   begin
      Application.CreateForm(TRezervasyonDlg, RezervasyonDlg);
      if SeciliSekil.Brush.Color = RenkMasaRezerve then
         RezervasyonDlg.RezID := 0 //rez var
      else
         RezervasyonDlg.RezID := -1;//rez yok yeni yap?lacak
      RezervasyonDlg.Tarih := RezTarih.Date;
      RezervasyonDlg.MekanID := MekanID;
      RezervasyonDlg.MasaID := SeciliSekil.Tag;
      RezervasyonDlg.MasaNo := SeciliSekil.Hint;
      RezervasyonDlg.RehberID := VarsMusteri;
      RezervasyonDlg.ShowModal;
      Result := RezervasyonDlg.TabRezervasyon.FieldByName('DURUM').AsInteger;
      case Result of
       0,3: begin //rezerve d???ndaki durumlar (0:gelmedi 1:geldi 2:rezerve 3 :iptal edildi)
             SeciliSekil.Brush.Color := RenkMasaBos;
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0 where ID='+IntToStr(SeciliSekil.Tag),[],[]);
           end;
       2 : begin  //rezerve edildi
             SeciliSekil.Brush.Color := RenkMasaRezerve;
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=2 where ID='+IntToStr(SeciliSekil.Tag),[],[]);
           end;
      end;
      RezervasyonDlg.Destroy;
      //rezervasyonyap?ld? normal moda ge?elim
      RezervasyonTus.Down := False;
      RezervasyonTusClick(Self);
   end;

   procedure BirlesikMasalariEskiDurumunaGetir;
   var i: smallint;
   begin
      for i:=0 to ComponentCount-1 do
        if (Components[i] is TShape)and(TShape(Components[i]).Brush.Color = RenkMasaBirles)  Then begin
            TShape(Components[i]).Brush.Color := RenkMasaBos;
            TShape(Components[i]).HelpContext := 0;
            //MasaNoYaz(TShape(Components[i]));
        end;
   end;

   procedure PaneldeMasaOlustur(SeciliSekil : TShape);
   var btn: TJvNavPanelButton;
   begin
        btn:= TJvNavPanelButton.Create(PanelBirlesen);
        with btn do
        begin
          Name := 'btn'+SeciliSekil.Name;
          Tag := SeciliSekil.Tag;//masaId
          Parent := PanelBirlesen;
          Caption := SeciliSekil.Hint;
          Align:=alLeft;
          colors.ButtonColorFrom := SeciliSekil.Brush.Color;
          Left := 1500;
          Width := 100;
        end;
   end;
begin
   SeciliSekil := TShape(Sender);
   case MasaAksiyon of
     1: if SeciliSekil.Brush.Color = RenkMasaRezerve then  //normal durumdayken rezerv olan masaya t?klan?rsa
           Sonuc := RezervasyonIslemi
        else
           Sonuc := 1;
     2: Sonuc := RezervasyonIslemi; //rezervasyon
     3:begin
         if OncekiMasaId=0 then begin
            OncekiMasaId := SeciliSekil.Tag;
            StatusBar1.Panels[3].Text := 'Yeni masay? se?in';  //de?i?tirme
         end else begin
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=1 where ID='+IntToStr(SeciliSekil.Tag),[],[]);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0 where ID='+IntToStr(OncekiMasaId),[],[]);
            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set FATURATARIH='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',DURUM=0, LOKASYON='+IntToStr(SeciliSekil.Tag)+',OZELKOD='''+SeciliSekil.Hint+''' where ID=(select top 1 ID from FATBASLIK where TUR=110 and LOKASYON='+IntToStr(OncekiMasaId)+' order by ID desc) ',[],[]);
            //EskiSeciliSekil.Brush.Color := RenkMasaBos; //me?gul
            //?imdiki masan?n rengini dolu yapal?m
            SeciliSekil.Brush.Color := RenkMasaDolu; //me?gul
            //Eski masa bo? renk olsun
            SeciliSekil := MasaBul(OncekiMasaId);
            OncekiMasaId:=0;
            MasaAksiyon := 1;
            StatusBar1.Panels[3].Text := '';
         end;
         exit;
      end;
     4: begin //Birle?tir
         if SeciliSekil.HelpContext = 0 then begin //masa birle?ik de?ilse
            {if BirlesNo = 0 then begin//Birle?meye ?imdi ba?l?yor numara alal?m
               Tablo.TablodanSorguAc(1,'select isnull(max(BIRLESIM),0)+1 from MASALAR');
               BirlesNo := Tablo.Query1.Fields[0].AsInteger;
               if BirlesenDoluMasaList=nil then
                  BirlesenDoluMasaList := TStringList.Create
               else
                  BirlesenDoluMasaList.clear;
               BirlesenDoluMasaMinNo:=9999;
            end; }
            //if SeciliSekil.Brush.Color = RenkMasaDolu then begin//birle?en masa doluysa bir string liste alal?m ki daha sonra adisyonlar?n? tek masada toplayal?m
               PaneldeMasaOlustur(SeciliSekil);
               //BirlesenDoluMasaList.add(IntToStr(SeciliSekil.Tag));
               //if SeciliSekil.Tag<BirlesenDoluMasaMinNo then
               //   BirlesenDoluMasaMinNo:= SeciliSekil.Tag; //birle?en dolu masalardan en k???k masa noyu tutmam laz?m; ??nk? o masa ?zerinde t?m adisyonlar toplanacak
            //end;
           // SeciliSekil.HelpContext := BirlesNo;
           // SeciliSekil.Brush.Color := RenkMasaBirles; //
           // if (BirlesikEnKucukSekil = nil)or(SeciliSekil.Tag < BirlesikEnKucukSekil.Tag) then
           //     BirlesikEnKucukSekil := SeciliSekil;
            //MasaNoYaz(SeciliSekil);
         end
         else
            showmessage('Birle?ik olan masa tekrar birle?mez!');
         exit;
       end;
     5: begin  //Ay?rma
            MasaAksiyon := 1;
            StatusBar1.Panels[3].Text := '';
            if SeciliSekil.HelpContext > 0 then begin //masa birle?ikse
               //ayr?lan masa en k???k ID olan m?, e?er enk???kse hesap bir b?y?k masa ?zerine ge?meli
               Tablo.TablodanSorguAc(1,'select top 2 ID, MASANO from MASALAR where BIRLESIM='+IntToStr(SeciliSekil.HelpContext)+' order by ID');
               if Tablo.Query1.Recordcount>1 then begin //tek masadan fazla ise
                   if Tablo.Query1.Fields[0].asInteger=SeciliSekil.Tag then begin //en k???kse
                      Tablo.Query1.next;//bir sonraki masa
                      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set LOKASYON='+Tablo.Query1.Fields[0].asstring+',OZELKOD='''+Tablo.Query1.Fields[1].asstring+''' where TUR=110 and LOKASYON='+IntToStr(SeciliSekil.Tag)+' and DURUM=0 ',[],[]);
                   end;
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set BIRLESIM=null where ID='+IntToStr(SeciliSekil.Tag),[],[]);
                   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=0 where ID='+IntToStr(SeciliSekil.Tag),[],[]);
                   SeciliSekil.HelpContext := 0;
                   SeciliSekil.Brush.Color := RenkMasaBos; //
                   //MasaNoYaz(SeciliSekil);
               end
               else
                   showmessage('Tek masa kalm??!');
            end;
            exit;
       end;
   end;

   if sonuc = 1 then begin   //Birle?ik masalar isehesap en k???k masa ID si?zerindeddir

      Application.CreateForm(THizliGirisDlg,HizliGirisDlg);

       //bir defa soracaksa masa bo?sa sorsun veya her defas?nda garsonu sorsun
       if ((GarsonAdiSor=1)and(SeciliSekil.Brush.Color = RenkMasaBos))or(GarsonAdiSor=2)
           or((GarsonAdiSor=1)and(SeciliSekil.Brush.Color = RenkMasaBirles)) then begin  // and(BirlesenDoluMasaList.Count=0)
          if not HizliGirisDlg.KullaniciSor then begin
             if SeciliSekil.Brush.Color = RenkMasaBirles then
                BirlesikMasalariEskiDurumunaGetir;
             FreeAndNil(HizliGirisDlg);
             Exit;
          end;
       end;

       if SeciliSekil.Brush.Color = RenkMasaBos then begin
          //masa bo? ve doluyor. Bu masayla ilgili a??k adisyon varsa kapat?l?r.
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set DURUM=1 where TUR=110 and DURUM=0 and LOKASYON='+IntToStr(SeciliSekil.Tag),[],[]);
          if KisiSaySor then
             HizliGirisDlg.EditKisiClick(Self)
          else
             HizliGirisDlg.EditKisi.Caption:='0';
       end;

       if  SeciliSekil.HelpContext > 0 then begin//e?er birle?mi? masa dolu hesap olan masa/lar var ise
           {if SeciliSekil.Brush.Color = RenkMasaBirles then
              MasaBirlestir;

           if (BirlesenDoluMasaList<>nil)and(BirlesenDoluMasaList.Count > 0) then
              MasaHesapBirlestir;}

           // birle?ik masa ise en k???k masa IDsini bulal?m
           Tablo.TablodanSorguAc(1,'select min(ID) from MASALAR where BIRLESIM='+IntToStr(SeciliSekil.HelpContext));
           SeciliSekil := MasaBul(Tablo.Query1.Fields[0].asInteger);
       end;

       HizliGirisDlg.Cagiran := 7;
       HizliGirisDlg.MasaID := SeciliSekil.Tag;
       HizliGirisDlg.MasaNo := SeciliSekil.Hint;
       if SeciliSekil.Brush.Color = RenkMasaBos
        then begin
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=1, GARSON='+IntToStr(KullananID)+',GARSONKOD='''+HizliGirisDlg.KullanKod+''',KISISAY='+HizliGirisDlg.EditKisi.Caption+', EKLEME_TARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''' where ID='+IntToStr(SeciliSekil.Tag),[],[]);
          SeciliSekil.Brush.Color := RenkMasaDolu; //me?gul
       end;
       HizliGirisDlg.ShowModal;
       if (HizliGirisDlg.TabFatBasDetay.FieldByName('DURUM').AsInteger=DefSiparisTahsil)or(HizliGirisDlg.TabDetay.RecordCount < 1) then //hi? giri? yap?lmam??sa tekrar beyaz yapal?m
          MasaBosalt
       else
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set TUTAR='+StringReplace(FloatToStr(HizliGirisDlg.EditToplamTutar.Value), ',','.',[])+', DEGISTIRME_TARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''' where ID='+IntToStr(SeciliSekil.Tag),[],[]);

       //Masa bilgilerini se?ili ?ekil ?zerine y?kleyelim
       Tablo.TablodanSorguAc(1,'select M.* from MASALAR M where M.ID='+inttostr(SeciliSekil.Tag));
       SeciliSekil.HelpKeyword := MasaBilgiGetir(Tablo.Query1);

       SeciliSekil := nil;
       FreeAndNil(HizliGirisDlg);
   end;

   (*for i:=0 to ComponentCount-1 do
        if (Components[i] is TShape)  Then
           MasaNoYaz(TShape(Components[I]));*)
        {MasaSorDlg.Label1.Caption:= TShape(Sender).name;
        MasaSorDlg.Label6.Caption:=label1.Caption;
        MasaSorDlg.ShowModal;}

end;

procedure TMekanMasaGorDlg.Shape1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
   //Tcontrol(Sender).SetFocus;
end;

procedure TMekanMasaGorDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Tablo.KasaSilmeIslemleri(TabSiparis.Fields[0].AsInteger,110);
      PaketTarihChange(Self);
   end;
end;

function  TMekanMasaGorDlg.MekanIdBul(mekan:string):integer;
begin
    Tablo.TablodanSorguAc(1,'select DEGER from GENINI where BOLUM=-4444 and ANAHTAR='''+mekan+''' ');
    result:= Tablo.Query1.FieldByName('DEGER').AsInteger;
end;

procedure TMekanMasaGorDlg.MasaAyirMenuClick(Sender: TObject);
begin
   MasaAksiyon := 5;
   StatusBar1.Panels[3].Text := 'Ayr?lacak masay? se?in!';
end;

procedure TMekanMasaGorDlg.MasaBirlestirMenuClick(Sender: TObject);
begin
   MasaAksiyon := 4;
   BirlesNo := 0;
   PanelBirlesen.Visible := True;
   RezervasyonTus.Visible := False;
   MasaTus.Visible := False;
   //BirlesikEnKucukSekil := nil;
   StatusBar1.Panels[3].Text := 'Masalar? se?in, Bitince "Son"a bas?n !';
end;

procedure TMekanMasaGorDlg.MasaDegistirMenuClick(Sender: TObject);
begin
   MasaAksiyon := 3;
   StatusBar1.Panels[3].Text := '?nceki masay? se?in!';
end;

//procedure TMekanMasaGorDlg.MasaNoYaz(Sender: TObject);///(SeciliSekil:TShape);
(*procedure TLabelShape.Paint;
var i : smallint;
    SeciliSekil:TShape;
begin
    inherited Paint;
    SeciliSekil.Refresh;
    SeciliSekil.Canvas.Font.Name :='Arial';// set the font
    SeciliSekil.Canvas.Font.Size  :=16;//set the size of the font
    SeciliSekil.Canvas.Font.Color:=clBlack;//set the color of the text
    SeciliSekil.Canvas.TextOut(10,5,SeciliSekil.Hint);
    SeciliSekil.Canvas.Font.Size := 10;
    if SeciliSekil.Brush.Color = RenkMasaDolu then begin
        ParcalaPar('@', SeciliSekil.HelpKeyWord, MasaBilgiList);
        i:= 15;
        if CheckKisiSay then
           begin inc(i,15); SeciliSekil.Canvas.TextOut(10,i,MasaBilgiList.Strings[1]); end;
        if CheckGarsonAdi then //garson,ki?i,a??l??,ge?en,tutar
           SeciliSekil.Canvas.TextOut(30,i,MasaBilgiList.Strings[0]);
        if CheckAcilisZamani then
           begin inc(i,15); SeciliSekil.Canvas.TextOut(10,i,MasaBilgiList.Strings[2]); end;
        if CheckGecenZaman then
           begin  SeciliSekil.Canvas.TextOut(50,i,MasaBilgiList.Strings[3]); end;
        if CheckMasaTutar then
           begin inc(i,15); SeciliSekil.Canvas.TextOut(10,i,MasaBilgiList.Strings[4]); end;
    end;
    SeciliSekil.Canvas.Font.Size :=12;//set the size of the font
    inc(i,15);
    if SeciliSekil.HelpContext>0 then
       SeciliSekil.Canvas.TextOut(12,80,'<><>'+IntToStr(SeciliSekil.HelpContext));

end; *)

procedure TLabelShape.Paint;
var i : smallint;
begin
    inherited Paint;
    Canvas.Font.Name :='Arial';// set the font
    Canvas.Font.Size  :=16;//set the size of the font
    Canvas.Font.Color:=clBlack;//set the color of the text
    Canvas.TextOut(10,5,Hint);
    Canvas.Font.Size := 10;
    if Brush.Color = RenkMasaDolu then begin
        ParcalaPar('@', HelpKeyWord, MasaBilgiList);
        i:= 15;
        if (CheckKisiSay)and(MasaBilgiList.Count>1) then
           begin inc(i,15); Canvas.TextOut(10,i,MasaBilgiList.Strings[1]); end;
        if (CheckGarsonAdi)and(MasaBilgiList.Count>0) then //garson,ki?i,a??l??,ge?en,tutar
           Canvas.TextOut(30,i,MasaBilgiList.Strings[0]);
        if (CheckAcilisZamani)and(MasaBilgiList.Count>2) then
           begin inc(i,15); Canvas.TextOut(10,i,MasaBilgiList.Strings[2]); end;
        if (CheckGecenZaman)and(MasaBilgiList.Count>3) then
           begin  Canvas.TextOut(50,i,MasaBilgiList.Strings[3]); end;
        if (CheckMasaTutar)and(MasaBilgiList.Count>4) then
           begin inc(i,15); Canvas.TextOut(10,i,MasaBilgiList.Strings[4]); end;
    end;
    Canvas.Font.Size :=12;//set the size of the font
    inc(i,15);
    if HelpContext>0 then
       Canvas.TextOut(12,80,'<><>'+IntToStr(HelpContext));

end;

procedure TLabelShape.SetCaption(const Value: string);
begin
  FCaption := Value;
  Refresh;
end;

function TMekanMasaGorDlg.MasaBilgiGetir(Query1:TFDQuery):string;
begin
    Result:= Tablo.Query1.FieldByName('GARSONKOD').asstring+
          '@'+Tablo.Query1.FieldByName('KISISAY').asstring+
          '@'+FormatDatetime('hh:nn', Tablo.Query1.FieldByName('EKLEME_TARIHI').asdatetime)+
          '@'+FormatDatetime('hh:nn',Tablo.Genini.BugunTrhSaat-Tablo.Query1.FieldByName('EKLEME_TARIHI').asdatetime)+
          '@'+Format('%m',[Tablo.Query1.FieldByName('TUTAR').AsCurrency]); //
end;

procedure TMekanMasaGorDlg.MekanMasaCreate;
var
    //yeni:TShape;
    GarsonLabel:TcxLabel;
    i,w,h:integer;
    s:string;
begin
   ResimGetir(-4444, 121, MekanID, ZeminResim);

   if RezervasyonVar then //e?er rezervasyon kullan?l?yorsa rezerveyi i?aretlemek i?in rezervasyon tablosuna da bakmak laz?m
      Tablo.TablodanSorguAc(1,'select M.*, REZID=isnull(R.ID, 0) from MASALAR M '+
           ' left outer join REZERVASYON R on M.ID = R.MASAID and R.DURUM=2 and R.TARIH between '''+FormatDateTime('yyyy-mm-dd 00:00',RezTarih.date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59',RezTarih.date)+''''+
//           ' left outer join FATBASLIK FB on FB.LOKASYON=R.MASAID  and FB.TUR=110  and FB.DURUM=0 '+ KISISAY=FB.ZARFID,  ,FB.FATURA_TUTARI
           ' where M.MEKAN= '+inttostr(MekanID))
   else
      Tablo.TablodanSorguAc(1,'select M.*,REZID=0 from MASALAR M where M.MEKAN='+inttostr(MekanID));

    while not Tablo.Query1.eof do begin
     SeciliSekil :=  TLabelShape.Create(MekanMasaGorDlg);
     with SeciliSekil do begin
       Parent := ZeminResim;
       Name:='M'+Tablo.Query1.FieldByName('ID').AsString;
       Hint:=Tablo.Query1.FieldByName('MASANO').AsString;
       Tag := Tablo.Query1.FieldByName('ID').AsInteger;
       Top := Tablo.Query1.FieldByName('USTTEN').AsInteger;
       Left := Tablo.Query1.FieldByName('SOLDAN').AsInteger;
       Width := Tablo.Query1.FieldByName('EN').AsInteger;
       Height := Tablo.Query1.FieldByName('BOY').AsInteger;
       //rezervasyon modunda ve bug?nden hari? bir g?nse masalar rezerve veya bo?tur. Ama bug?nse dolu masalar da g?r?lmeli
       if (rezervasyontus.Down)and(FormatDateTime('yyyy-mm-dd', RezTarih.date) <> FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)) then begin
             if Tablo.Query1.FieldByName('REZID').AsInteger>0 then
                Brush.Color := RenkMasaRezerve
             else
                Brush.Color := RenkMasaBos;
       end else begin
           case Tablo.Query1.FieldByName('DURUM').AsInteger of
            0 : Brush.Color := RenkMasaBos;
            1 : if Tablo.Query1.FieldByName('BIRLESIM').AsInteger>0 then begin
                   HelpContext := Tablo.Query1.FieldByName('BIRLESIM').AsInteger;
                   Brush.Color := RenkMasaBirles
                end else
                   Brush.Color := RenkMasaDolu;
            //2 : Brush.Color := RenkMasaRezerve;
           end;

           //if Tablo.Query1.FieldByName('REZID').AsInteger>0 then
           //   Brush.Color := RenkMasaRezerve;
       end;

       if Brush.Color = RenkMasaDolu then  //garson,ki?i,a??l??,ge?en,tutar
          HelpKeyWord := MasaBilgiGetir(Tablo.Query1);

       case Tablo.Query1.FieldByName('SEKIL').AsInteger of
          1 : Shape := stCircle;
          2 : Shape := stEllipse;
          3 : Shape := stRectangle;
       end;
       OnClick:= Shape1Click;
     end;
     //MasaNoYaz(SeciliSekil);
     SeciliSekil:= nil;
     //Labellar +
     GarsonLabel := TcxLabel.Create(MekanMasaGorDlg);
     GarsonLabel.Top := Tablo.Query1.FieldByName('USTTEN').AsInteger;
     GarsonLabel.Left := Tablo.Query1.FieldByName('SOLDAN').AsInteger;
     GarsonLabel.Caption:=Tablo.Query1.FieldByName('GARSON').AsString;
     GarsonLabel.Parent := ZeminResim;
     //Labellar -

     Tablo.Query1.Next;
    end;
end;

procedure TMekanMasaGorDlg.PaketTusClick(Sender: TObject);
begin
   JvTimer1.Enabled := False;
   JvTimer1.Interval := 10000;
   JvTimer1.Enabled := True;

   RezervasyonTus.Visible:= False;
   MasaTus.Visible:= False;
   PanelPaket.Visible:=True;
   PanelPaket.BringToFront;
end;

procedure TMekanMasaGorDlg.RezervasyonTusClick(Sender: TObject);
begin
   RezTarih.Visible := RezervasyonTus.Down;

   if RezervasyonTus.Down then begin
      StatusBar1.Panels[3].Text := 'Masa Se?in';
      MasaAksiyon := 2;
   end else begin
       StatusBar1.Panels[3].Text := '';
       MasaAksiyon := 1;
       if FormatDateTime('yyyy-mm-dd', RezTarih.date) <> FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh) then begin
          RezTarih.date := tablo.GENINI.BugunTrh;
          MekanMasaDestroy;
          MekanMasaCreate;
       end;
   end;
end;

function TMekanMasaGorDlg.MasaBul(MasaNo:SmallInt):TShape;
var i : smallint;
    c : TComponent;
begin
    for i := ComponentCount-1 downto 0 do
       if (Components[i] is TShape)and(Components[i].tag = MasaNo) Then begin
          result := TShape(Components[i]);
          exit;
       end;
end;

procedure TMekanMasaGorDlg.RezTarihChange(Sender: TObject);
var i : smallint;
    c : TComponent;
begin
{    //?ncebakal?m bu mekanda bu tarihte rezervasyon var m?
    SeciliSekil := nil;
    for i:= ComponentCount-1 downto 0 do
       if Components[i] is TShape Then begin
          TShape(Components[i]).Brush.Color := RenkMasaBos;
          MasaNoYaz(TShape(Components[i]));
       end;
//    sonra dolu masalar? i?aretleyelim
    Tablo.TablodanSorguAc(5, 'select MASAID, MASANO from REZERVASYON where MEKANID='+inttostr(MekanID) +' and TARIH between '''+ FormatDateTime('yyyy-mm-dd  00:00', RezTarih.date)+''' and '''+ FormatDateTime('yyyy-mm-dd  23:59', RezTarih.date)+'''');
    while not Tablo.Query5.Eof do begin
        c := FindComponent(Tablo.Query5.FieldByName('MASANO').AsString);
        if c <> nil then begin
           TShape(c).Brush.Color := RenkMasaRezerve;
           MasaNoYaz(TShape(C));
        end;
       Tablo.Query5.Next;
       //MekanMasaCreate;
    end; }
    MekanMasaDestroy;
    MekanMasaCreate;
end;

procedure TMekanMasaGorDlg.MekanClick(Sender: TObject);
begin
    {if RezervasyonTus.Down then begin
       RezervasyonTus.Down := False;
       RezTarih.Visible := False;
    end;}
    JvTimer1.Enabled := False;
    JvTimer1.Interval := 5000;
    JvTimer1.Enabled := True;
    //ScrollBoxMekan.BringToFront;
    PanelPaket.Visible:=False;
    RezervasyonTus.Visible:= True;
    MasaTus.Visible:= True;



    if TJvNavPanelButton(Sender).Tag > 0 then  //e?er fare ile mekan se?ilmi?se Ta 0'dan b?y?k olur. Timer ile refresh olmu?sa Tag 0 olur
       MekanID := TJvNavPanelButton(Sender).Tag;
    MekanMasaDestroy;
    MekanMasaCreate;
    JvTimer1.Enabled:=false;
    JvTimer1.Enabled:=true;
    //e?er rezervasyon modunda ise
    //if (RezervasyonTus.Down)and(FormatDateTime('yyyy-mm-dd', RezTarih.date) <> FormatDateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)) then
    //   RezTarihChange(self);
end;

procedure TMekanMasaGorDlg.IptalTusClick(Sender: TObject);
begin
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set DURUM='+IntToStr(DefSiparisIptal)+' where ID='+TabSiparis.Fields[0].AsString,[],[]); //buraya
   PaketTarihChange(Self);
end;

procedure TMekanMasaGorDlg.IsimGiris;
var
  isim:string;
begin
  if InputQuery('Garson ?sim', 'Garson Ad?n? Yaz?n?z?',isim) = True then
     ShowMessage('isim ' + isim)
end;

procedure TMekanMasaGorDlg.PaketTarihChange(Sender: TObject);
var ID:Integer;
begin
   ID:=0;
   if (TabSiparis.active)and(TabSiparis.RecordCount>0) then
       ID:=TabSiparis.Fields[0].AsInteger;
   TabSiparis.SQL.Text := MemoPaketSQL.Text;
   TabSiparis.SQL.Add(' where FATURATARIH between '''+FormatDateTime('yyyy-mm-dd 00:00', PaketTarih.date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59:59', PaketTarih.date)+''' and '+
     ' FB.TUR = 110  and LOKASYON<0 ');
   if not CheckTumListe.Checked then TabSiparis.SQL.Add(' and FB.DURUM not in('+IntToStr(DefSiparisIptal)+','+IntToStr(DefSiparisTahsil)+')');
   TabSiparis.SQL.Add(' order by FB.ID desc ');
   TabloYenile(TabSiparis,[]);
   tvSiparis.DataController.Groups.FullExpand;
   if ID>0 then
      TabSiparis.locate('ID', ID, []);
end;

procedure TMekanMasaGorDlg.JvPopupMenu2Popup(Sender: TObject);
begin
   if SubeSecimMenu.Count<1 then begin
      Tablo.TablodanSorguAc(1,'select SUBEID=DIL, count(DIL) from GENINI where BOLUM=-4444 group by  DIL');
      while not Tablo.Query1.eof do begin
         //MenuIslemleri(AnaForm.GenelDokumler, GenelRaporSecClick, 'Ekle', Secilen, '',-1);
         Tablo.Query1.next;
      end;
   end;
end;

procedure TMekanMasaGorDlg.JvTimer1Timer(Sender: TObject);
var SMasa : TShape;
begin
   if MekanMasaGorDlg.Active then begin
       if PanelPaket.Visible then
               PaketTarihChange(Self)
       else begin
          //MekanClick(self);
          Tablo.TablodanSorguAc(8,'select M.*,REZID=0 from MASALAR M where M.MEKAN='+inttostr(MekanID));
          while not Tablo.Query8.eof do begin
             SMasa := MasaBul(Tablo.Query8.Fields[0].AsInteger);
             {if (Tablo.Query8.FieldByName('DURUM').AsInteger=0)and(SMasa.Brush.Color<>RenkMasaBos) then
                  SMasa.Brush.Color:=RenkMasaBos
             else if (Tablo.Query8.FieldByName('DURUM').AsInteger=1)and(SMasa.Brush.Color<>RenkMasaDolu) then
                  SMasa.Brush.Color:=RenkMasaDolu
             else if (Tablo.Query8.FieldByName('DURUM').AsInteger=2)and(SMasa.Brush.Color<>RenkMasaRezerve) then
                  SMasa.Brush.Color:=RenkMasaRezerve;}
             case Tablo.Query8.FieldByName('DURUM').AsInteger of
               0: SMasa.Brush.Color:=RenkMasaBos;
               1: if Tablo.Query8.FieldByName('BIRLESIM').AsInteger>0 then begin
                     SMasa.HelpContext := Tablo.Query8.FieldByName('BIRLESIM').AsInteger;
                     SMasa.Brush.Color:=  RenkMasaBirles
                  end else
                     SMasa.Brush.Color:=  RenkMasaDolu;
               2: SMasa.Brush.Color:=RenkMasaRezerve;
             end;

             Tablo.Query8.next;
          end
       end;
   end
end;

procedure TMekanMasaGorDlg.SonTusClick(Sender: TObject);
   procedure MasaHesapBirlestir;
   var EnKucukFatbasId,EnKucukMasaNo, i: integer;
   begin
       Tablo.TablodanSorguAc(1,'select min(ID) from MASALAR where BIRLESIM='+IntToStr(BirlesNo));
       EnKucukMasaNo := Tablo.Query1.Fields[0].asInteger;
       //dolu en k???k masa, birle?en en k???k masa olur
//       Tablo.TablodanSorguAc(8, 'select top 1 FB.ID from FATBASLIK FB where FB.TUR=110 and FB.LOKASYON='+IntToStr(BirlesikEnKucukSekil.Tag)+' and FB.DURUM=0 order by 1 desc ');
//       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set LOKASYON='+IntToStr(BirlesikEnKucukSekil.Tag)+',OZELKOD='''+BirlesikEnKucukSekil.Hint+''' where ID='+Tablo.Query8.Fields[0].AsString,[],[]);
       //di?er dolu masalara da bunun IDsi verilerek birle?tirilir
//       for i := 0 to BirlesenDoluMasaList.Count-1 do
//           if BirlesenDoluMasaList.Strings[i]<>IntToStr(BirlesenDoluMasaMinNo) then begin

     { for i:=0 to PanelBirlesen.ComponentCount-1 do
            if (PanelBirlesen.Components[i] is TJvNavPanelButton)and(TJvNavPanelButton(PanelBirlesen.Components[i]).Name <> 'SonTus')
                and(TJvNavPanelButton(PanelBirlesen.Components[i]).Tag<>EnKucukMasaNo)and(TJvNavPanelButton(PanelBirlesen.Components[i]).colors.ButtonColorFrom=RenkMasaDolu)  Then begin
                  Tablo.TablodanSorguAc(7, 'select top 1 FB.ID from FATBASLIK FB where FB.TUR=110 and FB.LOKASYON='+IntToStr(EnKucukMasaNo )+' and FB.DURUM=0 order by 1 desc ');
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set FATBASID='+Tablo.Query8.Fields[0].AsString+' where FATBASID='+Tablo.Query7.Fields[0].AsString,[],[]);
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from FATBASLIK where ID='+Tablo.Query7.Fields[0].AsString,[],[]);
               end;

}

      //?nce dolu adisyonlardan en k?????n ID sini alal?m
      Tablo.TablodanSorguAc(2,'select min(ID) from FATBASLIK where TUR=110 and LOKASYON in (select ID from MASALAR where DURUM=1 and BIRLESIM='+IntToStr(BirlesNo)+') and DURUM=0 ');
      if Tablo.Query2.Fields[0].asInteger>0 then begin
         EnKucukFatbasId := Tablo.Query2.Fields[0].asInteger;
          //Sonra bu adisyona t?m a??lm?? ?r?n sat?rlar?n? birle?tirelim
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATURA set FATBASID= '+IntToStr(EnKucukFatbasId)+' where FATBASID in '+
               ' (select ID from FATBASLIK where TUR=110 and LOKASYON in (select ID from MASALAR where DURUM=1 and BIRLESIM='+IntToStr(BirlesNo)+') and DURUM=0)',[],[]);
          //Sonra bu adisyonu en k???k se?ilmi? masaya ba?layal?m. (Bu masa bo? da olabilir)
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set LOKASYON= '+IntToStr(EnKucukMasaNo)+' where ID='+IntToStr(EnKucukFatbasId),[],[]);
          //En k???k adisyon d???ndakilerin fatbasl?klar?n? silebilirizart?k
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete  from FATBASLIK where  ID<>'+IntToStr(EnKucukFatbasId)+
           '  and TUR=110 and LOKASYON in (select ID from MASALAR where DURUM=1 and BIRLESIM='+IntToStr(BirlesNo)+') and DURUM=0',[],[]);


           //Birle?mi? masadaki YER ve YERID d?zenleyelim
          //Tablo.TablodanSorguAc(8, 'select top 1 FB.ID from FATBASLIK FB where FB.TUR=110 and FB.LOKASYON='+IntToStr(EnKucukMasaNo)+' and FB.DURUM=0 order by 1 desc ');
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update F1 set F1.YERID=(select count(F2.ID) from FATURA F2 where F1.FATBASID=F2.FATBASID and F1.YERI=F2.YERI ) '+
              ' from FATURA F1 where F1.FATBASID='+IntToStr(EnKucukFatbasId),[],[]);
      end;

      //BirlesenDoluMasaList.Clear;
   end;

   procedure MasaBirlestir;
   var i: smallint;
   begin
     //
     Tablo.TablodanSorguAc(1,' select isnull(max(BIRLESIM),0)+1 from MASALAR');
     BirlesNo := Tablo.Query1.Fields[0].AsInteger;
     //
//      BirlesenDoluMasaMinNo := 99999;
      for i:=0 to PanelBirlesen.ComponentCount-1 do
        if (PanelBirlesen.Components[i] is TJvNavPanelButton)and(TJvNavPanelButton(PanelBirlesen.Components[i]).Name <> 'SonTus')  Then begin
//            if TJvNavPanelButton(PanelBirlesen.Components[i]).Tag<BirlesenDoluMasaMinNo then
//               BirlesenDoluMasaMinNo:= TJvNavPanelButton(PanelBirlesen.Components[i]).Tag; //birle?en dolu masalardan en k???k masa noyu tutmam laz?m; ??nk? o masa ?zerinde t?m adisyonlar toplanacak

            //if (BirlesikEnKucukSekil = nil)or(TJvNavPanelButton(PanelBirlesen.Components[i]).Tag < BirlesikEnKucukSekil.Tag) then
            //    BirlesikEnKucukSekil := TJvNavPanelButton(PanelBirlesen.Components[i]);


            Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update MASALAR set DURUM=1, BIRLESIM='+IntToStr(BirlesNo)+' where ID='+IntToStr(TJvNavPanelButton(PanelBirlesen.Components[i]).Tag),[],[]);
            //TShape(Components[i]).Brush.Color := RenkMasaDolu;
        end;
      i:=-1;
      while PanelBirlesen.ComponentCount > 0 do begin
            inc(i);
            if TJvNavPanelButton(PanelBirlesen.Components[i]).Name <> 'SonTus' then begin
               PanelBirlesen.Components[i].Destroy;
               i:=-1;
            end;
      end;
      end;
begin
   PanelBirlesen.Visible := False;
   RezervasyonTus.Visible := True;
   MasaTus.Visible := True;
   StatusBar1.Panels[3].Text := '';
   MasaAksiyon := 1;
   //Shape1Click(BirlesikEnKucukSekil);
   MasaBirlestir;
   MasaHesapBirlestir;
end;

procedure TMekanMasaGorDlg.TabSiparisAfterOpen(DataSet: TDataSet);
begin
   DuzenleTus.Visible := TabSiparis.RecordCount>0;
   SilTus.Visible := DuzenleTus.Visible;
   KuryeTus.Visible := DuzenleTus.Visible;
   TahsilatTus.Visible := DuzenleTus.Visible;
   IptalTus.Visible := DuzenleTus.Visible;
   PanelAlt.Visible := DuzenleTus.Visible;
end;

procedure TMekanMasaGorDlg.TumListeyiClick(Sender: TObject);
begin
   CheckTumListe.checked := not CheckTumListe.checked;
   PaketTarihChange(Self);
end;

procedure TMekanMasaGorDlg.tvSiparisSelectionChanged(Sender: TcxCustomGridTableView);
begin
   DateTeslim.date := TabSiparis.FieldByName('TeslimTarihi').AsDateTime;
end;

procedure TMekanMasaGorDlg.YeniTusClick(Sender: TObject);
var ID, AdrSiraNo : Integer;
    TelNo:String;
begin
   if TJvNavPanelButton(Sender).Name = 'YeniTus' then
      TelNo:=''
   else
      Telno:='0554 261 91 92';
   ID := CariIdGetir(TelNo, AdrSiraNo);
   if ID > 0 then begin
       Application.CreateForm(THizliGirisDlg,HizliGirisDlg);
       HizliGirisDlg.EditRehID.Text:= IntToStr(ID);
       HizliGirisDlg.Cagiran := 7;
       //Tablo.TablodanSorguAc(1, 'select isnull(min(LOKASYON),0)-1 from FATBASLIK where LOKASYON<0');
       HizliGirisDlg.MasaID := -1;//Tablo.Query1.Fields[0].AsInteger;
       HizliGirisDlg.MasaNo := 'Paket';
       HizliGirisDlg.AdrSiraNo :=AdrSiraNo ;
       HizliGirisDlg.ShowModal;

       FreeAndNil(HizliGirisDlg);
       PaketTarihChange(Self);
   end;
end;

procedure TMekanMasaGorDlg.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure TMekanMasaGorDlg.KuryeTusClick(Sender: TObject);
var
  Sifre:String;
begin
   if KullaniciGirisDlg = nil then
      Application.CreateForm(TKullaniciGirisDlg, KullaniciGirisDlg);
      KullaniciGirisDlg.Cagiran := 2;
//   if HizliGirisAnaMenu.SifreSifirla then
//      KullaniciGirisDlg.edPassword.EditValue:= ''
//   else
//      if KullaniciGirisDlg.TabKullanici.Locate('REHBERID',IntToStr(lbKullanici.Tag),[]) then
//         KullaniciGirisDlg.edPassword.EditValue:= UGenSifre.DeSifre(KullaniciGirisDlg.TabKullanici.FieldByName('SIFRE').AsString);
   KullaniciGirisDlg.ShowModal;
   if KullaniciGirisDlg.ModalResult = mrOk then begin             //Durum serviste  buraya
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update FATBASLIK set DURUM='+IntToStr(DefSiparisKurye)+', FATURA_GON_TARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Tablo.GENINI.BugunTrhSaat)+''', '+
        ' SATICIKODU='+KullaniciGirisDlg.TabKullanici.FieldByName('REHBERID').AsString+' where ID='+TabSiparis.Fields[0].AsString,[],[]);
      PaketTarihChange(Self);
   end;
   FreeAndNil(KullaniciGirisDlg);
end;

procedure TMekanMasaGorDlg.MekanMasaDestroy;
var i:integer;
begin
   for i:= ComponentCount-1 downto 0 do Begin
       if (Components[i] is TShape) and (Components[i].Name<>'Shape1') Then
           TShape(Components[i]).free
       else if (Components[i] is TcxLabel) Then
          TcxLabel(Components[i]).free;
   end;
end;


procedure TMekanMasaGorDlg.MekanListele(SecSubeId:Integer);
var
    i:integer;
    yeni : TJvNavPanelButton;
begin
    Tablo.TablodanSorguAc(1,'select ANAHTAR, DEGER from GENINI where BOLUM=-4444 and DIL='+IntToStr(SecSubeId));//DIL alan?nda ?ube tutulur
    //cxListBoxMekan.Items.Clear;
    while not Tablo.Query1.Eof do begin
       // cxListBoxMekan.Items.Add(Tablo.Query1.FieldByName('ANAHTAR').AsString);
       yeni := TJvNavPanelButton.Create(MekanMasaGorDlg);
       with yeni do begin
           //yeni := TJvNavPanelButton.Create(PanelBaslik);
           Parent := PanelBaslik;//MekanMasaGorDlg;
           Name:='MASA'+Tablo.Query1.FieldByName('DEGER').AsString;
           Caption := Tablo.Query1.FieldByName('ANAHTAR').AsString;
           Tag := Tablo.Query1.FieldByName('DEGER').AsInteger;
           Top := 0;
           Left := 300;
           Width := 120;
           Height := 37;
           //yeni.Picture.LoadFromFile(s);
           Colors.ButtonColorFrom:= $009E9E9E;
           Colors.ButtonColorFrom:= clBlack;
           Font.Color := clSilver;
           Align := alLeft;
           GroupIndex := 1;
           OnClick:= MekanClick;
       end;

       Tablo.Query1.Next;
    end;
    if Tablo.Query1.RecordCount=1 then begin//demek ki 1 adet mekan var oray? da a?al?m
       yeni.Refresh;
       PanelBaslik.Refresh;
       ZeminResim.Refresh;
       MekanClick(yeni);
       ZeminResim.Refresh;
    end;
end;

procedure TMekanMasaGorDlg.cxDBImageComboBox1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var SonucListe : TStringList;
begin
    SonucListe := TStringList.Create;
    if Tablo.HizliGirisListedenBilgiGetir('Tahsilat Se?imi','select ANAHTAR,DEGER from GENINI WHERE BOLUM=-1021',SonucListe,False,[True,True],[])then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set DETAYBOLUMU=&czm where ID=&id ',['&czm','&id'],
        [SonucListe[0] ,TabSiparis.FieldByName('ID').AsInteger]);
       TabloYenile(TabSiparis,[])
    end;
    SonucListe.free;
end;

procedure TMekanMasaGorDlg.cxDBMemo1Click(Sender: TObject);
var Bilgi:Variant;
begin
   Bilgi := TabSiparis.FieldByName('SipNotu').AsString;
   if TGirisKutusuEx.BilgiAlEx(BGSiparis_notu , TGirdiDenetimleri.Create.Memo('A??klama' , @Bilgi)) = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set ACIKLAMA=&czm where ID=&id ',['&czm','&id'],
        [StringReplace(VarToStr(Bilgi), '''', '"',[rfReplaceAll]) ,TabSiparis .FieldByName('ID').AsInteger]);
       TabloYenile(TabSiparis,[])
   end;
end;

procedure TMekanMasaGorDlg.MemoAdresClick(Sender: TObject);
var Bilgi:Variant;
begin
   Bilgi := TabSiparis.FieldByName(TcxDBMemo(Sender).Hint).AsString;
   if TGirisKutusuEx.BilgiAlEx(FWAdresi , TGirdiDenetimleri.Create.Memo(TcxDBMemo(Sender).Hint , @Bilgi)) = mrOk then begin
      Tablo.RehberBilgiGuncelle(TabSiparis .FieldByName('REHBERID').AsInteger, 1, TcxDBMemo(Sender).Tag, Bilgi);
      TabloYenile(TabSiparis,[])
   end;
end;

procedure TMekanMasaGorDlg.MterikartnSil1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
     Tablo.CariSil(TabSiparis.FieldByName('ID').AsInteger);
     TabloYenile(TabSiparis,[])
  end;
end;

procedure TMekanMasaGorDlg.cxDBMemo3Click(Sender: TObject);
var Bilgi:Variant;
begin
   Bilgi := TabSiparis.FieldByName('CariNotu').AsString;
   if TGirisKutusuEx.BilgiAlEx(BGMusteri_notu , TGirdiDenetimleri.Create.Memo('A??klama' , @Bilgi)) = mrOk then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update REHBER set NOTLAR=&czm where ID=&id ',['&czm','&id'],
        [StringReplace(VarToStr(Bilgi), '''', '"',[rfReplaceAll]) ,TabSiparis .FieldByName('REHBERID').AsInteger]);
       TabloYenile(TabSiparis,[])
   end;
end;

procedure TMekanMasaGorDlg.cxDBTextEdit1PropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var
  ID: Integer;
begin
  if AButtonIndex = 0 then begin
    ID := Tablo.RehberAra_IDGetir(335);
    if ID > 0 then begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set EKLEYEN=&czm where ID=&id ',['&czm','&id'],
            [ID, TabSiparis.FieldByName('ID').AsInteger]);
       TabloYenile(TabSiparis,[])
    end;
  end;
end;

procedure TMekanMasaGorDlg.DateTeslimPropertiesCloseUp(Sender: TObject);
var SonucListe : TStringList;
begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set TARIH='''+FormatDateTime('yyyy-mm-dd hh:nn', DateTeslim.date)+''' where ID=&id ',['&id'],
        [TabSiparis.FieldByName('ID').AsInteger]);
    TabloYenile(TabSiparis,[])
end;

procedure TMekanMasaGorDlg.DuzenleTusClick(Sender: TObject);
begin
   Application.CreateForm(THizliGirisDlg,HizliGirisDlg);
   HizliGirisDlg.Cagiran := 7;
   HizliGirisDlg.MasaID := TabSiparis.FieldByName('LOKASYON').AsInteger;
   HizliGirisDlg.MasaNo := 'Paket';
   HizliGirisDlg.ShowModal;
   FreeAndNil(HizliGirisDlg);
   PaketTarihChange(Self);
end;

procedure TMekanMasaGorDlg.FormActivate(Sender: TObject);
begin
    Tablo.TablodanSorguAc(1,'select SUBEID=DIL, count(DIL) from GENINI where BOLUM=-4444 group by  DIL');
    case Tablo.Query1.RecordCount of
       0 : ShowMessage('Listelenecek mekan bulunamad?.');
       1 : MekanListele(Tablo.Query1.Fields[0].AsInteger);
       2..999 : if (Tablo.Query1.Locate('SUBEID', SubeId, []))and(Tablo.Query1.Fields[0].AsInteger=SubeId) then
                    MekanListele(SubeId)
                else
                    SubeSecimMenu.Click;
    end;
end;

procedure TMekanMasaGorDlg.FormShow(Sender: TObject);
begin
    WindowState := wsMaximized;
    MasaAksiyon:=1;
    EskiSeciliSekil:=nil;
    OncekiMasaId:=0;
    MasaBilgiList := TStringList.Create;
    //label1.Caption:='';
    RezTarih.date := tablo.GENINI.BugunTrh;

    GarsonAdiSor := StrToIntDef(Tablo.GENINI.ReadString(Ops_Cafe_CheckGarsonAdiSorPC, '1'),1);
    KisiSaySor := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckKisiSaySor, False);

    RenkMasaBos:= StringToColor( Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboBos, 'clWhite')); //
    RenkMasaDolu:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboDolu, 'clYellow')); //
    RenkMasaRezerve:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboRezerve,'clGray')); //
    RenkMasaHesap:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboHesap, 'clBlue')); //
    RenkMasaBirles:=StringToColor(Tablo.GENINI.ReadString(Ops_HizliGiris_ColorComboBirles, 'clFuchsia')); //
    CheckGarsonAdi:= Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckGarsonAdi, True);
    CheckKisiSay:= Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckKisiSay, True);
    CheckAcilisZamani:= Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckAcilisZamani, True);
    CheckGecenZaman:= Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckGecenZaman, True);
    CheckMasaTutar:= Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckMasaTutar, True);


    RezervasyonVar := Tablo.GENINI.ReadBoolean(Ops_Cafe_CheckRezervasyon, True);
    RezervasyonTus.Visible := RezervasyonVar;

    PaketTarih.Date := Tablo.GENINI.BugunTrh;
    PaketTarihChange(Self);
    //MekanMasaDestroy;
    //E?er ?ubeler i?inde bir mekn varsa direk oray? g?steririz

end;

end.





