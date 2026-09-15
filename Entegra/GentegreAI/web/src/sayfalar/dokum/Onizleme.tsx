import type { DokumKolonMeta, DokumTanimi, ListeYaniti, OzetYaniti } from '../../api/sozlesme';
import { KURAL_ETIKET, kuralAraligi, parametreAlanlari } from './ortak';
import { CubukGrafik, ListeSonucu, OzetGostergeler, OzetSonucu, ozetMi } from './SonucTablosu';

/**
 * ÖNİZLEME (mockup "Önizleme" sekmesi): parametre şeridi + Çalıştır + sonuç.
 * Sonuç bileşeni baskıyla ortak (SonucTablosu).
 */
export function Onizleme({ tanim, kolonlar, parametreler, setParametreler, yanit, calisiyor, onCalistir,
                           sayfa, setSayfa }: {
  tanim: DokumTanimi; kolonlar: DokumKolonMeta[];
  parametreler: Record<string, unknown>; setParametreler(p: Record<string, unknown>): void;
  yanit: ListeYaniti | OzetYaniti | null; calisiyor: boolean; onCalistir(): void;
  sayfa: number; setSayfa(s: number): void;
}) {
  const alanlar = parametreAlanlari(tanim);
  const listeYaniti = yanit && !ozetMi(yanit) ? yanit : null;
  const sayfaSayisi = listeYaniti ? Math.max(1, Math.ceil(listeYaniti.toplamKayit / 100)) : 1;

  return (
    <>
      <div className="dk-serit">
        {alanlar.map(a => {
          const kol = kolonlar.find(k => k.ad === a.alan);
          const v = parametreler[a.alan];
          if (a.op === 'arasinda') {
            const d = Array.isArray(v) ? v : (kuralAraligi(a.kural) ?? ['', '']);
            return (
              <label key={a.alan} className="dk-param">
                <span>{a.ad}{a.kural && <i className="sonuk"> · {KURAL_ETIKET[a.kural]}</i>}</span>
                <span className="dk-ikiz">
                  <input type={kol?.tip === 'tarih' ? 'date' : 'text'} value={String(d[0] ?? '')}
                         onChange={e => setParametreler({ ...parametreler, [a.alan]: [e.target.value, d[1] ?? ''] })} />
                  <span className="sonuk">–</span>
                  <input type={kol?.tip === 'tarih' ? 'date' : 'text'} value={String(d[1] ?? '')}
                         onChange={e => setParametreler({ ...parametreler, [a.alan]: [d[0] ?? '', e.target.value] })} />
                </span>
              </label>
            );
          }
          return (
            <label key={a.alan} className="dk-param">
              <span>{a.ad}</span>
              <input value={Array.isArray(v) ? v.join(', ') : String(v ?? '')} placeholder={a.op === 'icinde' ? 'A, B, C' : ''}
                     onChange={e => setParametreler({ ...parametreler, [a.alan]:
                       a.op === 'icinde' ? e.target.value.split(',').map(s => s.trim()).filter(Boolean) : e.target.value })} />
            </label>
          );
        })}
        <button className="d bir" onClick={onCalistir} disabled={calisiyor}>▶ {calisiyor ? 'Çalışıyor…' : 'Çalıştır'}</button>
        {yanit && (
          <span className="rozet ok">
            {ozetMi(yanit) ? `${yanit.satirlar.length} grup` : `${yanit.toplamKayit.toLocaleString('tr-TR')} kayıt`} · {yanit.sureMs} ms
          </span>
        )}
        {listeYaniti && sayfaSayisi > 1 && (
          <span className="dk-sayfa">
            <button className="d mini" disabled={sayfa <= 1} onClick={() => setSayfa(sayfa - 1)}>◀</button>
            {sayfa} / {sayfaSayisi}
            <button className="d mini" disabled={sayfa >= sayfaSayisi} onClick={() => setSayfa(sayfa + 1)}>▶</button>
          </span>
        )}
      </div>

      {!yanit && (
        <div className="kagrup"><div className="bos">
          {alanlar.length ? 'Parametreleri girip ' : ''}<b>Çalıştır</b>'a basın — sonuç burada, aynı veri Baskı sekmesinde kâğıda çizilir.
        </div></div>
      )}

      {yanit && (
        <>
          <OzetGostergeler yanit={yanit} tanim={tanim} kolonlar={kolonlar} />
          <div className="kagrup">
            <h6>{ozetMi(yanit) ? 'Çapraz Tablo' : 'Kayıtlar'}
              <span className="sonuk">
                {ozetMi(yanit) && yanit.kiyasAraligi ? `kıyas: ${yanit.kiyasAraligi}` : 'sunucudan gelen aynı veri'}
              </span>
            </h6>
            <div className="dk-kaydir">
              {ozetMi(yanit)
                ? <OzetSonucu yanit={yanit} tanim={tanim} kolonlar={kolonlar} />
                : <ListeSonucu yanit={yanit} tanim={tanim} kolonlar={kolonlar} />}
            </div>
          </div>
          {ozetMi(yanit) && (tanim.boyut?.satir.length ?? 0) > 0 && (
            <div className="kagrup">
              <h6>Satır boyutuna göre <span className="sonuk">ilk ölçü · en büyük 12</span></h6>
              <CubukGrafik yanit={yanit} tanim={tanim} kolonlar={kolonlar} />
            </div>
          )}
        </>
      )}
    </>
  );
}
