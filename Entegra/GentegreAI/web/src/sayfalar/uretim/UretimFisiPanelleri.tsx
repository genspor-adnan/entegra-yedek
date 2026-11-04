import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { FisBelgesi } from '../../api/uclar/uretimFisi';
import { useSekmedeAc } from '../../bilesenler/KartAdi';
import { ImzaPenceresi } from '../../bilesenler/ImzaPenceresi';
import { mesaj } from '../../bilesenler/mesaj';
import { tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { mk, tl } from './uretimFisiYardimci';

/**
 * ÜRETİM FİŞİ KARTI - SALT OKUNUR PANELLER (1253): Maliyet (IAS 2 bileşenleri), İzlenebilirlik (soy ağacı, ileri izleme),
 * Denetim İzi (islem_log). Kartın kendi durumuna bağlı olmayan, kendi verisini çeken parçalar; kart yalnız yerleştirir.
 */

export interface MaliyetBilesenleri {
  malzeme: number; iscilik: number; fireNormal: number; fireAnormal: number; yanUrun: number; anaMaliyet: number; birim: number; anaMiktar: number;
}

export function MaliyetPaneli({ m, birimAdi, belgeler }: { m: MaliyetBilesenleri; birimAdi: string; belgeler: FisBelgesi[] }) {
  const ac = useSekmedeAc();
  return (
    <div className="uf-panel">
      <p className="not">{c('IAS 2 / TMS 2: ana ürün maliyeti = direkt malzeme + işçilik / gider + normal fire − yan ürün (net değer). Anormal fire mamule yüklenmez, dönem gideridir. Her seviyede aynı hesap; sarf birim maliyeti seçili yönteme göre.')}</p>
      <table className="uf-dg kucuk">
        <thead><tr><th>{c('Bileşen')}</th><th>{c('Dayanak')}</th><th className="sg">{c('Tutar')}</th><th className="sg">{c('Mamule')}</th><th className="sg">{c('Gidere')}</th></tr></thead>
        <tbody>
          <tr><td>{c('Direkt ilk madde (sarf)')}</td><td className="sl">IAS 2.10</td><td className="sg">{tl(m.malzeme)}</td><td className="sg">{tl(m.malzeme)}</td><td className="sg sl">—</td></tr>
          <tr><td>{c('Normal fire')}</td><td className="sl">IAS 2.10</td><td className="sg">{tl(m.fireNormal)}</td><td className="sg">{tl(m.fireNormal)}</td><td className="sg sl">—</td></tr>
          <tr><td>{c('İşçilik / gider')}</td><td className="sl">IAS 2.12</td><td className="sg">{tl(m.iscilik)}</td><td className="sg">{tl(m.iscilik)}</td><td className="sg sl">—</td></tr>
          <tr className={m.fireAnormal ? 'anormal' : ''}><td>{c('Anormal fire')}</td><td className="sl">IAS 2.16(a)</td><td className="sg">{tl(m.fireAnormal)}</td><td className="sg sl">—</td><td className="sg gider">{tl(m.fireAnormal)}</td></tr>
          <tr><td>{c('Yan ürün (−)')}</td><td className="sl">IAS 2.14</td><td className="sg">{tl(m.yanUrun)}</td><td className="sg">−{tl(m.yanUrun)}</td><td className="sg sl">—</td></tr>
          <tr className="top"><td colSpan={2}>{c('Ana ürün maliyeti')} ({mk(m.anaMiktar)} {birimAdi})</td><td className="sg">{tl(m.anaMaliyet)}</td><td className="sg">{tl(m.anaMaliyet)}</td><td className="sg gider">{tl(m.fireAnormal)}</td></tr>
          <tr className="top"><td colSpan={2}>{c('Birim maliyet')}</td><td className="sg">{tl(m.birim)}</td><td /><td /></tr>
        </tbody>
      </table>
      {belgeler.length > 0 && <>
        <div className="kbas">{c('Kesilen belgeler')}</div>
        <table className="uf-dg kucuk"><thead><tr><th>{c('Belge')}</th><th>{c('Tür')}</th><th>{c('Tarih')}</th><th>{c('Depo')}</th><th className="sg">{c('Tutar')}</th></tr></thead>
          <tbody>{belgeler.map(b => <tr key={b.id}><td><button type="button" className="bag" onClick={() => ac(`/belge/${b.id}`)}>{b.belgeNo ?? `#${b.id}`} ↗</button></td><td>{b.turAdi}</td><td>{tarihSaat(b.belgeTarihi)}</td><td>{b.depoAdi}</td><td className="sg">{tl(b.tutar)}</td></tr>)}</tbody></table>
      </>}
      <div className="bilgi">ℹ {c('Satış / pazarlama / yönetim giderleri ve depolama maliyete girmez (IAS 2.16 b–d). Sabit GÜG normal kapasite dağıtımı ve ay sonu kesinleştirme bu sürümde yok; GÜG işçilik / gider satırı olarak yazılır.')}</div>
    </div>
  );
}

export function IzlenebilirlikPaneli({ fisId, durum, belgeler }: { fisId: number; durum: number; belgeler: FisBelgesi[] }) {
  const [iz, setIz] = useState<Awaited<ReturnType<typeof api.uretimFisIzlenebilirlik>> | null>(null);
  useEffect(() => { if (durum >= 2) void api.uretimFisIzlenebilirlik(fisId).then(setIz).catch(() => setIz(null)) }, [fisId, durum]);
  return (
    <div className="uf-panel">
      <p className="not">{c('ISO 13485 §7.5.9 / 21 CFR 820.184: çıktı lotu hangi girdi lotlarından, hangi iş merkezinde, kim tarafından üretildi; ileri izleme çıktının sonraki hareketleri.')}</p>
      {!iz ? <div className="sl bos">{durum < 2 ? c('Gerçekleşmemiş fişte iz yok.') : c('Yükleniyor…')}</div> : (
        <div className="uf-agac">
          {iz.ciktilar.length === 0 && <div className="dug sl">{c('Çıktı lotu yok (izlemsiz stok).')}</div>}
          {iz.ciktilar.map((l, i) => <div key={i} className="dug cikti">▲ {l.stokKod} · {l.lotNo && <>lot <b>{l.lotNo}</b></>} {l.seriNo && <>seri <b>{l.seriNo}</b></>} · {mk(l.miktar)}{l.skt ? ` · SKT ${tarihSaat(l.skt).slice(0, 10)}` : ''}</div>)}
          {iz.girdiler.map((l, i) => <div key={`g${i}`} className="dug">├─ {l.stokKod} {l.stokAd} · lot <b>{l.lotNo || l.seriNo}</b> · {mk(l.miktar)}{l.tedarikci ? ` · ${c('tedarikçi')} ${l.tedarikci}` : ''}</div>)}
          {iz.fireler.map((l, i) => <div key={`f${i}`} className="dug sl">├─ ✖ {c('fire')} {l.stokKod} · lot <b>{l.lotNo || l.seriNo}</b> · {mk(l.miktar)}</div>)}
          {iz.personel.map((p, i) => <div key={`p${i}`} className="dug sl">├─ {p.operasyon}{p.isMerkezi ? ` · ${p.isMerkezi}` : ''}{p.personel ? ` · ${p.personel}` : ''}</div>)}
          <div className="dug sl">└─ {c('Belgeler')}: {belgeler.map(b => b.belgeNo ?? `#${b.id}`).join(' · ') || '—'}</div>
          {iz.ileri.length > 0 && <>
            <div className="kbas" style={{ marginTop: 10 }}>⇢ {c('İleri izleme (çıktı nereye gitti)')}</div>
            {iz.ileri.map((h, i) => <div key={`i${i}`} className="dug">{tarihSaat(h.tarih)} · {h.turAdi} {h.belgeNo} · {h.taraf || '—'} · {mk(h.miktar)} · {h.lotNo || h.seriNo}</div>)}
          </>}
        </div>)}
    </div>
  );
}

export function DenetimIziPaneli({ fisId }: { fisId: number }) {
  const [gecmis, setGecmis] = useState<{ tarih: string; kullanici: string; islemTipi: number; bilgi: string }[] | null>(null);
  useEffect(() => { void api.uretimFisGecmis(fisId).then(y => setGecmis(y.satirlar)).catch(() => setGecmis([])) }, [fisId]);
  return (
    <div className="uf-panel">
      <div className="kbas">{c('Denetim izi — salt okunur, silinemez')}</div>
      <table className="uf-dg kucuk"><thead><tr><th>{c('Zaman')}</th><th>{c('Kullanıcı')}</th><th>{c('İşlem')}</th><th>{c('Bilgi')}</th></tr></thead>
        <tbody>{(gecmis ?? []).map((g, i) => <tr key={i}><td>{tarihSaat(g.tarih)}</td><td>{g.kullanici}</td><td>{g.islemTipi === 1 ? c('Oluşturdu') : g.islemTipi === 0 ? c('Sildi') : c('Değiştirdi')}</td><td className="sl kucuk uf-bilgi">{g.bilgi}</td></tr>)}
          {gecmis && gecmis.length === 0 && <tr><td colSpan={4} className="sl bos">{c('Kayıt yok.')}</td></tr>}</tbody></table>
    </div>
  );
}

/** KALİTE SERBEST BIRAKMA / RET (e-imza, uretim_fisi_v2.html Kalite › imza kutusu): ortak ImzaPenceresi + sunucu çağrısı.
 *  Kart ve liste üst paneli (UretimGostergeleri) aynı pencereyi kullanır. */
export function FisSerbestPenceresi({ fisId, kontrolTamam, onKapat, onBitti }: { fisId: number; kontrolTamam: boolean; onKapat(): void; onBitti(): void }) {
  return (
    <ImzaPenceresi baslik={c('Kalite kararı — e-imza')} onKapat={onKapat}
      kararlar={[{ deger: 1, ad: `${c('Serbest bırak')}${kontrolTamam ? '' : ` (${c('kontroller tamam değil')})`}`, disabled: !kontrolTamam },
                 { deger: 2, ad: c('Reddet / uygunsuzluk'), tehlike: true }]}
      onaylaMetni={k => (k === 1 ? `✔ ${c('İmzala ve serbest bırak')}` : `⛔ ${c('İmzala ve reddet')}`)}
      aciklama={c('İmza kaydı: ad, zaman, anlam ("kalite serbest bırakma" / "ret"), gerekçe - değiştirilemez (21 CFR Part 11 §11.50).')}
      onImzala={async (gerekce, parola, karar) => { const y = await api.uretimFisSerbest(fisId, karar as 1 | 2, gerekce, parola); mesaj(y.mesaj); onBitti() }} />
  );
}
