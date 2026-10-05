import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GozBeklemeEkrani as Veri } from '../../api/uclar/goz';
import { c } from '../../dil/ceviri';
import { GOZ_ISTASYON, GOZ_KANBAN_SUTUNLARI, GOZ_PANO_ESIK } from '../../bilesenler/goz/gozPanoSabitleri';

/**
 * BEKLEME SALONU EKRANI (976, mockup `Ekranlar/Goz/goz_unite_panosu.html`
 * araç çubuğundaki "🖥 Bekleme Ekranı").
 *
 * <b>Panonun değil SALONUN ekranı.</b> Pano "ünite tıkalı mı" sorusunu
 * personele cevaplıyor; bu ekran hastaya "sıram geldi mi" diyor. Aynı veriyi
 * iki ekranın da okuması gerekiyor ama aynı düzende göstermek olmaz: burada
 * punto uzaktan okunacak kadar büyük, düğme hiç yok.
 *
 * <b>Ad MASKELİ</b> ve maskeleme sunucuda (<c>v_goz_bekleme_ekrani</c>):
 * salonda oturan herkes ekranı okuyor. Tam adı istemciye gönderip orada
 * kısaltmak, tarayıcı konsolunu da salonun bir parçası yapardı.
 *
 * <b>Düğme yok, kayıt yazmaz.</b> Çağırma / taşıma panoda kalıyor; salondaki
 * ekranda düğme olsaydı sahibi belli olmayan bir kayıt girişi açılırdı.
 *
 * <b>15 saniyede bir tazelenir</b> (panonun yarısı): çağrı anında ekranda
 * görünmezse hasta kalkmıyor, ekranın işi de bu.
 */

const ISTASYON = GOZ_ISTASYON;
const TAZELEME_MS = GOZ_PANO_ESIK.beklemeEkraniMs;

const saat = (t: Date) =>
  `${String(t.getHours()).padStart(2, '0')}:${String(t.getMinutes()).padStart(2, '0')}`;

export function GozBeklemeEkrani() {
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [simdi, setSimdi] = useState(() => new Date());

  const yukle = useCallback(async () => {
    try { setVeri(await api.gozBeklemeEkrani()); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => {
    const t = window.setInterval(() => {
      setSimdi(new Date());
      // Ekran duvarda: sekme görünmez olduğunda istek atmaya gerek yok.
      if (!document.hidden) void yukle();
    }, TAZELEME_MS);
    return () => window.clearInterval(t);
  }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;

  const cagrilanlar = veri?.cagrilanlar ?? [];
  // KUYRUK İSTASYONA GÖRE: hasta hangi masada beklediğini biliyor, "kaç kişi
  //   var" sorusunun cevabı o masanın kuyruğu.
  const kuyruk = GOZ_KANBAN_SUTUNLARI.map(k => k.kod)
    .map(i => ({ istasyon: i, satirlar: (veri?.bekleyenler ?? []).filter(b => b.istasyon === i) }))
    .filter(k => k.satirlar.length > 0);

  return (
    <div className="gbe">
      <div className="gbe-ust">
        <b>{c('Göz Ünitesi')}</b>
        <span>{saat(simdi)}</span>
      </div>

      {/* ÇAĞRILANLAR EN ÜSTTE VE EN BÜYÜK: salondaki hastanın ekrana bakma
          sebebi bu - kuyruk ikincil bilgi. */}
      <div className="gbe-cagri">
        {cagrilanlar.length === 0 && (
          <div className="gbe-bos">{c('Şu an çağrılan hasta yok')}</div>
        )}
        {cagrilanlar.map(k => (
          <div key={k.id} className="gbe-kart">
            <b>{k.ad}</b>
            <span>{k.kaynak || c(ISTASYON[k.istasyon] ?? '')}</span>
            {k.hekim && <i>{k.hekim}</i>}
          </div>
        ))}
      </div>

      <div className="gbe-kuyruk">
        {kuyruk.map(k => (
          <div key={k.istasyon} className="gbe-kol">
            <h4>{c(ISTASYON[k.istasyon] ?? '')}<span>{k.satirlar.length}</span></h4>
            {k.satirlar.slice(0, 9).map(b => (
              <div key={b.id} className={`gbe-satir${b.cagrildi ? ' cagrildi' : ''}`}>
                <span>{b.ad}</span>
                {/* DİLATASYON SALONDA DA GÖRÜNÜR: damlası biten hasta
                    "beni atladılar mı" diye bankoya gitmesin. */}
                {b.dilatasyon === 1 && <em className="gbe-hazir">💧 {c('hazır')}</em>}
                {b.dilatasyon === 2 && <em>💧 {c('damla etkisi bekleniyor')}</em>}
                <i>{b.beklemeDk} {c('dk')}</i>
              </div>
            ))}
            {k.satirlar.length > 9 && (
              <div className="gbe-satir sonuk">+{k.satirlar.length - 9} {c('kişi')}</div>
            )}
          </div>
        ))}
        {kuyruk.length === 0 && <div className="gbe-bos">{c('Ünitede bekleyen hasta yok')}</div>}
      </div>

      <div className="gbe-alt">
        {c('Dilatasyonda')}: {veri?.dilatasyonda ?? 0} ({veri?.dilatasyonHazir ?? 0} {c('hazır')})
        <span>{c('Ekran 15 saniyede bir yenilenir · adlar gizlilik için kısaltılmıştır')}</span>
      </div>
    </div>
  );
}
