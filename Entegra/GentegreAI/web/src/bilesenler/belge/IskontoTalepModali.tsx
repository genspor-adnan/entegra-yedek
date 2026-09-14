import { useState } from 'react';
import { Modal } from '../Modal';
import { para, hamSayi, paraYaz } from '../bicim';
import { ISKONTO_GEREKCELERI } from '../../sayfalar/belgeSabitleri';
import { satirTutari, type SatirDurumu } from '../../sayfalar/belgeSatir';
import { bruta } from '../../sayfalar/belgeKarti/kdvModu';

/** Pencerenin kalem satiri - ekranda gosterilen ve hesaplanan her sey. */
export interface IskontoKalemSatiri {
  anahtar: number;
  satirId: number;
  ad: string;
  /** Satirin KDV dahil tutari - ekranda konusulan rakam. */
  tutar: number;
  /** Indirilebilir mi; degilse sebebi rozette yazar. */
  kilit?: string;
  /** Kaleme ozel oran (%) - bos ise toplu oran gecerli. */
  oran: string;
}

export interface IskontoTalepSonucu {
  /** EN YUKSEK kalem orani - yetki tavani bununla olculur. */
  oran: number;
  gerekce: string;
  /** Onaya gonderilsin mi; false ise dogrudan uygulanir (limit ici). */
  onaya: boolean;
  /** Kalem bazli oranlar (673): her satirin kendi yuzdesi. */
  kalemler: { anahtar: number; satirId: number; oran: number }[];
}

/**
 * İSKONTO TALEP PENCERESİ
 * (mockup: Ekranlar/Kayıt Kabul/iskonto_talep_penceresi.html).
 *
 * Eskiden iki ardışık kutu soruluyordu (oran, sonra gerekçe) ve görevli neye
 * ne kadar indirim yaptığını göremiyordu. Karar burada verilir: hangi kalem,
 * ne kadar, kalan ne, limit yetiyor mu.
 *
 * İKİ ÇIKIŞ, AYNI ANDA ETKİN DEĞİL: limit içindeyse "Uygula" (onaya düşmez),
 * aşıyorsa "Onaya Gönder". Görevli hangi yolda olduğunu tahmin etmez - sonuç
 * satırı söyler.
 */
export function IskontoTalepModali({ satirlar, tavan, hasta, onKapat, onSonuc }: {
  satirlar: SatirDurumu[];
  /** Rolün iskonto tavanı (%) - `basvuru.iskonto` yetkisinin Sınır değeri. */
  tavan: number;
  hasta?: string;
  onKapat(): void;
  onSonuc(s: IskontoTalepSonucu): void | Promise<void>;
}) {
  /** Kalemler: kaydedilmemiş satır talebe giremez (kimliği yok). */
  const kalemler: IskontoKalemSatiri[] = satirlar.map(s => ({
    anahtar: s.anahtar,
    satirId: s.satirId ?? 0,
    ad: s.stokAdi || '(kalem)',
    // EKRANDA KONUSULAN TUTAR: adet x birim fiyat, KDV dahil - iskonto satiri
    //   zaten brut uzerinden konusuluyor (basvuruda fiyat hep KDV dahil).
    tutar: bruta(satirTutari(hamSayi(s.adet), hamSayi(s.birimFiyat),
                             s.iskonto, s.iskonto2), s.kdv),
    kilit: (s.satirId ?? 0) > 0 ? undefined : 'kaydedilmemiş satır',
    oran: '',
  }));

  const [secili, setSecili] = useState<Set<number>>(
    new Set(kalemler.filter(k => !k.kilit).map(k => k.anahtar)));
  const [topluOran, setTopluOran] = useState('');
  /**
   * KALEM BAZLI ORAN (673): anahtar -> yuzde metni. Toplu oran kutusu bunlari
   * TOPLUCA doldurur, sonra tek tek degistirilebilir - muayeneye %20, tetkike
   * %5 vermek gercek bir istek. Bos ise toplu oran gecerli.
   */
  const [oranlar, setOranlar] = useState<Record<number, string>>({});
  const [gerekce, setGerekce] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);

  const topluSayi = Math.max(0, hamSayi(topluOran));
  /** Kalemin gecerli orani: kendi degeri varsa o, yoksa toplu oran. */
  const kalemOrani = (a: number) => {
    const kendi = oranlar[a];
    return Math.min(100, Math.max(0,
      kendi !== undefined && kendi !== '' ? hamSayi(kendi) : topluSayi));
  };

  const secilenler = kalemler.filter(k => !k.kilit && secili.has(k.anahtar));
  /** İNDİRİLEBİLİR taban: yalnız seçili ve kilitsiz kalemler. */
  const indirilebilir = secilenler.reduce((t, k) => t + k.tutar, 0);
  const kilitli = kalemler.filter(k => k.kilit).reduce((t, k) => t + k.tutar, 0);
  const toplam = kalemler.reduce((t, k) => t + k.tutar, 0);
  const indirim = secilenler.reduce(
    (t, k) => t + k.tutar * kalemOrani(k.anahtar) / 100, 0);
  /** Toplam üzerinden efektif oran - "%20 yazdım neden %10,5" sorusu. */
  const efektif = toplam > 0 ? indirim / toplam * 100 : 0;
  /** TAVAN, EN YUKSEK kalem oranıyla ölçülür - sınırı zorlayan kalem odur. */
  const oranSayi = secilenler.reduce((m, k) => Math.max(m, kalemOrani(k.anahtar)), 0);

  const limitIci = oranSayi > 0 && oranSayi <= tavan;
  const onayGerek = oranSayi > tavan;

  const cevir = (a: number) => setSecili(s => {
    const y = new Set(s);
    if (y.has(a)) y.delete(a); else y.add(a);
    return y;
  });

  const gonder = async (onaya: boolean) => {
    setHata(null);
    if (!(oranSayi > 0)) { setHata('İskonto oranı sıfırdan büyük olmalı.'); return }
    if (secilenler.length === 0) { setHata('En az bir kalem seçin.'); return }
    // GEREKÇE ONAYA GİDECEKSE ZORUNLU, limit içi indirimde değil: gereksiz
    //   zorunlu alan görevliye rastgele kategori seçtirir, veri çöpe döner.
    if (onaya && !gerekce) { setHata('Onaya gönderirken gerekçe zorunlu.'); return }
    setCalisiyor(true);
    try {
      await onSonuc({
        oran: oranSayi,
        gerekce: [gerekce && ISKONTO_GEREKCELERI.find(x => x.kod === gerekce)?.ad,
                  aciklama.trim()].filter(Boolean).join(' — '),
        onaya,
        kalemler: secilenler
          .map(k => ({ anahtar: k.anahtar, satirId: k.satirId,
                       oran: kalemOrani(k.anahtar) }))
          .filter(k => k.oran > 0),
      });
      onKapat();
    } catch (h) { setHata(String(h)) }
    finally { setCalisiyor(false) }
  };

  return (
    <Modal baslik="İskonto Uygula" buyutmeYok enUst onKapat={onKapat}
           alt={
             <>
               {/* IKISI AYNI ANDA ETKIN DEGIL - limit durumu belirler. */}
               <button type="button" className="d ok" disabled={calisiyor || !limitIci}
                       title={limitIci ? 'Limit içinde - doğrudan uygulanır'
                                       : `Limitiniz %${tavan} - onaya gönderin`}
                       onClick={() => void gonder(false)}>✔ Uygula</button>
               <button type="button" className="d bir" disabled={calisiyor || !onayGerek}
                       title={onayGerek ? 'Yetkilinin onayına gönderir'
                                        : 'Limit içinde - onaya gerek yok'}
                       onClick={() => void gonder(true)}>⬆ Onaya Gönder</button>
               {/* KAPAT SAGA YANASIK: eylem dugmeleriyle arasi acilir ki
                   yanlislikla tiklanmasin. */}
               <button type="button" className="d" style={{ marginLeft: 'auto' }}
                       disabled={calisiyor} onClick={onKapat}>Kapat</button>
             </>
           }>
      <div className="isk-talep">
        {hasta && (
          <div className="kalem-serit">
            <span>👤 <b>{hasta}</b></span>
            <span>💰 Tahsil edilecek: <b>{paraYaz(toplam)}</b></span>
          </div>
        )}

        <div className="kagrup">
          <h6>
            İskonto Uygula
            <span className="sonuk" style={{ marginLeft: 'auto', fontWeight: 400 }}>
              tümüne oran{' '}
              <input className="hiza-sag" style={{ width: 56 }} value={topluOran}
                     onChange={e => {
                       // TOPLU ORAN kalem oranlarini SIFIRLAR: kutuya yazilan
                       //   sayi "hepsi bu olsun" demektir; eski tek tek
                       //   degerler kalsaydi yazdigi oran islemiyor gorunurdu.
                       setTopluOran(e.target.value); setOranlar({}); setHata(null);
                     }} />
              {' '}%
            </span>
          </h6>
          <table className="detay-tablo">
            <thead>
              <tr>
                <th className="check"></th>
                <th>Hizmet</th>
                <th className="hiza-sag" style={{ width: 110 }}>Tutar</th>
                <th className="hiza-sag" style={{ width: 70 }}>Oran %</th>
                <th className="hiza-sag" style={{ width: 90 }}>İskonto</th>
                <th className="hiza-sag" style={{ width: 110 }}>Net</th>
                <th style={{ width: 170 }}>Not</th>
              </tr>
            </thead>
            <tbody>
              {kalemler.map(k => {
                const acik = !k.kilit && secili.has(k.anahtar);
                const o = acik ? kalemOrani(k.anahtar) : 0;
                const ind = k.tutar * o / 100;
                return (
                  <tr key={k.anahtar} className={k.kilit ? 'pasif' : acik ? 'secili' : ''}>
                    <td className="check">
                      <input type="checkbox" checked={acik} disabled={!!k.kilit}
                             onChange={() => cevir(k.anahtar)} />
                    </td>
                    <td>{k.ad}</td>
                    <td className="hiza-sag">{para.format(k.tutar)}</td>
                    <td className="hiza-sag">
                      {/* KALEM BAZLI ORAN: bos birakilirsa toplu oran gecerli. */}
                      <input className="hiza-sag" style={{ width: 56 }}
                             disabled={!acik}
                             value={oranlar[k.anahtar] ?? (acik && topluSayi > 0
                               ? String(topluSayi) : '')}
                             onChange={e => {
                               setOranlar(x => ({ ...x, [k.anahtar]: e.target.value }));
                               setHata(null);
                             }} />
                    </td>
                    <td className="hiza-sag">{ind > 0 ? para.format(ind) : '—'}</td>
                    <td className="hiza-sag">{para.format(k.tutar - ind)}</td>
                    <td>
                      {/* KILITLI KALEM SATIRDA KALIR: "%20 yazdim neden %10,5
                          cikti" sorusu pencerede cevaplanmali. */}
                      {k.kilit
                        ? <span className="rozet gri">🔒 {k.kilit}</span>
                        : <span className="sonuk">—</span>}
                    </td>
                  </tr>
                );
              })}
              <tr className="genel">
                <td></td><td>TOPLAM</td>
                <td className="hiza-sag">{para.format(toplam)}</td>
                <td className="hiza-sag">—</td>
                <td className="hiza-sag">{para.format(indirim)}</td>
                <td className="hiza-sag">{para.format(toplam - indirim)}</td>
                <td></td>
              </tr>
            </tbody>
          </table>
          <div className="isk-ozet">
            <span className="sonuk">
              İndirilebilir <b>{paraYaz(indirilebilir)}</b>
              {kilitli > 0 && <> · kilitli <b>{paraYaz(kilitli)}</b></>}
            </span>
            <span>
              İndirim <b>{paraYaz(indirim)}</b>{' '}
              <span className="sonuk">
                · en yüksek %{oranSayi || 0} · toplamın
                %{(Math.round(efektif * 10) / 10)}'i
              </span>
            </span>
          </div>
        </div>

        <div className="kagrup">
          <h6>Gerekçe <span className="sonuk" style={{ fontWeight: 400 }}>
            — onaya gidecekse zorunlu</span></h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            <label className="alan">
              <span className={`etiket${onayGerek ? ' zorunlu-isaret' : ''}`}>Kategori</span>
              <select value={gerekce}
                      onChange={e => { setGerekce(e.target.value); setHata(null) }}>
                <option value="">— seçiniz —</option>
                {ISKONTO_GEREKCELERI.map(x =>
                  <option key={x.kod} value={x.kod}>{x.ad}</option>)}
              </select>
            </label>
            <label className="alan">
              <span className="etiket">Açıklama</span>
              <input value={aciklama} placeholder="Yetkili bunu okuyacak"
                     onChange={e => setAciklama(e.target.value)} />
            </label>
          </div>
        </div>

        {/* YETKI: hem oran hem sonuc gorunur - gorevli hangi dugmenin
            calisacagini tahmin etmesin. */}
        <div className="kagrup">
          <h6>Yetkiniz</h6>
          <div className="isk-sat"><span>Oran limitiniz</span><b>%{tavan}</b></div>
          <div className="isk-sat"><span>İstenen oran</span><b>%{oranSayi || 0}</b></div>
          <div className={`isk-sat ${onayGerek ? 'teh' : 'ok'}`}>
            <span>Sonuç</span>
            <b>{!(oranSayi > 0) ? 'Oran girin'
                : onayGerek ? '⚠ Onay gerekir' : '✔ Limit içinde — doğrudan uygulanır'}</b>
          </div>
        </div>

        {!!hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}
