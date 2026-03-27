var
  // fatura sorgularý
  faturaBaslik          : TADOQuery;
  faturaHizmet           : TADOQuery;
  faturaKDV           : TADOQuery;
  faturaOdeme           : TADOQuery;
  
  
  baslikXml			: TECXMLParser;
  transactions			: TXMLItem;
  xmlson			: string;
  exportpath			: string;
  sayac                 : Integer;

procedure MakeError(Msg: string;HataId: Integer;Params: string);
begin
  AddError(FaturaListesi.fieldbyname('DOSYANO').AsString,
    FaturaListesi.fieldbyname('ADSOYAD').AsString,
    FaturaListesi.fieldbyname('FATURANO').AsString,
    FaturaListesi.fieldbyname('GELISNO').AsInteger,
    FaturaListesi.fieldbyname('KARTNO').AsInteger,
    HataId,Msg,Params);
  SUCCESS := False;
end;  

function CheckInvoice: Boolean;
begin
  Result := True;
  if (Trim(faturaHizmet.FieldByName('FATURANO').AsString) = '') then begin
    MakeError('Fatura Numarasý Boþ',2000,'');
    Result := False;
    Exit;
  end;
  if faturaKDV.Active then begin 
  if (faturaKDV.FieldByName('MUHKODU').AsString = '') then begin
    MakeError('KDV Muhasebe Kodu tanýmsýz ',2000,'');
    Result := False;
    Exit;
  end;
  end;
  if faturaOdeme.Active then begin
  if (faturaOdeme.FieldByName('MUHKODU').AsString = '') then begin  
    MakeError('Fatura için kasa veya kurum kodu bulunamadý!',2000,'');
    Result := False;
    Exit;
  end;
  end;
  if (faturaHizmet.FieldByName('KURUM').AsString = '') then begin
    MakeError('Kurum bilgisi boþ!',2000,'');
    Result := False;
    Exit;
  end;
 
end;

procedure ReadSettings;
begin
  exportpath:= GenotipIni.ReadString('G2LKS','ExportPath','C:\Gen2005\XML',false); 
end;

procedure XmlDosyaBaslat;
begin  
  with baslikxml.root do
    begin
	  with new do begin 
	    name :='GL_VOUCHER'; 
		params.add('DBOP="INS"');
        with new do begin name:='TYPE'; text:='4';  end;		
		with new do begin name:='DATE'; text:=FormatDateTime('DD.MM.YYYY',now);  end;		
		with new do begin name:='AUXIL_CODE'; text:='F';  end;		
		with new do begin name:='NOTES1'; text:='SATISLARIMIZ GEREGI';  end;		
		with new do begin name:='CURRSEL_TOTALS'; text:='4';  end;		
		transactions:=new;
		with transactions do begin name:='TRANSACTIONS';  end;		
	  end;
	   
	end;
  
end;
  
procedure OnInitialize;
begin
  ReadSettings;  
  baslikXml := TECXMLParser.Create(nil); 
  baslikxml.Root.name := 'GL_VOUCHERS';
  sayac := 0;
  XmlDosyaBaslat;
  DeleteFileS(exportPath,FormatDateTime('YYYYMMDD',now)+'.xml');
end;

// Faturalarýn dönüþümü bittiði zaman çaðrýlýr.
procedure OnFinalize;
begin
 baslikxml.savetofile(exportPath+'\'+ FormatDateTime('YYYYMMDD',now)+'.xml');
 baslikxml.free;
 	
end;

procedure InvoiceTransactions;
begin
  if exportPath = '' then begin
    MakeError('Aktarým yolu tanýmlanmamýþ!',2500,'');
    Exit;
  end;  


  faturaHizmet := query_exec(SystemConnection,'p_G2LKS_FaturaHizmetBilgisi %dosyano%,%gelisno%,%kartno%,%KIME%',
    ['%dosyano%','%gelisno%','%kartno%','%KIME%'], [Dosyano,GelisNo,KartNo,Kime]);
  faturaKDV    := query_exec(SystemConnection,'p_G2LKS_FaturaKDVBilgisi %dosyano%,%gelisno%,%kartno%',
    ['%dosyano%','%gelisno%','%kartno%'], [Dosyano,GelisNo,KartNo]);
  faturaOdeme  :=query_exec(SystemConnection,'p_G2LKS_FaturaOdemeBilgisi %dosyano%,%gelisno%,%kartno%,%KIME%',
    ['%dosyano%','%gelisno%','%kartno%','%KIME%'], [Dosyano,GelisNo,KartNo,Kime]);

  faturaHizmet.open;	
  faturaHizmet.First;
  while not faturahizmet.eof do begin
   if CheckInvoice then 
		begin
			  with transactions.new do begin
			   name:='TRANSACTION';
				with new do begin name:='GL_CODE'; text:=faturaHizmet.fieldbyname('MUHKODU').Asstring;  end;	
				with new do begin name:='PARENT_GLCODE'; text:=copy(faturaHizmet.fieldbyname('MUHKODU').Asstring,1,3);  end;
				with new do begin name:='DEBIT'; text:=faturaHizmet.fieldbyname('TUTAR').Asstring;  end;
				with new do begin name:='DESCRIPTION'; text:='FT/'+faturaHizmet.fieldbyname('FATURANO').Asstring+' '+faturaHizmet.fieldbyname('ADSOYAD').Asstring;  end;
			  
				with new do begin name:='RC_XRATE'; text:='1';  end;	
				with new do begin name:='RC_AMOUNT'; text:=faturaHizmet.fieldbyname('TUTAR').Asstring;  end;
				with new do begin name:='TC_XRATE'; text:='1';  end;
				with new do begin name:='TC_AMOUNT'; text:=faturaHizmet.fieldbyname('TUTAR').Asstring;  end;	
				with new do begin name:='QUANTITY'; text:='0';  end;
			  end;
		end;  		 
	FaturaHizmet.Next;
	end;
  
  faturaKDV.open;
  faturaKDV.First;
  while not faturaKDV.eof do begin
    if CheckInvoice then 
	 begin
		  with transactions.new do begin
		   name:='TRANSACTION';
			with new do begin name:='GL_CODE'; text:=faturaKDV.fieldbyname('MUHKODU').Asstring;  end;	
			with new do begin name:='PARENT_GLCODE'; text:=copy(faturaKDV.fieldbyname('MUHKODU').Asstring,1,3);  end;
			with new do begin name:='DEBIT'; text:=faturaKDV.fieldbyname('TUTAR').Asstring;  end;
			with new do begin name:='DESCRIPTION'; text:='FT/'+faturaKDV.fieldbyname('FATURANO').Asstring+' '+faturaKDV.fieldbyname('ADSOYAD').Asstring;  end;
			with new do begin name:='RC_XRATE'; text:='1';  end;	
			with new do begin name:='RC_AMOUNT'; text:=faturaKDV.fieldbyname('TUTAR').Asstring;  end;
			with new do begin name:='TC_XRATE'; text:='1';  end;
			with new do begin name:='TC_AMOUNT'; text:=faturaKDV.fieldbyname('TUTAR').Asstring;  end;	
			with new do begin name:='QUANTITY'; text:='0';  end;
		  end;
	 end; 
	FaturaKDV.Next;
  end;
 
  faturaOdeme.open;
  faturaOdeme.First;
  while not faturaOdeme.eof do begin
     if CheckInvoice then
	 begin
		  with transactions.new do begin
		   name:='TRANSACTION';
			with new do begin name:='GL_CODE'; text:=faturaOdeme.fieldbyname('MUHKODU').Asstring;  end;	
			with new do begin name:='PARENT_GLCODE'; text:= copy(faturaOdeme.fieldbyname('MUHKODU').Asstring,1,3);  end;
			with new do begin name:='DEBIT'; text:=faturaOdeme.fieldbyname('TUTAR').Asstring;  end;
			with new do begin name:='DESCRIPTION'; text:='FT/'+faturaOdeme.fieldbyname('FATURANO').Asstring+' '+faturaOdeme.fieldbyname('ADSOYAD').Asstring;  end;
		  	with new do begin name:='RC_XRATE'; text:='1';  end;	
			with new do begin name:='RC_AMOUNT'; text:=faturaOdeme.fieldbyname('TUTAR').Asstring;  end;
			with new do begin name:='TC_XRATE'; text:='1';  end;
			with new do begin name:='TC_AMOUNT'; text:=faturaOdeme.fieldbyname('TUTAR').Asstring;  end;	
			with new do begin name:='QUANTITY'; text:='0';  end;
		  end;
	 end;  
  FaturaOdeme.Next;
  end;
 
  faturaHizmet.free;
  faturaOdeme.free;
  faturaKDV.free;

end;

begin
  // her fatura dönüþümü istediðinde scriptengine burayý çaðýrýr.
  // öyleyse InvoiceTransactions þu an için doðru yerde.
  InvoiceTransactions;
  sayac := sayac + 1;
  if (sayac >= 10) then
  begin    
	XmlDosyaBaslat;
	sayac := 0;	
  end;
  //ShowModal;
end.