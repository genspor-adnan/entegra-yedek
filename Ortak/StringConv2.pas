unit StringConv;

interface

uses SysUtils;

const
	CRLF : String = #13#10;
	ssSkip = 1;
	ssScan = 0;

	AlphaNum : String =  'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	AlphaNum2 : String = '_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	AlphaNum3 : String = '_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮёЁ';
	CfgAllowedChars : String = '_#@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	Printable: String = ' !%&()-+=*[]{}~;:"?/\<>.,_|№#@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	Printable1251: String = ' !%&()-+=*[]{}~`;:"?/\<>.,_|#@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮёЁ';
	Delimitors : String = '=,.<>;:\/?+-*&^%(){}[]|!~ '#9#10#13#0;
	i2xtable : array [0..15] of char = '0123456789abcdef';
	HexDigits : String = '0123456789abcdefABCDEF';
	DecimalDigits : String = '0123456789';
	DefaultStringTerminators : String = ',; '#9#10#13#0;


type
	PInteger = ^Integer;
	EStrConvError = class(Exception)
  public
  	ErrorCode : Integer;
	end;

	TArrayOfInteger = Array of Integer;

function IntMax( L1,L2 : Integer ) : Integer; assembler;
function RoundCents( const ACurr : Currency ) : Currency;
function IncMonth( ADate : TDateTime; const AMonthes : Integer ) : TDateTime;

function SpellCurrency( ANum : Currency ) : String;
function SpellDate( const ADate : TDateTime ) : String;

function GetTokenInteger(var ptr:PChar):Integer;
function GetIntegers(ptr:PChar;Arg:Array of PInteger):PChar;

function Comma( const str1, str2 : string ) : string;
function CommaAppend( var str1 : string; const str2 : string ) : string;
function LineAppend( var str1 : string; const str2 : string ) : string;
function StrOpStr( const str1, op, str2 : string ) : string;
function StrSpaceStr( const str1, op, str2 : string ) : string;
function StrAppendOpStr( var str1 : string; const op, str2 : string ) : string;

function Quote( const Line : String ) : String;
function XQuote( const Line, Table : String ) : String;
function ConditionalQuote( const Line : String; NoQuote : String; NoEscape : String ) : String;
function CfgQuote( const Line : String ) : String;
function NullQuote( const str : String ) : String;
function TextToCSV( Src : String ) : String;
function UnQuoteToken(var ptr : PChar) : String;
function QStrSplit( var str : String; c : char ) : String;
function QStrUnquote( str : String ) : String;
{function UnQuote(var ptr:PChar):String;}
function DeEsc( Str : String ) : String;

function SkipBlanks(ptr:PChar):PChar;
function SkipBlanksLen( var ptr : PChar; var len : Integer ) : PChar; // Пропускаем пробелы и символы табуляции
function RemoveTrailingBlanksLen( var ptr : PChar; var len : Integer ) : PChar; // Удаляем концевые пробелы и табуляции - уменьшаем len на количество концевых прбелов и табуляций
function FindLexLen( var ptr : PChar; var len : Integer ) : PChar; // Пропускаем управляющие символы и пробелы ( все символы меньше $21 )
function NextLine( var ptr : PChar; var len : Integer ) : PChar; // Пара ptr/len устанавливается за первый CR и/или LF
function NextTokenLen( var ptr : PChar; var len : Integer ) : PChar;
function NextToken( var ptr : PChar ) : PChar;

function QStrScan( str : String; c : char ) : Integer;
function QMemScan( ptr : PChar; len : Integer; c : Char ) : PChar;
function QSkipChars( ptr:PChar; len:Integer; chars : String )	: Integer;
function QScanChars( ptr:PChar; len:Integer; chars : String ) : Integer;
function StripCRLF( Str : String ) : String;

// Извлекаем строку до первого символа, не входящего в AllowedChars, этот символ будет выдан в ATerm.
// Если все символы из AllowedChars, то ATerm будет #0
// Если AllowedChars='' то будет использоваться AlphaNum2
// Пара ptr/len будет указывать на символ-терминатор
function GetTerm( var ptr : PChar; var len : Integer; var ATerm : Char; AllowedChars : String = '' ) : String;

// Если первый значимый символ - апостроф или кавычка, то будет возвращена расквоченная строка,
// иначе извлекает строку до терминатора, а пробелы/табуляции с обоих сторон будут удалены.
// Пара ptr/len будет указывать на символ-терминатор.
// Если ATerminators='' то будет использоваться DefaultStringTerminators
function GetStringTerm( var ptr : PChar; var len : Integer; ATerminators : String = '' ) : String;

// Эквивалентно вызову GetStringTerm(ptr,len,'');
function GetString( var ptr : PChar; var len : Integer ) : String;

// Если первый значимый символ - апостроф или кавычка, то будет возвращена расквоченная строка,
// иначе извлекает строку до первого недопустимого симола.
// Пара ptr/len будет указывать на первый символ, не входящий в число допустимых
// Если AllowedChars='' то будет использоваться AlphaNum2
function GetStringAlpha( var ptr : PChar; var len : Integer; AllowedChars : String = '' ) : String;

function GetLine( var ptr : PChar; var len : Integer ) : String;
function GetCfgKey( var ptr : PChar; var len : Integer ) : String;
function GetSubStr( var ptr : PChar; var len : Integer; const ATerminators : String ) : String;

function GetInteger(var ptr:PChar; var len:Integer) : Integer;
function GetInt64( var ptr : PChar; var len : Integer ) : Int64;
function GetIntegerDef( var ptr : PChar; var len : Integer; const ADefaultValue : Integer ) : Integer;
function GetInt64Def( var ptr : PChar; var len : Integer; const ADefaultValue : Int64 ) : Int64;
function GetIntegerArray( var ptr : PChar; var len : Integer; ATerminators : String ) : TArrayOfInteger;

function StrToIntegerArray( const S : String ) : TArrayOfInteger;
function IntegerArrayToStr( const A : TArrayOfInteger ) : String;

function GetNumVariant( var ptr:PChar; var len:Integer ) : Variant;

function c2x( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
function c2hex( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
function i2x( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
function BinToHex( const ptr : Pointer; len : Integer ) : String;
function DumpToBuf( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
function dump( ptr : Pointer; len : Integer ) : String;
function hex2c( Dest, Src : Pointer; len : Integer ) : Integer; assembler;

procedure AsmXLAT( Str : String; const sFrom, sTo : String; Pad : Char ); assembler;
function Translate( const Str, sFrom, sTo : String; Pad : Char ) : String;
function MacroExpand( src:String; Args : Array of String; c : Char ):String;
//function EncodeId( Origin, Id :Integer ) : String;
//procedure DecodeId( var Origin,Id : Integer; ptr : PChar ); assembler;

function MemScan(Str: PChar; Len : LongInt; Chr : Char): PChar; assembler;
function MemCpy( Dest : Pointer; Src : Pointer; Len : Integer ) : Pointer; assembler;
function MemCmp( Src1 : Pointer; Src2 : Pointer; Len : Integer ) : Integer; assembler;

function WStrComp( src1, src2 : PWideChar ) : Integer;

function lstrcmpi( const Str1, Str2 : PChar ) : LongInt; stdcall;  external 'kernel32.dll' name 'lstrcmpi';
function lstrcmp( const Str1, Str2 : PChar ) : LongInt; stdcall;  external 'kernel32.dll' name 'lstrcmp';

//=============================================================
implementation
uses	Windows;

//=============================================================
function IntMax( L1,L2 : Integer ) :Integer; assembler;
asm
	cmp	eax,edx
	jge	@@Ret
	mov	eax,edx
@@Ret:
end;

//-------------------------------------------------------------
               { EAX         EDX            ECX }
function MemScan(Str: PChar; Len : LongInt; Chr : Char): PChar; assembler;
asm
	push    edi
	push    eax      { Str }
	mov     al,chr   { CL }
	mov     ecx,len  { EDX }
	pop     edi      { Str }
	repne   scasb
	mov     eax,0
	jne     @@1
	mov     eax,edi
	dec     eax
@@1:
	pop     edi
end;

               { EAX            EDX            ECX }
function MemCpy( Dest: Pointer; Src : Pointer; Len : Integer ): Pointer; assembler;
asm
	push    edi
	push		esi
	mov			esi,edx
	mov			edi,eax
	rep			movsb
	mov     eax,edi
	pop     esi
	pop			edi
end;

               { EAX            EDX             ECX }
function MemCmp( Src1: Pointer; Src2 : Pointer; Len : Integer ): Integer; assembler;
asm
  push    edi
  push		esi
  mov			esi,edx
  mov			edi,eax
  xor			eax,eax
  repe		cmpsb
  je			@@2
  mov     al,[edi-1]
  sub			al,[esi-1]
	movsx		eax,al
@@2:
	pop     esi
	pop			edi
end;

{---------------------------------------------------------------------------}
function WStrComp( src1, src2 : PWideChar ):Integer; assembler;
asm
	or		eax,eax
  jnz		@@1
	or		edx,edx
  jz		@@Ret
  dec		eax
  jmp		@@Ret

@@1:
	or		edx,edx
  jnz		@@2
  xor		eax,eax
  inc		eax
  jmp		@@Ret

@@2:
  push	edi
  push	esi
	mov		esi,eax
  mov		edi,edx
  xor		eax,eax
  xor		ecx,ecx
  dec		ecx
  repne	scasw
  not		ecx
  mov		edi,edx
	xor		edx,edx
  repe	cmpsw
	mov		ax,[esi-2]
	mov		dx,[edi-2]
	sub		eax,edx
	pop		esi
  pop		edi
@@Ret:
end;

//-------------------------------------------------------------
function TextToCSV( Src : String ) : String;
const	MAXLEN = 256;
var buf : Array [0..(MAXLEN*2+1)] of Char;
		ptr : PChar;
    Len : Integer;
	function TextToBufCSV( src, buf : PChar; len : Integer ) : Integer; assembler;
	asm
		test	eax,eax	// Src
  	jz		@@Ret
  	test	ecx,ecx	// len
  	jz		@@RetNIL
		push	edi
		push	esi
		push	ebx

		push	edx
  	mov		esi,eax	// Src
		mov		ebx,ecx
  	mov		al,'"'
		mov		[edx],al
		inc   edx
		mov		edi,edx
	@@1:
		mov		edi,esi
	repnz	scasb
		jnz		@@7
		mov		edi,edx	// Buf
		xchg	ecx,ebx
		sub		ecx,ebx
		jz		@@5
	rep	movsb
	@@5:
		stosb		// удваиваем кавычку
		mov		edx,edi
		mov		ecx,ebx
		test	ebx,ebx
		jnz		@@1
		jmp		@@9

@@RetNIL:
		xor		eax,eax
		jmp		@@Ret

@@7:
		mov		edi,edx	// Buf
		mov		ecx,ebx
	rep	movsb
@@9:
		stosb
		pop		edx
		mov		eax,edi
		pop		ebx
		pop		esi
		pop		edi
		sub		eax,edx
@@Ret:
	end;

begin
  len := Length(Src);
	if (len=0)or((MemScan(PChar(Src),len,'"')=nil)and(MemScan(PChar(Src),len,';')=nil)) then Result := Src
	else if len>MAXLEN then
		begin
			GetMem( ptr, (len shl 1)+2 );
			len := TextToBufCSV( PChar(Src), ptr, len );
			Result := Copy(ptr,1,len);
			FreeMem( ptr );
		end
	else
		begin
			len := TextToBufCSV( PChar(Src), buf, len );
			Result := Copy(buf,1,len);
		end;
end; {TextToCSV}
//-------------------------------------------------------------
// !!! buf указывает на область, длинной не менее len*3+2 !!!
function asmXquote( const Src : String; buf : PChar; const Tbl : String ) : Integer; assembler;
var	Table : Array [0..255] of Char;
asm
		push	edi
		push	esi
		push	ebx

		push	eax
  	test	ecx,ecx
  	jz		@DefaultTable
  	mov   esi,ecx
		mov		ecx,[esi-4]
		test	ecx,ecx
		jnz		@BuildTable
@DefaultTable:
		lea		esi,Printable
		mov		ecx,[esi-4]
@BuildTable:
// строим таблицу
  	lea		ebx,Table
  	mov		edi,ebx
  	mov		ecx,256
  	mov		eax,1
rep	stosb
		mov		ecx,[esi-4]
@NextChar:
  	lodsb
  	mov		Byte[ebx+eax],0
		loop	@NextChar
  	mov		Byte[ebx+''''],2
  	mov		Byte[ebx+'$'],2
  	pop		esi	// Src

// подготовка к циклу
		push	edx
  	mov		edi,edx
		mov		ecx,[esi-4]
		mov		Byte[edi],''''
		inc		edi
		jcxz	@End
		xor		edx,edx
// преобразование
@Next:
		xor		eax,eax
		lodsb
		mov		dl,al
  	xlat
  	jmp		@Vector.Pointer[eax*4]

@Vector:
		dd		@Skip
  	dd		@Escape
  	dd		@Double

@Escape:
		mov		Byte[edi],'$'
		inc		edi
		mov		eax,edx
		shr		eax,4
		and		dl,15
		mov		al,Byte[i2xtable+eax]
		mov   [edi],al
		inc		edi
		mov		al,Byte[i2xtable+edx]
		mov   [edi],al
		inc		edi
		loop	@Next
		jmp		@End

@Double:
		mov		[edi],dl
		inc		edi
@Skip:
		mov		[edi],dl
		inc		edi
		loop	@Next
@End:
		mov		Byte[edi],''''
		inc		edi
		pop		edx
		mov		eax,edi
		sub		eax,edx
		pop		ebx
		pop		esi
		pop		edi
end; {asmXquote}
//-------------------------------------------------------------
function XQuote( const Line, Table : String ) : String;
const	MAXLEN = 256;
var buf : Array [0..(MAXLEN*3+1)] of Char;
		ptr : PChar;
    len : Integer;
begin
	len := Length(Line);
	if len=0 then Result := ''''''
	else if len>MAXLEN then
		begin
			GetMem( ptr, len*3+2 );
			try
				len := asmXquote( Line, ptr, Table  );
				SetString(Result,ptr,len);
			finally
				FreeMem( ptr );
			end;
		end
	else
		begin
			len := asmXquote( Line, buf, Table );
			Result := Copy(buf,1,len);
		end;
end; {XQuote}
//-------------------------------------------------------------
function asmquote( src, buf : PChar; len : Integer ): Integer; assembler;
asm
{	test	eax,eax
  jz		@@Ret
  test	ecx,ecx  всегда ecx<>0 <- это уже проверено
  jnz		@@Start
	xor		eax,eax
	jmp		@@Ret
@@Start:}
	push	edi
	push	esi
	push	ebx
	push	edx
	mov		esi,eax
	mov		edi,edx
	mov		ebx,ecx
	mov		al,''''
	stosb
@@Loop:
	mov		edx,edi
	mov		edi,esi
	repne	scasb
	mov   ecx,edi
	sub		ecx,esi
	sub		ebx,ecx
	mov		edi,edx
	rep		movsb
	stosb
	mov		ecx,ebx
	test	ebx,ebx
	jnz		@@Loop
	pop		edx
	mov		eax,edi
	sub		eax,edx
	pop		ebx
	pop   esi
	pop		edi
@@Ret:
end;
//-------------------------------------------------------------
function Quote( const Line : String ) : String;
const	MAXLEN = 256;
var buf : Array [0..(MAXLEN*2+1)] of Char;
		ptr : PChar;
    len : Integer;
begin
	len := Length(Line);
	if len=0 then Result := ''''''
	else if len>MAXLEN then
		begin
			GetMem( ptr, len*2+2 );
			len := asmquote( PChar(Line), ptr, len );
			Result := Copy(ptr,1,len);
			FreeMem( ptr );
		end
	else
		begin
			len := asmquote( PChar(Line), buf, len );
			Result := Copy(buf,1,len);
		end;
end; {Quote}
//-------------------------------------------------------------
function NullQuote( const str : String ) : String;
begin
	if str='' then Result := 'NULL' else	Result := Quote(str);
end;

{---------------------------------------------------------------------------}
//                       EAX  EDX          ECX
function asmUnQuote( var src; buf : PChar; len : Integer ): Integer; assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
	PUSH	ESI
	PUSH	EDI
  PUSH	src
  MOV		EDI,buf
  MOV		ESI,[src]
  OR		ESI,ESI
  JZ		@@RetNIL
	LODSB
  CMP		AL,' '
  JC		@@RetNIL
  CMP		AL,''''
  JE		@@1	{ начинается с апострофа }
  CMP		AL,'"'
  JNE		@@UNQ	{ начинается не с апострофа и не с кавычки }
{ нормальная отквоченная строчка }
@@1:  MOV		AH,AL	{ сохраняем первый символ }
@@2:	LODSB
	CMP		AL,' '
  JC		@@Unmatch
  CMP		AL,AH
  JE		@@End
	CMP		AL,'$'
  JE		@@ESC
@@Store:
	STOSB
	LOOP	@@2
@@Overflow:	{ Ошибка - переполнение буфера }
	MOV		EAX,-1
  JMP		@@Abort

@@Unmatch:	{ Ошибка - нет завершающего апострофа или кавычки }
	MOV		EAX,-3
  JMP		@@Abort

@@ESC:
	LODSB
  CMP		AL,'$'
  JE		@@Store
  SUB		AL,'0'
  JC		@@ErrEsc
  CMP		AL,32
  JC		@@Store
@@ErrEsc:
	MOV		EAX,-2	{ Ошибка - неверный символ после # }
@@Abort:
	XOR		ESI,ESI	{ nil }
	JMP		@@Exit

@@NextUnq:
	LODSB
@@UNQ:
	CMP		AL,' '
  JC		@@DEC
	CMP		AL,','
  JE    @@DEC
	STOSB
  LOOP  @@NextUnq
  JMP		@@OverFlow

@@RetNil:
	XOR		EAX,EAX
	POP		EDI		{src}
	JMP		@@Ret0

@@End:
  LODSB
	CMP		AL,AH
	JE		@@Store
@@DEC:
	DEC		ESI
@@Result:
	MOV		EAX,EDI
  SUB		EAX,EDX
@@Exit:
	POP		EDI		{src}
	MOV		[EDI],ESI
@@Ret0:
  POP		EDI
	POP		ESI
@@Ret:
end;

//-------------------------------------------------------------
function QStrUnquoteBuf( src : String; buf : PChar ) : Integer; assembler;
var	pBufStart : Pointer;
asm
			test	eax,eax
			jz		@@Ret
			push	esi
			push	edi
			mov		edi,eax
			test	edi,edi
			jz		@@RetNil
			mov		ecx,[edi-4]
			test	ecx,ecx
			jz		@@RetNil
// Пропуск пробелов и табуляций
			mov		ax,2920h
@@SkipBlanks:
			repe	scasb
			je		@@RetNil
			dec		edi
			inc		ecx
			xor		al,ah
			cmp		al,[edi]
			je		@@SkipBlanks
// Начало сканирования //
			mov		esi,edi
			mov		edi,edx	{buf}
			mov		pBufStart,edx
			mov		edx,0
			mov		eax,0

// Неотквоченная строка
@@NextUnq:
			lodsb
@@Unquoted:
			cmp		al,''''
			je		@@Quoted
			cmp		al,'"'
			je		@@Quoted
			stosb
			loop  @@NextUnq
			jmp		@@Exit

@@Quoted:
			mov		dh,al	{ сохраняем разделитель - апостроф или кавычку }
			loop	@@Dequote
			jmp		@@Unmatch

@HexToBinTable:
			db		0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1
			db		-1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
			db		-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
			db		-1,10,11,12,13,14,15

// нормальная отквоченная строчка
@@Dequote:
			lodsb
			cmp		al,dh
			je		@@Quote
			cmp		al,'$'
			jne		@@Store
// Escape в отквоченной строчке
			dec		ecx
			jz		@@ErrEsc
			lodsb
			cmp		al,'$'
			je		@@Store
			cmp		al,'f'
			ja    @@ErrEsc
			sub		al,'0'
			jb    @@ErrEsc
			mov		dl,@HexToBinTable.Byte[eax]
			cmp		dl,-1
			je		@@ErrEsc
			shl		dl,4
			dec		ecx
			jz		@@ErrEsc
			lodsb
			cmp		al,'f'
			ja    @@ErrEsc
			sub		al,'0'
			jb    @@ErrEsc
			mov		al,@HexToBinTable.Byte[eax]
			cmp		al,-1
			je		@@ErrEsc
			or		al,dl
			jmp		@@Store

@@ErrESC:
			mov		eax,-2	{ Ошибка - неверный символ после $ }
			jmp		@@Ret0

// Кавычка или апостроф при сканировании отквоченной строчки
@@Quote:
			dec		ecx
			jz		@@Exit
			lodsb
			cmp		al,dh		// проверяем на двойную кавычку/апостроф
			jne		@@Unquoted
@@Store:
			stosb
@@Iterate:
			loop	@@Dequote
@@Unmatch:	{ Ошибка - нет завершающего апострофа или кавычки }
			mov		eax,-3
  		jmp		@@Ret0

@@RetNil:
			xor		eax,eax
			jmp		@@ret0

@@Exit:
			mov		eax,edi
			sub		eax,pBufStart
@@Ret0:
  		pop		edi
			pop		esi
@@Ret:
end;

function QStrUnquote( str : String ) : String;
const	MAXLEN = 1024;
var buf : Array [0..(MAXLEN-1)] of Char;
		ptr : PChar;
    len : Integer;
    Msg : String;
begin
	len := Length(str);
	Result := '';
	if len>MAXLEN then
		begin
			GetMem( ptr, len );
			try
				Len := QStrUnquoteBuf( str, ptr );
				if Len>0 then SetString(Result,ptr,Len);
			finally
				FreeMem( ptr );
			end;
		end
	else
		begin
			len := QStrUnquoteBuf( str, buf );
			if len>0 then	SetString(Result,buf,len);
		end;
	if len<0 then
	begin
  	case -len of
  	2: Msg := 'StrUnquote: Неверный символ после $';
  	3: Msg := 'StrUnquote: Непарный апостроф или кавычка';
  	else
    	Msg := 'StrUnquote: Неизвестная ошибка '+IntToStr(len);
  	end;
  	raise EStrConvError.Create( Msg );
	end;
end;


{---------------------------------------------------------------------------}
function UnQuote( var ptr : PChar ) : String;
const	MAXLEN=1024;
var	Len : Integer;
		buf : Array [0..(MAXLEN-1)] of Char;
    Msg : String;
begin
	ptr := SkipBlanks(ptr);
  Len := asmUnQuote(ptr,buf,MAXLEN);
  if Len<=0 then
	 begin
  	Result := '';
    if Len<0 then
    begin
	    ptr := nil;
	  	case -Len of
  	  1: Msg := 'UnQuote: Переполнение буфера';
    	2: Msg := 'UnQuote: Неверный символ после #';
	    3: Msg := 'UnQuote: Непарный апостроф или кавычка';
  	  else
    		Msg := 'Unquote: Неизвестная ошибка '+IntToStr(Len);
	    end;
  	  raise EStrConvError.Create( Msg );
    end;
	 end
  else	Result := Copy(buf,1,Len);
end;

{---------------------------------------------------------------------------}
function UnQuoteToken( var ptr : PChar ) : String;
begin
	Result := UnQuote( ptr );
  NextToken( ptr );
end;

{---------------------------------------------------------------------------}
{                  EAX  EDX          ECX }
function asmDeEsc( src, buf : PChar; len : Integer ): Integer; assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
  OR		ECX,ECX
  JZ		@@Ret0
	PUSH	ESI
	PUSH	EDI
  MOV		EDI,buf
  MOV		ESI,src
	MOV		AH,'#'
@@2:	LODSB
	CMP		AL,AH
  JNE		@@Store
	LODSB
  LOOP	@@3
@@ErrEsc:
	XOR		EAX,EAX
  DEC		EAX  { Ошибка - неверный символ после # }
	JMP		@@Exit

@@Ret0:
	XOR		EAX,EAX
  JMP		@@Ret

@@3:
	CMP		AL,AH
  JE		@@Store
  SUB		AL,'0'
  JC		@@ErrEsc
  CMP		AL,32
  JNC		@@ErrEsc
@@Store:
	STOSB
	LOOP	@@2
	MOV		EAX,EDI
  SUB		EAX,EDX
@@Exit:
  POP		EDI
	POP		ESI
@@Ret:
end;

{---------------------------------------------------------------------------}
function DeEsc( Str : String ) : String;
const	MAXLEN=1024;
var	Len : Integer;
		buf : Array [0..(MAXLEN-1)] of Char;
    ptr : PChar;

function DeEscBuf( src, ptrbuf : PChar; Len : Integer ) : String;
var	Msg : String;
begin
  Len := asmDeEsc(PChar(Str),ptrbuf,Length(Str));
  if Len<=0 then
	 begin
  	Result := '';
    if Len<0 then
    begin
	  	if Len =-1 then Msg := 'DeEscBuf: Неверный символ после #'
  	  else Msg := 'DeEscBuf: Неизвестная ошибка '+IntToStr(Len);
  	  raise EStrConvError.Create( Msg );
		end;
	 end
	else if Len = Length(Str) then Result:=Str
  else	Result := Copy(ptrbuf,1,Len);
end;

begin
	if Str='' then Result:=''
  else
	 begin
	  Len := Length(Str);
	  if Len>MAXLEN then
  	 begin
  		GetMem( ptr, Len );
			Result := DeEscBuf(PChar(Str),ptr,Len);
  	  FreeMem( ptr );
		 end
		else Result := DeEscBuf(PChar(Str),buf,Len);
	 end;
end;


{---------------------------------------------------------------------------}
{                      EAX  EDX          ECX }
function asmStripCRLF( src, buf : PChar; len : Integer ): Integer; assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
  OR		ECX,ECX
  JZ		@@Ret0
	PUSH	ESI
	PUSH	EDI
  MOV		EDI,buf
  MOV		ESI,src
	XOR		AH,AH
{ Цикл поиска CRLF }
@@FindCRLF:
	LODSB
	CMP		AL,13
  JE		@@CR
	CMP		AL,10
  JE		@@CR
@@Store:
  STOSB
  LOOP	@@FindCRLF
	JMP		@@Exit

@@StoreCR:
  MOV		BYTE PTR[EDI],13
  INC		EDI
  MOV		BYTE PTR[EDI],10
  INC		EDI
  JMP   @@Store

@@Ret0:
	XOR		EAX,EAX
  JMP		@@Ret

{ Цикл подавления пустых строк }
@@SkipCRLF:
	LODSB
  CMP		AL,10
  JE		@@CR
	CMP		AL,13
  JNE		@@StoreCR
@@CR:
  LOOP	@@SkipCRLF

@@Exit:
	MOV		EAX,EDI
  SUB		EAX,EDX
  POP		EDI
	POP		ESI
@@Ret:
end;

{---------------------------------------------------------------------------}
function StripCRLF( Str : String ) : String;
const	MAXLEN=1024;
var	Len : Integer;
		buf : Array [0..(MAXLEN-1)] of Char;
    ptr : PChar;

function StripCRLFBuf( src, ptrbuf : PChar; Len : Integer ) : String;
begin
  Len := asmStripCRLF(PChar(Str),ptrbuf,Length(Str));
  if Len=0 then Result := ''
	else if Len = Length(Str) then Result:=Str
  else	Result := Copy(ptrbuf,1,Len);
end;

begin
	if Str='' then Result:=''
  else
	 begin
	  Len := Length(Str);
	  if Len>MAXLEN then
  	 begin
  		GetMem( ptr, Len );
			Result := StripCRLFBuf(PChar(Str),ptr,Len);
  	  FreeMem( ptr );
		 end
		else Result := StripCRLFBuf(PChar(Str),buf,Len);
	 end;
end;

{---------------------------------------------------------------------------}
{function EncodeId( Origin, Id :Integer ) : String;
const table : array [0..63] of char =
	'@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_ abcdefghijklmnopqrstuvwxyz;<=>?';
var Res : Array [0..7] of Char;

function Encode6( val : Integer; ptr : PChar ):Pchar; assembler;
asm
  PUSH	EDI
	PUSH	EBX
  LEA		EBX,table
	MOV		ECX,4
  MOV		EDI,EDX
	MOV		EDX,EAX
  SHL		EDX,8
@@Next:
  SHLD	EAX,EDX,6
  SHL		EDX,6
  AND		EAX,63
	XLAT
  STOSB
  LOOP	@@Next
  MOV		EAX,EDI
	POP		EBX
	POP		EDI
end;

begin
  Encode6( Id, Encode6( Origin, Res ));
	Result := Copy( Res, 1, 8 );
end;}
//-------------------------------------------------------------
// вывод в hex как есть
function c2hex( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
asm
	push	esi
	push	edi
  push	eax
	mov		esi,edx
	mov		edi,eax
	xor		eax,eax
	xor		edx,edx
@@loop:
	lodsb
	mov		dl,al
	shr		al,4
	and		dl,15
	mov		al,byte ptr[i2xtable+eax]
	mov   [edi],al
	inc		edi
	mov		al,byte ptr[i2xtable+edx]
	mov   [edi],al
	inc		edi
	loop	@@loop
	mov		eax,edi
  pop		edx
  sub		eax,edx
	pop		edi
	pop		esi
end;
//-------------------------------------------------------------
// вывод в hex как есть + ведущие 0x
function c2x( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
asm
	push	esi
	push	edi
  push	eax
	mov		esi,edx
	mov		edi,eax
	xor		eax,eax
	xor		edx,edx
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
@@loop:
	lodsb
	mov		dl,al
	shr		al,4
	and		dl,15
	mov		al,byte ptr[i2xtable+eax]
	mov   [edi],al
	inc		edi
	mov		al,byte ptr[i2xtable+edx]
	mov   [edi],al
	inc		edi
	loop	@@loop
	mov		eax,edi
  pop		edx
  sub		eax,edx
	pop		edi
	pop		esi
end;
{---------------------------------------------------------------------------}
// вывод в hex в обратном порядке
function i2x( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
asm
	push	esi
	push	edi
  push	eax
	mov		esi,edx
  add		esi,ecx
  dec		esi
	mov		edi,eax
	xor		eax,eax
	xor		edx,edx
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	std
@@loop:
	lodsb
	mov		dl,al
	shr		al,4
	and		dl,15
	mov		al,byte ptr[i2xtable+eax]
	mov   [edi],al
	inc		edi
	mov		al,byte ptr[i2xtable+edx]
	mov   [edi],al
	inc		edi
	loop	@@loop
	cld
	mov		eax,edi
  pop		edx
  sub		eax,edx
	pop		edi
	pop		esi
end;
//-------------------------------------------------------------
function BinToHex( const ptr : Pointer; len : Integer ) : String;
begin
	SetLength(Result,(len+1)shl 1);
	c2x(PChar(Result),ptr,len);
end;
//-------------------------------------------------------------
// Вывод дампа
// размер буфера = (len*3)+((len-1) shr 2)-1
function DumpToBuf( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
asm
	push	esi
	push	edi
  push	eax
	push	ebx
	mov		esi,edx
	mov		edi,eax
	xor		eax,eax
	xor		ebx,ebx
	xor		edx,edx
	jmp		@@enter
@@loop:
	inc		bl
	mov		al,bl
	and		al,15
	jnz   @@1
	mov		word ptr [edi],$0a0d
	inc		edi
	jmp		@@2
@@1:
	mov		byte ptr [edi],' '
	inc		edi
	and		al,3
	jnz   @@enter
	mov		byte ptr [edi],' '
@@2:
	inc		edi
@@enter:
	lodsb
	mov		dl,al
	shr		al,4
	and		dl,15
	mov		al,byte ptr[i2xtable+eax]
	mov   [edi],al
	inc		edi
	mov		al,byte ptr[i2xtable+edx]
	mov   [edi],al
	inc		edi
	loop	@@loop
	mov		eax,edi
	pop		ebx
  pop		edx
  sub		eax,edx
	pop		edi
	pop		esi
end;
//-------------------------------------------------------------
function dump( ptr : Pointer; len : Integer ) : String;
begin
	Result := '';
	if (len<=0)or(ptr=nil) then Exit;
	SetLength(Result,(len*3)+((len-1) shr 2)-1);
	DumpToBuf(Pointer(Result),ptr,len);
end;
//-------------------------------------------------------------
// Result  > 0  -- success, result = length
// Result <= 0  -- error, result = neg(position) (from 0)
function hex2c( Dest, Src : Pointer; len : Integer ) : Integer; assembler;
asm
	test	eax,eax
	jz		@@Exit
	push	esi
	push	edi
	push	eax
	mov		edi,eax
	test	ecx,ecx
	jz		@@End
	mov		esi,edx
	xor		eax,eax
@@loop:
	lodsb
	cmp		al,'9'+1     //  '0'..'9'  -- 'A'..'F'  -- 'a'..'f'
	jnc		@@90
	sub		al,'0'
	jnc   @@char2
	cmp		al,' '-'0'
	je		@@iterate
@@error:
	pop		eax
	mov		eax,edx
	sub		eax,esi
	jmp		@@Break
@@90:
	cmp		al,'F'+1
	jc    @@F0
	cmp		al,'f'+1
	jnc		@@error
	sub		al,'a'
	jnc		@@A0
	jmp		@@error
@@F0:
	sub		al,'A'
	jc		@@error
@@A0:
	add		al,10
@@char2:
	dec		ecx
	jng		@@error
	shl		eax,4
	mov		ah,al
	lodsb
	cmp		al,'9'+1
	jnc		@@9
	sub		al,'0'
	jnc   @@poke
	jmp		@@error
@@9:
	cmp		al,'F'+1
	jc    @@F
	cmp		al,'f'+1
	jnc		@@error
	sub		al,'a'
	jnc		@@AF
	jmp		@@error
@@F:
	sub		al,'A'
	jc		@@error
@@AF:
	add		al,10
@@poke:
	or		al,ah
	stosb
@@iterate:
	loop	@@loop
@@End:
	pop		eax
	neg		eax
	add		eax,edi
@@Break:
	pop		edi
	pop		esi
@@Exit:
end;
//-------------------------------------------------------------
{function EncodeId( Origin, Id :Integer ) : String;
var	i64 : int64;
		buf : array [0..18] of char;
begin
	i64.Lo := Id; i64.Hi := Origin;
	SetString( Result,	buf, i2x(@buf,@i64,8) );
end;}
//-------------------------------------------------------------
{procedure DecodeId( var Origin,Id : Integer; ptr : PChar ); assembler;
asm
  PUSH	ESI
  MOV		ESI,ECX
	PUSH	EDX
  PUSH	EAX
	MOV		ECX,4
@@Next:
	LODSB
  SHL		EDX,6
  AND		EAX,63
  OR		EDX,EAX
  LOOP	@@Next
  POP		EAX
  MOV		DWORD PTR[EAX],EDX
	MOV		ECX,4
@@Next2:
	LODSB
  SHL		EDX,6
  AND		EAX,63
  OR		EDX,EAX
  LOOP	@@Next2
  POP		EAX
  MOV		DWORD PTR[EAX],EDX
	POP		ESI
end;}

{---------------------------------------------------------------------------}
function asmMacroExpand(
	src : String; dest : PChar; destlen : Integer;
	args : Array of string;  c : Char ) : Integer;
asm
	PUSH	ESI
  PUSH	EDI
  MOV		ESI,EAX		{src}
  OR		ESI,ESI
  JZ		@@Exit
	MOV		EDI,EDX 	{dest}
  OR		EDI,EDI
  JZ		@@BadParm
  PUSH	EDX
  MOV		EDX,ECX		{destlen}
  MOV		ECX,[ESI-4]	{length(src)}
  OR		ECX,ECX
  JZ		@@Ret0
  SUB		EDX,ECX
  JC		@@Overflow
  MOV		EAX,args
  OR		EAX,EAX
  JNZ		@@Start
@@BadParm:
  XOR		EAX,EAX
	DEC		EAX
  JMP		@@Exit

@@SkipLoop:
	LODSB
  CMP		AL,''''
  JE    @@Store
@@StoreQuote:
  STOSB
	LOOP	@@SkipLoop
  JMP		@@EndLoop

@@Start:
  MOV		AH,c
@@Loop:
	LODSB
  CMP		AL,''''
  JE		@@StoreQuote
  CMP		AL,AH
  JNE		@@Store
	INC		EDX
  DEC		ECX
  JECXZ @@EndLoop
  LODSB
  CMP		AL,AH
  JE		@@Store
  CMP		AL,'9'+1
  JNC		@@Store
  CMP		AL,'0'
  JC		@@Store
  SUB		AL,'0'
	PUSH	ESI
  PUSH	ECX
	MOVZX	ECX,AL
  CMP		ECX,args.Integer[-4]
  JA		@@BadNum
	MOV		ESI,args
	MOV		ESI,[ESI+ECX*4]
  OR		ESI,ESI
  JZ		@@Continue
  MOV		ECX,[ESI-4]
	OR		ECX,ECX
	JZ		@@Continue
	SUB		EDX,ECX
  JC		@@Overflow
  REP		MOVSB
@@Continue:
  POP		ECX
  POP		ESI
  MOV		AH,c
  JMP		@@Iterate

@@BadNum:
	POP		ECX
  POP		ESI
	XOR		EAX,EAX
	DEC		EAX
	DEC		EAX
	DEC		EAX
	JMP		@@Exit

@@Ret0:
	POP		EAX
  XOR		EAX,EAX
  JMP		@@Exit

@@Overflow:
  POP		EAX
  XOR		EAX,EAX
	DEC		EAX
	DEC		EAX
  JMP		@@Exit

@@Store:
  STOSB
@@Iterate:
	LOOP	@@Loop
@@EndLoop:
	MOV		EAX,EDI
  POP		EDX
  SUB		EAX,EDX
@@Exit:
	POP		EDI
  POP		ESI
end;

function MacroExpand( src: String; Args : Array of String; c : Char ):String;
const	MAXLEN=4096;
var	buf : Array [0..(MAXLEN-1)] of Char;
		len : Integer;
    Msg : String;
begin
  if src='' then Result := ''
  else
    begin
    	len := asmMacroExpand( src, buf, MAXLEN, Args, c );
    	if len<=0 then
        begin
    	 	  case -Len of
          1: Msg := 'MacroExpand: Неверный параметр';
          2: Msg := 'MacroExpand: Переполнение буфера';
         	3: Msg := 'MacroExpand: Неверный номер параметра';
    		  else
		    	  Msg := 'MacroExpand: Неизвестная ошибка '+IntToStr(Len);
      		end;
		      raise EStrConvError.Create( Msg );
    	  end
      else Result := Copy( buf, 1, len );
    end;
end;

{---------------------------------------------------------------------------}
function StrOpStr( const str1, op, str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then Result := '('+str1+')'+op+'('+str2+')'
  else
		if str1<>'' then Result := str1 else Result := str2;
end;
{---------------------------------------------------------------------------}
function StrAppendOpStr( var str1: string; const op, str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then
	 begin
		if PChar(str1)^='(' then	str1 := str1+op+'('+str2+')'
		else str1 := '('+str1+')'+op+'('+str2+')';
	 end
  else
		if str2<>'' then str1 := str2;
	Result := str1;
end;
{---------------------------------------------------------------------------}
function StrSpaceStr( const str1, op, str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then Result := str1+op+str2
  else
		if str1<>'' then Result := str1 else Result := str2;
end;
{---------------------------------------------------------------------------}
function Comma( const str1, str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then Result := str1+','+str2
  else
		if str1<>'' then Result := str1 else Result := str2;
end;
{---------------------------------------------------------------------------}
function CommaAppend( var str1: string; const str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then	str1 := str1+','+str2
  else if str2<>'' then str1 := str2;
	Result := str1;
end;
{---------------------------------------------------------------------------}
function LineAppend( var str1: string; const str2 : string ) : string;
begin
	if (str1<>'')and(str2<>'') then	str1 := str1+#13#10+str2
  else if str2<>'' then str1 := str2;
	Result := str1;
end;
{---------------------------------------------------------------------------}
function NextTokenLen( var ptr : PChar; var len : Integer ) : PChar; assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
  PUSH	EDI
  PUSH	EAX
  MOV		EDI,[EAX]
  OR		EDI,EDI
  JZ    @@RetNil
  MOV		ECX,[EDX]
  OR		ECX,ECX
  JZ		@@RetNil
	MOV		AX,', '
@@Skip:
  REPE	SCASB
	JE		@@RetNIL
	JCXZ	@@RetNIL
  JNC		@@Skip
  CMP		AH,[EDI-1]
  JE		@@Skip2
	JMP		@@RetEDI

@@RetNil:
	XOR		EAX,EAX
  MOV		[EDX],EAX
  POP		ECX
  MOV		[ECX],EAX
 	JMP		@@Ret0

@@Skip2:
  REPE	SCASB
	JE		@@RetNIL
	JCXZ	@@RetNIL
  JNC		@@Skip2
@@RetEDI:
	DEC		EDI
  INC		ECX
	MOV		EAX,EDI
  POP		EDI
  MOV		[EDI],EAX
  MOV		[EDX],ECX
@@Ret0:
	POP		EDI
@@Ret:
end;
{---------------------------------------------------------------------------}
function SkipBlanks( ptr : PChar ):PChar;assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
	PUSH	ESI
  MOV		ESI,EAX
	XOR		EAX,EAX
@@SkipSpaces:
	LODSB
	CMP		AL,' '
  JE		@@SkipSpaces
  CMP		AL,9
  JE		@@SkipSpaces
  OR		EAX,EAX
  JZ		@@RetNil
  DEC		ESI
	MOV		EAX,ESI
@@RetNil:
	POP		ESI
@@Ret:
end;
//-------------------------------------------------------------
// Пропускаем пробелы и символы табуляции
function SkipBlanksLen( var ptr : PChar; var len : Integer ) : PChar; assembler;
asm
	test	EAX,EAX
  JZ		@@Ret
	PUSH	EDI
  PUSH	EAX
	test	ECX,ECX
  MOV		EDI,[EAX]
  test	EDI,EDI
  JZ		@@RetNil
  test	EDX,EDX
  JZ		@@RetNil
  MOV		ECX,[EDX]
  test	ECX,ECX
  JLE		@@RetNil
	MOV		AX,2920h
@@SkipBlanks:
  REPE	SCASB
	JE		@@RetNIL
  DEC		EDI
  INC		ECX
	XOR		AL,AH
  CMP		AL,[EDI]
  JE		@@SkipBlanks
	JMP		@@RetEDI

@@RetNIL:
	XOR		EDI,EDI
@@RetEDI:
	POP		EAX
  XCHG	EAX,EDI
  MOV		[EDI],EAX
  MOV		[EDX],ECX
	POP		EDI
@@Ret:
end;
//-------------------------------------------------------------
// Удаляем концевые пробелы и символы табуляции
function RemoveTrailingBlanksLen( var ptr : PChar; var len : Integer ) : PChar; assembler;
asm
	test	eax,eax
  jz		@exit
  test	edx,edx
  jz		@exit
	push	edi
	push	esi
	mov		esi,eax
	test	ecx,ecx
  mov		edi,[eax]
  test	edi,edi
  jz		@RetNil
  mov		ecx,[edx]
  test	ecx,ecx
  jle		@RetNil
	mov		ax,2920h
	add		edi,ecx
	dec		edi
	std
@loop:
  repe	scasb
	je		@RetNil
  inc		edi
  inc		ecx
	xor		al,ah
  cmp		al,[edi]
  je		@loop
	jmp		@RetEDI
@RetNil:
	mov		dword ptr[esi],0
	xor		ecx,ecx
@RetEDI:
	cld
  mov		[edx],ecx
	mov		eax,[esi]
	pop		esi
	pop		edi
@exit:
end;

//-------------------------------------------------------------
// Пропускаем управляющие символы и пробелы ( все символы меньше $21 )
function FindLexLen( var ptr : PChar; var len : Integer ) : PChar; assembler;
asm
	test	eax,eax
  jz		@@Ret
	push	edi
  push	eax
	xor		ecx,ecx
  mov		edi,[eax]
  test	edi,edi
  jz		@@RetNil
  test	edx,edx
  jz		@@RetNil
  mov		ecx,[edx]
	mov		eax,20h
@@Skip:
	jcxz	@@RetNil
  repe	scasb
	je		@@RetNIL
  jnc		@@Skip
  dec		edi
  inc		ecx
	jmp		@@RetEDI
@@RetNIL:
	xor		edi,edi
@@RetEDI:
	pop		eax
  xchg	eax,edi
  mov		[edi],eax
  mov		[edx],ecx
	pop		edi
@@Ret:
end;

{---------------------------------------------------------------------------}
function Translate( const Str, sFrom, sTo : String; Pad : Char ) : String;
begin
	if (Str='')or(sFrom='') then Result := Str
	else
	 begin
		SetString( Result, PChar(Str), Length(Str) );
    AsmXLAT( Result, sFrom, sTo, Pad );
	 end;
end;

// Внимание!!! Изменяет значение указанной строки!!!
procedure AsmXLAT( Str : String; const sFrom, sTo : String; Pad : Char );
var	Table : Array [0..255] of Char;
asm
	OR		EAX,EAX
  JZ		@@Ret
  OR		EDX,EDX
  JZ		@@Ret
	PUSH	ESI
	PUSH	EDI
  PUSH	EBX
	MOV		ESI,[EAX-4]
  OR		ESI,ESI
  JZ		@@Ret0
	MOV		ESI,[EDX-4]
  OR		ESI,ESI
  JZ		@@Ret0
// строим таблицу
	PUSH	EAX
  PUSH	ECX
  LEA		EBX,table
  MOV		EDI,EBX
  XOR		EAX,EAX
@@FillTBL1:
  STOSB
  INC		AL
  JNZ 	@@FillTBL1
  POP		EDI
  MOV		ESI,EDX
  MOV		EDX,[EDX-4]
  OR		EDI,EDI
  JZ		@@FillTBL3
  MOV		ECX,[EDI-4]
  SUB		EDX,ECX
  JC		@@100
  MOV		ECX,[ESI-4]
  XOR		EDX,EDX
@@100:
	OR		ECX,ECX
  JZ		@@FillTBL3
@@FillTBL2:
  LODSB
	LEA		EBX,Table.[EAX]
  MOV		AL,[EDI]
	MOV		[EBX],AL
  INC		EDI
	LOOP	@@FillTBL2
@@FillTBL3:
  LEA		EBX,Table
	MOV		ECX,EDX
  OR		ECX,ECX
  JZ		@@FillTBL9
	MOV		DL,Pad
  XOR		EAX,EAX
@@FillTBL4:
  LODSB
	MOV		[EAX+EBX],DL
	LOOP	@@FillTBL4
// Цикл перекодировки
@@FillTBL9:
	POP		EDI
  MOV		ECX,[EDI-4]
@@NextChar:
	MOV		AL,[EDI]
	XLAT
	STOSB
  LOOP	@@NextChar
@@Ret0:
	POP		EBX
	POP		EDI
  POP		ESI
@@Ret:
end;
//-------------------------------------------------------------
//  op=0 - Scan, op<>0 - Skip }
function QScanSkipChars( ptr : PChar; len : Integer; chars : String; op : Integer ) : Integer;
var	Table : Array [0..255] of Char;
asm
		test	eax,eax	// ptr
		jz		@@Ret
		test	edx,edx	// len
		jz		@@RetNil
		push	esi
		push	edi
		push	ebx
		test	ecx,ecx	// chars
		jz		@@Ret0
		mov   esi,ecx
		mov		ecx,[esi-4] // length(chars)
		test	ecx,ecx
		jz		@@Ret0
		// строим таблицу
		push	eax
		lea		ebx,Table
		mov		edi,ebx
		mov		ecx,256
		xor		eax,eax
rep	stosb
		mov		[ebx+''''].Byte,2
		mov		[ebx+'"'].Byte,2
		mov		ecx,[esi-4]
@@NextChar:
		lodsb
		mov		[ebx+eax].Byte,1
		loop	@@NextChar
		pop		esi		{ptr}
		mov		edi,esi
		mov		ecx,edx
		lea		edx,@@VectorScan
		mov		eax,op
		test	eax,eax
		jz    @@Next
		lea		edx,@@VectorSkip
		cmp		[ebx+''''].Byte,1
		jne		@@1
		mov		[ebx+''''].Byte,2
		jmp		@@2
@@1:mov		[ebx+''''].Byte,0
@@2:cmp		[ebx+'"'].Byte,1
  	jne		@@3
  	mov		[ebx+'"'].Byte,2
		jmp		@@Next
@@3:mov		[ebx+'"'].Byte,0

@@Next:
		lodsb
		xlat
		jmp		[edx].Pointer[eax*4]

@@VectorSkip:
		dd		@@Exit
		dd		@@IterateSkip
		dd		@@SkipQuoted

@@VectorScan:
		dd		@@IterateScan
		dd		@@Exit
		dd		@@SkipQuoted

@@RetNIL:
		xor		eax,eax
		jmp		@@Ret

@@IterateScan:
		loop	@@Next
@@Ret0:
  	xor		eax,eax
		jmp		@@RetEAX

@@SkipQuoted:
		dec		ecx
		jcxz	@@Ret0
  	dec		esi
  	lodsb
  	xchg	edi,esi
		repne	scasb
  	xchg	esi,edi
  	jne		@@Ret0
  	jmp		@@Next

@@IterateSkip:
  	loop	@@Next
		inc		esi
@@Exit:
		mov		eax,esi
		sub		eax,edi
@@RetEAX:
		pop		ebx
		pop		edi
  	pop		esi
@@Ret:
end;

function QScanChars( ptr:PChar; len:Integer; chars : String )	: Integer;
begin
	Result := QScanSkipChars(ptr,len,chars,0);
end;
function QSkipChars( ptr:PChar; len:Integer; chars : String )	: Integer;
begin
	Result := QScanSkipChars(ptr,len,chars,1);
end;

//-------------------------------------------------------------
// Line - source string
// NoQuote - if all charecters in source string are from NoQuote, then output without quoting ( Result <= Line )
// NoEscape - do not escape characters from NoEscape when quoting
function ConditionalQuote( const Line : String; NoQuote : String; NoEscape : String ) : String;
var len : Integer;
begin
  len := Length(Line);
	if len=0 then Result := ''''''
	else
		begin
			if NoQuote='' then NoQuote := AlphaNum;
			if QScanSkipChars(PChar(Line),len,NoQuote,1)>len then Result := Line
			else if NoEscape='' then Result := XQuote(Line,Printable1251)
			else Result := XQuote(Line,NoEscape);
		end;
end;
//-------------------------------------------------------------
function CfgQuote( const Line : String ) : String;
var len : Integer;
begin
  len := Length(Line);
	if len=0 then Result := ''''''
	else if QScanSkipChars(PChar(Line),len,CfgAllowedChars,1)>len then Result := Line
	else Result := XQuote(Line,Printable1251);
end;
//-------------------------------------------------------------
// Извлекаем строку до первого символа, не входящего в AllowedChars, этот символ будет выдан в ATerm.
// Если все символы из AllowedChars, то ATerm будет #0
function GetTerm( var ptr : PChar; var len : Integer; var ATerm : Char; AllowedChars : String ) : String;
var	i : Integer;
begin
	Result := '';
	ATerm := #0;
	if AllowedChars='' then AllowedChars := AlphaNum2;
	i := QScanSkipChars( ptr, len, AllowedChars, 1 );{skip}
  if i>0 then
		begin
			Dec(i);
			if i<>0 then
      begin
  			Result := Copy(ptr,1,i);
	  		Inc(ptr,i);
		  	Dec(len,i)
      end;
			ATerm := ptr^;
		end
  else
		begin
			Result := Copy(ptr,1,len);
			ptr := nil;
			len := 0;
		end;
end;
//-------------------------------------------------------------
// Если первый значимый символ - апостроф или кавычка, то будет возвращена расквоченная строка,
// иначе извлекает строку до терминатора, а пробелы/табуляции с обоих сторон будут удалены.
// Пара ptr/len будет указывать на символ-терминитор
function GetStringTerm( var ptr : PChar; var len : Integer; ATerminators : String ) : String;
var	i : Integer;
		pValue : PChar;
begin
	Result := '';
	if SkipBlanksLen(ptr,len)=nil then Exit;
  if (ptr^='''')or(ptr^='"') then
  	begin
			i := QScanSkipChars( ptr, len, '''"', 1 ); {skip}
  		if i>0 then
				begin
					Dec(i);
					if i=0 then Exit
					else Result := QStrUnquote(Copy(ptr,1,i));
					Inc(ptr,i);
					Dec(len,i);
					if len>0 then Exit;
				end
			else Result := QStrUnquote(Copy(ptr,1,len));
		end
	else
		begin
			if ATerminators='' then	ATerminators := DefaultStringTerminators;
			i := QScanSkipChars( ptr, len, ATerminators, 0 ); {scan}
			if i>0 then
				begin
					Dec(i);
					if i=0 then Exit;
					pValue := ptr;
					Inc(ptr,i);
					Dec(len,i);
					if RemoveTrailingBlanksLen(pValue,i)<>nil then SetString(Result,pValue,i);
					if len>0 then Exit;
				end
			else if RemoveTrailingBlanksLen(ptr,len)<>nil then SetString(Result,ptr,len);
		end;
	ptr := nil;
	len := 0;
end;
//-------------------------------------------------------------
// Если первый значимый символ - апостроф или кавычка, то будет возвращена расквоченная строка,
// иначе извлекает строку до первого недопустимого симола.
// Пара ptr/len будет указывать на первый символ, не входящий в число допустимых
function GetStringAlpha( var ptr : PChar; var len : Integer; AllowedChars : String ) : String;
var	i : Integer;
begin
	Result := '';
	if SkipBlanksLen(ptr,len)=nil then Exit;
  if (ptr^='''')or(ptr^='"') then
  begin
		i := QScanSkipChars( ptr, len, '''"', 1 ); {skip}
		if i>0 then
			begin
				Dec(i);
				if i=0 then Exit
				else Result := QStrUnquote(Copy(ptr,1,i));
				Inc(ptr,i);
				Dec(len,i)
			end
		else
			begin
				Result := QStrUnquote(Copy(ptr,1,len));
				ptr := nil;
				len := 0;
			end;
		Exit;
	end;
	if AllowedChars='' then AllowedChars := AlphaNum2;
	i := QScanSkipChars( ptr, len, AllowedChars, 1 ); {skip}
	if i>0 then
	begin
		Dec(i);
		if i=0 then Exit
		else Result := Copy(ptr,1,i);
		Inc(ptr,i);
		Dec(len,i);
		if len<=0 then ptr := nil;
	end;
end;
//-------------------------------------------------------------
function GetCfgKey( var ptr : PChar; var len : Integer ) : String;
const	CfgKeyTerminators : String = '=~:;#\/'#9#10#13#0;
var	i : Integer;
begin
	Result := '';
	if SkipBlanksLen(ptr,len)=nil then Exit;
  if (ptr^='''')or(ptr^='"') then
	begin
		i := QScanSkipChars( ptr, len, '''"', 1 ); {skip}
		if i>0 then
			begin
				Dec(i);
				if i=0 then Exit
				else Result := QStrUnquote(Copy(ptr,1,i));
				Inc(ptr,i);
				Dec(len,i)
			end
		else
			begin
				Result := QStrUnquote(Copy(ptr,1,len));
				ptr := nil;
				len := 0;
			end;
		Exit;
	end;
	i := QScanSkipChars( ptr, len, CfgKeyTerminators, 0 ); {scan}
	if i>0 then
		begin
			Dec(i);
			Dec(len,i);
			if (i=0)or(RemoveTrailingBlanksLen(ptr,i)=nil) then
			begin
				len := 0;
				Exit;
			end;
			Result := Copy(ptr,1,i);
			Inc(ptr,i);
		end
	else if RemoveTrailingBlanksLen(ptr,len)=nil then Exit
	else
		begin
			Result := Copy(ptr,1,len);
			ptr := nil;
			len := 0;
		end;
end;
//-------------------------------------------------------------
// Если первый значимый символ - апостроф или кавычка, то будет возвращена расквоченная строка,
// иначе извлекает строку до терминатора ( символ из DefaultStringTerminators ).
// Пара ptr/len будет указывать на символ-терминитор
function GetString( var ptr : PChar; var len : Integer ) : String;
begin
	Result := GetStringTerm(ptr,len,DefaultStringTerminators);
end;
//-------------------------------------------------------------
// Ищем терминатор, Result = строка до терминатора или исходная строка
// Строки не расквочиваются.
function GetSubStr( var ptr : PChar; var len : Integer; const ATerminators : String ) : String;
type	PWord = ^Word;
var	i : Integer;
begin
	Result := '';
	if (ptr=nil)and(len<=0) then Exit;
	i := QScanSkipChars( ptr, len, ATerminators, 0 ); {scan}
  if i<1 then
	begin
		SetString(Result,ptr,len);
		ptr := nil;
		len := 0;
		Exit;
	end;
	Dec(len,i);
	Dec(i);
	if i>0 then SetString(Result,ptr,i) else Result :='';
	Inc(ptr,i+1);
end;
//-------------------------------------------------------------
const ScanCRLF : String = #10#13#0;
//-------------------------------------------------------------
// Извлекает строчку - до очередного CRLF.  ptr,len будут указазывать ЗА CRLF
function GetLine( var ptr : PChar; var len : Integer ) : String;
type	PWord = ^Word;
var	i : Integer;
begin
	if (ptr=nil)and(len<=0) then
	begin
		Result := '';
		Exit;
	end;
	i := QScanSkipChars( ptr, len, ScanCRLF, 0 ); {scan}
  if i<1 then
	begin
		SetString(Result,ptr,len);
		ptr := nil;
		len := 0;
		Exit;
	end;
	Dec(len,i);
	Dec(i);
	if i>0 then SetString(Result,ptr,i) else Result :='';
	Inc(ptr,i);
	if PWord(ptr)^=$0A0D then
	begin
		Inc(ptr);
		Dec(len);
	end;
	Inc(ptr);
end;
//-------------------------------------------------------------
function NextLine( var ptr : PChar; var len : Integer ) : PChar;
const CRxorLR : Byte = Byte(#10) xor Byte(#13);
label ExitLen0;
var	i : Integer;
begin
	if ptr=nil then goto ExitLen0;
	i := QScanSkipChars( ptr, len, ScanCRLF, 0 ); {scan}
  if i<=0 then goto ExitLen0;
	Inc(ptr,i);
 	Dec(len,i);
	if len<=0 then goto ExitLen0;
	if ptr^=Char( CRxorLR xor Byte((ptr-1)^)) then
	begin
		Inc(ptr);
 		Dec(len);
	end;
	if len<=0 then goto ExitLen0;
	Result := ptr;
	Exit;

ExitLen0:
	len := 0;
	ptr := nil;
	Result := nil;
end;

//-------------------------------------------------------------
function GetInteger( var ptr : PChar; var len : Integer ) : Integer;
var n : Integer;
begin
	if (SkipBlanksLen(ptr,len)=nil)or(ptr^<' ') then Result := 0
	else
		begin
			Val(ptr,Result,n);
			if n>0 then
				begin
					Dec(n);
					Inc(ptr,n);
					Dec(len,n);
				end
			else
				begin
					Inc(ptr,len);
					len := 0;
				end;
		end;
end;
//-------------------------------------------------------------
function GetInt64Def( var ptr:PChar; var len:Integer; const ADefaultValue : Int64 ) : Int64;
var i : Integer;
begin
	if (SkipBlanksLen(ptr,len)=nil) or not(ptr^ in ['0'..'9','$']) then Result := ADefaultValue
	else
		begin
			if ptr^='$' then
				begin
					i := QScanSkipChars( ptr+1, len-1, HexDigits, 1 );{skip}
    			if i=1 then raise EStrConvError.Create( 'GetInt64Def: Invalid hex value' );
					if i<=0 then i := len;
				end
			else
				begin
					i := QScanSkipChars( ptr+1, len-1, DecimalDigits, 1 );{skip}
  				if i<=0 then i := len;
				end;
			Result := StrToInt64( Copy(ptr,1,i) );
			Dec(len,i);
  		Inc(ptr,i);
		end;
end;
//-------------------------------------------------------------
function GetInt64( var ptr : PChar; var len : Integer ) : Int64;
label InvalidValue;
var i : Integer;
begin
	if (SkipBlanksLen(ptr,len)<>nil) and (ptr^ in ['0'..'9','$']) then
	begin
		if ptr^='$' then
			begin
				i := QScanSkipChars( ptr+1, len-1, HexDigits, 1 );{skip}
    		if i=1 then goto InvalidValue;
				if i<=0 then i := len;
			end
		else
			begin
				i := QScanSkipChars( ptr+1, len-1, DecimalDigits, 1 );{skip}
  			if i<=0 then i := len;
			end;
		Result := StrToInt64( Copy(ptr,1,i) );
		Dec(len,i);
  	Inc(ptr,i);
		Exit;
	end;
InvalidValue:
	raise EStrConvError.Create( 'GetInt64: Invalid Int64 value' );
end;
//-------------------------------------------------------------
function GetIntegerDef( var ptr : PChar; var len : Integer; const ADefaultValue : Integer ) : Integer;
var n : Integer;
begin
  if (SkipBlanksLen(ptr,len)=nil)or(ptr^<' ') then Result := ADefaultValue
  else
		begin
			Val(ptr,Result,n);
			if n>0 then
				begin
					Dec(n);
					if n=0 then Result := ADefaultValue;
					Inc(ptr,n);
					Dec(len,n);
				end
			else
				begin
					Inc(ptr,len);
					len := 0;
				end;
		end;
end;
//-------------------------------------------------------------
function GetIntegerArray( var ptr : PChar; var len : Integer; ATerminators : String ) : TArrayOfInteger;
const
	DefaultTerminators : String = ')'#10#13#0;
	iMaxTemp = 64;
	iTempBufSize = iMaxTemp*SizeOf(Integer);
label Error;
var n, m, i, k : Integer;
		aTemp : Array [0..iMaxTemp-1] of Integer;
begin
	Result := nil;
	if SkipBlanksLen(ptr,len)=nil then Exit;
	if ATerminators='' then ATerminators := DefaultTerminators;
	if MemScan( PChar(ATerminators), Length(ATerminators), ptr^ )<>nil then Exit;
	k := 0;
	i := 0;
	repeat
		Val(ptr,n,m);
		if m>0 then
			begin
				Dec(m);
				if m=0 then goto Error;
				Inc(ptr,m);
				Dec(len,m);
			end
		else
			begin
				Inc(ptr,len);
				len := 0;
			end;
		aTemp[i] := n;
		Inc(i);
		if i=iMaxTemp then
		begin
			m := k;
			Inc(k,iMaxTemp);
			SetLength(Result,k);
			System.Move( aTemp, (PChar(Result)+m*SizeOf(Integer))^, iTempBufSize );
			i := 0;
		end;
		if (len=0)or(MemScan( PChar(ATerminators), Length(ATerminators), ptr^ )<>nil) then Break;
		if (ptr^>=' ')and(ptr^<>',')and(ptr^<>';') then goto Error;
		Inc(ptr);
		Dec(len);
	until SkipBlanksLen(ptr,len)=nil;
	if i>0 then
	begin
		m := k;
		Inc(k,i);
		SetLength(Result,k);
		System.Move( aTemp, (PChar(Result)+m*SizeOf(Integer))^, i*SizeOf(Integer) );
	end;
	Exit;
Error:
	raise EStrConvError.Create( 'StrToIntegerArray: Unappropriate symbol '''+ptr^+'''('+IntToHex(Ord(ptr^),2)+')' );
end;
//-------------------------------------------------------------
function StrToIntegerArray( const S : String ) : TArrayOfInteger;
label Error;
var ptr : PChar;
		len, n, i, k : Integer;
begin
	Result := nil;
	if S='' then Exit;
	k := 0;
	ptr := PChar(S);
	len := Length(S);
	while FindLexLen(ptr,len)<>nil do
	begin
		Val(ptr,n,i);
		if i>0 then
			begin
				Dec(i);
				if i=0 then goto Error;
				Inc(ptr,i);
				Dec(len,i);
			end
		else
			begin
				Inc(ptr,len);
				len := 0;
			end;
		i := k;
		Inc(k);
		SetLength(Result,k);
		Result[i] := n;
		if len=0 then Break;
		if (ptr^>=' ')and(ptr^<>',')and(ptr^<>';') then goto Error;
		Inc(ptr);
		Dec(len);
	end;
	Exit;
Error:
	raise EStrConvError.Create( 'StrToIntegerArray: Unappropriate symbol '''+ptr^+'''('+IntToHex(Ord(ptr^),2)+')' );
end;
//-------------------------------------------------------------
function IntegerArrayToStr( const A : TArrayOfInteger ) : String;
var i : Integer;
begin
	if Length(A)=0 then Result := ''
	else
		begin
			Result := IntToStr(A[0]);
			for i := 1 to Length(A)-1 do Result := Result + ',' + IntToStr(A[i]);
		end;
end;
{---------------------------------------------------------------------------}
function GetNumVariant( var ptr:PChar; var len:Integer ) : Variant;
const Numbers:String = '012345789';
var	i,n : Integer;
		c, first : Char;
begin
	Result := Null;
	if SkipBlanksLen(ptr,len)=nil then Exit;
  first := ptr^;
  if first<>'-' then	i := QScanSkipChars( ptr, len, Numbers, 1 ) {skip}
	else i := QScanSkipChars( ptr+1, len-1, Numbers, 1 ); {skip}
  if i<=0 then
  begin
    Val(ptr,i,n);
    Result := i;
    ptr := nil;
    len := 0;
    Exit;
	end;
	if first<>'-' then Dec(i);
	if i=0 then Exit;
  c:= (ptr+i)^;
  if (first<>'-')and(i<=2)and((c=':')or(c='.')or(c='/')) then
  begin
		n := QScanSkipChars( ptr, len, '012345789:/. ', 1 ); {skip}
    if n=0 then n:=len;
    if (n>=8)and((ptr+i+3)^=c) then
    begin
    	Dec(n);
			Result := StrToDateTime(Copy(ptr,1,n));
	    Inc(ptr,n);
  	  Dec(len,n);
      Exit;
		end;
  end;
  if c='.' then
  begin
    Inc(i);
		n := QScanSkipChars( ptr+i, len-i, Numbers, 1 ); {skip}
    if n=0 then n:=len
		else Dec(n);
    Inc(n,i);
		Result := StrToFloat(Copy(ptr,1,n));
    Inc(ptr,n);
 	  Dec(len,n);
    Exit;
  end;
	Result := StrToInt(Copy(ptr,1,i));
  Inc(ptr,i);
  Dec(len,i);
end;
//=============================================================
// ищем символ (с пониманием кавычек)
function QMemScan( ptr : PChar; len : Integer; c : Char ) : PChar;
asm
	test	eax,eax
  jz		@@Ret
	push	esi
  mov		esi,eax	// esi <- ptr
	mov		eax,ecx
  mov		ah,al		// ah <- al <- c
  mov		ecx,edx	// ecx <- len
	test	ecx,ecx
  jz		@@Ret0
@@Next:	// ??????? Оптимизировать ?
	lodsb
	cmp		al,ah
  je		@@Exit
  cmp		al,''''
  je		@@SkipQuoted
  cmp		al,'"'
  je		@@SkipQuoted
  loop	@@Next
	jmp		@@Ret0

@@skipQuoted:
	dec		ecx
	jcxz	@@Ret0
  xchg	esi,edi
	repne	scasb
  xchg	esi,edi
  je		@@Next
@@Ret0:
  xor		esi,esi
@@Exit:
  mov		eax,esi
	pop		esi
@@Ret:
end;

{---------------------------------------------------------------------------}
function QStrScan( str : String; c : Char ) : Integer;
asm
	test		EAX,EAX
  JZ		@@Ret
	PUSH	ESI
  MOV		ESI,EAX
  MOV		ECX,[EAX-4]
	test		ECX,ECX
  JZ		@@Ret0
  XCHG	EDX,EAX
  MOV		AH,AL
@@Next:
	LODSB
	CMP		AL,AH
  JE		@@Exit
  CMP		AL,''''
  JE		@@SkipQuoted
  CMP		AL,'"'
  JE		@@SkipQuoted
  LOOP	@@Next
@@Ret0:
  XOR		EAX,EAX
	JMP		@@RetEAX

@@SkipQuoted:
	DEC		ECX
	JCXZ	@@Ret0
  XCHG	ESI,EDI
	REPNE	SCASB
  XCHG	ESI,EDI
  JNE		@@Ret0
  JMP		@@Next

@@Exit:
  MOV		EAX,ESI
	SUB		EAX,EDX
@@RetEAX:
	POP		ESI
@@Ret:
end;

function QStrSplit( var str : String; c : char ) : String;
var	n, l : Integer;
begin
	n := QStrScan( str, c );
  if n=0 then
   begin
    Result := QStrUnquote( str );
  	str := '';
   end
	else
   begin
		Result := QStrUnquote( Copy( str, 1, n-1 ));
    l := Length(str)-n;
    if l>0 then str := Copy( str, n+1, l )
    else	str := '';
   end;
end;

{---------------------------------------------------------------------------}
function NextToken( var ptr : PChar ) : PChar; assembler;
asm
	OR		EAX,EAX
  JZ		@@Ret
	PUSH	ESI
  MOV		ESI,[EAX]
  OR		ESI,ESI
  JZ    @@RetZero
  PUSH	EAX
@@SkipSpaces1:
	LODSB
	CMP		AL,' '
  JE		@@Next1
  JNC		@@TestComma
  CMP		AL,9
  JNE		@@ControlChar
@@Next1:
  LOOP	@@SkipSpaces1
	JMP		@@Exit0

@@ControlChar:
	OR		EAX,EAX
  JZ		@@RetNil
	CMP		AL,13
  JE		@@RetNil
	CMP		AL,10
  JNE		@@Exit
@@RetNil:
  POP		EAX
  DEC		ESI
  MOV		[EAX],ESI
@@RetZero:
	XOR		EAX,EAX
 	JMP		@@Ret0

@@TestComma:
	CMP		AL,','
  JE    @@SkipSpaces2
	CMP		AL,';'
	JNE		@@Exit
@@SkipSpaces2:
	LODSB
	CMP		AL,' '
  JE		@@Next2
  JNC		@@Exit
  CMP		AL,9
  JNE		@@ControlChar
@@Next2:
  LOOP	@@SkipSpaces2
@@Exit0:
	XOR		ESI,ESI
  JMP		@@RetESI

@@Exit:
	DEC		ESI
@@RetESI:
	MOV		EAX,ESI
  POP		ESI
  MOV		[ESI],EAX
@@Ret0:
	POP		ESI
@@Ret:
end;

function GetTokenInteger(var ptr:PChar):Integer;
var n:Integer;
begin
	ptr := SkipBlanks(ptr);
  if (ptr=nil)or(ptr^<' ') then Result:=0
  else
   begin
    Val(ptr,Result,n);
    ptr:=ptr+n;
		NextToken(ptr);
   end;
end;

function GetIntegers(ptr:PChar;Arg:Array of PInteger):PChar;
var i,n:Integer;
begin
  for i:=Low(Arg) to High(Arg) do
  begin
    Arg[i]^ := GetTokenInteger(ptr);
    if ptr=nil then break;
    Val(ptr,Arg[i]^,n);
    ptr:=ptr+n;
  end;
  Result:=ptr;
end;

//-------------------------------------------------------------
function SpellCurrency( ANum : Currency ) : String;
type
	TUnitGender = ( ugMale, ugFemale );
const
		female : Array[1..2] of String = ('одна','две');
		upto20 : Array[1..20] of String =
			('один','два','три','четыре','пять','шесть','семь','восемь','девять','десять',
			'одиннадцать','двенадцать','тринадцать','четырнадцать','пятнадцать','шестнадцать','семнадцать','восемнадцать','девятнадцать','двадцать');
		decades: Array [2..9] of String = ('двадцать','тридцать','сорок','пятьдесят','шестьдесят','семьдесят','восемьдесят','девяносто');
		hundreds: Array [1..9] of String = ('сто','двести','триста','четыреста','пятьсот','шестьсот','семьсот','восемьсот','девятсот');
var n, m, i : LongInt;
		s : String;

	function SpellUpTo1000( const AGender : TUnitGender ) : String;
	var	k, h : Integer;
	begin
		k := m mod 100;
		h := m div 100;
		if h=0 then Result := '' else Result := hundreds[h];
		if k>20 then
		begin
			h := k div 10;
			k := k mod 10;
			Result := StrSpaceStr(Result,' ',decades[h]);
		end;
		if k<>0 then
			if (k<3)and(AGender=ugFemale) then Result := StrSpaceStr(Result,' ',female[k])
			else Result := StrSpaceStr(Result,' ',upto20[k]);
	end;

	procedure SpellNum( var Res : String; AUnits : Array of String; const AGender : TUnitGender );
	begin
		i := n mod 100;
		if (i>20)or(i<10) then
			case i mod 10 of
			1: s := AUnits[0];
			2,3,4: s := AUnits[1];
			else
				s := AUnits[2];
			end
		else s := AUnits[2];
		m := n mod 1000;
		n := n div 1000;
		Res := StrSpaceStr( SpellUpTo1000(AGender)+' '+s,' ',Res);
	end;

begin
	n := Trunc(ANum);
	if n=0 then Result := 'Ноль рублей'
	else
		begin
			Result := '';
			SpellNum(Result,['рубль','рубля','рублей'],ugMale);
			if n<>0 then
			begin
				SpellNum(Result,['тысяча','тысячи','тысяч'],ugFemale);
				if n<>0 then
				begin
					SpellNum(Result,['миллион','миллиона','миллионов'],ugMale);
					if n<>0 then SpellNum(Result,['миллиард','миллиарда','миллиардов'],ugMale);
				end;
			end;
		end;
	n := Trunc(ANum*100) mod 100;
	if n<10 then s := '0'+Chr(Ord('0')+n) else s := IntToStr(n);
	if (n>20)or(n<10) then
		case n mod 10 of
		1: s := s+' копейка';
		2,3,4: s := s+' копейки';
		else
			s := s+' копеек';
		end
	else s := s+' копеек';
	CharUpperBuff( PChar(Result), 1 );
	Result := Result+' '+s;
end;
//-------------------------------------------------------------
function RoundCents( const ACurr : Currency ) : Currency;
var	D : Currency;
begin
	D := ACurr/100;
	Result := D*100;
end;
//-------------------------------------------------------------
function SpellDate( const ADate : TDateTime ) : String;
const aMonth : array [1..12] of String = ('января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря');
var	wYear, wMonth, wDay : Word;
begin
	DecodeDate( ADate, wYear, wMonth, wDay );
	Result := IntToStr(wDay)+' '+aMonth[wMonth]+' '+IntToStr(wYear);
end;
//-------------------------------------------------------------
function IncMonth( ADate : TDateTime; const AMonthes : Integer ) : TDateTime;
const aMonth : array [1..12] of Byte = (31,28,31,30,31,30,31,31,30,31,30,31);
var	wYear, wMonth, wDay : Word;
		iMonth : Integer;
begin
	if Trunc(ADate)=0 then ADate := Now;
	DecodeDate( ADate, wYear, wMonth, wDay );
	iMonth := Integer(wMonth-1)+AMonthes;
  if iMonth>=0 then wMonth := (iMonth mod 12) + 1
	else
		begin
			wMonth := (iMonth mod 12) + 13;
      Dec(wYear);
		end;
	if (wDay>aMonth[wMonth])and((wMonth<>2)or(wDay<>29)or((wYear mod 4)<>0)or(wYear=2000)) then	wDay := aMonth[wMonth];
	Inc(wYear,iMonth div 12);
	Result := EncodeDate(wYear,wMonth,wDay)+Frac(ADate);
end;

end.

