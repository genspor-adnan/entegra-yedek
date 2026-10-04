import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { DuyuruYonetimSatiri } from '../api/uclar/duyuru';
import { useOturum } from '../kimlik/OturumBaglami';
import { tarihSaat } from '../bilesenler/bicim';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { c } from '../dil/ceviri';
import { DUYURU_DEGISTI, duyuruKartAc, duyuruOkuAc } from '../bilesenler/duyuru/DuyuruOrtak';
import { OnemEtiketi } from '../bilesenler/duyuru/duyuruOnem';
import { talepleriYenile } from '../bilesenler/taleplerim/useTaleplerimOzeti';

/**
 * DUYURULAR `/duyurular` - yönetim listesi (957, mockup Ekranlar/Duyuru/
 * duyuru.html bölüm 3): yayında / zamanlandı / taslak / bitti; okunma oranı,
 * okumayanlar ve hatırlatma. Yetki: duyuru.
 */
type Durum = DuyuruYonetimSatiri['durumKod'] | 'tumu';
const CIPLER: [Durum, string][] = [['yayinda', 'Yayında'], ['zamanlandi', 'Zamanlandı'], ['taslak', 'Taslak'], ['bitti', 'Bitti'], ['tumu', 'Tümü']];

export function Duyurular() {
  const { yetki } = useOturum();
  const [satirlar, setSatirlar] = useState<DuyuruYonetimSatiri[]>([]);
  const [durum, setDurum] = useState<Durum>('yayinda');
  const [secili, setSecili] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setSatirlar((await api.duyuruYonetim()).satirlar); setHata(null) } catch (e) { setHata(hataMetni(e)) }
  }, []);
  useEffect(() => {
    void yukle();
    const d = () => void yukle();
    window.addEventListener(DUYURU_DEGISTI, d);
    return () => window.removeEventListener(DUYURU_DEGISTI, d);
  }, [yukle]);

  const say = (k: Durum) => k === 'tumu' ? satirlar.length : satirlar.filter(s => s.durumKod === k).length;
  const gorunen = satirlar.filter(s => durum === 'tumu' || s.durumKod === durum);
  const sec = satirlar.find(s => s.id === secili) ?? null;

  return (
    <div className="tl-sayfa-dis">
      <div className="sayfabas"><div className="basrow">
        <h1>📣 {c('Duyurular')}</h1>
        <span className="yol">{c('Yönetim › Duyurular · yayınlananlar, zamanlananlar, taslaklar · kim okudu')}</span>
        <div className="sag">
          {yetki('duyuru', 'ekle') && <button type="button" className="d bir" onClick={() => duyuruKartAc()}>＋ {c('Yeni duyuru')}</button>}
        </div>
      </div></div>
      <div className="tl-sayfa">
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="cl-arac tl-arac">
          {CIPLER.map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip tl-cip${durum === k ? ' on' : ''}`} onClick={() => setDurum(k)}>{c(a)} <b>{say(k)}</b></button>
          ))}
        </div>
        <div className={`tl-govde${sec ? ' detayli' : ''}`}>
          <div className="cl-tablo tl-tablo">
            <table className="cl-grid">
              <thead><tr>
                <th>{c('Önem')}</th><th>{c('Başlık')}</th><th>{c('Kime')}</th><th>{c('Yayın')}</th><th>{c('Okunma')}</th><th>{c('Yayınlayan')}</th>
              </tr></thead>
              <tbody>
                {gorunen.map(s => {
                  const oran = s.kisi > 0 ? Math.round(((s.okumaOnayi ? s.okudu : s.gordu) / s.kisi) * 100) : 0;
                  return (
                    <tr key={s.id} className={`tl-satir${secili === s.id ? ' secili' : ''}${s.durumKod === 'bitti' ? ' pasif' : ''}`}
                        onClick={() => setSecili(secili === s.id ? null : s.id)}>
                      <td><OnemEtiketi onem={s.onem} />{s.sabit ? ' 📌' : ''}</td>
                      <td className="cl-tarih"><b>{s.baslik}</b>
                        <small>{[s.okumaOnayi ? c('okuma onayı') : '', s.eposta ? c('e-posta') : '', s.sms ? 'SMS' : '',
                                 s.durumKod === 'zamanlandi' ? `🕒 ${c('zamanlandı')}` : '', s.durumKod === 'taslak' ? c('taslak') : '',
                                 s.surum > 1 ? `${c('sürüm')} ${s.surum}` : ''].filter(Boolean).join(' · ')}</small></td>
                      <td className="cl-kim">{s.hedefOzet} · {s.kisi}</td>
                      <td className="cl-kim">{tarihSaat(s.yayinBas)}{s.yayinBit ? <><br />→ {tarihSaat(s.yayinBit)}</> : ''}</td>
                      <td>{s.durumKod === 'taslak' || s.durumKod === 'zamanlandi' ? '—' : <>
                        <span className="dy-bar"><i style={{ width: `${oran}%` }} /></span>{' '}
                        <b>{s.okumaOnayi ? s.okudu : s.gordu}</b>/{s.kisi} {s.okumaOnayi ? '' : c('gördü')}</>}</td>
                      <td className="cl-kim">{s.adina}</td>
                    </tr>
                  );
                })}
                {gorunen.length === 0 && <tr><td colSpan={6} className="sonuk" style={{ padding: 14, textAlign: 'center' }}>{c('Bu süzgeçte duyuru yok.')}</td></tr>}
              </tbody>
            </table>
          </div>
          {sec && <DuyuruDetay s={sec} onKapat={() => setSecili(null)} yenile={yukle} />}
        </div>
      </div>
    </div>
  );
}

function DuyuruDetay({ s, onKapat, yenile }: { s: DuyuruYonetimSatiri; onKapat(): void; yenile(): Promise<void> }) {
  const { yetki } = useOturum();
  const [kisiler, setKisiler] = useState<{ id: number; ad: string; gordu: string | null; okudu: string | null; okuduSurum: number }[] | null>(null);
  const [liste, setListe] = useState(false);
  useEffect(() => {
    setKisiler(null); setListe(false);
    api.duyuruOkuma(s.id).then(y => setKisiler(y.satirlar)).catch(() => setKisiler([]));
  }, [s.id, s.okudu, s.gordu]);
  const okudu = kisiler?.filter(k => k.okudu).length ?? 0;
  const gordu = kisiler?.filter(k => k.gordu).length ?? 0;
  const okumayan = kisiler?.filter(k => !k.okudu) ?? [];
  const eskiSurum = kisiler?.filter(k => k.okudu && k.okuduSurum < s.surum).length ?? 0;
  const degistir = yetki('duyuru', 'degistir');

  return (
    <div className="tl-detay">
      <div className="tl-grp">
        <h6>{s.sabit ? '📌 ' : ''}{s.baslik}<span style={{ marginLeft: 'auto' }}><OnemEtiketi onem={s.onem} /></span>
          <button type="button" className="cl-bag sonuk" title={c('Kapat')} onClick={onKapat}>✕</button></h6>
        <div className="tl-ic">
          <div className="tl-sat"><span>{c('Kime')}</span><span>{s.hedefOzet} · {s.kisi} {c('kişi')}</span></div>
          {s.okumaOnayi ? <div className="tl-sat"><span>{c('Okudu')}</span><span><b>{okudu}</b> / {s.kisi}{eskiSurum ? ` · ${eskiSurum} ${c('eski sürümü')}` : ''}</span></div> : null}
          <div className="tl-sat"><span>{c('Gördü')}</span><span><b>{gordu}</b> / {s.kisi}</span></div>
          <div className="tl-sat"><span>{s.okumaOnayi ? c('Okumadı') : c('Görmedi')}</span>
            <span>{(s.okumaOnayi ? okumayan.length : s.kisi - gordu)} {c('kişi')} · <button type="button" className="cl-bag" onClick={() => setListe(l => !l)}>{liste ? c('gizle') : c('listeyi gör')}</button></span></div>
          {liste && kisiler && (
            <div className="dy-kisiler">{kisiler.filter(k => s.okumaOnayi ? !k.okudu : !k.gordu).map(k => (
              <span key={k.id}>{k.ad}{k.gordu && !k.okudu ? <small> · {c('gördü')}</small> : null}</span>
            ))}</div>
          )}
          {s.gonderim && <div className="tl-sat"><span>{c('Gönderim')}</span><span>{tarihSaat(s.gonderim)}{s.sms ? ' · SMS' : ''}{s.eposta ? ' · e-posta' : ''}</span></div>}
          <div className="tl-eylem">
            <button type="button" className="d" onClick={() => duyuruOkuAc(s.id)}>👁 {c('Gör')}</button>
            {degistir && s.durumKod === 'yayinda' && (
              <button type="button" className="d" onClick={() => void guvenli(async () => {
                const y = await api.duyuruHatirlat(s.id); talepleriYenile();
                void mesaj(`${y.okumayan} ${c('kişide duyuru yeniden okunmamış olarak görünecek.')}`);
              })}>🔔 {c('Hatırlat')}</button>
            )}
            {degistir && s.durumKod !== 'bitti' && <button type="button" className="d" onClick={() => duyuruKartAc(s.id)}>✎ {c('Düzenle')}</button>}
            {degistir && s.durumKod === 'yayinda' && (
              <button type="button" className="d tl-tehlike" onClick={() => void guvenli(async () => {
                if (!await onay(c('Duyuru yayından kaldırılsın mı? Zilden kalkar, listede "Bitti" olarak durur.'), true)) return;
                await api.duyuruKaldir(s.id); talepleriYenile(); await yenile();
              })}>⏹ {c('Kaldır')}</button>
            )}
          </div>
        </div>
      </div>
      <div className="tl-bilgi">{c('Düzenlenen yayındaki duyuru "güncellendi" etiketiyle yeniden okunmamış olur; okuma onayları silinmez, kim eski sürümü onayladı görünür.')}</div>
    </div>
  );
}
