using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// DIŞ KURUM İSTEMİNİN ÜCRETLENDİRİLMESİ (kullanıcı).
///
/// <para>Dış kurumdan gelen numunede iş şu sırayla yürür:</para>
/// <list type="number">
///   <item>İstem kaydedilir → gönderen kuruma bir BAŞVURU (belge 19/30)
///         açılır ve tetkikler ücret satırı olur.</item>
///   <item>Sonradan tetkik eklenirse AYNI başvuruya eklenir - her kayıtta
///         yeni belge açmak, bir numuneyi iki kez faturalamak olurdu.</item>
///   <item>İstem "Sonuçlandı" olarak kaydedilince başvuru SATIŞ TAHAKKUKUNA
///         (tür 17) dönüştürülür ve kapanır: iş bitti, kuruma tahakkuk etti,
///         hastadan tahsilat beklenmiyor.</item>
/// </list>
///
/// <para><b>CARİ DIŞ KURUMDUR</b> (kullanıcı kararı): belge.taraf_id =
/// gönderen kurum. Numuneyi kurum gönderdi, faturayı kurum ödeyecek; hastayı
/// cari yapmak onun ekstresine hiç doğmayacak bir borç yazardı. Hasta bağı
/// `lab_istem.taraf_id`de zaten duruyor.</para>
///
/// <para><b>FİYAT SÖZLEŞMEDEN</b>: kurumun geçerli sözleşmesindeki fiyat
/// listesi, yoksa kurulumun varsayılan listesi. Liste belgeye yazılır -
/// "hangi anlaşmayla" sorusu sonradan cevaplanabilmeli.</para>
///
/// <para><b>SESSİZ ÇALIŞIR:</b> ücretlendirme düşerse istem kaydı düşmez.
/// Numune kabul edilmiş, tetkik çalışılacaktır; muhasebe adımı sonradan
/// elle tamamlanabilir. Hata günlüğe yazılır, çağırana uyarı döner.</para>
/// </summary>
public sealed class DisKurumBasvurusu(
    VeriKaynagi veri, BelgeDeposu belgeler, ILogger<DisKurumBasvurusu> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly BelgeDeposu _belgeler = belgeler;
    private readonly ILogger<DisKurumBasvurusu> _gunluk = gunluk;

    /// <summary>Dış kurum kaynak kodu (`lab_istem.kaynak`).</summary>
    private const short KaynakDisKurum = 4;
    /// <summary>Başvuru = satış siparişi (19), tipi 30 "hasta başvurusu".</summary>
    private const int BasvuruTuru = 19;
    private const short BasvuruTipi = 30;
    /// <summary>Satış tahakkuku - stok etkilemez, cari borçlanır.</summary>
    private const int TahakkukTuru = 17;
    /// <summary>`lab_istem.durum` 4 = bütün satırlar sonuçlandı.</summary>
    private const short IstemSonuclandi = 4;

    /// <summary>
    /// İstemi ücretlendirir. Döndürdüğü metin kullanıcıya gösterilecek
    /// uyarı/bilgidir; iş yapılmadıysa (dış kurum değil) null döner.
    /// </summary>
    public async Task<string?> TazeleAsync(long istemId, IstekBaglami baglam,
                                           CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var istem = await baglanti.TekAsync("""
            select i.id, i.kaynak, i.dis_kurum_id, i.taraf_id, i.sube_id, i.belge_id,
                   i.durum, i.istem_tarihi, i.personel_id, i.bolum
              from public.lab_istem i where i.id = @p0
            """, null, [istemId],
            o => new { Id = o.GetInt32(0), Kaynak = o.GetInt16(1),
                       KurumId = o.IsDBNull(2) ? (int?)null : o.GetInt32(2),
                       HastaId = o.GetInt32(3), SubeId = o.GetInt32(4),
                       BelgeId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                       Durum = o.GetInt16(6), Tarih = o.GetDateTime(7),
                       PersonelId = o.IsDBNull(8) ? (int?)null : o.GetInt32(8),
                       Bolum = o.IsDBNull(9) ? (short)0 : o.GetInt16(9) }, iptal);

        if (istem is null || istem.Kaynak != KaynakDisKurum || istem.KurumId is not { } kurumId)
            return null;                       // yalnız dış kurum numunesi

        // ---------------------------------------------------- kurum türü
        //  Başvurunun carisi gönderen kurumdur; SGK ve ÖSS türü kurumlarda
        //  belge tetiği "devredilen kurum" (SSK/Bağ-Kur/…) ya da poliçe
        //  bekler - o bilgi HASTANIN güvencesinden gelir ve bu belgede
        //  hasta cari değildir. Dış laboratuvar işi zaten kuruma doğrudan
        //  fatura edilir: kurum kartındaki tür "Kurumu Öder" olmalı.
        //  Yanlış türle zorlamak, SGK'ya hiç gitmeyecek bir provizyon
        //  kaydı üretirdi.
        var kurumTuru = await baglanti.TekDegerAsync<int?>(
            "select tur from public.taraf_kurum where id = @p0", null, [kurumId], iptal);
        if (kurumTuru is null)
            return "Gönderen kurum, kurum kartı olarak tanımlı değil - başvuru açılamadı.";
        if (kurumTuru is 2 or 3)
            return $"Gönderen kurumun türü {(kurumTuru == 3 ? "SGK" : "ÖSS")}; "
                 + "dış kurum numunesi doğrudan kuruma fatura edilir. "
                 + "Kurum kartında türü \"Kurumu Öder\" yapın - ücretlendirme yapılmadı.";

        // ------------------------------------------------------- sözleşme
        //  Birden çok geçerli sözleşme varsa EN YENİSİ: eski sözleşmenin
        //  fiyatıyla yeni işi faturalamak, kurumla aradaki anlaşmayı
        //  sessizce çiğnemek olurdu.
        var sozlesme = await baglanti.TekAsync("""
            select s.id, s.fiyat_listesi_id
              from public.kurum_sozlesme s
             where s.kurum_id = @p0 and s.durum = 1
               and (s.baslangic is null or s.baslangic <= current_date)
               and (s.bitis is null or s.bitis >= current_date)
             order by s.baslangic desc nulls last, s.id desc limit 1
            """, null, [kurumId],
            o => new { Id = o.GetInt32(0),
                       ListeId = o.IsDBNull(1) ? (int?)null : o.GetInt32(1) }, iptal);

        var listeId = sozlesme?.ListeId
            ?? await baglanti.TekDegerAsync<int?>("""
                select id from public.fiyat_listesi
                 where varsayilan = 1 and durum = 1 order by id limit 1
                """, null, [], iptal);

        if (listeId is null)
            return "Fiyat listesi bulunamadı - dış kurum başvurusu açılamadı.";

        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // --------------------------------------------------------- başvuru
        var belgeId = istem.BelgeId ?? 0;
        var yeniBelge = belgeId == 0;
        if (yeniBelge)
        {
            var belgeNo = await baglanti.TekDegerAsync<string>("""
                select public.fn_numara_kimlik_uret(19, @p0, 'belge', 'belge_no', @p1::date)
                """, islem, [istem.SubeId, istem.Tarih], iptal) ?? "";

            belgeId = await baglanti.TekDegerAsync<int>("""
                insert into public.belge
                       (tur, tipi, taraf_id, taraf_unvan, belge_no, belge_tarihi,
                        sube_id, durum, kdv_durum, fiyat_listesi_id, aciklama,
                        matrah, kdv_tutari, genel_toplam, ekleyen)
                -- kdv_durum METIN ('Dahil'/'Hariç'/'Muaf'): liste fiyatlari
                --   KDV dahil tutuluyor, belge de dahil calisir.
                select @p0, @p1, t.id, t.unvan, @p2, @p3, @p4, 0, 'Dahil', @p5,
                       -- Açıklamada HASTA ADI da durur: belgeye bakan
                       --   kişi numunenin kime ait olduğunu kolon
                       --   aramadan görsün.
                       'Dış kurum numunesi · Hasta: '
                         || coalesce((select coalesce(nullif(trim(x.unvan), ''),
                                                     trim(x.ad || ' ' || x.soyad))
                                        from public.taraf x where x.id = @p9), '?')
                         || ' · İstem ' || @p6::text,
                       0, 0, 0, @p7
                  from public.taraf t where t.id = @p8
                returning id
                """, islem,
                [BasvuruTuru, BasvuruTipi, belgeNo, istem.Tarih, istem.SubeId,
                 listeId, istem.Id, baglam.KullaniciId, kurumId, istem.HastaId], iptal);

            await baglanti.CalistirAsync("""
                -- HASTA AYRI ALANDA (658): cari gönderen kurum, hasta bu.
                insert into public.belge_basvuru
                       (id, odeyen_kurum_id, sozlesme_id, bolum_id, personel_id,
                        basvuru_turu, hasta_id, ekleyen)
                values (@p0, @p1, @p2, nullif(@p3, 0), @p4, 1, @p6, @p5)
                """, islem,
                [belgeId, kurumId, sozlesme?.Id, (int)istem.Bolum,
                 istem.PersonelId, baglam.KullaniciId, istem.HastaId], iptal);

            await baglanti.CalistirAsync(
                "update public.lab_istem set belge_id = @p1 where id = @p0",
                islem, [istem.Id, belgeId], iptal);
        }

        // ------------------------------------------------- ücret satırları
        //  Fatura kalemi PANEL varsa paneldir: hemogramın 23 parametresi ayrı
        //  ayrı ücretlendirilmez, SUT'ta tek kalemdir. Panelsiz satırda
        //  tetkiğin kendi hizmeti kullanılır.
        //  Zaten belgede olan hizmet ATLANIR - istem her kaydedildiğinde
        //  aynı tetkik yeniden eklenirse numune iki kez faturalanırdı.
        var eklenen = await baglanti.TekDegerAsync<int>("""
            with kalem as (
                select distinct coalesce(lp.hizmet_id, lt.hizmet_id) as hizmet_id
                  from public.lab_istem_satir s
                  left join public.lab_tetkik lt on lt.id = s.tetkik_id
                  left join public.lab_panel lp on lp.id = s.panel_id
                 where s.istem_id = @p0 and s.durum <> 0
                   and coalesce(lp.hizmet_id, lt.hizmet_id) is not null),
            yeni as (
                select k.hizmet_id, h.ad, coalesce(h.kdv, 0) as kdv,
                       coalesce(f.fiyat, 0) as brut
                  from kalem k
                  join public.hizmet h on h.id = k.hizmet_id
                  left join lateral public.fn_fiyat_listesi_fiyat(@p1, null, k.hizmet_id) f
                         on true
                 where not exists (select 1 from public.belge_satir bs
                                    where bs.belge_id = @p2 and bs.hizmet_id = k.hizmet_id)),
            yazilan as (
                insert into public.belge_satir
                       (belge_id, sira, tur, hizmet_id, aciklama, miktar, adet, birim,
                        birim_fiyat, kdv, tutar, tutar_kdvli, sube_id, ekleyen)
                select @p2,
                       coalesce((select max(bs.sira) from public.belge_satir bs
                                  where bs.belge_id = @p2), 0)
                         + row_number() over (order by y.ad),
                       2, y.hizmet_id, '', 1, 1, 0,
                       -- Liste fiyatı KDV DAHİL tutulur (kurulum listeleri
                       --   kdv_dahil = 1): birim fiyat matrahtır, brüt
                       --   `tutar_kdvli`de durur - BelgeHesap ile aynı düzen.
                       round(y.brut / (1 + y.kdv / 100.0), 6),
                       y.kdv,
                       round(y.brut / (1 + y.kdv / 100.0), 2),
                       y.brut, @p3, @p4
                  from yeni y
                returning 1)
            select count(*)::int from yazilan
            """, islem, [istem.Id, listeId, belgeId, istem.SubeId, baglam.KullaniciId], iptal);

        // Başlık toplamları satırlardan türetilir - iki yerde ayrı hesap,
        //   zamanla ayrışan iki toplam demekti.
        await baglanti.CalistirAsync("""
            update public.belge b
               set matrah = k.matrah, kdv_tutari = k.kdv, genel_toplam = k.brut,
                   degistiren = @p1, degistirme_tarihi = now()
              from (select coalesce(sum(tutar), 0) as matrah,
                           coalesce(sum(tutar_kdvli), 0) - coalesce(sum(tutar), 0) as kdv,
                           coalesce(sum(tutar_kdvli), 0) as brut
                      from public.belge_satir where belge_id = @p0) k
             where b.id = @p0
            """, islem, [belgeId, baglam.KullaniciId], iptal);

        await islem.CommitAsync(iptal);

        var mesaj = yeniBelge
            ? $"Dış kurum başvurusu açıldı ({eklenen} tetkik ücretlendirildi)."
            : eklenen > 0 ? $"{eklenen} tetkik başvuruya eklendi." : null;

        // ------------------------------------------------------- tahakkuk
        if (istem.Durum != IstemSonuclandi)
            return mesaj;

        var tahakkuk = await TahakkukKesAsync(belgeId, baglam, iptal);
        return tahakkuk is null ? mesaj : $"{mesaj} {tahakkuk}".Trim();
    }

    /// <summary>
    /// Başvuruyu SATIŞ TAHAKKUKUNA çevirir ve kapatır. Zaten kapanmışsa
    /// (kapanma_durum > 0) ikinci kez kesilmez - aynı iş iki kez tahakkuk
    /// ederse kuruma iki kez borç yazılırdı.
    /// </summary>
    private async Task<string?> TahakkukKesAsync(int belgeId, IstekBaglami baglam,
                                                 CancellationToken iptal)
    {
        var kapanma = await _veri.TekDegerAsync<int>(
            "select coalesce(kapanma_durum, 0) from public.belge where id = @p0",
            [belgeId], iptal);
        if (kapanma > 0) return null;

        var satirlar = await _veri.ListeAsync("""
            select id, coalesce(adet, miktar, 1)
              from public.belge_satir where belge_id = @p0 order by sira, id
            """, [belgeId],
            o => (o.GetInt32(0), o.GetDecimal(1), (decimal?)null, (decimal?)null), iptal);

        if (satirlar.Count == 0) return null;

        try
        {
            var (tahakkukId, _) = await _belgeler.DonusturAsync(
                belgeId, TahakkukTuru, satirlar, null, false, baglam.Yazma, iptal);
            return $"Kuruma tahakkuk kesildi (belge {tahakkukId}).";
        }
        catch (GentegreHatasi h)
        {
            // Tahakkuk düşerse İSTEM kaydı durur: sonuç onaylandı, iş bitti;
            //   muhasebe adımı elle tamamlanabilir.
            _gunluk.LogWarning("Dış kurum tahakkuku kesilemedi (belge {Belge}): {Mesaj}",
                belgeId, h.Message);
            return $"Tahakkuk kesilemedi: {h.Message}";
        }
    }
}
