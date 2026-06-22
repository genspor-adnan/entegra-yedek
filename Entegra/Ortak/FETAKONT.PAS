Unit FetaKont;

Interface

Var
   KeyGirdi,KeyCikti:Boolean;
   Function Iskeydisket(Mdl:Byte;Var Coklu:Integer;P:PChar):Integer;

Implementation
Uses
   WinProcs,WinTypes;
procedure  hasp (Service, SeedCode, LptNum, Pass1, Pass2 : integer;
                    var p1,p2,p3,p4 : integer);far;external;{$L  hasptpw.obj}

{
   For Windows 3.0 compatability : add the following line - }

function PrestoChangoSelector( x :word; y: word ) : word; far; external 'KERNEL';

Const
   IS_HASP                      =  1;
   GET_HASP_CODE                =  2;
   READ_MEMO                    =  3;
   WRITE_MEMO                   =  4;
   GET_HASP_STATUS              =  5;
   GET_ID_NUM                   =  6;
   READ_MEMO_BLOCK              = 50;
   WRITE_MEMO_BLOCK             = 51;

   LPT_IBM_ALL_HASP25  = 0;
   LPT_IBM_ALL_HASP36  = 50;
   LPT_NEC_ALL_HASP36  = 60;

   MEMO_BUFFER_SIZE  = 248;
   TIME_BUFFER_SIZE  = 16; (* TimeHASP maximum block size *)

   (*
 * A list of the TimeHASP services
 *)
   TIMEHASP_SET_TIME            = 70;
   TIMEHASP_GET_TIME            = 71;
   TIMEHASP_SET_DATE            = 72;
   TIMEHASP_GET_DATE            = 73;
   TIMEHASP_WRITE_MEMORY        = 74;
   TIMEHASP_READ_MEMORY         = 75;
   TIMEHASP_WRITE_MEMORY_BLOCK  = 76;
   TIMEHASP_READ_MEMORY_BLOCK   = 77;
   TIMEHASP_GET_ID_NUM          = 78;

(*
 * A list of NetHASP services.
 *)
   NET_LAST_STATUS              = 40;
   NET_GET_HASP_CODE            = 41;
   NET_LOGIN                    = 42;
   NET_LOGOUT                   = 43;
   NET_READ_WORD                = 44;
   NET_WRITE_WORD               = 45;
   NET_GET_ID_NUMBER            = 46;
   NET_SET_IDLE_TIME            = 48;   
   NET_READ_MEMO_BLOCK          = 52;
   NET_WRITE_MEMO_BLOCK         = 53;

   OK                           = 0;
   NET_READ_ERROR               = 131;
   NET_WRITE_ERROR              = 132;




Function HASPControl:Boolean;
Var
   p1, p2, p3, p4:Integer;
Begin
    HASPControl:=False;
    hasp ( IS_HASP, 2001, LPT_IBM_ALL_HASP25, 4862, 13240, p1, p2, p3, p4 );
    if p1 = 0 then Exit;
    hasp ( GET_HASP_CODE, 2001, LPT_IBM_ALL_HASP25, 4862, 13240, p1, p2, p3, p4 );
    If (p1=25664) And (p2=21072) And (p3=-10973) And (p4=512) Then
       HASPControl:=True;


End;


Function Test_Disket(Mdl:Byte; S,h,t:Byte):Byte;
Var
   Ht:Byte;
   Label Git5, Git6;
Begin
   Asm
      Push Bp
      Push Sp
      Push Ss
      Push Ds
      Mov ah, 4  ; { Verify Sector}
      Mov al, 1  ;
      Mov ch, T  ;
      Mov cl, S  ;
      Mov dh, H  ;
      Mov Dl, Mdl;
      Int $13    ; { Call DOS }
      Jc Git5
      Mov Ht,0
      Jmp Git6
Git5: Mov Ht,1
Git6:
      Pop Ds
      Pop Ss
      Pop Sp
      Pop Bp
   End;
   Test_disket:=ht;
End;
Function Iskeydisket(Mdl:Byte;Var Coklu:Integer;P:PChar):Integer;
Type
   Boz_type=record
      t,s,h,b:Integer;
   End;
   BozdiziType=Array[1..64] of boz_type;
Var
   k,l,Boz:Integer;
   Hata,saglam:array[1..3] of boz_type;
   BozDizi:^BozdiziType;
   MemH:THandle;
   Ptut:PChar;
   SonFlag, Tut1,Tut2:Word;
   Sonuc : Byte;
   MCarry: Byte;

   Function TestOkunan(Prm:Integer):Boolean;
   Var
      K:Integer;
   Begin
   {$Q-}
      TestOkunan:=False;
      Boz:=0;
      For k:=1 to 64 do begin
         if (k mod 2) = 0 then
            Boz:=Boz+Bozdizi^[k].t+(1+Prm)*Bozdizi^[k].s-3*Bozdizi^[k].h
         else
            Boz:=Boz-Bozdizi^[k].t+3*Bozdizi^[k].s+2*Bozdizi^[k].h;
         if (k mod 8) = 0 Then begin
            If Bozdizi^[k].b<>Boz Then Exit;
            boz:=0;
         End;
      End;
      TestOkunan:=True;
   End;

   Procedure BellekBirak;
   Begin
      localunlock(MemH);
      localFree(MemH);
   End;

   label Git1, Git2, Git3, Git4;

begin
   Coklu:=1;
   Iskeydisket:=0;
   For k:=0 To 49 Do P[k]:=Chr(k+1);
   P[50]:=Chr(0);
   KeyGirdi:=True;
   KeyCikti:=False;
   If HASPControl Then Begin
      Iskeydisket:=0;
      KeyCikti:=True;
      Coklu:=2;
      Exit;
   End;

   Iskeydisket:=1;
   Bozdizi:=Nil;
   MemH:=LocalAlloc(GHND,64*8);
   If MemH=0 Then Exit;
   BozDizi:=localLock(MemH);
   If BozDizi=NIL Then Begin
      LocalFree(MemH);
      Exit;
   End;
   Tut1 := Seg(Bozdizi^);
   Tut2 := Ofs(Bozdizi^);
   Repeat
      asm
         Push Bp
         Push Sp
         Push Ss
         Push Ds
         Mov Ah, 2 { Read Sector}
         Mov Al, 1
         Mov Es, Tut1  { Seg- Set DS:DX to addr }
         Mov Bx, Tut2  { Ofs- of first char }
         Mov Ch, 0
         Mov Cl, 2
         Mov Dh, 0
         Mov Dl, Mdl
         Int $13                { Call DOS }
         Mov Sonuc, Ah
         Jc Git1
         Mov MCarry,0
         Jmp Git2
Git1:    Mov MCarry,1
Git2:
         Pop Ds
         Pop Ss
         Pop Sp
         Pop Bp
      End;
      If MCarry = 1 Then
         If Sonuc<>$06 Then Begin
            BellekBirak;
            Exit;
         End;
   Until Sonuc<>$06;
   Hata[1]:=Bozdizi^[5];
   Hata[2]:=Bozdizi^[29];
   Hata[3]:=Bozdizi^[43];
   Saglam[1]:=Bozdizi^[9];
   Saglam[2]:=Bozdizi^[12];
   Saglam[3]:=Bozdizi^[51];
   Boz:=0;
   Iskeydisket:=2;

   If TestOkunan(1) Then Coklu:=1
   Else If TestOkunan(2) Then Coklu:=2
   Else Coklu:=0;

   Iskeydisket:=5;
   Repeat
      Asm
         Push Bp
         Push Sp
         Push Ss
         Push Ds
         Mov Ah, 2; { Read Sector}
         Mov Al, 1;
         Mov Es, Tut1; { Seg- Set DS:DX to addr }
         Mov Bx, Tut2; { Ofs- of first char }
         Mov Ch, 1;{track}
         Mov Cl, 2;{Sector}
         Mov Dh, 0;{Head}
         Mov Dl, Mdl;
         Int $13; { Call DOS }
         Mov Sonuc, Ah
         Jc Git3
         Mov MCarry,0
         Jmp Git4
Git3:    Mov MCarry,1
Git4:
         Pop Ds
         Pop Ss
         Pop Sp
         Pop Bp
      End;
      If MCArry = 1 Then
         If Sonuc<>$06 Then Begin
            BellekBirak;
            Exit;
         End;
   Until Sonuc<>$06;
   PTut:=PChar(Bozdizi);
   k:=0;
   l:=0;
   While (Ptut[k]<>#0) And (k<51) Do Begin
      If Ptut[k]<>Chr(255-Ord(Ptut[k+1])) Then
         k:=100
      Else Begin
         Ptut[l]:=Ptut[k];
         Inc(k,2);
         Inc(l);
      End;
   End;
   Ptut[l]:=#0;
   If (k=100) Or (k=1) Then
      For k:=0 to 49 do Ptut[k]:=Chr(k+1);
   Ptut[50]:=#0;
   Move(Bozdizi^,P^,51);
   IF Coklu=0 Then Begin
      BellekBirak;
      Exit;
   End;
   Iskeydisket:=3;
   For l:=1 to 3 do begin
      Boz:=0;
      k:=1;
      While (k<5) And (Boz=0) do begin
         Boz:=Test_Disket(Mdl,Hata[l].S,Hata[l].H,Hata[l].t);
         If Boz = 0 Then begin
            Asm
               Push Bp
               Push Sp
               Push Ss
               Push Ds
               Mov Ah, 0  ; { Reset Disket}
               Mov Dl, Mdl;
               Int $13    ; { Call DOS }
               Pop Ds
               Pop Ss
               Pop Sp
               Pop Bp
            End;
         End;
         k:=k+1;
      End;
      If Boz = 0 Then Begin
         BellekBirak;
         Exit;
      End;
   End;
   Iskeydisket:=4;
   For l:=1 to 3 do
      If Test_Disket(Mdl,Saglam[l].S,Saglam[l].H,Saglam[l].t)<>0 Then
         If Test_Disket(Mdl,Saglam[l].S,Saglam[l].H,Saglam[l].t)<>0 Then Begin
            BellekBirak;
            Exit;
         End;
   Iskeydisket:=0;
   KeyCikti:=True;
   BellekBirak;
End;
Begin
   KeyGirdi:=False;
   KeyCikti:=False;
End.
