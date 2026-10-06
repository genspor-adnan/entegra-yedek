import { useState } from 'react';
import type { EkSekmeBaglami } from '../../bilesenler/GenForm';
import type { GozCihazOnizleme } from '../../api/uclar/goz';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { GOZ_TETKIK, GOZ_CIHAZ_PROTOKOL } from '../../bilesenler/goz/gozKodlari';
import { api } from '../../api/istemci';

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

/** `ayarlar` jsonb'sinin tek alanını okuyup yazan küçük kutu. */
function AyarAlani({ ayarlar, yaz, ad, baslik, ipucu, genislik, secenekler }: {
  ayarlar: Record<string, unknown>;
  yaz(ad: string, deger: string): void;
  ad: string; baslik: string; ipucu?: string; genislik?: number;
  secenekler?: [string, string][];
}) {
  const deger = ayarlar[ad] === null || ayarlar[ad] === undefined ? '' : String(ayarlar[ad]);
  return (
    <label className="gc-alan" style={genislik ? { width: genislik } : undefined}>
      <span>{c(baslik)}</span>
      {secenekler
        ? (
          <select className="gc-inp" value={deger} onChange={e => yaz(ad, e.target.value)}>
            {secenekler.map(([v, et]) => <option key={v} value={v}>{c(et)}</option>)}
          </select>
        )
        : <input className="gc-inp" value={deger} placeholder={ipucu} onChange={e => yaz(ad, e.target.value)} />}
    </label>
  );
}

/**
 * BAĞLANTI AYARLARI (mockup "Bağlantı" sekmesi) — `ayarlar` jsonb'sini FORM
 * olarak düzenler ve <b>protokole göre</b> alan kümesini değiştirir: dosya
 * cihazında DICOM kutuları çizilmez, kullanıcı boş altı alana bakmaz.
 *
 * Protokol ve MWL kart alanları olduğu için burada DEĞİL "Tanım" sekmesindedir;
 * bu sekme yalnız o protokolün ayrıntısını ve hasta eşleştirmesini tutar.
 */
export function BaglantiAyarSekmesi({ b, onSina }: { b: EkSekmeBaglami; onSina?: () => void }) {
  const ayarlar = jsonCoz<Record<string, unknown>>(b.deger.ayarlar, {});
  const yaz = (ad: string, deger: string) => {
    const yeni = { ...ayarlar };
    if (deger === '') delete yeni[ad]; else yeni[ad] = deger;
    b.alanYaz('ayarlar', JSON.stringify(yeni));
  };
  const protokol = Number(b.deger.protokol ?? 0);
  const dicom = protokol === 1;
  const dosya = protokol === 3;

  return (
    <div className="gc-sekme">
      <div className="bilgi">{c('Bu sekmedeki alanlar protokole göre değişir ve tek bir ayar '
        + 'nesnesinde saklanır; seçili protokol')}: <b>{c(GOZ_CIHAZ_PROTOKOL[protokol] ?? '—')}</b>.
        {' '}{c('Protokolü ve MWL desteğini "Tanım" sekmesinden değiştirin.')}</div>

      {dicom && (
        <>
          <h5 className="gc-bas">{c('DICOM')}</h5>
          <div className="gc-izgara">
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="ip" baslik="Cihaz IP" ipucu="192.168.1.40" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="port" baslik="Port" ipucu="104" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="ae" baslik="Cihaz AE başlığı" ipucu="SPECTRALIS1" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="bizim_ae" baslik="Bizim AE başlığı" ipucu="GENOTIP" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="timeout_sn" baslik="Zaman aşımı (sn)" ipucu="30" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="deneme" baslik="Yeniden deneme" ipucu="3" />
          </div>
        </>
      )}

      {dosya && (
        <>
          <h5 className="gc-bas">{c('Klasör')}</h5>
          <div className="gc-izgara">
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="klasor" baslik="İzlenen klasör" ipucu="\\sunucu\oct\out" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="desen" baslik="Dosya deseni" ipucu="*.xml" />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="islenen" baslik="İşlenen dosya"
                       secenekler={[['', '— seçilmedi —'], ['arsiv', 'arşiv klasörüne taşı'],
                                    ['sil', 'sil'], ['birak', 'yerinde bırak']]} />
            <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="kod_sayfa" baslik="Kod sayfası"
                       secenekler={[['', '— seçilmedi —'], ['UTF-8', 'UTF-8'],
                                    ['windows-1254', 'windows-1254'], ['ISO-8859-9', 'ISO-8859-9']]} />
          </div>
        </>
      )}

      {!dicom && !dosya && (
        <div className="bilgi">{c('Seçili protokolde ek bağlantı ayarı yok; adres "Tanım" '
          + 'sekmesindeki Bağlantı alanına yazılır (seri port, API adresi).')}</div>
      )}

      <h5 className="gc-bas">{c('Hasta eşleştirme')}</h5>
      <div className="gc-izgara">
        <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="anahtar" baslik="Anahtar"
                   secenekler={[['', 'protokol no (varsayılan)'], ['protokol', 'protokol no'],
                                ['hasta_no', 'hasta no (H)'], ['tc', 'TC kimlik no'],
                                ['barkod', 'barkod']]} />
        <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="yedek_anahtar" baslik="Yedek anahtar"
                   secenekler={[['', '— yok —'], ['protokol', 'protokol no'],
                                ['hasta_no', 'hasta no (H)'], ['tc', 'TC kimlik no']]} />
        <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="eslesmezse" baslik="Eşleşmezse"
                   secenekler={[['', 'kuyrukta beklet (varsayılan)'], ['beklet', 'kuyrukta beklet'],
                                ['hata', 'hata olarak işaretle']]} />
        <AyarAlani ayarlar={ayarlar} yaz={yaz} ad="gun_penceresi" baslik="Gün penceresi" ipucu="1" />
      </div>
      {/* VARSAYILAN "BEKLET": ölçümü yanlış hastaya yazmak, hiç yazmamaktan
          kötüdür - kuyrukta bekleyen mesaj elle eşlenip yeniden işlenir. */}
      <div className="bilgi">{c('Eşleşme kurulamazsa varsayılan davranış kuyrukta bekletmektir: '
        + 'ölçümü yanlış hastaya yazmak, hiç yazmamaktan kötüdür. Bekleyen mesaj '
        + '"Mesaj günlüğü" sekmesinden elle eşlenip yeniden işlenir.')}</div>

      <h5 className="gc-bas">{c('Son sınama')}</h5>
      <div className="gc-ozet">
        <div><span>{c('Zaman')}</span><b>{b.deger.sonSinama ? tarihSaat(b.deger.sonSinama) : c('hiç sınanmadı')}</b></div>
        <div><span>{c('Sonuç')}</span><b>{String(b.deger.sonSinamaSonuc ?? '—')}</b></div>
      </div>
      {onSina && (
        <div><button type="button" className="d" onClick={onSina}>🔌 {c('Bağlantıyı sına')}</button>
          <div className="rt-kucuk sonuk">{c('Adrese TCP bağlantısı dener; DICOM doğrulaması yapılmaz.')}</div>
        </div>
      )}
    </div>
  );
}

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

/**
 * Eşleme satırının v2 biçimi. ESKİ BİÇİM (düz metin = yalnız ölçüm kodu)
 * okunmaya devam ediyor: elle JSON yazılmış kurulumlar ve göç verisi onu
 * kullanıyor, sessizce susmaları olmaz. Kaydetmede satır obje olarak yazılır.
 */
type EslemeSatiri = {
  kod: string; birim?: string; goz?: string; donustur?: string;
  esik?: string; zorunlu?: boolean;
};

const satirCoz = (ham: unknown): EslemeSatiri => {
  if (typeof ham === 'string') return { kod: ham };
  const o = (ham ?? {}) as Partial<EslemeSatiri>;
  return { ...o, kod: o.kod ?? '' };
};

export function OlcumEslemeSekmesi({ b, cihazId }: { b: EkSekmeBaglami; cihazId: number | null }) {
  const esleme = jsonCoz<Record<string, unknown>>(b.deger.olcumEsleme, {});
  const satirlar = Object.entries(esleme).map(([alan, ham]) => [alan, satirCoz(ham)] as const);
  const yaz = (yeni: Record<string, unknown>) => b.alanYaz('olcumEsleme', JSON.stringify(yeni));
  const satirYaz = (alan: string, parca: Partial<EslemeSatiri>) =>
    yaz({ ...esleme, [alan]: { ...satirCoz(esleme[alan]), ...parca } });

  const [alan, setAlan] = useState('');
  const [kod, setKod] = useState('');
  // ÖRNEK MESAJ sekmede durur: eşlemeyi kurarken cihazdan gerçek çekim
  //   beklemek, her denemede bir hasta kaydını kirletmek demekti.
  const [ornek, setOrnek] = useState('');
  const [sonuc, setSonuc] = useState<{ gozAd: string; olcum: string; deger: number }[] | null>(null);
  const [sinaHata, setSinaHata] = useState('');

  const sina = async () => {
    setSinaHata(''); setSonuc(null);
    if (!cihazId) { setSinaHata(c('Sınama kayıtlı cihazda çalışır - önce kaydedin.')); return }
    try {
      const y = await api.gozCihazEslemeSina(cihazId, ornek, JSON.stringify(esleme));
      setSonuc(y.satirlar);
    } catch (h) {
      setSinaHata(h instanceof Error ? h.message : String(h));
    }
  };

  return (
    <div className="gc-sekme">
      <div className="bilgi">{c('Cihazın gönderdiği alan adı, hangi ölçüm olarak kaydedilecek. '
        + 'Eşlenen her alan ölçüm tablosuna bir satır olarak yazılır (göz ayrımı "Göz alanı" '
        + 'kolonundan); trend, eşik bayrağı ve listedeki "ana ölçüm" kolonu bu satırlardan '
        + 'hesaplanır. Eşlenmemiş alan ham kalır.')}</div>

      <table className="gl-mini gc-tbl">
        <tbody>
          <tr><th>{c('Cihaz alanı')}</th><th>{c('Ölçüm kodu')}</th><th>{c('Birim')}</th>
            <th>{c('Göz alanı')}</th><th>{c('Dönüştürme')}</th><th>{c('Eşik / normatif')}</th>
            <th>{c('Zorunlu')}</th><th /></tr>
          {satirlar.map(([a, r]) => (
            <tr key={a}>
              <td><b>{a}</b></td>
              <td><input className="gc-inp" value={r.kod}
                         onChange={e => satirYaz(a, { kod: e.target.value })} /></td>
              <td><input className="gc-inp gc-dar" value={r.birim ?? ''} placeholder="µm"
                         onChange={e => satirYaz(a, { birim: e.target.value })} /></td>
              <td>
                <select className="gc-inp" value={r.goz ?? ''}
                        onChange={e => satirYaz(a, { goz: e.target.value })}>
                  <option value="">{c('mesajdan')}</option>
                  <option value="Laterality">Laterality</option>
                  <option value="Eye">Eye</option>
                  <option value="OD">{c('hep OD')}</option>
                  <option value="OS">{c('hep OS')}</option>
                </select>
              </td>
              <td><input className="gc-inp gc-dar" value={r.donustur ?? ''} placeholder="x0.25"
                         onChange={e => satirYaz(a, { donustur: e.target.value })} /></td>
              <td><input className="gc-inp gc-dar" value={r.esik ?? ''} placeholder="<6"
                         onChange={e => satirYaz(a, { esik: e.target.value })} /></td>
              {/* ZORUNLU alan mesajda yoksa mesaj hatalı sayılır: yarım ölçüm
                  kaydı sessizce eksik trend üretir. */}
              <td className="orta"><input type="checkbox" checked={r.zorunlu === true}
                                          onChange={e => satirYaz(a, { zorunlu: e.target.checked })} /></td>
              <td><button type="button" className="d" onClick={() => {
                const kopya = { ...esleme }; delete kopya[a]; yaz(kopya);
              }}>✕</button></td>
            </tr>
          ))}
          {satirlar.length === 0 && (
            <tr><td colSpan={8} className="sonuk">{c('Ölçüm eşlemesi yok - gelen değerler ham kalır, '
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
                onClick={() => { yaz({ ...esleme, [alan.trim()]: { kod: kod.trim() } }); setAlan(''); setKod('') }}>
          ＋ {c('Ekle')}</button>
      </div>

      <h5 className="gc-bas">{c('Örnek mesajla sına')}</h5>
      <div className="bilgi">{c('Cihazdan gelmiş gibi bir metin yapıştırın: hangi ölçümlerin '
        + 'çıkacağını gösterir, HİÇBİR ŞEY KAYDETMEZ. Tabloda değiştirdiğiniz (henüz '
        + 'kaydedilmemiş) eşleme kullanılır.')}</div>
      <textarea className="gc-ornek" value={ornek} rows={4}
                placeholder={'<Eye>OD</Eye><RNFL_Avg>78</RNFL_Avg>\nOD IOP 26 CCT 532'}
                onChange={e => setOrnek(e.target.value)} />
      <div className="gc-ekle">
        <button type="button" className="d" disabled={!ornek.trim()} onClick={() => void sina()}>
          🧪 {c('Sına')}</button>
        {sonuc && <span className="sonuk">{sonuc.length} {c('ölçüm çözüldü')}</span>}
      </div>
      {sinaHata && <div className="uyar">{sinaHata}</div>}
      {sonuc && sonuc.length === 0 && (
        <div className="uyar">{c('Hiçbir ölçüm çözülemedi: alan adları eşlemedeki adlarla '
          + 'birebir aynı mı (büyük/küçük harf önemsiz) ve değerler sayı mı?')}</div>
      )}
      {sonuc && sonuc.length > 0 && (
        <table className="gl-mini gc-tbl">
          <tbody>
            <tr><th>{c('Göz')}</th><th>{c('Ölçüm')}</th><th>{c('Değer')}</th></tr>
            {sonuc.map((x, i) => (
              <tr key={`${x.olcum}-${i}`}><td>{x.gozAd}</td><td>{x.olcum}</td><td>{x.deger}</td></tr>
            ))}
          </tbody>
        </table>
      )}
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

/**
 * KART YAN PANELİ (mockup ③ sağ sütun): MWL bilgisi, durum, son 24 saat,
 * tetkik dağılımı, hızlı işlem, kayıt bilgisi.
 *
 * Sayılar listedeki önizlemenin AYNI ucundan gelir - kartta ikinci bir sorgu
 * açmak, aynı cihaz için iki farklı "bugün çekim" sayısı demekti.
 */
export function CihazYanPaneli({ r, onSina, onDemirbas }: {
  r: GozCihazOnizleme | null;
  onSina?: () => void;
  onDemirbas?: (id: number) => void;
}) {
  if (!r) return null;
  const k = r.cihaz;
  const mwl = Number(k.mwl) === 1;
  const demirbasId = Number(k.demirbasId ?? 0);
  const sayi = (v: unknown) => (v === null || v === undefined ? '—' : String(v));
  return (
    <div className="gc-yan">
      {/* MWL DESTEĞİ eşleşme hatasının beklenip beklenmeyeceğini söylüyor:
          çalışma listesi varsa tekniker cihazda hasta seçmiyor. */}
      <div className={`gc-bilgi-kutu${mwl ? ' olumlu' : ''}`}>
        {mwl
          ? c('Bu cihaz MWL destekliyor: istem çalışma listesine düşer, tekniker cihazda hasta '
              + 'seçmez - eşleşme hatası beklenmez.')
          : c('Bu cihaz MWL desteklemiyor: tekniker hastayı cihazda seçer, eşleşme protokol '
              + 'numarasıyla kurulur. Protokol alanı boş gelen mesaj kuyrukta bekler.')}
      </div>

      <div className="gc-kutu"><h6>{c('Durum')}</h6>
        <div className="gc-sat"><span>{c('Dinleyici')}</span>
          <b>{Number(k.dinleyiciDurum) === 1 ? c('Dinliyor')
            : Number(k.dinleyiciDurum) === 2 ? c('Bağlantı yok') : c('—')}</b></div>
        <div className="gc-sat"><span>{c('Son mesaj')}</span>
          <b>{k.sonMesaj ? tarihSaat(k.sonMesaj) : '—'}</b></div>
        <div className="gc-sat"><span>{c('Bugün çekim')}</span><b>{sayi(k.bugunCekim)}</b></div>
        <div className="gc-sat"><span>{c('Kuyrukta')}</span><b>{sayi(k.eslenmeyen)}</b></div>
        <div className="gc-sat"><span>{c('Hatalı')}</span><b>{sayi(k.hatali)}</b></div>
      </div>

      <div className="gc-kutu"><h6>{c('Son 24 saat')}</h6>
        <div className="gc-sat"><span>{c('Gelen mesaj')}</span><b>{sayi(k.mesaj24s)}</b></div>
        <div className="gc-sat"><span>{c('İşlenen')}</span><b>{sayi(k.islenen24s)}</b></div>
        <div className="gc-sat"><span>{c('Ortalama gecikme')}</span>
          <b>{k.gecikmeSn != null ? `${Number(k.gecikmeSn)} ${c('sn')}` : '—'}</b></div>
      </div>

      {r.tetkikler.length > 0 && (
        <div className="gc-kutu"><h6>{c('Bu ay tetkikler')}</h6>
          {r.tetkikler.map(t => (
            <div key={t.tetkik} className="gc-sat">
              <span>{c(GOZ_TETKIK[t.tetkik] ?? String(t.tetkik))}</span><b>{t.sayi}</b></div>
          ))}
        </div>
      )}

      <div className="gc-kutu"><h6>{c('Hızlı işlem')}</h6>
        <div className="gc-dugmeler">
          {onSina && <button type="button" className="d" onClick={onSina}>🔌 {c('Bağlantıyı sına')}</button>}
          {demirbasId > 0 && onDemirbas && (
            <button type="button" className="d" onClick={() => onDemirbas(demirbasId)}>↗ {c('Demirbaş kartı')}</button>
          )}
        </div>
      </div>
    </div>
  );
}
