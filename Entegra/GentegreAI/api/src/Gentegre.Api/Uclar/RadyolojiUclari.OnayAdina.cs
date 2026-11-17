using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// RADYOLOG ADINA ONAY + ONAY / e-İMZA İPTALİ (kullanıcı 17.11.2026):
///  * "kullanıcı radyolog ise direkt kendi adına onay / e-imzayı yapabilir"
///  * "kullanıcı radyolog değilse, bunlara basınca radyolog seçimi sorar; sonra onayla basıldıysa şifre, e-imzala ise
///    e-imza çipini sorar" - onay SEÇİLEN radyoloğun adına yazılır (onaylayan_id / imzalayan_id), giren log'da kalır.
///  * "onaylandıysa Onayla → Onay İptal olur, e-imzala ise e-İmza İptal olur" - YALNIZ onaylayan radyolog iptal eder
///    (başkası basarsa onaylayanın şifresi sorulur); teslim edilmiş ya da e-Nabız / Teletıp'a gitmiş raporda iptal YOK
///    (düzeltme ek raporla). Gitmemiş e-Nabız paketi iptal (5), bekleyen Teletıp ORU atlandı (4) olur.
/// RADYOLOG = aktif hesap + `rad.rapor_onayla` + RADYOLOG ROLÜ (`radyolog` / `teleradyoloji_hekim`) - kullanıcı 17.11.2026:
/// "ben admin olarak şifre sormadan onayladım.. sadece radyolog direkt onaylar" (yönetici rolü onay yetkisini taşır ama
/// radyolog değildir; o da radyolog seçip şifre girer).
/// </summary>
public static partial class RadyolojiUclari
{
    public sealed record OnayIptalIstegi(string? Parola = null);

    /// <summary>
    /// Radyolog rolü: rol kartında "Radyolog" işaretli (rol.radyolog, 1365 - kod inceleme 17.11.2026). Rol KODU kalıbı
    /// ('%radyolog%') bırakıldı: harfe duyarlıydı ve adla iş bilmiyordu ('Radyolog' / 'rad_uzman' dışarıda,
    /// 'radyolog_sekreter' içeride kalıyordu).
    /// </summary>
    private static string RadyologRolSql(string kullanici) => $"""
        exists (select 1 from public.fn_kullanici_rolleri({kullanici}) kr join public.rol r on r.id = kr.rol_id
                 where r.aktif = 1 and r.radyolog = 1)
        """;

    /// <summary>Kişi rapor onaylayabilir mi: aktif kullanıcı hesabı + rad.rapor_onayla.</summary>
    private static Task<bool> RadyologMuAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int kullaniciId, CancellationToken iptal)
        => b.TekDegerAsync<bool>($"""
            select exists (select 1 from public.taraf_kullanici k where k.id = @p0 and k.aktif = 1)
               and exists (select 1 from public.fn_kullanici_yetkileri(@p0) y
                            where y.yetki_kod = 'rad.rapor_onayla' and y.gor = 1)
               and {RadyologRolSql("@p0")}
            """, tx, [kullaniciId], iptal);

    /// <summary>
    /// ONAYLAYAN KİM: kendisi radyologsa (ya da kendini seçtiyse) kendisi; değilse seçilen radyolog - rapor yazma yetkisi
    /// yeter, seçilen kişi aktif radyolog olmalı. Kimlik kanıtı (parola / kart) çağıranın işi.
    /// </summary>
    private static async Task<int> OnaylayanCozAsync(NpgsqlConnection b, NpgsqlTransaction? tx, IstekBaglami baglam,
                                                     int? adinaId, CancellationToken iptal)
    {
        if (adinaId is not > 0 || adinaId == baglam.KullaniciId)
        {
            baglam.AksiyonIste("rad.rapor_onayla");
            // KENDİ ADINA YALNIZ RADYOLOG: onay yetkisi olan ama radyolog olmayan (yönetici) radyolog seçip şifre girer.
            if (!await RadyologMuAsync(b, tx, baglam.KullaniciId, iptal))
                throw GentegreHatasi.IsKurali("Radyolog değilsiniz; raporu bir radyolog adına onaylayın (radyolog seçimi + şifre / çip).");
            return baglam.KullaniciId;
        }
        baglam.AksiyonIste("rad.rapor_yaz");
        if (!await RadyologMuAsync(b, tx, adinaId.Value, iptal))
            throw GentegreHatasi.IsKurali("Seçilen kişi rapor onaylayamaz (aktif radyolog değil).");
        return adinaId.Value;
    }

    private static void OnayIptalEkle(RouteGroupBuilder grup)
    {
        // ONAYLAYACAK RADYOLOGLAR (17.11.2026): onay / e-imza "kimin adına" seçimi - radyolog rolündeki, onay yetkili,
        //   aktif ve bu şubede çalışan kişiler (şube süzgeci onay-uzmanlarıyla aynı). `benRadyolog`: oturum sahibi
        //   radyolog mu - öyleyse seçim sorulmaz, kendi adına.
        grup.MapGet("/onay-radyologlari", async (BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");
            await using var b = await veri.AcAsync(iptal);
            var benRadyolog = await RadyologMuAsync(b, null, baglam.KullaniciId, iptal);
            var liste = await b.ListeAsync($"""
                select k.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad
                  from public.taraf_kullanici k
                  join public.taraf t on t.id = k.id
                 where k.aktif = 1
                   and public.fn_kullanici_yetkili(k.id, 'rad.rapor_onayla')
                   and {RadyologRolSql("k.id")}
                   and ({SubeSuzgeciSql})
                 order by 2
                """, null, [baglam.SubeId], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            return Results.Ok(new { benRadyolog, liste });
        });

        grup.MapPost("/rapor/{id:int}/onay-iptal", async (
            int id, OnayIptalIstegi? govde, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log, KimlikServisi kimlik,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("rad.rapor_yaz");
            await using var baglanti = await veri.AcAsync(iptal);
            await using var islem = await baglanti.BeginTransactionAsync(iptal);

            var r = await baglanti.TekAsync("""
                select r.istem_id, coalesce(r.durum, 1)::int, coalesce(r.kilit, 0)::int, r.onaylayan_id,
                       coalesce(r.imza_dokuman_id, 0)::int, coalesce(r.rapor_no, '')
                  from public.radyoloji_rapor r where r.id = @p0 for update
                """, islem, [id], o => new
                {
                    IstemId = o.GetInt32(0), Durum = o.GetInt32(1), Kilit = o.GetInt32(2),
                    Onaylayan = o.IsDBNull(3) ? (int?)null : o.GetInt32(3), ImzaDokuman = o.GetInt32(4), No = o.GetString(5),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Rapor bulunamadı.");
            if (r.Durum != 3 || r.Kilit != 1) throw GentegreHatasi.IsKurali("Rapor onaylı değil.");
            await baglanti.CalistirAsync("select 1 from public.radyoloji_istem where id = @p0 for update", islem, [r.IstemId], iptal);

            // YALNIZ ONAYLAYAN: başkası basarsa onaylayanın parolası.
            var onaylayan = r.Onaylayan ?? 0;
            if (onaylayan != baglam.KullaniciId)
            {
                if (onaylayan == 0) throw GentegreHatasi.IsKurali("Raporu onaylayan kişi kayıtlı değil; iptal edilemez.");
                if (string.IsNullOrEmpty(govde?.Parola))
                    throw GentegreHatasi.Dogrulama("Onaylayan radyoloğun şifresi gerekli.", new AlanHatasi("parola", "Zorunlu."));
                await kimlik.BaskasininParolasiniDogrulaAsync(onaylayan, govde.Parola, baglam.Ip,
                    ctx.Request.Headers.UserAgent.ToString(), "rad_onay_iptal", baglam.KullaniciId, iptal);
            }

            // DIŞARI ÇIKTIYSA İPTAL YOK: teslim / e-Nabız (gönderiliyor-gönderildi-silindi) / Teletıp ORU gönderildi.
            var engel = await baglanti.TekDegerAsync<string>("""
                select case
                  when exists (select 1 from public.radyoloji_teslim t where t.istem_id = @p1 or t.rapor_id = @p0)
                    then 'Rapor teslim edildi'
                  when exists (select 1 from public.enabiz_paket p where p.kaynak_tur = 5 and p.kaynak_id = @p0 and p.durum in (2, 3, 6))
                    then 'Rapor e-Nabız''a gönderildi'
                  when exists (select 1 from public.teletip_gonderim g where g.rapor_id = @p0 and g.durum = 1)
                    then 'Rapor Teletıp''a (Bakanlık) gönderildi'
                  else '' end
                """, islem, [id, r.IstemId], iptal) ?? "";
            if (engel.Length > 0)
                throw GentegreHatasi.IsKurali($"{engel}; onay iptal edilemez. Düzeltme için Ek Rapor açın.");

            // Gitmemiş dış kayıtlar düşer: yeniden onayda yenisi üretilir.
            await baglanti.CalistirAsync("""
                update public.enabiz_paket set durum = 5, degistirme_tarihi = now()
                 where kaynak_tur = 5 and kaynak_id = @p0 and durum in (0, 1, 4)
                """, islem, [id], iptal);
            await baglanti.CalistirAsync("""
                update public.teletip_gonderim set durum = 4 where rapor_id = @p0 and durum in (0, 3, 5)
                """, islem, [id], iptal);

            // Rapor taslağa, istem "raporlanıyor"a döner; rapor no korunur (yeniden onayda aynı no). e-İmza bağı kalkar,
            //   imzalı XML doküman deposunda iz olarak durur.
            await baglanti.CalistirAsync("""
                update public.radyoloji_rapor
                   set durum = 1, kilit = 0, onaylayan_id = null, onay_tarihi = null,
                       imza_zamani = null, imzalayan_id = null, imza_sertifika = null, imza_dokuman_id = null, imza_ozet = null,
                       degistiren = @p1, degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, islem, [id, baglam.KullaniciId], iptal);
            await baglanti.CalistirAsync("update public.radyoloji_istem set durum = 3 where id = @p0 and durum = 5", islem, [r.IstemId], iptal);

            await log.YazAsync(baglanti, islem, LogIslemi.Degistir, LogTabloRapor, id,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["durum"] = r.ImzaDokuman > 0 ? "e-İmza iptal (taslağa döndü)" : "Onay iptal (taslağa döndü)",
                    ["onaylayan"] = onaylayan.ToString(), ["imzaDokuman"] = r.ImzaDokuman.ToString(), ["raporNo"] = r.No,
                }, iptal: iptal);
            await islem.CommitAsync(iptal);
            return Results.Ok(new { tamam = true });
        });
    }
}
