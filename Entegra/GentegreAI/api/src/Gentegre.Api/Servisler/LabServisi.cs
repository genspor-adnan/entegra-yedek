using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// LABORATUVAR İŞ AKIŞI (433) — istem, numune, sonuç, onay.
///
/// <para><b>Kural motoru sonuç YAZILIRKEN çalışır.</b> Bayrak, panik ve delta
/// sonucun kendisiyle birlikte saklanır; rapor ve ekran hesaplama yapmaz.
/// Sonradan referans aralığı değişse bile o gün verilen rapor aynı kalır -
/// hekimin gördüğü değerlendirme geçmişe dönük değişmemeli.</para>
///
/// <para><b>Onaylı sonuç güncellenmez.</b> Düzeltme, eski satırı iptal edip
/// yeni satır açar; rapor "düzeltilmiş" damgası taşır.</para>
///
/// <para><b>Sınıf konu başına parçalara ayrılmıştır</b> (1348 satırdı):
/// <c>LabServisi.Numune.cs</c> · <c>.Sonuc.cs</c> · <c>.Cihaz.cs</c>. Burada
/// istem açma ve bütün bölümlerin kullandığı yardımcılar kalır.</para>
/// </summary>
public sealed partial class LabServisi(VeriKaynagi veri, ILogger<LabServisi> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly ILogger<LabServisi> _gunluk = gunluk;

    public sealed record IstemSatiriIstegi(int? TetkikId, int? PanelId);

    /// <summary>İstemin kim/kime/nerede üçlüsü - başvurudan ya da dıştan.</summary>
    private sealed record IstemKaynagi(int HastaId, int HekimId, int SubeId);

    /// <summary>
    /// DIŞ KURUM NUMUNESİ İÇİN KAYNAK (637).
    ///
    /// Gönderen kurum ve hasta ZORUNLU, ikisi de doğrulanır:
    ///   * Kurum yoksa fatura kime kesilecek, sonuç kime teslim edilecek
    ///     belirsiz kalır - `ck_lab_istem_kaynak_baglanti` de bunu istiyor.
    ///   * Hasta yoksa sonuç hiçbir dosyaya yazılamaz. "İsimsiz tüp" kabul
    ///     etmek, sonucu sisteme girip kimseye bağlamamak olurdu.
    ///
    /// HEKİM YOK: isteyen hekim dış kurumdadır, bizim personel listemizde
    /// değil. `personel_id` boş bırakılır - yerine bir kullanıcı yazmak,
    /// istemi yapmayan birini isteyen göstermek olurdu.
    ///
    /// ŞUBE oturumdan gelir: numuneyi kabul eden laboratuvar hangisiyse.
    /// </summary>
    private async Task<IstemKaynagi> DisKaynakAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int? hastaId, int? disKurumId, IstekBaglami baglam, CancellationToken iptal)
    {
        if (disKurumId is not > 0)
            throw GentegreHatasi.Dogrulama(
                "Başvurusuz istemde numuneyi gönderen kurum seçilmeli.",
                [new("disKurumId", "Dış kurum seçin ya da hastanın başvurusundan istem açın.")]);
        if (hastaId is not > 0)
            throw GentegreHatasi.Dogrulama(
                "Numunenin hastası seçilmeli - sonuç bir kişinin sonucudur.",
                [new("hastaId", "Hasta seçin; kayıtlı değilse önce hasta kartı açın.")]);

        var hastaVar = await baglanti.TekDegerAsync<int>(
            "select count(*) from public.taraf_hasta where id = @p0",
            islem, [hastaId.Value], iptal);
        if (hastaVar == 0)
            throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

        var kurumVar = await baglanti.TekDegerAsync<int>(
            "select count(*) from public.taraf_kurum where id = @p0",
            islem, [disKurumId.Value], iptal);
        if (kurumVar == 0)
            throw GentegreHatasi.Bulunamadi("Dış kurum bulunamadı.");

        return new IstemKaynagi(hastaId.Value, 0, baglam.SubeId ?? 0);
    }

    public sealed record SonucIstegi(int IstemSatirId, string Deger, string? Birim,
                                     string? Yorum, decimal? Dilusyon);

    // ================================================================== istem

    /// <summary>
    /// İstem açar; panel satırları tetkiklerine açılır.
    ///
    /// NUMUNE PLANI OTOMATİK: aynı tüp tipindeki tetkikler TEK barkoda bağlanır.
    /// Her tetkiğe ayrı tüp, hastadan gereksiz kan almak demekti.
    ///
    /// <para><b>İKİ GİRİŞ YOLU (637):</b> istem ya bir BAŞVURUYA ya bir DIŞ
    /// KURUMA bağlıdır.</para>
    ///
    /// <para><b>Başvurulu</b> (<paramref name="belgeId"/> dolu): hasta burada.
    /// Hasta, hekim ve şube başvurudan okunur; ücretlendirme, provizyon ve
    /// e-Nabız hep o başvuru üzerinden yürür.</para>
    ///
    /// <para><b>Dış kurum numunesi</b> (<paramref name="disKurumId"/> dolu):
    /// NUMUNE gelir, hasta gelmez. Başvuru açmak yapay olurdu - hasta kabul
    /// edilmedi, muayenesi yok, e-Nabız'a "hasta kabul" bildirmek yanlış olur
    /// ve fatura hastaya değil gönderen kuruma kesilir. Hasta kimliği yine
    /// ZORUNLU: sonuç bir kişinin sonucudur, kimsesiz bir tüp hiçbir dosyaya
    /// yazılamaz.</para>
    /// </summary>
    public async Task<int> IstemAcAsync(int? belgeId, IReadOnlyList<IstemSatiriIstegi> satirlar,
                                        short oncelik, string klinikBilgi, string taniIcd,
                                        IstekBaglami baglam, CancellationToken iptal,
                                        int? hastaId = null, int? disKurumId = null,
                                        short? kaynakKodu = null,
                                        IReadOnlyList<AkilciKarar>? akilci = null,
                                        bool akilciSessiz = false)
    {
        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali("En az bir tetkik ya da panel seçilmeli.");

        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // KAYNAK (433): 1 muayene istemi · 3 banko · 4 dış kurum · 5 check-up.
        //
        // BELGELİ İSTEMİN KAYNAĞINI ÇAĞIRAN SÖYLER (kullanici: "lab istemi
        //   kaynak muayene olmus, banko olmali degil mi"). Hepsini "muayene
        //   istemi" saymak yanlıştı: kayıt kabulde ücretlendirilip açılan
        //   istemi hekim istememiştir - hasta daha muayeneye girmemiş
        //   olabilir. Kaynak kabul kararını değiştiriyor (banko numunesi
        //   hemen alınır, muayene istemi hekimin yazdığı sıraya girer), o
        //   yüzden doğru yazılmalı.
        // DIŞ KURUM (912/913): kaynak = 4 GÖNDEREN KURUMDAN belli olur, belgeye
        //   bağlı olsun olmasın. Artık dış kabul de BAŞVURU üzerinden açılıyor
        //   (belgeId dolu gelir) - kaynağı `belgeId yok` ile anlamak yanlış
        //   olurdu; dış kurumlu istem başvurulu da olsa "dış kurum"dur.
        var disMi = belgeId is not > 0;
        var disKurumlu = disKurumId is > 0;
        short kaynak = disKurumlu ? (short)4 : (kaynakKodu ?? 1);

        var b = disMi
            ? await DisKaynakAsync(baglanti, islem, hastaId, disKurumId, baglam, iptal)
            : await baglanti.TekAsync("""
                select b.taraf_id, coalesce(bb.personel_id, 0), b.sube_id
                  from public.belge b
                  left join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, islem, [belgeId!.Value],
                o => new IstemKaynagi(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2)), iptal)
                ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

        // ISTEM NUMARASI TETIKTEN (641): burada uretilmiyor artik. Kart
        //   uzerinden acilan istem bu yoldan gecmiyor ve numarasiz
        //   kaliyordu; numarayi TABLONUN tetigine tasimak, hangi yoldan
        //   yazilirsa yazilsin ayni sayaci kullandiriyor. Yanitta donen
        //   numara kayittan okunur (`IstemOzetAsync`).

        // DIŞ KURUM INSERT'TE YAZILIR, sonradan UPDATE ile DEĞİL. 637'nin
        //   `ck_lab_istem_dis_kurum` kısıtı "kaynak 4 ise gönderen kurum dolu"
        //   diyor ve ERTELENEBİLİR DEĞİL: kurumu bir sonraki cümlede yazmak,
        //   INSERT'in daha o anda kısıtı ihlal etmesi demekti - dış kurum
        //   istemi açan uç 23514 ile düşüyordu. Kısıt sonradan eklenmiş ve
        //   bu yolu kırmış; kısıt doğru, yazım sırası yanlıştı.
        // SERBEST (912): poliklinik başvurusunda MUAYENE isteği (kaynak 1)
        //   banko ücretlendirmesi bekler (serbest=0) → numune kabul ekranında
        //   banko serbest bırakana kadar görünmez. Banko(3)/dış(4)/checkup(5)/
        //   teletıp(2) kaynak, acil öncelik ve acil/yatan başvuru bypass eder.
        var istemId = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (belge_id, taraf_id, sube_id, istem_no, istem_tarihi, bolum,
                    personel_id, durum, oncelik, kaynak, klinik_bilgi, tani_icd,
                    ekleyen, dis_kurum_id, serbest)
            values (@p0, @p1, @p2, '', now(), 1, @p3, 1, @p4, @p8, @p5, @p6, @p7, @p9,
                    public.fn_istem_serbest(
                        (select basvuru_turu from public.belge_basvuru where id = @p0)::smallint,
                        @p4::smallint, @p8::smallint))
            returning id
            """, islem,
            [belgeId is > 0 ? belgeId : null, b.HastaId, b.SubeId,
             b.HekimId == 0 ? null : b.HekimId,
             oncelik, klinikBilgi, taniIcd, baglam.KullaniciId, kaynak,
             disKurumlu ? disKurumId : (int?)null], iptal);

        // Panel -> tetkik acilimi. Ayni tetkik iki panelden gelirse BIR KEZ
        //   istenir: hastadan iki kez para alinmasi ve iki kez calisilmasi
        //   olmasin.
        var tetkikler = new List<(int TetkikId, int? PanelId)>();
        foreach (var s in satirlar)
        {
            // TETKİK VERİLDİYSE PANEL AÇILMAZ (638): satır hem tetkiği hem
            //   geldiği paneli taşıyabiliyor (`panel_id` yalnız köken bilgisi -
            //   rapor "hangi panelden" diye gösteriyor). Panel dalı önce
            //   bakarsa içerik ikinci kez açılır ve süzgeçten geçmiş tetkikler
            //   geri gelirdi.
            if (s.TetkikId is > 0)
                tetkikler.Add((s.TetkikId.Value, s.PanelId));
            else if (s.PanelId is > 0)
            {
                // PANEL OZYINELI ACILIR (500/501): icerik tek kaynakta
                //   (`hizmet_paket`) ve panel icinde panel olabiliyor
                //   (check-up > OGTT > glukozlar). `fn_hizmet_paket_ac`
                //   YAPRAK tetkikleri dondurur - istem yalniz calisilacak
                //   tetkikten acilir, ara paneller istem satiri uretmez.
                var pt = await baglanti.ListeAsync("""
                    select distinct t.id
                      from public.lab_panel p
                      join public.fn_hizmet_paket_ac(p.hizmet_id, 1) a on true
                      join public.lab_tetkik t on t.hizmet_id = a.hizmet_id
                     where p.id = @p0 and t.durum = 0
                     order by t.id
                    """, islem, [s.PanelId.Value], o => o.GetInt32(0), iptal);
                foreach (var t in pt) tetkikler.Add((t, s.PanelId));
            }
        }

        var tekil = tetkikler.GroupBy(x => x.TetkikId).Select(g => g.First()).ToList();
        if (tekil.Count == 0)
            throw GentegreHatasi.IsKurali("Seçilen panelde tetkik yok.");

        // TEST SEVİYESİNDE YETKİ (889, KTS L7): rolün isteyemediği tetkik
        //   ayıklanır. Akılcı kuralından ÖNCE: yetkisiz tetkikin akılcı
        //   gerekçesini sormak, sorulmaması gereken bir soruyu sormaktır.
        var yetkisiz = await TestYetkisiUygulaAsync(
            baglanti, islem, tekil.Select(t => t.TetkikId).ToList(), baglam, akilciSessiz, iptal);
        if (yetkisiz.Count > 0)
        {
            tekil = tekil.Where(t => !yetkisiz.Contains(t.TetkikId)).ToList();
            if (tekil.Count == 0)
                throw GentegreHatasi.Yasak(
                    "Seçilen tetkiklerin tamamı yetki kısıtlı; istem açılmadı.",
                    new { kod = TestYetkiKodu });
        }

        // AKILCI TEST İSTEMİ (873): kapalı/basamak = engel, branş/süre = gerekçeli
        //   uyarı. Etkileşimli istemde gerekçesiz uyarı 422 döner (istemci
        //   diyalog çizer, kararla yeniden gönderir); banko/başvuru isteminde
        //   sessiz: engelli tetkik atlanır, karar kaydı düşer.
        var (atlanan, akilciKayitlar) = await AkilciUygulaAsync(
            baglanti, islem, b, tekil.Select(t => t.TetkikId).ToList(), akilci, akilciSessiz, iptal);
        if (atlanan.Count > 0)
        {
            tekil = tekil.Where(t => !atlanan.Contains(t.TetkikId)).ToList();
            if (tekil.Count == 0)
            {
                // Hepsi engelli: istem açılmaz ama kararlar kalsın (Bakanlık izi).
                await AkilciKararlariYazAsync(baglanti, islem, null, null, b, akilciKayitlar, baglam, iptal);
                await islem.CommitAsync(iptal);
                throw GentegreHatasi.IsKurali("Seçilen tetkiklerin tamamı akılcı istem kuralıyla engelli; istem açılmadı.",
                                              new { kod = EngelKodu });
            }
        }

        // NUMUNE PLANI: tüp tipine göre grupla, her grup için bir barkod.
        var tupler = await baglanti.ListeAsync($"""
            select id, coalesce(nullif(tup_tipi, 0), 1) as tup, numune_tipi, kod, ad
              from public.lab_tetkik where id = any(@p0)
            """, islem, [tekil.Select(x => x.TetkikId).ToArray()],
            o => new { Id = o.GetInt32(0), Tup = o.GetInt16(1), Numune = o.GetInt16(2),
                       Kod = o.GetString(3), Ad = o.GetString(4) }, iptal);

        var numuneler = new Dictionary<short, int>();
        foreach (var grup in tupler.GroupBy(x => x.Tup))
        {
            var barkod = await baglanti.TekDegerAsync<string>(
                "select public.fn_lab_barkod_uret(@p0)", islem, [b.SubeId], iptal) ?? "";
            var numuneId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_numune
                       (barkod, istem_id, hasta_id, numune_tipi, tup_tipi, durum,
                        sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6)
                returning id
                """, islem,
                [barkod, istemId, b.HastaId, grup.First().Numune, grup.Key, b.SubeId,
                 baglam.KullaniciId], iptal);
            numuneler[grup.Key] = numuneId;
        }

        var sira = 0;
        var satirIdler = new Dictionary<int, int>();
        foreach (var t in tekil)
        {
            var bilgi = tupler.First(x => x.Id == t.TetkikId);
            satirIdler[t.TetkikId] = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_istem_satir
                       (istem_id, tetkik_id, panel_id, numune_id, stok_id, kod, ad,
                        durum, sira, ekleyen)
                values (@p0, @p1, @p2, @p3, null, @p4, @p5, 1, @p6, @p7)
                returning id
                """, islem,
                [istemId, t.TetkikId, t.PanelId, numuneler[bilgi.Tup], bilgi.Kod,
                 bilgi.Ad, (short)(++sira * 10), baglam.KullaniciId], iptal);
        }

        if (akilciKayitlar.Count > 0)
            await AkilciKararlariYazAsync(baglanti, islem, istemId, satirIdler, b, akilciKayitlar, baglam, iptal);

        await islem.CommitAsync(iptal);
        return istemId;
    }

    /// <summary>
    /// BAŞVURU KAYDEDİLDİ: ücretlendirilmiş tetkikler için istem AÇILIR
    /// (kullanici: "kaydet yapildiginda tahliller varsa ve istem
    /// acilmadiysa istem ac").
    ///
    /// Kayıt kabul tetkiki ÜCRET SATIRI olarak giriyor; istem ayrı bir adım
    /// olarak kalıyordu ve atlanınca tetkik laboratuvara hiç düşmüyordu -
    /// hastadan para alınmış, tüp istenmemiş oluyordu.
    ///
    /// <para><b>YALNIZ İSTEMİ AÇILMAMIŞ TETKİKLER:</b> başvuru her
    /// kaydedildiğinde çalışır; zaten istemi olan tetkik ikinci kez
    /// istenmez - hastadan iki kez tüp alınması ve iki kez çalışılması
    /// olmasın. Yeni tetkik eklenirse yalnız o tetkik için istem açılır.</para>
    ///
    /// <para><b>SESSİZDİR:</b> istem açılamazsa başvuru kaydı DÜŞMEZ - hasta
    /// kaydı birincil iştir, laboratuvar istemi onun sonucu. Hata günlüğe
    /// yazılır.</para>
    /// </summary>
    public async Task<int> BasvurudanIstemTamamlaAsync(int belgeId, IstekBaglami baglam,
                                                       CancellationToken iptal)
    {
        try
        {
            // ÜCRET SATIRI İKİ TÜRLÜ LABORATUVAR İŞİ OLABİLİR (638):
            //   * TEK TETKİK - hizmetin `lab_tetkik` karşılığı var (CRP, TSH…)
            //   * PANEL      - hizmetin `lab_panel` karşılığı var. Hemogram
            //     SUT'ta TEK kalemdir ama laboratuvar lökosit/hemoglobin/
            //     trombositi ayrı sonuç verir; panel `hizmet_paket` içeriğine
            //     açılır ve üçü aynı tüpe bağlanır.
            //   Paneli atlayıp yalnız tetkiğe bakmak, hemogram gibi
            //   faturalanan her paketi görmezden gelmek olurdu.
            //   * CHECK-UP   - ücrette TEK satır (hizmet.paket); içinde panel
            //     ve tek tetkikler var, hepsi aynı istemde açılır (925).
            //
            // "ZATEN İSTEMİ VAR MI" SORUSU YAPRAK TETKİK ÜZERİNDEN: panel de
            //   sonunda tetkiklere açılıyor, o yüzden iki tür aynı ölçüyle
            //   karşılaştırılır - panel bir kez istenmişse ikinci kez istenmez.
            var acilacak = await _veri.ListeAsync("""
                with kalem as (
                    select distinct bs.hizmet_id
                      from public.belge_satir bs
                     where bs.belge_id = @p0 and bs.hizmet_id is not null
                ),
                -- Tetkikler: kalemin KAPSADIGI her hizmet (925) - kendisi,
                --   panel icerigi, check-up > panel > parametre. Satirin
                --   paneli: yoldaki EN YAKIN lab_panel (check-up'taki
                --   hemogram parametresi hemogram panelinden dogar).
                aday as (
                    select t.id as tetkik_id,
                           (select p.id
                              from unnest(ks.yol) with ordinality u(hid, n)
                              join public.lab_panel p on p.hizmet_id = u.hid and p.durum = 0
                             where u.n < array_length(ks.yol, 1)
                             order by u.n desc limit 1) as panel_id
                      from kalem k
                     cross join lateral public.fn_hizmet_paket_kapsam(k.hizmet_id) ks
                      join public.lab_tetkik t
                        on t.hizmet_id = ks.hizmet_id and t.durum = 0
                )
                select distinct a.tetkik_id, a.panel_id
                  from aday a
                 where not exists (
                         select 1 from public.lab_istem i
                           join public.lab_istem_satir s on s.istem_id = i.id
                          where i.belge_id = @p0 and s.tetkik_id = a.tetkik_id)
                 order by a.tetkik_id
                """, [belgeId],
                o => new IstemSatiriIstegi(o.GetInt32(0),
                                           o.IsDBNull(1) ? null : o.GetInt32(1)),
                iptal);

            if (acilacak.Count == 0) return 0;

            // SATIRLAR TETKİK OLARAK GİDER, PANEL OLARAK DEĞİL: panel burada
            //   zaten açıldı. `IstemAcAsync`'e panel verseydik içeriği ikinci
            //   kez açılır, "istemi var mı" süzgecinden geçmiş tetkikler geri
            //   gelirdi. `panel_id` yalnız satırın hangi panelden doğduğunu
            //   söylemek için taşınıyor - rapor onu gösteriyor.
            // BAŞVURUDAN AÇILAN İSTEM "BANKO" (3): kayıt kabul ücretlendirdi,
            //   hekim istemedi. "Muayene istemi" (1) yalnız hekimin muayene
            //   sırasında açtığı istemdir (`MuayeneUclari`).
            return await IstemAcAsync(belgeId, acilacak, 1, "", "", baglam, iptal,
                                      kaynakKodu: 3, akilciSessiz: true);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Basvurudan lab istemi acilamadi (belge {Id})", belgeId);
            return 0;
        }
    }

    /// <summary>
    /// Ayna kolonu için referans metni: "0,5 - 1,2" / serbest metin.
    /// Sayısal aralık yoksa tetkik zaten metin referansla çalışıyordur.
    /// </summary>
    private static string AralikMetni(decimal? alt, decimal? ust, string metin)
        => alt is null && ust is null
            ? metin
            : alt is not null && ust is not null
                ? $"{alt:0.####} - {ust:0.####}"
                : alt is not null ? $"> {alt:0.####}" : $"< {ust:0.####}";

    /// <summary>
    /// Bayrak (N/L/H/LL/HH) -> satırın `isaret` kodu (0 Normal, 1 Düşük,
    /// 2 Yüksek, 3 Panik). Panik HER İKİ YÖNDE de 3'tür: kartta "düşük"
    /// görünen kritik değer, bakan kişiye aciliyetini söylemezdi.
    /// </summary>
    private static short IsaretKodu(string bayrak, bool panik)
        => panik ? (short)3
           : bayrak.StartsWith('L') ? (short)1
           : bayrak.StartsWith('H') ? (short)2 : (short)0;

    /// <summary>
    /// İstem durumu satırlardan TÜRETİLİR. İki yerde ayrı ayrı tutmak,
    /// listede "tamamlandı" görünüp içinde bekleyen tetkik olması demekti.
    ///
    /// <para>Eşik (kullanıcı: "bütün sonuçlar dolunca sonuçlandı durumuna
    /// geçer"): 4 SONUÇLANDI yalnız HER satır sonuçlandığında verilir -
    /// bir kısmı sonuçlanmışken istem "Çalışılıyor"dur. Önceki kural ilk
    /// onaylı satırda 4'e geçiyordu: 23 parametrelik hemogramın biri
    /// onaylanınca istem "Sonuçlandı" görünüyor, kalan 22 tetkik
    /// listede kimsenin dikkatini çekmiyordu.</para>
    ///
    /// <para>Sonuçlanmış sayılanlar: 3 sonuçlandı, 4 teknik onay, 5 onaylı.
    /// 6 (tekrar numune bekliyor) ve 7 (dış laboratuvarda) SAYILMAZ -
    /// ikisinde de o tetkiğin sonucu hâlâ yok.</para>
    /// </summary>
    private static async Task IstemDurumTazeleAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction? islem, int istemId, CancellationToken iptal)
        => await baglanti.CalistirAsync("""
            update public.lab_istem i
               set durum = case
                     when k.toplam = 0 then i.durum
                     when k.onayli = k.toplam then 5
                     when k.sonuclu = k.toplam then 4
                     when k.sonuclu > 0 then 3
                     else i.durum end,
                   -- Sonuc tarihi TUM satirlar sonuclaninca damgalanir;
                   --   TAT olcumu "son tetkik bitti" anini ister.
                   sonuc_tarihi = case when k.sonuclu = k.toplam then now()
                                       else i.sonuc_tarihi end
              from (select count(*) as toplam,
                           count(*) filter (where durum = 5) as onayli,
                           count(*) filter (where durum in (3, 4, 5)) as sonuclu
                      from public.lab_istem_satir where istem_id = @p0
                        and durum <> 0) k
             where i.id = @p0
               -- DEGISMEYECEKSE YAZMA: her sonuc yaziminda lab_istem satirini
               --   guncellemek xmin'i (essamanlilik damgasi) degistiriyor;
               --   acik duran istem karti sonrasinda 409 "kayit degisti"
               --   aliyordu. Ustelik her yazim olu satir uretiyordu.
               and (i.durum is distinct from case
                        when k.toplam = 0 then i.durum
                        when k.onayli = k.toplam then 5
                        when k.sonuclu = k.toplam then 4
                        when k.sonuclu > 0 then 3
                        else i.durum end
                    or (k.toplam > 0 and k.sonuclu = k.toplam
                        and i.sonuc_tarihi is null))
            """, islem, [istemId], iptal);

    /// <summary>
    /// RET → HASTAYA e-NABIZ MESAJI (879, KTS H1 / D16).
    ///
    /// <para>Üç kapı var ve üçü de kapalıysa sessizce geçilir - ret işleminin
    /// kendisi bilgilendirme yüzünden DÜŞMEZ:</para>
    /// <list type="number">
    /// <item>Kurum ayarı <c>lab.ret_enabiz_bildir</c>,</item>
    /// <item>ret nedeninin <c>hasta_bilgilendir</c> bayrağı,</item>
    /// <item>hastanın kimlik numarasının kayıtlı olması (e-Nabız profili
    /// kimlik numarasıyla bulunur).</item>
    /// </list>
    ///
    /// <para>Mesajı YAZAN hekim, istemi açan hekimdir: e-Nabız'da mesajın
    /// göndereni kurum değil hekimdir ve numuneyi reddeden teknisyenin
    /// hekim kimliği yoktur.</para>
    /// </summary>
    private static async Task<long?> RetMesajiYazAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, int numuneId, short? retNeden,
        int istemId, IstekBaglami baglam, CancellationToken iptal)
    {
        if (retNeden is null) return null;

        var bilgi = await baglanti.TekAsync("""
            select coalesce((select deger from public.referans
                              where anahtar = 'lab.ret_enabiz_bildir'), '1') as kurum_ayari,
                   coalesce(r.hasta_bilgilendir, 0) as neden_bayragi,
                   coalesce(nullif(r.mesaj_sablonu, ''),
                            (select deger from public.referans
                              where anahtar = 'lab.ret_mesaj_sablonu'), '') as sablon,
                   i.taraf_id, i.personel_id, i.belge_id, i.sube_id,
                   coalesce((select t.vkno from public.taraf t where t.id = i.taraf_id), '') as kimlik
              from public.lab_istem i
              left join public.lab_ret_nedeni r on r.kod = @p1
             where i.id = @p0
            """, islem, [istemId, retNeden],
            o => new
            {
                KurumAyari = o.GetString(0), NedenBayragi = o.GetInt32(1), Sablon = o.GetString(2),
                HastaId = o.IsDBNull(3) ? (int?)null : o.GetInt32(3),
                HekimId = o.IsDBNull(4) ? (int?)null : o.GetInt32(4),
                BelgeId = o.IsDBNull(5) ? (int?)null : o.GetInt32(5),
                SubeId = o.GetInt32(6), Kimlik = o.GetString(7),
            }, iptal);

        if (bilgi is null || bilgi.KurumAyari is not ("1" or "true" or "True")) return null;
        if (bilgi.NedenBayragi != 1) return null;
        if (bilgi.HastaId is not int hastaId) return null;
        if (bilgi.Kimlik.Trim().Length == 0 || bilgi.Sablon.Trim().Length == 0) return null;

        return await EnabizMesajServisi.KuyrugaAlAsync(
            baglanti, islem, hastaId, bilgi.HekimId, bilgi.Sablon,
            kaynak: 2, kaynakId: numuneId, belgeId: bilgi.BelgeId,
            subeId: bilgi.SubeId != 0 ? bilgi.SubeId : baglam.SubeId ?? 0,
            kullaniciId: baglam.KullaniciId, iptal: iptal);
    }
}
