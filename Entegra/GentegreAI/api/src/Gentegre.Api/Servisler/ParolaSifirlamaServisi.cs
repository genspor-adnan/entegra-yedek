using System.Security.Cryptography;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PAROLAMI UNUTTUM (843, kullanıcı: "parolamı unuttum seçeneği ekle login e").
///
/// İki adım, ikisi de oturumsuz:
///  1. <see cref="KodGonderAsync"/>: kullanıcı kodu → hesabın kayıtlı cep
///     telefonuna (yoksa e-postasına) 6 haneli tek kullanımlık kod. Kod BCRYPT
///     ile saklanır (parola_sifirlama), düz hali yalnız mesajda. Hesap
///     bulunamazsa / iletişim bilgisi yoksa da AYNI genel cevap döner - kullanıcı
///     adının varlığı dışarı sızmaz; ayrıntı yalnız giriş günlüğüne yazılır.
///  2. <see cref="DogrulaAsync"/>: kod + yeni parola → parola yazılır, açık
///     oturumlar kapanır (eski oturum açık kalsa sıfırlama bir şey korumazdı).
///
/// Kural: kod 10 dk geçerli; 5 yanlış denemede iptal; 15 dk'da en çok 3 istek.
///
/// <para><b>İLK PAROLA da bu kapıdan geçer</b> (denetim 28.09.2026 #5):
/// parolası hiç tanımlanmamış hesapta kimlik kanıtı yalnız TCKN'nin son dört
/// hanesiydi, sayaç ve kilit yoktu - kullanıcı kodunu bilen biri 10.000
/// ihtimali deneyip başkasının parolasını belirleyebilirdi. Artık TCKN son 4
/// yalnız KOD GÖNDERMENİN ön koşulu; parolayı belirleyen, kayıtlı kanala giden
/// süreli, tek kullanımlık koddur. Kayıtlı iletişim kanalı olmayan hesap bu
/// yoldan açılamaz: yönetici hesabı "Personel hesapları" ile zorunlu parola
/// değişimli varsayılan parolaya çeker (sunucu, parola değişene kadar iş
/// uçlarını kapatır - OturumKapisi).</para>
///
/// <para><b>Deneme sınırı iki eksende:</b> hesap (yanlış TCKN ve yanlış kod
/// normal girişin hatalı-giriş sayacını ve kilidini işletir) ve istemci IP'si
/// (15 dk'da en çok <see cref="EnCokIpHatasi"/> başarısız anonim parola
/// denemesi). IP, proxy arkasında yalnız GÜVENİLEN proxy'nin eklediği
/// X-Forwarded-For'dan çözülür (Program.cs); istemcinin yazdığı başlığa
/// güvenilmez.</para>
///
/// <para><b>Kod tek kullanımlık ve atomik:</b> kod satırı işlem içinde
/// kilitlenerek tüketilir; aynı kodla eşzamanlı iki istek iki ayrı başarı
/// üretemez. Parola yazılamazsa kod da tüketilmez (rollback).</para>
/// </summary>
public sealed class ParolaSifirlamaServisi(
    KullaniciDeposu kullanicilar, GunlukDeposu gunluk,
    VeriKaynagi veri, BildirimDeposu bildirim, YetkiCozucu yetkiCozucu)
{
    private const int GecerlilikDk = 10;
    private const int EnCokDeneme = 5;
    private const int EnCokIstek15Dk = 3;
    /// <summary>Bir IP'den 15 dk'da en çok bu kadar BAŞARISIZ anonim parola denemesi.</summary>
    public const int EnCokIpHatasi = 20;

    /// <summary>IP sınırının saydığı başarısız denemeler (giris_denemesi.sebep).</summary>
    private static readonly string[] AnonimParolaSebepleri =
    [
        "ilk_parola", "ilk_parola_tckn", "ilk_parola_kod", "ilk_parola_dogrula",
        "parola_unuttum_dogrula", "parola_unuttum_hesap_yok",
    ];

    public const string GenelMesaj = "Hesap bulunursa kayıtlı telefon / e-posta adresine doğrulama kodu gönderilir.";

    public const string IlkParolaGenelMesaj =
        "Bilgiler doğruysa kayıtlı telefon / e-posta adresinize doğrulama kodu gönderilir.";

    public sealed record GonderimSonucu(bool Gonderildi, string Kanal, string Hedef, int Dakika);

    public async Task<GonderimSonucu> KodGonderAsync(string? kod, string ip, string istemci, CancellationToken iptal)
    {
        await IpSiniriIsteAsync(ip, iptal);
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        if (kullanici is null || !kullanici.Aktif)
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "parola_unuttum_hesap_yok", iptal);
            return new GonderimSonucu(false, "", "", GecerlilikDk);
        }
        return await KodUretVeGonderAsync(kullanici, kullaniciKodu, "parola_unuttum", ip, istemci, iptal);
    }

    /// <summary>
    /// İLK PAROLA — 1. adım: TCKN son 4 doğruysa kayıtlı kanala kod gönderir.
    /// Cevap HER DURUMDA aynıdır (hesap yok / parolası zaten var / TCKN yanlış /
    /// kanal yok / kilitli / istek sınırı): dışarıya bilgi sızmaz, ayrıntı yalnız
    /// giriş günlüğündedir. Yanlış TCKN hesabın hatalı-giriş sayacını işletir.
    /// </summary>
    public async Task IlkParolaKodGonderAsync(string? kod, string? tcknSon4, string ip,
                                              string istemci, CancellationToken iptal)
    {
        await IpSiniriIsteAsync(ip, iptal);
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        if (kullanici is null || !kullanici.Aktif || kullanici.ParolaHash.Length > 0 || Kilitli(kullanici))
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "ilk_parola", iptal);
            return;
        }

        var tckn = (await kullanicilar.TcknAsync(kullanici.TarafId, iptal) ?? "").Trim();
        var son4 = (tcknSon4 ?? "").Trim();
        if (tckn.Length < 4 || son4.Length != 4 || !tckn.EndsWith(son4, StringComparison.Ordinal))
        {
            await kullanicilar.HataliGirisAsync(kullanici.TarafId, iptal);
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "ilk_parola_tckn", iptal);
            return;
        }

        try
        {
            await KodUretVeGonderAsync(kullanici, kullaniciKodu, "ilk_parola", ip, istemci, iptal);
        }
        catch (GentegreHatasi)
        {
            // İstek sınırı / gönderim hatası da genel cevaba döner: ayrı bir hata
            //   metni "bu hesap var ve kodu gönderilemedi" demiş olurdu.
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "ilk_parola_kod", iptal);
        }
    }

    /// <summary>
    /// İLK PAROLA — 2. adım: kod + yeni parola. Yalnız parolası HÂLÂ BOŞ olan
    /// hesapta çalışır (koşullu UPDATE); kod ve parola aynı işlemde yazılır.
    /// </summary>
    public async Task IlkParolaBelirleAsync(string? kod, string? dogrulamaKodu, string? yeniParola,
                                            string ip, string istemci, CancellationToken iptal)
    {
        await IpSiniriIsteAsync(ip, iptal);
        const string ortakHata = "Kod hatalı ya da süresi dolmuş.";
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var girilen = Rakamlar(dogrulamaKodu);
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        if (kullanici is null || !kullanici.Aktif || kullanici.ParolaHash.Length > 0
            || girilen.Length != 6 || Kilitli(kullanici))
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "ilk_parola_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }

        await ParolaKuraliIsteAsync(yeniParola, iptal);

        if (!await KodTuketVeParolaYazAsync(kullanici.TarafId, girilen, yeniParola!,
                                            yalnizBosParola: true, "ilk_parola", iptal))
        {
            await kullanicilar.HataliGirisAsync(kullanici.TarafId, iptal);
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "ilk_parola_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }
        yetkiCozucu.Temizle(kullanici.TarafId);
        await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, true, "ilk_parola", iptal);
    }

    public async Task DogrulaAsync(string? kod, string? dogrulamaKodu, string? yeniParola, string ip, string istemci, CancellationToken iptal)
    {
        await IpSiniriIsteAsync(ip, iptal);
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var girilen = Rakamlar(dogrulamaKodu);
        const string ortakHata = "Kod hatalı ya da süresi dolmuş.";
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        if (kullanici is null || !kullanici.Aktif || girilen.Length != 6)
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "parola_unuttum_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }

        await ParolaKuraliIsteAsync(yeniParola, iptal);

        if (!await KodTuketVeParolaYazAsync(kullanici.TarafId, girilen, yeniParola!,
                                            yalnizBosParola: false, "parola_unuttum", iptal))
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "parola_unuttum_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }
        yetkiCozucu.Temizle(kullanici.TarafId);
        await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, true, "parola_unuttum", iptal);
    }

    /// <summary>Kod üretir, kuyruğa koyar ve hash'iyle saklar. Hesap başına 15 dk'da en çok 3.</summary>
    private async Task<GonderimSonucu> KodUretVeGonderAsync(KullaniciKaydi kullanici, string kullaniciKodu,
        string sebepOnEki, string ip, string istemci, CancellationToken iptal)
    {
        var yok = new GonderimSonucu(false, "", "", GecerlilikDk);
        await using var b = await veri.AcAsync(iptal);
        var sonIstek = await b.TekDegerAsync<long>(
            "select count(*) from public.parola_sifirlama where kullanici_id = @p0 and ekleme_tarihi > now() - interval '15 minutes'",
            null, [kullanici.TarafId], iptal);
        if (sonIstek >= EnCokIstek15Dk)
            throw GentegreHatasi.IsKurali("Kısa sürede çok fazla istek yapıldı. 15 dakika sonra yeniden deneyin.");

        // İletişim (kullanıcı: "cep telefonu esas al"): parola sıfırlama SMS'i
        //   KİŞİ KARTINDAKİ cep telefonunu ESAS alır - o kişinin kayıtlı asıl
        //   mobili odur; hesabın "Hesabım" alanı boş ya da yer-tutucu (0500…)
        //   olabilir ve kod yanlış numaraya giderdi. Kişi kartı boşsa hesabın
        //   kendi alanına düşer. E-posta yine önce hesabın kendi adresi.
        var iletisim = await b.TekAsync("""
            select coalesce(nullif(t.cep_tel, ''), nullif(k.cep_tel, ''), ''), coalesce(nullif(k.eposta, ''), t.eposta, ''),
                   coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '')
              from public.taraf_kullanici k join public.taraf t on t.id = k.id where k.id = @p0
            """, null, [kullanici.TarafId], o => new { tel = o.GetString(0), eposta = o.GetString(1), ad = o.GetString(2) }, iptal);
        var tel = Rakamlar(iletisim?.tel);
        var eposta = (iletisim?.eposta ?? "").Trim();
        BildirimKanali kanal; string hedef;
        if (tel.Length >= 10) { kanal = BildirimKanali.Sms; hedef = iletisim!.tel.Trim(); }
        else if (eposta.Contains('@')) { kanal = BildirimKanali.Eposta; hedef = eposta; }
        else
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, sebepOnEki + "_iletisim_yok", iptal);
            return yok;
        }

        var dogrulamaKodu = RandomNumberGenerator.GetInt32(100000, 1000000).ToString();
        var kurum = await b.TekDegerAsync<string>("select ad from public.sube order by id limit 1", null, [], iptal) ?? "GenoTIP";
        try
        {
            await bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                kanal == BildirimKanali.Sms ? "kimlik.parola_sifirlama" : "kimlik.parola_sifirlama.eposta", kanal, hedef,
                new Dictionary<string, string> { ["kurum"] = kurum, ["kod"] = dogrulamaKodu, ["dakika"] = GecerlilikDk.ToString(), ["kisi"] = iletisim!.ad },
                TarafId: kullanici.TarafId, KaynakTur: 43, KaynakId: kullanici.TarafId, Oncelik: 1), kullanici.TarafId, null, iptal);
        }
        catch (InvalidOperationException h)
        {
            throw GentegreHatasi.IsKurali("Doğrulama kodu gönderilemedi: " + h.Message);
        }

        await b.CalistirAsync("""
            insert into public.parola_sifirlama (kullanici_id, kod_hash, kanal, hedef, bitis, ip)
            values (@p0, @p1, @p2, @p3, now() + make_interval(mins => @p4), @p5)
            """, null, [kullanici.TarafId, BCrypt.Net.BCrypt.HashPassword(dogrulamaKodu, workFactor: 10), (short)kanal, hedef, GecerlilikDk, ip], iptal);
        await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, true, sebepOnEki + "_kod", iptal);
        return new GonderimSonucu(true, kanal == BildirimKanali.Sms ? "sms" : "eposta", Maskele(hedef, kanal), GecerlilikDk);
    }

    /// <summary>
    /// KOD TÜKETİMİ + PAROLA TEK İŞLEMDE. Son geçerli kod satırı KİLİTLENİR
    /// (FOR UPDATE): aynı kodla eşzamanlı ikinci istek birincinin commit'ini
    /// bekler, sonra satırı kullanılmış görür ve başarısız olur. Yanlış kod
    /// deneme sayacını (commit edilerek) artırır; 5. yanlışta kod ölür.
    /// <paramref name="yalnizBosParola"/>: ilk parola - parola arada
    /// tanımlanmışsa hiçbir şey yazılmaz, kod da tüketilmez.
    /// </summary>
    private async Task<bool> KodTuketVeParolaYazAsync(int kullaniciId, string girilen, string yeniParola,
        bool yalnizBosParola, string neden, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        await using var islem = await b.BeginTransactionAsync(iptal);
        var satir = await b.TekAsync("""
            select id, kod_hash, deneme from public.parola_sifirlama
             where kullanici_id = @p0 and kullanildi is null and bitis > now()
             order by id desc limit 1
               for update
            """, islem, [kullaniciId], o => new { id = o.GetInt64(0), hash = o.GetString(1), deneme = o.GetInt16(2) }, iptal);
        if (satir is null) return false;

        if (satir.deneme >= EnCokDeneme || !BCrypt.Net.BCrypt.Verify(girilen, satir.hash))
        {
            await b.CalistirAsync("update public.parola_sifirlama set deneme = deneme + 1 where id = @p0",
                                  islem, [satir.id], iptal);
            await islem.CommitAsync(iptal);
            return false;
        }

        var yazilan = await b.CalistirAsync(
            "update public.taraf_kullanici " +
            "   set parola_hash = @p1, parola_algo = 'bcrypt', " +
            "       parola_tarihi = now()::timestamp, parola_degismeli = 0, " +
            "       hatali_giris = 0, kilit_bitis = null " +
            " where id = @p0 and aktif = 1" + (yalnizBosParola ? " and parola_hash = ''" : ""),
            islem, [kullaniciId, BCrypt.Net.BCrypt.HashPassword(yeniParola, workFactor: 12)], iptal);
        if (yazilan != 1) return false;   // rollback: kod tüketilmez

        await b.CalistirAsync("update public.parola_sifirlama set kullanildi = now() where id = @p0",
                              islem, [satir.id], iptal);
        // Parola değişince açık oturumlar kapanır - AYNI işlemde.
        await OturumDeposu.KullaniciOturumlariniKapatAsync(b, islem, kullaniciId, neden, iptal);
        await islem.CommitAsync(iptal);
        return true;
    }

    private async Task ParolaKuraliIsteAsync(string? yeniParola, CancellationToken iptal)
    {
        var enAzMetin = await veri.TekDegerAsync<string>(
            "select deger from public.referans where anahtar = 'guvenlik.parola_min_uzunluk'", [], iptal);
        var enAz = int.TryParse(enAzMetin, out var e) && e > 0 ? e : ParolaKurali.VarsayilanEnAz;
        ParolaKurali.Dogrula(yeniParola ?? "", enAz);
    }

    /// <summary>
    /// İSTEMCİ SINIRI: bu IP'den son 15 dk'daki başarısız anonim parola
    /// denemeleri eşiği geçtiyse istek işlenmez. IP çözülemediyse sınır
    /// uygulanamaz - hesap sayacı yine çalışır.
    /// </summary>
    private async Task IpSiniriIsteAsync(string ip, CancellationToken iptal)
    {
        if (string.IsNullOrEmpty(ip)) return;
        var hata = await veri.TekDegerAsync<long>("""
            select count(*) from public.giris_denemesi
             where ip = @p0 and basarili = 0 and tarih > now() - interval '15 minutes'
               and sebep = any(@p1)
            """, [ip, AnonimParolaSebepleri], iptal);
        if (hata >= EnCokIpHatasi)
            throw GentegreHatasi.IsKurali("Çok fazla başarısız deneme yapıldı. 15 dakika sonra yeniden deneyin.");
    }

    private static bool Kilitli(KullaniciKaydi k) => k.KilitBitis is { } kilit && kilit > Saat.An;

    private static string Rakamlar(string? s) => new((s ?? "").Where(char.IsDigit).ToArray());

    /// <summary>Hedef maskelenir: "05•• ••• •• 05" / "b•••@ornek.com" - kanal doğrulanır, bilgi sızmaz.</summary>
    private static string Maskele(string hedef, BildirimKanali kanal)
    {
        if (kanal == BildirimKanali.Sms)
        {
            var d = Rakamlar(hedef);
            d = d.Length > 10 ? d[^10..] : d;
            if (d.Length < 4) return "•••";
            return "0" + d[..1] + "•• ••• •• " + d[^2..];
        }
        var at = hedef.IndexOf('@');
        return at <= 0 ? "•••" : hedef[..1] + "•••" + hedef[at..];
    }
}
