import { tup } from '../../labKodlari';

type Satir = Record<string, unknown>;

/**
 * LAB DETAY PANELLERININ ORTAK PARCALARI.
 *
 * Dort alan detayi (istem · kultur · genetik · dis lab) ayni kucuk parcalari
 * kullaniyor: dizi/metin okuyuculari, kod eki, tup rozeti, tat suresi metni ve
 * "kayit yok" kutusu.
 */
export const dizi = (v: unknown): Satir[] => (Array.isArray(v) ? v as Satir[] : []);
export const metin = (v: unknown): string => String(v ?? '').trim();

/**
 * Tetkik adının yanına kodu YALNIZ ayırt ediyorsa yazar: "ALT (SGPT) ALT"
 * gibi tekrar, dar bir kolonda yer yiyor ve okumayı zorlaştırıyordu.
 */
export function kodEki(ad: unknown, kod: unknown): string {
  const a = metin(ad).toLocaleUpperCase('tr'), k = metin(kod).toLocaleUpperCase('tr');
  return k !== '' && !a.includes(k) ? metin(kod) : '';
}

/** Tüp rengi rozet olarak: renk bilgidir, teknisyen rafta rengi arar. */
export function TupRozeti({ tip }: { tip: unknown }) {
  const t = tup(tip);
  return (
    <span className="rozet gri"
          style={{ background: t.renk, color: t.yazi ?? '#1f2d3a', border: 'none' }}>
      {t.kisa}
    </span>
  );
}

/**
 * Hedef süre dakika olarak tutulur; mockup saat yazıyor ("2 s", "48 s").
 * 60'ın altını dakika bırakmak bilinçli: 30 dakikalık acil tetkiği "0,5 s"
 * diye göstermek okunmaz olurdu.
 */
export function tatMetni(dk: unknown): string {
  const d = Number(dk ?? 0);
  if (!d) return '—';
  return d < 60 ? `${d} dk` : `${Math.round(d / 6) / 10} s`.replace('.', ',');
}

/** Boş panel de bir bilgidir: "satır seç" demek, boş kutu bırakmaktan iyidir. */
export function Bos({ ne }: { ne: string }) {
  return <div className="kagrup"><div className="bos">{ne}</div></div>;
}

