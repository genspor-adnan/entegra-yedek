import { c } from '../dil/ceviri';
import type { Kosul } from '../api/sozlesme';
import { GenGrid } from './GenGrid';
import { Modal } from './Modal';

/**
 * KAYITLI KART ARAMASI (Ctrl+K "Kayıtlı X Kartı", kullanıcı 14.10.2026 - hasta/başvuru
 * deseni bütün kartlara): listenin KENDİ kaynağı ve kolonlarıyla arama; satır açılınca
 * (çift tık / Enter) kayıt kart sekmesinde açılır. Arama penceresi modal kalır (karar 3).
 */
export function KayitArama({ acik, baslik, kaynak, sabitFiltre, onSec, onKapat }: {
  acik: boolean;
  baslik: string;
  kaynak: string;
  sabitFiltre?: Kosul;
  onSec(id: number): void;
  onKapat(): void;
}) {
  if (!acik) return null;
  return (
    <Modal baslik={c(baslik)} onKapat={onKapat} enUst
           alt={<button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>}>
      <GenGrid kaynak={kaynak} gomulu seritGizli boyut={25} sabitFiltre={sabitFiltre}
               onSatirAc={r => { onKapat(); onSec(Number(r.id)) }} />
    </Modal>
  );
}
