using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// LABORATUVAR — CİHAZ ARAYÜZÜ — çalışma listesi ve gelen mesajın işlenmesi.
///
/// <para>Cihazdan gelen değer ÖN VERİDİR: aynı kural motorundan geçer ve teknik
/// onay bekler. Cihaz mesajını doğrudan onaylı sonuca yazmak, kimsenin
/// bakmadığı bir sonucu hekime göndermek olurdu.</para>
///
/// <para>Sınıfın kendisi ve ortak yardımcıları <c>LabServisi.cs</c>
/// içindedir (aynı partial sınıf).</para>
/// </summary>
public sealed partial class LabServisi
{
    public sealed record CihazIslemSonucu(int Yazilan, int Atlanan, string Mesaj);

    public sealed record CalismaSatiri(int IstemSatirId, string Barkod, int TetkikId,
                                       string TetkikKodu, string CihazKodu,
                                       string TetkikAdi, int HastaId, string HastaAdi,
                                       short Oncelik);

    /// <summary>
    /// HOST QUERY - cihaz "bu barkodda ne çalışacağım" diye sorar.
    ///
    /// Listeyi sunucu verir; teknisyenin cihaz başında testi elle seçmesi
    /// hem yavaş hem hatalı. Yalnız KABUL EDİLMİŞ numune döner.
    /// </summary>
    public async Task<List<CalismaSatiri>> CalismaListesiAsync(int cihazId, string barkod,
                                                               CancellationToken iptal)
        => await _veri.ListeAsync("""
            select istem_satir_id, barkod, tetkik_id, tetkik_kodu, cihaz_kodu,
                   tetkik_adi, hasta_no, hasta_adi, oncelik
              from public.fn_lab_cihaz_calisma_listesi(@p0, @p1)
            """, [cihazId, barkod],
            o => new CalismaSatiri(o.GetInt32(0), o.GetString(1), o.GetInt32(2),
                                   o.GetString(3), o.GetString(4), o.GetString(5),
                                   o.GetInt32(6), o.GetString(7), o.GetInt16(8)), iptal);

    /// <summary>
    /// Cihazdan gelen ÇÖZÜMLENMİŞ mesajı lab sonucuna yazar.
    ///
    /// <para><b>Ham metin cihaz_mesaj'da kalır.</b> Eşleme düzeltilince mesaj
    /// yeniden işlenir - cihaz aynı sonucu ikinci kez göndermez.</para>
    ///
    /// <para><b>Eşleşmeyen test SESSİZCE atılmaz</b>; sayısı ve kodları mesaj
    /// hatasına yazılır, yoksa sonuç kaybolmuş görünürdü.</para>
    /// </summary>
    /// <param name="dokumanlar">
    /// GRAFİK TİPLİ SONUÇ (892) için doküman deposu. Boş geçilebilir -
    /// grafiksiz akışlar (testler, eski çağrılar) depo istemek zorunda
    /// kalmasın; o durumda eğri kaydedilmez, sayısal sonuç yine yazılır.
    /// </param>
    public async Task<CihazIslemSonucu> CihazMesajIsleAsync(long mesajId,
        IstekBaglami baglam, CancellationToken iptal,
        Veri.Depolar.DokumanDeposu? dokumanlar = null)
    {
        var m = await _veri.TekAsync("""
            select m.id, m.cihaz_id, m.ornek_no, m.istem_no, m.durum, m.kalem_sayisi
              from public.cihaz_mesaj m where m.id = @p0
            """, [mesajId],
            o => new { Id = o.GetInt64(0), CihazId = o.GetInt32(1),
                       OrnekNo = o.GetString(2), IstemNo = o.GetString(3),
                       Durum = o.GetInt16(4), Kalem = o.GetInt32(5) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Cihaz mesajı bulunamadı.");

        if (m.Durum == 3)
            return new CihazIslemSonucu(0, 0, "Bu mesaj zaten işlenmiş.");

        // Barkod önce örnek numarasında aranır; bazı cihazlar barkodu istem
        //   alanına yazar - iki alana da bakmak, elle düzeltmeyi önler.
        var numuneId = await _veri.TekDegerAsync<int?>("""
            select id from public.lab_numune
             where barkod in (@p0, @p1) and barkod <> '' order by id desc limit 1
            """, [m.OrnekNo, m.IstemNo], iptal);

        if (numuneId is null or 0)
        {
            await MesajHataAsync(mesajId,
                $"Barkod eşleşmedi (örnek '{m.OrnekNo}', istem '{m.IstemNo}').", iptal);
            return new CihazIslemSonucu(0, m.Kalem,
                "Barkod bir numuneyle eşleşmedi - mesaj hata durumunda bekliyor.");
        }

        var kalemler = await _veri.ListeAsync("""
            select sira, test_kodu, deger, sayisal, birim, deger_tipi,
                   (gomulu is not null or seri is not null) as grafik
              from public.cihaz_mesaj_kalem where mesaj_id = @p0 order by sira, id
            """, [mesajId],
            o => new { Sira = o.GetInt32(0), Kod = o.GetString(1), Deger = o.GetString(2),
                       Sayisal = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                       Birim = o.GetString(4), DegerTipi = o.GetString(5),
                       // GRAFİK TİPLİ SONUÇ (892, KTS L10): gömülü görüntü ya
                       //   da sayı dizisi taşıyan kalem.
                       Grafik = o.GetBoolean(6) }, iptal);

        int yazilan = 0, grafik = 0;
        var eslesmeyen = new List<string>();

        // SERUM İNDEKSLERİ (444) ÖNCE: cihaz bunları normal sonuç gibi
        //   gönderir (SI-H, HI, HIL-L…). Tetkik eşlemesi olmadığı için
        //   "eşleşmeyen test" sayılıp atılıyorlardı; oysa numune kalitesinin
        //   kendisi ve sonraki sonuçların yorumunu değiştiriyorlar.
        var indeksler = new List<string>();
        foreach (var k in kalemler)
        {
            if (k.Sayisal is not { } indeksDeger) continue;
            var tip = await _veri.TekDegerAsync<short?>("""
                select indeks from public.lab_indeks_kod
                 where upper(kod) = upper(@p1) and durum = 0
                   and (cihaz_id = @p0 or cihaz_id is null)
                 order by cihaz_id nulls last limit 1
                """, [m.CihazId, k.Kod], iptal);
            if (tip is null) continue;

            var kolon = tip switch { 1 => "hemoliz_idx", 2 => "lipemi_idx",
                                     _ => "ikter_idx" };
            await _veri.CalistirAsync($"""
                update public.lab_numune set {kolon} = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, [numuneId, (short)Math.Round(indeksDeger)], iptal);
            indeksler.Add($"{k.Kod}={indeksDeger:0.#}");
        }

        foreach (var k in kalemler)
        {
            // İndeks kalemi tetkik değildir: sonuç satırı açılmaz.
            if (indeksler.Any(x => x.StartsWith(k.Kod + "=",
                                                StringComparison.OrdinalIgnoreCase)))
                continue;

            var e = await _veri.TekAsync("""
                select tetkik_id, carpan, ofset
                  from public.fn_lab_cihaz_tetkik(@p0, @p1, '')
                """, [m.CihazId, k.Kod],
                o => new { TetkikId = o.GetInt32(0), Carpan = o.GetDecimal(1),
                           Ofset = o.GetDecimal(2) }, iptal);

            if (e is null) { eslesmeyen.Add(k.Kod); continue; }

            var satirId = await _veri.TekDegerAsync<int?>("""
                select id from public.lab_istem_satir
                 where numune_id = @p0 and tetkik_id = @p1 and durum <> 0
                 order by id limit 1
                """, [numuneId, e.TetkikId], iptal);

            // İSTENMEMİŞ TEST YAZILMAZ: cihaz paneli komple çalışır, istemde
            //   olmayan testi hasta dosyasına eklemek faturalanmamış sonuç üretir.
            if (satirId is null or 0) { eslesmeyen.Add(k.Kod); continue; }

            var deger = k.Sayisal is { } sy
                ? (sy * e.Carpan + e.Ofset).ToString(System.Globalization.CultureInfo.InvariantCulture)
                : k.Deger;

            var yazim = await SonucYazAsync(
                new SonucIstegi(satirId.Value, deger, k.Birim, null, null),
                m.CihazId, mesajId, baglam, iptal, k.Deger, k.Birim);
            yazilan++;

            // GRAFİK TİPLİ SONUÇ (892, KTS L10): eğri/görüntü sonucun EKİDİR,
            //   sonuç yazıldıktan sonra bağlanır. Kalem grafik taşımıyorsa
            //   (çoğu kalem taşımaz) hiçbir şey yapılmaz.
            if (k.Grafik && dokumanlar is not null)
            {
                var g = await CihazGrafigiBaglaAsync(dokumanlar, mesajId, k.Sira,
                            satirId.Value, yazim.SonucId, m.CihazId,
                            k.Kod, baglam, iptal);
                if (g > 0) grafik++;
            }
        }

        var hata = eslesmeyen.Count == 0 ? ""
            : $"Eşleşmeyen test: {string.Join(", ", eslesmeyen)}";

        await _veri.CalistirAsync("""
            update public.cihaz_mesaj set durum = 3, hata = @p1, islenme = now()
             where id = @p0
            """, [mesajId, hata], iptal);

        var indeksNot = indeksler.Count > 0
            ? $" Serum indeksleri numuneye yazıldı ({string.Join(", ", indeksler)})."
            : "";

        // GRAFİK SAYISI MESAJDA SÖYLENİR (892): eğri sessizce eklenirse
        //   teknisyen onun geldiğini bilmez, raporda görünce şaşırır.
        var grafikNot = grafik > 0 ? $" {grafik} grafik sonuç eklendi." : "";

        return new CihazIslemSonucu(yazilan, eslesmeyen.Count,
            (yazilan == 0 ? $"Sonuç yazılamadı. {hata}"
                          : $"{yazilan} sonuç yazıldı. {hata}").Trim()
            + indeksNot + grafikNot);
    }

    private async Task MesajHataAsync(long mesajId, string hata, CancellationToken iptal)
        => await _veri.CalistirAsync("""
            update public.cihaz_mesaj set durum = 4, hata = @p1 where id = @p0
            """, [mesajId, hata], iptal);
}
