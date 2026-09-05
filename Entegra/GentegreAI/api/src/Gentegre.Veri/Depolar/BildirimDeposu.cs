using Gentegre.Cekirdek.Bildirim;
using Npgsql;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// BİLDİRİM KUYRUĞU (399) — kuyruğa koyma, sıradakini KİLİTLEYEREK alma ve
/// sonucu yazma.
///
/// Kuyruğu birden çok işçi (ya da yeniden başlayan tek işçi) tüketebilir;
/// bu yüzden alma işlemi <c>for update skip locked</c> ile yapılır: iki işçi
/// aynı satırı alıp aynı SMS'i iki kez göndermez. Satır alınır alınmaz
/// durumu 2 (Gönderiliyor) olur — işçi çökse bile satır "kuyrukta" görünüp
/// ikinci kez gönderilmez; askıda kalanı <see cref="AskidakileriKurtarAsync"/>
/// geri alır.
/// </summary>
public sealed class BildirimDeposu
{
    private readonly VeriKaynagi _veri;
    public BildirimDeposu(VeriKaynagi veri) => _veri = veri;

    // ------------------------------------------------------------- kuyruğa ekle
    /// <summary>
    /// Kuyruğa bir bildirim koyar. Şablon kodu verildiyse kanal/konu/gövde
    /// şablondan gelir ve <c>{{degisken}}</c>'ler doldurulur.
    /// Şablon pasifse (durum 0) kayıt AÇILMAZ: kapatılmış bildirim gitmemeli.
    /// </summary>
    public async Task<long?> KuyrugaEkleAsync(BildirimIstegi istek, int kullaniciId, int? subeId,
                                              CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        int? sablonId = null;
        var kanal = istek.Kanal ?? BildirimKanali.Sms;
        var konu = istek.Konu ?? "";
        var govde = istek.Govde ?? "";

        if (!string.IsNullOrWhiteSpace(istek.SablonKodu))
        {
            var s = await baglanti.TekAsync("""
                select id, kanal, konu, govde, durum
                  from public.bildirim_sablon where kod = @p0
                """, null, [istek.SablonKodu], SablonSatiri, iptal);

            if (s is null) throw new InvalidOperationException($"Bildirim şablonu yok: {istek.SablonKodu}");
            if (s.Durum != 1) return null;      // pasif şablon: sessizce gönderilmez

            sablonId = s.Id;
            kanal = istek.Kanal ?? (BildirimKanali)s.Kanal;
            if (string.IsNullOrEmpty(konu))  konu  = BildirimSablonu.Doldur(s.Konu, istek.Degiskenler);
            if (string.IsNullOrEmpty(govde)) govde = BildirimSablonu.Doldur(s.Govde, istek.Degiskenler);
        }

        if (string.IsNullOrWhiteSpace(istek.Alici))
            throw new InvalidOperationException("Bildirim alıcısı boş olamaz.");
        if (string.IsNullOrWhiteSpace(govde))
            throw new InvalidOperationException("Bildirim gövdesi boş olamaz.");

        return await baglanti.TekDegerAsync<long>("""
            insert into public.bildirim
                   (kanal, sablon_id, hesap_id, alici, taraf_id, kullanici_id,
                    konu, govde, kaynak_tur, kaynak_id, oncelik, planlanan, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10,
                    coalesce(@p11, now()), @p12, @p13)
            returning id
            """, null,
            [(short)kanal, sablonId, istek.HesapId, istek.Alici.Trim(), istek.TarafId,
             istek.KullaniciId, konu, govde, istek.KaynakTur, istek.KaynakId, istek.Oncelik,
             istek.Planlanan, subeId, kullaniciId], iptal);
    }

    // --------------------------------------------------------------- kuyruktan al
    /// <summary>
    /// Gönderilecek satırları KİLİTLEYEREK alır ve durumlarını 2 yapar.
    /// Sıra: önce öncelik (küçük önce), sonra planlanan zaman.
    /// </summary>
    public async Task<IReadOnlyList<BildirimKaydi>> SiradakileriAlAsync(
        int adet, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await baglanti.ListeAsync("""
            with secilen as (
                select id from public.bildirim
                 where durum = 1 and planlanan <= now()
                 order by oncelik asc, planlanan asc, id asc
                 limit @p0
                 for update skip locked
            )
            update public.bildirim b
               set durum = 2, deneme = b.deneme + 1
              from secilen s
             where b.id = s.id
            returning b.id, b.kanal, b.alici, b.konu, b.govde, b.hesap_id,
                      b.deneme, b.en_fazla_deneme
            """, null, [adet],
            o => new BildirimKaydi(
                o.GetInt64(0), (BildirimKanali)o.GetInt16(1), o.GetString(2),
                o.GetString(3), o.GetString(4),
                o.IsDBNull(5) ? null : o.GetInt32(5),
                o.GetInt16(6), o.GetInt16(7)),
            iptal);
    }

    /// <summary>
    /// Gönderim sonucunu yazar: başarılıysa 3, değilse deneme hakkı kaldıysa
    /// yeniden 1 (kuyrukta) — kalmadıysa 6 (vazgeçildi).
    ///
    /// Yeniden denemede planlanan zaman GERİ ATILIR (deneme × 5 dk): sağlayıcı
    /// geçici olarak düştüyse aynı saniyede üç kez denemek yalnız üç hata üretir.
    /// </summary>
    public async Task SonucYazAsync(BildirimKaydi kayit, GonderimSonucu sonuc,
                                    int sureMs, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var tx = await baglanti.BeginTransactionAsync(iptal);

        var yeniDurum = sonuc.Basarili
            ? (short)BildirimDurumu.Gonderildi
            : kayit.Deneme < kayit.EnFazlaDeneme
                ? (short)BildirimDurumu.Kuyrukta
                : (short)BildirimDurumu.Vazgecildi;

        await baglanti.CalistirAsync("""
            update public.bildirim
               set durum = @p1,
                   gonderim = case when @p1 = 3 then now() else gonderim end,
                   planlanan = case when @p1 = 1
                                    then now() + (deneme * interval '5 minutes')
                                    else planlanan end,
                   saglayici_ref = case when @p2 <> '' then @p2 else saglayici_ref end,
                   hata = @p3
             where id = @p0
            """, tx, [kayit.Id, yeniDurum, sonuc.SaglayiciRef, Kirp(sonuc.Hata, 400)], iptal);

        await baglanti.CalistirAsync("""
            insert into public.bildirim_log
                   (bildirim_id, deneme, basarili, http_durum, sure_ms, saglayici_ref, hata, yanit)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7::jsonb)
            """, tx,
            [kayit.Id, kayit.Deneme, sonuc.Basarili ? (short)1 : (short)0,
             (short)sonuc.HttpDurum, sureMs, sonuc.SaglayiciRef, Kirp(sonuc.Hata, 400),
             sonuc.HamYanit], iptal);

        await tx.CommitAsync(iptal);
    }

    /// <summary>
    /// ASKIDA KALANLARI KURTAR: işçi "Gönderiliyor" (2) durumundayken çökerse
    /// satır orada donar. Belirtilen süreden eski 2'ler kuyruğa geri alınır —
    /// aksi halde o bildirim hiç gitmez ve kimse fark etmez.
    /// </summary>
    public async Task<int> AskidakileriKurtarAsync(TimeSpan yas, CancellationToken iptal = default)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        return await baglanti.CalistirAsync("""
            update public.bildirim
               set durum = case when deneme >= en_fazla_deneme then 6 else 1 end,
                   hata = 'Gönderim yarıda kaldı (servis yeniden başladı).'
             where durum = 2
               and ekleme_tarihi < now() - @p0::interval
            """, null, [$"{(int)yas.TotalSeconds} seconds"], iptal);
    }

    // ------------------------------------------------------------------ ekran
    /// <summary>Tek bildirimin deneme günlüğü (kart penceresi).</summary>
    public Task<List<Dictionary<string, object?>>> LogAsync(long bildirimId,
                                                            CancellationToken iptal = default)
        => _veri.ListeAsync("""
            select id, deneme, basarili, http_durum as "httpDurum", sure_ms as "sureMs",
                   saglayici_ref as "saglayiciRef", hata, tarih
              from public.bildirim_log where bildirim_id = @p0 order by id desc
            """, new object?[] { bildirimId }, Satir, iptal);

    /// <summary>Kuyruktaki satırı kullanıcı isteğiyle iptal eder (yalnız gönderilmemişi).</summary>
    public Task<int> IptalAsync(long id, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.bildirim set durum = 5 where id = @p0 and durum in (1, 4, 6)
            """, new object?[] { id }, iptal);

    /// <summary>Hatalı/vazgeçilmiş satırı yeniden kuyruğa alır (deneme sayacı sıfırlanır).</summary>
    public Task<int> TekrarDeneAsync(long id, CancellationToken iptal = default)
        => _veri.CalistirAsync("""
            update public.bildirim
               set durum = 1, deneme = 0, hata = '', planlanan = now()
             where id = @p0 and durum in (4, 5, 6)
            """, new object?[] { id }, iptal);

    /// <summary>Sablon satiri - deger tipi (tuple) generic kisitina uymuyordu.</summary>
    private sealed record SablonSatir(int Id, short Kanal, string Konu, string Govde, short Durum);

    private static SablonSatir SablonSatiri(NpgsqlDataReader o) =>
        new(o.GetInt32(0), o.GetInt16(1), o.GetString(2), o.GetString(3), o.GetInt16(4));

    private static Dictionary<string, object?> Satir(NpgsqlDataReader o)
    {
        var d = new Dictionary<string, object?>(StringComparer.Ordinal);
        for (var i = 0; i < o.FieldCount; i++)
            d[o.GetName(i)] = o.IsDBNull(i) ? null : o.GetValue(i);
        return d;
    }

    private static string Kirp(string metin, int en) =>
        string.IsNullOrEmpty(metin) ? "" : metin.Length <= en ? metin : metin[..en];
}
