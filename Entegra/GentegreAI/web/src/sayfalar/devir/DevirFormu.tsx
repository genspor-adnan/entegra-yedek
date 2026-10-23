import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { ApiHatasi, hataMetni } from '../../api/sozlesme';
import type { Devir, DevirGirdisi, DevirTuru } from '../../api/uclar/devir';
import { para, tutarOku } from '../../bilesenler/bicim';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';

/**
 * DEVİR / AÇILIŞ BAKİYESİ FORMU - her tür (mockup Ekranlar/devir_girisi.html; cari için 1156
 * CariDevirPenceresi'nin genelleştirilmişi). Kart penceresi (DevirPenceresi) ve Finans › Devir
 * Girişi sayfası aynı formu çizer.
 *
 * Kayıt biçimi türden bağımsız (tutar · para · kur · vade · belge no · açıklama) - SUNUCUDA
 * hesabın "Devir" (tür 2) hareketi olur. Türe göre yalnız giriş değişir:
 *  · cari      yön + tek tutar ya da açık belgeler (her satır kendi vadesiyle)
 *  · kasa      kasadaki para (hep giriş, hesabın para birimi)
 *  · banka     bakiye + yön (alacak = bizim para / borç = KMH), "Bankadan al" (API bakiyesi)
 *  · pos       gün başına brüt · komisyon · net · valör, ya da tek tutar
 *  · kredi     kalan ana para (+ kalan taksit, sonraki taksit bilgi)
 *  · kredikarti dönem borcu (son ödeme vadesiyle) + ekstreye yansımamış borç
 */
export type Satir = { belgeNo: string; belgeTarihi: string; vade: string; tutar: string; doviz: string; kur: string; aciklama: string; ters: boolean };
export const bosSatir = (doviz = 'TL'): Satir => ({ belgeNo: '', belgeTarihi: '', vade: '', tutar: '', doviz, kur: '', aciklama: '', ters: false });
const iso = (t: string | null | undefined) => (t ? t.slice(0, 10) : '');
const sayiMetni = (n: number) => n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 4 });
const ekleGun = (t: string, g: number) => { const d = new Date(t + 'T00:00:00'); d.setDate(d.getDate() + g); return d.toISOString().slice(0, 10) };
const bugun = () => new Date().toISOString().slice(0, 10);

/** "18.11.2025" / "2025-11-18" -> yyyy-mm-dd; olmazsa ''. */
export function tarihOku(m: string): string {
  const s = (m ?? '').trim();
  let x = s.match(/^(\d{1,2})[./-](\d{1,2})[./-](\d{4})$/);
  if (x) return `${x[3]}-${x[2].padStart(2, '0')}-${x[1].padStart(2, '0')}`;
  x = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
  return x ? `${x[1]}-${x[2]}-${x[3]}` : '';
}

export const TUR_AD: Record<DevirTuru, string> = { cari: 'Cari', kasa: 'Kasa', banka: 'Banka', pos: 'POS', kredi: 'Kredi', kredikarti: 'Kredi Kartı' };

type Gun = { tarih: string; brut: string; komisyon: string; valor: string };

export function DevirFormu({ tur, id, onKaydedildi, onKapat, onYuklendi }: {
  tur: DevirTuru | 'hesap'; id: number; onKaydedildi?(): void; onKapat?(): void; onYuklendi?(v: Devir): void;
}) {
  const [v, setV] = useState<Devir | null>(null);
  const [hata, setHata] = useState('');
  const [tarih, setTarih] = useState('');
  const [yon, setYon] = useState<'B' | 'A'>('B');
  const [sekil, setSekil] = useState<'tek' | 'belge'>('tek');
  const [satirlar, setSatirlar] = useState<Satir[]>([bosSatir()]);
  const [gunler, setGunler] = useState<Gun[]>([]);
  const [kk, setKk] = useState({ donem: '', sonOdeme: '', disi: '' });
  const [kredi, setKredi] = useState({ kalanTaksit: '', sonrakiTaksit: '' });
  const [kaydediliyor, setKaydediliyor] = useState(false);
  const [yapistirAcik, setYapistirAcik] = useState(false);
  const yerel = v?.dovizler[0] ?? 'TL';
  const t: DevirTuru = v?.tur ?? (tur === 'hesap' ? 'kasa' : tur);
  const h = v?.hesap;
  const hesapDoviz = h?.doviz ?? yerel;

  useEffect(() => {
    setV(null); setHata('');
    api.devirOku(tur, id).then(d => {
      setV(d); onYuklendi?.(d);
      setTarih(iso(d.varsayilanTarih));
      const dv = d.hesap.doviz || d.dovizler[0] || 'TL';
      if (d.satirlar.length > 0) {
        const hepsiEksi = d.satirlar.every(s => s.tutar < 0);
        const y = hepsiEksi ? 'A' : 'B';
        setYon(y);
        const posGun = d.tur === 'pos' && d.satirlar.some(s => s.belgeNo.startsWith('POS '));
        setSekil(d.satirlar.length === 1 && !d.satirlar[0].belgeNo ? 'tek' : 'belge');
        setSatirlar(d.satirlar.map(s => ({
          belgeNo: s.belgeNo, belgeTarihi: '', vade: iso(s.vade), tutar: sayiMetni(Math.abs(s.tutar)), doviz: s.doviz,
          kur: s.doviz === (d.dovizler[0] ?? 'TL') ? '' : sayiMetni(s.kur), aciklama: s.aciklama === 'Devir' ? '' : s.aciklama,
          ters: (y === 'B') !== (s.tutar > 0),
        })));
        if (posGun) setGunler(d.satirlar.map(s => {
          const m = s.aciklama.match(/Brüt ([\d.,]+) · komisyon ([\d.,]+)/);
          return { tarih: tarihOku(s.belgeNo.slice(4)) || iso(s.tarih), brut: m ? m[1] : sayiMetni(s.tutar), komisyon: m ? m[2] : '0,00', valor: iso(s.vade) };
        }));
        if (d.tur === 'kredikarti') setKk({
          donem: sayiMetni(Math.abs(d.satirlar.find(s => s.belgeNo === 'Dönem borcu')?.tutar ?? 0)),
          sonOdeme: iso(d.satirlar.find(s => s.belgeNo === 'Dönem borcu')?.vade),
          disi: sayiMetni(Math.abs(d.satirlar.find(s => s.belgeNo === 'Ekstre dışı')?.tutar ?? 0)),
        });
        if (d.tur === 'kredi') {
          const m = d.satirlar[0].aciklama.match(/Kalan taksit (\d+)/);
          setKredi({ kalanTaksit: m ? m[1] : '', sonrakiTaksit: iso(d.satirlar[0].vade) });
        }
      } else { setSatirlar([bosSatir(dv)]); setGunler([]); setKk({ donem: '', sonOdeme: '', disi: '' }); setKredi({ kalanTaksit: '', sonrakiTaksit: '' }) }
    }).catch(e => setHata(hataMetni(e)));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tur, id]);

  const degis = (i: number, d: Partial<Satir>) => setSatirlar(l => l.map((s, j) => (j === i ? { ...s, ...d } : s)));
  const kurGetir = (i: number, doviz: string) => {
    if (!tarih || doviz === yerel) { degis(i, { doviz, kur: '' }); return }
    degis(i, { doviz });
    api.devirKur(doviz, tarih).then(k => { if (k.kur) degis(i, { kur: sayiMetni(k.kur) }) }).catch(() => { /* elle girilir */ });
  };
  // Hesabın para birimi döviz ise kur devir tarihinden (bilgi; sunucu kendisi bulur).
  const [hesapKur, setHesapKur] = useState<number | null>(null);
  useEffect(() => {
    if (!v || t === 'cari' || hesapDoviz === yerel || !tarih) { setHesapKur(null); return }
    api.devirKur(hesapDoviz, tarih).then(k => setHesapKur(k.kur)).catch(() => setHesapKur(null));
  }, [v, t, hesapDoviz, yerel, tarih]);

  const isaret = (s: Satir) => (yon === 'B' ? 1 : -1) * (s.ters ? -1 : 1);
  const etkin = sekil === 'tek' ? satirlar.slice(0, 1) : satirlar;
  const dolu = etkin.filter(s => tutarOku(s.tutar) !== 0);
  const tlKarsiligi = (s: Satir) => tutarOku(s.tutar) * (s.doviz === yerel ? 1 : tutarOku(s.kur) || 0) * isaret(s);
  const toplam = dolu.reduce((x, s) => x + tlKarsiligi(s), 0);
  const ilkSonra = v?.ilkHareket && tarih && v.ilkHareket.slice(0, 10) < tarih;
  const riskYuzde = v && t === 'cari' && (h?.riskLimiti ?? 0) > 0 && toplam > 0 ? Math.round((100 * toplam) / (h!.riskLimiti!)) : null;

  // POS gün satırları → net / valör.
  const oran = h?.komisyonOrani ?? 0;
  const gunNet = (g: Gun) => tutarOku(g.brut) - tutarOku(g.komisyon);
  const gunEkle = (tarihG = '') => setGunler(l => [...l, { tarih: tarihG, brut: '', komisyon: '', valor: '' }]);
  const gunDegis = (i: number, d: Partial<Gun>) => setGunler(l => l.map((g, j) => {
    if (j !== i) return g;
    const y = { ...g, ...d };
    if (d.brut !== undefined && oran > 0) y.komisyon = sayiMetni(Math.round(tutarOku(d.brut) * oran) / 100);
    if (d.tarih !== undefined && d.tarih && !g.valor) y.valor = ekleGun(d.tarih, h?.valorGun ?? 0);
    return y;
  }));
  const posToplam = gunler.reduce((x, g) => x + gunNet(g), 0);

  const yapistir = (metin: string) => {
    if (t === 'pos' && sekil === 'belge') {
      // tarih · brüt · [komisyon] · [valör]
      const yeni = metin.split(/\r?\n/).map(l => l.split('\t')).filter(p => p.length >= 2 && tarihOku(p[0]) && tutarOku(p[1]) !== 0)
        .map(p => ({ tarih: tarihOku(p[0]), brut: sayiMetni(tutarOku(p[1])),
                     komisyon: sayiMetni(p[2] && tutarOku(p[2]) ? tutarOku(p[2]) : Math.round(tutarOku(p[1]) * oran) / 100),
                     valor: tarihOku(p[3] ?? '') || ekleGun(tarihOku(p[0]), h?.valorGun ?? 0) }));
      if (yeni.length === 0) { mesaj("Uygun satır yok: tarih · brüt · komisyon · valör sütunlarını kopyalayın."); return }
      setGunler(l => [...l.filter(g => tutarOku(g.brut) !== 0), ...yeni]); setYapistirAcik(false); return;
    }
    // belge no · belge tarihi · vade · tutar · para
    const yeni = metin.split(/\r?\n/).map(l => l.split('\t')).filter(p => p.length >= 4 && tutarOku(p[3]) !== 0)
      .map(p => ({ ...bosSatir(yerel), belgeNo: p[0].trim(), belgeTarihi: tarihOku(p[1] ?? ''), vade: tarihOku(p[2] ?? ''),
                   tutar: sayiMetni(Math.abs(tutarOku(p[3]))), ters: tutarOku(p[3]) < 0, doviz: (p[4] ?? '').trim().toUpperCase() || yerel }));
    if (yeni.length === 0) { mesaj("Uygun satır yok: Excel'de belge no · belge tarihi · vade · tutar · para sütunlarını seçip kopyalayın."); return }
    const tum = [...satirlar.filter(s => tutarOku(s.tutar) !== 0), ...yeni];
    setSatirlar(tum); setSekil('belge'); setYapistirAcik(false);
    tum.forEach((s, i) => {
      if (s.doviz !== yerel && !tutarOku(s.kur) && tarih)
        api.devirKur(s.doviz, tarih).then(k => { if (k.kur) degis(i, { kur: sayiMetni(k.kur) }) }).catch(() => { /* elle girilir */ });
    });
  };

  /** Türün girişini sunucu satırlarına çevirir. */
  const govdeyiKur = (): DevirGirdisi[] => {
    const ilk = satirlar[0] ?? bosSatir(hesapDoviz);
    switch (t) {
      case 'cari':
        return dolu.map(s => ({
          belgeNo: s.belgeNo || undefined, belgeTarihi: s.belgeTarihi || null, vade: s.vade || null,
          tutar: Math.abs(tutarOku(s.tutar)) * isaret(s), doviz: s.doviz,
          kur: s.doviz === yerel ? null : (tutarOku(s.kur) || null), aciklama: s.aciklama || undefined,
        }));
      case 'kasa':
        return tutarOku(ilk.tutar) ? [{ tutar: Math.abs(tutarOku(ilk.tutar)), doviz: hesapDoviz, aciklama: ilk.aciklama || 'Açılış - kasa bakiyesi' }] : [];
      case 'banka':
        return tutarOku(ilk.tutar) ? [{ tutar: Math.abs(tutarOku(ilk.tutar)) * (yon === 'B' ? 1 : -1), doviz: hesapDoviz, aciklama: ilk.aciklama || 'Açılış - banka bakiyesi' }] : [];
      case 'pos':
        if (sekil === 'belge')
          return gunler.filter(g => gunNet(g) !== 0).map(g => ({
            belgeNo: `POS ${g.tarih ? tarihKisa(g.tarih) : ''}`.trim(), vade: g.valor || null, tutar: gunNet(g), doviz: hesapDoviz,
            aciklama: `Brüt ${sayiMetni(tutarOku(g.brut))} · komisyon ${sayiMetni(tutarOku(g.komisyon))}`,
          }));
        return tutarOku(ilk.tutar) ? [{ tutar: Math.abs(tutarOku(ilk.tutar)), doviz: hesapDoviz, vade: ilk.vade || null, aciklama: ilk.aciklama || 'Açılış - valörde bekleyen POS' }] : [];
      case 'kredi':
        return tutarOku(ilk.tutar) ? [{ tutar: Math.abs(tutarOku(ilk.tutar)), doviz: hesapDoviz, vade: kredi.sonrakiTaksit || null,
          aciklama: [kredi.kalanTaksit ? `Kalan taksit ${kredi.kalanTaksit}${h?.krediVadeAy ? ` / ${h.krediVadeAy}` : ''}` : '', ilk.aciklama || 'Açılış - kalan ana para'].filter(Boolean).join(' · ') }] : [];
      case 'kredikarti': {
        const l: DevirGirdisi[] = [];
        if (tutarOku(kk.donem)) l.push({ belgeNo: 'Dönem borcu', tutar: Math.abs(tutarOku(kk.donem)), doviz: hesapDoviz, vade: kk.sonOdeme || null, aciklama: 'Açılış - ekstre dönem borcu' });
        if (tutarOku(kk.disi)) l.push({ belgeNo: 'Ekstre dışı', tutar: Math.abs(tutarOku(kk.disi)), doviz: hesapDoviz, aciklama: 'Açılış - ekstreye yansımamış harcama' });
        return l;
      }
    }
  };

  const kaydet = async (zorla = false, kaldir = false) => {
    if (!v) return;
    const govde = kaldir ? [] : govdeyiKur();
    if (!kaldir && govde.length === 0) { mesaj('Tutar girin.'); return }
    setKaydediliyor(true);
    try {
      await api.devirKaydet(v.tur, id, { tarih, satirlar: govde, zorla });
      onKaydedildi?.(); onKapat?.();
    } catch (e) {
      const engel = e instanceof ApiHatasi ? (e.hata.engel as { kod?: string } | undefined) : undefined;
      if (engel?.kod === 'ILK_HAREKET' && await onay(`${hataMetni(e)}\n\nYine de kaydedilsin mi?`)) {
        setKaydediliyor(false); await kaydet(true, kaldir); return;
      }
      mesaj(hataMetni(e));
    } finally { setKaydediliyor(false) }
  };

  const mevcut = (v?.satirlar.length ?? 0) > 0;
  const seg = (deger: string, secenekler: [string, string][], ayarla: (k: string) => void) => (
    <div className="dv-seg">{secenekler.map(([k, ad]) => (
      <button key={k} type="button" className={deger === k ? 'on' : ''} onClick={() => ayarla(k)}>{ad}</button>))}</div>
  );
  const bankaFark = v && t === 'banka' && h?.bankaBakiye != null
    ? h.bankaBakiye - (v.hareketBakiye - v.satirlar.reduce((x, s) => x + s.tutar, 0) + (tutarOku(satirlar[0]?.tutar ?? '') * (yon === 'B' ? 1 : -1))) : null;

  return (
    <div className="dv-form">
      <style>{STIL}</style>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!v ? (!hata && <div className="yukleniyor">{c('Yükleniyor')}…</div>) : v.delphiKaynakli ? (
        <div className="dv-govde">
          <div className="uyari-kutusu">{c("Veri kaynağı Delphi: devirler Delphi'den aktarılır (yıl devri), burada girilmez.")}</div>
          <DelphiDevri v={v} />
        </div>
      ) : (
        <div className="dv-govde">
          <div className="dv-f4">
            <label>{c('Devir tarihi')} *<input type="date" value={tarih} max={bugun()} onChange={e => setTarih(e.target.value)} />
              <small>{c('Varsayılan: hareket başlangıcının bir gün öncesi')}</small></label>
            {t === 'cari' && <div>{c('Yön')} *{seg(yon, [['B', `🔴 ${c('Borçlu')}`], ['A', `🟢 ${c('Alacaklı')}`]], k => setYon(k as 'B' | 'A'))}
              <small>{yon === 'B' ? c('bize borcu var') : c('biz borçluyuz')}</small></div>}
            {t === 'banka' && <div>{c('Yön')} *{seg(yon, [['B', `🟢 ${c('Alacak bakiye')}`], ['A', `🔴 ${c('Borç (KMH)')}`]], k => setYon(k as 'B' | 'A'))}
              <small>{yon === 'B' ? c('bizim paramız') : c('bankaya borç')}</small></div>}
            {t === 'cari' && <div>{c('Giriş şekli')}{seg(sekil, [['tek', c('Tek tutar')], ['belge', c('Açık belgelerle')]], k => setSekil(k as 'tek' | 'belge'))}</div>}
            {t === 'pos' && <div>{c('Giriş şekli')}{seg(sekil, [['tek', c('Tek tutar')], ['belge', c('Gün başına')]], k => setSekil(k as 'tek' | 'belge'))}</div>}
            {t !== 'cari' && <label>{c('Para birimi')}<input value={hesapDoviz} disabled /><small>{c('hesabın para birimi')}{hesapKur ? ` · ${c('kur')} ${sayiMetni(hesapKur)}` : ''}</small></label>}
            {(t === 'cari' && sekil === 'tek') || t === 'kasa' || t === 'banka' || (t === 'pos' && sekil === 'tek') || t === 'kredi'
              ? <label>{c('Açıklama')}<input value={satirlar[0]?.aciklama ?? ''} placeholder={c('Açılış bakiyesi (eski program)')} onChange={e => degis(0, { aciklama: e.target.value })} /></label> : null}
          </div>

          {/* ---------------------------------------------------- türe özgü giriş -- */}
          {t === 'cari' && sekil === 'tek' && (
            <div className="dv-f4">
              <label>{c('Tutar')} *<input className="sag" value={satirlar[0]?.tutar ?? ''} onChange={e => degis(0, { tutar: e.target.value })} placeholder="0,00" /></label>
              <label>{c('Para birimi')}<select value={satirlar[0]?.doviz ?? yerel} onChange={e => kurGetir(0, e.target.value)}>
                {v.dovizler.map(d => <option key={d}>{d}</option>)}</select></label>
              <label>{c('Kur')}<input className="sag" value={satirlar[0]?.doviz === yerel ? '1,0000' : satirlar[0]?.kur ?? ''}
                disabled={satirlar[0]?.doviz === yerel} onChange={e => degis(0, { kur: e.target.value })} /></label>
              <label>{c('Vade')}<input type="date" value={satirlar[0]?.vade ?? ''} onChange={e => degis(0, { vade: e.target.value })} />
                <small>{(h?.vadeGun ?? 0) > 0 && tarih ? `${c('Boş')}: ${tarihKisa(ekleGun(tarih, h!.vadeGun!))} (${c('vade')} ${h!.vadeGun} ${c('gün')})` : c('Boş: devir tarihi')}</small></label>
            </div>
          )}
          {t === 'cari' && sekil === 'belge' && (
            <>
              <table className="detay-tablo dv-tablo">
                <thead><tr><th>#</th><th>{c('Belge no')}</th><th>{c('Belge tarihi')}</th><th>{c('Vade')}</th><th className="hiza-sag">{c('Tutar')}</th>
                  <th>{c('Para')}</th><th className="hiza-sag">{c('Kur')}</th><th className="hiza-sag">{c('TL karşılığı')}</th><th>{c('Ters')}</th><th>{c('Açıklama')}</th><th /></tr></thead>
                <tbody>
                  {satirlar.map((s, i) => (
                    <tr key={i} className={s.ters ? 'dv-ters' : undefined}>
                      <td>{i + 1}</td>
                      <td><input value={s.belgeNo} onChange={e => degis(i, { belgeNo: e.target.value })} /></td>
                      <td><input type="date" value={s.belgeTarihi} onChange={e => degis(i, { belgeTarihi: e.target.value })} /></td>
                      <td><input type="date" value={s.vade} onChange={e => degis(i, { vade: e.target.value })} /></td>
                      <td><input className="sag" value={s.tutar} onChange={e => degis(i, { tutar: e.target.value })} placeholder="0,00" /></td>
                      <td><select value={s.doviz} onChange={e => kurGetir(i, e.target.value)}>{v.dovizler.map(d => <option key={d}>{d}</option>)}</select></td>
                      <td><input className="sag" value={s.doviz === yerel ? '1,0000' : s.kur} disabled={s.doviz === yerel} onChange={e => degis(i, { kur: e.target.value })} /></td>
                      <td className="hiza-sag">{tutarOku(s.tutar) ? para.format(tlKarsiligi(s)) : ''}</td>
                      <td title={c('Avans / fazla ödeme: ters yönde yazılır')}><input type="checkbox" checked={s.ters} onChange={e => degis(i, { ters: e.target.checked })} /></td>
                      <td><input value={s.aciklama} onChange={e => degis(i, { aciklama: e.target.value })} /></td>
                      <td><button type="button" className="d mini" title={c('Satırı sil')}
                                  onClick={() => setSatirlar(l => (l.length > 1 ? l.filter((_, j) => j !== i) : [bosSatir(yerel)]))}>🗑</button></td>
                    </tr>
                  ))}
                </tbody>
                <tfoot><tr className="genel"><td colSpan={7}>{dolu.length} {c('kalem')}</td>
                  <td className="hiza-sag"><b>{para.format(Math.abs(toplam))} {toplam > 0.005 ? 'B' : toplam < -0.005 ? 'A' : ''}</b></td><td colSpan={3} /></tr></tfoot>
              </table>
              <div className="dv-arac">
                <button type="button" className="d mini" onClick={() => setSatirlar(l => [...l, bosSatir(yerel)])}>＋ {c('Satır ekle')}</button>
                <button type="button" className={'d mini' + (yapistirAcik ? ' on' : '')} onClick={() => setYapistirAcik(a => !a)}>📋 {c("Excel'den yapıştır")}</button>
                <span className="dv-not">{c('Sütunlar: belge no · belge tarihi · vade · tutar · para. Eksi tutar ters (avans) satır olur. Boş vade = devir tarihi + carinin vade günü.')}</span>
              </div>
            </>
          )}
          {(t === 'kasa' || t === 'banka' || (t === 'pos' && sekil === 'tek') || t === 'kredi') && (
            <div className="dv-f4">
              <label>{t === 'kasa' ? c('Kasadaki para (devir tarihinde)') : t === 'banka' ? c('Bakiye (devir tarihinde)') : t === 'pos' ? c('Bankaya geçmemiş POS tutarı') : c('Kalan ana para (devir tarihinde)')} *
                <input className="sag" value={satirlar[0]?.tutar ?? ''} onChange={e => degis(0, { tutar: e.target.value })} placeholder="0,00" />
                {t === 'banka' && h?.bankaBakiye != null && (
                  <small><a className="lnk" onClick={() => { degis(0, { tutar: sayiMetni(Math.abs(h.bankaBakiye!)) }); setYon(h.bankaBakiye! >= 0 ? 'B' : 'A') }}>⇐ {c('Bankadan al')}</a> ({para.format(h.bankaBakiye)}{h.bankaBakiyeZaman ? ` · ${tarihKisa(h.bankaBakiyeZaman)}` : ''})</small>)}
              </label>
              {t === 'pos' && <label>{c('Valör (bankaya geçeceği gün)')}<input type="date" value={satirlar[0]?.vade ?? ''} onChange={e => degis(0, { vade: e.target.value })} />
                <small>{h?.bagliHesap ? `${c('Aktarım hesabı')}: ${h.bagliHesap}` : ''}</small></label>}
              {t === 'kredi' && <>
                <label>{c('Kalan taksit')}<input className="sag" value={kredi.kalanTaksit} onChange={e => setKredi(k => ({ ...k, kalanTaksit: e.target.value }))} />
                  <small>{h?.krediVadeAy ? `/ ${h.krediVadeAy} ${c('ay')}` : ''}{h?.krediFaiz ? ` · ${c('faiz')} %${sayiMetni(h.krediFaiz)}` : ''}</small></label>
                <label>{c('Sonraki taksit tarihi')}<input type="date" value={kredi.sonrakiTaksit} onChange={e => setKredi(k => ({ ...k, sonrakiTaksit: e.target.value }))} /></label>
              </>}
              {t === 'kasa' && <div className="dv-ipucu">{c('Kasaya özgü: devir hep giriştir; Gün Sonu Sayımı kasayı devirden başlatır, fark hesabı devirden sonrasını sayar.')}</div>}
              {t === 'kredi' && <div className="dv-ipucu">{c("Krediye özgü: devir ana paradır; ödeme planı (taksit no, ana para / faiz ayrımı) kartın Ödeme Planı sekmesinden, faiz ayrı yazılır.")}</div>}
            </div>
          )}
          {t === 'pos' && sekil === 'belge' && (
            <>
              <table className="detay-tablo dv-tablo">
                <thead><tr><th>#</th><th>{c('Gün')}</th><th className="hiza-sag">{c('Brüt')}</th><th className="hiza-sag">{c('Komisyon')}</th>
                  <th className="hiza-sag">{c('Net')}</th><th>{c('Valör')}</th><th /></tr></thead>
                <tbody>
                  {gunler.map((g, i) => (
                    <tr key={i}>
                      <td>{i + 1}</td>
                      <td><input type="date" value={g.tarih} onChange={e => gunDegis(i, { tarih: e.target.value })} /></td>
                      <td><input className="sag" value={g.brut} onChange={e => gunDegis(i, { brut: e.target.value })} placeholder="0,00" /></td>
                      <td><input className="sag" value={g.komisyon} onChange={e => gunDegis(i, { komisyon: e.target.value })} /></td>
                      <td className="hiza-sag">{gunNet(g) ? para.format(gunNet(g)) : ''}</td>
                      <td><input type="date" value={g.valor} onChange={e => gunDegis(i, { valor: e.target.value })} /></td>
                      <td><button type="button" className="d mini" onClick={() => setGunler(l => l.filter((_, j) => j !== i))}>🗑</button></td>
                    </tr>
                  ))}
                  {gunler.length === 0 && <tr><td colSpan={7} className="bos">{c('Gün ekleyin ya da Excel\'den yapıştırın (tarih · brüt · komisyon · valör).')}</td></tr>}
                </tbody>
                <tfoot><tr className="genel"><td colSpan={2}>{gunler.length} {c('gün')}</td>
                  <td className="hiza-sag">{para.format(gunler.reduce((x, g) => x + tutarOku(g.brut), 0))}</td>
                  <td className="hiza-sag">{para.format(gunler.reduce((x, g) => x + tutarOku(g.komisyon), 0))}</td>
                  <td className="hiza-sag"><b>{para.format(posToplam)}</b></td><td colSpan={2} /></tr></tfoot>
              </table>
              <div className="dv-arac">
                <button type="button" className="d mini" onClick={() => gunEkle()}>＋ {c('Gün ekle')}</button>
                <button type="button" className={'d mini' + (yapistirAcik ? ' on' : '')} onClick={() => setYapistirAcik(a => !a)}>📋 {c("Excel'den yapıştır")}</button>
                <span className="dv-not">{c("POS'a özgü: gün başına satır; komisyon karttaki orandan")} (%{sayiMetni(oran)}), {c('valör karttaki valör gününden')} (+{h?.valorGun ?? 0}). {c('POS aktarımı devir satırını kapatır.')}</span>
              </div>
            </>
          )}
          {t === 'kredikarti' && (
            <div className="dv-f4">
              <label>{c('Dönem borcu (devir tarihinde)')} *<input className="sag" value={kk.donem} onChange={e => setKk(k => ({ ...k, donem: e.target.value }))} placeholder="0,00" /></label>
              <label>{c('Son ödeme tarihi')}<input type="date" value={kk.sonOdeme} onChange={e => setKk(k => ({ ...k, sonOdeme: e.target.value }))} />
                <small>{h?.hesapKesimGunu ? `${c('kesim')} ${h.hesapKesimGunu} · ${c('son ödeme')} ${h.sonOdemeGunu}` : ''}</small></label>
              <label>{c('Ekstreye yansımamış borç')}<input className="sag" value={kk.disi} onChange={e => setKk(k => ({ ...k, disi: e.target.value }))} placeholder="0,00" /></label>
              <label>{c('Limit')}<input value={h?.limit ? para.format(h.limit) : '—'} disabled />
                <small>{h?.limit ? `${c('kullanılabilir')} ${para.format(h.limit - tutarOku(kk.donem) - tutarOku(kk.disi))}` : ''}</small></label>
              <div className="dv-ipucu" style={{ gridColumn: '1 / -1' }}>{c('Kredi kartına özgü: iki tutar - ekstre borcu (son ödeme vadesiyle) ve ekstreye yansımamış harcama.')}</div>
            </div>
          )}
          {yapistirAcik && (
            <textarea className="dv-yapistir" autoFocus
                      placeholder={t === 'pos' ? c("Excel'de tarih · brüt · komisyon · valör sütunlarını kopyalayın, buraya Ctrl+V.") : c("Excel'de satırları kopyalayın (Ctrl+C), buraya tıklayıp Ctrl+V'ye basın - belge no · belge tarihi · vade · tutar · para.")}
                      onPaste={e => { e.preventDefault(); yapistir(e.clipboardData.getData('text')) }} />
          )}

          {/* ----------------------------------------------------------- kontroller -- */}
          <div className="dv-kontrol">
            <h5>{c('Kontroller')}</h5>
            <div className={ilkSonra ? 'dv-k uy' : 'dv-k ok'}>{ilkSonra
              ? `⚠ ${c('Hesabın')} ${tarihKisa(v.ilkHareket!)} ${c('tarihli hareketi var - devir ondan sonra kalır (kaydederken onay istenir)')}`
              : `✓ ${v.ilkHareket ? `${c('Devir tarihi ilk hareketten')} (${tarihKisa(v.ilkHareket)}) ${c('önce')}` : c('Hesabın henüz hareketi yok')}`}</div>
            <div className={mevcut ? 'dv-k bilgi' : 'dv-k ok'}>{mevcut
              ? `ℹ ${c('Daha önce devir girilmiş')} (${v.satirlar.length} ${c('satır')}) — ${c('kaydetmek devri baştan yazar')}`
              : `✓ ${c('Daha önce devir girilmemiş')}`}</div>
            {riskYuzde !== null && (
              <div className={riskYuzde > 100 ? 'dv-k kir' : riskYuzde >= 70 ? 'dv-k uy' : 'dv-k ok'}>
                {riskYuzde > 100 ? '⛔' : riskYuzde >= 70 ? '⚠' : '✓'} {c('Devir toplamı risk limitinin')} %{riskYuzde}'{c('i')}</div>)}
            {t !== 'cari' && (h?.acilisBakiye ?? 0) !== 0 && (
              <div className="dv-k uy">⚠ {c('Karttaki "Açılış Bakiyesi" alanı')} ({para.format(h!.acilisBakiye!)}) {c('bu devirle kapanır - alan artık okunmaz')}</div>)}
            {bankaFark !== null && (
              <div className={Math.abs(bankaFark) > 0.005 ? 'dv-k uy' : 'dv-k ok'}>{Math.abs(bankaFark) > 0.005
                ? `⚠ ${c('Banka API bakiyesi ile devir + hareketler arasında')} ${para.format(bankaFark)} ${c('fark')}`
                : `✓ ${c('Banka API bakiyesi devir + hareketlerle tutuyor')}`}</div>)}
            {v.delphiSatirlari.length > 0 && <div className="dv-k bilgi">ℹ {c("Delphi'den aktarılmış devir satırları ayrıca duruyor; bu form onlara dokunmaz.")}</div>}
            <div className="dv-k bilgi">ℹ {t === 'cari' ? c('Muhasebe fişi kesilmez - açılış fişi mali müşavirle yapılır.')
              : c('Muhasebe: açılış fişi mali müşavirle; devir hesabın "Devir" hareketidir, ekstre ve bakiyeler buradan beslenir.')}</div>
          </div>

          <div className="dv-dugmeler">
            <span className="sp" />
            {mevcut && <button type="button" className="d teh" disabled={kaydediliyor}
              onClick={async () => { if (await onay('Devir silinsin mi?', true)) void kaydet(false, true) }}>🗑 {c('Devri Kaldır')}</button>}
            {onKapat && <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>}
            <button type="button" className="d bir" disabled={kaydediliyor} onClick={() => void kaydet()}>💾 {c('Devri Kaydet')}</button>
          </div>
        </div>
      )}
    </div>
  );
}

function DelphiDevri({ v }: { v: Devir }) {
  if (v.delphiSatirlari.length === 0) return <div className="sonuk">{c('Delphi devri yok.')}</div>;
  return (
    <table className="detay-tablo">
      <thead><tr><th>{c('Tarih')}</th><th>{c('Belge')}</th><th>{c('Para')}</th><th className="hiza-sag">{c('Tutar')}</th><th className="hiza-sag">{c('TL')}</th></tr></thead>
      <tbody>{v.delphiSatirlari.map(s => (
        <tr key={s.id}><td>{tarihKisa(s.tarih)}</td><td>{s.belgeNo || s.aciklama}</td><td>{s.doviz}</td>
          <td className="hiza-sag">{para.format(Math.abs(s.tutar))} {s.tutar > 0 ? 'B' : 'A'}</td><td className="hiza-sag">{para.format(s.yerel)}</td></tr>
      ))}</tbody>
    </table>
  );
}

const STIL = `
.dv-govde { display:flex; flex-direction:column; gap:12px; }
.dv-f4 { display:grid; grid-template-columns:repeat(4, minmax(0, 1fr)); gap:10px 14px; }
.dv-f4 > label, .dv-f4 > div { display:flex; flex-direction:column; gap:3px; font-size:11px; color:var(--soluk); }
.dv-f4 input, .dv-f4 select { font-size:12px; }
.dv-f4 small { font-size:10px; color:var(--soluk); }
.dv-f4 .sag, .dv-tablo .sag { text-align:right; }
.dv-seg { display:inline-flex; border:1px solid var(--cizgi); border-radius:4px; overflow:hidden; align-self:flex-start; }
.dv-seg button { border:0; border-right:1px solid var(--cizgi2); background:var(--yuz); padding:4px 10px; font-size:11.5px; cursor:pointer; color:var(--yazi2); }
.dv-seg button:last-child { border-right:0; }
.dv-seg button.on { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.dv-tablo input, .dv-tablo select { width:100%; font-size:11.5px; }
.dv-tablo tr.dv-ters td { background:var(--okzem); }
.dv-tablo .bos { text-align:center; color:var(--soluk); padding:12px; }
.dv-arac { display:flex; gap:6px; align-items:center; }
.dv-not, .dv-ipucu { font-size:10.5px; color:var(--soluk); }
.dv-ipucu { padding:6px 8px; background:var(--yuz2); border-radius:4px; align-self:end; }
.dv-yapistir { min-height:70px; border:2px dashed var(--vurgu); border-radius:4px; padding:8px; font-size:12px; background:var(--yuz2); }
.dv-kontrol h5 { margin:0 0 6px; font-size:10.5px; color:var(--soluk); text-transform:uppercase; letter-spacing:.3px; }
.dv-k { font-size:11.5px; padding:5px 8px; border-radius:4px; margin-bottom:4px; }
.dv-k.ok { background:var(--okzem); color:var(--ok); }
.dv-k.uy { background:var(--uyarizem); color:var(--uyari); }
.dv-k.kir { background:var(--hatazem); color:var(--hata); }
.dv-k.bilgi { background:var(--yuz2); color:var(--vurgu); }
.dv-dugmeler { display:flex; gap:6px; align-items:center; border-top:1px solid var(--cizgi2); padding-top:8px; }
.dv-dugmeler .sp { flex:1; }
@media (max-width: 900px) { .dv-f4 { grid-template-columns:1fr 1fr; } }
`;
