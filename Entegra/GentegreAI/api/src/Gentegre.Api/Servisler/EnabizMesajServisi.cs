using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// HASTANIN e-NABIZ PROFİLİNE MESAJ (877 · 881 — KTS maddeleri H7 / D14).
///
/// <para><b>İki iş, bir tablo:</b> hekimin elle yazdığı bilgilendirme ile
/// olaydan doğan otomatik mesaj (numune reddi H1/D16 · randevu iptali D17)
/// aynı kuyruğa düşer, yalnız <c>kaynak</c> kodları ayrıdır. Otomatik mesaj
/// için ayrı yol açmak, aynı gönderimi iki yerde bakmak olurdu.</para>
///
/// <para><b>TAŞIMA 881'DE DEĞİŞTİ.</b> 877'de mesajı <c>NabizHBYS.svc</c>
/// üzerinde ayrı bir SOAP metoduyla göndermeyi tasarlamış ve "metot adı
/// kılavuzda yok" diye kapıyı kapalı bırakmıştık. Doğrusu şu: <b>hastaya
/// mesaj bir USS PAKETİDİR</b> — rehberdeki <b>411 Doktor Mesajı</b>. Yani
/// 101/102/103 ile aynı kuyruktan, aynı <c>SYSSendMessage</c> çağrısıyla
/// gider; ayrı hesap, ayrı metot adı, ayrı kapı gerekmez.</para>
///
/// <para>Bu servis artık <b>paket üretir</b>: kuyruktaki her mesaj satırı
/// için 411 paketi açılır ve satıra paket numarası işlenir. Paketi GÖNDERMEZ
/// - gönderim tek yerde, <c>enabiz.gonder</c> kuyruğunda olmalı; iki ayrı
/// gönderici, USS oturumunu ve hata yorumlamasını iki kez yazmak demekti.
/// Mesajın gönderim durumu bundan böyle PAKETİN durumudur.</para>
///
/// <para><b>TAKİP NUMARASI OLMADAN PAKET ÜRETİLMEZ:</b> 411'in ilk zorunlu
/// alanı <c>SYSTakipNo</c>'dur (102 ve 105'te öğrenilen kural). Numara
/// gelmemişse mesaj kuyrukta bekler ve sebebi <c>son_hata</c>'ya yazılır -
/// hata sayılmaz, çünkü numara birkaç dakika içinde gelir.</para>
/// </summary>
public sealed class EnabizMesajServisi
{
    private readonly VeriKaynagi _veri;
    private readonly EnabizPaketUretici _uretici;
    private readonly ILogger<EnabizMesajServisi> _gunluk;

    public EnabizMesajServisi(VeriKaynagi veri, EnabizPaketUretici uretici,
                              ILogger<EnabizMesajServisi> gunluk)
    {
        _veri = veri;
        _uretici = uretici;
        _gunluk = gunluk;
    }

    /// <summary>Mesaj gövdesinin azami uzunluğu - kolon da 500 (877).</summary>
    public const int AzamiMetin = 500;

    /// <summary>411 Doktor Mesajı paket türünün kodu (881).</summary>
    public const string PaketKodu = "HASTA_MESAJI";

    public sealed record Sonuc(int Gonderildi, int Hata, int Bekleyen, string Aciklama);

    // ============================================================ yazma ==

    /// <summary>
    /// Mesajı kuyruğa alır ve id'sini döner.
    ///
    /// <para><b>Kimlik numaraları satıra yazılır</b> (hasta ve hekim): kart
    /// sonradan değişse bile gönderilmiş mesajın kime/kimden gittiği kayıtta
    /// kalmalıdır.</para>
    ///
    /// <para><b>Mesaj türü SKRS listesinden</b> (881, <c>HASTA MESAJLARI</c>):
    /// 411'in zorunlu alanı. Çağıran vermezse kaynaktan türetilir - numune
    /// reddi olayı "NUMUNE REDDI" türüne, elle yazılan mesaj "DOKTORUN
    /// MESAJI" türüne düşer.</para>
    ///
    /// <para>Çağıran bir işlem içindeyse <paramref name="islem"/> verir:
    /// numune reddi gibi olaylarda mesaj, olayın kendisiyle birlikte ya
    /// yazılır ya hiç yazılmaz.</para>
    /// </summary>
    public static async Task<long> KuyrugaAlAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int hastaId, int? hekimId,
        string metin, short kaynak, int? kaynakId, int? belgeId, int subeId, int kullaniciId,
        CancellationToken iptal, short? mesajTuru = null)
    {
        var temiz = (metin ?? "").Trim();
        if (temiz.Length == 0) throw GentegreHatasi.Dogrulama("Mesaj boş olamaz.");
        if (temiz.Length > AzamiMetin)
            throw GentegreHatasi.Dogrulama($"Mesaj en çok {AzamiMetin} karakter olabilir.");

        return await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_mesaj
                   (sube_id, hasta_id, hekim_id, hekim_kimlik, hasta_kimlik, belge_id,
                    kaynak, kaynak_id, mesaj_turu, metin, durum, ekleyen)
            select @p0, @p1, @p2,
                   -- KIMLIK NUMARASI `taraf.vkno`da durur (kart TCKN ve VKN icin
                   --   ayni alani kullanir, 09 semasi); USS de ayni alani bekler.
                   coalesce((select h.vkno from public.taraf h where h.id = @p2), ''),
                   coalesce((select t.vkno from public.taraf t where t.id = @p1), ''),
                   @p3, @p4, @p5,
                   coalesce(cast(@p8 as smallint), public.fn_enabiz_mesaj_turu(@p4)),
                   @p6, 0, @p7
            returning id
            """, islem, [subeId, hastaId, hekimId, belgeId, kaynak, kaynakId, temiz,
                         kullaniciId, mesajTuru], iptal);
    }

    // ============================================== pakete dönüştürme ==

    /// <summary>
    /// Kuyruktaki mesajlardan 411 paketi üretir (zamanlı iş <c>enabiz.mesaj</c>).
    ///
    /// <para>Üretim başarısızsa satır HATA'ya düşmez, kuyrukta bekler:
    /// sebebi (çoğunlukla "takip numarası henüz yok") <c>son_hata</c>'ya
    /// yazılır. Kalıcı bir hata gibi işaretlemek, numara geldiğinde elle
    /// temizlik demekti.</para>
    /// </summary>
    public async Task<Sonuc> CalistirAsync(int adet, long? mesajId, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var kuyruk = await baglanti.ListeAsync("""
            select m.id, m.ekleyen,
                   coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                              where bb.id = m.belge_id), '') as takip
              from public.enabiz_mesaj m
             where m.durum = 0 and (cast(@p0 as bigint) is null or m.id = @p0)
             order by m.id
             limit @p1
            """, null, [mesajId, adet],
            o => new { Id = o.GetInt64(0), Kullanici = o.GetInt32(1), Takip = o.GetString(2) },
            iptal);

        if (kuyruk.Count == 0)
            return new Sonuc(0, 0, 0, "Kuyrukta mesaj yok.");

        int uretilen = 0, bekleyen = 0;
        foreach (var m in kuyruk)
        {
            // TAKIP NUMARASI GELMEDEN PAKET URETILMEZ (102/105'teki kural).
            //   Sebebi yalniz "eksik alanla gitmesin" degil: paket bir kez
            //   uretilince "ayni icerik -> ayni paket" korumasi devreye giriyor
            //   ve SYSTakipNo parmak izine GIRMEDIGI icin numara sonradan
            //   gelse bile paket kendiliginden tamamlanmiyor. Yani erken
            //   uretilen paket, numarasiz olarak SAPLANIP kaliyor.
            if (m.Takip.Trim().Length == 0)
            {
                await SebepYazAsync(baglanti, m.Id,
                    "Başvurunun e-Nabız takip numarası (SYSTakipNo) henüz gelmedi; "
                    + "mesaj kuyrukta bekliyor.", iptal);
                bekleyen++;
                continue;
            }

            try
            {
                var s = await _uretici.UretAsync(PaketKodu, (int)m.Id, m.Kullanici, iptal);
                if (s is null)
                {
                    // Paket türü kapalı ya da alanlar çözülemedi (takip
                    //   numarası yok). İkisi de geçici - satır kuyrukta kalır.
                    await SebepYazAsync(baglanti, m.Id,
                        "411 paketi üretilemedi: takip numarası (SYSTakipNo) bekleniyor "
                        + "ya da paket türü kapalı.", iptal);
                    bekleyen++;
                    continue;
                }

                // EKSIK ALANLI PAKET "GONDERILDI" SAYILMAZ (881): USS onu
                //   reddeder ve mesaj hastaya hic ulasmaz. Satir kuyrukta
                //   kalir; takip numarasi gelince bir sonraki tur AYNI paketi
                //   tamamlar ("ayni icerik -> ayni paket" kurali). Paket bagi
                //   yine yazilir - ekranda hangi paket oldugu gorunsun.
                var tamam = s.Eksikler.Count == 0;
                await baglanti.CalistirAsync("""
                    update public.enabiz_mesaj
                       set durum = case when @p3 then 1 else 0 end,
                           gonderim_zamani = case when @p3 then now() else gonderim_zamani end,
                           deneme = deneme + 1,
                           paket_id = (select p.id from public.enabiz_paket p
                                        where p.paket_no = @p1),
                           yanit_kod = left(@p1, 20),
                           yanit_mesaj = case when @p3 then @p2 else yanit_mesaj end,
                           son_hata = case when @p3 then '' else @p2 end,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, null, [m.Id, s.PaketNo,
                                tamam
                                    ? "411 paketi üretildi, gönderim kuyruğunda."
                                    : "411 paketi eksik alanla üretildi, gönderilmedi: "
                                      + string.Join(", ", s.Eksikler),
                                tamam], iptal);
                if (tamam) uretilen++; else bekleyen++;
            }
            catch (Exception h)
            {
                _gunluk.LogError(h, "e-Nabiz 411 paketi uretilemedi (mesaj {Id})", m.Id);
                await SebepYazAsync(baglanti, m.Id,
                    EnabizPortalIstemcisi.Kirp(h.Message, 400), iptal);
                bekleyen++;
            }
        }

        var kalan = await baglanti.TekDegerAsync<int>(
            "select count(*)::int from public.enabiz_mesaj where durum = 0", null, [], iptal);
        return new Sonuc(uretilen, 0, kalan,
            $"{uretilen} mesaj 411 paketine dönüştü, {bekleyen} bekliyor; kuyrukta {kalan}.");
    }

    private static async Task SebepYazAsync(NpgsqlConnection baglanti, long id, string sebep,
                                            CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.enabiz_mesaj
               set son_hata = @p1, deneme = deneme + 1, degistirme_tarihi = now()
             where id = @p0
            """, null, [id, EnabizPortalIstemcisi.Kirp(sebep, 400)], iptal);
}
