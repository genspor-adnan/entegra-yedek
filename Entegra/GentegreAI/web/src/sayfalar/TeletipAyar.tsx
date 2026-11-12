import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { gonder, istek } from '../api/cekirdek';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { c } from '../dil/ceviri';

/**
 * TELERADYOLOJİ AYARLARI = ŞUBE ÖZETİ (1317; mockup Ekranlar/Ayarlar/entegrasyon_teletip.html §3-§4). Eskiden tek kurum
 * ayarıydı (Teletıp Ayarları). Artık her şube Bakanlık'a kendi kimliği ve kendi hesabıyla gönderir:
 *   - kimlik (Bakanlık'ta görünen ad, SKRS, MEDULA tesis) = ANA kaynak e-Nabız hesabı (1321, şube satırı → kurum geneli;
 *     yoksa kurum profili / eski ayar) - burada yalnız görünür, düzenleme e-Nabız hesabının "Kurum Kimliği" sekmesinde;
 *   - gönderim hesabı = Ayarlar › Entegrasyon › TeleRadyoloji (şube satırı → kurum geneli), burada yalnız görünür;
 *   - kimlik çakışmaları (geçişte iki yerde farklı bulunan kodlar) seçilerek çözülür.
 * "Tümünü Sına" kanal adreslerine TCP yapar, mesaj göndermez. CSS öneki `tta-`.
 */
type Hesap = { hesapId: number; hesapAd: string; test: boolean; firmaKodu: string; hl7Adres: string; xdsAdres: string;
               dozAdres: string; encoding: string; subeNo: string; xdsHastaOid: string };
type Sube = { subeId: number; subeAdi: string; kimlik: { ad: string; skrs: string; tesis: string; kaynak: string; enabizHesapId: number | null }; hesap: Hesap | null };
type Cakisma = { id: number; subeId: number; subeAdi: string; alan: string; profilDegeri: string; eskiKaynak: string; eskiDeger: string };
type Ozet = { hesapModeli: boolean; aktif: boolean; subeler: Sube[]; cakismalar: Cakisma[];
              mirth: { url: string; kullanici: string; parolaTanimli: boolean; kaynak: string } };
type Kanal = { adres: string; acik: boolean; hata: string; sureMs: number } | null;
type Sinama = Record<number, { k1: Kanal; k2: Kanal; k3: Kanal }>;

export function TeletipAyar() {
  const git = useNavigate();
  const [v, setV] = useState<Ozet | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sinama, setSinama] = useState<Sinama | null>(null);
  const [mesgul, setMesgul] = useState(false);

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
  const cakismaCoz = (k: Cakisma, secim: 'profil' | 'eski') => void guvenli(async () => {
    const y = await gonder<{ mesaj: string }>(`/api/teletip/cakisma/${k.id}/coz`, { secim });
    mesaj(y.mesaj); await yukle();
  });
  const kanal = (k: Kanal | undefined) => !k ? <span className="tta-soluk">—</span>
    : k.acik ? <span className="tta-ok" title={`${k.adres} · ${k.sureMs} ms`}>✓</span>
    : <span className="tta-hata" title={`${k.adres}: ${k.hata}`}>✖</span>;

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
          <th>{c('Şube')}</th><th>{c("Bakanlık'ta görünen ad")}</th><th>SKRS</th><th>{c('MEDULA tesis')}</th><th>{c('Kimlik nereden')}</th>
          <th>{c('TeleRadyoloji hesabı')}</th><th className="orta">{c('Ortam')}</th><th>K1 HL7</th>
          <th className="orta">K1</th><th className="orta">K2</th><th className="orta">K3</th><th>{c('Durum')}</th>
        </tr></thead>
        <tbody>
          {v.subeler.map(s => {
            const sn = sinama?.[s.subeId];
            const kanalSorun = sn && [sn.k1, sn.k2, sn.k3].some(k => k && !k.acik);
            const test = s.kimlik.skrs === '999999' || s.kimlik.tesis === '99999999';
            const durum = !s.hesap || (!v.hesapModeli && !v.aktif) ? <span className="rz gri">{c('TeleRadyoloji kapalı')}</span>
              : !s.kimlik.skrs || !s.kimlik.tesis ? <span className="tta-kirmizi">{c('kimlik eksik')}</span>
              : kanalSorun ? <span className="tta-kirmizi">{c('kanal sorunu')}</span>
              : test ? <span className="tta-sari">{c('TEST kimliği')}</span>
              : <span className="tta-yesil">{c('gönderiyor')}</span>;
            return (
              <tr key={s.subeId}>
                <td><b>{s.subeAdi}</b></td>
                <td>{s.kimlik.ad || '—'}</td>
                <td className={!s.kimlik.skrs ? 'tta-kirmizi' : s.kimlik.skrs === '999999' ? 'tta-sari' : ''}>{s.kimlik.skrs || c('yok')}</td>
                <td className={!s.kimlik.tesis ? 'tta-kirmizi' : s.kimlik.tesis === '99999999' ? 'tta-sari' : ''}>{s.kimlik.tesis || c('yok')}</td>
                <td>{s.kimlik.enabizHesapId
                  ? <a className="tta-lnk" title={c('Kimliği düzenle: e-Nabız hesabı › Kurum Kimliği')}
                       onClick={() => git(`/entegrasyon-hesap/${s.kimlik.enabizHesapId}`)}>{s.kimlik.kaynak}</a>
                  : <span className="tta-sari" title={c("e-Nabız hesabı yok - kimlik kurum profilinden / eski ayardan. Ayarlar › Entegrasyon'da e-Nabız hesabı açın.")}>{s.kimlik.kaynak}</span>}</td>
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
                  <span className="tta-soluk"> {c('seçilen e-Nabız hesabına yazılır')}</span>
                </td>
              </tr>
            ))}</tbody>
          </table>
        </div>
      )}

      <div className="tta-not">
        <b>{c('Nasıl çalışır:')}</b> {c("istem / rapor / KOS / doz o işin şubesinin TeleRadyoloji hesabıyla gider (şube satırı → kurum geneli); ikisi de yoksa o şubenin işleri kuyruğa girmez. Kimlik (ORC-21, KOS InstitutionName, doz künyesi) şubenin e-Nabız hesabından (her HBYS e-Nabız kullanmak zorunda - ana kaynak); MEDULA da oradan okur. Bağlantı ayarları (firma kodu, Mirth K1 / K2 / K3, karakter seti) Entegrasyon Hesapları'nda. Dışa açık WADO kurulumda kalır (Ayarlar › Entegrasyon › PACS kartında durumu görünür).")}
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
