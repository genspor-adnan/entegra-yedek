using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - ŞUBE / FİRMA (1268): paketteki REHBER ID&lt;0 satırı web şubesine yazılır; -1 (merkez) web'in
/// aktarımsız varsayılan şubesine BAĞLANIR (yeni şube açılmaz), alanlar REHBERBILGI'den (vergi / mersis / sicil,
/// varsayılan iletişimin adres / il / telefon / e-posta); aktarim_sube_esleme dolar; ikinci paket değişiklik yazmaz;
/// başka negatif kimlik yeni şube açar; cari gövdesi (1081) yine çalışır. İşlem içinde, geri alınır.
/// </summary>
public sealed class AktarimSubeTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> CariAsync(NpgsqlConnection b, NpgsqlTransaction t, string paket)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               "select public.fn_aktar_cari(@p0::jsonb)::text", t, [paket], CancellationToken.None) ?? "{}")!;

    private static string Paket(string firma, string vergiNo, string il) =>
        "{\"U\": {\"REHBER\": [{\"id\": -1, \"kod\": \"0001\", \"firma\": \"" + firma + "\", \"subeid\": -1, \"durum\": 1},"
        + "{\"id\": -2, \"kod\": \"0002\", \"firma\": \"Test Şube İki\", \"subeid\": -2, \"durum\": 1},"
        + "{\"id\": 990008201, \"kod\": \"AKT-SB-CARI\", \"firma\": \"Şube Testi Carisi\", \"durum\": 1}],"
        + "\"REHBERILETISIM\": [{\"id\": 990008301, \"rehberid\": -1, \"ad\": \"Merkez\", \"varsayilan\": 1, \"aktif\": 1, \"subeid\": -1}],"
        + "\"REHBERBILGI\": [{\"id\": 990008401, \"yeri\": 2, \"yer_id\": -1, \"sira\": 16, \"etiket\": \"Vergi No\", \"bilgi\": \"" + vergiNo + "\"},"
        + "{\"id\": 990008402, \"yeri\": 2, \"yer_id\": -1, \"sira\": 14, \"etiket\": \"Vergi Dairesi\", \"bilgi\": \"Davutpaşa\"},"
        + "{\"id\": 990008403, \"yeri\": 2, \"yer_id\": -1, \"sira\": 17, \"etiket\": \"Mersis No\", \"bilgi\": \"892032263500011\"},"
        + "{\"id\": 990008404, \"yeri\": 2, \"yer_id\": -1, \"sira\": 18, \"etiket\": \"Ticari Sicil No\", \"bilgi\": \"16660-5\"},"
        + "{\"id\": 990008405, \"yeri\": 1, \"yer_id\": 990008301, \"sira\": 80, \"etiket\": \"Adres\", \"bilgi\": \"Maltepe Mah. No:1\"},"
        + "{\"id\": 990008406, \"yeri\": 1, \"yer_id\": 990008301, \"sira\": 100, \"etiket\": \"İlçe\", \"bilgi\": \"Zeytinburnu\"},"
        + "{\"id\": 990008407, \"yeri\": 1, \"yer_id\": 990008301, \"sira\": 110, \"etiket\": \"İl\", \"bilgi\": \"" + il + "\"},"
        + "{\"id\": 990008408, \"yeri\": 1, \"yer_id\": 990008301, \"sira\": 20, \"etiket\": \"İş Tel\", \"bilgi\": \"0212 557 1550\"},"
        + "{\"id\": 990008409, \"yeri\": 1, \"yer_id\": 990008301, \"sira\": 60, \"etiket\": \"Eposta\", \"bilgi\": \"info@test.com\"}]}}";

    [VtFact]
    public async Task Merkez_varsayilan_subeye_baglanir_alanlar_dolar_ikinci_sube_acilir()
    {
        if (!_olgu.Baglandi(nameof(Merkez_varsayilan_subeye_baglanir_alanlar_dolar_ikinci_sube_acilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // Temiz başlangıç (işlem içinde): şube aktarım bağları ve eşleme sıfır.
        await b.CalistirAsync("update public.sube set aktarim_kaynak = null, aktarim_tablo = null, aktarim_id = null", t, [], ct);
        await b.CalistirAsync("delete from public.aktarim_sube_esleme", t, [], ct);
        var varsayilanSube = await b.TekDegerAsync<int>("select id from public.sube order by varsayilan desc, id limit 1", t, [], ct);
        var subeSayisi = await b.TekDegerAsync<long>("select count(*) from public.sube", t, [], ct);

        var ilk = await CariAsync(b, t, Paket("Test Firma Ltd.", "8920322635", "İstanbul"));
        Assert.Equal(2, ilk["sube"]!.GetValue<int>());                    // -1 güncellendi, -2 açıldı
        Assert.Equal(1, ilk["taraf"]!.GetValue<int>());                   // cari gövdesi çalıştı
        Assert.Equal(subeSayisi + 1, await b.TekDegerAsync<long>("select count(*) from public.sube", t, [], ct));

        var s = await b.TekAsync<SubeSatiri>("""
            select id, ad, unvan, vkno, vd, mersis_no, ticaret_sicil_no, adres, ilce, il, telefon, eposta
              from public.sube where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = -1
            """, t, [], o => new SubeSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3), o.GetString(4),
                                           o.GetString(5), o.GetString(6), o.GetString(7), o.GetString(8), o.GetString(9),
                                           o.GetString(10), o.GetString(11)), ct);
        Assert.NotNull(s);
        Assert.Equal(varsayilanSube, s.Id);                               // yeni şube değil, varsayılan şube bağlandı
        Assert.Equal("Test Firma Ltd.", s.Unvan);
        Assert.Equal("8920322635", s.Vkno);
        Assert.Equal("Davutpaşa", s.Vd);
        Assert.Equal("892032263500011", s.Mersis);
        Assert.Equal("16660-5", s.Sicil);
        Assert.Equal("Maltepe Mah. No:1", s.Adres);
        Assert.Equal("Zeytinburnu", s.Ilce);
        Assert.Equal("İstanbul", s.Il);
        Assert.Equal("0212 557 1550", s.Telefon);
        Assert.Equal("info@test.com", s.Eposta);
        Assert.Equal(s.Id, await b.TekDegerAsync<int>("select sube_id from public.aktarim_sube_esleme where delphi_sube_id = -1", t, [], ct));
        Assert.Equal(s.Id, await b.TekDegerAsync<int>("select public.fn_aktarim_sube(-1)", t, [], ct));
        // e-Belge göndericisi artık firmanın kimliğini taşır.
        Assert.Equal("8920322635", await b.TekDegerAsync<string>("select vkno from public.v_ebelge_gonderici where sube_id = @p0", t, [s.Id], ct));

        var ikinciSube = await b.TekDegerAsync<int>(
            "select id from public.sube where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = -2", t, [], ct);
        Assert.NotEqual(s.Id, ikinciSube);
        Assert.Equal(ikinciSube, await b.TekDegerAsync<int>("select public.fn_aktarim_sube(-2)", t, [], ct));

        // Aynı paket: değişiklik yok. Değişen il: yalnız o güncellenir.
        Assert.Equal(0, (await CariAsync(b, t, Paket("Test Firma Ltd.", "8920322635", "İstanbul")))["sube"]!.GetValue<int>());
        Assert.Equal(1, (await CariAsync(b, t, Paket("Test Firma Ltd.", "8920322635", "Ankara")))["sube"]!.GetValue<int>());
        Assert.Equal("Ankara", await b.TekDegerAsync<string>("select il from public.sube where id = @p0", t, [s.Id], ct));
    }

    private sealed record SubeSatiri(int Id, string Ad, string Unvan, string Vkno, string Vd, string Mersis, string Sicil,
                                     string Adres, string Ilce, string Il, string Telefon, string Eposta);
}
