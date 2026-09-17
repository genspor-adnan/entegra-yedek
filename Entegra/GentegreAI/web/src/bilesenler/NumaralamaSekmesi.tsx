import { useState } from 'react';
import { GenGrid } from './GenGrid';
import { GenForm } from './GenForm';
import { modUyar, URUN_GENOTIP } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * NUMARALAMA (152) - Genel Ayarlar › Numaralama.
 *
 * Bes grid: solda Hasta Belgeleri (yalniz HBYS), satis ve alis belgeleri;
 * sagda tahsilat ve odeme turleri. Hepsi ayni tabloyu (numara_sablonu)
 * yazar; hangi turleri listeledigini SUNUCUDAKI kaynak tanimi belirler -
 * ekran filtre kurmaz. Ekranin kurdugu tek suzgec KURULUM MODU.
 *
 * Bir satir "su TARIHTEN ITIBAREN, su ON EK ile, su NUMARADAN baslayarak"
 * demektir. Ayni tur icin birden fazla satir olabilir: belge kesilirken
 * belgenin TARIHINE uyan en yeni satir gecerlidir, eski belgeler eski
 * numaralamayi korur.
 */
const GRIDLER = [
  // HASTA BELGELERI EN USTTE SOLDA ve YALNIZ HBYS'DE (634-636, kullanici).
  //
  //   TEK GRID, yedi tur (dosya · protokol · muayene · recete · lab ·
  //   radyoloji · e-Nabiz): her numara icin ayri grid acmak ayni tablonun
  //   yedi kopyasi olurdu. Sira SUNUCUDAN gelir
  //   (`v_numara_turu_kimlik.sira`) - hastanin izledigi yol.
  //
  //   `urunModu` ERP kurulumunda gridi HIC cizmez: hastanesi olmayan bir
  //   kurumda muayene/recete/e-Nabiz numarasi ayarlamak anlamsiz, ustelik
  //   ilk sirada duruyor - her acilista bos yere goze carpardi. Oteki dort
  //   grid iki kurulumda da gecerli (belge, tahsilat, odeme numaralari).
  { kaynak: 'numara-hasta-belge', baslik: 'Hasta Belgeleri',
    sutun: 'sol', urunModu: URUN_GENOTIP },
  { kaynak: 'numara-satis',    baslik: 'Satış Belgeleri',  sutun: 'sol' },
  { kaynak: 'numara-alis',     baslik: 'Alış Belgeleri',   sutun: 'sol' },
  { kaynak: 'numara-tahsilat', baslik: 'Tahsilat Türleri', sutun: 'sag' },
  { kaynak: 'numara-odeme',    baslik: 'Ödeme Türleri',    sutun: 'sag' },
  // TEDARIK BELGELERI (731): talep · teklif · mal kabul · eczane hazirlama ·
  //   ilac imha · demirbas · kalibrasyon · is emri. SAGDA ve EN ALTTA:
  //   gunluk ayar degil, kurulusta bir kez yapilan is - satis/alis
  //   numaralarinin onune koymak sik kullanilani asagi iterdi.
  //
  //   `urunModu` YOK, yani ERP kurulumunda da cizilir: satinalma, demirbas ve
  //   kalibrasyon hastaneye ozgu degil. Eczane satirlarini ERP'de ayri ayri
  //   gizlemek yerine hepsini birakiyoruz - numarasi ayarlanmayan tur zaten
  //   bos kalir ve kimseyi zorlamaz.
  { kaynak: 'numara-tedarik',  baslik: 'Tedarik Belgeleri', sutun: 'sag' },
  // IK TALEPLERI (767): avans · masraf beyani · belge talebi. AYRI GRUP,
  //   tedarik/satis gridlerine karistirilmadi: bunlar belge degil personel
  //   talebi ve numarayi kesen de baska bir modul. `urunModu` YOK - avans ve
  //   masraf beyani ERP kurulumunda da var.
  { kaynak: 'numara-ik',       baslik: 'İK Talepleri',      sutun: 'sag' },
] as const;

type Kaynak = typeof GRIDLER[number]['kaynak'];

/*
 * `NumaraGridi` KALDIRILDI (634): Kayit Kabul Ayarlari'ndaki Dosya No ve
 * Protokol No gridleri Genel Ayarlar › Numaralama › Hasta Belgeleri'ne
 * tasindi (kullanici). Ayni tabloyu iki ekrandan duzenlemek "hangisi
 * gecerli" sorusunu doguruyordu; tek paylasilan bilesene de gerek kalmadi.
 */

export function NumaralamaSekmesi() {
  const { kullanici } = useOturum();
  /**
   * Acik kart: hangi grid ve hangi kayit ("yeni" = ekleme).
   *
   * `tur` YALNIZ Hasta Belgeleri gridinde dolu gelir (636): orada ayari
   * OLMAYAN tur de bir satir olarak cizilir (`id = 0`) ve ona tiklamak
   * "yeni" kartini o tur secili acmali - kullanici turu bir daha secmesin.
   */
  const [kart, setKart] =
    useState<{ kaynak: Kaynak; id: number | 'yeni'; tur?: number } | null>(null);
  /** Kayit sonrasi ilgili gridi tazelemek icin sayac. */
  const [yenile, setYenile] = useState(0);

  const grid = (g: typeof GRIDLER[number]) => (
    <div className="kagrup" key={g.kaynak}>
      {/* Baslik ve "Yeni" ayni satirda: dort grid var, her birine ayri arac
          cubugu koymak ekrani gurultuye bogardi. */}
      <div className="numaralama-bas">
        <h6>{g.baslik}</h6>
        <button className="d bir mini"
                onClick={() => setKart({ kaynak: g.kaynak, id: 'yeni' })}>
          ＋ Yeni
        </button>
      </div>
      <GenGrid
        key={`${g.kaynak}-${yenile}`}
        kaynak={g.kaynak}
        gomulu
        seritGizli
        boyut={25}
        onSatirAc={satir => setKart(
          // AYARSIZ TUR SATIRI (id 0): kayit yok, "yeni" acilir ve turu
          //   satirdan tasinir.
          Number(satir.id) > 0
            ? { kaynak: g.kaynak, id: Number(satir.id) }
            : { kaynak: g.kaynak, id: 'yeni', tur: Number(satir.tur ?? 0) })}
      />
    </div>
  );

  // KURULUM MODU SUZGECI: karma kurulumda (mod 3) her iki urunun gridleri
  //   cizilir - `modUyar` bunu zaten biliyor, burada tekrar yazilmaz.
  const gorunen = GRIDLER.filter(g =>
    modUyar((g as { urunModu?: number }).urunModu, kullanici?.urunModu));

  return (
    <>
      <div className="numaralama-izgara">
        <div>{gorunen.filter(g => g.sutun === 'sol').map(grid)}</div>
        <div>{gorunen.filter(g => g.sutun === 'sag').map(grid)}</div>
      </div>

      <div className="not" style={{ marginTop: 8 }}>
        Bir satır <b>“şu tarihten itibaren”</b> demektir: belge kesilirken belgenin
        tarihine uyan en yeni satır geçerli olur, daha eski belgeler önceki
        numaralamayı korur. <b>Başlama No</b> hem başlangıç değerini hem hane
        sayısını verir — <b>00000100</b> yazarsanız ilk numara <b>100</b>’dür ve
        8 hane yazılır. <b>Ön Ek</b> numaranın başına eklenir (örn. <b>A-</b> →
        <b> A-00000100</b>). Şube boş bırakılırsa tüm şubelerde geçerlidir.
      </div>

      {kart && (
        <GenForm
          kaynak={kart.kaynak}
          id={kart.id}
          baslik="Numaralama"
          // AYARSIZ TUR SATIRINDAN gelindiyse tur SECILI acilir (636).
          yeniKayitVarsayilanlari={kart.tur ? { tur: kart.tur } : undefined}
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
