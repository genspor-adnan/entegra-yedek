// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://betatest.elogo.com.tr/webservice/PostBoxService.svc?wsdl
//  >Import : https://betatest.elogo.com.tr/webservice/PostBoxService.svc?wsdl>0
// Encoding : utf-8
// Version  : 1.0
// (26/03/2021 18:31:11 - - $Rev: 52705 $)
// ************************************************************************ //

unit Logo_EFatService;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:getEArchiveXsltResponse - "http://tempuri.org/"[Lit][]
  // !:getInvoiceApplicationResponse - "http://tempuri.org/"[Lit][]
  // !:getInvoiceApplicationResponseResponse - "http://tempuri.org/"[Lit][]
  // !:getDocumentStatusEx - "http://tempuri.org/"[Lit][]
  // !:getDocumentStatusExResponse - "http://tempuri.org/"[Lit][]
  // !:getEArchiveXslt - "http://tempuri.org/"[Lit][]
  // !:getInvoiceResponseData - "http://tempuri.org/"[Lit][]
  // !:getEArchiveInvoicePdfData - "http://tempuri.org/"[Lit][]
  // !:getEArchiveInvoicePdfDataResponse - "http://tempuri.org/"[Lit][]
  // !:getDocumentData - "http://tempuri.org/"[Lit][]
  // !:getInvoiceResponseDataResponse - "http://tempuri.org/"[Lit][]
  // !:setApplicationResponseOption - "http://tempuri.org/"[Lit][]
  // !:setApplicationResponseOptionResponse - "http://tempuri.org/"[Lit][]
  // !:getUserListNew  - "http://tempuri.org/"[Lit][]
  // !:getUserListNewResponse - "http://tempuri.org/"[Lit][]
  // !:getApprovalFlowList - "http://tempuri.org/"[Lit][]
  // !:getInvoiceResponse - "http://tempuri.org/"[Lit][]
  // !:getUserList     - "http://tempuri.org/"[Lit][]
  // !:getUserListResponse - "http://tempuri.org/"[Lit][]
  // !:getApprovalFlowListResponse - "http://tempuri.org/"[Lit][]
  // !:getApprovalFlowResResponse - "http://tempuri.org/"[Lit][]
  // !:getDocumentStatus - "http://tempuri.org/"[Lit][]
  // !:getDocumentStatusResponse - "http://tempuri.org/"[Lit][]
  // !:setApprovalFlowId - "http://tempuri.org/"[Lit][]
  // !:setApprovalFlowIdResponse - "http://tempuri.org/"[Lit][]
  // !:getApprovalFlowRes - "http://tempuri.org/"[Lit][]
  // !:getDocumentDataResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocumentStatus - "http://tempuri.org/"[Lit][]
  // !:GetDocumentStatusResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocumentData - "http://tempuri.org/"[Lit][]
  // !:GetDocumentResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocumentDone - "http://tempuri.org/"[Lit][]
  // !:GetDocumentDoneResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocumentDataResponse - "http://tempuri.org/"[Lit][]
  // !:GetValidateGIBUserResponse - "http://tempuri.org/"[Lit][]
  // !:CheckGibUser    - "http://tempuri.org/"[Lit][]
  // !:CheckGibUserResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocumentList - "http://tempuri.org/"[Lit][]
  // !:GetDocumentListResponse - "http://tempuri.org/"[Lit][]
  // !:GetValidateGIBUser - "http://tempuri.org/"[Lit][]
  // !:sendReconciliationReportResponse - "http://tempuri.org/"[Lit][]
  // !:createElementId - "http://tempuri.org/"[Lit][]
  // !:createElementIdResponse - "http://tempuri.org/"[Lit][]
  // !:getReconciliationList - "http://tempuri.org/"[Lit][]
  // !:getReconciliationListResponse - "http://tempuri.org/"[Lit][]
  // !:sendReconciliationReport - "http://tempuri.org/"[Lit][]
  // !:cancelEArchiveInvoice - "http://tempuri.org/"[Lit][]
  // !:SendDocument    - "http://tempuri.org/"[Lit][]
  // !:SendDocumentResponse - "http://tempuri.org/"[Lit][]
  // !:GetDocument     - "http://tempuri.org/"[Lit][]
  // !:cancelEArchiveInvoiceResponse - "http://tempuri.org/"[Lit][]
  // !:SendEArchiveListForReconcilition - "http://tempuri.org/"[Lit][]
  // !:SendEArchiveListForReconcilitionResponse - "http://tempuri.org/"[Lit][]
  // !:sendApplicationResponse - "http://tempuri.org/"[Lit][]
  // !:sendApplicationResponseResponse - "http://tempuri.org/"[Lit][]
  // !:sendEnvelopeEx  - "http://tempuri.org/"[Lit][]
  // !:sendEnvelopeResponse - "http://tempuri.org/"[Lit][]
  // !:sendInvoice     - "http://tempuri.org/"[Lit][]
  // !:sendInvoiceResponse - "http://tempuri.org/"[Lit][]
  // !:sendEnvelopeExResponse - "http://tempuri.org/"[Lit][]
  // !:sendSignedInvoiceResponse - "http://tempuri.org/"[Lit][]
  // !:sendApplicationResponseEx - "http://tempuri.org/"[Lit][]
  // !:sendApplicationResponseExResponse - "http://tempuri.org/"[Lit][]
  // !:sendInvoiceEx   - "http://tempuri.org/"[Lit][]
  // !:sendInvoiceExResponse - "http://tempuri.org/"[Lit][]
  // !:sendSignedInvoice - "http://tempuri.org/"[Lit][]
  // !:GetDiagnosisResultResponse - "http://tempuri.org/"[Lit][]
  // !:Ping            - "http://tempuri.org/"[Lit][]
  // !:PingResponse    - "http://tempuri.org/"[Lit][]
  // !:GetVersions     - "http://tempuri.org/"[Lit][]
  // !:GetVersionsResponse - "http://tempuri.org/"[Lit][]
  // !:GetDiagnosisResult - "http://tempuri.org/"[Lit][]
  // !:ALive           - "http://tempuri.org/"[Lit][]
  // !:Logout          - "http://tempuri.org/"[Lit][]
  // !:LogoutResponse  - "http://tempuri.org/"[Lit][]
  // !:sendEnvelope    - "http://tempuri.org/"[Lit][]
  // !:ALiveResponse   - "http://tempuri.org/"[Lit][]
  // !:Login           - "http://tempuri.org/"[Lit][]
  // !:LoginResponse   - "http://tempuri.org/"[Lit][]
  // !:sendEArchiveDocument - "http://tempuri.org/"[Lit][]
  // !:getInvoiceStatusResponse - "http://tempuri.org/"[Lit][]
  // !:getAppRespStatus - "http://tempuri.org/"[Lit][]
  // !:getAppRespStatusResponse - "http://tempuri.org/"[Lit][]
  // !:getApplicationResponse - "http://tempuri.org/"[Lit][]
  // !:getApplicationResponseResponse - "http://tempuri.org/"[Lit][]
  // !:getInvoiceStatus - "http://tempuri.org/"[Lit][]
  // !:getEnvelopeList - "http://tempuri.org/"[Lit][]
  // !:getInvoiceList  - "http://tempuri.org/"[Lit][]
  // !:getInvoiceListResponse - "http://tempuri.org/"[Lit][]
  // !:getInvoice      - "http://tempuri.org/"[Lit][]
  // !:getEnvelopeListResponse - "http://tempuri.org/"[Lit][]
  // !:getEnvelope     - "http://tempuri.org/"[Lit][]
  // !:getEnvelopeResponse - "http://tempuri.org/"[Lit][]
  // !:receiveDone     - "http://tempuri.org/"[Lit][]
  // !:receiveDoneResponse - "http://tempuri.org/"[Lit][]
  // !:receiveInvoice  - "http://tempuri.org/"[Lit][]
  // !:sendEArchiveDocumentResponse - "http://tempuri.org/"[Lit][]
  // !:receiveDocument - "http://tempuri.org/"[Lit][]
  // !:receiveDocumentResponse - "http://tempuri.org/"[Lit][]
  // !:receiveInvoiceResponse - "http://tempuri.org/"[Lit][]
  // !:receiveApplicationResponseResponse - "http://tempuri.org/"[Lit][]
  // !:receiveApplicationResponseDone - "http://tempuri.org/"[Lit][]
  // !:receiveApplicationResponseDoneResponse - "http://tempuri.org/"[Lit][]
  // !:receiveInvoiceDone - "http://tempuri.org/"[Lit][]
  // !:receiveInvoiceDoneResponse - "http://tempuri.org/"[Lit][]
  // !:receiveApplicationResponse - "http://tempuri.org/"[Lit][]


  // ************************************************************************ //
  // Namespace : http://tempuri.org/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : PostBoxServiceEndpoint
  // service   : PostBoxService
  // port      : PostBoxServiceEndpoint
  // URL       : https://betatest.elogo.com.tr/webservice/PostBoxService.svc
  // ************************************************************************ //
  IPostBoxService = interface(IInvokable)
  ['{3AC37819-076C-8A05-742B-827817D1BBFF}']

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetVersions(const parameters: GetVersions): GetVersionsResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDiagnosisResult(const parameters: GetDiagnosisResult): GetDiagnosisResultResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  Ping(const parameters: Ping): PingResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  ALive(const parameters: ALive): ALiveResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  Login(const parameters: Login): LoginResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  Logout(const parameters: Logout): LogoutResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendEnvelope(const parameters: sendEnvelope): sendEnvelopeResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendInvoice(const parameters: sendInvoice): sendInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendApplicationResponse(const parameters: sendApplicationResponse): sendApplicationResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendEnvelopeEx(const parameters: sendEnvelopeEx): sendEnvelopeExResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendInvoiceEx(const parameters: sendInvoiceEx): sendInvoiceExResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendSignedInvoice(const parameters: sendSignedInvoice): sendSignedInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendApplicationResponseEx(const parameters: sendApplicationResponseEx): sendApplicationResponseExResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendEArchiveDocument(const parameters: sendEArchiveDocument): sendEArchiveDocumentResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveDocument(const parameters: receiveDocument): receiveDocumentResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveDone(const parameters: receiveDone): receiveDoneResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveInvoice(const parameters: receiveInvoice): receiveInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveInvoiceDone(const parameters: receiveInvoiceDone): receiveInvoiceDoneResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveApplicationResponse(const parameters: receiveApplicationResponse): receiveApplicationResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  receiveApplicationResponseDone(const parameters: receiveApplicationResponseDone): receiveApplicationResponseDoneResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getApplicationResponse(const parameters: getApplicationResponse): getApplicationResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getInvoiceStatus(const parameters: getInvoiceStatus): getInvoiceStatusResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getAppRespStatus(const parameters: getAppRespStatus): getAppRespStatusResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getEnvelopeList(const parameters: getEnvelopeList): getEnvelopeListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getEnvelope(const parameters: getEnvelope): getEnvelopeResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getInvoiceList(const parameters: getInvoiceList): getInvoiceListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getInvoice(const parameters: getInvoice): getInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getUserList(const parameters: getUserList): getUserListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getUserListNew(const parameters: getUserListNew): getUserListNewResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getApprovalFlowList(const parameters: getApprovalFlowList): getApprovalFlowListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  setApprovalFlowId(const parameters: setApprovalFlowId): setApprovalFlowIdResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getApprovalFlowRes(const parameters: getApprovalFlowRes): getApprovalFlowResResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getDocumentStatus(const parameters: getDocumentStatus): getDocumentStatusResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getDocumentStatusEx(const parameters: getDocumentStatusEx): getDocumentStatusExResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getEArchiveXslt(const parameters: getEArchiveXslt): getEArchiveXsltResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getInvoiceApplicationResponse(const parameters: getInvoiceApplicationResponse): getInvoiceApplicationResponseResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getInvoiceResponseData(const parameters: getInvoiceResponseData): getInvoiceResponseDataResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  setApplicationResponseOption(const parameters: setApplicationResponseOption): setApplicationResponseOptionResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getEArchiveInvoicePdfData(const parameters: getEArchiveInvoicePdfData): getEArchiveInvoicePdfDataResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getDocumentData(const parameters: getDocumentData): getDocumentDataResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  getReconciliationList(const parameters: getReconciliationList): getReconciliationListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  sendReconciliationReport(const parameters: sendReconciliationReport): sendReconciliationReportResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  createElementId(const parameters: createElementId): createElementIdResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  cancelEArchiveInvoice(const parameters: cancelEArchiveInvoice): cancelEArchiveInvoiceResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  SendEArchiveListForReconcilition(const parameters: SendEArchiveListForReconcilition): SendEArchiveListForReconcilitionResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  SendDocument(const parameters: SendDocument): SendDocumentResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDocument(const parameters: GetDocument): GetDocumentResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDocumentDone(const parameters: GetDocumentDone): GetDocumentDoneResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDocumentStatus(const parameters: GetDocumentStatus): GetDocumentStatusResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDocumentData(const parameters: GetDocumentData): GetDocumentDataResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetDocumentList(const parameters: GetDocumentList): GetDocumentListResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  GetValidateGIBUser(const parameters: GetValidateGIBUser): GetValidateGIBUserResponse; stdcall;

    // Cannot unwrap: 
    //     - Input part does not refer to an element
    //     - Output part does not refer to an element
    function  CheckGibUser(const parameters: CheckGibUser): CheckGibUserResponse; stdcall;
  end;

function GetIPostBoxService(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IPostBoxService;


implementation
  uses SysUtils;

function GetIPostBoxService(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IPostBoxService;
const
  defWSDL = 'https://betatest.elogo.com.tr/webservice/PostBoxService.svc?wsdl';
  defURL  = 'https://betatest.elogo.com.tr/webservice/PostBoxService.svc';
  defSvc  = 'PostBoxService';
  defPrt  = 'PostBoxServiceEndpoint';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IPostBoxService);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  { IPostBoxService }
  InvRegistry.RegisterInterface(TypeInfo(IPostBoxService), 'http://tempuri.org/', 'utf-8');
  InvRegistry.RegisterAllSOAPActions(TypeInfo(IPostBoxService), '|http://tempuri.org/ICommonEndpoints/GetVersions'
                                                               +'|http://tempuri.org/ICommonEndpoints/GetDiagnosisResult'
                                                               +'|http://tempuri.org/IPostBoxService/Ping'
                                                               +'|http://tempuri.org/IPostBoxService/ALive'
                                                               +'|http://tempuri.org/IPostBoxService/Login'
                                                               +'|http://tempuri.org/IPostBoxService/Logout'
                                                               +'|http://tempuri.org/IPostBoxService/sendEnvelope'
                                                               +'|http://tempuri.org/IPostBoxService/sendInvoice'
                                                               +'|http://tempuri.org/IPostBoxService/sendApplicationResponse'
                                                               +'|http://tempuri.org/IPostBoxService/sendEnvelopeEx'
                                                               +'|http://tempuri.org/IPostBoxService/sendInvoiceEx'
                                                               +'|http://tempuri.org/IPostBoxService/sendSignedInvoice'
                                                               +'|http://tempuri.org/IPostBoxService/sendApplicationResponseEx'
                                                               +'|http://tempuri.org/IPostBoxService/sendEArchiveDocument'
                                                               +'|http://tempuri.org/IPostBoxService/receiveDocument'
                                                               +'|http://tempuri.org/IPostBoxService/receiveDone'
                                                               +'|http://tempuri.org/IPostBoxService/receiveInvoice'
                                                               +'|http://tempuri.org/IPostBoxService/receiveInvoiceDone'
                                                               +'|http://tempuri.org/IPostBoxService/receiveApplicationResponse'
                                                               +'|http://tempuri.org/IPostBoxService/receiveApplicationResponseDone'
                                                               +'|http://tempuri.org/IPostBoxService/getApplicationResponse'
                                                               +'|http://tempuri.org/IPostBoxService/getInvoiceStatus'
                                                               +'|http://tempuri.org/IPostBoxService/getAppRespStatus'
                                                               +'|http://tempuri.org/IPostBoxService/getEnvelopeList'
                                                               +'|http://tempuri.org/IPostBoxService/getEnvelope'
                                                               +'|http://tempuri.org/IPostBoxService/getInvoiceList'
                                                               +'|http://tempuri.org/IPostBoxService/getInvoice'
                                                               +'|http://tempuri.org/IPostBoxService/getUserList'
                                                               +'|http://tempuri.org/IPostBoxService/getUserListNew'
                                                               +'|http://tempuri.org/IPostBoxService/getApprovalFlowList'
                                                               +'|http://tempuri.org/IPostBoxService/setApprovalFlowId'
                                                               +'|http://tempuri.org/IPostBoxService/getApprovalFlowRes'
                                                               +'|http://tempuri.org/IPostBoxService/getDocumentStatus'
                                                               +'|http://tempuri.org/IPostBoxService/getDocumentStatusEx'
                                                               +'|http://tempuri.org/IPostBoxService/getEArchiveXslt'
                                                               +'|http://tempuri.org/IPostBoxService/getInvoiceApplicationResponse'
                                                               +'|http://tempuri.org/IPostBoxService/getInvoiceResponseData'
                                                               +'|http://tempuri.org/IPostBoxService/setApplicationResponseOption'
                                                               +'|http://tempuri.org/IPostBoxService/getEArchiveInvoicePdfData'
                                                               +'|http://tempuri.org/IPostBoxService/getDocumentData'
                                                               +'|http://tempuri.org/IPostBoxService/getReconciliationList'
                                                               +'|http://tempuri.org/IPostBoxService/sendReconciliationReport'
                                                               +'|http://tempuri.org/IPostBoxService/createElementId'
                                                               +'|http://tempuri.org/IPostBoxService/cancelEArchiveInvoice'
                                                               +'|http://tempuri.org/IPostBoxService/SendEArchiveListForReconcilition'
                                                               +'|http://tempuri.org/IPostBoxService/SendDocument'
                                                               +'|http://tempuri.org/IPostBoxService/GetDocument'
                                                               +'|http://tempuri.org/IPostBoxService/GetDocumentDone'
                                                               +'|http://tempuri.org/IPostBoxService/GetDocumentStatus'
                                                               +'|http://tempuri.org/IPostBoxService/GetDocumentData'
                                                               +'|http://tempuri.org/IPostBoxService/GetDocumentList'
                                                               +'|http://tempuri.org/IPostBoxService/GetValidateGIBUser'
                                                               +'|http://tempuri.org/IPostBoxService/CheckGibUser'
                                                               );
  InvRegistry.RegisterInvokeOptions(TypeInfo(IPostBoxService), ioDocument);
  InvRegistry.RegisterInvokeOptions(TypeInfo(IPostBoxService), ioLiteral);

end.