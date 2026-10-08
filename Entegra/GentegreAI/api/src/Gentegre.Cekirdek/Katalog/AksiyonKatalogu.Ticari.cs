using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// AKSIYON KATALOGU — Teknik servis (773), stok, satinalma, kasa, belge ve genel ekranlar.
///
/// Katalog 3240 satirlik tek dosyaydi; konu bazli partial parcalara ayrildi
/// (KartKatalogu / KaynakKatalogu ile ayni desen). Girdiler TASINDI, icerigi
/// degismedi.
/// </summary>
public static partial class AksiyonKatalogu
{
    private static void EkleTicari(Dictionary<string, IReadOnlyList<AksiyonTanimi>> s)
    {

        // ============================================= TEKNIK SERVIS (773) ==
        //  UC KATMAN, UC EKRAN: cagri (SLA isliyor) -> is emri (yapilan
        //  is) -> ziyaret (bir gidis). Aksiyonlar da o sirayi izler.
        s["servis-cagri-liste"] =
            [.. Crud("servis-cagri", "servis", "servis"),
             new("servis-cagri.is-emri", "🗂️ İş Emri Aç", "servis",
                 KaynakKodu: "servis", Islem: Islem.Ekle,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Çağrı atandı olur, ilk yanıt zamanı damgalanır"),
             new("servis-cagri.cihaz-parki", "📋 Cihaz Parkı", "servis",
                 Hedef: "sagtus,palet", KaynakKodu: "servis.cihaz",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 18,
                 Ipucu: "Müşterideki cihazlar, garanti ve sözleşme durumu")];

        //  IS EMRI: ziyaret ve emanet buradan yurur; TESLIM ayri aksiyon
        //  yetkisidir (`servis.teslim`) - duzenlemek ile kapatmak ayni
        //  sorumluluk degil.
        s["servis-is-emri-liste"] =
            [.. Crud("servis-is-emri", "servis", "servis"),
             new("servis-is-emri.ziyaret", "🚐 Ziyaret Başlat", "servis",
                 KaynakKodu: "servis", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Varış damgalanır; kapanışta imza ve sonuç sorulur"),
             new("servis-is-emri.emanet", "🔄 Emanet Cihaz Ver", "servis",
                 KaynakKodu: "servis", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16,
                 Ipucu: "İade alınmadan iş emri kapanmaz"),
             new("servis-is-emri.teslim", "📦 Teslim Et", "servis",
                 AksiyonYetkisi: "servis.teslim", KayitGerekir: true,
                 Sira: 20, Bicim: "bir",
                 Ipucu: "Açık emanet ya da kapanmamış ziyaret varken kapanmaz"),
             new("servis-is-emri.ziyaretler", "📍 Ziyaretler", "servis",
                 Hedef: "sagtus,palet", KaynakKodu: "servis",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 22)];

        s["servis-ziyaret-liste"] =
            [.. Crud("servis-ziyaret", "servis", "servis"),
             // MOBIL KART: sahadaki teknisyenin ekrani. Masaustunde de
             //   ayni ekran acilir - iki ayri kapanis formu tutmak
             //   ikisinin ayrismasi demekti.
             new("servis-ziyaret.mobil", "📱 Ziyaret Kartı", "servis",
                 KaynakKodu: "servis", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 14, Bicim: "bir",
                 Ipucu: "Tek sütun, büyük alanlar - telefonda doldurulur"),
             new("servis-ziyaret.kapat", "✓ Ziyareti Kapat", "servis",
                 KaynakKodu: "servis", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "İmza alınamadıysa gerekçe zorunlu")];

        //  ACIK EMANET AYRI LISTE: is emrinin icinde kalirsa kapanan is
        //  emriyle birlikte gorunmez olur.
        s["servis-emanet-liste"] =
            [.. Crud("servis-emanet", "servis", "servis"),
             new("servis-emanet.iade", "↩ İade Al", "servis",
                 KaynakKodu: "servis", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir")];

        s["taraf-cihaz-liste"] = [.. Crud("taraf-cihaz", "servis", "servis.cihaz")];

        //  ARIZA / TALEP (hizmet masası, 911): EKİP LİSTESİ. Serbest CRUD
        //  YOK - talep self-servis açılır (ayrı ekran), ekip yalnız AKIŞI
        //  yürütür: devral → çöz → kapat, gerekirse başka personele ata.
        //  Hepsi `ariza` yetkisiyle (ekip); açış yetkisi ayrı (`ariza.talep`).
        s["ariza-talep-liste"] =
            [new("ariza.devral", "🙋 Devral", "ariza",
                 KaynakKodu: "ariza", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 10, Bicim: "bir",
                 Ipucu: "Sorumlusu ben olurum, durum İşlemde"),
             new("ariza.coz", "✓ Çöz", "ariza",
                 KaynakKodu: "ariza", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 20, Bicim: "onay",
                 Ipucu: "Çözüm notu zorunlu"),
             new("ariza.kapat", "🔒 Kapat", "ariza",
                 KaynakKodu: "ariza", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 25)];

        s["servis-sozlesme-liste"] =
            [.. Crud("servis-sozlesme", "servis", "servis.sozlesme")];

        s["demirbas-is-emri-liste"] =
            [.. Crud("demirbas-is-emri", "demirbas", "demirbas.isemri"),
             new("demirbas-is-emri.ata", "👤 Ata", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, UrunModu: 2),
             new("demirbas-is-emri.mudahale", "▶ Müdahaleye Başla", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, UrunModu: 2, Bicim: "bir",
                 Ipucu: "Yanıt süresi bu damgadan hesaplanır"),
             // MASRAFLI ONARIM ONAYI (752): esigi asan is emri dis
             //   servise gonderilmeden once onaydan gecer.
             new("demirbas-is-emri.onaya-gonder", "📤 Onarımı Onaya Gönder", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 14, UrunModu: 2, Bicim: "bir",
                 Ipucu: "Eşiği aşan onarım onaysız dış servise gönderilemez"),
             new("demirbas-is-emri.onay-zinciri", "🧾 Onay Zinciri", "demirbas",
                 Hedef: "sagtus,palet", KaynakKodu: "demirbas.isemri",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 18, UrunModu: 2),
             new("demirbas-is-emri.parca-bekle", "⏸ Parça Bekliyor", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17, UrunModu: 2),
             new("demirbas-is-emri.dis-servis", "🚚 Dış Servise Gönder", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 18, UrunModu: 2),
             new("demirbas-is-emri.parca-cikis", "🧾 Parçaları Stoktan Düş", "demirbas",
                 AksiyonYetkisi: "stok", KayitGerekir: true, Sira: 19, UrunModu: 2,
                 Ipucu: "Yalnız kurumun ödediği parçalar düşülür (garanti/sözleşme düşülmez)"),
             new("demirbas-is-emri.tamamla", "✓ Tamamla", "demirbas",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 20, UrunModu: 2, Bicim: "onay",
                 Ipucu: "Zorunlu bakım maddeleri işaretsizse gerekçe ister"),
             new("demirbas-is-emri.iptal", "✖ İptal", "demirbas", Hedef: "sagtus,palet",
                 KaynakKodu: "demirbas.isemri", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 21, UrunModu: 2)];

        // SATINALMA (724). Onay/karar/ceza dugmeleri YOK: her biri para
        //   cikaran ya da imza zinciri isleyen bir karardir ve kendi ucunu
        //   ister - o uclar bu turda yazilmadi.
        // ONAY GELEN KUTUSU (738/739). TÜR FARK ETMEZ: satır bir
        //   BASAMAKTIR, kararı da basamağa verilir. Kaydın kendi ekranına
        //   gitmeden karar verilebilmesi kutunun varlık sebebi - aksi
        //   hâlde kullanıcı yine tür tür ekran gezerdi.
        // IZIN (743). TALEP -> ONAY -> IPTAL. "Onayla" dugmesi YOK:
        //   karar onay kutusundan ya da kaydin kendi zincirinden verilir -
        //   izin ekranina ikinci bir onay yolu koymak, ayni karari iki
        //   ayri yerde farkli kurallarla vermek olurdu.
        s["personel-izin-liste"] =
            [.. Crud("personel-izin", "ik", "ik.izin"),
             new("personel-izin.gonder", "📤 Onaya Gönder", "ik",
                 KaynakKodu: "ik.izin", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Zincir: âmir → İK → (10 günü aşarsa) üst yönetim"),
             new("personel-izin.bakiye", "📊 Bakiye", "ik",
                 KaynakKodu: "ik.izin", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 16),
             new("personel-izin.zincir", "🧾 Onay Zinciri", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.izin", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 17),
             new("personel-izin.iptal", "✖ İzni İptal Et", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.izin",
                 Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                 Bicim: "tehlike",
                 Ipucu: "Onaylı izin de iptal edilir - gerekçe zorunlu")];

        // AVANS (753). ODEME ONAYDAN SONRA ve AYRI DUGMEDIR: onay
        //   parayi cikarmaz, cikarma iznini verir.
        s["personel-avans-liste"] =
            [.. Crud("personel-avans", "ik", "ik.avans"),
             new("personel-avans.gonder", "📤 Onaya Gönder", "ik",
                 KaynakKodu: "ik.avans", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Zincir: âmir → İK → (tutar eşiğine göre) mali işler / üst yönetim"),
             new("personel-avans.ode", "💸 Öde", "ik",
                 AksiyonYetkisi: "ik.avans_ode", KayitGerekir: true, Sira: 16,
                 Ipucu: "Kasa/banka işlemi üretir ve kesinti planını açar"),
             new("personel-avans.kesinti", "✂ Kesinti İşle", "ik",
                 KaynakKodu: "ik.avans", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17,
                 Ipucu: "Bekleyen en eski taksit kesildi olarak işaretlenir"),
             new("personel-avans.zincir", "🧾 Onay Zinciri", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.avans", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 18),
             new("personel-avans.iptal", "✖ Avansı İptal Et", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.avans",
                 Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                 Bicim: "tehlike",
                 Ipucu: "Ödenmiş avans iptal edilemez - geri alım ayrı tahsilattır")];

        // MASRAF BEYANI (764). Odeme aksiyonu YOK: zincir onayla biter,
        //   muhasebe disarida oder (kullanici karari).
        s["personel-masraf-liste"] =
            [.. Crud("personel-masraf", "ik", "ik.masraf"),
             new("personel-masraf.gonder", "📤 Onaya Gönder", "ik",
                 KaynakKodu: "ik.masraf", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Zincir: âmir → (tutar eşiğine göre) mali işler / üst yönetim"),
             new("personel-masraf.zincir", "🧾 Onay Zinciri", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.masraf", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 18),
             new("personel-masraf.iptal", "✖ Beyanı İptal Et", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.masraf",
                 Islem: Islem.Degistir, KayitGerekir: true, Sira: 20,
                 Bicim: "tehlike",
                 Ipucu: "Beyan silinmez - \"bu harcama talep edilmiş miydi\" sorusu sonradan da sorulur")];

        // BELGE TALEBI (765). Asil is onay degil HAZIRLAMAK: aksiyonlar
        //   da o sirayi izler (hazirla -> teslim).
        s["personel-belge-talep-liste"] =
            [.. Crud("personel-belge-talep", "ik", "ik.belge_talep"),
             // YAZI EN ÜSTTE (768): hazırlamadan ÖNCE bakılır. Sıra
             //   işin sırasıdır - önce metni gör, sonra hazırlandı de.
             new("personel-belge-talep.yazi", "📄 Yazıyı Göster", "ik",
                 KaynakKodu: "ik.belge_talep", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 14,
                 Ipucu: "Şablondan üretilen metin; yazdırılır ve düzeltilebilir"),
             new("personel-belge-talep.hazirla", "🖨 Hazırlandı", "ik",
                 KaynakKodu: "ik.belge_talep", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Yalnız onaylanmış (hazırlanacak) talep hazırlanabilir"),
             new("personel-belge-talep.teslim", "📬 Teslim Edildi", "ik",
                 KaynakKodu: "ik.belge_talep", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16,
                 Ipucu: "Personelin beklediği şey onay değil belgenin kendisi"),
             new("personel-belge-talep.zincir", "🧾 Onay Zinciri", "ik",
                 Hedef: "sagtus,palet", KaynakKodu: "ik.belge_talep",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 18,
                 Ipucu: "Otomatik onaylanan talepte zincir kurulmaz"),
             new("personel-belge-talep.reddet", "✖ Reddet", "ik",
                 Hedef: "sagtus,palet", AksiyonYetkisi: "ik.belge_talep_onay",
                 KayitGerekir: true, Sira: 20, Bicim: "tehlike",
                 Ipucu: "Otomatik onaylanmış talep de gerekçeyle reddedilebilir")];

        // RESMI TATIL (749). "Yili Uret" yalniz MILLI tatilleri yazar;
        //   dini bayramlar elle girilir - hicri takvim algoritmayla
        //   uretilmiyor (bir gun kayan hesap izni yanlis sayar).
        s["resmi-tatil-liste"] =
            [.. Crud("resmi-tatil", "ik", "ik.tatil"),
             new("resmi-tatil.yil-uret", "📅 Yılın Millî Tatillerini Üret", "ik",
                 KaynakKodu: "ik.tatil", Islem: Islem.Ekle, Sira: 15, Bicim: "bir",
                 Ipucu: "Dinî bayramlar dâhil değildir - onları elle girin")];

        // BAKIYE LISTESI salt okunur: hak karti ayri ekrandir.
        s["izin-bakiye-liste"] =
            [new("izin-bakiye.izin-ac", "＋ İzin Talebi Aç", "ik",
                 KaynakKodu: "ik.izin", Islem: Islem.Ekle,
                 KayitGerekir: true, Sira: 10, Bicim: "bir"),
             new("izin-bakiye.hak-tanimla", "✎ Hakediş Tanımla", "ik",
                 KaynakKodu: "ik.izin_hak", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 11)];

        s["personel-izin-hak-liste"] =
            [.. Crud("personel-izin-hak", "ik", "ik.izin_hak")];

        // AKIS TANIMI (742): kurumun imza duzeni. "Akisi Dene" KURU
        //   CALISTIRMADIR - kayit uretmez, yalnizca verilen olcu ve
        //   bayraklarla hangi basamaklarin cikacagini gosterir. Eşiği
        //   degistiren kisi sonucunu gercek bir talep acmadan gormeli.
        s["onay-akis-liste"] =
            [.. Crud("onay-akis", "onay", "kullanici"),
             new("onay-akis.dene", "🧪 Akışı Dene", "onay",
                 KaynakKodu: "kullanici", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 15,
                 Ipucu: "Kayıt üretmez - hangi basamakların çıkacağını gösterir"),
             new("onay-akis.yuruyenler", "📋 Yürüyen Onaylar", "onay",
                 Hedef: "sagtus,palet", KaynakKodu: "kullanici", Islem: Islem.Gor,
                 KayitGerekir: true, Sira: 16)];

        // VEKALET EKRANI (741): imza yetkisinin gecici devri. CRUD
        //   yeter - vekaletin akisi yok, tanimlanir ya da kaldirilir.
        s["onay-vekalet-liste"] =
            [.. Crud("onay-vekalet", "onay", "kullanici")];

        s["onay-kutusu-liste"] =
            [new("onay-kutusu.onayla", "✓ Onayla", "onay",
                 KayitGerekir: true, Sira: 10, Bicim: "onay",
                 Ipucu: "Karar bekleyen en küçük basamağa yazılır"),
             new("onay-kutusu.bilgi", "↩ Bilgi İste", "onay",
                 KayitGerekir: true, Sira: 11,
                 Ipucu: "Zinciri durdurur ama bitirmez - basamak beklemeye devam eder"),
             new("onay-kutusu.reddet", "✖ Reddet", "onay",
                 KayitGerekir: true, Sira: 12, Bicim: "tehlike"),
             new("onay-kutusu.sozlu", "🗣 Sözlü Onay", "onay",
                 Hedef: "sagtus,palet", KayitGerekir: true, Sira: 13,
                 Ipucu: "Yazılı tamamlanma süresi izlenir"),
             new("onay-kutusu.kayda-git", "🔎 Kayda Git", "onay",
                 Hedef: "sagtus,palet", KayitGerekir: true, Sira: 20),
             new("onay-kutusu.zincir", "🧾 Onay Zinciri", "onay",
                 Hedef: "sagtus,palet", KayitGerekir: true, Sira: 21)];

        s["satinalma-talep-liste"] =
            [.. Crud("satinalma-talep", "satinalma", "satinalma.talep"),
             // ZİNCİRİ SİSTEM KURAR: "kime göndereyim" sorulmaz.
             new("satinalma-talep.gonder", "📤 Onaya Gönder", "satinalma",
                 KaynakKodu: "satinalma.talep", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Onay basamakları tutar ve bütçe durumundan türer"),
             new("satinalma-talep.karar-onayla", "✓ Onayla ve İlerlet", "satinalma",
                 AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true,
                 Sira: 16, Bicim: "onay",
                 Ipucu: "Karar hep bekleyen en küçük basamağa yazılır - basamak atlanamaz"),
             new("satinalma-talep.karar-bilgi", "↩ Bilgi İste", "satinalma",
                 AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true, Sira: 17),
             new("satinalma-talep.karar-sozlu", "🗣 Sözlü Onay", "satinalma",
                 Hedef: "sagtus,palet", AksiyonYetkisi: "satinalma.onay_birim",
                 KayitGerekir: true, Sira: 18,
                 Ipucu: "Yazılı tamamlanma süresi izlenir"),
             new("satinalma-talep.karar-reddet", "✖ Reddet", "satinalma",
                 AksiyonYetkisi: "satinalma.onay_birim", KayitGerekir: true,
                 Sira: 19, Bicim: "tehlike"),
             new("satinalma-talep.birlestir", "🔗 Talepleri Birleştir", "satinalma",
                 Hedef: "araccubugu,palet", KaynakKodu: "satinalma.talep",
                 Islem: Islem.Degistir, Sira: 20,
                 Ipucu: "İlk seçilen HEDEF olur; kaynaklar silinmez, birleştirildi olarak kapanır"),
             new("satinalma-talep.siparise", "📦 Siparişe Dönüştür", "satinalma",
                 AksiyonYetkisi: "satinalma.siparis", KayitGerekir: true, Sira: 21,
                 Ipucu: "Alış siparişi (belge tür 9) oluşturur")];

        s["satinalma-teklif-liste"] =
            [.. Crud("satinalma-teklif", "satinalma", "satinalma.teklif"),
             new("satinalma-teklif.davet", "📧 Daveti Gönder", "satinalma",
                 KaynakKodu: "satinalma.teklif", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15, Bicim: "bir",
                 Ipucu: "Değerlendirme ağırlıkları KİLİTLENİR"),
             new("satinalma-teklif.ac", "📂 Teklifleri Aç", "satinalma",
                 KaynakKodu: "satinalma.teklif", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16,
                 Ipucu: "Son tarihten önce açmak gerekçe ister; puanlar burada hesaplanır"),
             new("satinalma-teklif.karar", "✓ Kararı Ver", "satinalma",
                 AksiyonYetkisi: "satinalma.karar", KayitGerekir: true,
                 Sira: 17, Bicim: "onay",
                 Ipucu: "En düşük teklif alınmıyorsa gerekçe zorunlu")];

        s["satinalma-butce-liste"] = Crud("satinalma-butce", "satinalma", "satinalma.butce");
        // SIPARIS / FATURA KONTROL / TEDARIKCI: takip listeleri. Siparis
        //   `belge` (tur 9) kartindan, tedarikci cari kartindan duzenlenir;
        //   burada ikinci bir duzenleme yolu acilmiyor.
        s["satinalma-siparis-liste"] =
            [new("satinalma-siparis.gecikme", "⏱ Gecikme Bildir", "satinalma",
                 KaynakKodu: "satinalma.siparis", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 10,
                 Ipucu: "Gecikme söz verilen tarihten sayılır; tedarikçi performansına işlenir"),
             // CEZA KENDİLİĞİNDEN TAHSİL OLMAZ: işlemek ayrı karardır.
             new("satinalma-siparis.ceza", "⚖ Ceza İşlet", "satinalma",
                 AksiyonYetkisi: "satinalma.ceza", KayitGerekir: true,
                 Sira: 20, Bicim: "tehlike",
                 Ipucu: "Hesap sözleşmeden (binde/gün, üst sınır %)"),
             Yazdir()];

        s["satinalma-fatura-liste"] =
            [new("satinalma-fatura.eslestir", "🧮 Yeniden Eşleştir", "satinalma",
                 KaynakKodu: "satinalma.fatura", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 10,
                 Ipucu: "Sipariş - teslim - fatura; karşılaştırma tabanı TESLİMDİR"),
             // ÖDEME KARARI AYRI YETKİ: farkı görmekle ödemeyi serbest
             //   bırakmak aynı sorumluluk değil.
             new("satinalma-fatura.odeme-onay", "✓ Ödemeye Onay Ver", "satinalma",
                 AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true,
                 Sira: 20, Bicim: "onay"),
             new("satinalma-fatura.odeme-durdur", "⛔ Ödemeyi Durdur", "satinalma",
                 AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true,
                 Sira: 21, Bicim: "tehlike"),
             new("satinalma-fatura.odeme-itiraz", "📨 Tedarikçiye İtiraz", "satinalma",
                 AksiyonYetkisi: "satinalma.odeme_onay", KayitGerekir: true, Sira: 22),
             Yazdir()];

        // MAL KABUL (733). Muayene tutanağı: satırlar irsaliyeden gelir,
        //   karar komisyonundur.
        s["satinalma-kabul-liste"] =
            [.. Crud("satinalma-kabul", "satinalma", "satinalma.kabul"),
             new("satinalma-kabul.tumunu-kabul", "✓ Tüm Kalemleri Kabul Et", "satinalma",
                 KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 15,
                 Ipucu: "İstisna yoksa otuz satırı tek tek işaretlemek zaman kaybı"),
             new("satinalma-kabul.karar-kabul", "✓ Kabul", "satinalma",
                 KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 16, Bicim: "onay",
                 Ipucu: "Siparişi kapatır; muayenesi bitmemiş tutanak karara bağlanmaz"),
             new("satinalma-kabul.karar-kismi", "↩ Kısmi Kabul", "satinalma",
                 KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 17,
                 Ipucu: "Uygunsuzluk metni zorunlu"),
             // RET SİPARİŞİ KAPATMAZ: mal geri gidiyor, taahhüt sürüyor.
             new("satinalma-kabul.karar-ret", "✖ Ret", "satinalma",
                 KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 18, Bicim: "tehlike"),
             // KAREKOD OKUMA (734): kutular tek tek okutulur, her kod
             //   kendi sonucuyla döner - biri okunamadı diye öncekiler
             //   silinmez.
             new("satinalma-kabul.karekod", "🔦 Karekod Oku", "satinalma",
                 KaynakKodu: "satinalma.kabul", Islem: Islem.Degistir,
                 KayitGerekir: true, Sira: 12, Bicim: "bir",
                 Ipucu: "Aynı kutu iki kez okutulamaz; beklenmeyen kutu kayda geçer"),
             new("satinalma-kabul.karekod-ozet", "📋 Karekod Özeti", "satinalma",
                 Hedef: "sagtus,palet", KaynakKodu: "satinalma.kabul",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 13),
             // İTS BİLDİRİMİ (736). Kuyruğa alma muayene bittikten SONRA:
             //   hangi kutunun kabul edildiği kararla belli olur.
             new("satinalma-kabul.its-gonder", "📡 İTS Bildir", "satinalma",
                 AksiyonYetkisi: "uts.bildir", KayitGerekir: true, Sira: 25,
                 Ipucu: "Reddedilen kalemin kutusu bildirime girmez"),
             new("satinalma-kabul.its-durum", "📋 İTS Durumu", "satinalma",
                 Hedef: "sagtus,palet", KaynakKodu: "satinalma.kabul",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 26),
             new("satinalma-kabul.its-iptal", "✖ İTS Bildirimini İptal Et", "satinalma",
                 Hedef: "sagtus,palet", AksiyonYetkisi: "uts.iptal",
                 KayitGerekir: true, Sira: 27, Bicim: "tehlike",
                 Ipucu: "Gönderilmiş bildirim iptal edilemez (iade/deaktivasyon gerekir)"),
             new("satinalma-kabul.siparise-git", "📦 Siparişe Git", "satinalma",
                 Hedef: "sagtus,palet", KaynakKodu: "satinalma.siparis",
                 Islem: Islem.Gor, KayitGerekir: true, Sira: 19)];

        s["satinalma-tedarikci-liste"] = [Yazdir()];

        // ÜTS bildirim gecmisi (223). Iptal/yeniden gonderme RESMI islem:
        //   ayri aksiyon yetkileri (uts.iptal / uts.bildir).
        s["uts-bildirim-liste"] = new AksiyonTanimi[]
        {
            // Elle bildirim formlari: TEK "Bildirim" dugmesi, asagi acilir
            //   menu (kullanici) - alt secenekler listeTanimlari'nda.
            new("uts.bildirim-menu", "＋ Bildirim", "stok",
                Hedef: "araccubugu", AksiyonYetkisi: "uts.bildir", Sira: 10),
            new("uts.detay", "ÜTS Detay Sorgula", "stok",
                Hedef: "sagtus,palet", KaynakKodu: "uts", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 20),
            // Iki asamali akis: "Verme" gridi bekleyenlerle doldurur,
            //   secilenler buradan UTS'ye cikar (bekleyen + hatali).
            new("uts.yeniden-gonder", "📤 Gönder", "stok",
                Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.bildir",
                KayitGerekir: true, Sira: 30),
            new("uts.iptal", "✖ ÜTS'de İptal Et", "stok",
                Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.iptal",
                KayitGerekir: true, Sira: 40),
            new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // ÜTS askidaki/gelen urunler (223): senkron + alma bildirimi.
        s["uts-envanter-liste"] = new AksiyonTanimi[]
        {
            new("uts.senkron", "⟳ Askıdakileri Getir", "stok",
                Hedef: "araccubugu,palet", AksiyonYetkisi: "uts.bildir", Sira: 10),
            new("uts.al", "📥 Alma Bildirimi Yap", "stok",
                Hedef: "araccubugu,sagtus,palet", AksiyonYetkisi: "uts.bildir",
                KayitGerekir: true, Sira: 20),
            new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // BASVURU (246, kullanici): satis siparisinin AYNISI - ek olarak
        //   tahsilat acilabilir (hasta odemesi basvuru ekranindan alinir).
        s["basvuru-liste"] = new AksiyonTanimi[]
        {
            new("belge.yeni",     "＋ Yeni Başvuru", "belge", Kisayol: "Ctrl+N",
                KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
            new("belge.ac",       "Aç",              "belge", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("belge.sil",      "🗑 Sil",          "belge", Kisayol: "Del",
                KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
            new("belge.donustur", "⇢ Belge Kes",     "belge",
                AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
            // Tahsilat: hasta odemesi (nakit/banka/POS) basvurudan alinir.
            new("kasa.tahsilat.yeni", "＋ Tahsilat", "kasa",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 35),
            new("belge.iptal",    "İptal Et",        "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
            new("belge.fis-gor",  "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
            new("belge.hedef-ac", "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
            new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        s["siparis-liste"] = new AksiyonTanimi[]
        {
            new("belge.yeni",     "＋ Yeni Sipariş", "belge", Kisayol: "Ctrl+N",
                KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
            new("belge.ac",       "Aç",              "belge", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            // Fatura listesindeki desenin AYNISI: "Aç"in saginda silme.
            //   Izi olmayan (kesinlesmemis) belge silinir; digerinde "İptal Et".
            new("belge.sil",      "🗑 Sil",          "belge", Kisayol: "Del",
                KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
            new("belge.donustur", "⇢ Belge Kes",     "belge",
                AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
            new("belge.iptal",    "İptal Et",        "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 40),
            // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
            //   tikla fise ve zincirin iki ucuna gidilir.
            new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
            new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
            new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
            new("genel.yazdir",   "🖨️ Yazdır",    "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // Irsaliye listesi (Ekranlar/satis_irsaliye_listesi.html aksiyonlari).
        //   Ucu olan ucu calisir: ac, donustur, yeni. Digerleri yetkiye bagli
        //   gorunur ama tiklaninca "henuz baglanmadi" der.
        s["irsaliye-liste"] = new AksiyonTanimi[]
        {
            new("belge.yeni",     "＋ Yeni İrsaliye", "belge", Kisayol: "Ctrl+N",
                KaynakKodu: "belge", Islem: Islem.Ekle, Sira: 10),
            new("belge.ac",       "İrsaliyeyi Aç",    "belge", Kisayol: "Enter",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("belge.sil",      "🗑 Sil",           "belge", Kisayol: "Del",
                KaynakKodu: "belge", Islem: Islem.Sil, KayitGerekir: true, Sira: 25),
            new("belge.donustur", "🧾 Faturaya Dönüştür", "belge",
                AksiyonYetkisi: "belge.donustur", KayitGerekir: true, Sira: 30),
            // e-BELGE MENUSU - fatura listesindekiyle AYNI adimlar ve sira
            //   (kullanici). Tek fark kutu basligi: irsaliyede "E-İrsaliye".
            //   Ayrac satirlari combo'da secilemez cizgidir.
            new("ebelge.hazirla",  "Hazırla", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 41),
            new("ebelge.onizle",   "Ön İzle", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 42),
            new("ebelge.gonder",   "Gönder", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 43),
            new("ebelge.ayrac1", "─", "ebelge", Hedef: "sagtus", Sira: 44),
            new("ebelge.seri",     "Seri Değiştir", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 45),
            new("ebelge.sifirla",  "Hazırı Geri Al", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 46),
            new("ebelge.ayrac2", "─", "ebelge", Hedef: "sagtus", Sira: 48),
            new("ebelge.pdf",      "PDF Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 48),
            new("ebelge.html",     "HTML Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 49),
            new("ebelge.xml",      "XML Kaydet", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "veri.disa-aktar", KayitGerekir: true, Sira: 50),
            new("ebelge.ayrac3", "─", "ebelge", Hedef: "sagtus", Sira: 52),
            new("ebelge.durum", "Durum Sorgula", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 53),
            new("ebelge.mesajlar", "Mesaj Geçmişini Göster", "ebelge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 54),
            new("belge.iptal",    "✖ İrsaliyeyi İptal Et", "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 50),
            // MUHASEBE FISI (190) ve DONUSUM ZINCIRI (F8): belgeden tek
            //   tikla fise ve zincirin iki ucuna gidilir.
            new("belge.fis-gor",   "Muhasebe Fişini Aç", "belge", Hedef: "sagtus,palet",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 60),
            new("belge.kaynak-ac", "Kaynak Belgeyi Aç",  "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 61),
            new("belge.hedef-ac",  "Hedef Belgeyi Aç",   "belge", Hedef: "sagtus,palet",
                KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 62),
            new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        s["belge-kart"] = new AksiyonTanimi[]
        {
            new("belge.kesinlestir", "Kesinlestir", "belge",
                AksiyonYetkisi: "belge.kesinlestir", KayitGerekir: true, Sira: 10),
            new("ebelge.gonder", "e-Fatura Gonder", "ebelge",
                AksiyonYetkisi: "ebelge.gonder", KayitGerekir: true, Sira: 20),
            new("belge.iptal", "Belgeyi Iptal Et", "belge", Hedef: "sagtus,palet",
                AksiyonYetkisi: "belge.iptal", KayitGerekir: true, Sira: 30),
        };

        s["cari-kart"] = new AksiyonTanimi[]
        {
            new("cari.sil", "🗑 Sil", "kart", Hedef: "araccubugu,palet",
                KaynakKodu: "cari", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
        };

        s["stok-kart"] = new AksiyonTanimi[]
        {
            new("stok.sil", "🗑 Sil", "stok", Hedef: "araccubugu,palet",
                KaynakKodu: "stok", Islem: Islem.Sil, KayitGerekir: true, Sira: 20),
        };

        // ---------------------------------------------------------- kasa ----
        // "Yeni" tek dugme degil, tur GRUBU basina bir giris: tahsilat ile
        //   odeme ayni ekrandir ama kullanicinin kafasinda ayri islemdir.
        s["kasa-liste"] = new AksiyonTanimi[]
        {
            new("kasa.tahsilat.yeni", "＋ Tahsilat", "kasa", Kisayol: "Ctrl+N",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
            new("kasa.odeme.yeni",    "－ Ödeme",    "kasa",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 20),
            new("kasa.virman.yeni",   "⇄ Virman",    "kasa",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 22),
            new("kasa.doviz.yeni",    "💱 Döviz",    "kasa",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 24),
            new("kasa.plan.yeni",     "📅 Plan",     "kasa", Hedef: "araccubugu,palet",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 26),
            new("kasa.ac",            "Aç",          "kasa", Kisayol: "Enter",
                KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 30),
            new("kasa.kesinlestir",   "Kesinleştir", "kasa", Hedef: "araccubugu,sagtus,palet",
                AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 40),
            new("kasa.iptal",         "İptal Et",    "kasa", Hedef: "sagtus,palet",
                AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 50),
            new("kasa.sil",           "🗑 Sil",         "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 60),
            new("kasa.fis-gor",       "Muhasebe Fişi", "muhasebe", Hedef: "sagtus,palet",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 70),
            new("genel.yazdir",       "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        // HASTA AVANSLARI (779): kayit kabulun ekrani. "Avans Al" tahsilat
        //   kartini AVANS DAMGASIYLA acar - damga, para tamamen
        //   kullanildiktan sonra da kaydin listede kalmasini saglar.
        s["avans-liste"] = new AksiyonTanimi[]
        {
            new("avans.yeni", "＋ Avans Al", "kasa", Kisayol: "Ctrl+N",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
            new("kasa.ac",    "Aç",          "kasa", Kisayol: "Enter",
                KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            // IADE (780): kalan avansi hastaya geri odeme. Avans kaydini
            //   KUCULTMEZ - odeme yonunde ayri bir kasa islemi acar.
            new("avans.iade", "↩ İade Et", "kasa",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, KayitGerekir: true, Sira: 25),
            // Mahsup BELGEDE yapilir (322): hangi satira sayilacagi orada
            //   belli. Listede "mahsup et" dugmesi, parayi hangi basvuruya
            //   yazdigini gostermeden harcamak olurdu.
            new("avans.basvuru-ac", "Mahsup Edilen Belgeyi Aç", "kasa",
                Hedef: "sagtus,palet", KaynakKodu: "belge", Islem: Islem.Gor,
                KayitGerekir: true, Sira: 30),
            new("kasa.iptal", "İptal Et", "kasa", Hedef: "sagtus,palet",
                AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 40),
            new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        s["kasa-kart"] = new AksiyonTanimi[]
        {
            new("kasa.kesinlestir", "Kesinleştir", "kasa",
                AksiyonYetkisi: "kasa.kesinlestir", KayitGerekir: true, Sira: 10),
            new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 15),
            new("kasa.fis-gor",     "Muhasebe Fişi", "muhasebe",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("kasa.iptal",       "İptal Et",    "kasa", Hedef: "sagtus,palet",
                AksiyonYetkisi: "kasa.iptal", KayitGerekir: true, Sira: 30),
            new("kasa.sil",         "🗑 Sil",         "kasa", Hedef: "sagtus,palet",
                KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
        };

        // Acik planlar: buradan "Gerceklestir" ile tahsilat/odeme uretilir.
        //   Plan kaydin KENDISI degismez (K10) - yeni bir islem acilir.
        s["plan-liste"] = new AksiyonTanimi[]
        {
            new("kasa.plan.yeni",    "📅 Yeni Plan", "kasa", Kisayol: "Ctrl+N",
                KaynakKodu: "kasa_islem", Islem: Islem.Ekle, Sira: 10),
            new("kasa.ac",           "Aç",           "kasa", Kisayol: "Enter",
                KaynakKodu: "kasa_islem", Islem: Islem.Gor, KayitGerekir: true, Sira: 20),
            new("kasa.gerceklestir", "✔ Gerçekleştir", "kasa",
                AksiyonYetkisi: "kasa.gerceklestir", KayitGerekir: true, Sira: 30),
            new("kasa.sil",          "🗑 Sil",          "kasa", Hedef: "sagtus,palet", Kisayol: "Del",
                KaynakKodu: "kasa_islem", Islem: Islem.Sil, KayitGerekir: true, Sira: 40),
            new("genel.yazdir",      "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };

        s["fis-liste"] = new AksiyonTanimi[]
        {
            new("fis.ac",         "Aç",           "muhasebe", Kisayol: "Enter",
                KaynakKodu: "muhasebe_fis", Islem: Islem.Gor, KayitGerekir: true, Sira: 10),
            new("fis.ters-kayit", "Ters Kayıt",   "muhasebe", Hedef: "sagtus,palet",
                AksiyonYetkisi: "fis.ters-kayit", KayitGerekir: true, Sira: 20),
            new("genel.yazdir",   "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
                AksiyonYetkisi: "veri.disa-aktar", Sira: 90),
        };
    }
}
