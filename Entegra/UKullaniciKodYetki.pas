unit UKullaniciKodYetki;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, Buttons, ExtCtrls, DB, FireDAC.Comp.Client, StdCtrls;

type
  TKullaniciKodYetkiDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    GridKullanicilar: TDBGrid;
    DBGrid2: TDBGrid;
    EditKullaniciAdi: TEdit;
    Label1: TLabel;
    EditKod: TEdit;
    TabKodYetki: TFDQuery;
    DtsKodYetki: TDataSource;
    Label2: TLabel;
    DtsKullanicilar: TDataSource;
    TabKullanicilar: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure EditKullaniciAdiChange(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure TabKullanicilarAfterScroll(DataSet: TDataSet);
    procedure SpeedButton4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KullaniciKodYetkiDlg: TKullaniciKodYetkiDlg;

implementation
Uses UTablo;

{$R *.dfm}

procedure TKullaniciKodYetkiDlg.FormCreate(Sender: TObject);
begin
   TabloYenile(TabKullanicilar,[EditKullaniciAdi.Text+'%']);
end;

procedure TKullaniciKodYetkiDlg.EditKullaniciAdiChange(Sender: TObject);
begin
  if Length(EditKullaniciAdi.Text)>2 then
   TabloYenile(TabKullanicilar,[EditKullaniciAdi.Text+'%']);
end;

procedure TKullaniciKodYetkiDlg.SpeedButton3Click(Sender: TObject);
begin
 if TabKullanicilar.RecordCount<=0 then abort;
 if StringReplace(EditKod.Text,' ','',[rfReplaceAll]) ='' then abort;

  Tablo.Query2.Close;
  Tablo.Query2.SQL.Text:= 'SELECT COUNT(KOD) FROM REHBER WHERE KOD LIKE '''+EditKod.Text+'%'' ';
  Tablo.Query2.Open;

  if Tablo.Query2.RecordCount <=0 then
   begin
     Application.MessageBox('Girilen kod değeri ile başlayan kart bilgisi bulunamadı.','B İ L G İ',MB_OK+MB_ICONINFORMATION);
     abort;
   end
  else
   begin
     Tablo.Query3.Close;
     Tablo.Query3.SQL.Text:= 'IF NOT EXISTS (SELECT KULLANICIADI FROM KULHAR WHERE KULLANICIADI = '''+ TabKullanicilar.Fields[0].AsString+''' '+
                             ' and EKRAN = ''Gent-Kod Yetki-'+EditKod.Text+''' AND BILGI = '''+EditKod.Text+''' ) '+
                             ' INSERT INTO KULHAR (KULLANICIADI, EKRAN, GORME, BILGI ) '+
                             ' VALUES ('''+TabKullanicilar.Fields[0].AsString+''',''Gent-Kod Yetki-'+EditKod.Text+''',''0'','''+EditKod.Text+''') ';

     Tablo.Query3.ExecSQL;
     TabloYenile(TabKodYetki,[TabKullanicilar.Fields[0].AsString ]);
   end;

end;

procedure TKullaniciKodYetkiDlg.TabKullanicilarAfterScroll(
  DataSet: TDataSet);
begin
 if TabKullanicilar.RecordCount<=0 then abort;
   TabloYenile(TabKodYetki,[TabKullanicilar.Fields[0].AsString ]);
end;

procedure TKullaniciKodYetkiDlg.SpeedButton4Click(Sender: TObject);
begin
    if TabKullanicilar.RecordCount<=0 then abort;
    if TabKodYetki.RecordCount<=0 then abort;

    if (Application.MessageBox('Seçili kayıt silinecektir. Onaylıyor musunuz?','O N A Y',MB_YESNO+MB_ICONQUESTION))= ID_YES then
     begin
       Tablo.Query4.Close;
       Tablo.Query4.SQL.Text:= ' DELETE FROM KULHAR WHERE KULLANICIADI = '''+TabKullanicilar.Fields[0].AsString+''' '+
                               ' and EKRAN = ''Gent-Kod Yetki-'+ TabKodYetki.Fields[0].AsString+''' ';
       Tablo.Query4.ExecSQL;
       TabloYenile(TabKodYetki,[TabKullanicilar.Fields[0].AsString ]);                            
     end;
end;

end.

