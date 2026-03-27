program ENTWEB;

uses
  Forms,
  IWMain,
  FUSerLogin in 'FUSerLogin.pas' {IWLogin: TIWAppForm},
  ServerController in 'ServerController.pas' {IWServerController: TIWServerControllerBase},
  UserSessionUnit in 'UserSessionUnit.pas' {IWUserSession: TIWUserSessionBase},
  DatamoduleUnit in 'DatamoduleUnit.pas' {DataModule1: TDataModule},
  browseklasor in 'browseklasor.pas' {IWFBrowseDocs: TIWAppForm},
  PrjConst in 'PrjConst.pas',
  Searchform in 'Searchform.pas' {IWGrupSearchForm: TIWAppForm},
  UGenSifre in 'UGenSifre.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformIWMain, formIWMain);
  Application.Run;
end.
