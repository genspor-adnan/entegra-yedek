import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { MEDULA_TAKIP_DURUM, type MedulaHastaOzeti, type MedulaKuyrukSatiri, type MedulaTakip } from '../../api/uclar/medula';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { TarafSecici } from '../../bilesenler/TarafArama';
import { gunNokta, para, tarihSaat } from '../../bilesenler/bicim';
import { medulaSonucMetni } from '../liste/medulaAksiyonlari';
import { Adimlar, Gunluk, Rozet, Sonuc } from './medulaOrtak';

/**
 * MEDULA — HASTA KABUL / PROVİZYON — mockup `Ekranlar/Medula/medula_hasta_kabul.html`.
 *
 * Sıra: TCKN → hak sahipliği → hasta kartı/başvuru → provizyon (takip no) →
 * hizmet kaydı → çıkış → fatura. Bu ekran İSTİSNA ekranıdır: hata (1006 açık
 * takip, 1013 müstehak değil), sevkli hasta, takip iptali, elle tekrar.
 * Günlük akışta Kayıt Kabul otomatik yürütür (ayarlar).
 */
const TAKIP_TIPI = [[1, 'A — Ayaktan'], [2, 'Y — Yatan'], [3, 'G — Günübirlik']] as const;
const PROV_TIPI = [[1, 'N — Normal'], [2, 'A — Acil'], [3, 'İ — İş kazası'], [4, 'T — Trafik kazası'], [5, 'M — Meslek hastalığı']] as const;
type Sekme = 'hak' | 'kabul' | 'ara' | 'gunluk';

export function MedulaHastaKabul() {
  const { belgeId: param } = useParams();
  const git = useNavigate();
  const { yetki } = useOturum();
  const [hastaId, setHastaId] = useState<number>(0);
  const [hastaAdi, setHastaAdi] = useState('');
  const [belgeId, setBelgeId] = useState<number>(Number(param ?? 0));
  const [ozet, setOzet] = useState<MedulaHastaOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('hak');
  const [sonuc, setSonuc] = useState<{ tur: 'ok' | 'kir' | 'sari'; metin: string } | null>(null);
  const [takipTipi, setTakipTipi] = useState(1);
  const [provTipi, setProvTipi] = useState(1);
  const [sevkli, setSevkli] = useState(false);
  const [sevkKurum, setSevkKurum] = useState('');
  const [ara, setAra] = useState('');
  const [araSonuc, setAraSonuc] = useState<{ takip: MedulaTakip; hastaId: number; hasta: string }[]>([]);
  const [gunluk, setGunluk] = useState<MedulaKuyrukSatiri[]>([]);
  const [govde, setGovde] = useState<{ istek: string; yanit: string } | null>(null);

  const yukle = useCallback(async (hid: number) => {
    if (!hid) return;
    try {
      const o = await api.medulaHastaOzeti(hid);
      setOzet(o); setHastaAdi(o.hasta.unvan); setHata(null);
      const k = await api.medulaKuyruk(undefined, o.hasta.unvan);
      setGunluk(k.satirlar.filter(s => s.hastaId === hid));
    } catch (h) { setHata(hataMetni(h)) }
  }, []);

  // Başvurudan gelindiyse hasta başvurudan çözülür.
  useEffect(() => {
    if (!belgeId) return;
    void (async () => {
      try { const h = await api.medulaHizmet(belgeId); setHastaId(h.hastaId); await yukle(h.hastaId); setSekme('kabul'); }
      catch (e) { setHata(hataMetni(e)) }
    })();
  }, [belgeId, yukle]);

  const secTakip = ozet?.takipler.find(t => t.belgeId === belgeId) ?? null;
  const sonMust = ozet?.takipler.find(t => t.mustehaklik > 0) ?? null;

  const mustehaklik = async () => {
    if (!hastaId) { mesaj('Önce hasta seçin.'); return }
    await guvenli(async () => {
      const s = await api.medulaMustehaklik({ hastaId, belgeId: belgeId || null, provizyonTipi: provTipi });
      setSonuc({ tur: s.kabul ? 'ok' : s.bekliyor ? 'sari' : 'kir', metin: medulaSonucMetni(s) });
      await yukle(hastaId);
    });
  };
  const hastaKabul = async () => {
    if (!belgeId) { mesaj('Provizyon başvuru üstünden alınır: Takip Ara sekmesinden başvuru seçin ya da Kayıt Kabul\'den başvuru açın.'); return }
    await guvenli(async () => {
      const s = await api.medulaHastaKabul(belgeId, { takipTipi, provizyonTipi: provTipi, sevkli, sevkKurum });
      setSonuc({ tur: s.kabul ? 'ok' : s.bekliyor ? 'sari' : 'kir', metin: medulaSonucMetni(s) });
      await yukle(hastaId);
    });
  };
  const iptal = async () => {
    if (!belgeId || !await onay('Takip iptal edilsin mi? Hizmet kaydı varsa Medula reddeder.')) return;
    await guvenli(async () => { const s = await api.medulaHastaKabulIptal(belgeId); setSonuc({ tur: s.kabul ? 'ok' : 'kir', metin: medulaSonucMetni(s) }); await yukle(hastaId); });
  };
  const cikis = async () => {
    if (!belgeId || !await onay('Hasta çıkışı kaydedilsin mi? Takip kapanır.')) return;
    await guvenli(async () => { const s = await api.medulaHastaCikis(belgeId); setSonuc({ tur: s.kabul ? 'ok' : 'kir', metin: medulaSonucMetni(s) }); await yukle(hastaId); });
  };
  const takipAra = async () => {
    await guvenli(async () => setAraSonuc(await api.medulaTakipAra(ara || hastaAdi, false)));
  };
  const govdeAc = async (id: number) => { await guvenli(async () => setGovde(await api.medulaKuyrukGovde(id))) };

  const h = ozet?.hasta;
  const adim = !hastaId ? 0 : !sonMust ? 0 : !belgeId ? 1 : secTakip && secTakip.sgkDurum === 1 ? (secTakip.cikisZaman ? 5 : 4) : 3;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>🪪 Medula — Hasta Kabul / Provizyon</h1>
          <span className="yol">Medula › Hasta Kabul</span>
          {h && <span className="rozet mavi">{h.unvan}{h.tckn ? ` · ${h.tckn}` : ''}</span>}
          {secTakip && <Rozet d={secTakip.sgkDurum} sozluk={MEDULA_TAKIP_DURUM} />}
        </div>
        <div className="basarac">
          <button className="d bir" onClick={() => void mustehaklik()}>🔎 Hak Sahipliği Sorgula</button>
          <button className="d onay" onClick={() => void hastaKabul()} disabled={!belgeId}>✔ Provizyon Al</button>
          <button className="d" onClick={() => void iptal()} disabled={!secTakip || secTakip.sgkDurum !== 1}>✖ Kabulü İptal Et</button>
          <button className="d" onClick={() => void cikis()} disabled={!secTakip || secTakip.sgkDurum !== 1 || !!secTakip.cikisZaman}>🚪 Hasta Çıkışı</button>
          {belgeId > 0 && yetki('medula.hizmet') && <button className="d" onClick={() => git(`/medula-hizmet/${belgeId}`)}>🧾 Hizmet Kaydına Geç</button>}
          <button className="d" onClick={() => git('/medula-takip')}>📋 Takipler</button>
        </div>
      </div>
      <div className="sahne md-sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        <Adimlar aktif={adim} adimlar={['TCKN → hak sahipliği', 'Hasta kartı', 'Başvuru aç (ödeyen = sonuçtan)', 'Provizyon / takip no', 'Hizmet kaydı', 'Çıkış · fatura']} />
        <div className="md-hdr">
          <div><label>Hasta</label>
            <TarafSecici etiket="" deger={hastaAdi} kaynaklar={['hasta']} bosMetin="TCKN / ad ile hasta seçin…"
              onSec={s => { setHastaId(s.id); setHastaAdi(s.unvan); setBelgeId(0); setSonuc(null); void yukle(s.id); }} onTemizle={() => { setHastaId(0); setHastaAdi(''); setOzet(null); }} />
          </div>
          <div><label>Müstehaklık</label><div className="md-inp">
            {sonMust ? <><Rozet d={sonMust.mustehaklik === 1 ? 1 : 2} sozluk={{ 1: ['Müstehak', 'ok'], 2: ['Müstehak değil', 'hata'] }} /> {sonMust.sigortaTuru} · {sonMust.mustehaklikZaman ? tarihSaat(sonMust.mustehaklikZaman) : ''}</>
              : <span className="sonuk">sorgulanmadı</span>}
          </div></div>
          <div><label>Başvuru</label><div className="md-inp">
            {secTakip ? `${secTakip.belgeNo} · ${gunNokta(secTakip.belgeTarihi)} · ${secTakip.hekim || '—'}` : <span className="sonuk">seçilmedi · Takip Ara'dan seçin</span>}
          </div></div>
          <div><label>Takip no</label><div className="md-inp">
            {secTakip?.takipNo ? <><b>{secTakip.takipNo}</b> · geçerlilik {secTakip.gecerlilik ? gunNokta(secTakip.gecerlilik) : '—'}{secTakip.cikisZaman ? ' · çıkış verildi' : ''}</>
              : <span className="sonuk">{secTakip?.redNedeni || 'provizyon alınmadı'}</span>}
          </div></div>
        </div>
        {sonuc && <Sonuc tur={sonuc.tur}>{sonuc.metin}</Sonuc>}

        <div className="ka-sekmeler">
          {([['hak', 'Hak Sahipliği'], ['kabul', 'Hasta Kabul (Provizyon)'], ['ara', 'Takip Ara / Oku'], ['gunluk', 'Sonuç & Günlük']] as [Sekme, string][])
            .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
        </div>

        {sekme === 'hak' && (
          <div className="md-iki">
            <div className="md-grp"><div className="md-gb">Sorgu (mustehaklikSorgu)</div>
              <div className="md-hdr k2">
                <div><label>TC Kimlik No</label><div className="md-inp">{h?.tckn || <span className="sonuk">hasta kartında TCKN yok</span>}</div></div>
                <div><label>Provizyon tipi</label><select value={provTipi} onChange={e => setProvTipi(Number(e.target.value))}>{PROV_TIPI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}</select></div>
                <div><label>Kayıtlı kurum</label><div className="md-inp">{h?.kurumAdi ? `${h.kurumAdi} (${['', 'özel', 'ÖSS', 'SGK', 'kurum'][h.kurumTur ?? 0]})` : <span className="sonuk">yok → ücretli</span>}</div></div>
                <div><label>Son sorgu</label><div className="md-inp">{sonMust?.mustehaklikZaman ? tarihSaat(sonMust.mustehaklikZaman) : '—'}</div></div>
              </div>
              <div className="md-arac"><button className="d bir" onClick={() => void mustehaklik()}>🔎 Sorgula</button><span className="sonuk">Simülasyon: müstehak = hastanın aktif SGK kurum kaydı (Hasta kartı › Kurumlar).</span></div>
            </div>
            <div className="md-grp"><div className="md-gb">Bu hastanın takipleri</div>
              <div className="md-dg"><table>
                <thead><tr><th>Başvuru</th><th>Tarih</th><th>Takip no</th><th>Hekim</th><th className="orta">Durum</th><th className="orta">Kabul/hata</th><th className="sag">Tutar</th><th /></tr></thead>
                <tbody>
                  {(ozet?.takipler ?? []).map(t => (
                    <tr key={t.belgeId} className={t.belgeId === belgeId ? 'sel' : ''} onClick={() => { setBelgeId(t.belgeId); setSekme('kabul'); }}>
                      <td>{t.belgeNo}</td><td>{gunNokta(t.belgeTarihi)}</td><td>{t.takipNo || '—'}</td><td>{t.hekim}</td>
                      <td className="orta"><Rozet d={t.sgkDurum} sozluk={MEDULA_TAKIP_DURUM} />{t.cikisZaman && t.sgkDurum === 1 ? <span className="rozet gri" style={{ marginLeft: 3 }}>çıkış</span> : ''}</td>
                      <td className="orta">{t.kabulIslem} / {t.hataliIslem}</td><td className="sag">{para.format(t.yerelTutar)}</td>
                      <td><button className="d" onClick={e => { e.stopPropagation(); git(`/medula-hizmet/${t.belgeId}`) }}>🧾</button></td>
                    </tr>
                  ))}
                  {ozet && ozet.takipler.length === 0 && <tr><td colSpan={8} className="sonuk">Başvuru yok - Kayıt Kabul'den başvuru açın; provizyon otomatik alınır (ayar).</td></tr>}
                </tbody>
              </table></div>
            </div>
          </div>
        )}

        {sekme === 'kabul' && (
          <div className="md-iki">
            <div className="md-grp"><div className="md-gb">Hasta kabul bilgileri (hastaKabul)</div>
              <div className="md-hdr k2">
                <div><label>Takip tipi</label><select value={takipTipi} onChange={e => setTakipTipi(Number(e.target.value))}>{TAKIP_TIPI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}</select></div>
                <div><label>Provizyon tipi</label><select value={provTipi} onChange={e => setProvTipi(Number(e.target.value))}>{PROV_TIPI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}</select></div>
                <div><label>Branş / bölüm</label><div className="md-inp">{secTakip?.bolum || <span className="sonuk">başvurudan</span>}</div></div>
                <div><label>Hekim (tescil)</label><div className="md-inp">{secTakip?.hekim || <span className="sonuk">başvurudan</span>}</div></div>
                <div><label>Sevkli mi</label><select value={sevkli ? 1 : 0} onChange={e => setSevkli(e.target.value === '1')}><option value={0}>Hayır</option><option value={1}>Evet</option></select></div>
                <div><label>Sevk eden kurum</label><input value={sevkKurum} onChange={e => setSevkKurum(e.target.value)} disabled={!sevkli} /></div>
              </div>
              <div className="md-arac">
                <button className="d onay" onClick={() => void hastaKabul()} disabled={!belgeId}>✔ Provizyon Al</button>
                <span className="sonuk">Takip no başvuruya yazılır (belge_provizyon.sgk_takip_no). Kapı kapalıysa kuyrukta bekler, hasta bekletilmez.</span>
              </div>
            </div>
            <div className="md-grp"><div className="md-gb">Kurallar</div>
              <ul className="md-liste">
                <li><span className="rozet gri">1006</span> Aynı gün aynı branşta açık takip → var olanı bağla</li>
                <li><span className="rozet gri">1013</span> Müstehak değil → ücretli / ÖSS</li>
                <li><span className="rozet gri">1020</span> Hekim tescil no eksik → Personel kartı</li>
                <li><span className="rozet gri">2001</span> Kapı erişilemiyor → kuyruk, otomatik tekrar</li>
              </ul>
            </div>
          </div>
        )}

        {sekme === 'ara' && (
          <div className="md-grp"><div className="md-gb">Takip ara (takipAra)</div>
            <div className="md-arac"><input placeholder="Hasta / takip no / başvuru no…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} onKeyDown={e => { if (e.key === 'Enter') void takipAra() }} /><button className="d bir" onClick={() => void takipAra()}>🔎 Ara</button></div>
            <div className="md-dg"><table>
              <thead><tr><th>Takip no</th><th>Hasta</th><th>Başvuru</th><th>Tarih</th><th>Hekim</th><th className="orta">Durum</th><th className="orta">İşlem</th><th className="sag">Tutar</th><th>Fatura</th><th /></tr></thead>
              <tbody>
                {araSonuc.map(r => (
                  <tr key={r.takip.belgeId}>
                    <td>{r.takip.takipNo || '—'}</td><td>{r.hasta}</td><td>{r.takip.belgeNo}</td><td>{gunNokta(r.takip.belgeTarihi)}</td><td>{r.takip.hekim}</td>
                    <td className="orta"><Rozet d={r.takip.sgkDurum} sozluk={MEDULA_TAKIP_DURUM} /></td>
                    <td className="orta">{r.takip.kabulIslem}</td><td className="sag">{para.format(r.takip.yerelTutar)}</td><td>{r.takip.medulaFaturaNo || '—'}</td>
                    <td><button className="d" onClick={() => { setHastaId(r.hastaId); setBelgeId(r.takip.belgeId); void yukle(r.hastaId); setSekme('kabul'); }}>📖 Seç</button></td>
                  </tr>
                ))}
                {araSonuc.length === 0 && <tr><td colSpan={10} className="sonuk">Sonuç yok.</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}

        {sekme === 'gunluk' && (
          <>
            <div className="md-grp"><div className="md-gb">Bu hastanın Medula günlüğü</div><Gunluk satirlar={gunluk} govdeAc={govdeAc} /></div>
            {govde && <div className="md-grp"><div className="md-gb">İstek / yanıt <span className="md-sp"><button className="d" onClick={() => setGovde(null)}>Kapat</button></span></div>
              <pre className="md-xml">{govde.istek}{'\n---\n'}{govde.yanit}</pre></div>}
          </>
        )}
      </div>
    </>
  );
}
