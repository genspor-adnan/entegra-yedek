import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ZiyaretDetayi } from '../../api/uclar/servis';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { ImzaTuvali } from '../../bilesenler/ImzaTuvali';

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
  /** Çizilen imza (PNG); kapanışta doküman olarak yüklenir. */
  const [imzaBlob, setImzaBlob] = useState<Blob | null>(null);
  /** Kayıtlı imzanın görsel adresi - kapanmış ziyarette okunur. */
  const [imzaUrl, setImzaUrl] = useState<string | null>(null);
  /** Parça ekleme kutusu - sahada tek elle doldurulur. */
  const [parcaAcik, setParcaAcik] = useState(false);
  const [parcaAra, setParcaAra] = useState('');
  const [parcaSecenek, setParcaSecenek] = useState<
    { id: number; kod: string; ad: string }[]>([]);
  const [parcaAd, setParcaAd] = useState('');
  const [parcaStokId, setParcaStokId] = useState<number | null>(null);
  const [parcaMiktar, setParcaMiktar] = useState('1');
  const [parcaFiyat, setParcaFiyat] = useState('');
  const [parcaIade, setParcaIade] = useState(false);

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
        // AÇIK ZİYARETTE VARSAYILAN "ALINDI": kayıtlı bayrak her açık
        //   ziyarette 0'dır ve onu olduğu gibi almak "Alınamadı"yı ön seçili
        //   yapıyordu - imza tuvali hiç çizilmiyor, teknisyen imza almayı
        //   düşünmeden gerekçe kutusuyla karşılaşıyordu. Kapanmış ziyarette
        //   kayıtlı değer okunur; orada bayrak gerçeği söyler.
        setImza(y.ziyaret.sonuc === 0 ? true : y.ziyaret.imzaAlindi === 1);
        setImzaNotu(y.ziyaret.imzaNotu);
        // KAPANMIŞ ZİYARETTE İMZA GÖRSELİ OKUNUR: ekran aynı zamanda kanıt
        //   ekranıdır - "o gün kim imzaladı" sorusu burada cevaplanır.
        const d = await api.dokumanlar('servisZiyaret', Number(id));
        const imzaSatiri = d.find(x => x.belgeTuru === 'İmza');
        if (imzaSatiri) setImzaUrl(await api.dokumanIcerikUrl(imzaSatiri.id));
      } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [id]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!z) return <div className="yukleniyor">Yükleniyor…</div>;

  const kapali = z.sonuc !== 0;

  const tazele = async () => setZ((await api.servisZiyaretDetay(z.id)).ziyaret);

  // STOK ARAMA SAHADA KISA TUTULUR: ilk beş sonuç yeter, uzun liste telefonda
  //   kaydırmaktan başka bir şey değil. Aramayı kullanıcı tetikler - her
  //   tuşta istek atmak zayıf bağlantıda ekranı kilitlerdi.
  const stokAra = () => guvenli(async () => {
    const y = await api.liste('stok', {
      sayfa: 1, boyut: 5, arama: parcaAra,
    } as Parameters<typeof api.liste>[1]);
    setParcaSecenek(y.satirlar.map(r => ({
      id: Number(r.id), kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
    })));
  });

  const parcaEkle = () => guvenli(async () => {
    const y = await api.servisParcaEkle(z.id, {
      stokId: parcaStokId ?? undefined,
      ad: parcaAd.trim() || undefined,
      miktar: Number((parcaMiktar || '1').replace(',', '.')),
      birimFiyat: parcaFiyat.trim()
        ? Number(parcaFiyat.replace(',', '.')) : undefined,
      iadeToplandi: parcaIade,
    });
    mesaj(y.mesaj);
    setParcaAcik(false); setParcaAd(''); setParcaStokId(null);
    setParcaMiktar('1'); setParcaFiyat(''); setParcaIade(false);
    setParcaAra(''); setParcaSecenek([]);
    await tazele();
  });

  const parcaSil = (parcaId: number) => guvenli(async () => {
    await api.servisParcaSil(parcaId);
    await tazele();
  });
  const sayi = (m: string) => (m.trim() ? Number(m.replace(',', '.')) : undefined);

  const kapat = () => guvenli(async () => {
    // "ALINDI" DİYİP ÇİZMEMEK, ESKİ BOŞ İDDİANIN AYNISI. Kural burada
    //   çünkü imza ancak dokunmatik ekranda çizilebilir; uç, imzayı bilmeden
    //   karar veremez (masaüstündeki liste yolu bayrak + gerekçeyle yürür).
    if (imza && !imzaBlob && !imzaUrl) {
      mesaj(['Müşteri imzası çizilmedi.', '',
             'Ya tuvale imzalatın ya da "Alınamadı" seçip gerekçe yazın - '
             + 'yerinde yapılan işin tek kanıtı müşterinin onayıdır.'
            ].join(String.fromCharCode(10)));
      return;
    }
    // İMZA ÖNCE YÜKLENİR, SONRA KAPANIŞ: ziyaret kapandıktan sonra yükleme
    //   düşerse "imza alındı" diyen ama görseli olmayan bir kayıt kalırdı.
    //   Bu sırayla en kötü hâl kapanmamış bir ziyaret - o tekrar denenebilir.
    if (imza && imzaBlob) {
      const ad = `imza-${z.cagriNo || z.isEmriNo || z.id}.png`;
      await api.dokumanYukle('servisZiyaret', z.id,
        new File([imzaBlob], ad, { type: 'image/png' }), false);
      const yuklenen = (await api.dokumanlar('servisZiyaret', z.id))
        .filter(x => x.ad === ad).slice(-1)[0];
      // BELGE TÜRÜ "İmza": aynı ziyarete fotoğraf da eklenebilir; imzayı
      //   ötekilerden ayıran tek şey bu etiket.
      if (yuklenen) await api.dokumanDuzenle('servisZiyaret', z.id,
                                             yuklenen.id, ad, 'İmza');
    }
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

      <div className="zm-kart">
        <div className="zm-baslik">Kullanılan parça</div>
        {z.parcalar.map(p => (
          <div key={p.id} className="zm-parca">
            <div>
              <b>{p.ad || p.parcaNo}</b>
              <span>{p.miktar} × {p.birimFiyat} ₺
                {p.iadeDurum === 1 ? ' · arızalı parça toplandı' : ''}</span>
            </div>
            {!kapali && (
              <button type="button" className="d mini" onClick={() => parcaSil(p.id)}>
                Sil
              </button>
            )}
          </div>
        ))}
        {z.parcalar.length === 0 && (
          <div className="zm-bosluk">Bu ziyarette parça kullanılmadı.</div>
        )}

        {!kapali && !parcaAcik && (
          <button type="button" className="d zm-parca-ekle"
                  onClick={() => setParcaAcik(true)}>＋ Parça Ekle</button>
        )}

        {!kapali && parcaAcik && (
          <div className="zm-parca-kutu">
            {/* STOKTAN SEÇ YA DA ELLE YAZ: sahada her parça katalogda
                olmayabilir (müşterinin getirdiği, dışarıdan alınan). Adsız
                satır yasak - sonradan kimsenin ne olduğunu bilemediği bir
                maliyet olurdu. */}
            <label className="zm-alan">
              <span>Stokta ara</span>
              <div className="zm-ara">
                <input value={parcaAra} placeholder="Parça adı ya da kodu…"
                       onChange={e => setParcaAra(e.target.value)} />
                <button type="button" className="d" onClick={stokAra}>Ara</button>
              </div>
            </label>
            {parcaSecenek.map(o => (
              <button key={o.id} type="button"
                      className={`zm-sec${parcaStokId === o.id ? ' on' : ''}`}
                      style={{ width: '100%', marginBottom: 6, minHeight: 44 }}
                      onClick={() => guvenli(async () => {
                        setParcaStokId(o.id); setParcaAd(o.ad);
                        // FİYAT TEK YERDEN: stok kartında fiyat yok, fiyat
                        //   LİSTESİNDEN gelir. Teknisyen gerekirse üstüne
                        //   yazar; boş bırakırsa ofis fiyatlar.
                        const f = await api.fiyatKalem({ stokId: o.id }, {});
                        if (f.fiyat) setParcaFiyat(String(f.fiyat));
                      })}>
                {o.ad}<i>{o.kod}</i>
              </button>
            ))}
            <label className="zm-alan">
              <span>Parça adı</span>
              <input value={parcaAd} placeholder="Katalogda yoksa elle yazın"
                     onChange={e => { setParcaAd(e.target.value); setParcaStokId(null) }} />
            </label>
            <div className="zm-ucer">
              <label className="zm-alan">
                <span>Miktar</span>
                <input inputMode="decimal" value={parcaMiktar}
                       onChange={e => setParcaMiktar(e.target.value)} />
              </label>
              <label className="zm-alan">
                <span>Birim fiyat</span>
                <input inputMode="decimal" value={parcaFiyat}
                       onChange={e => setParcaFiyat(e.target.value)} />
              </label>
            </div>
            {/* ARIZALI PARÇA İADESİ: üretici garantisinde sökülen parça
                üreticiye geri gönderilmezse alacak REDDEDİLİR. */}
            <label className="zm-onay">
              <input type="checkbox" checked={parcaIade}
                     onChange={e => setParcaIade(e.target.checked)} />
              Sökülen arızalı parça toplandı
            </label>
            <div className="zm-secim">
              <button type="button" className="zm-sec on" onClick={parcaEkle}>
                Ekle
              </button>
              <button type="button" className="zm-sec"
                      onClick={() => setParcaAcik(false)}>Vazgeç</button>
            </div>
          </div>
        )}
      </div>

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
        {imza && (
          // ÇİZİLEN İMZA: bayrak "alındı" der, görsel KİMİN imzaladığını
          //   gösterir - onay kutusu, sonradan çıkan "gelmediler" tartışmasında
          //   delil değildir.
          <div className="zm-alan">
            <span>Müşteri buraya imzalasın</span>
            <ImzaTuvali salt={kapali} deger={imzaUrl} onDegisti={setImzaBlob} />
          </div>
        )}
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
