import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../../api/sozlesme';
import type { KysPolitika } from '../../../api/uclar/kysPolitika';
import { Modal } from '../../../bilesenler/Modal';
import { guvenli, mesaj } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';
import { dofAcmaYolu } from '../../liste/kysOlayRiskAksiyonlari';
import { DuzenleSilDugmeleri, silOnayi } from '../kysSecim';

/**
 * KURUMSAL KALİTE — POLİTİKA & HEDEFLER (1063, mockup Ekranlar/Kalite2/hedefler.html).
 * İki sekme: Hedefler (hedef · ölçü · hedef değer · son üç ay · durum · sorumlu;
 * hedef dışı satırdan DÖF) ve Politika & Kapsam (ISO 4.3 / 5.2). "Değer Gir"
 * geçen ayın değerlerini topluca yazar (generic kart ucu, `degerler` detayı -
 * log ve kural sunucuda). Hedef kartı generic: /kys-gosterge/:id.
 */
const AY = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const AY_UZUN = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
/** Bugünden geriye n ay: { ad, ilkGun 'YYYY-MM-01' }. */
const ayOnce = (n: number) => {
  const d = new Date(); d.setDate(1); d.setMonth(d.getMonth() - n);
  return { kisa: AY[d.getMonth()], uzun: AY_UZUN[d.getMonth()],
           ilkGun: `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-01` };
};
const sayi = (v: unknown) => v == null || v === '' ? '' : Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 2 });
const GERI = `?geri=${encodeURIComponent('/kys-hedefler')}`;
/** "6 aylık" yerine okunan cümle: 12 -> yılda 1, 6 -> yılda 2, 3 -> yılda 4. */
const periyotNotu = (ay: number) => ay >= 12 ? c('yılda 1 ölçüm') : ay > 1 && 12 % ay === 0 ? `${c('yılda')} ${12 / ay} ${c('ölçüm')}` : `${ay} ${c('ayda bir')}`;

export function KysHedefler() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<'h' | 'p'>('h');
  const [satirlar, setSatirlar] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [degerGir, setDegerGir] = useState(false);
  const [yenile, setYenile] = useState(0);
  const [secili, setSecili] = useState<ListeSatiri | null>(null);

  useEffect(() => {
    api.liste('kys-gosterge', { boyut: 500, filtre: { alan: 'aktif', op: 'esit', deger: 1 }, sirala: [{ alan: 'kod', yon: 'asc' }] })
      .then(y => setSatirlar(y.satirlar)).catch(h => setHata(hataMetni(h)));
  }, [yenile]);

  const [a1, a2, a3] = [ayOnce(3), ayOnce(2), ayOnce(1)];
  const dofAc = (s: ListeSatiri) => git(dofAcmaYolu(7, {
    id: s.id, no: String(s.kod ?? ''), departmanId: s.departmanId,
    tanim: `Hedef dışı: ${s.ad ?? ''} — son değer ${sayi(s.sonDeger) || '-'}, hedef ${s.hedefMetin || '-'}`,
  }) + `&geri=${encodeURIComponent('/kys-hedefler')}`);

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📈 {c('Kalite Politikası & Hedefler')}</h1>
        <span className="yol">Kalite › Politika & Hedefler · ISO 9001 · 4.3 kapsam · 5.2 politika · 6.2 hedefler</span>
        <div className="sag">
          {yetki('kys.gosterge', 'ekle') && <button className="d bir" onClick={() => git(`/kys-gosterge/yeni${GERI}`)}>＋ {c('Hedef')}</button>}
          <DuzenleSilDugmeleri secili={!!secili && sekme === 'h'} duzenleYetki={yetki('kys.gosterge', 'degistir')} silYetki={yetki('kys.gosterge', 'sil')}
            duzenle={() => secili && git(`/kys-gosterge/${secili.id}${GERI}`)}
            sil={() => void guvenli(async () => {
              if (!secili || !await silOnayi(String(secili.ad ?? ''))) return;
              await api.kartSil('kys-gosterge', Number(secili.id)); setSecili(null); setYenile(t => t + 1);
            })} />
          {yetki('kys.gosterge', 'degistir') && <button className="d" onClick={() => setDegerGir(true)} disabled={!satirlar?.length}>✎ {c('Değer Gir')} ({a3.uzun})</button>}
          <button className="d" onClick={() => void yazdir(satirlar ?? [], [a1, a2, a3].map(a => a.kisa))}>🖨️ {c('Politika & Hedefler')}</button>
        </div></div></div>

      <div className="katab">
        <div className={`kat${sekme === 'h' ? ' on' : ''}`} onClick={() => setSekme('h')}>{c('Hedefler')}<span className="b">{satirlar?.length ?? 0}</span></div>
        <div className={`kat${sekme === 'p' ? ' on' : ''}`} onClick={() => setSekme('p')}>{c('Politika & Kapsam')}</div>
      </div>

      {sekme === 'h' && (hata ? <div className="hata-kutusu">{hata}</div> : (
        <table className="fm-tablo kys-hedef-tablo">
          <thead><tr>
            <th>{c('Hedef')}</th><th style={{ width: 90 }}>{c('Ölçü')}</th><th style={{ width: 90 }}>{c('Hedef değer')}</th>
            <th className="sag" style={{ width: 60 }}>{a1.kisa}</th><th className="sag" style={{ width: 60 }}>{a2.kisa}</th><th className="sag" style={{ width: 60 }}>{a3.kisa}</th>
            <th style={{ width: 170 }}>{c('Durum')}</th><th style={{ width: 150 }}>{c('Sorumlu')}</th>
          </tr></thead>
          <tbody>
            {(satirlar ?? []).map(s => {
              const disi = s.durumAdi === 'Hedef dışı';
              return (
                <tr key={String(s.id)} className={secili?.id === s.id ? 'kys-secili' : undefined} style={{ cursor: 'pointer' }}
                    onClick={() => setSecili(s)} onDoubleClick={() => git(`/kys-gosterge/${s.id}${GERI}`)}>
                  <td>{String(s.ad ?? '')}</td><td>{String(s.olcu ?? '')}</td><td>{String(s.hedefMetin ?? '')}</td>
                  {Number(s.periyotAy) > 1 && s.m1 == null && s.m2 == null
                    // Her ay ölçülmeyen hedef (mockup "yılda 2 anket"): boş aylar tek hücrede.
                    ? <td colSpan={2} className="sonuk" style={{ textAlign: 'center' }}>{periyotNotu(Number(s.periyotAy))}</td>
                    : <><td className="sag">{sayi(s.m1)}</td><td className="sag">{sayi(s.m2)}</td></>}
                  <td className="sag"><b>{sayi(s.m3)}</b></td>
                  <td>
                    <span className={`rozet ${disi ? 'hata' : s.durumAdi === 'Hedefte' ? 'ok' : 'gri'}`}>{String(s.durumAdi ?? '')}</span>
                    {disi && yetki('kys.dof', 'ekle') && (
                      <button className="d mini" style={{ marginLeft: 6 }} onClick={e => { e.stopPropagation(); dofAc(s) }}>🛠️ DÖF</button>
                    )}
                  </td>
                  <td>{String(s.sorumluAdi ?? '')}</td>
                </tr>
              );
            })}
            {satirlar && !satirlar.length && <tr><td colSpan={8} className="sonuk">{c('Hedef tanımlanmamış - ＋ Hedef ile ekleyin.')}</td></tr>}
            {!satirlar && <tr><td colSpan={8} className="sonuk">{c('Yükleniyor…')}</td></tr>}
          </tbody>
        </table>
      ))}

      {sekme === 'p' && <PolitikaKapsam />}

      {degerGir && satirlar && (
        <DegerGir satirlar={satirlar} ay={a3} onKapat={kayit => { setDegerGir(false); if (kayit) setYenile(t => t + 1) }} />
      )}
    </div>
  );
}

/** Politika & Kapsam sekmesi - /api/kys-politika (kys.gosterge). */
function PolitikaKapsam() {
  const [p, setP] = useState<KysPolitika | null>(null);
  const [ilk, setIlk] = useState<KysPolitika | null>(null);
  const [duzenle, setDuzenle] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    api.kysPolitika().then(y => { const v = { ...y, yayin: y.yayin ?? '' }; setP(v); setIlk(v); setDuzenle(y.duzenle) })
      .catch(h => setHata(hataMetni(h)));
  }, []);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!p || !ilk) return <div className="sonuk">{c('Yükleniyor…')}</div>;
  const yaz = (k: keyof KysPolitika) => (e: { target: { value: string } }) => setP(x => x && ({ ...x, [k]: e.target.value }));
  const degisti = (Object.keys(p) as (keyof KysPolitika)[]).some(k => (p[k] ?? '') !== (ilk[k] ?? ''));
  const kaydet = () => void guvenli(async () => {
    const y = await api.kysPolitikaYaz(p);
    const v = { ...y, yayin: y.yayin ?? '' }; setP(v); setIlk(v);
    mesaj(c('Kaydedildi.'));
  });
  return (
    <div className="kys-politika">
      <label className="alan"><span className="etiket">{c('Kalite politikası')}</span>
        <textarea value={p.politika} disabled={!duzenle} maxLength={4000} onChange={yaz('politika')} /></label>
      <label className="alan"><span className="etiket">{c('Kapsam')}</span>
        <textarea value={p.kapsam} disabled={!duzenle} maxLength={2000} onChange={yaz('kapsam')}
                  placeholder={c('Ör. ürünlerin üretimi, satışı ve sevkiyatı. Uygulanmayan madde: 8.3 Tasarım ve geliştirme.')} /></label>
      <div className="kys-politika-iki">
        <label className="alan"><span className="etiket">{c('Onaylayan')}</span>
          <span className="kys-politika-onay">
            <input value={p.onaylayan} disabled={!duzenle} maxLength={120} onChange={yaz('onaylayan')} placeholder={c('Genel Müdür')} />
            <input value={p.tarih} disabled={!duzenle} maxLength={40} onChange={yaz('tarih')} placeholder="02.01.2026" style={{ width: 110 }} />
          </span></label>
        <label className="alan"><span className="etiket">{c('Yayın')}</span>
          <input value={p.yayin ?? ''} disabled={!duzenle} maxLength={200} onChange={yaz('yayin')} placeholder={c('Panolara asıldı, web sitesinde')} /></label>
      </div>
      {duzenle && <div><button className="d bir" disabled={!degisti} onClick={kaydet}>💾 {c('Kaydet')}</button></div>}
    </div>
  );
}

/**
 * DEĞER GİR (mockup "✎ Değer Gir (Eylül)"): aktif hedeflerin geçen ay değeri
 * tek pencerede. Her hedef kendi kartına yazılır (dönem ayın ilk günü; o ayın
 * satırı varsa düzeltilir, yoksa eklenir). Boş bırakılan satıra dokunulmaz.
 */
function DegerGir({ satirlar, ay, onKapat }: {
  satirlar: ListeSatiri[]; ay: { uzun: string; ilkGun: string }; onKapat(kayit: boolean): void;
}) {
  const [d, setD] = useState<Record<string, string>>(() =>
    Object.fromEntries(satirlar.map(s => [String(s.id), s.m3 == null ? '' : String(s.m3)])));
  const [yaziliyor, setYaziliyor] = useState(false);
  const kaydet = useCallback(async () => {
    const degisen = satirlar.filter(s => (d[String(s.id)] ?? '').trim() !== (s.m3 == null ? '' : String(s.m3)));
    if (!degisen.length) { onKapat(false); return }
    setYaziliyor(true);
    try {
      for (const s of degisen) {
        const metin = d[String(s.id)].trim().replace(',', '.');
        if (metin === '') continue;
        const deger = Number(metin);
        if (!Number.isFinite(deger)) { mesaj(`${s.ad}: ${c('sayı girin.')}`); return }
        const k = await api.kartOku('kys-gosterge', Number(s.id));
        const var_ = (k.detaylar?.degerler ?? []).find(r => String(r.donem ?? '').slice(0, 7) === ay.ilkGun.slice(0, 7));
        await api.kartGuncelle('kys-gosterge', Number(s.id), {
          surum: k.kart.surum,
          detaylar: { degerler: var_ ? { degisen: [{ ...var_, deger }] } : { eklenen: [{ donem: ay.ilkGun, deger }] } },
        });
      }
      onKapat(true);
    } catch (h) { mesaj(hataMetni(h)) } finally { setYaziliyor(false) }
  }, [satirlar, d, ay, onKapat]);

  return (
    <Modal baslik={`${c('Değer Gir')} — ${ay.uzun}`} dar onKapat={() => onKapat(false)}
      alt={<>
        <button className="d bir" disabled={yaziliyor} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
        <button className="d" onClick={() => onKapat(false)}>{c('Kapat')}</button>
      </>}>
      <table className="fm-tablo">
        <thead><tr><th>{c('Hedef')}</th><th style={{ width: 90 }}>{c('Hedef değer')}</th><th style={{ width: 110 }}>{ay.uzun}</th></tr></thead>
        <tbody>
          {satirlar.map(s => (
            <tr key={String(s.id)}>
              <td>{String(s.ad ?? '')} <span className="sonuk">{String(s.olcu ?? '')}</span></td>
              <td>{String(s.hedefMetin ?? '')}</td>
              <td><input inputMode="decimal" value={d[String(s.id)] ?? ''} style={{ width: 90, textAlign: 'right' }}
                         onChange={e => setD(x => ({ ...x, [String(s.id)]: e.target.value }))} /></td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="sonuk" style={{ marginTop: 6 }}>{c('Boş bırakılan hedefe dokunulmaz. Yılda birkaç kez ölçülen hedef (anket) yalnız ölçüldüğü ay girilir.')}</div>
    </Modal>
  );
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);

/** A4: politika + kapsam + hedef tablosu (panolara asılan / denetimde gösterilen sayfa). */
async function yazdir(satirlar: ListeSatiri[], aylar: string[]) {
  await guvenli(async () => {
    const p = await api.kysPolitika();
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>Kalite Politikası &amp; Hedefler</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 4mm } h2 { font-size: 11pt; margin: 6mm 0 2mm; border-bottom: 1px solid #999 }
  .metin { white-space: pre-wrap; line-height: 1.45 }
  table { width: 100%; border-collapse: collapse } th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left }
  td.s { text-align: right } .onay { margin-top: 4mm; font-size: 10pt; color: #444 }
</style></head><body>
<h1>KALİTE POLİTİKASI &amp; HEDEFLER</h1>
<h2>Kalite politikası</h2><div class="metin">${kacis(p.politika)}</div>
<h2>Kapsam</h2><div class="metin">${kacis(p.kapsam)}</div>
<div class="onay">Onaylayan: ${kacis(p.onaylayan)} ${kacis(p.tarih)}${p.yayin ? ` · Yayın: ${kacis(p.yayin)}` : ''}</div>
<h2>Kalite hedefleri</h2>
<table><thead><tr><th>Hedef</th><th>Ölçü</th><th>Hedef değer</th>${aylar.map(a => `<th>${a}</th>`).join('')}<th>Durum</th><th>Sorumlu</th></tr></thead><tbody>
${satirlar.map(s => `<tr><td>${kacis(s.ad)}</td><td>${kacis(s.olcu)}</td><td>${kacis(s.hedefMetin)}</td><td class="s">${sayi(s.m1)}</td><td class="s">${sayi(s.m2)}</td><td class="s">${sayi(s.m3)}</td><td>${kacis(s.durumAdi)}</td><td>${kacis(s.sorumluAdi)}</td></tr>`).join('')}
</tbody></table>
</body></html>`;
    const w = window.open('', '_blank', 'width=820,height=1000');
    if (!w) { mesaj(c('Açılır pencere engellendi.')); return }
    w.document.write(html); w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
