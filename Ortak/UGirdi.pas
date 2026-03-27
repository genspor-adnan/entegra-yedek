unit UGirdi;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,UCombo, Buttons, ExtCtrls,
  ComCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox;

type
  TGirdiAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    PageControl1: TPageControl;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Label3: TLabel;
    Label4: TLabel;
    cxImageComboBox1: TcxImageComboBox;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
      procedure KaydetIslem;
      procedure Ekleme(Madde:String);
  public
    { Public declarations }
  end;

var
  GirdiAyarlaDlg: TGirdiAyarlaDlg;
  function GirdiIniDuzenle(AnahtarKelime1:String; Ini1 : TIni):Integer;

implementation
uses UMesaj, UTablo,LocOnFly,PrjConst;
{$R *.DFM}
var
   i, j, say : integer;
   AnahtarKelime : String;
   Ini : TIni;


procedure TGirdiAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
    LB : TListBox;
begin
  LB := TListBox(PageControl1.ActivePage.FindComponent('LB'));

  if TBitBtn(Sender).Name = 'EkleTus' then
     MesajOkunan := ''
  else
     MesajOkunan := LB.Items[LB.ItemIndex];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
     if TBitBtn(Sender).Name = 'EkleTus' then
        LB.Items.Add(MesajOkunan)
     else begin
        LB.Items.Strings[LB.ItemIndex] := MesajOkunan;
     end;
  LB.ItemIndex := LB.Items.Count-1;
end;


{   Tablo.Query5.SQL.Text := 'select BOLUM, SIRANO from '+INI.Dosya+' where BOLUM=''+AnahtarKelime+''  order by SIRANO';
   Tablo.Query5.Open;
   while not Tablo.Query5.eof do begin
      Ini.EraseSection(Tablo.Query5.Fields[1].AsString);

      LB := TListBox(PageControl1.Pages[i].FindComponent('LB'));
      for j := 0 to LB.Items.Count - 1  do
         Ini.WriteString(Tablo.Query5.Fields[1].AsString, LB.Items[j],'');
      Tablo.Query5.next;
   end;                                                       }

//   Ini.EraseSection(ListBox1.Items[ListBox1.ItemIndex]);
//   for j := 0 to ListBox2.Items.Count - 1  do
//       Ini.WriteString(ListBox1.Items[ListBox1.ItemIndex], ListBox2.Items[j],'');

procedure TGirdiAyarlaDlg.Ekleme(Madde:String);
var    tt : TTabSheet;
begin
   for i := 0 to PageControl1.PageCount -1 do
     if PageControl1.Pages[i].caption = Madde then
        raise exception.create(FWAdkullanilmis);

   tt := TTabSheet.Create(PageControl1);
   with tt do
    begin
      PageControl := PageControl1;
      Caption := Madde;
   end;

   with TListBox.Create(tt) do
    begin
        Name := 'LB';
        parent := tt;
        Align := alClient;
        OnDblClick := EkleTusClick;
   end;
end;

procedure TGirdiAyarlaDlg.BitBtn2Click(Sender: TObject);
begin
   KaydetIslem;
end;

procedure TGirdiAyarlaDlg.BitBtn3Click(Sender: TObject);
var MesajOkunan : String;
begin
   MesajOkunan := '';
   if not MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then exit;
   Ekleme(MesajOkunan);
end;

procedure TGirdiAyarlaDlg.BitBtn4Click(Sender: TObject);
begin
   if PageControl1.PageCount<1 then exit;
   if Application.MessageBox(PCHAR(FWBubasliktakikayitlarsilinsinmi), PCHAR(Onay), mb_YESNO) <> IDYES then Exit;
   PageControl1.ActivePage.Destroy;
end;

procedure TGirdiAyarlaDlg.BitBtn5Click(Sender: TObject);
var
    MesajOkunan : String;
begin
   if PageControl1.PageCount<1 then exit;
   MesajOkunan := PageControl1.ActivePage.Caption;
   if not MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then exit;
   for i := 0 to PageControl1.PageCount -1 do
     if PageControl1.Pages[i].caption = MesajOkunan then
        raise exception.create(FWAdkullanilmis);

   PageControl1.ActivePage.Caption := MesajOkunan;
end;

procedure TGirdiAyarlaDlg.SpeedButton1Click(Sender: TObject);
begin
   if PageControl1.ActivePage.PageIndex > 0 then
      PageControl1.ActivePage.PageIndex := PageControl1.ActivePage.PageIndex-1;
end;

procedure TGirdiAyarlaDlg.SpeedButton2Click(Sender: TObject);
begin
   if PageControl1.ActivePage.PageIndex < PageControl1.PageCount-1 then
      PageControl1.ActivePage.PageIndex := PageControl1.ActivePage.PageIndex+1;
end;

procedure TGirdiAyarlaDlg.UstTusClick(Sender: TObject);
var
    LB : TListBox;
begin
   LB := TListBox(PageControl1.ActivePage.FindComponent('LB'));
   if (LB.Items.Count < 2)or(LB.ItemIndex = 0) then exit;
   LB.Items.Exchange(LB.ItemIndex, LB.ItemIndex-1) ;
//   LB.ItemIndex := LB.ItemIndex - 1;
end;

procedure TGirdiAyarlaDlg.AltTusClick(Sender: TObject);
var
    LB : TListBox;
begin
   LB := TListBox(PageControl1.ActivePage.FindComponent('LB'));
   if (LB.Items.Count < 2)or(LB.ItemIndex = LB.Items.Count-1) then exit;
   LB.Items.Exchange(LB.ItemIndex, LB.ItemIndex+1) ;
//   LB.ItemIndex := LB.ItemIndex + 1;
end;

procedure TGirdiAyarlaDlg.SilTusClick(Sender: TObject);
var
    LB : TListBox;
begin
   LB := TListBox(PageControl1.ActivePage.FindComponent('LB'));
   if LB.Items.Count > 0 then
      LB.Items.Delete(LB.ItemIndex) ;
end;

procedure TGirdiAyarlaDlg.KaydetIslem;
var i,j : smallint;
    LB : TListBox;
begin
   Ini.EraseSection(AnahtarKelime);
   if PageControl1.PageCount<1 then exit;
   for i := 0 to PageControl1.PageCount - 1  do begin
       LB := TListBox(PageControl1.Pages[i].FindComponent('LB'));
       Tablo.Query5.Close;
       Tablo.Query5.SQL.Text := 'Insert Into '+INI.Dosya+' (BOLUM, ANAHTAR, DEGER) VALUES('''+AnahtarKelime+
           ''','''+PageControl1.Pages[i].Caption+''','''')';
       Tablo.Query5.ExecSQL;
       for j := 0 to LB.Items.Count - 1  do
        if LB.Items[j]<>'' then begin
           Tablo.Query5.Close;
           Tablo.Query5.SQL.Text := 'Insert Into '+INI.Dosya+' (BOLUM, ANAHTAR, DEGER) VALUES('''+AnahtarKelime+
               ''','''+PageControl1.Pages[i].Caption+''','''+LB.Items[j]+''')';
           Tablo.Query5.ExecSQL;
        end;
//           Ini.WriteString(AnahtarKelime, PageControl1.Pages[i].Caption,LB.Items[j]);
   end;
end;

function GirdiIniDuzenle(AnahtarKelime1:String; Ini1 : TIni):Integer;
Begin
   Application.CreateForm(TGirdiAyarlaDlg, GirdiAyarlaDlg);
   AnahtarKelime := AnahtarKelime1;
   Ini := Ini1;
   GirdiAyarlaDlg.ShowModal;
   i := GirdiAyarlaDlg.ModalResult;
   GirdiAyarlaDlg.Free;
   GirdiIniDuzenle := i;
End;

procedure TGirdiAyarlaDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TGirdiAyarlaDlg.FormShow(Sender: TObject);
var  LB:TListBox;
     i : SmallInt;
     sl : TStringList;
begin
   sl := TStringList.Create;
   INI.ReadSectionAnahtar(AnahtarKelime, sl);
   for i:=0 to sl.count-1 do begin
      Ekleme(sl.strings[i]);
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text := 'select DEGER from '+INI.Dosya+' where BOLUM='''+AnahtarKelime+''' and ANAHTAR='''+sl.strings[i]+''' order by SIRANO';
      Tablo.Query4.Open;
      LB := TListBox(PageControl1.Pages[PageControl1.PageCount-1].FindComponent('LB'));
      while not Tablo.Query4.eof do begin
         if Tablo.Query4.Fields[0].AsString<>'' then
            LB.Items.Add(Tablo.Query4.Fields[0].AsString);
         Tablo.Query4.next;
      end;
   end;
   sl.free;
end;

end.
