using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// SGK EK-4/A — BEDELİ ÖDENECEK İLAÇLAR LİSTESİ (406).
///
/// Listenin ne verdiği yanlış bilinirse fiyat hesabı baştan yanlış kurulur:
/// Ek-4/A <b>fiyat vermez</b>, <b>iskonto oranı</b> verir. Sütunları kamu no,
/// güncel barkod, eşdeğer ilaç grubu, terapötik referans grubu, aktif/pasif
/// tarihleri, "uygulanan indirim oranları", <i>depocuya satış fiyatı
/// kademelerine göre</i> iskontolar, özel iskonto ve eczacı iskonto oranı.
///
/// Kamu fiyatı = TİTCK perakende fiyatı − bu iskontolar. Yani geri ödeme
/// tutarı için İKİ kaynak da gerekir; TİTCK Detaylı Fiyat Listesi kurumsal
/// portal hesabı istediği için o bir KAPIDIR.
///
/// DUYURU ADRESİ DEĞİŞKEN: SGK dosyayı her düzenlemede yeni bir duyuruya
/// koyuyor ve adres GUID taşıyor. Bu yüzden adres AYARDAN/İSTEKTEN gelir;
/// sabit adres bir sonraki yayında sessizce eskiyi yüklerdi.
/// </summary>
public sealed class SgkIlacListesi
{
    private readonly VeriKaynagi _veri;
    private readonly IHttpClientFactory _http;
    private readonly ILogger<SgkIlacListesi> _gunluk;

    public SgkIlacListesi(VeriKaynagi veri, IHttpClientFactory http, ILogger<SgkIlacListesi> gunluk)
    {
        _veri = veri;
        _http = http;
        _gunluk = gunluk;
    }

    public sealed record Sonuc(int Okunan, int FiyatSatiri, int IlacGuncellenen, int Eslesmeyen,
                               string Yururluk);

    /// <summary>
    /// Ek-4/A'yı verilen adresten (ya da yüklenen içerikten) okur ve yazar.
    /// <paramref name="yururluk"/> verilmezse bugün alınır: listenin kendi
    /// yürürlük tarihi duyuruda yazıyor, dosyada değil.
    /// </summary>
    public async Task<Sonuc> YukleAsync(string? adres, byte[]? icerik, DateOnly? yururluk,
                                        CancellationToken iptal)
    {
        byte[] veri;
        if (icerik is { Length: > 0 })
        {
            veri = icerik;
        }
        else
        {
            if (string.IsNullOrWhiteSpace(adres))
                throw new InvalidOperationException(
                    "SGK Ek-4/A adresi verilmedi. Duyurudaki .xlsx bağlantısını yapıştırın.");
            var istemci = _http.CreateClient("katalog");
            istemci.Timeout = TimeSpan.FromMinutes(5);
            veri = await istemci.GetByteArrayAsync(adres, iptal);
        }

        var satirlar = TitckIlacGuncelleme.XlsxOku(veri);
        if (satirlar.Count == 0)
            throw new InvalidOperationException("Ek-4/A okundu ama satır bulunamadı.");

        var gun = yururluk ?? DateOnly.FromDateTime(DateTime.Today);
        var kayitlar = satirlar
            .Select(h => new
            {
                Barkod = Rakam(Al(h, "GUNCEL BARKOD", "BARKOD")),
                Esdeger = Al(h, "ESDEGER ILAC GRUBU"),
                // Kademeli iskonto: sınırlar başlıktan okunur (bkz. db/407).
                Kademe = IlacListeCozumleme.Kademeler(h),
                OzelIskonto = IlacListeCozumleme.Ondalik(Al(h, "OZEL ISKONTO")),
                Eczaci = IlacListeCozumleme.Ondalik(Al(h, "ECZACI ISKONTO")),
            })
            .Where(x => x.Barkod.Length is >= 8 and <= 20)
            .GroupBy(x => x.Barkod).Select(g => g.Last()).ToList();

        await using var baglanti = await _veri.AcAsync(iptal);
        int fiyatSatiri = 0, guncellenen = 0;
        const int Parti = 4000;

        for (var i = 0; i < kayitlar.Count; i += Parti)
        {
            var p = kayitlar.Skip(i).Take(Parti).ToList();

            fiyatSatiri += await baglanti.CalistirAsync("""
                insert into public.ilac_fiyat (barkod, kaynak, yururluk_bas, kamu_iskonto,
                                               esdeger_iskonto, eczaci_iskonto,
                                               iskonto_kademe, kaynak_surum)
                select t.barkod, 2, @p5::date, t.iskonto, t.ozel, t.eczaci,
                       t.kademe::jsonb, 'sgk-ek4a'
                  from unnest(@p0::varchar[], @p1::numeric[], @p2::numeric[],
                              @p3::numeric[], @p4::text[])
                       as t(barkod, iskonto, ozel, eczaci, kademe)
                on conflict (barkod, kaynak, yururluk_bas) do update
                   set kamu_iskonto = excluded.kamu_iskonto,
                       esdeger_iskonto = excluded.esdeger_iskonto,
                       eczaci_iskonto = excluded.eczaci_iskonto,
                       iskonto_kademe = excluded.iskonto_kademe
                """, null,
                [p.Select(x => x.Barkod).ToArray(),
                 p.Select(x => x.Kademe.Count > 0 ? x.Kademe.Max(k => k.Oran) : 0m).ToArray(),
                 p.Select(x => x.OzelIskonto).ToArray(),
                 p.Select(x => x.Eczaci).ToArray(),
                 p.Select(x => IlacListeCozumleme.KademeJson(x.Kademe)).ToArray(),
                 gun.ToDateTime(TimeOnly.MinValue)], iptal);

            // Eşdeğer grup ilaç kartına da yazılır: eşdeğer sorgusu fiyat
            //   tarihçesine inmeden cevaplanabilsin.
            guncellenen += await baglanti.CalistirAsync("""
                update public.ilac i
                   set esdeger_grup = t.esdeger, guncelleme = now()
                  from unnest(@p0::varchar[], @p1::varchar[]) as t(barkod, esdeger)
                 where i.barkod = t.barkod
                   and nullif(t.esdeger, '') is not null
                   and i.esdeger_grup is distinct from t.esdeger
                """, null,
                [p.Select(x => x.Barkod).ToArray(), p.Select(x => Kirp(x.Esdeger, 64)).ToArray()], iptal);
        }

        // Ek-4/A'da olup KATALOĞUMUZDA olmayan barkod: ruhsat listesi ile
        //   geri ödeme listesi aynı kümeler değil (eski barkod, yurt dışı ilaç).
        var eslesmeyen = await baglanti.TekDegerAsync<int>("""
            select count(*) from public.ilac_fiyat f
             where f.kaynak = 2 and f.yururluk_bas = @p0::date
               and not exists (select 1 from public.ilac i where i.barkod = f.barkod)
            """, null, [gun.ToDateTime(TimeOnly.MinValue)], iptal);

        await baglanti.TekDegerAsync<int>("select public.fn_ilac_fiyat_golge_tazele()", null, [], iptal);

        await _veri.CalistirAsync("""
            insert into public.katalog_senkron (kod, ad, son_calisma, satir_sayisi, sonuc, basarili)
            values ('ilac_fiyat', 'İlaç fiyatları (TİTCK / SGK)', now(),
                    (select count(*) from public.ilac_fiyat), @p0, 1)
            on conflict (kod) do update
               set son_calisma = now(), satir_sayisi = excluded.satir_sayisi,
                   sonuc = excluded.sonuc, basarili = 1
            """,
            new object?[] { $"SGK Ek-4/A ({gun:dd.MM.yyyy}): {fiyatSatiri} iskonto satırı, "
                          + $"{guncellenen} ilaç eşleşti, {eslesmeyen} barkod katalogda yok." },
            iptal);

        _gunluk.LogInformation("SGK Ek-4/A yüklendi: {Satir} satır, {Eslesmeyen} eşleşmeyen.",
            fiyatSatiri, eslesmeyen);

        return new Sonuc(satirlar.Count, fiyatSatiri, guncellenen, eslesmeyen,
                         gun.ToString("dd.MM.yyyy"));
    }

    // ---------------------------------------------------------------- yardımcı
    private static string Al(Dictionary<string, string> satir, params string[] adaylar)
    {
        foreach (var a in adaylar)
        {
            var anahtar = satir.Keys.FirstOrDefault(k => k.Contains(a, StringComparison.Ordinal));
            if (anahtar is not null) return satir[anahtar];
        }
        return "";
    }

    /// <summary>Kolon sınırına kırpar: kaynak listede uzun değer var diye yükleme durmasın.</summary>
    private static string Kirp(string metin, int en) => metin.Length <= en ? metin : metin[..en];

    private static string Rakam(string metin)
        => new(metin.Where(char.IsDigit).ToArray());
}
