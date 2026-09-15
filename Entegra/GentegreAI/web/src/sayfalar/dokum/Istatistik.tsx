import type { DokumKolonMeta, DokumOlcu, DokumTanimi } from '../../api/sozlesme';
import { FN_ETIKET, KESME_ETIKET, KIYAS_ETIKET, boyutEtiketi, olcuEtiketi } from './ortak';

/**
 * İSTATİSTİK (mockup "İstatistik" sekmesi): satır boyutları (1-3), sütun
 * boyutu (çapraz tablo), ölçüler (fn + alan), kıyas dönemi, gizlilik eşiği.
 *
 * Boyut = kataloğun GRUPLANABİLİR işaretli alanı; tarih alanı gün/hafta/ay/
 * çeyrek/yıl kesmesi alır. Sayı/para alanı ölçüdür, boyut değil. Hasta
 * kimliği boyut listesinde hiç yok (sunucu kalıbı).
 */
export function Istatistik({ tanim, setTanim, kolonlar, fnler, kesmeler }: {
  tanim: DokumTanimi; setTanim(t: DokumTanimi): void; kolonlar: DokumKolonMeta[];
  fnler: string[]; kesmeler: string[];
}) {
  const boyut = tanim.boyut ?? { satir: [], sutun: null };
  const olcu = tanim.olcu ?? [];
  const boyutlar = kolonlar.filter(k => k.gruplanabilir);
  const olculebilir = kolonlar.filter(k => k.olculebilir);
  const tekilAlanlar = kolonlar.filter(k => k.ad.endsWith('Id') || k.gruplanabilir);

  const boyutYaz = (satir: string[], sutun: string | null) =>
    setTanim({ ...tanim, boyut: { satir: satir.filter(Boolean), sutun: sutun || null } });

  const satirDegistir = (i: number, v: string) => {
    const s = [...boyut.satir];
    if (v) s[i] = v; else s.splice(i, 1);
    boyutYaz(s, boyut.sutun ?? null);
  };
  const kesmeDegistir = (i: number | 'sutun', kesme: string) => {
    const mevcut = i === 'sutun' ? (boyut.sutun ?? '') : boyut.satir[i];
    const alan = mevcut.split(':')[0];
    const yeni = kesme ? `${alan}:${kesme}` : alan;
    if (i === 'sutun') boyutYaz(boyut.satir, yeni);
    else { const s = [...boyut.satir]; s[i] = yeni; boyutYaz(s, boyut.sutun ?? null); }
  };
  const olcuYaz = (o: DokumOlcu[]) => setTanim({ ...tanim, olcu: o });
  const olcuDegistir = (i: number, y: Partial<DokumOlcu>) => olcuYaz(olcu.map((o, j) => (j === i ? { ...o, ...y } : o)));
  const olcuEkle = () => olcuYaz([...olcu, { fn: 'toplam', alan: olculebilir[0]?.ad ?? null }]);

  const kesmeSecici = (deger: string, onKesme: (k: string) => void) => {
    const alan = deger.split(':')[0];
    const kesme = deger.includes(':') ? deger.split(':')[1] : '';
    const kol = kolonlar.find(k => k.ad === alan);
    if (kol?.tip !== 'tarih') return null;
    return (
      <select value={kesme} onChange={e => onKesme(e.target.value)} title="Tarih kesmesi">
        {['', ...kesmeler].map(k => <option key={k} value={k}>{KESME_ETIKET[k] ?? k}</option>)}
      </select>
    );
  };

  return (
    <div className="dk-tasarla">
      <div>
        <div className="kagrup">
          <h6>Boyutlar <span className="sonuk">satır × sütun</span></h6>
          <div className="dk-kimlik">
            {[0, 1, 2].map(i => (
              <label key={i}>Satır boyutu {i + 1}
                <span className="dk-ikiz">
                  <select value={(boyut.satir[i] ?? '').split(':')[0]} onChange={e => satirDegistir(i, e.target.value)}
                          disabled={i > boyut.satir.length}>
                    <option value="">—</option>
                    {boyutlar.map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                  </select>
                  {boyut.satir[i] && kesmeSecici(boyut.satir[i], k => kesmeDegistir(i, k))}
                </span>
              </label>
            ))}
            <label>Sütun boyutu <span className="sonuk">(çapraz tablo)</span>
              <span className="dk-ikiz">
                <select value={(boyut.sutun ?? '').split(':')[0]} onChange={e => boyutYaz(boyut.satir, e.target.value ? `${e.target.value}${kolonlar.find(k => k.ad === e.target.value)?.tip === 'tarih' ? ':ay' : ''}` : null)}>
                  <option value="">—</option>
                  {boyutlar.map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                </select>
                {boyut.sutun && kesmeSecici(boyut.sutun, k => kesmeDegistir('sutun', k))}
              </span>
            </label>
            <label>Kıyas dönemi
              <select value={tanim.kiyas} onChange={e => setTanim({ ...tanim, kiyas: e.target.value as DokumTanimi['kiyas'] })}>
                {Object.entries(KIYAS_ETIKET).map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
              </select>
            </label>
            <label>Gizlilik eşiği <span className="sonuk">(adet &lt; n gruplar düşer)</span>
              <input type="number" min={0} max={1000} value={tanim.esik}
                     onChange={e => setTanim({ ...tanim, esik: Math.max(0, Number(e.target.value) || 0) })} />
            </label>
          </div>
          <div className="pano-not">
            Boyut = kataloğun <b>gruplanabilir</b> alanı (kod · metin · tarih; kimlik kolonları hariç).
            Tarih alanı gün / hafta / ay / çeyrek / yıl kesmesi alır. Kıyas, ilk <i>arasında</i> tarih
            koşulunu kaydırarak ikinci bir sorgu çalıştırır; tarih koşulu yoksa kıyas boş döner.
          </div>
        </div>

        <div className="kagrup">
          <h6>Ölçüler <span className="sonuk">her hücrede hesaplanan · ilk ölçü çapraz tablonun hücresidir</span>
            <button className="d sag" onClick={olcuEkle}>＋ Ölçü ekle</button>
          </h6>
          <table className="detay-tablo dk-kosullar">
            <thead><tr>
              <th style={{ width: 30 }}></th><th style={{ width: 150 }}>Fonksiyon</th><th style={{ width: 200 }}>Alan</th>
              <th style={{ width: 200 }}>Bölen (oran)</th><th>Başlık</th><th style={{ width: 34 }}></th>
            </tr></thead>
            <tbody>
              {olcu.map((o, i) => (
                <tr key={i}>
                  <td className="orta"><span className="rozet mavi">{i + 1}</span></td>
                  <td>
                    <select value={o.fn} onChange={e => olcuDegistir(i, { fn: e.target.value, alan: e.target.value === 'adet' ? null : (o.alan ?? olculebilir[0]?.ad ?? null) })}>
                      {fnler.map(f => <option key={f} value={f}>{FN_ETIKET[f] ?? f}</option>)}
                    </select>
                  </td>
                  <td>
                    {o.fn !== 'adet' && (
                      <select value={o.alan ?? ''} onChange={e => olcuDegistir(i, { alan: e.target.value })}>
                        <option value="">—</option>
                        {(o.fn === 'tekil' ? tekilAlanlar : olculebilir).map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                      </select>
                    )}
                  </td>
                  <td>
                    {o.fn === 'oran' && (
                      <select value={o.bolen ?? ''} onChange={e => olcuDegistir(i, { bolen: e.target.value })}>
                        <option value="">—</option>
                        {olculebilir.map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                      </select>
                    )}
                  </td>
                  <td><input value={o.baslik ?? ''} placeholder={olcuEtiketi(o, kolonlar)}
                             onChange={e => olcuDegistir(i, { baslik: e.target.value || null })} /></td>
                  <td className="orta"><button className="d mini" onClick={() => olcuYaz(olcu.filter((_, j) => j !== i))}>✕</button></td>
                </tr>
              ))}
              {olcu.length === 0 && <tr><td colSpan={6} className="bos">Ölçü yok — en az bir ölçü seçin.</td></tr>}
            </tbody>
          </table>
          <div className="pano-not">
            Fonksiyonlar: <b>adet · tekil sayı · toplam · ortalama · medyan · en az · en çok · p90 · oran</b>.
            Hepsi sunucuda, gruplama katmanında hesaplanır; istemci hiçbir sayıyı yeniden toplamaz
            (çapraz tabloda satır toplamı yalnız adet/Σ için).
          </div>
        </div>
      </div>

      <div className="dk-yan">
        <div className="kagrup">
          <h6>Özet</h6>
          <div className="dk-sat"><span>Satır</span><span>{boyut.satir.map(b => boyutEtiketi(b, kolonlar)).join(' › ') || '—'}</span></div>
          <div className="dk-sat"><span>Sütun</span><span>{boyut.sutun ? boyutEtiketi(boyut.sutun, kolonlar) : '—'}</span></div>
          <div className="dk-sat"><span>Ölçü</span><span>{olcu.map(o => olcuEtiketi(o, kolonlar)).join(' · ') || '—'}</span></div>
          <div className="dk-sat"><span>Kıyas</span><span>{KIYAS_ETIKET[tanim.kiyas]}</span></div>
          <div className="dk-sat"><span>Eşik</span><span>{tanim.esik > 0 ? `< ${tanim.esik} gizli` : 'kapalı'}</span></div>
        </div>
        <div className="kagrup">
          <h6>Gizlilik</h6>
          <div className="dk-sat"><span>Hasta kimliği</span><span className="rozet hata">istatistikte yok</span></div>
          <div className="pano-not">
            İstatistik <b>toplam</b> gösterir, kişi göstermez; hücreye çift tık kayıt listesine iner
            (kayıt yetkisi olana). Eşik altı gruplar sunucuda hiç dönmez.
          </div>
        </div>
      </div>
    </div>
  );
}
