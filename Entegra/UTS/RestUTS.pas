{———————————————————————————————————————————————————————————————————————————————
  ARvRA M	  Töre library for Delphi.

  Copyright	: (C)2018-2071 İhsan V. Töre and licensors. All rights reserved.
  About		: A simple REST communicator for UTS.
  Home		: www.toretek.com
  Version	: 20181219 Authors: IVT
  Author	: IVT : İhsan V. Töre : ihsan@toretek.com : www.toretek.com
———————————————————————————————————————————————————————————————————————————————}
unit RestUTS;


interface

uses
    System.SysUtils,
    System.Classes,
	System.UITypes,
	IdHttp,
	IdHeaderList,
	IdSSLOpenSSL,
	Vcl.Dialogs,
    ModelApi;

{———————————————————————————————————————————————————————————————————————————————
  CLASS: TRestUTS
  USAGE:
	*	It is simple Https communicator for UTS servers.
	*	Server base address 	is at global utsServer.
	*	Client token 			is at global utsToken.
	*	Internal and Safe.
	*	Has only one service routine named talk.
	*	Sends and Receives Utf-8 json data.
———————————————————————————————————————————————————————————————————————————————}
type
    TRestUTS = class(TObject)
        function    talk(adr: String; req: String): String;     overload;
    private
        fClient :   TIdHTTP;
        fSocket :   TIdSSLIOHandlerSocketOpenSSL;
        fStream :   TStringStream;
    end;

function    utsTalkSS(
                address: String;
                request: String
            ):  String;

function    utsTalkMS(
                address: String;
                request: TModel;
                killReq: Boolean = true
            ):  String;

function    utsTalkMM(
                address: String;
                request: TModel;
                rsModel: TModel;
                killReq: Boolean = true
            ):  TModel;

function    utsTalkMC(
                address: String;
                request: TModel;
                rsClass: TModelClass;
                killReq: Boolean = true
			):  TModel;


const   TEST_UTS_SERVER  = 'https://utstest.saglik.gov.tr';
		MAIN_UTS_SERVER  = 'https://utsuygulama.saglik.gov.tr';

		//TEST_UTS_TOKEN   = 'Systemaf2caff3-8f10-473e-95f1-0196058f6e96';
		//CLNT_UTS_TOKEN   = 'System84594548-5fb0-4c48-ab58-0a0fe8e4758d';


var
 	utsToken: 	String;// = TEST_UTS_TOKEN;
	utsServer:	String = TEST_UTS_SERVER;//MAIN_UTS_SERVER;// ;

implementation

{———————————————————————————————————————————————————————————————————————————————
  FUNC: talk
  TASK: Sends a request to Uts server, then receives an answer, both in json.
  ARGS:	adr	:	String	: Request path to add to uts server base address.
		req	:	String	: Request string in json format.
  RETV:         String  : answer as json string.
  INFO:	Internal. Do not use this.
		Uses global utsServer 	as uts server base address.
		Uses global utsToken    as uts client token.
———————————————————————————————————————————————————————————————————————————————}
function TRestUTS.talk(adr, req: String): String;
var
	u: String;
	r: TIdHTTPRequest;
	h: TIdHeaderList;
  rStream: TStringStream;
begin
	fClient := TIdHTTP.Create();

{Http:= TIdHTTP.Create;
      IHandler:= TIdSSLIOHandlerSocketOpenSSL.Create(nil);
      IHandler.SSLOptions.Method:= sslvTLSv1_2;
      IHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      Http.IOHandler:= IHandler;
}
	r := fClient.Request;
	r.Clear;
	r.BasicAuthentication := true;
	h := r.CustomHeaders;
	h.Clear;
	h.AddValue('Content-type', 'application/json; charset=utf-8');
	h.AddValue('utsToken',utsToken);
	fSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  //09.06.21 AO
      fSocket.SSLOptions.Method:= sslvTLSv1_2;
      fSocket.SSLOptions.SSLVersions := [sslvTLSv1_2];
  ///
	fClient.IOHandler := fSocket;
	u       := utsServer + adr;
	fStream := TStringStream.Create(req,TEncoding.UTF8);
  rStream := TStringStream.Create('',TEncoding.UTF8); //14.04.2022 AÇ
	try
		fClient.Post(u, fStream,rStream);
    Result:= rStream.DataString;
	except on e: EIdHTTPProtocolException  do
		MessageDlg(
			e.ClassName+#13+#10+#13+#10+e.Message,
			mtWarning,
			[mbOk],
			0,
			mbOk
		); // say something
	end;

	if (fClient <> nil) then
		FreeAndNil(fClient);
	if (fSocket <> nil) then
		FreeAndNil(fSocket);
	if (fStream <> nil) then
		FreeAndNil(fStream);
  if (rStream <> nil) then
    FreeAndNil(rstream);
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: utsTalkSS (SS = send String recv String)
  TASK: Sends a request to Uts server, then receives an answer, both in json.
  ARGS:	address	:	String	: Request path to add to uts server base address.
		request	:	String	: Request string in json format.
  RETV:         	String  : answer as json string.
  INFO:	Uses global utsServer 	as uts server base address.
		Uses global utsToken    as uts client token.
———————————————————————————————————————————————————————————————————————————————}
function    utsTalkSS(address: String; request: String): String;
var
	r:   TRestUTS;
begin
	r := TRestUts.Create;
	result := r.talk(address, request);
	r.Free;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: utsTalkMS (MS = send Model recv String)
  TASK: Converts request model object to json string and sends it to uts
		server, then receives an answer as json string.
  ARGS:	address	:	String	: Request path to add to uts server base address.
		request	:	TModel	: Request as TModel object.
		killReq	:	Boolean	: Kill request object after use [default = true].
  RETV:         	String  : answer as json string.
  INFO:	Uses global utsServer 	as uts server base address.
		Uses global utsToken    as uts client token.
———————————————————————————————————————————————————————————————————————————————}
function    utsTalkMS(
				address: String;
				request: TModel;
				killReq: Boolean = true
			):  String;
var
	s:  String;
	b:  Boolean;
begin
	b := (request <> nil);
	if (b) then
		s := request.toJson
	else
		s := '';
	result := utsTalkSS(address, s);
	if (killReq and b) then
		FreeAndNil(request);
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: utsTalkMM (MM = send Model recv Model)
  TASK: Converts request model object to json string and sends it to uts
		server, then receives an answer as json string and converts it to the
		expected response model object.
  ARGS:	address	:	String	: Request path to add to uts server base address.
		request	:	TModel	: Request as TModel object.
		rsModel	:	TModel	: Response TModel object to fill in.
		killReq	:	Boolean	: Kill request object after use [default = true].
  RETV:         	TModel  : rsModel object.
  INFO: TModel descendant classes contain the field information for
		requests and responses. So instances of them work both as templates for
		conversion and containers of the data.
		Uses global utsServer 	as uts server base address.
		Uses global utsToken    as uts client token.
  WARN:	The response model object should match the received data.
———————————————————————————————————————————————————————————————————————————————}
function    utsTalkMM(
				address: String;
				request: TModel;
				rsModel: TModel;
				killReq: Boolean = true
			):  TModel;
var
	r: String;
begin
	if (rsModel = nil) then
		raise Exception.Create('E_INV_ARG: rsModel = nil');
	r := utsTalkMS(address, request, killReq);
	rsModel.byJson(r);
    result := rsModel;
end;

{———————————————————————————————————————————————————————————————————————————————
  FUNC: utsTalkMC (MC = send Model recv template Class)
  TASK: Converts request model object to json string and sends it to uts
		server, then receives an answer as json string.
		Then;
			a) 	If json denotes an array:
				It creates a ModelList with template class instance elements.
				Decodes json into modelList elements (which are Model objects).
			b)	If json denotes an object:
				It creates a Model object of template class.
				Decodes json into model object.
  ARGS:	address	:	String		: Request path added to uts server base address.
		request	:	TModel		: Request as TModel object.
		rsClass	:	TModelClass	: Response TModel Template Class.
		killReq	:	Boolean		: Kill request object after use[default = true].
  RETV:         	TModel  	: response 		object  of rsClass or
								  TModelList of objects of rsClass.
  INFO: TModel descendant classes contain the field information for
		requests and responses. So instances of them work both as templates for
		conversion and containers of the data.
		Uses global utsServer 	as uts server base address.
		Uses global utsToken    as uts client token.
  WARN:	The response model class should match the received data.
———————————————————————————————————————————————————————————————————————————————}
function    utsTalkMC(
                address: String;
                request: TModel;
                rsClass: TModelClass;
                killReq: Boolean = true
            ):  TModel;
var
    r: String;
    o: TModel;
begin
    if (rsClass = nil) then
        raise Exception.Create('E_INV_ARG: rsClass = nil');
    r := utsTalkMS(address, request, killReq);
	r := trimLeft(r);
	if (r = '') then
		exit(nil);
	if (r[1] = '[') then
		o := TModelList.Create(rsClass)
    else
        o := rsClass.Create(r);
    o.byJson(r);
    result := o;
end;



end.

