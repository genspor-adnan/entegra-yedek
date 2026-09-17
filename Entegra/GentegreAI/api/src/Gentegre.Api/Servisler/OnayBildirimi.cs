using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ONAY BİLDİRİMİ (741) — sırası gelene haber, sonucu talep sahibine.
///
/// ============ NEDEN KUYRUĞA BAKMAK YETMEZ ============================
/// 738'de kutu vardı ama kimse haberdar olmuyordu: onay, kişinin kutuyu
/// açma alışkanlığına kalmıştı. Acil bir talep, âmiri o gün sisteme
/// girmediği için bekler; kurum da çareyi telefonla aramada bulur - o
/// noktada zincirin kaydı ile gerçekte olan iş birbirinden ayrılır.
///
/// ============ BİLDİRİM GÖNDERİMİ DEĞİL, KUYRUĞA ALMADIR ==============
/// Burada yalnız `bildirim` kuyruğuna satır yazılır; gönderimi mevcut
/// `BildirimIscisi` yapar. Uçtan doğrudan SMS/e-posta göndermeye kalksaydık
/// onay kararı, sağlayıcı yavaşladığında ya da hata verdiğinde bekler ya da
/// geri alınırdı - imza, bildirimin başarısına bağlı olamaz.
///
/// ============ SESSİZ BAŞARISIZLIK YOK, İŞLEMİ DE DÜŞÜRMEZ ============
/// Bildirim yazılamazsa (şablon pasif, alıcı yok) karar YİNE DE geçerlidir;
/// hata günlüğe düşer. Tersi olsaydı iletişim ayarı eksik bir kurumda hiçbir
/// onay verilemezdi.
/// </summary>
public sealed class OnayBildirimi
{
    private readonly BildirimDeposu _bildirim;
    private readonly ILogger<OnayBildirimi> _gunluk;

    public OnayBildirimi(BildirimDeposu bildirim, ILogger<OnayBildirimi> gunluk)
    {
        _bildirim = bildirim;
        _gunluk = gunluk;
    }

    // BAGLANTI CAGIRANDAN GELIR: karar ucu zaten bir islem icinde; burada
    //   ikinci bir baglanti acmak, ayni islemde yazilmis satirlari
    //   gormeyen bir okuma demek olurdu.

    /// <summary>bildirim.kaynak_tur - onay zinciri.</summary>
    public const short KaynakOnay = 21;

    // ===================================================== sırası gelene ==

    /// <summary>
    /// Sırası gelen basamağın sahiplerine "onayınız bekleniyor" yazar.
    ///
    /// ROL BASAMAĞINDA HERKESE: rol basamağını o rolün her üyesi
    /// imzalayabilir; yalnız birine haber vermek, "kim bakacak" sorusunu
    /// kuruma bırakmak olurdu. Kişiye atanmış basamakta yalnız o kişi (ve
    /// varsa vekili) - vekile de yazılır, çünkü vekâletin anlamı tam olarak
    /// işin durmamasıdır.
    /// </summary>
    public async Task<int> SiradakiniBildirAsync(
        NpgsqlConnection baglanti, long onayId, int kullaniciId, int? subeId,
        CancellationToken iptal = default)
    {
        var a = await baglanti.TekAsync("""
            select v.id as "adimId", v.kaynak_tur as "kaynakTur",
                   v.kaynak_id as "kaynakId", v.adim_ad as "adimAd", v.rol,
                   v.atanan_kullanici_id as "atananId", v.akis_ad as "akisAd",
                   v.akis_kod as "akisKod", v.olcu, v.olcu_adi as "olcuAdi",
                   v.termin, v.kayit_no as "kayitNo", v.konu
              from public.v_onay_kutusu v
             where v.onay_id = @p0
             order by v.sira limit 1
            """, null, [onayId], OkuyucuGenisletmeleri.Sozluk, iptal);

        if (a is null) return 0;   // bekleyen basamak yok - zincir bitmiş

        var aliciIdler = await AlicilarAsync(baglanti, a["akisKod"] as string ?? "",
            Convert.ToInt16(a["rol"] ?? (short)0), a["atananId"] as int?, iptal);

        var degiskenler = new Dictionary<string, string>
        {
            ["akisAd"] = a["akisAd"] as string ?? "",
            ["kayitNo"] = a["kayitNo"] as string ?? "",
            ["konu"] = a["konu"] as string ?? "",
            ["adimAd"] = a["adimAd"] as string ?? "",
            ["olcu"] = Convert.ToDecimal(a["olcu"] ?? 0m).ToString("N2"),
            ["olcuAdi"] = a["olcuAdi"] as string ?? "",
            ["termin"] = a["termin"] is DateTime t ? t.ToString("dd.MM.yyyy") : "-",
            ["gecikmeGun"] = "0",
        };

        return await YazAsync(baglanti, aliciIdler, "onay.istek", degiskenler,
            Convert.ToInt64(a["adimId"]), kullaniciId, subeId, iptal);
    }

    // ========================================================== sonuç ==

    /// <summary>
    /// Zincir bitince TALEBİ AÇANA yazar. Onaylayanlara ayrıca yazmıyoruz:
    /// kararı onlar verdi, haber onlara değil bekleyene lazım.
    /// </summary>
    public async Task<int> SonucBildirAsync(
        NpgsqlConnection baglanti, long onayId, short zincirDurum, string? gerekce,
        int kullaniciId, int? subeId, CancellationToken iptal = default)
    {
        var n = await baglanti.TekAsync("""
            select o.baslatan_id as "baslatanId", o.kaynak_tur as "kaynakTur",
                   o.kaynak_id as "kaynakId", k.ad as "akisAd",
                   case o.kaynak_tur
                        when 1241 then coalesce(nullif(t.talep_no, ''),
                                                '#' || o.kaynak_id::text)
                        when 904  then coalesce(nullif(z.izin_no, ''),
                                                'İzin #' || o.kaynak_id::text)
                        when 1224 then coalesce(nullif(w.is_emri_no, ''),
                                                'İş emri #' || o.kaynak_id::text)
                        when 1257 then coalesce(nullif(av.avans_no, ''),
                                                'Avans #' || o.kaynak_id::text)
                        when 1256 then coalesce(nullif(ib.belge_no, ''),
                                                'Başvuru #' || o.kaynak_id::text)
                        when 976  then coalesce(nullif(dk.kod, ''), 'Doküman')
                                       || ' v' || coalesce(ds.surum_no::text, '?')
                        else '#' || o.kaynak_id::text end as "kayitNo"
              from public.onay o
              left join public.onay_akis k on k.id = o.akis_id
              left join public.satinalma_talep t
                     on o.kaynak_tur = 1241 and t.id = o.kaynak_id
              left join public.personel_izin z
                     on o.kaynak_tur = 904 and z.id = o.kaynak_id
              left join public.demirbas_is_emri w
                     on o.kaynak_tur = 1224 and w.id = o.kaynak_id
              left join public.personel_avans av
                     on o.kaynak_tur = 1257 and av.id = o.kaynak_id
              left join public.iskonto_talep isk
                     on o.kaynak_tur = 1256 and isk.id = o.kaynak_id
              left join public.belge ib on ib.id = isk.belge_id
              left join public.dokuman_surum ds
                     on o.kaynak_tur = 976 and ds.id = o.kaynak_id
              left join public.dokuman dk on dk.id = ds.dokuman_id
             where o.id = @p0
            """, null, [onayId], OkuyucuGenisletmeleri.Sozluk, iptal);

        if (n is null) return 0;
        var baslatan = Convert.ToInt32(n["baslatanId"] ?? 0);
        if (baslatan <= 0) return 0;

        var degiskenler = new Dictionary<string, string>
        {
            ["kayitNo"] = n["kayitNo"] as string ?? "",
            ["akisAd"] = n["akisAd"] as string ?? "",
            ["sonucAd"] = zincirDurum == OnayMotoru.ZincirOnaylandi ? "ONAYLANDI" : "REDDEDİLDİ",
            ["gerekce"] = gerekce ?? "",
        };

        return await YazAsync(baglanti, [baslatan], "onay.sonuc", degiskenler, onayId,
            kullaniciId, subeId, iptal);
    }

    // ==================================================== hatırlatma ==

    /// <summary>
    /// Termini geçmiş basamaklar için hatırlatma. Zamanlı işten çağrılır.
    ///
    /// GÜNDE BİR KEZ: aynı basamak için bugün zaten yazılmışsa atlanır.
    /// Her turda yeniden yazsaydık, saatte bir çalışan iş bir günde yirmi
    /// dört mesaj gönderir ve hatırlatma gürültüye dönüşürdü - gürültü de
    /// okunmaz.
    /// </summary>
    public async Task<(int Adim, int Bildirim)> HatirlatAsync(
        NpgsqlConnection baglanti, CancellationToken iptal = default)
    {
        var gecikenler = await baglanti.ListeAsync("""
            select v.id as "adimId", v.onay_id as "onayId", v.akis_kod as "akisKod",
                   v.rol, v.atanan_kullanici_id as "atananId", v.adim_ad as "adimAd",
                   v.kayit_no as "kayitNo", v.konu, v.gecikme_gun as "gecikmeGun",
                   v.sube_id as "subeId"
              from public.v_onay_kutusu v
             where v.gecikme_gun > 0
               -- BUGÜN HATIRLATMA YAZILDIYSA ATLA. Süzgeç ŞABLONA bakar:
               --   "bu basamak için bugün herhangi bir onay bildirimi var mı"
               --   deseydik, sıra geldiğinde yazılan `onay.istek` hatırlatmayı
               --   da bastırırdı - tam da gecikmenin başladığı gün.
               and not exists (
                     select 1 from public.bildirim b
                      where b.kaynak_tur = @p0 and b.kaynak_id = v.id
                        and b.sablon_id = (select x.id from public.bildirim_sablon x
                                            where x.kod = 'onay.hatirlatma')
                        and b.ekleme_tarihi::date = current_date)
             order by v.gecikme_gun desc
             limit 200
            """, null, [KaynakOnay], OkuyucuGenisletmeleri.Sozluk, iptal);

        var yazilan = 0;
        foreach (var g in gecikenler)
        {
            var aliciIdler = await AlicilarAsync(baglanti, g["akisKod"] as string ?? "",
                Convert.ToInt16(g["rol"] ?? (short)0), g["atananId"] as int?, iptal);

            yazilan += await YazAsync(baglanti, aliciIdler, "onay.hatirlatma", new Dictionary<string, string>
            {
                ["kayitNo"] = g["kayitNo"] as string ?? "",
                ["konu"] = g["konu"] as string ?? "",
                ["adimAd"] = g["adimAd"] as string ?? "",
                ["gecikmeGun"] = Convert.ToInt32(g["gecikmeGun"] ?? 0).ToString(),
            }, Convert.ToInt64(g["adimId"]), 0, g["subeId"] as int?, iptal);
        }

        return (gecikenler.Count, yazilan);
    }

    // ============================================ sözlü onay takibi ==

    /// <summary>
    /// YAZILI TEYİDİ GECİKEN SÖZLÜ ONAYLAR (763). Zamanlı işten çağrılır.
    ///
    /// Sözlü onay zinciri İLERLETİR (durum 4, `KararAsync` onu "karar
    /// verilmiş" sayar) ve `v_onay_bekleyen` onu göstermez - yani teyit
    /// gelmezse kimse fark etmez. Bu iş o boşluğu kapatıyor.
    ///
    /// ALICI KARARI VEREN KİŞİDİR: teyidi ondan başkası veremez. Rol
    /// basamağı olsa bile sözü söyleyen bellidir (`karar_veren_id`).
    ///
    /// GÜNDE BİR KEZ, hatırlatmayla aynı gerekçe: saatte bir çalışsaydı
    /// gürültüye dönerdi. Süzgeç yine ŞABLONA bakar.
    ///
    /// BASAMAĞI GERİ ALMAZ: zincir ilerlemiş, para ödenmiş, sürüm
    /// yayınlanmış olabilir; geri almak o eylemleri geri almaz, yalnız
    /// kaydı tutarsız yapar.
    /// </summary>
    public async Task<(int Adim, int Bildirim)> SozluTakipAsync(
        NpgsqlConnection baglanti, CancellationToken iptal = default)
    {
        var gecikenler = await baglanti.ListeAsync("""
            select v.adim_id as "adimId", v.kaynak_tur as "kaynakTur",
                   v.kaynak_id as "kaynakId", v.adim_ad as "adimAd",
                   v.karar_veren_id as "kararVerenId", v.yazili_son as "yaziliSon",
                   v.gecikme_saat as "gecikmeSaat", v.sube_id as "subeId"
              from public.v_onay_sozlu v
             where v.gecikti = 1
               and v.karar_veren_id is not null
               and not exists (
                     select 1 from public.bildirim b
                      where b.kaynak_tur = @p0 and b.kaynak_id = v.adim_id
                        and b.sablon_id = (select x.id from public.bildirim_sablon x
                                            where x.kod = 'onay.sozlu_gecikti')
                        and b.ekleme_tarihi::date = current_date)
             order by v.gecikme_saat desc
             limit 200
            """, null, [KaynakOnay], OkuyucuGenisletmeleri.Sozluk, iptal);

        var yazilan = 0;
        foreach (var g in gecikenler)
        {
            // KAYIT NO / KONU gelen kutusu görünümünden çözülür; sözlü adım
            //   orada olmadığı için kaydın kendisine ayrıca bakıyoruz.
            var kayit = await baglanti.TekAsync("""
                select coalesce(nullif(av.avans_no, ''), nullif(t.talep_no, ''),
                                nullif(z.izin_no, ''), nullif(w.is_emri_no, ''),
                                nullif(ib.belge_no, ''),
                                nullif(dk.kod, '') || ' v' || ds.surum_no::text,
                                '#' || @p1::text)                 as "kayitNo",
                       coalesce(nullif(av.gerekce, ''), nullif(t.gerekce, ''),
                                nullif(w.ariza_metni, ''), nullif(isk.gerekce, ''),
                                nullif(dk.ad, ''), '')            as konu
                  from (select 1) q
                  left join public.personel_avans av on @p0 = 1257 and av.id = @p1
                  left join public.satinalma_talep t on @p0 = 1241 and t.id = @p1
                  left join public.personel_izin z   on @p0 = 904  and z.id = @p1
                  left join public.demirbas_is_emri w on @p0 = 1224 and w.id = @p1
                  left join public.iskonto_talep isk on @p0 = 1256 and isk.id = @p1
                  left join public.belge ib          on ib.id = isk.belge_id
                  left join public.dokuman_surum ds  on @p0 = 976  and ds.id = @p1
                  left join public.dokuman dk        on dk.id = ds.dokuman_id
                """, null,
                [Convert.ToInt32(g["kaynakTur"]), Convert.ToInt64(g["kaynakId"])],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            var yaziliSon = g["yaziliSon"] as DateTime?;

            yazilan += await YazAsync(baglanti,
                [Convert.ToInt32(g["kararVerenId"])], "onay.sozlu_gecikti",
                new Dictionary<string, string>
                {
                    ["kayitNo"] = kayit?["kayitNo"] as string ?? "",
                    ["konu"] = kayit?["konu"] as string ?? "",
                    ["adimAd"] = g["adimAd"] as string ?? "",
                    ["gecikmeSaat"] = Convert.ToInt32(g["gecikmeSaat"] ?? 0).ToString(),
                    ["yaziliSon"] = yaziliSon?.ToString("dd.MM.yyyy HH:mm") ?? "",
                }, Convert.ToInt64(g["adimId"]), 0, g["subeId"] as int?, iptal);
        }

        return (gecikenler.Count, yazilan);
    }

    // ======================================================= yardımcılar ==

    /// <summary>
    /// Basamağın sahipleri. Rol basamağında "o aksiyon yetkisi olan aktif
    /// kullanıcılar" - yetkiyi ikinci kez tanımlamamak için karar ucuyla AYNI
    /// aksiyon kodundan gidiyoruz; başka bir liste tutsaydık yetki
    /// değiştiğinde bildirim eski kişiye gitmeye devam ederdi.
    /// </summary>
    private static async Task<List<int>> AlicilarAsync(
        NpgsqlConnection baglanti, string akisKod, short rol, int? atananId,
        CancellationToken iptal)
    {
        if (atananId is not null)
        {
            // VEKİL DE HABER ALIR: vekâletin anlamı işin durmamasıdır.
            var liste = new List<int> { atananId.Value };
            liste.AddRange(await baglanti.ListeAsync<int>("""
                select k.devralan_id from public.onay_vekalet k
                 where k.devreden_id = @p0 and k.aktif = 1
                   and current_date between k.baslangic and k.bitis
                """, null, [atananId.Value], o => o.GetInt32(0), iptal));
            return liste.Distinct().ToList();
        }

        var aksiyon = AksiyonKodu(akisKod, rol);
        if (aksiyon.Length == 0) return [];

        // EK ROLLER DE SAYILIR (665): kullanıcının ana rolü (`rol_id`) yanında
        //   `kullanici_rol` üzerinden taşıdığı roller de var. Yalnız ana role
        //   baksaydık, yetkiyi ek rolle alan kişi kararı VEREBİLİR ama haberi
        //   HİÇ ALMAZDI - ve "bu talep neden bekliyor" sorusunun cevabı
        //   kimsenin görmediği bir kuyrukta kalırdı.
        return await baglanti.ListeAsync<int>("""
            select distinct k.id
              from public.taraf_kullanici k
              join public.rol_yetki ry
                on ry.rol_id = k.rol_id
                or ry.rol_id in (select kr.rol_id from public.kullanici_rol kr
                                  where kr.kullanici_id = k.id)
              join public.yetki y on y.id = ry.yetki_id
             where k.aktif = 1 and y.tur = 1 and y.kod = @p0
               and coalesce(ry.gor, 0) = 1
            """, null, [aksiyon], o => o.GetInt32(0), iptal);
    }

    /// <summary>Karar ucundakiyle AYNI eşleme (tek kaynak olmalı).</summary>
    private static string AksiyonKodu(string akisKod, short rol) => akisKod switch
    {
        "satinalma.talep" => rol switch
        {
            1 => "satinalma.onay_birim",
            2 or 4 => "satinalma.onay_satinalma",
            _ => "satinalma.onay_ust",
        },
        "personel.izin" => rol switch
        {
            0 => "ik.izin_onay_amir",
            6 => "ik.izin_onay_ik",
            _ => "ik.izin_onay_ust",
        },
        "demirbas.onarim" => rol switch
        {
            6 => "demirbas.onarim_onay_teknik",
            4 => "demirbas.onarim_onay_mali",
            _ => "demirbas.onarim_onay_ust",
        },
        "personel.avans" => rol switch
        {
            0 => "ik.avans_onay_amir",
            6 => "ik.avans_onay_ik",
            4 => "ik.avans_onay_mali",
            _ => "ik.avans_onay_ust",
        },
        var _ when akisKod.StartsWith("dokuman.", StringComparison.Ordinal)
            => "dokuman.onay",
        "belge.iskonto" => rol switch
        {
            1 => "belge.iskonto_onay_birim",
            4 => "belge.iskonto_onay_mali",
            _ => "belge.iskonto_onay_ust",
        },
        // BOŞ = ALICI YOK, HATA YOK: bildirim kararı düşürmez. Ama akış
        //   eklenip buraya dal gelmezse sırası gelen kimseye HABER GİTMEZ
        //   ve talep kimsenin görmediği bir kuyrukta bekler - yeni akış
        //   eklerken OnayUclari.AksiyonKodu ile birlikte burası da yazılmalı.
        _ => "",
    };

    /// <summary>
    /// Kullanıcının iletişim bilgisine göre kanal seçer: e-posta varsa
    /// e-posta, yoksa cep. İkisi de yoksa SATIR AÇILMAZ - alıcısı olmayan
    /// bir bildirim kuyrukta hata olarak birikir ve kuyruğu tıkar.
    /// </summary>
    private async Task<int> YazAsync(
        NpgsqlConnection baglanti, IReadOnlyList<int> kullaniciIdler, string sablon,
        IReadOnlyDictionary<string, string> degiskenler, long kaynakId,
        int kullaniciId, int? subeId, CancellationToken iptal)
    {
        if (kullaniciIdler.Count == 0) return 0;

        var yazilan = 0;
        foreach (var kid in kullaniciIdler)
        {
            try
            {
                var k = await KullaniciAsync(baglanti, kid, iptal);
                if (k is null)
                {
                    // SESSİZ DÜŞMESİN: alıcının e-postası da cebi de yoksa
                    //   satır açılmaz (bkz. başlık) ama bu bir VERİ EKSİĞİDİR,
                    //   normal akış değil. Günlüğe yazmazsak onay zinciri
                    //   kimseye haber vermeden yürür ve kimse farkı anlamaz.
                    _gunluk.LogWarning(
                        "Onay bildirimi gönderilemedi: kullanıcı {Kid} için e-posta "
                        + "ve cep telefonu tanımlı değil (şablon {S}).", kid, sablon);
                    continue;
                }

                var (kanal, alici, ad) = k.Value;
                var d = new Dictionary<string, string>(degiskenler) { ["alici"] = ad };

                var id = await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                    SablonKodu: sablon, Kanal: kanal, Alici: alici, Degiskenler: d,
                    KullaniciId: kid, KaynakTur: KaynakOnay, KaynakId: (int)kaynakId),
                    kullaniciId, subeId, iptal);

                if (id is not null) yazilan++;
            }
            catch (Exception h)
            {
                // KARAR DÜŞMEZ: bildirim yazılamazsa günlüğe düşer (bkz. başlık).
                _gunluk.LogWarning(h, "Onay bildirimi yazılamadı (kullanıcı {Kid}, şablon {S}).",
                    kid, sablon);
            }
        }
        return yazilan;
    }

    /// <summary>Kullanıcının kanalı ve adresi (e-posta önce).</summary>
    private static async Task<(BildirimKanali Kanal, string Adres, string Ad)?> KullaniciAsync(
        NpgsqlConnection baglanti, int kullaniciId, CancellationToken iptal)
    {
        var k = await baglanti.TekAsync("""
            select coalesce(k.eposta, '') as eposta, coalesce(k.cep_tel, '') as cep,
                   coalesce(nullif(t.unvan, ''), k.kod) as ad
              from public.taraf_kullanici k
              left join public.taraf t on t.id = k.id
             where k.id = @p0
            """, null, [kullaniciId], OkuyucuGenisletmeleri.Sozluk, iptal);

        if (k is null) return null;
        var eposta = k["eposta"] as string ?? "";
        var cep = k["cep"] as string ?? "";
        var ad = k["ad"] as string ?? "";

        if (eposta.Length > 0) return (BildirimKanali.Eposta, eposta, ad);
        if (cep.Length > 0) return (BildirimKanali.Sms, cep, ad);
        return null;
    }
}
