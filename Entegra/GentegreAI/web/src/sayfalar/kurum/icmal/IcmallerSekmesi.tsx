import { Fragment, useEffect, useState } from 'react';
import { api } from '../../../api/istemci';
import { hataMetni } from '../../../api/sozlesme';
import type { KurumIcmalKaydi, KurumIcmalSatiri } from '../../../api/uclar/kurumIcmal';
import { para, paraYaz } from '../../../bilesenler/bicim';
import { guvenli, mesaj, onay } from '../../../bilesenler/mesaj';
import { tarihKisa } from '../../hasta/icmal/icmalOrtak';
import { kayitRozeti } from './kurumIcmalOrtak';

/**
 * İCMALLER SEKMESİ (ver2 - mockup Ekranlar/İcmal/kurum_icmal_ver2.html,
 * kullanıcı 10.10.2026: "kurum icmallerini kurum icmali ekranına sekme olarak
 * alalım", "ver2 yi kodla"). Eski "Kurum İcmalleri" listesinin yerini alır.
 *
 * Dönemden BAĞIMSIZ bütün icmal kayıtları. "Yalnız seçili kurum" işaretliyken
 * Dönemdeki Kurumlar'da seçilen kurumlarla süzülür. Satıra tıklamak satırları
 * açar, çift tık ekranı o kurum ve döneme getirir. İcmal oluşturma ve
 * faturalama 289'un uçlarıyla (yeni yazma yolu yok).
 */
type Cip = 'hepsi' | 'hazirlaniyor' | 'faturalandi' | 'tahsil';

export function IcmallerSekmesi({ seciliKurumlar, tazele, kurumlar, varsayilanKurum, donem, kurumSecIstegi, icmalOlustur, ac, yazdir, faturaAc, degisti }: {
  seciliKurumlar: number[];
  /** Ekranın tazeleme sayacı - icmal oluşturulunca liste de yenilenir. */
  tazele: number;
  /** Ekranın dönemindeki kurumlar - icmal oluştururken seçim listesi. */
  kurumlar: { id: number; ad: string }[];
  /** Tek kurum seçiliyse onun id'si: seçim sorulmaz. */
  varsayilanKurum: number;
  /** "01.09 – 30.09" - seçim satırında gösterilir. */
  donem: string;
  /** Üst araç çubuğundan "İcmal Oluştur" basıldı: seçim satırını aç. */
  kurumSecIstegi: number;
  icmalOlustur(kurumId: number, kurumAd: string): Promise<unknown>;
  ac(k: KurumIcmalKaydi): void;
  yazdir(k: KurumIcmalKaydi): void;
  faturaAc(belgeId: number): void;
  /** Faturalama sonrası ekranın özetini de tazelemek için. */
  degisti(): void;
}) {
  const [kayitlar, setKayitlar] = useState<KurumIcmalKaydi[] | null>(null);
  const [hata, setHata] = useState('');
  const [cip, setCip] = useState<Cip>('hepsi');
  const [yalnizSecili, setYalnizSecili] = useState(seciliKurumlar.length > 0);
  const [isaretli, setIsaretli] = useState<number[]>([]);
  const [acik, setAcik] = useState<number | null>(null);
  const [satirlar, setSatirlar] = useState<Record<number, KurumIcmalSatiri[]>>({});
  const [yerel, setYerel] = useState(0);
  // KURUM SEÇİMİ (tek kurum seçili değilken "İcmal Oluştur"): sekmede satır.
  const [secimAcik, setSecimAcik] = useState(false);
  const [secilenKurum, setSecilenKurum] = useState(0);
  useEffect(() => { if (kurumSecIstegi > 0) setSecimAcik(true) }, [kurumSecIstegi]);
  const olustur = (id: number) => {
    const ad = kurumlar.find(k => k.id === id)?.ad ?? '';
    void icmalOlustur(id, ad).then(() => { setSecimAcik(false); setSecilenKurum(0) });
  };
  const suzgec = yalnizSecili ? seciliKurumlar : [];
  const suzgecAnahtar = suzgec.join(',');

  useEffect(() => {
    setHata('');
    api.kurumIcmalKayitlari(suzgecAnahtar ? suzgecAnahtar.split(',').map(Number) : [])
      .then(r => setKayitlar(r.kayitlar)).catch(h => setHata(hataMetni(h)));
  }, [suzgecAnahtar, tazele, yerel]);

  useEffect(() => {
    if (acik == null || satirlar[acik]) return;
    api.kurumIcmalSatirlari(acik).then(r => setSatirlar(s => ({ ...s, [acik]: r.satirlar }))).catch(() => {});
  }, [acik, satirlar]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!kayitlar) return <div className="ki-not">Yükleniyor…</div>;

  const sayi = (c: Cip) => (c === 'hepsi' ? kayitlar.length : kayitlar.filter(k => k.durumKod === c).length);
  const gorunen = cip === 'hepsi' ? kayitlar : kayitlar.filter(k => k.durumKod === cip);
  const secilenler = gorunen.filter(k => isaretli.includes(k.id));
  const faturalanacak = secilenler.filter(k => k.durum === 1);
  const faturali = secilenler.find(k => k.belgeId);
  const hepsi = gorunen.length > 0 && gorunen.every(k => isaretli.includes(k.id));
  const degistir = (id: number) => setIsaretli(x => (x.includes(id) ? x.filter(i => i !== id) : [...x, id]));
  const p = (n: number) => para.format(n);
  const t = (f: (k: KurumIcmalKaydi) => number) => gorunen.reduce((s, k) => s + f(k), 0);

  const faturala = () => void guvenli(async () => {
    if (!faturalanacak.length) return;
    const toplam = faturalanacak.reduce((s, k) => s + k.kurumPayi, 0);
    if (!(await onay(`${faturalanacak.length} icmal faturalansın mı? Her icmal için kuruma TEK fatura kesilir `
          + `(toplam ${paraYaz(toplam)}), satırların kurum payı kapanır.`))) return;
    let kesilen = 0;
    for (const k of faturalanacak) { await api.icmalFaturala(k.id); kesilen++ }
    mesaj(`${kesilen} fatura kesildi.`);
    setIsaretli([]); setYerel(y => y + 1); degisti();
  });

  const cipler: [Cip, string][] = [['hazirlaniyor', 'Hazırlanıyor'], ['faturalandi', 'Faturalandı'], ['tahsil', 'Tahsil edildi'], ['hepsi', 'Tümü']];
  return (
    <>
      <div className="ki-altarac">
        {cipler.map(([c, ad]) => (
          <span key={c} className={'ki-cip' + (cip === c ? ' on' : '')} onClick={() => { setCip(c); setIsaretli([]) }}>
            {ad} <b>{sayi(c)}</b></span>
        ))}
        <span className="ki-ayrac" />
        <label className="ki-cip" title={seciliKurumlar.length ? '' : 'Dönemdeki Kurumlar sekmesinde kurum seçilmedi'}>
          <input type="checkbox" checked={yalnizSecili} disabled={!seciliKurumlar.length}
                 onChange={e => setYalnizSecili(e.target.checked)} /> Yalnız seçili kurum</label>
        <span className="sp" />
        <button title="Seçilen dönemin açık kurum payını icmale bağlar"
                onClick={() => (varsayilanKurum ? olustur(varsayilanKurum) : setSecimAcik(a => !a))}>＋ İcmal Oluştur</button>
        <button className="hi-yesil" disabled={!faturalanacak.length}
                title={faturalanacak.length ? '' : 'Hazırlanan (faturasız) icmal işaretleyin'} onClick={faturala}>
          🧾 Faturala{faturalanacak.length ? ` (${faturalanacak.length})` : ''}</button>
        <button disabled={!faturali} onClick={() => faturali?.belgeId && faturaAc(faturali.belgeId)}>↗ Faturayı Aç</button>
        <button disabled={secilenler.length !== 1} title="Tek icmal işaretleyin"
                onClick={() => secilenler[0] && yazdir(secilenler[0])}>🖨️ İcmali Yazdır</button>
      </div>
      {secimAcik && (
        <div className="ki-secim">
          <span>＋ İcmal oluştur · dönem <b>{donem}</b> · kurum:</span>
          <select value={secilenKurum} onChange={e => setSecilenKurum(Number(e.target.value))}>
            <option value={0}>— kurum seçin —</option>
            {kurumlar.map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select>
          <button className="hi-yesil" disabled={!secilenKurum} onClick={() => olustur(secilenKurum)}>Oluştur</button>
          <button onClick={() => setSecimAcik(false)}>Vazgeç</button>
          {kurumlar.length === 0 && <span className="ki-soluk">Bu dönemde kurum başvurusu yok - üstten dönemi değiştirin.</span>}
        </div>
      )}
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi}
                 onChange={() => setIsaretli(hepsi ? [] : gorunen.map(k => k.id))} /></th>
          <th>Kurum</th><th>Dönem</th><th className="sag">Başvuru</th><th className="sag">Satır</th>
          <th className="sag">Kurum Payı</th><th className="sag">Kesinti</th><th>Fatura No</th><th>Fatura Tarihi</th>
          <th className="sag">Fatura (KDV dahil)</th><th className="sag">Tahsil</th><th>Durum</th></tr></thead>
        <tbody>
          {gorunen.length === 0 && <tr><td colSpan={12} className="bos">İcmal kaydı yok.</td></tr>}
          {gorunen.map(k => {
            const r = kayitRozeti(k);
            const sec = isaretli.includes(k.id);
            return (
              <Fragment key={k.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={() => setAcik(a => (a === k.id ? null : k.id))}
                    onDoubleClick={() => ac(k)} title="Tıkla: satırlar · çift tık: bu kurum ve döneme geç">
                  <td><input type="checkbox" checked={sec} onClick={e => e.stopPropagation()} onChange={() => degistir(k.id)} /></td>
                  <td><span className="ok">{acik === k.id ? '▾' : '▸'}</span><b>{k.kurum}</b></td>
                  <td>{tarihKisa(k.donemBas)} – {tarihKisa(k.donemBit)}</td>
                  <td className="sag">{k.basvuru}</td><td className="sag">{k.satir}</td>
                  <td className="sag">{p(k.kurumPayi)}</td>
                  <td className={'sag' + (k.kesinti > 0.005 ? ' kir' : '')}>{k.kesinti > 0.005 ? p(k.kesinti) : '—'}</td>
                  <td>{k.faturaNo || '—'}</td><td>{tarihKisa(k.faturaTarihi)}</td>
                  <td className="sag">{k.belgeId ? p(k.faturaTutari) : '—'}</td>
                  <td className="sag">{k.tahsil > 0.005 ? p(k.tahsil) : '—'}</td>
                  <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
                </tr>
                {acik === k.id && (
                  <tr className="det"><td colSpan={12}>
                    {!satirlar[k.id] ? 'Yükleniyor…'
                      : satirlar[k.id].length === 0 ? 'Satır yok.'
                      : satirlar[k.id].map(s => `${s.protokolNo} ${s.hasta} · ${s.kalem} ${p(s.tutar)}`)
                          .slice(0, 40).join('  ·  ') + (satirlar[k.id].length > 40 ? `  · +${satirlar[k.id].length - 40} satır` : '')}
                  </td></tr>
                )}
              </Fragment>
            );
          })}
          {gorunen.length > 0 && (
            <tr className="top"><td /><td colSpan={2}>{gorunen.length} icmal · {new Set(gorunen.map(k => k.kurumId)).size} kurum</td>
              <td className="sag">{t(k => k.basvuru)}</td><td className="sag">{t(k => k.satir)}</td>
              <td className="sag">{p(t(k => k.kurumPayi))}</td><td className="sag">{p(t(k => k.kesinti))}</td><td colSpan={2} />
              <td className="sag">{p(t(k => k.faturaTutari))}</td><td className="sag">{p(t(k => k.tahsil))}</td><td /></tr>
          )}
        </tbody>
      </table>
    </>
  );
}
