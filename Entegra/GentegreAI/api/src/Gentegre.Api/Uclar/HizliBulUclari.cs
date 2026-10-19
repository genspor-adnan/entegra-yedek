using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// HIZLI BUL (kullanıcı 16.10.2026: "ekranlar ve menüler gittikçe artıyor, hızlı / kolay erişim" ·
/// "2: kayıt numarasıyla doğrudan açma"). Komut paletine (Ctrl+K) yazılan NUMARA ile kayıt bulunur:
/// hasta dosya no / TC kimlik, başvuru protokol no, muayene no, reçete no, muayene rapor no, lab istem
/// no. Ekran sorulmadan kartı açılır.
///
/// Her tür KENDİ veri yetkisine bağlı (yetkisi olmayana o türden satır dönmez) ve şube kolonu olan
/// kayıtlar aktif şubeyle süzülür. Eşleşme TAM numara ya da numaranın baştan yazılışıdır (en az 4
/// karakter); ad araması burada yok - o liste ekranlarının işi.
/// </summary>
public static class HizliBulUclari
{
    public static void HizliBulUclariniEkle(this IEndpointRouteBuilder yol)
    {
        yol.MapGet("/api/hizli-bul", async (string? q, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var metin = (q ?? "").Trim();
            if (metin.Length < 4 || metin.Length > 30) return Results.Ok(new { sonuclar = Array.Empty<object>() });
            var bas = metin.ToUpperInvariant() + "%";
            var sube = baglam.SubeId ?? 0;
            var y = baglam.Yetkiler;

            var parcalar = new List<string>();
            if (y.Var("hasta", Islem.Gor))
                parcalar.Add("""
                    (select 'hasta', t.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Hasta · ' || t.kod
                       from public.taraf t
                      where t.grup = 101 and (upper(t.kod) like @p0 or t.vkno = @p1)
                      order by t.id desc limit 5)
                    """);
            if (y.Var("belge", Islem.Gor))
                parcalar.Add("""
                    (select 'basvuru', b.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Başvuru · ' || b.belge_no || ' · ' || to_char(b.belge_tarihi, 'DD.MM.YYYY')
                       from public.belge b join public.taraf t on t.id = b.taraf_id
                      where b.tur = 19 and b.tipi = 30 and upper(b.belge_no) like @p0
                        and (@p2 = 0 or b.sube_id = @p2)
                      order by b.id desc limit 5)
                    """);
            if (y.Var("muayene", Islem.Gor))
            {
                parcalar.Add("""
                    (select 'muayene', m.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Muayene · ' || m.muayene_no
                       from public.muayene m join public.taraf t on t.id = m.taraf_id
                      where upper(m.muayene_no) like @p0 and (@p2 = 0 or m.sube_id = @p2)
                      order by m.id desc limit 5)
                    """);
                parcalar.Add("""
                    (select 'recete', r.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Reçete · ' || r.recete_no
                       from public.recete r join public.taraf t on t.id = r.hasta_id
                      where upper(r.recete_no) like @p0 and (@p2 = 0 or r.sube_id = @p2)
                      order by r.id desc limit 5)
                    """);
                parcalar.Add("""
                    (select 'rapor', r.muayene_id, r.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Rapor · ' || r.rapor_no
                       from public.muayene_rapor r join public.taraf t on t.id = r.hasta_id
                      where upper(r.rapor_no) like @p0 and (@p2 = 0 or r.sube_id = @p2)
                      order by r.id desc limit 5)
                    """);
            }
            if (y.Var("lab", Islem.Gor))
                parcalar.Add("""
                    (select 'lab', l.id, 0, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                            'Lab istemi · ' || l.istem_no
                       from public.lab_istem l join public.taraf t on t.id = l.taraf_id
                      where upper(l.istem_no) like @p0 and (@p2 = 0 or l.sube_id = @p2)
                      order by l.id desc limit 5)
                    """);
            if (parcalar.Count == 0) return Results.Ok(new { sonuclar = Array.Empty<object>() });

            var sonuclar = await veri.ListeAsync(string.Join(" union all ", parcalar),
                [bas, metin, sube],
                o => new { tur = o.GetString(0), id = o.GetInt32(1), altId = o.GetInt32(2), ad = o.GetString(3), bilgi = o.GetString(4) },
                iptal);
            return Results.Ok(new { sonuclar = sonuclar.Take(15) });
        }).RequireAuthorization().WithTags("Hızlı bul");

        // ------------------------------------------------------------ cümle komutu --
        // "ERCAN TEMEL HASTA KARTI AÇ" (kullanıcı 19.10.2026: "ctrl k aramada 'Ercan Temel hasta kartı aç'
        //   deyince açsın.. en son gelen", "hep o modülle ilgili son işlemi getirmeli"). Ad kelime kelime
        //   eşleşir (fn_ara_metin: Türkçe harf duyarsız, liste aramasıyla aynı); modül o hastanın EN SON
        //   kaydını verir. Birden çok hasta eşleşirse o modülde en son işlemi olan kazanır. Her modül kendi
        //   veri yetkisine bağlı; şube kolonu olan kayıt aktif şubeyle süzülür.
        yol.MapGet("/api/hizli-bul/son", async (string? ad, string? modul, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            var kelimeler = (ad ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .Where(k => k.Length >= 2).Take(5).ToList();
            if (kelimeler.Count == 0) return Results.Ok(new { sonuc = (object?)null });
            var y = baglam.Yetkiler;
            var (yetki, sql) = (modul ?? "") switch
            {
                "hasta" => ("hasta", """
                    select 'hasta', h.id, h.ad, 'Hasta · ' || h.kod
                      from h
                     order by (select max(b.belge_tarihi) from public.belge b
                                where b.taraf_id = h.id and b.tur = 19 and b.tipi = 30) desc nulls last, h.id desc
                     limit 1
                    """),
                "basvuru" => ("belge", """
                    select 'basvuru', b.id, h.ad, 'Son başvuru · ' || b.belge_no || ' · ' || to_char(b.belge_tarihi, 'DD.MM.YYYY')
                      from public.belge b join h on h.id = b.taraf_id
                     where b.tur = 19 and b.tipi = 30 and (@p0 = 0 or b.sube_id = @p0)
                     order by b.belge_tarihi desc, b.id desc limit 1
                    """),
                "randevu" => ("randevu", """
                    select 'randevu', r.id, h.ad, 'Son randevu · ' || to_char(r.baslangic, 'DD.MM.YYYY HH24:MI')
                      from public.randevu r join h on h.id = r.hasta_id
                     where (@p0 = 0 or r.sube_id = @p0)
                     order by r.baslangic desc, r.id desc limit 1
                    """),
                "muayene" => ("muayene", """
                    select 'muayene', m.id, h.ad, 'Son muayene · ' || m.muayene_no
                      from public.muayene m join h on h.id = m.taraf_id
                     where m.tur <> 3 and (@p0 = 0 or m.sube_id = @p0)
                     order by m.id desc limit 1
                    """),
                "recete" => ("muayene", """
                    select 'recete', r.id, h.ad, 'Son reçete · ' || r.recete_no
                      from public.recete r join h on h.id = r.hasta_id
                     where (@p0 = 0 or r.sube_id = @p0)
                     order by r.id desc limit 1
                    """),
                "lab" => ("lab", """
                    select 'lab', l.id, h.ad, 'Son lab istemi · ' || l.istem_no
                      from public.lab_istem l join h on h.id = l.taraf_id
                     where (@p0 = 0 or l.sube_id = @p0)
                     order by l.id desc limit 1
                    """),
                _ => ("", ""),
            };
            if (sql == "") throw GentegreHatasi.Dogrulama("Bilinmeyen modül.");
            if (!y.Var(yetki, Islem.Gor)) throw GentegreHatasi.Yasak("Bu kayda yetkiniz yok.");

            // Hasta adayları: her kelime adın / soyadın / unvanın içinde (sabit SQL, kelimeler parametre).
            // NUMARA (kullanıcı 19.10.2026: "hasta adı dışında kimlik no veya tel no da olabilir"): ad yerine
            //   rakam içeren bir değer yazıldıysa (TC kimlik, telefon, dosya no) kelimeler birleşip tek değer
            //   olur: kimlik no TAM, dosya no TAM, telefon rakamları (cep / sabit) İÇİNDE.
            var numara = kelimeler.Any(k => k.Any(char.IsDigit));
            string kosul;
            if (numara)
            {
                var deger = string.Concat(kelimeler);
                kelimeler = [deger];
                kosul = "(t.vkno = @p1 or upper(t.kod) = upper(@p1)"
                      + " or (length(public.fn_telefon_rakam(@p1)) >= 7 and (public.fn_telefon_rakam(t.cep_tel) like '%' || public.fn_telefon_rakam(@p1) || '%'"
                      + " or public.fn_telefon_rakam(t.telefon) like '%' || public.fn_telefon_rakam(@p1) || '%')))";
            }
            else
                kosul = string.Join(" and ", kelimeler.Select((_, i) =>
                    $"public.fn_ara_metin(coalesce(t.ad, '') || ' ' || coalesce(t.soyad, '') || ' ' || coalesce(t.unvan, '')) like '%' || public.fn_ara_metin(@p{i + 1}) || '%'"));
            var tam = $"""
                with h as (select t.id, t.kod, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), '') as ad
                             from public.taraf t where t.hasta = 1 and {kosul})
                {sql}
                """;
            var par = new List<object?> { baglam.SubeId ?? 0 };
            par.AddRange(kelimeler);
            var sonuc = (await veri.ListeAsync(tam, par,
                o => new { tur = o.GetString(0), id = o.GetInt32(1), altId = 0, ad = o.GetString(2), bilgi = o.GetString(3) },
                iptal)).FirstOrDefault();
            return Results.Ok(new { sonuc });
        }).RequireAuthorization().WithTags("Hızlı bul");
    }
}
