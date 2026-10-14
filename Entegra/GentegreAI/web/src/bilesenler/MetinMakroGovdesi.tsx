import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import type { KartAlanMeta } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import type { Deger } from './kartAlanCizim';

/**
 * METİN MAKROSU KARTI GÖVDESİ (kullanıcı 14.10.2026, mockup Ekranlar/Muayene/metin_makrosu_karti.html).
 *
 * Kart genel kart motorunda (kaydet / yetki / log aynen); bu bileşen yalnız sekmenin içini
 * mockup düzeninde çizer: Tanım (kısayol, açıklama, alan, yer tutucu çipleri + metin) ·
 * Kapsam (kurum / bölüm / kişisel) · sağda canlı önizleme, çakışma, kullanım, nasıl kullanılır.
 *
 * YER TUTUCULAR muayenede makro listesi verilirken SUNUCUDA doldurulur
 * (MuayeneSablonUclari tercihler); `{|}` imlecin duracağı yerdir (muayeneMakro.ts).
 * KAPSAM ayrı alan değil: hekim_id doluysa kişisel, bolum_id doluysa bölüm, ikisi boşsa
 * kurum geneli. Muayenede aynı kısayolun en yakını açılır: kişisel → bölüm → kurum.
 */
export const MAKRO_YER_TUTUCULAR: { kod: string; ornek: string; ipucu: string }[] = [
  { kod: '{hasta_adi}', ornek: 'Ramiz Ongun', ipucu: 'Hastanın adı soyadı' },
  { kod: '{yas}', ornek: '74', ipucu: 'Yaş (yıl)' },
  { kod: '{cinsiyet}', ornek: 'erkek', ipucu: 'erkek / kadın' },
  { kod: '{tarih}', ornek: '14.10.2026', ipucu: 'Muayene tarihi' },
  { kod: '{hekim}', ornek: 'Dr. Barış Güneş', ipucu: 'Muayene eden hekim' },
  { kod: '{bolum}', ornek: 'Kardiyoloji', ipucu: 'Muayene bölümü' },
  { kod: '{son_muayene}', ornek: '19.09.2026 (İç Hastalıkları)', ipucu: 'Hastanın bir önceki muayenesi' },
];

const ALANLAR: [string, string][] = [
  ['', 'Tüm alanlar'], ['sikayet', 'Şikâyet'], ['hikaye', 'Hikâye'],
  ['bulguOzet', 'Muayene bulguları'], ['karar', 'Değerlendirme / Sonuç'],
];

type Kapsam = 'kurum' | 'bolum' | 'kisi';
const metin = (v: unknown) => (v == null ? '' : String(v));

export function MetinMakroGovdesi({ id, deger, alanDegistir }: {
  id: number | 'yeni';
  deger: Record<string, Deger>;
  alanDegistir(ad: string, v: Deger): void;
}) {
  const [meta, setMeta] = useState<KartAlanMeta[] | null>(null);
  const [cakisma, setCakisma] = useState<{ kapsam: string; alan: string; metin: string; kaynak: string }[]>([]);
  const metinRef = useRef<HTMLTextAreaElement | null>(null);
  // KAPSAM SEÇİMİ: değer alanlardan türetilir; "Bölüm" seçilip henüz bölüm girilmediyse de seçili kalsın.
  const [secim, setSecim] = useState<Kapsam | null>(null);
  const kapsam: Kapsam = secim ?? (metin(deger.hekimId) ? 'kisi' : metin(deger.bolumId) ? 'bolum' : 'kurum');

  useEffect(() => { void api.kartAlanlari('metin-makro').then(m => setMeta(m.alanlar)).catch(() => setMeta([])) }, []);
  const kisayol = metin(deger.kisayol).trim();
  useEffect(() => {
    if (!kisayol) { setCakisma([]); return }
    const t = setTimeout(() => {
      void api.makroCakisma(kisayol, typeof id === 'number' ? id : 0)
        .then(setCakisma).catch(() => setCakisma([]));
    }, 300);
    return () => clearTimeout(t);
  }, [kisayol, id]);

  const kodlar = (ad: string) => meta?.find(a => a.ad === ad)?.kodlar ?? {};
  const alan = metin(deger.alan);
  const govde = metin(deger.metin);
  const aktif = Number(deger.durum ?? 1) === 1 || deger.durum === true;

  const yerTutucuEkle = (kod: string) => {
    const t = metinRef.current;
    const i = t?.selectionStart ?? govde.length, j = t?.selectionEnd ?? i;
    alanDegistir('metin', govde.slice(0, i) + kod + govde.slice(j));
    setTimeout(() => { if (t) { t.focus(); t.selectionStart = t.selectionEnd = i + kod.length } }, 0);
  };
  const kapsamSec = (k: Kapsam) => {
    setSecim(k);
    if (k !== 'kisi') alanDegistir('hekimId', '');
    if (k !== 'bolum') alanDegistir('bolumId', '');
  };

  // ÖNİZLEME: yer tutucular örnek hastayla (sarı), {|} yanıp sönen imleç.
  const onizleme = () => {
    const parcalar: React.ReactNode[] = [];
    const desen = /(\{[a-z_]+\}|\{\|\})/g;
    let son = 0, m: RegExpExecArray | null, n = 0;
    while ((m = desen.exec(govde))) {
      parcalar.push(govde.slice(son, m.index));
      const yt = MAKRO_YER_TUTUCULAR.find(y => y.kod === m![0]);
      parcalar.push(m[0] === '{|}' ? <span key={n++} className="mk-imlec" />
        : yt ? <span key={n++} className="mk-yt">{yt.ornek}</span> : m[0]);
      son = m.index + m[0].length;
    }
    parcalar.push(govde.slice(son));
    return parcalar;
  };

  const kapsamAdi = kapsam === 'kisi' ? `${c('Kişisel')} · ${kodlar('hekimId')[metin(deger.hekimId)] ?? '—'}`
    : kapsam === 'bolum' ? `${c('Bölüm')} · ${kodlar('bolumId')[metin(deger.bolumId)] ?? '—'}` : c('Kurum geneli');

  return (
    <div className="mk">
      <div className="mk-kimlik">
        <span className="mk-kisayol">{kisayol || '.?'}</span>
        <span>{metin(deger.aciklama)}</span>
        <span className={`rozet ${aktif ? 'olumlu' : 'gri'}`}>{aktif ? c('Aktif') : c('Pasif')}</span>
        <span className="rozet mavi">{kapsamAdi}</span>
        <span className="rozet">{c(ALANLAR.find(a => a[0] === alan)?.[1] ?? 'Tüm alanlar')}</span>
        <span className="not mk-sag">{Number(deger.kullanim ?? 0)} {c('kullanım')}</span>
      </div>

      <div className="mk-gvd">
        <div>
          <div className="kagrup">
            <h6>{c('Tanım')}</h6>
            <div className="ic mk-ic">
              <div className="mk-iki">
                <label className="mk-fld"><span>{c('Kısayol')} <b className="zorunlu">*</b></span>
                  <input className="mk-mono" maxLength={20} value={metin(deger.kisayol)} placeholder=".rut"
                         onChange={e => alanDegistir('kisayol', e.target.value)} /></label>
                <label className="mk-fld"><span>{c('Açıklama')}</span>
                  <input maxLength={200} value={metin(deger.aciklama)} onChange={e => alanDegistir('aciklama', e.target.value)} /></label>
              </div>
              <div className="mk-fld"><span>{c('Hangi alanda açılır')}</span>
                <div className="mk-seg">
                  {ALANLAR.map(([k, ad]) => (
                    <button key={k} type="button" className={alan === k ? 'on' : ''} onClick={() => alanDegistir('alan', k)}>{c(ad)}</button>
                  ))}
                </div>
                <div className="not">{c('Aynı kısayol farklı alanda farklı metin açabilir.')}</div>
              </div>
              <div className="mk-fld"><span>{c('Metin')} <b className="zorunlu">*</b> <span className="not">· {c('yer tutucu eklemek için çipe tıklayın')}</span></span>
                <div className="mk-cipler">
                  {MAKRO_YER_TUTUCULAR.map(y => (
                    <button key={y.kod} type="button" className="mk-cip" title={c(y.ipucu)} onClick={() => yerTutucuEkle(y.kod)}>{y.kod}</button>
                  ))}
                  <button type="button" className="mk-cip" title={c('Makro açılınca imleç buraya gelir')} onClick={() => yerTutucuEkle('{|}')}>{'{|}'} {c('imleç')}</button>
                </div>
                <textarea ref={metinRef} rows={7} value={govde} onChange={e => alanDegistir('metin', e.target.value)} />
                <div className="not">{govde.length} / 4000 {c('karakter')}</div>
              </div>
              <label className="mk-aktif"><input type="checkbox" checked={aktif} onChange={e => alanDegistir('durum', e.target.checked ? 1 : 0)} /> {c('Aktif')}</label>
            </div>
          </div>

          <div className="kagrup">
            <h6>{c('Kapsam')} <span className="not mk-sag">{c('kim kullanır')}</span></h6>
            <div className="ic mk-ic">
              <div className="mk-seg">
                <button type="button" className={kapsam === 'kurum' ? 'on' : ''} onClick={() => kapsamSec('kurum')}>🏥 {c('Kurum geneli')}</button>
                <button type="button" className={kapsam === 'bolum' ? 'on' : ''} onClick={() => kapsamSec('bolum')}>🏷 {c('Bölüm')}</button>
                <button type="button" className={kapsam === 'kisi' ? 'on' : ''} onClick={() => kapsamSec('kisi')}>👤 {c('Kişisel (hekim)')}</button>
              </div>
              <div className="mk-iki">
                <label className={`mk-fld${kapsam === 'bolum' ? '' : ' mk-soluk'}`}><span>{c('Bölüm (branş)')}</span>
                  <select disabled={kapsam !== 'bolum'} value={metin(deger.bolumId)} onChange={e => alanDegistir('bolumId', e.target.value)}>
                    <option value="">—</option>
                    {Object.entries(kodlar('bolumId')).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                  </select></label>
                <label className={`mk-fld${kapsam === 'kisi' ? '' : ' mk-soluk'}`}><span>{c('Hekim')}</span>
                  <select disabled={kapsam !== 'kisi'} value={metin(deger.hekimId)} onChange={e => alanDegistir('hekimId', e.target.value)}>
                    <option value="">—</option>
                    {Object.entries(kodlar('hekimId')).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                  </select></label>
              </div>
              <div className="mk-bant">{c('Aynı kısayol birden çok kapsamda tanımlıysa kişisel → bölüm → kurum sırasıyla en yakın olan açılır.')}</div>
            </div>
          </div>
        </div>

        <div className="mk-yan">
          <div className="kagrup">
            <h6>👁 {c('Önizleme')} <span className="not mk-sag">{c('örnek hasta ile')}</span></h6>
            <div className="ic">
              <div className="not">{alan ? `${c(ALANLAR.find(a => a[0] === alan)?.[1] ?? '')} ${c('alanında')}` : c('Her metin alanında')} <b>{kisayol || '.?'}</b> + {c('boşluk')}:</div>
              <div className="mk-onizleme">{govde ? onizleme() : <span className="not">{c('Metin yazın.')}</span>}</div>
              <div className="not">{c('Sarı: yer tutucudan gelen değer · imleç makrodan sonra burada durur.')}</div>
            </div>
          </div>

          <div className="kagrup">
            <h6>⚠ {c('Çakışma')}</h6>
            <div className="ic">
              {cakisma.length === 0
                ? <div className="not">{kisayol ? c('Bu kısayol başka bir makroda yok.') : c('Kısayol yazın.')}</div>
                : cakisma.map((k, i) => (
                    <div key={i} className="mk-bant sari"><b>{kisayol}</b> {k.kaynak === 's' ? c('şablonda') : ''} · {k.kapsam}
                      {k.alan ? ` · ${c(ALANLAR.find(a => a[0] === k.alan)?.[1] ?? k.alan)}` : ` · ${c('Tüm alanlar')}`}
                      <div className="not">{k.metin.slice(0, 120)}{k.metin.length > 120 ? '…' : ''}</div></div>
                  ))}
            </div>
          </div>

          <div className="kagrup">
            <h6>📊 {c('Kullanım')}</h6>
            <div className="ic"><div className="mk-sayi"><b>{Number(deger.kullanim ?? 0)}</b> {c('kez muayenede açıldı')}</div></div>
          </div>

          <div className="kagrup">
            <h6>💡 {c('Nasıl kullanılır')}</h6>
            <div className="ic not" style={{ lineHeight: 1.6 }}>
              {c('Muayenede metin alanına kısayolu yazıp boşluğa basın ya da alanın altındaki kısayol çipine tıklayın.')}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
