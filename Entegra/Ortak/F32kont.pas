Unit f32kont;

Interface

Var
   KeyGirdi,KeyCikti:Boolean;
   Function IsRegistered(Var Coklu:SmallInt):SmallInt;

Implementation

Uses
   WinTypes, SysUtils, Classes,FetaUtil;
//Uses WinProcs, Messages, DBTables, Classes, Graphics, DBGrids, Printers

Function IsRegistered(Var Coklu:SmallInt):SmallInt;
Var
   MyFile:TFileStream;
Begin
   FillChar(GenotipBilgi,SizeOf(TGenotipBilgi),0);
   Coklu:=1;
   IsRegistered:=1;
   KeyGirdi:=True;
   KeyCikti:=False;
//

   FetaSetSize(FetaGetSysDir+DataFile, SizeOf(TGenotipBilgi));
   Try
      MyFile:=TFileStream.Create(FetaGetSysDir+DataFile, fmOpenRead);
   Except
      Exit;
   End;

   IsRegistered:=2;
   Try
      MyFile.Read(GenotipBilgi,SizeOf(TGenotipBilgi));
   Except
      Exit;
   End;
   MyFile.Destroy;
   FetaSetSize(FetaGetSysDir+DataFile,20);
   Sifrele(-1,@GenotipBilgi,SizeOf(TGenotipBilgi));

   IsRegistered:=3;
   If GenotipBilgi.Crc<>CrcHesapla(@GenotipBilgi,SizeOf(TGenotipBilgi)-2) Then
      Exit;

   Coklu:=GenotipBilgi.CokKullanici;

//

   IsRegistered:=0;
   KeyCikti:=True;
End;
Begin
   KeyGirdi:=False;
   KeyCikti:=False;
End.
