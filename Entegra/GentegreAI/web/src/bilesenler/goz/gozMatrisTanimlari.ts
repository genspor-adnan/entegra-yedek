import type { GozMatrisTanimi } from './GozOlcumMatrisi';

/**
 * GÖZ MUAYENESİ ÖLÇÜM SEKMELERİNİN MATRİS TANIMLARI — satır adları ve sırası
 * mockup `Ekranlar/Goz/goz_detayli_muayene.html` ile birebir.
 *
 * Tanım BURADA, bileşende değil: satır listesi klinik bir sözleşmedir (hangi
 * ölçüm hangi sırada sorulur) ve ekranın çizim koduna karışırsa, bir satır
 * eklemek için bileşen değiştirmek gerekir.
 *
 * `ayirt` alanı satırın hangi kayda düştüğünü söyler ve ŞEMADAKİ ayırt edici
 * kolonla aynıdır (`tur`, `yontem`, `alan`): matris bir görünüm katmanıdır,
 * yeni bir veri kuralı getirmez.
 */

/** Cihazdan gelmeyen, hekimin girdiği ölçüm: kaynak = 1 (hekim). */
const HEKIM = { kaynak: 1 };

export const GOZ_MATRISLERI: Record<string, GozMatrisTanimi> = {
  // -------------------------------------------------------------- görme ----
  gorme: {
    detay: 'gorme',
    baslik: 'Görme keskinliği',
    aciklama: 'ondalık (Snellen 20/x) · 6 m · ETDRS/Snellen eşeli',
    // MOCKUP'TA TEK SEKME: "Görme & Refraksiyon". Hekim "0,3 görüyor" ile
    //   "−2,50 miyop"u birlikte okur; ikisi aynı cümlenin iki yarısı.
    ekMatris: 'refraksiyon',
    varsayilan: { ...HEKIM, esel: 1 },
    satirlar: [
      { etiket: 'UCVA (düzeltmesiz)', alan: 'degerOndalik', ayirt: { tur: 1 },
        yanAlan: 'degerSnellen', birim: 'Snellen' },
      { etiket: 'Mevcut gözlükle',    alan: 'degerOndalik', ayirt: { tur: 2 },
        yanAlan: 'degerSnellen', birim: 'Snellen' },
      { etiket: 'Pinhole',            alan: 'degerOndalik', ayirt: { tur: 3 } },
      { etiket: 'BCVA (en iyi düzeltilmiş)', alan: 'degerOndalik', ayirt: { tur: 4 },
        yanAlan: 'degerSnellen', birim: 'Snellen',
        ipucu: 'Hastanın gerçek görme düzeyi: takip ve rapor bu değere bakar.' },
      { etiket: 'Yakın (Jaeger)',      alan: 'yakinJaeger', ayirt: { tur: 5 } },
      // Sayıyla ifade edilemeyen görme düzeyleri (parmak sayma / el hareketi /
      //   ışık hissi): ondalık alana 0 yazmak "hiç görmüyor" ile "ışık hissi
      //   var"ı aynı yapardı.
      { etiket: 'PH / EH / IH',        alan: 'degerMetin',   ayirt: { tur: 4 },
        ipucu: 'Parmak sayma · el hareketi · ışık hissi' },
    ],
    not: 'BCVA satırı takibin omurgasıdır: rapor, sürücü belgesi ve ameliyat '
       + 'kararı bu değere bakar. Pinhole düzelme gösteriyorsa kayıp optik, '
       + 'göstermiyorsa retina/optik sinir kaynaklıdır.',
  },

  // -------------------------------------------------------- refraksiyon ----
  refraksiyon: {
    detay: 'refraksiyon',
    baslik: 'Refraksiyon',
    aciklama: 'sph / cyl / aks · add · sikloplejik ayrı satır',
    varsayilan: HEKIM,
    satirlar: [
      // Otoref CİHAZDAN düşer (kaynak 3) ama hekim düzeltebilir: cihaz ölçümü
      //   onaylanana kadar ÖN VERİDİR.
      { etiket: 'Otorefraktometre', alan: 'sph', ayirt: { tur: 1 }, genislik: 62 },
      { etiket: '   · Cyl / Aks',   alan: 'cyl', ayirt: { tur: 1 }, yanAlan: 'aks', birim: 'aks' },
      { etiket: 'Subjektif refraksiyon', alan: 'sph', ayirt: { tur: 2 }, genislik: 62 },
      { etiket: '   · Cyl / Aks',   alan: 'cyl', ayirt: { tur: 2 }, yanAlan: 'aks', birim: 'aks' },
      { etiket: '   · Add (yakın)', alan: 'addYakin', ayirt: { tur: 2 }, genislik: 62 },
      { etiket: '   · Bu düzeltmeyle VA', alan: 'va', ayirt: { tur: 2 }, genislik: 62 },
      { etiket: 'Sikloplejik',      alan: 'sph', ayirt: { tur: 3 }, genislik: 62 },
      { etiket: 'Keratometri K1 / K2', alan: 'k1', ayirt: { tur: 1 }, yanAlan: 'k2', birim: 'K2' },
      { etiket: 'PD (uzak / yakın)', alan: 'pdUzak', ayirt: { tur: 2 },
        yanAlan: 'pdYakin', birim: 'yakın' },
    ],
    not: 'Otoref, subjektif ve sikloplejik AYRI SATIRLARDIR: aynı ziyarette '
       + 'üçü de ölçülür ve birbirinin yerine geçmez. Reçete subjektiften yazılır.',
  },

  // ---------------------------------------------- tonometri / pakimetri ----
  tonometri: {
    detay: 'tonometri',
    baslik: 'Göz içi basıncı ve pakimetri',
    aciklama: 'mmHg · CCT düzeltmesi · ölçüm saati (diürnal)',
    varsayilan: HEKIM,
    satirlar: [
      { etiket: 'GİB — NCT (hava)',   alan: 'gib', ayirt: { yontem: 1 }, birim: 'mmHg' },
      { etiket: 'GİB — Goldmann',     alan: 'gib', ayirt: { yontem: 2 }, birim: 'mmHg',
        ipucu: 'Altın standart: karar Goldmann değerine göre verilir.' },
      { etiket: 'Pakimetri (CCT)',    alan: 'cctUm', ayirt: { yontem: 2 }, birim: 'µm',
        ipucu: 'İnce kornea GİB\'i olduğundan düşük gösterir.' },
      { etiket: 'Düzeltilmiş GİB',    alan: 'duzeltilmisGib', ayirt: { yontem: 2 }, birim: 'mmHg' },
      { etiket: 'Hedef GİB',          alan: 'hedefGib', ayirt: { yontem: 2 }, birim: 'mmHg',
        ipucu: 'Glokomda "GİB 18" tek başına iyi ya da kötü değildir; hedefe göre okunur.' },
      { etiket: 'Son damladan (dk)',  alan: 'damlaSonrasiDk', ayirt: { yontem: 2 } },
    ],
    not: 'Yüksek (>21) ve panik (>30) bayrağı KAYDEDİLİRKEN hesaplanır; '
       + 'elle işaretlenmez - yoğun bir günde panik değerin gözden kaçmaması için.',
  },

  // --------------------------------------------------------- ön segment ----
  onSegment: {
    detay: 'onSegment',
    baslik: 'Biyomikroskopi (ön segment)',
    aciklama: 'kapaktan lense · her alan ayrı satır',
    varsayilan: HEKIM,
    satirlar: [
      { etiket: 'Kapak / kirpik', alan: 'degerMetin', ayirt: { alan: 'kapak' } },
      { etiket: 'Konjonktiva',    alan: 'degerMetin', ayirt: { alan: 'konjonktiva' } },
      { etiket: 'Kornea',         alan: 'degerMetin', ayirt: { alan: 'kornea' } },
      { etiket: 'Ön kamara',      alan: 'degerMetin', ayirt: { alan: 'on_kamara' },
        yanAlan: 'degerKod', birim: 'Van Herick' },
      { etiket: 'İris',           alan: 'degerMetin', ayirt: { alan: 'iris' } },
      { etiket: 'Pupil',          alan: 'degerMetin', ayirt: { alan: 'pupil' } },
      { etiket: 'Lens',           alan: 'degerMetin', ayirt: { alan: 'lens' },
        yanAlan: 'degerKod', birim: 'LOCS III' },
      { etiket: 'Gözyaşı (BUT / Schirmer)', alan: 'degerSayi', ayirt: { alan: 'gozyasi' },
        yanAlan: 'degerMetin', birim: 'not' },
    ],
    not: 'Alan bazlı satır: yeni bir bulgu alanı eklemek şema değişikliği '
       + 'gerektirmesin diye kolon değil SATIR açılır.',
  },

  // -------------------------------------------------------------- fundus ----
  // Fundus göz başına TEK kayıttır: bütün satırlar aynı kaydın ayrı alanları.
  fundus: {
    detay: 'fundus',
    baslik: 'Fundus',
    aciklama: 'disk · makula · damarlar · periferi · evreler kodlu',
    varsayilan: { ...HEKIM, yontem: 1 },
    satirlar: [
      { etiket: 'Optik disk',        alan: 'diskMetin' },
      { etiket: 'C/D (yatay / dikey)', alan: 'cdYatay', yanAlan: 'cdDikey', birim: 'dikey',
        ipucu: 'Glokom takibinin temel bulgusu; dikey oran daha anlamlıdır.' },
      { etiket: 'ISNT ihlali',       alan: 'isntIhlal',
        kodlar: { '0': 'Yok', '1': 'Var' } },
      { etiket: 'Disk kanaması',     alan: 'diskKanama',
        kodlar: { '0': 'Yok', '1': 'Var' } },
      { etiket: 'Makula',            alan: 'makulaMetin' },
      { etiket: 'Damarlar',          alan: 'damarMetin' },
      { etiket: 'Periferi',          alan: 'periferiMetin' },
      { etiket: 'Vitreus',           alan: 'vitreus' },
      { etiket: 'DR evresi (ETDRS)', alan: 'drEvre',
        kodlar: { '0': 'R0 yok', '1': 'R1 hafif', '2': 'R2 orta', '3': 'R3 ağır', '4': 'R4 PDR' } },
      { etiket: 'DMÖ',               alan: 'dmo',
        kodlar: { '0': 'Yok', '1': 'Merkez dışı', '2': 'Merkezi tutan' } },
      { etiket: 'AMD evresi',        alan: 'amdEvre',
        kodlar: { '0': 'Yok', '1': 'Erken kuru', '2': 'Orta kuru', '3': 'İleri kuru (GA)',
                  '4': 'Yaş (neovasküler)' } },
    ],
    not: 'DR ve AMD evresi KODLUDUR: tarama programının, sevkin ve anti-VEGF '
       + 'endikasyonunun ortak dili - serbest metinden toplanamaz.',
  },
};
