import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { type BelgeYaniti, hataMetni } from '../../api/sozlesme';
import type { OnayAdimi } from '../../api/uclar/onay';
import { Modal } from '../Modal';
import { c } from '../../dil/ceviri';
import { TEKLIF_DURUMLARI } from '../../sayfalar/belgeSabitleri';

/**
 * TEKLİF İÇ ONAYI (mockup Ekranlar/Teklif/teklif_ic_onay.html, kullanıcı 10.11.2026 "teklife iç onayı aktar"):
 * dış (müşteri) onayı yok. Hazırlayan onaylayanı seçer ve "Onaya Sun" der; motorun `teklif.satis` akışı tek basamak
 * (sahip türü 5 "Hazırlayan seçer"). Onaylayan Onayımdakiler'de Onayla / Reddet / Düzeltme iste (bilgi iste).
 * Teklif durumu: 6 Onayda · 7 Onaylandı · 8 Düzeltme istendi · 9 Reddedildi (yalnız motor yazar).
 */

/** Onaya sunulabilecek durumlar: hazırlanıyor, düzeltme istendi, reddedildi, sunuldu (müşteriye gitmeden önce geri alınmış). */
export const ONAYA_SUNULABILIR = new Set([1, 8, 9]);
/** Kalemlerin kilitli olduğu iç onay durumları (sunucu da 422 ile korur). */
export const TEKLIF_ONAY_KILIDI = new Set([6, 7]);

/** Teklif kartı araç çubuğundaki onay düğmesi: durumdan hangisi çizilir - saf, test edilir. */
export function teklifOnayDugmesi(durum: number, kayitli: boolean): 'onaya-sun' | 'geri-cek' | null {
  if (!kayitli) return null;
  if (durum === 6) return 'geri-cek';
  return ONAYA_SUNULABILIR.has(durum) ? 'onaya-sun' : null;
}

const ADIM_DURUM: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Bekliyor', sinif: 'uyari' }, 1: { ad: 'Onaylandı', sinif: 'ok' }, 2: { ad: 'Reddedildi', sinif: 'hata' },
  3: { ad: 'Düzeltme istendi', sinif: 'uyari' }, 4: { ad: 'Sözlü onay', sinif: 'ok' }, 5: { ad: 'Geri çekildi', sinif: 'gri' },
};

const zaman = (iso: string | null) => {
  if (!iso) return '—';
  const d = new Date(iso);
  return isNaN(d.getTime()) ? iso : d.toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

/** +N takvim günü, yyyy-MM-dd. */
const gunSonra = (n: number) => {
  const d = new Date(); d.setDate(d.getDate() + n);
  return d.toISOString().slice(0, 10);
};

export function OnayaSunPenceresi({ belgeId, belgeNo, cariUnvan, onKapat, onTamam }: {
  belgeId: number; belgeNo: string; cariUnvan: string;
  onKapat(): void;
  onTamam(y: BelgeYaniti): void;
}) {
  const [kisiler, setKisiler] = useState<{ id: number; ad: string }[] | null>(null);
  const [onaylayanId, setOnaylayanId] = useState(0);
  const [sonTarih, setSonTarih] = useState(gunSonra(2));
  const [not, setNot] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let iptal = false;
    api.onayYetkiliKullanicilar('belge.teklif_onay')
      .then(l => { if (!iptal) { setKisiler(l); if (l.length === 1) setOnaylayanId(l[0].id) } })
      .catch(h => { if (!iptal) { setKisiler([]); setHata(hataMetni(h)) } });
    return () => { iptal = true };
  }, []);

  const gonder = async () => {
    if (!onaylayanId) { setHata(c('Onaylayacak kişiyi seçin.')); return }
    setCalisiyor(true); setHata(null);
    try {
      const y = await api.belgeOnayaSun(belgeId, { onaylayanId, sonTarih: sonTarih || null, not });
      onTamam(y);
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor(false) }
  };

  return (
    <Modal baslik={`${c('Onaya Sun')} — ${belgeNo || `#${belgeId}`}${cariUnvan ? ` · ${cariUnvan}` : ''}`} onKapat={onKapat} enUst dar
      alt={<>
        <button className="d bir" disabled={calisiyor || !onaylayanId} onClick={() => void gonder()}>✍️ {c('Onaya Sun')}</button>
        <button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Vazgeç')}</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="alan-izgara" data-testid="onaya-sun">
        <label className="alan">
          <span className="etiket">{c('Onaylayacak kişi')} <span className="zorunlu">*</span></span>
          <select value={onaylayanId} onChange={e => setOnaylayanId(Number(e.target.value))} disabled={kisiler === null}>
            <option value={0}>{kisiler === null ? c('Yükleniyor…') : kisiler.length === 0 ? c('Yetkili kullanıcı yok (belge.teklif_onay)') : c('Seçiniz…')}</option>
            {(kisiler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select>
        </label>
        <label className="alan">
          <span className="etiket">{c('Son tarih')}</span>
          <input type="date" value={sonTarih} onChange={e => setSonTarih(e.target.value)} />
        </label>
        <label className="alan" style={{ gridColumn: '1 / -1' }}>
          <span className="etiket">{c('Not (onaylayana)')}</span>
          <textarea rows={3} value={not} onChange={e => setNot(e.target.value)} placeholder={c('Ör. bayi fiyatı uygulandı, iskonto %12…')} />
        </label>
      </div>
      <div className="not" style={{ marginTop: 8 }}>
        {c('Gönderince teklif "Onayda" olur, kalemler kilitlenir. Onaylayanın vekâleti varsa vekile düşer; "Düzeltme iste" derse teklif size döner.')}
      </div>
    </Modal>
  );
}

/** Teklif kartı "Onay" sekmesi: motordaki zincir (onay + basamaklar). */
export function TeklifOnaySekmesi({ belgeId, teklifDurum, tazele }: { belgeId: number; teklifDurum: number; tazele: number }) {
  const [veri, setVeri] = useState<{ onay: { id: number; durum: number; baslama?: string; baslatanAd?: string | null } | null;
                                      adimlar: OnayAdimi[] } | null>(null);
  const [adlar, setAdlar] = useState<Record<number, string>>({});
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    if (!belgeId) { setVeri({ onay: null, adimlar: [] }); return }
    let iptal = false;
    api.onayZinciri(30, belgeId)
      .then(y => { if (!iptal) setVeri(y) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    api.onayYetkiliKullanicilar('belge.teklif_onay')
      .then(l => { if (!iptal) setAdlar(Object.fromEntries(l.map(k => [k.id, k.ad]))) })
      .catch(() => { /* ad çözülemezse kimlik numarası görünür */ });
    return () => { iptal = true };
  }, [belgeId, tazele]);

  if (!belgeId) return <div className="bilgi-kutusu">{c('Onay, teklif kaydedildikten sonra sunulur.')}</div>;
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (veri === null) return <div className="bilgi-kutusu">{c('Yükleniyor…')}</div>;

  const durumAd = TEKLIF_DURUMLARI[String(teklifDurum)] ?? String(teklifDurum);
  return (
    <div className="kutu" data-testid="teklif-onay">
      <div className="deger-serit" style={{ marginBottom: 8 }}>
        <span className="sonuk">{c('Teklif durumu')}:</span> <span className={`rozet ${teklifDurum === 7 || teklifDurum === 3 ? 'ok' : teklifDurum === 6 || teklifDurum === 8 ? 'uyari' : teklifDurum === 9 || teklifDurum === 4 ? 'hata' : 'gri'}`}>{durumAd}</span>
      </div>
      {!veri.onay && <div className="bilgi-kutusu">{c('Bu teklif henüz onaya sunulmadı. Araç çubuğundan "Onaya Sun".')}</div>}
      {veri.onay && (() => {
        const bekleyen = veri.adimlar.find(a => a.durum === 0 || a.durum === 3);
        const kime = (a: OnayAdimi) => a.atananAd || (a.atananId ? adlar[a.atananId] ?? `#${a.atananId}` : '');
        return (<>
          {/* KİM SUNDU / KİMDE (kullanıcı 10.11.2026: "kime onaya gönderdiğimi göremedim") */}
          <div className="bilgi-kutusu" data-testid="teklif-onay-ozet" style={{ marginBottom: 8 }}>
            <b>{c('Onaya sunan')}:</b> {veri.onay.baslatanAd || '—'}{veri.onay.baslama ? ` · ${zaman(veri.onay.baslama)}` : ''}
            {bekleyen && <> &nbsp;·&nbsp; <b>{c('Onay bekleyen')}:</b> {kime(bekleyen) || c('(rol basamağı)')}{bekleyen.termin ? ` · ${c('son')} ${zaman(bekleyen.termin).slice(0, 10)}` : ''}</>}
          </div>
          <table className="detay-tablo">
          <thead>
            <tr><th style={{ width: 40 }}>#</th><th>{c('Basamak')}</th><th style={{ width: 170 }}>{c('Kime')}</th><th style={{ width: 130 }}>{c('Durum')}</th>
                <th style={{ width: 170 }}>{c('Karar veren')}</th><th style={{ width: 140 }}>{c('Zaman')}</th><th style={{ width: 110 }}>{c('Son tarih')}</th><th>{c('Not')}</th></tr>
          </thead>
          <tbody>
            {veri.adimlar.map(a => {
              const d = ADIM_DURUM[a.durum] ?? { ad: String(a.durum), sinif: 'gri' };
              return (
                <tr key={a.id}>
                  <td>{a.sira}</td><td>{a.ad}</td>
                  <td>{kime(a) || '—'}</td>
                  <td><span className={`rozet ${d.sinif}`}>{c(d.ad)}</span></td>
                  <td>{a.kararVerenId ? a.kararVerenAd || adlar[a.kararVerenId] || `#${a.kararVerenId}` : '—'}</td>
                  <td>{zaman(a.kararZamani)}</td>
                  <td>{a.termin ? zaman(a.termin).slice(0, 10) : '—'}</td>
                  <td>{a.gerekce || ''}</td>
                </tr>
              );
            })}
          </tbody>
          </table>
        </>);
      })()}
      <div className="not" style={{ marginTop: 8 }}>
        {c('Müşteriye sunum onaya bağlı değil: Onaylandı sonrası "Müşteriye Sun" (PDF / yazdır) ve müşteri cevabı "Durumu Değiştir" ile işlenir.')}
      </div>
    </div>
  );
}
