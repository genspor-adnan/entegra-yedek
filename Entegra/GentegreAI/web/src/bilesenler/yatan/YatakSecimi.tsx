import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { YatakSecenegi } from '../../api/uclar/yatan';

/**
 * YATAK SEÇİMİ — mockup `Ekranlar/Yatan/yatis_kabul.html` ve
 * `nakil_yatak_degisim.html` (`.yataklar` / `.yk`).
 *
 * <b>Kutu dizisi, açılır liste değil.</b> "Hangi yatak" sorusunun cevabı oda
 * kurallarıyla BİRLİKTE verilir: açılır listede cinsiyet kuralı, izolasyon ve
 * oda arkadaşı görünmez.
 *
 * <b>Uygun olmayan yatak gizlenmez, sebebiyle gösterilir</b> (soluk, tıklanmaz).
 * Listeden düşseydi kabul memuru "yer yok" der ve telefonla servise sorardı;
 * sebebi görünce "temizlik bitsin" ya da "oda kuralını değiştir" diyebiliyor.
 *
 * Uygunluk KARARI SUNUCUNUNDUR (`/api/yatan/yatak-secenekleri`): aynı kural
 * kabul ucunda da çalışır. İstemciye kopyalansaydı iki kural sessizce ayrışır
 * ve ekranın "uygun" dediği yatak kaydederken reddedilirdi.
 */

const ODA_TUR: Record<number, string> = {
  1: 'tek kişilik', 2: 'çift kişilik', 3: 'çok yataklı',
  4: 'suit', 5: 'yoğun bakım', 6: 'doğum',
};
const CINSIYET_KURALI: Record<number, string> = {
  0: 'cinsiyet serbest', 1: 'kadın odası', 2: 'erkek odası',
  3: 'ilk yatan kuralı kilitler',
};
const IZOLASYON: Record<number, string> = {
  1: 'temaslı izolasyon', 2: 'damlacık izolasyon',
  3: 'solunum izolasyonu', 4: 'koruyucu izolasyon',
};

export function YatakSecimi({ hastaId, departmanId, seciliId, haricYatakId, onSec }: {
  hastaId: number;
  departmanId?: number | null;
  seciliId: number | null;
  /** Nakilde hastanın MEVCUT yatağı listede seçilemez olmalı. */
  haricYatakId?: number | null;
  onSec(y: YatakSecenegi): void;
}) {
  const [yataklar, setYataklar] = useState<YatakSecenegi[] | null>(null);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    if (!hastaId) { setYataklar([]); return }
    try {
      const y = await api.yatakSecenekleri(hastaId, departmanId ?? null);
      setYataklar(y.yataklar);
      setHata('');
    } catch { setHata('Yatak listesi alınamadı.') }
  }, [hastaId, departmanId]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!yataklar) return <div className="sonuk" style={{ padding: 8 }}>Yataklar yükleniyor…</div>;
  if (yataklar.length === 0)
    return <div className="sonuk" style={{ padding: 8 }}>Tanımlı yatak yok.</div>;

  const uygunSayi = yataklar.filter(y => y.uygun && y.id !== haricYatakId).length;

  return (
    <>
      <div className="not" style={{ marginBottom: 6 }}>
        {uygunSayi} yatak verilebilir · {yataklar.length - uygunSayi} yatak
        gerekçesiyle soluk gösteriliyor.
      </div>
      <div className="yatak-secim">
        {yataklar.map(y => {
          const mevcut = y.id === haricYatakId;
          const olmaz = !y.uygun || mevcut;
          const secili = y.id === seciliId;
          const oda = [ODA_TUR[y.odaTur] ?? '', CINSIYET_KURALI[y.cinsiyetKurali] ?? '']
            .filter(Boolean).join(' · ');
          return (
            <div key={y.id}
                 className={`yk${secili ? ' secili' : ''}${olmaz ? ' olmaz' : ''}`}
                 onClick={() => { if (!olmaz) onSec(y) }}
                 title={olmaz ? (mevcut ? 'Hasta hâlihazırda bu yatakta' : y.engel) : ''}>
              <div className="kod">{y.oda} / {y.yatak}</div>
              <div className="alt">
                {olmaz ? `✗ ${mevcut ? 'mevcut yatak' : y.engel}` : oda}
                <br />
                {olmaz
                  ? oda
                  : (<>
                      {y.izolasyon > 0
                        ? IZOLASYON[y.izolasyon]
                        : (y.klinik || '—')}
                      {y.ucretHizmet && <> · {y.ucretHizmet}</>}
                      {secili && <> · <b>seçildi</b></>}
                    </>)}
              </div>
            </div>
          );
        })}
      </div>
    </>
  );
}
