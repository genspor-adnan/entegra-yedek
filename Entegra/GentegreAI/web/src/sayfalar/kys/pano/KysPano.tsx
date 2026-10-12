import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni } from '../../../api/sozlesme';
import type { KysPano as Pano } from '../../../api/uclar/kysPano';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { LISTELER } from '../../listeTanimlari';

/** Bana düşenler tür rozeti (mockup: DÖF kırmızı, olay sarı, karar mavi). */
export const KYS_PANO_TUR_ROZET: Record<string, string> = {
  'DÖF': 'hata', 'Faaliyet': 'hata', 'Olay': 'uyari', 'Karar': 'mavi', 'Denetim': 'bilgi',
};

/**
 * Pano kartının gideceği liste: rota tanımlıysa ve kullanıcı görebiliyorsa adres,
 * değilse null (kart tıklanmaz). Eğitim / kalibrasyon ekranı kurulmamış kurumda
 * sayı yine görünür.
 */
export function kysPanoHedefi(rota: string, gorebilir: (kod: string) => boolean): string | null {
  const l = LISTELER.find(x => (x.rota ?? x.kaynak) === rota);
  if (!l || (l.yetkiKodu && !gorebilir(l.yetkiKodu))) return null;
  return `/${rota}`;
}

const tarih = (s?: string | null) => (s ? new Date(s).toLocaleDateString('tr-TR') : '');

/**
 * KALİTE PANOSU `/kys-pano` (Kurumsal Kalite 1055) — mockup
 * Ekranlar/Kalite2/kalite_panosu.html. Sade: yedi sayı + bana düşen işler.
 * Kartlar ilgili listeye gider; grafik, takvim, komite ajandası yok.
 */
export function KysPano() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [p, setP] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => { api.kysPano().then(setP).catch(h => setHata(hataMetni(h))) }, []);

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!p) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const o = p.ozet;
  const gor = (kod: string) => yetki(kod);
  const kart = (rota: string, baslik: string, deger: number, renk: '' | 'kir' | 'sari', ek?: string) => {
    const hedef = kysPanoHedefi(rota, gor);
    return (
      <div className="fm-kpi" key={rota} role={hedef ? 'button' : undefined} title={hedef ? 'Listeyi aç' : undefined}
           style={hedef ? { cursor: 'pointer' } : undefined} onClick={hedef ? () => git(hedef) : undefined}>
        <div className="b">{baslik}</div>
        <div className={`d${deger && renk ? ` ${renk}` : ''}`}>{deger} {ek && <small>{ek}</small>}</div>
      </div>
    );
  };
  const kalibrasyon = o.kalibrasyonYaklasan + o.kalibrasyonGecen;
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🏆 Kalite Panosu</h1>
        <span className="yol">Kalite › Pano · {tarih(p.bugun)}</span>
        <div className="sag">
          {yetki('kys.olay', 'ekle') && <button className="d bir" onClick={() => git('/kys-olay/yeni?geri=%2Fkys-pano')}>⚠️ Olay / Uygunsuzluk Bildir</button>}
          {yetki('kys.dof', 'ekle') && <button className="d" onClick={() => git('/kys-dof/yeni?geri=%2Fkys-pano')}>＋ Yeni DÖF</button>}
          {yetki('kys.denetim', 'ekle') && <button className="d" onClick={() => git('/kys-denetim/yeni?geri=%2Fkys-pano')}>＋ Denetim Planla</button>}
        </div></div></div>
      <div className="fm-kpis">
        {kart('kys-dof', 'Açık DÖF', o.acikDof, 'kir', o.vadesiGecenDof ? `${o.vadesiGecenDof}'i vadesi geçti` : undefined)}
        {kart('kys-olay', 'Değerlendirilecek bildirim', o.olay, 'sari')}
        {kart('kys-denetim', 'Bu ay denetim', o.denetimAy, '', o.denetimAy ? `${o.denetimYapilan}'i yapıldı` : undefined)}
        {kart('kys-risk', 'Yüksek risk', o.yuksekRisk, 'kir')}
        {kart('kys-hedefler', 'Hedef dışı', o.hedefDisi, 'sari', `/ ${o.hedefToplam} hedef`)}
        {kart('kys-kalibrasyon', 'Kalibrasyonu yaklaşan', kalibrasyon, o.kalibrasyonGecen ? 'kir' : 'sari',
              o.kalibrasyonGecen ? `${o.kalibrasyonGecen}'i geçti` : undefined)}
        {kart('kys-egitim', 'Eksik zorunlu eğitim', o.eksikEgitim, 'sari', 'kişi')}
      </div>
      <section className="fm-bolum">
        <h3 className="fm-bolum-bas">📌 Bana düşenler <span className="sonuk" style={{ fontWeight: 'normal', fontSize: 11 }}>yalnız bana atananlar</span></h3>
        <table className="fm-tablo">
          <thead><tr><th style={{ width: 90 }}>Tür</th><th style={{ width: 150 }}>No</th><th>İş</th><th style={{ width: 160 }}>Birim</th><th style={{ width: 100 }}>Termin</th></tr></thead>
          <tbody>
            {p.banaDusenler.map(x => (
              <tr key={`${x.tur}-${x.id}-${x.is}`} style={{ cursor: 'pointer' }} onClick={() => git(`${x.yol}?geri=%2Fkys-pano`)}>
                <td><span className={`rozet ${KYS_PANO_TUR_ROZET[x.tur] ?? 'gri'}`}>{x.tur}</span></td>
                <td><code>{x.no}</code></td><td>{x.is}</td><td>{x.birim}</td>
                <td style={x.gecikti ? { color: 'var(--hata)', whiteSpace: 'nowrap' } : { whiteSpace: 'nowrap' }}>{tarih(x.termin)}</td>
              </tr>
            ))}
            {!p.banaDusenler.length && <tr><td colSpan={5} className="sonuk">Size atanmış açık iş yok.</td></tr>}
          </tbody>
        </table>
      </section>
    </div>
  );
}
