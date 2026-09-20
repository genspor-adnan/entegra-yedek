using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HASTANIN e-NABIZ PROFİLİNE MESAJ — uçlar (877, KTS maddesi H7 / D14).
///
/// <para>Uçlar YALNIZ kuyruğa alır ve kuyruğu gösterir; gönderim zamanlı
/// işin (<c>enabiz.mesaj</c>) işidir. "Gönder" düğmesine basan hekim,
/// Bakanlık servisinin cevabını beklemek zorunda kalmasın.</para>
///
/// <para><b>Hekim kimliği zorunlu:</b> e-Nabız'da mesajı gönderen kurum
/// değil hekimdir. İstekte hekim verilmezse oturumun kendi personel kaydı
/// kullanılır; o da yoksa istek reddedilir - kimliksiz mesaj, servise
/// gönderilemeyecek bir satırı kuyruğa koymak olurdu.</para>
/// </summary>
public static class EnabizMesajUclari
{
    private const int LogTabloEnabizMesaj = 1143;
    private const int LogTabloEnabizErisim = 1144;

    public sealed record MesajIstegi(int HastaId, string Metin, int? HekimId, int? BelgeId,
                                     int? Kaynak, int? KaynakId);
    /// <summary>Hekim erişim isteği (878): hasta + (isteğe bağlı) hekim ve bağlam.</summary>
    public sealed record ErisimIstegi(int HastaId, int? HekimId, int? MuayeneId, int? BelgeId);

    public static void EnabizMesajUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/enabiz").WithTags("e-Nabız").RequireAuthorization();

        // ------------------------------------------------- hastanın mesajları ----
        grup.MapGet("/mesaj", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.mesaj", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync(Secim + " where m.hasta_id = @p0 order by m.id desc limit 50",
                null, [hastaId], Oku, iptal);
            // Kapının açık olup olmadığı EKRANDA görünmeli: mesaj kuyrukta
            //   bekliyorsa hekim sebebini bilsin ("metot tanımlı değil").
            var kapi = await KapiDurumuAsync(b, iptal);
            return Results.Ok(new { mesajlar = liste, kapi });
        });

        // ------------------------------------------------------------ yaz ----
        grup.MapPost("/mesaj", async (
            MesajIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.mesaj", Islem.Ekle);
            if (istek.HastaId <= 0) throw GentegreHatasi.Dogrulama("Hasta seçilmeli.");

            await using var baglanti = await veri.AcAsync(iptal);

            // KULLANICI ZATEN BİR TARAFTIR (`taraf_kullanici.id` → `taraf.id`),
            //   yani oturumu açan kişinin kartı hekim kartının kendisidir.
            //   İstek hekim vermemişse oturumun sahibi yazılır.
            var hekimId = istek.HekimId ?? baglam.KullaniciId;
            var hekimKimlik = await baglanti.TekDegerAsync<string>(
                "select coalesce(vkno, '') from public.taraf where id = @p0",
                null, [hekimId], iptal) ?? "";
            if (hekimKimlik.Trim().Length == 0)
                throw GentegreHatasi.IsKurali(
                    "Gönderen hekimin kimlik numarası kayıtlı değil; e-Nabız mesajı hekim kimliğiyle gider.");

            // HASTANIN KİMLİK NUMARASI YOKSA MESAJ KUYRUĞA GİRMEZ: e-Nabız
            //   profili kimlik numarasıyla bulunur, numarasız satır kuyrukta
            //   sonsuza kadar hata verirdi. Hata ekranda anlaşılır olsun.
            var kimlik = await baglanti.TekDegerAsync<string>(
                "select coalesce(vkno, '') from public.taraf where id = @p0",
                null, [istek.HastaId], iptal) ?? "";
            if (kimlik.Trim().Length == 0)
                throw GentegreHatasi.IsKurali(
                    "Hastanın kimlik numarası kayıtlı değil; e-Nabız mesajı gönderilemez.");

            await using var islem = await baglanti.BeginTransactionAsync(iptal);
            var id = await EnabizMesajServisi.KuyrugaAlAsync(
                baglanti, islem, istek.HastaId, hekimId, istek.Metin,
                (short)(istek.Kaynak ?? 1), istek.KaynakId, istek.BelgeId,
                baglam.SubeId ?? 0, baglam.KullaniciId, iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloEnabizMesaj, (int)id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { kaynak = istek.Kaynak ?? 1, uzunluk = istek.Metin?.Trim().Length ?? 0 },
                tarafId: istek.HastaId, iptal: iptal);
            await islem.CommitAsync(iptal);

            var m = await baglanti.TekAsync(Secim + " where m.id = @p0", null, [id], Oku, iptal);
            return Results.Ok(new { id, mesaj = m });
        });

        // -------------------------------------------------------- vazgeç ----
        // Kuyruktaki mesaj GÖNDERİLMEDEN geri alınabilir; gönderilmiş mesaj
        //   geri alınamaz (Bakanlık tarafında hastanın profiline düştü).
        grup.MapPost("/mesaj/{id:long}/vazgec", async (
            long id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.mesaj", Islem.Degistir);
            await using var baglanti = await veri.AcAsync(iptal);
            var satir = await baglanti.TekAsync(
                "select durum, hasta_id from public.enabiz_mesaj where id = @p0",
                null, [id], o => new { durum = o.GetInt16(0), hastaId = o.GetInt32(1) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Mesaj bulunamadı.");
            if (satir.durum == 1)
                throw GentegreHatasi.IsKurali("Gönderilmiş mesaj geri alınamaz.");

            await baglanti.CalistirAsync("""
                update public.enabiz_mesaj set durum = 3, degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0 and durum <> 1
                """, null, [id, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloEnabizMesaj, (int)id, baglam.KullaniciId,
                baglam.SubeId, baglam.Ip, new { vazgecildi = true },
                tarafId: satir.hastaId, iptal: iptal);
            return Results.Ok(new { durum = 3 });
        });

        // ------------------------------------------- hekim erişimi (878) ----
        // KTS maddesi H6 / D15. Servisten geçici `AccessKey` alınır ve
        //   açılacak adres döner; ekran adresi YENİ SEKMEDE açar, hekim orada
        //   e-Devlet ile girer (hasta verisini gizlemişse SMS onayı ister).
        //
        // POST, GET değil: çağrı Bakanlık tarafında iz bırakır ve bizde de
        //   KVKK kaydı açar - yan etkisi olan bir işlem GET olmamalı.
        grup.MapPost("/erisim", async (
            ErisimIstegi istek, EnabizErisimServisi servis, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.erisim", Islem.Gor);
            if (istek.HastaId <= 0) throw GentegreHatasi.Dogrulama("Hasta seçilmeli.");

            // Hekim verilmezse oturumun sahibi (kullanıcı zaten bir taraftır).
            var hekimId = istek.HekimId ?? baglam.KullaniciId;
            var s = await servis.AnahtarAlAsync(istek.HastaId, hekimId, istek.MuayeneId,
                istek.BelgeId, baglam.SubeId ?? 0, baglam.KullaniciId, baglam.Ip, iptal);

            // ERİŞİM DENEMESİ İŞLEM GÜNLÜĞÜNE DE YAZILIR: `enabiz_erisim`
            //   modülün kendi izi, ISLEMLOG ise kurumun tek elden bakılan
            //   günlüğü - "kim neye erişti" sorusu ikisinden de cevaplanabilsin.
            await log.YazAsync(LogIslemi.Ekle, LogTabloEnabizErisim, (int)s.KayitId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { hekimId, basarili = s.Basarili, mesaj = s.ServisMesaji },
                tarafId: istek.HastaId, iptal: iptal);

            if (!s.Basarili)
                throw GentegreHatasi.IsKurali(
                    s.ServisMesaji.Length > 0
                        ? $"e-Nabız erişim anahtarı alınamadı: {s.ServisMesaji}"
                        : "e-Nabız erişim anahtarı alınamadı.");

            return Results.Ok(new { s.KayitId, adres = s.Adres, mesaj = s.ServisMesaji });
        });

        // Hastanın erişim geçmişi (KVKK izi; hasta "kim baktı" diye sorabilir).
        grup.MapGet("/erisim", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.erisim", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await b.ListeAsync("""
                select e.id, e.hekim_adi, e.zaman, e.sonuc, e.sonuc_adi, e.anahtar_onek,
                       e.servis_mesaji
                  from public.v_enabiz_erisim e
                 where e.hasta_id = @p0 order by e.id desc limit 50
                """, null, [hastaId], o => new
            {
                id = o.GetInt64(0), hekim = o.GetString(1), zaman = o.GetDateTime(2),
                sonuc = (int)o.GetInt16(3), sonucAdi = o.GetString(4),
                anahtarOnek = o.GetString(5), servisMesaji = o.GetString(6),
            }, iptal);
            return Results.Ok(new { erisimler = liste });
        });

        // ------------------------------------------------- kuyruğu çalıştır ----
        // Elle tetikleme: zamanlı iş 15 dakikada bir çalışır, ama kapı yeni
        //   açıldığında beklemek gerekmesin.
        grup.MapPost("/mesaj/kuyruk", async (
            long? mesajId, EnabizMesajServisi servis, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("enabiz.mesaj", Islem.Degistir);
            var s = await servis.CalistirAsync(50, mesajId, iptal);
            return Results.Ok(new { s.Gonderildi, s.Hata, s.Bekleyen, s.Aciklama });
        });
    }

    private const string Secim = """
        select m.id, m.hasta_id, m.hasta_adi, m.hekim_id, m.hekim_adi, m.kaynak, m.kaynak_adi,
               m.metin, m.durum, m.durum_adi, m.deneme, m.gonderim_zamani, m.yanit_kod,
               m.yanit_mesaj, m.son_hata, m.ekleme_tarihi, m.belge_id
          from public.v_enabiz_mesaj m
        """;

    private static object Oku(NpgsqlDataReader o) => new
    {
        id = o.GetInt64(0), hastaId = o.GetInt32(1), hasta = o.GetString(2),
        hekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), hekim = o.GetString(4),
        kaynak = (int)o.GetInt16(5), kaynakAdi = o.GetString(6),
        metin = o.GetString(7), durum = (int)o.GetInt16(8), durumAdi = o.GetString(9),
        deneme = (int)o.GetInt16(10),
        gonderim = o.IsDBNull(11) ? (DateTime?)null : o.GetDateTime(11),
        yanitKod = o.GetString(12), yanitMesaj = o.GetString(13), sonHata = o.GetString(14),
        eklemeTarihi = o.GetDateTime(15),
        belgeId = o.IsDBNull(16) ? (int?)null : o.GetInt32(16),
    };

    /// <summary>
    /// GÖNDERİM KAPISI (881'de değişti): mesaj artık 411 USS paketiyle
    /// gidiyor, ayrı bir portal hesabı/metot adı istemiyor. Kapı ikiye
    /// indi: 411 paket türü açık mı ve USS gönderim hesabı (ENABIZ) hazır mı.
    /// </summary>
    private static async Task<object?> KapiDurumuAsync(NpgsqlConnection b, CancellationToken iptal)
        => await b.TekAsync("""
            select (select count(*)::int from public.enabiz_paket_turu
                     where kod = 'HASTA_MESAJI' and aktif = 1) as paket_acik,
                   (select count(*)::int from public.entegrasyon_hesap
                     where kod = 'ENABIZ' and aktif = 1) as hesap,
                   (select count(*)::int from public.zamanli_is
                     where kod = 'enabiz.gonder' and aktif = 1) as gonderim_isi
            """, null, [], o => new
        {
            paketAcik = o.GetInt32(0) > 0,
            hesapAcik = o.GetInt32(1) > 0,
            gonderimIsi = o.GetInt32(2) > 0,
            // KAPI "acik" ancak paket turu acik VE USS hesabi varsa: zamanli is
            //   kapaliyken paket yine uretilir ve kuyrukta durur - o bir
            //   gecikme, engel degil.
            acik = o.GetInt32(0) > 0 && o.GetInt32(1) > 0,
        }, iptal);
}
