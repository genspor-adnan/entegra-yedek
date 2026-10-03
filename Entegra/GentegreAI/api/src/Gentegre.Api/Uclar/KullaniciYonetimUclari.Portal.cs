using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Uclar;

/// <summary>
/// PORTAL HESABI AÇMA (819) — dış hekim · dış kurum · hasta.
///
/// <para><b>Hesap PAROLASIZ doğar.</b> Kurum içi desenin aynısı (674):
/// yönetici parola yazmaz, kişi ilk girişte kendi parolasını koyar.
/// Yöneticinin belirlediği parola, telefonda söylenen paroladır - kimin
/// elinde kaldığı bilinmez.</para>
///
/// <para><b>Kurum hesabı KİŞİ BAŞI</b> (kullanıcı kararı): hesap kurumun cari
/// kaydında değil, ekranı kullanan insanın kaydında açılır; kapsam
/// `portal_taraf_id` ile kuruma bağlanır. Paylaşımlı hesapta kim ne yaptı
/// bilinmez ve biri ayrılınca parola herkes için değişirdi.</para>
///
/// <para><b>Ayrı yetki:</b> `kullanici.portal`. Kurum içi hesap açma yetkisi
/// bankoda birçok kişide var; dışarıya kapı açmak ayrı bir karardır.</para>
/// </summary>
public static class KullaniciPortalUclari
{
    private const int LogTabloKullanici = 902;

    public sealed record PortalHesapIstegi(
        /// <summary>Hesabın açılacağı kişi/kurum (taraf id).</summary>
        int TarafId,
        /// <summary>1 dış doktor · 2 dış kurum · 3 hasta.</summary>
        short PortalTuru,
        /// <summary>Giriş kodu; boşsa TCKN/VKN, o da yoksa taraf kodu.</summary>
        string? Kod = null,
        /// <summary>Kurum portalında temsil edilen kurum (cari) - zorunlu.</summary>
        int? KurumId = null,
        /// <summary>
        /// Atanacak portal rolünün kodu. Bir portal türünde BİRDEN ÇOK rol
        /// varsa (kurum: Klinik / Yönetici) zorunludur - sunucu kendi başına
        /// seçmez.
        /// </summary>
        string? RolKodu = null,
        string? Eposta = null,
        string? CepTel = null);

    public static void PortalHesapUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kullanici").WithTags("Kullanıcı")
                      .RequireAuthorization();

        // Hesabın açılabilir olup olmadığını SÖYLER - düğme çizilmeden önce.
        //   "Her zaman hata veren düğme" göstermemek için (805 dersi).
        grup.MapGet("/portal-durum/{tarafId:int}", async (
            int tarafId, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx,
            CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("kullanici", Islem.Gor);

            await using var b = await veri.AcAsync(iptal);
            var satir = await b.TekAsync("""
                select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, coalesce(t.vkno, '') as vkno,
                       coalesce(t.kisi, 0) as kisi, coalesce(t.musteri, 0) as musteri,
                       coalesce(t.hasta, 0) as hasta,
                       coalesce(p.dis_hekim, 0) as "disHekim",
                       k.kod as "mevcutKod", coalesce(r.portal_turu, 0) as "mevcutPortal",
                       coalesce(r.ad, '') as "mevcutRol",
                       k.portal_taraf_id as "kapsamTarafId",
                       coalesce(k.aktif, 0) as "hesapAktif",
                       -- BAĞLI KURUM (309): kişinin çalıştığı kurum `taraf.bag_id`
                       --   alanında durur ("Cariye Bağla"). Kurum portalı hesabı
                       --   açılırken kapsam için VARSAYILAN budur - kullanıcıya
                       --   kart numarası yazdırmak, zaten kayıtlı olan bilgiyi
                       --   ikinci kez sormak olurdu.
                       t.bag_id as "bagliKurumId",
                       coalesce(public.fn_taraf_ad(bk.unvan, bk.ad, bk.soyad)::varchar(120), '') as "bagliKurumAdi"
                  from public.taraf t
                  left join public.taraf bk on bk.id = t.bag_id
                  left join public.taraf_personel p on p.id = t.id
                  left join public.taraf_kullanici k on k.id = t.id
                  left join public.rol r on r.id = k.rol_id
                 where t.id = @p0
                """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Taraf bulunamadı.");

            // PORTAL ROLLERİ EKRANA: kurum portalında iki rol var (Klinik /
            //   Yönetici) ve ikisi FARKLI ŞEY görüyor - muhasebeyi tutan kişi
            //   hasta ve lab ekranı görmemeli (824). Hangisinin açılacağını
            //   sunucunun kendi başına seçmesi yanlış hesabı sessizce açmak
            //   olurdu; liste buradan gider, soruyu ekran sorar.
            satir["roller"] = await b.ListeAsync(
                "select kod, ad, coalesce(portal_turu, 0) as portal_turu, "
                + "       coalesce(amac, '') as amac "
                + "  from public.rol "
                + " where coalesce(portal_turu, 0) > 0 and coalesce(aktif, 1) = 1 "
                + " order by portal_turu, id",
                null, [],
                o => (IDictionary<string, object?>)new Dictionary<string, object?>
                {
                    ["kod"] = o.GetString(0),
                    ["ad"] = o.GetString(1),
                    ["portalTuru"] = o.GetInt16(2),
                    ["amac"] = o.GetString(3),
                }, iptal);

            return Results.Ok(satir);
        });

        // --------------------------------------------- toplu portal rolü ----
        // Kullanıcı: *"tüm dış doktorlara Dış Doktor rolü ver"*.
        //
        // Göçle gelen dış hekimlerin HESABI VAR ama rolü "Rol Atanmamış" -
        //   giriş yapsalar hiçbir ekran göremezler. Tek tek rol atamak 20+
        //   kartı açmak demek.
        //
        // <b>Başka bir iç rolü olan hesap ATLANIR.</b> Dış hekim işaretli
        //   biri aynı zamanda kurum içinde çalışıyor olabilir; rolünü portal
        //   roluyle ezmek, o kişinin bütün yetkilerini sessizce kaldırırdı.
        //   Atlananlar yanıtta adıyla döner - karar insana kalır.
        grup.MapPost("/portal-toplu-rol", async (
            short portalTuru, BaglamCozucu cozucu, VeriKaynagi veri, LogDeposu log,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("kullanici.portal");

            if (portalTuru is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Portal türü 1, 2 ya da 3 olmalı.");

            await using var b = await veri.AcAsync(iptal);

            var rolId = await b.TekDegerAsync<int?>(
                "select id from public.rol where portal_turu = @p0 and coalesce(aktif, 1) = 1 "
                + "order by id limit 1", null, [portalTuru], iptal)
                ?? throw GentegreHatasi.IsKurali(
                    "Bu portal türü için aktif rol tanımlı değil (795 / 796 / 818).");

            // HEDEF KÜME portal türüne göre: dış hekim / hasta. Kurum
            //   portalında toplu atama YOK - orada hesap kişiye açılıyor ve
            //   hangi kurumu temsil ettiği tek tek seçiliyor (819).
            var kosul = portalTuru switch
            {
                1 => "coalesce(p.dis_hekim, 0) = 1",
                3 => "coalesce(t.hasta, 0) = 1",
                _ => throw GentegreHatasi.IsKurali(
                    "Kurum portalında toplu rol atama yok: her hesabın hangi kurumu "
                    + "temsil ettiği ayrıca seçilmeli."),
            };

            var adaylar = await b.ListeAsync($"""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as unvan, k.kod,
                       coalesce(r.ad, '') as "rolAdi",
                       coalesce(r.portal_turu, 0) as "rolPortal",
                       coalesce(r.sistem, 0) as "rolSistem",
                       -- ANLAMLI İÇ YETKİ: `panel` ve `ai.rehber` her role
                       --   verilen ortak kutulardır; "Rol Atanmamış" bile
                       --   onları taşıyor. Ham yetki sayısına bakmak, gerçekte
                       --   YETKİSİZ olan hesapları da korumalı sanıp hepsini
                       --   atlatıyordu.
                       (select count(*) from public.rol_yetki ry
                          join public.yetki y on y.id = ry.yetki_id
                         where ry.rol_id = k.rol_id
                           and y.kod not in ('panel', 'ai.rehber'))
                           as "yetkiSayisi"
                  from public.taraf t
                  join public.taraf_kullanici k on k.id = t.id
                  left join public.taraf_personel p on p.id = t.id
                  left join public.rol r on r.id = k.rol_id
                 where {kosul} and coalesce(k.aktif, 0) = 1
                """, null, [], OkuyucuGenisletmeleri.Sozluk, iptal);

            var atanacak = new List<int>();
            var atlanan = new List<object>();
            foreach (var a in adaylar)
            {
                var id = Convert.ToInt32(a["id"]);
                var rolPortal = Convert.ToInt32(a["rolPortal"] ?? 0);
                var yetki = Convert.ToInt32(a["yetkiSayisi"] ?? 0);

                if (rolPortal == portalTuru) continue;                 // zaten doğru rolde
                // YETKİLİ İÇ ROL EZİLMEZ: yetkisi olan bir rol taşıyorsa o
                //   kişi kurum içinde de çalışıyor olabilir.
                if (rolPortal == 0 && yetki > 0)
                {
                    atlanan.Add(new
                    {
                        id, unvan = a["unvan"], kod = a["kod"],
                        rol = a["rolAdi"],
                        sebep = "Yetkili bir iç rolü var - elle karar verilmeli.",
                    });
                    continue;
                }
                atanacak.Add(id);
            }

            if (atanacak.Count > 0)
            {
                await b.CalistirAsync("""
                    update public.taraf_kullanici
                       set rol_id = @p1, degistiren = @p2, degistirme_tarihi = now()
                     where id = any(@p0)
                    """, null, [atanacak.ToArray(), rolId, baglam.KullaniciId], iptal);

                await log.YazAsync(LogIslemi.Degistir, LogTabloKullanici, 0,
                    baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                    new Dictionary<string, string>
                    {
                        ["islem"] = "Toplu portal rolü atandı",
                        ["portalTuru"] = portalTuru.ToString(),
                        ["adet"] = atanacak.Count.ToString(),
                    }, iptal: iptal);
            }

            return Results.Ok(new
            {
                atanan = atanacak.Count,
                atlanan,
                mesaj = atanacak.Count == 0
                    ? "Rol atanacak hesap bulunamadı."
                    : $"{atanacak.Count} hesaba portal rolü atandı."
                      + (atlanan.Count > 0 ? $" {atlanan.Count} hesap atlandı." : ""),
            });
        });

        grup.MapPost("/portal-hesap", async (
            PortalHesapIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Gentegre.Api.Servisler.PortalDavetServisi davet,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.AksiyonIste("kullanici.portal");

            if (istek.PortalTuru is < 1 or > 3)
                throw GentegreHatasi.Dogrulama("Portal türü 1, 2 ya da 3 olmalı.");

            await using var b = await veri.AcAsync(iptal);

            var taraf = await b.TekAsync("""
                select t.id, public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as unvan, coalesce(t.vkno, '') as vkno, coalesce(t.kod, '') as kod,
                       coalesce(t.kisi, 0) as kisi, coalesce(t.musteri, 0) as musteri,
                       coalesce(t.hasta, 0) as hasta, coalesce(t.durum, 1) as durum,
                       coalesce(p.dis_hekim, 0) as "disHekim",
                       (select k.id from public.taraf_kullanici k where k.id = t.id) as "hesapVar"
                  from public.taraf t
                  left join public.taraf_personel p on p.id = t.id
                 where t.id = @p0
                """, null, [istek.TarafId], OkuyucuGenisletmeleri.Sozluk, iptal)
                ?? throw GentegreHatasi.Bulunamadi("Taraf bulunamadı.");

            if (taraf["hesapVar"] is not null)
                throw GentegreHatasi.IsKurali(
                    "Bu kayda ait kullanıcı hesabı zaten var; rolünü kullanıcı kartından "
                    + "değiştirin.");

            // TARAF UYGUN MU: portal türü, kaydın NE OLDUĞUYLA tutarlı olmalı.
            //   Rastgele bir cariye hasta portalı açmak, o kişiye başkasının
            //   kayıtlarını açmaz (kapsam kuralı korur) ama kurulumda kimin
            //   neyi gördüğünü izlenemez kılardı.
            var hata = istek.PortalTuru switch
            {
                1 when Sayi(taraf["disHekim"]) != 1
                    => "Dış hekim portalı yalnız \"Dış Hekim\" işaretli kişi kartına açılır.",
                3 when Sayi(taraf["hasta"]) != 1
                    => "Hasta portalı yalnız hasta kartına açılır.",
                2 when Sayi(taraf["kisi"]) != 1 && Sayi(taraf["musteri"]) != 1
                    => "Kurum portalı hesabı bir KİŞİ kartına açılır (kurumu temsil eden kişi).",
                _ => null,
            };
            if (hata is not null) throw GentegreHatasi.IsKurali(hata);

            int? kapsamTaraf = null;
            if (istek.PortalTuru == 2)
            {
                // KİŞİ BAŞI HESAP: kapsam kurumdan gelir, kişinin kendisinden
                //   değil - hangi kurumun işlerini göreceği açıkça seçilir.
                // KURUM VERİLMEDİYSE BAĞLI KURUM: kişi kartındaki "Bağlı Kurum"
                //   (309) zaten bu bilgiyi taşıyor.
                var bagliKurum = await b.TekDegerAsync<int?>(
                    "select bag_id from public.taraf where id = @p0",
                    null, [istek.TarafId], iptal);
                var kurumId = istek.KurumId ?? bagliKurum
                    ?? throw GentegreHatasi.Dogrulama(
                        "Kurum portalında kurum seçilmeli (kişi kartında \"Bağlı Kurum\" "
                        + "da boş).");
                var musteri = await b.TekDegerAsync<int>(
                    "select coalesce(musteri, 0) from public.taraf where id = @p0",
                    null, [kurumId], iptal);
                if (musteri != 1)
                    throw GentegreHatasi.IsKurali("Seçilen kayıt bir cari (kurum) değil.");
                // Kendi kaydına devir anlamsız: kurumun cari kaydına hesap
                //   açılıyorsa kapsam zaten odur.
                kapsamTaraf = kurumId == istek.TarafId ? null : kurumId;
            }

            // ROL SEÇİMİ SUNUCUDA TAHMİN EDİLMEZ (824 sonrası):
            //   Eskiden `order by id limit 1` vardı; kurum portalında iki rol
            //   olunca (Klinik 62, Yönetici 190) HER ZAMAN Klinik seçiliyordu -
            //   muhasebeciye hasta ve lab ekranı açan sessiz bir yanlıştı.
            //   Tek rollü portal türünde soru sorulmaz; çoklu türde rol kodu
            //   ZORUNLU - "en düşük id" bir iş kuralı değil, rastlantıdır.
            var roller = await b.ListeAsync(
                "select id, kod, ad from public.rol "
                + " where portal_turu = @p0 and coalesce(aktif, 1) = 1 order by id",
                null, [istek.PortalTuru],
                o => (Id: o.GetInt32(0), Kod: o.GetString(1), Ad: o.GetString(2)), iptal);
            if (roller.Count == 0)
                throw GentegreHatasi.IsKurali(
                    "Bu portal türü için rol tanımlı değil (795 / 796 / 818 / 824).");

            var rolKodu = (istek.RolKodu ?? "").Trim();
            int rolId;
            if (rolKodu.Length > 0)
            {
                rolId = roller.FirstOrDefault(r =>
                    string.Equals(r.Kod, rolKodu, StringComparison.OrdinalIgnoreCase)).Id;
                if (rolId == 0)
                    throw GentegreHatasi.Dogrulama(
                        $"\"{rolKodu}\" bu portal türünün rolü değil.",
                        [new("rolKodu",
                             "Seçenekler: " + string.Join(", ", roller.Select(r => r.Kod)))]);
            }
            else if (roller.Count == 1) rolId = roller[0].Id;
            else
                throw GentegreHatasi.Dogrulama(
                    "Bu portal türünde birden çok rol var; hangisi olacağı seçilmeli.",
                    [new("rolKodu",
                         string.Join(" · ", roller.Select(r => $"{r.Kod} = {r.Ad}")))]);

            // KOD: TCKN/VKN varsa o - kişi kendi bildiği numarayla girer.
            //   Yoksa taraf kodu. Benzersizlik veritabanında.
            var kod = (istek.Kod ?? "").Trim();
            if (kod.Length == 0) kod = ((string)(taraf["vkno"] ?? "")).Trim();
            if (kod.Length == 0) kod = ((string)(taraf["kod"] ?? "")).Trim();
            if (kod.Length == 0)
                throw GentegreHatasi.Dogrulama(
                    "Giriş kodu belirlenemedi: kartta TCKN/VKN yok, kod girin.");

            var cakisma = await b.TekDegerAsync<int>(
                "select count(*) from public.taraf_kullanici where lower(kod) = lower(@p0)",
                null, [kod], iptal);
            if (cakisma > 0)
                throw GentegreHatasi.IsKurali($"'{kod}' kodu başka bir hesapta kullanılıyor.");

            await using var islem = await b.BeginTransactionAsync(iptal);

            // PAROLASIZ: `parola_hash` boş + `parola_degismeli = 1`. Kişi ilk
            //   girişte kendi parolasını koyar (674 akışı).
            await b.CalistirAsync("""
                insert into public.taraf_kullanici
                       (id, kod, parola_hash, parola_algo, parola_degismeli, rol_id,
                        eposta, cep_tel, aktif, portal_taraf_id, ekleyen)
                values (@p0, @p1, '', 'bcrypt', 1, @p2, coalesce(@p3, ''), coalesce(@p4, ''),
                        1, @p5, @p6)
                """, islem,
                [istek.TarafId, kod, rolId, istek.Eposta, istek.CepTel, kapsamTaraf,
                 baglam.KullaniciId], iptal);

            // ŞUBE: portal kullanıcısının işlemi bir şubede geçer; yoksa giriş
            //   şube seçemeden takılırdı. Açan kişinin aktif şubesi verilir.
            await b.CalistirAsync("""
                insert into public.kullanici_sube (taraf_id, sube_id, varsayilan)
                values (@p0, @p1, 1)
                on conflict do nothing
                """, islem, [istek.TarafId, baglam.SubeId ?? 1], iptal);

            await log.YazAsync(b, islem, LogIslemi.Ekle, LogTabloKullanici, istek.TarafId,
                baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                new Dictionary<string, string>
                {
                    ["islem"] = "Portal erişimi verildi",
                    ["portalTuru"] = istek.PortalTuru.ToString(),
                    ["kod"] = kod,
                    ["kapsamTaraf"] = kapsamTaraf?.ToString() ?? "",
                }, iptal: iptal);

            await islem.CommitAsync(iptal);

            // KİŞİYE HABER VERİLİR (kullanıcı: "portal erişimi ver dediğimde
            //   yine dış doktora sms/mail göndersin"): hesabı açıp giriş
            //   kodunu yöneticinin ekranında bırakmak, kimsenin girmediği bir
            //   hesap demekti. Davet bağlantısının AYNISI gider - kişi
            //   parolasını oradan koyar.
            //
            //   ZORUNLU DEĞİL: kartta TCKN ya da iletişim bilgisi yoksa hesap
            //   yine açılmış olur, yalnız haber gönderilemez ve bu SÖYLENİR.
            //   Hesap açmayı gönderime bağlamak, numarası olmayan hekime hiç
            //   erişim verilememesi demekti.
            var haber = await davet.UretVeGonderAsync(
                istek.TarafId, kanalSecim: null,
                aliciSecim: istek.CepTel ?? istek.Eposta,
                baglam, zorunlu: false, iptal, portalTuru: istek.PortalTuru);

            return Results.Ok(new
            {
                tarafId = istek.TarafId,
                kod,
                portalTuru = istek.PortalTuru,
                kapsamTarafId = kapsamTaraf,
                parolasiz = true,
                davetGonderildi = haber is not null,
                davetAlici = haber?.MaskeliAlici ?? "",
                mesaj = haber is not null
                    ? $"Portal erişimi açıldı ve davet gönderildi ({haber.MaskeliAlici}). "
                      + $"Giriş kodu: {kod}."
                    : $"Portal erişimi açıldı. Giriş kodu: {kod}. "
                      + "Haber GÖNDERİLEMEDİ (kartta TCKN ya da iletişim bilgisi yok); "
                      + "kişi ilk girişte kendi parolasını belirleyecek.",
            });
        });
    }

    private static int Sayi(object? deger) => deger is null ? 0 : Convert.ToInt32(deger);
}
