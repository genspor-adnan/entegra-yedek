import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj, onay } from './mesaj';
import { tarihSaat } from './bicim';
import { c } from '../dil/ceviri';
import { BOLUM, ISTEM_DURUM } from './labKodlari';
import { GOZ_SONUC, GOZ_TARAF, GOZ_TETKIK } from './goz/gozKodlari';

/**
 * MUAYENE › İSTEM & SONUÇLAR (443; düzen: mockup muayene_karti_v2.html).
 *
 * <b>İki panel.</b> Solda istem listesi (bu muayenede istenen / başvuruya
 * gelen), sağda SEÇİLİ istemin sonuçları. Eskiden her istemin sonuç tablosu
 * alt alta diziliyordu; on istemli bir başvuruda hekim aradığı sonucu
 * kaydırarak buluyordu. Listede satıra tıklamak sonucu yanında açar.
 *
 * <b>Bağ satırı yetmez.</b> Kartın kendi gridi "şu istem açıldı" der;
 * hekimin ihtiyacı SONUCUN KENDİSİDİR.
 *
 * <b>Yalnız onaylı sonuçlar görünür.</b> Laboratuvarın doğrulamadığı bir
 * sayıya göre tedavi başlatılmamalı; bekleyen tetkik "sonuç bekleniyor"
 * olarak listelenir - eksikliğin kendisi de bilgidir. "Önceki" sütunu da
 * yalnız onaylı önceki sonucu gösterir (sunucu).
 *
 * <b>"Gördüm" ayrı bir olaydır</b>: sonucun gelmesi ile hekimin görmesi
 * farklı şeylerdir. Panik değer teyidi bu işarete bağlı - panikli istemde
 * işaret sonuç panelinin altında kırmızı şerit olarak istenir.
 */

type Satir = Record<string, unknown>;


const sayiMetni = (v: unknown, b = 2): string => {
  if (v === null || v === undefined || v === '') return '';
  const s = Number(v);
  return Number.isFinite(s) ? s.toLocaleString('tr-TR', { maximumFractionDigits: b })
                            : String(v);
};

/** "142" / "142,5" -> sayı; metin sonuç (pozitif, +++) -> null. */
const sayiyaCevir = (v: unknown): number | null => {
  if (v === null || v === undefined) return null;
  const s = Number(String(v).trim().replace(',', '.'));
  return Number.isFinite(s) && String(v).trim() !== '' ? s : null;
};

/** Sol listedeki tek satır: lab ve radyoloji aynı listede (hekim için tek kavram). */
type Kalem = { tur: 'lab' | 'radyoloji' | 'goz'; id: number; ham: Satir; bagli: boolean; panik: boolean };

export function MuayeneIstemSonuc({ muayeneId, onIstemAc, onDegisti }: {
  muayeneId: number;
  /** Araç çubuğundaki "＋ İstem Sepeti" düğmesi (birleşik istem modalını açar). */
  onIstemAc?: () => void;
  /** İstem silinince kartın diğer sayaçlarını tazelemek için. */
  onDegisti?: () => void;
}) {
  const git = useNavigate();
  const [veri, setVeri] = useState<{
    belgeId: number | null; istemler: Satir[]; sonuclar: Satir[];
    kulturler: Satir[]; vakalar: Satir[]; radyoloji: Satir[]; goz?: Satir[];
  } | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  // Seçili istem: sağ panel bunu gösterir, kırmızı 🗑 bunu siler.
  const [secili, setSecili] = useState<{ tur: 'lab' | 'radyoloji' | 'goz'; id: number } | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.muayeneSonuclari(muayeneId) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [muayeneId]);

  useEffect(() => { void yukle() }, [yukle]);

  const kalemler = useMemo<Kalem[]>(() => {
    if (!veri) return [];
    const lab = veri.istemler.map(i => {
      const id = Number(i.id);
      return {
        tur: 'lab' as const, id, ham: i, bagli: Number(i.bagId ?? 0) > 0,
        panik: veri.sonuclar.some(s => Number(s.istemId) === id && Number(s.panik ?? 0) === 1),
      };
    });
    const rad = veri.radyoloji.map(r => ({
      tur: 'radyoloji' as const, id: Number(r.id), ham: r,
      bagli: Number(r.bagId ?? 0) > 0, panik: false,
    }));
    // GÖZ GÖRÜNTÜLEME (974): aynı listede; eşik dışı ölçüm "panik" gibi öne alınmaz, rozetle görünür.
    const goz = (veri.goz ?? []).map(g => ({
      tur: 'goz' as const, id: Number(g.id), ham: g, bagli: Number(g.bagId ?? 0) > 0, panik: false,
    }));
    return [...lab, ...rad, ...goz];
  }, [veri]);

  // VARSAYILAN SEÇİM: panikli istem varsa o (hekimin ilk görmesi gereken),
  //   yoksa listenin ilki. Seçili istem silinince/kaybolunca yeniden seçilir.
  useEffect(() => {
    if (kalemler.length === 0) { if (secili) setSecili(null); return }
    if (secili && kalemler.some(k => k.tur === secili.tur && k.id === secili.id)) return;
    const ilk = kalemler.find(k => k.panik) ?? kalemler.find(k => k.bagli) ?? kalemler[0];
    setSecili({ tur: ilk.tur, id: ilk.id });
  }, [kalemler, secili]);

  const sil = () => guvenli(async () => {
    if (!secili) { mesaj('Önce silinecek istemi seçin.'); return }
    if (!await onay('Seçili istem silinecek. Onaylıyor musunuz?', true)) return;
    const y = secili.tur === 'lab'
      ? await api.labIstemSil(secili.id)
      : secili.tur === 'goz'
        ? await api.gozGoruntulemeIptal(secili.id)
        : await api.radyolojiIstemSil(secili.id);
    mesaj(y.mesaj);
    setSecili(null);
    await yukle();
    onDegisti?.();
  });

  const gordu = (bagId: number) => guvenli(async () => {
    await api.muayeneIstemGordu(bagId);
    mesaj('Sonuç görüldü olarak işaretlendi.');
    await yukle();
  });

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const arac = (
    <div className="muayene-arac" style={{ alignItems: 'center' }}>
      {onIstemAc && <button type="button" className="d bir" onClick={onIstemAc}>{c('＋ İstem Sepeti')}</button>}
      <button type="button" className="d sil" title={c('Seçili istemi sil')}
        disabled={!secili} onClick={() => void sil()}>🗑</button>
      <span className="not" style={{ marginLeft: 6 }}>
        {kalemler.length} {c('istem · silmek için satırı seçin (sonuçlanmış/çekilmiş silinemez)')}
      </span>
    </div>
  );

  if (kalemler.length === 0) {
    return (
      <div className="istem-sonuc">
        {arac}
        <p className="not ic">
          {c('Bu muayene ve başvurusu için açılmış istem yok. Lab / radyoloji istemi açmak için “＋ İstem Sepeti” düğmesini kullanın.')}
        </p>
      </div>
    );
  }

  const panikVar = kalemler.some(k => k.panik);
  const bagliKalemler = kalemler.filter(k => k.bagli);
  const digerKalemler = kalemler.filter(k => !k.bagli);
  const secKalem = secili ? kalemler.find(k => k.tur === secili.tur && k.id === secili.id) : undefined;

  const satirCiz = (k: Kalem) => {
    const sec = secili?.tur === k.tur && secili.id === k.id;
    const anahtar = `${k.tur}${k.id}`;
    const ortak = {
      className: `secilebilir${sec ? ' secili' : ''}${k.panik ? ' panik' : ''}`,
      style: { cursor: 'pointer' },
      onClick: () => setSecili({ tur: k.tur, id: k.id }),
    };
    if (k.tur === 'lab') {
      const i = k.ham;
      const satirlar = veri.sonuclar.filter(s => Number(s.istemId) === k.id);
      const adlar = satirlar.slice(0, 3).map(s => String(s.ad ?? '')).join(', ');
      const durum = Number(i.durum ?? 1);
      return (
        <tr key={anahtar} {...ortak}>
          <td>Lab</td>
          <td className="isn-ad">
            <b>{String(i.istemNo ?? '')}</b>
            {adlar && <span className="not"> · {adlar}
              {satirlar.length > 3 ? ` +${satirlar.length - 3}` : ''}</span>}
          </td>
          <td className="hiza-orta">
            {Number(i.oncelik ?? 1) === 3 ? <span className="rozet hata">{c('Acil')}</span> : '—'}
          </td>
          <td className="hiza-orta">{i.istemTarihi ? tarihSaat(i.istemTarihi) : '—'}</td>
          <td className="hiza-orta">
            <span className={`rozet ${durum === 5 ? 'olumlu' : durum === 9 ? 'gri' : 'uyari'}`}>
              {ISTEM_DURUM[durum] ?? ''}
            </span>
            {k.panik && <> <span className="rozet hata">{c('Panik')}</span></>}
          </td>
        </tr>
      );
    }
    if (k.tur === 'goz') {
      const g = k.ham;
      const gd = Number(g.durum ?? 1);
      return (
        <tr key={anahtar} {...ortak}>
          <td>{c('Göz')}</td>
          <td className="isn-ad">{GOZ_TETKIK[Number(g.tetkik)] ?? c('Göz tetkiki')} <span className="not">· {GOZ_TARAF[Number(g.goz)] ?? 'OU'}</span></td>
          <td className="hiza-orta">{Number(g.oncelik ?? 1) >= 2 ? <span className="rozet hata">{c('Acil')}</span> : '—'}</td>
          <td className="hiza-orta">{g.istemZamani ? tarihSaat(g.istemZamani) : '—'}</td>
          <td className="hiza-orta">
            <span className={`rozet ${gd === 3 ? 'olumlu' : gd === 0 ? 'gri' : 'uyari'}`}>{c(gozDurumAdi(g))}</span>
            {Number(g.bayrak ?? 0) >= 1 && <> <span className="rozet hata">{c('Eşik dışı')}</span></>}
          </td>
        </tr>
      );
    }
    const r = k.ham;
    const durum = Number(r.durum ?? 0);
    return (
      <tr key={anahtar} {...ortak}>
        <td>{c('Görüntüleme')}</td>
        <td className="isn-ad">{String(r.tetkik ?? '')}</td>
        <td className="hiza-orta">—</td>
        <td className="hiza-orta">{r.cekimTarihi ? tarihSaat(r.cekimTarihi) : '—'}</td>
        <td className="hiza-orta">
          <span className={`rozet ${r.onayTarihi ? 'olumlu' : 'uyari'}`}>
            {r.onayTarihi ? c('Raporlandı')
              : r.cekimTarihi ? c('Rapor bekliyor')
              : durum >= 2 ? c('Çekimde') : c('Sırada')}
          </span>
        </td>
      </tr>
    );
  };

  return (
    <div className="istem-sonuc">
      {arac}
      {/* PANİK UYARISI EN ÜSTTE: hekimin görmesi gereken tek şey buysa,
          listenin arasında kaybolmamalı. */}
      {panikVar && (
        <div className="uyari-kutusu">
          {c('⚠ Bu başvuruda PANİK DEĞER var — ilgili istem solda “Panik” ile işaretli.')}
        </div>
      )}

      <div className="isn-iki">
        <div className="isn-sol">
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th>{c('Tür')}</th><th>{c('Tetkik / İşlem')}</th>
                <th className="hiza-orta">{c('Aciliyet')}</th>
                <th className="hiza-orta">{c('İstem')}</th>
                <th className="hiza-orta">{c('Durum')}</th>
              </tr>
            </thead>
            <tbody>
              {bagliKalemler.length > 0 && (
                <tr className="isn-grup"><td colSpan={5}>{c('Bu muayenede istenen')}</td></tr>
              )}
              {bagliKalemler.map(satirCiz)}
              {digerKalemler.length > 0 && (
                <tr className="isn-grup"><td colSpan={5}>{c('Başvuruya gelen')}</td></tr>
              )}
              {digerKalemler.map(satirCiz)}
            </tbody>
          </table>
        </div>

        <div className="isn-sag">
          {!secKalem ? (
            <p className="not ic">{c('Sonucunu görmek için soldan bir istem seçin.')}</p>
          ) : secKalem.tur === 'lab'
            ? <LabSonucPaneli istem={secKalem.ham} veri={veri}
                onRapor={() => git(`/lab/rapor/${secKalem.id}`)}
                onGordu={gordu} />
            : secKalem.tur === 'goz'
              ? <GozGoruntuPaneli g={secKalem.ham} onGordu={gordu} onAc={() => git(`/goz-goruntuleme/${secKalem.id}`)} />
              : <RadyolojiPaneli r={secKalem.ham} onGordu={gordu} />}
        </div>
      </div>
    </div>
  );
}

function LabSonucPaneli({ istem: i, veri, onRapor, onGordu }: {
  istem: Satir;
  veri: { sonuclar: Satir[]; kulturler: Satir[]; vakalar: Satir[] };
  onRapor: () => void;
  onGordu: (bagId: number) => void;
}) {
  const istemId = Number(i.id);
  const satirlar = veri.sonuclar.filter(s => Number(s.istemId) === istemId);
  const kultur = veri.kulturler.filter(k => Number(k.istemId) === istemId);
  const vaka = veri.vakalar.filter(v => Number(v.istemId) === istemId);
  const bagId = Number(i.bagId ?? 0);
  const gorulen = i.hekimGordu ? tarihSaat(i.hekimGordu) : '';
  const panik = satirlar.some(s => Number(s.panik ?? 0) === 1);
  const sonOnay = satirlar.map(s => String(s.onayZamani ?? '')).filter(Boolean).sort().pop();

  return (
    <div className="kagrup">
      <h6>
        <b>{String(i.istemNo ?? '')}</b>
        <span className="rozet">{ISTEM_DURUM[Number(i.durum ?? 1)] ?? ''}</span>
        <span className="not">
          {String(i.onayli ?? 0)}/{String(i.tetkik ?? 0)} {c('onaylı')}
          {sonOnay ? ` · ${tarihSaat(sonOnay)}` : ''}
        </span>
        <span style={{ marginLeft: 'auto' }} />
        {/* SONUÇ RAPORU: hastaya verilen belge - aynı istemin sayısal,
            kültür ve genetik sonuçları tek kâğıtta. */}
        <button className="d" onClick={onRapor}>{c('🖨 Sonuç Raporu')}</button>
        {bagId > 0 && gorulen && <span className="rozet olumlu">{c('Görüldü')} · {gorulen}</span>}
        {bagId > 0 && !gorulen && !panik && (
          <button className="d bir" onClick={() => onGordu(bagId)}>{c('👁 Gördüm')}</button>
        )}
      </h6>

      {satirlar.length > 0 && (
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>{c('Test')}</th><th className="sag">{c('Sonuç')}</th><th>{c('Birim')}</th>
              <th>{c('Referans')}</th><th className="hiza-orta">{c('Bayrak')}</th>
              <th className="hiza-orta">{c('Önceki')}</th>
            </tr>
          </thead>
          <tbody>
            {satirlar.map((s, n) => {
              const bayrak = String(s.bayrak ?? '');
              const ref = String(s.referansMetin ?? '').trim() !== ''
                ? String(s.referansMetin)
                : (s.referansAlt !== null || s.referansUst !== null)
                  ? `${sayiMetni(s.referansAlt)} – ${sayiMetni(s.referansUst)}`
                  : '';
              // SONUCU OLMAYAN SATIR DA GÖRÜNÜR: "bekleniyor" bilgisi
              //   hekim için sonucun kendisi kadar önemlidir.
              const bekliyor = !s.deger;
              const satirPanik = Number(s.panik ?? 0) === 1;
              const simdi = sayiyaCevir(s.deger);
              const once = sayiyaCevir(s.onceki);
              const yon = simdi !== null && once !== null && simdi !== once
                ? (simdi > once ? ' ↑' : ' ↓') : '';
              return (
                <tr key={n} className={satirPanik ? 'panik' : ''}>
                  <td>
                    {satirPanik ? <b>{String(s.ad ?? '')}</b> : String(s.ad ?? '')}
                    <span className="not"> {String(s.kod ?? '')}</span>
                    <span className="not">{' · '}{BOLUM[Number(s.bolum ?? 0)] ?? ''}</span>
                  </td>
                  <td className="sag">
                    {bekliyor
                      ? <span className="not">{c('sonuç bekleniyor')}</span>
                      : <b className={satirPanik || bayrak === 'LL' || bayrak === 'HH' ? 'isn-vurgu' : ''}>
                          {String(s.deger)}</b>}
                  </td>
                  <td>{String(s.birim ?? '')}</td>
                  <td>{ref || '—'}</td>
                  <td className="hiza-orta">
                    {satirPanik ? <span className="rozet hata">{c('PANİK')}</span>
                      : bayrak === 'HH' || bayrak === 'LL' ? <span className="rozet hata">{bayrak}</span>
                      : bayrak === 'H' || bayrak === 'L' ? <span className="rozet uyari">{bayrak}</span>
                      : ''}
                    {Number(s.deltaUyari ?? 0) === 1 && (
                      <span className="not" title={c('Önceki sonuçtan belirgin sapma')}>{' '}Δ</span>
                    )}
                  </td>
                  <td className="hiza-orta not"
                    title={s.oncekiZamani ? tarihSaat(s.oncekiZamani) : undefined}>
                    {s.onceki ? `${String(s.onceki)}${yon}` : '—'}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}

      {kultur.map(k => (
        <div className="ic" key={`k${k.id}`}>
          <b>🦠 {String(k.tetkik ?? '')}:</b> {String(k.ozet ?? '')}
          {Number(k.abSayisi ?? 0) > 0 && (
            <span className="not"> · {String(k.abSayisi)} {c('antibiyotik raporlandı')}</span>
          )}
          {Number(k.kritik ?? 0) === 1 && (
            <span className="rozet uyari" style={{ marginLeft: 6 }}>{c('Kritik')}</span>
          )}
          {String(k.onRapor ?? '').trim() !== '' && !k.onayZamani && (
            <div className="not">{c('Ön rapor')}: {String(k.onRapor)}</div>
          )}
          {String(k.uzmanYorum ?? '').trim() !== '' && (
            <div className="not">{String(k.uzmanYorum)}</div>
          )}
        </div>
      ))}

      {vaka.map(v => (
        <div className="ic" key={`g${v.id}`}>
          <b>🧬 {String(v.test ?? '')} ({String(v.vakaNo ?? '')}):</b>{' '}
          {String(v.ozet ?? '')}
          {Number(v.varyantSayisi ?? 0) > 0 && (
            <span className="not"> · {String(v.varyantSayisi)} {c('varyant raporlandı')}</span>
          )}
          {String(v.oneriler ?? '').trim() !== '' && (
            <div className="not">{c('Öneriler')}: {String(v.oneriler)}</div>
          )}
        </div>
      ))}

      {/* PANİK TEYİDİ: "gördüm" işareti panikli istemde düz düğme değil,
          sonucun hemen altında kırmızı şerit - atlanamayacak yerde. */}
      {panik && bagId > 0 && !gorulen && (
        <div className="isn-panik">
          <span>⚠ {c('Panik değer — okunduğunu onaylayın')}</span>
          <span style={{ marginLeft: 'auto' }} />
          <button className="d" onClick={() => onGordu(bagId)}>{c('✔ Okudum, haberdarım')}</button>
        </div>
      )}
    </div>
  );
}

function RadyolojiPaneli({ r, onGordu }: { r: Satir; onGordu: (bagId: number) => void }) {
  const bagId = Number(r.bagId ?? 0);
  const sonuc = String(r.sonuc ?? '').trim();
  return (
    <div className="kagrup">
      <h6>
        <b>{String(r.tetkik ?? '')}</b>
        <span className={`rozet ${r.onayTarihi ? 'olumlu' : 'uyari'}`}>
          {r.onayTarihi ? c('Raporlandı') : r.cekimTarihi ? c('Rapor bekliyor') : c('Sırada')}
        </span>
        <span className="not">
          {r.cekimTarihi ? `${c('çekim')} ${tarihSaat(r.cekimTarihi)}` : ''}
          {String(r.raporNo ?? '') ? ` · ${String(r.raporNo)}` : ''}
        </span>
        <span style={{ marginLeft: 'auto' }} />
        {bagId > 0 && (r.hekimGordu
          ? <span className="rozet olumlu">{c('Görüldü')} · {tarihSaat(r.hekimGordu)}</span>
          : <button className="d bir" onClick={() => onGordu(bagId)}>{c('👁 Gördüm')}</button>)}
      </h6>
      <div className="ic">
        {sonuc || <span className="not">{r.onayTarihi ? c('Raporda sonuç bölümü yok.') : c('Rapor henüz onaylanmadı.')}</span>}
      </div>
    </div>
  );
}

// ------------------------------------------------------------- GÖZ (974) --
const OLCUM_AD: Record<string, string> = { cmt: 'CMT', rnfl_ort: 'RNFL ort.', md: 'MD', k1: 'K1', cct: 'CCT', al: 'AL' };

/** Ödeme / çekim / değerlendirme adımı tek metin. */
function gozDurumAdi(g: Satir): string {
  const d = Number(g.durum ?? 1);
  if (d === 0) return 'İptal';
  if (d === 3) return 'Değerlendirildi';
  if (d === 2) return 'Değerlendirme bekliyor';
  return Number(g.serbest ?? 1) === 0 ? 'Ödeme bekliyor' : 'Çekim sırasında';
}

function GozGoruntuPaneli({ g, onGordu, onAc }: { g: Satir; onGordu: (bagId: number) => void; onAc: () => void }) {
  const bagId = Number(g.bagId ?? 0);
  const d = Number(g.durum ?? 1);
  const ana = String(g.anaOlcum ?? '');
  return (
    <div className="kagrup">
      <h6>
        <b>{GOZ_TETKIK[Number(g.tetkik)] ?? c('Göz tetkiki')} · {GOZ_TARAF[Number(g.goz)] ?? 'OU'}</b>
        <span className={`rozet ${d === 3 ? 'olumlu' : d === 0 ? 'gri' : 'uyari'}`}>{c(gozDurumAdi(g))}</span>
        <span className="not">{g.cekimZamani ? `${c('çekim')} ${tarihSaat(g.cekimZamani)}` : ''}
          {g.kalite != null ? ` · ${c('sinyal')} ${String(g.kalite)}/10` : ''}</span>
        <span style={{ marginLeft: 'auto' }} />
        {d >= 2 && <button className="d" onClick={onAc}>{c('🖼 Görüntüyü aç')}</button>}
        {bagId > 0 && d === 3 && (g.hekimGordu
          ? <span className="rozet olumlu">{c('Görüldü')} · {tarihSaat(g.hekimGordu)}</span>
          : <button className="d bir" onClick={() => onGordu(bagId)}>{c('👁 Gördüm')}</button>)}
      </h6>
      <div className="ic">
        {d === 1 && Number(g.serbest ?? 1) === 0 && <div className="not">{c('Bankoda ücretlendirilip başvuru kaydedilince çekime düşer.')}</div>}
        {d === 1 && Number(g.serbest ?? 1) === 1 && <div className="not">{c('Teknisyen çekim listesinde.')}</div>}
        {ana && (g.anaOd != null || g.anaOs != null) && (
          <div>{OLCUM_AD[ana] ?? ana}: <b>OD {sayiMetni(g.anaOd) || '—'}</b> · <b>OS {sayiMetni(g.anaOs) || '—'}</b>
            {Number(g.bayrak ?? 0) >= 1 && <> <span className="rozet hata">{c('Eşik dışı')}</span></>}</div>
        )}
        {d === 3 && (
          <>
            <div style={{ marginTop: 4 }}><b>{c('Sonuç')}:</b> {c(GOZ_SONUC[Number(g.sonuc)] ?? '—')}</div>
            {String(g.degerlendirme ?? '') && <div style={{ whiteSpace: 'pre-wrap' }}>{String(g.degerlendirme)}</div>}
            {String(g.oneri ?? '') && <div><b>{c('Öneri')}:</b> {String(g.oneri)}</div>}
          </>
        )}
        {d === 2 && <div className="not">{c('Çekildi; hekim değerlendirmesi bekleniyor.')}</div>}
      </div>
    </div>
  );
}
