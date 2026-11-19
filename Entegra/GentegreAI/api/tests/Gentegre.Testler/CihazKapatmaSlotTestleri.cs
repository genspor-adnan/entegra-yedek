using System.Net.Http.Json;
using System.Text.Json;

namespace Gentegre.Testler;

/// <summary>
/// CİHAZ KAPATMA SAATLİ + SLOTTAN SEÇİM (kullanıcı 19.11.2026: "başlangıç / bitiş tarihlerine saat ekle" · "slot
/// bazında da kapatma olabilir mi? gün içinde başlama bitiş slotlar işaretlenerek"). Kart detayında yazılan yerel saat
/// şubenin saatinde yorumlanır; günün slotları ucu öğleyi ve kapalı slotları işaretler, saatler şubenin saatidir.
/// </summary>
[Collection(ApiKoleksiyonu.Ad)]
public sealed class CihazKapatmaSlotTestleri(ApiSunucuOlgusu api)
{
    private const int Merkez = 1;

    [VtFact]
    public async Task Saatli_kapatma_ve_gun_slotlari()
    {
        await using var d = new TestDunyasi(api.Veri);
        var rol = await d.RolAsync("ckslot", "radyoloji:ged");
        var (u, kod) = await d.KullaniciAsync(rol, Merkez);
        await d.SubeVerAsync(u, Merkez, yazma: true, varsayilan: true);
        var (access, _) = await api.GirisAsync(kod, TestDunyasi.Parola);
        using var h = api.Istemci(access, Merkez);

        var cihaz = await api.Veri.TekDegerAsync<int>("""
            insert into public.radyoloji_cihaz (ad, modalite, sube_id, randevu_verilir, baslangic_saat, bitis_saat,
                                                ogle_baslangic, ogle_bitis, slot_dk, eszaman, calisma_gunleri)
            values (@p0, 1, @p1, 1, '08:00', '12:00', '10:00', '10:30', 30, 1, '1,2,3,4,5,6,7') returning id
            """, [d.Onek + " cihaz", Merkez]);
        d.Temizle($"delete from public.radyoloji_cihaz where id = {cihaz}");
        d.Temizle($"delete from public.radyoloji_cihaz_kapatma where cihaz_id = {cihaz}");

        var gun = DateTime.UtcNow.Date.AddDays(30);
        var kart = (await h.GetFromJsonAsync<JsonElement>($"/api/kart/radyoloji-cihaz/{cihaz}")).GetProperty("kart");
        var p = await h.PutAsJsonAsync($"/api/kart/radyoloji-cihaz/{cihaz}", new
        {
            surum = kart.GetProperty("surum").GetString(),
            kart = new { },
            detaylar = new { kapatmalar = new { eklenen = new object[]
                {
                    new { baslangic = $"{gun:yyyy-MM-dd}T09:00", bitis = $"{gun:yyyy-MM-dd}T10:00", nedenTur = 1, aciklama = "slot" },
                    // TAM GÜN: iki gün (bitiş ertesi gün 00:00, hariç)
                    new { baslangic = $"{gun.AddDays(5):yyyy-MM-dd}T00:00", bitis = $"{gun.AddDays(7):yyyy-MM-dd}T00:00", nedenTur = 3, aciklama = "tam" },
                } } },
        });
        Assert.True(p.IsSuccessStatusCode, await p.Content.ReadAsStringAsync());

        // DB'de şubenin saatiyle 09:00-10:00 (UTC an olarak saklı).
        var yerel = await api.Veri.TekDegerAsync<string>("""
            select to_char(k.baslangic at time zone public.fn_sube_zaman_dilimi(@p1), 'HH24:MI') || '-' ||
                   to_char(k.bitis at time zone public.fn_sube_zaman_dilimi(@p1), 'HH24:MI')
              from public.radyoloji_cihaz_kapatma k where k.cihaz_id = @p0 and k.aciklama = 'slot'
            """, [cihaz, Merkez]);
        Assert.Equal("09:00-10:00", yerel);

        // Gridde tek "Aralık" kolonu: slot "gg.aa.yyyy 09:00–10:00", tam gün "ilk – son (tam gün)".
        var kartJson = (await h.GetFromJsonAsync<JsonElement>($"/api/kart/radyoloji-cihaz/{cihaz}")).GetRawText();
        Assert.Contains($"{gun:dd.MM.yyyy} 09:00–10:00", System.Text.RegularExpressions.Regex.Unescape(kartJson));
        Assert.Contains($"{gun.AddDays(5):dd.MM.yyyy} – {gun.AddDays(6):dd.MM.yyyy} (tam gün)", System.Text.RegularExpressions.Regex.Unescape(kartJson));

        var j = await h.GetFromJsonAsync<JsonElement>($"/api/radyoloji/cihaz/{cihaz}/gun-slotlari?tarih={gun:yyyy-MM-dd}");
        Assert.True(j.GetProperty("calisir").GetBoolean());
        var slotlar = j.GetProperty("slotlar").EnumerateArray()
            .ToDictionary(s => s.GetProperty("saat").GetString()!, s => s.GetProperty("tur").GetString());
        Assert.Equal(8, slotlar.Count);                                   // 08:00 … 11:30, 30 dk
        Assert.Equal("acik", slotlar["08:30"]);
        Assert.Equal("kapali", slotlar["09:00"]);
        Assert.Equal("kapali", slotlar["09:30"]);
        Assert.Equal("ogle", slotlar["10:00"]);
        Assert.Equal("acik", slotlar["10:30"]);
        Assert.Equal($"{gun:yyyy-MM-dd}T09:00",
            j.GetProperty("slotlar").EnumerateArray().First(s => s.GetProperty("saat").GetString() == "09:00").GetProperty("bas").GetString());
    }
}
