import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { gonder, istek } from '../api/cekirdek';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';

/**
 * TELERADYOLOJİ AYARLARI = ŞUBE ÖZETİ (1317; mockup Ekranlar/Ayarlar/entegrasyon_teletip.html §3-§4). Eskiden tek kurum
 * ayarıydı (Teletıp Ayarları). Artık her şube Bakanlık'a kendi kimliği ve kendi hesabıyla gönderir:
 *   - kimlik (Bakanlık'ta görünen ad, SKRS, MEDULA tesis) = kurum profili, şube bazlı TEK KAYNAK - burada düzenlenir
 *     (GenProfil'deki kurum profili ekranında da aynı alanlar);
 *   - gönderim hesabı = Ayarlar › Entegrasyon › TeleRadyoloji (şube satırı → kurum geneli), burada yalnız görünür;
 *   - kimlik çakışmaları (geçişte iki yerde farklı bulunan kodlar) seçilerek çözülür.
 * "Tümünü Sına" kanal adreslerine TCP yapar, mesaj göndermez. CSS öneki `tta-`.
 */
type Hesap = { hesapId: number; hesapAd: string; test: boolean; firmaKodu: string; hl7Adres: string; xdsAdres: string;
               dozAdres: string; encoding: string; subeNo: string; xdsHastaOid: string };
type Sube = { subeId: number; subeAdi: string; kimlik: { ad: string; skrs: string; tesis: string; kendi: boolean }; hesap: Hesap | null };
type Cakisma = { id: number; subeId: number; subeAdi: string; alan: string; profilDegeri: string; eskiKaynak: string; eskiDeger: string };
type Ozet = { hesapModeli: boolean; subeler: Sube[]; cakismalar: Cakisma[];
              mirth: { url: string; kullanici: string; parolaTanimli: boolean; kaynak: string } };
type Kanal = { adres: string; acik: boolean; hata: string; sureMs: number } | null;
type Sinama = Record<number, { k1: Kanal; k2: Kanal; k3: Kanal }>;
type Duzen = { ad: string; skrs: string; tesis: string };

export function TeletipAyar() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [v, setV] = useState<Ozet | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sinama, setSinama] = useState<Sinama | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [duzen, setDuzen] = useState<Record<number, Duzen>>({});

  const yukle = useCallback(async () => {
    try { setV(await istek<Ozet>('/api/teletip/subeler')); setHata(null) } catch (e) { setHata(hataMetni(e)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!v) return <div className="fm-sayfa"><div className="yukleniyor">{c('Yükleniyor…')}</div></div>;

  const tumunuSina = () => void guvenli(async () => {
    setMesgul(true);
    try {
      const y = await gonder<{ sonuclar: { subeId: number; k1: Kanal; k2: Kanal; k3: Kanal }[] }>('/api/teletip/subeler/sina', {});
      setSinama(Object.fromEntries(y.sonuclar.map(s => [s.subeId, { k1: s.k1, k2: s.k2, k3: s.k3 }])));
    } finally { setMesgul(false) }
  });
  const kimlikKaydet = (s: Sube) => void guvenli(async () => {
    const d = duzen[s.subeId]; if (!d) return;
    if (!s.kimlik.kendi && !await onay(c('Bu şubeye ayrı kimlik girmek şubeye ayrı kurum profili satırı açar (diğer profil ayarları kurum genelinden kopyalanır). Devam?'))) return;
    await api.kurumProfilYaz({ subeId: s.subeId, skrsKodu: d.skrs.trim(), tesisKodu: d.tesis.trim(), bakanlikAd: d.ad.trim() });
    setDuzen(x => { const y = { ...x }; delete y[s.subeId]; return y });
    mesaj(c('Kurum kimliği kaydedildi.'));
    await yukle();
  });
  const cakismaCoz = (k: Cakisma, secim: 'profil' | 'eski') => void guvenli(async () => {
    const y = await gonder<{ mesaj: string }>(`/api/teletip/cakisma/${k.id}/coz`, { secim });
    mesaj(y.mesaj); await yukle();
  });
  const kanal = (k: Kanal | undefined) => !k ? <span className="tta-soluk">—</span>
    : k.acik ? <span className="tta-ok" title={`${k.adres} · ${k.sureMs} ms`}>✓</span>
    : <span className="tta-hata" title={`${k.adres}: ${k.hata}`}>✖</span>;
  const yetkiAyar = yetki('ayar', 'degistir');   // kurum profili yazma yetkisi

  return (
    <div className="fm-sayfa tta" data-testid="teletip-ayar">
      <style>{TTA_STIL}</style>
      <div className="tta-arac">
        <b>🏛 {c('TeleRadyoloji (Bakanlık) · şube özeti')}</b>
        <button type="button" className="d" disabled={mesgul} onClick={tumunuSina}>🔌 {mesgul ? c('Sınanıyor…') : c('Tümünü Sına')}</button>
        <button type="button" className="d" onClick={() => git('/entegrasyon-hesap')}>🔗 {c('Entegrasyon Hesapları')}</button>
        <button type="button" className="d" onClick={() => void yukle()}>🔄 {c('Yenile')}</button>
        <span className="tta-sag">Mirth: {v.mirth.url ? <code>{v.mirth.url}</code> : c('tanımsız')} <span className="tta-soluk">({v.mirth.kaynak})</span></span>
      </div>
      {!v.hesapModeli && (
        <div className="tta-uyari">
          {c("Henüz TeleRadyoloji hesabı yok - gönderim eski kurum ayarlarıyla (teletip.*) çalışıyor. Şube başına gönderim için Ayarlar › Entegrasyon'da 'TeleRadyoloji (Bakanlık)' hesabı açın; ilk hesap açılınca eski ayarlar okunmaz.")}
        </div>
      )}

      <table className="tta-tablo">
        <thead><tr>
          <th>{c('Şube')}</th><th>{c("Bakanlık'ta görünen ad")}</th><th>SKRS</th><th>{c('MEDULA tesis')}</th><th></th>
          <th>{c('TeleRadyoloji hesabı')}</th><th className="orta">{c('Ortam')}</th><th>K1 HL7</th>
          <th className="orta">K1</th><th className="orta">K2</th><th className="orta">K3</th><th>{c('Durum')}</th>
        </tr></thead>
        <tbody>
          {v.subeler.map(s => {
            const d = duzen[s.subeId];
            const sn = sinama?.[s.subeId];
            const kanalSorun = sn && [sn.k1, sn.k2, sn.k3].some(k => k && !k.acik);
            const test = s.kimlik.skrs === '999999' || s.kimlik.tesis === '99999999';
            const durum = !s.hesap ? <span className="rz gri">{c('TeleRadyoloji kapalı')}</span>
              : !s.kimlik.skrs || !s.kimlik.tesis ? <span className="tta-kirmizi">{c('kimlik eksik')}</span>
              : kanalSorun ? <span className="tta-kirmizi">{c('kanal sorunu')}</span>
              : test ? <span className="tta-sari">{c('TEST kimliği')}</span>
              : <span className="tta-yesil">{c('gönderiyor')}</span>;
            return (
              <tr key={s.subeId}>
                <td><b>{s.subeAdi}</b>{!s.kimlik.kendi && <div className="tta-soluk">{c('kimlik kurum genelinden')}</div>}</td>
                {d ? <>
                  <td><input className="inp" value={d.ad} placeholder={c('boş = şube unvanı')} onChange={e => setDuzen(x => ({ ...x, [s.subeId]: { ...d, ad: e.target.value } }))} /></td>
                  <td><input className="inp tta-kisa" value={d.skrs} onChange={e => setDuzen(x => ({ ...x, [s.subeId]: { ...d, skrs: e.target.value } }))} /></td>
                  <td><input className="inp tta-kisa" value={d.tesis} onChange={e => setDuzen(x => ({ ...x, [s.subeId]: { ...d, tesis: e.target.value } }))} /></td>
                  <td className="tta-dugmeler">
                    <button type="button" className="d" onClick={() => kimlikKaydet(s)}>{c('Kaydet')}</button>
                    <button type="button" className="d" onClick={() => setDuzen(x => { const y = { ...x }; delete y[s.subeId]; return y })}>✖</button>
                  </td>
                </> : <>
                  <td>{s.kimlik.ad || '—'}</td>
                  <td className={!s.kimlik.skrs ? 'tta-kirmizi' : s.kimlik.skrs === '999999' ? 'tta-sari' : ''}>{s.kimlik.skrs || c('yok')}</td>
                  <td className={!s.kimlik.tesis ? 'tta-kirmizi' : s.kimlik.tesis === '99999999' ? 'tta-sari' : ''}>{s.kimlik.tesis || c('yok')}</td>
                  <td>{yetkiAyar && <button type="button" className="d" title={c('Kimliği düzenle (kurum profili)')}
                        onClick={() => setDuzen(x => ({ ...x, [s.subeId]: { ad: s.kimlik.kendi ? s.kimlik.ad : '', skrs: s.kimlik.kendi ? s.kimlik.skrs : '', tesis: s.kimlik.kendi ? s.kimlik.tesis : '' } }))}>✎</button>}</td>
                </>}
                <td>{s.hesap ? <a className="tta-lnk" onClick={() => s.hesap!.hesapId > 0 && git(`/entegrasyon-hesap/${s.hesap!.hesapId}`)}>{s.hesap.hesapAd}</a>
                             : <span className="tta-soluk">{c('— hesap yok')}</span>}</td>
                <td className="orta">{s.hesap ? (s.hesap.test ? <span className="rz uyari">BETA</span> : <span className="rz olumlu">{c('CANLI')}</span>) : '—'}</td>
                <td><code>{s.hesap?.hl7Adres || '—'}</code></td>
                <td className="orta">{kanal(sn?.k1)}</td><td className="orta">{kanal(sn?.k2)}</td><td className="orta">{kanal(sn?.k3)}</td>
                <td>{durum}</td>
              </tr>
            );
          })}
        </tbody>
      </table>

      {v.cakismalar.length > 0 && (
        <div className="tta-blok tta-cakisma">
          <h4>↻ {c('Kimlik çakışmaları')} <span className="tta-soluk">{c('geçişte iki yerde FARKLI bulunan kodlar - kendiliğinden ezilmez, hangisinin doğru olduğunu seçin')}</span></h4>
          <table className="tta-tablo">
            <thead><tr><th>{c('Şube')}</th><th>{c('Alan')}</th><th>{c('Kurum profili')}</th><th>{c('Eski yer')}</th><th>{c('Eski değer')}</th><th></th></tr></thead>
            <tbody>{v.cakismalar.map(k => (
              <tr key={k.id}>
                <td>{k.subeAdi}</td><td>{k.alan === 'skrs' ? 'SKRS' : c('MEDULA tesis')}</td>
                <td><b>{k.profilDegeri}</b></td><td className="tta-soluk">{k.eskiKaynak}</td><td><b>{k.eskiDeger}</b></td>
                <td className="tta-dugmeler">
                  <button type="button" className="d" onClick={() => cakismaCoz(k, 'profil')}>{c('Profildeki doğru')}</button>
                  <button type="button" className="d" onClick={() => cakismaCoz(k, 'eski')}>{c('Eski değer doğru')}</button>
                </td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      )}

      <div className="tta-not">
        <b>{c('Nasıl çalışır:')}</b> {c("istem / rapor / KOS / doz o işin şubesinin TeleRadyoloji hesabıyla gider (şube satırı → kurum geneli); ikisi de yoksa o şubenin işleri kuyruğa girmez. Kimlik (ORC-21, KOS InstitutionName, doz künyesi) şubenin kurum profilinden - e-Nabız ve MEDULA da aynı kaynaktan okur. Bağlantı ayarları (firma kodu, Mirth K1 / K2 / K3, karakter seti) Entegrasyon Hesapları'nda. Dışa açık WADO kurulumda kalır (Ayarlar › Entegrasyon › PACS kartında durumu görünür).")}
      </div>
    </div>
  );
}

const TTA_STIL = `
.tta .tta-arac{display:flex;gap:6px;align-items:center;flex-wrap:wrap;padding:8px 18px;border-bottom:1px solid #e3e9f0}
.tta .tta-arac>b{color:#14315a;margin-right:8px}
.tta .tta-sag{margin-left:auto;font-size:12px;color:#14315a}
.tta .tta-sag code{background:#eef4fc;border:1px solid #cfe0f5;border-radius:3px;padding:0 5px}
.tta .tta-uyari{margin:10px 18px 0;padding:7px 10px;border:1px solid #f2ddbf;background:#fdf9f1;color:#8a6218;border-radius:3px;font-size:12px}
.tta .tta-tablo{border-collapse:collapse;width:calc(100% - 36px);margin:10px 18px;font-size:12px}
.tta .tta-tablo th{background:linear-gradient(#f4f7fb,#e7eef6);border-bottom:1px solid #cdd6e0;text-align:left;padding:6px 8px;font-size:11px;color:#3a5573;white-space:nowrap}
.tta .tta-tablo td{border-bottom:1px solid #e3e9f0;padding:5px 8px;vertical-align:middle}
.tta .tta-tablo td.orta,.tta .tta-tablo th.orta{text-align:center}
.tta .tta-tablo input.inp{height:26px;width:100%;min-width:160px}
.tta .tta-tablo input.tta-kisa{min-width:80px;width:100px}
.tta .tta-dugmeler{white-space:nowrap}
.tta .tta-dugmeler button{margin-right:4px}
.tta .tta-ok{color:#2e7d46;font-weight:bold}
.tta .tta-hata{color:#9d3434;font-weight:bold;cursor:help}
.tta .tta-yesil{color:#2e7d46}
.tta .tta-kirmizi{color:#9d3434}
.tta .tta-sari{color:#9a5b00}
.tta .tta-soluk{color:#6b7a8b;font-size:11px}
.tta .tta-lnk{color:#2f6db3;cursor:pointer}
.tta .tta-blok{margin:0 18px 10px;border:1px solid #f0d3a0;background:#fffaf0;border-radius:4px}
.tta .tta-blok h4{margin:0;padding:7px 10px;font-size:12px;color:#9a5b00;border-bottom:1px solid #f3e2bf}
.tta .tta-blok .tta-tablo{width:calc(100% - 20px);margin:6px 10px 10px}
.tta .tta-not{margin:4px 18px 14px;font-size:11.5px;color:#6b7a8b;line-height:1.6}
`;
