import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import { Modal } from './Modal';

interface Satir { id: number; belgeNo: string; belgeTarihi: string; hastaAdi: string;
                  odeyenKurumAdi: string; poliklinik: string; doktor: string }

/**
 * KAYITLI BAŞVURU ARAMA (Ctrl+K "Kayıtlı Başvuru Kartı", kullanıcı 14.10.2026 - hasta
 * kartı deseni): protokol no ya da hasta adıyla başvuru bulunur, seçilen kendi kart
 * sekmesinde açılır. Boş aramada son başvurular. Süzgeç Başvuru Listesi'yle aynı
 * (tur 19 + tipi 30) - ERP satış siparişleri gelmez.
 */
export function BasvuruArama({ acik, onSec, onKapat }: {
  acik: boolean;
  onSec(id: number): void;
  onKapat(): void;
}) {
  const [metin, setMetin] = useState('');
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [secili, setSecili] = useState(0);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const kutu = useRef<HTMLInputElement | null>(null);

  useEffect(() => { if (acik) { setMetin(''); setSecili(0); setTimeout(() => kutu.current?.focus(), 50) } }, [acik]);

  useEffect(() => {
    if (!acik) return;
    const anahtar = metin.trim();
    let iptal = false;
    const zaman = setTimeout(() => {
      setYukleniyor(true);
      void (async () => {
        try {
          const y = await api.liste('belge', {
            sayfa: 1, boyut: 30,
            filtre: { op: 'and', kosullar: [
              { alan: 'tur', op: 'esit', deger: 19 },
              { alan: 'tipi', op: 'esit', deger: 30 },
              ...(anahtar ? [{ op: 'or' as const, kosullar: [
                { alan: 'belgeNo', op: 'icerir' as const, deger: anahtar },
                { alan: 'hastaAdi', op: 'icerir' as const, deger: anahtar },
              ] }] : []),
            ] },
          });
          if (!iptal) { setSatirlar(y.satirlar as unknown as Satir[]); setSecili(0); setHata(null) }
        } catch (h) { if (!iptal) setHata(hataMetni(h)) }
        finally { if (!iptal) setYukleniyor(false) }
      })();
    }, anahtar ? 300 : 0);
    return () => { iptal = true; clearTimeout(zaman) };
  }, [metin, acik]);

  if (!acik) return null;
  const sec = (s?: Satir) => { if (s) { onKapat(); onSec(s.id) } };

  return (
    <Modal baslik={c('Kayıtlı Başvuru Kartı')} onKapat={onKapat} enUst
           alt={<button className="d kapat-dugmesi" onClick={onKapat}>{c('Kapat')}</button>}>
      <div className="kagrup" onKeyDown={e => {
        if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(i => Math.min(i + 1, satirlar.length - 1)) }
        else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(i => Math.max(i - 1, 0)) }
        else if (e.key === 'Enter') { e.preventDefault(); sec(satirlar[secili]) }
      }}>
        <input ref={kutu} className="arama" style={{ width: '100%', marginBottom: 8 }} value={metin}
               placeholder={c('Protokol no ya da hasta adı…')} onChange={e => setMetin(e.target.value)} />
        {hata && <div className="hata-kutusu">{hata}</div>}
        <table className="grid">
          <thead><tr><th style={{ width: 110 }}>{c('Protokol No')}</th><th style={{ width: 130 }}>{c('Tarih')}</th>
            <th>{c('Hasta')}</th><th>{c('Kurum')}</th><th>{c('Poliklinik')}</th><th>{c('Doktor')}</th></tr></thead>
          <tbody>
            {satirlar.map((s, i) => (
              <tr key={s.id} className={i === secili ? 'secili' : ''} style={{ cursor: 'pointer' }}
                  onMouseEnter={() => setSecili(i)} onClick={() => sec(s)}>
                <td>{s.belgeNo}</td>
                <td>{s.belgeTarihi ? new Date(s.belgeTarihi).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : ''}</td>
                <td>{s.hastaAdi}</td><td>{s.odeyenKurumAdi}</td><td>{s.poliklinik}</td><td>{s.doktor}</td>
              </tr>
            ))}
            {!yukleniyor && satirlar.length === 0 && <tr><td colSpan={6} className="bos">{c('Başvuru bulunamadı.')}</td></tr>}
          </tbody>
        </table>
      </div>
    </Modal>
  );
}
