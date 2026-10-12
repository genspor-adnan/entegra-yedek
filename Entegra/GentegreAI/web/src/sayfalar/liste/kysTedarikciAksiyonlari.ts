import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj } from '../../bilesenler/mesaj';

/** DÖF kaynak türü (1048 sözleşmesi): 8 tedarikçi. kaynakId = tedarikçinin taraf id'si. */
const KAYNAK_TEDARIKCI = 8;

/** Tedarikçi satırından DÖF açma adresi - DÖF kartı (1050) kaynağı sorgudan okur. */
export function tedarikciDofYolu(satir: ListeSatiri): string {
  const ad = String(satir.tedarikciAdi ?? '');
  const tanim = [ad, satir.sonucAdi ? `değerlendirme: ${satir.sonucAdi} (${satir.puan ?? ''})` : '']
    .filter(Boolean).join(' · ');
  const p = new URLSearchParams({
    kaynakTur: String(KAYNAK_TEDARIKCI),
    kaynakId: String(satir.tarafId ?? ''),
    kaynakNo: ad.slice(0, 40),
    tanim: tanim.slice(0, 300),
  });
  return `/kys-dof/yeni?${p}`;
}

/** Aynı tedarikçiye yeni değerlendirme kartı (tedarikçi ve "ne alıyoruz" dolu). */
export function tedarikciYenidenYolu(satir: ListeSatiri): string {
  const p = new URLSearchParams({ tarafId: String(satir.tarafId ?? '') });
  if (satir.neAliniyor) p.set('neAliniyor', String(satir.neAliniyor));
  return `/kys-tedarikci/yeni?${p}`;
}

/**
 * KURUMSAL KALİTE (1057) tedarikçi liste aksiyonları. Ekle / düzenle / sil
 * generic kartta (Crud). Kodlar TAM eşleşir.
 */
export async function kysTedarikciAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                           b: { git(yol: string): void }): Promise<boolean> {
  if (kod === 'kys.tedarikci-onayli') { await onayliListeYazdir(); return true }
  if (kod !== 'kys.tedarikci-dof' && kod !== 'kys.tedarikci-yeniden') return false;
  if (!satir?.tarafId) { mesaj('Önce bir satır seçin.'); return true }
  b.git(kod === 'kys.tedarikci-dof' ? tedarikciDofYolu(satir) : tedarikciYenidenYolu(satir));
  return true;
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};

/**
 * ONAYLI TEDARİKÇİ LİSTESİ (1066, mockup "🖨️ Onaylı Tedarikçi Listesi"): onaylı
 * ve şartlı tedarikçiler, son değerlendirme puanlarıyla A4 - ISO 9001 8.4
 * kanıtı, satınalma bu listeden alır. Red olanlar listede yok.
 */
export async function onayliListeYazdir() {
  await guvenli(async () => {
    const y = await api.liste('kys-tedarikci', {
      boyut: 1000, filtre: { alan: 'sonuc', op: 'icinde', deger: [1, 2] },
      sirala: [{ alan: 'sonuc', yon: 'asc' }, { alan: 'tedarikciAdi', yon: 'asc' }],
    });
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>Onaylı Tedarikçi Listesi</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 2mm } .alt { color: #555; font-size: 9.5pt; margin-bottom: 5mm }
  table { width: 100%; border-collapse: collapse } th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left }
  td.o { text-align: center } .imza { margin-top: 14mm; display: grid; grid-template-columns: 1fr 1fr; gap: 10mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1>ONAYLI TEDARİKÇİ LİSTESİ</h1>
<div class="alt">ISO 9001 · 8.4 · ${tarih(new Date().toISOString())} · kalite / teslim / fiyat 1–5; ortalama ≥ 3,5 onaylı, 2,5–3,5 şartlı</div>
<table><thead><tr><th>#</th><th>Tedarikçi</th><th>Ne alıyoruz</th><th>Kalite</th><th>Teslim</th><th>Fiyat</th><th>Puan</th><th>Sonuç</th><th>Son değerlendirme</th></tr></thead><tbody>
${y.satirlar.map((s, i) => `<tr><td>${i + 1}</td><td>${kacis(s.tedarikciAdi)}</td><td>${kacis(s.neAliniyor)}</td><td class="o">${kacis(s.kalite)}</td><td class="o">${kacis(s.teslim)}</td><td class="o">${kacis(s.fiyat)}</td><td class="o">${Number(s.puan ?? 0).toLocaleString('tr-TR', { minimumFractionDigits: 1, maximumFractionDigits: 1 })}</td><td>${kacis(s.sonucAdi)}</td><td>${tarih(s.tarih)}</td></tr>`).join('')
  || '<tr><td colspan="9">Onaylı tedarikçi yok.</td></tr>'}
</tbody></table>
<div class="imza"><div>Hazırlayan</div><div>Onaylayan</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=900,height=1000');
    if (!w) { mesaj('Açılır pencere engellendi.'); return }
    w.document.write(html); w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
