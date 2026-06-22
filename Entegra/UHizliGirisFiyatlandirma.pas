unit UHizliGirisFiyatlandirma;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, Menus, cxLookAndFeelPainters,
  StdCtrls, cxButtons, cxLabel, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxCurrencyEdit, JvExControls, JvButton, JvNavigationPane, ExtCtrls,
  cxGraphics, cxLookAndFeels, dxSkinLiquidSky;

type
  THizliGirisFiyatlandirmaDlg = class(TForm)
    Panel1: TPanel;
    BtnNum1: TJvNavPanelButton;
    BtnNum8: TJvNavPanelButton;
    BtnNum7: TJvNavPanelButton;
    BtnNum6: TJvNavPanelButton;
    BtnNum4: TJvNavPanelButton;
    BtnNum5: TJvNavPanelButton;
    BtnNum2: TJvNavPanelButton;
    BtnNum3: TJvNavPanelButton;
    BtnNum9: TJvNavPanelButton;
    BtnNum0: TJvNavPanelButton;
    BtnNumComma: TJvNavPanelButton;
    BtnNumEnter: TJvNavPanelButton;
    BtnNumMinus: TJvNavPanelButton;
    BtnNumPlus: TJvNavPanelButton;
    BtnNumx: TJvNavPanelButton;
    BtnNumSls: TJvNavPanelButton;
    BtnNumBspc: TJvNavPanelButton;
    EditTutar: TcxCurrencyEdit;
    LabelKur: TcxLabel;
    cxLabel6: TcxLabel;
    BtnKapat: TcxButton;
    LabelUrunKod: TcxLabel;
    cxLabel1: TcxLabel;
    LabelUrunAd: TcxLabel;
    LabelKdvsiz: TcxLabel;
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnNumEnterClick(Sender: TObject);
    procedure EditTutarPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    TusBasili:Boolean;
    { Private declarations }
  public
    KDVOrani:Integer;
    { Public declarations }
  end;

var
  HizliGirisFiyatlandirmaDlg: THizliGirisFiyatlandirmaDlg;

implementation

uses Fetautil;//,LocOnFly;

{$R *.dfm}

procedure THizliGirisFiyatlandirmaDlg.FormShow(Sender: TObject);
begin


  EditTutar.SetFocus;
  EditTutar.SelectAll;
end;


procedure THizliGirisFiyatlandirmaDlg.BtnNumEnterClick(Sender: TObject);
begin
  if (Sender as TJvNavPanelButton).Caption = 'Ent' then
    ModalResult := mrOk
  else begin //if not TusBasili then
    //(ender as TJvNavPanelButton).Down := True;
    if (Sender as TJvNavPanelButton).Tag=55 then begin
      if EditTutar.SelLength>0 then
        EditTutar.ClearSelection
      else
        EditTutar.Text := Copy(EditTutar.Text,1,Length(EditTutar.Text)-1);
    end else begin
      EditTutar.ClearSelection;
      EditTutar.Text := EditTutar.Text+(Sender as TJvNavPanelButton).Caption;
    end;
    if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      EditTutar.SetFocus;
      EditTutar.SelStart:= Length(EditTutar.Text);
      EditTutar.PostEditValue;
    end;
  end;
end;

procedure THizliGirisFiyatlandirmaDlg.EditTutarPropertiesEditValueChanged(
  Sender: TObject);
begin
  LabelKdvsiz.Caption := 'KDV Hariç '+FCurrToStr(EditTutar.EditValue*(100/(100+KDVOrani)));
end;

procedure THizliGirisFiyatlandirmaDlg.FormCreate(Sender: TObject);
begin
//LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure THizliGirisFiyatlandirmaDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 8 then //BackSpace
    BtnNumBspc.click
  else if Key = 13 then //ENTER
    BtnNumEnter.Click
  else if Key=42 then //*
    BtnNumx.Click
  else if Key=43 then //+
    BtnNumPlus.Click
  else if Key=44 then //,
    BtnNumComma.Click
  else if Key=45 then //-
    BtnNumMinus.Click
  else if Key=46 then //.
    BtnNumComma.Click
  else if Key=47 then ///
    BtnNumSls.Click
  else if Key=48 then //0
    BtnNum0.Click
  else if Key=49 then //1
    BtnNum1.Click
  else if Key=50 then //2
    BtnNum2.Click
  else if Key=51 then //3
    BtnNum3.Click
  else if Key=52 then //4
    BtnNum4.Click
  else if Key=53 then //5
    BtnNum5.Click
  else if Key=54 then //6
    BtnNum6.Click
  else if Key=55 then //7
    BtnNum7.Click
  else if Key=56 then //8
    BtnNum8.Click
  else if Key=57 then //9
    BtnNum9.Click;

  EditTutar.PostEditValue;
end;


end.
