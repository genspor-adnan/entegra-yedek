unit Aktarim;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB,OleCtnrs, StdCtrls,Registry, cxControls, cxContainer,
  cxEdit, cxProgressBar, cxShellBrowserDialog, cxTextEdit, cxLabel,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,Winapi.ShellAPI,
  dxSkinsDefaultPainters,UGenSifre, Vcl.ComCtrls, dxCore, cxDateUtils,
  cxMaskEdit, cxDropDownEdit, cxCalendar, Vcl.Samples.Spin, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.ExtDlgs, IOUtils, JPEG, PNGImage,  cximage,//GIFImage,
  fetakurulussiniflari, fetaclassextensions, dxSkinBasic,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinOffice2019Black,
  dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray, dxSkinOffice2019White,
  dxSkinTheBezier, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxGroupBox, cxRadioGroup;

type
  TAnaform = class(TForm)
    cnn: TADOConnection;
    BaslatButton: TButton;
    cxProgressBar1: TcxProgressBar;
    KlasorAc: TButton;
    SonlandirButton: TButton;
    LblKlasorKonumu: TLabel;
    TabStoklar: TADOQuery;
    Query1: TADOQuery;
    MemoLog: TMemo;
    CheckSil: TCheckBox;
    CheckVarsayilan: TCheckBox;
    GroupEslesme: TcxRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure SonlandirButtonClick(Sender: TObject);
    procedure KlasorAcClick(Sender: TObject);
    procedure BaslatButtonClick(Sender: TObject);
    procedure XTablosunaResimKaydet(Yeri, ID:Integer; Pic : TJPEGImage);
    function JPGKucult(var oJPG: TJpegImage; Pixel:integer): integer;
    procedure ImajTablosunaResimKaydet(DosyaAdi: string; Rsm:TcxImage; RehberId, Yeri, Yer_ID: Integer);
    procedure ResimEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer);
    procedure DetectImage(const InputFileName: string; BM: TBitmap);
    function BMPtoJPG(var BMPpic, JPGpic: string):boolean;
    function ResizeJPG(var oJPG: TJpegImage; Percent, Quality: integer): integer;
    procedure FormShow(Sender: TObject);
    procedure CheckSilClick(Sender: TObject);

  private


    { Private declarations }
  public
    { Public declarations }
  end;


var
  Anaform: TAnaform;
  SystemIni: TRegistry;
  Subeid, Dokuman_Kayit_Yeri : integer;
  Kullanan : string;


implementation


{$R *.dfm}

procedure TAnaform.BaslatButtonClick(Sender: TObject);
var
  LstAdres,LstKod : TStringList;
  SR: TSearchRec;
  i,StokID: integer;
  Secim : string;
begin
  MemoLog.Lines.Clear;
  if LblKlasorKonumu.Caption = 'Klasör Konumu' then
    Exit;
  ///////////////////////////////////
  if GroupEslesme.ItemIndex=1 then
     Secim := 'URUNNO'
  else
     Secim := 'KOD';
  ///
  MemoLog.Lines.Add('Listeler Oluþturuluyor..');
  LstAdres := TStringList.Create();
  LstKod := TStringList.Create();
  TabStoklar.Open;
  if FindFirst(LblKlasorKonumu.Caption+'*.*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr <> faDirectory)and(SR.Name<>'.')and(SR.Name<>'..') then begin
        LstAdres.Add(LblKlasorKonumu.Caption+SR.Name);
        LstKod.Add(ChangeFileExt(SR.Name,''));
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  ///////////////////////////////////
  for i := 0 to LstAdres.Count - 1 do begin
    StokID := 0;
    TabStoklar.First;
    cxProgressBar1.Position := 100.0*(i/LstAdres.Count);
    cxProgressBar1.Update();
    //MemoLog.Lines.Add(LstAdres.Strings[i]+' için iþlem yapýlýyor..');
    //MemoLog.Update();
    try
      if TabStoklar.locate(Secim,LstKod[i],[loCaseInsensitive]) then begin
        StokID := TabStoklar.FieldByName('ID').AsInteger;
        MemoLog.Lines.Add(LstAdres.Strings[i]+' için stok kartý bulundu. ID:'+IntToStr(StokID));
      end else
        MemoLog.Lines.Add(LstAdres.Strings[i]+' için stok kartý bulunamadý!!');
    except
      MemoLog.Lines.Add(LstAdres.Strings[i]+' için beklenmedik bir hata oluþtu!!');
    end;
    if StokID>0 then begin
      try
        ImajTablosunaResimKaydet( LstAdres[i] , nil , 0, 88, StokID);
      except
        Exit;
      end;

      //MemoLog.Lines.Add(LstAdres.Strings[i]+' için resim eklendi.');
    end;

  end;
  cxProgressBar1.Position := 100.0;
  //MemoLog.Lines.Add('Ýþlem Tamamlandý.');
  //ShowMessage(Lst.Text);
  LstKod.Free;
  LstAdres.Free;
end;

procedure TAnaform.FormCreate(Sender: TObject);
var
  s:string;
begin
  SystemIni:=TRegistry.Create;
  SystemIni.RootKey := HKEY_CURRENT_USER;
  SystemIni.OpenKey('SOFTWARE\GENTEGRE2\',True);
  cnn.ConnectionString := DeSifre(SystemIni.ReadString('ConnectionString'));
  cnn.Connected := True;
end;


procedure TAnaform.FormShow(Sender: TObject);
begin

  Query1.Close;
  Query1.SQL.Text := 'select isnull((select isnull(DEGER,0) from GENINI where BOLUM=-10017),0)';
  Query1.Open;
  Dokuman_Kayit_Yeri := Query1.Fields[0].AsInteger;
                        //Veritabani.BasitKomutÇalýþtýr(cnn,'select isnull((select isnull(DEGER,0) from GENINI where BOLUM=-10017),0)',[],[],True);
                        //GENINI.ReadInteger(-10017,1) ; //  Doküman Kayit_Yeri', 0);
  Subeid := -1;
  Kullanan := '0';
end;

procedure TAnaform.KlasorAcClick(Sender: TObject);
Var
  Path    : String;
  SR      : TSearchRec;
  DirList : TStrings;
begin

  if Win32MajorVersion >= 6 then
    with TFileOpenDialog.Create(nil) do
      try
        Title := 'Klasör Seçimi';
        Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
        OkButtonLabel := 'Seç';

        if Execute then
          LblKlasorKonumu.Caption := FileName + '\';
      finally
        Free;
      end
  else
    ShowMessage('Bu iþlem için Windows Vista veya üzeri bir versiyon kullanmanýz gerekmektedir.');
end;

procedure TAnaform.SonlandirButtonClick(Sender: TObject);
begin
  Application.ProcessMessages;
  //Sonlandir := True;
  SonlandirButton.Enabled := False;
  BaslatButton.Enabled := True;
  Application.ProcessMessages;

end;

procedure TAnaform.XTablosunaResimKaydet(Yeri, ID:Integer; Pic : TJPEGImage);
var X : string[20];
begin
   //Varsayýlan resim küçültülmüþ olarak stok tablosunda tutulur. Satýþ ekranýnda kullanýlýr
   case Yeri of
    18 : X := 'DEMIRBAS';
    58 : X := 'MASRAFGELIR';
    71 : X := 'REHBER';
    88 : X := 'STOKLAR';
   end;
   Query1.Close;
   Query1.SQL.Text := ' update '+X+' set RESIM= :PR0 where  ID='+IntToStr(ID);
   JPGKucult(Pic,128);
   Query1.Parameters[0].Assign(Pic);
   Query1.ExecSQL;
end;

procedure TAnaform.ImajTablosunaResimKaydet(DosyaAdi: string; Rsm:TcxImage; RehberId, Yeri, Yer_ID: Integer);
var
  Pic : TJpegImage;
  bmp: TBitmap;
begin
  Pic := TJpegImage.Create;
  bmp := TBitmap.Create;
  DetectImage(DosyaAdi,bmp);
  Pic.Assign(bmp);
  Query1.Close;
  if CheckSil.Checked then begin
    Query1.Close;
    Query1.SQL.Text := ' delete from IMAJ where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID);
    Query1.ExecSQL;
  end else if CheckVarsayilan.Checked then begin
    Query1.Close;
    Query1.SQL.Text := ' update IMAJ set VARSAYILAN=0 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID)+' and VARSAYILAN=1';
    Query1.ExecSQL;
  end;
  Query1.SQL.Text := ' insert into IMAJ (REHBERID,ICDIS,YERI,YER_ID,BELGEADI,BELGE,VARSAYILAN,EKLEYEN,SUBEID)values('+IntToStr(RehberId)+','+ IntToStr(Dokuman_Kayit_Yeri) + ','+IntToStr(Yeri)+','+IntToStr(Yer_ID)+
          ',''Resim.jpg'',:Prm1,'+IIF(CheckVarsayilan.Checked,'1','0')+','''+Kullanan+''','+IntToStr(SubeId)+') select scope_identity()';

  try
    Query1.Parameters[0].Assign(Pic);
    Query1.Open;
  except
    exit;
  end;
    Veritabani.BasitKomutÇalýþtýr(cnn,'update IMAJ set VARSAYILAN=0 where YERI='+IntToStr(Yeri)+' and YER_ID='+IntToStr(Yer_ID)+' and ID<>&YeniId',['&YeniId'],[Query1.Fields[0].AsInteger]);

//  KutugeYaz(Tablo.Query1, DosyaAdi);

  if Yeri in [18, 58, 71, 88] then   //Demirbaþ, masraf,Rehber, stoksa
     XTablosunaResimKaydet(Yeri, Yer_ID, Pic);
  Pic.Free;
  bmp.Free;
end;

procedure TAnaform.ResimEkleme(DosyaAdi: string; RehberId, Yeri, Yer_ID: Integer);
begin
    ImajTablosunaResimKaydet(DosyaAdi,nil, RehberId, Yeri, Yer_ID);
end;

procedure TAnaform.DetectImage(const InputFileName: string; BM: TBitmap);
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
    //if Copy(FirstBytes, 1, 3) =  'GIF' then
   // begin
   //   Graphic := TGIFImage.Create;
  //  end else
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
      finally
        Graphic.Free;
      end;
    end;
  finally
    FS.Free;
  end;
end;

function TAnaform.BMPtoJPG(var BMPpic, JPGpic: string):boolean;
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

procedure TAnaform.CheckSilClick(Sender: TObject);
begin
  if CheckSil.Checked then
    CheckVarsayilan.Checked := True;
end;

function TAnaform.ResizeJPG(var oJPG: TJpegImage; Percent, Quality: integer): integer;
var
  oBmp: Graphics.TBitmap;
  Size : Integer;
begin
  oBmp:=Graphics.TBitmap.Create;
  oBmp.Width:=Round(oJPG.Width*Percent/100);
  oBmp.Height:=Round(oJPG.Height*Percent/100);
  oBmp.Canvas.StretchDraw(Rect(0,0,oBmp.Width-1,oBmp.Height-1),oJPG);
  Size := Round((oBmp.Width * oBmp.Height)/1024);
  oJPG.Assign(oBmp);
  //oJPG.CompressionQuality:=Quality;
  //oJPG.Compress;
  oBmp.Free;
  result := Size;
end;

function TAnaform.JPGKucult(var oJPG: TJpegImage; Pixel:integer): integer;
var
  Size, Percent: Integer;
begin
  if (oJPG.Width<=Pixel)and(oJPG.Height<=Pixel) then
      Exit;
  if oJPG.Width > oJPG.Height then
     Size := oJPG.Width
  else
     Size := oJPG.Height;

  Percent := Round(Pixel*100 / Size);
  result := ResizeJPG(oJPG,Percent,0);
end;


end.
