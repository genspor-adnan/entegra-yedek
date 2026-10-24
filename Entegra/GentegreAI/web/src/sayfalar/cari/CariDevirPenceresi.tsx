import { useState } from 'react';
import type { Devir, DevirTuru } from '../../api/uclar/devir';
import { Modal } from '../../bilesenler/Modal';
import { c } from '../../dil/ceviri';
import { DevirFormu, TUR_AD } from '../devir/DevirFormu';

/**
 * DEVİR / AÇILIŞ BAKİYESİ PENCERESİ - her tür (kart düğmesi, yeni kart sorusu, Ekstre).
 * Gövde DevirFormu (sayfalar/devir, 1160); kayıt sunucuda tür 2 "Devir" hareketi.
 * `tur: 'hesap'` hesabın türünü sunucudan alır (kasa / banka / POS / kredi / kredi kartı kartı).
 */
export function DevirPenceresi({ tur, id, onKapat, onKaydedildi }: {
  tur: DevirTuru | 'hesap'; id: number; onKapat(): void; onKaydedildi?(): void;
}) {
  const [v, setV] = useState<Devir | null>(null);
  /** Üst bant (katoolbar): Kaydet / Kaldır solda - formdan portal - Kapat sağda. */
  const [yer, setYer] = useState<HTMLSpanElement | null>(null);
  const baslik = v ? `${c('Devir / Açılış Bakiyesi')} — ${v.hesap.ad}` : c('Devir / Açılış Bakiyesi');
  return (
    <Modal baslik={baslik} ustBilgi={v ? `${TUR_AD[v.tur]} · ${[v.hesap.kod, v.hesap.altBilgi].filter(Boolean).join(' · ')}` : undefined}
           onKapat={onKapat} enUst buyutmeYok ekSinif="cd-pencere"
           alt={<>
             <span ref={setYer} style={{ display: 'contents' }} />
             <span style={{ marginLeft: 'auto' }} />
             <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
           </>}>
      <style>{'.cd-pencere { width:min(1100px, 96vw); }'}</style>
      <DevirFormu tur={tur} id={id} onKapat={onKapat} onKaydedildi={onKaydedildi} onYuklendi={setV} dugmeYeri={yer} />
    </Modal>
  );
}

/** Eski ad (1156): cari kartı. */
export function CariDevirPenceresi({ tarafId, onKapat, onKaydedildi }: { tarafId: number; onKapat(): void; onKaydedildi?(): void }) {
  return <DevirPenceresi tur="cari" id={tarafId} onKapat={onKapat} onKaydedildi={onKaydedildi} />;
}
