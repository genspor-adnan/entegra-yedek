unit UKuyruk;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, StdCtrls, Buttons, Menus, ComCtrls, ToolWin,
  ExtCtrls, ImgList, UFDCompatHelpers, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxintl, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGrid, cxGridCustomPopupMenu,
  cxGridPopupMenu, cxTimeEdit;

type
  TKuyrukDlg = class(TForm)
    DtsKuyruk: TDataSource;
    TabKuyruk: TADOQuery;
    PopupMenu1: TPopupMenu;
    KuyruktanSil1: TMenuItem;
    ToolBar1: TToolBar;
    IlkTus: TToolButton;
    OncekiTus: TToolButton;
    SonrakiTus: TToolButton;
    BugunTus: TToolButton;
    ErisTus: TToolButton;
    KapatTus: TToolButton;
    Panel1: TPanel;
    ImageList1: TImageList;
    Panel2: TPanel;
    Label1: TLabel;
    AraAd: TLabel;
    N1: TMenuItem;
    AlanEkleKaldr1: TMenuItem;
    KurukDegisMenu: TMenuItem;
    N2: TMenuItem;
    CagriCihaziMenu: TMenuItem;
    GeldiOlarakIsaretleMenu: TMenuItem;
    GelmediOlarakIsaretleMenu: TMenuItem;
    MonthCalendar1: TMonthCalendar;
    N3: TMenuItem;
    BelirsizlerdeMenu: TMenuItem;
    cxGridPopupMenu1: TcxGridPopupMenu;
    KuyrukGridDBTableView1: TcxGridDBTableView;
    KuyrukGridLevel1: TcxGridLevel;
    KuyrukGrid: TcxGrid;
    cxIntl1: TcxIntl;
    KuyrukGridDBTableView1DOSYANO: TcxGridDBColumn;
    KuyrukGridDBTableView1ADSOYAD: TcxGridDBColumn;
    KuyrukGridDBTableView1RANDEVU: TcxGridDBColumn;
    KuyrukGridDBTableView1GELIS: TcxGridDBColumn;
    KuyrukGridDBTableView1HZRLIK: TcxGridDBColumn;
    KuyrukGridDBTableView1GIRIS: TcxGridDBColumn;
    KuyrukGridDBTableView1CIKIS: TcxGridDBColumn;
    KuyrukGridDBTableView1TETKIK: TcxGridDBColumn;
    KuyrukGridDBTableView1GIRIS2: TcxGridDBColumn;
    KuyrukGridDBTableView1CIKIS2: TcxGridDBColumn;
    KuyrukGridDBTableView1AYRILIS: TcxGridDBColumn;
    KuyrukGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    ComboDurum: TComboBox;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure KuyruktanSil1Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure ErisTusClick(Sender: TObject);
    procedure BugunTusClick(Sender: TObject);
    procedure SonrakiTusClick(Sender: TObject);
    procedure OncekiTusClick(Sender: TObject);
    procedure IlkTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure AlanEkleKaldr1Click(Sender: TObject);
    procedure RadioBekleyenClick(Sender: TObject);
    procedure RadioTumClick(Sender: TObject);
    procedure CagriCihaziMenuClick(Sender: TObject);
    procedure GeldiOlarakIsaretleMenuClick(Sender: TObject);
    procedure GelmediOlarakIsaretleMenuClick(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure MonthCalendar1Click(Sender: TObject);
    procedure BelirsizlerdeMenuClick(Sender: TObject);
    procedure CheckYatanClick(Sender: TObject);
    procedure ToolBar1DblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComboDurumChange(Sender: TObject);
  private
    { Private declarations }
     procedure KuyrukSecClick(Sender: TObject);
  public
    { Public declarations }
    KuyrukAdi, KuyrukDr : String;
    SonucAlanKuyrukCiksin:boolean;
    procedure Kuyruga_At(Nereye, Dr, Yer, Dosyano,Aciklama : String; GelisNo, PolSNo:SmallInt);
    procedure AdsoyadDuzelt;
    procedure KuyrukTarih;
  end;

var
  KuyrukDlg: TKuyrukDlg;

implementation

uses UTablo, UTabDok, UCombo, UListeCheck;

{$R *.DFM}

var Tarih : TDateTime;
    s:String[20];
    ListelerAyri, Belirsizlerde, Yatan : Boolean;

procedure TKuyrukDlg.Kuyruga_At(Nereye, Dr, Yer, Dosyano,Aciklama : String; GelisNo, PolSNo:SmallInt);
  Function Dakika2Str(Dak:Integer):String;
  Var
     Tut,Tut2:String[2];
  Begin
    Tut:=IntToStr(Dak Div 60);
    If (Tut[0]=#1) Then Tut:='0'+Tut;
    Tut2:=IntToStr(Dak Mod 60);
    If (Tut2[0]=#1) Then Tut2:='0'+Tut2;
    Dakika2Str := Tut+':'+Tut2;
  End;
begin
  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'Select SIRANO,DOSYANO,GELISNO,NEREYE, DR, BOLUMSIRANO From KUYRUK Where (NEREYE='''+Nereye+
      ''' or NEREYE='''' or NEREYE is NULL) and TARIH >= '''+FormatDateTime('mm/dd/yyyy', GenotipIni.BugunTrh)+' 00:00'''+
       ' and TARIH <= '''+FormatDateTime('mm/dd/yyyy', GenotipIni.BugunTrh)+' 23:59'''+
       ' and ADSOYAD = '''+Tablo.TabKimlik.Fields[1].AsString+' '+Tablo.TabKimlik.Fields[2].AsString+'''';
//       ' and (GELISNO=0 or GELISNO='+IntToStr(Gelisno)+')';
  Tablo.Query3.Open;

  if Tablo.Query3.RecordCount > 0 then begin
     Tablo.Query4.Close;
     Tablo.Query4.SQL.Text:='';
     if Tablo.Query3.FieldByName('DOSYANO').AsString = '' then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'update KUYRUK set DOSYANO='''+Dosyano+''' where SIRANO='+Tablo.Query3.Fields[0].AsString;
        Tablo.Query4.ExecSQL;
     end;

     if (Nereye<>'')and(Tablo.Query3.FieldByName('NEREYE').AsString <> Nereye) then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'update KUYRUK set NEREYE='''+Nereye+''' where SIRANO='+Tablo.Query3.Fields[0].AsString;
        Tablo.Query4.ExecSQL;
     end;

     if (Dr<>'')and(Tablo.Query3.FieldByName('DR').AsString <> Dr) then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'update KUYRUK set DR='''+Dr+''' where SIRANO='+Tablo.Query3.Fields[0].AsString;
        Tablo.Query4.ExecSQL;
     end;

     if Tablo.Query3.FieldByName('GELISNO').AsInteger = 0 then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'update KUYRUK set GELISNO='+IntToStr(GelisNo)+' where SIRANO='+Tablo.Query3.Fields[0].AsString;
        Tablo.Query4.ExecSQL;
     end;

     if (PolSno>0)and(Tablo.Query3.FieldByName('BOLUMSIRANO').AsInteger < 1) then begin
        Tablo.Query4.Close;
        Tablo.Query4.SQL.Text := 'update KUYRUK set BOLUMSIRANO='+IntToStr(PolSno)+' where SIRANO='+Tablo.Query3.Fields[0].AsString;
        Tablo.Query4.ExecSQL;
     end;
     exit;
   end;

  Tablo.Query3.Close;
  Tablo.Query3.SQL.Text := 'Select NEREYE, DOKTOR, TARIH, RANSAATI, DOSYANO, DURUM From RANDEVU Where NEREYE='''+Nereye+
      ''' and (DOKTOR='''' or DOKTOR ='''+Dr+''') and ADSOYAD='''+Tablo.TabKimlik.Fields[1].AsString+' '+Tablo.TabKimlik.Fields[2].AsString+
      ''' and TARIH >= '''+FormatDateTime('mm/dd/yyyy', GenotipIni.BugunTrh)+' 00:00'''+
       ' and TARIH <= '''+FormatDateTime('mm/dd/yyyy', GenotipIni.BugunTrh)+' 23:59''';
  Tablo.Query3.Open;

  if (Tablo.Query3.RecordCount>0)and(Tablo.Query3.FieldByName('DURUM').AsString = '') then begin
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text := 'update RANDEVU set DURUM=''Geldi'' where NEREYE='''+Tablo.Query3.Fields[0].AsString+
         ''' and DOKTOR='''+Tablo.Query3.Fields[1].AsString+''' and TARIH='''+FormatDateTime('MM/DD/YYYY 00:00:00',Tablo.Query3.FieldByName('TARIH').AsDateTime)+''' and RANSAATI='+
         Tablo.Query3.Fields[3].AsString;
      Tablo.Query4.ExecSQL;
  end;


  if Tablo.Query3.FieldByName('RANSAATI').AsString = '' then
     s:=''
  else
     s:=Dakika2Str(Tablo.Query3.FieldByName('RANSAATI').AsInteger);

  Tablo.Query4.Close;
  Tablo.Query4.SQL.Text := 'Insert Into KUYRUK (TARIH, NEREYE, DR, DOSYANO, GELISNO,ADSOYAD,RANDEVU,GELIS,ACIKLAMA,BOLUMSIRANO)VALUES('+
      ''''+FormatDateTime('mm/dd/yyyy hh:mm', GenotipIni.BugunTrh)+''','''+Nereye+''','''+Dr+''','''+Dosyano+
      ''','+IntToStr(GelisNo)+','''+ Tablo.TabKimlik.Fields[1].AsString+' '+
      Tablo.TabKimlik.Fields[2].AsString+''','''+s+''','''+FormatDateTime('hh:mm', GenotipIni.BugunTrh)+''','''+Aciklama+''','+IntToStr(PolSNo)+')';
  try
  Tablo.Query4.ExecSQL;
  except
  end;
end;

procedure TKuyrukDlg.AdsoyadDuzelt;
begin
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text := 'update KUYRUK set ADSOYAD='''+Tablo.TabKimlik.Fields[1].AsString+' '+
                       Tablo.TabKimlik.Fields[2].AsString+''' where DOSYANO='''+Tablo.TabKimlik.Fields[0].AsString+'''';
   Tablo.Query4.ExecSQL;
end;

procedure TKuyrukDlg.FormActivate(Sender: TObject);
begin
   AraAd.Caption := '';
   BugunTus.Click;
    KuyrukGrid.SetFocus;
end;


procedure TKuyrukDlg.KuyruktanSil1Click(Sender: TObject);
begin
   if Application.MessageBox(PChar(TabKuyruk.FieldByName('ADSOYAD').AsString+' adlý hasta kuyruktan silinecektir. Onaylýyor musunuz?'), 'Silme Onayý', MB_OKCANCEL)<> IDOK then exit;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Delete From KUYRUK Where DOSYANO = '''+TabKuyruk.FieldByName('DOSYANO').AsString+'''';
   Tablo.Query1.ExecSQL;
   FormActivate(Self);
end;

procedure TKuyrukDlg.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TKuyrukDlg.ErisTusClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TKuyrukDlg.KuyrukTarih;
var i : smallint;
    SQLYatan:String;
begin
   KuyrukDlg.Panel1.Caption := FormatDateTime('dd/mm dddd', Tarih);
   KuyrukDlg.TabKuyruk.Close;
   KuyrukDlg.TabKuyruk.SQL.Text := ' Select KUYRUK.DOSYANO, ADSOYAD,'''' AS POLIKLINIK,'''' AS TEDAVI,ACIKLAMA,'+
                               ' RANDEVU,GELIS,HZRLIK,GIRIS,CIKIS,TETKIK,GIRIS2,CIKIS2,AYRILIS,DRSIRA,SIRANO From KUYRUK';;
   KuyrukDlg.TabKuyruk.SQL.Add(' Where (NEREYE LIKE '''+KuyrukDlg.KuyrukAdi+'%''');
   if Belirsizlerde then
      KuyrukDlg.TabKuyruk.SQL.Add(' or ISNULL(NEREYE,'''')='''') ')
   else
      KuyrukDlg.TabKuyruk.SQL.Add(' ) ');
   KuyrukDlg.TabKuyruk.SQL.Add(' and ADSOYAD LIKE '''+KuyrukDlg.AraAd.Caption+'%'' AND (DR is null or DR like '''+KuyrukDlg.KuyrukDr+'%'')');
   if not KuyrukDlg.SonucAlanKuyrukCiksin then
      KuyrukDlg.TabKuyruk.SQL.Add(' and TARIH >= '''+FormatDateTime('mm/dd/yyyy', Tarih)+' 00:00'''+
                                  ' and TARIH <= '''+FormatDateTime('mm/dd/yyyy', Tarih)+' 23:59'''+
                                  ' and SIRANO IN (select min(SIRANO) from KUYRUK '+
                                  ' where '+
                                  ' (NEREYE LIKE '''+KuyrukDlg.KuyrukAdi+'%'' or NEREYE is null or NEREYE='''') and ADSOYAD LIKE '''+KuyrukDlg.AraAd.Caption+'%'' AND (DR is null or DR like '''+KuyrukDlg.KuyrukDr+'%'')'+
                                  ' AND TARIH >= '''+FormatDateTime('mm/dd/yyyy', Tarih)+' 00:00'''+
                                  ' and TARIH <= '''+FormatDateTime('mm/dd/yyyy', Tarih)+' 23:59'''+
                                  ' group by DOSYANO)');

   if KuyrukDlg.ComboDurum.ItemIndex = 1 then begin
      if ListelerAyri then
         KuyrukDlg.TabKuyruk.SQL.Add(' and DRSIRA is null')
      else
         KuyrukDlg.TabKuyruk.SQL.Add(' and (CIKIS is null or CIKIS='''')and(AYRILIS is null or AYRILIS='''')');
   end;

   SQLYatan:= 'Select KUYRUK.DOSYANO, ADSOYAD, POLIKLINIK, TEDAVI, ACIKLAMA, RANDEVU,GELIS,'+
                     ' HZRLIK,GIRIS,CIKIS,TETKIK,GIRIS2,CIKIS2,AYRILIS,DRSIRA,SIRANO From KUYRUK, GELISLER '+
                     ' Where KUYRUK.DOSYANO=GELISLER.DOSYANO AND KUYRUK.GELISNO=GELISLER.GELISNO AND '+
                     ' ADSOYAD LIKE '''+KuyrukDlg.AraAd.Caption+'%'' AND NEREYE = ''YATAN''';

   if KuyrukDlg.ComboDurum.ItemIndex = 3  then
      KuyrukDlg.TabKuyruk.SQL.Add(' union '+SQLYatan)
   else if KuyrukDlg.ComboDurum.ItemIndex = 2 then
     KuyrukDlg.TabKuyruk.SQL.Text:=SQLYatan;

   if ListelerAyri then
      KuyrukDlg.TabKuyruk.SQL.Add(' order by DRSIRA');

 KuyrukDlg.TabKuyruk.Open;

 //for i := 5 to 13 do
//   if KuyrukDlg.TabKuyruk.Fields[i].DataType = FtDate then
//  TDateTimeField(KuyrukDlg.TabKuyruk.Fields[i]).DisplayFormat :='HH:NN'
//   TDateTimeField(KuyrukDlg.TabKuyruk.Fields[4]).DisplayFormat :='HH:NN'
end;



procedure TKuyrukDlg.BugunTusClick(Sender: TObject);
begin
   Tarih := Date;
   KuyrukTarih;
end;

procedure TKuyrukDlg.SonrakiTusClick(Sender: TObject);
begin
   Tarih := Tarih + 1;
   KuyrukTarih;
end;

procedure TKuyrukDlg.OncekiTusClick(Sender: TObject);
begin
   Tarih := Tarih - 1;
   KuyrukTarih;
end;

procedure TKuyrukDlg.IlkTusClick(Sender: TObject);
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select min(TARIH) From KUYRUK';
   Tablo.Query1.Open;
   if Tablo.Query1.RecordCount < 1 then raise exception.Create('Kuyruk Boþ...');
   Tarih := Tablo.Query1.Fields[0].AsDateTime;
   KuyrukTarih;
end;

procedure TKuyrukDlg.KuyrukSecClick(Sender: TObject);
begin
   s := TMenuItem(Sender).Caption;
   Delete(s, Pos('&',s),1);
   if s='Kayýt Kabul' then s := '';
   KuyrukAdi := s;
   KuyrukDr :='' ;
   KuyrukTarih;
end;


procedure TKuyrukDlg.FormCreate(Sender: TObject);
var i:smallint;
begin
   if TabloDokum.Modul = 'G' then
      KuyrukAdi := 'Radyoloji';
   ComboDurum.ItemIndex:=0;
   SonucAlanKuyrukCiksin := False;
   KuyrukGridDBTableView1.RestoreFromRegistry('KuyrukGrid',true,false,[gsoUseFilter],'KuyrukGrid');

   Belirsizlerde := GenRegIni.RegReadString('Kuyruk',Kullanan+'KuyrukBelirsiz', '0','C')='1';
   BelirsizlerdeMenu.Checked := Belirsizlerde;


   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select DEGER from RANDEVUINI where BOLUM=''GenelOpsiyon'' and ANAHTAR=''Listelerayri''';
   Tablo.Query1.Open;
   ListelerAyri := Tablo.Query1.Fields[0].AsString='1';

{   for i := 5 to 13 do begin
     if TabKuyruk.Fields[i].DataType = FtDate then
        TDateTimeField(KuyrukGridDBTableView1.Columns[i].DataBinding.Field).DisplayFormat := 'HH:NN'
  end;
}
   TabloDokum.MenuIslemleri(KurukDegisMenu, KuyrukSecClick, 'Ekle', 'Kayýt Kabul', '',-1);
   TabloDokum.MenuIslemleri(KurukDegisMenu, KuyrukSecClick, 'Ekle', 'Lab', '',-1);
   TabloDokum.MenuIslemleri(KurukDegisMenu, KuyrukSecClick, 'Ekle', 'Radyoloji', '',-1);
   TabloDokum.MenuIslemleri(KurukDegisMenu, KuyrukSecClick, 'Ekle', '-', '',-1);
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select AD From POLIKLNK order by AD';
   Tablo.Query1.Open;
   while not Tablo.Query1.eof do begin
     TabloDokum.MenuIslemleri(KurukDegisMenu, KuyrukSecClick, 'Ekle', Tablo.Query1.Fields[0].AsString, '',-1);
     Tablo.Query1.Next;
   end;
end;

procedure TKuyrukDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if Key = #13 then ErisTus.Click
   else if Key = #27 then KapatTus.Click
   else if Key = #8 then begin
            AraAd.Caption:='';
            KuyrukTarih;
   end
   else if (key in ['A'..'Z'])or(key in ['a'..'z'])or(key in ['ý','Ý','ð','Ð','þ','Þ','ü','Ü','ç','Ç','ö','Ö']) then begin
            AraAd.Caption:=AraAd.Caption+key;
            KuyrukTarih;
   end;
end;

procedure TKuyrukDlg.AlanEkleKaldr1Click(Sender: TObject);
var i : smallint;
begin
   Application.CreateForm(TListeCheckDlg, ListeCheckDlg);
   ListeCheckDlg.ListAmac.Items.Add('BugunTus');
   ListeCheckDlg.ListAmac.Items.Add('SonrakiTus');
   ListeCheckDlg.ListAmac.Items.Add('OncekiTus');
   ListeCheckDlg.ListAmac.Items.Add('');

   for i := 5 to 13 do
       ListeCheckDlg.ListAmac.Items.Add(TabKuyruk.Fields[i].FieldName);
   for i := 0 to ListeCheckDlg.ListAmac.Items.Count-1 do
     ListeCheckDlg.ListAmac.Checked[i] := GenotipIni.ReadBool('Kuyruk Alanlar', ListeCheckDlg.ListAmac.Items[i],True);
   ListeCheckDlg.ShowModal;
   if ListeCheckDlg.ModalResult = mrOK then begin
      for i := 0 to ListeCheckDlg.ListAmac.Items.Count-1 do
          GenotipIni.WriteBool('Kuyruk Alanlar', ListeCheckDlg.ListAmac.Items[i],ListeCheckDlg.ListAmac.Checked[i]);
   end;
   ListeCheckDlg.Destroy;
end;


procedure TKuyrukDlg.RadioBekleyenClick(Sender: TObject);
begin
{      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukBekleyen', '1','C');
   KuyrukTarih;}
end;

procedure TKuyrukDlg.RadioTumClick(Sender: TObject);
begin
{      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukBekleyen', '0','C');
      KuyrukTarih;}
end;

procedure TKuyrukDlg.CagriCihaziMenuClick(Sender: TObject);
begin
   s := GenRegIni.RegReadString('Kuyruk','SIRAPORTNO', '01','C');
   Winexec(pCHAR('C:\Psign.exe ['+s+'][UNBOLD]'+TabKuyruk.FieldByName('ADSOYAD').AsString+'[BEEP][STOP]'), SW_HIDE);
//   Winexec(pCHAR('C:\Psign.exe [06]'+TabKuyruk.FieldByName('ADSOYAD').AsString+'[STOP]'), SW_HIDE	);
//   C:\Psign.exe [1][UNBOLD]ADNAN ODABAÞI[BEEP][STOP]
end;

procedure TKuyrukDlg.GeldiOlarakIsaretleMenuClick(Sender: TObject);
var SNo:Integer;
begin
//   TabKuyruk.Edit;
//   TabKuyruk.FieldByName('GIRIS').AsDateTime := now;
//   TabKuyruk.Post;
   SNo := TabKuyruk.FieldByName('SIRANO').AsInteger;
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text := 'update KUYRUK set GIRIS='''+FormatDateTime('MM/DD/YYYY HH:NN',GenotipIni.BugunTrh)+''' where SIRANO='+TabKuyruk.FieldByName('SIRANO').AsString;
   Tablo.Query4.ExecSQL;
   KuyrukTarih;
   while (SNo<>TabKuyruk.FieldByName('SIRANO').AsInteger)and(not TabKuyruk.eof) do
      TabKuyruk.next;
end;

procedure TKuyrukDlg.GelmediOlarakIsaretleMenuClick(Sender: TObject);
var SNo:Integer;
begin
//   TabKuyruk.Edit;
//   TabKuyruk.FieldByName('GIRIS').AsDateTime := null;
//   TabKuyruk.Post;
   SNo := TabKuyruk.FieldByName('SIRANO').AsInteger;
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text := 'update KUYRUK set GIRIS=null where SIRANO='+TabKuyruk.FieldByName('SIRANO').AsString;
   Tablo.Query4.ExecSQL;
   KuyrukTarih;
   while (SNo<>TabKuyruk.FieldByName('SIRANO').AsInteger)and(not TabKuyruk.eof) do
      TabKuyruk.next;
end;

procedure TKuyrukDlg.Panel1Click(Sender: TObject);
begin
    MonthCalendar1.Date := GenotipIni.BugunTrh;
    MonthCalendar1.Visible := not MonthCalendar1.Visible
end;

procedure TKuyrukDlg.MonthCalendar1Click(Sender: TObject);
begin
   MonthCalendar1.Visible := False;
   Tarih := MonthCalendar1.Date;
   KuyrukTarih;
end;

procedure TKuyrukDlg.BelirsizlerdeMenuClick(Sender: TObject);
begin
   Belirsizlerde := not Belirsizlerde;
   BelirsizlerdeMenu.Checked := Belirsizlerde;
   if Belirsizlerde then
      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukBelirsiz', '1','C')
   else
      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukBelirsiz', '0','C');
   KuyrukTarih;
end;

procedure TKuyrukDlg.CheckYatanClick(Sender: TObject);
begin
//   GenotipIni.WriteBool('Kuyruk', Kullanan+'Yatan',True);
{   Yatan := not Yatan ;
   CheckYatan.Checked := Yatan;
   if Yatan then
      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukYatan', '1','C')
   else
      GenRegIni.RegWriteString('Kuyruk',Kullanan+'KuyrukYatan', '0','C');

   KuyrukTarih;}
end;

procedure TKuyrukDlg.ToolBar1DblClick(Sender: TObject);
begin
   showmessage(KuyrukDlg.TabKuyruk.SQL.text)
end;

procedure TKuyrukDlg.FormDestroy(Sender: TObject);
begin
  KuyrukDlg.KuyrukGridDBTableView1.StoreToRegistry('KuyrukGrid',true,[gsoUseFilter],'KuyrukGrid');
end;

procedure TKuyrukDlg.ComboDurumChange(Sender: TObject);
begin
   KuyrukTarih;
   KuyrukGrid.SetFocus;
end;

end.

