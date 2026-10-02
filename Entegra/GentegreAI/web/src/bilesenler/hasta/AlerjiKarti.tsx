import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { KaynakArama } from '../KaynakArama';
import { guvenli, onay } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * ALERJİ KARTI — mockup `Ekranlar/Muayene/alerji_karti.html`.
 *
 * Alerji ETKEN MADDE üzerinden tutulur: marka adıyla tutmak aynı maddeyi
 * taşıyan başka markayı kaçırırdı. İlaç türünde etken ilaç kataloğundan
 * ARANIR, etken madde (ve ATC) seçimden dolar; reçetede uyarı maddeye bakar.
 *
 * SİLMEK YERİNE PASİF: geçmişte bildirilmiş alerji tıbbi kayıttır - yanlış
 * girilen kayıt "Pasif yap" ile kapatılır (pasif alerji uyarı vermez).
 */

const TURLER = [
  { kod: 1, ad: '💊 İlaç' }, { kod: 2, ad: '🥜 Gıda' }, { kod: 3, ad: '🌿 Çevresel' },
  { kod: 4, ad: '🧤 Lateks' }, { kod: 5, ad: '🩻 Kontrast' },
];
const SIDDETLER = [
  { kod: 1, ad: 'Hafif' }, { kod: 2, ad: 'Orta' }, { kod: 3, ad: 'Şiddetli' }, { kod: 4, ad: 'Anafilaksi' },
];
const KAYNAKLAR = [{ kod: 1, ad: 'Hasta beyanı' }, { kod: 2, ad: 'Hekim' }, { kod: 3, ad: 'e-Nabız' }];
/** Hızlı reaksiyon seçimi - reaksiyon metnine eklenir / çıkarılır. */
const HIZLI_REAKSIYON = ['Döküntü', 'Ürtiker', 'Anjiyoödem', 'Bronkospazm', 'Bulantı / kusma', 'Hipotansiyon'];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);

/** Reaksiyon metnini virgüllü parçalara böler (hızlı çipin açık/kapalı hâli). */
const parcalar = (s: string) => s.split(',').map(x => x.trim()).filter(Boolean);

interface Deger {
  hastaId: number; tur: number; etken: string; etkenMadde: string; reaksiyon: string;
  siddet: number; kaynak: number; dogrulandi: number; aktif: number; kayitMuayeneId: number | null;
}

export function AlerjiKarti({ id, hastaId: ilkHasta, hastaAdi: ilkHastaAdi, muayeneId, onKapat, onKaydedildi }: {
  id: number | 'yeni';
  /** Yeni kayıtta hasta (bağlamdan); verilmezse kartta seçilir. */
  hastaId?: number;
  hastaAdi?: string;
  /** Kaydı açan muayene (yeni kayıtta yazılır). */
  muayeneId?: number;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const yeni = id === 'yeni';
  const bos = (h?: number): Deger => ({
    hastaId: h ?? 0, tur: 1, etken: '', etkenMadde: '', reaksiyon: '', siddet: 2,
    kaynak: 1, dogrulandi: 0, aktif: 1, kayitMuayeneId: muayeneId ?? null,
  });
  const [d, setD] = useState<Deger>(() => bos(ilkHasta));
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [kayitId, setKayitId] = useState<number | null>(yeni ? null : id);
  const [hastaAdi, setHastaAdi] = useState(ilkHastaAdi ?? '');
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(!yeni);
  const [atc, setAtc] = useState('');
  const [oneriler, setOneriler] = useState<ListeSatiri[]>([]);
  const [aramaMetni, setAramaMetni] = useState('');
  const [ayniEtken, setAyniEtken] = useState<{ satirlar: ListeSatiri[]; toplam: number }>({ satirlar: [], toplam: 0 });
  const [digerleri, setDigerleri] = useState<ListeSatiri[]>([]);
  const [hastaSec, setHastaSec] = useState(false);
  const [kaydediyor, setKaydediyor] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  // Kayıtlı alerjiyi oku.
  useEffect(() => {
    if (yeni) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kartOku('hasta-alerji', id);
        if (iptal) return;
        const k = y.kart;
        const v: Deger = {
          hastaId: sayi(k.hastaId), tur: sayi(k.tur) || 1, etken: metin(k.etken),
          etkenMadde: metin(k.etkenMadde), reaksiyon: metin(k.reaksiyon),
          siddet: sayi(k.siddet) || 0, kaynak: sayi(k.kaynak) || 1,
          dogrulandi: sayi(k.dogrulandi), aktif: sayi(k.aktif ?? 1),
          kayitMuayeneId: k.kayitMuayeneId == null ? null : sayi(k.kayitMuayeneId),
        };
        setD(v); setIlk(v); setSurum(k.surum);
        setHastaAdi(y.kodAd?.hastaId?.[String(k.hastaId ?? '')] ?? '');
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [id, yeni]);

  // Hasta adı (bağlamdan gelmediyse) ve hastanın diğer alerjileri.
  useEffect(() => {
    if (!(d.hastaId > 0)) { setDigerleri([]); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('hasta-alerji', { sayfa: 1, boyut: 20,
          filtre: { alan: 'hastaId', op: 'esit', deger: d.hastaId } });
        if (!iptal) setDigerleri(y.satirlar.filter(x => sayi(x.id) !== kayitId));
      } catch { /* panel zorunlu değil */ }
      if (!hastaAdi) {
        try {
          const h = await api.liste('hasta', { sayfa: 1, boyut: 1,
            filtre: { alan: 'id', op: 'esit', deger: d.hastaId } });
          if (!iptal) setHastaAdi(metin(h.satirlar[0]?.unvan ?? h.satirlar[0]?.ad));
        } catch { /* ad zorunlu değil */ }
      }
    })();
    return () => { iptal = true };
    // hastaAdi bilerek bağımlılıkta değil: yalnız boşken bir kez çözülür
  }, [d.hastaId, kayitId]);

  // İLAÇ ARAMASI (tür İlaç iken): yazdıkça ilaç kataloğunda ad / etken madde.
  useEffect(() => {
    const a = aramaMetni.trim();
    if (d.tur !== 1 || a.length < 3) { setOneriler([]); return }
    let iptal = false;
    const z = setTimeout(() => {
      void api.liste('ilac', { sayfa: 1, boyut: 8, filtre: { op: 'and', kosullar: [
        { alan: 'aktif', op: 'esit', deger: 1 },
        { op: 'or', kosullar: [
          { alan: 'ad', op: 'icerir', deger: a },
          { alan: 'etkenMadde', op: 'icerir', deger: a },
        ] },
      ] } }).then(y => { if (!iptal) setOneriler(y.satirlar) }).catch(() => {});
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [aramaMetni, d.tur]);

  // AYNI ETKENİ TAŞIYAN İLAÇLAR: uyarının neyi kapsayacağı.
  useEffect(() => {
    const m = d.etkenMadde.trim();
    if (m.length < 3) { setAyniEtken({ satirlar: [], toplam: 0 }); return }
    let iptal = false;
    const z = setTimeout(() => {
      void api.liste('ilac', { sayfa: 1, boyut: 5, filtre: { op: 'and', kosullar: [
        { alan: 'aktif', op: 'esit', deger: 1 },
        { alan: 'etkenMadde', op: 'icerir', deger: m },
      ] } }).then(y => { if (!iptal) setAyniEtken({ satirlar: y.satirlar, toplam: y.toplamKayit ?? y.satirlar.length }) })
        .catch(() => {});
    }, 300);
    return () => { iptal = true; clearTimeout(z) };
  }, [d.etkenMadde]);

  const oneriSec = (r: ListeSatiri) => {
    const madde = metin(r.etkenMadde);
    // Etken madde seçildiyse (ad = madde) etkene madde yazılır, marka seçildiyse marka.
    setD(o => ({ ...o, etken: metin(r.ad), etkenMadde: madde || o.etkenMadde }));
    setAtc(metin(r.atcKod));
    setAramaMetni('');
    setOneriler([]);
  };

  const hizliDegis = (r: string) => {
    const p = parcalar(d.reaksiyon);
    const var_ = p.some(x => x.toLocaleLowerCase('tr') === r.toLocaleLowerCase('tr'));
    yaz('reaksiyon', (var_ ? p.filter(x => x.toLocaleLowerCase('tr') !== r.toLocaleLowerCase('tr')) : [...p, r]).join(', '));
  };

  const govde = (v: Deger): Record<string, unknown> => ({
    hastaId: v.hastaId, tur: v.tur, etken: v.etken.trim(), etkenMadde: v.etkenMadde.trim(),
    reaksiyon: v.reaksiyon.trim(), siddet: v.siddet || null, kaynak: v.kaynak,
    dogrulandi: v.dogrulandi, aktif: v.aktif, kayitMuayeneId: v.kayitMuayeneId,
  });

  /** Kaydeder; `sonra`: 'kapat' | 'yeni'. */
  const kaydet = (sonra: 'kapat' | 'yeni', ek?: Partial<Deger>) => guvenli(async () => {
    const v = { ...d, ...ek };
    if (!(v.hastaId > 0)) { setHata('Hasta seçilmeli.'); return }
    if (!v.etken.trim() && !v.etkenMadde.trim()) { setHata('Etken ya da etken madde girilmeli.'); return }
    setHata(null);
    setKaydediyor(true);
    try {
      if (kayitId === null) {
        await api.kartEkle('hasta-alerji', { kart: govde(v) });
      } else {
        // Yalnız DEĞİŞEN alanlar gider (değişiklik logu alan bazlı).
        const once = ilk ? govde(ilk) : {};
        const simdi = govde(v);
        const fark = Object.fromEntries(Object.entries(simdi).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0)
          await api.kartGuncelle('hasta-alerji', kayitId, { surum, kart: fark });
      }
      onKaydedildi?.();
      if (sonra === 'kapat') { onKapat(); return }
      // KAYDET VE YENİ: aynı hasta, boş form - sıradaki alerji.
      setKayitId(null); setIlk(null); setSurum(undefined); setAtc('');
      setD(bos(v.hastaId));
    } finally { setKaydediyor(false) }
  });

  const pasifYap = () => guvenli(async () => {
    if (!await onay('Alerji pasif yapılacak: reçetede uyarı vermez ama kayıt silinmez. Onaylıyor musunuz?')) return;
    await kaydet('kapat', { aktif: 0 });
  });

  const siddetAdi = (k: number) => SIDDETLER.find(s => s.kod === k)?.ad ?? '';
  const baslikEk = kayitId === null ? c('Yeni') : `#${kayitId}`;

  return (
    <>
      <Modal baslik={`⚠ ${c('Alerji')} — ${baslikEk}`} ekSinif="kart-alerji" buyutmeYok onKapat={onKapat}
        ustSerit={(
          <div className="rk-kimlik">
            <b className="rk-ad">{hastaAdi || (d.hastaId > 0 ? `#${d.hastaId}` : c('Hasta seçilmedi'))}</b>
            {(ilkHasta === undefined && kayitId === null) && (
              <button type="button" className="d" onClick={() => setHastaSec(true)}>👤 {c('Hasta seç')}</button>
            )}
            {d.kayitMuayeneId ? <span className="sonuk">{c('Muayene')} <b>#{d.kayitMuayeneId}</b>{kayitId === null ? ` ${c('içinde giriliyor')}` : ''}</span> : null}
            <span className="rk-bosluk" />
            {digerleri.filter(x => sayi(x.aktif ?? 1) === 1).slice(0, 3).map((x, i) => (
              <span key={i} className={`rozet ${sayi(x.siddet) >= 3 ? 'hata' : 'uyari'}`}>
                {c('Mevcut')}: {metin(x.etken) || metin(x.etkenMadde)}
              </span>
            ))}
            {d.aktif === 0 && <span className="rozet gri">{c('Pasif')}</span>}
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
            <button type="button" className="d teh" onClick={() => void pasifYap()}
                    title={c('Silinmez; uyarı vermez')}>⏸ {c('Pasif yap')}</button>
          )}
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="rk-govde ak-govde">
          <div className="rk-sol">
            <div className="kagrup">
              <h6>{c('Alerji')}</h6>
              <div className="ak-alanlar">
                <div className="rk-fld">
                  <label>{c('Tür')} <span className="ak-zor">*</span></label>
                  <div className="ak-seg" role="radiogroup" aria-label={c('Tür')}>
                    {TURLER.map(t => (
                      <button key={t.kod} type="button" role="radio" aria-checked={d.tur === t.kod}
                              className={d.tur === t.kod ? 'on' : ''}
                              onClick={() => yaz('tur', t.kod)}>{t.ad}</button>
                    ))}
                  </div>
                </div>

                <div className="rk-fld ak-arama">
                  <label htmlFor="ak-etken">{c('Etken (ilaç / madde / besin)')} <span className="ak-zor">*</span></label>
                  <input id="ak-etken" value={d.etken} maxLength={200}
                         placeholder={d.tur === 1 ? c('İlaç adı ya da etken madde yazın…') : ''}
                         onChange={e => { yaz('etken', e.target.value); setAramaMetni(e.target.value) }} />
                  {oneriler.length > 0 && (
                    <div className="ak-oneri" role="listbox">
                      {oneriler.map((r, i) => (
                        <button key={i} type="button" role="option" onClick={() => oneriSec(r)}>
                          <b>{metin(r.ad)}</b>
                          <span className="sonuk">{metin(r.etkenMadde)}{metin(r.atcKod) ? ` · ${metin(r.atcKod)}` : ''}</span>
                        </button>
                      ))}
                    </div>
                  )}
                </div>

                <div className="ak-iki">
                  <div className="rk-fld">
                    <label htmlFor="ak-madde">{c('Etken madde (uyarı buna göre)')}</label>
                    <input id="ak-madde" value={d.etkenMadde} maxLength={200}
                           onChange={e => { yaz('etkenMadde', e.target.value); setAtc('') }} />
                  </div>
                  <div className="rk-fld">
                    <label>{c('ATC')}</label>
                    <div className="ak-salt">{atc || <span className="sonuk">{c('ilaç seçilince dolar')}</span>}</div>
                  </div>
                </div>

                <div className="rk-fld">
                  <label htmlFor="ak-reaksiyon">{c('Reaksiyon')}</label>
                  <input id="ak-reaksiyon" value={d.reaksiyon} maxLength={200}
                         onChange={e => yaz('reaksiyon', e.target.value)} />
                  <div className="ak-hizli">
                    {HIZLI_REAKSIYON.map(r => {
                      const on = parcalar(d.reaksiyon).some(x => x.toLocaleLowerCase('tr') === r.toLocaleLowerCase('tr'));
                      return (
                        <button key={r} type="button" className={on ? 'on' : ''} aria-pressed={on}
                                onClick={() => hizliDegis(r)}>{r}</button>
                      );
                    })}
                  </div>
                </div>

                <div className="rk-fld">
                  <label>{c('Şiddet')}</label>
                  <div className="ak-seg ak-siddet" role="radiogroup" aria-label={c('Şiddet')}>
                    {SIDDETLER.map(s => (
                      <button key={s.kod} type="button" role="radio" aria-checked={d.siddet === s.kod}
                              className={`s${s.kod}${d.siddet === s.kod ? ' on' : ''}`}
                              onClick={() => yaz('siddet', s.kod)}>{s.ad}</button>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            <div className="kagrup">
              <h6>{c('Kayıt')}</h6>
              <div className="ak-alanlar">
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
                    <label>{c('Kaydı açan muayene')}</label>
                    <div className="ak-salt">{d.kayitMuayeneId ? `#${d.kayitMuayeneId}` : '—'}</div>
                  </div>
                </div>
                <div className="ak-iki">
                  <label className="ak-kutu">
                    <input type="checkbox" checked={d.dogrulandi === 1}
                           onChange={e => yaz('dogrulandi', e.target.checked ? 1 : 0)} />
                    {c('Doğrulandı')} <span className="sonuk">{c('(test / belge ile)')}</span>
                  </label>
                  <label className="ak-kutu">
                    <input type="checkbox" checked={d.aktif === 1}
                           onChange={e => yaz('aktif', e.target.checked ? 1 : 0)} />
                    {c('Aktif')} <span className="sonuk">{c('(pasif alerji uyarı vermez)')}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>

          <div className="rk-sag">
            <div className="rk-bant mavi">
              <b>{c('Bu alerji neyi etkiler?')}</b>
              <div>
                {d.etkenMadde.trim()
                  ? <><b>{d.etkenMadde}</b> {c('içeren bir ilaç reçeteye eklenince uyarı çıkar; hekim gerekçe yazarak geçebilir.')}</>
                  : c('Etken madde girilince reçetede bu maddeyi içeren ilaçlar için uyarı çıkar.')}
              </div>
              <div className="sonuk">{c('Muayene kartının üst şeridinde rozet olarak görünür.')}</div>
            </div>
            {ayniEtken.satirlar.length > 0 && (
              <div className="rk-blk">
                <h6>{c('Aynı etkeni taşıyan ilaçlar')}</h6>
                <ul className="ak-liste">
                  {ayniEtken.satirlar.map((r, i) => <li key={i}>{metin(r.ad)}</li>)}
                  {ayniEtken.toplam > ayniEtken.satirlar.length && (
                    <li className="sonuk">+ {ayniEtken.toplam - ayniEtken.satirlar.length} {c('ilaç daha')}</li>
                  )}
                </ul>
              </div>
            )}
            <div className="rk-blk">
              <h6>{c('Hastanın diğer alerjileri')}</h6>
              {digerleri.length === 0
                ? <span className="rozet olumlu">{c('Başka alerji yok')}</span>
                : (
                  <ul className="ak-liste">
                    {digerleri.map((x, i) => (
                      <li key={i} className={sayi(x.aktif ?? 1) === 1 ? '' : 'sonuk'}>
                        {sayi(x.siddet) > 0 && (
                          <span className={`rozet ${sayi(x.siddet) >= 3 ? 'hata' : sayi(x.siddet) === 2 ? 'uyari' : 'olumlu'}`}>
                            {siddetAdi(sayi(x.siddet))}
                          </span>
                        )}{' '}
                        {metin(x.etken) || metin(x.etkenMadde)}
                        {sayi(x.aktif ?? 1) === 1 ? '' : ` · ${c('pasif')}`}
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
          onSec={r => {
            setHastaSec(false);
            yaz('hastaId', sayi(r.id));
            setHastaAdi(metin(r.unvan));
          }} />
      )}
    </>
  );
}
