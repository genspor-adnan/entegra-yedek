using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sigorta;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// SİGORTA İŞ AKIŞI (430) — hesap çözümü, provizyon yazımı, pay dağıtımı.
///
/// <para><b>Adapter yalnız protokolü bilir; kayıt ve kural burada.</b> Hangi
/// belgeden hangi satırların gideceği, provizyonun nasıl saklanacağı ve
/// belgenin payının nasıl dağıtılacağı sağlayıcıdan bağımsızdır - ikinci
/// şirket eklenince bu dosya değişmemeli.</para>
///
/// <para><b>Her dış çağrı günlüğe yazılır</b> (<c>sigorta_istek_log</c>):
/// ihtilafta kanıt, hata ayıklamada tek bakılacak yer. Günlük yazımı iş
/// akışını DÜŞÜRMEZ - log yazılamadı diye alınmış provizyon kaybolmamalı.</para>
/// </summary>
public sealed class SigortaServisi(
    VeriKaynagi veri, SigortaKodDeposu kodlar,
    IEnumerable<ISigortaSaglayici> saglayicilar, ILogger<SigortaServisi> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly SigortaKodDeposu _kodlar = kodlar;
    private readonly IReadOnlyList<ISigortaSaglayici> _saglayicilar = [.. saglayicilar];
    private readonly ILogger<SigortaServisi> _gunluk = gunluk;

    public sealed record Baglanti(SigortaHesabi Hesap, ISigortaSaglayici Saglayici);

    // ==================================================================== hesap

    /// <summary>
    /// Kurumun sağlayıcı hesabını çözer.
    ///
    /// YARIM YAPILANDIRILMIŞ HESAP HESAP SAYILMAZ: adres ya da istemci
    /// kimliği boşsa iş kuralı hatası döner. "Bağlanılamadı" diye her
    /// provizyona hata yazmak, kapının kapalı olduğunu gizlerdi.
    /// </summary>
    public async Task<Baglanti> HesapCozAsync(int kurumId, int? subeId,
                                              CancellationToken iptal)
    {
        var h = await _veri.TekAsync("""
            select h.id, h.saglayici_id, s.kod, h.kurum_id,
                   coalesce(nullif(case when e.test_mi = 1 then e.test_url else e.url end, ''), ''),
                   coalesce(e.kullanici_adi, ''), coalesce(e.sifre, ''),
                   coalesce(e.uygulama_kodu, ''),
                   coalesce(e.ayarlar ->> 'client_secret', ''),
                   coalesce(e.kurum_kodu, ''), e.test_mi
              from public.sigorta_hesap h
              join public.sigorta_saglayici s on s.id = h.saglayici_id
              join public.entegrasyon_hesap e on e.id = h.hesap_id
             where h.kurum_id = @p0 and h.durum = 0 and s.durum = 0 and e.aktif = 1
               and (h.sube_id is null or h.sube_id = @p1)
             order by case when h.sube_id = @p1 then 0 else 1 end, h.varsayilan desc, h.id
             limit 1
            """, [kurumId, subeId ?? 0],
            o => new SigortaHesabi(o.GetInt32(0), o.GetInt16(1), o.GetString(2),
                                   o.GetInt32(3), o.GetString(4), o.GetString(5),
                                   o.GetString(6), o.GetString(7), o.GetString(8),
                                   o.GetString(9), o.GetInt16(10) == 1), iptal)
            ?? throw GentegreHatasi.IsKurali(
                "Bu kurum için sigorta entegrasyon hesabı tanımlı değil.");

        if (h.Adres.Length == 0 || h.IstemciId.Length == 0)
            throw GentegreHatasi.IsKurali(
                "Sigorta hesabı eksik: servis adresi ve istemci kimliği girilmeli.");

        var saglayici = _saglayicilar.FirstOrDefault(s =>
                            s.Kod.Equals(h.SaglayiciKod, StringComparison.OrdinalIgnoreCase))
            ?? throw GentegreHatasi.IsKurali(
                $"'{h.SaglayiciKod}' sağlayıcısı bu sürümde desteklenmiyor.");

        await _kodlar.YukleAsync(h.SaglayiciId, iptal);
        return new Baglanti(h, saglayici);
    }

    // =================================================================== poliçe

    public async Task<(int Id, PoliceSonucu Sonuc)> PoliceSorgulaAsync(
        int tarafId, int kurumId, int? hekimId, string policeNo, DateTime tarih,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var b = await HesapCozAsync(kurumId, baglam.SubeId, iptal);
        if (!b.Saglayici.Yetenekler.Police)
            throw GentegreHatasi.IsKurali("Bu sağlayıcı poliçe sorgusu desteklemiyor.");

        var hasta = await HastaOkuAsync(tarafId, iptal);
        var hekim = await HekimOkuAsync(hekimId, iptal);

        var istek = new PoliceIstegi(hasta.KimlikNo, hasta.KimlikTipi, policeNo, tarih, hekim);
        PoliceSonucu sonuc;
        try
        {
            sonuc = await b.Saglayici.PoliceSorgulaAsync(b.Hesap, istek, iptal);
        }
        catch (Exception h)
        {
            await LogYazAsync(b.Hesap, "checkPolicy", "police", null, 0, 0, false,
                              h.Message, null, null, baglam, iptal);
            throw GentegreHatasi.IsKurali($"Poliçe sorgusu başarısız: {h.Message}");
        }

        await LogYazAsync(b.Hesap, "checkPolicy", "police", null, 0, 0, sonuc.Gecerli,
                          sonuc.Gecerli ? "" : string.Join(" · ", sonuc.Notlar),
                          null, sonuc.HamYanit, baglam, iptal);

        // Poliçe KAYIT olarak saklanır (önbellek değil): "o gün poliçe
        //   geçerliydi" beyanı ihtilafta kanıttır, sonradan sorgu aynı yanıtı
        //   vermez.
        var id = await _veri.TekDegerAsync<int>("""
            insert into public.sigorta_police
                   (saglayici_id, taraf_id, kurum_id, police_no, police_adi,
                    kart_no, musteri_no, ag_kodu, gecerli, notlar, ham_yanit,
                    sorgu_zamani, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10::jsonb,
                    now(), @p11, @p12)
            on conflict (saglayici_id, taraf_id, police_no) do update
               set police_adi = excluded.police_adi, kart_no = excluded.kart_no,
                   musteri_no = excluded.musteri_no, ag_kodu = excluded.ag_kodu,
                   gecerli = excluded.gecerli, notlar = excluded.notlar,
                   ham_yanit = excluded.ham_yanit, sorgu_zamani = now()
            returning id
            """,
            [b.Hesap.SaglayiciId, tarafId, kurumId, sonuc.PoliceNo, sonuc.PoliceAdi,
             sonuc.KartNo, sonuc.MusteriNo, sonuc.AgKodu, (short)(sonuc.Gecerli ? 1 : 0),
             string.Join("\n", sonuc.Notlar), JsonGuvenli(sonuc.HamYanit),
             baglam.SubeId ?? 0, baglam.KullaniciId], iptal);

        return (id, sonuc);
    }

    // ================================================================ provizyon

    public sealed record ProvizyonAyari(short Tip, short? AltTip, short? HizmetTipi,
                                        short VakaTipi, short TalepTuru, bool Acil,
                                        string Not);

    /// <summary>
    /// Başvurudan provizyon oluşturur ya da günceller.
    ///
    /// SATIR KİMLİĞİ belge satırının id'sidir (hospitalRowNumber): yanıttaki
    /// kırılım bununla eşleştirilir. Sıraya güvenilseydi şirketin farklı
    /// sırada döndürdüğü satırlar yanlış kaleme yazılırdı.
    /// </summary>
    public async Task<int> ProvizyonYazAsync(int belgeId, ProvizyonAyari ayar,
                                             IstekBaglami baglam, CancellationToken iptal)
    {
        var belge = await BelgeOkuAsync(belgeId, iptal);
        if (belge.KurumId is not > 0)
            throw GentegreHatasi.IsKurali(
                "Başvuruda ödeyen kurum seçili değil - provizyon kime sorulacak?");

        var b = await HesapCozAsync(belge.KurumId.Value, baglam.SubeId, iptal);
        if (!b.Saglayici.Yetenekler.Provizyon)
            throw GentegreHatasi.IsKurali("Bu sağlayıcı provizyon desteklemiyor.");

        var satirlar = await SatirlariOkuAsync(belgeId, iptal);
        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali(
                "Başvuruda ücretlendirilmiş kalem yok - önce işlem/sarf girin.");

        var hasta = await HastaOkuAsync(belge.TarafId, iptal);
        var hekim = await HekimOkuAsync(belge.PersonelId, iptal);
        var tanilar = await TanilariOkuAsync(belgeId, iptal);
        var police = await PoliceOkuAsync(b.Hesap.SaglayiciId, belge.TarafId,
                                          belge.KurumId.Value, iptal);

        // MEVCUT PROVİZYON: aynı başvuruda ikinci kayıt açılmaz - güncelleme
        //   aynı provizyon numarasıyla gider (createProvision hem oluşturur
        //   hem günceller).
        var mevcut = await _veri.TekAsync("""
            select id, provizyon_no, kurum_ref_no, durum
              from public.sigorta_provizyon
             where belge_id = @p0 and durum <> 6
             order by id desc limit 1
            """, [belgeId],
            o => new { Id = o.GetInt32(0), No = o.GetString(1), Ref = o.GetString(2),
                       Durum = o.GetInt16(3) }, iptal);

        var refNo = mevcut?.Ref is { Length: > 0 } r ? r
                  : await _veri.TekDegerAsync<string>(
                        "select public.fn_sigorta_ref_no(@p0, current_date)",
                        [baglam.SubeId ?? 0], iptal) ?? "";

        var istek = new ProvizyonIstegi(
            ProvizyonNo: mevcut?.No ?? "",
            KurumRefNo: refNo,
            TakipNo: "",
            ProvizyonTarihi: belge.Tarih,
            Tip: ayar.Tip, AltTip: ayar.AltTip, HizmetTipi: ayar.HizmetTipi,
            VakaTipi: ayar.VakaTipi, TalepTuru: ayar.TalepTuru, Acil: ayar.Acil,
            Sigortali: new SigortaliBilgisi(hasta.Ad, hasta.Soyad, hasta.DogumTarihi,
                                            hasta.Cinsiyet, hasta.KimlikNo,
                                            hasta.KimlikTipi, police?.KartNo ?? "",
                                            police?.MusteriNo ?? ""),
            PoliceNo: police?.PoliceNo ?? "",
            PoliceAdi: police?.PoliceAdi ?? "",
            PoliceTipi: police?.PoliceTipi ?? 0,
            PoliceTuru: police?.PoliceTuru ?? 0,
            KartNo: police?.KartNo ?? "",
            Hasta: new HastaBilgisi(belge.Sikayet, null, belge.Ozgecmis, "",
                                    null, false, null, null, belge.Tarih),
            Hekim: hekim,
            Tanilar: tanilar,
            Satirlar: satirlar,
            Not: ayar.Not);

        ProvizyonSonucu sonuc;
        try
        {
            sonuc = await b.Saglayici.ProvizyonYazAsync(b.Hesap, istek, iptal);
        }
        catch (Exception h)
        {
            await LogYazAsync(b.Hesap, "createProvision", "provizyon", mevcut?.Id,
                              0, 0, false, h.Message, null, null, baglam, iptal);
            throw GentegreHatasi.IsKurali($"Provizyon gönderilemedi: {h.Message}");
        }

        var id = await ProvizyonKaydetAsync(b, belge, mevcut?.Id, refNo, ayar, hekim,
                                            police?.Id, istek, sonuc, baglam, iptal);

        await LogYazAsync(b.Hesap, "createProvision", "provizyon", id, 0, 0,
                          sonuc.Basarili, sonuc.Hata, sonuc.HamIstek, sonuc.HamYanit,
                          baglam, iptal);

        if (!sonuc.Basarili)
            throw GentegreHatasi.IsKurali(
                sonuc.Hata.Length > 0 ? sonuc.Hata
                : "Provizyon oluşmadı; şirket bir provizyon numarası döndürmedi.");

        return id;
    }

    /// <summary>searchProvisions ile durumu ve kırılımı tazeler.</summary>
    public async Task<int> ProvizyonTazeleAsync(int provizyonId, IstekBaglami baglam,
                                                CancellationToken iptal)
    {
        var p = await ProvizyonBasligiAsync(provizyonId, iptal);
        var b = await HesapCozAsync(p.KurumId, baglam.SubeId, iptal);

        var sonuc = await b.Saglayici.ProvizyonOkuAsync(b.Hesap, p.ProvizyonNo,
                                                        p.KurumRefNo, iptal);
        await LogYazAsync(b.Hesap, "searchProvisions", "provizyon", provizyonId, 0, 0,
                          sonuc.Basarili, sonuc.Hata, null, sonuc.HamYanit, baglam, iptal);

        if (!sonuc.Basarili && sonuc.Satirlar.Count == 0)
            throw GentegreHatasi.IsKurali(
                sonuc.Hata.Length > 0 ? sonuc.Hata : "Provizyon sorgulanamadı.");

        await SonucIsleAsync(provizyonId, sonuc, baglam, iptal);
        return provizyonId;
    }

    public async Task<string> ProvizyonIptalAsync(int provizyonId, short nedenKodu,
        string aciklama, IstekBaglami baglam, CancellationToken iptal)
    {
        var p = await ProvizyonBasligiAsync(provizyonId, iptal);
        if (p.Durum == SigortaKanonik.Durum.Iptal)
            throw GentegreHatasi.IsKurali("Provizyon zaten iptal edilmiş.");
        if (p.ProvizyonNo.Length == 0)
            throw GentegreHatasi.IsKurali(
                "Şirkete gönderilmemiş provizyon iptal edilemez; kaydı silin.");

        var b = await HesapCozAsync(p.KurumId, baglam.SubeId, iptal);
        if (!b.Saglayici.Yetenekler.Iptal)
            throw GentegreHatasi.IsKurali("Bu sağlayıcı provizyon iptali desteklemiyor.");

        var kullanici = await _veri.TekDegerAsync<string>("""
            select coalesce(t.vkno, '') from public.taraf t where t.id = @p0
            """, [baglam.KullaniciId], iptal) ?? "";

        var sonuc = await b.Saglayici.ProvizyonIptalAsync(b.Hesap,
            new IptalIstegi(p.ProvizyonNo, nedenKodu, aciklama, kullanici), iptal);

        await LogYazAsync(b.Hesap, "cancelProvision", "provizyon", provizyonId, 0, 0,
                          sonuc.Basarili, sonuc.Basarili ? "" : sonuc.Aciklama,
                          null, sonuc.HamYanit, baglam, iptal);

        if (!sonuc.Basarili)
            throw GentegreHatasi.IsKurali(
                sonuc.Aciklama.Length > 0 ? sonuc.Aciklama : "İptal reddedildi.");

        await _veri.CalistirAsync("""
            update public.sigorta_provizyon
               set durum = 6, iptal_nedeni = @p1, iptal_aciklama = @p2,
                   degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, [provizyonId, nedenKodu, aciklama, baglam.KullaniciId], iptal);

        // PAY GERİ ALINIR: iptal edilen provizyonun sigorta payı düşer ve
        //   dağılım LİSTE fiyatına döner. Bırakılsaydı iptal edilmiş bir
        //   provizyonun tutarı kurumdan tahsil edilecekmiş gibi görünürdü.
        //   Kural sunucuda tek yerde (472): burada tazeleme ÇAĞRILIR, kova
        //   elle yazılmaz - yoksa aynı hesap iki yerde dururdu.
        await _veri.CalistirAsync("select public.fn_sigorta_pay_geri_al(@p0)",
                                  [provizyonId], iptal);
        await _veri.CalistirAsync("select public.fn_sigorta_ozet_tazele(@p0)",
                                  [provizyonId], iptal);

        return sonuc.Aciklama.Length > 0 ? sonuc.Aciklama : "Provizyon iptal edildi.";
    }

    public async Task<int> DokumanGonderAsync(int provizyonId, string tipKodu,
        string dosyaAdi, string mime, byte[] icerik, int? dokumanId,
        IstekBaglami baglam, CancellationToken iptal)
    {
        var p = await ProvizyonBasligiAsync(provizyonId, iptal);
        if (p.ProvizyonNo.Length == 0)
            throw GentegreHatasi.IsKurali(
                "Provizyon numarası olmadan doküman gönderilemez.");

        var b = await HesapCozAsync(p.KurumId, baglam.SubeId, iptal);
        if (!b.Saglayici.Yetenekler.Dokuman)
            throw GentegreHatasi.IsKurali("Bu sağlayıcı doküman gönderimi desteklemiyor.");

        var sira = await _veri.TekDegerAsync<int>("""
            select coalesce(count(*), 0) + 1 from public.sigorta_dokuman
             where provizyon_id = @p0
            """, [provizyonId], iptal);

        var kayitId = await _veri.TekDegerAsync<int>("""
            insert into public.sigorta_dokuman
                   (provizyon_id, dokuman_id, tip_kodu, dosya_adi, mime, boyut,
                    durum, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, 1, @p6)
            returning id
            """, [provizyonId, dokumanId, tipKodu, dosyaAdi, mime, icerik.Length,
                  baglam.KullaniciId], iptal);

        var sonuc = await b.Saglayici.DokumanGonderAsync(b.Hesap,
            new DokumanIstegi(p.ProvizyonNo, tipKodu, dosyaAdi, mime, icerik, sira), iptal);

        await _veri.CalistirAsync("""
            update public.sigorta_dokuman
               set durum = @p1, saglayici_ref = @p2, hata = @p3, gonderim = now()
             where id = @p0
            """, [kayitId, (short)(sonuc.Basarili ? 2 : 3), sonuc.SaglayiciRef,
                  sonuc.Hata], iptal);

        await LogYazAsync(b.Hesap, "organizationCreateDocument", "dokuman", kayitId,
                          0, 0, sonuc.Basarili, sonuc.Hata, null, sonuc.HamYanit,
                          baglam, iptal);

        if (!sonuc.Basarili)
            throw GentegreHatasi.IsKurali(
                sonuc.Hata.Length > 0 ? sonuc.Hata : "Doküman kabul edilmedi.");

        return kayitId;
    }

    // ================================================================== kayıt

    private async Task<int> ProvizyonKaydetAsync(Baglanti b, BelgeOzeti belge,
        int? mevcutId, string refNo, ProvizyonAyari ayar, HekimBilgisi hekim,
        int? policeId, ProvizyonIstegi istek, ProvizyonSonucu sonuc,
        IstekBaglami baglam, CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var talep = istek.Satirlar.Sum(s => s.TalepTutar);
        var sirket = sonuc.Satirlar.Sum(s => s.SirketTutar);

        int id;
        if (mevcutId is { } m)
        {
            id = m;
            await baglanti.CalistirAsync("""
                update public.sigorta_provizyon
                   set provizyon_no = @p1, durum = @p2, tip = @p3, alt_tip = @p4,
                       hizmet_tipi = @p5, vaka_tipi = @p6, talep_turu = @p7, acil = @p8,
                       police_id = coalesce(@p9, police_id),
                       talep_toplam = @p10, sirket_payi = @p11,
                       hasta_payi = @p12, onay_toplam = @p11,
                       karar_tipi = @p13, red_nedeni = @p14,
                       ham_istek = @p15::jsonb, ham_yanit = @p16::jsonb,
                       degistiren = @p17, degistirme_tarihi = now()
                 where id = @p0
                """, islem,
                [id, sonuc.ProvizyonNo, sonuc.Durum, ayar.Tip, ayar.AltTip,
                 ayar.HizmetTipi, ayar.VakaTipi, ayar.TalepTuru,
                 (short)(ayar.Acil ? 1 : 0), policeId, talep, sirket,
                 Math.Max(0, talep - sirket), sonuc.KararTipi, sonuc.RedNedeni,
                 JsonGuvenli(sonuc.HamIstek), JsonGuvenli(sonuc.HamYanit),
                 baglam.KullaniciId], iptal);

            // Satır/tanı/not YENİDEN yazılır: şirket her yanıtta tam listeyi
            //   döndürür, birleştirmeye çalışmak eski kırılımı canlı bırakırdı.
            foreach (var tablo in new[] { "sigorta_provizyon_satir",
                                          "sigorta_provizyon_tani",
                                          "sigorta_provizyon_not" })
                await baglanti.CalistirAsync(
                    $"delete from public.{tablo} where provizyon_id = @p0",
                    islem, [id], iptal);
        }
        else
        {
            id = await baglanti.TekDegerAsync<int>("""
                insert into public.sigorta_provizyon
                       (saglayici_id, hesap_id, belge_id, police_id, provizyon_no,
                        kurum_ref_no, durum, tip, alt_tip, hizmet_tipi, vaka_tipi,
                        talep_turu, acil, provizyon_tarihi, hekim_id, hekim_ad,
                        hekim_soyad, hekim_tckn, diploma_no, brans_kodu, brans_adi,
                        hekim_unvan, kadro, sgk_anlasmasi, sikayet, ozgecmis,
                        talep_toplam, onay_toplam, sirket_payi, hasta_payi,
                        karar_tipi, red_nedeni, ham_istek, ham_yanit, sube_id, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11,
                        @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19, @p20, @p21,
                        @p22, @p23, @p24, @p25, @p26, @p27, @p27, @p28, @p29, @p30,
                        @p31::jsonb, @p32::jsonb, @p33, @p34)
                returning id
                """, islem,
                [b.Hesap.SaglayiciId, b.Hesap.HesapId, belge.Id, policeId,
                 sonuc.ProvizyonNo, refNo, sonuc.Durum, ayar.Tip, ayar.AltTip,
                 ayar.HizmetTipi, ayar.VakaTipi, ayar.TalepTuru,
                 (short)(ayar.Acil ? 1 : 0), belge.Tarih, belge.PersonelId,
                 hekim.Ad, hekim.Soyad, hekim.Tckn, hekim.DiplomaNo, hekim.BransKodu,
                 hekim.BransAdi, hekim.Unvan, (short)(hekim.Kadro ? 1 : 0),
                 (short)(hekim.SgkAnlasmasi ? 1 : 0), belge.Sikayet, belge.Ozgecmis,
                 talep, sirket, Math.Max(0, talep - sirket), sonuc.KararTipi,
                 sonuc.RedNedeni, JsonGuvenli(sonuc.HamIstek),
                 JsonGuvenli(sonuc.HamYanit), baglam.SubeId ?? 0,
                 baglam.KullaniciId], iptal);
        }

        await SatirlariYazAsync(baglanti, islem, id, istek, sonuc, iptal);

        foreach (var (t, i) in istek.Tanilar.Select((t, i) => (t, i)))
            await baglanti.CalistirAsync("""
                insert into public.sigorta_provizyon_tani (provizyon_id, kod, ad, sira)
                values (@p0, @p1, @p2, @p3)
                """, islem, [id, t.Kod, t.Ad, (short)(i + 1)], iptal);

        foreach (var n in sonuc.Notlar)
            await baglanti.CalistirAsync("""
                insert into public.sigorta_provizyon_not (provizyon_id, tip, metin)
                values (@p0, @p1, @p2)
                """, islem, [id, n.Tip, n.Metin], iptal);

        await islem.CommitAsync(iptal);

        // Pay dağıtımı ve özet AYRI: belge satırlarına yazmak provizyon
        //   kaydından bağımsız bir iştir, kendi fonksiyonunda durur.
        await _veri.CalistirAsync("select public.fn_sigorta_pay_dagit(@p0)", [id], iptal);
        await _veri.CalistirAsync("select public.fn_sigorta_ozet_tazele(@p0)", [id], iptal);
        return id;
    }

    /// <summary>
    /// Gönderilen satır + gelen kırılım BİRLEŞTİRİLİR (hospitalRowNumber ile).
    /// Şirket bir satırı hiç döndürmezse talep tutarı korunur, kırılım sıfır
    /// kalır - satırın kaybolması "o kalem hiç istenmedi" gibi görünürdü.
    /// </summary>
    private static async Task SatirlariYazAsync(NpgsqlConnection baglanti,
        NpgsqlTransaction islem, int provizyonId, ProvizyonIstegi istek,
        ProvizyonSonucu sonuc, CancellationToken iptal)
    {
        var gelen = sonuc.Satirlar
            .GroupBy(s => s.KurumSiraNo, StringComparer.Ordinal)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.Ordinal);

        foreach (var s in istek.Satirlar)
        {
            gelen.TryGetValue(s.KurumSiraNo, out var y);
            var belgeSatirId = int.TryParse(s.KurumSiraNo, NumberStyles.Integer,
                                            CultureInfo.InvariantCulture, out var bs)
                             ? bs : (int?)null;

            await baglanti.CalistirAsync("""
                insert into public.sigorta_provizyon_satir
                       (provizyon_id, belge_satir_id, satir_turu, kurum_sira_no, kod, ad,
                        kaynak, malzeme_tipi, islem_tarihi, adet, talep_tutar, sgk_tutar,
                        kdv_oran, sirket_tutar, katilim_payi, istisna_tutar,
                        muafiyet_tutar, limit_ustu, faturalanmaz, uyumsuz_tutar,
                        tevkifat, odenecek, kapsam_kodu, kapsam, karar_tipi, aciklama)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8::date, @p9, @p10,
                        @p11, @p12, @p13, @p14, @p15, @p16, @p17, @p18, @p19, @p20,
                        @p21, @p22, @p23, @p24, @p25)
                """, islem,
                [provizyonId, belgeSatirId, s.SatirTuru, s.KurumSiraNo, s.Kod, s.Ad,
                 s.Kaynak, s.MalzemeTipi,
                 s.IslemTarihi?.ToDateTime(TimeOnly.MinValue), s.Adet, s.TalepTutar,
                 s.SgkTutar, s.KdvOran,
                 y?.SirketTutar ?? 0m, y?.KatilimPayi ?? 0m, y?.IstisnaTutar ?? 0m,
                 y?.MuafiyetTutar ?? 0m, y?.LimitUstu ?? 0m, y?.Faturalanmaz ?? 0m,
                 y?.UyumsuzTutar ?? 0m, y?.Tevkifat ?? 0m, y?.Odenecek ?? 0m,
                 y?.KapsamKodu ?? "", y?.Kapsam ?? "", y?.KararTipi ?? "",
                 y?.Aciklama ?? ""], iptal);
        }
    }

    /// <summary>Tazeleme yanıtını mevcut satırlara işler (yeni satır açmaz).</summary>
    private async Task SonucIsleAsync(int provizyonId, ProvizyonSonucu sonuc,
                                      IstekBaglami baglam, CancellationToken iptal)
    {
        foreach (var y in sonuc.Satirlar)
            await _veri.CalistirAsync("""
                update public.sigorta_provizyon_satir
                   set sirket_tutar = @p2, katilim_payi = @p3, istisna_tutar = @p4,
                       muafiyet_tutar = @p5, limit_ustu = @p6, tevkifat = @p7,
                       odenecek = @p8, karar_tipi = @p9, aciklama = @p10
                 where provizyon_id = @p0 and kurum_sira_no = @p1
                """,
                [provizyonId, y.KurumSiraNo, y.SirketTutar, y.KatilimPayi,
                 y.IstisnaTutar, y.MuafiyetTutar, y.LimitUstu, y.Tevkifat,
                 y.Odenecek, y.KararTipi, y.Aciklama], iptal);

        await _veri.CalistirAsync("""
            update public.sigorta_provizyon p
               set durum = @p1, karar_tipi = @p2, red_nedeni = @p3,
                   sirket_payi = k.sirket, onay_toplam = k.sirket,
                   hasta_payi = greatest(0, p.talep_toplam - k.sirket),
                   ham_yanit = @p4::jsonb, degistiren = @p5, degistirme_tarihi = now()
              from (select coalesce(sum(sirket_tutar), 0) as sirket
                      from public.sigorta_provizyon_satir where provizyon_id = @p0) k
             where p.id = @p0
            """, [provizyonId, sonuc.Durum, sonuc.KararTipi, sonuc.RedNedeni,
                  JsonGuvenli(sonuc.HamYanit), baglam.KullaniciId], iptal);

        await _veri.CalistirAsync("select public.fn_sigorta_pay_dagit(@p0)",
                                  [provizyonId], iptal);
        await _veri.CalistirAsync("select public.fn_sigorta_ozet_tazele(@p0)",
                                  [provizyonId], iptal);
    }

    // ================================================================== okuma

    private sealed record BelgeOzeti(int Id, int TarafId, int? KurumId, int? PersonelId,
                                     DateTime Tarih, string Sikayet, string Ozgecmis);

    private async Task<BelgeOzeti> BelgeOkuAsync(int belgeId, CancellationToken iptal)
        => await _veri.TekAsync("""
            select b.id, b.taraf_id, bp.oss_kurum_id, ba.personel_id, b.belge_tarihi,
                   coalesce(m.hikaye, ''), coalesce(m.bulgu_ozet, '')
              from public.belge b
              left join public.belge_basvuru ba on ba.id = b.id
              left join public.belge_provizyon bp on bp.id = b.id
              left join public.muayene m on m.belge_id = b.id
             where b.id = @p0
            """, [belgeId],
            o => new BelgeOzeti(o.GetInt32(0), o.GetInt32(1),
                                o.IsDBNull(2) ? null : o.GetInt32(2),
                                o.IsDBNull(3) ? null : o.GetInt32(3),
                                o.GetDateTime(4), o.GetString(5), o.GetString(6)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Başvuru bulunamadı.");

    private sealed record HastaOzeti(string Ad, string Soyad, DateOnly? DogumTarihi,
                                     short Cinsiyet, string KimlikNo, short KimlikTipi);

    private async Task<HastaOzeti> HastaOkuAsync(int tarafId, CancellationToken iptal)
        => await _veri.TekAsync("""
            select coalesce(t.ad, ''), coalesce(t.soyad, ''), th.dogum_tarihi,
                   coalesce(th.cinsiyet, 0), coalesce(t.vkno, '')
              from public.taraf t
              left join public.taraf_hasta th on th.id = t.id
             where t.id = @p0
            """, [tarafId],
            o => new HastaOzeti(o.GetString(0), o.GetString(1),
                                o.IsDBNull(2) ? null : DateOnly.FromDateTime(o.GetDateTime(2)),
                                o.GetInt16(3), o.GetString(4),
                                // KİMLİK TİPİ: 11 hane rakam TCKN; değilse
                                //   yabancı kimlik sayılır. Hasta kartında ayrı
                                //   bir "kimlik tipi" alanı yok.
                                (short)(o.GetString(4).Length == 11
                                        && o.GetString(4).All(char.IsDigit) ? 1 : 2)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Hasta bulunamadı.");

    private async Task<HekimBilgisi> HekimOkuAsync(int? personelId, CancellationToken iptal)
    {
        if (personelId is not > 0)
            throw GentegreHatasi.IsKurali(
                "Başvuruda hekim seçili değil - provizyon hekimsiz sorulamaz.");

        // BRANŞ KODU METİN: taraf_personel.brans varchar (kod_deger.deger
        //   integer). coalesce(brans, 0) "character varying ve integer
        //   eşleşemez" ile patlıyordu - kod metin olarak taşınır, adı yalnız
        //   sayısal kodlarda çözülür.
        return await _veri.TekAsync("""
            select coalesce(t.ad, ''), coalesce(t.soyad, ''), coalesce(t.vkno, ''),
                   coalesce(tp.tescil_no, ''), coalesce(tp.brans, ''),
                   coalesce((select kd.ad from public.kod_deger kd
                              join public.kod_liste kl on kl.id = kd.liste_id
                             where kl.kod = 'hekim.brans'
                               and tp.brans ~ '^[0-9]+$'
                               and kd.deger = tp.brans::integer
                             limit 1), '')
              from public.taraf t
              left join public.taraf_personel tp on tp.id = t.id
             where t.id = @p0
            """, [personelId.Value],
            o => new HekimBilgisi(o.GetString(0), o.GetString(1), o.GetString(2),
                                  o.GetString(3), o.GetString(4), o.GetString(5),
                                  // Unvan kanonik "uzman": kart alanı yok, en
                                  //   yaygın değer varsayılan; kullanıcı
                                  //   provizyon ekranından değiştirebilir.
                                  1, true, true), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Hekim bulunamadı.");
    }

    private async Task<List<ProvizyonSatiri>> SatirlariOkuAsync(int belgeId,
                                                                CancellationToken iptal)
        => await _veri.ListeAsync("""
            select bs.id, bs.tur, coalesce(st.kod, hz.kod, ''),
                   coalesce(st.ad, hz.ad, bs.aciklama, ''),
                   coalesce(bs.miktar, bs.adet, 1),
                   round(coalesce(bs.tutar, 0), 4), coalesce(bs.kdv, 0),
                   bs.stok_id is not null as sarf
              from public.belge_satir bs
              left join public.stok st on st.id = bs.stok_id
              left join public.hizmet hz on hz.id = bs.hizmet_id
             where bs.belge_id = @p0 and (bs.stok_id is not null or bs.hizmet_id is not null)
             order by bs.sira, bs.id
            """, [belgeId],
            o => new ProvizyonSatiri(
                SatirTuru: o.GetBoolean(7) ? SigortaKanonik.SatirTuru.Sarf
                                           : SigortaKanonik.SatirTuru.Islem,
                KurumSiraNo: o.GetInt32(0).ToString(CultureInfo.InvariantCulture),
                Kod: o.GetString(2), Ad: o.GetString(3),
                // İşlem kaynağı kanonik "Cari": kurumun kendi fiyat listesi.
                //   HUV/TTB/SUT eşlemesi hizmet kartına eklenince buradan gelir.
                Kaynak: o.GetBoolean(7) ? null : (short)3,
                MalzemeTipi: o.GetBoolean(7) ? (short)4 : null,
                IslemTarihi: null,
                Adet: o.GetDecimal(4), TalepTutar: o.GetDecimal(5),
                SgkTutar: 0m, KdvOran: o.GetInt16(6)), iptal);

    private async Task<List<TaniBilgisi>> TanilariOkuAsync(int belgeId,
                                                           CancellationToken iptal)
        => await _veri.ListeAsync("""
            select t.icd_kod, coalesce(i.ad, '')
              from public.tani t
              join public.muayene m on m.id = t.muayene_id
              left join public.icd i on i.kod = t.icd_kod
             where m.belge_id = @p0
             order by t.tur, t.sira, t.id
            """, [belgeId],
            o => new TaniBilgisi(o.GetString(0), o.GetString(1)), iptal);

    private sealed record PoliceOzeti(int Id, string PoliceNo, string PoliceAdi,
                                      short PoliceTipi, short PoliceTuru,
                                      string KartNo, string MusteriNo);

    private async Task<PoliceOzeti?> PoliceOkuAsync(short saglayiciId, int tarafId,
                                                    int kurumId, CancellationToken iptal)
        => await _veri.TekAsync("""
            select id, police_no, police_adi, police_tipi, police_turu,
                   kart_no, musteri_no
              from public.sigorta_police
             where saglayici_id = @p0 and taraf_id = @p1 and kurum_id = @p2
             order by gecerli desc, sorgu_zamani desc limit 1
            """, [saglayiciId, tarafId, kurumId],
            o => new PoliceOzeti(o.GetInt32(0), o.GetString(1), o.GetString(2),
                                 o.GetInt16(3), o.GetInt16(4), o.GetString(5),
                                 o.GetString(6)), iptal);

    private sealed record ProvizyonBasligi(int Id, int KurumId, string ProvizyonNo,
                                           string KurumRefNo, short Durum, int BelgeId);

    private async Task<ProvizyonBasligi> ProvizyonBasligiAsync(int id,
                                                               CancellationToken iptal)
        => await _veri.TekAsync("""
            select p.id, h.kurum_id, p.provizyon_no, p.kurum_ref_no, p.durum, p.belge_id
              from public.sigorta_provizyon p
              join public.sigorta_hesap h on h.id = p.hesap_id
             where p.id = @p0
            """, [id],
            o => new ProvizyonBasligi(o.GetInt32(0), o.GetInt32(1), o.GetString(2),
                                      o.GetString(3), o.GetInt16(4), o.GetInt32(5)), iptal)
           ?? throw GentegreHatasi.Bulunamadi("Provizyon bulunamadı.");

    // ================================================================== günlük

    /// <summary>
    /// Dış çağrı günlüğü. HATASI YUTULUR: log yazılamadı diye alınmış bir
    /// provizyon kaybolmamalı - günlük kanıttır, iş akışının koşulu değil.
    /// </summary>
    /// <remarks>
    /// <paramref name="httpDurum"/> 0 = BİLİNMİYOR. Adapter kanonik sonuç
    /// döndürüyor, HTTP durumunu taşımıyor; sabit 200 yazmak günlüğü yalancı
    /// yapardı - iş kuralı hatası HTTP 500 ile gelebiliyor (ASMED
    /// "faultstring" kabuğu).
    /// </remarks>
    private async Task LogYazAsync(SigortaHesabi hesap, string uc, string kayitTuru,
        int? kayitId, int httpDurum, int sureMs, bool basarili, string hata,
        string? istek, string? yanit, IstekBaglami baglam, CancellationToken iptal)
    {
        try
        {
            await _veri.CalistirAsync("""
                insert into public.sigorta_istek_log
                       (saglayici_id, hesap_id, uc, kayit_turu, kayit_id, http_durum,
                        sure_ms, basarili, hata, istek, yanit, kullanici_id, sube_id)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8,
                        @p9::jsonb, @p10::jsonb, @p11, @p12)
                """,
                [hesap.SaglayiciId, hesap.HesapId, uc, kayitTuru, kayitId,
                 (short)httpDurum, sureMs, (short)(basarili ? 1 : 0), Kirp(hata, 400),
                 JsonGuvenli(istek), JsonGuvenli(yanit), baglam.KullaniciId,
                 baglam.SubeId ?? 0], iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "Sigorta istek günlüğü yazılamadı ({Uc}).", uc);
        }
    }

    /// <summary>
    /// Ham metni jsonb'ye uygun hâle getirir. Servis her zaman JSON dönmüyor
    /// (HTML hata sayfası, düz metin); geçersiz metin kolonu patlatmasın diye
    /// sarmalanır - ham veri KAYBEDİLMEZ, "ham" alanında saklanır.
    /// </summary>
    private static string? JsonGuvenli(string? metin)
    {
        if (string.IsNullOrWhiteSpace(metin)) return null;
        try { using var _ = JsonDocument.Parse(metin); return metin; }
        catch { return JsonSerializer.Serialize(new { ham = Kirp(metin, 20000) }); }
    }

    private static string Kirp(string? m, int n)
        => string.IsNullOrEmpty(m) ? "" : m.Length <= n ? m : m[..n] + "…";
}
