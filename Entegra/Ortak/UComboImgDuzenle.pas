unit UComboImgDuzenle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, UCombo;

type
  TImgListeAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    SiralaTus: TSpeedButton;
    ListBox1: TListBox;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    IptalTus: TBitBtn;
    KaydetTus: TBitBtn;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SiralaTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure DegistirTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImgListeAyarlaDlg: TImgListeAyarlaDlg;

function ComboImgDuzenle(TabloveAlan, AnahtarKelime1: string; Ini1: TIni): Boolean;

implementation

uses
  Umesaj, Utablo,PrjConst,LocOnFly;
var
  AnahtarKelime, TabloAdi,AlanAdi: string;
  Ini: TIni;
  MaxDeger : Integer;

{$R *.dfm}

function ComboImgDuzenle(TabloveAlan, AnahtarKelime1: string; Ini1: TIni): Boolean;
var yer : SmallInt;
begin
  Application.CreateForm(TImgListeAyarlaDlg, ImgListeAyarlaDlg);
  AnahtarKelime := AnahtarKelime1;
  Ini := Ini1;
  yer := Pos('.', TabloveAlan);
  if yer >0 then begin
     TabloAdi := Copy(TabloveAlan,1,yer-1);
     AlanAdi :=  Copy(TabloveAlan,yer+1, Length(TabloveAlan)-yer);
  end;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select max(cast(isnull(DEGER,0) as Int))+1 from REHBERINI where BOLUM = '''+AnahtarKelime+''' ';
  Tablo.Query1.Open;
  MaxDeger := Tablo.Query1.Fields[0].AsInteger;
  ImgListeAyarlaDlg.Showmodal;
  Result := ImgListeAyarlaDlg.ModalResult = mrOk;
  ImgListeAyarlaDlg.Free;
end;

procedure TImgListeAyarlaDlg.UstTusClick(Sender: TObject);
begin
  if (ListBox1.Items.Count < 2) or (ListBox1.ItemIndex = 0) then exit;
  ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex - 1);
//   ListBox1.ItemIndex := ListBox1.ItemIndex - 1;
end;

procedure TImgListeAyarlaDlg.AltTusClick(Sender: TObject);
begin
  if (ListBox1.Items.Count < 2) or (ListBox1.ItemIndex = ListBox1.Items.Count - 1) then exit;
  ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex + 1);
//   ListBox1.ItemIndex := ListBox1.ItemIndex + 1;
end;

procedure TImgListeAyarlaDlg.SilTusClick(Sender: TObject);
var s:String;
begin
  if ListBox1.Items.Count = 0 then
     exit;
  s := ListBox1.Items[ListBox1.ItemIndex];
  if Pos('Varsayýlan:',s)>0 then
     exit;
  if pos('=',s)>0 then begin
    delete(s,1,Pos('=',s));
    if StrToIntDef(s,-98)<>-98 then begin
      if (TABLOADI <> '') and (ALANADI <> '') then begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'select top 1 ID from '+TABLOADI+' where '+ALANADI+' = '+s;
        Tablo.Query1.Open;
        if Tablo.Query1.RecordCount > 0 then
           raise Exception.Create(IKSilinemez);
      end;
    end;
  end;
  ListBox1.Items.Delete(ListBox1.ItemIndex);
end;

procedure TImgListeAyarlaDlg.DegistirTusClick(Sender: TObject);
var MesajOkunan: string;
begin
{$IFNDEF NO_UTABLO}
  if Pos('Varsayýlan:',ListBox1.Items.Strings[ListBox1.ItemIndex])>0 then
     Exit;
  MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];
  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
     ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
{$ENDIF}
end;

procedure TImgListeAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan, Deger: string;
begin
{$IFNDEF NO_UTABLO}
  MesajOkunan := '';
  Inc(MaxDeger);
  if MaxDeger<=50 then
    MaxDeger := 51;  //serkan
  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..Sonuna "'+Deger+'" otomatik eklenecektir.', 'E', nil, MesajOkunan, '', 'E', nil, MesajOkunan) then
      if Pos('=',MesajOkunan)>0  then
        MesajOkunan := Copy(MesajOkunan,1,Pos('=',MesajOkunan)-1);
  ListBox1.Items.Add(MesajOkunan+'='+IntToStr(MaxDeger));
{$ENDIF}
end;

procedure TImgListeAyarlaDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TImgListeAyarlaDlg.FormShow(Sender: TObject);
begin
  Ini.ReadSectionValues(AnahtarKelime, ListBox1.Items);
  ListBox1.ItemIndex := 0;
end;

procedure TImgListeAyarlaDlg.KaydetTusClick(Sender: TObject);
var i, yer: integer;
begin
  Ini.EraseSection(AnahtarKelime);
  for i := 0 to ListBox1.Items.Count - 1 do begin
    yer := pos('=', ListBox1.Items[i]);
    if yer = 0 then
      Ini.WriteString(AnahtarKelime, ListBox1.Items[i], '')
    else begin
      ListBox1.Items[i]:=StringReplace(ListBox1.Items[i],'Varsayýlan: ','',[]);
      yer := pos('=', ListBox1.Items[i]);
     // if StrToIntDef(copy(ListBox1.Items[i], yer + 1,length(ListBox1.Items[i])),99)>50 then  //serkan
        Ini.WriteString(AnahtarKelime, copy(ListBox1.Items[i], 1, yer - 1), copy(ListBox1.Items[i], yer + 1,length(ListBox1.Items[i])))
    end;
  end;
end;

procedure TImgListeAyarlaDlg.SiralaTusClick(Sender: TObject);
begin
  ListBox1.Sorted := False;
  ListBox1.Sorted := True;
end;
end.
