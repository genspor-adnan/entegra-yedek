unit UFIRMAARA;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Grids, DBGrids;

type
  TFIRMAARAFORM = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBGrid1: TDBGrid;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIRMAARAFORM: TFIRMAARAFORM;

implementation
uses UTABLO;
{$R *.DFM}

procedure TFIRMAARAFORM.BitBtn1Click(Sender: TObject);
var sql : string;
begin
     sql := ' SELECT  FIRMAKODU,FIRMAADI,YETKILIADISOY,UNVANI,GRUP FROM FIRMALAR ';

     if trim(edit1.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.FIRMAADI =' + '''' + edit1.text + '''';
        sql := sql + ' and ';
     end;

     if trim(edit2.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.YETKILIADISOY =' + '''' + edit2.text + '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX1.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.UNVAN =' + '''' + COMBOBOX1.text + '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX2.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.GRUP =' + '''' + COMBOBOX2.text + '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX3.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.OZELTANIM =' + '''' + COMBOBOX3.text + '''';
        sql := sql + ' and ';
     end;

    if pos('and',sql) <> 0 then
            sql := copy(sql,1,length(sql) - 5);

     sql := trim(sql);

     DM.FIRARA.CLOSE;
     DM.FIRARA.SQL.CLEAR;
     DM.FIRARA.SQL.ADD(SQL);
     DM.FIRARA.OPEN;
end;

procedure TFIRMAARAFORM.FormCreate(Sender: TObject);
begin
        DM.FIRARA.CLOSE;
end;

procedure TFIRMAARAFORM.BitBtn2Click(Sender: TObject);
var sql : string;
begin
     sql := ' SELECT  FIRMAKODU,FIRMAADI,YETKILIADISOY,UNVANI,GRUP FROM FIRMALAR ';

     if trim(edit1.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.FIRMAADI like ' + '''' +'%'+ edit1.text +'%'+ '''';
        sql := sql + ' and ';
     end;

     if trim(edit2.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.YETKILIADISOY like ' + '''' +'%'+ edit2.text +'%'+ '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX1.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.UNVAN like ' + '''' +'%'+ COMBOBOX1.text +'%'+ '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX2.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.GRUP like ' + '''' +'%'+ COMBOBOX2.text +'%'+ '''';
        sql := sql + ' and ';
     end;

     if trim(COMBOBOX3.text) <> '' then
     begin
        if pos('where',sql) = 0 then sql := sql + ' WHERE ';
        sql := sql + ' FIRMALAR.OZELTANIM like ' + '''' +'%'+ COMBOBOX3.text +'%'+ '''';
        sql := sql + ' and ';
     end;

    if pos('and',sql) <> 0 then
            sql := copy(sql,1,length(sql) - 5);

     sql := trim(sql);

     DM.FIRARA.CLOSE;
     DM.FIRARA.SQL.CLEAR;
     DM.FIRARA.SQL.ADD(SQL);
     DM.FIRARA.OPEN;
end;

end.
