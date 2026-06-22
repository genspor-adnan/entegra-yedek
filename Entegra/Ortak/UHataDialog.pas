unit UHataDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, ExtCtrls, Buttons, GraphicEx,
  dxGDIPlusClasses;

type
  TErrorDialogForm = class(TForm)
    Bevel1: TBevel;
    Label3: TLabel;
    ImageOk: TImage;
    errorDescriptionMemo: TMemo;
    MoreButton: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ImageError: TImage;
    ImageInformation: TImage;
    Panel1: TPanel;
    Label5: TLabel;
    Label2: TLabel;
    resolutionMemo: TMemo;
    causesMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure MoreButtonClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    FExpanded: Boolean;
    procedure SetExpanded(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property Expanded : Boolean read FExpanded write SetExpanded;
  end;

  procedure ShowErrorDialog(description,causes,resolution, errortype: string);

var
  ErrorDialogForm: TErrorDialogForm;
    
implementation
{$R *.dfm}

procedure ShowErrorDialog(description,causes,resolution, errortype : string);
begin
  with TErrorDialogForm.Create(Application) do
    begin
      errorDescriptionMemo.Lines.Text := description;
      causesMemo.Lines.Text := causes;
      resolutionMemo.Lines.Text := resolution;
       if errortype='imageOk' then
         begin
            ImageError.Visible:=False;
            ImageInformation.Visible:=False;
            ImageOk.Visible:=True;
            errorDescriptionMemo.Color:=$0080FF80;
            Caption := 'Bilgi';
         end
       else if errortype='imageInformation' then
         begin
            ImageOk.Visible:=False;
            ImageError.Visible:=False;
            ImageInformation.Visible:=True;
            errorDescriptionMemo.Color:= clSilver;
            Caption := 'Bilgi';
         end
       else 
         begin
            ImageOk.Visible:=False;
            ImageInformation.Visible:=False;
            ImageError.Visible:=True;
            errorDescriptionMemo.Color:= $008080FF;
            Caption := 'Hata';
         end;
      ShowModal;
      Free;
    end;
end;


procedure TErrorDialogForm.SetExpanded(const Value: Boolean);
begin
  FExpanded := Value;
  if (Value) then
    begin
      Height := 423;
      moreButton.Caption := 'Ayrıntı Gizle';
      Panel1.Height := 218;
    end
  else
    begin
      moreButton.Caption := 'Ayrıntı Göster';
      Height := 187;
    end;
end;

procedure TErrorDialogForm.FormCreate(Sender: TObject);
begin
  Expanded := False;
end;

procedure TErrorDialogForm.MoreButtonClick(Sender: TObject);
begin
  Expanded := not Expanded;
end;

procedure TErrorDialogForm.SpeedButton2Click(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
