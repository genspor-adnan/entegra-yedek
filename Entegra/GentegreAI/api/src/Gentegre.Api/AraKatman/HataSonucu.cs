using System.Text.Json;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// SÖZLEŞME BİÇİMİNDE HATA YANITI, FIRLATMADAN (refaktör 20.11.2026, B2; sözleşme §1.2 `{hata:{kod,mesaj,izlemeNo}}`).
///
/// Olağan yol <c>throw GentegreHatasi…</c>: ara katman biçimlendirir ve hata_log'a yazar. Bazı uçlarda "yok" OLAĞAN
/// bir cevaptır (ekranın yardım metni tanımlı değil, kart özeti boş…); orada her isteği hata_log'a yazmak gürültü olur.
/// O uçlar eskiden gövdesiz <c>Results.NotFound()</c> ya da düz <c>{hata:"…", mesaj}</c> dönüyordu - istemci gövdeyi
/// çözemeyip "Sunucuya ulaşılamadı (404)" gösteriyordu. Bu yardımcı aynı durumu DOĞRU BİÇİMDE, log yazmadan döner.
/// </summary>
public static class HataSonucu
{
    private static IResult Yaz(string kod, string mesaj, string izlemeNo)
        => Results.Json(new HataYaniti { Hata = new HataGovdesi { Kod = kod, Mesaj = mesaj, IzlemeNo = izlemeNo } },
                        JsonAyarlari.Secenekler, statusCode: HataKodu.HttpDurumu(kod));

    public static IResult Bulunamadi(string mesaj = "Kayıt bulunamadı.", string izlemeNo = "")
        => Yaz(HataKodu.Bulunamadi, mesaj, izlemeNo);

    public static IResult Dogrulama(string mesaj, string izlemeNo = "")
        => Yaz(HataKodu.Dogrulama, mesaj, izlemeNo);
}
