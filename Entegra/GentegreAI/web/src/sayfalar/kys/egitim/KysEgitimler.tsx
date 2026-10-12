import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../../api/sozlesme';
import { guvenli, mesaj } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';

/**
 * KURUMSAL KALİTE — EĞİTİM & YETKİNLİK (1065, mockup Ekranlar/Kalite2/egitim.html).
 * İki sekme: Eğitimler (Tarih · Eğitim · Zorunlu · Eğitmen · Katılımcı · Belge)
 * ve Eksik Zorunlu Eğitim (Personel · Birim · Eksik eğitim · Son tarih). Kayıt
 * kartı özel (KysEgitimKarti, /kys-egitim/:id); zorunlu eğitim tanımları
 * generic liste (/kys-zorunlu-egitim). Yetki tek kod: kys.egitim.
 */
const GERI = `?geri=${encodeURIComponent('/kys-egitimler')}`;
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};
const bugun = new Date().toISOString().slice(0, 10);

export function KysEgitimler() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<'e' | 'k'>('e');
  const [egitimler, setEgitimler] = useState<ListeSatiri[] | null>(null);
  const [eksikler, setEksikler] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    api.liste('kys-egitim', { boyut: 500, sirala: [{ alan: 'tarih', yon: 'desc' }] })
      .then(y => setEgitimler(y.satirlar)).catch(h => setHata(hataMetni(h)));
    api.liste('kys-egitim-eksik', { boyut: 1000, sirala: [{ alan: 'sonTarih', yon: 'asc' }] })
      .then(y => setEksikler(y.satirlar)).catch(h => setHata(hataMetni(h)));
  }, []);

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🎓 {c('Eğitim & Yetkinlik Kayıtları')}</h1>
        <span className="yol">Kalite › Eğitim · ISO 9001 · 7.2 {c('yetkinlik kanıtı')}</span>
        <div className="sag">
          {yetki('kys.egitim', 'ekle') && <button className="d bir" onClick={() => git(`/kys-egitim/yeni${GERI}`)}>＋ {c('Eğitim Kaydı')}</button>}
          <button className="d" onClick={() => void yillikPlan(egitimler ?? [])}>🖨️ {c('Yıllık Eğitim Planı')}</button>
        </div></div></div>

      <div className="katab">
        <div className={`kat${sekme === 'e' ? ' on' : ''}`} onClick={() => setSekme('e')}>{c('Eğitimler')}<span className="b">{egitimler?.length ?? 0}</span></div>
        <div className={`kat${sekme === 'k' ? ' on' : ''}`} onClick={() => setSekme('k')}>{c('Eksik Zorunlu Eğitim')}<span className="b">{eksikler?.length ?? 0}</span></div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {sekme === 'e' && (
        <table className="fm-tablo">
          <thead><tr><th style={{ width: 100 }}>{c('Tarih')}</th><th>{c('Eğitim')}</th><th style={{ width: 170 }}>{c('Zorunlu')}</th>
            <th style={{ width: 170 }}>{c('Eğitmen')}</th><th style={{ width: 100 }}>{c('Katılımcı')}</th><th style={{ width: 110 }}>{c('Belge')}</th></tr></thead>
          <tbody>
            {(egitimler ?? []).map(e => (
              <tr key={String(e.id)} style={{ cursor: 'pointer' }} onClick={() => git(`/kys-egitim/${e.id}${GERI}`)}>
                <td style={{ whiteSpace: 'nowrap' }}>{tarih(e.tarih) || String(e.tarihMetin ?? '')}</td>
                <td>{String(e.ad ?? '')}</td>
                <td><span className={`rozet ${Number(e.zorunlu) === 1 ? 'mavi' : 'gri'}`}>{String(e.zorunluAdi ?? '')}</span></td>
                <td>{String(e.egitmen ?? '')}</td>
                <td title={String(e.katilimcilar ?? '')}>{String(e.katilimci ?? 0)} {c('kişi')}</td>
                <td>{Number(e.belgeSayisi) > 0 ? `📎 ${e.belgeSayisi} ${c('belge')}` : <span className="sonuk">—</span>}</td>
              </tr>
            ))}
            {egitimler && !egitimler.length && <tr><td colSpan={6} className="sonuk">{c('Eğitim kaydı yok - ＋ Eğitim Kaydı ile ekleyin.')}</td></tr>}
            {!egitimler && <tr><td colSpan={6} className="sonuk">{c('Yükleniyor…')}</td></tr>}
          </tbody>
        </table>
      )}

      {sekme === 'k' && (<>
        <table className="fm-tablo">
          <thead><tr><th>{c('Personel')}</th><th style={{ width: 200 }}>{c('Birim')}</th><th>{c('Eksik eğitim')}</th><th style={{ width: 130 }}>{c('Son tarih')}</th></tr></thead>
          <tbody>
            {(eksikler ?? []).map(k => {
              const son = String(k.sonTarih ?? '');
              const gecti = !son || son.slice(0, 10) < bugun;
              return (
                <tr key={String(k.id)}>
                  <td>{String(k.ad ?? '')}</td><td>{String(k.birim ?? '')}</td><td>{String(k.eksikEgitim ?? '')}</td>
                  <td style={{ whiteSpace: 'nowrap', color: gecti ? 'var(--hata)' : undefined }}>
                    {son ? tarih(son) : c('hiç almadı')}</td>
                </tr>
              );
            })}
            {eksikler && !eksikler.length && <tr><td colSpan={4} className="sonuk">{c('Eksik zorunlu eğitim yok.')}</td></tr>}
          </tbody>
        </table>
        <div className="sonuk" style={{ marginTop: 8 }}>
          {c('Zorunlu eğitim = birime göre tanım.')}{' '}
          <a href="#" onClick={e => { e.preventDefault(); git(`/kys-zorunlu-egitim${GERI}`) }}>⚙ {c('Zorunlu eğitim tanımları')}</a>
        </div>
      </>)}
    </div>
  );
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);

/** A4 yıllık eğitim planı: bu yılın eğitimleri + zorunlu eğitim tanımları. */
async function yillikPlan(egitimler: ListeSatiri[]) {
  await guvenli(async () => {
    const yil = new Date().getFullYear();
    const z = await api.liste('kys-zorunlu-egitim', { boyut: 500, filtre: { alan: 'aktif', op: 'esit', deger: 1 } });
    const buYil = egitimler.filter(e => String(e.tarih ?? '').startsWith(String(yil)))
      .sort((a, b) => String(a.tarih ?? '').localeCompare(String(b.tarih ?? '')));
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>Yıllık Eğitim Planı ${yil}</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 4mm } h2 { font-size: 11pt; margin: 6mm 0 2mm; border-bottom: 1px solid #999 }
  table { width: 100%; border-collapse: collapse } th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left }
  .imza { margin-top: 14mm; display: grid; grid-template-columns: 1fr 1fr; gap: 10mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1>YILLIK EĞİTİM PLANI — ${yil}</h1>
<h2>Zorunlu eğitimler</h2>
<table><thead><tr><th>Eğitim</th><th>Birim</th><th>Periyot</th><th>Eksik kişi</th></tr></thead><tbody>
${z.satirlar.map(s => `<tr><td>${kacis(s.egitimAdi)}</td><td>${kacis(s.birim)}</td><td>${kacis(s.periyotAdi)}</td><td>${kacis(s.eksik)}</td></tr>`).join('')
  || '<tr><td colspan="4">Tanım yok.</td></tr>'}
</tbody></table>
<h2>${yil} eğitimleri</h2>
<table><thead><tr><th>Tarih</th><th>Eğitim</th><th>Zorunlu</th><th>Eğitmen</th><th>Katılımcı</th></tr></thead><tbody>
${buYil.map(e => `<tr><td>${tarih(e.tarih)}</td><td>${kacis(e.ad)}</td><td>${kacis(e.zorunluAdi)}</td><td>${kacis(e.egitmen)}</td><td>${kacis(e.katilimci)}</td></tr>`).join('')
  || '<tr><td colspan="5">Kayıt yok.</td></tr>'}
</tbody></table>
<div class="imza"><div>Hazırlayan</div><div>Onaylayan</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=820,height=1000');
    if (!w) { mesaj(c('Açılır pencere engellendi.')); return }
    w.document.write(html); w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
