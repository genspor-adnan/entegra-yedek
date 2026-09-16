import type { ReactNode } from 'react';
import { MEDULA_KUYRUK_DURUM, type MedulaKuyrukSatiri } from '../../api/uclar/medula';
import { tarihSaat } from '../../bilesenler/bicim';

/** Medula sayfalarının ortak parçaları: rozet, günlük tablosu, adım şeridi. */
export function Rozet({ d, sozluk }: { d: number | null | undefined; sozluk: Record<number, [string, string]> }) {
  const e = sozluk[d ?? 0] ?? ['—', 'gri'];
  return <span className={`rozet ${e[1]}`}>{e[0]}</span>;
}

export function Adimlar({ adimlar, aktif }: { adimlar: string[]; aktif: number }) {
  return (
    <div className="md-adim">
      {adimlar.map((a, i) => <span key={a} className={i < aktif ? 'ok' : i === aktif ? 'on' : ''}>{a}</span>)}
    </div>
  );
}

export function Sonuc({ tur, children }: { tur: 'ok' | 'kir' | 'sari'; children: ReactNode }) {
  return <div className={`md-sonuc ${tur}`}>{children}</div>;
}

export function Gunluk({ satirlar, govdeAc, tekrar }: {
  satirlar: MedulaKuyrukSatiri[]; govdeAc?(id: number): void; tekrar?(id: number): void;
}) {
  return (
    <div className="md-dg"><table>
      <thead><tr><th>Zaman</th><th>Servis</th><th>İşlem</th><th>Kaynak</th><th>Hasta</th><th className="orta">Durum</th><th>Kod</th><th>Mesaj</th><th className="orta">Deneme</th><th className="sag">Süre</th><th>Kullanıcı</th><th /></tr></thead>
      <tbody>
        {satirlar.map(s => (
          <tr key={s.id}>
            <td>{tarihSaat(s.zaman)}</td><td>{s.servis}</td><td>{s.islem}</td>
            <td className="sonuk">{s.kaynakTablo} {s.kaynakId ?? ''}</td><td>{s.hasta}</td>
            <td className="orta"><Rozet d={s.durum} sozluk={MEDULA_KUYRUK_DURUM} /></td>
            <td>{s.sonucKod}</td><td>{s.sonucMesaj}</td>
            <td className="orta">{s.deneme}{s.sonrakiDeneme && s.durum === 1 ? <span className="sonuk"> · {tarihSaat(s.sonrakiDeneme)}</span> : ''}</td>
            <td className="sag">{s.sureMs ? `${(s.sureMs / 1000).toFixed(1)} sn` : ''}</td><td>{s.kullanici}</td>
            <td className="md-satir-arac">
              {govdeAc && <button className="d" onClick={() => govdeAc(s.id)}>İstek / yanıt</button>}
              {tekrar && (s.durum === 1 || s.durum === 4 || s.durum === 5) && <button className="d" onClick={() => tekrar(s.id)}>↻</button>}
            </td>
          </tr>
        ))}
        {satirlar.length === 0 && <tr><td colSpan={12} className="sonuk">Çağrı yok.</td></tr>}
      </tbody>
    </table></div>
  );
}
