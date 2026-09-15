import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EmarDoz, EmarOrder } from '../../api/uclar/yatan';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';
import { tarihSaat } from '../bicim';

/**
 * İLAÇ UYGULAMA — mockup `Ekranlar/Yatan/order_ilac_uygulama.html`
 * (uygulama penceresi).
 *
 * <b>Beş doğru barkodla yapılır:</b> doğru hasta (bileklik), doğru ilaç
 * (karekod), doğru doz, doğru yol, doğru zaman. Barkod okutulmadan uygulama
 * <b>kaydedilebilir</b> — acil durumda hemşireyi ekrana kilitlemek hastaya
 * zarar verir — ama kayıt "elle doğrulandı" olarak işaretlenir; ikisi aynı şey
 * değildir ve denetimde de öyle görünür.
 *
 * <b>Geciken dozda sebep sorulur</b> (sunucu da ister): "neden geç verildi"
 * sorusunun cevabı sonradan hatırlanmaz.
 *
 * <b>Atlanan doz silinmez, sebebiyle kapanır</b> — ve "hasta reddetti" ayrı bir
 * durumdur: hemşirenin atlamasıyla aynı şey değildir, hekime farklı bir şey
 * söyler.
 */

const ATLAMA_SEBEPLERI = [
  'Hasta reddetti',
  'Damar yolu yok',
  'NPO (ağızdan alamıyor)',
  'Hasta tetkikte / ameliyatta',
  'İlaç serviste yok',
  'Hekim durdurdu',
];

const GECIKME_SEBEPLERI = [
  'Damar yolu yenilendi',
  'Hasta tetkikteydi',
  'İlaç eczaneden geç geldi',
  'Yoğunluk',
];

export function DozUygulamaModali({ doz, order, hasta, acilisAtlaModu,
                                    onKapat, onTamam }: {
  doz: EmarDoz;
  order: EmarOrder;
  hasta: string;
  /** Doz kuyruğundaki "Atlandı" düğmesi pencereyi doğrudan atlama modunda açar. */
  acilisAtlaModu?: boolean;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [barkod, setBarkod] = useState('');
  const [bileklik, setBileklik] = useState('');
  const [miktar, setMiktar] = useState(order.doz != null ? String(order.doz) : '');
  const [gecikme, setGecikme] = useState('');
  const [atlama, setAtlama] = useState(ATLAMA_SEBEPLERI[0]);
  const [atlaModu, setAtlaModu] = useState(!!acilisAtlaModu);
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  // GECİKME EŞİĞİ 30 DAKİKA — yatış kartındaki açık iş sayacı ve gece işi de
  //   aynı eşiği kullanır. İki yerde iki eşik, iki farklı gerçek demek olurdu.
  const gecikti = Date.now() > new Date(doz.planlanan).getTime() + 30 * 60000;
  const barkodOkundu = barkod.trim().length > 0;
  const bileklikOkundu = bileklik.trim().length > 0;

  const uygula = async () => {
    setHata('');
    if (gecikti && !gecikme.trim()) { setHata('Gecikme sebebi yazılmalı.'); return }
    setKaydediyor(true);
    try {
      const y = await api.dozUygula(doz.id, {
        barkod: barkod.trim(),
        elleDogrulandi: !barkodOkundu || !bileklikOkundu,
        miktar: miktar.trim() ? Number(miktar.replace(',', '.')) : null,
        gecikmeNedeni: gecikme.trim(),
      });
      mesaj(y.elleDogrulandi
        ? 'Doz uygulandı — kayıt "elle doğrulandı" olarak işaretlendi.'
        : 'Doz uygulandı (barkodla doğrulandı).');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const atla = async () => {
    setHata('');
    if (!atlama.trim()) { setHata('Atlama sebebi yazılmalı.'); return }
    setKaydediyor(true);
    try {
      await api.dozAtla(doz.id, {
        atlamaNedeni: atlama.trim(),
        hastaReddetti: atlama === 'Hasta reddetti',
      });
      mesaj('Doz "atlandı" olarak kapandı — sebep kayda geçti.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik="💉 İlaç Uygulama"
           ustBilgi={`${order.ad} · ${tarihSaat(doz.planlanan)} dozu`}
           onKapat={onKapat}
           alt={
             <>
               {atlaModu ? (
                 <button className="d ret" disabled={kaydediyor}
                         onClick={() => void atla()}>⤫ Atlandı Olarak Kaydet</button>
               ) : (
                 <button className="d onay" disabled={kaydediyor}
                         onClick={() => void uygula()}>✔ Uygulandı</button>
               )}
               <button className="d" onClick={() => setAtlaModu(a => !a)}>
                 {atlaModu ? '← Uygulama' : '⤫ Atlandı (sebep gir)'}
               </button>
               <button className="d" onClick={onKapat}>✖ Vazgeç</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {gecikti && !atlaModu && (
        <div className="uyari-kutusu">
          <b>Bu doz gecikti.</b> Planlanan {tarihSaat(doz.planlanan)}. Gecikme sebebi
          uygulama kaydına yazılır — "neden geç verildi" sorusunun cevabı sonradan
          hatırlanmaz.
        </div>
      )}

      <div className="kagrup">
        <h6>Doz <span>beş doğru</span></h6>
        <div className="ic">
          <div className="sat"><span>Hasta</span><b>{hasta}</b></div>
          <div className="sat"><span>İlaç</span><b>{order.ad}</b></div>
          <div className="sat"><span>Doz / yol</span>
            <b>{order.doz ?? '—'} {order.birim} {order.yolAd && `· ${order.yolAd}`}</b></div>
          <div className="sat"><span>Planlanan</span><b>{tarihSaat(doz.planlanan)}</b></div>
        </div>
      </div>

      {!atlaModu && (
        <>
          <div className="alan-izgara">
            <label className="alan">
              <span className="etiket">Bileklik barkodu</span>
              <input value={bileklik} placeholder="Hasta bilekliğini okutun"
                     onChange={e => setBileklik(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">İlaç karekodu</span>
              <input value={barkod} placeholder="Kutu karekodunu okutun"
                     onChange={e => setBarkod(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Uygulanan miktar</span>
              <input value={miktar} onChange={e => setMiktar(e.target.value)} />
            </label>
            {gecikti && (
              <label className="alan">
                <span className="etiket zorunlu-isaret">Gecikme sebebi</span>
                <input list="gecikme-sebep" value={gecikme}
                       onChange={e => setGecikme(e.target.value)} />
                <datalist id="gecikme-sebep">
                  {GECIKME_SEBEPLERI.map(s => <option key={s} value={s} />)}
                </datalist>
              </label>
            )}
          </div>
          <div className="not">
            <b>Barkod okutulmadan da kaydedilir</b> (acil durum) ama kayıt
            <b> "elle doğrulandı"</b> işaretlenir: ikisini aynı göstermek, beş doğru
            kontrolünü kâğıt üstünde bırakmak olurdu.
            {(!barkodOkundu || !bileklikOkundu) && (
              <> Şu an <b>elle doğrulama</b> ile kaydedilecek.</>
            )}
          </div>
        </>
      )}

      {atlaModu && (
        <>
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket zorunlu-isaret">Atlama sebebi</span>
              <input list="atlama-sebep" value={atlama}
                     onChange={e => setAtlama(e.target.value)} />
              <datalist id="atlama-sebep">
                {ATLAMA_SEBEPLERI.map(s => <option key={s} value={s} />)}
              </datalist>
            </label>
          </div>
          <div className="not">
            <b>Atlanan doz silinmez</b>, sebebiyle kapanır: silinen satır "verilmedi mi,
            hiç planlanmadı mı" sorusunu cevapsız bırakır. <b>"Hasta reddetti"</b> ayrı
            bir durumdur — hemşirenin atlamasıyla aynı şey değildir.
          </div>
        </>
      )}
    </Modal>
  );
}
