import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { KaynakArama } from '../KaynakArama';
import { guvenli, onay } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * KULLANILAN İLAÇ KARTI — mockup `Ekranlar/Muayene/kullanilan_ilac_karti.html`.
 *
 * İlaç KATALOGDAN seçilir: barkod, ad ve etken madde birlikte dolar
 * (reçetedeki etkileşim / alerji kontrolü maddeye bakar). SİLMEK YERİNE
 * "İlacı bıraktı": aktif değil, bitiş bugün, uyum "Bırakmış" - ilaç geçmişi
 * kaybolmaz. Etken madde hastanın aktif bir alerjisiyle çakışırsa kartta
 * kırmızı uyarı çıkar; kayıt ENGELLENMEZ (hasta zaten kullanıyor olabilir).
 */

const KAYNAKLAR = [{ kod: 1, ad: 'Reçete' }, { kod: 2, ad: 'Hasta beyanı' }, { kod: 3, ad: 'e-Nabız' },
                   { kod: 4, ad: 'Dış kurum' }];
const UYUMLAR = [{ kod: 1, ad: 'Düzenli', sinif: 'u1' }, { kod: 2, ad: 'Aralıklı', sinif: 'u2' },
                 { kod: 3, ad: 'Bırakmış', sinif: 'u3' }];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const gun = (v: unknown) => metin(v).slice(0, 10);
const bugun = () => new Date().toISOString().slice(0, 10);
const kucuk = (s: string) => s.toLocaleLowerCase('tr');

interface Deger {
  hastaId: number; ilacBarkod: string; ilacAd: string; etkenMadde: string; doz: string; periyot: string;
  baslangic: string; bitis: string; kaynak: number; uyum: number; aktif: number;
}

export function IlacKaydiKarti({ id, hastaId: ilkHasta, hastaAdi: ilkHastaAdi, onKapat, onKaydedildi }: {
  id: number | 'yeni';
  hastaId?: number;
  hastaAdi?: string;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const bos = (h?: number): Deger => ({
    hastaId: h ?? 0, ilacBarkod: '', ilacAd: '', etkenMadde: '', doz: '', periyot: '',
    baslangic: '', bitis: '', kaynak: 2, uyum: 1, aktif: 1,
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
  const [atc, setAtc] = useState('');
  const [digerleri, setDigerleri] = useState<ListeSatiri[]>([]);
  const [alerjiler, setAlerjiler] = useState<ListeSatiri[]>([]);
  const [hastaSec, setHastaSec] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  useEffect(() => {
    if (id === 'yeni') return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kartOku('hasta-ilac', id);
        if (iptal) return;
        const k = y.kart;
        const v: Deger = {
          hastaId: sayi(k.hastaId), ilacBarkod: metin(k.ilacBarkod), ilacAd: metin(k.ilacAd),
          etkenMadde: metin(k.etkenMadde), doz: metin(k.doz), periyot: metin(k.periyot),
          baslangic: gun(k.baslangic), bitis: gun(k.bitis), kaynak: sayi(k.kaynak) || 2,
          uyum: sayi(k.uyum) || 1, aktif: sayi(k.aktif ?? 1),
        };
        setD(v); setIlk(v); setSurum(k.surum);
        if (!hastaAdi) setHastaAdi(y.kodAd?.hastaId?.[String(k.hastaId ?? '')] ?? '');
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [id]);   // yalniz acilista

  // Hastanın diğer ilaçları + aktif alerjileri (+ ad).
  useEffect(() => {
    if (!(d.hastaId > 0)) { setDigerleri([]); setAlerjiler([]); return }
    let iptal = false;
    const f = { alan: 'hastaId', op: 'esit' as const, deger: d.hastaId };
    void api.liste('hasta-ilac', { sayfa: 1, boyut: 30, filtre: f })
      .then(y => { if (!iptal) setDigerleri(y.satirlar.filter(x => sayi(x.id) !== kayitId)) }).catch(() => {});
    void api.liste('hasta-alerji', { sayfa: 1, boyut: 30, filtre: f })
      .then(y => { if (!iptal) setAlerjiler(y.satirlar.filter(x => sayi(x.aktif ?? 1) === 1)) }).catch(() => {});
    if (!hastaAdi)
      void api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: d.hastaId } })
        .then(h => { if (!iptal) setHastaAdi(metin(h.satirlar[0]?.unvan)) }).catch(() => {});
    return () => { iptal = true };
  }, [d.hastaId, kayitId]);

  // İLAÇ ARAMASI: ad / etken madde / barkod.
  useEffect(() => {
    const a = arama.trim();
    if (a.length < 3) { setOneriler([]); return }
    let iptal = false;
    const z = setTimeout(() => {
      void api.liste('ilac', { sayfa: 1, boyut: 8, filtre: { op: 'and', kosullar: [
        { alan: 'aktif', op: 'esit', deger: 1 },
        { op: 'or', kosullar: [
          { alan: 'ad', op: 'icerir', deger: a }, { alan: 'etkenMadde', op: 'icerir', deger: a },
          { alan: 'barkod', op: 'baslar', deger: a },
        ] },
      ] } }).then(y => { if (!iptal) setOneriler(y.satirlar) }).catch(() => {});
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [arama]);

  const ilacSec = (r: ListeSatiri) => {
    setD(o => ({ ...o, ilacBarkod: metin(r.barkod), ilacAd: metin(r.ad), etkenMadde: metin(r.etkenMadde) }));
    setAtc(metin(r.atcKod));
    setArama(''); setOneriler([]);
  };

  // ALERJI KONTROLU: etken madde hastanin aktif alerjisinin maddesini iceriyor mu.
  const madde = kucuk(d.etkenMadde);
  const cakisan = madde
    ? alerjiler.filter(a => {
        const m = kucuk(metin(a.etkenMadde) || metin(a.etken));
        return m.length >= 3 && (madde.includes(m) || m.includes(madde));
      })
    : [];

  const govde = (v: Deger): Record<string, unknown> => ({
    hastaId: v.hastaId, ilacBarkod: v.ilacBarkod, ilacAd: v.ilacAd.trim(), etkenMadde: v.etkenMadde.trim(),
    doz: v.doz.trim(), periyot: v.periyot.trim(), baslangic: v.baslangic || null, bitis: v.bitis || null,
    kaynak: v.kaynak, uyum: v.uyum, aktif: v.aktif,
  });

  const kaydet = (sonra: 'kapat' | 'yeni', ek?: Partial<Deger>) => guvenli(async () => {
    const v = { ...d, ...ek };
    if (!(v.hastaId > 0)) { setHata('Hasta seçilmeli.'); return }
    if (!v.ilacAd.trim()) { setHata('İlaç seçilmeli.'); return }
    setHata(null);
    setKaydediyor(true);
    try {
      if (kayitId === null) await api.kartEkle('hasta-ilac', { kart: govde(v) });
      else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0) await api.kartGuncelle('hasta-ilac', kayitId, { surum, kart: fark });
      }
      onKaydedildi?.();
      if (sonra === 'kapat') { onKapat(); return }
      setKayitId(null); setIlk(null); setSurum(undefined); setAtc(''); setD(bos(v.hastaId));
    } finally { setKaydediyor(false) }
  });

  const birakti = () => guvenli(async () => {
    if (!await onay('İlaç bırakıldı olarak işaretlenecek: silinmez, aktif değil, bitiş bugün olur. Onaylıyor musunuz?')) return;
    await kaydet('kapat', { aktif: 0, uyum: 3, bitis: d.bitis || bugun() });
  });

  return (
    <>
      <Modal baslik={`💊 ${c('Kullanılan İlaç')} — ${kayitId === null ? c('Yeni') : `#${kayitId}`}`}
        ekSinif="kart-alerji" buyutmeYok onKapat={onKapat}
        ustSerit={(
          <div className="rk-kimlik">
            <b className="rk-ad">{hastaAdi || (d.hastaId > 0 ? `#${d.hastaId}` : c('Hasta seçilmedi'))}</b>
            {(ilkHasta === undefined && kayitId === null) && (
              <button type="button" className="d" onClick={() => setHastaSec(true)}>👤 {c('Hasta seç')}</button>
            )}
            <span className="rk-bosluk" />
            {alerjiler.slice(0, 3).map((a, i) => (
              <span key={`a${i}`} className="rozet hata">{c('Alerji')}: {metin(a.etken) || metin(a.etkenMadde)}</span>
            ))}
            {digerleri.filter(x => sayi(x.aktif ?? 1) === 1).slice(0, 2).map((x, i) => (
              <span key={`i${i}`} className="rozet mavi">{c('Aktif')}: {metin(x.ilacAd)}</span>
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
          {kayitId !== null && ilk !== null && d.aktif === 1 && (
            <button type="button" className="d teh" onClick={() => void birakti()}
                    title={c('Silinmez; aktif değil, bitiş bugün, uyum Bırakmış')}>⏹ {c('İlacı bıraktı')}</button>
          )}
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="rk-govde ak-govde">
          <div className="rk-sol">
            <div className="kagrup">
              <h6>{c('İlaç')}</h6>
              <div className="ak-alanlar">
                <div className="rk-fld ak-arama">
                  <label htmlFor="ik-ilac">{c('İlaç (katalogdan)')} <span className="ak-zor">*</span></label>
                  <input id="ik-ilac" value={arama || d.ilacAd} placeholder={c('İlaç adı, etken madde ya da barkod…')}
                         onChange={e => setArama(e.target.value)} />
                  {oneriler.length > 0 && (
                    <div className="ak-oneri" role="listbox">
                      {oneriler.map((r, i) => (
                        <button key={i} type="button" role="option" onClick={() => ilacSec(r)}>
                          <b>{metin(r.ad)}</b>
                          <span className="sonuk">{metin(r.etkenMadde)}{metin(r.atcKod) ? ` · ${metin(r.atcKod)}` : ''}</span>
                        </button>
                      ))}
                    </div>
                  )}
                </div>
                <div className="ak-iki">
                  <div className="rk-fld">
                    <label>{c('Etken madde')}</label>
                    <div className="ak-salt">{d.etkenMadde || <span className="sonuk">—</span>}
                      {atc && <span className="rozet mavi" style={{ marginLeft: 6 }}>{atc}</span>}</div>
                  </div>
                  <div className="rk-fld">
                    <label>{c('Barkod')}</label>
                    <div className="ak-salt">{d.ilacBarkod || <span className="sonuk">—</span>}</div>
                  </div>
                </div>
              </div>
            </div>
            <div className="kagrup">
              <h6>{c('Kullanım')}</h6>
              <div className="ak-alanlar">
                <div className="ak-iki">
                  <div className="rk-fld">
                    <label htmlFor="ik-doz">{c('Doz')}</label>
                    <input id="ik-doz" value={d.doz} maxLength={20} placeholder="50 mg" onChange={e => yaz('doz', e.target.value)} />
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="ik-periyot">{c('Periyot')}</label>
                    <input id="ik-periyot" value={d.periyot} maxLength={20} placeholder="1x1" onChange={e => yaz('periyot', e.target.value)} />
                  </div>
                </div>
                <div className="ak-iki">
                  <div className="rk-fld">
                    <label htmlFor="ik-bas">{c('Başlangıç')}</label>
                    <input id="ik-bas" type="date" value={d.baslangic} onChange={e => yaz('baslangic', e.target.value)} />
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="ik-bit">{c('Bitiş')}</label>
                    <input id="ik-bit" type="date" value={d.bitis} onChange={e => yaz('bitis', e.target.value)} />
                  </div>
                </div>
                <div className="ak-iki">
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
                  <div className="rk-fld">
                    <label>{c('Uyum')}</label>
                    <div className="ak-seg ak-uyum" role="radiogroup" aria-label={c('Uyum')}>
                      {UYUMLAR.map(u => (
                        <button key={u.kod} type="button" role="radio" aria-checked={d.uyum === u.kod}
                                className={`${u.sinif}${d.uyum === u.kod ? ' on' : ''}`}
                                onClick={() => yaz('uyum', u.kod)}>{u.ad}</button>
                      ))}
                    </div>
                  </div>
                </div>
                <label className="ak-kutu">
                  <input type="checkbox" checked={d.aktif === 1} onChange={e => yaz('aktif', e.target.checked ? 1 : 0)} />
                  {c('Aktif')} <span className="sonuk">{c('(muayene şeridinde ve reçete kontrolünde görünür)')}</span>
                </label>
              </div>
            </div>
          </div>
          <div className="rk-sag">
            <div className="rk-bant mavi">
              <b>{c('Neden önemli?')}</b>
              <div>{c('Aktif ilaçlar reçete yazılırken etkileşim kontrolüne girer ve muayene şeridinde mavi rozet olarak görünür.')}</div>
            </div>
            <div className="rk-blk">
              <h6>{c('Alerji kontrolü')}</h6>
              {!d.etkenMadde ? <span className="sonuk">{c('İlaç seçilince kontrol edilir.')}</span>
                : cakisan.length > 0 ? (
                  <div className="rk-bant hata">
                    <b>⚠ {d.etkenMadde}</b>
                    {cakisan.map((a, i) => <div key={i}>{c('Alerji')}: {metin(a.etken) || metin(a.etkenMadde)}</div>)}
                    <div className="sonuk">{c('Kayıt engellenmez; hekim bilgilendirilir.')}</div>
                  </div>
                ) : <span className="rozet olumlu">{d.etkenMadde}: {c('hasta alerjileriyle çakışma yok')}</span>}
            </div>
            <div className="rk-blk">
              <h6>{c('Hastanın diğer ilaçları')}</h6>
              {digerleri.length === 0 ? <span className="rozet olumlu">{c('Başka ilaç yok')}</span> : (
                <ul className="ak-liste">
                  {digerleri.map((x, i) => {
                    const aktif = sayi(x.aktif ?? 1) === 1;
                    return (
                      <li key={i} className={aktif ? '' : 'sonuk'}>
                        <span className={`rozet ${aktif ? 'mavi' : 'gri'}`}>{aktif ? c('Aktif') : c('Bıraktı')}</span>{' '}
                        {metin(x.ilacAd)}{metin(x.doz) ? ` · ${metin(x.doz)}` : ''}
                      </li>
                    );
                  })}
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
