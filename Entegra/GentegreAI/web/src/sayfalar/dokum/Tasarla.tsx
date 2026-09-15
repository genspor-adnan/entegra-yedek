import type { DokumKolonMeta, DokumTanimi, Kosul, KosulOp } from '../../api/sozlesme';
import {
  GORUNURLUK_ETIKET, KURAL_ETIKET, degerSayisi, listeyeCevir, operatorler, tanimCumlesi,
  yapraklar, yapraklariYaz,
} from './ortak';

/**
 * TASARLA (mockup "Tasarla" sekmesi): koşullar (alan / operatör / değer /
 * çalıştırırken sor), kolonlar (sıra + Σ), gruplama-sıralama, kimlik
 * (ad · açıklama · görünürlük). Sağda okunabilir tanım cümlesi.
 *
 * Alan listesi SUNUCUDAN (görünür kolonlar): yetkin olmayan alan burada hiç
 * görünmez, seçilemez. Operatörler alanın tipinden.
 */
export function Tasarla({ tanim, setTanim, kolonlar, kaynakAdi, ad, setAd, aciklama, setAciklama,
                          gorunurluk, setGorunurluk, kurumGeneliAcabilir, kurallar }: {
  tanim: DokumTanimi; setTanim(t: DokumTanimi): void; kolonlar: DokumKolonMeta[]; kaynakAdi: string;
  ad: string; setAd(v: string): void; aciklama: string; setAciklama(v: string): void;
  gorunurluk: number; setGorunurluk(v: number): void; kurumGeneliAcabilir: boolean;
  kurallar: string[];
}) {
  const kosullar = yapraklar(tanim);
  const yaz = (k: Kosul[]) => setTanim(yapraklariYaz(tanim, k));
  const filtrelenebilir = kolonlar.filter(k => k.filtrelenebilir);
  const parametreler = tanim.parametreler ?? {};

  const kosulEkle = () => {
    const ilk = filtrelenebilir.find(k => k.tip === 'tarih') ?? filtrelenebilir[0];
    if (!ilk) return;
    const op = operatorler(ilk.tip)[0].op;
    yaz([...kosullar, { alan: ilk.ad, op, deger: op === 'arasinda' ? ['', ''] : '' }]);
  };
  const kosulDegistir = (i: number, y: Partial<Kosul>) => {
    const yeni = kosullar.map((k, j) => (j === i ? { ...k, ...y } : k));
    yaz(yeni);
  };
  const kosulSil = (i: number) => {
    const k = kosullar[i];
    const p = { ...parametreler }; if (k.alan) delete p[k.alan];
    setTanim({ ...yapraklariYaz(tanim, kosullar.filter((_, j) => j !== i)), parametreler: p });
  };
  const parametreAc = (alan: string, ac: boolean, tip: string) => {
    const p = { ...parametreler };
    if (ac) p[alan] = { ad: kolonlar.find(k => k.ad === alan)?.baslik ?? alan, kural: tip === 'tarih' ? 'buAy' : '' };
    else delete p[alan];
    setTanim({ ...tanim, parametreler: p });
  };
  const kuralDegistir = (alan: string, kural: string) =>
    setTanim({ ...tanim, parametreler: { ...parametreler, [alan]: { ...parametreler[alan], kural } } });

  // ---------------------------------------------------------------- kolon
  const secili = tanim.kolonlar ?? [];
  const kolonEkle = (ad: string) => setTanim({ ...tanim, kolonlar: [...secili, ad] });
  const kolonCikar = (ad: string) => setTanim({
    ...tanim, kolonlar: secili.filter(x => x !== ad),
    toplam: (tanim.toplam ?? []).filter(x => x !== ad),
    grup: (tanim.grup ?? []).filter(x => x !== ad),
  });
  const kolonKaydir = (i: number, yon: -1 | 1) => {
    const j = i + yon; if (j < 0 || j >= secili.length) return;
    const y = [...secili]; [y[i], y[j]] = [y[j], y[i]];
    setTanim({ ...tanim, kolonlar: y });
  };
  const toplamDegistir = (ad: string) => {
    const t = tanim.toplam ?? [];
    setTanim({ ...tanim, toplam: t.includes(ad) ? t.filter(x => x !== ad) : [...t, ad] });
  };
  const grupDegistir = (i: number, ad: string) => {
    const g = [...(tanim.grup ?? [])];
    if (ad) g[i] = ad; else g.splice(i, 1);
    setTanim({ ...tanim, grup: g.filter(Boolean).slice(0, 2) });
  };
  const siraDegistir = (alan: string, yon: 'asc' | 'desc') =>
    setTanim({ ...tanim, sirala: alan ? [{ alan, yon }] : [] });

  const eklenebilir = kolonlar.filter(k => !secili.includes(k.ad));
  const gruplanabilir = kolonlar.filter(k => k.gruplanabilir && secili.includes(k.ad));

  return (
    <div className="dk-tasarla">
      <div>
        <div className="kagrup">
          <h6>Kimlik</h6>
          <div className="dk-kimlik">
            <label>Döküm adı<input value={ad} onChange={e => setAd(e.target.value)} placeholder="ör. Kurum bazlı hekim cirosu" /></label>
            <label>Açıklama<input value={aciklama} onChange={e => setAciklama(e.target.value)} /></label>
            <label>Çıktı biçimi
              <select value={tanim.cikti} onChange={e => setTanim({ ...tanim, cikti: e.target.value as 'liste' | 'ozet' })}>
                <option value="liste">Liste (satırlar, gruplu ara toplam)</option>
                <option value="ozet">İstatistik (boyut × ölçü, çapraz tablo)</option>
              </select>
            </label>
            <label>Görünürlük
              <select value={gorunurluk} onChange={e => setGorunurluk(Number(e.target.value))}>
                {[0, 1, 2].map(g => (
                  <option key={g} value={g} disabled={g === 2 && !kurumGeneliAcabilir}>{GORUNURLUK_ETIKET[g]}</option>
                ))}
              </select>
            </label>
          </div>
        </div>

        <div className="kagrup">
          <h6>Koşullar <span className="sonuk">hepsi sağlanmalı (VE)</span>
            <button className="d sag" onClick={kosulEkle}>＋ Koşul ekle</button>
          </h6>
          <table className="detay-tablo dk-kosullar">
            <thead><tr>
              <th style={{ width: 30 }}></th><th style={{ width: 190 }}>Alan</th><th style={{ width: 150 }}>Operatör</th>
              <th>Değer</th><th style={{ width: 230 }}>Çalıştırırken sor</th><th style={{ width: 34 }}></th>
            </tr></thead>
            <tbody>
              {kosullar.map((k, i) => {
                const kol = kolonlar.find(x => x.ad === k.alan);
                const tip = kol?.tip ?? 'metin';
                const ops = operatorler(tip);
                const parametre = !!(k.alan && parametreler[k.alan]);
                return (
                  <tr key={i}>
                    <td className="orta"><span className="rozet mavi">{i + 1}</span></td>
                    <td>
                      <select value={k.alan ?? ''} onChange={e => {
                        const yeniKol = kolonlar.find(x => x.ad === e.target.value);
                        const op = operatorler(yeniKol?.tip ?? 'metin')[0].op;
                        kosulDegistir(i, { alan: e.target.value, op, deger: op === 'arasinda' ? ['', ''] : '' });
                      }}>
                        {filtrelenebilir.map(x => <option key={x.ad} value={x.ad}>{x.baslik}</option>)}
                      </select>
                    </td>
                    <td>
                      <select value={k.op} onChange={e => {
                        const op = e.target.value as KosulOp;
                        kosulDegistir(i, { op, deger: op === 'arasinda' ? ['', ''] : degerSayisi(op) === -1 ? [] : '' });
                      }}>
                        {ops.map(o => <option key={o.op} value={o.op}>{o.ad}</option>)}
                      </select>
                    </td>
                    <td>
                      <DegerGirisi kosul={k} kolon={kol} parametre={parametre}
                                   onDeger={d => kosulDegistir(i, { deger: d })} />
                    </td>
                    <td>
                      <label className="dk-onay">
                        <input type="checkbox" checked={parametre} disabled={!k.alan || degerSayisi(k.op) === 0}
                               onChange={e => parametreAc(k.alan!, e.target.checked, tip)} />
                        {parametre ? (
                          <>
                            <input className="dk-param-ad" value={parametreler[k.alan!].ad}
                                   onChange={e => setTanim({ ...tanim, parametreler: { ...parametreler, [k.alan!]: { ...parametreler[k.alan!], ad: e.target.value } } })} />
                            {tip === 'tarih' && k.op === 'arasinda' && (
                              <select value={parametreler[k.alan!].kural} onChange={e => kuralDegistir(k.alan!, e.target.value)}>
                                {['', ...kurallar].map(r => <option key={r} value={r}>{KURAL_ETIKET[r] ?? r}</option>)}
                              </select>
                            )}
                          </>
                        ) : <span className="sonuk">sabit</span>}
                      </label>
                    </td>
                    <td className="orta"><button className="d mini" title="Koşulu sil" onClick={() => kosulSil(i)}>✕</button></td>
                  </tr>
                );
              })}
              {kosullar.length === 0 && <tr><td colSpan={6} className="bos">Koşul yok — tüm kayıtlar gelir.</td></tr>}
            </tbody>
          </table>
          <div className="pano-not">
            Alan listesi <b>kaynak kataloğundan</b> gelir; operatörler alanın türüne göre. Yetkin olmayan
            alan listede hiç görünmez. Liste tipi değerlerde virgülle ayırın: <i>SGK, Anadolu Sigorta</i>.
          </div>
        </div>

        {tanim.cikti === 'liste' && (
          <div className="dk-ikili">
            <div className="kagrup">
              <h6>Kolonlar <span className="sonuk">sıra · Σ toplam</span></h6>
              <div className="dk-kolonlar">
                {secili.map((ad, i) => {
                  const k = kolonlar.find(x => x.ad === ad);
                  const grupIdx = (tanim.grup ?? []).indexOf(ad);
                  return (
                    <div key={ad} className="dk-kolon">
                      <button className="d mini" onClick={() => kolonKaydir(i, -1)} disabled={i === 0}>▲</button>
                      <button className="d mini" onClick={() => kolonKaydir(i, 1)} disabled={i === secili.length - 1}>▼</button>
                      <span className="ad">{k?.baslik ?? ad}{grupIdx >= 0 && <span className="rozet mor">grup {grupIdx + 1}</span>}</span>
                      {k?.olculebilir && (
                        <label className="dk-onay" title="Toplam al">
                          <input type="checkbox" checked={(tanim.toplam ?? []).includes(ad)} onChange={() => toplamDegistir(ad)} />Σ
                        </label>
                      )}
                      <button className="d mini" onClick={() => kolonCikar(ad)}>✕</button>
                    </div>
                  );
                })}
                {secili.length === 0 && <div className="bos">Kolon seçilmedi — tüm görünür kolonlar gelir.</div>}
              </div>
              <div className="dk-havuz">
                <span className="sonuk">Eklenebilir:</span>
                {eklenebilir.map(k => (
                  <button key={k.ad} className="dk-cip" onClick={() => kolonEkle(k.ad)}>{k.baslik}</button>
                ))}
              </div>
            </div>
            <div className="kagrup">
              <h6>Gruplama · Sıralama</h6>
              <div className="dk-kimlik">
                {[0, 1].map(i => (
                  <label key={i}>Grup {i + 1}
                    <select value={(tanim.grup ?? [])[i] ?? ''} onChange={e => grupDegistir(i, e.target.value)}>
                      <option value="">—</option>
                      {gruplanabilir.map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                    </select>
                  </label>
                ))}
                <label>Sırala
                  <select value={tanim.sirala?.[0]?.alan ?? ''} onChange={e => siraDegistir(e.target.value, tanim.sirala?.[0]?.yon ?? 'desc')}>
                    <option value="">Varsayılan</option>
                    {kolonlar.filter(k => k.siralanabilir).map(k => <option key={k.ad} value={k.ad}>{k.baslik}</option>)}
                  </select>
                </label>
                <label>Yön
                  <select value={tanim.sirala?.[0]?.yon ?? 'desc'} disabled={!tanim.sirala?.[0]}
                          onChange={e => siraDegistir(tanim.sirala?.[0]?.alan ?? '', e.target.value as 'asc' | 'desc')}>
                    <option value="asc">Artan ↑</option><option value="desc">Azalan ↓</option>
                  </select>
                </label>
              </div>
              <div className="pano-not">
                Grup satırında adet ve Σ işaretli kolonların ara toplamı; en altta genel toplam.
                Gruplanabilir alan: kod · metin · tarih (kimlik kolonları hariç).
              </div>
            </div>
          </div>
        )}
      </div>

      <div className="dk-yan">
        <div className="kagrup">
          <h6>Tanım Özeti <span className="sonuk">okunabilir cümle</span></h6>
          <div className="dk-cumle">📄 {tanimCumlesi(tanim, kolonlar, kaynakAdi)}</div>
        </div>
        <div className="kagrup">
          <h6>Altyapı</h6>
          <div className="dk-sat"><span>Kaynak</span><span className="rozet mavi">liste motoru · {tanim.kaynak}</span></div>
          <div className="dk-sat"><span>Koşul → süzgeç</span><span className="rozet gri">filtre JSON</span></div>
          <div className="dk-sat"><span>Şube · alan yetkisi</span><span className="rozet ok">sunucuda</span></div>
          <div className="dk-sat"><span>Saklama</span><span className="rozet gri">dokum_tanimi (jsonb)</span></div>
          <div className="pano-not">
            Döküm, liste ekranlarının süzgeç/sıralama sözleşmesini <b>aynen</b> kullanır. Kolon ve
            alanlar beyaz listeden gelir; metin hiçbir yerde SQL'e ulaşmaz.
          </div>
        </div>
      </div>
    </div>
  );
}

/** Değer kutusu: operatör kaç değer istiyorsa o kadar; tarih/kod tipine uygun girdi. */
function DegerGirisi({ kosul, kolon, parametre, onDeger }: {
  kosul: Kosul; kolon?: DokumKolonMeta; parametre: boolean; onDeger(d: unknown): void;
}) {
  const n = degerSayisi(kosul.op);
  const tip = kolon?.tip ?? 'metin';
  const girdiTipi = tip === 'tarih' || tip === 'zaman' ? 'date' : (tip === 'sayi' || tip === 'para' || tip === 'ondalik') ? 'number' : 'text';
  if (n === 0) return <span className="sonuk">—</span>;
  if (parametre && tip === 'tarih') return <span className="sonuk">çalıştırırken sorulur (varsayılan: kural)</span>;
  if (n === 2) {
    const d = Array.isArray(kosul.deger) ? kosul.deger : ['', ''];
    return (
      <span className="dk-ikiz">
        <input type={girdiTipi} value={String(d[0] ?? '')} onChange={e => onDeger([e.target.value, d[1] ?? ''])} />
        <span className="sonuk">–</span>
        <input type={girdiTipi} value={String(d[1] ?? '')} onChange={e => onDeger([d[0] ?? '', e.target.value])} />
      </span>
    );
  }
  if (n === -1) {
    if (kolon?.kodlar) {
      const secili = Array.isArray(kosul.deger) ? kosul.deger.map(String) : [];
      return (
        <span className="dk-cipler">
          {Object.entries(kolon.kodlar).map(([kod, ad]) => (
            <label key={kod} className={`dk-cip${secili.includes(kod) ? ' on' : ''}`}>
              <input type="checkbox" checked={secili.includes(kod)} onChange={e =>
                onDeger(e.target.checked ? [...secili, kod] : secili.filter(x => x !== kod))} />
              {ad}
            </label>
          ))}
        </span>
      );
    }
    return (
      <input className="genis" placeholder="virgülle ayır: A, B, C"
             value={Array.isArray(kosul.deger) ? kosul.deger.join(', ') : String(kosul.deger ?? '')}
             onChange={e => onDeger(listeyeCevir(e.target.value))} />
    );
  }
  if (kolon?.kodlar) {
    return (
      <select value={String(kosul.deger ?? '')} onChange={e => onDeger(e.target.value)}>
        <option value="">—</option>
        {Object.entries(kolon.kodlar).map(([kod, ad]) => <option key={kod} value={kod}>{ad}</option>)}
      </select>
    );
  }
  if (tip === 'mantik') {
    return (
      <select value={String(kosul.deger ?? '')} onChange={e => onDeger(e.target.value)}>
        <option value="">—</option><option value="1">Evet</option><option value="0">Hayır</option>
      </select>
    );
  }
  return <input type={girdiTipi} value={String(kosul.deger ?? '')} onChange={e => onDeger(e.target.value)} />;
}
