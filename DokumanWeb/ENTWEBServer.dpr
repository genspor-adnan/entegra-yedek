program ENTWEBServer;

uses
IWInitService,  FUSerLogin in 'FUSerLogin.pas' {IWLogin: TIWAppForm},
  ServerController in 'ServerController.pas' {IWServerController: TIWServerControllerBase},
  UserSessionUnit in 'UserSessionUnit.pas' {IWUserSession: TIWUserSessionBase},
  DatamoduleUnit in 'DatamoduleUnit.pas' {DataModule1: TDataModule},
  browseklasor in 'browseklasor.pas' {IWFBrowseDocs: TIWAppForm},
  PrjConst in 'PrjConst.pas',
  Searchform in 'Searchform.pas' {IWGrupSearchForm: TIWAppForm};

{$R *.res}

begin
  IWRun;
end.

