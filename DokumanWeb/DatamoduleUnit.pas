unit DataModuleUnit;

interface

uses
  {$IFDEF Linux}QForms, {$ELSE}Forms, {$ENDIF}
  SysUtils, Classes, DB, ADODB;

type
  TDataModule1 = class(TDataModule)
  private
  public
  end;

  
implementation

{$R *.dfm}

end.
