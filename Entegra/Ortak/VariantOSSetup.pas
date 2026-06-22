unit VariantOSSetup;

interface

implementation

uses

 Sysutils, Variants;


function CheckWin32VersionBelow(AMajor: Integer; AMinor: Integer = 0): Boolean;

begin

 Result := (Win32MajorVersion < AMajor) or ((Win32MajorVersion = AMajor) and  (Win32MinorVersion <= AMinor));

end;


initialization

OleVariantInt64AsDouble := CheckWin32VersionBelow(5);

end.

