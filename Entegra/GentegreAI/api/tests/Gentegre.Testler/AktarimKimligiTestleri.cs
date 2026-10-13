using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - KAYNAK KİMLİĞİ (1080, dokuman/18 §11 adım 1).
///
/// Web kendi id'sini üretir; Delphi'deki kimlik `aktarim_kaynak / aktarim_tablo /
/// aktarim_id` kolonlarında durur. Bu sınıf iki şeyi korur:
///  · aktarılan her tabloda üç kolon ve benzersiz indeks var,
///  · göç kayıtlarını işaretleyen fonksiyon YALNIZ id eşitliğine güvenmez.
///    Gerçek vaka (13.10.2026): test DB'de 3.672 stok id'si stg.stoklar ile
///    örtüşüyor ama KODLARI farklı (stok tablosu sonradan başka kaynaktan
///    dolduruldu); yalnız id'ye bakılsaydı hepsi "Delphi'den" damgalanırdı.
/// </summary>
public sealed class AktarimKimligiTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static readonly string[] Tablolar =
    [
        "taraf", "taraf_adres", "depo", "hizmet", "masraf", "stok", "stok_seri_lot",
        "belge", "belge_satir", "mali_hareket", "stok_izleme", "kredi",
        "doviz_kur", "hesap", "proje", "masraf_merkezi",
        "stok_barkod", "stok_fiyat", "hizmet_fiyat", "masraf_fiyat",
    ];

    [VtFact]
    public async Task Aktarilan_her_tabloda_kaynak_kolonlari_ve_benzersiz_indeks_var()
    {
        if (!_olgu.Baglandi(nameof(Aktarilan_her_tabloda_kaynak_kolonlari_ve_benzersiz_indeks_var))) return;
        var veri = _olgu.Gerekli();
        var eksik = new List<string>();
        foreach (var t in Tablolar)
        {
            var kolon = await veri.TekDegerAsync<long>("""
                select count(*) from information_schema.columns
                 where table_schema = 'public' and table_name = @p0
                   and column_name in ('aktarim_kaynak', 'aktarim_tablo', 'aktarim_id')
                """, [t]);
            if (kolon != 3) eksik.Add($"{t}: {kolon}/3 kolon");
            var indeks = await veri.TekDegerAsync<long>("""
                select count(*) from pg_indexes
                 where schemaname = 'public' and tablename = @p0 and indexname = @p1
                   -- ilike DEĞİL: ICU tr-TR'de 'UNIQUE' küçülünce 'unıque' olur (noktasız ı).
                   and indexdef like 'CREATE UNIQUE INDEX%'
                """, [t, $"ux_{t}_aktarim"]);
            if (indeks != 1) eksik.Add($"{t}: benzersiz indeks yok");
        }
        Assert.True(eksik.Count == 0, "Aktarım kimliği eksik: " + string.Join(", ", eksik));
    }

    [VtFact]
    public async Task Isaretleme_yalniz_id_ye_guvenmez_ikinci_alan_tutmali()
    {
        if (!_olgu.Baglandi(nameof(Isaretleme_yalniz_id_ye_guvenmez_ikinci_alan_tutmali))) return;
        var veri = _olgu.Gerekli();
        await using var b = await veri.AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        if (await b.TekDegerAsync<bool>("select to_regclass('stg.rehber') is not null", t, [], ct) == false)
            return;   // stg'siz kurulum: işaretlenecek göç kaydı yok

        // id + kod eşleşen, henüz işaretsiz bir taraf seç.
        var hedef = await b.TekDegerAsync<int?>("""
            select x.id from public.taraf x join stg.rehber s on s.id = x.id
             where coalesce(x.kod, '') = coalesce(s.kod, '') and x.aktarim_kaynak is null
             order by x.id limit 1
            """, t, [], ct);
        if (hedef is null) return;   // eşleşen göç kaydı yok - test anlamsız

        var once = await b.TekDegerAsync<long>(
            "select eslesen from public.fn_aktarim_kaynak_isaretle() where tablo = 'taraf'", t, [], ct);

        // Aynı id kalsın, KOD değişsin: artık kanıtlanamaz, işaretlenmemeli.
        await b.CalistirAsync("update public.taraf set kod = coalesce(kod, '') || '#test' where id = @p0",
            t, [hedef], ct);
        var sonra = await b.TekDegerAsync<long>(
            "select eslesen from public.fn_aktarim_kaynak_isaretle() where tablo = 'taraf'", t, [], ct);
        Assert.Equal(once - 1, sonra);

        // Uygula: kodu bozulan satır işaretsiz kalır, kanıtlanan satırlar damgalanır.
        await b.CalistirAsync("select count(*) from public.fn_aktarim_kaynak_isaretle(true)", t, [], ct);
        Assert.Null(await b.TekDegerAsync<short?>(
            "select aktarim_kaynak from public.taraf where id = @p0", t, [hedef], ct));
        Assert.True(await b.TekDegerAsync<long>("""
            select count(*) from public.taraf
             where aktarim_kaynak = 1 and aktarim_tablo = 'REHBER' and aktarim_id = id
            """, t, [], ct) > 0);

        // İkinci çağrı hiçbir şey yapmaz (idempotent).
        Assert.Equal(0, await b.TekDegerAsync<long>(
            "select coalesce(sum(isaretlenen), 0) from public.fn_aktarim_kaynak_isaretle(true)", t, [], ct));

        await t.RollbackAsync();
    }
}
