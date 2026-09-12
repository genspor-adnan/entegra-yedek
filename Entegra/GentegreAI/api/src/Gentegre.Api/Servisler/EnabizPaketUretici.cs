using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-NABIZ PAKET ÜRETİMİ (415, Faz 1) — klinik olaydan USS paketine.
///
/// <para><b>Üretim gönderimden ayrıdır.</b> USS test hesabı / KTS tescili
/// henüz yok; paketler yine de üretilir ve kuyrukta bekler. Üretimi kapıya
/// bağlamak, kapı açıldığında geçmiş veriyi kaybetmek olurdu.</para>
///
/// <para><b>İdempotent.</b> Aynı kaynak için aynı içerik ikinci kez paket
/// açmaz (içerik hash'i). Muayene her kaydedildiğinde paket üretmek, USS'ye
/// aynı muayeneyi onlarca kez göndermek demekti.</para>
///
/// <para><b>Doğrulama üretim anında.</b> Zorunlu alan eksikse paket kuyruğa
/// GİRMEZ (durum 0 "eksik alan") ve eksiğin hangi kaynak kolondan gelmesi
/// gerektiği alan satırında yazar. Eksiği gönderim anında bulmak, hatayı
/// hekim ekrandan ayrıldıktan saatler sonra geri getirirdi.</para>
/// </summary>
public sealed partial class EnabizPaketUretici
{
    private readonly VeriKaynagi _veri;
    private readonly ILogger<EnabizPaketUretici> _gunluk;

    public EnabizPaketUretici(VeriKaynagi veri, ILogger<EnabizPaketUretici> gunluk)
    {
        _veri = veri;
        _gunluk = gunluk;
    }

    /// <summary>Paket kaynağı: 1 başvuru · 2 muayene · 3 reçete.</summary>
    public const short KaynakBasvuru = 1;
    public const short KaynakMuayene = 2;
    public const short KaynakRecete = 3;

    public sealed record Sonuc(long PaketId, string PaketNo, short Durum, int AlanSayisi,
                               IReadOnlyList<string> Eksikler);

    /// <summary>
    /// Verilen paket türü için paketi üretir (varsa mevcudu döndürür).
    ///
    /// Alan çözümleme SQL'de: USS alanı ile kaynak kolon eşlemesi tek yerde
    /// dursun, C# tarafında satır satır okuma/yazma olmasın.
    /// </summary>
    public async Task<Sonuc?> UretAsync(string paketKodu, int kaynakId, int kullaniciId,
                                        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var tur = await baglanti.TekAsync("""
            select t.id, t.uss_paket_kodu, t.sure_siniri_saat, t.zorunlu_alanlar::text, t.aktif
              from public.enabiz_paket_turu t where t.kod = @p0
            """, islem, [paketKodu], o => new
            {
                Id = o.GetInt16(0), Kod = o.GetString(1), Sure = o.GetInt16(2),
                Zorunlu = o.GetString(3), Aktif = o.GetInt16(4),
            }, iptal);

        // Tur kapaliysa paket URETILMEZ: kurum o paketi gondermiyor demektir.
        if (tur is null || tur.Aktif != 1) return null;

        var alanlar = await AlanlariCozAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (alanlar.Count == 0) return null;

        var zorunlu = JsonSerializer.Deserialize<string[]>(tur.Zorunlu) ?? [];
        var eksikler = zorunlu
            .Where(z => !alanlar.Any(a => a.Alan == z && a.Deger.Trim().Length > 0))
            .ToList();

        var baglam = await BaglamAlAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (baglam is null) return null;

        // PARMAK IZINE SKRS KODU DA GIRER (602): kod, alanin USS'ye giden
        //   ASIL degeridir - `deger` yalnizca okunabilir karsiligidir
        //   ("e-Nabız / USS" adi degismeden kurum kodu 11111111'den 500154'e
        //   gecebilir). Kod hash'e girmeyince icerik degismis sayilmiyor,
        //   "ayni icerik -> ayni paket" korumasi yeni paketi engelliyordu:
        //   kurum kodu duzeltildigi halde kart kaydedilince hala eski,
        //   REDDEDILMIS paket donuyordu (gercek vaka, paket 156 / E0009).
        // URETIM ZAMANI PARMAK IZINE GIRMEZ (620).
        //
        // PAKETE_AIT_ISLEM_ZAMANI `now()` ile doluyor. Hash'e girince "ayni
        //   icerik -> ayni paket" korumasi HIC tutmuyordu: hicbir sey
        //   degismeden kart ikinci kez kaydedilince zaman farkli oluyor,
        //   hash degisiyor ve AYNI basvuru icin ikinci bir paket aciliyordu
        //   (gercek vaka: 364 ve 365, aralarindaki tek fark dort dakika).
        //   Ikinci paket USS'ye gidince "E2033 ... daha once alinmis bir
        //   SYSTakipNo bulunmaktadir" ile geri donuyor - yani kuyruk kendi
        //   kendine mukerrer is uretiyordu.
        //
        // Zaman bir ICERIK degil, gonderimin damgasidir; parmak izi
        //   HASTANIN VERISINI tanimlamali.
        // SYS TAKIP NUMARASI DA PARMAK IZINE GIRMEZ (620).
        //
        // Numara USS'nin bize verdigi KAYIT KIMLIGIDIR, hastanin verisi
        //   degil. Hash'e girince kendi kendini besleyen bir dongu oluyordu:
        //   101 gonderiliyor -> numara basvuruya yaziliyor -> kart bir daha
        //   kaydedilince paket artik numarayi tasiyor -> icerik "degismis"
        //   sayilip IKINCI bir 101 aciliyor (gercek vaka: paket 366, tek
        //   farki doldurulmus SYSTakipNo). Hicbir klinik veri degismeden
        //   USS'ye guncelleme gonderirdi.
        var hash = Hash(alanlar
            .Where(a => a.Kaynak != "(uretim zamani)"
                     && a.Kaynak != "belge_basvuru.sys_takip_no")
            .Select(a => $"{a.Alan}={a.Deger}|{a.SkrsKod}"));
        var kaynakTur = MuayeneKaynakli(paketKodu) ? KaynakMuayene : KaynakBasvuru;

        // AYNI ICERIK -> AYNI PAKET. Kaynak yeniden kaydedilince yeni satir
        //   acilmaz; icerik degistiyse yeni paket (guncelleme) acilir.
        //
        // IPTAL EDILEN (durum 5) SAYILMAZ: "kaynaktan yeniden uret" once eski
        //   paketi iptal ediyor; iptali de "mevcut" saymak, kaynak degismediginde
        //   paketi tamamen yok ederdi (iptal edildi, yenisi acilmadi).
        var mevcut = await baglanti.TekAsync("""
            select p.id, p.paket_no, p.durum from public.enabiz_paket p
             where p.paket_turu_id = @p0 and p.kaynak_tur = @p1 and p.kaynak_id = @p2
               and p.islem = 1 and p.icerik_hash = @p3 and p.durum <> 5
             limit 1
            """, islem, [tur.Id, kaynakTur, kaynakId, hash],
            o => new { Id = o.GetInt64(0), No = o.GetString(1), Durum = o.GetInt16(2) },
            iptal);
        if (mevcut is not null)
        {
            await islem.CommitAsync(iptal);
            // Mevcut paketin GERCEK durumu doner: bos paket no ve durum 0
            //   dondurmek, cagiraninin "eksik alan var" sanmasina yol aciyordu.
            return new Sonuc(mevcut.Id, mevcut.No, mevcut.Durum, alanlar.Count, eksikler);
        }

        var durum = (short)(eksikler.Count > 0 ? 0 : 1);
        var paketId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_paket
                   (paket_no, paket_turu_id, islem, kaynak_tur, kaynak_id, belge_id,
                    hasta_id, hekim_id, sube_id, olay_tarihi, son_tarih, durum,
                    icerik_hash, ekleyen)
            values ('', @p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7,
                    @p7 + (@p8 || ' hours')::interval, @p9, @p10, @p11)
            returning id
            """, islem,
            [tur.Id, kaynakTur, kaynakId, baglam.BelgeId, baglam.HastaId, baglam.HekimId,
             baglam.SubeId, baglam.OlayTarihi, tur.Sure, durum, hash, kullaniciId], iptal);

        // Paket no INSERT SONRASI: yil + sira, kullanicinin kuyruk ekraninda
        //   arayabilecegi tek kimlik.
        var paketNo = $"PK-{DateTime.Today:yyyy}-{paketId:000000}";
        await baglanti.CalistirAsync(
            "update public.enabiz_paket set paket_no = @p1 where id = @p0",
            islem, [paketId, paketNo], iptal);

        var sira = 0;
        foreach (var a in alanlar)
        {
            var eksikMi = zorunlu.Contains(a.Alan) && a.Deger.Trim().Length == 0;
            await baglanti.CalistirAsync("""
                insert into public.enabiz_paket_alan
                       (paket_id, uss_alan, deger, kaynak_alan, skrs_liste, gecerli, sorun,
                        skrs_kod, skrs_sistem, sira)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
                """, islem,
                [paketId, a.Alan, a.Deger, a.Kaynak, a.SkrsListe,
                 (short)(eksikMi ? 0 : 1),
                 eksikMi ? $"Zorunlu alan bos ({a.Kaynak})" : "",
                 a.SkrsKod, a.SkrsSistem, (short)sira++], iptal);
        }

        await islem.CommitAsync(iptal);
        _gunluk.LogInformation("e-Nabiz paketi uretildi {No} ({Kod}) durum {Durum}",
            paketNo, paketKodu, durum);

        return new Sonuc(paketId, paketNo, durum, alanlar.Count, eksikler);
    }

    // ------------------------------------------------------------------ alan
    /// <summary>
    /// Bir paket alani. `Alan` USS'nin GERCEK adi ve YOLUDUR (605):
    /// "HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES". `SkrsSistem` doluysa
    /// deger kodlanmis yazilir (code + value), bossa duz.
    /// </summary>
    private sealed record AlanDegeri(string Alan, string Deger, string Kaynak,
                                     string SkrsListe, string SkrsKod = "",
                                     string SkrsSistem = "");

    private sealed record PaketBaglami(int? BelgeId, int? HastaId, int? HekimId, int SubeId,
                                       DateTime OlayTarihi);

    /// <summary>
    /// Paketin kaynağı muayene mi, başvuru mu.
    ///
    /// 106 Hasta Çıkış da MUAYENEDEN doğar (çıkış zamanı muayenenin
    /// tamamlanmasıdır). Tek tek "== MUAYENE" karşılaştırması yüzünden 106
    /// hiç üretilmiyordu: bağlam başvuru sanılıp muayene id'siyle belge
    /// aranıyor, bulunamayınca paket sessizce atlanıyordu.
    /// </summary>
    private static bool MuayeneKaynakli(string paketKodu)
        => paketKodu is "MUAYENE" or "HASTA_CIKIS";

    private static async Task<PaketBaglami?> BaglamAlAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
        => MuayeneKaynakli(paketKodu)
            ? await baglanti.TekAsync("""
                select m.belge_id, m.taraf_id, m.personel_id, m.sube_id,
                       coalesce(m.baslangic, m.muayene_tarihi)
                  from public.muayene m where m.id = @p0
                """, islem, [kaynakId], Oku, iptal)
            : await baglanti.TekAsync("""
                select b.id, b.taraf_id, bb.personel_id, b.sube_id, b.belge_tarihi
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, islem, [kaynakId], Oku, iptal);

    private static PaketBaglami Oku(NpgsqlDataReader o) => new(
        o.IsDBNull(0) ? null : o.GetInt32(0),
        o.IsDBNull(1) ? null : o.GetInt32(1),
        o.IsDBNull(2) ? null : o.GetInt32(2),
        o.GetInt32(3),
        o.IsDBNull(4) ? DateTime.Now : o.GetDateTime(4));

    /// <summary>
    /// USS alanlarını kaynak kolonlardan çözer.
    ///
    /// Eşleme SQL'de tek yerde: hangi USS alanının nereden geldiği paket
    /// kartında da aynı metinle görünsün (kaynak_alan kolonu). Sorguların
    /// kendisi <c>EnabizPaketUretici.Sorgular.cs</c> dosyasındadır - paket
    /// başına bir sabit. Bu metot yalnızca SEÇER ve ÇALIŞTIRIR: beş paketin
    /// SQL'i tek gövdede 600 satırı bulmuştu ve hangi paketin nerede
    /// bittiğini okumak, aradığını bulmaktan uzun sürüyordu.
    ///
    /// SKRS kodlu alanlar `fn_skrs_kod` / `fn_skrs_ad` / `fn_skrs_guid`
    /// çağırır (610). Kod listeleri 609'dan bu yana SKRS'nin kendisi
    /// olduğu için çeviriye gerek yok - yerel değerin KENDİSİ SKRS
    /// kodudur; codeSystemGuid de listenin kaydından gelir, SQL'e gömülü
    /// sabitten değil. `enabiz_kod_esleme` yalnızca SKRS'de karşılığı
    /// olmayan, kuruma özel eşlemeler için yedek yol olarak durur.
    /// </summary>
    private static Task<List<AlanDegeri>> AlanlariCozAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
    {
        var sql = AlanSorgusu(paketKodu);

        return sql.Length == 0
            ? Task.FromResult(new List<AlanDegeri>())
            : baglanti.ListeAsync(sql, islem, [kaynakId],
                o => new AlanDegeri(o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
                                    o.GetString(2), o.GetString(3),
                                    o.FieldCount > 4 && !o.IsDBNull(4) ? o.GetString(4) : "",
                                    o.FieldCount > 5 && !o.IsDBNull(5) ? o.GetString(5) : ""),
                iptal);
    }

    /// <summary>İçerik parmak izi - aynı içerik ikinci kez paket açmasın.</summary>
    private static string Hash(IEnumerable<string> parcalar)
        => Convert.ToHexString(SHA256.HashData(
               Encoding.UTF8.GetBytes(string.Join("\n", parcalar)))).ToLowerInvariant()[..64];
}
