unit UGorevListeAramaFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 04/12/2010 11:44:34 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore,  cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,PrjConst,
  cxDropDownEdit, cxCalendar, Buttons, cxLookAndFeelPainters, cxGroupBox,
  cxRadioGroup,Utablo, dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels,
  dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxCustomData, cxStyles, cxTL,
  cxTLdxBarBuiltInMenu, OfficePopupMenu, cxInplaceContainer, cxDBTL, cxTLData,
  cxButtons, JvExControls, JvNavigationPane, Data.DB, FireDAC.Comp.Client,
  cxImageComboBox, cxButtonEdit, cxCheckBox, cxLabel, cxPC, cxMemo, DateUtils,
  Vcl.ExtCtrls, cxGridCustomView, dxBarBuiltInMenu, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light,
  dxScrollbarAnnotations;

type
  TGorevListeAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PageListeler: TcxPageControl;
    TabSheetListe: TcxTabSheet;
    TabSheetArama: TcxTabSheet;
    DtsListe: TDataSource;
    TabListe: TFDQuery;
    JvNavPanelHeader1: TJvNavPanelHeader;
    TreeListeler: TcxDBTreeList;
    TreeListRollercxDBTreeListColumn1: TcxDBTreeListColumn;
    TreeListRollercxDBTreeListColumn2: TcxDBTreeListColumn;
    ListeMenu: TOfficePopupMenu;
    YeniListeOlutur1: TMenuItem;
    ListeyiSilMenu: TMenuItem;
    N7: TMenuItem;
    ListeyiDuzenleMenu: TMenuItem;
    EditAraIsler: TcxTextEdit;
    MemoKontrol: TcxMemo;
    Panel1: TPanel;
    lblPNO: TcxLabel;
    lbl4: TcxLabel;
    lbl6: TcxLabel;
    LabelAtayan: TcxLabel;
    dateAktBitis: TcxDateEdit;
    dateAktBaslangic: TcxDateEdit;
    ComboKonusu: TcxTextEdit;
    AraFirma: TcxButtonEdit;
    EditAtanan: TcxButtonEdit;
    checkTarih: TcxCheckBox;
    cxLabel1: TcxLabel;
    EditProje: TcxButtonEdit;
    EditOlusturan: TcxButtonEdit;
    N1: TMenuItem;
    ExceldenBilgiAl1: TMenuItem;
    ListeyeKisiEkle1: TMenuItem;
    ListeyiEPostaileGnder1: TMenuItem;
    ListyiYazdr1: TMenuItem;
    N2: TMenuItem;
    ListeyiKopyala1: TMenuItem;
    N3: TMenuItem;
    ListeEkleTus: TcxButton;
    MemoListe: TcxMemo;
    LabelAra: TJvNavPanelHeader;
    CheckTemas: TcxCheckBox;
    EditID: TcxTextEdit;
    cxLabel2: TcxLabel;
    TabSheetProje: TcxTabSheet;
    TreeProjeler: TcxDBTreeList;
    cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeListColumn2: TcxDBTreeListColumn;
    cxButton1: TcxButton;
    MemoProjeler: TcxMemo;
    JvNavPanelHeader2: TJvNavPanelHeader;
    EditAraProje: TcxTextEdit;
    JvNavPanelHeader3: TJvNavPanelHeader;
    procedure ListeyiSilMenuClick(Sender: TObject);
    procedure ListeMenuPopup(Sender: TObject);
    procedure ExceldenBilgiAl1Click(Sender: TObject);
    procedure LabelAraClick(Sender: TObject);
    procedure checkTarihPropertiesEditValueChanged(Sender: TObject);
    procedure AraFirmaPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure PageListelerChange(Sender: TObject);
    procedure ListeyiKopyala1Click(Sender: TObject);
    procedure ListeyiDuzenleMenuClick(Sender: TObject);
    procedure TreeListelerDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeListelerDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure EditAraIslerKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckTemasClick(Sender: TObject);
    procedure TreeListelerDblClick(Sender: TObject);
    procedure TreeListelerMoveTo(Sender: TcxCustomTreeList;
      AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
      Nodes: TList; var IsCopy, Done: Boolean);
    procedure ListeEkleTusClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
    function GetRealDragSourceGridView(const aSource: TcxDragControlObject): TcxCustomGridView;
    function GetDragSourceGridView (const aSource: TcxDragControlObject): TcxCustomGridView;
    procedure Listele;
  public
    { Public declarations }
  end;

implementation
    Uses LocOnFly, UGorevListePaylasim, FetaKurulusSiniflari, ComObj, UBekletme, UGorevListeDlg, UIsListesi;
{$R *.dfm}

{ TGorevListeAramaFrame }

procedure TGorevListeAramaFrame.AraFirmaPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
var ID : Integer;
begin
   if AButtonIndex = 0 then begin
       ID := Tablo.RehberAra_IDGetir(TcxButtonEdit(Sender).HelpContext);
       if ID>0 then begin
          TcxButtonEdit(Sender).Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
          TcxButtonEdit(Sender).Tag:=ID;
       end;
    end else begin
        TcxButtonEdit(Sender).Text:='';
        TcxButtonEdit(Sender).Tag:=0;
    end;
end;

procedure TGorevListeAramaFrame.Baslatildi;
var
  GorevDurumSQL:string;
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  OnaySistemiAktif := Tablo.GENINI.ReadBoolean(Ops_OpsiyonIsListesi_OnayAktif, False);
  dateAktBaslangic.Date := StartOfTheMonth(Tablo.GENINI.BugunTrh);
  dateAktBitis.Date := Tablo.GENINI.BugunTrhSaat;
  TabSheetProje.TabVisible := False;
  Listele;
  //TabloYenile(TabListe,[StrToInt(Kullanan)]);
end;

procedure TGorevListeAramaFrame.checkTarihPropertiesEditValueChanged(Sender: TObject);
begin
  dateAktBaslangic.Enabled:= checkTarih.Checked;
  dateAktBitis.Enabled:= checkTarih.Checked;
  //YenileTus.Click;
end;

procedure TGorevListeAramaFrame.CheckTemasClick(Sender: TObject);
begin
   //TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevGridDBTableView1ACKAPASECIM.visible := not CheckTemas.Checked;
   TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).PanelYeniIs.Visible := not CheckTemas.Checked;
   TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).Listele;
end;

procedure TGorevListeAramaFrame.cxButton1Click(Sender: TObject);
var ID : integer;
begin
      ID := Tablo.ProjeSihirbazBaslat('E',-1,-99,Tablo.GENINI.BugunTrhSaat);
      if  ID > 0 then begin
         Listele;
         TabListe.Locate('ID', ID, []);
         TreeListeler.OnClick(Self);
      end;
end;

procedure TGorevListeAramaFrame.EditAraIslerKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Listele;
end;

procedure TGorevListeAramaFrame.ListeEkleTusClick(Sender: TObject);
begin
      Application.CreateForm(TGorevListePaylasimDlg, GorevListePaylasimDlg);
      GorevListePaylasimDlg.ListeId:=0;
      GorevListePaylasimDlg.IslemOp:='E';
      GorevListePaylasimDlg.CheckHerkeseAcik.checked := True;

      GorevListePaylasimDlg.ShowModal;
      if GorevListePaylasimDlg.ModalResult = mrOk then begin
         Tablo.TablodanSorguAc(1,' select R.GOREVID, R.DEPARTMAN  FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan);
         TabloYenile(TabListe,[StrToInt(Kullanan),StrToInt(Kullanan),Tablo.Query1.Fields[0].AsInteger,Tablo.Query1.Fields[1].AsInteger,SubeId]);
         TabListe.Locate('ID', GorevListePaylasimDlg.ListeId, []);
      end;
      GorevListePaylasimDlg.Destroy;
end;

procedure TGorevListeAramaFrame.Listele;
var ops : string;
begin
   if PageListeler.ActivePageIndex=1 then begin
      TabListe.SQL.Text:= MemoProjeler.Text;
      if not TamYetkili then
         TabListe.SQL.Add(' and PRJ_SORUMLUSU_ID='+Kullanan);

      if EditAraProje.text<>'' then
         TabListe.SQL.Add(' and PROJEKODU like ''%'+EditAraProje.text+'%'' order by 3')
      else
         TabListe.SQL.Add(' order by 2,1 DESC');
      TabloYenile(TabListe,[]);
      TreeListeler.FullExpand;
   end
   else begin   // 'GL.ID not in (-995,-996,-997)';
         ops:= '  and  GL.ID not in (-995,-996,-997)  ';
         if Tablo.GENINI.ReadBoolean(Ops_CheckDemirbasGor, False)=False then
            ops := StringReplace(ops, '-995', '-5', []);

         if Tablo.GENINI.ReadBoolean(Ops_CheckServisGor, False)=False then
            ops := StringReplace(ops, '-996', '-6', []);

         if Tablo.GENINI.ReadBoolean(Ops_CheckToplantiGor, False)=False then
            ops := StringReplace(ops, '-997', '-7', []);


         TabListe.SQL.Text := stringreplace( MemoListe.Text, '--Opsiyon', ops,[]);
         if not OnaySistemiAktif then
            TabListe.SQL.Add(' where ID<> '+IntToStr(Onayla));
         TabListe.SQL.Add('order by ID');
         Tablo.TablodanSorguAc(1,' select R.GOREVID, R.DEPARTMAN  FROM KULLANICI K inner join ROLLER R on K.ROLID=R.ID where K.REHBERID='+Kullanan);
         TabloYenile(TabListe,[StrToInt(Kullanan),StrToInt(Kullanan),Tablo.Query1.Fields[0].AsInteger,Tablo.Query1.Fields[1].AsInteger,SubeId]);
   end;
end;

procedure TGorevListeAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

var satir:integer;
procedure TGorevListeAramaFrame.ExceldenBilgiAl1Click(Sender: TObject);
CONST c_ListeAdi=1; c_Konusu=2; c_Turu=3; c_Ackapa=4; c_Bayrak=5; c_Durum=6; c_Atayan=7;  c_Atanan=8;
      c_Basla=9; c_Bitis=10; c_Kod=11; c_Firma=12; c_Ilgili=13; c_Notlar=14; c_Yorum=15;  c_Sube=16;
var
    book:variant;
    excel,sheet:variant;
    sutun,i,RehID:integer;
    s,bastar,bittar:String;
    Trh:TDateTime;

    function excelsonsatir(AColumn: Integer): Integer;
    const
      xlUp = 3;
    begin
        Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
    end;

    function Kontrol(Tur:Char; Bilgi:String) : String;
    begin
        Bilgi := StringReplace(Trim(Bilgi),'''','',[rfreplaceall]);
        if Bilgi <> '' then begin
            case Tur  of
              'L' :begin
                    Tablo.TablodanSorguAc(1,'Select ID from GOREVLISTE where ADI='''+Bilgi+''' ');
                    if Tablo.Query1.IsEmpty then
                       Memokontrol.Lines.Add('Tanýmsýz Liste: '+Bilgi)
                   end;
              'G' : begin
                    Tablo.TablodanSorguAc(1,'Select DEGER from GENINI where BOLUM='+IntToStr(Ops_Gorev_Durum)+' and ANAHTAR='''+Bilgi+''' ');
                    if Tablo.Query1.IsEmpty then
                       Memokontrol.Lines.Add('Tanýmsýz Durum: '+Bilgi)
              end;
              'T' : begin
                    Tablo.TablodanSorguAc(1,'Select DEGER from GENINI where BOLUM='+IntToStr(Ops_Gorev_Turu)+' and ANAHTAR='''+Bilgi+''' ');
                    if Tablo.Query1.IsEmpty then
                       Memokontrol.Lines.Add('Tanýmsýz Tür: '+Bilgi)
              end;
              'P' : begin
                      Tablo.TablodanSorguAc(1,'Select ID from REHBER R where  R.FIRMA='''+Bilgi+''' ');
                      if Tablo.Query1.IsEmpty then
                          Memokontrol.Lines.Add('Tanýmsýz: '+Bilgi)
                    end;
              'R' : begin
                       if VarToStr(sheet.cells[satir,c_kod])<>'' then //Kod varsa
                          s:=' R.KOD='''+VarToStr(sheet.cells[satir,c_kod])+''' '
                       else
                          s:=' R.FIRMA='''+VarToStr(sheet.cells[satir,c_firma])+''' ';
                       Tablo.TablodanSorguAc(1,'Select ID from REHBER R where '+s);
                       if Tablo.Query1.IsEmpty then
                          Memokontrol.Lines.Add('Tanýmsýz: '+Bilgi)
                    end;
              'I' : begin
                       if VarToStr(sheet.cells[satir,c_kod])<>'' then //Kod varsa
                          s:=' R.KOD='''+VarToStr(sheet.cells[satir,c_kod])+''' '
                       else
                          s:=' R.FIRMA='''+VarToStr(sheet.cells[satir, c_firma])+''' ';
                       Tablo.TablodanSorguAc(1,'SELECT RP.ID,R.FIRMA FROM REHBER RP INNER JOIN REHBER R ON R.ID=RP.BAGID and RP.GRUP=334 WHERE '+
                          s+' AND RP.FIRMA='''+Bilgi+''' ');
                       if Tablo.Query1.IsEmpty then
                          Memokontrol.Lines.Add('Tanýmsýz Ýlgili:'+Bilgi+'/'+VarToStr(sheet.cells[satir, c_Firma]))
                       end;
            end;
            if not Tablo.Query1.IsEmpty then
                Result := Tablo.Query1.Fields[0].AsString;
        end
        else
          Result := 'null';
    end;
begin
  ShowMessage( GorevAktarim_Kosullari );
  excel := CreateOleObject('Excel.Application');
  Tablo.OpenDialog1.Title := 'Excel Dosyasýný Aç';
  Tablo.OpenDialog1.Filter := 'Excel Dosyalarý *.xls';

  if Tablo.OpenDialog1.Execute then begin
     try
     book := Excel.WorkBooks.Open(Tablo.OpenDialog1.FileName);
     Application.CreateForm(TBekletmeDlg,BekletmeDlg);


      Screen.Cursor := crHourGlass;
      sheet := book.worksheets[1];
      BekletmeDlg.Caption := 'Excelden veriler aktarýlýyor.Bekleyiniz...';
      BekletmeDlg.cxProgressBar1.Properties.Max := excelsonsatir(1)+1;
      BekletmeDlg.Show;

      MemoKontrol.visible := False;
      MemoKontrol.lines.Clear;
      for satir := 2 to excelsonsatir(1)+1 do begin
        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;
        Kontrol('L', VarToStr(sheet.cells[satir, c_ListeAdi])); // ListeAdý
        Kontrol('T', VarToStr(sheet.cells[satir, c_Turu])); // Türü
        Kontrol('G', VarToStr(sheet.cells[satir, c_Durum])); // Durum
        Kontrol('P', VarToStr(sheet.cells[satir, c_Atayan])); // Atayan
        Kontrol('P', VarToStr(sheet.cells[satir, c_Atanan])); // Atanan
        Kontrol('R', VarToStr(sheet.cells[satir, c_kod])+VarToStr(sheet.cells[satir,c_Firma])); // Müþteri
        Kontrol('I', VarToStr(sheet.cells[satir, c_Ilgili])); // Ýlgili
        Kontrol('P', VarToStr(sheet.cells[satir, c_Sube])); // Þube
      end;
      MemoKontrol.visible := MemoKontrol.lines.count>0;
      if MemoKontrol.visible then begin
         MemoKontrol.align:=alClient;
         LabelAra.caption := 'Kapat';
         EditAraIsler.visible := False;
         Screen.Cursor:=crDefault;
         exit;
      end;

      for satir := 2 to excelsonsatir(1)+1 do begin
        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;
        if VarToStr(sheet.cells[satir,1]) <> '' then begin
                Trh := StrToDateTimeDef(VarToStr(sheet.cells[satir, c_Basla]), 11111);
                if Trh = 11111 then bastar:='null'
                else bastar:=''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''' ';
                Trh := StrToDateTimeDef(VarToStr(sheet.cells[satir,c_Bitis]), 11111);
                if Trh = 11111 then bittar:='null'
                else bittar:=''''+FormatDateTime('yyyy-mm-dd hh:nn:ss', Trh)+''' ';
                Tablo.TablodanSorguAc(5,'insert into [GOREVLER] ([LISTEID],[KONUSU],TURU,[ACKAPA],[BAYRAK],[DURUM],[EKLEYEN],[BASLAMATARIHI],[BITISTARIHI],[REHBERID],[MUS_ILGILI])'+
                ' values('+Kontrol('L', VarToStr(sheet.cells[satir, c_Listeadi]))+','''+ StringReplace(VarToStr(sheet.cells[satir, c_Konusu]),'''','',[rfReplaceAll])+''','+Kontrol('T', VarToStr(sheet.cells[satir,c_Turu]))+',' +
                VarToStr(sheet.cells[satir,c_Ackapa])+','+VarToStr(sheet.cells[satir,c_Bayrak])+','+ Kontrol('G', VarToStr(sheet.cells[satir,c_Durum]))+','+Kontrol('P', VarToStr(sheet.cells[satir, c_Atayan]))+','+
                bastar+','+bittar+','+ Kontrol('R', VarToStr(sheet.cells[satir,c_kod])+VarToStr(sheet.cells[satir,c_Firma]))+','+Kontrol('I', VarToStr(sheet.cells[satir,c_Ilgili]))+') select scope_identity() ');
                if VarToStr(sheet.cells[satir, c_Atanan])<>'' then //atanan varsa
                   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' insert into [GOREVKULLANICI] ([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN])values('+Tablo.Query5.fields[0].AsString+',11,'+
                      Kontrol('P', VarToStr(sheet.cells[satir, c_Atanan]))+','+Kullanan+') ',[],[]);
                if VarToStr(sheet.cells[satir, c_Notlar])<>'' then //notlar varsa
                   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into [GOREVYORUM]([GOREVID],[TUR],[YORUM],[EKLEYEN])values('+Tablo.Query5.fields[0].AsString+',1,'''+StringReplace(VarToStr(sheet.cells[satir,c_Notlar]),'''','',[rfReplaceAll
                   ])+''','+Kullanan+')',[],[]);
                if VarToStr(sheet.cells[satir, c_Yorum])<>'' then //notlar varsa
                   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'insert into [GOREVYORUM]([GOREVID],[TUR],[YORUM],[EKLEYEN])values('+Tablo.Query5.fields[0].AsString+',2,'''+StringReplace(VarToStr(sheet.cells[satir,c_Yorum]),'''','',[rfReplaceAll
                   ])+''','+Kullanan+')',[],[]);
         end;
      end;

      excel.DisplayAlerts := False;
      excel.quit;
      excel := Unassigned;
      BekletmeDlg.Destroy;
      Application.Messagebox(PChar(Kaydedildi),Pchar(Uyari),MB_OK);
      //TabPlan.Close;
      //TabPlan.Open;
    finally
      Screen.Cursor:=crDefault;
    end;
  end;
end;


procedure TGorevListeAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TGorevListeAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TGorevListeAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TGorevListeAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TGorevListeAramaFrame.Gorunmez;
begin

end;

procedure TGorevListeAramaFrame.GorunmezOlacak;
begin

end;

procedure TGorevListeAramaFrame.Gorunur;
begin

end;

procedure TGorevListeAramaFrame.GorunurOlacak;
begin

end;

procedure TGorevListeAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TGorevListeAramaFrame.LabelAraClick(Sender: TObject);
begin
   MemoKontrol.Visible:=False;
   LabelAra.Caption := 'Ara';
   EditAraIsler.visible := True;
end;

procedure TGorevListeAramaFrame.ListeMenuPopup(Sender: TObject);
begin
   ListeyiSilMenu.Enabled := (TabListe.Fields[0].AsInteger > 0)
        and(Veritabani.VeriVarMi(Tablo.FDCnn,'select * from GOREVLER where LISTEID='+TabListe.Fields[0].AsString,[],[])=False)
        and((TamYetkili)or(TabListe.FieldByName('EKLEYEN').AsString=Kullanan));
   ListeyiDuzenleMenu.Enabled := (TamYetkili)or(TabListe.FieldByName('EKLEYEN').AsString=Kullanan);
   ListeyeKisiEkle1.Enabled := ListeyiDuzenleMenu.Enabled;
end;

procedure TGorevListeAramaFrame.ListeyiDuzenleMenuClick(Sender: TObject);
begin
  Application.CreateForm(TGorevListePaylasimDlg, GorevListePaylasimDlg);
     GorevListePaylasimDlg.ListeId:=TabListe.Fields[0].asInteger;
     GorevListePaylasimDlg.ListeBaslik.Text := TabListe.FieldByName('ADI').AsString;
     GorevListePaylasimDlg.CheckHerkeseAcik.Checked := TabListe.FieldByName('HERKESEACIK').AsBoolean;
     //GorevListePaylasimDlg.ProjeTus.Tag := TabListe.FieldByName('PROJEID').AsInteger;
     GorevListePaylasimDlg.IslemOp:='D';
  GorevListePaylasimDlg.ShowModal;
  if GorevListePaylasimDlg.ModalResult = mrOk then begin
     TabloYenile(TabListe,[StrToInt(Kullanan)]);
     TabListe.Locate('ID', GorevListePaylasimDlg.ListeId, []);
  end;
  GorevListePaylasimDlg.Destroy;

end;

procedure TGorevListeAramaFrame.ListeyiKopyala1Click(Sender: TObject);
var ID:integer;
begin
   ID := Tablo.SQLSatiriKopyala('GOREVLISTE', TabListe.Fields[0].AsInteger, ['ADI','EKLEYEN'],['Yeni Liste', Kullanan]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' insert into [GOREVLER] ([LISTEID],[KONUSU],[BASLAMATARIHI],[BITISTARIHI],[REHBERID],[MUS_ILGILI],[MUS_ILGILI2],'+
     ' [PROJEID],[BAYRAK],[ACKAPA],[DURUM],[TEKRARID],[ANIMSAT],[EKLEYEN])'+
     ' select [LISTEID]='+IntToStr(ID)+',[KONUSU],[BASLAMATARIHI],[BITISTARIHI],[REHBERID],[MUS_ILGILI],[MUS_ILGILI2],[PROJEID],[BAYRAK],[ACKAPA],[DURUM],'+
     ' [TEKRARID]=0,[ANIMSAT]=0,[EKLEYEN] from [GOREVLER] where LISTEID='+TabListe.Fields[0].AsString, [], []);
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' insert into [GOREVKULLANICI]([LISTGOREVID],[TUR],[REHBERID],[EKLEYEN]) '+
     'select [LISTGOREVID]='+IntToStr(ID)+',[TUR],[REHBERID],'+Kullanan+' from [GOREVKULLANICI] where TUR<=5 and LISTGOREVID='+TabListe.Fields[0].AsString, [], []);
   TabloYenile(TabListe,[StrToInt(Kullanan)]);
end;

procedure TGorevListeAramaFrame.ListeyiSilMenuClick(Sender: TObject);
begin
   if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT top 1 * FROM GOREVLER WHERE LISTEID='+TabListe.Fields[0].AsString,[],[]) then
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVLISTE set DURUM = 0 where ID='+TabListe.Fields[0].AsString,[],[])
   else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from GOREVKULLANICI where LISTGOREVID='+TabListe.Fields[0].AsString+' and TUR<=5',[],[]);
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from GOREVLISTE where ID='+TabListe.Fields[0].AsString,[],[]);
   end;
   TabloYenile(TabListe,[StrToInt(Kullanan)]);
end;

procedure TGorevListeAramaFrame.PageListelerChange(Sender: TObject);
begin
   case PageListeler.ActivePageIndex of
    0 : ComboKonusu.Text := '';
    1 : ;
   end;
   Listele;
   TreeListeler.OnClick(Self);

   //arama sekmesinde yeni butonu pasif olmalý
   if TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevEkleTus.visible then
      TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevEkleTus.Enabled := PageListeler.ActivePageIndex = 0;

   ComboKonusu.Text := EditAraIsler.Text;
   EditAraIsler.Text := '';
 {  if CheckTemas.Checked then begin
      CheckTemas.Checked := False;
      CheckTemasClick(Self);
      //TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).PanelYeniIs.visible := True;
      //TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevGridDBTableView1ACKAPASECIM.visible := True;
   end;  }
end;

procedure TGorevListeAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

function TGorevListeAramaFrame.GetRealDragSourceGridView(const aSource: TcxDragControlObject): TcxCustomGridView;
begin
  result := nil;
  if (TcxDragControlObject (aSource).Control is TcxGridSite) then begin
    result := TcxGridSite (TcxDragControlObject (aSource).Control).GridView;
  end;
end;

function TGorevListeAramaFrame.GetDragSourceGridView(
  const aSource: TcxDragControlObject): TcxCustomGridView;
begin
  result := GetRealDragSourceGridView (aSource);
  if result.IsDetail then
    result := result.PatternGridView;
end;

procedure TGorevListeAramaFrame.TreeListelerDblClick(Sender: TObject);
begin
   if (PageListeler.ActivePageIndex=1)and(TabListe.Fields[0].AsInteger>0) then
      if Tablo.ProjeSihirbazBaslat('D',  TabListe.Fields[0].AsInteger,TabListe.FieldByName('REHBERID').AsInteger,Tablo.GENINI.BugunTrh) > 0 then
         Listele;
end;

procedure TGorevListeAramaFrame.TreeListelerDragDrop(Sender, Source: TObject; X,Y: Integer);
var ANode: TcxTreeListNode;
    aRealGridView: TcxCustomGridView;
    DragID, DropID : integer;
    ADragnode: TcxTreeListNode;
begin
  Anode := TcxdbTreeList(Sender).GetNodeAt(X,Y);
  if ANode <> nil then
    DropID :=  TcxDBTreeListNode(ANode).KeyValue//       ParentKeyValue
  else
    DropID :=  -1;

  if (Source <> TreeListeler)and((DropId = Masaustu)or(DropId>0)) then begin  //Görev soldaki listelere sürüklenirse
//adn     aRealGridView := GetRealDragSourceGridView (TcxDragControlObject (Source));
//adn     DragID:= aRealGridView.DataController.Values[aRealGridView.DataController.FocusedRecordIndex,
//adn                 TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevGridDBTableView1ID.Index];
     //  TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).GorevUpdate(DragID , 'LISTEID='+IntToStr( DropID ));
    //Taþýnan Node Id si liste drag over dan alýnýr
     ADragnode := TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).ADragnode;
     if ADragnode <> nil then
        dragId := ADragnode.Values[0]
     else
        Abort;

     GorevUpdate(DragID , 'LISTEID='+IntToStr( DropID ));
     TGorevListeDlg(AnaFrameYoneticisi.AktifFrame.IcerikFrameYoneticisi.AktifFrame.Ornek).Listele;
  end;
end;

procedure TGorevListeAramaFrame.TreeListelerDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var ANode: TcxTreeListNode;
    TreeHitTest: TcxTreeListHitTest;
    TutulanNode,BirakilanNode: TcxTreeListNode;
begin
  if State = dsDragLeave then begin //
     TreeHitTest := (Sender as TcxDBTreeList).HitTest;
     if not TreeHitTest.HitAtNode then begin
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVLISTE set USTID = 0 where ID='+TabListe.Fields[0].AsString,[],[]);
        Listele;
     end;
  end
  else begin
      Anode := TcxTreeList(Sender).GetNodeAt(X,Y);
      if ANode <> nil then begin
         Caption := ANode.Values[0];
         Accept := True;
      end;
  end;
end;

procedure TGorevListeAramaFrame.TreeListelerMoveTo(Sender: TcxCustomTreeList;
  AttachNode: TcxTreeListNode; AttachMode: TcxTreeListNodeAttachMode;
  Nodes: TList; var IsCopy, Done: Boolean);
var
  dropId, dragId: Integer;
begin
  Sender.BeginUpdate;
  try
    if (Nodes.Count = 1)and(PageListeler.ActivePageIndex=1) then begin  //Projeler açýksa
      dropId := TcxDBTreeListNode( AttachNode ).KeyValue;
      if dropId>0 then begin//node deðil de proje adý üzerine býrakýldý
         Tablo.TablodanSorguAc(1, 'select ASAMA from PROJELER where ID='+IntToStr(dropId));
         dropId := StrToIntDef(Tablo.Query1.Fields[0].asstring,0);
      end;
      dragId := TcxDBTreeListNode( Nodes[0] ).Values[0];
      if DragId>0 then begin
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(abs(dropId))+' where ID='+IntToStr(dragId),[],[]);
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into [PROJEASAMA] ([PROJEID],[REHBERID],[ASAMA],[BASTAR],[AKTIF],[DURUM],[EKLEYEN])values('+
             IntToStr(abs(dragId))+',0,'+IntToStr(abs(dropId))+','''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',1,1,'+Kullanan+')',[],[]);
         Listele;
         TabListe.Locate('ID', abs(dragId), []);
      end;
    end
    else if Nodes.Count = 1 then begin  //Projeler kapalý ve liste diðer listenin altýna gelecekse
      dropId := TcxDBTreeListNode( AttachNode ).KeyValue;
      dragId := TcxDBTreeListNode( Nodes[0] ).Values[0];
      if (DragId>0)and(dropId>0) then begin
         //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update PROJELER set ASAMA='+IntToStr(abs(dropId))+' where ID='+IntToStr(dragId),[],[]);
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update GOREVLISTE set USTID = '+IntToStr(abs(dropId))+' where ID='+IntToStr(abs(dragId)),[],[]);
         Listele;
      end;
    end;
  finally
    Sender.EndUpdate;
  end;
  Done := True;
end;

procedure TGorevListeAramaFrame.TusAsagi(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TGorevListeAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TGorevListeAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TGorevListeAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TGorevListeAramaFrame);
end.

//						<OlayBagla hedefBilesen="EditAraIsler.Properties" hedefOlay="OnChange" kaynakMethod="AramaYap"/>




