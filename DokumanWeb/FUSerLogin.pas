unit FUSerLogin;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWLayoutMgrHTML, IWCompButton, IWCompEdit, Controls, IWVCLBaseControl,
  IWBaseControl, IWBaseHTMLControl, IWControl, IWCompLabel,
  IWTemplateProcessorHTML, IWCompMemo, IWHTMLControls;

type
  TIWLogin = class(TIWAppForm)
    IWLUserName: TIWLabel;
    IWLPassword: TIWLabel;
    IWUserName: TIWEdit;
    IWPassWord: TIWEdit;
    IWBLogin: TIWButton;
    IWBCancle: TIWButton;
    IWLMessage: TIWLabel;
    IWTemplateProcessorHTML1: TIWTemplateProcessorHTML;
    procedure IWBLoginClick(Sender: TObject);
    procedure IWBCancleClick(Sender: TObject);
    procedure IWAppFormCreate(Sender: TObject);
  public
  end;

implementation

uses DatamoduleUnit, UserSessionUnit, ServerController, browseklasor,
  Searchform, UGenSifre, PrjConst;

{$R *.dfm}


procedure TIWLogin.IWAppFormCreate(Sender: TObject);
begin
     IWLUserName.Caption:=KontrolKullaniciAdi;
     IWLPassword.Caption:=KontrolSifre;
end;

procedure TIWLogin.IWBCancleClick(Sender: TObject);
begin
     IWUserName.Text:='';
     IWPassWord.Text:='';
end;

procedure TIWLogin.IWBLoginClick(Sender: TObject);
begin
     UserSession.qChechUserIDPASS.Active:=FALSE;
     UserSession.qChechUserIDPASS.Parameters.ParamByName('UID').Value:=trim(IWUserName.Text);
     UserSession.qChechUserIDPASS.Parameters.ParamByName('SFIRE').Value:=Sifre(trim(IWPassword.Text));
     UserSession.qChechUserIDPASS.Active:=true;
     if UserSession.qChechUserIDPASS.RecordCount =1
     then
     begin
     TIWFBrowseDocs.Create(WebApplication).showForm;
     end
     else
         IWLMessage.Text:='Kullanýcý adý veya þifre hatalý.';

end;

initialization
  TIWLogin.SetAsMainForm;

end.
