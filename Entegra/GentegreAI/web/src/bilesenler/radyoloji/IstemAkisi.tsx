import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';

/**
 * ISTEM AKIS SERIDI + OZET (310) - mockup radyoloji_istem_karti.html.
 *
 * Kartin ust seridi: İstem → Randevu → Çekim → Raporlanıyor → Onay → Teslim.
 * Adimlar DURUM alanindan degil GERCEK ZAMAN DAMGALARINDAN cizilir: durum tek
 * bir sayidir, "randevu verildi mi, ne zaman cekildi" sorusunu tasiyamaz.
 * Zaman damgasi olan adim tamamlanmis, ilk bos adim SIMDIKI adimdir.
 *
 * Alttaki ozet (bekleme suresi, rapor durumu, olusturan) kalite gostergesidir:
 * "istemden cekime kac dakika" sorusu yonetim raporunun cekirdegi.
 */

interface Akis {
  accessionNo: string; durum: number;
  istemZamani: string | null; randevuZamani: string | null;
  cekimZamani: string | null; raporZamani: string | null;
  onayZamani: string | null; teslimZamani: string | null;
  raporDurum: number; raporNo: string; raporYazan: string;
  olusturan: string; beklemeDk: number | null;
}

const RAPOR_DURUM: Record<number, string> = {
  0: 'Yok', 1: 'Taslak', 2: 'Uzman onayında', 3: 'Onaylı', 4: 'Ek rapor',
};

/** "31.08.2026 09:23" - saatsiz gosterim adimi anlamsiz kilardi. */
const zaman = (v: string | null): string => {
  const m = String(v ?? '');
  if (!/^\d{4}-\d{2}-\d{2}/.test(m)) return '—';
  const [g, s] = m.split('T');
  return g.split('-').reverse().join('.') + (s ? ' ' + s.slice(0, 5) : '');
};

export function IstemAkisi({ istemId }: { istemId: number }) {
  const [akis, setAkis] = useState<Akis | null>(null);

  const yukle = useCallback(async () => {
    try {
      setAkis(await api.radyolojiIstemAkis(istemId) as unknown as Akis);
    } catch { /* akis gelmezse kart yine calisir - alanlar asil veridir */ }
  }, [istemId]);

  useEffect(() => { void yukle() }, [yukle]);

  if (!akis) return null;

  const adimlar = [
    { ad: 'İstem',        zaman: akis.istemZamani },
    { ad: 'Randevu',      zaman: akis.randevuZamani },
    { ad: 'Çekim',        zaman: akis.cekimZamani },
    { ad: 'Raporlanıyor', zaman: akis.raporZamani },
    { ad: 'Onay',         zaman: akis.onayZamani },
    { ad: 'Teslim',       zaman: akis.teslimZamani },
  ];
  // SIMDIKI adim: zamani olmayan ILK adim. Iptal edilmis istemde (durum 0)
  //   simdiki adim yoktur - akis durmustur.
  const simdiki = akis.durum === 0 ? -1 : adimlar.findIndex(a => !a.zaman);

  return (
    <div className="rad-akis">
      <div className="akis-seridi">
        {adimlar.map((a, i) => (
          <div key={a.ad}
               className={'adim' + (a.zaman ? ' ok' : i === simdiki ? ' simdi' : '')}>
            <span className="ad">{a.ad}</span>
            <span className="zm">{a.zaman ? zaman(a.zaman) : '—'}</span>
          </div>
        ))}
      </div>
      <div className="akis-ozet">
        <span>İstem No: <b>{akis.accessionNo}</b></span>
        <span>Bekleme (istem→çekim):{' '}
          <b>{akis.beklemeDk == null ? '—' : `${akis.beklemeDk} dk`}</b></span>
        <span>Rapor: <b>{RAPOR_DURUM[akis.raporDurum] ?? '—'}</b>
          {akis.raporNo ? ` · ${akis.raporNo}` : ''}
          {akis.raporYazan ? ` · ${akis.raporYazan}` : ''}</span>
        <span>Oluşturan: <b>{akis.olusturan || '—'}</b>
          {akis.istemZamani ? ` · ${zaman(akis.istemZamani)}` : ''}</span>
      </div>
    </div>
  );
}
