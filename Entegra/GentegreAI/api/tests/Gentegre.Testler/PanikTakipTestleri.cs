using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// PANİK DEĞER TAKİBİ (894 — KTS denetim maddesi L2).
///
/// Bildirim YAPILDIĞINDA iz zaten kalıyordu; denetimin asıl sorduğu
/// bildirim YAPILMAZSA ne olduğu. Test üç şeyi tutuyor:
///   * açık panik listesi bekleme süresini ölçüyor mu,
///   * süresi geçen panik hekime bildiriliyor ve YÜKSELTİLİYOR mu,
///   * okuma-geri teyidi alınınca kayıt listeden düşüyor mu (telefonun
///     açılması değil, değerin tekrar edilmesi kapatır).
///
/// Veritabanı yoksa sınıf atlanır (bkz. VeritabaniOlgusu).
/// </summary>
public sealed class PanikTakipTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>90 dakika önce ölçülmüş, bildirilmemiş bir panik sonuç.</summary>
    private static async Task<(int IstemId, int SatirId, long SonucId)>
        DuzenekKurAsync(VeriKaynagi veri, int hekimId)
    {
        var ek = Random.Shared.Next(100000).ToString();
        var tetkikId = await veri.TekDegerAsync<int>(
            "select id from public.lab_tetkik where kod = 'GLU' limit 1", null,
            CancellationToken.None);
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf_hasta order by id limit 1", null,
            CancellationToken.None);

        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik, personel_id)
            values (@p0, 0, 'TEST-PNK-' || @p1, 1, 2, 3, 1, @p2) returning id
            """, [hastaId, ek, hekimId], CancellationToken.None);
        var satirId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
            values (@p0, @p1, 3, 10) returning id
            """, [istemId, tetkikId], CancellationToken.None);
        var sonucId = await veri.TekDegerAsync<long>("""
            insert into public.lab_sonuc
                   (istem_satir_id, tetkik_id, deger_sayisal, deger_metin, birim,
                    bayrak, panik, durum, olcum_zamani, sube_id)
            values (@p0, @p1, 620, '620', 'mg/dL', 'HH', 1, 1,
                    now() - interval '90 minutes', 0)
            returning id
            """, [satirId, tetkikId], CancellationToken.None);

        return (istemId, satirId, sonucId);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int istemId, long sonucId)
    {
        await veri.CalistirAsync("delete from public.bildirim where kaynak_tur = 7 and kaynak_id = @p0",
                                 [(int)sonucId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_panik_bildirim where sonuc_id = @p0",
                                 [sonucId], CancellationToken.None);
        await veri.CalistirAsync("""
            delete from public.lab_sonuc where istem_satir_id in
                   (select id from public.lab_istem_satir where istem_id = @p0)
            """, [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
                                 [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0", [istemId],
                                 CancellationToken.None);
    }

    [VtFact]
    public async Task Bildirilmeyen_panik_HEKIME_gider_ve_YUKSELTILIR()
    {
        if (!_olgu.Baglandi(nameof(Bildirilmeyen_panik_HEKIME_gider_ve_YUKSELTILIR))) return;
        var veri = _olgu.Gerekli();

        // HEKİM GERÇEK BİR PERSONEL OLMALI: `taraf` tablosunun ilk satırı
        //   id = 0 "Tanımsız Cari"dir ve hekim sayılmaz - istemde personel_id
        //   0 kalınca bildirim üretilmez (kurallı davranış, testin hatası).
        var hekimId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where personel = 1 and id > 0 order by id limit 1",
            null, CancellationToken.None);
        var (istemId, _, sonucId) = await DuzenekKurAsync(veri, hekimId);
        try
        {
            // AÇIK PANİK: hiç bildirilmemiş (durum 1) ve süre ÖLÇÜMDEN
            //   başlıyor - onay beklemek bildirimi geciktirmenin gerekçesi
            //   olamaz.
            var acik = await veri.TekAsync("""
                select durum, gecen_dk from public.v_lab_panik_acik where sonuc_id = @p0
                """, [sonucId],
                o => new { Durum = o.GetInt16(0), Dk = o.GetInt32(1) },
                CancellationToken.None);
            Assert.NotNull(acik);
            Assert.Equal(1, acik!.Durum);
            Assert.InRange(acik.Dk, 85, 95);

            await veri.TekAsync("select uyarilan, yukseltilen from public.fn_lab_panik_tara()",
                null, o => new { U = o.GetInt32(0), Y = o.GetInt32(1) }, CancellationToken.None);

            // HEKİME BİLDİRİM: kanal 3 (push) - SMS BİLEREK KULLANILMIYOR,
            //   panik telefonla ve teyitle bildirilir, hasta adı SMS'e
            //   taşınmaz.
            var b = await veri.TekAsync("""
                select kanal, konu, oncelik from public.bildirim
                 where kaynak_tur = 7 and kaynak_id = @p0
                """, [(int)sonucId],
                o => new { Kanal = o.GetInt16(0), Konu = o.GetString(1),
                           Oncelik = o.GetInt16(2) }, CancellationToken.None);
            Assert.NotNull(b);
            Assert.Equal(3, b!.Kanal);
            Assert.Equal(1, b.Oncelik);                 // en yüksek öncelik
            Assert.Contains("PANİK", b.Konu, StringComparison.Ordinal);

            // YÜKSELTME: 90 dk > 60 dk eşiği; bildirim kaydı yoktu, sistem
            //   "bildirilmedi" kaydını açar - yükseltmenin kendisi de olaydır.
            var y = await veri.TekAsync("""
                select yukseltme, bildiren_id, aciklama from public.lab_panik_bildirim
                 where sonuc_id = @p0 order by id desc limit 1
                """, [sonucId],
                o => new { Yukseltme = o.GetInt16(0), Bildiren = o.GetInt32(1),
                           Aciklama = o.GetString(2) }, CancellationToken.None);
            Assert.NotNull(y);
            Assert.Equal(1, y!.Yukseltme);
            Assert.Equal(0, y.Bildiren);                // sistem yazdı
            Assert.Contains("yükseltti", y.Aciklama, StringComparison.OrdinalIgnoreCase);

            // İKİNCİ TUR AYNI KAYDI ÜRETMEZ: iş saat başı çalışıyor.
            await veri.TekAsync("select uyarilan, yukseltilen from public.fn_lab_panik_tara()",
                null, o => new { U = o.GetInt32(0), Y = o.GetInt32(1) }, CancellationToken.None);
            Assert.Equal(1, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.bildirim
                 where kaynak_tur = 7 and kaynak_id = @p0
                """, [(int)sonucId], CancellationToken.None));
        }
        finally { await TemizleAsync(veri, istemId, sonucId); }
    }

    [VtFact]
    public async Task Panik_kaydi_BILDIRIMLE_degil_TEYITLE_kapanir()
    {
        if (!_olgu.Baglandi(nameof(Panik_kaydi_BILDIRIMLE_degil_TEYITLE_kapanir))) return;
        var veri = _olgu.Gerekli();

        // HEKİM GERÇEK BİR PERSONEL OLMALI: `taraf` tablosunun ilk satırı
        //   id = 0 "Tanımsız Cari"dir ve hekim sayılmaz - istemde personel_id
        //   0 kalınca bildirim üretilmez (kurallı davranış, testin hatası).
        var hekimId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where personel = 1 and id > 0 order by id limit 1",
            null, CancellationToken.None);
        var (istemId, _, sonucId) = await DuzenekKurAsync(veri, hekimId);
        try
        {
            var bildirimId = await veri.TekDegerAsync<int>("""
                insert into public.lab_panik_bildirim
                       (sonuc_id, bildiren_id, bildirilen_ad, kanal)
                values (@p0, 1, 'Dr. Test', 1) returning id
                """, [sonucId], CancellationToken.None);

            // BİLDİRİLDİ AMA TEYİT YOK: kayıt hâlâ AÇIK - telefonun açılması,
            //   karşı tarafın değeri tekrar etmesi demek değildir.
            Assert.Equal(2, await veri.TekDegerAsync<short>("""
                select durum from public.v_lab_panik_acik where sonuc_id = @p0
                """, [sonucId], CancellationToken.None));

            await veri.CalistirAsync("""
                update public.lab_panik_bildirim
                   set teyit_zamani = now(), teyit_eden = 'Dr. Test'
                 where id = @p0
                """, [bildirimId], CancellationToken.None);

            // TEYİT ALINDI: panik listeden düşer, kaydı tarihte kalır.
            Assert.Equal(0, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.v_lab_panik_acik where sonuc_id = @p0
                """, [sonucId], CancellationToken.None));
            Assert.Equal(1, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.lab_panik_bildirim
                 where sonuc_id = @p0 and teyit_zamani is not null
                """, [sonucId], CancellationToken.None));

            // Kapanmış panik için tarama bildirim ÜRETMEZ.
            await veri.TekAsync("select uyarilan, yukseltilen from public.fn_lab_panik_tara()",
                null, o => new { U = o.GetInt32(0), Y = o.GetInt32(1) }, CancellationToken.None);
            Assert.Equal(0, await veri.TekDegerAsync<int>("""
                select count(*)::int from public.bildirim
                 where kaynak_tur = 7 and kaynak_id = @p0
                """, [(int)sonucId], CancellationToken.None));
        }
        finally { await TemizleAsync(veri, istemId, sonucId); }
    }
}
