import { useCallback, useEffect, useState } from 'react';
import { gonder, istek } from '../../api/cekirdek';
import { guvenli } from '../mesaj';
import { c } from '../../dil/ceviri';
import type { EkSekmeBaglami } from '../GenForm';
import { ayarYazici, jsonOku, metin } from './kartAyar';

/**
 * ENTEGRASYON HESABI › WORKLIST SUNUCUSU (1329; mockup Ekranlar/Ayarlar/entegrasyon_mwl.html §2). Yalnız kod = MWL
 * satırında. ŞUBE BAŞINA satır: bu dinleyiciye bağlanan cihaz yalnız satırın şubesinin istemlerini görür. Alanlar kartın
 * KENDİ alanlarına yazılır (Kaydet ortak yoldan): AE adı = kullanıcı adı, port = uygulama kodu; karakter seti / tanımsız
 * cihaz / tarih penceresi `ayarlar` JSON'unda. Kaydedince dinleyici birkaç saniyede yeni ayarla kurulur. CSS öneki `mwl-`.
 */
type Cihaz = {
  id: number; ad: string; modalite: string; ae: string; bekleyen: number | null;
  sonSorgu: string | null; sonSayi: number | null; durum: string; uyari: boolean;
};
type Durum = {
  calisiyor: boolean; aktif: boolean; dinliyor: boolean | null; mesaj: string; zaman: string | null;
  port: number | null; ae: string; adresler: string[]; cihazlar: Cihaz[];
};
type Adim = { ad: string; tamam: boolean; ayrinti: string; ms: number };

const KARAKTER_SETLERI: [string, string][] = [
  ['ISO_IR 148', 'ISO_IR 148 (Türkçe, Latin-5)'],
  ['ISO_IR 192', 'ISO_IR 192 (UTF-8)'],
  ['ISO_IR 100', 'ISO_IR 100 (Latin-1)'],
  ['ASCII', 'ASCII (Türkçe harfler sadeleşir)'],
];

const saat = (v: string | null) => v ? new Date(v).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '';

export function MwlBaglantiSekmesi({ e, kartId }: { e: EkSekmeBaglami; kartId: number | null }) {
  const [durum, setDurum] = useState<Durum | null>(null);
  const [test, setTest] = useState<{ zaman: string; basarili: boolean; adimlar: Adim[] } | null>(null);
  const [sinaniyor, setSinaniyor] = useState(false);
  const yukle = useCallback(() => {
    if (!kartId) return;
    istek<Durum>(`/api/entegrasyon/mwl/${kartId}/durum`).then(setDurum).catch(() => setDurum(null));
  }, [kartId]);
  useEffect(() => { yukle() }, [yukle]);

  const d = e.deger;
  const ay = jsonOku(d.ayarlar);
  const salt = e.saltOkunur;
  const ayarYaz = ayarYazici(e);
  const bilinmeyen = ay.bilinmeyenAe === true || ay.bilinmeyenAe === 1 || ay.bilinmeyenAe === '1';

  const sina = () => kartId && void guvenli(async () => {
    setSinaniyor(true);
    try {
      const y = await gonder<{ basarili: boolean; mesaj: string; adimlar?: Adim[] }>(`/api/entegrasyon/${kartId}/sina`, {});
      setTest({ zaman: new Date().toLocaleString('tr-TR'), basarili: y.basarili, adimlar: y.adimlar ?? [] });
      yukle();
    } finally { setSinaniyor(false) }
  });

  const kutu = (etiket: string, deger: string, yaz: (v: string) => void, o: { zorunlu?: boolean; ipucu?: string; tip?: string; yer?: string } = {}) => (
    <label className="mwl-alan">
      <span className={o.zorunlu ? 'mwl-zor' : ''}>{c(etiket)}</span>
      <input type={o.tip ?? 'text'} value={deger} disabled={salt} placeholder={o.yer ?? ''} onChange={ev => yaz(ev.target.value)} />
      {o.ipucu && <small>{c(o.ipucu)}</small>}
    </label>
  );

  const durumSinifi = !durum ? '' : durum.dinliyor ? 'mwl-iyi' : durum.dinliyor === false ? 'mwl-kotu' : 'mwl-notr';

  return (
    <div className="mwl" data-testid="mwl-baglanti">
      <style>{MWL_STIL}</style>

      {kartId && durum && (
        <div className={`mwl-durum ${durumSinifi}`}>
          <span className="mwl-nokta" />
          <b>{durum.mesaj}</b>
          {durum.zaman && <span className="mwl-soluk">{saat(durum.zaman)}</span>}
          <button type="button" className="d" onClick={yukle}>{c('Yenile')}</button>
        </div>
      )}
      {!kartId && <div className="mwl-bilgi">{c('Kaydedince dinleyici birkaç saniye içinde bu ayarla açılır; API yeniden başlatılmaz.')}</div>}

      <fieldset className="mwl-grp">
        <legend>{c('Dinleyici')} <small>{c('cihazın "Worklist sunucusu" ayarına girilecek değerler')}</small></legend>
        <div className="mwl-izgara">
          {kutu('Port', metin(d.uygulamaKodu), v => e.alanYaz('uygulamaKodu', v.replace(/\D/g, '')),
                { zorunlu: true, yer: '11112', ipucu: "104 ClearCanvas'ın; şubeler aynı portu paylaşabilir" })}
          {kutu('AE adı', metin(d.kullaniciAdi), v => e.alanYaz('kullaniciAdi', v.toUpperCase().replace(/[^A-Z0-9_\-.]/g, '').slice(0, 16)),
                { zorunlu: true, yer: 'GENTEGRE', ipucu: 'aynı porttaki şubeler farklı AE ile ayrılır (en çok 16 karakter)' })}
          <label className="mwl-alan">
            <span>{c('Karakter seti')}</span>
            <select value={metin(ay.karakterSeti) || 'ISO_IR 148'} disabled={salt} onChange={ev => ayarYaz('karakterSeti', ev.target.value)}>
              {KARAKTER_SETLERI.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
            <small>{c('cihaz Türkçe harfleri bozuk gösteriyorsa ISO_IR 192 ya da ASCII')}</small>
          </label>
          <label className="mwl-alan">
            <span>{c('Tanımsız cihaz')}</span>
            <span className="mwl-chk">
              <input type="checkbox" checked={bilinmeyen} disabled={salt} onChange={ev => ayarYaz('bilinmeyenAe', ev.target.checked ? 1 : '')} />
              {c('Kabul et')}
            </span>
            <small>{c('kapalı önerilir; açıksa cihaz kartında olmayan AE yalnız modalite + şube süzgeciyle liste alır')}</small>
          </label>
          <label className="mwl-alan">
            <span>{c('Tarih penceresi (gün)')}</span>
            <input type="number" min={0} max={30} value={metin(ay.pencereGun)} disabled={salt} placeholder="0"
                   onChange={ev => ayarYaz('pencereGun', ev.target.value === '' ? '' : Number(ev.target.value))} />
            <small>{c('cihaz tarih sormazsa bugün ± bu kadar gün; 0 = bütün bekleyenler')}</small>
          </label>
          <div className="mwl-oku mwl-genis">
            <span>{c('Cihazın gireceği sunucu adresi')}</span>
            <b>{durum?.adresler.length ? durum.adresler.join(' · ') : '—'}</b>
            <small>{c("bu makinenin ağ adresleri; Docker kurulumda sunucunun kendi IP'si girilir. Şube cihazı sunucuya VPN / şube ağıyla ulaşmalı.")}</small>
          </div>
        </div>
      </fieldset>

      <fieldset className="mwl-grp mwl-salt">
        <legend>{c('Bu dinleyiciyi kullanan cihazlar')} <small>{c("Radyoloji › Cihaz Listesi'nden · salt okunur")}</small></legend>
        {!kartId ? <div className="mwl-soluk">{c('Kaydedince listelenir.')}</div>
          : !durum ? <div className="mwl-soluk">{c('Yükleniyor…')}</div>
          : durum.cihazlar.length === 0 ? <div className="mwl-soluk">{c('Bu şubede tanımlı radyoloji cihazı yok.')}</div>
          : (
            <table className="mwl-tablo">
              <thead><tr><th>{c('Cihaz')}</th><th>{c('Modalite')}</th><th>{c('Cihaz AE')}</th><th>{c('Son sorgu')}</th>
                         <th className="mwl-sag">{c('Bekleyen istem')}</th><th>{c('Durum')}</th></tr></thead>
              <tbody>
                {durum.cihazlar.map(x => (
                  <tr key={x.id}>
                    <td>{x.ad}</td><td>{x.modalite}</td>
                    <td className={x.ae ? '' : 'mwl-hata'}>{x.ae || c('— boş')}</td>
                    <td>{x.sonSorgu ? `${saat(x.sonSorgu)}${x.sonSayi !== null ? ` · ${x.sonSayi}` : ''}` : <span className="mwl-soluk">{c('hiç')}</span>}</td>
                    <td className="mwl-sag">{x.bekleyen ?? '—'}</td>
                    <td className={x.uyari ? 'mwl-hata' : x.sonSorgu ? 'mwl-ok' : 'mwl-bekle'}>{c(x.durum)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        <div className="mwl-not">{c('Son sorgu bellekte tutulur; API yeniden başlayınca sıfırlanır. Bekleyen = cihazın şu an listede göreceği istem sayısı.')}</div>
      </fieldset>

      <div className="mwl-test">
        <div className="mwl-test-bas">
          <b>🔌 {c('Bağlantı testi')}</b>
          <span className="mwl-soluk">{c("KAYITLI ayarla: dinleyici → C-ECHO → cihaz gibi worklist sorgusu (şubenin kayıtlı bir cihazının AE'siyle; cihazın izine yazılmaz).")}</span>
          <button type="button" className="d" disabled={!kartId || sinaniyor} onClick={sina}>
            {sinaniyor ? c('Sınanıyor…') : c('Bağlantıyı Sına')}</button>
        </div>
        {!kartId && <div className="mwl-soluk">{c('Önce kaydedin.')}</div>}
        {test && (
          <table className={`mwl-tablo${test.basarili ? '' : ' mwl-hatali'}`}>
            <tbody>
              {test.adimlar.map((a, i) => (
                <tr key={i}>
                  <td className={a.tamam ? 'mwl-ok' : 'mwl-hata'}>{a.tamam ? '✓' : '✖'}</td>
                  <td><b>{a.ad}</b></td><td>{a.ayrinti}</td><td className="mwl-soluk">{a.ms > 0 ? `${a.ms} ms` : ''}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {test && <div className="mwl-soluk">{test.zaman}</div>}
      </div>

      <div className="mwl-uyari">
        <b>{c('Ekran güvenlik duvarını açmaz.')}</b> {c("Port ekrandan değişir ve dinleyici hemen yeni portta açılır; ama sunucunun güvenlik duvarı ve Docker kurulumda dışarı açılan port kurulumda ayarlanır. Önerilen: bütün şubeler tek port (11112), şubeler AE adıyla ayrılır.")}
      </div>
    </div>
  );
}

const MWL_STIL = `
.mwl{padding:10px 12px;display:flex;flex-direction:column;gap:10px;font-size:12px}
.mwl .mwl-durum{display:flex;gap:10px;align-items:center;padding:8px 10px;border:1px solid #e3e9f0;border-radius:3px;background:#f7fafc;flex-wrap:wrap}
.mwl .mwl-durum button{margin-left:auto}
.mwl .mwl-nokta{width:10px;height:10px;border-radius:50%;background:#9aa7b5;flex:none}
.mwl .mwl-iyi{border-color:#bfe3cb;background:#f5fbf7}.mwl .mwl-iyi .mwl-nokta{background:#2e7d46;box-shadow:0 0 0 3px #d6eedd}.mwl .mwl-iyi b{color:#2e7d46}
.mwl .mwl-kotu{border-color:#efc3c3;background:#fdf5f5}.mwl .mwl-kotu .mwl-nokta{background:#9d3434;box-shadow:0 0 0 3px #f3d6d6}.mwl .mwl-kotu b{color:#9d3434}
.mwl .mwl-bilgi{border:1px solid #cfe0f5;background:#eef4fc;border-radius:3px;padding:7px 10px}
.mwl .mwl-grp{border:1px solid #e3e9f0;border-radius:4px;background:#fbfcfd;margin:0;padding:8px 10px 10px}
.mwl .mwl-grp legend{font-weight:bold;color:#2c4a6b;padding:0 4px}
.mwl .mwl-grp legend small{font-weight:normal;color:#2f6db3;margin-left:6px}
.mwl .mwl-salt legend{color:#5b6b7c}
.mwl .mwl-izgara{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:9px 12px;align-items:start}
@media (max-width:900px){.mwl .mwl-izgara{grid-template-columns:repeat(2,minmax(0,1fr))}}
.mwl .mwl-alan,.mwl .mwl-oku{display:flex;flex-direction:column;gap:3px;min-width:0}
.mwl .mwl-alan>span,.mwl .mwl-oku>span{font-size:10.5px;color:#6b7a8b}
.mwl .mwl-zor::after{content:" *";color:#b23b3b}
.mwl .mwl-alan input:not([type=checkbox]),.mwl .mwl-alan select{height:26px;border:1px solid #cdd6e0;border-radius:2px;padding:0 7px;font-size:12px;background:#fff}
.mwl .mwl-alan small,.mwl .mwl-oku small{font-size:10px;color:#6b7a8b;line-height:1.35}
.mwl .mwl-chk{display:flex;align-items:center;gap:7px;height:26px;font-size:12px;color:inherit}
.mwl .mwl-genis{grid-column:span 2}
.mwl .mwl-oku b{font-weight:normal;min-height:26px;display:flex;align-items:center;padding:0 7px;border:1px solid #e3e9f0;border-radius:2px;background:#f4f6f9;color:#5b6b7c;overflow-wrap:anywhere}
.mwl .mwl-tablo{border-collapse:collapse;width:100%}
.mwl .mwl-tablo th{text-align:left;font-size:11px;color:#3a5573;padding:5px 8px;border-bottom:1px solid #cdd6e0;background:#f3f6fa}
.mwl .mwl-tablo td{padding:4px 8px;border-bottom:1px solid #e3e9f0;font-size:11.5px}
.mwl .mwl-sag{text-align:right}
.mwl .mwl-hatali{background:#fdf5f5}
.mwl .mwl-ok{color:#2e7d46}
.mwl .mwl-hata{color:#9d3434}
.mwl .mwl-bekle{color:#a9791a}
.mwl .mwl-not{font-size:11px;color:#6b7a8b;margin-top:6px}
.mwl .mwl-test{border:1px solid #bfe3cb;background:#f5fbf7;border-radius:4px;padding:8px 10px;display:flex;flex-direction:column;gap:6px}
.mwl .mwl-test-bas{display:flex;gap:10px;align-items:center}
.mwl .mwl-test-bas button{margin-left:auto;flex:none}
.mwl .mwl-uyari{font-size:11px;color:#8a6218;background:#fdf9f1;border:1px solid #f2ddbf;border-radius:3px;padding:6px 9px;line-height:1.5}
.mwl .mwl-soluk{color:#6b7a8b;font-size:11px}
`;
