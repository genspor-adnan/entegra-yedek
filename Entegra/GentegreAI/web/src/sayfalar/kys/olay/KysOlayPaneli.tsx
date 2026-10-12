import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type KartMetaYaniti, type ListeSatiri } from '../../../api/sozlesme';
import { guvenli } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';
import { dofAcmaYolu } from '../../liste/kysOlayRiskAksiyonlari';

/**
 * KURUMSAL KALİTE — OLAY BİLDİRİMİ SAĞ KARTI (1060, mockup
 * Ekranlar/Kalite2/olay_bildirim.html): "tek liste + sağda kart". Seçili
 * bildirim yerinde düzenlenir; DÖF Aç kaynağı taşıyarak DÖF kartını açar,
 * ✔ Kapat durumu "Kapandı" yapar. Kayıt generic kart ucuyla (kural ve log
 * sunucuda, `kys-olay` kartı); yeni bildirim listenin "Yeni" düğmesiyle.
 */
const ALANLAR = ['tarih', 'tur', 'departmanId', 'zarar', 'anonim', 'aciklama', 'anlikMudahale', 'degerlendirmeNotu', 'durum'] as const;
type Alan = typeof ALANLAR[number];
type Deger = Record<Alan, string>;

const bos = (): Deger => Object.fromEntries(ALANLAR.map(a => [a, ''])) as Deger;
const okut = (k: Record<string, unknown>): Deger => {
  const d = bos();
  for (const a of ALANLAR) d[a] = k[a] == null ? '' : String(k[a]);
  // datetime-local "YYYY-MM-DDTHH:MM" ister; sunucu saniye / ofset döner.
  d.tarih = d.tarih.slice(0, 16);
  return d;
};

export function KysOlayPaneli({ satir, yenile }: { satir: ListeSatiri | null; yenile: () => void }) {
  const git = useNavigate();
  const { yetki } = useOturum();
  const id = satir ? Number(satir.id) : 0;
  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [d, setD] = useState<Deger>(bos);
  const [surum, setSurum] = useState<string | undefined>();
  const [duzenle, setDuzenle] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => { api.kartAlanlari('kys-olay').then(setMeta).catch(h => setHata(hataMetni(h))) }, []);
  useEffect(() => {
    setIlk(null); setHata(null);
    if (!(id > 0)) return;
    let iptal = false;
    api.kartOku('kys-olay', id).then(y => {
      if (iptal) return;
      const v = okut(y.kart);
      setIlk(v); setD(v); setSurum(y.kart.surum); setDuzenle(y.yetki.duzenle);
    }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [id]);

  if (!(id > 0)) return <div className="kys-olay-panel sonuk">{c('Bir bildirim seçin ya da ＋ Yeni ile bildirin.')}</div>;
  if (hata) return <div className="kys-olay-panel"><div className="hata-kutusu">{hata}</div></div>;
  if (!ilk || !meta) return <div className="kys-olay-panel sonuk">{c('Yükleniyor…')}</div>;

  const kodlar = (alan: string) => meta.alanlar.find(a => a.ad === alan)?.kodlar ?? {};
  const degisen = ALANLAR.filter(a => d[a] !== ilk[a]);
  const salt = !duzenle;
  const yaz = (a: Alan) => (e: { target: { value: string } }) => setD(x => ({ ...x, [a]: e.target.value }));

  const kaydet = async (ek?: Partial<Deger>) => {
    const son = { ...d, ...ek };
    const fark = ALANLAR.filter(a => son[a] !== ilk[a]);
    if (fark.length === 0) return;
    await guvenli(async () => {
      const kart: Record<string, unknown> = {};
      for (const a of fark) {
        kart[a] = a === 'anonim' ? (son.anonim === '1' ? 1 : 0)
          : ['tur', 'departmanId', 'zarar', 'durum'].includes(a) ? (son[a] ? Number(son[a]) : null)
          : son[a];
      }
      const y = await api.kartGuncelle('kys-olay', id, { surum, kart });
      const v = okut(y.kart);
      setIlk(v); setD(v); setSurum(y.kart.surum);
      yenile();
    });
  };
  const dofAc = () => git(dofAcmaYolu(2, { ...satir!, tanim: d.aciklama }));
  const secim = (a: Alan, zorunlu = true) => (
    <select value={d[a]} disabled={salt} onChange={yaz(a)}>
      {!zorunlu || !d[a] ? <option value="">—</option> : null}
      {Object.entries(kodlar(a)).map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
    </select>
  );
  const kapali = ilk.durum === '3';

  return (
    <div className="kys-olay-panel">
      <div className="kagrup">
        <h6>{String(satir?.no ?? '')}
          <span className={`rozet ${kapali ? 'gri' : ilk.durum === '2' ? 'uyari' : 'bilgi'}`}>{String(satir?.durumAdi ?? '')}</span>
        </h6>
        <div className="alan-izgara kys-olay-hdr">
          <label className="alan"><span className="etiket">{c('No')}</span><input value={String(satir?.no ?? '')} disabled /></label>
          <label className="alan"><span className="etiket">{c('Tarih')}</span>
            <input type="datetime-local" value={d.tarih} disabled={salt} onChange={yaz('tarih')} /></label>
          <label className="alan"><span className="etiket">{c('Tür')}<b className="zorunlu"> *</b></span>{secim('tur')}</label>
          <label className="alan"><span className="etiket">{c('Birim')}<b className="zorunlu"> *</b></span>{secim('departmanId')}</label>
          <label className="alan"><span className="etiket">{c('Etki')}</span>{secim('zarar')}</label>
          <label className="alan"><span className="etiket">{c('Bildiren')}</span>
            <span className="kys-olay-bildiren">
              <input type="checkbox" checked={d.anonim === '1'} disabled={salt}
                     onChange={e => setD(x => ({ ...x, anonim: e.target.checked ? '1' : '0' }))} />
              {c('Anonim')} · {d.anonim === '1' ? '—' : String(satir?.bildirenAdi ?? '') || '—'}
            </span></label>
        </div>
        <div className="kys-olay-metin">
          <label className="alan"><span className="etiket">{c('Ne oldu?')}<b className="zorunlu"> *</b></span>
            <textarea value={d.aciklama} disabled={salt} maxLength={2000} onChange={yaz('aciklama')} /></label>
          <label className="alan"><span className="etiket">{c('Hemen ne yapıldı?')}</span>
            <textarea value={d.anlikMudahale} disabled={salt} maxLength={1000} onChange={yaz('anlikMudahale')} /></label>
          <label className="alan"><span className="etiket">{c('Değerlendirme (kalite sorumlusu)')}</span>
            <textarea value={d.degerlendirmeNotu} disabled={salt} maxLength={2000} onChange={yaz('degerlendirmeNotu')} /></label>
        </div>
        <div className="kys-olay-arac">
          {!salt && <button type="button" className="d bir" disabled={degisen.length === 0} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>}
          {yetki('kys.dof', 'ekle') && <button type="button" className="d onay" onClick={dofAc}>🛠️ {c('DÖF Aç')}</button>}
          {!salt && !kapali && <button type="button" className="d" onClick={() => void kaydet({ durum: '3' })}>✔ {c('Kapat')}</button>}
          <button type="button" className="d kys-olay-sag" onClick={() => git(`/kys-olay/${id}`)}>{c('Kartı aç')}</button>
        </div>
      </div>
    </div>
  );
}
