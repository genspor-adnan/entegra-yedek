unit UEntegrasyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, DB, FireDAC.Comp.Client,Utablo, cxStyles, dxSkinscxPCPainter, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxLookAndFeelPainters, Menus, cxMemo, cxRichEdit, cxLabel, StdCtrls,
  cxButtons, cxGroupBox, Registry, RegStr, UGirisKutusuEx, cxImageComboBox,
  cxCheckBox, cxGridCustomPopupMenu, cxGridPopupMenu, cxLookAndFeels,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxNavigator;

type
  TEntegrasyonDlg = class(TForm)
    cxGrid1: TcxGrid;
    TabAktarilacak: TFDQuery;
    DtsAktarilacak: TDataSource;
    CNNAktarilacak: TFDConnection;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGroupBox1: TcxGroupBox;
    cxButton1: TcxButton;
    cxGroupBox3: TcxGroupBox;
    cxGroupBox4: TcxGroupBox;
    LabelBaglanti: TcxLabel;
    cxButton2: TcxButton;
    cxRichEdit1: TcxRichEdit;
    cxGrid1DBTableView1NAME: TcxGridDBColumn;
    cxImageComboBox1: TcxImageComboBox;
    PopupMenu1: TPopupMenu;
    cxGridPopupMenu1: TcxGridPopupMenu;
    mnSe1: TMenuItem;
    mnTemizle1: TMenuItem;
    ADOQuery1: TFDQuery;
    DataSource1: TDataSource;
    procedure cxButton1Click(Sender: TObject);
    function DBConnect: boolean;
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    function RehberSatiriniAl: boolean;
    function RehberSatiriniVer: boolean;
    procedure mnSe1Click(Sender: TObject);
    procedure mnTemizle1Click(Sender: TObject);
    function GenotipdanRehberiEntegrayaGuncelle(Kod,GenoCnn: String): boolean;
    function EntegradanRehberiGenotipaGuncelle(Kod,GenoCnn: String): boolean;
    function GenotipdanRehberHareketKontrol(Kod,GenoCnn: String): boolean;
    function EntegradanRehberHareketKontrol(Kod,GenoCnn: String): boolean;

  private
   DBName:string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EntegrasyonDlg: TEntegrasyonDlg;

implementation

{$R *.dfm}

procedure TEntegrasyonDlg.cxButton1Click(Sender: TObject);
begin
   //baðlantý oluþturulacak ve baðlanýrsa;
   DBConnect;
   if CNNAktarilacak.Connected then begin
     LabelBaglanti.Caption:='Baðlantý Baþarýlý.';
     cxGroupBox3.Enabled:=True;
   end else begin
     LabelBaglanti.Caption:='Baðlantý Baþarýsýz!';
     cxGroupBox3.Enabled:=False;
   end;
   {Tablo.Query1.close;
   Tablo.Query1.Connection:=CNNAktarilacak;
   Tablo.Query1.SQL.Text:='select NAME from sysobjects where xtype=''U'' order by 1   ';
   Tablo.Query1.Open;
   while not Tablo.Query1.Eof do begin
     with cxImageComboBox1.Properties.Items.Add do begin
       Description:= Tablo.Query1.FieldByName('NAME').AsString;
       Value:= Tablo.Query1.FieldByName('NAME').AsString;
     end;
     Tablo.Query1.Next;
   end;
   Tablo.Query1.close;
   Tablo.Query1.Connection:=Tablo.FDCnn;   }
end;

procedure TEntegrasyonDlg.cxButton2Click(Sender: TObject);
begin
  if cxImageComboBox1.Text = 'Genotýpdan Rehber Al' then  begin
    TabAktarilacak.first;
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text:='SELECT KOD FROM REHBER';
    Tablo.Query1.Open;
    //ilk satýrdan son satýra kadar aktarým
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç deðeri deðiþtirilenler aktarýlmaz..
      if cxGrid1DBTableView1NAME.EditValue then begin
        if RehberSatiriniAl then
           cxGrid1DBTableView1NAME.EditValue:=True
        Else
           cxGrid1DBTableView1NAME.EditValue:=False;
      end;
      TabAktarilacak.Next;
    end;
  end else  if cxImageComboBox1.Text = 'Genotýpa Rehber Ver' then  begin
    TabAktarilacak.first;
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=CNNAktarilacak;
    Tablo.Query1.SQL.Text:='SELECT KOD FROM REHBER';
    Tablo.Query1.Open;
    //ilk satýrdan son satýra kadar aktarým
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç deðeri deðiþtirilenler aktarýlmaz..
      if cxGrid1DBTableView1NAME.EditValue then begin
        if RehberSatiriniVer then
           cxGrid1DBTableView1NAME.EditValue:=True
        Else
           cxGrid1DBTableView1NAME.EditValue:=False;
      end;
      TabAktarilacak.Next;
    end;

    Tablo.Query1.Connection := Tablo.FDCnn;
  end;
end;

function TEntegrasyonDlg.RehberSatiriniVer: boolean;
Var
  aramadaciksin:string;
  RehID:Integer;
Begin
  //ayný kaydýn bizde olup olmadýðý koduna bakýlarak kontrol edilir..  //
  if not Tablo.Query1.Locate('KOD',TabAktarilacak.FieldByName('KOD').AsString,[]) then begin
     if TabAktarilacak.FieldByName('DURUM').Asboolean = False then
        aramadaciksin:='H'
     Else
        aramadaciksin:='';
     Tablo.Query5.Close;
     Tablo.Query5.Connection := CNNAktarilacak;
     Tablo.Query5.SQL.Text:='INSERT INTO REHBER(KOD,FIRMA,GRUP,ISTEL,CEP,FAX,EMAIL '
            +',WEB,ADRES,ILCE,IL,PK,VERGIDAI,VERGINO,NOTLAR,FATURABASLIK) '
            +'VALUES(:KOD,:FIRMA,:GRUP,:ISTEL,:CEP,:FAX,:EMAIL, '
            +':WEB,:ADRES,:ILCE,:IL,:PK,:VERGIDAI,:VERGINO,:NOTLAR,:FATURABASLIK) ';
     Tablo.Query5.Params[0].Value:=Copy(TabAktarilacak.FieldByName('KOD').AsString,1,20);
     Tablo.Query5.Params[1].Value:=Copy(TabAktarilacak.FieldByName('FIRMA').AsString,1,50);
     Tablo.Query5.Params[2].Value:=Copy(TabAktarilacak.FieldByName('GRUP').AsString,1,10);
     Tablo.Query5.Params[3].Value:=Copy(TabAktarilacak.FieldByName('ISTEL').AsString,1,20);
     Tablo.Query5.Params[4].Value:=Copy(TabAktarilacak.FieldByName('CEP').AsString,1,20);
     Tablo.Query5.Params[5].Value:=Copy(TabAktarilacak.FieldByName('FAX').AsString,1,20);
     Tablo.Query5.Params[6].Value:=Copy(TabAktarilacak.FieldByName('EMAIL').AsString,1,50);
     Tablo.Query5.Params[7].Value:=Copy(TabAktarilacak.FieldByName('WEB').AsString,1,50);
     Tablo.Query5.Params[8].Value:=Copy(TabAktarilacak.FieldByName('ADRES').AsString,1,50);
     Tablo.Query5.Params[9].Value:=Copy(TabAktarilacak.FieldByName('ILCE').AsString,1,20);
     Tablo.Query5.Params[10].Value:=Copy(TabAktarilacak.FieldByName('IL').AsString,1,25);
     Tablo.Query5.Params[11].Value:=Copy(TabAktarilacak.FieldByName('PK').AsString,1,6);
     Tablo.Query5.Params[12].Value:=Copy(TabAktarilacak.FieldByName('VERGIDAI').AsString,1,15);
     Tablo.Query5.Params[13].Value:=Copy(TabAktarilacak.FieldByName('VERGINO').AsString,1,15);
     Tablo.Query5.Params[14].Value:=Copy(TabAktarilacak.FieldByName('NOTLAR').AsString,1,150);
     Tablo.Query5.Params[15].Value:=Copy(TabAktarilacak.FieldByName('FATURABASLIK').AsString,1,100);
     Tablo.Query5.Params[16].Value:='1';
     Tablo.Query5.ExecSQL;
     Result := True;
     Tablo.Query5.Connection := Tablo.FDCnn;
  end Else
     Result := False;
End;


function TEntegrasyonDlg.RehberSatiriniAl: boolean;
Var
  SQLParam:string;
  RehID:Integer;
Begin
  //ayný kaydýn bizde olup olmadýðý koduna bakýlarak kontrol edilir..  //
  if not Tablo.Query1.Locate('KOD',TabAktarilacak.FieldByName('KOD').AsString,[]) then begin
//     if TabAktarilacak.FieldByName('ARAMADACIKSIN').AsString='H' then
//        aramadaciksin:='0'
//     Else
//        aramadaciksin:='1';
     Tablo.Query2.Close;
     Tablo.Query2.SQL.Text:='INSERT INTO REHBER ' +
                       '([OZELTUZEL],[KOD],[FIRMA],[GRUP],[DURUM],[OZEL],[NOTLAR]' +
                       ',[C_ILGILI],[C_TICARI],[C_SOZLESME],[C_GORUSME],[EKLEYEN]) ' +
                       'VALUES ( 0, '''+
                       TabAktarilacak.FieldByName('KOD').AsString+''','''+TabAktarilacak.FieldByName('FIRMA').AsString+''','''+
                       TabAktarilacak.FieldByName('GRUP').AsString+''','+'1,'''+TabAktarilacak.FieldByName('OZEL').AsString+''','''+
                       TabAktarilacak.FieldByName('NOTLAR').AsString+''',1,1,1,1,'''+Kullanan+''' )';
     Tablo.Query2.ExecSQL;
     //eklediðimiz satýrý açýp aldýðý ID yi bulalým
     Tablo.Query3.Close;
     Tablo.Query3.SQL.Text:='select * from REHBER where KOD = '''+TabAktarilacak.FieldByName('KOD').AsString+'''';
     Tablo.Query3.Open;
     RehID := Tablo.Query3.FieldByName('ID').AsInteger;
     // eklenecek alanlarý bulalým(varsayýlaný dolu olanlar..
     Tablo.Query4.Close;
     Tablo.Query4.SQL.Text:='select DISTINCT VARSAYILAN, YERI, ETIKET from REHBERAYAR where isnull(VARSAYILAN,'''')<>'''' ';
     Tablo.Query4.Open;
     while not Tablo.Query4.Eof do begin
       case Tablo.Query4.FieldByName('VARSAYILAN').AsInteger of
          2:	SQLParam := 'EVADRES';//  Adres
          4:	SQLParam := 'EVPK';//  Adres PK
          6:	SQLParam := 'EVILCE';//  Adres ILCE
          8:	SQLParam := 'EVIL';//  Adres IL
          10: SQLParam := 'FATURABASLIK';//	Fatura Baþlýðý
          12: SQLParam := 'EVADRES';//	Fatura Adresi
          14: SQLParam := 'EVPK';//	Fatura Adresi PK
          16: SQLParam := 'EVILCE';//	Fatura Adresi ILCE
          18: SQLParam := 'EVIL';//	Fatura Adresi IL
          20: SQLParam := 'VERGIDAI';//	Vergi Dairesi
          22: SQLParam := 'VERGINO';//	Vergi No
         // 32: SQLParam := '';//	Masraf Merkezi
         // 34: SQLParam := '';//	Gelir Merkezi
         // 36: SQLParam := '';//	Tahakkuk
          40: SQLParam := 'ISTEL';//  Ýþ Tel
          42: SQLParam := 'CEP';//	Cep Tel
          44: SQLParam := 'EVTEL';//	Ev Tel
          46: SQLParam := 'EMAIL';//	E-Posta
          48: SQLParam := 'WEB';//	Web
         //50: SQLParam := '';//	T.C.Kimlik No
         //52: SQLParam := '';//	Baba Ad
       end;
       // ilgili satýr insert edilir..
       Tablo.Query5.Close;
       Tablo.Query5.SQL.Text := 'INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN)VALUES('+
                         Tablo.Query4.FieldbyName('YERI').AsString+','+Tablo.Query4.FieldByName('VARSAYILAN').AsString+','+inttostr(RehID)+','''+
                         Tablo.Query4.FieldbyName('ETIKET').AsString+''','''+TabAktarilacak.FieldByName(SQLParam).AsString+''','''+Kullanan+''')' ;
       Tablo.Query5.ExecSQL;
       Tablo.Query4.Next;
     end;
     Result := True;
  end Else
     Result := False;
End;

procedure TEntegrasyonDlg.cxImageComboBox1PropertiesEditValueChanged(
  Sender: TObject);
Var
i:Integer;
begin
  if cxImageComboBox1.Text = 'Genotýpdan Rehber Al' then  begin
    cxGrid1DBTableView1.DataController.KeyFieldNames := 'KOD';
    //bir önce açýlmýþ olan tabloyu sileriz,
    if cxGrid1DBTableView1.ColumnCount > 1 then begin
       for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
           cxGrid1DBTableView1.Columns[-i].Free;
    end;
    TabAktarilacak.Close;
    TabAktarilacak.SQL.Text:='select * from REHBER';
    TabAktarilacak.Open;
    cxButton2.Enabled:=True;
    //grid içerisine seçilen yeni tabloyu açarýz(Tüm Kayýtlar)
    for i := 0 to TabAktarilacak.FieldCount-1 do begin
      cxGrid1DBTableView1.CreateColumn;
      with cxGrid1DBTableView1.Columns[i+1] do begin
        DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
        Caption := TabAktarilacak.Fields[i].FieldName;
        Width := 80;
        //Properties.ReadOnly:=True;
      end;
    end;
  end else  if cxImageComboBox1.Text = 'Genotýpa Rehber Ver' then  begin
    cxGrid1DBTableView1.DataController.KeyFieldNames := 'KOD';
    //bir önce açýlmýþ olan tabloyu sileriz,
    if cxGrid1DBTableView1.ColumnCount > 1 then begin
       for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
           cxGrid1DBTableView1.Columns[-i].Free;
    end;
    TabAktarilacak.Close;
    TabAktarilacak.Connection:=Tablo.FDCnn;
    TabAktarilacak.SQL.Text:= 'SELECT OZELTUZEL,KOD,FIRMA,GRUP,DURUM,OZEL,NOTLAR,C_ILGILI,C_TICARI,C_SOZLESME,C_GORUSME,EKLEYEN, '
        +'ISTEL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=40), '
        +'CEP=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=42),   '
        +'FAX=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=41),   '
        +'ADRES=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=2),   '
        +'ILCE=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6),     '
        +'IL=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=8),        '
        +'PK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4),         '
        +'VERGIDAI=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),   '
        +'VERGINO=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),     '
        +'WEB=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=48),          '
        +'EMAIL=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=46),        '
        +'FATURABASLIK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=10)   '
        +'FROM REHBER R ';
    TabAktarilacak.Open;
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=CNNAktarilacak;
    Tablo.Query1.SQL.Text:='select * from REHBER';
    Tablo.Query1.Open;
    //grid içerisine seçilen yeni tabloyu açarýz(Tüm Kayýtlar)
    for i := 0 to TabAktarilacak.FieldCount-1 do begin
      cxGrid1DBTableView1.CreateColumn;
      with cxGrid1DBTableView1.Columns[i+1] do begin
        DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
        Caption := TabAktarilacak.Fields[i].FieldName;
        Width := 80;
      end;
    end;
    TabAktarilacak.Connection:=Tablo.FDCnn;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    cxButton2.Enabled:=True;
  end;
end;

function TEntegrasyonDlg.DBConnect: boolean;
var
   ServerName, conStr, UserName, PassWord : string;
   bilgi : Variant;
   ctrls : TGirdiDenetimleri;
   rid : Integer;
begin

   CNNAktarilacak.Connected:=False;
   bilgi:='.';
   ctrls := TGirdiDenetimleri.Create.Edit('Aktarým Yapýlacak Server Adýný Giriniz.',@bilgi);
   if TGirisKutusuEx.BilgiAlEx('Server Adý veya IP Adresi:',ctrls) = mrOK then begin
     if Trim(bilgi) = '' then begin
        MessageDlg(('Server Adý Boþ Olamaz.'),mtError,[mbOK],0);
        Exit;
     End else begin
        ServerName := bilgi;
        bilgi:='GEN2005';
        ctrls := TGirdiDenetimleri.Create.Edit('Aktarým Yapýlacak Veritabaný Adýný Giriniz.',@bilgi);
       if TGirisKutusuEx.BilgiAlEx('Veritabaný Adý:',ctrls) = mrOK then begin
         if Trim(bilgi) = '' then begin
            MessageDlg(('Veritabaný Adý Boþ Olamaz.'),mtError,[mbOK],0);
            Exit;
         End else begin
            DBName := bilgi;
            bilgi:='SA';
           ctrls := TGirdiDenetimleri.Create.Edit('Kullanýcý Adýný Giriniz.',@bilgi);
           if TGirisKutusuEx.BilgiAlEx('Kullanýcý Adý:',ctrls) = mrOK then begin
             if Trim(bilgi) = '' then begin
                MessageDlg(('Kullanýcý Adý Boþ Olamaz.'),mtError,[mbOK],0);
                Exit;
             End else begin
               UserName := bilgi;
               bilgi:='GENOTIP';
               ctrls := TGirdiDenetimleri.Create.Edit('Aktarým Yapýlacak Server Þifresini Giriniz.',@bilgi);
               if TGirisKutusuEx.BilgiAlEx('Server Þifresi('+UserName+'):',ctrls) = mrOK then begin
                  PassWord := bilgi;
                  CNNAktarilacak.ConnectionString :=
                  'Provider=SQLOLEDB.1;Password='+PassWord+
                  ';Persist Security Info=True;Packet Size=8192;User ID='+UserName+
                  ';Initial Catalog='+DBName+
                  ';Data Source='+ServerName;
                    CNNAktarilacak.Connected:=True;
                  if CNNAktarilacak.Connected then begin
                    LabelBaglanti.Caption:='Baðlantý Baþarýlý';
                    cxGroupBox3.Enabled;
                  end;
               end;
             end;
           end;
         end;
       end;
     end;
   end;
end;

function TEntegrasyonDlg.GenotipdanRehberiEntegrayaGuncelle(Kod,GenoCnn: String): boolean;
Var
  aramadaciksin,SQLParam:string;
  RehID:Integer;
Begin
   TabAktarilacak.Close;
   CNNAktarilacak.ConnectionString:= GenoCnn;
   CNNAktarilacak.Connected;
   TabAktarilacak.Connection:=Tablo.FDCnn;
   TabAktarilacak.SQL.Text:='select * from REHBER';
   TabAktarilacak.Open;
   if TabAktarilacak.FieldByName('ARAMADACIKSIN').AsString='H' then
      aramadaciksin:='0'
   Else
      aramadaciksin:='1';
   Tablo.Query2.Close;
   Tablo.Query2.SQL.Text:='UPDATE REHBER SET ' +
                     ' FIRMA = '''+TabAktarilacak.FieldByName('FIRMA').AsString+''+
                     ',GRUP = '''+TabAktarilacak.FieldByName('GRUP').AsString+''+
                     ',DURUM = '+'1'+
                     ',OZEL = '+TabAktarilacak.FieldByName('OZEL').AsString+''+
                     ',NOTLAR = '+TabAktarilacak.FieldByName('NOTLAR').AsString+''+
                     ',ARAMADACIKSIN = '+aramadaciksin+
                     ',DEGISTIREN = '''+Kullanan+''+
                     ',DEGISTIRMETARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn',rehberini.BugunTrhSaat)+'';
   Tablo.Query2.ExecSQL;
   //deðiþtirdiðimiz satýrý açýp aldýðý ID yi bulalým
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text:='select * from REHBER where KOD = '''+TabAktarilacak.FieldByName('KOD').AsString+'''';
   Tablo.Query3.Open;
   RehID := Tablo.Query3.FieldByName('ID').AsInteger;
   // deðiþtirilecek alanlarý bulalým(varsayýlaný dolu olanlar)..
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text:='select  RA.VARSAYILAN, RB.YERI, RB.ETIKET,RB.BILGI '+
                          ' from REHBERAYAR RA inner join REHBERBILGI RB on RA.YERI=RB.YERI AND RA.ETIKET=RB.ETIKET '+
                          ' where isnull(RA.VARSAYILAN,'')<>'' AND RB.YER_ID = ' + inttostr(RehID);
   Tablo.Query4.Open;
   while not Tablo.Query4.Eof do begin
     case Tablo.Query4.FieldByName('VARSAYILAN').AsInteger of
        2:	SQLParam := 'EVADRES';//  Adres
        4:	SQLParam := 'EVPK';//  Adres PK
        6:	SQLParam := 'EVILCE';//  Adres ILCE
        8:	SQLParam := 'EVIL';//  Adres IL
        10: SQLParam := 'FATURABASLIK';//	Fatura Baþlýðý
        12: SQLParam := 'EVADRES';//	Fatura Adresi
        14: SQLParam := 'EVPK';//	Fatura Adresi PK
        16: SQLParam := 'EVILCE';//	Fatura Adresi ILCE
        18: SQLParam := 'EVIL';//	Fatura Adresi IL
        20: SQLParam := 'VERGIDAI';//	Vergi Dairesi
        22: SQLParam := 'VERGINO';//	Vergi No
       // 32: SQLParam := '';//	Masraf Merkezi
       // 34: SQLParam := '';//	Gelir Merkezi
       // 36: SQLParam := '';//	Tahakkuk
        40: SQLParam := 'ISTEL';//  Ýþ Tel
        42: SQLParam := 'CEP';//	Cep Tel
        44: SQLParam := 'EVTEL';//	Ev Tel
        46: SQLParam := 'EMAIL';//	E-Posta
        48: SQLParam := 'WEB';//	Web
       //50: SQLParam := '';//	T.C.Kimlik No
       //52: SQLParam := '';//	Baba Ad
     end;
     // ilgili satýr update edilir..
     Tablo.Query5.Close;
     Tablo.Query5.SQL.Text := 'UPDATE REHBERBILGI SET BILGI = '''+TabAktarilacak.FieldByName(SQLParam).AsString+''+
                       'WHERE VARSAYILAN = '+
                       Tablo.Query4.FieldbyName('YERI').AsString+','+Tablo.Query4.FieldByName('VARSAYILAN').AsString+','+inttostr(RehID)+','''+
                       Tablo.Query4.FieldbyName('ETIKET').AsString+''','''++''','''+Kullanan+''')' ;
     Tablo.Query5.ExecSQL;
     Tablo.Query4.Next;
   end;



{
  TabAktarilacak.Close;
  CNNAktarilacak.ConnectionString:= GenoCnn;
  CNNAktarilacak.Connected;
  TabAktarilacak.Connection:=Tablo.FDCnn;
  TabAktarilacak.SQL.Text:='SELECT * FROM REHBER WHERE KOD = '''+Kod+'';
  TabAktarilacak.Open;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='';//üstteki selecte göre update,
  Tablo.Query1.ExecSQL;}
end;

function TEntegrasyonDlg.EntegradanRehberiGenotipaGuncelle(Kod,GenoCnn: String): boolean;
Var
  aramadaciksin:string;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text:=  'SELECT OZELTUZEL,KOD,FIRMA,GRUP,DURUM,OZEL,NOTLAR,ARAMADACIKSIN,C_ILGILI,C_TICARI,C_SOZLESME,C_GORUSME,EKLEYEN, '
        +'ISTEL=(SELECT TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=40), '
        +'CEP=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=42),   '
        +'FAX=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=41),   '
        +'ADRES=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=2),   '
        +'ILCE=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6),     '
        +'IL=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=8),        '
        +'PK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4),         '
        +'VERGIDAI=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20),   '
        +'VERGINO=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22),     '
        +'WEB=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=48),          '
        +'EMAIL=(SELECT  TOP 1 BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=46),        '
        +'FATURABASLIK=(SELECT TOP 1  BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=10)   '
        +'FROM REHBER R WHERE R.KOD = '''+Kod+'';
   Tablo.Query1.Open;
     if TabAktarilacak.FieldByName('DURUM').Asboolean = False then
        aramadaciksin:='H'
     Else
        aramadaciksin:='';
   TabAktarilacak.Close;
   CNNAktarilacak.ConnectionString:= GenoCnn;
   CNNAktarilacak.Connected;
   TabAktarilacak.Connection:=Tablo.FDCnn;
   TabAktarilacak.SQL.Text := 'UPDATE REHBER SET '+
                  '  FIRMA=:PFirma '+
                  ' ,GRUP=:PFirma '+
                  ' ,ISTEL=:PFirma '+
                  ' ,CEP=:PFirma '+
                  ' ,FAX=:PFirma '+
                  ' ,EMAIL=:PFirma '+
                  ' ,WEB=:PFirma '+
                  ' ,ADRES=:PFirma '+
                  ' ,ILCE=:PFirma '+
                  ' ,IL=:PFirma '+
                  ' ,PK=:PFirma '+
                  ' ,VERGIDAI=:PFirma '+
                  ' ,VERGINO=:PFirma '+
                  ' ,NOTLAR=:PFirma '+
                  ' ,FATURABASLIK=:PFirma '+
                  ' ,ARAMADACIKSIN=:PFirma '+
                  ' WHERE KOD='''+Kod+'';
   TabAktarilacak.Params[0].Value:=Copy(Tablo.Query1.FieldByName('FIRMA').AsString,1,50);
   TabAktarilacak.Params[1].Value:=Copy(Tablo.Query1.FieldByName('GRUP').AsString,1,10);
   TabAktarilacak.Params[2].Value:=Copy(Tablo.Query1.FieldByName('ISTEL').AsString,1,20);
   TabAktarilacak.Params[3].Value:=Copy(Tablo.Query1.FieldByName('CEP').AsString,1,20);
   TabAktarilacak.Params[4].Value:=Copy(Tablo.Query1.FieldByName('FAX').AsString,1,20);
   TabAktarilacak.Params[5].Value:=Copy(Tablo.Query1.FieldByName('EMAIL').AsString,1,50);
   TabAktarilacak.Params[6].Value:=Copy(Tablo.Query1.FieldByName('WEB').AsString,1,50);
   TabAktarilacak.Params[7].Value:=Copy(Tablo.Query1.FieldByName('ADRES').AsString,1,50);
   TabAktarilacak.Params[8].Value:=Copy(Tablo.Query1.FieldByName('ILCE').AsString,1,20);
   TabAktarilacak.Params[9].Value:=Copy(Tablo.Query1.FieldByName('IL').AsString,1,25);
   TabAktarilacak.Params[10].Value:=Copy(Tablo.Query1.FieldByName('PK').AsString,1,6);
   TabAktarilacak.Params[11].Value:=Copy(Tablo.Query1.FieldByName('VERGIDAI').AsString,1,15);
   TabAktarilacak.Params[12].Value:=Copy(Tablo.Query1.FieldByName('VERGINO').AsString,1,15);
   TabAktarilacak.Params[13].Value:=Copy(Tablo.Query1.FieldByName('NOTLAR').AsString,1,150);
   TabAktarilacak.Params[14].Value:=Copy(Tablo.Query1.FieldByName('FATURABASLIK').AsString,1,100);
   TabAktarilacak.Params[15].Value:='1';
   TabAktarilacak.ExecSQL;
end;

function TEntegrasyonDlg.GenotipdanRehberHareketKontrol(Kod,GenoCnn: String): boolean;
begin
  //
end;

function TEntegrasyonDlg.EntegradanRehberHareketKontrol(Kod,GenoCnn: String): boolean;
begin
  //
end;

procedure TEntegrasyonDlg.mnSe1Click(Sender: TObject);
begin
  TabAktarilacak.First;
     while not TabAktarilacak.Eof do begin
       cxGrid1DBTableView1NAME.EditValue:=True;
       TabAktarilacak.Next;
     end;
end;

procedure TEntegrasyonDlg.mnTemizle1Click(Sender: TObject);
begin
  TabAktarilacak.First;
     while not TabAktarilacak.Eof do begin
       cxGrid1DBTableView1NAME.EditValue:=False;
       TabAktarilacak.Next;
     end;
end;

end.







