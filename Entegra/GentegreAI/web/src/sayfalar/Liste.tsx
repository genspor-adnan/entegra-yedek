import { useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { c, cm } from '../dil/ceviri';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../bilesenler/sekmeBaglami';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { RandevuTakvimi } from '../bilesenler/RandevuTakvimi';
import { DisLabPano } from '../bilesenler/dis/DisLabPano';
import { GenForm } from '../bilesenler/GenForm';
import { kartOzellestirme } from './liste/kartOzellestirme';
import { KaynakArama } from '../bilesenler/KaynakArama';
import { useMuayeneSekmeVerisi } from '../bilesenler/MuayeneSekmeleri';
import {
  type EBelgeMesaji, type Kosul, type ListeSatiri, hataMetni,
} from '../api/sozlesme';
import { LabKatalogAgaci, BOS_SECIM, type AgacSecim }
  from '../bilesenler/lab/LabKatalogAgaci';
import { api } from '../api/istemci';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { BankoOturumModali } from '../bilesenler/banko/BankoOturumModali';
import { IceriAlModali } from '../bilesenler/IceriAlModali';
import { RandevuBekleyenPanel, type BekleyenIstem }
  from '../bilesenler/radyoloji/RandevuBekleyenPanel';
import { KategoriSuzgeci } from '../bilesenler/KategoriSuzgeci';
import { TARIH_ON_AYARLAR } from './liste/tarihAralik';
import { KategoriAgacPaneli } from '../bilesenler/KategoriAgacPaneli';
import { KalemRolModali } from '../bilesenler/prim/KalemRolModali';
import { DonemKapatModali } from '../bilesenler/prim/DonemKapatModali';
import { efaturaCalistir } from '../bilesenler/efatura/efaturaIslem';
import { gelenBelgeAksiyonu, gelenCokluAksiyonu } from './gelenBelgeIslem';
import { utsAksiyonu } from './liste/utsAksiyonlari';
import { kasaAksiyonu } from './liste/kasaAksiyonlari';
import { bildirimAksiyonu } from './liste/bildirimAksiyonlari';
import { belgeTakipAksiyonu } from './liste/belgeTakipAksiyonlari';
import { belgeTuruAksiyonu } from './liste/belgeTuruAksiyonlari';
import { listePaneli, useListeEkrani, type ListeEkranBaglami } from './liste/listeEkranlari';
import { entegrasyonAksiyonu } from './liste/entegrasyonAksiyonlari';
import { zamanliIsAksiyonu } from './liste/zamanliIsAksiyonlari';
import { klinikKaliteAksiyonu } from './liste/klinikKaliteAksiyonlari';
import { kysOlayRiskAksiyonu } from './liste/kysOlayRiskAksiyonlari';
import { kysDokumanAksiyonu } from './liste/kysDokumanAksiyonlari';
import { kysKalibrasyonAksiyonu } from './liste/kysKalibrasyonAksiyonlari';
import { kysDofBagAksiyonu } from './liste/kysGostergeAksiyonlari';
import { kysTedarikciAksiyonu } from './liste/kysTedarikciAksiyonlari';
import { ameliyathaneAksiyonu } from './liste/ameliyathaneAksiyonlari';
import { acilAksiyonu } from './liste/acilAksiyonlari';
import { tedarikAksiyonu } from './liste/tedarikAksiyonlari';
import { onayAksiyonu } from './liste/onayAksiyonlari';
import { izinAksiyonu } from './liste/izinAksiyonlari';
import { personelTalepSecenekleri } from '../bilesenler/taleplerim/personelTalebi';
import { servisAksiyonu } from './liste/servisAksiyonlari';
import { arizaAksiyonu } from './liste/arizaAksiyonlari';
import { useAmeliyatAcilModallari } from './liste/useAmeliyatAcilModallari';
import { AmeliyatAcilModallari } from './liste/AmeliyatAcilModallari';
import { ilacAksiyonu } from './liste/ilacAksiyonlari';
import { muayeneAksiyonu } from './liste/muayeneAksiyonlari';
import { hekimListesiAksiyonu } from './liste/hekimListesiAksiyonlari';
import { enabizAksiyonu } from './liste/enabizAksiyonlari';
import { dokumanAksiyonu } from './liste/dokumanAksiyonlari';
import { itsAksiyonu } from './liste/itsAksiyonlari';
import { uretimAksiyonu } from './liste/uretimAksiyonlari';
import { sigortaAksiyonu } from './liste/sigortaAksiyonlari';
import { cihazAksiyonu } from './liste/cihazAksiyonlari';
import { labAksiyonu } from './liste/labAksiyonlari';
import { mikroAksiyonu } from './liste/mikroAksiyonlari';
import { genetikAksiyonu } from './liste/genetikAksiyonlari';
import { kkAksiyonu } from './liste/kkAksiyonlari';
import { disLabAksiyonu } from './liste/disLabAksiyonlari';
import { patolojiAksiyonu } from './liste/patolojiAksiyonlari';
import { konsultasyonAksiyonu } from './liste/konsultasyonAksiyonlari';
import { BelgeTuruSiraModali } from '../bilesenler/BelgeTuruSiraModali';
import { GozSemasi } from '../bilesenler/goz/GozSemasi';
import { GozDikte } from '../bilesenler/goz/GozDikte';
import { IstemSepetiModal } from '../bilesenler/IstemSepetiModal';
import { YatisKabulModali } from '../bilesenler/yatan/YatisKabulModali';
import { DozSatirModali } from '../bilesenler/yatan/DozSatirModali';
import { NakilModali } from '../bilesenler/yatan/NakilModali';
import { TaburcuModali } from '../bilesenler/yatan/TaburcuModali';
import { yatanAksiyonu } from './liste/yatanAksiyonlari';
import { gozAkisAksiyonu } from './liste/gozAkisAksiyonlari';
import { disAksiyonu } from './liste/disAksiyonlari';
import { ftrAksiyonu } from './liste/ftrAksiyonlari';
import { formAksiyonu } from './liste/formAksiyonlari';
import { isgAksiyonu } from './liste/isgAksiyonlari';
import { cagriAksiyonu } from './liste/cagriAksiyonlari';
import { sterilAksiyonu } from './liste/sterilAksiyonlari';
import { medulaAksiyonu } from './liste/medulaAksiyonlari';
import { aiBaglamAyarla } from '../bilesenler/aiBaglam';
import { DokumanKlasorPaneli, type KlasorSecimi } from '../bilesenler/DokumanKlasorPaneli';
import { fiyatListesiAksiyonu } from './liste/fiyatListesiAksiyonlari';
import { ListeKarti } from './liste/ListeKarti';
import { useRandevuEkrani } from './liste/useRandevuEkrani';
import { useRadyolojiModallari } from './liste/useRadyolojiModallari';
import { RadyolojiModallari } from './liste/RadyolojiModallari';
import { SonucGirisModali } from '../bilesenler/lab/SonucGirisModali';
import { useUtsModallari } from './liste/useUtsModallari';
import { UtsModallari } from './liste/UtsModallari';
import { useBasvuruSuzgeci } from './liste/useBasvuruSuzgeci';
import { usePrimSuzgeci } from './liste/usePrimSuzgeci';
import { usePersonelSuzgeci } from './liste/usePersonelSuzgeci';
import { BasvuruSeridi } from './liste/BasvuruSeridi';
import { PrimSeridi } from './liste/PrimSeridi';
import { PersonelSeridi } from './liste/PersonelSeridi';
import { belgeAksiyonu } from './liste/belgeAksiyonlari';
import { icmalAksiyonu } from './liste/icmalAksiyonlari';
import { radyolojiAksiyonu } from './liste/radyolojiAksiyonlari';
import { teleradAksiyonu } from './liste/teleradAksiyonlari';
import { useOturum } from '../kimlik/OturumBaglami';
import { randevuTercihiOku, randevuTercihiYaz } from './liste/randevuTercihi';
import { useTaniEkleTercihi } from '../bilesenler/taniEkleTercihi';
import { usePortalBaslik, usePortaldaMi } from './portal/portalBaslik';
import { hakedisAksiyonu } from './liste/hakedisAksiyonlari';
import { randevuAksiyonu } from './liste/randevuAksiyonlari';
import { RandevuErtelePenceresi, type ErtelenecekRandevu } from '../bilesenler/RandevuErtelePenceresi';
import { Modal } from '../bilesenler/Modal';
import { BelgeKarti } from './BelgeKarti';
import { KasaIslemKarti } from './KasaIslemKarti';
import { BELGE_KARTI_KAYNAKLARI, kartSekmeYolu, kartSekmesiVar } from './listeTanimlari.Ortak';
import { DONUSUM_MENUSU, KASA_ARAC_MENUSU, LISTELER, type ListeTanimi }
  from './listeTanimlari';

/**
 * Şu anki ekranın uygulama içi yolu (taban yolu atılmış + sorgu) - açılan
 * ekranın "Geri" dönüşü için. Beş aksiyon aynı ifadeyi tekrarlıyordu.
 */
const buYol = () =>
  `${window.location.pathname.replace(new RegExp('^' + import.meta.env.BASE_URL.replace(/\/$/, '')), '')}${window.location.search}`;

// Tanimlar ayri dosyada (listeTanimlari); disaridan alisilmis yol bozulmasin
//   diye buradan da disa aktarilir (App.tsx / Kabuk.tsx LISTELER'i buradan alir).
export { LISTELER };

/** Kirilma yolu ("Satis › Satış Faturaları") parca parca cevrilir: ayrac
    korunur, her parca menu sozlugunden gecer. */
function yolCevir(yol: string | undefined): string | undefined {
  if (!yol) return yol;
  return yol.split('›').map(p => cm(p.trim())).join(' › ');
}
export type { ListeTanimi };

/**
 * Tek bilesen tum liste ekranlarini karsilar. Kolonlar, filtreler ve yetki
 * sunucudan geldigi icin ekran basina kod yazmaya gerek yok — yeni bir liste
 * eklemek katalogda kaynak tanimlamak + burada bir satir demek.
 */
export function Liste({ tanim }: { tanim: ListeTanimi }) {
  // KARTA OZEL YERLESIM tek yerde (sayfalar/liste/kartOzellestirme.ts): sekme
  //   sirasi, gomulu detaylar, izgara. Buradaki uclu kosullar yuz satir saf
  //   yapilandirmayi bilesenin ortasina yayiyordu.
  const kartOzel = kartOzellestirme(tanim.kaynak);
  // PORTAL BASLIGI (796 V2): portal kabugunun icindeysek ekranin adi menude
  //   yazan addir; disarida undefined doner ve tanimin kendi basligi kalir.
  const portalBaslik = usePortalBaslik(`/${tanim.rota ?? tanim.kaynak}`);
  const portalda = usePortaldaMi();
  // TELERADYOLOJI "Bana Ata" oturumun taraf kimligini yazar (799).
  const { kullanici, yetki } = useOturum();
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();

  // Kart MODAL acilir (mockup deseni): liste arkada kalir, URL yine /cari/4911.
  // OZEL KART (dis-hasta): /dis-hasta/:id rotasi liste + kendi modalini cizer;
  //   generic kart (GenForm) bu kaynak icin ACILMAZ - katalogda karti yok.
  const kartId = tanim.ozelKart ? null
    : id === undefined ? null : (id === 'yeni' ? 'yeni' as const : Number(id));

  // Ekstre ekranlari: /hesap-ekstre?hesapId=12 -> sunucu filtresi. Tanimdaki
  //   sabitFiltre ile birlikte gelirse ikisi AND'lenir.
  const urlDegeri = tanim.urlFiltreAlani ? sorgu.get(tanim.urlFiltreAlani) : null;
  const sabitFiltre = useMemo<Kosul | undefined>(() => {
    if (!tanim.urlFiltreAlani || !urlDegeri) return tanim.sabitFiltre;
    const urlKosul: Kosul = { alan: tanim.urlFiltreAlani, op: 'esit', deger: Number(urlDegeri) };
    return tanim.sabitFiltre
      ? { op: 'and', kosullar: [tanim.sabitFiltre, urlKosul] }
      : urlKosul;
  }, [tanim.urlFiltreAlani, tanim.sabitFiltre, urlDegeri]);

  // Kart kaydedilince (ekleme ya da duzenleme) grid'i yeniden yukletmek icin - GenForm
  //   onKaydedildi'de bir arttirilir, GenGrid bu degisimi izleyip yukle() cagirir.
  const [yenile, setYenile] = useState(0);
  /** KART KENDİ SEKMESİNDE (kartSekmesiVar): bu sekmede liste çizilmez, yalnız kart. */
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  /** Kart açan gezinme: sekmeler açıksa kayıtsız değişiklikli kartı korur (EkranSekmeleri.kartaGit). */
  const gitKart = (yol: string) => ekranSekmesi ? ekranSekmesi.kartaGit(yol) : git(yol);
  /** BELGE KARTI KENDİ SEKMESİNDE (başvuru, hasta deseni): kart yolu liste rotası. */
  const belgeSekmeYolu = ekranSekmesi && !tanim.kartYolu && kartSekmesiVar(tanim)
    && BELGE_KARTI_KAYNAKLARI.includes(tanim.kaynak) ? kartSekmeYolu(tanim) : null;
  // BAŞKA SEKMEDE kayıt eklendi (ör. "Yeni Hasta Kartı" sekmesi kaydedip kapandı): tazele.
  useEffect(() => {
    const tazele = (e: Event) => { if ((e as CustomEvent<string>).detail === tanim.kaynak) setYenile(t => t + 1) };
    window.addEventListener(LISTE_TAZELE_OLAYI, tazele);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, tazele);
  }, [tanim.kaynak]);
  /** Kategori suzgeci (kullanici): secilen dal + alt agaci. */
  const [kategoriDal, setKategoriDal] = useState<{ id: number; agac: number[] } | null>(null);
  /** Sol kategori AGAC paneli acik mi (kullanici: "acilir kapanir olsun"). */
  const [kategoriPaneli, setKategoriPaneli] = useState(false);
  // RADYOLOJI EKRAN MODALLARI (istem · randevu · teslim · kritik bulgu · sarf ·
  //   cihaz kapatma · konsultasyon) tek kancada; cizimi RadyolojiModallari yapar.
  const radyolojiModal = useRadyolojiModallari();
  const akisModal = useAmeliyatAcilModallari();
  /** SONUC GIRIS penceresi (433) - secili istemin tetkikleri. */
  const [sonucGirisi, setSonucGirisi] = useState<number | null>(null);
  // Yeni kart EKLENINCE (duzenlemede degil) grid "Son Aranan"a gecsin - kullanici
  //   az once ekledigi kaydi listede otomatik en ustte gorsun.
  const [odaklaSonEklenen, setOdaklaSonEklenen] = useState(0);
  /** Prim rolleri (324): hakedis satirindan kalemin rollerine gecis. */
  const [rolModali, setRolModali] = useState<
    { satirId: number; ad: string } | null>(null);
  /** Hakedis donemi kapatma (324) - secili satirin kisisi on dolu gelir. */
  const [donemModali, setDonemModali] = useState<
    { tarafId?: number; kisi?: string } | null>(null);
  /** Excel'den iceri alma modali (207) - fiyat listesi; null iken kapali. */
  const [iceriAl, setIceriAl] = useState<{ listeId: number; ad: string } | null>(null);
  /**
   * YATIS YASAM DONGUSU MODALLARI (695): kabul · nakil · taburcu. Ucu de
   * ayri pencere cunku ucu de KARAR ekranidir - yatak secimi, cikis kontrol
   * listesi ve gerekceler grid satirina sigmaz.
   */
  const [yatisKabul, setYatisKabul] =
    useState<{ hastaId?: number; hastaAdi?: string } | null>(null);
  const [yatisNakil, setYatisNakil] = useState<number | null>(null);
  /** İK › Belge Türleri "↕ Sırayı düzenle" penceresi. */
  const [belgeTuruSira, setBelgeTuruSira] = useState(false);
  // Göz şeması ve dikte (705): ikisi de açık muayeneye bulgu yazar.
  const [gozSema, setGozSema] = useState<number | null>(null);
  const [gozDikte, setGozDikte] = useState<number | null>(null);
  /** 976: panodan açılan istem sepeti (Göz sekmesi) - pano istemi açar, yazmaz. */
  const [gozPanoIstem, setGozPanoIstem] = useState<number | null>(null);
  const [yatisTaburcu, setYatisTaburcu] = useState<number | null>(null);
  /**
   * GÖZ ÜNİTE AKIŞINDA SEÇİLİ KART (691). Kanban gridin DIŞINDA bir seçim
   * yüzeyi: kullanıcı kartı tıklıyor ama gridin satır seçimi değişmiyordu,
   * bu yüzden araç çubuğu düğmeleri "önce kayıt seçin" diyordu. Kanban seçimi
   * burada tutulur ve aksiyonlara grid satırının yerine geçer.
   */
  const [gozAkisSecili, setGozAkisSecili] = useState<ListeSatiri | null>(null);
  /** Doz kuyruğu satırından açılan beş doğru penceresi (698). */
  const [dozSatiri, setDozSatiri] =
    useState<{ yatisId: number; dozId: number; atla: boolean } | null>(null);
  // ÜTS EKRAN MODALLARI (223/226) tek kancada; cizimi UtsModallari yapar.
  const utsModal = useUtsModallari();
  // Donusum modali (F8): siparis/irsaliye satirlarindan yeni belge uretir.
  /** Mesaj gecmisi penceresi (178) - null iken kapali. */
  const [eBelgeMesajlari, setEBelgeMesajlari] =
    useState<{ belgeNo: string; satirlar: EBelgeMesaji[] } | null>(null);
  const [donusum, setDonusum] =
    useState<{ belgeId: number; belgeTur: number; hedef?: number } | null>(null);
  // MUAYENE KIMLIK ALANLARI MODALDA (kullanici): tur/bolum/hekim/baslama/bitis
  //   ve isteyen muayene kart izgarasinda degil, baglam seridindeki "Bugun"
  //   kutusuna basinca acilan pencerede. Kart govdesi sekmelere kaliyor.
  const [muayeneBilgiAcik, setMuayeneBilgiAcik] = useState(false);
  /** ICD arama penceresi açık mı (tanı sekmesi "＋ ICD-10 Ekle"). */
  const [icdAramaAcik, setIcdAramaAcik] = useState(false);
  // GÖZ KARTI TANI SEKMESİ (süreç v2): ICD penceresi göz kartının GENEL muayenesine yazar.
  const [icdMuayeneId, setIcdMuayeneId] = useState<number | null>(null);
  /** ICD penceresindeki TÜR (Kesin / Ön) ve TARAF seçimi - son seçim hesapta
      hatırlanır (kullanıcı). */
  const tani = useTaniEkleTercihi(icdAramaAcik, kullanici?.id);
  /** Kartı sunucudan yeniden okutur: ekran düğmeleri (tanı ekle, şablon
      uygula, tümü normal...) satırı SUNUCUDA açar; kart onu ancak yeniden
      okuyunca gösterir. */
  const [kartTazele, setKartTazele] = useState(0);
  /** Muayene kartının ek sekmeleri (e-Reçete, ücret, geçmiş, konsültasyon):
      tek uçtan gelen ortak veri; kart tazelendikçe yenilenir. */
  const sekmeVerisi = useMuayeneSekmeVerisi(
    tanim.kaynak === 'muayene' && typeof kartId === 'number' ? kartId : 0, kartTazele);
  // Kart kapanip baska kayit acilinca pencere ACIK KALMASIN.
  useEffect(() => { setMuayeneBilgiAcik(false) }, [kartId]);
  // Belge (fatura/siparis) karti da MODAL: liste arkada kalir, rota degismez.
  const [yeniBelgeTuru, setYeniBelgeTuru] = useState<number | null>(null);
  /**
   * HASTA KARTINDAN BASVURU (782/788).
   *
   * Kullanici: *"hasta kartında iken başvuru aç basılırsa kapanmamış son
   * başvuru kartı ekrana gelir"*. Hasta ayni gun icinde ikinci kez kayit
   * kabule geldiginde memur "Yeni Başvuru" diyor ve ONCEKI basvurusu hala
   * acikken ikinci bir protokol aciliyordu: ucretler iki karta bolunuyor,
   * tahsilat ve provizyon hangi protokole yazildi sorusu doguyordu.
   *
   * ACIK = TAMAMLANMA %100'DEN AZ (kullanici: *"tamamlanma %100 ise başvuru
   * kapanmış demektir"*). Olcut `kapanmaDurum` DEGIL: o yalniz faturaya
   * donusme adimini bilir; basvuru provizyon/ucret/tahsilat adimlarindan biri
   * eksikken de aciktir. Yuzde kart ustundeki asama seridiyle AYNI kuraldan
   * gelir (370/602). En yenisi acilir; yoksa yeni basvuru.
   * Sorgu basarisiz olursa (yetki/ag) yeni basvuruya duseriz - memuru
   * bosluga birakmak daha kotu.
   */
  async function basvuruAc(tarafId: number, unvan: string) {
    try {
      const y = await api.liste('belge', {
        sayfa: 1, boyut: 1,
        sirala: [{ alan: 'belgeTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
        filtre: { op: 'and', kosullar: [
          { alan: 'tarafId', op: 'esit', deger: tarafId },
          { alan: 'tur', op: 'esit', deger: 19 },
          { alan: 'tipi', op: 'esit', deger: 30 },
          { alan: 'tamamlanma', op: 'kucuk', deger: 100 },
        ] },
      });
      const acik = Number(y.satirlar[0]?.id ?? 0);
      if (acik) {
        mesaj('Bu hastanın kapanmamış başvurusu var - o başvuru açıldı.');
        // KART İÇİNDEN AÇILAN KART YENİ SEKMEDE (kullanıcı 14.10.2026, karar 2).
        if (ekranSekmesi) git(`/basvuru/${acik}`); else setAcikBelgeId(acik);
        return;
      }
    } catch { /* sorgu basarisizsa yeni basvuru acilir */ }
    if (ekranSekmesi) git(`/basvuru/yeni?tarafId=${tarafId}&tarafUnvan=${encodeURIComponent(unvan)}`);
    else setYeniBasvuruHasta({ id: tarafId, unvan });
  }

  const [yeniBasvuruHasta, setYeniBasvuruHasta] =
    useState<{ id: number; unvan: string } | null>(null);
  // Mevcut belgeyi ac (salt gorunum) - ayni modal, id ile.
  const [acikBelgeId, setAcikBelgeId] = useState<number | null>(null);
  /** RANDEVU ERTELE penceresi (1119). */
  const [ertelenecek, setErtelenecek] = useState<ErtelenecekRandevu | null>(null);
  /** ADAY HASTA TAMAMLAMA (17.10.2026): başvuruya dönüştürürken hasta kartı; sonuç aksiyona döner. */
  const [hastaTamamla, setHastaTamamla] = useState<{ id: number; coz(s: { id: number; mevcut?: boolean } | null): void } | null>(null);
  // BANKO OTURUMU listeden MODAL olarak açılır (kullanıcı: "bankolar dan
  //   seçilerek Oturum Aç butonuyla girilsin"): açılış, gün içi ve gün sonu
  //   AYNI modalda - görevliyi iki ayrı yere göndermemek için.
  const [oturumAcBanko, setOturumAcBanko] = useState<number | null>(null);
  // Oturum gecmisinden "Duzenle": belirli oturumu ayni modalda acar.
  const [acikOturumId, setAcikOturumId] = useState<number | null>(null);

  // AI REHBER BAGLAMI (449): acik kart hangisi? Belge/basvuru karti MODAL
  //   aciliyor, rota degismiyor - panel kaydin id'sini baska turlu bilemez.
  useEffect(() => {
    // Kaynak ham haliyle gonderilir (basvuru ekraninda da 'belge'); hangi
    //   kural ailesinin calisacagina SUNUCU kayda bakarak karar verir.
    const kayit = acikBelgeId !== null
      ? { kaynak: tanim.kaynak, id: acikBelgeId }
      : (typeof kartId === 'number' ? { kaynak: tanim.kaynak, id: kartId } : null);
    aiBaglamAyarla(kayit);
    return () => aiBaglamAyarla(null);
  }, [acikBelgeId, kartId, tanim.kaynak]);
  // Kasa islem karti MODAL (tahsilat/odeme): liste arkada acik kalir.
  const [kasaTuru, setKasaTuru] = useState<number | null>(null);
  // Ekstre satirindan acilan MEVCUT kasa islemi (salt gorunum/duzenleme).
  const [acikKasaId, setAcikKasaId] = useState<number | null>(null);
  /** Cek/senet ile tahsilat-odemede once acilan KIYMET KARTININ turu (23/24/33/34). */
  const [cekTuru, setCekTuru] = useState<number | null>(null);
  /** HASTA AVANSI (779): avans damgasiyla acilan tahsilat kartinin turu. */
  const [avansTuru, setAvansTuru] = useState<number | null>(null);
  /** AVANS IADESI (780): kalan avansin hastaya geri odendigi odeme karti. */
  const [avansIade, setAvansIade] = useState<{
    avansId: number; tarafId: number; tarafUnvan: string; tutar: string;
  } | null>(null);
  /** Kiymet kaydedildikten sonra acilan kasa islemi (ayni kiymete bagli). */
  const [kasaAcilis, setKasaAcilis] = useState<{
    tur: number; tarafId?: number; tarafUnvan?: string; tutar?: string;
    belgeId?: number; cekSenetId?: number;
  } | null>(null);

  /**
   * Kiymet karti kaydedildi: ayni bilgilerle kasa islemini ac. Kart SUNUCUDAN
   * yeniden okunur - tutar/cari/doviz kullanicinin kartta girdigi son hali
   * olsun (formdaki ara degerler degil).
   */
  async function cekKartKaydedildi(tur: number, id: number) {
    setCekTuru(null);
    setYenile(t => t + 1);
    try {
      const k = await api.kartOku('cek-senet', id);
      const kart = k.kart as Record<string, unknown>;
      setKasaAcilis({
        tur,
        tarafId: Number(kart.tarafId) || undefined,
        tarafUnvan: String(k.kodAd?.tarafId?.[String(kart.tarafId)] ?? ''),
        tutar: String(kart.tutar ?? ''),
        cekSenetId: id,
      });
    } catch {
      // Kiymet kaydedildi ama okunamadi: kasa islemi kartini bos acmaktansa
      //   kullaniciyi listeye birak - kiymet portfoyde duruyor.
      setKasaTuru(tur);
    }
  }
  /**
   * Liste arac cubugundan acilan TAHSILAT/ODEME kartinin on dolgusu: secili
   * basvurunun hastasi, belgesi ve ACIK TAHSILAT tutari (genel toplam -
   * tahsil edilen). Satir secili degilse kart bos acilir.
   */
  function tahsilatAcilisi(tur: number) {
    const s = seciliSatir;
    if (!s || tanim.kaynak !== 'belge') return { tur };
    const acik = Math.max(0, Math.round(
      ((Number(s.genelToplam ?? 0)) - (Number(s.tahsilat ?? 0))) * 100) / 100);
    return {
      tur,
      tarafId: Number(s.tarafId) || undefined,
      tarafUnvan: String(s.tarafUnvan ?? '') || undefined,
      belgeId: Number(s.id) || undefined,
      tutar: acik > 0 ? String(acik) : undefined,
    };
  }

  // "Ekstre" modu (A secenegi): ayni grid ekstre kaynagina doner. null = liste.
  const [ekstre, setEkstre] = useState<{ id: number; ad: string } | null>(null);
  /** Ekstre gridinde SECILI satir - "Başvuru Aç" bunu kullanir. */
  const [ekstreSatir, setEkstreSatir] = useState<ListeSatiri | null>(null);
  useEffect(() => { setEkstreSatir(null) }, [ekstre?.id]);
  /**
   * Ekstre satirindan onu URETEN kayda gider: once kasa islemi, yoksa belge.
   * `yalnizBelge` (Başvuru Aç) tahsilat kartini degil DOGRUDAN belgeyi acar -
   * dugmenin adi belge vaat ediyor. Acilacak kayit yoksa false doner.
   */
  const ekstreSatirinaGit = (satir: ListeSatiri, yalnizBelge = false): boolean => {
    const kasaId = Number(satir.kasaIslemId ?? 0);
    const belgeId = Number(satir.belgeId ?? 0);
    if (belgeId && (yalnizBelge || !kasaId)) { setAcikBelgeId(belgeId); return true }
    if (!yalnizBelge && kasaId) { setAcikKasaId(kasaId); return true }
    return false;
  };
  // Ekstre dugmesinin aktifligi icin gridden gelen secili satir.
  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  // Ekstreden donunce ayni satiri yeniden isaretlemek icin - grid unmount
  //   olurken secim null'a duser, o yuzden SON DOLU deger ayrica saklanir.
  const [sonSeciliId, setSonSeciliId] = useState<number | null>(null);
  /**
   * Ekstreden donunce ayni cip (Aktif/Pasif/Tumu) secili kalsin.
   *
   * URL FILTRESIYLE gelindiyse (ör. /hakedis-satir?hakedisId=7) kayit kumesi
   * ZATEN daraltilmistir; ustune bir durum cipi (Acik/Aktif) binince grid
   * bos gorunuyordu. Boyle bir acilista suzgecsiz SON cip ("Tümü") secilir -
   * son cipin filtresi yoksa, yani gercekten hepsini gosteriyorsa.
   */
  const cipler = tanim.cipler;
  const suzgecsizCip = cipler && cipler.length > 1 && !cipler[cipler.length - 1].filtre
    ? cipler.length - 1 : null;
  // PORTALDA DA SUZGECSIZ CIP (796 V2): cip setleri KURUM ICI kuyruklardir
  //   ("Numune Uygunsuz", "Teknik Onay", "Bekleyen Çekim"). Portal
  //   kullanicisinin kuyrugu yok; kapsam zaten sunucuda daraltiyor - ilk cip
  //   ona hep BOS liste gosteriyordu. Cipler ekranda kalir, isteyen daraltir.
  const [cipIndeks, setCipIndeksIc] = useState(() => (
    (urlDegeri || portalda) && suzgecsizCip !== null ? suzgecsizCip
    // RANDEVU: kullanicinin son sectigi durum cipi (kaldigi yer - randevuTercihi).
    : tanim.kaynak === 'randevu'
      ? Math.min(randevuTercihiOku(kullanici?.id).cip ?? 0, (cipler?.length ?? 1) - 1)
      : 0));
  const setCipIndeks = (i: number) => {
    setCipIndeksIc(i);
    if (tanim.kaynak === 'randevu') randevuTercihiYaz(kullanici?.id, { cip: i });
  };

  /**
   * URL FILTRESI SONRADAN GELIRSE de suzgecsiz cipe gec.
   *
   * Yukaridaki `useState` baslatici YALNIZ ILK RENDER'da calisir; oysa bu
   * ekranlara cogunlukla SPA ICI gecisle gelinir (Hakedişler > "Satırları
   * Gör" -> /hakedis-satir?hakedisId=4). O gecişte bilesen ayakta kaliyor,
   * cip eski degerinde ("Kesin") duruyordu ve kapatilmis hakedisin satirlari
   * ONAYLI oldugu icin grid "Kayıt yok" gosteriyordu: kullanici hakedisi
   * kapatir, satirlarina bakar ve HICBIR SEY GOREMEZ.
   */
  useEffect(() => {
    if (urlDegeri && suzgecsizCip !== null) setCipIndeks(suzgecsizCip);
  }, [urlDegeri, suzgecsizCip]);

  // RANDEVU EKRANI (243/251/316): bolum-hekim suzgeci, takvim ayarlari, cihaz
  //   sutunlari ve bekleyen isteme randevu verme kendi kancasinda.
  const randevuEkran = useRandevuEkrani(
    tanim.kaynak, sabitFiltre, () => setYenile(t => t + 1));
  // PERSONEL (bolum agaci + rol) SERIT SUZGECI kendi kancasinda: durum,
  //   rol listesi ve filtre uretimi orada.
  const personelSuzgec = usePersonelSuzgeci(
    tanim.bolumSuzgeci, tanim.rolSuzgeci, tanim.kaynak);
  const rolSuzgeciVar = personelSuzgec.rolSuzgeciVar;
  // EKRAN ÇEVRESİ (refaktör 22.10.2026, liste/listeEkranlari): süzgeç + gösterge taşıyan ekranlar
  //   (personel, radyoloji, order, göz, konsültasyon, sevk) tek kancada; durumsuz şerit / paneller
  //   kaynak tablosunda. Gridin üst / sol / yan / alt panelleri ve sabit filtre buradan.
  const ekranBaglami: ListeEkranBaglami = {
    kaynak: tanim.kaynak, portalda, yenile, tazele: () => setYenile(t => t + 1),
    seciliSatir, git, gitKart, aksiyon: (kod, satir) => aksiyon(kod, satir), setCip: setCipIndeks,
    personelSuzgec,
    panoCipFiltresi: cipler?.[cipIndeks]?.filtre,
    panoSeciliId: Number(gozAkisSecili?.id ?? 0) || null, panoSec: setGozAkisSecili,
  };
  const ekran = useListeEkrani(ekranBaglami);
  /** Etkin ekranın süzgeci (yoksa dokunmaz). */
  const ekranFiltresi = (t: Kosul | undefined) => ekran ? ekran.filtre(t) : t;
  const panel = listePaneli(tanim.kaynak);

  // HAKEDIS SATIRLARI (prim rolu + kisi) SERIT SUZGECI kendi kancasinda.
  const primSuzgec = usePrimSuzgeci(tanim.primSuzgeci, tanim.kaynak);

  // BASVURU SERIT SUZGECLERI (tarih araligi + tamamlanma/tahsilat/donusum +
  //   odeyen/bolum/doktor) kendi kancasinda.
  const basvuruSuzgec = useBasvuruSuzgeci(tanim.basvuruSuzgeci, tanim.kaynak);
  /** Belge olusturmada sube: oturumun calisma subesi. */
  const oturumSubeId = Number(localStorage.getItem('gentegre.sube')) || undefined;
  /**
   * TETKIK KATALOGU SOL PANELI (492): bolum ya da panel secimi. Ikisi de
   * SUNUCU filtresine cevrilir - panel uyeligi tetkik kimlikleriyle gelir,
   * istemci uyelik kuralini kendisi kurmaz.
   */
  const [agacSecim, setAgacSecim] = useState<AgacSecim>(BOS_SECIM);

  const agacliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    // BOLUM kosulunu GenGrid'in kod suzgeci ekler (ayni deger paylasilir);
    //   burada tekrar eklemek ayni kosulu iki kez yazardi.
    if (agacSecim.panelIdleri !== null)
      // Bos panelde "icinde []" hicbir satir dondurmez - dogru davranis.
      kosullar.push({ alan: 'id', op: 'icinde', deger: agacSecim.panelIdleri });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [agacSecim]);

  /** IKINCI CIP GRUBU (tanim.onCipler): secimi ana ciplerden bagimsiz, filtresi AND'lenir. */
  const [onCipIndeks, setOnCipIndeks] = useState(0);
  const onCipliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    const f = tanim.onCipler?.[onCipIndeks]?.filtre;
    if (!f) return temel;
    return temel ? { op: 'and', kosullar: [temel, f] } : f;
  }, [tanim.onCipler, onCipIndeks]);

  /** Kategori secimi sabit filtreye AND'lenir - cip ve arama ile birlikte. */
  const kategoriliFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!kategoriDal || kategoriDal.agac.length === 0) return temel;
    const kosul: Kosul = {
      alan: tanim.kategoriSuzgecAlani ?? 'kategori',
      op: 'icinde', deger: kategoriDal.agac,
    };
    return temel ? { op: 'and', kosullar: [temel, kosul] } : kosul;
  }, [kategoriDal, tanim.kategoriSuzgecAlani]);

  /**
   * DOKUMAN SOL PANELI (419): secilen klasor listeye SABIT FILTRE olarak gecer.
   *
   * Kurumsal klasor `klasorId` ile, KAYNAK klasoru `kaynak` ile suzulur -
   * ikisi ayri alan cunku kaynak klasoru SANALDIR (tablo kaydi yok, dokumanin
   * kaynak alanindan turer).
   */
  const [klasorSecim, setKlasorSecim] = useState<KlasorSecimi>({ tur: 'tum', ad: 'Tümü' });

  /*
   * GIZLENECEK KOLONLAR - iki kural, tek yerde.
   *
   * 1) Dokuman listesinde KLASOR kolonu yalniz "Tümü"de gorunur: belli bir
   *    klasor secildiginde her satirda ayni klasor adi yazmak, dar ekranda
   *    yer harcayan bir tekrar olurdu.
   * 2) e-FATURA ve SENARYO kolonlari YALNIZ e-Belge'ye donusen turlerde
   *    (10 alis irsaliyesi · 11 alis faturasi · 14 satis irsaliyesi ·
   *    15 satis faturasi) anlamli. Siparis, teklif, fis, tahakkuk, konsinye,
   *    transfer ve basvuruda bu kolonlar HER SATIRDA BOS kaliyor - kolon
   *    secicide de yer kapliyorlardi. Kural burada, ekran ekran
   *    `gizliKolonlar` yazmak yerine: yeni bir belge listesi eklendiginde
   *    kendiliginden dogru davranir.
   */
  const gizlenecekKolonlar = useMemo(() => {
    const liste = [...(tanim.gizliKolonlar ?? [])];
    if (tanim.kaynak === 'dokuman' && klasorSecim.tur !== 'tum') liste.push('klasorYolu');
    const EBELGE_TURLERI = [10, 11, 14, 15];
    if (tanim.kaynak === 'belge' && !EBELGE_TURLERI.includes(tanim.yeniBelgeTuru ?? 0))
      liste.push('efaturaDurum', 'eBelgeDurumAdi', 'senaryoAdi', 'senaryo', 'efaturaKodu');
    // Basvurudan kesilen faturalarin e-Belge ozeti yalniz basvuru / siparis (19) listesinde.
    if (tanim.kaynak === 'belge' && tanim.yeniBelgeTuru !== 19) liste.push('faturaEBelgeDurum');
    return liste;
  }, [tanim.gizliKolonlar, tanim.kaynak, tanim.yeniBelgeTuru, klasorSecim.tur]);

  const klasorluFiltre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (tanim.kaynak !== 'dokuman' || klasorSecim.tur === 'tum') return temel;
    const kosul: Kosul = klasorSecim.tur === 'klasor'
      ? { alan: 'klasorId', op: 'esit', deger: klasorSecim.id ?? 0 }
      : { alan: 'kaynak', op: 'esit', deger: klasorSecim.kod ?? '' };
    return temel ? { op: 'and', kosullar: [temel, kosul] } : kosul;
  }, [tanim.kaynak, klasorSecim]);

  /**
   * AKSIYON YONLENDIRME - grid arac cubugu ve sag tus menusu buraya duser.
   *
   * Fonksiyon 950 satira ve 44 case'e ulasmisti; konu bazli bloklar AYRI
   * dosyalara alindi (refactor) ve burada sirayla deneniyor:
   *     liste/utsAksiyonlari · liste/kasaAksiyonlari
   *     liste/fiyatListesiAksiyonlari · liste/ebelgeAksiyonlari
   * Her modul "ele aldim mi" doner; ele aldiysa burada isimiz biter. e-Belge
   * CIKTILARI (onizleme/XML/PDF) ve gelen belge adimlari zaten ayriydi
   * (ebelgeIslem / gelenBelgeIslem) - ayni desen surduruldu.
   *
   * Burada kalanlar: belge/kart acma, silme, donusum, randevu akisi, radyoloji
   * ve listeye ozel tek tuk isler - hepsi ekranin kendi state'ine sikica bagli.
   */
  async function aksiyon(kod: string, satir?: ListeSatiri | null,
                         secililer?: ListeSatiri[],
                         /** Ekran-ozel ek girdi (or. tani arama metni). */
                         ek?: string) {
    const kartaGit = (kayitId: unknown) => gitKart(`${tanim.kartYolu}/${kayitId}`);

    // BAŞVURU EKLE (kullanici): hasta listesinde seçili hastaya başvuru aç
    //   (varsa kapanmamış başvurusu açılır, yoksa yeni). 2. sıra düğmesi.
    // HASTA İCMALİ (10.10.2026): seçili hastanın hesap icmali; geri dönüş bu listeye.
    if (kod === 'hasta.icmal') {
      const s = satir ?? seciliSatir;
      if (!s) { mesaj('Önce bir hasta seçin.'); return }
      git(`/hasta-icmal/${s.id}?geri=${encodeURIComponent(buYol())}`);
      return;
    }
    if (kod === 'hasta.basvuru-ekle') {
      const s = satir ?? seciliSatir;
      if (!s) { mesaj('Önce bir hasta seçin.'); return }
      await basvuruAc(Number(s.id), String(s.unvan ?? s.ad ?? s.id));
      return;
    }

    try {
      // GELEN KUTUSU once: oradaki id e_belge kaydidir, belge id'si degil -
      //   ayni "ebelge.*" kodlari farkli uclara gider.
      if (tanim.kaynak === 'gelen-belge' && (secililer?.length ?? 0) > 1
          && await gelenCokluAksiyonu(kod, secililer!, () => setYenile(t => t + 1))) return;
      if (tanim.kaynak === 'gelen-belge'
          && await gelenBelgeAksiyonu(kod, satir ?? secililer?.[0] ?? null, () => setYenile(t => t + 1),
                                      setEBelgeMesajlari)) return;

      // GIDEN e-FATURA (11.10.2026, Delphi e-Fatura menusu): fatura listesinin
      //   kombosu, Belgeye Donusum ve fatura kartindaki menuyle AYNI modul.
      if (satir && kod.startsWith('ebelge.')
          && await efaturaCalistir(kod, Number(satir.id), { tazele: () => setYenile(t => t + 1) })) return;

      // KONU BAZLI AKSIYONLAR ayri dosyalarda (refactor): `aksiyon()` 950
      //   satira ve 44 case'e ulasmisti. Her modul "ele aldim mi" doner;
      //   ele aldiysa burada isimiz biter. e-Belge ve gelen belge zaten
      //   ayriydi (ebelgeIslem / gelenBelgeIslem) - ayni desen surduruldu.
      if (await utsAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        setUtsHazirla: utsModal.setHazirla, setUtsKullanim: utsModal.setKullanim,
        setUtsGenel: utsModal.setGenel, setUtsAlma: utsModal.setAlma,
      })) return;

      if (await zamanliIsAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await klinikKaliteAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      // KURUMSAL KALİTE (1052): olay / risk satırından "DÖF aç".
      if (await kysOlayRiskAksiyonu(kod, satir, { git: yol => git(yol) })) return;
      if (await kysDokumanAksiyonu(kod, satir, { git: yol => git(yol) })) return;
      if (await kysKalibrasyonAksiyonu(kod, satir, { git: yol => git(yol) })) return;
      if (await kysDofBagAksiyonu(kod, satir, { git: yol => git(yol) })) return;
      if (await kysTedarikciAksiyonu(kod, satir, { git: yol => git(yol) })) return;

      // AMELİYATHANE ve ACİL akış aksiyonları (715/716/719): zaman damgaları,
      //   triyaj, yatak ve çıkış kararı. Kart yazmakla olmayan işler - kural
      //   sunucuda, ekran yalnız soruyu soruyor.
      if (await ameliyathaneAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        planlaAc: v => akisModal.setPlanlama(v),
        kontrolAc: v => akisModal.setKontrol(v),
        faturaAc: v => akisModal.setFaturaStok(v),
      })) return;

      if (await acilAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        cikisAc: v => akisModal.setAcilCikis(v),
      })) return;

      // İZİN (743): talep · onaya gönder · bakiye · iptal. Karar YOK -
      //   onay kutusundan ya da zincirden verilir.
      if (await izinAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: (yol, state) => git(yol, state ? { state } : undefined),
      })) return;

      // TEKNIK SERVIS (773): cagri -> is emri -> ziyaret. Iki kapi UCTA -
      //   imzasiz ziyaret kapanmaz, acik emanetle teslim edilmez; ekran
      //   yalnizca soruyu sorar ve reddi gosterir.
      if (await servisAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      // ARIZA / TALEP (911): ekip akışı devral -> çöz -> kapat. Guard'lar
      //   uçta; ekran yalnız düğmeyi bağlar.
      if (await arizaAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      // ONAY GELEN KUTUSU (738/739): karar KUTUDAN verilir - kullanıcıyı
      //   kaydın kendi ekranına yollamak tek kutunun anlamını bitirirdi.
      if (await onayAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      // ECZANE · BİYOMEDİKAL · SATINALMA (722-724 akış uçları). Modal yok:
      //   kurallar sunucuda, ekran yalnız reddi soruya çeviriyor.
      if (await tedarikAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        belgeAc: belgeId => setAcikBelgeId(belgeId),
      })) return;

      // BANKO (985/987): oturum akisi ayri bir ekran; liste yalniz secili
      //   bankoyla oraya goturur. Kurallar (uygun banko, canli oturum,
      //   devir) sunucuda - liste onlari tekrar yazmaz.
      if (kod === 'banko.oturum-ac' || kod === 'banko.oturumlar') {
        const bankoId = Number(satir?.id ?? 0);
        if (!bankoId) { mesaj('Önce bir banko seçin.'); return }
        if (kod === 'banko.oturum-ac') setOturumAcBanko(bankoId);
        else git(`/banko-oturumlar?banko=${bankoId}`);
        return;
      }
      // OTURUM GECMISINDEN: yeni oturum (banko secimi modalda) ya da secili
      //   oturumu ac. Ikisi de ayni modal - akis tek yerde.
      if (kod === 'banko-oturum.yeni') { setOturumAcBanko(0); return }
      if (kod === 'banko-oturum.duzenle') {
        const oturum = Number(satir?.id ?? 0);
        if (!oturum) { mesaj('Önce bir oturum seçin.'); return }
        setAcikOturumId(oturum);
        return;
      }
      if (kod === 'banko-oturum.sil') {
        const oturum = Number(satir?.id ?? 0);
        if (!oturum) { mesaj('Önce bir oturum seçin.'); return }
        // Kurallar SUNUCUDA (kapanmis oturum, islem gormus oturum silinmez);
        //   ekran yalniz onay soruyor ve reddi mesaja ceviriyor.
        if (!(await onay(`#${oturum} oturumu silinecek. Yalnız hiç işlem görmemiş,`
                         + ' kapanmamış oturum silinebilir.', true))) return;
        await guvenli(async () => {
          await api.bankoOturumSil(oturum);
          mesaj('Oturum silindi.');
          setYenile(t => t + 1);
        });
        return;
      }
      if (kod === 'banko-oturum.tutanak') {
        const oturumId = Number(satir?.id ?? 0);
        if (!oturumId) { mesaj('Önce bir oturum seçin.'); return }
        git(`/banko-tutanak/${oturumId}`);
        return;
      }

      if (await itsAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await uretimAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await sigortaAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await cihazAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await labAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        sonucGir: istemId => setSonucGirisi(istemId),
      }, secililer)) return;

      if (await mikroAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await genetikAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await kkAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await disLabAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      // KONSÜLTASYON (1107): yanıtla (yanıt muayenesi açılır) · yönlendir / reddet (gerekçeli pencere).
      if (await konsultasyonAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      // PATOLOJİ (1104): vaka / gönderim adımları; "Pakete Ekle" çoklu seçimle.
      if (await patolojiAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await dokumanAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await enabizAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await hekimListesiAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
      })) return;

      if (await muayeneAksiyonu(kod, satir, {
        // Muayene aksiyonlari kaydi SUNUCUDA degistirir: liste kadar ACIK
        //   KART da tazelenmeli.
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        // Kart aciksa tamamlamadan sonra kapanir; listeden cagrildiysa
        //   (kartId null) yapacak bir sey yok.
        kartKapat: () => { if (kartId !== null && tanim.kartYolu) git(tanim.kartYolu) },
      }, ek)) return;

      if (await ilacAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      // GOZ UNITE AKISI (691): panonun dugmeleri - cagir, istasyona al,
      //   dilatasyon, oda, ziyareti kapat. Pano YAZMAZ, TASIR.
      // KANBAN SEÇİMİ GRİD SEÇİMİNİN YERİNE GEÇER: kullanıcı karta tıklayıp
      //   düğmeye basıyor; gridden ikinci kez seçtirmek gereksiz bir adım.
      // KANBAN SEÇİMİ GRİD SEÇİMİNİN YERİNE GEÇER - ve ÖNCE gelir (976):
      //   grid ilk satırı kendiliğinden seçiyor, `satir ?? gozAkisSecili`
      //   sırası yüzünden kullanıcı karta tıklayıp düğmeye bastığında işlem
      //   BAŞKA hastaya uygulanıyordu (oda ataması, istem, çağrı). Kart
      //   seçilmemişse grid satırı yine kullanılır.
      if (await gozAkisAksiyonu(kod, gozAkisSecili ?? satir, {
        // Kart araç çubuğundan çağrıldığında (tamamla, önceki muayeneden
        //   kopyala) kayıt SUNUCUDA değişiyor: liste kadar AÇIK KART da
        //   tazelenmeli, yoksa getirilen bulgular ekranda görünmez.
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
        semaAc: id => setGozSema(id),
        dikteAc: id => setGozDikte(id),
        istemAc: id => setGozPanoIstem(id),
      })) return;

      // MEDULA (707): kabul/hizmet sayfalari, cikis, fatura, recete imzala/gonder, kuyruk.
      if (await medulaAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
      })) return;

      // ISG (741): firma panosu, calisan karti, Ek-2 ac, form gonder, olay, SGK.
      if (await isgAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
        geri: buYol(),
      })) return;

      // STERILIZASYON (868): dongu karti, izleme, okutma, birim hazirlama adimlari, geri cagirma.
      if (await sterilAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
        geri: buYol(),
      })) return;

      // CAGRI MERKEZI (839): cagri karti, elle kayit, geri arama tamam, kampanya uret/calistir/durdur, kisi ara/sonuc.
      if (await cagriAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
        geri: buYol(),
      })) return;

      // FORM MOTORU (740): sablon kopyala/editor, istek ac/hatirlat/yeniden/iptal, hasta formlari.
      if (await formAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
        geri: buYol(),
      })) return;

      // FTR (719): planla, bugunku seans, sonlandir, seans bitir / gelmedi.
      if (await ftrAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
      })) return;

      // DIS (706): plan sun/onayla, seans bitir, lab asamasi, hasta kartina gec.
      if (await disAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        git: yol => git(yol),
      })) return;

      // YATAN HASTA (695): kabul · yatakta · nakil · taburcu · yatak temizligi.
      //   Yatak durumu bu uclarla birlikte degisir - listede ayrica
      //   guncellenmez.
      if (await yatanAksiyonu(kod, satir, {
        tazele: () => { setYenile(t => t + 1); setKartTazele(t => t + 1) },
        kabulAc: h => setYatisKabul(h ? { hastaId: h.id, hastaAdi: h.ad } : {}),
        nakilAc: id => setYatisNakil(id),
        taburcuAc: id => setYatisTaburcu(id),
        dozAc: (yatisId, dozId, atla) =>
          setDozSatiri({ yatisId, dozId, atla: !!atla }),
        kartAc: id => { if (tanim.kartYolu) gitKart(`${tanim.kartYolu}/${id}`) },
      })) return;

      if (await belgeTakipAksiyonu(kod, satir, secililer)) return;
      // ENTEGRASYON HESAPLARI (bağımsız liste, 22.10.2026): sına / test mesajı / SKRS işlemleri.
      if (await entegrasyonAksiyonu(kod, satir, () => setYenile(t => t + 1))) return;
      if (await belgeTuruAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        kartAc: id => { if (tanim.kartYolu) gitKart(`${tanim.kartYolu}/${id}`) },
        siraAc: () => setBelgeTuruSira(true),
      })) return;

      if (await bildirimAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
      })) return;

      if (await kasaAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setKasaTuru, setCekTuru, setAcikKasaId,
        setAvansTuru, setAcikBelgeId, setAvansIade,
      })) return;

      if (await fiyatListesiAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setIceriAl,
      })) return;

      // BAŞVURU KARTI KENDİ SEKMESİNDE: Yeni / Aç pencere değil kart sekmesi açar.
      if (belgeSekmeYolu && kod === 'belge.yeni') { gitKart(`${belgeSekmeYolu}/yeni`); return }
      if (belgeSekmeYolu && kod === 'belge.ac' && satir) { gitKart(`${belgeSekmeYolu}/${satir.id}`); return }

      if (await belgeAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        kartaGit,
        setAcikBelgeId, setYeniBelgeTuru, setDonusum,
        setUtsBelgeSonuc: utsModal.setBelgeSonuc,
        varsayilanBelgeTuru: tanim.yeniBelgeTuru,
      })) return;

      // KURUM ICMALI (289): SGK payi donem sonu TEK faturaya doner.
      if (await icmalAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        setAcikBelgeId,
      })) return;

      if (await radyolojiAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setIstemHastaArama: radyolojiModal.setHastaArama,
        setSarfModali: radyolojiModal.setSarf,
        setRandevuModali: radyolojiModal.setRandevu,
        setTeslimModali: radyolojiModal.setTeslim,
        setKritikModali: radyolojiModal.setKritik,
        setKonsultasyonModali: radyolojiModal.setKonsultasyon,
      })) return;

      // TELERADYOLOJI (799): ata / birak / okumaya basla / teslim / iptal.
      //   Zaman damgalarini tetik yazar; buradan yalniz durum ve atama gider.
      if (await teleradAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        kullaniciId: Number(kullanici?.id ?? 0),
      })) return;

      // PRIM (324): hakedis satiri TAHSILATTAN dogar, elle eklenmez.
      if (await hakedisAksiyonu(kod, satir, secililer, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setDonemModali, setRolModali, setAcikBelgeId,
      })) return;

      // RANDEVU durum akisi (243) ve BASVURUYA DONUSUM (265 - 317).
      if (await randevuAksiyonu(kod, satir, {
        tazele: () => setYenile(t => t + 1),
        git: yol => git(yol),
        setIstemModali: radyolojiModal.setIstem, setAcikBelgeId, oturumSubeId, setErtele: setErtelenecek,
        hastaTamamla: hid => new Promise(coz => setHastaTamamla({ id: hid, coz })),
        gonderenModu: (kullanici?.hekimRolu ?? 4) === 1,
      })) return;

      if (kod.endsWith('.yeni') && tanim.kartYolu) {
        // RANDEVU (251): takvimde fareyle isaretlenen aralik varsa saat ve sure
        //   karta tasinir - kullanici "yukaridan asagi isaretleyip Yeni'ye
        //   basinca" formda o araligi gormek istiyor.
        // SUZGEC DE TASINIR (kullanici: "yeni butona basarsam filtre combosunda
        //   secili bolum / doktor ve isaretlenmis slotlarin baslama ve bitis
        //   zamani karta gecmeli"): aralik yoksa da secili bolum / doktor gider;
        //   aralik hekim sutunundan degilse doktor suzgecten gelir.
        // Cihaz sutunundan secildiyse bolum/hekim TASINMAZ - kaynak cihazdir (316).
        const ar = randevuEkran.aralik;
        if (tanim.kaynak === 'randevu' && ar && randevuEkran.gecmisGun(ar.baslangic)) return;
        const arHekim = ar?.cihazId ? undefined : (ar?.hekimId ?? (randevuEkran.hekim || undefined));
        const arBolum = ar?.cihazId
          ? undefined
          : (ar?.hekimId ? randevuEkran.hekimBolumu(ar.hekimId) : undefined) ?? (randevuEkran.bolum || randevuEkran.hekimBolumu(arHekim) || undefined);
        const parca = tanim.kaynak === 'randevu' ? [
          ar ? `baslangic=${encodeURIComponent(ar.baslangic)}` : '',
          ar ? `sure=${ar.sureDk}` : '',
          arHekim ? `hekim=${arHekim}` : '',
          ar?.cihazId ? `cihaz=${ar.cihazId}` : '',
          arBolum ? `bolum=${arBolum}` : '',
        ].filter(Boolean) : [];
        const ek = parca.length ? `?${parca.join('&')}` : '';
        gitKart(`${tanim.kartYolu}/yeni${ek}`);
      }
      // SIL gercekten SILER: eskiden karti aciyordu ve kullanici "sildim" sanip
      //   ekranda kaydi gorunce sasiriyordu. Onay sorulur; silme engelleri
      //   (SilmeEngeli) sunucuda, 422 mesaji kullaniciya aynen gosterilir.
      else if (kod.endsWith('.sil') && satir && tanim.kartYolu) {
        const ad = String(satir.ad ?? satir.konu ?? satir.unvan ?? satir.kod ?? satir.id);
        if (!await onay(`"${ad}" silinecek. Onaylıyor musunuz?`)) return;
        // Kart adi KAYNAK'tir, rota degil: Cek/Senet listelerinin rotasi '/cek'
        //   ama kart 'cek-senet'. Yoldan turetmek yanlis karta giderdi.
        await api.kartSil(tanim.kaynak, Number(satir.id));
        setYenile(t => t + 1);
      }
      else if ((kod.endsWith('.duzenle') || kod.endsWith('.ac')) && satir && tanim.kartYolu)
        kartaGit(satir.id);
      else if (satir) mesaj(`"${kod}" aksiyonu henuz baglanmadi.`);
    } catch (h) {
      mesaj(hataMetni(h));
    }
  }

  const kartSekmesi = kartId !== null && kartSekmesiVar(tanim) && !!ekranSekmesi && !sorgu.get('geri');
  return (
    <>
    {!kartSekmesi && <>
    {/* EKSTRE MODU (A): grid ekstre kaynagina doner. Ust cip seridinden
        Aktif/Pasif/Tumu'ye basmak listeye geri getirir. */}
    {ekstre && tanim.ekstre ? (
      <GenGrid
        key={`${tanim.ekstre.kaynak}-${ekstre.id}`}
        kaynak={tanim.ekstre.kaynak}
        baslik={`${c(tanim.ekstre.baslik)} — ${ekstre.ad}`}
        yol={yolCevir(tanim.yol)}
        sabitFiltre={{ alan: tanim.ekstre.alan, op: 'esit', deger: ekstre.id }}
        // DOVIZSIZ ekstrede yerel karsilik kolonlari CIZILMEZ (kullanici):
        //   hepsi TL ise "Borç" ile "Yerel Borç" ayni sayiyi iki kez gosterir.
        //   Kur kolonu da ayni sebeple gizlenir (her satirda 1).
        dovizsizGizle={['dovizKuru', 'yerelBorc', 'yerelAlacak', 'yerelBakiye']}
        kolonBasliklari={tanim.ekstre.kolonBasliklari}
        // Cari ekstresinde kolonlar borc/alacak, hesap ekstresinde giris/cikis;
        //   ikisinin de yerel karsiligi toplanir (genel toplam yerel parada).
        toplam={tanim.ekstre.kaynak === 'cari-ekstre'
          ? ['borc', 'alacak', 'yerelBorc', 'yerelAlacak']
          : ['giris', 'cikis', 'yerelBorc', 'yerelAlacak']}
        // Cipler ekstre modunda YALNIZ "geri don" gorevi gorur: filtreleri
        //   birlikte gondermek ekstre kaynagina "Bilinmeyen alan: durum" 400'u
        //   verdiriyordu (ekstre goruntusunde durum kolonu yok).
        cipler={tanim.cipler?.map(c => ({ ad: c.ad }))}
        tarihAlani={tanim.ekstre.tarihAlani}
        tarihVarsayilan="yilbasindanBugune"
        // Ekstrede yalniz cikti aksiyonlari (Yazdir ▾ = CSV Kaydet / Yazdir);
        //   Ekle/Duzenle/Sil hesap listesine ait. HASTA ekstresinde ustune
        //   "Başvuru Aç" gelir (kullanici) - satir secilmeden pasif, sebebi
        //   sunucudan (KayitGerekir).
        aksiyonEkrani={tanim.kaynak === 'hasta' ? 'hasta-ekstre' : 'cikti-liste'}
        // Cift tik: satiri URETEN kayda git - once kasa islemi, yoksa belge.
        onSatirAc={satir => ekstreSatirinaGit(satir)}
        onSecimDegisti={s => setEkstreSatir(s)}
        onAksiyon={kod => {
          if (kod === 'genel.yazdir') { mesaj('Yazdirma henuz baglanmadi.'); return }
          // "Başvuru Aç": secili satirin belgesini acar. Ekstre satiri
          //   tahsilattan gelmis olabilir - o zaman belge, tahsilatin bagli
          //   oldugu belgedir; ikisi de yoksa acilacak kayit yok.
          if (kod === 'basvuru.ac') {
            if (!ekstreSatir) { mesaj('Önce bir satır seçin.'); return }
            if (!ekstreSatirinaGit(ekstreSatir, true))
              mesaj('Bu satırın bağlı olduğu bir belge yok.');
          }
        }}
        cipBaslangic={cipIndeks}
        // Cip'e basmak = listeye don (secilen filtreyle).
        onCipSecildi={i => { setCipIndeks(i); setEkstre(null) }}
        cipSonu={
          <>
            <button className="on" disabled title={c('Ekstre gösteriliyor')}>
              📄 {ekstre.ad}
            </button>
            {/* EKSTREDEN CIKIS (kullanici): ad dugmesi pasif oldugu icin
                ekstreyi kapatmanin tek yolu bir cipe basmakti - filtreyi de
                degistiriyordu. Bu dugme YALNIZ ekstreyi kapatir, secili cip
                oldugu gibi kalir. */}
            <button className="kapat" title={c('Ekstreyi kapat')}
                    onClick={() => setEkstre(null)}>×</button>
          </>
        }
      />
    ) : (
    <>
    {/* KATEGORI AGACI PANELI (kullanici): acikken listenin SOLUNDA durur ve
        secilen dal listeyi suzer. Kapali varsayilan - her listede yer
        kaplamasin. */}
    <div className={(tanim.kategoriSuzgeci && kategoriPaneli) || tanim.kaynak === 'dokuman'
                    ? 'kat-duzen' : undefined}>
      {/* DOKUMAN KLASOR PANELI (419): listenin SOLUNDA durur - kat-duzen flex
          oldugu icin panel `kat-duzen-ic`in KARDESI olmali; icine konunca
          blok akista gridin USTUNDE kaliyordu. */}
      {tanim.kaynak === 'dokuman' && (
        <DokumanKlasorPaneli secim={klasorSecim} onSecim={setKlasorSecim} yenile={yenile} />
      )}
      {tanim.kategoriSuzgeci && kategoriPaneli && (
        <KategoriAgacPaneli
          tur={tanim.kategoriSuzgeci}
          secili={kategoriDal?.id ?? null}
          sayacAlani={tanim.kategoriSuzgeci === 1 ? 'stokSayisi' : 'hizmetSayisi'}
          onSec={(id, agac) => setKategoriDal(id === null ? null : { id, agac })}
        />
      )}
      <div className="kat-duzen-ic">
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.rota ?? tanim.kaynak}
      kaynak={tanim.kaynak}
      // SAĞ TIK "⏰ Hatırlat" (1139): kartı olan listede seçili kayda bağlı hatırlatma.
      hatirlatKarti={tanim.kartYolu ? { yol: tanim.kartYolu, baslik: tanim.kartBaslik } : undefined}
      aramaEkAlanlari={tanim.aramaEkAlanlari}
      // PORTALDA BASLIK MENU ADIYLA AYNI (796 V2); portal disinda degismez.
      //   Kirintili yol (Randevu > Randevular) portalda GIZLENIR: kurum ici
      //   menu agacini anlatiyor, portal kullanicisinda karsiligi yok.
      baslik={portalBaslik ?? cm(tanim.baslik)}
      yol={portalBaslik ? undefined : tanim.yol}
      // Baska ekrandan acilan liste (dis hasta karti > Lab Isleri / Odeme
      //   Planlari): basligin solunda "← Geri" oraya doner.
      geriYolu={sorgu.get('geri') ?? undefined}
      onGeri={() => git(sorgu.get('geri')!)}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      kodSuzgeci={tanim.kodSuzgeci}
      // Combo ve soldaki bolum agaci AYNI degeri paylasir (492).
      kodSuzgecDeger={tanim.kodSuzgeci ? agacSecim.bolum : undefined}
      onKodSuzgec={tanim.kodSuzgeci
        ? (v => setAgacSecim(o => ({ ...o, bolum: v, panelIdleri: null, panelAdi: '' })))
        : undefined}
      varsayilanGrup={tanim.varsayilanGrup}
      grupBirimi={tanim.grupBirimi}
      sabitFiltre={onCipliFiltre(agacliFiltre(klasorluFiltre(basvuruSuzgec.filtre(
        primSuzgec.filtre(personelSuzgec.filtre(ekranFiltresi(kategoriliFiltre(randevuEkran.filtre))))))))}
      cipOnu={tanim.onCipler ? (
        <>{tanim.onCipler.map((oc, i) => (
          <button key={oc.ad} type="button" className={i === onCipIndeks ? 'on' : ''}
                  onClick={() => setOnCipIndeks(i)}>{cm(oc.ad)}</button>
        ))}</>
      ) : undefined}
      tarihVarsayilan={tanim.tarihVarsayilan}
      onTarihAraligi={tanim.primSuzgeci ? primSuzgec.araligiBildir : undefined}
      aksiyonEkrani={tanim.aksiyonEkrani}
      aracCubuguAltSatir={tanim.aracCubuguAltSatir}
      ebelgeMenusu={tanim.ebelgeMenusu}
      onEBelgeDegisti={() => setYenile(t => t + 1)}
      // KLASOR KOLONU YALNIZ "TUMU"DE (kullanici): belli bir klasor
      //   secildiginde her satirda ayni klasor adi yazmak, dar ekranda
      //   yer harcayan bir tekrar olurdu.
      gizliKolonlar={gizlenecekKolonlar}
      kolonBasliklari={tanim.kolonBasliklari}
      aramaGorunumGizli={tanim.aramaGorunumGizli}
      kolonSirasi={tanim.kolonSirasi}
      altSecenekler={{ ...KASA_ARAC_MENUSU, ...DONUSUM_MENUSU,
                       ...(tanim.altSecenekler ?? {}),
                       // YENİ TALEP ▾ (personel): yalnız eklemeye yetkili türler.
                       ...(tanim.altSecenekler?.['personel.talep'] ? { 'personel.talep': personelTalepSecenekleri(yetki, seciliSatir) } : {}) }}
      yenile={yenile}
      odaklaSonEklenen={odaklaSonEklenen}
      icerikAlani={tanim.icerikAlani}
      icerikBaslik={tanim.icerikBaslik}
      onSatirAc={satir => {
        // Belge listelerinde kart MODAL acilir (rota yok); digerlerinde kartYolu.
        // Satinalma siparis TAKIP listesi de `belge` uzerinde (tur 9) ve
        //   satir kimligi belge id'sidir: ayri bir kart acmak, ayni belgeye
        //   ikinci bir duzenleme ekrani demek olurdu.
        if (tanim.kaynak === 'belge' || tanim.kaynak === 'irsaliye'
            || tanim.kaynak === 'stok-transfer' || tanim.kaynak === 'stok-talep'
            || tanim.kaynak === 'giris-fis' || tanim.kaynak === 'cikis-fis'
            || tanim.kaynak === 'satinalmaSiparis') {
          if (belgeSekmeYolu) gitKart(`${belgeSekmeYolu}/${satir.id}`);
          else setAcikBelgeId(Number(satir.id));
        }
        // Kasa islemi de MODAL (kullanici) - "Aç" aksiyonuyla ayni davranis.
        else if (tanim.kaynak === 'kasa-islem') setAcikKasaId(Number(satir.id));
        // BANKO OTURUMU cift tikta MODAL (kullanici 08.10.2026: "Banko
        //   Oturumlari cift tiklayinca duzenle acilsin") - "Duzenle"
        //   aksiyonuyla ayni davranis, akis tek yerde.
        else if (tanim.kaynak === 'bankoOturum') setAcikOturumId(Number(satir.id));
        // Gelen belgenin KARTI YOK: cift tik gonderenin goruntusunu acar.
        else if (tanim.kaynak === 'gelen-belge')
          void gelenBelgeAksiyonu('gelen.goruntule', satir, () => setYenile(t => t + 1));
        // BAŞKA MODÜLÜN KARTI (kalite dokümanı -> /dokuman/:id, 1068): kapatınca
        //   bu listeye dönülsün diye ?geri ile açılır.
        else if (tanim.kartYolu) gitKart(`${tanim.kartYolu}/${satir.id}${tanim.kartYolu !== `/${tanim.rota ?? tanim.kaynak}`
          ? `?geri=${encodeURIComponent(`/${tanim.rota ?? tanim.kaynak}`)}` : ''}`);
      }}
      onAksiyon={(kod, satir, secililer) => { void aksiyon(kod, satir, secililer) }}
      tarihAlani={tanim.tarihAlani}
      tarihCombo={tanim.tarihCombo}
      tarihComboVarsayilan={tanim.tarihComboVarsayilan}
      // Ekstreden donunce ayni hesap secili kalsin.
      seciliBaslangicId={sonSeciliId}
      cipBaslangic={cipIndeks}
      onCipSecildi={setCipIndeks}
      onCipRota={r => git(`/${r}`)}
      onSecimDegisti={s => { setSeciliSatir(s); if (s) setSonSeciliId(Number(s.id)) }}
      cipSonu={tanim.kategoriSuzgeci ? (
        // Ciplerin SAGINDA: agac panelini acan dugme + (panel kapaliyken)
        //   ayni suzgecin combo hali. Panel acikken combo cizilmez - ayni
        //   secim iki yerde durursa hangisinin gecerli oldugu belirsizlesir.
        <>
          <button className={kategoriPaneli ? 'on' : ''}
                  title={c('Kategori ağacını aç / kapat')}
                  onClick={() => setKategoriPaneli(a => !a)}>
            🌳 Kategoriler
          </button>
          {!kategoriPaneli && (
            <KategoriSuzgeci
              tur={tanim.kategoriSuzgeci}
              deger={kategoriDal?.id ?? null}
              onDegis={(id, agac) => setKategoriDal(id === null ? null : { id, agac })}
            />
          )}
        </>
      ) : tanim.kaynak === 'randevu' ? (
        // Bolum/hekim suzgeci TARIH ARALIGININ SAGINDA (kullanici) - grid ve
        //   altindaki takvim ayni secimi kullanir. Bölüm / doktor kapısı kapalıysa (1121) hiç yok.
        !randevuEkran.bolumDoktorAcik ? null : <>
          <select value={randevuEkran.bolum} title="Bölüm" disabled={randevuEkran.bolumSabit}
                  onChange={e => { randevuEkran.setBolum(e.target.value ? Number(e.target.value) : '');
                                   randevuEkran.setHekim('') }}>
            {/* Kisitli hekimde "Tum Bolumler" yok: yalniz kendi bolum(ler)i. */}
            {!randevuEkran.hekimSabit && <option value="">{c('Tüm Bölümler')}</option>}
            {randevuEkran.bolumSecenekleri.map(d => (
              <option key={d.departmanId} value={d.departmanId}>{d.ad}</option>
            ))}
          </select>
          <select value={randevuEkran.hekim} title={c('Doktor')}
                  disabled={randevuEkran.hekimSabit}
                  onChange={e => randevuEkran.setHekim(e.target.value ? Number(e.target.value) : '')}>
            {/* Kisitli hekimde "Tum Doktorlar" yok: secici kendi adina sabit. */}
            {!randevuEkran.hekimSabit && <option value="">{c('Tüm Doktorlar')}</option>}
            {randevuEkran.hekimSecenekleri.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select>
          {!randevuEkran.hekimSabit && (randevuEkran.bolum !== '' || randevuEkran.hekim !== '') && (
            <button type="button" className="kapat" title={c('Bölüm/hekim filtresini kaldır')}
                    onClick={() => { randevuEkran.setBolum(''); randevuEkran.setHekim('') }}>×</button>
          )}
        </>
      ) : tanim.basvuruSuzgeci ? (
        <BasvuruSeridi s={basvuruSuzgec} />
      ) : tanim.primSuzgeci ? (
        <PrimSeridi s={primSuzgec} />
      ) : (tanim.bolumSuzgeci || rolSuzgeciVar) ? (
        // Personel listesinde bölüm SOLDAKİ AĞAÇTA (963) - combo çizilmez.
        <PersonelSeridi s={personelSuzgec} bolumSuzgeci={tanim.bolumSuzgeci && ekran?.kod !== 'personel'} />
      ) : tanim.ekstre && (
        <button
          disabled={!seciliSatir}
          title={seciliSatir ? 'Seçili hesabın ekstresi' : 'Önce bir satır seçin'}
          onClick={() => {
            if (!seciliSatir) return;
            const hesap = { id: Number(seciliSatir.id), ad: String(seciliSatir.ad ?? seciliSatir.unvan ?? seciliSatir.id) };
            // YENİ SEKMEDE (hasta, 23.10.2026): ekstre kaynağının kendi listesi (Kasa › Cari Ekstre)
            //   hesaba süzülmüş açılır, liste yerinde kalır. Sekmesiz çalışmada / liste yoksa eski mod.
            const e = tanim.ekstre;
            const hedef = e?.yeniSekme && ekranSekmesi
              ? LISTELER.find(l => l.kaynak === e.kaynak && l.urlFiltreAlani === e.alan) : undefined;
            if (e && hedef) git(`/${hedef.rota ?? hedef.kaynak}?${e.alan}=${hesap.id}`);
            else setEkstre(hesap);
          }}
        >
          📄 Ekstre
        </button>
      )}
      // RANDEVU (251, kullanici: "arama editi sagina takvim butonu, basinca
      //   randevu takvimi listeye bassin"): takvim artik listenin ALTINDA
      //   degil, Liste/Grup/Analiz yanindaki "Takvim" dugmesiyle onun YERINE
      //   cizilir - ust serit (arama, cipler, bolum/hekim suzgeci) ortak kalir.
      // SONUC ONAY OZET SERIDI (446, mockup ".ozet"): ciplerin altinda,
      //   gridin ustunde. Cipi olan kutu tiklaninca o suzgeci acar.
      // KULLANICILAR (mockup kullanicilar.html `.ozet`): sayaclar ARAMANIN
      //   USTUNDE (kullanici: "arama editi ustune daha iyi") - ekrana girince
      //   ilk okunan satir "neye bakmam gerek" olsun.
      ustSerit={panel?.ustSerit?.(ekranBaglami)}
      // GOZ UNITE AKISI (mockup goz_hasta_listesi.html `.kanban`): bes
      //   istasyon yan yana - grid "kim var"i, kanban "hangi masada yigilma
      //   var"i cevaplar. Ikisi AYNI kaynagi okur (goz-akis).
      // YATAK PANOSU (mockup yatak_panosu.html): "yer var mi" sorusu LISTE
      //   degil PANO ile cevaplanir - kutu oda, satir yatak. Grid altta
      //   suzulebilir haliyle durur.
      // PORTALDA OZET SERITLERI HIC CIZILMEZ (796 V2 - GUVENLIK).
      //   Bu seritler KURUMUN GENELINI sayiyor: "8 onay bekliyor", "2 panik
      //   acik", "TAT asimi 1", cihaz durumu. Liste satirlari kapsam
      //   kuraliyla suzuluyor ama SERIT kendi sorgusunu yapiyor - hasta
      //   portalinda laboratuvarin butun kuyrugu gorunuyordu. Kapsam disi
      //   sayilari gostermek, kaydin kendisini gostermekle ayni sinifta.
      ustPanel={portalda ? undefined : ekran?.ustPanel ?? panel?.ustPanel?.(ekranBaglami)}
      // LABORATUVAR (446): mockup'larda tablo ile secili kaydin ayrintisi
      //   AYNI ekranda durur (tetkik/tup plani, antibiyogram, varyantlar).
      //   Teknisyen listeyi kaybetmeden ayrintiya bakabilmeli.
      // HASTA KARTI GRIDIN SAGINDA (kullanici: "hasta istem kartini alttan
      //   gridin sagina al"; mockup lab_istem_numune_kabul.html .ucPanel):
      //   tetkik tablosu gridin altinda tam genislikte kalir, hasta/etiket/
      //   kurallar kutulari saga gecer. Iki panel AYNI istegi paylasir.
      // SECILI TETKIK PANELI (492, mockup lab_tetkik_katalogu sag kolonu):
      //   katalogda gezerken LOINC/referans/panel/sonuc zamani sorulari karti
      //   acmadan cevaplansin.
      // BOS BASVURU LISTESI (kullanici: "başvuru kayıtları listelenmedi"):
      //   varsayilan suzgec BUGUN; o gun kayit yoksa liste bos gorunuyor ve
      //   sebebi yazmiyordu. Sebep + tek tikla tum tarihler.
      bosEk={tanim.basvuruSuzgeci && basvuruSuzgec.tarih !== '' ? (
        <div style={{ marginTop: 6 }}>
          <span className="sonuk">
            Seçili tarih aralığında başvuru yok
            ({TARIH_ON_AYARLAR.find(t => t.deger === basvuruSuzgec.tarih)?.ad
              ?? basvuruSuzgec.tarih}).
          </span>{' '}
          <button type="button" className="d" onClick={() => basvuruSuzgec.setTarih('')}>
            Tüm tarihleri göster
          </button>
        </div>
      ) : undefined}
      solPanel={tanim.kaynak === 'lab-tetkik'
        ? <LabKatalogAgaci secim={agacSecim} onSecim={setAgacSecim} />
        : ekran?.solPanel}
      // Yan panel de kurum ici ozet tasiyor (lab tetkik ozeti, detay paneli).
      yanPanel={portalda ? undefined : ekran?.yanPanel ?? panel?.yanPanel?.(ekranBaglami)}
      altPanel={portalda ? undefined : ekran?.altPanel ?? panel?.altPanel?.(ekranBaglami)}
      // LAB KANBAN (711): Lab Is Emirleri listesinin "Kanban" gorunumu -
      //   kolon = asama, surukle-birak = asama gecisi.
      // RANDEVU: Liste / Takvim secimi de kaldigi yerden (randevuTercihi).
      gorunumBaslangic={tanim.kaynak === 'randevu' ? randevuTercihiOku(kullanici?.id).liste : undefined}
      onGorunumDegisti={tanim.kaynak === 'randevu' ? g => randevuTercihiYaz(kullanici?.id, { liste: g }) : undefined}
      ekGorunumler={ekran?.ekGorunumler}
      grupAnalizGizli={!!ekran?.grupAnalizGizli}
      ekGorunum={tanim.kaynak === 'dis-lab-isemri' ? { ad: 'Kanban', ik: '🗂', icerik: <DisLabPano yenile={yenile} /> }
      : tanim.kaynak === 'randevu' ? {
        ad: 'Takvim', ik: '📅',
        icerik: (
          <RandevuTakvimi
            ayarlar={randevuEkran.takvimAyarlari}
            // KALDIGI YER: son takvim gorunumu (Gun/Hafta/Hekim/Cihaz).
            gorunumBaslangic={randevuTercihiOku(kullanici?.id).gorunum}
            onGorunumDegisti={g => randevuTercihiYaz(kullanici?.id, { gorunum: g })}
            hekimSabit={randevuEkran.hekimSabit}
            doktorYok={!randevuEkran.bolumDoktorAcik}
            bolum={randevuEkran.bolum === '' ? undefined : randevuEkran.bolum}
            hekimId={randevuEkran.hekim === '' ? undefined : randevuEkran.hekim}
            yenile={yenile}
            // Hekim gorunumunde sutunun hekimi de karta gecer (251).
            hekimler={randevuEkran.hekimSecenekleri}
            // CIHAZ gorunumu (316): radyolojide randevu cihaza verilir.
            cihazlar={randevuEkran.cihazlar}
            // RANDEVU BEKLEYEN ISTEMLER (316): panel yalniz radyoloji cihazi
            //   tanimliysa cizilir - poliklinik kurulumunda hic gorunmez.
            yanPanel={randevuEkran.cihazlar.length > 0 ? (
              <RandevuBekleyenPanel
                secili={randevuEkran.bekleyenSecili}
                onSecim={randevuEkran.setBekleyenSecili}
                yenile={yenile}
                onRandevuModali={i => radyolojiModal.setRandevu({
                  istemId: i.id, accessionNo: i.accessionNo,
                  tetkikAdi: i.tetkik, modalite: i.modalite, sureDk: i.sureDk,
                })}
              />
            ) : undefined}
            onKapatmaIste={(cihazId, bas, bit) => radyolojiModal.setKapatma({
              cihazId, baslangic: bas, bitis: bit,
              cihazAdi: randevuEkran.cihazlar.find(c => c.id === cihazId)?.ad ?? '',
            })}
            onBirak={(veri, bas, cih) => {
              // Yuk istemin kendisi (panel JSON yazar) - secili satira bakmayiz.
              try { void randevuEkran.bekleyeneRandevuVer(JSON.parse(veri) as BekleyenIstem, bas, cih) }
              catch { /* taninmayan surukleme yuku - yok say */ }
            }}
            onYeni={(bas, hek, cih) => {
              // Panelde istem SECILIYSE bos saate tiklamak yeni randevu formu
              //   degil, o isteme randevu demektir (dokunmatik/erisilebilir yol).
              // Randevuyu yalniz GOREN rol (uzman doktor varsayilani, 947) bos
              //   saate tiklayinca kart acmaz - kaydedemeyecegi formu gostermeyiz.
              if (!yetki('randevu', 'ekle')) return;
              if (randevuEkran.gecmisGun(bas)) return;
              if (randevuEkran.bekleyenSecili) { void randevuEkran.bekleyeneRandevuVer(randevuEkran.bekleyenSecili, bas, cih); return }
              // Cihaz sutunundan aciliyorsa bolum/hekim ARANMAZ - kaynak cihaz.
              const bol = cih ? undefined : (randevuEkran.hekimBolumu(hek) ?? (randevuEkran.bolum || undefined));
              git(`/randevu/yeni?baslangic=${encodeURIComponent(bas)}`
                  + (hek ? `&hekim=${hek}` : '')
                  + (cih ? `&cihaz=${cih}` : '')
                  + (bol ? `&bolum=${bol}` : ''));
            }}
            onAc={id => git(`/randevu/${id}`)}
            onAralik={(bas, sure, hek, cih) =>
              randevuEkran.setAralik(bas
                ? { baslangic: bas, sureDk: sure, hekimId: hek, cihazId: cih } : null)}
          />
        ),
      } : undefined}
    />
      </div>
    </div>
    </>
    )}
    </>}
    {/* PENCERELER LİSTE BLOĞUNUN DIŞINDA (15.10.2026): kart kendi sekmesindeyken liste gizli -
        karttan açılan pencereler (ICD arama, sonuç girişi, dönüşüm...) yine çizilmeli. */}

    {acikKasaId !== null && (
      <KasaIslemKarti
        kayitIdProp={acikKasaId}
        onKapat={() => { setAcikKasaId(null); setYenile(t => t + 1) }}
      />
    )}

    {/* CEK/SENET: kiymet karti. Kaydedilince ayni bilgilerle kasa islemi
        (23/24/33/34) acilir ve kiymete baglanir - cari o anda alacaklanir /
        borclanir, kagit portfoye girer. */}
    {cekTuru !== null && (
      <GenForm
        kaynak="cek-senet"
        id="yeni"
        baslik={cekTuru === 24 || cekTuru === 34 ? 'Senet' : 'Çek'}
        yeniKayitVarsayilanlari={{
          tur: cekTuru === 24 || cekTuru === 34 ? 2 : 1,
          yon: cekTuru === 33 || cekTuru === 34 ? 2 : 1,
        }}
        onKapat={() => setCekTuru(null)}
        onKaydedildi={id => { void cekKartKaydedildi(cekTuru, id) }}
      />
    )}

    {kasaTuru !== null && (
      <KasaIslemKarti
        // SECILI BASVURUNUN ACIK TAHSILATI ONERILIR (kullanici: "tahsilat
        //   butonuna basınca da açık tahsilat tutarı gelsin"): kart bos
        //   acilinca memur hastayi ve tutari ikinci kez yaziyordu.
        acilis={tahsilatAcilisi(kasaTuru)}
        onKapat={() => { setKasaTuru(null); setYenile(t => t + 1) }}
      />
    )}

    {/* HASTA AVANSI (779): tahsilat karti AVANS damgasiyla acilir - taraf
        aramasi da yalniz hastalari gosterir. Damga, para tumuyle mahsup
        edildikten sonra da kaydin avans listesinde kalmasini saglar. */}
    {avansTuru !== null && (
      <KasaIslemKarti
        acilis={{ tur: avansTuru, avans: true }}
        onKapat={() => { setAvansTuru(null); setYenile(t => t + 1) }}
      />
    )}

    {/* AVANS IADESI (780): NAKIT ODEME karti, avansa bagli acilir. Tutar
        kalanla onerilir; fazlasini sunucu tetigi reddeder ("İade tutarı kalan
        avansı aşamaz"). */}
    {avansIade !== null && (
      <KasaIslemKarti
        acilis={{ tur: 31, tarafId: avansIade.tarafId,
                  tarafUnvan: avansIade.tarafUnvan, tutar: avansIade.tutar,
                  avansKaynakId: avansIade.avansId }}
        onKapat={() => { setAvansIade(null); setYenile(t => t + 1) }}
      />
    )}

    {kasaAcilis !== null && (
      <KasaIslemKarti
        acilis={kasaAcilis}
        onKapat={() => { setKasaAcilis(null); setYenile(t => t + 1) }}
      />
    )}

    {acikBelgeId !== null && (
      <BelgeKarti id={acikBelgeId} onKapat={() => setAcikBelgeId(null)} />
    )}
    {hastaTamamla && (
      // Hasta kartının KENDİ kuralları: zorunlu alanlar, kimlik no (bu akışta zorunlu), mükerrer kimlik.
      <GenForm kaynak="hasta" id={hastaTamamla.id} baslik={c('Hasta Kartı - başvuru için tamamlayın')}
               cariyeBaglaGizli zorunluAlanlar={['vkno']}
               onKaydedildi={hid => { hastaTamamla.coz({ id: hid }); setHastaTamamla(null) }}
               onMevcutKayit={hid => { hastaTamamla.coz({ id: hid, mevcut: true }); setHastaTamamla(null) }}
               onKapat={() => { hastaTamamla.coz(null); setHastaTamamla(null) }} />
    )}
    {ertelenecek && (
      <RandevuErtelePenceresi randevu={ertelenecek} onKapat={() => setErtelenecek(null)}
                              onErtelendi={() => { setErtelenecek(null); setYenile(t => t + 1) }} />
    )}
    {acikOturumId !== null && (
      <BankoOturumModali oturumId={acikOturumId} onKapat={() => {
        setAcikOturumId(null);
        setYenile(t => t + 1);
      }} />
    )}
    {oturumAcBanko !== null && (
      <BankoOturumModali bankoId={oturumAcBanko} onKapat={() => {
        setOturumAcBanko(null);
        // Modal kapanınca liste tazelenir: oturum açılmış ya da kapanmış
        //   olabilir, "açık oturum" sütunu değişti.
        setYenile(t => t + 1);
      }} />
    )}

    {/* HASTA KARTINDAN YENİ BAŞVURU (782, kullanıcı): hasta kartı KAPANIR,
        başvuru kartı onun yerine açılır. Önceden ikisi üst üste duruyordu ve
        "hangi karttayım" sorusu doğuyordu. Hasta ön-dolgu olarak geçer -
        başvuru cari aramasıyla değil, hasta seçili açılır. */}
    {yeniBasvuruHasta !== null && (
      <BelgeKarti
        tur={19}
        tarafId={yeniBasvuruHasta.id}
        tarafUnvan={yeniBasvuruHasta.unvan}
        onKapat={() => setYeniBasvuruHasta(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}

    {yeniBelgeTuru !== null && (
      <BelgeKarti
        tur={yeniBelgeTuru}
        onKapat={() => setYeniBelgeTuru(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}

    {/* MESAJ GECMISI (178): belgenin e-Belge yolculugu - hazirlama, gonderim
        denemeleri ve GIB yanitlari tek pencerede. */}
    {eBelgeMesajlari && (
      <Modal
        baslik={`e-Belge Mesaj Geçmişi — ${eBelgeMesajlari.belgeNo}`}
        onKapat={() => setEBelgeMesajlari(null)}
        alt={<button className="d kapat-dugmesi"
                     onClick={() => setEBelgeMesajlari(null)}>{c('Kapat')}</button>}
      >
        <div className="kagrup">
          {eBelgeMesajlari.satirlar.length === 0 ? (
            <div className="not" style={{ padding: 10 }}>
              Bu belge için henüz e-Belge işlemi yapılmamış.
            </div>
          ) : (
            <table className="grid">
              <thead>
                <tr><th style={{ width: 40 }}>#</th><th style={{ width: 140 }}>Tarih</th>
                    <th>Olay</th><th>Durum</th><th style={{ width: 90 }}>Kod</th>
                    <th>Açıklama</th></tr>
              </thead>
              <tbody>
                {eBelgeMesajlari.satirlar.map(m => (
                  <tr key={m.sira}>
                    <td>{m.sira}</td>
                    <td>{m.tarih ? new Date(m.tarih).toLocaleString('tr-TR') : '—'}</td>
                    <td>{m.olay}</td>
                    <td>{m.durum}</td>
                    <td>{m.kod}</td>
                    <td>{m.aciklama}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </Modal>
    )}

    {iceriAl && (
      <IceriAlModali
        baslik={iceriAl.ad}
        sablonIndir={(dolu: boolean) => api.fiyatListesiSablon(iceriAl.listeId, dolu)}
        yukle={(dosya: File) => api.fiyatListesiIceriAl(iceriAl.listeId, dosya)}
        onKapat={() => setIceriAl(null)}
        onAlindi={() => setYenile(t => t + 1)}
      />
    )}
    {rolModali && (
      <KalemRolModali
        belgeSatirId={rolModali.satirId}
        kalemAdi={rolModali.ad}
        onKapat={() => setRolModali(null)}
        onTamam={() => setYenile(x => x + 1)}
      />
    )}
    {donemModali && (
      <DonemKapatModali
        tarafId={donemModali.tarafId}
        kisi={donemModali.kisi}
        onKapat={() => setDonemModali(null)}
        onTamam={() => setYenile(x => x + 1)}
      />
    )}
    {belgeTuruSira && (
      <BelgeTuruSiraModali onKapat={() => setBelgeTuruSira(false)}
                           onKaydedildi={() => { setBelgeTuruSira(false); setYenile(t => t + 1) }} />
    )}
    {yatisKabul && (
      <YatisKabulModali
        hastaId={yatisKabul.hastaId ?? null}
        hastaAdi={yatisKabul.hastaAdi}
        onKapat={() => setYatisKabul(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}
    {gozSema !== null && (
      <GozSemasi
        gozMuayeneId={gozSema}
        onKapat={() => setGozSema(null)}
        onTamam={() => { setYenile(t => t + 1); setKartTazele(t => t + 1) }}
      />
    )}
    {gozDikte !== null && (
      <GozDikte
        gozMuayeneId={gozDikte}
        onKapat={() => setGozDikte(null)}
        onTamam={() => { setYenile(t => t + 1); setKartTazele(t => t + 1) }}
      />
    )}
    {/* 976: panodan istem sepeti. Göz sekmesinde açılıyor - panoda istenen şey
        görüntüleme; sepet kaydı muayeneye, ücreti başvuruya yazıyor. */}
    {gozPanoIstem !== null && (
      <IstemSepetiModal muayeneId={gozPanoIstem} baslangicSekme="goz"
                        onKapat={() => setGozPanoIstem(null)}
                        onBitti={() => setYenile(t => t + 1)} />
    )}
    {yatisNakil !== null && (
      <NakilModali
        yatisId={yatisNakil}
        onKapat={() => setYatisNakil(null)}
        onTamam={() => { setYenile(t => t + 1); setKartTazele(t => t + 1) }}
      />
    )}
    {yatisTaburcu !== null && (
      <TaburcuModali
        yatisId={yatisTaburcu}
        onKapat={() => setYatisTaburcu(null)}
        onTamam={() => { setYenile(t => t + 1); setKartTazele(t => t + 1) }}
      />
    )}
    {dozSatiri && (
      <DozSatirModali
        yatisId={dozSatiri.yatisId}
        dozId={dozSatiri.dozId}
        atlaModu={dozSatiri.atla}
        onKapat={() => setDozSatiri(null)}
        onTamam={() => setYenile(t => t + 1)}
      />
    )}
    <RadyolojiModallari m={radyolojiModal} tazele={() => setYenile(t => t + 1)} />
    <AmeliyatAcilModallari m={akisModal} tazele={() => setYenile(t => t + 1)} />
    {sonucGirisi !== null && (
      <SonucGirisModali
        istemId={sonucGirisi}
        onKapat={() => setSonucGirisi(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}
    <UtsModallari m={utsModal} tazele={() => setYenile(t => t + 1)} />
    {donusum && (
      <BelgeDonusumModali
        belgeId={donusum.belgeId}
        belgeTur={donusum.belgeTur}
        varsayilanHedef={donusum.hedef}
        // Hedef LISTEDE secildiyse kartta degistirilemez (kullanici): karar
        //   zaten verilmis, ikinci kez sormak hata kapisi acar.
        hedefKilitli={donusum.hedef != null}
        onKapat={() => setDonusum(null)}
        // Modal KAPANMAZ: sonucu (yeni belge no + tutar) kendi icinde gosterir.
        //   mesaj() kullanmak tarayici diyalogu acar ve sayfayi kilitler.
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {/* ICD ARAMA (kullanici: "gelen ekranda tani arayabilmeliyim"): yazdikca
        arar, secilen kod SUNUCUDA tani satirina donusur (ana tani varsa ek). */}
    {icdAramaAcik && (icdMuayeneId !== null || (kartId !== null && kartId !== 'yeni')) && (
      <KaynakArama
        kaynak="icd" baslik="ICD-10 tanı ara"
        // İlk açılışta sık kullanılanlar (ilaç aramasıyla aynı biçim, 16.10.2026).
        ilkSik
        ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
        // ÖNCEKİ TANILAR bu HASTANIN başka muayenelerinden gelir - kronik
        //   hastada aynı tanı her muayenede yeniden yazılırken kod kayabilir.
        oncekiBaslik="Önceki Tanılar"
        onceki={async () => {
          const y = await api.muayeneTaniOnerileri((icdMuayeneId ?? Number(kartId)));
          return y.onceki.map(t => ({ kod: t.kod, ad: t.ad }));
        }}
        // ŞABLON TANILARI (931): muayenenin bölüm / doktor şablonlarının sık tanıları.
        sablonBaslik="Şablon Tanıları"
        // YZ ÖNERİSİ: bağlam SUNUCUDA toplanır ve anonimleştirilir (ad, soyad,
        //   kimlik no gitmez); ekran yalnız muayene numarasını yollar.
        yz={async () => {
          const y = await api.muayeneYzTaniOnerisi((icdMuayeneId ?? Number(kartId)));
          const notlar = [
            y.kirmiziBayrak && `⚠ ${y.kirmiziBayrak}`,
            y.eksikBilgi && `❓ ${y.eksikBilgi}`,
            y.atilanKod > 0 && `${y.atilanKod} öneri ICD kataloğunda bulunamadığı için gösterilmedi.`,
            y.oneriler.length === 0 && 'YZ bu bilgilerle öneri üretmedi; şikâyet / bulgu ekleyip tekrar deneyin.',
          ].filter((x): x is string => !!x);
          return { satirlar: y.oneriler, notlar, uyari: y.uyari };
        }}
        sablon={async () => (await api.muayeneSablonTercihleri((icdMuayeneId ?? Number(kartId)))).tanilar}
        // ÇOK SEÇİM (kullanıcı): pencere her seçimde kapanmaz; eklenen tanı
        //   ✓ ile işaretlenir, tanı gridi arkada tazelenir. "Kapat" ile çıkılır.
        acikKalir
        ustSecimler={<>
          <label>Tür
            <select value={tani.kesinlik} aria-label="Tanı türü"
                    onChange={e => tani.setKesinlik(Number(e.target.value))}>
              {tani.kesinlikler.map(t => <option key={t.kod} value={t.kod}>{t.ad}</option>)}
            </select>
          </label>
          <label>Taraf
            <select value={tani.taraf} aria-label="Taraf"
                    onChange={e => tani.setTaraf(Number(e.target.value))}>
              {tani.taraflar.map(t => <option key={t.kod} value={t.kod}>{t.ad}</option>)}
            </select>
          </label>
        </>}
        onKapat={() => { setIcdAramaAcik(false); setIcdMuayeneId(null) }}
        onSec={async satir => {
          try {
            await api.muayeneTaniEkle((icdMuayeneId ?? Number(kartId)), String(satir.kod),
                                      { kesinlik: tani.kesinlik, taraf: tani.taraf });
          } catch (h) {
            mesaj(hataMetni(h));
            throw h;
          }
          // SAYAÇ SEÇİM ANINDA (461): kayıt kaydedilmese bile hekim o kodla
          //   çalışmıştır; sayacı kaydetmeye bağlamak listeyi geç doldurur.
          void api.katalogKullanildi('icd', String(satir.kod)).catch(() => {});
          setYenile(t => t + 1);
          setKartTazele(t => t + 1);
        }}
      />
    )}


    {/* KART (modal GenForm): muayene/lab tetkik ozel yerlesimi dahil,
        kendi dosyasinda (liste/ListeKarti). */}
    {/* BAŞVURU KARTI KENDİ SEKMESİNDE (hasta deseni): BelgeKarti çerçevesiz, sekmeyi doldurur. */}
    {kartSekmesi && belgeSekmeYolu ? (
      <BelgeKarti key={String(kartId)} sayfa
                  {...(kartId === 'yeni' ? { tur: tanim.yeniBelgeTuru,
                        // Hasta kartından "＋ Yeni Başvuru": hasta seçili gelir.
                        tarafId: Number(sorgu.get('tarafId')) || undefined, tarafUnvan: sorgu.get('tarafUnvan') ?? undefined,
                        // Randevudan başvuru (17.10.2026): gönderen / bölüm dolu, kayıtta randevu bağlanır.
                        randevuId: Number(sorgu.get('randevuId')) || undefined,
                        onDolguPersonel: Number(sorgu.get('personelId'))
                          ? { id: Number(sorgu.get('personelId')), ad: sorgu.get('personelAd') ?? '' } : undefined,
                        onDolguBolumId: Number(sorgu.get('bolumId')) || undefined }
                     : { id: Number(kartId) })}
                  onKapat={() => ekranSekmesi!.kapat()}
                  onKaydedildi={() => window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: tanim.kaynak }))} />
    ) : (
    <ListeKarti
      tanim={tanim} kartId={kartId} kartOzel={kartOzel} sekmeVerisi={sekmeVerisi}
      aksiyon={aksiyon}
      muayeneBilgiAcik={muayeneBilgiAcik} setMuayeneBilgiAcik={setMuayeneBilgiAcik}
      setIcdAramaAcik={setIcdAramaAcik}
      icdAc={mid => { setIcdMuayeneId(mid); setIcdAramaAcik(true) }}
      kartTazele={kartTazele} setKartTazele={setKartTazele}
      sorgu={sorgu} git={git} setYenile={setYenile}
      setOdaklaSonEklenen={setOdaklaSonEklenen}
      onBasvuruAc={(tarafId, unvan) => void basvuruAc(tarafId, unvan)}
    />
    )}
    </>
  );
}
