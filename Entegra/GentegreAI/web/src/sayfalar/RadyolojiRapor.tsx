import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { Modal } from '../bilesenler/Modal';


/**
 * RADYOLOJİ RAPORU YAZMA (283/284).
 *
 * Generic karta sığmaz: bölümler ŞABLONDAN üretilir, makrolar imlecin
 * bulunduğu bölüme metin ekler, onay iki aşamalıdır ve onaydan sonra rapor
 * KİLİTLENİR. Düzen mockup ile aynı (Ekranlar/radyoloji_rapor_yaz.html):
 * solda hastanın geçmişi ve istem, ortada bölümler, sağda şablon/makro/skor.
 */
interface Bolum { id?: number; sira: number; baslik: string; metin: string;
                  yazdir: number; zorunlu?: number }
interface Sablon { id: number; kod: string; ad: string; surum: number;
                   varsayilan: number; tetkigeOzel: number }
interface Makro { kisayol: string; ad: string; metin: string; hedefBolum: string }
interface Skor { alanKod: string; alanAd: string; tip: number; secenekler: string;
                 zorunlu: number; raporaBas: number }
interface Gecmis { id: number; accessionNo: string; tetkikAdi: string; tarih: string;
                   raporlayan: string; ozet: string }
interface Kritik { bulgu: string; bildirilenAd: string; yol: number;
                   bildirimZamani: string; geriBildirim: string }

type Kayit = Record<string, unknown>;

/** Sunucudan gelen zaman damgasini "30.08.2026 14:05" olarak yazar. */
function anMetni(d: unknown): string {
  const t = d ? new Date(String(d)) : null;
  if (!t || Number.isNaN(t.getTime())) return '—';
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(t.getDate())}.${p(t.getMonth() + 1)}.${t.getFullYear()} `
       + `${p(t.getHours())}:${p(t.getMinutes())}`;
}

const RAPOR_DURUM: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Taslak',    sinif: 'uyari' },
  2: { ad: 'Ön Rapor',  sinif: 'bilgi' },
  3: { ad: 'Onaylı',    sinif: 'basari' },
};

const KRITIK_YOL: Record<number, string> = {
  1: 'Telefon', 2: 'SMS', 3: 'Yüz yüze', 4: 'e-Posta',
};

export function RadyolojiRapor() {
  const { istemId } = useParams();
  const git = useNavigate();
  const id = Number(istemId) || 0;

  const [istem, setIstem] = useState<Kayit | null>(null);
  const [rapor, setRapor] = useState<Kayit | null>(null);
  const [bolumler, setBolumler] = useState<Bolum[]>([]);
  const [sablonlar, setSablonlar] = useState<Sablon[]>([]);
  const [makrolar, setMakrolar] = useState<Makro[]>([]);
  const [skorlar, setSkorlar] = useState<Skor[]>([]);
  const [skorDeger, setSkorDeger] = useState<Record<string, string>>({});
  const [gecmis, setGecmis] = useState<Gecmis[]>([]);
  const [kritikler, setKritikler] = useState<Kritik[]>([]);
  const [sablonId, setSablonId] = useState<number | null>(null);
  const [kritik, setKritik] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');
  const [kritikModal, setKritikModal] = useState(false);
  /**
   * KONSULTASYON (304): ikinci gorus. Istek ve DONEN GORUS ayni yerden
   * yazilir - gorus alanina yazip kaydetmek kaydi "dondu"ye gecirir.
   */
  const [konsultasyonlar, setKonsultasyonlar] = useState<Kayit[]>([]);
  const [konsModal, setKonsModal] = useState(false);
  const [konsForm, setKonsForm] = useState({ hekimId: '', gerekce: '' });
  const [gorusYaz, setGorusYaz] = useState<{ id: number; gorus: string } | null>(null);
  const [kritikForm, setKritikForm] = useState({ bulgu: '', bildirilenAd: '', yol: 1,
                                                 geriBildirim: '' });
  /** Makro hangi bölüme eklenecek: en son dokunulan alan. */
  const sonBolum = useRef<number>(0);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      const y = await api.radyolojiRapor(id);
      setIstem(y.istem); setRapor(y.rapor);
      setSablonlar(y.sablonlar as unknown as Sablon[]);
      setMakrolar(y.makrolar as unknown as Makro[]);
      setSkorlar(y.skorlar as unknown as Skor[]);
      setGecmis(y.gecmis as unknown as Gecmis[]);
      setKritikler(y.kritikler as unknown as Kritik[]);
      setKonsultasyonlar(await api.radyolojiKonsultasyonlar(id));
      setKritik(Number(y.istem?.kritik ?? 0) === 1);

      const sec = (y.rapor?.sablonId as number | undefined)
               ?? (y.sablonlar as unknown as Sablon[])[0]?.id ?? null;
      setSablonId(sec);

      // Rapor varsa bölümleri ondan; yoksa şablon iskeletinden.
      if (y.bolumler.length > 0) {
        setBolumler((y.bolumler as Kayit[]).map(b => ({
          id: Number(b.id), sira: Number(b.sira), baslik: String(b.baslik ?? ''),
          metin: String(b.metin ?? ''), yazdir: Number(b.yazdir ?? 1),
          zorunlu: Number(b.zorunlu ?? 0),
        })));
      } else if (sec) {
        await sablonUygula(sec, true, String(y.istem?.klinikBilgi ?? ''));
      }

      const d: Record<string, string> = {};
      (y.alanlar as Kayit[]).forEach(a => { d[String(a.alanKod)] = String(a.deger ?? '') });
      setSkorDeger(d);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  // sablonUygula bilerek bagimlilikta degil: ilk yuklemede tek yon calisir.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);

  /**
   * Şablonu uygular: bölüm iskeletini kurar. `ilk` değilse kullanıcıya sorar -
   * yazılmış metnin üstüne şablon basmak emeği siler.
   */
  async function sablonUygula(sId: number, ilk = false, klinik = '') {
    if (!ilk && bolumler.some(b => b.metin.trim())) {
      if (!(await onay('Şablon yeniden uygulansın mı? Yazılmış bölüm metinleri '
                     + 'şablonun varsayılan metniyle değişir.'))) return;
    }
    const y = await api.radyolojiSablonBolumleri(sId);
    setBolumler(y.map((b, i) => {
      const baslik = String(b.baslik ?? '');
      // KLINIK BILGI istemden dolar: hekim ayni metni ikinci kez yazmasin.
      //   Sablonun kendi varsayilani varsa ona dokunulmaz.
      const varsayilan = String(b.varsayilanMetin ?? '');
      const klinikMi = baslik.toLocaleLowerCase('tr').includes('klinik');
      return {
        sira: Number(b.sira ?? i + 1), baslik,
        metin: !varsayilan && klinikMi ? klinik : varsayilan,
        yazdir: Number(b.yazdir ?? 1), zorunlu: Number(b.zorunlu ?? 0),
      };
    }));
    setSablonId(sId);
    const m = await api.radyolojiRapor(id);
    setMakrolar(m.makrolar as unknown as Makro[]);
  }

  const bolumYaz = (i: number, metin: string) =>
    setBolumler(b => b.map((x, k) => (k === i ? { ...x, metin } : x)));

  /** Makro metnini hedef bölüme (yoksa son dokunulan bölüme) ekler. */
  const makroEkle = (m: Makro) => {
    const hedef = m.hedefBolum
      ? bolumler.findIndex(b => b.baslik.toLocaleLowerCase('tr') ===
                                m.hedefBolum.toLocaleLowerCase('tr'))
      : -1;
    const i = hedef >= 0 ? hedef : sonBolum.current;
    if (i < 0 || i >= bolumler.length) return;
    setBolumler(b => b.map((x, k) => (k === i
      ? { ...x, metin: x.metin ? `${x.metin.trimEnd()} ${m.metin}` : m.metin }
      : x)));
  };

  const govde = () => ({
    sablonId,
    bolumler: bolumler.map(b => ({ id: b.id, sira: b.sira, baslik: b.baslik,
                                   metin: b.metin, yazdir: b.yazdir })),
    alanlar: skorlar.map(s => ({ alanKod: s.alanKod, alanAd: s.alanAd,
                                 deger: skorDeger[s.alanKod] ?? '' })),
    kritik: kritik ? 1 : 0,
  });

  const kaydet = async (sonra?: () => Promise<void>) =>
    guvenli(async () => {
      await api.radyolojiRaporYaz(id, govde());
      if (sonra) await sonra();
      await yukle();
      if (!sonra) mesaj('Rapor taslağı kaydedildi.');
    });

  const durumaGecir = (hedef: 'on-rapor' | 'onay') => kaydet(async () => {
    const raporId = Number((await api.radyolojiRapor(id)).rapor?.id ?? 0);
    if (!raporId) throw new Error('Rapor bulunamadı.');
    await api.radyolojiRaporDurum(raporId, hedef);
    mesaj(hedef === 'onay'
      ? 'Rapor onaylandı ve imzalandı; artık kilitlidir.'
      : 'Ön rapor uzman onayına gönderildi.');
  });

  const kritikKaydet = () => guvenli(async () => {
    await api.radyolojiKritikBulgu(id, kritikForm);
    setKritikModal(false);
    setKritikForm({ bulgu: '', bildirilenAd: '', yol: 1, geriBildirim: '' });
    await yukle();
    mesaj('Kritik bulgu bildirimi kaydedildi.');
  });

  const addendum = () => guvenli(async () => {
    const raporId = Number(rapor?.id ?? 0);
    if (!raporId) return;
    await api.radyolojiAddendum(raporId);
    await yukle();
    mesaj('Ek rapor (addendum) açıldı; orijinal rapor değişmeden kalır.');
  });

  if (yukleniyor) return <div className="yukleniyor">Yükleniyor…</div>;
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!istem) return <div className="hata-kutusu">İstem bulunamadı.</div>;

  const kilitli = Number(rapor?.kilit ?? 0) === 1;
  const durum = RAPOR_DURUM[Number(rapor?.durum ?? 1)] ?? RAPOR_DURUM[1];
  const yas = istem.dogumTarihi
    ? Math.floor((Date.now() - new Date(String(istem.dogumTarihi)).getTime())
                 / 31557600000)
    : null;

  return (
    <div className="sayfa rad-rapor">
      <div className="sayfa-bas">
        <h2>Radyoloji Raporu <span className="sonuk">{String(istem.accessionNo ?? '')}</span></h2>
        <div className="sayfa-eylem">
          <button className="d bir" disabled={kilitli} onClick={() => void kaydet()}>
            💾 Taslak Kaydet
          </button>
          <button className="d" disabled={kilitli}
                  onClick={() => void durumaGecir('on-rapor')}>➜ Uzmana Gönder</button>
          <button className="d basari" disabled={kilitli}
                  onClick={() => void durumaGecir('onay')}>✍ Onayla ve İmzala</button>
          <button className="d teh" disabled={kilitli}
                  onClick={() => setKritikModal(true)}>⚠ Kritik Bulgu Bildir</button>
          {kilitli && <button className="d" onClick={() => void addendum()}>＋ Ek Rapor</button>}
          {/* CIKTI (303): rapor kaydedilmeden numarasi/bolumleri olmaz -
              rapor yoksa dugme kapali. Onaysiz raporun ciktisinda "taslak"
              uyarisi cikar, basilmasi engellenmez (hekim kontrol icin alir). */}
          <button className="d" disabled={!rapor?.id}
                  title={rapor?.id ? 'Hastaya verilecek rapor çıktısı'
                                   : 'Önce raporu kaydedin.'}
                  onClick={() => git(`/radyoloji/cikti/${Number(rapor?.id)}`)}>
            🖨 Çıktı
          </button>
          <button className="d" onClick={() => git('/radyoloji')}>Kapat</button>
        </div>
      </div>

      {/* Kimlik şeridi - her zaman görünür */}
      <div className="kaid">
        <div className="alan-izgara rad-kimlik">
          <label className="alan"><span className="etiket">Hasta</span>
            <span className="deger-serit">
              <b>{String(istem.hastaAdi ?? '')}</b>
              {yas !== null && <span className="sonuk">{yas} y</span>}
            </span></label>
          <label className="alan"><span className="etiket">Tetkik</span>
            <span className="deger-serit">
              {String(istem.tetkikKodu ?? '')} · {String(istem.tetkikAdi ?? '')}
            </span></label>
          <label className="alan"><span className="etiket">Çekim</span>
            <span className="deger-serit">
              {istem.cekimTarihi ? anMetni(istem.cekimTarihi) : '—'}
              {istem.cihazAdi ? ` · ${String(istem.cihazAdi)}` : ''}
            </span></label>
          <label className="alan"><span className="etiket">Durum</span>
            <span className="deger-serit"><span className={`rozet ${durum.sinif}`}>{durum.ad}</span>
              {kilitli && <span className="rozet">🔒 Kilitli</span>}
            </span></label>
        </div>
      </div>

      <div className="rad-govde">
        {/* --------------------------------------------------- SOL: geçmiş --- */}
        <div className="rad-yan">
          <h5>Önceki Tetkikler</h5>
          {gecmis.length === 0 && <div className="sonuk kucuk">Önceki tetkik yok.</div>}
          {gecmis.map(g => (
            <div className="rad-kart" key={g.id}>
              <b>{g.tetkikAdi}</b>
              <div className="sonuk kucuk">
                {anMetni(g.tarih)}{g.raporlayan ? ` · ${g.raporlayan}` : ''}
              </div>
              {g.ozet && <div className="kucuk">{g.ozet}…</div>}
            </div>
          ))}

          <h5>İstem Bilgisi</h5>
          <div className="rad-kart">
            <div><b>Ön tanı:</b> {String(istem.onTani ?? '—')}</div>
            <div><b>Klinik:</b> {String(istem.klinikBilgi ?? '—')}</div>
            <div><b>İsteyen:</b> {String(istem.isteyen ?? '—')}</div>
            <div><b>Ödeyen:</b> {String(istem.odeyenKurum ?? '—')}</div>
          </div>

          <h5>Seri / Görüntü</h5>
          <div className="rad-kart">
            <b>{Number(istem.seriSayisi ?? 0)} seri · {Number(istem.goruntuSayisi ?? 0)} görüntü</b>
            {istem.studyUid ? <div className="sonuk kucuk">{String(istem.studyUid)}</div>
                            : <div className="sonuk kucuk">PACS eşleşmesi yok.</div>}
          </div>

          {kritikler.length > 0 && (
            <>
              <h5>Kritik Bulgu Bildirimleri</h5>
              {kritikler.map((k, i) => (
                <div className="rad-kart teh" key={i}>
                  <b>{k.bulgu}</b>
                  <div className="kucuk">{k.bildirilenAd} · {KRITIK_YOL[k.yol] ?? ''}</div>
                  <div className="sonuk kucuk">{anMetni(k.bildirimZamani)}</div>
                </div>
              ))}
            </>
          )}
        </div>

        {/* --------------------------------------------------- ORTA: rapor --- */}
        <div className="rad-orta">
          {bolumler.length === 0 && (
            <div className="bilgi-kutusu">
              Şablon seçilmemiş. Sağdan bir şablon seçip uygulayın.
            </div>
          )}
          {bolumler.map((b, i) => (
            <div className="rad-bolum" key={`${b.baslik}-${i}`}>
              <div className="rad-bolum-bas">
                {b.baslik}{b.zorunlu === 1 && <span className="zor"> *</span>}
                {b.yazdir === 0 && <span className="sonuk kucuk"> · çıktıya basılmaz</span>}
              </div>
              <textarea
                value={b.metin}
                readOnly={kilitli}
                onFocus={() => { sonBolum.current = i }}
                onChange={e => bolumYaz(i, e.target.value)}
                rows={b.baslik.toLocaleLowerCase('tr').includes('bulgu') ? 8 : 3}
              />
            </div>
          ))}
        </div>

        {/* -------------------------------------------- SAĞ: şablon / makro --- */}
        <div className="rad-yan">
          <h5>Şablon</h5>
          <select value={sablonId ?? ''} disabled={kilitli}
                  onChange={e => void sablonUygula(Number(e.target.value))}>
            <option value="">— seçiniz —</option>
            {sablonlar.map(s => (
              <option key={s.id} value={s.id}>
                {s.kod ? `${s.kod} · ` : ''}{s.ad}{s.tetkigeOzel === 1 ? ' ★' : ''}
              </option>
            ))}
          </select>

          <h5 style={{ marginTop: 12 }}>Makrolar</h5>
          {makrolar.length === 0 && <div className="sonuk kucuk">Bu şablonda makro yok.</div>}
          {makrolar.map(m => (
            <button type="button" className="rad-makro" key={m.kisayol} disabled={kilitli}
                    title={m.metin} onClick={() => makroEkle(m)}>
              <span className="kis">{m.kisayol}</span>
              <span>{m.ad}</span>
            </button>
          ))}

          {skorlar.length > 0 && (
            <>
              <h5 style={{ marginTop: 12 }}>Yapılandırılmış Alanlar</h5>
              {skorlar.map(s => (
                <label className="alan" key={s.alanKod}>
                  <span className="etiket">{s.alanAd}{s.zorunlu === 1 ? ' *' : ''}</span>
                  {s.secenekler ? (
                    <select value={skorDeger[s.alanKod] ?? ''} disabled={kilitli}
                            onChange={e => setSkorDeger(d => ({ ...d, [s.alanKod]: e.target.value }))}>
                      <option value="">—</option>
                      {s.secenekler.split('|').map(x => <option key={x} value={x}>{x}</option>)}
                    </select>
                  ) : (
                    <input value={skorDeger[s.alanKod] ?? ''} readOnly={kilitli}
                           onChange={e => setSkorDeger(d => ({ ...d, [s.alanKod]: e.target.value }))} />
                  )}
                </label>
              ))}
            </>
          )}

          <h5 style={{ marginTop: 12 }}>Kritik Bulgu</h5>
          <label className="alan yatay">
            <input type="checkbox" checked={kritik} disabled={kilitli}
                   onChange={e => setKritik(e.target.checked)} />
            <span>Bu tetkikte kritik bulgu var</span>
          </label>
          <div className="uyari-kutusu kucuk">
            İşaretliyse <b>bildirim kaydı olmadan rapor onaylanamaz</b>: kime, hangi yolla ve
            ne zaman haber verildiği kayda geçer.
          </div>

          {/* KONSULTASYON (304): supheli olguda ikinci gorus. Rapor kilitli
              olsa da istenebilir - gorus geldiginde addendum yazilir. */}
          <h5 style={{ marginTop: 12 }}>Konsültasyon</h5>
          <button className="d mini" onClick={() => setKonsModal(true)}>
            ＋ İkinci Görüş İste
          </button>
          {konsultasyonlar.length === 0 && (
            <div className="not kucuk">İstenmiş konsültasyon yok.</div>
          )}
          {konsultasyonlar.map(k => (
            <div className="kons-satir" key={String(k.id)}>
              <div>
                <b>{String(k.hekim ?? '') || String(k.kurum ?? '') || '—'}</b>
                <span className={`rozet ${Number(k.durum ?? 0) === 2 ? 'basari' : 'uyari'}`}>
                  {Number(k.durum ?? 0) === 2 ? 'Görüş geldi' : 'Bekliyor'}
                </span>
              </div>
              <div className="sonuk">{String(k.gerekce ?? '')}</div>
              {String(k.gorus ?? '').trim() !== '' && (
                <div className="kons-gorus">{String(k.gorus)}</div>
              )}
              {Number(k.durum ?? 0) !== 2 && (
                <button className="d mini"
                        onClick={() => setGorusYaz({ id: Number(k.id), gorus: '' })}>
                  ✎ Görüşü Gir
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Konsultasyon ISTEGI: hekim listesi rapor ekraninda zaten yok, bu
          yuzden serbest metin gerekce + (opsiyonel) hekim secimi yerine
          gerekce yeterli - gorusu YAZAN kisi kayittan belli olur. */}
      {konsModal && (
        <Modal baslik="İkinci Görüş İste" dar onKapat={() => setKonsModal(false)}
               alt={<>
                 <button className="d bir" onClick={() => void guvenli(async () => {
                   await api.radyolojiKonsultasyon(id, { gerekce: konsForm.gerekce,
                                                         hekimId: null, kurumId: null });
                   setKonsModal(false);
                   setKonsForm({ hekimId: '', gerekce: '' });
                   await yukle();
                   mesaj('Konsültasyon istendi.');
                 })}>Gönder</button>
                 <button className="d" onClick={() => setKonsModal(false)}>Vazgeç</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">Gerekçe</span>
              <textarea rows={3} value={konsForm.gerekce}
                        placeholder="örn. L4-L5 düzeyinde şüpheli lezyon; nöroradyoloji görüşü."
                        onChange={e => setKonsForm(f => ({ ...f, gerekce: e.target.value }))} />
            </label>
          </div>
        </Modal>
      )}

      {gorusYaz && (
        <Modal baslik="Konsültasyon Görüşü" dar onKapat={() => setGorusYaz(null)}
               alt={<>
                 <button className="d bir" onClick={() => void guvenli(async () => {
                   await api.radyolojiKonsultasyon(id, { gorus: gorusYaz.gorus, gerekce: '' },
                                                   gorusYaz.id);
                   setGorusYaz(null);
                   await yukle();
                   mesaj('Görüş kaydedildi.');
                 })}>Kaydet</button>
                 <button className="d" onClick={() => setGorusYaz(null)}>Vazgeç</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">Görüş</span>
              <textarea rows={4} value={gorusYaz.gorus}
                        onChange={e => setGorusYaz(g => (g ? { ...g, gorus: e.target.value } : g))} />
            </label>
          </div>
          <div className="not">
            Gelen görüş raporu DEĞİŞTİRMEZ; onaylı raporda düzeltme gerekiyorsa
            “＋ Ek Rapor” ile addendum yazın.
          </div>
        </Modal>
      )}

      {kritikModal && (
        <Modal baslik="Kritik Bulgu Bildirimi" onKapat={() => setKritikModal(false)}
               alt={<>
                 <button className="d bir" onClick={() => void kritikKaydet()}>Kaydet</button>
                 <button className="d" onClick={() => setKritikModal(false)}>Vazgeç</button>
               </>}>
          <div className="alan-izgara tek-sutun">
            <label className="alan"><span className="etiket">Bulgu</span>
              <input value={kritikForm.bulgu}
                     onChange={e => setKritikForm(f => ({ ...f, bulgu: e.target.value }))} /></label>
            <label className="alan"><span className="etiket">Bildirilen kişi</span>
              <input value={kritikForm.bildirilenAd}
                     onChange={e => setKritikForm(f => ({ ...f, bildirilenAd: e.target.value }))} /></label>
            <label className="alan"><span className="etiket">Yol</span>
              <select value={kritikForm.yol}
                      onChange={e => setKritikForm(f => ({ ...f, yol: Number(e.target.value) }))}>
                {Object.entries(KRITIK_YOL).map(([k, v]) =>
                  <option key={k} value={k}>{v}</option>)}
              </select></label>
            <label className="alan"><span className="etiket">Geri bildirim</span>
              <input value={kritikForm.geriBildirim}
                     onChange={e => setKritikForm(f => ({ ...f, geriBildirim: e.target.value }))} /></label>
          </div>
        </Modal>
      )}
    </div>
  );
}
