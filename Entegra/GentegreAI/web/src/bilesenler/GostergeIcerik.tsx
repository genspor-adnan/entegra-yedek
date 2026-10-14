import { useNavigate } from 'react-router-dom';
import { c } from '../dil/ceviri';
import { para, paraYaz } from './bicim';
import type { GostergeBlok, GostergeKutu } from '../api/uclar/gosterge';

const sayi = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 0 });

/** Blok ikonları (Ana Sayfa paneliyle aynı - 512). */
export const BLOK_IKON: Record<string, string> = {
  poliklinik: '🩺', kurum: '🏢', birim: '🧪', enabiz: '📤',
  hekim: '👨‍⚕️', dikkat: '⚠️', bolum: '🔬', labBolum: '🔬', modalite: '🖥',
};

export const gostergeDegeri = (k: GostergeKutu) =>
  k.bicim === 'para' ? paraYaz(Number(k.deger)) : sayi.format(Number(k.deger));

/**
 * GÖSTERGE İÇERİĞİ: kutular + liste blokları. Ana Sayfa profil paneli (508) ve
 * gösterge panelleri (1103) aynı çizimi kullanır - tanım sunucudan, burada yalnız çizim.
 */
export function GostergeIcerik({ kutular, bloklar }: { kutular: GostergeKutu[]; bloklar: GostergeBlok[] }) {
  const git = useNavigate();
  return (
    <>
      <div className="panel-kutular profil">
        {kutular.map(k => (
          <button key={k.kod} type="button" className="kpi panel-kpi"
                  onClick={() => k.rota && git(k.rota)} title={k.rota ? c('Listeyi aç') : undefined}>
            <div className="k">{c(k.baslik)}</div>
            <div className={`v ${k.vurgu ?? ''}`}>{gostergeDegeri(k)}</div>
            <div className="s">{k.alt}</div>
          </button>
        ))}
      </div>
      <div className="panel-sutunlar">
        {bloklar.map(b => (
          <div className="kagrup" key={b.kod}>
            <h6>
              {BLOK_IKON[b.kod] && <span className="blok-ikon">{BLOK_IKON[b.kod]}</span>}
              {c(b.baslik)}{b.ipucu && <span className="sonuk"> · {c(b.ipucu)}</span>}
            </h6>
            <table className="detay-tablo">
              <thead><tr>{b.kolonlar.map((k, i) => (
                <th key={k} className={b.bicimler?.[i] === 'metin' ? '' : 'hiza-sag'}>{c(k)}</th>
              ))}</tr></thead>
              <tbody>
                {b.satirlar.map((sat, si) => (
                  <tr key={si}>
                    {sat.map((h, hi) => (
                      <td key={hi} className={b.bicimler?.[hi] === 'metin' ? '' : 'hiza-sag'}>
                        {b.bicimler?.[hi] === 'para' ? para.format(Number(h))
                         : b.bicimler?.[hi] === 'sayi' ? sayi.format(Number(h)) : h}
                      </td>
                    ))}
                  </tr>
                ))}
                {b.satirlar.length === 0 && <tr><td className="bos" colSpan={b.kolonlar.length}>{c('Kayıt yok.')}</td></tr>}
              </tbody>
            </table>
          </div>
        ))}
      </div>
    </>
  );
}
