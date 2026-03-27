unit uTanimGridFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTanimBaseFrame, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, dxDateRanges, dxScrollbarAnnotations,
  Data.DB, cxDBData, Vcl.ExtCtrls, cxSplitter, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid,
  UTablo, uEvrakModule,
  System.Actions, Vcl.ActnList, Vcl.Buttons, FireDAC.Comp.Client;

type
  TEvrakTanimGridFrame = class(TEvrakTanimBaseFrame)
    PanelMain: TPanel;
    ViewTanim: TcxGridDBTableView;
    Level1: TcxGridLevel;
    GridTanim: TcxGrid;
    cxSplitter1: TcxSplitter;
    GridPanel1: TGridPanel;
    qryEvrak: TFDQuery;
    dsEvrak: TDataSource;
    procedure actSilUpdate(Sender: TObject);
    procedure actSilExecute(Sender: TObject);
    procedure actYeniKayitUpdate(Sender: TObject);
    procedure actYeniKayitExecute(Sender: TObject);
    procedure actKaydetUpdate(Sender: TObject);
    procedure actKaydetExecute(Sender: TObject);
    procedure actYazdirExecute(Sender: TObject);
  private
    { Private declarations }
    procedure SetActiveControl( _Control : TWinControl);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Startup; override;
    procedure FocusIlkControl( _scanGrid : TGridPanel); override;
    procedure GridIcerikDuzenle;
  end;

var
  EvrakTanimGridFrame: TEvrakTanimGridFrame;

implementation

{$R *.dfm}

uses
  {$IFDEF 3Dparty}
    uUtility_my,
  {$ENDIF 3Dparty}

   FetaUtil, PrjConst;

procedure TEvrakTanimGridFrame.actKaydetExecute(Sender: TObject);
begin
  qryEvrak.Post;
end;

procedure TEvrakTanimGridFrame.actKaydetUpdate(Sender: TObject);
begin
   TAction(Sender).Enabled := (qryEvrak.State in [dsEdit, dsInsert]);
end;

procedure TEvrakTanimGridFrame.actSilExecute(Sender: TObject);
begin
  //
  if Application.MessageBox(PWideChar(SSilmeSorusu), PWideChar(SGenotipOnay), MB_ICONQUESTION+MB_YESNO) = IDYES then begin
     qryEvrak.Delete;
  end;
end;

procedure TEvrakTanimGridFrame.actSilUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (qryEvrak.RecordCount>0) and (ViewTanim.DataController.FocusedRowIndex>-1);

end;

procedure TEvrakTanimGridFrame.actYazdirExecute(Sender: TObject);
begin
  Application.MessageBox('Yazdýrýlacak Bilgi bulunamadý!','Bilgilendirme', MB_ICONEXCLAMATION or MB_OK);

end;

procedure TEvrakTanimGridFrame.actYeniKayitExecute(Sender: TObject);

begin
  qryEvrak.Append;
  {
   Kayýt eklemeden sonra, GridPanel ilk sütun ilk Satýr EditControl ise FOCUS olmalý,
   Deðilse, ikinci sütun ilk satýr,
   deðilse ilk sütun ikinci satýr... vs EditoControl türevi bir bileþen bulana kadar ilerle,
   Yoksa yoktur, varsa Focus olmalý
  }

  //FocusIlkControl(GridPanel1);

end;

procedure TEvrakTanimGridFrame.actYeniKayitUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Not (qryEvrak.State in [dsEdit, dsInsert]);

end;

constructor TEvrakTanimGridFrame.Create(AOwner: TComponent);
begin
  inherited;
  GridIcerikDuzenle;
end;

procedure TEvrakTanimGridFrame.FocusIlkControl( _scanGrid : TGridPanel);
var i : integer;
begin
   for i := 0 to _scanGrid.ControlCollection.Count-1 do
   begin
     if _scanGrid.ControlCollection.Items[i].Control Is TWinControl then
       begin
         TwinControl(_scanGrid.ControlCollection.Items[i].Control).SetFocus;
         SetActiveControl (TWinControl(_scanGrid.ControlCollection.Items[i].Control));
       end;
   end;
end;


procedure TEvrakTanimGridFrame.GridIcerikDuzenle;
var
 i : integer;
begin
 for i := 0 to ComponentCount-1 do
     begin
       if Components[i] is TcxCustomGridTableView then
        begin
           TcxCustomGridTableView(Components[i]).OptionsView.NoDataToDisplayInfoText := '';
           TcxCustomGridTableView(Components[i]).FindPanel.InfoText := 'Aranacak metni girin...';
        end;
     end;
end;

procedure TEvrakTanimGridFrame.SetActiveControl(_Control: TWinControl);
var
  form : TScrollingWinControl;
  parentControl : TWinControl;
begin
   form := Nil;
   parentControl := Self;
     while parentControl<>Nil do
      begin
          if parentControl is TForm then
            begin
                form := TScrollingWinControl(parentControl);
                Break;
            end
             else
               parentControl := parentControl.Parent;
      end;
   if Assigned(form) then
     TCustomForm(form).ActiveControl := _Control;

end;

procedure TEvrakTanimGridFrame.Startup;
begin
  if Trim(qryEvrak.SQL.Text) <> '' then
    qryEvrak.Open;
  inherited;

end;

end.

