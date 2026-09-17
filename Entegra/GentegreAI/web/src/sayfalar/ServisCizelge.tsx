import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { ServisCizelgesi, CizelgeZiyareti } from '../api/uclar/servis';
import { guvenli, mesaj } from '../bilesenler/mesaj';

/**
 * TEKNİSYEN ÇİZELGESİ (775) — mockup `Ekranlar/TeknikServis/teknik_servis_saha.html`
 * "Teknisyen Çizelgesi" sekmesi.
 *
 * NEDEN AYRI SAYFA. Generic liste satır çizer, blok çizmez: "kimde boş
 * kapasite var" sorusu ancak zaman ekseninde görülür. Ziyaret listesi aynı
 * veriyi taşıyor ama o "ne yapıldı" sorusunun ekranı.
 *
 * ZİYARETİ OLMAYAN TEKNİSYEN DE SATIR AÇAR: çizelgenin asıl sorusu boş
 * kapasitedir; yalnız dolu satırları göstermek, iş atanacak kişiyi ekrandan
 * silerdi.
 *
 * SÜREN ZİYARET ŞİMDİYE KADAR UZAR (sunucu kuralı): kapanmamış işi bir
 * saatlik blok göstermek, üç saattir süren işi bitmiş gibi gösterirdi.
 */
const SONUC_SINIF: Record<number, string> = {
  0: 'suruyor', 1: 'bitti', 2: 'gec', 3: 'bekliyor', 4: 'iptal',
};
const SONUC_AD: Record<number, string> = {
  0: 'sürüyor', 1: 'çözüldü', 2: 'çözülemedi', 3: 'parça bekliyor', 4: 'iptal',
};

/** Çizelge penceresi: 08:00-19:00. Dışına taşan blok kenara yapışır. */
const BAS_SAAT = 8, BIT_SAAT = 19;

const saatYaz = (d: string) =>
  new Date(d).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

export function ServisCizelge() {
  const git = useNavigate();
  const [tarih, setTarih] = useState(() => new Date().toISOString().slice(0, 10));
  const [veri, setVeri] = useState<ServisCizelgesi | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<CizelgeZiyareti | null>(null);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    void (async () => {
      try { setVeri(await api.servisCizelge(tarih)); setHata(null) }
      catch (h) { setHata(hataMetni(h)) }
    })();
  }, [tarih, yenile]);

  const saatler = useMemo(
    () => Array.from({ length: BIT_SAAT - BAS_SAAT + 1 }, (_, i) => BAS_SAAT + i), []);

  /** Bloğun soldan konumu ve genişliği - pencereye kırpılır. */
  const yerlesim = (z: CizelgeZiyareti) => {
    const gun = new Date(tarih + 'T00:00:00');
    const saat = (s: string) => {
      const d = new Date(s);
      return (d.getTime() - gun.getTime()) / 3600000;
    };
    const pencere = BIT_SAAT - BAS_SAAT;
    const bas = Math.max(saat(z.bas) - BAS_SAAT, 0);
    const bit = Math.min(Math.max(saat(z.bit) - BAS_SAAT, bas + 0.25), pencere);
    if (bit <= 0 || bas >= pencere) return null;
    return { left: `${(bas / pencere) * 100}%`, width: `${((bit - bas) / pencere) * 100}%` };
  };

  const ata = (cagriId: number) => guvenli(async () => {
    const y = await api.servisIsEmriAc(cagriId);
    mesaj(`İş emri açıldı: ${y.isEmriNo || `#${y.id}`}\n\n`
        + 'Teknisyen ataması iş emri kartından ya da ziyaret başlatılırken '
        + 'yapılır - çağrı artık "atandı" ve SLA yanıt süresi damgalandı.');
    setYenile(t => t + 1);
  });

  const o = veri?.ozet;
  const gunDegis = (fark: number) => {
    const d = new Date(tarih + 'T00:00:00');
    d.setDate(d.getDate() + fark);
    setTarih(d.toISOString().slice(0, 10));
  };

  return (
    <div className="sayfa">
      <div className="sayfabas">
        <div className="basrow">
          <h1>Teknisyen Çizelgesi</h1>
          <span className="yol">Teknik Servis › Çizelge</span>
        </div>
      </div>

      <div className="cz-sayfa">
        <div className="cp-arac">
          <button className="d" onClick={() => gunDegis(-1)}>‹ Önceki gün</button>
          <input type="date" value={tarih} onChange={e => setTarih(e.target.value)} />
          <button className="d" onClick={() => gunDegis(1)}>Sonraki gün ›</button>
          <button className="d" onClick={() => setTarih(new Date().toISOString().slice(0, 10))}>
            Bugün
          </button>
          <span style={{ marginLeft: 'auto', display: 'inline-flex', gap: 6 }}>
            <button className="d" onClick={() => git('/servis-ziyaret')}>📍 Ziyaret Listesi</button>
            <button className="d" onClick={() => setYenile(t => t + 1)}>⟳ Tazele</button>
          </span>
        </div>

        {o && (
          <div className="cz-ozet">
            <div className="kutu"><b>Teknisyen</b><span>{o.teknisyen}</span></div>
            <div className="kutu"><b>Ziyaret</b><span>{o.ziyaret}</span></div>
            <div className="kutu"><b>Süren</b><span>{o.suren}</span></div>
            <div className="kutu ok"><b>Çözüldü</b><span>{o.cozuldu}</span></div>
            {/* ÇÖZÜLEMEYEN = İKİNCİ GİDİŞ: ücretsiz yol demektir, günün asıl
                verimlilik kaybı burada görünür. */}
            <div className="kutu sari"><b>Çözülemedi</b>
              <span>{o.cozulemedi}<small>ikinci gidiş gerekiyor</small></span></div>
            <div className="kutu kir"><b>Atanmamış çağrı</b>
              <span>{o.atanmamis}<small>SLA işliyor</small></span></div>
            <div className="kutu"><b>Yol</b><span>{o.yolKm}<small>km</small></span></div>
          </div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="cz-tablo">
          <div className="cz-bas">
            <div className="cz-basoda">Teknisyen</div>
            <div className="cz-serit">
              {saatler.map((s, i) => (
                <div key={s} className="cz-saat"
                     style={{ left: `${(i / (saatler.length - 1)) * 100}%` }}>
                  {String(s).padStart(2, '0')}:00
                </div>
              ))}
            </div>
          </div>

          {(veri?.teknisyenler ?? []).map(t => {
            const bloklar = (veri?.ziyaretler ?? []).filter(z => z.teknisyenId === t.id);
            const km = bloklar.reduce((x, z) => x + Number(z.yolKm || 0), 0);
            return (
              <div className="cz-satir" key={t.id}>
                <div className="cz-oda">
                  <b>{t.ad}</b>
                  <span>{[t.gorev || t.rolAdi,
                          bloklar.length ? `${bloklar.length} ziyaret` : 'boş',
                          km ? `${km} km` : ''].filter(Boolean).join(' · ')}</span>
                </div>
                <div className="cz-serit">
                  {saatler.map((s, i) => (
                    <div key={s} className="cz-cizgi"
                         style={{ left: `${(i / (saatler.length - 1)) * 100}%` }} />
                  ))}
                  {bloklar.map(z => {
                    const y = yerlesim(z);
                    if (!y) return null;
                    return (
                      <div key={z.id} style={y} onClick={() => setSecili(z)}
                           className={`cz-blok ${SONUC_SINIF[z.sonuc] ?? ''}`
                             + (z.slaAsildi === 1 ? ' gec' : '')
                             + (secili?.id === z.id ? ' sel' : '')}
                           title={`${z.tarafAdi} · ${z.cihaz}\n`
                             + `${saatYaz(z.bas)}–${z.sonuc === 0 ? '' : saatYaz(z.bit)}`
                             + ` · ${SONUC_AD[z.sonuc]}`
                             + (z.yolKm ? `\nYol ${z.yolKm} km` : '')
                             + (z.slaAsildi === 1 ? '\nSLA AŞILDI' : '')}>
                        <b>{z.cagriNo || z.isEmriNo || 'Ziyaret'}</b>
                        <span>{z.tarafAdi}{z.cihaz ? ` · ${z.cihaz}` : ''}
                          {' · '}{saatYaz(z.bas)}</span>
                      </div>
                    );
                  })}
                  {bloklar.length === 0 && <div className="cz-bos">— boş —</div>}
                </div>
              </div>
            );
          })}

          {/* ATANMAMIŞ ZİYARET (teknisyeni olmayan kayıt) kimsenin satırında
              görünmez; ayrı bir satırda toplanır ki kaybolmasın. */}
          {(veri?.ziyaretler ?? []).some(z => !z.teknisyenId) && (
            <div className="cz-satir">
              <div className="cz-oda"><b>Teknisyensiz</b>
                <span>ziyaret açılmış, kimseye atanmamış</span></div>
              <div className="cz-serit">
                {(veri?.ziyaretler ?? []).filter(z => !z.teknisyenId).map(z => {
                  const y = yerlesim(z);
                  return y ? (
                    <div key={z.id} style={y} className="cz-blok bekliyor"
                         onClick={() => setSecili(z)}>
                      <b>{z.cagriNo || z.isEmriNo}</b><span>{z.tarafAdi}</span>
                    </div>
                  ) : null;
                })}
              </div>
            </div>
          )}

          {(veri?.teknisyenler ?? []).length === 0 && (
            <div className="bos" style={{ padding: 18 }}>
              Servis yetkisi olan kullanıcı yok. Çizelgeye satır açılabilmesi için
              bir rolde <b>Teknik Servis</b> yetkisi tanımlı olmalı.
            </div>
          )}
        </div>
      </div>

      {/* ATANMAMIŞ ÇAĞRILAR ÇİZELGENİN YANINDA: kimsenin işi değil ama SLA
          işliyor. Boş kapasiteyi gören kişi buradan iş emri açar. */}
      {(veri?.atanmamis ?? []).length > 0 && (
        <div className="kagrup">
          <h6>Atanmamış Çağrılar <span className="sonuk">— SLA saati işliyor</span></h6>
          <table className="detay-tablo">
            <thead>
              <tr><th>Çağrı</th><th>Müşteri</th><th>Cihaz</th><th>Bölge</th>
                <th className="sag">SLA (dk)</th><th /></tr>
            </thead>
            <tbody>
              {(veri?.atanmamis ?? []).map(c => (
                <tr key={c.id}>
                  <td>{c.cagriNo || `#${c.id}`}</td>
                  <td>{c.tarafAdi}</td>
                  <td>{c.cihaz}</td>
                  <td>{c.bolge}</td>
                  <td className={`sag${(c.slaKalanDk ?? 1) < 0 ? ' hata' : ''}`}>
                    {c.slaKalanDk ?? '—'}
                  </td>
                  <td className="sag">
                    <button className="d mini" onClick={() => ata(c.id)}>
                      İş Emri Aç
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {secili && (
        <div className="kagrup">
          <h6>{secili.cagriNo || secili.isEmriNo} — {secili.tarafAdi}</h6>
          <div className="ic" style={{ padding: '8px 10px' }}>
            <b>{secili.cihaz}</b> · {saatYaz(secili.bas)}
            {secili.sonuc !== 0 ? `–${saatYaz(secili.bit)}` : ' (sürüyor)'}
            {' · '}{SONUC_AD[secili.sonuc]}
            {secili.yolKm ? ` · ${secili.yolKm} km` : ''}
            {secili.arac ? ` · ${secili.arac}` : ''}
            {secili.mesaiDisi === 1 ? ' · mesai dışı' : ''}
            {secili.yapilan && <div className="sonuk" style={{ marginTop: 4 }}>
              {secili.yapilan}</div>}
            <div style={{ marginTop: 8, display: 'flex', gap: 6 }}>
              <button className="d" onClick={() => git('/servis-ziyaret')}>
                📍 Ziyaret listesinde aç
              </button>
              <button className="d" onClick={() => git('/servis-is-emri')}>
                🗂️ İş emri listesi
              </button>
              <button className="d" onClick={() => setSecili(null)}>Kapat</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
