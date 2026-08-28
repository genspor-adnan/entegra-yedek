import { useRef, useState } from 'react';
import { Modal } from './Modal';
import { ApiHatasi, hataMetni } from '../api/sozlesme';
import { dosyaIndirUrl } from './indir';

/**
 * EXCEL'DEN ICERI ALMA MODALI - jenerik govde (207).
 *
 * Ekran bilmez: sablon indirme ve yukleme fonksiyonlarini PROPS ile alir.
 * Fiyat listesi bugun, stok/cari yarin ayni modali kullanir - degisen yalniz
 * verilen fonksiyonlar ve baslik.
 *
 * Akis: "Şablon İndir" (bos ya da mevcut satirlarla) -> kullanici Excel'de
 * doldurur -> dosya secer -> yukle. Sunucu YA HEP YA HIC calisir: tek hata
 * bile varsa hicbir satir yazilmaz, satir numarali hata tablosu burada
 * gosterilir - kullanici Excel'i duzeltip AYNI dosyayi yeniden yukler
 * (upsert oldugu icin tekrar guvenlidir).
 */
export function IceriAlModali({ baslik, sablonIndir, yukle, onKapat, onAlindi }: {
  /** Modal basligindaki hedef adi (ör. liste adi). */
  baslik: string;
  /** dolu=true mevcut kayitlarla dolu sablon. Blob URL dondurur. */
  sablonIndir(dolu: boolean): Promise<string>;
  /** Dosyayi sunucuya verir; basari mesaji dondurur. */
  yukle(dosya: File): Promise<{ mesaj: string }>;
  onKapat(): void;
  /** Basarili almadan sonra cagirilir (liste tazelensin). */
  onAlindi(): void;
}) {
  const [dosya, setDosya] = useState<File | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);
  const [sonucMesaji, setSonucMesaji] = useState<string | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [satirHatalari, setSatirHatalari] =
    useState<{ satirNo: number; alan: string; mesaj: string }[]>([]);
  const [toplamHata, setToplamHata] = useState(0);
  const girdi = useRef<HTMLInputElement | null>(null);

  const indir = async (dolu: boolean) => {
    setHata(null);
    try {
      dosyaIndirUrl(await sablonIndir(dolu),
        dolu ? `${baslik}.xlsx` : 'Fiyat Listesi Şablonu.xlsx', true);
    } catch (h) { setHata(hataMetni(h)) }
  };

  const gonder = async () => {
    if (!dosya) return;
    setCalisiyor(true);
    setHata(null);
    setSatirHatalari([]);
    setSonucMesaji(null);
    try {
      const y = await yukle(dosya);
      setSonucMesaji(y.mesaj);
      onAlindi();
    } catch (h) {
      if (h instanceof ApiHatasi && h.hata.satirHatalari?.length) {
        setHata(h.message);
        setSatirHatalari(h.hata.satirHatalari);
        setToplamHata(h.hata.toplamHata ?? h.hata.satirHatalari.length);
      } else {
        setHata(hataMetni(h));
      }
    } finally { setCalisiyor(false) }
  };

  return (
    <Modal baslik={`Excel'den İçeri Al — ${baslik}`} onKapat={onKapat}
      alt={<>
        <button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>
        <button className="d bir" disabled={!dosya || calisiyor}
                onClick={() => { void gonder() }}>
          {calisiyor ? 'Alınıyor…' : 'İçeri Al'}
        </button>
      </>}
    >
      <div className="kagrup">
        <div className="not" style={{ marginBottom: 10 }}>
          Sütunlar: <b>Stok Kodu</b> ya da <b>Hizmet Kodu</b> (tam biri; tek <b>Kod</b> sütunu
          da kabul edilir) · <b>Fiyat</b> · Döviz · KDV (Dahil/Hariç) · Birim · Durum.
          Eşleşen kalem <b>güncellenir</b>, yeni kalem eklenir; içeri alınan satırlar
          <b> İmport</b> işaretlenir ve "Listeyi Üret" onları ezmez.
        </div>

        <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
          <button className="d" onClick={() => { void indir(false) }}>⬇ Boş Şablon</button>
          <button className="d" onClick={() => { void indir(true) }}>⬇ Mevcut Satırlarla İndir</button>
        </div>

        <input ref={girdi} type="file" accept=".xlsx" hidden
               onChange={e => {
                 setDosya(e.target.files?.[0] ?? null);
                 setSonucMesaji(null); setHata(null); setSatirHatalari([]);
                 e.target.value = '';
               }} />
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <button className="d" onClick={() => girdi.current?.click()}>Dosya Seç…</button>
          <span className={dosya ? '' : 'not'}>{dosya ? dosya.name : 'dosya seçilmedi'}</span>
        </div>

        {sonucMesaji && <div className="bilgi-kutusu" style={{ marginTop: 10 }}>{sonucMesaji}</div>}
        {hata && <div className="hata-kutusu" style={{ marginTop: 10 }}>{hata}</div>}

        {satirHatalari.length > 0 && (
          <div style={{ marginTop: 8, maxHeight: 260, overflow: 'auto' }}>
            <table className="kasat-tablo" style={{ width: '100%', fontSize: 12 }}>
              <thead><tr><th>Satır</th><th>Alan</th><th>Sorun</th></tr></thead>
              <tbody>
                {satirHatalari.map((s, i) => (
                  <tr key={i}>
                    <td style={{ textAlign: 'right' }}>{s.satirNo}</td>
                    <td>{s.alan}</td>
                    <td>{s.mesaj}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {toplamHata > satirHatalari.length && (
              <div className="not">… ve {toplamHata - satirHatalari.length} hata daha
                (ilk {satirHatalari.length} gösteriliyor).</div>
            )}
          </div>
        )}
      </div>
    </Modal>
  );
}
