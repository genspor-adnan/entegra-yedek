using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// LABORATUVAR — SONUÇ, ONAY, DÜZELTME VE PANİK DEĞER.
///
/// <para><b>Kural motoru sonuç YAZILIRKEN çalışır:</b> bayrak, panik ve delta
/// sonucun kendisiyle saklanır; rapor ve ekran hesap yapmaz. Referans
/// aralığı sonradan değişse bile o gün verilen rapor aynı kalır.
///
/// <para><b>Onaylı sonuç güncellenmez:</b> düzeltme eski satırı iptal edip
/// yenisini açar, rapor "düzeltilmiş" damgası taşır. Panik bildirimi,
/// teyit eden kişi ve saat yazılana kadar kapanmaz.</para></para>
///
/// <para>Sınıfın kendisi ve ortak yardımcıları <c>LabServisi.cs</c>
/// içindedir (aynı partial sınıf).</para>
/// </summary>
public sealed partial class LabServisi
{
    public sealed record SonucSonucu(long SonucId, string Bayrak, bool Panik,
                                     bool DeltaUyari, string Mesaj);

    /// <summary>
    /// Sonuç yazar ve kuralları uygular: referans aralığı (yaş/cinsiyet),
    /// bayrak, panik, delta check.
    ///
    /// OTO-ONAY yalnız TEMİZ sonuçta: panik, delta uyarısı ya da bayrak varsa
    /// insan bakar. Bayraklı sonucu otomatik onaylamak, kural motorunu
    /// süsleme hâline getirirdi.
    /// </summary>
    public async Task<SonucSonucu> SonucYazAsync(SonucIstegi istek, int? cihazId,
        long? cihazMesajId, IstekBaglami baglam, CancellationToken iptal,
        string? hamDeger = null, string? hamBirim = null, bool otoOnaySerbest = true)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var s = await baglanti.TekAsync("""
            select s.id, s.istem_id, s.tetkik_id, s.numune_id, i.taraf_id, i.sube_id,
                   t.birim, t.ondalik, t.panik_alt, t.panik_ust, t.delta_yuzde,
                   t.delta_gun, t.oto_onay, t.tur,
                   coalesce(s.cihaz_id, t.varsayilan_cihaz_id) as cihaz_id
              from public.lab_istem_satir s
              join public.lab_istem i on i.id = s.istem_id
              join public.lab_tetkik t on t.id = s.tetkik_id
             where s.id = @p0
            """, islem, [istek.IstemSatirId],
            o => new { Id = o.GetInt32(0), IstemId = o.GetInt32(1), TetkikId = o.GetInt32(2),
                       NumuneId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                       HastaId = o.GetInt32(4), SubeId = o.GetInt32(5),
                       Birim = o.GetString(6), Ondalik = o.GetInt16(7),
                       PanikAlt = o.IsDBNull(8) ? (decimal?)null : o.GetDecimal(8),
                       PanikUst = o.IsDBNull(9) ? (decimal?)null : o.GetDecimal(9),
                       DeltaYuzde = o.GetDecimal(10), DeltaGun = o.GetInt32(11),
                       OtoOnay = o.GetInt16(12), Tur = o.GetInt16(13),
                       CihazId = o.IsDBNull(14) ? (int?)null : o.GetInt32(14) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem satırı bulunamadı.");

        // TEST SEVİYESİNDE YETKİ (889): göremeyen yazamaz.
        await SatirTestYetkisiIsteAsync(baglanti, islem, istek.IstemSatirId, baglam, iptal);

        // SONUÇ DOĞRULAMA (893, KTS L1): boş ya da anlamsız sonuç YAZILMAZ.
        //   Sayısal tetkike metin, fizyolojik olarak imkânsız değer ve boş
        //   sonuç engeldir; ölçüm aralığı dışı UYARIDIR - sonucu düşürmek
        //   veriyi kaybettirir, ama otomatik onaylanmamalı.
        var dogrulama = await baglanti.TekAsync("""
            select durum, mesaj from public.fn_lab_sonuc_dogrula(@p0, @p1)
            """, islem, [s.TetkikId, istek.Deger ?? ""],
            o => new { Durum = o.GetInt16(0), Mesaj = o.GetString(1) }, iptal);

        if (dogrulama is { Durum: 2 })
            throw GentegreHatasi.IsKurali(dogrulama.Mesaj,
                new { kod = SonucDogrulamaKodu });

        var dogrulamaUyarisi = dogrulama is { Durum: 1 } ? dogrulama.Mesaj : "";

        // REFERANS ARALIĞI hastanın yaş/cinsiyetine VE ÖLÇÜMÜN YAPILDIĞI
        //   CİHAZA göre (888). Aynı tetkikin aralığı yönteme bağlıdır;
        //   iki cihazlı laboratuvarda tek aralık kullanmak bir cihazın
        //   sonuçlarını sistematik olarak yanlış bayraklar. Sonucu getiren
        //   cihaz bilinmiyorsa satırın/tetkikin cihazına düşülür, o da
        //   yoksa genel aralık kullanılır.
        var r = await baglanti.TekAsync("""
            select alt, ust, metin, panik_alt, panik_ust
              from public.fn_lab_referans(@p0, @p1, current_date, @p2)
             where tetkik_id is not null
            """, islem, [s.TetkikId, s.HastaId, cihazId ?? s.CihazId],
            o => new { Alt = o.IsDBNull(0) ? (decimal?)null : o.GetDecimal(0),
                       Ust = o.IsDBNull(1) ? (decimal?)null : o.GetDecimal(1),
                       Metin = o.GetString(2),
                       PanikAlt = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                       PanikUst = o.IsDBNull(4) ? (decimal?)null : o.GetDecimal(4) }, iptal);

        var panikAlt = r?.PanikAlt ?? s.PanikAlt;
        var panikUst = r?.PanikUst ?? s.PanikUst;
        var sayisal = Cekirdek.Cihaz.CihazCevrim.Sayi(istek.Deger);

        var bayrak = await baglanti.TekDegerAsync<string>(
            "select public.fn_lab_bayrak(@p0, @p1, @p2, @p3, @p4)", islem,
            [sayisal, r?.Alt, r?.Ust, panikAlt, panikUst], iptal) ?? "";

        // DELTA CHECK: önceki ONAYLI sonuçla karşılaştırılır. Onaylanmamış
        //   ara sonuçla karşılaştırmak, yanlış bir değere göre uyarı üretirdi.
        decimal? oncekiDeger = null, deltaYuzde = null;
        var deltaUyari = false;
        if (sayisal is { } d && s.DeltaYuzde > 0 && s.DeltaGun > 0)
        {
            oncekiDeger = await baglanti.TekDegerAsync<decimal?>("""
                select ls.deger_sayisal
                  from public.lab_sonuc ls
                  join public.lab_istem_satir lis on lis.id = ls.istem_satir_id
                  join public.lab_istem li on li.id = lis.istem_id
                 where ls.tetkik_id = @p0 and li.taraf_id = @p1 and ls.durum = 3
                   and ls.deger_sayisal is not null
                   and ls.olcum_zamani >= now() - make_interval(days => @p2)
                 order by ls.olcum_zamani desc nulls last, ls.id desc
                 limit 1
                """, islem, [s.TetkikId, s.HastaId, s.DeltaGun], iptal);

            if (oncekiDeger is { } onceki && onceki != 0)
            {
                deltaYuzde = Math.Abs((d - onceki) / onceki * 100);
                deltaUyari = deltaYuzde >= s.DeltaYuzde;
            }
        }

        // KARAR SINIRI (896, KTS L15): referans aralığından AYRI bilgi -
        //   "referans aralığında ama hedefin üstünde" ancak ikisi birden
        //   söylenince anlaşılır. Bayrağı EZMEZ; sonuca DONAR, çünkü
        //   kılavuz sonradan değişse bile eski rapor kendi eşiğiyle
        //   okunmalı (888 referansında verdiğimiz kararın aynısı).
        var kararNotu = await baglanti.TekDegerAsync<string>("""
            select public.fn_lab_karar_notu(@p0, @p1, @p2)
            """, islem, [s.TetkikId, s.HastaId, sayisal], iptal) ?? "";

        var panik = bayrak is "LL" or "HH";

        // SERUM İNDEKSİ (444): hemolizli numunede potasyum YALANCI YÜKSEK
        //   çıkar (eritrosit içi potasyum seruma karışır); lipemi bazı
        //   yöntemlerde yalancı düşüklük yapar. Etkilenen testin sonucu
        //   kaydedilir ama oto-onaya girmez; ret eşiğinde satır "tekrar
        //   numune bekliyor"a alınır - ölçülmüş bir değeri yok saymak,
        //   teknisyenin cihazda gördüğü ile sistemin gösterdiğini ayırırdı.
        var indeks = s.NumuneId is null ? null : await baglanti.TekAsync("""
            select durum, uyari from public.fn_lab_indeks_etki(@p0, @p1)
            """, islem, [s.TetkikId, s.NumuneId],
            o => new { Durum = o.GetInt16(0), Uyari = o.GetString(1) }, iptal);

        var indeksDurum = (short)(indeks?.Durum ?? 0);
        var indeksUyari = indeks?.Uyari ?? "";

        // KALİTE KONTROL (442): testin son KK ölçümü RET ise oto-onay kapanır.
        //   Kural motorunun "temiz sonuç" kararı, cihazın o gün doğru ölçtüğü
        //   varsayımına dayanır; kontrol tutmuyorsa varsayım çürümüştür.
        //   Sonuç yine KAYDEDİLİR - uzman görüp karar verir.
        var kkGecerli = await baglanti.TekDegerAsync<bool>(
            "select public.fn_lab_kk_gecerli(@p0)", islem, [s.TetkikId], iptal);

        // Oto-onay: kural motoru TEMİZ dediyse. DÜZELTMEDE kapalıdır -
        //   daha önce onaylanmış bir sonucu değiştiren satırın ikinci bir göz
        //   görmeden yayınlanması, düzeltmenin kendisini denetimsiz bırakırdı.
        // ÇİFT ONAY ZORUNLUYSA OTO-ONAY YOK (895, KTS L4): oto-onay tek
        //   aşamalı yayındır; iki seviyeli onay kuralını sessizce delerdi.
        var ciftOnayZorunlu = await baglanti.TekDegerAsync<bool>("""
            select zorunlu from public.v_lab_cift_onay where tetkik_id = @p0
            """, islem, [s.TetkikId], iptal);

        var otoOnay = otoOnaySerbest && s.OtoOnay == 1 && bayrak == "N"
                      && !ciftOnayZorunlu
                      && !panik && !deltaUyari && kkGecerli && indeksDurum == 0
                      // DOĞRULAMA UYARISI OTO-ONAYI KAPATIR (893): ölçüm
                      //   aralığı dışındaki bir değeri kimse görmeden
                      //   yayınlamak, "anlamsız sonuç gönderilemez"
                      //   kuralını delerdi.
                      && dogrulamaUyarisi.Length == 0;

        // ÖNCEKİ AKTİF SONUÇ: aynı satıra ikinci kez yazmak iki CANLI sonuç
        //   bırakıyordu (aynı tetkikte 30 ve 130 yan yana durdu; ekran son
        //   yazılanı gösteriyor, onay kuyruğu ötekini de taşıyordu).
        //   ONAYLANMAMIŞ önceki sonuç düzeltme değil TEKRAR GİRİŞTİR:
        //   iptal edilir, izi `duzeltme_neden`de kalır. ONAYLI sonucun
        //   üzerine elle yazılamaz - düzeltme ayrı işlemdir (neden
        //   zorunlu, oto-onay kapalı, eski satır damgalı).
        var oncekiSonuc = await baglanti.TekAsync("""
            select id, durum from public.lab_sonuc
             where istem_satir_id = @p0 and durum <> 4
             order by id desc limit 1
            """, islem, [s.Id],
            o => new { Id = o.GetInt64(0), Durum = o.GetInt16(1) }, iptal);

        if (oncekiSonuc is not null)
        {
            if (oncekiSonuc.Durum >= 3)
                throw GentegreHatasi.IsKurali(
                    "Bu tetkikte onaylı sonuç var - değiştirmek için düzeltme yapın "
                    + "(neden zorunlu, eski sonuç iptal edilip yenisi açılır).");

            await baglanti.CalistirAsync("""
                update public.lab_sonuc
                   set durum = 4, duzeltme_neden = 'Yeniden girildi (onaysızdı)',
                       degistiren = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, islem, [oncekiSonuc.Id, baglam.KullaniciId], iptal);
        }

        var sonucId = await baglanti.TekDegerAsync<long>("""
            insert into public.lab_sonuc
                   (istem_satir_id, numune_id, tetkik_id, deger_sayisal, deger_metin,
                    birim, ham_deger, ham_birim, cihaz_id, cihaz_mesaj_id, olcum_zamani,
                    bayrak, referans_alt, referans_ust, referans_metin, panik,
                    delta_onceki, delta_yuzde, delta_uyari, dilusyon, yorum,
                    durum, oto_onay, onay_id, onay_zamani, sube_id, ekleyen,
                    indeks_durum, indeks_uyari, karar_notu)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, now(),
                    @p10, @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19,
                    -- İNDEKS RET eşiği: sonuç "tekrar bekliyor" (5) durumunda
                    --   durur; onaylı sayılmaz ama kaydı da kaybolmaz.
                    case when @p23 = 2 then 5
                         when @p20 = 1 then 3 else 1 end, @p20,
                    case when @p20 = 1 then @p21 else null end,
                    case when @p20 = 1 then now() else null end, @p22, @p21,
                    @p23, @p24, @p25)
            returning id
            """, islem,
            [s.Id, s.NumuneId, s.TetkikId, sayisal, istek.Deger,
             string.IsNullOrWhiteSpace(istek.Birim) ? s.Birim : istek.Birim,
             hamDeger ?? istek.Deger, hamBirim ?? "", cihazId, cihazMesajId,
             bayrak, r?.Alt, r?.Ust,
             r?.Metin ?? "", (short)(panik ? 1 : 0), oncekiDeger, deltaYuzde,
             (short)(deltaUyari ? 1 : 0), istek.Dilusyon,
             // UYARI SONUCUN YORUMUNA DA DÜŞER (893): onaylayan uzman
             //   değere neden bakması gerektiğini satırın yanında görmeli.
             string.Join(" · ", new[] { istek.Yorum ?? "", dogrulamaUyarisi }
                                .Where(x => x.Length > 0)),
             (short)(otoOnay ? 1 : 0), baglam.KullaniciId, s.SubeId,
             indeksDurum, indeksUyari, kararNotu], iptal);

        // Satır durumu: oto-onayda 5 (onaylı), indeks RET'inde 6 (tekrar
        //   numune bekliyor), diğerinde 3 (sonuçlandı, onay bekliyor).
        //
        // SATIRIN sonuc/birim/referans/isaret KOLONLARI AYNADIR: asıl sonuç
        //   lab_sonuc'ta (onay ve düzeltme geçmişi tek satıra sığmıyor), ama
        //   istem kartının "Tetkikler" gridi, raporlar ve eski ekranlar bu
        //   kolonlardan okuyor. Yazmayınca kullanıcı sonucu girdiği hâlde
        //   kartta BOŞ görüyordu - iki depo arasında sessiz bir ayrışma.
        //   Ayna TEK YÖNLÜ: kaynak daima lab_sonuc, buraya yalnız kopyalanır.
        await baglanti.CalistirAsync("""
            update public.lab_istem_satir
               set durum = case when @p2 = 2 then 6
                                when @p1 = 1 then 5 else 3 end,
                   sonuc = @p3, birim = @p4, referans = @p5, isaret = @p6,
                   -- GİRİŞİN KAYNAĞI GÖRÜNÜR OLSUN (kullanıcı: "sonucu elle
                   --   değiştirdiğim / girdiğim bilgisi nerede"): cihaz
                   --   bağlantısı yoksa kolon "Elle giriş" der; kim ve ne
                   --   zaman bilgisi lab_sonuc.ekleyen/olcum_zamani'nda durur.
                   -- CASTLER ZORUNLU: cihazId NULL gelince Npgsql
                   --   parametrenin tipini bildiremiyor ("could not determine
                   --   data type of parameter") ve sonuc yazimi patliyordu.
                   cihaz = case
                             -- ELLE GIRIS IKONLA (kullanici: "elle yerine
                             --   ikon ciksin"): kalem isareti + giren kisi.
                             --   "Elle · Ad" dar kolonda kisi adini kirpiyordu.
                             when @p7::int is null then coalesce(
                                    (select '✍ ' || k.ad
                                       from public.v_kullanici_lookup k
                                      where k.id = @p8::int), '✍')
                             else coalesce(
                                    (select coalesce(c.kod, c.ad)
                                       from public.cihaz c where c.id = @p7::int),
                                    'Cihaz') end,
                   sonuc_tarihi = now()
             where id = @p0
            """, islem,
            [s.Id, (short)(otoOnay ? 1 : 0), indeksDurum,
             istek.Deger,
             string.IsNullOrWhiteSpace(istek.Birim) ? s.Birim : istek.Birim,
             AralikMetni(r?.Alt, r?.Ust, r?.Metin ?? ""),
             IsaretKodu(bayrak, panik),
             cihazId, baglam.KullaniciId], iptal);

        // REFLEKS TEST (873 §6): sonuç eşiği aşınca ikincil tetkik aynı isteme
        //   ve numuneye eklenir; hekim müdahalesi yok, kayıt lab_akilci_gerekce.
        var refleks = await RefleksUygulaAsync(baglanti, islem, s.IstemId, s.TetkikId, s.NumuneId,
                                               s.HastaId, s.SubeId, sayisal, bayrak, baglam, iptal);

        // TEKRAR TALEBİNİ KAPAT (891, KTS L8): bu satıra açık bir tekrar
        //   talebi varsa yeni sonuç onun cevabıdır. Elle kapatmaya bırakmak,
        //   çalışılmış ama kuyrukta duran talepler biriktirirdi.
        var tekrarKarsilandi = await baglanti.TekDegerAsync<int?>(
            "select public.fn_lab_tekrar_karsila(@p0, @p1, @p2)", islem,
            [s.Id, sonucId, baglam.KullaniciId], iptal) is not null;

        await IstemDurumTazeleAsync(baglanti, islem, s.IstemId, iptal);
        await islem.CommitAsync(iptal);

        var mesaj = panik
            ? $"PANİK DEĞER ({bayrak}) - hekime bildirilmeli."
            : deltaUyari
                ? $"Delta uyarısı: önceki {oncekiDeger:0.##}, değişim %{deltaYuzde:0.#}"
                : otoOnay ? "Sonuç girildi ve otomatik onaylandı."
                : indeksDurum == 2
                    ? $"Sonuç girildi ({bayrak}) ama NUMUNE UYGUNSUZ: {indeksUyari}. "
                      + "Tetkik tekrar numune bekliyor."
                : indeksDurum == 1
                    ? $"Sonuç girildi ({bayrak}) - {indeksUyari}; otomatik onaylanmadı."
                : !kkGecerli
                    ? $"Sonuç girildi ({bayrak}) - KALİTE KONTROL RET durumunda "
                      + "olduğu için otomatik onaylanmadı."
                    : $"Sonuç girildi ({bayrak}).";
        if (refleks.Count > 0) mesaj += $" Refleks test eklendi: {string.Join(", ", refleks)}.";
        // KARAR SINIRI MESAJDA DA SÖYLENİR: sonucu giren kişi, değerin
        //   referans aralığında olsa bile hedefin dışında olduğunu görmeli.
        if (kararNotu.Length > 0) mesaj += $" {kararNotu}.";
        if (dogrulamaUyarisi.Length > 0)
            mesaj += $" DOĞRULAMA UYARISI: {dogrulamaUyarisi} Otomatik onaylanmadı.";
        if (tekrarKarsilandi) mesaj += " Tekrar talebi karşılandı.";
        return new SonucSonucu(sonucId, bayrak, panik, deltaUyari, mesaj);
    }

    /// <summary>
    /// Onay: 1 teknik (teknisyen), 2 uzman. Uzman onayı sonucu YAYINLAR.
    /// Onaylı sonuç bir daha değişmez - düzeltme ayrı bir işlemdir.
    /// </summary>
    /// <param name="istemId">
    /// Onaylanan sonucun istemi - cagirana DONER cunku e-Nabiz 105 paketi
    /// istem basina uretilir (632) ve ucun ayni sorguyu ikinci kez yazmasi
    /// gerekmesin.
    /// </param>
    /// <summary>İstemcinin ayırt edebilmesi için (893): doğrulama engeli.</summary>
    public const string SonucDogrulamaKodu = "SONUC_DOGRULAMA";

    /// <summary>İki seviyeli onay engeli (895): eksik teknik onay / dört göz.</summary>
    public const string CiftOnayKodu = "CIFT_ONAY";

    public async Task<(string Mesaj, int IstemId)> OnaylaAsync(
        long sonucId, short asama, IstekBaglami baglam, CancellationToken iptal)
    {
        // BOŞ SONUÇ ONAYLANAMAZ (893, KTS L1): onay, sonucu kurumun
        //   sahiplenmesidir - sahiplenilecek bir değer yoksa onay da olmaz.
        //   Sonuç yazarken denetleniyor ama eski/geçmiş satırlar ve dış
        //   yollar için kapı burada da kapalı.
        var bos = await _veri.TekDegerAsync<bool>("""
            select coalesce(nullif(trim(r.deger_metin), ''), '') = ''
                   and r.deger_sayisal is null
              from public.lab_sonuc r where r.id = @p0
            """, [sonucId], iptal);
        if (bos)
            throw GentegreHatasi.IsKurali(
                "Boş sonuç onaylanamaz - değeri girin ya da sonucu iptal edin.",
                new { kod = SonucDogrulamaKodu });

        // TEST SEVİYESİNDE YETKİ (889): kısıtlı tetkiki yalnız izinli rol
        //   onaylar - onay, sonucu kurumun sahiplenmesidir.
        await SonucTestYetkisiIsteAsync(sonucId, baglam, "onayla", iptal);

        // İKİ SEVİYELİ ONAY (895, KTS L4): teknik onay zorunluysa uzman
        //   onayı onu bekler; dört göz kuralı açıksa teknik onayı veren
        //   kişi aynı sonucu yayınlayamaz. İkisi de AYAR - kapalıyken
        //   bugünkü davranış birebir sürer.
        var onayKural = await _veri.TekAsync("""
            select durum, mesaj from public.fn_lab_onay_kontrol(@p0, @p1, @p2)
            """, [sonucId, asama, baglam.KullaniciId],
            o => new { Durum = o.GetInt16(0), Mesaj = o.GetString(1) }, iptal);

        if (onayKural is { Durum: 2 })
            throw GentegreHatasi.IsKurali(onayKural.Mesaj, new { kod = CiftOnayKodu });

        var alan = asama == 1 ? "teknik_onay" : "onay";
        var yeniDurum = asama == 1 ? 2 : 3;

        var etkilenen = await _veri.CalistirAsync($"""
            update public.lab_sonuc
               set {alan}_id = @p1, {alan}_zamani = now(), durum = @p2,
                   degistiren = @p1, degistirme_tarihi = now()
             where id = @p0 and durum < 3
            """, [sonucId, baglam.KullaniciId, (short)yeniDurum], iptal);

        if (etkilenen == 0)
            throw GentegreHatasi.IsKurali(
                "Sonuç zaten onaylı ya da iptal edilmiş - düzeltme için yeni satır açın.");

        if (asama == 2)
            await _veri.CalistirAsync("""
                update public.lab_istem_satir s set durum = 5
                  from public.lab_sonuc ls
                 where ls.id = @p0 and s.id = ls.istem_satir_id
                """, [sonucId], iptal);

        await using var baglanti = await _veri.AcAsync(iptal);
        var istemId = await baglanti.TekDegerAsync<int>("""
            select s.istem_id from public.lab_sonuc ls
              join public.lab_istem_satir s on s.id = ls.istem_satir_id
             where ls.id = @p0
            """, null, [sonucId], iptal);
        await IstemDurumTazeleAsync(baglanti, null, istemId, iptal);

        return (asama == 1 ? "Teknik onay verildi." : "Sonuç onaylandı ve yayınlandı.",
                istemId);
    }

    /// <summary>
    /// Düzeltme: eski satır İPTAL (durum 4), yenisi açılır. Rapor
    /// "düzeltilmiş" damgası taşıyacak.
    /// </summary>
    public async Task<SonucSonucu> DuzeltAsync(long sonucId, string yeniDeger,
        string neden, IstekBaglami baglam, CancellationToken iptal)
    {
        // Düzeltme de sonucu değiştirmektir (889).
        await SonucTestYetkisiIsteAsync(sonucId, baglam, "gor", iptal);

        if (string.IsNullOrWhiteSpace(neden))
            throw GentegreHatasi.Dogrulama("Düzeltme nedeni zorunlu.",
                [new("neden", "Onaylı sonucun neden değiştiğini yazın.")]);

        var eski = await _veri.TekAsync("""
            select istem_satir_id, tekrar_no from public.lab_sonuc where id = @p0
            """, [sonucId],
            o => new { SatirId = o.GetInt32(0), TekrarNo = o.GetInt16(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Sonuç bulunamadı.");

        await _veri.CalistirAsync("""
            update public.lab_sonuc
               set durum = 4, duzeltme_neden = @p1, degistiren = @p2,
                   degistirme_tarihi = now()
             where id = @p0
            """, [sonucId, neden, baglam.KullaniciId], iptal);

        var yeni = await SonucYazAsync(
            new SonucIstegi(eski.SatirId, yeniDeger, null, $"Düzeltme: {neden}", null),
            null, null, baglam, iptal, otoOnaySerbest: false);

        await _veri.CalistirAsync("""
            update public.lab_sonuc set tekrar_no = @p1 where id = @p0
            """, [yeni.SonucId, (short)(eski.TekrarNo + 1)], iptal);

        return yeni with { Mesaj = "Sonuç düzeltildi (eski satır iptal edildi)." };
    }

    /// <summary>Panik değer bildirimi - teyit alınmadan bildirim tamam sayılmaz.</summary>
    public async Task<int> PanikBildirAsync(long sonucId, string bildirilenAd,
        short kanal, string aciklama, IstekBaglami baglam, CancellationToken iptal)
        => await _veri.TekDegerAsync<int>("""
            insert into public.lab_panik_bildirim
                   (sonuc_id, bildiren_id, bildirilen_ad, kanal, aciklama)
            values (@p0, @p1, @p2, @p3, @p4)
            returning id
            """, [sonucId, baglam.KullaniciId, bildirilenAd, kanal, aciklama], iptal);

    public async Task<string> PanikTeyitAsync(int bildirimId, string teyitEden,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var etkilenen = await _veri.CalistirAsync("""
            update public.lab_panik_bildirim
               set teyit_zamani = now(), teyit_eden = @p1
             where id = @p0 and teyit_zamani is null
            """, [bildirimId, teyitEden], iptal);
        return etkilenen > 0 ? "Teyit alındı." : "Bu bildirim zaten teyitli.";
    }

    // ================================================================== cihaz
}
