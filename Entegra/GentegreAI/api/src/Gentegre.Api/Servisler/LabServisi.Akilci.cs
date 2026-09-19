using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// AKILCI TEST İSTEMİ (873) — Bakanlık EK-2 iş kuralı kılavuzu.
///
/// Beş kural, hepsi SUNUCUDA: istemci yalnız hekimin kararını (gerekçe
/// kodu) taşır; kuralın kendisi <c>lab_akilci_kural</c> + <c>fn_lab_akilci_kontrol</c>.
/// <list type="bullet">
///   <item><b>Engel</b> (kapalı test, basamak): istem açılmaz; 422
///   <c>AKILCI_ENGEL</c>, gövdede hangi tetkik ve neden.</item>
///   <item><b>Uyarı</b> (branş, tekrar süresi): hekim SKRS gerekçe koduyla
///   geçer; gerekçesiz gelirse 422 <c>AKILCI_UYARI</c> + uyarı listesi +
///   gerekçe seçenekleri, istemci diyaloğu çizer ve kararla tekrar gönderir.
///   Her karar (devam / iptal) <c>lab_akilci_gerekce</c>'ye yazılır - Bakanlık
///   bu kayıtları analiz eder (§4.5-4.6).</item>
///   <item><b>Refleks</b> (§6): sonuç yazılınca <c>lab_refleks_kural</c>
///   koşulu tutarsa hedef tetkik aynı isteme, aynı numuneye eklenir
///   (<c>kaynak_turu 1</c>).</item>
///   <item><b>Reflektif</b> (§7): lab uzmanı (<c>lab.onay</c>) sonuç sonrası
///   ek tetkik ister; <c>kaynak_turu 2</c>, karar kaydı 'reflektif'.</item>
/// </list>
/// Banko / başvuru ücretinden açılan istem (hekim yok, ekran yok) SESSİZ
/// çalışır: engelli tetkik atlanır ve iptal kaydı düşer, uyarılar "otomatik"
/// notuyla devam kaydına yazılır - hekim istemi değil, kayıt kabul kalemi.
/// </summary>
public sealed partial class LabServisi
{
    /// <summary>Hekimin bir uyarı için kararı. Kural: sure | brans. Gerekçe kodu SKRS listesinden.</summary>
    public sealed record AkilciKarar(int TetkikId, string Kural, short? GerekceKod, string? Aciklama = null);

    public sealed record AkilciUyari(
        int TetkikId, int HizmetId, string SutKodu, string Ad, string Kural, string Seviye, string Mesaj,
        int SureGun, DateTime? SonTarih, int? KalanGun, JsonElement? Sonuclar, string HekimBrans,
        string BransKodlari, string Bayraklar, string SureNotu);

    public sealed record GerekceSecenegi(short Kod, string Ad);

    public sealed record AkilciKontrolSonucu(
        IReadOnlyList<AkilciUyari> Uyarilar, IReadOnlyList<GerekceSecenegi> Gerekceler,
        IReadOnlyList<GerekceSecenegi> KlinikGerekceler, short Basamak);

    public const string EngelKodu = "AKILCI_ENGEL";
    public const string UyariKodu = "AKILCI_UYARI";

    // ---------------------------------------------------------- kontrol --
    public async Task<AkilciKontrolSonucu> AkilciKontrolAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int hastaId, int? hekimId, int subeId,
        IReadOnlyList<int> tetkikIdler, CancellationToken iptal)
    {
        if (tetkikIdler.Count == 0)
            return new([], [], [], 0);

        var uyarilar = await baglanti.ListeAsync("""
            select tetkik_id, hizmet_id, sut_kodu, ad, kural, seviye, mesaj, sure_gun, son_tarih,
                   kalan_gun, sonuclar::text, coalesce(hekim_brans, ''), brans_kodlari, bayraklar, sure_notu
              from public.fn_lab_akilci_kontrol(@p0, @p1, @p2, @p3)
            """, islem, [hastaId, hekimId is > 0 ? hekimId : null, subeId, tetkikIdler.ToArray()],
            o => new AkilciUyari(
                o.GetInt32(0), o.GetInt32(1), o.GetString(2), o.GetString(3), o.GetString(4),
                o.GetString(5), o.GetString(6), o.GetInt32(7),
                o.IsDBNull(8) ? null : o.GetDateTime(8),
                o.IsDBNull(9) ? null : o.GetInt32(9),
                o.IsDBNull(10) ? null : JsonDocument.Parse(o.GetString(10)).RootElement,
                o.GetString(11), o.GetString(12), o.GetString(13), o.GetString(14)), iptal);

        var gerekceler = await GerekcelerAsync(baglanti, islem, "lab.akilci_gerekce", iptal);
        var klinik = await GerekcelerAsync(baglanti, islem, "lab.akilci_klinik_gerekce", iptal);
        var basamak = await baglanti.TekDegerAsync<short>(
            "select public.fn_kurum_basamak(@p0)", islem, [subeId], iptal);
        return new(uyarilar, gerekceler, klinik, basamak);
    }

    private static async Task<List<GerekceSecenegi>> GerekcelerAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, string listeKodu, CancellationToken iptal)
        => await baglanti.ListeAsync("""
            select d.deger, d.ad from public.kod_deger d
              join public.kod_liste l on l.id = d.liste_id
             where l.kod = @p0 and d.dil = 0 and d.aktif = 1 order by d.sira, d.deger
            """, islem, [listeKodu], o => new GerekceSecenegi((short)o.GetInt32(0), o.GetString(1)), iptal);

    /// <summary>
    /// İstem açılmadan önce kuralları uygular. Sessiz kipte engelli tetkikleri
    /// döner (çağıran atlar); etkileşimli kipte engel/gerekçesiz uyarıda fırlatır.
    /// Kararlar istem yazıldıktan sonra <see cref="AkilciKararlariYazAsync"/> ile kalıcılaşır.
    /// </summary>
    private async Task<(HashSet<int> Atlanan, List<(AkilciUyari Uyari, AkilciKarar? Karar)> Kayitlar)>
        AkilciUygulaAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem, IstemKaynagi k,
                          IReadOnlyList<int> tetkikIdler, IReadOnlyList<AkilciKarar>? kararlar,
                          bool sessiz, CancellationToken iptal)
    {
        var sonuc = await AkilciKontrolAsync(baglanti, islem, k.HastaId, k.HekimId, k.SubeId,
                                             tetkikIdler, iptal);
        var atlanan = new HashSet<int>();
        var kayitlar = new List<(AkilciUyari, AkilciKarar?)>();
        if (sonuc.Uyarilar.Count == 0) return (atlanan, kayitlar);

        var engeller = sonuc.Uyarilar.Where(u => u.Seviye == "engel").ToList();
        if (engeller.Count > 0)
        {
            if (!sessiz)
                throw GentegreHatasi.IsKurali(
                    engeller[0].Mesaj + (engeller.Count > 1 ? $" (+{engeller.Count - 1} tetkik daha)" : ""),
                    new { kod = EngelKodu, tetkikler = engeller.Select(e => new { e.TetkikId, e.Ad, e.Kural, e.Mesaj }) });
            foreach (var e in engeller)
            {
                atlanan.Add(e.TetkikId);
                kayitlar.Add((e, new AkilciKarar(e.TetkikId, e.Kural, null, "otomatik: başvuru ücretinden açılan istem, engelli tetkik atlandı")));
            }
        }

        var uyarilar = sonuc.Uyarilar.Where(u => u.Seviye == "uyari" && !atlanan.Contains(u.TetkikId)).ToList();
        var eksik = new List<AkilciUyari>();
        foreach (var u in uyarilar)
        {
            var karar = kararlar?.FirstOrDefault(x => x.TetkikId == u.TetkikId
                                                      && string.Equals(x.Kural, u.Kural, StringComparison.OrdinalIgnoreCase));
            if (karar is null)
            {
                if (sessiz) kayitlar.Add((u, new AkilciKarar(u.TetkikId, u.Kural, null, "otomatik: başvuru ücretinden açılan istem")));
                else eksik.Add(u);
                continue;
            }
            // Gerekçe kodu SKRS listesinde olmalı: uydurma kod Bakanlık analizine gitmesin.
            var liste = u.Kural == "brans" ? sonuc.KlinikGerekceler : sonuc.Gerekceler;
            if (karar.GerekceKod is null || liste.All(g => g.Kod != karar.GerekceKod))
                throw GentegreHatasi.Dogrulama("Akılcı istem gerekçesi seçilmeli.",
                    [new AlanHatasi("akilci", $"{u.Ad}: geçerli bir gerekçe kodu verin.")]);
            kayitlar.Add((u, karar));
        }
        if (eksik.Count > 0)
            throw GentegreHatasi.IsKurali(
                eksik[0].Mesaj + (eksik.Count > 1 ? $" (+{eksik.Count - 1} uyarı daha)" : ""),
                new
                {
                    kod = UyariKodu,
                    uyarilar = eksik.Select(e => new
                    {
                        e.TetkikId, e.Ad, e.Kural, e.Mesaj, e.SureGun, e.SonTarih, e.KalanGun,
                        sonuclar = e.Sonuclar, e.HekimBrans, e.SureNotu, e.Bayraklar,
                    }),
                    gerekceler = sonuc.Gerekceler, klinikGerekceler = sonuc.KlinikGerekceler,
                });
        return (atlanan, kayitlar);
    }

    private static async Task AkilciKararlariYazAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int? istemId,
        IReadOnlyDictionary<int, int>? satirIdler, IstemKaynagi k,
        IEnumerable<(AkilciUyari Uyari, AkilciKarar? Karar)> kayitlar, IstekBaglami baglam,
        CancellationToken iptal)
    {
        foreach (var (u, karar) in kayitlar)
        {
            var devam = satirIdler is not null && satirIdler.ContainsKey(u.TetkikId);
            await baglanti.CalistirAsync("""
                insert into public.lab_akilci_gerekce
                       (istem_id, satir_id, hizmet_id, hasta_id, hekim_id, kural_turu, karar,
                        gerekce_kod, aciklama, son_sonuc_tarihi, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                """, islem,
                [istemId, devam ? satirIdler![u.TetkikId] : null, u.HizmetId, k.HastaId,
                 k.HekimId == 0 ? baglam.KullaniciId : k.HekimId, u.Kural, devam ? "devam" : "iptal",
                 karar?.GerekceKod, (karar?.Aciklama ?? "")[..Math.Min(300, (karar?.Aciklama ?? "").Length)],
                 u.SonTarih, k.SubeId, baglam.KullaniciId], iptal);
        }
    }

    /// <summary>
    /// Hekim uyarıya "Hayır" dedi: istem açılmadı ama karar KAYDEDİLİR (§4.6).
    /// İstemci tetkiği listeden çıkarır, bu uç yalnız izi düşer.
    /// </summary>
    public async Task AkilciVazgecAsync(int hastaId, int? hekimId, IReadOnlyList<AkilciKarar> kararlar,
                                       IstekBaglami baglam, CancellationToken iptal)
    {
        if (kararlar.Count == 0) return;
        await using var baglanti = await _veri.AcAsync(iptal);
        var k = new IstemKaynagi(hastaId, hekimId ?? baglam.KullaniciId, baglam.SubeId ?? 0);
        var sonuc = await AkilciKontrolAsync(baglanti, null, hastaId, k.HekimId, k.SubeId,
                                             kararlar.Select(x => x.TetkikId).Distinct().ToList(), iptal);
        var kayitlar = new List<(AkilciUyari, AkilciKarar?)>();
        foreach (var karar in kararlar)
        {
            var u = sonuc.Uyarilar.FirstOrDefault(x => x.TetkikId == karar.TetkikId
                                                       && string.Equals(x.Kural, karar.Kural, StringComparison.OrdinalIgnoreCase));
            if (u is not null) kayitlar.Add((u, karar with { Aciklama = karar.Aciklama ?? "hekim vazgeçti" }));
        }
        await AkilciKararlariYazAsync(baglanti, null, null, null, k, kayitlar, baglam, iptal);
    }

    // ---------------------------------------------------------- refleks --
    /// <summary>
    /// Sonuç yazıldı: kaynak tetkiğin refleks kuralları değerlendirilir, tutan
    /// hedef tetkik aynı isteme ve aynı numuneye eklenir (zaten varsa değil).
    /// Eklenen tetkik adlarını döner (mesaj için).
    /// </summary>
    private async Task<List<string>> RefleksUygulaAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, int istemId, int tetkikId, int? numuneId,
        int hastaId, int subeId, decimal? sayisal, string bayrak, IstekBaglami baglam, CancellationToken iptal)
    {
        var kurallar = await baglanti.ListeAsync("""
            select k.id, k.kosul, k.esik, k.hedef_tetkik_id, t.kod, t.ad, h.id
              from public.lab_refleks_kural k
              join public.lab_tetkik t on t.id = k.hedef_tetkik_id
              left join public.hizmet h on h.id = t.hizmet_id
             where k.tetkik_id = @p0 and k.aktif = 1 and (k.sube_id is null or k.sube_id = @p1)
            """, islem, [tetkikId, subeId],
            o => new { Id = o.GetInt32(0), Kosul = o.GetString(1),
                       Esik = o.IsDBNull(2) ? (decimal?)null : o.GetDecimal(2),
                       Hedef = o.GetInt32(3), Kod = o.GetString(4), Ad = o.GetString(5),
                       HizmetId = o.IsDBNull(6) ? 0 : o.GetInt32(6) }, iptal);
        var eklenen = new List<string>();
        foreach (var k in kurallar)
        {
            var tutar = k.Kosul switch
            {
                ">"  => sayisal is not null && k.Esik is not null && sayisal > k.Esik,
                ">=" => sayisal is not null && k.Esik is not null && sayisal >= k.Esik,
                "<"  => sayisal is not null && k.Esik is not null && sayisal < k.Esik,
                "<=" => sayisal is not null && k.Esik is not null && sayisal <= k.Esik,
                "anormal" => bayrak is "H" or "L" or "HH" or "LL",
                "yuksek"  => bayrak is "H" or "HH",
                "dusuk"   => bayrak is "L" or "LL",
                "pozitif" => bayrak is "H" or "HH" or "P",
                _ => false,
            };
            if (!tutar) continue;
            var var_ = await baglanti.TekDegerAsync<long>(
                "select count(*) from public.lab_istem_satir where istem_id = @p0 and tetkik_id = @p1 and durum <> 9",
                islem, [istemId, k.Hedef], iptal);
            if (var_ > 0) continue;
            var siraSon = await baglanti.TekDegerAsync<short>(
                "select coalesce(max(sira), 0) from public.lab_istem_satir where istem_id = @p0", islem, [istemId], iptal);
            var satirId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_istem_satir
                       (istem_id, tetkik_id, panel_id, numune_id, stok_id, kod, ad, durum, sira, ekleyen,
                        aciklama, kaynak_turu)
                values (@p0, @p1, null, @p2, null, @p3, @p4, @p5, @p6, @p7, @p8, 1)
                returning id
                """, islem,
                [istemId, k.Hedef, numuneId, k.Kod, k.Ad, (short)(numuneId is null ? 1 : 2),
                 (short)(siraSon + 10), baglam.KullaniciId, $"Refleks test (kural #{k.Id})"], iptal);
            await baglanti.CalistirAsync("""
                insert into public.lab_akilci_gerekce
                       (istem_id, satir_id, hizmet_id, hasta_id, hekim_id, kural_turu, karar, aciklama, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 'refleks', 'devam', @p5, @p6, @p4)
                """, islem,
                [istemId, satirId, k.HizmetId, hastaId, baglam.KullaniciId,
                 $"Refleks kural #{k.Id}: kaynak tetkik {tetkikId}, koşul {k.Kosul} {k.Esik}, bayrak {bayrak}", subeId], iptal);
            eklenen.Add(k.Ad);
        }
        return eklenen;
    }

    // -------------------------------------------------------- reflektif --
    /// <summary>
    /// Lab uzmanının sonuç sonrası ek tetkik istemi (§7): mevcut isteme
    /// satır olarak eklenir (kaynak_turu 2), "Laboratuvar Uzmanı Reflektif
    /// İstemi" diye kayda geçer. Numune planı çağıranın işi (NumunePlaniAsync).
    /// </summary>
    public async Task<List<string>> ReflektifEkleAsync(int istemId, IReadOnlyList<int> tetkikIdler, string aciklama,
                                                       IstekBaglami baglam, CancellationToken iptal)
    {
        if (tetkikIdler.Count == 0) throw GentegreHatasi.IsKurali("En az bir tetkik seçin.");
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);
        var istem = await baglanti.TekAsync("""
            select taraf_id, sube_id, durum from public.lab_istem where id = @p0
            """, islem, [istemId], o => new { Hasta = o.GetInt32(0), Sube = o.GetInt32(1), Durum = o.GetInt16(2) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");
        if (istem.Durum == 9) throw GentegreHatasi.IsKurali("İptal edilmiş isteme reflektif tetkik eklenemez.");

        var tetkikler = await baglanti.ListeAsync("""
            select t.id, t.kod, t.ad, coalesce(t.hizmet_id, 0) from public.lab_tetkik t
             where t.id = any(@p0) and t.durum = 0
            """, islem, [tetkikIdler.Distinct().ToArray()],
            o => new { Id = o.GetInt32(0), Kod = o.GetString(1), Ad = o.GetString(2), HizmetId = o.GetInt32(3) }, iptal);
        var eklenen = new List<string>();
        foreach (var t in tetkikler)
        {
            var var_ = await baglanti.TekDegerAsync<long>(
                "select count(*) from public.lab_istem_satir where istem_id = @p0 and tetkik_id = @p1 and durum <> 9",
                islem, [istemId, t.Id], iptal);
            if (var_ > 0) continue;
            var siraSon = await baglanti.TekDegerAsync<short>(
                "select coalesce(max(sira), 0) from public.lab_istem_satir where istem_id = @p0", islem, [istemId], iptal);
            var satirId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_istem_satir
                       (istem_id, tetkik_id, panel_id, numune_id, stok_id, kod, ad, durum, sira, ekleyen, aciklama, kaynak_turu)
                values (@p0, @p1, null, null, null, @p2, @p3, 1, @p4, @p5, @p6, 2)
                returning id
                """, islem,
                [istemId, t.Id, t.Kod, t.Ad, (short)(siraSon + 10), baglam.KullaniciId,
                 ("Laboratuvar Uzmanı Reflektif İstemi" + (aciklama.Length > 0 ? ": " + aciklama : ""))[..Math.Min(300, 37 + aciklama.Length)]], iptal);
            await baglanti.CalistirAsync("""
                insert into public.lab_akilci_gerekce
                       (istem_id, satir_id, hizmet_id, hasta_id, hekim_id, kural_turu, karar, aciklama, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 'reflektif', 'devam', @p5, @p6, @p4)
                """, islem, [istemId, satirId, t.HizmetId, istem.Hasta, baglam.KullaniciId,
                             aciklama[..Math.Min(300, aciklama.Length)], istem.Sube], iptal);
            eklenen.Add(t.Ad);
        }
        await IstemDurumTazeleAsync(baglanti, islem, istemId, iptal);
        await islem.CommitAsync(iptal);
        return eklenen;
    }
}
