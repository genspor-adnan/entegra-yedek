using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>Satıcı / alıcı (Delphi BizimTarafGetir / alıcı alanları).</summary>
public sealed record EFaturaTaraf(
    string Unvan, string Vkno, string VergiDairesi, string Adres, string Ilce, string Il,
    string Ulke, string PostaKodu, string Eposta, string Telefon, string Web = "",
    string Mersis = "", string TicaretSicil = "");

public sealed class EFaturaSatiri
{
    public int Id { get; init; }
    public int No { get; init; }
    public string Ad { get; init; } = "";
    public string Not { get; init; } = "";
    public string StokKodu { get; init; } = "";
    public string LotNo { get; init; } = "";
    public decimal Miktar { get; init; }
    public string BirimKodu { get; init; } = "C62";
    public decimal Fiyat { get; init; }
    /// <summary>Brüt = round(miktar × fiyat, 2) - iskonto öncesi.</summary>
    public decimal Brut { get; init; }
    /// <summary>Net = satırın kayıtlı tutarı (iskonto sonrası, KDV hariç).</summary>
    public decimal Net { get; init; }
    public decimal Iskonto => Math.Max(0, Brut - Net);
    public int KdvOran { get; init; }
    public decimal Kdv { get; init; }
    public int IstisnaKodu { get; set; }
    public string IstisnaAdi { get; set; } = "";
    public string TevkifatKodu { get; set; } = "";
    public string TevkifatAdi { get; set; } = "";
    public decimal TevkifatOran { get; set; }
    public decimal Tevkifat { get; set; }
    // ihracat (belge_efatura_satir)
    public string Gtip { get; init; } = "";
    public string TeslimSarti { get; init; } = "";
    public int TasimaSekli { get; init; }
    public string KapCinsi { get; init; } = "";
    public string KapNo { get; init; } = "";
    public decimal KapAdet { get; init; }
}

/// <summary>KDV oran grubu (taxSubTotal).</summary>
public sealed record VergiGrubu(int Oran, decimal Matrah, decimal Vergi, int IstisnaKodu, string IstisnaAdi);

/// <summary>Tevkifat oran grubu (withHoldingTax.taxSubTotal). Matrah = KDV TUTARI.</summary>
public sealed record TevkifatGrubu(string Kod, string Ad, decimal Oran, decimal Kdv, decimal Tevkifat);

/// <summary>
/// e-FATURA VERİSİ: belge + taraflar + satırlar + hesaplanmış toplamlar.
/// Delphi VerileriOku (sp_Prog_EBelge_GidenFatura + Detay) karşılığı. Hem
/// izibiz JSON'u hem UBL bunun üzerinden üretilir - iki çıktı aynı rakamları
/// görür.
/// </summary>
public sealed class EFaturaVerisi
{
    public int Id { get; init; }
    public int Tur { get; init; }
    public int Tipi { get; init; }
    public int Senaryo { get; init; }
    public int Durum { get; init; }
    public int EfaturaDurum { get; init; }
    public int EfaturaSonuc { get; init; }
    public int SubeId { get; init; }
    public int TarafId { get; init; }
    public string BelgeNo { get; init; } = "";
    public DateTime Tarih { get; init; }
    public string Aciklama { get; init; } = "";
    public string ParaKodu { get; init; } = "TRY";
    public decimal Kur { get; init; }
    public bool Dovizli => ParaKodu != "TRY";
    public decimal BelgeKdv { get; init; }
    public decimal BelgeToplam { get; init; }
    public string IrsaliyeNo { get; init; } = "";
    public DateTime? IrsaliyeTarihi { get; init; }
    public int IadeBelgeId { get; init; }

    public EFaturaTaraf Gonderici { get; init; } = null!;
    public EFaturaTaraf Alici { get; init; } = null!;
    public string GondericiAlias { get; init; } = "";

    // e-Fatura bilgileri (belge_efatura)
    public int TevkifatKodu { get; init; }
    public int IstisnaKodu { get; init; }
    public decimal Navlun { get; init; }
    public decimal Sigorta { get; init; }
    public string SgkTip { get; init; } = "";
    public string SgkMukellefKod { get; init; } = "";
    public string SgkMukellefAd { get; init; } = "";
    public string SgkDosyaNo { get; init; } = "";
    public DateTime? SgkDonemBas { get; init; }
    public DateTime? SgkDonemBit { get; init; }
    public string KamuIban { get; init; } = "";
    public string KamuBanka { get; init; } = "";
    public string KamuSube { get; init; } = "";

    // e-İRSALİYE SEVKİYATI (belge_sevkiyat; Delphi TSevkBilgisi). Sevk zamanı = irsaliye_tarihi.
    public string Plaka { get; init; } = "";
    public string SoforAd { get; init; } = "";
    public string SoforTckn { get; init; } = "";
    public string TasiyiciUnvan { get; init; } = "";
    public string TasiyiciVkno { get; init; } = "";
    public bool Irsaliye => EFaturaKodlari.IrsaliyeMi(Tur);

    // Son e_belge kaydı (giden)
    public long EBelgeId { get; set; }
    public short ETur { get; set; }
    public string Uuid { get; set; } = "";
    public string EBelgeNo { get; set; } = "";
    public string AliciAlias { get; set; } = "";

    public List<EFaturaSatiri> Satirlar { get; } = [];
    public List<(string No, DateTime Tarih)> IadeReferanslari { get; } = [];
    public List<(string No, DateTime Tarih)> SiparisReferanslari { get; } = [];

    // Hesap (Hesapla() doldurur)
    public decimal Brut { get; private set; }
    public decimal Net { get; private set; }
    public decimal Iskonto { get; private set; }
    public decimal Kdv { get; private set; }
    public decimal Tevkifat { get; private set; }
    public decimal Odenecek { get; private set; }
    public List<VergiGrubu> VergiGruplari { get; } = [];
    public List<TevkifatGrubu> TevkifatGruplari { get; } = [];

    public bool Arsiv => ETur == EFaturaKodlari.TurEArsiv;
    public string Profil => Irsaliye ? "TEMELIRSALIYE" : EFaturaKodlari.Profil(Arsiv, Senaryo);
    public string FaturaTipi => Irsaliye ? "SEVK" : EFaturaKodlari.FaturaTipi(Tipi, Profil);
    /// <summary>Sevk zamanı: irsaliyenin sevk tarihi, yoksa belge tarihi.</summary>
    public DateTime SevkZamani => IrsaliyeTarihi ?? Tarih;
    public bool IhracKayitli => Tipi == 9;

    /// <summary>
    /// TOPLAMLAR - Delphi _IzibizJSONOlustur'un hesap kuralları:
    /// KDV oran grubu (oran + sıfır/sıfır değil); KDV'si sıfır grup ve İhraç
    /// Kayıtlı'da istisna kodu ZORUNLU; tevkifat matrahı KDV tutarı;
    /// ödenecek = net + KDV − tevkifat (İhraç Kayıtlı'da yalnız net); toplam
    /// KDV ve ödenecek, belgenin kendi değerinden 2 kuruştan az sapıyorsa
    /// belgeninkine eşitlenir (GİB toplam uyuşmazlığını reddeder).
    /// </summary>
    public void Hesapla()
    {
        Brut = Satirlar.Sum(s => s.Brut);
        Net = Satirlar.Sum(s => s.Net);
        Iskonto = Satirlar.Sum(s => s.Iskonto);
        Kdv = Satirlar.Sum(s => s.Kdv);
        Tevkifat = Satirlar.Sum(s => s.Tevkifat);
        if (!Dovizli && Math.Abs(Kdv - BelgeKdv) < 0.02m) Kdv = BelgeKdv;

        VergiGruplari.Clear();
        foreach (var g in Satirlar.GroupBy(s => (s.KdvOran, Sifir: s.Kdv == 0)).OrderBy(g => g.Key.KdvOran))
        {
            var ilk = g.FirstOrDefault(s => s.IstisnaKodu > 0) ?? g.First();
            VergiGruplari.Add(new VergiGrubu(g.Key.KdvOran, g.Sum(s => s.Net), g.Sum(s => s.Kdv),
                                             ilk.IstisnaKodu, ilk.IstisnaAdi));
        }

        TevkifatGruplari.Clear();
        foreach (var g in Satirlar.Where(s => s.Tevkifat > 0).GroupBy(s => (s.TevkifatKodu, s.TevkifatOran)))
            TevkifatGruplari.Add(new TevkifatGrubu(g.Key.TevkifatKodu, g.First().TevkifatAdi, g.Key.TevkifatOran,
                                                   g.Sum(s => s.Kdv), g.Sum(s => s.Tevkifat)));

        Odenecek = IhracKayitli ? Net : Net + Kdv - Tevkifat;
        if (!Dovizli && Math.Abs(Odenecek - BelgeToplam) < 0.02m && !IhracKayitli && Tevkifat == 0)
            Odenecek = BelgeToplam;
    }

    /// <summary>
    /// DOĞRULAMA - numara/seri TÜKETİLMEDEN önce (Delphi MenuHazirla adım 1).
    /// Eksiklerin hepsi tek mesajda döner: kullanıcı tek tek düzeltip beş kez
    /// denemesin.
    /// </summary>
    public List<string> Eksikler()
    {
        var e = new List<string>();
        if (!EFaturaKodlari.EBelgeMi(Tur)) e.Add("e-Belge yalnız satış faturasında / satış irsaliyesinde kesilir.");
        if (Durum == 2) e.Add("Belge iptal edilmiş.");
        if (Irsaliye) return IrsaliyeEksikleri(e);
        if (TarafId == 0) e.Add("Belgede cari / hasta seçilmemiş.");
        var vkn = EFaturaKodlari.Rakam(Alici.Vkno);
        if (Senaryo != 3 && vkn.Length is not (10 or 11))
            e.Add($"{Alici.Unvan}: vergi / kimlik numarası 10 ya da 11 hane olmalı.");
        if (Satirlar.Count == 0) e.Add("Belgede kalem yok.");
        if (Net <= 0 && Tipi != 2) e.Add("Belge tutarı sıfır.");
        if (string.IsNullOrWhiteSpace(Gonderici.Unvan) || EFaturaKodlari.Rakam(Gonderici.Vkno).Length is not (10 or 11))
            e.Add("Firma (şube) ünvanı / vergi numarası eksik: Yönetim › Firma Bilgileri.");
        if (Dovizli && Kur <= 0) e.Add($"Dövizli belgede ({ParaKodu}) kur girilmemiş.");

        // KDV'SİZ GRUP: istisna kodu zorunlu - 351'e sessiz düşüş YOK (Delphi 10.2026).
        if (Satirlar.Any(s => s.Kdv == 0 && s.IstisnaKodu == 0) || (IhracKayitli && IstisnaKodu == 0))
            e.Add(IhracKayitli
                ? "İhraç kayıtlı faturada muafiyet kodu (701-704) seçilmemiş: e-Fatura Bilgileri."
                : "KDV'si sıfır olan kalem var; KDV istisna nedeni seçilmemiş: e-Fatura Bilgileri.");

        switch (Tipi)
        {
            case 22 when TevkifatKodu == 0 && Satirlar.All(s => s.TevkifatKodu.Length == 0):
                e.Add("Tevkifatlı faturada tevkifat kodu seçilmemiş: e-Fatura Bilgileri.");
                break;
            case 22 when Tevkifat <= 0:
                e.Add("Tevkifat tutarı sıfır: tevkifat yalnız KDV'li kalemlere uygulanır.");
                break;
            case 24 when IstisnaKodu == 0:
                e.Add("KDV istisna faturasında istisna kodu seçilmemiş: e-Fatura Bilgileri.");
                break;
            case 2 when IadeReferanslari.Count == 0:
                e.Add("İade faturasında iade edilen fatura seçilmemiş (GİB referanssız iadeyi reddeder).");
                break;
            case 25:
                if (Senaryo is not (0 or 1)) e.Add("SGK faturası yalnız Temel Fatura senaryosunda kesilir.");
                if (SgkTip.Length == 0) e.Add("SGK ilave fatura tipi seçilmemiş.");
                if (SgkMukellefKod.Length == 0 || SgkMukellefAd.Length == 0) e.Add("SGK mükellef kodu / adı girilmemiş.");
                if (SgkDosyaNo.Length == 0) e.Add("SGK dosya numarası girilmemiş.");
                if (SgkDonemBas is null || SgkDonemBit is null) e.Add("SGK fatura dönemi girilmemiş.");
                break;
        }

        if (Senaryo == 7)
        {
            if (Alici.Adres.Length == 0 || Alici.Il.Length == 0) e.Add("Kamu faturasında alıcı adresi / ili eksik.");
            if (!IbanGecerli(KamuIban)) e.Add("Kamu faturasında geçerli bir TR IBAN seçilmemiş: e-Fatura Bilgileri.");
        }

        if (Senaryo == 3)
        {
            if (Alici.Unvan.Length == 0) e.Add("İhracat faturasında alıcı ünvanı eksik.");
            foreach (var s in Satirlar)
            {
                var eks = new List<string>();
                if (s.TeslimSarti.Length == 0) eks.Add("teslim şartı");
                if (s.TasimaSekli == 0) eks.Add("taşıma şekli");
                if (s.KapCinsi.Length == 0) eks.Add("kap cinsi");
                if (EFaturaKodlari.Rakam(s.Gtip).Length != 12) eks.Add("12 haneli GTİP");
                if (eks.Count > 0) e.Add($"{s.No}. kalem ({s.Ad}): {string.Join(", ", eks)} eksik.");
            }
        }
        return e;
    }

    /// <summary>
    /// e-İRSALİYE DOĞRULAMASI (Delphi SevkBilgisiDogrula): vergi / tevkifat / istisna
    /// kuralları uygulanmaz; taşıma sorumlusu ZORUNLU - ya taşıyıcı (ünvan + vergi no)
    /// ya şoför (ad soyad + TC no). Plaka zorunlu değil.
    /// </summary>
    private List<string> IrsaliyeEksikleri(List<string> e)
    {
        if (TarafId == 0) e.Add("İrsaliyede cari seçilmemiş.");
        if (EFaturaKodlari.Rakam(Alici.Vkno).Length is not (10 or 11))
            e.Add($"{Alici.Unvan}: vergi / kimlik numarası 10 ya da 11 hane olmalı.");
        if (Alici.Il.Length == 0) e.Add("Teslimat adresinde il eksik (cari kartı adresi).");
        if (Satirlar.Count == 0) e.Add("İrsaliyede kalem yok.");
        if (Satirlar.Any(s => s.Miktar <= 0)) e.Add("Miktarı sıfır olan kalem var.");
        if (string.IsNullOrWhiteSpace(Gonderici.Unvan) || EFaturaKodlari.Rakam(Gonderici.Vkno).Length is not (10 or 11))
            e.Add("Firma (şube) ünvanı / vergi numarası eksik: Yönetim › Firma Bilgileri.");
        var tasiyiciTam = TasiyiciUnvan.Length > 0 && EFaturaKodlari.Rakam(TasiyiciVkno).Length is 10 or 11;
        var soforTam = SoforAd.Trim().Length > 0 && EFaturaKodlari.Rakam(SoforTckn).Length == 11;
        if (!tasiyiciTam && !soforTam)
            e.Add("Sevk bilgisi eksik (Taşıma sekmesi): taşıyıcı firma (ünvan + vergi no) YA DA şoför (ad soyad + 11 haneli TC no) girilmeli.");
        return e;
    }

    /// <summary>TR IBAN mod-97 (Delphi KamuFaturaHazirlikDogrula).</summary>
    public static bool IbanGecerli(string iban)
    {
        var i = new string((iban ?? "").Where(c => !char.IsWhiteSpace(c)).ToArray()).ToUpperInvariant();
        if (i.Length != 26 || !i.StartsWith("TR")) return false;
        var d = i[4..] + i[..4];
        var kalan = 0;
        foreach (var c in d)
        {
            var v = char.IsDigit(c) ? c - '0' : char.IsLetter(c) ? c - 'A' + 10 : -1;
            if (v < 0) return false;
            kalan = v >= 10 ? (kalan * 100 + v) % 97 : (kalan * 10 + v) % 97;
        }
        return kalan == 1;
    }

    // -------------------------------------------------------------- okuma ----
    public static async Task<EFaturaVerisi> OkuAsync(NpgsqlConnection b, NpgsqlTransaction? tx,
                                                     int belgeId, CancellationToken iptal)
    {
        var dilim = Saat.Dilim(null);
        DateTime Yerel(DateTime d) => d.Kind == DateTimeKind.Utc ? TimeZoneInfo.ConvertTimeFromUtc(d, dilim) : d;

        var v = await b.TekAsync("""
            select bl.id, bl.tur, bl.tipi, coalesce(bl.senaryo, 0) senaryo, bl.durum,
                   coalesce(bl.efatura_durum, 0) efatura_durum, coalesce(bl.efatura_sonuc, 0) efatura_sonuc,
                   coalesce(nullif(bl.sube_id, 0), (select s.id from public.sube s where s.varsayilan = 1
                                                     and s.aktif = 1 order by s.id limit 1)) sube_id,
                   coalesce(bl.taraf_id, 0) taraf_id, coalesce(bl.belge_no, '') belge_no, bl.belge_tarihi,
                   coalesce(bl.aciklama, '') aciklama,
                   coalesce(nullif(bl.belge_dovizi, ''), bl.doviz_cinsi, '') doviz,
                   coalesce(bl.doviz_kuru, 0) kur, coalesce(bl.kdv_tutari, 0) kdv, coalesce(bl.genel_toplam, 0) toplam,
                   coalesce(bl.irsaliye_no, '') irsaliye_no, bl.irsaliye_tarihi, coalesce(bl.iade_belge_id, 0) iade_belge_id,
                   coalesce(bl.taraf_unvan, '') taraf_unvan, coalesce(bl.taraf_vkno, '') taraf_vkno,
                   coalesce(bl.taraf_vd, '') taraf_vd, coalesce(bl.taraf_adres, '') taraf_adres,
                   coalesce(bl.taraf_ilce, '') taraf_ilce, coalesce(bl.taraf_il, '') taraf_il,
                   coalesce(ta.ulke, '') taraf_ulke, coalesce(ta.posta_kodu, '') taraf_posta,
                   coalesce(nullif(ta.eposta, ''), t.eposta, '') taraf_eposta,
                   coalesce(nullif(ta.telefon, ''), nullif(t.cep_tel, ''), t.telefon, '') taraf_tel,
                   coalesce(ef.tevkifat_kodu, 0) tevkifat_kodu, coalesce(ef.istisna_kodu, 0) istisna_kodu,
                   coalesce(ef.navlun, 0) navlun, coalesce(ef.sigorta, 0) sigorta,
                   coalesce(ef.sgk_tip, '') sgk_tip, coalesce(ef.sgk_mukellef_kod, '') sgk_mukellef_kod,
                   coalesce(ef.sgk_mukellef_ad, '') sgk_mukellef_ad, coalesce(ef.sgk_dosya_no, '') sgk_dosya_no,
                   ef.sgk_donem_bas, ef.sgk_donem_bit,
                   coalesce(h.iban, '') kamu_iban, coalesce(h.banka_adi, '') kamu_banka, coalesce(h.banka_subesi, '') kamu_sube,
                   coalesce(sv.arac_plaka, '') plaka, coalesce(sv.sofor_ad, '') sofor_ad, coalesce(sv.sofor_tckn, '') sofor_tckn,
                   coalesce(nullif(btrim(tt.unvan), ''), btrim(coalesce(tt.ad, '') || ' ' || coalesce(tt.soyad, '')), '') tasiyici_unvan, coalesce(tt.vkno, '') tasiyici_vkno
              from public.belge bl
              left join public.taraf t on t.id = bl.taraf_id
              left join public.taraf_adres ta on ta.id = coalesce(bl.taraf_adres_id,
                        (select a.id from public.taraf_adres a where a.taraf_id = bl.taraf_id
                          order by a.varsayilan desc, a.id limit 1))
              left join public.belge_efatura ef on ef.belge_id = bl.id
              left join public.hesap h on h.id = ef.kamu_hesap_id
              left join public.belge_sevkiyat sv on sv.id = bl.id
              left join public.taraf tt on tt.id = sv.tasiyici_id
             where bl.id = @p0
            """, tx, [belgeId], o => new EFaturaVerisi
        {
            Id = o.Sayi("id"), Tur = o.Sayi("tur"), Tipi = o.Sayi("tipi"), Senaryo = o.Sayi("senaryo"),
            Durum = o.Sayi("durum"), EfaturaDurum = o.Sayi("efatura_durum"), EfaturaSonuc = o.Sayi("efatura_sonuc"),
            SubeId = o.Sayi("sube_id"), TarafId = o.Sayi("taraf_id"), BelgeNo = o.Metin("belge_no").Trim(),
            Tarih = Yerel(o.Tarih("belge_tarihi") ?? DateTime.UtcNow), Aciklama = o.Metin("aciklama").Trim(),
            ParaKodu = EFaturaKodlari.ParaKodu(o.Metin("doviz")), Kur = Ondalik(o, "kur"),
            BelgeKdv = Math.Round(Ondalik(o, "kdv"), 2), BelgeToplam = Math.Round(Ondalik(o, "toplam"), 2),
            IrsaliyeNo = o.Metin("irsaliye_no").Trim(),
            IrsaliyeTarihi = o.Tarih("irsaliye_tarihi") is { } it ? Yerel(it) : null,
            IadeBelgeId = o.Sayi("iade_belge_id"),
            Alici = new EFaturaTaraf(o.Metin("taraf_unvan").Trim(), o.Metin("taraf_vkno").Trim(), o.Metin("taraf_vd").Trim(),
                                     o.Metin("taraf_adres").Trim(), o.Metin("taraf_ilce").Trim(), o.Metin("taraf_il").Trim(),
                                     o.Metin("taraf_ulke").Trim(), o.Metin("taraf_posta").Trim(),
                                     o.Metin("taraf_eposta").Trim(), o.Metin("taraf_tel").Trim()),
            TevkifatKodu = o.Sayi("tevkifat_kodu"), IstisnaKodu = o.Sayi("istisna_kodu"),
            Navlun = Ondalik(o, "navlun"), Sigorta = Ondalik(o, "sigorta"),
            SgkTip = o.Metin("sgk_tip"), SgkMukellefKod = o.Metin("sgk_mukellef_kod").Trim(),
            SgkMukellefAd = o.Metin("sgk_mukellef_ad").Trim(), SgkDosyaNo = o.Metin("sgk_dosya_no").Trim(),
            SgkDonemBas = o.Tarih("sgk_donem_bas"), SgkDonemBit = o.Tarih("sgk_donem_bit"),
            KamuIban = o.Metin("kamu_iban").Replace(" ", ""), KamuBanka = o.Metin("kamu_banka"), KamuSube = o.Metin("kamu_sube"),
            Plaka = o.Metin("plaka").Replace(" ", "").ToUpperInvariant(), SoforAd = o.Metin("sofor_ad").Trim(),
            SoforTckn = o.Metin("sofor_tckn").Trim(), TasiyiciUnvan = o.Metin("tasiyici_unvan").Trim(),
            TasiyiciVkno = o.Metin("tasiyici_vkno").Trim(),
            Gonderici = null!,
        }, iptal) ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

        // SATICI: şubenin e-Belge kimliği (v_ebelge_gonderici - merkez kimliğini kullanan şube dahil).
        var (gonderici, gAlias) = await b.TekAsync("""
            select coalesce(unvan, '') unvan, coalesce(vkno, '') vkno, coalesce(vergi_dairesi, '') vd,
                   coalesce(adres, '') adres, coalesce(ilce, '') ilce, coalesce(il, '') il, coalesce(ulke, '') ulke,
                   coalesce(posta_kodu, '') posta, coalesce(eposta, '') eposta, coalesce(telefon, '') tel,
                   coalesce(web, '') web, coalesce(mersis_no, '') mersis, coalesce(ticaret_sicil_no, '') sicil,
                   coalesce(gonderici_alias, '') alias
              from public.v_ebelge_gonderici where sube_id = @p0
            """, tx, [v.SubeId], o => new Tuple<EFaturaTaraf, string>(new EFaturaTaraf(
                o.Metin("unvan").Trim(), o.Metin("vkno").Trim(), o.Metin("vd").Trim(), o.Metin("adres").Trim(),
                o.Metin("ilce").Trim(), o.Metin("il").Trim(), o.Metin("ulke").Trim(), o.Metin("posta").Trim(),
                o.Metin("eposta").Trim(), o.Metin("tel").Trim(), o.Metin("web").Trim(), o.Metin("mersis").Trim(),
                o.Metin("sicil").Trim()), o.Metin("alias").Trim()), iptal)
            ?? new Tuple<EFaturaTaraf, string>(new EFaturaTaraf("", "", "", "", "", "", "", "", "", ""), "");
        var veri = new EFaturaVerisi
        {
            Id = v.Id, Tur = v.Tur, Tipi = v.Tipi, Senaryo = v.Senaryo, Durum = v.Durum,
            EfaturaDurum = v.EfaturaDurum, EfaturaSonuc = v.EfaturaSonuc, SubeId = v.SubeId, TarafId = v.TarafId,
            BelgeNo = v.BelgeNo, Tarih = v.Tarih, Aciklama = v.Aciklama, ParaKodu = v.ParaKodu, Kur = v.Kur,
            BelgeKdv = v.BelgeKdv, BelgeToplam = v.BelgeToplam, IrsaliyeNo = v.IrsaliyeNo,
            IrsaliyeTarihi = v.IrsaliyeTarihi, IadeBelgeId = v.IadeBelgeId, Alici = v.Alici,
            Gonderici = gonderici, GondericiAlias = gAlias,
            TevkifatKodu = v.TevkifatKodu, IstisnaKodu = v.IstisnaKodu, Navlun = v.Navlun, Sigorta = v.Sigorta,
            SgkTip = v.SgkTip, SgkMukellefKod = v.SgkMukellefKod, SgkMukellefAd = v.SgkMukellefAd,
            SgkDosyaNo = v.SgkDosyaNo, SgkDonemBas = v.SgkDonemBas, SgkDonemBit = v.SgkDonemBit,
            KamuIban = v.KamuIban, KamuBanka = v.KamuBanka, KamuSube = v.KamuSube,
            Plaka = v.Plaka, SoforAd = v.SoforAd, SoforTckn = v.SoforTckn,
            TasiyiciUnvan = v.TasiyiciUnvan, TasiyiciVkno = v.TasiyiciVkno,
        };

        // Son giden e_belge kaydı.
        await using (var k = b.Komut("""
            select id, belge_turu, coalesce(uuid, '') uuid, coalesce(belge_no, '') belge_no, coalesce(alici_alias, '') alias
              from public.e_belge where belge_id = @p0 and yon = 1 order by id desc limit 1
            """, tx, belgeId))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            if (await o.ReadAsync(iptal))
            {
                veri.EBelgeId = o.GetInt64(0); veri.ETur = o.GetInt16(1); veri.Uuid = o.GetString(2);
                veri.EBelgeNo = o.GetString(3); veri.AliciAlias = o.GetString(4);
            }

        // Kod adları (istisna / tevkifat / ihraç kayıtlı).
        var adlar = await b.ListeAsync("""
            select l.kod, d.deger, d.ad from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
             where l.kod in ('belge.tevkifat', 'belge.kdv_muafiyeti', 'belge.ihrac_kayitli') and d.dil = 0
            """, tx, null, o => (Liste: o.GetString(0), Kod: o.GetInt32(1), Ad: o.GetString(2)), iptal);
        string Ad(string liste, int kod) => adlar.FirstOrDefault(x => x.Liste == liste && x.Kod == kod).Ad ?? kod.ToString();

        // SATIRLAR. Dövizli belgede satır döviz fiyat/tutarıyla gider (Delphi EBELGEBIRIMFIYAT/EBELGETUTAR).
        var satirlar = await b.ListeAsync("""
            select s.id, coalesce(nullif(btrim(s.aciklama), ''), st.ad, hz.ad, 'Kalem') ad,
                   coalesce(st.kod, hz.kod, '') stok_kod, coalesce(s.izleme_kodu, '') lot,
                   coalesce(s.miktar, 0) miktar, coalesce(s.birim, 0) birim,
                   coalesce(s.birim_fiyat, 0) fiyat, coalesce(s.tutar, 0) tutar,
                   coalesce(s.doviz_birim_fiyat, 0) dfiyat, coalesce(s.doviz_tutari, 0) dtutar,
                   coalesce(s.kdv, 0) kdv, coalesce(s.kdv_muafiyeti, 0) muafiyet,
                   coalesce(btrim(s.tevkifat_kodu), '') tev_kod, coalesce(s.tevkifat_orani, 0) tev_oran,
                   coalesce(nullif(es.gtip, ''), st.gtip_kodu, '') gtip, coalesce(es.teslim_sarti, '') teslim,
                   coalesce(es.tasima_sekli, 0) tasima, coalesce(es.kap_cinsi, '') kap, coalesce(es.kap_no, '') kap_no,
                   coalesce(es.kap_adet, 0) kap_adet
              from public.belge_satir s
              left join public.stok st on st.id = s.stok_id
              left join public.hizmet hz on hz.id = s.hizmet_id
              left join public.belge_efatura_satir es on es.satir_id = s.id
             where s.belge_id = @p0
             order by s.sira, s.id
            """, tx, [belgeId], o => o.Sozluk(), iptal);

        var no = 0;
        foreach (var s in satirlar)
        {
            decimal D(string a) => Convert.ToDecimal(s[a] ?? 0m);
            var miktar = D("miktar");
            var fiyat = veri.Dovizli && D("dfiyat") != 0 ? D("dfiyat") : D("fiyat");
            var net = Math.Round(veri.Dovizli && D("dtutar") != 0 ? D("dtutar") : D("tutar"), 2);
            var brut = Math.Round(miktar * fiyat, 2);
            if (brut < net) brut = net;
            var oran = Convert.ToInt32(s["kdv"]);
            var kdv = Math.Round(net * oran / 100m, 2, MidpointRounding.AwayFromZero);

            var satir = new EFaturaSatiri
            {
                Id = Convert.ToInt32(s["id"]), No = ++no, Ad = (string)s["ad"]!, StokKodu = (string)s["stok_kod"]!,
                LotNo = (string)s["lot"]!, Miktar = miktar, BirimKodu = EFaturaKodlari.BirimKodu(Convert.ToInt32(s["birim"])),
                Fiyat = fiyat, Brut = brut, Net = net, KdvOran = oran, Kdv = kdv,
                Gtip = EFaturaKodlari.Rakam((string?)s["gtip"]), TeslimSarti = (string)s["teslim"]!,
                TasimaSekli = Convert.ToInt32(s["tasima"]), KapCinsi = (string)s["kap"]!, KapNo = (string)s["kap_no"]!,
                KapAdet = D("kap_adet"),
            };

            // ISTISNA: KDV'si sıfır kalem ya da İhraç Kayıtlı. Öncelik başlık kodu
            //   (istisna / ihraç kayıtlı faturası), sonra satırın kendi kodu;
            //   ihracat senaryosunda varsayılan 301 (Delphi IhracatBilgisiOku).
            if (kdv == 0 || veri.IhracKayitli)
            {
                var kod = veri.IhracKayitli || veri.Tipi == 24 ? veri.IstisnaKodu : 0;
                if (kod == 0) kod = Convert.ToInt32(s["muafiyet"]);
                if (kod == 0) kod = veri.IstisnaKodu;
                if (kod == 0 && veri.Senaryo == 3) kod = 301;
                satir.IstisnaKodu = kod;
                if (kod > 0) satir.IstisnaAdi = Ad(kod is >= 701 and <= 704 ? "belge.ihrac_kayitli" : "belge.kdv_muafiyeti", kod);
            }

            // TEVKIFAT: yalnız tevkifatlı faturada ve KDV'li kalemde. Satır kodu
            //   başlığı ezer; oran KODDAN (elle girilen oran koda uymazsa GİB reddeder).
            if (veri.Tipi == 22 && kdv > 0)
            {
                var kod = (string)s["tev_kod"]! is { Length: > 0 } sk ? sk
                          : veri.TevkifatKodu > 0 ? veri.TevkifatKodu.ToString() : "";
                if (kod.Length > 0)
                {
                    var adi = Ad("belge.tevkifat", int.Parse(kod));
                    var oranT = D("tev_oran") > 0 ? D("tev_oran") : TevkifatOrani(adi);
                    satir.TevkifatKodu = kod; satir.TevkifatAdi = adi; satir.TevkifatOran = oranT;
                    satir.Tevkifat = Math.Round(kdv * oranT / 100m, 2, MidpointRounding.AwayFromZero);
                }
            }
            veri.Satirlar.Add(satir);
        }

        // IADE REFERANSI (Delphi IadeReferanslariGetir): iade edilen faturanın no+tarihi.
        if (veri.Tipi == 2)
            veri.IadeReferanslari.AddRange(await b.ListeAsync("""
                select coalesce(nullif(e.belge_no, ''), o.belge_no, '') no, o.belge_tarihi
                  from public.belge o
                  left join lateral (select x.belge_no from public.e_belge x
                                      where x.belge_id = o.id and x.yon = 1 order by x.id desc limit 1) e on true
                 where o.id = @p0 or o.id in (select distinct ks.belge_id from public.belge_satir hs
                                               join public.belge_satir ks on ks.id = hs.kaynak_id
                                              where hs.belge_id = @p1 and ks.belge_id <> @p1
                                                and (select tur from public.belge where id = ks.belge_id) = 15)
                """, tx, [veri.IadeBelgeId, belgeId],
                o => (o.GetString(0).Trim(), Yerel(o.GetDateTime(1))), iptal));

        veri.Hesapla();
        return veri;
    }

    /// <summary>"... (9/10)" -> 90. Delphi: oran kodun resmi oranı.</summary>
    public static decimal TevkifatOrani(string ad)
    {
        var m = System.Text.RegularExpressions.Regex.Match(ad ?? "", @"\((\d+)/10\)\s*$");
        return m.Success ? int.Parse(m.Groups[1].Value) * 10 : 0;
    }

    private static decimal Ondalik(NpgsqlDataReader o, string alan)
    {
        var i = o.GetOrdinal(alan);
        return o.IsDBNull(i) ? 0 : Convert.ToDecimal(o.GetValue(i));
    }
}
