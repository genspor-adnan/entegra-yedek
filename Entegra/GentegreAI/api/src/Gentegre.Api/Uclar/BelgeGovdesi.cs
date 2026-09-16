using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;
using System.Text.Json;

namespace Gentegre.Api.Uclar;

/// <summary>
/// BELGE YAZMA HATTININ GİRDİ BİÇİMİ - ortak yardımcı.
///
/// `BelgeDeposu` isteği JSON olarak alıyor; uçlar satırı kod içinde kurduğu
/// için aynı biçime çevirmek gerekiyor. Bu iki yardımcı radyoloji, üretim ve
/// ameliyathane uçlarında birebir tekrar ediyordu (dördüncü kopya
/// yazılacaktı) - kural değişince üçünün birden değişmesi gerekirdi ve biri
/// unutulurdu.
/// </summary>
public static class BelgeGovdesi
{
    /// <summary>Sözlük -> BelgeDeposu'nun beklediği JsonElement satırı.</summary>
    public static Dictionary<string, JsonElement> Satir(IDictionary<string, object?> alanlar)
    {
        var json = JsonSerializer.SerializeToElement(alanlar);
        var sozluk = new Dictionary<string, JsonElement>(StringComparer.Ordinal);
        foreach (var alan in json.EnumerateObject()) sozluk[alan.Name] = alan.Value;
        return sozluk;
    }

    /// <summary>
    /// Mevcut belgeyi (başlık + satırlar) yazma hattının beklediği biçimde
    /// okur. BELGEYE SATIR EKLEMEK İÇİN ŞART: `BelgeDeposu.GuncelleAsync`
    /// belgeyi bütün olarak yazar - eksik gönderilen satır SİLİNMİŞ sayılır.
    /// </summary>
    public static async Task<(IDictionary<string, object?> Belge,
                              List<Dictionary<string, JsonElement>> Satirlar)>
        OkuAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        var belge = await baglanti.TekAsync("""
            select b.tur, b.tipi, b.taraf_id as "tarafId", b.belge_tarihi as "belgeTarihi",
                   b.belge_seri as "belgeSeri", b.belge_no as "belgeNo",
                   b.belge_dovizi as "belgeDovizi", b.rapor_dovizi as "raporDovizi",
                   b.ekstre_dovizi as "ekstreDovizi", b.doviz_kuru as "dovizKuru",
                   b.vade_gun as "vadeGun", b.aciklama, b.ozel_kod as "ozelKod",
                   b.satici_id as "saticiId", b.cikis_depo_id as "cikisDepoId",
                   b.giris_depo_id as "girisDepoId", b.fiyat_listesi_id as "fiyatListesiId",
                   b.kampanya_id as "kampanyaId", b.sube_id as "subeId", b.senaryo,
                   -- ODEYEN KURUM (249) uzantida durur ama govdede OLMALI:
                   --   pay bolusumu (289) bu alandan hesaplaniyor - eksik
                   --   gonderilirse tum tutar hastaya yazilir.
                   bb.odeyen_kurum_id as "odeyenKurumId",
                   bb.bolum_id as "bolumId", bb.personel_id as "personelId"
              from public.belge b
              left join public.belge_basvuru bb on bb.id = b.id
             where b.id = @p0
            """, null, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Belge bulunamadı.");

        var mevcut = await baglanti.ListeAsync("""
            select s.id, s.tur, s.stok_id as "stokId", s.hizmet_id as "hizmetId",
                   s.masraf_id as "masrafId", s.aciklama, s.miktar, s.birim,
                   s.birim_fiyat as "birimFiyat", s.iskonto, s.kdv,
                   s.doviz_cinsi as "dovizCinsi",
                   -- Satirda TEK depo kolonu yok: yon'e gore giris/cikis
                   --   kolonlari kullaniliyor (belge_satir semasi).
                   s.giris_depo_id as "girisDepoId", s.cikis_depo_id as "cikisDepoId",
                   s.kaynak_tur as "kaynakTur", s.kaynak_id as "kaynakId",
                   s.pay, coalesce(dg.sgk + dg.oss, 0) as "kurumTutar",
                   coalesce(dg.hasta_provizyon + dg.hasta_ek_katki, 0)
                     as "hastaTutar",
                   s.sira
              from public.belge_satir s
              left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
             where s.belge_id = @p0 order by s.sira, s.id
            """, null, [belgeId], OkuyucuGenisletmeleri.Sozluk, iptal);

        return (belge, mevcut.Select(Satir).ToList());
    }
}
