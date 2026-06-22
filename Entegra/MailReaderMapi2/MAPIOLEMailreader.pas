unit MAPIOLEMailreader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleServer, StdCtrls, OleCtrls,
  ComCtrls
  //, Vcl.oleAuto
  , System.Win.ComObj
  , GenOutLookInterface;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    ListView1: TListView;
    Edit1: TEdit;
    Edit2: TEdit;
    Button5: TButton;
    FolderDeletedItems: TRadioButton;
    FolderOutbox: TRadioButton;
    FolderSentMail: TRadioButton;
    FolderInbox: TRadioButton;
    FolderDrafts: TRadioButton;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
      procedure showMailHeadrs(HeadersArray:tGenMailHeaderaddray);
      function SelectedFolder:TOleEnum;
  end;

var
  Form1: TForm1;

implementation

uses Outlook2010;


{$R *.dfm}


procedure TForm1.Button1Click(Sender: TObject);
{var
   r:TStringList;
   HeadersArray:tGenMailHeaderaddray;
   i:integer;
begin
  if Init_OutLookInterface(self)
  then
  begin
       r:=RetrieveFolderTree;
       if r<>nil then memo1.Lines. Assign(r);
       if RetrieveMailHeadersFromDefInBox_AfterDate( HeadersArray,StrToDateTime('02.05.2012  11:41:53'))
       then
           dumpa(HeadersArray,'d:\azarmir\temp\2.csv');
       for i := low(HeadersArray) to high(HeadersArray) do
           SaveMailAs(headersArray[i].MailID,headersArray[i].FolderID,'d:\azarmir\temp\a'+inttostr(i)+'.msg');
  end;
end;  }
var
   r:TStringList;
   HeadersArray:tGenMailHeaderaddray;
   i:OlDefaultFolders;

begin
     if Init_OutLookInterface(self)
     then
     begin
          r:=RetrieveFolderTree;
          if r<>nil then memo1.Lines. Assign(r);
          i:=SelectedFolder;
          if RetrieveMailsHeaderFromOutLook( i,HeadersArray)
          //RetrieveMailHeadersFromDefInBox( HeadersArray)
          then
              showMailHeadrs(HeadersArray);
          DeInit_OutLookInterface;
     end;
end;


procedure TForm1.Button2Click(Sender: TObject);
var
   r:TStringList;
   HeadersArray:tGenMailHeaderaddray;
   i:integer;
begin
     if Init_OutLookInterface(self)
     then
     begin
          r:=RetrieveFolderTree;
          if r<>nil then memo1.Lines. Assign(r);
          if RetrieveMailsHeaderFromOutLook(GenFolderInbox,HeadersArray,trim(edit2.Text))
          //RetrieveMailHeadersFromDefInBox_NewCompany(HeadersArray,trim(edit2.Text))
          then
              showMailHeadrs(HeadersArray);
          DeInit_OutLookInterface;
     end;
end;
procedure TForm1.Button3Click(Sender: TObject);
var
  Outlook, oNameSpace, Inbox,mail: OleVariant;
  i: Integer;
  s:string;
begin
  try
    Outlook := GetActiveOleObject('Outlook.Application');
  except
    Outlook := CreateOleObject('Outlook.Application');
  end;
  oNameSpace := Outlook.GetNamespace('MAPI');
  oNameSpace.Logon('', '', False, False);   // not sure if this is necessary
  Inbox := oNameSpace.GetDefaultFolder(olFolderInbox);

  for i := 1 to Inbox.items.Count do
  begin
       mail:=Inbox.items[i];
       s:=  oNameSpace.session.Get_Message(mail.EntryID, inbox.StoreID).sender.address;
  end;
end;
procedure TForm1.Button4Click(Sender: TObject);
var
   r:TStringList;
   HeadersArray:tGenMailHeaderaddray;
   i:integer;
begin
     if Init_OutLookInterface(self)
     then
     begin
          r:=RetrieveFolderTree;
          if r<>nil then memo1.Lines. Assign(r);
          if RetrieveMailsHeaderFromOutLook( GenFolderInbox,HeadersArray,StrToDateTime(edit1.Text))
          //RetrieveMailHeadersFromDefInBox_AfterDate( HeadersArray,StrToDateTime(edit1.Text))
          then
              showMailHeadrs(HeadersArray);
          DeInit_OutLookInterface;
     end;
end;
procedure TForm1.Button5Click(Sender: TObject);
var
   r:TStringList;
   HeadersArray:tGenMailHeaderaddray;
   i:integer;

begin
     if Init_OutLookInterface(self)
     then
     begin
          r:=RetrieveFolderTree;
          if r<>nil then memo1.Lines. Assign(r);
          if RetrieveMailsHeaderFromOutLook( GenFolderInbox,HeadersArray,trim(edit2.Text),StrToDateTime(edit1.Text))
          //RetrieveMailHeadersFromDefInBox_NewCompany_AfterDate( HeadersArray,trim(edit2.Text),StrToDateTime(edit1.Text))
          then
              showMailHeadrs(HeadersArray);

     DeInit_OutLookInterface;
     end;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
     edit1.Text:=datetimetostr(now);
end;

procedure tform1.showMailHeadrs(HeadersArray:tGenMailHeaderaddray);
var
i:integer;
begin
              ListView1.Clear;
              for i := low(HeadersArray) to high(HeadersArray) do
              begin
                   with ListView1.Items.Add do
                   begin
                        Caption :=headersArray[i].SenderName;
                        SubItems.Add(headersArray[i].SenderEmail);
                        SubItems.Add(datetimetostr(headersArray[i].CreationTime));
                        SubItems.Add(datetimetostr(headersArray[i].SentOn));
                        SubItems.Add(datetimetostr(headersArray[i].ReceivedTime));
                        case headersArray[i].Importance of
                             miImportanceLow:SubItems.Add('Low');
                             miImportanceNormal :SubItems.Add('Normal');
                             miImportanceHigh   :SubItems.Add('High');
                        end;
                        SubItems.Add(headersArray[i].Subject);
                        case  headersArray[i].Sensitivity of
                              msNormal           :SubItems.Add('Normal');
                              msPersonal         :SubItems.Add('Personal');
                              msPrivate          :SubItems.Add('Private');
                              msConfidential     :SubItems.Add('Confidental');
                        end;
                        SubItems.Add(inttostr(headersArray[i].Size));
                        if headersArray[i].UnRead
                        then
                            SubItems.Add('Unread')
                        else
                            SubItems.Add('Readed');
                        SubItems.Add(headersArray[i].To_);
                        SubItems.Add(headersArray[i].BCC);
                        SubItems.Add(headersArray[i].CC);
                        SubItems.Add(inttostr(Length(headersArray[i].Attachments)));
                        SubItems.Add(headersArray[i].MessageClass);
                        case headersArray[i].BodyFormat of
                        bfFormatUnspecified:SubItems.Add('Unspecified');
                        bfFormatPlain      :SubItems.Add('PlainText');
                        bfFormatHTML       :SubItems.Add('HTML');
                        bfFormatRichText   :SubItems.Add('RichText');
                        end;

                   end;
//                   SaveMailAs(headersArray[i].MailID,headersArray[i].FolderID,'d:\azarmir\temp\a'+inttostr(i)+'.msg');
              end;
          end;

function TForm1.SelectedFolder:TOleEnum;
begin
      if FolderDeletedItems.Checked
      then
          result:=genFolderDeletedItems
      else
      if FolderOutbox.Checked
      then
          result:=genFolderOutbox
      else
      if FolderSentMail.Checked
      then
          result:=genFolderSentMail
      else
      if FolderInbox.Checked
      then
          result:=genFolderInbox
      else
      if FolderDrafts.Checked
      then
          result:=genFolderDrafts
      else
      result:=0;

end;
end.


