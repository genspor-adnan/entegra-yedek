unit UMailRehber;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, ExtCtrls, DB, UFDCompatHelpers, Buttons, DBCtrls,
  Mask;

type
  TMailRehberDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    EditAliciAd: TEdit;
    GridAdresDefteri: TDBGrid;
    DtsAdresDefteri: TDataSource;
    qryAdresDefteri: TADOQuery;
    KapatBtn: TSpeedButton;
    SecBtn: TSpeedButton;
    Panel: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    PanelDetay: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    EditAdsoyad: TDBEdit;
    EditMeslek: TDBEdit;
    DBComboBox1: TDBComboBox;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    BtnDuzenle: TSpeedButton;
    procedure EditAliciAdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure GridAdresDefteriDblClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure KapatBtnClick(Sender: TObject);
    procedure SecBtnClick(Sender: TObject);
    procedure BtnDuzenleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MailRehberDlg: TMailRehberDlg;

implementation
Uses UTablo;

{$R *.dfm}

procedure TMailRehberDlg.EditAliciAdKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if PanelDetay.Visible then Abort;

  if Key = 13 then  ModalResult:= mrOk
  else if Key = 40 then qryAdresDefteri.Next
  else if Key = 38 then qryAdresDefteri.Prior
  else begin
    qryAdresDefteri.Close;
    qryAdresDefteri.SQL.Text:= 'SELECT * FROM ADRESDEFTERI WHERE ISNULL(ADSOYAD,'''') LIKE '''+EditAliciAd.Text+'%'' ORDER BY ADSOYAD ';
    qryAdresDefteri.Open;
  end;  
end;

procedure TMailRehberDlg.SpeedButton3Click(Sender: TObject);
begin
  if qryAdresDefteri.State in [dsEdit,dsInsert] then 
   qryAdresDefteri.Post;
  PanelDetay.Visible:= False;
  qryAdresDefteri.Close;
  qryAdresDefteri.Open;
  
end;

procedure TMailRehberDlg.SpeedButton4Click(Sender: TObject);
begin
  if qryAdresDefteri.State in [dsEdit,dsInsert] then qryAdresDefteri.Cancel;
   PanelDetay.Visible:= False;
end;

procedure TMailRehberDlg.GridAdresDefteriDblClick(Sender: TObject);
begin
  ModalResult:=MrOk;
end;

procedure TMailRehberDlg.SpeedButton1Click(Sender: TObject);
begin
  qryAdresDefteri.Append;
  PanelDetay.Visible:=True;
end;

procedure TMailRehberDlg.FormActivate(Sender: TObject);
begin
  qryAdresDefteri.Close;
  qryAdresDefteri.Open;
end;

procedure TMailRehberDlg.KapatBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMailRehberDlg.SecBtnClick(Sender: TObject);
begin
  if qryAdresDefteri.RecordCount>0 then
     ModalResult:= mrOk;

end;

procedure TMailRehberDlg.BtnDuzenleClick(Sender: TObject);
begin
   PanelDetay.Visible:=True;
end;

end.

