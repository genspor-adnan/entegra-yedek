import { useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { Modal } from './Modal';
import { guvenli, mesaj } from './mesaj';

/**
 * MUAYENE RAPOR EKLE (kullanici: "eklerken direkt modal açılsın ön bilgilerle,
 * diğer kısımları doldurayım ve kaydedeyim"). Tür şablonu + başlangıç bugün
 * ön dolu gelir; hekim gün/açıklama/ICD'yi doldurup kaydeder. Kayıt TASLAK
 * rapor açar (grid'de belirir, e-İmzala ile onaylanır).
 */
const TURLER = [
  { k: 1, ad: 'İstirahat' }, { k: 2, ad: 'Sağlık durumu' },
  { k: 3, ad: 'İlaç kullanım (SUT)' }, { k: 4, ad: 'İş göremezlik' },
];
const ALT_TURLER = [
  { k: 0, ad: '—' }, { k: 1, ad: 'İş göremezlik' }, { k: 2, ad: 'Refakat' },
  { k: 3, ad: 'Doğum öncesi' }, { k: 4, ad: 'Doğum sonrası' }, { k: 5, ad: 'Diğer' },
];

const bugun = () => new Date().toISOString().slice(0, 10);

export function MuayeneRaporModal({ muayeneId, ilkTur, onKapat, onKaydedildi }: {
  muayeneId: number;
  ilkTur: number;
  onKapat(): void;
  onKaydedildi(): void;
}) {
  const [tur, setTur] = useState(ilkTur);
  const [altTur, setAltTur] = useState(0);
  const [baslangic, setBaslangic] = useState(bugun());
  const [gun, setGun] = useState(1);
  const [aciklama, setAciklama] = useState('');
  const [icdKod, setIcdKod] = useState('');
  const [mesgul, setMesgul] = useState(false);

  // Bitiş = başlangıç + gün - 1 (istirahat başlangıç günü dâhil).
  const bitis = useMemo(() => {
    if (!baslangic || gun <= 0) return '';
    const d = new Date(baslangic + 'T00:00:00');
    d.setDate(d.getDate() + gun - 1);
    return d.toISOString().slice(0, 10);
  }, [baslangic, gun]);

  const kaydet = async () => {
    setMesgul(true);
    await guvenli(async () => {
      const y = await api.muayeneRaporEkle(muayeneId, {
        tur, altTur, baslangic, gun, bitis: bitis || undefined,
        aciklama: aciklama.trim(), icdKod: icdKod.trim(),
      });
      mesaj(y.mesaj);
      onKaydedildi();
      onKapat();
    });
    setMesgul(false);
  };

  const kutu: React.CSSProperties = { padding: '7px 9px', fontSize: 14,
    border: '1px solid #cbd5e0', borderRadius: 6, width: '100%' };
  const etiket: React.CSSProperties = { fontSize: 12, fontWeight: 600, color: '#334',
    marginBottom: 3, display: 'block' };

  return (
    <Modal baslik="📄 Rapor Ekle" onKapat={onKapat} dar
      alt={<>
        <button className="d bir" disabled={mesgul} onClick={() => void kaydet()}>
          💾 Kaydet (Taslak)</button>
        <button className="d" onClick={onKapat}>Vazgeç</button>
      </>}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, padding: '2px' }}>
        <div>
          <label style={etiket}>Tür (şablon)</label>
          <select style={kutu} value={tur} onChange={e => setTur(Number(e.target.value))}>
            {TURLER.map(t => <option key={t.k} value={t.k}>{t.ad}</option>)}
          </select>
        </div>
        <div>
          <label style={etiket}>Alt tür (SGK)</label>
          <select style={kutu} value={altTur} onChange={e => setAltTur(Number(e.target.value))}>
            {ALT_TURLER.map(t => <option key={t.k} value={t.k}>{t.ad}</option>)}
          </select>
        </div>
        <div>
          <label style={etiket}>Başlangıç</label>
          <input type="date" style={kutu} value={baslangic}
            onChange={e => setBaslangic(e.target.value)} />
        </div>
        <div>
          <label style={etiket}>Gün</label>
          <input type="number" min={0} style={kutu} value={gun}
            onChange={e => setGun(Math.max(0, Number(e.target.value)))} />
        </div>
        <div>
          <label style={etiket}>Bitiş (otomatik)</label>
          <input type="date" style={{ ...kutu, background: '#f3f5f8' }} value={bitis} readOnly />
        </div>
        <div>
          <label style={etiket}>ICD-10 kodu</label>
          <input style={kutu} value={icdKod} onChange={e => setIcdKod(e.target.value)}
            placeholder="ör. J06.9" />
        </div>
        <div style={{ gridColumn: '1 / -1' }}>
          <label style={etiket}>Açıklama</label>
          <textarea style={{ ...kutu, minHeight: 64, resize: 'vertical' }} value={aciklama}
            onChange={e => setAciklama(e.target.value)}
            placeholder="Rapor gerekçesi / notu" />
        </div>
      </div>
      <div className="not ic" style={{ marginTop: 8 }}>
        Kayıt <b>taslak</b> olarak açılır; grid'de belirir ve <b>✍ e-İmzala</b> ile
        onaylanır. İmzalanan rapor değiştirilemez.
      </div>
    </Modal>
  );
}
