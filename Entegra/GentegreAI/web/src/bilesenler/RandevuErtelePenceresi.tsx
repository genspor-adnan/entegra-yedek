import { useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import { Modal } from './Modal';
import { RandevuUygunSaatler } from './RandevuUygunSaatler';

/** Ertelenecek randevu: listeden satır ya da karttan değerler. */
export interface ErtelenecekRandevu {
  id: number;
  hasta?: string;
  hekimId: number | null;
  hekimAdi?: string;
  cihazId: number | null;
  cihazAdi?: string;
  bolum: number | null;
  sureDk: number;
  /** Eski randevu, şube saatinde: yyyy-mm-dd ve HH:mm. */
  tarih: string;
  saat: string;
}

const HAZIR_NEDENLER = ['Hasta istedi', 'Doktor izinli / programı değişti', 'Cihaz arızası / bakım', 'Kurum kaynaklı'];

/**
 * RANDEVU ERTELE PENCERESİ (1119; kullanıcı 17.10.2026: "randevu ertelemeyi nasıl yapacağız?" → "ilk yol").
 *
 * Yeni tarih / saat kartla aynı Uygun Saatler şeridinden seçilir (hekim, cihaz ya da ikisi birden).
 * Neden zorunlu. Kayıtta eski randevu "Ertelendi" kalır, aynı bilgilerle yeni randevu açılır - sunucu
 * tek işlemde yapar; çakışma / mesai / izin kuralları yeni randevuya da uygulanır.
 */
export function RandevuErtelePenceresi({ randevu: r, onKapat, onErtelendi }: {
  randevu: ErtelenecekRandevu;
  onKapat(): void;
  onErtelendi(yeniId: number): void;
}) {
  const [tarih, setTarih] = useState(r.tarih);
  const [saat, setSaat] = useState('');
  const [sure, setSure] = useState(r.sureDk || 15);
  const [neden, setNeden] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const kaydet = async () => {
    if (!tarih || !saat) { setHata(c('Yeni tarih ve saat seçilmeli.')); return }
    if (!neden.trim()) { setHata(c('Erteleme nedeni yazılmalı.')); return }
    if (tarih === r.tarih && saat === r.saat) { setHata(c('Yeni saat eskisiyle aynı.')); return }
    setHata(null); setMesgul(true);
    try {
      const y = await api.randevuErtele(r.id, { baslangic: `${tarih}T${saat}`, neden: neden.trim(), sureDk: sure });
      onErtelendi(y.id);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setMesgul(false) }
  };

  return (
    <Modal baslik={`⏭ ${c('Randevu Ertele')}`} enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydet()}>⏭ {c('Ertele')}</button>
             <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ {c('Kapat')}</button>
           </>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 520 }}>
        <div className="not" style={{ margin: 0 }}>
          {r.hasta && <><b>{r.hasta}</b> · </>}
          {c('Mevcut')}: <b>{r.tarih.split('-').reverse().join('.')} {r.saat}</b> ({r.sureDk} dk)
          {r.hekimAdi ? ` · ${r.hekimAdi}` : ''}{r.cihazAdi ? ` · ${r.cihazAdi}` : ''}
        </div>
        <label style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, fontWeight: 600 }}>
          {c('Yeni tarih')}
          <input type="date" value={tarih} onChange={e => { setTarih(e.target.value); setSaat(''); setSure(r.sureDk || 15) }}
                 style={{ height: 30, padding: '0 8px' }} />
        </label>
        <RandevuUygunSaatler hekimId={r.hekimId} hekimAdi={r.hekimAdi} cihazId={r.cihazId} cihazAdi={r.cihazAdi}
                             bolum={r.bolum} tarih={tarih} sureDk={sure} seciliSaat={saat}
                             hariçId={r.id} onSec={(s, d) => {
                               // Yeni başlangıç seçimi randevunun KENDİ süresini korur (şerit tek slot
                               //   adımı verir); aynı başlangıçta uzatma / kısaltma şeridin süresiyle.
                               setSure(s !== saat ? Math.max(d, r.sureDk || d) : d);
                               setSaat(s);
                             }} />
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <span style={{ fontSize: 12, fontWeight: 600 }}>{c('Erteleme nedeni')} *</span>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
            {HAZIR_NEDENLER.map(n => (
              <button key={n} type="button" className={`d${neden === c(n) ? ' bir' : ''}`}
                      onClick={() => setNeden(c(n))}>{c(n)}</button>
            ))}
          </div>
          <input value={neden} maxLength={200} placeholder={c('Neden (serbest metin)')}
                 onChange={e => setNeden(e.target.value)} style={{ height: 30, padding: '0 8px' }} />
        </div>
        {hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}
