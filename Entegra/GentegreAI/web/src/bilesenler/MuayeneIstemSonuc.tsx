import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj } from './mesaj';
import { tarihSaat } from './bicim';

/**
 * MUAYENE › İSTEM & SONUÇLAR (443).
 *
 * <b>Bağ satırı yetmez.</b> Kartın kendi gridi "şu istem açıldı" der;
 * hekimin ihtiyacı SONUCUN KENDİSİDİR. Yalnız bağ gösterilseydi hekim her
 * sonuç için laboratuvar ekranına gitmek zorunda kalırdı - muayene
 * sırasında olmayacak bir şey.
 *
 * <b>Yalnız onaylı sonuçlar görünür.</b> Laboratuvarın doğrulamadığı bir
 * sayıya göre tedavi başlatılmamalı; bekleyen tetkik "sonuç bekleniyor"
 * olarak listelenir - eksikliğin kendisi de bilgidir.
 *
 * <b>"Gördüm" ayrı bir olaydır</b>: sonucun gelmesi ile hekimin görmesi
 * farklı şeylerdir. Panik değer teyidi ve "sonuç bekliyor" rozetinin
 * kapanması bu işarete bağlı.
 */

type Satir = Record<string, unknown>;

const BOLUM: Record<number, string> = {
  1: 'Biyokimya', 2: 'Hematoloji', 3: 'Hormon', 4: 'Mikrobiyoloji',
  5: 'Seroloji', 6: 'Koagülasyon', 7: 'İdrar', 9: 'Diğer',
};

const BAYRAK: Record<string, string> = {
  LL: '↓↓', HH: '↑↑', L: '↓', H: '↑', N: '',
};

const ISTEM_DURUM: Record<number, string> = {
  1: 'İstendi', 2: 'Numune alındı', 3: 'Çalışılıyor', 4: 'Kısmi sonuç',
  5: 'Onaylandı', 9: 'İptal',
};

const sayiMetni = (v: unknown, b = 2): string => {
  if (v === null || v === undefined || v === '') return '';
  const s = Number(v);
  return Number.isFinite(s) ? s.toLocaleString('tr-TR', { maximumFractionDigits: b })
                            : String(v);
};

export function MuayeneIstemSonuc({ muayeneId }: { muayeneId: number }) {
  const git = useNavigate();
  const [veri, setVeri] = useState<{
    belgeId: number | null; istemler: Satir[]; sonuclar: Satir[];
    kulturler: Satir[]; vakalar: Satir[]; radyoloji: Satir[];
  } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.muayeneSonuclari(muayeneId) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [muayeneId]);

  useEffect(() => { void yukle() }, [yukle]);

  const gordu = (bagId: number) => guvenli(async () => {
    await api.muayeneIstemGordu(bagId);
    mesaj('Sonuç görüldü olarak işaretlendi.');
    await yukle();
  });

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const bosMu = veri.istemler.length === 0 && veri.radyoloji.length === 0;
  if (bosMu) {
    return (
      <div className="kagrup">
        <p className="not ic">
          Bu muayene ve başvurusu için açılmış istem yok. İstem açmak için
          listedeki “🧪 İstem Aç” düğmesini kullanın.
        </p>
      </div>
    );
  }

  const panikVar = veri.sonuclar.some(s => Number(s.panik ?? 0) === 1);

  return (
    <div className="istem-sonuc">
      {/* PANİK UYARISI EN ÜSTTE: hekimin görmesi gereken tek şey buysa,
          tabloların arasında kaybolmamalı. */}
      {panikVar && (
        <div className="uyari-kutusu">
          ⚠ Bu başvuruda PANİK DEĞER var — aşağıdaki tabloda ↑↑/↓↓ ile
          işaretli satırlara bakın.
        </div>
      )}

      {veri.istemler.map(i => {
        const istemId = Number(i.id);
        const satirlar = veri.sonuclar.filter(s => Number(s.istemId) === istemId);
        const kultur = veri.kulturler.filter(k => Number(k.istemId) === istemId);
        const vaka = veri.vakalar.filter(v => Number(v.istemId) === istemId);
        const bagId = Number(i.bagId ?? 0);
        const gorulen = i.hekimGordu ? tarihSaat(i.hekimGordu) : '';

        return (
          <div className="kagrup" key={istemId}>
            <h6>
              <b>{String(i.istemNo ?? '')}</b>
              <span className="rozet">{ISTEM_DURUM[Number(i.durum ?? 1)] ?? ''}</span>
              {Number(i.oncelik ?? 1) === 3 && <span className="rozet uyari">Acil</span>}
              <span className="not">
                {i.istemTarihi ? tarihSaat(i.istemTarihi) : ''}
                {' · '}{String(i.onayli ?? 0)}/{String(i.tetkik ?? 0)} onaylı
              </span>
              <span style={{ marginLeft: 'auto' }} />
              {/* SONUÇ RAPORU: hastaya verilen belge - aynı istemin sayısal,
                  kültür ve genetik sonuçları tek kâğıtta. */}
              <button className="d" onClick={() => git(`/lab/rapor/${istemId}`)}>
                🖨 Sonuç Raporu
              </button>
              {bagId > 0 && (gorulen
                ? <span className="rozet olumlu">Görüldü · {gorulen}</span>
                : <button className="d bir" onClick={() => void gordu(bagId)}>
                    👁 Gördüm
                  </button>)}
            </h6>

            {satirlar.length > 0 && (
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>Tetkik</th><th>Sonuç</th><th>Birim</th><th>Referans</th>
                    <th>Değ.</th><th>Onay</th>
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map((s, n) => {
                    const bayrak = String(s.bayrak ?? '');
                    const ref = String(s.referansMetin ?? '').trim() !== ''
                      ? String(s.referansMetin)
                      : (s.referansAlt !== null || s.referansUst !== null)
                        ? `${sayiMetni(s.referansAlt)} – ${sayiMetni(s.referansUst)}`
                        : '';
                    // SONUCU OLMAYAN SATIR DA GÖRÜNÜR: "bekleniyor" bilgisi
                    //   hekim için sonucun kendisi kadar önemlidir.
                    const bekliyor = !s.deger;
                    return (
                      <tr key={n} className={Number(s.panik ?? 0) === 1 ? 'panik' : ''}>
                        <td>
                          {String(s.ad ?? '')}
                          <span className="not"> {String(s.kod ?? '')}</span>
                          <span className="not">
                            {' · '}{BOLUM[Number(s.bolum ?? 0)] ?? ''}
                          </span>
                        </td>
                        <td className="sag">
                          {bekliyor
                            ? <span className="not">sonuç bekleniyor</span>
                            : <b>{String(s.deger)}</b>}
                        </td>
                        <td>{String(s.birim ?? '')}</td>
                        <td>{ref || '—'}</td>
                        <td className={bayrak === 'LL' || bayrak === 'HH' ? 'vurgu' : ''}>
                          {BAYRAK[bayrak] ?? ''}
                          {Number(s.deltaUyari ?? 0) === 1 && (
                            <span className="not" title="Önceki sonuçtan belirgin sapma">
                              {' '}Δ
                            </span>
                          )}
                        </td>
                        <td className="not">
                          {s.onayZamani ? tarihSaat(s.onayZamani) : ''}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}

            {kultur.map(k => (
              <div className="ic" key={`k${k.id}`}>
                <b>🦠 {String(k.tetkik ?? '')}:</b> {String(k.ozet ?? '')}
                {Number(k.abSayisi ?? 0) > 0 && (
                  <span className="not"> · {String(k.abSayisi)} antibiyotik raporlandı</span>
                )}
                {Number(k.kritik ?? 0) === 1 && (
                  <span className="rozet uyari" style={{ marginLeft: 6 }}>Kritik</span>
                )}
                {String(k.onRapor ?? '').trim() !== '' && !k.onayZamani && (
                  <div className="not">Ön rapor: {String(k.onRapor)}</div>
                )}
                {String(k.uzmanYorum ?? '').trim() !== '' && (
                  <div className="not">{String(k.uzmanYorum)}</div>
                )}
              </div>
            ))}

            {vaka.map(v => (
              <div className="ic" key={`g${v.id}`}>
                <b>🧬 {String(v.test ?? '')} ({String(v.vakaNo ?? '')}):</b>{' '}
                {String(v.ozet ?? '')}
                {Number(v.varyantSayisi ?? 0) > 0 && (
                  <span className="not"> · {String(v.varyantSayisi)} varyant raporlandı</span>
                )}
                {String(v.oneriler ?? '').trim() !== '' && (
                  <div className="not">Öneriler: {String(v.oneriler)}</div>
                )}
              </div>
            ))}
          </div>
        );
      })}

      {veri.radyoloji.length > 0 && (
        <div className="kagrup">
          <h6>Görüntüleme</h6>
          <table className="detay-tablo">
            <thead>
              <tr><th>Tetkik</th><th>Çekim</th><th>Rapor</th><th>Sonuç</th><th /></tr>
            </thead>
            <tbody>
              {veri.radyoloji.map((r, n) => {
                const bagId = Number(r.bagId ?? 0);
                return (
                  <tr key={n}>
                    <td>{String(r.tetkik ?? '')}</td>
                    <td>{r.cekimTarihi ? tarihSaat(r.cekimTarihi) : '—'}</td>
                    <td>
                      {String(r.raporNo ?? '') || (r.onayTarihi ? 'onaylı' : 'bekliyor')}
                    </td>
                    <td>{String(r.sonuc ?? '').slice(0, 160) || '—'}</td>
                    <td>
                      {bagId > 0 && (r.hekimGordu
                        ? <span className="rozet olumlu">Görüldü</span>
                        : <button className="d" onClick={() => void gordu(bagId)}>
                            👁 Gördüm
                          </button>)}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
