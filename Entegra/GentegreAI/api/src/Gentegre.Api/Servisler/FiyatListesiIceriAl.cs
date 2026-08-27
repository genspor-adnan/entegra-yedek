using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// FIYAT LISTESINE EXCEL'DEN ICERI ALMA.
///
/// Sozlesme = SABLON (ayni sutunlar disari da verilir; "indir -> Excel'de
/// duzelt -> geri yukle" akisi tek bicim uzerinden doner):
///
///   Stok Kodu | Hizmet Kodu | Kod | Adı | Fiyat | Döviz | KDV | Birim | Durum
///
///  - Kalem "Stok Kodu" YA DA "Hizmet Kodu" ile gelir (tam biri). Musteri
///    dokumlerindeki tek "KOD" sutunu da kabul edilir: once stokta, yoksa
///    hizmette aranir; IKISINDE de varsa satir hatasi (belirsizlik sessiz
///    yanlis kaleme fiyat yazdirir).
///  - "Adı" YOK SAYILIR - insan icin tasinir, esleme koddan.
///  - YA HEP YA HIC: once TUM satirlar dogrulanir; tek hata bile varsa hicbir
///    sey yazilmaz ve satir numarali hata listesi doner. Upsert sayesinde
///    duzelt-tekrar-yukle bedava; yarim iceri alma "hangi satir girdi"
///    belirsizligi yaratir.
///  - Yazilan satir MANUEL (yazim = 1) sayilir: "Listeyi Üret" iceri alinan
///    fiyati ezmez (201/202 kurali).
/// </summary>
public static class FiyatListesiIceriAl
{
    public sealed record SatirHatasi(int SatirNo, string Alan, string Mesaj);

    public sealed record Sonuc(int Eklenen, int Guncellenen, int Toplam,
                               IReadOnlyList<SatirHatasi> Hatalar, int ToplamHata);

    /// <summary>Sablonun sutun basliklari - disa aktarim da ayni sirayi kullanir.</summary>
    public static readonly string[] SablonBasliklari =
        { "Stok Kodu", "Hizmet Kodu", "Adı", "Fiyat", "Döviz", "KDV", "Birim", "Durum" };

    private sealed record HamSatir(int SatirNo, int? StokId, int? HizmetId,
                                   decimal Fiyat, string Doviz, short KdvDahil,
                                   short Birim, short Durum);

    public static async Task<Sonuc> CalistirAsync(
        NpgsqlConnection baglanti, int listeId, short listeKdvDahil,
        ExcelOkuma.Sayfa sayfa, int kullaniciId, CancellationToken iptal)
    {
        // ---- 1) baslik eslestirme ------------------------------------------
        // Basliklar SAYFANIN baslik satirindan kontrol edilir, veri satirindan
        //   degil - bos dosyada "kalem sutunu yok" gibi yaniltici mesaj cikmasin.
        string A(string s) => ExcelOkuma.BaslikAnahtari(s);
        var baslikKumesi = sayfa.Basliklar.Select(A).ToHashSet(StringComparer.Ordinal);
        bool Basl(string ad) => baslikKumesi.Contains(A(ad));

        var stokKoduVar   = Basl("Stok Kodu");
        var hizmetKoduVar = Basl("Hizmet Kodu");
        var tekKodVar     = Basl("Kod");
        if (!stokKoduVar && !hizmetKoduVar && !tekKodVar)
            throw GentegreHatasi.Dogrulama(
                "Dosyada kalem sütunu yok: \"Stok Kodu\", \"Hizmet Kodu\" ya da \"Kod\" başlığı gerekli.",
                new AlanHatasi("dosya", "Kalem sütunu bulunamadı."));
        if (!Basl("Fiyat"))
            throw GentegreHatasi.Dogrulama("Dosyada \"Fiyat\" sütunu yok.",
                new AlanHatasi("dosya", "Fiyat sütunu bulunamadı."));

        string Hucre(Dictionary<string, string> h, string ad)
            => h.TryGetValue(A(ad), out var v) ? v : "";

        // ---- 2) kod -> id sozlukleri (tek sorguyla, yalniz dosyadaki kodlar) ---
        var kodlar = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var (_, h) in sayfa.Satirlar)
        {
            foreach (var ad in new[] { "Stok Kodu", "Hizmet Kodu", "Kod" })
            {
                var k = Hucre(h, ad);
                if (k.Length > 0) kodlar.Add(k);
            }
        }
        var kodDizi = kodlar.ToArray();

        var stokSozluk = new Dictionary<string, (int Id, short AnaBirim)>(StringComparer.OrdinalIgnoreCase);
        await using (var k = baglanti.Komut(
            "select kod, id, ana_birim from public.stok where durum = 1 and kod = any(@p0)",
            null, (object?)kodDizi))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                stokSozluk[o.GetString(0)] = (o.GetInt32(1), o.GetInt16(2));

        var hizmetSozluk = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        await using (var k = baglanti.Komut(
            "select kod, id from public.hizmet where durum = 1 and coalesce(baslik_mi, 0) = 0 and kod = any(@p0)",
            null, (object?)kodDizi))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                hizmetSozluk[o.GetString(0)] = o.GetInt32(1);

        // Birim: "Adet"/"Kg" adi -> kod. Ayni ada iki kod dusme olasiligina
        //   karsi ILK kazanir (kod listesi zaten tekil ad tasiyor).
        var birimSozluk = new Dictionary<string, short>(StringComparer.OrdinalIgnoreCase);
        await using (var k = baglanti.Komut("""
            select kd.ad, kd.deger from public.kod_deger kd
              join public.kod_liste kl on kl.id = kd.liste_id
             where kl.kod = 'stok.ana_birim' and kd.aktif = 1
            """, null))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal))
                birimSozluk.TryAdd(o.GetString(0), (short)o.GetInt32(1));

        // ---- 3) satir dogrulama --------------------------------------------
        var hatalar = new List<SatirHatasi>();
        var temiz = new List<HamSatir>();
        // Ayni dosyada ayni kalem iki kez gelirse SON satir kazanmasin - iki
        //   satir ayni upsert anahtarina duser ve "affected rows" sayimi yalan
        //   soyler. Erken yakala.
        var gorulen = new HashSet<(int?, int?, short, string)>();

        foreach (var (satirNo, h) in sayfa.Satirlar)
        {
            void Hata(string alan, string mesaj) => hatalar.Add(new SatirHatasi(satirNo, alan, mesaj));

            var stokKodu   = Hucre(h, "Stok Kodu");
            var hizmetKodu = Hucre(h, "Hizmet Kodu");
            var tekKod     = Hucre(h, "Kod");

            int? stokId = null, hizmetId = null;
            short anaBirim = 0;

            if (stokKodu.Length > 0 && hizmetKodu.Length > 0)
            { Hata("kalem", "Hem Stok Kodu hem Hizmet Kodu dolu; tam biri olmalı."); continue; }

            if (stokKodu.Length > 0)
            {
                if (stokSozluk.TryGetValue(stokKodu, out var s)) { stokId = s.Id; anaBirim = s.AnaBirim; }
                else { Hata("Stok Kodu", $"\"{stokKodu}\" aktif stoklarda bulunamadı."); continue; }
            }
            else if (hizmetKodu.Length > 0)
            {
                if (hizmetSozluk.TryGetValue(hizmetKodu, out var hid)) hizmetId = hid;
                else { Hata("Hizmet Kodu", $"\"{hizmetKodu}\" aktif hizmetlerde bulunamadı."); continue; }
            }
            else if (tekKod.Length > 0)
            {
                var stokta = stokSozluk.TryGetValue(tekKod, out var s2);
                var hizmette = hizmetSozluk.TryGetValue(tekKod, out var hid2);
                if (stokta && hizmette)
                { Hata("Kod", $"\"{tekKod}\" hem stokta hem hizmette var; \"Stok Kodu\" ya da \"Hizmet Kodu\" sütunu kullanın."); continue; }
                if (stokta) { stokId = s2.Id; anaBirim = s2.AnaBirim; }
                else if (hizmette) hizmetId = hid2;
                else { Hata("Kod", $"\"{tekKod}\" stok ve hizmetlerde bulunamadı."); continue; }
            }
            else { Hata("kalem", "Kalem kodu boş."); continue; }

            // Fiyat. Excel hucresi SAYI ise ExcelOkuma zaten invariant metin
            //   verir; kullanici hucreye METIN olarak TR bicimi yazdiysa
            //   ("1.234,56") once invariant'a cevrilir - DegerCevirici yalniz
            //   nokta-ondalik taniyor ve kart ekranlari icin bu dogru, ona
            //   dokunulmaz.
            decimal fiyat;
            try
            {
                fiyat = Convert.ToDecimal(DegerCevirici.Cevir(
                    TrSayiyiDuzelt(Hucre(h, "Fiyat")), "para", "fiyat", "Fiyat"));
            }
            catch (GentegreHatasi g) { Hata("Fiyat", g.Message); continue; }
            if (fiyat <= 0) { Hata("Fiyat", "Fiyat sıfırdan büyük olmalı."); continue; }

            var doviz = Hucre(h, "Döviz");
            if (doviz.Length == 0) doviz = "TL";
            if (doviz.Length > 5) { Hata("Döviz", $"\"{doviz}\" en fazla 5 karakter olabilir."); continue; }

            // KDV: "Dahil"/"Hariç"/1/0; bos -> listenin varsayilani.
            short kdv;
            var kdvMetni = Hucre(h, "KDV");
            switch (ExcelOkuma.BaslikAnahtari(kdvMetni))
            {
                case "": kdv = listeKdvDahil; break;
                case "DAHİL" or "DAHIL" or "1": kdv = 1; break;
                case "HARİÇ" or "HARIC" or "0": kdv = 0; break;
                default: Hata("KDV", $"\"{kdvMetni}\" çözülemedi; Dahil / Hariç yazın."); continue;
            }

            // Birim: ad ya da kod; bos -> stokun kendi ana birimi (hizmette 0).
            short birim = anaBirim;
            var birimMetni = Hucre(h, "Birim");
            if (birimMetni.Length > 0)
            {
                if (birimSozluk.TryGetValue(birimMetni, out var bk)) birim = bk;
                else if (short.TryParse(birimMetni, out var bs)) birim = bs;
                else { Hata("Birim", $"\"{birimMetni}\" birim listesinde bulunamadı."); continue; }
            }

            short durum;
            var durumMetni = Hucre(h, "Durum");
            switch (ExcelOkuma.BaslikAnahtari(durumMetni))
            {
                case "" or "AKTİF" or "AKTIF" or "1": durum = 1; break;
                case "PASİF" or "PASIF" or "0": durum = 0; break;
                default: Hata("Durum", $"\"{durumMetni}\" çözülemedi; Aktif / Pasif yazın."); continue;
            }

            if (!gorulen.Add((stokId, hizmetId, birim, doviz.ToUpperInvariant())))
            { Hata("kalem", "Aynı kalem (aynı birim ve döviz) dosyada birden çok kez geçiyor."); continue; }

            temiz.Add(new HamSatir(satirNo, stokId, hizmetId, fiyat, doviz, kdv, birim, durum));
        }

        // ---- 4) ya hep ya hic ----------------------------------------------
        if (hatalar.Count > 0)
            return new Sonuc(0, 0, sayfa.Satirlar.Count,
                             hatalar.Take(50).ToList(), hatalar.Count);
        if (temiz.Count == 0)
            throw GentegreHatasi.Dogrulama("Dosyada içeri alınacak satır yok.",
                new AlanHatasi("dosya", "Veri satırı bulunamadı."));

        // ---- 5) tek transaction'da upsert ----------------------------------
        // Stok ve hizmet satirlari IKI AYRI deyim: iki partial unique index tek
        //   `on conflict` ile inference edilemez. `xmax = 0` eklenen/guncellenen
        //   ayrimini verir (insert edilen satirda xmax 0'dir).
        var eklenen = 0; var guncellenen = 0;
        await using (var islem = await baglanti.BeginTransactionAsync(iptal))
        {
            foreach (var s in temiz)
            {
                var sql = s.StokId is not null
                    ? """
                      insert into public.fiyat_listesi_satir
                          (liste_id, stok_id, fiyat, doviz_cinsi, kdv_dahil, birim, durum,
                           yazim, taban_fiyat, ekleyen, degistiren)
                      values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p2, @p7, @p7)
                      on conflict (liste_id, stok_id, birim, doviz_cinsi) where stok_id is not null
                      do update set fiyat = excluded.fiyat, kdv_dahil = excluded.kdv_dahil,
                                    durum = excluded.durum, yazim = 1, degistiren = excluded.degistiren
                      returning (xmax = 0) as yeni
                      """
                    : """
                      insert into public.fiyat_listesi_satir
                          (liste_id, hizmet_id, fiyat, doviz_cinsi, kdv_dahil, birim, durum,
                           yazim, taban_fiyat, ekleyen, degistiren)
                      values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 1, @p2, @p7, @p7)
                      on conflict (liste_id, hizmet_id, doviz_cinsi) where hizmet_id is not null
                      do update set fiyat = excluded.fiyat, kdv_dahil = excluded.kdv_dahil,
                                    durum = excluded.durum, birim = excluded.birim,
                                    yazim = 1, degistiren = excluded.degistiren
                      returning (xmax = 0) as yeni
                      """;

                await using var komut = baglanti.Komut(sql, islem,
                    listeId, (object?)s.StokId ?? s.HizmetId, s.Fiyat, s.Doviz,
                    s.KdvDahil, s.Birim, s.Durum, kullaniciId);
                var yeni = (bool)(await komut.ExecuteScalarAsync(iptal))!;
                if (yeni) eklenen++; else guncellenen++;
            }
            await islem.CommitAsync(iptal);
        }

        return new Sonuc(eklenen, guncellenen, temiz.Count, Array.Empty<SatirHatasi>(), 0);
    }

    /// <summary>
    /// TR sayi bicimini invariant'a cevirir: VIRGUL varsa noktalar BINLIK
    /// sayilip atilir, virgul ondalik olur ("1.234,56" -> "1234.56").
    /// Virgul yoksa metin oldugu gibi kalir (nokta ondaliktir) - web'deki
    /// sayiOku / hamSayi ayrimiyla ayni kural.
    /// </summary>
    private static string TrSayiyiDuzelt(string metin)
        => metin.Contains(',')
            ? metin.Replace(".", "").Replace(',', '.')
            : metin;

    // ------------------------------------------------------------- sablon ----
    /// <summary>Bos sablon: baslik + iki ornek satir.</summary>
    public static byte[] BosSablon()
        => ExcelOkuma.Yaz("Fiyat Listesi", SablonBasliklari, new List<IReadOnlyList<object?>>
        {
            new object?[] { "STK-001", "", "(örnek stok — Adı sütunu yok sayılır)", 1250.50m, "TL", "Hariç", "Adet", "Aktif" },
            new object?[] { "", "HZM-001", "(örnek hizmet)", 900m, "TL", "Dahil", "", "Aktif" },
        });
}
