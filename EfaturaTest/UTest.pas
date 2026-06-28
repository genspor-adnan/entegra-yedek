unit UTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, dxSkinBasic, dxSkinOffice2019Black, dxSkinOffice2019Colorful,
  dxSkinOffice2019DarkGray, dxSkinOffice2019White, dxSkinTheBezier, dxSkinWXI,
  cxMemo;

type
  TTablo = class(TForm)
    cxTextEdit1: TcxTextEdit;
    cxButton1: TcxButton;
    cxComboBox1: TcxComboBox;
    Ent_Sifre1: TcxTextEdit;
    Ent_Kullanici1: TcxTextEdit;
    Ent_Addr1: TcxTextEdit;
    aliasfatura: TcxMemo;
    aliasirsaliye: TcxMemo;
    bilgiler: TcxMemo;
    MemoBilgi: TcxMemo;
    procedure cxButton1Click(Sender: TObject);
  private
    { Private declarations }
    function EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string):smallint;
    function IzibizTokenAl(out AToken, AHata: string): Boolean;
    procedure NaceBilgiGetir(const AVergiNo: string);
  public
    { Public declarations }
  end;

var
  Tablo: TTablo;
  EFaturaKullanimda : Smallint;
  Ent_Kullanici, Ent_Sifre, Ent_Addr : String;
implementation

{$R *.dfm}

uses Gentegre.UI.EFatura.FirmaAra, EFaturaOIB,
  System.NetEncoding, System.JSON, System.Net.HttpClient, System.Net.URLClient;

const
  // İzibiz REST tabani — uretim. Test icin: 'https://apidev.izibiz.com.tr'
  IZIBIZ_REST_BASE = 'https://api.izibiz.com.tr';

procedure TTablo.cxButton1Click(Sender: TObject);
var
  FirmaAra: TEFaturaFirmaAra;
  Firmalar: CheckUserResponse;
  FaturaAliaslari, IrsaliyeAliaslari: TStringList;
  VergiNo, Alias: string;
  I: Integer;
begin
  aliasfatura.Clear;
  aliasirsaliye.Clear;
  bilgiler.Clear;

  VergiNo := StringReplace(Trim(cxTextEdit1.Text), ' ', '', [rfReplaceAll]);
  if not (Length(VergiNo) in [10, 11]) then begin
    ShowMessage('Ge�erli bir vergi veya T.C. kimlik numaras� giriniz.');
    Exit;
  end;

  Ent_Kullanici := Ent_Kullanici1.Text;
  Ent_Sifre := Ent_Sifre1.Text;
  Ent_Addr := Ent_Addr1.Text;
  FAddr := Ent_Addr;
  SetLength(Firmalar, 0);

  try
    FirmaAra := TEFaturaFirmaAra.Create(nil);
    try
      FirmaAra.KullaniciAdi := Ent_Kullanici;
      FirmaAra.Sifre := Ent_Sifre;
      FaturaAliaslari := TStringList.Create;
      IrsaliyeAliaslari := TStringList.Create;
      try
        FaturaAliaslari.Sorted := True;
        FaturaAliaslari.Duplicates := dupIgnore;
        IrsaliyeAliaslari.Sorted := True;
        IrsaliyeAliaslari.Duplicates := dupIgnore;

        Firmalar := FirmaAra.FirmaBul(VergiNo);
        bilgiler.Lines.BeginUpdate;
        try
          bilgiler.Lines.Add('Bulunan kay�t say�s�: ' + IntToStr(Length(Firmalar)));
          for I := 0 to Length(Firmalar) - 1 do begin
            Alias := Trim(Firmalar[I].ALIAS);
            if Pos('IRSALIYE', UpperCase(Alias)) > 0 then begin
              IrsaliyeAliaslari.Add(Alias);
              bilgiler.Lines.Add('Belge t�r�: E-�rsaliye');
            end else begin
              if Alias <> '' then
                FaturaAliaslari.Add(Alias);
              bilgiler.Lines.Add('Belge t�r�: E-Fatura');
            end;

            bilgiler.Lines.Add('Vergi/T.C. no: ' + Firmalar[I].IDENTIFIER);
            bilgiler.Lines.Add('Unvan: ' + Firmalar[I].TITLE);
            bilgiler.Lines.Add('Alias: ' + Firmalar[I].ALIAS);
            bilgiler.Lines.Add('T�r: ' + Firmalar[I].TYPE_);
            bilgiler.Lines.Add('Birim: ' + Firmalar[I].UNIT_);
            bilgiler.Lines.Add('Kay�t tarihi: ' + Firmalar[I].REGISTER_TIME);
            if I < Length(Firmalar) - 1 then
              bilgiler.Lines.Add('----------------------------------------');
          end;
        finally
          bilgiler.Lines.EndUpdate;
        end;

        aliasfatura.Lines.Assign(FaturaAliaslari);
        aliasirsaliye.Lines.Assign(IrsaliyeAliaslari);
      finally
        FirmaAra.FirmalariTemizle(Firmalar);
        IrsaliyeAliaslari.Free;
        FaturaAliaslari.Free;
      end;
    finally
      FirmaAra.Free;
    end;
  except
    on E: Exception do
      ShowMessage('�zibiz firma alias sorgusu ba�ar�s�z: ' + E.Message);
  end;

  // NACE / Mukellef detay (faaliyet kodlari dahil) -> MemoBilgi
  NaceBilgiGetir(VergiNo);
end;

// İzibiz REST accessToken'i alir. Token endpoint formati kesin olmadigindan
// birkac varyant denenir (form-encoded / Basic / JSON; /auth/token + /auth/login).
function TTablo.IzibizTokenAl(out AToken, AHata: string): Boolean;

  function _ParseToken(const S: string): string;
  var
    JV, TV, DV: TJSONValue;
    function _Ara(AO: TJSONObject): TJSONValue;
    begin
      Result := AO.GetValue('accessToken');
      if Result = nil then Result := AO.GetValue('access_token');
      if Result = nil then Result := AO.GetValue('token');
    end;
  begin
    Result := '';
    JV := TJSONObject.ParseJSONValue(S);
    if not (JV is TJSONObject) then begin
      if JV <> nil then JV.Free;
      Exit;
    end;
    try
      TV := _Ara(TJSONObject(JV));
      if TV = nil then begin
        DV := TJSONObject(JV).GetValue('data');
        if DV is TJSONObject then TV := _Ara(TJSONObject(DV));
      end;
      if TV <> nil then Result := TV.Value;
    finally
      JV.Free;
    end;
  end;

var
  LClient: THTTPClient;
  LStream: TStringStream;
  LResp: IHTTPResponse;
  LStr, LBasic, LBody, LUrl: string;
  i: Integer;
begin
  Result := False;
  AToken := '';
  AHata := '';
  LBasic := StringReplace(
    TNetEncoding.Base64.Encode(Ent_Kullanici + ':' + Ent_Sifre),
    sLineBreak, '', [rfReplaceAll]);

  for i := 1 to 4 do begin
    LClient := THTTPClient.Create;
    try
      LClient.Accept := 'application/json';
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 60000;
      case i of
        1: begin   // form-encoded, /auth/token
          LUrl := IZIBIZ_REST_BASE + '/v1/auth/token';
          LClient.ContentType := 'application/x-www-form-urlencoded';
          LBody := 'grant_type=password&username=' +
            TNetEncoding.URL.Encode(Ent_Kullanici) + '&password=' +
            TNetEncoding.URL.Encode(Ent_Sifre);
        end;
        2: begin   // form-encoded + Basic auth, /auth/token
          LUrl := IZIBIZ_REST_BASE + '/v1/auth/token';
          LClient.ContentType := 'application/x-www-form-urlencoded';
          LClient.CustomHeaders['Authorization'] := 'Basic ' + LBasic;
          LBody := 'grant_type=password&username=' +
            TNetEncoding.URL.Encode(Ent_Kullanici) + '&password=' +
            TNetEncoding.URL.Encode(Ent_Sifre);
        end;
        3: begin   // JSON body, /auth/token
          LUrl := IZIBIZ_REST_BASE + '/v1/auth/token';
          LClient.ContentType := 'application/json; charset=UTF-8';
          LBody := Format('{"username":"%s","password":"%s"}',
            [Ent_Kullanici, Ent_Sifre]);
        end;
        4: begin   // JSON body, /auth/login (dokumante edilen)
          LUrl := IZIBIZ_REST_BASE + '/v1/auth/login';
          LClient.ContentType := 'application/json; charset=UTF-8';
          LBody := Format('{"username":"%s","password":"%s"}',
            [Ent_Kullanici, Ent_Sifre]);
        end;
      end;

      LStream := TStringStream.Create(LBody, TEncoding.UTF8);
      try
        try
          LResp := LClient.Post(LUrl, LStream);
          LStr := LResp.ContentAsString(TEncoding.UTF8);
          if (LResp.StatusCode >= 200) and (LResp.StatusCode < 300) then begin
            AToken := _ParseToken(LStr);
            if Trim(AToken) <> '' then Exit(True);
          end;
          AHata := Format('HTTP %d (%s): %s',
            [LResp.StatusCode, LUrl, Copy(LStr, 1, 300)]);
        except
          on E: Exception do
            AHata := LUrl + ' -> ' + E.Message;
        end;
      finally
        LStream.Free;
      end;
    finally
      LClient.Free;
    end;
  end;
end;

procedure TTablo.NaceBilgiGetir(const AVergiNo: string);
// NACE.postman_collection.json: GET {baseUrl}/v2/taxpayers/{VKN}?includeActivities=true
//   Authorization: Bearer <accessToken>.  Token TIzibizRest.Login ile alinir.
var
  LToken, LHata, LUrl, LYanit: string;
  LClient: THTTPClient;
  LResp: IHTTPResponse;
  LJson: TJSONValue;
begin
  MemoBilgi.Clear;
  MemoBilgi.Lines.Add('VKN/TCKN: ' + AVergiNo);

  // 1) accessToken al (kullanici/sifre formdan).
  if not IzibizTokenAl(LToken, LHata) then begin
    MemoBilgi.Lines.Add('Giris (token) basarisiz: ' + LHata);
    Exit;
  end;

  // 2) taxpayers detay + faaliyet (NACE) cek.
  try
    LClient := THTTPClient.Create;
    try
      LClient.Accept := 'application/json';
      LClient.CustomHeaders['Authorization'] := 'Bearer ' + LToken;
      LClient.ConnectionTimeout := 30000;
      LClient.ResponseTimeout := 60000;
      LUrl := IZIBIZ_REST_BASE + '/v2/taxpayers/' + AVergiNo +
        '?includeActivities=true';
      LResp := LClient.Get(LUrl);
      LYanit := LResp.ContentAsString(TEncoding.UTF8);
      MemoBilgi.Lines.Add('HTTP ' + IntToStr(LResp.StatusCode));
      MemoBilgi.Lines.Add(LUrl);
      MemoBilgi.Lines.Add('');
      // Tum bilgiyi okunabilir bicimde dok (firma + faaliyet/NACE detaylari).
      LJson := TJSONObject.ParseJSONValue(LYanit);
      if LJson <> nil then
        try
          MemoBilgi.Lines.Add(LJson.Format(2));
        finally
          LJson.Free;
        end
      else
        MemoBilgi.Lines.Add(LYanit);
    finally
      LClient.Free;
    end;
  except
    on E: Exception do
      MemoBilgi.Lines.Add('Taxpayers sorgu hatasi: ' + E.Message);
  end;
end;



function TTablo.EFaturami(RehID:integer; CarideEFatura : boolean; VNo:string):smallint;
var
   //Etiketler, Bilgiler: TArrayOfString;
   fa : TEFaturaFirmaAra;
   Function BireyKurum(Birey, Kurum : smallint) : smallint;
   begin
         if Length(VNO) = 10 then //�irketse
         Result := Kurum
      else if Length(VNO)=11 then //�ah�s ise
         Result := Birey;
  end;
begin   //  EFaturaKullanimda 0:yok 1:e-fat 11:e-fat + e-ar�
   EFaturaKullanimda := 1;
   Result := 0;
   VNo := StringReplace( Vno, ' ','',[rfReplaceAll]);
   if not (Length(VNo) in [10,11]) then begin
      //UyariGoster(Uyari,'Ge�ersiz Vergi No! Faturay� �ptal edin; Vergi No d�zeltip tekrar deneyin!',1);
      showmessage('Ge�ersiz Vergi No! Faturay� �ptal edin; Vergi No d�zeltip tekrar deneyin!');
      exit;
   end;

           (*
   if EFaturaKullanimda=0 then
      exit
   else if CarideEFatura then begin//caride efatura kullan�yor i�aretliyse direk kurum i�in 1, �ah�s i�in 21 yaz�p ge�elim
         Result := BireyKurum(21, 1);
         exit;
   end;  *)

//   Tablo.RehberEkBilgileriniGetir(RehID, 2, [RehVars_Vergi_No], Etiketler, Bilgiler);
//   VNo := StringReplace( Bilgiler[0], ' ','',[rfReplaceAll]);


    FAddr := Ent_Addr;
    fa := TEFaturaFirmaAra.Create(nil);
    fa.KullaniciAdi := Ent_Kullanici;//'sahinleryapi';
    fa.Sifre := Ent_Sifre;//'SHN102030Q';
    try
    if fa.FirmaVarMi(VNo) then //entegrat�r firmadan tarama yapar�z
       Result := 1
    else
       Result := 0;
    except                     ////entegrat�r firmaya ba�lanamazsak veri taban�ndan tarama yapar�z
//      if 'SELECT * FROM EFATURA.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''',[],[]) then
      //26/03/2021 AO EFATURA veri taban�ndan bulunan, INSTITUTIONS tablosuna, InvoiceType eklenmi�tir.
      // 1 -> E-Fatura m�kellefi, 2 -> E-�rsaliye m�kellefi, 3 -> E-Ar�iv m�kellefi
(*      TablodanSorguAc(1, 'SELECT * FROM '+EFaturaDB+'.dbo.INSTITUTIONS WHERE replace(TaxIdNoOrId,'' '','''')='''+VNo+'''');
      if Tablo.Query1.RecordCount > 0 then begin
         if trim(Tablo.Query1.FieldByName('InvoiceType').AsString) = '1' then  //Alias ar�iv i�arteli ise
            Result := 1
         else
            Result := 0
      end
      else
         Result := 0; *)
    end;
    fa.Free;

(*    if Result = 1 then begin //  sorgu dolu d�nm��se caride e-fatural� diye i�aretle
       Veritabani.BasitKomut�al��t�r(Tablo.cnn, ' update REHBER set EFATURA = 1 where ID = '+IntToStr(RehID) ,[],[]);
       Result := BireyKurum(21, 1);
    end else if Result = 0 then  //  sorgu bo� d�nm��se
       case EFaturaKullanimda of
        1 : ; //e�er sadece efat kullan�l�yor ve  ka��t fat demektir
        11: //e�er efat + ear� kullan�l�yor ise bakar�z
              Result := BireyKurum(31, 11);
       end;               *)
end;


end.
