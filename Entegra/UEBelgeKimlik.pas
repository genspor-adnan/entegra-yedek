unit UEBelgeKimlik;

// E-Belge gonderim/alias akislarinda kullanilan ortak kimlik cache.
// TEST veya URETIM moduna gore GENINI'den bir kez okunur, ardindan tum
// akislar (alias sorgusu, gonderim, vs.) bu cache'i kullanir.
// Opsiyon kaydedildiginde Sifirla cagrilirsa sonraki istek tazelenmis bilgileri alir.

interface

type
  TEBelgeKimlik = class
  public
    /// Test/Uretim moduna gore GENINI'den kimlik bilgilerini doner.
    /// Ilk cagrida okur, sonraki cagrilarda cache'i kullanir.
    class procedure Yukle(out AKullanici, ASifre, AURL: string;
      out ATestModu: Boolean); static;
    /// Cache'i sifirlar (opsiyon kaydedildikten sonra cagrilmali).
    class procedure Sifirla; static;
    /// Yuklenmis mi?
    class function Yuklendi: Boolean; static;
    /// Cached access token (alias ve send icin ortak kullanim).
    /// Son set'ten sonraki AGecerlilikDakika dakika boyunca gecerli sayilir.
    class procedure TokenSet(const AToken: string;
      AGecerlilikDakika: Integer = 25); static;
    /// Bos string donerse cached token yok/expired — yeniden Login yapilmali.
    class function TokenAl: string; static;
    /// Token cache'ini de sifirla.
    class procedure TokenSifirla; static;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, Utablo, PrjConst, UGenSifre;

var
  GYuklendi: Boolean = False;
  GKullanici: string = '';
  GSifre: string = '';
  GURL: string = '';
  GTestModu: Boolean = True;
  GToken: string = '';
  GTokenSonGecerlilik: TDateTime = 0;

class procedure TEBelgeKimlik.Yukle(out AKullanici, ASifre, AURL: string;
  out ATestModu: Boolean);
begin
  if not GYuklendi then begin
    GTestModu := Tablo.GENINI.ReadBoolean(Ops_FaturaOpsiyon_EBelgeTestAktif, True);
    if GTestModu then begin
      GKullanici := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeKullanici, '');
      GSifre := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EBelgeSifre, '');
      GURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_EFaturaTestURL, '');
    end else begin
      GKullanici := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Kullanici, '');
      GSifre := UGenSifre.DeSifre(
        Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Sifre, ''));
      GURL := Tablo.GENINI.ReadString(Ops_FaturaOpsiyon_Ent_Adres, '');
    end;
    GYuklendi := True;
  end;
  AKullanici := GKullanici;
  ASifre := GSifre;
  AURL := GURL;
  ATestModu := GTestModu;
end;

class procedure TEBelgeKimlik.Sifirla;
begin
  GYuklendi := False;
  GKullanici := '';
  GSifre := '';
  GURL := '';
  TokenSifirla;   // kimlik degisirse token da gecersiz
end;

class function TEBelgeKimlik.Yuklendi: Boolean;
begin
  Result := GYuklendi;
end;

class procedure TEBelgeKimlik.TokenSet(const AToken: string;
  AGecerlilikDakika: Integer = 25);
begin
  GToken := AToken;
  if AGecerlilikDakika > 0 then
    GTokenSonGecerlilik := IncMinute(Now, AGecerlilikDakika)
  else
    GTokenSonGecerlilik := 0;
end;

class function TEBelgeKimlik.TokenAl: string;
begin
  if (GToken <> '') and (GTokenSonGecerlilik > Now) then
    Result := GToken
  else begin
    Result := '';
    GToken := '';
    GTokenSonGecerlilik := 0;
  end;
end;

class procedure TEBelgeKimlik.TokenSifirla;
begin
  GToken := '';
  GTokenSonGecerlilik := 0;
end;

end.
