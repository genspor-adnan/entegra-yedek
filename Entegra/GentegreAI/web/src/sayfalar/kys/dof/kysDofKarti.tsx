import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { guvenli, mesaj } from '../../../bilesenler/mesaj';
import type { Deger } from '../../../bilesenler/kartAlanCizim';
import { c } from '../../../dil/ceviri';

/**
 * KURUMSAL KALİTE — DÖF KARTI ekleri (1050, mockup Ekranlar/Kalite2/dof_karti.html).
 * Kart generic (GenForm); burada yalnız mockup'ın kart çerçevesine eklediği
 * parçalar var: başlıkta DÖF numarası, araç çubuğunda "🔗 Kaynak" ve
 * "🖨️ DÖF Formu", Faaliyetler başlığında "2 / 3 tamamlandı".
 */

/** Faaliyet durumu 2 = Tamamlandı (KartKatalogu.KysDof KysFaaliyetDurumlari). */
export function faaliyetSayaci(satirlar: Record<string, unknown>[]): string {
  if (satirlar.length === 0) return '';
  const tamam = satirlar.filter(s => Number(s.durum) === 2).length;
  return `${tamam} / ${satirlar.length} ${c('tamamlandı')}`;
}

/** Başlıkta "#id" yerine DÖF numarası. */
export function dofBaslikEk(deger: Record<string, Deger>) {
  return deger.no ? <span className="rozet gri">{String(deger.no)}</span> : null;
}

/** Kaynak türü -> kaynak kartı (kaynak_id'nin ne olduğu türe göre değişir). */
const DOGRUDAN: Record<number, string> = { 2: '/kys-olay', 4: '/kys-risk', 6: '/kys-karar', 7: '/kys-gosterge' };
const KAYNAK_AD: Record<number, string> = {
  1: 'Denetim', 2: 'Olay', 3: 'Şikâyet', 4: 'Risk', 5: 'Dış denetim', 6: 'Karar', 7: 'Hedef', 8: 'Tedarikçi', 9: 'Diğer',
};

async function kaynakYolu(tur: number, kaynakId: number): Promise<string | null> {
  if (DOGRUDAN[tur]) return `${DOGRUDAN[tur]}/${kaynakId}`;
  // İç denetim: kaynak_id BULGU kimliği - kart denetimin kartıdır.
  if (tur === 1) {
    const y = await api.liste('kys-denetim-bulgu', { boyut: 1, filtre: { alan: 'id', op: 'esit', deger: kaynakId } });
    const d = Number(y.satirlar[0]?.denetimId);
    return d ? `/kys-denetim/${d}` : null;
  }
  // Tedarikçi: kaynak_id TARAF kimliği - kart son değerlendirmedir.
  if (tur === 8) {
    const y = await api.liste('kys-tedarikci', { boyut: 1, filtre: { alan: 'tarafId', op: 'esit', deger: kaynakId } });
    const d = Number(y.satirlar[0]?.id);
    return d ? `/kys-tedarikci/${d}` : null;
  }
  return null;
}

/** Araç çubuğu: kaynağa git + DÖF formu yazdır. */
export function DofAraclari({ deger }: { deger: Record<string, Deger> }) {
  const git = useNavigate();
  const konum = useLocation();
  const tur = Number(deger.kaynakTur);
  const kaynakId = Number(deger.kaynakId);
  const no = String(deger.kaynakNo ?? '');
  const baglanir = !!kaynakId && (!!DOGRUDAN[tur] || tur === 1 || tur === 8);

  const kaynagaGit = () => void guvenli(async () => {
    const yol = await kaynakYolu(tur, kaynakId);
    if (!yol) { mesaj(c('Kaynak kayıt bulunamadı (silinmiş ya da yetkiniz yok).')); return }
    git(`${yol}?geri=${encodeURIComponent(konum.pathname + konum.search)}`);
  });

  return <>
    {(baglanir || no) && (
      <button type="button" className="d" disabled={!baglanir} onClick={kaynagaGit}
              title={baglanir ? c('Kaynak kaydı aç') : c('Kaynak kaydı bağlı değil')}>
        🔗 {c('Kaynak')}: {no || KAYNAK_AD[tur] || '—'}
      </button>
    )}
    <button type="button" className="d" onClick={() => void dofFormuYazdir(Number(deger.id))}>
      🖨️ {c('DÖF Formu')}
    </button>
  </>;
}

const kacis = (s: unknown) => String(s ?? '').replace(/[&<>"]/g, ch =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[ch]!);
const tarih = (s: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(s ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : '';
};

/** A4 DÖF formu: kayıtlı hali (sunucudan okunur), yeni pencerede yazdırılır. */
export async function dofFormuYazdir(id: number) {
  if (!id) return;
  await guvenli(async () => {
    const [y, meta] = await Promise.all([api.kartOku('kys-dof', id), api.kartAlanlari('kys-dof')]);
    const k = y.kart as Record<string, unknown>;
    const ad = (alan: string, deger: unknown) => y.kodAd?.[alan]?.[String(deger ?? '')] ?? '';
    const faaliyetler = y.detaylar?.faaliyetler ?? [];
    const satir = (etiket: string, deger: string) =>
      `<tr><th>${kacis(etiket)}</th><td>${kacis(deger) || '&nbsp;'}</td></tr>`;
    // Detay satırlarının kod adları kodAd'da yok - seçenekler alan metasından.
    const fAlanlari = meta.detaylar.find(d => d.ad === 'faaliyetler')?.alanlar ?? [];
    const fadAd = (f: Record<string, unknown>, alan: string) =>
      fAlanlari.find(a => a.ad === alan)?.kodlar?.[String(f[alan] ?? '')] ?? '';
    const html = `<!doctype html><html><head><meta charset="utf-8"><title>${kacis(k.no)} — DÖF Formu</title>
<style>
  @page { size: A4; margin: 14mm }
  body { font: 11pt "Trebuchet MS", Arial, sans-serif; color: #222 }
  h1 { font-size: 15pt; margin: 0 0 4mm; display: flex; justify-content: space-between }
  h2 { font-size: 11pt; margin: 6mm 0 2mm; border-bottom: 1px solid #999 }
  table { width: 100%; border-collapse: collapse }
  th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left; vertical-align: top }
  .kunye th { width: 22%; background: #f3f3f3; font-weight: normal }
  .metin { border: 1px solid #bbb; padding: 6px; min-height: 18mm; white-space: pre-wrap }
  .imza { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8mm; margin-top: 14mm }
  .imza div { border-top: 1px solid #555; padding-top: 2mm; text-align: center; font-size: 9pt }
</style></head><body>
<h1><span>DÜZELTİCİ / ÖNLEYİCİ FAALİYET FORMU</span><span>${kacis(k.no)}</span></h1>
<table class="kunye">
${satir('Tür', ad('tur', k.tur))}${satir('Birim', ad('departmanId', k.departmanId))}
${satir('Sorumlu', ad('sorumluId', k.sorumluId))}${satir('Kaynak', [ad('kaynakTur', k.kaynakTur), String(k.kaynakNo ?? '')].filter(Boolean).join(' · '))}
${satir('Açılış', [tarih(k.eklemeTarihi), ad('ekleyen', k.ekleyen)].filter(Boolean).join(' · '))}${satir('Termin', tarih(k.termin))}
${satir('Durum', ad('durum', k.durum))}
</table>
<h2>Sorun nedir?</h2><div class="metin">${kacis(k.tanim)}</div>
<h2>Kök neden</h2><div class="metin">${kacis(k.kokNeden)}</div>
<h2>Faaliyetler</h2>
<table><thead><tr><th style="width:6%">#</th><th>Faaliyet</th><th style="width:22%">Sorumlu</th><th style="width:14%">Termin</th><th style="width:14%">Durum</th></tr></thead><tbody>
${faaliyetler.map((f, i) => `<tr><td>${i + 1}</td><td>${kacis(f.faaliyet)}</td><td>${kacis(fadAd(f, 'sorumluId'))}</td><td>${tarih(f.termin)}</td><td>${kacis(fadAd(f, 'durum'))}</td></tr>`).join('')
  || '<tr><td colspan="5">&nbsp;</td></tr>'}
</tbody></table>
<h2>Doğrulama</h2>
<table class="kunye">${satir('Etkili oldu mu?', ad('dogrulamaSonuc', k.dogrulamaSonuc))}${satir('Doğrulama tarihi', tarih(k.dogrulamaTarihi))}</table>
<div class="imza"><div>Hazırlayan</div><div>DÖF sorumlusu</div><div>Kalite sorumlusu / onay</div></div>
</body></html>`;
    const w = window.open('', '_blank', 'width=820,height=1000');
    if (!w) { mesaj(c('Açılır pencere engellendi.')); return }
    w.document.write(html);
    w.document.close();
    w.onload = () => { w.focus(); w.print() };
  });
}
