import { useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';

/**
 * ONAY KODU GİR PENCERESİ (kullanıcı 17.11.2026: "sms gönder seçilince onay kodu gir ekranı otomatik gelsin.. yanlış kod
 * girilirse uyarı versin ama ekran kapanmasın.. ekran ya doğru kod ile ya da kapat butonu ile kapansın").
 * Kod sunucuda doğrulanır (POST /api/basvuru/{id}/kvkk-kod); hata pencerede kalır, perdeye tıklamak kapatmaz.
 */
export function KvkkKodPenceresi({ belgeId, alici, onDogrulandi, onKapat }: {
  belgeId: number;
  /** SMS'in gittiği numara (maskeli, ***1234) - yeni gönderimden açıldıysa. */
  alici?: string | null;
  onDogrulandi(y: { kod: string; kvkkOnay: number; etkOnay: number }): void;
  onKapat(): void;
}) {
  const [kod, setKod] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const kutu = useRef<HTMLInputElement>(null);
  useEffect(() => { kutu.current?.focus() }, []);

  const dogrula = async () => {
    const k = kod.replace(/\D/g, '');
    if (!k) { setHata(c('Hastanın söylediği kodu girin.')); kutu.current?.focus(); return }
    setMesgul(true); setHata(null);
    try {
      onDogrulandi(await api.basvuruKvkkKod(belgeId, k));
    } catch (h) {
      setHata(hataMetni(h));
      kutu.current?.select();
    } finally { setMesgul(false) }
  };

  return (
    <Modal baslik={`🔢 ${c('Onay Kodu Gir')}`} dar enUst onKapat={onKapat}
           alt={<>
             <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
             <button type="button" className="d bir" disabled={mesgul} onClick={() => void dogrula()} data-testid="kvkk-kod-dogrula">
               ✔ {c('Doğrula')}</button>
           </>}>
      <div style={{ padding: '4px 2px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <div style={{ fontSize: 12 }}>
          {alici
            ? <>{c('KVKK onay SMS\'i gönderildi')} (<b>{alici}</b>). {c('Hastanın söylediği 6 haneli kodu girin.')}</>
            : c('Hastanın SMS ile aldığı 6 haneli onay kodunu girin.')}
        </div>
        <input ref={kutu} value={kod} inputMode="numeric" maxLength={10} disabled={mesgul}
               data-testid="kvkk-kod-girdi" aria-label={c('Onay kodu')}
               style={{ fontSize: 20, letterSpacing: 6, textAlign: 'center', fontFamily: 'Consolas, monospace', height: 40 }}
               onChange={e => { setKod(e.target.value.replace(/\D/g, '')); if (hata) setHata(null) }}
               onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); void dogrula() } }} />
        {hata && <div className="hata-kutusu" data-testid="kvkk-kod-hata" style={{ margin: 0 }}>{hata}</div>}
      </div>
    </Modal>
  );
}
