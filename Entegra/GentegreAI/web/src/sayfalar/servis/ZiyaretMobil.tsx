import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ZiyaretDetayi } from '../../api/uclar/servis';
import { guvenli, mesaj } from '../../bilesenler/mesaj';

/**
 * ZİYARET KARTI — TEKNİSYENİN TELEFONU (776).
 *
 * Mockup `Ekranlar/TeknikServis/teknik_servis_saha.html` › "Ziyaret Kartı".
 *
 * ============ NEDEN AYRI EKRAN =======================================
 * Generic kart iki sütunlu bir form çizer; sahadaki teknisyen tek elle,
 * güneş altında, zayıf bağlantıyla doldurur. Tek sütun, büyük dokunma
 * alanları ve TEK KAYDET düğmesi - yarım dolmuş bir form, akşam ofiste
 * hatırlanarak tamamlanan bir kayıt demektir.
 *
 * Adres ve telefon da burada: "nereye gideceğim, kimi arayacağım" için
 * başka ekrana bakılmasın. Telefon `tel:` bağlantısıdır - numarayı elle
 * çevirmek, telefonda duran bir uygulamada anlamsız.
 *
 * ============ KAPANIŞ KURALI SUNUCUDA ================================
 * İmzasız ziyaret kapanmaz; alınamadıysa gerekçe zorunlu. Ekran soruyu
 * sorar, kararı `/ziyaret/{id}/kapat` verir - burada ikinci bir kural
 * yazsaydık ikisi bir gün ayrışırdı.
 */
const SONUCLAR = [
  { deger: 1, ad: 'Çözüldü', ipucu: 'Çağrı kapanır' },
  { deger: 2, ad: 'Çözülemedi', ipucu: 'Çağrı açık kalır - ikinci gidiş' },
  { deger: 3, ad: 'Parça bekliyor', ipucu: 'Çağrı "parça bekliyor"a geçer' },
];

const saat = (d?: string | null) =>
  d ? new Date(d).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' }) : '—';

export function ZiyaretMobil() {
  const { id } = useParams();
  const git = useNavigate();
  const [z, setZ] = useState<ZiyaretDetayi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const [yapilan, setYapilan] = useState('');
  const [sonuc, setSonuc] = useState(1);
  const [sonucMetni, setSonucMetni] = useState('');
  const [yolKm, setYolKm] = useState('');
  const [iscilikSaat, setIscilikSaat] = useState('');
  const [tutar, setTutar] = useState('');
  const [mesaiDisi, setMesaiDisi] = useState(false);
  const [imza, setImza] = useState(true);
  const [imzaNotu, setImzaNotu] = useState('');

  useEffect(() => {
    void (async () => {
      try {
        const y = await api.servisZiyaretDetay(Number(id));
        setZ(y.ziyaret);
        // AÇIK ZİYARETTE KUTULAR BOŞ BAŞLAR; kapanmış ziyarette kayıtlı
        //   değerler görünür (ekran aynı zamanda okuma ekranıdır).
        setYapilan(y.ziyaret.yapilan);
        setSonuc(y.ziyaret.sonuc || 1);
        setSonucMetni(y.ziyaret.sonucMetni);
        setYolKm(y.ziyaret.yolKm ? String(y.ziyaret.yolKm) : '');
        setIscilikSaat(y.ziyaret.iscilikSaat ? String(y.ziyaret.iscilikSaat) : '');
        setTutar(y.ziyaret.tutar ? String(y.ziyaret.tutar) : '');
        setMesaiDisi(y.ziyaret.mesaiDisi === 1);
        setImza(y.ziyaret.imzaAlindi === 1);
        setImzaNotu(y.ziyaret.imzaNotu);
      } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [id]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!z) return <div className="yukleniyor">Yükleniyor…</div>;

  const kapali = z.sonuc !== 0;
  const sayi = (m: string) => (m.trim() ? Number(m.replace(',', '.')) : undefined);

  const kapat = () => guvenli(async () => {
    const y = await api.servisZiyaretKapat(z.id, {
      yapilan, sonuc, sonucMetni: sonucMetni || undefined,
      yolKm: sayi(yolKm), iscilikSaat: sayi(iscilikSaat), tutar: sayi(tutar),
      mesaiDisi, imzaAlindi: imza, imzaNotu: imza ? undefined : imzaNotu,
    });
    mesaj(`${y.mesaj}\n\nİş emri toplamı: ${y.toplamTutar} ₺`);
    git('/servis-cizelge');
  });

  return (
    <div className="zm">
      {/* BAŞLIK KÂĞITTAKİ GİBİ SABİT: teknisyen kaydırırken kimin işinde
          olduğunu kaybetmesin. */}
      <div className="zm-bas">
        <div>
          <b>{z.cagriNo || z.isEmriNo || 'Ziyaret'}</b>
          <span>{z.sira}. ziyaret · {z.sahiplik === 2 ? 'müşteri cihazı' : 'kurum demirbaşı'}</span>
        </div>
        <button className="d" onClick={() => git(-1)}>✕</button>
      </div>

      <div className="zm-kart">
        <div className="zm-mus">{z.tarafAdi}</div>
        <div className="zm-cihaz">{z.cihaz}{z.seriNo ? ` · S/N ${z.seriNo}` : ''}</div>
        {z.adres && <div className="zm-satir">📍 {z.adres}</div>}
        {z.telefon && (
          // TELEFON BAĞLANTIDIR: numarayı elle çevirmek, telefonda duran bir
          //   uygulamada anlamsız.
          <a className="zm-tel" href={`tel:${z.telefon.replace(/\s/g, '')}`}>
            📞 {z.telefon}{z.bildiren ? ` · ${z.bildiren}` : ''}
          </a>
        )}
        {(z.sikayet || z.arizaMetni) && (
          <div className="zm-sikayet">
            <b>Şikâyet</b>{z.sikayet || z.arizaMetni}
          </div>
        )}
        <div className="zm-zaman">
          <span>Varış <b>{saat(z.varis)}</b></span>
          <span>Ayrılış <b>{saat(z.ayrilis)}</b></span>
          {z.arac && <span>Araç <b>{z.arac}</b></span>}
        </div>
      </div>

      {kapali && (
        <div className="zm-kapali">
          Bu ziyaret kapatılmış. Aşağıdaki bilgiler kayıtlıdır; değiştirmek için
          iş emrinden yeni ziyaret açın.
        </div>
      )}

      <div className="zm-kart">
        <label className="zm-alan">
          <span>Yapılan iş</span>
          <textarea rows={4} value={yapilan} readOnly={kapali}
                    placeholder="Ne yapıldı, ne değişti…"
                    onChange={e => setYapilan(e.target.value)} />
        </label>

        <div className="zm-alan">
          <span>Sonuç</span>
          {/* BÜYÜK DOKUNMA ALANI: sahada açılır liste seçmek zor; üç seçenek
              yan yana düğme. */}
          <div className="zm-secim">
            {SONUCLAR.map(s => (
              <button key={s.deger} type="button" disabled={kapali}
                      className={`zm-sec${sonuc === s.deger ? ' on' : ''}`}
                      onClick={() => setSonuc(s.deger)}>
                {s.ad}<i>{s.ipucu}</i>
              </button>
            ))}
          </div>
        </div>

        {sonuc !== 1 && (
          <label className="zm-alan">
            <span>Neden çözülemedi</span>
            <input value={sonucMetni} readOnly={kapali}
                   placeholder="Parça yok, erişilemedi…"
                   onChange={e => setSonucMetni(e.target.value)} />
          </label>
        )}

        <div className="zm-ucer">
          <label className="zm-alan">
            <span>Yol (km)</span>
            <input inputMode="decimal" value={yolKm} readOnly={kapali}
                   onChange={e => setYolKm(e.target.value)} />
          </label>
          <label className="zm-alan">
            <span>İşçilik (sa)</span>
            <input inputMode="decimal" value={iscilikSaat} readOnly={kapali}
                   onChange={e => setIscilikSaat(e.target.value)} />
          </label>
          <label className="zm-alan">
            <span>Tutar (₺)</span>
            <input inputMode="decimal" value={tutar} readOnly={kapali}
                   onChange={e => setTutar(e.target.value)} />
          </label>
        </div>

        <label className="zm-onay">
          <input type="checkbox" checked={mesaiDisi} disabled={kapali}
                 onChange={e => setMesaiDisi(e.target.checked)} />
          Mesai dışı çalışma
        </label>
      </div>

      {z.parcalar.length > 0 && (
        <div className="zm-kart">
          <div className="zm-baslik">Kullanılan parça</div>
          {z.parcalar.map(p => (
            <div key={p.id} className="zm-parca">
              <b>{p.ad || p.parcaNo}</b>
              <span>{p.miktar} × {p.birimFiyat} ₺
                {p.iadeDurum === 1 ? ' · arızalı parça toplandı' : ''}</span>
            </div>
          ))}
        </div>
      )}

      <div className="zm-kart">
        <div className="zm-baslik">Müşteri imzası</div>
        {/* İMZASIZ ZİYARET KAPANMAZ: yerinde yapılan işin tek kanıtı müşterinin
            onayıdır. Alınamıyorsa gerekçe yazılır - kural esner, iz kalır. */}
        <div className="zm-secim">
          <button type="button" disabled={kapali}
                  className={`zm-sec${imza ? ' on' : ''}`}
                  onClick={() => setImza(true)}>Alındı</button>
          <button type="button" disabled={kapali}
                  className={`zm-sec${!imza ? ' on' : ''}`}
                  onClick={() => setImza(false)}>Alınamadı</button>
        </div>
        {!imza && (
          <label className="zm-alan">
            <span>Gerekçe (zorunlu)</span>
            <input value={imzaNotu} readOnly={kapali}
                   placeholder="Yetkili yoktu, imzadan kaçındı…"
                   onChange={e => setImzaNotu(e.target.value)} />
          </label>
        )}
      </div>

      {!kapali && (
        // TEK KAYDET DÜĞMESİ, EKRANIN ALTINDA SABİT: yarım dolmuş form,
        //   akşam ofiste hatırlanarak tamamlanan kayıt demektir.
        <div className="zm-alt">
          <button className="d bir zm-kaydet" onClick={kapat}>
            ✓ Ziyareti Kapat
          </button>
        </div>
      )}
    </div>
  );
}
