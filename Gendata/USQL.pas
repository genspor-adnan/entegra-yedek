unit USQL;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Db, DBTables, Grids, DBGrids;

type
  TSQLDlg = class(TForm)
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Query1: TQuery;
    Memo1: TMemo;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SQLDlg: TSQLDlg;

implementation

{$R *.DFM}

procedure TSQLDlg.BitBtn1Click(Sender: TObject);
begin

   Query1.SQL.Clear;
   Query1.SQL.AddStrings(Memo1.Lines);
   if pos('SELECT', UpperCase(Memo1.Text))>0 then
      Query1.Open
   else
      Query1.ExecSQL;
end;

procedure TSQLDlg.BitBtn2Click(Sender: TObject);
begin
   Close;
end;

end.

{
BACKUP DATABASE BETAMAR
TO DISK = 'c:\BETAMAR\YEDEK\YEDEK'
RESTORE DATABASE BETAMAR
   FROM DISK = 'c:\GEN2000\DENGE'
   WITH MOVE 'GEN3000_DATA' TO
'c:\MSSQL7\DATA\BETAMAR.MDF',
   MOVE 'GEN3000_LOG' TO
'c:\MSSQL7\DATA\BETAMAR_LOG.LDF'
}
{
BEGIN TRANSACTION                                 BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON                          SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE      SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON                                 SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF                        SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON                    SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON                                 SET ANSI_NULLS ON
SET ANSI_PADDING ON                               SET ANSI_PADDING ON
SET ANSI_WARNINGS ON                              SET ANSI_WARNINGS ON
COMMIT                                            COMMIT
                                                  BEGIN TRANSACTION
BEGIN TRANSACTION                                 CREATE TABLE dbo.DENE10
CREATE TABLE dbo.Table3                           (
	(                                         AA varchar(10)  NOT NULL PRIMARY KEY CLUSTERED,
	AA varchar(50) NOT NULL,                  BB varchar(10)  NULL
	BB varchar(50) NULL                       )  ON [PRIMARY]
	)  ON [PRIMARY]
GO                                                ALTER TABLE dbo.DENE10 ADD CONSTRAINT
                                                  PK_DENE10 PRIMARY KEY CLUSTERED
ALTER TABLE dbo.Table3 ADD CONSTRAINT             (AA) ON [PRIMARY]
	PK_Table3 PRIMARY KEY CLUSTERED
	(
	AA
	) ON [PRIMARY]

GO

COMMIT
}


BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
CREATE TABLE dbo.DENE10
(
AA VARCHAR(10)  NOT  NULL ,
BB VARCHAR(10)  NULL
)  ON [PRIMARY]

ALTER TABLE dbo.DENE10 ADD CONSTRAINT
PK_DENE10 PRIMARY KEY CLUSTERED
(AA) ON [PRIMARY]







