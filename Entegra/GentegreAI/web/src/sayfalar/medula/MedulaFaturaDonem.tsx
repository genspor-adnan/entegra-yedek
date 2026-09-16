import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { MEDULA_DONEM_DURUM, MEDULA_FATURA_DURUM, type MedulaDonemOzeti } from '../../api/uclar/medula';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { gunNokta, para, tarihSaat } from '../../bilesenler/bicim';
import { medulaSonucMetni } from '../liste/medulaAksiyonlari';
import { Rozet, Sonuc } from './medulaOrtak';

/**
 * MEDULA — FATURA & DÖNEM — mockup `Ekranlar/Medula/medula_fatura_donem.html`.
 * Takip → fatura (Medula tutarı), fark eşiği, dönem sonlandırma engelleri,
 * kesinti / itiraz, ödeme takibi.
 */
type Sekme = 'liste' | 'donem' | 'kesinti' | 'odeme';
const AYLAR = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];

export function MedulaFaturaDonem() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const bugun = new Date();
  const [yil, setYil] = useState(bugun.getFullYear());
  const [ay, setAy] = useState(bugun.getMonth() + 1);
  const [v, setV] = useState<MedulaDonemOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('liste');
  const [suzgec, setSuzgec] = useState<'tumu' | 'kayitli' | 'faturasiz' | 'fark'>('tumu');
  const [sonuc, setSonuc] = useState<{ tur: 'ok' | 'kir' | 'sari'; metin: string } | null>(null);

  const yukle = useCallback(async () => {
    try { setV(await api.medulaDonem(yil, ay)); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [yil, ay]);
  useEffect(() => { void yukle() }, [yukle]);

  const faturaKaydet = async (belgeId: number) => {
    await guvenli(async () => { const s = await api.medulaFaturaKaydet(belgeId); setSonuc({ tur: s.kabul ? 'ok' : s.bekliyor ? 'sari' : 'kir', metin: medulaSonucMetni(s) }); await yukle(); });
  };
  const toplu = async () => {
    if (!await onay('Çıkışı verilmiş, hizmet kaydı kabul edilmiş, faturasız takipler toplu kaydedilsin mi?')) return;
    await guvenli(async () => { const y = await api.medulaFaturaToplu(yil, ay); setSonuc({ tur: y.hata ? 'sari' : 'ok', metin: `${y.denenen} takip denendi · ${y.kabul} kaydedildi · ${y.hata} hata` }); await yukle(); });
  };
  const sonlandir = async () => {
    if (!await onay(`${AYLAR[ay - 1]} ${yil} dönemi sonlandırılsın mı? Geri alınamaz; dönemdeki faturalar kapanır.`, true)) return;
    await guvenli(async () => { const s = await api.medulaDonemSonlandir(yil, ay); setSonuc({ tur: s.kabul ? 'ok' : s.bekliyor ? 'sari' : 'kir', metin: medulaSonucMetni(s) }); await yukle(); });
  };
  const faturaIptal = async (id: number) => {
    if (!await onay('Fatura iptal edilsin mi?')) return;
    await guvenli(async () => { const y = await api.medulaFaturaIptal(id); setSonuc({ tur: y.kabul ? 'ok' : 'kir', metin: y.kabul ? y.mesaj : `${y.kod} · ${y.mesaj}` }); await yukle(); });
  };
  const kesintiEkle = async (faturaId: number) => {
    const tutar = await metinSor('Kesinti tutarı', '0'); if (tutar === null) return;
    const kod = await metinSor('Kesinti kodu', 'K-'); if (kod === null) return;
    const acik = await metinSor('Açıklama', ''); if (acik === null) return;
    await guvenli(async () => { await api.medulaKesintiEkle({ medulaFaturaId: faturaId, kesintiKodu: kod, aciklama: acik, tutar: Number(String(tutar).replace(',', '.')) || 0 }); await yukle(); setSekme('kesinti'); });
  };
  const itiraz = async (id: number) => {
    const m = await metinSor('İtiraz gerekçesi', ''); if (m === null) return;
    await guvenli(async () => { await api.medulaItiraz(id, m); await yukle(); });
  };
  const itirazSonuc = async (id: number, kabul: boolean) => {
    await guvenli(async () => { const y = await api.medulaItirazSonuc(id, kabul); mesaj(kabul ? `Kabul · iade ${para.format(y.iade)}` : 'Red kaydedildi.'); await yukle(); });
  };

  if (hata) return <div className="sahne"><div className="hata-kutusu">{hata}</div></div>;
  const o = v?.ozet, d = v?.donem;
  const takipler = (v?.takipler ?? []).filter(t =>
    suzgec === 'kayitli' ? t.faturaId != null && (t.faturaDurum ?? 0) >= 2
    : suzgec === 'faturasiz' ? t.faturaId == null
    : suzgec === 'fark' ? t.faturaId != null && Math.abs(t.yerelTutar - (t.medulaTutar ?? 0)) > (v?.esik ?? 0)
    : true);
  const engeller = o ? [
    o.hizmetEksik ? `${o.hizmetEksik} takipte hizmet kaydı eksik → önce gönder` : null,
    o.hatali ? `${o.hatali} takipte hatalı kayıt → düzelt ya da ücretli işaretle` : null,
    o.farkli ? `${o.farkli} faturada tutar farkı → karşılaştır` : null,
    o.faturaBekleyen ? `${o.faturaBekleyen} takip faturasız → fatura kaydet` : null,
  ].filter(Boolean) as string[] : [];
  const sonlandirilabilir = engeller.length === 0 && (d?.durum ?? 1) === 1 && (o?.faturali ?? 0) > 0;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>🧮 Medula — Fatura &amp; Dönem</h1>
          <span className="yol">Medula › Fatura &amp; Dönem</span>
          {d && <Rozet d={d.durum} sozluk={MEDULA_DONEM_DURUM} />}
        </div>
        <div className="basarac">
          <select value={ay} onChange={e => setAy(Number(e.target.value))}>{AYLAR.map((a, i) => <option key={a} value={i + 1}>{a}</option>)}</select>
          <input type="number" value={yil} onChange={e => setYil(Number(e.target.value))} style={{ width: 80 }} />
          <button className="d bir" onClick={() => void toplu()} disabled={!yetki('medula.fatura')}>🧾 Toplu Fatura Kaydet</button>
          <button className="d onay" onClick={() => void sonlandir()} disabled={!sonlandirilabilir}>🔒 Dönemi Sonlandır</button>
          <button className="d" onClick={() => git('/medula-fatura')}>📑 Fatura Listesi</button>
          <button className="d" onClick={() => git('/medula-kesinti')}>⚖ Kesintiler</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </div>
      </div>
      <div className="sahne md-sahne">
        <div className="md-ozet">
          <div><span>{AYLAR[ay - 1]} {yil} · takip</span><b>{o?.takip ?? 0}</b><i>{o?.cikissiz ?? 0} çıkışsız</i></div>
          <div className="ok"><span>Medula'ya kaydedilen</span><b>{o?.faturali ?? 0}</b><i>{o?.takip ? Math.round(100 * (o.faturali / o.takip)) : 0}%</i></div>
          <div className={o?.faturaBekleyen ? 'kir' : ''}><span>Fatura bekleyen</span><b>{o?.faturaBekleyen ?? 0}</b><i>hizmet eksik {o?.hizmetEksik ?? 0} · hata {o?.hatali ?? 0}</i></div>
          <div><span>Dönem tutarı (Medula)</span><b>{para.format(o?.medulaTutar ?? 0)}</b></div>
          <div className={o?.farkli ? 'kir' : ''}><span>Yerel tutar</span><b>{para.format(o?.yerelTutar ?? 0)}</b><i>fark {o?.farkli ?? 0} takip · eşik {v?.esik ?? 0}</i></div>
          <div><span>Dönem</span><b><Rozet d={d?.durum ?? 1} sozluk={MEDULA_DONEM_DURUM} /></b><i>uyarı: ayın {v?.uyariGun}'i</i></div>
        </div>
        {sonuc && <Sonuc tur={sonuc.tur}>{sonuc.metin}</Sonuc>}

        <div className="ka-sekmeler">
          {([['liste', 'Fatura Listesi'], ['donem', 'Dönem Sonlandırma'], ['kesinti', 'Kesinti / İtiraz'], ['odeme', 'Ödeme Takibi']] as [Sekme, string][])
            .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
        </div>

        {sekme === 'liste' && (
          <div className="md-grp">
            <div className="md-arac">
              {([['tumu', 'Tümü'], ['kayitli', 'Kaydedildi'], ['faturasiz', 'Faturasız'], ['fark', 'Fark var']] as [typeof suzgec, string][])
                .map(([k, ad]) => <span key={k} className={`cip${suzgec === k ? ' on' : ''}`} onClick={() => setSuzgec(k)}>{ad}</span>)}
            </div>
            <div className="md-dg"><table>
              <thead><tr><th>Takip no</th><th>Hasta</th><th>Başvuru</th><th>Tarih</th><th>Hekim</th><th className="orta">Çıkış</th><th className="orta">İşlem</th><th className="sag">Yerel</th><th className="sag">Medula</th><th className="sag">Katılım</th><th>Fatura no</th><th className="orta">Durum</th><th /></tr></thead>
              <tbody>
                {takipler.map(t => {
                  const fark = t.medulaTutar != null ? t.yerelTutar - t.medulaTutar : 0;
                  return (
                    <tr key={t.belgeId}>
                      <td>{t.takipNo}</td><td>{t.hasta}</td><td>{t.belgeNo}</td><td>{gunNokta(t.tarih)}</td><td>{t.hekim}</td>
                      <td className="orta">{t.cikis ? '✔' : '—'}</td><td className="orta">{t.kabulIslem}{t.hataliIslem ? <span className="md-kir"> / {t.hataliIslem}</span> : ''}</td>
                      <td className="sag">{para.format(t.yerelTutar)}</td><td className="sag">{t.medulaTutar != null ? para.format(t.medulaTutar) : '—'}</td>
                      <td className="sag">{t.katilim != null ? para.format(t.katilim) : '—'}</td><td>{t.faturaNo || '—'}</td>
                      <td className="orta">{t.faturaId ? <>{fark !== 0 && (t.faturaDurum ?? 0) >= 2 ? <span className="rozet uyari">Fark {para.format(fark)}</span> : <Rozet d={t.faturaDurum} sozluk={MEDULA_FATURA_DURUM} />}</>
                        : !t.cikis ? <span className="rozet gri">Çıkış yok</span> : t.kabulIslem === 0 ? <span className="rozet hata">Hizmet kaydı yok</span> : <span className="rozet uyari">Fatura bekliyor</span>}</td>
                      <td className="md-satir-arac">
                        {!t.faturaId && t.cikis && t.kabulIslem > 0 && <button className="d" onClick={() => void faturaKaydet(t.belgeId)}>🧾 Kaydet</button>}
                        {t.kabulIslem === 0 && <button className="d" onClick={() => git(`/medula-hizmet/${t.belgeId}`)}>🧾 Hizmet</button>}
                        {t.faturaId && (t.faturaDurum ?? 0) < 4 && <button className="d" onClick={() => void faturaIptal(t.faturaId!)}>✖</button>}
                        {t.faturaId && (t.faturaDurum ?? 0) >= 3 && <button className="d" onClick={() => void kesintiEkle(t.faturaId!)}>➖ Kesinti</button>}
                      </td>
                    </tr>
                  );
                })}
                {takipler.length === 0 && <tr><td colSpan={13} className="sonuk">Bu dönemde takip yok.</td></tr>}
                <tr className="grup"><td colSpan={7}>{AYLAR[ay - 1]} {yil} · {takipler.length} takip</td><td className="sag">{para.format(takipler.reduce((a, t) => a + t.yerelTutar, 0))}</td><td className="sag">{para.format(takipler.reduce((a, t) => a + (t.medulaTutar ?? 0), 0))}</td><td colSpan={4} /></tr>
              </tbody>
            </table></div>
          </div>
        )}

        {sekme === 'donem' && (
          <div className="md-iki">
            <div className="md-grp"><div className="md-gb">Dönem sonlandırma (donemSonlandir) <span className="md-sp sonuk">geri alınamaz · yetki medula.donem</span></div>
              <div className="md-hdr k2">
                <div><label>Dönem</label><div className="md-inp">{yil} / {String(ay).padStart(2, '0')}</div></div>
                <div><label>Kaydedilen fatura</label><div className="md-inp">{o?.faturali ?? 0} · {para.format(o?.medulaTutar ?? 0)}</div></div>
                <div><label>Faturasız takip</label><div className={`md-inp${o?.faturaBekleyen ? ' err' : ''}`}>{o?.faturaBekleyen ?? 0} · sonlandırınca dönem dışı kalır</div></div>
                <div><label>Durum</label><div className="md-inp"><Rozet d={d?.durum ?? 1} sozluk={MEDULA_DONEM_DURUM} />{d?.icmalNo ? ` · icmal ${d.icmalNo}` : ''}</div></div>
              </div>
              <ul className="md-liste">
                {engeller.map(e => <li key={e}><span className="rozet hata">✖</span> {e}</li>)}
                {engeller.length === 0 && <li><span className="rozet ok">✔</span> Engel yok</li>}
                {v?.donemler.find(x => x.yil === (ay === 1 ? yil - 1 : yil) && x.ay === (ay === 1 ? 12 : ay - 1)) ? <li><span className="rozet ok">✔</span> Önceki dönem kaydı var</li> : <li><span className="rozet gri">—</span> Önceki dönem kaydı yok</li>}
              </ul>
              <div className="md-arac"><button className="d onay" onClick={() => void sonlandir()} disabled={!sonlandirilabilir}>🔒 Dönemi Sonlandır</button><span className="sonuk">engeller kalkınca aktif</span></div>
            </div>
            <div className="md-grp"><div className="md-gb">Dönemler</div>
              <div className="md-dg"><table>
                <thead><tr><th>Dönem</th><th className="orta">Fatura</th><th className="sag">Tutar</th><th className="sag">Kesinti</th><th>Sonlandırma</th><th>İcmal</th><th className="orta">Durum</th></tr></thead>
                <tbody>
                  {(v?.donemler ?? []).map(x => (
                    <tr key={x.id} className={x.yil === yil && x.ay === ay ? 'sel' : ''} onClick={() => { setYil(x.yil); setAy(x.ay); }}>
                      <td>{x.yil}/{String(x.ay).padStart(2, '0')}</td><td className="orta">{x.faturaSayisi}</td><td className="sag">{para.format(x.toplam)}</td><td className="sag">{para.format(x.kesinti)}</td>
                      <td>{x.sonlandirma ? tarihSaat(x.sonlandirma) : '—'}</td><td>{x.icmalNo || '—'}</td><td className="orta"><Rozet d={x.durum} sozluk={MEDULA_DONEM_DURUM} /></td>
                    </tr>
                  ))}
                  {(v?.donemler ?? []).length === 0 && <tr><td colSpan={7} className="sonuk">Dönem kaydı yok - ilk fatura kaydıyla açılır.</td></tr>}
                </tbody>
              </table></div>
              <div className="md-ic sonuk">Sonlandırma → icmal → satış tahakkuku (SGK carisi) → e-Fatura → ödeme takibi. Dönem kapanınca fatura satırı değişmez; düzeltme ek dönem ya da itirazla.</div>
            </div>
          </div>
        )}

        {sekme === 'kesinti' && (
          <div className="md-grp"><div className="md-gb">Kesinti / itiraz</div>
            <div className="md-dg"><table>
              <thead><tr><th>Fatura no</th><th>Hasta</th><th>Takip</th><th>Dönem</th><th>SUT</th><th>Kod</th><th>Açıklama</th><th className="sag">Kesinti</th><th className="orta">İtiraz</th><th className="sag">İade</th><th /></tr></thead>
              <tbody>
                {(v?.kesintiler ?? []).map(k => (
                  <tr key={k.id}>
                    <td>{k.faturaNo}</td><td>{k.hasta}</td><td>{k.takipNo}</td><td>{k.yil ? `${k.yil}/${String(k.ay).padStart(2, '0')}` : '—'}</td><td>{k.sutKodu}</td><td>{k.kesintiKodu}</td><td>{k.aciklama}</td>
                    <td className="sag">{para.format(k.tutar)}</td>
                    <td className="orta"><Rozet d={k.itirazDurum} sozluk={{ 0: ['Edilmedi', 'gri'], 1: ['Bekliyor', 'mavi'], 2: ['Kabul · iade', 'ok'], 3: ['Red', 'hata'] }} /></td>
                    <td className="sag">{para.format(k.iadeTutar)}</td>
                    <td className="md-satir-arac">
                      {k.itirazDurum === 0 && <button className="d" onClick={() => void itiraz(k.id)}>📝 İtiraz</button>}
                      {k.itirazDurum === 1 && <><button className="d" onClick={() => void itirazSonuc(k.id, true)}>✔ Kabul</button><button className="d" onClick={() => void itirazSonuc(k.id, false)}>✖ Red</button></>}
                    </td>
                  </tr>
                ))}
                {(v?.kesintiler ?? []).length === 0 && <tr><td colSpan={11} className="sonuk">Kesinti yok. Fatura listesinde "➖ Kesinti" ile SGK inceleme sonucu yazılır.</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}

        {sekme === 'odeme' && (
          <div className="md-grp"><div className="md-gb">Ödeme takibi</div>
            <div className="md-dg"><table>
              <thead><tr><th>Dönem</th><th className="sag">Fatura tutarı</th><th className="sag">Kesinti</th><th className="sag">Net</th><th className="sag">Ödenen</th><th>Ödeme tarihi</th><th className="sag">Kalan</th><th className="orta">Durum</th></tr></thead>
              <tbody>
                {(v?.donemler ?? []).map(x => (
                  <tr key={x.id}><td>{x.yil}/{String(x.ay).padStart(2, '0')}</td><td className="sag">{para.format(x.toplam)}</td><td className="sag">{para.format(x.kesinti)}</td><td className="sag">{para.format(x.toplam - x.kesinti)}</td>
                    <td className="sag">{para.format(x.odenen)}</td><td>{x.odemeTarihi ? gunNokta(x.odemeTarihi) : '—'}</td><td className={`sag${x.toplam - x.kesinti - x.odenen > 0 ? ' md-kir' : ''}`}>{para.format(x.toplam - x.kesinti - x.odenen)}</td>
                    <td className="orta"><Rozet d={x.durum} sozluk={MEDULA_DONEM_DURUM} /></td></tr>
                ))}
              </tbody>
            </table></div>
            <div className="md-ic sonuk">Ödeme dönem kartından (Dönemler listesi) yazılır; banka hareketiyle eşleme Finans'ta.</div>
          </div>
        )}
      </div>
    </>
  );
}
