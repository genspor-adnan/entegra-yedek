import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { EnabizMesaji, EnabizMesajKapisi } from '../api/uclar/enabiz';
import { hataMetni } from '../api/sozlesme';
import { Modal } from './Modal';
import { guvenli, mesaj as bildir, onay } from './mesaj';
import { tarihSaat } from './bicim';
import { c as cev } from '../dil/ceviri';

/**
 * HASTANIN e-NABIZ PROFİLİNE MESAJ (877 · 881 — KTS maddeleri H7 / D14).
 *
 * <b>Mesaj kuyruğa girer, ekranda beklenmez.</b> Hekim "Gönder" deyince satır
 * yazılır; satır arka planda <b>411 Doktor Mesajı</b> USS paketine dönüşür ve
 * gönderimi e-Nabız kuyruğu yapar. Hekim Bakanlık servisini beklemez.
 *
 * <b>Durum sütunu iki şeyi birden söyler:</b> "Kuyrukta" satırın henüz pakete
 * dönüşmediğini (çoğunlukla başvurunun takip numarası beklendiğini),
 * "Gönderildi" paketin üretilip gönderim kuyruğuna girdiğini anlatır; paket
 * numarası sağdaki sütunda görünür.
 *
 * <b>Kapı kapalıysa ekran bunu söyler</b> - hekimin bunu bilmeden "gönderdim"
 * sanması, hastaya ulaşmayan bir bilgilendirme bırakırdı.
 *
 * <b>Şablonlar kısa yol, zorunluluk değil</b>: en sık yazılan üç bilgilendirme
 * tek tıkla metne gelir, hekim üstünde değiştirir.
 */
const SABLONLAR: [string, string][] = [
  ['Sonuç hazır', 'Tetkik sonuçlarınız hazırlandı. e-Nabız üzerinden görüntüleyebilirsiniz.'],
  ['Kontrol randevusu', 'Kontrol muayeneniz için randevu almanız önerilir.'],
  ['İlaç kullanımı', 'Reçete edilen ilaçlarınızı tarif edildiği şekilde kullanmayı sürdürünüz.'],
];

const DURUM_ROZET: Record<number, string> = { 0: 'uyari', 1: 'ok', 2: 'hata', 3: 'gri' };

export function EnabizMesajModali({ hastaId, hastaAdi, belgeId, onKapat }: {
  hastaId: number; hastaAdi?: string; belgeId?: number | null; onKapat(): void;
}) {
  const [metin, setMetin] = useState('');
  const [mesajlar, setMesajlar] = useState<EnabizMesaji[]>([]);
  const [kapi, setKapi] = useState<EnabizMesajKapisi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.enabizMesajListe(hastaId);
      setMesajlar(y.mesajlar); setKapi(y.kapi); setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const gonder = async () => {
    const m = metin.trim();
    if (!m) { bildir('Mesaj boş olamaz.'); return }
    await guvenli(async () => {
      await api.enabizMesajYaz({ hastaId, metin: m, belgeId: belgeId ?? null });
      setMetin('');
      bildir(kapi?.acik
        ? 'Mesaj kuyruğa alındı; gönderimi arka planda yapılacak.'
        : 'Mesaj kaydedildi ve kuyrukta bekliyor (e-Nabız gönderimi henüz açık değil).');
      await yukle();
    });
  };

  const vazgec = async (m: EnabizMesaji) => {
    if (!await onay('Bu mesajdan vazgeçilsin mi? Kuyruktan çıkarılır.')) return;
    await guvenli(async () => { await api.enabizMesajVazgec(m.id); await yukle() });
  };

  return (
    <Modal baslik={`💬 e-Nabız mesajı${hastaAdi ? ' · ' + hastaAdi : ''}`} onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" onClick={() => void gonder()}>
               {cev('Gönder')}
             </button>
             <button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>
           </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* KAPI (881): mesaj artık 411 USS paketiyle gidiyor - ayrı hesap/metot
          istemiyor. Kapalıysa sebebi söylenir; mesaj yine kaydedilir. */}
      {kapi && !kapi.acik && (
        <div className="uyari-kutusu">
          {cev('e-Nabız mesaj gönderimi henüz açık değil')} —{' '}
          {!kapi.paketAcik
            ? cev('411 "Doktor Mesajı" paket türü kapalı.')
            : cev('e-Nabız gönderim hesabı (ENABIZ) tanımlı değil.')}{' '}
          {cev('Yazdığınız mesaj kaydedilir ve kapı açılınca gönderilir.')}
        </div>
      )}
      {kapi?.acik && !kapi.gonderimIsi && (
        <div className="uyari-kutusu">
          {cev('Mesajlar 411 paketine dönüşüyor ama e-Nabız gönderim işi (enabiz.gonder) kapalı; paketler kuyrukta bekliyor.')}
        </div>
      )}

      <div className="ds-hdr" style={{ gridTemplateColumns: '1fr' }}>
        <div>
          <label>{cev('Mesaj')} <span className="sonuk">({metin.length}/500)</span></label>
          <textarea rows={4} maxLength={500} value={metin} autoFocus
                    placeholder={cev('Hastanın e-Nabız profiline düşecek düz metin…')}
                    onChange={e => setMetin(e.target.value)} />
        </div>
      </div>

      <div className="ds-arac" style={{ padding: '4px 0' }}>
        <span className="sonuk">{cev('Hazır metin:')}</span>
        {SABLONLAR.map(([ad, govde]) => (
          <span key={ad} className="cip" onClick={() => setMetin(govde)}>{ad}</span>
        ))}
      </div>

      <div className="ds-dg"><table>
        <thead><tr>
          <th className="orta">{cev('Tarih')}</th><th>{cev('Mesaj')}</th>
          <th>{cev('Tür')}</th><th>Hekim</th><th className="orta">{cev('Durum')}</th>
          <th className="orta">{cev('Paket')}</th><th />
        </tr></thead>
        <tbody>
          {mesajlar.map(m => (
            <tr key={m.id}>
              <td className="orta">{tarihSaat(m.eklemeTarihi)}</td>
              <td title={m.sonHata || m.yanitMesaj || undefined}>{m.metin}</td>
              <td className="sonuk" title={m.kaynakAdi}>{m.mesajTuruAdi || m.kaynakAdi}</td>
              <td>{m.hekim || '—'}</td>
              <td className="orta">
                <span className={`rozet ${DURUM_ROZET[m.durum] ?? 'gri'}`}>{m.durumAdi}</span>
                {m.durum === 0 && m.sonHata ? <div className="sonuk">{m.sonHata}</div> : null}
              </td>
              <td className="orta sonuk">{m.paketNo || '—'}</td>
              <td className="orta">
                {m.durum !== 1 && m.durum !== 3 && (
                  <button type="button" className="d" title={cev('Vazgeç')}
                          onClick={() => void vazgec(m)}>✕</button>
                )}
              </td>
            </tr>
          ))}
          {mesajlar.length === 0 && (
            <tr><td colSpan={7} className="sonuk">{cev('Bu hastaya gönderilmiş mesaj yok.')}</td></tr>
          )}
        </tbody>
      </table></div>
    </Modal>
  );
}
