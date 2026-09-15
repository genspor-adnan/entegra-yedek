import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { YatakSecenegi } from '../../api/uclar/yatan';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';
import { YatakSecimi } from './YatakSecimi';

/**
 * YATIŞ KABUL — mockup `Ekranlar/Yatan/yatis_kabul.html`.
 *
 * <b>Dört adım, tek form değil.</b> Kabul masasında dört ayrı soru sırayla
 * cevaplanıyor ve üçüncüsü (provizyon) bazen dakikalar sürüyor. Tek formda
 * olsaydı, provizyon beklerken form açık kalır ve yatak kimseye verilmezdi.
 *
 * <b>Provizyon yatışı kilitlemez.</b> Acil vakada hastayı kapıda bekletmek,
 * mali riskten büyük bir risktir: provizyon alanı boş bırakılabilir, rozet
 * listede kalır ve fatura kapanmadan çözülür. Klinik karar mali kontrole
 * bağlanmaz.
 *
 * <b>Açık yatış kontrolü SUNUCUDA</b> (`/api/yatan/kabul`): kapanmamış yatışın
 * üstüne ikinci yatış, iki yatak ve iki fatura demektir. İstemcide de
 * tekrarlansaydı iki kural zamanla ayrışırdı; burada yalnız sunucunun
 * cümlesini gösteriyoruz.
 */

interface KodDeger { deger: number; ad: string }

const ADIMLAR = [
  { ad: '1 · Hasta', alt: 'kimlik' },
  { ad: '2 · Klinik & Yatak', alt: 'servis, hekim, yatak' },
  { ad: '3 · Ödeyen & Provizyon', alt: 'Medula yatış takip' },
  { ad: '4 · Onay', alt: 'dosya no · yatak' },
];

export function YatisKabulModali({ hastaId: ilkHastaId, hastaAdi: ilkHastaAdi,
                                   onKapat, onTamam }: {
  hastaId?: number | null;
  hastaAdi?: string;
  onKapat(): void;
  onTamam?(yatisId: number): void;
}) {
  const [adim, setAdim] = useState(ilkHastaId ? 1 : 0);
  const [hastaId, setHastaId] = useState<number | null>(ilkHastaId ?? null);
  const [hastaAdi, setHastaAdi] = useState(ilkHastaAdi ?? '');
  const [hastaArama, setHastaArama] = useState(false);

  const [yatisTuru, setYatisTuru] = useState(1);
  const [gelisSekli, setGelisSekli] = useState(1);
  const [taniKodu, setTaniKodu] = useState('');
  const [tahminiCikis, setTahminiCikis] = useState('');
  const [hekimId, setHekimId] = useState<number | null>(null);
  const [hekimAdi, setHekimAdi] = useState('');
  const [hekimArama, setHekimArama] = useState(false);
  const [yatak, setYatak] = useState<YatakSecenegi | null>(null);

  const [kurumId, setKurumId] = useState<number | null>(null);
  const [kurumAdi, setKurumAdi] = useState('');
  const [kurumArama, setKurumArama] = useState(false);
  const [provizyon, setProvizyon] = useState('');
  const [refakatci, setRefakatci] = useState('');
  const [refakatciTckn, setRefakatciTckn] = useState('');

  const [turler, setTurler] = useState<KodDeger[]>([]);
  const [gelisler, setGelisler] = useState<KodDeger[]>([]);
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  useEffect(() => {
    void (async () => {
      try {
        const [t, g] = await Promise.all([
          api.kodListe('yatan.yatis_tur'), api.kodListe('yatan.gelis_sekli'),
        ]);
        setTurler(t.degerler.filter(d => d.aktif === 1));
        setGelisler(g.degerler.filter(d => d.aktif === 1));
      } catch { /* kod listesi yoksa alan yine de yazılabilir */ }
    })();
  }, []);

  const ileriOlur =
    adim === 0 ? !!hastaId
    : adim === 1 ? !!yatak
    : true;

  const kaydet = async () => {
    if (!hastaId || !yatak) { setHata('Hasta ve yatak seçilmeli.'); return }
    setHata('');
    setKaydediyor(true);
    try {
      const y = await api.yatisKabul({
        hastaId, yatakId: yatak.id,
        departmanId: yatak.departmanId, hekimId,
        yatisTuru, gelisSekli,
        yatisTaniKodu: taniKodu,
        odeyenKurumId: kurumId,
        provizyonNo: provizyon,
        refakatciAd: refakatci, refakatciTckn,
        tahminiCikis: tahminiCikis || null,
      });
      mesaj(`Yatış açıldı: ${y.dosyaNo} · ${y.oda}/${y.yatak}`);
      onTamam?.(y.id);
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <>
      <TarafArama
        acik={hastaArama}
        kaynaklar={['hasta']}
        yerTutucu="Hastayı isim / TCKN ile ara…"
        onKapat={() => setHastaArama(false)}
        onSec={s => {
          setHastaId(s.id); setHastaAdi(s.unvan); setHastaArama(false);
          // HASTA DEĞİŞTİ: yatak uygunluğu cinsiyete bağlı, seçim düşer.
          setYatak(null);
        }}
      />
      <TarafArama
        acik={hekimArama}
        kaynaklar={['basvuru-hekim']}
        yerTutucu="Sorumlu hekimi ara…"
        onKapat={() => setHekimArama(false)}
        onSec={s => { setHekimId(s.id); setHekimAdi(s.unvan); setHekimArama(false) }}
      />
      <TarafArama
        acik={kurumArama}
        kaynaklar={['kurum']}
        yerTutucu="Ödeyen kurumu ara…"
        onKapat={() => setKurumArama(false)}
        onSec={s => { setKurumId(s.id); setKurumAdi(s.unvan); setKurumArama(false) }}
      />

      <Modal baslik="🛏 Yatış Kabul" onKapat={onKapat}
             alt={
               <>
                 <button className="d" onClick={onKapat}>Vazgeç</button>
                 {adim > 0 && (
                   <button className="d" onClick={() => setAdim(a => a - 1)}>‹ Geri</button>
                 )}
                 <span style={{ flex: 1 }} />
                 {adim < 3 ? (
                   <button className="d onay" disabled={!ileriOlur}
                           onClick={() => setAdim(a => a + 1)}>İleri ›</button>
                 ) : (
                   <button className="d onay" disabled={kaydediyor || !yatak}
                           onClick={() => void kaydet()}>✔ Yatışı Aç</button>
                 )}
               </>
             }>
        <div className="yatis-adimlar">
          {ADIMLAR.map((a, i) => (
            <div key={a.ad}
                 className={`adim${i === adim ? ' on' : i < adim ? ' bitti' : ''}`}
                 onClick={() => { if (i < adim || ileriOlur) setAdim(i) }}>
              {i < adim ? '✓ ' : ''}{a.ad}<b>{a.alt}</b>
            </div>
          ))}
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        {adim === 0 && (
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">Hasta</span>
              <span className="deger-serit">
                <input readOnly style={{ flex: 1, minWidth: 0 }} value={hastaAdi} placeholder="Hasta seçilmedi"
                       onClick={() => setHastaArama(true)} />
                <button className="d" onClick={() => setHastaArama(true)}>🔍 Ara</button>
              </span>
            </label>
            <div className="not">
              Hastanın <b>açık yatışı olup olmadığı kaydederken sunucuda</b> kontrol
              edilir: kapanmamış bir yatışın üstüne ikinci yatış açmak, iki yatak ve
              iki fatura demektir.
            </div>
          </div>
        )}

        {adim === 1 && (
          <>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">Yatış türü</span>
                <select value={yatisTuru} onChange={e => setYatisTuru(Number(e.target.value))}>
                  {turler.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
              </label>
              <label className="alan">
                <span className="etiket">Geliş şekli</span>
                <select value={gelisSekli} onChange={e => setGelisSekli(Number(e.target.value))}>
                  {gelisler.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
              </label>
              <label className="alan">
                <span className="etiket">Sorumlu hekim</span>
                <span className="deger-serit">
                  <input readOnly style={{ flex: 1, minWidth: 0 }} value={hekimAdi} placeholder="Seçilmedi"
                         onClick={() => setHekimArama(true)} />
                  <button className="d" onClick={() => setHekimArama(true)}>🔍</button>
                </span>
              </label>
              <label className="alan">
                <span className="etiket">Yatış tanısı (ICD)</span>
                <input value={taniKodu} placeholder="örn. J18.9"
                       onChange={e => setTaniKodu(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Tahmini çıkış</span>
                <input type="date" value={tahminiCikis}
                       onChange={e => setTahminiCikis(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Klinik / servis</span>
                <input readOnly style={{ flex: 1, minWidth: 0 }} value={yatak?.klinik || '— yatakla gelir'} />
              </label>
            </div>
            <div className="not" style={{ marginTop: 6 }}>
              <b>Klinik yataktan gelir:</b> yatak odaya, oda servise bağlı. Ayrı
              seçilseydi hasta "Dahiliye"de görünürken Ortopedi yatağında yatabilirdi.
              Tahmini çıkış boş bırakılırsa yatak, hasta çıkana kadar dolu sayılır —
              panodaki "bugün boşalacak" sayısı bu alandan doğar.
            </div>
            <h4 style={{ margin: '10px 0 4px' }}>Yatak seçimi</h4>
            {hastaId && (
              <YatakSecimi hastaId={hastaId} seciliId={yatak?.id ?? null}
                           onSec={y => setYatak(y)} />
            )}
          </>
        )}

        {adim === 2 && (
          <>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">Ödeyen kurum</span>
                <span className="deger-serit">
                  <input readOnly style={{ flex: 1, minWidth: 0 }} value={kurumAdi} placeholder="Ücretli / kendi ödemeli"
                         onClick={() => setKurumArama(true)} />
                  <button className="d" onClick={() => setKurumArama(true)}>🔍</button>
                </span>
              </label>
              <label className="alan">
                <span className="etiket">Provizyon / takip no</span>
                <input value={provizyon} onChange={e => setProvizyon(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Refakatçi</span>
                <input value={refakatci} placeholder="Ad Soyad (yakınlık)"
                       onChange={e => setRefakatci(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Refakatçi TCKN</span>
                <input value={refakatciTckn} maxLength={11}
                       onChange={e => setRefakatciTckn(e.target.value)} />
              </label>
            </div>
            <div className="not" style={{ marginTop: 6 }}>
              <b>Provizyon alınamazsa yatış engellenmez.</b> Acil vakada hastayı kapıda
              bekletmek, mali riskten büyük bir risktir; provizyonsuz yatış listede
              rozetle taşınır ve fatura kapanmadan çözülür.
            </div>
          </>
        )}

        {adim === 3 && (
          <>
            <div className="kagrup">
              <h6>Onay <span>kaydetmeden önce son kontrol</span></h6>
              <div className="ic">
                <div className="sat"><span>Hasta</span><b>{hastaAdi || '—'}</b></div>
                <div className="sat"><span>Yatak</span>
                  <b>{yatak ? `${yatak.oda} / ${yatak.yatak}` : '—'}
                     {yatak?.ucretHizmet && <span className="sonuk"> · {yatak.ucretHizmet}</span>}</b></div>
                <div className="sat"><span>Klinik / hekim</span>
                  <b>{[yatak?.klinik, hekimAdi].filter(Boolean).join(' · ') || '—'}</b></div>
                <div className="sat"><span>Ödeyen</span>
                  <b>{kurumAdi || 'Kendi ödemeli'}
                     {kurumAdi && !provizyon && <span className="rozet sari"> provizyon yok</span>}</b></div>
                <div className="sat"><span>Dosya no</span>
                  <b className="sonuk">kaydederken üretilir (Y-yyyy-nnnn)</b></div>
              </div>
            </div>
            <div className="kagrup" style={{ marginTop: 8 }}>
              <h6>Kaydedince olacaklar</h6>
              <div className="ic">
                <div className="sat"><span>Yatak</span>
                  <b>→ <span className="rozet mavi">rezerve</span>
                     <span className="sonuk"> hasta yatağına çıkınca "dolu"</span></b></div>
                <div className="sat"><span>Yatak hareketi</span>
                  <b>ilk satır açılır — yatak ücreti bu tablodan hesaplanır</b></div>
                <div className="sat"><span>Yatış durumu</span><b>Yatış kabul</b></div>
              </div>
              <div className="not">
                Kabul yatağı <b>rezerve</b> eder, dolu yapmaz: hasta henüz yatağında
                değil (evrak, provizyon, transfer). Rezerve yatak ikinci bir hastaya da
                verilemez.
              </div>
            </div>
          </>
        )}
      </Modal>
    </>
  );
}
