using System.Security.Cryptography;
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
/// İlk-parola akışı (parolası hiç tanımlanmamış hesap) ayrı kalır: orada kimlik
/// kanıtı TCKN son 4, burada kayıtlı iletişim kanalı.
/// </summary>
public sealed class ParolaSifirlamaServisi(
    KullaniciDeposu kullanicilar, OturumDeposu oturumlar, GunlukDeposu gunluk,
    VeriKaynagi veri, BildirimDeposu bildirim, YetkiCozucu yetkiCozucu)
{
    private const int GecerlilikDk = 10;
    private const int EnCokDeneme = 5;
    private const int EnCokIstek15Dk = 3;

    public const string GenelMesaj = "Hesap bulunursa kayıtlı telefon / e-posta adresine doğrulama kodu gönderilir.";

    public sealed record GonderimSonucu(bool Gonderildi, string Kanal, string Hedef, int Dakika);

    public async Task<GonderimSonucu> KodGonderAsync(string? kod, string ip, string istemci, CancellationToken iptal)
    {
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        var yok = new GonderimSonucu(false, "", "", GecerlilikDk);
        if (kullanici is null || !kullanici.Aktif)
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "parola_unuttum_hesap_yok", iptal);
            return yok;
        }

        await using var b = await veri.AcAsync(iptal);
        var sonIstek = await b.TekDegerAsync<long>(
            "select count(*) from public.parola_sifirlama where kullanici_id = @p0 and ekleme_tarihi > now() - interval '15 minutes'",
            null, [kullanici.TarafId], iptal);
        if (sonIstek >= EnCokIstek15Dk)
            throw GentegreHatasi.IsKurali("Kısa sürede çok fazla istek yapıldı. 15 dakika sonra yeniden deneyin.");

        // İletişim: önce hesabın kendi alanları, yoksa kişi kartı.
        var iletisim = await b.TekAsync("""
            select coalesce(nullif(k.cep_tel, ''), t.cep_tel, ''), coalesce(nullif(k.eposta, ''), t.eposta, ''),
                   coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, '')
              from public.taraf_kullanici k join public.taraf t on t.id = k.id where k.id = @p0
            """, null, [kullanici.TarafId], o => new { tel = o.GetString(0), eposta = o.GetString(1), ad = o.GetString(2) }, iptal);
        var tel = Rakamlar(iletisim?.tel);
        var eposta = (iletisim?.eposta ?? "").Trim();
        BildirimKanali kanal; string hedef;
        if (tel.Length >= 10) { kanal = BildirimKanali.Sms; hedef = iletisim!.tel.Trim(); }
        else if (eposta.Contains('@')) { kanal = BildirimKanali.Eposta; hedef = eposta; }
        else
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "parola_unuttum_iletisim_yok", iptal);
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
        await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, true, "parola_unuttum_kod", iptal);
        return new GonderimSonucu(true, kanal == BildirimKanali.Sms ? "sms" : "eposta", Maskele(hedef, kanal), GecerlilikDk);
    }

    public async Task DogrulaAsync(string? kod, string? dogrulamaKodu, string? yeniParola, string ip, string istemci, CancellationToken iptal)
    {
        var kullaniciKodu = (kod ?? "").Trim().ToLowerInvariant();
        var girilen = Rakamlar(dogrulamaKodu);
        const string ortakHata = "Kod hatalı ya da süresi dolmuş.";
        var (kullanici, _) = kullaniciKodu.Length > 0 ? await kullanicilar.EsnekBulAsync(kullaniciKodu, iptal) : (null, false);
        if (kullanici is null || !kullanici.Aktif || girilen.Length != 6)
        {
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici?.TarafId, ip, istemci, false, "parola_unuttum_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }

        await using var b = await veri.AcAsync(iptal);
        var satir = await b.TekAsync("""
            select id, kod_hash, deneme from public.parola_sifirlama
             where kullanici_id = @p0 and kullanildi is null and bitis > now()
             order by id desc limit 1
            """, null, [kullanici.TarafId], o => new { id = o.GetInt64(0), hash = o.GetString(1), deneme = o.GetInt16(2) }, iptal);
        if (satir is null || satir.deneme >= EnCokDeneme || !BCrypt.Net.BCrypt.Verify(girilen, satir.hash))
        {
            if (satir is not null)
                await b.CalistirAsync("update public.parola_sifirlama set deneme = deneme + 1 where id = @p0", null, [satir.id], iptal);
            await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, false, "parola_unuttum_dogrula", iptal);
            throw GentegreHatasi.Yetkisiz(ortakHata);
        }

        var enAzMetin = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = 'guvenlik.parola_min_uzunluk'", null, [], iptal);
        var enAz = int.TryParse(enAzMetin, out var e) && e > 0 ? e : ParolaKurali.VarsayilanEnAz;
        ParolaKurali.Dogrula(yeniParola ?? "", enAz);

        await kullanicilar.ParolaAtaAsync(kullanici.TarafId, BCrypt.Net.BCrypt.HashPassword(yeniParola, workFactor: 12), degismeli: false, iptal);
        await b.CalistirAsync("update public.parola_sifirlama set kullanildi = now() where id = @p0", null, [satir.id], iptal);
        await oturumlar.KullaniciOturumlariniKapatAsync(kullanici.TarafId, "parola_unuttum", iptal);
        yetkiCozucu.Temizle(kullanici.TarafId);
        await gunluk.GirisDenemesiAsync(kullaniciKodu, kullanici.TarafId, ip, istemci, true, "parola_unuttum", iptal);
    }

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
