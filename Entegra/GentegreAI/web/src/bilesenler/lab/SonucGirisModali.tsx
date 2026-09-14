import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { mesaj } from '../mesaj';
import { BAYRAK_OK, bayrakSinifi, referansMetni } from '../labKodlari';


/**
 * SONUÇ GİRİŞİ (433) - bir istemin BÜTÜN tetkikleri tek pencerede.
 *
 * Cihaz bağlı olmayan laboratuvarda (ya da cihazın okumadığı bir tetkikte)
 * sonuç elle girilir. Uç ve kural motoru zaten vardı (`POST /api/lab/sonuc`:
 * referans, bayrak, panik, delta); EKRANI yoktu - fonksiyon istemcide
 * duruyor ama hiçbir yerden çağrılmıyordu.
 *
 * <b>Satır satır değil, TEK PENCEREDE.</b> Hemogram 23, tam idrar 21
 * parametre üretiyor; her değer için ayrı pencere açmak teknisyeni 23 kez
 * tıklatırdı. Değerler girilir, "Kaydet" hepsini sırayla yazar.
 *
 * <b>Kural motoru SUNUCUDA.</b> Ekran bayrak/panik hesaplamaz - yazdıktan
 * sonra sunucunun döndürdüğünü gösterir. İki yerde hesaplamak, referans
 * aralığı yaşa/cinsiyete göre değiştiği için sessizce ayrışırdı.
 *
 * <b>Boş bırakılan satır YAZILMAZ.</b> "Henüz çalışılmadı" ile "sonuç boş"
 * ayrı şeyler; boş değer göndermek tetkiki sonuçlanmış gösterirdi.
 */
interface Satir {
  satirId: number;
  sonucId: number | null;
  sonucDurum: number;
  kod: string;
  ad: string;
  birim: string;
  referansAlt: unknown;
  referansUst: unknown;
  referansMetin: string;
  deger: string;
  bayrak: string;
  panik: boolean;
  panelAd: string;
  girisTuru: string;
  giren: string;
  olcumZamani: string;
  tekrarNo: number;
  duzeltmeNeden: string;
}

/** "13.09.2026 18:04" - saniye yok, ekranda gurultu yapiyor. */
const anMetni = (ham: string): string => {
  const d = new Date(ham);
  return Number.isNaN(d.getTime()) ? ham
    : d.toLocaleString('tr-TR', { day: '2-digit', month: '2-digit',
                                  year: 'numeric', hour: '2-digit',
                                  minute: '2-digit' });
};

export function SonucGirisModali({ istemId, onKapat, onKaydedildi }: {
  istemId: number;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const [istemNo, setIstemNo] = useState('');
  const [hasta, setHasta] = useState('');
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [girilen, setGirilen] = useState<Record<number, string>>({});
  // DÜZELTME: sonucu olan satır kilitlidir; açmak ayrı bir karardır ve
  //   nedeni zorunludur (sunucu da zorunlu tutuyor).
  const [duzeltilen, setDuzeltilen] = useState<Record<number, string>>({});
  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');
  // HIZLI GIRIS: teknisyen cihaz cikti kagidindan yukaridan asagi okur.
  //   Enter/ok tusu bir alt tetkige gecer - 23 parametre icin fareye
  //   uzanmak ya da Tab'in duzeltme kutusuna dusmesi akisi kirardi.
  const kutular = useRef<(HTMLInputElement | null)[]>([]);

  const odakla = (i: number) => {
    const k = kutular.current[i];
    if (!k) return;
    k.focus();
    k.select();
    // EKRAN SATIRA KAYAR (kullanici: "asagi dogru girerken ekran otomatik
    //   scroll olsun, yoksa alt taraf gorunmuyor"). 23 parametrelik
    //   hemogramda odak goruntu alaninin altina cikiyordu: kullanici
    //   yazdigini gormeden yaziyordu. `nearest` yalnizca gerektiginde
    //   kaydirir - her Enter'da tabloyu ziplatmaz.
    k.scrollIntoView({ block: 'nearest' });
  };

  const tus = (e: React.KeyboardEvent<HTMLInputElement>, i: number) => {
    if (e.key === 'Enter' && (e.ctrlKey || e.metaKey)) { e.preventDefault(); void kaydet(); return }
    if (e.key === 'Enter' || e.key === 'ArrowDown') {
      e.preventDefault();
      // Son satirda Enter basa DONMEZ: girisin bittigini gormek,
      //   sessizce ilk satiri ezmekten iyidir.
      odakla(Math.min(i + 1, kutular.current.length - 1));
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      odakla(Math.max(i - 1, 0));
    }
  };

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const y = await api.labIstemOku(istemId);
      setIstemNo(String(y.istemNo ?? ''));
      setHasta(String(y.hasta ?? ''));
      setSatirlar(((y.satirlar ?? []) as Record<string, unknown>[]).map(r => ({
        satirId: Number(r.satirId),
        sonucId: r.sonucId == null ? null : Number(r.sonucId),
        sonucDurum: Number(r.sonucDurum ?? 0),
        kod: String(r.kod ?? ''), ad: String(r.ad ?? ''),
        birim: String(r.birim ?? ''),
        referansAlt: r.referansAlt, referansUst: r.referansUst,
        referansMetin: String(r.referansMetin ?? ''),
        deger: String(r.deger ?? ''), bayrak: String(r.bayrak ?? ''),
        panik: Boolean(r.panik), panelAd: String(r.panelAd ?? ''),
        girisTuru: String(r.girisTuru ?? ''), giren: String(r.giren ?? ''),
        olcumZamani: String(r.olcumZamani ?? ''),
        tekrarNo: Number(r.tekrarNo ?? 0),
        duzeltmeNeden: String(r.duzeltmeNeden ?? ''),
      })));
      setGirilen({}); setDuzeltilen({});
      setHata('');
    } catch (h) { setHata(hataMetni(h)) }
    setYukleniyor(false);
  }, [istemId]);

  useEffect(() => { void yukle() }, [yukle]);

  // Pencere acilir acilmaz ilk SONUCSUZ satirda bekler: zaten sonuclanmis
  //   tetkiklerin uzerinden gecmek gereksiz.
  useEffect(() => {
    if (yukleniyor || satirlar.length === 0) return;
    const i = satirlar.findIndex(s => s.sonucId === null);
    odakla(i < 0 ? 0 : i);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [yukleniyor, satirlar.length]);

  const kaydet = async () => {
    const yazilacak = satirlar.filter(s => (girilen[s.satirId] ?? '').trim() !== '');
    if (yazilacak.length === 0) { setHata('Değer girilmedi.'); return }
    // NEDENSİZ DÜZELTME YOK: değiştirilen satır eski sonucu iptal edip
    //   yenisini açacak; niçin değiştiği raporda kalmalı.
    const nedensiz = yazilacak.find(
      s => s.sonucId !== null && (duzeltilen[s.satirId] ?? '').trim() === '');
    if (nedensiz) {
      setHata(`${nedensiz.kod}: düzeltme nedeni zorunlu.`);
      return;
    }
    setKaydediyor(true);
    // SIRAYLA yazılır, topluca değil: her sonuç kendi kuralından geçiyor
    //   (delta önceki sonuca bakar) ve biri düşerse ötekiler yazılmış kalmalı -
    //   teknisyen baştan girmesin.
    let yazan = 0;
    const panikler: string[] = [];
    for (const s of yazilacak) {
      const deger = (girilen[s.satirId] ?? '').trim();
      try {
        // Sonucu OLAN satır düzeltme ucundan geçer: eski satır iptal
        //   edilir, yenisi oto-onaya girmez. Aynı satıra ikinci kez
        //   labSonucYaz çağırmak iki canlı sonuç bırakırdı.
        const y = s.sonucId !== null
          ? await api.labSonucDuzelt(s.sonucId, deger,
                                     (duzeltilen[s.satirId] ?? '').trim())
          : await api.labSonucYaz({
              istemSatirId: s.satirId, deger, birim: s.birim || undefined });
        yazan += 1;
        if ('panik' in y && y.panik) panikler.push(`${s.kod} ${s.ad}`);
      } catch (h) {
        setHata(`${s.kod}: ${hataMetni(h)}`);
        break;
      }
    }
    setKaydediyor(false);
    if (yazan > 0) {
      // PANİK SONUÇ AYRICA SÖYLENİR: listede rozet var ama pencere kapanırken
      //   teknisyen onu görmeyebilir - panik değer hekime bildirilmek zorunda.
      mesaj(`${yazan} sonuç kaydedildi.`
            + (panikler.length ? `\n\nPANİK DEĞER: ${panikler.join(', ')}` : ''));
      await yukle();
      onKaydedildi?.();
    }
  };

  return (
    <Modal
      baslik={`Sonuç Girişi — ${istemNo}${hasta ? ` · ${hasta}` : ''}`}
      onKapat={onKapat}
      alt={
        <>
          {hata && <span className="alan-hata">{hata}</span>}
          <button className="d" onClick={onKapat}>Kapat</button>
          <button className="d bir" disabled={kaydediyor || yukleniyor}
                  onClick={() => void kaydet()}>
            {kaydediyor ? 'Kaydediliyor…' : '💾 Kaydet'}
          </button>
        </>
      }
    >
      <div className="kagrup">
        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <div className="detay-kaydir">
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Kod</th><th>Tetkik</th>
                  <th className="sag">Değer</th><th>Birim</th><th>Referans</th>
                  <th className="orta">Bayrak</th>
                  <th>Giriş</th>
                  <th>Düzeltme nedeni</th>
                </tr>
              </thead>
              <tbody>
                {satirlar.map((s, i) => (
                  <tr key={s.satirId} className={s.panik ? 'panik' : undefined}>
                    <td>{s.kod}</td>
                    <td>
                      <b>{s.ad}</b>
                      {s.panelAd && <span className="not"> · {s.panelAd}</span>}
                    </td>
                    <td className={`hiza-sag hucre-ekli-td${s.panik ? ' hucre-panik' : ''}`}>
                      {/* KAYITLI DEĞER YER TUTUCUDA: üzerine yazmak DÜZELTMEDİR
                          ve ayrı bir işlemdir (eski satır iptal edilip yenisi
                          açılır). Kutuyu kayıtlı değerle doldurmak,
                          dokunulmayan satırı yeniden yazdırırdı. */}
                      <input className="hiza-sag"
                             ref={el => { kutular.current[i] = el }}
                             onKeyDown={e => tus(e, i)}
                             value={girilen[s.satirId] ?? ''}
                             placeholder={s.deger || '—'}
                             title={s.sonucId !== null
                                    ? 'Kayıtlı sonuç - yazarsanız düzeltme olur'
                                    : undefined}
                             onChange={e => setGirilen(o =>
                               ({ ...o, [s.satirId]: e.target.value }))} />
                      {/* YON OKU DEGERIN YANINDA (kullanici): bayrak
                          kolonuna bakmadan, sayiyi okurken yon gorunsun. */}
                      {s.bayrak && s.bayrak !== 'N' && (
                        <span className={`rozet ${bayrakSinifi(s.bayrak).replace('rozet ', '')}`
                                         + ' hucre-ok'}
                              title={s.panik ? 'Panik değer' : s.bayrak}>
                          {s.panik ? '⚠' : BAYRAK_OK[s.bayrak] ?? ''}
                        </span>
                      )}
                    </td>
                    <td>{s.birim}</td>
                    <td>
                      {referansMetni(s.referansAlt, s.referansUst, s.referansMetin) || '—'}
                    </td>
                    <td className="orta">
                      {s.bayrak && s.bayrak !== 'N'
                        ? <span className={bayrakSinifi(s.bayrak)}>
                            {s.bayrak} {BAYRAK_OK[s.bayrak] ?? ''}
                          </span>
                        : '—'}
                    </td>
                    {/* GİRİŞİN KAYNAĞI (kullanıcı: "sonucu elle değiştirdiğim /
                        girdiğim bilgisi nerede"): elle mi cihazdan mı, kim ve
                        ne zaman. Düzeltmede kaçıncı tekrar olduğu da yazar. */}
                    <td className="not">
                      {s.girisTuru === '' ? '—' : (
                        <>
                          <span title={s.girisTuru === 'Elle' ? 'Elle girildi'
                                                                 : 'Cihazdan geldi'}>
                            {s.girisTuru === 'Elle' ? '✍' : '🖧'}
                          </span>
                          {s.giren && ` ${s.giren}`}
                          {s.olcumZamani && ` · ${anMetni(s.olcumZamani)}`}
                          {s.tekrarNo > 0 && ` · ${s.tekrarNo}. düzeltme`}
                          {s.duzeltmeNeden && ` · ${s.duzeltmeNeden}`}
                        </>
                      )}
                    </td>
                    <td>
                      {s.sonucId !== null ? (
                        <input tabIndex={-1}
                               value={duzeltilen[s.satirId] ?? ''}
                               placeholder={(girilen[s.satirId] ?? '').trim()
                                            ? 'Neden? (zorunlu)' : '—'}
                               onChange={e => setDuzeltilen(o =>
                                 ({ ...o, [s.satirId]: e.target.value }))} />
                      ) : <span className="not">—</span>}
                    </td>
                  </tr>
                ))}
                {satirlar.length === 0 && (
                  <tr><td colSpan={8} className="not">Bu istemde tetkik yok.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}
        <div className="not">
          Değer girilen satırlar kaydedilir; boş bırakılan tetkik “çalışılmadı”
          sayılır. Bayrak, panik ve delta uyarısı <b>sunucuda</b> hesaplanır -
          kaydettikten sonra bu tabloda görünür. Temiz sonuç oto-onaya gider,
          bayraklı sonuç onay kuyruğunda bekler. Zaten sonucu olan satıra
          değer yazmak <b>düzeltmedir</b>: nedeni zorunludur, eski sonuç
          iptal edilir ve yenisi otomatik onaylanmaz.
          <br />
          <b>Enter</b> / <b>↓</b> bir alt tetkiğe geçer, <b>↑</b> bir üste,
          <b>Ctrl+Enter</b> hepsini kaydeder.
        </div>
      </div>
    </Modal>
  );
}
