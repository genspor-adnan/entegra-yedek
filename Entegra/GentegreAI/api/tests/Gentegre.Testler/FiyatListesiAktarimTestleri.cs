using System.Text.Json;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DELPHİ FİYAT ADLARI -> FİYAT LİSTESİ (1280, kullanıcı 09.11.2026: "universe DB den fiyat listesi ve fiyatlar
/// migrate olmadı mı"). Aktarım stok_fiyat'ı dolduruyor ama web fiyatı fiyat_listesi'nden alıyor: fonksiyon her
/// satış / alış fiyat adını bir listeye çevirir, maliyet adlarını (-1 / -2) atlar, ikinci çağrıda hiçbir şey eklemez.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class FiyatListesiAktarimTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;
    private const int FiyatAdi = 9636;   // gerçek kurulumlarda kullanılmayan ad kodu - test listesi ayrışsın

    [VtFact]
    public async Task Satis_fiyat_adi_listeye_doner_maliyet_atlanir_ikinci_cagri_eklemez()
    {
        await using var d = new TestDunyasi(api.Veri);
        var stok = await api.Veri.TekDegerAsync<int>(
            "insert into public.stok (kod, ad, durum, izleme, sube_id) values (@p0, @p1, 1, 0, @p2) returning id",
            [d.Onek + "-FL", d.Onek + " fiyat stoğu", Merkez]);
        d.Temizle($"delete from public.fiyat_listesi_satir where stok_id = {stok}");
        d.Temizle($"delete from public.stok_fiyat where stok_id = {stok}");
        d.Temizle($"delete from public.stok where id = {stok}");
        d.Temizle($"delete from public.fiyat_listesi where aciklama like 'Delphi fiyat adı {FiyatAdi} %'");
        // Satış adı: TL + EUR (ux_sls_stok döviz başına satır), maliyet adı -1: liste değil.
        await api.Veri.CalistirAsync("""
            insert into public.stok_fiyat (stok_id, fiyat_adi, birim, fiyat, doviz_cinsi, satis) values
              (@p0, @p1, 51, 100, 'TL', 1), (@p0, @p1, 51, 5, 'EUR', 1), (@p0, -1, 51, 40, 'TL', 0)
            """, [stok, FiyatAdi]);

        var ilk = JsonDocument.Parse((await api.Veri.TekDegerAsync<string>(
            "select public.fn_aktar_fiyat_listesi()::text", null))!).RootElement;
        Assert.True(ilk.GetProperty("liste_yeni").GetInt32() >= 1, ilk.ToString());

        var liste = await api.Veri.TekDegerAsync<int>(
            "select id from public.fiyat_listesi where aciklama like @p0 and yon = 2", [$"Delphi fiyat adı {FiyatAdi} %"]);
        Assert.True(liste > 0);
        var satir = await api.Veri.TekDegerAsync<int>(
            "select count(*) from public.fiyat_listesi_satir where liste_id = @p0 and stok_id = @p1 and yazim = 3", [liste, stok]);
        Assert.Equal(2, satir);
        var maliyet = await api.Veri.TekDegerAsync<int>(
            "select count(*) from public.fiyat_listesi where aciklama like 'Delphi fiyat adı -1 %'", null);
        Assert.Equal(0, maliyet);

        // Fiyatlama zinciri listeyi görür (204): cari listesi yoksa yönün varsayılanı ya da kart fiyatı -
        //   iki yoldan biri 100 TL'yi vermeli.
        var fiyat = await api.Veri.TekDegerAsync<decimal>(
            "select fiyat from public.fn_fiyat_listesi_fiyat(@p0, @p1) ", [liste, stok]);
        Assert.Contains(fiyat, new[] { 100m, 5m });

        var ikinci = JsonDocument.Parse((await api.Veri.TekDegerAsync<string>(
            "select public.fn_aktar_fiyat_listesi()::text", null))!).RootElement;
        Assert.Equal(0, ikinci.GetProperty("liste_yeni").GetInt32());
        Assert.Equal(0, ikinci.GetProperty("satir_eklenen").GetInt32());
    }
}
