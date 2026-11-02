import { useContext, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import type { EslemeAdayi, EslemeAilesi, EslemeListesi, EslemeOnizleme, EslemeSatiri } from '../../api/uclar/aktarimEsleme';
import { Modal } from '../../bilesenler/Modal';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * SKRS EŞLEME MASASI ÇEVRESİ (1222 hizmet · 1224 bölüm / branş; mockup Ekranlar/Aktarim/skrs_esleme_masasi.html):
 *   EslemeSekmeleri  masanın üç listesi arasında geçiş (Hizmetler → SUT · Bölüm → SKRS klinik · Branş → SKRS branş),
 *   EslemeSeridi     üst şerit - onaylı / bekleyen / aday yok / kuruma özel (yok say) / birleşecek / uygulanan,
 *   EslemePaneli     sağ panel - seçili eski kaydın adayları (puan + dikkat), arama, karar düğmeleri,
 *   EslemeAraclari   araç çubuğu - masayı doldur, yüksek güvenlileri / işaretlileri onayla, Uygula (önizlemeli).
 * Kararı sunucu doğrular (listede olmayan hedef reddedilir); yetki hizmet kartını değiştirebilmek.
 */

const ROTA: Record<EslemeListesi, string> = { hizmet: '/skrs-esleme', bolum: '/skrs-esleme-bolum', brans: '/skrs-esleme-brans' };
const SEKME: [EslemeListesi, string][] = [['hizmet', '💉 Hizmetler → SUT'], ['bolum', '🏥 Bölüm / poliklinik → SKRS klinik'], ['brans', '🩺 Hekim branşı → SKRS branş']];
/** Karar 2'nin adı: hizmette kuruma özel, bölüm / branşta yok say. */
const ozelAdi = (l: EslemeListesi) => (l === 'hizmet' ? 'Kuruma özel' : 'Yok say');
const durumAdi = (l: EslemeListesi, d: number) => ['Bekliyor', 'Onaylı', ozelAdi(l), 'Aday yok', 'Yön ailesi'][d] ?? '';
const YON_AD = ['', 'Sağ', 'Sol', 'Bilateral'];
const KONTRAST_AD: Record<number, string> = { [-1]: '', 0: 'kontrastsız', 1: 'kontrastlı' };

export const kaynaktanListe = (kaynak: string): EslemeListesi =>
  kaynak.endsWith('-bolum') ? 'bolum' : kaynak.endsWith('-brans') ? 'brans' : 'hizmet';

export function EslemeSekmeleri({ liste, git }: { liste: EslemeListesi; git(yol: string): void }) {
  // Ekran sekmesinde: başlık okunur ad, listeler arası geçiş AYNI sekmenin yerine geçer (yeni sekme açılmaz).
  const ekran = useContext(EkranSekmesiBaglami);
  useEffect(() => {
    ekran?.baslik(c(`SKRS Eşleme · ${liste === 'hizmet' ? 'Hizmet' : liste === 'bolum' ? 'Bölüm' : 'Branş'}`), ROTA[liste]);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [liste]);
  const gec = (l: EslemeListesi) => { if (l === liste) return; if (ekran) ekran.kapat(ROTA[l]); else git(ROTA[l]) };
  return (
    <div className="es-sekmeler">
      {SEKME.map(([l, ad]) => (
        <button type="button" key={l} className={l === liste ? 'on' : ''} onClick={() => gec(l)}>{c(ad)}</button>
      ))}
    </div>
  );
}

export function EslemeSeridi({ liste, yenile, onCip }: { liste: EslemeListesi; yenile: number; onCip(i: number): void }) {
  const [o, setO] = useState<EslemeOnizleme | null>(null);
  useEffect(() => { api.eslemeOnizleme(liste).then(y => setO(y.onizleme)).catch(() => setO(null)) }, [yenile, liste]);
  if (!o) return null;
  // Çip sırası listeTanimlari.Stok.ts ile aynı (1 bekleyen · 3 onaylı · 4 aday yok · 5 kuruma özel / yok say · 6 uygulanan
  //   · 7 yön ailesi).
  const kutular: { etiket: string; deger: number; alt: string; cip?: number; vurgu?: 'uyari' | 'hata' }[] = [
    { etiket: 'Onaylı', deger: o.onayli, alt: 'uygulanmayı bekliyor', cip: 3 },
    ...(liste === 'hizmet' ? [{ etiket: 'Yön ailesi', deger: o.aile ?? 0, alt: 'yönlere ayrılacak', cip: 7 }] : []),
    { etiket: 'Bekleyen', deger: o.bekleyen, alt: 'karar verilmedi', cip: 1, vurgu: o.bekleyen > 0 ? 'uyari' : undefined },
    { etiket: 'Aday yok', deger: o.adayYok, alt: liste === 'hizmet' ? 'Bakanlıkta ara ya da kuruma özel' : 'ara ya da yok say',
      cip: 4, vurgu: o.adayYok > 0 ? 'hata' : undefined },
    { etiket: ozelAdi(liste), deger: o.ozel, alt: liste === 'hizmet' ? 'kendi koduyla kalır' : 'bölüm / branş değil', cip: 5 },
    ...(liste === 'hizmet' ? [{ etiket: 'Birleşecek', deger: o.birlesen, alt: 'aynı SUT koduna düşen' }] : []),
    { etiket: 'Uygulanan', deger: o.uygulanmis, alt: liste === 'hizmet' ? 'Bakanlık koduna çevrildi' : 'hekimlere yazıldı', cip: 6 },
  ];
  return (
    <div className="kul-ozet" style={{ gridTemplateColumns: `repeat(${kutular.length}, 1fr)` }}>
      {kutular.map(k => k.cip === undefined ? (
        <div className="k bilgi" key={k.etiket}><span className="bas">{c(k.etiket)}</span>
          <span className="deg">{k.deger.toLocaleString('tr')}</span><span className="alt">{c(k.alt)}</span></div>
      ) : (
        <button type="button" className="k" key={k.etiket} onClick={() => onCip(k.cip!)} title={c('Listeyi bu süzgeçle aç')}>
          <span className="bas">{c(k.etiket)}</span>
          <span className={`deg${k.vurgu ? ` ${k.vurgu}` : ''}`}>{k.deger.toLocaleString('tr')}</span>
          <span className="alt">{c(k.alt)}</span></button>
      ))}
    </div>
  );
}

export function EslemePaneli({ liste, satir, yenile, tazele }: {
  liste: EslemeListesi; satir: ListeSatiri | null; yenile: number; tazele(): void;
}) {
  const id = Number(satir?.id ?? 0);
  const [s, setS] = useState<EslemeSatiri | null>(null);
  const [secili, setSecili] = useState('');
  const [ara, setAra] = useState('');
  const [bulunan, setBulunan] = useState<{ kod: string; ad: string; puan: number }[]>([]);
  useEffect(() => {
    setS(null); setBulunan([]); setAra('');
    if (!id) return;
    api.eslemeSatiri(id).then(y => {
      setS(y.satir);
      const ad: EslemeAdayi[] = JSON.parse(y.satir.adaylar || '[]');
      setSecili(y.satir.secilenKod || ad[0]?.kod || '');
    }).catch(() => setS(null));
  }, [id, yenile]);
  // Arama: yazmayı bekleyip (300 ms) sunucuya sor - hizmette SUT, diğerlerinde bölüm / SKRS branş.
  useEffect(() => {
    if (ara.trim().length < 2) { setBulunan([]); return }
    const t = setTimeout(() => {
      (liste === 'hizmet' ? api.eslemeSutAra(ara.trim(), s?.tur) : api.eslemeHedefAra(liste, ara.trim()))
        .then(y => setBulunan(y.satirlar)).catch(() => setBulunan([]));
    }, 300);
    return () => clearTimeout(t);
  }, [ara, s?.tur, liste]);

  if (!id) return <div className="es-panel sonuk">{c(liste === 'hizmet' ? 'Bir eski hizmet seçin.' : 'Bir eski kayıt seçin.')}</div>;
  if (!s) return <div className="es-panel sonuk">{c('yükleniyor')}…</div>;
  const adaylar: EslemeAdayi[] = JSON.parse(s.adaylar || '[]');
  const aile: EslemeAilesi | null = s.aile ? JSON.parse(s.aile) : null;
  const kilitli = s.uygulandi === 1;
  const karar = (durum: number, kod?: string) => void guvenli(async () => {
    // Yönsüz eski hizmeti tek yönlü koda bağlamak listede yalnız o yönü bırakır - aile önerisi varken sorulur.
    if (durum === 1 && aile && aile.varyant.some(v => v.kod === kod)
        && !(await onay(c('Bu eski hizmet yönsüz; tek yönlü koda bağlanırsa listede yalnız bu yön kalır. "Yönlere ayır" önerilir. Yine de bu koda bağlansın mı?')))) return;
    await api.eslemeKarar(id, durum, kod);
    mesaj(durum === 1 ? `${c('Onaylandı')}: ${kod}` : c(durumAdi(liste, durum)));
    tazele();
  });
  const secenek = (k: { kod: string; ad: string; puan?: number }, alt?: string, dikkat?: string | null) => (
    <label key={k.kod} className={`es-aday${secili === k.kod ? ' on' : ''}`}>
      <input type="radio" name="es-aday" checked={secili === k.kod} disabled={kilitli} onChange={() => setSecili(k.kod)} />
      <span className="es-aday-ic">
        {liste === 'hizmet' && <><b className="es-kod">{k.kod}</b> </>}{k.ad}
        <small>{k.puan !== undefined ? (Number(k.puan) >= 1 && liste !== 'hizmet' ? c('sözlük') : `${c('benzerlik')} %${Math.round(Number(k.puan) * 100)}`) : ''}{alt ? ` · ${alt}` : ''}</small>
        {dikkat && <small className="es-dikkat">⚠ {dikkat}</small>}
      </span>
    </label>
  );
  const baslik = liste === 'hizmet' ? 'Bakanlık adayları (SUT)' : liste === 'bolum' ? 'Bölüm adayları (SKRS kodlu)' : 'SKRS branş adayları';
  return (
    <div className="es-panel">
      <div className="rt-bl"><h5>{c(liste === 'hizmet' ? 'Eski hizmet' : liste === 'bolum' ? 'Eski poliklinik' : 'Eski uzmanlık')}</h5>
        <div className="rt-ad">{s.eskiAd}</div>
        {liste === 'hizmet' && <div className="rt-satir"><span>{c('Eski kod')}</span><b className="es-eski">{s.eskiKod}</b></div>}
        {liste === 'hizmet' && <div className="rt-satir"><span>{c('Tür')}</span><b>{s.tur}</b></div>}
        <div className="rt-satir"><span>{c('Kullanım')}</span>
          <b>{s.kullanim} {c(liste === 'hizmet' ? 'satır' : liste === 'bolum' ? 'başvuru' : 'hekim')}{liste === 'hizmet' ? ` · ${s.fiyatSatiri} ${c('fiyat satırı')}` : ''}</b></div>
        <div className="rt-satir"><span>{c('Durum')}</span><b>{kilitli ? c('Uygulandı') : c(durumAdi(liste, s.durum))}</b></div>
        {s.notlar && <div className="sonuk" style={{ marginTop: 4 }}>{s.notlar}</div>}
      </div>
      <div className="rt-bl"><h5>{c(baslik)}</h5>
        {adaylar.length === 0 && <div className="sonuk">{c(liste === 'hizmet'
          ? 'Otomatik aday yok - aşağıdan arayın ya da kuruma özel yapın.' : 'Aday yok - aşağıdan arayın ya da yok sayın.')}</div>}
        {adaylar.map(a => secenek(a, undefined, a.dikkat))}
        {s.secilenKod && !adaylar.some(a => a.kod === s.secilenKod) && secenek({ kod: s.secilenKod, ad: s.secilenAd }, c('elle seçildi'))}
        {!kilitli && <input className="es-ara" value={ara} onChange={e => setAra(e.target.value)}
                            placeholder={c(liste === 'hizmet' ? 'Bakanlıkta ara (SUT kodu / ad)…' : liste === 'bolum' ? 'Bölüm ara…' : 'SKRS branş ara…')} />}
        {bulunan.filter(b => !adaylar.some(a => a.kod === b.kod)).slice(0, 10).map(b => secenek(b))}
      </div>
      {liste === 'hizmet' && aile && (
        <div className="rt-bl"><h5>{c('Yön ailesi')} · {aile.kok}</h5>
          <div className="sonuk" style={{ fontSize: 10.5, marginBottom: 4 }}>
            {c('Uygulanınca her satır ayrı SUT hizmeti olur (fiyat, protokol ve eski ad kopyalanır); eski hizmet pasife alınır. Banko listeden doğru yönü seçer.')}</div>
          {aile.varyant.map(v => (
            <div className="rt-satir" key={v.kod}>
              <span>{c(YON_AD[v.yon] ?? '')}{KONTRAST_AD[v.kontrastli] ? ` · ${c(KONTRAST_AD[v.kontrastli])}` : ''}</span>
              <b className="es-kod">{v.kod}</b></div>))}
          {!aile.varyant.some(v => v.yon === 3) && (
            <div className="sonuk" style={{ fontSize: 10.5, marginTop: 4 }}>{c('Bilateral kodu yok: iki taraf için sağ ve sol ayrı seçilir.')}</div>)}
        </div>)}
      {liste === 'hizmet' && s.ayniKodlu && (
        <div className="rt-bl"><h5>{c('Aynı SUT koduna bağlanan diğer eskiler')}</h5>
          <div className="sonuk">{s.ayniKodlu}</div>
          <div className="sonuk" style={{ fontSize: 10.5, marginTop: 4 }}>{c('Uygulanınca tek hizmette birleşir; eski kodlar "Eski kod" listesinde kalır.')}</div>
        </div>)}
      {!kilitli && (
        <div className="rt-bl es-karar">
          {aile && <button type="button" className="d bir" onClick={() => karar(4, aile.seed)}>⇆ {c('Yönlere ayır')}</button>}
          <button type="button" className={`d${aile ? '' : ' bir'}`} disabled={!secili} onClick={() => karar(1, secili)}>✓ {c('Onayla')}</button>
          <button type="button" className="d" onClick={() => karar(2)}>🏷 {c(ozelAdi(liste))}</button>
          {s.durum !== 0 && <button type="button" className="d" onClick={() => karar(adaylar.length ? 0 : 3)}>↶ {c('Kararı geri al')}</button>}
        </div>)}
    </div>
  );
}

export function EslemeAraclari({ liste, isaretli, tazele }: { liste: EslemeListesi; isaretli: ListeSatiri[]; tazele(): void }) {
  const [onizleme, setOnizleme] = useState<EslemeOnizleme | null>(null);
  const doldur = () => void guvenli(async () => {
    const y = await api.eslemeDoldur(liste);
    mesaj(`${y.satir} ${c('eski kayıt masada; adaylar tazelendi.')}`);
    tazele();
  });
  const topluOnay = (idler?: number[]) => void guvenli(async () => {
    const soru = idler
      ? `${idler.length} ${c('işaretli satırdan yüksek güvenli ve uyarısız olanlar ilk adayıyla onaylansın mı?')}`
      : c('Bekleyenlerden yüksek güvenli (%80 ve üzeri) ve uyarısız olanlar ilk adayıyla onaylansın mı?');
    if (!(await onay(soru))) return;
    const y = await api.eslemeTopluOnay(0.8, idler, liste);
    mesaj(`${y.onaylanan} ${c('satır onaylandı.')}`);
    tazele();
  });
  const uygula = () => void guvenli(async () => {
    const y = await api.eslemeUygula(liste);
    const s = JSON.parse(y.sonuc || '{}') as { sut?: number; birlesen?: number; ozel?: number; aile?: number; uye?: number; guncellenen?: number };
    mesaj(liste === 'hizmet'
      ? `${c('Uygulandı')}: ${s.sut ?? 0} ${c('SUT hizmeti')}, ${s.aile ?? 0} ${c('yöne ayrılan')} (${s.uye ?? 0} ${c('SUT hizmeti')}), ${s.birlesen ?? 0} ${c('birleşen')}, ${s.ozel ?? 0} ${c('kuruma özel')}.`
      : `${c('Uygulandı')}: ${s.guncellenen ?? 0} ${c('dış hekim güncellendi.')}`);
    setOnizleme(null);
    tazele();
  });
  const idler = isaretli.map(r => Number(r.id)).filter(x => x > 0);
  return (
    <>
      <button type="button" className="d" onClick={doldur} title={c('Eski kayıtları masaya al, adayları yeniden hesapla')}>↻ {c('Masayı doldur')}</button>
      <button type="button" className="d" onClick={() => topluOnay(idler.length ? idler : undefined)}>
        ✓ {idler.length ? `${c('İşaretlileri onayla')} (${idler.length})` : c('Yüksek güvenlileri onayla')}</button>
      <button type="button" className="d bir" onClick={() => void guvenli(async () => setOnizleme((await api.eslemeOnizleme(liste)).onizleme))}>
        ▶ {c('Uygula')}…</button>
      {onizleme && (
        <Modal baslik={c('SKRS eşlemesini uygula')} dar buyutmeYok onKapat={() => setOnizleme(null)}
               alt={<>
                 <button type="button" className="d bir" disabled={onizleme.onayli + onizleme.ozel + (onizleme.aile ?? 0) === 0} onClick={uygula}>▶ {c('Uygula')}</button>
                 <button type="button" className="d" onClick={() => setOnizleme(null)}>✖ {c('Vazgeç')}</button></>}>
          <div className="es-onizle">
            {liste === 'hizmet' ? (<>
              <p><b>{onizleme.onayli}</b> {c('onaylı eski hizmet Bakanlık (SUT) koduna çevrilecek')}
                {onizleme.birlesen > 0 && <> · <b>{onizleme.birlesen}</b> {c('tanesi aynı SUT hizmetinde birleşecek')}</>}.</p>
              {(onizleme.aile ?? 0) > 0 && (
                <p><b>{onizleme.aile}</b> {c('yönsüz eski hizmet yönlerine ayrılacak: her yön / kontrast ayrı SUT hizmeti (fiyat ve protokol kopyalanır), eski hizmet pasif.')}</p>)}
              <p><b>{onizleme.ozel}</b> {c('hizmet kuruma özel olarak kendi koduyla kalacak.')}</p>
              <p><b>{onizleme.belgeSatiri.toLocaleString('tr')}</b> {c('başvuru satırı yeni hizmeti gösterecek (birleşenler asıl hizmete yönlenir).')}</p>
              <p className="sonuk">{c('Eski kodlar hizmetin "Eski kod" listesine yazılır ve aramada bulunur. Hiçbir hizmet silinmez.')}</p>
            </>) : (<>
              <p><b>{onizleme.onayli}</b> {c(liste === 'bolum' ? 'onaylı poliklinik eşlemesine göre dış hekimlerin bölümü (en sık gönderdiği poliklinik) yeniden yazılacak.'
                                                               : 'onaylı uzmanlık eşlemesine göre dış hekimlerin branşı (kart Branş + Medula branş kodu) yazılacak.')}</p>
              <p><b>{onizleme.ozel}</b> {c('kayıt yok sayılacak (bölüm / branş değil).')}</p>
            </>)}
            {(onizleme.bekleyen + onizleme.adayYok) > 0 && (
              <p className="sonuk">{onizleme.bekleyen + onizleme.adayYok} {c('satır karar beklediği için uygulanmayacak.')}</p>)}
          </div>
        </Modal>
      )}
    </>
  );
}
