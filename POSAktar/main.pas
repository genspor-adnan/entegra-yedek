program Main;

uses
  Auth, PosInfo;

var
  AuthToken: string;
begin
  AuthToken := Authenticate;
  FetchPOSInfo(AuthToken);
end.
