using System.Net.Sockets;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ CİHAZLARI v2 (mockup <c>Ekranlar/Goz/goz_goruntuleme_cihazlar_v2.html</c> ·
/// <c>goz_cihaz_karti_v2.html</c>).
///
/// <para>Listenin göstergesi, sol ağacı ve sağ önizlemesi; cihaz kartının
/// "Mesaj günlüğü" ve "Kalibrasyon (demirbaştan)" sekmeleri; bağlantı
/// sınaması. Mesaj <b>işleme</b> uçları ayrı yerde (<c>GozUclari.cs</c>
/// <c>/cihaz-mesaj/...</c>) - oradaki servis gece işiyle paylaşılıyor.</para>
///
/// <para><b>Sayılar görünümden okunur</b> (<c>v_goz_cihaz_ozet</c>, db/978):
/// gösterge ile liste kolonları aynı tanımı kullanmazsa "gösterge 3 diyor,
/// liste 2 satır veriyor" durumu kaçınılmaz olur.</para>
/// </summary>
public static class GozCihazUclari
{
    /// <param name="Ham">Cihazdan gelmiş gibi denenecek örnek mesaj.</param>
    /// <param name="Esleme">Kartta düzenlenen (henüz kaydedilmemiş) harita; boşsa kayıtlı olan.</param>
    public sealed record EslemeSinaIstegi(string? Ham, string? Esleme);

    public static void CihazUclariniEkle(this RouteGroupBuilder grup)
    {
        // ------------------------------------------------------- gösterge ----
        grup.MapGet("/cihaz-gosterge", async (BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var gosterge = await b.TekAsync("""
                select count(*)                                                as tanimli,
                       count(*) filter (where c.aktif = 1)                     as aktif,
                       coalesce(sum(v.bugun_cekim), 0)                         as "bugunCekim",
                       coalesce(sum(v.bekleyen), 0)                            as bekleyen,
                       coalesce(sum(v.eslenmeyen), 0)                          as eslenmeyen,
                       coalesce(sum(v.hatali), 0)                              as hatali,
                       count(*) filter (where v.kalibrasyon_gecikmis = 1)      as "kalibrasyonGecikmis"
                  from public.goz_cihaz c
                  join public.v_goz_cihaz_ozet v on v.cihaz_id = c.id
                 where (@p0::int is null or c.sube_id = @p0)
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            // SOL AĞAÇ: tür · protokol · durum. Dinleyici durumu ile aktiflik
            //   AYRI iki soru: pasif cihaz dinlemez ama "bağlantı yok" demek
            //   de değildir - kullanıcı ikisini ayrı süzmek istiyor.
            var turler = await b.ListeAsync("""
                select c.tur, count(*) as sayi from public.goz_cihaz c
                 where (@p0::int is null or c.sube_id = @p0) group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var protokoller = await b.ListeAsync("""
                select c.protokol, count(*) as sayi from public.goz_cihaz c
                 where (@p0::int is null or c.sube_id = @p0) group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var durumlar = await b.ListeAsync("""
                select case when c.aktif = 0 then 3
                            when c.dinleyici_durum = 2 then 2
                            when c.dinleyici_durum = 1 then 0
                            else 1 end                              as durum,
                       count(*)                                     as sayi
                  from public.goz_cihaz c
                 where (@p0::int is null or c.sube_id = @p0) group by 1 order by 1
                """, null, [baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new { gosterge, turler, protokoller, durumlar, izlemeNo = baglam.IzlemeNo });
        });

        // ------------------------------------------------------ önizleme ----
        // Liste sağ paneli ve kartın "Mesaj günlüğü" / "Kalibrasyon" sekmeleri
        //   AYNI uçtan beslenir: ikisi de cihazın o anki durumunu gösteriyor.
        grup.MapGet("/cihaz/{id:int}/onizleme", async (int id, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var cihaz = await b.TekAsync("""
                select c.id, c.kod, c.ad, c.tur, c.uretici, c.model, c.seri_no as "seriNo",
                       coalesce(c.oda, '')              as oda,
                       coalesce(c.yazilim_surum, '')    as "yazilimSurum",
                       c.cekim_dk                       as "cekimDk",
                       c.dilatasyon_ister               as "dilatasyonIster",
                       c.protokol, coalesce(c.baglanti, '') as baglanti, c.mwl,
                       c.dinleyici_durum                as "dinleyiciDurum",
                       c.son_mesaj                      as "sonMesaj",
                       c.son_sinama                     as "sonSinama",
                       coalesce(c.son_sinama_sonuc, '') as "sonSinamaSonuc",
                       c.aktif, c.demirbas_id           as "demirbasId",
                       coalesce(c.ayarlar, '{}'::jsonb) as ayarlar,
                       coalesce(c.tetkik_esleme, '[]'::jsonb) as "tetkikEsleme",
                       coalesce(c.olcum_esleme, '{}'::jsonb)  as "olcumEsleme",
                       coalesce(public.fn_taraf_ad(s.unvan, s.ad, s.soyad)::varchar(120), '') as sorumlu,
                       v.bugun_cekim as "bugunCekim", v.bekleyen, v.eslenmeyen, v.hatali,
                       v.mesaj_24s as "mesaj24s", v.islenen_24s as "islenen24s",
                       v.gecikme_sn as "gecikmeSn", v.tetkik_say as "tetkikSay",
                       v.esleme_say as "eslemeSay",
                       v.demirbas_kod as "demirbasKod",
                       v.kalibrasyon_periyot_ay as "kalibrasyonPeriyotAy",
                       v.son_kalibrasyon as "sonKalibrasyon",
                       v.kalibrasyon_gecerlilik as "kalibrasyonGecerlilik",
                       v.son_bakim as "sonBakim", v.sonraki_bakim as "sonrakiBakim",
                       v.garanti_bitis as "garantiBitis",
                       v.kalibrasyon_gecikmis as "kalibrasyonGecikmis"
                  from public.goz_cihaz c
                  join public.v_goz_cihaz_ozet v on v.cihaz_id = c.id
                  left join public.taraf s on s.id = c.sorumlu_id
                 where c.id = @p0 and (@p1::int is null or c.sube_id = @p1)
                """, null, [id, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");

            // SON MESAJLAR: ham gövde İLK 400 KARAKTER - tamamı kart sekmesinde
            //   satır açılınca okunur, panelde yüz satırlık XML yer kaplar.
            var mesajlar = await b.ListeAsync("""
                select m.id, m.zaman, coalesce(m.hasta_eslesme, '') as "hastaEslesme",
                       m.islem_durum as durum, coalesce(m.hata, '') as hata,
                       coalesce(m.dosya_yolu, '') as "dosyaYolu",
                       left(coalesce(m.ham, ''), 400) as ham
                  from public.goz_cihaz_mesaj m
                 where m.cihaz_id = @p0 order by m.zaman desc limit 20
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // TETKİK DAĞILIMI: cihazın bu ay hangi tetkiki kaç kez yaptığı -
            //   "eşlemede duruyor ama hiç kullanılmıyor" da bir cevaptır.
            var tetkikler = await b.ListeAsync("""
                select g.tetkik, count(*) as sayi
                  from public.goz_goruntuleme g
                 where g.cihaz_id = @p0 and g.durum <> 0
                   and g.istem_zamani >= date_trunc('month', now())
                 group by 1 order by 2 desc
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal);

            // KALİBRASYON KAYITLARI ve İŞ EMİRLERİ: demirbaştan SALT OKUMA
            //   (kullanıcı kararı 05.10.2026). Cihaz demirbaşa bağlı değilse
            //   boş dizi döner - ekran "takip edilmiyor" der.
            var kalibrasyonlar = await b.ListeAsync("""
                select k.id, k.tarih, coalesce(k.kayit_no, '') as "kayitNo", k.tur, k.sonuc,
                       k.gecerlilik, coalesce(k.referans_cihaz, '') as "referansCihaz",
                       coalesce(k.referans_sertifika, '') as "referansSertifika",
                       k.belirsizlik, coalesce(k.belirsizlik_birim, '') as "belirsizlikBirim",
                       coalesce(public.fn_taraf_ad(y.unvan, y.ad, y.soyad)::varchar(120), '') as yapan,
                       coalesce(f.unvan, '') as firma
                  from public.demirbas_kalibrasyon k
                  left join public.taraf y on y.id = k.yapan_id
                  left join public.taraf f on f.id = k.firma_id
                 where k.demirbas_id = @p0 order by k.tarih desc limit 10
                """, null, [cihaz["demirbasId"] is null ? -1 : Convert.ToInt32(cihaz["demirbasId"])],
                OkuyucuGenisletmeleri.Sozluk, iptal);
            var isEmirleri = await b.ListeAsync("""
                select e.id, coalesce(e.is_emri_no, '') as "isEmriNo", e.tur, e.oncelik, e.durum,
                       e.bildirim_zamani as "bildirimZamani", e.tamamlanma, e.planlanan,
                       coalesce(e.ariza_metni, '')  as "arizaMetni",
                       coalesce(e.yapilan_is, '')   as "yapilanIs",
                       e.hasta_etkilendi            as "hastaEtkilendi"
                  from public.demirbas_is_emri e
                 where e.demirbas_id = @p0 order by e.bildirim_zamani desc limit 10
                """, null, [cihaz["demirbasId"] is null ? -1 : Convert.ToInt32(cihaz["demirbasId"])],
                OkuyucuGenisletmeleri.Sozluk, iptal);

            return Results.Ok(new
            {
                cihaz, mesajlar, tetkikler, kalibrasyonlar, isEmirleri,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ------------------------------------------- eşlemeyi örnekle sına ----
        /* Kart "Ölçüm eşlemesi" sekmesindeki "örnek mesajla sına": ham metni
           cihazın AYRIŞTIRICISINDAN geçirir ve ne çıkacağını gösterir.
           HİÇBİR ŞEY YAZMAZ - eşleme kurarken cihazdan gerçek mesaj beklemek,
           her denemede bir hasta kaydını kirletmek demekti.

           Eşleme gövdeden alınabilir: kullanıcı kartta DEĞİŞTİRDİĞİ ama henüz
           kaydetmediği haritayı denemek istiyor; gövde boşsa kayıtlı harita. */
        grup.MapPost("/cihaz/{id:int}/esleme-sina", async (
            int id, EslemeSinaIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Gor);
            if (string.IsNullOrWhiteSpace(istek.Ham))
                throw GentegreHatasi.Dogrulama("Sınanacak örnek mesaj boş.");

            await using var b = await veri.AcAsync(iptal);
            var c = await b.TekAsync("""
                select c.protokol, coalesce(c.olcum_esleme, '{}'::jsonb)::text as esleme
                  from public.goz_cihaz c
                 where c.id = @p0 and (@p1::int is null or c.sube_id = @p1)
                """, null, [id, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");

            var esleme = string.IsNullOrWhiteSpace(istek.Esleme)
                ? (string)(c["esleme"] ?? "{}")
                : istek.Esleme!;
            var protokol = Convert.ToInt32(c["protokol"] ?? 0);

            List<object> satirlar;
            try
            {
                satirlar = Servisler.GozCihazServisi.EslemeSina(istek.Ham!, protokol, esleme)
                    .Select(d => (object)new
                    {
                        goz = d.Goz,
                        gozAd = d.Goz == 1 ? "OD" : d.Goz == 2 ? "OS" : "OU",
                        olcum = d.Olcum,
                        deger = d.Deger,
                    })
                    .ToList();
            }
            catch (System.Text.Json.JsonException h)
            {
                // BOZUK JSON kullanıcının yazdığı haritadan geliyor: 500 değil
                //   doğrulama hatası - düzeltecek olan kullanıcı.
                throw GentegreHatasi.Dogrulama($"Eşleme JSON'u okunamadı: {h.Message}");
            }

            return Results.Ok(new
            {
                satirlar,
                // SIFIR SATIR da bir cevaptır: "eşleme tutmadı" demek, hata değil.
                bulunan = satirlar.Count,
                protokol,
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // -------------------------------------------------- bağlantı sına ----
        /* NE YAPAR: cihazın ADRESİNE TCP bağlantısı dener ve sonucu kaydeder.
           NE YAPMAZ: DICOM C-ECHO göndermez - DICOM yığını yok. "Port açık"
           bilgisi sınırlıdır ama yanlış IP / kapalı cihaz / kapalı güvenlik
           duvarı durumlarını yakalar; sonucu bu sınırla YAZIYORUZ, kullanıcı
           "bağlantı tamam" sanıp sonuç beklemesin.
           Dosya protokolünde adres bir KLASÖRDÜR: sunucu o klasörü göremiyorsa
           TCP denemesi anlamsız - erişim kontrolü ayrı dalda. */
        grup.MapPost("/cihaz/{id:int}/sina", async (int id, BaglamCozucu cozucu,
            VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.cihaz", Islem.Degistir);
            baglam.YazmaIste();
            await using var b = await veri.AcAsync(iptal);

            var c = await b.TekAsync("""
                select c.protokol, coalesce(c.baglanti, '') as baglanti,
                       coalesce(c.ayarlar, '{}'::jsonb) ->> 'ip'   as ip,
                       coalesce(c.ayarlar, '{}'::jsonb) ->> 'port' as port,
                       coalesce(c.ayarlar, '{}'::jsonb) ->> 'klasor' as klasor,
                       coalesce((c.ayarlar ->> 'timeout_sn')::int, 5) as timeout
                  from public.goz_cihaz c
                 where c.id = @p0 and (@p1::int is null or c.sube_id = @p1)
                """, null, [id, baglam.SubeId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Cihaz bulunamadı.");

            var protokol = Convert.ToInt32(c["protokol"] ?? 0);
            string sonuc;
            var basarili = false;

            if (protokol == 3)
            {
                // Dosya protokolü: klasör sunucudan görünüyor mu?
                var klasor = (string?)c["klasor"] ?? "";
                if (klasor.Length == 0) klasor = (string)(c["baglanti"] ?? "");
                if (klasor.Length == 0) sonuc = "Klasör yolu tanımlı değil.";
                else if (Directory.Exists(klasor))
                {
                    var say = Directory.EnumerateFiles(klasor).Take(50).Count();
                    basarili = true;
                    sonuc = $"Klasör erişilebilir · {say} dosya görüldü";
                }
                else sonuc = $"Klasör görünmüyor: {klasor}";
            }
            else
            {
                var (ip, port) = AdresCoz(c);
                if (ip.Length == 0 || port <= 0)
                    sonuc = "IP / port tanımlı değil (ayarlar.ip · ayarlar.port ya da 'AE:ad@ip:port').";
                else
                {
                    var sn = Math.Clamp(Convert.ToInt32(c["timeout"] ?? 5), 1, 30);
                    var baslangic = DateTime.UtcNow;
                    try
                    {
                        using var istemci = new TcpClient();
                        using var zaman = new CancellationTokenSource(TimeSpan.FromSeconds(sn));
                        using var birlesik = CancellationTokenSource.CreateLinkedTokenSource(zaman.Token, iptal);
                        await istemci.ConnectAsync(ip, port, birlesik.Token);
                        var ms = (int)(DateTime.UtcNow - baslangic).TotalMilliseconds;
                        basarili = true;
                        // "Port açık" demek DICOM konuştuğu anlamına GELMEZ; metin bunu söylüyor.
                        sonuc = $"Port açık · {ms} ms (DICOM doğrulaması yapılmadı)";
                    }
                    catch (OperationCanceledException) { sonuc = $"Zaman aşımı ({sn} sn) · {ip}:{port}"; }
                    catch (SocketException h) { sonuc = $"Bağlanamadı · {ip}:{port} · {h.SocketErrorCode}"; }
                }
            }

            await b.CalistirAsync("""
                update public.goz_cihaz
                   set son_sinama = now(), son_sinama_sonuc = left(@p1, 200),
                       degistiren = @p2, degistirme_tarihi = now()
                 where id = @p0
                """, null, [id, sonuc, baglam.KullaniciId], iptal);

            return Results.Ok(new { id, basarili, sonuc, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>
    /// Adres iki yerde olabilir: yeni <c>ayarlar</c> (ip · port) ya da eski tek
    /// satır <c>baglanti</c> metni (<c>AE:OCT1@10.20.4.51:104</c>). Eski kayıtlar
    /// taşınmadan da çalışsın diye ikisi de okunuyor.
    /// </summary>
    private static (string Ip, int Port) AdresCoz(IDictionary<string, object?> c)
    {
        var ip = (string?)c["ip"] ?? "";
        var portMetin = (string?)c["port"] ?? "";
        if (ip.Length > 0 && int.TryParse(portMetin, out var p1)) return (ip, p1);

        var ham = (string)(c["baglanti"] ?? "");
        var at = ham.LastIndexOf('@');
        var kalan = at >= 0 ? ham[(at + 1)..] : ham;
        var iki = kalan.Split(':', StringSplitOptions.TrimEntries);
        if (iki.Length == 2 && int.TryParse(iki[1], out var p2)) return (iki[0], p2);
        return (kalan.Trim(), 104);
    }
}
