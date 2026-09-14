namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// GİRİŞ KAYITLARI (674, kullanıcı: "login bilgileri de log da tutulsun").
///
/// Kayıt zaten tutuluyordu (<c>giris_denemesi</c>; KimlikServisi her denemede
/// yazar) - eksik olan OKUNABİLMESİYDİ. Tutulup bakılmayan kayıt, tutulmamış
/// kayıtla aynı şeydir.
///
/// BAŞARISIZ deneme de listelenir ve asıl değer oradadır: aynı koda arka arkaya
/// gelen "parola hatalı" satırları deneme-yanılma, aynı IP'den farklı kodlar
/// tarama demektir. Yalnız başarılı girişleri göstermek, görülmesi gereken tek
/// şeyi gizlerdi.
/// </summary>
public static partial class KaynakKatalogu
{
    private static KaynakTanimi GirisLog() => new(
        Ad: "giris-log",
        // İşlem günlüğüyle AYNI yetki: ikisi de denetim kaydı, ayrı bir yetki
        //   kodu "logu görebilen ama girişleri göremeyen" yapay bir rol üretirdi.
        YetkiKodu: "islem_log",
        Kaynak: """
            public.giris_denemesi g
            left join public.taraf k on k.id = g.kullanici_id
            left join public.taraf_kullanici tk on tk.id = g.kullanici_id
            """,
        VarsayilanSirala: "g.tarih desc, g.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id", "g.id", "sayi", "Id", Varsayilan: false),
            // 667: timestamptz - ELLE SAAT KAYMASI KALKTI; islem logu ile ayni
            //   kural, ikisi yan yana okunuyor. Gosterimi istemci subenin saat
            //   diliminde yapar; kayma birakilsaydi saat iki kez kaydirilirdi.
            new("tarih", "g.tarih", "tarih", "Tarih", Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm:ss"),
            new("sonuc", "case when g.basarili = 1 then 'Başarılı' else 'Başarısız' end",
                "metin", "Sonuç", Hizalama: "orta", Bicim: "rozet"),
            // Cip filtreleri ham kodla calisir (metin case'i degil).
            new("basarili", "g.basarili", "kod", "Sonuç Kodu", Hizalama: "orta",
                Varsayilan: false),
            // GIRISE YAZILAN metin: kullanici kodu / sicil / e-posta / cep /
            //   TCKN / ad soyad. Kullanici bulunamadiginda tek ipucu budur.
            new("kod", "g.kod", "metin", "Girilen Kimlik"),
            new("kullanici", "coalesce(k.unvan, '')", "metin", "Kullanıcı"),
            new("kullaniciKod", "coalesce(tk.kod, '')", "metin", "Kullanıcı Kodu",
                Varsayilan: false),
            new("sebep", SebepIfade(), "metin", "Ayrıntı"),
            new("ip", "g.ip", "metin", "IP"),
            new("istemci", "g.istemci", "metin", "İstemci", Varsayilan: false),
            new("kullaniciId", "g.kullanici_id", "sayi", "Kullanıcı Id", Varsayilan: false),
        });

    /// <summary>KimlikServisi'nin yazdigi ham sebep kodlari okunabilir metne.</summary>
    private static string SebepIfade() => """
        case g.sebep
            when ''                then ''
            when 'yok'             then 'Kullanıcı bulunamadı'
            when 'belirsiz'        then 'Birden fazla kullanıcı eşleşti'
            when 'parola'          then 'Parola hatalı'
            when 'pasif'           then 'Hesap pasif'
            when 'kilitli'         then 'Hesap kilitli'
            when 'ilk_parola'      then 'İlk parola belirleme'
            when 'ilk_parola_tckn' then 'İlk parola - kimlik doğrulaması hatalı'
            when 'giris'           then 'Giriş'
            when 'sube'            then 'Şube değişimi'
            when 'yenile'          then 'Oturum yenileme'
            else g.sebep
        end
        """;
}
