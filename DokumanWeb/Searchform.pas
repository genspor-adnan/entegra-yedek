unit Searchform;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes,
  IWCompRadioButton, IWCompLabel, Controls, IWVCLBaseControl, IWBaseControl,
  IWBaseHTMLControl, IWControl, IWCompButton, IWCompEdit, IWCompListbox,
  IWGrids, IWDBGrids, DB, IWTreeview;

type
  TIWGrupSearchForm = class(TIWAppForm)
    IWBSelect: TIWButton;
    IWBClose: TIWButton;
    IWLGrup: TIWLabel;
    IWLKod: TIWLabel;
    IWLUnvan: TIWLabel;
    IWLIlgili: TIWLabel;
    IWRBaslayan: TIWRadioButton;
    IWRIcindeGencer: TIWRadioButton;
    IWEUnvan: TIWEdit;
    IWEIlgili: TIWEdit;
    IWEKod: TIWEdit;
    IWCGrup: TIWComboBox;
    DataSource1: TDataSource;
    IWDBGrid1: TIWDBGrid;
    IWTreeView1: TIWTreeView;
    procedure IWAppFormCreate(Sender: TObject);
    procedure IWCGrupChange(Sender: TObject);
    procedure IWEKodAsyncChange(Sender: TObject; EventParams: TStringList);
    procedure IWEUnvanAsyncChange(Sender: TObject; EventParams: TStringList);
    procedure IWEIlgiliAsyncChange(Sender: TObject; EventParams: TStringList);
    procedure IWTreeView1TreeItemClick(Sender: TObject;
      ATreeViewItem: TIWTreeViewItem);
  public
  private
        procedure RunSearchQuery;
  end;

implementation

uses UserSessionUnit, ServerController, browseklasor;

{$R *.dfm}
procedure TIWGrupSearchForm.IWAppFormCreate(Sender: TObject);
var
   i:integer;
begin
     IWCGrup.Items.Clear;
     for i := 0 to UserSession.GenGrugs.Count-1 do
         IWCGrup.Items.Add( UserSession.GenGrugs.ValueFromIndex[i]);

end;

procedure TIWGrupSearchForm.IWCGrupChange(Sender: TObject);
begin
     RunSearchQuery;
end;

procedure TIWGrupSearchForm.IWEIlgiliAsyncChange(Sender: TObject;
  EventParams: TStringList);
begin
     RunSearchQuery;
end;

procedure TIWGrupSearchForm.IWEKodAsyncChange(Sender: TObject; EventParams: TStringList);
begin
     RunSearchQuery;
end;

procedure TIWGrupSearchForm.IWEUnvanAsyncChange(Sender: TObject;
  EventParams: TStringList);
begin
     RunSearchQuery;
end;

procedure TIWGrupSearchForm.IWTreeView1TreeItemClick(Sender: TObject;
  ATreeViewItem: TIWTreeViewItem);
begin
//
end;

procedure TIWGrupSearchForm.RunSearchQuery;
    var
 s1, s, Fir,Yet,Kod,TFirma,TYet,TKod, Grup :string;
 i:integer;
 t:tstringlist;
begin
  s := '';
  Fir := ' R.FIRMA ';
  Yet := ' P.ADSOYAD ';
  Kod := ' R.KOD ';
  if  IWRBaslayan.Checked then
  begin
    TFirma := Trim(IWEUnvan.Text) + '%';
    TYet := Trim(IWEIlgili.Text) + '%';
    TKod := Trim(IWEKod.Text) + '%';
  end
  else if IWRIcindeGencer.Checked then
  begin
    TFirma := '%' + Trim(IWEUnvan.Text) + '%';
    TYet := '%' + Trim(IWEIlgili.Text) + '%';
    TKod := '%' + Trim(IWEKod.Text) + '%';
  end;
  if IWCGrup.Text <> ''
  then
  begin
       t:=UserSession.GenGrugs;
       s1:=IWCGrup.Items[IWCGrup.ItemIndex];
       t.Find(s1,i);



     Grup := ' and GRUP='+UserSession.GenGrugs.Names[ i]
  end
  else
     Grup := '';
  UserSession.qAraQuery1.Close;
  if IWEUnvan.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Fir + ' LIKE ''' + TFirma +''''+ Grup + ' ORDER BY FIRMA'  //   and ' + gorulmeyecekkod
  else if IWEIlgili.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and ' + Yet + ' LIKE ''' + TYet +''''+ Grup +'  ORDER BY FIRMA'             // and gorulmeyecekkod
  else if IWEKod.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Kod + ' LIKE ''' + TKod+'''' + Grup + '  ORDER BY ' + Kod     // and gorulmeyecekkod
  else if IWCGrup.Text <> '' then
    s := ' where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' ORDER BY FIRMA'
  else
    Exit;
  UserSession.qAraQuery1.SQL.Text := ' select R.ID,KOD,FIRMA,GRUP,ADSOYAD '+
                        ' from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERID ';
  UserSession.qAraQuery1.SQL.Add(s);
  UserSession.qAraQuery1.open;
end;



end.
