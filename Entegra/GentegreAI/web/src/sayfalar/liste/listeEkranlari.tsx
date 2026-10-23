import type { ReactNode } from 'react';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { usePersonelSuzgeci } from './usePersonelSuzgeci';
import { MuayeneOzetSeridi } from '../../bilesenler/MuayeneOzetSeridi';
import { LabTetkikOzeti } from '../../bilesenler/lab/LabTetkikOzeti';
import { KysPolitikaSeridi } from './KysPolitikaSeridi';
import { KysOlayPaneli } from '../kys/olay/KysOlayPaneli';
import { KysRiskPaneli } from '../kys/risk/KysRiskPaneli';
import { MusteriGostergesi, MusteriOnizleme } from './MusteriPanelleri';
import { KonsultasyonOnizlemePaneli, KonsultasyonUstPanel, useKonsultasyonSuzgeci } from '../konsultasyon/KonsultasyonPanelleri';
import { SevkOnizlemePaneli, SevkUstPanel, useSevkSuzgeci } from '../sevk/SevkPanelleri';
import { LabDetayPaneli, labDetayVarMi, labYanVarMi } from '../../bilesenler/LabDetayPaneli';
import { EnabizPaketPaneli } from '../../bilesenler/EnabizPaketPaneli';
import { TeleradTeslimIzi } from '../../bilesenler/TeleradTeslimIzi';
import { TeleradGelenPaneli } from '../../bilesenler/TeleradGelenPaneli';
import { LabOzetSeridi } from '../../bilesenler/LabOzetSeridi';
import { KullaniciOzetSeridi } from '../../bilesenler/KullaniciOzetSeridi';
import { BelgeTakipOzetSeridi } from '../../bilesenler/BelgeTakipOzetSeridi';
import { BelgeTuruOzetSeridi } from '../../bilesenler/BelgeTuruOzetSeridi';
import { KullaniciAltPanel } from '../../bilesenler/KullaniciAltPanel';
import { GozHastaPaneli } from '../../bilesenler/GozHastaPaneli';
import { GozUniteKanban } from '../../bilesenler/goz/GozUniteKanban';
import { GozUniteOzeti } from '../../bilesenler/goz/GozUniteOzeti';
import { GozUniteTablolari } from '../../bilesenler/goz/GozUniteTablolari';
import { YatakPanosu } from '../../bilesenler/YatakPanosu';
import { EmarCizelgesi } from '../../bilesenler/yatan/EmarCizelgesi';
import { HemsireIzlem } from '../../bilesenler/yatan/HemsireIzlem';
import { YatanIcmal } from '../../bilesenler/yatan/YatanIcmal';
import { BolgePaneli, ProtokolOnizlemePaneli, SablonOnizlemePaneli, useBolgeSuzgeci } from '../radyoloji/RadyolojiTanimPanelleri';
import { CihazGostergesi, CihazOnizlemePaneli, CihazSolPanel, useCihazGostergesi, useCihazSuzgeci } from '../radyoloji/CihazPanelleri';
import { GozCihazGostergesi, GozCihazOnizlemePaneli, GozCihazSolPanel,
         useGozCihazGostergesi, useGozCihazSuzgeci } from '../goz/GozCihazPanelleri';
import { OrderGostergesi, OrderOnizlemePaneli, OrderSolPanel, useOrderGostergesi, useOrderSuzgeci } from '../yatan/OrderPanelleri';
import { GozlukGostergesi, GozlukOnizlemePaneli, GozlukSolPanel, useGozlukGostergesi, useGozlukSuzgeci } from '../goz/GozlukPanelleri';
import { GoruntulemeGostergesi, GoruntulemeOnizlemePaneli, GoruntulemeSolPanel, useGoruntulemeGostergesi, useGoruntulemeSuzgeci } from '../goz/GozGoruntulemePanelleri';
import { BankaHareketYanPanel, BankaOzetSeridi } from '../banka/BankaHareketPanelleri';
import { GozPanoSolPanel, GozPanoTazeleSeridi, useGozPanoOzeti, useGozPanoSuzgeci } from '../goz/GozPanoPanelleri';
import { GozMuayeneGostergesi, GozMuayeneOnizleme, GozMuayeneSolPanel, useGozMuayeneGostergesi, useGozMuayeneSuzgeci } from '../goz/GozMuayenePanelleri';
import { PersonelBolumAgaci, PersonelGostergesi, PersonelKartlari, PersonelOnizleme, PersonelOrganizasyon,
         usePersonelGostergesi } from './PersonelPanelleri';

/**
 * LİSTE EKRANLARI ve PANELLERİ — liste ekranının çevresi KAYNAK BAŞINA tek yerde (refaktör 22.10.2026).
 *
 * `Liste.tsx` gridin çevresini (üst şerit, üst panel, sol panel, yan panel, alt panel, ek görünüm)
 * GenGrid prop'larında `tanim.kaynak === '...'` zincirleriyle kuruyor, on ekranın süzgeç + gösterge
 * kancalarını da gövdesinde tek tek çağırıyordu (12 kat iç içe filtre zinciri dahil). İki parça:
 *
 *  · `useListeEkrani` - süzgeç / gösterge TAŞIYAN ekranlar (personel, radyoloji tanım / cihaz, order,
 *    göz muayene / gözlük / cihaz / görüntüleme / ünite panosu, konsültasyon, sevk). Kancalar her
 *    çizimde AYNI SIRAYLA çağrılır (React kuralı; pasif ekranın kancası iş yapmaz), dönen tek nesne
 *    etkin ekranın filtresi ve panelleridir.
 *  · `listePaneli` - durumsuz şerit / paneller (kaynak + seçili satır yeter).
 *
 * Portal kuralı (796 V2 - GÜVENLİK) Liste'de kalır: portalda üst / yan / alt panel hiç çizilmez -
 * bu şerit ve paneller kurumun GENELİNİ sayar, liste satırlarının kapsam süzgecinden geçmez.
 */

export interface ListeEkranBaglami {
  kaynak: string;
  /** Aynı kaynağı kullanan ikinci ekran (Tedarikçi Listesi `cari` + rota 'tedarikci'). */
  rota?: string;
  portalda: boolean;
  yenile: number;
  tazele(): void;
  seciliSatir: ListeSatiri | null;
  git(yol: string): void;
  /** Kart açılışı (sekme düzeninde kendi sekmesinde). */
  gitKart(yol: string): void;
  aksiyon(kod: string, satir?: ListeSatiri | null): void | Promise<void>;
  /** Üst şerit kutusu listeyi o çiple açar. */
  setCip(i: number): void;
  /** Seçili çip - kutunun "seçili" görünümü için. */
  cipIndeks?: number;
  personelSuzgec: ReturnType<typeof usePersonelSuzgeci>;
  /** GÖZ ÜNİTE PANOSU (976): kanban da gridin çipiyle süzülür; seçimi aksiyonlara geçer. */
  panoCipFiltresi?: Kosul;
  panoSeciliId: number | null;
  panoSec(s: ListeSatiri | null): void;
}

export interface ListeEkrani {
  kod: string;
  /** Sabit filtreye etkin ekranın süzgecini AND'ler. */
  filtre(temel: Kosul | undefined): Kosul | undefined;
  ustPanel?: ReactNode;
  solPanel?: ReactNode;
  yanPanel?: ReactNode;
  altPanel?: ReactNode;
  ekGorunumler?: { ad: string; ik: string; icerik: ReactNode }[];
  grupAnalizGizli?: boolean;
}

export function useListeEkrani(b: ListeEkranBaglami): ListeEkrani | null {
  const { kaynak: k, portalda: p, yenile, seciliSatir: s, aksiyon, git } = b;
  // Etkin ekran bayrakları - portalda hiçbiri (gösterge kurum genelini sayar).
  const personel = k === 'personel' && !p;
  const radTanim = (k === 'radyoloji-sablon' || k === 'radyoloji-protokol') && !p;
  const radCihaz = k === 'radyoloji-cihaz' && !p;
  const order = k === 'yatis-order' && !p;
  const gozMuayene = k === 'goz-muayene' && !p;
  const gozluk = k === 'goz-gozluk-recete' && !p;
  const kons = k === 'konsultasyon' && !p;
  const sevk = k === 'sevk' && !p;
  // Radyolojinin cihaz ekranıyla aynı adları taşıyor - göz önekli ayrı bileşen kümesi (978).
  const gozCihaz = k === 'goz-cihaz' && !p;
  const pano = k === 'goz-akis' && !p;
  const gor = k === 'goz-goruntuleme' && !p;

  // KANCALAR - sıra sabit, koşulsuz.
  const radBolge = useBolgeSuzgeci(radTanim);
  const gozlukS = useGozlukSuzgeci(gozluk);
  const gozlukG = useGozlukGostergesi(gozluk, yenile);
  const konsS = useKonsultasyonSuzgeci(kons, yenile);
  const sevkS = useSevkSuzgeci(sevk);
  const gozCihazS = useGozCihazSuzgeci(gozCihaz);
  const gozCihazG = useGozCihazGostergesi(gozCihaz, yenile);
  // Ünite panosu: 30 sn otomatik tazeleme; şerit, kanban ve alt tablolar TEK isteği paylaşır.
  const panoS = useGozPanoSuzgeci(pano);
  const panoD = useGozPanoOzeti(pano, yenile, b.tazele);
  const gorS = useGoruntulemeSuzgeci(gor);
  const gorG = useGoruntulemeGostergesi(gor, yenile);
  const gozS = useGozMuayeneSuzgeci(gozMuayene);
  const gozG = useGozMuayeneGostergesi(gozMuayene, yenile);
  const orderS = useOrderSuzgeci(order);
  const orderG = useOrderGostergesi(order, yenile);
  const cihazS = useCihazSuzgeci(radCihaz);
  const cihazG = useCihazGostergesi(radCihaz, yenile);
  const personelG = usePersonelGostergesi(personel, b.personelSuzgec, yenile);

  // PERSONEL LİSTESİ (963, mockup personel_listesi.html): gösterge şeridi + bölüm ağacı aynı veriden;
  //   önizleme sağda, Kart / Organizasyon ek görünüm. Süzgeç (bölüm + rol) Liste'de - ortak şerit.
  if (personel) return {
    kod: 'personel', filtre: t => t,
    ustPanel: <PersonelGostergesi veri={personelG} s={b.personelSuzgec} />,
    solPanel: <PersonelBolumAgaci veri={personelG} s={b.personelSuzgec} />,
    yanPanel: <PersonelOnizleme satir={s} yenile={yenile} />,
    ekGorunumler: [
      { ad: 'Kart', ik: '▦', icerik: <PersonelKartlari filtre={b.personelSuzgec.filtre(undefined)} yenile={yenile} /> },
      { ad: 'Organizasyon', ik: '⛬', icerik: <PersonelOrganizasyon filtre={b.personelSuzgec.filtre(undefined)} yenile={yenile} /> },
    ],
    grupAnalizGizli: true,
  };
  // RADYOLOJİ TANIMLARI (965): solda bölge, sağda önizleme.
  if (radTanim) return {
    kod: 'radyoloji-tanim', filtre: radBolge.filtre,
    solPanel: <BolgePaneli kaynak={k} s={radBolge} yenile={yenile} />,
    yanPanel: k === 'radyoloji-sablon' ? <SablonOnizlemePaneli satir={s} /> : <ProtokolOnizlemePaneli satir={s} />,
  };
  // RADYOLOJİ CİHAZLARI (967): gösterge + konum / durum süzgeci, önizleme.
  if (radCihaz) return {
    kod: 'radyoloji-cihaz', filtre: cihazS.filtre,
    ustPanel: <CihazGostergesi veri={cihazG} s={cihazS} />,
    solPanel: <CihazSolPanel veri={cihazG} s={cihazS} />,
    yanPanel: <CihazOnizlemePaneli satir={s} yenile={yenile} />,
  };
  // ORDER LİSTESİ (968): gösterge + servis / oda / tür süzgeci, önizleme.
  if (order) return {
    kod: 'yatis-order', filtre: orderS.filtre,
    ustPanel: <OrderGostergesi veri={orderG} s={orderS} />,
    solPanel: <OrderSolPanel veri={orderG} s={orderS} />,
    yanPanel: <OrderOnizlemePaneli satir={s} yenile={yenile} />,
  };
  // GÖZ MUAYENELERİ (970): gösterge + tür / hekim süzgeci, önizleme (hızlı işlemler aksiyon koduyla).
  if (gozMuayene) return {
    kod: 'goz-muayene', filtre: gozS.filtre,
    ustPanel: <GozMuayeneGostergesi veri={gozG} s={gozS} />,
    solPanel: <GozMuayeneSolPanel veri={gozG} s={gozS} />,
    yanPanel: <GozMuayeneOnizleme satir={s} yenile={yenile}
                                  onAc={id => git(`/goz-muayene/${id}`)}
                                  onTamamla={() => void aksiyon('goz.muayene-tamamla', s)}
                                  onGozluk={() => void aksiyon('goz.gozluk-recete', s)}
                                  onIstem={() => void aksiyon('goz.goruntuleme-istem', s)} />,
  };
  // GÖZLÜK REÇETELERİ (973): gösterge + tür / durum / optik süzgeci, önizleme.
  if (gozluk) return {
    kod: 'goz-gozluk-recete', filtre: gozlukS.filtre,
    ustPanel: <GozlukGostergesi veri={gozlukG} s={gozlukS} />,
    solPanel: <GozlukSolPanel veri={gozlukG} s={gozlukS} />,
    yanPanel: <GozlukOnizlemePaneli satir={s} yenile={yenile}
                                    onAc={id => git(`/goz-gozluk-recete/${id}`)}
                                    onImzala={() => void aksiyon('goz.gozluk-imzala', s)}
                                    onBildir={() => void aksiyon('goz.gozluk-bildir', s)}
                                    onOptik={() => void aksiyon('goz.gozluk-optik', s)}
                                    onTeslim={() => void aksiyon('goz.gozluk-teslim', s)} />,
  };
  // KONSÜLTASYON (1107): sekmeler (bana / bölümüme gelen · istediklerim · bölüm) + özet kutuları.
  if (kons) return {
    kod: 'konsultasyon', filtre: konsS.filtre,
    ustPanel: <KonsultasyonUstPanel s={konsS} />,
    altPanel: <KonsultasyonOnizlemePaneli satir={s ?? null} yenile={yenile}
                                          onAc={id => b.gitKart(`/konsultasyon/${id}`)}
                                          onYanitla={() => void aksiyon('konsultasyon.yanitla', s)} />,
  };
  // SEVK (1110): Giden / Gelen sekmeleri + kısa ön izleme (mockup v2, sade).
  if (sevk) return {
    kod: 'sevk', filtre: sevkS.filtre,
    ustPanel: <SevkUstPanel s={sevkS} />,
    altPanel: <SevkOnizlemePaneli satir={s ?? null} onAc={id => b.gitKart(`/sevk/${id}`)} />,
  };
  // GÖZ CİHAZLARI (978).
  if (gozCihaz) return {
    kod: 'goz-cihaz', filtre: gozCihazS.filtre,
    ustPanel: <GozCihazGostergesi veri={gozCihazG} s={gozCihazS} />,
    solPanel: <GozCihazSolPanel veri={gozCihazG} s={gozCihazS} />,
    yanPanel: <GozCihazOnizlemePaneli satir={s} yenile={yenile}
                                      onSina={() => void aksiyon('goz.cihaz-sina', s)}
                                      onMesajlar={() => void aksiyon('goz.cihaz-mesajlar', s)}
                                      onDemirbas={() => void aksiyon('goz.cihaz-demirbas', s)} />,
  };
  // GÖZ ÜNİTE PANOSU (976, mockup goz_unite_panosu.html): ÖNCE SAYAÇ ŞERİDİ, SONRA KANBAN - şerit
  //   "ünite tıkalı mı", kanban "kim nerede" sorusunu cevaplıyor. Kanbanı da çipler ve sol panel süzer
  //   (gridi süzüp kanbanı dolu bırakmak "süzgeç çalışmıyor" demekti).
  if (pano) return {
    kod: 'goz-akis', filtre: panoS.filtre,
    ustPanel: <>
      <GozPanoTazeleSeridi d={panoD} onYenile={b.tazele} />
      <GozUniteOzeti veri={panoD.veri} />
      <GozUniteKanban yenile={yenile} seciliId={b.panoSeciliId}
                      filtre={panoS.filtre(b.panoCipFiltresi)}
                      onSec={sat => b.panoSec(sat as unknown as ListeSatiri)}
                      // SÜRÜKLE-BIRAK: kart sütuna bırakılınca hasta o istasyona alınır. Kararı sunucu
                      //   veriyor - dilatasyon uyarısı da oradan geliyor.
                      onTasi={(sat, istasyon) => void guvenli(async () => {
                        const y = await api.gozIstasyonaAl(sat.id, { istasyon });
                        mesaj(y.tamamlandi
                          ? `${y.hasta} · ziyaret tamamlandı.`
                          : `${y.hasta} → ${y.istasyon}`
                            + (y.uyari ? ` — ${y.uyari}` : '')
                            + (y.muayeneYeni ? ` · göz muayenesi #${y.gozMuayeneId} açıldı` : ''));
                        b.panoSec(null);
                        b.tazele();
                      })} />
      <GozUniteTablolari veri={panoD.veri} />
    </>,
    solPanel: <GozPanoSolPanel veri={panoD.veri} s={panoS} />,
  };
  // GÖZ GÖRÜNTÜLEME (974): gösterge (ödeme / sıra / değerlendirme), tetkik-cihaz (sol), önizleme (sağ).
  //   HIZLI İŞLEM düğmeleri araç çubuğunun AYNI yolunu kullanır (aksiyon kodu).
  if (gor) return {
    kod: 'goz-goruntuleme', filtre: gorS.filtre,
    ustPanel: <GoruntulemeGostergesi veri={gorG} s={gorS} />,
    solPanel: <GoruntulemeSolPanel veri={gorG} s={gorS} />,
    yanPanel: <GoruntulemeOnizlemePaneli satir={s} yenile={yenile}
                                         onAc={id => git(`/goz-goruntuleme/${id}`)}
                                         onDegerlendir={() => void aksiyon('goz.gor-degerlendir', s)}
                                         onMuayene={() => void aksiyon('goz.gor-muayene', s)} />,
  };
  return null;
}

// ------------------------------------------------------------ durumsuz --

export interface ListePaneli {
  ustSerit?(b: ListeEkranBaglami): ReactNode;
  ustPanel?(b: ListeEkranBaglami): ReactNode;
  yanPanel?(b: ListeEkranBaglami): ReactNode;
  altPanel?(b: ListeEkranBaglami): ReactNode;
}

/** Seçili satırın kaydı (id > 0) - alt panellerin ortak koşulu. */
const kayitId = (b: ListeEkranBaglami) => b.seciliSatir && Number(b.seciliSatir.id ?? 0) > 0 ? Number(b.seciliSatir.id) : 0;

const PANELLER: Record<string, ListePaneli> = {
  // KULLANICILAR (mockup kullanicilar.html `.ozet` + `.sekmeler` / `.alt`): sayaçlar ARAMANIN ÜSTÜNDE;
  //   alt panelde seçili hesabın rolleri, açık oturumları, giriş hareketleri ve hesaba yapılan işlemler.
  //   Yetki SUNUCUDA ölçülür - panel düğmeleri karartılmaz, yetkisiz istek 403 ve sebebi panelde.
  kullanici: {
    ustSerit: b => <KullaniciOzetSeridi yenile={b.yenile} onCip={b.setCip} />,
    altPanel: b => kayitId(b) ? <KullaniciAltPanel kullaniciId={kayitId(b)} saltOkunur={false} /> : undefined,
  },
  // KURUMSAL KALİTE (1059): Politika & Hedefler listesinin üstünde politika / kapsam.
  'kys-gosterge': { ustSerit: () => <KysPolitikaSeridi /> },
  // BANKA HAREKETLERİ (1157, mockup banka_hareketleri.html): üstte hesap + çek + sayaçlar, sağda karar.
  'banka-hareket': {
    ustSerit: b => <BankaOzetSeridi yenile={b.yenile} onCip={b.setCip} onYenile={b.tazele} />,
    yanPanel: b => <BankaHareketYanPanel satir={b.seciliSatir} yenile={b.yenile} onIslendi={b.tazele} />,
  },
  // KURUMSAL KALİTE (1060 / 1062, mockup Kalite2 olay_bildirim · risk_listesi): liste + sağda kart.
  'kys-olay': { yanPanel: b => <KysOlayPaneli satir={b.seciliSatir} yenile={b.tazele} /> },
  'kys-risk': { yanPanel: b => <KysRiskPaneli satir={b.seciliSatir} yenile={b.tazele} /> },
  // MÜŞTERİ LİSTESİ VER3 (1150, mockup musteri_listesi_ver3.html): gösterge şeridi + sağda önizleme.
  //   Aynı kaynağı kullanan Tedarikçi Listesi (rota 'tedarikci') çizmez - sayılar müşteri kümesidir.
  cari: {
    ustPanel: b => b.rota ? undefined
      : <MusteriGostergesi yenile={b.yenile} cipIndeks={b.cipIndeks} onCip={b.setCip} />,
    yanPanel: b => b.rota ? undefined
      : <MusteriOnizleme satir={b.seciliSatir} yenile={b.yenile} tazele={b.tazele} git={b.git} gitKart={b.gitKart} />,
  },
  // İK BELGE TAKİBİ (1137 / 1138): eksik / doldu / yaklaşan · aktif / zorunlu / süreli / eksiği olan.
  'personel-belge-ozet': { ustSerit: b => <BelgeTakipOzetSeridi yenile={b.yenile} onCip={b.setCip} /> },
  'personel-belge-turu': { ustSerit: b => <BelgeTuruOzetSeridi yenile={b.yenile} onCip={b.setCip} /> },
  // YATAK PANOSU (mockup yatak_panosu.html): "yer var mı" sorusu pano ile; grid altta süzülebilir.
  yatak: { ustPanel: b => <YatakPanosu yenile={b.yenile} /> },
  // eMAR (698): üstte TEK HASTANIN gün çizelgesi, altta servis genelindeki doz kuyruğu.
  'order-uygulama': { ustPanel: b => <EmarCizelgesi yenile={b.yenile} onDegisti={b.tazele} /> },
  // HEMŞİRE İZLEMİ (699): üstte nöbet ekranı (ölçüm girişi + eğri + sıvı + risk), altta ölçüm satırları.
  'yatis-izlem': { ustPanel: b => <HemsireIzlem yenile={b.yenile} onDegisti={b.tazele} /> },
  // HİZMET İCMALİ (700): üstte tek yatışın icmali, altta günsonu tahakkukları.
  'yatis-tahakkuk': { ustPanel: b => <YatanIcmal yenile={b.yenile} /> },
  // SONUÇ ONAY ÖZET ŞERİDİ (446, mockup ".ozet"): kutu tıklanınca o süzgeç.
  'lab-sonuc': { ustPanel: b => <LabOzetSeridi yenile={b.yenile} onCip={b.setCip} /> },
  // MUAYENE LİSTESİ ÖZET ŞERİDİ (461): polikliniğin o günkü hali.
  muayene: { ustPanel: () => <MuayeneOzetSeridi /> },
  // SEÇİLİ TETKİK PANELİ (492, mockup lab_tetkik_katalogu sağ kolonu): kartı açmadan LOINC / referans /
  //   panel / sonuç zamanı.
  'lab-tetkik': { yanPanel: b => <LabTetkikOzeti id={b.seciliSatir ? Number(b.seciliSatir.id) : null} /> },
  // e-NABIZ (454): "Eksik Alan" yazan satırın cevabı paketin alanlarında - grid altında.
  'enabiz-paket': { altPanel: b => kayitId(b) ? <EnabizPaketPaneli paketId={kayitId(b)} /> : undefined },
  // TESLİM KUYRUĞU (814): "gitti mi, gitmediyse neden" - ham ORU ve ACK satırın altında.
  'telerad-teslim': { altPanel: b => kayitId(b) ? <TeleradTeslimIzi teslimId={kayitId(b)} /> : undefined },
  // GELEN RAPOR (817): "eşleşmedi" yazan satırın cevabı ham mesajda.
  'telerad-gelen': { altPanel: b => kayitId(b) ? <TeleradGelenPaneli gelenId={kayitId(b)} /> : undefined },
  // GÖZ HASTA ÖZETİ (691): OD/OS son değerler, takip planı, ziyaretler, işlemler ve reçeteler altta.
  'goz-hasta-ozet': { altPanel: b => kayitId(b) ? <GozHastaPaneli hastaId={kayitId(b)} /> : undefined },
};

/**
 * LABORATUVAR (446): tablo ile seçili kaydın ayrıntısı AYNI ekranda (tetkik/tüp planı, antibiyogram,
 * varyantlar) - hangi lab ekranının yan / alt paneli olduğu LabDetayPaneli'nin kendi kümesinde.
 */
const labPaneli = (kaynak: string): ListePaneli | undefined =>
  labYanVarMi(kaynak) || labDetayVarMi(kaynak) ? {
    yanPanel: labYanVarMi(kaynak) ? b => <LabDetayPaneli kaynak={kaynak} satir={b.seciliSatir} kisim="yan" /> : undefined,
    altPanel: labDetayVarMi(kaynak)
      ? b => b.seciliSatir ? <LabDetayPaneli kaynak={kaynak} satir={b.seciliSatir} kisim="ana" /> : undefined
      : undefined,
  } : undefined;

export function listePaneli(kaynak: string): ListePaneli | undefined {
  const sabit = PANELLER[kaynak], lab = labPaneli(kaynak);
  if (!sabit) return lab;
  if (!lab) return sabit;
  // Aynı kaynak hem tabloda hem lab kümesinde: tablodaki önce (zincirdeki sıra).
  return { ...lab, ...Object.fromEntries(Object.entries(sabit).filter(([, v]) => v)) };
}
