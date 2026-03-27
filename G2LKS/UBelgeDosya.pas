unit UBelgeDosya;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, DBGrids, DB, ADODB,ShellAPI;

type
  TBelgeDosyaDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnGoster: TBitBtn;
    btnKapat: TBitBtn;
    DBGrid1: TDBGrid;
    DtsBelgeDosya: TDataSource;
    TabBelgeDosya: TADOQuery;
    OpenDialog1: TOpenDialog;
    btnOnayla: TBitBtn;
    btnOnayIptal: TBitBtn;
    procedure btnKapatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure btnGosterClick(Sender: TObject);
    procedure btnOnaylaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BelgeDosyaDlg: TBelgeDosyaDlg;
  surucu, dizin : string;

implementation
Uses UTablo;

{$R *.dfm}

procedure TBelgeDosyaDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;

procedure TBelgeDosyaDlg.btnOnaylaClick(Sender: TObject);
begin
   if Tablo.TabFaturaListesi.FieldByName('MUHAKTAR').AsString='1' then
    begin
        Application.MessageBox('Bu giriþin aktarýmý yapýlmýþ Onay bilgisi deðiþtirilemez','U Y A R I',MB_OK+MB_ICONWARNING);
        abort;
    end;
   if Application.MessageBox('Bu giriþin Onay Durumu deðiþtirilecektir, Onaylýyor musunuz?','O N A Y',MB_YESNO+MB_ICONQUESTION)  = IDNO then abort;

   
   Tablo.StokMuhAktarimIzni(anahtarno,(Sender As TBitBtn).Tag);
   Tablo.TabFaturaListesi.Edit;
   Tablo.TabFaturaListesi.FieldByName('AKTARILABILIR').AsBoolean:=True;
   Tablo.TabFaturaListesi.Post;

end;

procedure TBelgeDosyaDlg.FormCreate(Sender: TObject);
begin
   surucu:= GenRegIni.RegReadString('Stok','BelgeSurucu','C:','C');
   dizin := GenRegIni.RegReadString('Stok','BelgeDizin','\Belgeler\','C');
end;

procedure TBelgeDosyaDlg.DBGrid1DblClick(Sender: TObject);
begin
  btnGoster.Click;
end;

procedure TBelgeDosyaDlg.btnGosterClick(Sender: TObject);
begin
   if TabBelgeDosya.RecordCount<=0 then abort;
 if TabBelgeDosya.FieldByName('DOSYAADI').AsString='' Then abort;

   ShellExecute(Handle, 'open',pchar(surucu+TabBelgeDosya.FieldByName('DOSYAADI').AsString),nil,nil,SW_SHOWNORMAL)

end;

end.
