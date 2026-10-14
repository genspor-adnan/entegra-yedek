import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import { Modal } from './Modal';

/**
 * KENDİME NOT (1098) — hekimin bu hastaya dair yalnız kendisinin gördüğü not.
 * Özet › İşlemler'den ve sekmesiz düzenin sol listesinden açılır (tek pencere).
 * Not hekim-hasta çiftine bağlı; epikriz, rapor, çıktı, e-Nabız ve YZ'ye girmez.
 */
export function KendimeNotPenceresi({ muayeneId, onKapat, onKaydedildi }: {
  muayeneId: number;
  onKapat(): void;
  /** Kayıttan sonra yeni metin (boş = silindi) - listedeki 🔒 işaretini tazeler. */
  onKaydedildi?(metin: string): void;
}) {
  const [metin, setMetin] = useState<string | null>(null);
  const [hata, setHata] = useState('');

  useEffect(() => {
    let iptal = false;
    api.muayeneOzelNot(muayeneId).then(y => { if (!iptal) setMetin(y.metin) })
      .catch(h => { if (!iptal) { setMetin(''); setHata(hataMetni(h)) } });
    return () => { iptal = true };
  }, [muayeneId]);

  const kaydet = () => {
    if (metin === null) return;
    api.muayeneOzelNotYaz(muayeneId, metin)
      .then(y => { onKaydedildi?.(y.metin); onKapat() })
      .catch(h => setHata(hataMetni(h)));
  };

  return (
    <Modal baslik={`🔒 ${c('Kendime Not')}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
             <button type="button" className="d bir" onClick={kaydet} disabled={metin === null}>{c('Kaydet')}</button>
           </>}>
      <textarea className="moz-not" value={metin ?? ''} maxLength={4000} autoFocus disabled={metin === null}
                placeholder={c('Bu hastaya dair yalnız sizin göreceğiniz not…')}
                onChange={e => setMetin(e.target.value)} />
      <p className="not moz-not-bilgi">{c('Yalnız siz görürsünüz. Başka hekim, hemşire, yönetici ya da hasta görmez; epikrize, rapora, çıktıya, e-Nabız\'a ve YZ\'ye gitmez. Bu hastanın sonraki muayenelerinde yine görürsünüz.')}</p>
      {hata && <p className="hata-kutusu">{hata}</p>}
    </Modal>
  );
}

/** Notu var mı (liste işareti için) - pencere açılmadan. */
export function useKendimeNotVar(muayeneId: number): [boolean, (v: boolean) => void] {
  const [var_, setVar] = useState(false);
  useEffect(() => {
    let iptal = false;
    api.muayeneOzelNot(muayeneId).then(y => { if (!iptal) setVar(!!y.metin) }).catch(() => {});
    return () => { iptal = true };
  }, [muayeneId]);
  return [var_, setVar];
}
