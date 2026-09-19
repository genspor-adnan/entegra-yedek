import type { ReactNode } from 'react';
import type { SterilEtiket } from '../../api/uclar/steril';

/** Sterilizasyon (868) ekranlarının ortak parçaları. */
export const zaman = (d?: string | null) => d ? new Date(d).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—';
export const tarih = (d?: string | null) => d ? new Date(d).toLocaleDateString('tr-TR') : '—';
export const saat = (d?: string | null) => d ? new Date(d).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—';

/** İndikatör sonucu rozeti: 0 bekliyor · 1 geçti · 2 kaldı · 3 inkübasyonda; null = yok. */
export function SonucRozeti({ s, yok = '—' }: { s?: number | null; yok?: string }) {
  if (s === null || s === undefined) return <span className="sonuk">{yok}</span>;
  const [ad, cls] = s === 1 ? ['geçti', 'ok'] : s === 2 ? ['KALDI', 'kir'] : s === 3 ? ['inkübasyonda', 'sari'] : ['bekliyor', 'sari'];
  return <span className={`st-rz ${cls}`}>{ad}</span>;
}

export function DurumRozeti({ durum, ad }: { durum: number; ad: string }) {
  const cls = durum === 4 || durum === 7 || durum === 3 ? 'ok' : durum === 6 || durum === 9 || durum === 10 || durum === 5 ? 'kir' : durum === 2 || durum === 1 ? 'mavi' : 'sari';
  return <span className={`st-rz ${cls}`}>{ad}</span>;
}

/** Salt okunur etiket + değer satırı. */
export function Al({ lb, v, g2 = false }: { lb: string; v: ReactNode; g2?: boolean }) {
  return <div className={`al${g2 ? ' g2' : ''}`}><span className="lb">{lb}</span><span className="inp ro">{v}</span></div>;
}

/** Paket etiketi önizleme (50×30 mm mantığı): barkod, içerik, cihaz/döngü, tarih, SKT, operatör. */
export function Etiket({ e }: { e: SterilEtiket }) {
  return (
    <div className="st-etk">
      <div className="bas">🦷 GenoTIP · STERİL PAKET</div>
      <div className="bar" />
      <div className="kod">{e.barkod}</div>
      <table><tbody>
        <tr><td>İçerik</td><td><b>{e.icerik}</b></td></tr>
        <tr><td>Cihaz / döngü</td><td>{e.cihaz} · #{e.donguNo}</td></tr>
        <tr><td>Sterilizasyon</td><td>{zaman(e.tarih)}</td></tr>
        <tr><td>Son kullanma</td><td className="skt">{e.skt ? tarih(e.skt) : 'olay bazlı'}</td></tr>
        <tr><td>Operatör</td><td>{e.operatorAdi || '—'}{e.raf ? ` · ${e.raf}` : ''}</td></tr>
      </tbody></table>
      <div className="alt">Paket açık / ıslak / yırtık ise KULLANMA · sınıf 4 şerit koyu = geçti</div>
    </div>
  );
}
