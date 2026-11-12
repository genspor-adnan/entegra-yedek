using System.Text;
using System.Text.RegularExpressions;

namespace Gentegre.Cekirdek.Cihaz;

/// <summary>ORM^O01 emir türü (ORC-1 / ORC-5).</summary>
public enum OrmEmri
{
    /// <summary>NW / SC - yeni tetkik istemi (kabulde).</summary>
    Yeni = 1,
    /// <summary>XO / SC - istem güncellemesi (randevu saati, tetkik, tanı değişti).</summary>
    Guncelle = 2,
    /// <summary>CA / CA - istem iptali.</summary>
    Iptal = 3,
}

/// <summary>HL7 kişi alanı: Kimlik^Soyad^Ad^İkinciAd^^Önek (kılavuz: hekimde Kimlik = TCKN).</summary>
public sealed record Hl7Kisi(string Kimlik = "", string Soyad = "", string Ad = "", string IkinciAd = "", string Onek = "")
{
    public bool BosMu => Kimlik.Length == 0 && Soyad.Length == 0 && Ad.Length == 0;
}

/// <summary>Kod^Ad çifti (LOINC, ICD-10, tekrar istem gerekçesi).</summary>
public sealed record Hl7Kod(string Kod, string Ad = "");

/// <summary>DG1 tanısı: ICD-10 + tür (A ön tanı / F kesin tanı).</summary>
public sealed record Hl7Tani(string Icd, string Ad = "", string Tur = "A");

/// <summary>ORM mesajına girecek veri - düz taşıyıcı, iş kuralı yok (kural <see cref="OrmUretici.Denetle"/>'de).</summary>
public sealed record OrmVerisi
{
    public OrmEmri Emir { get; init; } = OrmEmri.Yeni;

    // ---- MSH
    /// <summary>MSH-3: firma uygulama kodu - e-Nabız'da kayıtlı olduğu gibi (yanlışsa 0275).</summary>
    public string FirmaKodu { get; init; } = "";
    /// <summary>MSH-4: HBYS (hastane) adı.</summary>
    public string HbysAdi { get; init; } = "";
    public string AliciUygulama { get; init; } = "TELERADYOLOJI";
    public string AliciTesis { get; init; } = "TELERADYOLOJI";
    public DateTime Zaman { get; init; } = Saat.Simdi;
    public string KontrolNo { get; init; } = "";
    /// <summary>MSH-18: UTF8 ya da Windows1254 (Windows1254 Bakanlık'a önceden bildirilir).</summary>
    public string Encoding { get; init; } = "UTF8";

    // ---- PID
    public string HastaDosyaNo { get; init; } = "";
    public string HastaTckn { get; init; } = "";
    /// <summary>Yabancı hasta: TCKN yoksa pasaport (PID-4 …^^^PASS) + <see cref="UlkeKodu"/> (PID-26, 4 hane SKRS).</summary>
    public string PasaportNo { get; init; } = "";
    public string UlkeKodu { get; init; } = "";
    public string HastaSoyad { get; init; } = "";
    public string HastaAd { get; init; } = "";
    public string HastaIkinciAd { get; init; } = "";
    public DateTime? DogumTarihi { get; init; }
    /// <summary>F / M / U / O.</summary>
    public string Cinsiyet { get; init; } = "U";
    public string Adres { get; init; } = "";
    public string EvTelefonu { get; init; } = "";
    public string Eposta { get; init; } = "";
    public string IsTelefonu { get; init; } = "";
    /// <summary>PID-19: YUPAS no / bebekte faturalanan anne TCKN / transplantta alıcı TCKN; rutin hastada boş.</summary>
    public string SigortaliKimlik { get; init; } = "";
    public string AnneTckn { get; init; } = "";
    public string DogumYeri { get; init; } = "";
    /// <summary>PID-24: kimliksiz bebekte Y (çoğul) / N (tekil); TCKN'li hastada boş.</summary>
    public string CokluDogum { get; init; } = "";
    public string DogumSirasi { get; init; } = "";

    // ---- PV1
    /// <summary>E acil · I yatan · O ayaktan.</summary>
    public string HastaSinifi { get; init; } = "O";
    public string BirimId { get; init; } = "";
    public string BirimAdi { get; init; } = "";
    public Hl7Kisi YonlendirenHekim { get; init; } = new();
    /// <summary>PV1-19: hastane başvuru referansı - e-Nabız 101 paketindekiyle AYNI (boşsa 0278).</summary>
    public string BasvuruReferansi { get; init; } = "";
    /// <summary>PV1-20 SGK (Medula'ya bildirilecek) / OTHER.</summary>
    public bool Sgk { get; init; }
    /// <summary>PV1-50: SGK ise Medula takip numarası.</summary>
    public string MedulaTakipNo { get; init; } = "";
    public DateTime? KabulZamani { get; init; }

    // ---- ORC / OBR
    public string AccessionNo { get; init; } = "";
    /// <summary>Klinisyenin istem zamanı (OBR-6).</summary>
    public DateTime? IstemZamani { get; init; }
    /// <summary>Randevu ya da çekim kabul zamanı (ORC-7, OBR-27, OBR-36) - çoklu istem eşleşmesi buna bakar (≤ 40 dk).</summary>
    public DateTime? PlanlananZaman { get; init; }
    public Hl7Kisi Giren { get; init; } = new();
    public Hl7Kisi Onaylayan { get; init; } = new();
    /// <summary>İstem yapan hekim (ORC-12 / OBR-16): Kimlik = TCKN (yoksa ret).</summary>
    public Hl7Kisi IsteyenHekim { get; init; } = new();
    public string KurumKisaAdi { get; init; } = "";
    public string KurumAdi { get; init; } = "";
    public string KurumSkrs { get; init; } = "";
    public string SubeNo { get; init; } = "1";
    public string MedulaTesisKodu { get; init; } = "";
    /// <summary>OBR-4 resmî SUT kodu (≥ 6 hane, nokta/virgül/tire yok) ve adı.</summary>
    public string SutKodu { get; init; } = "";
    public string SutAdi { get; init; } = "";
    /// <summary>OBR-4 LOINC (bir ya da çok); LOINC'siz istem Bakanlık'ta "gönderilmemiş" sayılır (18.02.2020 duyurusu).</summary>
    public IReadOnlyList<Hl7Kod> Loinc { get; init; } = [];
    public string KlinikBilgi { get; init; } = "";
    /// <summary>OBR-15: hasta başka hastaneye (SKRS) gönderiliyorsa o hastanenin SKRS'si; boşsa "Radiology".</summary>
    public string GonderilenSkrs { get; init; } = "";
    public string SysTakipNo { get; init; } = "";
    public string HastaneReferansi { get; init; } = "";
    /// <summary>OBR-24 Kayıtlı Yöntem (CT, MR, CR, DX, US, MG, …; 2-16 karakter).</summary>
    public string Modalite { get; init; } = "";
    /// <summary>OBR-31: tekrar istem süresine takılanda gerekçe(ler) (SKRS Tekrar Tetkik İstem Gerekçeleri).</summary>
    public IReadOnlyList<Hl7Kod> TekrarGerekceleri { get; init; } = [];
    /// <summary>OBR-34 teknisyen (Kimlik = personel no).</summary>
    public Hl7Kisi Teknisyen { get; init; } = new();
    public IReadOnlyList<Hl7Tani> Tanilar { get; init; } = [];

    // ---- NTE (tek satır)
    public string Sikayet { get; init; } = "";
    public string Gecmis { get; init; } = "";
    public string Bulgu { get; init; } = "";
    public string Tedavi { get; init; } = "";
}

/// <summary>
/// ORM^O01 ÜRETİCİSİ - Teletıp istem mesajı (kullanıcı 11.11.2026: "ORM üreticiyi yaz"; Teleradyoloji Entegrasyon
/// Kılavuzu 3.43 § 3.1.3.1-3.1.3.4 ve § 3.1.5 örnekleri). Yalnız Bakanlık profili: HL7 2.3.1, alan biçimleri kılavuzdaki
/// tablolar birebir. Mesaj Mirth K1 (TELETIP_HL7) üzerinden gider; Mirth içeriğe dokunmaz.
///
/// <para><b>Saf işlev</b> (veritabanı, ağ, saat yok) - <see cref="OruUretici"/> ile aynı yaklaşım; kaçış aynı
/// (<see cref="OruUretici.K"/>), iki kaçış kuralı olmasın.</para>
///
/// <para><b>Segment düzeni</b> kılavuz örneğindeki gibi: MSH, PID, PV1, ORC, OBR, DG1*, NTE (en çok 4). İptal (CA)
/// yalnız MSH, PID, PV1, ORC (Tablo 5).</para>
///
/// <para><b>ORC-21 kaçışsız <c>\S\</c>:</b> kılavuz biçimi "Kurum adı^^SKRS\S\şube\S\MEDULA tesis" - üçüncü bileşenin
/// içindeki <c>\S\</c> HL7 kaçışının KENDİSİ; değerler ayrı ayrı kaçırılır, ayraç olduğu gibi yazılır.</para>
/// </summary>
public static class OrmUretici
{
    private const string SegmentSonu = "\r";

    public static string Uret(OrmVerisi v)
    {
        var s = new StringBuilder(2048);
        var zaman = Z(v.Zaman);
        var kontrol = v.KontrolNo.Length > 0 ? v.KontrolNo : zaman;

        var msh = Bos(19);
        msh[2] = @"^~\&";
        msh[3] = K(v.FirmaKodu);
        msh[4] = K(v.HbysAdi);
        msh[5] = K(v.AliciUygulama);
        msh[6] = K(v.AliciTesis);
        msh[7] = zaman;
        msh[9] = "ORM^O01";
        msh[10] = K(kontrol);
        msh[11] = "P";
        msh[12] = "2.3.1";
        msh[18] = K(v.Encoding);
        Segment(s, "MSH", msh);

        Segment(s, "PID", Pid(v));
        Segment(s, "PV1", Pv1(v));
        Segment(s, "ORC", Orc(v));
        if (v.Emir == OrmEmri.Iptal) return s.ToString();

        Segment(s, "OBR", Obr(v));
        var sira = 1;
        foreach (var t in v.Tanilar.Where(x => !string.IsNullOrWhiteSpace(x.Icd)))
        {
            var dg1 = Bos(7);
            dg1[1] = (sira++).ToString();
            dg1[3] = $"{K(t.Icd)}^{K(t.Ad)}^I10";
            dg1[6] = t.Tur == "F" ? "F" : "A";
            Segment(s, "DG1", dg1);
        }
        if (v.Emir == OrmEmri.Yeni)
        {
            // NTE sırası ve türü sabit (Tablo 14-17); boş not da yazılır - kılavuz örneği dördünü de gönderiyor.
            Nte(s, 1, v.Sikayet, "NTE0001^PatientComplaints^TELETIP");
            Nte(s, 2, v.Gecmis, "NTE0002^PatientHistory^TELETIP");
            Nte(s, 3, v.Bulgu, "NTE0003^PatientSymptom^TELETIP");
            Nte(s, 4, v.Tedavi, "NTE0004^PatientCure^TELETIP");
        }
        return s.ToString();
    }

    // ------------------------------------------------------------------ segmentler
    /// <summary>PID alanları (dizin = alan no). ORU'nun Bakanlık profili de bunu kullanır - kılavuz ORU'nun PID'ini HBYS
    /// bölümündekiyle aynı tanımlar; iki ayrı PID kodu biri düzeltilip öteki unutulurdu (1326).</summary>
    public static string[] PidAlanlari(OrmVerisi v) => Pid(v);

    private static string[] Pid(OrmVerisi v)
    {
        var a = Bos(27);
        a[2] = v.KurumSkrs.Length > 0 && v.HastaDosyaNo.Length > 0 ? $"{K(v.KurumSkrs)}-{K(v.HastaDosyaNo)}" : K(v.HastaDosyaNo);
        a[3] = v.HastaDosyaNo.Length > 0 ? $"{K(v.HastaDosyaNo)}^^HBYS" : "";
        var yabanci = v.HastaTckn.Length == 0 && v.PasaportNo.Length > 0;
        a[4] = yabanci ? $"{K(v.PasaportNo)}^^^PASS" : v.HastaTckn.Length > 0 ? $"{K(v.HastaTckn)}^^^TC" : "";
        a[5] = v.HastaSoyad.Length == 0 && v.HastaAd.Length == 0 ? ""
             : v.HastaIkinciAd.Length > 0 ? $"{K(v.HastaSoyad)}^{K(v.HastaAd)}^{K(v.HastaIkinciAd)}"
             : $"{K(v.HastaSoyad)}^{K(v.HastaAd)}";
        a[7] = v.DogumTarihi is { } d ? d.ToString("yyyyMMdd") : "";
        a[8] = K(v.Cinsiyet);
        a[11] = K(TekSatir(v.Adres));
        a[13] = v.EvTelefonu.Length == 0 && v.Eposta.Length == 0 ? "" : $"{K(v.EvTelefonu)}^^^{K(v.Eposta)}";
        a[14] = K(v.IsTelefonu);
        a[19] = K(v.SigortaliKimlik);
        a[21] = K(v.AnneTckn);
        a[23] = K(v.DogumYeri);
        a[24] = K(v.CokluDogum);
        a[25] = v.CokluDogum.Length > 0 ? K(v.DogumSirasi) : "";
        a[26] = yabanci ? K(v.UlkeKodu) : "";
        return a;
    }

    private static string[] Pv1(OrmVerisi v)
    {
        var a = Bos(52);
        a[2] = K(v.HastaSinifi);
        a[3] = v.BirimId.Length == 0 && v.BirimAdi.Length == 0 ? "" : $"{K(v.BirimId)}^^^{K(v.BirimAdi)}";
        a[8] = Kisi(v.YonlendirenHekim);
        // PV1-19: VisitNo^^^^^^^^BirimId&BirimAdı&HBYS (Tablo 10).
        a[19] = v.BasvuruReferansi.Length == 0 ? ""
              : $"{K(v.BasvuruReferansi)}^^^^^^^^{K(v.BirimId)}&{K(v.BirimAdi)}&HBYS";
        a[20] = v.Sgk ? "SGK" : "OTHER";
        a[44] = v.KabulZamani is { } k ? Z(k) : "";
        a[50] = v.Sgk ? K(v.MedulaTakipNo) : "";
        a[51] = "V";
        return a;
    }

    private static string[] Orc(OrmVerisi v)
    {
        var a = Bos(22);
        a[1] = v.Emir switch { OrmEmri.Guncelle => "XO", OrmEmri.Iptal => "CA", _ => "NW" };
        a[2] = $"{K(v.AccessionNo)}^HBYS";
        a[5] = v.Emir == OrmEmri.Iptal ? "CA" : "SC";
        a[7] = v.PlanlananZaman is { } p ? $"1^once^^{Z(p)}" : "";
        a[9] = Z(v.Zaman);
        a[10] = Kisi(v.Giren);
        if (v.Emir == OrmEmri.Yeni) a[11] = Kisi(v.Onaylayan);
        a[12] = Kisi(v.IsteyenHekim);
        a[17] = v.BirimId.Length == 0 && v.BirimAdi.Length == 0 ? ""
              : $"{K(v.BirimId)}^{K(v.BirimAdi)}^{K(v.KurumKisaAdi)}".TrimEnd('^');
        a[21] = Orc21(v);
        return a;
    }

    /// <summary>"Kurum adı^^SKRS\S\şube\S\MEDULA tesis" (Tablo 11 örneği: "Bartın Devlet Hastanesi^^148\S\1\S\11740001").</summary>
    public static string Orc21(OrmVerisi v) =>
        $@"{K(v.KurumAdi)}^^{K(v.KurumSkrs)}\S\{K(v.SubeNo)}\S\{K(v.MedulaTesisKodu)}";

    private static string[] Obr(OrmVerisi v)
    {
        var a = Bos(37);
        a[1] = "1";
        a[2] = $"{K(v.AccessionNo)}^HBYS";
        a[3] = $"{K(v.AccessionNo)}^RBS";
        a[4] = Obr4(v);
        a[6] = v.IstemZamani is { } i ? Z(i) : "";
        a[13] = K(TekSatir(v.KlinikBilgi));
        a[15] = v.GonderilenSkrs.Length > 0 ? $"{K(v.GonderilenSkrs)}&&SKRS^^^^^R" : "Radiology^^^^^R";
        a[16] = Kisi(v.IsteyenHekim);
        a[18] = K(v.AccessionNo);
        a[20] = K(v.SysTakipNo);
        a[21] = K(v.HastaneReferansi);
        a[24] = K(v.Modalite);
        a[27] = v.PlanlananZaman is { } p ? $"1^once^^{Z(p)}" : "";
        a[31] = string.Join("~", v.TekrarGerekceleri.Where(x => x.Kod.Length > 0).Select(x => $"{K(x.Kod)}^{K(x.Ad)}"));
        a[34] = v.Teknisyen.BosMu ? ""
              : $"{K(v.Teknisyen.Kimlik)}&{K(v.Teknisyen.Soyad)}&{K(v.Teknisyen.Ad)}&{K(v.Teknisyen.IkinciAd)}&&{K(v.Teknisyen.Onek)}".TrimEnd('&');
        a[36] = v.PlanlananZaman is { } r ? Z(r) : "";
        return a;
    }

    /// <summary>OBR-4: SUT^Ad^SUT[^LOINC^Ad^LNC]… - LOINC yoksa yalnız SUT üçlüsü.</summary>
    public static string Obr4(OrmVerisi v)
    {
        var b = new StringBuilder($"{K(v.SutKodu)}^{K(v.SutAdi)}^SUT");
        foreach (var l in v.Loinc.Where(x => x.Kod.Length > 0)) b.Append($"^{K(l.Kod)}^{K(l.Ad)}^LNC");
        return b.ToString();
    }

    private static void Nte(StringBuilder s, int no, string metin, string tur)
    {
        var a = Bos(5);
        a[1] = no.ToString();
        a[2] = "P";
        a[3] = K(TekSatir(metin));   // kılavuz: Seq-3 tek satır; yeni satırlar silinir
        a[4] = tur;
        // Boş açıklamada da NTE-4 yazılmalı: Segment sondaki boşları atar, ortadakini değil.
        Segment(s, "NTE", a);
    }

    // ------------------------------------------------------------------ denetim
    private static readonly Regex TcknBicim = new(@"^[1-9][0-9]{10}$", RegexOptions.Compiled);
    private static readonly Regex SutBicim = new(@"^[0-9A-Za-z]{6,}$", RegexOptions.Compiled);
    private static readonly Regex MedulaBicim = new(@"^[0-9]{8}$", RegexOptions.Compiled);

    /// <summary>
    /// GÖNDERMEDEN ÖNCE: Bakanlık'ın reddedeceği eksikler (kılavuz § 3.3 "sık yapılan hatalar" + § 3.4 hata kodları).
    /// Boş liste = gönderilebilir. Ekranda "gidemez" rozeti ve kuyruğun "göndermeden dur" kararı buradan.
    /// </summary>
    public static List<string> Denetle(OrmVerisi v)
    {
        var e = new List<string>();
        if (v.AccessionNo.Length == 0) e.Add("Accession numarası yok (ORC-2 / OBR-18).");
        if (v.KurumSkrs.Length == 0) e.Add("Kurum SKRS kodu yok (ORC-21, 0005).");
        if (v.FirmaKodu.Length == 0) e.Add("Firma uygulama kodu yok (MSH-3, 0275).");
        // ORC-21 son bileşeni (Tablo 11 / 19, iptalde de var): "Kurum^^SKRS\S\şube\S\MEDULA tesis". Kılavuz örnekleri
        //   8 hane (11740001); boş giderse kurum alanı eksik kalır (kullanıcı 11.11.2026: "Medula tesis kodunu denetime ekle").
        if (v.MedulaTesisKodu.Length == 0) e.Add("MEDULA tesis kodu yok (ORC-21) - kurum profilinde tesis kodu girilmeli.");
        else if (!MedulaBicim.IsMatch(v.MedulaTesisKodu)) e.Add("MEDULA tesis kodu 8 haneli sayı olmalı (ORC-21).");
        if (v.Emir == OrmEmri.Iptal) return e;

        if (v.HastaTckn.Length > 0 && !TcknGecerli(v.HastaTckn)) e.Add("Hasta TCKN geçersiz (PID-4).");
        if (v.HastaTckn.Length == 0 && v.PasaportNo.Length == 0) e.Add("Hasta TCKN yok (PID-4); acil hasta TCKN kesinleşmeden gönderilmez.");
        if (v.HastaTckn.Length == 0 && v.PasaportNo.Length > 0 && !Regex.IsMatch(v.UlkeKodu, "^[0-9]{4}$"))
            e.Add("Yabancı hastada ülke kodu yok ya da 4 hane değil (PID-26).");
        if (v.HastaDosyaNo.Length == 0) e.Add("Hasta dosya numarası yok (PID-3).");
        if (v.BasvuruReferansi.Length == 0) e.Add("e-Nabız başvuru referansı yok (PV1-19, 0278).");
        if (v.Sgk && v.MedulaTakipNo.Length == 0) e.Add("SGK hastasında Medula takip numarası yok (PV1-50).");
        if (!TcknGecerli(v.IsteyenHekim.Kimlik)) e.Add("İstem yapan hekimin TCKN'si yok ya da geçersiz (ORC-12 / OBR-16).");
        if (!SutBicim.IsMatch(v.SutKodu)) e.Add("SUT kodu 6 haneden kısa ya da nokta / virgül / tire içeriyor (OBR-4, 0008).");
        if (v.SutAdi.Length == 0) e.Add("SUT açıklaması yok (OBR-4-2, 0008).");
        if (!v.Loinc.Any(x => x.Kod.Length > 0)) e.Add("LOINC kodu yok (OBR-4) - LOINC'siz istem Bakanlık'ta gönderilmemiş sayılır.");
        if (v.Modalite.Length is < 2 or > 16) e.Add("Modalite 2-16 karakter olmalı (OBR-24, 0003).");
        if (v.IstemZamani is null) e.Add("İstem zamanı yok (OBR-6).");
        if (v.PlanlananZaman is null) e.Add("Randevu / çekim kabul zamanı yok (OBR-36).");
        if (v.SysTakipNo.Length == 0) e.Add("SYS takip numarası yok (OBR-20).");
        if (v.HastaneReferansi.Length == 0) e.Add("Hastane referans numarası yok (OBR-21).");
        if (v.Tanilar.Any(t => t.Tur is not ("A" or "F"))) e.Add("Tanı türü A ya da F olmalı (DG1-6, 0240).");
        return e;
    }

    /// <summary>TCKN algoritması (10. ve 11. hane denetimi).</summary>
    public static bool TcknGecerli(string t)
    {
        if (!TcknBicim.IsMatch(t ?? "")) return false;
        var h = t!.Select(c => c - '0').ToArray();
        var tek = h[0] + h[2] + h[4] + h[6] + h[8];
        var cift = h[1] + h[3] + h[5] + h[7];
        var d10 = ((tek * 7 - cift) % 10 + 10) % 10;
        var d11 = h.Take(10).Sum() % 10;
        return h[9] == d10 && h[10] == d11;
    }

    // ------------------------------------------------------------------ yardımcı
    private static string[] Bos(int n)
    {
        var a = new string[n];
        for (var i = 0; i < n; i++) a[i] = "";
        return a;
    }

    private static void Segment(StringBuilder s, string ad, string[] alanlar)
    {
        s.Append(ad);
        // MSH'de 1. alan ayıracın kendisi: dizide MSH-2 indeks 2'de, araya ayraç konmaz.
        var bas = ad == "MSH" ? 2 : 1;
        for (var i = bas; i < alanlar.Length; i++) s.Append('|').Append(alanlar[i]);
        while (s[^1] == '|') s.Length--;
        s.Append(SegmentSonu);
    }

    /// <summary>Kimlik^Soyad^Ad^İkinciAd^^Önek; sondaki boş bileşenler atılır.</summary>
    private static string Kisi(Hl7Kisi k) => k.BosMu ? ""
        : $"{K(k.Kimlik)}^{K(k.Soyad)}^{K(k.Ad)}^{K(k.IkinciAd)}^^{K(k.Onek)}".TrimEnd('^');

    private static string TekSatir(string? m) =>
        Regex.Replace((m ?? "").Trim(), @"\s*[\r\n]+\s*", " ");

    private static string Z(DateTime t) => t.ToString("yyyyMMddHHmmss");

    private static string K(string? d) => OruUretici.K(d);
}
