{———————————————————————————————————————————————————————————————————————————————
  ARvRA M	  Töre library for Delphi.

  Copyright	: (C)2018-2071 İhsan V. Töre and licensors. All rights reserved.
  About		: A multipurpose framework for Model based programming.
  Home		: www.toretek.com
  Version	: 20181214 Authors: IVT
  Author	: IVT : İhsan V. Töre : ihsan@toretek.com : www.toretek.com
———————————————————————————————————————————————————————————————————————————————}

unit ModelApi;
{———————————————————————————————————————————————————————————————————————————————
 This is a Model Api for delphi XE3.
 It is transparent to programmer, giving almost no burden.
 Use TModel descendants for  json object strings and datasets.
 Use TModelList for incoming json array  strings.
 Please read class definitions for detailed functionality.
———————————————————————————————————————————————————————————————————————————————}

interface

uses
    System.SysUtils,
    System.Classes,
    System.Contnrs,
	  System.TypInfo,
	  System.Types,
    System.Rtti,
    System.JSON,
	  Data.Db,
	  Data.Dbxjson;
type

{———————————————————————————————————————————————————————————————————————————————
  Run Time Type Info Attributes for Model Classes.
———————————————————————————————————————————————————————————————————————————————}
{———————————————————————————————————————————————————————————————————————————————
  ATTR: RMax
  TASK:	Tells the limit of characters of a String field.
  PROP:	limit	: Integer	: The number of characters for a String.
  INFO: Specially useful for generating datasets from objects.

  USAGE EXAMPLE:

		class TExampleModel = class(TModel)
		public
						someInteger	:	integer;
			[RMax(40)]  theString	:	String;
			[RMax(10)]	yetAnother	:	String;
		end;
———————————————————————————————————————————————————————————————————————————————}
	RMax 		= class (TCustomAttribute)
	private
		fLimit : integer;
	public
		constructor Create(aLimit : Integer);
		property limit : Integer read fLimit write fLimit;
	end;

{———————————————————————————————————————————————————————————————————————————————
  ATTR: RDepends
  TASK:	Stores class type dependancy information for current field.
  PROP: ref	:	String	:  Reference field that Current field depends.
		vN  :	String	:  Value n...
		cN	:   TClass	:  Maps to class n.
  INFO: Current field should be an object, or an array of object field.
		Value match is done by stringifying the reference field.
  WARN: * 	There can be only one   [RDepends] attribute for a field.
		* 	This attribute is checked only when object class is EQUAL to
			TModel or TObject.
		*	cN: Should be always a TModel class.
				Class should be defined before [RDepends(...)] attribute.
				Class forward declarations will not work.
		Ex:
			class TSomeModel = class; // a forward declaration
			...
			[RDepends('fieldName','A Value', TSomeModel, ...)]
			Will give compilation error because of TSomeModel.

  USAGE EXAMPLE:

		class TExampleModel = class(TModel)
		public
			objType:	integer;
			[RDepends('objType','1', TModelTypeOne, '2', TModelTypeTwo)]
			dependantObj: TModel; 			// This should be TModel or TObject.

			arrType:	String;
			[RDepends(	'arrType',
						'Moon',			TModelMoonMaybe,
						'Something', 	TModelTypeMatchingSomething,
						'2', 			TModelTypeTwo
			)]
			dependantArr: Array of TModel; 	// This should be TModel or TObject
		end;                                // array.


———————————————————————————————————————————————————————————————————————————————}
	RDepends	= class (TCustomAttribute)
	private
		fRef	: String;
		fStr	: Array[0..9]of String;
		fCls	: Array[0..9]of Pointer;
	function	getClass(v: String): TClass;
	public
		constructor	Create(
				aRef: String;
				v0:	String;		c0: TClass;
				v1:	String;		c1: TClass;
				v2:	String ='';	c2: TClass = nil;
				v3:	String ='';	c3: TClass = nil;
				v4:	String ='';	c4: TClass = nil;
				v5:	String ='';	c5: TClass = nil;
				v6:	String ='';	c6: TClass = nil;
				v7:	String ='';	c7: TClass = nil;
				v8:	String ='';	c8: TClass = nil;
				v9:	String ='';	c9: TClass = nil
		);
		property	ref	: String 				read fRef write fRef;
		property	Cls[v: String] : 	TClass	read getClass;
	end;

{———————————————————————————————————————————————————————————————————————————————
  CLASS: TModel
  USAGE:
	*	It is the base class for modeling.
		Model objects serve as data templates for converting
		information from and to JSON, datasets and themselves as objects.

	*   Model classes are recommended to be direct descendants of TModel.
	*	Only public fields are significant in a Model.
	*	Sets and Static arrays are not supported.
	*	Only TModel descendants are valid as public sub object fields.
		Ex:
			o: TComponent; 			// No! May crash!
			o: TModelDescendant;  	// Yes.

	*	Only TModel descendants are valid as public sub object array fields.
		Ex:
			a: Array of TComponent; 		// No! May crash!
			a: Array of TModelDescendant;   // Yes.


	*	Here is an example Model class:

		TExampleModel = class(TModel)
		public
			StrField: String;
			IntField: Integer;
			BooField  Boolean;
			LonField: Int64;
			AriField: Array of integer;
			AroField: Array of TAnotherModelClass;
		end;

	*	It can :

		read 	a json string (must be object, matching fields will be red).
		byJson(json: String),
		Create(json: String)

		make	a json string denoting an object from its contents.
		toJson(): String;

		read	from	a dataset, but fields must match.
		byDataSet(dataSet: TDataSet);
		Create(dataSet: TDataSet);

		write	to      a dataset, but fields must match.
		toDataSet(dataSet: TDataSet);

		Structure a TDataSet from its field definitions.
		toTable(d: TDataSet); (Class procedure)

		Please refer to method definitions for detailed functionality.
———————————————————————————————————————————————————————————————————————————————}
	TModel = Class
		constructor 	Create(dataSet:     TDataSet);      overload;
		constructor 	Create(json:        String);        overload;
		class procedure toTable(d: TDataSet);               virtual;
		destructor  	Destroy(); 							override;
		procedure   	byJson(json:        String);        virtual;
		function    	toJson:             String;         virtual;
		procedure   	byDataSet(dataSet:  TDataSet);      virtual;
		procedure   	toDataSet(dataSet:  TDataSet);      virtual;
	end;

	TModelClass =   class of TModel;
	TModelArray =	Array of TModel;

{———————————————————————————————————————————————————————————————————————————————
  CLASS: TModelList
  USAGE:
	*	It is basically a TObjectList wrapper for TModel objects.
	*	It is for conversion of Array of TModel descendants to and from JSON.
	*	It should NOT be used as a sub object of another TModel descendant.
	*	It should be containing TModel descendants as list elements.

	*	ownsModels  property :
		*	Indicates if ModelList is the owner of element objects or not.
		***	Default is true!
		*	When True:
			*	All elements will be destroyed when ModelList gets destroyed.
			*	When list is downsized by length, the elements discarded gets
				destroyed.
			*	When an element is overwritten by another or nil, the old one
				gets destroyed.

	*   template 	property :
		*	It can be given at Create too.
		*	It is used as a general model for elements of the list.
		*	While reading form json, if any element of the list is nil,
			an object of class given at template will be created to fill in.
		***	If a list element is not nil template will not be used for it.
			the element itself will be used for reading from json.
		***	That means every element of list can be of a different TModel Class.

	*	count 		property :
		*	Sets the length of list.
		*	While reading from json, the length is automatically set to the
			number of elements in then json array.
		*	When ownsModels is true (default) if list is downsized by length,
			the elements discarded gets	destroyed.

	*	models[ix]	property :
		*	Accessor [default] property for the list.
			Ex:  myList[i] has the same meaning of myList.models[i].

	*	It can :

		read 	a json string denoting an array ('[ .... ]').
		byJson(json: String),
		Create(json: String)

		make	a json string denoting an array from its contents.
		toJson(): String;

		Transfer contents to a dataset.
		toDataSet();

		Please refer to method definitions for detailed functionality.
———————————————————————————————————————————————————————————————————————————————}
 {$M+}
	TModelList  =   class sealed (TModel)  			// Do not inherit this.
		constructor Create(aTemplate: TModelClass); // No inherited creates.
		class procedure toTable(d: TDataSet);       	override; // Blocker.
		destructor  Destroy();                          override;
		procedure   byJson(json:        String);        override;
		function    toJson:             String;         override;
		procedure   byDataSet(dataSet:  TDataSet);      override; // Blocker.
		procedure   toDataSet(dataSet:  TDataSet);      override;
		function	add(model: TModel): Integer;
		procedure	delete(ix: Integer);
		procedure	insert(ix: Integer; model: TModel);
		function 	indexOf(model: TModel): Integer;
	private
		fCls:       TModelClass;
		fLst:       TObjectList;
		fArr:		Array of TModel;
		procedure 	checkIndex(ix: Integer);
		function    getCnt(): integer;
		procedure   setCnt(value: integer);
		function    getOwn(): boolean;
		procedure   setOwn(value: boolean);
		function    getM(ix: integer): TModel;
		procedure   setM(ix: integer; value: TModel);
		procedure 	toAConv(length: Integer);
		procedure 	byAConv();
	public
		property    models[ix: integer]: TModel read getM 	write setM; default;
	published
		property	template	: TModelClass  	read fCls   write fCls;
		property    count 		: integer		read getCnt	write setCnt;
		property    ownsModels	: Boolean 		read getOwn	write setOwn;
    end;

 // Utility function.
procedure modelArrayToDataSet(var modelArray; dataSet: TDataSet);

implementation

const
    F_PUBLIC    = TMemberVisibility.mvPublic;   // To discriminate Publics.

var
	context:    TRttiContext;
	ctxList:    TObjectList;
	ctxActv:	Integer;
{———————————————————————————————————————————————————————————————————————————————
	Forward declarations for internal functions.
	These functions should not be accessible from other units.
———————————————————————————————————————————————————————————————————————————————}
procedure	enterContext();											forward;
procedure   leaveContext();                  						forward;
function    fetchModel(o: TObject): TArray<TRttiField>;		        forward;

procedure   objToDst(m: TObject; d: TDataSet);                      forward;
procedure   dstToObj(m: TObject; d: TDataSet);                      forward;
procedure   modelToTable(c: TModelClass; d: TDataSet); 				forward;

function    objToJson(v: TValue): TJSONValue;                       forward;
function    valToJson(v: TValue): TJSONValue;                       forward;
function    strToJson(v: TValue): TJSONValue;                       forward;
function    enuToJson(v: TValue): TJSONValue;                       forward;
function    dynToJson(v: TValue): TJSONArray;                       forward;

function    jsonToObj(j: TJSONObject;   v: TValue): TValue;         forward;
function    jsonToVal(j: TJSONValue;    v: TValue): TValue;         forward;
function    jsonToDyn(j: TJSONArray;    v: TValue): TValue;         forward;
function    jsonToStr(j: TJSONString)             : TValue;         forward;

{———————————————————————————————————————————————————————————————————————————————

	Run Time Type Info Attribute Codes for Model Classes.

———————————————————————————————————————————————————————————————————————————————}
{ RMax }

constructor RMax.Create(aLimit: Integer);
begin
	fLimit := aLimit;
end;

{ RDepends }

constructor RDepends.Create(   // Attribute arguments have heavy restrictions.
					aRef,
					v0: String; c0: TClass; v1: String; c1: TClass;
					v2: String; c2: TClass; v3: String; c3: TClass;
					v4: String; c4: TClass; v5: String; c5: TClass;
					v6: String; c6: TClass; v7: String; c7: TClass;
					v8: String; c8: TClass; v9: String; c9: TClass
);
var
	i: Integer;
procedure add(v: String; c: Pointer);
begin
	if ((v = '') or (c = nil)) then
		exit;

	fStr[i] := v;
	fCls[i] := c;
	inc(i);
end;

begin
	if (aRef = '') then
		raise Exception.Create('E_CODING: RDepends has no field to refer.');
	fRef := aRef;
	i := 0;
	add(v0,c0);	add(v1,c1);	add(v2,c2);	add(v3,c3); add(v4,c4);
	add(v5,c5);	add(v6,c6); add(v7,c7); add(v8,c8); add(v9,c9);
end;

function	RDepends.getClass(v: String): TClass;
var i: integer;
begin
	for i := 0 to High(fStr) do
	begin
		if (fStr[i] = v) then
			exit(TClass(fCls[i]));
	end;
	exit(nil);
end;

{———————————————————————————————————————————————————————————————————————————————
  *****************
  *  TModel Code. *
  *               *
  *****************
———————————————————————————————————————————————————————————————————————————————}

{———————————————————————————————————————————————————————————————————————————————
  CTOR: Create (overloaded).
  TASK: Creates then assigns fields of a model object from a json string.
  ARGS: json    : String  : JSON string data for Object.
  RETV: New model object.
  INFO: 1) Only public fields are converted.
		2) Public Set and Static array fields are not supported.
———————————————————————————————————————————————————————————————————————————————}
constructor     TModel.Create(json: String);
begin
    byJson(json);
end;

{———————————————————————————————————————————————————————————————————————————————
  CTOR: Create (overloaded).
  TASK: Creates then assigns fields of a model object from a TDataSet.
  ARGS: dataSet : TDataSet  : Data Set containing the object fields.
  INFO: 1) Only public fields are transferred from dataset.
        2) Public Sets, Arrays and sub objects in model are ignored.
———————————————————————————————————————————————————————————————————————————————}
constructor     TModel.Create(dataSet: TDataSet);
begin
    byDataSet(dataSet);
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: toTable (class procedure)
  TASK: Structures a dataset's fields out of the model object class.
  ARGS: d	: TDataSet	: Dataset to form according to model.
  INFO: 1) Only public fields are generated into TDxMemData.
        2) Public Sets, Arrays and sub objects in model are ignored.
———————————————————————————————————————————————————————————————————————————————}
class procedure  TModel.toTable(d: TDataSet);
begin
	enterContext;
try
	modelToTable(self, d);
finally
    leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: byJson
  TASK: Assigns fields of a model object from a json string.
  ARGS: json    : String  : JSON string data for Object.
  INFO: 1) Only public fields are converted.
		2) Public Set and Static array fields are not supported.
———————————————————————————————————————————————————————————————————————————————}
procedure       TModel.byJson(json: String);
var
	tVal: TValue;
	jObj: TJSONObject;
	jVal: TJSONValue;
begin
	jObj := nil;
	enterContext;
try
	TValue.MakeWithoutCopy(@self, self.ClassType.ClassInfo, tVal);
	// ParseJSONValue gecersiz/JSON-olmayan govdede (yetki hatasi, HTML, bos yanit) nil
	//   ya da nesne-disi bir deger dondurur. Kontrolsuz cast + jsonToObj = nil alan
	//   okumasi (access violation). Once dogrula, anlasilir hata ver.
	jVal := TJSONObject.ParseJSONValue(json);
	if (not (jVal is TJSONObject)) then
	begin
		if (jVal <> nil) then
			jVal.Free;
		raise Exception.Create(
			'E_NOT_JSON_OBJECT: sunucu yanıtı JSON nesnesi değil -> '
			+ Copy(TrimLeft(json), 1, 300));
	end;
	jObj := TJSONObject(jVal);
	jsonToObj(jObj, tVal);
finally
	if (jObj <> nil) then
		jObj.Free;
	leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: toJson
  TASK: Converts model object to a JSON string.
  RETV:         String  : JSON string version of Object in model or null.
  INFO: 1) Only public fields are converted.
		2) Circular references will cause exception.
		3) Set and Static array fields are not supported.
———————————————————————————————————————————————————————————————————————————————}
function        TModel.toJson: String;
var
	tVal: TValue;
	jVal: TJSONValue;
begin
	jVal 	:= nil;
	enterContext;
try
	TValue.MakeWithoutCopy(@self, self.ClassType.ClassInfo, tVal);
	jVal    := objToJson(tVal);
	result  := jVal.toString;
finally
	if (jVal <> nil) then
		jVal.Free;
	leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: byDataSet
  TASK: Transfers contents of a TDataSet to the model object.
  ARGS: dataSet : TDataSet  : Data Set containing the object fields.
  INFO: 1) Only public fields are transferred from dataset.
		2) Public Sets, Arrays and sub objects in model are ignored.
		3) All public fields must be defined in the dataSet.
———————————————————————————————————————————————————————————————————————————————}
procedure       TModel.byDataSet(dataSet: TDataSet);
begin
	enterContext;
try
	dstToObj(self, dataSet);
finally
	leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: toDataSet
  TASK: Transfers contents of model object to the TDataSet .
  ARGS: dataSet   : TDataSet  : Data Set containing the object fields.
  INFO: 1) Only public fields are transferred to dataset.
		2) Public Sets, Arrays and sub objects in model are ignored.
		3) All public fields must be defined in the dataSet.
———————————————————————————————————————————————————————————————————————————————}
procedure      TModel.toDataSet(dataSet: TDataSet);
begin
	enterContext;
try
	objToDst(self, dataSet);
finally
	leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  DTOR: Destroy.
  TASK: Destroys the model object and ***All Sub Objects at Public Fields.***
———————————————————————————————————————————————————————————————————————————————}
destructor      TModel.Destroy;
var
    l: TArray<TRttiField>;                              // List of all fields.
    r: TRttiField;                                      // Field data.
    k: TTypeKind;                                       // Field Type kind.
    v: TValue;                                          // Value    for arrays.
    i,                                                  // Iterator for arrays.
    c: Integer;                                         // Count    for arrays.
begin
	enterContext;
try
	l := fetchModel(self);
	for r in l do
	begin
		if (r.Visibility <> F_PUBLIC) then              // If not public
			continue;                                   // skip it.
		k := r.FieldType.TypeKind;                      // Get type kind.
		case k of                                       // Kind selector.
		tkClass: r.GetValue(self).AsObject.Free;        // If object, kill it.
		tkDynArray:                                     // If dynamic array
		begin
			k := TRttiDynamicArrayType(r.FieldType)     // Get element typekind.
				.ElementType
				.TypeKind;
			if (k <> tkClass) then                      // If not object array
				continue;                               // ignore.
			v := r.GetValue(self);                      // Get the array.
			c := v.GetArraylength - 1;                  // Get element count-1.
			for i := 0 to c do                          // Iterate elements
				v.GetArrayElement(i).AsObject.Free;     // Free the element
		end;
		end;
	end;
finally
	leaveContext;
end;
	inherited;
end;


{———————————————————————————————————————————————————————————————————————————————
  **********************
  *  TModelList Code.  *
  *                    *
  **********************
———————————————————————————————————————————————————————————————————————————————}

{———————————————————————————————————————————————————————————————————————————————
  CTOR: Create
  TASK: Creates a model list.
  ARGS: aTemplate    : TModelClass  : Default template class for elements.
  RETV: New model list object.
———————————————————————————————————————————————————————————————————————————————}
constructor     TModelList.Create(aTemplate: TModelClass);
begin
	fCls := aTemplate;
	fLst := TObjectList.Create;
	fLst.OwnsObjects := true;
end;

{———————————————————————————————————————————————————————————————————————————————
  DTOR: Destroy.
  TASK: Destroys the list and ***All elements if it is the Owner***
———————————————————————————————————————————————————————————————————————————————}
destructor      TModelList.Destroy;
begin
	if (fLst <> nil) then
		fLst.Free;
	setLength(fArr, 0);
	inherited;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROP: ownsModels	: Boolean
  TASK:	GET:	True if list owns the elements.
		SET:    Sets ownership of elements.
———————————————————————————————————————————————————————————————————————————————}
function TModelList.getOwn: boolean;
begin
	exit(fLst.OwnsObjects);
end;

procedure TModelList.setOwn(value: boolean);
begin
	fLst.OwnsObjects := Value;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROP: count	: Integer
  TASK:	GET:	Returns list element count.
		SET:    Sets list element count.
  WARN: When ownsModels is true, if downsizing the list,
		discarded elements get destroyed.
———————————————————————————————————————————————————————————————————————————————}
function        TModelList.getCnt: integer;
begin
	exit(fLst.Count);
end;

procedure       TModelList.setCnt(value: integer);
begin
	fLst.Count := value;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROP: models[ix: integer] : TModel : Default.
  TASK:	GET:	Returns list element at index.
		SET:    Sets list element at index.
  WARN: If ownsModels is true, when setting an element, if there is another
		element there it will get destroyed. Unlike TObjectList, setting an
		element to nil will destroy that element.
———————————————————————————————————————————————————————————————————————————————}
function        TModelList.getM(ix: integer): TModel;
begin
	checkIndex(ix);
	exit(TModel(fLst[ix]));
end;

procedure       TModelList.setM(ix: integer; value: TModel);
begin
	checkIndex(ix);
	if (fLst[ix]= value) then
		exit;
	if ((fLst.OwnsObjects) and (fLst[ix]<> nil)) then
		fLst[ix].Free;
    fLst[ix] := value;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: checkIndex
  TASK: Checks if an index is in list range. Raises exception if not.
  ARGS: ix 	: Integer	: Index to list.
———————————————————————————————————————————————————————————————————————————————}
procedure 	TModelList.checkIndex(ix: Integer);
var
	l : Integer;
begin
	l := getCnt;
	if ((ix < 0) or (ix >= l)) then
		raise Exception.Create('E_MODEL_LIST_RANGE');
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: add
  TASK: Adds an element to model list.
  ARGS:	model	: TModel	: Model object or nil to add.
  RETV:         : Integer	: Index of list element added.
  INFO: List count increases by one. Allocation is automatic.
———————————————————————————————————————————————————————————————————————————————}
function 	TModelList.add(model: TModel): Integer;
begin
	exit(fLst.Add(model));
end;
{———————————————————————————————————————————————————————————————————————————————
  PROC: insert
  TASK: Inserts an element to index at model list.
  ARGS:	ix	: Integer	: Index of element to add.
  INFO: When an element gets inserted, elements after it are shifted down.
		List count increases by one. Allocation is automatic.
———————————————————————————————————————————————————————————————————————————————}
procedure 	TModelList.insert(ix: Integer; model: TModel);
begin
	checkIndex(ix);
	fLst.Insert(ix, model);
end;
{———————————————————————————————————————————————————————————————————————————————
  PROC: delete
  TASK: Deletes an element from model list.
  ARGS:	ix	: Integer	: Index of element to delete.
  INFO: When an element gets deleted, elements after it are shifted up.
		List count decreases by one.
  WARN:	If ownsModels is true, deleted element gets destroyed.
———————————————————————————————————————————————————————————————————————————————}
procedure 	TModelList.delete(ix: Integer);
begin
	checkIndex(ix);
	fLst.Delete(ix);
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: indexOf
  TASK: Returns index of an element in list if exists or -1 if not.
  ARGS:	model	: TModel	: Model object or nil to look for.
  RETV:         : Integer	: Index of list element found or -1 if not found.
———————————————————————————————————————————————————————————————————————————————}
function 	TModelList.indexOf(model: TModel): Integer;
begin
	exit(fLst.IndexOf(model));
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: toAConv (internal use)
  TASK: Transfers fLst contents to fArr. Empty elements will be filled with
		new objects of template class.
  INFO: Since fLst is an object (TObjectList) fArr is necessary.
		fArr is and can be accessed as "array" by RTTI system.
		fArr is used during conversions and then cleared immediately.
———————————————————————————————————————————————————————————————————————————————}
procedure       TModelList.toAConv(length: Integer);
var
	i: integer;
begin
	setCnt(length);
	setLength(fArr, length);
	for i := 0 to length - 1 do
	begin
		if (fLst[i]<> nil) then
		begin
			fArr[i] := TModel(fLst[i]);
			continue;
		end;
		if (fCls = nil) then
			raise Exception.Create('E_MODEL_LIST_TEMPLATE_NIL');
		fArr[i] := fCls.Create;
		fLst[i] := fArr[i];
	end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: byAConv (internal use)
  TASK: Transfers fArr contents to fLst. Clears fArr.
  INFO: Since fLst is an object (TObjectList) fArr is necessary.
		fArr is and can be accessed as "array" by RTTI system.
		fArr is used during conversions and then cleared immediately.
———————————————————————————————————————————————————————————————————————————————}
procedure TModelList.byAConv;
var
	i,
	l: integer;
begin
	l := Length(fArr);
	setCnt(l);
	for i := 0 to l - 1 do
		setM(i, fArr[i]);
	setLength(fArr, 0);
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: byJson
  TASK: Assigns fields of a model list from a json string denoting an array.
  ARGS: json    : String  : JSON string data of array.
  INFO: 1) Only public fields are converted.
		2) Public Sets and Static arrays are not supported.
———————————————————————————————————————————————————————————————————————————————}
procedure       TModelList.byJson(json: String);
var
	j: TJsonValue;
	r: TRttiField;
	v: TValue;
begin
	j := TJSONObject.ParseJSONValue(json);
	if (not (j is TJSONArray)) then
	begin
		if (j <> nil) then
			j.Free;
		raise Exception.Create('E_NOT_JSON_ARRAY');
	end;
	toAConv(TJSONArray(j).Size);
	enterContext;
try
	r := context.getType(self.ClassType).GetField('fArr');
	v := jsonToDyn(TJSONArray(j), r.GetValue(self));
	r.SetValue(self, v);
finally
	byAConv();
	if(j <> nil) then
		j.Free;
	leavecontext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: toJson
  TASK: Converts a model list into a json string denoting an array.
  INFO: 1) Only public fields are converted.
		2) Public Sets and Static arrays are not supported.
———————————————————————————————————————————————————————————————————————————————}
function        TModelList.toJson: String;
var
	j: TJSONArray;
	r: TRttiField;
begin
	j := nil;
	toAConv(getCnt());
	enterContext;
try
	r := context.getType(self.ClassType).GetField('fArr');
	j := dynToJson(r.GetValue(self));
	if (j <> nil) then
		result := j.ToString
	else
		result := '[]';
finally
	byAConv();
	if (j <> nil) then
		j.Free;
	leaveContext;
end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: toDataSet
  TASK: Transfers contents of a model list into a data set.
  INFO: 1) Only public fields are converted.
		2) Public Sub Objects, Sets and arrays are not supported.
  WARN: It is recommended that all elements in the list are of the same
		model class.
———————————————————————————————————————————————————————————————————————————————}
procedure TModelList.toDataSet(dataSet: TDataSet);
var
	i,
	l: integer;
begin
	if (dataSet = nil) then
		raise Exception.Create('E_INV_ARG: dataSet = nil');
	l := getCnt() - 1;
	for i := 0 to l do
	begin
		if (fLst[i] = nil) then
			continue;
		TModel(fLst[i]).toDataSet(dataSet);
	end;
end;

// STUB: Unsupported method call.
class procedure TModelList.toTable(d: TDataSet);
begin
    raise Exception.Create('E_INV_MET: Method not supported.');
end;
// STUB: Unsupported method call.
procedure TModelList.byDataSet(dataSet: TDataSet);
begin
	raise Exception.Create('E_INV_MET: Method not supported.');
end;

{———————————————————————————————————————————————————————————————————————————————
	EXTERNAL UTILITY Functions
———————————————————————————————————————————————————————————————————————————————}
{———————————————————————————————————————————————————————————————————————————————
  PROC: modelArraytoDataSet
  TASK: Transfers contents of a model array into a data set.
  ARGS: modelArray 	: var 		: Pointer to an Array of TModel Descendant.
                                  Contains models to transfer to dataset.
		dataSet		: TDataSet	: Target data set to transfer.
  INFO: 1) Only public fields are converted.
		2) Public Sub Objects, Sets and arrays are not supported.

  WARN: *** VERY IMPORTANT ***	About modelArray parameter;
		Delphi is a mess when type checking arrays as parameters.
		When defined as	:	var modelArray: TModelArray
		Call becomes	:   modelArrayToDataSet(TModelArray(x), dset);
		And compiler doesn't care even if you pass a string as 'x'.
		Since model arrays are Array of 'TModel descendants', the casting
		should be done everytime, rendering type checks obsolete.
		So the modelArray has no type in the declaration because;
			a) It has no use, compiler is very very stupid.
			b) Casting will always hide the real type of parameter.
			c) Programmer ends up writing cast TModelArray(x) everytime.
		2) It is recommended that all elements in the array are of the same
		model class.
———————————————————————————————————————————————————————————————————————————————}
procedure modelArrayToDataSet(var modelArray; dataSet: TDataSet);
var
	i,
	l: integer;
	m: TModelArray;
begin
	if (dataSet = nil) then
		raise Exception.Create('E_INV_ARG: dataSet = nil');
	m := TModelArray(modelArray);
	l := length(m);
	for i := 0 to l-1 do
	begin
		if (m[i] = nil) then
			continue;
		m[i].toDataSet(dataSet);
	end;
end;

{———————————————————————————————————————————————————————————————————————————————
	JSON Escapes these characters as a rule but XE3 libraries does not
	with the exception of double quote(") being parsed correctly by TJSON.
    Since we use utf-8 encoding characters above 126 is sent as is.
    These constants are used in:
        strToJson and
        jsonToStr functions.
———————————————————————————————————————————————————————————————————————————————}
const
    ESCAPE = '\';
  //DQUOTE = '"';    // Handled by TJSON library correctly
    SQUOTE = '''';
    BSLASH = '\';
    FSLASH = '/';
    BSPACE = #8;
	F_FEED = #12;
    L_FEED = #10;
    RETURN = #13;
	TABSPC = #9;

{———————————————————————————————————————————————————————————————————————————————
    Initializer and finalizer codes.
———————————————————————————————————————————————————————————————————————————————}
procedure   initUnit;
begin
	// Nothing for now...
end;

procedure   exitUnit;
begin
	leaveContext;
end;

{———————————————————————————————————————————————————————————————————————————————
	INTERNAL UTILITY Functions
———————————————————————————————————————————————————————————————————————————————}
{———————————————————————————————————————————————————————————————————————————————
  FUNC: enterContext
  TASK: Manages Rtti context, and a conversion list.
  INFO: Avoids unnecessary TRttiContext instances. Saves time...
  WARN:	TRttiContext is a RECORD, not a real OBJECT.
———————————————————————————————————————————————————————————————————————————————}
procedure 	enterContext;
begin
	if (ctxList <> nil) then                    // If conversion list created
	begin
		inc(ctxActv);                           // Increase reference.
		exit;
    end;
	context := TRttiContext.Create;         	// create a RTTI context.
	ctxList := TObjectList.Create(false);   	// Create conversion list.
	ctxActv := 1;								// Set reference. First call.
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: leaveContext
  TASK: Manages Rtti context, and the conversion list.
  INFO: Avoids unnecessary TRttiContext instances. Saves time...
  WARN: Should be called at top level.
———————————————————————————————————————————————————————————————————————————————}
procedure   leaveContext;
begin
	if (ctxList = nil) then                    	// If no conversion list
	begin
		ctxActv := 0;                           // Reset reference.
		exit;
	end;
	dec(ctxActv);								// Decrease reference.
	if (ctxActv > 0) then                       // If live referrers
		exit;                                   // exit.
	context.free;        						// destroy RTTI context.
	ctxList.Free;                               // destroy conversion list.
	ctxList := nil;                             // Mark with nil.
end;

{———————————————————————————————————————————————————————————————————————————————

  Functions and procedures below can work only when there is a context...

———————————————————————————————————————————————————————————————————————————————}


{———————————————————————————————————————————————————————————————————————————————
  FUNC: fetchModel
  TASK: Keeps track of conversions, returns field info list of object given.
  ARGS: o:  TObject             : Object which field info list requested.
  RETV:     TArray<TRttiField>  : Field info list of object.
  INFO: Avoids circular references during conversions.
———————————————————————————————————————————————————————————————————————————————}
function    fetchModel(o: TObject): TArray<TRttiField>;
begin
	if (ctxList.IndexOf(o)<>-1) then            // If object already converted.
		raise Exception.Create('E_CIRCULAR');   // Raise circular ref. exc.
	ctxList.Add(o);                             // Add object to list.
    exit(context.GetType(o.ClassType).GetFields)// Access to fields.
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: isEnumBoolean
  TASK: Checks if an enumeration in TValue is Boolean.
  ARGS: v:  TValue  : Value to check.
  RETV:     Boolean : true if value type is boolean.
———————————————————————————————————————————————————————————————————————————————}
function    isEnumBoolean(v:TValue): boolean;
var
    e :  TRttiEnumerationType;
begin
	e := TRttiEnumerationType(context.GetType(v.TypeInfo));
    exit(e.UnderlyingType.Handle = System.TypeInfo(Boolean));
end;

{———————————————————————————————————————————————————————————————————————————————
    Functions for converting to and from TDataSet...
———————————————————————————————————————————————————————————————————————————————}

{———————————————————————————————————————————————————————————————————————————————
  PROC: dstToObj
  TASK: Transfers fields of a TDataSet to a model object.
  ARGS: m   : TObject   : Model object to fill from Data Set.
        d   : TDataSet  : Data Set containing the object fields.
  INFO: Conversion rules:
        1) Only public fields are transferred from dataset.
        2) Public Sets, Arrays and sub objects in model are ignored.
———————————————————————————————————————————————————————————————————————————————}
procedure   dstToObj(m: TObject; d: TDataSet);
var
    l: TArray<TRttiField>;                              // List of all fields.
    r: TRttiField;                                      // Field data.
    n: String;                                          // Field name.
    k: TTypeKind;                                       // Field type kind.
    f: TField;                                          // Field at dataset.
begin
    if (d = nil) then                                   // if dataset is nil.
        raise Exception.Create('E_INV_ARG: d = nil');   // Tell the problem...
    if (m = nil) then                                   // if model is nil.
        raise Exception.Create('E_INV_ARG: m = nil');   // Tell the problem...
	l := fetchModel(m);                               	// Get model info.
    for r in l do begin                                 // Iterate fields.
        if (r.Visibility <> F_PUBLIC) then              // If not public
            continue;                                   // ignore.
		k := r.FieldType.TypeKind;                      // Get type kind.
        if ((k = tkDynArray) or (k = tkClass)) then     // If array or object
			continue;                                   // ignore (not in data).
		n := r.Name;                                    // Get field name.
		f := d.FindField(n);                            // Get field from data.
        if (f = nil) then                               // If not in dataset
			raise Exception.Create(                     // Tell the problem...
                'E_FLD_NOT_FOUND: '+ n
            );
		case k of                                       // Read data by type.
		tkEnumeration:
        begin
			if (isEnumBoolean(r.GetValue(m))) then
				r.SetValue(m, TValue(f.AsBoolean))
			else
				r.SetValue(m, TValue(f.AsInteger));
		end;
		tkChar,
		tkWChar,
		tkLString,
		tkWString,
		tkUString,
		tkString:       r.SetValue(m, TValue(f.AsString));
		tkFloat:        r.SetValue(m, TValue(f.AsFloat));
		tkInt64:        r.SetValue(m, TValue(f.AsLargeInt));
		tkInteger:      r.SetValue(m, TValue(f.AsInteger));
		else                                            // If invalid type
			raise Exception.Create(                     // Scream and shout...
                'E_INV_TYPE: '
                + n + ' -> '
                + String(r.FieldType.Name)
            );
        end;
	end;
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: objToDst
  TASK: Fills a TDataSet out of a model object.
  ARGS: m   : TObject   : Model object to fill the Data Set.
		d   : TDataSet  : Data Set containing the object fields.
  INFO: Transfer rules:
		1) Only public fields are transferred to dataset.
		2) Public Arrays and sub objects in model are ignored.
———————————————————————————————————————————————————————————————————————————————}
procedure   objToDst(m: TObject; d: TDataSet);
var
    l: TArray<TRttiField>;                              // List of all fields.
    r: TRttiField;                                      // Field data.
    n: String;                                          // Field name.
    k: TTypeKind;                                       // Field type kind.
    f: TField;                                          // Field at dataset.
begin
	if (d = nil) then                                   // if dataset is nil.
        raise Exception.Create('E_INV_ARG: d = nil');   // Tell the problem...
    if (m = nil) then                                   // if model is nil.
        raise Exception.Create('E_INV_ARG: m = nil');   // Tell the problem...
	l := fetchModel(m);                               	// Get model info.
    d.Append;
    for r in l do begin                                 // Iterate fields.
        if (r.Visibility <> F_PUBLIC) then              // If not public
            continue;                                   // ignore.
        k := r.FieldType.TypeKind;                      // Get type kind.
        if ((k = tkDynArray) or (k = tkClass)) then     // If array or object
            continue;                                   // ignore (not in data).
        n := r.Name;                                    // Get field name.
        f := d.FindField(n);                            // Get field from data.
        if (f = nil) then                               // If not in dataset
			raise Exception.Create(                     // Tell the problem...
                'E_FLD_NOT_FOUND: '+ n
            );
		case k of                                       // Read data by type.
        tkEnumeration:
		begin
			if (isEnumBoolean(r.GetValue(m))) then
				f.asBoolean := r.GetValue(m).AsBoolean
			else
				f.AsInteger := r.GetValue(m).AsInteger;
		end;
		tkChar,
        tkWChar,
        tkLString,
        tkWString,
        tkUString,
        tkString:   f.AsString      := r.GetValue(m).AsString;
        tkFloat:    f.AsFloat       := r.GetValue(m).AsExtended;
        tkInt64:    f.AsLargeInt    := r.GetValue(m).AsInt64;
        tkInteger:  f.AsInteger     := r.GetValue(m).AsInteger;
		else                                            // If invalid type
			raise Exception.Create(                     // Scream and shout...
				'E_INV_TYPE: '
                + n + ' -> '
                + String(r.FieldType.Name)
            );
        end;
	end;
	d.Post;                                             // Thank you Adnan.
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: closeAndWipeDataSet
  TASK: Closes a dataset, erasing records, then frees field definitions in it.
  ARGS: d   : TDataSet  : Data Set to wipe.
———————————————————————————————————————————————————————————————————————————————}
procedure closeAndWipeDataSet(d: TDataSet);
var
	i,
	l: Integer;
begin
	if (d = nil) then						// if nothing to wipe
		exit;                               // exit.
	d.Close;                      			// Close. Clears content also.
	l := d.FieldCount;                      // Get field count.
	for i := l - 1 downto 0 do				// Fields get removed, so backwards.
		d.Fields[0].Free;                   // Free field.
	d.FieldDefs.Update;                     // Update dataset.
end;

{———————————————————————————————————————————————————————————————————————————————
  PROC: modelToTable
  TASK: Structures a DataSet's Fields out of a model object class.
  ARGS: c   : TModelClass   : Template to form the dataset fields.
		d	: TDataSet		: Dataset to form the fields.
  INFO: Generation rules:
        1) Only public fields are generated into dataset.
        2) Public Sets, Arrays and sub objects in model are ignored.
———————————————————————————————————————————————————————————————————————————————}
procedure    modelToTable(c: TModelClass; d: TDataSet);
var
	l: TArray<TRttiField>;                              // List of all fields.
	a: TArray<TCustomAttribute>;                        // Attribute collector.
    r: TRttiField;                                      // Field data.
    n: String;                                          // Field name.
    k: TTypeKind;                                       // Field type kind.
	m: TObject;                                         // Template object.

    procedure newFld(t: TFieldType);                    // Helper to add field.
    var
        f: TFieldDef;
    begin
		if (n = '') then                            	// If no name
			exit;                                       // return.
		f := d.FieldDefs.AddFieldDef;                   // Add field definition.
		f.Name      := n;                               // Assign name.
		f.DataType  := t;                               // Assign type.
		if (t = ftWideString) then                      // If string
		begin
			a := r.GetAttributes;                       // get RTTI attribute
			if ((Length(a) > 0)and(a[0] is RMax)) then  // if there is Maximum
				f.Size := RMax(a[0]).limit              // set string size.
			else
				f.Size := 64;                           // otherwise size 64.
		end;
		f.CreateField(d);                               // create it!
    end;

begin
    if (c = nil) then                                   // if model is nil.
		raise Exception.Create('E_INV_ARG: c = nil');   // Tell the problem...
	if (d = nil) then                                   // if dataset is nil.
		raise Exception.Create('E_INV_ARG: d = nil');   // Tell the problem...
	m := c.Create();                                    // Make template.
	closeAndWipeDataSet(d);                          	// close and wipe.
	l := fetchModel(m);                               	// Get model info.
	ctxList.Remove(m);	// Remove from list, will be destroyed in context.
    for r in l do begin                                 // Iterate fields.
		if (r.Visibility <> F_PUBLIC) then              // If not public
            continue;                                   // ignore.
        k := r.FieldType.TypeKind;                      // Get type kind.
        if ((k = tkDynArray) or (k = tkClass)) then     // If array or object
            continue;                                   // ignore (not in data).
        n := r.Name;                                    // Get field name.
        case k of                                       // Read data by type.
        tkEnumeration:
		begin
			if (isEnumBoolean(r.GetValue(m))) then
					newFld(ftBoolean)
			else
					newFld(ftInteger);
		end;
		tkChar,
		tkWChar,
		tkLString,
		tkWString,
		tkUString,
		tkString:   newFld(ftWideString);
		tkFloat:    newFld(ftFloat);
		tkInt64:    newFld(ftLargeInt);
		tkInteger:  newFld(ftInteger);
		else                                            // If invalid type
			m.Free;                                     // Free template.
			raise Exception.Create(                     // Scream and shout...
                'E_INV_TYPE: '
                + n + ' -> '
                + String(r.FieldType.Name)
            );
        end;
	end;
	m.Free;                                             // Delete model object.
	d.Open;                                             // Open dataset.
end;

{———————————————————————————————————————————————————————————————————————————————
    Functions for converting to JSON ...
———————————————————————————————————————————————————————————————————————————————}

{———————————————————————————————————————————————————————————————————————————————
  FUNC: objToJson
  TASK: Converts an object in TValue to TJSONValue.
  ARGS: v:  TValue      : Contains Object to convert to JSON.
  RETV:     TJSONValue  : JSON version of Object in v or null.
  INFO: Do not use these functions directly.
———————————————————————————————————————————————————————————————————————————————}
function    objToJson(v: TValue): TJSONValue;
var
    l: TArray<TRttiField>;                  // List of all fields.
    r: TRttiField;                          // Field data.
    f: TJSONValue;                          // Field value.
	j: TJSONObject;                         // The JSON object.
	n: String;                              // Field name.
	o: Pointer;                             // The object.
begin
	o := v.AsObject;                        // Get an object representation.
	if (o = nil) then                       // If object is nil
		exit(nil);                          // return nil.
	l := fetchModel(o);                   	// Get field list.
    j := TJSONObject.Create;                // Build json object.
    for r in l do                           // Iterate field data in list.
    begin
        if (r.Visibility <> F_PUBLIC) then  // If not a public field
            continue;                       // skip it.
		n := r.Name;                        // Get field name.
		f := valToJson(r.GetValue(o));      // Get JSON of field value.
		if (f = nil) then                   // If empty
			continue;                       // next.
		j.addPair(n, f);                    // Add to Json.
	end;
	result := j;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: valToJson
  TASK: Converts a TValue to TJSONValue.
  ARGS: v:  TValue      : Value to convert to JSON.
  RETV:     TJSONValue  : JSON version of value or null.
———————————————————————————————————————————————————————————————————————————————}
function    valToJson(v: TValue): TJSONValue;
var
    k : TTypeKind;
begin
	k := v.Kind;
	if (k = tkUnknown) then                 	// Delphi bug .
	begin
		if (v.TypeData.ClassType.InheritsFrom(TObject)) then
			k := tkClass;
	end;
	case k of                                   // Add to Json by typekind.
	tkChar,
	tkWChar,
	tkLString,
	tkWString,
	tkUString,
	tkString:       result := strToJson(v);
	tkFloat:        result := TJSONNumber.Create(v.AsExtended);
	tkInt64:        result := TJSONNumber.Create(Int64 (v.AsInt64));
	tkInteger:      result := TJSONNumber.Create(v.AsInteger);
	tkEnumeration:  result := enuToJson(v);
	tkDynArray:     result := dynToJson(v);
	tkClass:        result := objToJson(v);
	else
	begin
		raise Exception.Create(                 // Say I don't support it...
			'E_INV_TYPE: '
			+ String(v.TypeInfo.Name) + ' Kind : ' + intToStr(Integer(k))
		);
	end;
	end;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: strToJson
  TASK: Converts a TValue string to TJSONValue, escaping characters correctly.
  ARGS: v:  TValue      : Value containing string to convert to JSON.
  RETV:     TJSONValue  : JSON version of value or null.
———————————————————————————————————————————————————————————————————————————————}
function    strToJson(v: TValue): TJSONValue;
var
    s,
    r:  String;
	c:  Char;
begin
    s := v.AsString;
    r := '';
    for c in s do
    begin
        case c of
        BSLASH,
        FSLASH: r := r + ESCAPE + c;
        BSPACE: r := r + ESCAPE + 'b';
        F_FEED: r := r + ESCAPE + 'f';
        L_FEED: r := r + ESCAPE + 'n';
        RETURN: r := r + ESCAPE + 'r';
        TABSPC: r := r + ESCAPE + 't';
        else
        begin
            if (Integer(c) < 32) then
            r := r + ESCAPE + 'u' + IntToHex(Integer(c), 4)
        else
            r := r + c;
        end;
        end;
    end;
    if (r = '') then
       exit(nil);
    exit(TJSONString.Create(r));
end;


{———————————————————————————————————————————————————————————————————————————————
  FUNC: enuToJson
  TASK: Converts an Enumeration TValue to TJSONValue.
  ARGS: v:  TValue      : Value to convert to JSON.
  RETV:     TJSONValue  : JSON version of value or null.
  INFO: This just supports booleans, other enumerated types are
        converted directly to integer.
———————————————————————————————————————————————————————————————————————————————}
function    enuToJson(v:TValue): TJSONValue;
var
    b: Boolean;
begin
    if isEnumBoolean(v) then
    begin                                       // If boolean
        b := v.AsBoolean;                       // get value as boolean.
        if b then                               // if true
            result := TJSONTrue.Create
        else                                    // if false
            result := TJSONFalse.Create;
        exit;
    end;                                        // If not enum or boolean
    exit(TJSONNumber.Create(v.AsInteger));
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: dynToJson
  TASK: Converts a dynamic array TValue to TJSONValue.
  ARGS: v:  TValue      : Value to convert to JSON.
  RETV:     TJSONValue  : JSON version of value or null.
———————————————————————————————————————————————————————————————————————————————}
function    dynToJson(v: TValue): TJSONArray;
var
    j: TJSONValue;                              // JSON for items.
    i,                                          // Array Indexer.
    l: Integer;                                 // Array length.
begin
    l      := v.GetArrayLength;                 // Get array length.
    if (l = 0) then                             // If length is 0
       exit(nil);                               // Nothing to convert.
    result := TJSONArray.Create;                // Make JSON array.
    for i  := 0 to l - 1 do                     // Iterate array
    begin
        j := valToJson(v.GetArrayElement(i));   // Convert element to JSON.
        result.AddElement(j);                   // Add it to array.
    end;
end;

{———————————————————————————————————————————————————————————————————————————————
    Functions for converting from JSON ...
———————————————————————————————————————————————————————————————————————————————}
// Access RDepends attribute if any.
function 	getDepends(r: TRttiField): RDepends;
var
	arr : TArray<TCustomAttribute>;
	atr : TCustomAttribute;
begin
	arr 	:= r.GetAttributes;
	result 	:= nil;
	for atr in arr do
	begin
		if (atr is RDepends) then
			exit(RDepends(atr));
	end;
end;

// Resolve RDepend value for JSON.
function	getDependJSON(r: TRttiField; j: TJSONObject): TClass;
var
	nam,
	val : String;
	dep : RDepends;
	jPa : TJSONPair;
begin
	nam := r.Name;
	dep	:= getDepends(r);
	if (dep = nil) then
		raise Exception.Create('E_DEP_NONE: '+nam);
	jPa := j.Get(dep.ref);
	if (jPa = nil) then
		raise Exception.Create(
			'E_DEP_JSON_NIL: '
			+nam +' <- '+ dep.ref
		);
	val := TJSONString(jPa.JsonValue).Value;
	result := dep.Cls[val];

	if (result = nil) then
		raise Exception.Create(
			'E_DEP_JSON_VAL: '
			+nam+' <- '+dep.ref
			+' = ''' + val + ''''
		);
end;

// Prepare sub object models with dependancy
function 	prepJ2O(j: TJSONObject; v: TValue; r: TRttiField): TValue;
var
	o : TObject;
	c : TClass;
begin
	o := v.AsObject;
	if (o <> nil) then
		exit(v);
	c := v.TypeData.ClassType;
	if ((c = TObject) or (c = TModel)) then
		c := getDependJSON(r, j);
	o := c.Create;
	TValue.MakeWithoutCopy(@o, c.ClassInfo, result);
end;

// Prepare Array sub object models with dependancy
function 	prepJ2A(j: TJSONObject; v: TValue; r: TRttiField; l: LongInt): TValue;
var
	c: TClass;
	e: TValue;
	p: Pointer;
	i: Integer;
	o: TObject;
begin
	if (l = 0) then                                 // If length = 0
		exit(v);                                    // return as is.
	p := v.GetReferenceToRawData;                   // Get pointer at heap.
	DynArraySetLength(PPointer(p)^,v.TypeInfo,1,@l);// Set array size  (magic).
	e := v.GetArrayElement(0);						// Get a sample;
	case e.Kind of
	tkUnknown,
	tkClass	:
	begin
		c := e.TypeData.ClassType;
		if ((c = TObject) or (c = TModel)) then		// If class is dependant.
			c := getDependJson(r, j);
	end;
	else
		exit(v);
	end;
	for i := 0 to l - 1 do                          // Iterate fields.
	begin
		e := v.GetArrayElement(i);                  // Get info for element.
		if (e.asObject = nil) then
		begin
			o := c.Create;
			TValue.MakeWithoutCopy(@o, c.ClassInfo, e);
		end;
		v.SetArrayElement(i, e);                    // Put to array.
	end;
    result := v;
end;


{———————————————————————————————————————————————————————————————————————————————
  FUNC: jsonToObj
  TASK: Uses a TJSONObject to a fill fields of a model object in a TValue.
  ARGS: j:  TJSONObject : JSON object containing the field values.
		v:  TValue      : Model object in TValue.
  RETV:     TValue      : Model object in TValue.
———————————————————————————————————————————————————————————————————————————————}
function   jsonToObj(j: TJSONObject; v: TValue): TValue;
var
	mObj: TObject;                              	// Model object.
	rLst: TArray<TRttiField>;                   	// RTTI List of all fields.
	rFld: TRttiField;                           	// RTTI per field.

	jFld: TJSONPair;                            	// JSON name value pair.
	jVal: TJSONValue;                           	// Field as TJSONValue.

	fVal: TValue;                               	// Field as TValue.
	fNam: String;                               	// Field name.
	fKnd: TTypeKind;                                // Field type.
begin
	if (j = nil) then                               // No json -> nothing to fill.
		exit(v);
	mObj := v.AsObject;                            	// Unpack model.
	if (mObj = nil) then
		exit(v);
	rLst := fetchModel(mObj);                     	// Get RTTI list.
	for rFld in rLst do                             // Iterate RTTI list.
	begin
		if (rFld.Visibility <> F_PUBLIC) then       // If not a public field
			continue;                               // skip it.
		fNam := rFld.Name;
		jFld := j.Get(fNam);                        // Get JSON pair.
		jVal := nil;
		if (jFld <> nil) then                       // If there is a pair.
			jVal := jFld.JsonValue;                 // get field json data.
		if ((jFld = nil)                            // If no such pair.
		or	(jVal.ClassType = TJSONNull)) then      // or value is null
		begin
			rFld.SetValue(mObj, nil);               // Clear that field.
            continue;                               // Next.
		end;
		fVal := rFld.GetValue(mObj);				// Get field as template.
		fKnd := fVal.Kind;							// Get field kind.
		// TIP UYUSMAZLIGI KORUMASI: model alani dizi/nesne bekliyor ama JSON'da
		//   baska tipte geldiyse hard-cast (TJSONArray(jVal).Size) gecersiz bellek
		//   okur = access violation. Uyusmayan alani bos birak, digerlerine devam et.
		if ((fKnd = tkDynArray) and (not (jVal is TJSONArray)))
		or ((fKnd = tkClass)    and (not (jVal is TJSONObject))) then
		begin
			rFld.SetValue(mObj, nil);
			continue;
		end;
		case fKnd of                                // Prepare if obj. or array.
		tkUnknown,
		tkClass:	fVal :=	prepJ2O(j, fVal, rFld);
		tkDynArray: fVal :=	prepJ2A(j, fVal, rFld, TJSONArray(jVal).Size);
		end;
		fVal := jsonToVal(jVal, fVal);         		// Convert to TValue.
		rFld.SetValue(mObj, fVal);                  // Set it
    end;
	TValue.MakeWithoutCopy(@mObj, mObj.ClassType.ClassInfo, result);
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: jsonToVal
  TASK: Converts a TJSONValue to TValue.
  ARGS: j:  TJSONArray  : JSON array containing the array values.
        v:  TValue      : TValue containing the model field info.
  RETV:     TValue      : TValue containing the field value.
———————————————————————————————————————————————————————————————————————————————}
function   jsonToVal(j: TJSONValue; v: TValue): TValue;
var
	k: TTypeKind;
begin

	k := v.Kind;
	if (k = tkUnknown) then                 // Delphi bug when array of object.
	begin
		if (v.TypeData.ClassType.InheritsFrom(TObject)) then
			k := tkClass;
	end;

    case k of                               // Fill the value by typekind
    tkChar,
    tkWChar,
    tkLString,
    tkWString,
    tkUString,
    tkString:       v := jsonToStr(TJSONString(j));
    tkFloat:        v := TJSONNumber(j).AsDouble;
    tkInt64:        v := TJSONNumber(j).AsInt64;
    tkInteger:      v := TJSONNumber(j).AsInt;
    tkEnumeration:
	begin
		if (j.ClassType = TJSONTrue) then
			v := TValue(true)
		else
		begin
			if (j.ClassType = TJSONFalse) then
				v := TValue(false)
			else
				v := TValue(TJSONNumber(j).AsInt);
		end;
	end;
    tkDynArray:     v := jsonToDyn(TJSONArray(j), v);   // Prepared already.
	tkClass:        v := jsonToObj(TJSONObject(j), v);  // Prepared already.
	else
		raise Exception.Create(                         // I don't do it...
             'E_JSON_TO_TYPE: '
            + j.ClassName
            + ' -> '
            + String(v.TypeInfo.Name)
        );
    end;
    result := v;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: jsonToDyn
  TASK: Converts a TJSONArray to a model dynamic array field in TValue.
  ARGS: j:  TJSONArray  : JSON array containing the array values.
        v:  TValue      : Model dynamic array field in TValue
———————————————————————————————————————————————————————————————————————————————}
function    jsonToDyn(j: TJSONArray; v: TValue): TValue;
var
	e: TValue;
	k: TJSONValue;
	i,
	c: LongInt;
begin
	c := TJSONArray(j).Size;                        // Get size.
	for i := 0 to c - 1 do                          // Iterate fields.
	begin
		e := v.GetArrayElement(i);                  // Get info for element.
		k := j.Get(i);                              // Get JSON for element.
		e := jsonToVal(k, e);                       // Convert element.
		v.SetArrayElement(i, e);                    // Put to array.
	end;
	result := v;
end;


{———————————————————————————————————————————————————————————————————————————————
  FUNC: jsonToStr
  TASK: Converts a TJSONString to TValue, unescaping characters correctly.
  ARGS: j:  TJSONString : JSON containing string to convert.
  RETV:     TValue      : Unescaped version of value.
———————————————————————————————————————————————————————————————————————————————}
function    jsonToStr(j: TJSONString): TValue;
var
    s,
    r:  String;
    i,
    l:  Integer;
begin
    s := j.Value;
    r := '';
    i := 1;
    l := length(s);

    while (i <= l) do
    begin
        if s[i] = '\' then
        begin
            inc(i);
            case s[i] of
            FSLASH,
            BSLASH  :   r := r + s[i];
            'b'     :   r := r + BSPACE;
            'f'     :   r := r + F_FEED;
            'n'     :   r := r + L_FEED;
            'r'     :   r := r + RETURN;
            't'     :   r := r + TABSPC;
            'u'     :
            begin
                inc(i);
                r := r + char(StrToInt('$'+ Copy(s, i, 4)));
                i := i + 4;
            end;
            else
                r := r + s[i];
            end;
        end
        else
        begin
            r := r + s[i];
        end;
		inc(i);
    end;
    result := TValue(r);
end;



initialization
	initUnit;

finalization
    exitUnit;

end.

