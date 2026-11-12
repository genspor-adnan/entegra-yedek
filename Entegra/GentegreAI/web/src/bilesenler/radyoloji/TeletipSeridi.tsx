import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { TELETIP_DURUM, mesajKisaAdi, type TeletipSatir } from '../../api/uclar/teletip';
import { tarihSaat } from '../bicim';
import { c } from '../../dil/ceviri';

/**
 * RADYOLOJİ İSTEM KARTI › TELETIP ŞERİDİ (1304; mockup Ekranlar/Radyoloji/teletip_mirth.html §6): istemin Bakanlık
 * mesajları tek satırda - her mesaj bir adım (NW / XO / CA + durum + saat). Kurumda TeleRadyoloji kapalıysa ve iz yoksa
 * şerit hiç çizilmez (özel merkez). "Ayrıntı" TeleRadyoloji gönderim kartını (/teletip/:istemId) açar - ekran yetkisi varsa.
 * CSS öneki `tts-` (tema genel sınıflarıyla çakışmasın).
 */
export function TeletipSeridi({ istemId, yenile, ac }: { istemId: number; yenile?: number; ac?(): void }) {
  const [v, setV] = useState<{ aktif: boolean; satirlar: TeletipSatir[]; detayYetkisi: boolean } | null>(null);

  useEffect(() => {
    let iptal = false;
    // Yetki ya da ağ hatasında şerit sessizce gizlenir: istem kartının asıl işi bu değil.
    api.teletipIstem(istemId).then(y => { if (!iptal) setV(y) }).catch(() => { if (!iptal) setV(null) });
    return () => { iptal = true };
  }, [istemId, yenile]);

  if (!v || (!v.aktif && v.satirlar.length === 0)) return null;
  const sorunlu = v.satirlar.some(s => s.durum === 2 || s.durum === 3);
  return (
    <div className={`tts-serit${sorunlu ? ' tts-sorunlu' : ''}`} data-testid="teletip-serit">
      <style>{TTS_STIL}</style>
      <b>🏛 {c('TeleRadyoloji')}</b>
      {v.satirlar.length === 0
        ? <span className="tts-adim">{c('henüz mesaj yok')}{v.aktif ? '' : ` · ${c('kurumda kapalı')}`}</span>
        : v.satirlar.map((s, i) => {
          const d = TELETIP_DURUM[s.durum] ?? { ad: String(s.durum), sinif: 'gri' };
          const saat = tarihSaat(s.sonDeneme ?? s.eklemeTarihi).split(' ')[1] ?? '';
          return (
            <span key={s.id} className="tts-parca">
              {i > 0 && <span className="tts-ayrac">›</span>}
              <span className={`tts-adim ${d.sinif}`} title={s.hata || `${mesajKisaAdi(s.kanal, s.emir)} · ${d.ad}`}>
                {mesajKisaAdi(s.kanal, s.emir)} {s.durum === 1 ? '✓' : s.durum === 2 || s.durum === 3 ? '✖' : '…'} {c(d.ad)}{saat ? ` ${saat}` : ''}
              </span>
            </span>
          );
        })}
      {v.detayYetkisi && ac && <button type="button" className="d tts-ac" onClick={ac}>{c('ayrıntı')}</button>}
    </div>
  );
}

const TTS_STIL = `
.tts-serit{display:flex;gap:6px;align-items:center;flex-wrap:wrap;padding:6px 18px;background:#fbfcfd;border-bottom:1px solid #e3e9f0;font-size:11.5px}
.tts-serit.tts-sorunlu{background:#fff8f6}
.tts-serit .tts-parca{display:inline-flex;align-items:center;gap:6px}
.tts-serit .tts-adim{border:1px solid #cdd6e0;border-radius:12px;padding:1px 9px;background:#f4f6f9;color:#5b6b7c;white-space:nowrap}
.tts-serit .tts-adim.olumlu{background:#e2f3e8;color:#2e7d46;border-color:#bfe3cb}
.tts-serit .tts-adim.uyari{background:#fff4e0;color:#9a5b00;border-color:#f0d3a0}
.tts-serit .tts-adim.hata{background:#fbe5e5;color:#9d3434;border-color:#efc3c3}
.tts-serit .tts-ayrac{color:#9aa7b4}
.tts-serit .tts-ac{margin-left:auto}
`;
