using Gentegre.Cekirdek.Cihaz;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// TESLİM SERVİSİ (814) — kuyruktaki işi mesaja çevirir, gönderir, sonucu yazar.
///
/// <para><b>Üç adım, tek yer:</b> veriyi topla → <see cref="OruUretici"/> ile
/// mesajı kur → <see cref="MllpIstemci"/> ile gönder ve ACK'i yorumla. Uç da,
/// arka plan işçisi de buradan geçer; "elle gönderim" ile "otomatik gönderim"
/// aynı kodu çalıştırır - ikisi ayrılsaydı biri düzeltilip öteki unutulurdu.
///
/// <para><b>ACK politikası</b> (kapsam belgesi § 4.2):
/// <list type="bullet">
/// <item>AA → teslim tamam, istek damgalanır.</item>
/// <item>AE → mesaj ulaştı ama kabul edilmedi; <b>otomatik tekrar YOK</b>,
/// aynı mesaj yine reddedilir - insan bakmalı.</item>
/// <item>AR / yanıt yok → kuyrukta kalır, artan aralıkla tekrar.</item>
/// </list></para>
/// </summary>
public sealed class TeleradTeslimServisi(VeriKaynagi veri, MllpIstemci mllp,
                                         ILogger<TeleradTeslimServisi> gunluk)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly MllpIstemci _mllp = mllp;
    private readonly ILogger<TeleradTeslimServisi> _gunluk = gunluk;

    public sealed record TeslimSonucu(long TeslimId, bool Basarili, string AckKodu,
                                      string Hata, short Durum);

    /// <summary>Kuyruğa alır (kural veritabanında: fn_telerad_teslim_kuyrukla).</summary>
    public async Task<long> KuyruklaAsync(int istekId, short hedef, int kullaniciId,
                                          CancellationToken iptal)
    {
        await using var b = await _veri.AcAsync(iptal);
        return await b.TekDegerAsync<long>(
            "select public.fn_telerad_teslim_kuyrukla(@p0, @p1, @p2)",
            null, [istekId, hedef, kullaniciId], iptal);
    }

    /// <summary>Tek kuyruk satırını dener. Kuyruk satırı yoksa hata döner.</summary>
    public async Task<TeslimSonucu> DeneAsync(long teslimId, CancellationToken iptal)
    {
        await using var b = await _veri.AcAsync(iptal);

        // TEK SORGU: mesajın her alanı buradan gelir. Parça parça okumak,
        //   "hangi alan nereden geliyor" sorusunu koda dağıtırdı.
        var k = await b.TekAsync(SatirSql, null, [teslimId],
                                 OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Teslim kaydı bulunamadı.");

        var hedef = Convert.ToInt16(k["hedef"] ?? (short)1);
        var bakanlikMi = hedef == 2;
        var adres = (string)(k["hl7Adres"] ?? "");
        var eksik = (string)(k["bakanlikEksik"] ?? "");

        // BAKANLIK HEDEFİNDE EKSİK VARSA HİÇ GÖNDERİLMEZ: reddedilecek mesajı
        //   yollamak, kuyruğu ve karşı tarafın günlüğünü boş yere şişirir.
        //   Eksik listesi ekranı (813) neyin eksik olduğunu zaten söylüyor.
        if (bakanlikMi && eksik.Length > 0)
            return await SonucYazAsync(b, teslimId, k, "", $"Gönderilmedi - eksik alan: {eksik}",
                                       "", "", 0, kalici: true, iptal);

        if (adres.Length == 0)
            return await SonucYazAsync(b, teslimId, k, "", "Kurum kartında teslim adresi yok.",
                                       "", "", 0, kalici: true, iptal);

        var mesaj = MesajKur(k, bakanlikMi, out var kontrolNo);
        var encodingAdi = Convert.ToInt16(k["mshEncoding"] ?? (short)1) == 2
                        ? "Windows1254" : "UTF8";

        await b.CalistirAsync("""
            update public.telerad_teslim
               set durum = 2, mesaj_kontrol_no = @p1, son_deneme = now()::timestamp
             where id = @p0
            """, null, [teslimId, kontrolNo], iptal);

        var tls = Convert.ToInt16(k["tls"] ?? (short)0) == 1;
        var sonuc = await _mllp.GonderAsync(adres, mesaj, encodingAdi, tls, 30, iptal);

        return await SonucYazAsync(b, teslimId, k, sonuc.AckKodu, sonuc.Hata, mesaj,
                                   sonuc.YanitGovdesi, sonuc.SureMs,
                                   kalici: sonuc.KaliciHata, iptal);
    }

    /// <summary>Zamanı gelmiş kuyruk satırlarını sırayla dener.</summary>
    public async Task<int> SiradakileriIsleAsync(int azami, CancellationToken iptal)
    {
        List<long> sira;
        await using (var b = await _veri.AcAsync(iptal))
        {
            var satirlar = await b.ListeAsync("""
                select id from public.telerad_teslim
                 where durum = 1 and sonraki_deneme <= now()::timestamp
                 order by sonraki_deneme
                 limit @p0
                """, null, [azami], OkuyucuGenisletmeleri.Sozluk, iptal);
            sira = [.. satirlar.Select(x => Convert.ToInt64(x["id"]))];
        }

        var sayac = 0;
        foreach (var id in sira)
        {
            if (iptal.IsCancellationRequested) break;
            try
            {
                var s = await DeneAsync(id, iptal);
                if (s.Basarili) sayac++;
            }
            catch (Exception h)
            {
                _gunluk.LogError(h, "Teslim {Id} denenirken hata.", id);
            }
        }
        return sayac;
    }

    // ------------------------------------------------------------- mesaj ----
    private static string MesajKur(IDictionary<string, object?> k, bool bakanlikMi,
                                   out string kontrolNo)
    {
        // ALAN OKUMA TOLERANSLI: eksik bir kolon mesajı boş bırakmalı, isteği
        //   500 ile düşürmemeli - teslim akışı tek eksik alan yüzünden
        //   tamamen durmasın (eksikler zaten fn_telerad_bakanlik_eksik'te).
        object? D(string ad) => k.TryGetValue(ad, out var v) ? v : null;
        string M(string ad) => D(ad) as string ?? "";
        DateTime? T(string ad) => D(ad) is DateTime d ? d : null;
        short S(string ad) => D(ad) is { } v ? Convert.ToInt16(v) : (short)0;

        // MSH-10 KONTROL NUMARASI: ACK bununla eşleşiyor ve mükerrer gönderimi
        //   karşı taraf bununla eliyor - her DENEME için yeni değil, teslim
        //   satırı + deneme numarasıyla üretilir.
        kontrolNo = $"T{k["id"]}D{S("denemeNo") + 1}";

        var veri = new OruVerisi
        {
            Profil = bakanlikMi ? Hl7Profili.Bakanlik : Hl7Profili.Kurum,
            GonderenUygulama = M("mshUygulama").Length > 0 ? M("mshUygulama") : "GENTEGRE",
            GonderenTesis = M("mshTesis").Length > 0 ? M("mshTesis") : M("subeAdi"),
            AliciUygulama = M("aliciUygulama").Length > 0 ? M("aliciUygulama")
                          : bakanlikMi ? "TELETIP" : "HBYS",
            AliciTesis = M("aliciTesis").Length > 0 ? M("aliciTesis")
                       : bakanlikMi ? "TELETIP" : M("kurumAdi"),
            Zaman = DateTime.Now,
            KontrolNo = kontrolNo,
            Encoding = S("mshEncoding") == 2 ? "Windows1254" : "UTF8",

            HastaDosyaNo = M("hastaDosyaNo"),
            HastaTckn = M("hastaTckn"),
            HastaSoyad = M("hastaSoyad"),
            HastaAd = M("hastaAd"),
            DogumTarihi = T("dogumTarihi"),
            Cinsiyet = S("cinsiyet") switch { 1 => "M", 2 => "F", _ => "U" },

            BasvuruNo = M("basvuruNo"),
            HastaneReferans = M("hastaneReferans"),
            SysTakipNo = M("sysTakipNo"),
            KurumSkrs = M("skrsKodu"),
            AccessionNo = M("accessionNo"),
            IsteyenHekimTckn = M("isteyenHekimTckn"),
            IsteyenHekimSoyad = M("isteyenHekimSoyad"),
            IsteyenHekimAd = M("isteyenHekimAd"),
            Bolum = M("bolum"),

            SutKodu = M("sutKodu"),
            SutAdi = M("sutAdi"),
            Loinc = M("loinc"),
            // LOINC AÇIKLAMASI ELİMİZDE YOK: SUT adını oraya yazmak, karşı
            //   tarafa yanlış bilgi göndermek olurdu - alan boş bırakılıyor.
            LoincAdi = "",
            IstemZamani = T("istemZamani"),
            OnayZamani = T("onayZamani"),
            CekimZamani = T("cekimZamani"),
            KlinikBilgi = M("klinikBilgi"),
            // OBR-15: raporu BİZ yazdık; istemi açan kurum başkası. Kendi SKRS
            //   kodumuz yazılmazsa rapor karşı tarafın istemine oturmaz.
            HizmetVerenSkrs = bakanlikMi ? M("bizimSkrs") : "",
            ModaliteKodu = M("modaliteKodu"),
            TeknisyenId = M("teknisyenId"),
            TeknisyenSoyad = M("teknisyenSoyad"),
            TeknisyenAd = M("teknisyenAd"),

            RaporTeknik = M("raporTeknik"),
            RaporKarsilastirma = M("raporKarsilastirma"),
            RaporBulgular = M("raporBulgular"),
            RaporSonuc = M("raporSonuc"),
            IstemNedeniPuan = S("istemNedeniPuan"),
            CekimKalitePuan = S("cekimKalitePuan"),
            RadyologTckn = M("radyologTckn"),
            RadyologSoyad = M("radyologSoyad"),
            RadyologAd = M("radyologAd"),
            KontrastObx17 = M("kontrastObx17"),
            Duzeltme = S("addendum") == 1,
            TaniIcd = M("onTani").Length > 0 ? [M("onTani")] : [],
        };

        return OruUretici.Uret(veri);
    }

    // -------------------------------------------------------- sonuç yazımı ----
    private async Task<TeslimSonucu> SonucYazAsync(Npgsql.NpgsqlConnection b, long teslimId,
        IDictionary<string, object?> k, string ackKodu, string hata, string istekGovde,
        string yanitGovde, int sureMs, bool kalici, CancellationToken iptal)
    {
        var basarili = ackKodu is "AA" or "CA";
        var denemeNo = (short)(Convert.ToInt16(k["denemeNo"] ?? (short)0) + 1);
        var azami = await AyarDeposu.MetinAsync(b, null, "telerad.teslim_azami_deneme", "12", iptal);
        var azamiSayi = int.TryParse(azami, out var x) ? x : 12;

        // DURUM: başarılı 3 · kalıcı hata 4 · azami denemeyi aşan 4 · gerisi 1
        //   (kuyrukta bekler). AE'yi tekrar denememek bilinçli: aynı mesaj yine
        //   reddedilir, kuyruk sonsuza kadar döner ve gerçek sorun görünmez.
        short durum = basarili ? (short)3
                    : kalici ? (short)4
                    : azamiSayi > 0 && denemeNo >= azamiSayi ? (short)4
                    : (short)1;

        var sonucKodu = basarili ? (short)1
                      : ackKodu == "AE" ? (short)2
                      : ackKodu == "AR" ? (short)3 : (short)4;

        await using var islem = await b.BeginTransactionAsync(iptal);

        await b.CalistirAsync("""
            insert into public.telerad_teslim_iz
                   (teslim_id, deneme_no, sonuc, ack_kodu, hata_metni, sure_ms,
                    istek_govde, yanit_govde)
            values (@p0, @p1, @p2, @p3, left(@p4, 400), @p5, @p6, @p7)
            """, islem, [teslimId, denemeNo, sonucKodu, ackKodu, hata, sureMs,
                         istekGovde, yanitGovde], iptal);

        await b.CalistirAsync("""
            update public.telerad_teslim
               set durum = @p1, deneme_no = @p2, ack_kodu = @p3,
                   hata_metni = left(@p4, 400),
                   son_deneme = now()::timestamp,
                   sonraki_deneme = case when @p1 = 1
                        then (now() + public.fn_telerad_teslim_sonraki(@p2))::timestamp
                        else sonraki_deneme end,
                   degistirme_tarihi = now()
             where id = @p0
            """, islem, [teslimId, durum, denemeNo, ackKodu, hata], iptal);

        // İSTEĞİN TESLİM DAMGASI yalnız KURUM hedefinde yazılır: Bakanlık
        //   bildirimi kuruma teslim değildir, ayrı bir kayıt yükümlülüğüdür.
        if (basarili && Convert.ToInt16(k["hedef"] ?? (short)1) == 1)
            await b.CalistirAsync("""
                update public.telerad_istek
                   set durum = case when durum < 7 then 7 else durum end,
                       teslim_zamani = coalesce(teslim_zamani, now()::timestamp),
                       teslim_durum = 1, teslim_hata = ''
                 where id = @p0
                """, islem, [Convert.ToInt32(k["istekId"])], iptal);
        else if (!basarili && Convert.ToInt16(k["hedef"] ?? (short)1) == 1)
            await b.CalistirAsync("""
                update public.telerad_istek
                   set teslim_durum = 2, teslim_hata = left(@p1, 400)
                 where id = @p0
                """, islem, [Convert.ToInt32(k["istekId"]), hata], iptal);

        await islem.CommitAsync(iptal);

        return new TeslimSonucu(teslimId, basarili, ackKodu, hata, durum);
    }

    /// <summary>
    /// Mesajın bütün alanları TEK sorgudan. Rapor gövdesi parça numarasına
    /// göre (809) toplanır - başlık metnine göre değil.
    /// </summary>
    internal const string SatirSql = """
        select t.id, t.hedef, t.deneme_no as "denemeNo", t.istek_id as "istekId",
               coalesce(k.hl7_adres, '')            as "hl7Adres",
               coalesce(k.hl7_alici_uygulama, '')   as "aliciUygulama",
               coalesce(k.hl7_alici_tesis, '')      as "aliciTesis",
               coalesce(k.msh_uygulama, '')         as "mshUygulama",
               coalesce(k.msh_tesis, '')            as "mshTesis",
               coalesce(k.msh_encoding, 1)          as "mshEncoding",
               coalesce(k.skrs_kodu, '')            as "skrsKodu",
               0::smallint                          as tls,
               coalesce(tk.unvan, '')               as "kurumAdi",
               coalesce(sb.ad, '')                  as "subeAdi",
               -- BİZİM SKRS kodumuz (OBR-15): hizmeti veren kurum biziz.
               coalesce((select r.deger from public.referans r
                          where r.anahtar = 'kurum.skrs_kodu'), '') as "bizimSkrs",

               coalesce(i.dis_erisim_no, '')        as "accessionNo",
               -- PID-3: hastanin GONDEREN KURUMDAKI dosya numarasi (816).
               coalesce(i.dis_hasta_no, '')         as "hastaDosyaNo",
               coalesce(i.dis_hasta_kimlik, '')     as "hastaTckn",
               coalesce(h.soyad, '')                as "hastaSoyad",
               coalesce(nullif(h.ad, ''), h.unvan, '') as "hastaAd",
               hs.dogum_tarihi                      as "dogumTarihi",
               coalesce(hs.cinsiyet, 0)             as cinsiyet,
               coalesce(i.isteyen_hekim_tckn, '')   as "isteyenHekimTckn",
               coalesce(split_part(i.isteyen_hekim, ' ', 2), '') as "isteyenHekimSoyad",
               coalesce(split_part(i.isteyen_hekim, ' ', 1), '') as "isteyenHekimAd",
               coalesce(i.klinik_bilgi, '')         as "klinikBilgi",
               i.ekleme_tarihi::timestamp           as "istemZamani",
               i.onay_zamani                        as "onayZamani",
               i.cekim_zamani                       as "cekimZamani",
               public.fn_rad_modalite_kod(i.modalite) as "modaliteKodu",
               coalesce(hz.sut_kodu, '')            as "sutKodu",
               coalesce(hz.ad, '')                  as "sutAdi",
               coalesce(hz.loinc, '')               as loinc,
               public.fn_telerad_bakanlik_eksik(i.id) as "bakanlikEksik",

               coalesce(ri.on_tani, '')             as "onTani",
               coalesce(ri.belge_id::text, '')      as "basvuruNo",
               coalesce(tek.unvan, '')              as "teknisyenSoyad",
               coalesce(tek.vkno, '')               as "teknisyenId",
               ''                                   as "teknisyenAd",
               ''                                   as bolum,
               case when i.radyoloji_istem_id is null then ''
                    else public.fn_rad_kontrast_obx17(i.radyoloji_istem_id) end
                                                    as "kontrastObx17",
               coalesce(er.sys_takip_no, '')        as "sysTakipNo",
               coalesce(er.hastane_referans, '')    as "hastaneReferans",

               coalesce(rp.istem_nedeni_puan, 0)    as "istemNedeniPuan",
               coalesce(rp.cekim_kalite_puan, 0)    as "cekimKalitePuan",
               coalesce(rad.vkno, '')               as "radyologTckn",
               coalesce(rad.soyad, '')              as "radyologSoyad",
               coalesce(nullif(rad.ad, ''), rad.unvan, '') as "radyologAd",
               case when rp.ust_rapor_id is null then 0 else 1 end::smallint as addendum,

               coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira)
                           from public.radyoloji_rapor_bolum b
                          where b.rapor_id = rp.id and b.bakanlik_parca = 1), '') as "raporTeknik",
               coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira)
                           from public.radyoloji_rapor_bolum b
                          where b.rapor_id = rp.id and b.bakanlik_parca = 2), '') as "raporKarsilastirma",
               coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira)
                           from public.radyoloji_rapor_bolum b
                          where b.rapor_id = rp.id and b.bakanlik_parca = 3), '') as "raporBulgular",
               coalesce((select string_agg(btrim(b.metin), E'\n' order by b.sira)
                           from public.radyoloji_rapor_bolum b
                          where b.rapor_id = rp.id and b.bakanlik_parca = 4), '') as "raporSonuc"
          from public.telerad_teslim t
          join public.telerad_istek i on i.id = t.istek_id
          join public.telerad_kurum k on k.id = i.kurum_id
          join public.taraf tk on tk.id = k.taraf_id
          left join public.sube sb on sb.id = i.sube_id
          left join public.taraf h on h.id = i.hasta_id
          left join public.taraf_hasta hs on hs.id = i.hasta_id
          left join public.hizmet hz on hz.id = i.tetkik_hizmet_id
          left join public.radyoloji_istem ri on ri.id = i.radyoloji_istem_id
          left join public.taraf tek on tek.id = ri.tekniker_id
          left join public.radyoloji_rapor rp on rp.id = i.rapor_id
          left join public.taraf rad on rad.id = rp.onaylayan_id
          left join lateral public.fn_enabiz_basvuru_referans(ri.belge_id) er on true
         where t.id = @p0
        """;
}
