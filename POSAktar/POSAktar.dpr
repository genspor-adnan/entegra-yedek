program POSAktar;

uses
  SysUtils,
  Auth,
  PosInfo;

begin
  // Main program execution starts here
  // Call authentication and fetch POS information
  Authenticate;
  FetchPOSInfo;
end.

