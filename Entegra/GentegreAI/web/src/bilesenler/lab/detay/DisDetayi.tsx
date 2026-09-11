import { tarihSaat } from '../../bicim';
import {
  sayi, } from '../../labKodlari';
import { dizi, metin, kodEki } from './ortak';

/** Panelde cizilen sunucu kaydi - alanlar kaynaga gore degisir. */
type Kayit = Record<string, unknown>;

export function DisDetayi({ veri }: { veri: Kayit }) {
  const g = (veri.gonderim ?? {}) as Kayit;
  const satirlar = dizi(veri.satirlar);
  const TASIMA: Record<number, string> = {
    1: 'Oda sıcaklığı', 2: 'Soğuk (2-8 °C)', 3: 'Dondurulmuş (-20 °C)',
    4: 'Kuru buz (-70 °C)',
  };
  const SDURUM: Record<number, string> = {
    1: 'Gönderildi', 2: 'Sonuç geldi', 3: 'Dış lab reddetti', 4: 'Numune kayboldu',
  };

  return (
    <div className="lab-ana-yan">
      <div className="kagrup">
        <h6>
          {metin(g.gonderimNo)} · Gönderilen tetkikler
          <span className="sp">{satirlar.length} tetkik</span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Hasta</th><th>Tetkik</th><th className="orta">Barkod</th>
                <th className="sag">Sonuç</th><th className="orta">Sonuç zamanı</th>
                <th className="orta">Durum</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map(s => (
                <tr key={String(s.id)}
                    className={Number(s.durum ?? 1) >= 3 ? 'panik' : ''}>
                  <td>{metin(s.hasta)}</td>
                  <td>
                    <b>{metin(s.ad)}</b>
                    {kodEki(s.ad, s.kod) &&
                      <span className="not"> {kodEki(s.ad, s.kod)}</span>}
                  </td>
                  <td className="orta not">{metin(s.barkod) || '—'}</td>
                  <td className="sag">{metin(s.deger) || <span className="not">bekliyor</span>}</td>
                  <td className="orta not">
                    {s.sonucZamani ? tarihSaat(s.sonucZamani) : '—'}
                  </td>
                  <td className="orta">
                    <span className={Number(s.durum ?? 1) >= 3 ? 'rozet hata'
                                   : Number(s.durum) === 2 ? 'rozet olumlu' : 'rozet gri'}>
                      {SDURUM[Number(s.durum ?? 1)] ?? ''}
                    </span>
                  </td>
                </tr>
              ))}
              {satirlar.length === 0 && (
                <tr><td colSpan={6} className="not">Gönderim satırı yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {satirlar.filter(s => metin(s.retNeden)).map(s => (
          <div className="ic sonuk" key={`r${s.id}`}>
            <b>{metin(s.kod)} reddedildi:</b> {metin(s.retNeden)}
          </div>
        ))}
      </div>

      <div className="kagrup">
        <h6>Kurye / soğuk zincir</h6>
        <div className="lab-alanlar">
          <div className="fld" style={{ gridColumn: '1 / -1' }}>
            <label>Dış laboratuvar</label>
            <div className="deger buyuk">{metin(g.disLab) || '—'}</div>
          </div>
          <div className="fld">
            <label>Kurye</label>
            <div className="deger">
              {[metin(g.kuryeFirma), metin(g.kuryeAd)].filter(Boolean).join(' · ') || '—'}
            </div>
          </div>
          <div className="fld">
            <label>Telefon</label>
            <div className="deger">{metin(g.kuryeTel) || '—'}</div>
          </div>
          {/* SOĞUK ZİNCİR: -20 °C isteyen numune oda sıcaklığında gittiyse
              sonuç geçersizdir; kayıt sonradan sorulur. */}
          <div className="fld">
            <label>Taşıma koşulu</label>
            <div className="deger">{TASIMA[Number(g.tasimaKosulu ?? 2)] ?? '—'}</div>
          </div>
          <div className="fld">
            <label>Sıcaklık / kap</label>
            <div className="deger">
              {g.sicaklik ? `${sayi(g.sicaklik, 1)} °C` : '—'} · {String(g.kapSayisi ?? 1)} kap
            </div>
          </div>
          <div className="fld">
            <label>Gönderim</label>
            <div className="deger">
              {g.gonderimZamani ? tarihSaat(g.gonderimZamani) : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Teslim</label>
            <div className="deger">
              {g.teslimZamani ? tarihSaat(g.teslimZamani) : '—'}
              {metin(g.teslimAlan) ? ` · ${metin(g.teslimAlan)}` : ''}
            </div>
          </div>
          <div className="fld">
            <label>Dış kabul no</label>
            <div className="deger">{metin(g.disKabulNo) || '—'}</div>
          </div>
          <div className="fld">
            <label>Alış faturası</label>
            <div className="deger">{metin(g.faturaNo) || 'eşleştirilmedi'}</div>
          </div>
        </div>
      </div>
    </div>
  );
}

