unit UHazirSMS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, UFDCompatHelpers, StdCtrls, DBCtrls, Grids, DBGrids, ExtCtrls, Buttons;

type
  THazirSMSDlg = class(TForm)
    DBGrid1: TDBGrid;
    DtsHazirSMS: TDataSource;
    TabHazirSMS: TADOQuery;
    Panel1: TPanel;
    Navigator: TDBNavigator;
    Panel2: TPanel;
    mMESAJ: TDBMemo;
    Panel3: TPanel;
    lbKalKarakter: TLabel;
    BitBtn1: TBitBtn;
    Panel4: TPanel;
    Label1: TLabel;
    procedure DtsHazirSMSStateChange(Sender: TObject);
    procedure TabHazirSMSBeforeDelete(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure mMESAJChange(Sender: TObject);
    procedure TabHazirSMSAfterScroll(DataSet: TDataSet);
    procedure TabHazirSMSNewRecord(DataSet: TDataSet);
    procedure TabHazirSMSBeforePost(DataSet: TDataSet);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HazirSMSDlg: THazirSMSDlg;

implementation

uses UTablo;

{$R *.dfm}

procedure THazirSMSDlg.DtsHazirSMSStateChange(Sender: TObject);
begin
//  Tablo.YetkiTuslariBelirle('', '', 'AE',DtsHazirSMS, Navigator);
  if DtsHazirSMS.State in [dsEdit, dsInsert] then
    Navigator.VisibleButtons := [nbPost, nbCancel]
  else
    Navigator.VisibleButtons := [nbInsert, nbDelete];
end;

procedure THazirSMSDlg.TabHazirSMSBeforeDelete(DataSet: TDataSet);
begin
  if Application.MessageBox('Mesaj şablonu silinecektir. Onaylıyor musunuz?', 'O N A Y', mb_YESNO) <> IDYES then Abort;

end;

procedure THazirSMSDlg.FormShow(Sender: TObject);
begin
  TabHazirSMS.Close;
  TabHazirSMS.Open;

end;

procedure THazirSMSDlg.mMESAJChange(Sender: TObject);
begin
  lbKalKarakter.Caption := IntToStr(160 - Length(mMesaj.Text));
end;

procedure THazirSMSDlg.TabHazirSMSAfterScroll(DataSet: TDataSet);
begin
  lbKalKarakter.Caption := IntToStr(160 - Length(mMesaj.Text));

end;

procedure THazirSMSDlg.TabHazirSMSNewRecord(DataSet: TDataSet);
begin
  TabHazirSMS.FieldByName('DURUM').AsString:='Aktif';
end;

procedure THazirSMSDlg.TabHazirSMSBeforePost(DataSet: TDataSet);
begin
  if (TabHazirSMS.FieldByName('BASLIK').AsString='') or (TabHazirSMS.FieldByName('BASLIK').IsNull) THEN
    raise Exception.Create('Mesaj başlığı boş bırakılamaz.');
end;

procedure THazirSMSDlg.BitBtn1Click(Sender: TObject);
begin
  close;
end;

end.

