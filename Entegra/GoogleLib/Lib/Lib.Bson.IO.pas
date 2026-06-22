unit Lib.Bson.IO;
(*< JSON and BSON reading and writing.

  @bold(Quick Start)

  Consider this JSON document:

  @preformatted(
    { "x" : 1,
      "y" : 2,
      "z" : [ 3.14, true] }
  )

  You can serialize it manually to BSON like this:

  <source>
  var
    Writer: IBsonWriter;
    Bson: TBytes;
  begin
    Writer := TBsonWriter.Create;
    Writer.WriteStartDocument;

    Writer.WriteName('x');
    Writer.WriteInt32(1);

    Writer.WriteInt32('y', 2); // Writes name and value in single call

    Writer.WriteName('z');
    Writer.WriteStartArray;
    Writer.WriteDouble(3.14);
    Writer.WriteBoolean(True);
    Writer.WriteEndArray;

    Writer.WriteEndDocument;

    Bson := Writer.ToBson;
  end;
  </source>

  Likewise, you can serialize to JSON by using the IJsonWriter interface
  instead.

  You can also manually deserialize by using the IBsonReader and IJsonReader
  interfaces. However, these are a bit more complicated to use since you don't
  know the deserialized BSON types in advance.

  You can look at the unit tests in the unit Lib.Data.Bson.IO.Tests
  for examples of manual serialization and deserialization. *)

{$INCLUDE 'Lib.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  Lib.Bson;

type
  { Type of exception that is raised when parsing an invalid JSON source. }
  EgoJsonParserError = class(Exception)
  {$REGION 'Internal Declarations'}
  private
    FLineNumber: Integer;
    FColumnNumber: Integer;
    FPosition: Integer;
  {$WARNINGS OFF}
  private
    constructor Create(const AMsg: String; const ALineNumber,
      AColumnNumber, APosition: Integer);
  {$WARNINGS ON}
  {$ENDREGION 'Internal Declarations'}
  public
    { The line number of the error in the source text, starting at 1. }
    property LineNumber: Integer read FLineNumber;

    { The column number of the error in the source text, starting at 1. }
    property ColumnNumber: Integer read FColumnNumber;

    { The position of the error in the source text, starting at 0.
      The position is the offset (in characters) from the beginning of the
      text. }
    property Position: Integer read FPosition;
  end;

type
  { State of a IBsonBaseWriter }
  TBsonWriterState = (
    { Initial state }
    Initial,

    { The writer is positioned to write a name }
    Name,

    { The writer is positioned to write a value }
    Value,

    { The writer is positioned to write a scope document (call
      WriteStartDocument to start writing the scope document). }
    ScopeDocument,

    { The writer is done }
    Done,

    { The writer is closed }
    Closed);

type
  { State of a IBsonBaseReader }
  TBsonReaderState = (
    { Initial state }
    Initial,

    { The reader is positioned at the type of an element or value }
    &Type,

    { The reader is positioned at the name of an element }
    Name,

    { The reader is positioned at the value }
    Value,

    { The reader is positioned at a scope document }
    ScopeDocument,

    { The reader is positioned at the end of a document }
    EndOfDocument,

    { The reader is positioned at the end of an array }
    EndOfArray,

    { The reader has finished reading a document }
    Done,

    { The reader is closed }
    Closed);

type
  { Used internally by BSON/JSON readers and writers to represent the current
    context. }
  TBsonContextType = (
    { The top level of a BSON document }
    TopLevel,

    { A (possible embedded) BSON document }
    Document,

    { A BSON array }
    &Array,

    { A JavaScript w/Scope BSON value }
    JavaScriptWithScope,

    { The scope document of a JavaScript w/Scope BSON value }
    ScopeDocument);

type
  { Base interface for IBsonWriter, IJsonWriter and IBsonDocumentWriter }
  IBsonBaseWriter = interface
  ['{4525DC0D-C54E-47B2-85BE-4C09A8F5DF54}']
    {$REGION 'Internal Declarations'}
    function GetState: TBsonWriterState;
    {$ENDREGION 'Internal Declarations'}

    { Writes a BSON value.

      Parameters:
        AValue: the BSON value to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteValue(const AValue: TBsonValue);

    { Writes a BSON binary.

      Parameters:
        AValue: the BSON binary to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteBinaryData(const AValue: TBsonBinaryData);

    { Writes a BSON Regular Expression.

      Parameters:
        AValue: the BSON Regular Expression to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteRegularExpression(const AValue: TBsonRegularExpression); overload;

    { Writes both an element name and a BSON Regular Expression.

      Parameters:
        AName: the element name.
        AValue: the BSON Regular Expression to write.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
        True). }
    procedure WriteRegularExpression(const AName: String; const AValue: TBsonRegularExpression); overload;

    { Writes the name of an element.

      Parameters:
        AName: the element name. }
    procedure WriteName(const AName: String);

    { Writes a Boolean value.

      Parameters:
        AValue: the Boolean value. }
    procedure WriteBoolean(const AValue: Boolean); overload;

    { Writes a name/value pair with a Boolean value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Boolean value. }
    procedure WriteBoolean(const AName: String; const AValue: Boolean); overload;

    { Writes a 32-bit Integer value.

      Parameters:
        AValue: the Integer value. }
    procedure WriteInt32(const AValue: Integer); overload;

    { Writes a name/value pair with a 32-bit Integer value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Integer value. }
    procedure WriteInt32(const AName: String; const AValue: Integer); overload;

    { Writes a 64-bit Integer value.

      Parameters:
        AValue: the Integer value. }
    procedure WriteInt64(const AValue: Int64); overload;

    { Writes a name/value pair with a 64-bit Integer value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Integer value. }
    procedure WriteInt64(const AName: String; const AValue: Int64); overload;

    { Writes a Double value.

      Parameters:
        AValue: the Double value. }
    procedure WriteDouble(const AValue: Double); overload;

    { Writes a name/value pair with a Double value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Double value. }
    procedure WriteDouble(const AName: String; const AValue: Double); overload;

    { Writes a String value.

      Parameters:
        AValue: the String value. }
    procedure WriteString(const AValue: String); overload;

    { Writes a name/value pair with a String value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the String value. }
    procedure WriteString(const AName, AValue: String); overload;

    { Writes a DateTime value.

      Parameters:
        AMillisecondsSinceEpoch: the number of UTC milliseconds since the
          Unix epoch }
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); overload;

    { Writes a name/value pair with a DateTime value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AMillisecondsSinceEpoch: the number of UTC milliseconds since the
          Unix epoch }
    procedure WriteDateTime(const AName: String; const AMillisecondsSinceEpoch: Int64); overload;

    { Writes a byte array as binary data of sub type Binary

      Parameters:
        ABytes: the bytes to write }
    procedure WriteBytes(const AValue: TBytes); overload;

    { Writes a name/value pair with binary date.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ABytes: the bytes to write }
    procedure WriteBytes(const AName: String; const AValue: TBytes); overload;

    { Writes a Timestamp value.

      Parameters:
        AValue: the Timestamp value. }
    procedure WriteTimestamp(const AValue: Int64); overload;

    { Writes a name/value pair with a Timestamp value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the Timestamp value. }
    procedure WriteTimestamp(const AName: String; const AValue: Int64); overload;

    { Writes an ObjectId value.

      Parameters:
        AValue: the ObjectId value. }
    procedure WriteObjectId(const AValue: TObjectId); overload;

    { Writes a name/value pair with an ObjectId value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the ObjectId value. }
    procedure WriteObjectId(const AName: String; const AValue: TObjectId); overload;

    { Writes a JavaScript.

      Parameters:
        ACode: the JavaScript code. }
    procedure WriteJavaScript(const ACode: String); overload;

    { Writes a name/value pair with a JavaScript.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ACode: the JavaScript code. }
    procedure WriteJavaScript(const AName, ACode: String); overload;

    { Writes a JavaScript with scope.

      Parameters:
        ACode: the JavaScript code.

      @bold(Note): call WriteStartDocument to start writing the scope. }
    procedure WriteJavaScriptWithScope(const ACode: String); overload;

    { Writes a name/value pair with a JavaScript with scope.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        ACode: the JavaScript code.

      @bold(Note): call WriteStartDocument to start writing the scope. }
    procedure WriteJavaScriptWithScope(const AName, ACode: String); overload;

    { Writes a BSON Null value }
    procedure WriteNull; overload;

    { Writes a name/value pair with a BSON Null value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteNull(const AName: String); overload;

    { Writes a BSON Undefined value. }
    procedure WriteUndefined; overload;

    { Writes a name/value pair with a BSON Undefined value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteUndefined(const AName: String); overload;

    { Writes a BSON MaxKey value }
    procedure WriteMaxKey; overload;

    { Writes a name/value pair with a BSON MaxKey value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteMaxKey(const AName: String); overload;

    { Writes a BSON MinKey value }
    procedure WriteMinKey; overload;

    { Writes a name/value pair with a BSON MinKey value.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteMinKey(const AName: String); overload;

    { Writes a BSON Symbol.

      Parameters:
        AValue: the symbol. }
    procedure WriteSymbol(const AValue: String); overload;

    { Writes a name/value pair with a BSON Symbol.
      Can only be used when inside a document.

      Parameters:
        AName: the element name.
        AValue: the symbol. }
    procedure WriteSymbol(const AName, AValue: String); overload;

    { Writes the start of a BSON Array }
    procedure WriteStartArray; overload;

    { Writes a name/value pair, where the value starts a BSON Array.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteStartArray(const AName: String); overload;

    { Writes the end of a BSON Array }
    procedure WriteEndArray;

    { Writes the start of a BSON Document }
    procedure WriteStartDocument; overload;

    { Writes a name/value pair, where the value starts a BSON Document.
      Can only be used when inside a document.

      Parameters:
        AName: the element name. }
    procedure WriteStartDocument(const AName: String); overload;

    { Writes the end of a BSON Document }
    procedure WriteEndDocument;

    { The current state of the writer }
    property State: TBsonWriterState read GetState;
  end;

type
  { Interface for writing BSON values to binary BSON format.
    See TBsonWriter for the stock implementation of this interface. }
  IBsonWriter = interface(IBsonBaseWriter)
  ['{6B413B69-018F-48AD-8D81-140C1078AFA1}']
    { Returns the currently written data as a byte array.

      Returns:
        The data in BSON format.

      @bold(Note): you usually call this method when you have finished writing
      a BSON Document or value }
    function ToBson: TBytes;

    { Writes a raw BSON document.

      Parameters:
        AValue: the raw BSON document to write.

      @bold(Note): no BSON validity checking is performed. The value will be
      written as-is, and generate invalid BSON of not used carefully. }
    procedure WriteRawBsonDocument(const ADocument: TBytes);
  end;

type
  { Interface for writing BSON values to JSON format.
    See TJsonWriter for the stock implementation of this interface. }
  IJsonWriter = interface(IBsonBaseWriter)
  ['{92F5BA20-02C9-401C-8403-B51F8898E692}']
    { Returns the currently written data as a JSON string.

      Returns:
        The data in JSON format.

      @bold(Note): you usually call this method when you have finished writing
      a BSON Document or value }
    function ToJson: String;

    { Inserts a raw value into the current JSON string.

      Parameters:
        AValue: the value to write.

      @bold(Note): no JSON syntax checking is performed. The value will be
      written as-is, and generate invalid JSON of not used carefully. You
      usually never call this method yourself. }
    procedure WriteRaw(const AValue: String);
  end;

type
  { Interface for writing BSON values to a BSON document.
    See TBsonDocumentWriter for the stock implementation of this interface. }
  IBsonDocumentWriter = interface(IBsonBaseWriter)
  ['{4A410F7E-69FA-46A0-ACE2-317AF5DEA2B8}']
    {$REGION 'Internal Declarations'}
    function GetDocument: TBsonDocument;
    {$ENDREGION 'Internal Declarations'}

    { The document the writer writes to }
    property Document: TBsonDocument read GetDocument;
  end;

type
  { A bookmark that can be used to return a reader to the current position and
    state. }
  IBsonReaderBookmark = interface
  ['{7324A2DE-20F6-4FF2-9973-FD861F6833EB}']
    {$REGION 'Internal Declarations'}
    function GetState: TBsonReaderState;
    function GetCurrentBsonType: TBsonType;
    function GetCurrentName: String;
    {$ENDREGION 'Internal Declarations'}

    { The current state of the reader }
    property State: TBsonReaderState read GetState;

    { The current BsonType }
    property CurrentBsonType: TBsonType read GetCurrentBsonType;

    { The name of the current element }
    property CurrentName: String read GetCurrentName;
  end;

type
  { Base interface for IBsonReader, IJsonReader and IBsonDocumentReader }
  IBsonBaseReader = interface
  ['{A0592C3C-5E24-4424-9662-EA7F33BB1B9A}']
    {$REGION 'Internal Declarations'}
    function GetState: TBsonReaderState;
    {$ENDREGION 'Internal Declarations'}

    { Whether the reader is at the end of the stream.

      Returns:
        True if at end of stream }
    function EndOfStream: Boolean;

    { Gets the current BSON type in the stream.

      Returns:
        The current BSON type.

       @bold(Note): calls ReadBsonType if necessary. }
    function GetCurrentBsonType: TBsonType;

    { Gets a bookmark to the reader's current position and state.

      Returns:
        A bookmark.

      You can use the returned bookmark to restore the state using
      ReturnToBookmark. }
    function GetBookmark: IBsonReaderBookmark;

    { Returns the reader to previously bookmarked position and state.

      AParameters:
        ABookmark: the bookmark to return to. This value has previously been
          acquired using GetBookmark. }
    procedure ReturnToBookmark(const ABookmark: IBsonReaderBookmark);

    { Reads a BSON Document from the stream.

      Returns:
        The read BSON Document.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Document, or the stream is invalid. }
    function ReadDocument: TBsonDocument;

    { Reads a BSON Array from the stream.

      Returns:
        The read BSON Array.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Array, or the stream is invalid. }
    function ReadArray: TBsonArray;

    { Reads a BSON value from the stream.

      Returns:
        The read BSON value.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON value, or the stream is invalid. }
    function ReadValue: TBsonValue;

    { Reads a BSON Binary from the stream.

      Returns:
        The read BSON Binary.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Binary, or the stream is invalid. }
    function ReadBinaryData: TBsonBinaryData;

    { Reads a BSON Regular Expression from the stream.

      Returns:
        The read BSON Regular Expression.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Regular Expression, or the stream is invalid. }
    function ReadRegularExpression: TBsonRegularExpression;

    { Reads a BSON type from the stream.

      Returns:
        The read BSON type.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON type, or the stream is invalid. }
    function ReadBsonType: TBsonType;

    { Reads the name of an element from the stream.

      Returns:
        The read element name.

      Raises:
        An exception if the current position in the stream does not contain
        an element name, or the stream is invalid. }
    function ReadName: String;

    { Skips the name of an element.

      Raises:
        An exception if the current position in the stream does not contain
        an element name, or the stream is invalid. }
    procedure SkipName;

    { Skips the value of an element.

      Raises:
        An exception if the current position in the stream does not contain
        an element value, or the stream is invalid. }
    procedure SkipValue;

    { Reads a Boolean value from the stream.

      Returns:
        The read Boolean value.

      Raises:
        An exception if the current position in the stream does not contain
        a Boolean value, or the stream is invalid. }
    function ReadBoolean: Boolean;

    { Reads a 32-bit Integer value from the stream.

      Returns:
        The read Integer value.

      Raises:
        An exception if the current position in the stream does not contain
        a 32-bit Integer value, or the stream is invalid. }
    function ReadInt32: Integer;

    { Reads a 64-bit Integer value from the stream.

      Returns:
        The read Integer value.

      Raises:
        An exception if the current position in the stream does not contain
        a 64-bit Integer value, or the stream is invalid. }
    function ReadInt64: Int64;

    { Reads a Double value from the stream.

      Returns:
        The read Double value.

      Raises:
        An exception if the current position in the stream does not contain
        a Double value, or the stream is invalid. }
    function ReadDouble: Double;

    { Reads a String value from the stream.

      Returns:
        The read String value.

      Raises:
        An exception if the current position in the stream does not contain
        a String value, or the stream is invalid. }
    function ReadString: String;

    { Reads a DateTime value from the stream.

      Returns:
        The read DateTime value as the number of UTC milliseconds since the
        Unix epoch.

      Raises:
        An exception if the current position in the stream does not contain
        a DateTime value, or the stream is invalid. }
    function ReadDateTime: Int64;

    { Reads a Timestamp value from the stream.

      Returns:
        The read Timestamp value.

      Raises:
        An exception if the current position in the stream does not contain
        a Timestamp value, or the stream is invalid. }
    function ReadTimestamp: Int64;

    { Reads an ObjectId value from the stream.

      Returns:
        The read ObjectId value.

      Raises:
        An exception if the current position in the stream does not contain
        a ObjectId value, or the stream is invalid. }
    function ReadObjectId: TObjectId;

    { Reads a Binary value from the stream as a byte array.

      Returns:
        The read Binary value.

      Raises:
        An exception if the current position in the stream does not contain
        a BSON Binary, or the stream is invalid. }
    function ReadBytes: TBytes;

    { Reads a JavaScript from the stream.

      Returns:
        The read JavaScript.

      Raises:
        An exception if the current position in the stream does not contain
        a JavaScript, or the stream is invalid. }
    function ReadJavaScript: String;

    { Reads a JavaScript with scope from the stream.

      Returns:
        The read JavaScript.

      Raises:
        An exception if the current position in the stream does not contain
        a JavaScript with Scope, or the stream is invalid.

      @bold(Note): call ReadStartDocument next to read the scope. }
    function ReadJavaScriptWithScope: String;

    { Reads a BSON Null value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a Null value, or the stream is invalid. }
    procedure ReadNull;

    { Reads a BSON Undefined value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a Undefined value, or the stream is invalid. }
    procedure ReadUndefined;

    { Reads a BSON MaxKey value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a MaxKey value, or the stream is invalid. }
    procedure ReadMaxKey;

    { Reads a BSON MinKey value from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        a MinKey value, or the stream is invalid. }
    procedure ReadMinKey;

    { Reads a BSON Symbol from the stream.

      Returns:
        The read Symbol name.

      Raises:
        An exception if the current position in the stream does not contain
        a Symbol, or the stream is invalid. }
    function ReadSymbol: String;

    { Reads the start of a BSON Array from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the start of a BSON Array, or the stream is invalid. }
    procedure ReadStartArray;

    { Reads the end of a BSON Array from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the end of a BSON Array, or the stream is invalid. }
    procedure ReadEndArray;

    { Reads the start of a BSON Document from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the start of a BSON Document, or the stream is invalid. }
    procedure ReadStartDocument;

    { Reads the end of a BSON Document from the stream.

      Raises:
        An exception if the current position in the stream does not contain
        the end of a BSON Document, or the stream is invalid. }
    procedure ReadEndDocument;

    { The current state of the reader }
    property State: TBsonReaderState read GetState;
  end;

type
  { Interface for reading BSON values from binary BSON format.
    See TBsonReader for the stock implementation of this interface. }
  IBsonReader = interface(IBsonBaseReader)
  ['{773A4BBE-A4D9-4DDA-A937-C865ADC0A5B8}']
  end;

type
  { Interface for reading BSON values from JSON format.
    See TJsonReader for the stock implementation of this interface. }
  IJsonReader = interface(IBsonBaseReader)
  ['{F579A93F-760C-463D-9B54-64AAF527F514}']
  end;

type
  { Interface for reading BSON values from a BSON Document.
    See TBsonDocumentReader for the stock implementation of this interface. }
  IBsonDocumentReader = interface(IBsonBaseReader)
  ['{1D4F90C4-C790-491C-844A-C7FFCF58F2E8}']
  end;

type
  { Abstract base class of TBsonWriter and TJsonWriter.
    Implements the IBsonBaseWriter interface. }
  TBsonBaseWriter = class abstract(TInterfacedObject, IBsonBaseWriter)
  {$REGION 'Internal Declarations'}
  private
    FState: TBsonWriterState;
    FName: String;
  private
    procedure WriteValueIntf(const AValue: TBsonValue._IValue);
    procedure WriteArray(const AArray: TBsonArray._IArray);
    procedure WriteDocument(const ADocument: TBsonDocument._IDocument);
    procedure DoWriteBinaryData(const AValue: TBsonValue._IValue);
    procedure DoWriteDateTime(const AValue: TBsonValue._IValue);
    procedure DoWriteRegularExpression(const AValue: TBsonValue._IValue);
    procedure DoWriteJavaScript(const AValue: TBsonValue._IValue);
    procedure DoWriteJavaScriptWithScope(const AValue: TBsonJavaScriptWithScope); overload;
    procedure DoWriteJavaScriptWithScope(const AValue: TBsonValue._IValue); overload;
    procedure DoWriteSymbol(const AValue: TBsonValue._IValue);
    procedure DoWriteTimestamp(const AValue: TBsonValue._IValue);
  protected
    { IBsonBaseWriter }
    procedure WriteName(const AName: String); virtual;
    procedure WriteValue(const AValue: TBsonValue);
    function GetState: TBsonWriterState;
    procedure WriteBoolean(const AValue: Boolean); overload; virtual; abstract;
    procedure WriteBoolean(const AName: String; const AValue: Boolean); overload;
    procedure WriteInt32(const AValue: Integer); overload; virtual; abstract;
    procedure WriteInt32(const AName: String; const AValue: Int32); overload;
    procedure WriteInt64(const AValue: Int64); overload; virtual; abstract;
    procedure WriteInt64(const AName: String; const AValue: Int64); overload;
    procedure WriteDouble(const AValue: Double); overload; virtual; abstract;
    procedure WriteDouble(const AName: String; const AValue: Double); overload;
    procedure WriteString(const AValue: String); overload; virtual; abstract;
    procedure WriteString(const AName, AValue: String); overload;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); overload; virtual; abstract;
    procedure WriteDateTime(const AName: String; const AMillisecondsSinceEpoch: Int64); overload;
    procedure WriteBytes(const AValue: TBytes); overload;
    procedure WriteBytes(const AName: String; const AValue: TBytes); overload;
    procedure WriteTimestamp(const AValue: Int64); overload; virtual; abstract;
    procedure WriteTimestamp(const AName: String; const AValue: Int64); overload;
    procedure WriteObjectId(const AValue: TObjectId); overload; virtual; abstract;
    procedure WriteObjectId(const AName: String; const AValue: TObjectId); overload;
    procedure WriteJavaScript(const ACode: String); overload; virtual; abstract;
    procedure WriteJavaScript(const AName, ACode: String); overload;
    procedure WriteJavaScriptWithScope(const ACode: String); overload; virtual; abstract;
    procedure WriteJavaScriptWithScope(const AName, ACode: String); overload;
    procedure WriteNull; overload; virtual; abstract;
    procedure WriteNull(const AName: String); overload;
    procedure WriteUndefined; overload; virtual; abstract;
    procedure WriteUndefined(const AName: String); overload;
    procedure WriteMaxKey; overload; virtual; abstract;
    procedure WriteMaxKey(const AName: String); overload;
    procedure WriteMinKey; overload; virtual; abstract;
    procedure WriteMinKey(const AName: String); overload;
    procedure WriteSymbol(const AValue: String); overload; virtual; abstract;
    procedure WriteSymbol(const AName, AValue: String); overload;
    procedure WriteStartArray; overload; virtual; abstract;
    procedure WriteStartArray(const AName: String); overload;
    procedure WriteEndArray; virtual; abstract;
    procedure WriteStartDocument; overload; virtual; abstract;
    procedure WriteStartDocument(const AName: String); overload;
    procedure WriteEndDocument; virtual; abstract;
    procedure WriteBinaryData(const AValue: TBsonBinaryData); virtual; abstract;
    procedure WriteRegularExpression(const AValue: TBsonRegularExpression); overload; virtual; abstract;
    procedure WriteRegularExpression(const AName: String; const AValue: TBsonRegularExpression); overload;
  protected
    property State: TBsonWriterState read FState write FState;
    property Name: String read FName;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Stock implementation of the IBsonWriter interface. }
  TBsonWriter = class(TBsonBaseWriter, IBsonWriter)
  {$REGION 'Internal Declarations'}
  private type
    TOutput = record
    private const
      TEMP_BYTES_LENGTH = 128;
    private
      FBuffer: TBytes;
      FSize: Integer;
      FCapacity: Integer;
      FTempBytes: TBytes;
    public
      procedure Initialize;

      procedure Write(const AValue; const ASize: Integer);
      procedure WriteBsonType(const ABsonType: TBsonType); inline;
      procedure WriteBinarySubType(const ASubType: TBsonBinarySubType); inline;
      procedure WriteByte(const AValue: Byte); inline;
      procedure WriteBoolean(const AValue: Boolean); inline;
      procedure WriteInt32(const AValue: Int32); inline;
      procedure WriteInt32At(const APosition, AValue: Int32); inline;
      procedure WriteInt64(const AValue: Int64); inline;
      procedure WriteDouble(const AValue: Double); inline;
      procedure WriteCString(const AValue: String); overload;
      procedure WriteCString(const AValue: TBytes); overload;
      procedure WriteString(const AValue: String);
      procedure WriteObjectId(const AValue: TObjectId);

      function ToBytes: TBytes;

      property Position: Integer read FSize;
    end;
  private type
    PContext = ^TContext;
    TContext = record
    private
      FStartPosition: Integer;
      FIndex: Integer;
      FContextType: TBsonContextType;
    public
      procedure Initialize(const AContextType: TBsonContextType;
        const AStartPosition: Integer); inline;

      property StartPosition: Integer read FStartPosition;
      property Index: Integer read FIndex write FIndex;
      property ContextType: TBsonContextType read FContextType;
    end;
  protected type
    TArrayElementNameAccelerator = record
    private class var
      FCachedElementNames: array [0..999] of TBytes;
    private
      class function CreateElementNameBytes(const AIndex: Integer): TBytes; static;
    public
      class constructor Create;
    public
      class function GetElementNameBytes(const AIndex: Integer): TBytes; static;
    end;
  private
    FOutput: TOutput;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonWriterState;
    procedure PushContext(const AContextType: TBsonContextType;
      const AStartPosition: Integer);
    procedure PopContext;
    procedure WriteNameHelper;
    procedure BackpatchSize;
  protected
    { IBsonBaseWriter }
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TBsonRegularExpression); override;
  protected
    { IBsonWriter }
    function ToBson: TBytes;
    procedure WriteRawBsonDocument(const ADocument: TBytes);
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a binary BSON writer }
    constructor Create;
  end;

type
  { Stock implementation of the IJsonWriter interface. }
  TJsonWriter = class(TBsonBaseWriter, IJsonWriter)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = record
    private
      FIndentation: String;
      FContextType: TBsonContextType;
      FHasElements: Boolean;
    public
      procedure Initialize(const AParentContext: PContext;
        const AContextType: TBsonContextType;
        const AIndentString: String);

      property Indentation: String read FIndentation;
      property ContextType: TBsonContextType read FContextType;
      property HasElements: Boolean read FHasElements write FHasElements;
    end;
  private type
    TOutput = record
    private
      FBuffer: PByte;
      FSize: Integer;
      FCapacity: Integer;
    public
      procedure Initialize;
      procedure Finalize;

      procedure Append(const AValue; const ASize: Integer); overload;
      procedure Append(const AValue: Char); overload; inline;
      procedure Append(const AValue: String); overload; inline;
      procedure Append(const AValue: Integer); overload; inline;
      procedure Append(const AValue: Int64); overload; inline;
      procedure AppendFormat(const AValue: String; const AArgs: array of const); overload;

      function ToString: String; inline;
    end;
  private
    FSettings: TJsonWriterSettings;
    FOutput: TOutput;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonWriterState;
    procedure PushContext(const AContextType: TBsonContextType;
      const AIndentString: String);
    procedure PopContext;
    procedure WriteNameHelper(const AName: String);
    procedure WriteQuotedString(const AValue: String);
    procedure WriteEscapedString(const AValue: String);
    class function GuidToString(const ABytes: TBytes;
      const ASubType: TBsonBinarySubType): String; static;
  protected
    { IBsonBaseWriter }
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TBsonRegularExpression); override;
  protected
    { IJsonWriter }
    function ToJson: String;
    procedure WriteRaw(const AValue: String);
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a JSON writer using the default settings. }
    constructor Create; overload;

    { Creates a JSON writer.

      Parameters:
        ASettings: the writer settings to use. }
    constructor Create(const ASettings: TJsonWriterSettings); overload;

    { Destructor }
    destructor Destroy; override;
  end;

type
  { Stock implementation of the IBsonDocumentWriter interface. }
  TBsonDocumentWriter = class(TBsonBaseWriter, IBsonDocumentWriter)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = record
    private
      FContextType: TBsonContextType;
      FDocument: TBsonDocument;
      FArray: TBsonArray;
      FName: String;
      FCode: String;
    public
      procedure Initialize(const AContextType: TBsonContextType;
        const ADocument: TBsonDocument); overload;
      procedure Initialize(const AContextType: TBsonContextType;
        const AArray: TBsonArray); overload;
      procedure Initialize(const AContextType: TBsonContextType;
        const ACode: String); overload;

      property ContextType: TBsonContextType read FContextType;
      property Document: TBsonDocument read FDocument;
      property &Array: TBsonArray read FArray;
      property Name: String read FName write FName;
      property Code: String read FCode;
    end;
  private
    FDocument: TBsonDocument;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonWriterState;
    procedure PushContext(const AContextType: TBsonContextType;
      const ADocument: TBsonDocument); overload;
    procedure PushContext(const AContextType: TBsonContextType;
      const AArray: TBsonArray); overload;
    procedure PushContext(const AContextType: TBsonContextType;
      const ACode: String); overload;
    procedure PopContext;
    procedure AddValue(const AValue: TBsonValue);
  protected
    { IBsonBaseWriter }
    procedure WriteName(const AName: String); override;
    procedure WriteBoolean(const AValue: Boolean); override;
    procedure WriteInt32(const AValue: Integer); override;
    procedure WriteInt64(const AValue: Int64); override;
    procedure WriteDouble(const AValue: Double); override;
    procedure WriteString(const AValue: String); override;
    procedure WriteDateTime(const AMillisecondsSinceEpoch: Int64); override;
    procedure WriteTimestamp(const AValue: Int64); override;
    procedure WriteObjectId(const AValue: TObjectId); override;
    procedure WriteJavaScript(const ACode: String); override;
    procedure WriteJavaScriptWithScope(const ACode: String); override;
    procedure WriteNull; override;
    procedure WriteUndefined; override;
    procedure WriteMaxKey; override;
    procedure WriteMinKey; override;
    procedure WriteSymbol(const AValue: String); override;
    procedure WriteStartArray; override;
    procedure WriteEndArray; override;
    procedure WriteStartDocument; override;
    procedure WriteEndDocument; override;
    procedure WriteBinaryData(const AValue: TBsonBinaryData); override;
    procedure WriteRegularExpression(const AValue: TBsonRegularExpression); override;
  protected
    { IBsonDocumentWriter }
    function GetDocument: TBsonDocument;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Document writer.

      Parameters:
        ADocument: the BSON Document to write to. }
    constructor Create(const ADocument: TBsonDocument);
  end;

type

  TBookmark = class abstract(TInterfacedObject, IBsonReaderBookmark)
  private
    FState: TBsonReaderState;
    FCurrentBsonType: TBsonType;
    FCurrentName: String;
  protected
    { IBsonReaderBookmark }
    function GetState: TBsonReaderState;
    function GetCurrentBsonType: TBsonType;
    function GetCurrentName: String;
  public
    constructor Create(const AState: TBsonReaderState;
      const ACurrentBsonType: TBsonType; const ACurrentName: String);

    property State: TBsonReaderState read FState;
    property CurrentBsonType: TBsonType read FCurrentBsonType;
    property CurrentName: String read FCurrentName;
  end;

  { Abstract base class of TBsonReader and TJsonReader.
    Implements the IBsonBaseReader interface. }
  TBsonBaseReader = class abstract(TInterfacedObject, IBsonBaseReader)
  {$REGION 'Internal Declarations'}
  private type
  private
    FState: TBsonReaderState;
    FCurrentBsonType: TBsonType;
    FCurrentName: String;
    FAllowDuplicateNames: Boolean;
  private
    function DoReadJavaScriptWithScope: TBsonValue;
  protected
    { IBsonBaseReader }
    function GetState: TBsonReaderState;
    function GetCurrentBsonType: TBsonType;
    function ReadDocument: TBsonDocument;
    function ReadArray: TBsonArray;
    function ReadValue: TBsonValue;
    function GetBookmark: IBsonReaderBookmark; virtual; abstract;
    procedure ReturnToBookmark(const ABookmark: IBsonReaderBookmark); virtual; abstract;
    function EndOfStream: Boolean; virtual; abstract;
    function ReadBsonType: TBsonType; virtual; abstract;
    function ReadName: String; virtual; abstract;
    procedure SkipName; virtual; abstract;
    procedure SkipValue; virtual; abstract;
    function ReadBoolean: Boolean; virtual; abstract;
    function ReadInt32: Integer; virtual; abstract;
    function ReadInt64: Int64; virtual; abstract;
    function ReadDouble: Double; virtual; abstract;
    function ReadString: String; virtual; abstract;
    function ReadDateTime: Int64; virtual; abstract;
    function ReadTimestamp: Int64; virtual; abstract;
    function ReadObjectId: TObjectId; virtual; abstract;
    function ReadBytes: TBytes; virtual; abstract;
    function ReadJavaScript: String; virtual; abstract;
    function ReadJavaScriptWithScope: String; virtual; abstract;
    procedure ReadNull; virtual; abstract;
    procedure ReadUndefined; virtual; abstract;
    procedure ReadMaxKey; virtual; abstract;
    procedure ReadMinKey; virtual; abstract;
    function ReadSymbol: String; virtual; abstract;
    procedure ReadStartArray; virtual; abstract;
    procedure ReadEndArray; virtual; abstract;
    procedure ReadStartDocument; virtual; abstract;
    procedure ReadEndDocument; virtual; abstract;
    function ReadBinaryData: TBsonBinaryData; virtual; abstract;
    function ReadRegularExpression: TBsonRegularExpression; virtual; abstract;
  protected
    function ReadDocumentIntf: TBsonDocument._IDocument;
    function ReadArrayIntf: TBsonArray._IArray;
    function ReadValueIntf: TBsonValue._IValue;
    function ReadBinaryDataIntf: TBsonValue._IValue;
    function ReadRegularExpressionIntf: TBsonValue._IValue;
    function ReadJavaScriptIntf: TBsonValue._IValue;
    function ReadJavaScriptWithScopeIntf: TBsonValue._IValue;
    function ReadTimeStampIntf: TBsonValue._IValue;
    function ReadStringIntf: TBsonValue._IValue;
    function ReadSymbolIntf: TBsonValue._IValue;
  protected
    procedure EnsureBsonTypeEquals(const ABsonType: TBsonType);
    procedure VerifyBsonType(const ARequiredBsonType: TBsonType);

    property State: TBsonReaderState read FState write FState;
    property CurrentBsonType: TBsonType read FCurrentBsonType write FCurrentBsonType;
    property CurrentName: String read FCurrentName write FCurrentName;
    property AllowDuplicateNames: Boolean read FAllowDuplicateNames write FAllowDuplicateNames;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Stock implementation of the IBsonReader interface. }
  TBsonReader = class(TBsonBaseReader, IBsonReader)
  {$REGION 'Internal Declarations'}
  private type
    TInput = record
    private const
      TEMP_BYTES_LENGTH = 128;
    private class var
      FValidBsonTypes: array [0..255] of Boolean;
    private
      FBuffer: TBytes;
      FSize: Integer;
      FPosition: Integer;
      FTempBytes: TBytes;
    public
      class constructor Create;
    public
      procedure Initialize(const ABuffer: TBytes); inline;
      procedure Skip(const ANumBytes: Integer);

      procedure Read(out AData; const ASize: Integer);
      function ReadBsonType: TBsonType; inline;
      function ReadBinarySubType: TBsonBinarySubType; inline;
      function ReadByte: Byte; inline;
      function ReadBytes(const ASize: Integer): TBytes;
      function ReadBoolean: Boolean; inline;
      function ReadInt32: Int32; inline;
      function ReadInt64: Int64; inline;
      function ReadDouble: Double; inline;
      function ReadCString: String;
      procedure SkipCString;
      function ReadString: String;
      function ReadObjectId: TObjectId;

      property Size: Integer read FSize;
      property Position: Integer read FPosition write FPosition;
    end;
  private type
    PContext = ^TContext;
    TContext = record
    private
      FStartPosition: Integer;
      FSize: Integer;
      FCurrentArrayIndex: Integer;
      FCurrentElementName: String;
      FContextType: TBsonContextType;
    public
      procedure Initialize(const AContextType: TBsonContextType;
        const AStartPosition, ASize: Integer); inline;

      property ContextType: TBsonContextType read FContextType;
      property CurrentArrayIndex: Integer read FCurrentArrayIndex write FCurrentArrayIndex;
      property CurrentElementName: String read FCurrentElementName write FCurrentElementName;
    end;
  private type
    TBsonBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FPosition: Integer;
    public
      constructor Create(const AState: TBsonReaderState;
        const ACurrentBsonType: TBsonType; const ACurrentName: String;
        const AContextIndex, APosition: Integer);

      property ContextIndex: Integer read FContextIndex;
      property Position: Integer read FPosition;
    end;
  private
    FInput: TInput;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonReaderState;
    procedure PushContext(const AContextType: TBsonContextType;
      const AStartPosition, ASize: Integer);
    procedure PopContext(const APosition: Integer);
    function ReadSize: Integer;
  protected
    { IBsonBaseReader }
    function GetBookmark: IBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TBsonBinaryData; override;
    function ReadRegularExpression: TBsonRegularExpression; override;
  protected
    { IBsonReader }
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON binary reader.

      Parameters:
        ABson: the binary BSON data to read from. }
    constructor Create(const ABson: TBytes);

    { Creates a BSON binary reader from a file.

      Parameters:
        AFilename: the name of the file containing the BSON data. }
    class function Load(const AFilename: String): IBsonReader; overload; static;

    { Creates a BSON binary reader from a stream.

      Parameters:
        AStream: the stream containing the BSON data. }
    class function Load(const AStream: TStream): IBsonReader; overload; static;
  end;

type
  { Stock implementation of the IJsonReader interface. }
  TJsonReader = class(TBsonBaseReader, IJsonReader)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = record
    private
      FContextType: TBsonContextType;
    public
      procedure Initialize(const AContextType: TBsonContextType); inline;

      property ContextType: TBsonContextType read FContextType;
    end;
  private type
    TBuffer = record
    private
      FJson: String;
      FBuffer: PChar;
      FCurrent: PChar;
      FErrorPos: PChar;
      FLineNumber: Integer;
      FLineStart: PChar;
      FPrevLineStart: PChar;
    public
      class function Create(const AJson: String): TBuffer; static;
      function Read: Char; inline;
      procedure Unread(const AChar: Char);
      procedure MarkErrorPos; inline;
      procedure ClearErrorPos; inline;

      function ParseError(const AMsg: PResStringRec): EgoJsonParserError; overload;
      function ParseError(const AMsg: String): EgoJsonParserError; overload;
      function ParseError(const AMsg: PResStringRec; const AArgs: array of const): EgoJsonParserError; overload;
      function ParseError(const AMsg: String; const AArgs: array of const): EgoJsonParserError; overload;

      property Current: PChar read FCurrent write FCurrent;
    end;
  private type
    TTokenType = (Invalid, BeginArray, BeginObject, EndArray, LeftParen,
      RightParen, EndObject, Colon, Comma, DateTime, Double, Int32, Int64,
      ObjectId, RegularExpression, &String, UnquotedString, EndOfFile);
  private type
    TToken = class
    {$REGION 'Internal Declarations'}
    private type
      TTokenValue = record
      case Byte of
        0: (Int32Value: Int32);
        1: (Int64Value: Int64);
        2: (DoubleValue: Double);
      end;
    private
      FTokenType: TTokenType;
      FLexemeStart: PChar;
      FLexemeLength: Integer;
      FStringValue: String;
      FValue: TTokenValue;
    {$ENDREGION 'Internal Declarations'}
    public
      procedure Initialize(const ATokenType: TTokenType;
        const ALexemeStart: PChar; const ALexemeLength: Integer); overload; inline;
      procedure Initialize(const ATokenType: TTokenType;
        const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AStringValue: String); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AInt32Value: Int32); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const AInt64Value: Int64); overload; inline;
      procedure Initialize(const ALexemeStart: PChar; const ALexemeLength: Integer;
        const ADoubleValue: Double); overload; inline;
      procedure InitializeRegEx(const ALexemeStart: PChar;
        const ALexemeLength: Integer); overload; inline;

      procedure Assign(const AOther: TToken);

      function IsLexeme(const AValue: PChar; const AValueLength: Integer): Boolean; inline;
      function LexemeToString: String; inline;

      property TokenType: TTokenType read FTokenType;
      property LexemeStart: PChar read FLexemeStart;
      property LexemeLength: Integer read FLexemeLength;
      property StringValue: String read FStringValue;
      property Int32Value: Int32 read FValue.Int32Value;
      property Int64Value: Int64 read FValue.Int64Value;
      property DoubleValue: Double read FValue.DoubleValue;
    end;
  private type
    TScanner = record
    private type
      TRegularExpressionState = (InPattern, InEscapeSequence, InOptions,
        Done, Invalid);
    private type
      TCharHandler = procedure(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken);
    private class var
      FCharHandlers: array [#0..#127] of TCharHandler;
    private
      class function IsWhitespace(const AChar: Char): Boolean; inline; static;
    private
      { Character handlers }
      class procedure CharError(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEof(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharWhitespace(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharBeginObject(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEndObject(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharBeginArray(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharEndArray(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharLeftParen(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharRightParen(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharColon(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharComma(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharNumberToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharStringToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharStringTokenUnscape(var ABuffer: TBuffer;
        const AQuoteChar: Char; const AToken: TToken; const AStart: PChar;
        const APrefix: String); static;
      class procedure CharUnquotedStringToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
      class procedure CharRegularExpressionToken(var ABuffer: TBuffer; const AChar: Char;
        const AToken: TToken); static;
    public
      class procedure Initialize; static;
      class procedure GetNextToken(var ABuffer: TBuffer; const AToken: TToken); static;
    end;
  private type
    TValue = record
      StrVal: String;
      Bytes: TBytes;
      case Byte of
        0: (BoolVal: Boolean);
        1: (Int32Val: Int32);
        2: (Int64Val: Int64);
        3: (DoubleVal: Double);
        4: (ObjectIdVal: TObjectId);
        5: (BinarySubType: TBsonBinarySubType);
    end;
  private type
    TJsonBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FCurrentToken: TToken;
      FCurrentValue: TValue;
      FPushedToken: TToken;
      FCurrent: PChar;
    public
      constructor Create(const AState: TBsonReaderState;
        const ACurrentBsonType: TBsonType; const ACurrentName: String;
        const AContextIndex: Integer; const ACurrentToken: TToken;
        const ACurrentValue: TValue; const APushedToken: TToken;
        const ACurrent: PChar);
      destructor Destroy; override;

      property ContextIndex: Integer read FContextIndex;
      property CurrentToken: TToken read FCurrentToken;
      property CurrentValue: TValue read FCurrentValue;
      property PushedToken: TToken read FPushedToken;
      property Current: PChar read FCurrent;
    end;
  private
    FBuffer: TBuffer;
    FTokenBase: TToken;
    FTokenToPush: TToken;
    FCurrentToken: TToken;
    FCurrentValue: TValue;
    FPushedToken: TToken;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonReaderState;
    procedure PushContext(const AContextType: TBsonContextType);
    procedure PopContext;
    procedure PushToken(const AToken: TToken);
    procedure PopToken(out AToken: TToken);
    function ParseDocumentOrExtendedJson: TBsonType;
    function ParseExtendedJson(const ANameToken: TToken): TBsonType;
    procedure ParseExtendedJsonBinaryData;
    function ParseExtendedJsonDateTime: Int64;
    function ParseExtendedJsonNumberLong: Int64;
    function ParseExtendedJsonJavaScript: TBsonType;
    procedure ParseExtendedJsonMaxKey;
    procedure ParseExtendedJsonMinKey;
    procedure ParseExtendedJsonUndefined;
    function ParseExtendedJsonObjectId: TObjectId;
    procedure ParseExtendedJsonRegularExpression;
    procedure ParseExtendedJsonSymbol;
    function ParseExtendedJsonTimestamp: Int64;
    function ParseExtendedJsonTimestampNew: Int64;
    function ParseExtendedJsonTimestampOld(const AValueToken: TToken): Int64;
    procedure ParseConstructorBinaryData;
    procedure ParseConstructorDateTime(const AWithNew: Boolean);
    procedure ParseConstructorHexData;
    procedure ParseConstructorISODateTime;
    procedure ParseConstructorNumber;
    procedure ParseConstructorNumberLong;
    procedure ParseConstructorObjectId;
    procedure ParseConstructorRegularExpression;
    procedure ParseConstructorTimestamp;
    procedure ParseConstructorUUID(const ALexemeStart: Char);
    function ParseNew: TBsonType;
    procedure VerifyToken(const AExpectedLexeme: Char); overload;
    procedure VerifyToken(const AExpectedLexeme: PChar;
      const AExpectedLexemeLength: Integer); overload;
    procedure VerifyString(const AExpectedString: String);
    procedure SetCurrentValueRegEx(const AToken: TToken);
    class function FormatJavaScriptDateTimeString(const ALocalDateTime: TDateTime): String; static;
  protected
    { IBsonBaseReader }
    function GetBookmark: IBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TBsonBinaryData; override;
    function ReadRegularExpression: TBsonRegularExpression; override;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a JSON reader.

      Parameters:
        AJson: the JSON string to parse. }
    constructor Create(const AJson: String; AllowDuplicateNames : Boolean = false);

    { Destructor }
    destructor Destroy; override;

    { Creates a JSON reader from a file.

      Parameters:
        AFilename: the name of the file containing the JSON data. }
    class function Load(const AFilename: String; AllowDuplicateNames : Boolean = false): IJsonReader; overload; static;

    { Creates a JSON reader from a stream.

      Parameters:
        AStream: the stream containing the JSON data. }
    class function Load(const AStream: TStream; AllowDuplicateNames : Boolean = false): IJsonReader; overload; static;
  end;

type
  { Stock implementation of the IBsonDocumentReader interface. }
  TBsonDocumentReader = class(TBsonBaseReader, IBsonDocumentReader)
  {$REGION 'Internal Declarations'}
  private type
    PContext = ^TContext;
    TContext = record
    private
      FContextType: TBsonContextType;
      FDocument: TBsonDocument;
      FArray: TBsonArray;
      FIndex: Integer;
    public
      procedure Initialize(const AContextType: TBsonContextType;
        const ADocument: TBsonDocument); overload; inline;
      procedure Initialize(const AContextType: TBsonContextType;
        const AArray: TBsonArray); overload; inline;

      function TryGetNextElement(out AElement: TBsonElement): Boolean;
      function TryGetNextValue(out AValue: TBsonValue): Boolean;

      property ContextType: TBsonContextType read FContextType;
      property Document: TBsonDocument read FDocument;
      property Index: Integer read FIndex write FIndex;
    end;
  private type
    TDocumentBookmark = class(TBookmark)
    private
      FContextIndex: Integer;
      FContextIndexIndex: Integer;
      FCurrentValue: TBsonValue;
    public
      constructor Create(const AState: TBsonReaderState;
        const ACurrentBsonType: TBsonType; const ACurrentName: String;
        const AContextIndex, AContextIndexIndex: Integer; const ACurrentValue: TBsonValue);

      property ContextIndex: Integer read FContextIndex;
      property ContextIndexIndex: Integer read FContextIndexIndex;
      property CurrentValue: TBsonValue read FCurrentValue;
    end;
  private
    FCurrentValue: TBsonValue;
    FContextStack: TArray<TContext>;
    FContextIndex: Integer;
    FContext: PContext;
  private
    function GetNextState: TBsonReaderState;
    procedure PushContext(const AContextType: TBsonContextType;
      const ADocument: TBsonDocument); overload;
    procedure PushContext(const AContextType: TBsonContextType;
      const AArray: TBsonArray); overload;
    procedure PopContext;
  protected
    { IBsonBaseReader }
    function GetBookmark: IBsonReaderBookmark; override;
    procedure ReturnToBookmark(const ABookmark: IBsonReaderBookmark); override;
    function EndOfStream: Boolean; override;
    function ReadBsonType: TBsonType; override;
    function ReadName: String; override;
    procedure SkipName; override;
    procedure SkipValue; override;
    function ReadBoolean: Boolean; override;
    function ReadInt32: Integer; override;
    function ReadInt64: Int64; override;
    function ReadDouble: Double; override;
    function ReadString: String; override;
    function ReadDateTime: Int64; override;
    function ReadTimestamp: Int64; override;
    function ReadObjectId: TObjectId; override;
    function ReadBytes: TBytes; override;
    function ReadJavaScript: String; override;
    function ReadJavaScriptWithScope: String; override;
    procedure ReadNull; override;
    procedure ReadUndefined; override;
    procedure ReadMaxKey; override;
    procedure ReadMinKey; override;
    function ReadSymbol: String; override;
    procedure ReadStartArray; override;
    procedure ReadEndArray; override;
    procedure ReadStartDocument; override;
    procedure ReadEndDocument; override;
    function ReadBinaryData: TBsonBinaryData; override;
    function ReadRegularExpression: TBsonRegularExpression; override;
  protected
    { IBsonDocumentReader }
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Document reader.

      Parameters:
        ADocument: the BSON Document to read from. }
    constructor Create(const ADocument: TBsonDocument);
  end;

resourcestring
  RS_BSON_NOT_SUPPORTED = 'Unsupported feature';
  RS_BSON_INVALID_WRITER_STATE = 'Cannot write Bson/Json element in current state';
  RS_BSON_INVALID_READER_STATE = 'Cannot read Bson/Json element in current state';
  RS_BSON_INVALID_DATA = 'Bson/Json data is invalid';
  RS_BSON_INT_EXPECTED = 'Integer value expected';
  RS_BSON_UNEXPECTED_TOKEN = 'Unexpected token';
  RS_BSON_TOKEN_EXPECTED = 'Expected token with value "%s" but got "%s"';
  RS_BSON_STRING_EXPECTED = 'String value expected';
  RS_BSON_STRING_WITH_VALUE_EXPECTED = 'Expected string with value "%s" but got "%s"';
  RS_BSON_INT_OR_STRING_EXPECTED = 'Integer or string value expected';
  RS_BSON_COLON_EXPECTED = 'Colon (":") expected';
  RS_BSON_COMMA_EXPECTED = 'Comma (",") expected';
  RS_BSON_QUOTE_EXPECTED = 'Double quotes (") expected';
  RS_BSON_CLOSE_BRACKET_EXPECTED = 'Close bracket ("]") expected';
  RS_BSON_CLOSE_BRACE_EXPECTED = 'Curly close brace ("}") expected';
  RS_BSON_COMMA_OR_CLOSE_BRACE_EXPECTED = 'Comma (",") or curly close brace ("}") expected';
  RS_BSON_STRING_OR_CLOSE_BRACE_EXPECTED = 'String or curly close brace ("}") expected';
  RS_BSON_INVALID_NUMBER = 'Invalid number';
  RS_BSON_INVALID_STRING = 'Invalid character string';
  RS_BSON_INVALID_DATE = 'Invalid date value';
  RS_BSON_INVALID_GUID = 'Invalid GUID value';
  RS_BSON_INVALID_NEW_STATEMENT = 'Invalid "new" statement';
  RS_BSON_INVALID_EXTENDED_JSON = 'Invalid extended JSON';
  RS_BSON_INVALID_BINARY_TYPE = 'Invalid binary type';
  RS_BSON_INVALID_REGEX = 'Invalid regular expression';
  RS_BSON_INVALID_UNICODE_CODEPOINT = 'Invalid Unicode codepoint';
  RS_BSON_JS_DATETIME_STRING_NOT_SUPPORTED = 'JavaScript date/time strings are not supported';

implementation

uses
  System.Math,
  System.Types,
  System.Character,
  System.RTLConsts,
  System.DateUtils,
  {$IF Defined(MACOS)}
  Macapi.CoreFoundation,
  {$ENDIF}
  {$IF CompilerVersion < 28.0}
  Lib.Helpers,
  {$ENDIF}
  Lib.SysUtils,
  Lib.DateUtils,
  Lib.Base64;

type
  TCharBuffer = record
  private const
    SIZE = 256;
  private type
    TBuffer = array [0..SIZE - 1] of Char;
    PBuffer = ^TBuffer;
  private
    FStatic: TBuffer;
    FDynamic: PBuffer;
    FCurrent: PChar;
    FCurrentEnd: PChar;
    FDynamicCount: Integer;
  public
    procedure Initialize; inline;
    procedure Release; inline;
    procedure Append(const AChar: Char); inline;
    function ToString: String; inline;
  end;

procedure TCharBuffer.Append(const AChar: Char);
begin
  if (FCurrent < FCurrentEnd) then
  begin
    FCurrent^ := AChar;
    Inc(FCurrent);
    Exit;
  end;

  ReallocMem(FDynamic, (FDynamicCount + 1) * SizeOf(TBuffer));
  FCurrent := PChar(FDynamic) + (FDynamicCount * SIZE);
  FCurrentEnd := FCurrent + SIZE;
  Inc(FDynamicCount);

  FCurrent^ := AChar;
  Inc(FCurrent);
end;

function TCharBuffer.ToString: String;
var
  I, StrIndex, TrailingLength: Integer;
  Src: PBuffer;
  Start: PChar;
begin
  if (FDynamic = nil) then
  begin
    Start := @FStatic;
    SetString(Result, Start, FCurrent - Start);
    Exit;
  end;

  TrailingLength := SIZE - (FCurrentEnd - FCurrent);
  SetLength(Result, (FDynamicCount * SIZE) + TrailingLength);
  Move(FStatic, Result[Low(String)], SizeOf(TBuffer));
  StrIndex := Low(String) + SIZE;

  Src := FDynamic;
  for I := 0 to FDynamicCount - 2 do
  begin
    Move(Src^, Result[StrIndex], SizeOf(TBuffer));
    Inc(Src);
    Inc(StrIndex, SIZE);
  end;

  Move(Src^, Result[StrIndex], TrailingLength * SizeOf(Char));
end;

procedure TCharBuffer.Initialize;
begin
  FDynamic := nil;
  FCurrent := @FStatic;
  FCurrentEnd := FCurrent + SIZE;
  FDynamicCount := 0;
end;

procedure TCharBuffer.Release;
begin
  FreeMem(FDynamic);
end;

{ EgoJsonParserError }

constructor EgoJsonParserError.Create(const AMsg: String;
  const ALineNumber, AColumnNumber, APosition: Integer);
begin
  inherited CreateFmt('(%d:%d) %s', [ALineNumber, AColumnNumber, AMsg]);
  FLineNumber := ALineNumber;
  FColumnNumber := AColumnNumber;
  FPosition := APosition;
end;

{ TBsonBaseWriter }

procedure TBsonBaseWriter.DoWriteBinaryData(
  const AValue: TBsonValue._IValue);
var
  Value: TBsonBinaryData;
begin
  _goGetBinaryData(AValue, Value);
  WriteBinaryData(Value);
end;

procedure TBsonBaseWriter.DoWriteDateTime(const AValue: TBsonValue._IValue);
var
  Value: TBsonDateTime;
begin
  _goGetDateTime(AValue, Value);
  WriteDateTime(Value.MillisecondsSinceEpoch);
end;

procedure TBsonBaseWriter.DoWriteJavaScript(
  const AValue: TBsonValue._IValue);
var
  Value: TBsonJavaScript;
begin
  _goGetJavaScript(AValue, Value);
  WriteJavaScript(Value.Code);
end;

procedure TBsonBaseWriter.DoWriteJavaScriptWithScope(
  const AValue: TBsonValue._IValue);
var
  Value: TBsonJavaScriptWithScope;
begin
  _goGetJavaScriptWithScope(AValue, Value);
  DoWriteJavaScriptWithScope(Value);
end;

procedure TBsonBaseWriter.DoWriteJavaScriptWithScope(
  const AValue: TBsonJavaScriptWithScope);
begin
  WriteJavaScriptWithScope(AValue.Code);
  WriteDocument(AValue.Scope._Impl);
end;

procedure TBsonBaseWriter.DoWriteRegularExpression(
  const AValue: TBsonValue._IValue);
var
  Value: TBsonRegularExpression;
begin
  _goGetRegularExpression(AValue, Value);
  WriteRegularExpression(Value);
end;

procedure TBsonBaseWriter.DoWriteSymbol(const AValue: TBsonValue._IValue);
var
  Value: TBsonSymbol;
begin
  _goGetSymbol(AValue, Value);
  WriteSymbol(Value.Name);
end;

procedure TBsonBaseWriter.DoWriteTimestamp(const AValue: TBsonValue._IValue);
var
  Value: TBsonTimestamp;
begin
  _goGetTimestamp(AValue, Value);
  WriteTimestamp(Value.Value);
end;

function TBsonBaseWriter.GetState: TBsonWriterState;
begin
  Result := FState;
end;

procedure TBsonBaseWriter.WriteArray(const AArray: TBsonArray._IArray);
var
  I: Integer;
  Item: TBsonValue._IValue;
begin
  WriteStartArray;

  for I := 0 to AArray.Count - 1 do
  begin
    AArray.GetItem(I, Item);
    WriteValueIntf(Item);
  end;

  WriteEndArray;
end;

procedure TBsonBaseWriter.WriteBoolean(const AName: String;
  const AValue: Boolean);
begin
  WriteName(AName);
  WriteBoolean(AValue);
end;

procedure TBsonBaseWriter.WriteBytes(const AValue: TBytes);
begin
  WriteBinaryData(TBsonBinaryData.Create(AValue));
end;

procedure TBsonBaseWriter.WriteBytes(const AName: String;
  const AValue: TBytes);
begin
  WriteName(AName);
  WriteBytes(AValue);
end;

procedure TBsonBaseWriter.WriteDateTime(const AName: String;
  const AMillisecondsSinceEpoch: Int64);
begin
  WriteName(AName);
  WriteDateTime(AMillisecondsSinceEpoch);
end;

procedure TBsonBaseWriter.WriteDocument(
  const ADocument: TBsonDocument._IDocument);
var
  I: Integer;
  Element: TBsonElement;
begin
  WriteStartDocument;

  for I := 0 to ADocument.Count - 1 do
  begin
    Element := ADocument.Elements[I];
    WriteName(Element.Name);
    WriteValueIntf(Element._Impl);
  end;

  WriteEndDocument;
end;

procedure TBsonBaseWriter.WriteDouble(const AName: String;
  const AValue: Double);
begin
  WriteName(AName);
  WriteDouble(AValue);
end;

procedure TBsonBaseWriter.WriteInt32(const AName: String;
  const AValue: Int32);
begin
  WriteName(AName);
  WriteInt32(AValue);
end;

procedure TBsonBaseWriter.WriteInt64(const AName: String;
  const AValue: Int64);
begin
  WriteName(AName);
  WriteInt64(AValue);
end;

procedure TBsonBaseWriter.WriteJavaScript(const AName, ACode: String);
begin
  WriteName(AName);
  WriteJavaScript(ACode);
end;

procedure TBsonBaseWriter.WriteJavaScriptWithScope(const AName,
  ACode: String);
begin
  WriteName(AName);
  WriteJavaScriptWithScope(ACode);
end;

procedure TBsonBaseWriter.WriteMaxKey(const AName: String);
begin
  WriteName(AName);
  WriteMaxKey;
end;

procedure TBsonBaseWriter.WriteMinKey(const AName: String);
begin
  WriteName(AName);
  WriteMinKey;
end;

procedure TBsonBaseWriter.WriteName(const AName: String);
begin
  if (State <> TBsonWriterState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FName := AName;
  FState := TBsonWriterState.Value;
end;

procedure TBsonBaseWriter.WriteNull(const AName: String);
begin
  WriteName(AName);
  WriteNull;
end;

procedure TBsonBaseWriter.WriteObjectId(const AName: String;
  const AValue: TObjectId);
begin
  WriteName(AName);
  WriteObjectId(AValue);
end;

procedure TBsonBaseWriter.WriteRegularExpression(const AName: String;
  const AValue: TBsonRegularExpression);
begin
  WriteName(AName);
  WriteRegularExpression(AValue);
end;

procedure TBsonBaseWriter.WriteStartArray(const AName: String);
begin
  WriteName(AName);
  WriteStartArray;
end;

procedure TBsonBaseWriter.WriteStartDocument(const AName: String);
begin
  WriteName(AName);
  WriteStartDocument;
end;

procedure TBsonBaseWriter.WriteString(const AName, AValue: String);
begin
  WriteName(AName);
  WriteString(AValue);
end;

procedure TBsonBaseWriter.WriteSymbol(const AName, AValue: String);
begin
  WriteName(AName);
  WriteSymbol(AValue);
end;

procedure TBsonBaseWriter.WriteTimestamp(const AName: String;
  const AValue: Int64);
begin
  WriteName(AName);
  WriteTimestamp(AValue);
end;

procedure TBsonBaseWriter.WriteUndefined(const AName: String);
begin
  WriteName(AName);
  WriteUndefined;
end;

procedure TBsonBaseWriter.WriteValue(const AValue: TBsonValue);
begin
  if (AValue.IsNil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  case AValue.BsonType of
    TBsonType.EndOfDocument      : ;
    TBsonType.Double             : WriteDouble(AValue.AsDouble);
    TBsonType.&String            : WriteString(AValue.AsString);
    TBsonType.Document           : WriteDocument(TBsonDocument._IDocument(AValue._Impl));
    TBsonType.&Array             : WriteArray(TBsonArray._IArray(AValue._Impl));
    TBsonType.Binary             : DoWriteBinaryData(AValue._Impl);
    TBsonType.Undefined          : WriteUndefined;
    TBsonType.ObjectId           : WriteObjectId(AValue.AsObjectId);
    TBsonType.Boolean            : WriteBoolean(AValue.AsBoolean);
    TBsonType.DateTime           : DoWriteDateTime(AValue._Impl);
    TBsonType.Null               : WriteNull;
    TBsonType.RegularExpression  : DoWriteRegularExpression(AValue._Impl);
    TBsonType.JavaScript         : DoWriteJavaScript(AValue._Impl);
    TBsonType.Symbol             : DoWriteSymbol(AValue._Impl);
    TBsonType.JavaScriptWithScope: DoWriteJavaScriptWithScope(AValue._Impl);
    TBsonType.Int32              : WriteInt32(AValue.AsInteger);
    TBsonType.Timestamp          : DoWriteTimestamp(AValue._Impl);
    TBsonType.Int64              : WriteInt64(AValue.AsInt64);
    TBsonType.MaxKey             : WriteMaxKey;
    TBsonType.MinKey             : WriteMinKey;
  else
    Assert(False);
  end;
end;

procedure TBsonBaseWriter.WriteValueIntf(const AValue: TBsonValue._IValue);
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  case AValue.BsonType of
    TBsonType.EndOfDocument      : ;
    TBsonType.Double             : WriteDouble(AValue.AsDouble);
    TBsonType.&String            : WriteString(AValue.AsString);
    TBsonType.Document           : WriteDocument(TBsonDocument._IDocument(AValue));
    TBsonType.&Array             : WriteArray(TBsonArray._IArray(AValue));
    TBsonType.Binary             : DoWriteBinaryData(AValue);
    TBsonType.Undefined          : WriteUndefined;
    TBsonType.ObjectId           : WriteObjectId(AValue.AsObjectId);
    TBsonType.Boolean            : WriteBoolean(AValue.AsBoolean);
    TBsonType.DateTime           : DoWriteDateTime(AValue);
    TBsonType.Null               : WriteNull;
    TBsonType.RegularExpression  : DoWriteRegularExpression(AValue);
    TBsonType.JavaScript         : DoWriteJavaScript(AValue);
    TBsonType.Symbol             : DoWriteSymbol(AValue);
    TBsonType.JavaScriptWithScope: DoWriteJavaScriptWithScope(AValue);
    TBsonType.Int32              : WriteInt32(AValue.AsInteger);
    TBsonType.Timestamp          : DoWriteTimestamp(AValue);
    TBsonType.Int64              : WriteInt64(AValue.AsInt64);
    TBsonType.MaxKey             : WriteMaxKey;
    TBsonType.MinKey             : WriteMinKey;
  else
    Assert(False);
  end;
end;

{ TBsonWriter }

procedure TBsonWriter.BackpatchSize;
var
  Size: Integer;
begin
  Assert(Assigned(FContext));
  Size := FOutput.Position - FContext.StartPosition;
  FOutput.WriteInt32At(FContext.StartPosition, Size);
end;

constructor TBsonWriter.Create;
begin
  inherited Create;
  FOutput.Initialize;
  FContextIndex := -1;
end;

function TBsonWriter.GetNextState: TBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.&Array) then
    Result := TBsonWriterState.Value
  else
    Result := TBsonWriterState.Name;
end;

procedure TBsonWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TBsonWriter.PushContext(const AContextType: TBsonContextType;
  const AStartPosition: Integer);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AStartPosition);
  FContext := @FContextStack[FContextIndex];
end;

function TBsonWriter.ToBson: TBytes;
begin
  Result := FOutput.ToBytes;
end;

procedure TBsonWriter.WriteBinaryData(const AValue: TBsonBinaryData);
var
  Bytes: TBytes;
  SubType: TBsonBinarySubType;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Bytes := AValue.AsBytes;
  SubType := AValue.SubType;
  if (SubType = TBsonBinarySubType.OldBinary) then
    SubType := TBsonBinarySubType.Binary;

  FOutput.WriteBsonType(TBsonType.Binary);
  WriteNameHelper;

  FOutput.WriteInt32(Length(Bytes));
  FOutput.WriteBinarySubType(SubType);
  if Assigned(Bytes) then
    FOutput.Write(Bytes[0], Length(Bytes));
  State := GetNextState;
end;

procedure TBsonWriter.WriteBoolean(const AValue: Boolean);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Boolean);
  WriteNameHelper;
  FOutput.WriteBoolean(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteDateTime(const AMillisecondsSinceEpoch: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.DateTime);
  WriteNameHelper;
  FOutput.WriteInt64(AMillisecondsSinceEpoch);
  State := GetNextState;
end;

procedure TBsonWriter.WriteDouble(const AValue: Double);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Double);
  WriteNameHelper;
  FOutput.WriteDouble(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteEndArray;
begin
  Assert(Assigned(FContext));
  if (State <> TBsonWriterState.Value) or (FContext.ContextType <> TBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteByte(0);
  BackpatchSize;

  PopContext;
  if (FContext = nil) then
    State := TBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TBsonWriter.WriteEndDocument;
begin
  Assert(Assigned(FContext));
  if (State <> TBsonWriterState.Name) or
    (not (FContext.ContextType in [TBsonContextType.Document, TBsonContextType.ScopeDocument]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteByte(0);
  BackpatchSize;

  PopContext;
  if (FContext = nil) then
    State := TBsonWriterState.Done
  else
  begin
    if (FContext.ContextType = TBsonContextType.JavaScriptWithScope) then
    begin
      BackpatchSize;
      PopContext;
    end;
    State := GetNextState;
  end;
end;

procedure TBsonWriter.WriteInt32(const AValue: Integer);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Int32);
  WriteNameHelper;
  FOutput.WriteInt32(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteInt64(const AValue: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Int64);
  WriteNameHelper;
  FOutput.WriteInt64(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteJavaScript(const ACode: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.JavaScript);
  WriteNameHelper;
  FOutput.WriteString(ACode);
  State := GetNextState;
end;

procedure TBsonWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.JavaScriptWithScope);
  WriteNameHelper;
  PushContext(TBsonContextType.JavaScriptWithScope, FOutput.Position);
  FOutput.WriteInt32(0);  // Reserve space
  FOutput.WriteString(ACode);
  State := TBsonWriterState.ScopeDocument;
end;

procedure TBsonWriter.WriteMaxKey;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.MaxKey);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TBsonWriter.WriteMinKey;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.MinKey);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TBsonWriter.WriteNameHelper;
var
  Index: Integer;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.&Array) then
  begin
    Index := FContext.Index;
    FContext.Index := Index + 1;
    FOutput.WriteCString(TArrayElementNameAccelerator.GetElementNameBytes(Index));
  end
  else
    FOutput.WriteCString(Name);
end;

procedure TBsonWriter.WriteNull;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Null);
  WriteNameHelper;
  State := GetNextState;
end;

procedure TBsonWriter.WriteObjectId(const AValue: TObjectId);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.ObjectId);
  WriteNameHelper;
  FOutput.WriteObjectId(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteRawBsonDocument(const ADocument: TBytes);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value,
    TBsonWriterState.ScopeDocument, TBsonWriterState.Done]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TBsonType.Document);
    WriteNameHelper;
  end;

  FOutput.Write(ADocument[0], Length(ADocument));

  if (FContext = nil) then
    State := TBsonWriterState.Done
  else
  begin
    if (FContext.ContextType = TBsonContextType.JavaScriptWithScope) then
    begin
      BackpatchSize;
      PopContext;
    end;
    State := GetNextState;
  end;
end;

procedure TBsonWriter.WriteRegularExpression(
  const AValue: TBsonRegularExpression);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.RegularExpression);
  WriteNameHelper;

  FOutput.WriteCString(AValue.Pattern);
  FOutput.WriteCString(AValue.Options);

  State := GetNextState;
end;

procedure TBsonWriter.WriteStartArray;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TBsonType.&Array);
    WriteNameHelper;
  end;

  PushContext(TBsonContextType.&Array, FOutput.Position);
  FOutput.WriteInt32(0); // Reserve space for size
  State := TBsonWriterState.Value;
end;

procedure TBsonWriter.WriteStartDocument;
var
  ContextType: TBsonContextType;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value,
    TBsonWriterState.ScopeDocument, TBsonWriterState.Done]))
  then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State = TBsonWriterState.Value) then
  begin
    FOutput.WriteBsonType(TBsonType.Document);
    WriteNameHelper;
  end;

  if (State = TBsonWriterState.ScopeDocument) then
    ContextType := TBsonContextType.ScopeDocument
  else
    ContextType := TBsonContextType.Document;

  PushContext(ContextType, FOutput.Position);
  FOutput.WriteInt32(0); // Reserve space for size

  State := TBsonWriterState.Name;
end;

procedure TBsonWriter.WriteString(const AValue: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.String);
  WriteNameHelper;
  FOutput.WriteString(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteSymbol(const AValue: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Symbol);
  WriteNameHelper;
  FOutput.WriteString(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteTimestamp(const AValue: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Timestamp);
  WriteNameHelper;
  FOutput.WriteInt64(AValue);
  State := GetNextState;
end;

procedure TBsonWriter.WriteUndefined;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.WriteBsonType(TBsonType.Undefined);
  WriteNameHelper;
  State := GetNextState;
end;

{ TBsonWriter.TOutput }

procedure TBsonWriter.TOutput.Initialize;
begin
  SetLength(FBuffer, 256);
  FCapacity := 256;
  FSize := 0;
  SetLength(FTempBytes, TEMP_BYTES_LENGTH);
end;

function TBsonWriter.TOutput.ToBytes: TBytes;
begin
  SetLength(FBuffer, FSize);
  Result := FBuffer;
end;

procedure TBsonWriter.TOutput.Write(const AValue; const ASize: Integer);
begin
  if ((FSize + ASize) > FCapacity) then
  begin
    repeat
      FCapacity := FCapacity shl 1;
    until (FCapacity >= (FSize + ASize));
    SetLength(FBuffer, FCapacity);
  end;
  Move(AValue, FBuffer[FSize], ASize);
  Inc(FSize, ASize);
end;

procedure TBsonWriter.TOutput.WriteBinarySubType(
  const ASubType: TBsonBinarySubType);
begin
  Write(ASubType, 1);
end;

procedure TBsonWriter.TOutput.WriteBoolean(const AValue: Boolean);
begin
  Write(AValue, 1);
end;

procedure TBsonWriter.TOutput.WriteBsonType(const ABsonType: TBsonType);
begin
  Write(ABsonType, 1);
end;

procedure TBsonWriter.TOutput.WriteByte(const AValue: Byte);
begin
  Write(AValue, 1);
end;

procedure TBsonWriter.TOutput.WriteCString(const AValue: String);
var
  CharCount, Utf8Count: Integer;
  Bytes: TBytes;
begin
  CharCount := AValue.Length;
  if (((CharCount + 1) * 3) <= TEMP_BYTES_LENGTH) then
  begin
    Bytes := FTempBytes;
    Utf8Count := goUtf16ToUtf8(AValue, CharCount, FTempBytes);
  end
  else
  begin
    Bytes := goUtf16ToUtf8(AValue);
    Utf8Count := Length(Bytes);
  end;
  Write(Bytes[0], Utf8Count);
  WriteByte(0);
end;

procedure TBsonWriter.TOutput.WriteCString(const AValue: TBytes);
begin
  Write(AValue[0], Length(AValue));
  WriteByte(0);
end;

procedure TBsonWriter.TOutput.WriteDouble(const AValue: Double);
begin
  Write(AValue, 8);
end;

procedure TBsonWriter.TOutput.WriteInt32(const AValue: Int32);
begin
  Write(AValue, 4);
end;

procedure TBsonWriter.TOutput.WriteInt32At(const APosition, AValue: Int32);
begin
  Move(AValue, FBuffer[APosition], 4);
end;

procedure TBsonWriter.TOutput.WriteInt64(const AValue: Int64);
begin
  Write(AValue, 8);
end;

procedure TBsonWriter.TOutput.WriteObjectId(const AValue: TObjectId);
begin
  AValue.ToByteArray(FTempBytes, 0);
  Write(FTempBytes[0], 12);
end;

procedure TBsonWriter.TOutput.WriteString(const AValue: String);
var
  CharCount, Utf8Count: Integer;
  Bytes: TBytes;
begin
  CharCount := AValue.Length;
  if (((CharCount + 1) * 3) <= TEMP_BYTES_LENGTH) then
  begin
    Bytes := FTempBytes;
    Utf8Count := goUtf16ToUtf8(AValue, CharCount, Bytes);
  end
  else
  begin
    Bytes := goUtf16ToUtf8(AValue);
    Utf8Count := Length(Bytes);
  end;
  WriteInt32(Utf8Count + 1);
  Write(Bytes[0], Utf8Count);
  WriteByte(0);
end;

{ TBsonWriter.TContext }

procedure TBsonWriter.TContext.Initialize(const AContextType: TBsonContextType;
  const AStartPosition: Integer);
begin
  FStartPosition := AStartPosition;
  FIndex := 0;
  FContextType := AContextType;
end;

{ TBsonWriter.TArrayElementNameAccelerator }

class constructor TBsonWriter.TArrayElementNameAccelerator.Create;
var
  I: Integer;
begin
  for I := 0 to Length(FCachedElementNames) - 1 do
    FCachedElementNames[I] := CreateElementNameBytes(I);
end;

class function TBsonWriter.TArrayElementNameAccelerator.CreateElementNameBytes(
  const AIndex: Integer): TBytes;
const
  ASCII_ZERO = 48;
var
  A, B, C, D, E, N: Integer;
begin
  N := AIndex;
  A := ASCII_ZERO + (N mod 10);
  B := ASCII_ZERO;
  C := ASCII_ZERO;
  D := ASCII_ZERO;
  E := ASCII_ZERO;
  N := N div 10;
  if (N > 0) then
  begin
    Inc(B, N mod 10);
    N := N div 10;
    if (N > 0) then
    begin
      Inc(C, N mod 10);
      N := N div 10;
      if (N > 0) then
      begin
        Inc(D, N mod 10);
        N := N div 10;
        if (N > 0) then
        begin
          Inc(E, N mod 10);
          N := N div 10;
        end;
      end;
    end;
  end;

  if (N = 0) then
  begin
    if (E <> ASCII_ZERO) then
      Exit(TBytes.Create(E, D, C, B, A));

    if (D <> ASCII_ZERO) then
      Exit(TBytes.Create(D, C, B, A));

    if (C <> ASCII_ZERO) then
      Exit(TBytes.Create(C, B, A));

    if (B <> ASCII_ZERO) then
      Exit(TBytes.Create(B, A));

    Exit(TBytes.Create(A));
  end;

  Result := BytesOf(IntToStr(AIndex));
end;

class function TBsonWriter.TArrayElementNameAccelerator.GetElementNameBytes(
  const AIndex: Integer): TBytes;
begin
  Assert(AIndex >= 0);
  if (AIndex < Length(FCachedElementNames)) then
    Result := FCachedElementNames[AIndex]
  else
    Result := CreateElementNameBytes(AIndex);
end;

{ TJsonWriter }

constructor TJsonWriter.Create;
begin
  Create(TJsonWriterSettings.Default);
end;

constructor TJsonWriter.Create(const ASettings: TJsonWriterSettings);
begin
  inherited Create;
  FSettings := ASettings;
  FOutput.Initialize;
  FContextIndex := -1;
  PushContext(TBsonContextType.TopLevel, '');
end;

destructor TJsonWriter.Destroy;
begin
  FOutput.Finalize;
  inherited;
end;

function TJsonWriter.GetNextState: TBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType in [TBsonContextType.TopLevel, TBsonContextType.&Array]) then
    Result := TBsonWriterState.Value
  else
    Result := TBsonWriterState.Name;
end;

class function TJsonWriter.GuidToString(const ABytes: TBytes;
  const ASubType: TBsonBinarySubType): String;
var
  Guid: TGUID;
  S: String;
begin
  if (Length(ABytes) <> 16) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  if (ASubType = TBsonBinarySubType.UuidLegacy) then
  begin
    // We only support output to C# legacy
    Result := 'CSUUID("';
    {$IF CompilerVersion >= 28.0}
    Guid := TGuid.Create(ABytes, TEndian.Little);
    {$ELSE}
    Guid := TGuid.Create(ABytes);
    {$ENDIF}
  end
  else
  begin
    Result := 'UUID("';
    {$IF CompilerVersion >= 28.0}
    Guid := TGuid.Create(ABytes, TEndian.Big);
    {$ELSE}
    Guid := TGuid.Create(ABytes);
    {$ENDIF}
  end;

  S := Guid.ToString.ToLower; // Include '{' and '}'
  Result := Result + S.Substring(1, S.Length - 2) + '")';
end;

procedure TJsonWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TJsonWriter.PushContext(const AContextType: TBsonContextType;
  const AIndentString: String);
var
  ParentContext: PContext;
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);

  if (FContextIndex > 0) then
    ParentContext := @FContextStack[FContextIndex - 1]
  else
    ParentContext := nil;

  FContextStack[FContextIndex].Initialize(ParentContext, AContextType, AIndentString);
  FContext := @FContextStack[FContextIndex];
end;

function TJsonWriter.ToJson: String;
begin
  Result := FOutput.ToString;
end;

procedure TJsonWriter.WriteBinaryData(const AValue: TBsonBinaryData);
var
  SubType: TBsonBinarySubType;
  Bytes: TBytes;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  SubType := AValue.SubType;
  Bytes := AValue.AsBytes;
  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$binary" : "');
    FOutput.Append(TEncoding.ANSI.GetString(Base64Encode(Bytes)));
    FOutput.AppendFormat('", "$type" : "%.2x" }', [Ord(SubType)]);
  end
  else if (SubType in [TBsonBinarySubType.UuidLegacy, TBsonBinarySubType.UuidStandard]) then
    FOutput.Append(GuidToString(Bytes, SubType))
  else
  begin
    FOutput.Append('new BinData(');
    FOutput.Append(Ord(SubType));
    FOutput.Append(', "');
    FOutput.Append(TEncoding.ANSI.GetString(Base64Encode(Bytes)));
    FOutput.Append('")');
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteBoolean(const AValue: Boolean);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  if (AValue) then
    FOutput.Append('true')
  else
    FOutput.Append('false');
  State := GetNextState;
end;

procedure TJsonWriter.WriteDateTime(const AMillisecondsSinceEpoch: Int64);
var
  DateTime: TDateTime;
  S: String;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$date" : ');
    FOutput.Append(AMillisecondsSinceEpoch);
    FOutput.Append(' }');
  end
  else
  begin
    if (AMillisecondsSinceEpoch >= MIN_MILLISECONDS_SINCE_EPOCH) and
       (AMillisecondsSinceEpoch <= MAX_MILLISECONDS_SINCE_EPOCH) then
    begin
      DateTime := ToDateTimeFromMillisecondsSinceEpoch(AMillisecondsSinceEpoch, True);
      FOutput.Append('ISODate("');
      S := DateToISO8601(DateTime, True);
      if (S.EndsWith('.000Z')) then
        { Only include milliseconds if not 0 }
        S := S.Remove(S.Length - 5, 4);
      FOutput.Append(S);
      FOutput.Append('")');
    end
    else
    begin
      FOutput.Append('new Date(');
      FOutput.Append(AMillisecondsSinceEpoch);
      FOutput.Append(')');
    end;
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteDouble(const AValue: Double);
var
  S: String;
  I: Int64;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  S := FloatToStr(AValue, goUSFormatSettings);
  if (S = 'NAN') then
    S := 'NaN' // JSON compliant
  else if (S = 'INF') then
    S := 'Infinity'
  else if (S = '-INF') then
    S := '-Infinity'
  else if (TryStrToInt64(S, I)) then
    { If S looks like an integer, then add ".0" }
    S := S + '.0';

  FOutput.Append(S);

  State := GetNextState;
end;

procedure TJsonWriter.WriteEndArray;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  FOutput.Append(']');
  PopContext;
  State := GetNextState;
end;

procedure TJsonWriter.WriteEndDocument;
begin
  if (State <> TBsonWriterState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Assert(Assigned(FContext));
  if (FSettings.PrettyPrint) and (FContext.HasElements) then
  begin
    FOutput.Append(FSettings.LineBreak);
    if (FContextIndex > 0) then
      FOutput.Append(FContextStack[FContextIndex - 1].Indentation);
    FOutput.Append('}');
  end
  else
    FOutput.Append(' }');

  if (FContext.ContextType = TBsonContextType.ScopeDocument) then
  begin
    PopContext;
    WriteEndDocument;
  end
  else
    PopContext;

  if (FContext = nil) then
    State := TBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TJsonWriter.WriteEscapedString(const AValue: String);
var
  I: Integer;
  C: Char;
begin
  for I := Low(String) to Low(String) + Length(AValue) - 1 do
  begin
    C := AValue[I];
    case C of
      '"', '\':
        begin
          FOutput.Append('\');
          FOutput.Append(C);
        end;

       #8: FOutput.Append('\b');
       #9: FOutput.Append('\t');
      #10: FOutput.Append('\n');
      #12: FOutput.Append('\f');
      #13: FOutput.Append('\r');
    else
      if (C < ' ') or (C >= #$0080) then
      begin
        FOutput.Append('\u');
        FOutput.Append(LowerCase(IntToHex(Ord(C), 4)));
      end
      else
        FOutput.Append(C);
    end;
  end;
end;

procedure TJsonWriter.WriteInt32(const AValue: Integer);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append(AValue);
  State := GetNextState;
end;

procedure TJsonWriter.WriteInt64(const AValue: Int64);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
    FOutput.Append(AValue)
  else
  begin
    if (AValue >= Low(Integer)) and (AValue <= High(Integer)) then
    begin
      FOutput.Append('NumberLong(');
      FOutput.Append(AValue);
      FOutput.Append(')');
    end
    else
    begin
      FOutput.Append('NumberLong("');
      FOutput.Append(AValue);
      FOutput.Append('")');
    end;
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteJavaScript(const ACode: String);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('{ "$code" : "');
  WriteEscapedString(ACode);
  FOutput.Append('" }');
  State := GetNextState;
end;

procedure TJsonWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteStartDocument;
  WriteName('$code');
  WriteString(ACode);
  WriteName('$scope');

  State := TBsonWriterState.ScopeDocument;
end;

procedure TJsonWriter.WriteMaxKey;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
    FOutput.Append('{ "$maxKey" : 1 }')
  else
    FOutput.Append('MaxKey');

  State := GetNextState;
end;

procedure TJsonWriter.WriteMinKey;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
    FOutput.Append('{ "$minKey" : 1 }')
  else
    FOutput.Append('MinKey');

  State := GetNextState;
end;

procedure TJsonWriter.WriteNameHelper(const AName: String);
begin
  Assert(Assigned(FContext));
  case FContext.ContextType of
    TBsonContextType.&Array:
      begin
        if (FContext.HasElements) then
          FOutput.Append(', ');
      end;

    TBsonContextType.Document,
    TBsonContextType.ScopeDocument:
      begin
        if (FContext.HasElements) then
          FOutput.Append(',');

        if (FSettings.PrettyPrint) then
        begin
          FOutput.Append(FSettings.LineBreak);
          FOutput.Append(FContext.Indentation);
        end
        else
          FOutput.Append(' ');

        WriteQuotedString(AName);
        FOutput.Append(' : ');
      end;

    TBsonContextType.TopLevel: ;
  else
    Assert(False);
  end;
  FContext.HasElements := True;
end;

procedure TJsonWriter.WriteNull;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('null');
  State := GetNextState;
end;

procedure TJsonWriter.WriteObjectId(const AValue: TObjectId);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$oid" : "');
    FOutput.Append(AValue.ToString);
    FOutput.Append('" }');
  end
  else
  begin
    FOutput.Append('ObjectId("');
    FOutput.Append(AValue.ToString);
    FOutput.Append('")');
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteQuotedString(const AValue: String);
begin
  FOutput.Append('"');
  WriteEscapedString(AValue);
  FOutput.Append('"');
end;

procedure TJsonWriter.WriteRaw(const AValue: String);
begin
  FOutput.Append(AValue)
end;

procedure TJsonWriter.WriteRegularExpression(
  const AValue: TBsonRegularExpression);
var
  Pattern, Options: String;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Pattern := AValue.Pattern;
  Options := AValue.Options;

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$regex" : "');
    WriteEscapedString(Pattern);
    FOutput.Append('", "$options" : "');
    WriteEscapedString(Options);
    FOutput.Append('" }');
  end
  else
  begin
    if (Pattern = '') then
      Pattern := '(?:)'
    else
      Pattern := Pattern.Replace('/', '\/', [rfReplaceAll]);
    FOutput.Append('/');
    FOutput.Append(Pattern);
    FOutput.Append('/');
    FOutput.Append(Options);
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteStartArray;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  FOutput.Append('[');

  PushContext(TBsonContextType.&Array, FSettings.Indent);
  State := TBsonWriterState.Value;
end;

procedure TJsonWriter.WriteStartDocument;
var
  ContextType: TBsonContextType;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value, TBsonWriterState.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  if (State in [TBsonWriterState.Value, TBsonWriterState.ScopeDocument]) then
    WriteNameHelper(Name);

  FOutput.Append('{');

  if (State = TBsonWriterState.ScopeDocument) then
    ContextType := TBsonContextType.ScopeDocument
  else
    ContextType := TBsonContextType.Document;

  PushContext(ContextType, FSettings.Indent);
  State := TBsonWriterState.Name;
end;

procedure TJsonWriter.WriteString(const AValue: String);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);
  WriteQuotedString(AValue);
  State := GetNextState;
end;

procedure TJsonWriter.WriteSymbol(const AValue: String);
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  FOutput.Append('{ "$symbol" : "');
  WriteEscapedString(AValue);
  FOutput.Append('" }');

  State := GetNextState;
end;

procedure TJsonWriter.WriteTimestamp(const AValue: Int64);
var
  SecondsSinceEpoch, Increment: Integer;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  SecondsSinceEpoch := AValue shr 32;
  Increment := AValue and $FFFFFFFF;

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
  begin
    FOutput.Append('{ "$timestamp" : { "t" : ');
    FOutput.Append(SecondsSinceEpoch);
    FOutput.Append(', "i" : ');
    FOutput.Append(Increment);
    FOutput.Append(' } }');
  end
  else
  begin
    FOutput.Append('Timestamp(');
    FOutput.Append(SecondsSinceEpoch);
    FOutput.Append(', ');
    FOutput.Append(Increment);
    FOutput.Append(')');
  end;

  State := GetNextState;
end;

procedure TJsonWriter.WriteUndefined;
begin
  if (not (State in [TBsonWriterState.Initial, TBsonWriterState.Value])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  WriteNameHelper(Name);

  if (FSettings.OutputMode = TJsonOutputMode.Strict) then
    FOutput.Append('{ "$undefined" : true }')
  else
    FOutput.Append('undefined');

  State := GetNextState;
end;

{ TJsonWriter.TContext }

procedure TJsonWriter.TContext.Initialize(const AParentContext: PContext;
  const AContextType: TBsonContextType;
  const AIndentString: String);
begin
  if Assigned(AParentContext) then
    FIndentation := AParentContext.FIndentation + AIndentString
  else
    FIndentation := AIndentString;
  FContextType := AContextType;
  FHasElements := False;
end;

{ TJsonWriter.TOutput }

procedure TJsonWriter.TOutput.Append(const AValue: String);
begin
  if (AValue <> '') then
    Append(AValue[Low(String)], Length(AValue) * SizeOf(Char));
end;

procedure TJsonWriter.TOutput.Append(const AValue: Integer);
begin
  Append(IntToStr(AValue));
end;

procedure TJsonWriter.TOutput.Append(const AValue: Int64);
begin
  Append(IntToStr(AValue));
end;

procedure TJsonWriter.TOutput.Append(const AValue; const ASize: Integer);
begin
  if ((FSize + ASize) > FCapacity) then
  begin
    repeat
      FCapacity := FCapacity shl 1;
    until (FCapacity >= (FSize + ASize));
    ReallocMem(FBuffer, FCapacity);
  end;
  Move(AValue, FBuffer[FSize], ASize);
  Inc(FSize, ASize);
end;

procedure TJsonWriter.TOutput.Append(const AValue: Char);
begin
  Append(AValue, SizeOf(Char));
end;

procedure TJsonWriter.TOutput.AppendFormat(const AValue: String;
  const AArgs: array of const);
begin
  Append(Format(AValue, AArgs));
end;

procedure TJsonWriter.TOutput.Finalize;
begin
  FreeMem(FBuffer);
  FBuffer := nil;
end;

procedure TJsonWriter.TOutput.Initialize;
begin
  GetMem(FBuffer, 512);
  FCapacity := 512;
  FSize := 0;
end;

function TJsonWriter.TOutput.ToString: String;
begin
  SetString(Result, PChar(FBuffer), FSize shr 1);
end;

{ TBsonDocumentWriter }

procedure TBsonDocumentWriter.AddValue(const AValue: TBsonValue);
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.&Array) then
    FContext.&Array.Add(AValue)
  else
    FContext.Document.Add(FContext.Name, AValue);
end;

constructor TBsonDocumentWriter.Create(const ADocument: TBsonDocument);
begin
  inherited Create;
  FDocument := ADocument;
  FContextIndex := -1;
end;

function TBsonDocumentWriter.GetDocument: TBsonDocument;
begin
  Result := FDocument;
end;

function TBsonDocumentWriter.GetNextState: TBsonWriterState;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.&Array) then
    Result := TBsonWriterState.Value
  else
    Result := TBsonWriterState.Name;
end;

procedure TBsonDocumentWriter.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentWriter.PushContext(
  const AContextType: TBsonContextType; const ACode: String);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ACode);
  FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentWriter.PushContext(
  const AContextType: TBsonContextType; const AArray: TBsonArray);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AArray);
  FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentWriter.PushContext(
  const AContextType: TBsonContextType; const ADocument: TBsonDocument);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ADocument);
  FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentWriter.WriteBinaryData(
  const AValue: TBsonBinaryData);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteBoolean(const AValue: Boolean);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteDateTime(
  const AMillisecondsSinceEpoch: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonDateTime.Create(AMillisecondsSinceEpoch));
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteDouble(const AValue: Double);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteEndArray;
var
  A: TBsonArray;
begin
  Assert(Assigned(FContext));
  if (State <> TBsonWriterState.Value) or (FContext.ContextType <> TBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  A := FContext.&Array;
  PopContext;
  AddValue(A);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteEndDocument;
var
  Document: TBsonDocument;
  Code: String;
begin
  Assert(Assigned(FContext));
  if (State <> TBsonWriterState.Name) or (not (FContext.ContextType in [TBsonContextType.Document, TBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);

  Document := FContext.Document;
  if (FContext.ContextType = TBsonContextType.ScopeDocument) then
  begin
    PopContext;
    Assert(Assigned(FContext));
    Code := FContext.Code;
    PopContext;
    AddValue(TBsonJavaScriptWithScope.Create(Code, Document));
  end
  else
  begin
    PopContext;
    if (FContext <> nil) then
      AddValue(Document);
  end;

  if (FContext = nil) then
    State := TBsonWriterState.Done
  else
    State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteInt32(const AValue: Integer);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteInt64(const AValue: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteJavaScript(const ACode: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonJavaScript.Create(ACode));
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteJavaScriptWithScope(const ACode: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  PushContext(TBsonContextType.JavaScriptWithScope, ACode);
  State := TBsonWriterState.ScopeDocument;
end;

procedure TBsonDocumentWriter.WriteMaxKey;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonMaxKey.Value);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteMinKey;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonMinKey.Value);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteName(const AName: String);
begin
  inherited;
  Assert(Assigned(FContext));
  FContext.Name := AName;
end;

procedure TBsonDocumentWriter.WriteNull;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonNull.Value);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteObjectId(const AValue: TObjectId);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteRegularExpression(
  const AValue: TBsonRegularExpression);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteStartArray;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  PushContext(TBsonContextType.&Array, TBsonArray.Create);
  State := TBsonWriterState.Value;
end;

procedure TBsonDocumentWriter.WriteStartDocument;
begin
  case State of
    TBsonWriterState.Initial,
    TBsonWriterState.Done:
      PushContext(TBsonContextType.Document, FDocument);

    TBsonWriterState.Value:
      PushContext(TBsonContextType.Document, TBsonDocument.Create);

    TBsonWriterState.ScopeDocument:
      PushContext(TBsonContextType.ScopeDocument, TBsonDocument.Create);
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  end;
  State := TBsonWriterState.Name;
end;

procedure TBsonDocumentWriter.WriteString(const AValue: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(AValue);
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteSymbol(const AValue: String);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonSymbolTable.Lookup(AValue));
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteTimestamp(const AValue: Int64);
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonTimestamp.Create(AValue));
  State := GetNextState;
end;

procedure TBsonDocumentWriter.WriteUndefined;
begin
  if (State <> TBsonWriterState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_WRITER_STATE);
  AddValue(TBsonUndefined.Value);
  State := GetNextState;
end;

{ TBsonDocumentWriter.TContext }

procedure TBsonDocumentWriter.TContext.Initialize(
  const AContextType: TBsonContextType; const ADocument: TBsonDocument);
begin
  FContextType := AContextType;
  FDocument := ADocument;
end;

procedure TBsonDocumentWriter.TContext.Initialize(
  const AContextType: TBsonContextType; const AArray: TBsonArray);
begin
  FContextType := AContextType;
  FArray := AArray;
end;

procedure TBsonDocumentWriter.TContext.Initialize(
  const AContextType: TBsonContextType; const ACode: String);
begin
  FContextType := AContextType;
  FCode := ACode;
end;

{ TBsonBaseReader }

function TBsonBaseReader.DoReadJavaScriptWithScope: TBsonValue;
var
  Code: String;
  Scope: TBsonDocument;
begin
  Code := ReadJavaScriptWithScope;
  Scope := ReadDocument;
  Result := TBsonJavaScriptWithScope.Create(Code, Scope);
end;

procedure TBsonBaseReader.EnsureBsonTypeEquals(const ABsonType: TBsonType);
begin
  if (GetCurrentBsonType <> ABsonType) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

function TBsonBaseReader.GetCurrentBsonType: TBsonType;
begin
  if (FState in [TBsonReaderState.Initial, TBsonReaderState.ScopeDocument, TBsonReaderState.&Type]) then
    ReadBsonType;

  if (FState <> TBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Result := FCurrentBsonType;
end;

function TBsonBaseReader.GetState: TBsonReaderState;
begin
  Result := FState;
end;

function TBsonBaseReader.ReadArray: TBsonArray;
var
  Item: TBsonValue._IValue;
  Arr: TBsonArray._IArray;
begin
  EnsureBsonTypeEquals(TBsonType.&Array);

  ReadStartArray;
  Result := TBsonArray.Create;
  Arr := Result._Impl;
  while (ReadBsonType <> TBsonType.EndOfDocument) do
  begin
    Item := ReadValueIntf;
    Arr.Add(Item);
  end;
  ReadEndArray;
end;

function TBsonBaseReader.ReadArrayIntf: TBsonArray._IArray;
var
  Item: TBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TBsonType.&Array);

  ReadStartArray;
  Result := _goCreateArray;
  while (ReadBsonType <> TBsonType.EndOfDocument) do
  begin
    Item := ReadValueIntf;
    Result.Add(Item);
  end;
  ReadEndArray;
end;

function TBsonBaseReader.ReadBinaryDataIntf: TBsonValue._IValue;
var
  Value: TBsonBinaryData;
begin
  Value := ReadBinaryData;
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadDocument: TBsonDocument;
var
  Doc: TBsonDocument._IDocument;
  Name: String;
  Value: TBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TBsonType.Document);

  ReadStartDocument;

  Result := TBsonDocument.Create(FAllowDuplicateNames);

  Doc := Result._Impl;

  while (ReadBsonType <> TBsonType.EndOfDocument) do
  begin
    Name := ReadName;
    Value := ReadValueIntf;
    Doc.Add(Name, Value);
  end;

  ReadEndDocument;
end;

function TBsonBaseReader.ReadDocumentIntf: TBsonDocument._IDocument;
var
  Name: String;
  Value: TBsonValue._IValue;
begin
  EnsureBsonTypeEquals(TBsonType.Document);

  ReadStartDocument;

  Result := _goCreateDocument;
  Result.AllowDuplicateNames := FAllowDuplicateNames;

  while (ReadBsonType <> TBsonType.EndOfDocument) do
  begin
    Name := ReadName;
    Value := ReadValueIntf;
    Result.Add(Name, Value);
  end;

  ReadEndDocument;
end;

function TBsonBaseReader.ReadJavaScriptIntf: TBsonValue._IValue;
var
  Value: TBsonJavaScript;
begin
  Value := TBsonJavaScript.Create(ReadJavaScript);
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadJavaScriptWithScopeIntf: TBsonValue._IValue;
var
  Value: TBsonValue;
begin
  Value := DoReadJavaScriptWithScope;
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadRegularExpressionIntf: TBsonValue._IValue;
var
  Value: TBsonRegularExpression;
begin
  Value := ReadRegularExpression;
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadStringIntf: TBsonValue._IValue;
begin
  Result := _goBsonValueFromString(ReadString);
end;

function TBsonBaseReader.ReadSymbolIntf: TBsonValue._IValue;
var
  Value: TBsonSymbol;
begin
  Value := TBsonSymbolTable.Lookup(ReadSymbol);
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadTimeStampIntf: TBsonValue._IValue;
var
  Value: TBsonTimestamp;
begin
  Value := TBsonTimestamp.Create(ReadTimestamp);
  Result := Value._Impl;
end;

function TBsonBaseReader.ReadValue: TBsonValue;
begin
  Result._Impl := ReadValueIntf;
end;

function TBsonBaseReader.ReadValueIntf: TBsonValue._IValue;
begin
  case GetCurrentBsonType of
    TBsonType.EndOfDocument: ;
    TBsonType.Double: Result := _goBsonValueFromDouble(ReadDouble);
    TBsonType.&String: Result := ReadStringIntf;
    TBsonType.Document: Result := ReadDocumentIntf;
    TBsonType.&Array: Result := ReadArrayIntf;
    TBsonType.Binary: Result := ReadBinaryDataIntf;
    TBsonType.Undefined: begin ReadUndefined; Result := TBsonUndefined.Value._Value end;
    TBsonType.ObjectId: Result := _goBsonValueFromObjectId(ReadObjectId);
    TBsonType.Boolean: Result := _goBsonValueFromBoolean(ReadBoolean);
    TBsonType.DateTime: Result := _goBsonValueFromDateTime(ReadDateTime);
    TBsonType.Null: begin ReadNull; Result := TBsonNull.Value._Value end;
    TBsonType.RegularExpression: Result := ReadRegularExpressionIntf;
    TBsonType.JavaScript: Result := ReadJavaScriptIntf;
    TBsonType.Symbol: Result := ReadSymbolIntf;
    TBsonType.JavaScriptWithScope: Result := ReadJavaScriptWithScopeIntf;
    TBsonType.Int32: Result := _goBsonValueFromInt32(ReadInt32);
    TBsonType.Timestamp: Result := ReadTimeStampIntf;
    TBsonType.Int64: Result := _goBsonValueFromInt64(ReadInt64);
    TBsonType.MaxKey: begin ReadMaxKey; Result := TBsonMaxKey.Value._Value end;
    TBsonType.MinKey: begin ReadMinKey; Result := TBsonMinKey.Value._Value end;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TBsonBaseReader.VerifyBsonType(
  const ARequiredBsonType: TBsonType);
begin
  if (FState in [TBsonReaderState.Initial, TBsonReaderState.ScopeDocument, TBsonReaderState.&Type]) then
    ReadBsonType;

  if (FState = TBsonReaderState.Name) then
    SkipName;

  if (FState <> TBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FCurrentBsonType <> ARequiredBsonType) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

{ TBsonBaseReader.TBookmark }

constructor TBookmark.Create(const AState: TBsonReaderState;
  const ACurrentBsonType: TBsonType; const ACurrentName: String);
begin
  inherited Create;
  FState := AState;
  FCurrentBsonType := ACurrentBsonType;
  FCurrentName := ACurrentName;
end;

function TBookmark.GetCurrentBsonType: TBsonType;
begin
  Result := FCurrentBsonType;
end;

function TBookmark.GetCurrentName: String;
begin
  Result := FCurrentName;
end;

function TBookmark.GetState: TBsonReaderState;
begin
  Result := FState;
end;

{ TBsonReader }

constructor TBsonReader.Create(const ABson: TBytes);
begin
  inherited Create;
  FInput.Initialize(ABson);
  PushContext(TBsonContextType.TopLevel, 0, 0);
end;

function TBsonReader.EndOfStream: Boolean;
begin
  Result := (FInput.Position >= FInput.Size);
end;

function TBsonReader.GetBookmark: IBsonReaderBookmark;
begin
  Result := TBsonBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FInput.Position);
end;

function TBsonReader.GetNextState: TBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document,
    TBsonContextType.ScopeDocument:
      Result := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      Result := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

class function TBsonReader.Load(const AFilename: String): IBsonReader;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := Load(Stream);
  finally
    Stream.Free;
  end;
end;

class function TBsonReader.Load(const AStream: TStream): IBsonReader;
var
  Bson: TBytes;
begin
  SetLength(Bson, AStream.Size - AStream.Position);
  AStream.ReadBuffer(Bson[0], Length(Bson));
  Result := TBsonReader.Create(Bson);
end;

procedure TBsonReader.PopContext(const APosition: Integer);
var
  ActualSize: Integer;
begin
  Assert(Assigned(FContext));
  ActualSize := APosition - FContext.FStartPosition;
  if (ActualSize <> FContext.FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TBsonReader.PushContext(const AContextType: TBsonContextType;
  const AStartPosition, ASize: Integer);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AStartPosition, ASize);
  FContext := @FContextStack[FContextIndex];
end;

function TBsonReader.ReadBinaryData: TBsonBinaryData;
var
  Size, Size2: Integer;
  SubType: TBsonBinarySubType;
  Bytes: TBytes;
begin
  VerifyBsonType(TBsonType.Binary);
  Size := ReadSize;

  SubType := FInput.ReadBinarySubType;
  if (SubType = TBsonBinarySubType.OldBinary) then
  begin
    Size2 := ReadSize;
    if (Size2 <> (Size - 4)) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

    Size := Size2;
    SubType := TBsonBinarySubType.Binary;
  end;

  SetLength(Bytes, Size);
  FInput.Read(Bytes[0], Size);
  State := GetNextState;

  Result := TBsonBinaryData.Create(Bytes, SubType);
end;

function TBsonReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TBsonType.Boolean);
  State := GetNextState;
  Result := FInput.ReadBoolean;
end;

function TBsonReader.ReadBsonType: TBsonType;
begin
  if (State in [TBsonReaderState.Initial, TBsonReaderState.ScopeDocument]) then
  begin
    CurrentBsonType := TBsonType.Document;
    State := TBsonReaderState.Value;
    Exit(CurrentBsonType);
  end;

  if (State <> TBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.&Array) then
    Inc(FContext.FCurrentArrayIndex);

  CurrentBsonType := FInput.ReadBsonType;

  if (CurrentBsonType = TBsonType.EndOfDocument) then
  begin
    case FContext.ContextType of
      TBsonContextType.&Array:
        State := TBsonReaderState.EndOfArray;

      TBsonContextType.Document,
      TBsonContextType.ScopeDocument:
        State := TBsonReaderState.EndOfDocument;
    else
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
    end;
  end
  else
  begin
    case FContext.ContextType of
      TBsonContextType.&Array:
        begin
          FInput.SkipCString;
          State := TBsonReaderState.Value;
        end;

      TBsonContextType.Document,
      TBsonContextType.ScopeDocument:
        State := TBsonReaderState.Name;
    else
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
    end;
  end;
  Result := CurrentBsonType;
end;

function TBsonReader.ReadBytes: TBytes;
var
  Size: Integer;
  SubType: TBsonBinarySubType;
begin
  VerifyBsonType(TBsonType.Binary);

  Size := ReadSize;
  SubType := FInput.ReadBinarySubType;
  if (not (SubType in [TBsonBinarySubType.Binary, TBsonBinarySubType.OldBinary])) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  State := GetNextState;
  Result := FInput.ReadBytes(Size);
end;

function TBsonReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TBsonType.DateTime);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

function TBsonReader.ReadDouble: Double;
begin
  VerifyBsonType(TBsonType.Double);
  State := GetNextState;
  Result := FInput.ReadDouble;
end;

procedure TBsonReader.ReadEndArray;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType <> TBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfArray) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext(FInput.Position);
  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      State := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TBsonReader.ReadEndDocument;
begin
  Assert(Assigned(FContext));
  if (not (FContext.ContextType in [TBsonContextType.Document, TBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfDocument) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext(FInput.Position);
  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.JavaScriptWithScope) then
  begin
    PopContext(FInput.Position);
    Assert(Assigned(FContext));
  end;

  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      State := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TBsonReader.ReadInt32: Integer;
begin
  VerifyBsonType(TBsonType.Int32);
  State := GetNextState;
  Result := FInput.ReadInt32;
end;

function TBsonReader.ReadInt64: Int64;
begin
  VerifyBsonType(TBsonType.Int64);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

function TBsonReader.ReadJavaScript: String;
begin
  VerifyBsonType(TBsonType.JavaScript);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TBsonReader.ReadJavaScriptWithScope: String;
var
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TBsonType.JavaScriptWithScope);

  StartPosition := FInput.Position;
  Size := ReadSize;

  PushContext(TBsonContextType.JavaScriptWithScope, StartPosition, Size);
  Result := FInput.ReadString;

  State := TBsonReaderState.ScopeDocument;
end;

procedure TBsonReader.ReadMaxKey;
begin
  VerifyBsonType(TBsonType.MaxKey);
  State := GetNextState;
end;

procedure TBsonReader.ReadMinKey;
begin
  VerifyBsonType(TBsonType.MinKey);
  State := GetNextState;
end;

function TBsonReader.ReadName: String;
begin
  if (FState = TBsonReaderState.&Type) then
    ReadBsonType;

  if (FState <> TBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  CurrentName := FInput.ReadCString;
  State := TBsonReaderState.Value;

  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.Document) then
    FContext.CurrentElementName := CurrentName;

  Result := CurrentName;
end;

procedure TBsonReader.ReadNull;
begin
  VerifyBsonType(TBsonType.Null);
  State := GetNextState;
end;

function TBsonReader.ReadObjectId: TObjectId;
begin
  VerifyBsonType(TBsonType.ObjectId);
  State := GetNextState;
  Result := FInput.ReadObjectId;
end;

function TBsonReader.ReadRegularExpression: TBsonRegularExpression;
var
  Pattern, Options: String;
begin
  VerifyBsonType(TBsonType.RegularExpression);
  State := GetNextState;
  Pattern := FInput.ReadCString;
  Options := FInput.ReadCString;
  Result := TBsonRegularExpression.Create(Pattern, Options);
end;

function TBsonReader.ReadSize: Integer;
begin
  Result := FInput.ReadInt32;
  if (Result < 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

procedure TBsonReader.ReadStartArray;
var
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TBsonType.&Array);
  StartPosition := FInput.Position;
  Size := ReadSize;
  PushContext(TBsonContextType.&Array, StartPosition, Size);
  State := TBsonReaderState.&Type;
end;

procedure TBsonReader.ReadStartDocument;
var
  ContextType: TBsonContextType;
  StartPosition, Size: Integer;
begin
  VerifyBsonType(TBsonType.Document);

  if (State = TBsonReaderState.ScopeDocument) then
    ContextType := TBsonContextType.ScopeDocument
  else
    ContextType := TBsonContextType.Document;

  StartPosition := FInput.Position;
  Size := ReadSize;

  PushContext(ContextType, StartPosition, Size);
  State := TBsonReaderState.&Type;
end;

function TBsonReader.ReadString: String;
begin
  VerifyBsonType(TBsonType.String);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TBsonReader.ReadSymbol: String;
begin
  VerifyBsonType(TBsonType.Symbol);
  State := GetNextState;
  Result := FInput.ReadString;
end;

function TBsonReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TBsonType.Timestamp);
  State := GetNextState;
  Result := FInput.ReadInt64;
end;

procedure TBsonReader.ReadUndefined;
begin
  VerifyBsonType(TBsonType.Undefined);
  State := GetNextState;
end;

procedure TBsonReader.ReturnToBookmark(
  const ABookmark: IBsonReaderBookmark);
var
  BM: TBsonBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TBsonBookmark);
  BM := TBsonBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];
  FInput.Position := BM.Position;
end;

procedure TBsonReader.SkipName;
begin
  if (FState <> TBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  FInput.SkipCString;
  FCurrentName := '';
  State := TBsonReaderState.Value;

  Assert(Assigned(FContext));
  if (FContext.ContextType = TBsonContextType.Document) then
    FContext.CurrentElementName := CurrentName;
end;

procedure TBsonReader.SkipValue;
var
  Skip: Integer;
begin
  if (FState <> TBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  case CurrentBsonType of
    TBsonType.&Array: Skip := ReadSize - 4;
    TBsonType.Binary: Skip := ReadSize + 1;
    TBsonType.Boolean: Skip := 1;
    TBsonType.DateTime: Skip := 8;
    TBsonType.Document: Skip := ReadSize - 4;
    TBsonType.Double: Skip := 8;
    TBsonType.Int32: Skip := 4;
    TBsonType.Int64: Skip := 8;
    TBsonType.JavaScript: Skip := ReadSize;
    TBsonType.JavaScriptWithScope: Skip := ReadSize - 4;
    TBsonType.ObjectId: Skip := 12;
    TBsonType.RegularExpression:
      begin
        FInput.SkipCString;
        FInput.SkipCString;
        Skip := 0;
      end;
    TBsonType.String: Skip := ReadSize;
    TBsonType.Symbol: Skip := ReadSize;
    TBsonType.Timestamp: Skip := 8;
  else
    Skip := 0;
  end;
  FInput.Skip(Skip);
  State := TBsonReaderState.&Type;
end;

{ TBsonReader.TInput }

class constructor TBsonReader.TInput.Create;
var
  B: Integer;
begin
  FillChar(FValidBsonTypes, SizeOf(FValidBsonTypes), False);
  for B := 0 to $12 do
    FValidBsonTypes[B] := (B <> $0C);
  FValidBsonTypes[$7F] := True;
  FValidBsonTypes[$FF] := True;
end;

procedure TBsonReader.TInput.Initialize(const ABuffer: TBytes);
begin
  FBuffer := ABuffer;
  FSize := Length(ABuffer);
  FPosition := 0;
  SetLength(FTempBytes, TEMP_BYTES_LENGTH);
end;

procedure TBsonReader.TInput.Read(out AData; const ASize: Integer);
begin
  if ((FPosition + ASize) > FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Move(FBuffer[FPosition], AData, ASize);
  Inc(FPosition, ASize);
end;

function TBsonReader.TInput.ReadBinarySubType: TBsonBinarySubType;
var
  B: Byte absolute Result;
begin
  Read(B, 1);
end;

function TBsonReader.TInput.ReadBoolean: Boolean;
var
  B: Byte;
begin
  Read(B, 1);
  Result := (B <> 0);
end;

function TBsonReader.TInput.ReadBsonType: TBsonType;
var
  B: Byte absolute Result;
begin
  Read(B, 1);
  if (not (FValidBsonTypes[B])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
end;

function TBsonReader.TInput.ReadByte: Byte;
begin
  Read(Result, 1);
end;

function TBsonReader.TInput.ReadBytes(const ASize: Integer): TBytes;
begin
  Assert(ASize >= 0);
  SetLength(Result, ASize);
  if (Result <> nil) then
    Read(Result[0], ASize);
end;

function TBsonReader.TInput.ReadCString: String;
var
  Bytes: TBytes;
  B: Byte;
  Index: Integer;
begin
  Index := 0;
  Bytes := nil;
  while True do
  begin
    B := ReadByte;
    if (B = 0) then
      Break;

    if (Index >= Length(Bytes)) then
      SetLength(Bytes, Index + 32);
    Bytes[Index] := B;
    Inc(Index);
  end;
  Result := TEncoding.UTF8.GetString(Bytes, 0, Index);
end;

function TBsonReader.TInput.ReadDouble: Double;
begin
  Read(Result, 8);
end;

function TBsonReader.TInput.ReadInt32: Int32;
begin
  Read(Result, 4);
end;

function TBsonReader.TInput.ReadInt64: Int64;
begin
  Read(Result, 8);
end;

function TBsonReader.TInput.ReadObjectId: TObjectId;
var
  Bytes: TBytes;
begin
  SetLength(Bytes, 12);
  Read(Bytes[0], 12);
  Result := TObjectId.Create(Bytes);
end;

function TBsonReader.TInput.ReadString: String;
var
  Len: Integer;
  Bytes: TBytes;
begin
  Len := ReadInt32;
  if (Len <= 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);

  if (Len <= TEMP_BYTES_LENGTH) then
    Bytes := FTempBytes
  else
    SetLength(Bytes, Len);
  Read(Bytes[0], Len);
  if (Bytes[Len - 1] <> 0) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Result := TEncoding.UTF8.GetString(Bytes, 0, Len - 1);
end;

procedure TBsonReader.TInput.Skip(const ANumBytes: Integer);
begin
  if ((FPosition + ANumBytes) > FSize) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Inc(FPosition, ANumBytes);
end;

procedure TBsonReader.TInput.SkipCString;
begin
  while (ReadByte <> 0) do ;
end;

{ TBsonReader.TContext }

procedure TBsonReader.TContext.Initialize(
  const AContextType: TBsonContextType; const AStartPosition, ASize: Integer);
begin
  FStartPosition := AStartPosition;
  FSize := ASize;
  FCurrentArrayIndex := -1;
  FCurrentElementName := '';
  FContextType := AContextType;
end;

{ TBsonReader.TBsonBookmark }

constructor TBsonReader.TBsonBookmark.Create(const AState: TBsonReaderState;
  const ACurrentBsonType: TBsonType; const ACurrentName: String;
  const AContextIndex, APosition: Integer);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  FPosition := APosition;
end;

{ TJsonReader }

constructor TJsonReader.Create(const AJson: String; AllowDuplicateNames : Boolean = false);
begin
  inherited Create;
  FAllowDuplicateNames := AllowDuplicateNames;
  FBuffer := TBuffer.Create(AJson);
  FTokenBase := TToken.Create;
  FTokenToPush := TToken.Create;
  PushContext(TBsonContextType.TopLevel);
end;

class constructor TJsonReader.Create;
begin
  TScanner.Initialize;
end;

destructor TJsonReader.Destroy;
begin
  FTokenBase.Free;
  FTokenToPush.Free;
  inherited;
end;

function TJsonReader.EndOfStream: Boolean;
var
  C: Char;
begin
  while True do
  begin
    C := FBuffer.Read;
    if (C = #0) then
      Exit(True);

    if (not TScanner.IsWhitespace(C)) then
    begin
      FBuffer.Unread(C);
      Exit(False);
    end;
  end;
end;

class function TJsonReader.FormatJavaScriptDateTimeString(
  const ALocalDateTime: TDateTime): String;
var
  Utc, Offset: TDateTime;
  OffsetSign: String;
  H, M, S, MSec: Word;
begin
  Utc := TTimeZone.Local.ToUniversalTime(ALocalDateTime);
  Offset := ALocalDateTime - Utc;
  if (Offset < 0) then
  begin
    Offset := -Offset;
    OffsetSign := '-';
  end
  else
    OffsetSign := '+';

  DecodeTime(Offset, H, M, S, MSec);
  Result := FormatDateTime('ddd mmm dd yyyy hh:nn:ss', ALocalDateTime, goUSFormatSettings)
    + Format('GMT%s%.2d%.2d (%s)', [OffsetSign, H, M, TTimeZone.Local.DisplayName]);
end;

function TJsonReader.GetBookmark: IBsonReaderBookmark;
begin
  Result := TJsonBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FCurrentToken, FCurrentValue, FPushedToken,
    FBuffer.FCurrent);
end;

function TJsonReader.GetNextState: TBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      Result := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      Result := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

class function TJsonReader.Load(const AFilename: String; AllowDuplicateNames : Boolean = false): IJsonReader;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    Result := Load(Stream, AllowDuplicateNames);
  finally
    Stream.Free;
  end;
end;

class function TJsonReader.Load(const AStream: TStream; AllowDuplicateNames : Boolean = false): IJsonReader;
var
  Reader: TStreamReader;
  Json: String;
begin
  Reader := TStreamReader.Create(AStream, True);
  try
    Json := Reader.ReadToEnd;
  finally
    Reader.Free;
  end;
  Result := TJsonReader.Create(Json, AllowDuplicateNames);
end;

procedure TJsonReader.ParseConstructorBinaryData;
{ BinData(0, "AQ==") }
var
  Token: TToken;
  Base64: TBytes;
begin
  VerifyToken('(');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.Int32) then
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
  FCurrentValue.BinarySubType := TBsonBinarySubType(Token.Int32Value);

  VerifyToken(',');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Base64 := TEncoding.ANSI.GetBytes(Token.StringValue);

  VerifyToken(')');

  FCurrentValue.Bytes := Base64Decode(Base64);
end;

procedure TJsonReader.ParseConstructorDateTime(
  const AWithNew: Boolean);
{ Date()
  new Date()
  new Date(9223372036854775807)
  new Date(1970, 3, 30, 11, 59, 23, 123)
  new Date("...") }
var
  Token: TToken;
  DateTime: TDateTime;
  Args: array [0..6] of Int64;
  ArgCount: Integer;
begin
  VerifyToken('(');

  if (not AWithNew) then
  begin
    VerifyToken(')');
    FCurrentValue.StrVal := FormatJavaScriptDateTimeString(Now);
    Exit;
  end;

  PopToken(Token);
  if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ')') then
  begin
    FCurrentValue.Int64Val := DateTimeToMillisecondsSinceEpoch(Now, False);
    Exit;
  end;

  if (Token.TokenType = TTokenType.String) then
  begin
    VerifyToken(')');
    raise FBuffer.ParseError(@RS_BSON_JS_DATETIME_STRING_NOT_SUPPORTED);
  end;

  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
  begin
    ArgCount := 0;
    FillChar(Args, SizeOf(Args), 0);
    while True do
    begin
      if (ArgCount > 6) then
        raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
      Args[ArgCount] := Token.Int64Value;
      Inc(ArgCount);

      PopToken(Token);
      if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ')') then
        Break;

      if (Token.LexemeLength <> 1) or (Token.LexemeStart^ <> ',') then
        raise FBuffer.ParseError(@RS_BSON_COMMA_EXPECTED);

      PopToken(Token);
      if (not (Token.TokenType in [TTokenType.Int32, TTokenType.Int64])) then
        raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
    end;

    case ArgCount of
      1: FCurrentValue.Int64Val := Args[0];
      3..7:
        begin
          DateTime := EncodeDateTime(
            Args[0], Args[1] + 1, Args[2],
            Args[3], Args[3], Args[5], Args[6]);
          FCurrentValue.Int64Val := DateTimeToMillisecondsSinceEpoch(DateTime, True);
        end
    else
      raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
    end;
    Exit;
  end;

  raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
end;

procedure TJsonReader.ParseConstructorHexData;
{ HexData(0, "123") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.Int32) then
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
  FCurrentValue.BinarySubType := TBsonBinarySubType(Token.Int32Value);

  VerifyToken(',');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');

  FCurrentValue.Bytes := goParseHexString(Token.StringValue);
end;

procedure TJsonReader.ParseConstructorISODateTime;
{ ISODate("1970-01-01T00:00:00Z")
  ISODate("1970-01-01T00:00:00.000Z") }
var
  Token: TToken;
  DateTime: TDateTime;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  VerifyToken(')');

  { Note: The C# drivers supports a whole range of date/time formats.
    We only support the official ISO8601 format }
  if (not TryISO8601ToDate(Token.StringValue, DateTime, True)) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);

  FCurrentValue.Int64Val := DateTimeToMillisecondsSinceEpoch(DateTime, True);
end;

procedure TJsonReader.ParseConstructorNumber;
{ Number(42)
  Number("42")
  NumberInt(42)
  NumberInt("42") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    FCurrentValue.Int32Val := Token.Int32Value
  else if (Token.TokenType = TTokenType.String) then
    FCurrentValue.Int32Val := StrToInt(Token.StringValue)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken(')');
end;

procedure TJsonReader.ParseConstructorNumberLong;
{ NumberLong(42)
  NumberLong("42") }
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    FCurrentValue.Int64Val := Token.Int64Value
  else if (Token.TokenType = TTokenType.String) then
    FCurrentValue.Int64Val := StrToInt64(Token.StringValue)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken(')');
end;

procedure TJsonReader.ParseConstructorObjectId;
// ObjectId("0102030405060708090a0b0c")
var
  Token: TToken;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');
  FCurrentValue.ObjectIdVal := TObjectId.Create(Token.StringValue);
end;

procedure TJsonReader.ParseConstructorRegularExpression;
{ RegExp("pattern")
  RegExp("pattern", "options") }
var
  Token: TToken;
  Pattern, Options: String;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Pattern := Token.StringValue;
  Options := '';

  PopToken(Token);
  if (Token.LexemeLength = 1) and (Token.LexemeStart^ = ',') then
  begin
    PopToken(Token);
    if (Token.TokenType <> TTokenType.String) then
      raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
    Options := Token.StringValue;
  end
  else
    PushToken(Token);

  VerifyToken(')');
  FCurrentValue.StrVal := Pattern + #1 + Options;
end;

procedure TJsonReader.ParseConstructorTimestamp;
{ Timestamp(1, 2) }
var
  Token: TToken;
  SecondsSinceEpoch, Increment: Integer;
begin
  VerifyToken('(');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    SecondsSinceEpoch := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(',');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    Increment := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(')');
  FCurrentValue.Int64Val := (UInt64(SecondsSinceEpoch) shl 32) or UInt32(Increment);
end;

procedure TJsonReader.ParseConstructorUUID(const ALexemeStart: Char);
var
  Token: TToken;
  HexString: String;
begin
  VerifyToken('(');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken(')');

  HexString := Token.StringValue.Replace('{', '').Replace('}', '');
  HexString := HexString.Replace('-', '', [rfReplaceAll]);
  FCurrentValue.Bytes := goParseHexString(HexString);
  if (Length(FCurrentValue.Bytes) <> 16) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_GUID);
  FCurrentValue.BinarySubType := TBsonBinarySubType.UuidLegacy;

  if (ALexemeStart = 'C') then // C#
  begin
    // No conversion needed
    goReverseBytes(FCurrentValue.Bytes, 0, 4);
    goReverseBytes(FCurrentValue.Bytes, 4, 2);
    goReverseBytes(FCurrentValue.Bytes, 6, 2);
  end
  else
  begin
    if (ALexemeStart = 'J') then // Java
    begin
      goReverseBytes(FCurrentValue.Bytes, 0, 8);
      goReverseBytes(FCurrentValue.Bytes, 8, 8);
    end
    else if (ALexemeStart <> 'P') then // Python
      FCurrentValue.BinarySubType := TBsonBinarySubType.UuidStandard;
  end;
end;

function TJsonReader.ParseDocumentOrExtendedJson: TBsonType;
var
  NameToken: TToken;
begin
  PopToken(NameToken);
  if (NameToken.TokenType in [TTokenType.String, TTokenType.UnquotedString])
    and (NameToken.StringValue <> '')
  then
    Result := ParseExtendedJson(NameToken)
  else
  begin
    PushToken(NameToken);
    Result := TBsonType.Document;
  end;
end;

function TJsonReader.ParseExtendedJson(const ANameToken: TToken): TBsonType;
var
  S: String;
begin
  S := ANameToken.StringValue;
  Assert(S <> '');
  if (S.Chars[0] = '$') and (S.Length > 1) then
  begin
    case S.Chars[1] of
      'b': if (S = '$binary') then
           begin
             ParseExtendedJsonBinaryData;
             Exit(TBsonType.Binary);
           end;
      'c': if (S = '$code') then
             Exit(ParseExtendedJsonJavaScript);
      'd': if (S = '$date') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonDateTime;
             Exit(TBsonType.DateTime);
           end;
      'm': if (S = '$maxkey') or (S = '$maxKey') then
           begin
             ParseExtendedJsonMaxKey;
             Exit(TBsonType.MaxKey);
           end
           else if (S = '$minkey') or (S = '$minKey') then
           begin
             ParseExtendedJsonMinKey;
             Exit(TBsonType.MinKey);
           end;
      'n': if (S = '$numberLong') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonNumberLong;
             Exit(TBsonType.Int64);
           end;
      'o': if (S = '$oid') then
           begin
             FCurrentValue.ObjectIdVal := ParseExtendedJsonObjectId;
             Exit(TBsonType.ObjectId);
           end;
      'r': if (S = '$regex') then
           begin
             ParseExtendedJsonRegularExpression;
             Exit(TBsonType.RegularExpression);
           end;
      's': if (S = '$symbol') then
           begin
             ParseExtendedJsonSymbol;
             Exit(TBsonType.Symbol);
           end;
      't': if (S = '$timestamp') then
           begin
             FCurrentValue.Int64Val := ParseExtendedJsonTimestamp;
             Exit(TBsonType.Timestamp);
           end;
      'u': if (S = '$undefined') then
           begin
             ParseExtendedJsonUndefined;
             Exit(TBsonType.Undefined);
           end;
    end;
  end;
  PushToken(ANameToken);
  Result := TBsonType.Document;
end;

procedure TJsonReader.ParseExtendedJsonBinaryData;
(* { $binary : "AQ==", $type : 0 }
   { $binary : "AQ==", $type : "0" }
   { $binary : "AQ==", $type : "00" } *)
var
  Token: TToken;
  Base64: TBytes;
begin
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  Base64 := TEncoding.ANSI.GetBytes(Token.StringValue);
  FCurrentValue.Bytes := Base64Decode(Base64);

  VerifyToken(',');
  VerifyString('$type');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.String) then
    FCurrentValue.BinarySubType := TBsonBinarySubType(StrToInt('$' + Token.StringValue))
  else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    FCurrentValue.BinarySubType := TBsonBinarySubType(Token.Int32Value)
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);

  VerifyToken('}');
end;

function TJsonReader.ParseExtendedJsonDateTime: Int64;
(* { $date : -9223372036854775808 }
   { $date : { $numberLong : 9223372036854775807 } }
   { $date : { $numberLong : "-9223372036854775808" } }
   { $date : "1970-01-01T00:00:00Z" }
   { $date : "1970-01-01T00:00:00.000Z" } *)
var
  Token: TToken;
  DateTime: TDateTime;
begin
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := Token.Int64Value
  else if (Token.TokenType = TTokenType.String) then
  begin
    if (not TryISO8601ToDate(Token.StringValue, DateTime, True)) then
      raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);
    Result := DateTimeToMillisecondsSinceEpoch(DateTime, True);
  end
  else if (Token.TokenType = TTokenType.BeginObject) then
  begin
    VerifyString('$numberLong');
    VerifyToken(':');
    PopToken(Token);
    if (Token.TokenType = TTokenType.String) then
    begin
      if (not TryStrToInt64(Token.StringValue, Result)) then
        raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);
    end
    else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
      Result := Token.Int64Value
    else
      raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
    VerifyToken('}');
  end
  else
    raise FBuffer.ParseError(@RS_BSON_INVALID_DATE);

  VerifyToken('}');
end;

function TJsonReader.ParseExtendedJsonJavaScript: TBsonType;
(* { "$code" : "function f() { return 1; }" }
   { "$code" : "function f() { return 1; }" , "$scope" : {...} } *)
var
  Token: TToken;
  Code: String;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Code := Token.StringValue;

  PopToken(Token);
  case Token.TokenType of
    TTokenType.Comma:
      begin
        VerifyString('$scope');
        VerifyToken(':');
        State := TBsonReaderState.Value;
        FCurrentValue.StrVal := Code;
        Result := TBsonType.JavaScriptWithScope;
      end;

    TTokenType.EndObject:
      begin
        FCurrentValue.StrVal := Code;
        Result := TBsonType.JavaScript;
      end;
  else
    raise FBuffer.ParseError(@RS_BSON_COMMA_OR_CLOSE_BRACE_EXPECTED);
  end;
end;

procedure TJsonReader.ParseExtendedJsonMaxKey;
(* { $maxKey : 1 }
   { $maxkey : 1 } *)
begin
  VerifyToken(':');
  VerifyToken('1');
  VerifyToken('}');
end;

procedure TJsonReader.ParseExtendedJsonMinKey;
(* { $minKey : 1 }
   { $minkey : 1 } *)
begin
  VerifyToken(':');
  VerifyToken('1');
  VerifyToken('}');
end;

function TJsonReader.ParseExtendedJsonNumberLong: Int64;
(* { $numberLong: 42 }
   { $numberLong: "42" } *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType = TTokenType.String) then
    Result := StrToInt64(Token.StringValue)
  else if (Token.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := Token.Int64Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);
  VerifyToken('}');
end;

function TJsonReader.ParseExtendedJsonObjectId: TObjectId;
// { $oid : "0102030405060708090a0b0c" }
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken('}');
  Result := TObjectId.Create(Token.StringValue);
end;

procedure TJsonReader.ParseExtendedJsonRegularExpression;
(* { $regex : "abc" }
   { $regex : "abc", $options : "i" } *)
var
  Token: TToken;
  Pattern, Options: String;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  Pattern := Token.StringValue;
  Options := '';

  PopToken(Token);
  if (Token.TokenType = TTokenType.Comma) then
  begin
    VerifyString('$options');
    VerifyToken(':');
    PopToken(Token);
    if (Token.TokenType <> TTokenType.String) then
      raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
    Options := Token.StringValue;
  end
  else
    PushToken(Token);

  VerifyToken('}');
  FCurrentValue.StrVal := Pattern + #1 + Options;
end;

procedure TJsonReader.ParseExtendedJsonSymbol;
(* { "$symbol" : "symbol" } *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType <> TTokenType.String) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);
  VerifyToken('}');
  FCurrentValue.StrVal := Token.StringValue; // Will be converted to a TBsonSymbol later
end;

function TJsonReader.ParseExtendedJsonTimestamp: Int64;
(* { $timestamp : { t : 1, i : 2 } } // New
   { $timestamp : 123 }              // Old
   { $timestamp : NumberLong(123) }  // Old *)
var
  Token: TToken;
begin
  VerifyToken(':');
  PopToken(Token);
  if (Token.TokenType = TTokenType.BeginObject) then
    Result := ParseExtendedJsonTimestampNew
  else
    Result := ParseExtendedJsonTimestampOld(Token);
end;

function TJsonReader.ParseExtendedJsonTimestampNew: Int64;
(* { $timestamp : { t : 1, i : 2 } } *)
var
  Token: TToken;
  SecondsSinceEpoch, Increment: Integer;
begin
  VerifyString('t');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    SecondsSinceEpoch := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken(',');
  VerifyString('i');
  VerifyToken(':');

  PopToken(Token);
  if (Token.TokenType = TTokenType.Int32) then
    Increment := Token.Int32Value
  else
    raise FBuffer.ParseError(@RS_BSON_INT_EXPECTED);

  VerifyToken('}');
  VerifyToken('}');
  Result := (UInt64(SecondsSinceEpoch) shl 32) or UInt32(Increment);
end;

function TJsonReader.ParseExtendedJsonTimestampOld(
  const AValueToken: TToken): Int64;
(* { $timestamp : 123 }
   { $timestamp : NumberLong(123) } *)
begin

  if (AValueToken.TokenType in [TTokenType.Int32, TTokenType.Int64]) then
    Result := AValueToken.Int64Value
  else if (AValueToken.TokenType = TTokenType.UnquotedString)
    and (AValueToken.IsLexeme('NumberLong', 10)) then
  begin
    ParseConstructorNumberLong;
    Result := FCurrentValue.Int64Val;
  end
  else
    raise FBuffer.ParseError(@RS_BSON_INT_OR_STRING_EXPECTED);

  VerifyToken('}');
end;

procedure TJsonReader.ParseExtendedJsonUndefined;
(* { $undefined : true } *)
begin
  VerifyToken(':');
  VerifyToken('true', 4);
  VerifyToken('}');
end;

function TJsonReader.ParseNew: TBsonType;
var
  Token: TToken;
begin
  PopToken(Token);
  if (Token.TokenType <> TTokenType.UnquotedString) then
    raise FBuffer.ParseError(@RS_BSON_STRING_EXPECTED);

  Assert(Token.LexemeLength > 0);
  case Token.LexemeStart^ of
    'B': if (Token.IsLexeme('BinData', 7)) then
         begin
           ParseConstructorBinaryData;
           Exit(TBsonType.Binary);
         end;

    'C': if (Token.IsLexeme('CSUUID', 6)) or (Token.IsLexeme('CSGUID', 6)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TBsonType.DateTime);
         end;

    'D': if (Token.IsLexeme('Date', 4)) then
         begin
           ParseConstructorDateTime(True);
           Exit(TBsonType.DateTime);
         end;

    'G': if (Token.IsLexeme('GUID', 4)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TBsonType.DateTime);
         end;

    'H': if (Token.IsLexeme('HexData', 7)) then
         begin
           ParseConstructorHexData;
           Exit(TBsonType.Binary);
         end;

    'I': if (Token.IsLexeme('ISODate', 7)) then
         begin
           ParseConstructorISODateTime;
           Exit(TBsonType.DateTime);
         end;

    'J': if (Token.IsLexeme('JUUID', 5)) or (Token.IsLexeme('JGUID', 5)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TBsonType.DateTime);
         end;

    'N': if (Token.IsLexeme('NumberInt', 9)) then
         begin
           ParseConstructorNumber;
           Exit(TBsonType.Int32);
         end
         else if (Token.IsLexeme('NumberLong', 10)) then
         begin
           ParseConstructorNumberLong;
           Exit(TBsonType.Int64);
         end;

    'O': if (Token.IsLexeme('ObjectId', 8)) then
         begin
           ParseConstructorObjectId;
           Exit(TBsonType.ObjectId);
         end;

    'P': if (Token.IsLexeme('PYUUID', 6)) or (Token.IsLexeme('PYGUID', 6)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TBsonType.DateTime);
         end;

    'T': if (Token.IsLexeme('Timestamp', 9)) then
         begin
           ParseConstructorTimestamp;
           Exit(TBsonType.Timestamp);
         end;

    'U': if (Token.IsLexeme('UUID', 4)) then
         begin
           ParseConstructorUUID(Token.LexemeStart^);
           Exit(TBsonType.DateTime);
         end;
  end;

  raise FBuffer.ParseError(@RS_BSON_INVALID_NEW_STATEMENT);
end;

procedure TJsonReader.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TJsonReader.PopToken(out AToken: TToken);
begin
  if (FPushedToken <> nil) then
  begin
    Assert(FPushedToken = FTokenToPush);
    AToken := FPushedToken;
    FPushedToken := nil;
  end
  else
  begin
    AToken := FTokenBase;
    TScanner.GetNextToken(FBuffer, AToken);
  end;
end;

procedure TJsonReader.PushContext(const AContextType: TBsonContextType);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType);
  FContext := @FContextStack[FContextIndex];
end;

procedure TJsonReader.PushToken(const AToken: TToken);
begin
  if (FPushedToken <> nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  FTokenToPush.Assign(AToken);
  FPushedToken := FTokenToPush;
end;

function TJsonReader.ReadBinaryData: TBsonBinaryData;
begin
  VerifyBsonType(TBsonType.Binary);
  State := GetNextState;
  Result := TBsonBinaryData.Create(FCurrentValue.Bytes, FCurrentValue.BinarySubType);
end;

function TJsonReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TBsonType.Boolean);
  State := GetNextState;
  Result := FCurrentValue.BoolVal;
end;

function TJsonReader.ReadBsonType: TBsonType;
var
  Token: TToken;
  NoValueFound: Boolean;
begin
  Assert(Assigned(FContext));

  if (State in [TBsonReaderState.Initial, TBsonReaderState.ScopeDocument]) then
    State := TBsonReaderState.&Type;

  if (State <> TBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FContext.ContextType = TBsonContextType.Document) then
  begin
    PopToken(Token); // Name
    case Token.TokenType of
      TTokenType.String,
      TTokenType.UnquotedString:
        CurrentName := Token.StringValue;

      TTokenType.EndObject:
        begin
          State := TBsonReaderState.EndOfDocument;
          Exit(TBsonType.EndOfDocument);
        end;
    else
      raise FBuffer.ParseError(@RS_BSON_STRING_OR_CLOSE_BRACE_EXPECTED);
    end;

    PopToken(Token); // Colon
    if (Token.TokenType <> TTokenType.Colon) then
      raise FBuffer.ParseError(@RS_BSON_COLON_EXPECTED);
  end;

  PopToken(Token); // Value
  if (FContext.ContextType = TBsonContextType.&Array)
    and (Token.TokenType = TTokenType.EndArray) then
  begin
    State := TBsonReaderState.EndOfArray;
    Exit(TBsonType.EndOfDocument);
  end;

  NoValueFound := False;
  case Token.TokenType of
    TTokenType.BeginArray:
      CurrentBsonType := TBsonType.&Array;

    TTokenType.BeginObject:
      CurrentBsonType := ParseDocumentOrExtendedJson;

    TTokenType.Double:
      begin
        CurrentBsonType := TBsonType.Double;
        FCurrentValue.DoubleVal := Token.DoubleValue;
      end;

    TTokenType.EndOfFile:
      CurrentBsonType := TBsonType.EndOfDocument;

    TTokenType.Int32:
      begin
        CurrentBsonType := TBsonType.Int32;
        FCurrentValue.Int32Val := Token.Int32Value;
      end;

    TTokenType.Int64:
      begin
        CurrentBsonType := TBsonType.Int64;
        FCurrentValue.Int64Val := Token.Int64Value;
      end;

    TTokenType.RegularExpression:
      begin
        CurrentBsonType := TBsonType.RegularExpression;
        SetCurrentValueRegEx(Token);
      end;

    TTokenType.String:
      begin
        CurrentBsonType := TBsonType.String;
        FCurrentValue.StrVal := Token.StringValue;
      end;

    TTokenType.UnquotedString:
      begin
        Assert(Token.LexemeLength > 0);
        case Token.LexemeStart^ of
          'B': if (Token.IsLexeme('BinData', 7)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorBinaryData;
               end
               else
                 NoValueFound := True;

          'C': if (Token.IsLexeme('CSUUID', 6)) or (Token.IsLexeme('CSGUID', 6)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'D': if (Token.IsLexeme('Date', 4)) then
               begin
                 { This is the Date() function (without arguments).
                   It should return the current datetime (in UTC) as a
                   JavaScript formatted datetime string. }
                 CurrentBsonType := TBsonType.String;
                 ParseConstructorDateTime(False);
               end
               else
                 NoValueFound := True;

          'G': if (Token.IsLexeme('GUID', 4)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'H': if (Token.IsLexeme('HexData', 7)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorHexData;
               end
               else
                 NoValueFound := True;

          'I': if (Token.IsLexeme('Infinity', 8)) then
               begin
                 CurrentBsonType := TBsonType.Double;
                 FCurrentValue.DoubleVal := Infinity;
               end
               else if (Token.IsLexeme('ISODate', 7)) then
               begin
                 CurrentBsonType := TBsonType.DateTime;
                 ParseConstructorISODateTime;
               end
               else
                 NoValueFound := True;

          'J': if (Token.IsLexeme('JUUID', 5)) or (Token.IsLexeme('JGUID', 5)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'M': if (Token.IsLexeme('MaxKey', 6)) then
                 CurrentBsonType := TBsonType.MaxKey
               else if (Token.IsLexeme('MinKey', 6)) then
                 CurrentBsonType := TBsonType.MinKey
               else
                 NoValueFound := True;

          'N': if (Token.IsLexeme('NaN', 3)) then
               begin
                 CurrentBsonType := TBsonType.Double;
                 FCurrentValue.DoubleVal := NaN;
               end
               else if (Token.IsLexeme('Number', 6)) or (Token.IsLexeme('NumberInt', 9)) then
               begin
                 CurrentBsonType := TBsonType.Int32;
                 ParseConstructorNumber;
               end
               else if (Token.IsLexeme('NumberLong', 10)) then
               begin
                 CurrentBsonType := TBsonType.Int64;
                 ParseConstructorNumberLong;
               end
               else
                 NoValueFound := True;

          'O': if (Token.IsLexeme('ObjectId', 8)) then
               begin
                 CurrentBsonType := TBsonType.ObjectId;
                 ParseConstructorObjectId;
               end
               else
                 NoValueFound := True;

          'P': if (Token.IsLexeme('PYUUID', 6)) or (Token.IsLexeme('PYGUID', 6)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'R': if (Token.IsLexeme('RegExp', 6)) then
               begin
                 CurrentBsonType := TBsonType.RegularExpression;
                 ParseConstructorRegularExpression;
               end
               else
                 NoValueFound := True;

          'T': if (Token.IsLexeme('Timestamp', 9)) then
               begin
                 CurrentBsonType := TBsonType.Timestamp;
                 ParseConstructorTimestamp;
               end
               else
                 NoValueFound := True;

          'U': if (Token.IsLexeme('UUID', 4)) then
               begin
                 CurrentBsonType := TBsonType.Binary;
                 ParseConstructorUUID(Token.LexemeStart^);
               end
               else
                 NoValueFound := True;

          'f': if (Token.IsLexeme('false', 5)) then
               begin
                 CurrentBsonType := TBsonType.Boolean;
                 FCurrentValue.BoolVal := False;
               end
               else
                 NoValueFound := True;

          'n': if (Token.IsLexeme('new', 3)) then
                 CurrentBsonType := ParseNew
               else if (Token.IsLexeme('null', 4)) then
                 CurrentBsonType := TBsonType.Null
               else
                 NoValueFound := True;

          't': if (Token.IsLexeme('true', 4)) then
               begin
                 CurrentBsonType := TBsonType.Boolean;
                 FCurrentValue.BoolVal := True;
               end
               else
                 NoValueFound := True;

          'u': if (Token.IsLexeme('undefined', 9)) then
                 CurrentBsonType := TBsonType.Undefined
               else
                 NoValueFound := True;
        else
          NoValueFound := True;
        end;
      end;
  else
    NoValueFound := True;
  end;

  if (NoValueFound) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_EXTENDED_JSON);

  FCurrentToken := Token;

  if (FContext.ContextType in [TBsonContextType.&Array, TBsonContextType.Document]) then
  begin
    PopToken(Token); // Comma
    if (Token.TokenType <> TTokenType.Comma) then
      PushToken(Token);
  end;

  case FContext.ContextType of
    TBsonContextType.Document,
    TBsonContextType.ScopeDocument:
      State := TBsonReaderState.Name;

    TBsonContextType.&Array,
    TBsonContextType.JavaScriptWithScope,
    TBsonContextType.TopLevel:
      State := TBsonReaderState.Value;
  end;

  Result := CurrentBsonType;
end;

function TJsonReader.ReadBytes: TBytes;
begin
  VerifyBsonType(TBsonType.Binary);
  State := GetNextState;

  if (not (FCurrentValue.BinarySubType in [TBsonBinarySubType.Binary, TBsonBinarySubType.OldBinary])) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_BINARY_TYPE);

  Result := FCurrentValue.Bytes;
end;

function TJsonReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TBsonType.DateTime);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

function TJsonReader.ReadDouble: Double;
begin
  VerifyBsonType(TBsonType.Double);
  State := GetNextState;
  Result := FCurrentValue.DoubleVal;
end;

procedure TJsonReader.ReadEndArray;
var
  CommaToken: TToken;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType <> TBsonContextType.&Array) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACKET_EXPECTED);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfArray) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACKET_EXPECTED);

  PopContext;
  if (FContext = nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      begin
        State := TBsonReaderState.&Type;
        PopToken(CommaToken);
        if (CommaToken.TokenType <> TTokenType.Comma) then
          PushToken(CommaToken);
      end;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TJsonReader.ReadEndDocument;
var
  CommaToken: TToken;
begin
  Assert(Assigned(FContext));
  if (not (FContext.ContextType in [TBsonContextType.Document, TBsonContextType.ScopeDocument])) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACE_EXPECTED);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfDocument) then
    raise FBuffer.ParseError(@RS_BSON_CLOSE_BRACE_EXPECTED);

  PopContext;
  if (FContext = nil) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (FContext.ContextType = TBsonContextType.JavaScriptWithScope) then
  begin
    PopContext;
    if (FContext = nil) then
      raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
    VerifyToken('}');
  end;

  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      begin
        State := TBsonReaderState.&Type;
        PopToken(CommaToken);
        if (CommaToken.TokenType <> TTokenType.Comma) then
          PushToken(CommaToken);
      end;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Initial;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TJsonReader.ReadInt32: Integer;
begin
  VerifyBsonType(TBsonType.Int32);
  State := GetNextState;
  Result := FCurrentValue.Int32Val;
end;

function TJsonReader.ReadInt64: Int64;
begin
  VerifyBsonType(TBsonType.Int64);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

function TJsonReader.ReadJavaScript: String;
begin
  VerifyBsonType(TBsonType.JavaScript);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TJsonReader.ReadJavaScriptWithScope: String;
begin
  VerifyBsonType(TBsonType.JavaScriptWithScope);
  PushContext(TBsonContextType.JavaScriptWithScope);
  State := TBsonReaderState.ScopeDocument;
  Result := FCurrentValue.StrVal;
end;

procedure TJsonReader.ReadMaxKey;
begin
  VerifyBsonType(TBsonType.MaxKey);
  State := GetNextState;
end;

procedure TJsonReader.ReadMinKey;
begin
  VerifyBsonType(TBsonType.MinKey);
  State := GetNextState;
end;

function TJsonReader.ReadName: String;
begin
  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.Name) then
    raise FBuffer.ParseError(@RS_BSON_QUOTE_EXPECTED);

  State := TBsonReaderState.Value;
  Result := CurrentName;
end;

procedure TJsonReader.ReadNull;
begin
  VerifyBsonType(TBsonType.Null);
  State := GetNextState;
end;

function TJsonReader.ReadObjectId: TObjectId;
begin
  VerifyBsonType(TBsonType.ObjectId);
  State := GetNextState;
  Result := FCurrentValue.ObjectIdVal;
end;

function TJsonReader.ReadRegularExpression: TBsonRegularExpression;
var
  I: Integer;
begin
  VerifyBsonType(TBsonType.RegularExpression);
  State := GetNextState;
  I := FCurrentValue.StrVal.IndexOf(#1);
  if (I < 0) then
    Result := TBsonRegularExpression.Create(FCurrentValue.StrVal)
  else
    Result := TBsonRegularExpression.Create(FCurrentValue.StrVal.Substring(0, I),
      FCurrentValue.StrVal.Substring(I + 1));
end;

procedure TJsonReader.ReadStartArray;
begin
  VerifyBsonType(TBsonType.&Array);
  PushContext(TBsonContextType.&Array);
  State := TBsonReaderState.&Type;
end;

procedure TJsonReader.ReadStartDocument;
begin
  VerifyBsonType(TBsonType.Document);
  PushContext(TBsonContextType.Document);
  State := TBsonReaderState.&Type;
end;

function TJsonReader.ReadString: String;
begin
  VerifyBsonType(TBsonType.String);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TJsonReader.ReadSymbol: String;
begin
  VerifyBsonType(TBsonType.Symbol);
  State := GetNextState;
  Result := FCurrentValue.StrVal;
end;

function TJsonReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TBsonType.Timestamp);
  State := GetNextState;
  Result := FCurrentValue.Int64Val;
end;

procedure TJsonReader.ReadUndefined;
begin
  VerifyBsonType(TBsonType.Undefined);
  State := GetNextState;
end;

procedure TJsonReader.ReturnToBookmark(
  const ABookmark: IBsonReaderBookmark);
var
  BM: TJsonBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TJsonBookmark);
  BM := TJsonBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];

  if Assigned(BM.CurrentToken) then
    FCurrentToken.Assign(BM.CurrentToken)
  else
    FCurrentToken := nil;

  FCurrentValue := BM.CurrentValue;

  if Assigned(BM.PushedToken) then
  begin
    FTokenToPush.Assign(BM.PushedToken);
    FPushedToken := FTokenToPush;
  end
  else
    FPushedToken := nil;

  FBuffer.Current := BM.Current;
end;

procedure TJsonReader.SetCurrentValueRegEx(const AToken: TToken);
begin
  { Put in separate (non-inlined) method to avoid string finalization }
  FCurrentValue.StrVal := AToken.LexemeToString;
end;

procedure TJsonReader.SkipName;
begin
  if (State <> TBsonReaderState.Name) then
    raise FBuffer.ParseError(@RS_BSON_QUOTE_EXPECTED);

  State := TBsonReaderState.Value;
end;

procedure TJsonReader.SkipValue;
begin
  if (State <> TBsonReaderState.Value) then
    raise FBuffer.ParseError(@RS_BSON_INVALID_READER_STATE);

  case CurrentBsonType of
    TBsonType.&Array:
      begin
        ReadStartArray;
        while (ReadBsonType <> TBsonType.EndOfDocument) do
          SkipValue;
        ReadEndArray;
      end;

    TBsonType.Binary: ReadBinaryData;
    TBsonType.Boolean: ReadBoolean;
    TBsonType.DateTime: ReadDateTime;

    TBsonType.Document:
      begin
        ReadStartDocument;
        while (ReadBsonType <> TBsonType.EndOfDocument) do
        begin
          SkipName;
          SkipValue;
        end;
        ReadEndDocument;
      end;

    TBsonType.Double: ReadDouble;
    TBsonType.Int32: ReadInt32;
    TBsonType.Int64: ReadInt64;
    TBsonType.JavaScript: ReadJavaScript;

    TBsonType.JavaScriptWithScope:
      begin
        ReadJavaScriptWithScope;
        ReadStartDocument;
        while (ReadBsonType <> TBsonType.EndOfDocument) do
        begin
          SkipName;
          SkipValue;
        end;
        ReadEndDocument;
      end;

    TBsonType.MaxKey: ReadMaxKey;
    TBsonType.MinKey: ReadMinKey;
    TBsonType.Null: ReadNull;
    TBsonType.ObjectId: ReadObjectId;
    TBsonType.RegularExpression: ReadRegularExpression;
    TBsonType.String: ReadString;
    TBsonType.Symbol: ReadSymbol;
    TBsonType.Timestamp: ReadTimestamp;
    TBsonType.Undefined: ReadUndefined;
  else
    raise FBuffer.ParseError(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TJsonReader.VerifyString(const AExpectedString: String);
var
  Token: TToken;
begin
  PopToken(Token);
  if (not (Token.TokenType in [TTokenType.String, TTokenType.UnquotedString]))
    or (Token.StringValue <> AExpectedString)
  then
    raise FBuffer.ParseError(@RS_BSON_STRING_WITH_VALUE_EXPECTED, [AExpectedString, Token.StringValue]);
end;

procedure TJsonReader.VerifyToken(const AExpectedLexeme: Char);
var
  Token: TToken;
begin
  PopToken(Token);
  if (Token.LexemeLength <> 1) or (Token.LexemeStart^ <> AExpectedLexeme) then
    raise FBuffer.ParseError(@RS_BSON_TOKEN_EXPECTED, [String(AExpectedLexeme), Token.LexemeToString]);
end;

procedure TJsonReader.VerifyToken(const AExpectedLexeme: PChar;
  const AExpectedLexemeLength: Integer);
var
  Token: TToken;
begin
  PopToken(Token);
  if (not Token.IsLexeme(AExpectedLexeme, AExpectedLexemeLength)) then
    raise FBuffer.ParseError(@RS_BSON_TOKEN_EXPECTED, [String(AExpectedLexeme), Token.LexemeToString]);
end;

{ TJsonReader.TContext }

procedure TJsonReader.TContext.Initialize(
  const AContextType: TBsonContextType);
begin
  FContextType := AContextType;
end;

{ TJsonReader.TBuffer }

procedure TJsonReader.TBuffer.ClearErrorPos;
begin
  FErrorPos := nil;
end;

class function TJsonReader.TBuffer.Create(const AJson: String): TBuffer;
begin
  Result.FJson := AJson;
  Result.FBuffer := PChar(AJson);
  Result.FCurrent := Result.FBuffer;
  Result.FLineStart := Result.FBuffer;
  Result.FPrevLineStart := Result.FBuffer;
  Result.FLineNumber := 1;
end;

function TJsonReader.TBuffer.ParseError(
  const AMsg: PResStringRec): EgoJsonParserError;
begin
  Result := ParseError(LoadResString(AMsg));
end;

function TJsonReader.TBuffer.ParseError(const AMsg: String): EgoJsonParserError;
var
  ColumnNumber, Position: Integer;
  ErrorPos, TextStart: PWideChar;
begin
  if Assigned(FErrorPos) then
    ErrorPos := FErrorPos
  else
    ErrorPos := FCurrent;
  FErrorPos := nil;

  if (ErrorPos = nil) then
  begin
    ColumnNumber := 1;
    Position := 0;
  end
  else
  begin
    TextStart := FBuffer;
    ColumnNumber := ErrorPos - FLineStart;
    Position := ErrorPos - TextStart;
  end;
  Result := EgoJsonParserError.Create(AMsg, FLineNumber, ColumnNumber, Position);
end;

procedure TJsonReader.TBuffer.MarkErrorPos;
begin
  FErrorPos := FCurrent;
end;

function TJsonReader.TBuffer.ParseError(const AMsg: String;
  const AArgs: array of const): EgoJsonParserError;
begin
  Result := ParseError(Format(AMsg, AArgs));
end;

function TJsonReader.TBuffer.ParseError(const AMsg: PResStringRec;
  const AArgs: array of const): EgoJsonParserError;
begin
  Result := ParseError(Format(LoadResString(AMsg), AArgs));
end;

function TJsonReader.TBuffer.Read: Char;
begin
  Result := FCurrent^;
  case Result of
     #0: ;
    #10: begin
           Inc(FCurrent);
           Inc(FLineNumber);
           FPrevLineStart := FLineStart;
           FLineStart := FCurrent;
         end;
  else
    Inc(FCurrent);
  end;
end;

procedure TJsonReader.TBuffer.Unread(const AChar: Char);
begin
  if (AChar = #0) then
    Exit;

  if (FCurrent = FBuffer) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if ((FCurrent - 1)^ <> AChar) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Dec(FCurrent);

  if (AChar = #10) then
  begin
    Dec(FLineNumber);
    FLineStart := FPrevLineStart;
  end;
end;

{ TJsonReader.TScanner }

var
  LEXEME_EOF         : array [0..4] of Char = '<eof>';
  LEXEME_BEGIN_OBJECT: Char = '{';
  LEXEME_END_OBJECT  : Char = '}';
  LEXEME_BEGIN_ARRAY : Char = '[';
  LEXEME_END_ARRAY   : Char = ']';
  LEXEME_LEFT_PAREN  : Char = '(';
  LEXEME_RIGHT_PAREN : Char = ')';
  LEXEME_COLON       : Char = ':';
  LEXEME_COMMA       : Char = ',';

class procedure TJsonReader.TScanner.CharBeginArray(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.BeginArray, @LEXEME_BEGIN_ARRAY, 1);
end;

class procedure TJsonReader.TScanner.CharBeginObject(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.BeginObject, @LEXEME_BEGIN_OBJECT, 1);
end;

class procedure TJsonReader.TScanner.CharColon(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.Colon, @LEXEME_COLON, 1);
end;

class procedure TJsonReader.TScanner.CharComma(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.Comma, @LEXEME_COMMA, 1);
end;

class procedure TJsonReader.TScanner.CharEndArray(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndArray, @LEXEME_END_ARRAY, 1);
end;

class procedure TJsonReader.TScanner.CharEndObject(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndObject, @LEXEME_END_OBJECT, 1);
end;

class procedure TJsonReader.TScanner.CharEof(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.EndOfFile, LEXEME_EOF, 5);
end;

class procedure TJsonReader.TScanner.CharError(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  Error: EgoJsonParserError;
begin
  ABuffer.ClearErrorPos;
  Error := ABuffer.ParseError(@RS_BSON_UNEXPECTED_TOKEN);
  ABuffer.Unread(AChar);
  raise Error;
end;

class procedure TJsonReader.TScanner.CharLeftParen(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.LeftParen, @LEXEME_LEFT_PAREN, 1);
end;

{$IFOPT Q+}
  {$DEFINE HAS_OVERFLOWCHECKS}
  {$OVERFLOWCHECKS OFF}
{$ENDIF}
class procedure TJsonReader.TScanner.CharNumberToken(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
{ Lexical grammar:
    NumberLiteral: ['-'] DecimalLiteral
    DecimalLiteral: 'Inifinity'
                  | ['.'] DecimalDigits [ExponentPart]
                  | DecimalDigits '.' [DecimalDigits] [ExponentPart]
    DecimalDigits: ('0'..'9')+
    ExponentPart: ('e' | 'E') ['+' | '-'] DecimalDigits

  There are 3 special values: Inifinity, -Infinity and NaN.
  The values Infinity and NaN are handled elsewhere (in ReadBsonType), so here
  we only need to handle -Infinity. }
const
  NFINITY = 'nfinity';
var
  Current, Start: PChar;
  C: Byte;
  IsNegative, IsNegativeExponent: Boolean;
  I, Power, Exponent: Integer;
  IntegerPart: Int64;
  Value: Double;
begin
  ABuffer.ClearErrorPos;
  Current := ABuffer.Current;
  Start := Current - 1;
  {$IF CompilerVersion < 28.0}
  C:=0; //Disable warning
  {$ENDIF}
  { NumberLiteral: ['-'] DecimalLiteral }
  if (AChar = '-') then
  begin
    IsNegative := True;
    IntegerPart := 0;
    if (Current^ = 'I') then
    begin
      { DecimalLiteral: 'Inifinity' }
      Inc(Current);
      for I := 0 to Length(NFINITY) - 1 do
      begin
        if (Current^ <> NFINITY.Chars[I]) then
        begin
          ABuffer.Current := Current;
          raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
        end;
        Inc(Current);
      end;

      ABuffer.Current := Current;
      C := Byte(Current^);
      if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
        AToken.Initialize(Start, Current - Start, NegInfinity)
      else
        raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
      Exit;
    end;
  end
  else
  begin
    IsNegative := False;
    IntegerPart := Ord(AChar) - Ord('0');
  end;

  { Parse integer part (before optional '.') }
  while True do
  begin
    C := Byte(Current^);
    if (C in [Ord('0')..Ord('9')]) then
    begin
      IntegerPart := (IntegerPart * 10) + (C - Ord('0'));
      Inc(Current);
    end
    else
      Break;
  end;

  if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
  begin
    { Integer value.
      Cannot start with a leading 0 (unless entire number is 0) }
    ABuffer.Current := Current;
    if (IntegerPart <> 0) and (Start^ = '0') then
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);

    if (IsNegative) then
      IntegerPart := -IntegerPart;

    if (IntegerPart < Low(Integer)) or (IntegerPart > High(Integer)) then
      AToken.Initialize(Start, Current - Start, IntegerPart)
    else
      AToken.Initialize(Start, Current - Start, Int32(IntegerPart));
    Exit;
  end;

  { Floating-point value }
  Value := IntegerPart;
  Power := 0;

  if (C = Ord('.')) then
  begin
    { Parse fractional part }
    Inc(Current);

    { Fractional part must start with a digit... }
    C := Byte(Current^);
    if (C in [Ord('0')..Ord('9')]) then
    begin
      Value := (Value * 10.0) + (C - Ord('0'));
      Inc(Current);
      Dec(Power);
    end
    else
    begin
      ABuffer.Current := Current;
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
    end;

    { ...followed by some more optional digits }
    while True do
    begin
      C := Byte(Current^);
      if (C in [Ord('0')..Ord('9')]) then
      begin
        Value := (Value * 10.0) + (C - Ord('0'));
        Inc(Current);
        Dec(Power);
      end
      else
        Break;
    end;
  end;

  if (C in [Ord('e'), Ord('E')]) then
  begin
    { Parse exponent }
    Exponent := 0;
    Inc(Current);
    C := Byte(Current^);
    IsNegativeExponent := False;
    if (C = Ord('-')) then
    begin
      IsNegativeExponent := True;
      Inc(Current);
      C := Byte(Current^);
    end
    else if (Current^ = '+') then
    begin
      Inc(Current);
      C := Byte(Current^);
    end;

    { Exponent must start with a digit... }
    if (C in [Ord('0')..Ord('9')]) then
    begin
      Exponent := (Exponent * 10) + (C - Ord('0'));
      Inc(Current);
    end
    else
    begin
      ABuffer.Current := Current;
      raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
    end;

    { ...followed by some more optional digits }
    while True do
    begin
      C := Byte(Current^);
      if (C in [Ord('0')..Ord('9')]) then
      begin
        Exponent := (Exponent * 10) + (C - Ord('0'));
        Inc(Current);
      end
      else
        Break;
    end;

    if (IsNegativeExponent) then
      Exponent := -Exponent;

    Inc(Power, Exponent);
  end;

  ABuffer.Current := Current;
  if (C in [0..32, Ord(','), Ord('}'), Ord(']'), Ord(')')]) then
  begin
    Value := Power10(Value, Power);
    if (IsNegative) then
      Value := -Value;
    AToken.Initialize(Start, Current - Start, Value);
  end
  else
    raise ABuffer.ParseError(@RS_BSON_INVALID_NUMBER);
end;
{$IFDEF HAS_OVERFLOWCHECKS}
  {$OVERFLOWCHECKS ON}
{$ENDIF}

class procedure TJsonReader.TScanner.CharRegularExpressionToken(
  var ABuffer: TBuffer; const AChar: Char; const AToken: TToken);
var
  Start: PChar;
  State: TRegularExpressionState;
  C: Char;
begin
  ABuffer.ClearErrorPos;
  Start := ABuffer.Current - 1;
  State := TRegularExpressionState.InPattern;
  while True do
  begin
    C := ABuffer.Read;
    case State of
      TRegularExpressionState.InPattern:
        case C of
          '/': State := TRegularExpressionState.InOptions;
          '\': State := TRegularExpressionState.InEscapeSequence;
        else
          State := TRegularExpressionState.InPattern;
        end;

      TRegularExpressionState.InEscapeSequence:
        State := TRegularExpressionState.InPattern;

      TRegularExpressionState.InOptions:
        case C of
          'i', 'm', 'x', 's': State := TRegularExpressionState.InOptions;
          ',', '}', ']', ')', #0: State := TRegularExpressionState.Done;
        else
          if IsWhiteSpace(C) then
            State := TRegularExpressionState.Done
          else
            State := TRegularExpressionState.Invalid;
        end;
    end;

    case State of
      TRegularExpressionState.Done:
        begin
          ABuffer.Unread(C);
          AToken.InitializeRegEx(Start, ABuffer.Current - Start);
          Exit;
        end;

      TRegularExpressionState.Invalid:
        raise ABuffer.ParseError(@RS_BSON_INVALID_REGEX);
    end;
  end;
end;

class procedure TJsonReader.TScanner.CharRightParen(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
begin
  ABuffer.MarkErrorPos;
  AToken.Initialize(TTokenType.RightParen, @LEXEME_RIGHT_PAREN, 1);
end;

class procedure TJsonReader.TScanner.CharStringToken(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  Current, Start: PChar;
  C: Char;
  S: String;
begin
  ABuffer.ClearErrorPos;
  Current := ABuffer.Current;
  Start := Current - 1;
  while True do
  begin
    C := Current^;
    Inc(Current);
    case C of
      #0:
        begin
          ABuffer.Current := Current;
          raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
        end;

      '\':
        begin
          SetString(S, Start + 1, Current - Start - 2);
          ABuffer.Current := Current - 1;
          CharStringTokenUnscape(ABuffer, AChar, AToken, Start, S);
          Exit;
        end;

      '''', '"':
        if (C = AChar) then
        begin
          SetString(S, Start + 1, Current - Start - 2);
          AToken.Initialize(TTokenType.String, Start, Current - Start, S);
          ABuffer.Current := Current;
          Exit;
        end;
    end;
  end;
end;

class procedure TJsonReader.TScanner.CharStringTokenUnscape(
  var ABuffer: TBuffer; const AQuoteChar: Char; const AToken: TToken;
  const AStart: PChar; const APrefix: String);
var
  CharBuffer: TCharBuffer;
  Current: PChar;
  I: Integer;
  C: Char;
  S: String;
begin
  Current := ABuffer.Current;
  CharBuffer.Initialize;
  try
    while True do
    begin
      C := Current^;
      Inc(Current);
      case C of
        #0:
          begin
            ABuffer.Current := Current;
            raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
          end;

        '\':
          begin
            C := Current^;
            Inc(Current);
            case C of
              '''', '"', '\', '/': CharBuffer.Append(C);
              'b': CharBuffer.Append(#8);
              't': CharBuffer.Append(#9);
              'n': CharBuffer.Append(#10);
              'f': CharBuffer.Append(#12);
              'r': CharBuffer.Append(#13);
              'u': begin
                     ABuffer.Current := Current;
                     SetLength(S, 5);
                     S[Low(String) + 0] := '$';
                     S[Low(String) + 1] := ABuffer.Read;
                     S[Low(String) + 2] := ABuffer.Read;
                     S[Low(String) + 3] := ABuffer.Read;
                     C := ABuffer.Read;
                     S[Low(String) + 4] := C;
                     if (C <> #0) then
                     begin
                       I := StrToIntDef(S, -1);
                       if (I < 0) then
                         raise ABuffer.ParseError(@RS_BSON_INVALID_UNICODE_CODEPOINT);
                       CharBuffer.Append(Char(I));
                     end
                     else
                       raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
                     Current := ABuffer.Current;
                   end;
            else
              ABuffer.Current := Current;
              raise ABuffer.ParseError(@RS_BSON_INVALID_STRING);
            end;
          end;

        '''', '"':
          if (C = AQuoteChar) then
          begin
            AToken.Initialize(TTokenType.String, AStart, Current - AStart,
              APrefix + CharBuffer.ToString);
            Exit;
          end
          else
            CharBuffer.Append(C);
      else
        CharBuffer.Append(C);
      end;
    end;
  finally
    CharBuffer.Release;
    ABuffer.Current := Current;
  end;
end;

class procedure TJsonReader.TScanner.CharUnquotedStringToken(
  var ABuffer: TBuffer; const AChar: Char; const AToken: TToken);
var
  Start: PChar;
  C: Char;
  Lexeme: String;
begin
  ABuffer.MarkErrorPos;
  Start := ABuffer.Current - 1;
  C := ABuffer.Read;
  while (C = '$') or (C = '_') or (C.IsLetterOrDigit) do
    C := ABuffer.Read;
  ABuffer.Unread(C);
  SetString(Lexeme, Start, ABuffer.Current - Start);
  AToken.Initialize(TTokenType.UnquotedString, Start, ABuffer.Current - Start, Lexeme);
end;

class procedure TJsonReader.TScanner.CharWhitespace(var ABuffer: TBuffer;
  const AChar: Char; const AToken: TToken);
var
  C: Char;
begin
  C := ABuffer.Read;
  if (C >= #$80) then
    CharError(ABuffer, C, AToken)
  else
    FCharHandlers[C](ABuffer, C, AToken);
end;

class procedure TJsonReader.TScanner.GetNextToken(var ABuffer: TBuffer;
  const AToken: TToken);
var
  C: Char;
begin
  C := ABuffer.Read;
  while (C <> #0) and (C <= ' ') do
    C := ABuffer.Read;

  if (C >= #$80) then
    CharError(ABuffer, C, AToken)
  else
    FCharHandlers[C](ABuffer, C, AToken);
end;

class procedure TJsonReader.TScanner.Initialize;
var
  C: Char;
begin
  for C := #0 to #127 do
    FCharHandlers[C] := CharError;

  FCharHandlers[#0] := CharEof;
  for C := #1 to #32 do
    FCharHandlers[C] := CharWhitespace;
  for C := '0' to '9' do
    FCharHandlers[C] := CharNumberToken;
  for C := 'a' to 'z' do
    FCharHandlers[C] := CharUnquotedStringToken;
  for C := 'A' to 'Z' do
    FCharHandlers[C] := CharUnquotedStringToken;

  FCharHandlers['{'] := CharBeginObject;
  FCharHandlers['}'] := CharEndObject;
  FCharHandlers['['] := CharBeginArray;
  FCharHandlers[']'] := CharEndArray;
  FCharHandlers['('] := CharLeftParen;
  FCharHandlers[')'] := CharRightParen;
  FCharHandlers[':'] := CharColon;
  FCharHandlers[','] := CharComma;
  FCharHandlers[''''] := CharStringToken;
  FCharHandlers['"'] := CharStringToken;
  FCharHandlers['/'] := CharRegularExpressionToken;
  FCharHandlers['-'] := CharNumberToken;
  FCharHandlers['$'] := CharUnquotedStringToken;
  FCharHandlers['_'] := CharUnquotedStringToken;
end;

class function TJsonReader.TScanner.IsWhitespace(const AChar: Char): Boolean;
begin
//  Result := AChar.IsWhitespace; // Official, but slow
  Result := (AChar <= ' ');
end;

{ TJsonReader.TToken }

procedure TJsonReader.TToken.Assign(const AOther: TToken);
begin
  if (AOther = Self) then
    Exit;

  FTokenType := AOther.FTokenType;
  FLexemeStart := AOther.FLexemeStart;
  FLexemeLength := AOther.FLexemeLength;
  FStringValue := AOther.FStringValue;
  FValue := AOther.FValue;
end;

procedure TJsonReader.TToken.Initialize(const ATokenType: TTokenType;
  const ALexemeStart: PChar; const ALexemeLength: Integer);
begin
  FTokenType := ATokenType;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
end;

procedure TJsonReader.TToken.Initialize(const ATokenType: TTokenType;
  const ALexemeStart: PChar; const ALexemeLength: Integer;
  const AStringValue: String);
begin
  FTokenType := ATokenType;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FStringValue := AStringValue;
end;

procedure TJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const ADoubleValue: Double);
begin
  FTokenType := TTokenType.Double;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.DoubleValue := ADoubleValue;
end;

procedure TJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const AInt32Value: Int32);
begin
  FTokenType := TTokenType.Int32;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.Int64Value := AInt32Value; // Clear upper 32 bits
end;

procedure TJsonReader.TToken.Initialize(const ALexemeStart: PChar;
  const ALexemeLength: Integer; const AInt64Value: Int64);
begin
  FTokenType := TTokenType.Int64;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
  FValue.Int64Value := AInt64Value;
end;

procedure TJsonReader.TToken.InitializeRegEx(const ALexemeStart: PChar;
  const ALexemeLength: Integer);
begin
  FTokenType := TTokenType.RegularExpression;
  FLexemeStart := ALexemeStart;
  FLexemeLength := ALexemeLength;
end;

function TJsonReader.TToken.IsLexeme(const AValue: PChar;
  const AValueLength: Integer): Boolean;
begin
  Result := (FLexemeLength = AValueLength)
    and CompareMem(AValue, FLexemeStart, AValueLength * SizeOf(Char));
end;

function TJsonReader.TToken.LexemeToString: String;
begin
  SetString(Result, FLexemeStart, FLexemeLength);
end;

{ TJsonReader.TJsonBookmark }

constructor TJsonReader.TJsonBookmark.Create(const AState: TBsonReaderState;
  const ACurrentBsonType: TBsonType; const ACurrentName: String;
  const AContextIndex: Integer; const ACurrentToken: TToken;
  const ACurrentValue: TValue; const APushedToken: TToken;
  const ACurrent: PChar);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  if Assigned(ACurrentToken) then
  begin
    FCurrentToken := TToken.Create;
    FCurrentToken.Assign(ACurrentToken);
  end;
  FCurrentValue := ACurrentValue;
  if Assigned(APushedToken) then
  begin
    FPushedToken := TToken.Create;
    FPushedToken.Assign(APushedToken);
  end;
  FCurrent := ACurrent;
end;

destructor TJsonReader.TJsonBookmark.Destroy;
begin
  FCurrentToken.Free;
  FPushedToken.Free;
  inherited;
end;

{ TBsonDocumentReader }

constructor TBsonDocumentReader.Create(const ADocument: TBsonDocument);
begin
  inherited Create;
  FCurrentValue := ADocument;
  FContextIndex := -1;
  PushContext(TBsonContextType.TopLevel, ADocument);
end;

function TBsonDocumentReader.EndOfStream: Boolean;
begin
  Result := (State = TBsonReaderState.Done);
end;

function TBsonDocumentReader.GetBookmark: IBsonReaderBookmark;
begin
  Assert(Assigned(FContext));
  Result := TDocumentBookmark.Create(State, CurrentBsonType, CurrentName,
    FContextIndex, FContext.Index, FCurrentValue);
end;

function TBsonDocumentReader.GetNextState: TBsonReaderState;
begin
  Assert(Assigned(FContext));
  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      Result := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      Result := TBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TBsonDocumentReader.PopContext;
begin
  Dec(FContextIndex);
  if (FContextIndex < 0) then
  begin
    FContext := nil;
    FContextIndex := -1;
  end
  else
    FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentReader.PushContext(
  const AContextType: TBsonContextType; const AArray: TBsonArray);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, AArray);
  FContext := @FContextStack[FContextIndex];
end;

procedure TBsonDocumentReader.PushContext(
  const AContextType: TBsonContextType; const ADocument: TBsonDocument);
begin
  Inc(FContextIndex);
  if (FContextIndex >= Length(FContextStack)) then
    SetLength(FContextStack, FContextIndex + 8);
  FContextStack[FContextIndex].Initialize(AContextType, ADocument);
  FContext := @FContextStack[FContextIndex];
end;

function TBsonDocumentReader.ReadBinaryData: TBsonBinaryData;
begin
  VerifyBsonType(TBsonType.Binary);
  State := GetNextState;
  Result := FCurrentValue.AsBsonBinaryData;
end;

function TBsonDocumentReader.ReadBoolean: Boolean;
begin
  VerifyBsonType(TBsonType.Boolean);
  State := GetNextState;
  Result := FCurrentValue.AsBoolean;
end;

function TBsonDocumentReader.ReadBsonType: TBsonType;
var
  CurrentElement: TBsonElement;
begin
  if (State in [TBsonReaderState.Initial, TBsonReaderState.ScopeDocument]) then
  begin
    CurrentBsonType := TBsonType.Document;
    State := TBsonReaderState.Value;
    Exit(CurrentBsonType);
  end;

  if (State <> TBsonReaderState.&Type) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  Assert(Assigned(FContext));
  case FContext.ContextType of
    TBsonContextType.&Array:
      begin
        if (not FContext.TryGetNextValue(FCurrentValue)) then
        begin
          State := TBsonReaderState.EndOfArray;
          Exit(TBsonType.EndOfDocument);
        end;
        State := TBsonReaderState.Value;
      end;

    TBsonContextType.Document:
      begin
        if (not FContext.TryGetNextElement(CurrentElement)) then
        begin
          State := TBsonReaderState.EndOfDocument;
          Exit(TBsonType.EndOfDocument);
        end;
        CurrentName := CurrentElement.Name;
        FCurrentValue := CurrentElement.Value;
        State := TBsonReaderState.Name;
      end;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;

  CurrentBsonType := FCurrentValue.BsonType;
  Result := CurrentBsonType;
end;

function TBsonDocumentReader.ReadBytes: TBytes;
var
  Binary: TBsonBinaryData;
  SubType: TBsonBinarySubType;
begin
  VerifyBsonType(TBsonType.Binary);
  State := GetNextState;
  Binary := FCurrentValue.AsBsonBinaryData;
  SubType := Binary.SubType;
  if (not (SubType in [TBsonBinarySubType.Binary, TBsonBinarySubType.OldBinary])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_DATA);
  Result := Binary.AsBytes;
end;

function TBsonDocumentReader.ReadDateTime: Int64;
begin
  VerifyBsonType(TBsonType.DateTime);
  State := GetNextState;
  Result := FCurrentValue.AsBsonDateTime.MillisecondsSinceEpoch;
end;

function TBsonDocumentReader.ReadDouble: Double;
begin
  VerifyBsonType(TBsonType.Double);
  State := GetNextState;
  Result := FCurrentValue.AsDouble;
end;

procedure TBsonDocumentReader.ReadEndArray;
begin
  Assert(Assigned(FContext));
  if (FContext.ContextType <> TBsonContextType.&Array) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfArray) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext;
  Assert(Assigned(FContext));

  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      State := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

procedure TBsonDocumentReader.ReadEndDocument;
begin
  Assert(Assigned(FContext));
  if (not (FContext.ContextType in [TBsonContextType.Document, TBsonContextType.ScopeDocument])) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  if (State = TBsonReaderState.&Type) then
    ReadBsonType;

  if (State <> TBsonReaderState.EndOfDocument) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  PopContext;
  Assert(Assigned(FContext));

  case FContext.ContextType of
    TBsonContextType.&Array,
    TBsonContextType.Document:
      State := TBsonReaderState.&Type;

    TBsonContextType.TopLevel:
      State := TBsonReaderState.Done;
  else
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);
  end;
end;

function TBsonDocumentReader.ReadInt32: Integer;
begin
  VerifyBsonType(TBsonType.Int32);
  State := GetNextState;
  Result := FCurrentValue.AsInteger;
end;

function TBsonDocumentReader.ReadInt64: Int64;
begin
  VerifyBsonType(TBsonType.Int64);
  State := GetNextState;
  Result := FCurrentValue.AsInt64;
end;

function TBsonDocumentReader.ReadJavaScript: String;
begin
  VerifyBsonType(TBsonType.JavaScript);
  State := GetNextState;
  Result := FCurrentValue.AsBsonJavaScript.Code;
end;

function TBsonDocumentReader.ReadJavaScriptWithScope: String;
begin
  VerifyBsonType(TBsonType.JavaScriptWithScope);
  State := TBsonReaderState.ScopeDocument;
  Result := FCurrentValue.AsBsonJavaScriptWithScope.Code;
end;

procedure TBsonDocumentReader.ReadMaxKey;
begin
  VerifyBsonType(TBsonType.MaxKey);
  State := GetNextState;
end;

procedure TBsonDocumentReader.ReadMinKey;
begin
  VerifyBsonType(TBsonType.MinKey);
  State := GetNextState;
end;

function TBsonDocumentReader.ReadName: String;
begin
  if (FState = TBsonReaderState.&Type) then
    ReadBsonType;

  if (FState <> TBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TBsonReaderState.Value;
  Result := CurrentName;
end;

procedure TBsonDocumentReader.ReadNull;
begin
  VerifyBsonType(TBsonType.Null);
  State := GetNextState;
end;

function TBsonDocumentReader.ReadObjectId: TObjectId;
begin
  VerifyBsonType(TBsonType.ObjectId);
  State := GetNextState;
  Result := FCurrentValue.AsObjectId;
end;

function TBsonDocumentReader.ReadRegularExpression: TBsonRegularExpression;
begin
  VerifyBsonType(TBsonType.RegularExpression);
  State := GetNextState;
  Result := FCurrentValue.AsBsonRegularExpression;
end;

procedure TBsonDocumentReader.ReadStartArray;
var
  A: TBsonArray;
begin
  VerifyBsonType(TBsonType.&Array);
  A := FCurrentValue.AsBsonArray;
  PushContext(TBsonContextType.&Array, A);
  State := TBsonReaderState.&Type;
end;

procedure TBsonDocumentReader.ReadStartDocument;
var
  Document: TBsonDocument;
begin
  VerifyBsonType(TBsonType.Document);

  if (FCurrentValue.IsBsonJavaScriptWithScope) then
    Document := FCurrentValue.AsBsonJavaScriptWithScope.Scope
  else
    Document := FCurrentValue.AsBsonDocument;

  PushContext(TBsonContextType.Document, Document);
  State := TBsonReaderState.&Type;
end;

function TBsonDocumentReader.ReadString: String;
begin
  VerifyBsonType(TBsonType.String);
  State := GetNextState;
  Result := FCurrentValue.AsString;
end;

function TBsonDocumentReader.ReadSymbol: String;
begin
  VerifyBsonType(TBsonType.Symbol);
  State := GetNextState;
  Result := FCurrentValue.AsBsonSymbol.Name;
end;

function TBsonDocumentReader.ReadTimestamp: Int64;
begin
  VerifyBsonType(TBsonType.Timestamp);
  State := GetNextState;
  Result := FCurrentValue.AsBsonTimestamp.Value;
end;

procedure TBsonDocumentReader.ReadUndefined;
begin
  VerifyBsonType(TBsonType.Undefined);
  State := GetNextState;
end;

procedure TBsonDocumentReader.ReturnToBookmark(
  const ABookmark: IBsonReaderBookmark);
var
  BM: TDocumentBookmark;
begin
  Assert(Assigned(ABookmark));
  Assert(ABookmark is TDocumentBookmark);
  BM := TDocumentBookmark(ABookmark);
  State := BM.State;
  CurrentBsonType := BM.CurrentBsonType;
  CurrentName := BM.CurrentName;
  FContextIndex := BM.ContextIndex;
  Assert((FContextIndex >= 0) and (FContextIndex < Length(FContextStack)));
  FContext := @FContextStack[FContextIndex];
  FContext.Index := BM.ContextIndexIndex;
  FCurrentValue := BM.CurrentValue;
end;

procedure TBsonDocumentReader.SkipName;
begin
  if (FState <> TBsonReaderState.Name) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TBsonReaderState.Value;
end;

procedure TBsonDocumentReader.SkipValue;
begin
  if (FState <> TBsonReaderState.Value) then
    raise EInvalidOperation.CreateRes(@RS_BSON_INVALID_READER_STATE);

  State := TBsonReaderState.&Type;
end;

{ TBsonDocumentReader.TContext }

procedure TBsonDocumentReader.TContext.Initialize(
  const AContextType: TBsonContextType; const ADocument: TBsonDocument);
begin
  FContextType := AContextType;
  FDocument := ADocument;
  FIndex := 0;
end;

procedure TBsonDocumentReader.TContext.Initialize(
  const AContextType: TBsonContextType; const AArray: TBsonArray);
begin
  FContextType := AContextType;
  FArray := AArray;
  FIndex := 0;
end;

function TBsonDocumentReader.TContext.TryGetNextElement(
  out AElement: TBsonElement): Boolean;
begin
  if (FIndex < FDocument.Count) then
  begin
    AElement := FDocument.Elements[FIndex];
    Inc(FIndex);
    Result := True;
  end
  else
  begin
    AElement := Default(TBsonElement);
    Result := False;
  end;
end;

function TBsonDocumentReader.TContext.TryGetNextValue(
  out AValue: TBsonValue): Boolean;
begin
  if (FIndex < FArray.Count) then
  begin
    AValue := FArray[FIndex];
    Inc(FIndex);
    Result := True;
  end
  else
    Result := False;
end;

{ TBsonDocumentReader.TDocumentBookmark }

constructor TBsonDocumentReader.TDocumentBookmark.Create(
  const AState: TBsonReaderState; const ACurrentBsonType: TBsonType;
  const ACurrentName: String; const AContextIndex, AContextIndexIndex: Integer;
  const ACurrentValue: TBsonValue);
begin
  inherited Create(AState, ACurrentBsonType, ACurrentName);
  FContextIndex := AContextIndex;
  FContextIndexIndex := AContextIndexIndex;
  FCurrentValue := ACurrentValue;
end;

end.
