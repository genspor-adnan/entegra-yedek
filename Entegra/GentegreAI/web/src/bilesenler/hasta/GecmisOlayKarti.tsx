import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { KaynakArama } from '../KaynakArama';
import { guvenli, onay } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * GEÇMİŞ OLAY KARTI — mockup `Ekranlar/Muayene/gecmis_olay_karti.html`.
 *
 * TÜR alan etiketini ve aramayı belirler: Ameliyat / Girişim → hizmet
 * kataloğu (SUT, "Ameliyat ve Girişimler" kategorisi; kod = SUT kodu), Aşı →
 * aşı tanımları (kod = SKRS kodu), Yatış / Travma / Transfüzyon → serbest
 * metin. Katalogda olmayan olay serbest yazılır (kod boş kalır).
 *
 * TARİH TAM BİLİNMEYEBİLİR: hasta beyanında yıl yeter - "yalnız yıl" işareti
 * tarihi 1 Ocak olarak saklar, ekran o durumda yalnız yılı gösterir.
 *
 * Geçmiş olay bir OLGUDUR (pasif hâli yok): Sil yalnız yanlış girilmiş kayıt
 * içindir. Sağdaki zaman çizgisi hastanın bütün olaylarını gösterir; tıklanan
 * olay açılır.
 */

const TURLER = [
  { kod: 1, ad: 'Ameliyat', ikon: '🔪', alt: "SUT'tan işlem", renk: '#b3261e' },
  { kod: 2, ad: 'Girişim', ikon: '🩺', alt: 'endoskopi, biyopsi…', renk: '#e0843a' },
  { kod: 3, ad: 'Yatış', ikon: '🛏', alt: 'servis, süre', renk: '#2f6db3' },
  { kod: 4, ad: 'Aşı', ikon: '💉', alt: 'aşı listesi', renk: '#2e7d46' },
  { kod: 5, ad: 'Travma', ikon: '🩹', alt: 'kaza, kırık', renk: '#8a6218' },
  { kod: 6, ad: 'Transfüzyon', ikon: '🩸', alt: 'kan ürünü', renk: '#6a3fb5' },
];
const OLAY_ETIKETI: Record<number, string> = {
  1: 'İşlem (SUT kataloğundan)', 2: 'Girişim (SUT kataloğundan)', 3: 'Yatış nedeni / servis',
  4: 'Aşı (aşı listesinden)', 5: 'Travma', 6: 'Kan ürünü',
};
const KAYNAKLAR = [{ kod: 1, ad: 'Hekim' }, { kod: 2, ad: 'Hasta beyanı' }, { kod: 3, ad: 'e-Nabız' },
                   { kod: 4, ad: 'Dış kurum' }];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const gun = (v: unknown) => metin(v).slice(0, 10);
/** 1 Ocak tarihi "yalnız yıl" girişidir: yalnız yıl gösterilir. */
export const olayTarihi = (v: unknown) => {
  const s = gun(v);
  if (!s) return '';
  const [y, a, g] = s.split('-');
  return a === '01' && g === '01' ? y : `${g}.${a}.${y}`;
};
const turBul = (k: number) => TURLER.find(t => t.kod === k) ?? TURLER[0];

interface Deger {
  hastaId: number; tur: number; ad: string; kod: string; tarih: string; kurum: string;
  notMetni: string; kaynak: number;
}

export function GecmisOlayKarti({ id, hastaId: ilkHasta, hastaAdi: ilkHastaAdi, muayeneId, onKapat, onKaydedildi }: {
  id: number | 'yeni';
  hastaId?: number;
  hastaAdi?: string;
  /** Açıldığı muayene (şeritte gösterilir). */
  muayeneId?: number;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const bos = (h?: number, tur = 1): Deger => ({
    hastaId: h ?? 0, tur, ad: '', kod: '', tarih: '', kurum: '', notMetni: '', kaynak: 2,
  });
  const [kayitId, setKayitId] = useState<number | null>(id === 'yeni' ? null : id);
  const [d, setD] = useState<Deger>(() => bos(ilkHasta));
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [yalnizYil, setYalnizYil] = useState(false);
  const [hastaAdi, setHastaAdi] = useState(ilkHastaAdi ?? '');
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(id !== 'yeni');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [arama, setArama] = useState('');
  const [oneriler, setOneriler] = useState<ListeSatiri[]>([]);
  const [olaylar, setOlaylar] = useState<ListeSatiri[]>([]);
  const [suzgec, setSuzgec] = useState(0);
  const [tazele, setTazele] = useState(0);
  const [hastaSec, setHastaSec] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  const oku = async (kid: number) => {
    setYukleniyor(true);
    try {
      const y = await api.kartOku('hasta-gecmis', kid);
      const k = y.kart;
      const v: Deger = {
        hastaId: sayi(k.hastaId), tur: sayi(k.tur) || 1, ad: metin(k.ad), kod: metin(k.kod),
        tarih: gun(k.tarih), kurum: metin(k.kurum), notMetni: metin(k.notMetni), kaynak: sayi(k.kaynak) || 2,
      };
      setKayitId(kid); setD(v); setIlk(v); setSurum(k.surum); setArama('');
      setYalnizYil(v.tarih.endsWith('-01-01'));
      if (!hastaAdi) setHastaAdi(y.kodAd?.hastaId?.[String(k.hastaId ?? '')] ?? '');
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  };

  useEffect(() => { if (id !== 'yeni') void oku(id) }, [id]);   // yalniz acilista

  // Hastanın bütün olayları (zaman çizgisi) + ad.
  useEffect(() => {
    if (!(d.hastaId > 0)) { setOlaylar([]); return }
    let iptal = false;
    void api.liste('hasta-gecmis', { sayfa: 1, boyut: 100, filtre: { alan: 'hastaId', op: 'esit', deger: d.hastaId } })
      .then(y => {
        if (iptal) return;
        setOlaylar([...y.satirlar].sort((a, b) => gun(b.tarih).localeCompare(gun(a.tarih))));
      }).catch(() => {});
    if (!hastaAdi)
      void api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: d.hastaId } })
        .then(h => { if (!iptal) setHastaAdi(metin(h.satirlar[0]?.unvan)) }).catch(() => {});
    return () => { iptal = true };
  }, [d.hastaId, tazele]);

  // KATALOG ARAMASI türe göre: ameliyat/girişim → hizmet (kategori 5), aşı → asi.
  useEffect(() => {
    const a = arama.trim();
    const katalog = d.tur === 1 || d.tur === 2 ? 'hizmet' : d.tur === 4 ? 'asi' : null;
    if (!katalog || a.length < 2) { setOneriler([]); return }
    let iptal = false;
    const z = setTimeout(() => {
      const kosullar: Kosul[] = [
        { op: 'or', kosullar: [{ alan: 'kod', op: 'baslar', deger: a }, { alan: 'ad', op: 'icerir', deger: a }] },
      ];
      if (katalog === 'hizmet') kosullar.push({ alan: 'kategori', op: 'esit', deger: 5 });
      else kosullar.push({ alan: 'aktif', op: 'esit', deger: 1 });
      void api.liste(katalog, { sayfa: 1, boyut: 8, filtre: { op: 'and', kosullar } })
        .then(y => { if (!iptal) setOneriler(y.satirlar) }).catch(() => {});
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [arama, d.tur]);

  const oneriSec = (r: ListeSatiri) => {
    // Aşıda SKRS kodu varsa o (e-Nabız aşı kaydıyla karşılaştırılan kod).
    const kod = d.tur === 4 ? (metin(r.skrsKod) || metin(r.kod)) : metin(r.kod);
    setD(o => ({ ...o, ad: metin(r.ad), kod }));
    setArama(''); setOneriler([]);
  };

  const turDegis = (t: number) => {
    // Tür değişince katalog kodu anlamını yitirir (SUT kodu aşı kodu değildir).
    setD(o => ({ ...o, tur: t, kod: o.tur === t ? o.kod : '' }));
    setOneriler([]);
  };

  const govde = (v: Deger): Record<string, unknown> => ({
    hastaId: v.hastaId, tur: v.tur, ad: v.ad.trim(), kod: v.kod.trim(), tarih: v.tarih || null,
    kurum: v.kurum.trim(), notMetni: v.notMetni.trim(), kaynak: v.kaynak,
  });

  const kaydet = (sonra: 'kapat' | 'yeni') => guvenli(async () => {
    const v = { ...d, ad: arama.trim() && !d.ad ? arama.trim() : d.ad };
    if (!(v.hastaId > 0)) { setHata('Hasta seçilmeli.'); return }
    if (!v.ad.trim()) { setHata('Olay yazılmalı.'); return }
    setHata(null);
    setKaydediyor(true);
    try {
      if (kayitId === null) await api.kartEkle('hasta-gecmis', { kart: govde(v) });
      else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0) await api.kartGuncelle('hasta-gecmis', kayitId, { surum, kart: fark });
      }
      onKaydedildi?.();
      if (sonra === 'kapat') { onKapat(); return }
      setKayitId(null); setIlk(null); setSurum(undefined); setYalnizYil(false); setArama('');
      setD(bos(v.hastaId, v.tur));
      setTazele(t => t + 1);
    } finally { setKaydediyor(false) }
  });

  const sil = () => guvenli(async () => {
    if (kayitId === null) return;
    if (!await onay('Olay silinecek. Yalnız yanlış girilmiş kayıt için. Onaylıyor musunuz?')) return;
    await api.kartSil('hasta-gecmis', kayitId);
    onKaydedildi?.();
    onKapat();
  });

  const tur = turBul(d.tur);
  const katalogVar = d.tur === 1 || d.tur === 2 || d.tur === 4;
  const gorunen = suzgec ? olaylar.filter(o => sayi(o.tur) === suzgec) : olaylar;
  const yilDegeri = d.tarih ? d.tarih.slice(0, 4) : '';

  return (
    <>
      <Modal baslik={`🗓 ${c('Geçmiş Olay')} — ${kayitId === null ? c('Yeni') : `#${kayitId}`}`}
        ekSinif="kart-alerji kart-gecmis" buyutmeYok onKapat={onKapat}
        ustSerit={(
          <div className="rk-kimlik">
            <b className="rk-ad">{hastaAdi || (d.hastaId > 0 ? `#${d.hastaId}` : c('Hasta seçilmedi'))}</b>
            {(ilkHasta === undefined && kayitId === null) && (
              <button type="button" className="d" onClick={() => setHastaSec(true)}>👤 {c('Hasta seç')}</button>
            )}
            {muayeneId ? <span className="sonuk">{c('Muayene')} <b>#{muayeneId}</b></span> : null}
            <span className="rk-bosluk" />
            <span className="rozet gri">{olaylar.length} {c('geçmiş olay')}</span>
          </div>
        )}
        alt={<>
          <button type="button" className="d bir" disabled={kaydediyor || yukleniyor}
                  onClick={() => void kaydet('kapat')}>💾 {c('Kaydet')}</button>
          <button type="button" className="d" disabled={kaydediyor || yukleniyor}
                  onClick={() => void kaydet('yeni')}>💾＋ {c('Kaydet ve yeni')}</button>
          <span style={{ marginLeft: 'auto' }} />
          {kayitId !== null && (
            <button type="button" className="d teh" onClick={() => void sil()}
                    title={c('Yalnız yanlış girilmiş kayıt için')}>🗑 {c('Sil')}</button>
          )}
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="rk-govde go-govde">
          <div className="rk-sol">
            <div className="kagrup">
              <h6>{c('Olay türü')}</h6>
              <div className="go-turler" role="radiogroup" aria-label={c('Olay türü')}>
                {TURLER.map(t => (
                  <button key={t.kod} type="button" role="radio" aria-checked={d.tur === t.kod}
                          className={`go-tur${d.tur === t.kod ? ' on' : ''}`}
                          style={{ ['--go-renk' as string]: t.renk }}
                          onClick={() => turDegis(t.kod)}>
                    <b>{t.ikon} {t.ad}</b><small>{t.alt}</small>
                  </button>
                ))}
              </div>
            </div>

            <div className="kagrup">
              <h6>{c('Olay')} — {tur.ad}</h6>
              <div className="ak-alanlar">
                <div className="rk-fld ak-arama">
                  <label htmlFor="go-ad">{c(OLAY_ETIKETI[d.tur])} <span className="ak-zor">*</span></label>
                  <input id="go-ad" value={arama || d.ad} maxLength={200}
                         placeholder={katalogVar ? c('Yazdıkça aranır; katalogda yoksa serbest yazın') : ''}
                         onChange={e => { setArama(e.target.value); setD(o => ({ ...o, ad: e.target.value, kod: katalogVar ? '' : o.kod })) }} />
                  {oneriler.length > 0 && (
                    <div className="ak-oneri" role="listbox">
                      {oneriler.map((r, i) => (
                        <button key={i} type="button" role="option" onClick={() => oneriSec(r)}>
                          <b>{metin(r.ad)}</b>
                          <span className="sonuk">{d.tur === 4 ? (metin(r.skrsKod) || metin(r.kod)) : `SUT ${metin(r.kod)}`}</span>
                        </button>
                      ))}
                    </div>
                  )}
                  {katalogVar && <span className="not">{c('Katalogda yoksa serbest yazılabilir; kod boş kalır.')}</span>}
                </div>
                <div className="go-uc">
                  <div className="rk-fld">
                    <label htmlFor="go-kod">{c('Kod (SUT / aşı)')}</label>
                    <input id="go-kod" value={d.kod} maxLength={20} onChange={e => yaz('kod', e.target.value)} />
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="go-tarih">
                      {c('Tarih')}
                      <span className="go-yil">
                        <input type="checkbox" checked={yalnizYil} aria-label={c('Yalnız yıl')}
                               onChange={e => {
                                 setYalnizYil(e.target.checked);
                                 if (e.target.checked && d.tarih) yaz('tarih', `${d.tarih.slice(0, 4)}-01-01`);
                               }} /> {c('yalnız yıl')}
                      </span>
                    </label>
                    {yalnizYil
                      ? <input id="go-tarih" type="number" min={1900} max={2100} value={yilDegeri}
                               placeholder="YYYY"
                               onChange={e => yaz('tarih', e.target.value.length === 4 ? `${e.target.value}-01-01` : '')} />
                      : <input id="go-tarih" type="date" value={d.tarih} onChange={e => yaz('tarih', e.target.value)} />}
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="go-kurum">{c('Kurum')}</label>
                    <input id="go-kurum" value={d.kurum} maxLength={120} onChange={e => yaz('kurum', e.target.value)} />
                  </div>
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
                <div className="rk-fld">
                  <label htmlFor="go-not">{c('Not')}</label>
                  <input id="go-not" value={d.notMetni} maxLength={400} onChange={e => yaz('notMetni', e.target.value)} />
                </div>
              </div>
            </div>
          </div>

          <div className="rk-sag">
            <div className="rk-bant mavi">
              <b>{c('Nerede görünür?')}</b>
              <div>{c('Tıbbi özetin "Ameliyat / girişim · Aşı" bölümünde ve muayenede hasta öyküsünde.')}</div>
            </div>
            <div className="rk-blk">
              <h6>{c('Hastanın geçmişi')}</h6>
              <div className="go-filtre">
                <button type="button" className={suzgec === 0 ? 'on' : ''} onClick={() => setSuzgec(0)}>{c('Tümü')}</button>
                {TURLER.filter(t => olaylar.some(o => sayi(o.tur) === t.kod)).map(t => (
                  <button key={t.kod} type="button" className={suzgec === t.kod ? 'on' : ''}
                          onClick={() => setSuzgec(t.kod)}>{t.ad}</button>
                ))}
              </div>
              {gorunen.length === 0 ? <span className="sonuk">{c('Kayıtlı olay yok.')}</span> : (
                <ul className="go-cizgi">
                  {gorunen.map(o => {
                    const t = turBul(sayi(o.tur));
                    const secili = sayi(o.id) === kayitId;
                    return (
                      <li key={sayi(o.id)} style={{ ['--go-renk' as string]: t.renk }} className={secili ? 'secili' : ''}>
                        <button type="button" onClick={() => void oku(sayi(o.id))}
                                title={c('Bu olayı aç')}>
                          <span className="go-yil-etiket">{olayTarihi(o.tarih) || '—'}</span>
                          <span>{metin(o.ad)} <span className="sonuk">· {t.ad}{metin(o.kurum) ? ` · ${metin(o.kurum)}` : ''}</span></span>
                        </button>
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
