using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ORTODONTİ ICON SKORU (875 — KTS denetim maddesi D9).
///
/// <para><b>Hesap sunucuda bile değil, şemada:</b> toplam üretilmiş kolon,
/// karmaşıklık ve iyileşme birer fonksiyon (<c>fn_dis_icon_karmasiklik</c>,
/// <c>fn_dis_icon_iyilesme</c>). Bu uç yalnız bileşen puanlarını yazar ve
/// <c>v_dis_icon_skor</c>'u okur - ağırlıkları burada bir daha yazmak, iki
/// yerin sessizce ayrılması demekti.</para>
///
/// <para><b>Tedavi sonrası ölçüm önceki ölçüme bağlanır.</b> Bağ verilmezse
/// hastanın en son "tedavi öncesi" ölçümü kendiliğinden bağlanır: iyileşme
/// derecesi ancak bir başlangıç noktasına göre anlamlıdır ve o noktayı
/// kullanıcıya her seferinde seçtirmek, boş bırakılan alan yüzünden
/// raporun yarısını boş bırakırdı.</para>
/// </summary>
public static partial class DisUclari
{
    private const int LogTabloIcon = 1142;

    public sealed record IconIstegi(int? Id, int HastaId, string? Tarih, int? OlcumTuru,
                                    int Estetik, int UstArk, int Capraz, int Dikey, int Bukkal,
                                    int? HekimId, int? MuayeneId, int? OncesiId, string? Not);

    private static void IconUclariniEkle(RouteGroupBuilder grup)
    {
        // ----------------------------------------------- hastanın skorları ----
        grup.MapGet("/hasta/{hastaId:int}/icon", async (
            int hastaId, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.icon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var liste = await IconListesiAsync(b, hastaId, iptal);
            return Results.Ok(new { skorlar = liste });
        });

        // ------------------------------------------------- canlı önizleme ----
        // Form doldurulurken toplam/karmaşıklık ekranda görünmeli ama ağırlık
        //   İSTEMCİDE YENİDEN YAZILMAZ: aynı `fn_dis_icon_toplam` çağrılır.
        //   İki yerde yazılsaydı ağırlık değişince kaydedilen ile görünen
        //   skor sessizce ayrışırdı.
        grup.MapGet("/icon/hesapla", async (
            int estetik, int ustArk, int capraz, int dikey, int bukkal,
            VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.icon", Islem.Gor);
            IconDogrula(new IconIstegi(null, 1, null, 1, estetik, ustArk, capraz, dikey, bukkal,
                                       null, null, null, null));
            await using var b = await veri.AcAsync(iptal);
            var h = await b.TekAsync("""
                select t.toplam,
                       case when t.toplam > 43 then 1 else 0 end as tedavi_gerekir,
                       public.fn_dis_icon_karmasiklik(t.toplam) as karmasiklik,
                       coalesce(k.ad, '') as karmasiklik_adi
                  from (select public.fn_dis_icon_toplam(@p0::smallint, @p1::smallint, @p2::smallint,
                                                         @p3::smallint, @p4::smallint) as toplam) t
                  left join public.kod_liste l on l.kod = 'dis.icon_karmasiklik'
                  left join public.kod_deger k on k.liste_id = l.id
                                              and k.deger = public.fn_dis_icon_karmasiklik(t.toplam)
                """, null, [estetik, ustArk, capraz, dikey, bukkal], o => new
            {
                toplam = o.GetInt32(0), tedaviGerekir = o.GetInt32(1) == 1,
                karmasiklik = o.IsDBNull(2) ? (int?)null : (int)o.GetInt16(2),
                karmasiklikAdi = o.GetString(3),
            }, iptal);
            return Results.Ok(h);
        });

        // ------------------------------------------------------ tek skor ----
        // Rapor çıktısı da bunu okur: ekran ile rapor aynı satırı görsün.
        grup.MapGet("/icon/{id:int}", async (
            int id, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.icon", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var s = await b.TekAsync(IconSecim + " where s.id = @p0", null, [id], IconOku, iptal)
                ?? throw GentegreHatasi.Bulunamadi("ICON skoru bulunamadı.");
            var kurum = await EtiketKurumuAsync(b, baglam.SubeId, iptal);
            return Results.Ok(new { skor = s, kurum });
        });

        // --------------------------------------------------------- yazma ----
        grup.MapPost("/icon", async (
            IconIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.icon", istek.Id is > 0 ? Islem.Degistir : Islem.Ekle);
            IconDogrula(istek);

            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            short olcum = (short)(istek.OlcumTuru ?? 1);
            // TEDAVİ SONRASI ÖLÇÜM: bağ verilmediyse hastanın en son "tedavi
            //   öncesi" ölçümü bağlanır. İyileşme ancak başlangıca göre
            //   anlamlı; bağsız kalan sonrası ölçüm raporda boş sütun olurdu.
            int? oncesi = istek.OncesiId;
            if (olcum == 2 && oncesi is null)
                oncesi = await baglanti.TekDegerAsync<int?>("""
                    select id from public.dis_icon_skor
                     where hasta_id = @p0 and olcum_turu = 1
                     order by tarih desc, id desc limit 1
                    """, islem, [istek.HastaId], iptal);
            if (olcum == 1) oncesi = null;   // öncesi ölçümün "öncesi" olmaz

            int id;
            if (istek.Id is > 0)
            {
                id = istek.Id.Value;
                var etkilenen = await baglanti.CalistirAsync("""
                    update public.dis_icon_skor
                       set tarih = coalesce(cast(@p1 as date), tarih), olcum_turu = @p2,
                           estetik = @p3, ust_ark = @p4, capraz = @p5, dikey = @p6, bukkal = @p7,
                           hekim_id = @p8, muayene_id = @p9, oncesi_id = @p10, not_metin = @p11,
                           degistiren = @p12, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [id, istek.Tarih, olcum, istek.Estetik, istek.UstArk, istek.Capraz,
                                 istek.Dikey, istek.Bukkal, istek.HekimId, istek.MuayeneId, oncesi,
                                 istek.Not ?? "", baglam.KullaniciId], iptal);
                if (etkilenen == 0) throw GentegreHatasi.Bulunamadi("ICON skoru bulunamadı.");
            }
            else
            {
                id = await baglanti.TekDegerAsync<int>("""
                    insert into public.dis_icon_skor
                           (sube_id, hasta_id, tarih, olcum_turu, estetik, ust_ark, capraz,
                            dikey, bukkal, hekim_id, muayene_id, oncesi_id, not_metin, ekleyen)
                    values (@p0, @p1, coalesce(cast(@p2 as date), current_date), @p3, @p4, @p5,
                            @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13)
                    returning id
                    """, islem, [baglam.SubeId ?? 0, istek.HastaId, istek.Tarih, olcum,
                                 istek.Estetik, istek.UstArk, istek.Capraz, istek.Dikey,
                                 istek.Bukkal, istek.HekimId, istek.MuayeneId, oncesi,
                                 istek.Not ?? "", baglam.KullaniciId], iptal);
            }

            await log.YazAsync(baglanti, islem, istek.Id is > 0 ? LogIslemi.Degistir : LogIslemi.Ekle,
                LogTabloIcon, id, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { olcum, istek.Estetik, istek.UstArk, istek.Capraz, istek.Dikey, istek.Bukkal },
                tarafId: istek.HastaId, iptal: iptal);
            await islem.CommitAsync(iptal);

            var s = await baglanti.TekAsync(IconSecim + " where s.id = @p0", null, [id], IconOku, iptal);
            return Results.Ok(new { id, skor = s });
        });

        grup.MapDelete("/icon/{id:int}", async (
            int id, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("dis.icon", Islem.Sil);
            await using var baglanti = await veri.AcAsync(iptal);
            var satir = await baglanti.TekAsync(
                "select hasta_id, toplam, olcum_turu from public.dis_icon_skor where id = @p0",
                null, [id], o => new { hastaId = o.GetInt32(0), toplam = o.GetInt32(1),
                                       olcum = (int)o.GetInt16(2) }, iptal)
                ?? throw GentegreHatasi.Bulunamadi("ICON skoru bulunamadı.");
            // Sonrası ölçüm bu satıra bağlıysa silme, bağı kopar: bağlı satırı
            //   sessizce silmek hastanın tedavi sonucunu kaybettirirdi.
            var bagli = await baglanti.TekDegerAsync<int>(
                "select count(*)::int from public.dis_icon_skor where oncesi_id = @p0", null, [id], iptal);
            if (bagli > 0)
                throw GentegreHatasi.IsKurali(
                    "Bu ölçüme bağlı tedavi sonrası kaydı var; önce onun bağını değiştirin.");

            // Silme logu DELETE'ten ÖNCE (ULog kuralı, 706 ile aynı).
            await log.YazAsync(LogIslemi.Sil, LogTabloIcon, id, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { satir.toplam, satir.olcum }, tarafId: satir.hastaId, iptal: iptal);
            await baglanti.CalistirAsync("delete from public.dis_icon_skor where id = @p0",
                null, [id], iptal);
            return Results.NoContent();
        });
    }

    private static void IconDogrula(IconIstegi i)
    {
        if (i.HastaId <= 0) throw GentegreHatasi.Dogrulama("Hasta seçilmeli.");
        if (i.Estetik is < 1 or > 10)
            throw GentegreHatasi.Dogrulama("Estetik bileşen (IOTN-AC) 1-10 arası olmalı.");
        if (i.UstArk is < 0 or > 4) throw GentegreHatasi.Dogrulama("Üst ark puanı 0-4 arası olmalı.");
        if (i.Capraz is < 0 or > 1) throw GentegreHatasi.Dogrulama("Çapraz kapanış 0 ya da 1 olmalı.");
        if (i.Dikey is < 0 or > 4) throw GentegreHatasi.Dogrulama("Dikey ilişki puanı 0-4 arası olmalı.");
        if (i.Bukkal is < 0 or > 4) throw GentegreHatasi.Dogrulama("Bukkal segment puanı 0-4 arası olmalı.");
        if (i.OlcumTuru is not (null or 1 or 2))
            throw GentegreHatasi.Dogrulama("Ölçüm türü 1 (tedavi öncesi) ya da 2 (tedavi sonrası) olmalı.");
    }

    private const string IconSecim = """
        select s.id, s.hasta_id, s.hasta_adi, s.hekim_id, s.hekim_adi, s.tarih, s.olcum_turu,
               s.olcum_turu_adi, s.estetik, s.ust_ark, s.capraz, s.dikey, s.bukkal, s.toplam,
               s.tedavi_gerekir, s.karmasiklik, s.karmasiklik_adi, s.oncesi_id, s.oncesi_toplam,
               s.iyilesme, s.iyilesme_adi, s.not_metin, s.muayene_id
          from public.v_dis_icon_skor s
        """;

    private static object IconOku(NpgsqlDataReader o) => new
    {
        id = o.GetInt32(0), hastaId = o.GetInt32(1), hasta = o.GetString(2),
        hekimId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), hekim = o.GetString(4),
        tarih = o.GetDateTime(5), olcumTuru = (int)o.GetInt16(6), olcumTuruAdi = o.GetString(7),
        estetik = (int)o.GetInt16(8), ustArk = (int)o.GetInt16(9), capraz = (int)o.GetInt16(10),
        dikey = (int)o.GetInt16(11), bukkal = (int)o.GetInt16(12), toplam = o.GetInt32(13),
        tedaviGerekir = o.GetInt16(14) == 1,
        karmasiklik = o.IsDBNull(15) ? (int?)null : (int)o.GetInt16(15),
        karmasiklikAdi = o.GetString(16),
        oncesiId = o.IsDBNull(17) ? (int?)null : o.GetInt32(17),
        oncesiToplam = o.IsDBNull(18) ? (int?)null : o.GetInt32(18),
        iyilesme = o.IsDBNull(19) ? (int?)null : (int)o.GetInt16(19),
        iyilesmeAdi = o.GetString(20), not_ = o.GetString(21),
        muayeneId = o.IsDBNull(22) ? (int?)null : o.GetInt32(22),
    };

    private static async Task<List<object>> IconListesiAsync(
        NpgsqlConnection b, int hastaId, CancellationToken iptal)
        => await b.ListeAsync(IconSecim + " where s.hasta_id = @p0 order by s.tarih desc, s.id desc",
            null, [hastaId], IconOku, iptal);
}
