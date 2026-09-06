using System.Text;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// CİHAZ ARA KATMANI (432) — mesajı ALIR, SAKLAR, sonra çözümler.
///
/// <para><b>Sıra bilinçli: önce kayıt, sonra çözümleme.</b> Cihaz sonucu bir
/// kez gönderir; çözümleme çökerse ham metin durmalı ki sürücü düzeltilince
/// yeniden işlensin. Tersi sırada bir ayrıştırma hatası veriyi yok ederdi.</para>
///
/// <para><b>Mükerrer gönderim korunur.</b> Cihazlar bağlantı koptu sanıp aynı
/// sonucu tekrar yolluyor; <c>cihaz + kontrol numarası</c> benzersiz indeksi
/// ikinci kaydı reddeder ve mesaj "zaten alınmış" diye sessizce geçilir.</para>
/// </summary>
public sealed class CihazServisi(VeriKaynagi veri, IEnumerable<ICihazSurucu> surucular,
                                 ILogger<CihazServisi> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly IReadOnlyList<ICihazSurucu> _surucular = [.. surucular];
    private readonly ILogger<CihazServisi> _gunluk = gunluk;

    public sealed record Cihaz(int Id, string Kod, string Ad, string Surucu,
                               short BaglantiTuru, string Adres, int Port,
                               string KlasorYolu, string ArsivKlasoru, string Kodlama,
                               int SubeId);

    public sealed record AlimSonucu(long MesajId, bool Yeni, string Durum, string Mesaj);

    public async Task<List<Cihaz>> CihazlarAsync(short? baglantiTuru, bool yalnizOtomatik,
                                                 CancellationToken iptal)
        => await _veri.ListeAsync("""
            select id, kod, ad, surucu, baglanti_turu, adres, port,
                   klasor_yolu, arsiv_klasoru, kodlama, sube_id
              from public.cihaz
             where durum = 0
               and (@p0::smallint is null or baglanti_turu = @p0)
               and (@p1 = 0 or otomatik = 1)
             order by id
            """, [baglantiTuru, (short)(yalnizOtomatik ? 1 : 0)],
            o => new Cihaz(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3),
                           o.GetInt16(4), o.GetString(5), o.GetInt32(6), o.GetString(7),
                           o.GetString(8), o.GetString(9), o.GetInt32(10)), iptal);

    /// <summary>
    /// Ham mesajı alır: kaydeder, çözümler, kalemleri yazar.
    ///
    /// Çözümleme hatası mesajı DÜŞÜRMEZ - kayıt <c>durum = 4</c> ile kalır,
    /// ham metin ekrandan okunabilir ve sürücü düzeltilince yeniden işlenir.
    /// </summary>
    public async Task<AlimSonucu> AlAsync(int cihazId, string ham, string kaynak,
                                          CancellationToken iptal)
    {
        var cihaz = await _veri.TekAsync("""
            select id, kod, ad, surucu, baglanti_turu, adres, port,
                   klasor_yolu, arsiv_klasoru, kodlama, sube_id
              from public.cihaz where id = @p0 and durum = 0
            """, [cihazId],
            o => new Cihaz(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetString(3),
                           o.GetInt16(4), o.GetString(5), o.GetInt32(6), o.GetString(7),
                           o.GetString(8), o.GetString(9), o.GetInt32(10)), iptal)
            ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı ya da pasif.");

        return await AlAsync(cihaz, ham, kaynak, iptal);
    }

    public async Task<AlimSonucu> AlAsync(Cihaz cihaz, string ham, string kaynak,
                                          CancellationToken iptal)
    {
        var surucu = _surucular.FirstOrDefault(
            s => s.Kod.Equals(cihaz.Surucu, StringComparison.OrdinalIgnoreCase));

        // SÜRÜCÜ YOKSA DA KAYDEDİLİR: veri gelmiş, kaybetmeyelim; mesaj
        //   "hata" durumunda bekler ve sürücü eklenince yeniden işlenir.
        var cozum = surucu?.Coz(ham)
            ?? new CihazMesaji(cihaz.Surucu, "", "", "", "", "", null, [],
                               $"'{cihaz.Surucu}' sürücüsü tanımlı değil.");

        var mesajId = await _veri.TekDegerAsync<long>("""
            insert into public.cihaz_mesaj
                   (cihaz_id, yon, protokol, mesaj_tipi, kontrol_no, ornek_no, istem_no,
                    hasta_no, cihaz_zamani, ham, kaynak, durum, hata, kalem_sayisi, sube_id)
            values (@p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9,
                    case when @p10 = '' then 2 else 4 end, @p10, @p11, @p12)
            on conflict (cihaz_id, kontrol_no) where kontrol_no <> ''
                do nothing
            returning id
            """,
            [cihaz.Id, cozum.Protokol, cozum.MesajTipi, cozum.KontrolNo, cozum.OrnekNo,
             cozum.IstemNo, cozum.HastaNo, cozum.CihazZamani, ham, kaynak,
             cozum.Hata, cozum.Kalemler.Count, cihaz.SubeId], iptal);

        if (mesajId == 0)
        {
            // Benzersiz indeks reddetti: aynı kontrol numarası zaten var.
            _gunluk.LogInformation("Cihaz {Kod}: mesaj zaten alınmış ({No}).",
                                   cihaz.Kod, cozum.KontrolNo);
            return new AlimSonucu(0, false, "mukerrer",
                                  "Bu mesaj daha önce alınmış (aynı kontrol numarası).");
        }

        foreach (var k in cozum.Kalemler)
            await _veri.CalistirAsync("""
                insert into public.cihaz_mesaj_kalem
                       (mesaj_id, sira, test_kodu, test_adi, deger, sayisal, birim,
                        referans, isaret, durum, olcum_zamani, aciklama)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                """,
                [mesajId, k.Sira, k.TestKodu, k.TestAdi, k.Deger, k.Sayisal, k.Birim,
                 k.Referans, k.Isaret, k.Durum, k.OlcumZamani, k.Aciklama], iptal);

        await _veri.CalistirAsync("""
            update public.cihaz set son_mesaj = now(), son_hata = @p1,
                   degistirme_tarihi = now()
             where id = @p0
            """, [cihaz.Id, cozum.Hata], iptal);

        return new AlimSonucu(mesajId, true, cozum.Gecerli ? "cozumlendi" : "hata",
            cozum.Gecerli
                ? $"{cozum.Kalemler.Count} sonuç alındı."
                : $"Mesaj alındı ama çözümlenemedi: {cozum.Hata}");
    }

    /// <summary>
    /// Kaydedilmiş bir mesajı YENİDEN çözümler (sürücü düzeltildikten sonra).
    /// Eski kalemler silinir - birleştirmeye çalışmak eski hatalı satırları
    /// canlı bırakırdı.
    /// </summary>
    public async Task<AlimSonucu> YenidenIsleAsync(long mesajId, CancellationToken iptal)
    {
        var m = await _veri.TekAsync("""
            select m.id, m.ham, c.surucu, c.id
              from public.cihaz_mesaj m join public.cihaz c on c.id = m.cihaz_id
             where m.id = @p0
            """, [mesajId],
            o => new { Id = o.GetInt64(0), Ham = o.GetString(1), Surucu = o.GetString(2),
                       CihazId = o.GetInt32(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Mesaj bulunamadı.");

        var surucu = _surucular.FirstOrDefault(
            s => s.Kod.Equals(m.Surucu, StringComparison.OrdinalIgnoreCase))
            ?? throw GentegreHatasi.IsKurali($"'{m.Surucu}' sürücüsü tanımlı değil.");

        var cozum = surucu.Coz(m.Ham);

        await _veri.CalistirAsync(
            "delete from public.cihaz_mesaj_kalem where mesaj_id = @p0", [mesajId], iptal);

        foreach (var k in cozum.Kalemler)
            await _veri.CalistirAsync("""
                insert into public.cihaz_mesaj_kalem
                       (mesaj_id, sira, test_kodu, test_adi, deger, sayisal, birim,
                        referans, isaret, durum, olcum_zamani, aciklama)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11)
                """,
                [mesajId, k.Sira, k.TestKodu, k.TestAdi, k.Deger, k.Sayisal, k.Birim,
                 k.Referans, k.Isaret, k.Durum, k.OlcumZamani, k.Aciklama], iptal);

        await _veri.CalistirAsync("""
            update public.cihaz_mesaj
               set mesaj_tipi = @p1, kontrol_no = case when kontrol_no = '' then @p2
                                                       else kontrol_no end,
                   ornek_no = @p3, istem_no = @p4, hasta_no = @p5, cihaz_zamani = @p6,
                   kalem_sayisi = @p7, hata = @p8,
                   durum = case when @p8 = '' then 2 else 4 end, islenme = now()
             where id = @p0
            """,
            [mesajId, cozum.MesajTipi, cozum.KontrolNo, cozum.OrnekNo, cozum.IstemNo,
             cozum.HastaNo, cozum.CihazZamani, cozum.Kalemler.Count, cozum.Hata], iptal);

        return new AlimSonucu(mesajId, true, cozum.Gecerli ? "cozumlendi" : "hata",
            cozum.Gecerli ? $"{cozum.Kalemler.Count} sonuç çözümlendi."
                          : $"Çözümlenemedi: {cozum.Hata}");
    }

    /// <summary>
    /// Klasör izleyen cihazların yeni dosyalarını kuyruğa alır.
    ///
    /// İŞLENEN DOSYA TAŞINIR ya da adı işaretlenir: aynı dosyayı her turda
    /// yeniden okumak, aynı sonucu tekrar tekrar kaydetmek olurdu (kontrol
    /// numarası olmayan cihazlarda mükerrer koruması da çalışmaz).
    /// </summary>
    public async Task<(int Okunan, int Hatali)> KlasorleriTaraAsync(CancellationToken iptal)
    {
        var cihazlar = await CihazlarAsync(3, true, iptal);
        int okunan = 0, hatali = 0;

        foreach (var c in cihazlar)
        {
            if (c.KlasorYolu.Length == 0 || !Directory.Exists(c.KlasorYolu))
            {
                await HataYazAsync(c.Id, $"Klasör bulunamadı: {c.KlasorYolu}", iptal);
                hatali++;
                continue;
            }

            foreach (var dosya in Directory.EnumerateFiles(c.KlasorYolu).Take(200))
            {
                if (iptal.IsCancellationRequested) break;
                try
                {
                    var ham = await File.ReadAllTextAsync(dosya, Kodlama(c.Kodlama), iptal);
                    var sonuc = await AlAsync(c, ham, Path.GetFileName(dosya), iptal);
                    if (sonuc.Durum != "mukerrer") okunan++;
                    Arsivle(c, dosya);
                }
                catch (Exception h)
                {
                    hatali++;
                    _gunluk.LogError(h, "Cihaz {Kod}: {Dosya} okunamadı.", c.Kod, dosya);
                    await HataYazAsync(c.Id, $"{Path.GetFileName(dosya)}: {h.Message}", iptal);
                }
            }
        }
        return (okunan, hatali);
    }

    private static Encoding Kodlama(string ad)
    {
        try { return Encoding.GetEncoding(ad.Length == 0 ? "utf-8" : ad); }
        catch { return Encoding.UTF8; }
    }

    private void Arsivle(Cihaz c, string dosya)
    {
        try
        {
            if (c.ArsivKlasoru.Length == 0)
            {
                // Arşiv klasörü yoksa dosya YERİNDE bırakılır ama uzantısı
                //   işaretlenir - bir sonraki turda yeniden okunmasın.
                File.Move(dosya, dosya + ".alindi", overwrite: true);
                return;
            }
            Directory.CreateDirectory(c.ArsivKlasoru);
            File.Move(dosya, Path.Combine(c.ArsivKlasoru, Path.GetFileName(dosya)),
                      overwrite: true);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Cihaz {Kod}: {Dosya} arşivlenemedi.", c.Kod, dosya);
        }
    }

    private async Task HataYazAsync(int cihazId, string hata, CancellationToken iptal)
        => await _veri.CalistirAsync("""
            update public.cihaz set son_hata = @p1, degistirme_tarihi = now()
             where id = @p0
            """, [cihazId, hata.Length > 300 ? hata[..300] : hata], iptal);
}
