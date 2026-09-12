using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-NABIZ PAKET ÜRETİMİ (415, Faz 1) — klinik olaydan USS paketine.
///
/// <para><b>Üretim gönderimden ayrıdır.</b> USS test hesabı / KTS tescili
/// henüz yok; paketler yine de üretilir ve kuyrukta bekler. Üretimi kapıya
/// bağlamak, kapı açıldığında geçmiş veriyi kaybetmek olurdu.</para>
///
/// <para><b>İdempotent.</b> Aynı kaynak için aynı içerik ikinci kez paket
/// açmaz (içerik hash'i). Muayene her kaydedildiğinde paket üretmek, USS'ye
/// aynı muayeneyi onlarca kez göndermek demekti.</para>
///
/// <para><b>Doğrulama üretim anında.</b> Zorunlu alan eksikse paket kuyruğa
/// GİRMEZ (durum 0 "eksik alan") ve eksiğin hangi kaynak kolondan gelmesi
/// gerektiği alan satırında yazar. Eksiği gönderim anında bulmak, hatayı
/// hekim ekrandan ayrıldıktan saatler sonra geri getirirdi.</para>
/// </summary>
public sealed class EnabizPaketUretici
{
    private readonly VeriKaynagi _veri;
    private readonly ILogger<EnabizPaketUretici> _gunluk;

    public EnabizPaketUretici(VeriKaynagi veri, ILogger<EnabizPaketUretici> gunluk)
    {
        _veri = veri;
        _gunluk = gunluk;
    }

    /// <summary>Paket kaynağı: 1 başvuru · 2 muayene · 3 reçete.</summary>
    public const short KaynakBasvuru = 1;
    public const short KaynakMuayene = 2;
    public const short KaynakRecete = 3;

    public sealed record Sonuc(long PaketId, string PaketNo, short Durum, int AlanSayisi,
                               IReadOnlyList<string> Eksikler);

    /// <summary>
    /// Verilen paket türü için paketi üretir (varsa mevcudu döndürür).
    ///
    /// Alan çözümleme SQL'de: USS alanı ile kaynak kolon eşlemesi tek yerde
    /// dursun, C# tarafında satır satır okuma/yazma olmasın.
    /// </summary>
    public async Task<Sonuc?> UretAsync(string paketKodu, int kaynakId, int kullaniciId,
                                        CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var tur = await baglanti.TekAsync("""
            select t.id, t.uss_paket_kodu, t.sure_siniri_saat, t.zorunlu_alanlar::text, t.aktif
              from public.enabiz_paket_turu t where t.kod = @p0
            """, islem, [paketKodu], o => new
            {
                Id = o.GetInt16(0), Kod = o.GetString(1), Sure = o.GetInt16(2),
                Zorunlu = o.GetString(3), Aktif = o.GetInt16(4),
            }, iptal);

        // Tur kapaliysa paket URETILMEZ: kurum o paketi gondermiyor demektir.
        if (tur is null || tur.Aktif != 1) return null;

        var alanlar = await AlanlariCozAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (alanlar.Count == 0) return null;

        var zorunlu = JsonSerializer.Deserialize<string[]>(tur.Zorunlu) ?? [];
        var eksikler = zorunlu
            .Where(z => !alanlar.Any(a => a.Alan == z && a.Deger.Trim().Length > 0))
            .ToList();

        var baglam = await BaglamAlAsync(baglanti, islem, paketKodu, kaynakId, iptal);
        if (baglam is null) return null;

        // PARMAK IZINE SKRS KODU DA GIRER (602): kod, alanin USS'ye giden
        //   ASIL degeridir - `deger` yalnizca okunabilir karsiligidir
        //   ("e-Nabız / USS" adi degismeden kurum kodu 11111111'den 500154'e
        //   gecebilir). Kod hash'e girmeyince icerik degismis sayilmiyor,
        //   "ayni icerik -> ayni paket" korumasi yeni paketi engelliyordu:
        //   kurum kodu duzeltildigi halde kart kaydedilince hala eski,
        //   REDDEDILMIS paket donuyordu (gercek vaka, paket 156 / E0009).
        // URETIM ZAMANI PARMAK IZINE GIRMEZ (620).
        //
        // PAKETE_AIT_ISLEM_ZAMANI `now()` ile doluyor. Hash'e girince "ayni
        //   icerik -> ayni paket" korumasi HIC tutmuyordu: hicbir sey
        //   degismeden kart ikinci kez kaydedilince zaman farkli oluyor,
        //   hash degisiyor ve AYNI basvuru icin ikinci bir paket aciliyordu
        //   (gercek vaka: 364 ve 365, aralarindaki tek fark dort dakika).
        //   Ikinci paket USS'ye gidince "E2033 ... daha once alinmis bir
        //   SYSTakipNo bulunmaktadir" ile geri donuyor - yani kuyruk kendi
        //   kendine mukerrer is uretiyordu.
        //
        // Zaman bir ICERIK degil, gonderimin damgasidir; parmak izi
        //   HASTANIN VERISINI tanimlamali.
        // SYS TAKIP NUMARASI DA PARMAK IZINE GIRMEZ (620).
        //
        // Numara USS'nin bize verdigi KAYIT KIMLIGIDIR, hastanin verisi
        //   degil. Hash'e girince kendi kendini besleyen bir dongu oluyordu:
        //   101 gonderiliyor -> numara basvuruya yaziliyor -> kart bir daha
        //   kaydedilince paket artik numarayi tasiyor -> icerik "degismis"
        //   sayilip IKINCI bir 101 aciliyor (gercek vaka: paket 366, tek
        //   farki doldurulmus SYSTakipNo). Hicbir klinik veri degismeden
        //   USS'ye guncelleme gonderirdi.
        var hash = Hash(alanlar
            .Where(a => a.Kaynak != "(uretim zamani)"
                     && a.Kaynak != "belge_basvuru.sys_takip_no")
            .Select(a => $"{a.Alan}={a.Deger}|{a.SkrsKod}"));
        var kaynakTur = MuayeneKaynakli(paketKodu) ? KaynakMuayene : KaynakBasvuru;

        // AYNI ICERIK -> AYNI PAKET. Kaynak yeniden kaydedilince yeni satir
        //   acilmaz; icerik degistiyse yeni paket (guncelleme) acilir.
        //
        // IPTAL EDILEN (durum 5) SAYILMAZ: "kaynaktan yeniden uret" once eski
        //   paketi iptal ediyor; iptali de "mevcut" saymak, kaynak degismediginde
        //   paketi tamamen yok ederdi (iptal edildi, yenisi acilmadi).
        var mevcut = await baglanti.TekAsync("""
            select p.id, p.paket_no, p.durum from public.enabiz_paket p
             where p.paket_turu_id = @p0 and p.kaynak_tur = @p1 and p.kaynak_id = @p2
               and p.islem = 1 and p.icerik_hash = @p3 and p.durum <> 5
             limit 1
            """, islem, [tur.Id, kaynakTur, kaynakId, hash],
            o => new { Id = o.GetInt64(0), No = o.GetString(1), Durum = o.GetInt16(2) },
            iptal);
        if (mevcut is not null)
        {
            await islem.CommitAsync(iptal);
            // Mevcut paketin GERCEK durumu doner: bos paket no ve durum 0
            //   dondurmek, cagiraninin "eksik alan var" sanmasina yol aciyordu.
            return new Sonuc(mevcut.Id, mevcut.No, mevcut.Durum, alanlar.Count, eksikler);
        }

        var durum = (short)(eksikler.Count > 0 ? 0 : 1);
        var paketId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_paket
                   (paket_no, paket_turu_id, islem, kaynak_tur, kaynak_id, belge_id,
                    hasta_id, hekim_id, sube_id, olay_tarihi, son_tarih, durum,
                    icerik_hash, ekleyen)
            values ('', @p0, 1, @p1, @p2, @p3, @p4, @p5, @p6, @p7,
                    @p7 + (@p8 || ' hours')::interval, @p9, @p10, @p11)
            returning id
            """, islem,
            [tur.Id, kaynakTur, kaynakId, baglam.BelgeId, baglam.HastaId, baglam.HekimId,
             baglam.SubeId, baglam.OlayTarihi, tur.Sure, durum, hash, kullaniciId], iptal);

        // Paket no INSERT SONRASI: yil + sira, kullanicinin kuyruk ekraninda
        //   arayabilecegi tek kimlik.
        var paketNo = $"PK-{DateTime.Today:yyyy}-{paketId:000000}";
        await baglanti.CalistirAsync(
            "update public.enabiz_paket set paket_no = @p1 where id = @p0",
            islem, [paketId, paketNo], iptal);

        var sira = 0;
        foreach (var a in alanlar)
        {
            var eksikMi = zorunlu.Contains(a.Alan) && a.Deger.Trim().Length == 0;
            await baglanti.CalistirAsync("""
                insert into public.enabiz_paket_alan
                       (paket_id, uss_alan, deger, kaynak_alan, skrs_liste, gecerli, sorun,
                        skrs_kod, skrs_sistem, sira)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9)
                """, islem,
                [paketId, a.Alan, a.Deger, a.Kaynak, a.SkrsListe,
                 (short)(eksikMi ? 0 : 1),
                 eksikMi ? $"Zorunlu alan bos ({a.Kaynak})" : "",
                 a.SkrsKod, a.SkrsSistem, (short)sira++], iptal);
        }

        await islem.CommitAsync(iptal);
        _gunluk.LogInformation("e-Nabiz paketi uretildi {No} ({Kod}) durum {Durum}",
            paketNo, paketKodu, durum);

        return new Sonuc(paketId, paketNo, durum, alanlar.Count, eksikler);
    }

    // ------------------------------------------------------------------ alan
    /// <summary>
    /// Bir paket alani. `Alan` USS'nin GERCEK adi ve YOLUDUR (605):
    /// "HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES". `SkrsSistem` doluysa
    /// deger kodlanmis yazilir (code + value), bossa duz.
    /// </summary>
    private sealed record AlanDegeri(string Alan, string Deger, string Kaynak,
                                     string SkrsListe, string SkrsKod = "",
                                     string SkrsSistem = "");

    private sealed record PaketBaglami(int? BelgeId, int? HastaId, int? HekimId, int SubeId,
                                       DateTime OlayTarihi);

    /// <summary>
    /// Paketin kaynağı muayene mi, başvuru mu.
    ///
    /// 106 Hasta Çıkış da MUAYENEDEN doğar (çıkış zamanı muayenenin
    /// tamamlanmasıdır). Tek tek "== MUAYENE" karşılaştırması yüzünden 106
    /// hiç üretilmiyordu: bağlam başvuru sanılıp muayene id'siyle belge
    /// aranıyor, bulunamayınca paket sessizce atlanıyordu.
    /// </summary>
    private static bool MuayeneKaynakli(string paketKodu)
        => paketKodu is "MUAYENE" or "HASTA_CIKIS";

    private static async Task<PaketBaglami?> BaglamAlAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
        => MuayeneKaynakli(paketKodu)
            ? await baglanti.TekAsync("""
                select m.belge_id, m.taraf_id, m.personel_id, m.sube_id,
                       coalesce(m.baslangic, m.muayene_tarihi)
                  from public.muayene m where m.id = @p0
                """, islem, [kaynakId], Oku, iptal)
            : await baglanti.TekAsync("""
                select b.id, b.taraf_id, bb.personel_id, b.sube_id, b.belge_tarihi
                  from public.belge b
                  join public.belge_basvuru bb on bb.id = b.id
                 where b.id = @p0
                """, islem, [kaynakId], Oku, iptal);

    private static PaketBaglami Oku(NpgsqlDataReader o) => new(
        o.IsDBNull(0) ? null : o.GetInt32(0),
        o.IsDBNull(1) ? null : o.GetInt32(1),
        o.IsDBNull(2) ? null : o.GetInt32(2),
        o.GetInt32(3),
        o.IsDBNull(4) ? DateTime.Now : o.GetDateTime(4));

    /// <summary>
    /// USS alanlarını kaynak kolonlardan çözer.
    ///
    /// Eşleme SQL'de tek yerde: hangi USS alanının nereden geldiği paket
    /// kartında da aynı metinle görünsün (kaynak_alan kolonu).
    ///
    /// SKRS kodlu alanlar `fn_skrs_kod` / `fn_skrs_ad` / `fn_skrs_guid`
    /// çağırır (610). Kod listeleri 609'dan bu yana SKRS'nin kendisi
    /// olduğu için çeviriye gerek yok - yerel değerin KENDİSİ SKRS
    /// kodudur; codeSystemGuid de listenin kaydından gelir, SQL'e gömülü
    /// sabitten değil. `enabiz_kod_esleme` yalnızca SKRS'de karşılığı
    /// olmayan, kuruma özel eşlemeler için yedek yol olarak durur.
    /// </summary>
    private static Task<List<AlanDegeri>> AlanlariCozAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, string paketKodu, int kaynakId, CancellationToken iptal)
    {
        var sql = paketKodu switch
        {
            // 301 HASTA KAYIT SILME - 101'in USS'deki karsiligini siler (602).
            //   Tek alani, 101'in yanitinda donen SYSTakipNo'dur; ayni
            //   basvurunun gonderilmis paketinden okunur. Alan olarak da
            //   yazilir (govde XmlUretAsync'te ondan uretilir): boylece paket
            //   kartinda HANGI KAYDIN silindigi gorunur ve icerik hash'i
            //   dogar - ayni basvuru icin ikinci bir silme paketi acilmaz.
            "HASTA_KABUL_SIL" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                """,

            // 102 HASTA ISLEM - hizmet / ilac / malzeme bildirimi (623).
            //
            // Kilavuz: "Bu paket hasta dosyasina hizmet, ilac, malzeme, vaka
            //   basi veya paket islem eklendiginde gonderilir." Bizdeki
            //   karsiligi BELGE KALEMIDIR.
            //
            // TEKRARLI GRUP: her kalem bir `ISLEM_BILGISI`. Yol parcasindaki
            //   `[n]` indeksi kalemleri birbirinden ayirir; XML'e yazilmaz
            //   (EnabizGonderimi.XmlUretAsync). Indeks satirin SIRASIDIR -
            //   kalem silinip eklendiginde numaralar kaymasin diye
            //   row_number kullanilir, satir kimligi degil.
            //
            // ALAN SIRASI KILAVUZLA BIREBIR: sema `sequence` olabilir, 101'de
            //   oyleydi (E1013/E1016). Karsiligi olmayan alanlar atlanir -
            //   SKRS kodlu bos eleman zaten yazilamiyor (611), kodsuz bos
            //   eleman ise bu pakette gereksiz.
            "HASTA_ISLEM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce(bb.sys_takip_no, ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all
                -- Disardaki select 6 kolon dondurur; `sira` yalniz SIRALAMA
                --   icindir (kalemler dogru duzende yazilsin) ve disari
                --   cikmaz - union all kollarinin kolon sayisi esit olmali.
                select k2.uss_alan, k2.deger, k2.kaynak,
                       k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with kalem as (
                    select bs.id, bs.tur, bs.hizmet_id, bs.stok_id,
                           bs.miktar, b.belge_tarihi, bb.bolum_id, bs.ekleyen,
                           row_number() over (order by bs.sira, bs.id) as ix,
                           -- HIZMET TURU (SKRS d03e562d): 1 DIGER (SUT/paket),
                           --   2 ILAC, 3 MALZEME. Ilac, stok kartinin ilac
                           --   kaydi olup olmamasindan anlasilir - ayri bir
                           --   "bu ilactir" bayragi tutmuyoruz.
                           case when bs.tur = 2 then 1
                                when exists (select 1 from public.ilac i
                                              where i.stok_id = bs.stok_id) then 2
                                else 3 end as skrs_tur,
                           -- ISLEM KODU: hizmette SUT kodu (hizmet.kod),
                           --   ilacta barkod, malzemede stok kodu.
                           case when bs.tur = 2
                                then coalesce((select h.kod from public.hizmet h
                                                where h.id = bs.hizmet_id), '')
                                else coalesce(
                                       (select i.barkod from public.ilac i
                                         where i.stok_id = bs.stok_id limit 1),
                                       (select st.kod from public.stok st
                                         where st.id = bs.stok_id), '')
                           end as islem_kodu,
                           case when bs.tur = 2
                                then coalesce((select h.ad from public.hizmet h
                                                where h.id = bs.hizmet_id), '')
                                else coalesce((select st.ad from public.stok st
                                                where st.id = bs.stok_id), '')
                           end as islem_adi,
                           -- Tutarlar DAGILIMDAN: kuruma yansiyan SGK + OSS,
                           --   hastaya yansiyan provizyon + ek katki + SGK
                           --   katilim payi. Kilavuz ikisini de ozel ve
                           --   universite hastanelerinden istiyor.
                           coalesce(dg.sgk, 0) + coalesce(dg.oss, 0) as kurum_tutar,
                           coalesce(dg.hasta_provizyon, 0)
                             + coalesce(dg.hasta_ek_katki, 0)
                             + coalesce(dg.sgk_katilim_payi, 0) as hasta_tutar
                      from public.belge_satir bs
                      join public.belge b on b.id = bs.belge_id
                      join public.belge_basvuru bb on bb.id = b.id
                      left join public.belge_satir_dagilim dg on dg.belge_satir_id = bs.id
                     where bs.belge_id = @p0
                  )
                  -- SEMADAKI ALANLAR EKSIKSIZ, SIRA KILAVUZLA BIREBIR (623).
                  --   Kilavuz bu alanlarin cogunu "Zorunlu: Hayir" diye
                  --   isaretliyor ama USS govdeyi XSD ile dogruluyor ve
                  --   yazilmayanlari sayip donduruyor: "E1016 ... eksik veya
                  --   dokumanda bulunmamasi gerekiyor GERCEKLESME_ZAMANI,
                  --   RANDEVU_ZAMANI, KULLANICI_KIMLIK_NUMARASI,
                  --   CIHAZ_NUMARASI, GIRISIMSEL_ISLEM_KODU" (canli deneme,
                  --   paket 466). 101'de ayni ders YATIS_BILGISI ile
                  --   alinmisti: "zorunlu degil" ile "olmayabilir" ayni sey
                  --   degil - alan BOS gidebilir, EKSIK gidemez.
                  --   Sira `ix * 100 + n` ile sabitlenir.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/KLINIK_KODU',
                         public.fn_skrs_ad('klinik.kod',
                             nullif((select d.kod from public.departman d
                                      where d.id = k.bolum_id
                                        and d.kod ~ '^[0-9]+$'), '')::int),
                         'departman.kod (SKRS klinik)', 'SKRS Klinik',
                         coalesce(public.fn_skrs_kod('klinik.kod',
                             nullif((select d.kod from public.departman d
                                      where d.id = k.bolum_id
                                        and d.kod ~ '^[0-9]+$'), '')::int), ''),
                         public.fn_skrs_guid('klinik.kod'),
                         k.ix * 100 + 1
                    from kalem k
                  union all
                  -- GERCEKLESME_ZAMANI: kilavuz "istek zamani gonderilmemelidir"
                  --   diyor - islemin YAPILDIGI an. Kalemde ayri bir
                  --   gerceklesme damgasi tutmuyoruz, bos gider.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/GERCEKLESME_ZAMANI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 2
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/ISLEM_TURU',
                         public.fn_skrs_ad('hizmet.skrs_turu', k.skrs_tur),
                         'belge_satir.tur / ilac kaydi', 'SKRS Hizmet Turu',
                         public.fn_skrs_kod('hizmet.skrs_turu', k.skrs_tur),
                         public.fn_skrs_guid('hizmet.skrs_turu'),
                         k.ix * 100 + 3
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/ISLEM_KODU',
                         k.islem_kodu, 'hizmet.kod / ilac.barkod / stok.kod',
                         '', '', '', k.ix * 100 + 4
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/ISLEM_ADI',
                         k.islem_adi, 'hizmet.ad / stok.ad', '', '', '',
                         k.ix * 100 + 5
                    from kalem k
                  union all
                  -- GIRISIMSEL_ISLEM_KODU: Girisimsel Islem Listesi ayri bir
                  --   kodlama; hizmet kartinda karsiligi tutulmuyor.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/GIRISIMSEL_ISLEM_KODU',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 6
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/ISLEM_ZAMANI',
                         to_char(k.belge_tarihi, 'YYYYMMDDHH24MI'),
                         'belge.belge_tarihi', '', '', '', k.ix * 100 + 7
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/ADET',
                         trim(to_char(k.miktar, 'FM9999999990.00')),
                         'belge_satir.miktar', '', '', '', k.ix * 100 + 8
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/HASTA_TUTARI',
                         trim(to_char(k.hasta_tutar, 'FM9999999990.00')),
                         'belge_satir_dagilim (hasta)', '', '', '', k.ix * 100 + 9
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix || ']/KURUM_TUTARI',
                         trim(to_char(k.kurum_tutar, 'FM9999999990.00')),
                         'belge_satir_dagilim (kurum)', '', '', '', k.ix * 100 + 10
                    from kalem k
                  union all
                  -- RANDEVU_ZAMANI: randevudan acilan basvuruda doldurulabilir;
                  --   kalemin kendi randevusu yok.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/RANDEVU_ZAMANI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 11
                    from kalem k
                  union all
                  -- KULLANICI_KIMLIK_NUMARASI: islemi KAYDEDEN kullanicinin
                  --   TCKN'si. Kullanici kaydi kisi kartina `rehberid` ile
                  --   bagli; kimlik numarasi zorunlu olmadigi icin bos
                  --   kalabilir.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/KULLANICI_KIMLIK_NUMARASI',
                         coalesce((select t.vkno from public.taraf t
                                    where t.id = k.ekleyen), ''),
                         'taraf.vkno (kaydeden)', '', '', '', k.ix * 100 + 12
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/CIHAZ_NUMARASI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 13
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/ISLEM_REFERANS_NUMARASI',
                         k.id::text, 'belge_satir.id', '', '', '', k.ix * 100 + 14
                    from kalem k
                  union all
                  -- ISLEM_HEKIM_BILGISI grubu: ACILDIYSA ICI DE TAM OLMALI.
                  --   Grup opsiyonel (GEN_ISLEM_BILGISI gibi hic acilmayabilir)
                  --   ama bir kez acildi mi USS icindeki alanlari da ariyor:
                  --   "E1016 ... eksik PUAN_HAKEDIS_ZAMANI" (canli deneme,
                  --   paket 479). Hekimi bildirmek istiyoruz, o yuzden grup
                  --   acilir ve dordu de yazilir - degeri olan doldurulur,
                  --   olmayan bos gider.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/ISLEM_HEKIM_BILGISI/ASISTAN_HEKIM_KIMLIK_NUMARASI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 15
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/ISLEM_HEKIM_BILGISI/HEKIM_KIMLIK_NUMARASI',
                         coalesce((select t.vkno from public.taraf t
                                    join public.belge_basvuru b2 on b2.personel_id = t.id
                                   where b2.id = @p0), ''),
                         'taraf.vkno (hekim)', '', '', '', k.ix * 100 + 16
                    from kalem k
                  union all
                  -- ISLEM_PUANI / PUAN_HAKEDIS_ZAMANI: hekim performans
                  --   puanlamasi. Prim modulumuz ayri calisiyor, USS'ye
                  --   bildirilen bir puan uretmiyoruz.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/ISLEM_HEKIM_BILGISI/ISLEM_PUANI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 17
                    from kalem k
                  union all
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/ISLEM_HEKIM_BILGISI/PUAN_HAKEDIS_ZAMANI',
                         '', '(karsiligi yok)', '', '', '', k.ix * 100 + 18
                    from kalem k
                  order by 7
                ) as k2(uss_alan, deger, kaynak, skrs_liste, skrs_kod,
                        skrs_sistem, sira)
                """,

            // 101 HASTA KAYIT - USS'nin GERCEK alan adlari ve yollari (605).
            //   Alan adi artik "VERI_SETI/ALAN" yolu tasir; SKRS kodlu alanlar
            //   5. ve 6. kolonda kod + codeSystemGuid dondurur (bos ise duz
            //   deger yazilir). Tarihler USS bicimi: yyyyMMddHHmm.
            //   Sema: dokuman/09_ENABIZ_USS_SEMASI.md
            "HASTA_KABUL" => """
                select 'HASTA_KIMLIK_BILGILERI/HASTA_KIMLIK_NUMARASI',
                       coalesce(h.vkno, ''), 'taraf.vkno', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/AD',
                       coalesce(nullif(h.ad, ''), h.unvan), 'taraf.ad', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/SOYAD',
                       coalesce(h.soyad, ''), 'taraf.soyad', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/DOGUM_TARIHI',
                       coalesce(to_char(th.dogum_tarihi, 'YYYYMMDD') || '0000', ''),
                       'taraf_hasta.dogum_tarihi', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- KOD LISTESI ARTIK SKRS'NIN KENDISI (609/610): yerel deger
                --   dogrudan SKRS kodudur, ceviri katmani yok. Ad da listeden
                --   okunur - SKRS'nin yazdigi metinle birebir gider.
                union all select 'HASTA_KIMLIK_BILGILERI/CINSIYET',
                       public.fn_skrs_ad('hasta.cinsiyet', th.cinsiyet),
                       'kod_deger[hasta.cinsiyet]', 'SKRS Cinsiyet',
                       public.fn_skrs_kod('hasta.cinsiyet', th.cinsiyet),
                       public.fn_skrs_guid('hasta.cinsiyet')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- UYRUK: USS ISO harf kodunu (TR) KABUL ETMIYOR, MERNIS
                --   kodunu (9980) istiyor - canli denemede code="TR" "E1008
                --   Code 'TR' ... bulunamadi", code="9980" ile alan gecti.
                --   609 hasta kartindaki uyrugu MERNIS koduna cevirdi, alan
                --   artik dogrudan o kodu tasiyor.
                union all select 'HASTA_KIMLIK_BILGILERI/UYRUK',
                       public.fn_skrs_ad('hasta.uyruk', th.uyruk),
                       'taraf_hasta.uyruk (MERNIS)', 'SKRS Ulke',
                       public.fn_skrs_kod('hasta.uyruk', th.uyruk),
                       public.fn_skrs_guid('hasta.uyruk')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- HASTA TIPI: USS'nin istedigi liste, SKRS'nin klinik
                --   "HASTA TIPI"si (bebek/gebe/obez...) DEGIL, GP_HASTA_TIPI:
                --   VATANDAS_KAYIT / YABANCI_KAYIT / VATANSIZ / YENIDOGAN /
                --   KIMLIKSIZ. Bu hasta kartindan KESIN turetilir (610), o
                --   yuzden artik bos gitmiyor. Once liste-basi `limit 1` ile
                --   rastgele kod seciliyordu ve erkek hastaya "15-49 KADIN
                --   HASTALAR" yaziyordu (basvuru 1092) - yanlis liste, yanlis
                --   kod. Simdi hem liste dogru hem deger hastanin kendisinden.
                union all select 'HASTA_KIMLIK_BILGILERI/HASTA_TIPI',
                       public.fn_skrs_ad('hasta.tipi', th.hasta_tipi),
                       'taraf_hasta.hasta_tipi', 'SKRS Hasta Kayit Tipi',
                       public.fn_skrs_kod('hasta.tipi', th.hasta_tipi),
                       public.fn_skrs_guid('hasta.tipi')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- SEMADAKI KIMLIK ALANLARI EKSIKSIZ GIDER (602): USS govdeyi
                --   XSD ile dogruluyor ve yazilmayan elemani sema ihlali
                --   sayiyor - "E1014 ... eksik elemanlar var: UYRUK,
                --   ANNE_KIMLIK_NUMARASI, DOGUM_SIRASI, ..." (paket 194).
                --   Degeri olanlar karttan, olmayanlar BOS gider; bos gitmek
                --   gecerli, hic gitmemek degil.
                union all select 'HASTA_KIMLIK_BILGILERI/ANNE_KIMLIK_NUMARASI',
                       coalesce(th.anne_tckn, ''), 'taraf_hasta.anne_tckn', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/BABA_KIMLIK_NUMARASI',
                       coalesce(th.baba_tckn, ''), 'taraf_hasta.baba_tckn', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/PASAPORT_NO',
                       coalesce(th.pasaport_no, ''), 'taraf_hasta.pasaport_no', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- Karsiligi olmayan sema alanlari: BOS ama VAR.
                --   DOGUM_SIRASI cogul dogumda sira (bizde tutulmuyor),
                --   BEYAN_DOGUM_TARIHI kimliksiz hastanin beyani,
                --   KIMLIKSIZ_HASTA_BILGISI ve YABANCI_* yabanci/kimliksiz
                --   vakalar icin - hicbirinin yerel karsiligi yok.
                union all select 'HASTA_KIMLIK_BILGILERI/DOGUM_SIRASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/YABANCI_HASTA_KIMLIK_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/KIMLIKSIZ_HASTA_BILGISI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/BEYAN_DOGUM_TARIHI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- ADRES_BILGISI ZORUNLU GRUP (602): kilavuzda "Evet", eksik
                --   olunca USS "E1013 Xml dokumaninda eksik elemanlar var:
                --   ADRES_BILGISI" donuyor (gercek vaka, paket 183).
                --   Adres VARSAYILAN olani, yoksa ilk aktif kayit; hasta
                --   kartinda adres hic yoksa alanlar bos gider ve grup yine
                --   de yazilir - USS grubun VARLIGINI ariyor.
                -- ADRES GRUBUNUN ILK IKI ALANI (602): USS "E1016 ... eksik
                --   veya dokumanda bulunmamasi gerekiyor ADRES_KODU" dondu
                --   (paket 205). Kilavuzdaki sira: ADRES_KODU_SEVIYESI,
                --   ADRES_KODU, ACIK_ADRES, ACIK_ADRES_ILCE - XSD sequence
                --   olabilecegi icin AYNI SIRAYLA uretilir. Ikisinin de yerel
                --   karsiligi yok (SKRS adres kodlama sistemi), bos gider.
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ADRES_KODU_SEVIYESI',
                       '', '(karsiligi yok)', 'SKRS Adres Kodu Seviyesi',
                       '', 'aa0e83ba-e9db-4817-80da-577fd6a17373'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ADRES_KODU',
                       '', '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES',
                       coalesce((select a.adres from public.taraf_adres a
                                  where a.taraf_id = b.taraf_id and a.aktif = 1
                                  order by a.varsayilan desc, a.id limit 1), ''),
                       'taraf_adres.adres', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES_ILCE',
                       coalesce((select a.ilce from public.taraf_adres a
                                  where a.taraf_id = b.taraf_id and a.aktif = 1
                                  order by a.varsayilan desc, a.id limit 1), ''),
                       'taraf_adres.ilce', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/TELEFON_NUMARASI',
                       coalesce(h.telefon, ''), 'taraf.telefon', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                -- ====================== HASTA_BASVURU_BILGILERI ======================
                -- SIRA KILAVUZLA BIREBIR (602): USS govdeyi XSD ile dogruluyor,
                --   sema `sequence` ise eleman SIRASI da baglayicidir. Alanlar
                --   kilavuzun 101 ornegindeki sirayla uretilir; karsiligi
                --   olmayanlar BOS ama VAR - eksik eleman sema ihlali sayiliyor
                --   ("E1013 ... eksik elemanlar var: YATIS_BILGISI", paket 216).
                union all select 'HASTA_BASVURU_BILGILERI/SPK_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HTS_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_AKILLI_BILEKLIK_NUMARASI',
                       coalesce(bb.ambulans_bileklik_no, ''),
                       'belge_basvuru.ambulans_bileklik_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_HASTA_NO',
                       coalesce(bb.ambulans_hasta_no, ''),
                       'belge_basvuru.ambulans_hasta_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_TAKIP_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/PAKETE_AIT_ISLEM_ZAMANI',
                       to_char(now(), 'YYYYMMDDHH24MI'), '(uretim zamani)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/DIS_ISTEM_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HIZMET_SUNUCU',
                       coalesce((select e.ad from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu (tesis)', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/KAYIT_YERI',
                       coalesce((select e.ad from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu (tesis)', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/PROTOKOL_NUMARASI',
                       coalesce(b.belge_no, ''), 'belge.belge_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HASTANE_REFERANS_NUMARASI',
                       b.id::text, 'belge.id', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/SGK_TAKIP_NUMARASI',
                       coalesce((select bp.sgk_takip_no from public.belge_provizyon bp
                                  where bp.id = b.id), ''),
                       'belge_provizyon.sgk_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/KABUL_ZAMANI',
                       to_char(b.belge_tarihi, 'YYYYMMDDHH24MI'),
                       'belge.belge_tarihi', '', '', ''
                  from public.belge b where b.id = @p0
                -- KLINIK: `departman.kod`un KENDISI SKRS klinik kodudur (619) -
                --   ayri kolon yok, bir kod iki yerde durmaz.
                --
                --   619 oncesi buradaki degerler SKRS'nin KLINIKLER degil
                --   PERSONEL BRANS listesinden geliyordu ve her paket yanlis
                --   klinigi bildiriyordu ("Acil" bolumunun kodu 102,
                --   KLINIKLER'de 102 = ADLI TIP). Goc kodlari duzeltti,
                --   karsiligi bulunamayanlari BOSALTTI.
                --
                --   Kod yine de LISTEDE ARANIR: elle girilmis, SKRS'de
                --   bulunmayan bir kod pakete YAZILMAZ. Boylece bos birakilan
                --   52 bolumden biri sonradan gelisiguzel doldurulursa
                --   sessizce yanlis klinik gitmez.
                union all select 'HASTA_BASVURU_BILGILERI/KLINIK_KODU',
                       public.fn_skrs_ad('klinik.kod',
                           nullif((select d.kod from public.departman d
                                    where d.id = bb.bolum_id
                                      and d.kod ~ '^[0-9]+$'), '')::int),
                       'departman.kod (SKRS klinik)', 'SKRS Klinik',
                       coalesce(
                         public.fn_skrs_kod('klinik.kod',
                           nullif((select d.kod from public.departman d
                                    where d.id = bb.bolum_id
                                      and d.kod ~ '^[0-9]+$'), '')::int),
                         (select k.skrs_kod from public.enabiz_kod_esleme k
                           where k.esleme_turu = 'KLINIK' and k.yerel_id = bb.bolum_id
                             and k.aktif = 1 limit 1),
                         ''),
                       public.fn_skrs_guid('klinik.kod')
                  from public.belge_basvuru bb where bb.id = @p0
                -- SOSYAL GUVENCE: basvurunun KENDI alt kurumundan (SSK,
                --   Bag-Kur, Emekli Sandigi, ozel sigorta...). Kurum kimligi
                --   uzerinden esleme aranmasi yanlisti: ayni kurumun farkli
                --   police turleri farkli guvence demek.
                union all select 'HASTA_BASVURU_BILGILERI/SOSYAL_GUVENCE_DURUMU',
                       public.fn_skrs_hedef_ad('kurum.alt_kurum', bb.alt_kurum),
                       'belge_basvuru.alt_kurum', 'SKRS Sosyal Guvence',
                       public.fn_skrs_kod('kurum.alt_kurum', bb.alt_kurum),
                       public.fn_skrs_guid('kurum.alt_kurum')
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HEKIM_KIMLIK_NUMARASI',
                       coalesce((select t.vkno from public.taraf t
                                  where t.id = bb.personel_id), ''),
                       'taraf.vkno (hekim)', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/VAKA_TURU',
                       public.fn_skrs_hedef_ad('basvuru.gelis_nedeni', bb.gelis_nedeni),
                       'belge_basvuru.gelis_nedeni', 'SKRS Vaka Turu',
                       public.fn_skrs_kod('basvuru.gelis_nedeni', bb.gelis_nedeni),
                       public.fn_skrs_guid('basvuru.gelis_nedeni')
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/MHRS_RANDEVU_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/TRIAJ', '',
                       '(karsiligi yok)', 'SKRS Triaj',
                       '', '1ddcbef5-4006-41fe-87c0-6190c9801708'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/BASVURU_HIZMET_ALIMI_BILGISI', '',
                       '(karsiligi yok)', 'SKRS Hizmet Alimi',
                       '', 'c9d56fee-d143-4602-ad7b-ba131ef92ad9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/E_SEVK_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- YATIS_BILGISI: AYAKTA basvuruda da GRUP OLARAK bulunmali,
                --   icindekiler bos. Yatis modulu gelince buradan doldurulur.
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATIS_KABUL_ZAMANI', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATAK_NO', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATIS_GUNUBIRLIK_MI', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- YATISIN ACILIYETI: grubun icindeki TEK ZORUNLU alan.
                --   Ayakta basvuruda da kod istiyor - grubu bos birakinca
                --   "E1016 ... eksik veya dokumanda bulunmamasi gerekiyor
                --   YATISIN_ACILIYETI", grubu hic yazmayinca "E1013 ...
                --   eksik elemanlar var: YATIS_BILGISI". SKRS listesinde
                --   bunun kendi kodu var: 3 = ACILIYET DURUMU ATANMAMIS -
                --   yatis olmayan basvurunun DOGRU karsiligi, uydurma degil.
                --   Yatis modulu gelince gercek aciliyet buradan yazilacak.
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATISIN_ACILIYETI',
                       public.fn_skrs_ad('yatis.aciliyet', 3),
                       'yatis yok -> ACILIYET DURUMU ATANMAMIS',
                       'SKRS Yatis Aciliyeti',
                       public.fn_skrs_kod('yatis.aciliyet', 3),
                       public.fn_skrs_guid('yatis.aciliyet')
                  from public.belge b where b.id = @p0
                """,

            // 103 MUAYENE BILGISI - USS adlari (605).
            //   Her paket (101 haric) once HASTA_TAKIP_BILGISI/SYSTakipNo
            //   tasir: 101'in yanitinda donen numara, basvurunun USS'deki
            //   kimligidir. O olmadan muayene hangi basvuruya baglanacagini
            //   bilemez - bu yuzden ZORUNLU ilk alan.
            "MUAYENE" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = m.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/MUAYENE_BASLANGIC_TARIHI',
                       coalesce(to_char(m.baslangic, 'YYYYMMDDHH24MI'), ''),
                       'muayene.baslangic', '', '', ''
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/MUAYENE_BITIS_TARIHI',
                       coalesce(to_char(coalesce(m.bitis, m.tamamlanma),
                                        'YYYYMMDDHH24MI'), ''),
                       'muayene.bitis', '', '', ''
                  from public.muayene m where m.id = @p0
                -- TANI: ana tani TANI_TURU kodlu, ICD10 kendi kod sisteminde.
                union all select 'MUAYENE_BILGILERI/TANI_BILGISI/ICD10',
                       coalesce((select t.icd_kod from public.tani t
                                  where t.muayene_id = m.id and t.tur = 1 limit 1), ''),
                       'tani (tur=1)', 'ICD-10',
                       coalesce((select t.icd_kod from public.tani t
                                  where t.muayene_id = m.id and t.tur = 1 limit 1), ''),
                       'c3eaabad-8c4c-56ee-e043-14031b0a5530'
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/EPIKRIZ_BILGISI/EPIKRIZ_BILGISI_ACIKLAMA',
                       left(coalesce(m.sikayet, ''), 400), 'muayene.sikayet', '', '', ''
                  from public.muayene m where m.id = @p0
                """,

            // 106 HASTA CIKIS - USS adlari (605).
            "HASTA_CIKIS" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_CIKIS_BILGILERI/CIKIS_ZAMANI',
                       coalesce(to_char(b.degistirme_tarihi, 'YYYYMMDDHH24MI'),
                                to_char(b.belge_tarihi, 'YYYYMMDDHH24MI'), ''),
                       'belge.degistirme_tarihi', '', '', ''
                  from public.belge b where b.id = @p0
                -- CIKIS SEKLI: basvurunun GELIS seklinden okunuyordu - baska
                --   bir alan, baska bir liste; ustelik gomulu GUID SKRS'deki
                --   "CIKIS SEKLI" listesinin GUID'i bile degildi. Cikis sekli
                --   icin yerelde HENUZ kaynak kolon yok (yatis/taburcu modulu
                --   gelince dolacak), o yuzden alan BOS gider: yanlis kod,
                --   bos koddan kotudur.
                union all select 'HASTA_CIKIS_BILGILERI/CIKIS_SEKLI',
                       '', '(kaynak yok - taburcu modulu)', 'SKRS Cikis Sekli',
                       '', public.fn_skrs_guid('cikis.sekli')
                  from public.belge_basvuru bb where bb.id = @p0
                """,

            _ => "",
        };

        return sql.Length == 0
            ? Task.FromResult(new List<AlanDegeri>())
            : baglanti.ListeAsync(sql, islem, [kaynakId],
                o => new AlanDegeri(o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
                                    o.GetString(2), o.GetString(3),
                                    o.FieldCount > 4 && !o.IsDBNull(4) ? o.GetString(4) : "",
                                    o.FieldCount > 5 && !o.IsDBNull(5) ? o.GetString(5) : ""),
                iptal);
    }

    /// <summary>İçerik parmak izi - aynı içerik ikinci kez paket açmasın.</summary>
    private static string Hash(IEnumerable<string> parcalar)
        => Convert.ToHexString(SHA256.HashData(
               Encoding.UTF8.GetBytes(string.Join("\n", parcalar)))).ToLowerInvariant()[..64];
}
