using System.Globalization;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// SATINALMA SÜREÇ İCMALİ (1176 - kullanıcı 25.10.2026, mockup Ekranlar/İcmal/satinalma_icmali.html,
/// kararlar 25.10.2026). "Talepler nerede tıkanıyor, kim bekletiyor, hangi tedarikçi güvenilir,
/// fiyatlar ne kadar arttı, bütçenin ne kadarı kaldı?"
///
/// <para><b>Kaynak:</b> dönem TALEP TARİHİdir (satinalma_talep.tarih); bütün aşamalar o taleplerden
/// türer: onay zinciri (onay / onay_adim, kaynak_tur 1241), teklif (satinalma_teklif + _firma),
/// alış siparişi (belge tür 9 + belge_satinalma.talep_id), mal kabul (satinalma_kabul) ve fatura
/// kontrolü (satinalma_fatura_kontrol). Birleştirilen talep (durum 6) hedef talepte sayılır.
/// Aşama süreleri ortalamadır; hedef süre Genel Ayarlar'dan (satinalma.hedef_gun_onay · _teklif ·
/// _siparis · _kabul · _odeme) - boşsa hedef sütunu boş, yalnız ortalama (karar 25.10.2026).</para>
///
/// <para><b>Bölünme (karar 25.10.2026):</b> talep birden çok siparişe bölünürse sipariş süresi İLK
/// siparişe göre ölçülür, satırda "bölündü" rozeti. <b>Hizmet</b> alımları dahildir, kalem rozeti
/// ürün / hizmet / karma.</para>
///
/// <para><b>Tasarruf (karar 25.10.2026):</b> teklifli siparişte ortalama teklif − kazanan teklif;
/// ikinci sütun son alışa göre fark (sipariş satırının son alış fiyatıyla tutarı − sipariş tutarı).
/// TEK TEKLİFLE verilen sipariş tasarrufa katılmaz, ayrı sayılır.</para>
///
/// <para><b>Kurallar tek yerde:</b> bekleyen basamak <c>v_onay_bekleyen</c>'den (onay motoru), bütçe
/// <c>v_butce_durum</c>'dan (taahhüt harcamadır - talep onayındaki ButceDurumuAsync ile aynı görünüm),
/// tedarikçi skoru <c>v_tedarikci_skor</c>'dan (olaylardan türer, icmal yeniden hesaplamaz).</para>
///
/// <para><b>Onaycıya hatırlat</b> (POST /hatirlat, karar 25.10.2026): aynı belge için günde bir
/// (şube günü); aynı onaycıya ikinci kez hatırlatılırsa zincirin bir üst basamağına da bilgi gider
/// (satinalma_hatirlatma.ust_bilgi = 1). Bildirim mevcut onay bildirimi yolundan (OnayBildirimi →
/// bildirim kuyruğu); hatırlatma talep loguna yazılır. Onay / ret bu ekrandan verilmez.</para>
/// </summary>
public static class SatinalmaIcmalUclari
{
    private const string Kod = "satinalma.icmali";

    /// <summary>islem_log.tablo_id ve onay.kaynak_tur - satınalma talebi (SatinalmaUclari.LogTalep ile aynı).</summary>
    private const int LogTalep = 1241;

    /// <summary>Kritik Stok İcmali'nin "Talep aç" eylemi (StokIcmalUclari.Ek) talebe bu kaynak türünü yazar.</summary>
    private const int KaynakTurKritikElle = 918;

    // talep.durum (SatinalmaUclari ile aynı)
    private const int TalepTaslak = 0, TalepOnayda = 1, TalepOnaylandi = 2, TalepRed = 3, TalepTeklifte = 4, TalepIptal = 8;

    /// <summary>Hedef ayarı boşken "uzun bekleyen onay" eşiği (mockup: 5 günden uzun).</summary>
    private const int UzunOnayVarsayilan = 5;

    public sealed record HatirlatIstegi(string? BelgeTur, long BelgeId);

    // ------------------------------------------------------------------ modeller --
    private sealed class Talep
    {
        public long Id; public string No = ""; public DateTime Tarih; public int Kaynak; public int KaynakTur; public int Durum;
        public int Oncelik; public string Departman = ""; public int ButceId; public string Konu = ""; public decimal Tutar;
        public int StokN; public int HizmetN; public int SatirN; public string IlkAd = ""; public decimal Miktar;
        public string Isteyen = "";
        public Onay? Onay; public Basamak? Bekleyen;
        public List<Teklif> Teklifler = [];
        public List<Siparis> Siparisler = [];
        public DateTime? IlkSiparis => Siparisler.Count == 0 ? null : Siparisler.Min(s => s.Tarih);
    }

    private sealed record Onay(long Id, int Durum, DateTime? Baslama, DateTime? Bitis);

    private sealed record Basamak(long OnayId, long AdimId, int Sira, string Ad, int Rol, int AtananId, string Atanan,
        string AkisKod, DateTime BeklemeBasi, int Toplam, int Durum);

    private sealed class Teklif
    {
        public long Id; public long TalepId; public string No = ""; public int Durum; public DateTime Ekleme;
        public DateTime? Karar; public DateTime? Davet; public int Davetli; public int Yanit; public decimal? Ort; public decimal? Kazanan;
    }

    private sealed class Siparis
    {
        public int Id; public long TalepId; public string No = ""; public DateTime Tarih; public int TarafId; public string Taraf = "";
        public decimal Matrah; public DateTime? SozTeslim; public DateTime? IlkTeslim; public int Takip; public long TeklifId;
        public DateTime? IlkKabul; public int KabulN; public int Eksik; public int Ret; public int StokN; public int HizmetN;
        public List<SipSatir> Satirlar = [];
        public List<Kontrol> Kontroller = [];
        public DateTime? Teslim => IlkKabul ?? IlkTeslim;
    }

    private sealed record SipSatir(int BelgeId, int StokId, int HizmetId, string Kod, string Ad, decimal Miktar, decimal Tutar, decimal Fiyat);

    private sealed record Kontrol(long Id, int SiparisId, int FaturaId, string FaturaNo, DateTime? FaturaTarih, int Sonuc,
        decimal FaturaTutar, decimal Fark, int OdemeDurum, DateTime Ekleme, DateTime? Karar, string Ekleyen, string FarkMetni);

    private sealed record Alis(int StokId, int HizmetId, decimal Fiyat, DateTime Tarih, string Taraf);

    private sealed record BekleyenSatir(string Anahtar, string BelgeTur, long Id, long TalepId, string No, string Asama,
        string TalepEden, string Konu, string Kalem, decimal Tutar, string Kimde, int Gun, string Oncelik, bool Gecikme,
        string Not, int HatirlatmaSayi, DateTime? SonHatirlatma, bool BugunHatirlatildi, bool Hatirlatilabilir, bool Bolundu);

    private sealed record Hatirlatma(int Sayi, DateTime? Son, bool Bugun);

    // ---------------------------------------------------------------- yardımcılar --
    private static decimal R(decimal d) => Math.Round(d, 2);
    private static double? Ort(IEnumerable<double> l) { var a = l.ToList(); return a.Count == 0 ? null : Math.Round(a.Average(), 1); }
    private static double? Medyan(IEnumerable<double> l)
    {
        var a = l.OrderBy(x => x).ToList();
        if (a.Count == 0) return null;
        var m = a.Count % 2 == 1 ? a[a.Count / 2] : (a[a.Count / 2 - 1] + a[a.Count / 2]) / 2;
        return Math.Round(m, 1);
    }
    private static double Sure(DateTime bas, DateTime bit) => Math.Max(0, (bit - bas).TotalDays);
    private static string Kalem(int stokN, int hizmetN) => hizmetN > 0 && stokN > 0 ? "karma" : hizmetN > 0 ? "hizmet" : "urun";
    private static string OncelikKodu(int o) => o switch { 1 => "acil", 2 => "yuksek", _ => "normal" };
    private static string DurumAdi(int d) => d switch
    {
        0 => "taslak", 1 => "onayda", 2 => "onaylandı", 3 => "reddedildi", 4 => "teklifte", 5 => "siparişe dönüştü",
        6 => "birleştirildi", 8 => "iptal", _ => "?",
    };
    private static string AsimAdi(int a) => a switch { 0 => "uyar", 2 => "engeller", _ => "ek onay" };

    /// <summary>Aşama hedef süresi (gün). Boş / geçersiz / sıfır = hedef yok (karar 25.10.2026).</summary>
    private static async Task<decimal?> HedefAsync(NpgsqlConnection b, string anahtar, CancellationToken iptal)
    {
        var m = (await AyarDeposu.MetinAsync(b, null, anahtar, "", iptal)).Trim().Replace(',', '.');
        return decimal.TryParse(m, NumberStyles.Number, CultureInfo.InvariantCulture, out var d) && d > 0 ? d : null;
    }

    /// <summary>
    /// Basamağın sahipleri - OnayBildirimi.AlicilarAsync ile BİREBİR (atanan + aktif vekil; rol basamağında
    /// karar ucuyla aynı aksiyon kodunu taşıyan aktif kullanıcılar, ek roller dahil). Aksiyon eşlemesi
    /// OnayBildirimi.AksiyonKodu'ndan - kural tek yerde. O metot internal açılınca bu kopya kaldırılmalı.
    /// </summary>
    private static async Task<List<int>> AlicilarAsync(NpgsqlConnection b, NpgsqlTransaction? tx, string akisKod,
        int rol, int atananId, CancellationToken iptal)
    {
        if (atananId > 0)
        {
            var liste = new List<int> { atananId };
            liste.AddRange(await b.ListeAsync("""
                select k.devralan_id from public.onay_vekalet k
                 where k.devreden_id = @p0 and k.aktif = 1
                   and current_date between k.baslangic and k.bitis
                """, tx, [atananId], o => o.GetInt32(0), iptal));
            return liste.Distinct().ToList();
        }
        var aksiyon = Servisler.OnayBildirimi.AksiyonKodu(akisKod, (short)rol);
        if (aksiyon.Length == 0) return [];
        return await b.ListeAsync("""
            select distinct k.id
              from public.taraf_kullanici k
              join public.rol_yetki ry
                on ry.rol_id = k.rol_id
                or ry.rol_id in (select kr.rol_id from public.kullanici_rol kr where kr.kullanici_id = k.id)
              join public.yetki y on y.id = ry.yetki_id
             where k.aktif = 1 and y.tur = 1 and y.kod = @p0 and coalesce(ry.gor, 0) = 1
            """, tx, [aksiyon], o => o.GetInt32(0), iptal);
    }

    private sealed record Kisi(int Id, string Ad, string Eposta, string Cep);

    private static async Task<List<Kisi>> KisilerAsync(NpgsqlConnection b, NpgsqlTransaction? tx, List<int> idler, CancellationToken iptal)
    {
        if (idler.Count == 0) return [];
        return await b.ListeAsync("""
            select k.id, coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod, ''),
                   coalesce(k.eposta, ''), coalesce(k.cep_tel, '')
              from public.taraf_kullanici k left join public.taraf t on t.id = k.id
             where k.id = any(@p0)
             order by 2
            """, tx, [idler.ToArray()], o => new Kisi(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3)), iptal);
    }

    public static void SatinalmaIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/satinalma-icmal").WithTags("Satınalma Süreç İcmali").RequireAuthorization();

        // =================================================================== GET ===
        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? sube, int? departman, int? kategori, int? tedarikci,
                                int? butce, int? kaynak, VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx,
                                CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var dilim = baglam.ZamanDilimi;
            var bugun = Saat.BugunDilim(dilim);
            var bitis = (bit ?? bugun).Date;
            if (bitis > bugun) bitis = bugun;
            var baslangic = (bas ?? new DateTime(bitis.Year, bitis.Month, 1)).Date;
            if (baslangic > bitis) throw GentegreHatasi.Dogrulama("Başlangıç tarihi bitişten sonra olamaz.");
            if ((bitis - baslangic).TotalDays > 732) throw GentegreHatasi.Dogrulama("Dönem en çok iki yıl olabilir.");
            var tumSubeler = baglam.Subeler.Select(s => s.Id).ToArray();
            int[] subeler;
            if (sube is > 0)
            {
                if (!tumSubeler.Contains(sube.Value)) throw GentegreHatasi.Bulunamadi("Şube bulunamadı.");
                subeler = [sube.Value];
            }
            else subeler = tumSubeler;
            var dep0 = departman ?? 0; var kat0 = kategori ?? 0; var ted0 = tedarikci ?? 0; var but0 = butce ?? 0;
            var kay0 = kaynak is 1 or 2 or 3 or 4 or 5 ? kaynak.Value : 0;
            var yil = bitis.Year;
            DateTime Y(DateTime utc) => Saat.Yerel(utc, dilim);
            DateTime? YN(NpgsqlDataReader o, int i) => o.IsDBNull(i) ? null : Y(o.GetDateTime(i));
            DateTime? TN(NpgsqlDataReader o, int i) => o.IsDBNull(i) ? null : o.GetDateTime(i).Date;

            await using var b = await veri.AcAsync(iptal);

            var hedef = new
            {
                onay = await HedefAsync(b, "satinalma.hedef_gun_onay", iptal),
                teklif = await HedefAsync(b, "satinalma.hedef_gun_teklif", iptal),
                siparis = await HedefAsync(b, "satinalma.hedef_gun_siparis", iptal),
                kabul = await HedefAsync(b, "satinalma.hedef_gun_kabul", iptal),
                odeme = await HedefAsync(b, "satinalma.hedef_gun_odeme", iptal),
            };

            // ------------------------------------------------------------- talepler --
            var talepler = await b.ListeAsync("""
                with recursive dal as (
                    select k.id, 0 as d from public.kategori k where @p6 > 0 and k.id = @p6
                    union all
                    select k.id, dal.d + 1 from public.kategori k join dal on k.ust_id = dal.id where dal.d < 30
                )
                select t.id, coalesce(nullif(t.talep_no, ''), '#' || t.id), t.tarih, coalesce(t.kaynak, 1)::int,
                       coalesce(t.kaynak_tur, 0)::int, coalesce(t.durum, 0)::int, coalesce(t.oncelik, 3)::int,
                       coalesce(d.ad, '')::varchar(200), coalesce(t.butce_kalem_id, 0),
                       coalesce(nullif(t.gerekce, ''), sat.ilk_ad, '')::varchar(400),
                       coalesce(nullif(t.tahmini_tutar, 0), sat.tutar, 0),
                       coalesce(sat.stok_n, 0)::int, coalesce(sat.hizmet_n, 0)::int, coalesce(sat.n, 0)::int,
                       coalesce(sat.ilk_ad, '')::varchar(300), coalesce(sat.miktar, 0),
                       coalesce(public.fn_taraf_ad(i.unvan, i.ad, i.soyad)::varchar(120), '')
                  from public.satinalma_talep t
                  left join public.departman d on d.id = t.departman_id
                  left join public.taraf i on i.id = t.isteyen_id
                  left join lateral (
                        select sum(coalesce(nullif(s.tahmini_tutar, 0), coalesce(s.son_alis_fiyat, 0) * s.miktar)) as tutar,
                               count(*) filter (where s.hizmet_id is null) as stok_n,
                               count(*) filter (where s.hizmet_id is not null) as hizmet_n,
                               count(*) as n,
                               (array_agg(coalesce(nullif(s.ad, ''), st.ad, hz.ad, '') order by s.sira, s.id))[1] as ilk_ad,
                               sum(s.miktar) as miktar
                          from public.satinalma_talep_satir s
                          left join public.stok st on st.id = s.stok_id
                          left join public.hizmet hz on hz.id = s.hizmet_id
                         where s.talep_id = t.id) sat on true
                 where t.tarih >= @p0::date and t.tarih <= @p1::date and coalesce(t.durum, 0) <> 6
                   and (t.sube_id is null or t.sube_id = any(@p2::int[]))
                   and (@p3 = 0 or t.departman_id = @p3)
                   and (@p4 = 0 or t.butce_kalem_id = @p4)
                   and (@p5 = 0 or t.kaynak = @p5)
                   and (@p6 = 0 or exists (select 1 from public.satinalma_talep_satir s join public.stok st on st.id = s.stok_id
                                            where s.talep_id = t.id and st.kategori in (select id from dal)))
                   and (@p7 = 0 or exists (select 1 from public.belge_satinalma bs join public.belge sb on sb.id = bs.id
                                            where bs.talep_id = t.id and sb.tur = 9 and sb.taraf_id = @p7))
                 order by t.tarih, t.id
                """, null, [baslangic, bitis, subeler, dep0, but0, kay0, kat0, ted0], o => new Talep
                {
                    Id = o.GetInt64(0), No = o.GetString(1), Tarih = o.GetDateTime(2).Date, Kaynak = o.GetInt32(3),
                    KaynakTur = o.GetInt32(4), Durum = o.GetInt32(5), Oncelik = o.GetInt32(6), Departman = o.GetString(7),
                    ButceId = o.GetInt32(8), Konu = o.GetString(9), Tutar = o.GetDecimal(10), StokN = o.GetInt32(11),
                    HizmetN = o.GetInt32(12), SatirN = o.GetInt32(13), IlkAd = o.GetString(14), Miktar = o.GetDecimal(15),
                    Isteyen = o.GetString(16),
                }, iptal);
            var talepSoz = talepler.ToDictionary(x => x.Id);
            var talepIdler = talepler.Select(x => x.Id).ToArray();

            var siparisler = new List<Siparis>();
            var teklifler = new List<Teklif>();
            var hatir = new Dictionary<long, Hatirlatma>();
            var gunBasUtc = Saat.UtcYap(bugun, dilim);
            if (talepIdler.Length > 0)
            {
                // ---------------------------------------------- onay zinciri (son zincir) --
                var onaylar = await b.ListeAsync("""
                    select o.kaynak_id, o.id, coalesce(o.durum, 0)::int, o.baslama, o.bitis
                      from public.onay o where o.kaynak_tur = @p1 and o.kaynak_id = any(@p0::bigint[])
                     order by o.kaynak_id, o.id
                    """, null, [talepIdler, LogTalep], o => new { talep = o.GetInt64(0), onay = new Onay(o.GetInt64(1), o.GetInt32(2), YN(o, 3), YN(o, 4)) }, iptal);
                foreach (var x in onaylar) if (talepSoz.TryGetValue(x.talep, out var t)) t.Onay = x.onay;

                // BEKLEYEN BASAMAK: onay motorunun görünümünden (KaynakKatalogu.Satinalma "bekleyenBasamak" ile aynı).
                //   Bekleme başı = önceki basamağın kararı, yoksa zincirin başlaması.
                var bekleyen = await b.ListeAsync("""
                    select v.kaynak_id, v.onay_id, v.adim_id, v.sira::int, coalesce(v.adim_ad, ''), coalesce(v.rol, 0)::int,
                           coalesce(v.atanan_kullanici_id, 0),
                           coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''), coalesce(v.akis_kod, ''),
                           coalesce((select max(x.karar_zamani) from public.onay_adim x where x.onay_id = v.onay_id and x.sira < v.sira),
                                    v.baslama, now()),
                           (select count(*) from public.onay_adim x where x.onay_id = v.onay_id)::int, coalesce(v.durum, 0)::int
                      from public.v_onay_bekleyen v
                      left join public.taraf u on u.id = v.atanan_kullanici_id
                     where v.kaynak_tur = @p1 and v.kaynak_id = any(@p0::bigint[])
                     order by v.kaynak_id, v.sira
                    """, null, [talepIdler, LogTalep], o => new
                    {
                        talep = o.GetInt64(0),
                        b = new Basamak(o.GetInt64(1), o.GetInt64(2), o.GetInt32(3), o.GetString(4), o.GetInt32(5), o.GetInt32(6),
                            o.GetString(7), o.GetString(8), Y(o.GetDateTime(9)), o.GetInt32(10), o.GetInt32(11)),
                    }, iptal);
                foreach (var x in bekleyen) if (talepSoz.TryGetValue(x.talep, out var t) && t.Bekleyen is null) t.Bekleyen = x.b;

                // ------------------------------------------------------------ teklifler --
                teklifler = await b.ListeAsync("""
                    select k.id, k.talep_id, coalesce(nullif(k.teklif_no, ''), '#' || k.id), coalesce(k.durum, 0)::int,
                           k.ekleme_tarihi, k.karar_zamani, k.davet_tarihi,
                           coalesce(f.davet, 0)::int, coalesce(f.yanit, 0)::int, f.ort, f.kazanan
                      from public.satinalma_teklif k
                      left join lateral (
                            select count(*) as davet,
                                   count(*) filter (where x.durum in (1, 4, 5) and x.tutar > 0) as yanit,
                                   avg(x.tutar) filter (where x.durum in (1, 4, 5) and x.tutar > 0) as ort,
                                   max(x.tutar) filter (where x.firma_id = k.karar_firma_id and x.tutar > 0) as kazanan
                              from public.satinalma_teklif_firma x where x.teklif_id = k.id) f on true
                     where k.talep_id = any(@p0::bigint[]) and coalesce(k.durum, 0) <> 8
                     order by k.talep_id, k.id
                    """, null, [talepIdler], o => new Teklif
                    {
                        Id = o.GetInt64(0), TalepId = o.GetInt64(1), No = o.GetString(2), Durum = o.GetInt32(3),
                        Ekleme = Y(o.GetDateTime(4)), Karar = YN(o, 5), Davet = TN(o, 6), Davetli = o.GetInt32(7),
                        Yanit = o.GetInt32(8), Ort = o.IsDBNull(9) ? null : o.GetDecimal(9), Kazanan = o.IsDBNull(10) ? null : o.GetDecimal(10),
                    }, iptal);
                foreach (var k in teklifler) if (talepSoz.TryGetValue(k.TalepId, out var t)) t.Teklifler.Add(k);

                // ------------------------------------------------------------ siparişler --
                //   Sipariş = belge tür 9 + belge_satinalma (SatinalmaUclari "/siparise"); iptal (belge durum 2,
                //   takip 8) sayılmaz. Mal kabul = satinalma_kabul sonuc 1 kabul / 2 kısmi.
                siparisler = await b.ListeAsync("""
                    select b.id, bs.talep_id, coalesce(nullif(b.belge_no, ''), '#' || b.id), b.belge_tarihi, coalesce(b.taraf_id, 0),
                           coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200),
                           coalesce(b.matrah, 0), bs.soz_teslim, bs.ilk_teslim, coalesce(bs.takip_durum, 0)::int,
                           coalesce(bs.teklif_id, 0), kb.ilk, coalesce(kb.n, 0)::int,
                           (select count(*) from public.satinalma_kabul_satir ks join public.satinalma_kabul k2 on k2.id = ks.kabul_id
                             where k2.siparis_belge_id = b.id and coalesce(ks.sonuc, 0) <> 3 and coalesce(ks.siparis_miktar, 0) > 0
                               and coalesce(ks.sayilan, 0) <> ks.siparis_miktar)::int,
                           (select count(*) from public.satinalma_kabul_satir ks join public.satinalma_kabul k2 on k2.id = ks.kabul_id
                             where k2.siparis_belge_id = b.id and ks.sonuc = 3)::int,
                           coalesce(st.stok_n, 0)::int, coalesce(st.hizmet_n, 0)::int
                      from public.belge b
                      join public.belge_satinalma bs on bs.id = b.id
                      left join public.taraf t on t.id = b.taraf_id
                      left join lateral (select min(k.tarih) filter (where k.sonuc in (1, 2)) as ilk,
                                                count(*) filter (where k.sonuc in (1, 2)) as n
                                           from public.satinalma_kabul k where k.siparis_belge_id = b.id) kb on true
                      left join lateral (select count(*) filter (where s.hizmet_id is null) as stok_n,
                                                count(*) filter (where s.hizmet_id is not null) as hizmet_n
                                           from public.belge_satir s where s.belge_id = b.id) st on true
                     where b.tur = 9 and coalesce(b.durum, 0) <> 2 and coalesce(bs.takip_durum, 0) <> 8
                       and bs.talep_id = any(@p0::bigint[])
                       and (@p1 = 0 or b.taraf_id = @p1)
                     order by b.belge_tarihi, b.id
                    """, null, [talepIdler, ted0], o => new Siparis
                    {
                        Id = o.GetInt32(0), TalepId = o.GetInt64(1), No = o.GetString(2), Tarih = Y(o.GetDateTime(3)),
                        TarafId = o.GetInt32(4), Taraf = o.GetString(5), Matrah = o.GetDecimal(6), SozTeslim = TN(o, 7),
                        IlkTeslim = TN(o, 8), Takip = o.GetInt32(9), TeklifId = o.GetInt64(10), IlkKabul = TN(o, 11),
                        KabulN = o.GetInt32(12), Eksik = o.GetInt32(13), Ret = o.GetInt32(14), StokN = o.GetInt32(15), HizmetN = o.GetInt32(16),
                    }, iptal);
                foreach (var s in siparisler) if (talepSoz.TryGetValue(s.TalepId, out var t)) t.Siparisler.Add(s);

                // ------------------------------------------------- hatırlatma geçmişi --
                var hl = await b.ListeAsync("""
                    select h.belge_id, (count(distinct h.an) filter (where h.ust_bilgi = 0))::int, max(h.an),
                           coalesce(bool_or(h.an >= @p1 and h.an < @p2), false)
                      from public.satinalma_hatirlatma h
                     where h.belge_tur = 'talep' and h.belge_id = any(@p0::bigint[])
                     group by h.belge_id
                    """, null, [talepIdler, gunBasUtc, gunBasUtc.AddDays(1)],
                    o => new { id = o.GetInt64(0), h = new Hatirlatma(o.GetInt32(1), o.IsDBNull(2) ? null : o.GetDateTime(2), o.GetBoolean(3)) }, iptal);
                foreach (var x in hl) hatir[x.id] = x.h;
            }
            var siparisSoz = siparisler.ToDictionary(x => x.Id);
            var sipIdler = siparisler.Select(x => x.Id).ToArray();
            var teklifSoz = teklifler.ToDictionary(x => x.Id);

            var kontroller = new List<Kontrol>();
            var alislar = new Dictionary<(int, int), List<Alis>>();
            if (sipIdler.Length > 0)
            {
                // fatura kontrolü (üçlü eşleştirme) - sonuc 0 yok · 1 tuttu · 2+ fark; odeme 1 onay · 2 durdu · 3 itiraz · 4 düzeltildi
                kontroller = await b.ListeAsync("""
                    select k.id, k.siparis_belge_id, coalesce(k.fatura_belge_id, 0),
                           coalesce(nullif(f.belge_no, ''), '#' || k.fatura_belge_id), f.belge_tarihi,
                           coalesce(k.sonuc, 0)::int, coalesce(k.fatura_tutar, 0), coalesce(k.fark_tutar, 0), coalesce(k.odeme_durum, 0)::int,
                           k.ekleme_tarihi, k.karar_zamani,
                           coalesce(public.fn_taraf_ad(u.unvan, u.ad, u.soyad)::varchar(120), ''), coalesce(k.fark_metni, '')
                      from public.satinalma_fatura_kontrol k
                      left join public.belge f on f.id = k.fatura_belge_id
                      left join public.taraf u on u.id = k.ekleyen
                     where k.siparis_belge_id = any(@p0::int[])
                     order by k.id
                    """, null, [sipIdler], o => new Kontrol(o.GetInt64(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), YN(o, 4),
                        o.GetInt32(5), o.GetDecimal(6), o.GetDecimal(7), o.GetInt32(8), Y(o.GetDateTime(9)), YN(o, 10),
                        o.GetString(11), o.GetString(12)), iptal);
                foreach (var k in kontroller) if (siparisSoz.TryGetValue(k.SiparisId, out var s)) s.Kontroller.Add(k);

                // sipariş satırları (fiyat analizi, fiyat sapması, son alışa göre fark)
                var satirlar = await b.ListeAsync("""
                    select s.belge_id, coalesce(s.stok_id, 0), coalesce(s.hizmet_id, 0), coalesce(st.kod, hz.kod, '')::varchar(100),
                           coalesce(st.ad, hz.ad, nullif(s.aciklama, ''), '')::varchar(300),
                           coalesce(s.miktar, 0), coalesce(s.tutar, 0), coalesce(nullif(s.iskontolu_birim_fiyat, 0), s.birim_fiyat, 0)
                      from public.belge_satir s
                      left join public.stok st on st.id = s.stok_id
                      left join public.hizmet hz on hz.id = s.hizmet_id
                     where s.belge_id = any(@p0::int[]) and (s.stok_id is not null or s.hizmet_id is not null)
                       and coalesce(s.miktar, 0) > 0
                     order by s.belge_id, s.sira, s.id
                    """, null, [sipIdler], o => new SipSatir(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2), o.GetString(3), o.GetString(4),
                        o.GetDecimal(5), o.GetDecimal(6), o.GetDecimal(7)), iptal);
                foreach (var s in satirlar) if (siparisSoz.TryGetValue(s.BelgeId, out var sp)) sp.Satirlar.Add(s);

                // ALIŞ GEÇMİŞİ: kesin alış faturası (tür 11, iade tipi 2 hariç) satırının KDV hariç birim fiyatı,
                //   kalem başına en son 12 alış (dönem sonuna kadar). Son 3 alış ve "siparişten önceki" son alışlar buradan.
                var stoklar = satirlar.Where(x => x.StokId > 0).Select(x => x.StokId).Distinct().ToArray();
                var hizmetler = satirlar.Where(x => x.StokId == 0 && x.HizmetId > 0).Select(x => x.HizmetId).Distinct().ToArray();
                if (stoklar.Length + hizmetler.Length > 0)
                {
                    var ham = await b.ListeAsync("""
                        select x.stok_id, x.hizmet_id, x.fiyat, x.tarih, x.taraf from (
                            select coalesce(s.stok_id, 0) as stok_id, case when s.stok_id is null then coalesce(s.hizmet_id, 0) else 0 end as hizmet_id,
                                   coalesce(nullif(s.iskontolu_birim_fiyat, 0), s.birim_fiyat, 0) as fiyat, b.belge_tarihi as tarih,
                                   coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200) as taraf,
                                   row_number() over (partition by coalesce(s.stok_id, 0), case when s.stok_id is null then coalesce(s.hizmet_id, 0) else 0 end
                                                      order by b.belge_tarihi desc, b.id desc, s.id desc) as rn
                              from public.belge b
                              join public.belge_satir s on s.belge_id = b.id
                              left join public.taraf t on t.id = b.taraf_id
                             where b.tur = 11 and b.durum = 0 and coalesce(b.tipi, 0) <> 2
                               and b.belge_tarihi::date <= @p2::date
                               and (b.sube_id is null or b.sube_id = any(@p3::int[]))
                               and (s.stok_id = any(@p0::int[]) or (s.stok_id is null and s.hizmet_id = any(@p1::int[])))
                               and coalesce(s.miktar, 0) > 0 and coalesce(nullif(s.iskontolu_birim_fiyat, 0), s.birim_fiyat, 0) > 0) x
                         where x.rn <= 12
                         order by x.stok_id, x.hizmet_id, x.rn
                        """, null, [stoklar, hizmetler, bitis, subeler],
                        o => new Alis(o.GetInt32(0), o.GetInt32(1), o.GetDecimal(2), Y(o.GetDateTime(3)), o.GetString(4)), iptal);
                    foreach (var g in ham.GroupBy(a => (a.StokId, a.HizmetId))) alislar[g.Key] = g.ToList();
                }
            }
            (int, int) Anahtar(SipSatir s) => s.StokId > 0 ? (s.StokId, 0) : (0, s.HizmetId);
            List<Alis> Once(SipSatir s, DateTime tarih, int adet) =>
                alislar.TryGetValue(Anahtar(s), out var l) ? l.Where(a => a.Tarih < tarih).Take(adet).ToList() : [];

            // ================================================================ HUNİ ==
            var onayGiren = talepler.Where(t => t.Onay is not null || t.Durum is TalepOnayda or TalepOnaylandi or TalepRed or TalepTeklifte or 5).ToList();
            var teklifli = talepler.Where(t => t.Teklifler.Count > 0).ToList();
            var siparisli = talepler.Where(t => t.Siparisler.Count > 0).ToList();
            var kabulluSip = siparisler.Where(s => s.KabulN > 0).ToList();
            var odemeOnay = kontroller.Where(k => k.OdemeDurum is 1 or 4).ToList();
            var redIptal = talepler.Where(t => t.Durum is TalepRed or TalepIptal).ToList();

            var onaySure = talepler.Where(t => t.Onay is { Durum: 1, Baslama: not null, Bitis: not null })
                .Select(t => Sure(t.Onay!.Baslama!.Value, t.Onay.Bitis!.Value)).ToList();
            var teklifSure = teklifler.Where(k => k.Karar is not null).Select(k => Sure(k.Ekleme, k.Karar!.Value)).ToList();
            // SİPARİŞ SÜRESİ: onayın (teklif kararı varsa onun) bitişinden İLK siparişe (karar 25.10.2026 - bölünmede ilk sipariş).
            DateTime SiparisBasi(Talep t)
            {
                var a = t.Onay?.Bitis ?? t.Tarih;
                var kararlar = t.Teklifler.Where(k => k.Karar is not null).Select(k => k.Karar!.Value).ToList();
                if (kararlar.Count > 0 && kararlar.Max() > a) a = kararlar.Max();
                return a;
            }
            var siparisSure = siparisli.Select(t => Sure(SiparisBasi(t), t.IlkSiparis!.Value)).ToList();
            var kabulSure = kabulluSip.Where(s => s.IlkKabul is not null).Select(s => Sure(s.Tarih.Date, s.IlkKabul!.Value)).ToList();
            var faturaSure = kontroller.Where(k => k.FaturaTarih is not null).Select(k => Sure(k.FaturaTarih!.Value.Date, k.Ekleme)).ToList();
            var odemeSure = odemeOnay.Where(k => k.Karar is not null).Select(k => Sure(k.Ekleme, k.Karar!.Value)).ToList();

            var bekleyenTeklif = teklifli.Count(t => t.Siparisler.Count == 0 && t.Durum is not (TalepRed or TalepIptal)
                                                     && t.Teklifler.Any(k => k.Durum < 3));
            bool SiparisBekliyor(Talep t) => t.Siparisler.Count == 0
                && (t.Durum == TalepOnaylandi || (t.Durum == TalepTeklifte && t.Teklifler.Count > 0 && t.Teklifler.All(k => k.Durum >= 3)));
            var acikSip = siparisler.Where(s => s.Takip is 0 or 1 && s.KabulN == 0).ToList();
            bool Uyusmaz(Kontrol k) => k.Sonuc >= 2 && k.OdemeDurum is 0 or 2 or 3;
            var kararBekleyen = kontroller.Count(k => k.OdemeDurum is not (1 or 4));
            var uyusmaz = kontroller.Count(Uyusmaz);

            var huniHam = new (string kod, string ad, int adet, decimal tutar, int? bekleyen, string bekleyenNot, double? ort, decimal? hdf)[]
            {
                ("talep", "Talep açıldı", talepler.Count, talepler.Sum(t => t.Tutar), talepler.Count(t => t.Durum == TalepTaslak), "taslak", null, null),
                ("onay", "Onay", onayGiren.Count, onayGiren.Sum(t => t.Tutar), talepler.Count(t => t.Durum == TalepOnayda), "onayda", Ort(onaySure), hedef.onay),
                ("teklif", "Teklif", teklifli.Count, teklifli.Sum(t => t.Tutar), bekleyenTeklif, "teklifte", Ort(teklifSure), hedef.teklif),
                ("siparis", "Sipariş", siparisli.Count, siparisli.Sum(t => t.Siparisler.Sum(s => s.Matrah)), talepler.Count(SiparisBekliyor), "onaylı · sipariş bekliyor", Ort(siparisSure), hedef.siparis),
                ("kabul", "Mal kabul", kabulluSip.Count, kabulluSip.Sum(s => s.Matrah), acikSip.Count, "sipariş", Ort(kabulSure), hedef.kabul),
                ("fatura", "Fatura kontrolü", kontroller.Count, kontroller.Sum(k => k.FaturaTutar), kararBekleyen, uyusmaz > 0 ? $"{uyusmaz} uyuşmaz" : "karar bekliyor", Ort(faturaSure), null),
                ("odeme", "Ödemeye onay", odemeOnay.Count, odemeOnay.Sum(k => k.FaturaTutar), null, "", Ort(odemeSure), hedef.odeme),
            };
            var enCok = Math.Max(1, huniHam.Max(h => h.adet));
            var huni = huniHam.Select((h, i) => new
            {
                sira = i + 1, h.kod, h.ad, h.adet, tutar = R(h.tutar), h.bekleyen, h.bekleyenNot, ortGun = h.ort,
                hedefGun = h.hdf, hedefAsimi = h.ort is { } o1 && h.hdf is { } h1 && (decimal)o1 > h1,
                cubuk = Math.Round(100.0 * h.adet / enCok, 1),
            }).ToList();

            // ========================================================= BEKLEYENLER ==
            var esik = (int)Math.Ceiling(hedef.onay ?? UzunOnayVarsayilan);
            var bekleyenler = new List<BekleyenSatir>();
            int GunFark(DateTime d) => Math.Max(0, (int)Math.Floor((bugun - d.Date).TotalDays));
            Hatirlatma? H(long id) => hatir.TryGetValue(id, out var h) ? h : null;
            foreach (var t in talepler)
            {
                var kalem = Kalem(t.StokN, t.HizmetN);
                var bolundu = t.Siparisler.Count > 1;
                if (t.Durum == TalepTaslak)
                    bekleyenler.Add(new BekleyenSatir("t" + t.Id, "talep", t.Id, t.Id, t.No, "Taslak", t.Departman, t.Konu, kalem,
                        R(t.Tutar), t.Isteyen.Length > 0 ? $"{t.Isteyen} (talep eden)" : "talep eden", GunFark(t.Tarih),
                        OncelikKodu(t.Oncelik), false, "onaya gönderilmedi", 0, null, false, false, bolundu));
                else if (t.Durum == TalepOnayda && t.Bekleyen is { } bk)
                {
                    var h = H(t.Id);
                    var kim = bk.Atanan.Length > 0 ? $"{bk.Atanan} ({bk.Ad})" : bk.Ad;
                    var gun = GunFark(bk.BeklemeBasi);
                    bekleyenler.Add(new BekleyenSatir("t" + t.Id, "talep", t.Id, t.Id, t.No,
                        bk.Toplam > 1 ? $"Onay ({bk.Sira}. basamak)" : "Onay", t.Departman, t.Konu, kalem, R(t.Tutar), kim, gun,
                        OncelikKodu(t.Oncelik), gun > esik, bk.Durum == 3 ? "bilgi istendi" : "",
                        h?.Sayi ?? 0, h?.Son, h?.Bugun ?? false, !(h?.Bugun ?? false), bolundu));
                }
                else if (t.Siparisler.Count == 0 && t.Durum is not (TalepRed or TalepIptal) && t.Teklifler.FirstOrDefault(k => k.Durum < 3) is { } tk)
                    bekleyenler.Add(new BekleyenSatir("k" + tk.Id, "teklif", tk.Id, t.Id, tk.No, "Teklif", t.Departman, t.Konu, kalem,
                        R(t.Tutar), $"{tk.Davetli} firmadan {tk.Yanit} yanıt", GunFark(tk.Davet ?? tk.Ekleme), OncelikKodu(t.Oncelik),
                        hedef.teklif is { } ht && GunFark(tk.Davet ?? tk.Ekleme) > ht, $"talep {t.No}", 0, null, false, false, bolundu));
                else if (SiparisBekliyor(t))
                    bekleyenler.Add(new BekleyenSatir("t" + t.Id, "talep", t.Id, t.Id, t.No, "Sipariş", t.Departman, t.Konu, kalem,
                        R(t.Tutar), "Satınalma (siparişe dönüştürülmedi)", GunFark(SiparisBasi(t)), OncelikKodu(t.Oncelik),
                        hedef.siparis is { } hs && GunFark(SiparisBasi(t)) > hs, "onaylandı", 0, null, false, false, false));
            }
            foreach (var s in acikSip)
            {
                talepSoz.TryGetValue(s.TalepId, out var t);
                var gec = s.SozTeslim is { } st0 && st0 < bugun;
                var onc = t is null ? "normal" : OncelikKodu(t.Oncelik);
                if (gec && onc == "normal") onc = "yuksek";
                bekleyenler.Add(new BekleyenSatir("s" + s.Id, "siparis", s.Id, s.TalepId, s.No, "Mal kabul", t?.Departman ?? "",
                    t?.Konu ?? "", Kalem(s.StokN, s.HizmetN), R(s.Matrah),
                    s.Taraf + (s.SozTeslim is { } st1 ? $" (termin {st1:dd.MM})" : ""), GunFark(s.Tarih), onc, gec,
                    gec ? $"{GunFark(s.SozTeslim!.Value)} gün gecikme" : "", 0, null, false, false, (t?.Siparisler.Count ?? 0) > 1));
            }
            foreach (var k in kontroller.Where(k => k.OdemeDurum is not (1 or 4)))
            {
                siparisSoz.TryGetValue(k.SiparisId, out var s);
                Talep? t = null;
                if (s is not null) talepSoz.TryGetValue(s.TalepId, out t);
                var durumNotu = k.Sonuc == 0 ? "eşleştirilmedi"
                    : k.Sonuc == 1 ? "tuttu · ödeme kararı bekliyor"
                    : $"fark {k.Fark.ToString("N2", CultureInfo.GetCultureInfo("tr-TR"))} ₺" + (k.OdemeDurum == 2 ? " · ödeme durduruldu" : k.OdemeDurum == 3 ? " · itiraz" : "");
                bekleyenler.Add(new BekleyenSatir("f" + k.Id, "fatura", k.FaturaId, s?.TalepId ?? 0, k.FaturaNo, "Fatura kontrolü",
                    t?.Departman ?? "", k.FarkMetni.Length > 0 ? k.FarkMetni : t?.Konu ?? "", s is null ? "urun" : Kalem(s.StokN, s.HizmetN),
                    R(k.FaturaTutar), k.Ekleyen.Length > 0 ? k.Ekleyen : "Mali işler", GunFark(k.Ekleme), t is null ? "normal" : OncelikKodu(t.Oncelik),
                    Uyusmaz(k), durumNotu, 0, null, false, false, false));
            }
            var bekleyenSirali = bekleyenler.OrderByDescending(x => x.Gecikme).ThenByDescending(x => x.Gun).ToList();

            // ================================================= TEDARİKÇİ KARNESİ ==
            var firmaIdler = siparisler.Select(s => s.TarafId).Where(x => x > 0).Distinct().ToArray();
            var skorlar = new Dictionary<int, decimal>();
            var olaylar = new List<(int firma, DateTime zaman, int tur, string aciklama, decimal etki, int belge)>();
            if (firmaIdler.Length > 0)
            {
                foreach (var x in await b.ListeAsync("""
                        select v.firma_id, coalesce(v.skor, 100) from public.v_tedarikci_skor v where v.firma_id = any(@p0::int[])
                        """, null, [firmaIdler], o => new { id = o.GetInt32(0), skor = o.GetDecimal(1) }, iptal))
                    skorlar[x.id] = x.skor;
                olaylar = await b.ListeAsync("""
                    select o.firma_id, o.zaman, coalesce(o.tur, 0)::int, coalesce(o.aciklama, ''), coalesce(o.skor_etki, 0), coalesce(o.belge_id, 0)
                      from public.tedarikci_olay o
                     where o.firma_id = any(@p0::int[]) and o.zaman >= @p1 and o.zaman < @p2
                       and (o.sube_id is null or o.sube_id = 0 or o.sube_id = any(@p3::int[]))
                     order by o.zaman desc
                     limit 2000
                    """, null, [firmaIdler, Saat.UtcYap(baslangic, dilim), Saat.UtcYap(bitis.AddDays(1), dilim), subeler],
                    o => (o.GetInt32(0), Y(o.GetDateTime(1)), o.GetInt32(2), o.GetString(3), o.GetDecimal(4), o.GetInt32(5)), iptal);
            }
            static string OlayAdi(int tur) => tur switch { 1 => "gecikme", 2 => "uygunsuzluk", 3 => "fatura farkı", _ => "olay" };
            var tedarikciler = siparisler.Where(s => s.TarafId > 0).GroupBy(s => s.TarafId).Select(g =>
            {
                var l = g.ToList();
                int zamaninda = 0, olculen = 0; var gecikmeler = new List<double>();
                foreach (var s in l.Where(s => s.SozTeslim is not null))
                {
                    var soz = s.SozTeslim!.Value;
                    if (s.Teslim is { } te)
                    {
                        olculen++;
                        var gg = (te.Date - soz).TotalDays;
                        if (gg <= 0) zamaninda++; else gecikmeler.Add(gg);
                    }
                    else if (bugun > soz) { olculen++; gecikmeler.Add((bugun - soz).TotalDays); }
                }
                decimal fSip = 0, fRef = 0;
                foreach (var s in l)
                    foreach (var st in s.Satirlar)
                    {
                        var once = Once(st, s.Tarih, 3);
                        if (once.Count == 0 || st.Fiyat <= 0) continue;
                        fSip += st.Fiyat * st.Miktar; fRef += once.Average(a => a.Fiyat) * st.Miktar;
                    }
                return new
                {
                    id = g.Key, ad = l[0].Taraf, siparis = l.Count, tutar = R(l.Sum(s => s.Matrah)),
                    zamanindaOran = olculen > 0 ? Math.Round(100.0 * zamaninda / olculen, 1) : (double?)null,
                    olculen, ortGecikme = Ort(gecikmeler),
                    eksikFazla = l.Sum(s => s.Eksik), kaliteRet = l.Sum(s => s.Ret),
                    fiyatSapma = fRef > 0 ? Math.Round((fSip / fRef - 1) * 100, 1) : (decimal?)null,
                    faturaFark = l.Sum(s => s.Kontroller.Count(k => k.Sonuc >= 2)),
                    skor = skorlar.TryGetValue(g.Key, out var sk) ? sk : (decimal?)null,
                    hizmet = l.Any(s => s.HizmetN > 0), urun = l.Any(s => s.StokN > 0),
                    olaylar = olaylar.Where(x => x.firma == g.Key).Take(50).Select(x => new
                    {
                        zaman = x.zaman, tur = x.tur, turAd = OlayAdi(x.tur), aciklama = x.aciklama, skorEtki = x.etki, belgeId = x.belge,
                    }).ToList(),
                };
            }).OrderByDescending(x => x.tutar).ToList();

            // ===================================================== FİYAT ANALİZİ ==
            var tumSatir = siparisler.SelectMany(s => s.Satirlar).ToList();
            var fiyatHam = tumSatir.GroupBy(Anahtar).Select(g =>
            {
                if (!alislar.TryGetValue(g.Key, out var l)) return null;
                var son3 = l.Take(3).ToList();
                if (son3.Count < 2) return null;
                var ilk = son3[^1]; var son = son3[0];
                var miktar = g.Sum(x => x.Miktar);
                var degisim = ilk.Fiyat > 0 ? Math.Round((son.Fiyat - ilk.Fiyat) / ilk.Fiyat * 100, 1) : (decimal?)null;
                var f = g.First();
                return new
                {
                    anahtar = $"{g.Key.Item1}-{g.Key.Item2}", stokId = g.Key.Item1, hizmet = g.Key.Item1 == 0, kod = f.Kod, ad = f.Ad,
                    tedarikci = son.Taraf, onceki3 = son3.Count == 3 ? son3[2].Fiyat : (decimal?)null, onceki3Tarih = son3.Count == 3 ? son3[2].Tarih : (DateTime?)null,
                    onceki2 = son3[1].Fiyat, onceki2Tarih = son3[1].Tarih, son = son.Fiyat, sonTarih = son.Tarih,
                    degisim, yuksek = degisim > 10, miktar, etki = R((son.Fiyat - ilk.Fiyat) * miktar),
                };
            }).Where(x => x is not null).Select(x => x!).OrderByDescending(x => x.etki).ToList();

            // ========================================================== TASARRUF ==
            var tasarrufSatir = new List<object>();
            decimal tasarruf = 0, ortTeklifTop = 0, sonAlisFarkTop = 0, tekTeklifTutar = 0; int tekTeklif = 0;
            foreach (var s in siparisler.Where(s => s.TeklifId > 0))
            {
                if (!teklifSoz.TryGetValue(s.TeklifId, out var k) || k.Yanit == 0 || k.Ort is null) continue;
                if (k.Yanit == 1) { tekTeklif++; tekTeklifTutar += s.Matrah; continue; }
                var kazanan = k.Kazanan ?? s.Matrah;
                var fark = k.Ort.Value - kazanan;
                decimal? sonAlis = null;
                foreach (var st in s.Satirlar)
                {
                    var once = Once(st, s.Tarih, 1);
                    if (once.Count == 0) continue;
                    sonAlis = (sonAlis ?? 0) + once[0].Fiyat * st.Miktar - st.Tutar;
                }
                tasarruf += fark; ortTeklifTop += k.Ort.Value; sonAlisFarkTop += sonAlis ?? 0;
                talepSoz.TryGetValue(s.TalepId, out var t);
                tasarrufSatir.Add(new
                {
                    siparisId = s.Id, siparisNo = s.No, teklifId = k.Id, teklifNo = k.No, talepNo = t?.No ?? "", tedarikci = s.Taraf,
                    teklifSayisi = k.Yanit, ortTeklif = R(k.Ort.Value), kazananTeklif = R(kazanan), siparisTutar = R(s.Matrah),
                    tasarruf = R(fark), oran = k.Ort > 0 ? Math.Round(fark / k.Ort.Value * 100, 1) : (decimal?)null,
                    sonAlisFark = sonAlis is null ? (decimal?)null : R(sonAlis.Value),
                    kalem = Kalem(s.StokN, s.HizmetN),
                });
            }

            // ============================================================= BÜTÇE ==
            //   v_butce_durum: harcanan (fatura) + taahhüt (açık sipariş) kalanı düşer; onaylı talep bilgi amaçlı.
            var butceSatir = await b.ListeAsync("""
                select v.id, coalesce(v.kod, ''), coalesce(v.ad, ''), coalesce(v.tutar, 0), coalesce(v.harcanan, 0), coalesce(v.taahhut, 0),
                       coalesce(v.kalan, 0), coalesce(v.kullanim_yuzde, 0), coalesce(k.asim_davranis, 1)::int,
                       coalesce((select sum(t.tahmini_tutar) from public.satinalma_talep t
                                  where t.butce_kalem_id = v.id and t.durum in (2, 4)
                                    and extract(year from t.tarih) = v.yil), 0)
                  from public.v_butce_durum v
                  join public.butce_kalem k on k.id = v.id
                 where v.yil = @p0 and (v.sube_id is null or v.sube_id = any(@p1::int[])) and (@p2 = 0 or v.id = @p2)
                 order by v.kod, v.ad
                """, null, [yil, subeler, but0], o => new
                {
                    id = o.GetInt32(0), kod = o.GetString(1), ad = o.GetString(2), plan = o.GetDecimal(3), gerceklesen = o.GetDecimal(4),
                    taahhut = o.GetDecimal(5), kalan = o.GetDecimal(6), kullanim = o.GetDecimal(7), asim = o.GetInt32(8),
                    asimAd = AsimAdi(o.GetInt32(8)), onayliTalep = o.GetDecimal(9),
                }, iptal);
            var bPlan = butceSatir.Sum(x => x.plan); var bGer = butceSatir.Sum(x => x.gerceklesen); var bTaah = butceSatir.Sum(x => x.taahhut);
            var butceToplam = new
            {
                plan = R(bPlan), gerceklesen = R(bGer), taahhut = R(bTaah), onayliTalep = R(butceSatir.Sum(x => x.onayliTalep)),
                kalan = R(butceSatir.Sum(x => x.kalan)), kullanim = bPlan > 0 ? Math.Round((bGer + bTaah) / bPlan * 100, 1) : (decimal?)null,
            };

            // ================================================ KRİTİK STOKTAN GELEN ==
            var kritik = talepler.Where(t => t.Kaynak == 2).OrderByDescending(t => t.Tarih).Select(t =>
            {
                var ilk = t.Siparisler.OrderBy(s => s.Tarih).FirstOrDefault();
                return new
                {
                    id = t.Id, no = t.No, tarih = t.Tarih, elle = t.KaynakTur == KaynakTurKritikElle,
                    kaynakAd = t.KaynakTur == KaynakTurKritikElle ? "Kritik Stok İcmali (elle)" : "Kritik stok (otomatik)",
                    urun = t.IlkAd + (t.SatirN > 1 ? $" +{t.SatirN - 1} kalem" : ""), miktar = t.Miktar, durum = t.Durum,
                    durumAd = DurumAdi(t.Durum),
                    talepSiparisGun = ilk is null ? (double?)null : Math.Round(Sure(t.Tarih, ilk.Tarih), 1),
                    tedarikci = ilk?.Taraf ?? "", siparisId = ilk?.Id ?? 0, bolundu = t.Siparisler.Count > 1,
                };
            }).ToList();

            // ============================================================= ÖZET ==
            var tsSure = siparisli.Select(t => Sure(t.Tarih, t.IlkSiparis!.Value)).ToList();
            var terminOlculen = siparisler.Where(s => s.SozTeslim is not null && s.Teslim is not null).ToList();
            var ozet = new
            {
                talep = talepler.Count, talepTutar = R(talepler.Sum(t => t.Tutar)), kritik = talepler.Count(t => t.Kaynak == 2),
                hizmetTalep = talepler.Count(t => t.HizmetN > 0),
                acik = talepler.Count(t => t.Durum is TalepOnayda or TalepOnaylandi or TalepTeklifte),
                onayda = talepler.Count(t => t.Durum == TalepOnayda), teklifte = talepler.Count(t => t.Durum == TalepTeklifte),
                onayli = talepler.Count(t => t.Durum == TalepOnaylandi), taslak = talepler.Count(t => t.Durum == TalepTaslak),
                talepSiparisGun = Ort(tsSure), talepSiparisMedyan = Medyan(tsSure), bolunen = talepler.Count(t => t.Siparisler.Count > 1),
                siparis = siparisler.Count, kabulGun = Ort(kabulSure),
                terminUyum = terminOlculen.Count > 0
                    ? Math.Round(100.0 * terminOlculen.Count(s => s.Teslim!.Value.Date <= s.SozTeslim!.Value) / terminOlculen.Count, 1) : (double?)null,
                teklifTalep = teklifli.Count > 0 ? Math.Round((double)teklifli.Sum(t => t.Teklifler.Sum(k => k.Yanit)) / teklifli.Count, 1) : (double?)null,
                tekTeklif, tekTeklifTutar = R(tekTeklifTutar),
                tasarruf = R(tasarruf), tasarrufOran = ortTeklifTop > 0 ? Math.Round(tasarruf / ortTeklifTop * 100, 1) : (decimal?)null,
                sonAlisFark = R(sonAlisFarkTop), tasarrufSiparis = tasarrufSatir.Count,
                uyusmaz, odemeDurdu = kontroller.Count(k => k.OdemeDurum == 2),
                farkTutar = R(kontroller.Where(Uyusmaz).Sum(k => Math.Abs(k.Fark))),
                odemeOnay = R(odemeOnay.Sum(k => k.FaturaTutar)),
                siparisTutar = R(siparisler.Sum(s => s.Matrah)),
                butceKullanim = butceToplam.kullanim,
                uzunOnay = bekleyenler.Count(x => x.BelgeTur == "talep" && x.Asama.StartsWith("Onay", StringComparison.Ordinal) && x.Gun > esik),
                uzunOnayEsik = esik,
                tedarikci = tedarikciler.Count,
            };

            // ============================================================ SEÇİM ==
            var departmanlar = await b.ListeAsync("""
                select d.id, coalesce(d.ad, '') from public.departman d order by d.sira nulls last, d.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var kategoriler = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.kategori k where coalesce(k.tur, 1) = 1 order by k.kod, k.ad
                """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var tedSecim = await b.ListeAsync("""
                select distinct b.taraf_id,
                       coalesce(nullif(b.taraf_unvan, ''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(200), '')::varchar(200)
                  from public.belge b
                  join public.belge_satinalma bs on bs.id = b.id
                  join public.satinalma_talep tl on tl.id = bs.talep_id
                  left join public.taraf t on t.id = b.taraf_id
                 where b.tur = 9 and coalesce(b.taraf_id, 0) > 0
                   and tl.tarih >= @p0::date and tl.tarih <= @p1::date
                   and (tl.sube_id is null or tl.sube_id = any(@p2::int[]))
                 order by 2
                """, null, [baslangic, bitis, subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
            var butceSecim = await b.ListeAsync("""
                select k.id, coalesce(nullif(btrim(coalesce(k.kod, '') || ' ' || coalesce(k.ad, '')), ''), '?')
                  from public.butce_kalem k
                 where k.aktif = 1 and k.yil = @p0 and (k.sube_id is null or k.sube_id = any(@p1::int[]))
                 order by k.kod, k.ad
                """, null, [yil, subeler], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);

            return Results.Ok(new
            {
                bas = baslangic, bit = bitis, sube = sube ?? 0, departman = dep0, kategori = kat0, tedarikci = ted0, butceKalem = but0,
                kaynak = kay0, yil, hedefler = hedef, ozet, huni,
                redIptal = new { adet = redIptal.Count, tutar = R(redIptal.Sum(t => t.Tutar)) },
                bekleyenler = bekleyenSirali.Take(500).ToList(), bekleyenSayi = bekleyenSirali.Count,
                tedarikciler,
                fiyat = new { satirlar = fiyatHam.Take(300).ToList(), kalem = fiyatHam.Count, etki = R(fiyatHam.Sum(x => x.etki)) },
                tasarruf = new
                {
                    satirlar = tasarrufSatir, toplam = R(tasarruf), oran = ozet.tasarrufOran, sonAlisFark = R(sonAlisFarkTop),
                    tekTeklif, tekTeklifTutar = R(tekTeklifTutar),
                },
                butce = new { yil, satirlar = butceSatir, toplam = butceToplam },
                kritik,
                secim = new
                {
                    subeler = baglam.Subeler.Select(s => new { id = s.Id, ad = s.Ad }).ToList(),
                    departmanlar, kategoriler, tedarikciler = tedSecim, butceler = butceSecim,
                },
                yetkiler = new
                {
                    // Hatırlatma "satinalma.talep Gör yeterli" (mockup tasarım notu); onay / ret Onay ekranında.
                    hatirlat = baglam.Yetkiler.Var("satinalma.talep", Islem.Gor),
                },
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ========================================================= HATIRLAT ===
        // ONAYCIYA HATIRLAT (karar 25.10.2026). Aynı belge için GÜNDE BİR (şube günü; ikinci istek 422).
        //   Bekleyen basamağın sahiplerine mevcut onay bildirimi (OnayBildirimi.SiradakiniBildirAsync -
        //   İzin / Avans "hatırlat" uçlarıyla aynı yol) gider. AYNI ONAYCIYA İKİNCİ KEZ hatırlatılıyorsa
        //   (önceki bir günde) zincirin bir üst basamağına da bilgi gider (ust_bilgi = 1, şablon
        //   onay.hatirlatma). Hatırlatma talep loguna yazılır. Bildirim hatası hatırlatmayı düşürmez.
        grup.MapPost("/hatirlat", async (HatirlatIstegi istek, VeriKaynagi veri, BaglamCozucu cozucu, LogDeposu log,
                                         Servisler.OnayBildirimi haber, BildirimDeposu bildirim, ILoggerFactory gunlukFab,
                                         HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            baglam.YetkiIste("satinalma.talep", Islem.Gor);
            var tur = (istek.BelgeTur ?? "talep").Trim().ToLowerInvariant();
            if (tur is not ("talep" or "teklif" or "fatura"))
                throw GentegreHatasi.Dogrulama("Geçersiz belge türü.", new AlanHatasi("belgeTur", "talep · teklif · fatura"));
            if (tur != "talep")
                throw GentegreHatasi.IsKurali("Hatırlatma yalnız onay bekleyen talep için gönderilir; teklif ve fatura kontrolü için belgeye gidin.");
            if (istek.BelgeId <= 0) throw GentegreHatasi.Dogrulama("Belge seçilmeli.", new AlanHatasi("belgeId", "Zorunlu."));

            var dilim = baglam.ZamanDilimi;
            var bugun = Saat.BugunDilim(dilim);
            var gunBas = Saat.UtcYap(bugun, dilim);
            var gunBit = gunBas.AddDays(1);

            await using var b = await veri.AcAsync(iptal);
            await using var tx = await b.BeginTransactionAsync(iptal);

            // AYNI BELGEYE EŞZAMANLI İKİ İSTEK günde bir kuralını delmesin: belge başına işlem kilidi.
            await b.CalistirAsync("select pg_advisory_xact_lock(1176, @p0)", tx, [(int)(istek.BelgeId % int.MaxValue)], iptal);

            var talep = await b.TekAsync("""
                select t.id, t.sube_id, coalesce(t.durum, 0)::int, coalesce(nullif(t.talep_no, ''), '#' || t.id),
                       coalesce(nullif(t.gerekce, ''), 'Satınalma talebi')
                  from public.satinalma_talep t where t.id = @p0
                """, tx, [istek.BelgeId], o => new
                {
                    id = o.GetInt64(0), sube = o.IsDBNull(1) ? (int?)null : o.GetInt32(1), durum = o.GetInt32(2),
                    no = o.GetString(3), konu = o.GetString(4),
                }, iptal) ?? throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");
            if (talep.sube is { } ts && !baglam.Subeler.Any(s => s.Id == ts)) throw GentegreHatasi.Bulunamadi("Talep bulunamadı.");
            if (talep.durum != TalepOnayda) throw GentegreHatasi.IsKurali("Talep onayda değil; hatırlatılacak onaycı yok.");

            var bk = await b.TekAsync("""
                select v.onay_id, v.adim_id, v.sira::int, coalesce(v.adim_ad, ''), coalesce(v.rol, 0)::int,
                       coalesce(v.atanan_kullanici_id, 0), coalesce(v.akis_kod, ''),
                       coalesce((select max(x.karar_zamani) from public.onay_adim x where x.onay_id = v.onay_id and x.sira < v.sira),
                                v.baslama, now())
                  from public.v_onay_bekleyen v
                 where v.kaynak_tur = @p1 and v.kaynak_id = @p0
                 order by v.sira limit 1
                """, tx, [istek.BelgeId, LogTalep], o => new
                {
                    onayId = o.GetInt64(0), adimId = o.GetInt64(1), sira = o.GetInt32(2), ad = o.GetString(3), rol = o.GetInt32(4),
                    atanan = o.GetInt32(5), akis = o.GetString(6), beklemeBasi = o.GetDateTime(7),
                }, iptal) ?? throw GentegreHatasi.IsKurali("Bekleyen onay basamağı yok.");

            var bugunku = await b.TekAsync("""
                select h.an, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
                  from public.satinalma_hatirlatma h left join public.taraf t on t.id = h.gonderen
                 where h.belge_tur = 'talep' and h.belge_id = @p0 and h.an >= @p1 and h.an < @p2
                 order by h.an desc limit 1
                """, tx, [istek.BelgeId, gunBas, gunBit], o => new { an = o.GetDateTime(0), kim = o.GetString(1) }, iptal);
            if (bugunku is not null)
                throw GentegreHatasi.IsKurali(
                    $"{talep.no} için bugün zaten hatırlatma gönderildi ({Saat.Yerel(bugunku.an, dilim):HH:mm}"
                    + (bugunku.kim.Length > 0 ? $", {bugunku.kim}" : "") + "). Aynı belge için günde bir hatırlatma gönderilir.",
                    new { kod = "GUNDE_BIR" });

            var alicilar = await AlicilarAsync(b, tx, bk.akis, bk.rol, bk.atanan, iptal);
            if (alicilar.Count == 0)
                throw GentegreHatasi.IsKurali($"\"{bk.ad}\" basamağının onaycısı bulunamadı (atanan kişi ya da rol yetkisi olan aktif kullanıcı yok).");

            // İKİNCİ HATIRLATMA = aynı onaycılara önceki bir günde hatırlatılmış. Zincir ilerlediyse
            //   (yeni basamak, yeni kişi) sayaç o kişiden yeniden başlar.
            var ikinci = await b.TekDegerAsync<bool>("""
                select exists (select 1 from public.satinalma_hatirlatma h
                                where h.belge_tur = 'talep' and h.belge_id = @p0 and h.ust_bilgi = 0
                                  and h.alici_id = any(@p1::int[]) and h.an < @p2)
                """, tx, [istek.BelgeId, alicilar.ToArray(), gunBas], iptal);

            var ustAdim = ikinci
                ? await b.TekAsync("""
                    select a.id, a.sira::int, coalesce(a.ad, ''), coalesce(a.rol, 0)::int, coalesce(a.atanan_kullanici_id, 0)
                      from public.onay_adim a
                     where a.onay_id = @p0 and a.sira > @p1 and coalesce(a.durum, 0) in (0, 3)
                     order by a.sira limit 1
                    """, tx, [bk.onayId, bk.sira], o => new
                    {
                        id = o.GetInt64(0), sira = o.GetInt32(1), ad = o.GetString(2), rol = o.GetInt32(3), atanan = o.GetInt32(4),
                    }, iptal)
                : null;
            var ustAlicilar = ustAdim is null ? []
                : (await AlicilarAsync(b, tx, bk.akis, ustAdim.rol, ustAdim.atanan, iptal)).Where(x => !alicilar.Contains(x)).ToList();

            var kisiler = await KisilerAsync(b, tx, alicilar, iptal);
            var ustKisiler = await KisilerAsync(b, tx, ustAlicilar, iptal);

            foreach (var a in alicilar)
                await b.CalistirAsync("""
                    insert into public.satinalma_hatirlatma (belge_tur, belge_id, alici_id, ust_bilgi, gonderen)
                    values ('talep', @p0, @p1, 0, @p2)
                    """, tx, [istek.BelgeId, a, baglam.KullaniciId], iptal);
            foreach (var a in ustAlicilar)
                await b.CalistirAsync("""
                    insert into public.satinalma_hatirlatma (belge_tur, belge_id, alici_id, ust_bilgi, gonderen)
                    values ('talep', @p0, @p1, 1, @p2)
                    """, tx, [istek.BelgeId, a, baglam.KullaniciId], iptal);

            var beklemeGun = Math.Max(0, (int)Math.Floor((bugun - Saat.Yerel(bk.beklemeBasi, dilim).Date).TotalDays));
            await log.YazAsync(b, tx, LogIslemi.Degistir, LogTalep, istek.BelgeId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["aksiyon"] = "onayciya-hatirlat",
                    ["basamak"] = $"{bk.sira} · {bk.ad}",
                    ["alicilar"] = string.Join(", ", kisiler.Select(k => k.Ad)),
                    ["ustBilgi"] = ustAdim is null ? "" : $"{ustAdim.sira} · {ustAdim.ad}: " + string.Join(", ", ustKisiler.Select(k => k.Ad)),
                    ["beklemeGun"] = beklemeGun.ToString(CultureInfo.InvariantCulture),
                    ["kaynak"] = "satinalma-icmali",
                }, iptal: iptal);

            await tx.CommitAsync(iptal);

            // BİLDİRİM İŞLEMDEN SONRA: kuyruk yazımı kendi bağlantısını açar; hata hatırlatmayı düşürmez.
            var gunluk = gunlukFab.CreateLogger("SatinalmaIcmali");
            var yazilan = 0;
            try { yazilan += await haber.SiradakiniBildirAsync(b, bk.onayId, baglam.KullaniciId, baglam.SubeId, iptal); }
            catch (Exception h) { gunluk.LogWarning(h, "Satınalma hatırlatması yazılamadı (talep {Id}).", istek.BelgeId); }
            foreach (var k in ustKisiler)
            {
                try
                {
                    var (kanal, adres) = k.Eposta.Length > 0 ? (BildirimKanali.Eposta, k.Eposta) : (BildirimKanali.Sms, k.Cep);
                    if (adres.Length == 0)
                    {
                        gunluk.LogWarning("Üst basamak bilgisi gönderilemedi: kullanıcı {Kid} için e-posta ve cep tanımlı değil.", k.Id);
                        continue;
                    }
                    var id = await bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                        SablonKodu: "onay.hatirlatma", Kanal: kanal, Alici: adres,
                        Degiskenler: new Dictionary<string, string>
                        {
                            ["alici"] = k.Ad, ["kayitNo"] = talep.no, ["konu"] = talep.konu,
                            ["adimAd"] = $"{bk.ad} (bilgi: sizden önceki basamakta, ikinci hatırlatma)",
                            ["gecikmeGun"] = beklemeGun.ToString(CultureInfo.InvariantCulture),
                        },
                        KullaniciId: k.Id, KaynakTur: Servisler.OnayBildirimi.KaynakOnay, KaynakId: (int)bk.adimId),
                        baglam.KullaniciId, baglam.SubeId, iptal);
                    if (id is not null) yazilan++;
                }
                catch (Exception h) { gunluk.LogWarning(h, "Üst basamak bilgisi yazılamadı (kullanıcı {Kid}).", k.Id); }
            }

            return Results.Ok(new
            {
                belgeTur = tur, belgeId = istek.BelgeId, talepNo = talep.no, basamak = bk.sira, adimAd = bk.ad,
                alicilar = kisiler.Select(k => new { id = k.Id, ad = k.Ad }).ToList(),
                eskalasyon = ustAdim is not null && ustKisiler.Count > 0, ikinci,
                ustAdim = ustAdim is null ? null : new { basamak = ustAdim.sira, ad = ustAdim.ad },
                ustBilgi = ustKisiler.Select(k => new { id = k.Id, ad = k.Ad }).ToList(),
                bildirim = yazilan, beklemeGun, izlemeNo = baglam.IzlemeNo,
            });
        });
    }
}
