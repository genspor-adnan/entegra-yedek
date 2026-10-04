import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { guvenli, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';

/**
 * ARIZA EKİPLERİ `/ariza-ekipleri` (955, mockup gelen_talepler.html ④).
 *
 * Kategori → ekip zaten sistemde; burada ekibin KİMLER olduğu ve NÖBETÇİ
 * tanımlanır. Üyesi olan ekipte iş yalnız üyelere düşer (📨 "Bana gelenler",
 * anlık bildirim); üyesiz ekipte arıza yetkisi olan herkese. Acil SMS
 * nöbetçiye (yoksa tüm üyelere).
 */
type Veri = Awaited<ReturnType<typeof api.arizaEkipler>>;

export function ArizaEkipleri() {
  const { yetki } = useOturum();
  const yazar = yetki('ariza', 'degistir');
  const [v, setV] = useState<Veri | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setV(await api.arizaEkipler()); setHata(null) } catch (e) { setHata(hataMetni(e)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow">
        <h1>👥 {c('Arıza Ekipleri')}</h1>
        <span className="yol">{c('Teknik Servis › Arıza Ekipleri · iş kime düşer, acilde kim aranır')}</span>
      </div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="tl-sayfa">
        <div className="tl-bilgi">ℹ {c('Üyesi tanımlı ekibin işi yalnız üyelerine düşer; üyesi olmayan ekipte arıza yetkisi olan herkese. Acil arıza SMS\'i nöbetçiye gider (nöbetçi yoksa tüm üyelere) - nöbetçinin cep telefonu kullanıcı kartında olmalı.')}</div>
        <div className="tl-ekipler">
          {v?.ekipler.map(e => (
            <EkipKarti key={e.ekip} ekip={e} uyeler={v.uyeler.filter(u => u.ekip === e.ekip)} yazar={yazar} yenile={yukle} />
          ))}
        </div>
      </div>
    </div>
  );
}

function EkipKarti({ ekip, uyeler, yazar, yenile }: {
  ekip: Veri['ekipler'][number]; uyeler: Veri['uyeler']; yazar: boolean; yenile(): Promise<void>;
}) {
  const [ara, setAra] = useState('');
  const [sonuc, setSonuc] = useState<{ id: number; ad: string; kod: string }[]>([]);

  useEffect(() => {
    if (ara.trim().length < 2) { setSonuc([]); return }
    const z = window.setTimeout(() => {
      api.arizaKullaniciAra(ara.trim()).then(y => setSonuc(y.satirlar)).catch(() => setSonuc([]));
    }, 300);
    return () => window.clearTimeout(z);
  }, [ara]);

  const kaydet = (id: number, nobetci: boolean) =>
    guvenli(async () => { await api.arizaEkipUyeKaydet(ekip.ekip, id, nobetci); setAra(''); setSonuc([]); await yenile() });

  return (
    <div className="tl-grp tl-ekip">
      <h6>{ekip.ad}<span className="tl-grp-ek">{ekip.acik > 0 ? `${ekip.acik} ${c('açık iş')}` : ''}</span></h6>
      <div className="tl-ic">
        <div className="sonuk tl-kucuk">{c('Kategoriler')}: {ekip.kategoriler || '—'}</div>
        {uyeler.length === 0 && <div className="sonuk">{c('Üye yok - iş arıza yetkisi olan herkese düşer.')}</div>}
        {uyeler.map(u => (
          <div key={u.kullaniciId} className="tl-uye">
            <span>{u.ad}{!u.cepVar && u.nobetci ? <span className="tl-gec" title={c('Cep telefonu yok - SMS gidemez')}> ⚠</span> : null}</span>
            <label className="tl-nobet" title={c('Acil SMS nöbetçiye gider')}>
              <input type="checkbox" checked={u.nobetci === 1} disabled={!yazar}
                     onChange={e => void kaydet(u.kullaniciId, e.target.checked)} /> {c('nöbetçi')}</label>
            {yazar && <button type="button" className="cl-bag sonuk" title={c('Ekipten çıkar')} onClick={async () => {
              if (!await onay(`${u.ad} ${c('ekipten çıkarılsın mı?')}`)) return;
              await guvenli(async () => { await api.arizaEkipUyeSil(ekip.ekip, u.kullaniciId); await yenile() });
            }}>✕</button>}
          </div>
        ))}
        {yazar && (
          <div className="tl-db">
            <input value={ara} onChange={e => setAra(e.target.value)} placeholder={`＋ ${c('Üye ekle: ad ya da kullanıcı kodu')}`} />
            {sonuc.length > 0 && (
              <div className="tl-db-liste">
                {sonuc.filter(s => !uyeler.some(u => u.kullaniciId === s.id)).map(s => (
                  <button key={s.id} type="button" onClick={() => void kaydet(s.id, false)}><b>{s.ad}</b> <small>{s.kod}</small></button>
                ))}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
