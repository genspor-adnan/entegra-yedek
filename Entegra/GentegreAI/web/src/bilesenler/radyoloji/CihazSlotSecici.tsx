import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { anGirdiMetni } from '../bicim';
import { c } from '../../dil/ceviri';

/**
 * CİHAZ KAPATMA ARALIĞI (kullanıcı 19.11.2026: "tarihten saati kaldır yine.. 2 seçim olsun tarih aralığı (tam gün
 * kapansın) veya bir tarihteki slot aralığı (slot bazında kısmi kapanma)").
 *
 *  * TAM GÜN: iki tarih; başlangıç = ilk gün 00:00, bitiş = son günün ERTESİ 00:00 (aralık sonu hariç - çakışma
 *    kuralı `baslangic < bitis` ile son gün de tamamen kapalı).
 *  * SLOT ARALIĞI: tek gün; o günün slotları çip olarak gelir, ilk tık başlangıç, ikinci tık bitiş slotu.
 *
 * Değerler şubenin saatiyle "yyyy-MM-ddTHH:mm" yazılır (sunucu şube diliminde yorumlar, 666). Kip mevcut değerden
 * anlaşılır: iki uç da 00:00 ise tam gün.
 */
type Slot = { bas: string; bit: string; saat: string; tur: 'acik' | 'ogle' | 'kapali' | 'dolu'; dolu: number };
const bugun = () => new Date().toLocaleDateString('sv-SE');
const gunEkle = (g: string, n: number) => {
  const d = new Date(`${g}T12:00:00Z`); d.setUTCDate(d.getUTCDate() + n); return d.toISOString().slice(0, 10);
};

export function KapatmaAraligiSecici({ cihazId, bas, bit, salt, onSec }: {
  cihazId: number; bas: unknown; bit: unknown; salt?: boolean;
  onSec(bas: string, bit: string): void;
}) {
  const b = anGirdiMetni(bas).slice(0, 16), e = anGirdiMetni(bit).slice(0, 16);
  const tamGunDeger = !b || (b.slice(11) === '00:00' && e.slice(11) === '00:00');
  const [kip, setKip] = useState<'gun' | 'slot'>(tamGunDeger ? 'gun' : 'slot');

  // Boş yeni satır: tam gün, bugün.
  useEffect(() => { if (!b && !salt) onSec(`${bugun()}T00:00`, `${gunEkle(bugun(), 1)}T00:00`) },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []);

  const kipSec = (k: 'gun' | 'slot') => {
    if (k === kip || salt) return;
    setKip(k);
    const g = b.slice(0, 10) || bugun();
    // Tam güne geçiş: o gün tamamen; slota geçiş: aralık boşalır, slot seçilir.
    if (k === 'gun') onSec(`${g}T00:00`, `${gunEkle(g, 1)}T00:00`);
    else onSec(`${g}T00:00`, `${g}T00:00`);
  };

  return (
    <div className="cs-slot">
      <div className="cipler cs-slot-kip">
        <button type="button" className={`cip${kip === 'gun' ? ' on' : ''}`} disabled={salt}
                onClick={() => kipSec('gun')}>📅 {c('Tam gün (tarih aralığı)')}</button>
        <button type="button" className={`cip${kip === 'slot' ? ' on' : ''}`} disabled={salt || !(cihazId > 0)}
                title={cihazId > 0 ? undefined : c('Slotlar cihaz kaydedildikten sonra seçilebilir')}
                onClick={() => kipSec('slot')}>⏱ {c('Slot aralığı (tek gün)')}</button>
      </div>
      {kip === 'gun'
        ? <TamGun bas={b} bit={e} salt={salt} onSec={onSec} />
        : <SlotAraligi cihazId={cihazId} bas={b} bit={e} salt={salt} onSec={onSec} />}
    </div>
  );
}

function TamGun({ bas, bit, salt, onSec }: { bas: string; bit: string; salt?: boolean; onSec(b: string, e: string): void }) {
  const ilk = bas.slice(0, 10) || bugun();
  const son = bit ? gunEkle(bit.slice(0, 10), -1) : ilk;
  const yaz = (i: string, s: string) => {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(i)) return;
    const s2 = /^\d{4}-\d{2}-\d{2}$/.test(s) && s >= i ? s : i;
    onSec(`${i}T00:00`, `${gunEkle(s2, 1)}T00:00`);
  };
  return (
    <div className="cs-slot-ust">
      <span>{c('Başlangıç')}</span>
      <input type="date" value={ilk} disabled={salt} aria-label={c('Başlangıç tarihi')} onChange={x => yaz(x.target.value, son)} />
      <span>{c('Bitiş')}</span>
      <input type="date" value={son} min={ilk} disabled={salt} aria-label={c('Bitiş tarihi')} onChange={x => yaz(ilk, x.target.value)} />
      <span className="sonuk kucuk">{c('Bitiş günü dahil, günler tamamen kapalı.')}</span>
    </div>
  );
}

function SlotAraligi({ cihazId, bas, bit, salt, onSec }: {
  cihazId: number; bas: string; bit: string; salt?: boolean; onSec(b: string, e: string): void;
}) {
  const tarih = bas.slice(0, 10) || bugun();
  const [veri, setVeri] = useState<{ calisir: boolean; mesaiYok: boolean; slotlar: Slot[] } | null>(null);
  const [capa, setCapa] = useState<Slot | null>(null);

  useEffect(() => {
    let iptal = false;
    setVeri(null); setCapa(null);
    if (!/^\d{4}-\d{2}-\d{2}$/.test(tarih)) return;
    api.radCihazGunSlotlari(cihazId, tarih)
      .then(y => { if (!iptal) setVeri(y) })
      .catch(() => { if (!iptal) setVeri(null) });
    return () => { iptal = true };
  }, [cihazId, tarih]);

  const tikla = (s: Slot) => {
    if (salt) return;
    if (!capa) { setCapa(s); onSec(s.bas, s.bit); return; }
    const [ilk, son] = s.bas < capa.bas ? [s, capa] : [capa, s];
    onSec(ilk.bas, son.bit);
    setCapa(null);
  };

  return (
    <>
      <div className="cs-slot-ust">
        <span>{c('Tarih')}</span>
        <input type="date" value={tarih} disabled={salt} aria-label={c('Slot günü')}
               onChange={x => /^\d{4}-\d{2}-\d{2}$/.test(x.target.value) && onSec(`${x.target.value}T00:00`, `${x.target.value}T00:00`)} />
        <span className="sonuk kucuk">
          {capa ? c('Bitiş slotunu seçin') : c('Başlangıç slotunu, sonra bitiş slotunu tıklayın')}
        </span>
      </div>
      {!veri ? <div className="sonuk kucuk">{c('Yükleniyor…')}</div>
        : veri.mesaiYok ? <div className="sonuk kucuk">{c('Cihazın mesaisi girilmemiş (Randevu ayarları).')}</div>
        : !veri.calisir ? <div className="sonuk kucuk">{c('Cihaz bu gün çalışmıyor.')}</div>
        : (
          <div className="cs-slot-cipler">
            {veri.slotlar.map(s => {
              const secili = bas < bit && s.bas >= bas && s.bit <= bit;
              return (
                <button key={s.bas} type="button" disabled={salt}
                        className={`cs-slot-cip cs-slot-${s.tur}${secili ? ' on' : ''}${capa?.bas === s.bas ? ' capa' : ''}`}
                        title={s.tur === 'kapali' ? c('Zaten kapalı') : s.tur === 'ogle' ? c('Öğle arası')
                               : s.dolu ? `${s.dolu} ${c('randevu')}` : undefined}
                        onClick={() => tikla(s)}>
                  {s.saat}{s.dolu > 0 && <sup>{s.dolu}</sup>}
                </button>
              );
            })}
          </div>
        )}
      {bas < bit && <div className="kucuk">{c('Seçili')}: <b>{bas.slice(11)} – {bit.slice(11)}</b></div>}
    </>
  );
}
