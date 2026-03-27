unit UHesapPlani;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, FireDAC.Comp.Client, cxImageComboBox,
  cxTextEdit, cxCheckBox, cxTL, cxMaskEdit, cxDropDownEdit, cxTLExportLink,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, ExtCtrls, Menus,
  StdCtrls, cxCalendar, cxSplitter, dxSkinLondonLiquidSky, cxSpinEdit, ShellApi,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  THesapPlaniDlg = class(TForm)
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    btnKapat: TToolButton;
    DtsPlan: TDataSource;
    TabPlan: TFDQuery;
    cxDBTreeList1: TcxDBTreeList;
    cxDBTreeList1cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn2: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn4: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn7: TcxDBTreeListColumn;
    PopupMenu1: TPopupMenu;
    PasifleriGster1: TMenuItem;
    VarlklarGster1: TMenuItem;
    Pasifler1: TMenuItem;
    N1: TMenuItem;
    Kasalar1: TMenuItem;
    BankaHesaplar1: TMenuItem;
    CariKartlar1: TMenuItem;
    N2: TMenuItem;
    Hepsi1: TMenuItem;
    Ekle1: TMenuItem;
    SeiliyiKopyala1: TMenuItem;
    Sil1: TMenuItem;
    SeiliyiSil1: TMenuItem;
    SeiliveTmAltKategorilerinisil1: TMenuItem;
    MemoHesapPlani: TMemo;
    TabKartlar: TFDQuery;
    MemoBankalar: TMemo;
    MemoKasalar: TMemo;
    MemoCari: TMemo;
    SadecePlan1: TMenuItem;
    MemoGelir: TMemo;
    MemoMasraf: TMemo;
    Gelir1: TMenuItem;
    Masraf1: TMenuItem;
    cxDBTreeList1cxDBTreeListColumn5: TcxDBTreeListColumn;
    ToolButton1: TToolButton;
    ToolBar2: TToolBar;
    ToolButton2: TToolButton;
    PlanSil: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    cxSplitter1: TcxSplitter;
    MemoSQLBas: TMemo;
    MemoSQL320: TMemo;
    MemoSQL100: TMemo;
    MemoSQL102: TMemo;
    cxDBTreeList1cxDBTreeListColumn3: TcxDBTreeListColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    ResimGirMenu: TMenuItem;
    N3: TMenuItem;
    ExceldenBilgiekle1: TMenuItem;
    Shape1: TShape;
    ExceleGnder1: TMenuItem;
    cxDBTreeList1cxDBTreeListColumn6: TcxDBTreeListColumn;
    cxDBTreeList1cxDBTreeListColumn8: TcxDBTreeListColumn;
    procedure btnKapatClick(Sender: TObject);
    procedure DtsPlanStateChange(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure TabPlanNewRecord(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure CariKartlar1Click(Sender: TObject);
    procedure KartlariBirlestir;
    procedure BankaHesaplar1Click(Sender: TObject);
    procedure Kasalar1Click(Sender: TObject);
    procedure Hepsi1Click(Sender: TObject);
    procedure SadecePlan1Click(Sender: TObject);
    procedure Pasifler1Click(Sender: TObject);
    procedure TabPlanAfterPost(DataSet: TDataSet);
    procedure TabKartlarBeforeEdit(DataSet: TDataSet);
    procedure Gelir1Click(Sender: TObject);
    procedure Masraf1Click(Sender: TObject);
    procedure PlanSilClick(Sender: TObject);
    procedure TabPlanBeforePost(DataSet: TDataSet);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ResimGirMenuClick(Sender: TObject);
    procedure ExceldenBilgiekle1Click(Sender: TObject);
    procedure ExceleGnder1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
//  Resourcestring
//  YanlisTabHata = 'Kartlar üzerinde düzenleme yapamazsýnýz, sadece hesap planýný deðiþtirebilirsiniz. Lütfen Sað Tuþ menüsünden "Görünüm \ Sadece Plan" ý seçiniz.';

var
  HesapPlaniDlg: THesapPlaniDlg;

implementation
uses Utablo,PrjConst, UResimOlcumleme, jpeg, Fetautil,ComObj,UBekletme,LocOnFly;

{$R *.dfm}


procedure THesapPlaniDlg.BankaHesaplar1Click(Sender: TObject);
begin
  if BankaHesaplar1.Checked=True then
     BankaHesaplar1.Checked:=False
  Else
     BankaHesaplar1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;

procedure THesapPlaniDlg.KartlariBirlestir;
begin
  TabKartlar.Close;
  TabPlan.Close;
  if (CariKartlar1.Checked = False) And (BankaHesaplar1.Checked =False) And (Kasalar1.Checked =False ) then
  Begin;
    if Pasifler1.Checked = False then
       StringReplace(TabPlan.SQL.Text, 'order by 1',' where DURUM = 1  order by 1',[rfReplaceAll])
    Else StringReplace(TabPlan.SQL.Text, ' where DURUM = 1 ','',[rfReplaceAll]);

    DtsPlan.DataSet := TabPlan;
    TabPlan.Open;
  End Else Begin
    TabKartlar.SQL:=MemoHesapPlani.Lines;
    if Pasifler1.Checked=False then
       TabKartlar.SQL.Text := TabKartlar.SQL.Text + ' and DURUM = 1 ';
    if CariKartlar1.Checked = True then  begin //cariler eklenir
       TabKartlar.SQL.text := TabKartlar.SQL.text + MemoCari.Lines.text;
       if Pasifler1.Checked=False then
          TabKartlar.SQL.Text:= TabKartlar.SQL.Text + ' and DURUM = 1 ';
    end;
    if BankaHesaplar1.Checked = True then  begin//bankalar eklenir
       TabKartlar.SQL.text := TabKartlar.SQL.text + MemoBankalar.Lines.text;
       if Pasifler1.Checked=False then
          TabKartlar.SQL.Text:= TabKartlar.SQL.Text + ' and DURUM = 1 ';
    end;
    if Kasalar1.Checked = True then begin//kasalar eklenir
       TabKartlar.SQL.text := TabKartlar.SQL.text + MemoKasalar.Lines.text;
       if Pasifler1.Checked=False then
          TabKartlar.SQL.Text:= TabKartlar.SQL.Text + ' and DURUM = 1 ';
    end;
    if Kasalar1.Checked = True then begin//kasalar eklenir
       TabKartlar.SQL.text := TabKartlar.SQL.text + MemoGelir.Lines.text;
       if Pasifler1.Checked=False then
          TabKartlar.SQL.Text:= TabKartlar.SQL.Text + ' and DURUM = 1 ';
    end;
    if Kasalar1.Checked = True then begin//kasalar eklenir
       TabKartlar.SQL.text := TabKartlar.SQL.text + MemoMasraf.Lines.text;
       if Pasifler1.Checked=False then
          TabKartlar.SQL.Text:= TabKartlar.SQL.Text + ' and DURUM = 1 ';
    end;

    TabKartlar.SQL.Text := TabKartlar.SQL.Text+' order by 1';
    DtsPlan.DataSet := TabKartlar;
    TabKartlar.Open;
    if Pasifler1.Checked=True then
       StringReplace(TabKartlar.SQL.Text, ' and DURUM = 1 ','',[rfReplaceAll]);
  End;
end;




procedure THesapPlaniDlg.Kasalar1Click(Sender: TObject);
begin
  if Kasalar1.Checked=True then
     Kasalar1.Checked:=False
  Else
     Kasalar1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.CariKartlar1Click(Sender: TObject);
begin
  if CariKartlar1.Checked=True then
     CariKartlar1.Checked:=False
  Else
     CariKartlar1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.DtsPlanStateChange(Sender: TObject);
begin
  if DtsPlan.State in [dsEdit,dsInsert] then begin
    ToolBar2.Visible:=False;
    ToolBar1.Visible:=True;
  end else begin
    ToolBar1.Visible:=False;
    ToolBar2.Visible:=True;

  end;

end;

procedure THesapPlaniDlg.EkleTusClick(Sender: TObject);
begin
  if not (DtsPlan.State in [dsEdit,dsInsert]) then
    TabPlan.Append;

  //cxDBTreeList1cxDBTreeListColumn1.Editing:=True;
end;

procedure THesapPlaniDlg.ExceldenBilgiekle1Click(Sender: TObject);
var
    book:variant;
    excel,sheet:variant;
    satir, sutun,i,RehID:integer;


    function excelsonsatir(AColumn: Integer): Integer;
    const
      xlUp = 3;
    begin
        Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
    end;
begin

  excel := CreateOleObject('Excel.Application');
  Tablo.OpenDialog1.Title := 'Excel Dosyasýný Aç';
  Tablo.OpenDialog1.Filter := 'Excel Dosyalarý *.xls';

  if Tablo.OpenDialog1.Execute then begin
    book := Excel.WorkBooks.Open(Tablo.OpenDialog1.FileName);
    Application.CreateForm(TBekletmeDlg,BekletmeDlg);

    try
      Screen.Cursor := crHourGlass;
      sheet := book.worksheets[1];
      BekletmeDlg.Caption := 'Excelden veriler aktarýlýyor.Bekleyiniz...';
      BekletmeDlg.cxProgressBar1.Properties.Max := excelsonsatir(1)+1;
      BekletmeDlg.Show;

      for satir := 2 to excelsonsatir(1)+1 do begin

        BekletmeDlg.cxProgressBar1.Position := satir;
        BekletmeDlg.cxProgressBar1.Refresh;

           if VarToStr(sheet.cells[satir,1]) <> '' then begin
                Tablo.TablodanSorguAc(1,'insert into HESAPPLANI(HESAPKODU,HESAPADI,DIGITSAY,DURUM,EKLEYEN,EKLEMETARIHI,VARSAYILAN,SUBEID) values('''+
                VarToStr(sheet.cells[satir,1])+''','''+ VarToStr(sheet.cells[satir,2])+''',4,1,'''+Kullanan+''','''+
                FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''',1,0) select scope_identity() ');

           end;
      end;
      excel.DisplayAlerts := False;
      excel.quit;
      excel := Unassigned;
      BekletmeDlg.Destroy;
      Application.Messagebox(PChar(Kaydedildi),Pchar(Uyari),MB_OK);
      TabPlan.Close;
      TabPlan.Open;
    finally
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure THesapPlaniDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   TabloYenile(TabPlan, []);
end;

procedure THesapPlaniDlg.Gelir1Click(Sender: TObject);
begin
  if Gelir1.Checked=True then
     Gelir1.Checked:=False
  Else
     Gelir1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.Hepsi1Click(Sender: TObject);
begin
  Kasalar1.Checked := True;
  BankaHesaplar1.Checked := True;
  CariKartlar1.Checked := True;
  Gelir1.Checked := True;
  Masraf1.Checked := True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.IptalTusClick(Sender: TObject);
begin
  if DtsPlan.State in [dsEdit,dsInsert] then
    TabPlan.Cancel;
end;

procedure THesapPlaniDlg.KaydetTusClick(Sender: TObject);
begin
  //if DtsPlan.State in [dsEdit,dsInsert] then
    //TabPlan.Next;
   //TabPlan.Post;
   try
     cxDBTreeList1.GotoNext;
   finally
     cxDBTreeList1.GotoPrev;
   end;
end;

procedure THesapPlaniDlg.Masraf1Click(Sender: TObject);
begin
  if Masraf1.Checked=True then
     Masraf1.Checked:=False
  Else
     Masraf1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.Pasifler1Click(Sender: TObject);
begin
  if Pasifler1.Checked=True then
     Pasifler1.Checked:=False
  Else
     Pasifler1.Checked:=True;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.PlanSilClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabPlan.Delete;
end;

procedure THesapPlaniDlg.PopupMenu1Popup(Sender: TObject);
begin
   //Varsayýlan stoksa resimgirme  menüsü görünecek
   ResimGirMenu.Visible := TabPlan.FieldByName('VARSAYILAN').AsString = '1';
end;

procedure THesapPlaniDlg.ResimGirMenuClick(Sender: TObject);
var
  DosyaAdi: string;
  Pic : TJPEGImage;
begin
  if Tablo.OpenPictureDialog1.Execute then
  begin
    // DosyaAdi := ResimOlcumleme(Tablo.OpenPictureDialog1.Files[0]);
    //DosyaAdi := ResimKucult(Tablo.OpenPictureDialog1.Files[0], 130);
    Pic := TJpegImage.Create;
    Pic.LoadFromFile(Tablo.OpenPictureDialog1.Files[0]);
    JPGKucult(Pic,128);
   // if DosyaAdi <> '' then
    begin
      TabPlan.Edit;
      TabPlan.FieldByName('RESIM').Assign(Pic);
      Pic.Free;
      TabPlan.Post;
    end;
  end;
end;

procedure THesapPlaniDlg.SadecePlan1Click(Sender: TObject);
begin
  Kasalar1.Checked := False;
  BankaHesaplar1.Checked := False;
  CariKartlar1.Checked := False;
  Gelir1.Checked := False;
  Masraf1.Checked := False;
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.TabKartlarBeforeEdit(DataSet: TDataSet);
begin
  raise Exception.Create(YanlisTabHata);
end;

procedure THesapPlaniDlg.TabPlanAfterPost(DataSet: TDataSet);
begin
  KartlariBirlestir;
end;

procedure THesapPlaniDlg.TabPlanBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(TabPlan.FieldByName('HESAPKODU').AsString, 'HESAPKODU') then Abort;
   if not BoslukKontrol(TabPlan.FieldByName('HESAPADI').AsString, 'HESAPADI') then Abort;
   if pos('''', TabPlan.FieldByName('HESAPADI').AsString) > 0 then
      raise Exception.Create(Yanlis_Isaret);

end;

procedure THesapPlaniDlg.TabPlanNewRecord(DataSet: TDataSet);
begin
   TabPlan.FieldByName('GIRIS').AsInteger:= 0;
   TabPlan.FieldByName('DIGITSAY').AsInteger:= 0;
   TabPlan.FieldByName('DURUM').AsBoolean:= True;
   TabPlan.FieldByName('EKLEYEN').AsString := Kullanan;
   TabPlan.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure THesapPlaniDlg.ExceleGnder1Click(Sender: TObject);
begin
  Tablo.saveDialog1.Title := 'Excel Kayýt';
  Tablo.saveDialog1.InitialDir := GetCurrentDir;
  Tablo.saveDialog1.Filter := 'Excel|*.xls';
  Tablo.saveDialog1.DefaultExt := 'xls';
  Tablo.saveDialog1.FilterIndex := 1;

  if Tablo.SaveDialog1.Execute then begin
     cxExportTLToExcel(Tablo.saveDialog1.FileName, cxDBTreeList1);
     ShellExecute(Handle, 'open', PChar(Tablo.saveDialog1.FileName), nil, nil, SW_SHOWNORMAL);
  end;
end;

end.

