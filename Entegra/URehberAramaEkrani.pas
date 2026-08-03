unit URehberAramaEkrani;

interface

uses
  Windows,   Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxImageComboBox, cxMaskEdit, cxDropDownEdit, cxContainer,
  cxTextEdit, StdCtrls, ExtCtrls, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,UTouchKeyboardWindow,
  cxGrid, ComCtrls, ToolWin, FireDAC.Comp.Client, cxLabel, JvExControls, JvButton, JvNavigationPane, JvTimer,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, cxCheckBox,
  dxSkinLiquidSky, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, Vcl.Menus,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TRehberAramaEkrani = class(TForm)
    AraQuery1: TFDQuery;
    dsAra: TDataSource;
    ToolBar2: TToolBar;
    YeniTus: TToolButton;
    ToolButton2: TToolButton;
    SecTus: TToolButton;
    KapatTus: TToolButton;
    GridCariArama: TcxGrid;
    GridCariAramaDBTableView1: TcxGridDBTableView;
    GridCariAramaDBTableView1ID: TcxGridDBColumn;
    GridCariAramaDBTableView1GRUP: TcxGridDBColumn;
    GridCariAramaDBTableView1KOD1: TcxGridDBColumn;
    GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn;
    GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn;
    GridCariAramaLevel1: TcxGridLevel;
    Panel1: TPanel;
    LabelPNO: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    AraFirma: TcxTextEdit;
    AraYetkili: TcxTextEdit;
    AraKod: TcxTextEdit;
    ComboGrup: TcxImageComboBox;
    ToolBar1: TToolBar;
    LabelSon: TcxLabel;
    LabelSIK: TcxLabel;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    JvNavPanelButton1: TJvNavPanelButton;
    AraBarkod: TcxTextEdit;
    Label1: TLabel;
    JvTimer1: TJvTimer;
    Label3: TLabel;
    ComboSinif: TcxImageComboBox;
    GridCariAramaDBTableView1Column1: TcxGridDBColumn;
    CheckPasifler: TcxCheckBox;
    GridCariAramaDBTableView1DURUM: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    GrupIceriginiGosterMenu: TMenuItem;
    GridCariAramaDBTableView1FATBASLIK: TcxGridDBColumn;
    procedure FormShow(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure AraTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure LabelSonClick(Sender: TObject);
    procedure AraQuery1AfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GrupIceriginiGosterMenuClick(Sender: TObject);
  private
    { Private declarations }
    Klavye1 : TKeyboardWindow;
    procedure CariListele;
    procedure SAPdenListele;
  public
    { Public declarations }
    AramaGrup,YetkiliModul : integer;
    Potansiyel, SAPOrtak:Boolean;
  end;

var
  RehberAramaEkrani: TRehberAramaEkrani;

implementation

uses Utablo,PrjConst,LocOnFly, UGirisKutusuEx, UListe, UVeriMotor;

{$R *.dfm}
var Aramayeri : String;

procedure TRehberAramaEkrani.AraQuery1AfterOpen(DataSet: TDataSet);
begin
   SecTus.Visible := AraQuery1.RecordCount > 0;
end;

procedure TRehberAramaEkrani.AraTusClick(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TRehberAramaEkrani.LabelSonClick(Sender: TObject);
begin
   AraQuery1.Close;
   AraQuery1.SQL.Text :=
      'select '+DbUst(50)+'R.ID, R.KOD, R.FIRMA, R.GRUP, ADSOYAD = P.FIRMA, P.ID as PERID, R.DURUM ' +
      'from REHBER R ' +
      'outer apply ( ' +
      '   select '+DbUst(1)+'K.SAY, K.DEGISTIRMETARIHI ' +
      '   from KULLANICI_REHBER K with (nolock) ' +
      '   where K.REHBERID = R.ID and K.KULID = :KULID ' +
      '   order by K.DEGISTIRMETARIHI desc ' +
      DbSinir(1)+') K ' +
      'outer apply ( ' +
      '   select '+DbUst(1)+'P.ID, P.FIRMA ' +
      '   from REHBER P with (nolock) ' +
      '   where P.GRUP = 334 and P.BAGID = R.ID and isnull(P.STATU,1) = 1 ' +
      '   order by P.DEGISTIRMETARIHI desc, P.ID desc ' +
      DbSinir(1)+') P ' +
      'where R.ID > 0 and R.DURUM > 0 ';
   // Param'lar (KULID, GRUP) asagida TabloYenile'ye p dizisiyle SIRAYLA gecilir
   // (TabloYenile SQL.Text'i PgSqlCevir'den gecirir -> inline ParamByName sifirlanirdi).
   if (AramaGrup = 335) or (AramaGrup = 336) then
      AraQuery1.SQL.Add(' and R.GRUP = :GRUP ')
   else if AramaGrup = 337 then
      AraQuery1.SQL.Add(' and R.GRUP between 335 and 336 ')
   else
   begin
      AraQuery1.SQL.Add(' and R.GRUP <> 335 ');
      if not Potansiyel then
         AraQuery1.SQL.Add(' and R.GRUP > 1 ');
   end;

   if SubeVarmi then
      AraQuery1.SQL.Add(' and R.SUBEID in(' + Tablo.YetkiliSubeleriGetir(22, YetkiTur_Gorme) + ') ');

   if TcxLabel(Sender).Tag = 1 then
      AraQuery1.SQL.Add(' order by K.DEGISTIRMETARIHI desc ')
   else
      AraQuery1.SQL.Add(' order by K.SAY desc ');

   AraQuery1.SQL.Add(' '+DbSinir(50)+' ');
   // Converter'a bagli ac: TabloYenile vmPG'de PgSqlCevir uygular (OUTER APPLY->LATERAL,
   // WITH(NOLOCK) strip, isnull vb.); MSSQL'de cevirici cagrilmaz -> .Open ile ayni.
   // Param'lar SIRAYLA: :KULID (once), :GRUP (varsa, [335,336] dalinda).
   if (AramaGrup = 335) or (AramaGrup = 336) then
      TabloYenile(AraQuery1, [StrToIntDef(Kullanan, 0), AramaGrup])
   else
      TabloYenile(AraQuery1, [StrToIntDef(Kullanan, 0)]);
end;
procedure TRehberAramaEkrani.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   AramaGrup := 0
end;

procedure TRehberAramaEkrani.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TRehberAramaEkrani.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   JVTimer1.enabled := True;
   if (Key = 13) then begin
       if Sender as TcxTextEdit = AraBarkod  then
          JVTimer1.OnTimer(self);
       Sectus.Click
   end
   else if Key = 27 then KapatTus.Click
   else if Key = 38 then AraQuery1.Prior
   else if Key = 40 then AraQuery1.Next;
end;

procedure TRehberAramaEkrani.FormShow(Sender: TObject);
var c:TComponent;
begin
   RehberAramaEkrani.ComboGrup.Enabled := (AramaGrup < 1)or(AramaGrup = 337)or(Potansiyel=True); //337 : 335 Pers + 336 grup
   if AramaGrup < 1 then begin
      //Tablo.GENINI.ReadImageSection(Ops_CariKart_Grup, ComboGrup.Properties.Items, True);
      Tablo.GENINI.ReadImageSection(Ops_CariKart_Grup, Tablo.RepCariGrup.Properties.Items, True);
      RehberAramaEkrani.ComboGrup.EditValue := AramaGrup;
   end
   else if AramaGrup = 337 then begin
      //ComboGrup.Properties.Items:=tablo.imgComboboxInit('SELECT DEGER, ANAHTAR FROM GENINI WHERE BOLUM=-2200 AND DEGER IN (335, 336)').Items;
      Tablo.RepCariGrup.Properties.Items:=tablo.imgComboboxInit('SELECT DEGER, ANAHTAR FROM GENINI WHERE BOLUM=-2200 AND DEGER IN (335, 336)').Items;
      RehberAramaEkrani.ComboGrup.EditValue := 335;
   end;


   JvTimer1.Enabled := False;
   JvTimer1.Interval := 0;

   if (AramaGrup = 335)or(AramaGrup = 337) then begin
      LabelSon.Visible := False;
      LabelSIK.Visible := False;
      Caption:= RAEPersonelAramaEkrani;
      // if (not AraQuery1.Active)or(AraQuery1.RecordCount<1) then
      //     AraTusClick(Self);
   end
   else begin
      if not Potansiyel then //potansiyeller gelmeyecekse combodan çıkaralım.
         Tablo.RepCariGrup.Properties.Items.Delete(Tablo.RepCariGrup.Properties.FindItemByValue(1).Index );
      Tablo.RepCariGrup.Properties.Items.Delete(Tablo.RepCariGrup.Properties.FindItemByValue(335).Index );
      Caption:= RAEAramaEkrani;
      LabelSon.Visible := True;
      LabelSIK.Visible := True;
   end;

   CheckPasifler.Checked:=False;

   Aramayeri := GenRegIni.RegReadString('', 'FirmaAramaAlani', '1', 'C');
   c := FindComponent(Aramayeri);
   if c <> nil then
      TcxTextEdit(c).SetFocus
   else
      AraFirma.SetFocus;

   if (SAPOrtak = False)or(KaynakDB <> 'SAP')  then begin
       if AramaGrup = 335 then
          JvTimer1Timer(Self)
       else
          LabelSonClick(LabelSon);  // acilista SON arananlar (Tag=1, DEGISTIRMETARIHI desc); Self=form Tag=0 SIK getiriyordu
   end;

    GridCariAramaDBTableView1FATBASLIK.Visible := False;
end;

procedure TRehberAramaEkrani.GrupIceriginiGosterMenuClick(Sender: TObject);
var GrupListe : TStringList;
    i : integer;
begin
    Application.CreateForm(TListeDlg, ListeDlg);
    ListeDlg.Label1.Caption := 'Grup Üyeleri';
    GrupListe := TStringList.Create;
    GrupListe.Delimiter := ',';
    GrupListe.QuoteChar := ',';
    GrupListe.Clear;
    GrupListe.DelimitedText := Tablo.AciklamaGetir('REHBER', 'NOTLAR', AraQuery1.Fields[0].AsInteger);

    for i := 0 to GrupListe.Count-1 do
        ListeDlg.ListAmac.Items.Add(Tablo.AciklamaGetir('REHBER', 'FIRMA', GrupListe[i]));
    GrupListe.Free;
    ListeDlg.ShowModal;
    ListeDlg.Destroy;
end;

procedure TRehberAramaEkrani.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
     JvNavPanelButton1.Down:=True;
     Klavye1 := TKeyboardWindow.Create(Application);
     Klavye1.ShowKeyboard(Self);
     Klavye1.Top := RehberAramaEkrani.Top+200;//Top + Height;
  end else begin
     Klavye1.HideKeyboard;
     FreeAndNil(Klavye1);
     JvNavPanelButton1.Down:=False;
  end;
end;

procedure TRehberAramaEkrani.CariListele;
var
  s, Fir,Yet,Kod,Barkod, TFirma,TYet,TKod, Grup,Sinif, Sube, Aranan,Durumu,FatBaslik, LikeOp :string;
begin
  if (AramaGrup <> 335)and((ComboGrup.EditValue<1)and(ComboSinif.EditValue<1)and(Trim(AraFirma.Text)='')and(Trim(AraYetkili.Text)='')and(Trim(AraKod.Text)='')) then
      Exit;

  s := '';
  Fir := ' R.FIRMA ';
  Yet := ' P.FIRMA ';
  Kod := ' R.KOD ';
  if AktifVeriMotor = vmPG then
    LikeOp := ' ILIKE '
  else
    LikeOp := ' LIKE ';

  TFirma := '%' + Trim(AraFirma.Text) + '%';// OR X1.BILGI LIKE '%' + Trim(AraFirma.Text) + '%';
  TYet := '%' + Trim(AraYetkili.Text) + '%';
  TKod := '%' + Trim(AraKod.Text) + '%';


  //if (AramaGrup = 335)or(AramaGrup = 336) then  //335 personel 336 grup
  //    AraQuery1.SQL.Add(' and R.GRUP='+IntToStr(AramaGrup))
   if AramaGrup = 337 then begin                 // 337 personel + grup
      if TFirma = '%%' then
         Grup := ' and R.GRUP ='+IntToStr(ComboGrup.EditValue) //arama alanı boşsa gruba göre listelenir
      else
         Grup := ' and R.GRUP between 335 and 336 ' //aramaya harf girildiyse personel ve grup içinden arama yapılır
   end else if AramaGrup > 0 then
      Grup := ' and R.GRUP ='+IntToStr(AramaGrup) //Sadece personeli lislemek için yapıldı
   else if ComboGrup.Text <> '' then
      Grup := ' and R.GRUP ='+IntToStr(ComboGrup.EditValue)//ComboGrup.Properties.Items[ComboGrup.ItemIndex].Value)
   else
      Grup := ' and R.GRUP<>99 and R.GRUP<>334 and R.GRUP<>335  ';//grup adı,  potansiyel personel ve personel

  if (not Potansiyel)and(AramaGrup < 1) then
     Grup := Grup+' and R.GRUP > 1 ';


  if ComboSinif.Text <> '' then
     Sinif := ' and R.SINIF ='+IntToStr(ComboSinif.EditValue)//ComboGrup.Properties.Items[ComboGrup.ItemIndex].Value)
  else
     Sinif := '';

  if AraBarkod.Text <> '' then
     if Length(AraBarkod.Text)=1 then
        Barkod := AraBarkod.Text
     else
        Barkod := Copy(AraBarkod.Text,1,Length(AraBarkod.Text)-1);//checksum almayalım

  if SubeVarmi then
     Sube := ' and R.SUBEID in('+Tablo.YetkiliSubeleriGetir(22,YetkiTur_Gorme)+') '
  else
     Sube := '';

  if CheckPasifler.Checked then
     Durumu := ''
  else
     Durumu := ' and R.DURUM > 0 ';

  AraQuery1.Close;
  ///Aramalarda bankalar gelmesin diye 102 kod ile başlayanları devre dışı bıraktık
  FatBaslik:= '';
  if AraFirma.Text <> '' then begin
     if AramaGrup = -1 then
        FatBaslik:= ' OR X1.BILGI' + LikeOp + '''' + TFirma +''' ' ;

    Aranan := 'AraFirma';
    s := ' where R.KOD not like ''102.%'' and R.ID > 0 '+Grup+Durumu+' and (' + Fir + LikeOp + '''' + TFirma +''''+FatBaslik+ ')'+ Grup + ' '+Sube+' ORDER BY R.FIRMA'  //   and ' + gorulmeyecekkod
  end else if AraYetkili.Text <> '' then begin
    Aranan := 'AraYetkili';
    s := ' where R.KOD not like ''102.%'' and R.ID > 0 '+Grup+Durumu+' and ' + Yet + LikeOp + '''' + TYet +''''+ Grup +' '+Sube+' ORDER BY R.FIRMA'             // and gorulmeyecekkod
  end else if AraKod.Text <> '' then begin
    Aranan := 'AraKod';
    s := ' where R.KOD not like ''102.%'' and R.ID > 0 '+Grup+Durumu+' and ' + Kod + LikeOp + '''' + TKod+'''' + Grup + ' '+Sube+'  ORDER BY ' + Kod     // and gorulmeyecekkod
  end else if ComboSinif.Text <> '' then begin   //EditValue
    Aranan := '';
    s := ' where R.KOD not like ''102.%'' and R.ID > 0 '+Durumu+' '+Sinif+ ' '+Sube+' ORDER BY R.FIRMA'
  end else if AraBarkod.Text <> '' then begin
    Aranan := 'AraBarkod'; //R.ID
    s := ' where R.ID='+Barkod+Grup+Durumu+'  '+Grup+ ' '+Sube+' ORDER BY R.FIRMA'
//    s := ' where R.ID='+IntToStr(StrToIntDef(Barkod,0))+' and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' '+Sube+' ORDER BY FIRMA'
//    s := ' where R.FIRMA='''+Barkod+''' and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' '+Sube+' ORDER BY FIRMA'
  end else if (AramaGrup > 0)or(ComboGrup.Text <> '') then begin   //EditValue
    Aranan := '';
    s := ' where R.KOD not like ''102.%'' and R.ID > 0 '+Durumu+'  '+Grup+ ' '+Sube+' ORDER BY R.FIRMA'
  end else
     exit;

  if YetkiliModul <> 0 then
     s := stringreplace(s,' where ',' where exists(select 1 from KULLANICI K  inner join ROLLER RO on RO.ID=K.ROLID inner join YETKI Y on Y.ROLID=K.ROLID and Y.MODULID='+IntToStr(YetkiliModul)+' and Y.HAK=1 where R.ID=K.REHBERID and ((Y.HAK=1)or(RO.TY=1))) and ',[]);
    //s := ' where R.KOD not like ''102.%''  '+Sube+' ORDER BY FIRMA ';

  ///////
  AraQuery1.SQL.Text := ' select R.ID,R.KOD,R.FIRMA,R.GRUP,R.SINIF,ADSOYAD=P.FIRMA,P.ID as PERID, R.DURUM   ';
  if (TFirma<>'%%')and(AramaGrup = -1) then
     AraQuery1.SQL.Add(' ,FATBASLIK=X1.BILGI ');
  AraQuery1.SQL.Add(' from REHBER R left outer join REHBER P on R.ID=P.BAGID AND P.GRUP=334 and isnull(P.STATU,1) = 1 ');

  if (TFirma<>'%%')and(AramaGrup = -1) then begin//Firma adı araması yapılacaksa fatura başlığına da bakılması lazım
     AraQuery1.SQL.Add(' LEFT OUTER JOIN (SELECT YER_ID,RB.BILGI FROM REHBERBILGI RB '+
      ' INNER JOIN REHBERAYAR RA ON RA.YERI = 2 AND RA.SIRA = RB.SIRA AND RA.YERI = RB.YERI AND RA.VARSAYILAN = 10) X1 ON X1.YER_ID = R.ID');
     GridCariAramaDBTableView1FATBASLIK.Visible := True;
  end;

  AraQuery1.SQL.Add(s);
  TabloYenile(AraQuery1, []);
  if (Aranan<>'')and(Aramayeri <> Aranan) then
     GenRegIni.RegWriteString('', 'FirmaAramaAlani', Aranan, 'C');

end;

procedure TRehberAramaEkrani.SAPdenListele;
begin
   AraQuery1.Close;
   AraQuery1.SQL.Text := 'sp_SAP_Muhatap_Listesi '''+Trim(AraKod.Text)+''','''+Trim(AraFirma.Text)+''','''','''','''+Trim(AraYetkili.Text)+''' ';
   TabloYenile(AraQuery1, []);
end;

procedure TRehberAramaEkrani.JvTimer1Timer(Sender: TObject);
begin
  JvTimer1.Enabled := False;
  if (SAPOrtak)and(KaynakDB = 'SAP') then
     SAPdenListele
  else
     CariListele;
end ;

procedure TRehberAramaEkrani.KapatTusClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;

procedure TRehberAramaEkrani.SecTusClick(Sender: TObject);
begin
   if (SecTus.Visible)and(AraQuery1.RecordCount>0)  then begin
      case AlanTamsayi(AraQuery1.FieldByName('DURUM')) of
       0 : if (MessageBox(0,PChar(CRPasif_kayda_islem_Secimi),PChar(Onay),MB_YESNO)<> ID_YES) then begin //pasif kayıt
                ModalResult := mrCancel;
                exit;
             end;
       2,3 : if Tablo.Uyari_Yasak_Ekrani(AraQuery1.FieldS[0].AsInteger)= 13 then begin //yasak varsa işlem yapılamaz
                ModalResult := mrCancel;
                exit;
             end;
      end;
      ModalResult := mrOk;
   end;
end;

procedure TRehberAramaEkrani.YeniTusClick(Sender: TObject);
var  ID : Integer;
begin
   ID := Tablo.RehberSihirbazBaslat(0,-100,-100,-100, Potansiyel);   //
   if ID<>-99 then begin
      AraQuery1.Close;
      AraQuery1.SQL.Text := ' select * from REHBER where ID = '+ IntToStr(ID);
      TabloYenile( AraQuery1, []);
   end;
end;

end.




