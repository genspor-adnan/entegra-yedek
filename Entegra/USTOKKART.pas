unit USTOKKART;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, Buttons, oaAssist, ExtCtrls, oaPanel, AppEvnts,
  Grids, DBGrids;

type
  TSTOKKARTFORM = class(TForm)
    Label1: TLabel;
    DBEdit1: TDBEdit;
    Label2: TLabel;
    DBEdit2: TDBEdit;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    SpeedButton1: TSpeedButton;
    GroupBox3: TGroupBox;
    Label15: TLabel;
    Label16: TLabel;
    DBEdit15: TDBEdit;
    DBEdit16: TDBEdit;
    DBComboBox2: TDBComboBox;
    DBComboBox3: TDBComboBox;
    DBComboBox4: TDBComboBox;
    DBComboBox1: TDBComboBox;
    Label7: TLabel;
    DBEdit3: TDBEdit;
    DBComboBox5: TDBComboBox;
    Label9: TLabel;
    DBEdit4: TDBEdit;
    Label6: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    DBEdit5: TDBEdit;
    Label11: TLabel;
    DBEdit6: TDBEdit;
    Label12: TLabel;
    DBEdit7: TDBEdit;
    Label13: TLabel;
    DBComboBox6: TDBComboBox;
    GroupBox2: TGroupBox;
    DBGrid1: TDBGrid;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Label14: TLabel;
    Label17: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  STOKKARTFORM: TSTOKKARTFORM;

implementation
uses UANAFORM,UTABLO;
{$R *.DFM}


end.
