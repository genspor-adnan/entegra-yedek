import { useCallback, useContext, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { TELETIP_DURUM, mesajKisaAdi, mesajUzunAdi, type TeletipIstemOzet, type TeletipSatir } from '../api/uclar/teletip';
import { EkranSekmesiBaglami, sekmeAdi } from '../bilesenler/sekmeBaglami';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { tarihSaat } from '../bilesenler/bicim';
import { c } from '../dil/ceviri';

/**
 * TELETIP GÖNDERİM KARTI (1304; mockup Ekranlar/Radyoloji/teletip_mirth.html §4): bir radyoloji isteminin Bakanlık
 * mesaj izi. Rota /teletip/:istemId (liste satırı da istem). Sol: mesaj izi (her NW / XO / CA bir satır; durum, deneme,
 * ACK, sorun) ve seçili mesajın ham HL7'si + ACK'i. Sağ: "ne yapmalı" (sorunun açıklaması) ve göndermeden önizleme
 * (şu anki veriyle kurulacak mesaj + eksik listesi). Yeniden gönder yalnız sonuçlanmamış satırda (kuyrukta / reddedildi
 * / gidemez / ulaşmadı). CSS öneki `ttk-`.
 */
export function TeletipGonderimKarti() {
  const { id } = useParams();
  const istemId = Number(id);
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const [v, setV] = useState<{ aktif: boolean; istem: TeletipIstemOzet | null; satirlar: TeletipSatir[] } | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<number | null>(null);
  const [ham, setHam] = useState<{ mesaj: string; yanit: string } | null>(null);
  const [onizleme, setOnizleme] = useState<{ eksikler: string[]; mesaj: string } | null>(null);
  const [mesgul, setMesgul] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const y = await api.teletipIstem(istemId);
      setV(y); setHata(null);
      // Varsayılan seçim: en son sorunlu, yoksa en son mesaj.
      const sorunlu = [...y.satirlar].reverse().find(s => s.durum === 2 || s.durum === 3 || s.durum === 5);
      setSecili(s => s ?? (sorunlu ?? y.satirlar[y.satirlar.length - 1])?.id ?? null);
    } catch (e) { setHata(hataMetni(e)) }
  }, [istemId]);
  useEffect(() => { if (istemId > 0) void yukle() }, [istemId, yukle]);

  useEffect(() => {
    if (!secili) { setHam(null); return }
    let iptal = false;
    api.teletipMesaj(secili).then(y => { if (!iptal) setHam(y) }).catch(() => { if (!iptal) setHam(null) });
    return () => { iptal = true };
  }, [secili, v]);

  const hastaAdi = v?.istem?.hastaAdi ?? '';
  useEffect(() => {
    // Sekme ikonu liste tanımından (kartIc 🏛) gelir; başlığa ayrıca eklenmez.
    if (ekranSekmesi && istemId) ekranSekmesi.baslik(sekmeAdi(hastaAdi || c('TeleRadyoloji')), `/teletip/${istemId}`);
  }, [ekranSekmesi, hastaAdi, istemId]);

  const istemKarti = () => {
    const yol = `/radyoloji/${istemId}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };
  const dene = (s: TeletipSatir) => guvenli(async () => {
    setMesgul(true);
    try {
      const y = await api.teletipDene(s.id);
      const d = TELETIP_DURUM[y.durum]?.ad ?? String(y.durum);
      mesaj(y.durum === 1 ? c('TeleRadyoloji kabul etti (AA).') : `${c('Sonuç')}: ${c(d)}${y.hata ? ` - ${y.hata}` : ''}`);
      await yukle();
    } finally { setMesgul(false) }
  });
  const onizle = () => guvenli(async () => setOnizleme(await api.teletipOnizle(istemId)));

  if (!(istemId > 0)) return null;
  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!v) return <div className="fm-sayfa"><div className="yukleniyor">{c('Yükleniyor…')}</div></div>;

  const satir = v.satirlar.find(s => s.id === secili) ?? null;
  const ist = v.istem;
  return (
    <div className="fm-sayfa ttk" data-testid="teletip-kart">
      <style>{TTK_STIL}</style>
      <div className="ttk-bas">
        <h1>🏛 {c('TeleRadyoloji Gönderimi')}</h1>
        {ist && <span className="ttk-acc">{ist.accessionNo}</span>}
        {!v.aktif && <span className="rozet uyari">{c('Kurumda TeleRadyoloji gönderimi kapalı')}</span>}
        <div className="ttk-sag">
          <button type="button" className="d" onClick={() => void yukle()}>🔄 {c('Yenile')}</button>
          <button type="button" className="d" onClick={() => void onizle()}>🔍 {c('Önizle / Eksikler')}</button>
          {ist && <button type="button" className="d" onClick={istemKarti}>📄 {c('İstem Kartı')}</button>}
        </div>
      </div>
      <div className="ttk-band">
        {ist ? <>
          <div><span className="ttk-k">{c('Hasta')}</span><span className="ttk-v">{ist.hastaAdi}</span></div>
          <div><span className="ttk-k">{c('Tetkik')}</span><span className="ttk-v">{ist.tetkikAdi}</span></div>
          <div><span className="ttk-k">{c('Mod.')}</span><span className="rozet mavi">{ist.modalite}</span></div>
          <div><span className="ttk-k">{c('Kabul')}</span><span className="ttk-v">{tarihSaat(ist.kabul)}</span></div>
          <div><span className="ttk-k">{c('İstem durumu')}</span><span className="ttk-v">{c(ISTEM_DURUM[ist.durum] ?? String(ist.durum))}</span></div>
        </> : <div className="ttk-soluk">{c('İstem silinmiş - yalnız gönderim izi duruyor.')}</div>}
      </div>

      <div className="ttk-govde">
        <div>
          <div className="ttk-blok">
            <h4>{c('Mesaj izi')} <span className="ttk-ip">· Gentegre → Mirth K1 → TeleRadyoloji</span></h4>
            {v.satirlar.length === 0
              ? <div className="ttk-soluk ttk-ic">{c('Bu istem için TeleRadyoloji mesajı yok.')}</div>
              : <table className="ttk-tablo">
                <thead><tr>
                  <th>#</th><th>{c('Emir')}</th><th>{c('Durum')}</th><th className="sag">{c('Deneme')}</th><th>ACK</th>
                  <th>{c('Kontrol no')}</th><th>{c('Kayıt')}</th><th>{c('Son deneme')}</th><th>{c('Sorun')}</th><th></th>
                </tr></thead>
                <tbody>
                  {v.satirlar.map(s => {
                    const d = TELETIP_DURUM[s.durum] ?? { ad: String(s.durum), sinif: 'gri' };
                    const denenebilir = s.durum === 0 || s.durum === 2 || s.durum === 3 || s.durum === 5;
                    return (
                      <tr key={s.id} className={`ac${s.id === secili ? ' secili' : ''}`} onClick={() => setSecili(s.id)}>
                        <td className="ttk-soluk">{s.id}</td>
                        <td title={mesajUzunAdi(s.kanal, s.emir)}><b>{mesajKisaAdi(s.kanal, s.emir)}</b> <span className="ttk-soluk">{c(mesajUzunAdi(s.kanal, s.emir))}</span></td>
                        <td><span className={`rozet ${d.sinif}`}>{c(d.ad)}</span></td>
                        <td className="sag">{s.denemeNo}</td>
                        <td>{s.ackKodu}</td>
                        <td className="ttk-soluk">{s.kontrolNo}</td>
                        <td>{tarihSaat(s.eklemeTarihi)}</td>
                        <td>{s.sonDeneme ? tarihSaat(s.sonDeneme) : '—'}</td>
                        <td className="ttk-sorun">{s.hata}</td>
                        <td>{denenebilir && <button type="button" className="d" disabled={mesgul}
                          onClick={e => { e.stopPropagation(); void dene(s) }}>🔁 {c('Yeniden gönder')}</button>}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>}
          </div>
          {satir && (
            <div className="ttk-blok">
              <h4>{satir.kanal === 2 ? c('XDS isteği (SOAP gövdesi)') : satir.kanal === 3 ? c('Doz raporu (RDSR) özeti') : c('HL7 mesajı')} <span className="ttk-ip">· {mesajKisaAdi(satir.kanal, satir.emir)} · {satir.kanal === 2 ? 'RAD-68 / ITI-41 · KOS eki gösterilmez' : satir.kanal === 3 ? 'C-STORE → TELETIP_MGA · SR ikilisi gösterilmez' : `${satir.emir === 4 ? 'ORU^R01' : 'ORM^O01'} · 2.3.1`}</span></h4>
              <div className="ttk-ic">
                {ham?.mesaj ? <pre className="ttk-hl7">{ham.mesaj}</pre>
                  : <div className="ttk-soluk">{satir.durum === 3 ? c('Mesaj gönderilmedi: eksik alanlar var (sağdaki "Ne yapmalı").')
                    : c('Bu satır için henüz gönderilmiş mesaj yok.')}</div>}
                {ham?.yanit && <>
                  <div className="ttk-k" style={{ marginTop: 8 }}>{satir.kanal === 2 ? c('TeleRadyoloji yanıtı (RegistryResponse)') : satir.kanal === 3 ? c('MGA yanıtı (C-STORE-RSP, Mirth K3)') : c('TeleRadyoloji yanıtı (ACK)')}</div>
                  <pre className="ttk-hl7 ttk-ack">{ham.yanit}</pre>
                </>}
              </div>
            </div>
          )}
        </div>

        <div>
          <div className="ttk-blok">
            <h4>{c('Ne yapmalı')}</h4>
            <div className="ttk-ic ttk-ne">{NeYapmali(satir)}</div>
          </div>
          {onizleme && (
            <div className="ttk-blok">
              <h4>{c('Önizleme')} <span className="ttk-ip">· {c('şu anki veriyle, göndermez')}</span></h4>
              <div className="ttk-ic">
                {onizleme.eksikler.length === 0
                  ? <span className="rozet olumlu">✓ {c('Eksik yok - gönderilebilir')}</span>
                  : <ul className="ttk-eksik">{onizleme.eksikler.map(e => <li key={e}>{e}</li>)}</ul>}
                <pre className="ttk-hl7" style={{ marginTop: 8 }}>{onizleme.mesaj}</pre>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

/** rad.istem_durum (283). */
const ISTEM_DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Bekliyor', 2: 'Çekildi', 3: 'Raporlanıyor', 4: 'Ön Rapor', 5: 'Onaylandı', 6: 'Teslim Edildi',
};

/** Seçili satırın durumuna göre düz yönerge (kılavuz 3.43 § 3.3 / 3.4). */
function NeYapmali(s: TeletipSatir | null) {
  if (!s) return <span className="ttk-soluk">{c('Mesaj seçin.')}</span>;
  switch (s.durum) {
    case 1: return <><span className="rozet olumlu">✓ {c('TeleRadyoloji kabul etti (AA).')}</span><p>{c('Yapılacak bir şey yok.')}</p></>;
    case 3: return <>
      <span className="rozet hata">✖ {c('Gönderilmedi - eksik var')}</span>
      <p>{c('Bakanlık bu mesajı reddederdi; gönderilmeden durduruldu. Eksikleri tamamlayın:')}</p>
      <ul className="ttk-eksik">{s.hata.split(' · ').filter(Boolean).map(e => <li key={e}>{e}</li>)}</ul>
      <p className="ttk-soluk">{c('İstem kartında yapılan değişiklik satırı kendiliğinden yeniden kuyruğa alır; kurum ayarı (SKRS, firma kodu) değiştiyse "Yeniden gönder".')}</p>
    </>;
    case 2: return <>
      <span className="rozet hata">✖ {c('TeleRadyoloji reddetti')} {s.ackKodu && `(${s.ackKodu})`}</span>
      <p>{s.hata}</p>
      <p className="ttk-soluk">{c('Reddedilen mesaj kendiliğinden tekrar gönderilmez (aynı mesaj yine reddedilir). Hata kodundaki alanı düzeltip "Yeniden gönder".')}</p>
    </>;
    case 5: return <>
      <span className="rozet uyari">… {c('Ulaşılamadı - tekrar denenecek')}</span>
      <p>{s.hata}</p>
      <p className="ttk-soluk">{c('Mirth ya da TeleRadyoloji yanıt vermedi; kuyruk artan aralıkla dener. Sonraki deneme')}: {s.sonrakiDeneme ? tarihSaat(s.sonrakiDeneme) : '—'}</p>
    </>;
    case 0: return <><span className="rozet uyari">… {c('Kuyrukta')}</span><p className="ttk-soluk">{c('İşçi 30 saniyede bir gönderir; önceki mesaj sonuçlanmadan sıradaki gitmez.')}</p></>;
    default: return <><span className="rozet gri">{c('Atlandı')}</span><p>{s.hata || c('İstem iptal edildi ya da mesaj gereksiz kaldı.')}</p></>;
  }
}

const TTK_STIL = `
.ttk .ttk-bas{display:flex;align-items:center;gap:10px;padding:10px 18px;border-bottom:1px solid #e3e9f0}
.ttk .ttk-bas h1{font-size:16px;margin:0;color:var(--baslik,#14315a)}
.ttk .ttk-acc{font-family:Consolas,monospace;background:#eef4fc;border:1px solid #cfe0f5;border-radius:10px;padding:1px 9px;font-size:12px}
.ttk .ttk-sag{margin-left:auto;display:flex;gap:6px}
.ttk .ttk-band{display:flex;gap:22px;flex-wrap:wrap;padding:8px 18px;background:#fbfcfd;border-bottom:1px solid #e3e9f0;align-items:center}
.ttk .ttk-k{font-size:10px;color:var(--soluk,#6b7a8b);text-transform:uppercase;letter-spacing:.3px;margin-right:7px}
.ttk .ttk-v{font-size:12.5px;font-weight:bold}
.ttk .ttk-govde{display:grid;grid-template-columns:minmax(0,1fr) 360px;gap:12px;padding:12px 18px}
@media (max-width:1000px){.ttk .ttk-govde{grid-template-columns:1fr}}
.ttk .ttk-blok{border:1px solid #e3e9f0;border-radius:4px;margin-bottom:12px;background:#fff}
.ttk .ttk-blok h4{margin:0;padding:7px 10px;font-size:12px;background:linear-gradient(#f6f9fc,#eef3f9);border-bottom:1px solid #e3e9f0;color:#2c4a6b}
.ttk .ttk-ip{font-weight:normal;color:var(--soluk,#6b7a8b);font-size:11px}
.ttk .ttk-ic{padding:8px 10px}
.ttk .ttk-tablo{width:100%;border-collapse:collapse;font-size:11.5px}
.ttk .ttk-tablo th{text-align:left;padding:5px 7px;border-bottom:1px solid #cdd6e0;color:#3a5573;font-size:11px;white-space:nowrap}
.ttk .ttk-tablo td{padding:5px 7px;border-bottom:1px solid #eef2f6;vertical-align:top}
.ttk .ttk-tablo tr.secili td{background:#eef4fc}
.ttk .ttk-tablo .sag{text-align:right}
.ttk .ttk-sorun{color:#9d3434;max-width:380px}
.ttk .ttk-soluk{color:var(--soluk,#6b7a8b)}
.ttk .ttk-hl7{margin:0;font-family:Consolas,monospace;font-size:11px;white-space:pre-wrap;word-break:break-all;background:#0f1a26;color:#cfe0f5;border-radius:3px;padding:8px;max-height:340px;overflow:auto}
.ttk .ttk-ack{background:#13261a;color:#cfeedd}
.ttk .ttk-ne p{margin:6px 0;line-height:1.5}
.ttk .ttk-eksik{margin:6px 0 6px 18px;padding:0;color:#9d3434;line-height:1.5}
`;
