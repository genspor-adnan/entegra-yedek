import { useState, type ReactNode } from 'react';

/** Çalışma şablonu / istisna kartlarının ortak parçaları (mockup Ekranlar/Randevu). */
export const GUN_AD = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
export const SLOTLAR = [10, 15, 20, 30, 45, 60];
export const KANALLAR: [string, string][] = [['B', 'Banko / telefon'], ['P', 'Hasta portalı'], ['C', 'Çağrı merkezi']];

export const metin = (v: unknown) => String(v ?? '').trim();
export const sayi = (v: unknown) => Number(v ?? 0) || 0;
export const gun10 = (v: unknown) => metin(v).slice(0, 10);
export const isoGun = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
export const bugunIso = () => isoGun(new Date());

/** 'HH:MM' -> dakika; geçersizse NaN. */
export const dk = (s: string | null | undefined) => {
  const m = /^(\d{2}):(\d{2})$/.exec(s ?? '');
  return m && Number(m[1]) < 24 && Number(m[2]) < 60 ? Number(m[1]) * 60 + Number(m[2]) : NaN;
};

/** "1,2,3,4,5" -> "Pzt–Cum"; ardışık değilse "Pzt, Çar". */
export function gunMetni(gunler: string | number[]) {
  const l = (Array.isArray(gunler) ? gunler : String(gunler).split(',').map(Number))
    .filter(x => x >= 1 && x <= 7).sort((a, b) => a - b);
  if (l.length === 0) return '—';
  const ardisik = l.length > 2 && l.every((x, i) => i === 0 || x === l[i - 1] + 1);
  return ardisik ? `${GUN_AD[l[0] - 1]}–${GUN_AD[l[l.length - 1] - 1]}` : l.map(x => GUN_AD[x - 1]).join(', ');
}

/** An (Z'li) şubenin saatinde gösterilir - ortak biçimleyici (667). */
export { tarihSaat } from '../bicim';

/** Açılır / kapanır bölüm (mockup: "sekmeler açılır olsun" - başlığa tıkla). */
export function Grp({ baslik, ek, ilkKapali, children, sinif }: {
  baslik: ReactNode; ek?: ReactNode; ilkKapali?: boolean; children: ReactNode; sinif?: string;
}) {
  const [kapali, setKapali] = useState(!!ilkKapali);
  return (
    <div className={`ck-grp${kapali ? ' kapali' : ''}${sinif ? ' ' + sinif : ''}`}>
      <h6 onClick={() => setKapali(k => !k)} role="button" aria-expanded={!kapali}>
        <span className="ck-ok">{kapali ? '▸' : '▾'}</span>{baslik}{ek && <span className="ck-ek">{ek}</span>}
      </h6>
      {!kapali && children}
    </div>
  );
}
