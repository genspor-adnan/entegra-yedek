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
/// </summary>
public sealed class LabServisi(VeriKaynagi veri, ILogger<LabServisi> gunluk)
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
                                        short? kaynakKodu = null)
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
        var disMi = belgeId is not > 0;
        short kaynak = disMi ? (short)4 : (kaynakKodu ?? 1);

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

        var istemId = await baglanti.TekDegerAsync<int>("""
            insert into public.lab_istem
                   (belge_id, taraf_id, sube_id, istem_no, istem_tarihi, bolum,
                    personel_id, durum, oncelik, kaynak, klinik_bilgi, tani_icd, ekleyen)
            values (@p0, @p1, @p2, '', now(), 1, @p3, 1, @p4, @p8, @p5, @p6, @p7)
            returning id
            """, islem,
            [belgeId is > 0 ? belgeId : null, b.HastaId, b.SubeId,
             b.HekimId == 0 ? null : b.HekimId,
             oncelik, klinikBilgi, taniIcd, baglam.KullaniciId, kaynak], iptal);

        // DIS KURUM AYRI YAZILIR: kolonu insert listesine koymak, basvurulu
        //   istemde de null tasimak demekti - tek satirlik update okumayi
        //   kolaylastiriyor ve "yalniz dis istemde dolu" kurali goz onunde.
        if (disMi)
            await baglanti.CalistirAsync(
                "update public.lab_istem set dis_kurum_id = @p1 where id = @p0",
                islem, [istemId, disKurumId!.Value], iptal);

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
        foreach (var t in tekil)
        {
            var bilgi = tupler.First(x => x.Id == t.TetkikId);
            await baglanti.CalistirAsync("""
                insert into public.lab_istem_satir
                       (istem_id, tetkik_id, panel_id, numune_id, stok_id, kod, ad,
                        durum, sira, ekleyen)
                values (@p0, @p1, @p2, @p3, null, @p4, @p5, 1, @p6, @p7)
                """, islem,
                [istemId, t.TetkikId, t.PanelId, numuneler[bilgi.Tup], bilgi.Kod,
                 bilgi.Ad, (short)(++sira * 10), baglam.KullaniciId], iptal);
        }

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
                -- Yaprak tetkikler: dogrudan bagli olan + panel icerigi.
                aday as (
                    select t.id as tetkik_id, null::integer as panel_id
                      from kalem k
                      join public.lab_tetkik t
                        on t.hizmet_id = k.hizmet_id and t.durum = 0
                    union all
                    select t.id, p.id
                      from kalem k
                      join public.lab_panel p
                        on p.hizmet_id = k.hizmet_id and p.durum = 0
                      join public.fn_hizmet_paket_ac(p.hizmet_id, 1) a on true
                      join public.lab_tetkik t
                        on t.hizmet_id = a.hizmet_id and t.durum = 0
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
                                      kaynakKodu: 3);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Basvurudan lab istemi acilamadi (belge {Id})", belgeId);
            return 0;
        }
    }

    /// <summary>
    /// Numunesi olmayan istem satirlari icin tüp planı ve barkod üretir.
    ///
    /// Kart ekranından açılan istemde (uç yerine kartla kayıt) satırlar
    /// numunesiz kalır; barkodsuz istem kan alma biriminde "hangi tüp"
    /// sorusunu cevapsız bırakır. Aynı tüp tipindekiler yine TEK barkoda
    /// bağlanır ve zaten numunesi olan satıra dokunulmaz.
    /// </summary>
    public async Task<List<string>> NumunePlaniAsync(int istemId, IstekBaglami baglam,
                                                     CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var i = await baglanti.TekAsync("""
            select taraf_id, sube_id, durum from public.lab_istem where id = @p0
            """, islem, [istemId],
            o => new { HastaId = o.GetInt32(0), SubeId = o.GetInt32(1),
                       Durum = o.GetInt16(2) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem bulunamadı.");

        if (i.Durum == 9)
            throw GentegreHatasi.IsKurali("İptal edilmiş isteme numune üretilemez.");

        var satirlar = await baglanti.ListeAsync("""
            select s.id, coalesce(nullif(t.tup_tipi, 0), 1) as tup, t.numune_tipi
              from public.lab_istem_satir s
              join public.lab_tetkik t on t.id = s.tetkik_id
             where s.istem_id = @p0 and s.numune_id is null and s.durum <> 0
             order by s.sira, s.id
            """, islem, [istemId],
            o => new { Id = o.GetInt32(0), Tup = o.GetInt16(1), Numune = o.GetInt16(2) },
            iptal);

        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Numunesi olmayan tetkik yok - barkodlar zaten üretilmiş "
                + "(tetkiği olmayan satır varsa önce tetkik seçin).");

        var barkodlar = new List<string>();
        foreach (var grup in satirlar.GroupBy(x => x.Tup))
        {
            var barkod = await baglanti.TekDegerAsync<string>(
                "select public.fn_lab_barkod_uret(@p0)", islem, [i.SubeId], iptal) ?? "";
            var numuneId = await baglanti.TekDegerAsync<int>("""
                insert into public.lab_numune
                       (barkod, istem_id, hasta_id, numune_tipi, tup_tipi, durum,
                        sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, 1, @p5, @p6)
                returning id
                """, islem,
                [barkod, istemId, i.HastaId, grup.First().Numune, grup.Key, i.SubeId,
                 baglam.KullaniciId], iptal);

            await baglanti.CalistirAsync("""
                update public.lab_istem_satir set numune_id = @p0
                 where id = any(@p1)
                """, islem, [numuneId, grup.Select(x => x.Id).ToArray()], iptal);

            barkodlar.Add(barkod);
        }

        await islem.CommitAsync(iptal);
        return barkodlar;
    }

    // ================================================================= numune

    /// <summary>
    /// Numune alındı / kabul / ret.
    ///
    /// TAT KABULDE BAŞLAR: numune laboratuvara ulaşmadan süre işlemez.
    /// RET numuneyi kapatır ve istem satırlarını "tekrar bekliyor"a alır -
    /// sessizce açık bırakmak, sonuç hiç gelmeyen bir istem üretirdi.
    /// </summary>
    public async Task<string> NumuneDurumAsync(int numuneId, short yeniDurum,
        short? kalite, short? retNeden, string aciklama, IstekBaglami baglam,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var n = await baglanti.TekAsync("""
            select id, durum, barkod, istem_id from public.lab_numune
             where id = @p0 for update
            """, islem, [numuneId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1), Barkod = o.GetString(2),
                       IstemId = o.GetInt32(3) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Numune bulunamadı.");

        string mesaj;
        switch (yeniDurum)
        {
            case 2:   // alındı
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 2, alim_zamani = coalesce(alim_zamani, now()),
                           alan_id = coalesce(alan_id, @p1), degistiren = @p1,
                           degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId], iptal);
                mesaj = $"{n.Barkod} alındı.";
                break;

            case 3:   // kabul
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 3, kabul_zamani = now(), kabul_eden_id = @p1,
                           kalite = coalesce(@p2, kalite), ret = 0,
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId, kalite], iptal);
                // TAT hedefi kabulden itibaren: istemin en uzun hedef TAT'ı.
                await baglanti.CalistirAsync("""
                    update public.lab_istem i
                       set durum = greatest(i.durum, 2),
                           hedef_bitis = now() + make_interval(mins =>
                               coalesce((select max(case when i.oncelik = 3
                                                         then nullif(t.acil_tat_dk, 0)
                                                         else nullif(t.hedef_tat_dk, 0) end)
                                           from public.lab_istem_satir s
                                           join public.lab_tetkik t on t.id = s.tetkik_id
                                          where s.istem_id = i.id), 120))
                     where i.id = @p0
                    """, islem, [n.IstemId], iptal);
                mesaj = $"{n.Barkod} kabul edildi.";
                break;

            case 0:   // ret
                if (retNeden is null)
                    throw GentegreHatasi.Dogrulama("Ret nedeni zorunlu.",
                        [new("retNeden", "Ret nedeni seçilmeli.")]);
                await baglanti.CalistirAsync("""
                    update public.lab_numune
                       set durum = 0, ret = 1, ret_neden = @p2, ret_aciklama = @p3,
                           ret_zamani = now(), kalite = coalesce(@p4, kalite),
                           degistiren = @p1, degistirme_tarihi = now()
                     where id = @p0
                    """, islem, [numuneId, baglam.KullaniciId, retNeden, aciklama,
                                 kalite], iptal);
                // Ret edilen numunenin tetkikleri TEKRAR BEKLIYOR: istem
                //   sessizce acik kalirsa sonuc hic gelmez.
                await baglanti.CalistirAsync("""
                    update public.lab_istem_satir set durum = 6
                     where numune_id = @p0 and durum in (1, 2)
                    """, islem, [numuneId], iptal);
                mesaj = $"{n.Barkod} reddedildi - yeniden numune gerekiyor.";
                break;

            default:
                throw GentegreHatasi.IsKurali("Geçersiz numune durumu.");
        }

        await baglanti.CalistirAsync("""
            insert into public.lab_numune_hareket
                   (numune_id, olay, kullanici_id, aciklama)
            values (@p0, @p1, @p2, @p3)
            """, islem,
            [numuneId, (short)(yeniDurum == 3 ? 3 : yeniDurum == 2 ? 1 : 9),
             baglam.KullaniciId, aciklama], iptal);

        await islem.CommitAsync(iptal);
        return mesaj;
    }

    /// <summary>
    /// İSTEMİN TÜM TÜPLERİNE tek işlemde alındı / kabul / ret.
    ///
    /// Mockup lab_istem_numune_kabul.html araç çubuğu ("✔ Numune Kabul" /
    /// "✖ Numune Ret") istem satırının üzerinde durur: banko hastanın
    /// tüplerini birlikte alır, birlikte kabul eder. Tek tek kabul, dört
    /// tüplük bir istemde dört ayrı diyalog demekti.
    ///
    /// SONUÇLANMIŞ tüpe dokunulmaz: çalışılmış numuneyi geri almak sonucu
    /// dayanaksız bırakırdı. Ret zaten kapalı numuneyi de atlar.
    /// </summary>
    public async Task<string> IstemNumuneDurumAsync(int istemId, short yeniDurum,
        short? kalite, short? retNeden, string aciklama, IstekBaglami baglam,
        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        var numuneler = await baglanti.ListeAsync("""
            select id, durum from public.lab_numune
             where istem_id = @p0 and durum < 4 order by id
            """, null, [istemId],
            o => new { Id = o.GetInt32(0), Durum = o.GetInt16(1) }, iptal);

        // Halihazirda hedef durumda olan tup ISLENMEZ: kabul zamanini
        //   yeniden yazmak TAT saatini geri alirdi.
        var hedef = numuneler.Where(n => n.Durum != yeniDurum && !(yeniDurum == 0 && n.Durum == 0))
                             .Select(n => n.Id).ToList();
        if (numuneler.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Bu istemde tüp yok - önce \"Barkod Üret\" ile numune planı çıkarın.");
        if (hedef.Count == 0)
            return "Tüplerin hepsi zaten bu durumda.";

        foreach (var id in hedef)
            await NumuneDurumAsync(id, yeniDurum, kalite, retNeden, aciklama, baglam, iptal);

        var ne = yeniDurum switch { 2 => "alındı", 3 => "kabul edildi", _ => "reddedildi" };
        return $"{hedef.Count} tüp {ne}.";
    }

    // ================================================================== sonuç

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
                   t.delta_gun, t.oto_onay, t.tur
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
                       OtoOnay = o.GetInt16(12), Tur = o.GetInt16(13) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("İstem satırı bulunamadı.");

        // Referans aralığı hastanın yaş/cinsiyetine göre.
        var r = await baglanti.TekAsync("""
            select alt, ust, metin, panik_alt, panik_ust
              from public.fn_lab_referans(@p0, @p1, current_date)
             where tetkik_id is not null
            """, islem, [s.TetkikId, s.HastaId],
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
        var otoOnay = otoOnaySerbest && s.OtoOnay == 1 && bayrak == "N"
                      && !panik && !deltaUyari && kkGecerli && indeksDurum == 0;

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
                    indeks_durum, indeks_uyari)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, now(),
                    @p10, @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19,
                    -- İNDEKS RET eşiği: sonuç "tekrar bekliyor" (5) durumunda
                    --   durur; onaylı sayılmaz ama kaydı da kaybolmaz.
                    case when @p23 = 2 then 5
                         when @p20 = 1 then 3 else 1 end, @p20,
                    case when @p20 = 1 then @p21 else null end,
                    case when @p20 = 1 then now() else null end, @p22, @p21,
                    @p23, @p24)
            returning id
            """, islem,
            [s.Id, s.NumuneId, s.TetkikId, sayisal, istek.Deger,
             string.IsNullOrWhiteSpace(istek.Birim) ? s.Birim : istek.Birim,
             hamDeger ?? istek.Deger, hamBirim ?? "", cihazId, cihazMesajId,
             bayrak, r?.Alt, r?.Ust,
             r?.Metin ?? "", (short)(panik ? 1 : 0), oncekiDeger, deltaYuzde,
             (short)(deltaUyari ? 1 : 0), istek.Dilusyon, istek.Yorum ?? "",
             (short)(otoOnay ? 1 : 0), baglam.KullaniciId, s.SubeId,
             indeksDurum, indeksUyari], iptal);

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
    public async Task<(string Mesaj, int IstemId)> OnaylaAsync(
        long sonucId, short asama, IstekBaglami baglam, CancellationToken iptal)
    {
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

    public sealed record CihazIslemSonucu(int Yazilan, int Atlanan, string Mesaj);

    public sealed record CalismaSatiri(int IstemSatirId, string Barkod, int TetkikId,
                                       string TetkikKodu, string CihazKodu,
                                       string TetkikAdi, int HastaId, string HastaAdi,
                                       short Oncelik);

    /// <summary>
    /// HOST QUERY - cihaz "bu barkodda ne çalışacağım" diye sorar.
    ///
    /// Listeyi sunucu verir; teknisyenin cihaz başında testi elle seçmesi
    /// hem yavaş hem hatalı. Yalnız KABUL EDİLMİŞ numune döner.
    /// </summary>
    public async Task<List<CalismaSatiri>> CalismaListesiAsync(int cihazId, string barkod,
                                                               CancellationToken iptal)
        => await _veri.ListeAsync("""
            select istem_satir_id, barkod, tetkik_id, tetkik_kodu, cihaz_kodu,
                   tetkik_adi, hasta_no, hasta_adi, oncelik
              from public.fn_lab_cihaz_calisma_listesi(@p0, @p1)
            """, [cihazId, barkod],
            o => new CalismaSatiri(o.GetInt32(0), o.GetString(1), o.GetInt32(2),
                                   o.GetString(3), o.GetString(4), o.GetString(5),
                                   o.GetInt32(6), o.GetString(7), o.GetInt16(8)), iptal);

    /// <summary>
    /// Cihazdan gelen ÇÖZÜMLENMİŞ mesajı lab sonucuna yazar.
    ///
    /// <para><b>Ham metin cihaz_mesaj'da kalır.</b> Eşleme düzeltilince mesaj
    /// yeniden işlenir - cihaz aynı sonucu ikinci kez göndermez.</para>
    ///
    /// <para><b>Eşleşmeyen test SESSİZCE atılmaz</b>; sayısı ve kodları mesaj
    /// hatasına yazılır, yoksa sonuç kaybolmuş görünürdü.</para>
    /// </summary>
    public async Task<CihazIslemSonucu> CihazMesajIsleAsync(long mesajId,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var m = await _veri.TekAsync("""
            select m.id, m.cihaz_id, m.ornek_no, m.istem_no, m.durum, m.kalem_sayisi
              from public.cihaz_mesaj m where m.id = @p0
            """, [mesajId],
            o => new { Id = o.GetInt64(0), CihazId = o.GetInt32(1),
                       OrnekNo = o.GetString(2), IstemNo = o.GetString(3),
                       Durum = o.GetInt16(4), Kalem = o.GetInt32(5) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Cihaz mesajı bulunamadı.");

        if (m.Durum == 3)
            return new CihazIslemSonucu(0, 0, "Bu mesaj zaten işlenmiş.");

        // Barkod önce örnek numarasında aranır; bazı cihazlar barkodu istem
        //   alanına yazar - iki alana da bakmak, elle düzeltmeyi önler.
        var numuneId = await _veri.TekDegerAsync<int?>("""
            select id from public.lab_numune
             where barkod in (@p0, @p1) and barkod <> '' order by id desc limit 1
            """, [m.OrnekNo, m.IstemNo], iptal);

        if (numuneId is null or 0)
        {
            await MesajHataAsync(mesajId,
                $"Barkod eşleşmedi (örnek '{m.OrnekNo}', istem '{m.IstemNo}').", iptal);
            return new CihazIslemSonucu(0, m.Kalem,
                "Barkod bir numuneyle eşleşmedi - mesaj hata durumunda bekliyor.");
        }

        var kalemler = await _veri.ListeAsync("""
            select sira, test_kodu, deger, sayisal, birim
              from public.cihaz_mesaj_kalem where mesaj_id = @p0 order by sira, id
            """, [mesajId],
            o => new { Sira = o.GetInt32(0), Kod = o.GetString(1), Deger = o.GetString(2),
                       Sayisal = o.IsDBNull(3) ? (decimal?)null : o.GetDecimal(3),
                       Birim = o.GetString(4) }, iptal);

        int yazilan = 0;
        var eslesmeyen = new List<string>();

        // SERUM İNDEKSLERİ (444) ÖNCE: cihaz bunları normal sonuç gibi
        //   gönderir (SI-H, HI, HIL-L…). Tetkik eşlemesi olmadığı için
        //   "eşleşmeyen test" sayılıp atılıyorlardı; oysa numune kalitesinin
        //   kendisi ve sonraki sonuçların yorumunu değiştiriyorlar.
        var indeksler = new List<string>();
        foreach (var k in kalemler)
        {
            if (k.Sayisal is not { } indeksDeger) continue;
            var tip = await _veri.TekDegerAsync<short?>("""
                select indeks from public.lab_indeks_kod
                 where upper(kod) = upper(@p1) and durum = 0
                   and (cihaz_id = @p0 or cihaz_id is null)
                 order by cihaz_id nulls last limit 1
                """, [m.CihazId, k.Kod], iptal);
            if (tip is null) continue;

            var kolon = tip switch { 1 => "hemoliz_idx", 2 => "lipemi_idx",
                                     _ => "ikter_idx" };
            await _veri.CalistirAsync($"""
                update public.lab_numune set {kolon} = @p1, degistirme_tarihi = now()
                 where id = @p0
                """, [numuneId, (short)Math.Round(indeksDeger)], iptal);
            indeksler.Add($"{k.Kod}={indeksDeger:0.#}");
        }

        foreach (var k in kalemler)
        {
            // İndeks kalemi tetkik değildir: sonuç satırı açılmaz.
            if (indeksler.Any(x => x.StartsWith(k.Kod + "=",
                                                StringComparison.OrdinalIgnoreCase)))
                continue;

            var e = await _veri.TekAsync("""
                select tetkik_id, carpan, ofset
                  from public.fn_lab_cihaz_tetkik(@p0, @p1, '')
                """, [m.CihazId, k.Kod],
                o => new { TetkikId = o.GetInt32(0), Carpan = o.GetDecimal(1),
                           Ofset = o.GetDecimal(2) }, iptal);

            if (e is null) { eslesmeyen.Add(k.Kod); continue; }

            var satirId = await _veri.TekDegerAsync<int?>("""
                select id from public.lab_istem_satir
                 where numune_id = @p0 and tetkik_id = @p1 and durum <> 0
                 order by id limit 1
                """, [numuneId, e.TetkikId], iptal);

            // İSTENMEMİŞ TEST YAZILMAZ: cihaz paneli komple çalışır, istemde
            //   olmayan testi hasta dosyasına eklemek faturalanmamış sonuç üretir.
            if (satirId is null or 0) { eslesmeyen.Add(k.Kod); continue; }

            var deger = k.Sayisal is { } sy
                ? (sy * e.Carpan + e.Ofset).ToString(System.Globalization.CultureInfo.InvariantCulture)
                : k.Deger;

            await SonucYazAsync(new SonucIstegi(satirId.Value, deger, k.Birim, null, null),
                                m.CihazId, mesajId, baglam, iptal, k.Deger, k.Birim);
            yazilan++;
        }

        var hata = eslesmeyen.Count == 0 ? ""
            : $"Eşleşmeyen test: {string.Join(", ", eslesmeyen)}";

        await _veri.CalistirAsync("""
            update public.cihaz_mesaj set durum = 3, hata = @p1, islenme = now()
             where id = @p0
            """, [mesajId, hata], iptal);

        var indeksNot = indeksler.Count > 0
            ? $" Serum indeksleri numuneye yazıldı ({string.Join(", ", indeksler)})."
            : "";

        return new CihazIslemSonucu(yazilan, eslesmeyen.Count,
            (yazilan == 0 ? $"Sonuç yazılamadı. {hata}"
                          : $"{yazilan} sonuç yazıldı. {hata}").Trim() + indeksNot);
    }

    private async Task MesajHataAsync(long mesajId, string hata, CancellationToken iptal)
        => await _veri.CalistirAsync("""
            update public.cihaz_mesaj set durum = 4, hata = @p1 where id = @p0
            """, [mesajId, hata], iptal);

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
}
