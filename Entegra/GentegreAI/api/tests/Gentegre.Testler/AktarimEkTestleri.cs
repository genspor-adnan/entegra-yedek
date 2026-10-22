using System.Text.Json.Nodes;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// DELPHI AKTARIMI - EK MODÜLLER (1143..1149, bir kerelik: db/araclar/aktar_ek.ps1).
/// Kaynak stg tablolarına örnek satır yazılır, modül fonksiyonu iki kez çalıştırılır
/// (ikincisi hiçbir şey yazmamalı). Çek hareketinin cari satırı Delphi cari listesi
/// kuralıyla; teklif tür 18 ve cariyi etkilemez; hesap planında web'in kodu korunur.
/// İşlem içinde, geri alınır (stg tabloları da).
/// </summary>
public sealed class AktarimEkTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<JsonObject> CalistirAsync(NpgsqlConnection b, NpgsqlTransaction t, string fn)
        => (JsonObject)JsonNode.Parse(await b.TekDegerAsync<string>(
               $"select public.{fn}()::text", t, [], CancellationToken.None) ?? "{}")!;

    private static int Sayi(JsonObject o, string k) => o[k]?.GetValue<int>() ?? 0;

    private static Task CariAsync(NpgsqlConnection b, NpgsqlTransaction t, int id, string kod) =>
        b.TekDegerAsync<string>("select public.fn_aktar_cari(@p0::jsonb)::text", t,
            ["{\"U\": {\"REHBER\": [{\"id\": " + id + ", \"kod\": \"" + kod + "\", \"firma\": \"Aktarım Ek " + kod
             + "\", \"durum\": 1}]}}"],
            CancellationToken.None);

    [VtFact]
    public async Task Cek_karti_hareketi_ve_cari_satiri_Delphi_kuraliyla_tekrar_yazmaz()
    {
        if (!_olgu.Baglandi(nameof(Cek_karti_hareketi_ve_cari_satiri_Delphi_kuraliyla_tekrar_yazmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await CariAsync(b, t, 990005201, "AKT-EK-CEK");
        await b.CalistirAsync("""
            truncate stg.cekler, stg.cekhareket;
            insert into stg.cekler (id, rehberid, ceksenet, tur, tarih, vade, tutar, kur, serino, makbuzno)
            values (990005301, 990005201, 101, 136, '2026-02-01', '2026-04-01', 1000, 'TL', 1234567, 'M-1');
            -- müşteriden portföye (cari ALACAK), sonra tahsil (carisiz, cariyi etkilemez)
            insert into stg.cekhareket (id, ceksenetlerid, tarih, islem, rehberid, tutar, kur, ekstredekullan)
            values (990005401, 990005301, '2026-02-01', 130, 990005201, 1000, 'TL', 0),
                   (990005402, 990005301, '2026-04-02', 136, 0, 1000, 'TL', 0);
            """, t, [], ct);

        var ilk = await CalistirAsync(b, t, "fn_aktar_ek_cek");
        Assert.Equal(1, Sayi(ilk, "cek_eklenen"));
        Assert.Equal(2, Sayi(ilk, "hareket_eklenen"));
        Assert.Equal(1, Sayi(ilk, "cari_eklenen"));

        // Kart: alınan çek (1/1), güncel durum 136 Tahsil -> 50.
        Assert.Equal("1/1/50/1000.0000/1234567", await b.TekDegerAsync<string>("""
            select tur || '/' || yon || '/' || durum || '/' || tutar || '/' || seri_no from public.cek_senet
             where aktarim_kaynak = 1 and aktarim_tablo = 'CEKLER' and aktarim_id = 990005301
            """, t, [], ct));
        // Hareketler: 130 portföye (0 -> 10), 136 Delphi tahsil -> web 133 (10 -> 50).
        Assert.Equal("130:0>10 133:10>50", await b.TekDegerAsync<string>("""
            select string_agg(h.islem || ':' || h.eski_durum || '>' || h.yeni_durum, ' ' order by h.tarih)
              from public.cek_senet_hareket h
             where h.aktarim_kaynak = 1 and h.aktarim_tablo = 'CEKHAREKET'
               and h.aktarim_id in (990005401, 990005402)
            """, t, [], ct));
        // Cari satırı yalnız portföye girişte: Çek ile Tahsilat (23), cari ALACAK 1000.
        Assert.Equal("23/C/0.0000/1000.0000/1000.0000", await b.TekDegerAsync<string>("""
            select m.tur || '/' || m.hesap_turu || '/' || m.borc || '/' || m.alacak || '/' || m.yerel_alacak
              from public.mali_hareket m
             where m.aktarim_kaynak = 1 and m.aktarim_tablo = 'CEKHAREKET' and m.aktarim_id = 990005401
            """, t, [], ct));

        var ikinci = await CalistirAsync(b, t, "fn_aktar_ek_cek");
        Assert.Equal(0, Sayi(ikinci, "cek_eklenen") + Sayi(ikinci, "cek_guncellenen") + Sayi(ikinci, "hareket_eklenen")
                        + Sayi(ikinci, "hareket_guncellenen") + Sayi(ikinci, "cari_eklenen") + Sayi(ikinci, "cari_guncellenen"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Teklif_tur_18_cariyi_etkilemez_durum_eslenir()
    {
        if (!_olgu.Baglandi(nameof(Teklif_tur_18_cariyi_etkilemez_durum_eslenir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await CariAsync(b, t, 990005202, "AKT-EK-TKL");
        await b.CalistirAsync("""
            truncate stg.teklif, stg.teklifdetay;
            insert into stg.teklif (id, tarih, rehberid, teklifno, durum, konusu, kdvdurum, teklif_matrahi, kdv_tutari,
                                    teklif_tutari, kur, teslim_suresi)
            values (990005501, '2026-03-10', 990005202, 'TKL-1', 7, 'Yıllık bakım', 'Hariç', 100, 20, 120, 'TL', 15);
            insert into stg.teklifdetay (id, teklifid, tur, urunid, aciklama, adet, miktar, birim, birimfiyat, kdv, tutar)
            values (990005601, 990005501, 0, 0, 'Bakım hizmeti', 1, 1, '51', 100, 20, 100);
            """, t, [], ct);

        var ilk = await CalistirAsync(b, t, "fn_aktar_ek_teklif");
        Assert.Equal(1, Sayi(ilk, "teklif_eklenen"));
        Assert.Equal(1, Sayi(ilk, "satir_eklenen"));
        // Delphi 7 "Kabul edildi" -> 3 Kabul; teslim süresi metin; tür 18.
        Assert.Equal("18/3/TKL-1/Yıllık bakım/15 gün/120.0000", await b.TekDegerAsync<string>("""
            select tur || '/' || teklif_durum || '/' || belge_no || '/' || teklif_konusu || '/' || teklif_teslim
                   || '/' || genel_toplam
              from public.belge where aktarim_kaynak = 1 and aktarim_tablo = 'TEKLIF' and aktarim_id = 990005501
            """, t, [], ct));
        Assert.Equal(0L, await b.TekDegerAsync<long>("""
            select count(*) from public.mali_hareket m join public.belge x on x.id = m.belge_id
             where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'TEKLIF' and x.aktarim_id = 990005501
            """, t, [], ct));

        var ikinci = await CalistirAsync(b, t, "fn_aktar_ek_teklif");
        Assert.Equal(0, Sayi(ikinci, "teklif_eklenen") + Sayi(ikinci, "teklif_guncellenen")
                        + Sayi(ikinci, "satir_eklenen") + Sayi(ikinci, "satir_guncellenen"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Hesap_plani_web_kodu_korunur_alt_hesap_ustune_baglanir()
    {
        if (!_olgu.Baglandi(nameof(Hesap_plani_web_kodu_korunur_alt_hesap_ustune_baglanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        // Web'in kendi hesabı (Delphi kökenli değil) - adı değişmemeli.
        await b.CalistirAsync("""
            insert into public.hesap_plani (kod, ad, seviye, sinif, calisir_mi, durum)
            select 'T99', 'Web hesabı', 1, 0, 1, 1
             where not exists (select 1 from public.hesap_plani where kod = 'T99');
            truncate stg.hesapplani;
            insert into stg.hesapplani (id, hesapkodu, hesapadi, kur, durum)
            values (990005701, 'T99', 'Delphi adı', 'TL', 1),
                   (990005702, 'T99.01', 'Delphi alt hesabı', 'TL', 1),
                   (990005703, 'T99.01.001', 'Delphi en alt', '$', 1);
            """, t, [], ct);

        var ilk = await CalistirAsync(b, t, "fn_aktar_ek_hesap_plani");
        Assert.Equal(2, Sayi(ilk, "eklenen"));
        Assert.Equal(1, Sayi(ilk, "web_kodu_korunan"));
        Assert.Equal("Web hesabı/0", await b.TekDegerAsync<string>(
            "select ad || '/' || calisir_mi from public.hesap_plani where kod = 'T99'", t, [], ct));
        Assert.Equal("T99.01:T99:0 T99.01.001:T99.01:1:USD", await b.TekDegerAsync<string>("""
            select string_agg(h.kod || ':' || u.kod || ':' || h.calisir_mi
                              || case when h.doviz_cinsi <> 'TL' then ':' || h.doviz_cinsi else '' end, ' ' order by h.kod)
              from public.hesap_plani h join public.hesap_plani u on u.id = h.ust_id
             where h.kod like 'T99.%'
            """, t, [], ct));

        var ikinci = await CalistirAsync(b, t, "fn_aktar_ek_hesap_plani");
        Assert.Equal(0, Sayi(ikinci, "eklenen") + Sayi(ikinci, "guncellenen") + Sayi(ikinci, "ust_baglanan"));
        await t.RollbackAsync();
    }

    [VtFact]
    public async Task Toplu_cagri_bos_kaynakta_her_modulu_hatasiz_calistirir()
    {
        if (!_olgu.Baglandi(nameof(Toplu_cagri_bos_kaynakta_her_modulu_hatasiz_calistirir))) return;
        await using var b = await _olgu.Gerekli().AcAsync(CancellationToken.None);
        await using var t = await b.BeginTransactionAsync();
        var ct = CancellationToken.None;

        await b.CalistirAsync("""
            truncate stg.kullanici, stg.roller, stg.rehberpersonel, stg.personelizin, stg.pers_hareket,
                     stg.gorevler, stg.gorevkullanici, stg.gorevyorum, stg.aktiviteler, stg.aktivitenotlar,
                     stg.animsat, stg.dokuman, stg.dokumanklasor, stg.imaj, stg.ebelge, stg.ebelgemesaj,
                     stg.cekler, stg.cekhareket, stg.teklif, stg.teklifdetay, stg.hesapplani, stg.demirbas;
            """, t, [], ct);
        var sonuc = await CalistirAsync(b, t, "fn_aktar_ek");
        foreach (var m in new[] { "kisi", "hesap_plani", "demirbas", "cek", "teklif", "gorev", "dokuman", "ebelge" })
        {
            Assert.True(sonuc.ContainsKey(m), m + " sonuçta yok");
            Assert.Null(sonuc[m]?["hata"]);
        }
        await t.RollbackAsync();
    }
}
