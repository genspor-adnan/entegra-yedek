unit UTakvimAcilisKaydi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin,Utablo, DB, FireDAC.Comp.Client;

type
  TfrmTakvimAcilis = class(TForm)
    tlb1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SilTus: TToolButton;
    btn1: TToolButton;
    BelgeTus: TToolButton;
    ToolButton1: TToolButton;
    Iptal: TToolButton;
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTakvimAcilis: TfrmTakvimAcilis;

implementation
  Uses LocOnFly,PrjConst;

{$R *.dfm}

procedure TfrmTakvimAcilis.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TfrmTakvimAcilis.KaydetTusClick(Sender: TObject);
begin
  TabKasa.Post;
end;

end.

