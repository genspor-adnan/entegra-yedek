import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from '../bilesenler/bicim';

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

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

/** Dogum tarihinden yas - kartlardaki hesapla ayni kural. */
const yas = (dogum: unknown): string => {
  const m = String(dogum ?? '').slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(m)) return '';
  const d = new Date(m), b = new Date();
  let y = b.getFullYear() - d.getFullYear();
  const ay = b.getMonth() - d.getMonth();
  if (ay < 0 || (ay === 0 && b.getDate() < d.getDate())) y--;
  return String(y);
};

const CINSIYET: Record<number, string> = { 1: 'Erkek', 2: 'Kadın' };

/** Modaliteye gore rapor basligi (mockup "Manyetik Rezonans İnceleme Raporu"). */
const RAPOR_ADI: Record<number, string> = {
  1: 'Direkt Grafi İnceleme Raporu',
  2: 'Ultrasonografi İnceleme Raporu',
  3: 'Bilgisayarlı Tomografi İnceleme Raporu',
  4: 'Manyetik Rezonans İnceleme Raporu',
  5: 'Mamografi İnceleme Raporu',
  6: 'Kemik Dansitometri Raporu',
};

export function RadyolojiRaporCikti() {
  const { id } = useParams();
  const git = useNavigate();
  const [veri, setVeri] = useState<{
    rapor: Satir; bolumler: Satir[]; alanlar: Satir[]; ekler: Satir[]; kurum: Satir | null;
  } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.radyolojiRaporCikti(Number(id)) as never);
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const r = veri.rapor;
  const k = veri.kurum ?? {};
  const onayli = Number(r.durum ?? 0) === 3;
  const adresSatiri = [k.adres, [k.ilce, k.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');

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

      <div className="cikti-sayfa">
        {/* --- KURUM ANTETI --- */}
        <div className="kbaslik">
          <div className="logo">🏥</div>
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
              {[gun(r.dogumTarihi), yas(r.dogumTarihi), CINSIYET[Number(r.cinsiyet ?? 0)]]
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
        {!veri.bolumler.some(b => String(b.baslik ?? '')
                                    .toLocaleLowerCase('tr').includes('klinik'))
         && String(r.klinikBilgi ?? '').trim() !== '' && (
          <div className="bolum">
            <h3>Klinik Bilgi</h3>
            <p>
              {String(r.klinikBilgi)}
              {String(r.onTani ?? '').trim() !== '' && ` Ön tanı: ${r.onTani}.`}
            </p>
          </div>
        )}

        {/* --- RAPOR BOLUMLERI (yalniz basilacaklar) --- */}
        {veri.bolumler.map((b, i) => (
          <div className="bolum" key={i}>
            <h3>{String(b.baslik ?? '')}</h3>
            <p>{String(b.metin ?? '')}</p>
          </div>
        ))}

        {/* --- SKOR / OLCUM ALANLARI --- */}
        {veri.alanlar.length > 0 && (
          <div className="bolum">
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
      </div>
    </div>
  );
}
