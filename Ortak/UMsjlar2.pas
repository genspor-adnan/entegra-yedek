unit UMsjlar2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, ExtCtrls, Buttons, Db, ComCtrls, DBTables, 
  WSocket,MMSystem;

type
  TMesajDlg = class(TForm)
    Panel1: TPanel;
    DBCheckBox1: TDBCheckBox;
    DBNavigator1: TDBNavigator;
    BitBtn2: TBitBtn;
    DtsMesajlar: TDataSource;
    PageControl1: TPageControl;
    TabSheetGelen: TTabSheet;
    TabSheetGiden: TTabSheet;
    Panel2: TPanel;
    Label3: TLabel;
    Label2: TLabel;
    DBText1: TDBText;
    DBText2: TDBText;
    DBMemo1: TDBMemo;
    ComboKime: TDBComboBox;
    LD: TQuery;
    TabMesajlar: TQuery;
    procedure ComboKimeDropDown(Sender: TObject);
    procedure DtsMesajlarStateChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure TabMesajlarNewRecord(DataSet: TDataSet);
    procedure DBCheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure TabMesajlarAfterPost(DataSet: TDataSet);
    procedure TabMesajlarBeforeEdit(DataSet: TDataSet);
    procedure TabMesajlarAfterInsert(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MesajDlg: TMesajDlg;

procedure MesajKontrolu;

implementation

uses UTablo, UAnaForm, UTabDok;

{$R *.DFM}
var
   YeniMesaj : boolean;
   pc : array[0..140] of char;

procedure MesajKontrolu;
begin
  TabloDokum.MsjKontr.Close;
  TabloDokum.MsjKontr.SQL.Text := 'Select * From MESAJLAR Where KIMIN = "'+KullanAdi+'" and GIREN_CIKAN="G" and OKUNDU = 0';
  TabloDokum.MsjKontr.Open;
  TabloDokum.MsjKontr.Last;

  if (not TabloDokum.MsjKontr.Fields[0].IsNull) and
     (not (TabloDokum.MsjKontr.FieldByName('OKUNDU').AsString='1'))then begin
      StrPCopy(pc, FSesDosya);
      sndPlaySound(pc, snd_Async or snd_NoDefault);
      if AnaForm.MesajMenu.Tag = 0 then
         AnaForm.MesajMenu.Click
      else
         MesajDlg.PageControl1Change(MesajDlg);
  end;
end;

procedure TMesajDlg.ComboKimeDropDown(Sender: TObject);
begin
   ComboKime.Clear;
   ComboKime.Items.Add('*Tüm Kullanýcýlar*');
   Tablo.TabKullan.Close;
   Tablo.TabKullan.Open;
   Tablo.TabKullan.first;
   while not Tablo.TabKullan.eof do begin
      if Tablo.TabKullan.FieldByName('KULLANICIADI').AsString <> KullanAdi  then
         ComboKime.Items.Add(Tablo.TabKullan.FieldByName('KULLANICIADI').AsString);
      Tablo.TabKullan.next;
   end;
end;

procedure TMesajDlg.DtsMesajlarStateChange(Sender: TObject);
begin
//   tABLO.YetkiTuslariBelirle('Mesaj', '', 'AES', DtsMesajlar, MesajDlg.DBNavigator1);
end;

procedure TMesajDlg.PageControl1Change(Sender: TObject);
begin
   DBCheckBox1.Visible := True;
   Label2.Caption := 'Kimden';
   TabMesajlar.Close;
   TabMesajlar.SQL.Clear;
   case PageControl1.ActivePageIndex  of
     0 : TabMesajlar.SQL.Text := 'Select * From MESAJLAR Where KIMIN = "'+KullanAdi+'" and GIREN_CIKAN="G" order by TARIH desc';
     1 : begin
           DBCheckBox1.Visible := False;
           Label2.Caption := 'Kime';
           TabMesajlar.SQL.Text := 'Select * From MESAJLAR Where KIMIN = "'+KullanAdi+'" and GIREN_CIKAN="Ç" order by TARIH desc';
         end;
//     2 : Tablo.TabMesajlar.SQL.Text := 'Select * From Mesajlar Where KIMIN = "'+KullanAdi+'" and GIREN_CIKAN="G" and OKUNDU = 0 order by TARIH desc';
   end;
   TabMesajlar.Open;
   if PageControl1.ActivePageIndex = 1 then DBCheckBox1.Visible := False

   else ;
end;

procedure TMesajDlg.FormShow(Sender: TObject);
begin
   PageControl1Change(Self);
end;

procedure TMesajDlg.DBNavigator1Click(Sender: TObject;Button: TNavigateBtn);
var i : integer;
  procedure gonder(kime : string);
  begin
      LD.Params[0].AsString := kime;
      LD.Params[1].AsDateTime := now;
      LD.Params[2].AsString := KullanAdi; //kimdenkime
      LD.Params[3].AsString := 'G';   //gýren/cýkan
      LD.Params[4].AsString:='0';   //okundu
      LD.Params[5].AsMemo := DBMemo1.Text;
      LD.ExecSQL;
   end;
begin
   if Button = nbInsert then begin
      PageControl1.ActivePage := PageControl1.Pages[1];
      DBCheckBox1.Visible := False;
      Label2.Caption := 'Kime';
   end else if Button = nbPost then begin
      if ComboKime.Text = '*Tüm Kullanýcýlar*' then
         for i := 1 to ComboKime.Items.count-1 do
             gonder(ComboKime.Items[i])
      else gonder(ComboKime.Text);
  end;
end;

procedure TMesajDlg.TabMesajlarNewRecord(DataSet: TDataSet);
begin
   TabMesajlar.FieldByName('KIMIN').AsString := KullanAdi;
   TabMesajlar.FieldByName('TARIH').AsDateTime := Now;
   TabMesajlar.FieldByName('GIREN_CIKAN').AsString := 'Ç';
   TabMesajlar.FieldByName('OKUNDU').AsString:='0';
end;

procedure TMesajDlg.DBCheckBox1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TabMesajlar.Post;
end;

procedure TMesajDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   AnaForm.MesajMenu.Tag := 0;
end;

procedure TMesajDlg.FormActivate(Sender: TObject);
begin
    AnaForm.MesajMenu.Tag := 99;
end;

procedure TMesajDlg.TabMesajlarAfterPost(DataSet: TDataSet);
begin
    if not YeniMesaj then exit;
{    WSocketCLI.Proto        := 'udp';
    WSocketCLI.Addr         := '255.255.255.255';
    WSocketCLI.Port         := '1276';
    WSocketCLI.LocalPort    := '0';
    WSocketCLI.Connect;
    WSocketCLI.SendStr('mesajvar');
    WSocketCLI.Close;    }
end;

procedure TMesajDlg.TabMesajlarBeforeEdit(DataSet: TDataSet);
begin
   YeniMesaj := False;
end;

procedure TMesajDlg.TabMesajlarAfterInsert(DataSet: TDataSet);
begin
   YeniMesaj := True;
end;

end.
