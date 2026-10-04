using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// DOKÜMAN ERİŞİM KAPISI (tekrar denetim 28.09.2026 #1).
///
/// <para>Doküman uçları yetkiyi URL'deki kart adından çözüyor, depo ise
/// yalnız doküman kimliğiyle çalışıyordu: `cari` değiştirme yetkisi olan biri
/// cari yolu altında bir LAB dokümanının kimliğini verip paylaşım linki
/// üretebiliyor, silebiliyordu; içerik ucu da lab dışındaki kaynaklarda kayıt
/// kapsamına bakmıyordu.</para>
///
/// <para>Bu kapı dokümanın GERÇEK bağını (`dokuman.kaynak`, `kaynak_id`)
/// veritabanından okur ve kararı ona göre verir: kaynak türünün yetkisi +
/// o kaydın katalogdaki erişim kuralı (şube, kayıt kapsamı, portal, hekim —
/// <see cref="KayitErisimi"/>). Okuma, değiştirme, silme ve paylaşım aynı
/// kapıdan geçer. Tanımadığı kaynak türü KAPALIDIR. Kapsam dışı doküman,
/// var olmayanla aynı 404'ü alır.</para>
///
/// <para><b>Kendi kartı:</b> istisna URL'ye değil gerçek sahipliğe bağlıdır —
/// dokümanın bağı `taraf` + kişinin kendi kimliği ise (profil fotoğrafı).</para>
/// </summary>
public sealed class DokumanErisimi(VeriKaynagi veri, KayitErisimi erisim)
{
    /// <param name="Yetkiler">Bu kaynak türünde işlem için gereken kaynak yetkisi
    /// (herhangi biri yeter).</param>
    /// <param name="Kataloglar">Kayıt kapsamının sorulacağı katalog kaynakları;
    /// kullanıcının yetkisi olan herhangi birinde görünür olması yeter. Boşsa
    /// kaynağın kayıt düzeyi kapsamı yoktur (kurum geneli).</param>
    /// <param name="HerkeseGor">Oturumlu herkes GÖREBİLİR (şube logosu, e-Belge
    /// şablonu - çıktılarda herkes kullanır); değiştirmek yine yetki ister.</param>
    private sealed record Kural(string[] Yetkiler, string[] Kataloglar, bool HerkeseGor = false);

    private static readonly Dictionary<string, Kural> Kurallar = new(StringComparer.Ordinal)
    {
        // cari / kisi / personel / hasta hepsi `taraf` satırı (DokumanUclari.FizikselKaynak).
        ["taraf"]           = new(["cari", "personel"], ["cari", "personel"]),
        ["stok"]            = new(["stok"], ["stok"]),
        ["belge"]           = new(["belge"], ["belge"]),
        ["muayene"]         = new(["muayene"], ["muayene"]),
        ["radyoloji-istem"] = new(["radyoloji", "radyoloji-istem"], ["radyoloji-istem"]),
        ["masraf-beyan"]    = new(["ik.masraf"], ["personel-masraf"]),
        ["servis-ziyaret"]  = new(["servis"], ["servis-ziyaret"]),
        ["klasor"]          = new(["dokuman"], []),
        ["sube"]            = new(["sube"], [], HerkeseGor: true),
        ["ebelge-xslt"]     = new(["ebelge_xslt"], [], HerkeseGor: true),
        // "lab-sonuc" ayrı: satır kapsamı + tetkik izni (KayitErisimi.LabSatirIsteAsync).
    };

    /// <summary>Kuralı olan kaynak türleri (test: her tür katalogda çözülmeli).</summary>
    public static IEnumerable<string> BilinenKataloglar => Kurallar.Values.SelectMany(k => k.Kataloglar);

    public sealed record Bag(string Kaynak, long KaynakId);

    /// <summary>Dokümanın gerçek bağı; yoksa null.</summary>
    public Task<Bag?> BagAsync(int dokumanId, CancellationToken iptal)
        => veri.TekAsync("select kaynak, kaynak_id from public.dokuman where id = @p0",
                         [dokumanId], o => new Bag(o.GetString(0), o.GetInt32(1)), iptal);

    /// <summary>Doküman kimliğiyle gelen her işlem: gerçek bağ + kural. Yetkisizse 404/403.</summary>
    public async Task<Bag> IsteAsync(IstekBaglami baglam, int dokumanId, Islem islem,
                                     CancellationToken iptal)
    {
        var bag = await BagAsync(dokumanId, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Doküman bulunamadı.");
        await KaynakIsteAsync(baglam, bag.Kaynak, bag.KaynakId, islem, iptal);
        return bag;
    }

    /// <summary>
    /// KART YOLU: URL'deki kart/kayıt ile dokümanın GERÇEK bağı eşleşmek
    /// zorunda - başka kaydın dokümanı bu yol altından yönetilemez.
    /// </summary>
    public async Task BagliIsteAsync(IstekBaglami baglam, int dokumanId, string fizikselKaynak,
                                     long kaynakId, Islem islem, CancellationToken iptal)
    {
        var bag = await BagAsync(dokumanId, iptal);
        if (bag is null || bag.Kaynak != fizikselKaynak || bag.KaynakId != kaynakId)
            throw GentegreHatasi.Bulunamadi("Doküman bulunamadı.");
        await KaynakIsteAsync(baglam, bag.Kaynak, bag.KaynakId, islem, iptal);
    }

    /// <summary>Bir kaynağın (kart kaydının) dokümanları üzerinde işlem hakkı.</summary>
    public async Task KaynakIsteAsync(IstekBaglami baglam, string kaynak, long kaynakId,
                                      Islem islem, CancellationToken iptal)
    {
        const string yok = "Doküman bulunamadı.";
        if (KendiKartiMi(baglam, kaynak, kaynakId))
        {
            if (islem != Islem.Gor) baglam.YazmaIste();
            return;
        }

        // ARIZA FOTOĞRAFI (954): bildiren ya da takipçi kendi kaydında;
        //   ekip `ariza` yetkisiyle. Başkası = bulunamadı.
        if (kaynak == "ariza")
        {
            var kendi = await veri.TekDegerAsync<bool>("""
                select exists (select 1 from public.ariza_talep t where t.id = @p0
                                 and (t.talep_eden = @p1 or exists (
                                      select 1 from public.ariza_talep_takipci k
                                       where k.talep_id = t.id and k.taraf_id = @p1)))
                """, [(int)kaynakId, baglam.KullaniciId], iptal);
            if (!kendi && !baglam.Yetkiler.Var("ariza", islem == Islem.Gor ? Islem.Gor : Islem.Degistir))
                throw GentegreHatasi.Bulunamadi(yok);
            if (islem != Islem.Gor) baglam.YazmaIste();
            return;
        }

        // İZİN BELGESİ (959): talep sahibi kendi izninde; İK `ik.izin` yetkisiyle.
        if (kaynak is "izin" or "avans" or "belge-talep")
        {
            var sahip = await veri.TekDegerAsync<int?>(kaynak switch
            {
                "izin" => "select taraf_id from public.personel_izin where id = @p0",
                "avans" => "select taraf_id from public.personel_avans where id = @p0",
                _ => "select taraf_id from public.personel_belge_talep where id = @p0",
            }, [(int)kaynakId], iptal);
            if (sahip is null) throw GentegreHatasi.Bulunamadi(yok);
            if (sahip != baglam.KullaniciId
                && !baglam.Yetkiler.Var(kaynak switch { "izin" => "ik.izin", "avans" => "ik.avans", _ => "ik.belge_talep" },
                                        islem == Islem.Gor ? Islem.Gor : Islem.Degistir))
                throw GentegreHatasi.Bulunamadi(yok);
            if (islem != Islem.Gor) baglam.YazmaIste();
            return;
        }

        // DUYURU EKİ (957): duyuruyu gören okur; yükleme / silme `duyuru` yetkisiyle.
        if (kaynak == "duyuru")
        {
            var yonetir = baglam.Yetkiler.Var("duyuru", islem == Islem.Gor ? Islem.Gor : Islem.Degistir);
            if (!yonetir)
            {
                if (islem != Islem.Gor) throw GentegreHatasi.Bulunamadi(yok);
                var gorur = await veri.TekDegerAsync<bool>(
                    "select public.fn_duyuru_gorur(@p0, @p1)", [(int)kaynakId, baglam.KullaniciId], iptal);
                if (!gorur) throw GentegreHatasi.Bulunamadi(yok);
            }
            if (islem != Islem.Gor) baglam.YazmaIste();
            return;
        }

        if (kaynak == "lab-sonuc")
        {
            // Yetkisizlik de 404: 403 dönmek, kimliğin bir LAB dokümanı olduğunu söylerdi.
            if (!baglam.Yetkiler.Var("lab.sonuc", islem == Islem.Gor ? Islem.Gor : Islem.Degistir))
                throw GentegreHatasi.Bulunamadi(yok);
            if (islem != Islem.Gor) baglam.YazmaIste();
            try { await erisim.LabSatirIsteAsync(baglam, kaynakId, iptal); }
            catch (GentegreHatasi h) when (h.Kod is HataKodu.Bulunamadi or HataKodu.Yasak)
            {
                throw GentegreHatasi.Bulunamadi(yok);
            }
            return;
        }

        // Tanınmayan kaynak türü KAPALI: yarın eklenen bir doküman türü
        //   kimse fark etmeden herkese açılmasın.
        if (!Kurallar.TryGetValue(kaynak, out var kural))
            throw GentegreHatasi.Bulunamadi(yok);

        if (islem == Islem.Gor && kural.HerkeseGor) return;

        var yetkili = kural.Yetkiler.Where(y => baglam.Yetkiler.Var(y, islem)).ToList();
        if (yetkili.Count == 0) throw GentegreHatasi.Bulunamadi(yok);
        if (islem != Islem.Gor) baglam.YazmaIste();

        if (kural.Kataloglar.Length == 0) return;

        // KAYIT KAPSAMI: kullanıcının GÖRME yetkisi olan katalog kaynaklarından
        //   birinde kayıt görünür olmalı (liste ile aynı kural).
        foreach (var ad in kural.Kataloglar)
        {
            if (KaynakKatalogu.Bul(ad) is not { } tanim) continue;
            if (!baglam.Yetkiler.Var(tanim.YetkiKodu, Islem.Gor)) continue;
            if (await erisim.GorunurAsync(baglam, ad, kaynakId, iptal)) return;
        }
        throw GentegreHatasi.Bulunamadi(yok);
    }

    private static bool KendiKartiMi(IstekBaglami baglam, string kaynak, long kaynakId)
        => kaynak == "taraf" && kaynakId == baglam.KullaniciId;
}
