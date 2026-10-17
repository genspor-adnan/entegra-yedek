namespace Gentegre.Cekirdek.Yetki;

/// <summary>
/// MENÜ YERİNE GÖRE BÖLÜNEN EKRAN KODLARI (1003 — kullanıcı 09.10.2026:
/// "genprofil ile seçtiğim menüler yetki matrisinde görünecek.. yetki
/// matrisinde gor dediğim menüler de kullanıcı menüsünde görünecek",
/// "menü koduyla yetki matrisi kodları aynı olmalı", "A grubunun hepsini böl").
///
/// Bir yetki kodu FARKLI menü gruplarındaki ekranları birlikte açıyordu
/// (`belge.satis` hem Satış'ı hem Kurumlar &amp; Sigorta › Faturalar'ı,
/// `dokum` 28 grubun Dökümler'ini). Matristeki tek kutu menüde iki ayrı yeri
/// açıp kapatıyordu. Menü yerinin dışında kalan ekran kendi kodunu aldı; ana
/// gruptaki ekranlar eski kodu korur.
///
/// İKİ AYRI İŞ, TEK HARİTA:
///   <see cref="KopyaKaynagi"/> — göç (1003) ve standart rol şablonu yeni koda
///     eski kodun haklarını AYNEN verir: kimse yetki kazanmaz ya da kaybetmez,
///     yalnız kutular ayrılır.
///   <see cref="VeriKapisiAltlari"/> — ortak KAYNAK kullanan ekranlarda eski
///     kodun sunucu kapısı yeni kodla da açılır (Tedarikçiler `cari`
///     kaynağını, Medula Kabul `medula.provizyon` uçlarını kullanır). Kendi
///     kaynağı olan ekran (`eczane.miad`, `dis_doktor`) doğrudan yeni koda
///     bağlıdır, burada yoktur. `kayit_kabul.ayar` ayrıca dar tutulur
///     (yalnız kendi ayar anahtarları, bkz. AyarUclari).
///
/// Web tarafında aynı kodlar listeTanimlari'nda ve Dökümler öğelerinde durur.
/// </summary>
public static partial class EkranKodlari
{
    /// <summary>Grubun Dökümler ekranı kodu: <c>dokum.&lt;grup&gt;</c>.</summary>
    public static readonly IReadOnlyList<string> DokumKodlari =
    [
        "dokum.yonetim", "dokum.randevu", "dokum.kayit_kabul", "dokum.muayene",
        "dokum.laboratuvar", "dokum.radyoloji", "dokum.patoloji", "dokum.goz", "dokum.yatan_hasta",
        "dokum.dis", "dokum.ftr", "dokum.isyeri_hekimligi", "dokum.cagri_merkezi",
        "dokum.medula", "dokum.ameliyathane", "dokum.acil", "dokum.kurumlar_sigorta",
        "dokum.cari_crm", "dokum.satis", "dokum.alis", "dokum.stok_hizmet",
        "dokum.eczane", "dokum.satinalma", "dokum.uretim", "dokum.finans",
        "dokum.muhasebe", "dokum.ik", "dokum.dokuman", "dokum.teknik_servis",
        "dokum.sabit_varliklar",   // 1007
    ];

    /// <summary>Yeni ekran kodu → haklarını kopyaladığı eski kod.</summary>
    private static readonly Dictionary<string, string> Kopya = new(StringComparer.Ordinal)
    {
        ["belge.kurum_fatura"] = "belge.satis",       // Kurumlar & Sigorta › Faturalar
        ["belge.alis_fatura"]  = "belge.alis",        // Stok & Hizmet › Alış Faturaları
        ["eczane.miad"]        = "stok",              // Eczane › Miad & Tüketim
        ["kayit_kabul.ayar"]   = "ayar",              // Kayıt Kabul › Ayarlar › Kayıt Kabul
        ["cari.tedarikci"]     = "cari",              // Stok & Hizmet › Tedarikçiler
        ["dis_doktor"]         = "personel",          // Kurumlar & Sigorta › Dış Doktorlar
        ["medula.kabul"]       = "medula.provizyon",  // Kayıt Kabul › Medula Kabul
        ["demirbas.ayar"]      = "ayar",              // Sabit Varlıklar › Ayarlar › Demirbaş (1007)
        ["patoloji.dislab"]    = "lab.dislab",        // Patoloji › Dış Laboratuvarlar (Lab ile ORTAK kart, 1104)
    };

    /// <summary>
    /// Eski veri kodu → onun sunucu kapısını da açan ekran kodları. Belge
    /// kodları burada `belge` çekirdeğine bağlanır; hangi TÜRÜ göreceğini
    /// yine belge kümesi (tam eşleşme) belirler.
    /// </summary>
    private static readonly Dictionary<string, string[]> VeriKapisi = new(StringComparer.Ordinal)
    {
        // Belge ekranları `belge` kaynağını açar; hangi TÜRÜ göreceğini
        //   ekran kodunun kendi kümesi belirler (BelgeKisiti, 1004 aşama 2).
        ["belge"]            = ["belge.kurum_fatura", "belge.alis_fatura",
                                "belge.satis", "belge.satis.siparis", "belge.satis.irsaliye",
                                "belge.satis.fatura", "belge.satis.fis", "belge.satis.tahakkuk",
                                "belge.satis.acik_satir",
                                "belge.alis", "belge.alis.irsaliye", "belge.alis.fis",
                                "belge.alis.tahakkuk", "belge.alis.konsinye",
                                "belge.stok", "belge.stok.transfer", "belge.stok.giris", "belge.stok.cikis"],
        ["cari"]             = ["cari.tedarikci"],
        ["medula.provizyon"] = ["medula.kabul"],
        ["lab.dislab"]       = ["patoloji.dislab"],
        ["dokum"]            = [.. DokumKodlari],
        // 1004 aşama 2 Finans: hesap ekranı kodu `hesap` kaynağını ve liste
        //   içi ekstreyi açar; hangi satırı göreceğini SatirKisitlari belirler.
        ["hesap"]              = ["hesap.tanim", "hesap.tanim.banka", "hesap.tanim.kredi",
                                  "hesap.tanim.pos", "hesap.tanim.kredi_karti"],
        ["hesap.tanim.ekstre"] = ["hesap.tanim", "hesap.tanim.banka", "hesap.tanim.kredi",
                                  "hesap.tanim.pos", "hesap.tanim.kredi_karti"],
    };

    /// <summary>Ekran kodunun haklarını kopyaladığı eski kod; bölünmemiş kodda null.</summary>
    public static string? KopyaKaynagi(string kod)
        => Kopya.TryGetValue(kod, out var k) ? k
         // Liste ekranı kartının kodunu izler (şablon "randevu" diyorsa Randevu Listesi de gelir -
         //   yalnız Gör, bkz. StandartRolUclari.Eslestir).
         : YalnizGorListe.TryGetValue(kod, out var l) && !AyniGrupKopya.Value.ContainsKey(kod) ? l
         : AyniGrupKopya.Value.TryGetValue(kod, out var a) ? a
         : kod.StartsWith("dokum.", StringComparison.Ordinal) ? "dokum"
         : null;

    // AYNI GRUP TABLOSU (1004) başka dosyada: kısmi sınıfların statik alan
    //   sırası dosyalar arasında belirsiz, sözlükler ilk kullanımda kurulur.
    private static readonly Lazy<Dictionary<string, string>> AyniGrupKopya = new(() =>
        AyniGrupEkranlari.ToDictionary(x => x.Yeni, x => x.Eski, StringComparer.Ordinal));

    private static readonly Lazy<Dictionary<string, string[]>> TumVeriKapisi = new(() =>
    {
        var d = VeriKapisi.ToDictionary(x => x.Key, x => x.Value.ToList(), StringComparer.Ordinal);
        foreach (var (yeni, eski) in AyniGrupEkranlari)
        {
            if (KendiKapisi.Contains(yeni)) continue;
            if (!d.TryGetValue(eski, out var l)) d[eski] = l = [];
            l.Add(yeni);
        }
        return d.ToDictionary(x => x.Key, x => x.Value.ToArray(), StringComparer.Ordinal);
    });

    /// <summary>
    /// SEÇİM KAPISI - yalnız GÖR (kullanıcı 09.10.2026: "başvuru açtım ama
    /// ücret ekleyemedim.. yetkisiz dedi"). Başvuruya ücret satırı eklerken
    /// hizmet aranır ve fiyat listesinden fiyat okunur. Banko görevlisine
    /// `hizmet` / `fiyat_listesi` vermek menüde Hizmetler ve Fiyat Listeleri
    /// ekranlarını açardı (matris = menü). Satır ekleyebilen kişi (`belge_satir`)
    /// bu kaynakları yalnız OKUR - menüsü `/ben`'deki gerçek kodlardan
    /// çizildiği için değişmez, yazma hakkı da gelmez.
    /// </summary>
    private static readonly Dictionary<string, string[]> GorKapisi = new(StringComparer.Ordinal)
    {
        ["hizmet"]        = ["belge_satir"],
        ["fiyat_listesi"] = ["belge_satir"],
        // Ücret penceresi stok (malzeme + birimleri) ve ilaç kataloğunu da
        //   aynı aramada sorar; biri kapalıysa arama bütünüyle düşüyordu
        //   (kullanıcı: "ücret ekleyemedim yine: Bu islem icin yetkiniz yok").
        ["stok"]          = ["belge_satir"],
        ["katalog"]       = ["belge_satir"],
    };

    /// <summary>
    /// LİSTE EKRANI YALNIZ GÖR (1115 aşama 2 - kullanıcı 17.10.2026: "Hasta Listesi yetkisi sade
    /// Gör/Görme ve hasta kartı yetkisi Gör/ekle/değiş/sil"). Liste ekran kodu yalnız GÖR taşır: menüde
    /// ekranı açar ve veri kodunu yalnız OKUMADA açar (liste satırları, kartı salt okunur açma). Kart
    /// işlemleri (ekle / değiştir / sil, liste araç çubuğundaki Yeni / Sil dahil) yalnız VERİ koduna
    /// bakar. Kodun Ekle / Değiştir / Sil'i hiçbir yerde sayılmaz (<see cref="YetkiSeti.VarTam"/>).
    /// Aşama 1'de liste kodu veri kodunun kapısını BÜTÜN işlemlerde açıyordu: listeye verilen Ekle
    /// fiilen hasta kartına verilmiş oluyordu. Desen başarılı olursa öteki listelere yayılacak.
    /// </summary>
    private static readonly Dictionary<string, string> YalnizGorListe = new(StringComparer.Ordinal)
    {
        ["hasta.liste"]   = "hasta",   // Kayıt Kabul › Hasta Listesi   - kart / veri: hasta
        ["basvuru.liste"] = "belge",   // Kayıt Kabul › Başvuru Listesi - kart / veri: belge (başvuru)
        // PİLOT YAYILIM (göç 1128, kullanıcı 17.10.2026: "deseni diğer liste/kart özelliği olan menülere
        //   uygula" -> "önce pilot grup"): Randevu + Radyoloji'nin kartını KENDİ koduyla açan listeleri.
        //   Kod adı bilinçli olarak açık tablo - `.liste` soneki başka anlamda da kullanılıyor
        //   (muayene.liste, ftr.seans.liste, medula.fatura.liste aşama 1 bölme kodları).
        ["randevu.liste"]                = "randevu",
        ["randevu.plan.sablon.liste"]    = "randevu.plan.sablon",
        ["randevu.plan.istisna.liste"]   = "randevu.plan.istisna",
        ["radyoloji-istem.liste"]        = "radyoloji-istem",
        ["radyoloji.sablon.liste"]       = "radyoloji.sablon",
        ["radyoloji.protokol.liste"]     = "radyoloji.protokol",
        ["radyoloji.cihaz.liste"]        = "radyoloji.cihaz",
        ["teleradyoloji.liste"]          = "teleradyoloji",
        ["teleradyoloji.kurum.liste"]    = "teleradyoloji.kurum",
        ["teleradyoloji.nobet.liste"]    = "teleradyoloji.nobet",
        ["teleradyoloji.kural.liste"]    = "teleradyoloji.kural",
        ["teleradyoloji.sozlesme.liste"] = "teleradyoloji.sozlesme",
        // ESKİ AŞAMA 1 LİSTE KODLARI (göç 1130, grup 1): liste ekranı için zaten bölünmüştü ama tam
        //   yetki taşıyordu; kart = aşama 1'in eski kodu (KendiKapisi'nde de - tam köprü kalktı).
        ["muayene.liste"]                = "muayene",
        ["ftr.seans.liste"]              = "ftr.seans",
        ["medula.fatura.liste"]          = "medula.fatura",
        // KARTI BAŞKA EKRANDA (göç 1132, grup 3): ortak kaynağı tam açan aşama 1 kodları - yalnız Gör.
        ["radyoloji.kritik"] = "radyoloji",
        ["radyoloji.konsultasyon"] = "radyoloji",
        ["radyoloji.teslim"] = "radyoloji",
        ["servis.is_emri"] = "servis",
        // ORTAK KODLU LİSTELER (göç 1131, grup 2): kodun bütün liste ekranları; "(kart)" ekranı kartta.
        ["ftr.program.liste"] = "ftr.program",
        ["isg.calisan.liste"] = "isg.calisan",
        ["cagri.kayit.liste"] = "cagri.kayit",
        ["cagri.kampanya.liste"] = "cagri.kampanya",
        ["steril.dongu.liste"] = "steril.dongu",
        ["kys.denetim.liste"] = "kys.denetim",
        ["kys.gosterge.liste"] = "kys.gosterge",
        ["kys.toplanti.liste"] = "kys.toplanti",
        ["kys.egitim.liste"] = "kys.egitim",
        ["fiyat_listesi.liste"] = "fiyat_listesi",
        // KALAN GRUPLAR (göç 1129, kullanıcı: "kalan grupları da tek göçle yap"): aday üretici seçti -
        //   menüde, kartı kendi rotasında, kodu tek ekranda, listesi kodla ya da köprüyle açılan listeler.
        ["asi.katalog.liste"] = "asi.katalog",
        ["sigorta.tanim.kod_esleme.liste"] = "sigorta.tanim.kod_esleme",
        ["cihaz.liste"] = "cihaz",
        ["muayene.recete.liste"] = "muayene.recete",
        ["muayene.sablon.liste"] = "muayene.sablon",
        ["bzbh.hastalik.liste"] = "bzbh.hastalik",
        ["muayene.makro.liste"] = "muayene.makro",
        ["lab.liste"] = "lab",
        ["lab.tetkik.liste"] = "lab.tetkik",
        ["lab.tetkik.panel.liste"] = "lab.tetkik.panel",
        ["lab.arsiv_konum.liste"] = "lab.arsiv_konum",
        ["lab.saklama_politika.liste"] = "lab.saklama_politika",
        ["lab.ret_nedeni.liste"] = "lab.ret_nedeni",
        ["lab.tetkik.akilci_kural.liste"] = "lab.tetkik.akilci_kural",
        ["lab.tetkik.refleks_kural.liste"] = "lab.tetkik.refleks_kural",
        ["lab.kk.dkk.liste"] = "lab.kk.dkk",
        ["lab.kk.lot.liste"] = "lab.kk.lot",
        ["lab.dislab.tanim.liste"] = "lab.dislab.tanim",
        ["lab.tetkik.indeks.liste"] = "lab.tetkik.indeks",
        ["lab.kk.kural.liste"] = "lab.kk.kural",
        ["lab.kk.cihaz_olay.liste"] = "lab.kk.cihaz_olay",
        ["lab.gen.liste"] = "lab.gen",
        ["lab.gen.panel.liste"] = "lab.gen.panel",
        ["lab.mikro.liste"] = "lab.mikro",
        ["lab.mikro.antibiyotik.liste"] = "lab.mikro.antibiyotik",
        ["lab.mikro.besiyeri.liste"] = "lab.mikro.besiyeri",
        ["lab.cihaz.liste"] = "lab.cihaz",
        ["patoloji.vaka.liste"] = "patoloji.vaka",
        ["patoloji.gonderim.liste"] = "patoloji.gonderim",
        ["patoloji.dislab.liste"] = "patoloji.dislab",
        ["patoloji.tanim.materyal.liste"] = "patoloji.tanim.materyal",
        ["patoloji.tanim.boya.liste"] = "patoloji.tanim.boya",
        ["patoloji.tanim.ret.liste"] = "patoloji.tanim.ret",
        ["muayene.konsultasyon.liste"] = "muayene.konsultasyon",
        ["goz.kaynak.liste"] = "goz.kaynak",
        ["goz.muayene.liste"] = "goz.muayene",
        ["goz.goruntuleme.liste"] = "goz.goruntuleme",
        ["goz.islem.liste"] = "goz.islem",
        ["goz.recete.liste"] = "goz.recete",
        ["goz.takip.liste"] = "goz.takip",
        ["goz.recete.kontakt_lens.liste"] = "goz.recete.kontakt_lens",
        ["goz.islem.protokol.liste"] = "goz.islem.protokol",
        ["goz.cihaz.liste"] = "goz.cihaz",
        ["goz.dikte_sozluk.liste"] = "goz.dikte_sozluk",
        ["yatan.liste"] = "yatan",
        ["yatan.order.liste"] = "yatan.order",
        ["yatan.yatak.liste"] = "yatan.yatak",
        ["dis.plan.liste"] = "dis.plan",
        ["dis.seans.liste"] = "dis.seans",
        ["dis.lab.liste"] = "dis.lab",
        ["dis.odeme.liste"] = "dis.odeme",
        ["dis.unit.liste"] = "dis.unit",
        ["dis.unit.lab.liste"] = "dis.unit.lab",
        ["ftr.degerlendirme.liste"] = "ftr.degerlendirme",
        ["ftr.olcek.liste"] = "ftr.olcek",
        ["ftr.unite.liste"] = "ftr.unite",
        ["form.sablon.liste"] = "form.sablon",
        ["form.kural.liste"] = "form.kural",
        ["isg.muayene.liste"] = "isg.muayene",
        ["isg.ziyaret.liste"] = "isg.ziyaret",
        ["isg.olay.liste"] = "isg.olay",
        ["isg.firma.liste"] = "isg.firma",
        ["cagri.kalite.liste"] = "cagri.kalite",
        ["cagri.ayar.liste"] = "cagri.ayar",
        ["cagri.ayar.kuyruk.liste"] = "cagri.ayar.kuyruk",
        ["cagri.ayar.agent.liste"] = "cagri.ayar.agent",
        ["steril.birim.set_alet.liste"] = "steril.birim.set_alet",
        ["steril.birim.set_tanim.liste"] = "steril.birim.set_tanim",
        ["steril.ayar.liste"] = "steril.ayar",
        ["steril.ayar.program.liste"] = "steril.ayar.program",
        ["steril.ayar.bakim.liste"] = "steril.ayar.bakim",
        ["medula.recete.rapor.liste"] = "medula.recete.rapor",
        ["medula.fatura.donem.liste"] = "medula.fatura.donem",
        ["medula.fatura.kesinti.liste"] = "medula.fatura.kesinti",
        ["klinik_kalite.donem.liste"] = "klinik_kalite.donem",
        ["kys.olay.liste"] = "kys.olay",
        ["kys.risk.liste"] = "kys.risk",
        ["kys.dof.liste"] = "kys.dof",
        ["kys.tedarikci.liste"] = "kys.tedarikci",
        ["kys.kalibrasyon.liste"] = "kys.kalibrasyon",
        ["ameliyathane.talep.liste"] = "ameliyathane.talep",
        ["ameliyathane.salon.liste"] = "ameliyathane.salon",
        ["acil.yatak.liste"] = "acil.yatak",
        ["entegrasyon.kod_esleme.liste"] = "entegrasyon.kod_esleme",
        ["cari.liste"] = "cari",
        ["cari.tedarikci.liste"] = "cari.tedarikci",
        ["kurum.liste"] = "kurum",
        ["cari.kisi.liste"] = "cari.kisi",
        ["dis_doktor.liste"] = "dis_doktor",
        ["proje.liste"] = "proje",
        ["gorev.liste"] = "gorev",
        ["firsat.liste"] = "firsat",
        ["aday.liste"] = "aday",
        ["hesap_plani.liste"] = "hesap_plani",
        ["masraf_merkezi.liste"] = "masraf_merkezi",
        ["fiyat_listesi.kampanya.liste"] = "fiyat_listesi.kampanya",
        ["hesap.tanim.liste"] = "hesap.tanim",
        ["banko.liste"] = "banko",
        ["hesap.tanim.banka.liste"] = "hesap.tanim.banka",
        ["hesap.tanim.kredi.liste"] = "hesap.tanim.kredi",
        ["hesap.tanim.pos.liste"] = "hesap.tanim.pos",
        ["hesap.tanim.kredi_karti.liste"] = "hesap.tanim.kredi_karti",
        ["hesap.tanim.banka_tanim.liste"] = "hesap.tanim.banka_tanim",
        ["cek_senet.liste"] = "cek_senet",
        ["cek_senet.senet.liste"] = "cek_senet.senet",
        ["stok.liste"] = "stok",
        ["hizmet.liste"] = "hizmet",
        ["uretim.urun_agaci.liste"] = "uretim.urun_agaci",
        ["uretim.liste"] = "uretim",
        ["uretim.is_merkezi.liste"] = "uretim.is_merkezi",
        ["eczane.order.liste"] = "eczane.order",
        ["eczane.doz.liste"] = "eczane.doz",
        ["eczane.hazirlama.liste"] = "eczane.hazirlama",
        ["eczane.iade.liste"] = "eczane.iade",
        ["eczane.imha.liste"] = "eczane.imha",
        ["demirbas.kalibrasyon.liste"] = "demirbas.kalibrasyon",
        ["demirbas.isemri.liste"] = "demirbas.isemri",
        ["satinalma.talep.liste"] = "satinalma.talep",
        ["satinalma.teklif.liste"] = "satinalma.teklif",
        ["satinalma.kabul.liste"] = "satinalma.kabul",
        ["satinalma.butce.liste"] = "satinalma.butce",
        ["kullanici.onay_akis.liste"] = "kullanici.onay_akis",
        ["kullanici.onay_vekalet.liste"] = "kullanici.onay_vekalet",
        ["ik.izin.liste"] = "ik.izin",
        ["ik.avans.liste"] = "ik.avans",
        ["ik.masraf.liste"] = "ik.masraf",
        ["ik.belge_talep.liste"] = "ik.belge_talep",
        ["ik.tatil.liste"] = "ik.tatil",
        ["ik.izin_hak.liste"] = "ik.izin_hak",
        ["kullanici.liste"] = "kullanici",
        ["personel.liste"] = "personel",
        ["prim.plan.liste"] = "prim.plan",
        ["demirbas.liste"] = "demirbas",
        ["dokuman.liste"] = "dokuman",
        ["dokuman.kategori.liste"] = "dokuman.kategori",
        ["dokuman.klasor.liste"] = "dokuman.klasor",
        ["onam.liste"] = "onam",
        ["bildirim_sablon.liste"] = "bildirim_sablon",
        ["zamanli_is.liste"] = "zamanli_is",
        ["rol.liste"] = "rol",
        ["ik.kadro.liste"] = "ik.kadro",
    };

    /// <summary>Kod yalnız Gör taşıyan bir liste ekranı mı (Ekle / Değiştir / Sil'i yok sayılır).</summary>
    public static bool YalnizGor(string kod) => YalnizGorListe.ContainsKey(kod);

    /// <summary>Liste ekran kodlarının hepsi (matris / şablon / göç aynı listeyi kullanır).</summary>
    public static IReadOnlyCollection<string> YalnizGorKodlari => YalnizGorListe.Keys;

    /// <summary>Bu veri kodunu YALNIZ OKUMADA açan liste ekran kodları (yoksa boş).</summary>
    public static IReadOnlyList<string> ListeGorAltlari(string veriKodu)
        => YalnizGorListe.Where(x => x.Value == veriKodu).Select(x => x.Key).ToArray();

    /// <summary>
    /// OKUMA KÖPRÜSÜ (liste / kart ayrımı grup 4, 17.10.2026). Bu ekranların listesi BAŞKA bir kaynağın
    /// verisini gösteriyor ama ekran kodu o kaynağa hiç bağlanmamıştı: menüde görünen liste, yalnız o
    /// ekran yetkisi olan kullanıcıda 403 veriyordu (Sevk, e-Reçete, Klinik Kalite Göstergesi, Kasa
    /// İşlemleri). Ekran kodu kaynağı YALNIZ OKUMADA açar; kodun kendi hakları (e-Reçete gönderme,
    /// Klinik Kalite kartı) ve kaynağın kartı değişmez - yazmak için kaynağın kendi yetkisi gerekir.
    /// </summary>
    private static readonly Dictionary<string, string[]> OkumaKapisi = new(StringComparer.Ordinal)
    {
        ["muayene"]       = ["muayene.sevk", "medula.recete"],   // Muayene › Sevk Listesi, Medula › e-Reçete
        ["klinik_kalite"] = ["klinik_kalite.olgu"],             // Klinik Kalite › Gösterge Listesi
        ["kasa_islem"]    = ["kasa.finans"],                    // Finans › Kasa İşlemi Listesi
    };

    /// <summary>Bu kaynağı yalnız okumada açan ekran kodları (yoksa boş).</summary>
    public static IReadOnlyList<string> OkumaKapisiAltlari(string veriKodu)
        => OkumaKapisi.TryGetValue(veriKodu, out var a) ? a : [];

    /// <summary>Bu kaynağı yalnız görme işleminde açan kodlar (yoksa boş).</summary>
    public static IReadOnlyList<string> GorKapisiAltlari(string veriKodu)
        => GorKapisi.TryGetValue(veriKodu, out var a) ? a : [];

    /// <summary>Bu veri kodunun kapısını da açan ekran kodları (yoksa boş).</summary>
    public static IReadOnlyList<string> VeriKapisiAltlari(string veriKodu)
        => TumVeriKapisi.Value.TryGetValue(veriKodu, out var a) ? a : [];

    /// <summary>
    /// SATIR KURALI (kullanıcı 09.10.2026: "tedarikçi satır süzgecini de
    /// ekle"; 1004 aşama 2 Finans). Ekran kodu ortak bir kaynağı açtığında
    /// yalnız O EKRANIN satırlarını görür: `cari.tedarikci` müşteri listesini,
    /// `hesap.tanim.banka` kasa hesaplarını adres çubuğundan açamaz.
    /// </summary>
    /// <param name="Kod">Kuralın bağlı olduğu ekran kodu.</param>
    /// <param name="Kosul">Kaynağın kendi takma adıyla sabit SQL; kullanıcı girdisi yok.</param>
    /// <param name="Alan">Kartta bu ekranın kaydını belirleyen alan (yazmada korunur).</param>
    /// <param name="Deger">Alanın bu ekrana ait değeri (true = açık bayrak).</param>
    /// <param name="UstAlani">Kartta, kısıtı sağlayan üst kayda işaret eden alan.</param>
    /// <param name="UstKaynak">UstAlani'nin işaret ettiği kaynak (onun kuralı denetler).</param>
    public sealed record SatirKurali(string Kod, string Kosul, string? Alan = null, object? Deger = null,
                                     string? UstAlani = null, string? UstKaynak = null);

    /// <param name="Serbest">Bu kodlardan biri olan kullanıcıya kısıt uygulanmaz (veri çekirdeği).</param>
    public sealed record SatirKisiti(string[] Serbest, SatirKurali[] Kurallar);

    /// <summary>Kullanıcıya uygulanacak kısıt: geçerli kurallar ve birleşik koşul.</summary>
    public sealed record UygulananKisit(IReadOnlyList<SatirKurali> Kurallar)
    {
        /// <summary>Kurallardan biri yeter (veya); hiç kural yoksa kapı kapalı.</summary>
        public string Kosul => Kurallar.Count == 0 ? "false"
            : string.Join(" or ", Kurallar.Select(k => "(" + k.Kosul + ")"));
    }

    private static string HesapTuru(string tur) => $"h.tur = '{tur}'";
    private static string EkstreHesapTuru(string tur)
        => $"exists (select 1 from public.hesap eh where eh.id = e.hesap_id and eh.tur = '{tur}')";

    /// <summary>Kaynak/kart adı → satır kısıtı.</summary>
    private static readonly Dictionary<string, SatirKisiti> SatirKisitlari = new(StringComparer.Ordinal)
    {
        // Tedarikçiler ekranı: yalnız tedarikçi bayraklı cariler (`taraf t`).
        ["cari"] = new(["cari"], [new("cari.tedarikci", "t.tedarikci = 1", "tedarikci", true)]),
        // Tedarikçi kartının kişileri: yalnız tedarikçiye bağlı kişiler.
        ["kisi"] = new(["cari"], [new("cari.tedarikci",
            "exists (select 1 from public.taraf u where u.id = t.bag_id and u.tedarikci = 1)",
            UstAlani: "bagId", UstKaynak: "cari")]),

        // FİNANS (1004 aşama 2). Hesap ekranları tek `hesap` kaynağına türle
        //   bakar. `hesap` çekirdeği SERBEST: banko POS/hesap seçimi ve
        //   muhasebe tümünü görür (998 kararı). Yalnız ekran kodu olan kendi
        //   türünü görür ve karta yalnız o türü yazar.
        ["hesap"] = new(["hesap"],
        [
            new("hesap.tanim",             HesapTuru("K"), "tur", "K"),   // Kasa Hesapları
            new("hesap.tanim.banka",       HesapTuru("B"), "tur", "B"),   // Banka Hesapları
            new("hesap.tanim.kredi",       HesapTuru("R"), "tur", "R"),   // Krediler
            new("hesap.tanim.pos",         HesapTuru("P"), "tur", "P"),   // POS
            new("hesap.tanim.kredi_karti", HesapTuru("V"), "tur", "V"),   // Kredi Kartı
        ]),
        // Ekstre: kendi ekranı (Hesap Ekstresi) tümünü, hesap ekranlarının
        //   liste içi ekstresi yalnız kendi türündeki hesapları açar.
        ["hesap-ekstre"] = new(["hesap.tanim.ekstre"],
        [
            new("hesap.tanim",             EkstreHesapTuru("K")),
            new("hesap.tanim.banka",       EkstreHesapTuru("B")),
            new("hesap.tanim.kredi",       EkstreHesapTuru("R")),
            new("hesap.tanim.pos",         EkstreHesapTuru("P")),
            new("hesap.tanim.kredi_karti", EkstreHesapTuru("V")),
        ]),
        // Çek / Senet tek kaynak, türle ayrılır; ikisi de ekran kodu, serbest yok.
        ["cek-senet"] = new([],
        [
            new("cek_senet",       "c.tur = 1", "tur", (short)1),   // Çek Listesi
            new("cek_senet.senet", "c.tur = 2", "tur", (short)2),   // Senet Listesi
        ]),
    };

    /// <summary>
    /// Kaynağa/karta uygulanacak kısıt; kısıtsız kaynakta ya da kullanıcı
    /// serbest bir koda sahipse null.
    /// </summary>
    public static UygulananKisit? Kisit(string ad, Func<string, bool> tamVar)
    {
        if (!SatirKisitlari.TryGetValue(ad, out var k) || k.Serbest.Any(tamVar)) return null;
        return new UygulananKisit(k.Kurallar.Where(x => tamVar(x.Kod)).ToList());
    }

    /// <summary>
    /// AŞAMA 2'YE GEÇEN EKRANLAR: kendi kaynağına doğrudan bağlandı, eski
    /// kodun kapısını artık AÇMAZ (aşama 1 köprüsü kalkar; kopya kaynağı kalır).
    /// </summary>
    private static readonly HashSet<string> KendiKapisi = new(StringComparer.Ordinal)
    {
        // Kayıt Kabul listeleri (1115 aşama 2) ve eski liste kodları (1130): veri kapısını yalnız
        //   Gör'de açar - YalnizGorListe.
        "hasta.liste", "basvuru.liste", "muayene.liste", "ftr.seans.liste", "medula.fatura.liste",
        "radyoloji.kritik", "radyoloji.konsultasyon", "radyoloji.teslim", "servis.is_emri",   // 1132
        "hesap.tanim.banka_tanim",   // banka kaynağı + kartı
        "hesap.tanim.ekstre",        // hesap-ekstre kaynağı
        "kasa.finans.vade",          // plan-vade kaynağı
        "kasa.finans.ayar",          // yalnız kasa ayar anahtarları (AyarUclari)
        // Satış / Alış / Stok (1004 aşama 2): belge ekranı kendi türüyle,
        //   tek türlü kaynaklar (irsaliye, açık satır, stok fişleri) kendi kodu.
        "belge.satis.siparis", "belge.satis.irsaliye", "belge.satis.fatura", "belge.satis.fis",
        "belge.satis.tahakkuk", "belge.satis.acik_satir", "belge.satis.ayar",
        "belge.alis.irsaliye", "belge.alis.fis", "belge.alis.tahakkuk", "belge.alis.konsinye",
        "belge.alis.ayar",
        "belge.stok.transfer", "belge.stok.giris", "belge.stok.cikis",
        // Muayene (1004 aşama 2): yalnız Metin Makroları yönetimi ayrıldı.
        "muayene.makro",
        // Radyoloji (1004 aşama 2): yalnız Çekim Protokolleri tanımı ayrıldı.
        "radyoloji.protokol",
        // Laboratuvar (1004 aşama 2): yalnız kural / denetim tanımları.
        "lab.akilci_karar", "lab.kk.kural", "lab.tetkik.akilci_kural",
        "lab.tetkik.refleks_kural", "lab.tetkik.indeks",
        // Klinik modüller (1004 aşama 2): yalnız Göz İşlem Protokolleri tanımı.
        "goz.islem.protokol",
        // Yönetim / ERP (1004 aşama 2): tanım, günlük ve araç ekranları.
        "ayar.demo_verisi", "islem_log.giris", "kullanici.onay_akis", "kullanici.onay_vekalet",
        "ik.izin.bakiye", "dokuman.kategori", "sigorta.tanim.kod_esleme",
        "sigorta.tanim.istek_log", "uretim.is_merkezi", "stok.ayar",
        // Sabit Varlıklar (1007): Zimmet / Hareketler kendi uçlarında
        //   (DemirbasZimmetUclari), demirbaş kartının kapısını açmaz.
        "demirbas.zimmet", "demirbas.ayar",
        // Vezne İcmali (1016): kendi ucu (VezneIcmalUclari) kendi koduna bakar.
        "banko.vezne_icmal",
        // Medula Mutabakat İcmali (1017): /api/medula/mutabakat kendi koduna bakar.
        "medula.mutabakat",
        // Alacak Yaşlandırma (1019): /api/alacak-yaslandirma kendi koduna bakar.
        "finans.alacak_yaslandirma",
        // Hasta Borç Takibi (1020): /api/hasta-borc kendi koduna bakar.
        "hasta.borc_takip",
        // Doktor Performans İcmali (1021): /api/hekim-performans kendi koduna bakar.
        "prim.hekim_performans",
        // İskonto İcmali (1023): /api/iskonto-icmal kendi koduna bakar.
        "iskonto.icmal",
        // Hasta Başı Maliyet (1024): /api/maliyet-icmal kendi koduna bakar.
        "maliyet.hasta_basi",
        // Sevk Eden İcmali (1025): /api/sevk-eden kendi koduna bakar.
        "prim.sevk_eden",
        // Laboratuvar İcmali (1026): /api/lab-icmal kendi koduna bakar.
        "lab.icmal",
        // Görüntüleme İcmali (1027): /api/goruntuleme-icmal kendi koduna bakar.
        "radyoloji.icmal",
        // Yatan Hasta İcmali (1028): /api/yatan-icmal kendi koduna bakar.
        "yatan.donem_icmal",
        // Kasa / Gün Sonu Mutabakatı (1030): /api/kasa-gun-sonu kendi koduna bakar.
        "kasa.gun_sonu",
        // Çağrı Merkezi İcmali (1031): /api/cagri-icmal kendi koduna bakar.
        "cagri.icmal",
        // Sterilizasyon İcmali (1032): /api/steril-icmal kendi koduna bakar.
        "steril.icmal",
        // Fatura / e-Belge İcmali (1035): /api/efatura-icmal kendi koduna bakar.
        "efatura.icmal",
        // Ameliyathane İcmali (1040): /api/ameliyathane-icmal kendi koduna bakar.
        "ameliyathane.icmal",
        // Diş İcmali (1041): /api/dis-icmal kendi koduna bakar.
        "dis.icmal",
        // Eczane / İlaç İcmali (1042): /api/eczane-icmal kendi koduna bakar.
        "eczane.icmal",
        // FTR İcmali (1043): /api/ftr-icmal kendi koduna bakar.
        "ftr.icmal",
        // İSG / OSGB İcmali (1044): /api/isg-icmal kendi koduna bakar.
        "isg.icmal",
        // Kalite / SKS İcmali (1045): /api/kalite-icmal kendi koduna bakar.
        "kalite.icmal",
        // Randevu / Poliklinik İcmali (1046): /api/randevu-icmal kendi koduna bakar.
        "randevu.icmal",
    };

    // BİLİNÇLİ KÖPRÜ - MUAYENE (1004 aşama 2, kullanıcı: "Muayene'ye geç"):
    //   Reçeteler (`recete`), Muayeneler (`muayene`), Muayene Şablonları,
    //   ICD / İlaç katalogları ve Prim Satırları kaynakları menü ekranının
    //   DIŞINDA hekimin klinik akışında da kullanılır: reçete kartı muayenede
    //   reçete yazarken, muayene kartı Diş / İSG / başvurudan, şablon muayene
    //   içinde, ICD / ilaç her tanı ve ilaç seçiminde açılır. Bu kaynakları
    //   ekran koduna bağlamak "Reçeteler menüsü kapalı hekim reçete yazamaz"
    //   demek olurdu. Menü ve matris ekran başına AYRIK; veri çekirdek klinik
    //   koddan (`muayene`, `katalog`, `prim.kendi`) açılmaya devam eder ve bu
    //   ekranların köprüsü kasıtlı olarak kalır.
    //
    // BİLİNÇLİ KÖPRÜ - RADYOLOJİ: Rapor Şablonları (rapor yazarken şablon
    //   kartı yüklenir), Cihazlar (randevuda cihaz seçimi), Kritik Bulgular /
    //   Konsültasyonlar / Sonuç Teslim ve teleradyoloji listeleri (iş akışı
    //   ekranları; işlemleri çekirdek `radyoloji` / `teleradyoloji` uçlarıyla
    //   yapılır - ayırmak "ekranı görür, işlem yapamaz" demek olurdu).
    //
    // BİLİNÇLİ KÖPRÜ - LABORATUVAR: Paneller (istem sepeti), Antibiyotik /
    //   Besiyeri (mikrobiyoloji sonuç girişi), Kontrol Lotları (KK ölçümünde
    //   lot seçimi), Dış Laboratuvarlar (gönderimde lab seçimi), Genetik
    //   Panelleri / Varyant / Run (vaka akışı), Dış Kalite / Cihaz Olayları
    //   (KK akışı), Arşiv Kayıtları ve Cihaz Mesajları (Göz / Lab ekranları).
    //
    // BİLİNÇLİ KÖPRÜ - KLİNİK MODÜLLER: Sterilizasyon program / bakım / set
    //   listeleri (Steril Ayarlar sayfası ve pano birlikte kullanır), Diş
    //   Laboratuvarları (diş akışının beş ekranı), Çalışma Şablon / İstisna
    //   (Çalışma Planı ve izin talebi), e-Nabız Kod Eşleme (e-Nabız panosu),
    //   Çağrı kuyruk / agent (Santral sayfası), Medula kuyruğu (kuyruk
    //   bileşeni), Göz cihaz mesajı / kontakt lens / hasta özeti, Yatak
    //   Panosu / Hizmet İcmali / İlaç Uygulama, FTR Seanslar, Masa Çizelgesi,
    //   Acil Çağrılar, Medula fatura / dönem / kesinti ve e-Rapor (iş akışı).
    //
    // BİLİNÇLİ KÖPRÜ - YÖNETİM / ERP: Kişi, Bölüm / Görev, Kategoriler,
    //   Kampanyalar (her yerde seçim listesi), Doküman Klasörleri (Dokümanlar
    //   paneli), Prim Planları (personel kartı), Onam Kayıtları (hasta onamı
    //   klinik akışta yazılır), Ürün Ağaçları (üretim emri buradan açılır),
    //   Arıza Ekipleri (talep atama), teknik servis / İTS / ÜTS / kurum icmali
    //   listeleri (iş akışı) ve Excel İçeri Alma (hedef kaynağın kendi
    //   yetkisiyle yazar).

    /// <summary>Ekran aşama 2'de kendi kaynağına bağlandı mı (eski kapıyı açmaz).</summary>
    public static bool KendiKapisinda(string kod) => KendiKapisi.Contains(kod);

    /// <summary>
    /// Ekran kodunun kendi ayar anahtarları: kod bunları genel `ayar`
    /// yetkisi olmadan yazar (AyarUclari).
    /// </summary>
    public static readonly IReadOnlyDictionary<string, string> AyarAnahtariKodu =
        new Dictionary<string, string>(StringComparer.Ordinal)
    {
        ["kasa.duzenleme_gun"] = "kasa.finans.ayar",
        ["stok.negatif_davranis"]       = "stok.ayar",
        ["demirbas.iade_lokasyon"]      = "demirbas.ayar",
        ["demirbas.tutanak_metni"]      = "demirbas.ayar",
        ["demirbas.amortisman_yontem"]  = "demirbas.ayar",
        ["demirbas.amortisman_omur"]    = "demirbas.ayar",
        ["demirbas.parca_depo"]         = "demirbas.ayar",
        ["belge.satis.vade_gun"]        = "belge.satis.ayar",
        ["belge.satis.varsayilan_seri"] = "belge.satis.ayar",
        ["belge.alis.vade_gun"]         = "belge.alis.ayar",
        ["belge.alis.varsayilan_seri"]  = "belge.alis.ayar",
    };

    /// <summary>
    /// Kayıt Kabul Ayarları sayfasının yazdığı anahtarlar. `kayit_kabul.ayar`
    /// yalnız bunları yazabilir - genel `ayar` kapısını açmak bütün kurum
    /// ayarlarını açmak olurdu.
    /// </summary>
    public static readonly IReadOnlySet<string> KayitKabulAyarAnahtarlari = new HashSet<string>(StringComparer.Ordinal)
    {
        "basvuru.pos_aksiyon", "basvuru.sgk_katilim_payi",
        "basvuru.sgk_katilim_kodlari", "basvuru.iskonto_onay_esik",
    };
}
