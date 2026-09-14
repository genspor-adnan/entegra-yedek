using Gentegre.Api.AraKatman;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Microsoft.Extensions.Logging.Abstractions;

namespace Gentegre.Testler;

/// <summary>
/// DIŞ KURUM NUMUNESİNİN ÜCRETLENDİRİLMESİ (kullanıcı akışı).
///
/// İstem kaydedilince gönderen kuruma başvuru açılır, tetkikler ücret
/// satırı olur; sonradan tetkik eklenirse AYNI başvuruya girer; istem
/// "Sonuçlandı" olunca başvuru satış tahakkukuna çevrilip kapanır.
///
/// Buradaki bir hata MALİ kayıt üretir: aynı numuneyi iki kez faturalamak
/// ya da yanlış cariye borç yazmak. Test gerçek veritabanına yazar ve
/// kendi kayıtlarını siler.
/// </summary>
public sealed class DisKurumBasvurusuTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static IstekBaglami Baglam() => new()
    {
        KullaniciId = 1, RolId = 1, SubeId = 1,
        Yetkiler = new YetkiSeti(1, [new YetkiKaydi("belge", 0, true, true, true, true)], []),
    };

    private static DisKurumBasvurusu Servis(VeriKaynagi veri)
        => new(veri, new BelgeDeposu(veri, new LogDeposu()),
               NullLogger<DisKurumBasvurusu>.Instance);

    /// <summary>Test kurumu + hasta + iki tetkikli dış kurum istemi.</summary>
    private static async Task<(int IstemId, int KurumId, int[] TetkikIdler)>
        DuzenekKurAsync(VeriKaynagi veri)
    {
        var damga = Guid.NewGuid().ToString("N")[..8];
        // Ödeyen taraf KURUM olmalı (DB tetiği `taraf_kurum` kaydı arar):
        //   gerçek akışta dış kurum "Anlaşmalı Kurumlar" kartından seçiliyor.
        var kurumId = await veri.TekDegerAsync<int>("""
            insert into public.taraf (kod, unvan, musteri, kurum, durum, sube_id)
            values ('TEST-DK-' || @p0, 'TEST Dış Kurum ' || @p0, 1, 1, 1, 1)
            returning id
            """, [damga], CancellationToken.None);
        await veri.CalistirAsync(
            "insert into public.taraf_kurum (id, tur) values (@p0, 1)",
            [kurumId], CancellationToken.None);

        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where hasta = 1 order by id limit 1", null,
            CancellationToken.None);

        // Fiyatı OLAN iki tetkik: ücret satırının tutarı sıfır çıkmasın.
        var tetkikler = await veri.ListeAsync("""
            select t.id from public.lab_tetkik t
             where t.hizmet_id is not null
               and exists (select 1 from public.fiyat_listesi_satir f
                            join public.fiyat_listesi l on l.id = f.liste_id
                                 and l.varsayilan = 1
                           where f.hizmet_id = t.hizmet_id and coalesce(f.fiyat, 0) > 0)
             order by t.id limit 2
            """, null, o => o.GetInt32(0), CancellationToken.None);

        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik,
                    dis_kurum_id, istem_tarihi)
            values (@p0, 1, 'TEST-DK-' || @p1, 1, 2, 4, 1, @p2, now())
            returning id
            """, [hastaId, damga, kurumId], CancellationToken.None);

        foreach (var (t, i) in tetkikler.Select((t, i) => (t, i)))
            await veri.CalistirAsync("""
                insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
                values (@p0, @p1, 1, @p2)
                """, [istemId, t, (short)((i + 1) * 10)], CancellationToken.None);

        return (istemId, kurumId, [.. tetkikler]);
    }

    private static async Task TemizleAsync(VeriKaynagi veri, int istemId, int kurumId)
    {
        var belgeler = await veri.ListeAsync("""
            select id from public.belge
             where id in (select belge_id from public.lab_istem where id = @p0)
                or kaynak_id in (select belge_id from public.lab_istem where id = @p0)
                or taraf_id = @p1
            """, [istemId, kurumId], o => o.GetInt32(0), CancellationToken.None);

        foreach (var b in belgeler)
        {
            await veri.CalistirAsync("delete from public.belge_satir where belge_id = @p0",
                [b], CancellationToken.None);
            await veri.CalistirAsync("delete from public.belge_basvuru where id = @p0",
                [b], CancellationToken.None);
            await veri.CalistirAsync("delete from public.mali_hareket where belge_id = @p0",
                [b], CancellationToken.None);
            await veri.CalistirAsync("delete from public.belge where id = @p0",
                [b], CancellationToken.None);
        }
        await veri.CalistirAsync("delete from public.lab_istem_satir where istem_id = @p0",
            [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.lab_istem where id = @p0",
            [istemId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.taraf_kurum where id = @p0",
            [kurumId], CancellationToken.None);
        await veri.CalistirAsync("delete from public.taraf where id = @p0",
            [kurumId], CancellationToken.None);
    }

    [Fact]
    public async Task Dis_kurum_istemi_BASVURU_acar_ve_tetkikleri_ucretlendirir()
    {
        if (!_olgu.Baglandi(nameof(Dis_kurum_istemi_BASVURU_acar_ve_tetkikleri_ucretlendirir)))
            return;
        var veri = _olgu.Gerekli();
        var (istemId, kurumId, tetkikler) = await DuzenekKurAsync(veri);
        try
        {
            await Servis(veri).TazeleAsync(istemId, Baglam(), CancellationToken.None);

            var belge = await veri.TekAsync("""
                select b.id, b.tur, b.tipi, b.taraf_id, coalesce(b.genel_toplam, 0),
                       coalesce(bb.odeyen_kurum_id, 0), coalesce(bb.hasta_id, 0)
                  from public.lab_istem i
                  join public.belge b on b.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = b.id
                 where i.id = @p0
                """, [istemId],
                o => new { Id = o.GetInt32(0), Tur = o.GetInt32(1), Tipi = o.GetInt32(2),
                           TarafId = o.GetInt32(3), Toplam = o.GetDecimal(4),
                           Odeyen = o.GetInt32(5), HastaId = o.GetInt32(6) },
                CancellationToken.None);

            Assert.NotNull(belge);
            Assert.Equal(19, belge!.Tur);                 // başvuru
            Assert.Equal(30, belge.Tipi);                 // hasta başvurusu tipi
            // CARİ DIŞ KURUM: hastanın ekstresine doğmayacak borç yazılmamalı.
            Assert.Equal(kurumId, belge.TarafId);
            Assert.Equal(kurumId, belge.Odeyen);
            Assert.True(belge.Toplam > 0, "Ücret satırı tutarsız açıldı.");
            // HASTA KAYBOLMAZ (658): cari kurum, hasta ayrı alanda -
            //   başvuruya bakan kişi numunenin kime ait olduğunu görmeli.
            var hastaId = await veri.TekDegerAsync<int>(
                "select taraf_id from public.lab_istem where id = @p0", [istemId],
                CancellationToken.None);
            Assert.Equal(hastaId, belge.HastaId);

            var satir = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.belge_satir where belge_id = @p0",
                [belge.Id], CancellationToken.None);
            Assert.Equal(tetkikler.Length, satir);
        }
        finally { await TemizleAsync(veri, istemId, kurumId); }
    }

    [Fact]
    public async Task Ikinci_kayit_MUKERRER_satir_yazmaz_yeni_tetkigi_ekler()
    {
        if (!_olgu.Baglandi(nameof(Ikinci_kayit_MUKERRER_satir_yazmaz_yeni_tetkigi_ekler)))
            return;
        var veri = _olgu.Gerekli();
        var (istemId, kurumId, tetkikler) = await DuzenekKurAsync(veri);
        try
        {
            var servis = Servis(veri);
            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);
            // Aynı istem yeniden kaydedildi: satır SAYISI değişmemeli -
            //   yoksa aynı numune iki kez faturalanırdı.
            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);

            var belgeId = await veri.TekDegerAsync<int>(
                "select belge_id from public.lab_istem where id = @p0", [istemId],
                CancellationToken.None);
            var sayi = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.belge_satir where belge_id = @p0",
                [belgeId], CancellationToken.None);
            Assert.Equal(tetkikler.Length, sayi);

            // SONRADAN TETKİK EKLENDİ: aynı başvuruya girmeli.
            var yeniTetkik = await veri.TekDegerAsync<int>("""
                select t.id from public.lab_tetkik t
                 where t.hizmet_id is not null and t.id <> all(@p0)
                   and exists (select 1 from public.fiyat_listesi_satir f
                                join public.fiyat_listesi l on l.id = f.liste_id
                                     and l.varsayilan = 1
                               where f.hizmet_id = t.hizmet_id and coalesce(f.fiyat, 0) > 0)
                 order by t.id limit 1
                """, [tetkikler], CancellationToken.None);
            await veri.CalistirAsync("""
                insert into public.lab_istem_satir (istem_id, tetkik_id, durum, sira)
                values (@p0, @p1, 1, 90)
                """, [istemId, yeniTetkik], CancellationToken.None);

            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);

            var sayi2 = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.belge_satir where belge_id = @p0",
                [belgeId], CancellationToken.None);
            Assert.Equal(tetkikler.Length + 1, sayi2);
        }
        finally { await TemizleAsync(veri, istemId, kurumId); }
    }

    [Fact]
    public async Task Sonuclandi_durumunda_KURUMA_TAHAKKUK_kesilir()
    {
        if (!_olgu.Baglandi(nameof(Sonuclandi_durumunda_KURUMA_TAHAKKUK_kesilir))) return;
        var veri = _olgu.Gerekli();
        var (istemId, kurumId, _) = await DuzenekKurAsync(veri);
        try
        {
            var servis = Servis(veri);
            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);

            var belgeId = await veri.TekDegerAsync<int>(
                "select belge_id from public.lab_istem where id = @p0", [istemId],
                CancellationToken.None);

            // Sonuçlandı (4) olarak kaydedildi.
            await veri.CalistirAsync("update public.lab_istem set durum = 4 where id = @p0",
                [istemId], CancellationToken.None);
            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);

            var tahakkuk = await veri.TekAsync("""
                select b.id, b.tur, b.taraf_id
                  from public.belge b
                 where b.kaynak_id = @p0 and b.tur = 17
                 order by b.id desc limit 1
                """, [belgeId],
                o => new { Id = o.GetInt32(0), Tur = o.GetInt32(1), TarafId = o.GetInt32(2) },
                CancellationToken.None);

            Assert.NotNull(tahakkuk);
            Assert.Equal(kurumId, tahakkuk!.TarafId);     // borç KURUMUN

            // Başvuru kapandı: kapanma_durum > 0.
            var kapanma = await veri.TekDegerAsync<int>(
                "select coalesce(kapanma_durum, 0) from public.belge where id = @p0",
                [belgeId], CancellationToken.None);
            Assert.True(kapanma > 0, "Başvuru tahakkuktan sonra kapanmadı.");

            // İKİNCİ KEZ tahakkuk kesilmemeli: kuruma iki kez borç yazılırdı.
            await servis.TazeleAsync(istemId, Baglam(), CancellationToken.None);
            var adet = await veri.TekDegerAsync<int>(
                "select count(*)::int from public.belge where kaynak_id = @p0 and tur = 17",
                [belgeId], CancellationToken.None);
            Assert.Equal(1, adet);
        }
        finally { await TemizleAsync(veri, istemId, kurumId); }
    }

    [Fact]
    public async Task Dis_kurum_OLMAYAN_istemde_basvuru_acilmaz()
    {
        if (!_olgu.Baglandi(nameof(Dis_kurum_OLMAYAN_istemde_basvuru_acilmaz))) return;
        var veri = _olgu.Gerekli();
        var hastaId = await veri.TekDegerAsync<int>(
            "select id from public.taraf where hasta = 1 order by id limit 1", null,
            CancellationToken.None);
        var istemId = await veri.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (taraf_id, sube_id, istem_no, bolum, durum, kaynak, oncelik)
            values (@p0, 1, 'TEST-BANKO-' || floor(random() * 100000)::text, 1, 2, 3, 1)
            returning id
            """, [hastaId], CancellationToken.None);
        try
        {
            var sonuc = await Servis(veri).TazeleAsync(istemId, Baglam(), CancellationToken.None);
            Assert.Null(sonuc);
            var belge = await veri.TekDegerAsync<int?>(
                "select belge_id from public.lab_istem where id = @p0", [istemId],
                CancellationToken.None);
            Assert.Null(belge);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.lab_istem where id = @p0",
                [istemId], CancellationToken.None);
        }
    }
}
