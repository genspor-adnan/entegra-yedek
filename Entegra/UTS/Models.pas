unit Models;

interface

uses
    System.Classes,
    ModelApi;

type
    TM_AlmaSorgu = Class(TModel)
    public
        GKK : string;
        ADT : integer;
        OFF : string;
    end;

{    TM_AlmaSorgu = Class(TModel)
    public
        GKK : string;
        SAN : integer;
    end;  }


    TM_Alma = Class(TModel)
    public
        BID : String; //veri BID olarak gelir, aktarým olduktan sonra BID -> VBI olrak deðiþtirilir ve öyle Alma bildirimine gönderilir.
        ADT : integer;
    end;

    TM_HEK= Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        TUR : String;
        DTA : String;
    end;

    TM_Envanter = Class(TModel)
    public
        UIK : String;
        UNO : String;
        LNO : String;
        SNO : String;
        ENT : String;
        SKT : String;
        SBT : String;
    end;

    TM_Kullanim = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        TUA : String;
        TUS : String;
        TKN : String;
        YKN : String;
        PAN : String;
        GIT : String; //TDateTime;
       // KTN : String;
        TUR : String;
        DTA : String;
    end;

    TM_Kullanim_Iade = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        TKN : String;
    end;

    TM_Stok= Class(TModel)
    public
        UIK : String;
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        URT : String;
        SKT : String;
    end;

    TM_Uretim= Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        URT : String;
        SKT : String;
        ADT : integer;
        UDI : String;
        SIP : String;
        KUS : String;
        GTK : String;
    end;

   { TM_Ithal_LNo= Class(TModel)
    public
        UNO : String;
        LNO : String;
        ADT : integer;
        UDI : String;
        URT : String;
        SKT : String;
        IEU : String;
        MEU : String;
        GBN : String;
    end;  }

    TM_Ithal_SNo= Class(TModel)
    public
        UNO : String;
        SNO : String;
        LNO : String;
        ADT : integer;
        URT : String;
        SKT : String;
        IEU : String;
        MEU : String;
    end;


    TM_Verme = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        KUN : String;
        BEN : String;
        BNO : String;
        GIT : String;
    end;

    TM_Iptal = Class(TModel)
    public
        BID : String;
    end;

    TM_Urun = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
    end;

    TM_Urun_Sayfa = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        SAY : integer;
    end;


    TM_Urun_List = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        SAN : String;
    end;

    TM_Urun_Off = Class(TModel)
    public
        UNO : String;
        LNO : String;
        SNO : String;
        ADT : integer;
        OFF : String;
    end;

    //TM_MP = Class(TModel)
    //public
    //    BID : String;
    //end;


    TMesaj = class(TModel)
    public
        TIP :   String;
        MET :   String;
        KOD :   String;
        MPA :   Array of String;
//        MPA :   Array of TModel;
    end;

   TUrunSorgulaSonucItem = class(TModel)
    public
        [LMax(20)]  UTP :   String; //    TIBBI_CIHAZ / KOZMETIK_URUN
        [LMax(23)]  UNO :   String; // Ürün No.
        [LMax(20)]  LNO :   String; // Lot/Batch No.
        [LMax(20)]  SNO :   String; // Seri/Sýra No.
                    ADT :   Integer;// Adet
        [LMax(23)]  URT :   String; // ÜRT
        [LMax(23)]  SKT :   String; // SKT
        [LMax(23)]  ITT :   String; // Ýth trh
		    [LMax(23)]  UIK :   String; // Tekil ürünü üreten/ithal eden kurumun numarasýdýr.
		    [LMax(16)]	UAK :   String; // Tekil / Lot
		    [LMax(16)]	SKG :   String; // Satarken Kimlik Numarasý Gerekli Mi? True / False
		    [LMax(16)]	KKG :   String; // Kullanýrken Kimlik Numarasý Gerekli Mi? True / False
		    [LMax(64)]	UDI :   String; // Eþsiz kimlik
		    [LMax(128)]	MME :   String; // Marka Model Etiket adý
	 end;
	 TUrunSonuc = class(TModel)
    public
	    	SNC :   Array of  TUrunSorgulaSonucItem;
        MSJ :   Array of  TMesaj;
   end;

   TAyrintiUrunSorgulaSonucItem = class(TModel)
    public
        [LMax(20)] sahibi  :   String; //    Sahibi / KOZMETIK_URUN
        [LMax(23)] urunNumarasi  :   String; // Ürün No.
        [LMax(20)] seriNumarasi  :   String; // Seri/Sýra No.
        [LMax(20)] lotBatchNumarasi  :   String; // Lot/Batch No.
                   adet  :   Integer;// Adet
        [LMax(23)] kullanilabilirAdet  :   Integer;
        [LMax(23)] Stok_Arti_AcikIrsaliye  :   Integer;

        [LMax(23)] olusturulmaTarihiString  :   String;
        [LMax(23)] uretimTarihiString  :   String;
        [LMax(23)] sonKullanmaTarihiString  :   String;

        [LMax(64)] essizKimlik	 :   String; // Eþsiz kimlik

       // [LMax(23)] olusturulmaTarihi  :   String; // Oluþturma tarihi
        [LMax(100)]	sahibiUnvan :   String; // Sahibi Ünvan

      //  [LMax(23)] sonKullanmaTarihi  :   String; // SKT
        [LMax(23)] ureticiIthalatciKurumNo  :   String; // Tekil ürünü üreten/ithal eden kurumun numarasýdýr.  //  ureticiIthalatciKurumNo
      //  [LMax(23)] uretimTarihi  :   String; // ÜRT
        [LMax(100)] urunTanimi :   String; // Ürün Tanýmý

      //  [LMax(23)] urunBilgileri  :   String; // ÜRT     "sonKullanmaTarihiString": null,
      //  [LMax(23)] essizKimlikForExcel  :   String; // ÜRT     "olusturulmaTarihiString": "2020-01-10",
      //  [LMax(23)] ureticiIthalatciKurumNoForExcel  :   String; // ÜRT     "uretimTarihiString": "2019-12-30"
//        [LMax(23)] kullanilabilirAdetForExcel  :   String;
//        [LMax(23)] kullanilabilirAdet  :   String;
//        [LMax(23)] olusturulmaTarihiString  :   String;
//        [LMax(23)] uretimTarihiString  :   String;
       // [LMax(23)] test  :   String;
//        [LMax(23)] sonKullanmaTarihiString  :   String;
	 end;
	 TAyrintiUrunSonuc = class(TModel)
    public
	    	SNC :   Array of  TAyrintiUrunSorgulaSonucItem;
        MSJ :   Array of  TMesaj;
   end;


   TAskiSorgulaSonucItem = class(TModel)
    public
        //[LMax(20)]  UTP :   String; //    TIBBI_CIHAZ / KOZMETIK_URUN
        [LMax(23)]  UNO :   String; // Ürün No.
        [LMax(20)]  LNO :   String; // Lot/Batch No.
        [LMax(20)]  SNO :   String; // Seri/Sýra No.
		    [LMax(50)]	BNO	:	String; // Fatura/Ýrsaliye No.
		    [LMax(16)]	KUN :   String; // Gönderen Kurum Kodu.
                    ADT :   Integer;// Adet
        [LMax(36)]  BID :   String; // Bildirim Kodu.
		    [LMax(64)]	BTI :   String; // Bildirim Tipi.
		    [LMax(19)]	BZA	:	String;	// Bildirim Zamaný. YYYY-AA-GG SS:DD:ss
		    [LMax(164)]	AKU :   String; // Verilen Kurumun adý.
		    [LMax(128)]	MME :   String; // Marka Model Etiket adý
	 end;

	 TAskiSNC = class(TModel)
    public
	    	LST :   Array of  TAskiSorgulaSonucItem;
        OFF :   String;
   end;

	 TAskiSonuc = class(TModel)
    public
	    	SNC :   TAskiSNC; //TAskiSorgulaSonucItem;
        MSJ :   Array of  TMesaj;
   end;


   TBildirimSonucItem = class(TModel)
    public
        //[LMax(20)]  UTP :   String; //    TIBBI_CIHAZ / KOZMETIK_URUN
		    [LMax(64)]	BTI :   String; // Bildirim Tipi.
        [LMax(23)]  UNO :   String; // Ürün No.
        [LMax(20)]  LNO :   String; // Lot/Batch No.
        [LMax(20)]  SNO :   String; // Seri/Sýra No.
                    ADT :   Integer;// Adet
		    [LMax(50)]	BNO	:	String; // Fatura/Ýrsaliye No.
		    [LMax(36)]	BDR :   String; //
        [LMax(40)]  BID :   String; // Bildirim Kodu.
		    [LMax(19)]	BZA	:	String;	// Bildirim Zamaný. YYYY-AA-GG SS:DD:ss
		    [LMax(16)]	GKK :   String; // Gönderen Kurum Kodu.
		    [LMax(16)]	KUN :   String; // Gönderen Kurum Kodu.
        [LMax(5)]   BEN : String;
		    [LMax(23)]  UIK :   String; // Tekil ürünü üreten/ithal eden kurumun numarasýdýr.
		    [LMax(10)]	GIT	:	String;	// Bildirim Zamaný. YYYY-AA-GG SS:DD:ss
		    [LMax(164)]	BKU :   String; // Verilen Kurumun adý.
		    [LMax(164)]	DKU :   String; // Marka Model Etiket adý
                    AAD :   Integer;// Adet
        [LMax(40)]  OFF :   String; // Bildirim Kodu.
	 end;
   TBildirimSonucListesiOff = class(TModel)
   public
        LST : Array of  TBildirimSonucItem;
        OFF : String;
   end;

	 TBildirimSonucListe = class(TModel)
    public
	    	SNC : Array of TBildirimSonucItem;
        MSJ : Array of TMesaj;
   end;

   TBildirimSonucUrun = class(TModel)
    public
	    	SNC : TBildirimSonucListesiOff;
        MSJ : Array of TMesaj;
   end;

{    TBildirim = class(TModel)
    public
        UNO :   String;
        SNO :   String;
        LNO :   String;
        ADT :   Integer;
        URA :   Integer;
        BID :   String;
        GKK :   Int64;
        BNO :   String;
        BZA :   String;
        BTI :   String;
    end;

    TBildirimWrapper = class(TModel)
    public
        SNC : Array of TBildirim;
    end;

    TMesaj = class(TModel)
    public
        MET :   String;
        KOD :   String;
        TIP :   String;
        MPA :   Array of TModel;
    end; }

    TSonuc = class(TModel)
    public
        SNC :   String;
        MSJ :   Array of TMesaj;
    end;

    TKabulIstek = class(TModel)
    public
        GKK :   String;
        SAN :   Integer;
    end;

   TKabulSonucItem = class(TModel)
    public
        [LMax(23)]  UNO :   String; // Ürün No.
        [LMax(20)]  LNO :   String; // Lot/Batch No.
        [LMax(20)]  SNO :   String; // Seri/Sýra No.
                    ADT :   Integer;// Adet
        [LMax(40)]  VBI :   String; // Bildirim Kodu.     BID
		    [LMax(128)]	MME :   String; // Marka Model Etiket adý
		    [LMax(16)]	GKK :   String; // Gönderen Kurum Kodu.
		    [LMax(50)]	BNO	:	String; // Fatura/Ýrsaliye No.
		    [LMax(19)]	BZA	:	String;	// Bildirim Zamaný. YYYY-AA-GG SS:DD:ss
		    [LMax(64)]	BTI :   String; // Bildirim Tipi.
		    [LMax(16)]	UIK :   String; // Üreten/ithal eden kurum kodu.
        [LMax(64)]	GKU :   String;	// Gönderen Kurum ünvaný
		    [LMax(64)]	UDI :   String; // Bildirim Tipi.

		    [LMax(40)]	BID :   String; // Bildirim Tipi.

	 end;

   TKabulSonucSNC = class(TModel)
   public
        LST: Array of  TKabulSonucItem;
        OFF: string;
   end;
	 TKabulSonuc = class(TModel)
    public
	    	SNC :   TKabulSonucSNC;
        MSJ :   array of TMesaj;
   end;

{    TKabulSonucPayload = class(TModel)
    public
        LST :   Array of  TM_KabulSonuc;
        OFF :   String;
    end;


    TSorguSonuc = class(TModel)
    public
        SNC :   TSorguSonucPayload;
        MSJ :   String;
    end;
}

implementation

end.
