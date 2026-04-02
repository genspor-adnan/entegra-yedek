unit XmldenTabloya;

interface

uses
  xmldom, XMLIntf, msxmldom, XMLDoc, HKMTab, DB, Classes, JclStrings, SysUtils,InvokeRegistry,Dialogs;

function XmlDenMemTabloya(AXML: string; ATablo: THKMemTab; ASemaYolu: string; ASemaTipi: Integer = 0) : string;
function RiodanMemTabloya( ATablo: THKMemTab; GelenClass:TRemotable) : string;

implementation

function GetDelimitedString(var s: string; delimiter: string): string; overload;
begin
  if (Pos(delimiter, s) > 0) then
  begin
    Result := Copy(s, 1, Pos(delimiter, s) - 1);
    Delete(s, 1, Pos(delimiter, s));
  end
  else
  begin
    Result := s;
    s := '';
  end;
end;

function GetNode(APath: string; ARootNode: IDOMNode): IDOMNode;

  function NodeBul(ANodeAdi: string; AKok: IDOMNode): IDOMNode;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to AKok.childNodes.length - 1 do
      if AKok.childNodes[i].nodeName = ANodeAdi then
      begin
        Result := AKok.childNodes[i];
        Exit;
      end;
  end;

var
  ANode: string;
begin
  Result := nil;
  if not Assigned(ARootNode) then
    Exit;
  ANode := GetDelimitedString(APath, '/');
  if (APath <> '') then
    Result := GetNode(APath, NodeBul(ANode, ARootNode))
  else
    Result := NodeBul(ANode, ARootNode);
end;

function XmlDenMemTabloya(AXML: string; ATablo: THKMemTab; ASemaYolu: string; ASemaTipi: Integer = 0) : string;

  function SemaTipiFieldType(s: string): TFieldType;
  begin
    Result := ftString;
    if s = 'xs:long' then
      Result := ftInteger;
  end;

var
  node: IDOMNode;
  elementAdi: string;
  node2: IDOMNode;
  i: Integer;
  j: Integer;
  tip: TFieldType;
  XmlDoc: TXMLDocument;
  gerekli: Boolean;
begin
  Result := '';
  XmlDoc := TXMLDocument.Create(nil);
  try
    XmlDoc.XML.Text := AXML;
    StringToFile(GetEnvironmentVariable('Temp') + '\' +'Gelenxml.txt', AXML);
    XmlDoc.Active := True;

    node := GetNode('s:Envelope/s:Body/' + ASemaYolu +
     '/xs:schema/xs:element/xs:complexType/xs:choice', XmlDoc.DOMDocument);

//    node := GetNode('<guncellemeResult><xs:schema id="NewDataSet" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">', XmlDoc.DOMDocument);

    if (node.childNodes.length > 0) then
    begin
      elementAdi := node.childNodes[ASemaTipi].attributes[0].nodeValue;
      node := GetNode('xs:complexType/xs:sequence', node.childNodes[ASemaTipi]);
      ATablo.Active := False;
      ATablo.FieldDefs.Clear;
      for i := 0 to node.childNodes.length - 1 do
      begin

        if node.childNodes[i].attributes.getNamedItem('minOccurs') <> nil then
          gerekli := StrToIntDEf(node.childNodes[i].attributes.getNamedItem('minOccurs').nodeValue, 0) > 0
        else
          gerekli := true;
        tip := SemaTipiFieldType(node.childNodes[i].attributes[1].nodeValue);

        if tip = ftString then
          ATablo.FieldDefs.Add(node.childNodes[i].attributes[0].nodeValue, tip, 8000, gerekli)
        else
          ATablo.FieldDefs.Add(node.childNodes[i].attributes[0].nodeValue, tip, 0, gerekli);

      end;

      ATablo.CreateTable;
      ATablo.Active := True;
      node := GetNode('s:Envelope/s:Body/' + ASemaYolu +
        '/diffgr:diffgram', XmlDoc.DOMDocument);
      // diffgram içindeki ilk elementi alýyoruz
      // çünkü mainDataTable = true ise DocumentElement diðer durumda baþka
      // biþey oluyor bunu önlemek için ilk elementi alýyoruz.
      node := node.childNodes[0];
      //Atablo.DisableControls;

      //node nil deðer alýyor bilinmiyor kontrol et
      if node <> nil then
      begin

        if node.childNodes.length > 0 then
          for i := 0 to node.childNodes.length - 1 do
          begin
            node2 := node.childNodes[i];
            if node2.nodeName = elementAdi then
            begin
              ATablo.Append;
              for j := 0 to node2.childNodes.length - 1 do
              begin
                if node2.childNodes[j].childNodes.length > 0 then
                  ATablo.FieldByName(node2.childNodes[j].nodeName).AsString := node2.childNodes[j].childNodes[0].nodeValue;
              end;
              ATablo.Post;
            end;
          end;
      end;
    end else begin
      node2 := node.parentNode.parentNode.parentNode.parentNode.parentNode;
      if (node2.childNodes.length > 1) then begin
        Result := node2.childNodes.item[1].childNodes[0].nodeValue;
      end;
    end;
    //Atablo.EnableControls;

  finally
    XmlDoc.Free;
  end;

end;

function RiodanMemTabloya( ATablo: THKMemTab; GelenClass:TRemotable) : string;

  function SemaTipiFieldType(s: string): TFieldType;
  begin
    Result := ftString;
    if s = 'xs:long' then
      Result := ftInteger;
  end;

var
  node: IDOMNode;
  elementAdi: string;
  node2: IDOMNode;
  i: Integer;
  j: Integer;
  tip: TFieldType;
  XmlDoc: TXMLDocument;
  gerekli: Boolean;
begin


 



 ShowMessage(TInvokableClass(GelenClass).ClassType.ClassName);
 ShowMessage(GelenClass.DataContext.ClassType.ClassName);
 ShowMessage(GelenClass.DataContext.ClassName);
 ShowMessage(inttostr(GelenClass.InstanceSize));



end;





end.

