import { useCallback, useContext, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { EkranSekmesiBaglami } from '../bilesenler/sekmeBaglami';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { mesaj, onay } from '../bilesenler/mesaj';
import { c } from '../dil/ceviri';
import { FONTLAR, TIPOGRAFI_OZGUN, TIPOGRAFI_VARSAYILAN, tipografiOku, tipografiOzeti, tipografiStil, type Tipografi } from './radyoloji/tipografi';

/**
 * RADYOLOJİ › AYARLAR › RAPOR TİPOGRAFİSİ (1344, mockup Ekranlar/Radyoloji/radyoloji_rapor_tipografi.html).
 * Kurum düzeyi tek ayar; solda alanlar, sağda aynı örnek raporun "şimdi (özgün)" ve "seçiminiz" A4 karşılaştırması.
 * Kaydetmek şablon kayıtlarını değiştirmez; onaylı raporlar damgalarıyla korunur (rapor ekranında rozet).
 */
export function RadyolojiTipografi() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const [ayar, setAyar] = useState<Tipografi>(TIPOGRAFI_VARSAYILAN);
  const [kayitli, setKayitli] = useState<Tipografi>(TIPOGRAFI_VARSAYILAN);
  const [duzenle, setDuzenle] = useState(false);
  const [damgali, setDamgali] = useState(0);
  const [eski, setEski] = useState({ kendi: 0, kurum: 0, ozel: 0 });
  const [topluCalisiyor, setTopluCalisiyor] = useState(false);
  // DENEME BASKISI (kullanıcı 14.11.2026): seçili (kaydedilmemiş olsa da) tipografiyle örnek A4 yazdırılır; kâğıtta nasıl
  //   durduğu görülmeden kaydetmek gerekmez. Yazdırma penceresi kapanınca (afterprint) baskı kabı kaldırılır.
  const [baski, setBaski] = useState(false);
  useEffect(() => {
    if (!baski) return;
    const bitti = () => setBaski(false);
    window.addEventListener('afterprint', bitti);
    const z = window.setTimeout(() => window.print(), 150);
    return () => { window.clearTimeout(z); window.removeEventListener('afterprint', bitti) };
  }, [baski]);
  const [hata, setHata] = useState<string | null>(null);
  const [kaydediliyor, setKaydediliyor] = useState(false);

  const yukle = useCallback(async () => {
    try {
      const y = await api.radyolojiTipografi();
      const t = tipografiOku(y.ayar);
      setAyar(t); setKayitli(t); setDuzenle(Boolean(y.duzenle)); setDamgali(Number(y.damgaliRapor ?? 0)); setHata(null);
      setEski({ kendi: Number(y.eskiSablon?.kendi ?? 0), kurum: Number(y.eskiSablon?.kurum ?? 0), ozel: Number(y.eskiSablon?.ozel ?? 0) });
    } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const degisti = JSON.stringify({ ...ayar, kaynak: '' }) !== JSON.stringify({ ...kayitli, kaynak: '' });
  const d = (k: Partial<Tipografi>) => setAyar(a => ({ ...a, ...k }));

  const kaydet = async () => {
    if (!degisti || kaydediliyor) return;
    if (!await onay(c('Rapor tipografisi değişecek: taslak raporların ekranı ve yeni çıktılar bu ayarla çizilir. '
                      + 'Onaylı raporlar damgalarıyla aynı kalır. Devam edilsin mi?'))) return;
    setKaydediliyor(true);
    try {
      const y = await api.radyolojiTipografiKaydet({ font: ayar.font, punto: ayar.punto, satir: ayar.satir, paragraf: ayar.paragraf,
                                                     hiza: ayar.hiza, kenar: ayar.kenar, baslikPunto: ayar.baslikPunto });
      const t = tipografiOku(y.ayar); setAyar(t); setKayitli(t);
      mesaj(c('Rapor tipografisi kaydedildi.'));
    } catch (h) { setHata(hataMetni(h)) }
    finally { setKaydediliyor(false) }
  };

  // TOPLU (kullanıcı 14.11.2026: "toplu düğmeyi ekle"): eski HBYS Word şablonları kurum ayarına / kendi biçimine; geri alınabilir.
  const toplu = async (islem: 'kurum' | 'kendi') => {
    const adet = islem === 'kurum' ? eski.kendi : eski.kurum;
    if (adet === 0 || topluCalisiyor) return;
    const soru = islem === 'kurum'
      ? `${adet.toLocaleString('tr-TR')} eski HBYS şablonu kurum tipografisine alınacak: bu şablonların yeni / taslak raporları kurum ayarıyla çizilir `
        + '(gömülü biçimli metin kendi fontunu korur). Onaylı raporlar değişmez. İstediğiniz an geri alınabilir. Devam edilsin mi?'
      : `${adet.toLocaleString('tr-TR')} eski HBYS şablonu kendi biçimine (özgün görünüm) döndürülecek. Devam edilsin mi?`;
    if (!await onay(c(soru))) return;
    setTopluCalisiyor(true);
    try {
      const y = await api.radyolojiTipografiEskiSablon(islem);
      mesaj(`${Number(y.adet).toLocaleString('tr-TR')} ${c('şablon güncellendi.')}`);
      await yukle();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setTopluCalisiyor(false) }
  };

  const seg = <T extends string | number>(deger: T, secenekler: { v: T; ad: string }[], sec: (v: T) => void) => (
    <span className="seg rt-seg" role="group">
      {secenekler.map(s => (
        <button key={String(s.v)} type="button" className={deger === s.v ? 'on' : ''} disabled={!duzenle}
                onClick={() => sec(s.v)}>{s.ad}</button>))}
    </span>);

  return (
    <>
      {/* ARAÇ ÇUBUĞU (kullanıcı 14.11.2026): düğmeler solda, başlık düğmelerin sağında, Kapat sağa yaslı. */}
      <div className="rt-arac">
        <button type="button" className="d bir" disabled={!duzenle || !degisti || kaydediliyor} onClick={() => void kaydet()}>
          💾 {c('Kaydet')}</button>
        <button type="button" className="d" disabled={!duzenle} onClick={() => setAyar({ ...TIPOGRAFI_VARSAYILAN })}
                title={c('Dünya pratiği: Arial 10,5 · 1,3')}>↺ {c('Varsayılana dön')}</button>
        <button type="button" className="d" onClick={() => setBaski(true)}
                title={c('Seçili tipografiyle örnek raporu yazdırır (kaydetmek gerekmez; yazdırma penceresinde PDF de seçilebilir).')}>
          🖨 {c('Deneme baskısı')}</button>
        <span className="rt-baslik"><b>🖨 {c('Rapor Tipografisi')}</b><span className="yol">{c('Radyoloji › Ayarlar › Rapor Tipografisi')}</span></span>
        <span className="ck-bosluk" />
        <button type="button" className="d" onClick={() => void (async () => {
          if (degisti && !await onay(c('Kaydedilmemiş değişiklik var. Kaydetmeden kapatılsın mı?'))) return;
          if (ekranSekmesi) ekranSekmesi.kapat(); else git('/radyoloji-pano');
        })()}>✖ {c('Kapat')}</button>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!duzenle && !hata && <div className="bilgi-kutusu">{c('Bu ayarı yalnız görüntüleyebilirsiniz (radyoloji.tipografi Değiştir yetkisi gerekir).')}</div>}

      <div className="rt-govde">
        <div className="rt-form">
          <div className="kagrup rt-grp">
            <h5>{c('Gövde')}</h5>
            <div className="rt-fld"><label>{c('Font ailesi')}</label>
              <div className="rt-radyo">
                {Object.entries(FONTLAR).map(([kod, f]) => (
                  <label key={kod}><input type="radio" name="rt-font" checked={ayar.font === kod} disabled={!duzenle}
                                          onChange={() => d({ font: kod })} />
                    <span style={{ fontFamily: f.css }}>{f.ad}</span> <small>{c(f.not)}</small></label>))}
              </div>
            </div>
            <div className="rt-fld"><label>{c('Punto')}</label>
              {seg(ayar.punto, [9, 10, 10.5, 11, 12].map(v => ({ v, ad: v.toLocaleString('tr-TR') })), v => d({ punto: v }))}</div>
            <div className="rt-fld"><label>{c('Satır aralığı')}</label>
              {seg(ayar.satir, [1.15, 1.3, 1.5].map(v => ({ v, ad: v.toLocaleString('tr-TR') })), v => d({ satir: v }))}</div>
            <div className="rt-fld"><label>{c('Paragraf arası')}</label>
              {seg(ayar.paragraf, [0, 6, 12].map(v => ({ v, ad: v === 0 ? '0' : `${v} pt` })), v => d({ paragraf: v }))}</div>
            <div className="rt-fld"><label>{c('Hizalama')}</label>
              {seg(ayar.hiza, [{ v: 'sol' as const, ad: c('Sol') }, { v: 'iki' as const, ad: c('İki yana') }], v => d({ hiza: v }))}</div>
          </div>

          <div className="kagrup rt-grp">
            <h5>{c('Başlıklar ve sayfa')}</h5>
            <div className="rt-fld"><label>{c('Bölüm başlığı')}</label><span className="sonuk">{c('BÜYÜK HARF · kalın · gövde puntosu (sabit)')}</span></div>
            <div className="rt-fld"><label>{c('Rapor başlığı')}</label>
              <span className="rt-yan">{seg(ayar.baslikPunto, [12, 13, 14].map(v => ({ v, ad: String(v) })), v => d({ baslikPunto: v }))}<span className="sonuk kucuk">pt · {c('kalın · ortalı')}</span></span></div>
            <div className="rt-fld"><label>{c('Kenar boşluğu')}</label>
              <span className="rt-yan">{seg(ayar.kenar, [15, 18, 20].map(v => ({ v, ad: String(v) })), v => d({ kenar: v }))}<span className="sonuk kucuk">mm · A4</span></span></div>
            <div className="rt-fld"><label>{c('Renk')}</label><span className="sonuk">{c('Yok - siyah/beyaz baskı ve faks (sabit)')}</span></div>
          </div>

          <div className="kagrup rt-grp">
            <h5>{c('Eski HBYS (Word) şablonları')}</h5>
            <div className="rt-not"><ul>
              <li>{c('Aktarılan Word şablonları kendi biçimini korur; kurum ayarı onları etkilemez. Toplu olarak kurum tipografisine alınabilir ve geri döndürülebilir.')}</li>
              <li><b>{c('Kendi biçimi')}: {eski.kendi.toLocaleString('tr-TR')}</b> · {c('Kurum ayarı')}: {eski.kurum.toLocaleString('tr-TR')} · {c('Özel')}: {eski.ozel.toLocaleString('tr-TR')}</li>
            </ul></div>
            <div className="rt-yan" style={{ marginTop: 6 }}>
              <button type="button" className="d bir" disabled={!duzenle || topluCalisiyor || eski.kendi === 0} onClick={() => void toplu('kurum')}>
                ⇒ {c('Kurum tipografisine uydur')} ({eski.kendi.toLocaleString('tr-TR')})</button>
              <button type="button" className="d" disabled={!duzenle || topluCalisiyor || eski.kurum === 0} onClick={() => void toplu('kendi')}>
                ↩ {c('Kendi biçimine döndür')} ({eski.kurum.toLocaleString('tr-TR')})</button>
            </div>
          </div>

          <div className="kagrup rt-grp rt-not">
            <h5>{c('Etkisi')}</h5>
            <ul>
              <li>{c('Ekrandaki A4 editörü, çıktı/PDF ve e-imza belgesi için ortaktır (ne görüyorsan onu imzalarsın).')}</li>
              <li>{c('Şablon kayıtları değişmez. Şablon kartında "Tipografi: Özel" ya da "Şablonun kendi biçimi" seçili olanlar bu ayardan etkilenmez; eski HBYS Word şablonları kendi biçimini korur.')}</li>
              <li>{c('Onaylı raporlar onay anındaki tipografiyle damgalıdır; bu ayar onları değiştirmez.')} {damgali > 0 && <b>({damgali.toLocaleString('tr-TR')} {c('damgalı rapor')})</b>}</li>
              <li>{c('Bakanlık / SKS görünüm şartı koymaz; zorunlu içerik blokları (kimlik, tetkik, tarih, hekim, dört parça, imza, rapor no) her tipografide basılır.')}</li>
            </ul>
          </div>
        </div>

        <div className="rt-oniz">
          <OrnekA4 baslik={c('Şimdi (özgün)')} t={TIPOGRAFI_OZGUN} rozet="eski" />
          <OrnekA4 baslik={degisti ? c('Seçiminiz (kaydedilmedi)') : c('Kurum ayarı')} t={ayar} rozet="oneri" />
        </div>
      </div>

      {/* DENEME BASKISI: ekranda görünmez, yalnız yazdırmada (tema.css @media print .rt-baski). Gerçek boy, @page kenarı ayardan. */}
      {baski && (
        <div className="rt-baski">
          <style>{`@media print { @page { size: A4; margin: ${ayar.kenar}mm } }`}</style>
          <div className="rt-a4 rt-a4-tam" style={tipografiStil(ayar)}><OrnekA4Icerik /></div>
        </div>
      )}
    </>
  );
}

/** Aynı örnek rapor, verilen tipografiyle; gerçek A4 (794×1123 px) %52 küçültülür ki punto oranı gerçekçi kalsın. */
function OrnekA4({ baslik, t, rozet }: { baslik: string; t: Tipografi; rozet: 'eski' | 'oneri' }) {
  return (
    <div>
      <h6 className="rt-oniz-bas">{baslik} <span className={`rt-roz ${rozet}`}>{tipografiOzeti(t)}</span></h6>
      <div className="rt-a4k">
        <div className="rt-a4" style={{ ...tipografiStil(t), padding: `${t.kenar}mm` }}><OrnekA4Icerik /></div>
      </div>
    </div>
  );
}

/** Örnek rapor gövdesi: ekran önizlemesi ve deneme baskısı aynı içerik. */
function OrnekA4Icerik() {
  return (
    <>
          <div className="rt-antet"><b>{c('Kurum Adı')}</b><span>Radyoloji</span></div>
          <div className="rt-kimlik">
            <span><b>Hasta:</b> Örnek HASTA</span><span><b>Protokol:</b> 2026-004512</span>
            <span><b>TC:</b> 12*******34 · E · 44</span><span><b>Accession:</b> KTB0000000000337</span>
            <span><b>Tetkik:</b> MRG, Omuz - Sağ</span><span><b>Çekim:</b> 14.11.2026 10:42</span>
          </div>
          <div className="rt-rb">MANYETİK REZONANS GÖRÜNTÜLEME RAPORU</div>
          <div className="rt-bb">TEKNİK</div>
          <p>Sağ omuz eklemine yönelik koronal ve sagittal T1A, PD-FS ve aksiyel T2A-FS sekanslarda kontrastsız MR incelemesi yapıldı.</p>
          <div className="rt-bb">KARŞILAŞTIRMA</div>
          <p>Karşılaştırılabilecek önceki tetkik yok.</p>
          <div className="rt-bb">BULGULAR</div>
          <p>Supraspinatus tendonunda distal kesimde intrasubstans sinyal artışı (tendinozis) izlenmektedir; tam kat yırtık saptanmamıştır.
            İnfraspinatus, subskapularis ve teres minör tendonları doğaldır. Akromioklaviküler eklemde hafif dejeneratif değişiklikler ve
            minimal efüzyon mevcuttur. Glenohumeral eklem aralığında fizyolojik sınırlarda sıvı izlenmiştir. Labrum bütünlüğü korunmuştur.</p>
          <div className="rt-bb">SONUÇ VE ÖNERİLER</div>
          <p>Supraspinatus tendinozisi. Akromioklaviküler eklem dejenerasyonu. Klinik korelasyon önerilir.</p>
          <div className="rt-imza"><b>Uzm. Dr. Örnek RADYOLOG</b><small>Radyoloji Uzmanı · Dip. No 123456</small><small>e-imzalıdır · 14.11.2026 14:05</small></div>
          <div className="rt-alt"><span>Rapor No: RAD-2026-01187</span><span>1 / 1</span></div>
    </>
  );
}
