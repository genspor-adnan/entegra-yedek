unit GenOutLookInterface;
interface
uses
    windows,Messages, SysUtils, Variants, Classes,forms,
    OleServer,outlook2010
    , ComCtrls,oleAuto;

const
  GenFolderDeletedItems                    = olFolderDeletedItems ;
  GenFolderOutbox                          = olFolderOutbox                   ;
  GenFolderSentMail                        = olFolderSentMail                 ;
  GenFolderInbox                           = olFolderInbox                    ;
  GenFolderCalendar                        = olFolderCalendar                 ;
  GenFolderContacts                        = olFolderContacts                 ;
  GenFolderJournal                         = olFolderJournal                  ;
  GenFolderNotes                           = olFolderNotes                    ;
  GenFolderTasks                           = olFolderTasks                    ;
  GenFolderDrafts                          = olFolderDrafts                   ;
  GenPublicFoldersAllPublicFolders         = olPublicFoldersAllPublicFolders  ;

type
    //email importance type          e-postanýn önemi tipi
    tImportance                   = ( miImportanceLow    =0,
                                      miImportanceNormal =1,
                                      miImportanceHigh   =2);
    //email Sensitivity              e-postanýn Hassasiyet tipi
    tSensitivity                  = ( msNormal           =0,
                                      msPersonal         =1,
                                      msPrivate          =2,
                                      msConfidential     =3);
    //email body type                e-postanýn gövde tipi
    tBodyFormat                   = ( bfFormatUnspecified=0,
                                      bfFormatPlain      =1,
                                      bfFormatHTML       =2,
                                      bfFormatRichText   =3);
    //email's header type e-postanýn baþlýk tipi
    tGenMailHeader                =  record
         MailID                   : Widestring;
         FolderID                 : Widestring;
         SenderName               : WideString;
         SenderEmail              : widestring;
         CreationTime             : TDateTime;
         SentOn                   : TDateTime;
         ReceivedTime             : TDateTime;
         Subject                  : widestring;
         Importance               : tImportance;
         Sensitivity              : tSensitivity;
         Size                     : integer;
         UnRead                   : boolean;
         To_                      : widestring;
         Recipients               : array of widestring;
         BCC                      : widestring;
         CC                       : widestring;
         Attachments              : array of widestring;
         MessageClass             : widestring;
         BodyFormat               : tBodyFormat;
    end;
    //container array type for email headers     e-posta baþlýklarýný için konteyner dizi türü
    tGenMailHeaderaddray          = array of tGenMailHeader;

TSearchFunction = function (Rec:tGenMailHeader):boolean;
//initiate Outlook interface Outlook arabirimi baþlatýr
function Init_OutLookInterface(Owner:TComponent):boolean;
//deinitiate Outlook interface Outlook arabirimi baþlatýr
function DeInit_OutLookInterface:boolean;
//Retrieves folders tree   Bu klasörlerin aðaç alýr
function RetrieveFolderTree:TStringList;
// saves an email in specified location in MSG format MSG formatýnda belirtilen konuma bir e-posta kaydeder
function SaveMailAs(MailId:widestring;FolderId:OleVariant;FileName:widestring):boolean;

{
//retrieves emails headers from default inbox folder    varsayýlan gelen kutusu klasöründen e-posta baþlýklarýný alýr
function RetrieveMailHeadersFromDefInBox(var HeadersArray:tGenMailHeaderaddray):boolean;

// for debug purposes, DON'T USE it   hata ayýklama amaçlarý için, KULLANMAYIN
procedure dumpa(var H:tGenMailHeaderaddray;fl:widestring);


//retrieves emails headers from  default inbox folder  which received after a specific date
// belirli bir tarihten sonra alýnan e-postalerin baþlýklarýný varsayýlan gelen kutusu klasöründen alýr
function RetrieveMailHeadersFromDefInBox_AfterDate(var HeadersArray:tGenMailHeaderaddray;After:TDateTime):boolean;

//retrieves emails headers from  default inbox folder  which received from specific company
//e-posta baþlýklarýný belirli bir þirkden alýnan varsayýlan gelen kutusu klasöründen alýr
function RetrieveMailHeadersFromDefInBox_NewCompany(var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring):boolean;

function RetrieveMailHeadersFromDefInBox_NewCompany_AfterDate(var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring;After:TDateTime):boolean;
}
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray):boolean;overload ;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring):boolean;overload ;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring;After:TDateTime):boolean;overload ;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;After:TDateTime):boolean;overload ;
implementation
type
  TSearchCompletEventHandlers = class // create a dummy class

  procedure searchcompletedHD(ASender: TObject;const SearchObject: Search);

   end;

var
    InterfaceInitiated     : boolean=false;
    GenOutlookApplication  : TOutlookApplication;
    GenNameSpace           : _NameSpace;
    GenFolders             : _Folders;
    GenOwner               : TComponent;
    SearchCompleted        : boolean=false;
procedure TSearchCompletEventHandlers.searchcompletedHD(ASender: TObject;const SearchObject: Search);
begin
     SearchCompleted:=true;

end;

function LocaltimeToGTM(dat:tdatetime):tdatetime;
const
  MinsPerDay = 24 * 60;

function GetGMTBias: Integer;
var
  info: TTimeZoneInformation;
  Mode: DWord;
begin
  Mode := GetTimeZoneInformation(info);
  Result := info.Bias;
  case Mode of
    TIME_ZONE_ID_INVALID:
      RaiseLastOSError;
    TIME_ZONE_ID_STANDARD:
      Result := Result + info.StandardBias;
    TIME_ZONE_ID_DAYLIGHT:
      Result := Result + info.DaylightBias;
  end;
end;
function GMTToLocale(const Value: TDateTime): TDateTime;
begin
  Result := Value - (GetGMTBias / MinsPerDay);
end;
  function LocaleToGMT(const Value: TDateTime): TDateTime;
  begin
    Result := Value + (GetGMTBias / MinsPerDay);
  end;

function GMTNow: TDateTime;
begin
  Result := LocaleToGMT(Now);
end;
begin
     result:=LocaleToGMT(Dat);
end      ;

function Init_OutLookInterface(Owner:TComponent) :boolean;
var
    m:Variant;
begin
     try
        GenOwner:=Owner;
        GenOutlookApplication:= TOutlookApplication.Create(Owner);
        GenOutlookApplication.ConnectKind := (ckRunningOrNew);
        GenOutlookApplication.Connect;
        GenNameSpace:=GenOutlookApplication.GetNameSpace('MAPI');

        GenFolders:=GenNameSpace.folders;
     except
      result:=false;
      exit;
     end;
     Result:=true;
     InterfaceInitiated:=true;
end;
function DeInit_OutLookInterface :boolean;
begin
     try
        GenOwner:=nil;

        GenOutlookApplication.Disconnect;
        GenOutlookApplication.free;
        GenFolders:=nil;
        GenNameSpace:=nil;
        GenOutlookApplication:=nil;



     except
      result:=false;
      exit;
     end;
     Result:=true;
     InterfaceInitiated:=true;
end;
function RetrieveFolderTree:TStringList;
procedure readfolderstree(fl:mapifolder;FLDSTR:widestring;tree:TStringList);
var
    s:widestring;
    fl1:MAPIFolder;
    i:integer;
begin
     tree.Add(FLDSTR+'\'+fl.Name);
     FLDSTR:= FLDSTR+'\'+fl.Name;
     if fl.Folders.Count>0
     then
     begin
          for i := 1 to fl.Folders.Count  do
              if fl.Folders.Item(i)<>nil
              then
              begin
                    fl1:=fl.Folders.Item(i);
                    if fl1.Get_Class_=olFolder
                    then
                    begin

                         readfolderstree(fl1,FLDSTR,tree);
                    end;
              end;
     end;
end;
var
   TempFolder   : MAPIFolder;
   i            : integer;
   Tree         : TStringList;

begin
     Tree:=nil;
     try
        if not InterfaceInitiated then Init_OutLookInterface(Application) ;
        Tree:=TStringList.Create;
        i:=        tree.Count;

        for i := 1 to GenFOLDERS.Count do
        begin
             TempFolder:=GenFOLDERS.Item(i) ;
             readfolderstree(TempFolder,'',Tree);

        end;
        Result:=tree;
     except
           if Tree<>nil then Tree.Free;
           Result:=Nil;

     end;
end;

function RetrieveMailHeadersFromPreDefFolders(GenFolder: OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray):boolean;

var
   TempFolder:MAPIFolder;
   m:_MailItem;
   i,j:integer;
begin
     try
         if not InterfaceInitiated
         then
             Init_OutLookInterface(Application);
         TempFolder:=GenNameSpace.GetDefaultFolder(GenFolder);
         setlength(HeadersArray,TempFolder.Items.Count);
         try
            for i := 1 to TempFolder.Items.Count  do
            begin
                m:=TempFolder.Items.Item(i) as _MailItem;;
                HeadersArray[i-1].MailID              :=m.EntryID;
                HeadersArray[i-1].FolderID            :=TempFolder.StoreID;
                HeadersArray[i-1].SenderName          :=m.SenderName;
                HeadersArray[i-1].SenderEmail         :=m.SenderEmailAddress;
                HeadersArray[i-1].CreationTime        :=m.CreationTime;
                HeadersArray[i-1].SentOn              :=m.SentOn;
                HeadersArray[i-1].ReceivedTime        :=m.ReceivedTime;
                HeadersArray[i-1].Subject             :=m.Subject;
                HeadersArray[i-1].Importance          :=tImportance(m.Importance);
                HeadersArray[i-1].Sensitivity         :=tSensitivity(m.Sensitivity);
                HeadersArray[i-1].Size                :=m.Size;
                HeadersArray[i-1].UnRead              :=m.UnRead;
                HeadersArray[i-1].To_                 :=m.To_;
                setlength(HeadersArray[i-1].Recipients,m.Recipients.Count);
                for j:=1 to m.Recipients.Count do
                    HeadersArray[i-1].Recipients[j-1] :=m.Recipients.Item(j).Address;
                HeadersArray[i-1].BCC                 :=m.BCC;
                HeadersArray[i-1].CC                  :=m.CC;
                setlength(HeadersArray[i-1].Attachments,m.Attachments.Count);
                for j := 1 to m.Attachments.Count do
                    HeadersArray[i-1].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                HeadersArray[i-1].MessageClass        :=m.MessageClass;
                HeadersArray[i-1].BodyFormat          :=tBodyFormat(m.BodyFormat);
            end;
         finally
                m:=nil;

         end;
         except
               SetLength(HeadersArray,0);
               result:=false;
               exit;
         end;
         result:=true;

end;
function SaveMailAs(MailId:widestring;FolderId:OleVariant;FileName:widestring):boolean;
var

     m:_MailItem;
begin
     try
       try

          m:=GenNamespace.GetItemFromID(Mailid,FolderId)as _mailItem;
          m.SaveAs(FileName,EmptyParam);
          result:=true;
       finally
         m:=nil;
       end;
     except
           Result:=false;
     end;

end;
procedure dumpa(var H:tGenMailHeaderaddray;fl:widestring);
var
   i:integer;
   f:textfile;
begin
     assignfile(f,fl);
     rewrite(f);
writeln(f,'MailID;FolderID;SenderName;SenderEmail;CreationTime;SentOn;ReceivedTime;Subject;'+
'Size;UnRead;To_;BCC,CC;MessageClass');

     for i:= low(h) to high(h) do
     with h[i] do
         writeln(f,MailID,';',FolderID,';',SenderName,';',SenderEmail,';',DateTimeToStr(CreationTime),';',DateTimeToStr(SentOn),';',DateTimeToStr(ReceivedTime),';',Subject,';',
Size,';',UnRead,';',To_,';',BCC,';',CC,';',MessageClass);
closefile(f);
end;
function Conditional_RetrieveMailHeadersFromPreDefFolders(GenFolder: OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;condition:TSearchFunction):boolean;
var
   TempFolder:MAPIFolder;

   m:_MailItem;
   i,j:integer;
   r:tGenMailHeader;
begin
     try
         if not InterfaceInitiated
         then
             Init_OutLookInterface(Application);
         TempFolder:=GenNameSpace.GetDefaultFolder(GenFolder);
         setlength(HeadersArray,0);
         try
            for i := 1 to TempFolder.Items.Count  do
            begin
                m:=TempFolder.Items.Item(i) as _MailItem;;
                r.MailID              :=m.EntryID;
                r.FolderID            :=TempFolder.StoreID;
                r.SenderName          :=m.SenderName;
                r.SenderEmail         :=m.SenderEmailAddress;
                r.CreationTime        :=m.CreationTime;
                r.SentOn              :=m.SentOn;
                r.ReceivedTime        :=m.ReceivedTime;
                r.Subject             :=m.Subject;
                r.Importance          :=tImportance(m.Importance);
                r.Sensitivity         :=tSensitivity(m.Sensitivity);
                r.Size                :=m.Size;
                r.UnRead              :=m.UnRead;
                r.To_                 :=m.To_;
                setlength(r.Recipients,m.Recipients.Count);
                for j:=1 to m.Recipients.Count do
                    r.Recipients[j-1] :=m.Recipients.Item(j).Address;
                r.BCC                 :=m.BCC;
                r.CC                  :=m.CC;
                setlength(r.Attachments,m.Attachments.Count);
                for j := 1 to m.Attachments.Count do
                    r.Attachments[j-1]:=m.Attachments.Item(j).FileName;
                r.MessageClass        :=m.MessageClass;
                r.BodyFormat          :=tBodyFormat(m.BodyFormat);
                if condition(r)
                then
                begin
                    setlength(HeadersArray,length(HeadersArray)+1);
                    HeadersArray[high(HeadersArray)].MailID              :=m.EntryID;
                    HeadersArray[high(HeadersArray)].FolderID            :=TempFolder.StoreID;
                    HeadersArray[high(HeadersArray)].SenderName          :=m.SenderName;
                    if m.Reply.Recipients.count>0
                    then
                        HeadersArray[high(HeadersArray)].SenderEmail     :=m.Reply.Recipients.Item(1).Address
                    else
                        HeadersArray[high(HeadersArray)].SenderEmail     :='';
                    HeadersArray[high(HeadersArray)].CreationTime        :=m.CreationTime;
                    HeadersArray[high(HeadersArray)].SentOn              :=m.SentOn;
                    HeadersArray[high(HeadersArray)].ReceivedTime        :=m.ReceivedTime;
                    HeadersArray[high(HeadersArray)].Subject             :=m.Subject;
                    HeadersArray[high(HeadersArray)].Importance          :=tImportance(m.Importance);
                    HeadersArray[high(HeadersArray)].Sensitivity         :=tSensitivity(m.Sensitivity);
                    HeadersArray[high(HeadersArray)].Size                :=m.Size;
                    HeadersArray[high(HeadersArray)].UnRead              :=m.UnRead;
                    HeadersArray[high(HeadersArray)].To_                 :=m.To_;
                    setlength(HeadersArray[high(HeadersArray)].Recipients,m.Recipients.Count);
                    for j:=1 to m.Recipients.Count do
                        HeadersArray[high(HeadersArray)].Recipients[j-1] :=m.Recipients.Item(j).Address;
                    HeadersArray[high(HeadersArray)].BCC                 :=m.BCC;
                    HeadersArray[high(HeadersArray)].CC                  :=m.CC;
                    setlength(HeadersArray[high(HeadersArray)].Attachments,m.Attachments.Count);
                    for j := 1 to m.Attachments.Count do
                        HeadersArray[high(HeadersArray)].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                    HeadersArray[high(HeadersArray)].MessageClass        :=m.MessageClass;
                    HeadersArray[high(HeadersArray)].BodyFormat          :=tBodyFormat(m.BodyFormat);
                end;
            end;
         finally
         end;
         except
               SetLength(HeadersArray,0);
               result:=false;
               exit;
         end;
         result:=true;
end;
function RetrieveMailHeadersFromDefInBox_FromFolder(var HeadersArray:tGenMailHeaderaddray;FolderName:widestring):boolean;

function RetrieveMailHeaders(Folder:MapiFolder;var HeadersArray:tGenMailHeaderaddray):boolean;

var
   TempFolder:MAPIFolder;
   m:_MailItem;
   i,j:integer;
   r:tGenMailHeader;
   s:widestring;

begin
     TempFolder:=Folder;
     try
         setlength(HeadersArray,TempFolder.Items.Count);
         try
            for i := 1 to TempFolder.Items.Count  do
            begin
                m:=TempFolder.Items.Item(i) as _MailItem;;
                HeadersArray[i-1].MailID              :=m.EntryID;
                HeadersArray[i-1].FolderID            :=TempFolder.StoreID;
                HeadersArray[i-1].SenderName          :=m.SenderName;
                HeadersArray[i-1].SenderEmail         :=m.SenderEmailAddress;
                HeadersArray[i-1].CreationTime        :=m.CreationTime;
                HeadersArray[i-1].SentOn              :=m.SentOn;
                HeadersArray[i-1].ReceivedTime        :=m.ReceivedTime;
                HeadersArray[i-1].Subject             :=m.Subject;
                HeadersArray[i-1].Importance          :=tImportance(m.Importance);
                HeadersArray[i-1].Sensitivity         :=tSensitivity(m.Sensitivity);
                HeadersArray[i-1].Size                :=m.Size;
                HeadersArray[i-1].UnRead              :=m.UnRead;
                HeadersArray[i-1].To_                 :=m.To_;
                setlength(HeadersArray[i-1].Recipients,m.Recipients.Count);
                for j:=1 to m.Recipients.Count do
                    HeadersArray[i-1].Recipients[j-1] :=m.Recipients.Item(j).Address;
                HeadersArray[i-1].BCC                 :=m.BCC;
                HeadersArray[i-1].CC                  :=m.CC;
                setlength(HeadersArray[i-1].Attachments,m.Attachments.Count);
                for j := 1 to m.Attachments.Count do
                    HeadersArray[i-1].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                HeadersArray[i-1].MessageClass        :=m.MessageClass;
                HeadersArray[i-1].BodyFormat          :=tBodyFormat(m.BodyFormat);
            end;
         finally
         end;
         except
               SetLength(HeadersArray,0);
               result:=false;
               exit;
         end;
         result:=true;

end;
function FindFolder(fl:mapifolder;FLDSTR:widestring;var folder:mapifolder):boolean;
var
    s:widestring;
    fl1:MAPIFolder;
    i:integer;
begin
     result:=false;
     i:=pos('\',fldstr);
     if i>0
     then
     begin
          s:=system.copy(Fldstr,1,i);
          system.Delete(fldstr,1,i);
          if uppercase(fl.Name)=s
          then
          begin
               for i := 1 to fl.Folders.Count  do
                 begin
                      fl1:=fl.Folders.Item(i);
                      if FindFolder(fl1,FLDSTR,folder)
                      then
                      begin
                           result:=true;
                           exit;
                      end;
                 end;
          end;
     end
     else
         if s=uppercase(fl.Name)
         then
         begin
              result:=true;
              folder:=fl;
         end;

end;
var
   ResFold,TempFolder   : MAPIFolder;
   i            : integer;

begin
     FolderName:=uppercase(FolderName);
     try
        if not InterfaceInitiated then Init_OutLookInterface(Application) ;

        for i := 1 to GenFOLDERS.Count do
        begin
             if True then

             TempFolder:=GenFOLDERS.Item(i) ;
             if FindFolder(TempFolder,FolderName,ResFold)
             then
             begin
                  result:=RetrieveMailHeaders(ResFold,HeadersArray);
                  exit;
             end;


        end;
     except
           result:=false;

     end;
end;


function RetrieveMailHeadersFromDefInBox_NewCompany(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring):boolean;
var
   TempFolder:MAPIFolder;

   m:_MailItem;
   i,j:integer;
   r:tGenMailHeader;
   s:widestring;
     sr:  Search;
   srchComp:TSearchCompletEventHandlers;

begin
     srchComp:=TSearchCompletEventHandlers.Create;
     try

       try
          //CompanyDomain:=AnsiUpperCase (CompanyDomain);
           if not InterfaceInitiated
           then
               Init_OutLookInterface(Application);
           TempFolder:=GenNameSpace.GetDefaultFolder(GenFolder);
           s:='"urn:schemas:httpmail:fromemail" LIKE  ''%'+CompanyDomain+'%''';
           SearchCompleted:=false;
           GenOutlookApplication.OnAdvancedSearchComplete:=srchComp.searchcompletedHD;
           sr:=GenOutlookApplication.AdvancedSearch('inbox',s,true,'TempSearc');
           while not SearchCompleted do
                 application.ProcessMessages;
           setlength(HeadersArray,sr.Results.Count);
           try
              for i := 1 to sr.Results.Count  do
              begin
                  m:=sr.Results.Item(i) as _MailItem;;
                  HeadersArray[i-1].MailID              :=m.EntryID;
                  HeadersArray[i-1].FolderID            :=TempFolder.StoreID;
                  HeadersArray[i-1].SenderName          :=m.SenderName;
                  HeadersArray[i-1].SenderEmail         :=m.SenderEmailAddress;
                  HeadersArray[i-1].CreationTime        :=m.CreationTime;
                  HeadersArray[i-1].SentOn              :=m.SentOn;
                  HeadersArray[i-1].ReceivedTime        :=m.ReceivedTime;
                  HeadersArray[i-1].Subject             :=m.Subject;
                  HeadersArray[i-1].Importance          :=tImportance(m.Importance);
                  HeadersArray[i-1].Sensitivity         :=tSensitivity(m.Sensitivity);
                  HeadersArray[i-1].Size                :=m.Size;
                  HeadersArray[i-1].UnRead              :=m.UnRead;
                  HeadersArray[i-1].To_                 :=m.To_;
                  setlength(HeadersArray[i-1].Recipients,m.Recipients.Count);
                  for j:=1 to m.Recipients.Count do
                      HeadersArray[i-1].Recipients[j-1] :=m.Recipients.Item(j).Address;
                  HeadersArray[i-1].BCC                 :=m.BCC;
                  HeadersArray[i-1].CC                  :=m.CC;
                  setlength(HeadersArray[i-1].Attachments,m.Attachments.Count);
                  for j := 1 to m.Attachments.Count do
                      HeadersArray[i-1].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                  HeadersArray[i-1].MessageClass        :=m.MessageClass;
                  HeadersArray[i-1].BodyFormat          :=tBodyFormat(m.BodyFormat);
              end;
           finally
                  m:=nil;

           end;
       except
             SetLength(HeadersArray,0);
             result:=false;
             exit;
       end;
     finally
          srchComp.Free;
   end;

           result:=true;
end;
function RetrieveMailHeadersFromDefInBox_AfterDate(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;After:TDateTime):boolean;
var
   TempFolder:MAPIFolder;
   m:_MailItem;
   i,j:integer;
   r:tGenMailHeader;
   s:widestring;
   sr:  Search;
   stim:TSystemTime;
   srchComp:TSearchCompletEventHandlers;
begin
     srchComp:=TSearchCompletEventHandlers.Create;
     try
         try
            after:=LocaltimeToGTM(after);
            if not InterfaceInitiated
            then
                Init_OutLookInterface(Application);
            TempFolder:=GenNameSpace.GetDefaultFolder(GenFolder);
            s:='"urn:schemas:httpmail:datereceived" >= '''+datetimetostr(after)+'''';
            DateTimeToSystemTime( After,stim);
            SearchCompleted:=false;
            GenOutlookApplication.OnAdvancedSearchComplete:=srchComp.searchcompletedHD;
            sr:=GenOutlookApplication.AdvancedSearch('inbox',s,true,'TempSearc');
            while not SearchCompleted do
                  application.ProcessMessages;
            setlength(HeadersArray,sr.Results.Count);
            try
                for i := 1 to sr.Results.Count  do
                begin
                    m:=sr.Results.Item(i) as _MailItem;;
                    HeadersArray[i-1].MailID              :=m.EntryID;
                    HeadersArray[i-1].FolderID            :=TempFolder.StoreID;
                    HeadersArray[i-1].SenderName          :=m.SenderName;
                    HeadersArray[i-1].SenderEmail         :=m.SenderEmailAddress;
                    HeadersArray[i-1].CreationTime        :=m.CreationTime;
                    HeadersArray[i-1].SentOn              :=m.SentOn;
                    HeadersArray[i-1].ReceivedTime        :=m.ReceivedTime;
                    HeadersArray[i-1].Subject             :=m.Subject;
                    HeadersArray[i-1].Importance          :=tImportance(m.Importance);
                    HeadersArray[i-1].Sensitivity         :=tSensitivity(m.Sensitivity);
                    HeadersArray[i-1].Size                :=m.Size;
                    HeadersArray[i-1].UnRead              :=m.UnRead;
                    HeadersArray[i-1].To_                 :=m.To_;
                    setlength(HeadersArray[i-1].Recipients,m.Recipients.Count);
                    for j:=1 to m.Recipients.Count do
                        HeadersArray[i-1].Recipients[j-1] :=m.Recipients.Item(j).Address;
                    HeadersArray[i-1].BCC                 :=m.BCC;
                    HeadersArray[i-1].CC                  :=m.CC;
                    setlength(HeadersArray[i-1].Attachments,m.Attachments.Count);
                    for j := 1 to m.Attachments.Count do
                        HeadersArray[i-1].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                    HeadersArray[i-1].MessageClass        :=m.MessageClass;
                    HeadersArray[i-1].BodyFormat          :=tBodyFormat(m.BodyFormat);
                end;
             finally
                    m:=nil;
             end;
         except
               SetLength(HeadersArray,0);
               result:=false;
               exit;
         end;
   finally
          srchComp.Free;
   end;
   result:=true;
end;
function RetrieveMailHeadersFromDefInBox_NewCompany_AfterDate(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring;After:TDateTime):boolean;
var
   TempFolder:MAPIFolder;
   m:_MailItem;
   i,j:integer;
   r:tGenMailHeader;
   s:widestring;
   sr:  Search;
   stim:TSystemTime;
   srchComp:TSearchCompletEventHandlers;
begin
     srchComp:=TSearchCompletEventHandlers.Create;
     try
         try
            after:=LocaltimeToGTM(after);
             if not InterfaceInitiated
             then
                 Init_OutLookInterface(Application);
             TempFolder:=GenNameSpace.GetDefaultFolder(GenFolder);
             s:='"urn:schemas:httpmail:datereceived" >= '''+datetimetostr(after)+''' & '+'"urn:schemas:httpmail:fromemail" LIKE  ''%'+CompanyDomain+'%''';
              DateTimeToSystemTime( After,stim);

              SearchCompleted:=false;
              GenOutlookApplication.OnAdvancedSearchComplete:=srchComp.searchcompletedHD;
              sr:=GenOutlookApplication.AdvancedSearch('inbox',s,true,'TempSearc');

              while not SearchCompleted do
                    application.ProcessMessages;
             setlength(HeadersArray,sr.Results.Count);

             try
                for i := 1 to sr.Results.Count  do
                begin
                    m:=sr.Results.Item(i) as _MailItem;;
                    HeadersArray[i-1].MailID              :=m.EntryID;
                    HeadersArray[i-1].FolderID            :=TempFolder.StoreID;
                    HeadersArray[i-1].SenderName          :=m.SenderName;
                    HeadersArray[i-1].SenderEmail         :=m.SenderEmailAddress;
                    HeadersArray[i-1].CreationTime        :=m.CreationTime;
                    HeadersArray[i-1].SentOn              :=m.SentOn;
                    HeadersArray[i-1].ReceivedTime        :=m.ReceivedTime;
                    HeadersArray[i-1].Subject             :=m.Subject;
                    HeadersArray[i-1].Importance          :=tImportance(m.Importance);
                    HeadersArray[i-1].Sensitivity         :=tSensitivity(m.Sensitivity);
                    HeadersArray[i-1].Size                :=m.Size;
                    HeadersArray[i-1].UnRead              :=m.UnRead;
                    HeadersArray[i-1].To_                 :=m.To_;
                    setlength(HeadersArray[i-1].Recipients,m.Recipients.Count);
                    for j:=1 to m.Recipients.Count do
                        HeadersArray[i-1].Recipients[j-1] :=m.Recipients.Item(j).Address;
                    HeadersArray[i-1].BCC                 :=m.BCC;
                    HeadersArray[i-1].CC                  :=m.CC;
                    setlength(HeadersArray[i-1].Attachments,m.Attachments.Count);
                    for j := 1 to m.Attachments.Count do
                        HeadersArray[i-1].Attachments[j-1]:=m.Attachments.Item(j).FileName;
                    HeadersArray[i-1].MessageClass        :=m.MessageClass;
                    HeadersArray[i-1].BodyFormat          :=tBodyFormat(m.BodyFormat);
                end;
             finally
                    m:=nil;
             end;
         except
               SetLength(HeadersArray,0);
               result:=false;
               exit;
         end;
   finally
          srchComp.Free;
   end;
   result:=true;
end;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray):boolean;overload ;
begin
    result:=RetrieveMailHeadersFromPreDefFolders(GenFolder,HeadersArray);
end;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring):boolean;overload ;
begin
     result:=RetrieveMailHeadersFromDefInBox_NewCompany(GenFolder,HeadersArray,CompanyDomain);
end;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;CompanyDomain:widestring;After:TDateTime):boolean;overload ;
begin
     result:=RetrieveMailHeadersFromDefInBox_NewCompany_AfterDate(GenFolder, HeadersArray,CompanyDomain,After);

end;
function RetrieveMailsHeaderFromOutLook(GenFolder:OlDefaultFolders;var HeadersArray:tGenMailHeaderaddray;After:TDateTime):boolean;overload ;
begin
     result:=RetrieveMailHeadersFromDefInBox_AfterDate( GenFolder,HeadersArray,After);
end;

end.

