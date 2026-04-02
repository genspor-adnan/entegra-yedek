unit UTasklist;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;


Type
  TProcRecord=record
      Exename:string;
      ProcId:Cardinal;
  end;


var
    ProcRecords:array[0..1000] of TProcRecord;

Function TaskListteVar:Boolean;


implementation
                    // EnumProcesses
uses psapi;

{*******************************************************************************
Function Name: ShowNTProcesses

Parameters: None

Result:  None

Author: David G. Parsons

Date:  3/23/2000

Comments:   Function returns the names of all open proccesses in NT/W2K (not Win 9x)
           populates the TProcRecord array.
           * include PSAPI in the uses section!! *

Revision history:
*******************************************************************************}
Function TaskListteVar:Boolean;
var
  Pids:array of Dword;
  procid:array [0..1000] of Dword;
  Howmany:Cardinal;
  numprocs:integer;
  loopint:integer;
  Fname:array [0..10000] of char;
  ProcHandle:Thandle;
  hmods:array [0..10000] of Dword;
  quantity:cardinal;
  ResList:Tstringlist;
  s:string;
begin
 TaskListteVar := False;
 Try
    enumprocesses(@Procid,1000,Howmany);
    For numprocs:=0 to howmany-1 do
    begin
      Setlength(pids,length(pids)+1);
      Pids[length(pids)-1]:=procid[numprocs];
    end;
   Except
     On E:Exception do
     begin
       showmessage(E.Message);
       exit;
     end;
   end;// of try
   For loopint:=0 to Length(Pids)-1 do
   begin
     try
        ProcHandle:=OpenProcess(PROCESS_QUERY_INFORMATION+PROCESS_VM_READ,FALSE, Pids[loopint]);
        if (ProcHandle>0) then
        begin
          Enumprocessmodules(prochandle,@hmods,1000,Howmany);
          if (GetModuleBasename(prochandle,Hmods[0],Fname,10000)>0) then
          begin
//           Procrecords[loopint].Exename:=Fname;
//           Procrecords[loopint].Exename := Fname;
//           if UpperCase(Procrecords[loopint].Exename) ='GENOTIP.EXE' then
             if Fname[0] ='G' then //'GENOTIP.EXE' then
              TaskListteVar := True;
           ProcRecords[loopint].ProcId:=pids[loopint];
          end;
        end;
    except
      on E:Exception do
      begin
        Continue;
      end;
    end;/// of try
  end;
end;

end.


end.
