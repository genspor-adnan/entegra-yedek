import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { KaynakArama } from '../KaynakArama';
import { guvenli, onay } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * KRONİK TANI KARTI — mockup `Ekranlar/Muayene/kronik_tani_karti.html`.
 *
 * Tanı ICD kataloğundan ARANIR; ad kayda KOPYALANIR (katalog güncellense de
 * özetteki metin değişmez). SİLMEK YERİNE "Geçmişe al": remisyondaki
 * hastalık tıbbi geçmiştir - durum Geçmiş, bitiş bugün.
 *
 * AYNI ICD İLE İKİNCİ AKTİF KAYIT AÇILMAZ: yeni kayıtta seçilen kod hastada
 * geçmişe alınmamış bir kayıtta varsa o kayıt açılır (mükerrer kronik tanı
 * özeti ikiye böler).
 */

const DURUMLAR = [
  { kod: 1, ad: 'Aktif', sinif: 'd1' }, { kod: 2, ad: 'Kontrol altında', sinif: 'd2' },
  { kod: 3, ad: 'Geçmiş (remisyon)', sinif: 'd3' },
];
const KAYNAKLAR = [{ kod: 1, ad: 'Hekim' }, { kod: 2, ad: 'Hasta beyanı' }, { kod: 3, ad: 'e-Nabız' },
                   { kod: 4, ad: 'Dış kurum' }];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const gun = (v: unknown) => metin(v).slice(0, 10);
const bugun = () => new Date().toISOString().slice(0, 10);

interface Deger {
  hastaId: number; icdKod: string; taniAd: string; baslangic: string; bitis: string;
  takipHekimId: number | null; durum: number; kaynak: number; kayitMuayeneId: number | null; notMetni: string;
}

export function KronikTaniKarti({ id, hastaId: ilkHasta, hastaAdi: ilkHastaAdi, muayeneId, onKapat, onKaydedildi }: {
  id: number | 'yeni';
  hastaId?: number;
  hastaAdi?: string;
  muayeneId?: number;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const bos = (h?: number): Deger => ({
    hastaId: h ?? 0, icdKod: '', taniAd: '', baslangic: '', bitis: '', takipHekimId: null,
    durum: 1, kaynak: 1, kayitMuayeneId: muayeneId ?? null, notMetni: '',
  });
  const [kayitId, setKayitId] = useState<number | null>(id === 'yeni' ? null : id);
  const [d, setD] = useState<Deger>(() => bos(ilkHasta));
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [hastaAdi, setHastaAdi] = useState(ilkHastaAdi ?? '');
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(id !== 'yeni');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [arama, setArama] = useState('');
  const [oneriler, setOneriler] = useState<ListeSatiri[]>([]);
  const [digerleri, setDigerleri] = useState<ListeSatiri[]>([]);
  const [hekimler, setHekimler] = useState<Record<string, string>>({});
  const [hastaSec, setHastaSec] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  /** Kaydı okur (ilk açılış ya da mükerrer kodda mevcut kayda geçiş). */
  const oku = async (kid: number) => {
    setYukleniyor(true);
    try {
      const y = await api.kartOku('hasta-kronik', kid);
      const k = y.kart;
      const v: Deger = {
        hastaId: sayi(k.hastaId), icdKod: metin(k.icdKod), taniAd: metin(k.taniAd),
        baslangic: gun(k.baslangic), bitis: gun(k.bitis),
        takipHekimId: k.takipHekimId == null ? null : sayi(k.takipHekimId),
        durum: sayi(k.durum) || 1, kaynak: sayi(k.kaynak) || 1,
        kayitMuayeneId: k.kayitMuayeneId == null ? null : sayi(k.kayitMuayeneId),
        notMetni: metin(k.notMetni),
      };
      setKayitId(kid); setD(v); setIlk(v); setSurum(k.surum);
      if (!hastaAdi) setHastaAdi(y.kodAd?.hastaId?.[String(k.hastaId ?? '')] ?? '');
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  };

  useEffect(() => { if (id !== 'yeni') void oku(id) }, [id]);   // yalniz acilista

  // Takip eden hekim seçenekleri kart metasından (sunucu lookup'ı).
  useEffect(() => {
    void api.kartAlanlari('hasta-kronik')
      .then(m => setHekimler(m.alanlar.find(a => a.ad === 'takipHekimId')?.kodlar ?? {}))
      .catch(() => {});
  }, []);

  // Hastanın diğer kronik tanıları (+ ad bağlamdan gelmediyse).
  useEffect(() => {
    if (!(d.hastaId > 0)) { setDigerleri([]); return }
    let iptal = false;
    void api.liste('hasta-kronik', { sayfa: 1, boyut: 30, filtre: { alan: 'hastaId', op: 'esit', deger: d.hastaId } })
      .then(y => { if (!iptal) setDigerleri(y.satirlar.filter(x => sayi(x.id) !== kayitId)) }).catch(() => {});
    if (!hastaAdi)
      void api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: d.hastaId } })
        .then(h => { if (!iptal) setHastaAdi(metin(h.satirlar[0]?.unvan)) }).catch(() => {});
    return () => { iptal = true };
  }, [d.hastaId, kayitId]);

  // ICD ARAMASI: kod başlar / ad içerir.
  useEffect(() => {
    const a = arama.trim();
    if (a.length < 2) { setOneriler([]); return }
    let iptal = false;
    const z = setTimeout(() => {
      void api.liste('icd', { sayfa: 1, boyut: 8, filtre: { op: 'and', kosullar: [
        { alan: 'aktif', op: 'esit', deger: 1 },
        { op: 'or', kosullar: [{ alan: 'kod', op: 'baslar', deger: a }, { alan: 'ad', op: 'icerir', deger: a }] },
      ] } }).then(y => { if (!iptal) setOneriler(y.satirlar) }).catch(() => {});
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [arama]);

  const icdSec = async (r: ListeSatiri) => {
    const kod = metin(r.kod);
    setArama(''); setOneriler([]);
    // MUKERRER: yeni kayitta ayni kod gecmise alinmamis bir kayitta varsa ona gec.
    const mevcut = kayitId === null
      ? digerleri.find(x => metin(x.icdKod) === kod && sayi(x.durum) !== 3) : undefined;
    if (mevcut && await onay(`${kod} bu hastada zaten kayıtlı. Mevcut kayıt açılsın mı?`)) {
      await oku(sayi(mevcut.id));
      return;
    }
    setD(o => ({ ...o, icdKod: kod, taniAd: metin(r.ad) }));
  };

  const govde = (v: Deger): Record<string, unknown> => ({
    hastaId: v.hastaId, icdKod: v.icdKod, taniAd: v.taniAd.trim(),
    baslangic: v.baslangic || null, bitis: v.bitis || null, takipHekimId: v.takipHekimId,
    durum: v.durum, kaynak: v.kaynak, kayitMuayeneId: v.kayitMuayeneId, notMetni: v.notMetni.trim(),
  });

  const kaydet = (sonra: 'kapat' | 'yeni', ek?: Partial<Deger>) => guvenli(async () => {
    const v = { ...d, ...ek };
    if (!(v.hastaId > 0)) { setHata('Hasta seçilmeli.'); return }
    if (!v.icdKod) { setHata('ICD-10 kodu seçilmeli.'); return }
    setHata(null);
    setKaydediyor(true);
    try {
      if (kayitId === null) await api.kartEkle('hasta-kronik', { kart: govde(v) });
      else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0) await api.kartGuncelle('hasta-kronik', kayitId, { surum, kart: fark });
      }
      onKaydedildi?.();
      if (sonra === 'kapat') { onKapat(); return }
      setKayitId(null); setIlk(null); setSurum(undefined); setD(bos(v.hastaId));
    } finally { setKaydediyor(false) }
  });

  const gecmiseAl = () => guvenli(async () => {
    if (!await onay('Tanı geçmişe alınacak: silinmez, durum "Geçmiş", bitiş bugün olur. Onaylıyor musunuz?')) return;
    await kaydet('kapat', { durum: 3, bitis: d.bitis || bugun() });
  });

  const durumRozet = (k: number) => k === 1 ? 'uyari' : k === 2 ? 'olumlu' : 'gri';
  const durumAdi = (k: number) => DURUMLAR.find(x => x.kod === k)?.ad ?? '';

  return (
    <>
      <Modal baslik={`🩺 ${c('Kronik Tanı')} — ${kayitId === null ? c('Yeni') : `#${kayitId}`}`}
        ekSinif="kart-alerji" buyutmeYok onKapat={onKapat}
        ustSerit={(
          <div className="rk-kimlik">
            <b className="rk-ad">{hastaAdi || (d.hastaId > 0 ? `#${d.hastaId}` : c('Hasta seçilmedi'))}</b>
            {(ilkHasta === undefined && kayitId === null) && (
              <button type="button" className="d" onClick={() => setHastaSec(true)}>👤 {c('Hasta seç')}</button>
            )}
            {d.kayitMuayeneId ? <span className="sonuk">{c('Muayene')} <b>#{d.kayitMuayeneId}</b></span> : null}
            <span className="rk-bosluk" />
            {digerleri.filter(x => sayi(x.durum) !== 3).slice(0, 3).map((x, i) => (
              <span key={i} className={`rozet ${durumRozet(sayi(x.durum))}`}>
                {c('Mevcut')}: {metin(x.icdKod)} {metin(x.taniAd)}
              </span>
            ))}
          </div>
        )}
        alt={<>
          <button type="button" className="d bir" disabled={kaydediyor || yukleniyor}
                  onClick={() => void kaydet('kapat')}>💾 {c('Kaydet')}</button>
          <button type="button" className="d" disabled={kaydediyor || yukleniyor}
                  onClick={() => void kaydet('yeni')}>💾＋ {c('Kaydet ve yeni')}</button>
          <span style={{ marginLeft: 'auto' }} />
          {/* Kayit OKUNDUKTAN sonra: yuklenirken tik surumsuz (eszamanlilik denetimsiz) yazim gonderirdi. */}
          {kayitId !== null && ilk !== null && d.durum !== 3 && (
            <button type="button" className="d teh" onClick={() => void gecmiseAl()}
                    title={c('Silinmez; durum Geçmiş, bitiş bugün')}>⏸ {c('Geçmişe al')}</button>
          )}
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="rk-govde ak-govde">
          <div className="rk-sol">
            <div className="kagrup">
              <h6>{c('Tanı')}</h6>
              <div className="ak-alanlar">
                <div className="rk-fld ak-arama">
                  <label htmlFor="kt-icd">{c('ICD-10')} <span className="ak-zor">*</span></label>
                  <input id="kt-icd" value={arama || d.icdKod} placeholder={c('Kod ya da tanı adı yazın…')}
                         onChange={e => setArama(e.target.value)} />
                  {oneriler.length > 0 && (
                    <div className="ak-oneri" role="listbox">
                      {oneriler.map((r, i) => (
                        <button key={i} type="button" role="option" onClick={() => void icdSec(r)}>
                          <b>{metin(r.kod)}</b> {metin(r.ad)}
                        </button>
                      ))}
                    </div>
                  )}
                </div>
                <div className="rk-fld">
                  <label htmlFor="kt-ad">{c('Tanı adı (kayda kopyalanır)')}</label>
                  <input id="kt-ad" value={d.taniAd} maxLength={300} onChange={e => yaz('taniAd', e.target.value)} />
                </div>
              </div>
            </div>
            <div className="kagrup">
              <h6>{c('Takip')}</h6>
              <div className="ak-alanlar">
                <div className="rk-fld">
                  <label>{c('Durum')}</label>
                  <div className="ak-seg ak-durum" role="radiogroup" aria-label={c('Durum')}>
                    {DURUMLAR.map(x => (
                      <button key={x.kod} type="button" role="radio" aria-checked={d.durum === x.kod}
                              className={`${x.sinif}${d.durum === x.kod ? ' on' : ''}`}
                              onClick={() => yaz('durum', x.kod)}>{x.ad}</button>
                    ))}
                  </div>
                </div>
                <div className="ak-iki">
                  <div className="rk-fld">
                    <label htmlFor="kt-bas">{c('Başlangıç')}</label>
                    <input id="kt-bas" type="date" value={d.baslangic} onChange={e => yaz('baslangic', e.target.value)} />
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="kt-bit">{c('Bitiş (remisyon)')}</label>
                    <input id="kt-bit" type="date" value={d.bitis} onChange={e => yaz('bitis', e.target.value)} />
                  </div>
                </div>
                <div className="ak-iki">
                  <div className="rk-fld">
                    <label htmlFor="kt-hekim">{c('Takip eden hekim')}</label>
                    <select id="kt-hekim" value={d.takipHekimId ?? ''}
                            onChange={e => yaz('takipHekimId', e.target.value ? Number(e.target.value) : null)}>
                      <option value="">—</option>
                      {Object.entries(hekimler).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  </div>
                  <div className="rk-fld">
                    <label>{c('Kaynak')}</label>
                    <div className="ak-seg" role="radiogroup" aria-label={c('Kaynak')}>
                      {KAYNAKLAR.map(k => (
                        <button key={k.kod} type="button" role="radio" aria-checked={d.kaynak === k.kod}
                                className={d.kaynak === k.kod ? 'on' : ''}
                                onClick={() => yaz('kaynak', k.kod)}>{k.ad}</button>
                      ))}
                    </div>
                  </div>
                </div>
                <div className="rk-fld">
                  <label htmlFor="kt-not">{c('Not')}</label>
                  <input id="kt-not" value={d.notMetni} maxLength={300} onChange={e => yaz('notMetni', e.target.value)} />
                </div>
              </div>
            </div>
          </div>
          <div className="rk-sag">
            <div className="rk-bant mavi">
              <b>{c('Bu tanı nerede görünür?')}</b>
              <div>{c('Muayene kartının üst şeridinde (Alerji / Kronik), tıbbi özetin "Kronik Tanılar" bölümünde ve İSG / diş kartlarının hasta özetinde.')}</div>
            </div>
            <div className="rk-blk">
              <h6>{c('Hastanın diğer kronik tanıları')}</h6>
              {digerleri.length === 0 ? <span className="rozet olumlu">{c('Başka kronik tanı yok')}</span> : (
                <ul className="ak-liste">
                  {digerleri.map((x, i) => (
                    <li key={i} className={sayi(x.durum) === 3 ? 'sonuk' : ''}>
                      <span className={`rozet ${durumRozet(sayi(x.durum))}`}>{durumAdi(sayi(x.durum))}</span>{' '}
                      {metin(x.icdKod)} {metin(x.taniAd)}
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </div>
        </div>
        )}
      </Modal>
      {hastaSec && (
        <KaynakArama kaynak="hasta" baslik={c('Hasta seç')} kodAlani="kod" adAlani="unvan"
          onKapat={() => setHastaSec(false)}
          onSec={r => { setHastaSec(false); yaz('hastaId', sayi(r.id)); setHastaAdi(metin(r.unvan)) }} />
      )}
    </>
  );
}
