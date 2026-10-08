using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Laboratuvar (istem, sonuc, kalite kontrol, mikrobiyoloji) ve e-Nabiz.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleLab(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // LAB v1 (433/434). Tetkik ve panel sirandan CRUD; numune, sonuc
        //   ve cihaz eslemesi is akisi dugmeleri tasir.
        // LAB ISTEM (360 + 433): kart CRUD'u + kartla acilan isteme barkod
        //   uretimi. Uc uzerinden acilan istemde tup plani zaten calisir.
        s["lab-istem-liste"] =
        [
            // "Yeni İstem" YOK (kullanıcı kuralı, radyolojiyle aynı): lab
            //   istemi YALNIZ başvurudan açılır - kayıt-kabul (dış kurum →
            //   başvuru + istem) ya da muayeneden hekim isteği. Boş kart
            //   başvurusuz (ücretsiz/ödeyensiz) istem üretirdi. Crud'un
            //   "yeni"si bu yüzden alınmadı; düzenle/sil/yazdır elle.
            new("lab-istem.duzenle", "✎ Aç / Düzenle", "lab-istem", Kisayol: "Enter",
                KaynakKodu: "lab", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("lab-istem.sil", "🗑 Sil", "lab-istem", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "lab", Islem: Islem.Sil, KayitGerekir: true, Sira: 30),
            Yazdir(),
            // REFLEKTİF İSTEM (873 §7): lab uzmanı sonuç sonrası ek tetkik ister.
            new("lab.reflektif", "🔁 Reflektif tetkik ekle", "lab", Hedef: "araccubugu2,sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 45, UrunModu: 2,
                Ipucu: "Laboratuvar uzmanı: sonuç sonrası ek tetkik (kayıt 'Laboratuvar Uzmanı Reflektif İstemi')."),
            // DIS NUMUNE ICIN AYRI DUGME YOK (kullanici: "dis numune
            //   kabul butona gerek kalmadi, yeni istem den girebiliyoruz").
            //   Istem kartinin kaynak varsayilani "Dis kurum"; gonderen
            //   kurum ve dis doktor arama penceresiyle seciliyor. Ayni isi
            //   yapan ikinci bir pencere, iki ayri dogrulama yolu demekti.
            // SONUC ELLE GIRISI (433, kullanici: "lab istem sonuclarini
            //   elle girmek istiyorum"). Uc ve kural motoru vardi,
            //   EKRANI yoktu. Istemin butun tetkikleri tek pencerede -
            //   hemogram 23 parametre, her biri icin ayri pencere
            //   teknisyeni 23 kez tiklatirdi.
            new("lab.sonuc-gir", "🧪 Sonuç Gir", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 4),
            new("lab.numune-plani", "🏷 Barkod Üret", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 40),
            // Kultur tetkiginin EKIMI istem satirindan baslar (436):
            //   ayri bir "kultur ac" ekrani, teknisyeni ayni kaydin iki
            //   yuzu arasinda gezdirirdi.
            new("lab.ekim", "🧫 Ekim Yap (kültür)", "lab-istem",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 50),
            // SONUC RAPORU: hastaya verilen belge. Istem numarasiyla
            //   acilir - ayni istemdeki sayisal sonuc, kultur ve genetik
            //   TEK kagida basilir.
            // ETIKET: istemin TUM tupleri tek sayfada basilir - kan alma
            //   bankosu tupleri birlikte hazirlar.
            // BARKOD OKUT (mockup "📷 Barkod Okut"): bankonun asil giris
            //   yolu. Teknisyen elindeki tupu okutur, istem KENDILIGINDEN
            //   bulunur - listede ad aramak, ayni isimli iki hastada
            //   yanlis tupu kabul ettirir.
            new("lab.barkod-okut", "📷 Barkod Okut", "lab-istem",
                Hedef: "araccubugu,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: false,
                Sira: 20),
            new("lab.etiket", "🏷 Etiket Bas", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: true,
                Sira: 25),
            // KABUL / RET ISTEM DUZEYINDE: bir hastanin dort tupu birlikte
            //   alinir ve birlikte kabul edilir (mockup araç çubuğu).
            //   Tup bazli islem Numune Kabul ekraninda kalir.
            // AD KISA, RENK AYIRT EDICI (kullanici): "Kabul" yesil,
            //   "Ret" kirmizi. Ikisi yan yana duran KARSIT eylemdir;
            //   ayni renkte iki uzun etiket, acele eden bir kullaniciya
            //   yanlis dugmeye bastirir - ve ret geri alinmaz.
            new("lab.istem-kabul", "✔ Kabul", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 27, Bicim: "onay"),
            new("lab.istem-ret", "✖ Ret", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 28, Bicim: "ret"),
            new("lab.rapor", "🖨 Sonuç Raporu", "lab-istem",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
            new("lab.genetik-vaka", "🧬 Genetik Vaka Aç", "lab-istem",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 55),
            // Numune kabul ekranindakiyle AYNI kod: sevk mantigi tek
            //   yerde (disLabAksiyonlari) kalir, dugme iki listede durur.
            new("lab.dis-gonder", "🏍️ Dış Lab'a Gönder", "lab-istem",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 60),
            // SAKLAMA YERI: calisilmayi bekleyen tup nerede? Kayitsiz
            //   buzdolabi, tekrar calisma gerektiginde numuneyi
            //   bulunamaz hale getirir (mockup "🧊 Saklama Yeri").
            new("lab.saklama", "🧊 Saklama Yeri", "lab-istem",
                Hedef: "araccubugu2,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 65),
        ];

        // MIKROBIYOLOJI (436). Kultur bir SUREC: her adim ayri dugme.
        //   Tek "kaydet" dugmesi, hangi asamada olundugunu gizlerdi.
        //   Yapilamayacak adim GIZLENMEZ - sunucu sebebini soyler.
        s["lab-kultur-liste"] =
        [
            new("lab.kultur-okuma", "👁 Okuma Kaydet", "lab-kultur",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.kultur-izolat", "🔬 İzolat / İdentifikasyon", "lab-kultur",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            new("lab.kultur-antibiyogram", "💊 Antibiyogram", "lab-kultur",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 30),
            new("lab.kultur-on-rapor", "📄 Ön Rapor (Gram)", "lab-kultur",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 40),
            new("lab.kultur-rapor", "🖨 Sonuç Raporu", "lab-kultur",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 45),
            new("lab.kultur-onayla", "✔ Raporu Onayla", "lab-kultur",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 50),
            new("lab.kultur-iptal", "✖ Kültürü İptal Et", "lab-kultur",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.kultur", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 60),
            Yazdir(),
        ];

        // GENETIK (439). Vaka bir SUREC: onam -> izolasyon -> run ->
        //   varyant -> dogrulama -> onay. ONAM ayri dugme cunku raporun
        //   on kosulu (KVKK md. 6) ve tesadufi bulgu tercihi raporlamayi
        //   dogrudan degistirir.
        s["lab-genetik-liste"] =
        [
            new("lab.genetik-onam", "📋 Onam Kaydet", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.genetik-izolasyon", "🧪 DNA İzolasyon", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            new("lab.genetik-run", "📚 Run'a Al", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 30),
            new("lab.genetik-kalite", "📊 Kalite Metrikleri", "lab-genetik-vaka",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 40),
            new("lab.genetik-varyant", "🧬 Varyant Ekle", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 50),
            new("lab.genetik-rapor", "🖨 Sonuç Raporu", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab", Islem: Islem.Gor, KayitGerekir: true, Sira: 55),
            new("lab.genetik-onayla", "✔ Raporu Onayla", "lab-genetik-vaka",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 60),
            new("lab.genetik-iptal", "✖ Vakayı İptal Et", "lab-genetik-vaka",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 70),
            Yazdir(),
        ];

        // VARYANT HAVUZU: sinif ezme ve Sanger dogrulama.
        s["lab-varyant-liste"] =
        [
            new("lab.varyant-sinif", "🏷 Sınıfı Değiştir (uzman)", "lab-varyant",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 10),
            new("lab.varyant-dogrulama", "🔁 Sanger Doğrulama", "lab-varyant",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.genetik", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            Yazdir(),
        ];

        s["lab-genetik-run-liste"] = [Yazdir()];
        // KALITE KONTROL (442). Olcumun kendi karti yok; girise ve
        //   duzeltici faaliyete uctan gidilir. RET satirinda aksiyon
        //   zorunlu (ISO 15189) - kapatilmamis ret listede kalir.
        s["lab-kk-liste"] =
        [
            new("lab.kk-olcum", "＋ KK Sonucu (elle)", "lab-kk-olcum",
                Hedef: "araccubugu,palet",
                KaynakKodu: "lab.kk", Islem: Islem.Ekle, Sira: 10),
            new("lab.kk-aksiyon", "🛠 Düzeltici Faaliyet", "lab-kk-olcum",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.kk", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            new("lab.kk-grafik", "📈 Levey-Jennings", "lab-kk-olcum",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.kk", Islem: Islem.Gor, KayitGerekir: true,
                Sira: 30),
            Yazdir(),
        ];

        s["lab-kk-lot-liste"] = Crud("lab-kk-lot", "lab-kk-lot", "lab.kk");
        s["lab-kk-kural-liste"] = Crud("lab-kk-kural", "lab-kk-kural", "lab.kk");
        s["lab-dkk-liste"] = Crud("lab-dkk", "lab-dkk", "lab.kk");
        s["lab-cihaz-olay-liste"] =
            Crud("lab-cihaz-olay", "lab-cihaz-olay", "lab.kk");
        s["lab-indeks-esik-liste"] =
            Crud("lab-indeks-esik", "lab-indeks-esik", "lab.tetkik");

        // DIS LABORATUVAR (445). Gonderim bir surec: her adim ayri dugme.
        //   "Sonuc Gir" burada cunku dis lab sonucu PDF/portal ile gelir
        //   ve elle yazilir; oto-onaya girmez.
        s["lab-dis-gonderim-liste"] =
        [
            new("lab.dis-yolda", "🚚 Yola Çıktı", "lab-dis-gonderim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.dis-teslim", "📦 Teslim Edildi", "lab-dis-gonderim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            new("lab.dis-sonuc", "🧾 Sonuç Gir", "lab-dis-gonderim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 30),
            new("lab.dis-ret", "✖ Dış Lab Reddetti", "lab-dis-gonderim",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 40),
            new("lab.dis-fatura", "🧾 Alış Faturası Eşleştir", "lab-dis-gonderim",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 50),
            Yazdir(),
        ];

        s["lab-dis-lab-liste"] = Crud("lab-dis-lab", "lab-dis-lab", "lab.dislab");

        s["lab-gen-liste"] = Crud("lab-gen", "lab-gen", "lab.gen");
        s["lab-genetik-panel-liste"] =
            Crud("lab-genetik-panel", "lab-genetik-panel", "lab.gen");

        s["lab-besiyeri-liste"] = Crud("lab-besiyeri", "lab-besiyeri", "lab.mikro");
        s["lab-organizma-liste"] = Crud("lab-organizma", "lab-organizma", "lab.mikro");
        s["lab-antibiyotik-liste"] =
            Crud("lab-antibiyotik", "lab-antibiyotik", "lab.mikro");

        s["lab-tetkik-liste"] = Crud("lab-tetkik", "lab-tetkik", "lab.tetkik");
        // AKILCI TEST İSTEMİ (873): kural kataloğu, refleks kuralları; karar günlüğü salt okunur.
        s["lab-akilci-kural-liste"] = Crud("lab-akilci-kural", "lab-akilci-kural", "lab.tetkik");
        s["lab-refleks-kural-liste"] = Crud("lab-refleks-kural", "lab-refleks-kural", "lab.tetkik");
        s["lab-akilci-gerekce-liste"] =
        [
            new("genel.yazdir", "🖨️ Yazdır", "lab", Hedef: "araccubugu2,palet", Sira: 90, UrunModu: 2),
        ];
        s["lab-panel-liste"] = Crud("lab-panel", "lab-panel", "lab.tetkik");
        // BILDIRIM SABLONLARI (399): kart vardi ama ekran ARAC CUBUGU
        //   tanimli degildi - kullanici kayit ekleyemiyor, bunu "yetkim
        //   yok" saniyordu. Kod SABIT (kodla cagrilir), metin serbest.
        //   Sil ARAC CUBUGUNDA (kullanici: "ekle/duzenle/sil butonlari"):
        //   varsayilan Crud silmeyi yalniz sag tus/palete koyar.
        s["bildirim-sablon-liste"] =
            Crud("bildirim-sablon", "bildirim-sablon", "bildirim_sablon",
                 silHedef: null);

        // e-NABIZ KOD ESLEME (454): duz katalog - ekle/duzenle/sil.
        s["enabiz-kod-esleme-liste"] =
            Crud("enabiz-kod-esleme", "enabiz-kod-esleme", "entegrasyon");

        s["lab-cihaz-esleme-liste"] =
            Crud("lab-cihaz-esleme", "lab-cihaz-esleme", "lab.cihaz",
                 "＋ Yeni", silHedef: "sagtus,palet", yazdir: false);

        // NUMUNE KABUL: ret AYRI dugme ve neden ister - "kabul etmedim"
        //   ile "reddettim" farkli seylerdir; ret istem satirlarini
        //   "tekrar bekliyor"a alir, sessiz birakmak sonucu hic
        //   gelmeyen istem uretirdi.
        s["lab-numune-liste"] =
        [
            new("lab.numune-alindi", "🩸 Alındı İşaretle", "lab-numune",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.numune-kabul", "✔ Kabul Et", "lab-numune",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            new("lab.numune-ret", "✖ Reddet", "lab-numune",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 30),
            // DIS LABA GONDER: numune kabul bankosundan - tup elde
            //   iken sevk edilir (mockup: "📦 Dis Lab'a Gonder").
            new("lab.dis-gonder", "🏍️ Dış Lab'a Gönder", "lab-numune",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.dislab", Islem: Islem.Ekle, KayitGerekir: true,
                Sira: 35),
            new("lab.barkod-yazdir", "🏷 Barkod Etiketi", "lab-numune",
                Hedef: "sagtus,palet",
                KaynakKodu: "lab.numune", Islem: Islem.Gor, KayitGerekir: true,
                Sira: 40),
            Yazdir(),
        ];

        // PANIK DEGERLER (894, KTS L2): liste ACIK panikleri gosterir;
        //   kayit "bildirildi" ile DEGIL okuma-geri TEYIDI ile kapanir -
        //   telefonun acilmasi, karsi tarafin degeri tekrar etmesi
        //   demek degildir.
        s["lab-panik-liste"] =
        [
            new("lab.panik-bildir", "☎ Panik Bildirimi", "lab-panik",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.panik-teyit", "✔ Okuma-Geri Teyidi", "lab-panik",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            Yazdir(),
        ];

        // TEKRAR TALEPLERI (891, KTS L8): kuyruk yalniz IPTAL edilir -
        //   "karsilandi" durumunu SISTEM yazar (ayni satira yeni sonuc
        //   girilince). Elle kapatma dugmesi, calisilmadan kapatilmis
        //   talepler uretirdi.
        s["lab-tekrar-liste"] =
        [
            new("lab.tekrar-iptal", "✖ Talebi İptal Et", "lab-tekrar",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.tekrar", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            Yazdir(),
        ];

        // SONUC ONAY KUYRUGU: iki asama ayri dugme (teknik / uzman).
        //   Onayli sonuc GUNCELLENMEZ - "Duzelt" eski satiri iptal edip
        //   yenisini acar, bu yuzden ayri dugme.
        s["lab-sonuc-liste"] =
        [
            new("lab.teknik-onay", "✔ Teknik Onay", "lab-sonuc",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("lab.onayla", "✅ Uzman Onayı (yayınla)", "lab-sonuc",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 20),
            new("lab.duzelt", "✎ Sonucu Düzelt", "lab-sonuc",
                Hedef: "sagtus,palet",
                AksiyonYetkisi: "lab.onay", KayitGerekir: true, Sira: 30),
            new("lab.panik-bildir", "☎ Panik Bildirimi", "lab-sonuc",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "lab.sonuc", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 40),
            // TEST TEKRARI (891, KTS L8): uzman/klinisyen laboratuvara
            //   elektronik olarak tekrar isteyebilsin. Ayrı aksiyon
            //   yetkisi - sonucu GÖREBİLEN herkesin laboratuvara iş
            //   açması doğru değil.
            new("lab.tekrar-iste", "🔁 Tekrar İste", "lab-sonuc",
                Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "lab.tekrar.iste", KayitGerekir: true, Sira: 45),
            Yazdir(),
        ];

        // ITS KUYRUGU (427): gonderilmis bildirim IPTAL EDILEMEZ - ITS'de
        //   kayit olustu, geri almak ayri bir bildirim turudur (iade /
        //   deaktivasyon). Kural sunucuda, dugme yine de gosterilir ki
        //   kullanici sebebini ogrensin.
        s["its-liste"] =
        [
            new("its.gonder", "📤 Şimdi Gönder", "its-bildirim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("its.iptal", "✖ İptal Et", "its-bildirim",
                Hedef: "sagtus,palet",
                KaynakKodu: "stok", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            Yazdir(),
        ];

        // e-NABIZ KUYRUGU (415): eksik duzeltilince paket KAYNAKTAN
        //   YENIDEN URETILIR - paket satirini elle duzeltmek, gonderilen
        //   veriyle kayittaki veriyi ayirirdi.
        s["enabiz-liste"] =
        [
            new("enabiz.gonder", "📤 Şimdi Gönder", "enabiz-paket",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 5),
            new("enabiz.yeniden-uret", "↻ Kaynaktan Yeniden Üret", "enabiz-paket",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 10),
            new("enabiz.iptal", "✖ İptal Et", "enabiz-paket",
                Hedef: "sagtus,palet",
                KaynakKodu: "entegrasyon", Islem: Islem.Degistir, KayitGerekir: true,
                Sira: 20),
            Yazdir(),
        ];

        // HEKIM CALISMA LISTESI (410): gunun isi tek ekranda. Cagirma ve
        //   muayeneye alma AYRI dugmelerdir - hasta cagrilip gelmeyebilir,
        //   ikisini birlestirmek "geldi mi" sorusunu olculemez yapardi.
        s["hekim-liste"] =
        [
            new("hekim.cagir", "📢 Sıradakini Çağır", "hekim-listesi",
                Hedef: "araccubugu,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, Sira: 10),
            new("hekim.secileni-cagir", "🔔 Seçileni Çağır", "hekim-listesi",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            new("hekim.al", "🩺 Muayeneye Al", "hekim-listesi",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Ekle, KayitGerekir: true, Sira: 30),
            Yazdir(),
        ];

        // MUAYENE (409, Faz 1): hekimin gunluk isi iki dugmeye baglidir.
        //   "Muayeneye Al" baslangic zamanini yazar (USS Muayene
        //   Baslangic) - hasta ne zaman iceri girdi sorusunun tek cevabi
        //   budur; kartin acilma zamani degil. "Tamamla" kaydi KILITLER,
        //   basvuruyu tahakkuka dondurur ve e-Nabiz kuyruguna atar; bu
        //   yuzden eksik kayitta reddedilir (ana tani + sikayet + karar).
        s["muayene-liste"] =
        [
            new("muayene.al", "▶ Muayeneye Al", "muayene",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("muayene.tamamla", "✔ Tamamla", "muayene",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            // ISTEM AC ve SABLON UYGULA LISTEDE YOK (kullanici): ikisi de
            //   muayene KARTININ sekmelerinde yapiliyor (Istem & Sonuclar,
            //   Fizik Muayene). Listede tekrar etmek, hangi muayeneye
            //   uygulandigini karti acmadan gormeyi zorlastiriyordu.
            //   Aksiyon KODLARI duruyor - kart arac cubugu onlari cagiriyor.
            new("muayene.istem", "🔬 İstem Aç", "muayene",
                Hedef: "sagtus",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 25),
            new("muayene.sablon", "📋 Şablon Uygula", "muayene",
                Hedef: "sagtus",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 30),
            // Mockup fizik muayene araç çubuğu: şablonla açılmış boş
            //   satırları tek tıkla "normal" işaretler. Yazılmış bulguya
            //   dokunmaz - kural uçta.
            // Mockup tanı araç çubuğu: hastanın önceki tanıları ve
            //   hekimin sık yazdıkları - kod aramak yerine listeden seçmek
            //   aynı hastalığın iki ayrı ICD ile yazılmasını önler.
            new("muayene.taniOnceki", "🕘 Önceki Tanılar", "muayene",
                Hedef: "sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 36),
            new("muayene.taniSik", "⭐ Sık Tanılarım", "muayene",
                Hedef: "sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 37),
            new("muayene.normal", "☑ Tümü Normal", "muayene",
                Hedef: "sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 35),
            new("muayene.ozet", "🧾 Özeti Derle", "muayene",
                Hedef: "sagtus,palet",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 40),
            new("kart.duzenle", "✎ Düzenle", "muayene", Kisayol: "F2",
                KaynakKodu: "muayene", Islem: Islem.Degistir, KayitGerekir: true, Sira: 50),
            Yazdir(),
        ];

        // ILAC KATALOGU (406/407): katalog senkronla dolar, AMA FIYAT
        //   DOLMAZ - TITCK Detayli Fiyat Listesi kurumsal portal hesabi
        //   istiyor. O kapi acilana kadar fiyati elle girmenin bir yolu
        //   olmali, yoksa ilac cikisi fiyatsiz kalir.
        s["ilac-liste"] =
        [
            new("ilac.fiyat", "₺ Fiyat Gir", "ilac", Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "katalog", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            Yazdir(),
        ];

        // ZAMANLI ISLER (405): zamani beklemeden calistir + zamanlamayi
        //   duzenle. "Simdi Calistir" KayitGerekir - satir secilmeden
        //   pasif gelir; is zaten calisiyorsa sunucu ikinci kez baslatmaz.
        s["zamanli-is-liste"] =
        [
            new("zamanli-is.calistir", "▶ Şimdi Çalıştır", "zamanli-is",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "zamanli_is", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("kart.duzenle", "✎ Düzenle", "zamanli-is", Kisayol: "F2",
                KaynakKodu: "zamanli_is", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            Yazdir(),
        ];

        // BILDIRIM KUYRUGU (399): gitmeyeni yeniden dene, gitmesini
        //   istemedigini iptal et. Ikisi de KayitGerekir - satir secilmeden
        //   pasif gelir ve sebebi sunucudan yazilir. Toplu secim destekli:
        //   gece bosa dusmus butun bildirimler tek seferde denenebilsin.
        s["bildirim-liste"] =
        [
            new("bildirim.tekrar", "🔄 Tekrar Dene", "bildirim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "bildirim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 10),
            new("bildirim.iptal", "✖ İptal Et", "bildirim",
                Hedef: "araccubugu,sagtus,palet",
                KaynakKodu: "bildirim", Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            Yazdir(),
        ];

        // HASTA EKSTRESI: cikti aksiyonlari + secili satirin belgesine
        //   gidis (kullanici: "bir satiri isaretledigimde ustte Yazdır'in
        //   solunda Başvuru Aç aktif olsun"). KayitGerekir ile satir
        //   secilmeden pasif gelir - sebebi sunucudan yazilir.
        s["hasta-ekstre"] = [BasvuruAc(), Yazdir()];

        // Stok Ayarlari > Depolar sekmesi.
        s["sube-liste"] = Crud("sube", "sube", "sube", "＋ Ekle", silHedef: null, yazdir: false);

        s["hizmet-liste"] = Crud("hizmet", "hizmet", "hizmet", "＋ Ekle", silHedef: null, yazdir: false);

        s["depo-liste"] = Crud("depo", "depo", "stok", "＋ Ekle", silHedef: null, yazdir: false);

        s["belge-liste"] = new AksiyonTanimi[]
        {
            // ÜTS belge koprusu (226): satista satir basina VERME, alista
            //   askidakilerle eslesip ALMA. Sunucu tur guard'li - yalniz
            //   alis/satis irsaliye/fatura/fis. Sag tusta durur, arac
            //   cubugunu kalabaliklastirmaz.
            new("belge.uts-bildir", "🩺 ÜTS Bildir", "stok",
                Hedef: "sagtus,palet", AksiyonYetkisi: "uts.bildir",
                KayitGerekir: true, Sira: 62),
            new("belge.yeni",  "＋ Yeni",      "belge", Kisayol: "Ctrl+N",
                KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
            new("belge.ac",    "Belgeyi Ac",   "belge", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            // SIL, "Belgeyi Aç"in saginda (kullanici). Silme yalniz IZI
            //   OLMAYAN belgede mumkun; kesin/izli belgede "İptal Et".
            new("belge.sil",   "🗑 Sil",       "belge", Kisayol: "Del",
                KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
            new("belge.kesinlestir", "Kesinlestir", "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 30),
            // DONUSTUR YOK (kullanici): fatura zincirin SONU - siparis ve
            //   irsaliye faturaya donusur, fatura baska bir belgeye donusmez.
            //   Aksiyon siparis-liste ve irsaliye-liste ekranlarinda duruyor.
            new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
            // e-BELGE MENUSU (Delphi menu sirasiyla ayni, kullanici istegi):
            //   Hazırla · Ön İzle · Gönder | Seri Değiştir · Hazırı Geri Al |
            //   PDF / HTML / XML Kaydet | Mesaj Geçmişi.
            //   AYRAC: kodu "ebelge.ayrac*" olan satirlar - combo'da cizgi
            //   olarak cizilir, secilemez. Sira degerleri bosluklu ki araya
            //   yeni adim girerse numaralar yeniden yazilmasin.
            new("ebelge.hazirla", "Hazırla", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 41),
            new("ebelge.onizle", "Ön İzle", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 42),
            new("ebelge.gonder", "Gönder", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 43),
            new("ebelge.ayrac1", "─", "ebelge", Hedef: "sagtus", Sira: 44),
            new("ebelge.seri", "Seri Değiştir", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 45),
            new("ebelge.sifirla", "Hazırı Geri Al", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 46),
            // IPTAL (188): e-Arsivde dogrudan iptal, e-Faturada IPTAL TALEBI.
            //   Hangisi oldugunu sunucu belirler; kullanici tek dugme gorur.
            new("ebelge.iptal", "İptal Et / İptal Talebi", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 47),
            new("ebelge.ayrac2", "─", "ebelge", Hedef: "sagtus", Sira: 48),
            new("ebelge.pdf", "PDF Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 49),
            new("ebelge.html", "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
            new("ebelge.xml", "XML Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 51),
            new("ebelge.ayrac3", "─", "ebelge", Hedef: "sagtus", Sira: 52),
            new("ebelge.durum", "Durum Sorgula", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 53),
            new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 54),
            // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
            //   tikla fise ve zincirin iki ucuna gidilir.
            new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
            new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
            new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
            new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // GELEN e-BELGE KUTUSU (187): kutuyu yenile, icerigi gor, yanitla.
        //   "Yeni" YOK - gelen belgeyi biz uretmeyiz.
        s["gelen-belge-liste"] = new AksiyonTanimi[]
        {
            new("gelen.yenile",  "⟳ Kutuyu Yenile", "gelen",
                AksiyonYetkisi: "ebelge.gonder", Sira: 10),
            new("gelen.goruntule", "Belgeyi Görüntüle", "gelen", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("gelen.kabul",   "✓ Kabul Et",      "gelen", Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 30),
            new("gelen.red",     "✕ Reddet",        "gelen", Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 40),
            // ALIS FATURASINA AKTAR: kutu satiri muhasebeye ancak boyle girer
            //   (kutunun kendisi cari borc/alacak URETMEZ - kullanici kurali).
            //   Kabulde otomatik calisir; burada yanit gerekmeyen belgeler
            //   (temel fatura / e-Arsiv) ve tekrar denemeler icin durur.
            new("gelen.aktar",   "🧾 Faturaya Aktar", "gelen",
                KaynakKodu: "belge", Islem: Islem.Ekle, KayitGerekir: true, Sira: 25),
            // e-FATURA KOMBOSU (kullanici): giden listedekiyle AYNI serit -
            //   grup "ebelge" oldugu icin arac cubugunda degil kombo'da cikar.
            //   Gelen belgede hazirla/gonder YOK; cikti adimlari var.
            new("ebelge.onizle",   "Ön İzle",     "ebelge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 41),
            new("ebelge.ayrac1",   "─",           "ebelge", Hedef: "sagtus", Sira: 42),
            new("ebelge.pdf",      "PDF Kaydet",  "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 43),
            new("ebelge.html",     "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 44),
            new("ebelge.xml",      "XML Kaydet",  "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 45),
            new("ebelge.ayrac2",   "─",           "ebelge", Hedef: "sagtus", Sira: 46),
            new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 47),
            new("gelen.xml",     "XML Kaydet",      "gelen", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
            new("genel.yazdir",  "🖨️ Yazdır",     "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // Siparis listesi: buradan irsaliye/faturaya donusum yapilir (F8).
        //   Ayni 'belge' kaynagi, tur in (9,19) sabit filtresiyle.
        // TEKLIF listesi (216): siparis setinin sadesi - donusum/iptal/fis
        //   akislari ilk surumde yok, yalniz ekle/ac/sil + yazdir.
        s["teklif-liste"] = new AksiyonTanimi[]
        {
            new("belge.yeni", "＋ Yeni Teklif", "belge", Kisayol: "Ctrl+N",
                KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
            new("belge.ac",   "Aç",             "belge", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("belge.sil",  "🗑 Sil",         "belge", Kisayol: "Del",
                KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
            // Teklif -> siparis (KABUL sartiyla; istemci ve sunucu dogrular).
            new("belge.donustur", "⇢ Siparişe Dönüştür", "belge",
                AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
            new("genel.yazdir", "🖨️ Yazdır",   "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // DEMIRBAS listesi (216): standart kart Crud'u.
        s["demirbas-liste"] = Crud("demirbas", "demirbas", "demirbas");

        // ECZANE (722). AKIS DUGMESI YOK: eczaci karari, doz kontrolu,
        //   hazirlama dogrulamasi ve imha onayi kendi uclarini ister -
        //   o uclar bu turda YAZILMADI. Calismayan bir dugme koymak,
        //   kullaniciya var olmayan bir yetenek vaat etmektir.
        s["eczane-kontrol-liste"] =
            [.. Crud("eczane-kontrol", "eczane", "eczane.order"),
             // KARAR AYRI YETKİ (`eczane.onay`): uyarıyı görmek ile onu
             //   kapatmak aynı sorumluluk değil.
             new("eczane-kontrol.karar", "✓ Eczacı Kararı", "eczane",
                 AksiyonYetkisi: "eczane.onay", KayitGerekir: true, Sira: 15,
                 UrunModu: 2, Bicim: "bir",
                 Ipucu: "Yüksek düzey uyarıyı 'uygun' kapatmak gerekçe ister"),
             new("eczane-kontrol.hekim-yanit", "📞 Hekim Yanıtı", "eczane",
                 KaynakKodu: "eczane.order", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, UrunModu: 2)];

        s["eczane-doz-liste"] =
            [.. Crud("eczane-doz", "eczane", "eczane.doz"),
             // SIRA SUNUCUDA: hazırlanmadan kontrol, kontrol edilmeden teslim yok.
             new("eczane-doz.hazirla", "▶ Hazırlandı", "eczane",
                 KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, UrunModu: 2),
             new("eczane-doz.kontrol", "✓ Kontrol Edildi", "eczane",
                 KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir",
                 Ipucu: "Hazırlayan kendi hazırladığını kontrol edemez"),
             new("eczane-doz.teslim", "🚚 Teslim Et", "eczane",
                 KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17, UrunModu: 2),
             new("eczane-doz.iade", "↩ İade", "eczane", Hedef: "sagtus,palet",
                 KaynakKodu: "eczane.doz", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 18, UrunModu: 2),
             new("eczane-doz.imha", "🗑 İmha", "eczane", Hedef: "sagtus,palet",
                 AksiyonYetkisi: "eczane.imha", KayitGerekir: true,
                 Sira: 19, UrunModu: 2)];

        s["eczane-hazirlama-liste"] =
            [.. Crud("eczane-hazirlama", "eczane", "eczane.hazirlama"),
             new("eczane-hazirlama.doz-hesapla", "🧮 Doz Hesapla", "eczane",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 14, UrunModu: 2,
                 Ipucu: "VYA ve protokol dozundan ÖNERİ üretir; uygulanacak dozu eczacı girer"),
             // HASTA GELMEDEN HAZIRLANMAZ: hazırlanıp iptal edilen
             //   kemoterapi sitotoksik atık olarak imha edilir.
             new("eczane-hazirlama.hasta-geldi", "🧍 Hasta Geldi", "eczane",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, UrunModu: 2),
             new("eczane-hazirlama.hazirla", "▶ Hazırlamaya Başla", "eczane",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir"),
             new("eczane-hazirlama.dogrula", "✓ 2. Eczacı Doğrulaması", "eczane",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17, UrunModu: 2, Bicim: "onay",
                 Ipucu: "Kemoterapide yanlış doz geri alınamaz - doğrulayan başkası olmalı"),
             new("eczane-hazirlama.teslim", "🚚 Teslim Et", "eczane",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 18, UrunModu: 2),
             new("eczane-hazirlama.iptal", "✖ İptal", "eczane", Hedef: "sagtus,palet",
                 KaynakKodu: "eczane.hazirlama", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 19, UrunModu: 2)];

        s["eczane-iade-liste"] =
            [.. Crud("eczane-iade", "eczane", "eczane.iade"),
             // ÜÇ ÖLÇÜT: ambalaj / sulandırma / soğuk zincir. Biri "evet"
             //   ise stoğa kabul REDDEDİLİR - burada zorlama yok.
             new("eczane-iade.karar-stok", "✓ Stoğa Kabul", "eczane",
                 KaynakKodu: "eczane.iade", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, UrunModu: 2, Bicim: "onay",
                 Ipucu: "Ambalajı açılmış / sulandırılmış / soğuk zinciri bozulmuş ilaç kabul edilmez"),
             new("eczane-iade.karar-imha", "🔥 İmhaya", "eczane",
                 AksiyonYetkisi: "eczane.imha", KayitGerekir: true,
                 Sira: 16, UrunModu: 2),
             new("eczane-iade.karar-kasa", "🔴 Kasaya (kontrollü)", "eczane",
                 AksiyonYetkisi: "eczane.kontrollu", KayitGerekir: true,
                 Sira: 17, UrunModu: 2,
                 Ipucu: "Kontrollü ilaç defterine iade satırı yazılır")];

        s["eczane-imha-liste"] =
            [.. Crud("eczane-imha", "eczane", "eczane.imha"),
             new("eczane-imha.onayla", "✓ Komisyon Onayı", "eczane",
                 AksiyonYetkisi: "eczane.imha_onay", KayitGerekir: true,
                 Sira: 15, UrunModu: 2,
                 Ipucu: "İmha tek kişinin işi değil - komisyon yazılmadan ilerlemez"),
             new("eczane-imha.imha-et", "🔥 İmha Et (stoktan düş)", "eczane",
                 AksiyonYetkisi: "eczane.imha_onay", KayitGerekir: true,
                 Sira: 16, UrunModu: 2, Bicim: "tehlike",
                 Ipucu: "Çıkış fişi keser; kontrollü kalemler deftere de yazılır")];
        // KONTROLLU DEFTER ve MIAD: kart yok, yalniz okunur.
        //   Defter satiri SILINEMEZ (722 tetigi) - "Sil" dugmesi koymak,
        //   basilinca 422 donen bir dugme olurdu.
        // DEFTER SATIRI SİLİNMEZ (722 tetiği) - "Sil" düğmesi basılınca
        //   422 dönen bir düğme olurdu. Yazma kendi ucundan geçer.
        s["kontrollu-defter-liste"] =
            [new("kontrollu-defter.yaz", "🗒️ Defter Kaydı", "eczane",
                 Hedef: "araccubugu", AksiyonYetkisi: "eczane.kontrollu",
                 Sira: 10, UrunModu: 2,
                 Ipucu: "Hatalı satır silinmez; düzeltme satırıyla kapatılır"),
             Yazdir()];
        s["eczane-miad-liste"] = [Yazdir()];

        // BANKO (985). SILME VAR: banko taniminin gecmise bagi yok -
        //   oturum ve tahsilat baglandiginda silme engeli eklenecek;
        //   simdilik kullanilmayan banko PASIFE alinir (listedeki
        //   varsayilan suzgec aktifleri gosterir).
        s["banko-liste"] = [.. Crud("banko", "banko", "banko",
            silIpucu: "Kullanımdan çıkarmak için Aktif alanını kapatmak yeterli")];

        // OTURUM GECMISI SALT OKUMA (987): oturum karttan acilmaz/kapanmaz,
        //   akis ekraninin (banko-oturum) isi. Kapanan oturum duzeltilmez;
        //   hatali tahsilat iade/duzeltme fisiyle cozulur - bu yuzden
        //   listede yeni/duzenle/sil yok, yalniz yazdirma var.
        s["banko-oturum-liste"] = [Yazdir()];

        // BIYOMEDIKAL (723). Cihaz envanterinin karti DEMIRBAS kartidir -
        //   ekran kodu ayri, Crud ayni karta bagli.
        s["demirbas-cihaz-liste"] =
            [.. Crud("demirbas", "demirbas", "demirbas"),
             new("demirbas-cihaz.hareket-zimmet", "🔄 Zimmet Değiştir", "demirbas",
                 AksiyonYetkisi: "demirbas.zimmet", KayitGerekir: true,
                 Sira: 15, UrunModu: 2),
             new("demirbas-cihaz.hareket-yer", "📍 Yer Değiştir", "demirbas",
                 KaynakKodu: "demirbas", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, UrunModu: 2),
             new("demirbas-cihaz.hareket-havuz", "📦 Yedek Havuza", "demirbas",
                 KaynakKodu: "demirbas", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17, UrunModu: 2,
                 Ipucu: "Arıza anında yerine konacak cihaz havuzu"),
             // AÇIK İŞ EMRİ VARKEN HURDA YOK (uç reddeder).
             new("demirbas-cihaz.hareket-hurda", "🗑️ Hurdaya Ayır", "demirbas",
                 Hedef: "sagtus,palet", AksiyonYetkisi: "demirbas.hurda",
                 KayitGerekir: true, Sira: 18, UrunModu: 2, Bicim: "tehlike")];

        s["demirbas-kalibrasyon-liste"] =
            [.. Crud("demirbas-kalibrasyon", "demirbas", "demirbas.kalibrasyon"),
             new("demirbas-kalibrasyon.tamamla", "✓ Kalibrasyonu Tamamla", "demirbas",
                 AksiyonYetkisi: "demirbas.kalibrasyon", KayitGerekir: true,
                 Sira: 15, UrunModu: 2, Bicim: "onay",
                 Ipucu: "Sonuç ölçümlerden türer; sınır dışı ölçümde 'uygun' seçilemez")];
    }
}
