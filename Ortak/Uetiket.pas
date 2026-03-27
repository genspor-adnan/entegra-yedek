unit Uetiket;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, FetaUtil, Dialogs, SysUtils, Grids, Outline, ExtCtrls;

type
  TEtiket = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    FontTus: TBitBtn;
    FontDialog1: TFontDialog;
    Genis: TEdit;
    Yuksek: TEdit;
    MarjSol: TEdit;
    MarjUst: TEdit;
    SayfaUstBosluk: TEdit;
    SayfaSolBosluk: TEdit;
    YanBos: TEdit;
    AltBos: TEdit;
    GroupEtiket: TGroupBox;
    GroupYonlen: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    SayfaSagBosluk: TEdit;
    YanSay: TEdit;
    RadioDikey: TRadioButton;
    RadioYatay: TRadioButton;
    RadioSayfa: TRadioButton;
    RadioSurekli: TRadioButton;
    Image2: TImage;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Yeni: TBitBtn;
    Degis: TBitBtn;
    Sil: TBitBtn;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FontTusClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure YeniClick(Sender: TObject);
    procedure DegisClick(Sender: TObject);
    procedure SilClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
    procedure EtiketOku(Etiket: String);
    procedure DegerAtama(SiraNo: integer; AlanTuru, Tablo, AlanAdi: string; BandNo: integer;
      Sol, Ust, En, Boy: Real; Font: string; Punto: integer);
  public
    { Public declarations }
  end;

var
  Etiket: TEtiket;

implementation

uses UAyar, UTablo, UMesaj;

{$R *.DFM}


var
  EtiketTuru, EtiketYon: string[20];

{ Radyoloji Vers. 8.1.3.8 7/9/2008 de Adnan tarafýndan yapýldý..

[EtiketListesi]
HP=
Canon=

[Etkt_HP]
BOYUTLAR=A4,1,2,0.5,0.5,0.5,3.5,7.5,0.5,1,0,0'
FONT=Courier New,10

[Etkt_Canon]
BOYUTLAR=A4,1,2,0.5,0.5,0.5,3.5,7.5,0.5,1,0,0'
FONT=Courier New,10
}

procedure TEtiket.DegerAtama(SiraNo: integer; AlanTuru, Tablo, AlanAdi: string; BandNo: integer;
  Sol, Ust, En, Boy: Real; Font: string; Punto: integer);
begin
  RapTablo.Ayarlar.Append;
  RapTablo.Ayarlar.FieldByName('RAPORADI').AsString := 'Etkt_'+ListBox1.Items[ListBox1.Itemindex];  //  'Etiket_'
  RapTablo.Ayarlar.FieldByName('SIRANO').AsInteger := SiraNo;
  RapTablo.Ayarlar.FieldByName('ALANTURU').AsString := ALANTURU;
  RapTablo.Ayarlar.FieldByName('TABLO').AsString := TABLO;
  RapTablo.Ayarlar.FieldByName('ALANADI').AsString := ALANADI;
  RapTablo.Ayarlar.FieldByName('SOL').AsFloat := SOL;
  RapTablo.Ayarlar.FieldByName('UST').AsFloat := UST;
  if (En <> 0) and (TABLO <> 'BOÞLUK') then
    RapTablo.Ayarlar.FieldByName('EN').AsFloat := En;
  if (Boy <> 0) and (TABLO <> 'BOÞLUK') then
    RapTablo.Ayarlar.FieldByName('BOY').AsFloat := BOY;
  RapTablo.Ayarlar.FieldByName('FONT').AsString := Font;
  if Punto <> 0 then
    RapTablo.Ayarlar.FieldByName('PUNTO').AsFloat := Punto;
  if BandNo <> 0 then
    RapTablo.Ayarlar.FieldByName('BANDNO').AsInteger := BandNo;
  RapTablo.Ayarlar.Post;
end;

procedure TEtiket.OKBtnClick(Sender: TObject);
var
  SayfaGen, SayfaYuk, Yuk, Gen, YBos, ABos, MSol, MUst, SUstBosluk, SSolBosluk, SSagBosluk: real;
  YanYanaSay: integer;
  S: TStringList;
begin
  if ListBox1.Count<1 then
     raise Exception.Create('Tanýmlý etiket bulunamadý. Yeni tuþuyla tanýmlayýn!');

  if StrToInt(YanSay.Text) > 20 then begin
    ShowMessage('Yanyana etiket sayýsý 20 yi aþýyor!!!');
    ModalResult := mrNone;
  end
  else begin
//   GenotiIni.WriteString('ETIKET', 'Hitap', );
   if not RapTablo.Ayarlar.Active then
      RapTablo.Ayarlar.Close;
      RapTablo.Ayarlar.SQL.Text := 'select * from AYARLAR where RAPORADI = ''Etkt_'+ListBox1.Items[ListBox1.Itemindex]+''' ';  //  'Etiket_'
      RapTablo.Ayarlar.Open;

    try
      if RadioSayfa.checked then
        EtiketTuru := 'A4'
      else
        EtiketTuru := 'KUL';

      if RadioDikey.checked then
        EtiketYon := '1'
      else
        EtiketYon := '2';

      YanYanaSay := StrToInt(YanSay.Text);
      SUstBosluk := StrToFloat(SayfaUstBosluk.Text);
      SSolBosluk := StrToFloat(SayfaSolBosluk.Text);
      SSagBosluk := StrToFloat(SayfaSagBosluk.Text);
      Yuk := StrToFloat(Yuksek.Text);
      Gen := StrToFloat(Genis.Text);
      MSol := StrToFloat(MarjSol.Text);
      MUst := StrToFloat(MarjUst.Text);
      YBos := StrToFloat(YanBos.Text);
      ABos := StrToFloat(AltBos.Text);
    except
      on exception do
        raise Exception.Create('Rakam bildiriminde hata var!');
    end;                                 //'BOYUTLAR'
                           // 'ETIKET'
//    GenotipIni.WriteString('Etkt_'+ListBox1.Items[ListBox1.Itemindex], 'BOYUTLAR', EtiketTuru + ',' + EtiketYon + ',' + YanSay.Text + ',' +
//      SayfaUstBosluk.Text + ',' + SayfaSolBosluk.Text + ',' + SayfaSagBosluk.Text + ',' + Yuksek.Text + ',' +
//      Genis.Text + ',' + MarjSol.Text + ',' + MarjUst.Text + ',' + YanBos.Text + ',' + AltBos.Text);

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'Delete From Ayarlar Where RAPORADI = ''Etkt_'+ListBox1.Items[ListBox1.Itemindex]+''' ';    ///Etiket_''';
    Tablo.Query1.ExecSQL;
    SayfaGen := SSolBosluk + YanYanaSay * Gen + (YanYanaSay - 1) * YBos + SSagBosluk;
    SayfaYuk := SUstBosluk + Yuk;
    DegerAtama(1, 'SAYFA', 'BOYUT', EtiketTuru, 0, 0, 0, SayfaGen, SayfaYuk, '', 0);
//     DegerAtama(3,'SAYFA', 'BOÞLUK', '',0,0,0,0,0,'',0);
    DegerAtama(3, 'SAYFA', 'BOÞLUK', '', 0, SSolBosluk, SUstBosluk, SSagBosluk, 0, '', 0);
    DegerAtama(5, 'SAYFA', 'KOLON', '', YanYanaSay, 0, 0, 0, 0, '', 0);
//     if SUstBosluk > 0 then
//        DegerAtama(10,'BAND', 'SAYFABAÞI', '',0,0,0,0,SUstBosluk,'',0);
    DegerAtama(12, 'BAND', 'DETAY', 'SORGU', 0, 0, 0, 0, Yuk + ABos, '', 0);

    S := TStringList.Create;        //'ETIKET'
  //  Parcala(GenotipIni.ReadString('Etkt_'+ListBox1.Items[ListBox1.Itemindex], 'FONT', 'Courier New,10'), S);
    DegerAtama(30, 'HESAP', 'SORGU', 'EtiAdres(''' + TabloDokum.TabDokum.FieldByName('RAPORADI').AsString + ''')', 12, MSol, MUst, Gen - MSol, Yuk, S.Strings[0], StrToInt(S.Strings[1]));
    S.Free;
  end;
end;


procedure TEtiket.EtiketOku(Etiket: String);
var S: TStringList;
begin
  S := TStringList.Create;      // 'ETIKET'              // 'BOYUTLAR'
 // Parcala(GenotipIni.ReadString('Etkt_'+Etiket, 'BOYUTLAR', 'A4,1,2,0.5,0.5,0.5,3.5,7.5,0.5,1,0,0'), S);

  EtiketTuru := S.Strings[0];
  EtiketYon := S.Strings[1];
  YanSay.Text := S.Strings[2];
  SayfaUstBosluk.Text := S.Strings[3];
  SayfaSolBosluk.Text := S.Strings[4];
  SayfaSagBosluk.Text := S.Strings[5];
  Yuksek.Text := S.Strings[6];
  Genis.Text := S.Strings[7];
  MarjSol.Text := S.Strings[8];
  MarjUst.Text := S.Strings[9];
  YanBos.Text := S.Strings[10];
  AltBos.Text := S.Strings[11];
  S.Free;

  if EtiketTuru = 'A4' then
    RadioSayfa.checked := True
  else
    RadioSurekli.checked := True;

  if EtiketYon = '1' then
    RadioDikey.checked := True
  else
    RadioYatay.checked := True
end;

procedure TEtiket.FormShow(Sender: TObject);
begin
   //GenotipIni.ReadSectionValues('EtiketListesi', ListBox1.Items);
    if ListBox1.Count<1 then
     raise Exception.Create('Tanýmlý etiket bulunamadý. Yeni tuþuyla tanýmlayýn!');
   ListBox1.Itemindex := 0;
   ListBox1Click(Self);
end;

procedure TEtiket.FontTusClick(Sender: TObject);
var S: TStringList;
begin
  S := TStringList.Create;       // 'ETIKET'
//  Parcala(GenotipIni.ReadString('Etkt_'+ListBox1.Items[ListBox1.Itemindex], 'FONT', 'Courier New,10'), S);
  FontDialog1.Font.Name := S.Strings[0];
  FontDialog1.Font.Size := StrToInt(S.Strings[1]);
  S.Free;
  if FontDialog1.Execute then
    with FontDialog1.font do   //'ETIKET'
//      GenotipIni.WriteString('Etkt_'+ListBox1.Items[ListBox1.Itemindex], 'FONT', Name + ',' + IntToStr(Size) {+','+Color+','+Style});
end;

procedure TEtiket.FormDblClick(Sender: TObject);
begin
  AyarlarDlgEkran('ETIKET_9',nil);
end;

procedure TEtiket.YeniClick(Sender: TObject);
var Ad : String;
begin
  Ad := '';
  if not MesajStrAl('', 'Etiket Adýný Giriniz :', 'E', nil, Ad, '', 'E', nil, Ad) then exit;
  ListBox1.Items.Add(Ad);
 // GenotipIni.WriteString('EtiketListesi', Ad,'');
  ListBox1.Itemindex := ListBox1.Items.IndexOf(Ad);
  ListBox1Click(Self);
  OKBtn.Click;
end;

procedure TEtiket.DegisClick(Sender: TObject);
var EskiAd, Ad : String;
begin
  if ListBox1.Count<1 then
     raise Exception.Create('Tanýmlý etiket bulunamadý. Yeni tuþuyla tanýmlayýn!');

  EskiAd := ListBox1.Items[ListBox1.Itemindex];
  Ad:=EskiAd;
  if not MesajStrAl('', 'Etiket Adýný Giriniz :', 'E', nil, Ad, '', 'E', nil, Ad) then exit;
  ListBox1.Items[ListBox1.Itemindex] := Ad;
  //Soldakini deðiþtirelim
//  GenotipIni.DeleteKey('EtiketListesi', EskiAd);
//  GenotipIni.WriteString('EtiketListesi', Ad,'');
//  //Saðdakini deðiþtirelim
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text :='update GENOTIPINI set BOLUM=''Etkt_'+Ad+''' where BOLUM=''Etkt_'+EskiAd+''' ';
  Tablo.Query1.ExecSQL;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'update Ayarlar set RAPORADI = ''Etkt_'+Ad+''' Where RAPORADI = ''Etkt_'+EskiAd+''' ';
  Tablo.Query1.ExecSQL;

end;

procedure TEtiket.SilClick(Sender: TObject);
begin
  if ListBox1.Count<1 then
     raise Exception.Create('Tanýmlý etiket bulunamadý. Yeni tuþuyla tanýmlayýn!');

  if Application.MessageBox('Bu etiket silinecektir. Onaylýyor musunuz?', 'O N A Y', MB_YESNO) <> IDYES then exit;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Delete From Ayarlar Where RAPORADI = ''Etkt_'+ListBox1.Items[ListBox1.Itemindex]+''' ';    ///Etiket_''';
  Tablo.Query1.ExecSQL;
//  GenotipIni.EraseSection('Etkt_'+ListBox1.Items[ListBox1.Itemindex]);
//  GenotipIni.DeleteKey('EtiketListesi', ListBox1.Items[ListBox1.Itemindex]);
  ListBox1.Items.Delete(ListBox1.Itemindex);
end;

procedure TEtiket.ListBox1Click(Sender: TObject);
begin
   EtiketOku(ListBox1.Items[ListBox1.Itemindex]);
end;

end.
