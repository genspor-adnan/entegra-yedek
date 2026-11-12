import { useEffect, useState } from 'react';
import { gonder, istek } from '../../api/cekirdek';
import { guvenli } from '../mesaj';
import { c } from '../../dil/ceviri';
import type { EkSekmeBaglami } from '../GenForm';

/**
 * ENTEGRASYON HESABI › TELERADYOLOJİ BAĞLANTISI (1317; mockup Ekranlar/Ayarlar/entegrasyon_teletip.html §2). Yalnız
 * kod = TELERADYOLOJI satırında. Her şube kendi satırı (şube boş = kurum geneli). Alanlar kartın kendi alanlarına yazılır:
 * firma kodu = uygulama kodu, K1 HL7 = canlı adres; K2 / K3 / karakter seti / şube no / XDS OID / Mirth hesabı `ayarlar`
 * JSON'unda. Kurum kimliği (ad, SKRS, MEDULA tesis) şubenin kurum profilinden, salt okunur. Bağlantı testi kayıtlı ayarla
 * kanal adreslerine TCP yapar (mesaj göndermez). CSS öneki `trb-`.
 */
type Baglam = { kimlik: { ad: string; skrs: string; tesis: string; kaynak: string; enabizHesapId: number | null } | null; mirthler: { id: number; ad: string }[] };
type Adim = { ad: string; tamam: boolean; ayrinti: string; ms: number };

function jsonOku(v: unknown): Record<string, unknown> {
  if (v && typeof v === 'object') return v as Record<string, unknown>;
  try { const o = JSON.parse(String(v ?? '') || '{}'); return o && typeof o === 'object' ? o : {} } catch { return {} }
}

export function TeleradyolojiBaglantiSekmesi({ e, kartId }: { e: EkSekmeBaglami; kartId: number | null }) {
  const d = e.deger;
  const subeId = Number(d.subeId ?? 0) || 0;
  const [bg, setBg] = useState<Baglam | null>(null);
  const [test, setTest] = useState<{ zaman: string; basarili: boolean; adimlar: Adim[] } | null>(null);
  const [sinaniyor, setSinaniyor] = useState(false);
  useEffect(() => {
    istek<Baglam>(`/api/entegrasyon/teleradyoloji/baglam?subeId=${subeId}`).then(setBg).catch(() => setBg(null));
  }, [subeId]);

  const ay = jsonOku(d.ayarlar);
  const salt = e.saltOkunur;
  const metin = (v: unknown) => (v === null || v === undefined ? '' : String(v));
  const ayarYaz = (anahtar: string, v: string) => {
    const yeni: Record<string, unknown> = { ...jsonOku(e.deger.ayarlar), [anahtar]: v };
    if (v === '') delete yeni[anahtar];
    e.alanYaz('ayarlar', JSON.stringify(yeni));
  };
  const sondaEgik = (s: string) => s.length > 0 && !s.endsWith('/');
  const sina = () => kartId && void guvenli(async () => {
    setSinaniyor(true);
    try {
      const y = await gonder<{ basarili: boolean; mesaj: string; adimlar?: Adim[] }>(`/api/entegrasyon/${kartId}/sina`, {});
      setTest({ zaman: new Date().toLocaleString('tr-TR'), basarili: y.basarili, adimlar: y.adimlar ?? [] });
    } finally { setSinaniyor(false) }
  });

  const kutu = (etiket: string, deger: string, yaz: (v: string) => void,
                o: { zorunlu?: boolean; ipucu?: string; hata?: string; genis?: boolean; yer?: string } = {}) => (
    <label className={`trb-alan${o.genis ? ' trb-genis' : ''}`}>
      <span className={o.zorunlu ? 'trb-zor' : ''}>{c(etiket)}</span>
      <input value={deger} disabled={salt} placeholder={o.yer ?? ''} onChange={ev => yaz(ev.target.value)} />
      {o.hata ? <small className="trb-kirmizi">{c(o.hata)}</small> : o.ipucu && <small>{c(o.ipucu)}</small>}
    </label>
  );
  const k = bg?.kimlik;
  const xds = metin(ay.xdsAdres), doz = metin(ay.dozAdres);

  return (
    <div className="trb" data-testid="teleradyoloji-baglanti">
      <style>{TRB_STIL}</style>

      <fieldset className="trb-grp trb-salt">
        <legend>{c('Kurum kimliği')} <small>{c('şubenin e-Nabız hesabından · burada değişmez')} · {k?.kaynak ?? ''}</small></legend>
        <div className="trb-izgara">
          <div className="trb-oku trb-genis"><span>{c("Bakanlık'ta görünen ad")}</span><b>{k?.ad || '—'}</b></div>
          <div className="trb-oku"><span>{c('SKRS kurum kodu')}</span>
            <b className={!k?.skrs ? 'trb-kirmizi' : k.skrs === '999999' ? 'trb-sari' : ''}>{k?.skrs || c('yok')}{k?.skrs === '999999' ? ` (${c('TEST')})` : ''}</b></div>
          <div className="trb-oku"><span>{c('MEDULA tesis kodu')}</span>
            <b className={!k?.tesis ? 'trb-kirmizi' : k.tesis === '99999999' ? 'trb-sari' : ''}>{k?.tesis || c('yok')}{k?.tesis === '99999999' ? ` (${c('TEST')})` : ''}</b></div>
        </div>
      </fieldset>

      <fieldset className="trb-grp">
        <legend>{c('Bakanlık kimliği')} <small>MSH-3 · ORC-21 · XDS</small></legend>
        <div className="trb-izgara">
          {kutu('Firma kodu', metin(d.uygulamaKodu), v => e.alanYaz('uygulamaKodu', v.trim()),
                { zorunlu: true, ipucu: "Bakanlık'ın verdiği; KOS'ta FK" })}
          <label className="trb-alan">
            <span>{c('Mesaj karakter seti')}</span>
            <select value={metin(ay.encoding) || 'UTF8'} disabled={salt} onChange={ev => ayarYaz('encoding', ev.target.value)}>
              <option value="UTF8">UTF8</option><option value="Windows1254">Windows1254</option>
            </select>
            <small>{c("Bakanlık'a önceden bildirilen ile aynı (MSH-18)")}</small>
          </label>
          {kutu('Şube no', metin(ay.subeNo), v => ayarYaz('subeNo', v.trim()), { ipucu: 'ORC-21 şube bileşeni', yer: '1' })}
          {kutu('XDS hasta OID', metin(ay.xdsHastaOid), v => ayarYaz('xdsHastaOid', v.trim()), { yer: '1.3.6.1.4.1.21367.13.20.3000' })}
        </div>
      </fieldset>

      <fieldset className="trb-grp">
        <legend>{c('Mirth kanalları')} <small>{c("Gentegre → Mirth · şubenin Mirth'i ya da aynı Mirth'te ayrı kanal portları")}</small></legend>
        <div className="trb-izgara">
          {kutu('K1 HL7 (MLLP) - istem / rapor', metin(d.url), v => e.alanYaz('url', v.trim()),
                { zorunlu: true, genis: true, yer: '10.0.0.12:6661', ipucu: 'host:port' })}
          {kutu('K2 KOS (HTTP)', xds, v => ayarYaz('xdsAdres', v.trim()),
                { genis: true, yer: 'http://10.0.0.12:8082/kos/', hata: sondaEgik(xds) ? 'sonda / olmalı (Jetty 302 verip gövdeyi düşürür)' : '' })}
          {kutu('K3 Doz (HTTP)', doz, v => ayarYaz('dozAdres', v.trim()),
                { genis: true, yer: 'http://10.0.0.12:4104/doz/', hata: sondaEgik(doz) ? 'sonda / olmalı' : '' })}
          <label className="trb-alan trb-genis">
            <span>{c('Mirth izleme hesabı')}</span>
            <select value={metin(ay.mirthHesapId)} disabled={salt} onChange={ev => ayarYaz('mirthHesapId', ev.target.value)}>
              <option value="">{c('— kurum geneli Mirth hesabı')}</option>
              {(bg?.mirthler ?? []).map(m => <option key={m.id} value={String(m.id)}>{m.ad}</option>)}
            </select>
            <small>{c('panodaki kanal durumları için (Entegrasyon › Mirth)')}</small>
          </label>
        </div>
      </fieldset>

      <div className="trb-test">
        <div className="trb-test-bas">
          <b>🔌 {c('Bağlantı testi')}</b>
          <span className="trb-soluk">{c('KAYITLI ayarla · mesaj göndermez - değişikliği önce kaydedin.')}</span>
          <button type="button" className="d" disabled={!kartId || sinaniyor} onClick={sina}>
            {sinaniyor ? c('Sınanıyor…') : c('Bağlantıyı Sına')}</button>
        </div>
        {!kartId && <div className="trb-soluk">{c('Önce kaydedin.')}</div>}
        {test && (
          <table className="trb-tablo"><tbody>
            {test.adimlar.map((a, i) => (
              <tr key={i}><td className={a.tamam ? 'trb-ok' : 'trb-hata'}>{a.tamam ? '✓' : '✖'}</td>
                <td><b>{a.ad}</b></td><td>{a.ayrinti}</td><td className="trb-soluk">{a.ms > 0 ? `${a.ms} ms` : ''}</td></tr>
            ))}
          </tbody></table>
        )}
        {test && <div className="trb-soluk">{test.zaman}</div>}
        {!test && metin(d.sonSonuc) && <div className="trb-soluk">{c('Son sonuç')}: {metin(d.sonSonuc)}</div>}
      </div>

      <div className="trb-not">
        <b>{c('Gönderim hesabı:')}</b> {c("şubenin aktif TeleRadyoloji satırı → kurum geneli aktif satır → yoksa o şubenin işleri kuyruğa girmez. Test ve canlı ayrı satır: canlıya geçerken beta pasife alınır.")}
      </div>
    </div>
  );
}

const TRB_STIL = `
.trb{padding:10px 12px;display:flex;flex-direction:column;gap:10px;font-size:12px}
.trb .trb-grp{border:1px solid #e3e9f0;border-radius:4px;background:#fbfcfd;margin:0;padding:8px 10px 10px}
.trb .trb-grp legend{font-weight:bold;color:#2c4a6b;padding:0 4px}
.trb .trb-grp legend small{font-weight:normal;color:#2f6db3;margin-left:6px}
.trb .trb-salt legend{color:#5b6b7c}
.trb .trb-izgara{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:9px 12px;align-items:start}
@media (max-width:900px){.trb .trb-izgara{grid-template-columns:repeat(2,minmax(0,1fr))}}
.trb .trb-alan{display:flex;flex-direction:column;gap:3px}
.trb .trb-alan>span{font-size:10.5px;color:#6b7a8b}
.trb .trb-zor::after{content:" *";color:#b23b3b}
.trb .trb-alan input,.trb .trb-alan select{height:26px;border:1px solid #cdd6e0;border-radius:2px;padding:0 7px;font-size:12px;background:#fff}
.trb .trb-alan small{font-size:10px;color:#6b7a8b;line-height:1.35}
.trb .trb-genis{grid-column:span 2}
.trb .trb-oku{display:flex;flex-direction:column;gap:3px}
.trb .trb-oku span{font-size:10.5px;color:#6b7a8b}
.trb .trb-oku b{font-weight:normal;height:26px;display:flex;align-items:center;padding:0 7px;border:1px solid #e3e9f0;border-radius:2px;background:#f4f6f9;color:#5b6b7c}
.trb .trb-kirmizi{color:#9d3434 !important}
.trb .trb-sari{color:#9a5b00 !important}
.trb .trb-test{border:1px solid #bfe3cb;background:#f5fbf7;border-radius:4px;padding:8px 10px;display:flex;flex-direction:column;gap:6px}
.trb .trb-test-bas{display:flex;gap:10px;align-items:center}
.trb .trb-test-bas button{margin-left:auto}
.trb .trb-tablo{border-collapse:collapse;width:100%}
.trb .trb-tablo td{padding:4px 8px;border-bottom:1px solid #e3efe6;font-size:11.5px}
.trb .trb-ok{color:#2e7d46;font-weight:bold;width:18px}
.trb .trb-hata{color:#9d3434;font-weight:bold;width:18px}
.trb .trb-soluk{color:#6b7a8b;font-size:11px}
.trb .trb-not{font-size:11px;color:#6b7a8b;background:#fff;border:1px solid #e3e9f0;border-radius:3px;padding:6px 9px;line-height:1.5}
`;
