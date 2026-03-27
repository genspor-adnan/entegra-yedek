unit UGenelAktarimAyarlari;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ActnList, StdActns;
                 //  , folderBrowse
{$I options.inc}

type
  TaktarimAyarlariForm = class(TFrame)
    Label1: TLabel;
    aktarimYoluEdit: TEdit;
    browseButton: TButton;
    browseForFolder: TBrowseForFolder;
    OpenDialog1: TOpenDialog;
    procedure browseButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
  end;

implementation
uses
  UOpsiyon,UTablo, ECXMLParser,PrjConst;

{$R *.dfm}

{ TaktarimAyarlariForm }

constructor TaktarimAyarlariForm.Create(AOwner: TComponent);
var
  node : TXMLItem;
begin
  inherited;
//  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=aktarim_yolu',Tablo.configuration.Root);
//  aktarimYoluEdit.Text := node.Params.Values['yol'];

  case Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,1) of
    1:begin
       aktarimYoluEdit.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_LOGOExportPath,'C:\GEN2005\XML');
    end;
    2:begin
       aktarimYoluEdit.Text:= Tablo.GENINI.ReadString(Ops_G2LKS_ORKAExportPath,'C:\Winiceberg\Download');
    end;
  end;


end;

procedure TaktarimAyarlariForm.SaveContentMsg(var Msg: TMessage);
var
  node : TXMLItem;
begin
//  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=aktarim_yolu',Tablo.configuration.Root);
//  node.Params.Values['yol'] := IncludeTrailingBackslash(aktarimYoluEdit.Text);


  case Tablo.GENINI.ReadInteger(Ops_G2LKS_VarsayilanMuhasebeProg,1) of
    1:begin
       Tablo.GENINI.WriteString(Ops_G2LKS_LOGOExportPath,aktarimYoluEdit.Text);
    end;
    2:begin
       Tablo.GENINI.WriteString(Ops_G2LKS_ORKAExportPath,aktarimYoluEdit.Text);
    end;
  end;
end;

procedure TaktarimAyarlariForm.browseButtonClick(Sender: TObject);
begin
  browseForFolder.Folder := ExtractFilePath(aktarimYoluEdit.Text);
  if (browseForFolder.Execute) then
    begin
      aktarimYoluEdit.Text := browseForFolder.Folder;
    end;
end;

initialization
  RegisterOption(0,'Genel/Aktarým Ayarlarý',TaktarimAyarlariForm);

end.
