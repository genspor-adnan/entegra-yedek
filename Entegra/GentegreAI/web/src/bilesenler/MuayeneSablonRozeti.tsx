import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { guvenli, mesaj } from './mesaj';

/**
 * BÖLÜME UYGUN ŞABLON ROZETİ (kullanıcı): "Şablon Uygula" sağında, muayenenin
 * bölümüne göre rozet içinde şablon adı (ör. bölüm Üroloji ise "Üroloji", İç
 * Hastalıkları ise "İç Hastalıkları"). Basınca o bölümün hazır şablonu
 * uygulanır (bulgular alta dolar). Eşleşen şablon yoksa rozet çizilmez.
 */
const norm = (s: string) => s.toLocaleLowerCase('tr').replace(/[^a-zçğıöşü ]/g, ' ').replace(/\s+/g, ' ').trim();

// Bölüm adı → hazır şablon kodu eş anlamlıları (ad birebir tutmayanlar).
const ES: { anahtar: string; kod: string }[] = [
  { anahtar: 'ic hastaliklari', kod: 'dahiliye' },
  { anahtar: 'dahiliye', kod: 'dahiliye' },
  { anahtar: 'cocuk', kod: 'pediatri' },
  { anahtar: 'pediatri', kod: 'pediatri' },
  { anahtar: 'kadin', kod: 'kadindogum' },
  { anahtar: 'kulak burun', kod: 'kbb' },
  { anahtar: 'kbb', kod: 'kbb' },
  { anahtar: 'ruh sagligi', kod: 'psikiyatri' },
  { anahtar: 'gogus', kod: 'gogus' },
  { anahtar: 'aile hekim', kod: 'aile' },
];

export function MuayeneSablonRozeti({ muayeneId, onUygulandi }:
  { muayeneId: number; onUygulandi(): void }) {
  const [bolumAd, setBolumAd] = useState('');
  const [sablon, setSablon] = useState<{ id: number; ad: string } | null>(null);
  const [mesgul, setMesgul] = useState(false);

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const my = await api.liste('muayene', { sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: muayeneId } });
        const bad = String(my.satirlar[0]?.bolumAdi ?? '').trim();
        if (iptal) return;
        setBolumAd(bad);
        if (!bad) { setSablon(null); return }

        const sy = await api.liste('muayene-sablon', { sayfa: 1, boyut: 200,
          filtre: { alan: 'durum', op: 'esit', deger: 1 } });
        if (iptal) return;
        const nb = norm(bad);
        const kodHedef = ES.find(e => nb.includes(e.anahtar))?.kod;
        const bul = sy.satirlar.find(r => {
          const na = norm(String(r.ad ?? ''));
          const nk = norm(String(r.kod ?? ''));
          return (kodHedef && nk === kodHedef)
            || na.includes(nb) || nb.includes(na.split(' ')[0]);
        });
        setSablon(bul ? { id: Number(bul.id), ad: String(bul.ad ?? '') } : null);
      } catch { if (!iptal) setSablon(null) }
    })();
    return () => { iptal = true };
  }, [muayeneId]);

  if (!bolumAd || !sablon) return null;

  const uygula = () => guvenli(async () => {
    setMesgul(true);
    try {
      const y = await api.muayeneSablonUygula(muayeneId, sablon.id);
      mesaj(y.mesaj);
      onUygulandi();
    } finally { setMesgul(false) }
  });

  return (
    <button type="button" className="rozet mavi" disabled={mesgul}
      title={`${bolumAd} bölümü şablonu (${sablon.ad}) uygula`}
      style={{ cursor: 'pointer', border: '1px solid #cfe0f5' }}
      onClick={() => void uygula()}>
      🩺 {bolumAd}
    </button>
  );
}
