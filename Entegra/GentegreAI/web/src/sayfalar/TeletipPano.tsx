import { useCallback, useContext, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { TELETIP_DURUM, mesajKisaAdi, type TeletipPano as Pano } from '../api/uclar/teletip';
import { EkranSekmesiBaglami } from '../bilesenler/sekmeBaglami';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { bugunIso, tarihSaat } from '../bilesenler/bicim';
import { c } from '../dil/ceviri';

/**
 * TELETIP PANOSU (kullanıcı 11.11.2026: "Mirth panosunu yap"; mockup Ekranlar/Radyoloji/teletip_mirth.html §2).
 * Üst: Mirth / Teletıp HL7 bağlantı durumu. Özet: günün istem (NW) ve güncelleme / iptal mesajları, kuyrukta bekleyen
 * (en eski kaç dk), reddedilen, gidemez. Kanal tablosu: Mirth REST'ten (gentegre_izleme kullanıcısı) durum + sayaçlar -
 * yalnız okunur; kanal durdur / başlat Mirth Administrator'da. Son olaylar: son 10 gönderim, çift tık istemin Teletıp
 * kartı. Mirth erişilemezse DB bölümü yine çizilir. CSS öneki `ttp-`.
 */
export function TeletipPano() {
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const [gun, setGun] = useState(bugunIso());
  const [v, setV] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [test, setTest] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const yukle = useCallback(async () => {
    try { setV(await api.teletipPano(gun)); setHata(null) } catch (e) { setHata(hataMetni(e)) }
  }, [gun]);
  useEffect(() => { void yukle() }, [yukle]);
  // Pano açıkken 60 sn'de bir tazelenir (kuyruk işçisi 30 sn'de bir çalışır).
  useEffect(() => { const t = window.setInterval(() => void yukle(), 60_000); return () => window.clearInterval(t) }, [yukle]);

  const gunKaydir = (n: number) => {
    const d = new Date(`${gun}T12:00:00`); d.setDate(d.getDate() + n); setGun(bugunIso(d));
  };
  const baglantiTesti = () => guvenli(async () => {
    const y = await api.teletipBaglantiTesti();
    setTest([
      y.hl7.acik ? `✓ ${c('Teletıp HL7')} ${y.hl7.adres} (${y.hl7.sureMs} ms)` : `✖ ${c('Teletıp HL7')} ${y.hl7.adres || '—'}: ${y.hl7.hata}`,
      !y.mirth.tanimli ? `– ${c('Mirth tanımlı değil')}` : y.mirth.erisilebilir
        ? `✓ Mirth ${y.mirth.surum} · ${y.mirth.kanalSayisi} ${c('kanal')}` : `✖ Mirth: ${y.mirth.hata}`,
    ].join('   '));
  });
  const topluGonder = () => guvenli(async () => {
    setMesgul(true);
    try {
      const y = await api.teletipTopluGonder();
      mesaj(`${c('Denenen')}: ${y.denenen} · ${c('gönderilen')}: ${y.gonderilen} · ${c('sorunlu kalan')}: ${y.sorunluKalan}`);
      await yukle();
    } finally { setMesgul(false) }
  });
  const karta = (istemId: number | null) => {
    if (!istemId) return;
    const yol = `/teletip/${istemId}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!v) return <div className="fm-sayfa"><div className="yukleniyor">{c('Yükleniyor…')}</div></div>;
  const o = v.ozet;
  const m = v.mirth;
  const mirthRozet = !m.tanimli ? <span className="rozet gri">{c('tanımsız')}</span>
    : m.erisilebilir ? <span className="rozet olumlu">{c('çalışıyor')}</span> : <span className="rozet hata">{c('ulaşılamıyor')}</span>;

  return (
    <div className="fm-sayfa ttp" data-testid="teletip-pano">
      <style>{TTP_STIL}</style>
      <div className="ttp-arac">
        <button type="button" className="d" onClick={() => gunKaydir(-1)}>◀</button>
        <input type="date" value={gun} onChange={e => setGun(e.target.value || bugunIso())} />
        <button type="button" className="d" onClick={() => gunKaydir(1)}>▶</button>
        <button type="button" className="d" onClick={() => setGun(bugunIso())}>{c('Bugün')}</button>
        <button type="button" className="d" onClick={() => void yukle()}>🔄 {c('Yenile')}</button>
        <button type="button" className="d" onClick={() => void baglantiTesti()}>🧪 {c('Bağlantı Testi')}</button>
        <button type="button" className="d" disabled={mesgul || o.sorunluToplam === 0} onClick={() => void topluGonder()}
          title={c('Reddedilen, gidemez ve ulaşmadı satırlarını şimdi yeniden dener')}>🔁 {c('Sorunluları Yeniden Gönder')}</button>
        <div className="ttp-sag">
          <span>Mirth {m.surum} {mirthRozet}</span>
          <span>· {c('Teletıp HL7')} <code>{v.hl7Adres || '—'}</code></span>
          {!v.aktif && <span className="rozet uyari">{c('Kurumda Teletıp kapalı')}</span>}
        </div>
      </div>
      {test && <div className="ttp-test">{test}</div>}
      {m.tanimli && !m.erisilebilir && <div className="ttp-test ttp-hata">Mirth: {m.hata}</div>}

      <div className="ttp-ozet">
        <div className="ttp-kutu"><small>{c('İstem (NW)')}</small><b>{o.nwToplam}</b> <span>· {o.nwGonderildi} {c('kabul')}</span></div>
        <div className="ttp-kutu"><small>{c('Güncelleme / iptal')}</small><b>{o.xoCaToplam}</b> <span>· {o.xoCaGonderildi} {c('kabul')}</span></div>
        <div className="ttp-kutu"><small>{c('Rapor (ORU)')}</small><b>{o.oruToplam}</b> <span>· {o.oruGonderildi} {c('kabul')}</span></div>
        <div className="ttp-kutu"><small>{c('Görüntü (KOS)')}</small><b>{o.kosToplam}</b> <span>· {o.kosGonderildi} {c('eşleşti')}</span></div>
        <div className={`ttp-kutu${o.kuyrukta > 0 ? ' sari' : ''}`}><small>{c('Kuyrukta bekleyen')}</small><b>{o.kuyrukta}</b>
          {o.kuyrukta > 0 && <span>· {c('en eski')} {o.enEskiDk} {c('dk')}</span>}</div>
        <div className={`ttp-kutu${o.reddedildi > 0 ? ' kir' : ''}`}><small>{c('Reddedildi (AE)')}</small><b>{o.reddedildi}</b></div>
        <div className={`ttp-kutu${o.gidemez > 0 ? ' kir' : ''}`}><small>{c('Gidemez (eksik)')}</small><b>{o.gidemez}</b></div>
        <div className={`ttp-kutu${o.sorunluToplam > 0 ? ' kir' : ''}`}><small>{c('Sorunlu (tüm günler)')}</small><b>{o.sorunluToplam}</b></div>
      </div>

      <div className="ttp-blok">
        <h4>{c('Mirth kanalları')} <span className="ttp-ip">· {c('Mirth REST, yalnız okunur · sayaçlar güne göre değil, Mirth’te son sıfırlamadan beri')}</span></h4>
        {m.kanallar.length === 0
          ? <div className="ttp-ic ttp-soluk">{m.tanimli ? (m.erisilebilir ? c('Kanal yok.') : c('Mirth\'e ulaşılamadı.')) : c('Mirth bağlantısı tanımlı değil (API ayarı Mirth:Url / Mirth__Parola).')}</div>
          : <table className="ttp-tablo">
            <thead><tr><th>{c('Kanal')}</th><th>{c('Durum')}</th><th className="sag">{c('Alınan')}</th><th className="sag">{c('Süzülen')}</th>
              <th className="sag">{c('Kuyruk')}</th><th className="sag">{c('Gönderilen')}</th><th className="sag">{c('Hatalı')}</th><th>{c('Görev')}</th></tr></thead>
            <tbody>
              {m.kanallar.map(k => (
                <tr key={k.id}>
                  <td><b>{k.ad}</b></td>
                  <td><span className={`rozet ${k.durum === 'STARTED' ? 'olumlu' : k.durum === 'STOPPED' || k.durum === 'UNDEPLOYED' ? 'hata' : 'uyari'}`}>{k.durum}</span></td>
                  <td className="sag">{k.alinan}</td><td className="sag">{k.suzulen}</td><td className="sag">{k.kuyruk}</td>
                  <td className="sag">{k.gonderilen}</td><td className={`sag${k.hatali > 0 ? ' ttp-kirmizi' : ''}`}>{k.hatali}</td>
                  <td className="ttp-soluk">{KANAL_GOREV[k.ad] ?? ''}</td>
                </tr>
              ))}
            </tbody>
          </table>}
        <div className="ttp-not">{c('Hatalı = Teletıp\'ın AE / AR yanıtı ya da ulaşılamayan hedef. Mirth otomatik tekrar etmez; tekrar Gentegre kuyruğundadır.')}</div>
      </div>

      <div className="ttp-blok">
        <h4>{c('Son olaylar')} <span className="ttp-ip">· {c('çift tık: Teletıp kartı')}</span></h4>
        {v.sonOlaylar.length === 0 ? <div className="ttp-ic ttp-soluk">{c('Henüz gönderim yok.')}</div>
          : <table className="ttp-tablo">
            <thead><tr><th>{c('Zaman')}</th><th>{c('Emir')}</th><th>{c('Durum')}</th><th>{c('Accession')}</th><th>{c('Hasta')}</th><th>ACK</th><th>{c('Sorun')}</th></tr></thead>
            <tbody>
              {v.sonOlaylar.map(s => {
                const d = TELETIP_DURUM[s.durum] ?? { ad: String(s.durum), sinif: 'gri' };
                return (
                  <tr key={s.id} className="ac" onDoubleClick={() => karta(s.istemId)}>
                    <td>{tarihSaat(s.zaman)}</td><td><b>{mesajKisaAdi(s.kanal, s.emir)}</b></td>
                    <td><span className={`rozet ${d.sinif}`}>{c(d.ad)}</span></td><td>{s.accessionNo}</td><td>{s.hastaAdi}</td>
                    <td>{s.ackKodu}</td><td className="ttp-kirmizi">{s.hata}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>}
      </div>
    </div>
  );
}

/** Kanal adı -> görevi (yayin/mirth/kanal-uret.js). */
const KANAL_GOREV: Record<string, string> = {
  TELETIP_HL7: 'K1 · HL7 ORM / ORU → Teletıp',
  TELETIP_KOS: 'K2 · KOS / XDS → Teletıp',
  TELETIP_DOZ: 'K3 · RDSR → TELETIP_MGA',
  TELETIP_DURUM: 'K4 · durum → Gentegre',
  TELETIP_SIMULATOR: 'yalnız dev · Teletıp benzetimi',
};

const TTP_STIL = `
.ttp .ttp-arac{display:flex;gap:6px;align-items:center;flex-wrap:wrap;padding:8px 18px;border-bottom:1px solid #e3e9f0}
.ttp .ttp-arac input[type=date]{height:28px}
.ttp .ttp-sag{margin-left:auto;display:flex;gap:8px;align-items:center;font-size:12px;color:#14315a;font-weight:bold}
.ttp .ttp-sag code{font-weight:normal;background:#eef4fc;border:1px solid #cfe0f5;border-radius:3px;padding:0 5px}
.ttp .ttp-test{margin:8px 18px 0;padding:6px 10px;border:1px solid #cfe0f5;background:#eef4fc;border-radius:3px;font-size:12px}
.ttp .ttp-test.ttp-hata{border-color:#efc3c3;background:#fbf0f0;color:#9d3434}
.ttp .ttp-ozet{display:grid;grid-template-columns:repeat(8,minmax(0,1fr));gap:8px;padding:10px 18px}
@media (max-width:1000px){.ttp .ttp-ozet{grid-template-columns:repeat(2,minmax(0,1fr))}}
.ttp .ttp-kutu{border:1px solid #e3e9f0;border-radius:4px;background:#fbfcfd;padding:8px 10px}
.ttp .ttp-kutu small{display:block;color:var(--soluk,#6b7a8b);font-size:10.5px}
.ttp .ttp-kutu b{font-size:18px;color:var(--baslik,#14315a)}
.ttp .ttp-kutu span{color:var(--soluk,#6b7a8b);font-size:11px}
.ttp .ttp-kutu.kir b{color:#9d3434}
.ttp .ttp-kutu.sari b{color:#9a5b00}
.ttp .ttp-blok{border:1px solid #e3e9f0;border-radius:4px;margin:0 18px 12px;background:#fff}
.ttp .ttp-blok h4{margin:0;padding:7px 10px;font-size:12px;background:linear-gradient(#f6f9fc,#eef3f9);border-bottom:1px solid #e3e9f0;color:#2c4a6b}
.ttp .ttp-ip{font-weight:normal;color:var(--soluk,#6b7a8b);font-size:11px}
.ttp .ttp-ic{padding:8px 10px}
.ttp .ttp-tablo{width:100%;border-collapse:collapse;font-size:11.5px}
.ttp .ttp-tablo th{text-align:left;padding:5px 8px;border-bottom:1px solid #cdd6e0;color:#3a5573;font-size:11px;white-space:nowrap}
.ttp .ttp-tablo td{padding:5px 8px;border-bottom:1px solid #eef2f6}
.ttp .ttp-tablo .sag{text-align:right}
.ttp .ttp-kirmizi{color:#9d3434}
.ttp .ttp-soluk{color:var(--soluk,#6b7a8b)}
.ttp .ttp-not{padding:6px 10px;font-size:11px;color:var(--soluk,#6b7a8b);border-top:1px solid #eef2f6}
`;
