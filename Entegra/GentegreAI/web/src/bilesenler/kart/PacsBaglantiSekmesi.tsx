import { useEffect, useState } from 'react';
import { gonder, istek } from '../../api/cekirdek';
import { guvenli } from '../mesaj';
import { c } from '../../dil/ceviri';
import type { EkSekmeBaglami } from '../GenForm';
import { ayarYazici, jsonOku, metin } from './kartAyar';

/**
 * ENTEGRASYON HESABI › PACS BAĞLANTISI (1316; mockup Ekranlar/Ayarlar/entegrasyon_pacs.html §2). Yalnız kod = PACS
 * satırında görünür. Alanlar kartın KENDİ alanlarına yazılır (Kaydet ortak yoldan): bizim AE = kullanıcı adı,
 * PACS AE = uygulama kodu, WADO = canlı adres; sunucu / port / zaman aşımı / görüntüleyici / jeton süresi / ürün
 * `ayarlar` JSON'unda. Sunucunun DİNLEDİĞİ portlar (MWL, dışa açık WADO) kurulumdan gelir, salt okunur. Bağlantı testi
 * KAYITLI ayarla çalışır. CSS öneki `pcs-`.
 */
type Dinleyiciler = {
  mwlPort: number; mwlAe: string; mwlKarakterSeti: string; mwlBilinmeyenAe: boolean;
  wadoPort: number; wadoHttps: boolean; wadoYol: string; wadoIzinliIpler: string[];
  dosya: { sunucu: string; port: number; bizimAe: string; pacsAe: string; wadoUrl: string; goruntuleyiciUrl: string;
           jetonDakika: number; zamanAsimiSn: number; aktif: boolean };
  ekrandan: boolean;
};
type Adim = { ad: string; tamam: boolean; ayrinti: string; ms: number };

const URUNLER = ['ClearCanvas ImageServer', 'Orthanc', 'dcm4chee', 'Diğer'];

export function PacsBaglantiSekmesi({ e, kartId }: { e: EkSekmeBaglami; kartId: number | null }) {
  const [din, setDin] = useState<Dinleyiciler | null>(null);
  const [test, setTest] = useState<{ zaman: string; basarili: boolean; adimlar: Adim[] } | null>(null);
  const [sinaniyor, setSinaniyor] = useState(false);
  useEffect(() => { istek<Dinleyiciler>('/api/entegrasyon/pacs/dinleyiciler').then(setDin).catch(() => setDin(null)) }, []);

  const d = e.deger;
  const ay = jsonOku(d.ayarlar);
  const salt = e.saltOkunur;
  const ayarYaz = ayarYazici(e);
  const bos = !metin(ay.sunucu) && !metin(d.uygulamaKodu) && !metin(d.url);

  const dosyadanAl = () => {
    if (!din) return;
    const f = din.dosya;
    e.alanYaz('kullaniciAdi', f.bizimAe); e.alanYaz('uygulamaKodu', f.pacsAe); e.alanYaz('url', f.wadoUrl);
    e.alanYaz('ayarlar', JSON.stringify({ ...jsonOku(e.deger.ayarlar), sunucu: f.sunucu, port: f.port, zamanAsimiSn: f.zamanAsimiSn,
                                          goruntuleyiciUrl: f.goruntuleyiciUrl, jetonDakika: f.jetonDakika,
                                          urun: metin(ay.urun) || 'ClearCanvas ImageServer' }));
  };
  const clearCanvasWado = () => {
    const sunucu = metin(ay.sunucu) || '127.0.0.1';
    const ae = metin(d.uygulamaKodu) || 'SERVERAE';
    e.alanYaz('url', `http://${sunucu}:1000/WADO/${ae}`);
  };
  const sina = () => kartId && void guvenli(async () => {
    setSinaniyor(true);
    try {
      const y = await gonder<{ basarili: boolean; mesaj: string; adimlar?: Adim[] }>(`/api/entegrasyon/${kartId}/sina`, {});
      setTest({ zaman: new Date().toLocaleString('tr-TR'), basarili: y.basarili, adimlar: y.adimlar ?? [] });
    } finally { setSinaniyor(false) }
  });

  const kutu = (etiket: string, deger: string, yaz: (v: string) => void, o: { zorunlu?: boolean; ipucu?: string; tip?: string; genis?: boolean; yer?: string } = {}) => (
    <label className={`pcs-alan${o.genis ? ' pcs-genis' : ''}`}>
      <span className={o.zorunlu ? 'pcs-zor' : ''}>{c(etiket)}</span>
      <input type={o.tip ?? 'text'} value={deger} disabled={salt} placeholder={o.yer ?? ''}
             onChange={ev => yaz(ev.target.value)} />
      {o.ipucu && <small>{c(o.ipucu)}</small>}
    </label>
  );

  return (
    <div className="pcs" data-testid="pacs-baglanti">
      <style>{PCS_STIL}</style>
      {din && !din.ekrandan && (
        <div className="pcs-bilgi">
          {c('Bu kurulumda PACS ayarı henüz kurulum dosyasından (appsettings › Dicom) okunuyor. Bu satır kaydedilip aktif olunca ekrandaki değerler geçerli olur.')}
          {bos && !salt && <button type="button" className="d" onClick={dosyadanAl}>{c('↓ Dosyadaki değerleri al')}</button>}
        </div>
      )}

      <fieldset className="pcs-grp">
        <legend>{c('DICOM bağlantısı')} <small>{c('sorgu (C-FIND) · çalışma listesi, KOS, doz')}</small></legend>
        <div className="pcs-izgara">
          {kutu('Sunucu', metin(ay.sunucu), v => ayarYaz('sunucu', v.trim()), { zorunlu: true, ipucu: 'IP ya da ad', yer: '127.0.0.1' })}
          {kutu('Port', metin(ay.port), v => ayarYaz('port', v === '' ? '' : Number(v)), { zorunlu: true, tip: 'number', yer: '104' })}
          {kutu('PACS AE başlığı', metin(d.uygulamaKodu), v => e.alanYaz('uygulamaKodu', v.trim()), { zorunlu: true, ipucu: "KOS'ta Retrieve AE Title da bu", yer: 'SERVERAE' })}
          {kutu('Bizim AE başlığı', metin(d.kullaniciAdi), v => e.alanYaz('kullaniciAdi', v.trim()), { zorunlu: true, ipucu: "PACS'ta bu AE tanımlı olmalı", yer: 'GENTEGRE' })}
          {kutu('Zaman aşımı (sn)', metin(ay.zamanAsimiSn), v => ayarYaz('zamanAsimiSn', v === '' ? '' : Number(v)), { tip: 'number', yer: '20' })}
          <label className="pcs-alan">
            <span>{c('PACS ürünü')}</span>
            <select value={metin(ay.urun)} disabled={salt} onChange={ev => ayarYaz('urun', ev.target.value)}>
              <option value="">—</option>
              {URUNLER.map(u => <option key={u} value={u}>{u}</option>)}
            </select>
            <small>{c('yalnız bilgi + varsayılan adres önerisi')}</small>
          </label>
        </div>
      </fieldset>

      <fieldset className="pcs-grp">
        <legend>{c('Görüntü erişimi')} <small>{c('WADO-URI · OHIF görüntüleyici')}</small></legend>
        <div className="pcs-izgara">
          {kutu('WADO adresi', metin(d.url), v => e.alanYaz('url', v.trim()),
                { zorunlu: true, genis: true, yer: 'http://127.0.0.1:1000/WADO/SERVERAE',
                  ipucu: 'DICOM indirme - görüntüleyici, KOS ikonu, dışa açık WADO, doz' })}
          {!salt && metin(ay.urun).startsWith('ClearCanvas') && (
            <button type="button" className="d pcs-oner" onClick={clearCanvasWado}>{c('ClearCanvas varsayılanı')}</button>)}
          {kutu('Görüntüleyici (OHIF) adresi', metin(ay.goruntuleyiciUrl), v => ayarYaz('goruntuleyiciUrl', v.trim()),
                { genis: true, yer: 'http://localhost:3001', ipucu: 'boş = "Görüntüle" düğmesi çalışmaz' })}
          {kutu('Görüntüleyici erişim süresi (dk)', metin(ay.jetonDakika), v => ayarYaz('jetonDakika', v === '' ? '' : Number(v)),
                { tip: 'number', yer: '240' })}
        </div>
      </fieldset>

      <fieldset className="pcs-grp pcs-salt">
        <legend>{c('Sunucu dinleyicileri')} <small>{c('kurulumda · salt okunur')}</small></legend>
        {!din ? <div className="pcs-soluk">{c('Yükleniyor…')}</div> : (
          <div className="pcs-izgara">
            <div className="pcs-oku"><span>{c('MWL portu')}</span><b>{din.mwlPort > 0 ? din.mwlPort : c('kapalı (0)')}</b></div>
            <div className="pcs-oku"><span>{c('MWL AE')}</span><b>{din.mwlAe || '—'}</b></div>
            <div className="pcs-oku"><span>{c('MWL karakter seti')}</span><b>{din.mwlKarakterSeti}</b></div>
            <div className="pcs-oku"><span>{c('Tanımsız cihaza MWL')}</span><b>{din.mwlBilinmeyenAe ? c('evet') : c('hayır')}</b></div>
            <div className="pcs-oku"><span>{c('Dışa açık WADO (TeleRadyoloji)')}</span><b>{din.wadoPort > 0 ? `${din.wadoPort} ${din.wadoYol}` : c('kapalı')}</b></div>
            <div className="pcs-oku"><span>{c('Dışa açık WADO HTTPS')}</span><b>{din.wadoPort > 0 ? (din.wadoHttps ? c('evet') : c('hayır (sertifika yok)')) : '—'}</b></div>
            <div className="pcs-oku pcs-genis"><span>{c('IP izin listesi')}</span><b>{din.wadoIzinliIpler.length ? din.wadoIzinliIpler.join(', ') : c('— (herkes)')}</b></div>
          </div>
        )}
        <div className="pcs-not">
          {c("Bu alanlar burada değişmez: port açmak sunucu / güvenlik duvarı işi, değişince API'nin yeniden başlaması gerekir; sertifika parolası yalnız sunucu ortamında durur (appsettings › Dicom ve TeletipWado).")}
        </div>
      </fieldset>

      <div className="pcs-test">
        <div className="pcs-test-bas">
          <b>🔌 {c('Bağlantı testi')}</b>
          <span className="pcs-soluk">{c('KAYITLI ayarla çalışır - değişikliği önce kaydedin.')}</span>
          <button type="button" className="d" disabled={!kartId || sinaniyor} onClick={sina}>
            {sinaniyor ? c('Sınanıyor…') : c('Bağlantıyı Sına')}</button>
        </div>
        {!kartId && <div className="pcs-soluk">{c('Önce kaydedin.')}</div>}
        {test && (
          <table className={`pcs-tablo${test.basarili ? '' : ' pcs-hatali'}`}>
            <tbody>
              {test.adimlar.map((a, i) => (
                <tr key={i}>
                  <td className={a.tamam ? 'pcs-ok' : 'pcs-hata'}>{a.tamam ? '✓' : '✖'}</td>
                  <td><b>{a.ad}</b></td><td>{a.ayrinti}</td><td className="pcs-soluk">{a.ms > 0 ? `${a.ms} ms` : ''}</td>
                </tr>
              ))}
              {test.adimlar.length === 0 && <tr><td colSpan={4}>{c('Sonuç yok.')}</td></tr>}
            </tbody>
          </table>
        )}
        {test && <div className="pcs-soluk">{test.zaman}</div>}
        {!test && metin(d.sonSonuc) && <div className="pcs-soluk">{c('Son sonuç')}: {metin(d.sonSonuc)}</div>}
      </div>

      <div className="pcs-not">
        <b>{c('Ayar çözümü:')}</b> {c('şubenin PACS satırı → kurum geneli PACS satırı (şube boş) → kurulum dosyası (satır yoksa). Kaydedilen değişiklik birkaç saniye içinde geçerli olur; API yeniden başlatılmaz.')}
      </div>
    </div>
  );
}

const PCS_STIL = `
.pcs{padding:10px 12px;display:flex;flex-direction:column;gap:10px;font-size:12px}
.pcs .pcs-bilgi{border:1px solid #cfe0f5;background:#eef4fc;border-radius:3px;padding:7px 10px;display:flex;gap:10px;align-items:center;justify-content:space-between}
.pcs .pcs-grp{border:1px solid #e3e9f0;border-radius:4px;background:#fbfcfd;margin:0;padding:8px 10px 10px}
.pcs .pcs-grp legend{font-weight:bold;color:#2c4a6b;padding:0 4px}
.pcs .pcs-grp legend small{font-weight:normal;color:#2f6db3;margin-left:6px}
.pcs .pcs-salt legend{color:#5b6b7c}
.pcs .pcs-izgara{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:9px 12px;align-items:start}
@media (max-width:900px){.pcs .pcs-izgara{grid-template-columns:repeat(2,minmax(0,1fr))}}
.pcs .pcs-alan{display:flex;flex-direction:column;gap:3px}
.pcs .pcs-alan>span{font-size:10.5px;color:#6b7a8b}
.pcs .pcs-zor::after{content:" *";color:#b23b3b}
.pcs .pcs-alan input,.pcs .pcs-alan select{height:26px;border:1px solid #cdd6e0;border-radius:2px;padding:0 7px;font-size:12px;background:#fff}
.pcs .pcs-alan small{font-size:10px;color:#6b7a8b;line-height:1.35}
.pcs .pcs-genis{grid-column:span 2}
.pcs .pcs-oner{align-self:end;justify-self:start;margin-bottom:16px}
.pcs .pcs-oku{display:flex;flex-direction:column;gap:3px}
.pcs .pcs-oku span{font-size:10.5px;color:#6b7a8b}
.pcs .pcs-oku b{font-weight:normal;height:26px;display:flex;align-items:center;padding:0 7px;border:1px solid #e3e9f0;border-radius:2px;background:#f4f6f9;color:#5b6b7c}
.pcs .pcs-not{font-size:11px;color:#8a6218;background:#fdf9f1;border:1px solid #f2ddbf;border-radius:3px;padding:6px 9px;line-height:1.5;margin-top:8px}
.pcs > .pcs-not{color:#6b7a8b;background:#fff;border-color:#e3e9f0}
.pcs .pcs-test{border:1px solid #bfe3cb;background:#f5fbf7;border-radius:4px;padding:8px 10px;display:flex;flex-direction:column;gap:6px}
.pcs .pcs-test-bas{display:flex;gap:10px;align-items:center}
.pcs .pcs-test-bas button{margin-left:auto}
.pcs .pcs-tablo{border-collapse:collapse;width:100%}
.pcs .pcs-tablo td{padding:4px 8px;border-bottom:1px solid #e3efe6;font-size:11.5px}
.pcs .pcs-hatali{background:#fdf5f5}
.pcs .pcs-ok{color:#2e7d46;font-weight:bold;width:18px}
.pcs .pcs-hata{color:#9d3434;font-weight:bold;width:18px}
.pcs .pcs-soluk{color:#6b7a8b;font-size:11px}
`;
