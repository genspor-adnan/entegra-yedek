unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, Buttons, cxStyles,
  dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxGridLevel, cxClasses,
  cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxContainer, cxListBox;

type
  THareketAktarForm = class(TForm)
    Edit1: TEdit;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ADOQuerySORGU: TADOQuery;
    ADOQueryGOSTER: TADOQuery;
    BarkodList: TcxListBox;
    DataSource1: TDataSource;
    cxGrid1DBTableViewBARKOD: TcxGridDBColumn;
    cxGrid1DBTableViewTARIH: TcxGridDBColumn;
    cxGrid1DBTableViewMIKTAR: TcxGridDBColumn;
    cxGrid1DBTableViewKDV: TcxGridDBColumn;
    cxGrid1DBTableViewBIRIM: TcxGridDBColumn;
    cxGrid1DBTableViewTUR: TcxGridDBColumn;
    cxGrid1DBTableViewFATTOPLAM: TcxGridDBColumn;
    cxGrid1DBTableViewFISFATNO: TcxGridDBColumn;
    cxButton2: TcxButton;
    FileOpenDialog1: TFileOpenDialog;
    Button1: TButton;
    cxGrid1DBTableViewISKONTO: TcxGridDBColumn;
    procedure cxButton2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HareketAktarForm: THareketAktarForm;
  HareketYOL:string;

implementation

uses Unit1;

{$R *.dfm}


procedure GETIR();
var
dosya:TextFile;
s,barkod,tarih,saat,miktar,TUR,TOPLAM,birim,FISFATNO:string;
I,j,jj:integer;
DiziMiktar,DiziKDV,DiziTur,DiziTarih,DiziTektoplam,DiziFisfatno,DiziFattoplam,DiziBirim,diziIskonto:array of string;
begin
j:=0;
jj:=0;
SetLength(DiziMiktar,40);
SetLength(DiziTektoplam,40);
SetLength(DiziBirim,40);
SetLength(DiziIskonto,40);
SetLength(DiziKDV,40);
HareketAktarForm.BarkodList.Items.Clear;

  with AnaForm do  begin
     ADOConnection1.Close;
     ADOConnection1.ConnectionString:='Provider=SQLOLEDB.1;Password=FETAGEN;Persist Security Info=True;User ID=SA;Initial Catalog=GENTEGRE;Data Source=AVT-NOTEBOOK\SQLEXPRESS;Use Procedure for Prepare=1;Auto Translate=True;Packet Size=4096;Workstation ID=AVT-NOTEBOOK';
     ADOConnection1.Open;
  end;



   if HareketAktarForm.edit1.Text <> '' then  begin

    try
      AssignFile(dosya,HareketYOL);
      Reset(dosya);
    except
      showmessage('Dosya Yolu Bulunamadi');
    end;

     while not eof(dosya) do begin
       Readln(dosya,s);
       //operasyon +
         if copy(s,12,3)='BKD' then  begin
           barkod:=copy(s,16,12);
           //barkod:=StringReplace(barkod,',','',[rfReplaceAll]);
           barkod:=barkod+trim(copy(s,29,4));
           //showmessage(barkod);
           HareketAktarForm.BarkodList.Items.Add(barkod);
         end;
         if copy(s,12,3)='TAR' then  begin
           saat:=copy(s,29,8);
           tarih:=copy(s,16,10);
           tarih:=StringReplace(tarih,'/','-',[rfReplaceAll]);
           tarih:=tarih+' '+saat+'.000';
//          DiziTarih[j]:=copy(s,16,2);
//          inc(j);
         end;
         if copy(s,12,3)='SAT' then begin
         DiziMiktar[j]:=copy(s,16,2);
         DiziTektoplam[j]:=TRIM(copy(s,31,10));
         DiziTektoplam[j]:=StringReplace(DiziTektoplam[j],'.',',',[rfReplaceAll]);
         DiziMiktar[j]:=StringReplace(DiziMiktar[j],'.',',',[rfReplaceAll]);
         DiziBirim[j]:=floattostr( strtofloat(DiziTektoplam[j]) / strtoint(DiziMiktar[j]) ) ;
         DiziBirim[j]:=StringReplace(DiziBirim[j],',','.',[rfReplaceAll]);

         DiziKDV[j]:=TRIM(copy(s,29,2));
          Case STRTOINT(DiziKDV[j]) of
          01 : DiziKDV[j] := '0' ;
          02 : DiziKDV[j] := '1' ;
          03 : DiziKDV[j] := '8' ;
          04 : DiziKDV[j] := '18' ;
          else
           DiziKDV[j] := '18' ;
          end;


         inc(j);

         end;

         if copy(s,12,3)='FIS' then
         begin
           TUR:='16';
           FISFATNO:=trim(copy(s,29,12));
         end;
         if copy(s,12,3)='FAT' then
         begin
           TUR:='15';
           FISFATNO:=trim(copy(s,29,12));
         end;
         if copy(s,12,3)='TOP' then
         begin
           TOPLAM:=TRIM(copy(s,31,10));
         end;
         if copy(s,12,3)='IND' then
         begin
           DiziIskonto[j-1]:=TRIM(copy(s,24,4));
           //showmessage(iskonto);
         end;
        //operasyon -

     end;
     CloseFile(dosya);

       HareketAktarForm.ADOQueryGoster.SQL.Clear;
       HareketAktarForm.ADOQueryGoster.Close;
       HareketAktarForm.ADOQueryGoster.SQL.Add('IF EXISTS(SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##TMP_:SPID_%'')');
       HareketAktarForm.ADOQueryGoster.SQL.Add('DROP TABLE ##TMP');
       HareketAktarForm.ADOQueryGoster.SQL.Add('CREATE TABLE ##TMP(');
       HareketAktarForm.ADOQueryGoster.SQL.Add('[barkod] [nvarchar](50) NULL,[tarih] [nvarchar](50) NULL,[miktar] [float] NULL,[kdv] [nvarchar](50) NULL,');
       HareketAktarForm.ADOQueryGoster.SQL.Add('[birim] [float] NULL,[tur] [nvarchar](50) NULL,[fattoplam] [float] NULL,[fisfatno] [nvarchar](50) NULL,[iskonto] [nvarchar](15) NULL)');



     for I := 0 to HareketAktarForm.BarkodList.Count - 1 do
     begin
     //showmessage('i: '+DiziMiktar[i]);
       HareketAktarForm.ADOQueryGoster.SQL.Add('INSERT INTO ##TMP(barkod,tarih,miktar,kdv,birim,tur,fattoplam,fisfatno,iskonto) values('''+HareketAktarForm.BarkodList.Items.Strings[i]+''','''+tarih+''','''+DiziMiktar[i]+''','''+DiziKDV[i]+''','''+DiziBirim[i]+''','''+tur+''','''+toplam+''','''+FISFATNO+''','''+diziIskonto[i]+''')');
//       HareketAktarForm.ADOQueryGoster.SQL.Add('INSERT INTO ##TMP(barkod,tarih,miktar,kdv,birim,tur,fattoplam,fisfatno) values(:barkod,:tarih,:miktar,:kdv,:birim,:tur,:fattoplam,:fisfatno)';
//      HareketAktarForm.parameters.parambyname('barkod').asstring := 'asdasd';
//      HareketAktarForm.parameters.parambyname('barkod').asstring := 'asdasd';
//      HareketAktarForm.parameters.parambyname('barkod').asstring := 'asdasd';
//      HareketAktarForm.parameters.parambyname('barkod').asstring := 'asdasd';

     end;
       HareketAktarForm.ADOQueryGoster.SQL.Add('select barkod,tarih,miktar=sum(miktar),kdv,birim,tur,fattoplam,fisfatno,iskonto=(isnull(iskonto,''%0'')) from ##TMP t');
       HareketAktarForm.ADOQueryGoster.SQL.Add('GROUP BY barkod,tarih,kdv,birim,tur,fattoplam,fisfatno,iskonto');
       HareketAktarForm.ADOQueryGoster.Open;

  end else
  showmessage('Okunacak Dosya Seçin');

end;

procedure AKTAR_FATURA(TARIH,BARKOD,FATURA_TUTARI,FISFATNO,KDV,BR_TUTAR,iskonto:STRING;BRADET,TUR:INTEGER);
var
BARKODBIRIMI,REHBERID,FATBASID,STOKID:INTEGER;
TARIHgun,TARIHay,TARIHyil,saat,hesap:string;
begin
   //SABÝTLER +
  REHBERID:=-99;
  //SABÝTLER -

  BR_TUTAR:=StringReplace(BR_TUTAR,',','.',[rfReplaceAll]);
  //showmessage(BR_TUTAR);
  TARIHgun:=copy(tarih,1,2);
  TARIHay:=copy(tarih,4,2);
  TARIHyil:=copy(tarih,7,4);
  saat:=copy(tarih,11,12);
  TARIH:=TARIHyil+'-'+TARIHay+'-'+TARIHgun+' '+saat;
  iskonto:=copy(iskonto,2,2);
  //showmessage(iskonto);
  hesap:= StringReplace(FATURA_TUTARI,',','.',[rfReplaceAll]);

  //SHOWMESSAGE(birim);

    WITH HareketAktarForm DO
    BEGIN
       ADOQuerySorgu.SQL.Clear;
       ADOQuerySorgu.Close;
       ADOQuerySorgu.SQL.Add('SELECT top 1 * FROM FATBASLIK ORDER BY ID DESC');
       ADOQuerySorgu.Open;

      FATBASID:=ADOQuerySorgu.FieldByName('ID').AsInteger;

       ADOQuerySorgu.SQL.Clear;
       ADOQuerySorgu.Close;
       ADOQuerySorgu.SQL.Add('SELECT * FROM STOKBARKOD WHERE BARKOD='''+BARKOD+'''');
       ADOQuerySorgu.Open;

       STOKID:= ADOQuerySorgu.FieldByName('STOKID').AsInteger;
       BARKODBIRIMI:= ADOQuerySorgu.FieldByName('BARKODBIRIMI').AsInteger;
       //SHOWMESSAGE('STOKID: '+INTTOSTR(STOKID));

       //urun önceden eklenmiþmi +
       ADOQuerySorgu.SQL.Clear;
       ADOQuerySorgu.Close;
       ADOQuerySorgu.SQL.Add('SELECT * FROM FATURA WHERE URUNID='''+inttostr(STOKID)+''' and FATBASID='''+INTTOSTR(FATBASID)+'''');
       ADOQuerySorgu.Open;

       if ADOQuerySorgu.RecordCount>=1 then
       begin

       BRADET:=BRADET+ADOQuerySorgu.FieldByName('ADET').AsInteger;
       //showmessage(ADOQuerySorgu.FieldByName('ADET').AsString+'  '+inttostr(BRADET));
       ADOQuerySorgu.SQL.Clear;
       ADOQuerySorgu.Close;
       ADOQuerySorgu.SQL.Add('update FATURA set ADET='''+INTTOSTR(BRADET)+''',MIKTAR='''+INTTOSTR(BRADET)+''' where URUNID='''+inttostr(STOKID)+''' and FATBASID='''+INTTOSTR(FATBASID)+'''');
       ADOQuerySorgu.SQL.Add('SELECT TOP 1 * FROM FATURA ORDER BY ID DESC');
       ADOQuerySorgu.Open;
       end else begin

       //urun önceden eklenmiþmi -

       ADOQuerySorgu.SQL.Clear;
       ADOQuerySorgu.Close;
       ADOQuerySorgu.SQL.Add('INSERT INTO FATURA(FATBASID,REHBERID,TUR,URUNID,ADET,TUTAR,MIKTAR,BIRIM,BIRIMFIYAT,ACIKLAMA,KDV,ISKONTO)');
       ADOQuerySorgu.SQL.Add('VALUES('''+INTTOSTR(FATBASID)+''','''+INTTOSTR(REHBERID)+''','''+INTTOSTR(TUR)+''','''+INTTOSTR(STOKID)+''','''+INTTOSTR(BRADET)+''','''+hesap+''','''+INTTOSTR(BRADET)+''','''+INTTOSTR(BARKODBIRIMI)+''','''+BR_TUTAR+''',''INTERPOS SATIS'','''+KDV+''','''+iskonto+''')');
       ADOQuerySorgu.SQL.Add('SELECT TOP 1 * FROM FATURA ORDER BY ID DESC');
       ADOQuerySorgu.Open;
       end;

    END;

end;

procedure AKTAR_FATBASLIK(TARIH,FATURA_TUTARI,FISFATNO,KDV:STRING;TUR:INTEGER);
var
TIPI,REHBERID,KOCANNO,FATURASERI:INTEGER;
TARIHgun, TARIHay, TARIHyil, saat,FATURA_MATRAH,KDV_TUTAR:string;
begin
//SABÝTLER +
  TIPI:=1;
  REHBERID:=-99;
  KOCANNO:=999;
  FATURASERI:=999;
//SABÝTLER -

//BUL +
KDV_TUTAR:=floattostr(( strtofloat(FATURA_TUTARI)*strtoint(KDV) ) /100 );
KDV_TUTAR:=StringReplace(KDV_TUTAR,',','.',[rfReplaceAll]);

FATURA_MATRAH:=floattostr( strtofloat(FATURA_TUTARI) - ( ( strtofloat(FATURA_TUTARI)*strtoint(KDV) ) /100 ) );
FATURA_MATRAH:=StringReplace(FATURA_MATRAH,',','.',[rfReplaceAll]);

FATURA_TUTARI:=StringReplace(FATURA_TUTARI,',','.',[rfReplaceAll]);
//showmessage(FATURA_MATRAH);
 //exit;
//BUL -

  TARIHgun:=copy(tarih,1,2);
  TARIHay:=copy(tarih,4,2);
  TARIHyil:=copy(tarih,7,4);
  saat:=copy(tarih,11,12);
  TARIH:=TARIHyil+'-'+TARIHay+'-'+TARIHgun+' '+saat;

    WITH HareketAktarForm DO
    BEGIN
    AdoQuerySORGU.SQL.Clear;
    AdoQuerySORGU.Close;
    AdoQuerySORGU.SQL.Add('INSERT INTO FATBASLIK(TARIH,TUR,TIPI,REHBERID,KOCANNO,BASLIK,FATURA_TUTARI,FATURATARIH,FATURANO,FATURASERI,FATURA_MATRAHI,KDV_TUTARI)');
    AdoQuerySORGU.SQL.Add('VALUES('''+TARIH+''','''+INTTOSTR(TUR)+''','''+INTTOSTR(TIPI)+''','''+INTTOSTR(REHBERID)+''','''+INTTOSTR(KOCANNO)+''',''INTERPOS'','''+FATURA_TUTARI+''','''+TARIH+''','''+FISFATNO+''','''+INTTOSTR(FATURASERI)+''','''+FATURA_MATRAH+''','''+KDV_TUTAR+''')');
    AdoQuerySORGU.SQL.Add('SELECT TOP 1 * FROM FATBASLIK ORDER BY ID DESC');
    AdoQuerySORGU.Open;
    END;

end;

procedure THareketAktarForm.Button1Click(Sender: TObject);
begin
 if FileOpenDialog1.Execute then
 BEGIN
   EDIT1.Text:=FileOpenDialog1.FileName;

   if FileExists(EDIT1.Text) then
   begin
     HareketYOL:=Edit1.Text;

     GETIR;

   end else  begin
     showmessage('Hareket bulunamadý');
   end;

 END;

end;

procedure THareketAktarForm.cxButton2Click(Sender: TObject);
var
i:integer;
begin

 if (edit1.Text='') or (ADOQueryGOSTER.RecordCount<=0) then
 begin
   Showmessage('Seçim Yapýnýz');
   exit;
 end;

//showmessage(ADOQueryGOSTER.FieldByName('fisfatno').Text);
  AKTAR_FATBASLIK(ADOQueryGOSTER.FieldByName('tarih').AsString,ADOQueryGOSTER.FieldByName('fattoplam').AsString,ADOQueryGOSTER.FieldByName('fisfatno').AsString,ADOQueryGOSTER.FieldByName('kdv').AsString,ADOQueryGOSTER.FieldByName('tur').AsInteger);
  for I := 0 to ADOQueryGOSTER.RecordCount - 1 do
  begin
  AKTAR_FATURA(ADOQueryGOSTER.FieldByName('tarih').AsString,ADOQueryGOSTER.FieldByName('barkod').AsString,ADOQueryGOSTER.FieldByName('fattoplam').AsString,ADOQueryGOSTER.FieldByName('fisfatno').AsString,ADOQueryGOSTER.FieldByName('kdv').AsString,ADOQueryGOSTER.FieldByName('birim').AsString,ADOQueryGOSTER.FieldByName('iskonto').AsString,ADOQueryGOSTER.FieldByName('miktar').AsInteger,ADOQueryGOSTER.FieldByName('tur').AsInteger);

  ADOQueryGOSTER.Next
  end;
HareketAktarForm.BarkodList.Visible:=false;
showmessage('Aktarým tamam');
end;

end.
