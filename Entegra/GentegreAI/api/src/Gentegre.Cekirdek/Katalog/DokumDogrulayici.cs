using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// DÖKÜM TANIMI DOĞRULAMASI (686). Tanım kaydedilirken VE çalıştırılırken
/// aynı kapıdan geçer: kaynak katalogda mı, alanlar GÖRÜNÜR kolonlar arasında
/// mı (alan yetkisi + ürün modu), fn beyaz listede mi, fn alana uyuyor mu,
/// boyut/ölçü tavanı aşılmış mı. AI'nın ürettiği taslak da buradan geçer.
/// </summary>
public static class DokumDogrulayici
{
    public const int EnCokBoyut = 3;
    public const int EnCokOlcu = 8;

    public static KaynakTanimi Dogrula(DokumTanimi t, IReadOnlyList<KolonTanimi> gorunur)
    {
        var kaynak = KaynakKatalogu.Bul(t.Kaynak)
            ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen kaynak: {t.Kaynak}",
                   new AlanHatasi("kaynak", "Katalogda yok."));
        var dizin = gorunur.ToDictionary(k => k.Ad, StringComparer.Ordinal);

        KolonTanimi Kolon(string ad, string yer)
            => dizin.TryGetValue(ad, out var k) ? k
               : throw GentegreHatasi.Dogrulama($"Bilinmeyen ya da yetkisiz alan: {ad}",
                     new AlanHatasi(yer, $"'{ad}' bu kaynakta görünür değil."));

        if (t.Cikti is not ("liste" or "ozet"))
            throw GentegreHatasi.Dogrulama("Çıktı 'liste' ya da 'ozet' olmalı.", new AlanHatasi("cikti", "Geçersiz."));

        if (t.Filtre is not null) FiltreDogrula(t.Filtre, Kolon);
        foreach (var k in t.Kolonlar ?? []) Kolon(k, "kolonlar");
        foreach (var s in t.Sirala ?? [])
            if (!Kolon(s.Alan, "sirala").Siralanabilir)
                throw GentegreHatasi.Dogrulama($"{s.Alan} sıralanamaz.", new AlanHatasi("sirala", "Sıralanabilir değil."));
        foreach (var k in t.Toplam ?? [])
            if (!Kolon(k, "toplam").SayiMi)
                throw GentegreHatasi.Dogrulama($"{k} toplanamaz.", new AlanHatasi("toplam", "Sayı değil."));
        foreach (var g in t.Grup ?? [])
            if (!OlcuKatalogu.Gruplanabilir(Kolon(g, "grup")))
                throw GentegreHatasi.Dogrulama($"{g} gruplanamaz.", new AlanHatasi("grup", "Gruplanabilir değil."));
        if ((t.Grup?.Count ?? 0) > 2)
            throw GentegreHatasi.Dogrulama("Liste gruplaması en çok 2 kolon.", new AlanHatasi("grup", "En çok 2."));

        foreach (var (alan, p) in t.Parametreler ?? [])
        {
            Kolon(alan, "parametreler");
            if (p.Kural.Length > 0 && !ParametreCozucu.Kurallar.Contains(p.Kural))
                throw GentegreHatasi.Dogrulama($"Bilinmeyen tarih kuralı: {p.Kural}",
                    new AlanHatasi("parametreler", "Geçersiz kural."));
        }

        if (t.Cikti == "ozet")
        {
            var boyutlar = new List<string>(t.Boyut?.Satir ?? []);
            if (!string.IsNullOrEmpty(t.Boyut?.Sutun)) boyutlar.Add(t.Boyut!.Sutun!);
            if (boyutlar.Count == 0)
                throw GentegreHatasi.Dogrulama("Özet için en az bir boyut seçin.", new AlanHatasi("boyut", "Boş."));
            if (boyutlar.Count > EnCokBoyut)
                throw GentegreHatasi.Dogrulama($"En çok {EnCokBoyut} boyut.", new AlanHatasi("boyut", "Fazla."));
            foreach (var b in boyutlar)
            {
                var (alan, kesme) = OlcuKatalogu.BoyutCoz(b);
                var k = Kolon(alan, "boyut");
                if (!OlcuKatalogu.Gruplanabilir(k))
                    throw GentegreHatasi.Dogrulama($"{alan} boyut olamaz.", new AlanHatasi("boyut", "Gruplanabilir değil."));
                if (kesme.Length > 0 && (k.Tip != "tarih" || !OlcuKatalogu.KesmeVar(kesme)))
                    throw GentegreHatasi.Dogrulama($"{b}: geçersiz tarih kesmesi.", new AlanHatasi("boyut", "Geçersiz kesme."));
            }

            var olculer = t.Olcu ?? [];
            if (olculer.Count == 0)
                throw GentegreHatasi.Dogrulama("Özet için en az bir ölçü seçin.", new AlanHatasi("olcu", "Boş."));
            if (olculer.Count > EnCokOlcu)
                throw GentegreHatasi.Dogrulama($"En çok {EnCokOlcu} ölçü.", new AlanHatasi("olcu", "Fazla."));
            foreach (var o in olculer)
            {
                var fn = OlcuKatalogu.Fn(o.Fn)
                    ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen ölçü: {o.Fn}", new AlanHatasi("olcu", "Geçersiz fn."));
                if (fn.AlanIster)
                {
                    if (string.IsNullOrEmpty(o.Alan))
                        throw GentegreHatasi.Dogrulama($"{o.Fn} alan ister.", new AlanHatasi("olcu", "Alan seçin."));
                    var k = Kolon(o.Alan!, "olcu");
                    if (fn.SayiIster && !OlcuKatalogu.Olculebilir(k))
                        throw GentegreHatasi.Dogrulama($"{o.Alan} sayısal değil.", new AlanHatasi("olcu", "Sayı/para alanı seçin."));
                }
                if (o.Fn == "oran")
                {
                    if (string.IsNullOrEmpty(o.Bolen))
                        throw GentegreHatasi.Dogrulama("Oran için bölen seçin.", new AlanHatasi("olcu", "Bölen boş."));
                    if (!OlcuKatalogu.Olculebilir(Kolon(o.Bolen!, "olcu")))
                        throw GentegreHatasi.Dogrulama($"{o.Bolen} sayısal değil.", new AlanHatasi("olcu", "Bölen sayı olmalı."));
                }
            }
            if (t.Kiyas is not ("yok" or "oncekiDonem" or "oncekiYil"))
                throw GentegreHatasi.Dogrulama("Kıyas: yok · oncekiDonem · oncekiYil.", new AlanHatasi("kiyas", "Geçersiz."));
            if (t.Esik < 0 || t.Esik > 1000)
                throw GentegreHatasi.Dogrulama("Eşik 0-1000 arası.", new AlanHatasi("esik", "Aralık dışı."));
        }
        return kaynak;
    }

    private static void FiltreDogrula(Kosul k, Func<string, string, KolonTanimi> kolon)
    {
        if (k.DalMi) { foreach (var a in k.Kosullar!) FiltreDogrula(a, kolon); return; }
        if (string.IsNullOrEmpty(k.Alan)) return;
        var kol = kolon(k.Alan!, "filtre");
        if (!kol.Filtrelenebilir)
            throw GentegreHatasi.Dogrulama($"{kol.Baslik} süzülemez.", new AlanHatasi("filtre", "Filtrelenebilir değil."));
        if (!KosulOperatoru.Gecerlidir(k.Op))
            throw GentegreHatasi.Dogrulama($"Bilinmeyen operatör: {k.Op}", new AlanHatasi("filtre", "Geçersiz operatör."));
    }
}
