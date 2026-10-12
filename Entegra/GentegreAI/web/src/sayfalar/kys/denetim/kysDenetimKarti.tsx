import { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import type { ListeSatiri } from '../../../api/sozlesme';
import { guvenli, mesaj } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import type { Deger } from '../../../bilesenler/kartAlanCizim';
import { c } from '../../../dil/ceviri';
import { dofAcmaYolu } from '../../liste/kysOlayRiskAksiyonlari';

/**
 * KURUMSAL KALİTE — İÇ DENETİM KARTI ekleri (1061, mockup
 * Ekranlar/Kalite2/denetim_karti.html). Kart generic; burada mockup'ın
 * eklediği iki parça var: Bulgular tablosunda "DÖF" kolonu (açılmış DÖF no
 * ya da tek tıkla "🛠️ DÖF Aç") ve araç çubuğunda "🖨️ Denetim Raporu".
 * DÖF bağı kalite_dof.kaynak_tur = 1 / kaynak_id = bulgu id (1050);
 * numaralar Denetim Bulguları listesinden (v_kalite_denetim_bulgu) okunur.
 */
export function useBulguDoflari(denetimId: number): Map<number, ListeSatiri> {
  const [m, setM] = useState<Map<number, ListeSatiri>>(new Map());
  useEffect(() => {
    setM(new Map());
    if (!(denetimId > 0)) return;
    let iptal = false;
    api.liste('kys-denetim-bulgu', { boyut: 500, filtre: { alan: 'denetimId', op: 'esit', deger: denetimId } })
      .then(y => { if (!iptal) setM(new Map(y.satirlar.map(s => [Number(s.id), s]))) })
      .catch(() => { /* kolon boş kalır; kart yine çalışır */ });
    return () => { iptal = true };
  }, [denetimId]);
  return m;
}

/** Bulgu satırının DÖF hücresi. Gözlem (sınıf 3) DÖF gerektirmez. */
export function BulguDofHucresi({ satir, doflar }: { satir: Record<string, unknown>; doflar: Map<number, ListeSatiri> }) {
  const git = useNavigate();
  const konum = useLocation();
  const { yetki } = useOturum();
  const id = Number(satir.id);
  const b = id > 0 ? doflar.get(id) : undefined;
  if (b?.dofNo) return <code>{String(b.dofNo)}</code>;
  // Kaydedilmemiş bulgu: kimliği yok, DÖF kaynağı olamaz.
  if (!b || Number(satir.sinif) === 3 || !yetki('kys.dof', 'ekle')) return <span className="sonuk">—</span>;
  const ac = () => {
    const tanim = `${b.sinifAdi ? `${b.sinifAdi} bulgu` : 'Bulgu'}${b.madde ? ` (${b.madde})` : ''}: ${b.aciklama ?? ''}`;
    const yol = dofAcmaYolu(1, { id, no: String(b.denetimNo ?? ''), tanim, departmanId: b.departmanId });
    git(`${yol}&geri=${encodeURIComponent(konum.pathname + konum.search)}`);
  };
  return <button type="button" className="d mini" onClick={ac}>🛠️ {c('DÖF Aç')}</button>;
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};

/** Araç çubuğu: denetim raporu (A4, kayıtlı hali). */
export function DenetimAraclari({ deger }: { deger: Record<string, Deger> }) {
  return <button type="button" className="d" onClick={() => void denetimRaporuYazdir(Number(deger.id))}>
    🖨️ {c('Denetim Raporu')}
  </button>;
}

export async function denetimRaporuYazdir(id: number) {
  if (!id) return;
  await guvenli(async () => {
    const [y, b] = await Promise.all([
      api.kartOku('kys-denetim', id),
      api.liste('kys-denetim-bulgu', { boyut: 500, filtre: { alan: 'denetimId', op: 'esit', deger: id } }),
    ]);
    const k = y.kart as Record<string, unknown>;
    const ad = (alan: string, v: unknown) => y.kodAd?.[alan]?.[String(v ?? '')] ?? '';
    const satir = (e: string, d: string) => `<tr><th>${kacis(e)}</th><td>${kacis(d) || '&nbsp;'}</td></tr>`;
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>${kacis(k.no)} — İç Denetim Raporu</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 4mm; display: flex; justify-content: space-between }
  h2 { font-size: 11pt; margin: 6mm 0 2mm; border-bottom: 1px solid #999 }
  table { width: 100%; border-collapse: collapse }
  th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left; vertical-align: top }
  .kunye th { width: 22%; background: #f3f3f3; font-weight: normal }
  .metin { border: 1px solid #bbb; padding: 6px; min-height: 18mm; white-space: pre-wrap }
  .imza { display: grid; grid-template-columns: 1fr 1fr; gap: 10mm; margin-top: 14mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1><span>İÇ DENETİM RAPORU</span><span>${kacis(k.no)}</span></h1>
<table class="kunye">
${satir('Birim', ad('departmanId', k.departmanId))}${satir('Plan tarihi', tarih(k.planTarih))}
${satir('Yapıldığı tarih', tarih(k.gerceklesen))}${satir('Baş denetçi', ad('basDenetciId', k.basDenetciId))}
${satir('Ekip', String(k.ekip ?? ''))}${satir('Kapsam', String(k.kapsam ?? ''))}${satir('Durum', ad('durum', k.durum))}
</table>
<h2>Bulgular</h2>
<table><thead><tr><th style="width:6%">#</th><th style="width:12%">Sınıf</th><th>Bulgu</th><th style="width:14%">Madde</th><th style="width:16%">DÖF</th></tr></thead><tbody>
${b.satirlar.map((s, i) => `<tr><td>${i + 1}</td><td>${kacis(s.sinifAdi)}</td><td>${kacis(s.aciklama)}</td><td>${kacis(s.madde)}</td><td>${kacis(s.dofNo)}</td></tr>`).join('')
  || '<tr><td colspan="5">Bulgu yok.</td></tr>'}
</tbody></table>
<h2>Sonuç notu</h2><div class="metin">${kacis(k.sonucNotu)}</div>
<div class="imza"><div>Baş denetçi</div><div>Denetlenen birim sorumlusu</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=820,height=1000');
    if (!w) { mesaj(c('Açılır pencere engellendi.')); return }
    w.document.write(html);
    w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
