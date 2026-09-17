using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// ONAY MOTORU (738) — modülden bağımsız onay zinciri.
///
/// ============ NEDEN TEK MOTOR ========================================
/// Satınalma talebi, izin, avans, masraflı onarım: hepsinin sorduğu soru
/// aynı - "bu kaydı kim, hangi sırayla imzalayacak". Ayrı ayrı yazılsaydı
/// vekâlet, süre aşımı, ret dalı, bilgi isteme ve gelen kutusu her modülde
/// yeniden yazılır, biri düzeltilince ötekiler eski hâliyle kalırdı.
///
/// ============ KAYNAK BAĞI ============================================
/// Onay bir kayda `kaynak_tur` + `kaynak_id` ile bağlanır; `kaynak_tur`
/// kurumun zaten kullandığı `islem_log.tablo_id`dir (satınalma talebi 1241).
/// İkinci bir numaralandırma, aynı tabloyu iki ayrı adla anmak olurdu.
///
/// ============ MOTOR KARAR VERMEZ, SIRAYI YÜRÜTÜR =====================
/// "Bu talep onaylanmalı mı" sorusu motorun işi değil. Motor yalnız hangi
/// basamağın açık olduğunu, kimin imzalayabileceğini ve sıranın nereye
/// gittiğini bilir. Kaydın kendi durumunu (talep "onayda" mı "onaylandı" mı)
/// çağıran modül yazar - onu da motor yazsaydı her yeni tür için motorun
/// içine bir `switch` eklenirdi.
/// </summary>
public sealed class OnayMotoru
{
    private readonly VeriKaynagi _veri;

    public OnayMotoru(VeriKaynagi veri) => _veri = veri;

    /// <summary>onay_adim.durum</summary>
    public const short Bekliyor = 0, Onaylandi = 1, Reddedildi = 2,
                       BilgiIstendi = 3, SozluOnay = 4, Atlandi = 5;

    /// <summary>onay.durum</summary>
    public const short ZincirYuruyor = 0, ZincirOnaylandi = 1,
                       ZincirReddedildi = 2, ZincirIptal = 3;

    public sealed record AdimOzeti(long Id, short Sira, string Ad, short Rol,
                                   int? AtananKullaniciId, short Durum);

    public sealed record ZincirSonucu(long OnayId, IReadOnlyList<AdimOzeti> Adimlar,
                                      short? BekleyenSira);

    // ==================================================== zincir kurulumu ==

    /// <summary>
    /// Kayıt için zinciri kurar ve onayı başlatır.
    ///
    /// KARAR VERİLMİŞ BASAMAK KORUNUR: zincir yeniden kurulduğunda (tutar
    /// değişti, akış güncellendi) atılmış imzalar silinmez - yoksa "onaylamış
    /// mıydım" sorusunun cevabı kaybolur ve aynı kişiye ikinci kez sorulur.
    /// </summary>
    /// <param name="bayraklar">
    /// Sayıya sığmayan koşullar ("butce", "butce_asildi"). Adım tanımındaki
    /// `bayrak` bu kümedeyse basamak eklenir.
    /// </param>
    /// <param name="sahipTarafId">
    /// Kaydın SAHİBİ (izin talebinde personelin `taraf` id'si). Âmir
    /// basamağı (`sahip_turu = 3`) bundan çözülür: âmir bir rol değil,
    /// KİŞİYE bağlı bir bağdır (`taraf_personel.yonetici_taraf_id`).
    /// Verilmezse âmir basamağı kimseye atanmaz ve rol basamağı gibi
    /// davranır - sessizce atlamak, onay zincirinden bir imzayı düşürmek
    /// olurdu.
    /// </param>
    public async Task<ZincirSonucu> BaslatAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        string akisKodu, long kaynakId, decimal olcu,
        IEnumerable<string> bayraklar, IstekBaglami baglam,
        CancellationToken iptal = default, int? sahipTarafId = null)
    {
        var bayrakMetni = string.Join(",", bayraklar.Where(b => !string.IsNullOrWhiteSpace(b)));

        var akis = await baglanti.TekAsync("""
            select k.id, k.kaynak_tur as "kaynakTur", k.ad
              from public.onay_akis k where k.kod = @p0 and k.aktif = 1
            """, islem, [akisKodu], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.IsKurali(
                $"Onay akışı tanımlı değil: {akisKodu}. Onay Akışları ekranından tanımlayın.");

        var akisId = Convert.ToInt32(akis["id"]);
        var kaynakTur = Convert.ToInt32(akis["kaynakTur"]);

        // AÇIK ZİNCİR VARSA ONU SÜRDÜRÜRÜZ: ikinci bir zincir açmak, aynı
        //   kaydı iki ayrı imza dizisiyle farklı sonuçlara götürürdü
        //   (benzersiz indeks de reddeder).
        var onayId = await baglanti.TekDegerAsync<long?>("""
            select id from public.onay
             where kaynak_tur = @p0 and kaynak_id = @p1 and durum = 0
            """, islem, [kaynakTur, kaynakId], iptal);

        if (onayId is null)
            onayId = await baglanti.TekDegerAsync<long>("""
                insert into public.onay (akis_id, kaynak_tur, kaynak_id, sube_id,
                                         olcu, bayraklar, durum, baslatan_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 0, @p6, @p6)
                returning id
                """, islem,
                [akisId, kaynakTur, kaynakId, baglam.SubeId ?? 0, olcu, bayrakMetni,
                 baglam.KullaniciId], iptal);
        else
            await baglanti.CalistirAsync("""
                update public.onay set olcu = @p1, bayraklar = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [onayId, olcu, bayrakMetni, baglam.KullaniciId], iptal);

        // KARAR VERİLMEMİŞ basamaklar silinir, karar verilmiş olan durur.
        await baglanti.CalistirAsync(
            "delete from public.onay_adim where onay_id = @p0 and durum = 0",
            islem, [onayId], iptal);

        var secilen = await SecilenAdimlarAsync(baglanti, islem, akisId, olcu,
            bayrakMetni, iptal);

        var mevcut = await baglanti.ListeAsync<short>(
            "select sira from public.onay_adim where onay_id = @p0",
            islem, [onayId], o => o.GetInt16(0), iptal);

        // ÂMİR BİR KEZ ÇÖZÜLÜR: zincir kurulurken kim âmirse o basamağa
        //   yazılır. Her karar anında yeniden sorsaydık, personelin âmiri
        //   izin sürerken değiştiğinde basamak el değiştirir ve "bu bana ne
        //   zaman düştü" sorusunun cevabı kalmazdı.
        //   ÂMİRİN KULLANICI HESABI ŞART: `yonetici_taraf_id` bir TARAF'tır,
        //   imzayı atacak olan ise bir KULLANICIDIR. İkisinin id'si aynı
        //   uzayda (taraf_kullanici.id -> taraf.id) ama her âmirin hesabı
        //   olmayabilir. Hesabı yokken basamağı yine de yazsaydık,
        //   `atanan_kullanici_id` hiçbir kullanıcıya denk gelmez (kolonda FK
        //   de yok), basamak kimsenin kutusuna düşmez ve talep sessizce
        //   sonsuza kadar "onayda" kalırdı. Bu yüzden ÇÖZÜLEMEDİĞİNDE
        //   ZİNCİR HİÇ KURULMAZ - talep sahibi hatayı gönderirken görür.
        int? amirId = null;
        if (sahipTarafId is not null && secilen.Any(a => a.SahipTuru == 3))
        {
            amirId = await baglanti.TekDegerAsync<int?>("""
                select k.id
                  from public.taraf_personel p
                  join public.taraf_kullanici k on k.id = p.yonetici_taraf_id
                                               and k.aktif = 1
                 where p.id = @p0
                """, islem, [sahipTarafId.Value], iptal);

            if (amirId is null)
                throw GentegreHatasi.IsKurali(
                    "Bu personelin âmiri tanımlı değil ya da âmirin aktif bir "
                    + "kullanıcı hesabı yok; onay zinciri kurulamaz. İnsan "
                    + "Kaynakları personel kartından âmiri tanımlamalı.");
        }

        foreach (var a in secilen)
        {
            if (mevcut.Contains(a.Sira)) continue;

            var atanan = a.SahipTuru == 3 ? amirId : a.KullaniciId;

            await baglanti.CalistirAsync("""
                insert into public.onay_adim (onay_id, sira, ad, sahip_turu, rol,
                                              atanan_kullanici_id, durum, termin, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, 0,
                        case when @p6 > 0 then now() + (@p6 || ' days')::interval end, @p7)
                """, islem,
                [onayId, a.Sira, a.Ad, a.SahipTuru, a.Rol, atanan,
                 a.SureGun, baglam.KullaniciId], iptal);
        }

        return await DurumAsync(baglanti, islem, onayId.Value, iptal);
    }

    /// <summary>Akış tanımından seçilen basamak (henüz yazılmamış).</summary>
    public sealed record SecilenAdim(short Sira, string Ad, short SahipTuru, short Rol,
                                     int? KullaniciId, short SureGun, decimal? EsikAlt,
                                     string Bayrak, short KararTuru, short EImza);

    /// <summary>
    /// ÖLÇÜ VE BAYRAKLARA GÖRE HANGİ BASAMAKLAR ÇIKAR.
    ///
    /// Zincir kurma ile "akışı dene" ekranı AYNI metottan geçer: ikisi ayrı
    /// yazılsaydı deneme ekranı, gerçekte kurulacak zincirden başka bir şey
    /// gösterebilirdi - ve kimse farkı görmeden akışı yanlış kurardı.
    ///
    /// SIRA BURADA YENİDEN NUMARALANIR: tanımdaki altı adımdan üçü seçilirse
    /// yürüyen zincir 1-2-3 olur. Tanımın sıra numarasını taşısaydık
    /// "basamak 5'teyiz ama 3 basamak var" gibi bir zincir çıkardı.
    /// </summary>
    public static async Task<List<SecilenAdim>> SecilenAdimlarAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int akisId,
        decimal olcu, string bayrakMetni, CancellationToken iptal = default)
    {
        var adimlar = await baglanti.ListeAsync("""
            select a.sira, a.ad, a.sahip_turu as "sahipTuru", a.rol,
                   a.kullanici_id as "kullaniciId", a.esik_alt as "esikAlt",
                   a.bayrak, a.sure_gun as "sureGun",
                   a.karar_turu as "kararTuru", a.e_imza_zorunlu as "eImza"
              from public.onay_akis_adim a
             where a.akis_id = @p0 and a.aktif = 1
             order by a.sira
            """, islem, [akisId], OkuyucuGenisletmeleri.Sozluk, iptal);

        var bayrakKume = bayrakMetni.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                    .Select(x => x.Trim())
                                    .ToHashSet(StringComparer.OrdinalIgnoreCase);

        var sonuc = new List<SecilenAdim>();
        short sira = 0;
        foreach (var a in adimlar)
        {
            var bayrak = (a["bayrak"] as string ?? "").Trim();
            var esik = a["esikAlt"] as decimal?;

            // KOŞUL: eşik verilmişse ölçü onu geçmeli; bayrak verilmişse
            //   çağıran o bayrağı bildirmeli. İkisi de boşsa adım her zaman.
            if (bayrak.Length > 0 && !bayrakKume.Contains(bayrak)) continue;
            if (esik is not null && olcu < esik.Value) continue;

            sonuc.Add(new SecilenAdim(++sira, a["ad"] as string ?? "",
                Convert.ToInt16(a["sahipTuru"] ?? (short)1),
                Convert.ToInt16(a["rol"] ?? (short)0), a["kullaniciId"] as int?,
                Convert.ToInt16(a["sureGun"] ?? (short)0), esik, bayrak,
                Convert.ToInt16(a["kararTuru"] ?? (short)0),
                Convert.ToInt16(a["eImza"] ?? (short)0)));
        }
        return sonuc;
    }

    // =========================================================== karar ==

    public sealed record KararSonucu(long OnayId, short Sira, short Rol, short AdimDurum,
                                     short ZincirDurum, short? SonrakiSira,
                                     DateTime? YaziliSon, string AdimAd);

    /// <summary>
    /// Bekleyen basamağa karar yazar ve sırayı ilerletir.
    ///
    /// RET ZİNCİRİ BİTİRİR: bekleyen basamaklar da kapanır, yoksa reddedilmiş
    /// bir kayıt listede hâlâ "onayda" görünürdü.
    /// BİLGİ İSTENDİ zinciri DURDURUR ama bitirmez - basamak hâlâ bekleyendir.
    /// </summary>
    public async Task<KararSonucu> KararAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        int kaynakTur, long kaynakId, short karar, string? gerekce,
        IstekBaglami baglam, decimal yaziliSaat = 24,
        CancellationToken iptal = default)
    {
        if (karar is Reddedildi or BilgiIstendi && string.IsNullOrWhiteSpace(gerekce))
            throw GentegreHatasi.Dogrulama("Gerekçe zorunlu.",
                new AlanHatasi("gerekce", "Ret ve bilgi isteğinde gerekçe zorunlu."));

        var n = await baglanti.TekAsync("""
            select o.id, o.durum,
                   (select min(a.sira) from public.onay_adim a
                     where a.onay_id = o.id and a.durum in (0, 3)) as "bekleyen"
              from public.onay o
             where o.kaynak_tur = @p0 and o.kaynak_id = @p1 and o.durum = 0
            """, islem, [kaynakTur, kaynakId], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.IsKurali("Bu kayıtta yürüyen onay zinciri yok.");

        if (n["bekleyen"] is null)
            throw GentegreHatasi.IsKurali("Bekleyen onay basamağı yok.");

        var onayId = Convert.ToInt64(n["id"]);
        var sira = Convert.ToInt16(n["bekleyen"]);

        var a = await baglanti.TekAsync("""
            select a.id, a.rol, a.ad, a.sahip_turu as "sahipTuru",
                   a.atanan_kullanici_id as "atananId"
              from public.onay_adim a where a.onay_id = @p0 and a.sira = @p1
            """, islem, [onayId, sira], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Onay basamağı bulunamadı.");

        var rol = Convert.ToInt16(a["rol"] ?? (short)0);
        var atananId = a["atananId"] as int?;

        // KİŞİYE DÜŞEN BASAMAĞI BAŞKASI İMZALAYAMAZ - vekâleti yoksa.
        //   Rol basamağının yetkisi çağıran modülde sorulur (rol kodları
        //   modülün kendi aksiyon yetkileridir; motor onları bilmez).
        if (atananId is not null && atananId != baglam.KullaniciId
            && !await VekaletVarMiAsync(baglanti, islem, atananId.Value, baglam.KullaniciId, iptal))
            throw GentegreHatasi.IsKurali(
                "Bu basamak başka bir kullanıcıya atanmış; vekâletiniz yok.");

        var simdi = DateTime.Now;

        await baglanti.CalistirAsync("""
            update public.onay_adim
               set durum = @p2, karar_veren_id = @p3, karar_zamani = @p4,
                   gerekce = coalesce(nullif(@p5, ''), gerekce),
                   yazili_son = case when @p2 = 4 then @p4 + (@p6 || ' hours')::interval
                                     else yazili_son end,
                   degistiren = @p3, degistirme_tarihi = now()
             where onay_id = @p0 and sira = @p1
            """, islem,
            [onayId, sira, karar, baglam.KullaniciId, simdi, gerekce ?? "",
             ((int)yaziliSaat).ToString()], iptal);

        short zincirDurum;
        short? sonraki = null;

        if (karar == Reddedildi)
        {
            await baglanti.CalistirAsync("""
                update public.onay_adim set durum = 5, karar_zamani = @p1,
                       gerekce = 'Zincir reddedilerek kapandı'
                 where onay_id = @p0 and durum = 0
                """, islem, [onayId, simdi], iptal);
            zincirDurum = ZincirReddedildi;
        }
        else if (karar == BilgiIstendi)
        {
            zincirDurum = ZincirYuruyor;
        }
        else
        {
            sonraki = await baglanti.TekDegerAsync<short?>("""
                select min(sira) from public.onay_adim
                 where onay_id = @p0 and durum in (0, 3)
                """, islem, [onayId], iptal);
            zincirDurum = sonraki is null ? ZincirOnaylandi : ZincirYuruyor;
        }

        if (zincirDurum != ZincirYuruyor)
            await baglanti.CalistirAsync("""
                update public.onay set durum = @p1, bitis = @p2,
                       degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [onayId, zincirDurum, simdi, baglam.KullaniciId], iptal);

        return new KararSonucu(onayId, sira, rol, karar, zincirDurum, sonraki,
            karar == SozluOnay ? simdi.AddHours((double)yaziliSaat) : null,
            a["ad"] as string ?? "");
    }

    // ========================================================== okuma ==

    public async Task<ZincirSonucu> DurumAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, long onayId,
        CancellationToken iptal = default)
    {
        var adimlar = await baglanti.ListeAsync("""
            select a.id, a.sira, a.ad, a.rol,
                   a.atanan_kullanici_id as "atananId", a.durum
              from public.onay_adim a where a.onay_id = @p0 order by a.sira
            """, islem, [onayId], OkuyucuGenisletmeleri.Sozluk, iptal);

        var liste = adimlar.Select(a => new AdimOzeti(
            Convert.ToInt64(a["id"]), Convert.ToInt16(a["sira"]), a["ad"] as string ?? "",
            Convert.ToInt16(a["rol"] ?? (short)0), a["atananId"] as int?,
            Convert.ToInt16(a["durum"] ?? (short)0))).ToList();

        return new ZincirSonucu(onayId, liste,
            liste.FirstOrDefault(x => x.Durum is Bekliyor or BilgiIstendi)?.Sira);
    }

    /// <summary>Kaydın yürüyen zinciri (yoksa null).</summary>
    public static async Task<long?> AcikOnayIdAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        int kaynakTur, long kaynakId, CancellationToken iptal = default)
        => await baglanti.TekDegerAsync<long?>("""
            select id from public.onay
             where kaynak_tur = @p0 and kaynak_id = @p1 and durum = 0
            """, islem, [kaynakTur, kaynakId], iptal);

    /// <summary>
    /// VEKÂLET: devredilen imza DEVRALANIN adıyla atılır - kimin imzaladığı
    /// kaybolmaz. Tarih aralığı bugünü kapsamalı.
    /// </summary>
    private static async Task<bool> VekaletVarMiAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        int devredenId, int devralanId, CancellationToken iptal)
        => await baglanti.TekDegerAsync<int>("""
            select count(*) from public.onay_vekalet
             where devreden_id = @p0 and devralan_id = @p1 and aktif = 1
               and current_date between baslangic and bitis
            """, islem, [devredenId, devralanId], iptal) > 0;
}
