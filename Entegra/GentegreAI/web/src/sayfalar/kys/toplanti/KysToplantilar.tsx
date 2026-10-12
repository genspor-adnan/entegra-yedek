import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../../api/sozlesme';
import { guvenli, mesaj } from '../../../bilesenler/mesaj';
import type { Deger } from '../../../bilesenler/kartAlanCizim';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';
import { DuzenleSilDugmeleri, silOnayi } from '../kysSecim';

/**
 * KURUMSAL KALİTE — YGG & KARARLAR (1064, mockup Ekranlar/Kalite2/toplanti_kararlar.html).
 * Tek ekran, iki sekme: Açık Kararlar (Toplantı · Karar · Sorumlu · Termin ·
 * Durum) ve Toplantılar (Tarih · Toplantı · Katılımcılar · Karar · Açık).
 * Kartlar generic: /kys-toplanti/:id (kararlar tablosuyla), /kys-karar/:id.
 * Yetki tek kod: kys.toplanti.
 */
const GERI = `?geri=${encodeURIComponent('/kys-toplantilar')}`;
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};

export function KysToplantilar() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<'k' | 't'>('k');
  const [kararlar, setKararlar] = useState<ListeSatiri[] | null>(null);
  const [toplantilar, setToplantilar] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    api.liste('kys-karar', { boyut: 500, filtre: { alan: 'durum', op: 'esit', deger: 1 }, sirala: [{ alan: 'termin', yon: 'asc' }] })
      .then(y => setKararlar(y.satirlar)).catch(h => setHata(hataMetni(h)));
    api.liste('kys-toplanti', { boyut: 200, sirala: [{ alan: 'tarih', yon: 'desc' }] })
      .then(y => setToplantilar(y.satirlar)).catch(h => setHata(hataMetni(h)));
  }, [yenile]);
  // Seçili satır sekmeye göre karar ya da toplantı; sekme değişince seçim düşer.
  const secKaynak = sekme === 'k' ? 'kys-karar' : 'kys-toplanti';

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>👥 {c('Toplantı & Kararlar')}</h1>
        <span className="yol">Kalite › YGG & Kararlar · {c('YGG (Yönetimin Gözden Geçirmesi) + kalite toplantıları')}</span>
        <div className="sag">
          {yetki('kys.toplanti', 'ekle') && <button className="d bir" onClick={() => git(`/kys-toplanti/yeni${GERI}`)}>＋ {c('Toplantı')}</button>}
          <DuzenleSilDugmeleri secili={!!secili} duzenleYetki={yetki('kys.toplanti', 'degistir')} silYetki={yetki('kys.toplanti', 'sil')}
            duzenle={() => secili && git(`/${secKaynak}/${secili.id}${GERI}`)}
            sil={() => void guvenli(async () => {
              if (!secili || !await silOnayi(String(secili.karar ?? secili.toplantiAdi ?? ''))) return;
              await api.kartSil(secKaynak, Number(secili.id)); setSecili(null); setYenile(t => t + 1);
            })} />
        </div></div></div>

      <div className="katab">
        <div className={`kat${sekme === 'k' ? ' on' : ''}`} onClick={() => { setSekme('k'); setSecili(null) }}>{c('Açık Kararlar')}<span className="b">{kararlar?.length ?? 0}</span></div>
        <div className={`kat${sekme === 't' ? ' on' : ''}`} onClick={() => { setSekme('t'); setSecili(null) }}>{c('Toplantılar')}<span className="b">{toplantilar?.length ?? 0}</span></div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {sekme === 'k' && (
        <table className="fm-tablo">
          <thead><tr><th style={{ width: 200 }}>{c('Toplantı')}</th><th>{c('Karar')}</th><th style={{ width: 160 }}>{c('Sorumlu')}</th>
            <th style={{ width: 100 }}>{c('Termin')}</th><th style={{ width: 100 }}>{c('Durum')}</th></tr></thead>
          <tbody>
            {(kararlar ?? []).map(k => {
              const gecikti = k.durumAdi === 'Gecikti';
              return (
                <tr key={String(k.id)} className={secili?.id === k.id ? 'kys-secili' : undefined} style={{ cursor: 'pointer' }}
                    onClick={() => setSecili(k)} onDoubleClick={() => git(`/kys-karar/${k.id}${GERI}`)}>
                  <td>{String(k.toplantiAdi ?? '')}</td><td>{String(k.karar ?? '')}</td><td>{String(k.sorumluAdi ?? '')}</td>
                  <td style={{ whiteSpace: 'nowrap', color: gecikti ? 'var(--hata)' : undefined }}>{tarih(k.termin)}</td>
                  <td><span className={`rozet ${gecikti ? 'hata' : 'uyari'}`}>{String(k.durumAdi ?? '')}</span></td>
                </tr>
              );
            })}
            {kararlar && !kararlar.length && <tr><td colSpan={5} className="sonuk">{c('Açık karar yok.')}</td></tr>}
            {!kararlar && <tr><td colSpan={5} className="sonuk">{c('Yükleniyor…')}</td></tr>}
          </tbody>
        </table>
      )}

      {sekme === 't' && (
        <table className="fm-tablo">
          <thead><tr><th style={{ width: 100 }}>{c('Tarih')}</th><th style={{ width: 240 }}>{c('Toplantı')}</th><th>{c('Katılımcılar')}</th>
            <th className="orta" style={{ width: 70 }}>{c('Karar')}</th><th className="orta" style={{ width: 70 }}>{c('Açık')}</th><th style={{ width: 150 }} /></tr></thead>
          <tbody>
            {(toplantilar ?? []).map(t => (
              <tr key={String(t.id)} className={secili?.id === t.id ? 'kys-secili' : undefined} style={{ cursor: 'pointer' }}
                    onClick={() => setSecili(t)} onDoubleClick={() => git(`/kys-toplanti/${t.id}${GERI}`)}>
                <td>{tarih(t.tarih)}</td><td>{String(t.toplantiAdi ?? '')}</td><td>{String(t.katilimcilar ?? '')}</td>
                <td className="orta">{String(t.kararSayisi ?? 0)}</td><td className="orta">{String(t.acikKarar ?? 0)}</td>
                <td><button className="d mini" onClick={e => { e.stopPropagation(); void tutanakYazdir(Number(t.id)) }}>🖨️ {c('Tutanak')}</button></td>
              </tr>
            ))}
            {toplantilar && !toplantilar.length && <tr><td colSpan={6} className="sonuk">{c('Toplantı yok - ＋ Toplantı ile ekleyin.')}</td></tr>}
          </tbody>
        </table>
      )}
    </div>
  );
}

/** Toplantı kartının araç çubuğu: tutanak. */
export function ToplantiAraclari({ deger }: { deger: Record<string, Deger> }) {
  return <button type="button" className="d" onClick={() => void tutanakYazdir(Number(deger.id))}>🖨️ {c('Toplantı Tutanağı')}</button>;
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);

/** A4 toplantı tutanağı: künye, katılımcılar, gündem, kararlar, imza. */
export async function tutanakYazdir(id: number) {
  if (!id) return;
  await guvenli(async () => {
    const [y, t, meta] = await Promise.all([
      api.kartOku('kys-toplanti', id),
      api.liste('kys-toplanti', { boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } }),
      api.kartAlanlari('kys-toplanti'),
    ]);
    const k = y.kart as Record<string, unknown>;
    const ozet = t.satirlar[0] ?? {};
    const kAlan = meta.detaylar.find(d => d.ad === 'kararlar')?.alanlar ?? [];
    const kod = (alan: string, v: unknown) => kAlan.find(a => a.ad === alan)?.kodlar?.[String(v ?? '')] ?? '';
    const kararlar = y.detaylar?.kararlar ?? [];
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>Toplantı Tutanağı</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 4mm } h2 { font-size: 11pt; margin: 6mm 0 2mm; border-bottom: 1px solid #999 }
  table { width: 100%; border-collapse: collapse } th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left; vertical-align: top }
  .kunye th { width: 20%; background: #f3f3f3; font-weight: normal }
  .metin { white-space: pre-wrap; border: 1px solid #bbb; padding: 6px; min-height: 14mm }
  .imza { margin-top: 16mm; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1>TOPLANTI TUTANAĞI — ${kacis(ozet.toplantiAdi)}</h1>
<table class="kunye">
<tr><th>Tarih</th><td>${tarih(k.tarih)} ${kacis(String(k.tarih ?? '').slice(11, 16))}</td></tr>
<tr><th>Toplantı</th><td>${kacis(ozet.kurulAdi)}</td></tr>
<tr><th>Yer</th><td>${kacis(k.yer)}</td></tr>
</table>
<h2>Katılımcılar</h2><div class="metin">${kacis(k.katilimcilar)}</div>
<h2>Gündem</h2><div class="metin">${kacis(k.gundem)}</div>
<h2>Kararlar</h2>
<table><thead><tr><th style="width:6%">#</th><th>Karar</th><th style="width:22%">Sorumlu</th><th style="width:13%">Termin</th><th style="width:11%">Durum</th></tr></thead><tbody>
${kararlar.map((r, i) => `<tr><td>${i + 1}</td><td>${kacis(r.karar)}</td><td>${kacis(kod('sorumluId', r.sorumluId))}</td><td>${kacis(String(r.termin ?? '').slice(0, 10).split('-').reverse().join('.'))}</td><td>${kacis(kod('durum', r.durum))}</td></tr>`).join('')
  || '<tr><td colspan="5">Karar yok.</td></tr>'}
</tbody></table>
<div class="imza"><div>Toplantı başkanı</div><div>Raportör</div><div>Kalite sorumlusu</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=820,height=1000');
    if (!w) { mesaj(c('Açılır pencere engellendi.')); return }
    w.document.write(html); w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
