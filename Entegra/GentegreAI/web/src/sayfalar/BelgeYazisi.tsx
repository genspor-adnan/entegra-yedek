import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { BelgeYazisi as Yazi } from '../api/uclar/izin';
import { guvenli, mesaj } from '../bilesenler/mesaj';
import { AntetLogo } from '../bilesenler/AntetLogo';

/**
 * BELGE TALEBİ YAZISI (768) — personelin İK'dan istediği resmî yazının
 * KENDİSİ.
 *
 * 765'te "hazırlandı" yalnız bir işaretti; metni İK kendi bilgisayarında
 * yazıyordu ve sistem *"o yazıda ne yazıyordu"* sorusunu cevaplayamıyordu.
 * Burası metnin üretildiği, düzeltildiği ve yazdırıldığı yer.
 *
 * Yazdırma tarayıcının kendi diyalogudur ("PDF olarak kaydet" de orada);
 * ayrı bir PDF üreticisi YOK - göz/lab/radyoloji çıktılarıyla aynı karar.
 *
 * ============ ÜÇ DURUM ===============================================
 *   eksik.length > 0 → yazı üretildi ama BOŞLUKLU. Hazırlama reddedilir;
 *                      ekran nereyi doldurması gerektiğini söyler.
 *   donmus = false   → şablondan taze üretim, her açılışta yeniden çizilir.
 *   donmus = true    → bu talep için DONDURULMUŞ metin. Şablon sonradan
 *                      değişse de bu değişmez; teslim edilmiş kâğıtla
 *                      ekrandaki yazı ayrışmasın.
 */
export function BelgeYazisi() {
  const { id } = useParams();
  const git = useNavigate();
  const [y, setY] = useState<Yazi | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [duzenle, setDuzenle] = useState(false);
  const [taslak, setTaslak] = useState({ baslik: '', govde: '' });

  const yukle = async () => {
    try { const v = await api.belgeTalepYazi(Number(id)); setY(v); setTaslak({ baslik: v.baslik, govde: v.govde }) }
    catch (h) { setHata(hataMetni(h)) }
  };

  useEffect(() => { void yukle() }, [id]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!y) return <div className="yukleniyor">Yükleniyor…</div>;

  const a = y.antet;
  const adres = [a.adres, [a.ilce, a.il].filter(Boolean).join(' / ')]
    .filter(x => x.trim() !== '').join(' · ');

  const kaydet = () => guvenli(async () => {
    await api.belgeTalepYaziKaydet(Number(id), {
      baslik: taslak.baslik, govde: taslak.govde, sablonId: y.sablonId || undefined,
    });
    setDuzenle(false);
    await yukle();
    mesaj('Yazı donduruldu. Bundan sonra şablon değişse de bu metin değişmez; '
        + '"Hazırlandı" bu metni kullanır.');
  });

  return (
    <div className="sema-cikti">
      {/* Araç çubuğu YAZDIRILMAZ (@media print) - kâğıtta yalnız yazı kalır. */}
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
        <button className="d" onClick={() => window.print()}
                title="Tarayıcı yazdırma penceresinde 'PDF olarak kaydet'">📄 PDF</button>
        {duzenle
          ? <>
              <button className="d bir" onClick={kaydet}>💾 Metni Dondur</button>
              <button className="d" onClick={() => {
                setDuzenle(false); setTaslak({ baslik: y.baslik, govde: y.govde });
              }}>Vazgeç</button>
            </>
          : <button className="d" onClick={() => setDuzenle(true)}>✏️ Düzenle</button>}
        <button className="d" onClick={() => git(-1)}>← Geri</button>
        <span className="sonuk">
          {y.donmus
            ? 'Bu metin donduruldu (şablon değişse de değişmez).'
            : `Şablon: ${y.sablonAd || '—'} · henüz dondurulmadı`}
          {y.adet > 1 ? ` · ${y.adet} nüsha` : ''}
        </span>
      </div>

      {/* EKSİK YER TUTUCU: kâğıda basmadan ÖNCE söylenir. Boş bir "Görevi :"
          satırı ancak yazdırıldıktan sonra fark edilirdi. */}
      {y.eksik.length > 0 && (
        <div className="yazi-eksik">
          <b>Eksik bilgi:</b> {y.eksik.join(', ')}. Bu haliyle “Hazırlandı”
          denemez — personel kartındaki boş alanları doldurun; maaş bilgisi
          talebin kendi alanlarındadır (Maaş Tutarı / Maaş Türü).
        </div>
      )}

      <div className="cikti-sayfa">
        <div className="cikti-antet">
          {/* Resmî yazıda kurum logosu beklenir (772). Logosuz kurulumda
              kutu hiç çizilmez - boş çerçeve logonun yerini tutuyormuş gibi
              görünürdü. */}
          <AntetLogo dokumanId={a.logoDokumanId} />
          <div>
            <b>{a.unvan || '—'}</b>
            {adres && <div className="sonuk">{adres}</div>}
            {a.telefon && <div className="sonuk">Tel: {a.telefon}</div>}
            {a.vkno && <div className="sonuk">VKN: {a.vkno}{a.vd ? ` · ${a.vd}` : ''}</div>}
          </div>
          <div className="sag">
            <b>{y.talepNo || '—'}</b>
            <div className="sonuk">{new Date().toLocaleDateString('tr-TR')}</div>
          </div>
        </div>

        {duzenle
          ? <div className="cikti-blok">
              <input className="yazi-baslik-girdi" value={taslak.baslik}
                     onChange={e => setTaslak({ ...taslak, baslik: e.target.value })}
                     placeholder="Yazı başlığı" />
              {/* DÜZ METİN: biçim ekranın işi, şablonun değil - gövdede HTML
                  yok (doküman deposu da HTML'i bilerek kabul etmiyor). */}
              <textarea className="yazi-govde-girdi" rows={22} value={taslak.govde}
                        onChange={e => setTaslak({ ...taslak, govde: e.target.value })} />
            </div>
          : <>
              <h2 className="yazi-baslik">{y.baslik}</h2>
              <div className="yazi-govde">{y.govde}</div>
              {y.altNot && <div className="yazi-altnot">{y.altNot}</div>}
              <div className="yazi-imza">
                <div>
                  <div className="cizgi" />
                  <b>{y.imzaUnvan || 'Yetkili İmza'}</b>
                  <div className="sonuk">{a.unvan}</div>
                </div>
              </div>
            </>}
      </div>
    </div>
  );
}
