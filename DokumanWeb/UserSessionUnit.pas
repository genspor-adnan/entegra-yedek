unit UserSessionUnit;

{
  This is a DataModule where you can add components or declare fields that are specific to 
  ONE user. Instead of creating global variables, it is better to use this datamodule. You can then
  access the it using UserSession.
}
interface

uses
  IWUserSessionBase, SysUtils, Classes, DB, ADODB;
type
  TIWUserSession = class(TIWUserSessionBase)
    qChechUserIDPASS: TADOQuery;
    DBFly: TADOConnection;
    QDucKlasur: TADOQuery;
    QDucKlasurID: TAutoIncField;
    QDucKlasurUSTID: TIntegerField;
    QDucKlasurAD: TWideStringField;
    QDocuments: TADOQuery;
    QLangStringTab: TADOQuery;
    QLangStringTabBOLUM: TIntegerField;
    QLangStringTabANAHTAR: TWideStringField;
    QLangStringTabDEGER: TIntegerField;
    QLangStringTabDIL: TSmallintField;
    QLangStringTabSIRA: TSmallintField;
    QDocumentsYONSTR: TIntegerField;
    SPRetIMGFILE: TADOStoredProc;
    QRetrvieDOCIMJID: TADOQuery;
    QRetrvieDOCIMJIDID: TAutoIncField;
    qSPRetIMGFILE: TADOQuery;
    QRetrvieDOCIMJIDBELGE: TBlobField;
    QFetchFileName: TADOQuery;
    QFetchFileNameAD: TWideStringField;
    QDocumentsID: TAutoIncField;
    QDocumentsTARIH: TDateTimeField;
    QDocumentsBELGENO: TWideStringField;
    QDocumentsDURUM: TWordField;
    QDocumentsYON: TWordField;
    QDocumentsKATEGORI: TWideStringField;
    QDocumentsAD: TWideStringField;
    QDocumentsSURUM: TWideStringField;
    QDocumentsKONU: TWideStringField;
    QDocumentsTUR: TSmallintField;
    QDocumentsBOYUT: TBCDField;
    QDocumentsSORUMLU: TIntegerField;
    QDocumentsBOLUM: TSmallintField;
    QDocumentsLOKASYON: TIntegerField;
    QDocumentsREHBERID: TIntegerField;
    QDocumentsILGILIID: TIntegerField;
    QDocumentsPROJEID: TIntegerField;
    QDocumentsAKTIVITEID: TIntegerField;
    QDocumentsKLASOR: TIntegerField;
    QDocumentsGECERLILIK_TARIHI: TDateTimeField;
    QDocumentsEKLEYEN: TSmallintField;
    QDocumentsEKLEMETARIHI: TDateTimeField;
    QDocumentsDEGISTIREN: TSmallintField;
    QDocumentsDEGISTIRMETARIHI: TDateTimeField;
    QDocumentsESKIKLASOR: TIntegerField;
    QDocumentsMODUL: TWordField;
    QDocumentsBAGI: TIntegerField;
    QDocumentsFIRMA: TWideStringField;
    QDocumentsACIKLAMA: TWideStringField;
    QDocumentsADSOYAD: TWideStringField;
    QDocumentsSorumluadi: TWideStringField;
    QDocumentsEXT: TStringField;
    QDocumentsdurumstr: TStringField;
    QGenIni: TADOQuery;
    QGenIniBOLUM: TIntegerField;
    QGenIniANAHTAR: TWideStringField;
    QGenIniDEGER: TIntegerField;
    QGenIniDIL: TSmallintField;
    QGenIniSIRA: TSmallintField;
    QDocumentsmodulstr: TStringField;
    QDocumentsKlasorad: TWideStringField;
    QDocumentsbolumstr: TStringField;
    QAraQuery1: TADOQuery;
    QAraQuery1ID: TAutoIncField;
    QAraQuery1KOD: TWideStringField;
    QAraQuery1FIRMA: TWideStringField;
    QAraQuery1GRUP: TSmallintField;
    QAraQuery1ADSOYAD: TWideStringField;
    QLocasion: TADOQuery;
    QLocasionID: TAutoIncField;
    QLocasionKOD: TWideStringField;
    QLocasionACIKLAMA: TWideStringField;
    QILGIli: TADOQuery;
    QILGIliADSOYAD: TWideStringField;
    QILGIliID: TAutoIncField;
    QAraQuery1GrupSTr: TStringField;
    procedure IWUserSessionBaseCreate(Sender: TObject);
    procedure IWUserSessionBaseDestroy(Sender: TObject);
    procedure QDocumentsYONSTRGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure QDocumentsdurumstrGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure QDocumentsBeforeOpen(DataSet: TDataSet);
    procedure QDocumentsmodulstrGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure QDocumentsbolumstrGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure QAraQuery1GrupSTrGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  private
    { Private declarations }

  public
    { Public declarations }
        GenModules:TStringList;
        GenBolums:Tstringlist;
        GenGrugs:Tstringlist;
        procedure ReadGenINI;
        function DecodeGenGrups(value:string):string;
        Function DecodeGenModules(value:string):string;
        Function DecodeGenBolums(value:string):string;

  end;
var
   IwYon1:string='';
   IwYon2:string='';
implementation

uses DatamoduleUnit, PrjConst;

{$R *.dfm}

var
   LanguageCode:integer=-1;

const
   Bolum      =-3200;
   Bolum_Yon  =Bolum-5;
procedure TIWUserSession.IWUserSessionBaseCreate(Sender: TObject);
begin
     DBFly.Connected:=true;
     QLangStringTab.Active:=false;
     try
        QLangStringTab.Parameters.ParamByName('BL').Value:=Bolum_yon;
        QLangStringTab.Parameters.ParamByName('DL').Value:=LanguageCode;
        QLangStringTab.Active:=true;
        GenModules :=TStringList.Create;
        GenBolums  :=TStringList.Create;
        GenGrugs   :=TStringList.Create;
        ReadGenINI;
        try
           while not QLangStringTab.eof do
           begin
                case QLangStringTabDEGER.AsInteger of
                   1:IwYon1:=QLangStringTabANAHTAR.AsString;
                   2:IwYon2:=QLangStringTabANAHTAR.AsString;
                end;
                QLangStringTab.Next;
           end;
        finally
              QLangStringTab.Active:=false;
        end;
     except
     end;
end;

procedure TIWUserSession.IWUserSessionBaseDestroy(Sender: TObject);
begin
     DBFly.Connected:=false;
     GenModules.Free;
     GenBolums.Free;
     GenGrugs.Free;
end;
procedure TIWUserSession.ReadGenINI;
begin
     try
        QGenIni.Parameters.ParamByName('bolum').Value:=Ops_Dokuman_Modul;
        QGenIni.Parameters.ParamByName('dil').Value:=LanguageCode;

        QGenIni.Active:=false;
        QGenIni.Active:=true;
        try
           GenModules.Sorted:=false;
           GenModules.Clear;
           while not QGenIni.Eof  do
           begin
                 GenModules.Values[trim(QGenIniDEGER.AsString)]:=QGenIniANAHTAR.AsString;
                 QGenIni.Next;
           end;

        finally
               QGenIni.Active:=false;
        end;
        QGenIni.Parameters.ParamByName('bolum').Value:=Ops_CariKart_Bölüm;
        QGenIni.Parameters.ParamByName('dil').Value:=LanguageCode;

        QGenIni.Active:=false;
        QGenIni.Active:=true;
        try
           GenBolums.Sorted:=false;
           GenBolums.Clear;
           while not QGenIni.Eof  do
           begin
                 GenBolums.Values[trim(QGenIniDEGER.AsString)]:=QGenIniANAHTAR.AsString;
                 QGenIni.Next;
           end;

        finally
               QGenIni.Active:=false;
        end;
        QGenIni.Parameters.ParamByName('bolum').Value:=Ops_CariKart_Grup;
        QGenIni.Parameters.ParamByName('dil').Value:=LanguageCode;

        QGenIni.Active:=false;
        QGenIni.Active:=true;
        try
           GenGrugs.Sorted:=false;
           GenGrugs.Clear;
           while not QGenIni.Eof  do
           begin
                 GenGrugs.Values[trim(QGenIniDEGER.AsString)]:=QGenIniANAHTAR.AsString;
                 QGenIni.Next;
           end;

        finally
               QGenIni.Active:=false;
        end;


     except
     end;
end;
procedure TIWUserSession.QAraQuery1GrupSTrGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
     if not assigned(GenGrugs)
     then
         if GenGrugs.Count=0
         then
             ReadGenINI;
     text:=GenGrugs.Values[QAraQuery1GRUP.AsString];


end;

procedure TIWUserSession.QDocumentsBeforeOpen(DataSet: TDataSet);
begin
     ReadGenINI;

end;

procedure TIWUserSession.QDocumentsbolumstrGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
     Text:='';
     if assigned(GenModules)
     then
         Text:=GenModules.Values[trim(QDocumentsBOLUM.AsString)];

end;

procedure TIWUserSession.QDocumentsdurumstrGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
     case QDocumentsDURUM.AsInteger of
          0:text:='Pasif';
          1:text:='Aktif';
     end;

end;

procedure TIWUserSession.QDocumentsmodulstrGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
     Text:='';
     if assigned(GenModules)
     then
         Text:=GenModules.Values[trim(QDocumentsMODUL.AsString)];
end;

procedure TIWUserSession.QDocumentsYONSTRGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
     case QDocumentsYON.AsInteger  of
          1:Text:=IwYon1;
          2:Text:=IwYon2;
     end;
end;
function TIWUserSession.DecodeGenGrups(value:string):string;
var
   i,j:integer;
   s:string;
begin
     result:='';
     if not assigned(GenGrugs) then exit;
     for i:=0 to GenGrugs.Count-1 do
     begin
          s:=GenGrugs.Strings[i];
          j:=pos('=',s);
          if j>0
          then
          begin
               if copy(s,j+1,255)=value
               then
               begin
                    result:=copy(s,1,j-1);
                    exit;
               end;

          end;

     end;


end;
function TIWUserSession.DecodeGenModules(value:string):string;
var
   i,j:integer;
   s:string;
begin
     result:='';
     if not assigned(GenModules) then exit;
     for i:=0 to GenModules.Count-1 do
     begin
          s:=GenModules.Strings[i];
          j:=pos('=',s);
          if j>0
          then
          begin
               if copy(s,j+1,255)=value
               then
               begin
                    result:=copy(s,1,j-1);
                    exit;
               end;

          end;

     end;


end;
function TIWUserSession.DecodeGenBolums(value:string):string;

var
   i,j:integer;
   s:string;
begin
     result:='';
     if not assigned(GenBolums) then exit;
     for i:=0 to GenBolums.Count-1 do
     begin
          s:=GenBolums.Strings[i];
          j:=pos('=',s);
          if j>0
          then
          begin
               if copy(s,j+1,255)=value
               then
               begin
                    result:=copy(s,1,j-1);
                    exit;
               end;

          end;

     end;


end;
end.


