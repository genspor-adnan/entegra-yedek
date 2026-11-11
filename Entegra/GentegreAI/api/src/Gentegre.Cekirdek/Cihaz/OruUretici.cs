using System.Text;

namespace Gentegre.Cekirdek.Cihaz;

/// <summary>Üretilecek mesajın profili — sürüm ve gövde biçimini belirler.</summary>
public enum Hl7Profili
{
    /// <summary>Kurumun HBYS'si: HL7 2.5, rapor metni satır satır TX.</summary>
    Kurum = 1,
    /// <summary>
    /// T.C. Sağlık Bakanlığı Teletıp/Teleradyoloji: HL7 <b>2.3.1</b>, rapor
    /// gövdesi dört parça base64 (Entegrasyon Kılavuzu 3.46).
    /// </summary>
    Bakanlik = 2,
}

/// <summary>ORU mesajına girecek veri — tek düz taşıyıcı, iş kuralı yok.</summary>
public sealed record OruVerisi
{
    public Hl7Profili Profil { get; init; } = Hl7Profili.Kurum;

    // ---------------------------------------------------------------- MSH ----
    public string GonderenUygulama { get; init; } = "GENTEGRE";
    public string GonderenTesis { get; init; } = "";
    public string AliciUygulama { get; init; } = "";
    public string AliciTesis { get; init; } = "";
    public DateTime Zaman { get; init; } = Saat.Simdi;
    public string KontrolNo { get; init; } = "";
    /// <summary>MSH-18: <c>UTF8</c> ya da <c>Windows1254</c>.</summary>
    public string Encoding { get; init; } = "UTF8";

    // ---------------------------------------------------------------- PID ----
    public string HastaDosyaNo { get; init; } = "";
    public string HastaTckn { get; init; } = "";
    public string HastaSoyad { get; init; } = "";
    public string HastaAd { get; init; } = "";
    public DateTime? DogumTarihi { get; init; }
    /// <summary>F / M / U / O.</summary>
    public string Cinsiyet { get; init; } = "U";

    // ------------------------------------------------------------ PV1/ORC ----
    public string BasvuruNo { get; init; } = "";
    public string KurumSkrs { get; init; } = "";
    public string AccessionNo { get; init; } = "";
    public string IsteyenHekimTckn { get; init; } = "";
    public string IsteyenHekimSoyad { get; init; } = "";
    public string IsteyenHekimAd { get; init; } = "";
    public string Bolum { get; init; } = "";

    // ---------------------------------------------------------------- OBR ----
    public string SutKodu { get; init; } = "";
    public string SutAdi { get; init; } = "";
    public string Loinc { get; init; } = "";
    public string LoincAdi { get; init; } = "";
    public DateTime? IstemZamani { get; init; }
    public DateTime? OnayZamani { get; init; }
    public DateTime? CekimZamani { get; init; }
    public string KlinikBilgi { get; init; } = "";
    /// <summary>Hizmeti VEREN kurumun SKRS kodu (OBR-15) — bkz. kılavuz.</summary>
    public string HizmetVerenSkrs { get; init; } = "";
    public string SysTakipNo { get; init; } = "";
    public string HastaneReferans { get; init; } = "";
    /// <summary>OBR-24: CT / MR / CR … en az iki harf.</summary>
    public string ModaliteKodu { get; init; } = "";
    public string TeknisyenId { get; init; } = "";
    public string TeknisyenSoyad { get; init; } = "";
    public string TeknisyenAd { get; init; } = "";

    // ---------------------------------------------------------------- OBX ----
    public string RaporTeknik { get; init; } = "";
    public string RaporKarsilastirma { get; init; } = "";
    public string RaporBulgular { get; init; } = "";
    public string RaporSonuc { get; init; } = "";
    public short IstemNedeniPuan { get; init; }
    public short CekimKalitePuan { get; init; }
    public string RadyologTckn { get; init; } = "";
    public string RadyologSoyad { get; init; } = "";
    public string RadyologAd { get; init; } = "";
    /// <summary>Hazır OBX-17 gövdesi: <c>IV^Ioheksol^300</c>.</summary>
    public string KontrastObx17 { get; init; } = "";

    // ---- Bakanlık kılavuz biçimi (3.43 Tablo 9-10, 20-21; ORM ile aynı ortak bölümler) ----
    /// <summary>ORC-21: raporu gönderen kurumun adı ("B Hastanesi^^A-SKRS\S\şube\S\B-MEDULA tesis").</summary>
    public string KurumAdi { get; init; } = "";
    public string KurumKisaAdi { get; init; } = "";
    public string SubeNo { get; init; } = "1";
    /// <summary>ORC-21 son bileşeni: raporu gönderenin MEDULA tesis kodu.</summary>
    public string MedulaTesisKodu { get; init; } = "";
    /// <summary>PV1-2: E acil · I yatan · O ayaktan.</summary>
    public string HastaSinifi { get; init; } = "O";
    public string BirimId { get; init; } = "";
    /// <summary>PV1-20 SGK / OTHER; SGK ise PV1-50 Medula takip.</summary>
    public bool Sgk { get; init; }
    public string MedulaTakipNo { get; init; } = "";
    /// <summary>ORC-7 / OBR-27 / OBR-36: randevu ya da çekim kabul zamanı (yoksa çekim zamanı).</summary>
    public DateTime? PlanlananZaman { get; init; }
    /// <summary>Ek rapor (addendum) ise durum C (correction), değilse F.</summary>
    public bool Duzeltme { get; init; }

    public IReadOnlyList<string> TaniIcd { get; init; } = [];
    /// <summary>Kurum profilinde düz metin rapor (TX satırları).</summary>
    public IReadOnlyList<string> RaporSatirlari { get; init; } = [];
}

/// <summary>
/// ORU^R01 ÜRETİCİSİ (814).
///
/// <para><b>Saf işlev:</b> veritabanı, ağ, saat yok - içeri veri, dışarı
/// metin. Böylece mesajın biçimi karşı uç olmadan sınanabiliyor; kapsam
/// belgesindeki "HL7 önce yapılabilir" gerekçesi budur.</para>
///
/// <para><b>Tek üretici, iki profil.</b> Bakanlık mesajı 2.3.1 ve gövdesi
/// dört parça base64; kurum HBYS'si 2.5 ve satır satır TX. İki ayrı üretici
/// yazmak, bir alanı birinde düzeltip ötekinde unutmak demekti - bu yüzden
/// fark <see cref="Hl7Profili"/> dalında, ayrı sınıfta değil.</para>
///
/// <para><b>Kaçış yapılır:</b> hasta adında <c>&amp;</c>, raporda <c>|</c>
/// geçebilir. Kaçışsız gönderilen tek karakter, karşı tarafta bütün alanları
/// kaydırır.</para>
/// </summary>
public static class OruUretici
{
    private const char Alan = '|', Bilesen = '^', Tekrar = '~', AltBilesen = '&';
    private const string SegmentSonu = "\r";

    public static string Uret(OruVerisi v)
    {
        var s = new StringBuilder(2048);
        var surum = v.Profil == Hl7Profili.Bakanlik ? "2.3.1" : "2.5";
        var zaman = Z(v.Zaman);
        var kontrol = v.KontrolNo.Length > 0 ? v.KontrolNo : zaman;

        // MSH-2 kodlama karakterleri SABİT YAZILIR: çözümleyicimiz ayırıcıyı
        //   MSH'den okuyor (432) ve karşı taraftan da aynısı bekleniyor.
        Segment(s, "MSH", [
            @"^~\&", K(v.GonderenUygulama), K(v.GonderenTesis),
            K(v.AliciUygulama), K(v.AliciTesis), zaman, "",
            "ORU^R01", kontrol, "P", surum,
            // MSH-13..17 boş, MSH-18 karakter kümesi.
            "", "", "", "", "",
            v.Encoding,
        ], mshMi: true);

        // ALANLAR DİZİ İNDEKSİYLE: "kaç virgül saydım" yöntemi PID-3 ile
        //   PID-4'ü kaydırıyordu; numara kılavuzda yazan numaradır.
        var bakanlik = v.Profil == Hl7Profili.Bakanlik;
        var ziyaretNo = v.HastaneReferans.Length > 0 ? v.HastaneReferans : v.BasvuruNo;
        var planlanan = v.PlanlananZaman ?? v.CekimZamani;
        var pid = Bos(9);
        pid[5] = Ad(v.HastaSoyad, v.HastaAd);
        pid[7] = v.DogumTarihi is { } d ? d.ToString("yyyyMMdd") : "";
        pid[8] = K(v.Cinsiyet);
        if (bakanlik)
        {
            // Kılavuz Tablo 9 (ORM ile ortak): PID-2 "SKRS-dosya", PID-3 "dosya^^HBYS", PID-4 "TCKN^^^TC".
            pid[2] = v.KurumSkrs.Length > 0 && v.HastaDosyaNo.Length > 0 ? $"{K(v.KurumSkrs)}-{K(v.HastaDosyaNo)}" : K(v.HastaDosyaNo);
            pid[3] = v.HastaDosyaNo.Length > 0 ? $"{K(v.HastaDosyaNo)}^^HBYS" : "";
            pid[4] = v.HastaTckn.Length > 0 ? $"{K(v.HastaTckn)}^^^TC" : "";
        }
        else
        {
            pid[3] = K(v.HastaDosyaNo);      // hastane dosya numarası
            pid[4] = K(v.HastaTckn);         // TCKN
        }
        Segment(s, "PID", pid);

        // PV1-19 (Visit No): Bakanlık e-Nabız'daki hastane başvuru referansını
        //   bekliyor, boş geçilirse 0278 hatası dönüyor.
        var pv1 = Bos(bakanlik ? 52 : 20);
        pv1[2] = bakanlik ? K(v.HastaSinifi.Length > 0 ? v.HastaSinifi : "O") : "O";
        pv1[3] = K(v.Bolum);
        if (bakanlik)
        {
            // Tablo 10: "VisitNo^^^^^^^^BirimId&BirimAdı&HBYS", PV1-20 SGK/OTHER, PV1-50 Medula takip, PV1-51 V.
            pv1[3] = v.BirimId.Length == 0 && v.Bolum.Length == 0 ? "" : $"{K(v.BirimId)}^^^{K(v.Bolum)}";
            pv1[19] = ziyaretNo.Length == 0 ? ""
                    : v.BirimId.Length == 0 && v.Bolum.Length == 0 ? K(ziyaretNo)      // birim yoksa yalnız ziyaret no
                    : $"{K(ziyaretNo)}^^^^^^^^{K(v.BirimId)}&{K(v.Bolum)}&HBYS";
            pv1[20] = v.Sgk ? "SGK" : "OTHER";
            pv1[50] = v.Sgk ? K(v.MedulaTakipNo) : "";
            pv1[51] = "V";
        }
        else pv1[19] = K(ziyaretNo);
        Segment(s, "PV1", pv1);

        var orc = Bos(22);
        if (bakanlik)
        {
            // Tablo 20 (3.43 - 31.05.2022 güncellemesi): ORC-1 SN, ORC-2 acc^HBYS, ORC-3 acc^RBS,
            //   ORC-21 "Kurum adı^^SKRS\S\şube\S\MEDULA tesis" - ayraç kaçışsız (ORM ile aynı).
            orc[1] = "SN";
            orc[2] = $"{K(v.AccessionNo)}^HBYS";
            orc[3] = $"{K(v.AccessionNo)}^RBS";
            orc[7] = planlanan is { } p7 ? $"1^once^^{Z(p7)}" : "";
            orc[9] = Z(v.Zaman);
            orc[12] = Kisi(v.IsteyenHekimTckn, v.IsteyenHekimSoyad, v.IsteyenHekimAd);
            orc[17] = v.BirimId.Length == 0 && v.Bolum.Length == 0 ? ""
                    : $"{K(v.BirimId)}^{K(v.Bolum)}^{K(v.KurumKisaAdi)}".TrimEnd('^');
            orc[21] = $@"{K(v.KurumAdi)}^^{K(v.KurumSkrs)}\S\{K(v.SubeNo)}\S\{K(v.MedulaTesisKodu)}";
        }
        else
        {
            orc[1] = "NW";
            orc[2] = K(v.AccessionNo);
            orc[5] = "SC";
            orc[9] = v.IstemZamani is { } io ? Z(io) : "";
            orc[12] = Kisi(v.IsteyenHekimTckn, v.IsteyenHekimSoyad, v.IsteyenHekimAd);
            orc[21] = K(v.KurumSkrs);        // kurum SKRS kodu - eşleştirme anahtarı
        }
        Segment(s, "ORC", orc);

        Segment(s, "OBR", ObrAlanlari(v));

        if (v.Profil == Hl7Profili.Bakanlik) BakanlikObx(s, v);
        else                                 KurumObx(s, v);

        var sira = 1;
        foreach (var icd in v.TaniIcd.Where(x => !string.IsNullOrWhiteSpace(x)))
        {
            var dg1 = Bos(7);
            dg1[1] = sira++.ToString();
            dg1[3] = K(icd) + "^^I10";   // DG1-3: ICD-10, SUT koduyla ilgili tanı
            dg1[6] = "A";                // A = admitting/kesin
            Segment(s, "DG1", dg1);
        }

        return s.ToString();
    }

    // ---------------------------------------------------------------- OBR ----
    private static string[] Bos(int uzunluk)
    {
        var a = new string[uzunluk];
        for (var i = 0; i < uzunluk; i++) a[i] = "";
        return a;
    }

    private static string[] ObrAlanlari(OruVerisi v)
    {
        var a = Bos(37);
        var bakanlik = v.Profil == Hl7Profili.Bakanlik;
        a[1] = "1";
        a[2] = bakanlik ? $"{K(v.AccessionNo)}^HBYS" : K(v.AccessionNo);    // Tablo 21
        a[3] = bakanlik ? $"{K(v.AccessionNo)}^RBS" : K(v.AccessionNo);
        // OBR-4: resmî SUT kodu + (varsa) LOINC. Kılavuz tür alanında yalnız
        //   SUT ya da LNC kabul ediyor; LOINC yoksa parça hiç yazılmaz.
        a[4] = v.Loinc.Length > 0
             ? $"{K(v.SutKodu)}^{K(v.SutAdi)}^SUT^{K(v.Loinc)}^{K(v.LoincAdi)}^LNC"
             : $"{K(v.SutKodu)}^{K(v.SutAdi)}^SUT";
        a[6] = v.IstemZamani is { } io ? Z(io) : "";
        // OBR-7 ORU'da RAPORUN ONAY zamanıdır (kılavuzun "sık yapılan
        //   hatalar" listesinde ilk sıralarda).
        a[7] = v.OnayZamani is { } oz ? Z(oz) : "";
        a[13] = K(v.KlinikBilgi);
        // OBR-15: hizmeti VEREN kurum. Teleradyolojide raporu biz yazıyoruz;
        //   istemi açan hastane başkasıysa kendi SKRS kodumuzu yazmak zorunda
        //   olduğumuz alan budur.
        a[15] = v.HizmetVerenSkrs.Length > 0
              ? $"{K(v.HizmetVerenSkrs)}&&SKRS^^^^^R"
              : "Radiology^^^^^R";
        a[16] = Kisi(v.IsteyenHekimTckn, v.IsteyenHekimSoyad, v.IsteyenHekimAd);
        a[18] = K(v.AccessionNo);
        a[20] = K(v.SysTakipNo);
        a[21] = K(v.HastaneReferans);
        a[24] = K(v.ModaliteKodu);
        var planlanan = v.PlanlananZaman ?? v.CekimZamani;   // Tablo 21: randevu / çekim kabul zamanı
        a[27] = planlanan is { } cz ? $"1^once^^{Z(cz)}" : "";
        if (v.TeknisyenId.Length > 0)
            a[34] = $"{K(v.TeknisyenId)}&{K(v.TeknisyenSoyad)}&{K(v.TeknisyenAd)}";
        a[36] = planlanan is { } rz ? Z(rz) : "";
        return a;
    }

    // ---------------------------------------------------------- Bakanlık ----
    private static void BakanlikObx(StringBuilder s, OruVerisi v)
    {
        // OBX-5: parçalar `~` ile ayrık, her parça base64 ve `^n` ile
        //   numaralı. Kılavuz sıraya bakmıyor ama NUMARAYA bakıyor.
        var parcalar = new List<string>();
        void Ekle(string metin, int no)
        {
            if (!string.IsNullOrWhiteSpace(metin)) parcalar.Add($"{B64(metin)}^{no}");
        }
        Ekle(v.RaporTeknik, 1);
        Ekle(v.RaporKarsilastirma, 2);
        Ekle(v.RaporBulgular, 3);
        Ekle(v.RaporSonuc, 4);

        var a = Bos(18);
        a[1] = "1";
        a[2] = "TX";
        a[3] = "TXT^BASE64";
        a[4] = "1";
        a[5] = string.Join(Tekrar, parcalar);
        a[11] = v.Duzeltme ? "C" : "F";
        // OBX-13: iki ayrı puan. Biri bile girilmemişse alan hiç yazılmaz -
        //   "1^0" göndermek, kılavuzda karşılığı olmayan bir değerdir.
        a[13] = v.IstemNedeniPuan > 0 && v.CekimKalitePuan > 0
              ? $"{v.IstemNedeniPuan}^{v.CekimKalitePuan}" : "";
        a[16] = Kisi(v.RadyologTckn, v.RadyologSoyad, v.RadyologAd);
        // OBX-17 KAÇIŞSIZ: alan zaten BİLEŞENLİ geliyor (`IV^Ioheksol^300`,
        //   fn_rad_kontrast_obx17). Kaçırmak `^` işaretlerini `\S\` yapar ve
        //   kontrast bilgisi tek parçaya çöker.
        a[17] = v.KontrastObx17;
        Segment(s, "OBX", a);
    }

    // -------------------------------------------------------------- kurum ----
    private static void KurumObx(StringBuilder s, OruVerisi v)
    {
        // Rapor metni SATIR SATIR: tek OBX'e sığdırmak uzun raporda kesilmeye
        //   yol açıyor, karşı sistemlerin çoğu satır başına bir OBX bekliyor.
        var satirlar = v.RaporSatirlari.Count > 0
            ? v.RaporSatirlari
            : Bolumle(v);

        var sira = 1;
        foreach (var satir in satirlar)
        {
            var a = Bos(18);
            a[1] = sira.ToString();
            a[2] = "TX";
            a[3] = $"{K(v.SutKodu)}^RAPOR";
            a[4] = "1";
            a[5] = K(satir);
            a[11] = v.Duzeltme ? "C" : "F";
            a[16] = Kisi(v.RadyologTckn, v.RadyologSoyad, v.RadyologAd);
            Segment(s, "OBX", a);
            sira++;
        }
    }

    /// <summary>Kurum profilinde başlıklı düz metin: bölümler alt alta.</summary>
    private static List<string> Bolumle(OruVerisi v)
    {
        var l = new List<string>();
        void Ekle(string baslik, string metin)
        {
            if (string.IsNullOrWhiteSpace(metin)) return;
            // BAŞLIK OLDUĞU GİBİ: ToUpperInvariant Türkçe'de "İ"yi "I" yapıyor
            //   ("SONUÇ VE ÖNERILER"). Karşı tarafa bozuk Türkçe göndermektense
            //   başlığı yazıldığı gibi göndermek yeğdir.
            l.Add(baslik + ":");
            l.AddRange(metin.Replace("\r\n", "\n").Split('\n'));
        }
        Ekle("Teknik", v.RaporTeknik);
        Ekle("Karşılaştırma", v.RaporKarsilastirma);
        Ekle("Bulgular", v.RaporBulgular);
        Ekle("Sonuç ve Öneriler", v.RaporSonuc);
        return l;
    }

    // ------------------------------------------------------------ yardımcı ----
    private static void Segment(StringBuilder s, string ad, IReadOnlyList<string> alanlar,
                                bool mshMi = false)
    {
        s.Append(ad);
        // MSH'de 1. alan AYIRICININ KENDİSİ: dizinin ilk ögesi MSH-2'dir,
        //   bu yüzden araya fazladan ayırıcı konmaz.
        var bas = mshMi ? 0 : 1;
        for (var i = bas; i < alanlar.Count; i++)
        {
            s.Append(Alan);
            s.Append(alanlar[i]);
        }
        // Sondaki boş alanlar taşınmaz: mesaj gereksiz uzar, okunmaz olur.
        while (s.Length > 0 && s[^1] == Alan) s.Length--;
        s.Append(SegmentSonu);
    }

    private static string Ad(string soyad, string ad)
        => soyad.Length == 0 && ad.Length == 0 ? "" : $"{K(soyad)}^{K(ad)}";

    /// <summary>TCKN^Soyad^Ad — kılavuzun hekim/radyolog biçimi.</summary>
    private static string Kisi(string tckn, string soyad, string ad)
        => tckn.Length == 0 && soyad.Length == 0 ? ""
         : $"{K(tckn)}^{K(soyad)}^{K(ad)}";

    private static string Z(DateTime t) => t.ToString("yyyyMMddHHmmss");

    private static string B64(string metin)
        => Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(metin.Trim()));

    /// <summary>
    /// HL7 KAÇIŞI: ayırıcı karakterler alan içinde geçemez. Ters bölü ÖNCE
    /// değiştirilir - sonra yapılırsa öteki kaçışların kendisi bozulur.
    /// </summary>
    internal static string K(string? deger)
    {
        if (string.IsNullOrEmpty(deger)) return "";
        return deger
            .Replace(@"\", @"\E\")
            .Replace(Alan.ToString(), @"\F\")
            .Replace(Bilesen.ToString(), @"\S\")
            .Replace(Tekrar.ToString(), @"\R\")
            .Replace(AltBilesen.ToString(), @"\T\")
            // Satır sonu segmenti böler: rapor metninde geçebilir.
            .Replace("\r\n", @"\X0D0A\").Replace("\r", @"\X0D\").Replace("\n", @"\X0A\");
    }
}
