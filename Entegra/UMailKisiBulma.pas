unit UMailKisiBulma;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons,
  cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls, FireDAC.Comp.Client,Utablo,
  dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxLookAndFeels,
  cxNavigator, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinLiquidSky;

type
  TMailKisiEkleme = class(TForm)
    Panel1: TPanel;
    KimeTus: TcxButton;
    BilgiTus: TcxButton;
    GizliTus: TcxButton;
    KimeEdit: TEdit;
    BilgiEdit: TEdit;
    GizliEdit: TEdit;
    TamamTus: TcxButton;
    IptalTus: TcxButton;
    DataMail: TDataSource;
    QueryMail: TFDQuery;
    MailGrid: TcxGrid;
    MailGridDBTableView1: TcxGridDBTableView;
    MailGridDBTableView1FIRMA: TcxGridDBColumn;
    FIRMAMailGridDBTableView1ETIKET: TcxGridDBColumn;
    FIRMAMailGridDBTableView1BILGI: TcxGridDBColumn;
    MailGridLevel1: TcxGridLevel;
    Panel2: TPanel;
    cxButton1: TcxButton;
    Edit1: TEdit;
    MemoListeSQL: TMemo;
    procedure KimeTusClick(Sender: TObject);
    procedure BilgiTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MailGridDBTableView1DblClick(Sender: TObject);
    procedure TamamTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
           {type Mailadresleri = record
      gizli : tstrings;
      kime  : tstrings;
      bilgi : tstrings;
   end;   }

  private
    { Private declarations }
     procedure Listele;
  public
     kime,bilgi,gizli : string;
     RehberID:integer;
    mailler:  Dmailadresleri;//  TStrings;
    KimeDefaultMail,BilgiDefaultMail : string;
        { Public declarations }
  end;

var
   MailKisiEkleme: TMailKisiEkleme;
   dizi,dizi2,sonuc,sontus: integer;
   kontrol,kontrolb : string;
   harf:char;


implementation

{$R *.dfm}
Uses LocOnFly, FetaUtil;


 procedure TMailKisiEkleme.BilgiTusClick(Sender: TObject);

begin
sontus:=2;
  if BilgiEdit.Text = '' then begin
    //dizi:=1;
    kontrolb:=QueryMail.FieldByName('BILGI').AsString;
    BilgiEdit.Text:= QueryMail.FieldByName('BILGI').AsString+';';
    // Mailler[dizi].bilgi:=(QueryMail.FieldByName('BILGI').AsString);
    //dizi:=dizi+1;
  end  else begin
    if pos(QueryMail.FieldByName('BILGI').AsString,Kontrolb) > 0  then
      ShowMessage('Mail adres tekrarı!')
    else  begin
      BilgiEdit.Text :=BilgiEdit.Text + QueryMail.FieldByName('BILGI').AsString+';';
      //Mailler[dizi].bilgi:=(QueryMail.FieldByName('BILGI').AsString);
      //dizi:=dizi+1;
      kontrolb:=BilgiEdit.Text;
    end;
  end
end;

procedure TMailKisiEkleme.Edit1KeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  case Key of
   13 : begin
           MailGridDBTableView1DblClick(Self);
           Edit1.Text :='';
        end;
   38 : QueryMail.Prior;
   40 : QueryMail.next;
  else
    Listele
  end;
end;

procedure TMailKisiEkleme.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   action:=cafree;
end;

procedure TMailKisiEkleme.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  sontus:=1;
  dizi:=0;
  dizi2:=0;
  SetLength(mailler,100);
  mailler[0].kime:='';
  Mailler[0].bilgi:='';
end;

procedure TMailKisiEkleme.Listele;
begin
  QueryMail.Close;
  QueryMail.SQL.Text:= StringReplace(MemoListeSQL.Text, '@@REHBERID', IntToStr(RehberID), [rfReplaceAll]);
  QueryMail.SQL.Text:= StringReplace(QueryMail.SQL.Text, '@@ADSOYAD', Trim(Edit1.Text), [rfReplaceAll]);
  TabloYenile( QueryMail, []);
end;

procedure TMailKisiEkleme.FormShow(Sender: TObject);
begin
  if RehberID>0 then begin
     Listele;
     Edit1.Text := '';
  end;
  if KimeDefaultMail <> '' then
     KimeEdit.Text := KimeDefaultMail;
  if BilgiDefaultMail <> '' then
     BilgiEdit.Text := BilgiDefaultMail;
  Edit1.SetFocus;
end;

procedure TMailKisiEkleme.KimeTusClick(Sender: TObject);begin
  sontus:=1;

  if KimeEdit.Text = '' then begin
    //dizi2:=1;
    kontrol:=QueryMail.FieldByName('BILGI').AsString;
    KimeEdit.Text:= QueryMail.FieldByName('BILGI').AsString+';';
    //mailler[dizi2].kime:=(QueryMail.FieldByName('BILGI').AsString);
    //dizi2:=dizi2+1;
  end else begin
    if pos(QueryMail.FieldByName('BILGI').AsString,Kontrol) > 0  then                                                  //(sonuc = 0) or (sonuc < 0)  then
      ShowMessage('Mail adres tekrarı!')
    else begin
      KimeEdit.Text :=KimeEdit.Text + QueryMail.FieldByName('BILGI').AsString+';';
      //mailler[dizi2].kime:=(QueryMail.FieldByName('BILGI').AsString);
      //dizi2:=dizi2+1;
      kontrol:=KimeEdit.Text;
    end;
  end

end;
procedure TMailKisiEkleme.MailGridDBTableView1DblClick(Sender: TObject);
begin
   if sontus=1 then
      KimeTus.Click
   else
      if sontus=2 then
         BilgiTus.Click
end;

procedure TMailKisiEkleme.TamamTusClick(Sender: TObject);
var
  kim,bil:string;
  yeri : smallint;
begin
 KimeEdit.Text := Trim(KimeEdit.Text);
 if RevPos(';',KimeEdit.Text)<>1 then //sonda ; yoksa ekleyelim
    KimeEdit.Text:=KimeEdit.Text+';';
 dizi2 := 1;
 dizi := 1;
 while Length(KimeEdit.Text) > 0 do  //Kime Kısımını Diziye Gönderiyor
 begin
   kim:=KimeEdit.Text ;
   yeri := pos(';',kim);
   if yeri=0 then   //; ile değil boşlukla ayrılmış
      yeri := pos(' ',kim);
   if yeri>3 then
      mailler[dizi2].kime:=Copy(kim,0,yeri-1);
   Delete(kim,1, yeri);
   dizi2:=dizi2+1;
   KimeEdit.Text:=trim(kim);
 end;

 while Length(BilgiEdit.Text) > 0 do      //Bilgi Kısımını Diziye Gönderiyor
 begin
   bil:=BilgiEdit.Text ;
   mailler[dizi2].bilgi:=Copy(bil,0,pos(';',bil)-1);
   Delete(bil,1,pos(';',bil));
   dizi2:=dizi2+1;
  BilgiEdit.Text:=bil;
 end;


end;

end.


