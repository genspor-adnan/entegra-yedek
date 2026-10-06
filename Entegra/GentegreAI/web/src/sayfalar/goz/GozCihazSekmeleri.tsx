import { useState } from 'react';
import type { EkSekmeBaglami } from '../../bilesenler/GenForm';
import type { GozCihazOnizleme } from '../../api/uclar/goz';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { GOZ_TETKIK } from '../../bilesenler/goz/gozKodlari';

/**
 * CİHAZ KARTININ EK SEKMELERİ (978, mockup `goz_cihaz_karti_v2.html`).
 *
 *   TetkikEslemeSekmesi  cihazın yapabildiği tetkikler + MWL kodu (düzenlenir)
 *   OlcumEslemeSekmesi   cihaz alanı → ölçüm kodu (düzenlenir)
 *   MesajGunluguSekmesi  son mesajlar + ham gövde (salt okuma)
 *   KalibrasyonSekmesi   demirbaştan kalibrasyon ve iş emirleri (SALT OKUMA)
 *
 * <b>İki eşleme sekmesi jsonb kolonları TABLO olarak düzenler</b>: kullanıcıya
 * JSON metni yazdırmak, bir virgül hatasında cihazın bütün ölçümlerini
 * susturmak demekti. Değer yine aynı kolona (`tetkik_esleme` / `olcum_esleme`)
 * kart kaydedilince yazılır - ikinci bir uç yok.
 */

/** jsonb sunucudan METİN gelebilir; nesne ve metin hâli birlikte karşılanır. */
function jsonCoz<T>(ham: unknown, varsayilan: T): T {
  if (ham === null || ham === undefined || ham === '') return varsayilan;
  if (typeof ham === 'object') return ham as T;
  try {
    const c = JSON.parse(String(ham));
    return (c ?? varsayilan) as T;
  } catch { return varsayilan }
}

type TetkikSatiri = { tetkik: number; cihaz_kod?: string; mwl?: string; goz?: string };

export function TetkikEslemeSekmesi({ b }: { b: EkSekmeBaglami }) {
  const satirlar = jsonCoz<TetkikSatiri[]>(b.deger.tetkikEsleme, []);
  const yaz = (yeni: TetkikSatiri[]) => b.alanYaz('tetkikEsleme', JSON.stringify(yeni));
  const [yeniTetkik, setYeniTetkik] = useState('');

  return (
    <div className="gc-sekme">
      <div className="bilgi">{c('Bu liste iki işi yapar: istem bu cihaza yönlendirilebilir mi '
        + '(görüntüleme ekranındaki cihaz kutusu bunu okur) ve DICOM çalışma listesine ne yazılacak. '
        + 'Eşlemesi olmayan tetkik bu cihaza gönderilemez.')}</div>

      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Tetkik')}</th><th>{c('Cihazdaki kod')}</th><th>{c('MWL kodu')}</th><th>{c('Göz')}</th><th /></tr>
          {satirlar.map((t, i) => (
            <tr key={`${t.tetkik}-${i}`}>
              <td>{c(GOZ_TETKIK[t.tetkik] ?? String(t.tetkik))}</td>
              <td><input className="gc-inp" value={t.cihaz_kod ?? ''}
                         onChange={e => yaz(satirlar.map((x, j) => (j === i ? { ...x, cihaz_kod: e.target.value } : x)))} /></td>
              <td><input className="gc-inp" value={t.mwl ?? ''}
                         onChange={e => yaz(satirlar.map((x, j) => (j === i ? { ...x, mwl: e.target.value } : x)))} /></td>
              <td>
                <select className="gc-inp" value={t.goz ?? 'istem'}
                        onChange={e => yaz(satirlar.map((x, j) => (j === i ? { ...x, goz: e.target.value } : x)))}>
                  <option value="istem">{c('istemden')}</option>
                  <option value="OD">OD</option><option value="OS">OS</option><option value="OU">OU</option>
                </select>
              </td>
              <td><button type="button" className="d" onClick={() => yaz(satirlar.filter((_, j) => j !== i))}>✕</button></td>
            </tr>
          ))}
          {satirlar.length === 0 && (
            <tr><td colSpan={5} className="sonuk">{c('Tetkik eşlemesi yok - bu cihaza istem yönlendirilemez.')}</td></tr>
          )}
        </tbody>
      </table>

      <div className="gc-ekle">
        <select className="gc-inp" value={yeniTetkik} onChange={e => setYeniTetkik(e.target.value)}>
          <option value="">{c('— tetkik seç —')}</option>
          {Object.entries(GOZ_TETKIK)
            .filter(([k]) => !satirlar.some(t => String(t.tetkik) === k))
            .map(([k, ad]) => <option key={k} value={k}>{c(ad)}</option>)}
        </select>
        <button type="button" className="d" disabled={!yeniTetkik}
                onClick={() => { yaz([...satirlar, { tetkik: Number(yeniTetkik), goz: 'istem' }]); setYeniTetkik('') }}>
          ＋ {c('Ekle')}</button>
      </div>
    </div>
  );
}

export function OlcumEslemeSekmesi({ b }: { b: EkSekmeBaglami }) {
  const esleme = jsonCoz<Record<string, string>>(b.deger.olcumEsleme, {});
  const satirlar = Object.entries(esleme);
  const yaz = (yeni: Record<string, string>) => b.alanYaz('olcumEsleme', JSON.stringify(yeni));
  const [alan, setAlan] = useState('');
  const [kod, setKod] = useState('');

  return (
    <div className="gc-sekme">
      <div className="bilgi">{c('Cihazın gönderdiği alan adı, hangi ölçüm olarak kaydedilecek. '
        + 'Eşlenen her alan ölçüm tablosuna bir satır olarak yazılır; trend, eşik bayrağı ve '
        + 'listedeki "ana ölçüm" kolonu bu satırlardan hesaplanır. Eşlenmemiş alan ham kalır.')}</div>

      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Cihaz alanı')}</th><th>{c('Ölçüm kodu')}</th><th /></tr>
          {satirlar.map(([a, k]) => (
            <tr key={a}>
              <td>{a}</td>
              <td><input className="gc-inp" value={k}
                         onChange={e => yaz({ ...esleme, [a]: e.target.value })} /></td>
              <td><button type="button" className="d" onClick={() => {
                const kopya = { ...esleme }; delete kopya[a]; yaz(kopya);
              }}>✕</button></td>
            </tr>
          ))}
          {satirlar.length === 0 && (
            <tr><td colSpan={3} className="sonuk">{c('Ölçüm eşlemesi yok - gelen değerler ham kalır, '
              + 'trend ve eşik kontrolü çalışmaz.')}</td></tr>
          )}
        </tbody>
      </table>

      <div className="gc-ekle">
        <input className="gc-inp" placeholder={c('Cihaz alanı (RNFL_Average)')} value={alan}
               onChange={e => setAlan(e.target.value)} />
        <input className="gc-inp" placeholder={c('Ölçüm kodu (rnfl_ort)')} value={kod}
               onChange={e => setKod(e.target.value)} />
        <button type="button" className="d" disabled={!alan.trim() || !kod.trim()}
                onClick={() => { yaz({ ...esleme, [alan.trim()]: kod.trim() }); setAlan(''); setKod('') }}>
          ＋ {c('Ekle')}</button>
      </div>
    </div>
  );
}

const MESAJ_DURUM: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Bekliyor', sinif: 'uyari' }, 1: { ad: 'İşlendi', sinif: 'olumlu' },
  2: { ad: 'Sahipsiz', sinif: 'uyari' }, 3: { ad: 'Hata', sinif: 'hata' },
};

export function MesajGunluguSekmesi({ r, onIsle }: { r: GozCihazOnizleme | null; onIsle(id: number): void }) {
  const [acik, setAcik] = useState<number | null>(null);
  if (!r) return <div className="sonuk">{c('yükleniyor')}…</div>;
  if (r.mesajlar.length === 0) return <div className="sonuk">{c('Bu cihazdan mesaj gelmemiş.')}</div>;
  return (
    <div className="gc-sekme">
      {/* HAM MESAJ SİLİNMEZ: eşleşme düzeltilince aynı kayıttan yeniden
          işlenir - "cihazdan gelmişti ama kayıp" durumu oluşmasın. */}
      <div className="bilgi">{c('Ham mesaj silinmez: sürücü ya da eşleşme düzeltilince aynı kayıt '
        + 'yeniden işlenir, ölçüm o anda türetilir. Mükerrer yazım veritabanında engelli.')}</div>
      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Zaman')}</th><th>{c('Eşleşme')}</th><th>{c('Durum')}</th><th>{c('Hata')}</th><th /></tr>
          {r.mesajlar.map(m => {
            const d = MESAJ_DURUM[Number(m.durum)] ?? { ad: '—', sinif: 'gri' };
            return (
              <>
                <tr key={m.id}>
                  <td>{tarihSaat(m.zaman)}</td>
                  <td>{m.hastaEslesme || <span className="sonuk">{c('eşleşmedi')}</span>}</td>
                  <td><span className={`rozet ${d.sinif}`}>{c(d.ad)}</span></td>
                  <td className="sonuk">{m.hata || '—'}</td>
                  <td style={{ whiteSpace: 'nowrap' }}>
                    <button type="button" className="d" onClick={() => setAcik(acik === m.id ? null : m.id)}>👁 {c('Ham')}</button>
                    {Number(m.durum) !== 1 && (
                      <button type="button" className="d" onClick={() => onIsle(m.id)}>🔁 {c('İşle')}</button>
                    )}
                  </td>
                </tr>
                {acik === m.id && (
                  <tr key={`${m.id}-ham`}><td colSpan={5}><pre className="gc-ham">{m.ham || c('(ham gövde yok)')}</pre></td></tr>
                )}
              </>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

const KALIB_TUR: Record<number, string> = { 1: 'Kalibrasyon', 2: 'Elektriksel güvenlik', 3: 'Doğrulama' };
const KALIB_SONUC: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Açık', sinif: 'uyari' }, 1: { ad: 'Uygun', sinif: 'olumlu' },
  2: { ad: 'Uygun değil', sinif: 'hata' }, 3: { ad: 'Şartlı uygun', sinif: 'uyari' },
};
const EMIR_TUR: Record<number, string> = {
  1: 'Periyodik bakım', 2: 'Arıza', 3: 'Kurulum', 4: 'Yer değişikliği', 5: 'Hizmetten çıkarma',
};
const EMIR_DURUM: Record<number, { ad: string; sinif: string }> = {
  1: { ad: 'Açık', sinif: 'uyari' }, 2: { ad: 'Devam', sinif: 'uyari' },
  3: { ad: 'Beklemede', sinif: 'gri' }, 4: { ad: 'Kapandı', sinif: 'olumlu' },
  5: { ad: 'İptal', sinif: 'gri' },
};

/**
 * KALİBRASYON / BAKIM — <b>salt okuma</b>, biyomedikal modülünden
 * (kullanıcı kararı 05.10.2026). Bu sekme hiçbir şey yazmaz: ikinci bir bakım
 * geçmişi, iki ayrı "son kalibrasyon tarihi" üretirdi.
 */
export function KalibrasyonSekmesi({ r, onDemirbas }: { r: GozCihazOnizleme | null; onDemirbas(id: number): void }) {
  if (!r) return <div className="sonuk">{c('yükleniyor')}…</div>;
  const k = r.cihaz;
  const demirbasId = Number(k.demirbasId ?? 0);
  if (!demirbasId) {
    return (
      <div className="gc-sekme">
        <div className="uyar">{c('Cihaz demirbaşa bağlı değil: kalibrasyon ve bakım takip edilmiyor. '
          + 'Takip için "Genel" sekmesindeki Demirbaş alanına biyomedikal kaydını yazın - '
          + 'periyot, kalibrasyon ve iş emirleri oradan okunur, burada ikinci kez tutulmaz.')}</div>
      </div>
    );
  }
  const gecikmis = Number(k.kalibrasyonGecikmis) === 1;
  return (
    <div className="gc-sekme">
      <div className="bilgi">{c('Kalibrasyon ve bakım bu kartta tutulmaz; demirbaş kaydından salt okuma gelir. '
        + 'Ekleme ve düzenleme demirbaş kartında yapılır.')}
        {' '}<button type="button" className="d" onClick={() => onDemirbas(demirbasId)}>↗ {c('Demirbaş kartı')}</button>
      </div>

      <div className="gc-ozet">
        <div><span>{c('Demirbaş')}</span><b>{String(k.demirbasKod ?? '—')}</b></div>
        <div><span>{c('Kalibrasyon periyodu')}</span><b>{k.kalibrasyonPeriyotAy ? `${Number(k.kalibrasyonPeriyotAy)} ${c('ay')}` : '—'}</b></div>
        <div><span>{c('Son kalibrasyon')}</span><b>{k.sonKalibrasyon ? tarihYaz(String(k.sonKalibrasyon)) : '—'}</b></div>
        <div><span>{c('Geçerlilik')}</span><b>{k.kalibrasyonGecerlilik
          ? <>{tarihYaz(String(k.kalibrasyonGecerlilik))}{' '}
            <span className={`rozet ${gecikmis ? 'hata' : 'olumlu'}`}>{c(gecikmis ? 'geçti' : 'güncel')}</span></>
          : '—'}</b></div>
        <div><span>{c('Son bakım')}</span><b>{k.sonBakim ? tarihYaz(String(k.sonBakim)) : '—'}</b></div>
        <div><span>{c('Sonraki bakım')}</span><b>{k.sonrakiBakim ? tarihYaz(String(k.sonrakiBakim)) : '—'}</b></div>
        <div><span>{c('Garanti bitiş')}</span><b>{k.garantiBitis ? tarihYaz(String(k.garantiBitis)) : '—'}</b></div>
      </div>

      {gecikmis && (
        <div className="uyar">{c('Kalibrasyon geçerliliği dolmuş. Ölçüm alınmaya devam eder ama '
          + 'görüntüleme listesinde uyarı çıkar: kalibrasyonsuz cihaz ölçümünü eğilime sokmak '
          + 'yanlış "progresyon" üretir.')}</div>
      )}

      <h5 className="gc-bas">{c('Kalibrasyon kayıtları')}</h5>
      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Tarih')}</th><th>{c('Kayıt no')}</th><th>{c('Tür')}</th><th>{c('Sonuç')}</th>
            <th>{c('Geçerlilik')}</th><th>{c('Referans cihaz')}</th><th>{c('Belirsizlik')}</th><th>{c('Yapan')}</th></tr>
          {r.kalibrasyonlar.map(x => {
            const s = KALIB_SONUC[Number(x.sonuc)] ?? { ad: '—', sinif: 'gri' };
            return (
              <tr key={x.id}>
                <td>{tarihYaz(x.tarih)}</td><td>{x.kayitNo || '—'}</td>
                <td>{c(KALIB_TUR[Number(x.tur)] ?? '—')}</td>
                <td><span className={`rozet ${s.sinif}`}>{c(s.ad)}</span></td>
                <td>{x.gecerlilik ? tarihYaz(x.gecerlilik) : '—'}</td>
                <td>{x.referansCihaz || '—'}</td>
                <td>{x.belirsizlik != null ? `±${x.belirsizlik} ${x.belirsizlikBirim}` : '—'}</td>
                <td>{x.yapan || x.firma || '—'}</td>
              </tr>
            );
          })}
          {r.kalibrasyonlar.length === 0 && (
            <tr><td colSpan={8} className="sonuk">{c('Kalibrasyon kaydı yok.')}</td></tr>
          )}
        </tbody>
      </table>

      <h5 className="gc-bas">{c('Bakım / arıza iş emirleri')}</h5>
      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Tarih')}</th><th>{c('İş emri')}</th><th>{c('Tür')}</th><th>{c('Durum')}</th>
            <th>{c('Konu')}</th><th>{c('Hasta etkilendi')}</th></tr>
          {r.isEmirleri.map(e => {
            const d = EMIR_DURUM[Number(e.durum)] ?? { ad: '—', sinif: 'gri' };
            return (
              <tr key={e.id}>
                <td>{e.bildirimZamani ? tarihYaz(e.bildirimZamani) : '—'}</td>
                <td>{e.isEmriNo || '—'}</td>
                <td>{c(EMIR_TUR[Number(e.tur)] ?? '—')}</td>
                <td><span className={`rozet ${d.sinif}`}>{c(d.ad)}</span></td>
                <td>{e.arizaMetni || e.yapilanIs || '—'}</td>
                <td>{Number(e.hastaEtkilendi) === 1 ? <span className="rozet hata">{c('evet')}</span> : '—'}</td>
              </tr>
            );
          })}
          {r.isEmirleri.length === 0 && (
            <tr><td colSpan={6} className="sonuk">{c('İş emri yok.')}</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
