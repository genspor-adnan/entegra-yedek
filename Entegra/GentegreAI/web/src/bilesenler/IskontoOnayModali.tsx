import { useState } from 'react';
import { Modal } from './Modal';
import { para, tarihSaat, paraYaz } from './bicim';
import { hataMetni, type IskontoTalebi } from '../api/sozlesme';
import { api } from '../api/istemci';

/** Cinsiyet ikonu + ilk harfi (663): 1 erkek · 2 kadın · 0 bilinmiyor. */
function cinsiyetRozeti(kod: number) {
  if (kod === 1) return { ikon: '♂', harf: 'E', sinif: 'cins-e' };
  if (kod === 2) return { ikon: '♀', harf: 'K', sinif: 'cins-k' };
  return { ikon: '•', harf: '?', sinif: 'cins-y' };
}

/**
 * İSKONTO ONAY PENCERESİ (663).
 *
 * Yetkili kararı BELGEYİ AÇMADAN vermeli - zilden tıklayıp başvuru kartını
 * açmak, sırada bekleyen hastayı iki ekran daha bekletirdi. O yüzden karara
 * yetecek ne varsa burada: kim (hasta şeridi), ne için (hizmetler + toplam),
 * ne kadar (oran) ve neden (gerekçe + isteyen).
 *
 * Tutarlar TALEP ANINDA dondurulmuş satır tutarlarıdır (`iskonto_talep_satir`):
 * onay ertesi gün gelse de yetkilinin gördüğü rakam, kararını verdiği rakamdır.
 */
export function IskontoOnayModali({ talep, tavan, onKapat, onSonuc }: {
  talep: IskontoTalebi;
  /** Kullanıcının iskonto tavanı - onaylanan oran bunu aşamaz. */
  tavan: number;
  onKapat(): void;
  /** Karar verildi: zil listesini tazelemek için. */
  onSonuc(): void;
}) {
  const [oran, setOran] = useState(String(talep.oran));
  const [not, setNot] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  const c = cinsiyetRozeti(talep.cinsiyet);
  const sayi = Number(String(oran).replace(',', '.')) || 0;
  /** Onaylanan oran talebi de tavanı da aşamaz - ikisinin küçüğü sınırdır. */
  const ustSinir = Math.min(talep.oran, tavan);
  const indirim = talep.tutar * sayi / 100;

  const karar = async (onayMi: boolean) => {
    setHata(null);
    if (onayMi && !(sayi > 0)) { setHata('Onaylanan oran sıfırdan büyük olmalı.'); return }
    if (onayMi && sayi > ustSinir + 0.0001) {
      setHata(`En çok %${ustSinir} onaylayabilirsiniz.`); return;
    }
    // RET GEREKÇESİ ZORUNLU: banko onu hastaya söyleyecek.
    if (!onayMi && not.trim() === '') { setHata('Ret gerekçesi zorunlu.'); return }
    setCalisiyor(true);
    try {
      if (onayMi) await api.iskontoOnayla(talep.id, sayi, not.trim());
      else await api.iskontoReddet(talep.id, not.trim());
      onSonuc();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setCalisiyor(false) }
  };

  return (
    <Modal baslik="İskonto Onayı" dar buyutmeYok enUst onKapat={onKapat}
           alt={
             <>
               <button type="button" className="d" disabled={calisiyor}
                       onClick={onKapat}>Kapat</button>
               <button type="button" className="d teh" disabled={calisiyor}
                       onClick={() => void karar(false)}>✖ Reddet</button>
               <button type="button" className="d bir" disabled={calisiyor}
                       onClick={() => void karar(true)}>✔ Onayla</button>
             </>
           }>
      <div className="isk-onay">
        {/* HASTA ŞERİDİ: kim için karar veriyorum. */}
        <div className="isk-hasta">
          <span className={`isk-cins ${c.sinif}`} title={c.harf === 'E' ? 'Erkek'
            : c.harf === 'K' ? 'Kadın' : 'Cinsiyet bilinmiyor'}>
            {c.ikon} {c.harf}
          </span>
          <b className="isk-ad">{talep.hasta || talep.belgeNo}</b>
          {talep.yas > 0 && <span className="isk-yas">{talep.yas}</span>}
          <span className="sp" />
          <span className="sonuk">{talep.belgeNo}</span>
        </div>
        <div className="isk-alt-serit">
          {talep.kurum && <span>🏛 {talep.kurum}</span>}
          {talep.doktor && <span>👨‍⚕️ {talep.doktor}</span>}
        </div>

        {/* ÜCRETLER yan yana, virgülle - kalem listesi bir tablo kadar yer
            kaplamasın; karar için "neler var ve toplam ne" yeter. */}
        <div className="isk-kutu">
          <div className="isk-baslik">Ücretler</div>
          <div className="isk-kalemler">
            {talep.kalemler.length === 0
              ? <span className="sonuk">{talep.satirSayisi} satır</span>
              : talep.kalemler.map((k, i) => (
                  <span key={i}>
                    {k.ad} <span className="sonuk">{para.format(k.tutar)}</span>
                    {i < talep.kalemler.length - 1 ? ', ' : ''}
                  </span>
                ))}
          </div>
          <div className="isk-toplam">
            <span>Toplam</span><b>{paraYaz(talep.tutar)}</b>
          </div>
        </div>

        {/* TALEP: ne isteniyor, neden, kim istedi. */}
        <div className="isk-kutu">
          <div className="isk-baslik">Talep</div>
          <div className="isk-satir"><span>İstenen iskonto</span>
            <b>%{talep.oran}</b></div>
          <div className="isk-satir"><span>Gerekçe</span>
            <b>{talep.gerekce}</b></div>
          <div className="isk-satir"><span>Banko görevlisi</span>
            <b>{talep.isteyen}</b></div>
          <div className="isk-satir"><span>İstek zamanı</span>
            <b>{tarihSaat(talep.istekTs)}</b></div>
        </div>

        {/* KARAR: kısmi onay birinci sınıf - kutu istenen oranla açılır. */}
        <div className="alan-izgara tek-sutun ayar-formu para-sor">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Onaylanan oran</span>
            <span className="ikili">
              <input className="hiza-sag genis-deger" value={oran} autoFocus
                     onChange={e => { setOran(e.target.value); setHata(null) }} />
              <span className="birim-metin">% (en çok {ustSinir})</span>
            </span>
            <span className="ipucu">
              Karşılığı: <b>−{paraYaz(indirim)}</b> ·
              {' '}kalan <b>{paraYaz(talep.tutar - indirim)}</b>
            </span>
          </label>
          <label className="alan">
            <span className="etiket">Karar notu</span>
            <input value={not} placeholder="Onayda isteğe bağlı, RETTE zorunlu"
                   onChange={e => { setNot(e.target.value); setHata(null) }} />
          </label>
        </div>

        {!!hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}
