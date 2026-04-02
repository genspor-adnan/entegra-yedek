unit uDebugUtils;

interface

function GetCurrentAddress: Pointer;
function GetMethodName(AClass: TClass; Address: Pointer): string; overload;
function GetMethodName(AObject: TObject; Address: Pointer): string; overload;

implementation

// Get address of currently executed code
function GetCurrentAddress: Pointer;
begin
  Result := ReturnAddress;
end;

// Get name of class method that contains the given address.
// Note that it has to utilize some internals
function GetMethodName(AClass: TClass; Address: Pointer): string; overload;
type   // copy declaration from System's impl section
  PMethRec = ^MethRec;
  MethRec = packed record
    recSize: Word;
    methAddr: Pointer;
    nameLen: Byte;
    { nameChars[nameLen]: AnsiChar }
  end;
var
  LMethTablePtr: Pointer;
  LMethCount: Word;
  LMethEntry, LResultMethEntry: PMethRec;
begin
  Result := '';

  { Obtain the method table and count }
  LMethTablePtr := PPointer(PByte(AClass) + vmtMethodTable)^;
  if LMethTablePtr = nil then // no methods...
    Exit;
  LMethCount := PWord(LMethTablePtr)^;
  if LMethCount = 0 then // no methods...
    Exit;

  Inc(PWord(LMethTablePtr));
  // Get all method entries and find max method entry addr that is less (or equal - very unlikely tho) than Address
  LMethEntry := LMethTablePtr;
  LResultMethEntry := nil;
  while LMethCount > 0 do
  begin
    // Only consider methods starting before the Address
    if PByte(LMethEntry.methAddr) <= PByte(Address) then
    begin
      // Not assigned yet
      if (LResultMethEntry = nil) or
        // Current entry is closer to Address, reassign the variable
        (PByte(LMethEntry.methAddr) > PByte(LResultMethEntry.methAddr)) then
        LResultMethEntry := LMethEntry;
    end;
    Dec(LMethCount);
    LMethEntry := Pointer(PByte(LMethEntry) + LMethEntry.recSize); // get next
  end;

  if LResultMethEntry <> nil then
    Result := string(PShortString(@LResultMethEntry.nameLen)^);
end;

// Get name of object's method that contains the given address
function GetMethodName(AObject: TObject; Address: Pointer): string; overload;
begin
  Result := GetMethodName(AObject.ClassType, Address);
end;

end.
