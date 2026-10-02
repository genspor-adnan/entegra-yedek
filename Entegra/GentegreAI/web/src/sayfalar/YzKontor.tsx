import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { AiKontorHareket, AiKontorOzet, AiPlan, AiAbonelik } from '../api/uclar/yapayZeka';
import { Modal } from '../bilesenler/Modal';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { useOturum } from '../kimlik/OturumBaglami';
import { c } from '../dil/ceviri';

/**
 * YZ KONTÖR & KULLANIM (934) — mockup `Ekranlar/Ayarlar/yz_kontor_kullanim.html`.
 *
 * Göstergeler · Özet (30 günlük kullanım, özelliğe göre kontör) · Hareketler ·
 * Kullanıcıya göre · Plan & Faturalar · Ayarlar · Gizlilik.
 *
 * KONTÖR SATIN ALMA (kullanıcı: "KK girip benden kontör alabilecek müşteri",
 * "3 değişik plan"): sipariş SUNUCUDA fiyatlanır, ödeme kuruluşunun formunda
 * ödenir; kart verisi bu uygulamaya hiç girmez, kontörü yalnız ödeme
 * kuruluşunun bildirimi yükler.
 *
 * iyzico (Ödeme Formu): 3. adımda "iyzico ile öde" iyzico'nun sayfasına gider;
 * iyzico tarayıcıyı API'nin dönüş ucuna, API sonucu iyzico'ya sorup kontörü
 * yükledikten sonra buraya `?siparis=ID` ile döndürür - sonuç penceresi açılır.
 * Simülasyonda kart alanı yok, sonuç düğmeyle seçilir.
 */

const OZELLIK: Record<string, { ad: string; ik: string; sinif: string }> = {
  tani: { ad: 'Tanı önerisi', ik: '🩺', sinif: 'yk-s-tani' },
  tetkik: { ad: 'Tetkik önerisi', ik: '🔬', sinif: 'yk-s-tetkik' },
  ilac: { ad: 'İlaç önerisi', ik: '💊', sinif: 'yk-s-ilac' },
  rehber: { ad: 'YZ Rehber', ik: '❓', sinif: 'yk-s-rehber' },
};
const OZ_SIRA = ['tani', 'tetkik', 'ilac', 'rehber'];
const SEKMELER = ['Özet', 'Hareketler', 'Kullanıcıya Göre', 'Plan & Faturalar', 'Ayarlar', 'Gizlilik & Denetim'] as const;
type Sekme = typeof SEKMELER[number];

const sayi = (n: number, basamak = 0) => n.toLocaleString('tr-TR', { minimumFractionDigits: basamak, maximumFractionDigits: basamak });
const tl = (n: number) => `${sayi(n, 2)} ₺`;
const tarih = (s: string | null | undefined, saat = true) => {
  if (!s) return '—';
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? s : d.toLocaleString('tr-TR', saat
    ? { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }
    : { day: '2-digit', month: '2-digit', year: 'numeric' });
};

export function YzKontor() {
  const { aksiyonVar, yetki } = useOturum();
  const satinAlabilir = aksiyonVar('ai.kontor_satin_al');
  const ayarDegistirir = yetki('ai.kontor', 'degistir');
  const [ozet, setOzet] = useState<AiKontorOzet | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('Özet');
  const [satinAl, setSatinAl] = useState<null | 'plan' | 'paket'>(null);
  /** iyzico dönüşü: `?siparis=ID` ile gelinirse sonucu göster, adresi temizle. */
  const [donus, setDonus] = useState<null | { id: number; durum: number; kontor: number; yeniBakiye: number;
                                             faturaNo: string; hata: string }>(null);
  useEffect(() => {
    const q = new URLSearchParams(window.location.search);
    const id = Number(q.get('siparis'));
    if (!q.has('siparis')) return;
    window.history.replaceState(null, '', window.location.pathname);
    if (!(id > 0)) { setDonus({ id: 0, durum: 3, kontor: 0, yeniBakiye: 0, faturaNo: '', hata: 'Ödeme dönüşü bir siparişle eşleşmedi.' }); return }
    void api.aiKontorSiparisDurum(id).then(y => setDonus({ id, ...y })).catch(h => setHata(hataMetni(h)));
  }, []);

  const yukle = useCallback(async () => {
    try { setOzet(await api.aiKontorOzet()); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const k = ozet?.kontor;
  const ab = ozet?.abonelik;
  const aktifPlan = ab && ab.durum > 0 && ab.planAd ? ab : null;
  const sureOrt = useMemo(() => {
    const l = ozet?.sureler ?? [];
    if (l.length === 0) return null;
    return l.reduce((t, x) => t + x.ortalamaMs, 0) / l.length / 1000;
  }, [ozet]);
  const artis = k && k.gecenAy > 0 ? Math.round((k.buAy - k.gecenAy) / k.gecenAy * 100) : null;

  return (
    <div className="yk">
      <div className="sayfabas">
        <div className="basrow">
          <h1>🤖 {c('YZ Kontör & Kullanım')}</h1>
          <span className="yol">{c('Ayarlar › Yapay Zekâ › Kontör & Kullanım')}</span>
          <div className="sag">
            <div className="arac-cubugu">
              {satinAlabilir && (
                <button type="button" className="d bir" onClick={() => setSatinAl('plan')}><span>💳 {c('Kontör Satın Al')}</span></button>
              )}
              <button type="button" className="d" onClick={() => setSekme('Plan & Faturalar')}><span>📦 {c('Planım')}</span></button>
              <button type="button" className="d" onClick={() => void yukle()}><span>⟳ {c('Yenile')}</span></button>
            </div>
          </div>
        </div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {ozet && k && (
        <>
          <div className="yk-rozetler">
            <span className="rozet mavi">{c('Sağlayıcı')}: {ozet.saglayici.adres || ozet.saglayici.tur} · {ozet.saglayici.model}</span>
            {ozet.saglayici.test && <span className="rozet uyari">{c('TEST ortamı')}</span>}
            <span className="rozet olumlu">🔒 {c('Anonimleştirme açık')}</span>
            <span className={`rozet ${k.modelAktif && ozet.saglayici.hazir ? 'olumlu' : 'hata'}`}>
              ● {k.modelAktif && ozet.saglayici.hazir ? c('Model aktif') : !ozet.saglayici.hazir ? c('Model yapılandırılmamış') : c('Model kapalı')}
            </span>
          </div>

          <div className="yk-kpi">
            <div className={`yk-k yk-bakiye${k.bakiye < k.uyariEsigi ? ' az' : ''}`}>
              <div className="e">{c('Kontör bakiyesi')}</div>
              <div className="d">{sayi(k.bakiye)} <small>{c('kontör')}</small></div>
              <div className="yk-bar"><i style={{ width: `${Math.min(100, aktifPlan ? k.bakiye / Math.max(1, aktifPlan.aylikKontor) * 100 : k.bakiye)}%` }} /></div>
              <div className="a">
                {aktifPlan
                  ? <>{c('Plan')}: <b>{aktifPlan.planAd}</b>{aktifPlan.sonrakiYenileme ? ` · ${tarih(aktifPlan.sonrakiYenileme, false)} ${c('yenilenir')}` : ''}</>
                  : c('Plan yok')}
                {' · '}≈ {sayi(Math.floor(k.bakiye / Math.max(0.01, k.cagriUcreti)))} {c('öneri hakkı')}
              </div>
            </div>
            <div className="yk-k">
              <div className="e">{c('Bugün')}</div>
              <div className="d">{sayi(k.bugunCagri)} <small>/ {k.gunlukSinir > 0 ? sayi(k.gunlukSinir) : '∞'} {c('çağrı')}</small></div>
              <div className="yk-bar"><i style={{ width: `${k.gunlukSinir > 0 ? Math.min(100, k.bugunCagri / k.gunlukSinir * 100) : 0}%` }} /></div>
              <div className="a">{c('Harcanan')}: {sayi(k.bugunKontor)} {c('kontör')}</div>
            </div>
            <div className="yk-k">
              <div className="e">{c('Bu ay harcanan')}</div>
              <div className="d">{sayi(k.buAy)} <small>{c('kontör')}</small></div>
              <div className="a">{c('Geçen ay')} {sayi(k.gecenAy)}{artis !== null && <> · <span className={artis >= 0 ? 'yk-art' : 'yk-eksi'}>{artis >= 0 ? '▲' : '▼'} %{Math.abs(artis)}</span></>}</div>
            </div>
            <div className="yk-k">
              <div className="e">{c('Ortalama yanıt')}</div>
              <div className="d">{sureOrt === null ? '—' : sayi(sureOrt, 1)} <small>{c('sn')}</small></div>
              <div className="a">{(ozet.sureler).map(x => `${OZELLIK[x.ozellik]?.ad.split(' ')[0] ?? x.ozellik} ${sayi(x.ortalamaMs / 1000, 1)}`).join(' · ') || c('Bu ay çağrı yok')}</div>
            </div>
            <div className="yk-k">
              <div className="e">{c('Başarısız çağrı')}</div>
              <div className="d">{sayi(k.basarisizAy)} <small>{c('bu ay')}</small></div>
              <div className="a">{c('Ücretlendirilmedi')}</div>
            </div>
          </div>

          <div className="katab">
            {SEKMELER.map(s => (
              <div key={s} role="tab" aria-selected={sekme === s} className={`kat${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{c(s)}</div>
            ))}
          </div>

          <div className="yk-govde">
            {sekme === 'Özet' && <OzetSekmesi ozet={ozet} />}
            {sekme === 'Hareketler' && <HareketSekmesi />}
            {sekme === 'Kullanıcıya Göre' && <KullaniciSekmesi />}
            {sekme === 'Plan & Faturalar' && (
              <PlanSekmesi abonelik={ab ?? null} satinAlabilir={satinAlabilir}
                           onSatinAl={t => setSatinAl(t)} onDegisti={() => void yukle()} />
            )}
            {sekme === 'Ayarlar' && <AyarSekmesi ozet={ozet} degistirir={ayarDegistirir} onKaydedildi={() => void yukle()} />}
            {sekme === 'Gizlilik & Denetim' && <GizlilikSekmesi />}
          </div>
        </>
      )}

      {donus && (
        <Modal baslik={`💳 ${c('Ödeme sonucu')}`} ekSinif="yk-satin" buyutmeYok onKapat={() => setDonus(null)}
               alt={<button type="button" className="d bir" onClick={() => setDonus(null)}>{c('Tamam')}</button>}>
          <div className="yk-sonuc">
            {donus.durum === 2 ? (
              <>
                <div className="ik">✅</div>
                <div className="bas ok">{c('Ödeme alındı — kontör yüklendi')}</div>
                <div>{sayi(donus.kontor)} {c('kontör')} · {c('Yeni bakiye')}: <b>{sayi(donus.yeniBakiye)}</b></div>
                <div className="sonuk">{c('Fatura no')}: {donus.faturaNo}</div>
              </>
            ) : donus.durum === 1 ? (
              <>
                <div className="ik">⏳</div>
                <div className="bas">{c('Ödeme henüz sonuçlanmadı')}</div>
                <div className="sonuk">{c('iyzico sonucu bildirince kontör yüklenir; birkaç dakika sonra ekranı yenileyin.')}</div>
              </>
            ) : (
              <>
                <div className="ik">⛔</div>
                <div className="bas hata">{c('Ödeme alınamadı')}</div>
                <div>{donus.hata || c('Ödeme tamamlanmadı.')}</div>
                <div className="sonuk">{c('Kontör yüklenmedi; tekrar deneyebilirsiniz.')}</div>
              </>
            )}
          </div>
        </Modal>
      )}

      {satinAl && (
        <SatinAlPenceresi baslangic={satinAl} bakiye={k?.bakiye ?? 0}
          onKapat={() => setSatinAl(null)} onTamam={() => void yukle()} />
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ Özet */
function OzetSekmesi({ ozet }: { ozet: AiKontorOzet }) {
  const gunler = useMemo(() => {
    const m = new Map<string, Record<string, number>>();
    for (const r of ozet.seri) {
      const g = m.get(r.gun) ?? {};
      if (r.ozellik) g[r.ozellik] = (g[r.ozellik] ?? 0) + r.adet;
      m.set(r.gun, g);
    }
    return [...m.entries()];
  }, [ozet.seri]);
  const enCok = Math.max(1, ...gunler.map(([, g]) => Object.values(g).reduce((a, b) => a + b, 0)));
  const topKontor = Math.max(1, ...ozet.dagilim.map(d => d.kontor));
  const k = ozet.kontor;
  return (
    <>
      <div className="yk-iki">
        <div className="kagrup">
          <h6>{c('Son 30 gün — günlük çağrı (özelliğe göre)')}</h6>
          <div className="yk-grafik" role="img" aria-label={c('Son 30 günlük YZ kullanımı')}>
            {gunler.map(([gun, g]) => (
              <div key={gun} className="yk-g" title={`${tarih(gun, false)} · ${OZ_SIRA.map(o => `${OZELLIK[o].ad} ${g[o] ?? 0}`).join(' · ')}`}>
                {OZ_SIRA.map(o => (g[o] ?? 0) > 0 && (
                  <span key={o} className={OZELLIK[o].sinif} style={{ height: `${(g[o] ?? 0) / enCok * 130}px` }} />
                ))}
              </div>
            ))}
          </div>
          <div className="yk-eks"><span>{tarih(gunler[0]?.[0], false)}</span><span>{tarih(gunler[gunler.length - 1]?.[0], false)}</span></div>
          <div className="yk-lej">{OZ_SIRA.map(o => <span key={o}><i className={OZELLIK[o].sinif} />{c(OZELLIK[o].ad)}</span>)}</div>
        </div>
        <div className="kagrup">
          <h6>{c('Bu ay — özelliğe göre kontör')}</h6>
          <div className="yk-dagilim">
            {OZ_SIRA.map(o => {
              const d = ozet.dagilim.find(x => x.ozellik === o);
              return (
                <div key={o} className="yk-satir">
                  <span>{OZELLIK[o].ik} {c(OZELLIK[o].ad)}</span>
                  <div className="yk-cubuk"><i className={OZELLIK[o].sinif} style={{ width: `${(d?.kontor ?? 0) / topKontor * 100}%` }} /></div>
                  <b>{sayi(d?.kontor ?? 0)}</b>
                </div>
              );
            })}
          </div>
        </div>
      </div>
      <div className="rk-bant sari yk-bant">
        ⚠ {c('Bakiye uyarı eşiğinin')} (<b>{sayi(k.uyariEsigi)}</b>) {c('altına düşünce yöneticiler uyarılır; bakiye bitince YZ önerileri kapanır, rehber katalog cevabıyla çalışmaya devam eder. Başarısız çağrıdan kontör düşülmez.')}
      </div>
    </>
  );
}

/* ------------------------------------------------------------- Hareketler */
function HareketSekmesi() {
  const [tur, setTur] = useState<number | undefined>();
  const [oz, setOz] = useState('');
  const [gun, setGun] = useState(30);
  const [satirlar, setSatirlar] = useState<AiKontorHareket[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    let iptal = false;
    void api.aiKontorHareketler({ tur, ozellik: oz, gun })
      .then(y => { if (!iptal) { setSatirlar(y.satirlar); setHata(null) } })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [tur, oz, gun]);
  const turAd = (h: AiKontorHareket) => !h.basarili ? ['gri', 'Başarısız']
    : h.tur === 1 ? ['olumlu', 'Yükleme'] : h.tur === 2 ? ['hata', 'Harcama'] : h.tur === 3 ? ['mavi', 'Düzeltme'] : ['mavi', 'İade'];
  return (
    <>
      <div className="cipler yk-suz">
        {([[undefined, 'Tümü'], [1, 'Yükleme'], [2, 'Harcama'], [3, 'Düzeltme']] as const).map(([v, a]) => (
          <button key={a} type="button" className={`cip${tur === v ? ' on' : ''}`} onClick={() => setTur(v)}>{c(a)}</button>
        ))}
        <span className="yk-ayrac" />
        {OZ_SIRA.map(o => (
          <button key={o} type="button" className={`cip${oz === o ? ' on' : ''}`} onClick={() => setOz(oz === o ? '' : o)}>
            {OZELLIK[o].ik} {c(OZELLIK[o].ad.split(' ')[0])}</button>
        ))}
        <span className="yk-ayrac" />
        {[1, 7, 30, 365].map(g => (
          <button key={g} type="button" className={`cip${gun === g ? ' on' : ''}`} onClick={() => setGun(g)}>
            {g === 1 ? c('Bugün') : g === 365 ? c('1 yıl') : `${g} ${c('gün')}`}</button>
        ))}
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!satirlar ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <table className="detay-tablo yk-tablo">
          <thead><tr>
            <th>{c('Tarih')}</th><th>{c('Tür')}</th><th>{c('Özellik')}</th><th>{c('Muayene')}</th><th>{c('Kullanıcı')}</th>
            <th className="hiza-sag">{c('Jeton')}</th><th className="hiza-sag">{c('Süre')}</th>
            <th className="hiza-sag">{c('Miktar')}</th><th className="hiza-sag">{c('Bakiye')}</th><th>{c('Açıklama')}</th>
          </tr></thead>
          <tbody>
            {satirlar.length === 0 && <tr><td colSpan={10} className="bos">{c('Hareket yok.')}</td></tr>}
            {satirlar.map(h => {
              const [sinif, ad] = turAd(h);
              return (
                <tr key={h.id}>
                  <td>{tarih(h.tarih)}</td>
                  <td><span className={`rozet ${sinif}`}>{c(ad)}</span></td>
                  <td>{h.ozellik ? `${OZELLIK[h.ozellik]?.ik ?? ''} ${c(OZELLIK[h.ozellik]?.ad.split(' ')[0] ?? h.ozellik)}` : '—'}</td>
                  <td>{h.muayeneId ? `#${h.muayeneId}` : '—'}</td>
                  <td>{h.kullanici || '—'}</td>
                  <td className="hiza-sag">{h.jeton ? sayi(h.jeton) : '—'}</td>
                  <td className="hiza-sag">{h.sureMs != null ? `${sayi(h.sureMs / 1000, 1)} sn` : '—'}</td>
                  <td className={`hiza-sag ${h.tur === 1 ? 'yk-art' : h.miktar > 0 ? 'yk-eksi' : 'sonuk'}`}>
                    {h.tur === 1 ? '+' : h.miktar > 0 ? '−' : ''}{sayi(h.miktar)}</td>
                  <td className="hiza-sag">{sayi(h.bakiye)}</td>
                  <td>{h.aciklama}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
      <p className="not">{c('Modele giden metin burada saklanmaz; yalnız sayılar. Başarısız çağrı ücretlendirilmez ama kayda girer.')}</p>
    </>
  );
}

/* ---------------------------------------------------------- Kullanıcılar */
function KullaniciSekmesi() {
  const [gun, setGun] = useState(30);
  const [satirlar, setSatirlar] = useState<Awaited<ReturnType<typeof api.aiKontorKullanicilar>>['satirlar'] | null>(null);
  useEffect(() => { void api.aiKontorKullanicilar(gun).then(y => setSatirlar(y.satirlar)).catch(() => setSatirlar([])) }, [gun]);
  return (
    <>
      <div className="cipler yk-suz">
        {[[30, 'Bu ay (30 gün)'], [7, 'Son 7 gün'], [1, 'Bugün']].map(([g, a]) => (
          <button key={g} type="button" className={`cip${gun === g ? ' on' : ''}`} onClick={() => setGun(Number(g))}>{c(String(a))}</button>
        ))}
      </div>
      {!satirlar ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <table className="detay-tablo yk-tablo">
          <thead><tr>
            <th>{c('Kullanıcı')}</th>
            {OZ_SIRA.map(o => <th key={o} className="hiza-orta">{OZELLIK[o].ik} {c(OZELLIK[o].ad.split(' ')[0])}</th>)}
            <th className="hiza-sag">{c('Kontör')}</th><th>{c('Son kullanım')}</th>
          </tr></thead>
          <tbody>
            {satirlar.length === 0 && <tr><td colSpan={7} className="bos">{c('Bu dönemde kullanım yok.')}</td></tr>}
            {satirlar.map(r => (
              <tr key={r.kullanici}>
                <td>{r.kullanici}</td>
                <td className="hiza-orta">{r.tani || '—'}</td><td className="hiza-orta">{r.tetkik || '—'}</td>
                <td className="hiza-orta">{r.ilac || '—'}</td><td className="hiza-orta">{r.rehber || '—'}</td>
                <td className="hiza-sag"><b>{sayi(r.kontor)}</b></td><td>{tarih(r.son)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  );
}

/* ------------------------------------------------------ Plan & Faturalar */
function PlanSekmesi({ abonelik, satinAlabilir, onSatinAl, onDegisti }: {
  abonelik: AiAbonelik | null; satinAlabilir: boolean;
  onSatinAl(t: 'plan' | 'paket'): void; onDegisti(): void;
}) {
  const [siparisler, setSiparisler] = useState<Awaited<ReturnType<typeof api.aiKontorSiparisler>>['satirlar'] | null>(null);
  useEffect(() => { void api.aiKontorSiparisler().then(y => setSiparisler(y.satirlar)).catch(() => setSiparisler([])) }, []);
  const a = abonelik && abonelik.durum > 0 && abonelik.planAd ? abonelik : null;
  const durum = (d: number) => d === 2 ? ['olumlu', 'Ödendi'] : d === 3 ? ['hata', 'Reddedildi'] : d === 4 ? ['gri', 'İptal'] : ['uyari', 'Ödeme bekliyor'];
  return (
    <div className="yk-iki">
      <div className="kagrup">
        <h6>{c('Mevcut plan')}</h6>
        {!a ? <p className="not">{c('Aktif plan yok. Kontör satın almak için bir plan ya da ek paket seçin.')}</p> : (
          <div className="yk-form">
            <div className="rk-fld"><label>{c('Plan')}</label><div className="ak-salt"><b>{a.planAd}</b> <span className="rozet mavi">{a.donemAy === 12 ? c('Yıllık') : c('Aylık')}</span>
              {a.durum === 2 && <span className="rozet uyari">{c('İptal edildi')}</span>}</div></div>
            <div className="rk-fld"><label>{c('Kontör')}</label><div className="ak-salt">{sayi(a.aylikKontor)} / {c('ay')}</div></div>
            <div className="rk-fld"><label>{c('Tutar')}</label><div className="ak-salt">{tl(a.tutar)} + KDV / {a.donemAy === 12 ? c('yıl') : c('ay')}</div></div>
            <div className="rk-fld"><label>{c('Dönem')}</label><div className="ak-salt">{tarih(a.donemBaslangic, false)} – {tarih(a.sonrakiYenileme, false)}</div></div>
            <div className="rk-fld"><label>{c('Sonraki yenileme')}</label><div className="ak-salt">{a.durum === 1 ? tarih(a.sonrakiYenileme, false) : '—'}</div></div>
            <div className="rk-fld"><label>{c('Kayıtlı kart')}</label><div className="ak-salt">{a.kartSon4 ? `${a.kartMarka} •••• ${a.kartSon4}` : '—'} <span className="sonuk">({c('ödeme kuruluşunda')})</span></div></div>
            <div className="rk-fld"><label>{c('Devreden kontör')}</label><div className="ak-salt">{a.devreder ? c('Kullanılmayan kontör 1 dönem devreder') : c('Devretmez')}</div></div>
          </div>
        )}
        {satinAlabilir && (
          <div className="yk-dugmeler">
            <button type="button" className="d bir" onClick={() => onSatinAl('plan')}>⬆ {a ? c('Planı Değiştir') : c('Plan Seç')}</button>
            <button type="button" className="d" onClick={() => onSatinAl('paket')}>＋ {c('Ek Paket Al')}</button>
            <span style={{ marginLeft: 'auto' }} />
            {a?.durum === 1 && (
              <button type="button" className="d teh" onClick={() => void guvenli(async () => {
                if (!await onay('Abonelik iptal edilecek; dönem sonuna kadar kontör kullanılabilir. Onaylıyor musunuz?')) return;
                const y = await api.aiAbonelikIptal(); mesaj(y.mesaj); onDegisti();
              })}>{c('Aboneliği İptal Et')}</button>
            )}
          </div>
        )}
      </div>
      <div className="kagrup">
        <h6>{c('Faturalar & ödemeler')}</h6>
        {!siparisler ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
          <table className="detay-tablo yk-tablo">
            <thead><tr><th>{c('Tarih')}</th><th>{c('Açıklama')}</th><th className="hiza-sag">{c('Kontör')}</th>
              <th className="hiza-sag">{c('Tutar')}</th><th>{c('Durum')}</th><th>{c('Fatura')}</th></tr></thead>
            <tbody>
              {siparisler.length === 0 && <tr><td colSpan={6} className="bos">{c('Henüz satın alma yok.')}</td></tr>}
              {siparisler.map(s => {
                const [sinif, ad] = durum(s.durum);
                return (
                  <tr key={s.id}>
                    <td>{tarih(s.tarih)}</td><td>{s.aciklama}</td><td className="hiza-sag">{sayi(s.kontor)}</td>
                    <td className="hiza-sag">{tl(s.toplam)}</td>
                    <td><span className={`rozet ${sinif}`} title={s.hata}>{c(ad)}</span></td>
                    <td>{s.faturaNo || '—'}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

/* ---------------------------------------------------------------- Ayarlar */
function AyarSekmesi({ ozet, degistirir, onKaydedildi }: { ozet: AiKontorOzet; degistirir: boolean; onKaydedildi(): void }) {
  const k = ozet.kontor;
  const [d, setD] = useState({
    gunlukSinir: k.gunlukSinir, kullaniciGunlukSinir: k.kullaniciGunlukSinir, uyariEsigi: k.uyariEsigi,
    modelAktif: k.modelAktif, ozRehber: k.ozRehber, ozTani: k.ozTani, ozTetkik: k.ozTetkik, ozIlac: k.ozIlac,
    otomatikEkPaket: k.otomatikEkPaket,
  });
  const [paketler, setPaketler] = useState<{ kod: string; kontor: number }[]>([]);
  useEffect(() => { void api.aiKontorPlanlar().then(y => setPaketler(y.paketler)).catch(() => {}) }, []);
  const yaz = <K extends keyof typeof d>(a: K, v: (typeof d)[K]) => setD(o => ({ ...o, [a]: v }));
  const ozSatir = (anahtar: 'ozTani' | 'ozTetkik' | 'ozIlac' | 'ozRehber', oz: string, nerede: string) => (
    <tr key={oz}>
      <td>{OZELLIK[oz].ik} {c(OZELLIK[oz].ad)}</td><td className="sonuk">{c(nerede)}</td>
      <td className="hiza-orta"><input type="checkbox" aria-label={OZELLIK[oz].ad} checked={d[anahtar]} disabled={!degistirir}
        onChange={e => yaz(anahtar, e.target.checked)} /></td>
      <td className="hiza-sag">{sayi(k.cagriUcreti)}</td>
    </tr>
  );
  return (
    <>
      <fieldset className="yk-fs" disabled={!degistirir}>
        <div className="kagrup">
          <h6>{c('Kontör kuralları')}</h6>
          <div className="yk-form">
            <div className="rk-fld"><label>{c('Çağrı ücreti (kontör)')}</label><div className="ak-salt">{sayi(k.cagriUcreti)} <span className="sonuk">({c('satıcı belirler')})</span></div></div>
            <div className="rk-fld"><label htmlFor="yk-gs">{c('Günlük çağrı sınırı (kurum)')}</label>
              <input id="yk-gs" type="number" min={0} value={d.gunlukSinir} onChange={e => yaz('gunlukSinir', Number(e.target.value))} /></div>
            <div className="rk-fld"><label htmlFor="yk-ks">{c('Kullanıcı başına günlük sınır')}</label>
              <input id="yk-ks" type="number" min={0} value={d.kullaniciGunlukSinir} onChange={e => yaz('kullaniciGunlukSinir', Number(e.target.value))} />
              <small className="sonuk">0 = {c('sınırsız')}</small></div>
            <div className="rk-fld"><label htmlFor="yk-ue">{c('Uyarı eşiği')}</label>
              <input id="yk-ue" type="number" min={0} value={d.uyariEsigi} onChange={e => yaz('uyariEsigi', Number(e.target.value))} /></div>
            <div className="rk-fld"><label htmlFor="yk-oe">{c('Otomatik ek paket')}</label>
              <select id="yk-oe" value={d.otomatikEkPaket} onChange={e => yaz('otomatikEkPaket', e.target.value)}>
                <option value="">{c('Kapalı')}</option>
                {paketler.map(p => <option key={p.kod} value={p.kod}>{sayi(p.kontor)} {c('kontör (eşiğin altına düşünce)')}</option>)}
              </select></div>
            <label className="ak-kutu"><input type="checkbox" checked={d.modelAktif} onChange={e => yaz('modelAktif', e.target.checked)} /> {c('YZ modeli aktif')}</label>
          </div>
        </div>
        <div className="yk-iki">
          <div className="kagrup">
            <h6>{c('Özellikler — aç / kapa')}</h6>
            <table className="detay-tablo yk-tablo">
              <thead><tr><th>{c('Özellik')}</th><th>{c('Nerede')}</th><th className="hiza-orta">{c('Açık')}</th><th className="hiza-sag">{c('Ücret')}</th></tr></thead>
              <tbody>
                {ozSatir('ozTani', 'tani', 'ICD tanı arama › 🤖 YZ Önerisi')}
                {ozSatir('ozTetkik', 'tetkik', 'İstem ekranı › 🤖 YZ Önerisi')}
                {ozSatir('ozIlac', 'ilac', 'Reçete › İlaç ara › 🤖 YZ Önerisi')}
                {ozSatir('ozRehber', 'rehber', 'Yardım asistanı')}
              </tbody>
            </table>
          </div>
          <div className="kagrup">
            <h6>{c('Sağlayıcı (salt okunur)')}</h6>
            <div className="yk-form">
              <div className="rk-fld"><label>{c('Sağlayıcı')}</label><div className="ak-salt">{ozet.saglayici.tur} · {ozet.saglayici.adres}</div></div>
              <div className="rk-fld"><label>{c('Model')}</label><div className="ak-salt">{ozet.saglayici.model}</div></div>
              <div className="rk-fld"><label>{c('Düşünme düzeyi')}</label><div className="ak-salt">{ozet.saglayici.akilYurutme || '—'}</div></div>
              <div className="rk-fld"><label>{c('Zaman aşımı')}</label><div className="ak-salt">{ozet.saglayici.zamanAsimiSn} sn</div></div>
              <div className="rk-fld"><label>{c('API anahtarı')}</label><div className="ak-salt">•••••••• ({c('sunucuda; gösterilmez, veritabanına yazılmaz')})</div></div>
            </div>
          </div>
        </div>
      </fieldset>
      {degistirir && (
        <div className="yk-dugmeler">
          <button type="button" className="d bir" onClick={() => void guvenli(async () => {
            const y = await api.aiKontorAyar(d); mesaj(y.mesaj); onKaydedildi();
          })}>💾 {c('Kaydet')}</button>
        </div>
      )}
    </>
  );
}

/* --------------------------------------------------------------- Gizlilik */
function GizlilikSekmesi() {
  return (
    <div className="yk-iki">
      <div className="kagrup">
        <h6>{c('Modele giden örnek metin (maskeli)')}</h6>
        <pre className="yk-maske">{`Yaş: 27 yaş
Cinsiyet: Kadın
Bölüm: Kulak Burun Boğaz
Şikâyet: [kişi] [kişi] 2 gündür boğaz ağrısı, ateş (TC [kimlik-no])
Hikâye: Öksürük yok. Titreme var.
Muayene bulguları: Tonsiller hipertrofik, beyaz eksüda
Vital: ateş 38.7 °C, nabız 102/dk
Alerjiler: Penisilin (döküntü)`}</pre>
        <p className="not">{c('[kişi] / [kimlik-no]: sunucuda maskelenen yerler. Metin veritabanına kaydedilmez.')}</p>
      </div>
      <div className="kagrup">
        <h6>{c('Gönderilen / gönderilmeyen')}</h6>
        <ul className="yk-liste">
          <li className="ok">✓ {c('Yaş (yıl; 2 yaş altı ay), cinsiyet, bölüm')}</li>
          <li className="ok">✓ {c('Şikâyet, hikâye, bulgular, son vital')}</li>
          <li className="ok">✓ {c('Mevcut / kronik tanılar, alerji ve ilaç etken maddeleri')}</li>
          <li className="yok">✗ {c('Ad, soyad, anne / baba adı, hekim adı')}</li>
          <li className="yok">✗ {c('TC kimlik / pasaport no, doğum tarihi, adres, telefon, e-posta')}</li>
          <li className="yok">✗ {c('Protokol / muayene numarası')}</li>
        </ul>
        <div className="rk-bant mavi yk-bant">
          {c('Öneriler katalogla doğrulanır: ICD kodu katalogda yoksa, lab kodu listede yoksa, ilaç kataloğunda ürün bulunamazsa gösterilmez; alerjiyle çakışan ilaç elenir. Karar hekimindir; hiçbir öneri kendiliğinden kayda yazılmaz.')}
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------ Satın al (4 adım) */
type Secim = { tur: 'plan' | 'paket'; kod: string; ad: string; tutar: number; kontor: number };

function SatinAlPenceresi({ baslangic, bakiye, onKapat, onTamam }: {
  baslangic: 'plan' | 'paket'; bakiye: number; onKapat(): void; onTamam(): void;
}) {
  const [veri, setVeri] = useState<Awaited<ReturnType<typeof api.aiKontorPlanlar>> | null>(null);
  const [adim, setAdim] = useState(1);
  const [donem, setDonem] = useState<1 | 12>(1);
  const [secim, setSecim] = useState<Secim | null>(null);
  const [fatura, setFatura] = useState({ unvan: '', vkn: '', vergiDairesi: '', adres: '', il: '', eposta: '' });
  const [siparis, setSiparis] = useState<Awaited<ReturnType<typeof api.aiKontorSiparis>> | null>(null);
  const [sonuc, setSonuc] = useState<Awaited<ReturnType<typeof api.aiKontorSimulasyon>> | null>(null);
  const [onayli, setOnayli] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  const planSecimi = (p: AiPlan, d: 1 | 12): Secim => ({ tur: 'plan', kod: p.kod, ad: `${p.ad} (${d === 12 ? 'yıllık' : 'aylık'})`,
    tutar: d === 12 ? p.yillikFiyat : p.aylikFiyat, kontor: p.aylikKontor * d });
  useEffect(() => {
    void api.aiKontorPlanlar().then(y => {
      setVeri(y);
      if (baslangic === 'paket' && y.paketler[1]) {
        const p = y.paketler[1];
        setSecim({ tur: 'paket', kod: p.kod, ad: `Ek paket ${sayi(p.kontor)}`, tutar: p.fiyat, kontor: p.kontor });
      } else {
        const p = y.planlar.find(x => x.oneCikan) ?? y.planlar[0];
        if (p) setSecim(planSecimi(p, 1));
      }
    }).catch(h => setHata(hataMetni(h)));
  }, [baslangic]);

  const kdvOrani = veri?.kdvOrani ?? 0.2;
  const ozet = secim && (
    <div className="yk-ozet">
      <div><span>{secim.ad}</span><b>{sayi(secim.kontor)} {c('kontör')}</b></div>
      <div><span>{c('Tutar')}</span><span>{tl(secim.tutar)}</span></div>
      <div><span>KDV %{Math.round(kdvOrani * 100)}</span><span>{tl(secim.tutar * kdvOrani)}</span></div>
      <div className="top"><span>{c('Ödenecek')}</span><span>{tl(secim.tutar * (1 + kdvOrani))}</span></div>
      <small className="sonuk">{secim.tur === 'plan' ? c('Otomatik yenilenir · istediğiniz zaman iptal') : c('Tek seferlik · 12 ay geçerli')}</small>
    </div>
  );

  const ileri = () => guvenli(async () => {
    setHata(null);
    if (adim === 1) { if (!secim) return; setAdim(2); return }
    if (adim === 2) {
      if (!fatura.unvan.trim() || !fatura.vkn.trim() || !fatura.eposta.trim()) { setHata('Fatura unvanı, VKN/TCKN ve e-posta zorunlu.'); return }
      setMesgul(true);
      try {
        // Sipariş SUNUCUDA fiyatlanır; istemci yalnız plan/paket kodunu yollar.
        setSiparis(await api.aiKontorSiparis({ tur: secim!.tur, kod: secim!.kod, donemAy: secim!.tur === 'plan' ? donem : undefined, fatura }));
        setAdim(3);
      } finally { setMesgul(false) }
      return;
    }
    if (adim === 4) { onKapat(); return }
  });

  const simulasyon = (basarili: boolean) => guvenli(async () => {
    if (!siparis) return;
    if (!onayli) { setHata('Sözleşme onayını işaretleyin.'); return }
    setMesgul(true);
    try {
      const y = await api.aiKontorSimulasyon(siparis.siparisId, basarili);
      setSonuc(y); setAdim(4); onTamam();
    } finally { setMesgul(false) }
  });

  const ADIMLAR = ['Plan / paket', 'Fatura bilgileri', 'Kartla ödeme', 'Sonuç'];
  return (
    <Modal baslik={`💳 ${c('Kontör Satın Al')}`} ekSinif="yk-satin" buyutmeYok onKapat={onKapat}
      alt={<>
        {adim > 1 && adim < 4 && !sonuc && <button type="button" className="d" disabled={mesgul} onClick={() => { setHata(null); setAdim(adim - 1) }}>‹ {c('Geri')}</button>}
        <span style={{ marginLeft: 'auto' }} />
        <button type="button" className="d" onClick={onKapat}>{adim === 4 ? c('Kapat') : c('Vazgeç')}</button>
        {adim < 3 && <button type="button" className="d bir" disabled={mesgul || !secim} onClick={() => void ileri()}>{c('Devam')} ›</button>}
      </>}>
      <div className="yk-adimlar">
        {ADIMLAR.map((a, i) => (
          <div key={a} className={`yk-adim${adim === i + 1 ? ' on' : adim > i + 1 ? ' bitti' : ''}`}><i>{adim > i + 1 ? '✓' : i + 1}</i>{c(a)}</div>
        ))}
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!veri ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="yk-sgov">
          {adim === 1 && (
            <>
              <div className="yk-donem" role="radiogroup" aria-label={c('Dönem')}>
                {([1, 12] as const).map(d => (
                  <button key={d} type="button" role="radio" aria-checked={donem === d} className={donem === d ? 'on' : ''}
                    onClick={() => { setDonem(d); if (secim?.tur === 'plan') { const p = veri.planlar.find(x => x.kod === secim.kod); if (p) setSecim(planSecimi(p, d)) } }}>
                    {d === 1 ? c('Aylık') : c('Yıllık (2 ay bedava)')}</button>
                ))}
              </div>
              <div className="yk-planlar">
                {veri.planlar.map(p => {
                  const sec = secim?.tur === 'plan' && secim.kod === p.kod;
                  const fiyat = donem === 12 ? p.yillikFiyat : p.aylikFiyat;
                  return (
                    <button key={p.kod} type="button" className={`yk-plan${sec ? ' sec' : ''}`} aria-pressed={sec}
                            onClick={() => setSecim(planSecimi(p, donem))}>
                      {p.oneCikan && <span className="rozet mavi yk-ust">⭐ {c('En çok tercih edilen')}</span>}
                      <span className="ad">{p.ad}</span>
                      <span className="fiyat">{sayi(fiyat)} ₺ <small>+ KDV / {donem === 12 ? c('yıl') : c('ay')}</small></span>
                      <span className="kont">{sayi(p.aylikKontor)} {c('kontör / ay')}</span>
                      <span className="sonuk">≈ {sayi(p.aylikFiyat / p.aylikKontor, 2)} ₺ / {c('öneri')}</span>
                      <ul>{p.ozellikler.map(o => <li key={o}>{o}</li>)}</ul>
                    </button>
                  );
                })}
              </div>
              <div className="yk-ekbas">{c('…ya da tek seferlik ek paket (plan değişmez)')}</div>
              <div className="yk-ekpaket">
                {veri.paketler.map(p => {
                  const sec = secim?.tur === 'paket' && secim.kod === p.kod;
                  return (
                    <button key={p.kod} type="button" className={`yk-p${sec ? ' sec' : ''}`} aria-pressed={sec}
                      onClick={() => setSecim({ tur: 'paket', kod: p.kod, ad: `Ek paket ${sayi(p.kontor)}`, tutar: p.fiyat, kontor: p.kontor })}>
                      <b>{sayi(p.kontor)}</b>{sayi(p.fiyat)} ₺
                    </button>
                  );
                })}
              </div>
            </>
          )}
          {adim === 2 && (
            <div className="yk-iki">
              <div className="yk-form iki">
                {([['unvan', 'Fatura unvanı *'], ['vkn', 'VKN / TCKN *'], ['vergiDairesi', 'Vergi dairesi'],
                   ['eposta', 'Fatura e-postası *'], ['il', 'İl'], ['adres', 'Adres']] as const).map(([a, l]) => (
                  <div key={a} className={`rk-fld${a === 'unvan' || a === 'adres' ? ' tam' : ''}`}>
                    <label htmlFor={`yk-f-${a}`}>{c(l)}</label>
                    <input id={`yk-f-${a}`} value={fatura[a]} maxLength={a === 'adres' ? 300 : 120}
                           onChange={e => setFatura(o => ({ ...o, [a]: e.target.value }))} />
                  </div>
                ))}
              </div>
              {ozet}
            </div>
          )}
          {adim === 3 && siparis && (
            <div className="yk-iki">
              <div className="yk-guvenli">
                <div className="bas">🔒 {c('Ödeme kuruluşunun güvenli formu')} <span className="rozet olumlu">3D Secure</span></div>
                {siparis.odemeSaglayici === 'simulasyon' ? (
                  <>
                    <div className="rk-bant sari yk-bant">
                      <b>{c('TEST — simülasyon ödeme.')}</b> {c('Ödeme kuruluşu henüz bağlı değil; kart bilgisi istenmez. Sonucu aşağıdan seçin — sunucu bunu ödeme kuruluşunun bildirimi gibi işler.')}
                    </div>
                    <label className="yk-onay"><input type="checkbox" checked={onayli} onChange={e => setOnayli(e.target.checked)} />
                      {c('Mesafeli Hizmet Sözleşmesi, Ön Bilgilendirme Formu ve YZ Kullanım Koşullarını okudum, kabul ediyorum.')}</label>
                    <div className="yk-dugmeler">
                      <button type="button" className="d bir" disabled={mesgul} onClick={() => void simulasyon(true)}>✓ {c('Başarılı ödeme')}</button>
                      <button type="button" className="d teh" disabled={mesgul} onClick={() => void simulasyon(false)}>✗ {c('Kart reddedildi')}</button>
                    </div>
                  </>
                ) : siparis.odemeAdresi ? (
                  <>
                    <p className="not">{c('Kart bilgileri iyzico\'nun güvenli sayfasında girilir; ödeme bitince bu ekrana dönersiniz.')}</p>
                    <label className="yk-onay"><input type="checkbox" checked={onayli} onChange={e => setOnayli(e.target.checked)} />
                      {c('Mesafeli Hizmet Sözleşmesi, Ön Bilgilendirme Formu ve YZ Kullanım Koşullarını okudum, kabul ediyorum.')}</label>
                    <div className="yk-dugmeler">
                      <button type="button" className="d bir" disabled={!onayli}
                              onClick={() => window.location.assign(siparis.odemeAdresi!)}>🔒 {c('iyzico ile öde')}</button>
                    </div>
                    <div className="yk-logolar"><span>iyzico</span><span>VISA</span><span>MasterCard</span><span>TROY</span></div>
                  </>
                ) : (
                  <p className="not">{c('Ödeme sayfası alınamadı; tekrar deneyin.')}</p>
                )}
              </div>
              <div>
                {ozet}
                <div className="rk-bant mavi yk-bant">
                  {c('Kart bilgisi Gentegre sunucusuna hiç gelmez: form ödeme kuruluşunun sayfasıdır. Biz yalnız ödeme sonucunu ve kartın son 4 hanesini alırız. Sipariş no')}: <b>#{siparis.siparisId}</b>
                </div>
              </div>
            </div>
          )}
          {adim === 4 && sonuc && (
            <div className="yk-sonuc">
              {sonuc.durum === 2 ? (
                <>
                  <div className="ik">✅</div>
                  <div className="bas ok">{c('Ödeme alındı — kontör yüklendi')}</div>
                  <div>{secim?.ad} · {sonuc.mesaj} {c('Yeni bakiye')}: <b>{sayi(sonuc.yeniBakiye)}</b></div>
                  <div className="sonuk">{c('Fatura no')}: {sonuc.faturaNo}</div>
                </>
              ) : (
                <>
                  <div className="ik">⛔</div>
                  <div className="bas hata">{c('Ödeme alınamadı')}</div>
                  <div>{sonuc.mesaj}</div>
                  <div className="sonuk">{c('Kontör yüklenmedi. Bakiye')}: {sayi(bakiye)}</div>
                </>
              )}
            </div>
          )}
        </div>
      )}
    </Modal>
  );
}
