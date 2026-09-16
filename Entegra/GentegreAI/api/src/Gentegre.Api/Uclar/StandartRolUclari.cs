using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STANDART ROLLER (712, kullanıcı: "standart rolleri kur düğmesini ekle").
/// Kurum tipine göre hazır rol şablonları (Kayıt Kabul, Hekim, Hemşire,
/// Muhasebe, Diş Hekimi, Radyolog, Lab Teknisyeni…). Şablon = rol + yetki
/// kalıpları (yetki kodu deseni × gör/ekle/değiştir/sil). Kurulum sonrası
/// yönetici rolleri tek tek elle açıp 150 yetkiyi işaretliyordu; tipin
/// standart seti tek tıkla kurulur, sonra yetki matrisinden inceltilir.
///
/// Kurallar: var olan rol (aynı kod) EZİLMEZ - yalnız `guncelle` istenirse
/// yetkileri şablona çekilir; rol tüm aktif şubelere yazma hakkıyla bağlanır;
/// modülü kapalı kurumda o modülün yetkileri yine yazılır (modül açılınca
/// rol hazır olsun), ekranda görünmezler (`fn_kurum_modul_acik`).
/// </summary>
public static class StandartRolUclari
{
    /// <summary>Yetki kalıbı: `desen` SQL LIKE (yetki.kod), `tam` = kodların birebir listesi.</summary>
    private sealed record Kural(string Desen, bool Gor = true, bool Ekle = false, bool Degistir = false, bool Sil = false);
    private sealed record Sablon(string Kod, string Ad, string Amac, string[] Tipler, Kural[] Kurallar);

    private const string TUM = "*";
    private static readonly string[] Klinik = ["muayenehane", "dal_goz", "dal_ftr", "goruntuleme", "lab", "goruntuleme_lab", "dis", "tip_merkezi", "hastane"];

    // Her rolde: ana sayfa, mesaj, görev, dökümler, AI rehber (gör).
    private static readonly Kural[] Ortak = [new("panel"), new("mesaj", true, true, true), new("gorev", true, true, true), new("dokum"), new("ai"), new("ai.rehber"), new("dokuman", true, true)];
    private static Kural[] K(params Kural[] k) => [.. Ortak, .. k];
    private static Kural T(string d) => new(d, true);                       // gör
    private static Kural Y(string d) => new(d, true, true, true);           // gör+ekle+değiştir
    private static Kural H(string d) => new(d, true, true, true, true);     // hepsi
    private static Kural A(string d) => new(d, true);                        // aksiyon (tur 1): gör = izin

    private static readonly Kural[] HekimTemel =
    [
        Y("muayene"), T("hasta"), Y("randevu"), T("belge"), T("belge_satir"), T("taraf"), Y("lab"), T("lab.sonuc"),
        Y("radyoloji-istem"), A("rad.istem_ac"), A("rad.istem_iptal"), T("radyoloji"), T("katalog"), Y("onam"),
        T("prim.kendi"), Y("medula.recete"), Y("medula.hizmet"), T("medula"), T("hizmet"), T("kurum"), T("klinik_kalite.olgu"),
        T("islem_log"),
    ];
    private static readonly Kural[] KayitKabulTemel =
    [
        Y("hasta"), Y("randevu"), Y("belge"), Y("belge_satir"), Y("taraf"), Y("cari"), T("kurum"), T("hizmet"), T("fiyat_listesi"),
        Y("sigorta"), A("sigorta.provizyon"), A("sigorta.iptal"), Y("medula.provizyon"), T("medula"), Y("kasa_islem"), Y("mali_hareket"),
        T("hesap"), A("kasa.makbuz-yazdir"), Y("onam"), T("bildirim"), T("iskonto_onay"), T("muayene"), Y("aday"),
    ];
    private static readonly Kural[] MuhasebeTemel =
    [
        H("belge"), H("belge_satir"), H("cari"), H("taraf"), H("kasa_islem"), H("mali_hareket"), H("hesap"), H("hesap_plani"), H("muhasebe_fis"),
        H("cek_senet"), H("kredi"), H("masraf"), H("masraf_merkezi"), H("kasa_kapatma"), T("kasa_islem_turu"), H("e_belge"), T("ebelge_seri"),
        T("ebelge_xslt"), H("fiyat_listesi"), A("fiyat_listesi.uret"), H("kurum"), T("hasta"), T("hizmet"), Y("medula.fatura"), T("medula"),
        T("medula.ayar"), T("sigorta"), H("prim"), T("doviz_kur"), T("demirbas"), T("stok"), T("islem_log"),
        A("belge.kesinlestir"), A("belge.iptal"), A("belge.donustur"), A("kasa.%"), A("ceksenet.%"), A("ebelge.%"), A("fis.ters-kayit"),
        A("muhasebe.donem-kilitle"), A("kredi.taksit-ode"), A("prim.%"), A("veri.disa-aktar"), A("basvuru.iskonto"),
    ];

    private static readonly Sablon[] Sablonlar =
    [
        new("kayit_kabul", "Kayıt Kabul / Banko", "Hasta kaydı, randevu, başvuru, provizyon, fiş ve tahsilat.", Klinik, K(KayitKabulTemel)),
        new("hekim", "Hekim", "Muayene, tanı, istem, reçete ve rapor; kendi hakedişi.", ["muayenehane", "tip_merkezi", "hastane"], K(HekimTemel)),
        new("hemsire", "Hemşire", "Vital, enjeksiyon, pansuman, numune; muayene kaydına yardım.", ["tip_merkezi", "hastane", "dal_ftr"],
            K(T("hasta"), Y("muayene"), T("randevu"), Y("lab.numune"), T("lab"), Y("onam"), T("katalog"), T("belge"))),
        new("muhasebe", "Muhasebe / Finans", "Fatura, kasa-banka, dönem sonlandırma, kesinti ve itiraz.", Klinik, K(MuhasebeTemel)),
        new("vezne", "Vezne", "Tahsilat, makbuz, fatura kapatma.", ["tip_merkezi", "hastane"],
            K(Y("kasa_islem"), Y("mali_hareket"), T("hesap"), Y("kasa_kapatma"), A("kasa.kapat"), A("kasa.makbuz-yazdir"), A("kasa.kesinlestir"), T("belge"), T("hasta"), T("cari"))),
        new("rapor_goruntuleyici", "Yönetim Görüntüleyici", "Kurum sahibi / mesul müdür: salt okuma dökümler ve günlük.", Klinik,
            K(T("%"), new("ayar", false), new("rol", false), new("kullanici", false), new("sube", false), new("referans", false), new("entegrasyon", false), new("dokuman.ozel_nitelikli", false))),
        new("kalite", "Kalite Sorumlusu", "Klinik kalite göstergeleri, dönem hesabı, doküman onayı; klinik ekranlar salt okuma.", Klinik,
            K(H("klinik_kalite"), H("klinik_kalite.%"), A("klinik_kalite.%"), Y("dokuman.onayla"), T("islem_log"), T("hasta"), T("muayene"), T("lab"), T("radyoloji"), T("yatan"))),
        new("medula_sorumlu", "Medula Sorumlusu", "SGK kuyruğu, hizmet kaydı, fatura, dönem sonlandırma, kesinti.", ["tip_merkezi", "hastane", "dal_goz", "dal_ftr", "dis", "goruntuleme", "goruntuleme_lab"],
            K(H("medula"), H("medula.%"), A("medula.donem"), T("kurum"), T("belge"), T("hasta"), T("hizmet"))),
        new("bilgi_islem", "Bilgi İşlem Sorumlusu", "Kullanıcı, rol ve şube tanımı, ayarlar, entegrasyon ve cihaz hesapları, işlem günlüğü; hasta verisi görmez.", Klinik,
            K(H("kullanici"), A("kullanici.parola-sifirla"), H("rol"), H("sube"), H("ayar"), H("referans"), H("entegrasyon"), H("cihaz"), A("cihaz.isle"),
              H("kod_liste"), H("numara_sablonu"), H("bildirim_sablon"), Y("bildirim"), T("islem_log"), A("log.geri-al"), H("dokuman"), H("katalog"),
              T("medula.ayar"), A("sigorta.ayar"), H("goz.cihaz"), H("lab.cihaz"), H("ebelge_seri"), H("ebelge_xslt"), A("veri.iceri-al"), A("veri.disa-aktar"))),
        // ---- diş
        new("dis_hekimi", "Diş Hekimi", "Odontogram, tedavi planı, seans, yapıldı ve ücretlendirme.", ["dis", "tip_merkezi", "hastane"],
            K([.. HekimTemel, H("dis"), H("dis.%"), A("dis.plan.onayla"), A("dis.seans.bitir"), A("dis.plan.fiyat_degistir"), T("dis.unit")])),
        new("dis_asistan", "Diş Asistanı", "Seans sarf ve sterilizasyon, hekim adına odontogram girişi, lab iş emri.", ["dis"],
            K(Y("dis.hasta"), Y("dis.seans"), Y("dis.lab"), Y("dis.muayene"), T("dis"), T("dis.plan"), T("hasta"), T("randevu"), T("stok"))),
        new("tedavi_danismani", "Tedavi Danışmanı", "Proforma sunma, hasta onayı, ödeme planı ve tahsilat takibi.", ["dis"],
            K(Y("dis.plan"), A("dis.plan.onayla"), H("dis.odeme"), T("dis"), T("dis.hasta"), T("hasta"), Y("randevu"), Y("kasa_islem"), T("belge"), T("fiyat_listesi"))),
        new("dis_lab_sorumlu", "Lab Sorumlusu (Protez)", "Lab iş emirleri, kurye, aşama takibi, lab faturası eşleme.", ["dis"],
            K(H("dis.lab"), T("dis"), T("dis.unit"), T("dis.hasta"), T("hasta"), T("cari"))),
        // ---- göz
        new("goz_hekimi", "Göz Hekimi", "Göz muayenesi, görüntüleme değerlendirme, işlem, reçete, takip.", ["dal_goz", "tip_merkezi", "hastane"],
            K([.. HekimTemel, H("goz"), H("goz.%"), A("goz.goruntuleme.degerlendir"), A("goz.islem.uygula")])),
        new("optometrist", "Optometrist / Refraksiyonist", "Ön tetkik, ölçüm, gözlük-lens reçetesi hazırlığı.", ["dal_goz"],
            K(Y("goz.on_tetkik"), Y("goz.recete"), Y("goz.goruntuleme"), T("goz"), T("goz.muayene"), T("hasta"), T("randevu"))),
        new("goz_teknisyen", "Göz Teknisyeni", "Görüntüleme (OCT, FFA), cihaz, ön tetkik.", ["dal_goz"],
            K(Y("goz.on_tetkik"), Y("goz.goruntuleme"), T("goz.cihaz"), T("goz"), Y("cihaz"), A("cihaz.isle"), T("hasta"), T("randevu"))),
        // ---- FTR
        new("ftr_uzmani", "FTR Uzmanı", "Değerlendirme, program, seans onayı.", ["dal_ftr"], K(HekimTemel)),
        new("fizyoterapist", "Fizyoterapist", "Seans uygulama ve seans notu.", ["dal_ftr", "tip_merkezi", "hastane"],
            K(Y("muayene"), T("hasta"), Y("randevu"), T("belge"), Y("onam"), T("prim.kendi"))),
        // ---- görüntüleme
        new("radyolog", "Radyolog", "Rapor yazma ve onay, sonuç teslimi.", ["goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(H("radyoloji"), H("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"), A("rad.teslim"), A("rad.istem_iptal"), T("hasta"), T("katalog"), T("muayene"), T("prim.kendi"))),
        new("rad_teknisyen", "Radyoloji Teknisyeni", "Çekim, cihaz, sonuç teslimi.", ["goruntuleme", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("radyoloji"), Y("radyoloji-istem"), Y("cihaz"), A("cihaz.isle"), A("rad.teslim"), T("hasta"), T("randevu"))),
        new("teleradyoloji_hekim", "Teleradyoloji Hekimi (dış)", "Yalnız rapor yazma ve onay; kayıt/kabul görmez.", ["goruntuleme", "goruntuleme_lab"],
            K(T("radyoloji"), T("radyoloji-istem"), A("rad.rapor_yaz"), A("rad.rapor_onayla"))),
        // ---- laboratuvar
        new("lab_uzmani", "Lab Uzmanı", "Sonuç onayı, kalite kontrol serbest bırakma, katalog.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(H("lab"), H("lab.%"), A("lab.onay"), A("lab.kk.onay"), T("hasta"), T("katalog"), T("cihaz"), T("prim.kendi"))),
        new("lab_teknisyen", "Lab Teknisyeni", "Numune, cihaz, sonuç girişi, iç-dış kalite kontrol.", ["lab", "goruntuleme_lab", "tip_merkezi", "hastane"],
            K(Y("lab"), Y("lab.numune"), Y("lab.sonuc"), Y("lab.kk"), Y("lab.cihaz"), Y("lab.kultur"), T("lab.mikro"), T("lab.tetkik"), Y("cihaz"), A("cihaz.isle"), T("hasta"))),
        new("numune_kabul", "Numune Kabul", "Numune kabul, barkod, dış laboratuvar gönderimi.", ["lab", "goruntuleme_lab"],
            K(Y("lab"), H("lab.numune"), Y("lab.dislab"), T("lab.sonuc"), Y("hasta"), Y("belge"), T("randevu"))),
        new("dis_istem_kurumu", "Dış İstem Kurumu (portal)", "Anlaşmalı kurum: istem girer, kendi sonuçlarını görür.", ["lab", "goruntuleme_lab"],
            K(new("lab", true, true), T("lab.sonuc"), T("hasta"))),
        // ---- eczane / depo
        new("eczane_depo", "Eczane / Depo", "İlaç-sarf stoğu, karekod (ÜTS), depo hareketleri.", ["tip_merkezi", "hastane"],
            K(H("stok"), H("depo"), T("katalog"), H("uts"), A("uts.%"), T("yatan"), T("belge"), Y("belge_satir"))),
        // ---- yatan hasta
        new("yatan_hemsire", "Yatan Hasta Hemşiresi", "Order uygulama, ilaç, hemşire gözlemi.", ["hastane"],
            K(Y("yatan"), T("hasta"), T("muayene"), T("katalog"), Y("lab.numune"), T("lab"), Y("onam"))),
        new("yatis_ofisi", "Yatış / Taburcu Ofisi", "Yatış, oda-yatak, taburcu ve tahakkuk.", ["hastane"],
            K(Y("yatan"), Y("hasta"), Y("belge"), Y("belge_satir"), Y("randevu"), T("kurum"), Y("medula.provizyon"), T("medula"))),
    ];

    public static void StandartRolUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kurum-profil/standart-roller").WithTags("KurumProfil").RequireAuthorization();

        // Önizleme: tipin şablonları + hangileri zaten var.
        grup.MapGet("/", async (string? kurumTipi, VeriKaynagi veri, BaglamCozucu cozucu, KurumProfilDeposu profil,
                                HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Gor);
            var tip = kurumTipi ?? await KurumTipiAsync(profil, baglam.SubeId ?? 0, iptal);
            await using var b = await veri.AcAsync(iptal);
            var mevcut = await b.ListeAsync("select kod, id, ad, aktif from public.rol", null, [],
                o => new { kod = o.GetString(0), id = o.GetInt32(1), ad = o.GetString(2), aktif = o.GetInt16(3) == 1 }, iptal);
            var yetkiler = await YetkilerAsync(b, iptal);
            var liste = Sablonlar.Where(s => s.Tipler.Contains(tip) || s.Tipler.Contains(TUM)).Select(s =>
            {
                var m = mevcut.FirstOrDefault(x => x.kod == s.Kod);
                var esle = Eslestir(s, yetkiler);
                return new { s.Kod, s.Ad, s.Amac, mevcut = m is not null, rolId = m?.id, aktif = m?.aktif,
                             yetkiSayisi = esle.Count, ekran = esle.Count(x => x.tur == 0), aksiyon = esle.Count(x => x.tur == 1) };
            }).ToList();
            return Results.Ok(new { kurumTipi = tip, roller = liste });
        });

        // Kur: seçilen şablonlar (boşsa tipin hepsi). Var olan rol atlanır;
        //   `guncelle` ile yetkileri şablona çekilir (rol adı/amacı korunur).
        grup.MapPost("/", async (KurIstegi istek, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, KurumProfilDeposu profil,
                                 HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("rol", Islem.Ekle);
            var tip = istek.KurumTipi ?? await KurumTipiAsync(profil, baglam.SubeId ?? 0, iptal);
            var secim = Sablonlar.Where(s => (s.Tipler.Contains(tip) || s.Tipler.Contains(TUM))
                                          && (istek.Kodlar is null || istek.Kodlar.Count == 0 || istek.Kodlar.Contains(s.Kod))).ToList();
            if (secim.Count == 0) throw GentegreHatasi.Dogrulama("Bu kurum tipi için şablon yok.");

            await using var b = await veri.AcAsync(iptal);
            var yetkiler = await YetkilerAsync(b, iptal);
            var subeler = await b.ListeAsync("select id, varsayilan from public.sube where aktif = 1 order by id", null, [],
                o => new { id = o.GetInt32(0), varsayilan = o.GetInt16(1) == 1 }, iptal);
            var kuruldu = new List<string>(); var guncellendi = new List<string>(); var atlandi = new List<string>();
            await using var islem = await b.BeginTransactionAsync(iptal);
            foreach (var s in secim)
            {
                var rolId = await b.TekDegerAsync<int?>("select id from public.rol where kod = @p0", islem, [s.Kod], iptal);
                if (rolId is int varId)
                {
                    if (istek.Guncelle != true) { atlandi.Add(s.Ad); continue; }
                    await YetkileriYazAsync(b, islem, varId, s, yetkiler, baglam.KullaniciId, true, iptal);
                    guncellendi.Add(s.Ad);
                    await log.YazAsync(b, islem, LogIslemi.Degistir, LogTabloRol, varId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                        new { standartSablon = s.Kod, kurumTipi = tip }, iptal: iptal);
                    continue;
                }
                var yeniId = await b.TekDegerAsync<int>("""
                    insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen) values (@p0, @p1, @p2, 0, 1, @p3) returning id
                    """, islem, [s.Kod, s.Ad, s.Amac, baglam.KullaniciId], iptal);
                await YetkileriYazAsync(b, islem, yeniId, s, yetkiler, baglam.KullaniciId, false, iptal);
                foreach (var sb in subeler)
                    await b.CalistirAsync("""
                        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen) values (@p0, @p1, @p2, 1, @p3)
                        on conflict do nothing
                        """, islem, [yeniId, sb.id, (short)(sb.varsayilan ? 1 : 0), baglam.KullaniciId], iptal);
                kuruldu.Add(s.Ad);
                await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloRol, yeniId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new { standartSablon = s.Kod, kurumTipi = tip, s.Ad }, iptal: iptal);
            }
            await islem.CommitAsync(iptal);
            return Results.Ok(new { kurumTipi = tip, kuruldu, guncellendi, atlandi });
        });
    }

    public sealed record KurIstegi(string? KurumTipi, List<string>? Kodlar, bool? Guncelle);
    private const int LogTabloRol = 903;   // rol karti ile ayni (KartKatalogu.Cari.Hasta)

    private sealed record YetkiSatir(int id, string kod, short tur);

    private static async Task<string> KurumTipiAsync(KurumProfilDeposu depo, int subeId, CancellationToken iptal)
    {
        var (profil, _, _, _, _, _, _) = await depo.OkuAsync(subeId, iptal);
        return string.IsNullOrEmpty(profil.KurumTipi) ? "tip_merkezi" : profil.KurumTipi;
    }

    private static Task<List<YetkiSatir>> YetkilerAsync(NpgsqlConnection b, CancellationToken iptal)
        => b.ListeAsync("select id, kod, tur from public.yetki where aktif = 1", null, [],
            o => new YetkiSatir(o.GetInt32(0), o.GetString(1), o.GetInt16(2)), iptal);

    /// <summary>Şablon kurallarını yetki tablosuna uygular; sonraki kural öncekini ezer (ör. "%" gör + "ayar" kapalı).</summary>
    private static List<(int id, short tur, bool gor, bool ekle, bool degistir, bool sil)> Eslestir(Sablon s, List<YetkiSatir> yetkiler)
    {
        var sonuc = new Dictionary<int, (int id, short tur, bool gor, bool ekle, bool degistir, bool sil)>();
        foreach (var k in s.Kurallar)
        {
            var desen = "^" + System.Text.RegularExpressions.Regex.Escape(k.Desen).Replace("%", ".*") + "$";
            foreach (var y in yetkiler.Where(y => System.Text.RegularExpressions.Regex.IsMatch(y.kod, desen)))
            {
                // "%" gibi geniş desen aksiyonları (tur 1) kapsamaz: aksiyon açıkça istenir.
                if (k.Desen.Contains('%') && y.tur == 1 && !k.Desen.Contains('.')) continue;
                if (!k.Gor) { sonuc.Remove(y.id); continue; }
                sonuc[y.id] = (y.id, y.tur, k.Gor, k.Ekle, k.Degistir, k.Sil);
            }
        }
        return [.. sonuc.Values];
    }

    private static async Task YetkileriYazAsync(NpgsqlConnection b, NpgsqlTransaction islem, int rolId, Sablon s,
        List<YetkiSatir> yetkiler, int kullaniciId, bool temizle, CancellationToken iptal)
    {
        if (temizle) await b.CalistirAsync("delete from public.rol_yetki where rol_id = @p0", islem, [rolId], iptal);
        foreach (var e in Eslestir(s, yetkiler))
            await b.CalistirAsync("""
                insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen) values (@p0, @p1, @p2, @p3, @p4, @p5, @p6)
                on conflict (rol_id, yetki_id) do update set gor = excluded.gor, ekle = excluded.ekle, degistir = excluded.degistir, sil = excluded.sil
                """, islem, [rolId, e.id, (short)(e.gor ? 1 : 0), (short)(e.ekle ? 1 : 0), (short)(e.degistir ? 1 : 0), (short)(e.sil ? 1 : 0), kullaniciId], iptal);
        // Yetki önbelleği rol sürümüyle geçersizlenir (YetkiCozucu).
        await b.CalistirAsync("update public.rol set yetki_surumu = yetki_surumu + 1 where id = @p0", islem, [rolId], iptal);
    }
}
