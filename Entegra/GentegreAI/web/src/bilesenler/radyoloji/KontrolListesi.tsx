import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { mesaj } from '../mesaj';

/**
 * CEKIM ONCESI KONTROL LISTESI (310) - mockup radyoloji_istem_karti.html.
 *
 * Sorular MODALITEYE gore gelir (MR'da metal/pil, BT'de gebelik ve kreatinin);
 * kaydeden ve zaman her satirda durur - bu iz adli/kalite denetiminde istenen
 * asil seydir.
 *
 * KURAL SUNUCUDA: zorunlu sorular yanitlanmadan istem "Çekildi" yapilamaz
 * (radyoloji_istem tetigi). Buradaki uyari yalnizca ONCEDEN gorunur olsun diye.
 */

interface Soru {
  soruId: number; soru: string; yanitTipi: number; zorunlu: number;
  yanit: string; kayitZamani: string | null; kaydeden: string;
}

const zaman = (v: string | null): string => {
  const m = String(v ?? '');
  if (!/^\d{4}-\d{2}-\d{2}/.test(m)) return '';
  const [g, s] = m.split('T');
  return g.split('-').reverse().join('.') + (s ? ' ' + s.slice(0, 5) : '');
};

export function KontrolListesi({ istemId, saltOkunur }: {
  istemId: number;
  saltOkunur?: boolean;
}) {
  const [sorular, setSorular] = useState<Soru[]>([]);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.radyolojiKontrol(istemId);
      setSorular(y.sorular as unknown as Soru[]);
    } catch (h) { setHata(hataMetni(h)) }
  }, [istemId]);

  useEffect(() => { void yukle() }, [yukle]);

  const degis = (soruId: number, yanit: string) =>
    setSorular(x => x.map(s => (s.soruId === soruId ? { ...s, yanit } : s)));

  const kaydet = async () => {
    setHata('');
    setKaydediyor(true);
    try {
      await api.radyolojiKontrolKaydet(istemId,
        sorular.map(s => ({ soruId: s.soruId, yanit: s.yanit })));
      mesaj('Kontrol listesi kaydedildi.');
      await yukle();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const eksik = sorular.filter(s => s.zorunlu === 1 && !s.yanit.trim());

  if (sorular.length === 0)
    return (
      <div className="not" style={{ padding: 20 }}>
        {hata || 'Bu modalite için tanımlı kontrol sorusu yok.'}
      </div>
    );

  return (
    <div className="kagrup rad-kontrol">
      <h6>Çekim Öncesi Kontrol Listesi</h6>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: '46%' }}>Soru</th>
            <th style={{ width: 150 }}>Yanıt</th>
            <th>Kaydeden</th>
          </tr>
        </thead>
        <tbody>
          {sorular.map(s => (
            <tr key={s.soruId} className={s.zorunlu === 1 && !s.yanit ? 'eksik' : ''}>
              <td>
                {s.soru}
                {s.zorunlu === 1 && <span className="zorunlu-isaret" title="Zorunlu"> *</span>}
              </td>
              <td>
                {/* Evet/hayir sorusunda serbest metin, yanitlari karsilastirilamaz
                    hale getirirdi; olcum sorusu (kreatinin) ise degeri ister. */}
                {s.yanitTipi === 1 ? (
                  <select value={s.yanit} disabled={saltOkunur}
                          onChange={e => degis(s.soruId, e.target.value)}>
                    <option value="">—</option>
                    <option value="Evet">Evet</option>
                    <option value="Hayır">Hayır</option>
                    <option value="Bilinmiyor">Bilinmiyor</option>
                  </select>
                ) : (
                  <input value={s.yanit} maxLength={120} disabled={saltOkunur}
                         onChange={e => degis(s.soruId, e.target.value)} />
                )}
              </td>
              <td className="sonuk">
                {s.kaydeden}{s.kayitZamani ? ` · ${zaman(s.kayitZamani)}` : ''}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {eksik.length > 0 && (
        <div className="uyari-kutusu">
          Zorunlu sorular yanıtlanmadan istem “Çekildi” işaretlenemez. Eksik:{' '}
          {eksik.map(s => s.soru).join(', ')}
        </div>
      )}

      {!saltOkunur && (
        <div className="detay-arac">
          <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
            {kaydediyor ? '⏳ Kaydediliyor…' : '💾 Kontrol Listesini Kaydet'}
          </button>
          <span className="alan-notu">
            Yanıtlar kart kaydından bağımsız, anında yazılır.
          </span>
        </div>
      )}
    </div>
  );
}
