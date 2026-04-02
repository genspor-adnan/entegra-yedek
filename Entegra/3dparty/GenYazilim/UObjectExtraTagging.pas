unit UObjectExtraTagging;

interface


implementation
uses
  UCodeRedirect, FetaClassExtensions,Classes, Windows;

type
  TObjectPatch = class(TObject)
  public
    destructor Destroy;override;
  end;

var
  rd : TRedirectCode;

destructor TObjectPatch.Destroy;
begin
  if Self.InheritsFrom(TComponent) then
    TComponent(Self).UseExtraTagging := False;
end;

initialization
  rd := CodeRedirect(@TObject.Destroy,@TObjectPatch.Destroy);
finalization
  CodeRestore(rd);
end.
