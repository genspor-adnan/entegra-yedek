import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GozMuayeneIsleri, GozOyku } from '../../api/uclar/goz';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { MuayeneReceteSekmesi, MuayeneUcretSekmesi, useMuayeneSekmeVerisi } from '../../bilesenler/MuayeneSekmeleri';
import { c } from '../../dil/ceviri';

/**
 * GÖZ KARTINDA GENEL MUAYENE SEKMELERİ (süreç v2, mockup Ekranlar/Goz/goz_sureci_v2.html).
 *
 * Göz hekimi iki kart arasında gezinmesin: şikâyet / öykü, tanı, e-reçete ve ücret
 * genel muayenenin AYNI verisidir (muayeneId) - bileşenler genel kartınkiler, ikinci
 * giriş yolu yok. Rapor ve sevk genel kartta kalır ("Genel muayene" düğmesi).
 */

export function GozOykuSekmesi({ id, yenile }: { id: number; yenile: number }) {
  const [o, setO] = useState<GozOyku | null>(null);
  const [sikayet, setSikayet] = useState('');
  const [hikaye, setHikaye] = useState('');
  const [durum, setDurum] = useState<string | null>(null);
  useEffect(() => {
    api.gozOyku(id).then(y => { setO(y); setSikayet(y.sikayet); setHikaye(y.hikaye) }).catch(e => setDurum(hataMetni(e)));
  }, [id, yenile]);
  if (!o) return <div className="sonuk" style={{ padding: 16 }}>{durum ?? `${c('yükleniyor')}…`}</div>;
  const degisti = sikayet !== o.sikayet || hikaye !== o.hikaye;
  const kaydet = () => void guvenli(async () => {
    await api.gozOykuYaz(id, { sikayet, hikaye });
    setO({ ...o, sikayet, hikaye });
    setDurum(c('Kaydedildi.'));
  });
  return (
    <div className="rt-sekme gz-oyku">
      <div className="gz-iki">
        <div>
          <label className="gz-alan"><span>{c('Şikâyet')}</span>
            <textarea rows={4} value={sikayet} disabled={o.kapali} maxLength={4000}
                      onChange={e => { setSikayet(e.target.value); setDurum(null) }} /></label>
          <label className="gz-alan"><span>{c('Hikâye')}</span>
            <textarea rows={7} value={hikaye} disabled={o.kapali} maxLength={4000}
                      onChange={e => { setHikaye(e.target.value); setDurum(null) }} /></label>
          {!o.kapali && (
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <button type="button" className="d bir" disabled={!degisti} onClick={kaydet}>💾 {c('Öyküyü kaydet')}</button>
              {durum && <span className="sonuk rt-kucuk">{durum}</span>}
              {degisti && <span className="sonuk rt-kucuk">{c('Kaydedilmemiş değişiklik var (kartın Kaydet\'inden ayrı).')}</span>}
            </div>
          )}
        </div>
        <div className="gz-yan">
          <div className="rt-baslik">{c('Özgeçmiş')}</div>
          <div className="rt-kucuk">{o.ozgecmis || <span className="sonuk">—</span>}</div>
          <div className="rt-baslik" style={{ marginTop: 10 }}>{c('Soygeçmiş / aile')}</div>
          <div className="rt-kucuk">{o.soygecmis || <span className="sonuk">—</span>}</div>
          <div className="sonuk rt-kucuk" style={{ marginTop: 10 }}>
            {c('Şikâyet ve hikâye genel muayenenin alanlarıdır - burada yazılan genel kartta da görünür.')}
          </div>
        </div>
      </div>
    </div>
  );
}

const TARAF: Record<number, string> = { 1: 'Sağ', 2: 'Sol', 3: 'İki taraf' };
const KESIN: Record<number, string> = { 1: 'Kesin', 2: 'Ön tanı' };

export function GozTaniSekmesi({ id, muayeneId, yenile, icdAc }: {
  id: number; muayeneId: number; yenile: number; icdAc(muayeneId: number): void;
}) {
  const [v, setV] = useState<GozMuayeneIsleri | null>(null);
  const [tazele, setTazele] = useState(0);
  useEffect(() => { api.gozMuayeneIsleri(id).then(setV).catch(() => setV(null)) }, [id, yenile, tazele]);
  const sil = (taniId: number, kod: string) => void guvenli(async () => {
    if (!await onay(`${kod} tanısı kaldırılsın mı?`)) return;
    await api.muayeneTaniSil(muayeneId, taniId);
    setTazele(t => t + 1);
  });
  return (
    <div className="rt-sekme">
      <div className="gz-iki">
        <div>
          <div className="rt-baslik" style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            {c('Tanılar')} <span className="sonuk">({c('genel muayenenin tanı listesi')})</span>
            <button type="button" className="d kucuk" style={{ marginLeft: 'auto' }}
                    disabled={!(muayeneId > 0)} onClick={() => icdAc(muayeneId)}>＋ {c('Tanı (ICD ara)')}</button>
          </div>
          {!v ? <div className="sonuk">{c('yükleniyor')}…</div> : v.tanilar.length === 0
            ? <div className="sonuk rt-kucuk">{c('Tanı girilmemiş.')}</div> : (
            <table className="rt-tablo">
              <thead><tr><th>ICD</th><th>{c('Tanı')}</th><th>{c('Göz')}</th><th>{c('Tür')}</th><th>{c('Kesinlik')}</th><th /></tr></thead>
              <tbody>{v.tanilar.map(t => (
                <tr key={t.id}>
                  <td><b>{t.kod}</b></td><td>{t.ad}</td>
                  <td>{TARAF[t.taraf] ? <span className="rozet gri">{c(TARAF[t.taraf])}</span>
                       : <span className="gz-kirmizi rt-kucuk">{c('taraf yok')}</span>}</td>
                  <td>{t.tur === 1 ? c('Ana') : c('Ek')}</td>
                  <td>{c(KESIN[t.kesinlik] ?? '—')}</td>
                  <td><button type="button" className="d kucuk" onClick={() => sil(t.id, t.kod)}>🗑</button></td>
                </tr>
              ))}</tbody>
            </table>
          )}
        </div>
        <div className="gz-yan">
          <div className="tl-uyari rt-kucuk">
            {c('Göz tanısında göz tarafı (sağ / sol / iki taraf) seçilmeli: ICD H kodlarının çoğu taraf içermez; takip ve Medula bunu ister. ICD penceresindeki "Taraf" seçicisini kullanın.')}
          </div>
        </div>
      </div>
    </div>
  );
}

/** e-Reçete: genel muayene kartının sekmesi, göz kartında aynı muayene için. */
export function GozReceteSekmesi({ muayeneId, yenile, tazele }: { muayeneId: number; yenile: number; tazele(): void }) {
  const v = useMuayeneSekmeVerisi(muayeneId, yenile);
  return <MuayeneReceteSekmesi veri={v.veri} hata={v.hata} muayeneId={muayeneId} tazele={tazele}
                               ilacAra={false} onIlacAraTamam={() => {}} />;
}

export function GozUcretSekmesi({ muayeneId, yenile }: { muayeneId: number; yenile: number }) {
  const v = useMuayeneSekmeVerisi(muayeneId, yenile);
  return <MuayeneUcretSekmesi veri={v.veri} hata={v.hata} />;
}

/** Genel muayene kartında: bu muayenenin göz kartı varsa "👁 Göz kartı" düğmesi. */
export function GozKartinaGit({ muayeneId, git }: { muayeneId: number; git(yol: string): void }) {
  const [gid, setGid] = useState<number | null>(null);
  useEffect(() => { api.gozMuayeneUzantiBul(muayeneId).then(y => setGid(y.gozMuayeneId)).catch(() => setGid(null)) }, [muayeneId]);
  if (!gid) return null;
  return <button type="button" className="d" onClick={() => git(`/goz-muayene/${gid}`)}>👁 {c('Göz kartı')}</button>;
}

/**
 * TAMAMLA SONRASI (süreç v2): muayeneden doğan işleri söyler, hastayı bir sonraki
 * istasyona geçirir, kontrol günü girildiyse randevu kartını ön dolu açar.
 */
export async function gozTamamlaSonrasi(id: number, git: (yol: string) => void) {
  const [isler, oz] = await Promise.all([
    api.gozMuayeneIsleri(id).catch(() => null), api.gozMuayeneOnizleme(id).catch(() => null)]);
  const satirlar = (isler?.isler ?? []).map(s => `• ${s.ad}${s.ayrinti ? ` (${s.ayrinti})` : ''}`);
  const goruntu = (isler?.isler ?? []).some(s => s.tur === 'goruntuleme');
  const m = oz?.muayene;
  const kontrol = m?.kontrolTarihi ?? null;
  const metin = [
    c('Muayene tamamlandı.'),
    satirlar.length ? `\n${c('Bu muayeneden doğan işler')}:\n${satirlar.join('\n')}` : '',
    `\n${c('Hasta panoda')} ${goruntu ? c('Görüntüleme') : c('Karar / işlem')} ${c('istasyonuna alınsın mı?')}`,
  ].join('\n');
  if (await onay(metin)) {
    try {
      const y = await api.gozSonrakiIstasyon(id);
      if (y.istasyon) mesaj(`${c('Hasta')} → ${y.ad ?? ''}`);
    } catch (e) { mesaj(hataMetni(e)) }
  }
  if (kontrol && m && await onay(`${c('Kontrol')}: ${kontrol.slice(0, 10).split('-').reverse().join('.')} — ${c('kontrol randevusu verilsin mi?')}`)) {
    const p = new URLSearchParams({ baslangic: `${kontrol.slice(0, 10)}T09:00`, hastaId: String(m.hastaId), hastaAd: m.hasta,
                                    geri: `/goz-muayene/${id}` });
    if (m.hekimId) p.set('hekim', String(m.hekimId));
    git(`/randevu/yeni?${p.toString()}`);
  }
}
