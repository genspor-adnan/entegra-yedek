import { useCallback, useEffect, useState } from 'react';
import { tipografiOku, tipografiStil } from './radyoloji/tipografi';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { AntetLogo } from '../bilesenler/AntetLogo';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat, gunNokta, yasMetni } from '../bilesenler/bicim';
import { cinsiyetAdi } from '../bilesenler/kisiKodlari';
import { tekParcaMi } from './radyoloji/raporBicimi';
import { Karekod } from '../bilesenler/Karekod';
import { raporBaglantisi } from '../api/uclar/raporGonderim';

/**
 * RADYOLOJI RAPOR CIKTISI (mockup: Ekranlar/radyoloji_rapor_onizleme.html).
 *
 * Hastaya VERILEN belge. Yazma ekranindan ayri bir sayfa cunku isi baska:
 * orada sablon/makro/skor ile metin uretilir, burada o metin KURUM ANTETI ve
 * kimlik satirlariyla basilabilir hale gelir. Ayni ekrana sikistirmak, yazma
 * yuzeyini (kilit, addendum, kritik bulgu) cikti duzenine bulastirirdi.
 *
 * Yazdirma tarayicinin kendi diyalogudur: "PDF olarak kaydet" secenegi de
 * orada. Ayri bir PDF ureticisi (sunucu tarafi) YOK - ayni ciktinin iki
 * uretim yolu olmasi, birinin digerinden sapmasi demektir.
 */

type Satir = Record<string, unknown>;

/** Dogum tarihinden yas - kartlardaki hesapla ayni kural. */

/** Modaliteye gore rapor basligi (mockup "Manyetik Rezonans İnceleme Raporu"). */
const RAPOR_ADI: Record<number, string> = {
  1: 'Bilgisayarlı Tomografi İnceleme Raporu',
  2: 'Manyetik Rezonans İnceleme Raporu',
  3: 'Ultrasonografi İnceleme Raporu',
  4: 'Direkt Grafi İnceleme Raporu',
  5: 'Mamografi İnceleme Raporu',
  6: 'Kemik Dansitometri (DEXA) Raporu',
  7: 'Anjiyografi İnceleme Raporu',
  8: 'Skopi İnceleme Raporu',
};

export function RadyolojiRaporCikti() {
  const { id } = useParams();
  const git = useNavigate();
  const [veri, setVeri] = useState<RaporCiktiVerisi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.radyolojiRaporCikti(Number(id)) as never);
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const r = veri.rapor;
  const onayli = Number(r.durum ?? 0) === 3;

  return (
    <div className="rapor-cikti">
      {/* Arac cubugu YAZDIRILMAZ (@media print) - kagitta yalniz belge kalir. */}
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
        <button className="d" onClick={() => window.print()}
                title="Yazdırma penceresinde “PDF olarak kaydet” seçin.">
          📄 PDF
        </button>
        <button className="d" disabled title="SMS / e-posta gönderimi henüz bağlanmadı.">
          ✉ Hastaya Gönder
        </button>
        <button className="d" disabled title="Hasta portalı henüz yok.">
          🔗 Hasta Portalı Bağlantısı
        </button>
        <span style={{ marginLeft: 'auto' }} />
        {!onayli && (
          <span className="rozet uyari" style={{ marginRight: 8 }}>
            Rapor onaylanmadı — bu çıktı taslaktır
          </span>
        )}
        <button className="d" onClick={() => git(-1)}>✖ Kapat</button>
      </div>

      <RadyolojiRaporBelgesi veri={veri} />
    </div>
  );
}

/** Rapor çıktısının verisi (GET /api/radyoloji/rapor/{id}/cikti). */
export type RaporCiktiVerisi = {
  rapor: Satir; bolumler: Satir[]; alanlar: Satir[]; ekler: Satir[]; kurum: Satir | null;
  /** TİPOGRAFİ (1344): raporun etkin tipografisi (onaylıda onay damgası). */
  tipografi?: Record<string, unknown>; tipografiDamga?: boolean;
  /** RAPOR BAĞLANTISI (1389): onaylı raporda hasta bağlantısı - çıktının köşesine karekod. Yoksa basılmaz. */
  baglanti?: { kod?: string; webKok?: string; sonGecerli?: string } | null;
};

/**
 * A4 RAPOR BELGESİ: çıktı sayfası ve rapor kartının yazdırma önizlemesi (CiktiMenusu) AYNI belgeyi çizer -
 * kâğıda giden ile önizlenen ayrışmasın.
 */
export function RadyolojiRaporBelgesi({ veri }: { veri: RaporCiktiVerisi }) {
  const r = veri.rapor;
  const k = veri.kurum ?? {};
  const onayli = Number(r.durum ?? 0) === 3;
  const adresSatiri = [k.adres, [k.ilce, k.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');
  // TİPOGRAFİ (1344): ekran A4'ü ile aynı CSS değişkenleri; kâğıt kenar boşluğu ayardan (@page).
  const tip = tipografiOku(veri.tipografi);
  return (
    <div className="cikti-sayfa" style={tipografiStil(tip)}>
      <style>{`@media print { @page { size: A4; margin: ${tip.kenar}mm } .rapor-cikti .cikti-sayfa { padding: 0 } }`}</style>
      {/* --- KURUM ANTETI --- */}
      <div className="kbaslik">
        <AntetLogo dokumanId={k.logoDokumanId as number | undefined} yedek="🏥" />
        <div>
          <h1>{String(k.unvan ?? '—')}</h1>
          <div className="alt">
            Radyoloji Bölümü{adresSatiri ? ` · ${adresSatiri}` : ''}<br />
            {[k.telefon ? `Tel: ${k.telefon}` : '',
              k.mersisNo ? `MERSİS ${k.mersisNo}` : '',
              k.vkno ? `VKN ${k.vkno}` : ''].filter(Boolean).join(' · ')}
          </div>
        </div>
        <div className="sag">
          Rapor No: <b>{String(r.raporNo ?? '') || '(onayda verilir)'}</b><br />
          Protokol: {String(r.protokolNo ?? '—')}<br />
          Accession: {String(r.accessionNo ?? '—')}
        </div>
      </div>

      {/* REVİZE (1374): arşiv kopyası - geçerli rapor değildir. */}
      {Number(r.revize ?? 0) === 1 && (
        <div style={{ border: '2px solid #c0392b', color: '#c0392b', fontWeight: 700, textAlign: 'center',
                      padding: '6px 8px', margin: '6px 0' }}>
          REVİZE EDİLDİ — {String(r.revizeTarihi ?? '').replace('T', ' ').slice(0, 16)} tarihinde revize edilmiştir;
          bu çıktı raporun ÖNCEKİ hâlidir, geçerli rapor değildir.
          {r.revizeNedeni ? <div style={{ fontWeight: 400 }}>Neden: {String(r.revizeNedeni)}</div> : null}
        </div>
      )}
      <div className="rapadi">
        {RAPOR_ADI[Number(r.modalite ?? 0)] ?? 'Radyolojik İnceleme Raporu'}
      </div>

      {/* --- KIMLIK IKILISI --- */}
      <div className="kimlik">
        <div><span className="et">Hasta</span><span className="dg">{String(r.hastaAdi ?? '—')}</span></div>
        <div><span className="et">Tetkik</span><span className="dg">{String(r.tetkikAdi ?? '—')}</span></div>
        <div>
          <span className="et">Doğum T. / Yaş</span>
          <span className="dg">
            {[gunNokta(r.dogumTarihi), yasMetni(r.dogumTarihi), cinsiyetAdi(r.cinsiyet)]
              .filter(Boolean).join(' · ') || '—'}
          </span>
        </div>
        <div>
          <span className="et">Çekim Tarihi</span>
          <span className="dg">{r.cekimTarihi ? tarihSaat(r.cekimTarihi) : '—'}</span>
        </div>
        <div><span className="et">Hasta No</span><span className="dg">{String(r.hastaNo ?? '—')}</span></div>
        <div>
          <span className="et">Rapor Tarihi</span>
          <span className="dg">{r.onayTarihi ? tarihSaat(r.onayTarihi)
                              : r.yazmaTarihi ? tarihSaat(r.yazmaTarihi) : '—'}</span>
        </div>
        <div>
          <span className="et">İsteyen Hekim</span>
          <span className="dg">
            {String(r.isteyen ?? '—')}
            {r.isteyenKurum ? ` · ${r.isteyenKurum}` : ''}
          </span>
        </div>
        <div><span className="et">Ödeyen Kurum</span>
             <span className="dg">{String(r.odeyenKurum ?? '') || 'Hasta kendi öder'}</span></div>
      </div>

      {/* --- KLINIK BILGI: istemden gelir, radyoloğun yazdığı bölüm değil.
             Şablonda "Klinik Bilgi" bölümü VARSA burada tekrar basılmaz -
             rapor yazılırken o bölüm zaten istemin metniyle dolduruluyor,
             ikisi birden basılınca aynı cümle iki kez çıkıyordu. --- */}
      {/* TEK PARÇA raporda klinik bilgi metnin içinde (şablondan) - ayrıca basılmaz. */}
      {!tekParcaMi(veri.bolumler) && !veri.bolumler.some(b => String(b.baslik ?? '')
                                  .toLocaleLowerCase('tr').includes('klinik'))
       && String(r.klinikBilgi ?? '').trim() !== '' && (
        <div className="rapor-bolum">
          <h3>Klinik Bilgi</h3>
          <p>
            {String(r.klinikBilgi)}
            {String(r.onTani ?? '').trim() !== '' && ` Ön tanı: ${r.onTani}.`}
          </p>
        </div>
      )}

      {/* --- RAPOR BOLUMLERI (yalniz basilacaklar) --- */}
      {veri.bolumler.map((b, i) => (
        <div className="rapor-bolum" key={i}>
          {/* Tek parça raporun "Rapor" başlığı basılmaz - başlıklar metnin içinde. */}
          {!tekParcaMi(veri.bolumler) && <h3>{String(b.baslik ?? '')}</h3>}
          {/* BİÇİMLİ METİN (1195): sunucuda beyaz listeyle temizlenmiş HTML; yoksa düz metin. */}
          {b.metinHtml ? <div className="rapor-html" dangerouslySetInnerHTML={{ __html: String(b.metinHtml) }} />
                       : <p>{String(b.metin ?? '')}</p>}
        </div>
      ))}

      {/* --- SKOR / OLCUM ALANLARI --- */}
      {veri.alanlar.length > 0 && (
        <div className="rapor-bolum">
          <h3>Ölçüm / Skorlama</h3>
          <table className="cikti-alan">
            <tbody>
              {veri.alanlar.map((a, i) => (
                <tr key={i}>
                  <td>{String(a.alanAd ?? '')}</td>
                  <td><b>{String(a.deger ?? '')}</b></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* --- EK RAPORLAR: orijinalin ALTINDA, metni degistirmeden. --- */}
      {veri.ekler.map((e, i) => (
        <div className="bolum ek-rapor" key={`ek${i}`}>
          <h3>
            Ek Rapor (Addendum)
            {e.onayTarihi ? ` · ${tarihSaat(e.onayTarihi)}` : ''}
            {e.raporNo ? ` · ${e.raporNo}` : ''}
          </h3>
          <p>{String(e.metin ?? '')}</p>
        </div>
      ))}

      {/* --- IMZA --- */}
      <div className="imza">
        <div className="imzak">
          <div className="cizgi" />
          <b>{String(r.onaylayan ?? '') || String(r.yazan ?? '') || '—'}</b><br />
          Radyoloji Uzmanı
          {onayli && (
            <div className="eimza">
              ✓ Elektronik olarak onaylandı · {tarihSaat(r.onayTarihi)}
            </div>
          )}
        </div>
      </div>

      <div className="dipnot">
        Bu rapor yalnızca yukarıda adı geçen tetkike aittir; klinik bulgular ve
        diğer tetkiklerle birlikte değerlendirilmelidir.
        {r.cihazAdi ? ` Çekim cihazı: ${r.cihazAdi}.` : ''}
      </div>

      {/* --- KAREKOD (1389): raporu telefonda gör. Onaylı raporda, bağlantı varsa. --- */}
      {onayli && veri.baglanti?.kod && (() => {
        const adres = raporBaglantisi(veri.baglanti.kod, veri.baglanti.webKok);
        return (
          <div className="rapor-karekod" data-testid="rapor-karekod">
            <Karekod deger={adres} baslik="Rapor bağlantısı" />
            <div>
              <b>Raporunuzu telefonda görün</b>
              Karekodu telefonunuzun kamerasıyla okutun ya da<br />
              <span className="rk-adres">{adres.replace(/^https?:\/\//, '')}</span>
              {veri.baglanti.sonGecerli && <><br />{gunNokta(veri.baglanti.sonGecerli)} tarihine kadar geçerlidir.</>}
            </div>
          </div>
        );
      })()}
    </div>
  );
}
