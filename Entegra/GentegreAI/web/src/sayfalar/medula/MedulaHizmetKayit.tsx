import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { MEDULA_HATA_ONERI, MEDULA_ISLEM_DURUM, MEDULA_TAKIP_DURUM, type MedulaHizmet } from '../../api/uclar/medula';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, onay } from '../../bilesenler/mesaj';
import { gunNokta, para } from '../../bilesenler/bicim';
import { medulaSonucMetni } from '../liste/medulaAksiyonlari';
import { Adimlar, Gunluk, Rozet, Sonuc } from './medulaOrtak';

/**
 * MEDULA — HİZMET KAYDI — mockup `Ekranlar/Medula/medula_hizmet_kayit.html`.
 * Tanılar + başvuru satırları (SUT) → takibe; satır bazlı kabul/hata;
 * yerel ↔ Medula karşılaştırma fatura öncesi zorunlu adım.
 */
type Sekme = 'tani' | 'islem' | 'karsilastir' | 'gunluk';

export function MedulaHizmetKayit() {
  const { belgeId: param } = useParams();
  const belgeId = Number(param ?? 0);
  const git = useNavigate();
  const { yetki } = useOturum();
  const [v, setV] = useState<MedulaHizmet | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('islem');
  const [secili, setSecili] = useState<number[]>([]);
  const [sonuc, setSonuc] = useState<{ tur: 'ok' | 'kir' | 'sari'; metin: string } | null>(null);
  const [govde, setGovde] = useState<{ istek: string; yanit: string } | null>(null);

  const yukle = useCallback(async () => {
    try { setV(await api.medulaHizmet(belgeId)); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [belgeId]);
  useEffect(() => { void yukle() }, [yukle]);

  const gonder = async (satirIds?: number[]) => {
    await guvenli(async () => {
      const y = await api.medulaHizmetGonder(belgeId, { satirIds, tanilarDa: true });
      setSonuc({ tur: y.hata ? 'kir' : y.bekleyen ? 'sari' : 'ok', metin: `${y.gonderilen} satır gönderildi · ${y.kabul} kabul · ${y.hata} hata · ${y.bekleyen} bekliyor` });
      setSecili([]); await yukle();
    });
  };
  const iptal = async (id: number) => {
    if (!await onay('Hizmet kaydı iptal edilsin mi?')) return;
    await guvenli(async () => { const y = await api.medulaIslemIptal(id); setSonuc({ tur: y.kabul ? 'ok' : 'kir', metin: y.kabul ? y.mesaj : `${y.kod} · ${y.mesaj}` }); await yukle(); });
  };
  const yerel = async (id: number) => { await guvenli(async () => { await api.medulaIslemYerel(id); await yukle(); }) };
  const cikis = async () => {
    if (!await onay('Hasta çıkışı kaydedilsin mi?')) return;
    await guvenli(async () => { const s = await api.medulaHastaCikis(belgeId); setSonuc({ tur: s.kabul ? 'ok' : 'kir', metin: medulaSonucMetni(s) }); await yukle(); });
  };
  const fatura = async () => {
    await guvenli(async () => { const s = await api.medulaFaturaKaydet(belgeId); setSonuc({ tur: s.kabul ? 'ok' : s.bekliyor ? 'sari' : 'kir', metin: medulaSonucMetni(s) }); await yukle(); });
  };
  const govdeAc = async (id: number) => { await guvenli(async () => setGovde(await api.medulaKuyrukGovde(id))) };

  if (hata) return <div className="sahne"><div className="hata-kutusu">{hata}</div></div>;
  if (!v) return <div className="sahne"><span className="sonuk">Yükleniyor…</span></div>;
  const t = v.takip;
  const kabul = v.satirlar.filter(s => s.durum === 2), hatali = v.satirlar.filter(s => s.durum === 3);
  const yerelToplam = v.satirlar.reduce((a, s) => a + s.yerelTutar, 0);
  const medulaToplam = kabul.reduce((a, s) => a + (s.medulaTutar ?? 0), 0);
  const adim = t.sgkDurum !== 1 ? 1 : t.cikisZaman ? (t.medulaFaturaNo ? 5 : 4) : kabul.length ? 3 : 2;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>🧾 Medula — Hizmet Kaydı — {v.hasta}</h1>
          <span className="yol">Medula › Hizmet Kaydı</span>
          <span className="rozet mavi">{t.belgeNo}</span>
          {t.takipNo ? <span className="rozet ok">takip {t.takipNo}</span> : <Rozet d={t.sgkDurum} sozluk={MEDULA_TAKIP_DURUM} />}
        </div>
        <div className="basarac">
          <button className="d bir" onClick={() => void gonder()} disabled={!t.takipNo || !yetki('medula.hizmet')}>📤 Tümünü Gönder (tanı + işlem)</button>
          <button className="d" onClick={() => void gonder(secili)} disabled={!secili.length}>📤 Seçilileri gönder ({secili.length})</button>
          <button className="d" onClick={() => setSekme('karsilastir')}>⚖ Karşılaştır</button>
          <button className="d" onClick={() => void cikis()} disabled={!t.takipNo || !!t.cikisZaman}>🚪 Hasta Çıkışı</button>
          <button className="d onay" onClick={() => void fatura()} disabled={!t.cikisZaman || !!t.medulaFaturaNo || !yetki('medula.fatura')}>🧮 Fatura Kaydet</button>
          <button className="d" onClick={() => git(`/medula-kabul/${belgeId}`)}>🪪 Provizyon</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </div>
      </div>
      <div className="sahne md-sahne">
        <Adimlar aktif={adim} adimlar={['Hak sahipliği', `Takip ${t.takipNo || '—'}`, 'Hizmet kaydı', 'Hasta çıkışı', 'Fatura']} />
        <div className="md-ozet">
          <div><span>Tanı</span><b>{v.tanilar.length}</b><i>{v.tanilar.filter(x => x.durum === 2).length} kabul</i></div>
          <div className="ok"><span>İşlem kaydı</span><b>{kabul.length} / {v.satirlar.length}</b><i>kabul</i></div>
          <div className={hatali.length ? 'kir' : ''}><span>Hatalı</span><b>{hatali.length}</b><i>{hatali[0]?.sonucKod ?? ''}</i></div>
          <div><span>Tetkik / radyoloji</span><b>{v.satirlar.filter(s => s.tetkik).length}</b></div>
          <div><span>Yerel tutar</span><b>{para.format(yerelToplam)}</b></div>
          <div className={medulaToplam !== yerelToplam && kabul.length === v.satirlar.length ? 'kir' : ''}><span>Medula tutarı</span><b>{para.format(medulaToplam)}</b><i>fark {para.format(yerelToplam - medulaToplam)}</i></div>
        </div>
        {sonuc && <Sonuc tur={sonuc.tur}>{sonuc.metin}</Sonuc>}
        {!t.takipNo && <Sonuc tur="sari">Takip yok: önce <a href="#" onClick={e => { e.preventDefault(); git(`/medula-kabul/${belgeId}`) }}>provizyon alın</a>.</Sonuc>}

        <div className="ka-sekmeler">
          {([['tani', `Tanılar (${v.tanilar.length})`], ['islem', `İşlemler (SUT) (${v.satirlar.length})`], ['karsilastir', 'Karşılaştırma'], ['gunluk', 'Günlük']] as [Sekme, string][])
            .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
        </div>

        {sekme === 'tani' && (
          <div className="md-grp"><div className="md-gb">Tanılar <span className="md-sp sonuk">muayene.tani → medula_tani · ana tanı tek</span></div>
            <div className="md-dg"><table>
              <thead><tr><th className="orta">Ana</th><th>ICD-10</th><th>Tanı</th><th className="orta">Diş</th><th className="orta">Medula</th><th>Sonuç</th></tr></thead>
              <tbody>
                {v.tanilar.map(x => (
                  <tr key={x.id}><td className="orta">{x.tur === 1 ? '●' : ''}</td><td>{x.icdKod}</td><td>{x.ad}</td><td className="orta">{x.disNo ?? '—'}</td>
                    <td className="orta"><Rozet d={x.durum} sozluk={MEDULA_ISLEM_DURUM} /></td><td className="sonuk">{x.sonucKod}</td></tr>
                ))}
                {v.tanilar.length === 0 && <tr><td colSpan={6} className="sonuk">Tanı yok - muayenede tanı girilmeden Medula işlem kabul etmez (1110).</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}

        {sekme === 'islem' && (
          <div className="md-grp">
            <div className="md-dg"><table>
              <thead><tr><th className="orta"><input type="checkbox" checked={secili.length > 0 && secili.length === v.satirlar.filter(s => s.durum !== 2).length} onChange={e => setSecili(e.target.checked ? v.satirlar.filter(s => s.durum !== 2 && s.durum !== 5).map(s => s.satirId) : [])} /></th>
                <th>SUT</th><th>İşlem</th><th className="orta">Diş</th><th className="orta">Adet</th><th>Tarih</th><th className="sag">Yerel</th><th className="sag">Medula</th><th className="orta">Sıra</th><th className="orta">Durum</th><th>Sonuç</th><th /></tr></thead>
              <tbody>
                {v.satirlar.map(s => (
                  <tr key={s.satirId} className={s.durum === 3 ? 'md-hata' : ''}>
                    <td className="orta">{s.durum !== 2 && s.durum !== 5 && <input type="checkbox" checked={secili.includes(s.satirId)} onChange={e => setSecili(e.target.checked ? [...secili, s.satirId] : secili.filter(x => x !== s.satirId))} />}</td>
                    <td><code>{s.sutKodu || '—'}</code></td><td>{s.islem}{s.tetkik && <span className="rozet gri" style={{ marginLeft: 4 }}>tetkik</span>}</td>
                    <td className="orta">{s.disNo ?? '—'}</td><td className="orta">{s.adet}</td><td>{s.tarih ? gunNokta(s.tarih) : '—'}</td>
                    <td className="sag">{para.format(s.yerelTutar)}</td><td className="sag">{s.medulaTutar != null && s.durum === 2 ? para.format(s.medulaTutar) : '—'}</td>
                    <td className="orta">{s.medulaSira ?? '—'}</td>
                    <td className="orta"><Rozet d={s.durum} sozluk={MEDULA_ISLEM_DURUM} /></td>
                    <td className="sonuk">{s.sonucKod ? `${s.sonucKod} · ${s.sonucMesaj}` : ''}{s.durum === 3 && MEDULA_HATA_ONERI[s.sonucKod] ? ` → ${MEDULA_HATA_ONERI[s.sonucKod]}` : ''}</td>
                    <td className="md-satir-arac">
                      {s.durum === 3 && <button className="d" onClick={() => void gonder([s.satirId])}>↻</button>}
                      {s.medulaId && (s.durum === 2 || s.durum === 3) && <button className="d" onClick={() => void iptal(s.medulaId!)}>✖</button>}
                      {s.medulaId && s.durum === 3 && <button className="d" title="Hastaya ücretli bırak" onClick={() => void yerel(s.medulaId!)}>💳</button>}
                    </td>
                  </tr>
                ))}
                {v.satirlar.length === 0 && <tr><td colSpan={12} className="sonuk">Başvuruda hizmet satırı yok.</td></tr>}
                <tr className="grup"><td colSpan={6}>TOPLAM · {v.satirlar.length} satır</td><td className="sag">{para.format(yerelToplam)}</td><td className="sag">{para.format(medulaToplam)}</td><td colSpan={4} /></tr>
              </tbody>
            </table></div>
            <div className="md-arac"><span className="sonuk">Kaynak belge_satir · hizmet.sut_kodu (boşsa 1100). SUT kodu olmayan satırı "💳 ücretli" bırakın; Medula faturasına girmez, hasta fişinde kalır.</span></div>
          </div>
        )}

        {sekme === 'karsilastir' && (
          <div className="md-grp"><div className="md-gb">Yerel ↔ Medula <span className="md-sp sonuk">fark eşiği aşılırsa fatura döneme alınmaz</span></div>
            <div className="md-dg"><table>
              <thead><tr><th>SUT</th><th>İşlem</th><th className="sag">Yerel</th><th className="sag">Medula</th><th className="sag">Fark</th><th className="orta">Durum</th></tr></thead>
              <tbody>
                {v.satirlar.map(s => { const m = s.durum === 2 ? (s.medulaTutar ?? 0) : 0; return (
                  <tr key={s.satirId}><td>{s.sutKodu}</td><td>{s.islem}</td><td className="sag">{para.format(s.yerelTutar)}</td><td className="sag">{s.durum === 2 ? para.format(m) : '—'}</td>
                    <td className={`sag${s.yerelTutar - m !== 0 ? ' md-kir' : ''}`}>{para.format(s.yerelTutar - m)}</td>
                    <td className="orta">{s.durum === 2 ? (s.yerelTutar === m ? <span className="rozet ok">Eşit</span> : <span className="rozet uyari">Fark</span>) : <span className="rozet uyari">Yalnız yerelde</span>}</td></tr>
                ); })}
                <tr className="grup"><td colSpan={2}>TOPLAM</td><td className="sag">{para.format(yerelToplam)}</td><td className="sag">{para.format(medulaToplam)}</td><td className="sag">{para.format(yerelToplam - medulaToplam)}</td><td /></tr>
              </tbody>
            </table></div>
          </div>
        )}

        {sekme === 'gunluk' && (
          <>
            <div className="md-grp"><div className="md-gb">Bu başvurunun Medula günlüğü</div><Gunluk satirlar={v.gunluk} govdeAc={govdeAc} /></div>
            {govde && <div className="md-grp"><div className="md-gb">İstek / yanıt <span className="md-sp"><button className="d" onClick={() => setGovde(null)}>Kapat</button></span></div><pre className="md-xml">{govde.istek}{'\n---\n'}{govde.yanit}</pre></div>}
          </>
        )}
      </div>
    </>
  );
}
