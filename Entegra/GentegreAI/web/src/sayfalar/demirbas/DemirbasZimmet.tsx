import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type {
  DemirbasBulunan, PersonelZimmeti, Tutanak, ZimmetIslemi, ZimmetOzet,
} from '../../api/uclar/demirbasZimmet';
import { GenGrid } from '../../bilesenler/GenGrid';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * ZİMMET / HAREKETLER (1007) - mockup Ekranlar/Demirbas/
 * demirbas_zimmet_hareketleri.html (kullanıcı 10.10.2026: "... yap").
 *
 * Ekran hareket YAZMAZ: işlem demirbaşın zimmet / lokasyon alanını değiştirir,
 * hareketi ve tutanak numarasını 1006 tetiği yazar (DemirbasZimmetUclari).
 * Üç sekme: Hareketler (günlük), Personel Zimmetleri, Lokasyon Dağılımı.
 */
const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const tarihKisa = (t: string | null) =>
  t ? new Date(t).toLocaleDateString('tr-TR') : '—';

type Sekme = 'hareket' | 'personel' | 'lokasyon';
const SEKMELER: [Sekme, string][] = [
  ['hareket', 'Hareketler'], ['personel', 'Personel Zimmetleri'], ['lokasyon', 'Lokasyon Dağılımı'],
];

const ISLEM_ADI: Record<ZimmetIslemi, string> = {
  veris: '👤 Zimmetle (Veriş)', iade: '↩ İade Al', devir: '⇄ Devret', yer: '📍 Yer Değiştir',
};

/** Hareket tipi çipleri - 1006 kodları (1 veriş/devir, 9 iade, 2 yer). */
const HAREKET_CIPLERI = [
  { ad: 'Tümü' },
  { ad: 'Veriş / Devir', filtre: { alan: 'tip', op: 'esit' as const, deger: 1 } },
  { ad: 'İade', filtre: { alan: 'tip', op: 'esit' as const, deger: 9 } },
  { ad: 'Yer değişikliği', filtre: { alan: 'tip', op: 'esit' as const, deger: 2 } },
];

export function DemirbasZimmet() {
  const { yetki } = useOturum();
  const yazabilir = yetki('demirbas.zimmet', 'degistir');
  const [sekme, setSekme] = useState<Sekme>('hareket');
  const [ozet, setOzet] = useState<ZimmetOzet | null>(null);
  const [hata, setHata] = useState('');
  const [tazele, setTazele] = useState(0);
  const [secilenKisi, setSecilenKisi] = useState<number | null>(null);
  const [kisiZimmetleri, setKisiZimmetleri] = useState<PersonelZimmeti[]>([]);
  const [islem, setIslem] = useState<{ tur: ZimmetIslemi; demirbaslar?: DemirbasBulunan[] } | null>(null);
  const [tutanakNo, setTutanakNo] = useState<string | null>(null);

  useEffect(() => {
    api.zimmetOzet().then(setOzet).catch(h => setHata(hataMetni(h)));
  }, [tazele]);

  useEffect(() => {
    if (secilenKisi == null) { setKisiZimmetleri([]); return }
    api.zimmetPersonel(secilenKisi).then(setKisiZimmetleri).catch(h => setHata(hataMetni(h)));
  }, [secilenKisi, tazele]);

  // İlk açılışta listedeki ilk kişi seçili gelsin (mockup).
  useEffect(() => {
    if (secilenKisi == null && ozet?.personeller.length) setSecilenKisi(ozet.personeller[0].id);
  }, [ozet, secilenKisi]);

  const kisiyeIslem = (tur: ZimmetIslemi) => {
    const kisi = ozet?.personeller.find(p => p.id === secilenKisi);
    setIslem({ tur, demirbaslar: kisiZimmetleri.map(z => ({
      id: z.id, kod: z.kod, ad: z.ad, zimmetId: secilenKisi, zimmet: kisi?.ad ?? '',
      lokasyon: null, lokasyonAd: '' })) });
  };

  const k = ozet?.kpi;
  const enCokDeger = Math.max(1, ...(ozet?.lokasyonlar ?? []).map(l => l.deger));
  const toplamDeger = (ozet?.lokasyonlar ?? []).reduce((t, l) => t + l.deger, 0);

  return (
    <>
      <style>{stil}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Zimmet / Hareketler</h1>
          <span className="yol">Sabit Varlıklar › Zimmet / Hareketler</span>
        </div>
      </div>

      {yazabilir && (
        <div className="dz-arac">
          {(Object.keys(ISLEM_ADI) as ZimmetIslemi[]).map(t => (
            <button key={t} className={t === 'veris' ? 'dz-ana' : ''} onClick={() => setIslem({ tur: t })}>
              {ISLEM_ADI[t]}
            </button>
          ))}
          <span className="dz-not">Toplu zimmet: pencerede birden çok demirbaş okutun - tek tutanak üretilir.</span>
        </div>
      )}

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="dz-kpi">
        <div className="dz-k"><div className="dz-kb">Toplam Demirbaş</div><div className="dz-kd">{k?.toplam ?? '—'}</div><div className="dz-ka">aktif kayıt</div></div>
        <div className="dz-k"><div className="dz-kb">Zimmetli</div><div className="dz-kd mavi">{k?.zimmetli ?? '—'}</div><div className="dz-ka">{k ? `${para(k.zimmetliDeger)} ₺` : ''}</div></div>
        <div className="dz-k"><div className="dz-kb">Depoda / Boşta</div><div className="dz-kd">{k?.bosta ?? '—'}</div><div className="dz-ka">kimsede değil</div></div>
        <div className="dz-k"><div className="dz-kb">Bu Ay Hareket</div><div className="dz-kd">{k?.buAyHareket ?? '—'}</div><div className="dz-ka">veriş · iade · yer</div></div>
        <div className="dz-k"><div className="dz-kb">İade Bekleyen</div>
          <div className={'dz-kd' + (k?.iadeBekleyen ? ' kir' : '')}>{k?.iadeBekleyen ?? '—'}</div>
          <div className="dz-ka">ayrılan personelde</div></div>
      </div>

      <div className="katab dz-tab" role="tablist">
        {SEKMELER.map(([s, ad]) => (
          <div key={s} role="tab" aria-selected={sekme === s}
               className={'kat' + (sekme === s ? ' on' : '')} onClick={() => setSekme(s)}>{ad}</div>
        ))}
      </div>

      {sekme === 'hareket' && (
        <GenGrid key={tazele} kaynak="demirbasHareket" gomulu seritGizli boyut={50}
                 cipler={HAREKET_CIPLERI}
                 kolonSirasi={['zaman', 'tipAdi', 'demirbasKod', 'demirbasAd', 'kimden', 'kime',
                               'tutanakNo', 'islemYapan', 'aciklama']}
                 onSatirAc={s => { const no = String(s.tutanakNo ?? ''); if (no) setTutanakNo(no) }} />
      )}

      {sekme === 'personel' && (
        <div className="dz-iki">
          <div className="dz-kisiler">
            {(ozet?.personeller ?? []).length === 0 && <div className="dz-bos">Zimmetli demirbaş yok.</div>}
            {(ozet?.personeller ?? []).map(p => (
              <div key={p.id} className={'dz-kisi' + (p.id === secilenKisi ? ' sec' : '')}
                   onClick={() => setSecilenKisi(p.id)}>
                <span className="ad">{p.ad}</span>
                {!p.aktif && <span className="bo-rz kir">işten ayrıldı — iade bekliyor</span>}
                <span className="sy">{p.adet}</span>
              </div>
            ))}
          </div>
          <div className="dz-sag">
            <table className="dz-tablo">
              <thead><tr><th>Demirbaş No</th><th>Ad</th><th>Kategori</th><th>Zimmet Tarihi</th>
                <th>Tutanak</th><th className="sag">Değer</th></tr></thead>
              <tbody>
                {kisiZimmetleri.map(z => (
                  <tr key={z.id}>
                    <td>{z.kod}</td><td>{z.ad}</td><td>{z.kategori || '—'}</td>
                    <td>{tarihKisa(z.zimmetTarihi)}</td>
                    <td>{z.tutanakNo
                      ? <a className="dz-link" onClick={() => setTutanakNo(z.tutanakNo)}>{z.tutanakNo}</a>
                      : '—'}</td>
                    <td className="sag">{para(z.deger)}</td>
                  </tr>
                ))}
                {kisiZimmetleri.length > 0 && (
                  <tr className="top"><td colSpan={5}>Toplam ({kisiZimmetleri.length} kalem)</td>
                    <td className="sag">{para(kisiZimmetleri.reduce((t, z) => t + z.deger, 0))}</td></tr>
                )}
              </tbody>
            </table>
            {yazabilir && kisiZimmetleri.length > 0 && (
              <div className="dz-arac alt">
                <button onClick={() => kisiyeIslem('iade')}>↩ Tümünü İade Al</button>
                <button onClick={() => kisiyeIslem('devir')}>⇄ Tümünü Devret</button>
              </div>
            )}
          </div>
        </div>
      )}

      {sekme === 'lokasyon' && (
        <table className="dz-tablo dz-lok">
          <thead><tr><th>Lokasyon</th><th className="sag">Adet</th><th className="sag">Zimmetli</th>
            <th className="sag">Değer</th><th style={{ width: '35%' }}>Pay</th></tr></thead>
          <tbody>
            {(ozet?.lokasyonlar ?? []).map(l => (
              <tr key={l.ad}>
                <td>{l.ad}</td><td className="sag">{l.adet}</td><td className="sag">{l.zimmetli}</td>
                <td className="sag">{para(l.deger)}</td>
                <td><div className="dz-bar"><span style={{ width: `${(l.deger / enCokDeger) * 100}%` }} /></div>
                  <span className="dz-yuzde">{toplamDeger ? `%${((l.deger / toplamDeger) * 100).toFixed(1)}` : ''}</span></td>
              </tr>
            ))}
            <tr className="top"><td>Toplam</td>
              <td className="sag">{(ozet?.lokasyonlar ?? []).reduce((t, l) => t + l.adet, 0)}</td>
              <td className="sag">{(ozet?.lokasyonlar ?? []).reduce((t, l) => t + l.zimmetli, 0)}</td>
              <td className="sag">{para(toplamDeger)}</td><td /></tr>
          </tbody>
        </table>
      )}

      <div className="dz-alt">
        Hareket → <b>DEMIRBAS_HAREKET</b> (tetikle yazılır) · Zimmet → <b>DEMIRBAS.ZIMMET_TARAF_ID</b> ·
        Tutanak no → <b>TUT.yyyy-nnnn</b> (yalnız veriş / iade / devir)
      </div>

      {islem && (
        <IslemModali tur={islem.tur} baslangic={islem.demirbaslar ?? []}
                     onKapat={() => setIslem(null)}
                     onTamam={(no, yazdir) => {
                       setIslem(null);
                       setTazele(t => t + 1);
                       if (no && yazdir) setTutanakNo(no);
                     }} />
      )}
      {tutanakNo && <TutanakModali no={tutanakNo} onKapat={() => setTutanakNo(null)} />}
    </>
  );
}

/** ZİMMETLE / İADE / DEVRET / YER DEĞİŞTİR penceresi - barkod okutularak çoklu seçim. */
function IslemModali({ tur, baslangic, onKapat, onTamam }: {
  tur: ZimmetIslemi; baslangic: DemirbasBulunan[];
  onKapat(): void; onTamam(tutanakNo: string, yazdir: boolean): void;
}) {
  const [secilen, setSecilen] = useState<DemirbasBulunan[]>(baslangic);
  const [aranan, setAranan] = useState('');
  const [sonuclar, setSonuclar] = useState<DemirbasBulunan[]>([]);
  const [personeller, setPersoneller] = useState<{ id: number; ad: string }[]>([]);
  const [lokasyonlar, setLokasyonlar] = useState<{ deger: number; ad: string }[]>([]);
  const [kisiId, setKisiId] = useState<number | ''>('');
  const [lokasyon, setLokasyon] = useState<number | ''>('');
  const [aciklama, setAciklama] = useState('');
  const [yazdir, setYazdir] = useState(tur !== 'yer');
  const [hata, setHata] = useState('');
  const [bekle, setBekle] = useState(false);
  const kisiGerekli = tur === 'veris' || tur === 'devir';

  useEffect(() => {
    if (kisiGerekli) api.zimmetPersoneller().then(setPersoneller).catch(h => setHata(hataMetni(h)));
    api.kodListe('demirbas.lokasyon')
      .then(l => setLokasyonlar(l.degerler.filter(d => d.aktif !== 0)))
      .catch(() => setLokasyonlar([]));
  }, [kisiGerekli]);

  const ara = useCallback(async (q: string) => {
    setAranan(q);
    if (q.trim().length < 2) { setSonuclar([]); return }
    try { setSonuclar(await api.zimmetDemirbasAra(q)) } catch (h) { setHata(hataMetni(h)) }
  }, []);

  const ekle = (d: DemirbasBulunan) => {
    if (!secilen.some(x => x.id === d.id)) setSecilen(s => [...s, d]);
    setAranan(''); setSonuclar([]);
  };

  // BARKOD: okuyucu Enter gönderir - tek eşleşme varsa doğrudan eklenir.
  const enter = async () => {
    const q = aranan.trim();
    if (!q) return;
    const l = sonuclar.length ? sonuclar : await api.zimmetDemirbasAra(q).catch(() => []);
    const tam = l.find(x => x.kod.toLocaleLowerCase('tr') === q.toLocaleLowerCase('tr')) ?? (l.length === 1 ? l[0] : null);
    if (tam) ekle(tam); else setSonuclar(l);
  };

  const kaydet = async () => {
    setHata('');
    if (secilen.length === 0) { setHata('En az bir demirbaş seçin.'); return }
    if (kisiGerekli && !kisiId) { setHata('Teslim alan personeli seçin.'); return }
    if (tur === 'yer' && !lokasyon) { setHata('Yeni lokasyonu seçin.'); return }
    setBekle(true);
    try {
      const r = await api.zimmetIslem({
        islem: tur, demirbasIdler: secilen.map(s => s.id),
        kisiId: kisiId === '' ? null : kisiId, lokasyon: lokasyon === '' ? null : lokasyon, aciklama,
      });
      onTamam(r.tutanakNo, yazdir);
    } catch (h) { setHata(hataMetni(h)) } finally { setBekle(false) }
  };

  return (
    <Modal baslik={ISLEM_ADI[tur].replace(/^\S+\s/, '')} dar onKapat={onKapat} buyutmeYok
           alt={<>
             <button className="birincil" disabled={bekle} onClick={kaydet}>Kaydet</button>
             <button onClick={onKapat}>Vazgeç</button>
           </>}>
      <style>{stil}</style>
      <div className="dz-form">
        <label>Demirbaş (barkod okut / no / ad)</label>
        <div className="dz-ara">
          <input autoFocus value={aranan} placeholder="Barkodu okutun veya yazın…"
                 onChange={e => void ara(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); void enter() } }} />
          {sonuclar.length > 0 && (
            <div className="dz-oneri">
              {sonuclar.map(s => (
                <div key={s.id} onClick={() => ekle(s)}>
                  <b>{s.kod}</b> {s.ad}
                  <span className="sonuk"> {s.zimmet ? `· ${s.zimmet}` : '· boşta'}{s.lokasyonAd ? ` · ${s.lokasyonAd}` : ''}</span>
                </div>
              ))}
            </div>
          )}
        </div>
        <div className="dz-secilen">
          {secilen.length === 0 && <span className="sonuk">Seçili demirbaş yok.</span>}
          {secilen.map(s => (
            <span key={s.id} className="dz-cip">
              {s.kod} {s.ad}{s.zimmet ? ` (${s.zimmet})` : ''}
              <a onClick={() => setSecilen(x => x.filter(y => y.id !== s.id))}>✖</a>
            </span>
          ))}
        </div>

        {kisiGerekli && (<>
          <label>Teslim alan personel</label>
          <select value={kisiId} onChange={e => setKisiId(e.target.value ? Number(e.target.value) : '')}>
            <option value="">— seçin —</option>
            {personeller.map(p => <option key={p.id} value={p.id}>{p.ad}</option>)}
          </select>
        </>)}

        {tur !== 'iade' && (<>
          <label>{tur === 'yer' ? 'Yeni lokasyon' : 'Lokasyon (değişmeyecekse boş)'}</label>
          <select value={lokasyon} onChange={e => setLokasyon(e.target.value ? Number(e.target.value) : '')}>
            <option value="">{tur === 'yer' ? '— seçin —' : '(değişmesin)'}</option>
            {lokasyonlar.map(l => <option key={l.deger} value={l.deger}>{l.ad}</option>)}
          </select>
        </>)}
        {tur === 'iade' && (
          <div className="sonuk">İade alınan demirbaş Ayarlar'daki iade lokasyonuna döner (tanımlı değilse yeri değişmez).</div>
        )}

        <label>Açıklama</label>
        <input value={aciklama} maxLength={300} onChange={e => setAciklama(e.target.value)} />

        {tur !== 'yer' && (
          <label className="dz-onay">
            <input type="checkbox" checked={yazdir} onChange={e => setYazdir(e.target.checked)} />
            Tutanak oluştur ve yazdır
          </label>
        )}
        {hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}

/** ZİMMET TUTANAĞI - A4 önizleme + yazdır. */
function TutanakModali({ no, onKapat }: { no: string; onKapat(): void }) {
  const [t, setT] = useState<Tutanak | null>(null);
  const [hata, setHata] = useState('');
  useEffect(() => { api.zimmetTutanak(no).then(setT).catch(h => setHata(hataMetni(h))) }, [no]);
  const toplam = (t?.kalemler ?? []).reduce((s, k) => s + k.deger, 0);
  return (
    <Modal baslik={`Zimmet Tutanağı ${no}`} onKapat={onKapat} buyutmeYok
           alt={<>
             <button className="birincil" disabled={!t} onClick={() => window.print()}>🖨️ Yazdır</button>
             <button onClick={onKapat}>Kapat</button>
           </>}>
      <style>{stil}</style>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {t && (
        <div className="dz-a4">
          <h2>DEMİRBAŞ {t.iade ? 'İADE' : 'ZİMMET'} TUTANAĞI</h2>
          <div className="dz-a4-ust">
            <span>Tutanak No: <b>{t.tutanakNo}</b></span>
            <span>Tarih: <b>{new Date(t.tarih).toLocaleString('tr-TR')}</b></span>
          </div>
          <table className="dz-a4-bilgi"><tbody>
            <tr><td>Teslim Eden</td><td>{t.teslimEden || '—'}</td></tr>
            <tr><td>Teslim Alan</td><td>{t.teslimAlan || '—'}</td></tr>
            <tr><td>Lokasyon</td><td>{t.lokasyon || '—'}</td></tr>
            {t.aciklama && <tr><td>Açıklama</td><td>{t.aciklama}</td></tr>}
          </tbody></table>
          <table className="dz-a4-kalem">
            <thead><tr><th>#</th><th>Demirbaş No</th><th>Adı</th><th>Marka / Model</th><th>Seri No</th>
              <th className="sag">Değer</th></tr></thead>
            <tbody>
              {t.kalemler.map((k, i) => (
                <tr key={k.kod}><td>{i + 1}</td><td>{k.kod}</td><td>{k.ad}</td><td>{k.markaModel || '—'}</td>
                  <td>{k.seriNo || '—'}</td><td className="sag">{para(k.deger)}</td></tr>
              ))}
              <tr className="top"><td colSpan={5}>Toplam</td><td className="sag">{para(toplam)}</td></tr>
            </tbody>
          </table>
          {!t.iade && t.metin && <p className="dz-a4-metin">{t.metin}</p>}
          <div className="dz-imza">
            <div><b>Teslim Eden</b><span>{t.teslimEden}</span><i>İmza</i></div>
            <div><b>Teslim Alan</b><span>{t.teslimAlan}</span><i>İmza</i></div>
          </div>
        </div>
      )}
    </Modal>
  );
}

const stil = `
.dz-arac { display:flex; gap:6px; flex-wrap:wrap; align-items:center; padding:8px 12px; }
.dz-arac button { border:1px solid var(--cizgi,#cdd6e0); border-radius:4px; padding:5px 11px; font-size:12px;
  background:var(--yuz,#fff); cursor:pointer; }
.dz-arac button.dz-ana { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; border-color:#2f6db3; }
.dz-arac.alt { padding:8px 0 0; }
.dz-not { font-size:11px; color:var(--soluk,#6b7a8b); margin-left:auto; }
.dz-kpi { display:grid; grid-template-columns:repeat(5,1fr); gap:1px; margin:0 12px 10px;
  background:var(--cizgi-ince,#e3e9f0); border:1px solid var(--cizgi-ince,#e3e9f0); border-radius:4px; overflow:hidden; }
@media (max-width: 900px) { .dz-kpi { grid-template-columns:repeat(2,1fr); } }
.dz-kpi .dz-k { background:var(--yuz,#fff); padding:7px 12px; }
.dz-kpi .dz-kb { font-size:10.5px; color:var(--soluk,#6b7a8b); text-transform:uppercase; letter-spacing:.3px; }
.dz-kpi .dz-kd { font-size:18px; font-weight:bold; color:var(--baslik,#14315a); }
.dz-kpi .dz-kd.mavi { color:#2f6db3; } .dz-kpi .dz-kd.kir { color:#b3261e; }
.dz-kpi .dz-ka { font-size:10.5px; color:var(--soluk,#6b7a8b); }
.dz-tab { margin:0 12px; }
.dz-iki { display:grid; grid-template-columns:260px 1fr; gap:12px; padding:10px 12px; }
@media (max-width: 800px) { .dz-iki { grid-template-columns:1fr; } }
.dz-kisiler { border:1px solid var(--cizgi-ince,#e3e9f0); border-radius:4px; max-height:60vh; overflow:auto; }
.dz-kisi { display:flex; gap:6px; align-items:center; flex-wrap:wrap; padding:7px 10px; cursor:pointer;
  border-bottom:1px solid var(--cizgi-ince,#e3e9f0); font-size:12.5px; }
.dz-kisi.sec { background:#eef4fc; font-weight:bold; }
.dz-kisi .ad { flex:1; } .dz-kisi .sy { background:#cdd9e6; color:#34506e; border-radius:9px; padding:0 7px; font-size:11px; }
.dz-bos { padding:12px; color:var(--soluk,#6b7a8b); font-size:12px; }
.dz-tablo { width:100%; border-collapse:collapse; font-size:12px; }
.dz-tablo th, .dz-tablo td { border-bottom:1px solid var(--cizgi-ince,#e3e9f0); padding:5px 8px; text-align:left; }
.dz-tablo th { background:#f3f6fa; font-weight:600; }
.dz-tablo .sag { text-align:right; font-family:Consolas,monospace; }
.dz-tablo tr.top td { font-weight:bold; background:#f3f6fa; }
.dz-lok { margin:10px 12px; width:calc(100% - 24px); }
.dz-bar { display:inline-block; width:75%; height:9px; background:#eef2f6; border-radius:5px; overflow:hidden; vertical-align:middle; }
.dz-bar span { display:block; height:100%; background:#4d8fd6; }
.dz-yuzde { font-size:11px; color:var(--soluk,#6b7a8b); margin-left:6px; }
.dz-link { color:#2f6db3; cursor:pointer; text-decoration:underline; }
.dz-alt { margin:10px 12px; padding:6px 9px; font-size:11px; color:var(--soluk,#6b7a8b);
  background:#f7fafc; border:1px solid var(--cizgi-ince,#e3e9f0); border-radius:3px; }
.dz-form { display:grid; gap:6px; padding:4px 2px; }
.dz-form label { font-size:11.5px; font-weight:600; color:var(--yazi2,#1f2d3a); margin-top:4px; }
.dz-form input, .dz-form select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; padding:5px 7px; font-size:12.5px; }
.dz-ara { position:relative; }
.dz-ara input { width:100%; box-sizing:border-box; }
.dz-oneri { position:absolute; z-index:5; left:0; right:0; background:var(--yuz,#fff); border:1px solid var(--cizgi,#cdd6e0);
  border-radius:3px; box-shadow:0 6px 16px rgba(0,0,0,.12); max-height:220px; overflow:auto; }
.dz-oneri div { padding:5px 8px; cursor:pointer; font-size:12px; } .dz-oneri div:hover { background:#eef4fc; }
.dz-secilen { display:flex; gap:5px; flex-wrap:wrap; min-height:24px; }
.dz-cip { background:#eef4fc; border:1px solid #cfe0f5; color:#2f6db3; border-radius:12px; padding:2px 8px; font-size:11.5px; }
.dz-cip a { margin-left:5px; cursor:pointer; color:#b3261e; }
.dz-onay { display:flex; gap:6px; align-items:center; font-weight:normal !important; }
.dz-a4 { background:#fff; color:#111; width:min(190mm,100%); margin:0 auto; padding:14mm 12mm; box-sizing:border-box;
  border:1px solid #d9dee5; font-size:12px; }
.dz-a4 h2 { text-align:center; margin:0 0 10px; font-size:16px; letter-spacing:.5px; }
.dz-a4-ust { display:flex; justify-content:space-between; margin-bottom:10px; }
.dz-a4-bilgi { width:100%; border-collapse:collapse; margin-bottom:10px; }
.dz-a4-bilgi td { border:1px solid #bbb; padding:4px 7px; } .dz-a4-bilgi td:first-child { width:30%; font-weight:bold; background:#f5f5f5; }
.dz-a4-kalem { width:100%; border-collapse:collapse; }
.dz-a4-kalem th, .dz-a4-kalem td { border:1px solid #bbb; padding:4px 6px; text-align:left; }
.dz-a4-kalem .sag { text-align:right; } .dz-a4-kalem tr.top td { font-weight:bold; }
.dz-a4-metin { margin:12px 0; line-height:1.5; text-align:justify; }
.dz-imza { display:grid; grid-template-columns:1fr 1fr; gap:24px; margin-top:24px; }
.dz-imza div { display:flex; flex-direction:column; gap:4px; text-align:center; }
.dz-imza i { margin-top:40px; border-top:1px solid #333; padding-top:3px; font-style:normal; color:#555; }
@media print {
  body * { visibility:hidden !important; }
  .dz-a4, .dz-a4 * { visibility:visible !important; }
  .dz-a4 { position:fixed; left:0; top:0; width:100%; border:none; }
}
`;

export default DemirbasZimmet;
