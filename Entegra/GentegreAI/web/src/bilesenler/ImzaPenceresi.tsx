import { useState } from 'react';
import { Modal } from './Modal';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';

/**
 * E-İMZA PENCERESİ (1253; 21 CFR Part 11 §11.50 - bilinen bileşen = parola tekrarı): karar (isteğe bağlı) + gerekçe +
 * parola. Üretim fişi kalite serbest bırakma / ret ve üretim emri atölyeye serbest bırakma aynı pencereyi kullanır -
 * iki kopya iki ayrı davranış demekti. İmzanın kendisi (ad, zaman, anlam) SUNUCUDA yazılır; pencere yalnız toplar.
 */
export interface ImzaKarari { deger: number; ad: string; disabled?: boolean; tehlike?: boolean }

export function ImzaPenceresi({ baslik, kararlar, varsayilanKarar, parolaIster = true, gerekceZorunlu = true, aciklama, onaylaMetni, onImzala, onKapat }: {
  baslik: string;
  /** Verilmezse karar sorulmaz (tek anlam). */
  kararlar?: ImzaKarari[];
  varsayilanKarar?: number;
  /** Denetimli seviyede parola zorunlu; standartta istenmez. */
  parolaIster?: boolean;
  gerekceZorunlu?: boolean;
  aciklama?: string;
  /** Onay düğmesinin metni (karara göre). */
  onaylaMetni(karar: number): string;
  onImzala(gerekce: string, parola: string, karar: number): Promise<void>;
  onKapat(): void;
}) {
  const [karar, setKarar] = useState(varsayilanKarar ?? kararlar?.find(k => !k.disabled)?.deger ?? 1);
  const [gerekce, setGerekce] = useState('');
  const [parola, setParola] = useState('');
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const secili = kararlar?.find(k => k.deger === karar);
  const hazir = !mesgul && (!gerekceZorunlu || gerekce.trim().length > 0) && (!parolaIster || parola.length > 0) && !secili?.disabled;
  const imzala = async () => {
    setMesgul(true); setHata('');
    try { await onImzala(gerekce.trim(), parola, karar) }
    catch (h) { setHata(hataMetni(h)) } finally { setMesgul(false) }
  };
  return (
    <Modal baslik={baslik} dar enUst buyutmeYok onKapat={onKapat}
           alt={<><span style={{ marginLeft: 'auto' }} /><button type="button" className="d" onClick={onKapat}>✖ {c('Vazgeç')}</button>
                 <button type="button" className={`d ${secili?.tehlike ? 'teh' : 'onay'}`} disabled={!hazir} onClick={() => void imzala()}>{onaylaMetni(karar)}</button></>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {kararlar && <label className="alan"><span className="etiket">{c('Karar')}</span>
          <select value={karar} onChange={e => setKarar(Number(e.target.value))}>
            {kararlar.map(k => <option key={k.deger} value={k.deger} disabled={k.disabled}>{k.ad}</option>)}</select></label>}
        <label className="alan"><span className={`etiket${gerekceZorunlu ? ' zorunlu-isaret' : ''}`}>{c('Gerekçe')}</span>
          <input value={gerekce} maxLength={500} onChange={e => setGerekce(e.target.value)} /></label>
        {parolaIster && <label className="alan"><span className="etiket zorunlu-isaret">{c('Parola')}</span>
          <input type="password" value={parola} autoComplete="current-password" onChange={e => setParola(e.target.value)} /></label>}
        <div className="sl" style={{ fontSize: 11 }}>{aciklama ?? c('İmza kaydı: ad, zaman, anlam ve gerekçe - değiştirilemez (21 CFR Part 11 §11.50).')}</div>
      </div>
    </Modal>
  );
}
