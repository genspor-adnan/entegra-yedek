import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * TETKİK KATALOĞU SOL PANELİ (492) - "Bölüm / Çalışma Grubu" + "Paneller".
 * Mockup: Ekranlar/Lab/lab_tetkik_katalogu.html sol kolonu.
 *
 * Katalogda gezinmenin iki doğal yolu var: tetkiğin NEREDE çalışıldığı (bölüm)
 * ve HANGİ İSTEMDE birlikte gittiği (panel). Üstteki bölüm combosu tek satırda
 * aynı işi görüyor ama sayıları göstermiyordu - "biyokimyada kaç tetkik var"
 * sorusu listeyi süzmeden cevaplanmalı.
 *
 * SAYIM SUNUCUDAN: sayfalı listede istemci yalnızca 50 satır görür, oradan
 * sayarsa yanlış toplam yazardı.
 *
 * PANEL SEÇİMİ tetkik kimlikleriyle süzer (üyelik kuralı sunucuda çözülür);
 * bölüm seçimi `bolum` kolonuna eşitlik filtresidir - ikisi de aynı liste
 * filtre mekanizmasını kullanır, ekran kendi başına satır ayıklamaz.
 */
export interface AgacSecim {
  /** Seçili bölüm kodu ('' = tümü). */
  bolum: string;
  /** Seçili panelin tetkik kimlikleri (null = panel süzgeci yok). */
  panelIdleri: number[] | null;
  panelAdi: string;
}

interface Bolum { kod: number; ad: string; ikon: string; adet: number; aktif: number }
interface Panel { id: number; ad: string; durum: number; tetkikIdleri: number[] }

export const BOS_SECIM: AgacSecim = { bolum: '', panelIdleri: null, panelAdi: '' };

export function LabKatalogAgaci({ secim, onSecim }: {
  secim: AgacSecim; onSecim(s: AgacSecim): void;
}) {
  const [toplam, setToplam] = useState(0);
  const [bolumler, setBolumler] = useState<Bolum[]>([]);
  const [paneller, setPaneller] = useState<Panel[]>([]);
  const [hata, setHata] = useState('');

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.labTetkikAgaci();
        if (iptal) return;
        setToplam(Number(y.toplam) || 0);
        setBolumler(y.bolumler as unknown as Bolum[]);
        setPaneller(y.paneller as unknown as Panel[]);
        setHata('');
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, []);

  if (hata) return <div className="lab-detay"><div className="hata-kutusu">{hata}</div></div>;

  const tumuSecili = secim.bolum === '' && secim.panelIdleri === null;

  return (
    <div className="lab-detay lab-katalog-agac">
      <div className="kagrup">
        <h6>Bölüm / Çalışma Grubu</h6>
        <ul className="agac-liste">
          <li className={tumuSecili ? 'sec' : ''}
              onClick={() => onSecim(BOS_SECIM)}>
            <span className="ikon">📂</span> Tüm tetkikler
            <span className="sp">{toplam}</span>
          </li>
          {bolumler.map(b => (
            <li key={b.kod}
                className={secim.bolum === String(b.kod) && secim.panelIdleri === null ? 'sec' : ''}
                onClick={() => onSecim({ ...BOS_SECIM, bolum: String(b.kod) })}>
              <span className="ikon">{b.ikon}</span> {b.ad}
              <span className="sp">{b.adet}</span>
            </li>
          ))}
          {bolumler.length === 0 && <li className="sonuk">Tetkik yok</li>}
        </ul>
      </div>

      <div className="kagrup">
        <h6>Paneller <span className="sp">{paneller.length}</span></h6>
        <ul className="agac-liste">
          {paneller.map(p => (
            <li key={p.id}
                className={secim.panelIdleri !== null && secim.panelAdi === p.ad ? 'sec' : ''}
                onClick={() => onSecim({
                  bolum: '',
                  // Uyesi olmayan panelde bos dizi: liste bos gorunur, "hepsi"
                  //   gibi davranip yaniltmaz.
                  panelIdleri: p.tetkikIdleri ?? [],
                  panelAdi: p.ad,
                })}>
              <span className="ikon">📦</span> {p.ad}
              <span className="sp">{(p.tetkikIdleri ?? []).length} tetkik</span>
            </li>
          ))}
          {paneller.length === 0 && <li className="sonuk">Panel tanımlı değil</li>}
        </ul>
      </div>
    </div>
  );
}
