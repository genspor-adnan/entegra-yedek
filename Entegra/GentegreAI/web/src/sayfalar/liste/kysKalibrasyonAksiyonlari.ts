import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj } from '../../bilesenler/mesaj';

/**
 * KURUMSAL KALİTE (1067) kalibrasyon liste aksiyonları - mockup
 * Ekranlar/Kalite2/kalibrasyon.html:
 *   "＋ Cihaz"              demirbaş kartı (cihaz envanteri Sabit Varlıklar'da;
 *                           kalibrasyon periyodu verilince bu listeye düşer)
 *   "🖨️ Kalibrasyon Planı"  bütün cihazlar sonraki tarih sırasıyla, A4.
 * Kodlar TAM eşleşir.
 */
export async function kysKalibrasyonAksiyonu(kod: string, _satir: ListeSatiri | null | undefined,
                                             b: { git(yol: string): void }): Promise<boolean> {
  if (kod === 'kys.kalibrasyon-cihaz') {
    b.git(`/demirbas/yeni?geri=${encodeURIComponent('/kys-kalibrasyon')}`);
    return true;
  }
  if (kod === 'kys.kalibrasyon-plan') { await planYazdir(); return true }
  return false;
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};

async function planYazdir() {
  await guvenli(async () => {
    const y = await api.liste('kys-kalibrasyon', { boyut: 2000, sirala: [{ alan: 'sonraki', yon: 'asc' }] });
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>Kalibrasyon Planı</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 2mm } .alt { color: #555; font-size: 9.5pt; margin-bottom: 5mm }
  table { width: 100%; border-collapse: collapse } th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left }
  .gecti { color: #b3261e; font-weight: bold }
  .imza { margin-top: 14mm; display: grid; grid-template-columns: 1fr 1fr; gap: 10mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1>KALİBRASYON PLANI</h1>
<div class="alt">ISO 9001 · 7.1.5 izleme ve ölçme kaynakları · ${tarih(new Date().toISOString())}</div>
<table><thead><tr><th>No</th><th>Cihaz</th><th>Birim</th><th>Periyot</th><th>Son kalibrasyon</th><th>Sonraki</th><th>Durum</th><th>Yapıldı (tarih / imza)</th></tr></thead><tbody>
${y.satirlar.map(s => `<tr><td>${kacis(s.no)}</td><td>${kacis(s.ad)}</td><td>${kacis(s.birimAdi)}</td><td>${kacis(s.periyotAdi)}</td><td>${tarih(s.sonKalibrasyon)}</td><td class="${Number(s.durum) === 3 ? 'gecti' : ''}">${tarih(s.sonraki)}</td><td>${kacis(s.durumAdi)}</td><td></td></tr>`).join('')
  || '<tr><td colspan="8">Kalibrasyona tâbi cihaz yok.</td></tr>'}
</tbody></table>
<div class="imza"><div>Hazırlayan</div><div>Onaylayan</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=900,height=1000');
    if (!w) { mesaj('Açılır pencere engellendi.'); return }
    w.document.write(html); w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
