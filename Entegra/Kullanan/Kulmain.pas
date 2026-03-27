unit KulMain;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Menus, Messages,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin, Db,
  Grids, DBGrids, DBCtrls, Mask, ImgList, UTablo, SysUtils, IniFiles, UMesaj,
  System.ImageList;
type
  TKullaniciDlg  = class(TForm)
    Panel2: TPanel;
    ScrollBox: TPanel;
    Panel1: TPanel;
    DtsKullan: TDataSource;
    TreeView1: TTreeView;
    TabDokumler: TFDTable;
    Query1: TFDQuery;
    Label4: TLabel;
    ImageList1: TImageList;
    CancelBtn: TBitBtn;
    Query2: TFDQuery;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditKULLANICIADI: TDBEdit;
    EditSIFRE: TDBEdit;
    EditKULLANICI: TDBEdit;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    ComboGrup: TDBComboBox;
    DBEdit2: TDBEdit;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    DBNavigator: TDBNavigator;
    BitBtn2: TBitBtn;
    PageControl2: TPageControl;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    Ekleme: TCheckBox;
    Degistirme: TCheckBox;
    Silme: TCheckBox;
    Gorsun: TRadioButton;
    Gormesin: TRadioButton;
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    EditGrup: TEdit;
    TreeView2: TTreeView;
    PopupMenu1: TPopupMenu;
    Sadeceuygula1: TMenuItem;
    N1: TMenuItem;
    Tumunuuygula1: TMenuItem;
    Label8: TLabel;
    EditAra: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure DtsKullanStateChange(Sender: TObject);
    procedure TreeView1Enter(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure GorsunClick(Sender: TObject);
    procedure GormesinClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DegistirTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure ComboGrupDropDown(Sender: TObject);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure ListeKaydet;
    procedure ListeAktar;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure Kaydet(KulAdi:String);
    procedure YetkiUygula;
  public
    { Public declarations }
    Modul1:String;
  end;

var
  KullaniciDlg: TKullaniciDlg;

implementation

{$R *.DFM}
var
   c : Char;
   p : PChar;
   i, j : integer;
   Yukari : Boolean;
   Modul,EkranAdi, KullaniciAdi : String[30];
   Dir, s : String;


procedure TKullaniciDlg.ListeAktar;
var
Node:TTreeNode;
i:integer;
begin
Tablo.TabListe.Close;
Tablo.TabListe.SQL.Text:='Select * from KULLAN_BASLIK WHERE MODUL = ''' + Modul1 + ''' ORDER BY SIRANO';
Tablo.TabListe.Open;

TreeView1.Items.Clear;
while not Tablo.TabListe.Eof do
begin
  if Tablo.TabListe.FieldByName('ALTSIRA').AsString = '' THEN
  begin
    TreeView1.Items.Add(nil, Tablo.TabListe.FieldByName('BASLIK').AsString);
    Node:=TreeView1.Items[TreeView1.Items.count-1];
  end
  else
  begin
    for i:=0 To TreeView1.Items.Count -1 do
      if TreeView1.Items.Item[i].Text = Tablo.TabListe.FieldByName('ALTSIRA').AsString then
      begin
         Node:=TreeView1.Items.Item[i];
         Break;
      end;
    TreeView1.Items.AddChild(Node, Tablo.TabListe.FieldByName('BASLIK').AsString);
    Node.Expand(true);
  end;
  Tablo.TabListe.Next;
end;

end;

procedure TKullaniciDlg.ListeKaydet;
var
SQLResult:String;
i:integer;
Alt:String;
begin
  SQLResult:='delete from KULLAN_BASLIK';
  Tablo.FDCnn.ExecSQL(SQLResult);
  for i:=0 to TreeView1.Items.Count-1 do
  begin
    if assigned(TreeView1.Items.Item[i].Parent) then
      Alt:=TreeView1.Items.Item[i].Parent.text
    else
      Alt:='';
    SQLResult:='insert into KULLAN_BASLIK Values(' + inttostr(i) + ',''' + TreeView1.Items[i].Text + ''',''' + alt +''',''' + Modul1 + ''')';
    Tablo.FDCnn.ExecSQL(SQLResult);
  end;
end;

procedure TKullaniciDlg.FormCreate(Sender: TObject);
var
   Nereye : TStringlist;
   RandevuIni : TIniFile;
   MenuTut, Nod : TTreeNode;
   function Bul(Tr:TTreeView; s:String):TTreeNode;
   begin
     Bul := nil;
     for i := 0 to Tr.Items.Count -1 do
       if Tr.Items[i].Text = s then begin

          Bul := Tr.Items[i];
          Exit;
       End;
   end;
begin
   Tablo.TabKullan.Open;
   Tablo.TabKulHar.Open;
   Yukari := False;
   EkranAdi := '';
   TabDokumler.Open;
   TabDokumler.First;
//   TreeView2.Items.Add(nil, 'Genel D�k�mler');
//   tv2 := Bul(TreeView2, 'Genel D�k�mler');
   TreeView2.Items.Clear;
   while not TabDokumler.eof do begin
     Modul := TabDokumler.FieldByName('MODUL').AsString;
     if pos('K', Modul)>0  then begin    //MenuTut := Bul(TreeView1, 'Genel D�k�mler')
        if TabDokumler.FieldByName('GRUBU').AsString = '' then
           TreeView2.Items.AddChild(nil, TabDokumler.FieldByName('RAPORADI').AsString) { Add a child }//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'
        else begin
          MenuTut := Bul(TreeView2, TabDokumler.FieldByName('GRUBU').AsString);
          if MenuTut <> nil then
             TreeView2.Items.AddChild(MenuTut, TabDokumler.FieldByName('RAPORADI').AsString) { Add a child }//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'
          else begin
             TreeView2.Items.AddChild(nil, TabDokumler.FieldByName('GRUBU').AsString); { Add a child }//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'
             MenuTut := Bul(TreeView2, TabDokumler.FieldByName('GRUBU').AsString);
             TreeView2.Items.AddChild(MenuTut, TabDokumler.FieldByName('RAPORADI').AsString); { Add a child };//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'
          end;
        end;
     end {else if pos('L', Modul)>0 then MenuTut := Bul(TreeView1, 'Lab-D�k�mler')
     else if pos('D', Modul)>0 then MenuTut := Bul(TreeView1, 'Rad-D�k�mler')
     else if pos('M', Modul)>0 then MenuTut := Bul(TreeView1, 'Mua-D�k�mler')
     else if pos('R', Modul)>0 then MenuTut := Bul(TreeView1, 'Ran-D�k�mler')
     else if pos('E', Modul)>0 then MenuTut := Bul(TreeView1, 'Ecz-D�k�mler');
//     else i := 8;
     if (MenuTut <> nil)and(pos('K', Modul)=0)  then
        TreeView1.Items.AddChild(MenuTut, TabDokumler.FieldByName('RAPORADI').AsString);} { Add a child };//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'

     TabDokumler.Next;
   end;
//        TreeView1.Items.AddChild(TreeView1.Items[i], TabDokumler.FieldByName('RAPORADI').AsString); { Add a child };//     if TabDokumler.FieldByName('MODUL').AsString = 'Genotip'

   MenuTut := Bul(TreeView1, 'Genel D�k�mler');
//   MenuTut.TreeView.Assign(TreeView2);
     for i := 0 to TreeView2.Items.Count -1 do
//        memo1.Lines.Add(TreeView2.Items[i].text+' '+IntToStr(TreeView2.Items[i].Index));
       if TreeView2.Items[i].Level = 0 then
          Nod := TreeView1.Items.AddChild(MenuTut, TreeView2.Items[i].Text)
       else
          TreeView1.Items.AddChild(Nod, TreeView2.Items[i].Text);
//       if TreeView2.Items[i].HasChildren then
//          Nod := TreeView1.Items.AddChild(MenuTut, TreeView2.Items[i].Text);




   Nereye := TStringlist.Create;
   GetDir(0, Dir);

{--   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select distinct NEREYE, SIRA From RANSAATLERI order by SIRA, NEREYE';
   Tablo.Query1.Open;}
//--   while not Tablo.Query1.eof do begin
//      Nereye.Items.Add(Tablo.Query1.Fields[0].AsString);
//      NereyeSag.Items.Add(Tablo.Query1.Fields[0].AsString);

 //--     MenuTut :=Bul(TreeView1, 'Nereye');
 //--     TreeView1.Items.AddChild(MenuTut{TreeView1.Items[i]}, Tablo.Query1.Fields[0].AsString); { Add a child };

 //--     Tablo.Query1.Next;
 //--  end;

(*   RandevuIni := TIniFile.Create(Dir+'\Randevu.ini');
   RandevuIni.ReadSection('RANDEVU_NEREYE', Nereye);
   For j := 0 to Nereye.Count-1 do begin
     MenuTut :=Bul(TreeView1, 'Nereye');
     TreeView1.Items.AddChild(MenuTut{TreeView1.Items[i]}, Nereye.Strings[j]); { Add a child };
   end;*)
   Nereye.Free;

   PageControl1Change(Self);
   UstTus.Click;
(*   //Kimlik Gruplar�n� getir..
   Query1.SQL.Text := 'Select Distinct GRUP From KIMLIK';
   Query1.Open;
   while not Query1.eof do begin
      i :=Bul('Kimlik-Grup');
      TreeView1.Items.AddChild(TreeView1.Items[i], Query1.Fields[0]); { Add a child };
   end;*)
end;

procedure TKullaniciDlg.TreeView1Click(Sender: TObject);
begin
   if TreeView1.Selected=nil then exit;

   PageControl1Change(Self);
   EkranAdi := TreeView1.Selected.Text;
   GroupBox1.Caption := EkranAdi;
   Edit1.Text := '';
   if (EkranAdi = 'Muayene')or(EkranAdi = 'Kimlik-Grup')or(EkranAdi = '�skonto')or(EkranAdi = 'Kasa')or(EkranAdi = 'Fat-Ko�an�') then
      Edit1.Visible := True
   else
      Edit1.Visible := False;

{   Tablo.TabKulHar.Refresh;
   if EkranAdi = 'Kimlik-Grup' then begin
      Tablo.TabKulHar.Filter := 'KULLANICIADI='''+Tablo.TabKulHar.FieldByName('KULLANICIADI').AsString+''' and EKRAN='''+EkranAdi+'*''';
      Tablo.TabKulHar.Filtered := True;
      if Tablo.TabKulHar.RecordCount > 0 then
         EkranAdi := Tablo.TabKulHar.FieldByName('EKRAN').AsString;
      Tablo.TabKulHar.Filtered := False;        Tablo.TabKullan.FieldByName('KULLANICIADI').AsString
   end; }

   if Tablo.KullaniciBilgisi(KullaniciAdi, EkranAdi) then begin
      begin
         Gorsun.Checked := Tablo.TabKulHar.FieldByName('GORME').AsString = '1';
         Gormesin.Checked := not (Tablo.TabKulHar.FieldByName('GORME').AsString = '1');
         Ekleme.Checked := Tablo.TabKulHar.FieldByName('EKLEME').AsString = '1';
         Degistirme.Checked := Tablo.TabKulHar.FieldByName('DEGISTIRME').AsString = '1';
         Silme.Checked := Tablo.TabKulHar.FieldByName('SILME').AsString = '1';
      end;
      Edit1.Text:=Tablo.TabKulHar.FieldByName('BILGI').AsString ;
   end else begin
      Gorsun.Checked := True;
      Ekleme.Checked := True;
      Degistirme.Checked := True;
      Silme.Checked := True;
      Gorsun.Checked := True;
   end;
end;

procedure TKullaniciDlg.Kaydet(KulAdi:String);
   Function BoolToString(t:Boolean):String;
   begin
      if t then BoolToString := '1'
      else BoolToString := '0'
   end;
begin
   Query1.Close;
   Query1.SQL.Text := 'Delete from Kulhar where KULLANICIADI='''+KulAdi+''' and EKRAN ='''+ EkranAdi+'''';
   Query1.ExecSQL;
   if Gormesin.Checked then begin
      Query1.Close;
      Query1.SQL.Text := 'Insert Into Kulhar (KULLANICIADI,EKRAN,GORME,EKLEME,DEGISTIRME,SILME,BILGI) values ('''+KulAdi+''','''+EkranAdi+''',0,0,0,0,'''+Edit1.Text+''')';
      Query1.ExecSQL;
   end
   else begin
         Query1.Close;
         Query1.SQL.Text := 'Insert Into Kulhar (KULLANICIADI,EKRAN,GORME,EKLEME,DEGISTIRME,SILME,BILGI) values ('''+
                  KulAdi+''','''+EkranAdi+''',1,'+BoolToString(Ekleme.Checked)+','+
                  BoolToString(Degistirme.Checked)+','+BoolToString(Silme.Checked)+','''+Edit1.Text+''')';
         Query1.ExecSQL;
   end;
end;

procedure TKullaniciDlg.YetkiUygula;
begin
   Tablo.Query2.Close;
   Tablo.Query2.SQL.Text := 'select KULLANICIADI from KULLAN where GRUP='''+KullaniciAdi+'''';
   Tablo.Query2.Open;
   while not Tablo.Query2.eof do begin
       Kaydet(Tablo.Query2.Fields[0].AsString);
       Tablo.Query2.next;
   end;
end;

procedure TKullaniciDlg.BitBtn1Click(Sender: TObject);
begin
   PageControl1Change(Self);
   Kaydet(KullaniciAdi);
   if PageControl1.ActivePage.Name='TabSheet2' then
      YetkiUygula;
end;

procedure TKullaniciDlg.DtsKullanStateChange(Sender: TObject);
begin
   if DtsKullan.State in [dsEdit, dsInsert] then begin
      DBNavigator.VisibleButtons := [nbPost, nbCancel];
      GroupBox1.Visible := False;
   end else begin
      DBNavigator.VisibleButtons := [nbFirst,nbPrior,nbNext,nbLast, nbInsert, nbDelete];
      GroupBox1.Visible := True;
   end
end;

procedure TKullaniciDlg.TreeView1Enter(Sender: TObject);
begin
   if Tablo.TabKullan.State in [dsEdit, dsInsert] then
      Tablo.TabKullan.post;
end;

procedure TKullaniciDlg.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
   TreeView1Click(Self);
end;

procedure TKullaniciDlg.GorsunClick(Sender: TObject);
begin
   Ekleme.Visible := True;
   Degistirme.Visible := True;
   Silme.Visible := True;
end;

procedure TKullaniciDlg.GormesinClick(Sender: TObject);
begin
   Ekleme.Visible := False;
   Degistirme.Visible := False;
   Silme.Visible := False;
end;

procedure TKullaniciDlg.CancelBtnClick(Sender: TObject);
begin
   Close;
end;

procedure TKullaniciDlg.BitBtn2Click(Sender: TObject);
var Yenikul:String;
begin
   Yenikul :='';
   if not MesajStrAl('', 'Yeni kullan�c� ad�n� giriniz : ','E',nil,Yenikul, '','E',nil, Yenikul) then exit;
   Query1.Close;
   Query1.Sql.Text := 'Select * From KULHAR Where KULLANICIADI='''+KullaniciAdi+'''';
   Query1.Open;
   Query2.Close;
   Query2.Sql.Text := 'Insert Into KULLAN (KULLANICIADI, SIFRE, KULLANICI, UZMANLIK, GORUNMESIN, SUPER, GRUP) Values('''+
                      Yenikul+''','''','''','''',0,0,'''+ComboGrup.Text+''')';
   Query2.ExecSQL;
   Query1.first;
   while not Query1.eof do begin
      Query2.Close;
      Query2.SQL.Text := 'Insert Into Kulhar (KULLANICIADI,EKRAN,GORME,EKLEME,DEGISTIRME,SILME,BILGI) values ('''+Yenikul+
        ''','''+Query1.Fields[1].AsString+''','''+Query1.Fields[2].AsString+''','''+Query1.Fields[3].AsString+''','''+
        Query1.Fields[4].AsString+''','''+Query1.Fields[5].AsString+''','''+Query1.Fields[6].AsString+''')';
      Query2.ExecSQL;
      Query1.next;
   end;
   Tablo.TabKullan.Refresh;
end;

procedure TKullaniciDlg.FormShow(Sender: TObject);
begin
  Tablo.TabKullan.Last;

end;

procedure TKullaniciDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
begin
   MesajOkunan := '';
   if not MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then exit;

   Query1.Close;
   Query1.SQL.Text := 'select TOP 1 ANAHTAR From GENOTIPINI where BOLUM=''KulGruplari'' and ANAHTAR= ''' +MesajOkunan+'''';
   Query1.Open;
   if Query1.RecordCount>0 then begin
      ShowMessage('Daha �nceden eklenmi� grup ad�..');
      exit;
   end;

   GenotipIni.WriteString('KulGruplari',MesajOkunan,'');
   EditGrup.Text := MesajOkunan;
   TreeView1Click(Self);
end;

procedure TKullaniciDlg.SilTusClick(Sender: TObject);
var Eski : String[20];
begin
   if Application.MessageBox('Bu grup ve bununla ilgili t�m k�s�tlamalar silinecektir. Devam etsin mi?', 'Dikkat! Silme ��lemi!!!',MB_YESNO)<>IDYES then
      Exit;
   Eski := EditGrup.Text;
   Query1.Close;
   Query1.SQL.Text := 'Delete From KulHar where KULLANICIADI = ''' +Eski+'''';
   Query1.ExecSQL;
   Query1.Close;
   Query1.SQL.Text := 'update KULLAN set GRUP='''' where GRUP = ''' +Eski+'''';
   Query1.ExecSQL;
   GenotipIni.DeleteKey('KulGruplari', EditGrup.Text);
   UstTus.Click;
   if EditGrup.Text=Eski then
      EditGrup.Text :='';
   Tablo.TabKullan.Refresh;
   TreeView1Click(Self);
end;

procedure TKullaniciDlg.DegistirTusClick(Sender: TObject);
var Eski, Yeni : String[20];
    MesajOkunan : String;
begin
   Eski:=EditGrup.Text;
   MesajOkunan := Eski;
   if not MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then exit;
   Yeni := MesajOkunan;
   GenotipIni.DeleteKey('KulGruplari', Eski);
   GenotipIni.WriteString('KulGruplari',Yeni,'');
   EditGrup.Text := Yeni;
   Query1.Close;
   Query1.SQL.Text := 'update KULLAN set GRUP='''+Yeni+''' where GRUP = ''' +Eski+'''';
   Query1.ExecSQL;
   Query1.Close;
   Query1.SQL.Text := 'update KulHar set KULLANICIADI='''+Yeni+''' where KULLANICIADI = ''' +Eski+'''';
   Query1.ExecSQL;
   Tablo.TabKullan.Refresh;
   TreeView1Click(Self);
end;

procedure TKullaniciDlg.AltTusClick(Sender: TObject);
begin
   Query1.Close;
   Query1.SQL.Text := 'select TOP 1 ANAHTAR From GENOTIPINI where BOLUM=''KulGruplari'' and ANAHTAR< ''' +EditGrup.Text+''' order by ANAHTAR DESC';
   Query1.Open;
   if Query1.RecordCount>0 then
      EditGrup.Text := Query1.Fields[0].AsString;
   TreeView1Click(Self);   
end;

procedure TKullaniciDlg.UstTusClick(Sender: TObject);
begin
   Query1.Close;
   Query1.SQL.Text := 'select TOP 1 ANAHTAR From GENOTIPINI where BOLUM=''KulGruplari'' and ANAHTAR> ''' +EditGrup.Text+'%'' order by ANAHTAR';
   Query1.Open;
   if Query1.RecordCount>0 then
      EditGrup.Text := Query1.Fields[0].AsString;
   TreeView1Click(Self);
end;

procedure TKullaniciDlg.PageControl1Change(Sender: TObject);
begin
   if PageControl1.ActivePage.Name='TabSheet1' then
      KullaniciAdi := EditKULLANICIADI.Text
   else if PageControl1.ActivePage.Name='TabSheet2' then
      KullaniciAdi := EditGRUP.Text;
end;

procedure TKullaniciDlg.ComboGrupDropDown(Sender: TObject);
begin
   GenotipIni.ReadSection('KulGruplari',ComboGrup.Items);
end;

procedure TKullaniciDlg.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Tablo.TabKullan.Locate('KULLANICIADI', EditAra.Text, [loPartialKey]);
end;

procedure TKullaniciDlg.Button1Click(Sender: TObject);
begin
TreeView1.SaveToFile('C:\KullananAgac.xls');
end;

procedure TKullaniciDlg.SpeedButton1Click(Sender: TObject);
var
Kayit:String;
SQLResult:String;
begin
  if MesajStrAl('L�tfen eklenecek kayd�n ad�n� giriniz...', 'Kay�t : ', 'E', nil,Kayit , '', 'E', nil,kayit) then
  begin
    TreeView1.Items.Add(nil,Kayit);
    ListeKaydet;
  end;
end;

procedure TKullaniciDlg.SpeedButton2Click(Sender: TObject);
var
Kayit,SQLREsult:String;
begin
  if MesajStrAl('L�tfen eklenecek kayd�n ad�n� giriniz...', 'Kay�t : ', 'E', nil,Kayit , '', 'E', nil,kayit) then
  begin
    TreeView1.items.AddChild(TreeView1.Selected,kayit);
    TreeView1.Items[TreeView1.Selected.Index].Expand(true);
    ListeKaydet;
  end;
end;

procedure TKullaniciDlg.SpeedButton3Click(Sender: TObject);
begin
TreeView1.Items.Delete(TreeView1.Selected);
ListeKaydet;
end;

procedure TKullaniciDlg.FormActivate(Sender: TObject);
begin
ListeAktar;
end;

end.






