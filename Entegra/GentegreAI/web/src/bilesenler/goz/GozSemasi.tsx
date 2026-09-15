import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GozCizimIsareti, GozCizimKarsilastirma, GozCizimYaniti } from '../../api/uclar/goz';
import { Modal } from '../Modal';
import { mesaj, onay } from '../mesaj';
import { SemaZemini } from './gozSemaZemini';

/**
 * GÖZ ŞEMASI (705) — mockup `Ekranlar/Goz/goz_semasi.html`.
 *
 * <b>Çizim ölçüm değildir.</b> C/D oranı, GİB, görme yine kendi sekmelerine
 * yazılır; şema onların yerini almaz, YERİNİ gösterir. "Saat 11'de kanama"
 * cümlesi, aynı hastayı altı ay sonra gören hekim için ancak şemayla birlikte
 * anlam taşır.
 *
 * <b>Ekran kural yazmaz.</b> Tıklanan nokta 0–1 oranı olarak gönderilir;
 * saat kadranı ve çizimden üretilen cümle SUNUCUDA hesaplanır. İki ekranın
 * (kart, yazdırma) aynı çizimden farklı cümle üretmemesi böyle güvence altında.
 *
 * <b>Üretilen metin öneridir:</b> hekim hedef alanı seçip onaylamadan hiçbir
 * bulgu alanına geçmez — dikte ile aynı kapıdan (`bulgu-metni`) yazılır.
 */
export function GozSemasi({ gozMuayeneId, onKapat, onTamam }: {
  gozMuayeneId: number;
  onKapat(): void;
  onTamam?(): void;
}) {
  const git = useNavigate();
  const [yanit, setYanit] = useState<GozCizimYaniti | null>(null);
  // KARŞILAŞTIRMA çizimin asıl işi: tek şema "bugün ne var"ı, iki şema
  //   "ne değişti"yi söyler - kararı değiştiren ikincisi. Fark sunucuda
  //   hesaplanır (tür + saat), ekran yalnız gösterir.
  const [onceki, setOnceki] = useState<GozCizimKarsilastirma | null>(null);
  const [karsilastir, setKarsilastir] = useState(false);
  const [semaTuru, setSemaTuru] = useState(2);
  const [damga, setDamga] = useState(1);
  const [arac, setArac] = useState<'damga' | 'ciz'>('damga');
  const [secili, setSecili] = useState<{ goz: number; sira: number } | null>(null);
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hedef, setHedef] = useState('');
  const [metin, setMetin] = useState('');
  // Çizim durumu göz ve şema başına ayrı: hekim OD'yi çizerken OS'ye
  //   geçip dönebilmeli, arada kaydetmeye zorlanmamalı.
  const [isaretler, setIsaretler] = useState<Record<string, GozCizimIsareti[]>>({});
  const cizimAktif = useRef<{ goz: number; noktalar: string[] } | null>(null);
  // GERİ AL en son HANGİ GÖZE işaret konduğunu bilmeli: iki tuval yan yana
  //   duruyor, "son işlem" ekranın tamamı için tek.
  const sonGoz = useRef(1);

  const anahtar = (goz: number, sema: number) => `${goz}-${sema}`;
  const liste = (goz: number) => isaretler[anahtar(goz, semaTuru)] ?? [];
  const kilitli = yanit?.muayeneKapali ?? false;

  const oku = async () => {
    try {
      const y = await api.gozCizimOku(gozMuayeneId);
      setYanit(y);
      const yeni: Record<string, GozCizimIsareti[]> = {};
      for (const c of y.semalar) yeni[anahtar(c.goz, c.semaTuru)] = c.isaretler;
      setIsaretler(yeni);
    } catch (h) { setHata(hataMetni(h)) }
  };

  useEffect(() => { void oku() }, [gozMuayeneId]);   // eslint-disable-line react-hooks/exhaustive-deps

  // Hedef alan şemaya göre daralır: fundus çizimi ön segment alanına
  //   yazılmasın - yanlış yere düşen bulgu, olmayan bulgudan beterdir.
  const hedefler = (yanit?.hedefler ?? []).filter(h =>
    semaTuru === 2 || semaTuru === 3 ? h.kod.startsWith('fundus.')
      : h.kod.startsWith('onSegment.'));
  useEffect(() => {
    const varsayilan = semaTuru === 2 ? 'fundus.disk'
      : semaTuru === 3 ? 'fundus.periferi'
      : semaTuru === 4 ? 'onSegment.kapak' : 'onSegment.kornea';
    setHedef(hedefler.some(h => h.kod === varsayilan) ? varsayilan
             : (hedefler[0]?.kod ?? ''));
  }, [semaTuru, yanit]);                             // eslint-disable-line react-hooks/exhaustive-deps

  const damgalar = (yanit?.damgalar ?? []).filter(d => d.semalar.includes(semaTuru));
  useEffect(() => {
    if (damgalar.length && !damgalar.some(d => d.tur === damga)) setDamga(damgalar[0].tur);
  }, [semaTuru, yanit]);                             // eslint-disable-line react-hooks/exhaustive-deps

  const oran = (e: React.PointerEvent<SVGSVGElement>) => {
    const k = e.currentTarget.getBoundingClientRect();
    return {
      x: Math.min(1, Math.max(0, (e.clientX - k.left) / k.width)),
      y: Math.min(1, Math.max(0, (e.clientY - k.top) / k.height)),
    };
  };

  const ekle = (goz: number, i: GozCizimIsareti) => {
    sonGoz.current = goz;
    setIsaretler(t => ({ ...t, [anahtar(goz, semaTuru)]: [...(t[anahtar(goz, semaTuru)] ?? []), i] }));
  };

  /** Son konan işareti geri alır - yanlış yere tıklamak çizimde kuraldır. */
  const geriAl = () => {
    const a = anahtar(sonGoz.current, semaTuru);
    setIsaretler(t => ({ ...t, [a]: (t[a] ?? []).slice(0, -1) }));
    setSecili(null);
  };

  const bas = (goz: number) => (e: React.PointerEvent<SVGSVGElement>) => {
    if (kilitli) return;
    const p = oran(e);
    if (arac === 'damga') {
      const d = damgalar.find(x => x.tur === damga);
      ekle(goz, { sekil: 1, tur: damga, x: p.x, y: p.y,
                  renk: d?.renk ?? '#b3261e', yol: '', aciklama: '' });
      return;
    }
    e.currentTarget.setPointerCapture(e.pointerId);
    cizimAktif.current = { goz, noktalar: [`M${(p.x * 320).toFixed(1)} ${(p.y * 320).toFixed(1)}`] };
  };

  const surukle = (e: React.PointerEvent<SVGSVGElement>) => {
    if (!cizimAktif.current) return;
    const p = oran(e);
    cizimAktif.current.noktalar.push(`L${(p.x * 320).toFixed(1)} ${(p.y * 320).toFixed(1)}`);
    // Çizgi bitene kadar geçici olarak gösterilsin diye durum güncellenir.
    setIsaretler(t => ({ ...t }));
  };

  const birak = (goz: number) => (e: React.PointerEvent<SVGSVGElement>) => {
    const c = cizimAktif.current;
    cizimAktif.current = null;
    if (!c || c.noktalar.length < 3) return;
    const p = oran(e);
    // SERBEST ÇİZİMİN "konumu" ORTA NOKTASIDIR: saat kadranı ondan hesaplanır,
    //   yoksa çizgi hangi saatte diye cevap veremezdik.
    ekle(goz, {
      sekil: 2, tur: 16, x: p.x, y: p.y, renk: '#1f2d3a',
      yol: c.noktalar.join(' '), aciklama: '',
    });
  };

  const sil = (goz: number, sira: number) =>
    setIsaretler(t => ({
      ...t,
      [anahtar(goz, semaTuru)]: (t[anahtar(goz, semaTuru)] ?? []).filter((_, i) => i !== sira),
    }));

  const kaydet = async (goz: number) => {
    setHata('');
    setKaydediyor(true);
    try {
      const y = await api.gozCizimKaydet(gozMuayeneId, {
        goz, semaTuru, svg: '', isaretler: liste(goz),
      });
      setMetin(y.uretilenMetin);
      mesaj(y.uretilenMetin
        ? `${y.isaret} işaret kaydedildi. Üretilen metin hazır — hekim onayıyla yazılır.`
        : `${y.isaret} işaret kaydedildi.`);
      await oku();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const bulguyaYaz = async (goz: number) => {
    if (!metin.trim()) { setHata('Önce çizimi kaydedin: metin çizimden üretilir.'); return }
    if (!hedef) { setHata('Hedef alan seçilmeli.'); return }
    if (!await onay(`Metin "${hedefler.find(h => h.kod === hedef)?.ad}" alanına `
                    + 'eklensin mi? Mevcut bulgu silinmez, sonuna eklenir.')) return;
    setHata('');
    try {
      const y = await api.gozBulguMetni(gozMuayeneId, { hedef, goz, metin, yontem: 2 });
      mesaj(y.aciklama);
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) }
  };

  const karsilastirAc = async () => {
    if (karsilastir) { setKarsilastir(false); return }
    try {
      const y = await api.gozCizimKarsilastir(gozMuayeneId);
      setOnceki(y);
      setKarsilastir(true);
      if (!y.oncekiId) mesaj(y.aciklama);
    } catch (h) { setHata(hataMetni(h)) }
  };

  /** Çıktı AYRI SAYFA: kâğıda palet ve araç değil, antet + döküm gider. */
  const yazdir = () => { onKapat(); git(`/goz/sema-cikti/${gozMuayeneId}`) };

  const oncekiKopyala = async () => {
    if (!await onay('Önceki muayenenin şemaları getirilsin mi? '
                    + 'Bu muayenede çizilmiş şema korunur.')) return;
    try {
      const y = await api.gozCizimOncekiKopyala(gozMuayeneId);
      mesaj(y.aciklama);
      await oku();
    } catch (h) { setHata(hataMetni(h)) }
  };

  /** Önceki muayenenin aynı göz/şema işaretleri (salt okunur çizilir). */
  const oncekiIsaret = (goz: number) =>
    onceki?.semalar.find(s => s.goz === goz && s.semaTuru === semaTuru)?.isaretler ?? [];

  /** Bir işaretin çizimi - bugün ve önceki aynı kodla çizilsin diye ortak. */
  const isaretCiz = (i: GozCizimIsareti, sira: number, seyrek: boolean,
                     secimVar = false, tikla?: () => void) => {
    const d = yanit?.damgalar.find(x => x.tur === i.tur);
    if (i.sekil === 2 || i.yol) {
      return (
        <path key={sira} d={i.yol} fill="none" stroke={i.renk || '#1f2d3a'}
              strokeWidth={secimVar ? 3.4 : 2.2} strokeLinecap="round"
              opacity={seyrek ? 0.45 : 1} onClick={tikla} />
      );
    }
    const x = (i.x ?? 0) * 320;
    const y = (i.y ?? 0) * 320;
    return (
      <g key={sira} onClick={tikla} opacity={seyrek ? 0.5 : 1}>
        {secimVar && <circle cx={x} cy={y} r="11" fill="none"
                             stroke="#2f6db3" strokeDasharray="3 3" />}
        <text x={x} y={y + 4} fontSize="14" textAnchor="middle"
              fill={i.renk || d?.renk || '#b3261e'}>{d?.simge ?? '●'}</text>
      </g>
    );
  };

  /** Karşılaştırma kipinde üstte duran ÖNCEKİ çizim: salt okunur, soluk. */
  const oncekiTuval = (goz: number) => (
    <div className="sema-goz onceki">
      <div className="gb">
        <span className={goz === 1 ? 'od' : 'os'}>{goz === 1 ? 'OD' : 'OS'} · önceki</span>
        <span className="sp">
          {onceki?.oncekiTarih
            ? new Date(onceki.oncekiTarih).toLocaleDateString('tr-TR') : '—'}
          {' · '}{oncekiIsaret(goz).length} işaret
        </span>
      </div>
      <svg viewBox="0 0 320 320" className="sema-tuval">
        <SemaZemini semaTuru={semaTuru} goz={goz} />
        {oncekiIsaret(goz).map((i, sira) => isaretCiz(i, sira, true))}
      </svg>
    </div>
  );

  const gozTuvali = (goz: number) => {
    const isaret = liste(goz);
    const gecici = cizimAktif.current?.goz === goz ? cizimAktif.current.noktalar.join(' ') : '';
    return (
      <div className="sema-goz" key={goz}>
        <div className="gb">
          <span className={goz === 1 ? 'od' : 'os'}>{goz === 1 ? 'OD · Sağ' : 'OS · Sol'}</span>
          <span className="sp">{isaret.length} işaret</span>
          {!kilitli && (
            <button className="d" disabled={kaydediyor} onClick={() => void kaydet(goz)}>
              💾 Kaydet
            </button>
          )}
        </div>
        <svg viewBox="0 0 320 320" className="sema-tuval"
             style={{ cursor: kilitli ? 'default' : 'crosshair' }}
             onPointerDown={bas(goz)} onPointerMove={surukle} onPointerUp={birak(goz)}>
          <SemaZemini semaTuru={semaTuru} goz={goz} />
          {isaret.map((i, sira) => isaretCiz(
            i, sira, false, secili?.goz === goz && secili.sira === sira,
            () => setSecili({ goz, sira })))}
          {gecici && <path d={gecici} fill="none" stroke="#1f2d3a"
                           strokeWidth="2.2" strokeDasharray="4 3" />}
        </svg>
      </div>
    );
  };

  return (
    <Modal baslik="🖼 Göz Şeması" onKapat={onKapat}
           ustBilgi={yanit ? `${yanit.hasta}${yanit.dilate ? ' · dilate' : ''}` : undefined}
           alt={
             <>
               <button className="d" onClick={geriAl}
                       disabled={kilitli || liste(sonGoz.current).length === 0}>
                 ↶ Geri al
               </button>
               <button className="d" onClick={() => void oncekiKopyala()} disabled={kilitli}>
                 📋 Önceki çizimden başla
               </button>
               <button className={`d${karsilastir ? ' secili' : ''}`}
                       onClick={() => void karsilastirAc()}>
                 ⇄ Öncekiyle karşılaştır
               </button>
               <button className="d" onClick={yazdir}>🖨 Yazdır / rapora ekle</button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {kilitli && (
        <div className="uyari-kutusu">
          Muayene tamamlanmış: çizim kilitli. Düzeltme yeni muayenede,
          "önceki çizimden başla" ile yapılır.
        </div>
      )}

      <div className="sema-sekme">
        {(yanit?.semaAdlari ?? []).map(s => (
          <button key={s.tur} className={`d${semaTuru === s.tur ? ' secili' : ''}`}
                  onClick={() => { setSemaTuru(s.tur); setSecili(null); setMetin('') }}>
            {s.ad}
          </button>
        ))}
      </div>

      <div className="sema-duzen">
        <div className="sema-palet">
          <div className="pb">Damgalar</div>
          {damgalar.map(d => (
            <button key={d.tur} type="button"
                    className={`sema-damga${damga === d.tur && arac === 'damga' ? ' secili' : ''}`}
                    onClick={() => { setDamga(d.tur); setArac('damga') }}>
              <span className="sim" style={{ color: d.renk }}>{d.simge}</span>
              {d.ad}
            </button>
          ))}
          <div className="pb">Araç</div>
          <button type="button" className={`sema-damga${arac === 'ciz' ? ' secili' : ''}`}
                  onClick={() => setArac('ciz')}>
            <span className="sim">✎</span> Serbest çiz
          </button>
          <button type="button" className="sema-damga" disabled={!secili || kilitli}
                  onClick={() => { if (secili) { sil(secili.goz, secili.sira); setSecili(null) } }}>
            <span className="sim">🗑</span> Seçili işareti sil
          </button>
        </div>

        <div className="sema-tuvaller">
          {/* KARŞILAŞTIRMA: önceki üstte, bugün altta. Yan yana koymak dört
              tuvali bir satıra sıkıştırır, aynı gözün iki tarihi ayrı
              köşelere düşerdi - karşılaştırma tam da o ikisini yan yana
              okumak demek. */}
          {karsilastir && onceki?.oncekiId ? (
            <>
              {oncekiTuval(1)}
              {oncekiTuval(2)}
              {gozTuvali(1)}
              {gozTuvali(2)}
            </>
          ) : (
            <>
              {gozTuvali(1)}
              {gozTuvali(2)}
            </>
          )}
        </div>

        <div className="sema-yan">
          <div className="pb">İşaretler</div>
          {[1, 2].flatMap(goz => liste(goz).map((i, sira) => {
            const d = yanit?.damgalar.find(x => x.tur === i.tur);
            return (
              <button key={`${goz}-${sira}`} type="button"
                      className={`sema-satir${secili?.goz === goz && secili.sira === sira ? ' secili' : ''}`}
                      onClick={() => setSecili({ goz, sira })}>
                <span className="sim" style={{ color: i.renk || d?.renk }}>{d?.simge ?? '●'}</span>
                {d?.ad ?? 'İşaret'}
                <span className="sp">
                  <span className={goz === 1 ? 'od' : 'os'}>{goz === 1 ? 'OD' : 'OS'}</span>
                  {i.saat ? ` · saat ${i.saat}` : ''}
                </span>
              </button>
            );
          }))}
          {liste(1).length + liste(2).length === 0 && (
            <div className="sema-bos">Şemaya tıklayarak işaret koyun.</div>
          )}

          {karsilastir && onceki?.oncekiId ? (
            <>
              <div className="pb">Değişim
                <span className="sp">
                  {onceki.oncekiTarih
                    ? new Date(onceki.oncekiTarih).toLocaleDateString('tr-TR') : ''} → bugün
                </span>
              </div>
              {onceki.degisim
                .filter(d => d.semaTuru === semaTuru)
                .map((d, i) => {
                  const ad = yanit?.damgalar.find(x => x.tur === d.tur)?.ad ?? 'İşaret';
                  return (
                    <div key={i} className={`sema-satir degisim ${d.durum}`}>
                      <span className="sim">
                        {d.durum === 'yeni' ? '＋' : d.durum === 'kayboldu' ? '－' : '=' }
                      </span>
                      {ad}
                      <span className="sp">
                        <span className={d.goz === 1 ? 'od' : 'os'}>
                          {d.goz === 1 ? 'OD' : 'OS'}</span>
                        {d.saat ? ` · saat ${d.saat}` : ''} · {d.durum}
                      </span>
                    </div>
                  );
                })}
              <div className="sema-not">{onceki.aciklama} Eşleşme işaretin TÜRÜ ve
                SAATİ üzerinden yapılır: aynı lezyon iki çizimde birebir aynı
                piksele düşmez, hekim de zaten saat kadranıyla konuşur.</div>
            </>
          ) : null}

          <div className="pb">Çizimden üretilen metin <span className="sp">öneri</span></div>
          <textarea className="sema-metin" rows={4} value={metin}
                    placeholder="Çizimi kaydedin; cümle sunucuda üretilir."
                    onChange={e => setMetin(e.target.value)} />
          <div className="sema-yaz">
            <select value={hedef} onChange={e => setHedef(e.target.value)}>
              {hedefler.map(h => <option key={h.kod} value={h.kod}>{h.ad}</option>)}
            </select>
            <button className="d onay" disabled={kilitli || !metin.trim()}
                    onClick={() => void bulguyaYaz(1)}>✔ OD alanına yaz</button>
            <button className="d onay" disabled={kilitli || !metin.trim()}
                    onClick={() => void bulguyaYaz(2)}>✔ OS alanına yaz</button>
          </div>
          <div className="sema-not">
            Metin hekim onayı olmadan bulgu alanına geçmez; ölçüm alanlarına
            (görme, basınç, C/D) hiçbir koşulda yazılmaz.
          </div>

          <div className="pb">Sürümler</div>
          {(yanit?.gecmis ?? []).map(g => (
            <div key={g.id} className="sema-satir">
              v{g.surum} <span className={g.goz === 1 ? 'od' : 'os'}>
                {g.goz === 1 ? 'OD' : 'OS'}</span>
              <span className="sp">
                {new Date(g.zaman).toLocaleString('tr-TR')}
                {g.kilitli ? ' · kilitli' : ''}
              </span>
            </div>
          ))}
        </div>
      </div>
    </Modal>
  );
}
