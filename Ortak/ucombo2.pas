unit UCombo;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, IniFiles;

type
  TListeAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    ListBox1: TListBox;
    Label1: TLabel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    BitBtn1: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EkleTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListeAyarlaDlg: TListeAyarlaDlg;
  procedure ComboIniDuzenle(AnahtarKelime1 : String; Ini1 : TIniFile);

implementation
uses UMesaj, FetaUtil;
{$R *.DFM}
var
   i, j, say : integer;
   AnahtarKelime : String;
   Ini : TIniFile;

procedure ComboIniDuzenle(AnahtarKelime1:String; Ini1 : TIniFile);
Begin
    Application.CreateForm(TListeAyarlaDlg, ListeAyarlaDlg);
    AnahtarKelime := AnahtarKelime1;
    Ini := Ini1;
    ListeAyarlaDlg.ShowModal;
    ListeAyarlaDlg.Free;
End;

procedure TListeAyarlaDlg.FormShow(Sender: TObject);
begin
   INIToList(ListBox1.Handle, AnahtarKelime, Ini);
   ListBox1.ItemIndex := 0;
end;

procedure TListeAyarlaDlg.UstTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = 0) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex-1) ;
   ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
end;

procedure TListeAyarlaDlg.AltTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = ListBox1.Items.Count-1) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex+1) ;
   ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
end;

procedure TListeAyarlaDlg.SilTusClick(Sender: TObject);
begin
   if ListBox1.Items.Count = 0 then exit;
   ListBox1.Items.Delete(ListBox1.ItemIndex) ;
end;

procedure TListeAyarlaDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
   Ini.WriteString(AnahtarKelime, 'SAYI', IntToStr(ListBox1.Items.Count));
   for i := 0 to ListBox1.Items.Count-1 do
       Ini.WriteString(AnahtarKelime, IntToStr(i+1), ListBox1.Items[i]);
   for j := i+1 to say do
       Ini.DeleteKey(AnahtarKelime, IntToStr(j))
end;

procedure TListeAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
begin
  if TBitBtn(Sender).Name = 'EkleTus' then
     MesajOkunan := ''
  else
     MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];
     
  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', MesajOkunan, '', MesajOkunan) then
     if TBitBtn(Sender).Name = 'EkleTus' then
        ListBox1.Items.Add(MesajOkunan)
     else
        ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
end;

end.
