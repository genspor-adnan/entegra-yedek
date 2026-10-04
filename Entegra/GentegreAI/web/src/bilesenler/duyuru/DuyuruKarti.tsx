import { useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import type { DuyuruHedef, DuyuruOnem } from '../../api/uclar/duyuru';
import { Modal } from '../Modal';
import { guvenli, metinSor, onay } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { ONEM, OnemEtiketi } from './duyuruOnem';

/**
 * DUYURU YAYINLA penceresi (957, mockup Ekranlar/Duyuru/duyuru.html bölüm 2).
 *
 * Kime: şube / bölüm / rol / kişi BİRLEŞİMİ (seçilenlerden herhangi birine
 * giren herkes) ya da Herkes; kaç kişinin göreceği sunucuda sayılır. Herkese
 * ve SMS ile gönderim `duyuru.genel` ister. Metin sunucuda temizlenir.
 */
const HEDEF_IC: Record<number, string> = { 1: '🏥', 2: '🩺', 3: '👤', 4: '🙍' };
const HEDEF_AD: Record<number, string> = { 1: 'Şube', 2: 'Bölüm', 3: 'Rol', 4: 'Kişi' };

/** ISO → datetime-local (yerel). */
const yerel = (iso: string | null | undefined) => {
  if (!iso) return '';
  const d = new Date(iso); d.setMinutes(d.getMinutes() - d.getTimezoneOffset());
  return d.toISOString().slice(0, 16);
};
const isoYap = (v: string) => (v ? new Date(v).toISOString() : null);

export function DuyuruKarti({ id, onKapat, onKaydet }: { id?: number; onKapat(): void; onKaydet(): void }) {
  const { kullanici, yetki } = useOturum();
  const genel = yetki('duyuru.genel', 'ekle');
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [durum, setDurum] = useState(0);
  const [baslik, setBaslik] = useState('');
  const [onem, setOnem] = useState<DuyuruOnem>(1);
  const [herkes, setHerkes] = useState(false);
  const [hedefler, setHedefler] = useState<DuyuruHedef[]>([]);
  const [bas, setBas] = useState('');
  const [bit, setBit] = useState('');
  const [okumaOnayi, setOkumaOnayi] = useState(false);
  const [sabit, setSabit] = useState(false);
  const [eposta, setEposta] = useState(false);
  const [sms, setSms] = useState(false);
  const [adina, setAdina] = useState('');
  const [kisi, setKisi] = useState<number | null>(null);
  const [ara, setAra] = useState('');
  const [sonuc, setSonuc] = useState<DuyuruHedef[]>([]);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [yeniEk, setYeniEk] = useState<File[]>([]);
  const [ozet, setOzet] = useState('');
  const editor = useRef<HTMLDivElement>(null);
  const dosyaRef = useRef<HTMLInputElement>(null);

  // DÜZENLE: kaydı yükle.
  useEffect(() => {
    if (!id) return;
    api.duyuru(id).then(y => {
      const d = y.duyuru;
      setDurum(d.durum); setBaslik(d.baslik); setOnem(d.onem); setHerkes(d.herkes === 1);
      setHedefler(y.hedefler); setBas(yerel(d.yayinBas)); setBit(yerel(d.yayinBit));
      setOkumaOnayi(d.okumaOnayi === 1); setSabit(d.sabit === 1); setEposta(d.eposta === 1); setSms(d.sms === 1);
      setAdina(d.adina);
      if (editor.current) { editor.current.innerHTML = d.metin; setOzet(editor.current.innerText) }
    }).catch(e => setHata(hataMetni(e)));
    api.dokumanlar('duyuru', id).then(setEkler).catch(() => setEkler([]));
  }, [id]);

  // KAÇ KİŞİ: sunucu sayar (fn_duyuru_alicilari ile aynı kural).
  useEffect(() => {
    if (!herkes && hedefler.length === 0) { setKisi(0); return }
    const z = window.setTimeout(() => {
      api.duyuruHedefSay(herkes, hedefler.map(h => ({ tur: h.tur, id: h.id }))).then(y => setKisi(y.kisi)).catch(() => setKisi(null));
    }, 300);
    return () => window.clearTimeout(z);
  }, [herkes, hedefler]);

  useEffect(() => {
    if (ara.trim().length < 1) { setSonuc([]); return }
    const z = window.setTimeout(() => {
      api.duyuruHedefAra(ara.trim()).then(y => setSonuc(y.satirlar)).catch(() => setSonuc([]));
    }, 250);
    return () => window.clearTimeout(z);
  }, [ara]);

  useEffect(() => { if (onem !== 3) setSms(false) }, [onem]);

  const komut = (k: string, deger?: string) => { editor.current?.focus(); document.execCommand(k, false, deger) };
  const baglanti = async () => {
    const u = await metinSor(c('Bağlantı adresi (https://…)'), 'https://', c('Adres'));
    if (u) komut('createLink', u);
  };

  const zamanli = bas && new Date(bas).getTime() > Date.now() + 60000;

  const kaydet = async (islem: 'taslak' | 'yayinla') => {
    const metin = editor.current?.innerHTML ?? '';
    if (!baslik.trim()) { setHata(c('Başlık zorunlu.')); return }
    if (islem === 'yayinla' && !(editor.current?.innerText ?? '').trim()) { setHata(c('Duyuru metnini yazın.')); return }
    if (islem === 'yayinla' && !herkes && hedefler.length === 0) { setHata(c('Kime gideceğini seçin.')); return }
    if (islem === 'yayinla' && sms && !await onay(`${c('Kritik duyuru SMS ile')} ${kisi ?? '?'} ${c('kişiye gidecek. Gönderilsin mi?')}`)) return;
    setHata(null); setMesgul(true);
    try {
      const y = await api.duyuruKaydet({
        id, baslik: baslik.trim(), metin, onem, herkes, hedefler: hedefler.map(h => ({ tur: h.tur, id: h.id })),
        yayinBas: isoYap(bas), yayinBit: isoYap(bit), okumaOnayi, sabit, yorumAcik: false, eposta, sms,
        adina: adina.trim() || undefined, islem,
      });
      for (const f of yeniEk) await api.dokumanYukle('duyuru', y.id, f, false);
      onKaydet();
    } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };

  const sil = () => guvenli(async () => {
    if (!id || !await onay(c('Taslak silinsin mi?'), true)) return;
    await api.duyuruSil(id); onKaydet();
  });

  const alt = (
    <>
      <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydet('yayinla')}>
        {zamanli ? `🕒 ${c('Zamanla')}` : `📣 ${durum === 1 ? c('Güncelle') : c('Yayınla')}`}</button>
      {durum === 0 && <button type="button" className="d" disabled={mesgul} onClick={() => void kaydet('taslak')}>💾 {c('Taslak')}</button>}
      {id && durum === 0 && <button type="button" className="d tl-tehlike" onClick={() => void sil()}>🗑 {c('Sil')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`📣 ${id ? c('Duyuru') : c('Yeni duyuru')}`} ustBilgi={adina || kullanici?.ad} buyutmeYok alt={alt}
           onKapat={onKapat} ekSinif="dy-kart">
      <div className="dy-govde">
        <div className="tl-form">
          {hata && <div className="hata-kutusu">{hata}</div>}
          {durum === 1 && <div className="tl-bilgi">ℹ {c('Yayındaki duyuruyu güncellemek onu herkeste yeniden "okunmamış" yapar; okuma onayları silinmez.')}</div>}
          <label className="rk-fld"><span className="ck-etiket">{c('Başlık')} <b className="ak-zor">*</b></span>
            <input value={baslik} maxLength={200} onChange={e => setBaslik(e.target.value)} /></label>

          <div className="rk-fld"><span className="ck-etiket">{c('Metin')} <b className="ak-zor">*</b></span>
            <div className="dy-editor">
              <div className="dy-arac">
                <button type="button" title={c('Kalın')} onMouseDown={e => { e.preventDefault(); komut('bold') }}><b>B</b></button>
                <button type="button" title={c('İtalik')} onMouseDown={e => { e.preventDefault(); komut('italic') }}><i>I</i></button>
                <button type="button" title={c('Altı çizili')} onMouseDown={e => { e.preventDefault(); komut('underline') }}><u>U</u></button>
                <button type="button" title={c('Madde')} onMouseDown={e => { e.preventDefault(); komut('insertUnorderedList') }}>•≡</button>
                <button type="button" title={c('Numaralı')} onMouseDown={e => { e.preventDefault(); komut('insertOrderedList') }}>1≡</button>
                <button type="button" title={c('Bağlantı')} onMouseDown={e => { e.preventDefault(); void baglanti() }}>🔗</button>
                <button type="button" title={c('Ek dosya')} onMouseDown={e => { e.preventDefault(); dosyaRef.current?.click() }}>📎</button>
              </div>
              <div ref={editor} className="dy-icerik" contentEditable suppressContentEditableWarning
                   onInput={e => setOzet((e.target as HTMLDivElement).innerText)} />
            </div></div>

          <div className="rk-fld"><span className="ck-etiket">{c('Önem')}</span>
            <div className="dy-onemsec">
              {([1, 2, 3] as DuyuruOnem[]).map(o => (
                <button key={o} type="button" className={onem === o ? 'dy-on' : ''} onClick={() => setOnem(o)}>
                  <b>{ONEM[o].ic} {c(ONEM[o].ad)}</b>
                  <span>{o === 1 ? c('zilde listelenir') : o === 2 ? c('+ anlık bildirim') : c('+ girişte tam ekran, SMS seçilebilir')}</span></button>
              ))}
            </div></div>

          <div className="rk-fld tl-db"><span className="ck-etiket">{c('Kime')} <b className="ak-zor">*</b></span>
            <div className="dy-hedef">
              {genel && (
                <button type="button" className={`dy-herkes${herkes ? ' dy-on' : ''}`} onClick={() => setHerkes(h => !h)}>🌐 {c('Herkes')}</button>
              )}
              {!herkes && hedefler.map(h => (
                <span key={`${h.tur}-${h.id}`} className="dy-cip">{HEDEF_IC[h.tur]} {h.tur === 3 ? `${c('Rol')}: ` : ''}{h.ad}
                  <button type="button" onClick={() => setHedefler(l => l.filter(x => !(x.tur === h.tur && x.id === h.id)))}>✕</button></span>
              ))}
              {!herkes && <input className="dy-hedef-ara" value={ara} onChange={e => setAra(e.target.value)} placeholder={`＋ ${c('şube / bölüm / rol / kişi')}`} />}
            </div>
            {sonuc.length > 0 && !herkes && (
              <div className="tl-db-liste">
                {sonuc.filter(s => !hedefler.some(h => h.tur === s.tur && h.id === s.id)).map(s => (
                  <button key={`${s.tur}-${s.id}`} type="button" onClick={() => { setHedefler(l => [...l, s]); setAra(''); setSonuc([]) }}>
                    {HEDEF_IC[s.tur]} <b>{s.ad}</b> <small>{c(HEDEF_AD[s.tur])}</small></button>
                ))}
              </div>
            )}
            <span className="sonuk tl-kucuk">{c('seçilenlerden herhangi birine giren herkes')} · <b>{kisi ?? '…'} {c('kişi görecek')}</b></span>
          </div>

          <div className="tl-iki">
            <div className="rk-fld"><span className="ck-etiket">{c('Yayın')}</span>
              <div className="ck-ikili">
                <input type="datetime-local" value={bas} onChange={e => setBas(e.target.value)} title={c('Boş = şimdi')} />
                <span className="sonuk">–</span>
                <input type="datetime-local" value={bit} min={bas || undefined} onChange={e => setBit(e.target.value)} />
              </div>
              <span className="sonuk tl-kucuk">{c('başlangıç boşsa hemen; bitişte zilden kalkar, listede durur')}</span></div>
            <div className="rk-fld"><span className="ck-etiket">{c('Seçenekler')}</span>
              <label className="dy-sec"><input type="checkbox" checked={okumaOnayi} onChange={e => setOkumaOnayi(e.target.checked)} /> {c('Okuma onayı iste ("✔ Okudum")')}</label>
              <label className="dy-sec"><input type="checkbox" checked={sabit} onChange={e => setSabit(e.target.checked)} /> 📌 {c('Sabitle (bitişe kadar en üstte)')}</label></div>
          </div>

          <div className="tl-iki">
            <div className="rk-fld"><span className="ck-etiket">{c('Ek')}</span>
              <div className="tl-ekler">
                {ekler.map(f => (
                  <span key={f.id} className="tl-ek">📎 {f.ad}
                    <button type="button" className="cl-bag sonuk" onClick={() => void guvenli(async () => { setEkler(await api.dokumanSil('duyuru', id!, f.id)) })}> ✕</button></span>
                ))}
                {yeniEk.map((f, i) => (
                  <span key={`y${i}`} className="tl-ek">📎 {f.name}
                    <button type="button" className="cl-bag sonuk" onClick={() => setYeniEk(l => l.filter((_, j) => j !== i))}> ✕</button></span>
                ))}
                <button type="button" className="tl-ek" onClick={() => dosyaRef.current?.click()}>＋</button>
                <input ref={dosyaRef} type="file" multiple hidden
                       onChange={e => { const l = Array.from(e.target.files ?? []); setYeniEk(x => [...x, ...l]); e.target.value = '' }} />
              </div></div>
            <div className="rk-fld"><span className="ck-etiket">{c('Ayrıca gönder')}</span>
              <label className="dy-sec"><input type="checkbox" checked={eposta} onChange={e => setEposta(e.target.checked)} /> {c('E-posta')}</label>
              <label className="dy-sec" title={onem !== 3 ? c('Yalnız Kritik duyuruda') : !genel ? c('Yetkiniz yok') : undefined}>
                <input type="checkbox" checked={sms} disabled={onem !== 3 || !genel} onChange={e => setSms(e.target.checked)} /> {c('SMS')} <span className="sonuk">({c('yalnız Kritik')})</span></label></div>
          </div>

          <label className="rk-fld" style={{ maxWidth: 320 }}><span className="ck-etiket">{c('Kimin adına')}</span>
            <input value={adina} maxLength={120} onChange={e => setAdina(e.target.value)} placeholder={kullanici?.ad ?? ''} /></label>
        </div>

        <div className="dy-sag">
          <div className="tl-grp">
            <h6>{c('Önizleme — zilde böyle görünür')}</h6>
            <div className="tl-ic">
              <ul className="dy-liste dy-onizle">
                <li className={`dy-yeni${onem === 3 ? ' dy-kritik' : ''}${sabit ? ' dy-sabit' : ''}`}>
                  <span className="dy-ic">{sabit ? '📌' : ONEM[onem].ic}</span>
                  <span><b>{baslik || c('Başlık')}</b> <OnemEtiketi onem={onem} />
                    <small>{adina || kullanici?.ad} · {zamanli ? new Date(bas).toLocaleString('tr-TR') : c('şimdi')} · {herkes ? c('herkes') : hedefler.map(h => h.ad).join(', ') || '—'}{ekler.length + yeniEk.length ? ` · 📎 ${ekler.length + yeniEk.length}` : ''}</small>
                    {ozet && <span className="dy-oz">{ozet.slice(0, 160)}</span>}</span>
                  {okumaOnayi ? <span className="d tl-ok dy-sahte">✔ {c('Okudum')}</span> : <span />}
                </li>
              </ul>
            </div>
          </div>
          <div className="tl-bilgi">ℹ <b>{c('Kim yayınlar?')}</b> {c('Duyuru yetkisi olan. "Herkes" ve Kritik + SMS yalnız genel duyuru yetkisiyle.')}</div>
          {sms && <div className="tl-uyari">⚠ {c('Kritik + SMS')} {kisi ?? '?'} {c('kişiye gider. Gönderim öncesi bir kez daha sorulur.')}</div>}
        </div>
      </div>
    </Modal>
  );
}
