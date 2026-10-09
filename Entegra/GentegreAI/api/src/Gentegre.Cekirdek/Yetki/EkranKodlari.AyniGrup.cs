namespace Gentegre.Cekirdek.Yetki;

/// <summary>
/// AYNI GRUPTA BİRDEN ÇOK EKRAN AÇAN KODLARIN BÖLÜNMESİ (1004 — kullanıcı
/// 09.10.2026: "B grubunu da böl", "1 ile başla, sonra 2").
///
/// 1003 farklı menü gruplarını açan kodları böldü; burada aynı grubun içinde
/// birden çok ekran açan 58 kodun ana ekranı eski kodu korur, diğer 117 ekran
/// kendi kodunu alır. Matristeki her satır = menüdeki bir ekran.
///
/// AŞAMA 1 (bu dosya): her yeni kod eski kodun sunucu kapısını açar
/// (<see cref="EkranKodlari.VeriKapisiAltlari"/>) - kimse yetki kazanmaz ya da
/// kaybetmez, yalnız menü ve matris ayrılır. AŞAMA 2'de kendi kaynağı olan
/// ekranlar modül modül doğrudan yeni koda bağlanacak ve satır buradan
/// "kopya" olarak kalıp veri kapısından düşecek.
///
/// Bu tablo web listeTanimlari ve db/1004 ile birlikte üretildi; üçü aynı
/// kalmalı (EkranKoduBolmeTestleri sayıyı denetler).
/// </summary>
public static partial class EkranKodlari
{
    /// <summary>(yeni ekran kodu, haklarını kopyaladığı ve kapısını açtığı eski kod)</summary>
    public static readonly (string Yeni, string Eski)[] AyniGrupEkranlari =
    [
        ("acil.pano.cagri", "acil.pano"),                       // Acil › Çağrılar
        ("ameliyathane.plan.cizelge", "ameliyathane.plan"),     // Ameliyathane › Masa Çizelgesi
        ("ariza.ekip", "ariza"),                                // Teknik Servis › Arıza Ekipleri
        ("ayar.demo_verisi", "ayar"),                           // Yönetim › Veri Aktarımı › Demo Verisi
        ("ayar.iceri_alma", "ayar"),                            // Yönetim › Veri Aktarımı › Excel'den İçeri Alma
        ("belge.alis.ayar", "belge.alis"),                      // Alış › Ayarlar › Alış Belgeleri
        ("belge.alis.fis", "belge.alis"),                       // Alış › Alış Fişleri
        ("belge.alis.irsaliye", "belge.alis"),                  // Alış › Alış İrsaliyeleri
        ("belge.alis.konsinye", "belge.alis"),                  // Alış › Alış Konsinyeler
        ("belge.alis.tahakkuk", "belge.alis"),                  // Alış › Tahakkuklar
        ("belge.satis.acik_satir", "belge.satis"),              // Satış › Açık Satırlar
        ("belge.satis.ayar", "belge.satis"),                    // Satış › Ayarlar › Satış Belgeleri
        ("belge.satis.fatura", "belge.satis"),                  // Satış › Satış Faturaları
        ("belge.satis.fis", "belge.satis"),                     // Satış › Satış Fişleri
        ("belge.satis.irsaliye", "belge.satis"),                // Satış › Satış İrsaliyeleri
        ("belge.satis.siparis", "belge.satis"),                 // Satış › Satış Siparişleri
        ("belge.satis.tahakkuk", "belge.satis"),                // Satış › Tahakkuklar
        ("belge.stok.cikis", "belge.stok"),                     // Stok & Hizmet › Çıkış Fişi
        ("belge.stok.giris", "belge.stok"),                     // Stok & Hizmet › Giriş Fişi
        ("belge.stok.transfer", "belge.stok"),                  // Stok & Hizmet › Stok Transfer
        ("cagri.ayar.agent", "cagri.ayar"),                     // Çağrı Merkezi › Ayarlar › Agentlar (dahili)
        ("cagri.ayar.kuyruk", "cagri.ayar"),                    // Çağrı Merkezi › Ayarlar › Kuyruklar & SLA
        ("cagri.ayar.santral", "cagri.ayar"),                   // Çağrı Merkezi › Ayarlar › Santral · IVR · Kanallar
        ("cari.kisi", "cari"),                                  // Cari & CRM › Kişi Listesi
        ("cek_senet.senet", "cek_senet"),                       // Finans › Senet Listesi
        ("cihaz.mesaj", "cihaz"),                               // Laboratuvar › Biyokimya › Cihaz Mesajları
        ("dis.unit.lab", "dis.unit"),                           // Diş › Ayarlar › Laboratuvarlar
        ("dokuman.kategori", "dokuman"),                        // Doküman › Ayarlar › Kategoriler
        ("dokuman.klasor", "dokuman"),                          // Doküman › Ayarlar › Klasörler
        ("entegrasyon.kod_esleme", "entegrasyon"),              // e-Nabız › Ayarlar › Kod Eşleme
        ("entegrasyon.kuyruk", "entegrasyon"),                  // e-Nabız › Gönderim Kuyruğu
        ("fiyat_listesi.kampanya", "fiyat_listesi"),            // Kurumlar & Sigorta › Ayarlar › Kampanyalar
        ("ftr.seans.liste", "ftr.seans"),                       // FTR › Seanslar
        ("goz.hasta_ozet", "goz"),                              // Göz › Hasta Özeti
        ("goz.cihaz.mesaj", "goz.cihaz"),                       // Göz › Ayarlar › Cihaz Mesajları
        ("goz.islem.protokol", "goz.islem"),                    // Göz › Ayarlar › İşlem Protokolleri
        ("goz.recete.kontakt_lens", "goz.recete"),              // Göz › Kontakt Lens
        ("hesap.tanim.banka", "hesap.tanim"),                   // Finans › Banka Hesapları
        ("hesap.tanim.banka_tanim", "hesap.tanim"),             // Finans › Ayarlar › Banka Tanımları
        ("hesap.tanim.ekstre", "hesap.tanim"),                  // Finans › Hesap Ekstresi
        ("hesap.tanim.kredi", "hesap.tanim"),                   // Finans › Krediler
        ("hesap.tanim.kredi_karti", "hesap.tanim"),             // Finans › Kredi Kartı
        ("hesap.tanim.pos", "hesap.tanim"),                     // Finans › POS
        ("ik.izin.bakiye", "ik.izin"),                          // İK › İzin Bakiyesi
        ("islem_log.giris", "islem_log"),                       // Yönetim › Güvenlik › Giriş Kayıtları
        ("kasa.finans.ayar", "kasa.finans"),                    // Finans › Ayarlar › Kasa
        ("kasa.finans.vade", "kasa.finans"),                    // Finans › Vade / Planlar
        ("katalog.ilac", "katalog"),                            // Muayene › Ayarlar › İlaç Kataloğu
        ("katalog.klinik", "katalog"),                          // Muayene › Ayarlar › Klinik Kataloglar
        ("kullanici.onay_akis", "kullanici"),                   // Yönetim › Onay Akışları
        ("kullanici.onay_vekalet", "kullanici"),                // Yönetim › Onay Vekâleti
        ("kurum.icmal", "kurum"),                               // Kurumlar & Sigorta › Kurum İcmalleri
        ("lab.akilci_karar", "lab"),                            // Laboratuvar › Akılcı İstem Kararları
        ("lab.arsiv.kayit", "lab.arsiv"),                       // Laboratuvar › Arşiv Kayıtları
        ("lab.dislab.tanim", "lab.dislab"),                     // Laboratuvar › Ayarlar › Dış Laboratuvarlar
        ("lab.gen.panel", "lab.gen"),                           // Laboratuvar › Ayarlar › Genetik Panelleri
        ("lab.genetik.run", "lab.genetik"),                     // Laboratuvar › Genetik › Dizileme Runları
        ("lab.genetik.varyant", "lab.genetik"),                 // Laboratuvar › Genetik › Varyantlar
        ("lab.kk.cihaz_olay", "lab.kk"),                        // Laboratuvar › Biyokimya › Cihaz Olayları
        ("lab.kk.dkk", "lab.kk"),                               // Laboratuvar › Biyokimya › Dış Kalite
        ("lab.kk.kural", "lab.kk"),                             // Laboratuvar › Ayarlar › Westgard Kuralları
        ("lab.kk.lot", "lab.kk"),                               // Laboratuvar › Biyokimya › Kontrol Lotları
        ("lab.mikro.antibiyotik", "lab.mikro"),                 // Laboratuvar › Ayarlar › Antibiyotikler
        ("lab.mikro.besiyeri", "lab.mikro"),                    // Laboratuvar › Ayarlar › Besiyerleri
        ("lab.tetkik.akilci_kural", "lab.tetkik"),              // Laboratuvar › Ayarlar › Akılcı İstem Kuralları
        ("lab.tetkik.indeks", "lab.tetkik"),                    // Laboratuvar › Ayarlar › Serum İndeksi
        ("lab.tetkik.panel", "lab.tetkik"),                     // Laboratuvar › Ayarlar › Paneller
        ("lab.tetkik.refleks_kural", "lab.tetkik"),             // Laboratuvar › Ayarlar › Refleks Test Kuralları
        ("medula.cagri_gunlugu", "medula"),                     // Medula › Ayarlar › Çağrı Günlüğü
        ("medula.kuyruk_ayar", "medula"),                       // Medula › Gönderim Kuyruğu & Ayarlar
        ("medula.fatura.donem", "medula.fatura"),               // Medula › Dönemler
        ("medula.fatura.kesinti", "medula.fatura"),             // Medula › Kesinti / İtiraz
        ("medula.fatura.liste", "medula.fatura"),               // Medula › Faturalar
        ("medula.recete.rapor", "medula.recete"),               // Medula › e-Rapor
        ("muayene.liste", "muayene"),                           // Muayene › Muayeneler
        ("muayene.makro", "muayene"),                           // Muayene › Ayarlar › Metin Makroları
        ("muayene.recete", "muayene"),                          // Muayene › Reçeteler
        ("muayene.sablon", "muayene"),                          // Muayene › Ayarlar › Muayene Şablonları
        ("onam.kayit", "onam"),                                 // Yönetim › Platform › Onam Kayıtları
        ("personel.bolum", "personel"),                         // İK › Bölüm / Görev
        ("prim.plan", "prim"),                                  // İK › Prim Planları
        ("prim.kendi.satir", "prim.kendi"),                     // Muayene › Prim Satırları
        ("radyoloji.cihaz", "radyoloji"),                       // Radyoloji › Ayarlar › Cihazlar
        ("radyoloji.konsultasyon", "radyoloji"),                // Radyoloji › Konsültasyonlar
        ("radyoloji.kritik", "radyoloji"),                      // Radyoloji › Kritik Bulgular
        ("radyoloji.protokol", "radyoloji"),                    // Radyoloji › Ayarlar › Çekim Protokolleri
        ("radyoloji.sablon", "radyoloji"),                      // Radyoloji › Ayarlar › Rapor Şablonları
        ("radyoloji.teslim", "radyoloji"),                      // Radyoloji › Sonuç Teslim
        ("randevu.plan.istisna", "randevu.plan"),               // Randevu › Ayarlar › Çalışma İstisnaları
        ("randevu.plan.sablon", "randevu.plan"),                // Randevu › Ayarlar › Çalışma Şablonları
        ("servis.cizelge", "servis"),                           // Teknik Servis › Çizelge
        ("servis.emanet", "servis"),                            // Teknik Servis › Emanet Cihazlar
        ("servis.is_emri", "servis"),                           // Teknik Servis › İş Emirleri
        ("servis.ziyaret", "servis"),                           // Teknik Servis › Ziyaretler
        ("sigorta.tanim.istek_log", "sigorta.tanim"),           // Kurumlar & Sigorta › İstek Günlüğü
        ("sigorta.tanim.kod_esleme", "sigorta.tanim"),          // Kurumlar & Sigorta › Ayarlar › Kod Eşleme
        ("steril.ayar.bakim", "steril.ayar"),                   // Diş › Ayarlar › Bakım · Validasyon
        ("steril.ayar.kural", "steril.ayar"),                   // Diş › Ayarlar › Test takvimi · Kurallar
        ("steril.ayar.program", "steril.ayar"),                 // Diş › Ayarlar › Programlar
        ("steril.birim.set_alet", "steril.birim"),              // Diş › Sterilizasyon › Setler · Döner Aletler
        ("steril.birim.set_tanim", "steril.birim"),             // Diş › Ayarlar › Set tanımları (içerik)
        ("steril.izleme.defter", "steril.izleme"),              // Diş › Sterilizasyon › İzlenebilirlik · Kayıt Defteri
        ("stok.ayar", "stok"),                                  // Stok & Hizmet › Ayarlar › Stok Ayarları
        ("stok.its", "stok"),                                   // Stok & Hizmet › İTS › Bildirimler
        ("stok.kategori", "stok"),                              // Stok & Hizmet › Ayarlar › Kategoriler
        ("teleradyoloji.bakanlik_eksik", "teleradyoloji"),      // Radyoloji › Teleradyoloji › Bakanlık Eksikleri
        ("teleradyoloji.gelen", "teleradyoloji"),               // Radyoloji › Teleradyoloji › Gelen Raporlar
        ("teleradyoloji.pano", "teleradyoloji"),                // Radyoloji › Teleradyoloji › Telerad Panosu
        ("teleradyoloji.teslim", "teleradyoloji"),              // Radyoloji › Teleradyoloji › Teslim Kuyruğu
        ("teleradyoloji.kurum.fatura", "teleradyoloji.kurum"),  // Radyoloji › Teleradyoloji › Dönem Faturası
        ("uretim.is_merkezi", "uretim"),                        // Üretim › Ayarlar › İş Merkezleri
        ("uretim.urun_agaci", "uretim"),                        // Üretim › Ürün Ağaçları
        ("uts.bildirim", "uts"),                                // Stok & Hizmet › ÜTS › Bildirimler
        ("uts.sorgu", "uts"),                                   // Stok & Hizmet › ÜTS › Ürün Sorgu
        ("yatan.icmal", "yatan"),                               // Yatan Hasta › Hizmet İcmali
        ("yatan.yatak_pano", "yatan"),                          // Yatan Hasta › Yatak Panosu
        ("yatan.order.uygulama", "yatan.order"),                // Yatan Hasta › İlaç Uygulama
    ];
}
