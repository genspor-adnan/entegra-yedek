unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, Menus,
  cxLookAndFeelPainters, StdCtrls, cxButtons, ADODB, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxShellBrowserDialog, cxContainer, cxTextEdit;

type
  TUrunAktarForm = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ADOQueryGOSTER: TADOQuery;
    cxTextEdit1: TcxTextEdit;
    cxButton2: TcxButton;
    cxShellBrowserDialog1: TcxShellBrowserDialog;
    DataSource1: TDataSource;
    ADOQueryAKTAR: TADOQuery;
    cxButton3: TcxButton;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    DataSourceInterposUrun: TDataSource;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3Level1: TcxGridLevel;
    cxGrid3: TcxGrid;
    DataSourceInterposBarkod: TDataSource;
    ADOQueryInterposBarkod: TADOQuery;
    cxGrid4DBTableView1: TcxGridDBTableView;
    cxGrid4Level1: TcxGridLevel;
    cxGrid4: TcxGrid;
    DataSourcePLU: TDataSource;
    ADOQueryPLU: TADOQuery;
    procedure cxButton2Click(Sender: TObject);
    procedure cxButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  UrunAktarForm: TUrunAktarForm;
  urunYOL,barkodYOL,pluYOL,yol:STRING;

implementation

uses Unit1, Unit4;

{$R *.dfm}

procedure UrunGetir();
VAR
I,ii,j,hesapBarkod,hesapUrun,hesapFiyat,hesapBirim:INTEGER;
TARTILMA,barkod,urun,fiyat,virgulsonrasi,satir,birim,KDVGRUP,aktarString:STRING;
begin
  with AnaForm do
  begin
    ADOConnection1.Close;
    ADOConnection1.ConnectionString:='Provider=SQLOLEDB.1;Password=FETAGEN;Persist Security Info=True;User ID=SA;Initial Catalog=GENTEGRE;Data Source=AVT-NOTEBOOK\SQLEXPRESS;Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=AVT-NOTEBOOK';
    ADOConnection1.Open;
  end;

  //cxGrid1DBTableView1.DataController.CreateAllItems;

  with UrunAktarForm do
  begin
    ADOQueryGOSTER.SQL.Clear;

    ADOQueryGOSTER.Close;
    ADOQueryGOSTER.SQL.Add('SELECT S.KOD,S.STOKADI,SB.BARKOD,');
    ADOQueryGOSTER.SQL.Add('ISNULL(SD.KALAN,0) AS KALAN,');
    ADOQueryGOSTER.SQL.Add('ISNULL(SF.FIYAT,0) AS FIYAT,');
    ADOQueryGOSTER.SQL.Add('ISNULL(S.KDV,0) AS KDV,');
    ADOQueryGOSTER.SQL.Add('ANABIRIM=(SELECT ANAHTAR FROM GENINI GI WHERE DEGER=S.ANABIRIM AND BOLUM=''-2702''  )');
    ADOQueryGOSTER.SQL.Add('FROM STOKLAR S ');
    ADOQueryGOSTER.SQL.Add('INNER JOIN STOKBARKOD SB ON S.ID=SB.STOKID');
    ADOQueryGOSTER.SQL.Add('LEFT JOIN STOKDURUM SD ON SD.STOKID=SB.STOKID');
    ADOQueryGOSTER.SQL.Add('LEFT JOIN STOKFIYAT SF ON SF.STOKID=SB.STOKID');
    ADOQueryGOSTER.SQL.Add('ORDER BY SB.BARKOD ASC');
    ADOQueryGOSTER.Open;

    cxGrid1DBTableView1.DataController.CreateAllItems;
    cxGrid1DBTableView1.ApplyBestFit;

   ADOQueryAKTAR.SQL.Clear;
   ADOQueryAKTAR.Close;
   ADOQueryAKTAR.SQL.Add('IF EXISTS(SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##AKTAR_:SPID_%'')');
   ADOQueryAKTAR.SQL.Add('DROP TABLE ##AKTAR');
   ADOQueryAKTAR.SQL.Add('CREATE TABLE ##AKTAR(');
   ADOQueryAKTAR.SQL.Add('[icerik] [text] NULL)');

   ADOQueryInterposBarkod.SQL.Clear;
   ADOQueryInterposBarkod.Close;
   ADOQueryInterposBarkod.SQL.Add('IF EXISTS(SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##INBARKOD_:SPID_%'')');
   ADOQueryInterposBarkod.SQL.Add('DROP TABLE ##INBARKOD');
   ADOQueryInterposBarkod.SQL.Add('CREATE TABLE ##INBARKOD(');
   ADOQueryInterposBarkod.SQL.Add('[icerik] [text] NULL)');

   ADOQueryPLU.SQL.Clear;
   ADOQueryPLU.Close;
   ADOQueryPLU.SQL.Add('IF EXISTS(SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##INPLU_:SPID_%'')');
   ADOQueryPLU.SQL.Add('DROP TABLE ##INPLU');
   ADOQueryPLU.SQL.Add('CREATE TABLE ##INPLU(');
   ADOQueryPLU.SQL.Add('[icerik] [nvarchar](40) NULL)');


       for I := 0 to ADOQueryGOSTER.RecordCount - 1 do
        BEGIN


        //kontroller +
          if ADOQueryGOSTER.FieldByName('ANABIRIM').AsString='Kg' then
          BEGIN
          TARTILMA:='E';
          END ELSE
          BEGIN
          TARTILMA:='H';
          END;
          barkod:=ADOQueryGOSTER.FieldByName('BARKOD').AsString;
          urun:=ADOQueryGOSTER.FieldByName('STOKADI').AsString;
          fiyat:= copy(ADOQueryGOSTER.FieldByName('FIYAT').AsString,0,pos(',',ADOQueryGOSTER.FieldByName('FIYAT').AsString)+2 );
          birim:=ADOQueryGOSTER.FieldByName('ANABIRIM').AsString;

          Case STRTOINT(ADOQueryGOSTER.FieldByName('KDV').AsString) of
          0 : KDVGRUP := '01' ;
          1 : KDVGRUP := '02' ;
          8 : KDVGRUP := '03' ;
          18 : KDVGRUP := '04' ;
          else
           KDVGRUP := '18' ;
          end;


          //showmessage(fiyat);

          hesapBarkod:=20-Length(barkod);
          hesapUrun:=20-Length(urun);
          hesapBirim:=4-Length(birim);

          //virgul sonrasý hane kontroller +
          if pos(',',fiyat)>0 then
          begin
          virgulsonrasi:= copy(fiyat,pos(',',fiyat)+1,2 );
          //showmessage(virgulsonrasi);

                    if Length(virgulsonrasi)=1 then
                    begin
                    fiyat:=fiyat+'0';
                    end;

          end;
          if pos(',',fiyat)=0 then
          begin
          fiyat:=fiyat+'.00';
          end;
          //virgul sonrasý hane kontroller -

            hesapFiyat:=10-Length(fiyat);

            for ii := 1 to hesapBarkod  do
            begin
            barkod:=barkod+' ';
            hesapBarkod:=hesapBarkod+1;
            end;
            for ii := 1 to hesapUrun  do
            begin
            urun:=urun+' ';
            hesapUrun:=hesapUrun+1;
            end;
            for ii := 1 to hesapBirim  do
            begin
            birim:=birim+' ';
            hesapBirim:=hesapBirim+1;
            end;

            for ii := 1 to hesapFiyat  do
            begin
            fiyat:='0'+fiyat;
            hesapFiyat:=hesapFiyat+1;
            end;

            //satýrno+
            satir:=inttostr(I+1);
            for ii := 1 to 6  do
            begin

             if Length(satir)<6 then
             begin
             satir:='0'+satir;
             end;

            end;
            //satýrno-

            fiyat:=StringReplace(fiyat,',','.',[rfReplaceAll]);
            urun:=StringReplace(urun,'Ý','i',[rfReplaceAll]);
            urun:=StringReplace(urun,'Þ','S',[rfReplaceAll]);
            urun:=StringReplace(urun,'Ç','C',[rfReplaceAll]);
            urun:=StringReplace(urun,'Ö','O',[rfReplaceAll]);
            urun:=StringReplace(urun,'Ð','G',[rfReplaceAll]);
            urun:=StringReplace(urun,'Ü','U',[rfReplaceAll]);

        //kontroller -
  //==============================================================================
  // buraya geçici tablo oluþturup memo içine attýklarýný geçici tabloya atacaksýn
  //==============================================================================

  //        MEMO1.Lines.Add('1'+'0'+ADOQuery1.FieldByName('KOD').AsString+barkod+copy(urun,0,20)+fiyat+KDVGRUP+UpperCase( birim )+TARTILMA);
  //        memo2.Lines.Add(barkod+satir);
  //        cxListBox1.Items.Add(ADOQuery1.FieldByName('KOD').AsString+satir);
  //        cxListBox1.Sorted:=true;

         aktarString:='1'+'0'+ADOQueryGOSTER.FieldByName('KOD').AsString+barkod+copy(urun,0,20)+fiyat+KDVGRUP+UpperCase( birim )+TARTILMA;
         ADOQueryAKTAR.SQL.Add('INSERT INTO ##AKTAR(icerik) values('''+aktarString+''')');
         ADOQueryInterposBarkod.SQL.Add('INSERT INTO ##INBARKOD(icerik) values('''+barkod+satir+''')');
         ADOQueryPLU.SQL.Add('INSERT INTO ##INPLU(icerik) values('''+ADOQueryGOSTER.FieldByName('KOD').AsString+satir+''')');

        ADOQueryGOSTER.Next;
        END;

   ADOQueryAKTAR.SQL.Add('select * from ##AKTAR');
   ADOQueryAKTAR.Open;


   ADOQueryInterposBarkod.SQL.Add('select * from ##INBARKOD');
   ADOQueryInterposBarkod.Open;

   ADOQueryPLU.SQL.Add('select * from ##INPLU order by icerik asc');
   ADOQueryPLU.Open;

   cxGrid2DBTableView1.DataController.CreateAllItems;
   cxGrid2DBTableView1.ApplyBestFit;

   cxGrid3DBTableView1.DataController.CreateAllItems;
   cxGrid3DBTableView1.ApplyBestFit;

   cxGrid4DBTableView1.DataController.CreateAllItems;
   cxGrid4DBTableView1.ApplyBestFit;
  end;

end;

procedure TUrunAktarForm.cxButton2Click(Sender: TObject);
begin

  if not( FileExists(cxtextedit1.Text+'\URUN.DAT') ) then
  begin
   if cxShellBrowserDialog1.Execute then
   BEGIN
     cxtextedit1.Text:=cxShellBrowserDialog1.Path;
   END;
  end;
   urunYOL:=cxtextedit1.Text+'\URUN.DAT';
   barkodYOL:=cxtextedit1.Text+'\BARKOD.IDX';
   pluYOL:=cxtextedit1.Text+'\PLUNO.IDX';

   if not( FileExists(cxtextedit1.Text+'\URUN.DAT') ) then
   begin
   showmessage('Dosya Bulunamadý');
   exit;
   end;
end;

procedure TUrunAktarForm.cxButton3Click(Sender: TObject);
var
dosyaUrun,dosyaBarkod,dosyaPlu:TextFile;
i:integer;
begin

 //kontroller +
 if (ADOQueryPLU.RecordCount<=0) or (ADOQueryAKTAR.RecordCount<=0)  or (ADOQueryInterposBarkod.RecordCount<=0) then
 begin
   showmessage('Seçimler yapýlmamýþ veya ürünler çekilmemiþ');
   exit();
 end;
 //kontroller -


    //urun için +
    i:=0;
    AssignFile(dosyaUrun,urunYOL);
    Rewrite(dosyaUrun);

       while i<= ADOQueryAKTAR.RecordCount -1  do
       begin
       Writeln(dosyaUrun,ADOQueryAKTAR.FieldByName('icerik').AsString);
       ADOQueryAKTAR.Next;
       inc(i);
       end;
    closefile(dosyaUrun);
    //showmessage('Urunler Yüklendi');
    //urun için -

    //barkod için +
    i:=0;
    AssignFile(dosyaBarkod,barkodYOL);
    Rewrite(dosyaBarkod);

       while i<=ADOQueryInterposBarkod.RecordCount-1  do
       begin
       Writeln(dosyaBarkod,ADOQueryInterposBarkod.FieldByName('icerik').AsString);
       ADOQueryInterposBarkod.Next;
       inc(i);
       end;
    closefile(dosyaBarkod);
    //showmessage('Barkod Yüklendi');
    //barkod için -

    //PLU için +
    i:=0;
    AssignFile(dosyaPlu,pluYOL);
    Rewrite(dosyaPlu);

       while i<= ADOQueryPLU.RecordCount -1  do
       begin
       Writeln(dosyaPlu,ADOQueryPLU.FieldByName('icerik').AsString);
       ADOQueryPLU.Next;
       inc(i);
       end;
    closefile(dosyaPlu);
    //showmessage('PLU Yüklendi');
    //PLU için -
showmessage('Aktarým Baþarýyla Tamamlandý');


end;

procedure TUrunAktarForm.FormCreate(Sender: TObject);
begin
   urunYOL:=cxtextedit1.Text+'\URUN.DAT';
   barkodYOL:=cxtextedit1.Text+'\BARKOD.IDX';
   pluYOL:=cxtextedit1.Text+'\PLUNO.IDX';
   yol:=cxtextedit1.Text;

   UrunGetir;
end;

end.
