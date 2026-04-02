unit UListeDinamik;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Db, DBTables;

type
  TListeDinamikDlg = class(TForm)
    Bevel1: TBevel;
    ListBox1: TListBox;
    Label1: TLabel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    KapatTus: TBitBtn;
    KaydetTus: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListeDinamikDlg: TListeDinamikDlg;
  Function ListeDuzenle(var Liste:TStringList):integer;

implementation
uses UMesaj;
{$R *.DFM}
var
   j : integer;
   s : String;

Function ListeDuzenle(var Liste:TStringList):integer;
var i, yer : integer;
Begin
    Application.CreateForm(TListeDinamikDlg, ListeDinamikDlg);
    ListeDinamikDlg.ListBox1.Items.AddStrings(Liste);
    ListeDinamikDlg.ListBox1.ItemIndex := 0;
    ListeDuzenle := ListeDinamikDlg.ShowModal;
    Liste.Clear;
    for i := 0 to ListeDinamikDlg.ListBox1.Items.Count - 1  do
        Liste.Add(ListeDinamikDlg.ListBox1.Items[i]);
    ListeDinamikDlg.Free;
End;

procedure TListeDinamikDlg.FormShow(Sender: TObject);
begin
//   Ini.ReadSectionValues(AnahtarKelime, ListBox1.Items);
//   ListBox1.ItemIndex := 0;
end;

procedure TListeDinamikDlg.UstTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = 0) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex-1) ;
end;

procedure TListeDinamikDlg.AltTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = ListBox1.Items.Count-1) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex+1) ;
end;

procedure TListeDinamikDlg.SilTusClick(Sender: TObject);
begin
   if ListBox1.Items.Count = 0 then exit;
   ListBox1.Items.Delete(ListBox1.ItemIndex) ;
end;

procedure TListeDinamikDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
begin
  if TBitBtn(Sender).Name = 'EkleTus' then
     MesajOkunan := ''
  else
     MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
     if TBitBtn(Sender).Name = 'EkleTus' then
        ListBox1.Items.Add(MesajOkunan)
     else
        ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
end;

end.
