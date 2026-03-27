unit Lib.Bson;
(*< A light-weight and fast BSON and JSON object model, with support for
  efficiently parsing and writing in JSON and BSON format.

  The code in this unit is fully compatible with the BSON and JSON used by
  MongoDB. It supports all JSON extensions used by MongoDB.

  However, this unit does @bold(not) have any dependencies on the MongoDB units
  and can be used as a stand-alone BSON/JSON library. It is therefore also
  suitable as a general purpose JSON library.

  @bold(Quick Start)

  <source>
  var
    Doc: TBsonDocument;
    A: TBsonArray;
    Json: String;
    Bson: TBytes;
  begin
    Doc := TBsonDocument.Create;
    Doc.Add('Hello', 'World');

    A := TBsonArray.Create(['awesome', 5.05, 1986]);
    Doc.Add('BSON', A);

    Json := Doc.ToJson; // Returns:
    // { "hello" : "world",
    //   "BSON": ["awesone", 5.05, 1986] }

    Bson := Doc.ToBson; // Saves to binary BSON

    Doc := TBsonDocument.Parse('{ "Answer" : 42 }');
    WriteLn(Doc['Answer']); // Outputs 42
    Doc['Answer'] := 'Unknown';
    Doc['Pi'] := 3.14;
    WriteLn(Doc.ToJson); // Outputs { "Answer" : "Unknown", "Pi" : 3.14 }
  end;
  </source>

  @bold(Object Model)

  The root type in the BSON object model is TBsonValue. TBsonValue is a
  record type which can hold any type of BSON value. Some implicit class
  operators make it easy to assign basic types:

  <source>
  var
    Value: TBsonValue;
  begin
    Value := True;                           // Creates a Boolean value
    Value := 1;                              // Creates an Integer value
    Value := 3.14;                           // Creates a Double value
    Value := 'Foo';                          // Creates a String value
    Value := TBytes.Create(1, 2, 3);         // Creates a binary (TBytes) value
    Value := TObjectId.GenerateNewId;      // Creates an ObjectId value
  end;
  </source>

  Note that you can change the type later by assigning a value of another type.
  You can also go the other way around:

  <source>
  var
    Value: TBsonValue;
    FloatVal: Double;
  begin
    Value := 3.14;              // Creates a Double value
    FloatVal := Value;          // Uses implicit cast
    FloatVal := Value.AsDouble; // Or more explicit cast
    Value := 42;                // Creates an Integer value
    FloatVal := Value;          // Converts an Integer BSON value to a Double
    FloatVal := Value.AsDouble; // Raises exception because types don't match exactly

    if (Value.BsonType = TBsonType.Double) then
      FloatVal := Value.AsDouble; // Now it is safe to cast

    // Or identical:
    if (Value.IsDouble) then
      FloatVal := Value.AsDouble;
  end;
  </source>

  Note that the implicit operators will try to convert if the types don't match
  exactly. For example, a BSON value containing an Integer value can be
  implicitly converted to a Double. If the conversion fails, it returns a zero
  value (or empty string).

  The "As*" methods however will raise an exception if the types don't match
  exactly. You should use these methods if you know that the type you request
  matches the value's type exactly. These methods are a bit more efficient than
  the implicit operators.

  You can check the value type using the BsonType-property or one of the "Is*"
  methods.

  For non-basic types, there are value types that are "derived" from
  TBsonValue:
  * TBsonNull: the special "null" value
  * TBsonArray: an array of other BSON values.
  * TBsonDocument: a document containing key/value pairs, where the key is a
    string and the value can be any BSON value. This is usually the main
    starting point in Mongo, since all database "records" are represented as
    BSON documents in Mongo. A document is similar to a dictionary in many
    programming languages, or the "object" type in JSON.
  * TBsonBinaryData: arbitrary binary data. Is also used to store GUID's (but
    not ObjectId's).
  * TBsonDateTime: a date/time value with support for conversion to and from
    UTC (Universal) time. Is always stored in UTC format (as the number of UTC
    milliseconds since the Unix epoch).
  * TBsonRegularExpression: a regular expression with options.
  * TBsonJavaScript: a piece of JavaScript code.
  * TBsonJavaScriptWithScope: a piece of JavaScript code with a scope (a set
    of variables with values, as defined in another document).
  * TBsonTimestamp: special internal type used by MongoDB replication and
    sharding.
  * TBsonMaxKey: special type which compares higher than all other possible
    BSON element values.
  * TBsonMinKey: special type which compares lower than all other possible
    BSON element values.
  * TBsonUndefined: an undefined value (deprecated by BSON)
  * TBsonSymbol: a symbol from a lookup table (deprecated by BSON)

  Note that these are not "real" derived types, since they are implemented as
  Delphi records (which do not support inheritance). But the implicit operators
  make it possible to treat each of these types as a TBsonValue. For example

  <source>
  var
    MyArray: TBsonArray;
    Value: TBsonValue;
  begin
    MyArray := TBsonArray.Create([1, 3.14, 'Foo', False]);
    Value := MyArray; // "subtypes" are compatible with TBsonValue

    // Or shorter:
    Value := TBsonArray.Create([1, 3.14, 'Foo', False]);
  end;
  </source>

  @Bold(Arrays)

  The example above also shows that arrays can be created very easily. An array
  contains a collection of BSON values of any type. Since BSON values can be
  implicitly created from basic types, you can pass multiple types in the
  array constructor. In the example above, 4 BSON values will be added to the
  array of types Integer, Double, String and Boolean.

  You can also add items using the Add or AddRange methods:

  <source>
  MyArray := TBsonArray.Create;
  MyArray.Add(1);
  MyArray.Add(3.14);
  MyArray.Add('Foo');
  </source>

  Some methods return the array (or document) itself, so they can be used for
  chaining (aka as a "fluent interface"). The example above is equivalent to:

  <source>
  MyArray := TBsonArray.Create;
  MyArray.Add(1).Add(3.14).Add('Foo');
  </source>

  You can change values (and types) like this:

  <source>
  // Changes entry 1 from Double to Boolean
  MyArray[1] := True;
  </source>

  @Bold(Documents)

  Documents (or dictionaries) can also be created easily:

  <source>
  var
    Doc: TBsonDocument;
  begin
    Doc := TBsonDocument.Create('Answer', 42);
  end;
  </source>

  This creates a document with a single entry called 'Answer' with a value of
  42. Keep in mind that the value can be any BSON type:

  <source>
  Doc := TBsonDocument.Create('Answer', TBsonArray.Create([42, False]));
  </source>

  You can Add, Remove and Delete (Adds can be fluent):

  <source>
  Doc := TBsonDocument.Create;
  Doc.Add('Answer', 42);
  Doc.Add('Pi', 3.14).Add('Pie', 'Yummi');

  // Deletes second item (Pi):
  Doc.Delete(1);

  // Removes first item (Answer):
  Doc.Remove('Answer');
  </source>

  Like Delphi dictionaries, the Add method will raise an exception if an item
  with the given name already exists. Unlike Delphi dictionaries however, you
  can easily set an item using its default accessor:

  <source>
  // Adds Answer:
  Doc['Answer'] := 42;

  // Adds Pi:
  Doc['Pi'] := 3.14;

  // Updates Answer:
  Doc['Answer'] := 'Everything';
  </source>

  This adds the item if it does not yet exists, or replaces it otherwise (there
  is no (need for an) AddOrSet method).

  Also unlike Delphi dictionaries, documents maintain insertion order and you
  can also access the items by index:

  <source>
  // Returns item by name:
  V := Doc['Pi'];

  // Returns item by index:
  V := Doc.Values[1];
  </source>

  Documents can be easily parsed from JSON:

  <source>
  Doc := TBsonDocument.Parse('{ "Answer" : 42 }');
  </source>

  The parser understands standard JSON as well as the MongoDB JSON extensions.

  You can also load a document from a BSON byte array:

  <source>
  Bytes := LoadSomeBSONData();
  Doc := TBsonDocument.Load(Bytes);
  </source>

  These methods will raise exceptions if the JSON or BSON data is invalid.

  @bold(Memory Management)

  All memory management in this library is automatic. You never need to (and you
  never must) destroy any objects yourself.

  The object model types (TBsonValue and friends) are all Delphi records. The
  actual implementations of these records use interfaces to manage memory.

  There is no concept of ownership in the object model. An array does @bold(not)
  own its elements and a document does @bold(not) own its elements. So you are
  free to add the same value to multiple arrays and/or documents without
  ownership concerns:

  <source>
  var
    Array1, Array2, SubArray, Doc1, Doc2: TBsonValue;
  begin
    SubArray := TBsonArray.Create([42, 'Foo', True]);
    Array1 := TBsonArray.Create;
    Array2 := TBsonArray.Create([123, 'Abc']);
    Doc1 := TBsonDocument.Create;
    Doc2 := TBsonDocument.Create('Pi', 3.14);

    Array1.Add(SubArray);
    Array2.Add(SubArray);      // Add same value to other container
    Doc1.Add('Bar', SubArray); // And again
    Doc2.Add('Baz', SubArray); // And again
  end;
  </source>

  Non-object model types are defined as interfaces, so their memory is managed
  automatically as well. For example JSON/BSON readers and writer are
  interfaces:

  <source>
  var
    Reader: IgoJsonReader;
    Value: TBsonValue;
  begin
    Reader := TJsonReader.Create('{ "Pi" : 3.14 }');
    Value := Reader.ReadValue;
    Assert(Value.IsDocument);
    Assert(Value.AsDocument['Pi'] = 3.14);
  end;
  </source>

  Just keep in mind that you must always declare your variable (Reader) as an
  interface type (IgoJsonReader), but you construct it using the class type
  (TJsonReader).

  @bold(JSON and BSON reading and writing)

  For easy storing, all BSON values have methods called ToJson and ToBson to
  store its value into JSON or BSON format:

  <source>
  var
    A: TBsonValue;
    B: TBytes;
  begin
    A := 42;
    WriteLn(A.ToJson); // Outputs '42'

    A := 'Foo';
    WriteLn(A.ToJson); // Outputs '"Foo"'

    A := TBsonArray.Create([1, 'Foo', True]);
    WriteLn(A.ToJson); // Outputs '[1, "Foo", true]'

    A := TBsonDocument.Create('Pi', 3.14);
    WriteLn(A.ToJson); // Outputs '{ "Pi" : 3.14 }'
    B := A.ToBson;     // Outputs document in BSON format
  end;
  </source>

  When outputting to JSON, you can optionally supply a settings record to
  customize the output:
  * Whether to pretty-print the output
  * What strings to use for indentation and line breaks
  * Whether to output standard JSON or use the MongoDB shell syntax extension

  If you don's supply any settings, then output will be in Strict JSON format
  without pretty printing.

  Easy loading is only supported at the Value, Document and Array level, using
  the Parse and Load methods:

  <source>
  var
    Doc: TBsonDocument;
    Bytes: TBytes;
  begin
    Doc := TBsonDocument.Parse('{ "Pi" : 3.14 }');
    Bytes := LoadSomeBSONData();
    Doc := TBsonDocument.Load(Bytes);
  end;
  </source>

  You can load other types using the IgoJsonReader and IgoBsonReader
  interfaces:

  <source>
  var
    Reader: IgoBsonReader;
    Value: TBsonValue;
    Bytes: TBytes;
  begin
    Bytes := LoadSomeBSONData();
    Reader := TBsonReader.Create(Bytes);
    Value := Reader.ReadValue;
  end;
  </source>

  The JSON reader and writer supports both the "strict" JSON syntax, as well as
  the "Mongo Shell" syntax (see https://docs.mongodb.org/manual/reference/mongodb-extended-json/).
  Extended JSON is supported for both reading and writing. This library supports
  all the current extensions, as well as some deprecated legacy extensions.
  The JSON reader accepts both key names with double quotes (as per JSON spec)
  as without quotes.

  @bold(Manual reading and writing)

  For all situations, the methods ToJson, ToBson, Parse and Load can take care
  of reading and writing any kind of JSON and BSON data.

  However, you can use the reading and writing interfaces directly if you want
  for some reason. One reason may be that you want the fastest performance when
  creating BSON payloads, without the overhead of creating a document object
  model in memory.

  For information, see the unit Lib.Data.Bson.IO

  @bold(Serialization)

  For even easier reading and writing, you can use serialization to directory
  store a Delphi record or object in JSON or BSON format (or convert it to a
  TBsonDocument).

  For information, see the unit Lib.Data.Bson.Serialization *)

{$INCLUDE 'Lib.inc'}

interface

uses
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections;

type
  { Supported BSON types. As returned by TBsonValue.BsonType.
    Tech note: Ordinal values must match BSON spec (http://bsonspec.org) }
  TBsonType = (
    { Not a real BSON type. Used to signal the end of a document. }
    EndOfDocument       = $00,

    { A BSON double }
    Double              = $01,

    { A BSON string }
    &String             = $02,

    { A BSON document (see TBsonDocument) }
    Document            = $03,

    { A BSON array (see TBsonArray) }
    &Array              = $04,

    { BSON binary data (see TBsonBinaryData) }
    Binary              = $05,

    { A BSON undefined value (see TBsonUndefined) }
    Undefined           = $06,

    { A ObjectId, generally used with MongoDB (see TObjectId) }
    ObjectId            = $07,

    { A BSON boolean }
    Boolean             = $08,

    { A BSON DateTime (see TBsonDateTime) }
    DateTime            = $09,

    { A BSON null value (see TBsonNull) }
    Null                = $0A,

    { A BSON regular expression (see TBsonRegularExpression) }
    RegularExpression   = $0B,

    { BSON JavaScript code (see TBsonJavaScript) }
    JavaScript          = $0D,

    { A BSON Symbol (see TBsonSymbol, deprecated) }
    Symbol              = $0E,

    { BSON JavaScript code with a scope (see TBsonJavaScriptWithScope) }
    JavaScriptWithScope = $0F,

    { A BSON 32-bit integer }
    Int32               = $10,

    { A BSON Timestamp (see TBsonTimestamp) }
    Timestamp           = $11,

    { A BSON 64-bit integer }
    Int64               = $12,

    { A BSON MaxKey value (see TBsonMaxKey) }
    MaxKey              = $7F,

    { A BSON MinKey value (see TBsonMinKey) }
    MinKey              = $FF);

type
  { Supported BSON binary sub types.
    As returned by TBsonBinaryData.SubType.
    Tech note: Ordinal values must match BSON spec (http://bsonspec.org) }
  TBsonBinarySubType = (
    { Binary data in an arbitrary format }
    Binary       = $00,

    { A function }
    &Function    = $01,

    { Obsolete binary type }
    OldBinary    = $02,

    { A UUID/GUID in driver dependent legacy byte order }
    UuidLegacy   = $03,

    { A UUID/GUID in standard network byte order (big endian) }
    UuidStandard = $04,

    { A MD5 hash }
    MD5          = $05,

    { User defined type }
    UserDefined  = $80);

type
  { The output mode of a IgoJsonWriter, as set using TJsonWriterSettings. }
  TJsonOutputMode = (
    { Outputs strict JSON }
    Strict,

    { Outputs a format that can be used by the MongoDB shell }
    Shell);

type
  { Settings for a IgoJsonWriter }
  TJsonWriterSettings = record
  {$REGION 'Internal Declarations'}
  private class var
    FDefault: TJsonWriterSettings;
    FShell: TJsonWriterSettings;
    FPretty: TJsonWriterSettings;
  private
    FPrettyPrint: Boolean;
    FIndent: String;
    FLineBreak: String;
    FOutputMode: TJsonOutputMode;
  public
    { @exclude }
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a settings record using the default settings:
      * PrettyPrint: False
      * OutputMode: Strict
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later)

      Returns:
        The settings }
    class function Create: TJsonWriterSettings; overload; static;

    { Creates a settings record:

      Parameters:
        APrettyPrint: whether to use indentation (see Indent) and line breaks
          (see LineBreak).
        AOutputMode: (optional) output mode. Defaults to Strict.

      Returns:
        The settings }
    class function Create(const APrettyPrint: Boolean;
      const AOutputMode: TJsonOutputMode = TJsonOutputMode.Strict): TJsonWriterSettings; overload; static;

    { Creates a settings record:

      Parameters:
        AIndent: the string to use for indentation. Should only contain
          whitespace characters to create valid output.
        ALineBreak: the string to use for line breaks. Should only contain
          whitespace characters to create valid output.
        AOutputMode: (optional) output mode. Defaults to Strict.

      Returns:
        The settings.

      @bold(Note): this constructor sets PrettyPrint to True. }
    class function Create(const AIndent, ALineBreak: String;
      const AOutputMode: TJsonOutputMode = TJsonOutputMode.Strict): TJsonWriterSettings; overload; static;

    { Creates a settings record:

      Parameters:
        AOutputMode: output mode to use.

      Returns:
        The settings

      @bold(Note): this constructor sets PrettyPrint to False. }
    class function Create(const AOutputMode: TJsonOutputMode): TJsonWriterSettings; overload; static;

    { The default settings:
      * PrettyPrint: False
      * OutputMode: Strict
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later) }
    class property Default: TJsonWriterSettings read FDefault;

    { "Shell" settings for outputing JSON with MongoDB shell extensions.
      * PrettyPrint: False
      * OutputMode: Shell
      * Indent: 2 spaces (not used unless PrettyPrint is set to True later)
      * LineBreak: CR+LF (not used unless PrettyPrint is set to True later) }
    class property Shell: TJsonWriterSettings read FShell;

    { Settings for outputing JSON compliant JSON in a pretty format.
      * PrettyPrint: True
      * OutputMode: Strict
      * Indent: 2 spaces
      * LineBreak: CR+LF }
    class property Pretty: TJsonWriterSettings read FPretty;

    { Whether to use indentation (see Indent) and line breaks (see LineBreak).
      Default False. }
    property PrettyPrint: Boolean read FPrettyPrint write FPrettyPrint;

    { String to use for indentation. Should only contain whitespace characters
      to create valid output. Not used unless PrettyPrint is True.
      Defaults to 2 spaces }
    property Indent: String read FIndent write FIndent;

    { String to use for line breaks. Should only contain whitespace characters
      to create valid output. Not used unless PrettyPrint is True.
      Defaults to CR+LF }
    property LineBreak: String read FLineBreak write FLineBreak;

    { Output mode to use.
      Defaults to Strict }
    property OutputMode: TJsonOutputMode read FOutputMode write FOutputMode;
  end;

type
  { Represents an ObjectId. This is a 12-byte (96-bit) value that is regularly
    used for (unique) primary keys in MongoDB databases.

    Internally, an ObjectId is composed of:
    * A 4-byte value containing the number of seconds since the Unix epoch.
    * A 3-byte machine identifier
    * A 2-byte process identifier
    * A 3-byte counter, starting from a random value

    This makes ObjectId's fairly unique (but not as unique as GUID's though) }
  TObjectId = record
  {$REGION 'Internal Declarations'}
  private class var
    FIncrement: Integer;
    FMachine: Integer;
    FPid: UInt16;
    FInitialized: Boolean;
  private
    function GetIsEmpty: Boolean;
    function GetTimestamp: Integer;
    function GetMachine: Integer;
    function GetPid: UInt16;
    function GetIncrement: Integer;
    function GetCreationTime: TDateTime;
  private
    class procedure Initialize; static;
    class function GetTimestampFromDateTime(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean): Integer; static;
  private
    procedure FromByteArray(const ABytes: TBytes);
  public
    { @exclude }
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an ObjectId from a byte array.

      Parameters:
        ABytes: the array of bytes to use for the ObjectId.
          Must be 12 bytes long.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if ABytes is not 12 bytes long }
    class function Create(const ABytes: TBytes): TObjectId; overload; static;

    { Creates an ObjectId from a byte array.

      Parameters:
        ABytes: the array of bytes to use for the ObjectId.
          Must be 12 bytes long.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if ABytes is not 12 bytes long }
    class function Create(const ABytes: array of Byte): TObjectId; overload; static;

    { Creates an ObjectId from its components.

      Parameters:
        ATimestamp: 32-bit number of seconds since Unix epoch.
        AMachine: 24-bit machine identifier. Must be >= 0 and < $01000000.
        APid: 16-bit process identifier.
        AIncrement: 24-bit counter. Must be >= 0 and < $01000000.

      Returns:
        The ObjectId.

      Raises:
        EArgumentOutOfRangeException if AMachine or AIncrement are out of range. }
    class function Create(const ATimestamp, AMachine: Integer; const APid: UInt16;
      const AIncrement: Integer): TObjectId; overload; static;

    { Creates an ObjectId from its components.

      Parameters:
        ATimestamp: the date/time to use as a timestamp.
        ATimestampIsUTC: whether ATimestamp is in universal time.
        AMachine: 24-bit machine identifier. Must be >= 0 and < $01000000.
        APid: 16-bit process identifier.
        AIncrement: 24-bit counter. Must be >= 0 and < $01000000.

      Returns:
        The ObjectId.

      Raises:
        EArgumentOutOfRangeException if AMachine or AIncrement are out of range. }
    class function Create(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean; const AMachine: Integer;
      const APid: UInt16; const AIncrement: Integer): TObjectId; overload; static;

    { Creates an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if AString does not contain 24 hex digits.

      @bold(Note): this constructor is equal to the Parse method. }
    class function Create(const AString: String): TObjectId; overload; static;

    { Generates a new ObjectId using the current timestamp, machine, process
      and counter settings.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId: TObjectId; overload; static;

    { Generates a new ObjectId using a given timestamp and the current machine,
      process and counter settings.

      Parameters:
        ATimestamp: the date/time to use as a timestamp.
        ATimestampIsUTC: whether ATimestamp is in universal time.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId(const ATimestamp: TDateTime;
      const ATimestampIsUTC: Boolean): TObjectId; overload; static;

    { Generates a new ObjectId using a given timestamp and the current machine,
      process and counter settings.

      Parameters:
        ATimestamp: 32-bit number of seconds since Unix epoch.

      Returns:
        The newly generated ObjectId.

      @bold(Note): the returned ObjectId is guaranteed to be unique on the
      current system, even if this function is called at the same time from
      the same or other processes on the machine. However, the ObjectId is not
      neccesarily globally unique since another machine with the same hostname
      or computer name can theoretically generate the same Id. }
    class function GenerateNewId(const ATimestamp: Integer): TObjectId; overload; static;

    { Parses an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.

      Returns:
        The ObjectId.

      Raises:
        EArgumentException if AString does not contain 24 hex digits }
    class function Parse(const AString: String): TObjectId; overload; static;

    { Tries to parse an ObjectId from its string representation (see ToString).

      Parameters:
        AString: the string representation of the ObjectId. Must contain 24
          hex digits.
        AObjectId: is set to the parsed ObjectId, or all zeros if AString could
          not be parsed.

      Returns:
        True if AString could be successfully parsed. }
    class function TryParse(const AString: String;
      out AObjectId: TObjectId): Boolean; overload; static;

    { Returns an empty ObjectId (with all zeros)

      Returns:
        The empty ObjectId. }
    class function Empty: TObjectId; static;

    { Implicitly converts a string to an ObjectId. The string @bold(must)
      contain 24 hex digits. An EArgumentException will be raised if this is not
      the case }
    class operator Implicit(const A: String): TObjectId;

    { Implicitly convers an ObjectId to a string }
    class operator Implicit(const A: TObjectId): String;

    { Tests 2 ObjectId's for equality }
    class operator Equal(const A, B: TObjectId): Boolean; //static;

    { Tests 2 ObjectId's for inequality }
    class operator NotEqual(const A, B: TObjectId): Boolean; //static;

    { Compares 2 ObjectId's using the ">" operator }
    class operator GreaterThan(const A, B: TObjectId): Boolean; //static;

    { Compares 2 ObjectId's using the ">=" operator }
    class operator GreaterThanOrEqual(const A, B: TObjectId): Boolean; //static;

    { Compares 2 ObjectId's using the "<" operator }
    class operator LessThan(const A, B: TObjectId): Boolean; //static;

    { Compares 2 ObjectId's using the "<=" operator }
    class operator LessThanOrEqual(const A, B: TObjectId): Boolean; //static;

    { Converts the ObjectId to an array of 12 bytes.

      Returns:
        The ObjectId as 12 bytes. }
    function ToByteArray: TBytes; overload;

    { Converts the ObjectId to an array of bytes.

      Parameters:
        ADestination: byte array to store the ObjectId into.
        AOffset: starting offset in ADestination to use.

      Raises:
        EArgumentException if ADestination does not have room enough to store
        (AOffset+12) bytes. }
    procedure ToByteArray(const ADestination: TBytes; const AOffset: Integer); overload;

    { Converts the ObjectId to its string representation. This is a string
      containing 24 hex digits.

      Returns:
        The string representation of the ObjectId. }
    function ToString: String;

    { Compare this ObjectId to another one.

      Parameters:
        AOther: the other ObjectId.

      Returns:
        * -1 if Self < AOther
        * 0 if Self = AOther
        * 1 if Self > AOther }
    function CompareTo(const AOther: TObjectId): Integer;

    { Returns True if this ObjectId is empty (all zeros) }
    property IsEmpty: Boolean read GetIsEmpty;

    { Timestamp component of the ObjectId.
      If the 32-bit number of seconds since Unix epoch. }
    property Timestamp: Integer read GetTimestamp;

    { Machine component of the ObjectId.
      Is a 24-bit machine identifier. }
    property Machine: Integer read GetMachine;

    { Process component of the ObjectId.
      Is a 16-bit process identifier. }
    property Pid: UInt16 read GetPid;

    { Counter component of the ObjectId.
      Is a 32-bit increment. }
    property Increment: Integer read GetIncrement;

    { The creation time of the ObjectId, as stored inside its Timestamp
      component. The time is in UTC. }
    property CreationTime: TDateTime read GetCreationTime;
  {$REGION 'Internal Declarations'}
  private
    case Byte of
      0: (FData: array [0..2] of UInt32);
      1: (FBytes: array [0..11] of Byte);
  {$ENDREGION 'Internal Declarations'}
  end;
  PgoObjectId = ^TObjectId;

type
  { The base "class" for all BSON values. It is implemented as a record type
    which can hold any type of BSON value. }
  TBsonValue = record
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IValue = interface
    ['{290B24D7-1D64-4F76-93C8-1B9D92658018}']
      function GetBsonType: TBsonType;
      function AsBoolean: Boolean;
      function AsInteger: Integer;
      function AsInt64: Int64;
      function AsDouble: Double;
      function AsString: String;
      function AsArray: TArray<TBsonValue>;
      function AsByteArray: TBytes;
      function AsGuid: TGUID;
      function AsObjectId: TObjectId;

      function ToBoolean(const ADefault: Boolean): Boolean;
      function ToDouble(const ADefault: Double): Double;
      function ToInteger(const ADefault: Integer): Integer;
      function ToInt64(const ADefault: Int64): Int64;
      function ToString(const ADefault: String): String;
      function ToLocalTime: TDateTime;
      function ToUniversalTime: TDateTime;
      function ToByteArray: TBytes;
      function ToGuid: TGUID;
      function ToObjectId: TObjectId;

      function Equals(const AOther: _IValue): Boolean;

      function Clone: _IValue;
      function DeepClone: _IValue;

      property BsonType: TBsonType read GetBsonType;
    end;
  private
    FImpl: _IValue;
    function GetBsonType: TBsonType; inline;
    function GetIsBoolean: Boolean; inline;
    function GetIsBsonArray: Boolean; inline;
    function GetIsBsonBinaryData: Boolean; inline;
    function GetIsBsonDateTime: Boolean; inline;
    function GetIsBsonDocument: Boolean; inline;
    function GetIsBsonJavaScript: Boolean; inline;
    function GetIsBsonJavaScriptWithScope: Boolean; inline;
    function GetIsBsonMaxKey: Boolean; inline;
    function GetIsBsonMinKey: Boolean; inline;
    function GetIsBsonNull: Boolean; inline;
    function GetIsBsonRegularExpression: Boolean; inline;
    function GetIsBsonSymbol: Boolean; inline;
    function GetIsBsonTimestamp: Boolean; inline;
    function GetIsBsonUndefined: Boolean; inline;
    function GetIsDateTime: Boolean; inline;
    function GetIsDouble: Boolean; inline;
    function GetIsGuid: Boolean; inline;
    function GetIsInt32: Boolean; inline;
    function GetIsInt64: Boolean; inline;
    function GetIsNumeric: Boolean; inline;
    function GetIsObjectId: Boolean; inline;
    function GetIsString: Boolean; inline;
  public
    { @exclude }
    class operator Implicit(const A: TBsonValue): Int8; //static;
    { @exclude }
    class operator Implicit(const A: TBsonValue): UInt8; //static;
    { @exclude }
    class operator Implicit(const A: TBsonValue): Int16; //static;
    { @exclude }
    class operator Implicit(const A: TBsonValue): UInt16; //static;
    { @exclude }
    class operator Implicit(const A: TBsonValue): UInt32; //static;
    { @exclude }
    class operator Implicit(const A: TBsonValue): Single; //static;

    { @exclude }
    class operator Implicit(const A: UInt32): TBsonValue; //static;
    { @exclude }
    class operator Implicit(const A: UInt64): TBsonValue; //static;
    { @exclude }
    class operator Implicit(const A: Single): TBsonValue; //static;

    { @exclude }
    property _Impl: _IValue read FImpl write FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON value by paring a JSON string.

      Parameters:
        AJson: the JSON string to parse.

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function Parse(const AJson: String): TBsonValue; static;

    { Tries to parse a JSON string to a BSON value.

      Parameters:
        AJson: the JSON string to parse.
        AArray: is set to the parsed JSON on success.

      Returns:
        True if the JSON string could be successfully parsed. }
    class function TryParse(const AJson: String; out AValue: TBsonValue): Boolean; static;

    { Creates a BSON value from a BSON byte array.

      Parameters:
        ABson: the BSON byte array to load.

      Returns:
        The BSON value

      Raises:
        EInvalidOperation if BSON data is invalid }
    class function Load(const ABson: TBytes): TBsonValue; static;

    { Tries to load a BSON value from a BSON byte array.

      Parameters:
        ABson: the BSON byte array to load.
        AValue: is set to the loaded BSON on success.

      Returns:
        True if the BSON value could be successfully loaded. }
    class function TryLoad(const ABson: TBytes; out AValue: TBsonValue): Boolean; static;

    { Loads a BSON value from a JSON file.

      Parameters:
        AFilename: the name of the JSON file

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function LoadFromJsonFile(const AFilename: String): TBsonValue; static;

    { Loads a BSON value from a JSON stream.

      Parameters:
        AStream: the JSON stream

      Returns:
        The BSON value

      Raises:
        EgoJsonParserError or EInvalidOperation on parse errors }
    class function LoadFromJsonStream(const AStream: TStream): TBsonValue; static;

    { Loads a BSON value from a BSON file.

      Parameters:
        AFilename: the name of the BSON file

      Returns:
        The BSON value

      Raises:
        EInvalidOperation when the BSON file is invalid }
    class function LoadFromBsonFile(const AFilename: String): TBsonValue; static;

    { Loads a BSON value from a BSON stream.

      Parameters:
        AStream: the BSON stream

      Returns:
        The BSON value

      Raises:
        EInvalidOperation when the BSON file is invalid }
    class function LoadFromBsonStream(const AStream: TStream): TBsonValue; static;

    { Saves the BSON value to a JSON file.

      Parameters:
        AFilename: the name of the JSON file. }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { Saves the BSON value to a JSON file, using specified settings.

      Parameters:
        AFilename: the name of the JSON file.
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode. }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TJsonWriterSettings); overload;

    { Saves the BSON value to a JSON stream.

      Parameters:
        AStream: the JSON stream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { Saves the BSON value to a JSON stream.

      Parameters:
        AStream: the JSON stream
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode. }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TJsonWriterSettings); overload;

    { Saves the BSON value to a BSON file.

      Parameters:
        AFilename: the name of the BSON file. }
    procedure SaveToBsonFile(const AFilename: String);

    { Saves the BSON value to a BSON stream.

      Parameters:
        AStream: the BSON stream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly converts a Boolean to a BSON value }
    class operator Implicit(const A: Boolean): TBsonValue; //static;

    { Implicitly converts an Integer to a BSON value }
    class operator Implicit(const A: Integer): TBsonValue; //static;

    { Implicitly converts an Int64 to a BSON value }
    class operator Implicit(const A: Int64): TBsonValue; //static;

    { Implicitly converts a Double to a BSON value }
    class operator Implicit(const A: Double): TBsonValue; //static;

    { Implicitly converts an Extended to a BSON value }
    class operator Implicit(const A: Extended): TBsonValue; //static;

    { Implicitly converts a TDateTime a BSON value of type TBsonDateTime.
      The TDateTime value @bold(must) be UTC format. }
    class operator Implicit(const A: TDateTime): TBsonValue; //static;

    { Implicitly converts a String to a BSON value }
    class operator Implicit(const A: String): TBsonValue; //static;

    { Implicitly converts an array of bytes to a BSON value of type
      TBsonBinaryData with sub type Binary. }
    class operator Implicit(const A: TBytes): TBsonValue; //static;

    { Implicitly converts a GUID to a BSON value of type TBsonBinaryData with
      sub type UuidStandard. }
    class operator Implicit(const A: TGUID): TBsonValue; //static;

    { Implicitly converts an ObjectId to a BSON value }
    class operator Implicit(const A: TObjectId): TBsonValue; //static;

    { Tries to implicitly convert a BSON value to a Boolean.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: the value
      * Double: True if the value isn't 0 or NaN
      * Integer: True if the value isn't 0
      * Null: False
      * String: True if the value isn't an empty string
      * Otherwise: True }
    class operator Implicit(const A: TBsonValue): Boolean; //static;

    { Tries to implicitly convert a BSON value to an Integer.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to Integer, if possible
      * Otherwise: 0 }
    class operator Implicit(const A: TBsonValue): Integer; //static;

    { Tries to implicitly convert a BSON value to an Int64.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to Int64, if possible
      * Otherwise: 0 }
    class operator Implicit(const A: TBsonValue): Int64; //static;

    { Tries to implicitly convert a BSON value to an UInt64.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: truncated value
      * Integer: the value
      * String: String converted to UInt64, if possible
      * Otherwise: 0 }
    class operator Implicit(const A: TBsonValue): UInt64; //static;

    { Tries to implicitly convert a BSON value to an Double.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: the value
      * Integer: the value
      * String: String (in US format) converted to Double, if possible
      * Otherwise: 0 }
    class operator Implicit(const A: TBsonValue): Double; //static;

    { Tries to implicitly convert a BSON value to an Extended.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 0 if False, 1 if True
      * Double: the value
      * Integer: the value
      * String: String (in US format) converted to Double, if possible
      * Otherwise: 0 }
    class operator Implicit(const A: TBsonValue): Extended; //static;

    { Tries to implicitly convert a BSON value to a TDateTime in UTC format.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in UTC format
      * Otherwise: 0

      @bold(Note): see ToLocalTime and ToUniversalTime for more control over
      the output. }
    class operator Implicit(const A: TBsonValue): TDateTime; //static;

    { Tries to implicitly convert a BSON value to a String.
      Depending on the BsonType, one of the following will be returned:
      * Boolean: 'false' or 'true'
      * Double: the value converted to a String (in US format)
      * Integer: the value converted to an Integer
      * String: the value
      * DateTime: UTC value in ISO8601 format
      * ObjectId: string representation of the ObjectId
      * Null: 'null'
      * Undefined: 'undefined'
      * MinKey: 'MinKey'
      * MaxKey: 'MaxKey'
      * Symbol: name of the symbol
      * Otherwise: '' (empty string) }
    class operator Implicit(const A: TBsonValue): String; //static;

    { Tries to implicitly convert a BSON value to a byte array.
      Depending on the BsonType, one of the following will be returned:
      * Binary: the value
      * Otherwise: nil (empty array) }
    class operator Implicit(const A: TBsonValue): TBytes; //static;

    { Tries to implicitly convert a BSON value to a GUID.
      Depending on the BsonType, one of the following will be returned:
      * Binary of sub type UuidLegacy or UuidStandard: the value
      * Otherwise: TGUID.Empty }
    class operator Implicit(const A: TBsonValue): TGUID; //static;

    { Tries to implicitly convert a BSON value to an ObjectId.
      Depending on the BsonType, one of the following will be returned:
      * ObjectId: the value
      * Otherwise: TObjectId.Empty }
    class operator Implicit(const A: TBsonValue): TObjectId; //static;

    { Tries to implicitly convert a BSON value to a TDateTime in local time.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in local time
      * Otherwise: 0 }
    function ToLocalTime: TDateTime; inline;

    { Tries to implicitly convert a BSON value to a TDateTime in universal time.
      Depending on the BsonType, one of the following will be returned:
      * DateTime: the value in universal time (UTC)
      * Otherwise: 0 }
    function ToUniversalTime: TDateTime; inline;

    { Tests 2 BSON values for equality. BSON values are equal if their types
      and contents match exactly. }
    class operator Equal(const A, B: TBsonValue): Boolean; //static;

    { Tests 2 BSON values for inequality }
    class operator NotEqual(const A, B: TBsonValue): Boolean; //static;

    { Checks if the BSON value has been assigned.

      Returns:
        True if value hasn't been assigned yet.

      @bold(Note): does @bold(not) return True if the value is a NULL value
      (see IsBsonNull/AsBsonNull) }
    function IsNil: Boolean; inline;

    { Unassigns the BSON value (like setting an object to nil).
      IsNil will return True afterwards. }
    procedure SetNil; inline;

    { Tries to convert the value to a Boolean.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to False. }
    function ToBoolean(const ADefault: Boolean = False): Boolean; inline;

    { Tries to convert the value to a 32-bit integer.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0. }
    function ToInteger(const ADefault: Integer = 0): Integer; inline;

    { Tries to convert the value to a 64-bit integer.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0. }
    function ToInt64(const ADefault: Int64 = 0): Int64; inline;

    { Tries to convert the value to a floating-point number.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to 0.0. }
    function ToDouble(const ADefault: Double = 0): Double; inline;

    { Tries to convert the value to a string.

      Parameters:
        ADefault: (optional) value to return if value cannot be converted.
          Defaults to ''. }
    function ToString(const ADefault: String = ''): String; inline;

    { Tries to convert the value to a GUID.
      Returns an empty GUID if the value cannot be converted. }
    function ToGuid: TGUID; inline;

    { Tries to convert the value to an ObjectId.
      Returns an empty ObjectId if the value cannot be converted. }
    function ToObjectId: TObjectId; inline;

    { Returns the value as a Boolean.

      Raises:
        EIntfCastError if this value isn't a Boolean }
    function AsBoolean: Boolean; inline;

    { Returns the value as a 32-bit integer.

      Raises:
        EIntfCastError if this value isn't a 32-bit integer }
    function AsInteger: Integer; inline;

    { Returns the value as a 64-bit integer.

      Raises:
        EIntfCastError if this value isn't a 64-bit integer }
    function AsInt64: Int64; inline;

    { Returns the value as a Double.

      Raises:
        EIntfCastError if this value isn't a Double }
    function AsDouble: Double; inline;

    { Returns the value as a String.

      Raises:
        EIntfCastError if this value isn't a String }
    function AsString: String; inline;

    { Returns the value as a Delphi array of BSON values.

      Raises:
        EIntfCastError if this value isn't a BSON array }
    function AsArray: TArray<TBsonValue>; inline;

    { Returns the value as an array of bytes.

      Raises:
        EIntfCastError if this value isn't a Binary value }
    function AsByteArray: TBytes; inline;

    { Returns the value as a GUID.

      Raises:
        EIntfCastError if this value isn't a Binary value of sub type
        UuidLegacy or UuidStandard. }
    function AsGuid: TGUID; inline;

    { Returns the value as an ObjectId.

      Raises:
        EIntfCastError if this value isn't an ObjectId }
    function AsObjectId: TObjectId; inline;

    { Creates shallow clone of the value.

      Returns:
        The shallow clone

      @bold(Note): a shallow clone copies the value, but not any sub-values.
      For example, if the value is an array, then the array reference is copied,
      but not the individual elements. }
    function Clone: TBsonValue; inline;

    { Creates deep clone of the value.

      Returns:
        The deep clone

      @bold(Note): a deep clone copies the value and any sub-values it may hold.
      For example, if the value is an array, then the array reference is copied,
      and its individual elements are copied as well. Any sub-values of those
      elements are also copied, etc... }
    function DeepClone: TBsonValue; inline;

    { Saves the value to a BSON-compliant byte stream.

      Returns:
        The BSON byte stream. }
    function ToBson: TBytes; inline;

    { Saves the value to a string in JSON format.

      Returns:
        The value in JSON format.

      @bold(Note): the value is saved using the default writer settings. That
      is, without any pretty printing, and in Strict mode. Use the other overload
      of this function to specify output settings. }
    function ToJson: String; overload; inline;

    { Saves the value to a string in JSON format, using specified settings.

      Parameters:
        ASettings: the output settings to use, such as pretty-printing and
          Strict vs Shell mode.

      Returns:
        The value in JSON format. }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The type of this value. }
    property BsonType: TBsonType read GetBsonType;

    { Whether this value represents a Boolean. }
    property IsBoolean: Boolean read GetIsBoolean;

    { Whether this value represents a BSON array. }
    property IsBsonArray: Boolean read GetIsBsonArray;

    { Whether this value represents a BSON binary value. }
    property IsBsonBinaryData: Boolean read GetIsBsonBinaryData;

    { Whether this value represents a BSON DateTime. }
    property IsBsonDateTime: Boolean read GetIsBsonDateTime;

    { Whether this value represents a BSON Document (aka Dictionary or Object). }
    property IsBsonDocument: Boolean read GetIsBsonDocument;

    { Whether this value represents a JavaScript script. }
    property IsBsonJavaScript: Boolean read GetIsBsonJavaScript;

    { Whether this value represents a JavaScript script with scope. }
    property IsBsonJavaScriptWithScope: Boolean read GetIsBsonJavaScriptWithScope;

    { Whether this value represents a BSON MaxKey value. }
    property IsBsonMaxKey: Boolean read GetIsBsonMaxKey;

    { Whether this value represents a BSON MinKey value. }
    property IsBsonMinKey: Boolean read GetIsBsonMinKey;

    { Whether this value represents a BSON Null value. }
    property IsBsonNull: Boolean read GetIsBsonNull;

    { Whether this value represents a regular expression. }
    property IsBsonRegularExpression: Boolean read GetIsBsonRegularExpression;

    { Whether this value represents a (deprectated) BSON symbol. }
    property IsBsonSymbol: Boolean read GetIsBsonSymbol;

    { Whether this value represents a BSON timestamp. }
    property IsBsonTimestamp: Boolean read GetIsBsonTimestamp;

    { Whether this value represents a BSON Undefined value. }
    property IsBsonUndefined: Boolean read GetIsBsonUndefined;

    { Whether this value represents a DateTime value. }
    property IsDateTime: Boolean read GetIsDateTime;

    { Whether this value represents a Double. }
    property IsDouble: Boolean read GetIsDouble;

    { Whether this value represents a GUID. }
    property IsGuid: Boolean read GetIsGuid;

    { Whether this value represents a 32-bit integer. }
    property IsInt32: Boolean read GetIsInt32;

    { Whether this value represents a 64-bit integer. }
    property IsInt64: Boolean read GetIsInt64;

    { Whether this value represents a numeric value (Integer or Double). }
    property IsNumeric: Boolean read GetIsNumeric;

    { Whether this value represents an ObjectId. }
    property IsObjectId: Boolean read GetIsObjectId;

    { Whether this value represents a String. }
    property IsString: Boolean read GetIsString;
  end;

type
  { An array of other BSON values }
  TBsonArray = record
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IArray = interface(TBsonValue._IValue)
    ['{968AA4B3-4569-4676-B85D-0DF953DC6D26}']
      function GetCount: Integer;
      procedure GetItem(const AIndex: Integer; out AValue: TBsonValue._IValue);
      procedure SetItem(const AIndex: Integer; const AValue: TBsonValue._IValue);

      procedure Add(const AValue: TBsonValue._IValue);
      procedure AddRange(const AValues: array of TBsonValue); overload;
      procedure AddRange(const AValues: TArray<TBsonValue>); overload;
      procedure AddRange(const AValues: TBsonArray); overload;
      procedure Delete(const AIndex: Integer);
      function Remove(const AValue: TBsonValue): Boolean;
      procedure Clear;
      function Contains(const AValue: TBsonValue): Boolean;
      function IndexOf(const AValue: TBsonValue): Integer;

      property Count: Integer read GetCount;
    end;
  private type
    TEnumerator = record
    private
      FImpl: _IArray;
      FIndex: Integer;
      FHigh: Integer;
      function GetCurrent: TBsonValue;
    public
      constructor Create(const AImpl: _IArray);
      function MoveNext: Boolean;

      property Current: TBsonValue read GetCurrent;
    end;
  private
    FImpl: _IArray;
    function GetCount: Integer; inline;
    function GetItem(const AIndex: Integer): TBsonValue; inline;
    procedure SetItem(const AIndex: Integer; const AValue: TBsonValue); inline;
  public
    { @exclude }
    property _Impl: _IArray read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON array.

      Parameters:
        ACapacity: (optional) initial capacity of the array. You can reduce
          memory reallocations if you know in advance the (approximate) number
          of values the array is going to hold.

      Returns:
        The empty BSON array }
    class function Create(const ACapacity: Integer = 0): TBsonArray; overload; static;

    { Creates a BSON array an populates it with a Delphi array of values.

      Parameters:
        AValues: the Delphi array of values to populate the BSON array with.

      Returns:
        The BSON array

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    class function Create(const AValues: array of TBsonValue): TBsonArray; overload; static;

    { Creates a BSON array an populates it with a Delphi array of values.

      Parameters:
        AValues: the Delphi array of values to populate the BSON array with.

      Returns:
        The BSON array

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    class function Create(const AValues: TArray<TBsonValue>): TBsonArray; overload; static;

    { See TBsonValue.Parse }
    class function Parse(const AJson: String): TBsonArray; static;

    { See TBsonValue.TryParse }
    class function TryParse(const AJson: String; out AArray: TBsonArray): Boolean; static;

    { See TBsonValue.Load }
    class function Load(const ABson: TBytes): TBsonArray; static;

    { See TBsonValue.TryLoad }
    class function TryLoad(const ABson: TBytes; out AArray: TBsonArray): Boolean; static;

    { See TBsonValue.LoadFromJsonFile }
    class function LoadFromJsonFile(const AFilename: String): TBsonArray; static;

    { See TBsonValue.LoadFromJsonStream }
    class function LoadFromJsonStream(const AStream: TStream): TBsonArray; static;

    { See TBsonValue.LoadFromBsonFile }
    class function LoadFromBsonFile(const AFilename: String): TBsonArray; static;

    { See TBsonValue.LoadFromBsonStream }
    class function LoadFromBsonStream(const AStream: TStream): TBsonArray; static;

    { See TBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { See TBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TJsonWriterSettings); overload;

    { See TBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { See TBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TJsonWriterSettings); overload;

    { See TBsonValue.SaveToBsonFile }
    procedure SaveToBsonFile(const AFilename: String);

    { See TBsonValue.SaveToBsonStream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly casts a BSON array to a BSON value. }
    class operator Implicit(const A: TBsonArray): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonArray): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonArray): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonArray; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonArray; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { Adds a value to the array.

      Parameters:
        AValue: the value to add.

      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True). }
    function Add(const AValue: TBsonValue): TBsonArray; inline;

    { Adds a range of values to the array.

      Parameters:
        AValues: the Delphi array of values to add to the array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    function AddRange(const AValues: array of TBsonValue): TBsonArray; overload;

    { Adds a range of values to the array.

      Parameters:
        AValues: the Delphi array of values to add to the array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if any of the values in the array has not been
        assigned (if their IsNil returns True for those). }
    function AddRange(const AValues: TArray<TBsonValue>): TBsonArray; overload; inline;

    { Adds a range of values from another BSON array to this array.

      Parameters:
        AValues: the BSON array of values to add to this array.


      Returns:
        The array itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValues has not been assigned or any of the
        values in the array has not been assigned (if their IsNil returns True
        for those). }
    function AddRange(const AValues: TBsonArray): TBsonArray; overload; inline;

    { Deletes a value from the array by index.

      Parameters:
        AIndex: the index of the value to delete.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    procedure Delete(const AIndex: Integer); inline;

    { Removes a value from the array.

      Parameters:
        AValue: the value to remove.

      Returns:
        True if the value was removed. False if the array does not contain the
        value.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True).

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function Remove(const AValue: TBsonValue): Boolean; inline;

    { Clears the array.

      Returns:
        The array itself, so you can use it for chaining. }
    function Clear: TBsonArray; inline;

    { Checks if the array contains a given value.

      Parameters:
        AValue: the value to look for.

      Returns:
        True if the array contains the value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function Contains(const AValue: TBsonValue): Boolean; inline;

    { Returns the index of a value in the array.

      Parameters:
        AValue: the value to look for.

      Returns:
        The index of the value in the array, or -1 if the array does not contain
        the value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the array. }
    function IndexOf(const AValue: TBsonValue): Integer; inline;

    { Returns the values in the array as a Delphi array of values.

      Returns:
        The Delphi array of BSON values }
    function ToArray: TArray<TBsonValue>; inline;

    { Allow <tt>for..in</tt> enumeration of the values in the array. }
    function GetEnumerator: TEnumerator; inline;

    { Number of items in the array }
    property Count: Integer read GetCount;

    { The items in the array.

      Parameters:
        AIndex: the index of the item to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds.
        EArgumentNilException when setting the item and AValue is not assigned
        (IsNil returns True) }
    property Items[const AIndex: Integer]: TBsonValue read GetItem write SetItem; default;
  end;

type
  { An element in a TBsonDocument }
  TBsonElement = record
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    FImpl: TBsonValue._IValue;
    function GetValue: TBsonValue; inline;
  public
    { @exclude }
    property _Impl: TBsonValue._IValue read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a document element.

      Parameters:
        AName: the name of the element.
        AValue: the value of the element.

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True). }
    class function Create(const AName: String; const AValue: TBsonValue): TBsonElement; static;

    { Tests 2 document elements for equality. Elements are equal if both their
      names (case-sensitive) and values are equal. }
    class operator Equal(const A, B: TBsonElement): Boolean; //static;

    { Tests 2 document elements for inequality. }
    class operator NotEqual(const A, B: TBsonElement): Boolean; inline; static;

    { Creates a shallow clone of the element. The returned element will contain
      a reference to the existing value.

      Returns:
        The clone }
    function Clone: TBsonElement;

    { Creates a deep clone of the element. The returned element will contain
      a deep clone of the existing value.

      Returns:
        The deep clone }
    function DeepClone: TBsonElement;

    { Name of the element }
    property Name: String read FName;

    { Value of the element }
    property Value: TBsonValue read GetValue;
  end;

type
  { A BSON document. A BSON document contains key/value pairs, where the key is
    a String and the value can be any BSON value. It is similar to a Delphi
    dictionary or a JSON object. However, unlike Delphi dictionaries, a
    documents maintains insertion order and you can access values both by name
    and by index. }
  TBsonDocument = record
  {$REGION 'Internal Declarations'}
  public type
    { @exclude }
    _IDocument = interface(TBsonValue._IValue)
    ['{9E13B024-904D-44F6-BE16-33D81A0F057F}']
      function GetCount: Integer;
      function GetAllowDuplicateNames: Boolean;
      procedure SetAllowDuplicateNames(const Value: Boolean);
      function GetElement(const AIndex: Integer): TBsonElement;
      procedure GetValue(const AIndex: Integer; out AValue: TBsonValue._IValue);
      procedure SetValue(const AIndex: Integer; const AValue: TBsonValue._IValue);
      procedure GetValueByName(const AName: String; out AValue: TBsonValue._IValue);
      procedure SetValueByName(const AName: String; const AValue: TBsonValue._IValue);

      procedure Add(const AName: String; const AValue: TBsonValue._IValue);
      procedure Get(const AName: String; const ADefault: TBsonValue._IValue;
        out AValue: TBsonValue._IValue);
      function IndexOfName(const AName: String): Integer;
      function Contains(const AName: String): Boolean;
      function ContainsValue(const AValue: TBsonValue): Boolean;
      function TryGetElement(const AName: String; out AElement: TBsonElement): Boolean;
      function TryGetValue(const AName: String; out AValue: TBsonValue._IValue): Boolean;
      procedure Remove(const AName: String);
      procedure Delete(const AIndex: Integer);
      procedure Clear;
      procedure Merge(const AOtherDocument: TBsonDocument;
        const AOverwriteExistingElements: Boolean);
      function ToArray: TArray<TBsonElement>;

      property AllowDuplicateNames: Boolean read GetAllowDuplicateNames write SetAllowDuplicateNames;
      property Count: Integer read GetCount;
      property Elements[const AIndex: Integer]: TBsonElement read GetElement;
    end;
  private type
    TEnumerator = record
    private
      FImpl: _IDocument;
      FIndex: Integer;
      FHigh: Integer;
      function GetCurrent: TBsonElement;
    public
      constructor Create(const AImpl: _IDocument);
      function MoveNext: Boolean;

      property Current: TBsonElement read GetCurrent;
    end;
  private
    FImpl: _IDocument;
    function GetCount: Integer; inline;
    function GetElement(const AIndex: Integer): TBsonElement; inline;
    function GetValue(const AIndex: Integer): TBsonValue; inline;
    procedure SetValue(const AIndex: Integer; const AValue: TBsonValue); inline;
    function GetValueByName(const AName: String): TBsonValue; inline;
    procedure SetValueByName(const AName: String; const AValue: TBsonValue); inline;
    function GetAllowDuplicateNames: Boolean; inline;
    procedure SetAllowDuplicateNames(const AValue: Boolean); inline;
  public
    { @exclude }
    property _Impl: _IDocument read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON document.

      Returns:
        The empty BSON document }
    class function Create: TBsonDocument; overload; static;

    { Creates an empty BSON document.

      Parameters:
        AAllowDuplicateNames: whether to allow duplicate names in the document.
          This should generally be False.

      Returns:
        The empty BSON document }
    class function Create(const AAllowDuplicateNames: Boolean): TBsonDocument; overload; static;

    { Creates a BSON document with a single element.

      Parameters:
        AElement: the element to add to the document.

      Returns:
        The BSON document

      Raises:
        EArgumentNilException if AElement.Value has not been assigned (if IsNil
        returns True) }
    class function Create(const AElement: TBsonElement): TBsonDocument; overload; static;

    { Creates a BSON document with a single element.

      Parameters:
        AName: the name of the element to add to the document.
        AValue: the value of the element.

      Returns:
        The BSON document

      Raises:
        EArgumentNilException if AValue has not been assigned (if IsNil returns
        True) }
    class function Create(const AName: String; const AValue: TBsonValue): TBsonDocument; overload; static;

    { See TBsonValue.Parse }
    class function Parse(const AJson: String; AllowDuplicateNames : Boolean = false): TBsonDocument; static;

    { See TBsonValue.TryParse }
    class function TryParse(const AJson: String; out ADocument: TBsonDocument; AllowDuplicateNames : Boolean = false): Boolean; static;

    { See TBsonValue.Load }
    class function Load(const ABson: TBytes): TBsonDocument; static;

    { See TBsonValue.TryLoad }
    class function TryLoad(const ABson: TBytes; out ADocument: TBsonDocument): Boolean; static;

    { See TBsonValue.LoadFromJsonFile }
    class function LoadFromJsonFile(const AFilename: String): TBsonDocument; static;

    { See TBsonValue.LoadFromJsonStream }
    class function LoadFromJsonStream(const AStream: TStream): TBsonDocument; static;

    { See TBsonValue.LoadFromBsonFile }
    class function LoadFromBsonFile(const AFilename: String): TBsonDocument; static;

    { See TBsonValue.LoadFromBsonStream }
    class function LoadFromBsonStream(const AStream: TStream): TBsonDocument; static;

    { See TBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String); overload;

    { See TBsonValue.SaveToJsonFile }
    procedure SaveToJsonFile(const AFilename: String;
      const ASettings: TJsonWriterSettings); overload;

    { See TBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream); overload;

    { See TBsonValue.SaveToJsonStream }
    procedure SaveToJsonStream(const AStream: TStream;
      const ASettings: TJsonWriterSettings); overload;

    { See TBsonValue.SaveToBsonFile }
    procedure SaveToBsonFile(const AFilename: String);

    { See TBsonValue.SaveToBsonStream }
    procedure SaveToBsonStream(const AStream: TStream);

    { Implicitly casts a BSON document to a BSON value. }
    class operator Implicit(const A: TBsonDocument): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonDocument): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonDocument): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonDocument; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonDocument; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { Adds an element to the document.

      Parameters:
        AName: the name of the element to add to the document.
        AValue: the value of the element.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AValue has not been assigned (IsNil returns
          True).
        EInvalidOperation if AllowDuplicateNames = False and document already
          contains element with given name.

      @bold(Note): Names are case-sensitive }
    function Add(const AName: String; const AValue: TBsonValue): TBsonDocument; overload; inline;

    { Adds an element to the document.

      Parameters:
        AElement: the element to add to the document.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AElement.Value has not been assigned (IsNil
          returns True).
        EInvalidOperation if AllowDuplicateNames = False and document already
          contains element with given name.

      @bold(Note): Names are case-sensitive }
    function Add(const AElement: TBsonElement): TBsonDocument; overload; inline;

    { Gets a value from the document by name, or a default value if the document
      does not contain an element with the given name.

      Parameters:
        AName: the name of the value to get.
        ADefault: the default value to return in case the document does not
          contain an element named AName.

      Returns:
        The value associated with AName, or ADefault in case the document does
        not contain an element named AName. }
    function Get(const AName: String; const ADefault: TBsonValue): TBsonValue;

    { Returns the index of the element with a given name.

      Parameters:
        AName: the name of the element to find.

      Returns:
        The index of the element, or -1 of the document does not contain an
        element with the given name.

      @bold(Note): Names are case-sensitive }
    function IndexOfName(const AName: String): Integer; inline;

    { Checks whether the document contains an element with a given name.

      Parameters:
        AName: the name of the element to find.

      Returns:
        True if the document contains an element with the given name.

      @bold(Note): Names are case-sensitive }
    function Contains(const AName: String): Boolean; inline;

    { Checks whether the document contains an element with a given value.

      Parameters:
        AValue: the value of the element to find.

      Returns:
        True if the document contains an element with the given value.

      @bold(Note): the Equal operator of AValue is used to check if the value
      is in the document. }
    function ContainsValue(const AValue: TBsonValue): Boolean; inline;

    { Tries to retrieve an element by name.

      Parameters:
        AName: the name of the element to find.
        AELement: is set to the corresponding element if found.

      Returns:
        True if the document contains an element with the given name. }
    function TryGetElement(const AName: String; out AElement: TBsonElement): Boolean; inline;

    { Tries to retrieve a value by name.

      Parameters:
        AName: the name of the value to find.
        AValue: is set to the corresponding value if found.

      Returns:
        True if the document contains an element with the given name. }
    function TryGetValue(const AName: String; out AValue: TBsonValue): Boolean; inline;

    { Removes an element by name.

      Parameters:
        AName: the name of the element to remove.

      @bold(Note):
        In case AllowDuplicateNames = True, then all elements with this name are
        removed. The method does nothing if the document does not contain an
        element with the given name. }
    procedure Remove(const AName: String); inline;

    { Deletes an element by index.

      Parameters:
        AIndex: the index of the element to delete.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    procedure Delete(const AIndex: Integer); inline;

    { Clears the document }
    procedure Clear; inline;

    { Merges another document into this one.

      Parameters:
        AOtherDocument: the other document to merge with this one.
        AOverwriteExistingElements: whether to overwrite existing element.

      Returns:
        The document itself, so you can use it for chaining.

      Raises:
        EArgumentNilException if AOtherDocument has not been assigned (IsNil
          returns True). }
    function Merge(const AOtherDocument: TBsonDocument;
      const AOverwriteExistingElements: Boolean): TBsonDocument;

    { Returns the elements in then document as an array.

      Returns:
        The array of elements }
    function ToArray: TArray<TBsonElement>; inline;

    { Allow <tt>for..in</tt> enumeration of the elements in the document. }
    function GetEnumerator: TEnumerator; inline;

    { Whether duplicate element names are allowed.
      Should generally be False (the default). }
    property AllowDuplicateNames: Boolean read GetAllowDuplicateNames write SetAllowDuplicateNames;

    { Number of elements in the document.
      Could be larger than the number of names in the document in case
      AllowDuplicateNames = True }
    property Count: Integer read GetCount;

    { The elements in the document by index.

      Parameters:
        AIndex: the index of the element to get.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    property Elements[const AIndex: Integer]: TBsonElement read GetElement;

    { The values in the document by index.

      Parameters:
        AIndex: the index of the value to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds.
        EArgumentNilException when setting the value and AValue is not assigned
        (IsNil returns True) }
    property Values[const AIndex: Integer]: TBsonValue read GetValue write SetValue;

    { The values in the document by name.

      Parameters:
        AName: the name of the value to get or set.

      Raises:
        EArgumentNilException when setting the value and AValue is not assigned
        (IsNil returns True)

      @bold(Note): when getting a value and the name is not found, a TBsonNull
      value is returned.

      @bold(Note): when setting a value, it will replace an existing value with
      the same name if found, or otherwise add it. }
    property ValuesByName[const AName: String]: TBsonValue read GetValueByName write SetValueByName; default;
  end;

type
  { A blob of binary data }
  TBsonBinaryData = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IBinaryData = interface(TBsonValue._IValue)
    ['{8C7D00D2-6C0F-444F-A4A8-79F366BBA9A1}']
      function GetSubType: TBsonBinarySubType;
      function GetCount: Integer;
      function GetByte(const AIndex: Integer): Byte;
      procedure SetByte(const AIndex: Integer; const AValue: Byte);
      function GetAsBytes: TBytes;

      property SubType: TBsonBinarySubType read GetSubType;
      property Count: Integer read GetCount;
      property Bytes[const AIndex: Integer]: Byte read GetByte write SetByte; default;
      property AsBytes: TBytes read GetAsBytes;
    end;
  private
    FImpl: _IBinaryData;
    function GetSubType: TBsonBinarySubType; inline;
    function GetCount: Integer; inline;
    function GetByte(const AIndex: Integer): Byte; inline;
    procedure SetByte(const AIndex: Integer; const AValue: Byte); inline;
    function GetAsBytes: TBytes; inline;
  public
    { @exclude }
    property _Impl: _IBinaryData read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an empty BSON binary.

      Returns:
        The empty BSON binary }
    class function Create: TBsonBinaryData; overload; static;

    { Creates a BSON binary from a byte array.

      Parameters:
        AData: the bytes to populate the binary with.

      Returns:
        The BSON binary }
    class function Create(const AData: TBytes): TBsonBinaryData; overload; static;

    { Creates a BSON binary from a byte array.

      Parameters:
        AData: the bytes to populate the binary with.
        ASubType: the type of binary data in AData.

      Returns:
        The BSON binary }
    class function Create(const AData: TBytes;
      const ASubType: TBsonBinarySubType): TBsonBinaryData; overload; static;

    { Implicitly casts a BSON binary to a BSON value. }
    class operator Implicit(const A: TBsonBinaryData): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonBinaryData): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonBinaryData): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonBinaryData; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonBinaryData; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The type of binary data this object contains }
    property SubType: TBsonBinarySubType read GetSubType;

    { Number of bytes in the binary data }
    property Count: Integer read GetCount;

    { The bytes in the binary data.

      Parameters:
        AIndex: the index of the byte to get or set.

      Raises:
        EArgumentOutOfRangeException in AIndex is out of bounds. }
    property Bytes[const AIndex: Integer]: Byte read GetByte write SetByte; default;

    { Returns the binary as a byte array }
    property AsBytes: TBytes read GetAsBytes;
  end;

type
  { Represents the BSON Null value }
  TBsonNull = record
  {$REGION 'Internal Declarations'}
  private type
    _INull = interface(TBsonValue._IValue)
    ['{112081EC-BB01-4974-948C-59CE64077420}']
    end;
  private class var
    FImpl: TBsonNull;
  private
    FValue: _INull;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    property _Value: _INull read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Null to a BSON value. }
    class operator Implicit(const A: TBsonNull): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonNull): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonNull): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonNull; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonNull; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The Null value singleton }
    class property Value: TBsonNull read FImpl;
  end;

type
  { Represents the BSON Undefined value }
  TBsonUndefined = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IUndefined = interface(TBsonValue._IValue)
    ['{7410572B-2559-4036-B79A-A6237C0B2679}']
    end;
  private class var
    FImpl: TBsonUndefined;
  private
    FValue: _IUndefined;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    property _Value: _IUndefined read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Undefined to a BSON value. }
    class operator Implicit(const A: TBsonUndefined): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonUndefined): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonUndefined): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonUndefined; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonUndefined; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The Undefined value singleton }
    class property Value: TBsonUndefined read FImpl;
  end;

type
  { A BSON DateTime value }
  TBsonDateTime = record
  {$REGION 'Internal Declarations'}
  private type
    _IDateTime = interface(TBsonValue._IValue)
      ['{87332312-C7B7-4E45-B778-569166ACA2D2}']
      function GetMillisecondsSinceEpoch: Int64;

      property MillisecondsSinceEpoch: Int64 read GetMillisecondsSinceEpoch;
    end;
  private
    FImpl: _IDateTime;
    function GetMillisecondsSinceEpoch: Int64; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON DateTime value from a Delphi DateTime value.

      Parameters:
        ADateTime: the (Delphi) date time value
        ADateTimeIsUTC: whether ADateTime is in universal time

      Returns:
        The BSON DateTime value }
    class function Create(const ADateTime: TDateTime; const ADateTimeIsUTC: Boolean): TBsonDateTime; overload; static;

    { Creates a BSON DateTime value.

      Parameters:
        AMillisecondsSinceEpoch: the number of milliseconds since the Unix epoch.

      Returns:
        The BSON DateTime value }
    class function Create(const AMillisecondsSinceEpoch: Int64): TBsonDateTime; overload; static;

    { Implicitly casts a BSON DateTime value to a BSON value. }
    class operator Implicit(const A: TBsonDateTime): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonDateTime): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonDateTime): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonDateTime; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonDateTime; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { Converts the DateTime value to a Delphi DateTime value in local time }
    function ToLocalTime: TDateTime; inline;

    { Converts the DateTime value to a Delphi DateTime value in universal time }
    function ToUniversalTime: TDateTime; inline;

    { The number of milliseconds since the Unix epoch }
    property MillisecondsSinceEpoch: Int64 read GetMillisecondsSinceEpoch;
  end;

type
  { A BSON Timestamp. Mostly used internally for MongoDB replication and
    sharding. }
  TBsonTimestamp = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _ITimestamp = interface(TBsonValue._IValue)
    ['{212644B0-BF5F-4F16-AF96-50437C404DCA}']
      function GetIncrement: Integer;
      function GetTimestamp: Integer;
      function GetValue: Int64;

      property Value: Int64 read GetValue;
      property Timestamp: Integer read GetTimestamp;
      property Increment: Integer read GetIncrement;
    end;
  private
    FImpl: _ITimestamp;
    function GetIncrement: Integer; inline;
    function GetTimestamp: Integer; inline;
    function GetValue: Int64; inline;
  public
    { @exclude }
    property _Impl: _ITimestamp read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Timestamp.

      Parameters:
        ATimestamp: the timestamp
        AIncrement: the increment

      Returns:
        The BSON Timestamp }
    class function Create(const ATimestamp, AIncrement: Integer): TBsonTimestamp; overload; static;

    { Creates a BSON Timestamp.

      Parameters:
        AValue: the combined timestamp/increment value

      Returns:
        The BSON Timestamp }
    class function Create(const AValue: Int64): TBsonTimestamp; overload; static;

    { Implicitly casts a BSON Timestamp to a BSON value. }
    class operator Implicit(const A: TBsonTimestamp): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonTimestamp): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonTimestamp): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonTimestamp; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonTimestamp; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The timestamp }
    property Timestamp: Integer read GetTimestamp;

    { The increment }
    property Increment: Integer read GetIncrement;

    { The combined timestamp/increment value }
    property Value: Int64 read GetValue;
  end;

type
  { A BSON Regular Expression }
  TBsonRegularExpression = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IRegularExpression = interface(TBsonValue._IValue)
    ['{C1283C00-6071-4DB7-82CD-5A53A00A7399}']
      function GetOptions: String;
      function GetPattern: String;

      property Pattern: String read GetPattern;
      property Options: String read GetOptions;
    end;
  private
    FImpl: _IRegularExpression;
    function GetOptions: String; inline;
    function GetPattern: String; inline;
  public
    { @exclude }
    property _Impl: _IRegularExpression read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON Regular Expression.

      Parameters:
        APattern: the regex pattern

      Returns:
        The BSON Regular Expression }
    class function Create(const APattern: String): TBsonRegularExpression; overload; static;

    { Creates a BSON Regular Expression.

      Parameters:
        APattern: the regex pattern
        AOptions: the regex options

      Returns:
        The BSON Regular Expression }
    class function Create(const APattern, AOptions: String): TBsonRegularExpression; overload; static;

    { Implicitly converts a regex pattern String to a BSON Regular Expression }
    class operator Implicit(const A: String): TBsonRegularExpression; //static;

    { Implicitly casts a BSON Regular Expression to a BSON value. }
    class operator Implicit(const A: TBsonRegularExpression): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonRegularExpression): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonRegularExpression): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonRegularExpression; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonRegularExpression; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The regex pattern }
    property Pattern: String read GetPattern;

    { The regex options }
    property Options: String read GetOptions;
  end;

type
  { A piece of JavaScript code }
  TBsonJavaScript = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IJavaScript = interface(TBsonValue._IValue)
    ['{8659A4B1-171B-4C44-BBFC-109E14DE27FC}']
      function GetCode: String;

      property Code: String read GetCode;
    end;
  private
    FImpl: _IJavaScript;
    function GetCode: String; inline;
  public
    { @exclude }
    property _Impl: _IJavaScript read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON JavaScript.

      Parameters:
        ACode: the JavaScript code.

      Returns:
        The BSON JavaScript }
    class function Create(const ACode: String): TBsonJavaScript; static;

    { Implicitly casts a BSON JavaScript to a BSON value. }
    class operator Implicit(const A: TBsonJavaScript): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonJavaScript): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonJavaScript): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonJavaScript; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonJavaScript; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The JavaScript code }
    property Code: String read GetCode;
  end;

type
  { A piece of JavaScript code with a scope (a set of variables with values, as
    defined in another document).}
  TBsonJavaScriptWithScope = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IJavaScriptWithScope = interface(TBsonJavaScript._IJavaScript)
    ['{17B4EFE0-6FEE-4972-A2E5-1CAC276649D4}']
      function GetScope: TBsonDocument;

      property Scope: TBsonDocument read GetScope;
    end;
  private
    FImpl: _IJavaScriptWithScope;
    function GetCode: String; inline;
    function GetScope: TBsonDocument; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a BSON JavaScript w/scope.

      Parameters:
        ACode: the JavaScript code.
        AScope: the scope document containing the variables with values.

      Returns:
        The BSON JavaScript w/scope

      Raises:
        EArgumentNilException if AScope has not been assigned (IsNil returns True) }
    class function Create(const ACode: String;
      const AScope: TBsonDocument): TBsonJavaScriptWithScope; static;

    { Implicitly casts a BSON JavaScript w/scope to a BSON value. }
    class operator Implicit(const A: TBsonJavaScriptWithScope): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonJavaScriptWithScope): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonJavaScriptWithScope): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonJavaScriptWithScope; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonJavaScriptWithScope; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The JavaScript code }
    property Code: String read GetCode;

    { The scope document containing the variables with values. }
    property Scope: TBsonDocument read GetScope;
  end;

type
  { A symbol from a lookup table (deprecated by BSON).
    You create symbols using TBsonSymbolTable.Lookup. }
  TBsonSymbol = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _ISymbol = interface(TBsonValue._IValue)
    ['{B63F0297-6A95-4A74-98DF-6E355E8E83B4}']
      function GetName: String;

      property Name: String read GetName;
    end;
  private
    FImpl: _ISymbol;
    function GetName: String; inline;
  public
    { @exclude }
    property _Impl: _ISymbol read FImpl;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON Symbol to a BSON value. }
    class operator Implicit(const A: TBsonSymbol): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonSymbol): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonSymbol): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.SetNil }
    procedure SetNil; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonSymbol; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonSymbol; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The name of the symbol }
    property Name: String read GetName;
  end;

type
  { A table used to lookup TBsonSymbol values }
  TBsonSymbolTable = record
  {$REGION 'Internal Declarations'}
  private class var
    FTable: TDictionary<String, TBsonSymbol>;
    FLock: TCriticalSection;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    { Looks up a symbol.

      Parameters:
        AName: the name of the symbol the lookup.

      Returns:
        A symbol with the given name.

      If the table already contains a symbol with the given name, then that
      symbol is returned. Otherwise, a new symbol is added to the table. }
    class function Lookup(const AName: String): TBsonSymbol; static;
  end;

type
  { Represents the BSON MaxKey value }
  TBsonMaxKey = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IMaxKey = interface(TBsonValue._IValue)
    ['{A6013802-3E77-4A53-B167-9EC4F0EDE896}']
    end;
  private class var
    FImpl: TBsonMaxKey;
  private
    FValue: _IMaxKey;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    property _Value: _IMaxKey read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON MaxKey to a BSON value. }
    class operator Implicit(const A: TBsonMaxKey): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonMaxKey): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonMaxKey): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonMaxKey; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonMaxKey; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The MaxKey value singleton }
    class property Value: TBsonMaxKey read FImpl;
  end;

type
  { Represents the BSON MinKey value }
  TBsonMinKey = record
  {$REGION 'Internal Declarations'}
  private type
    { @exclude }
    _IMinKey = interface(TBsonValue._IValue)
    ['{539D88D8-5E9F-4FA0-8304-A81FA89D8934}']
    end;
  private class var
    FImpl: TBsonMinKey;
  private
    FValue: _IMinKey;
  public
    { @exclude }
    class constructor Create;

    { @exclude }
    property _Value: _IMinKey read FValue;
  {$ENDREGION 'Internal Declarations'}
  public
    { Implicitly casts a BSON MinKey to a BSON value. }
    class operator Implicit(const A: TBsonMinKey): TBsonValue; //static;

    { See TBsonValue.Equal }
    class operator Equal(const A, B: TBsonMinKey): Boolean; //static;

    { See TBsonValue.NotEqual }
    class operator NotEqual(const A, B: TBsonMinKey): Boolean; //static;

    { See TBsonValue.IsNil }
    function IsNil: Boolean; inline;

    { See TBsonValue.Clone }
    function Clone: TBsonMinKey; inline;

    { See TBsonValue.DeepClone }
    function DeepClone: TBsonMinKey; inline;

    { See TBsonValue.ToBson }
    function ToBson: TBytes; inline;

    { See TBsonValue.ToJson }
    function ToJson: String; overload; inline;

    { See TBsonValue.ToJson }
    function ToJson(const ASettings: TJsonWriterSettings): String; overload; inline;

    { The MinKey value singleton }
    class property Value: TBsonMinKey read FImpl;
  end;

type
  { Adds methods to TBsonValue }
  TBsonValueHelper = record helper for TBsonValue
  public
    { Returns the value as a BSON array.
      Returns an empty array of the value isn't a BSON array }
    function ToBsonArray: TBsonArray; inline;

    { Returns the value as a BSON array.

      Raises:
        EIntfCastError if this value isn't a BSON array }
    function AsBsonArray: TBsonArray; inline;

    { Returns the value as a BSON binary.

      Raises:
        EIntfCastError if this value isn't a BSON binary }
    function AsBsonBinaryData: TBsonBinaryData; inline;

    { Returns the value as a BSON document.
      Returns an empty document of the value isn't a BSON document }
    function ToBsonDocument: TBsonDocument; inline;

    { Returns the value as a BSON document.

      Raises:
        EIntfCastError if this value isn't a BSON document }
    function AsBsonDocument: TBsonDocument; inline;

    { Returns the value as a BSON JavaScript object.

      Raises:
        EIntfCastError if this value isn't a BSON JavaScript object }
    function AsBsonJavaScript: TBsonJavaScript; inline;

    { Returns the value as a BSON JavaScript-with-scope object.

      Raises:
        EIntfCastError if this value isn't a BSON JavaScript-with-scope object }
    function AsBsonJavaScriptWithScope: TBsonJavaScriptWithScope; inline;

    { Returns the value as a BSON MaxKey.

      Raises:
        EIntfCastError if this value isn't a BSON MaxKey }
    function AsBsonMaxKey: TBsonMaxKey; inline;

    { Returns the value as a BSON MinKey.

      Raises:
        EIntfCastError if this value isn't a BSON MinKey }
    function AsBsonMinKey: TBsonMinKey; inline;

    { Returns the value as a BSON Null.

      Raises:
        EIntfCastError if this value isn't a BSON Null }
    function AsBsonNull: TBsonNull; inline;

    { Returns the value as a BSON Undefined.

      Raises:
        EIntfCastError if this value isn't a BSON Undefined }
    function AsBsonUndefined: TBsonUndefined; inline;

    { Returns the value as a BSON Regular Expression.

      Raises:
        EIntfCastError if this value isn't a BSON Regular Expression }
    function AsBsonRegularExpression: TBsonRegularExpression; inline;

    { Returns the value as a BSON Symbol.

      Raises:
        EIntfCastError if this value isn't a BSON Symbol }
    function AsBsonSymbol: TBsonSymbol; inline;

    { Returns the value as a BSON DateTime.

      Raises:
        EIntfCastError if this value isn't a BSON DateTime }
    function AsBsonDateTime: TBsonDateTime; inline;

    { Returns the value as a BSON Timestamp.

      Raises:
        EIntfCastError if this value isn't a BSON Timestamp }
    function AsBsonTimestamp: TBsonTimestamp; inline;
  end;

{$REGION 'Internal Declarations'}
{ @exclude }
function _goBsonValueFromDouble(const AValue: Double): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromString(const AValue: String): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromObjectId(const AValue: TObjectId): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromBoolean(const AValue: Boolean): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromDateTime(const AValue: Int64): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromInt32(const AValue: Int32): TBsonValue._IValue;

{ @exclude }
function _goBsonValueFromInt64(const AValue: Int64): TBsonValue._IValue;

{ @exclude }
function _goCreateArray: TBsonArray._IArray;

{ @exclude }
function _goCreateDocument: TBsonDocument._IDocument;

{ @exclude }
procedure _goGetBinaryData(const ASrc: TBsonValue._IValue;
  out ADst: TBsonBinaryData);

{ @exclude }
procedure _goGetDateTime(const ASrc: TBsonValue._IValue;
  out ADst: TBsonDateTime);

{ @exclude }
procedure _goGetRegularExpression(const ASrc: TBsonValue._IValue;
  out ADst: TBsonRegularExpression);

{ @exclude }
procedure _goGetJavaScript(const ASrc: TBsonValue._IValue;
  out ADst: TBsonJavaScript);

{ @exclude }
procedure _goGetJavaScriptWithScope(const ASrc: TBsonValue._IValue;
  out ADst: TBsonJavaScriptWithScope);

{ @exclude }
procedure _goGetSymbol(const ASrc: TBsonValue._IValue;
  out ADst: TBsonSymbol);

{ @exclude }
procedure _goGetTimestamp(const ASrc: TBsonValue._IValue;
  out ADst: TBsonTimestamp);
{$ENDREGION 'Internal Declarations'}

implementation

uses
  System.Types,
  System.SysConst,
  System.RTLConsts,
  System.DateUtils,
  {$IF CompilerVersion < 28.0}
  Lib.Helpers,
  System.Math,
  {$IFEND}
  Lib.SysUtils,
  Lib.DateUtils,
  Lib.Bson.IO;

type
  TNonRefCountedInterface = record {IInterface}
  private
    FVTable: Pointer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Addref: Integer; stdcall;
    function Release: Integer; stdcall;
  end;

type
  TRefCountedInterface = record {IInterface}
  private
    FVTable: Pointer;
    FRefCount: Integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Addref: Integer; stdcall;
    function Release: Integer; stdcall;
  end;

type
  TValue = record {TInterfacedRecord, TBsonValue._IValue}
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsBoolean: Boolean;
    function AsInteger: Integer;
    function AsInt64: Int64;
    function AsDouble: Double;
    function AsString: String;
    function AsArray: TArray<TBsonValue>;
    function AsByteArray: TBytes;
    function AsGuid: TGUID;
    function AsObjectId: TObjectId;

    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function ToLocalTime: TDateTime;
    function ToUniversalTime: TDateTime;
    function ToByteArray: TBytes;
    function ToGuid: TGUID;
    function ToObjectId: TObjectId;

    function Equals(const AOther: TBsonValue._IValue): Boolean;

    function Clone: TBsonValue._IValue;
    function DeepClone: TBsonValue._IValue;
  end;
  PValue = ^TValue;

type
  TInterfaceVTable = record
    QueryInterface: Pointer;
    Addref: Pointer;
    Release: Pointer;
  end;

type
  TVTableValue = record
    Intf: TInterfaceVTable;
    GetBsonType: Pointer;
    AsBoolean: Pointer;
    AsInteger: Pointer;
    AsInt64: Pointer;
    AsDouble: Pointer;
    AsString: Pointer;
    AsArray: Pointer;
    AsByteArray: Pointer;
    AsGuid: Pointer;
    AsObjectId: Pointer;

    ToBoolean: Pointer;
    ToDouble: Pointer;
    ToInteger: Pointer;
    ToInt64: Pointer;
    ToString: Pointer;
    ToLocalTime: Pointer;
    ToUniversalTime: Pointer;
    ToByteArray: Pointer;
    ToGuid: Pointer;
    ToObjectId: Pointer;

    Equals: Pointer;

    Clone: Pointer;
    DeepClone: Pointer;
  end;

type
  TValueFalse = record {TValue}
  private class var
    FValue: TBsonValue._IValue;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsBoolean: Boolean;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_FALSE: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueFalse.GetBsonType;
    AsBoolean: @TValueFalse.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueFalse.ToBoolean;
    ToDouble: @TValueFalse.ToDouble;
    ToInteger: @TValueFalse.ToInteger;
    ToInt64: @TValueFalse.ToInt64;
    ToString: @TValueFalse.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueFalse.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_BOOLEAN_FALSE: Pointer = @VTABLE_FALSE;

type
  TValueTrue = record {TValue}
  private class var
    FValue: TBsonValue._IValue;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsBoolean: Boolean;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_TRUE: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueTrue.GetBsonType;
    AsBoolean: @TValueTrue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueTrue.ToBoolean;
    ToDouble: @TValueTrue.ToDouble;
    ToInteger: @TValueTrue.ToInteger;
    ToInt64: @TValueTrue.ToInt64;
    ToString: @TValueTrue.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueTrue.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_BOOLEAN_TRUE: Pointer = @VTABLE_TRUE;

type
  TValueInteger = record {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Integer;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsInteger: Integer;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Integer): TBsonValue._IValue; inline; static;
  end;
  PValueInteger = ^TValueInteger;

const
  VTABLE_INTEGER: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueInteger.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValueInteger.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInteger.ToBoolean;
    ToDouble: @TValueInteger.ToDouble;
    ToInteger: @TValueInteger.ToInteger;
    ToInt64: @TValueInteger.ToInt64;
    ToString: @TValueInteger.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInteger.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueIntegerConst = record {TValue}
  private const
    MIN_PRECREATED_VALUE = -100;
    MAX_PRECREATED_VALUE = 100;
  private class var
    FPrecreatedValues: array [MIN_PRECREATED_VALUE..MAX_PRECREATED_VALUE] of TBsonValue._IValue;
    FPrecreatedData: Pointer;
  private
    FBase: TNonRefCountedInterface;
    FValue: Integer;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsInteger: Integer;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
    class destructor Destroy;
  end;
  PValueIntegerConst = ^TValueIntegerConst;

const
  VTABLE_INTEGER_CONST: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueIntegerConst.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValueIntegerConst.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueIntegerConst.ToBoolean;
    ToDouble: @TValueIntegerConst.ToDouble;
    ToInteger: @TValueIntegerConst.ToInteger;
    ToInt64: @TValueIntegerConst.ToInt64;
    ToString: @TValueIntegerConst.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueIntegerConst.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueInt64 = record {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Int64;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsInt64: Int64;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Int64): TBsonValue._IValue; inline; static;
  end;
  PValueInt64 = ^TValueInt64;

const
  VTABLE_INT64: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueInt64.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValueInt64.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInt64.ToBoolean;
    ToDouble: @TValueInt64.ToDouble;
    ToInteger: @TValueInt64.ToInteger;
    ToInt64: @TValueInt64.ToInt64;
    ToString: @TValueInt64.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInt64.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueInt64Const = record {TValue}
  private const
    MIN_PRECREATED_VALUE = -100;
    MAX_PRECREATED_VALUE = 100;
  private class var
    FPrecreatedValues: array [MIN_PRECREATED_VALUE..MAX_PRECREATED_VALUE] of TBsonValue._IValue;
    FPrecreatedData: Pointer;
  private
    FBase: TNonRefCountedInterface;
    FValue: Int64;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsInt64: Int64;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
    class destructor Destroy;
  end;
  PValueInt64Const = ^TValueInt64Const;

const
  VTABLE_INT64_CONST: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueInt64Const.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValueInt64Const.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueInt64Const.ToBoolean;
    ToDouble: @TValueInt64Const.ToDouble;
    ToInteger: @TValueInt64Const.ToInteger;
    ToInt64: @TValueInt64Const.ToInt64;
    ToString: @TValueInt64Const.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueInt64Const.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueDouble = record {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Double;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsDouble: Double;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: Double): TBsonValue._IValue; inline; static;
  end;
  PValueDouble = ^TValueDouble;

const
  VTABLE_DOUBLE: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueDouble.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValueDouble.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueDouble.ToBoolean;
    ToDouble: @TValueDouble.ToDouble;
    ToInteger: @TValueDouble.ToInteger;
    ToInt64: @TValueDouble.ToInt64;
    ToString: @TValueDouble.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueDouble.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueDoubleZero = record {TValue}
  private class var
    FValue: TBsonValue._IValue;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsDouble: Double;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_DOUBLE_ZERO: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueDoubleZero.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValueDoubleZero.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueDoubleZero.ToBoolean;
    ToDouble: @TValueDoubleZero.ToDouble;
    ToInteger: @TValueDoubleZero.ToInteger;
    ToInt64: @TValueDoubleZero.ToInt64;
    ToString: @TValueDoubleZero.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueDoubleZero.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_DOUBLE_ZERO: Pointer = @VTABLE_DOUBLE_ZERO;

type
  TValueDateTime = record {TValue, TBsonDateTime._IDateTime}
  private
    FBase: TRefCountedInterface;
    FMillisecondsSinceEpoch: Int64;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function ToLocalTime: TDateTime;
    function ToUniversalTime: TDateTime;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    { TBsonDateTime._IDateTime }
    function GetMillisecondsSinceEpoch: Int64;
  public
    class function Create(const ADateTime: TDateTime; const ADateTimeIsUTC: Boolean): TBsonDateTime._IDateTime; overload; inline; static;
    class function Create(const AMillisecondsSinceEpoch: Int64): TBsonDateTime._IDateTime; overload; inline; static;
  end;
  PValueDateTime = ^TValueDateTime;

type
  TVTableValueDateTime = record
    Base: TVTableValue;
    GetMillisecondsSinceEpoch: Pointer;
  end;

const
  VTABLE_DATE_TIME: TVTableValueDateTime = (
    Base:
     (Intf:
       (QueryInterface: @TValueDateTime.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TRefCountedInterface.Release);
      GetBsonType: @TValueDateTime.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValueDateTime.ToString;
      ToLocalTime: @TValueDateTime.ToLocalTime;
      ToUniversalTime: @TValueDateTime.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueDateTime.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);
    GetMillisecondsSinceEpoch: @TValueDateTime.GetMillisecondsSinceEpoch);

type
  TValueString = record {TValue}
  private
    FBase: TRefCountedInterface;
    FLength: Integer;
    { Data: array of Char }
  private
    function Value: String; inline;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: String): TBsonValue._IValue; inline; static;
  end;
  PValueString = ^TValueString;

const
  VTABLE_STRING: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueString.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueString.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueString.ToBoolean;
    ToDouble: @TValueString.ToDouble;
    ToInteger: @TValueString.ToInteger;
    ToInt64: @TValueString.ToInt64;
    ToString: @TValueString.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueString.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueStringEmpty = packed record {TValue}
  private class var
    FValue: TBsonValue._IValue;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class constructor Create;
  end;

const
  VTABLE_STRING_EMPTY: TVTableValue = (
    Intf:
      (QueryInterface: @TNonRefCountedInterface.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueStringEmpty.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueStringEmpty.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueStringEmpty.ToBoolean;
    ToDouble: @TValueStringEmpty.ToDouble;
    ToInteger: @TValueStringEmpty.ToInteger;
    ToInt64: @TValueStringEmpty.ToInt64;
    ToString: @TValueStringEmpty.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueStringEmpty.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

const
  VALUE_STRING_EMPTY: Pointer = @VTABLE_STRING_EMPTY;

type
  TValueStringConstant = record {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: Pointer;
  private
    function Value: String; inline;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsString: String;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToDouble(const ADefault: Double): Double;
    function ToInteger(const ADefault: Integer): Integer;
    function ToInt64(const ADefault: Int64): Int64;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: String): TBsonValue._IValue; inline; static;
  end;
  PValueStringConstant = ^TValueStringConstant;

const
  VTABLE_STRING_CONSTANT: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueStringConstant.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValueStringConstant.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueStringConstant.ToBoolean;
    ToDouble: @TValueStringConstant.ToDouble;
    ToInteger: @TValueStringConstant.ToInteger;
    ToInt64: @TValueStringConstant.ToInt64;
    ToString: @TValueStringConstant.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueStringConstant.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueArray = record {TValue, TBsonArray._IArray}
  private
    FBase: TRefCountedInterface;
    FItems: TArray<TBsonValue._IValue>;
    FCount: Integer;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsArray: TArray<TBsonValue>;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
    function Clone: TBsonValue._IValue;
    function DeepClone: TBsonValue._IValue;
  public
    { TBsonArray._IArray }
    function GetCount: Integer;
    procedure GetItem(const AIndex: Integer; out AValue: TBsonValue._IValue);
    procedure SetItem(const AIndex: Integer; const AValue: TBsonValue._IValue);
    procedure Add(const AValue: TBsonValue._IValue); overload;
    procedure AddRangeOpenArray(const AValues: array of TBsonValue); overload;
    procedure AddRangeGenArray(const AValues: TArray<TBsonValue>); overload;
    procedure AddRangeBsonArray(const AValues: TBsonArray); overload;
    procedure Delete(const AIndex: Integer);
    function Remove(const AValue: TBsonValue): Boolean;
    procedure Clear;
    function Contains(const AValue: TBsonValue): Boolean;
    function IndexOf(const AValue: TBsonValue): Integer;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    class function Create(const ACapacity: Integer = 0): TBsonArray._IArray; overload; inline; static;
    class function Create(const AValues: array of TBsonValue): TBsonArray._IArray; overload; static;
    class function Create(const AValues: TArray<TBsonValue>): TBsonArray._IArray; overload; inline; static;
  end;
  PValueArray = ^TValueArray;

type
  TVTableValueArray = record
    Base: TVTableValue;
    GetCount: Pointer;
    GetItem: Pointer;
    SetItem: Pointer;
    Add: Pointer;
    AddRangeOpenArray: Pointer;
    AddRangeGenArray: Pointer;
    AddRangeBsonArray: Pointer;
    Delete: Pointer;
    Remove: Pointer;
    Clear: Pointer;
    Contains: Pointer;
    IndexOf: Pointer;
  end;

const
  VTABLE_ARRAY: TVTableValueArray = (
    Base:
     (Intf:
       (QueryInterface: @TValueArray.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueArray.Release);
      GetBsonType: @TValueArray.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValueArray.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueArray.Equals;

      Clone: @TValueArray.Clone;
      DeepClone: @TValueArray.DeepClone);
    GetCount: @TValueArray.GetCount;
    GetItem: @TValueArray.GetItem;
    SetItem: @TValueArray.SetItem;
    Add: @TValueArray.Add;
    AddRangeOpenArray: @TValueArray.AddRangeOpenArray;
    AddRangeGenArray: @TValueArray.AddRangeGenArray;
    AddRangeBsonArray: @TValueArray.AddRangeBsonArray;
    Delete: @TValueArray.Delete;
    Remove: @TValueArray.Remove;
    Clear: @TValueArray.Clear;
    Contains: @TValueArray.Contains;
    IndexOf: @TValueArray.IndexOf);

type
  TValueBinaryData = record {TValue, TBsonBinaryData._IBinaryData}
  private
    FBase: TRefCountedInterface;
    FValue: TBytes;
    FSubType: TBsonBinarySubType;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsByteArray: TBytes;
    function AsGuid: TGUID;
    function ToGuid: TGUID;
    function ToByteArray: TBytes;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    { TBsonBinaryData._IBinaryData }
    function GetSubType: TBsonBinarySubType;
    function GetCount: Integer;
    function GetByte(const AIndex: Integer): Byte;
    procedure SetByte(const AIndex: Integer; const AValue: Byte);
    function GetAsBytes: TBytes;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    class function Create: TBsonBinaryData._IBinaryData; overload; inline; static;
    class function Create(const AValue: TBytes;
      const ASubType: TBsonBinarySubType = TBsonBinarySubType.Binary): TBsonBinaryData._IBinaryData; overload; inline; static;
    class function Create(const AValue: TGUID): TBsonBinaryData._IBinaryData; overload; inline; static;
  end;
  PValueBinaryData = ^TValueBinaryData;

type
  TVTableValueBinaryData = record
    Base: TVTableValue;
    GetSubType: Pointer;
    GetCount: Pointer;
    GetByte: Pointer;
    SetByte: Pointer;
    GetAsBytes: Pointer;
  end;

const
  VTABLE_BINARY_DATA: TVTableValueBinaryData = (
    Base:
     (Intf:
       (QueryInterface: @TValueBinaryData.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueBinaryData.Release);
      GetBsonType: @TValueBinaryData.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValueBinaryData.AsByteArray;
      AsGuid: @TValueBinaryData.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValueBinaryData.ToByteArray;
      ToGuid: @TValueBinaryData.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueBinaryData.Equals);
    GetSubType: @TValueBinaryData.GetSubType;
    GetCount: @TValueBinaryData.GetCount;
    GetByte: @TValueBinaryData.GetByte;
    SetByte: @TValueBinaryData.SetByte;
    GetAsBytes: @TValueBinaryData.GetAsBytes);

type
  TValueDocument = record {TValue, TBsonDocument._IDocument}
  private const
    { We use an FIndices dictionary to map names to indices.
      However, for small dictionaries it is faster and more memory efficient
      to just perform a linear search.
      So we only use the dictionary if the number of items reaches this value. }
    INDICES_COUNT_THRESHOLD = 12;
  private type
    TMapEntry = record
      HashCode: Integer;
      Name: String;
      Index: Integer;
    end;
    TMapEntries = TArray<TMapEntry>;
  private type
    TIndexMap = record
    private const
      EMPTY_HASH = -1;
    private
      FEntries: TMapEntries;
      FCount: Integer;
      FGrowThreshold: Integer;
    private
      procedure Resize(ANewSize: Integer);
    public
      procedure Release; inline;
      procedure Clear;
      procedure Add(const AName: String; const AIndex: Integer);
      function Get(const AName: String): Integer;
    end;
    PIndexMap = ^TIndexMap;
  private
    FBase: TRefCountedInterface;
    FAllowDuplicateNames: Boolean;
    FElements: TArray<TBsonElement>;
    FIndices: PIndexMap;
    FCount: Integer;
  private
    procedure RebuildIndices;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
    function Clone: TBsonValue._IValue;
    function DeepClone: TBsonValue._IValue;
  public
    { TBsonDocument._IDocument }
    function GetCount: Integer;
    function GetAllowDuplicateNames: Boolean;
    procedure SetAllowDuplicateNames(const AValue: Boolean);
    function GetElement(const AIndex: Integer): TBsonElement;
    procedure GetValue(const AIndex: Integer; out AValue: TBsonValue._IValue);
    procedure SetValue(const AIndex: Integer; const AValue: TBsonValue._IValue);
    procedure GetValueByName(const AName: String; out AValue: TBsonValue._IValue);
    procedure SetValueByName(const AName: String; const AValue: TBsonValue._IValue);
    procedure Add(const AName: String; const AValue: TBsonValue._IValue);
    procedure Get(const AName: String; const ADefault: TBsonValue._IValue;
      out AValue: TBsonValue._IValue);
    function IndexOfName(const AName: String): Integer;
    function Contains(const AName: String): Boolean;
    function ContainsValue(const AValue: TBsonValue): Boolean;
    function TryGetElement(const AName: String; out AElement: TBsonElement): Boolean;
    function TryGetValue(const AName: String; out AValue: TBsonValue._IValue): Boolean;
    procedure Remove(const AName: String);
    procedure Delete(const AIndex: Integer);
    procedure Clear;
    procedure Merge(const AOtherDocument: TBsonDocument;
      const AOverwriteExistingElements: Boolean);
    function ToArray: TArray<TBsonElement>;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    class function Create(const AAllowDuplicateNames: Boolean = False): TBsonDocument._IDocument; overload; inline; static;
    class function Create(const AElement: TBsonElement): TBsonDocument._IDocument; overload; inline; static;
    class function Create(const AName: String; const AValue: TBsonValue): TBsonDocument._IDocument; overload; inline; static;
  end;
  PValueDocument = ^TValueDocument;

type
  TVTableValueDocument = record
    Base: TVTableValue;

    GetCount: Pointer;
    GetAllowDuplicateNames: Pointer;
    SetAllowDuplicateNames: Pointer;
    GetElement: Pointer;
    GetValue: Pointer;
    SetValue: Pointer;
    GetValueByName: Pointer;
    SetValueByName: Pointer;

    Add: Pointer;
    Get: Pointer;
    IndexOfName: Pointer;
    Contains: Pointer;
    ContainsValue: Pointer;
    TryGetElement: Pointer;
    TryGetValue: Pointer;
    Remove: Pointer;
    Delete: Pointer;
    Clear: Pointer;
    Merge: Pointer;
    ToArray: Pointer;
  end;

const
  VTABLE_DOCUMENT: TVTableValueDocument = (
    Base:
     (Intf:
       (QueryInterface: @TValueDocument.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueDocument.Release);
      GetBsonType: @TValueDocument.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueDocument.Equals;

      Clone: @TValueDocument.Clone;
      DeepClone: @TValueDocument.DeepClone);

    GetCount: @TValueDocument.GetCount;
    GetAllowDuplicateNames: @TValueDocument.GetAllowDuplicateNames;
    SetAllowDuplicateNames: @TValueDocument.SetAllowDuplicateNames;
    GetElement: @TValueDocument.GetElement;
    GetValue: @TValueDocument.GetValue;
    SetValue: @TValueDocument.SetValue;
    GetValueByName: @TValueDocument.GetValueByName;
    SetValueByName: @TValueDocument.SetValueByName;

    Add: @TValueDocument.Add;
    Get: @TValueDocument.Get;
    IndexOfName: @TValueDocument.IndexOfName;
    Contains: @TValueDocument.Contains;
    ContainsValue: @TValueDocument.ContainsValue;
    TryGetElement: @TValueDocument.TryGetElement;
    TryGetValue: @TValueDocument.TryGetValue;
    Remove: @TValueDocument.Remove;
    Delete: @TValueDocument.Delete;
    Clear: @TValueDocument.Clear;
    Merge: @TValueDocument.Merge;
    ToArray: @TValueDocument.ToArray);

type
  TValueNull = record {TValue, TBsonNull._INull}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  end;

const
  VTABLE_NULL: TVTableValue = (
    Intf:
      (QueryInterface: @TValueNull.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueNull.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueNull.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueNull.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueNull.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_NULL: Pointer = @VTABLE_NULL;

type
  TValueUndefined = record {TValue, TBsonUndefined._IUndefined}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function ToBoolean(const ADefault: Boolean): Boolean;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  end;

const
  VTABLE_UNDEFINED: TVTableValue = (
    Intf:
      (QueryInterface: @TValueUndefined.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueUndefined.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValueUndefined.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueUndefined.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueUndefined.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_UNDEFINED: Pointer = @VTABLE_UNDEFINED;

type
  TValueObjectId = record {TValue}
  private
    FBase: TRefCountedInterface;
    FValue: TObjectId;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function AsObjectId: TObjectId;
    function ToObjectId: TObjectId;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    class function Create(const AValue: TObjectId): TBsonValue._IValue; inline; static;
  end;
  PValueObjectId = ^TValueObjectId;

const
  VTABLE_OBJECT_ID: TVTableValue = (
    Intf:
      (QueryInterface: @TRefCountedInterface.QueryInterface;
       AddRef: @TRefCountedInterface.AddRef;
       Release: @TRefCountedInterface.Release);
    GetBsonType: @TValueObjectId.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValueObjectId.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueObjectId.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValueObjectId.ToObjectId;

    Equals: @TValueObjectId.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.DeepClone);

type
  TValueRegularExpression = record {TValue, TBsonRegularExpression._IRegularExpression}
  private
    FBase: TRefCountedInterface;
    FPattern: String;
    FOptions: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    { TBsonRegularExpression._IRegularExpression }
    function GetOptions: String;
    function GetPattern: String;
  public
    class function Create(const APattern: String): TBsonRegularExpression._IRegularExpression; overload; inline; static;
    class function Create(const APattern, AOptions: String): TBsonRegularExpression._IRegularExpression; overload; inline; static;
  end;
  PValueRegularExpression = ^TValueRegularExpression;

type
  TVTableValueRegularExpression = record
    Base: TVTableValue;
    GetOptions: Pointer;
    GetPattern: Pointer;
  end;

const
  VTABLE_REGULAR_EXPRESSION: TVTableValueRegularExpression = (
    Base:
     (Intf:
       (QueryInterface: @TValueRegularExpression.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueRegularExpression.Release);
      GetBsonType: @TValueRegularExpression.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueRegularExpression.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetOptions: @TValueRegularExpression.GetOptions;
    GetPattern: @TValueRegularExpression.GetPattern);

type
  TValueJavaScript = record {TValue, TBsonJavaScript._IJavaScript}
  private
    FBase: TRefCountedInterface;
    FCode: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    { TBsonJavaScript._IJavaScript }
    function GetCode: String;
  public
    class function Create(const ACode: String): TBsonJavaScript._IJavaScript; inline; static;
  end;
  PValueJavaScript = ^TValueJavaScript;

type
  TVTableValueJavaScript = record
    Base: TVTableValue;
    GetCode: Pointer;
  end;

const
  VTABLE_JAVA_SCRIPT: TVTableValueJavaScript = (
    Base:
     (Intf:
       (QueryInterface: @TValueJavaScript.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueJavaScript.Release);
      GetBsonType: @TValueJavaScript.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueJavaScript.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetCode: @TValueJavaScript.GetCode);

type
  TValueJavaScriptWithScope = record {TValueJavaScript, TBsonJavaScriptWithScope._IJavaScriptWithScope}
  private
    FBase: TValueJavaScript;
    FScope: TBsonDocument;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
    function Clone: TBsonValue._IValue;
    function DeepClone: TBsonValue._IValue;
  public
    { TBsonJavaScriptWithScope._IJavaScriptWithScope }
    function GetScope: TBsonDocument;
  public
    class function Create(const ACode: String; const AScope: TBsonDocument): TBsonJavaScriptWithScope._IJavaScriptWithScope; inline; static;
  end;
  PValueJavaScriptWithScope = ^TValueJavaScriptWithScope;

type
  TVTableValueJavaScriptWithScope = record
    Base: TVTableValueJavaScript;
    GetScope: Pointer;
  end;

const
  VTABLE_JAVA_SCRIPT_WITH_SCOPE: TVTableValueJavaScriptWithScope = (
    Base:
     (Base:
       (Intf:
         (QueryInterface: @TValueJavaScriptWithScope.QueryInterface;
          AddRef: @TRefCountedInterface.AddRef;
          Release: @TValueJavaScriptWithScope.Release);
        GetBsonType: @TValueJavaScriptWithScope.GetBsonType;
        AsBoolean: @TValue.AsBoolean;
        AsInteger: @TValue.AsInteger;
        AsInt64: @TValue.AsInt64;
        AsDouble: @TValue.AsDouble;
        AsString: @TValue.AsString;
        AsArray: @TValue.AsArray;
        AsByteArray: @TValue.AsByteArray;
        AsGuid: @TValue.AsGuid;
        AsObjectId: @TValue.AsObjectId;

        ToBoolean: @TValue.ToBoolean;
        ToDouble: @TValue.ToDouble;
        ToInteger: @TValue.ToInteger;
        ToInt64: @TValue.ToInt64;
        ToString: @TValue.ToString;
        ToLocalTime: @TValue.ToLocalTime;
        ToUniversalTime: @TValue.ToUniversalTime;
        ToByteArray: @TValue.ToByteArray;
        ToGuid: @TValue.ToGuid;
        ToObjectId: @TValue.ToObjectId;

        Equals: @TValueJavaScriptWithScope.Equals;

        Clone: @TValueJavaScriptWithScope.Clone;
        DeepClone: @TValueJavaScriptWithScope.DeepClone);

      GetCode: @TValueJavaScript.GetCode);

    GetScope: @TValueJavaScriptWithScope.GetScope);

type
  TValueSymbol = record {TValue, TBsonSymbol._ISymbol}
  private
    FBase: TRefCountedInterface;
    FName: String;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function Release: Integer; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
    function ToString(const ADefault: String): String;
  public
    { TBsonSymbol._ISymbol }
    function GetName: String;
  public
    class function Create(const AName: String): TBsonSymbol._ISymbol; inline; static;
  end;
  PValueSymbol = ^TValueSymbol;

type
  TVTableValueSymbol = record
    Base: TVTableValue;
    GetName: Pointer;
  end;

const
  VTABLE_SYMBOL: TVTableValueSymbol = (
    Base:
     (Intf:
       (QueryInterface: @TValueSymbol.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TValueSymbol.Release);
      GetBsonType: @TValueSymbol.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValueSymbol.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueSymbol.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetName: @TValueSymbol.GetName);

type
  TValueTimestamp = record {TValue, TBsonTimestamp._ITimestamp}
  private
    FBase: TRefCountedInterface;
    FValue: Int64;
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  public
    { TBsonTimestamp._ITimestamp }
    function GetIncrement: Integer;
    function GetTimestamp: Integer;
    function GetValue: Int64;
  public
    class function Create(const AValue: Int64): TBsonTimestamp._ITimestamp; overload; inline; static;
    class function Create(const ATimestamp, AIncrement: Integer): TBsonTimestamp._ITimestamp; overload; inline; static;
  end;
  PValueTimestamp = ^TValueTimestamp;

type
  TVTableValueTimestamp = record
    Base: TVTableValue;
    GetIncrement: Pointer;
    GetTimestamp: Pointer;
    GetValue: Pointer;
  end;

const
  VTABLE_TIMESTAMP: TVTableValueTimestamp = (
    Base:
     (Intf:
       (QueryInterface: @TValueTimestamp.QueryInterface;
        AddRef: @TRefCountedInterface.AddRef;
        Release: @TRefCountedInterface.Release);
      GetBsonType: @TValueTimestamp.GetBsonType;
      AsBoolean: @TValue.AsBoolean;
      AsInteger: @TValue.AsInteger;
      AsInt64: @TValue.AsInt64;
      AsDouble: @TValue.AsDouble;
      AsString: @TValue.AsString;
      AsArray: @TValue.AsArray;
      AsByteArray: @TValue.AsByteArray;
      AsGuid: @TValue.AsGuid;
      AsObjectId: @TValue.AsObjectId;

      ToBoolean: @TValue.ToBoolean;
      ToDouble: @TValue.ToDouble;
      ToInteger: @TValue.ToInteger;
      ToInt64: @TValue.ToInt64;
      ToString: @TValue.ToString;
      ToLocalTime: @TValue.ToLocalTime;
      ToUniversalTime: @TValue.ToUniversalTime;
      ToByteArray: @TValue.ToByteArray;
      ToGuid: @TValue.ToGuid;
      ToObjectId: @TValue.ToObjectId;

      Equals: @TValueTimestamp.Equals;

      Clone: @TValue.Clone;
      DeepClone: @TValue.DeepClone);

    GetIncrement: @TValueTimestamp.GetIncrement;
    GetTimestamp: @TValueTimestamp.GetTimestamp;
    GetValue: @TValueTimestamp.GetValue);

type
  TValueMaxKey = record {TValue, TBsonMaxKey._IMaxKey}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  end;

const
  VTABLE_MAX_KEY: TVTableValue = (
    Intf:
      (QueryInterface: @TValueMaxKey.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueMaxKey.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueMaxKey.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueMaxKey.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_MAX_KEY: Pointer = @VTABLE_MAX_KEY;

type
  TValueMinKey = record {TValue, TBsonMinKey._IMinKey}
  public
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  public
    { TBsonValue._IValue }
    function GetBsonType: TBsonType;
    function ToString(const ADefault: String): String;
    function Equals(const AOther: TBsonValue._IValue): Boolean;
  end;

const
  VTABLE_MIN_KEY: TVTableValue = (
    Intf:
      (QueryInterface: @TValueMinKey.QueryInterface;
       AddRef: @TNonRefCountedInterface.AddRef;
       Release: @TNonRefCountedInterface.Release);
    GetBsonType: @TValueMinKey.GetBsonType;
    AsBoolean: @TValue.AsBoolean;
    AsInteger: @TValue.AsInteger;
    AsInt64: @TValue.AsInt64;
    AsDouble: @TValue.AsDouble;
    AsString: @TValue.AsString;
    AsArray: @TValue.AsArray;
    AsByteArray: @TValue.AsByteArray;
    AsGuid: @TValue.AsGuid;
    AsObjectId: @TValue.AsObjectId;

    ToBoolean: @TValue.ToBoolean;
    ToDouble: @TValue.ToDouble;
    ToInteger: @TValue.ToInteger;
    ToInt64: @TValue.ToInt64;
    ToString: @TValueMinKey.ToString;
    ToLocalTime: @TValue.ToLocalTime;
    ToUniversalTime: @TValue.ToUniversalTime;
    ToByteArray: @TValue.ToByteArray;
    ToGuid: @TValue.ToGuid;
    ToObjectId: @TValue.ToObjectId;

    Equals: @TValueMinKey.Equals;

    Clone: @TValue.Clone;
    DeepClone: @TValue.Clone);

const
  VALUE_MIN_KEY: Pointer = @VTABLE_MIN_KEY;

function _goBsonValueFromDouble(const AValue: Double): TBsonValue._IValue;
begin
  if (not AValue.IsNan) and (AValue = 0) then
    Result := TValueDoubleZero.FValue
  else
    Result := TValueDouble.Create(AValue);
end;

function _goBsonValueFromString(const AValue: String): TBsonValue._IValue;
begin
  if (AValue = '') then
    Result := TValueStringEmpty.FValue
  else if (StringRefCount(AValue) < 0) then
    Result := TValueStringConstant.Create(AValue)
  else
    Result := TValueString.Create(AValue);
end;

function _goBsonValueFromObjectId(const AValue: TObjectId): TBsonValue._IValue;
begin
  Result := TValueObjectId.Create(AValue);
end;

function _goBsonValueFromBoolean(const AValue: Boolean): TBsonValue._IValue;
begin
  if (AValue) then
    Result := TValueTrue.FValue
  else
    Result := TValueFalse.FValue;
end;

function _goBsonValueFromDateTime(const AValue: Int64): TBsonValue._IValue;
begin
  Result := TValueDateTime.Create(AValue);
end;

function _goBsonValueFromInt32(const AValue: Int32): TBsonValue._IValue;
begin
  if (AValue >= TValueIntegerConst.MIN_PRECREATED_VALUE) and (AValue <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result := TValueIntegerConst.FPrecreatedValues[AValue]
  else
    Result := TValueInteger.Create(AValue);
end;

function _goBsonValueFromInt64(const AValue: Int64): TBsonValue._IValue;
begin
  if (AValue >= TValueInt64Const.MIN_PRECREATED_VALUE) and (AValue <= TValueInt64Const.MAX_PRECREATED_VALUE) then
    Result := TValueInt64Const.FPrecreatedValues[AValue]
  else
    Result := TValueInt64.Create(AValue);
end;

function _goCreateArray: TBsonArray._IArray;
begin
  Result := TValueArray.Create;
end;

function _goCreateDocument: TBsonDocument._IDocument;
begin
  Result := TValueDocument.Create;
end;

procedure _goGetBinaryData(const ASrc: TBsonValue._IValue;
  out ADst: TBsonBinaryData);
begin
  ASrc.QueryInterface(TBsonBinaryData._IBinaryData, ADst.FImpl);
end;

procedure _goGetDateTime(const ASrc: TBsonValue._IValue;
  out ADst: TBsonDateTime);
begin
  ASrc.QueryInterface(TBsonDateTime._IDateTime, ADst.FImpl);
end;

procedure _goGetRegularExpression(const ASrc: TBsonValue._IValue;
  out ADst: TBsonRegularExpression);
begin
  ASrc.QueryInterface(TBsonRegularExpression._IRegularExpression, ADst.FImpl);
end;

procedure _goGetJavaScript(const ASrc: TBsonValue._IValue;
  out ADst: TBsonJavaScript);
begin
  ASrc.QueryInterface(TBsonJavaScript._IJavaScript, ADst.FImpl);
end;

procedure _goGetJavaScriptWithScope(const ASrc: TBsonValue._IValue;
  out ADst: TBsonJavaScriptWithScope);
begin
  ASrc.QueryInterface(TBsonJavaScriptWithScope._IJavaScriptWithScope, ADst.FImpl);
end;

procedure _goGetSymbol(const ASrc: TBsonValue._IValue;
  out ADst: TBsonSymbol);
begin
  ASrc.QueryInterface(TBsonSymbol._ISymbol, ADst.FImpl);
end;

procedure _goGetTimestamp(const ASrc: TBsonValue._IValue;
  out ADst: TBsonTimestamp);
begin
  ASrc.QueryInterface(TBsonTimestamp._ITimestamp, ADst.FImpl);
end;

{ TJsonWriterSettings }

class constructor TJsonWriterSettings.Create;
begin
  FDefault := TJsonWriterSettings.Create;
  FShell := TJsonWriterSettings.Create(TJsonOutputMode.Shell);
  FPretty := TJsonWriterSettings.Create('  ', #13#10, TJsonOutputMode.Strict);
end;

class function TJsonWriterSettings.Create: TJsonWriterSettings;
begin
  Result.FPrettyPrint := False;
  Result.FIndent := '  ';
  Result.FLineBreak := #13#10;
  Result.FOutputMode := TJsonOutputMode.Strict;
end;

class function TJsonWriterSettings.Create(const AIndent, ALineBreak: String;
  const AOutputMode: TJsonOutputMode): TJsonWriterSettings;
begin
  Result.FPrettyPrint := True;
  Result.FIndent := AIndent;
  Result.FLineBreak := ALineBreak;
  Result.FOutputMode := AOutputMode;
end;

class function TJsonWriterSettings.Create(
  const AOutputMode: TJsonOutputMode): TJsonWriterSettings;
begin
  Result.FPrettyPrint := False;
  Result.FIndent := '  ';
  Result.FLineBreak := #13#10;
  Result.FOutputMode := AOutputMode;
end;

class function TJsonWriterSettings.Create(const APrettyPrint: Boolean;
  const AOutputMode: TJsonOutputMode): TJsonWriterSettings;
begin
  Result.FPrettyPrint := APrettyPrint;
  Result.FIndent := '  ';
  Result.FLineBreak := #13#10;
  Result.FOutputMode := AOutputMode;
end;

{ TObjectId }

class function TObjectId.Create(const ABytes: TBytes): TObjectId;
begin
  if (Length(ABytes) <> 12) then
    EArgumentException.CreateRes(@sArgumentInvalid);
  Result.FromByteArray(ABytes);
end;

class function TObjectId.Create(const ABytes: array of Byte): TObjectId;
var
  Bytes: TBytes;
begin
  if (Length(ABytes) <> 12) then
    EArgumentException.CreateRes(@sArgumentInvalid);
  SetLength(Bytes, 12);
  Move(ABytes[0], Bytes[0], 12);
  Result := Create(Bytes);
end;

class function TObjectId.Create(const ATimestamp, AMachine: Integer;
  const APid: UInt16; const AIncrement: Integer): TObjectId;
begin
  if ((AMachine and $FF000000) <> 0) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if ((AIncrement and $FF000000) <> 0) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result.FData[0] := UInt32(ATimestamp);
  Result.FData[1] := UInt32((AMachine shl 8) or (APid shr 8));
  Result.FData[2] := UInt32((APid shl 24) or AIncrement);
end;

procedure TObjectId.FromByteArray(const ABytes: TBytes);
begin
  FBytes[00] := ABytes[03];
  FBytes[01] := ABytes[02];
  FBytes[02] := ABytes[01];
  FBytes[03] := ABytes[00];
  FBytes[04] := ABytes[07];
  FBytes[05] := ABytes[06];
  FBytes[06] := ABytes[05];
  FBytes[07] := ABytes[04];
  FBytes[08] := ABytes[11];
  FBytes[09] := ABytes[10];
  FBytes[10] := ABytes[09];
  FBytes[11] := ABytes[08];
end;

class function TObjectId.GenerateNewId: TObjectId;
begin
  Result := GenerateNewId(GetTimestampFromDateTime(Now, False));
end;

class function TObjectId.GenerateNewId(const ATimestamp: TDateTime;
  const ATimestampIsUTC: Boolean): TObjectId;
begin
  Result := GenerateNewId(GetTimestampFromDateTime(ATimestamp, ATimestampIsUTC));
end;

class function TObjectId.GenerateNewId(
  const ATimestamp: Integer): TObjectId;
var
  Increment: Integer;
begin
  if (not FInitialized) then
    Initialize;

  Increment := AtomicIncrement(FIncrement) and $00FFFFFF;
  Result := TObjectId.Create(ATimestamp, FMachine, FPid, Increment);
end;

function TObjectId.GetCreationTime: TDateTime;
begin
  Result := IncSecond(UnixDateDelta, Timestamp);
end;

function TObjectId.GetIncrement: Integer;
begin
  Result := FData[2] and $FFFFFF;
end;

function TObjectId.GetIsEmpty: Boolean;
begin
  Result := (FData[0] = 0) and (FData[1] = 0) and (FData[2] = 0);
end;

function TObjectId.GetMachine: Integer;
begin
  Result := FData[1] shr 8;
end;

function TObjectId.GetPid: UInt16;
begin
  Result := UInt16((FData[1] shl 8) or (FData[2] shr 24));
end;

function TObjectId.GetTimestamp: Integer;
begin
  Result := Int32(FData[0]);
end;

class function TObjectId.GetTimestampFromDateTime(
  const ATimestamp: TDateTime; const ATimestampIsUTC: Boolean): Integer;
var
  DateTime: TDateTime;
  SecondsSinceEpoch: Int64;
begin
  if (ATimestampIsUTC) then
    DateTime := ATimestamp
  else
    DateTime := TTimeZone.Local.ToUniversalTime(ATimestamp);

  SecondsSinceEpoch := SecondsBetween(DateTime, UnixDateDelta);
  if (DateTime < UnixDateDelta) then
    SecondsSinceEpoch := -SecondsSinceEpoch;

  if (SecondsSinceEpoch < Low(Integer)) or (SecondsSinceEpoch > High(Integer)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := SecondsSinceEpoch;
end;

class operator TObjectId.GreaterThan(const A,
  B: TObjectId): Boolean;
begin
  Result := (A.CompareTo(B) > 0);
end;

class operator TObjectId.GreaterThanOrEqual(const A,
  B: TObjectId): Boolean;
begin
  Result := (A.CompareTo(B) >= 0);
end;

class operator TObjectId.Implicit(const A: String): TObjectId;
begin
  Result := TObjectId.Create(A);
end;

class operator TObjectId.Implicit(const A: TObjectId): String;
begin
  Result := A.ToString;
end;

class procedure TObjectId.Initialize;
var
  MachineName: String;
begin
  FIncrement := Random($1000000);

  MachineName := goGetMachineName;
  FMachine := goMurmurHash2(MachineName[Low(String)], Length(MachineName) * SizeOf(Char)) and $00FFFFFF;
  FPid := goGetCurrentProcessId;

  FInitialized := True;
end;

class operator TObjectId.LessThan(const A, B: TObjectId): Boolean;
begin
  Result := (A.CompareTo(B) < 0);
end;

class operator TObjectId.LessThanOrEqual(const A,
  B: TObjectId): Boolean;
begin
  Result := (A.CompareTo(B) <= 0);
end;

class operator TObjectId.NotEqual(const A, B: TObjectId): Boolean;
begin
  Result := (A.FData[0] <> B.FData[0])
         or (A.FData[1] <> B.FData[1])
         or (A.FData[2] <> B.FData[2])
end;

class function TObjectId.Parse(const AString: String): TObjectId;
begin
  Result := TObjectId.Create(AString);
end;

function TObjectId.ToByteArray: TBytes;
begin
  SetLength(Result, 12);
  ToByteArray(Result, 0);
end;

procedure TObjectId.ToByteArray(const ADestination: TBytes;
  const AOffset: Integer);
begin
  if ((AOffset + 12) > Length(ADestination)) then
    EArgumentException.Create('Not enough room in ADestination');

  ADestination[AOffset + 00] := FBytes[03];
  ADestination[AOffset + 01] := FBytes[02];
  ADestination[AOffset + 02] := FBytes[01];
  ADestination[AOffset + 03] := FBytes[00];
  ADestination[AOffset + 04] := FBytes[07];
  ADestination[AOffset + 05] := FBytes[06];
  ADestination[AOffset + 06] := FBytes[05];
  ADestination[AOffset + 07] := FBytes[04];
  ADestination[AOffset + 08] := FBytes[11];
  ADestination[AOffset + 09] := FBytes[10];
  ADestination[AOffset + 10] := FBytes[09];
  ADestination[AOffset + 11] := FBytes[08];
end;

function TObjectId.ToString: String;
begin
  Result := goToHexString(ToByteArray);
end;

class function TObjectId.TryParse(const AString: String;
  out AObjectId: TObjectId): Boolean;
var
  Bytes: TBytes;
begin
  Result := (Length(AString) = 24) and goTryParseHexString(AString, Bytes);
  if (Result) then
    AObjectId := TObjectId.Create(Bytes)
  else
    AObjectId := Default(TObjectId);
end;

class function TObjectId.Create(const ATimestamp: TDateTime;
  const ATimestampIsUTC: Boolean; const AMachine: Integer; const APid: UInt16;
  const AIncrement: Integer): TObjectId;
begin
  Result := Create(GetTimestampFromDateTime(ATimestamp, ATimestampIsUTC),
    AMachine, APId, AIncrement);
end;

class function TObjectId.Create(const AString: String): TObjectId;
var
  Bytes: TBytes;
begin
  if (Length(AString) <> 24) then
    raise EArgumentException.CreateRes(@SArgumentOutOfRange);
  Bytes := goParseHexString(AString);
  Result.FromByteArray(Bytes);
end;

function TObjectId.CompareTo(const AOther: TObjectId): Integer;
begin
  if (FData[0] < AOther.FData[0]) then
    Exit(-1);
  if (FData[0] > AOther.FData[0]) then
    Exit(1);

  if (FData[1] < AOther.FData[1]) then
    Exit(-1);
  if (FData[1] > AOther.FData[1]) then
    Exit(1);

  if (FData[2] < AOther.FData[2]) then
    Exit(-1);
  if (FData[2] > AOther.FData[2]) then
    Exit(1);

  Result := 0;
end;

class function TObjectId.Empty: TObjectId;
begin
  FillChar(Result, SizeOf(Result), 0);
end;

class operator TObjectId.Equal(const A, B: TObjectId): Boolean;
begin
  Result := (A.FData[0] = B.FData[0])
        and (A.FData[1] = B.FData[1])
        and (A.FData[2] = B.FData[2])
end;

class constructor TObjectId.Create;
begin
  FInitialized := False;
end;

{ TBsonValue }

function TBsonValue.AsArray: TArray<TBsonValue>;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsArray;
end;

function TBsonValue.AsBoolean: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsBoolean;
end;

function TBsonValue.AsByteArray: TBytes;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsByteArray;
end;

function TBsonValue.AsDouble: Double;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsDouble;
end;

function TBsonValue.AsGuid: TGUID;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsGuid;
end;

function TBsonValue.AsInt64: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsInt64;
end;

function TBsonValue.AsInteger: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsInteger;
end;

function TBsonValue.AsObjectId: TObjectId;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsObjectId;
end;

function TBsonValue.AsString: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsString;
end;

function TBsonValue.Clone: TBsonValue;
begin
  Assert(Assigned(FImpl));
  Result.FImpl := FImpl.Clone;
end;

function TBsonValue.DeepClone: TBsonValue;
begin
  Assert(Assigned(FImpl));
  Result.FImpl := FImpl.DeepClone;
end;

class operator TBsonValue.Equal(const A, B: TBsonValue): Boolean;
begin
  if (A.FImpl = nil) then
    Result := (B.FImpl = nil)
  else if (B.FImpl = nil) then
    Result := False
  else
    Result := A.FImpl.Equals(B.FImpl);
end;

function TBsonValue.GetBsonType: TBsonType;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.BsonType;
end;

function TBsonValue.GetIsBoolean: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Boolean);
end;

function TBsonValue.GetIsBsonArray: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.&Array);
end;

function TBsonValue.GetIsBsonBinaryData: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Binary);
end;

function TBsonValue.GetIsBsonDateTime: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.DateTime);
end;

function TBsonValue.GetIsBsonDocument: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Document);
end;

function TBsonValue.GetIsBsonJavaScript: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType in [TBsonType.JavaScript, TBsonType.JavaScriptWithScope]);
end;

function TBsonValue.GetIsBsonJavaScriptWithScope: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.JavaScriptWithScope);
end;

function TBsonValue.GetIsBsonMaxKey: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.MaxKey);
end;

function TBsonValue.GetIsBsonMinKey: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.MinKey);
end;

function TBsonValue.GetIsBsonNull: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Null);
end;

function TBsonValue.GetIsBsonRegularExpression: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.RegularExpression);
end;

function TBsonValue.GetIsBsonSymbol: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Symbol);
end;

function TBsonValue.GetIsBsonTimestamp: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Timestamp);
end;

function TBsonValue.GetIsBsonUndefined: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Undefined);
end;

function TBsonValue.GetIsDateTime: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.DateTime);
end;

function TBsonValue.GetIsDouble: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Double);
end;

function TBsonValue.GetIsGuid: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Binary)
    and (AsBsonBinaryData.SubType in [TBsonBinarySubType.UuidLegacy, TBsonBinarySubType.UuidStandard]);
end;

function TBsonValue.GetIsInt32: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Int32);
end;

function TBsonValue.GetIsInt64: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.Int64);
end;

function TBsonValue.GetIsNumeric: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType in [TBsonType.Int32, TBsonType.Int64, TBsonType.Double]);
end;

function TBsonValue.GetIsObjectId: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.ObjectId);
end;

function TBsonValue.GetIsString: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := (FImpl.BsonType = TBsonType.String);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Int64;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInt64(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Double;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Boolean;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToBoolean(False);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Integer;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Extended;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): TBytes;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToByteArray;
end;

class operator TBsonValue.Implicit(const A: TBsonValue): TGUID;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToGuid;
end;

class operator TBsonValue.Implicit(const A: TBsonValue): TDateTime;
begin
  Assert(Assigned(A.FImpl));
  Result := A.ToUniversalTime;
end;

class operator TBsonValue.Implicit(const A: TBsonValue): String;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToString('');
end;

class operator TBsonValue.Implicit(const A: TBsonValue): TObjectId;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToObjectId;
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Single;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToDouble(0);
end;

class operator TBsonValue.Implicit(const A: Single): TBsonValue;
begin
  if (not A.IsNan) and (A = 0) then
    Result.FImpl := TValueDoubleZero.FValue
  else
    Result.FImpl := TValueDouble.Create(A);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): UInt32;
begin
  Assert(Assigned(A.FImpl));
  Result := UInt32(A.FImpl.ToInteger(0));
end;

class operator TBsonValue.Implicit(const A: UInt32): TBsonValue;
begin
  if (A <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueIntegerConst.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInteger.Create(Int32(A));
end;

class operator TBsonValue.Implicit(const A: TBsonValue): UInt16;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Int16;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): UInt8;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): Int8;
begin
  Assert(Assigned(A.FImpl));
  Result := A.FImpl.ToInteger(0);
end;

class operator TBsonValue.Implicit(const A: UInt64): TBsonValue;
begin
  if (A <= TValueInt64Const.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueInt64Const.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInt64.Create(A);
end;

class operator TBsonValue.Implicit(const A: TBsonValue): UInt64;
begin
  Assert(Assigned(A.FImpl));
  Result := UInt64(A.FImpl.ToInt64(0));
end;

function TBsonValue.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TBsonValue.Load(const ABson: TBytes): TBsonValue;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Create(ABson);
  Result := Reader.ReadValue;
end;

class function TBsonValue.LoadFromBsonFile(
  const AFilename: String): TBsonValue;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AFilename);
  Result := Reader.ReadValue;
end;

class function TBsonValue.LoadFromBsonStream(
  const AStream: TStream): TBsonValue;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AStream);
  Result := Reader.ReadValue;
end;

class function TBsonValue.LoadFromJsonFile(
  const AFilename: String): TBsonValue;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AFilename);
  Result := Reader.ReadValue;
end;

class function TBsonValue.LoadFromJsonStream(
  const AStream: TStream): TBsonValue;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AStream);
  Result := Reader.ReadValue;
end;

class operator TBsonValue.Implicit(const A: Boolean): TBsonValue;
begin
  if (A) then
    Result.FImpl := TValueTrue.FValue
  else
    Result.FImpl := TValueFalse.FValue;
end;

class operator TBsonValue.Implicit(const A: Double): TBsonValue;
begin
  if (not A.IsNan) and (A = 0) then
    Result.FImpl := TValueDoubleZero.FValue
  else
    Result.FImpl := TValueDouble.Create(A);
end;

class operator TBsonValue.Implicit(const A: Integer): TBsonValue;
begin
  if (A >= TValueIntegerConst.MIN_PRECREATED_VALUE) and (A <= TValueIntegerConst.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueIntegerConst.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInteger.Create(A);
end;

class operator TBsonValue.Implicit(const A: Int64): TBsonValue;
begin
  if (A >= TValueInt64Const.MIN_PRECREATED_VALUE) and (A <= TValueInt64Const.MAX_PRECREATED_VALUE) then
    Result.FImpl := TValueInt64Const.FPrecreatedValues[A]
  else
    Result.FImpl := TValueInt64.Create(A);
end;

class operator TBsonValue.Implicit(const A: String): TBsonValue;
begin
  if (A = '') then
    Result.FImpl := TValueStringEmpty.FValue
  else if (StringRefCount(A) < 0) then
    Result.FImpl := TValueStringConstant.Create(A)
  else
    Result.FImpl := TValueString.Create(A);
end;

class operator TBsonValue.Implicit(const A: TBytes): TBsonValue;
begin
  Result.FImpl := TValueBinaryData.Create(A);
end;

class operator TBsonValue.Implicit(const A: Extended): TBsonValue;
var
  D: Double;
begin
  D := A;
  Result := D;
end;

class operator TBsonValue.Implicit(const A: TDateTime): TBsonValue;
begin
  Result.FImpl := TValueDateTime.Create(A, True);
end;

class operator TBsonValue.Implicit(const A: TGUID): TBsonValue;
begin
  Result.FImpl := TValueBinaryData.Create(A);
end;

class operator TBsonValue.Implicit(const A: TObjectId): TBsonValue;
begin
  Result.FImpl := TValueObjectId.Create(A);
end;

class operator TBsonValue.NotEqual(const A, B: TBsonValue): Boolean;
begin
  Result := not (A = B);
end;

class function TBsonValue.Parse(const AJson: String): TBsonValue;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Create(AJson);
  Result := Reader.ReadValue;
end;

procedure TBsonValue.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TBsonValue.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TBsonValue.SaveToJsonFile(const AFilename: String;
  const ASettings: TJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TBsonValue.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TJsonWriterSettings.Default);
end;

procedure TBsonValue.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TJsonWriterSettings.Default);
end;

procedure TBsonValue.SaveToJsonStream(const AStream: TStream;
  const ASettings: TJsonWriterSettings);
var
  Writer: TStreamWriter;
  Json: String;
begin
  Json := ToJson(ASettings);
  Writer := TStreamWriter.Create(AStream);
  try
    Writer.Write(Json);
  finally
    Writer.Free;
  end;
end;

procedure TBsonValue.SetNil;
begin
  FImpl := nil;
end;

function TBsonValue.ToJson: String;
begin
  Result := ToJson(TJsonWriterSettings.Default);
end;

function TBsonValue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToBoolean(ADefault);
end;

function TBsonValue.ToBson: TBytes;
var
  Writer: IBsonWriter;
begin
  Assert(Assigned(FImpl));
  Writer := TBsonWriter.Create;
  Writer.WriteValue(Self);
  Result := Writer.ToBson;
end;

function TBsonValue.ToDouble(const ADefault: Double): Double;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToDouble(ADefault);
end;

function TBsonValue.ToGuid: TGUID;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToGuid;
end;

function TBsonValue.ToInt64(const ADefault: Int64): Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToInt64(ADefault);
end;

function TBsonValue.ToInteger(const ADefault: Integer): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToInteger(ADefault);
end;

function TBsonValue.ToJson(const ASettings: TJsonWriterSettings): String;
var
  Writer: IJsonWriter;
begin
  Assert(Assigned(FImpl));
  Writer := TJsonWriter.Create(ASettings);
  Writer.WriteValue(Self);
  Result := Writer.ToJson;
end;

function TBsonValue.ToLocalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToLocalTime;
end;

function TBsonValue.ToObjectId: TObjectId;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToObjectId;
end;

function TBsonValue.ToString(const ADefault: String): String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToString(ADefault);
end;

function TBsonValue.ToUniversalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToUniversalTime;
end;

class function TBsonValue.TryLoad(const ABson: TBytes;
  out AValue: TBsonValue): Boolean;
var
  Reader: IBsonReader;
begin
  try
    Reader := TBsonReader.Create(ABson);
    AValue := Reader.ReadValue;
    Result := True;
  except
    AValue.FImpl := nil;
    Result := False;
  end;
end;

class function TBsonValue.TryParse(const AJson: String;
  out AValue: TBsonValue): Boolean;
var
  Reader: IJsonReader;
begin
  try
    Reader := TJsonReader.Create(AJson);
    AValue := Reader.ReadValue;
    Result := True;
  except
    AValue.FImpl := nil;
    Result := False;
  end;
end;

{ TBsonValueHelper }

function TBsonValueHelper.AsBsonBinaryData: TBsonBinaryData;
begin
  if (FImpl.QueryInterface(TBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonBinaryData)');
end;

function TBsonValueHelper.AsBsonArray: TBsonArray;
begin
  if (FImpl.QueryInterface(TBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonArray)');
end;

function TBsonValueHelper.AsBsonDateTime: TBsonDateTime;
begin
  if (FImpl.QueryInterface(TBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonDateTime)');
end;

function TBsonValueHelper.AsBsonDocument: TBsonDocument;
begin
  if (FImpl.QueryInterface(TBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonDocument)');
end;

function TBsonValueHelper.AsBsonJavaScript: TBsonJavaScript;
begin
  if (FImpl.QueryInterface(TBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonJavaScript)');
end;

function TBsonValueHelper.AsBsonJavaScriptWithScope: TBsonJavaScriptWithScope;
begin
  if (FImpl.QueryInterface(TBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonJavaScriptWithScope)');
end;

function TBsonValueHelper.AsBsonMaxKey: TBsonMaxKey;
begin
  if (FImpl.QueryInterface(TBsonMaxKey._IMaxKey, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonMaxKey)');
end;

function TBsonValueHelper.AsBsonMinKey: TBsonMinKey;
begin
  if (FImpl.QueryInterface(TBsonMinKey._IMinKey, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonMinKey)');
end;

function TBsonValueHelper.AsBsonNull: TBsonNull;
begin
  if (FImpl.QueryInterface(TBsonNull._INull, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonNull)');
end;

function TBsonValueHelper.AsBsonRegularExpression: TBsonRegularExpression;
begin
  if (FImpl.QueryInterface(TBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonRegularExpression)');
end;

function TBsonValueHelper.AsBsonSymbol: TBsonSymbol;
begin
  if (FImpl.QueryInterface(TBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonSymbol)');
end;

function TBsonValueHelper.AsBsonTimestamp: TBsonTimestamp;
begin
  if (FImpl.QueryInterface(TBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonTimestamp)');
end;

function TBsonValueHelper.AsBsonUndefined: TBsonUndefined;
begin
  if (FImpl.QueryInterface(TBsonUndefined._IUndefined, Result.FValue) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonValue.AsBsonUndefined)');
end;

function TBsonValueHelper.ToBsonArray: TBsonArray;
begin
  if (FImpl.QueryInterface(TBsonArray._IArray, Result.FImpl) <> S_OK) then
    Result := TBsonArray.Create;
end;

function TBsonValueHelper.ToBsonDocument: TBsonDocument;
begin
  if (FImpl.QueryInterface(TBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    Result := TBsonDocument.Create;
end;

{ TBsonArray }

function TBsonArray.Add(const AValue: TBsonValue): TBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AValue.FImpl);
  Result.FImpl := FImpl;
end;

function TBsonArray.AddRange(
  const AValues: array of TBsonValue): TBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

function TBsonArray.AddRange(
  const AValues: TArray<TBsonValue>): TBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

function TBsonArray.AddRange(const AValues: TBsonArray): TBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.AddRange(AValues);
  Result.FImpl := FImpl;
end;

class function TBsonArray.Create(const ACapacity: Integer): TBsonArray;
begin
  Result.FImpl := TValueArray.Create(ACapacity);
end;

class function TBsonArray.Create(const AValues: array of TBsonValue): TBsonArray;
begin
  Result.FImpl := TValueArray.Create(AValues);
end;

function TBsonArray.Clear: TBsonArray;
begin
  Assert(Assigned(FImpl));
  FImpl.Clear;
  Result.FImpl := FImpl;
end;

function TBsonArray.Clone: TBsonArray;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonArray.Clone)');
end;

function TBsonArray.Contains(const AValue: TBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Contains(AValue);
end;

class function TBsonArray.Create(const AValues: TArray<TBsonValue>): TBsonArray;
begin
  Result.FImpl := TValueArray.Create(AValues);
end;

function TBsonArray.DeepClone: TBsonArray;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonArray._IArray, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonArray.DeepClone)');
end;

procedure TBsonArray.Delete(const AIndex: Integer);
begin
  Assert(Assigned(FImpl));
  FImpl.Delete(AIndex);
end;

class operator TBsonArray.Equal(const A, B: TBsonArray): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonArray.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TBsonArray.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FImpl);
end;

function TBsonArray.GetItem(const AIndex: Integer): TBsonValue;
begin
  FImpl.GetItem(AIndex, Result.FImpl);
end;

class operator TBsonArray.Implicit(const A: TBsonArray): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonArray.IndexOf(const AValue: TBsonValue): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.IndexOf(AValue);
end;

function TBsonArray.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TBsonArray.Load(const ABson: TBytes): TBsonArray;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Create(ABson);
  Result := Reader.ReadArray;
end;

class function TBsonArray.LoadFromBsonFile(
  const AFilename: String): TBsonArray;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AFilename);
  Result := Reader.ReadArray;
end;

class function TBsonArray.LoadFromBsonStream(
  const AStream: TStream): TBsonArray;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AStream);
  Result := Reader.ReadArray;
end;

class function TBsonArray.LoadFromJsonFile(
  const AFilename: String): TBsonArray;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AFilename);
  Result := Reader.ReadArray;
end;

class function TBsonArray.LoadFromJsonStream(
  const AStream: TStream): TBsonArray;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AStream);
  Result := Reader.ReadArray;
end;

class operator TBsonArray.NotEqual(const A, B: TBsonArray): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

class function TBsonArray.Parse(const AJson: String): TBsonArray;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Create(AJson);
  Result := Reader.ReadArray;
end;

function TBsonArray.Remove(const AValue: TBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Remove(AValue);
end;

procedure TBsonArray.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TBsonArray.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TBsonArray.SaveToJsonFile(const AFilename: String;
  const ASettings: TJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TBsonArray.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TJsonWriterSettings.Default);
end;

procedure TBsonArray.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TJsonWriterSettings.Default);
end;

procedure TBsonArray.SaveToJsonStream(const AStream: TStream;
  const ASettings: TJsonWriterSettings);
var
  Json: String;
  Writer: TStreamWriter;
begin
  Json := ToJson(ASettings);
  Writer := TStreamWriter.Create(AStream);
  try
    Writer.Write(Json);
  finally
    Writer.Free;
  end;
end;

procedure TBsonArray.SetItem(const AIndex: Integer;
  const AValue: TBsonValue);
begin
  FImpl.SetItem(AIndex, AValue.FImpl);
end;

procedure TBsonArray.SetNil;
begin
  FImpl := nil;
end;

function TBsonArray.ToArray: TArray<TBsonValue>;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsArray;
end;

function TBsonArray.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonArray.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonArray.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

class function TBsonArray.TryLoad(const ABson: TBytes;
  out AArray: TBsonArray): Boolean;
var
  Reader: IBsonReader;
begin
  try
    Reader := TBsonReader.Create(ABson);
    AArray := Reader.ReadArray;
    Result := True;
  except
    AArray.FImpl := nil;
    Result := False;
  end;
end;

class function TBsonArray.TryParse(const AJson: String;
  out AArray: TBsonArray): Boolean;
var
  Reader: IJsonReader;
begin
  try
    Reader := TJsonReader.Create(AJson);
    AArray := Reader.ReadArray;
    Result := True;
  except
    AArray.FImpl := nil;
    Result := False;
  end;
end;

{ TBsonElement }

function TBsonElement.Clone: TBsonElement;
begin
  Result.FName := FName;
  Result.FImpl := FImpl;
end;

class function TBsonElement.Create(const AName: String;
  const AValue: TBsonValue): TBsonElement;
begin
  if (AValue.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  Result.FName := AName;
  Result.FImpl := AValue.FImpl;
end;

function TBsonElement.DeepClone: TBsonElement;
begin
  Result.FName := FName;
  Result.FImpl := FImpl.DeepClone;
end;

class operator TBsonElement.Equal(const A, B: TBsonElement): Boolean;
begin
  Result := (A.FName = B.FName);
  if (Result) then
  begin
    if (A.FImpl = nil) then
      Result := (B.FImpl = nil)
    else if (B.FImpl = nil) then
      Result := False
    else
      Result := A.FImpl.Equals(B.FImpl);
  end;
end;

function TBsonElement.GetValue: TBsonValue;
begin
  Result.FImpl := FImpl;
end;

class operator TBsonElement.NotEqual(const A, B: TBsonElement): Boolean;
begin
  Result := not (A = B);
end;

{ TBsonArray.TEnumerator }

constructor TBsonArray.TEnumerator.Create(const AImpl: _IArray);
begin
  Assert(Assigned(AImpl));
  FImpl := AImpl;
  FHigh := AImpl.Count - 1;
  FIndex := -1;
end;

function TBsonArray.TEnumerator.GetCurrent: TBsonValue;
begin
  FImpl.GetItem(FIndex, Result.FImpl);
end;

function TBsonArray.TEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < FHigh);
  if Result then
    Inc(FIndex);
end;

{ TBsonDocument }

function TBsonDocument.Add(const AName: String; const AValue: TBsonValue): TBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AName, AValue.FImpl);
  Result.FImpl := FImpl;
end;

function TBsonDocument.Add(const AElement: TBsonElement): TBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Add(AElement.FName, AElement.FImpl);
  Result.FImpl := FImpl;
end;

procedure TBsonDocument.Clear;
begin
  Assert(Assigned(FImpl));
  FImpl.Clear;
end;

function TBsonDocument.Clone: TBsonDocument;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonDocument.Clone)');
end;

class function TBsonDocument.Create: TBsonDocument;
begin
  Result.FImpl := TValueDocument.Create;
end;

class function TBsonDocument.Create(
  const AElement: TBsonElement): TBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AElement);
end;

class function TBsonDocument.Create(
  const AAllowDuplicateNames: Boolean): TBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AAllowDuplicateNames);
end;

class function TBsonDocument.Create(const AName: String;
  const AValue: TBsonValue): TBsonDocument;
begin
  Result.FImpl := TValueDocument.Create(AName, AValue);
end;

function TBsonDocument.Contains(const AName: String): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Contains(AName);
end;

function TBsonDocument.ContainsValue(const AValue: TBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ContainsValue(AValue);
end;

function TBsonDocument.DeepClone: TBsonDocument;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonDocument._IDocument, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonDocument.DeepClone)');
end;

procedure TBsonDocument.Delete(const AIndex: Integer);
begin
  Assert(Assigned(FImpl));
  FImpl.Delete(AIndex);
end;

class operator TBsonDocument.Equal(const A, B: TBsonDocument): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonDocument.Get(const AName: String;
  const ADefault: TBsonValue): TBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.Get(AName, ADefault.FImpl, Result.FImpl);
end;

function TBsonDocument.GetAllowDuplicateNames: Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AllowDuplicateNames;
end;

function TBsonDocument.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TBsonDocument.GetElement(const AIndex: Integer): TBsonElement;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Elements[AIndex];
end;

function TBsonDocument.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FImpl);
end;

function TBsonDocument.GetValue(const AIndex: Integer): TBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.GetValue(AIndex, Result.FImpl);
end;

function TBsonDocument.GetValueByName(const AName: String): TBsonValue;
begin
  Assert(Assigned(FImpl));
  FImpl.GetValueByName(AName, Result.FImpl);
end;

class operator TBsonDocument.Implicit(const A: TBsonDocument): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonDocument.IndexOfName(const AName: String): Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.IndexOfName(AName);
end;

function TBsonDocument.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class function TBsonDocument.Load(const ABson: TBytes): TBsonDocument;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Create(ABson);
  Result := Reader.ReadDocument;
end;

class function TBsonDocument.LoadFromBsonFile(
  const AFilename: String): TBsonDocument;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AFilename);
  Result := Reader.ReadDocument;
end;

class function TBsonDocument.LoadFromBsonStream(
  const AStream: TStream): TBsonDocument;
var
  Reader: IBsonReader;
begin
  Reader := TBsonReader.Load(AStream);
  Result := Reader.ReadDocument;
end;

class function TBsonDocument.LoadFromJsonFile(
  const AFilename: String): TBsonDocument;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AFilename);
  Result := Reader.ReadDocument;
end;

class function TBsonDocument.LoadFromJsonStream(
  const AStream: TStream): TBsonDocument;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Load(AStream);
  Result := Reader.ReadDocument;
end;

function TBsonDocument.Merge(const AOtherDocument: TBsonDocument;
  const AOverwriteExistingElements: Boolean): TBsonDocument;
begin
  Assert(Assigned(FImpl));
  FImpl.Merge(AOtherDocument, AOverwriteExistingElements);
  Result.FImpl := FImpl;
end;

class operator TBsonDocument.NotEqual(const A, B: TBsonDocument): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

class function TBsonDocument.Parse(const AJson: String; AllowDuplicateNames : Boolean = false): TBsonDocument;
var
  Reader: IJsonReader;
begin
  Reader := TJsonReader.Create(AJson, AllowDuplicateNames);
  Result := Reader.ReadDocument;
end;

procedure TBsonDocument.Remove(const AName: String);
begin
  Assert(Assigned(FImpl));
  FImpl.Remove(AName);
end;

procedure TBsonDocument.SaveToBsonFile(const AFilename: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToBsonStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TBsonDocument.SaveToBsonStream(const AStream: TStream);
var
  Bson: TBytes;
begin
  Bson := ToBson;
  AStream.Write(Bson, Length(Bson));
end;

procedure TBsonDocument.SaveToJsonFile(const AFilename: String;
  const ASettings: TJsonWriterSettings);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFilename, fmCreate);
  try
    SaveToJsonStream(Stream, ASettings);
  finally
    Stream.Free;
  end;
end;

procedure TBsonDocument.SaveToJsonFile(const AFilename: String);
begin
  SaveToJsonFile(AFilename, TJsonWriterSettings.Default);
end;

procedure TBsonDocument.SaveToJsonStream(const AStream: TStream);
begin
  SaveToJsonStream(AStream, TJsonWriterSettings.Default);
end;

procedure TBsonDocument.SaveToJsonStream(const AStream: TStream;
  const ASettings: TJsonWriterSettings);
var
  Writer: TStreamWriter;
  Json: String;
begin
  Json := ToJson(ASettings);
  Writer := TStreamWriter.Create(AStream);
  try
    Writer.Write(Json);
  finally
    Writer.Free;
  end;
end;

procedure TBsonDocument.SetAllowDuplicateNames(const AValue: Boolean);
begin
  Assert(Assigned(FImpl));
  FImpl.AllowDuplicateNames := AValue;
end;

procedure TBsonDocument.SetNil;
begin
  FImpl := nil;
end;

procedure TBsonDocument.SetValue(const AIndex: Integer;
  const AValue: TBsonValue);
begin
  Assert(Assigned(FImpl));
  FImpl.SetValue(AIndex, AValue.FImpl);
end;

procedure TBsonDocument.SetValueByName(const AName: String;
  const AValue: TBsonValue);
begin
  Assert(Assigned(FImpl));
  FImpl.SetValueByName(AName, AValue.FImpl);
end;

function TBsonDocument.ToArray: TArray<TBsonElement>;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToArray;
end;

function TBsonDocument.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonDocument.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonDocument.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

function TBsonDocument.TryGetElement(const AName: String;
  out AElement: TBsonElement): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.TryGetElement(AName, AElement);
end;

function TBsonDocument.TryGetValue(const AName: String;
  out AValue: TBsonValue): Boolean;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.TryGetValue(AName, AValue.FImpl);
end;

class function TBsonDocument.TryLoad(const ABson: TBytes;
  out ADocument: TBsonDocument): Boolean;
var
  Reader: IBsonReader;
begin
  try
    Reader := TBsonReader.Create(ABson);
    ADocument := Reader.ReadDocument;
    Result := True;
  except
    ADocument.FImpl := nil;
    Result := False;
  end;
end;

class function TBsonDocument.TryParse(const AJson: String;
  out ADocument: TBsonDocument; AllowDuplicateNames : Boolean = false): Boolean;
var
  Reader: IJsonReader;
begin
  try
    Reader := TJsonReader.Create(AJson, AllowDuplicateNames);
    ADocument := Reader.ReadDocument;
    Result := True;
  except
    ADocument.FImpl := nil;
    Result := False;
  end;
end;

{ TBsonDocument.TEnumerator }

constructor TBsonDocument.TEnumerator.Create(const AImpl: _IDocument);
begin
  Assert(Assigned(AImpl));
  FImpl := AImpl;
  FHigh := AImpl.Count - 1;
  FIndex := -1;
end;

function TBsonDocument.TEnumerator.GetCurrent: TBsonElement;
begin
  Result := FImpl.Elements[FIndex];
end;

function TBsonDocument.TEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < FHigh);
  if Result then
    Inc(FIndex);
end;

{ TBsonBinaryData }

function TBsonBinaryData.Clone: TBsonBinaryData;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonBinaryData.Clone)');
end;

class function TBsonBinaryData.Create: TBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create;
end;

class function TBsonBinaryData.Create(const AData: TBytes): TBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create(AData);
end;

class function TBsonBinaryData.Create(const AData: TBytes;
  const ASubType: TBsonBinarySubType): TBsonBinaryData;
begin
  Result.FImpl := TValueBinaryData.Create(AData, ASubType);
end;

function TBsonBinaryData.DeepClone: TBsonBinaryData;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonBinaryData._IBinaryData, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonArray.TBsonBinaryData)');
end;

class operator TBsonBinaryData.Equal(const A, B: TBsonBinaryData): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonBinaryData.GetAsBytes: TBytes;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.AsBytes;
end;

function TBsonBinaryData.GetByte(const AIndex: Integer): Byte;
begin
  Result := FImpl[AIndex];
end;

function TBsonBinaryData.GetCount: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Count;
end;

function TBsonBinaryData.GetSubType: TBsonBinarySubType;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.SubType;
end;

class operator TBsonBinaryData.Implicit(
  const A: TBsonBinaryData): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonBinaryData.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonBinaryData.NotEqual(const A,
  B: TBsonBinaryData): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonBinaryData.SetByte(const AIndex: Integer; const AValue: Byte);
begin
  FImpl[AIndex] := AValue;
end;

procedure TBsonBinaryData.SetNil;
begin
  FImpl := nil;
end;

function TBsonBinaryData.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonBinaryData.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonBinaryData.ToJson(
  const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonNull }

function TBsonNull.Clone: TBsonNull;
begin
  Result := FImpl;
end;

class constructor TBsonNull.Create;
begin
  FImpl.FValue := _INull(@VALUE_NULL);
end;

function TBsonNull.DeepClone: TBsonNull;
begin
  Result := FImpl;
end;

class operator TBsonNull.Equal(const A, B: TBsonNull): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

class operator TBsonNull.Implicit(const A: TBsonNull): TBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TBsonNull.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class operator TBsonNull.NotEqual(const A, B: TBsonNull): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

function TBsonNull.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonNull.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonNull.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonUndefined }

function TBsonUndefined.Clone: TBsonUndefined;
begin
  Result := FImpl;
end;

class constructor TBsonUndefined.Create;
begin
  FImpl.FValue := _IUndefined(@VALUE_UNDEFINED);
end;

function TBsonUndefined.DeepClone: TBsonUndefined;
begin
  Result := FImpl;
end;

class operator TBsonUndefined.Equal(const A, B: TBsonUndefined): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

class operator TBsonUndefined.Implicit(const A: TBsonUndefined): TBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TBsonUndefined.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class operator TBsonUndefined.NotEqual(const A, B: TBsonUndefined): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

function TBsonUndefined.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonUndefined.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonUndefined.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonRegularExpression }

function TBsonRegularExpression.Clone: TBsonRegularExpression;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonRegularExpression.Clone)');
end;

class function TBsonRegularExpression.Create(const APattern,
  AOptions: String): TBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(APattern, AOptions);
end;

class function TBsonRegularExpression.Create(
  const APattern: String): TBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(APattern);
end;

function TBsonRegularExpression.DeepClone: TBsonRegularExpression;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonRegularExpression._IRegularExpression, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonRegularExpression.DeepClone)');
end;

class operator TBsonRegularExpression.Equal(const A,
  B: TBsonRegularExpression): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonRegularExpression.GetOptions: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Options;
end;

function TBsonRegularExpression.GetPattern: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Pattern;
end;

class operator TBsonRegularExpression.Implicit(
  const A: TBsonRegularExpression): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

class operator TBsonRegularExpression.Implicit(const A: String): TBsonRegularExpression;
begin
  Result.FImpl := TValueRegularExpression.Create(A);
end;

function TBsonRegularExpression.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonRegularExpression.NotEqual(const A,
  B: TBsonRegularExpression): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonRegularExpression.SetNil;
begin
  FImpl := nil;
end;

function TBsonRegularExpression.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonRegularExpression.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonRegularExpression.ToJson(
  const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonJavaScript }

function TBsonJavaScript.Clone: TBsonJavaScript;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonJavaScript.Clone)');
end;

class function TBsonJavaScript.Create(const ACode: String): TBsonJavaScript;
begin
  Result.FImpl := TValueJavaScript.Create(ACode);
end;

function TBsonJavaScript.DeepClone: TBsonJavaScript;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonJavaScript._IJavaScript, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonJavaScript.DeepClone)');
end;

class operator TBsonJavaScript.Equal(const A, B: TBsonJavaScript): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonJavaScript.GetCode: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Code;
end;

class operator TBsonJavaScript.Implicit(
  const A: TBsonJavaScript): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonJavaScript.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonJavaScript.NotEqual(const A,
  B: TBsonJavaScript): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonJavaScript.SetNil;
begin
  FImpl := nil;
end;

function TBsonJavaScript.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonJavaScript.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonJavaScript.ToJson(
  const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonJavaScriptWithScope }

function TBsonJavaScriptWithScope.Clone: TBsonJavaScriptWithScope;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonJavaScriptWithScope.Clone)');
end;

class function TBsonJavaScriptWithScope.Create(const ACode: String;
  const AScope: TBsonDocument): TBsonJavaScriptWithScope;
begin
  Result.FImpl := TValueJavaScriptWithScope.Create(ACode, AScope);
end;

function TBsonJavaScriptWithScope.DeepClone: TBsonJavaScriptWithScope;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonJavaScriptWithScope._IJavaScriptWithScope, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonJavaScriptWithScope.DeepClone)');
end;

class operator TBsonJavaScriptWithScope.Equal(const A,
  B: TBsonJavaScriptWithScope): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonJavaScriptWithScope.GetCode: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Code;
end;

function TBsonJavaScriptWithScope.GetScope: TBsonDocument;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Scope;
end;

class operator TBsonJavaScriptWithScope.Implicit(
  const A: TBsonJavaScriptWithScope): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonJavaScriptWithScope.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonJavaScriptWithScope.NotEqual(const A,
  B: TBsonJavaScriptWithScope): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonJavaScriptWithScope.SetNil;
begin
  FImpl := nil;
end;

function TBsonJavaScriptWithScope.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonJavaScriptWithScope.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonJavaScriptWithScope.ToJson(
  const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonSymbol }

function TBsonSymbol.Clone: TBsonSymbol;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonSymbol.Clone)');
end;

function TBsonSymbol.DeepClone: TBsonSymbol;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonSymbol._ISymbol, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonSymbol.DeepClone)');
end;

class operator TBsonSymbol.Equal(const A, B: TBsonSymbol): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonSymbol.GetName: String;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Name;
end;

class operator TBsonSymbol.Implicit(const A: TBsonSymbol): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonSymbol.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonSymbol.NotEqual(const A, B: TBsonSymbol): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonSymbol.SetNil;
begin
  FImpl := nil;
end;

function TBsonSymbol.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonSymbol.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonSymbol.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonSymbolTable }

class constructor TBsonSymbolTable.Create;
begin
  FTable := TDictionary<String, TBsonSymbol>.Create;
  FLock := TCriticalSection.Create;
end;

class destructor TBsonSymbolTable.Destroy;
begin
  FreeAndNil(FTable);
  FreeAndNil(FLock);
end;

class function TBsonSymbolTable.Lookup(const AName: String): TBsonSymbol;
begin
  FLock.Enter;
  try
    if (not FTable.TryGetValue(AName, Result)) then
    begin
      Result.FImpl := TValueSymbol.Create(AName);
      FTable.Add(AName, Result);
    end;
  finally
    FLock.Leave;
  end;
end;

{ TBsonDateTime }

function TBsonDateTime.Clone: TBsonDateTime;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonDateTime.Clone)');
end;

class function TBsonDateTime.Create(const ADateTime: TDateTime;
  const ADateTimeIsUTC: Boolean): TBsonDateTime;
begin
  Result.FImpl := TValueDateTime.Create(ADateTime, ADateTimeIsUTC);
end;

class function TBsonDateTime.Create(
  const AMillisecondsSinceEpoch: Int64): TBsonDateTime;
begin
  Result.FImpl := TValueDateTime.Create(AMillisecondsSinceEpoch);
end;

function TBsonDateTime.DeepClone: TBsonDateTime;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonDateTime._IDateTime, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonDateTime.DeepClone)');
end;

class operator TBsonDateTime.Equal(const A, B: TBsonDateTime): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonDateTime.GetMillisecondsSinceEpoch: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.MillisecondsSinceEpoch;
end;

class operator TBsonDateTime.Implicit(const A: TBsonDateTime): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonDateTime.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonDateTime.NotEqual(const A, B: TBsonDateTime): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonDateTime.SetNil;
begin
  FImpl := nil;
end;

function TBsonDateTime.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonDateTime.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonDateTime.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

function TBsonDateTime.ToLocalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToLocalTime;
end;

function TBsonDateTime.ToUniversalTime: TDateTime;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.ToUniversalTime;
end;

{ TBsonTimestamp }

class function TBsonTimestamp.Create(const AValue: Int64): TBsonTimestamp;
begin
  Result.FImpl := TValueTimestamp.Create(AValue);
end;

function TBsonTimestamp.Clone: TBsonTimestamp;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.Clone;
  if (C.QueryInterface(TBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonTimestamp.Clone)');
end;

class function TBsonTimestamp.Create(const ATimestamp, AIncrement: Integer): TBsonTimestamp;
begin
  Result.FImpl := TValueTimestamp.Create(ATimestamp, AIncrement);
end;

function TBsonTimestamp.DeepClone: TBsonTimestamp;
var
  C: TBsonValue._IValue;
begin
  Assert(Assigned(FImpl));
  C := FImpl.DeepClone;
  if (C.QueryInterface(TBsonTimestamp._ITimestamp, Result.FImpl) <> S_OK) then
    raise EIntfCastError.Create('Invalid cast (TBsonTimestamp.DeepClone)');
end;

class operator TBsonTimestamp.Equal(const A, B: TBsonTimestamp): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

function TBsonTimestamp.GetIncrement: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Increment;
end;

function TBsonTimestamp.GetTimestamp: Integer;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Timestamp;
end;

function TBsonTimestamp.GetValue: Int64;
begin
  Assert(Assigned(FImpl));
  Result := FImpl.Value;
end;

class operator TBsonTimestamp.Implicit(
  const A: TBsonTimestamp): TBsonValue;
begin
  Result.FImpl := A.FImpl;
end;

function TBsonTimestamp.IsNil: Boolean;
begin
  Result := (FImpl = nil);
end;

class operator TBsonTimestamp.NotEqual(const A, B: TBsonTimestamp): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

procedure TBsonTimestamp.SetNil;
begin
  FImpl := nil;
end;

function TBsonTimestamp.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonTimestamp.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonTimestamp.ToJson(
  const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonMaxKey }

function TBsonMaxKey.Clone: TBsonMaxKey;
begin
  Result := FImpl;
end;

class constructor TBsonMaxKey.Create;
begin
  FImpl.FValue := _IMaxKey(@VALUE_MAX_KEY);
end;

function TBsonMaxKey.DeepClone: TBsonMaxKey;
begin
  Result := FImpl;
end;

class operator TBsonMaxKey.Equal(const A, B: TBsonMaxKey): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

class operator TBsonMaxKey.Implicit(const A: TBsonMaxKey): TBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TBsonMaxKey.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class operator TBsonMaxKey.NotEqual(const A, B: TBsonMaxKey): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

function TBsonMaxKey.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonMaxKey.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonMaxKey.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TBsonMinKey }

function TBsonMinKey.Clone: TBsonMinKey;
begin
  Result := FImpl;
end;

class constructor TBsonMinKey.Create;
begin
  FImpl.FValue := _IMinKey(@VALUE_MIN_KEY);
end;

function TBsonMinKey.DeepClone: TBsonMinKey;
begin
  Result := FImpl;
end;

class operator TBsonMinKey.Equal(const A, B: TBsonMinKey): Boolean;
begin
  Result := (TBsonValue(A) = TBsonValue(B));
end;

class operator TBsonMinKey.Implicit(const A: TBsonMinKey): TBsonValue;
begin
  Result.FImpl := A.FValue;
end;

function TBsonMinKey.IsNil: Boolean;
begin
  Result := (FValue = nil);
end;

class operator TBsonMinKey.NotEqual(const A, B: TBsonMinKey): Boolean;
begin
  Result := (TBsonValue(A) <> TBsonValue(B));
end;

function TBsonMinKey.ToBson: TBytes;
begin
  Result := TBsonValue(Self).ToBson;
end;

function TBsonMinKey.ToJson: String;
begin
  Result := TBsonValue(Self).ToJson;
end;

function TBsonMinKey.ToJson(const ASettings: TJsonWriterSettings): String;
begin
  Result := TBsonValue(Self).ToJson(ASettings);
end;

{ TNonRefCountedInterface }

function TNonRefCountedInterface.Addref: Integer;
begin
  Result := -1;
end;

function TNonRefCountedInterface.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;
end;

function TNonRefCountedInterface.Release: Integer;
begin
  Result := -1;
end;

{ TRefCountedInterface }

function TRefCountedInterface.Addref: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;

function TRefCountedInterface.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  Result := E_NOINTERFACE;
end;

function TRefCountedInterface.Release: Integer;
begin
  Result := AtomicDecrement(FRefCount);
  if (Result = 0) then
    FreeMem(@Self);
end;

{ TValue }

function TValue.AsArray: TArray<TBsonValue>;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsBoolean: Boolean;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsByteArray: TBytes;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsDouble: Double;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsGuid: TGUID;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsInt64: Int64;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsInteger: Integer;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsObjectId: TObjectId;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.AsString: String;
begin
  raise EIntfCastError.Create('Invalid cast');
end;

function TValue.Clone: TBsonValue._IValue;
begin
  Result := TBsonValue._IValue(@Self);
end;

function TValue.DeepClone: TBsonValue._IValue;
begin
  Result := TBsonValue._IValue(@Self);
end;

function TValue.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  This, Other: TBsonValue;
begin
  This.FImpl := TBsonValue._IValue(@Self);
  Other.FImpl := AOther;
  Result := (This = Other);
end;

function TValue.GetBsonType: TBsonType;
begin
  raise EAbstractError.CreateRes(@SAbstractError);
end;

function TValue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := ADefault;
end;

function TValue.ToByteArray: TBytes;
begin
  Result := nil;
end;

function TValue.ToDouble(const ADefault: Double): Double;
begin
  Result := ADefault;
end;

function TValue.ToGuid: TGUID;
begin
  Result := TGUID.Empty;
end;

function TValue.ToInt64(const ADefault: Int64): Int64;
begin
  Result := ADefault;
end;

function TValue.ToInteger(const ADefault: Integer): Integer;
begin
  Result := ADefault;
end;

function TValue.ToLocalTime: TDateTime;
begin
  Result := 0;
end;

function TValue.ToObjectId: TObjectId;
begin
  Result := TObjectId.Empty;
end;

function TValue.ToString(const ADefault: String): String;
begin
  Result := ADefault;
end;

function TValue.ToUniversalTime: TDateTime;
begin
  Result := 0;
end;

{ TValueFalse }

function TValueFalse.AsBoolean: Boolean;
begin
  Result := False;
end;

class constructor TValueFalse.Create;
begin
  FValue := TBsonValue._IValue(@VALUE_BOOLEAN_FALSE);
end;

function TValueFalse.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.Boolean) then
    Result := (not AOther.AsBoolean)
  else
    Result := False;
end;

function TValueFalse.GetBsonType: TBsonType;
begin
  Result := TBsonType.Boolean;
end;

function TValueFalse.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueFalse.ToDouble(const ADefault: Double): Double;
begin
  Result := 0;
end;

function TValueFalse.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 0;
end;

function TValueFalse.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 0;
end;

function TValueFalse.ToString(const ADefault: String): String;
begin
  Result := 'false';
end;

{ TValueTrue }

function TValueTrue.AsBoolean: Boolean;
begin
  Result := True;
end;

class constructor TValueTrue.Create;
begin
  FValue := TBsonValue._IValue(@VALUE_BOOLEAN_TRUE);
end;

function TValueTrue.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.Boolean) then
    Result := AOther.AsBoolean
  else
    Result := False;
end;

function TValueTrue.GetBsonType: TBsonType;
begin
  Result := TBsonType.Boolean;
end;

function TValueTrue.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueTrue.ToDouble(const ADefault: Double): Double;
begin
  Result := 1;
end;

function TValueTrue.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 1;
end;

function TValueTrue.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 1;
end;

function TValueTrue.ToString(const ADefault: String): String;
begin
  Result := 'true';
end;

{ TValueInteger }

function TValueInteger.AsInteger: Integer;
begin
  Result := FValue;
end;

class function TValueInteger.Create(const AValue: Integer): TBsonValue._IValue;
var
  V: PValueInteger;
begin
  GetMem(V, SizeOf(TValueInteger));
  V.FBase.FVTable := @VTABLE_INTEGER;
  V.FBase.FRefCount := 0;
  V.FValue := AValue;
  Result := TBsonValue._IValue(V);
end;

function TValueInteger.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInteger.GetBsonType: TBsonType;
begin
  Result := TBsonType.Int32;
end;

function TValueInteger.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInteger.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInteger.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInteger.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInteger.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueIntegerConst }

function TValueIntegerConst.AsInteger: Integer;
begin
  Result := FValue;
end;

class constructor TValueIntegerConst.Create;
var
  I: Integer;
  P: PValueIntegerConst;
begin
  GetMem(FPrecreatedData, ((MAX_PRECREATED_VALUE - MIN_PRECREATED_VALUE) + 1) * SizeOf(TValueIntegerConst));
  P := FPrecreatedData;
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
  begin
    P.FBase.FVTable := @VTABLE_INTEGER_CONST;
    P.FValue := I;
    FPrecreatedValues[I] := TBsonValue._IValue(P);
    Inc(P);
  end;
end;

class destructor TValueIntegerConst.Destroy;
var
  I: Integer;
begin
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
    FPrecreatedValues[I] := nil;
  FreeMem(FPrecreatedData);
  FPrecreatedData := nil;
end;

function TValueIntegerConst.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueIntegerConst.GetBsonType: TBsonType;
begin
  Result := TBsonType.Int32;
end;

function TValueIntegerConst.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueIntegerConst.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueIntegerConst.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueInt64 }

function TValueInt64.AsInt64: Int64;
begin
  Result := FValue;
end;

class function TValueInt64.Create(const AValue: Int64): TBsonValue._IValue;
var
  V: PValueInt64;
begin
  GetMem(V, SizeOf(TValueInt64));
  V.FBase.FVTable := @VTABLE_INT64;
  V.FBase.FRefCount := 0;
  V.FValue := AValue;
  Result := TBsonValue._IValue(V);
end;

function TValueInt64.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInt64.GetBsonType: TBsonType;
begin
  Result := TBsonType.Int64;
end;

function TValueInt64.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInt64.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInt64.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInt64.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInt64.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueInt64Const }

function TValueInt64Const.AsInt64: Int64;
begin
  Result := FValue;
end;

class constructor TValueInt64Const.Create;
var
  I: Integer;
  P: PValueInt64Const;
begin
  GetMem(FPrecreatedData, ((MAX_PRECREATED_VALUE - MIN_PRECREATED_VALUE) + 1) * SizeOf(TValueInt64Const));
  P := FPrecreatedData;
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
  begin
    P.FBase.FVTable := @VTABLE_INT64_CONST;
    P.FValue := I;
    FPrecreatedValues[I] := TBsonValue._IValue(P);
    Inc(P);
  end;
end;

class destructor TValueInt64Const.Destroy;
var
  I: Integer;
begin
  for I := MIN_PRECREATED_VALUE to MAX_PRECREATED_VALUE do
    FPrecreatedValues[I] := nil;
  FreeMem(FPrecreatedData);
  FPrecreatedData := nil;
end;

function TValueInt64Const.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueInt64Const.GetBsonType: TBsonType;
begin
  Result := TBsonType.Int64;
end;

function TValueInt64Const.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0);
end;

function TValueInt64Const.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueInt64Const.ToInt64(const ADefault: Int64): Int64;
begin
  Result := FValue;
end;

function TValueInt64Const.ToInteger(const ADefault: Integer): Integer;
begin
  Result := FValue;
end;

function TValueInt64Const.ToString(const ADefault: String): String;
begin
  Result := IntToStr(FValue);
end;

{ TValueDouble }

function TValueDouble.AsDouble: Double;
begin
  Result := FValue;
end;

class function TValueDouble.Create(const AValue: Double): TBsonValue._IValue;
var
  V: PValueDouble;
begin
  GetMem(V, SizeOf(TValueDouble));
  V.FBase.FVTable := @VTABLE_DOUBLE;
  V.FBase.FRefCount := 0;
  V.FValue := AValue;
  Result := TBsonValue._IValue(V);
end;

function TValueDouble.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (FValue = AOther.AsInteger);

    TBsonType.Int64:
      Result := (FValue = AOther.AsInt64);

    TBsonType.Double:
      Result := (FValue = AOther.AsDouble);
  else
    Result := False;
  end;
end;

function TValueDouble.GetBsonType: TBsonType;
begin
  Result := TBsonType.Double;
end;

function TValueDouble.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := (FValue <> 0) and (not FValue.IsNan);
end;

function TValueDouble.ToDouble(const ADefault: Double): Double;
begin
  Result := FValue;
end;

function TValueDouble.ToInt64(const ADefault: Int64): Int64;
begin
  Result := Trunc(FValue);
end;

function TValueDouble.ToInteger(const ADefault: Integer): Integer;
begin
  Result := Trunc(FValue);
end;

function TValueDouble.ToString(const ADefault: String): String;
begin
  Result := FloatToStr(FValue, goUSFormatSettings);
end;

{ TValueDoubleZero }

function TValueDoubleZero.AsDouble: Double;
begin
  Result := 0;
end;

class constructor TValueDoubleZero.Create;
begin
  FValue := TBsonValue._IValue(@VALUE_DOUBLE_ZERO);
end;

function TValueDoubleZero.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  case AOther.BsonType of
    TBsonType.Int32:
      Result := (AOther.AsInteger = 0);

    TBsonType.Int64:
      Result := (AOther.AsInt64 = 0);

    TBsonType.Double:
      Result := (AOther.AsDouble = 0);
  else
    Result := False;
  end;
end;

function TValueDoubleZero.GetBsonType: TBsonType;
begin
  Result := TBsonType.Double;
end;

function TValueDoubleZero.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueDoubleZero.ToDouble(const ADefault: Double): Double;
begin
  Result := 0;
end;

function TValueDoubleZero.ToInt64(const ADefault: Int64): Int64;
begin
  Result := 0;
end;

function TValueDoubleZero.ToInteger(const ADefault: Integer): Integer;
begin
  Result := 0;
end;

function TValueDoubleZero.ToString(const ADefault: String): String;
begin
  Result := '0';
end;

{ TValueDateTime }

class function TValueDateTime.Create(const ADateTime: TDateTime;
  const ADateTimeIsUTC: Boolean): TBsonDateTime._IDateTime;
begin
  Result := Create(DateTimeToMillisecondsSinceEpoch(ADateTime, ADateTimeIsUTC));
end;

class function TValueDateTime.Create(
  const AMillisecondsSinceEpoch: Int64): TBsonDateTime._IDateTime;
var
  V: PValueDateTime;
begin
  GetMem(V, SizeOf(TValueDateTime));
  V.FBase.FVTable := @VTABLE_DATE_TIME;
  V.FBase.FRefCount := 0;
  V.FMillisecondsSinceEpoch := AMillisecondsSinceEpoch;
  Result := TBsonDateTime._IDateTime(V);
end;

function TValueDateTime.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueDateTime;
begin
  if (AOther.BsonType = TBsonType.DateTime) then
  begin
    Other := PValueDateTime(AOther);
    Result := (FMillisecondsSinceEpoch = Other.FMillisecondsSinceEpoch);
  end
  else
    Result := False;
end;

function TValueDateTime.GetBsonType: TBsonType;
begin
  Result := TBsonType.DateTime;
end;

function TValueDateTime.GetMillisecondsSinceEpoch: Int64;
begin
  Result := FMillisecondsSinceEpoch;
end;

function TValueDateTime.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonDateTime._IDateTime) then
  begin
    TBsonDateTime._IDateTime(Obj) := TBsonDateTime._IDateTime(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueDateTime.ToLocalTime: TDateTime;
begin
  Result := ToDateTimeFromMillisecondsSinceEpoch(FMillisecondsSinceEpoch, False);
end;

function TValueDateTime.ToString(const ADefault: String): String;
begin
  Result := DateToISO8601(ToLocalTime, False);
end;

function TValueDateTime.ToUniversalTime: TDateTime;
begin
  Result := ToDateTimeFromMillisecondsSinceEpoch(FMillisecondsSinceEpoch, True);
end;

{ TValueString }

function TValueString.AsString: String;
begin
  Result := Value;
end;

class function TValueString.Create(const AValue: String): TBsonValue._IValue;
var
  Len: Integer;
  V: PValueString;
begin
  Len := Length(AValue);
  GetMem(V, SizeOf(TValueString) + Len * SizeOf(Char));
  V.FBase.FVTable := @VTABLE_STRING;
  V.FBase.FRefCount := 0;
  V.FLength := Len;
  Result := TBsonValue._IValue(V);
  Inc(V);
  Move(AValue[Low(String)], V^, Len * SizeOf(Char));
end;

function TValueString.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.String) then
    Result := (Value = AOther.AsString)
  else
    Result := False;
end;

function TValueString.GetBsonType: TBsonType;
begin
  Result := TBsonType.String;
end;

function TValueString.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueString.ToDouble(const ADefault: Double): Double;
begin
  Result := StrToFloatDef(Value, ADefault, goUSFormatSettings);
end;

function TValueString.ToInt64(const ADefault: Int64): Int64;
begin
  Result := StrToInt64Def(Value, ADefault);
end;

function TValueString.ToInteger(const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Value, ADefault);
end;

function TValueString.ToString(const ADefault: String): String;
begin
  Result := Value;
end;

function TValueString.Value: String;
begin
  SetString(Result, PChar(PByte(@Self) + SizeOf(TValueString)), FLength);
end;

{ TValueStringEmpty }

function TValueStringEmpty.AsString: String;
begin
  Result := '';
end;

class constructor TValueStringEmpty.Create;
begin
  FValue := TBsonValue._IValue(@VALUE_STRING_EMPTY);
end;

function TValueStringEmpty.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.String) then
    Result := (AOther.AsString = '')
  else
    Result := False;
end;

function TValueStringEmpty.GetBsonType: TBsonType;
begin
  Result := TBsonType.String;
end;

function TValueStringEmpty.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueStringEmpty.ToDouble(const ADefault: Double): Double;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToInt64(const ADefault: Int64): Int64;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToInteger(const ADefault: Integer): Integer;
begin
  Result := ADefault;
end;

function TValueStringEmpty.ToString(const ADefault: String): String;
begin
  Result := '';
end;

{ TValueStringConstant }

function TValueStringConstant.AsString: String;
begin
  Result := Value;
end;

class function TValueStringConstant.Create(const AValue: String): TBsonValue._IValue;
var
  V: PValueStringConstant;
begin
  GetMem(V, SizeOf(TValueStringConstant));
  V.FBase.FVTable := @VTABLE_STRING_CONSTANT;
  V.FBase.FRefCount := 0;
  V.FValue := Pointer(AValue);
  Result := TBsonValue._IValue(V);
end;

function TValueStringConstant.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.String) then
    Result := (Value = AOther.AsString)
  else
    Result := False;
end;

function TValueStringConstant.GetBsonType: TBsonType;
begin
  Result := TBsonType.String;
end;

function TValueStringConstant.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := True;
end;

function TValueStringConstant.ToDouble(const ADefault: Double): Double;
begin
  Result := StrToFloatDef(Value, ADefault, goUSFormatSettings);
end;

function TValueStringConstant.ToInt64(const ADefault: Int64): Int64;
begin
  Result := StrToInt64Def(Value, ADefault);
end;

function TValueStringConstant.ToInteger(const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(Value, ADefault);
end;

function TValueStringConstant.ToString(const ADefault: String): String;
begin
  Result := Value;
end;

function TValueStringConstant.Value: String;
begin
  Result := String(FValue);
end;

{ TValueArray }

procedure TValueArray.Add(const AValue: TBsonValue._IValue);
var
  Capacity: Integer;
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  Capacity := Length(FItems);
  if (FCount >= Capacity) then
  begin
    if (Capacity > 64) then
      Inc(Capacity, Capacity div 4)
    else if (Capacity > 8) then
      Inc(Capacity, 16)
    else
      Inc(Capacity, 4);
    SetLength(FItems, Capacity);
  end;
  FItems[FCount] := AValue;
  Inc(FCount);
end;

procedure TValueArray.AddRangeOpenArray(const AValues: array of TBsonValue);
var
  I: Integer;
begin
  for I := 0 to Length(AValues) - 1 do
    Add(AValues[I].FImpl);
end;

procedure TValueArray.AddRangeGenArray(const AValues: TArray<TBsonValue>);
var
  I: Integer;
begin
  for I := 0 to Length(AValues) - 1 do
    Add(AValues[I].FImpl);
end;

procedure TValueArray.AddRangeBsonArray(const AValues: TBsonArray);
var
  I: Integer;
begin
  if (AValues.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  for I := 0 to AValues.Count - 1 do
    Add(AValues[I].FImpl);
end;

function TValueArray.AsArray: TArray<TBsonValue>;
var
  I: Integer;
begin
  SetLength(Result, FCount);
  for I := 0 to FCount - 1 do
    Result[I].FImpl := FItems[I];
end;

procedure TValueArray.Clear;
begin
  FItems := nil;
  FCount := 0;
end;

function TValueArray.Clone: TBsonValue._IValue;
var
  A: PValueArray;
  I: Integer;
begin
  Result := TValueArray.Create(FCount);
  A := PValueArray(Result);
  for I := 0 to FCount - 1 do
    A.Add(FItems[I]);
end;

function TValueArray.Contains(const AValue: TBsonValue): Boolean;
var
  I: Integer;
  Item: TBsonValue;
begin
  for I := 0 to FCount - 1 do
  begin
    Item.FImpl := FItems[I];
    if (Item = AValue) then
      Exit(True);
  end;
  Result := False;
end;

class function TValueArray.Create(
  const AValues: array of TBsonValue): TBsonArray._IArray;
begin
  Result := Create(Length(AValues));
  Result.AddRange(AValues);
end;

class function TValueArray.Create(
  const ACapacity: Integer): TBsonArray._IArray;
var
  V: PValueArray;
begin
  GetMem(V, SizeOf(TValueArray));
  V.FBase.FVTable := @VTABLE_ARRAY;
  V.FBase.FRefCount := 0;
  Pointer(V.FItems) := nil;
  SetLength(V.FItems, ACapacity);
  V.FCount := 0;
  Result := TBsonArray._IArray(V);
end;

class function TValueArray.Create(
  const AValues: TArray<TBsonValue>): TBsonArray._IArray;
begin
  Result := Create(Length(AValues));
  Result.AddRange(AValues);
end;

function TValueArray.DeepClone: TBsonValue._IValue;
var
  A: PValueArray;
  I: Integer;
begin
  Result := TValueArray.Create(FCount);
  A := PValueArray(Result);
  for I := 0 to FCount - 1 do
    A.Add(FItems[I].DeepClone);
end;

procedure TValueArray.Delete(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  FItems[AIndex] := nil;

  Dec(FCount);
  if (AIndex <> FCount) then
  begin
    Move(FItems[AIndex + 1], FItems[AIndex], (FCount - AIndex) * SizeOf(TBsonValue._IValue));
    FillChar(FItems[FCount], SizeOf(TBsonValue), 0);
  end;
end;

function TValueArray.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: TArray<TBsonValue>;
  Item: TBsonValue;
  I: Integer;
begin
  if (AOther.BsonType = TBsonType.&Array) then
  begin
    Other := AOther.AsArray;
    Result := (FCount = Length(Other));
    if (Result) then
    begin
      for I := 0 to FCount - 1 do
      begin
        Item.FImpl := FItems[I];
        if (Item <> Other[I]) then
          Exit(False);
      end;
    end;
  end
  else
    Result := False;
end;

function TValueArray.GetBsonType: TBsonType;
begin
  Result := TBsonType.&Array;
end;

function TValueArray.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TValueArray.GetItem(const AIndex: Integer;
  out AValue: TBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  AValue := FItems[AIndex];
end;

function TValueArray.IndexOf(const AValue: TBsonValue): Integer;
var
  I: Integer;
  Item: TBsonValue;
begin
  for I := 0 to FCount - 1 do
  begin
    Item.FImpl := FItems[I];
    if (Item = AValue) then
      Exit(I);
  end;
  Result := -1;
end;

function TValueArray.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonArray._IArray) then
  begin
    TBsonArray._IArray(Obj) := TBsonArray._IArray(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueArray.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FItems := nil;
    FreeMem(@Self);
  end;
end;

function TValueArray.Remove(const AValue: TBsonValue): Boolean;
var
  Index: Integer;
begin
  if (AValue.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  Index := IndexOf(AValue);
  Result := (Index >= 0);
  if (Result) then
    Delete(Index);
end;

procedure TValueArray.SetItem(const AIndex: Integer;
  const AValue: TBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= FCount) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  FItems[AIndex] := AValue;
end;

{ TValueBinaryData }

function TValueBinaryData.AsByteArray: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.AsGuid: TGUID;
begin
  case FSubType of
    {$IF CompilerVersion < 28.0}
    TBsonBinarySubType.UuidLegacy:
      Result := TGUID.Create(FValue);

    TBsonBinarySubType.UuidStandard:
      Result := TGUID.Create(FValue);
    {$ELSE}
    TBsonBinarySubType.UuidLegacy:
      Result := TGUID.Create(FValue, TEndian.Little);

    TBsonBinarySubType.UuidStandard:
      Result := TGUID.Create(FValue, TEndian.Big);
    {$IFEND}
  else
    raise EIntfCastError.Create('Invalid cast (AsGuid)');
  end;
end;

class function TValueBinaryData.Create(const AValue: TBytes;
  const ASubType: TBsonBinarySubType): TBsonBinaryData._IBinaryData;
var
  V: PValueBinaryData;
begin
  GetMem(V, SizeOf(TValueBinaryData));
  V.FBase.FVTable := @VTABLE_BINARY_DATA;
  V.FBase.FRefCount := 0;
  Pointer(V.FValue) := nil;
  V.FValue := AValue;
  V.FSubType := ASubType;
  Result := TBsonBinaryData._IBinaryData(V);
end;

class function TValueBinaryData.Create: TBsonBinaryData._IBinaryData;
begin
  Result := Create(nil);
end;

class function TValueBinaryData.Create(
  const AValue: TGUID): TBsonBinaryData._IBinaryData;
begin
  {$IF CompilerVersion < 28.0}
  Result := Create(AValue.ToByteArray(), TBsonBinarySubType.UuidStandard);
  {$ELSE}
  Result := Create(AValue.ToByteArray(TEndian.Big), TBsonBinarySubType.UuidStandard);
  {$IFEND}
end;

function TValueBinaryData.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueBinaryData;
begin
  if (AOther.BsonType = TBsonType.Binary) then
  begin
    Other := PValueBinaryData(AOther);
    Result := (FSubType = Other.FSubType)
      and (Length(FValue) = Length(Other.FValue))
      and (CompareMem(@FValue[0], @Other.FValue[0], Length(FValue)));
  end
  else
    Result := False;
end;

function TValueBinaryData.GetBsonType: TBsonType;
begin
  Result := TBsonType.Binary;
end;

function TValueBinaryData.GetByte(const AIndex: Integer): Byte;
begin
  if (AIndex < 0) or (AIndex >= Length(FValue)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := FValue[AIndex];
end;

function TValueBinaryData.GetAsBytes: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.GetCount: Integer;
begin
  Result := Length(FValue);
end;

function TValueBinaryData.GetSubType: TBsonBinarySubType;
begin
  Result := FSubType;
end;

function TValueBinaryData.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonBinaryData._IBinaryData) then
  begin
    TBsonBinaryData._IBinaryData(Obj) := TBsonBinaryData._IBinaryData(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueBinaryData.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FValue := nil;
    FreeMem(@Self);
  end;
end;

procedure TValueBinaryData.SetByte(const AIndex: Integer; const AValue: Byte);
begin
  if (AIndex < 0) or (AIndex >= Length(FValue)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  FValue[AIndex] := AValue;
end;

function TValueBinaryData.ToByteArray: TBytes;
begin
  Result := FValue;
end;

function TValueBinaryData.ToGuid: TGUID;
begin
  case FSubType of
    {$IF CompilerVersion < 28.0}
    TBsonBinarySubType.UuidLegacy:
      Result := TGUID.Create(FValue);

    TBsonBinarySubType.UuidStandard:
      Result := TGUID.Create(FValue);
    {$ELSE}
    TBsonBinarySubType.UuidLegacy:
      Result := TGUID.Create(FValue, TEndian.Little);

    TBsonBinarySubType.UuidStandard:
      Result := TGUID.Create(FValue, TEndian.Big);
    {$IFEND}
  else
    Result := TGUID.Empty;
  end;
end;

{ TValueDocument }

procedure TValueDocument.Add(const AName: String;
  const AValue: TBsonValue._IValue);
var
  IsDuplicate: Boolean;
  Capacity: Integer;
begin
  IsDuplicate := (IndexOfName(AName) >= 0);
  if (IsDuplicate) and (not FAllowDuplicateNames) then
    raise EInvalidOperation.CreateRes(@SGenericDuplicateItem);

  Capacity := Length(FElements);
  if (FCount >= Capacity) then
  begin
    if (Capacity > 64) then
      Inc(Capacity, Capacity div 4)
    else if (Capacity > 8) then
      Inc(Capacity, 16)
    else
      Inc(Capacity, 4);
    SetLength(FElements, Capacity);
  end;
  FElements[FCount].FName := AName;
  FElements[FCount].FImpl := AValue;
  Inc(FCount);

  if (not IsDuplicate) then
  begin
    if (FIndices = nil) then
      RebuildIndices
    else
      FIndices.Add(AName, FCount - 1);
  end;
end;

procedure TValueDocument.Clear;
begin
  FElements := nil;
  if (FIndices <> nil) then
  begin
    FIndices.Release;
    FIndices := nil;
  end;
  FCount := 0;
end;

function TValueDocument.Clone: TBsonValue._IValue;
var
  D: PValueDocument;
  I: Integer;
begin
  Result := TValueDocument.Create;
  D := PValueDocument(Result);
  for I := 0 to FCount - 1 do
    D.Add(FElements[I].FName, FElements[I].FImpl);
end;

function TValueDocument.Contains(const AName: String): Boolean;
begin
  Result := (IndexOfName(AName) <> -1);
end;

function TValueDocument.ContainsValue(const AValue: TBsonValue): Boolean;
var
  I: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    if (FElements[I].Value = AValue) then
      Exit(True);
  end;
  Result := False;
end;

class function TValueDocument.Create(
  const AAllowDuplicateNames: Boolean): TBsonDocument._IDocument;
var
  V: PValueDocument;
begin
  GetMem(V, SizeOf(TValueDocument));
  V.FBase.FVTable := @VTABLE_DOCUMENT;
  V.FBase.FRefCount := 0;
  V.FAllowDuplicateNames := AAllowDuplicateNames;
  Pointer(V.FElements) := nil;
  Pointer(V.FIndices) := nil;
  V.FCount := 0;
  Result := TBsonDocument._IDocument(V);
end;

class function TValueDocument.Create(
  const AElement: TBsonElement): TBsonDocument._IDocument;
begin
  Result := Create;
  Result.Add(AElement.FName, AElement.FImpl);
end;

class function TValueDocument.Create(const AName: String;
  const AValue: TBsonValue): TBsonDocument._IDocument;
begin
  Result := Create;
  Result.Add(AName, AValue.FImpl);
end;

function TValueDocument.DeepClone: TBsonValue._IValue;
var
  D: PValueDocument;
  I: Integer;
  E: TBsonElement;
begin
  Result := TValueDocument.Create;
  D := PValueDocument(Result);
  for I := 0 to FCount - 1 do
  begin
    E := FElements[I].DeepClone;
    D.Add(E.FName, E.FImpl);
  end;
end;

procedure TValueDocument.Delete(const AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);

  FElements[AIndex] := Default(TBsonElement);

  Dec(FCount);
  if (AIndex <> FCount) then
  begin
    Move(FElements[AIndex + 1], FElements[AIndex], (FCount - AIndex) * SizeOf(TBsonElement));
    FillChar(FElements[FCount], SizeOf(TBsonElement), 0);
  end;
end;

function TValueDocument.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueDocument;
  I: Integer;
begin
  if (AOther.BsonType = TBsonType.Document) then
  begin
    Other := PValueDocument(AOther);
    Result := (FCount = Other.FCount);
    for I := 0 to FCount - 1 do
    begin
      if (FElements[I] <> Other.FElements[I]) then
        Exit(False);
    end;
  end
  else
    Result := False;
end;

procedure TValueDocument.Get(const AName: String;
  const ADefault: TBsonValue._IValue; out AValue: TBsonValue._IValue);
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
    AValue := ADefault
  else
    AValue := FElements[Index].FImpl;
end;

function TValueDocument.GetAllowDuplicateNames: Boolean;
begin
  Result := FAllowDuplicateNames;
end;

function TValueDocument.GetBsonType: TBsonType;
begin
  Result := TBsonType.Document;
end;

function TValueDocument.GetCount: Integer;
begin
  Result := FCount;
end;

function TValueDocument.GetElement(const AIndex: Integer): TBsonElement;
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  Result := FElements[AIndex];
end;

procedure TValueDocument.GetValue(const AIndex: Integer;
  out AValue: TBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  AValue := FElements[AIndex].FImpl;
end;

procedure TValueDocument.GetValueByName(const AName: String;
  out AValue: TBsonValue._IValue);
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
    AValue := TBsonNull.Value._Value
  else
    AValue := FElements[Index].FImpl;
end;

function TValueDocument.IndexOfName(const AName: String): Integer;
var
  I: Integer;
begin
  if (FIndices = nil) then
  begin
    for I := 0 to Length(FElements) - 1 do
    begin
      if (FElements[I].Name = AName) then
        Exit(I);
    end;
    Result := -1;
  end
  else
    Result := FIndices.Get(AName);
end;

procedure TValueDocument.Merge(const AOtherDocument: TBsonDocument;
  const AOverwriteExistingElements: Boolean);
var
  Element: TBsonElement;
begin
  if (AOtherDocument.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  for Element in AOtherDocument do
  begin
    if (AOverwriteExistingElements) or (not Contains(Element.Name)) then
      SetValueByName(Element.Name, Element.FImpl);
  end;
end;

function TValueDocument.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonDocument._IDocument) then
  begin
    TBsonDocument._IDocument(Obj) := TBsonDocument._IDocument(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

procedure TValueDocument.RebuildIndices;
var
  I: Integer;
begin
  if (FCount < INDICES_COUNT_THRESHOLD) then
  begin
    if (FIndices <> nil) then
    begin
      FIndices.Release;
      FIndices := nil;
    end;
    Exit;
  end;

  if (FIndices = nil) then
  begin
    GetMem(FIndices, SizeOf(TIndexMap));
    FillChar(FIndices^, SizeOf(TIndexMap), 0);
  end
  else
    FIndices.Clear;

  { Process the elements in reverse order so that in case of duplicates the
    dictionary ends up pointing at the first one }
  for I := FCount - 1 downto 0 do
    FIndices.Add(FElements[I].Name, I);
end;

function TValueDocument.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FElements := nil;
    if (FIndices <> nil) then
      FIndices.Release;
    FreeMem(@Self);
  end;
end;

procedure TValueDocument.Remove(const AName: String);
var
  RemovedAny: Boolean;
  I: Integer;
begin
  if (FAllowDuplicateNames) then
  begin
    RemovedAny := False;
    for I := FCount - 1 downto 0 do
    begin
      if (FElements[I].Name = AName) then
      begin
        Delete(I);
        RemovedAny := True;
      end;
    end;

    if (RemovedAny) then
      RebuildIndices;
  end
  else
  begin
    I := IndexOfName(AName);
    if (I >= 0) then
    begin
      Delete(I);
      RebuildIndices;
    end;
  end;
end;

procedure TValueDocument.SetAllowDuplicateNames(const AValue: Boolean);
begin
  FAllowDuplicateNames := AValue;
end;

procedure TValueDocument.SetValue(const AIndex: Integer;
  const AValue: TBsonValue._IValue);
begin
  if (AIndex < 0) or (AIndex >= Length(FElements)) then
    raise EArgumentOutOfRangeException.CreateRes(@SArgumentOutOfRange);
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);
  FElements[AIndex].FImpl := AValue;
end;

procedure TValueDocument.SetValueByName(const AName: String;
  const AValue: TBsonValue._IValue);
var
  Index: Integer;
begin
  if (AValue = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  Index := IndexOfName(AName);
  if (Index < 0) then
    Add(AName, AValue)
  else
    FElements[Index].FImpl := AValue;
end;

function TValueDocument.ToArray: TArray<TBsonElement>;
begin
  SetLength(FElements, FCount);
  Result := FElements;
end;

function TValueDocument.TryGetElement(const AName: String;
  out AElement: TBsonElement): Boolean;
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
  begin
    AElement := Default(TBsonElement);
    Result := False;
  end
  else
  begin
    AElement := FElements[Index];
    Result := True;
  end;
end;

function TValueDocument.TryGetValue(const AName: String;
  out AValue: TBsonValue._IValue): Boolean;
var
  Index: Integer;
begin
  Index := IndexOfName(AName);
  if (Index < 0) then
  begin
    AValue := nil;
    Result := False;
  end
  else
  begin
    AValue := FElements[Index].FImpl;
    Result := True;
  end;
end;

{ TValueDocument.TIndexMap }

procedure TValueDocument.TIndexMap.Add(const AName: String;
  const AIndex: Integer);
var
  Mask, Index, HashCode, HC: Integer;
begin
  if (FCount >= FGrowThreshold) then
    Resize(Length(FEntries) * 2);

  HashCode := goMurmurHash2(Pointer(AName)^, Length(AName) * SizeOf(Char)) and $7FFFFFFF;
  Mask := Length(FEntries) - 1;
  Index := HashCode and Mask;

  while True do
  begin
    HC := FEntries[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Break;

    if (HC = HashCode) and (FEntries[Index].Name = AName) then
    begin
      FEntries[Index].Index := AIndex;
      Exit;
    end;

    Index := (Index + 1) and Mask;
  end;

  FEntries[Index].HashCode := HashCode;
  FEntries[Index].Name := AName;
  FEntries[Index].Index := AIndex;
  Inc(FCount);
end;

procedure TValueDocument.TIndexMap.Clear;
begin
  FEntries := nil;
  FCount := 0;
  FGrowThreshold := 0;
end;

function TValueDocument.TIndexMap.Get(const AName: String): Integer;
var
  Mask, Index, HashCode, HC: Integer;
begin
  if (FCount = 0) then
    Exit(-1);

  Mask := Length(FEntries) - 1;
  HashCode := goMurmurHash2(Pointer(AName)^, Length(AName) * SizeOf(Char)) and $7FFFFFFF;
  Index := HashCode and Mask;

  while True do
  begin
    HC := FEntries[Index].HashCode;
    if (HC = EMPTY_HASH) then
      Exit(-1);

    if (HC = HashCode) and (FEntries[Index].Name = AName) then
      Exit(FEntries[Index].Index);

    Index := (Index + 1) and Mask;
  end;
end;

procedure TValueDocument.TIndexMap.Release;
begin
  FEntries := nil;
  FreeMem(@Self);
end;

procedure TValueDocument.TIndexMap.Resize(ANewSize: Integer);
var
  NewMask, I, NewIndex: Integer;
  OldEntries, NewEntries: TMapEntries;
begin
  if (ANewSize < 4) then
    ANewSize := 4;
  NewMask := ANewSize - 1;
  SetLength(NewEntries, ANewSize);
  for I := 0 to ANewSize - 1 do
    NewEntries[I].HashCode := EMPTY_HASH;
  OldEntries := FEntries;

  for I := 0 to Length(OldEntries) - 1 do
  begin
    if (OldEntries[I].HashCode <> EMPTY_HASH) then
    begin
      NewIndex := OldEntries[I].HashCode and NewMask;
      while (NewEntries[NewIndex].HashCode <> EMPTY_HASH) do
        NewIndex := (NewIndex + 1) and NewMask;
      NewEntries[NewIndex] := OldEntries[I];
    end;
  end;

  FEntries := NewEntries;
  FGrowThreshold := (ANewSize * 3) shr 2; // 75%
end;

{ TValueNull }

function TValueNull.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TBsonType.Null);
end;

function TValueNull.GetBsonType: TBsonType;
begin
  Result := TBsonType.Null;
end;

function TValueNull.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonNull._INull) then
  begin
    TBsonNull._INull(Obj) := TBsonNull._INull(@VALUE_NULL);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueNull.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueNull.ToString(const ADefault: String): String;
begin
  Result := 'null';
end;

{ TValueUndefined }

function TValueUndefined.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TBsonType.Undefined);
end;

function TValueUndefined.GetBsonType: TBsonType;
begin
  Result := TBsonType.Undefined;
end;

function TValueUndefined.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonUndefined._IUndefined) then
  begin
    TBsonUndefined._IUndefined(Obj) := TBsonUndefined._IUndefined(@VALUE_UNDEFINED);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueUndefined.ToBoolean(const ADefault: Boolean): Boolean;
begin
  Result := False;
end;

function TValueUndefined.ToString(const ADefault: String): String;
begin
  Result := 'undefined';
end;

{ TValueObjectId }

function TValueObjectId.AsObjectId: TObjectId;
begin
  Result := FValue;
end;

class function TValueObjectId.Create(
  const AValue: TObjectId): TBsonValue._IValue;
var
  V: PValueObjectId;
begin
  GetMem(V, SizeOf(TValueObjectId));
  V.FBase.FVTable := @VTABLE_OBJECT_ID;
  V.FBase.FRefCount := 0;
  V.FValue := AValue;
  Result := TBsonValue._IValue(V);
end;

function TValueObjectId.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  if (AOther.BsonType = TBsonType.ObjectId) then
    Result := (FValue = AOther.AsObjectId)
  else
    Result := False;
end;

function TValueObjectId.GetBsonType: TBsonType;
begin
  Result := TBsonType.ObjectId;
end;

function TValueObjectId.ToObjectId: TObjectId;
begin
  Result := FValue;
end;

function TValueObjectId.ToString(const ADefault: String): String;
begin
  Result := FValue.ToString;
end;

{ TValueRegularExpression }

class function TValueRegularExpression.Create(
  const APattern: String): TBsonRegularExpression._IRegularExpression;
var
  Index: Integer;
  Escaped, Unescaped, Pattern, Options: String;
begin
  if (APattern <> '') and (APattern.Chars[0] = '/') then
  begin
    Index := APattern.LastIndexOf('/');
    Escaped := APattern.Substring(1, Index - 1);
    if (Escaped = '(?:)') then
      Unescaped := ''
    else
      Unescaped := Escaped.Replace('\/', '/', [rfReplaceAll]);
    Pattern := Unescaped;
    Options := APattern.Substring(Index + 1);
  end
  else
  begin
    Pattern := APattern;
    Options := '';
  end;
  Result := Create(Pattern, Options);
end;

class function TValueRegularExpression.Create(const APattern,
  AOptions: String): TBsonRegularExpression._IRegularExpression;
var
  V: PValueRegularExpression;
begin
  GetMem(V, SizeOf(TValueRegularExpression));
  V.FBase.FVTable := @VTABLE_REGULAR_EXPRESSION;
  V.FBase.FRefCount := 0;
  Pointer(V.FPattern) := nil;
  Pointer(V.FOptions) := nil;
  V.FPattern := APattern;
  V.FOptions := AOptions;
  Result := TBsonRegularExpression._IRegularExpression(V);
end;

function TValueRegularExpression.Equals(
  const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueRegularExpression;
begin
  if (AOther.BsonType = TBsonType.RegularExpression) then
  begin
    Other := PValueRegularExpression(AOther);
    Result := (FPattern = Other.FPattern) and (FOptions = Other.FOptions);
  end
  else
    Result := False;
end;

function TValueRegularExpression.GetBsonType: TBsonType;
begin
  Result := TBsonType.RegularExpression;
end;

function TValueRegularExpression.GetOptions: String;
begin
  Result := FOptions;
end;

function TValueRegularExpression.GetPattern: String;
begin
  Result := FPattern;
end;

function TValueRegularExpression.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if (IID = TBsonRegularExpression._IRegularExpression) then
  begin
    TBsonRegularExpression._IRegularExpression(Obj) := TBsonRegularExpression._IRegularExpression(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueRegularExpression.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FPattern := '';
    FOptions := '';
    FreeMem(@Self);
  end;
end;

{ TValueJavaScript }

class function TValueJavaScript.Create(
  const ACode: String): TBsonJavaScript._IJavaScript;
var
  V: PValueJavaScript;
begin
  GetMem(V, SizeOf(TValueJavaScript));
  V.FBase.FVTable := @VTABLE_JAVA_SCRIPT;
  V.FBase.FRefCount := 0;
  Pointer(V.FCode) := nil;
  V.FCode := ACode;
  Result := TBsonJavaScript._IJavaScript(V);
end;

function TValueJavaScript.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueJavaScript;
begin
  if (AOther.BsonType = TBsonType.JavaScript) then
  begin
    Other := PValueJavaScript(AOther);
    Result := (FCode = Other.FCode);
  end
  else
    Result := False;
end;

function TValueJavaScript.GetBsonType: TBsonType;
begin
  Result := TBsonType.JavaScript;
end;

function TValueJavaScript.GetCode: String;
begin
  Result := FCode;
end;

function TValueJavaScript.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonJavaScript._IJavaScript) then
  begin
    TBsonJavaScript._IJavaScript(Obj) := TBsonJavaScript._IJavaScript(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueJavaScript.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FCode := '';
    FreeMem(@Self);
  end;
end;

{ TValueJavaScriptWithScope }

function TValueJavaScriptWithScope.Clone: TBsonValue._IValue;
begin
  Result := TValueJavaScriptWithScope.Create(FBase.FCode, FScope.Clone);
end;

class function TValueJavaScriptWithScope.Create(const ACode: String;
  const AScope: TBsonDocument): TBsonJavaScriptWithScope._IJavaScriptWithScope;
var
  V: PValueJavaScriptWithScope;
begin
  if (AScope.FImpl = nil) then
    raise EArgumentNilException.CreateRes(@SArgumentNil);

  GetMem(V, SizeOf(TValueJavaScriptWithScope));
  V.FBase.FBase.FVTable := @VTABLE_JAVA_SCRIPT_WITH_SCOPE;
  V.FBase.FBase.FRefCount := 0;
  Pointer(V.FBase.FCode) := nil;
  V.FBase.FCode := ACode;
  Pointer(V.FScope) := nil;
  V.FScope := AScope;

  Result := TBsonJavaScriptWithScope._IJavaScriptWithScope(V);
end;

function TValueJavaScriptWithScope.DeepClone: TBsonValue._IValue;
begin
  Result := TValueJavaScriptWithScope.Create(FBase.FCode, FScope.DeepClone);
end;

function TValueJavaScriptWithScope.Equals(
  const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueJavaScriptWithScope;
begin
  if (AOther.BsonType = TBsonType.JavaScriptWithScope) then
  begin
    Other := PValueJavaScriptWithScope(AOther);
    Result := (FBase.FCode = Other.FBase.FCode) and (FScope = Other.FScope);
  end
  else
    Result := False;
end;

function TValueJavaScriptWithScope.GetBsonType: TBsonType;
begin
  Result := TBsonType.JavaScriptWithScope;
end;

function TValueJavaScriptWithScope.GetScope: TBsonDocument;
begin
  Result := FScope;
end;

function TValueJavaScriptWithScope.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if (IID = TBsonJavaScript._IJavaScript)
    or (IID = TBsonJavaScriptWithScope._IJavaScriptWithScope) then
  begin
    TBsonJavaScript._IJavaScript(Obj) := TBsonJavaScript._IJavaScript(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueJavaScriptWithScope.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FBase.FRefCount);
  if (Result = 0) then
  begin
    FBase.FCode := '';
    FScope.FImpl := nil;
    FreeMem(@Self);
  end;
end;

{ TValueSymbol }

class function TValueSymbol.Create(const AName: String): TBsonSymbol._ISymbol;
var
  V: PValueSymbol;
begin
  GetMem(V, SizeOf(TValueSymbol));
  V.FBase.FVTable := @VTABLE_SYMBOL;
  V.FBase.FRefCount := 0;
  Pointer(V.FName) := nil;
  V.FName := AName;
  Result := TBsonSymbol._ISymbol(V);
end;

function TValueSymbol.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueSymbol;
begin
  if (AOther.BsonType = TBsonType.Symbol) then
  begin
    Other := PValueSymbol(AOther);
    Result := (FName = Other.FName);
  end
  else
    Result := False;
end;

function TValueSymbol.GetBsonType: TBsonType;
begin
  Result := TBsonType.Symbol;
end;

function TValueSymbol.GetName: String;
begin
  Result := FName;
end;

function TValueSymbol.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonSymbol._ISymbol) then
  begin
    TBsonSymbol._ISymbol(Obj) := TBsonSymbol._ISymbol(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueSymbol.Release: Integer;
begin
  Result := AtomicDecrement(FBase.FRefCount);
  if (Result = 0) then
  begin
    FName := '';
    FreeMem(@Self);
  end;
end;

function TValueSymbol.ToString(const ADefault: String): String;
begin
  Result := FName;
end;

{ TValueTimestamp }

class function TValueTimestamp.Create(
  const AValue: Int64): TBsonTimestamp._ITimestamp;
var
  V: PValueTimestamp;
begin
  GetMem(V, SizeOf(TValueTimestamp));
  V.FBase.FVTable := @VTABLE_TIMESTAMP;
  V.FBase.FRefCount := 0;
  V.FValue := AValue;
  Result := TBsonTimestamp._ITimestamp(V);
end;

class function TValueTimestamp.Create(const ATimestamp,
  AIncrement: Integer): TBsonTimestamp._ITimestamp;
begin
  Result := Create((UInt64(ATimestamp) shl 32) or UInt32(AIncrement));
end;

function TValueTimestamp.Equals(const AOther: TBsonValue._IValue): Boolean;
var
  Other: PValueTimestamp;
begin
  if (AOther.BsonType = TBsonType.Timestamp) then
  begin
    Other := PValueTimestamp(AOther);
    Result := (FValue = Other.FValue);
  end
  else
    Result := False;
end;

function TValueTimestamp.GetBsonType: TBsonType;
begin
  Result := TBsonType.Timestamp;
end;

function TValueTimestamp.GetIncrement: Integer;
begin
  Result := Integer(FValue);
end;

function TValueTimestamp.GetTimestamp: Integer;
begin
  Result := Integer(FValue shr 32);
end;

function TValueTimestamp.GetValue: Int64;
begin
  Result := FValue;
end;

function TValueTimestamp.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonTimestamp._ITimestamp) then
  begin
    TBsonTimestamp._ITimestamp(Obj) := TBsonTimestamp._ITimestamp(@Self);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

{ TValueMaxKey }

function TValueMaxKey.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TBsonType.MaxKey);
end;

function TValueMaxKey.GetBsonType: TBsonType;
begin
  Result := TBsonType.MaxKey;
end;

function TValueMaxKey.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonMaxKey._IMaxKey) then
  begin
    TBsonMaxKey._IMaxKey(Obj) := TBsonMaxKey._IMaxKey(@VALUE_MAX_KEY);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueMaxKey.ToString(const ADefault: String): String;
begin
  Result := 'MaxKey';
end;

{ TValueMinKey }

function TValueMinKey.Equals(const AOther: TBsonValue._IValue): Boolean;
begin
  Result := (AOther.BsonType = TBsonType.MinKey);
end;

function TValueMinKey.GetBsonType: TBsonType;
begin
  Result := TBsonType.MinKey;
end;

function TValueMinKey.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if (IID = TBsonMinKey._IMinKey) then
  begin
    TBsonMinKey._IMinKey(Obj) := TBsonMinKey._IMinKey(@VALUE_MIN_KEY);
    Result := S_OK;
  end
  else
    Result := E_NOINTERFACE;
end;

function TValueMinKey.ToString(const ADefault: String): String;
begin
  Result := 'MinKey';
end;

end.
