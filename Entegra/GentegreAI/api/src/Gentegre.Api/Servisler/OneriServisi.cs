using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// AI KONTROLLÜ ÖNERİ (449, Faz 3) — açık kaydın eksiklerini işaret eder.
///
/// <b>Okur ve işaret eder; yazmaz.</b> Alan doldurmaz, kaydetmez, göndermez,
/// onaylamaz. Faz 1-2 "nerede / nasıl" diyordu; burada "bu caride VKN yok,
/// e-Fatura reddedilir" deniyor.
///
/// <b>Kural AI'ya yazdırılmaz.</b> Her öneri `ai_oneri_kural` satırına bağlı
/// ve koşulu kurumun kendi verisinde çalışan bir SQL. Model bağlandığında
/// yalnız metni güzelleştirir, kararı değil - "bence şu daha iyi" diyen bir
/// asistan denetimde savunulamaz.
///
/// <b>Gürültü kontrolü</b>: seviyeye göre sıralanır (engel → uyarı → bilgi),
/// en çok beş öneri döner, kullanıcı bir kuralı susturabilir. On uyarı
/// gösteren asistan kapatılır.
/// </summary>
public sealed class OneriServisi(VeriKaynagi veri)
{
    public sealed record Istek(string Kaynak, int KayitId);

    public sealed record Oneri(string Kod, short Seviye, string Baslik, string Aciklama,
                               string Alan, string Ekran, string? Rota);

    public sealed record Yanit(string Kaynak, int KayitId, IReadOnlyList<Oneri> Oneriler,
                               int Engel, int Uyari, int Bilgi);

    /// <summary>Panelden gelen rota: "/cari/4868" → ("cari", 4868).</summary>
    public static (string Kaynak, int Id)? RotadanKayit(string? rota)
    {
        if (string.IsNullOrWhiteSpace(rota)) return null;
        var parca = rota.Trim().Trim('/').Split('/');
        if (parca.Length < 2) return null;
        return int.TryParse(parca[1], out var id) && id > 0 ? (parca[0], id) : null;
    }

    /// <summary>
    /// KURAL AİLESİ — hangi kural kümesi çalışacak?
    ///
    /// `belge` tablosu iki ekranı birden besler: fatura/irsaliye/teklif ve
    /// <b>başvuru</b> (tür 19). Liste tanımlarında ikisinin de kaynağı
    /// `belge`, rotaları ayrı (`/alis-fatura`, `/basvuru`, …) — panel hangi
    /// aileden olduğunu bilemez, rotadan tahmin de yanıltır (tek rota birden
    /// çok türe açılıyor).
    ///
    /// Karar bu yüzden <b>kayda</b> sorulur: türü 19 ise başvuru kuralları,
    /// değilse belge kuralları. İstemcinin söylediği kaynak yalnızca ipucu.
    /// </summary>
    private static async Task<string> AileAsync(NpgsqlConnection baglanti, string kaynak,
                                                int kayitId, CancellationToken iptal)
    {
        if (kaynak is not ("belge" or "basvuru")) return kaynak;
        var tur = await baglanti.TekDegerAsync<int>(
            "select coalesce(b.tur, 0) from public.belge b where b.id = @p0",
            null, [kayitId], iptal);
        return tur == 19 ? "basvuru" : "belge";
    }

    public async Task<Yanit> OnerilerAsync(Istek istek, IstekBaglami baglam,
                                           CancellationToken iptal)
    {
        var kaynak = (istek.Kaynak ?? "").Trim();
        if (kaynak.Length == 0 || istek.KayitId <= 0)
            throw GentegreHatasi.IsKurali("Kaynak ve kayıt gerekli.");

        await using var baglanti = await veri.AcAsync(iptal);
        kaynak = await AileAsync(baglanti, kaynak, istek.KayitId, iptal);

        // Kullanıcının SUSTURDUĞU kurallar hiç çalıştırılmaz.
        var kurallar = await baglanti.ListeAsync("""
            select k.kod, k.seviye, k.baslik, k.aciklama, k.alan, k.ekran,
                   k.yetki_kodu as "yetkiKodu", k.kosul
              from public.ai_oneri_kural k
             where k.durum = 0 and k.kaynak = @p0
               and not exists (select 1 from public.ai_oneri_gizli g
                                where g.kullanici_id = @p1 and g.kural_kod = k.kod)
             order by k.seviye desc, k.sira
            """, null, [kaynak, baglam.KullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

        var oneriler = new List<Oneri>();
        foreach (var k in kurallar)
        {
            var yetki = k["yetkiKodu"]?.ToString() ?? "";
            if (yetki != "" && !baglam.Yetkiler.Var(yetki, Islem.Gor)) continue;

            var kosul = k["kosul"]?.ToString() ?? "";
            if (kosul.Length == 0) continue;

            bool tetikledi;
            try
            {
                // Koşul KATALOGDAN gelir, kullanıcı girdisinden değil; kayıt id
                //   yine de parametre olarak bağlanır.
                tetikledi = await baglanti.TekDegerAsync<bool>(
                    kosul, null, [istek.KayitId], iptal);
            }
            catch (PostgresException)
            {
                // Bozuk kural bütün paneli düşürmemeli: o kural atlanır.
                //   (Kural metni katalogda; hatası orada düzeltilir.)
                continue;
            }
            if (!tetikledi) continue;

            var ekran = k["ekran"]?.ToString() ?? "";
            var rota = ekran.Length == 0 ? null : await baglanti.TekDegerAsync<string>("""
                select rota from public.ai_rehber_ekran
                 where (rota = @p0 or rota = '/' || @p0 or kaynak = @p0) and durum = 0
                 order by menu_gizli, id limit 1
                """, null, [ekran], iptal);

            oneriler.Add(new Oneri(
                k["kod"]?.ToString() ?? "", Convert.ToInt16(k["seviye"]),
                k["baslik"]?.ToString() ?? "", k["aciklama"]?.ToString() ?? "",
                k["alan"]?.ToString() ?? "", ekran, rota));

            if (oneriler.Count >= 5) break;   // gürültü sınırı
        }

        // Kaç öneri döndü, hangi kayıtta: hep görmezden gelinen kuralı ölçmek
        //   için (rehber günlüğüyle aynı tablo, kaynak = 4).
        await baglanti.CalistirAsync("""
            insert into public.ai_rehber_log
                   (kullanici_id, sube_id, soru, kaynak, konu_kod, guven, aktif_sayfa)
            values (@p0, @p1, @p2, 4, @p3, 0, @p4)
            """, null,
            [baglam.KullaniciId, baglam.SubeId,
             $"öneri: {kaynak}#{istek.KayitId}", string.Join(",", oneriler.Select(o => o.Kod)),
             $"/{kaynak}/{istek.KayitId}"], iptal);

        return new Yanit(kaynak, istek.KayitId, oneriler,
                         oneriler.Count(o => o.Seviye == 3),
                         oneriler.Count(o => o.Seviye == 2),
                         oneriler.Count(o => o.Seviye == 1));
    }

    /// <summary>Kuralı bu kullanıcı için susturur (kural silinmez).</summary>
    public async Task GizleAsync(string kuralKod, bool gizle, IstekBaglami baglam,
                                 CancellationToken iptal)
    {
        await using var baglanti = await veri.AcAsync(iptal);
        if (gizle)
            await baglanti.CalistirAsync("""
                insert into public.ai_oneri_gizli (kullanici_id, kural_kod)
                values (@p0, @p1) on conflict do nothing
                """, null, [baglam.KullaniciId, kuralKod], iptal);
        else
            await baglanti.CalistirAsync("""
                delete from public.ai_oneri_gizli
                 where kullanici_id = @p0 and kural_kod = @p1
                """, null, [baglam.KullaniciId, kuralKod], iptal);
    }
}
