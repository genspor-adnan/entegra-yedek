import { useState } from 'react';
import { GenGrid } from './GenGrid';
import { GenForm } from './GenForm';

/**
 * NUMARALAMA (152) - Genel Ayarlar › Numaralama.
 *
 * Dort grid: solda satis ve alis belgeleri, sagda tahsilat ve odeme turleri.
 * Dordu de ayni tabloyu (numara_sablonu) yazar; hangi turleri listeledigini
 * SUNUCUDAKI kaynak tanimi belirler - ekran filtre kurmaz.
 *
 * Bir satir "su TARIHTEN ITIBAREN, su ON EK ile, su NUMARADAN baslayarak"
 * demektir. Ayni tur icin birden fazla satir olabilir: belge kesilirken
 * belgenin TARIHINE uyan en yeni satir gecerlidir, eski belgeler eski
 * numaralamayi korur.
 */
const GRIDLER = [
  { kaynak: 'numara-satis',    baslik: 'Satış Belgeleri',  sutun: 'sol' },
  { kaynak: 'numara-alis',     baslik: 'Alış Belgeleri',   sutun: 'sol' },
  { kaynak: 'numara-tahsilat', baslik: 'Tahsilat Türleri', sutun: 'sag' },
  { kaynak: 'numara-odeme',    baslik: 'Ödeme Türleri',    sutun: 'sag' },
] as const;

type Kaynak = typeof GRIDLER[number]['kaynak'];

export function NumaralamaSekmesi() {
  /** Acik kart: hangi grid ve hangi kayit ("yeni" = ekleme). */
  const [kart, setKart] = useState<{ kaynak: Kaynak; id: number | 'yeni' } | null>(null);
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
        onSatirAc={satir => setKart({ kaynak: g.kaynak, id: Number(satir.id) })}
      />
    </div>
  );

  return (
    <>
      <div className="numaralama-izgara">
        <div>{GRIDLER.filter(g => g.sutun === 'sol').map(grid)}</div>
        <div>{GRIDLER.filter(g => g.sutun === 'sag').map(grid)}</div>
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
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
