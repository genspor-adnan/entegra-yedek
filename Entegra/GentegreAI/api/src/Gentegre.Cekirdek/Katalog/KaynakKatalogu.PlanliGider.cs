namespace Gentegre.Cekirdek.Katalog;

/// <summary>PLANLI GİDER KATEGORİLERİ listesi (1177) - kartın öntanımları; kullanım sayısıyla.</summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi PlanliGiderKategori() => new(
        Ad: "planli-gider-kategori",
        YetkiKodu: "finans.planli_gider_kategori",
        Kaynak: "public.planli_gider_kategori k left join public.masraf m on m.id = k.masraf_id",
        SubeKolonu: null,
        VarsayilanSirala: "k.sira, k.ad",
        Kolonlar:
        [
            new("id", "k.id", "sayi", "Id", Varsayilan: false),
            new("kod", "k.kod", "metin", "Kod", Genislik: 110),
            new("ad", "k.ad", "metin", "Kategori", Genislik: 200),
            new("masraf", "coalesce(nullif(concat_ws(' · ', nullif(m.kod, ''), m.ad), ''), '')", "metin", "Masraf kalemi", Genislik: 220),
            new("tutarTur", "k.tutar_tur", "kod", "Tutar türü", Genislik: 160, Kodlar: KartKatalogu.PlanliGiderTutarTurleri),
            new("tatilKural", "k.tatil_kural", "kod", "Tatil", Genislik: 130, Kodlar: KartKatalogu.PlanliGiderTatilKurallari),
            new("hatirlatmaGun", "k.hatirlatma_gun", "sayi", "Hatırlatma (gün)", Hizalama: "sag", Genislik: 110),
            new("kullanim", "(select count(*) from public.planli_gider g where g.kategori_id = k.id)",
                "sayi", "Tanım", Hizalama: "sag", Genislik: 80, Filtrelenebilir: false),
            new("sira", "k.sira", "sayi", "Sıra", Hizalama: "sag", Genislik: 70, Varsayilan: false),
            new("aktif", "k.aktif", "mantik", "Aktif", Hizalama: "orta", Genislik: 80),
        ]);
}
