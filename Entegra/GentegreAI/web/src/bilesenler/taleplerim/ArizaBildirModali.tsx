import { useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ArizaBenzer, ArizaDemirbas, ArizaSecenekleri } from '../../api/uclar/ariza';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { talepleriYenile } from './useTaleplerimOzeti';

/**
 * ARIZA BİLDİR penceresi (954, mockup Ekranlar/Taleplerim/ariza_bildir.html).
 *
 * Kişi EKİP SEÇMEZ: kategori seçer, sunucu yönlendirir (pencere yalnız
 * "iletilecek ekip"i gösterir). Demirbaş biliniyorsa aranır / okutulur,
 * konum ondan dolar. Aynı cihaz / konumda açık arıza varsa ÖNCE o gösterilir:
 * "Ben de bildiriyorum" ikinci kayıt açmaz, mevcut kayda takipçi ekler.
 */
const KAT_IKON: Record<number, [string, string]> = {
  1: ['🩺', 'EKG, monitör, pompa'], 2: ['❄️', 'ısıtma, havalandırma'], 3: ['⚡', 'priz, ışık, su'],
  4: ['💻', 'PC, yazıcı, ağ'], 5: ['🪑', 'masa, sedye, dolap'], 6: ['🚪', 'kilit, cam, duvar'],
  7: ['🧹', 'dökülme, koku'], 8: ['🛡', 'kamera, kartlı geçiş'], 9: ['💬', 'listede yoksa'],
};

export function ArizaBildirModali({ onKapat }: { onKapat(): void }) {
  const { kullanici } = useOturum();
  const [sec, setSec] = useState<ArizaSecenekleri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [kategori, setKategori] = useState(0);
  const [demirbas, setDemirbas] = useState<ArizaDemirbas | null>(null);
  const [ara, setAra] = useState('');
  const [sonuc, setSonuc] = useState<ArizaDemirbas[]>([]);
  const [konum, setKonum] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [oncelik, setOncelik] = useState(2);
  const [telefon, setTelefon] = useState('');
  const [dosyalar, setDosyalar] = useState<File[]>([]);
  const [benzer, setBenzer] = useState<ArizaBenzer[]>([]);
  const araRef = useRef<HTMLInputElement>(null);
  const dosyaRef = useRef<HTMLInputElement>(null);

  useEffect(() => { api.arizaSecenekler().then(setSec).catch(h => setHata(hataMetni(h))) }, []);

  // DEMİRBAŞ ARAMA: 300 ms bekleyip sor - okutucu bir anda yazar, elle yazan harf harf.
  useEffect(() => {
    if (demirbas || ara.trim().length < 2) { setSonuc([]); return }
    const z = window.setTimeout(() => {
      api.arizaDemirbasAra(ara.trim()).then(y => setSonuc(y.satirlar)).catch(() => setSonuc([]));
    }, 300);
    return () => window.clearTimeout(z);
  }, [ara, demirbas]);

  // BENZER AÇIK ARIZA: demirbaş ya da konum + kategori değişince.
  useEffect(() => {
    if (!demirbas && !(kategori && konum.trim())) { setBenzer([]); return }
    const z = window.setTimeout(() => {
      api.arizaBenzer({ demirbasId: demirbas?.id, kategori: kategori || undefined, konum: konum.trim() || undefined })
        .then(y => setBenzer(y.satirlar)).catch(() => setBenzer([]));
    }, 400);
    return () => window.clearTimeout(z);
  }, [demirbas, kategori, konum]);

  const ekip = sec?.ekipler?.find(e => e.kategori === kategori)?.ad;
  const acil = oncelik === 4;

  const demirbasSec = (d: ArizaDemirbas) => {
    setDemirbas(d); setAra(''); setSonuc([]);
    if (d.konum) setKonum(d.konum);
  };

  const benDe = async (b: ArizaBenzer) => {
    setMesgul(true);
    try {
      const y = await api.arizaBenDe(b.id, aciklama.trim() || undefined);
      talepleriYenile();
      onKapat();
      void mesaj(`${y.mesaj} (${b.talepNo})`);
    } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };

  const gonder = async () => {
    if (!kategori) { setHata(c('Ne arızalı? Bir kategori seçin.')); return }
    if (!konum.trim()) { setHata(c('Konumu yazın (ya da cihazı seçin).')); return }
    if (!aciklama.trim()) { setHata(c('Ne olduğunu kısaca yazın.')); return }
    setHata(null); setMesgul(true);
    try {
      const y = await api.arizaTalepAc({
        kategori, aciklama: aciklama.trim(), konum: konum.trim(), oncelik,
        demirbasId: demirbas?.id ?? null, telefon: telefon.trim() || undefined,
      });
      // FOTOĞRAF kayıttan sonra: yüklenemezse kayıt durur, kişiye söylenir.
      const yuklenemeyen: string[] = [];
      for (const f of dosyalar) {
        try { await api.dokumanYukle('ariza', y.id, f, false) } catch { yuklenemeyen.push(f.name) }
      }
      talepleriYenile();
      onKapat();
      if (yuklenemeyen.length)
        void mesaj(`${y.mesaj}\n\n${c('Yüklenemeyen dosya')}: ${yuklenemeyen.join(', ')}`);
    } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };

  const alt = (
    <>
      <button type="button" className="d bir" disabled={mesgul} onClick={() => void gonder()}>📨 {c('Gönder')}</button>
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`🔧 ${c('Arıza bildir')}`} ustBilgi={kullanici?.ad} buyutmeYok alt={alt} onKapat={onKapat} ekSinif="tl-ariza-win">
      <div className="tl-form">
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="rk-fld"><span className="ck-etiket">{c('Ne arızalı?')} <b className="ak-zor">*</b></span>
          <div className="tl-kat">
            {(sec?.kategoriler ?? []).map(k => (
              <button key={k.deger} type="button" className={kategori === k.deger ? 'tl-kat-on' : ''} onClick={() => setKategori(k.deger)}>
                <b>{KAT_IKON[k.deger]?.[0] ?? '🔧'} {k.ad}</b><span>{KAT_IKON[k.deger]?.[1] ?? ''}</span></button>
            ))}
          </div>
          {ekip && <span className="tl-ekip">↳ {c('İletilecek ekip')}: <b>{ekip}</b> · {c('kategoriye göre kendiliğinden')}</span>}
        </div>

        <div className="tl-iki">
          <div className="rk-fld tl-db"><span className="ck-etiket">{c('Cihaz / demirbaş')} <span className="sonuk">({c('biliyorsan')})</span></span>
            {demirbas ? (
              <div className="ck-ikili"><span className="tl-db-sec">▦ <b>{demirbas.kod}</b> · {demirbas.ad}</span>
                <button type="button" className="cl-bag sonuk" title={c('Kaldır')} onClick={() => { setDemirbas(null); setTimeout(() => araRef.current?.focus(), 0) }}>✕</button></div>
            ) : (
              <input ref={araRef} value={ara} onChange={e => setAra(e.target.value)}
                     placeholder={`▦ ${c('etiketi okut ya da kod / ad yaz')}`} />
            )}
            {sonuc.length > 0 && (
              <div className="tl-db-liste">
                {sonuc.map(d => (
                  <button key={d.id} type="button" onClick={() => demirbasSec(d)}>
                    <b>{d.kod}</b> {d.ad}{d.konum && <small>{d.konum}</small>}</button>
                ))}
              </div>
            )}
          </div>
          <label className="rk-fld"><span className="ck-etiket">{c('Konum')} <b className="ak-zor">*</b></span>
            <input value={konum} onChange={e => setKonum(e.target.value)} maxLength={150}
                   placeholder={c('ör. Kardiyoloji · Poliklinik 3')} />
            <span className="sonuk tl-kucuk">{c('cihaz seçilince yerinden dolar')}</span></label>
        </div>

        {benzer.length > 0 && (
          <div className="tl-benzer">⚠ <b>{demirbas ? c('Bu cihaz için açık bir arıza var') : c('Bu konumda aynı türde açık arıza var')}</b> — {c('aynı arızaysa yeni kayıt açmak yerine takip edin')}:
            {benzer.map(b => (
              <div key={b.id} className="tl-benzer-sat">
                <span className="tl-tur tl-t-ariza">🧰 {b.talepNo}</span>
                <span className="tl-benzer-ac">{b.aciklama}{b.sorumluAdi ? ` · ${b.sorumluAdi}` : ''} · <b>{b.durumAdi}</b></span>
                {b.benimki
                  ? <span className="sonuk">{c('zaten takibinizde')}</span>
                  : <button type="button" className="d" disabled={mesgul} onClick={() => void benDe(b)}>＋ {c('Ben de bildiriyorum')}</button>}
              </div>
            ))}
          </div>
        )}

        <label className="rk-fld"><span className="ck-etiket">{c('Ne oluyor?')} <b className="ak-zor">*</b></span>
          <textarea rows={3} value={aciklama} onChange={e => setAciklama(e.target.value)} maxLength={1000} /></label>

        <div className="tl-iki">
          <div className="rk-fld"><span className="ck-etiket">{c('Öncelik')}</span>
            <div className="ck-cipler">
              {(sec?.oncelikler ?? []).map(o => (
                <button key={o.deger} type="button" className={`ck-cip${oncelik === o.deger ? ' on' : ''}${o.deger === 4 ? ' tl-acil' : ''}`}
                        onClick={() => setOncelik(o.deger)}>{o.deger === 4 ? '🚨 ' : ''}{o.ad}</button>
              ))}
            </div>
            <span className="sonuk tl-kucuk">{c('Acil = hasta güvenliği / bölüm çalışamıyor')}</span></div>
          <div className="rk-fld"><span className="ck-etiket">{c('Fotoğraf / video')}</span>
            <div className="tl-foto">
              {dosyalar.map((f, i) => (
                <span key={i} className="tl-foto-kare dolu" title={f.name}>{f.name.slice(0, 10)}
                  <button type="button" onClick={() => setDosyalar(l => l.filter((_, j) => j !== i))}>✕</button></span>
              ))}
              <button type="button" className="tl-foto-kare" onClick={() => dosyaRef.current?.click()}>＋</button>
              <input ref={dosyaRef} type="file" accept="image/*,video/*" multiple capture="environment" hidden
                     onChange={e => { const l = Array.from(e.target.files ?? []); setDosyalar(d => [...d, ...l]); e.target.value = '' }} />
              <span className="sonuk tl-kucuk">{c('telefondan çek ya da seç')}</span>
            </div></div>
        </div>

        <label className="rk-fld" style={{ maxWidth: 240 }}><span className="ck-etiket">{c('Ulaşılacak telefon')}</span>
          <input value={telefon} onChange={e => setTelefon(e.target.value)} maxLength={40} placeholder={c('ör. dahili 4123')} /></label>

        {acil && (
          <div className="tl-uyari tl-acil-uyari">🚨 <b>{c('Acil seçildi')}</b> — {c('kayıt açılır ve ekibe anında SMS / e-posta gider.')}
            {' '}{c('Hasta güvenliği söz konusuysa ayrıca telefonla arayın.')}</div>
        )}
      </div>
    </Modal>
  );
}
