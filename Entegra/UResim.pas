unit UResim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Vcl.Imaging.pngimage, Vcl.Imaging.GIFImg, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxContainer, cxImage,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls, ToolWin, FireDAC.Comp.Client,
  ExtDlgs, JPeg, Clipbrd, cxCheckBox, Menus, dxSkinLondonLiquidSky,
  JvComponentBase, JvDragDrop, dxSkinBlack, dxSkinBlue, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxDateRanges, dxScrollbarAnnotations ;

type
  TResimDlg = class(TForm)
    ToolBar1: TToolBar;
    YapistirTus: TToolButton;
    SilTus: TToolButton;
    DosyadanTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    GridResim: TcxGrid;
    GridResimView: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    GridFirIlet: TcxGridLevel;
    LogoResim: TcxImage;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    GridResimViewColumn1: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    Varsaylanyap1: TMenuItem;
    JvDragDrop1: TJvDragDrop;
    procedure FormShow(Sender: TObject);
    procedure TabResimAfterScroll(DataSet: TDataSet);
    procedure YapistirTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure DosyadanTusClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure TabResimNewRecord(DataSet: TDataSet);
    procedure LogoResimClick(Sender: TObject);
    procedure TabResimAfterOpen(DataSet: TDataSet);
    procedure TabResimBeforeOpen(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
    procedure FormCreate(Sender: TObject);
    procedure Varsaylanyap1Click(Sender: TObject);
    procedure ToolBar1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Yeri : SmallInt;
    RehberId, YerId : Integer;
    EkleSil : Boolean;
  end;

var
  ResimDlg: TResimDlg;
//yer=1 dokuman belge
///yer = 11 : firma logo/Resim;
// 12:personel resim
// 13:profil resim
//21 Çek Resim  25:senet Resim
//31 fatura Resim
//41 Proje Belge
//51 Aktivite Belge
//61 Görev Belge
//65 Masraf Gelir Resim
//88 Stok Resim
//72 Stok Belge
//81 Teklif Belge
//85 Demirbaş Resim
//86 Demirbaş Belge
//90 Servis
//100 Banka-Teminat Mektubu Belge
//121 Genini Mekan Zemin resim

procedure ResimGetir(RehberId,Yer,YerId:Integer; Rsm:TcxImage);
procedure XTablosunaResimKaydet(Yeri, ID: Integer; Pic : TJPEGImage);
procedure ResimEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer);
procedure ResimYapistir(Rs:TcxImage; RehberId, Yeri, Yer_ID: Integer);
procedure ResmiVarsayilanyap(TabRsm:TFDQuery; Yeri, Yer_ID: Integer);
procedure ImajTablosunaResimKaydet(DosyaAdi: string; Rsm:TcxImage; RehberId, Yeri, Yer_ID: Integer);

implementation

{$R *.dfm}
uses Utablo,PrjConst, FetaKurulusSiniflari, Fetautil, UBinarySave,LocOnFly, ULog;


procedure ResimGetir(RehberId, Yer, YerId:Integer; Rsm:TcxImage);
var Pic : TJpegImage;
begin
   Tablo.TablodanSorguAc(1, ' select BELGE, DOSYAID from IMAJ where REHBERID='+IntToStr(RehberId)+' and YERI='+IntToStr(Yer)+' and YER_ID='+IntToStr(YerId)+' and VARSAYILAN = 1');
   if Tablo.Query1.RecordCount=0 then
      Rsm.Picture.Graphic:= nil
   else begin
      Pic := TJpegImage.Create;
      try
         if Tablo.Query1.FieldByName('DOSYAID').AsLargeInt > 0 then
         begin // YENI: icerik DOSYA deposunda (FILESTREAM); eski davranis: IMAJ.BELGE
            Tablo.TablodanSorguAc(0, 'select ICERIK from '+DepoTablo('DOSYA')+' where ID='+Tablo.Query1.FieldByName('DOSYAID').AsString);
            if (Tablo.Query0.RecordCount>0) and (not Tablo.Query0.FieldByName('ICERIK').IsNull) then
               Pic.LoadFromStream(Tablo.Query0.CreateBlobStream(Tablo.Query0.FieldByName('ICERIK'),bmread));
         end
         else
            Pic.LoadFromStream(Tablo.Query1.CreateBlobStream(Tablo.Query1.FieldByName('BELGE'),bmread));
         Rsm.Picture.Graphic := Pic;
      finally
         Pic.Free;
      end;
   end;
end;

procedure XTablosunaResimKaydet(Yeri, ID:Integer; Pic : TJPEGImage);
var X : string[20];
begin
   //Varsayılan resim küçültülmüş olarak stok tablosunda tutulur. Satış ekranında kullanılır
   case Yeri of
    18 : X := 'DEMIRBAS';
    58 : X := 'MASRAFGELIR';
    71 : X := 'REHBER';
    88 : X := 'STOKLAR';
   end;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := ' update '+X+' set RESIM= :PR0 where  ID='+IntToStr(ID);
   JPGKucult(Pic,128);
   Tablo.Query1.ParamByName('PR0').Assign(Pic);
   Tablo.Query1.ExecSQL;
end;

function BMPtoJPG
  (var BMPpic, JPGpic: string):boolean;
var Bitmap: TBitmap;
   JpegImg: TJpegImage;
begin
  Result:=False;
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromFile(BMPpic) ;
    JpegImg := TJpegImage.Create;
    try
      JpegImg.Assign(Bitmap) ;
      JpegImg.SaveToFile(JPGpic) ;
      Result:=True;
    finally
      JpegImg.Free
    end;
  finally
    Bitmap.Free
  end;
end;

procedure DetectImage(const InputFileName: string; BM: TBitmap);
var
  FS: TFileStream;
  FirstBytes: AnsiString;
  Graphic: TGraphic;
begin
  Graphic := nil;
  FS := TFileStream.Create(InputFileName, fmOpenRead);
  try
    SetLength(FirstBytes, 8);
    FS.Read(FirstBytes[1], 8);
    if Copy(FirstBytes, 1, 2) = 'BM' then
    begin
      Graphic := TBitmap.Create;
    end else
    if FirstBytes = #137'PNG'#13#10#26#10 then
    begin
      Graphic := TPngImage.Create;
    end else
    if Copy(FirstBytes, 1, 3) =  'GIF' then
    begin
      Graphic := TGIFImage.Create;
    end else
    if Copy(FirstBytes, 1, 2) = #$FF#$D8 then
    begin
      Graphic := TJPEGImage.Create;
    end;
    if Assigned(Graphic) then
    begin
      try
        FS.Seek(0, soFromBeginning);
        Graphic.LoadFromStream(FS);
        BM.Assign(Graphic);
      except
      end;
      Graphic.Free;
    end;
  finally
    FS.Free;
  end;
end;

procedure ImajTablosunaResimKaydet(DosyaAdi: string; Rsm:TcxImage; RehberId, Yeri, Yer_ID: Integer);
var
  Pic : TJpegImage;
  bmp: TBitmap;
  LMs: TMemoryStream;
  LDosyaID: Int64;
  LBoyutKB: Integer;
begin
  Pic := TJpegImage.Create;
  try
    if DosyaAdi = '' then //yapıştırma
       Pic.Assign(Rsm.Picture.Bitmap)
    else begin
      bmp := TBitmap.Create;
      try
        DetectImage(DosyaAdi,bmp);
        Pic.Assign(bmp);
      finally
        bmp.Free;
      end;
    end;

    // YENI: JPEG'i DOSYA deposuna (ham, hash-dedup) kaydet. Basarili ise IMAJ.BELGE'ye YAZMA.
    LDosyaID := 0; LBoyutKB := 0;
    LMs := TMemoryStream.Create;
    try
      Pic.SaveToStream(LMs);
      LBoyutKB := (LMs.Size + 1023) div 1024;   // IMAJ.BOYUT = KB
      LMs.Position := 0;
      LDosyaID := ULog.DosyaKaydet(LMs, '.jpg', 'image/jpeg');
    finally
      LMs.Free;
    end;

    Tablo.Query1.Close;
    if LDosyaID > 0 then
      // YENI: icerik DOSYA deposunda; IMAJ sadece referans (BELGE bos).
      Tablo.Query1.SQL.Text := ' insert into IMAJ (REHBERID,ICDIS,YERI,YER_ID,BELGEADI,DOSYAID,BOYUT,VARSAYILAN,EKLEYEN,SUBEID) values('+
        IntToStr(RehberId)+',0,'+IntToStr(Yeri)+','+IntToStr(Yer_ID)+',''Resim.jpg'','+IntToStr(LDosyaID)+','+IntToStr(LBoyutKB)+',1,'''+Kullanan+''','+IntToStr(SubeId)+') select scope_identity()'
    else begin
      // FALLBACK (DOSYA yok/hata): eski davranis - IMAJ.BELGE inline.
      Tablo.Query1.SQL.Text := ' insert into IMAJ (REHBERID,ICDIS,YERI,YER_ID,BELGEADI,BELGE,VARSAYILAN,EKLEYEN,SUBEID)values('+IntToStr(RehberId)+','+ IntToStr(Dokuman_Kayit_Yeri) + ','+IntToStr(Yeri)+','+IntToStr(Yer_ID)+
            ',''Resim.jpg'',:Prm1,1,'''+Kullanan+''','+IntToStr(SubeId)+') select scope_identity()';
      Tablo.Query1.ParamByName('Prm1').Assign(Pic);
    end;
    Tablo.Query1.Open;
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update IMAJ set VARSAYILAN=0 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID)+' and ID<>&YeniId',['&YeniId'],[Tablo.Query1.Fields[0].AsInteger]);

    if Yeri in [18, 58, 71, 88] then   //Demirbaş, masraf,Rehber, stoksa
       XTablosunaResimKaydet(Yeri, Yer_ID, Pic);
  finally
    Pic.Free;
  end;
end;


procedure ResimEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer);
begin
    ImajTablosunaResimKaydet(DosyaAdi,nil, RehberId, Yeri, Yer_ID);
end;

procedure ResimYapistir(Rs:TcxImage; RehberId, Yeri, Yer_ID: Integer);
var Pic : TJpegImage;
    s : string[1];
begin
   if Clipboard.HasFormat(CF_PICTURE) then  begin
      Rs.Picture.Bitmap.LoadFromClipboardFormat(cf_BitMap, ClipBoard.GetAsHandle(cf_Bitmap), 0);
      ImajTablosunaResimKaydet('',Rs, RehberId, Yeri, Yer_ID);
   end;
end;

procedure ResmiVarsayilanyap(TabRsm:TFDQuery; Yeri, Yer_ID: Integer);
var Pic : TJPEGImage;
    LMs : TMemoryStream;
begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' update IMAJ set VARSAYILAN=0 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID)+' and VARSAYILAN=1';
      Tablo.Query1.ExecSQL;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' update IMAJ set VARSAYILAN=1 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID)+' and ID='+TabRsm.FieldByName('ID').AsString;
      Tablo.Query1.ExecSQL;
      //IMAJ tablosunda varsayılan olarak işaretlendi. Şimdi de bu resmi stok tablosuna kaydedelim
      if Yeri in [18, 58, 71, 88]  then begin
         Pic := TJpegImage.Create;
         try
            if TabRsm.FieldByName('DOSYAID').AsLargeInt > 0 then
            begin // YENI: icerik DOSYA deposunda
               LMs := TMemoryStream.Create;
               try
                  if ULog.DosyaGetir(TabRsm.FieldByName('DOSYAID').AsLargeInt, LMs) and (LMs.Size > 0) then
                  begin
                     LMs.Position := 0;
                     Pic.LoadFromStream(LMs);
                     XTablosunaResimKaydet(Yeri, Yer_ID, Pic);
                  end;
               finally
                  LMs.Free;
               end;
            end
            else if not TabRsm.FieldByName('BELGE').IsNull then
            begin
               Pic.Assign(TabRsm.FieldByName('BELGE'));
               XTablosunaResimKaydet(Yeri, Yer_ID, Pic);
            end;
         finally
            Pic.Free;
         end;
      end;
end;

procedure TResimDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;
procedure TResimDlg.YapistirTusClick(Sender: TObject);
begin
   ResimYapistir(LogoResim,RehberId , Yeri, YerId);
   TabloYenile(TabResim,[]);
   TabResim.Last;
end;

procedure TResimDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//     veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update IMAJ set BELGE = null where ICDIS=1 and VARSAYILAN=0 and YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(YerId), [], []);
end;

procedure TResimDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   Tablo.GridTurkcelestir;
end;

procedure TResimDlg.FormShow(Sender: TObject);
begin
   YapistirTus.visible := EkleSil;
   DosyadanTus.visible := EkleSil;
   SilTus.visible := EkleSil;
   if not EkleSil then
      LogoResim.properties.popupMenuLayout.menuItems := [];
   TabloYenile(TabResim,[Yeri,YerId]);
end;

procedure TResimDlg.JvDragDrop1Drop(Sender: TObject; Pos: TPoint; Value: TStrings);
var
   j: SmallInt;
begin
   for j := 0 to Value.Count - 1 do
       ResimEkleme(Value.Strings[j], RehberId , Yeri, YerId);
   TabloYenile(TabResim, []);
end;

procedure TResimDlg.DosyadanTusClick(Sender: TObject);
var
   i : SmallInt;
begin
   if Tablo.OpenPictureDialog1.Execute then begin
      for i := 0 to Tablo.OpenPictureDialog1.Files.Count-1 do
          ResimEkleme(Tablo.OpenPictureDialog1.Files[i], RehberId , Yeri, YerId);
      TabloYenile(TabResim, []);
   end;
end;

procedure TResimDlg.KaydetTusClick(Sender: TObject);
begin
   TabResim.Post;
end;

procedure TResimDlg.LogoResimClick(Sender: TObject);
begin
   if TabResim.Eof then
      TabResim.First
   else
      TabResim.Next
end;

procedure TResimDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      TabResim.Delete;
      if TabResim.RecordCount > 0 then
         Varsaylanyap1Click(Self)
      else
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKLAR set RESIM=null where ID='+IntToStr(YerId),[],[]);
   end;
end;

procedure TResimDlg.TabResimAfterOpen(DataSet: TDataSet);
begin
   SilTus.Visible :=(EkleSil)and(TabResim.RecordCount > 0);
end;

procedure TResimDlg.TabResimAfterScroll(DataSet: TDataSet);
var Pic : TJpegImage;
    LMs : TMemoryStream;
begin
   if TabResim.RecordCount=0 then
      LogoResim.Picture.Graphic:= nil
   else begin
      Pic := TJpegImage.Create;
      try
         if TabResim.FieldByName('DOSYAID').AsLargeInt > 0 then
         begin // YENI: icerik DOSYA deposunda (FILESTREAM)
            LMs := TMemoryStream.Create;
            try
               if ULog.DosyaGetir(TabResim.FieldByName('DOSYAID').AsLargeInt, LMs) and (LMs.Size > 0) then
               begin
                  LMs.Position := 0;
                  Pic.LoadFromStream(LMs);
                  LogoResim.Picture.Graphic := Pic;
               end
               else
                  LogoResim.Picture.Graphic := nil;
            finally
               LMs.Free;
            end;
         end
         else if not TabResim.FieldByName('BELGE').IsNull then
         begin
            Pic.LoadFromStream(TabResim.CreateBlobStream(TabResim.FieldByName('BELGE'),bmread));
            LogoResim.Picture.Graphic := Pic;
         end
         else
            LogoResim.Picture.Graphic := nil;
      finally
         Pic.Free;
      end;
   end;
end;

procedure TResimDlg.TabResimBeforeOpen(DataSet: TDataSet);
begin //eğer resimler dizine kayıt yapılıyorsa önce dizinden tabloya almak gerekir.
    // DOSYA deposundaki satirlar (DOSYAID>0) klasorden OKUNMAZ (icerik DOSYA'da, .OBJ yok)
    //  -> haric tut; yoksa null BELGE'de eski folder-load fn'i cagrilir ('dbo.' syntax hatasi).
    Tablo.TablodanSorguAc(1, '  select ID, cast(BELGE as binary(1)) from IMAJ where (DOSYAID is null or DOSYAID=0) and YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(YerId));
    while not Tablo.Query1.eof do begin
       if Tablo.Query1.Fields[1].isnull then //eğer dosyada tutuluyorsa
          veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' dbo.fn_Imaj_KayitliObjNesnesiniOku ' + Tablo.Query1.Fields[0].AsString, [],[]);
       Tablo.Query1.next;
    end;
end;

procedure TResimDlg.TabResimNewRecord(DataSet: TDataSet);
begin
   TabResim.FieldByName('YERI').AsInteger := Yeri;
   TabResim.FieldByName('YER_ID').AsInteger := YerId;
   TabResim.FieldByName('SUBEID').AsInteger := SubeID;
end;

procedure TResimDlg.ToolBar1DblClick(Sender: TObject);
var Pic : TJpegImage;
begin
   Pic := TJpegImage.Create;
   Tablo.TablodanSorguAc(0, 'SELECT * FROM IMAJ WHERE YERI = 71 AND VARSAYILAN=1 ORDER BY ID DESC ');
   while not Tablo.Query0.eof do begin

      Pic.LoadFromStream(Tablo.Query0.CreateBlobStream(Tablo.Query0.FieldByName('BELGE'),bmread));
      //Rsm.Picture.Graphic := Pic;

      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' update REHBER set RESIM= :PR0 where  ID='+Tablo.query0.fieldbyname('YER_ID').asstring;
      JPGKucult(Pic,128);
      Tablo.Query1.ParamByName('PR0').Assign(Pic);
      Tablo.Query1.ExecSQL;
      Tablo.Query0.next;
   end;
   Pic.Free;
   showmessage('Tamamlandı');
end;

procedure TResimDlg.Varsaylanyap1Click(Sender: TObject);
begin
   ResmiVarsayilanyap(TabResim, Yeri, YerId);
   TabloYenile(TabResim, []);
end;

end.





