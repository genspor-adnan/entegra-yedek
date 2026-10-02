using Gentegre.Api.Servisler;
using Gentegre.Api.Uclar;

namespace Gentegre.Testler;

/// <summary>
/// YZ KONTÖR (934, kullanıcı: "KK girip benden kontör alabilecek müşteri").
///
/// · Ödeme sonucu İDEMPOTENT: aynı bildirim iki kez gelirse kontör bir kez yüklenir.
/// · Başarılı plan ödemesi aboneliği açar; reddedilen ödeme kontör yüklemez.
/// · Kurumda kapatılan özellik (oz_tani) kontör kapısından geçmez.
/// Test kurumun tek satırlık ai_kontor / ai_abonelik kaydını değiştirir ve
/// sonunda eski hâline döndürür; kendi sipariş ve hareketlerini siler.
/// </summary>
public sealed class AiKontorTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    [VtFact]
    public async Task Odeme_sonucu_bir_kez_islenir_red_kontor_yuklemez_kapali_ozellik_gecmez()
    {
        if (!_olgu.Baglandi(nameof(Odeme_sonucu_bir_kez_islenir_red_kontor_yuklemez_kapali_ozellik_gecmez))) return;
        var veri = _olgu.Gerekli();
        var ct = CancellationToken.None;
        var eskiBakiye = await veri.TekDegerAsync<decimal>("select bakiye from public.ai_kontor where id = 1", []);
        var eskiOz = await veri.TekDegerAsync<short>("select oz_tani from public.ai_kontor where id = 1", []);
        var ab = await veri.ListeAsync("select plan_id, donem_ay, durum from public.ai_abonelik where id = 1", [],
            o => (Plan: o.IsDBNull(0) ? (int?)null : o.GetInt32(0), Donem: o.GetInt16(1), Durum: o.GetInt16(2)), ct);
        var planId = await veri.TekDegerAsync<int>("select id from public.ai_plan where kod = 'baslangic'", []);
        long ok = 0, red = 0;
        try
        {
            ok = await veri.TekDegerAsync<long>("""
                insert into public.ai_siparis (tur, plan_id, donem_ay, kontor, tutar, kdv, toplam, odeme_saglayici)
                values (1, @p0, 1, 500, 890, 178, 1068, 'test') returning id
                """, [planId]);
            red = await veri.TekDegerAsync<long>("""
                insert into public.ai_siparis (tur, plan_id, donem_ay, kontor, tutar, kdv, toplam, odeme_saglayici)
                values (1, @p0, 1, 500, 890, 178, 1068, 'test') returning id
                """, [planId]);

            await using var b = await veri.AcAsync(ct);
            var s1 = await AiKontorUclari.SiparisSonuclandirAsync(b, ok, true, "T1", "4242", "", ct);
            var s2 = await AiKontorUclari.SiparisSonuclandirAsync(b, ok, true, "T1", "4242", "", ct);
            Assert.Equal(2, s1.Durum);
            Assert.Equal(eskiBakiye + 500, s1.YeniBakiye);
            Assert.Equal(eskiBakiye + 500, s2.YeniBakiye);   // ikinci bildirim: yükleme YOK
            Assert.StartsWith("GYZ-", s1.FaturaNo);
            Assert.Equal(1, await veri.TekDegerAsync<long>(
                "select count(*) from public.ai_kontor_hareket where siparis_id = @p0", [ok]));
            Assert.Equal(1, await veri.TekDegerAsync<short>("select durum from public.ai_abonelik where id = 1", []));
            Assert.Equal(planId, await veri.TekDegerAsync<int>("select plan_id from public.ai_abonelik where id = 1", []));

            var s3 = await AiKontorUclari.SiparisSonuclandirAsync(b, red, false, "T2", "", "Kart reddedildi", ct);
            Assert.Equal(3, s3.Durum);
            Assert.Equal(eskiBakiye + 500, s3.YeniBakiye);

            await veri.CalistirAsync("update public.ai_kontor set oz_tani = 0 where id = 1", []);
            var (izin, _, sebep) = await RehberServisi.KontorDurumAsync(b, ct, "tani", 1);
            Assert.False(izin);
            Assert.Contains("kapalı", sebep);
        }
        finally
        {
            await veri.CalistirAsync("delete from public.ai_kontor_hareket where siparis_id in (@p0, @p1)", [ok, red]);
            await veri.CalistirAsync("delete from public.ai_siparis where id in (@p0, @p1)", [ok, red]);
            await veri.CalistirAsync("update public.ai_kontor set bakiye = @p0, oz_tani = @p1 where id = 1", [eskiBakiye, eskiOz]);
            if (ab.Count == 1)
                await veri.CalistirAsync("update public.ai_abonelik set plan_id = @p0, donem_ay = @p1, durum = @p2 where id = 1",
                    [ab[0].Plan, ab[0].Donem, ab[0].Durum]);
        }
    }
}
