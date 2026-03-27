
var
  // fatura sorgularý
  
  baslikXml			: TECXMLParser;
  transactions			: TXMLItem;
  xmlson			: string;
  exportpath			: string;

procedure MakeError(Msg: string;HataId: Integer;Params: string);
begin
  AddError(TahsilatListesi.fieldbyname('DOSYANO').AsString,
    TahsilatListesi.fieldbyname('ADSOYAD').AsString,
    TahsilatListesi.fieldbyname('FATURANO').AsString,
    TahsilatListesi.fieldbyname('GELISNO').AsInteger,
    TahsilatListesi.fieldbyname('SIRANO').AsInteger,
    HataId,Msg,Params);
  SUCCESS := False;
end;  

function CheckInvoice: Boolean;
begin
  Result := True;
  if (Trim(TahsilatListesi.FieldByName('TUR').AsString) = '') then begin
    MakeError('Tahsilat Türü Boþ',2000,'');
    Result := False;
    Exit;
  end;
  if (Trim(TahsilatListesi.FieldByName('MUHKODU').AsString) = '') then begin
    MakeError('Tahsilat Muhasebe Kodu Boþ',2000,'');
    Result := False;
    Exit;
  end;
  if (Trim(TahsilatListesi.FieldByName('HESAPKODU').AsString) = '') then begin
    MakeError('Tahsilat Hesap Kodu Boþ',2000,'');
    Result := False;
    Exit;
  end;
  if (Trim(TahsilatListesi.FieldByName('CARIKOD').AsString) = '') then begin
    MakeError('Tahsilat Türü Boþ',2000,'');
    Result := False;
    Exit;
  end;


 
end;

procedure ReadSettings;
begin
  exportpath:= 'C:\GEN2005\XML';//GenotipIni.ReadString('G2LKS','ExportPath','C:\Gen2005\XML',false); 
end;

procedure XmlDosyaBaslat;
begin  
  with baslikxml.root do
    begin
	  with new do begin 
	    name :='SD_TRANSACTION'; 
		params.add('DBOP=INS');
        with new do begin name:='TYPE'; text:='11';  end;	
        with new do begin name:='SD_CODE'; text:=TahsilatListesi.FieldByName('KASAHESAPKODU').AsString;  end;	
		with new do begin name:='SD_CODE_CROSS'; text:='' end;
		with new do begin name:='SD_NUMBER_CROSS'; text:='' end;		
//        with new do begin name:='CROSS_DATA_REFERENCE'; text:='1';  end;	 		
		with new do begin name:='DATE'; text:=formatdatetime('dd.mm.yyyy',TahsilatListesi.Fieldbyname('TARIH').AsDateTime);  end;		
		with new do begin name:='HOUR'; text:=formatdatetime('hh',TahsilatListesi.Fieldbyname('TARIH').AsDateTime);  end;		
		with new do begin name:='MINUTE'; text:=formatdatetime('nn',TahsilatListesi.Fieldbyname('TARIH').AsDateTime);  end;		
                with new do begin name:='NUMBER'; text:=TahsilatListesi.FieldByName('TAHSILATNO').AsString;  end;	 			 		
//		with new do begin name:='DIVISION'; text:='1'; end;
		//with new do begin name:='AUXIL_CODE'; text:='01';  end;				
		With new do begin name:='MASTER_TITLE'; text:=TahsilatListesi.FieldByName('LKSACIKLAMA').AsString; end;
		With new do begin name:='DESCRIPTION'; text:=TahsilatListesi.FieldByName('LKSACIKLAMA').AsString; end;		
		With new do begin name:='AMOUNT'; text:=TahsilatListesi.FieldByName('TUTAR').AsString; end;		
		With new do begin name:='TC_XRATE'; text:='1'; end;			
		With new do begin name:='TC_AMOUNT'; text:=TahsilatListesi.FieldByName('TUTAR').AsString; end;				
		With new do begin name:='DATA_REFERENCE'; text:='1'; end;
		with new do begin
		  name:='ATTACHMENT_ARP';
		   with new do begin 
		     name:='TRANSACTION';
			  with new do begin name:='ARP_CODE'; text:= TahsilatListesi.FieldByname('KURUMCARIKODU').ASstring; end;
			  with new do begin name:='GL_CODE1'; text:= TahsilatListesi.FieldByname('KURUMMUHASEBEKODU').ASstring; end;			  
			  with new do begin name:='GL_CODE2'; text:= TahsilatListesi.FieldByname('KASAMUHASEBEKODU').ASstring; end;	
		      with new do begin name:='TRANNO'; text:='1'; end;					  			  
//			  with new do begin name:='AUXIL_CODE'; text:= '01' end;			  
			  with new do begin name:='DESCRIPTION'; text:=TahsilatListesi.FieldByName('LKSACIKLAMA').AsString; end;
		      with new do begin name:='CREDIT'; text:=TahsilatListesi.FieldByName('TUTAR').AsString; end;					  
		      with new do begin name:='TC_XRATE'; text:='1'; end;					  
		      with new do begin name:='TC_AMOUNT'; text:=TahsilatListesi.FieldByName('TUTAR').AsString; end;					  
              with new do begin
			     name:='PAYMENT_LIST';
				  with new do begin
				    name:='PAYMENT';
					 with new do begin name:='DATE'; text:=formatdatetime('dd.mm.yyyy',TahsilatListesi.Fieldbyname('TARIH').AsDateTime); end;
					 with new do begin name:='MODULENR'; text:='10'; end;
					 with new do begin name:='SIGN' text:='1'; end;
					 with new do begin name:='TRCODE' text:='1'; end;					
					 with new do begin name:='TOTAL'; text:=TahsilatListesi.FieldByName('TUTAR').AsString; end;		
					 with new do begin name:='PROCDATE'; text:=formatdatetime('dd.mm.yyyy',TahsilatListesi.FieldByName('TARIH').AsDateTime); end;					 
					 with new do begin name:='TRRATE' text:='1'; end;										 
					 with new do begin name:='DATA_REFERENCE' text:='0'; end;		
 					 with new do begin name:='DISCOUNT_DUEDATE'; text:=formatdatetime('dd.mm.yyyy',TahsilatListesi.FieldByName('TARIH').AsDateTime); end;
					 with new do begin name:='PAY_NO' text:='1'; end;	
					 with new do begin name:='DISCTRDELLIST' text:='0'; end;				 
				  end;				  
              end;		
              with new do begin name:='PROJECT_CODE'; text:=TahsilatListesi.FieldByname('LKSPROJEKODU').AsString; end;	
              with new do begin name:='MONTH'; text:=inttostr(MonthOf(TahsilatListesi.FieldByname('TARIH').AsDateTime)); end;			  
              with new do begin name:='YEAR'; text:=inttostr(YearOf(TahsilatListesi.FieldByName('TARIH').ASDatetime)); end;			  
              with new do begin name:='AFFECT_RISK'; text:='0'; end;				  
		   end;
		end;
		
        with new do begin name:='PROJECT_CODE'; text:=TahsilatListesi.FieldByname('LKSPROJEKODU').AsString; end;		
	  end;
	   
	end;
  
end;
  
procedure OnInitialize;
begin
  ReadSettings;   
  baslikXml := TECXMLParser.Create(nil); 
  baslikxml.Root.name := 'SD_TRANSACTIONS';

//  XmlDosyaBaslat;
  DeleteFileS(exportPath,FormatDateTime('YYYYMMDD_HHNNSS',now)+'.xml');

  
end;

// Faturalarýn dönüþümü bittiði zaman çaðrýlýr.
procedure OnFinalize;
begin
 baslikxml.savetofile(exportPath+'\'+ FormatDateTime('YYYYMMDD_HHNNSS',now)+'.xml');
 baslikxml.free;
 	
end;




begin
  // her fatura dönüþümü istediðinde scriptengine burayý çaðýrýr.
  // öyleyse InvoiceTransactions þu an için doðru yerde.
  //secilifistarih := formatdatetime('dd.mm.yyyy',FaturaListesi.Fieldbyname('FATURATARIH').AsDateTime )
  XmlDosyaBaslat;
	


  //ShowModal;
end.