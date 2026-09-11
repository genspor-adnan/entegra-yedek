/** Ayar ekranlarindaki bir sekme: anahtar + gorunen baslik. */
export interface AyarSekmesi { anahtar: string; baslik: string }

/**
 * AYAR EKRANLARININ SEKME SERIDI (mockup `.katab` / `.kat`).
 *
 * Alti ayar ekraninda (Genel · Belge · Kasa · Stok · Randevu · Kayıt Kabul)
 * ayni dokuz satir kopyalanmisti; serit gorunumu degisecekse alti dosyada
 * degismesi gerekiyordu. Serit KARAR VERMEZ - hangi sekmeler var ve secim
 * nereye yazilir, cagiran ekranin isi.
 */
export function AyarSekmeSeridi(
  { sekmeler, aktif, onSec }: {
    sekmeler: readonly AyarSekmesi[];
    aktif: string;
    /** Secim CAGIRANA yazilir; ekranin kendi birlesim tipine cevrimi orada. */
    onSec(anahtar: string): void;
  },
) {
  return (
    <div className="katab">
      {sekmeler.map(s => (
        <div key={s.anahtar}
             className={`kat${s.anahtar === aktif ? ' on' : ''}`}
             onClick={() => onSec(s.anahtar)}>
          {s.baslik}
        </div>
      ))}
    </div>
  );
}
