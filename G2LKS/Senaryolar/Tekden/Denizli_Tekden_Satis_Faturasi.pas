                        var
  // fatura sorgularý
  faturaBaslik          : TADOQuery;
  faturaHizmet          : TADOQuery;

  
  baslikXml			: TECXMLParser;
  transactions,dispatches	: TXMLItem;
  xmlson			: string;
  exportpath			: string;


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
 
  if (faturaHizmet.FieldByName('MUHKODU').AsString = '') then begin
    MakeError(faturaHizmet.FieldByName('KOD').AsString+'-Ürün Muhasebe Kodu bilgisi boþ!',2000,'');
    Result := False;
    Exit;
  end;
  
  if (faturaHizmet.FieldByName('KURUMKODU').AsString = '') then begin
    MakeError('Firma Muhasebe Kodu bilgisi boþ!',2000,'');
    Result := False;
    Exit;
  end;
  
  
  
 
end;

procedure ReadSettings;
begin
  exportpath:= 'C:\GEN2005\G2LKS\XML'; //GenotipIni.ReadString('G2LKS','ExportPath','C:\Gen2005\XML',false); 
end;

procedure XmlDosyaBaslat;
begin  
  with baslikxml.root do
    begin
	  with new do begin 
	    name :='INVOICE'; 
		params.add('DBOP="INS"');
        with new do begin name:='TYPE'; text:='8';  end;	
		with new do begin name:='DATE'; text:=formatdatetime('dd.mm.yyyy',FaturaListesi.FieldByName('FATURATARIH').AsDatetime);  end;		
        with new do begin name:='NUMBER'; text:=FaturaListesi.FieldByName('FATURANO').AsString;  end;		
		with new do begin name:='AUXIL_CODE'; text:='G'; end;
		with new do begin name:='ARP_CODE'; text:= FaturaListesi.FieldByName('MUHASEBEKODU').AsString;  end;		
		with new do begin name:='GL_CODE';  text:= FaturaListesi.FieldByName('MUHASEBEKODU').AsString;  end;		
		with new do begin name:='POST_FLAGS'; text:='247';  end;	
		with new do begin name:='VAT_RATE'; text:='8';  end;
		with new do begin name:='TOTAL_DISCOUNTS'; text:=floattostr(FaturaListesi.FieldByName('KDV_TUTARI').AsFloat ) ; ;  end;	
		with new do begin name:='TOTAL_DISCOUNTED'; text:=floattostr(FaturaListesi.FieldByName('FATURA_TUTARI').AsFloat -FaturaListesi.FieldByName('KDV_TUTARI').AsFloat) ; ;  end;	
		with new do begin name:='TOTAL_VAT'; text:=FaturaListesi.FieldByName('KDV_TUTARI').AsString;  end;	
		with new do begin name:='TOTAL_GROSS'; text:=floattostr(FaturaListesi.FieldByName('FATURA_TUTARI').AsFloat -FaturaListesi.FieldByName('KDV_TUTARI').AsFloat) ;  end;	
		with new do begin name:='TOTAL_NET'; text:=FaturaListesi.FieldByName('FATURA_TUTARI').AsString;  end;			
		with new do begin name:='TC_NET'; text:=FaturaListesi.FieldByName('FATURA_TUTARI').AsString;  end;			
		with new do begin name:='NOTES1'; text:=FaturaListesi.FieldByName('REFERANS').AsString;  ;  end;			
		with new do begin name:='NOTES2'; text:=FaturaListesi.FieldByName('ADSOYAD').AsString;  ;  end;			
		with new do begin name:='NOTES3'; text:=FaturaListesi.FieldByName('NOTLAR').AsString;  ;  end;	
		with new do begin name:='RC_XRATE'; text:='1';  end;					
		with new do begin name:='RC_NET'; text:=FaturaListesi.FieldByName('FATURA_TUTARI').AsString;  end;					
	
		
		dispatches:= new;
		 with dispatches do begin name:= 'DISPATCHES' 
			 with new do begin name:= 'DISPATCH' 		 
					with new do begin name:='TYPE'; text:='8';  end;	
					with new do begin name:='DATE'; text:=formatdatetime('dd.mm.yyyy',FaturaListesi.FieldByName('FATURATARIH').AsDatetime);  end;		
					with new do begin name:='NUMBER'; text:=FaturaListesi.FieldByName('FATURANO').AsString;  end;		
					with new do begin name:='AUXIL_CODE'; text:='G'; end;
					with new do begin name:='ARP_CODE'; text:= FaturaListesi.FieldByName('MUHASEBEKODU').AsString;  end;		
					with new do begin name:='GL_CODE';  text:= FaturaListesi.FieldByName('MUHASEBEKODU').AsString;  end;		
					with new do begin name:='INVOICED';  text:= '1';  end;					
					with new do begin name:='TOTAL_DISCOUNTS'; text:=floattostr(FaturaListesi.FieldByName('KDV_TUTARI').AsFloat ) ; ;  end;	
					with new do begin name:='TOTAL_DISCOUNTED'; text:=floattostr(FaturaListesi.FieldByName('FATURA_TUTARI').AsFloat -FaturaListesi.FieldByName('KDV_TUTARI').AsFloat) ; ;  end;	
					with new do begin name:='TOTAL_VAT'; text:=FaturaListesi.FieldByName('KDV_TUTARI').AsString;  end;	
					with new do begin name:='TOTAL_GROSS'; text:=floattostr(FaturaListesi.FieldByName('FATURA_TUTARI').AsFloat -FaturaListesi.FieldByName('KDV_TUTARI').AsFloat) ;  end;	
					with new do begin name:='TOTAL_NET'; text:=FaturaListesi.FieldByName('FATURA_TUTARI').AsString;  end;			
					with new do begin name:='RC_RATE'; text:='1';  end;					
					with new do begin name:='RC_NET'; text:=FaturaListesi.FieldByName('FATURA_TUTARI').AsString;  end;								
			end;				        
		 end;
		 
		
		transactions:=new;
		with transactions do begin name:='TRANSACTIONS';  end;		
	  end;
	   
	end;

end;
  
procedure OnInitialize;
begin
  ReadSettings;  
  baslikXml := TECXMLParser.Create(nil); 
  baslikxml.Root.name := 'SALES_INVOICES'; 
  //XmlDosyaBaslat;
  DeleteFileS(exportPath,'Satis_'+FormatDateTime('YYYYMMDD',now)+'.xml'); 
end;

// Faturalarýn dönüþümü bittiði zaman çaðrýlýr.
procedure OnFinalize;
begin
 baslikxml.savetofile(exportPath+'\'+'Satis_'+ FormatDateTime('YYYYMMDDHHNN',now)+'.xml');
 baslikxml.free;
 	
end;
function openTables:boolean;
Var
  hizmettoplam   : double;
begin
   hizmettoplam:=0;
   
// fatura ile ilgili tüm satýrlarý kontrol ettirip herhangi bir hatasý varsa fiþe bu fatura aktarýlmasýn.
  result:=True;
  faturaHizmet := query_exec(SystemConnection,'p_G2LKS_FaturaHizmetBilgisi %dosyano%,%gelisno%,%kartno%,%KIME%',
    ['%dosyano%','%gelisno%','%kartno%','%KIME%'], [Dosyano,GelisNo,KartNo,Kime],nil);
  faturaHizmet.open;	
  faturaHizmet.First;
  
 	  while not faturahizmet.eof do begin
		 if not CheckInvoice then 
		   begin 
		     Result:=False; 
			exit; 
		  end;
	   faturahizmet.next;
	  end; 

	  // eðer ödeme toplamý ile 
	  faturahizmet.first;
end; 
  
    
procedure InvoiceTransactions;
begin
  if exportPath = '' then begin
    MakeError('Aktarým yolu tanýmlanmamýþ!',2500,'');
    Exit;
  end;  


 if not OpenTables then 
   exit;

  XmlDosyaBaslat;
   
   
  while not faturahizmet.eof do begin
   if CheckInvoice then 
		begin
			  with transactions.new do begin
			   name:='TRANSACTION';
                with new do begin name:='TYPE'; text:='0';  end;		
               	with new do begin name:='MASTER_CODE'; text:=faturaHizmet.fieldbyname('KOD').Asstring;  end;
				with new do begin name:='GL_CODE1'; text:=faturaHizmet.fieldbyname('MUHKODU').Asstring;  end;
				with new do begin name:='GL_CODE2'; text:=faturaHizmet.fieldbyname('KDVMUHKODU').Asstring;  end;				
				with new do begin name:='QUANTITY'; text:='1';  end;				
				with new do begin name:='PRICE';    text:=faturaHizmet.fieldbyname('TUTAR').Asstring;   end;	
				with new do begin name:='TOTAL';    text:=faturaHizmet.fieldbyname('TUTAR').Asstring;  end;
				with new do begin name:='RC_XRATE'; text:='1';  end;
				with new do begin name:='UNIT_CODE'; text:='ADET';  end;	
				with new do begin name:='UNIT_CONV1'; text:='1';  end;
				with new do begin name:='UNIT_CONV2'; text:='1';  end;				
				with new do begin name:='VAT_RATE'; text:= faturaHizmet.FieldByName('KDV').Asstring;  end;				
				with new do begin name:='VAT_AMOUNT'; text:= faturaHizmet.FieldByName('KDVTUTAR').Asstring;  end;					
				with new do begin name:='VAT_BASE'; text:= floattostr(faturaHizmet.FieldByName('KDVLITUTAR').AsFloat-faturaHizmet.FieldByName('KDVTUTAR').AsFloat);  end;					
				with new do begin name:='BILLED'; text:='1';  end;								
				with new do begin name:='TOTAL_NET'; text:=floattostr(faturaHizmet.FieldByName('KDVLITUTAR').AsFloat-faturaHizmet.FieldByName('KDVTUTAR').AsFloat);  end;					
				with new do begin name:='EDT_CURR'; text:='160';  end;								
				with new do begin name:='EDT_PRICE'; text:= floattostr(faturaHizmet.FieldByName('KDVLITUTAR').AsFloat-faturaHizmet.FieldByName('KDVTUTAR').AsFloat);  end;									
			  end;
			 with transactions.new do begin
			  name:= 'TRANSACTION';
				   with new do begin name:='TYPE'; text:='2'; end;
				   with new do begin name:='QUANTITY'; text:='0'; end;
				   with new do begin name:='TOTAL'; text:=faturaHizmet.fieldbyname('TUTAR').Asstring; end;
				   with new do begin name:='RC_XRATE'; text:='1'; end;
				   with new do begin name:='UNIT_CONV1'; text:='0'; end;
				   with new do begin name:='UNIT_CONV2'; text:='0'; end;
				   with new do begin name:='BILLED'; text:='1'; end;
			   end;
			   
			  
		end;  		 
	FaturaHizmet.Next;
	end;
	

  faturaHizmet.free;

end;

begin
  // her fatura dönüþümü istediðinde scriptengine burayý çaðýrýr.
  // öyleyse InvoiceTransactions þu an için doðru yerde.

   InvoiceTransactions;
  //ShowModal;
end.