unit uSocialCommon;

interface

type
   recLead = record
     id : string;
     created_time : string;
     NOT1,
     FULL_NAME,
     EMAIL,
     PHONE,
     PHONE2,
     STREET_ADDRESS,
     CITY,
     TOWN,    // Kasaba/İlçe
     COUNTRY,
     GENDER : string;
   end;

function QS(_s : string) : string;
function DQ(_s : string) : string;
function UnQUote(_s : string) : string;
function FirstUpperCase(_s : string) : string;

implementation
uses
  System.AnsiStrings;

function QS(_s : string) : string;
begin
  Result := #39 + _s + #39;
end;


function DQ(_s : string) : string;
begin
  Result := '"' + _s + '"';
end;

function UnQUote(_s : string) : string;
begin
  Result := _s;
  if Result[1] = '<' then
    Delete(Result, 1, 1);
  if Result[Length(Result)] = '>' then
    Delete(Result, Length(Result), 1);
end;

function FirstUpperCase(_s : string) : string;
var
  ilkChar : string;
begin
   Result := _s;
   if Length(result)>0 then
    begin
      ilkChar := AnsiUppercase(Copy(Result, 1, 1));
      Result := ilkChar + Copy(Result, 2, 2048);

    end;
end;

end.
