unit fbDatamodule;
{
  https://developers.facebook.com/docs/facebook-login/guides/access-tokens/
}

{$i DefFacebook.inc}

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope
  ,Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter
  , System.Hash
  , System.JSON
  , uSocialCommon
  , fbCommon
  , fbClasses
  ;

type

  TdmFaceBook = class(TDataModule)
    fb_GET_ACCESS_TOKEN_Client1: TRESTClient;
    fb_GET_ACCESS_TOKEN_Request: TRESTRequest;
    fb_GET_ACCESS_TOKEN_Response: TRESTResponse;
    RESTDataSetAdapter1: TRESTResponseDataSetAdapter;
    fb_GET_ACCESS_Table: TFDMemTable;
    fb_GGET_ACCESS_DataSource: TDataSource;
    fb_GET_PAGE_FEED_Client: TRESTClient;
    fb_GET_PAGE_FEED_Request: TRESTRequest;
    fb_GET_PAGE_FEED_Response: TRESTResponse;
    fb_GET_INFO_Client: TRESTClient;
    fb_GET_INFO_Request: TRESTRequest;
    fb_GET_INFO_Response: TRESTResponse;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TTokenType = (bearer, jwt, failed);

   RecTokenType=Record
     access_token : string;
     token_type   : TTokenType;
     content      : string;
     StatusCode   : integer;
   End;

  TFacebookObject = class(TPersistent)
  private
    FName: string;
    FID: string;
  public
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
  published
    property ID: string read FID write FID;
    property Name: string read FName write FName;
  end;

  TFaceBookGender = (fbErkek, fbKadin, fbBilinmiyor);

  TFacebookProfile = class;

  TFacebookProfileItem = class(TCollectionItem)
  private
    FProfile: TFacebookProfile;
    procedure SetProfile(const Value: TFacebookProfile);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Profile: TFacebookProfile read FProfile write SetProfile;
  end;

  TFacebookProfileList = class(TCollection)
  private
    function GetItemProfile(Index: integer): TFacebookProfile;
    procedure SetItemProfile(Index: integer; const Value: TFacebookProfile);
  public
    constructor Create;
    function Find(const ID: integer): TFacebookProfile; overload;
    function Find(const ID: string): TFacebookProfile; overload;
    function Add: TFacebookProfile;
    property Items[Index: integer]: TFacebookProfile read GetItemProfile write SetItemProfile; default;
  end;


  TFacebookObjectItem = class(TCollectionItem)
  private
    FObject: TFacebookObject;
    procedure SetObject(const Value: TFacebookObject);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property FacebookObject: TFacebookObject read FObject write SetObject;
  end;

  TFacebookObjectList = class(TCollection)
  private
    function GetObjectItem(Index: integer): TFacebookObject;
    procedure SetObjectItem(Index: integer; const Value: TFacebookObject);
  public
    constructor Create;
    function Find(const ID: integer): TFacebookObject; overload;
    function Find(const ID: string): TFacebookObject; overload;
    function Add: TFacebookObject;
    property Items[Index: integer]: TFacebookObject read GetObjectItem write SetObjectItem; default;
  end;

  TFacebookComment = class(TPersistent)
  private
    FID: string;
    FCreatedTime: TDateTime;
    FUser: TFacebookProfile;
    FText: string;
    FLikes: TFacebookProfileList;
    FUserLikes: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
  published
    property ID: string read FID write FID;
    property User: TFacebookProfile read FUser write FUser;
    property UserLikes: boolean read FUserLikes write FUserLikes;
    property Text: string read FText write Ftext;
    property CreatedTime: TDateTime read FCreatedTime write FCreatedTime;
    property Likes: TFacebookProfileList read FLikes write FLikes;
  end;

  TFacebookCommentItem = class(TCollectionItem)
  private
    FObject: TFacebookComment;
    procedure SetObject(const Value: TFacebookComment);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property FacebookComment: TFacebookComment read FObject write SetObject;
  end;


  TFacebookCommentList = class(TCollection)
  private
    function GetObjectItem(Index: integer): TFacebookComment;
    procedure SetObjectItem(Index: integer; const Value: TFacebookComment);
  public
    constructor Create;
    function Find(const ID: integer): TFacebookComment; overload;
    function Find(const ID: string): TFacebookComment; overload;
    function Add: TFacebookComment;
    property Items[Index: integer]: TFacebookComment read GetObjectItem write SetObjectItem; default;
  end;

  TFacebookPicture = class(TPersistent)
  private
    FCaption: string;
    FID: string;
    FCreatedTime: TDateTime;
    FImageURL: string;
    FLink: string;
    FFrom: TFacebookProfile;
    FUpdatedTime: TDateTime;
  public
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
  published
    property ID: string read FID write FID;
    property Caption: string read FCaption write FCaption;
    property From: TFacebookProfile read FFrom write FFrom;
    property ImageURL: string read FImageURL write FImageURL;
    property Link: string read FLink write FLink;
    property CreatedTime: TDateTime read FCreatedTime write FCreatedTime;
    property UpdatedTime: TDateTime read FUpdatedTime write FUpdatedTime;
  end;

  TFacebookPictureItem = class(TCollectionItem)
  private
    FPicture: TFacebookPicture;
    procedure SetPicture(const Value: TFacebookPicture);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property FacebookPicture: TFacebookPicture read FPicture write SetPicture;
  end;

  TFacebookPictureList = class(TCollection)
  private
    function GetPictureItem(Index: integer): TFacebookPicture;
    procedure SetPictureItem(Index: integer; const Value: TFacebookPicture);
  public
    constructor Create;
    function Find(const ID: integer): TFacebookPicture; overload;
    function Find(const ID: string): TFacebookPicture; overload;
    function Add: TFacebookPicture;
    property Items[Index: integer]: TFacebookPicture read GetPictureItem write SetPictureItem; default;
  end;

  TFacebookAlbum = class(TPersistent)
  private
    FTitle: string;
    FID: string;
    FCreatedTime: TDateTime;
    FLink: string;
    FFrom: TFacebookProfile;
    FUpdatedTime: TDateTime;
    FCoverPhotoID: string;
    FDescription: string;
    FPictures: TFacebookPictureList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
  published
    property ID: string read FID write FID;
    property Title: string read FTitle write FTitle;
    property From: TFacebookProfile read FFrom write FFrom;
    property Link: string read FLink write FLink;
    property Description: string read FDescription write FDescription;
    property CoverPhotoID: string read FCoverPhotoID write FCoverPhotoID;
    property CreatedTime: TDateTime read FCreatedTime write FCreatedTime;
    property UpdatedTime: TDateTime read FUpdatedTime write FUpdatedTime;
    property Pictures: TFacebookPictureList read FPictures write FPictures;
  end;


  TFacebookAlbumItem = class(TCollectionItem)
  private
    FAlbum: TFacebookAlbum;
    procedure SetAlbum(const Value: TFacebookAlbum);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property FacebookAlbum: TFacebookAlbum read FAlbum write SetAlbum;
  end;

  TFacebookAlbumList = class(TCollection)
  private
    function GetAlbumItem(Index: integer): TFacebookAlbum;
    procedure SetAlbumItem(Index: integer; const Value: TFacebookAlbum);
  public
    constructor Create;
    function Find(const ID: integer): TFacebookAlbum; overload;
    function Find(const ID: string): TFacebookAlbum; overload;
    function Add: TFacebookAlbum;
    property Items[Index: integer]: TFacebookAlbum read GetAlbumItem write SetAlbumItem; default;
  end;


  TFacebookFeedItem = class(TPersistent)
  private
    FUser: TFacebookProfile;
    FID: string;
    FText: string;
    FSummary: string;
    FStory: string;
    FCreatedTime: TDateTime;
    FImageURL: string;
    FLink: string;
    FLikes: TFacebookProfileList;
    FCaption: string;
    FDescription: string;
    FObjectID: string;
    FToUsers: TFacebookProfileList;
    FUpdatedTime: TDateTime;
    FComments: TFacebookCommentList;
    procedure SetUser(const Value: TFacebookProfile);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
    property User: TFacebookProfile read FUser write SetUser;
    property ID: string read FID write FID;
    property Text: string read FText write FText;
    property ImageURL: string read FImageURL write FImageURL;
    property Link: string read FLink write FLink;
    property Summary: string read FSummary write FSummary;
    property Caption: string read FCaption write FCaption;
    property Description: string read FDescription write FDescription;
    property CreatedTime: TDateTime read FCreatedTime write FCreatedTime;
    property Story: string read FStory write FStory;
    property ObjectID: string read FObjectID write FObjectID;
    property UpdatedTime: TDateTime read FUpdatedTime write FUpdatedTime;
    property Likes: TFacebookProfileList read FLikes write FLikes;
    property ToUsers: TFacebookProfileList read FToUsers write FToUsers;
    property Comments: TFacebookCommentList read FComments write FComments;
  end;

  TFeedItem = class(TCollectionItem)
  private
    FFeedItem: TFacebookFeedItem;
    procedure SetFeedItem(const Value: TFacebookFeedItem);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property FeedItem: TFacebookFeedItem read FFeedItem write SetFeedItem;
  end;

  TFeed = class(TCollection)
  private
    function GetFeedItem(Index: integer): TFacebookFeedItem;
    procedure SetFeedItem(Index: integer; const Value: TFacebookFeedItem);
  public
    constructor Create;
    property Items[Index: integer]: TFacebookFeedItem read GetFeedItem write SetFeedItem; default;
    function Add: TFacebookFeedItem;
  end;



  TFacebookProfile = class(TPersistent)
  private
    FFullName: string;
    FLastName: string;
    FGender: TFacebookGender;
    FFirstName: string;
    FLink: string;
    FID: string;
    FEmail: string;
    FBirthDay: string;
    FVerified: boolean;
    FLocale: string;
    FTimeZone: double;
    FUpdatedTime: TDateTime;
    FUserName: string;
    FMiddleName: string;
    FImageURL: string;
    FLocation: TFacebookObject;
    FRelationShip: string;
    FSignificantOther: TFacebookObject;
    FWebsite: string;
    FHomeTown: TFacebookObject;
    FLikes: TFacebookObjectList;
    FFeed: TFeed;
    FAlbums: TFacebookAlbumList;
  public
    procedure Assign(Source: TPersistent); override;
    procedure FromJSON(jo: TJSONObject);
    constructor Create;
    destructor Destroy; override;
  published
    property ID: string read FID write FID;
    property FullName: string read FFullName write FFullName;
    property FirstName: string read FFirstName write FFirstName;
    property LastName: string read FLastName write FLastName;
    property MiddleName: string read FMiddleName write FMiddleName;
    property Gender: TFacebookGender read FGender write FGender;
    property Link: string read FLink write FLink;
    property UserName: string read FUserName write FUserName;
    property BirthDay: string read FBirthDay write FBirthDay;
    property Email: string read FEmail write FEmail;
    property TimeZone: double read FTimeZone write FTimeZone;
    property Locale: string read FLocale write FLocale;
    property Verified: boolean read FVerified write FVerified;
    property UpdatedTime: TDateTime read FUpdatedTime write FUpdatedTime;
    property ImageURL: string read FImageURL write FImageURL;
    property HomeTown: TFaceBookObject read FHomeTown write FHomeTown;
    property Location: TFaceBookObject read FLocation write FLocation;
    property RelationShip: string read FRelationShip write FRelationShip;
    property SignificantOther: TFacebookObject read FSignificantOther write FSignificantOther;
    property Website: string read FWebsite write FWebsite;
    property Likes: TFacebookObjectList read FLikes write FLikes;
    property Feed: TFeed read FFeed;
    property Albums: TFacebookAlbumList read FAlbums write FAlbums;
  end;

 TArguman = class
 private
   fKod ,
   fDeger : string;
   fFieldType : TFieldType;
 public
   constructor Create(const cKod , cDeger : string; ftype : TFieldType = ftString);
   property Kod : string read fKod write fKod;
   property Deger : string read fDeger write fDeger;
   property FieldType : TFieldType read fFieldType write fFieldType;
 end;

   argumanArray = array of TArguman;



const


    {$if defined(WIN32) or defined (win64)}
    __ = #13#10;
    {$else}
    __ = #10;
    {$endif}

var
  dmFaceBook: TdmFaceBook;

function GetJSONValue(O: TJSONObject; ID: string): TJSONValue;
function GetJSONProp(O: TJSONOBject; ID: string): string; overload;
function GetJSONProp(JSON: string; ID: string): string; overload;
function GetJSONPropCheck(jo: TJSONObject; PropName: string): string;

function IsoToDateTime(const s: string):TDateTime; overload;
function IsoToDateTime(const s: string; IsUTC: Boolean): TDateTime; overload;
function IsoToDate(const s: string):TDateTime;




function GetAppAccessToken( clientID, clientSecret : string) : RecTokenType;
function GetPageAccesToken( userId, userAccessToken : string) : string;
function GetLongLiveUserAccesToken( clientID, clientSecret, userAccessToken : string) : string;
function GetPageFeed( pageID, fieldsParam : string; pageToken : string) : string;
function GetUserInfo( AppID, AppSecret, userAccessToken : string) : TFacebookProfile;
function FaceBookSecret(Content, Key : string ) : string;
function GetConversationsList( _pageID : string; _platform : string; _token : string; _List : TFbItems)  : integer;
function GetMessagesList( _messageID : string; _platform : string; _token : string; _List : TFbItems)  : integer;
function GetMessageData( _messageId : string; _fields : string; _platform : string; _token : string) : TMessageDataRec;

function GetFormsByPage( _pageId, _token : string; _List : TFbItems) : integer; // ok
function GetLeadsByForm( _formId, _token : string ; _List : TfbItems) : integer; //ok
function GetLeadData( _leadID, _token : string) : recLead;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
   System.DateUtils;

{$R *.dfm}




function FaceBookSecret(Content, Key : string ) : string;
begin
  Result := THashSHA2.GetHMAC( Content, Key, THashSHA2.TSHA2Version.SHA256);
end;


{ TArguman }

constructor TArguman.Create(const cKod, cDeger: string; ftype : TFieldType = ftString);
begin
//
 inherited Create;
 fKod := cKod;
 fDeger := cDeger;
 fFieldType := ftype;
end;

function JsonFromParam( const _arguman : array of TArguman; NonFreeArgs : boolean = False )  : TJSONObject;
var
 i : integer;
begin
    Result := TJSONObject.Create();
    try
      for i := 0 to High(_arguman) do
      begin
        if Trim(_arguman[i].Kod)<>'' then
        begin
          Result.AddPair(_arguman[i].Kod,  _arguman[i].Deger);
        end;
      end;
    finally
      // Result.Free;
    end;
end;

function GetAppAccessToken( clientID, clientSecret : string) : RecTokenType;
{
var
  jRequest : TJSONObject;
}
begin
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.ClearBody;

     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('client_id', clientID);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('client_secret', clientSecret);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('grant_type', 'client_credentials');

     dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL := varBaseURL + '/'+ cGetaccessToke;
     //{--} LogAppStatus('URL = '#13#10+ dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL);

     dmFaceBook.fb_GET_ACCESS_TOKEN_Response.RootElement := '';
     Result.token_type := TTokenType.failed;

     try
       dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Execute;
       Result.content := dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Response.JSONText;

       //{--} LogAppStatus('Resource = '+cGetaccessToke+__+Result.content);

       if dmFaceBook.fb_GET_ACCESS_TOKEN_Response.StatusText ='OK' then
        begin
          Result.StatusCode := dmFaceBook.fb_GET_ACCESS_TOKEN_Response.StatusCode;
          Result.access_token := dmFaceBook.fb_GET_ACCESS_Table.Fields[0].AsString;
          if dmFaceBook.fb_GET_ACCESS_Table.Fields[1].AsString='bearer' then
            Result.token_type := TTokenType.bearer;
        end;
     except
        on Ex_fb_GET_ACCESS00001 : Exception do
        begin
          {--} LogFacebook('** hata : ExUTSrest001 :'+Ex_fb_GET_ACCESS00001.ClassName+__+ Ex_fb_GET_ACCESS00001.Message);
          Result.content := '('+Ex_fb_GET_ACCESS00001.ClassName+') '+Ex_fb_GET_ACCESS00001.Message;
          Result.StatusCode := -1;
          Result.access_token := '';
        end;
     end;

   finally
     dmFaceBook.Free;
   end;
end;


function GetPageAccesToken( userId, userAccessToken : string) : string;
begin
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.ClearBody;

     dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL := varBaseURL + '/'+ userID+'/'+'accounts?access_token='+userAccessToken;

     //{--} LogAppStatus('URL = '#13#10+ dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL);

     dmFaceBook.fb_GET_ACCESS_TOKEN_Response.RootElement := '';

     try
       dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Execute;
       Result := dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Response.JSONText;

       //{--} LogAppStatus({'Result = '+#13#10+}Result);

       if dmFaceBook.fb_GET_ACCESS_TOKEN_Response.StatusText ='OK' then
        begin
          //fRecordCount := fb_GET_ACCESS_Table.RecordCount;
          Result := dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Response.JSONText;
        end;
     except
        on Ex_fb_GET_ACCESS00001 : Exception do
        begin
          {--} LogFacebook('** hata : ExUTSrest001 :'+Ex_fb_GET_ACCESS00001.ClassName+__+ Ex_fb_GET_ACCESS00001.Message);
          Result := 'ERROR ('+Ex_fb_GET_ACCESS00001.ClassName+') '+Ex_fb_GET_ACCESS00001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;
end;


function GetLongLiveUserAccesToken( clientID, clientSecret, userAccessToken : string) : string;
begin
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.ClearBody;
     dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+cGetaccessToke +'?';

     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('fb_exchange_token', userAccessToken);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('grant_type', 'fb_exchange_token');
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('client_id', clientID);
     dmFaceBook.fb_GET_ACCESS_TOKEN_Request.AddParameter('client_secret', clientSecret);


     //{--} LogAppStatus('URL = '#13#10+ dmFaceBook.fb_GET_ACCESS_TOKEN_Client1.BaseURL);

     dmFaceBook.fb_GET_ACCESS_TOKEN_Response.RootElement := '';

     try
       dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Execute;
       Result := dmFaceBook.fb_GET_ACCESS_TOKEN_Request.Response.JSONText;

       //{--} LogAppStatus({'Result = '+#13#10+}Result);

       if dmFaceBook.fb_GET_ACCESS_TOKEN_Response.StatusText ='OK' then
        begin
          Result := dmFaceBook.fb_GET_ACCESS_Table.Fields[0].AsString;
        end
         else
           raise Exception.Create(dmFaceBook.fb_GET_ACCESS_TOKEN_Response.Content);
     except
        on Ex_fb_GET_ACCESS00001 : Exception do
        begin
          {--} LogFacebook('** hata : ExUTSrest001 :'+Ex_fb_GET_ACCESS00001.ClassName+__+ Ex_fb_GET_ACCESS00001.Message);
          Result := 'ERROR ('+Ex_fb_GET_ACCESS00001.ClassName+') '+Ex_fb_GET_ACCESS00001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;
end;


function GetArraySize(ja: TJSONArray): integer;
begin
  {$IFNDEF DELPHIXE6_LVL}
  Result := ja.Size;
  {$ENDIF}

  {$IFDEF DELPHIXE6_LVL}
  Result := ja.Count;
  {$ENDIF}
end;

function GetArrayItem(ja: TJSONArray; Index: integer): TJSONValue;
begin
  {$IFNDEF DELPHIXE6_LVL}
  Result := ja.Get(Index);
  {$ENDIF}

  {$IFDEF DELPHIXE6_LVL}
  Result := ja.Items[Index];
  {$ENDIF}
end;

function GetJSONValue(O: TJSONObject; ID: string): TJSONValue;
var
  p: TJSONPair;
begin
  Result := nil;
  p := o.Get(ID);
  if Assigned(p) then
  begin
    Result := p.JsonValue;
  end;
end;


function GetJSONProp(O: TJSONOBject; ID: string): string; overload;
var
  p: TJSONPair;
begin
  Result := '';
  p := o.Get(ID);
  if Assigned(p) then
    Result := p.JsonValue.Value;
end;


function GetJSONProp(JSON: string; ID: string): string;
var
  StringBytes: TBytes;
  o: TJSONObject;
  p: TJSONPair;

begin
  Result := '';

  StringBytes := TEncoding.ASCII.GetBytes(JSON);

  o := TJSONObject.Create;

  try
    o.Parse(StringBytes,0);
    p := o.Get(ID);
    if Assigned(p) then
    begin
      Result := p.JsonValue.Value;
    end;
  finally
    o.Free;
  end;
end;

function GetJSONPropCheck(jo: TJSONObject; PropName: string): string;
begin
  Result := '';
  if (Pos('"' + PropName + '":', jo.ToString) > 0) then
    Result := GetJSONProp(jo,PropName);
end;



function AdjustDateTime(const ADate: TDateTime; AHourOffset, AMinuteOffset:Integer; IsUTC: Boolean = True): TDateTime;
var
  AdjustDT: TDateTime;
  BiasLocal: Int64;
  BiasTime: Int64;
  BiasHour: Integer;
  BiasMins: Integer;
  BiasDT: TDateTime;
  TZ: TTimeZone;
begin
  Result := ADate;
  if IsUTC then
  begin
    { If we have an offset, adjust time to go back to UTC }
    if (AHourOffset <> 0) or (AMinuteOffset <> 0) then
    begin
      AdjustDT := EncodeTime(Abs(AHourOffset), Abs(AMinuteOffset), 0, 0);
      if ((AHourOffset * MinsPerHour) + AMinuteOffset) > 0 then
        Result := Result - AdjustDT
      else
        Result := Result + AdjustDT;
    end;
  end
  else
  begin
    { Now adjust TDateTime based on any offsets we have and the local bias }
    { There are two possibilities:
        a. The time we have has the same offset as the local bias - nothing to do!!
        b. The time we have and the local bias are different - requiring adjustments }
    TZ := TTimeZone.Local;
    BiasLocal := Trunc(TZ.GetUTCOffset(Result).Negate.TotalMinutes);
    BiasTime  := (AHourOffset * MinsPerHour) + AMinuteOffset;
    if (BiasLocal + BiasTime) = 0 then
      Exit;

    { Here we adjust the Local Bias to make it relative to the Time's own offset
      instead of being relative to GMT }
    BiasLocal := BiasLocal + BiasTime;
    BiasHour := Abs(BiasLocal) div MinsPerHour;
    BiasMins := Abs(BiasLocal) mod MinsPerHour;
     BiasDT := EncodeTime(BiasHour, BiasMins, 0, 0);
    if (BiasLocal > 0) then
      Result := Result - BiasDT
    else
      Result := Result + BiasDT;
  end;
end;


function IsoToDateTime(const s: string):TDateTime;
var
  da,mo,ye,ho,mi,se: Word;
  err: Integer;
begin
  Val(Copy(s,1,4),ye,err);
  Val(Copy(s,6,2),mo,err);
  Val(Copy(s,9,2),da,err);
  Val(Copy(s,12,2),ho,err);
  Val(Copy(s,15,2),mi,err);
  Val(Copy(s,18,2),se,err);

  if ye < 1 then
    ye := 1;
  if mo < 1 then
    mo := 1;
  if da < 1 then
    da := 1;

  Result := EncodeDate(ye,mo,da) + EncodeTime(ho,mi,se,0);
end;


function IsoToDateTime(const s: string; IsUTC: Boolean): TDateTime;
const
  STimePrefix: Char = 'T';
var
  TimeString, DateString: string;
  TimePosition: Integer;
  da,mo,ye,ho,mi,se: Word;
  HourOffset, MinuteOffset: Integer;
  err: Integer;
  sign: string;
begin
  HourOffset := 0;
  MinuteOffset := 0;
  TimePosition := Pos(STimePrefix, s);
  if TimePosition >= 0 then
  begin
    DateString := Copy(s, 0, TimePosition);
    TimeString := Copy(s, TimePosition + 1, Length(s));
  end;

//  Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, Millisecond);
  Val(Copy(s,1,4),ye,err);
  Val(Copy(s,6,2),mo,err);
  Val(Copy(s,9,2),da,err);
  Val(Copy(s,12,2),ho,err);
  Val(Copy(s,15,2),mi,err);
  Val(Copy(s,18,2),se,err);

  if ye < 1 then
    ye := 1;
  if mo < 1 then
    mo := 1;
  if da < 1 then
    da := 1;

  //Get TimeOffset from Iso string
  if Length(s) > 20 then
  begin
    sign := Copy(s,20,1);
    if (sign = '-') or (sign = '+') then
    begin
      Val(Copy(s,22,2), HourOffset, err);
      Val(Copy(s,25,2), MinuteOffset, err);

      if sign = '-' then
      begin
        HourOffset := HourOffset * -1;
        MinuteOffset := MinuteOffset * -1;
      end;
    end;
  end;

  Result := EncodeDate(ye,mo,da) + EncodeTime(ho,mi,se,0);
  Result := AdjustDateTime(Result, HourOffset, MinuteOffset, IsUTC);
end;

function IsoToDate(const s: string):TDateTime;
var
  da,mo,ye: Word;
  err: Integer;
begin
  Val(Copy(s,1,4),ye,err);
  Val(Copy(s,6,2),mo,err);
  Val(Copy(s,9,2),da,err);

  if ye < 1 then
    ye := 1;
  if mo < 1 then
    mo := 1;
  if da < 1 then
    da := 1;

  Result := EncodeDate(ye,mo,da) + EncodeTime(0,0,0,0);
end;


function GetUserInfo( AppID, AppSecret, userAccessToken : string) :  TFacebookProfile;
var
  //resp : string;
  jv,jve: TJSONValue;
begin
   Result := TFaceBookProfile.Create;
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/me';
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields','email,name,first_name,last_name,middle_name,link,id,gender,birthday,website,relationship_status,timezone,locale,verified,updated_time,location,hometown,significant_other');
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', userAccessToken);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  Result.FromJSON(jv as TJSONObject);
                  //Result := true;
                end

             finally
               jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_INFO0001 : Exception do
        begin
          {--} LogFacebook('** hata : ExUTSrest001 :'+Ex_fb_GET_INFO0001.ClassName+__+ Ex_fb_GET_INFO0001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_INFO0001.ClassName+') '+Ex_fb_GET_INFO0001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;

end;

function GetPageFeed( pageID, fieldsParam : string; pageToken : string) : string;
begin
  try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_PAGE_FEED_Request.ClearBody;
     if Pos('me%', fieldsParam)=1 then
      begin
       dmFaceBook.fb_GET_PAGE_FEED_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/me';
       dmFaceBook.fb_GET_PAGE_FEED_Request.AddParameter('fields', fieldsParam);
      end
     else
       dmFaceBook.fb_GET_PAGE_FEED_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+pageID+'/?fields='+fieldsParam;

     dmFaceBook.fb_GET_PAGE_FEED_Request.AddParameter('access_token', pageToken);


     //{--} LogAppStatus('URL = '#13#10+ dmFaceBook.fb_GET_PAGE_FEED_Client.BaseURL);

     dmFaceBook.fb_GET_PAGE_FEED_Response.RootElement := '';

     try
       dmFaceBook.fb_GET_PAGE_FEED_Request.Execute;
       //Result := dmFaceBook.fb_GET_PAGE_FEED_Request.Response.JSONText;

      // {--} LogAppStatus({'Result = '+#13#10+}Result);

       if dmFaceBook.fb_GET_PAGE_FEED_Response.StatusText ='OK' then
        begin
          Result := dmFaceBook.fb_GET_PAGE_FEED_Request.Response.JSONText;
        end
         else
          Result := 'ERROR : '+dmFaceBook.fb_GET_PAGE_FEED_Response.StatusText+' : '+dmFaceBook.fb_GET_PAGE_FEED_Request.Response.JSONText;
     except
        on Ex_fb_GET_PGFEED0001 : Exception do
        begin
          {--} LogFacebook('** hata : ExUTSrest001 :'+Ex_fb_GET_PGFEED0001.ClassName+__+ Ex_fb_GET_PGFEED0001.Message);
          Result := 'ERROR ('+Ex_fb_GET_PGFEED0001.ClassName+') '+Ex_fb_GET_PGFEED0001.Message;
        end;
     end;

  finally
      dmFaceBook.Free;
  end;
end;

function GetConversationsList( _pageID : string; _platform : string; _token : string; _List : TFbItems) : integer;
var
  jv,jve: TJSONValue;
  jo : TJSONObject;
  //jva: TJSONValue;
  ja: TJSONArray;

  item : TFbItem;
  newItemId : string;
  i : integer;
begin
  Result := -1;
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_pageID+'/conversations';
     dmFaceBook.fb_GET_INFO_Request.AddParameter('platform',_platform);
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
       // {--} LogAppStatus('GetConversationsList('+_pageId+','+_platform+#13#10);
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
            // {--} LogAppStatus(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  jo := jv as TJSONObject;
                  ja := GetJSONValue(jo,'data') as TJSONArray;
                  for i := 0 to GetArraySize(ja) - 1 do
                  begin
                    jo := GetArrayItem(ja, i) as TJSONObject;
                    newItemId := GetJSONValue(jo,'id').Value;
                    if _List.IndexOf(newItemId)<0 then
                    begin
                      item := _List.Add;
                      item.ItemType := fbConversation;
                      item.Platform := _platform;
                      item.Text := '';
                      item.ItemId := newItemId;
                      if GetJSONValue(jo,'link')<>nil then
                       item.Link := GetJSONValue(jo,'link').Value;
                      item.UpdateTime := GetJSONValue(jo,'updated_time').Value;
                     end;
                  end;
                end
             finally
               jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_ConversationO0001 : Exception do
        begin
          Result := -2;
          {--} LogFacebook('** hata  :'+Ex_fb_GET_ConversationO0001.ClassName+__+ Ex_fb_GET_ConversationO0001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_ConversationO0001.ClassName+') '+Ex_fb_GET_ConversationO0001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;
end;

function GetMessagesList( _messageID : string; _platform : string; _token : string; _List : TFbItems)  : integer;
var
  jv,jve  : TJSONValue;
  jvm : TJSONObject;
  jo   : TJSONObject;
  //jva: TJSONValue;
  ja: TJSONArray;

  item : TFbItem;
  newItemId : string;
  i : integer;
begin
  Result := -1;
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_messageID;
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields','messages');
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
        {--} LogFacebook('GetMessageList('+_messageID+')'#13#10);
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
            // {--} LogAppStatus(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  //jo := jv as TJSONObject;
                  jvm := GetJSONValue(jv as TJsonObject,'messages') as TJsonObject;
                  if Assigned(jvm) then
                  begin
                    //jo := jvm as TJSONObject;
                    ja := GetJSONValue(jvm,'data') as TJSONArray;
                    for i := 0 to GetArraySize(ja) - 1 do
                    begin
                      jo := GetArrayItem(ja, i) as TJSONObject;
                      newItemId := GetJSONValue(jo,'id').Value;
                      if _List.IndexOf(newItemId)<0 then
                      begin
                        item := _List.Add;
                        item.Platform := _platform;
                        item.ItemType := fbMessage;
                        item.Text := '';
                        item.ItemId := newItemId;
                        item.Link := '';
                        item.UpdateTime := GetJSONValue(jo,'created_time').Value;
                       end;
                    end;
                  end;
                end
             finally
               if Assigned(jv) then
                 jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_MsgListaO0001 : Exception do
        begin
          Result := -2;
          {--} LogFacebook('** hata : '+Ex_fb_GET_MsgListaO0001.ClassName+__+ Ex_fb_GET_MsgListaO0001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_MsgListaO0001.ClassName+') '+Ex_fb_GET_MsgListaO0001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;
end;


function GetMessageData( _messageId : string; _fields : string; _platform : string; _token : string) : TMessageDataRec;


      function ParseByTag( _tag : string; var _source : string) : string;
      var
        pPos : integer;
        diffLen : integer;
        endPos : integer;
        tempStr : string;
      begin
        pPos := Pos(_tag,_source);
        if pPos>0 then
         begin
            tempStr := Copy(_source,pPos + Length(_tag),2048);
            endPos := Pos(#10,tempStr);
            diffLen := 0;
            if endPos>0 then
               diffLen := endPos + Length(_tag)
            else
              diffLen := 4096;
            Delete(tempStr,endPos,2048);
            Result := tempStr;
            Delete(_source,pPos,difflen);
         end;
      end;

      function ParseFirst(var  _source : string) : string;
      var
        pPos : integer;
      begin
          pPos := Pos(#10, _source);
          if pPos>0 then
           begin
             Result := Copy(_source,1,pPos-1);
             Delete(_source,1,pPos);
           end
         else
           begin
              Result := _source;
              _source :='';
           end;
      end;

var
  jv,jve  : TJSONValue;
  jVo_from
  //,jVo_message
  //,jvm
  : TJSONObject;

  jVData_from : TJSONValue;
  jVcreateTime,
  jVData_message : TJSONValue;
  firstStr  : string;
  //tempStr : string;
  //item : TFbItem;
  //newItemId : string;
  //pPos : integer;
  //i : integer;

begin
  Result := Default(TMessageDataRec);
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_messageID;
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields',_fields);
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
        {--} LogFacebook('GetMessageData('+_messageID+'), fields='+_fields+ #13#10);
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
             //{--} LogAppStatus(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin

                  jVo_from := GetJSONValue(jv as TJsonObject,'from') as TJsonObject;
                  if Assigned(jVo_from) then
                  begin
                    if _platform='INSTAGRAM' then
                     begin
                        if jVo_from.Get('username')<>nil then
                          Result.from_name := GetJSonValue(jVo_from, 'username').Value;
                        if jVo_from.Get('id')<>nil then
                         Result.from_id := GetJSonValue(jVo_from, 'id').Value;
                        if jVo_from.Get('email')<>nil then
                         Result.from_eMail := GetJSonValue(jVo_from, 'email').Value;
                     end
                      else
                      begin
                        if jVo_from.Get('name')<>nil then
                          Result.from_name := GetJSonValue(jVo_from, 'name').Value;
                        if jVo_from.Get('id')<>nil then
                         Result.from_id := GetJSonValue(jVo_from, 'id').Value;
                        if jVo_from.Get('email')<>nil then
                         Result.from_eMail := GetJSonValue(jVo_from, 'email').Value;
                     end;
                  end;

                  jVcreateTime := GetJSONValue(jv as TJsonObject,'created_time');
                  if jVcreateTime<>nil then
                    Result.created_time := jVcreateTime.Value;

                  jVData_message := GetJSONValue(jv as TJsonObject,'message');
                  if Assigned(jVData_message) then
                  begin
                    firstStr := jVData_message.Value;
                        firstStr := StringReplace(firstStr,#10#10,#10,[rfReplaceAll]);
                        firstStr := StringReplace(firstStr,#13#10,#10,[rfReplaceAll]);
                        firstStr := StringReplace(firstStr,'Ad ve soyadý'#10,'Ad ve soyadý:',[rfReplaceAll]);
                        firstStr := StringReplace(firstStr,'Telefon numarasý'#10,'Telefon numarasý:',[rfReplaceAll]);
                        firstStr := StringReplace(firstStr,'E-posta'#10,'E-posta:',[rfReplaceAll]);

                        Result.message := firstStr;

                    if _platform='INSTAGRAM' then
                     begin
                        Result.message_UserName := Result.from_name;
                        Result.PageName := 'Instagram';
                     end
                       else
                     begin

                        Result.message_UserName  := ParseByTag('Ad ve soyadý:',firstStr);
                        Result.message_Phone  := ParseByTag('Telefon numarasý:',firstStr);
                        Result.message_email    := ParseByTag('E-posta:',firstStr);
                        Result.PageName :=  ParseFirst( firstStr);
                        Result.Title := ParseFirst( firstStr);
                      end;
                  end;
                  // Sað/Sol boþluklar temizlenmeli
                  Result.from_id := TrimLeft(TrimRight(Result.from_id));
                  Result.message_UserName := TrimLeft(TrimRight(Result.message_UserName));

                end // if Assigned(jve);
                  else
                    Result.error := jve.Value;
             finally
               if Assigned(jv) then
                 jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_MsgListaO0001 : Exception do
        begin
          Result.error := Ex_fb_GET_MsgListaO0001.Message;
          {--} LogFacebook('** hata : '+Ex_fb_GET_MsgListaO0001.ClassName+__+ Ex_fb_GET_MsgListaO0001.Message);
        end;
     end;
   finally
     dmFaceBook.Free;
   end;

end;

// https://graph.facebook.com/v18.0/{pageID}164408166754533/leadgen_forms

function GetFormsByPage( _pageId, _token : string; _List : TFbItems) : integer;
var
  jv,jve  : TJSONValue;
  jo   : TJSONObject;

  ja: TJSONArray;

  item : TFbItem;
  newItemId : string;
  activeStr : string;
  i : integer;
begin
  Result := -1;
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_pageId+'/leadgen_forms';
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields','id,locale,name,status');
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        {--} LogFacebook('GetFormsByPage('+_pageId+') try to Execute'#13#10);
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;

        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
             {--} LogFacebook(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  jo := jv as TJSONObject;
                  ja := GetJSONValue(jo,'data') as TJSONArray;
                  Result := 0;
                  for i := 0 to GetArraySize(ja) - 1 do
                  begin
                    jo := GetArrayItem(ja, i) as TJSONObject;
                    newItemId := GetJSONValue(jo,'id').Value;
                    if _List.IndexOf(newItemId)<0 then
                    begin
                      item := _List.Add;
                      item.ItemType := fbLeadForm;
                      item.Platform := '';
                      if GetJSONValue(jo,'name')<>nil then
                        item.Text := GetJSONValue(jo,'name').Value;
                      item.ItemId := newItemId;
                      if GetJSONValue(jo,'locale')<>nil then
                        item.Locale := GetJSONValue(jo,'locale').Value;
                      if (GetJSONValue(jo,'status')<>nil) then
                        activeStr := GetJSONValue(jo,'status').Value;
                      item.Status := (activeStr = 'ACTIVE');
                     end;
                  end;
                end
             finally
               if Assigned(jv) then
                 jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_FormsByPage001 : Exception do
        begin
          Result := -2;
          {--} LogFacebook('** hata : '+Ex_fb_GET_FormsByPage001.ClassName+__+ Ex_fb_GET_FormsByPage001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_FormsByPage001.ClassName+') '+Ex_fb_GET_FormsByPage001.Message;
        end;
     end;

   finally
     dmFaceBook.Free;
   end;

end;

//https://graph.facebook.com/v18.0/1569153207222534?fields=leads{id}
function GetLeadsByForm( _formId, _token : string ; _List : TfbItems) : integer;
var
  jv,jve,jvL  : TJSONValue;
  jo,jvm   : TJSONObject;
  ja: TJSONArray;
  item : TFbItem;
  newItemId : string;
  i : integer;
  tempStatusStr : string;
  tempStatus : boolean;
  leadCount : integer;
begin
(*
  //https://graph.facebook.com/v18.0/1569153207222534?fields=organic_leads_count,name,id,page,created_time,status,leads{id},expired_leads_count
{
  "organic_leads_count": 3,
  "name": "Granit'(n)in 2 Aralýk 2023 Cumartesi 14:31 tarihinde oluþturduðu form",
  "id": "1569153207222534",
  "page": {
    "name": "Granit",
    "id": "164408166754533"
  },
  "created_time": "2023-12-02T11:31:25+0000",
  "status": "ACTIVE",
  "leads": {
    "data": [
      {
        "id": "1406838526896656"
      },
      {
        "id": "333609759413975"
      },
      {
        "id": "263041796749324"
      }
    ],
  },
  "expired_leads_count": 0
}
*)

  Result := -1;
  leadCount := 0;
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_formId;
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields', 'leads_count,organic_leads_count,name,id,page,created_time,status,leads{id,created_time}'); {}
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
        {--} LogFacebook('GetLeadsByForm('+_formId+')'#13#10);
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
             {--} LogFacebook(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  //jo := jv as TJSONObject;
                  jvL := GetJSONValue(jv as TJsonObject,'leads_count');
                  if Assigned(jvL) then
                    leadCount := jvL.Value.ToInteger;
                  if leadCount>0 then
                  begin
                    jvL := GetJSONValue(jv as TJsonObject,'status');
                    if Assigned(jvL) then
                      tempStatusStr := jvL.Value;
                    tempStatus := tempStatusStr ='ACTIVE';


                    jvm := GetJSONValue(jv as TJsonObject,'leads') as TJsonObject;
                    if Assigned(jvm) then
                    begin
                      Result := 0;
                      ja := GetJSONValue(jvm,'data') as TJSONArray;
                      for i := 0 to GetArraySize(ja) - 1 do
                      begin
                        jo := GetArrayItem(ja, i) as TJSONObject;
                        newItemId := GetJSONValue(jo,'id').Value;
                        if _List.IndexOf(newItemId)<0 then
                        begin
                          item := _List.Add;
                          item.ItemType := fbLeadItem;
                          item.ItemId := newItemId;
                          item.Status := tempStatus;
                         end;
                      end;
                    end;
                  end; // if leadCount>0
                end
             finally
               if Assigned(jv) then
                 jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_LeadsByForm0001 : Exception do
        begin
          Result := -2;
          {--} LogFacebook('** hata : '+Ex_fb_GET_LeadsByForm0001.ClassName+__+ Ex_fb_GET_LeadsByForm0001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_LeadsByForm0001.ClassName+') '+Ex_fb_GET_LeadsByForm0001.Message;
        end;
     end;
   finally
     dmFaceBook.Free;
   end;
end;

// https://graph.facebook.com/v18.0/{leadid}1569153207222534?fields=organic_leads_count,name,id,page,created_time,status,leads{id},expired_leads_count
function GetLeadData( _leadID, _token : string) : recLead;
var
  jv,jve  : TJSONValue;
  jo,jvm   : TJSONObject;
  ja, jaVal: TJSONArray;
  //item : TFbItem;
  //newItemId : string;
  i : integer;
  tempVal, tempName : string;
begin
  Result := Default(recLead);
   try
     dmFaceBook := TdmFaceBook.Create(Nil);
     dmFaceBook.fb_GET_INFO_Request.ClearBody;
     dmFaceBook.fb_GET_INFO_Client.BaseURL := varBaseURL + '/'+cMetaApiVer+'/'+_leadID;
     dmFaceBook.fb_GET_INFO_Request.AddParameter('fields', 'field_data,created_time,id');
     dmFaceBook.fb_GET_INFO_Request.AddParameter('access_token', _token);
     try
        dmFaceBook.fb_GET_INFO_Request.Execute;
        var_ResponseString := dmFaceBook.fb_GET_INFO_Response.Content;
        {--} LogFacebook('GetLeadData('+_leadID+')'#13#10);
        jv := TJsonObject.ParseJSONValue(var_ResponseString);
        if Assigned(jv) then
          begin
             {--} LogFacebook(jv.Format+#13#10);
             try
                jve := GetJSONValue(jv as TJSONObject,'error');
                if not Assigned(jve) then
                begin
                  jvm := jv as TJSONObject;
                  if GetJSonValue(jvm,'id')<>nil then
                    Result.id := GetJSonValue(jvm,'id').Value;
                  if GetJSonValue(jvm,'created_time')<>nil then
                    Result.created_time := GetJSonValue(jvm,'created_time').Value;

                  ja := GetJSONValue(jvm,'field_data') as TJSONArray;
                  Result.NOT1 := '';
                  for i := 0 to GetArraySize(ja) - 1 do
                  begin
                    jo := GetArrayItem(ja, i) as TJSONObject;
                    if GetJSONValue(jo,'name')<>nil then
                     begin
                       tempName := GetJSONValue(jo,'name').Value;
                       jaVal := GetJSONValue(jo,'values') as TJSONArray;
                       if GetArraySize(jaVal)>0 then
                         tempVal := (GetArrayItem(jaVal, 0) as TJSONValue).Value
                       else tempVal := '';
                       if (tempName = 'FULL_NAME') or(tempName='adý_soyadý') then Result.FULL_NAME := tempVal; //'adý_soyadý'
                       if (tempName = 'EMAIL') or(tempName='e-posta') then Result.EMAIL := tempVal; //'e-posta'
                       if (tempName = 'PHONE') or(tempName='telefon_numarasý') then Result.PHONE := tempVal; //'telefon_numarasý'
                       if (tempName='diger_telefon_numarasý') then Result.PHONE2 := tempVal; //'telefon_numarasý' , 'diger_telefon_numarasý'
                       if (tempName = 'STREET_ADDRESS') or(tempName='adres') then Result.STREET_ADDRESS := tempVal;  //'adres'
                       if (tempName = 'GENDER') or(tempName='cinsiyet') then Result.GENDER := tempVal; //'cinsiyet'
                       if (tempName = 'CITY') or(tempName='þehir') then Result.CITY:= tempVal;     //'þehir'
                       if (tempName = 'COUNTRY') or(tempName='ülke') then Result.COUNTRY := tempVal;     //'ülke'
                       if (tempName = 'NOT1')  then Result.NOT1 := Result.NOT1 + tempVal;
                       //if tempName = 'NOT2' then Result.NOTES := Result.NOTES +#13#10+ tempVal;
                       //if tempName = 'S1' then Result.NOTES := Result.NOTES +#13#10+ tempVal;
                       if Length(Result.GENDER)>0 then
                        begin
                           if (UpperCase(Result.GENDER[1])='M') or (Uppercase(Result.GENDER[1])='E') then
                             Result.GENDER := 'E';
                           if (UpperCase(Result.GENDER[1])='F') or (UpperCase( Result.GENDER[1])='K') then
                             Result.GENDER := 'K';
                        end;
                       //NOT için eklenecek Ek Soru !
                     end;
                     end;
                  end;
             finally
               if Assigned(jv) then
                 jv.Free;
             end;
          end;
     except
        on Ex_fb_GET_LeadsByForm0001 : Exception do
        begin

          {--} LogFacebook('** hata : '+Ex_fb_GET_LeadsByForm0001.ClassName+__+ Ex_fb_GET_LeadsByForm0001.Message);
          //Result := 'ERROR ('+Ex_fb_GET_LeadsByForm0001.ClassName+') '+Ex_fb_GET_LeadsByForm0001.Message;
        end;
     end;
   finally
     dmFaceBook.Free;
   end;
end;


(*

Kalýcý User Acess Token     EAAJFC5NMtMcBO3ittBKkTLDZC5XgqevELoeMnEk5zReNvScIpP6xuf1ZAaiPXCInrVaqFZCqxEmHwgvKCly4ZAoc3TxSNYtZBEfZCUoiicSj3Y3OnurJVV01iDIbvBLeateM0oj0ljEVlhoEkeIqRro2JZAZC5Mc6lw9hVz4RfD8zG82dIaEPI6TuMxJBoS6ZCLmwtRBIzv5M
Kalýcý Page Acess Token     EAAJFC5NMtMcBOZCpHHvfn7L0YSCjuk1C1GjUE4TDV9MXeZCZCZCYKZBu78w2bWqHZA8nHu8Np67DNweEpK4zPKOwn12UBn4vqdwK9DKQ4HxZCHaSxudTHNvIZCtTp8jlm88wgTk8LCVlppjP0Lmawz1ww7ALRwkZCI1h1E1eW0XIKsouZCjiPyvdsE1g7fyUHGOu9dHNad3kLglZACu82kZD

*)


{
 Get Long Lived User Access Token

URL >>
https://graph.facebook.com/v18.0/oauth/access_token?

params >>
grant_type         fb_exchange_token
client_id          638865971655879
client_secret      a868dd95e19c7137315ec9d0c5658769
                   Kalýcý UserAcessToken
fb_exchange_token  EAAJFC5NMtMcBO3ittBKkTLDZC5XgqevELoeMnEk5zReNvScIpP6xuf1ZAaiPXCInrVaqFZCqxEmHwgvKCly4ZAoc3TxSNYtZBEfZCUoiicSj3Y3OnurJVV01iDIbvBLeateM0oj0ljEVlhoEkeIqRro2JZAZC5Mc6lw9hVz4RfD8zG82dIaEPI6TuMxJBoS6ZCLmwtRBIzv5M


}

(*
 Get Long Lived Page Access Token

URL >>
https://graph.facebook.com/v18.0/{app-scoped-user-id}/accounts?access_token={long-lived-user-access-token}

params >>
access_token       {long-lived-user-access-token}
*)




{ TFacebookObject }

procedure TFacebookObject.Assign(Source: TPersistent);
begin
  inherited;

end;

procedure TFacebookObject.FromJSON(jo: TJSONObject);
begin
  ID := GetJSONProp(jo,'id');
  Name := GetJSONProp(jo,'name');
end;


{ TFacebookProfileItem }

procedure TFacebookProfileItem.Assign(Source: TPersistent);
begin
  //inherited;

end;

constructor TFacebookProfileItem.Create(Collection: TCollection);
begin
  inherited;
  FProfile := TFacebookProfile.Create;
end;

destructor TFacebookProfileItem.Destroy;
begin
  FProfile.Free;
  inherited;
end;

procedure TFacebookProfileItem.SetProfile(const Value: TFacebookProfile);
begin
  FProfile.Assign(Value);
end;

{ TFacebookProfile }

procedure TFacebookProfile.Assign(Source: TPersistent);
begin
 // inherited;

end;

constructor TFacebookProfile.Create;
begin
  inherited;
  FHomeTown := TFacebookObject.Create;
  FLocation := TFacebookObject.Create;
  FSignificantOther := TFacebookObject.Create;
  FLikes := TFacebookObjectList.Create;
  FFeed := TFeed.Create;
  FAlbums := TFacebookAlbumList.Create;
end;

destructor TFacebookProfile.Destroy;
begin
  FHomeTown.Free;
  FLocation.Free;
  FSignificantOther.Free;
  FLikes.Free;
  FFeed.Free;
  FAlbums.Free;
  inherited;
end;

procedure TFacebookProfile.FromJSON(jo: TJSONObject);
var
  jv: TJSONValue;
begin
  FFullName := GetJSONPropCheck(jo,'name');
  FFirstName := GetJSONPropCheck(jo,'first_name');
  FLastName := GetJSONPropCheck(jo,'last_name');
  FMiddleName := GetJSONPropCheck(jo,'middle_name');
  FLink := GetJSONPropCheck(jo,'link');
  FID := GetJSONPropCheck(jo,'id');

  if FID <> '' then
    FImageURl := 'http://graph.facebook.com/' + FID + '/picture';

  if GetJSONPropCheck(jo,'gender') = 'male' then
    FGender := fbErkek
  else if GetJSONPropCheck(jo,'gender') = 'female' then
    FGender := fbKadin
  else
    FGender := fbBilinmiyor;

  FUserName := GetJSONPropCheck(jo, 'username');

  FBirthday := GetJSONPropCheck(jo,'birthday');

  FEmail := GetJSONPropCheck(jo,'email');
  FWebsite := GetJSONPropCheck(jo,'website');
  FRelationShip := GetJSONPropCheck(jo,'relationship_status');

  if GetJSONPropCheck(jo,'timezone') <> '' then
    FTimeZone := StrToFloat(GetJSONPropCheck(jo,'timezone'))
  else
    FTimeZone := -1;

  FLocale := GetJSONPropCheck(jo,'locale');
  if GetJSONPropCheck(jo,'verified') = 'true' then
    FVerified := True
  else
    FVerified := False;

  if GetJSONPropCheck(jo,'updated_time') <> '' then
    FUpdatedTime := IsoToDateTime(GetJSONPropCheck(jo,'updated_time'));

  jv := GetJSONValue(jo,'location');
  if Assigned(jv) then
    Location.FromJSON(jv as TJSONObject);

  jv := GetJSONValue(jo,'hometown');
  if Assigned(jv) then
    HomeTown.FromJSON(jv as TJSONObject);

  jv := GetJSONValue(jo,'significant_other');
  if Assigned(jv) then
    SignificantOther.FromJSON(jv as TJSONObject);
end;





{ TFacebookProfileList }

function TFacebookProfileList.Add: TFacebookProfile;
begin
  Result := TFacebookProfileItem(inherited Add).Profile;
end;

constructor TFacebookProfileList.Create;
begin
  inherited Create(TFacebookProfileItem);
end;

function TFacebookProfileList.Find(const ID: integer): TFacebookProfile;
begin
  Result := Find(IntToStr(ID));
end;

function TFacebookProfileList.Find(const ID: string): TFacebookProfile;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if Items[i].ID = ID then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TFacebookProfileList.GetItemProfile(Index: integer): TFacebookProfile;
begin
  Result := TFacebookProfileItem(inherited Items[Index]).Profile;
end;

procedure TFacebookProfileList.SetItemProfile(Index: integer;
  const Value: TFacebookProfile);
begin
  TFacebookProfileItem(inherited Items[Index]).Profile.Assign(Value);
end;




{ TFacebookCommentList }

function TFacebookCommentList.Add: TFacebookComment;
begin
  Result := TFacebookCommentItem(inherited Add).FObject;
end;

constructor TFacebookCommentList.Create;
begin
  inherited Create(TFacebookCommentItem);
end;

function TFacebookCommentList.Find(const ID: string): TFacebookComment;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if Items[i].ID = ID then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TFacebookCommentList.Find(const ID: integer): TFacebookComment;
begin
  Result := Find(IntToStr(ID));
end;

function TFacebookCommentList.GetObjectItem(Index: integer): TFacebookComment;
begin
  Result := TFacebookCommentItem(inherited Items[Index]).FObject;
end;

procedure TFacebookCommentList.SetObjectItem(Index: integer;
  const Value: TFacebookComment);
begin
  TFacebookCommentItem(inherited Items[Index]).FObject.Assign(Value);
end;

{ TFacebookComment }

procedure TFacebookComment.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookComment.Create;
begin
  FUser := TFacebookProfile.Create;
  FLikes := TFacebookProfileList.Create;
end;

destructor TFacebookComment.Destroy;
begin
  FUser.Free;
  FLikes.Free;
  inherited;
end;

procedure TFacebookComment.FromJSON(jo: TJSONObject);
var
  jv: TJSONValue;
begin
  ID := GetJSONProp(jo,'id');
  Text := GetJSONProp(jo,'message');

  if GetJSONProp(jo,'created_time') <> '' then
    CreatedTime := IsoToDateTime(GetJSONProp(jo,'created_time'));

  jv := GetJSONValue(jo,'user_likes');
  if Assigned(jv) then
    UserLikes := jv is TJSONTrue;

  jv := GetJSONValue(jo,'from');
  if Assigned(jv) then
    User.FromJSON(jv as TJSONObject);
end;

{ TFacebookCommentItem }

procedure TFacebookCommentItem.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookCommentItem.Create(Collection: TCollection);
begin
  inherited;
  FObject := TFacebookComment.Create;
end;

destructor TFacebookCommentItem.Destroy;
begin
  FObject.Free;
  inherited;
end;

procedure TFacebookCommentItem.SetObject(const Value: TFacebookComment);
begin
  FObject.Assign(Value);
end;

{ TFacebookFeedItem }

procedure TFacebookFeedItem.Assign(Source: TPersistent);
begin
  if (Source is TFacebookFeedItem) then
  begin
    FText := (Source as TFacebookFeedItem).Text;
    FID := (Source as TFacebookFeedItem).ID;
  end;
end;

constructor TFacebookFeedItem.Create;
begin
  inherited;
  FUser := TFacebookProfile.Create;
  FLikes := TFacebookProfileList.Create;
  FToUsers := TFacebookProfileList.Create;
  FComments := TFacebookCommentList.Create;
end;

destructor TFacebookFeedItem.Destroy;
begin
  FUser.Free;
  FLikes.Free;
  FToUsers.Free;
  FComments.Free;
  inherited;
end;

procedure TFacebookFeedItem.FromJSON(jo: TJSONObject);
var
  jvo, joa: TJSONObject;
  jv, jva: TJSONValue;
  ja: TJSONArray;
  I: integer;
  UserProfile: TFacebookProfile;
  Comment: TFacebookComment;
begin
  Text := GetJSONProp(jo,'message');
  ID := GetJSONProp(jo,'id');
  ImageURL := GetJSONProp(jo,'picture');
  Link := GetJSONProp(jo,'link');
  Summary := GetJSONProp(jo,'name');
  Caption := GetJSONProp(jo,'caption');
  Description := GetJSONProp(jo,'description');

  if GetJSONProp(jo,'created_time') <> '' then
    CreatedTime := IsoToDateTime(GetJSONProp(jo,'created_time'), False);
  if GetJSONProp(jo,'updated_time') <> '' then
    UpdatedTime := IsoToDateTime(GetJSONProp(jo,'updated_time'), False);

  Story := GetJSONProp(jo,'story');
  ObjectID := GetJSONProp(jo,'object_id');

  jva := GetJSONValue(jo,'likes');
  if Assigned(jva) then
  begin
    // reset list
    Likes.Clear;

    joa := jva as TJSONObject;

    ja := GetJSONValue(joa,'data') as TJSONArray;

    if Assigned(ja) then
    begin
      for i := 0 to GetArraySize(ja) - 1 do
      begin
        jvo := GetArrayItem(ja, i) as TJSONObject;

        UserProfile := Likes.Add;
        UserProfile.FromJSON(jvo);
      end;
    end;
  end;

  jva := GetJSONValue(jo,'comments');
  if Assigned(jva) then
  begin
    // reset list
    Comments.Clear;

    joa := jva as TJSONObject;

    ja := GetJSONValue(joa,'data') as TJSONArray;

    if Assigned(ja) then
    begin
      for i := 0 to GetArraySize(ja) - 1 do
      begin
        jvo := GetArrayItem(ja, i) as TJSONObject;

        Comment := Comments.Add;
        Comment.FromJSON(jvo);
      end;
    end;
  end;

  jva := GetJSONValue(jo,'to');
  if Assigned(jva) then
  begin
    // reset list
    ToUsers.Clear;

    joa := jva as TJSONObject;
    ja := GetJSONValue(joa,'data') as TJSONArray;

    if Assigned(ja) then
    begin
      for i := 0 to GetArraySize(ja) - 1 do
      begin
        jvo := GetArrayItem(ja, i) as TJSONObject;

        UserProfile := ToUsers.Add;
        UserProfile.FromJSON(jvo);
      end;
    end;
  end;

  jv := GetJSONValue(jo,'from');
  if Assigned(jv) then
    User.FromJSON(jv as TJSONObject);
end;

procedure TFacebookFeedItem.SetUser(const Value: TFacebookProfile);
begin
  FUser.Assign(Value);
end;

{ TFeedItem }

constructor TFeedItem.Create(Collection: TCollection);
begin
  inherited;
  FFeedItem := TFacebookFeedItem.Create;
end;

destructor TFeedItem.Destroy;
begin
  FFeedItem.Free;
  inherited;
end;

procedure TFeedItem.SetFeedItem(const Value: TFacebookFeedItem);
begin
  FFeedItem.Assign(Value);
end;

{ TFeed }

function TFeed.Add: TFacebookFeedItem;
begin
  Result := TFeedItem(inherited Add).FeedItem;
end;

constructor TFeed.Create;
begin
  inherited Create(TFeedItem);
end;

function TFeed.GetFeedItem(Index: integer): TFacebookFeedItem;
begin
  Result := TFeedItem(inherited Items[Index]).FeedItem;
end;

procedure TFeed.SetFeedItem(Index: integer; const Value: TFacebookFeedItem);
begin
  TFeedItem(inherited Items[Index]).FeedItem.Assign(Value);
end;


{ TFacebookObjectItem }

procedure TFacebookObjectItem.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookObjectItem.Create(Collection: TCollection);
begin
  inherited;
  FObject := TFacebookObject.Create;
end;

destructor TFacebookObjectItem.Destroy;
begin
  FObject.Free;
  inherited;
end;

procedure TFacebookObjectItem.SetObject(const Value: TFacebookObject);
begin
  FObject.Assign(Value);
end;


{ TFacebookObjectList }

function TFacebookObjectList.Add: TFacebookObject;
begin
  Result := TFacebookObjectItem(inherited Add).FObject;
end;

constructor TFacebookObjectList.Create;
begin
  inherited Create(TFacebookObjectItem);
end;

function TFacebookObjectList.Find(const ID: string): TFacebookObject;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if Items[i].ID = ID then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TFacebookObjectList.Find(const ID: integer): TFacebookObject;
begin
  Result := Find(IntToStr(ID));
end;

function TFacebookObjectList.GetObjectItem(Index: integer): TFacebookObject;
begin
  Result := TFacebookObjectItem(inherited Items[Index]).FObject;
end;

procedure TFacebookObjectList.SetObjectItem(Index: integer;
  const Value: TFacebookObject);
begin
  TFacebookObjectItem(inherited Items[Index]).FObject.Assign(Value);
end;

{ TFacebookAlbum }

procedure TFacebookAlbum.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookAlbum.Create;
begin
  Pictures := TFacebookPictureList.Create;
end;

destructor TFacebookAlbum.Destroy;
begin
  FPictures.Free;
  inherited;
end;

procedure TFacebookAlbum.FromJSON(jo: TJSONObject);
var
  fo: TJSONObject;
begin
  ID := GetJSONProp(jo,'id');
  Title := GetJSONProp(jo,'name');

  CoverPhotoID := GetJSONProp(jo,'cover_photo');
  //from v2.4 the API returns an object instead of an id
  if CoverPhotoID = '' then
  begin
    fo := GetJSONValue(jo,'cover_photo') as TJSONObject;

    if Assigned(fo) then
    begin
      if GetJSONProp(fo, 'id') <> '' then
        CoverPhotoID := GetJSONProp(fo,'id');
    end;
  end;

  Link := GetJSONProp(jo,'link');
  Description := GetJSONProp(jo,'description');

  if GetJSONPropCheck(jo,'created_time') <> '' then
    CreatedTime := IsoToDateTime(GetJSONPropCheck(jo,'created_time'));
  if GetJSONPropCheck(jo,'updated_time') <> '' then
    UpdatedTime := IsoToDateTime(GetJSONPropCheck(jo,'updated_time'));
end;

{ TFacebookAlbumItem }

procedure TFacebookAlbumItem.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookAlbumItem.Create(Collection: TCollection);
begin
  inherited;
  FAlbum := TFacebookAlbum.Create;
end;

destructor TFacebookAlbumItem.Destroy;
begin
  FAlbum.Free;
  inherited;
end;

procedure TFacebookAlbumItem.SetAlbum(const Value: TFacebookAlbum);
begin
  FAlbum.Assign(Value);
end;

{ TFacebookAlbumList }

function TFacebookAlbumList.Add: TFacebookAlbum;
begin
  Result := TFacebookAlbumItem(inherited Add).FAlbum;
end;

constructor TFacebookAlbumList.Create;
begin
  inherited Create(TFacebookAlbumItem);
end;

function TFacebookAlbumList.Find(const ID: string): TFacebookAlbum;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if Items[i].ID = ID then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TFacebookAlbumList.Find(const ID: integer): TFacebookAlbum;
begin
  Result := Find(IntToStr(ID));
end;

function TFacebookAlbumList.GetAlbumItem(Index: integer): TFacebookAlbum;
begin
  Result := TFacebookAlbumItem(inherited Items[Index]).FAlbum;
end;

procedure TFacebookAlbumList.SetAlbumItem(Index: integer;
  const Value: TFacebookAlbum);
begin
  TFacebookAlbumItem(inherited Items[Index]).FAlbum.Assign(Value);
end;

{ TFacebookPicture }

procedure TFacebookPicture.Assign(Source: TPersistent);
begin
  inherited;

end;

procedure TFacebookPicture.FromJSON(jo: TJSONObject);
begin
  ID := GetJSONPropCheck(jo,'id');
  Caption := GetJSONPropCheck(jo,'name');
  Link := GetJSONPropCheck(jo,'link');
  ImageURL := GetJSONPropCheck(jo,'source');

  if GetJSONPropCheck(jo,'created_time') <> '' then
    CreatedTime := IsoToDateTime(GetJSONPropCheck(jo,'created_time'));
//  if GetJSONPropCheck(jo,'updated_time') <> '' then
//    UpdatedTime := TCloudBase.IsoToDateTime(GetJSONPropCheck(jo,'updated_time'));
end;

{ TFacebookPictureItem }

procedure TFacebookPictureItem.Assign(Source: TPersistent);
begin
  inherited;

end;

constructor TFacebookPictureItem.Create(Collection: TCollection);
begin
  inherited;
  FPicture := TFacebookPicture.Create;
end;

destructor TFacebookPictureItem.Destroy;
begin
  FPicture.Free;
  inherited;
end;

procedure TFacebookPictureItem.SetPicture(const Value: TFacebookPicture);
begin
  FPicture.Assign(Value);
end;

{ TFacebookPictureList }

function TFacebookPictureList.Add: TFacebookPicture;
begin
  Result := TFacebookPictureItem(inherited Add).FPicture;
end;

constructor TFacebookPictureList.Create;
begin
  inherited Create(TFacebookPictureItem);
end;

function TFacebookPictureList.Find(const ID: string): TFacebookPicture;
var
  i: integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    if Items[i].ID = ID then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TFacebookPictureList.Find(const ID: integer): TFacebookPicture;
begin
  Result := Find(IntToStr(ID));
end;

function TFacebookPictureList.GetPictureItem(Index: integer): TFacebookPicture;
begin
  Result := TFacebookPictureItem(inherited Items[Index]).FPicture;
end;

procedure TFacebookPictureList.SetPictureItem(Index: integer;
  const Value: TFacebookPicture);
begin
  TFacebookPictureItem(inherited Items[Index]).FPicture.Assign(Value);
end;


end.
