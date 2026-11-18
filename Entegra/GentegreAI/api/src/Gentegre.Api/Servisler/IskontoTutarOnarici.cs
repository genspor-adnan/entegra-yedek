using Gentegre.Cekirdek.Katalog;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// İSKONTO TUTAR ONARIMI (1378, kullanıcı 18.11.2026: "evet onarım adımını hazırla").
///
/// 1377'ye kadar iskonto kararı (dijital zincir / sözlü onay) satıra yalnız ORANI yazıyordu: tutar, ödeme dağılımı ve
/// dip toplam kart yeniden kaydedilene kadar eski kaldı (onaylı %50 iskontolu satır tam fiyatla açık). Bu servis API
/// açılışında BİR KEZ çalışır ve o satırları kart kaydının hesabıyla düzeltir
/// (<see cref="BelgeDeposu.IskontoSonrasiYenileAsync"/>: BelgeHesap.SatirTutari + dağılım + fn_belge_diptoplam).
///
/// Müşteri verisi kuralları (CLAUDE.md): yalnız KANITLI yanlış satır - onaylı (durum 1) talebin KİLİTLİ satırı, tutarı
/// kendi oranıyla hesaplanan tutarı tutmuyor; belge iptal değil. Belgeye DÖNÜŞMÜŞ satırı olan talep ATLANIR ve günlüğe
/// yazılır (o tutarla fiş / fatura kesilmiş - elle karar). Dokunmadan önce eski hâl `iskonto_tutar_onarim_yedek`e.
/// Düzeltilen satır artık tutarsız olmadığından yeniden koşması güvenlidir (idempotent); talep başına ayrı işlem -
/// biri düşerse ötekiler yine düzelir.
///
/// BİR KEZ (kod inceleme 18.11.2026): ilk tam turdan sonra `referans` 'sistem.iskonto_tutar_onarim_1378' işareti yazılır;
/// sonraki açılışlar tarama yapmaz (her yeniden başlatmada bütün onaylı satırları taramak boşa iş). İşaret silinirse
/// bir sonraki açılışta yeniden çalışır. Test ve elle çağrı <see cref="OnarAsync"/> ile işarete bakmadan koşar.
/// </summary>
public sealed class IskontoTutarOnarici(IServiceProvider servisler, ILogger<IskontoTutarOnarici> gunluk) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        try
        {
            await using var kapsam = servisler.CreateAsyncScope();
            var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();
            var depo = kapsam.ServiceProvider.GetRequiredService<BelgeDeposu>();
            if (await veri.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0", [Isaret], iptal) is not null)
                return;
            var (onarilan, atlanan, hatali) = await OnarAsync(veri, depo, gunluk, iptal);
            // İŞARET YALNIZ HATASIZ TURDA (yayın 18.11.2026): yetki / bağlantı hatası alan talep bir sonraki açılışta
            //   yeniden denenir; hata alındı diye "bir kez çalıştı" sayılmaz.
            if (hatali > 0)
            {
                gunluk.LogWarning("İskonto tutar onarımı: {H} talep hata aldı - bir sonraki açılışta yeniden denenecek.", hatali);
                return;
            }
            await veri.CalistirAsync(
                "insert into public.referans (anahtar, deger, tip, kapsam, aciklama) values (@p0, @p1, 'metin', 'sistem', "
                + "'IskontoTutarOnarici (1378) bir kez çalıştı') on conflict (anahtar) do nothing",
                [Isaret, $"{DateTime.UtcNow:yyyy-MM-dd HH:mm} · {onarilan} düzeltildi · {atlanan} atlandı"], iptal);
            if (onarilan + atlanan > 0)
                gunluk.LogWarning("İskonto tutar onarımı: {O} talep düzeltildi, {A} talep belgeye dönüştüğü için atlandı.",
                    onarilan, atlanan);
        }
        catch (OperationCanceledException) when (iptal.IsCancellationRequested) { }
        catch (Exception h) { gunluk.LogError(h, "İskonto tutar onarımı başarısız."); }
    }

    /// <summary>Bir kez çalıştı işareti (referans anahtarı).</summary>
    public const string Isaret = "sistem.iskonto_tutar_onarim_1378";

    /// <summary>Tek tur: (düzeltilen, dönüştüğü için atlanan, hata alan talep). Test ve elle çağrı için açık.</summary>
    public static async Task<(int Onarilan, int Atlanan, int Hatali)> OnarAsync(VeriKaynagi veri, BelgeDeposu depo, ILogger gunluk,
        CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        if (await b.TekDegerAsync<string>("select to_regclass('public.iskonto_tutar_onarim_yedek')::text", null, null, iptal) is null)
            return (0, 0, 0);                                 // göç henüz uygulanmamış

        var adaylar = await b.ListeAsync("""
            select t.id, s.id, coalesce(s.adet, 0), coalesce(s.birim_fiyat, 0), coalesce(s.iskonto, 0),
                   coalesce(s.iskonto2, 0), coalesce(s.tutar, 0),
                   -- TALEBİN HERHANGİ BİR SATIRI dönüşmüşse (kod inceleme 18.11.2026): yenileme talebin bütün satırlarını
                   --   yeniden yazar; yalnız aday satıra bakmak, sonra başka talepte onaylanıp fişe dönüşen satırı kaçırıyordu.
                   exists (select 1 from public.iskonto_talep_satir tx
                             join public.belge_satir sx on sx.id = tx.belge_satir_id
                            where tx.talep_id = t.id
                              and (coalesce(sx.kapatilan_miktar, 0) > 0
                                   or exists (select 1 from public.belge_satir h
                                               where h.kaynak_tur = 30 and h.kaynak_id = sx.id))) as donustu
              from public.iskonto_talep t
              join public.iskonto_talep_satir ts on ts.talep_id = t.id
              join public.belge_satir s on s.id = ts.belge_satir_id
              join public.belge be on be.id = s.belge_id
             where t.durum = 1 and coalesce(s.iskonto_kilit, 0) = 1 and be.durum <> 6
               -- Satırı en son kilitleyen talep (sonraki onay oranı değiştirdiyse eskisi değil).
               and t.id = (select max(ts2.talep_id) from public.iskonto_talep_satir ts2
                             join public.iskonto_talep t2 on t2.id = ts2.talep_id and t2.durum = 1
                            where ts2.belge_satir_id = s.id)
            """, null, null, o => new
            {
                Talep = o.GetInt32(0), Satir = o.GetInt32(1), Adet = o.GetDecimal(2), Fiyat = o.GetDecimal(3),
                Isk = o.GetDecimal(4), Isk2 = o.GetDecimal(5), Tutar = o.GetDecimal(6), Donustu = o.GetBoolean(7),
            }, iptal);

        // KANIT: kayıtlı tutar, satırın kendi oranıyla hesaplanan tutarı tutmuyor (kart kaydının formülü).
        var yanlis = adaylar
            .Where(a => Math.Abs(a.Tutar - BelgeHesap.SatirTutari(a.Adet, a.Fiyat, a.Isk, a.Isk2)) > 0.005m)
            .GroupBy(a => a.Talep).ToList();

        int onarilan = 0, atlanan = 0, hatali = 0;
        foreach (var g in yanlis)
        {
            // Talebin HERHANGİ bir satırı dönüşmüşse talep atlanır (aynı talebin satırlarını yarım düzeltmeyelim).
            if (adaylar.Any(a => a.Talep == g.Key && a.Donustu))
            {
                atlanan++;
                gunluk.LogWarning("İskonto tutar onarımı: talep {T} atlandı - satırı belgeye dönüşmüş, elle kontrol edin.", g.Key);
                continue;
            }
            try
            {
                await using var islem = await b.BeginTransactionAsync(iptal);
                await b.CalistirAsync("""
                    insert into public.iskonto_tutar_onarim_yedek
                           (talep_id, belge_id, belge_satir_id, eski_tutar, eski_tutar_kdvli, eski_doviz_tutari,
                            eski_dagilim, eski_genel_toplam)
                    select @p0, s.belge_id, s.id, s.tutar, s.tutar_kdvli, s.doviz_tutari,
                           (select to_jsonb(d) from public.belge_satir_dagilim d where d.belge_satir_id = s.id),
                           (select be.genel_toplam from public.belge be where be.id = s.belge_id)
                      from public.iskonto_talep_satir ts join public.belge_satir s on s.id = ts.belge_satir_id
                     where ts.talep_id = @p0
                    """, islem, [g.Key], iptal);
                await depo.IskontoSonrasiYenileAsync(b, islem, g.Key, iptal);
                await islem.CommitAsync(iptal);
                onarilan++;
            }
            // Talep başına ayrı işlem: biri (ör. Delphi kaynaklı salt-okunur satır, 1089) düşerse ötekiler sürer.
            catch (Exception h) when (h is not OperationCanceledException)
            {
                hatali++;
                gunluk.LogWarning(h, "İskonto tutar onarımı: talep {T} düzeltilemedi.", g.Key);
            }
        }
        return (onarilan, atlanan, hatali);
    }
}
