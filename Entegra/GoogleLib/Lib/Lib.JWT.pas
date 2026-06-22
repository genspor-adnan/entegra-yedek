unit Lib.JWT;

{ Java Web Tokens }

interface

uses
  System.SysUtils;

const
  { RSA with SHA256 }
  JWT_RS256 = '{"alg":"RS256","typ":"JWT"}';

  { TODO: Added HMAC with SHA256 token support }

{ Creates a Java Web Token using the provided private key in PEM format }
function JavaWebToken(const APrivateKey: TBytes; const AHeader, APayload: String; out AJWT: String): Boolean;

implementation

uses
  {$IF CompilerVersion < 28.0} //XE7
  Lib.Helpers,
  {$ENDIF}
  Lib.OpenSSL,
  Lib.Base64;

function JavaWebToken(const APrivateKey: TBytes; const AHeader, APayload: String; out AJWT: String): Boolean;
var
  Data: TBytes;
  JWS: TBytes;
begin
  {$IF CompilerVersion >= 28.0}
  Data := Base64Encode(BytesOf(AHeader)) + [Ord('.')] + Base64Encode(BytesOf(APayload));
  {$ELSE}
  Data := Base64Encode(BytesOf(AHeader));
  TArrHelper.AppendArrays<Byte>(Data, TBytes.Create(Ord('.')));
  TArrHelper.AppendArrays<Byte>(Data, Base64Encode(BytesOf(APayload)));
  {$ENDIF}

  if TSSLHelper.Sign_RSASHA256(Data, APrivateKey, JWS) then
  begin
    AJWT := StringOf(Data) + '.' + StringOf(Base64Encode(JWS));
    Result := True;
  end
  else
    Result := False;
end;

end.
