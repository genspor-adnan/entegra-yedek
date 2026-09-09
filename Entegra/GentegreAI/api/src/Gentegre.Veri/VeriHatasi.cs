using Gentegre.Cekirdek.Sozlesme;
using Npgsql;

namespace Gentegre.Veri;

/// <summary>
/// PostgreSQL kisit ihlallerini sozlesme hatasina cevirir. Aksi halde kullanici
/// "Beklenmeyen bir hata olustu" goruyor ve HANGI alanin sorunlu oldugunu ogrenemiyor
/// (gercek vaka: yeni cari kaydinda durum kolonuna null gidince 500 donuyordu).
/// </summary>
public static class VeriHatasi
{
    public static GentegreHatasi? Cevir(PostgresException h) => h.SqlState switch
    {
        // not null violation
        "23502" => GentegreHatasi.Dogrulama(
            $"{Alan(h)} bos birakilamaz.",
            new AlanHatasi(Alan(h), "Zorunlu alan.")),

        // unique violation
        "23505" => GentegreHatasi.IsKurali(BenzersizMesaji(h)),

        // foreign key violation
        "23503" => GentegreHatasi.IsKurali(BagMesaji(h)),

        // check violation
        "23514" => GentegreHatasi.Dogrulama(KuralMesaji(h)),

        // string too long
        "22001" => GentegreHatasi.Dogrulama("Girilen deger alanin izin verdiginden uzun."),

        // numeric/tarih cevrim hatasi
        "22P02" or "22003" => GentegreHatasi.Dogrulama("Sayisal ya da tarih degeri cozulemedi."),

        // DB tetikleyicilerinin bilerek firlattigi IS KURALI (bkz. kasa motoru,
        //   depo kurallari): mesaj kullaniciya gosterilmek uzere yazilmistir.
        "GK422" => GentegreHatasi.IsKurali(h.MessageText),

        _ => null
    };

    /// <summary>
    /// Bilinen benzersizlik kisitlari icin kullanicinin anlayacagi mesaj. Ham kisit
    /// adi ("ux_depo_ad") kullaniciya bir sey anlatmiyor.
    /// </summary>
    private static readonly Dictionary<string, string> BenzersizMesajlari = new(StringComparer.Ordinal)
    {
        ["ux_depo_ad"] = "Bu depo adı zaten kullanılıyor.",
        ["ux_depo_varsayilan"] = "Yalnizca bir depo varsayilan olabilir.",
        ["ux_stok_paket_satir"] = "Bu ürün pakete zaten eklenmiş - satırdaki adedi değiştirin.",
        ["ux_hizmet_paket_satir"] = "Bu tetkik panele zaten eklenmiş - satırdaki adedi değiştirin.",
        ["ux_firsat_no"] = "Bu fırsat numarası zaten kullanılıyor.",
        ["ux_stok_uts_stok"] = "Bu stokun ÜTS bilgisi zaten var.",
        // Kasa atamasi (197/198): ham index adi kullaniciya bir sey soylemiyordu.
        ["ux_hesap_ana_kasa"] = "Bu şubede zaten bir Ana Kasa var; önce onun atamasını kaldırın.",
        ["ux_hesap_personel_kasa"] = "Bu personelin zaten bir kasası var; bir personel tek kasaya atanabilir.",
        // Fiyat listesi (204): yon basina TEK varsayilan.
        ["ux_fiyat_listesi_varsayilan"] = "Bu yönde zaten bir varsayılan liste var; önce onun \"Varsayılan\" işaretini kaldırın.",
        ["ux_fiyat_listesi_ad"] = "Bu adda bir fiyat listesi zaten var."
    };

    /// <summary>
    /// Bilinen CHECK kisitlari icin kullanicinin anlayacagi mesaj. Ham kisit adi
    /// ("ck_stok_paket_kendisi") kullaniciya bir sey anlatmiyordu - ekranda
    /// "Deger kurala uymuyor" yazip birakiyorduk.
    /// </summary>
    private static readonly Dictionary<string, string> KuralMesajlari = new(StringComparer.Ordinal)
    {
        ["ck_stok_paket_kendisi"] = "Paket kendi kendisini içeremez.",
        ["ck_stok_paket_adet"]    = "Paket içeriğinde adet sıfırdan büyük olmalı.",
        ["ck_firsat_olasilik"]    = "Olasılık 0 ile 100 arasında olmalı.",
        ["ck_cek_senet_kur"]      = "Kur sıfırdan büyük olmalı.",
        ["ck_gorev_ilerleme"]     = "İlerleme 0 ile 100 arasında olmalı.",
        // HASTA KIMLIK ZORUNLULUKLARI (480): ikisi de sonucun yorumunu
        //   degistirir - referans araligi ve hizmet uygunlugu bunlara bakar.
        ["ck_taraf_hasta_dogum_zorunlu"]    =
            "Hastanın doğum tarihi zorunlu (yalnız kimliksiz hastada boş bırakılabilir).",
        ["ck_taraf_hasta_cinsiyet_zorunlu"] = "Hastanın cinsiyeti seçilmeli (Erkek / Kadın).",
        ["ck_taraf_hasta_dogum_akilli"]     =
            "Doğum tarihi geçersiz: gelecek bir tarih ya da 130 yaştan büyük olamaz.",
        // 175'te kaldirildi; eski kurulumda hala olabilir - ham kisit adi yerine
        //   ne yapilmasi gerektigini soyler.
        ["ck_sube_efatura"]       = "e-Fatura mükellefi şubede VKN ve gönderici etiketi dolu olmalı.",
        // TETKIK CALISMA DUZENI (486): seri duzeninde gun ve saat olmadan
        //   sonuc zamani hesaplanamaz. Ham kisit adi ekranda "Deger kurala
        //   uymuyor" diye cikiyor, kullanici NEYI duzeltecegini bilemiyordu -
        //   kayit sessizce eski degerinde kaliyordu (gercek vaka: "calisma
        //   zamani degistiriyorum ama listede surekli ayni").
        ["ck_lab_tetkik_seri_tanimli"] =
            "Seri düzeninde çalışma günü ve saati zorunlu: en az bir gün seçin "
            + "ve saat yazın (örn. 09:00,15:00). Tetkik her an çalışılıyorsa "
            + "düzeni \"Sürekli\" yapın.",
        ["ck_lab_tetkik_calisma_duzeni"] =
            "Çalışma düzeni geçersiz (Sürekli · Mesai içi · Belirli günlerde).",
        ["ck_hizmet_yas_araligi"] =
            "En küçük yaş, en büyük yaştan büyük olamaz."
    };

    /// <summary>
    /// Bilinen FK kisitlari icin kullanicinin ANLAYACAGI ve NE YAPACAGINI
    /// soyleyen mesaj. Ham metin ("baska kayitlar tarafindan kullaniliyor")
    /// hangi kaydin engellendigini de cikis yolunu da soylemiyordu: kullanici
    /// kurum kartindan sozlesmeyi siliyor, Kaydet calismiyor ve sebebi
    /// goremiyordu (gercek vaka).
    /// </summary>
    private static readonly Dictionary<string, string> BagMesajlari = new(StringComparer.Ordinal)
    {
        ["belge_basvuru_sozlesme_id_fkey"] =
            "Bu sözleşme başvurularda kullanılmış, silinemez. Kullanımdan kaldırmak için "
            + "satırdaki \"Aktif\" işaretini kaldırın - eski başvurular hangi sözleşmeyle "
            + "açıldığını göstermeye devam eder.",
        ["belge_basvuru_odeyen_kurum_id_fkey"] =
            "Bu kurum başvurularda kullanılmış, silinemez. Kullanımdan kaldırmak için "
            + "kurumu Pasif yapın.",
        ["kurum_sozlesme_kurum_id_fkey"] =
            "Kurumun sözleşmeleri var; önce sözleşmeleri kaldırın.",
    };

    private static string BagMesaji(PostgresException h)
        => h.ConstraintName is not null && BagMesajlari.TryGetValue(h.ConstraintName, out var m)
            ? m
            : "Bağlantılı kayıt bulunamadı ya da bu kayıt başka kayıtlarda kullanıldığı için "
              + $"silinemiyor{(h.ConstraintName is null ? "" : $" ({h.ConstraintName})")}.";

    private static string KuralMesaji(PostgresException h)
        => h.ConstraintName is not null && KuralMesajlari.TryGetValue(h.ConstraintName, out var m)
            ? m
            : $"Deger kurala uymuyor{(h.ConstraintName is null ? "" : $" ({h.ConstraintName})")}.";

    private static string BenzersizMesaji(PostgresException h)
        => h.ConstraintName is not null && BenzersizMesajlari.TryGetValue(h.ConstraintName, out var m)
            ? m
            : $"Ayni kayit zaten var{(h.ConstraintName is null ? "" : $" ({h.ConstraintName})")}.";

    /// <summary>PG kolon adi (snake_case) -> API alan adi (camelCase).</summary>
    private static string Alan(PostgresException h)
    {
        var kolon = h.ColumnName;
        if (string.IsNullOrEmpty(kolon)) return "alan";

        var sonuc = new System.Text.StringBuilder(kolon.Length);
        var buyuk = false;
        foreach (var c in kolon)
        {
            if (c == '_') { buyuk = true; continue; }
            sonuc.Append(buyuk ? char.ToUpperInvariant(c) : c);
            buyuk = false;
        }
        return sonuc.ToString();
    }
}
