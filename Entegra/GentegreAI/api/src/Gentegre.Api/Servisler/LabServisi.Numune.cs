using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// LABORATUVAR — NUMUNE AKIŞI — plan, kabul / ret, istem bazında durum.
///
/// <para>Numune planı istemden TÜRETİLİR (tetkikin tüp tipi + aynı tüpe giren
/// tetkiklerin birleştirilmesi): teknisyenin kaç tüp alacağını elle
/// saymasını beklemek, eksik tüple başlayan bir güne razı olmaktı.
///
/// <para>Ret bir sonuç kadar kayıttır: nedeni kodludur ve istem durumu
/// ona göre geri alınır - "numune gelmedi" ile "numune uygunsuz" aynı
/// görünürse laboratuvarın kendi hata oranı ölçülemez.</para></para>
///
/// <para>Sınıfın kendisi ve ortak yardımcıları <c>LabServisi.cs</c>
/// içindedir (aynı partial sınıf).</para>
/// </summary>
public sealed partial class LabServisi
{
    /// <summary>
    /// Numunesi olmayan istem satirlari icin tüp planı ve barkod üretir.
    ///
    /// Kart ekranından açılan istemde (uç yerine kartla kayıt) satırlar
    /// numunesiz kalır; barkodsuz istem kan alma biriminde "hangi tüp"
    /// sorusunu cevapsız bırakır. Aynı tüp tipindekiler yine TEK barkoda
    /// bağlanır ve zaten numunesi olan satıra dokunulmaz.
    /// </summary>
    public async Task<List<string>> NumunePlaniAsync(int istemId, IstekBaglami baglam,
                                                     CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var i = await baglanti.TekAsync("""
            select taraf_id, sube_id, durum from public.lab_istem where id = @p0
            """, islem, [istemId],
            o => new { HastaId = o.GetInt32(0), SubeId = o.GetInt32(1),
                       Durum = o.GetInt16(2) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

        if (i.Durum == 9)
            throw GentegreHatasi.IsKurali("İptal edilmiş isteme numune üretilemez.");

        var satirlar = await baglanti.ListeAsync("""
            select s.id, coalesce(nullif(t.tup_tipi, 0), 1) as tup, t.numune_tipi
              from public.lab_istem_satir s
              join public.lab_tetkik t on t.id = s.tetkik_id
             where s.istem_id = @p0 and s.numune_id is null and s.durum <> 0
             order by s.sira, s.id
            """, islem, [istemId],
            o => new { Id = o.GetInt32(0), Tup = o.GetInt16(1), Numune = o.GetInt16(2) },
            iptal);

        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Numunesi olmayan tetkik yok - barkodlar zaten üretilmiş "
                + "(tetkiği olmayan satır varsa önce tetkik seçin).");

        var barkodlar = new List<string>();
        foreach (var grup in satirlar.GroupBy(x => x.Tup))
        {
            var barkod = await baglanti.TekDegerAsync<string>(
                "select public.fn_lab_barkod_uret(@p0)", islem, [i.SubeId], iptal) ?? "";
            var numuneId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_numune
                       (barkod, istem_id, hasta_id, numune_tipi, tup_tipi, durum,
                        sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6)
                returning id
                """, islem,
                [barkod, istemId, i.HastaId, grup.First().Numune, grup.Key, i.SubeId,
                 baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.lab_istem_satir set numune_id = @p0
                 where id = any(@p1)
                """, islem, [numuneId, grup.Select(x => x.Id).ToArray()], iptal);

            barkodlar.Add(barkod);
        }

        await islem.CommitAsync(iptal);
        return barkodlar;
    }

    // ================================================================= numune

    /// <summary>
    /// Numune alındı / kabul / ret.
    ///
    /// TAT KABULDE BAŞLAR: numune laboratuvara ulaşmadan süre işlemez.
    /// RET numuneyi kapatır ve istem satırlarını "tekrar bekliyor"a alır -
    /// sessizce açık bırakmak, sonuç hiç gelmeyen bir istem üretirdi.
    /// </summary>
    public async Task<string> NumuneDurumAsync(int numuneId, short yeniDurum,
        short? kalite, short? retNeden, string aciklama, IstekBaglami baglam,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var n = await baglanti.TekAsync("""
            select id, durum, barkod, istem_id from public.lab_numune
             where id = @p0 for update
            """, islem, [numuneId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1), Barkod = o.GetString(2),
                       IstemId = o.GetInt32(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Numune bulunamadı.");

        string mesaj;
        switch (yeniDurum)
        {
            case 2:   // alındı
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 2, alim_zamani = coalesce(alim_zamani, now()),
                           alan_id = coalesce(alan_id, @p1), degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId], iptal);
                mesaj = $"{n.Barkod} alındı.";
                break;

            case 3:   // kabul
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 3, kabul_zamani = now(), kabul_eden_id = @p1,
                           kalite = coalesce(@p2, kalite), ret = 0,
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId, kalite], iptal);
                // TAT hedefi kabulden itibaren: istemin en uzun hedef TAT'ı.
                await baglanti.CalistirAsync("""
                    update public.lab_istem i
                       set durum = greatest(i.durum, 2),
                           hedef_bitis = now() + make_interval(mins =>
                               coalesce((select max(case when i.oncelik = 3
                                                         then nullif(t.acil_tat_dk, 0)
                                                         else nullif(t.hedef_tat_dk, 0) end)
                                           from public.lab_istem_satir s
                                           join public.lab_tetkik t on t.id = s.tetkik_id
                                          where s.istem_id = i.id), 120))
                     where i.id = @p0
                    """, islem, [n.IstemId], iptal);
                mesaj = $"{n.Barkod} kabul edildi.";
                break;

            case 0:   // ret
                if (retNeden is null)
                    throw GentegreHatasi.Dogrulama("Ret nedeni zorunlu.",
                        [new("retNeden", "Ret nedeni seçilmeli.")]);
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 0, ret = 1, ret_neden = @p2, ret_aciklama = @p3,
                           ret_zamani = now(), kalite = coalesce(@p4, kalite),
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId, retNeden, aciklama,
                                 kalite], iptal);
                // Ret edilen numunenin tetkikleri TEKRAR BEKLIYOR: istem
                //   sessizce acik kalirsa sonuc hic gelmez.
                await baglanti.CalistirAsync("""
                    update public.lab_istem_satir set durum = 6
                     where numune_id = @p0 and durum in (1, 2)
                    """, islem, [numuneId], iptal);

                // HASTAYA e-NABIZ MESAJI (879, KTS maddesi H1 / D16).
                //   AYNI ISLEMDE yazilir: ret ile bilgilendirme ya birlikte
                //   olur ya hic - reddedilmis ama hastanin haberi olmayan
                //   numune, denetimin tam da sordugu bosluktur.
                //
                //   HANGI NEDENDE MESAJ GIDECEGI KRITERIN KENDI AYARINDA
                //   (`lab_ret_nedeni.hasta_bilgilendir`): "etiketsiz tup"
                //   kurumun kendi hatasidir, hastayi gereksiz endiselendirir.
                //   Mesaj kuyruga girer; gonderimi 877'nin zamanli isi yapar.
                var mesajId = await RetMesajiYazAsync(baglanti, islem, numuneId, retNeden,
                                                      n.IstemId, baglam, iptal);
                mesaj = $"{n.Barkod} reddedildi - yeniden numune gerekiyor."
                      + (mesajId is null ? "" : " Hastaya e-Nabız bilgilendirmesi kuyruğa alındı.");
                break;

            default:
                throw GentegreHatasi.IsKurali("Geçersiz numune durumu.");
        }

        await baglanti.CalistirAsync("""
            insert into public.lab_numune_hareket
                   (numune_id, olay, kullanici_id, aciklama)
            values (@p0, @p1, @p2, @p3)
            """, islem,
            [numuneId, (short)(yeniDurum == 3 ? 3 : yeniDurum == 2 ? 1 : 9),
             baglam.KullaniciId, aciklama], iptal);

        await islem.CommitAsync(iptal);
        return mesaj;
    }

    /// <summary>
    /// İSTEMİN TÜM TÜPLERİNE tek işlemde alındı / kabul / ret.
    ///
    /// Mockup lab_istem_numune_kabul.html araç çubuğu ("✔ Numune Kabul" /
    /// "✖ Numune Ret") istem satırının üzerinde durur: banko hastanın
    /// tüplerini birlikte alır, birlikte kabul eder. Tek tek kabul, dört
    /// tüplük bir istemde dört ayrı diyalog demekti.
    ///
    /// SONUÇLANMIŞ tüpe dokunulmaz: çalışılmış numuneyi geri almak sonucu
    /// dayanaksız bırakırdı. Ret zaten kapalı numuneyi de atlar.
    /// </summary>
    public async Task<string> IstemNumuneDurumAsync(int istemId, short yeniDurum,
        short? kalite, short? retNeden, string aciklama, IstekBaglami baglam,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var numuneler = await baglanti.ListeAsync("""
            select id, durum from public.lab_numune
             where istem_id = @p0 and durum < 4 order by id
            """, null, [istemId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1) }, iptal);

        // Halihazirda hedef durumda olan tup ISLENMEZ: kabul zamanini
        //   yeniden yazmak TAT saatini geri alirdi.
        var hedef = numuneler.Where(n => n.Durum != yeniDurum && !(yeniDurum == 0 && n.Durum == 0))
                             .Select(n => n.Id).ToList();
        if (numuneler.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Bu istemde tüp yok - önce \"Barkod Üret\" ile numune planı çıkarın.");
        if (hedef.Count == 0)
            return "Tüplerin hepsi zaten bu durumda.";

        foreach (var id in hedef)
            await NumuneDurumAsync(id, yeniDurum, kalite, retNeden, aciklama, baglam, iptal);

        var ne = yeniDurum switch { 2 => "alındı", 3 => "kabul edildi", _ => "reddedildi" };
        return $"{hedef.Count} tüp {ne}.";
    }

    // ================================================================== sonuç
}
