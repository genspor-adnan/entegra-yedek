unit browseklasor;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, Controls,
  IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl, IWControl, IWTreeview,
  IWHTMLControls, IWGrids, IWDynGrid, DB, IWDBGrids, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, IWCompLabel, Forms, IWVCLBaseContainer, IWContainer,
  IWHTMLContainer, IWHTML40Container, IWRegion,ADODB, IWDBStdCtrls, IWExtCtrls,
  IWCompTabControl, IWCompEdit, IWLayoutMgrHTML, IWCompOrderedListbox,
  IWCompListbox, IWCompButton, IWCompRadioButton, IWContainer32Layout,
  IWTemplateProcessorHTML32, IWLayoutMgrForm ;
type

  TilgiliTabRec=record
    ID         :integer;
    Unvan      :string;
  end;
  TGENWEBSearType=(GENWEBS_KURUM,GENWEBS_ilgili,GENWEBS_Surumlusu,GENWEBS_Lokasyon,GENWEBS_Kategory);
  TIWFBrowseDocs = class(TIWAppForm)
    IWTemplateProcessorHTML2: TIWTemplateProcessorHTML;
    IWRegion1: TIWRegion;
    DataSource1: TDataSource;
    IWRegSearchGroup: TIWRegion;
    IWBClose: TIWButton;
    IWBSelect: TIWButton;
    IWLGrup: TIWLabel;
    IWLKod: TIWLabel;
    IWLUnvan: TIWLabel;
    IWLIlgili: TIWLabel;
    IWRIcindeGencer: TIWRadioButton;
    IWRBaslayan: TIWRadioButton;
    IWEUnvan: TIWEdit;
    IWEIlgili: TIWEdit;
    IWEKod: TIWEdit;
    IWCGrup: TIWComboBox;
    DataSource2: TDataSource;
    IWBSearch: TIWButton;
    IWBReset: TIWButton;
    IWRegGRIDSearch: TIWRegion;
    IWSearchList: TIWDBGrid;
    IWRegLokasyon: TIWRegion;
    IWTLokasyon: TIWTreeView;
    IWBSelect1: TIWButton;
    IWBClose1: TIWButton;
    IWNAVIGATION: TIWTabControl;
    IWTabControl1Page0: TIWTabPage;
    IWTFolders: TIWTreeView;
    IWTabControl1Page1: TIWTabPage;
    IWRegion2: TIWRegion;
    IWEDOKAD: TIWEdit;
    IWLDOKAD: TIWLabel;
    IWLKonusu: TIWLabel;
    IWEKonusu: TIWEdit;
    IWLModul: TIWLabel;
    IWCModul: TIWComboBox;
    IWCBolum: TIWComboBox;
    IWLBolumu: TIWLabel;
    IWLKurum: TIWLabel;
    IWBKurum: TIWButton;
    IWEKurum: TIWEdit;
    IWLIlgili1: TIWLabel;
    IWESurumlusu: TIWEdit;
    IWBSurumlusu: TIWButton;
    IWLSurumlusu: TIWLabel;
    IWBLokasyon: TIWButton;
    IWELokasyon: TIWEdit;
    IWLLokasyon: TIWLabel;
    IWCIlgili: TIWComboBox;
    IWBsearch1: TIWButton;
    IWBClear1: TIWButton;
    IWRBaslayan1: TIWRadioButton;
    IWRIcindeGencer1: TIWRadioButton;
    IWRegion3: TIWRegion;
    IWDocList: TIWDBGrid;
    procedure IWTFoldersTreeItemClick(Sender: TObject;
      ATreeViewItem: TIWTreeViewItem);
    procedure IWNFirstAsyncClick(Sender: TObject; EventParams: TStringList);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure IWDocListRenderCell(ACell: TIWGridCell; const ARow,
      AColumn: Integer);
    procedure IWImageButton1Click(Sender: TObject);
    procedure IWAppFormCreate(Sender: TObject);
    procedure IWBKurumClick(Sender: TObject);
    procedure IWRegSearchGroupRender(Sender: TObject);
    procedure IWBSearchClick(Sender: TObject);
    procedure IWBResetClick(Sender: TObject);
    procedure IWSearchListRenderCell(ACell: TIWGridCell; const ARow,
      AColumn: Integer);
    procedure IWButton1Click(Sender: TObject);
    procedure IWBSelectClick(Sender: TObject);
    procedure IWBIlgili1Click(Sender: TObject);
    procedure IWBSurumlusuClick(Sender: TObject);
    procedure IWBLokasyonClick(Sender: TObject);
    procedure IWTLokasyonTreeItemClick(Sender: TObject;
      ATreeViewItem: TIWTreeViewItem);
    procedure IWBClear1Click(Sender: TObject);
    procedure IWBsearch1Click(Sender: TObject);
    procedure IWNAVIGATIONChange(Sender: TObject);
    procedure IWBCloseClick(Sender: TObject);
  private
         SearchType:TGENWEBSearType;
         IlgiliTab :array of TilgiliTabRec;
         Resultstring:string;
         LokasyonIdI:integer;

  public
  procedure showForm;
  procedure hidebrowser;
  procedure RunSearchQuery;
  procedure showBrowser;
  procedure SearhForKurum;
  procedure SearchForSurumlu;
  function ReadLokasyonTree:boolean;
  end;

implementation
uses UserSessionUnit, ServerController,IdZLibEx, Searchform;

{$R *.dfm}
type
    TFolderS=record
      id:integer;
      ustid:integer;
      name:widestring;
    end;
    TLocasionItem=record
      Id         : integer;
      Kod        : string;
      Ackilama   : string;
      par        : integer;
      Node       :TIWTreeViewItem;
      Lev,ParLev : integer;
    end;

procedure TIWFBrowseDocs.DataSource1DataChange(Sender: TObject; Field: TField);
begin
     if field<>nil then
     field.Tag:=UserSession.QDocumentsID.AsInteger;

end;

procedure TIWFBrowseDocs.IWAppFormCreate(Sender: TObject);
var
   i:integer;
begin
     IWCModul.Items.Clear;
     IWNAVIGATION.ActivePage:=0;
     for i := 0 to UserSession.GenModules.Count-1 do
         IWCModul.Items.Add( UserSession.GenModules.ValueFromIndex[i]);
     IWCBolum.Items.Clear;
     for i := 0 to UserSession.GenBolums.Count-1 do
         IWCBolum.Items.Add( UserSession.GenBolums.ValueFromIndex[i]);


end;

procedure TIWFBrowseDocs.IWBClear1Click(Sender: TObject);
begin
     IWEDOKAD.Text:='';
     IWEKonusu.Text:='';
     IWCModul.ItemIndex:=-1;
     IWCBolum.ItemIndex:=-1;
     IWEKurum.Text:='';
     IWCIlgili.ItemIndex:=-1;
     IWCIlgili.Items.Clear;
     IWCIlgili.Enabled:=false;
     IWESurumlusu.Text:='';
     IWELokasyon.Text:='';

end;

procedure TIWFBrowseDocs.IWBCloseClick(Sender: TObject);
begin
     IWRegSearchGroup.Visible:=false;
     IWRegLokasyon.Visible:=false;


     showBrowser;

end;

procedure TIWFBrowseDocs.IWBIlgili1Click(Sender: TObject);
begin
     if trim(IWEKurum.Text)=''
     then
         WebApplication.ShowMessage('You must select kurum');

end;

procedure TIWFBrowseDocs.IWBKurumClick(Sender: TObject);
begin
     SearhForKurum;
end;
procedure TIWFBrowseDocs.IWBLokasyonClick(Sender: TObject);
begin
     if ReadLokasyonTree
     then
     begin
          hidebrowser;
     SearchType:=GENWEBS_Lokasyon;
     IWRegSearchGroup.Visible:=false;
     IWRegLokasyon.left:=0;
     IWRegLokasyon.top:=0;
     IWRegLokasyon.Visible:=true;
     IWRegLokasyon.Align:=alClient;

     end;

end;

procedure TIWFBrowseDocs.SearhForKurum;
begin
     hidebrowser;
     IWRegLokasyon.Visible:=FALSE;
     IWRegion3.Visible:=false;
     SearchType:=GENWEBS_KURUM;
     IWRegSearchGroup.left:=0;
     IWRegSearchGroup.top:=0;
     IWCGrup.ItemIndex:=-1;
     IWCGrup.Enabled:=true;
     IWRegSearchGroup.Align:=alClient;
     IWRegSearchGroup.Visible:=true;
     RunSearchQuery;

end;
procedure TIWFBrowseDocs.SearchForSurumlu;
var
   s:string;
begin
     hidebrowser;
     IWRegion3.Visible:=false;
     IWRegLokasyon.Visible:=FALSE;

     SearchType:=GENWEBS_Surumlusu;
     IWRegSearchGroup.left:=0;
     IWRegSearchGroup.top:=0;
     s:=UserSession.GenGrugs.Values['335'];
     IWCGrup.ItemIndex:=IWCGrup.Items.IndexOf(s);
     IWCGrup.Enabled:=false;
     IWRegSearchGroup.Align:=alClient;
     IWRegSearchGroup.Visible:=true;
     RunSearchQuery;

end;

procedure TIWFBrowseDocs.IWBResetClick(Sender: TObject);
begin
     if SearchType<>GENWEBS_Surumlusu
     then
         IWCGrup.ItemIndex:=-1;
     IWEUnvan.Text:='';
     IWEIlgili.Text:='';
     iwekod.Text:='';
end;

procedure TIWFBrowseDocs.IWBsearch1Click(Sender: TObject);
function decodeilgili(s:string):integer;
var
   i:integer;
begin
     result:=-1;
     if length(IlgiliTab)=0 then exit;
     for i := low(IlgiliTab) to high(IlgiliTab) do
         if IlgiliTab[i].Unvan=s
         then
         begin
              result:=ilgiliTab[i].ID;
              exit;
         end;

end;
VAR
    S,s1,s2:STRING;
begin
     S:='(D.KLASOR > 0)';
     if IWRBaslayan1.Checked
     then
     BEGIN
          s1:=IWEDOKAD.Text;
          if trim(s1)<>''
          then
              s:='(d.ad like '''+s1+'%'')';
          s1:=IWEKonusu.Text;
          if trim(s1)<>''
          then
          begin
              if s<>'' then s:=s+' and ';
              s:=s+'(d.KONU like '''+s1+'%'')';
          end;
     END
     else
     if IWRIcindeGencer1.Checked
     then
     BEGIN
          s1:=IWEDOKAD.Text;
          if trim(s1)<>''
          then
              s:='(d.ad like ''%'+s1+'%'')';
          s1:=IWEKonusu.Text;
          if trim(s1)<>''
          then
          begin
              if s<>'' then s:=s+' and ';
              s:=s+'(d.KONU like ''%'+s1+'%'')';
          END;
     END;
     if IWCModul.ItemIndex>-1
     then
     begin
          s2:=UserSession.DecodeGenModules(IWCModul.Items.Strings[IWCModul.ItemIndex]);
          if s2<>''
          then
          begin
              s1:='(d.MODUL='+s2+')';
              if s<>''
              then
                  s:=s+' and '+s1
              else
                s:=s1;

          end;
     end;
     if IWCBolum.ItemIndex>-1
     then
     begin
          s2:=UserSession.DecodeGenBolums(IWCBolum.Items.Strings[IWCBolum.ItemIndex]);
          if s2<>''
          then
          begin
              s1:='(d.BOLUM='+s2+')';
              if s<>''
              then
                  s:=s+' and '+s1
              else
              s:=s1;

          end;
     end;
     if trim(IWEKurum.Text)<>''
     then
     begin
          s1:='(Firma.FIRMA = N'''+IWEKurum.Text+''')';
          if s<>''
          then
              s:=s+' and '+s1
          else
              s:=s1;
     end;
     if IWCIlgili.ItemIndex>-1
     then
     begin
          s1:='(Ilgili.ADSOYAD = N'''+IWCIlgili.Items.Strings[IWCIlgili.ItemIndex]+''')';
          if s<>''
          then
              s:=s+' and '+s1
          else
              s:=s1;

     end;
     if trim(IWESurumlusu.Text)<>''
     then
     begin
          s1:='(Sorumlu.FIRMA=N'''+IWESurumlusu.Text+''')';
          if s<>''
          then
              s:=s+' and '+s1
          else
              s:=s1;
     end;
     if trim(IWELokasyon.Text)<>''
     then
     begin
          s1:='(D.LOKASYON = '+inttostr(LokasyonIdI)+')';
          if s<>''
          then
              s:=s+' and '+s1
          else
              s:=s1;

     end;


     UserSession.QDocuments.Active:=false;
     UserSession.QDocuments.sql.Clear;
     UserSession.QDocuments.sql.add('SELECT    top(200) 1 AS tip, D.ID, D.TARIH, D.BELGENO, D.DURUM, D.YON, D.KATEGORI, D.AD, D.SURUM, D.KONU, D.TUR, D.BOYUT, D.SORUMLU, D.BOLUM, D.LOKASYON,');
     UserSession.QDocuments.sql.add('                      D.REHBERID, D.ILGILIID, D.PROJEID, D.AKTIVITEID, D.KLASOR, D.GECERLILIK_TARIHI, D.EKLEYEN, D.EKLEMETARIHI, D.DEGISTIREN, D.DEGISTIRMETARIHI,');
     UserSession.QDocuments.sql.add('                      D.ESKIKLASOR, D.BAGI, Firma.FIRMA, Lokasyon.ACIKLAMA, Ilgili.ADSOYAD, Sorumlu.FIRMA AS Sorumluadi, ''.'' + REVERSE(SUBSTRING(REVERSE(ISNULL');
     UserSession.QDocuments.sql.add('                          ((SELECT     TOP (1) BELGEADI');
     UserSession.QDocuments.sql.add('                              FROM         IMAJ AS I');
     UserSession.QDocuments.sql.add('                              WHERE     (YERI = 1) AND (YER_ID = D.ID)');
     UserSession.QDocuments.sql.add('                              ORDER BY ID DESC), ''.'')), 1, CHARINDEX(''.'', REVERSE(ISNULL');
     UserSession.QDocuments.sql.add('                          ((SELECT     TOP (1) BELGEADI');
     UserSession.QDocuments.sql.add('                              FROM         IMAJ AS I');
     UserSession.QDocuments.sql.add('                              WHERE     (YERI = 1) AND (YER_ID = D.ID)');
     UserSession.QDocuments.sql.add('                              ORDER BY ID DESC), ''.'')), 1) - 1)) AS EXT, D.MODUL, DOKUMANKLASOR.AD AS Klasorad');
     UserSession.QDocuments.sql.add('FROM         DOKUMAN AS D LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      DOKUMANKLASOR ON D.KLASOR = DOKUMANKLASOR.ID LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBER AS Firma ON Firma.ID = D.REHBERID LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      LOKASYON AS Lokasyon ON Lokasyon.ID = D.LOKASYON LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBER AS Sorumlu ON Sorumlu.ID = D.SORUMLU LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBERPERSONEL AS Ilgili ON Ilgili.ID = D.ILGILIID');
     UserSession.QDocuments.sql.add('where '+s);
     UserSession.QDocuments.sql.add('union all');
     UserSession.QDocuments.sql.add('SELECT    top(200) 0 AS tip, D.ID, D.TARIH, D.BELGENO, D.DURUM, D.YON, D.KATEGORI, D.AD, D.SURUM, D.KONU, D.TUR, D.BOYUT, D.SORUMLU, D.BOLUM, D.LOKASYON,');
     UserSession.QDocuments.sql.add('                      D.REHBERID, D.ILGILIID, D.PROJEID, D.AKTIVITEID, D.KLASOR, D.GECERLILIK_TARIHI, D.EKLEYEN, D.EKLEMETARIHI, D.DEGISTIREN, D.DEGISTIRMETARIHI,');
     UserSession.QDocuments.sql.add('                      D.ESKIKLASOR, D.BAGI, Firma.FIRMA, Lokasyon.ACIKLAMA, Ilgili.ADSOYAD, Sorumlu.FIRMA AS Sorumluadi, ''.'' + REVERSE(SUBSTRING(REVERSE(ISNULL');
     UserSession.QDocuments.sql.add('                          ((SELECT     TOP (1) BELGEADI');
     UserSession.QDocuments.sql.add('                              FROM         IMAJ AS I');
     UserSession.QDocuments.sql.add('                              WHERE     (YERI = 1) AND (YER_ID = D.ID)');
     UserSession.QDocuments.sql.add('                              ORDER BY ID DESC), ''.'')), 1, CHARINDEX(''.'', REVERSE(ISNULL');
     UserSession.QDocuments.sql.add('                          ((SELECT     TOP (1) BELGEADI');
     UserSession.QDocuments.sql.add('                              FROM         IMAJ AS I');
     UserSession.QDocuments.sql.add('                              WHERE     (YERI = 1) AND (YER_ID = D.ID)');
     UserSession.QDocuments.sql.add('                              ORDER BY ID DESC), ''.'')), 1) - 1)) AS EXT, D.MODUL, DOKUMANKLASOR.AD AS Klasorad');
     UserSession.QDocuments.sql.add('FROM         DOKUMAN AS D INNER JOIN');
     UserSession.QDocuments.sql.add('                      DOKUMANKISAYOL ON D.ID = DOKUMANKISAYOL.DOKUMANID LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      DOKUMANKLASOR ON D.KLASOR = DOKUMANKLASOR.ID LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBER AS Firma ON Firma.ID = D.REHBERID LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      LOKASYON AS Lokasyon ON Lokasyon.ID = D.LOKASYON LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBER AS Sorumlu ON Sorumlu.ID = D.SORUMLU LEFT OUTER JOIN');
     UserSession.QDocuments.sql.add('                      REHBERPERSONEL AS Ilgili ON Ilgili.ID = D.ILGILIID');
     UserSession.QDocuments.sql.add('where '+s);
     try
        UserSession.QDocuments.Prepared:=true;
        UserSession.QDocuments.Active:=true;
     except on E: Exception do
     end;

end;

procedure TIWFBrowseDocs.IWBSearchClick(Sender: TObject);
begin
     RunSearchQuery;
end;

procedure TIWFBrowseDocs.IWBSelectClick(Sender: TObject);
var
   j,i:integer;
begin
     case SearchType of
          GENWEBS_KURUM:
                        begin
                             IWEKurum.Text:=UserSession.QAraQuery1FIRMA.AsString;
                             UserSession.QILGIli.Active:=false;

                             UserSession.QILGIli.Parameters.ParamByName('FRM').Value:=UserSession.QAraQuery1FIRMA.AsString;
                             try
                                UserSession.QILGIli.Active:=true;
                                try
                                   if  UserSession.QILGIli.RecordCount>0
                                   then
                                   begin
                                        setlength(IlgiliTab,UserSession.QILGIli.RecordCount);
                                        i:=0;
                                        while not UserSession.QILGIli.eof do
                                        begin
                                             IlgiliTab[i].ID:=UserSession.QILGIliID.AsInteger;
                                             IlgiliTab[i].Unvan:=UserSession.QILGIliADSOYAD.AsString;
                                             inc(i);
                                             UserSession.QILGIli.next;
                                        end;
                                        IWCIlgili.Enabled:=true;
                                        IWCIlgili.Clear;
                                        if length(IlgiliTab)>0
                                        then
                                            for I := low(IlgiliTab) to high(IlgiliTab) do
                                                IWCIlgili.Items.Add(IlgiliTab[i].Unvan)
                                        else
                                            IWCIlgili.Enabled:=false;
                                   end
                                   else
                                       IWCIlgili.Enabled:=false;

                                finally
                                       UserSession.QILGIli.Active:=false;
                                end;
                             except on E: Exception do
                                IWCIlgili.Enabled:=false;

                             end;

                             showBrowser;
                             UserSession.QAraQuery1.Active:=false;

                        end;
          GENWEBS_ilgili:;
          GENWEBS_Surumlusu:
                        begin
                             IWESurumlusu.Text:=UserSession.QAraQuery1FIRMA.AsString;
                             showBrowser;
                             UserSession.QAraQuery1.Active:=false;
                        end;

          GENWEBS_Lokasyon:
                           begin
                                if Resultstring=''
                                then
                                begin
                                    if IWTLokasyon.Selected<>nil
                                    then
                                    begin
                                        Resultstring:=IWTLokasyon.Selected.Caption;
                                        val(trim(IWTLokasyon.Selected.Hint),i,j);
                                        if j=0
                                        then
                                            LokasyonIdI:=i
                                        else
                                            LokasyonIdI:=-1;
                                    end;

                                end;

                                IWRegLokasyon.Visible:=false;
                                IWELokasyon.Text:=Resultstring;
                                showBrowser;
                           end;
          GENWEBS_Kategory:;
     end;
end;

procedure TIWFBrowseDocs.IWBSurumlusuClick(Sender: TObject);
begin
     SearchForSurumlu;
end;

procedure TIWFBrowseDocs.IWDocListRenderCell(ACell: TIWGridCell; const ARow,
  AColumn: Integer);
var

  s:string;
begin
     if arow>0
     then
     begin
         case AColumn of
            0:if acell.Control=nil
              then
              begin
                  ACell.Control:=TIWImageButton.Create(self);
                  TIWImageButton(ACell.Control).RenderSize:=true;
                  TIWImageButton(ACell.Control).Width:=16;
                  TIWImageButton(ACell.Control).Height:=16;
                  TIWImageButton(ACell.Control).StyleRenderOptions.RenderSize:=true;
                  TIWImageButton(ACell.Control).StyleRenderOptions.RenderPosition:=false;
                  TIWImageButton(ACell.Control).tag:=IWDocList.DataSource.DataSet.FieldByName('id').AsInteger;
                  TIWImageButton(ACell.Control).OnClick:=IWImageButton1Click;
                  IWDocList.DataSource.DataSet.FieldByName('id').AsInteger;
                  s:=IWDocList.DataSource.DataSet.FieldByName('EXT').AsString;
                  s:=system.Copy(s,2,255);
                  if FileExists(IWServerController.AppPath+'files\'+s+'.png')
                  then
                      TIWImageButton(ACell.Control).ImageFile.Filename:='files\'+s+'.png'
                  else
                      TIWImageButton(ACell.Control).ImageFile.Filename:='files\unknown.png';
              end
             else;

            8: begin

               end;

         end;
     end;



end;

procedure TIWFBrowseDocs.IWImageButton1Click(Sender: TObject);
var
   s:string;
   st:TMemoryStream;
   stf:TFileStream;
begin
     try

        UserSession.QRetrvieDOCIMJID.Parameters.ParamByName('ID').Value:=TIWImageButton(Sender).Tag;
        UserSession.QRetrvieDOCIMJID.Active:=true;
        try
           if UserSession.QRetrvieDOCIMJID.RecordCount>0
           then
           begin
                {UserSession.SPRetIMGFILE.Parameters.ParamByName('@ID').Value:=UserSession.QRetrvieDOCIMJIDid.asinteger;

                UserSession.SPRetIMGFILE.ExecProc;}
                UserSession.qSPRetIMGFILE.Active:=false;
                UserSession.qSPRetIMGFILE.SQL.Text:=' dbo.fn_Imaj_KayitliObjNesnesiniOku ' +UserSession.QRetrvieDOCIMJIDid.AsString;
                UserSession.qSPRetIMGFILE.ExecSQL;
                s:=IWServerController.UserCacheDir;
                s:=ExtractFileDir(s);
                s:=ExtractFileName(s);
                UserSession.QFetchFileName.Parameters.ParamByName('id').Value:=TIWImageButton(Sender).Tag;
                UserSession.QFetchFileName.Active:=true;
                st:=TMemoryStream.Create;
                try
                   s:=s+trim(UserSession.QFetchFileNameAD.AsString);
                   UserSession.QRetrvieDOCIMJIDBELGE.SaveToStream(st);
                   st.Position:=0;
                   stf:=TFileStream.Create(IWServerController.AppPath+'files\'+s,fmcreate);
                   ZDecompressStream(st,stf);
                   stf.Free;
                   WebApplication.NewWindow(IWServerController.FilesURL+ s);
                finally
                       UserSession.QFetchFileName.Active:=false;
                       st.Free;
                end;
           end;
        finally
          UserSession.QRetrvieDOCIMJID.Active:=false;
        end;
     except
     end;

end;

procedure TIWFBrowseDocs.IWNAVIGATIONChange(Sender: TObject);
begin
     case IWNAVIGATION.ActivePage of
        0:begin
               IWTFolders.Visible:=true;
               IWRegion2.Visible:=false;

          end;
        1:begin
               IWTFolders.Visible:=false;
               IWRegion2.Visible:=true;

          end;
     end;

end;

procedure TIWFBrowseDocs.IWNFirstAsyncClick(Sender: TObject;
  EventParams: TStringList);
var
   newpos:integer;
   i:integer;
   s:string;
begin
    exit;
     s:=TIWLabel(sender).Caption;
     if s='|<'
     then
          Newpos:=1
     else
         if s='>|'
         then
         begin
         UserSession.QDocuments. Next;

         exit;
             newpos:=UserSession.QDocuments.RecordCount div IWDocList.RowLimit;
{             if UserSession.QDocuments.RecordCount mod IWDocList.RowLimit=0
             then
                 dec(newpos);}
         end
         else
         begin
              val(s,newpos,i);
              if (i<>0)
              then
                  exit;
         end;
     newpos:=(newpos)*IWDocList.RowLimit;
     newpos:=newpos-UserSession.QDocuments.RecNo;

     UserSession.QDocuments.MoveBy(Newpos);
{     IWDocList.Refresh;
     IWDocList.Repaint;}
end;

procedure TIWFBrowseDocs.IWRegSearchGroupRender(Sender: TObject);
var
   i:integer;
begin
     IWCGrup.Items.Clear;
     for i := 0 to UserSession.GenGrugs.Count-1 do
         IWCGrup.Items.Add( UserSession.GenGrugs.ValueFromIndex[i]);

end;


procedure TIWFBrowseDocs.IWButton1Click(Sender: TObject);
var
   CurPos,Newpos:integer;
begin
      NewPos:=TIWButton(sender).Tag;
      Curpos:=UserSession.QAraQuery1.RecNo;
      NewPos:=NewPos-Curpos;
      UserSession.QAraQuery1.MoveBy(NewPos);


end;

procedure TIWFBrowseDocs.IWSearchListRenderCell(ACell: TIWGridCell; const ARow,
  AColumn: Integer);
begin
     if arow>0
     then
     begin
         case AColumn of
            0:if acell.Control=nil
              then
              begin
                  ACell.Control:=TIWButton.Create(acell.grid);
                  TIWButton(ACell.Control).RenderSize:=true;
                  if TIWDBGrid(acell.Grid).RowIsCurrent
                  then
                      TIWButton(ACell.Control).Caption:='  '
                  else
                      TIWButton(ACell.Control).Caption:='  ';
                  TIWButton(ACell.Control).Width:=16;
                  TIWButton(ACell.Control).Height:=16;
                  TIWButton(ACell.Control).StyleRenderOptions.RenderSize:=false;
                  TIWButton(ACell.Control).StyleRenderOptions.RenderPosition:=false;
                  TIWButton(ACell.Control).tag:=ARow;
                  TIWButton(ACell.Control).OnClick:=IWButton1Click;


              end

         end;
     end;
end;

procedure TIWFBrowseDocs.IWTFoldersTreeItemClick(Sender: TObject;
  ATreeViewItem: TIWTreeViewItem);
  var
     i:integer;
begin

     UserSession.QDocuments.Active:=false;
     UserSession.QDocuments.sql.Clear;
     UserSession.QDocuments.sql.Text:=
     'SELECT     1 AS tip,D.ID, D.TARIH, D.BELGENO, D.DURUM, D.YON, D.KATEGORI, D.AD, D.SURUM, D.KONU, D.TUR, D.BOYUT, D.SORUMLU, D.BOLUM, D.LOKASYON, D.REHBERID, '+
     'D.ILGILIID, D.PROJEID, D.AKTIVITEID, D.KLASOR, D.GECERLILIK_TARIHI, D.EKLEYEN, D.EKLEMETARIHI, D.DEGISTIREN, D.DEGISTIRMETARIHI, D.ESKIKLASOR, '+
     'D.BAGI, Firma.FIRMA, Lokasyon.ACIKLAMA, Ilgili.ADSOYAD, Sorumlu.FIRMA AS Sorumluadi, ''.'' + REVERSE(SUBSTRING(REVERSE(ISNULL '+
     '((SELECT     TOP (1) BELGEADI '+
     'FROM         IMAJ AS I '+
     'WHERE     (YERI = 1) AND (YER_ID = D.ID) '+
     'ORDER BY ID DESC), ''.'')), 1, CHARINDEX(''.'', REVERSE(ISNULL '+
     '((SELECT     TOP (1) BELGEADI '+
     'FROM         IMAJ AS I '+
     'WHERE     (YERI = 1) AND (YER_ID = D.ID) '+
     'ORDER BY ID DESC), ''.'')), 1) - 1)) AS EXT, D.MODUL, DOKUMANKLASOR.AD AS Klasorad '+
     'FROM         DOKUMAN AS D LEFT OUTER JOIN '+
     'DOKUMANKLASOR ON D.KLASOR = DOKUMANKLASOR.ID LEFT OUTER JOIN '+
     'REHBER AS Firma ON Firma.ID = D.REHBERID LEFT OUTER JOIN '+
     'LOKASYON AS Lokasyon ON Lokasyon.ID = D.LOKASYON LEFT OUTER JOIN '+
     'REHBER AS Sorumlu ON Sorumlu.ID = D.SORUMLU LEFT OUTER JOIN '+
     'REHBERPERSONEL AS Ilgili ON Ilgili.ID = D.ILGILIID '+
     'WHERE     (D.KLASOR = '+inttostr(ATreeViewItem.tag)+')';
     UserSession.QDocuments.Prepared:=true;
     UserSession.QDocuments.Active:=true;

     IWCModul.Items.Clear;
     for i := 0 to UserSession.GenModules.Count-1 do
         IWCModul.Items.Add( UserSession.GenModules.ValueFromIndex[i]);
     IWCBolum.Items.Clear;
     for i := 0 to UserSession.GenBolums.Count-1 do
         IWCBolum.Items.Add( UserSession.GenBolums.ValueFromIndex[i]);


end;

procedure TIWFBrowseDocs.IWTLokasyonTreeItemClick(Sender: TObject;
  ATreeViewItem: TIWTreeViewItem);
var
   i,j:integer;
begin
     Resultstring:=ATreeViewItem.Caption;
     val(trim(ATreeViewItem.Hint),i,j);
     if j=0
     then
         LokasyonIdI:=i
     else
         LokasyonIdI:=-1;

end;

procedure TIWFBrowseDocs.showForm;
var
    temp:array of tfolders;
    i:integer;
    Node1:TIWTreeViewItem;

procedure addNode(id:integer;var Node:TIWTreeViewItem);
var
    i:integer;
    Node1:TIWTreeViewItem;
begin
      for I := 0 to high(temp) do
       if temp[i].ustid=id
       then
       begin
            node1:=IWTFolders.Items.Add(Node);
            Node1.Caption:=temp[i].name;
            Node1.Tag:=temp[i].id;
            addNode(temp[i].id, Node1);
       end;


end;
begin
     setlength(temp,0);
     IWTFolders.Align:=alClient;
//     IWNAVIGATION.Align:=alClient;
     UserSession.QDucKlasur.Active:=false;
     UserSession.QDucKlasur.Active:=true;
     try
        i:=0;
        while  not UserSession.QDucKlasur.eof do
        begin
             setlength(temp,length(temp)+1);
             temp[i].id:=UserSession.QDucKlasurID.AsInteger;
             temp[i].ustid:=UserSession.QDucKlasurUSTID.AsInteger;
             temp[i].name:=UserSession.QDucKlasurAD.AsString;
             UserSession.QDucKlasur.Next;
             inc(i);
        end;
        for i := low(temp) to high(temp) do
        begin
             if temp[i].ustid=0
             then
             begin
                  node1:=IWTFolders.Items.Add(nil);
                  Node1.Caption:=temp[i].name;
                  Node1.tag:=temp[i].id;
                  addNode(temp[i].id, Node1);

             end;
        end;

        show;
     finally
        setlength(temp,0);
        UserSession.QDucKlasur.Active:=false;
     end;

end;
procedure TIWFBrowseDocs.hidebrowser;
begin
       Resultstring:='';
//       IWRegion1.Visible:=false;
       IWDocList.Visible:=false;

end;
procedure TIWFBrowseDocs.showBrowser;
begin
       IWRegSearchGroup.Visible:=false;
       IWRegLokasyon.Visible:=FALSE;

       IWRegion1.Visible:=true;
       IWRegion3.Visible:=TRUE;
       IWDocList.Visible:=true;


end;
procedure TIWFBrowseDocs.RunSearchQuery;
    var
 s1,s2, s, Fir,Yet,Kod,TFirma,TYet,TKod, Grup :string;

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
       s1:=IWCGrup.Items[IWCGrup.ItemIndex];
       s2:=UserSession.DecodeGenGrups(s1);
       if s2<>''
       then
           Grup := ' and GRUP='+s2
       else
       Grup := ' ';
  end
  else
     Grup := '';
  UserSession.qAraQuery1.Active:=FALSE;
  if IWEUnvan.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Fir + ' LIKE ''' + TFirma +''''+ Grup + ' ORDER BY FIRMA'  //   and ' + gorulmeyecekkod
  else if IWEIlgili.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and ' + Yet + ' LIKE ''' + TYet +''''+ Grup +'  ORDER BY FIRMA'             // and gorulmeyecekkod
  else if IWEKod.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Kod + ' LIKE ''' + TKod+'''' + Grup + '  ORDER BY ' + Kod     // and gorulmeyecekkod
  else if IWCGrup.Text <> '' then
    s := ' where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' ORDER BY FIRMA';
{  else
    Exit;}
  UserSession.qAraQuery1.SQL.Text := ' select R.ID,KOD,FIRMA,GRUP,ADSOYAD '+
                        ' from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERID ';
  UserSession.qAraQuery1.SQL.Add(s);
  UserSession.qAraQuery1.Active:=true;;
  DataSource2.DataSet:=UserSession.qAraQuery1;
//  IWEUnvan.Text:=inttostr(UserSession.qAraQuery1.RecordCount);
  IWRegSearchGroup.Refresh;
  IWSearchList.Refresh;
  Refresh;
end;
function TIWFBrowseDocs.ReadLokasyonTree:boolean;

var

   k,i,j,cnt:integer;
   Lokasyonarray:array of TLocasionItem;
function calcLev(s:string):integer;
var
   lev,i:integer;

begin
     lev:=0;
     for i := 1 to length(s) do
       if copy(s,i,1)='.' then inc(lev);
     result:=lev;
end;
begin
     result:=false;
     UserSession.QLocasion.Active:=false;
     UserSession.QLocasion.Active:=true;
     IWTLokasyon.Items .Clear;


     try
        cnt:=UserSession.QLocasion.RecordCount;
        setlength(Lokasyonarray,cnt);
        i:=0;
        while not UserSession.QLocasion.Eof do
        begin
             if length(Lokasyonarray)<=i
             then
                  setlength(Lokasyonarray,i+1);
             Lokasyonarray[i].Id:=UserSession.QLocasionID.AsInteger;
             Lokasyonarray[i].Kod:=UserSession.QLocasionKOD.AsString;
             Lokasyonarray[i].Ackilama:=UserSession.QLocasionACIKLAMA.AsString;
             Lokasyonarray[i].ParLev:=-1;
             Lokasyonarray[i].par:=-1;
             Lokasyonarray[i].Node:=IWTLokasyon.Items.Add;
             Lokasyonarray[i].Node.Caption:=Lokasyonarray[i].Ackilama;
             Lokasyonarray[i].Node.Hint:=Lokasyonarray[i].Kod;
             Lokasyonarray[i].Lev:=calcLev(Lokasyonarray[i].Kod);
             UserSession.QLocasion.Next;
             inc(i);
             result:=true;
        end;
            cnt:=i;
     finally
            UserSession.QLocasion.Active:=false;
     end;
     for i:=0 to cnt-1 do
         for j:=0 to cnt-1 do
         begin
              if i<>j
              then
              begin
                  k:=pos(Lokasyonarray[j].Kod,Lokasyonarray[i].Kod);
                  if k=1
                  then
                      if Lokasyonarray[i].ParLev<Lokasyonarray[j].Lev
                      then
                      begin
                           Lokasyonarray[i].ParLev:=Lokasyonarray[j].Lev;
                           Lokasyonarray[i].par:=j;

                      end;
                  end;
         end;

         for i := 0 to cnt - 1 do
         begin
              Lokasyonarray[i].Node.Caption:=Lokasyonarray[i].Kod+'  ('+Lokasyonarray[i].Ackilama+')';
              Lokasyonarray[i].Node.Hint:=IntToStr(Lokasyonarray[i].Id);;

              if Lokasyonarray[i].par<>-1
              then
              begin
                   j:=Lokasyonarray[i].par;
                   Lokasyonarray[i].Node.ParentItem:=Lokasyonarray[j].Node;
              end;
         end;

//
end;

end.

