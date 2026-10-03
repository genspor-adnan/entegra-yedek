using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// TEK KAYIT ERISIM KAPISI (denetim 28.09.2026 #3).
///
/// <para>Liste ve kartlar kayit erisimini katalogdan (SorguUretici) alir:
/// sube, kayit kapsami (kullanici_kapsam), portal kapsami (794/819) ve hekim
/// kisiti. Ozel uclar ise kimligi yoldan alip dogrudan <c>where id = @p0</c>
/// ile okuyordu - kaynak yetkisini gecen kullanici BASKA SUBENIN ya da baska
/// hastanin kaydini kimligiyle acabiliyordu (lab grafik ucu).</para>
///
/// <para>Bu kapi AYNI kurali ikinci kez yazmaz: katalogdaki kaynagin sayim
/// sorgusunu tek kimlik suzgeciyle calistirir. Kural degisirse liste ile ozel
/// uc birlikte degisir. Kaynagin <c>SabitKosul</c>'u bir IS AKISI suzgecidir
/// (or. "serbest birakilmis istem"), erisim kurali degil - atlanir.</para>
///
/// <para>Kapsam disi kayit <b>bulunamadi</b> ile ayni cevabi alir: kimligi
/// deneyen kisi kaydin var olup olmadigini ogrenemez.</para>
/// </summary>
public sealed class KayitErisimi
{
    private readonly VeriKaynagi _veri;
    public KayitErisimi(VeriKaynagi veri) => _veri = veri;

    /// <summary>Kayit bu baglamin kapsaminda mi (katalog kaynagi + kimlik).</summary>
    public async Task<bool> GorunurAsync(IstekBaglami baglam, string kaynakAdi, long id,
                                         CancellationToken iptal = default)
    {
        var tanim = KaynakKatalogu.Bul(kaynakAdi)
            ?? throw new InvalidOperationException($"Bilinmeyen kaynak: {kaynakAdi}");
        var erisim = tanim with { SabitKosul = null };

        // HEKIM KISITI: liste ucundaki kuralin aynisi (ListeUclari).
        int? hekimId = null;
        if (KaynakKatalogu.HekimKolonu(tanim.Ad) is not null
            && await _veri.TekDegerAsync<int>(KaynakKatalogu.HekimKisitliSql,
                                              [baglam.KullaniciId], iptal) == 1)
            hekimId = baglam.KullaniciId;

        var uretici = baglam.PortalTuru > 0
            ? new SorguUretici(erisim, baglam.PortalTuru, baglam.PortalKimlik)
                  { HekimId = hekimId, TetkikRolleri = baglam.RolIdleri }
            : new SorguUretici(erisim) { HekimId = hekimId, TetkikRolleri = baglam.RolIdleri };

        var istek = new ListeIstegi
        {
            Filtre = new Kosul { Alan = "id", Op = KosulOperatoru.Esit, Deger = id }
        };
        var sorgu = uretici.Sayim(istek, baglam.SubeId, baglam.Kapsam, null);
        return await _veri.TekDegerAsync<long>(sorgu.Sql, sorgu.Parametreler, iptal) > 0;
    }

    /// <summary>Kapsam disi ya da olmayan kayit: ayni 404.</summary>
    public async Task IsteAsync(IstekBaglami baglam, string kaynakAdi, long id,
                                string bulunamadiMesaji, CancellationToken iptal = default)
    {
        if (!await GorunurAsync(baglam, kaynakAdi, id, iptal))
            throw GentegreHatasi.Bulunamadi(bulunamadiMesaji);
    }

    /// <summary>
    /// LAB ISTEM SATIRI: satirin istemi kapsamda mi (sube / portal / kapsam)
    /// VE satirin tetkiki kullanicinin GUNCEL rol kumesine <c>gor</c> izni
    /// veriyor mu (889/923). Grafik, sonuc gecmisi ve grafik dosyasi ayni
    /// kapidan gecer.
    /// </summary>
    public async Task LabSatirIsteAsync(IstekBaglami baglam, long satirId,
                                        CancellationToken iptal = default)
    {
        const string yok = "Tetkik satiri bulunamadi.";
        var satir = await _veri.TekAsync(
            "select s.istem_id, public.fn_lab_tetkik_izin_roller(s.tetkik_id, @p1, 'gor') " +
            "  from public.lab_istem_satir s where s.id = @p0",
            [satirId, baglam.RolIdleri.ToArray()],
            o => new { IstemId = o.GetInt32(0), Izin = o.GetBoolean(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi(yok);

        await IsteAsync(baglam, "lab-istem", satir.IstemId, yok, iptal);

        // Kapsamdaki kullanici icin tetkik kisiti ayrica soylenir: kaydi
        //   zaten gorebildigi bir istemin satiri, varligi sir degil.
        if (!satir.Izin)
            throw GentegreHatasi.Yasak("Bu tetkikin sonucunu görme yetkiniz yok.");
    }
}
