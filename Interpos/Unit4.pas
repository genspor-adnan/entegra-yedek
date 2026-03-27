unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxContainer,
  cxTextEdit, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ADODB,
  StdCtrls, Menus, cxLookAndFeelPainters, cxButtons, cxListBox, ComCtrls,
  cxShellBrowserDialog;

type
  TKampanyaForm = class(TForm)
    ADOQueryListele: TADOQuery;
    DataSourceListele: TDataSource;
    cxGridListeleDBTableView1: TcxGridDBTableView;
    cxGridListeleLevel1: TcxGridLevel;
    cxGridListele: TcxGrid;
    cxTextEdit1: TcxTextEdit;
    Label1: TLabel;
    cxTextEdit2: TcxTextEdit;
    Label2: TLabel;
    cxButton1: TcxButton;
    cxListBoxPROMO: TcxListBox;
    cxTextEdit3: TcxTextEdit;
    Label3: TLabel;
    DateTimePickerBASLANGIC: TDateTimePicker;
    DateTimePickerBITIS: TDateTimePicker;
    Label4: TLabel;
    Label5: TLabel;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxShellBrowserDialog1: TcxShellBrowserDialog;
    procedure cxTextEdit1PropertiesChange(Sender: TObject);
    procedure cxTextEdit2PropertiesChange(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxListBoxPROMOClick(Sender: TObject);
    procedure DateTimePickerBASLANGICChange(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    procedure DateTimePickerBITISChange(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure cxTextEdit3KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KampanyaForm: TKampanyaForm;
  giden_baslangic,giden_bitis,PromoYOL,mesajYOL:string;

implementation

uses Unit1, Unit3;

{$R *.dfm}

procedure TKampanyaForm.cxButton1Click(Sender: TObject);
var
dosya:textfile;
i:integer;
begin

  //promo için +
    i:=0;
    AssignFile(dosya,PromoYOL);
    Rewrite(dosya);

       while i<= cxListBoxPROMO.Count -1  do
       begin
       Writeln(dosya,cxListBoxPROMO.Items.Strings[i]);
       inc(i);
       end;
    closefile(dosya);
    //promo için -

    //mesaj +
    AssignFile(dosya,MesajYOL);
    Rewrite(dosya);
    Writeln(dosya,'1110');
    closefile(dosya);
    //mesaj -

    showmessage('Promosyonlar Aktarýldý');

end;

procedure TKampanyaForm.cxButton2Click(Sender: TObject);
begin
//showmessage(ADOQueryListele.FieldByName('barkod').AsString);
if ( (giden_baslangic='') or (giden_bitis='') ) then
begin
showmessage('Tarih Aralýðý Belirleyin');
exit;
end;
if cxTextEdit3.Text='' then
begin
showmessage('Ýndirim oraný belirleyin');
exit;
end;
if Length(cxTextEdit3.Text)=1 then
begin
cxTextEdit3.Text:='0'+cxTextEdit3.Text;
end;
if Length(cxTextEdit3.Text)>2 then
begin
showmessage('Ýndirim oraný iki haneden büyük olamaz');
cxTextEdit3.SetFocus;
exit;
end;
if cxGridListeleDBTableView1.ColumnCount<=0 then
begin
showmessage('Ýndirim yapýlacak ürünü seçmelisiniz');
exit;
end;

cxListBoxPROMO.Items.Add('P2,H,01,'+'0'+ADOQueryListele.FieldByName('KOD').AsString+','+cxTextEdit3.Text+',0000000.00,--,,'+giden_baslangic+' 08:20:59 '+giden_bitis+' 23:59:59,');

label3.Font.Color:=ClRed;
label4.Font.Color:=ClRed;
label5.Font.Color:=ClRed;

giden_baslangic:='';
giden_bitis:='';
cxTextEdit3.Text:='';
DateTimePickerBASLANGIC.Date:=date;
DateTimePickerBITIS.Date:=date;


end;

procedure TKampanyaForm.cxButton3Click(Sender: TObject);
begin
cxListBoxPROMO.Items.Delete(cxListBoxPROMO.ItemIndex);
cxButton3.Enabled:=false;
end;

procedure TKampanyaForm.cxListBoxPROMOClick(Sender: TObject);
var
baslangic,bitis:string;
s:string;
begin
s:=copy(cxListBoxPROMO.Items.Strings[cxListBoxPROMO.ItemIndex],10,5);
cxTextEdit3.Text:=copy(cxListBoxPROMO.Items.Strings[cxListBoxPROMO.ItemIndex],16,2);
baslangic:=StringReplace(copy(cxListBoxPROMO.Items.Strings[cxListBoxPROMO.ItemIndex],34,10),'-','.',[rfReplaceAll]);
bitis:=StringReplace(copy(cxListBoxPROMO.Items.Strings[cxListBoxPROMO.ItemIndex],54,10),'-','.',[rfReplaceAll]);

DateTimePickerBASLANGIC.Date:=strtodate(baslangic);
DateTimePickerBITIS.Date:=strtodate(bitis);

cxButton3.Enabled:=true;

  //showmessage(bitis);
  //showmessage(s);
  ADOQueryListele.SQL.Clear;
  ADOQueryListele.Close;
  ADOQueryListele.SQL.Add('select KOD,STOKADI,BARKOD from STOKLAR s inner join STOKBARKOD sb on s.ID=sb.STOKID where kod = '''+s+'''');
  ADOQueryListele.Open;

  cxGridListeleDBTableView1.ClearItems;
  cxGridListeleDBTableView1.DataController.CreateAllItems;
  cxGridListeleDBTableView1.ApplyBestFit;
end;

procedure TKampanyaForm.cxTextEdit1PropertiesChange(Sender: TObject);
begin

  if Length(cxTextEdit1.Text)>=3 then
  begin
  ADOQueryListele.SQL.Clear;
  ADOQueryListele.Close;
  ADOQueryListele.SQL.Add('SELECT * FROM STOKLAR where STOKADI like '''+cxTextEdit1.Text+'%''');
  ADOQueryListele.Open;

  cxGridListeleDBTableView1.ClearItems;
  cxGridListeleDBTableView1.DataController.CreateAllItems;
  cxGridListeleDBTableView1.ApplyBestFit;
  end;
end;

procedure TKampanyaForm.cxTextEdit2PropertiesChange(Sender: TObject);
begin
  if Length(cxTextEdit2.Text)>=3 then
  begin
  ADOQueryListele.SQL.Clear;
  ADOQueryListele.Close;
  ADOQueryListele.SQL.Add('select KOD,STOKADI,BARKOD from STOKLAR s inner join STOKBARKOD sb on s.ID=sb.STOKID where barkod = '''+cxTextEdit2.Text+'''');
  ADOQueryListele.Open;

  cxGridListeleDBTableView1.ClearItems;
  cxGridListeleDBTableView1.DataController.CreateAllItems;
  cxGridListeleDBTableView1.ApplyBestFit;
  end;
end;

procedure TKampanyaForm.cxTextEdit3KeyPress(Sender: TObject; var Key: Char);
begin
if (key=',') or (key='.') then begin key:=' '; end;
label3.Font.Color:=ClGreen;

end;

procedure TKampanyaForm.DateTimePickerBASLANGICChange(Sender: TObject);
begin
giden_baslangic:=StringReplace(copy(datetostr(DateTimePickerBASLANGIC.Date),0,10),'.','-',[rfReplaceAll]);
label4.Font.Color:=ClGreen;
//showmessage(giden_baslangic);
end;

procedure TKampanyaForm.DateTimePickerBITISChange(Sender: TObject);
begin
giden_bitis:=StringReplace(copy(datetostr(DateTimePickerBITIS.Date),0,10),'.','-',[rfReplaceAll]);
label5.Font.Color:=ClGreen;
//showmessage(giden_bitis);
end;

procedure TKampanyaForm.FormCreate(Sender: TObject);
var
dosya:textfile;
s:string;
begin
//baslangic:=StringReplace(copy(datetostr(DateTimePickerBASLANGIC.Date),34,10),'-','.',[rfReplaceAll]);
//bitis:=StringReplace(copy(datetostr(DateTimePickerBITIS.Date),54,10),'-','.',[rfReplaceAll]);

PromoYOL:='c:\POSGENEL\PROMO.DAT';
MesajYOL:='c:\POSKON\MESAJ.001';
  if not( FileExists(PromoYOL) ) then
  begin
   if cxShellBrowserDialog1.Execute then
   BEGIN
     PromoYOL:=cxShellBrowserDialog1.Path+'\PROMO.DAT';
   END;
  end;
    if not( FileExists(MesajYOL) ) then
  begin
   if cxShellBrowserDialog1.Execute then
   BEGIN
     MesajYOL:=cxShellBrowserDialog1.Path+'\MESAJ.001';
   END;
  end;



//showmessage(yol);
    try
      AssignFile(dosya,PromoYOL);
      Reset(dosya);
    except
      showmessage('Dosya Yolu Bulunamadi');
    end;

     while not eof(dosya) do begin
       Readln(dosya,s);
       //operasyon +
       if s<>'' then
       begin
        cxListBoxPROMO.Items.Add(s);
       end;
        //operasyon -

     end;
     CloseFile(dosya);
end;

end.
