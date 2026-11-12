using System.Text.Json;
using Gentegre.Cekirdek.Cihaz;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>Bir gönderim denemesinin sonucu (uç ve işçi aynı tipi görür).</summary>
public sealed record TeletipDenemeSonucu(long GonderimId, short Durum, string AckKodu, string Hata);

/// <summary>
/// TELETIP ORM GÖNDERİMİ (1302; kullanıcı 11.11.2026: "ORM'yi kuyruğa ve akışa bağla").
///
/// <para><b>Akış:</b> radyoloji_istem tetiği <c>teletip_gonderim</c>'e NW / XO / CA satırı açar → bu servis satırı alır,
/// veriyi <c>fn_teletip_orm_verisi</c>'nden (CA'da satırdaki anlık görüntüden) okur, <see cref="OrmUretici.Denetle"/> ile
/// Bakanlık'ın reddedeceği eksikleri arar, <see cref="OrmUretici.Uret"/> ile mesajı kurar ve <see cref="MllpIstemci"/> ile
/// Mirth K1'e (TELETIP_HL7) gönderir. Mirth Teletıp'ın ACK'ini aynen geri döndürür.</para>
///
/// <para><b>Durumlar:</b> 0 bekliyor · 1 gönderildi (AA) · 2 reddedildi (AE - otomatik tekrar YOK, aynı mesaj yine
/// reddedilir) · 3 gidemez (eksik; istem değişince tetik yeniden kuyruğa alır) · 4 atlandı · 5 ulaşmadı (AR / ACK yok,
/// artan aralıkla tekrar).</para>
///
/// <para><b>Sıra:</b> aynı istemin önceki satırı sonuçlanmadan (gönderilmeden) sonraki gitmez - XO / CA, NW'den önce
/// Bakanlık'a varırsa "istem yok" diye reddedilir.</para>
/// </summary>
public sealed class TeletipOrmServisi(VeriKaynagi veri, MllpIstemci mllp, ILogger<TeletipOrmServisi> gunluk,
                                      DicomKaynagi? dicom = null, IHttpClientFactory? httpFabrika = null)
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };
    private const int AzamiDeneme = 20;

    /// <summary>Zamanı gelmiş satırları sırayla dener; gönderilen sayısı.</summary>
    public async Task<int> SiradakileriIsleAsync(int azami, CancellationToken iptal)
    {
        if (!await AktifMiAsync(iptal)) return 0;
        var idler = await veri.ListeAsync("""
            select g.id from public.teletip_gonderim g
             where g.durum in (0, 5) and g.sonraki_deneme <= now()
               and not exists (select 1 from public.teletip_gonderim o
                                where o.istem_id = g.istem_id and o.kanal = g.kanal and o.id < g.id
                                  and o.durum in (0, 2, 3, 5))
               -- KOS (kanal 2) istemin NW'si Bakanlık'ta kabul edilmeden gitmez (kılavuz 3.43 § 5.4 örnek 2).
               and (g.kanal <> 2 or exists (select 1 from public.teletip_gonderim n
                                             where n.istem_id = g.istem_id and n.kanal = 1 and n.emir = 1 and n.durum = 1))
             order by g.id
             limit @p0
            """, [azami], o => o.GetInt64(0), iptal);
        var sayac = 0;
        foreach (var id in idler)
        {
            if (iptal.IsCancellationRequested) break;
            try { if ((await DeneAsync(id, iptal)).Durum == 1) sayac++; }
            catch (Exception h) { gunluk.LogError(h, "Teletıp gönderimi {Id} denenirken hata.", id); }
        }
        return sayac;
    }

    public async Task<bool> AktifMiAsync(CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await b.TekDegerAsync<bool>("select public.fn_teletip_aktif()", null, [], iptal);   // 1317: herhangi bir şubede
    }

    /// <summary>Tek satırı dener (işçi ve "Yeniden Gönder" ucu). Satır kilitlenir; aynı anda iki deneme olmaz.</summary>
    public async Task<TeletipDenemeSonucu> DeneAsync(long id, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        await using var islem = await b.BeginTransactionAsync(iptal);
        var satir = await b.TekAsync("""
            select id, istem_id, kanal, emir, durum, deneme_no, veri::text as veri, accession_no, rapor_id, sube_id
              from public.teletip_gonderim where id = @p0 for update skip locked
            """, islem, [id], o => new
        {
            IstemId = o.SayiNull("istem_id"),
            RaporId = o.SayiNull("rapor_id"),
            Kanal = Convert.ToInt32(o.GetValue(o.GetOrdinal("kanal"))),
            EmirKodu = Convert.ToInt32(o.GetValue(o.GetOrdinal("emir"))),
            Durum = Convert.ToInt16(o.GetValue(o.GetOrdinal("durum"))),
            Deneme = o.Sayi("deneme_no"),
            Veri = o.Metin("veri"),
            Sube = o.Sayi("sube_id"),
        }, iptal);
        if (satir is null) return new(id, -1, "", "Satır bulunamadı ya da başka bir deneme sürüyor.");
        if (satir.Durum is 1 or 4) return new(id, satir.Durum, "", "Satır zaten sonuçlanmış.");
        using var pacsKapsami = DicomAyarDeposu.SubeIcin(satir.Sube);   // 1316: KOS / doz şubenin PACS'ından
        // 1315: dış kurumun teleradyoloji işi Teletıp'tan gitmez (Bakanlık bildirimi Teleradyoloji › Teslim Kuyruğu'ndan).
        // Satır açıldıktan sonra bağ kurulmuş olabilir - göndermeden hemen önce yeniden bakılır.
        if (satir.IstemId is int disIstem
            && await b.TekDegerAsync<bool>("select public.fn_teletip_dis_is(@p0)", islem, [disIstem], iptal))
            return await YazAsync(b, islem, id, 4, satir.Deneme, "",
                "Dış kurumun teleradyoloji işi - Bakanlık bildirimi Teleradyoloji › Teslim Kuyruğu'ndan (1315).", "", "", iptal);

        // 1317 / 1324: ŞUBENİN TeleRadyoloji hesabı (şube satırı → kurum geneli; eski teletip.* yolu 1324'te kalktı) ve
        //   şubenin Bakanlık kimliği (kurum profili - tek kaynak). Hesap kapalıysa satır bekler (hesap açılınca gider).
        var hesap = await TeleRadyolojiHesabi.OkuAsync(b, islem, satir.Sube, iptal);
        if (hesap is null)
            return await YazAsync(b, islem, id, 5, satir.Deneme, "",
                "Bu şubede aktif TeleRadyoloji hesabı yok (Ayarlar › Entegrasyon › TeleRadyoloji).", "", "", iptal,
                sonraki: TimeSpan.FromMinutes(30));
        var kimlik = await KurumKimlik.OkuAsync(b, islem, satir.Sube, iptal);
        var adres = hesap.Hl7Adres;

        // VERİ: CA anlık görüntüden (istem iptal / silinmiş olabilir), NW / XO güncel istemden.
        var json = satir.Veri.Length > 0 ? satir.Veri
                 : satir.IstemId is int iid
                     ? await b.TekDegerAsync<string>("select public.fn_teletip_orm_verisi(@p0)::text", islem, [iid], iptal) ?? ""
                     : "";
        if (json.Length == 0)
            return await YazAsync(b, islem, id, 4, satir.Deneme, "", "İstem yok (silinmiş) ve anlık görüntü yok.", "", "", iptal);

        var oruMu = satir.EmirKodu == 4;
        // Kurum kimliği şubeden (CA anlık görüntüsündeki eski kimlik de güncellenir); MEDULA tesis yoksa istemin
        //   provizyonundaki tesis kodu (ORM verisinin yedeği) kalır.
        var v = kimlik.Uygula(JsonSerializer.Deserialize<OrmVerisi>(json, JsonAyar) ?? new OrmVerisi(), hesap) with
        {
            // ORU satırında ORM denetimi "yeni istem" kurallarıyla yapılır (hasta / istem / kurum alanları aynı).
            Emir = oruMu ? OrmEmri.Yeni : (OrmEmri)satir.EmirKodu,
            KontrolNo = $"TT{id}-{satir.Deneme + 1}",
        };

        if (satir.Kanal == 3)
            return await DozGonderAsync(b, islem, id, satir.Deneme, satir.IstemId, v, hesap.DozAdres, iptal);
        if (satir.Kanal == 2)
            return await KosGonderAsync(b, islem, id, satir.Deneme, satir.IstemId, v, hesap.XdsAdres,
                                        hesap.XdsHastaOid.Length > 0 ? hesap.XdsHastaOid : XdsZarfi.VarsayilanHastaOid, iptal);

        string mesaj;
        if (oruMu)
        {
            // RAPOR (1309): rapor kısmı fn_teletip_oru_verisi; istem / hasta / kurum kısmı yukarıdaki ORM verisi.
            var raporJson = satir.RaporId is int rid
                ? await b.TekDegerAsync<string>("select public.fn_teletip_oru_verisi(@p0)::text", islem, [rid], iptal) ?? "" : "";
            if (raporJson.Length == 0)
                return await YazAsync(b, islem, id, 4, satir.Deneme, "", "Rapor yok (silinmiş).", "", "", iptal);
            var rapor = JsonSerializer.Deserialize<TeletipRaporVerisi>(raporJson, JsonAyar) ?? new TeletipRaporVerisi();
            var eksikOru = TeletipOruKurucu.Denetle(v, rapor);
            if (eksikOru.Count > 0)
                return await YazAsync(b, islem, id, 3, satir.Deneme, "", string.Join(" · ", eksikOru), "", "", iptal);
            mesaj = OruUretici.Uret(TeletipOruKurucu.Kur(v, rapor));
        }
        else
        {
            var eksik = OrmUretici.Denetle(v);
            if (eksik.Count > 0)
                return await YazAsync(b, islem, id, 3, satir.Deneme, "", string.Join(" · ", eksik), "", "", iptal);
            mesaj = OrmUretici.Uret(v);
        }
        if (adres.Length == 0)
            return await YazAsync(b, islem, id, 5, satir.Deneme, "", "TeleRadyoloji hesabında K1 HL7 adresi yok (Ayarlar › Entegrasyon › TeleRadyoloji).", "", "", iptal,
                                  sonraki: TimeSpan.FromMinutes(30));

        var s = await mllp.GonderAsync(adres, mesaj, v.Encoding, false, 40, iptal);
        short durum = s.AckKodu is "AA" or "CA" ? (short)1
                    : s.KaliciHata ? (short)2
                    : satir.Deneme + 1 >= AzamiDeneme ? (short)2
                    : (short)5;
        var hata = durum == 1 ? "" : s.Hata.Length > 0 ? s.Hata : $"ACK {s.AckKodu}";
        return await YazAsync(b, islem, id, durum, satir.Deneme, s.AckKodu, hata, mesaj, s.YanitGovdesi, iptal,
                              kontrolNo: v.KontrolNo, sonraki: Geri(satir.Deneme + 1));
    }

    /// <summary>
    /// KOS (K2, 1310): PACS'tan çalışma yapısı + küçük resimler → KOS (Tablo 2) → RAD-68 MTOM zarfı → Mirth K2 → yanıt
    /// (Tablo 3). Success + eşleşme → 1; PartialSuccess (kayıt var, istem eşleşmedi) / Failure → 2 (insan bakmalı);
    /// HTTP hatası / yanıt yok → 5 (tekrar). Saklanan mesaj SOAP gövdesidir (DICOM eki değil).
    /// </summary>
    private async Task<TeletipDenemeSonucu> KosGonderAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction islem, long id, int deneme,
        int? istemId, OrmVerisi v, string xdsAdres, string hastaOid, CancellationToken iptal)
    {
        if (dicom is null || httpFabrika is null)
            return await YazAsync(b, islem, id, 5, deneme, "", "DICOM / HTTP bileşeni yok (servis yapılandırması).", "", "", iptal);
        var kosJson = istemId is int iid
            ? await b.TekDegerAsync<string>("select public.fn_teletip_kos_verisi(@p0)::text", islem, [iid], iptal) ?? "" : "";
        using var kj = System.Text.Json.JsonDocument.Parse(kosJson.Length > 0 ? kosJson : "{}");
        string K(string ad) => kj.RootElement.TryGetProperty(ad, out var e) ? e.ToString() : "";
        var studyUid = K("StudyUid");
        if (studyUid.Length == 0)
            return await YazAsync(b, islem, id, 3, deneme, "", "İstemin PACS çalışması (study_uid) bağlı değil.", "", "", iptal);
        // 1313: satır gönderdiği çalışmayı taşır - dışa açık WADO yalnız başarıyla gitmiş KOS'un çalışmasını verir.
        await b.CalistirAsync("update public.teletip_gonderim set study_uid = @p1 where id = @p0", islem, [id, studyUid], iptal);

        KosCalisma? calisma;
        try { calisma = await dicom.KosCalismaAsync(studyUid, iptal); }
        catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
        {
            return await YazAsync(b, islem, id, 5, deneme, "", "PACS sorgusu başarısız: " + h.Message, "", "", iptal, sonraki: Geri(deneme + 1));
        }
        var kurum = new KosKurum(v.KurumAdi, v.KurumSkrs, v.FirmaKodu, dicom.PacsAe, K("CihazSeriNo"));
        var eksik = KosUretici.Denetle(v, calisma, kurum);
        eksik.AddRange(OrmUretici.Denetle(v with { Emir = OrmEmri.Iptal }));   // kurum kimliği (SKRS, MSH-3, MEDULA)
        if (eksik.Count > 0)
            return await YazAsync(b, islem, id, 3, deneme, "", string.Join(" · ", eksik.Distinct()), "", "", iptal);
        if (xdsAdres.Length == 0)
            return await YazAsync(b, islem, id, 5, deneme, "", "TeleRadyoloji hesabında K2 KOS adresi yok (Ayarlar › Entegrasyon › TeleRadyoloji).", "", "", iptal,
                                  sonraki: TimeSpan.FromMinutes(30));

        var simdi = DateTime.UtcNow;
        var kosSop = FellowOakDicom.DicomUID.Generate().UID;
        var kos = KosUretici.Baytlar(KosUretici.Uret(v, calisma!, kurum, v.Zaman, kosSop));
        var zarf = XdsZarfi.Kur(kos, kosSop, v, xdsAdres, simdi, hastaOid);
        // Görüntüsüz seriler (doz SR, KO, PR) küçük resim taşımaz - eksik sayılmaz.
        var ikonsuz = calisma!.Seriler.Count(x => x.Ikon is null && x.Modalite is not ("SR" or "KO" or "PR"));
        try
        {
            var (httpKod, govde) = await MirthPostAsync(xdsAdres, zarf.Govde, zarf.IcerikTuru, iptal);
            var sonuc = XdsYaniti.Coz(govde);
            short durum = sonuc.Durum == "" ? (short)5
                        : sonuc.Basarili && (sonuc.Eslesti || sonuc.HataKodu != "MatchStatus") ? (short)1
                        : (short)2;
            var hata = durum == 1 ? (ikonsuz > 0 ? $"{ikonsuz} seride küçük resim üretilemedi (sıkıştırılmış görüntü)." : "")
                     : sonuc.Durum == "" ? $"HTTP {httpKod}: {sonuc.Aciklama}"
                     : $"{sonuc.Durum}{(sonuc.HataKodu.Length > 0 ? " / " + sonuc.HataKodu : "")}: {sonuc.Aciklama}";
            var ack = sonuc.Durum switch { "Success" => "OK", "PartialSuccess" => "PARTIAL", "Failure" => "FAIL", _ => "" };
            if (durum == 5 && deneme + 1 >= AzamiDeneme) durum = 2;
            return await YazAsync(b, islem, id, durum, deneme, ack, hata, zarf.SoapXml, Kirp(govde), iptal,
                                  kontrolNo: kosSop, sonraki: Geri(deneme + 1));
        }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException)
        {
            return await YazAsync(b, islem, id, deneme + 1 >= AzamiDeneme ? (short)2 : (short)5, deneme, "",
                                  "Mirth K2'ye ulaşılamadı: " + h.Message, zarf.SoapXml, "", iptal, kontrolNo: kosSop, sonraki: Geri(deneme + 1));
        }
    }

    /// <summary>Mirth HTTP kanalına (K2 / K3) gövde gönderir; yanıt kodu + gövde.</summary>
    private async Task<(int Kod, string Govde)> MirthPostAsync(string adres, byte[] govde, string icerikTuru, CancellationToken iptal)
    {
        var istemci = httpFabrika!.CreateClient("teletip-xds");
        using var icerik = new ByteArrayContent(govde);
        icerik.Headers.TryAddWithoutValidation("Content-Type", icerikTuru);
        using var istek = new HttpRequestMessage(HttpMethod.Post, adres) { Content = icerik };
        // Mirth HTTP dinleyicisi Content-Type'ı başlık haritasına koymuyor; kanal bu kopyadan okuyup hedefe yazar.
        istek.Headers.TryAddWithoutValidation("X-Gentegre-Content-Type", icerikTuru);
        using var y = await istemci.SendAsync(istek, iptal);
        return ((int)y.StatusCode, await y.Content.ReadAsStringAsync(iptal));
    }

    private static string Kirp(string s) => s.Length > 4000 ? s[..4000] : s;

    /// <summary>
    /// DOZ (1314, Mirth K3): çalışmanın RDSR'leri PACS'tan → künye KOS'la aynı (DozUretici.Kunye) → denetim → her RDSR
    /// Mirth K3'e HTTP (gövde DICOM Part 10) → Mirth DICOM Sender → TELETIP_MGA; yanıt C-STORE-RSP durumu. Cihaz RDSR'yi
    /// geç yollayabilir: PACS'ta yoksa birkaç kez tekrar, sonra "gidemez" (cihaz RDSR üretmiyor olabilir).
    /// </summary>
    private async Task<TeletipDenemeSonucu> DozGonderAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction islem, long id, int deneme,
        int? istemId, OrmVerisi v, string dozAdres, CancellationToken iptal)
    {
        if (dicom is null || httpFabrika is null)
            return await YazAsync(b, islem, id, 5, deneme, "", "DICOM / HTTP bileşeni yok (servis yapılandırması).", "", "", iptal);
        if (istemId is not int iid)
            return await YazAsync(b, islem, id, 4, deneme, "", "İstem yok (silinmiş).", "", "", iptal);
        // Tek sorgu: KOS / doz verisi, satırın çalışması ve 1323 ilerlemesi (kabul edilmiş RDSR'ler).
        var s = await b.TekAsync("""
            select coalesce(public.fn_teletip_kos_verisi(@p1)::text, '{}'), coalesce(public.fn_teletip_doz_verisi(@p1)::text, '{}'),
                   coalesce(t.study_uid, ''), coalesce(t.ilerleme -> 'gonderilenSop', '[]'::jsonb)::text
              from public.teletip_gonderim t where t.id = @p0
            """, islem, [id, iid], o => new[] { o.GetString(0), o.GetString(1), o.GetString(2), o.GetString(3) }, iptal)
            ?? ["{}", "{}", "", "[]"];
        using var kj = JsonDocument.Parse(s[0]); using var dj = JsonDocument.Parse(s[1]);
        string K(string ad) => kj.RootElement.TryGetProperty(ad, out var e) ? e.ToString() : "";
        double? D(string ad) => dj.RootElement.TryGetProperty(ad, out var e) && e.ValueKind == JsonValueKind.Number ? e.GetDouble() : null;
        var studyUid = s[2].Length > 0 ? s[2] : K("StudyUid");
        if (studyUid.Length == 0)
            return await YazAsync(b, islem, id, 3, deneme, "", "İstemin PACS çalışması (study_uid) bağlı değil.", "", "", iptal);

        List<(string Seri, string Sop)> raporlar;
        try { raporlar = await dicom.DozRaporlariAsync(studyUid, iptal); }
        catch (Exception h) when (h is not OperationCanceledException || !iptal.IsCancellationRequested)
        {
            return await YazAsync(b, islem, id, 5, deneme, "", "PACS sorgusu başarısız: " + h.Message, "", "", iptal, sonraki: Geri(deneme + 1));
        }
        if (raporlar.Count == 0)
        {
            // Cihaz RDSR'yi çekimden sonra yollar; birkaç saat beklenir (1, 2, 5, 10, 30 dk, sonra saatlik), sonra gidemez.
            var son = deneme + 1 >= 8;
            return await YazAsync(b, islem, id, son ? (short)3 : (short)5, deneme, "",
                "PACS'ta bu çalışmanın doz raporu (RDSR, X-Ray Radiation Dose SR) yok" + (son ? " - cihaz RDSR üretmiyor ya da PACS'a yollamıyor olabilir." : " - bekleniyor."),
                "", "", iptal, sonraki: Geri(deneme + 1));
        }

        var kurum = new KosKurum(v.KurumAdi, v.KurumSkrs, v.FirmaKodu, dicom.PacsAe, K("CihazSeriNo"));
        var eksikKurum = OrmUretici.Denetle(v with { Emir = OrmEmri.Iptal });
        eksikKurum.AddRange(KosUretici.KurumDenetle(kurum));
        if (eksikKurum.Count > 0)
            return await YazAsync(b, islem, id, 3, deneme, "", string.Join(" · ", eksikKurum.Distinct()), "", "", iptal);
        if (dozAdres.Length == 0)
            return await YazAsync(b, islem, id, 5, deneme, "", "TeleRadyoloji hesabında K3 doz adresi yok (Ayarlar › Entegrasyon › TeleRadyoloji).", "", "", iptal,
                                  sonraki: TimeSpan.FromMinutes(30));

        var mesajlar = new List<string>(); var uyarilar = new List<string>(); var sonSop = raporlar[^1].Sop;
        // 1323: Bakanlık'ın KABUL ETTİĞİ RDSR'ler satırın ilerlemesinde - sonraki biri düşüp satır yeniden denenince
        //   kabul edilmişler tekrar gönderilmez (mükerrer doz kaydı olmasın).
        var gonderilenler = JsonSerializer.Deserialize<List<string>>(s[3]) ?? [];
        var onceden = gonderilenler.Count(g => raporlar.Any(r => r.Sop == g));
        foreach (var (seri, sop) in raporlar)
        {
            if (gonderilenler.Contains(sop)) { mesajlar.Add($"{sop}: daha önce kabul edildi (tekrar gönderilmedi)."); continue; }
            FellowOakDicom.DicomDataset hazir;
            try
            {
                using var y = await dicom.WadoAsync(studyUid, seri, sop, iptal);
                if (!y.IsSuccessStatusCode)
                    return await YazAsync(b, islem, id, 5, deneme, "", $"RDSR PACS'tan alınamadı (WADO HTTP {(int)y.StatusCode}).", "", "", iptal, sonraki: Geri(deneme + 1));
                var dosya = await FellowOakDicom.DicomFile.OpenAsync(new MemoryStream(await y.Content.ReadAsByteArrayAsync(iptal)));
                hazir = DozUretici.Kunye(dosya.Dataset, v, kurum, studyUid, D("BoyCm"), D("KiloKg"));
            }
            catch (Exception h) when (h is HttpRequestException or FellowOakDicom.DicomFileException || (h is TaskCanceledException && !iptal.IsCancellationRequested))
            {
                return await YazAsync(b, islem, id, 5, deneme, "", "RDSR PACS'tan alınamadı: " + h.Message, "", "", iptal, sonraki: Geri(deneme + 1));
            }
            var ozet = DozUretici.Ozet(hazir);
            var (hatalar, uyari) = DozUretici.Denetle(hazir, ozet);
            var metin = DozUretici.MesajMetni(hazir, ozet);
            if (hatalar.Count > 0)
                return await YazAsync(b, islem, id, 3, deneme, "", string.Join(" · ", hatalar), metin, "", iptal, kontrolNo: sop);
            uyarilar.AddRange(uyari);
            mesajlar.Add(metin);
            sonSop = sop;

            var baytlar = KosUretici.Baytlar(new FellowOakDicom.DicomFile(hazir));
            string govde; int httpKod;
            try { (httpKod, govde) = await MirthPostAsync(dozAdres, baytlar, "application/dicom", iptal); }
            catch (Exception h) when (h is HttpRequestException or TaskCanceledException)
            {
                return await YazAsync(b, islem, id, deneme + 1 >= AzamiDeneme ? (short)2 : (short)5, deneme, "",
                                      "Mirth K3'e ulaşılamadı: " + h.Message, string.Join("\n\n", mesajlar), "", iptal, kontrolNo: sop, sonraki: Geri(deneme + 1));
            }
            var sonuc = DozYaniti.Coz(govde);
            if (sonuc.Durum != 1)
            {
                var durum = sonuc.Durum == 5 && deneme + 1 >= AzamiDeneme ? (short)2 : sonuc.Durum;
                return await YazAsync(b, islem, id, durum, deneme, sonuc.Ack,
                                      (sonuc.Durum == 5 ? $"HTTP {httpKod}: " : "") + sonuc.Aciklama, string.Join("\n\n", mesajlar),
                                      Kirp(govde), iptal, kontrolNo: sop, sonraki: Geri(deneme + 1));
            }
            if (sonuc.Ack != "0000" && sonuc.Aciklama.Length > 0) uyarilar.Add($"MGA uyarısı 0x{sonuc.Ack}: {sonuc.Aciklama}");
            await b.CalistirAsync(
                "update public.teletip_gonderim set ilerleme = jsonb_set(coalesce(ilerleme, '{}'::jsonb), '{gonderilenSop}', coalesce(ilerleme -> 'gonderilenSop', '[]'::jsonb) || to_jsonb(@p1::text)) where id = @p0",
                islem, [id, sop], iptal);
            gonderilenler.Add(sop);
        }
        return await YazAsync(b, islem, id, 1, deneme, "0000",
                              (raporlar.Count > 1 ? $"{raporlar.Count - onceden} doz raporu gönderildi" + (onceden > 0 ? $", {onceden} önceden kabul edilmişti. " : ". ") : "")
                              + string.Join(" · ", uyarilar.Distinct()),
                              string.Join("\n\n", mesajlar), "", iptal, kontrolNo: sonSop);
    }

    /// <summary>Artan aralık: 1, 2, 5, 10, 30 dk, sonra saatlik.</summary>
    public static TimeSpan Geri(int deneme) => deneme switch
    {
        <= 1 => TimeSpan.FromMinutes(1),
        2 => TimeSpan.FromMinutes(2),
        3 => TimeSpan.FromMinutes(5),
        4 => TimeSpan.FromMinutes(10),
        5 => TimeSpan.FromMinutes(30),
        _ => TimeSpan.FromHours(1),
    };

    private static async Task<TeletipDenemeSonucu> YazAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction islem, long id,
        short durum, int deneme, string ack, string hata, string mesaj, string yanit, CancellationToken iptal,
        string kontrolNo = "", TimeSpan? sonraki = null)
    {
        // "gidemez" denemeyi saymaz: mesaj hiç gitmedi, eksik tamamlanınca tetik satırı yeniden 0 yapar.
        var sayilir = durum is 1 or 2 or 5;
        await b.CalistirAsync("""
            update public.teletip_gonderim
               set durum = @p1, deneme_no = deneme_no + @p2, ack_kodu = @p3, hata_metni = left(@p4, 2000),
                   mesaj = case when @p5 = '' then mesaj else @p5 end,
                   yanit = case when @p5 = '' then yanit else @p6 end,
                   kontrol_no = case when @p7 = '' then kontrol_no else @p7 end,
                   son_deneme = now(),
                   sonraki_deneme = now() + make_interval(secs => @p8)
             where id = @p0
            """, islem, [id, durum, sayilir ? 1 : 0, ack, hata, mesaj, yanit, kontrolNo,
                         (sonraki ?? TimeSpan.FromMinutes(1)).TotalSeconds], iptal);
        await islem.CommitAsync(iptal);
        _ = deneme;
        return new(id, durum, ack, hata);
    }
}

/// <summary>fn_teletip_oru_verisi (1309) - raporun Bakanlık kısmı.</summary>
public sealed record TeletipRaporVerisi
{
    public int RaporId { get; init; }
    public string Teknik { get; init; } = "";
    public string Karsilastirma { get; init; } = "";
    public string Bulgular { get; init; } = "";
    public string Sonuc { get; init; } = "";
    public DateTime? OnayZamani { get; init; }
    public DateTime? CekimZamani { get; init; }
    public short IstemNedeniPuan { get; init; }
    public short CekimKalitePuan { get; init; }
    public string RadyologTckn { get; init; } = "";
    public string RadyologSoyad { get; init; } = "";
    public string RadyologAd { get; init; } = "";
    public string KontrastObx17 { get; init; } = "";
    public bool Duzeltme { get; init; }
    /// <summary>fn_rad_bakanlik_eksik: Bulgular ≥ 50 karakter, Sonuç dolu - boş = uygun.</summary>
    public string RaporEksik { get; init; } = "";
}

/// <summary>
/// KENDİ RAPORUMUZUN ORU'SU (1309): istem / hasta / kurum alanları ORM verisinden (tek kaynak), rapor alanları
/// <see cref="TeletipRaporVerisi"/>'nden; üretim <see cref="OruUretici"/> Bakanlık profili (kılavuz 3.43 Tablo 20-22).
/// OBR-15 kendi hastanemizde "Radiology" (rapor ve istem aynı kurum - telerad'daki A/B ayrımı yok).
/// </summary>
public static class TeletipOruKurucu
{
    public static OruVerisi Kur(OrmVerisi v, TeletipRaporVerisi r) => new()
    {
        Profil = Hl7Profili.Bakanlik,
        GonderenUygulama = v.FirmaKodu, GonderenTesis = v.HbysAdi,
        AliciUygulama = v.AliciUygulama, AliciTesis = v.AliciTesis,
        Zaman = v.Zaman, KontrolNo = v.KontrolNo, Encoding = v.Encoding,
        HastaDosyaNo = v.HastaDosyaNo, HastaTckn = v.HastaTckn, HastaSoyad = v.HastaSoyad, HastaAd = v.HastaAd,
        DogumTarihi = v.DogumTarihi, Cinsiyet = v.Cinsiyet,
        BasvuruNo = v.BasvuruReferansi, HastaneReferans = v.HastaneReferansi,
        KurumSkrs = v.KurumSkrs, KurumAdi = v.KurumAdi, KurumKisaAdi = v.KurumKisaAdi, SubeNo = v.SubeNo,
        MedulaTesisKodu = v.MedulaTesisKodu,
        HastaSinifi = v.HastaSinifi, BirimId = v.BirimId, Bolum = v.BirimAdi, Sgk = v.Sgk, MedulaTakipNo = v.MedulaTakipNo,
        AccessionNo = v.AccessionNo,
        IsteyenHekimTckn = v.IsteyenHekim.Kimlik, IsteyenHekimSoyad = v.IsteyenHekim.Soyad, IsteyenHekimAd = v.IsteyenHekim.Ad,
        SutKodu = v.SutKodu, SutAdi = v.SutAdi,
        Loinc = v.Loinc.FirstOrDefault()?.Kod ?? "", LoincAdi = v.Loinc.FirstOrDefault()?.Ad ?? "",
        IstemZamani = v.IstemZamani, OnayZamani = r.OnayZamani, CekimZamani = r.CekimZamani,
        PlanlananZaman = v.PlanlananZaman,
        KlinikBilgi = v.KlinikBilgi, HizmetVerenSkrs = v.GonderilenSkrs,
        SysTakipNo = v.SysTakipNo, ModaliteKodu = v.Modalite, CihazGirisi = v.CihazGirisi,
        TeknisyenId = v.Teknisyen.Kimlik, TeknisyenSoyad = v.Teknisyen.Soyad, TeknisyenAd = v.Teknisyen.Ad,
        RaporTeknik = r.Teknik, RaporKarsilastirma = r.Karsilastirma, RaporBulgular = r.Bulgular, RaporSonuc = r.Sonuc,
        IstemNedeniPuan = r.IstemNedeniPuan, CekimKalitePuan = r.CekimKalitePuan,
        RadyologTckn = r.RadyologTckn, RadyologSoyad = r.RadyologSoyad, RadyologAd = r.RadyologAd,
        KontrastObx17 = r.KontrastObx17, Duzeltme = r.Duzeltme,
        TaniIcd = [.. v.Tanilar.Select(t => t.Icd).Where(x => !string.IsNullOrWhiteSpace(x))],
        Tanilar = v.Tanilar, Sikayet = v.Sikayet, Gecmis = v.Gecmis, Bulgu = v.Bulgu, Tedavi = v.Tedavi,
        YonlendirenHekim = v.YonlendirenHekim, Giren = v.Giren, KabulZamani = v.KabulZamani,
        BakanlikPid = OrmUretici.PidAlanlari(v),
    };

    /// <summary>ORM'in ortak denetimi (hasta, istem, kurum) + rapora özgü: kılavuz OBX-5 (Bulgular ≥ 50, Sonuç), OBX-16
    /// radyolog TCKN (ÇKYS'den doğrulanır), OBX-13 puanları, OBR-7 onay zamanı.</summary>
    public static List<string> Denetle(OrmVerisi v, TeletipRaporVerisi r)
    {
        var e = OrmUretici.Denetle(v with { Emir = OrmEmri.Yeni });
        if (r.RaporEksik.Length > 0) e.Add(r.RaporEksik);
        if (!OrmUretici.TcknGecerli(r.RadyologTckn)) e.Add("Raporu onaylayan radyoloğun TCKN'si yok ya da geçersiz (OBX-16).");
        if (r.IstemNedeniPuan <= 0 || r.CekimKalitePuan <= 0) e.Add("İstem nedeni / çekim kalitesi puanı girilmemiş (OBX-13).");
        if (r.OnayZamani is null) e.Add("Rapor onay zamanı yok (OBR-7).");
        return e;
    }
}

/// <summary>Teletıp ORM kuyruğu işçisi: 30 sn'de bir; aktif TeleRadyoloji hesabı yoksa hiçbir şey yapmaz.</summary>
public sealed class TeletipOrmIscisi(IServiceScopeFactory kapsam, ILogger<TeletipOrmIscisi> gunluk) : BackgroundService
{
    private static readonly TimeSpan Aralik = TimeSpan.FromSeconds(30);

    protected override async Task ExecuteAsync(CancellationToken dur)
    {
        try { await Task.Delay(TimeSpan.FromSeconds(25), dur); }
        catch (OperationCanceledException) { return; }
        while (!dur.IsCancellationRequested)
        {
            try
            {
                using var k = kapsam.CreateScope();
                var n = await k.ServiceProvider.GetRequiredService<TeletipOrmServisi>().SiradakileriIsleAsync(50, dur);
                if (n > 0) gunluk.LogInformation("Teletıp ORM: {Sayi} mesaj gönderildi.", n);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception h) { gunluk.LogError(h, "Teletıp ORM kuyruğu turu başarısız."); }
            try { await Task.Delay(Aralik, dur); }
            catch (OperationCanceledException) { break; }
        }
    }
}

/// <summary>
/// ŞUBENİN TELERADYOLOJİ HESABI (1317, fn_teletip_hesap_ayar): entegrasyon hesabı (kod TELERADYOLOJI) - firma kodu, Mirth
/// K1 / K2 / K3 adresleri, karakter seti, şube no, XDS hasta OID. Hesap yoksa şubede kapalı (1324).
/// </summary>
public sealed record TeleRadyolojiHesabi
{
    private static readonly JsonSerializerOptions JsonAyar = new() { PropertyNameCaseInsensitive = true };

    /// <summary>Şubenin hesabı (fn_teletip_hesap_ayar: şube satırı → kurum geneli → eski ayar); yoksa null.</summary>
    public static async Task<TeleRadyolojiHesabi?> OkuAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction? islem, int sube, CancellationToken iptal)
        => Coz(await b.TekDegerAsync<string>("select public.fn_teletip_hesap_ayar(@p0)::text", islem, [sube], iptal));

    public static TeleRadyolojiHesabi? Coz(string? json)
        => string.IsNullOrEmpty(json) ? null : JsonSerializer.Deserialize<TeleRadyolojiHesabi>(json, JsonAyar) ?? new();

    public int HesapId { get; init; }
    public string HesapAd { get; init; } = "";
    public bool Test { get; init; }
    public string FirmaKodu { get; init; } = "";
    public string Hl7Adres { get; init; } = "";
    public string XdsAdres { get; init; } = "";
    public string DozAdres { get; init; } = "";
    public string Encoding { get; init; } = "UTF8";
    public string SubeNo { get; init; } = "1";
    public string XdsHastaOid { get; init; } = "";
    public string MirthHesapId { get; init; } = "";
}

/// <summary>
/// ŞUBENİN BAKANLIK KİMLİĞİ (fn_kurum_kimlik; 1321-1323: şube e-Nabız → şube profili → kurum geneli e-Nabız → kurum geneli
/// profil → eski yer). Tek okuyucu: kuyruk işçisi, önizleme, entegrasyon sınaması aynı kaydı kullanır.
/// </summary>
public sealed record KurumKimlik(string Ad, string Skrs, string Tesis)
{
    /// <summary>Bakanlık test ortamı kodları - gerçek bağlantıdan önce değişmeli.</summary>
    public const string TestSkrs = "999999", TestTesis = "99999999";

    public static async Task<KurumKimlik> OkuAsync(Npgsql.NpgsqlConnection b, Npgsql.NpgsqlTransaction? islem, int sube, CancellationToken iptal)
        => await b.TekAsync("select coalesce(ad, ''), coalesce(skrs, ''), coalesce(tesis, '') from public.fn_kurum_kimlik(@p0)", islem, [sube],
               o => new KurumKimlik(o.GetString(0), o.GetString(1), o.GetString(2)), iptal) ?? new("", "", "");

    /// <summary>ORM verisine şubenin kimliği + hesabı: ad / tesis boşsa istemin verisi kalır.</summary>
    public OrmVerisi Uygula(OrmVerisi v, TeleRadyolojiHesabi h) => v with
    {
        FirmaKodu = h.FirmaKodu,
        Encoding = h.Encoding.Length > 0 ? h.Encoding : "UTF8",
        SubeNo = h.SubeNo.Length > 0 ? h.SubeNo : v.SubeNo,
        KurumAdi = Ad.Length > 0 ? Ad : v.KurumAdi,
        KurumSkrs = Skrs,
        MedulaTesisKodu = Tesis.Length > 0 ? Tesis : v.MedulaTesisKodu,
    };

    /// <summary>Gönderimi engelleyen kimlik eksikleri (sınama ekranı).</summary>
    public List<string> Eksikler(string firmaKodu)
    {
        var e = new List<string>();
        if (Skrs.Length == 0) e.Add("SKRS kurum kodu yok"); else if (Skrs == TestSkrs) e.Add("SKRS TEST değeri");
        if (Tesis.Length == 0) e.Add("MEDULA tesis kodu yok"); else if (Tesis == TestTesis) e.Add("MEDULA tesis TEST değeri");
        if (firmaKodu.Length == 0) e.Add("firma kodu yok");
        return e;
    }
}
