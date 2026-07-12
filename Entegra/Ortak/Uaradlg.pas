unit UAraDlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBGrids,  Grids, ExtCtrls,
  Dialogs, Buttons, Mask,  Menus, ComCtrls, UFDCompatHelpers;

type
  TAraDlg = class(TForm)
    Panel1: TPanel;
    LabelPNO: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    AraPNo: TEdit;
    AraAd: TEdit;
    AraSoyad: TEdit;
    ParcaAraTus: TBitBtn;
    PopupMenu1: TPopupMenu;
    Ayarlar1: TMenuItem;
    N1: TMenuItem;
    AyarlarKaydet1: TMenuItem;
    Animate1: TAnimate;
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    AraQuery1: TADOQuery;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Label1: TLabel;
    Kaytlar1: TMenuItem;
    GelisSayisiBelirle: TMenuItem;
    EditEk: TEdit;
    LabelEk: TLabel;
    N2: TMenuItem;
    DetaylAramaysteEkle1: TMenuItem;
    sttekiEkAramayKaldr1: TMenuItem;
    Panel3: TPanel;
    Label4: TLabel;
    KapatTus: TBitBtn;
    ErisTus: TBitBtn;
    Aramadalkkahastalistelensin1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Ayarlar1Click(Sender: TObject);
    procedure AyarlarKaydet1Click(Sender: TObject);
    procedure ParcaAraTusClick(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComboBox4Exit(Sender: TObject);
    procedure ComboBox2DropDown(Sender: TObject);
    procedure Label4DblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ErisTusClick(Sender: TObject);
    procedure GelisSayisiBelirleClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DetaylAramaysteEkle1Click(Sender: TObject);
    procedure sttekiEkAramayKaldr1Click(Sender: TObject);
    procedure Aramadalkkahastalistelensin1Click(Sender: TObject);
  private
    { private declarations }
    procedure KolonlariOlustur;
  public
    { public declarations }
    Gelis, AdSakla, SoyadSakla : String[20];
    AramaModu, SonGelisSay : Integer;
    FieldList : TStringList;
  end;

var
  AraDlg: TAraDlg;
  AdList, soyadList : TStringList;
  Dno, Ad, Soyad, TNo, TAd, TSoyad : String[25];

implementation

uses UCombo, UTablo, FetaUtil, UMesaj, UVeriMotor;// {$IFNDEF AGENT} , UTabDok{$ENDIF};

{$R *.DFM}

var i,j : integer;
    s, SonGelen, AramaHastaSay: string;
    ust : boolean;
    FieldTipi : TFieldType;

procedure TAraDlg.FormCreate(Sender: TObject);
begin
//   s := GenotipIni.ReadString('GenelOpsiyon','AramaHastaSay', '30');
   if StrToInt(s) < 1 then
      AramaHastaSay := ''
   else
      AramaHastaSay := ' top '+s;


   SonGelisSay := 0;
   FieldList := TStringList.Create;
//   if GenotipIni.SectionExists('Kimlik Arama Alanlari') then
//      KolonlariOlustur
//   else begin
//      FieldList.Add('KIMLIK.DOSYANO,');
//      FieldList.Add('AD,');
//      FieldList.Add('SOYAD,');
//      FieldList.Add('DOGUMYER,');
//      FieldList.Add('DOGUMTARIH');
//   end;

//   BenzesAra := GenotipIni.ReadBool('GenelOpsiyon', 'Benzestirme', True);
   AdList := TStringlist.Create;
   SoyadList := TStringlist.Create;

   if Sifresizler>0 then begin
      AraPNO.Visible := False;
      LabelPNO.Visible := False;
      DBGrid1.Columns[0].Visible := False;
   end;


//   ComboBox1.Text := GenotipIni.ReadString('AramaEkranı','ComboBox1', '');
//   ComboBox2.Text := GenotipIni.ReadString('AramaEkranı','ComboBox2', '');
//   ComboBox3.Text := GenotipIni.ReadString('AramaEkranı','ComboBox3', '');
//   ComboBox4.Text := GenotipIni.ReadString('AramaEkranı','ComboBox4', '');
//   LabelEk.Caption := GenotipIni.ReadString('AramaEkranı',TabloDokum.Modul, '---');
   if LabelEk.Caption <> '---' then begin
      LabelEk.Hint:= copy(LabelEk.Caption,1,pos('.',LabelEk.Caption)-1);
      LabelEk.Caption := copy(LabelEk.Caption,pos('.',LabelEk.Caption)+1,length(LabelEk.Caption)-pos('.',LabelEk.Caption));
      LabelEk.Visible := True;
      EditEk.Visible := True;
   end;
end;

procedure TAraDlg.FormShow(Sender: TObject);
begin
{   if not TumKayitlar then begin
      DataSource1.DataSet := KimQuery;
      KimQuery.Open;
   end;
  TabKimlik.Refresh;
  if AramaModu = 4 then KayitAra(4, 'AD;SOYAD', AdSakla,SoyadSakla)}
end;

procedure TAraDlg.KolonlariOlustur;
begin
//   SonGelisSay := GenotipIni.ReadInteger('GenelOpsiyon','SonGelisSay',0);
//   GenotipIni.ReadSection('Kimlik Arama Alanlari', FieldList);
   for i := 0 to DBGrid1.Columns.Count-1 do
       DBGrid1.Columns[0].Destroy;
   for i := 0 to FieldList.Count-1 do begin
     DBGrid1.Columns.Add;
     DBGrid1.Columns[i].FieldName := FieldList.Strings[i];
     if FieldList.Strings[i]='DOSYANO' then
        FieldList.Strings[i]:='KIMLIK.DOSYANO'
     else if FieldList.Strings[i]='ADRES' then
        FieldList.Strings[i]:='KIMLIK.ADRES';
     if i < FieldList.Count-1 then
        FieldList.Strings[i]:=FieldList.Strings[i]+',';
//     DBGrid1.Columns[i].Width := GenotipIni.ReadInteger('Kimlik Arama Alanlari',DBGrid1.Columns[i].FieldName, 80);
   end;
end;

procedure TAraDlg.Ayarlar1Click(Sender: TObject);
begin
//   ComboIniDuzenle('Kimlik Arama Alanlari', GenotipIni);
   KolonlariOlustur;
   AyarlarKaydet1Click(Self);
end;

procedure TAraDlg.AyarlarKaydet1Click(Sender: TObject);
begin
//   if GenotipIni.SectionExists('Kimlik Arama Alanlari') then
//      for i := 0 to DBGrid1.Columns.Count-1 do
//         GenotipIni.WriteInteger('Kimlik Arama Alanlari',DBGrid1.Columns[i].FieldName, DBGrid1.Columns[i].Width);
end;

procedure TAraDlg.ParcaAraTusClick(Sender: TObject);
   procedure SifresizAra;
   begin
     AraQuery1.Close;
     if Sifresizler = 4 then
        AraQuery1.SQL.Text := 'select DISTINCT KIMLIK.DOSYANO, AD, SOYAD, DOGUMTARIH from KIMLIK, GELISLER, FATBASLIK '+
                              ' WHERE KIMLIK.DOSYANO = GELISLER.DOSYANO AND GELISLER.DOSYANO = FATBASLIK.DOSYANO'
     else
        AraQuery1.SQL.Text := 'select DISTINCT KIMLIK.DOSYANO, AD, SOYAD, DOGUMTARIH from KIMLIK, GELISLER '+
                              ' WHERE KIMLIK.DOSYANO = GELISLER.DOSYANO AND ';
     case Sifresizler of
       1 : if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then
              if Tablo.TabKulhar.FieldByName('GORME').AsString='1' then
                 AraQuery1.SQL.Text := AraQuery1.SQL.Text+' GRUP = '''+Tablo.TabKulhar.FieldByName('BILGI').AsString+''''
              else
                 AraQuery1.SQL.Text := AraQuery1.SQL.Text+' GRUP <> '''+Tablo.TabKulhar.FieldByName('BILGI').AsString+'''';
       2 : AraQuery1.SQL.Text := AraQuery1.SQL.Text+' (FATURATARIH <> '''' OR FATURANO <> '''') ';
       3 : AraQuery1.SQL.Text := AraQuery1.SQL.Text+' GELISLER.KDVDURUM = ''Dahil'' ';
     end;
     if AraAd.Text <> '' then AraQuery1.SQL.Text := AraQuery1.SQL.Text+' AND AD LIKE '''+AraAd.Text+'%''  order by AD, SOYAD'
     else if AraSoyAd.Text <> '' then AraQuery1.SQL.Text := AraQuery1.SQL.Text+' AND SOYAD LIKE '''+AraSoyAd.Text+'%''  order by SOYAD, AD';
     AraQuery1.open;
  end;

  procedure EkArama(CB1,CB2,CB3,CB4:string);
  begin
      ust:=False;
      s := 'where '+CB1+'.'+CB2;
      if (CB3='Başlayan')or(CB3='İçinde geçen') then
         s := s + ' LIKE '
      else
         s := s + CB3;

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'select '+DbUst(1)+'* from '+CB1+' '+DbSinir(1);
      Tablo.Query1.Open;

      FieldTipi := Tablo.Query1.FieldByName(CB2).DataType;
      if  (FieldTipi = FtString) Or (FieldTipi = FtMemo) Or (FieldTipi = FtDate)or(FieldTipi = FtDateTime)then
          s := s + '''';
      if CB3 = 'İçinde geçen' then  s := s + '%';
      if (FieldTipi = FtDate)or(FieldTipi = FtDateTime) then
         s := s+ FormatDateTime('mm/dd/yyyy',StrToDate(CB4)) // VALUE := GAY2AGY(VALUE);
      else
         s := s + CB4;
      if (CB3='Başlayan')or(CB3='İçinde geçen') then
         s := s + '%';
      if  (FieldTipi = FtString) Or (FieldTipi = FtMemo) Or (FieldTipi = FtDate)or(FieldTipi = FtDateTime)then
         s := s + '''';
  end;

  procedure GelisEkle;
  begin
     AraQuery1.SQL.Add(' FROM KIMLIK '+
        ' LEFT OUTER JOIN GELISLER'+
        ' ON GELISLER.DOSYANO = KIMLIK.DOSYANO '+
         ' WHERE ((GELISLER.GELISNO IS NULL '+
         ' OR GELISLER.GELISNO IN '+
         ' (SELECT '+DbUst(SonGelisSay)+'GELISNO FROM GELISLER G1 '+
       ' WHERE KIMLIK.DOSYANO = G1.DOSYANO '+
         ' ORDER BY 1 DESC '+DbSinir(SonGelisSay)+'))  ')
  end;

begin
   ParcaAraTus.Default := False;
   ErisTus.Default := True;

   if Sifresizler > 0 then begin
      SifresizAra;
      exit;
   end;

   Animate1.Play(1,23,0);
   s:=''; ust:=True;

      DNo   := ' KIMLIK.DOSYANO ';
      Ad    := ' AD ';
      Soyad := ' SOYAD ';
      TNo   := Trim(AraPNo.Text);
      TAd   := Trim(AraAd.Text);
      TSoyad:= Trim(AraSoyad.Text);

   if (TNo='')and((TAd <> '')or(TSoyad <> '')) then begin
      if TAd <> '' then begin
         Adlist := Benzestir(TAd);
         Adlist.Strings[0] := Ad + ' LIKE '''+Adlist.Strings[0]+'%''';
         for i := 1 to AdList.Count - 1 do
           Adlist.Strings[i] := ' or '+Ad + ' LIKE '''+Adlist.Strings[i]+'%''';
      end;
      if TSoyad <> '' then  begin
         Soyadlist := Benzestir(TSoyad);
         Soyadlist.Strings[0] := Soyad + ' LIKE '''+Soyadlist.Strings[0]+'%''';
         for i := 1 to SoyadList.Count - 1 do
             Soyadlist.Strings[i] := ' or '+Soyad + ' LIKE '''+Soyadlist.Strings[i]+'%''';
      end;

      AraQuery1.Close;
      AraQuery1.SQL.Text := 'select '+ AramaHastaSay+' '+FieldList.Text;
{      for i := 0 to FieldList.Count-1 do begin    //alanlar belirleniyor
          if i>0 then AraQuery1.SQL.Add(',');
          if FieldList.Strings[i]='DOSYANO,' then
             AraQuery1.SQL.Add('KIMLIK.DOSYANO')
          else
             AraQuery1.SQL.Add(FieldList.Strings[i]);
      end;  }

      if SonGelisSay>0 then begin
         GelisEkle;
         AraQuery1.SQL.Add(' AND (');
      end else
         AraQuery1.SQL.Add(' FROM KIMLIK where ((');

      if (TAd <> '')and(TSoyad = '') then begin
         AraQuery1.SQL.AddStrings(AdList);
         AraQuery1.SQL.Add(')) ORDER BY AD');
      end else if (TAd = '')and(TSoyad <> '') then begin
         AraQuery1.SQL.AddStrings(SoyadList);

         AraQuery1.SQL.Add(')) ORDER BY SOYAD');
      end else if (TAd <> '')and(TSoyad <> '') then begin
         AraQuery1.SQL.AddStrings(AdList);
         AraQuery1.SQL.Add(')and(');
         AraQuery1.SQL.AddStrings(SoyAdList);
         AraQuery1.SQL.Add(')) ORDER BY AD');
      end;
      if SonGelisSay>0 then
         AraQuery1.SQL.Add(', GIRISTARIH');

      AraQuery1.open;
      Animate1.Stop;
      exit;
   end;

   if TNo <> '' then
      s := 'where (('+Dno+' LIKE '''+TNo+'%'')or(VATANDASLIKNO LIKE '''+TNo+'%'')) ORDER BY KIMLIK.DOSYANO'
   else if (TAd <> '')and(TSoyad = '') then
         s :=  'where ('+Ad+' LIKE '''+TAd+'%'' ORDER BY AD'
   else if (TAd = '')and((TSoyad <> '')) then
         s :=  'where ('+Soyad+' LIKE '''+TSoyad+'%'' ORDER BY SOYAD'
   else if (TAd <> '')and((TSoyad <> '')) then
         s := 'where ('+Ad+' LIKE '''+TAd+'%'' AND '+Soyad+' LIKE '''+TSoyad+'%''  ORDER BY AD'
   else if (LabelEk.Visible)and(Trim(EditEk.Text)<>'') then begin
        EkArama(LabelEk.Hint, copy(LabelEk.Caption,1, pos(' ',LabelEk.Caption)-1),
        copy(LabelEk.Caption, pos(' ',LabelEk.Caption)+1,length(LabelEk.Caption)-pos(' ',LabelEk.Caption)), EditEk.Text)
   end
   else if ComboBox1.Text <> '' then
        EkArama(ComboBox1.Text, ComboBox2.Text, ComboBox3.Text, ComboBox4.Text);

  AraQuery1.Close;
  AraQuery1.SQL.Text := 'select '+ AramaHastaSay+' '+FieldList.Text;
  if SonGelisSay>0 then begin
     GelisEkle;
     AraQuery1.SQL.Add(' ) and ');
     Delete(s,1,5);
  end
  else
     AraQuery1.SQL.Add(' from KIMLIK '+Gelis);

  if not ust then begin
     if (LabelEk.Visible)and(Trim(EditEk.Text)<>'')and(LabelEk.Hint<>'KIMLIK')and(SonGelisSay < 1) then
         AraQuery1.SQL.Text := AraQuery1.SQL.Text+ ','+LabelEk.Hint      ///ComboBox1.Text
     else if (ComboBox1.Text <> 'KIMLIK') then
         AraQuery1.SQL.Text := AraQuery1.SQL.Text+ ','+ComboBox1.Text;
  end;

  if s ='' then raise exception.Create('Arama Kriteri verilmedi');
  AraQuery1.SQL.Add(s);
  if (not ust) then begin
     if (LabelEk.Visible)and(Trim(EditEk.Text)<>'')then
        AraQuery1.SQL.Add('and KIMLIK.DOSYANO='+LabelEk.Hint+'.DOSYANO')
     else
        AraQuery1.SQL.Add('and KIMLIK.DOSYANO='+ComboBox1.Text+'.DOSYANO');
  end;
  AraQuery1.open;
  Animate1.Stop;
end;

procedure TAraDlg.ComboBox1DropDown(Sender: TObject);
begin
//   GenotipIni.ReadSection('TABLEADLARI', TComboBox(Sender).Items)
end;

procedure TAraDlg.FormActivate(Sender: TObject);
begin
   AraAd.SetFocus;
   AraPNo.Text:='';
//   AraAd.Text:='';
//   AraSoyAd.Text:='';
end;

procedure TAraDlg.ComboBox2DropDown(Sender: TObject);
begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'select '+DbUst(1)+'* from '+ComboBox1.Text+' '+DbSinir(1);
    Tablo.Query1.Open;
    ComboBox2.Clear;
    Tablo.Query1.GetFieldNames(ComboBox2.Items);
end;

procedure TAraDlg.ComboBox4Exit(Sender: TObject);
begin
//   GenotipIni.WriteString('AramaEkranı','ComboBox1', ComboBox1.Text);
//   GenotipIni.WriteString('AramaEkranı','ComboBox2', ComboBox2.Text);
//   GenotipIni.WriteString('AramaEkranı','ComboBox3', ComboBox3.Text);
//   GenotipIni.WriteString('AramaEkranı','ComboBox4', ComboBox4.Text);
end;

procedure TAraDlg.Label4DblClick(Sender: TObject);
var adsoyad, AnaDosyano: string;
    GelNo : Integer;
//    stlist, DosyanoList : TStringList;
    farkli : Boolean;

    {procedure GelisnoYok;
    begin
       Tablo.Query3.Close;
       Tablo.Query3.SQL.Text := 'Select max(DOSYANO) From '+stlist.strings[i]+' where'; //bu dosyanolar içinde en yüksek hangi dosyanoda bilgi var
       for j := 0 to Dosyanolist.Count - 1 do begin
           if j>0 then Tablo.Query3.SQL.Add(' or ');
           Tablo.Query3.SQL.Add(' DOSYANO='''+Dosyanolist.strings[j]+'''');
       end;
       Tablo.Query3.Open;
       if Tablo.Query3.Fields[0].AsString <>'' then begin//eğer varsa
          Tablo.Query5.Close;
          Tablo.Query5.SQL.Text := 'Delete From '+stlist.strings[i]+' where'; //diğerlerini sil
          for j := 0 to Dosyanolist.Count - 1 do
                if Dosyanolist.strings[j]<>Tablo.Query3.Fields[0].AsString then begin
                   if Tablo.Query5.SQL.Count>1 then Tablo.Query5.SQL.Add(' or ');
                   Tablo.Query5.SQL.Add(' DOSYANO='''+Dosyanolist.strings[j]+'''');
                 end;
          Tablo.Query5.ExecSQL;
          Tablo.Query5.Close;
          Tablo.Query5.SQL.Text := 'Update '+stlist.strings[i]+' set DOSYANO='''+AnaDosyano+''' where DOSYANO='''+Tablo.Query3.Fields[0].AsString+'''';
          Tablo.Query5.ExecSQL;
       end;
    end;}

    procedure Birlestir;
       procedure uppp(Tablo1:String);
       begin
            Tablo.Query3.Close;
            Tablo.Query3.SQL.Text := 'Update '+Tablo1+' set DOSYANO='''+Anadosyano+''', GELISNO='+IntToStr(GelNo)+
             ' where DOSYANO='''+Tablo.Query1.Fields[0].AsString+''' and GELISNO='''+Tablo.Query1.Fields[1].AsString+'''';
            Tablo.Query3.ExecSQL;
       end;
    begin
       inc(Gelno);
       //gelişler için uygulayalım
       Tablo.Query1.first;
       while not Tablo.Query1.eof do begin
       //o gelişe bağlı tüm dosyalar için
         Tablo.Query2.first;
         while not Tablo.Query2.eof do begin
            uppp(Tablo.Query2.Fields[0].AsString);
            Tablo.Query2.next;
         end;
         uppp('GELISLER');
         Tablo.Query1.Next;
       end;
    end;
    {procedure kimlikleri_Birlestir;
    begin
       //kimlikleri birleştir
       for i := 0 to Dosyanolist.Count - 1 do
           if Dosyanolist.strings[i]<>AnaDosyano then begin
             Tablo.Query4.Close;
             Tablo.Query4.SQL.Text := 'Select * From KIMLIK where DOSYANO='''+Dosyanolist.strings[i]+'''';
             Tablo.Query4.Open;
             for j := 1 to Tablo.Query4.FieldCount - 1 do
                 if Tablo.Query4.Fields[j].AsString <> '' then begin
                    if pos('TARIH', Tablo.Query4.Fields[j].FieldName)>0 then
                       s := formatDateTime('MM/DD/YYYY',Tablo.Query4.Fields[j].AsDateTime)
                    else
                       s := Tablo.Query4.Fields[j].AsString;
                    Tablo.Query5.Close;
                    Tablo.Query5.SQL.Text := 'Update KIMLIK set '+Tablo.Query4.Fields[j].FieldName+'='''+S+''' where DOSYANO='''+AnaDosyano+'''';
                    Tablo.Query5.ExecSQL;
                 end;
             Tablo.Query4.Close;
             Tablo.Query4.SQL.Text := 'Delete From KIMLIK where DOSYANO='''+Dosyanolist.strings[i]+'''';
             Tablo.Query4.ExecSQL;
           end;
    end;}
begin
   Showmessage(' Kayıt birleştirme yeniden yapılandırılıyor.');
   Exit;

   if not Super then begin
      Showmessage(' Yetkili kullanıcı değilsiniz..');
      exit;
   end;
   //Ad ve soyadları aynı mı bakalım..
   if DBGrid1.SelectedRows.Count<2 then exit;

//   DosyanoList := TStringList.Create;
   farkli := False;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select DOSYANO, GELISNO, GIRISTARIH from GELISLER where ';
   with DBGrid1.DataSource.DataSet do
      for i:=0 to DBGrid1.SelectedRows.Count-1 do
      begin
        GotoBookmark(DBGrid1.SelectedRows.Items[i]);
        //DosyanoList.Add(Fields[0].AsString);
        if i = 0 then begin
           adsoyad := Fields[1].AsString+Fields[2].AsString;
           Tablo.Query1.SQL.Add('DOSYANO = '''+Fields[0].AsString+'''');
        end else begin
           if adsoyad <> Fields[1].AsString+Fields[2].AsString then farkli :=True;
           Tablo.Query1.SQL.Add('or DOSYANO = '''+Fields[0].AsString+'''');
        end;
      end;

   if farkli then
      raise exception.Create('Dosyaların ad veya soyadları aynı değil..');

//   stlist := TStringList.Create;
//   GenotipIni.ReadSection('HASTADOSYALARI', stlist);

   Tablo.Query1.SQL.Add('order by GIRISTARIH');
   Tablo.Query1.Open;
   AnaDosyano := Tablo.Query1.Fields[0].AsString;
   //Anadosya nodaki tablo gelisnolarını artıralım yoksa üzerine yazılır
   Tablo.Query2.Close;
   Tablo.Query2.SQL.Text := 'SELECT O.NAME,o.xtype FROM syscolumns C inner join sysobjectS o on o.id = c.id '+
                            ' where c.name= ''GELISNO'' and o.type =''U'' and O.NAME<>''GELISLER'' order by 1 ';
   Tablo.Query2.Open;
{   Tablo.Query2.Close;
   Tablo.Query2.SQL.Text := 'SELECT O.NAME,o.xtype FROM syscolumns C inner join sysobjectS o on o.id = c.id '+
                            '  where c.name= ''DOSYANO'' and o.type =''U'' and O.NAME<>''GELISLER'''+
                            '  and o.name not in (SELECT O.NAME FROM syscolumns C inner join sysobjectS o on o.id = c.id'+
                            '  where c.name= ''GELISNO'' and o.type =''U'' '+
                            '  ) order by 1';
   Tablo.Query2.Open;}
   while not Tablo.Query2.eof do begin
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'Update '+Tablo.Query2.Fields[0].AsString+' set GELISNO=GELISNO+100 where DOSYANO='''+AnaDosyano+'''';
      try
        Tablo.Query3.ExecSQL;
      except
      end;
      Tablo.Query2.next;
   end;
   Tablo.Query3.SQL.Text := 'Update GELISLER set GELISNO=GELISNO+100 where DOSYANO='''+AnaDosyano+'''';
   Tablo.Query3.ExecSQL;
   //Ana dosyadaki gelişlere 100 eklendi terar refresh edelim
   Tablo.Query1.Close;
   Tablo.Query1.Open;
   //şimdi sırayla birleştirelim
   Gelno:=0;
   while not Tablo.Query1.eof do begin
     Birlestir;
     Tablo.Query1.next;
   end;
   //kimlikleri_Birlestir;
   //stlist.free;
   //DosyanoList.Free;
   ShowMessage('İşlem tamamlandı..');

(*

   AraQuery1.First;
   while not AraQuery1.eof do begin
      if DBGrid1.Selected then
      adsoyad :=
      AraQuery1.next;
   end;

   DNo1 := ''; DNo2 := '';
   if not MesajStrAl('','Hastanın 1.DOSYANO giriniz :','E', nil,DNo1, 'Hastanın 2.DOSYANO giriniz : (Eklenip silinececek)', 'E', nil,DNo2) then exit;
   Tablo.Query1.SQL.Text := 'Select AD, SOYAD from KIMLIK where DOSYANO='''+DNo1+'''';
   Tablo.Query1.Open;
   Tablo.Query2.SQL.Text := 'Select AD, SOYAD from KIMLIK where DOSYANO='''+DNo2+'''';
   Tablo.Query2.Open;
   if (Tablo.Query1.Fields[0].AsString<>Tablo.Query2.Fields[0].AsString)or(Tablo.Query1.Fields[1].AsString<>Tablo.Query2.Fields[1].AsString)then
      raise exception.Create('Dosyaların ad veya soyadları aynı değil..');
   Tablo.Query1.SQL.Text := 'Select max(GELISNO) from GELISLER where DOSYANO='''+DNo1+'''';
   Tablo.Query1.Open;

   stlist := TStringList.Create;
   GenotipIni.ReadSection('HASTADOSYALARI', stlist);

   for i := 0 to stlist.Count -1 do begin
       Tablo.Query3.SQL.Text := 'Update '+stlist.strings[i]+' set GELISNO=GELISNO+'+IntToStr(100+GelisNo)+' where DOSYANO='''+DNo1+'''';
       try Tablo.Query3.ExecSQL; except end;
       Tablo.Query3.SQL.Text := 'Update '+stlist.strings[i]+' set DOSYANO ='''+DNo1+''', GELISNO=GELISNO+'+IntToStr(200+GelisNo)+' where DOSYANO='''+DNo2+'''';
       try
          Tablo.Query3.ExecSQL;
       except
          Tablo.Query3.SQL.Text := 'Select * From '+stlist.strings[i]+' where DOSYANO='''+DNo1+'''';
          Tablo.Query3.Open;
          if Tablo.Query3.RecordCount > 0 then begin //Önceki dosyada varsa bilgileri al ve sil
             Tablo.Query4.SQL.Text := 'Select * From '+stlist.strings[i]+' where DOSYANO='''+DNo2+'''';
             Tablo.Query4.Open;
             if Tablo.Query4.RecordCount > 0 then begin //Önceki dosyada varsa bilgileri al ve sil
               for i := 1 to Tablo.Query3.FieldCount - 1 do
                 if Tablo.Query3.Fields[i].AsString <> '' then begin
                    Tablo.Query5.SQL.Text := 'Update '+stlist.strings[i]+' set '+Tablo.Query4.Fields[i].FieldName+'='''+Tablo.Query4.Fields[i].AsString+''' where DOSYANO='''+DNo2+'''';
                    Tablo.Query5.ExecSQL;
                 end;
               Tablo.Query3.SQL.Text := 'Delete from '+stlist.strings[i]+' where DOSYANO='''+DNo1+'''';
               Tablo.Query3.ExecSQL;
             end
          end else begin
             Tablo.Query3.SQL.Text := 'Update '+stlist.strings[i]+' set DOSYANO='''+DNo1+''' where DOSYANO='''+DNo2+'''';
             Tablo.Query3.ExecSQL;
          end;
      end;
   end;

   Tablo.Query2.SQL.Text := 'Select GELISNO from GELISLER where DOSYANO='''+DNo1+''' order by GIRISTARIH';
   Tablo.Query2.Open;
   GelisNo := 0;
   while not Tablo.Query2.eof do begin
      inc(GelisNo);
      for i := 0 to stlist.Count -1 do begin
          Tablo.Query3.SQL.Text := 'Update '+stlist.strings[i]+' set GELISNO= '+IntToStr(GelisNo)+
                                   ' where DOSYANO='''+DNo1+''' and GELISNO = '+Tablo.Query2.Fields[0].AsString;
          try
            Tablo.Query3.ExecSQL;
          except
          end;
      end;
      Tablo.Query2.next;
   end;
   stlist.free;

   Tablo.Query3.SQL.Text := 'Select * from KIMLIK where DOSYANO='''+DNo2+'''';
   Tablo.Query3.Open;
   Tablo.TabKimlik.Close;
   Tablo.TabKimlik.Params[0].AsString := DNo1;
   Tablo.TabKimlik.Open;
   Tablo.TabKimlik.Edit;
   for i := 1 to Tablo.TabKimlik.FieldCount -1 do
      if Tablo.Query3.Fields[i].AsString<>'' then
         Tablo.TabKimlik.Fields[i].AsString :=  Tablo.Query3.Fields[i].AsString;
   Tablo.TabKimlik.Post;
   Tablo.Query3.SQL.Text := 'Delete from KIMLIK where DOSYANO='''+DNo2+'''';
   Tablo.Query3.ExecSQL;
   ShowMessage('İşlem tamamlandı..');
   *)
end;

procedure TAraDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key in ['0'..'9'])or(Key in ['a'..'z'])or(Key in ['A'..'Z'])or(Key in ['ğ','ü','ş','ı','ö','ç','Ğ','Ü','Ş','İ','Ö','Ç']) then begin
      ParcaAraTus.Default := True;
      ErisTus.Default := False;
   end
end;

procedure TAraDlg.FormKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
    if Key = 38 then begin
      AraQuery1.Prior;
      ParcaAraTus.Default := False;
      ErisTus.Default := True;
   end
   else if Key = 40 then begin
      AraQuery1.next;
      ParcaAraTus.Default := False;
      ErisTus.Default := True;
   end
   else if (Key = VK_Return)and(ParcaAraTus.Default) then begin
      ParcaAraTus.Default := False;
      ErisTus.Default := True;
   end

end;

procedure TAraDlg.ErisTusClick(Sender: TObject);
begin
   if (not AraQuery1.Active)or(AraQuery1.Fields[0].AsString='') then
      raise exception.create('Erişim için hasta bulunamadı..')
   else
      ModalResult := mrOk;
end;

procedure TAraDlg.GelisSayisiBelirleClick(Sender: TObject);
begin
//   s := GenotipIni.ReadString('GenelOpsiyon','SonGelisSay', '0');
//   if not MesajStrAl('','Hastanın son kaç gelişi :','E', nil,s, '', 'E', nil,s) then exit;
//   SonGelisSay := StrToInt(s);
//   GenotipIni.WriteInteger('GenelOpsiyon','SonGelisSay', SonGelisSay);
end;

procedure TAraDlg.FormDestroy(Sender: TObject);
begin
   FieldList.Free;
end;

procedure TAraDlg.DetaylAramaysteEkle1Click(Sender: TObject);
begin
   if (ComboBox1.Text='')or(ComboBox2.Text='')or(ComboBox3.Text='')then
      showmessage('Alanlarda boşluk bırakmayın..')
   else begin
//      GenotipIni.WriteString('AramaEkranı',TabloDokum.Modul, Trim(ComboBox1.Text)+'.'+Trim(ComboBox2.Text)+' '+Trim(ComboBox3.Text));
      LabelEk.Hint:= Trim(ComboBox1.Text);
      LabelEk.Caption := Trim(ComboBox2.Text)+' '+Trim(ComboBox3.Text);
      LabelEk.Visible := True;
      EditEk.Visible := True;
   end;
end;

procedure TAraDlg.sttekiEkAramayKaldr1Click(Sender: TObject);
begin
//      GenotipIni.WriteString('AramaEkranı',TabloDokum.Modul, '---');
      LabelEk.Visible := False;
      EditEk.Visible := False;
end;

procedure TAraDlg.Aramadalkkahastalistelensin1Click(Sender: TObject);
begin
//   s := GenotipIni.ReadString('GenelOpsiyon','AramaHastaSay', '30');
//   if not MesajStrAl('','Aramada İlk kaç hasta listelensin : (Sınırsız için 0 girin)','E', nil,s, '', 'E', nil,s) then exit;
//   GenotipIni.WriteString('GenelOpsiyon','AramaHastaSay', s);
   if StrToInt(s) < 1 then
      AramaHastaSay := ''
   else
      AramaHastaSay := ' top '+s;
end;

End.

