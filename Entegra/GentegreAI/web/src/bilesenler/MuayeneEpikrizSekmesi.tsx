import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { MuayeneEpikrizKaydi } from '../api/uclar/liste';
import { tarihSaat } from './bicim';
import { c } from '../dil/ceviri';
import { guvenli, mesaj, onay } from './mesaj';

/**
 * MUAYENE › EPİKRİZ (1100, mockup Ekranlar/Muayene/muayene_karti_v7.html).
 *
 * Sekme YALNIZ İSTENİNCE açılır (kullanıcı): Özet › İşlemler › "Epikriz" ya da
 * muayenenin epikriz kaydı varsa. Taslak karttan ücretsiz derlenir (model yok);
 * hekim düzeltir, kaydeder, ayrı adımda imzalar. İmzalı metin kilitlidir -
 * hastaya / sevk kurumuna giden budur, muayene sonradan değişse de aynı kalır.
 */
const BOLUMLER: [keyof MuayeneEpikrizKaydi, string][] = [
  ['sikayet', 'Şikâyet'], ['hikaye', 'Hikâye'], ['bulgular', 'Muayene bulguları'], ['tani', 'Tanı'],
  ['tetkikOzet', 'Tetkik sonuçları'], ['tedavi', 'Uygulanan tedavi'], ['oneriler', 'Sonuç ve öneriler'],
];
const BOS: MuayeneEpikrizKaydi = { sikayet: '', hikaye: '', bulgular: '', tani: '', tetkikOzet: '', tedavi: '', oneriler: '' };

export function MuayeneEpikrizSekmesi({ muayeneId, saltOkunur, onDegisti }: {
  muayeneId: number;
  saltOkunur: boolean;
  /** Kayıt / imza sonrası (Özet listesindeki durum tazelensin). */
  onDegisti?(durum: 'taslak' | 'imzali'): void;
}) {
  const [veri, setVeri] = useState<Awaited<ReturnType<typeof api.muayeneEpikriz>> | null>(null);
  const [form, setForm] = useState<MuayeneEpikrizKaydi>(BOS);
  const [kirli, setKirli] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(() => {
    api.muayeneEpikriz(muayeneId).then(v => {
      setVeri(v);
      // KAYIT YOKSA alanlar taslakla dolar (henüz kaydedilmedi - "kirli").
      const k = v.kayit;
      setForm(k ? Object.fromEntries(BOLUMLER.map(([a]) => [a, String(k[a] ?? '')])) as never : v.taslak);
      setKirli(!k);
      setHata('');
    }).catch(h => setHata(hataMetni(h)));
  }, [muayeneId]);
  useEffect(() => { yukle() }, [yukle]);

  const imzali = veri?.kayit?.imzaDurum === 1;
  const kilitli = imzali || saltOkunur;

  const derle = () => { if (veri) { setForm(veri.taslak); setKirli(true) } };
  const kaydet = () => guvenli(async () => {
    await api.muayeneEpikrizKaydet(muayeneId, form);
    mesaj(c('Epikriz kaydedildi.'));
    onDegisti?.('taslak');
    yukle();
  });
  const imzala = () => guvenli(async () => {
    if (!await onay(c('Epikriz imzalanacak. İmzalı metin değiştirilemez. Onaylıyor musunuz?'))) return;
    if (kirli || !veri?.kayit) await api.muayeneEpikrizKaydet(muayeneId, form);
    await api.muayeneEpikrizImzala(muayeneId);
    mesaj(c('Epikriz imzalandı.'));
    onDegisti?.('imzali');
    yukle();
  });

  if (hata) return <p className="hata-kutusu">{hata}</p>;
  if (!veri) return <p className="not">{c('Yükleniyor…')}</p>;

  return (
    <div className="epk">
      <div className="epk-ust">
        <span className={`rozet ${imzali ? 'ok' : 'uyari'}`}>
          {imzali ? `${c('İmzalı')} · ${tarihSaat(veri.kayit?.imzaZamani)}` : veri.kayit ? c('Taslak') : c('Kaydedilmedi')}
        </span>
        <span className="not">
          {imzali ? c('İmzalı metin değişmez.')
            : veri.kayit ? `${c('Son kayıt')} ${tarihSaat(veri.kayit.kayitZamani)}`
            : c('Alanlar karttan derlendi; düzeltip kaydedin.')}
        </span>
        <span style={{ marginLeft: 'auto' }} />
        {!kilitli && <button type="button" className="d" onClick={derle}>⟳ {c('Karttan yeniden derle')}</button>}
      </div>

      {BOLUMLER.map(([a, ad]) => (
        <label key={a} className="epk-alan">
          <span>{c(ad)}</span>
          <textarea value={form[a]} readOnly={kilitli}
                    onChange={e => { setForm(f => ({ ...f, [a]: e.target.value })); setKirli(true) }} />
        </label>
      ))}

      {!kilitli && (
        <div className="epk-alt">
          <button type="button" className="d" onClick={() => void kaydet()} disabled={!kirli && !!veri.kayit}>
            💾 {c('Taslağı kaydet')}</button>
          <span style={{ marginLeft: 'auto' }} />
          <button type="button" className="d bir" onClick={() => void imzala()}>✍ {c('İmzala')}</button>
        </div>
      )}
    </div>
  );
}
