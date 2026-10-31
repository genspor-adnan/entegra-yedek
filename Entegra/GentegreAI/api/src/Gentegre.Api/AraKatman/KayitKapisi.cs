using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// KAYIT KAPISI (kod inceleme raporu 28.10.2026 B02 → 30.10.2026 K01–K07, K26): özel uçlar kaynak / aksiyon iznini
/// kontrol edip kimlikle doğrudan okuyor / yazıyordu — başka şubenin, portalda başka hastanın / kurumun kaydı
/// kimliği değiştirilerek açılabiliyordu. Bu filtre bir grubun BÜTÜN uçlarında yol kimliğini merkezi kayıt erişim
/// kapısından (<see cref="KayitErisimi"/>, liste ile aynı şube / kapsam / portal kuralı) geçirir.
///
/// <para>Her grup kendi kural listesini verir (<see cref="Radyoloji"/>, <see cref="Lab"/>, <see cref="Telerad"/>,
/// <see cref="Isg"/>, <see cref="Hasta"/>): yol deseninde geçen parça → yol parametresi → (gerekirse ara SQL ile
/// üst kayda çıkıp) katalog kaynağı. Kapsam dışı ya da olmayan kayıt aynı 404'ü alır (kimliği deneyen kayıt var
/// mı öğrenemez). Kurallarda geçmeyen uçlar (tanım, cihaz, kalite kontrol) dokunulmadan geçer.</para>
///
/// <para>Kural eşleşmesi ilk eşleşen kazanır — daha özel desen (<c>/numune/barkod/{barkod</c>) genel olandan
/// (<c>/numune/{id</c>) önce yazılır.</para>
/// </summary>
public sealed class KayitKapisi(IReadOnlyList<KayitKapisi.Kural> kurallar) : IEndpointFilter
{
    public enum Hedef
    {
        /// <summary>Çözülen kimlik <see cref="Kural.Kaynak"/> katalog kaynağında görünür olmalı.</summary>
        Kaynak,
        /// <summary>Çözülen kimlik lab istem SATIRIDIR: istem kapsamı + tetkik rol izni (<see cref="KayitErisimi.LabSatirIsteAsync"/>).</summary>
        LabSatir,
    }

    /// <param name="Desen">Yol deseninde aranan parça, ör. <c>"/istem/{id"</c>.</param>
    /// <param name="Parametre">Yol parametresinin adı (<c>id</c>, <c>teslimId</c>, <c>barkod</c>…).</param>
    /// <param name="Kaynak">Katalog kaynağı (Hedef=Kaynak için).</param>
    /// <param name="Mesaj">404 metni — olmayan ve kapsam dışı kayıt için aynı.</param>
    /// <param name="CozSql">Verilirse önce çalışır (<c>@p0</c> = yol parametresi) ve üst kaydın kimliğini döner.</param>
    /// <param name="YedekKaynak">CozSql boş dönerse (ör. bağsız gelen rapor) kimliğin kendisi bu kaynakta aranır.</param>
    /// <param name="MetinParametre">Yol parametresi sayı değil metin (barkod).</param>
    public sealed record Kural(string Desen, string Parametre, string Kaynak, string Mesaj,
                               string? CozSql = null, Hedef Hedef = Hedef.Kaynak,
                               string? YedekKaynak = null, bool MetinParametre = false);

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext ctx, EndpointFilterDelegate sonraki)
    {
        var http = ctx.HttpContext;
        var desen = (http.GetEndpoint() as RouteEndpoint)?.RoutePattern.RawText ?? "";
        Kural? kural = null;
        foreach (var k in kurallar)
            if (desen.Contains(k.Desen, StringComparison.Ordinal)) { kural = k; break; }
        if (kural is null) return await sonraki(ctx);

        var ham = http.Request.RouteValues[kural.Parametre]?.ToString();
        object parametre;
        long kimlik = 0;
        if (kural.MetinParametre)
        {
            if (string.IsNullOrWhiteSpace(ham)) return await sonraki(ctx);
            parametre = ham;
        }
        else
        {
            if (!long.TryParse(ham, out kimlik) || kimlik <= 0) return await sonraki(ctx);
            parametre = kimlik;
        }

        var iptal = http.RequestAborted;
        var hizmetler = http.RequestServices;
        var baglam = await hizmetler.GetRequiredService<BaglamCozucu>().CozAsync(http, iptal);
        var erisim = hizmetler.GetRequiredService<KayitErisimi>();

        var hedefKimlik = kimlik;
        var kaynak = kural.Kaynak;
        if (kural.CozSql is not null)
        {
            var ust = await hizmetler.GetRequiredService<VeriKaynagi>()
                .TekDegerAsync<long?>(kural.CozSql, [parametre], iptal);
            if (ust is null)
            {
                // Metin parametre (barkod) üst kayda çıkamadıysa kayıt yok demektir.
                if (kural.YedekKaynak is null || kural.MetinParametre)
                    throw GentegreHatasi.Bulunamadi(kural.Mesaj);
                kaynak = kural.YedekKaynak;
            }
            else hedefKimlik = ust.Value;
        }

        if (kural.Hedef == Hedef.LabSatir)
            await erisim.LabSatirIsteAsync(baglam, hedefKimlik, iptal);
        else
            await erisim.IsteAsync(baglam, kaynak, hedefKimlik, kural.Mesaj, iptal);

        return await sonraki(ctx);
    }

    // ------------------------------------------------------------- gruplar ----

    public static KayitKapisi Radyoloji() => new(
    [
        new("/istem/{id", "id", "radyoloji-istem", "Radyoloji istemi bulunamadı."),
        new("/rapor/{id", "id", "radyoloji-istem", "Rapor bulunamadı.",
            "select istem_id from public.radyoloji_rapor where id = @p0"),
        new("/hasta/{id", "id", "hasta", "Hasta bulunamadı."),
    ]);

    public static KayitKapisi Hasta() => new(
    [
        new("/api/hasta/{id", "id", "hasta", "Hasta bulunamadı."),
    ]);

    /// <summary>
    /// Lab: her kimlik istem ya da istem SATIRINA indirgenir — satır yolu tetkik rol iznini de denetler.
    /// Tanım / cihaz / kalite kontrol / arşiv kutusu uçları hasta verisi taşımaz, kuralda yok.
    /// </summary>
    public static KayitKapisi Lab()
    {
        const string istemYok = "İstem bulunamadı.";
        const string numuneYok = "Numune bulunamadı.";
        return new(
        [
            new("/basvuru/{belgeId", "belgeId", "belge", "Başvuru bulunamadı."),
            new("/istem/{id", "id", "lab-istem", istemYok),
            new("/rapor/{istemId", "istemId", "lab-istem", istemYok),
            new("/muayene/{id", "id", "muayene", "Muayene bulunamadı."),
            new("/numune/barkod/{barkod", "barkod", "lab-istem", numuneYok,
                "select istem_id from public.lab_numune where barkod = @p0", MetinParametre: true),
            new("/arsiv/bul/{barkod", "barkod", "lab-istem", numuneYok,
                "select istem_id from public.lab_numune where barkod = @p0", MetinParametre: true),
            new("/calisma-listesi/{barkod", "barkod", "lab-istem", numuneYok,
                "select istem_id from public.lab_numune where barkod = @p0", MetinParametre: true),
            new("/numune/{id", "id", "lab-istem", numuneYok,
                "select istem_id from public.lab_numune where id = @p0"),
            new("/satir/{id", "id", "", "Tetkik satırı bulunamadı.", Hedef: Hedef.LabSatir),
            new("/sonuc/{id", "id", "", "Sonuç bulunamadı.",
                "select istem_satir_id from public.lab_sonuc where id = @p0", Hedef.LabSatir),
            new("/panik/{id", "id", "", "Panik bildirimi bulunamadı.",
                "select s.istem_satir_id from public.lab_panik_bildirim p join public.lab_sonuc s on s.id = p.sonuc_id where p.id = @p0",
                Hedef.LabSatir),
            new("/tekrar/{id", "id", "", "Tekrar isteği bulunamadı.",
                "select istem_satir_id from public.lab_tekrar_istegi where id = @p0", Hedef.LabSatir),
            new("/grafik/{id", "id", "", "Grafik bulunamadı.",
                "select istem_satir_id from public.lab_sonuc_grafik where id = @p0", Hedef.LabSatir),
            new("/kultur/{id", "id", "", "Kültür bulunamadı.",
                "select istem_satir_id from public.lab_kultur where id = @p0", Hedef.LabSatir),
            new("/izolat/{id", "id", "", "İzolat bulunamadı.",
                "select k.istem_satir_id from public.lab_kultur_ureme u join public.lab_kultur k on k.id = u.kultur_id where u.id = @p0",
                Hedef.LabSatir),
            new("/antibiyogram/{id", "id", "", "Antibiyogram bulunamadı.",
                "select k.istem_satir_id from public.lab_antibiyogram a join public.lab_kultur_ureme u on u.id = a.ureme_id "
                + "join public.lab_kultur k on k.id = u.kultur_id where a.id = @p0", Hedef.LabSatir),
            new("/genetik/{id", "id", "lab-istem", "Genetik vaka bulunamadı.",
                "select istem_id from public.lab_genetik_vaka where id = @p0"),
            new("/varyant/{id", "id", "lab-istem", "Varyant bulunamadı.",
                "select v2.istem_id from public.lab_varyant v join public.lab_genetik_vaka v2 on v2.id = v.vaka_id where v.id = @p0"),
            new("/dis/{id", "id", "lab-dis-gonderim", "Dış laboratuvar gönderimi bulunamadı."),
        ]);
    }

    public static KayitKapisi Telerad() => new(
    [
        new("/istek/{id", "id", "telerad-istek", "İstek bulunamadı."),
        new("/teslim/{teslimId", "teslimId", "telerad-istek", "Teslim bulunamadı.",
            "select istek_id from public.telerad_teslim where id = @p0"),
        // Gelen rapor henüz bir isteğe bağlanmamış olabilir: o zaman kendi kaynağında (şube) aranır.
        new("/gelen/{gelenId", "gelenId", "telerad-istek", "Gelen rapor bulunamadı.",
            "select istek_id from public.telerad_gelen where id = @p0", YedekKaynak: "telerad-gelen"),
    ]);

    public static KayitKapisi Isg() => new(
    [
        new("/firma/{id", "id", "isg-firma", "Firma bulunamadı."),
        new("/calisan/{id", "id", "isg-calisan", "Çalışan bulunamadı."),
        new("/muayene/{id", "id", "isg-muayene", "Muayene bulunamadı."),
        new("/olay/{id", "id", "isg-olay", "Olay bulunamadı."),
    ]);

    // KAYIT KAPSAMI (kod inceleme 30.10.2026 K26): kurum içi özel uçlar da `where id = @p0` ile çalışıyordu -
    //   başka şubenin ya da kullanici_kapsam dışındaki hastanın muayenesi / reçetesi / eczane kaydı kimlikle
    //   okunup yazılabiliyordu. Aşağıdaki gruplar liste ile aynı kuralı (şube + kapsam + hekim kısıtı) uygular.

    /// <summary>
    /// Muayene: yol kimliği muayene; istem (<c>/istem/{id}/gordu</c>) ve rapor (<c>/rapor/{raporId}</c>)
    /// kimlikleri ara SQL ile muayeneye çıkar; <c>/basvuru/{belgeId}/al</c> başvuru belgesini denetler.
    /// Alt kayıt (tanı, bulgu) kimlikleri handler'da zaten <c>muayene_id = @id</c> ile bağlı.
    /// Özel desenler genel <c>/{id</c>'den ÖNCE: <c>/istem/{id:int}/gordu</c> ikisini de içerir.
    /// </summary>
    public static KayitKapisi Muayene()
    {
        const string muayeneYok = "Muayene bulunamadi.";
        return new(
        [
            new("/istem/{id", "id", "muayene", "Istem bulunamadi.",
                "select muayene_id from public.muayene_istem where id = @p0"),
            new("/rapor/{raporId", "raporId", "muayene", "Rapor bulunamadı.",
                "select muayene_id from public.muayene_rapor where id = @p0"),
            new("/basvuru/{belgeId", "belgeId", "belge", "Basvuru bulunamadi."),
            new("/{id", "id", "muayene", muayeneYok),
        ]);
    }

    /// <summary>
    /// Reçete: <c>/{id}/ilac/{satirId}</c> ve <c>/{id}/imzala</c> reçete kapsamından geçer (satır handler'da
    /// <c>recete_id = @id</c> ile bağlı); <c>/hasta/{hastaId}/taslak</c> hasta, <c>/muayene/{muayeneId}</c> muayene.
    /// </summary>
    public static KayitKapisi Recete() => new(
    [
        new("/hasta/{hastaId", "hastaId", "hasta", "Hasta bulunamadı."),
        new("/muayene/{muayeneId", "muayeneId", "muayene", "Muayene bulunamadi."),
        new("/{id", "id", "recete", "Recete bulunamadi."),
    ]);

    /// <summary>
    /// Eczane iş akışı: her alt yol kendi katalog kaynağına. Kontrollü sayım (<c>/sayim/{id}</c>) için liste
    /// kaynağı yok - şube koşulu handler'da. Gövdeden gelen imha / defter kimlikleri handler'da denetlenir.
    /// </summary>
    public static KayitKapisi Eczane() => new(
    [
        new("/kontrol/{id", "id", "eczaneKontrol", "Eczacı kontrolü bulunamadı."),
        new("/doz/{id", "id", "eczaneDoz", "Doz kaydı bulunamadı."),
        new("/hazirlama/{id", "id", "eczaneHazirlama", "Hazırlama kaydı bulunamadı."),
        new("/iade/{id", "id", "eczaneIade", "İade kaydı bulunamadı."),
        new("/imha/{id", "id", "eczaneImha", "İmha tutanağı bulunamadı."),
    ]);

    /// <summary>
    /// FTR: program ve seans kimlikleri; uygulama satırları (<c>/program/uygulama/{id}</c>,
    /// <c>/seans/uygulama/{id}</c>) ara SQL ile üst kayda çıkar - genel desenlerden önce.
    /// </summary>
    public static KayitKapisi Ftr() => new(
    [
        new("/program/uygulama/{id", "id", "ftr-program", "Uygulama bulunamadı.",
            "select program_id from public.ftr_program_uygulama where id = @p0"),
        new("/seans/uygulama/{id", "id", "ftr-seans", "Seans uygulaması bulunamadı.",
            "select seans_id from public.ftr_seans_uygulama where id = @p0"),
        new("/program/{id", "id", "ftr-program", "Program bulunamadı."),
        new("/seans/{id", "id", "ftr-seans", "Seans bulunamadı."),
    ]);

    /// <summary>Çocuk izlem: <c>/hasta/{id}</c> hasta, <c>/{id}/iptal</c> izlem kaydı. Gövdedeki hasta handler'da.</summary>
    public static KayitKapisi CocukIzlem() => new(
    [
        new("/hasta/{id", "id", "hasta", "Hasta bulunamadı."),
        new("/{id", "id", "cocuk-izlem", "İzlem kaydı bulunamadı."),
    ]);

    /// <summary>
    /// Form (yetkili grup): istek kimliği <c>form-istek</c> kaynağından (şube), <c>/hasta/{hastaId}</c> hasta.
    /// Şablon uçları ana veridir (şubesiz), kuralda yok; açık (anonim) grup bu kapıdan geçmez.
    /// </summary>
    public static KayitKapisi Form() => new(
    [
        new("/istek/{id", "id", "form-istek", "Form isteği bulunamadı."),
        new("/hasta/{hastaId", "hastaId", "hasta", "Hasta bulunamadı."),
    ]);

    /// <summary>
    /// GÖZ (K26): göz muayenesi / görüntüleme / gözlük reçetesi / akış satırı / hasta / cihaz kimlikleri kendi
    /// katalog kaynağından geçer. <c>/akis/{id</c> kaynağı <c>v_goz_unite_akis</c>'tir (yalnız AÇIK satırlar) -
    /// akış uçlarının tümü zaten açık satır üzerinde çalışır. Tanım uçları (<c>/dikte/sozluk</c>,
    /// <c>/tetkik-hizmet</c>, göstergeler) kimlik taşımaz, kuralda yok.
    /// </summary>
    public static KayitKapisi Goz() => new(
    [
        new("/muayene-uzanti/{muayeneId", "muayeneId", "muayene", "Muayene bulunamadı."),
        new("/muayene/{id", "id", "goz-muayene", "Göz muayenesi bulunamadı."),
        new("/goruntuleme/{id", "id", "goz-goruntuleme", "Görüntüleme bulunamadı."),
        new("/gozluk/{id", "id", "goz-gozluk-recete", "Reçete bulunamadı."),
        new("/akis/{id", "id", "goz-akis", "Akış kaydı bulunamadı."),
        new("/hasta/{hastaId", "hastaId", "hasta", "Hasta bulunamadı."),
        new("/cihaz-mesaj/{id", "id", "goz-cihaz-mesaj", "Cihaz mesajı bulunamadı."),
        new("/cihaz/{id", "id", "goz-cihaz", "Cihaz bulunamadı."),
    ]);

    /// <summary>
    /// ÇAĞRI MERKEZİ (K26): çağrı / kampanya / kampanya kişisi kimlikleri şube kapsamından geçer.
    /// Agent (<c>/supervizor/agent/{kullaniciId</c>) ve santral ayarı şubesiz tanımdır, kuralda yok;
    /// anonim santral webhook'u ayrı grupta, bu kapıdan geçmez.
    /// </summary>
    public static KayitKapisi Cagri() => new(
    [
        new("/geri-arama/{cagriId", "cagriId", "cagri", "Çağrı bulunamadı."),
        new("/kampanya-kisi/{id", "id", "cagri-kampanya-kisi", "Kampanya kişisi bulunamadı."),
        new("/kampanya/{id", "id", "cagri-kampanya", "Kampanya bulunamadı."),
        new("/cagri/{id", "id", "cagri", "Çağrı bulunamadı."),
    ]);

    /// <summary>ACİL SERVİS (K26): başvuru / çağrı / yatak kimlikleri şube (başvuruda ayrıca hasta kapsamı) kuralından geçer.</summary>
    public static KayitKapisi Acil() => new(
    [
        new("/basvuru/{id", "id", "acilBasvuru", "Acil başvurusu bulunamadı."),
        new("/cagri/{id", "id", "acilCagri", "Çağrı bulunamadı."),
        new("/yatak/{id", "id", "acilYatak", "Yatak bulunamadı."),
    ]);

    /// <summary>AMELİYATHANE (K26): ameliyat ve talep kimlikleri şube kuralından geçer (fatura / stok / ÜTS uçları dahil).</summary>
    public static KayitKapisi Ameliyathane() => new(
    [
        new("/ameliyat/{id", "id", "ameliyat", "Ameliyat bulunamadı."),
        new("/talep/{id", "id", "ameliyatTalep", "Ameliyat talebi bulunamadı."),
    ]);

    /// <summary>BİYOMEDİKAL / DEMİRBAŞ (K26): iş emri / kalibrasyon / demirbaş kimlikleri şube kuralından geçer.</summary>
    public static KayitKapisi Biyomedikal() => new(
    [
        new("/is-emri/{id", "id", "demirbasIsEmri", "İş emri bulunamadı."),
        new("/kalibrasyon/{id", "id", "demirbasKalibrasyon", "Kalibrasyon kaydı bulunamadı."),
        new("/demirbas/{id", "id", "demirbas", "Demirbaş bulunamadı."),
    ]);
}
