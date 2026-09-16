using Gentegre.Api.AraKatman;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// DİŞ AKIŞINDAN BAŞVURU AÇMA (706). Kullanıcı: "diş için önce kimlik ve
/// başvuru mu açılmalı" → kimlik bir kez, başvuru her ziyarette ama yalnız
/// ÜCRET doğuracak iş için (muayene, seans → yapıldı). Odontogram, plan,
/// proforma başvurusuz yaşar.
///
/// <para>Seans açılırken ya da plan satırı "yapıldı" olurken günün açık
/// başvurusu yoksa Kayıt Kabul'e gitmeden burada açılır: ödeyen hastanın
/// KAYITLI kurumu (SGK · ÖSS · kurum; yoksa ücretli), fiyat listesi kurumun
/// sözleşmesinden ya da varsayılan liste, bölüm diş departmanı, hekim
/// seansın hekimi. SGK'lı hastada <c>belge_provizyon</c> satırı "provizyon
/// alınmadı" (0) ile açılır - Medula kapısı bağlanınca kuyruk doldurur;
/// ücret bugün de yazılır, provizyon sonradan işlenir.</para>
///
/// <para>Dış kurum başvurusuyla (<c>DisKurumBasvurusu</c>) aynı belge deseni:
/// tür 19 / tipi 30, numara <c>fn_numara_kimlik_uret</c>, KDV dahil,
/// toplamlar sıfır (satırlar sonra doldurur).</para>
/// </summary>
public static partial class DisUclari
{
    /// <summary>Başvuru (belge) log kodu - BelgeDeposu ile aynı.</summary>
    private const int LogTabloBelge = 30;

    private sealed record AcilanBasvuru(int BelgeId, string BelgeNo, string Odeyen, bool Sgk);

    private static async Task<AcilanBasvuru> BasvuruAcAsync(NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        LogDeposu log, IstekBaglami baglam, int hastaId, int? hekimId, CancellationToken iptal)
    {
        var sube = baglam.SubeId ?? 0;

        // Ödeyen: hastanın aktif kurum kaydı - SGK (3) > kurum (4) > ÖSS (2) > özel.
        //   Birden çok kayıt varsa SGK ana ödeyicidir; ÖSS tamamlayıcı olarak
        //   provizyon tablosunda ayrı alanda durur (299).
        var kurum = await baglanti.TekAsync("""
            select k.kurum_id, k.tur, k.sozlesme_id, coalesce(t.unvan, '') as unvan
              from public.taraf_hasta_kurum k
              left join public.taraf t on t.id = k.kurum_id
             where k.hasta_id = @p0 and k.aktif = 1
               and (k.gecerlilik is null or k.gecerlilik >= current_date)
             order by case k.tur when 3 then 0 when 4 then 1 when 2 then 2 else 3 end, k.id desc
             limit 1
            """, islem, [hastaId], o => new
        {
            kurumId = o.IsDBNull(0) ? (int?)null : o.GetInt32(0), tur = o.GetInt16(1),
            sozlesmeId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2), unvan = o.GetString(3),
        }, iptal);

        // Fiyat listesi: kurumun geçerli sözleşmesi, yoksa varsayılan liste.
        int? listeId = null;
        if (kurum?.kurumId is int kid)
            listeId = await baglanti.TekDegerAsync<int?>("""
                select s.fiyat_listesi_id from public.kurum_sozlesme s
                 where s.kurum_id = @p0 and s.durum = 1
                   and (s.baslangic is null or s.baslangic <= current_date)
                   and (s.bitis is null or s.bitis >= current_date)
                 order by s.baslangic desc nulls last, s.id desc limit 1
                """, islem, [kid], iptal);
        listeId ??= await VarsayilanFiyatListesiAsync(baglanti, null, iptal);

        // Bölüm: diş departmanı varsa o (adında "diş"/"ağız"); yoksa boş.
        var bolumId = await baglanti.TekDegerAsync<int?>("""
            select id from public.departman
             where ad ilike '%diş%' or ad ilike '%ağız%'
             order by case when ad ilike '%diş%' then 0 else 1 end, id limit 1
            """, islem, [], iptal);

        var belgeNo = await baglanti.TekDegerAsync<string>("""
            select public.fn_numara_kimlik_uret(19, @p0, 'belge', 'belge_no', current_date)
            """, islem, [sube], iptal) ?? "";

        var belgeId = await baglanti.TekDegerAsync<int>("""
            insert into public.belge
                   (tur, tipi, taraf_id, taraf_unvan, belge_no, belge_tarihi, sube_id, durum,
                    kdv_durum, fiyat_listesi_id, aciklama, matrah, kdv_tutari, genel_toplam, ekleyen)
            select @p0, @p1, t.id, t.unvan, @p2, now(), @p3, 0, 'Dahil', @p4,
                   'Diş seansı - akıştan açıldı', 0, 0, 0, @p5
              from public.taraf t where t.id = @p6
            returning id
            """, islem, [BasvuruTuru, BasvuruTipi, belgeNo, sube, listeId, baglam.KullaniciId, hastaId], iptal);

        await baglanti.CalistirAsync("""
            insert into public.belge_basvuru
                   (id, odeyen_kurum_id, sozlesme_id, bolum_id, personel_id, basvuru_turu, hasta_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6)
            """, islem, [belgeId, kurum?.kurumId, kurum?.sozlesmeId, bolumId, hekimId, hastaId, baglam.KullaniciId], iptal);

        // SGK'lı hasta: provizyon satırı "alınmadı" ile açılır; Medula bağlanınca
        //   kuyruk doldurur. Satır açılmazsa "kimde provizyon eksik" listesi
        //   bu başvuruyu hiç görmez.
        var sgk = kurum?.tur == 3;
        if (sgk)
            await baglanti.CalistirAsync("""
                insert into public.belge_provizyon (id, sgk_durum, ekleyen) values (@p0, 0, @p1)
                on conflict (id) do nothing
                """, islem, [belgeId, baglam.KullaniciId], iptal);

        var odeyen = kurum is null ? "Ücretli" : kurum.unvan;
        if (islem is null)
            await log.YazAsync(LogIslemi.Ekle, LogTabloBelge, belgeId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new { belgeNo, kaynak = "dis-seans", odeyen }, tarafId: hastaId, iptal: iptal);
        else
            await log.YazAsync(baglanti, islem, LogIslemi.Ekle, LogTabloBelge, belgeId, baglam.KullaniciId, baglam.SubeId,
                baglam.Ip, new { belgeNo, kaynak = "dis-seans", odeyen }, tarafId: hastaId, iptal: iptal);

        return new AcilanBasvuru(belgeId, belgeNo, odeyen, sgk);
    }
}
