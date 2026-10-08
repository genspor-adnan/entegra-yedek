import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { PosSecenek } from '../../api/uclar/bankoOturum';

/**
 * POS SEÇİMİ (997, mockup banko_gun_sonu_kasa_teslimi.html + kullanıcı
 * 08.10.2026: "tahsilat yaparken kurumdaki tüm pos listesi değil sadece o
 * bankoya bağlı POS listesi gelmiş olur").
 *
 * Açık oturumun bankosundaki **çalışan** terminalleri listeler. Yan bankonun
 * cihazına çekilen kart o bankonun gün sonunu tutturmaz; arızalı cihaz da
 * listede yok - görevli çalışmayan terminali denemesin.
 *
 * Seçim İKİ SORUYU BİRDEN yanıtlıyor: terminalin kendi tahsilat hesabı
 * işlemin hesabı olur, `bankoPosId` de gün sonu eşleşmesine yazılır. Önce
 * "POS hesabı" sorup sonra terminali sormak aynı bilgiyi iki kez istemekti.
 *
 * OTURUM YOKSA bu modal hiç açılmaz: çağıran taraf listeyi boş görürse eski
 * hesap seçimine düşer (muhasebeden girilen POS tahsilatı gibi bankosuz
 * durumlar için).
 */
export function PosSecModali({ onSec, onKapat, onOturumYok }: {
  onSec(p: PosSecenek): void;
  onKapat(): void;
  /** Açık oturum ya da çalışan POS yoksa: çağıran eski akışa düşsün. */
  onOturumYok(): void;
}) {
  const [liste, setListe] = useState<PosSecenek[] | null>(null);
  const [hata, setHata] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const l = await api.bankoOturumPosSecenekleri();
        if (l.length === 0) { onOturumYok(); return }
        setListe(l);
      } catch (h) {
        // LISTE ALINAMADIYSA ESKI AKIS: POS hesabı seçimi devam eder.
        //   Tahsilatı kilitlemek, uç erişilemediğinde kasayı durdurmak olurdu.
        setHata(hataMetni(h));
        setListe([]);
        onOturumYok();
      }
    })();
  }, [onOturumYok]);

  if (liste === null && !hata) return null;

  return (
    <div className="psm-ort" onClick={onKapat}>
      <div className="psm" onClick={e => e.stopPropagation()}>
        <style>{stil}</style>
        <div className="psm-bas">
          💳 POS Seç
          <button type="button" className="psm-kapat" onClick={onKapat}>✖</button>
        </div>
        {hata && <div className="psm-ic gp-hata">{hata}</div>}
        {liste && liste.length > 0 && (
          <>
            <div className="psm-ust">
              {liste[0].bankoAd} · oturum #{liste[0].oturumId}
            </div>
            <div className="psm-liste">
              {liste.map(p => (
                <button key={p.id} type="button" className="psm-satir"
                        onClick={() => onSec(p)}>
                  <span className="psm-terminal">
                    {p.varsayilan && <span className="psm-yildiz">⭐</span>}
                    {p.terminalNo}
                  </span>
                  <span className="psm-hesap">{p.hesapAdi || '(tahsilat hesabı yok)'}</span>
                </button>
              ))}
            </div>
            <div className="psm-not">
              Yalnız bu bankonun <b>çalışan</b> terminalleri listelenir. Seçilen
              terminalin tahsilat hesabı işlemin hesabı olur ve gün sonu
              eşleşmesine yazılır.
            </div>
          </>
        )}
      </div>
    </div>
  );
}

const stil = `
.psm-ort { position:fixed; inset:0; background:rgba(16,28,42,.45); z-index:910;
  display:flex; align-items:flex-start; justify-content:center; padding:48px 16px }
.psm { width:min(460px,100%); background:var(--kart,#fff); border:1px solid var(--cizgi,#cdd6e0);
  border-radius:8px; box-shadow:0 18px 48px rgba(16,28,42,.28); overflow:hidden }
.psm-bas { background:linear-gradient(#2b5c95,#1c4374); color:#fff; padding:9px 12px;
  font-weight:bold; font-size:13.5px; display:flex; align-items:center }
.psm-kapat { margin-left:auto; background:none; border:none; color:#fff; cursor:pointer; font-size:14px }
.psm-ust { padding:8px 12px 4px; font-size:11px; color:var(--ikincil-metin,#6b7a8b) }
.psm-ic { padding:10px 12px }
.psm-liste { display:flex; flex-direction:column; padding:0 8px 8px }
.psm-satir { display:flex; align-items:center; gap:10px; text-align:left; width:100%;
  border:1px solid var(--cizgi,#cdd6e0); border-radius:5px; background:var(--kart,#fff);
  padding:8px 10px; margin:4px 0; cursor:pointer; font-size:12.5px }
.psm-satir:hover { border-color:#2f6db3; background:#eef4fc }
.psm-terminal { font-family:Consolas,monospace; font-weight:bold; min-width:92px }
.psm-yildiz { margin-right:4px }
.psm-hesap { color:var(--ikincil-metin,#6b7a8b); font-size:11.5px }
.psm-not { padding:0 12px 10px; font-size:11px; color:var(--ikincil-metin,#6b7a8b); line-height:1.6 }
`;

export default PosSecModali;
