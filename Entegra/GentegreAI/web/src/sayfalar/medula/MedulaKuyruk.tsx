import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { MEDULA_HATA_ONERI, type MedulaKuyrukOzeti } from '../../api/uclar/medula';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { tarihSaat } from '../../bilesenler/bicim';
import { medulaSonucMetni } from '../liste/medulaAksiyonlari';
import { Gunluk, Sonuc } from './medulaOrtak';

/**
 * MEDULA — GÖNDERİM KUYRUĞU & AYARLAR — mockup `Ekranlar/Medula/medula_kuyruk.html`.
 * Her çağrı bir satır; bekleyen / hatalı / tamamlanan; servis özeti, hata
 * kodu dağılımı; hesap + davranış ayarları (referans).
 */
type Sekme = 'bekleyen' | 'hatali' | 'tamam' | 'ozet' | 'ayar';

export function MedulaKuyruk() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<Sekme>('bekleyen');
  const [v, setV] = useState<MedulaKuyrukOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [ara, setAra] = useState('');
  const [govde, setGovde] = useState<{ istek: string; yanit: string } | null>(null);
  const [sonuc, setSonuc] = useState<{ tur: 'ok' | 'kir' | 'sari'; metin: string } | null>(null);
  const [ayarTaslak, setAyarTaslak] = useState<Record<string, string>>({});

  const yukle = useCallback(async () => {
    try {
      const durum = sekme === 'bekleyen' ? 1 : sekme === 'hatali' ? 4 : sekme === 'tamam' ? 3 : undefined;
      const y = await api.medulaKuyruk(durum, ara);
      setV(y); setHata(null);
      setAyarTaslak(Object.fromEntries(y.ayarlar.map(a => [a.anahtar, a.deger])));
    } catch (h) { setHata(hataMetni(h)) }
  }, [sekme, ara]);
  useEffect(() => { void yukle() }, [yukle]);

  const gonder = async (hatalilarDa: boolean) => {
    await guvenli(async () => { const y = await api.medulaKuyrukGonder(hatalilarDa); setSonuc({ tur: y.hata ? 'sari' : 'ok', metin: y.aciklama }); await yukle(); });
  };
  const tekrar = async (id: number) => { await guvenli(async () => { setSonuc({ tur: 'ok', metin: medulaSonucMetni(await api.medulaKuyrukTekrar(id)) }); await yukle(); }) };
  const iptal = async (id: number) => { if (!await onay('Satır iptal edilsin mi?')) return; await guvenli(async () => { await api.medulaKuyrukIptal(id); await yukle(); }) };
  const govdeAc = async (id: number) => { await guvenli(async () => setGovde(await api.medulaKuyrukGovde(id))) };
  const test = async () => {
    await guvenli(async () => { const y = await api.medulaHesapTest(); setSonuc({ tur: y.acik ? 'ok' : 'kir', metin: `${y.acik ? '✔ Bağlantı açık' : '✖ Bağlantı yok'} · ${y.kod} ${y.mesaj} · ${y.sureMs} ms${y.simulasyon ? ' · simülasyon kapısı' : ''}` }); await yukle(); });
  };
  const ayarKaydet = async (anahtar: string) => {
    await guvenli(async () => { await api.ayarYaz(anahtar, ayarTaslak[anahtar] ?? ''); mesaj(`${anahtar} kaydedildi.`); await yukle(); });
  };

  const o = v?.ozet;
  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>📡 Medula — Gönderim Kuyruğu &amp; Ayarlar</h1>
          <span className="yol">Medula › Gönderim Kuyruğu</span>
          {v?.hesap ? <span className={`rozet ${v.hesap.testMi ? 'uyari' : 'ok'}`}>{v.hesap.testMi ? 'test / simülasyon' : 'canlı'} · tesis {v.hesap.tesisKodu || '—'}</span> : <span className="rozet hata">hesap tanımsız</span>}
        </div>
        <div className="basarac">
          <button className="d bir" onClick={() => void gonder(false)}>↻ Bekleyenleri Gönder</button>
          <button className="d" onClick={() => void gonder(true)}>🔁 Hatalıları Yeniden Dene</button>
          <button className="d" onClick={() => void test()}>🩺 Bağlantı Testi</button>
          <button className="d" onClick={() => git('/medula-kuyruk')}>🗂 Çağrı Günlüğü (liste)</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </div>
      </div>
      <div className="sahne md-sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="md-ozet">
          <div><span>Bugün çağrı</span><b>{o?.bugun ?? 0}</b><i>ort. {((o?.ortMs ?? 0) / 1000).toFixed(1)} sn</i></div>
          <div><span>Bekleyen</span><b>{o?.bekleyen ?? 0}</b><i>{o?.sonraki ? `sonraki ${tarihSaat(o.sonraki)}` : '—'}</i></div>
          <div className={o?.hata || o?.elle ? 'kir' : ''}><span>Hatalı</span><b>{(o?.hata ?? 0) + (o?.elle ?? 0)}</b><i>{o?.elle ?? 0} elle müdahale</i></div>
          <div className="ok"><span>Kabul (bugün)</span><b>{o?.bugun ? Math.round(100 * (o.bugunKabul / o.bugun)) : 0}%</b><i>{o?.bugunKabul ?? 0} / {o?.bugun ?? 0}</i></div>
          <div><span>Bağlantı</span><b>{v?.hesap?.sonSonuc || '—'}</b><i>{v?.hesap?.sonKullanim ? tarihSaat(v.hesap.sonKullanim) : ''}</i></div>
          <div><span>Kapı</span><b>{ayarTaslak['medula.kapi_kapali'] === '1' ? <span className="rozet hata">Kapalı (simülasyon)</span> : <span className="rozet ok">Açık</span>}</b></div>
        </div>
        {sonuc && <Sonuc tur={sonuc.tur}>{sonuc.metin}</Sonuc>}

        <div className="ka-sekmeler">
          {([['bekleyen', 'Bekleyen'], ['hatali', 'Hatalı'], ['tamam', 'Tamamlanan'], ['ozet', 'Günlük Özet'], ['ayar', 'Ayarlar & Hesap']] as [Sekme, string][])
            .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
        </div>

        {(sekme === 'bekleyen' || sekme === 'hatali' || sekme === 'tamam') && (
          <div className="md-grp">
            <div className="md-arac"><input placeholder="Hasta / işlem / hata kodu…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
              {sekme === 'hatali' && <span className="sonuk">3 denemeden sonra "elle müdahale"; öneri sütunu kök nedene götürür.</span>}</div>
            <Gunluk satirlar={v?.satirlar ?? []} govdeAc={govdeAc} tekrar={tekrar} />
            {sekme !== 'tamam' && (v?.satirlar.length ?? 0) > 0 && (
              <div className="md-arac"><span className="sonuk">İptal: satırı seçmek yerine numarasını yazın →</span>
                <input placeholder="kuyruk id" id="md-iptal-id" style={{ width: 90 }} />
                <button className="d" onClick={() => { const el = document.getElementById('md-iptal-id') as HTMLInputElement; const id = Number(el?.value); if (id) void iptal(id); }}>✖ İptal et</button>
              </div>
            )}
            {govde && <div className="md-grp" style={{ margin: 8 }}><div className="md-gb">İstek / yanıt <span className="md-sp"><button className="d" onClick={() => setGovde(null)}>Kapat</button></span></div><pre className="md-xml">{govde.istek}{'\n---\n'}{govde.yanit}</pre></div>}
          </div>
        )}

        {sekme === 'ozet' && (
          <div className="md-iki">
            <div className="md-grp"><div className="md-gb">Servis bazında (bugün)</div>
              <div className="md-dg"><table>
                <thead><tr><th>İşlem</th><th className="sag">Çağrı</th><th className="sag">Kabul</th><th className="sag">Hata</th><th className="sag">Ort. süre</th><th>Oran</th></tr></thead>
                <tbody>
                  {(v?.servisler ?? []).map(s => <tr key={s.islem}><td>{s.islem}</td><td className="sag">{s.cagri}</td><td className="sag">{s.kabul}</td><td className="sag">{s.hata}</td><td className="sag">{(s.ortMs / 1000).toFixed(1)} sn</td>
                    <td><div className="md-bar"><i style={{ width: `${s.cagri ? Math.round(100 * s.kabul / s.cagri) : 0}%` }} /></div></td></tr>)}
                  {(v?.servisler ?? []).length === 0 && <tr><td colSpan={6} className="sonuk">Bugün çağrı yok.</td></tr>}
                </tbody>
              </table></div>
            </div>
            <div className="md-grp"><div className="md-gb">Hata kodu dağılımı (bu ay)</div>
              <div className="md-dg"><table>
                <thead><tr><th>Kod</th><th>Mesaj</th><th className="sag">Adet</th><th>Kök neden / öneri</th></tr></thead>
                <tbody>
                  {(v?.hataKodlari ?? []).map(h => <tr key={h.kod}><td>{h.kod}</td><td>{h.mesaj}</td><td className="sag">{h.adet}</td><td className="sonuk">{MEDULA_HATA_ONERI[h.kod] ?? ''}</td></tr>)}
                  {(v?.hataKodlari ?? []).length === 0 && <tr><td colSpan={4} className="sonuk">Hata yok.</td></tr>}
                </tbody>
              </table></div>
            </div>
          </div>
        )}

        {sekme === 'ayar' && (
          <div className="md-iki">
            <div className="md-grp"><div className="md-gb">Entegrasyon hesabı <span className="md-sp sonuk">entegrasyon_hesap · kod MEDULA</span></div>
              {v?.hesap ? (
                <div className="md-hdr k2">
                  <div><label>Tesis kodu</label><div className="md-inp">{v.hesap.tesisKodu || '—'}</div></div>
                  <div><label>Kullanıcı adı</label><div className="md-inp">{v.hesap.kullaniciAdi || '—'}</div></div>
                  <div><label>Canlı URL</label><div className="md-inp">{v.hesap.url || '—'}</div></div>
                  <div><label>Test URL</label><div className="md-inp">{v.hesap.testUrl || '—'}</div></div>
                  <div><label>Ortam</label><div className="md-inp">{v.hesap.testMi ? 'Test (simülasyon kapısı)' : 'Canlı (SOAP kapısı bu sürümde bağlı değil)'}</div></div>
                  <div><label>Son kullanım</label><div className="md-inp">{v.hesap.sonKullanim ? tarihSaat(v.hesap.sonKullanim) : '—'} · {v.hesap.sonSonuc}</div></div>
                </div>
              ) : <div className="md-ic sonuk">MEDULA hesabı tanımlı değil. Yönetim › Entegrasyonlar'dan tesis kodu / kullanıcı girin; simülasyon kapısı hesapsız da çalışır (tesis "TEST").</div>}
              <div className="md-arac"><button className="d" onClick={() => void test()}>🩺 Bağlantı testi</button><button className="d" onClick={() => git('/entegrasyon-hesap')}>⚙ Hesabı düzenle</button></div>
            </div>
            <div className="md-grp"><div className="md-gb">Davranış ayarları <span className="md-sp sonuk">referans · medula.*</span></div>
              <div className="md-dg"><table>
                <thead><tr><th>Ayar</th><th>Değer</th><th>Açıklama</th><th /></tr></thead>
                <tbody>
                  {(v?.ayarlar ?? []).map(a => (
                    <tr key={a.anahtar}>
                      <td><code>{a.anahtar}</code></td>
                      <td>{a.tip === 'mantik'
                        ? <select value={ayarTaslak[a.anahtar] ?? a.deger} onChange={e => setAyarTaslak(t => ({ ...t, [a.anahtar]: e.target.value }))} disabled={!yetki('medula.ayar')}><option value="1">Evet</option><option value="0">Hayır</option></select>
                        : <input value={ayarTaslak[a.anahtar] ?? a.deger} onChange={e => setAyarTaslak(t => ({ ...t, [a.anahtar]: e.target.value }))} disabled={!yetki('medula.ayar')} style={{ width: 120 }} />}</td>
                      <td className="sonuk">{a.aciklama}</td>
                      <td>{yetki('medula.ayar') && (ayarTaslak[a.anahtar] ?? a.deger) !== a.deger && <button className="d onay" onClick={() => void ayarKaydet(a.anahtar)}>💾</button>}</td>
                    </tr>
                  ))}
                </tbody>
              </table></div>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
