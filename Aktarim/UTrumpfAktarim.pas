unit UTrumpfAktarim;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, DateUtils, XSBuiltins,
  Data.DB, Data.Win.ADODB, Vcl.StdCtrls, cxProgressBar, Registry, UGenSifre,
  cxGroupBox, cxRadioGroup, LibXmlParser, ECXmlParser;

type
  TTrumpfAktarimDlg = class(TForm)
    LblKlasorKonumu: TLabel;
    BaslatButton: TButton;
    KlasorAc: TButton;
    MemoLog: TMemo;
    cnn: TADOConnection;
    TabServisler: TADOQuery;
    Query1: TADOQuery;
    Servis: TADOQuery;
    ServisHareket: TADOQuery;
    ServisBilgi: TADOQuery;
    Button1: TButton;
    procedure KlasorAcClick(Sender: TObject);
    procedure BaslatButtonClick(Sender: TObject);
    procedure TabloYenile(TabloAdi: TADOQuery; p: array of Variant;LocateID:integer=0; IDTur:String='ID');
    function AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant; IDAlani: string='ID'):string;
    function IDGetir(TabloAdi: string; AciklamaAlanlari,Aciklamalar: array of string):integer;
    function ServisHareketEkle(AServisID,APersonelID,ADurum,AGeriDonusID:integer;AAciklama:string;ABaslama,ABitis:TDateTime):integer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }

    procedure ServisTablosunaKaydet(Dosya:String);
  public
    { Public declarations }
  end;

var
  TrumpfAktarimDlg: TTrumpfAktarimDlg;

  SystemIni: TRegistry;

implementation

{$R *.dfm}

procedure TTrumpfAktarimDlg.BaslatButtonClick(Sender: TObject);
var
  LstAdres,LstKod : TStringList;
  SR: TSearchRec;
  i,ServisID: integer;
begin
MemoLog.Lines.Add('-------------------------------------------');
MemoLog.Lines.Add('-------------------------------------------');
  {MemoLog.Lines.Clear;
  if LblKlasorKonumu.Caption = 'Klasör Konumu' then
    Exit;
  ///////////////////////////////////
  MemoLog.Lines.Add('Listeler Oluþturuluyor..');
  LstAdres := TStringList.Create();
  LstKod := TStringList.Create();
  TabServisler.Open;
  if FindFirst(LblKlasorKonumu.Caption+'*.*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr <> faDirectory) then begin
        LstAdres.Add(LblKlasorKonumu.Caption+SR.Name);
        LstKod.Add(ChangeFileExt(SR.Name,''));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;  }
  ///////////////////////////////////
  {for i := 0 to LstAdres.Count - 1 do begin
    ServisID := 0;
    TabServisler.First;
    try
      if TabServisler.locate('OZELKOD',LstKod[i],[]) then begin
        ServisID := TabServisler.FieldByName('ID').AsInteger;
        MemoLog.Lines.Add(LstAdres.Strings[i]+' için servis kaydý bulundu. ID:'+IntToStr(ServisID));
      end else
        MemoLog.Lines.Add(LstAdres.Strings[i]+' için servis kaydý bulunamadý!!');
    except
      MemoLog.Lines.Add(LstAdres.Strings[i]+' için beklenmedik bir hata oluþtu!!');
    end;
     }
    try
      ServisTablosunaKaydet(LblKlasorKonumu.Caption);
      MemoLog.Lines.Add(ExtractFileName(LblKlasorKonumu.Caption)+' için servis kaydý oluþturuldu!');
    except
      MemoLog.Lines.Add(ExtractFileName(LblKlasorKonumu.Caption)+' için servis kaydý oluþturulurken beklenmedik bir hata oluþtu!!');
      Exit;
    end;

      //MemoLog.Lines.Add(LstAdres.Strings[i]+' için resim eklendi.');


  //end;
  //MemoLog.Lines.Add('Ýþlem Tamamlandý.');
  //ShowMessage(Lst.Text);
  //LstKod.Free;
  //LstAdres.Free;
end;

procedure TTrumpfAktarimDlg.Button1Click(Sender: TObject);
begin
  MemoLog.Lines.Clear;
end;

procedure TTrumpfAktarimDlg.FormCreate(Sender: TObject);
var
  s:string;
begin
  SystemIni:=TRegistry.Create;
  SystemIni.RootKey := HKEY_CURRENT_USER;
  SystemIni.OpenKey('SOFTWARE\GENTEGRE2\',True);
  cnn.ConnectionString := DeSifre(SystemIni.ReadString('ConnectionString'));
  cnn.Connected := True;
end;

procedure TTrumpfAktarimDlg.ServisTablosunaKaydet(Dosya:String);
var
  xml:TECXmlParser;
  i,RehberID,ServisID,ServisHareketYeniID,ServisHareketSonID,PersonelID:integer;
  MusKodu,EklemeTrh,ServisNo,ServisTip,GenelAciklama,Problem:string;
  Personel,Ilgili,EkipmanSeri,Aciklama:string;
  IsGunu:TXSDateTime;
  YolBaslama,YolBitis,IsBaslama,IsBitis:TXSDuration;
  IsMola,YolMola:TXSDuration;
begin
  xml:=TECXmlParser.Create(nil);
  xml.LoadFromFile(Dosya,TEncoding.UTF8);

  ServisNo := xml.Root.NamedItem['MissionOrder'].NamedItem['Version'].NamedItem['ID'].Text;
  Query1.close;
  Query1.SQL.Text :=  'select * from SERVIS where SERVISNO='''+ServisNo+'''';
  Query1.Open;
  if Query1.RecordCount>0 then begin
    ShowMessage('Aktarmak istediðiniz '+ServisNo+' nolu servis daha önce kaydedilmiþ. Tekrar aktarýlamýyor!!');
    MemoLog.Lines.Add('Aktarmak istediðiniz '+ServisNo+' nolu servis daha önce kaydedilmiþ. Tekrar aktarýlamýyor!!');
    Abort;
  end;

  MusKodu := xml.Root.NamedItem['MissionOrder'].NamedItem['CustomerNumber'].Text;   //Müþteri Kodu
  //Önemli:Müþteriye REHBER.OZELKOD dan ulaþýyor.
  RehberID := IDGetir('REHBER',['OZELKOD'],[MusKodu]);
  if RehberID <=0 then begin
    MemoLog.Lines.Add('!!!ServisNo:'+ServisNo+' CustomerNumber:'+MusKodu+' için Gentegre Rehber kaydý bulunamadý.(OZELKOD)');
    Exit;
  End else begin
    MemoLog.Lines.Add('ServisNo:'+ServisNo+' CustomerNumber:'+MusKodu+' için Gentegre Rehber kaydý bulundu.(RehberID:'+IntToStr(RehberID)+')');
    MemoLog.Lines.Add('Firma:'+AciklamaGetir('REHBER','FIRMA',RehberID));
  end;

  EklemeTrh := StringReplace(xml.Root.NamedItem['MissionOrder'].NamedItem['Created'].Text,'T',' ',[]);
  ServisTip := xml.Root.NamedItem['MissionOrder'].NamedItem['Type'].Text;
  Problem := StringReplace(xml.Root.NamedItem['MissionOrder'].NamedItem['Description'].Text,'''','''''',[rfReplaceAll]);
  //Yeni servis kaydýnýn açýldýðý yer
  try
    Query1.close;
    Query1.SQL.Text := 'exec sp_prg_Servis_Yeni '+IntToStr(RehberID)+',-1,0,'''+Copy(ServisTip + ' - ' +Problem,1,100)+''','''+EklemeTrh+''', '''',100,'+ServisNo+'  ';
    Query1.Open;
    ServisID := Query1.Fields[0].AsInteger;
    MemoLog.Lines.Add('Kayýt Oluþturuldu. Dýþ ID:'+ServisNo+' Ýç ID:'+Query1.Fields[0].AsString);
  Except
    MemoLog.Lines.Add('!!!Kayýt Oluþturulamadý. '+ServisNo);
    Exit;
  end;
  TabloYenile(Servis,[ServisID]);
  TabloYenile(ServisHareket,[ServisID]);
  TabloYenile(ServisBilgi,[ServisID]);
  ServisHareketYeniID := ServisHareket.FieldByName('ID').AsInteger;

  EkipmanSeri := xml.Root.NamedItem['MissionReport'].NamedItem['MachineData'].NamedItem['EquipmentNumber'].Text;
  Ilgili := StringReplace(xml.Root.NamedItem['MissionOrder'].NamedItem['ContactPerson'].NamedItem['Name'].Text,'''','''''',[rfReplaceAll]);
  Personel := StringReplace(xml.Root.NamedItem['MissionOrder'].NamedItem['Technician'].NamedItem['DisplayName'].Text,'''','''''',[rfReplaceAll]);
//servisteki ek güncellemelerin yapýldýðý yer
  Servis.Edit;
  Servis.FieldByName('TURU').AsString := '1';
  Servis.FieldByName('DISSERVIS').AsBoolean := True;
  Servis.FieldByName('SERVISNO').AsString := ServisNo;
  Servis.FieldByName('SERINO').AsString := EkipmanSeri;
  //Servis.FieldByName('NOTLAR').AsString := Copy(xml.Root.NamedItem['MissionOrder'].NamedItem['Description'].Text,1,200);
  Servis.FieldByName('EKIPMANREHBERID').AsInteger := IDGetir('EKIPMANREHBER',['REHBERID','SERINO'],[IntToStr(RehberID),EkipmanSeri]);
  if Servis.FieldByName('EKIPMANREHBERID').AsInteger>0 then begin
    Query1.Close;
    Query1.SQL.Text := 'select EKIPMANID from EKIPMANREHBER where ID='+Servis.FieldByName('EKIPMANREHBERID').AsString;
    Query1.Open;
    Servis.FieldByName('EKIPMANID').AsInteger := Query1.Fields[0].AsInteger;
    MemoLog.Lines.Add('Ekipman Bulundu ID:'+Query1.Fields[0].AsString);
  end else
    MemoLog.Lines.Add('!!!Ekipman Bulunamadý Serino:'+EkipmanSeri);

  if Ilgili <> '' then begin
    Servis.FieldByName('MUS_ILGILI').AsInteger := IDGetir('REHBER',['GRUP','BAGID','FIRMA'],['334',IntToStr(RehberID),Ilgili]);
    if Servis.FieldByName('MUS_ILGILI').AsInteger <= 0 then
      MemoLog.Lines.Add('!!!Müþteri Ýlgili Bulunamadý:'+Ilgili);
  end;

  if Personel <> '' then begin
    Servis.FieldByName('SORUMLU').AsInteger := IDGetir('REHBER',['GRUP','OZELKOD'],['335',Personel]);
    if Servis.FieldByName('SORUMLU').AsInteger <= 0 then
      MemoLog.Lines.Add('!!!Servis Sorumlusu Bulunamadý:'+Personel);
  end;

  Servis.Post;
//servis hareketlerin insert edildiði yer
  if (xml.Root.NamedItem['MissionTimes'].SubItemCount>0)and((xml.Root.NamedItem['MissionTimes'].SubItems[0].Name = 'WorkingTimeProxy')or(xml.Root.NamedItem['MissionTimes'].SubItems[0].Name = 'WorkingTimeDto')) then begin
    for I := 0 to xml.Root.NamedItem['MissionTimes'].SubItemCount-1 do begin
      if (xml.Root.NamedItem['MissionTimes'].SubItems[i].Name = 'WorkingTimeProxy')or(xml.Root.NamedItem['MissionTimes'].SubItems[i].Name = 'WorkingTimeDto') then begin
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Mission'].NamedItem['Technician'].NamedItem['DisplayName'].Text <> '' then
          PersonelID := IDGetir('REHBER',['GRUP','OZELKOD'],['335',xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Mission'].NamedItem['Technician'].NamedItem['DisplayName'].Text])
        else
          PersonelID := IDGetir('REHBER',['GRUP','OZELKOD'],['335',Personel]);
        Aciklama := 'MissionID:'+xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Mission'].NamedItem['Number'].NamedItem['ID'].Text+
                    ' - ID:'+xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Version'].NamedItem['Id'].Text;

        IsGunu :=  TXSDateTime.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Date'].Text <> '' then
          IsGunu.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['Date'].Text);

        YolBaslama := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['StartTravelTime'].Text <> '' then
          YolBaslama.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['StartTravelTime'].Text);

        YolBitis := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['EndTravelTime'].Text <> '' then
          YolBitis.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['EndTravelTime'].Text);

        IsBaslama := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['StartTime'].Text <> '' then
          IsBaslama.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['StartTime'].Text);

        IsBitis := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['EndTime'].Text <> '' then
          IsBitis.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['EndTime'].Text);

        IsMola := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['WorkBreak'].Text <> '' then
          IsMola.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['WorkBreak'].Text);

        YolMola := TXSDuration.Create();
        if xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['TravelBreak'].Text <> '' then
          YolMola.XSToNative(xml.Root.NamedItem['MissionTimes'].SubItems[i].NamedItem['TravelBreak'].Text);

        //Seyahat Baþlama
        ServisHareketSonID := ServisHareketEkle(ServisID,PersonelID,40,ServisHareketYeniID,Aciklama,
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),YolBaslama.Hour),YolBaslama.Minute),
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBaslama.Hour),IsBaslama.Minute));

        //Çalýþma
        ServisHareketSonID := ServisHareketEkle(ServisID,PersonelID,5,ServisHareketSonID,Aciklama,
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBaslama.Hour),IsBaslama.Minute),
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBitis.Hour),IsBitis.Minute));

        //Çalýþma Molasý
        ServisHareketSonID := ServisHareketEkle(ServisID,PersonelID,44,ServisHareketSonID,Aciklama,
                                                ((RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBaslama.Hour),IsBaslama.Minute)+
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBitis.Hour),IsBitis.Minute))/2),
                                                IncMinute(IncHour(((RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBaslama.Hour),IsBaslama.Minute)+
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBitis.Hour),IsBitis.Minute))/2),IsMola.Hour),IsMola.Minute)
                                                );

        //Seyahat Bitiþ
        ServisHareketSonID := ServisHareketEkle(ServisID,PersonelID,42,ServisHareketSonID,Aciklama,
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),IsBitis.Hour),IsBitis.Minute),
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),YolBitis.Hour),YolBitis.Minute));
        //Seyahat Mola
        ServisHareketSonID := ServisHareketEkle(ServisID,PersonelID,46,ServisHareketSonID,Aciklama,
                                                RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),YolBitis.Hour),YolBitis.Minute),
                                                IncMinute(IncHour(RecodeMinute(RecodeHour(DateOf(IsGunu.AsDateTime),YolBitis.Hour),YolBitis.Minute),YolMola.Hour),YolMola.Minute));

        IsGunu.Free;
        YolBaslama.Free;
        YolBitis.Free;
        IsBaslama.Free;
        IsBitis.Free;
        IsMola.Free;
        YolMola.Free;
      end;
    end;
  end;

//servis detaylarýn insert edildiði yer
  //önce problemleri ekleyelim..
  if (xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItemCount>0)and(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[0].Name = 'ActivityProxy') then begin
    for I := 0 to xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItemCount-1 do begin
      ServisBilgi.Append;
      ServisBilgi.FieldByName('SERVISID').AsInteger := ServisID;
      ServisBilgi.FieldByName('SERVISTUR').AsInteger := 210; //özel oluþturulan Malzemeler bölümüne göndereceðiz..
      ServisBilgi.FieldByName('ACIKLAMA').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['Cause'].Text + ' - ' + #13 +
                                                      xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['DamageType'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.FieldByName('COZUM').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['Solution'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.Post;
    end;
  end;
  if (xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItemCount>0)and(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[0].Name = 'ActivityDto') then begin
    for I := 0 to xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItemCount-1 do begin
      ServisBilgi.Append;
      ServisBilgi.FieldByName('SERVISID').AsInteger := ServisID;
      ServisBilgi.FieldByName('SERVISTUR').AsInteger := 210; //özel oluþturulan Malzemeler bölümüne göndereceðiz..
      ServisBilgi.FieldByName('ACIKLAMA').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['Cause'].Text + ' - ' + #13 +
                                                      xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['DamageType'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.FieldByName('COZUM').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['Activities'].SubItems[i].NamedItem['Solution'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.Post;
    end;
  end;

  //malzemeleri ekleyelim..
  if (xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItemCount>0)and(xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[0].Name = 'SparePartProxy') then begin
    for I := 0 to xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItemCount-1 do begin
      ServisBilgi.Append;
      ServisBilgi.FieldByName('SERVISID').AsInteger := ServisID;
      ServisBilgi.FieldByName('SERVISTUR').AsInteger := 250; //özel oluþturulan Malzemeler bölümüne göndereceðiz..
      ServisBilgi.FieldByName('ACIKLAMA').AsString := stringReplace('Miktar:'+xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['Quantity'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.FieldByName('COZUM').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['MaterialNumber'].Text + ' - ' + #13 +
                                                      xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['Description'].Text + ' - ' + #13 +
                                                      'EngineerNumber:'+xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['EngineerNumber'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.Post;
    end;
  end;
  if (xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItemCount>0)and(xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[0].Name = 'SparePartDto') then begin
    for I := 0 to xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItemCount-1 do begin
      ServisBilgi.Append;
      ServisBilgi.FieldByName('SERVISID').AsInteger := ServisID;
      ServisBilgi.FieldByName('SERVISTUR').AsInteger := 250; //özel oluþturulan Malzemeler bölümüne göndereceðiz..
      ServisBilgi.FieldByName('ACIKLAMA').AsString := stringReplace('Miktar:'+xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['Quantity'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.FieldByName('COZUM').AsString := stringReplace(xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['MaterialNumber'].Text + ' - ' + #13 +
                                                      xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['Description'].Text + ' - ' + #13 +
                                                      'EngineerNumber:'+xml.Root.NamedItem['MissionReport'].NamedItem['SpareParts'].SubItems[i].NamedItem['EngineerNumber'].Text,'''','''''',[rfReplaceAll]);
      ServisBilgi.Post;
    end;
  end;
end;

function TTrumpfAktarimDlg.ServisHareketEkle(AServisID,APersonelID,ADurum,AGeriDonusID:integer;AAciklama:string;ABaslama,ABitis:TDateTime):integer;
Begin
  ServisHareket.Append;
  ServisHareket.FieldByName('SERVISID').AsInteger := AServisID;
  ServisHareket.FieldByName('PERSONEL').AsInteger := APersonelID;
  ServisHareket.FieldByName('DURUM').AsInteger := ADurum;
  ServisHareket.FieldByName('GERIDONUSID').AsInteger := AGeriDonusID;
  ServisHareket.FieldByName('ACIKLAMA').AsString := AAciklama;
  ServisHareket.FieldByName('BASLAMA').AsDateTime := ABaslama;
  ServisHareket.FieldByName('BITIS').AsDateTime := ABitis;
  ServisHareket.Post;
  Result := ServisHareket.FieldByName('ID').AsInteger;
End;

function TTrumpfAktarimDlg.AciklamaGetir(TabloAdi, AciklamaAlani: string; Id: Variant; IDAlani: string='ID'):string;
var
  Qry: TADOQuery;
begin
  if VarToStr(Id) <> '' then begin
    Qry := TADOQuery.Create(Nil);
    Qry.Connection := cnn;
    try
      Qry.Close;
      Qry.SQL.Text := 'SELECT ' + AciklamaAlani + ' FROM ' + TabloAdi +
        ' WHERE '+IDAlani+'=' + VarToStr(Id);
      Qry.Open;
      Result := Qry.Fields[0].AsString
    except
      Result := ''
    end;
    FreeAndNil(Qry);
  end else
    Result := ''
end;

function TTrumpfAktarimDlg.IDGetir(TabloAdi: string; AciklamaAlanlari,Aciklamalar: array of string):integer;
var
  Qry: TADOQuery;
  i:integer;
begin
    Qry := TADOQuery.Create(Nil);
    Qry.Connection := cnn;
    try
      Qry.Close;
      Qry.SQL.Text := 'SELECT ID FROM ' + TabloAdi + ' WHERE 1=1 ';
      for i := Low(AciklamaAlanlari) to High(AciklamaAlanlari) do
        Qry.SQL.Add(' and '+ AciklamaAlanlari[i] + '=''' + Aciklamalar[i] + '''');
      Qry.Open;
      Result := Qry.Fields[0].AsInteger
    except
      Result := 0
    end;
    FreeAndNil(Qry);
end;

procedure TTrumpfAktarimDlg.TabloYenile(TabloAdi: TADOQuery; p: array of Variant;LocateID:integer=0; IDTur:String='ID');
var
  i: Byte;
  IDField: TField;
  ID: integer;
  AfterScroll : TDataSetNotifyEvent;
begin
  try
    if TabloAdi.State in [dsEdit,dsInsert] then
      TabloAdi.Post;
  finally
    ID := 0;
    AfterScroll := TabloAdi.AfterScroll;
    TabloAdi.AfterScroll := Nil;
    if TabloAdi.Active then begin
      IDField := TabloAdi.FindField(IdTur);
      if (TabloAdi.RecordCount>0)and(IDField <> nil) then
        ID := IDField.AsInteger;
      TabloAdi.Close;
    end;
    if length(p) > 0 then
      for i := 0 to High(p) do begin
        TabloAdi.Parameters[i].Value := p[i];
      end;
    TabloAdi.Prepared := True;
    TabloAdi.Open;
    if LocateID<>0 then
      TabloAdi.Locate(IdTur,LocateID,[])
    else if (IDField <> nil)and(TabloAdi.RecordCount>0)and(ID>0) then
      TabloAdi.Locate(IdTur,ID,[]);
    if Assigned(AfterScroll) then begin
      TabloAdi.AfterScroll := AfterScroll;
      AfterScroll(TabloAdi);
    end;
  end;
end;

procedure TTrumpfAktarimDlg.KlasorAcClick(Sender: TObject);
Var
  Path    : String;
  SR      : TSearchRec;
  DirList : TStrings;
begin

  if Win32MajorVersion >= 6 then
    with TFileOpenDialog.Create(nil) do
      try
        TFileOpenDialog.Create(nil).FileTypes.Clear;
          with FileTypes.Add do begin
            DisplayName := 'xml file';
            FileMask := '*.xml';
          end;
        DefaultExtension := 'xml';
        Title := 'Dosya Seçimi';
        Options := [fdoPathMustExist, fdoForceFileSystem];
        OkButtonLabel := 'Seç';
        if Execute then
          LblKlasorKonumu.Caption := FileName;
      finally
        Free;
      end
  else
    ShowMessage('Bu iþlem için Windows Vista veya üzeri bir versiyon kullanmanýz gerekmektedir.');

end;

end.
