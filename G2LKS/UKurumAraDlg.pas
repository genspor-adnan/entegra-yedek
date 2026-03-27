unit UKurumAraDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxGraphics,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxControls, cxGridCustomView, cxGrid, cxTextEdit, cxContainer,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox, StdCtrls, ADODB, cxStyles;

type
  TKurumAraDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    cbSube: TcxImageComboBox;
    editKurumAra: TcxTextEdit;
    tvKurumAra: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    clmKurumAdi: TcxGridDBColumn;
    clmKurumGrubu: TcxGridDBColumn;
    tabKurumAra: TADOQuery;
    lbSube: TLabel;
    btnEkle: TButton;
    dtsKurumAra: TDataSource;
    procedure editKurumAraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnEkleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KurumAra;
    procedure cbSubePropertiesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  KurumAraDlg: TKurumAraDlg;

implementation
 Uses UTablo;
{$R *.dfm}

procedure  TKurumAraDlg.KurumAra;
begin
     if (SubeliSistem) and (cbSube.Text='') then
    begin
      ShowMessage('Önce Þube Seçiniz');
      abort;
    end;


     tabKurumAra.Close;
     tabKurumAra.SQL.Text:= 'SELECT KURUM , GRUBU FROM KURUM K WHERE KURUM LIKE ''%'+EditKurumAra.text+'%''  '+
     ' AND NOT EXISTS (SELECT KURUM FROM KURUMMUHASEBEKODLARI KM WHERE K.KURUM = KM.KURUM   ';
     if SubeliSistem then tabKurumAra.SQL.Text:= tabKurumAra.SQL.Text+' AND  KM.SUBEID ='+cbSube.EditValue+' ';
     tabKurumAra.Sql.Add(' ) order by 1 ');
     tabKurumAra.open;
end;

procedure TKurumAraDlg.btnEkleClick(Sender: TObject);
begin
 if tabKurumAra.RecordCount<=0  then abort;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text:= 'INSERT INTO KURUMMUHASEBEKODLARI (KURUM ';
  if SubeliSistem then
    Tablo.Query1.SQL.Text:= Tablo.Query1.SQL.Text+ ' ,SUBEID ';
   Tablo.Query1.SQL.Add( ' ) VALUES ('''+tabKurumAra.FieldByName('KURUM').AsString+''' ');
  if SubeliSistem then
   Tablo.Query1.SQL.Add('  ,'+cbSube.EditValue+'  ');
   Tablo.Query1.SQL.Add(' ) ');
   
  Tablo.Query1.ExecSQL;


end;

procedure TKurumAraDlg.cbSubePropertiesChange(Sender: TObject);
begin
 KurumAra;
end;

procedure TKurumAraDlg.editKurumAraKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);

begin
//  if Key = 13 then  begin if Secti then DBGrid1DblClick(Self) end
    if Key = 40 then tabKurumAra.Next
  else if Key = 38 then tabKurumAra.Prior
  else  KurumAra;
end;

procedure TKurumAraDlg.FormCreate(Sender: TObject);
begin
 if SubeliSistem then
  begin
   cbSube.Visible:=True;
   lbSube.Visible:=True;
   cbSube.Properties:= Tablo.imgComboboxInit('SELECT ID, SUBE FROM SUBELER ORDER BY 2');
  end;
end;

end.
