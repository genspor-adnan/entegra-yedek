import { useEffect, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { ApiHatasi, hataMetni } from '../../api/sozlesme';
import {
  type IzlemSatiri, bosIzlem, izlemKurali, seriSutunuVar, tarihSutunuVar, tariheEkle, RAF_BIRIM,
} from '../../sayfalar/belgeSatir';
import { bugunIso, hamSayi as sayi } from '../bicim';
import { c } from '../../dil/ceviri';

/**
 * IZLEM (LOT / SERI) PENCERESI — giris belgelerinde izlemli stok icin.
 *
 * Kalem penceresinde miktar ve fiyat girildikten SONRA acilir: girilen miktar
 * lotlara dagitilir. Bir kalem 1:n lot tasiyabilir (ayni urunden iki farkli
 * partiden mal gelmesi normaldir).
 *
 * TOPLAM KILIDI: lot miktarlarinin toplami kalem miktarina esit olmadan
 * kapanmaz. Esit degilse depodaki miktarla lotlarin toplami ayrisir ve maldan
 * cikis yapilirken lot bulunamaz - geri izlenebilirlik orada kirilir.
 *
 * Durum GIRISTE 0 ("Girişte"); karantina/bloke gibi durumlar kod listesi
 * tanimlandiginda burada secilebilir olacak (db/114).
 */
export function IzlemPenceresi({ stokAdi, stokId, depoId, izleme, miktar, satirlar, cikis, kayitli,
                         onKapat, onKaydet }: {
  stokAdi: string;
  stokId: number | null;
  /** CIKISTA lotlar BU DEPODAN listelenir (115) - baska deponun lotu satilamaz. */
  depoId: number | null;
  izleme: number;
  /** Kalemde girilen toplam miktar - lotlarin toplami buna esit olmali. */
  miktar: number;
  satirlar: IzlemSatiri[];
  /** CIKIS belgesi: lot GIRILMEZ, stoktakilerden secilir. */
  cikis: boolean;
  /** Satirin SUNUCUDAKI (kayitli) lotlari - cikista secilebilir kalan bunlarla geri eklenir. */
  kayitli?: IzlemSatiri[];
  onKapat(): void;
  onKaydet(satirlar: IzlemSatiri[]): void;
}) {
  // Ilk acilista tek satir ve miktarin TAMAMI onda: tek lottan gelen mal en sik
  //   durum, kullanici yalniz lot numarasini yazip gecer.
  const [liste, setListe] = useState<IzlemSatiri[]>(
    satirlar.length > 0 ? satirlar : cikis ? [] : [bosIzlem(String(miktar))]);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(cikis);
  const kural = izlemKurali(izleme);
  const seriVar = seriSutunuVar(izleme, satirlar);
  const tarihVar = tarihSutunuVar(izleme, satirlar);

  // RAF OMRU (stok karti): ÜRT <-> SKT donusumu bununla yapilir. Kartta yoksa
  //   kullanicidan BURADA sorulur ve karta yazilir - lot girisini yarida kesip
  //   stok kartina gitmek zorunda kalmasin.
  const [rafSure, setRafSure] = useState(0);
  const [rafBirim, setRafBirim] = useState(0);
  const [rafSurum, setRafSurum] = useState<string | undefined>();
  const [rafTaslak, setRafTaslak] = useState({ sure: '', birim: '2' });
  const [rafDuzenle, setRafDuzenle] = useState(false);
  const [rafNot, setRafNot] = useState<string | null>(null);

  useEffect(() => {
    if (cikis || !stokId) return;
    let iptal = false;
    void api.kartOku('stok', stokId)
      .then(k => {
        if (iptal) return;
        const sure = Number(k.kart.rafOmruSure ?? 0) || 0;
        const birim = Number(k.kart.rafOmruBirim ?? 0) || 0;
        setRafSure(sure); setRafBirim(birim);
        setRafSurum(k.kart.surum as string | undefined);
        // Ust bantta duzenlenir (kullanici 24.10.2026 "başlığa yine raf ömrü gelsin").
        setRafTaslak({ sure: sure > 0 ? String(sure) : '', birim: birim > 0 ? String(birim) : '2' });
      })
      .catch(() => { /* kart okunamazsa raf omru sorulmaz, elle girilir */ });
    return () => { iptal = true };
  }, [cikis, stokId]);

  /**
   * Bantta raf omru degisti (kutudan cikinca / birim secilince): hesaplama HEMEN yeni sureyle calisir ve
   * STOK KARTINA yazilir - lot girisini yarida kesip stok kartina gitmek gerekmesin. Bos = hesap yok.
   */
  async function rafKaydet(t = rafTaslak) {
    const sure = sayi(t.sure);
    const birim = Number(t.birim) || 0;
    if (sure === rafSure && birim === rafBirim) return;
    if (sure <= 0 || birim <= 0) { setRafSure(0); return }
    setRafSure(sure); setRafBirim(birim); setHata(null);
    if (!stokId) return;
    try {
      const y = await api.kartGuncelle('stok', stokId,
        { surum: rafSurum, kart: { rafOmruSure: sure, rafOmruBirim: String(birim) } });
      setRafSurum(y.kart.surum as string | undefined);
      setRafNot(`Raf ömrü stok kartına yazıldı: ${sure} ${RAF_BIRIM[birim as 1 | 2 | 3]}.`);
    } catch (h) {
      // Yetkisi yoksa kart guncellenmez ama hesaplama yine calisir.
      setRafNot(h instanceof ApiHatasi
        ? `Raf ömrü bu girişte kullanılacak; stok kartına yazılamadı (${h.message}).`
        : 'Raf ömrü bu girişte kullanılacak; stok kartına yazılamadı.');
    }
  }

  // CIKISTA stoktaki lotlar getirilir: kullanici lot YAZMAZ, listeden secer.
  //   Sira SKT'ye gore (once tukenecek olan basta) - sunucu boyle veriyor.
  useEffect(() => {
    if (!cikis || !stokId) return;
    let iptal = false;
    void api.stokLotlari(stokId, depoId)
      .then(lotlar => {
        if (iptal) return;
        setListe(eski => {
          // DEPO LOTLARI + BU SATIRIN KAYITLI DUSUMU + GUNCEL SECIM (kullanici 24.10.2026: "satış irs de lotno
          //   değiştiremedim" + "adeti 20'den 18'e düşürüp sonra 20'ye çıkardım, boştaki lotlar gelmedi").
          //   Sunucunun stok kalani KAYITLI belgenin dusumunu icerir; duzenlemede sunucu once o dusumu geri
          //   alir. Bu yuzden her lotun secilebilir kalani = depodaki kalan + bu satirin KAYITLI miktari.
          //   Kayitli liste ayri tutulur (`kayitli`) - guncel secimden turetilirse oturumda birakilan lotlar
          //   (20 -> 18'de dusenler) depoda da secimde de olmadigi icin listeden kayboluyordu.
          const kimlik = (z: { seriLotId?: number; lotNo: string; seriNo: string }) =>
            z.seriLotId ? `#${z.seriLotId}` : `${z.lotNo}|${z.seriNo}`;
          const ikiAnahtar = (z: { seriLotId?: number; lotNo: string; seriNo: string }) =>
            [kimlik(z), `${z.lotNo}|${z.seriNo}`];
          const kayitliListe = kayitli ?? eski.filter(z => z.kalan === undefined);
          const geriGelen = new Map<string, { z: IzlemSatiri; m: number }>();
          for (const k of kayitliListe) {
            const var_ = geriGelen.get(kimlik(k));
            const kayit = var_ ?? { z: k, m: 0 };
            kayit.m += sayi(k.miktar);
            ikiAnahtar(k).forEach(a => geriGelen.set(a, kayit));
          }
          const secim = new Map<string, string>();
          eski.forEach(z => ikiAnahtar(z).forEach(a => secim.set(a, z.miktar)));
          const kullanilan = new Set<{ z: IzlemSatiri; m: number }>();
          const bul = <T,>(m: Map<string, T>, z: { seriLotId?: number; lotNo: string; seriNo: string }) =>
            ikiAnahtar(z).map(a => m.get(a)).find(x => x !== undefined);
          const birlesik: IzlemSatiri[] = lotlar.map(l => {
            const g = bul(geriGelen, l);
            if (g) kullanilan.add(g);
            return {
              seriLotId: l.seriLotId,
              kalan: l.kalan + (g?.m ?? 0),
              lotNo: l.lotNo,
              seriNo: l.seriNo,
              uretimTarihi: (l.uretimTarihi ?? '').slice(0, 10),
              sonKullanmaTarihi: (l.sonKullanmaTarihi ?? '').slice(0, 10),
              durum: 0,
              miktar: bul(secim, l) ?? '',
            };
          });
          // Depoda kalani SIFIR olan kayitli lotlar (tamami bu belgeyle cikmis) depo listesinde yok - basa eklenir.
          const tukenmis = [...new Set(geriGelen.values())].filter(g => !kullanilan.has(g))
            .map(g => ({ ...g.z, kalan: g.m, miktar: bul(secim, g.z) ?? '' }));
          const bilinen = new Set([...tukenmis, ...birlesik].flatMap(ikiAnahtar));
          // Bu oturumda secilmis ama ne depoda ne kayitta olan (olmamali) - secim kaybolmasin.
          const yetim = eski.filter(z => sayi(z.miktar) > 0 && !ikiAnahtar(z).some(a => bilinen.has(a)));
          return [...tukenmis, ...yetim, ...birlesik];
        });
      })
      .catch(h => setHata(hataMetni(h)))
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [cikis, stokId, depoId]);

  const toplam = liste.reduce((t, z) => t + sayi(z.miktar), 0);
  const fark = Math.round((miktar - toplam) * 10000) / 10000;
  /** SKT'si gecmis lot sayisi - girisi ENGELLEMEZ, uyarir. */
  const gecmisSkt = liste.filter(z => sayi(z.miktar) > 0
                                   && z.sonKullanmaTarihi
                                   && z.sonKullanmaTarihi < bugunIso()).length;

  const degis = (i: number, alan: keyof IzlemSatiri, deger: string | number) =>
    setListe(l => l.map((z, x) => {
      if (x !== i) return z;
      const yeni = { ...z, [alan]: deger } as IzlemSatiri;
      // ÜRT <-> SKT: hangisi girildiyse DIGERI raf omrunden hesaplanir.
      //   Kullanici sonra elle degistirebilir - hesap yalniz yazilan alanin
      //   karsisini doldurur, yazdigi alana dokunmaz.
      if (!cikis && rafSure > 0 && rafBirim > 0) {
        if (alan === 'uretimTarihi' && deger)
          yeni.sonKullanmaTarihi = tariheEkle(String(deger), rafSure, rafBirim, 1);
        else if (alan === 'sonKullanmaTarihi' && deger)
          yeni.uretimTarihi = tariheEkle(String(deger), rafSure, rafBirim, -1);
      }
      return yeni;
    }));

  /** Lot Ekle'den sonra imlec yeni satirin Lot No kutusuna (kullanici 24.10.2026). */
  const [odakSatir, setOdakSatir] = useState<number | null>(null);
  const satirEkle = () => {
    // Yeni satir KALAN miktarla acilir - kullanici hesap yapmasin.
    setOdakSatir(liste.length);
    setListe(l => [...l, bosIzlem(fark > 0 ? String(fark) : '')]);
  };

  const satirSil = (i: number) =>
    setListe(l => (l.length === 1 ? [bosIzlem(String(miktar))] : l.filter((_, x) => x !== i)));

  function kaydet() {
    const dolu = liste.filter(z => sayi(z.miktar) > 0);
    if (dolu.length === 0) {
      setHata(cikis ? 'En az bir lottan miktar girilmeli.' : 'En az bir lot satiri girilmeli.');
      return;
    }
    // Cikista secilen miktar o lotun kalanini asamaz - depoda olmayan mal cikamaz.
    const asan = cikis ? dolu.find(z => sayi(z.miktar) > (z.kalan ?? 0)) : undefined;
    if (asan) {
      setHata(`"${asan.lotNo || asan.seriNo}" lotunda ${asan.kalan?.toLocaleString('tr-TR')} kaldi.`);
      return;
    }
    if (!cikis && kural.lot && dolu.some(z => !z.lotNo.trim())) { setHata('Lot No zorunlu.'); return }
    if (!cikis && kural.seri && dolu.some(z => !z.seriNo.trim())) { setHata('Seri No zorunlu.'); return }
    if (!cikis && kural.skt && dolu.some(z => !z.sonKullanmaTarihi)) { setHata('Son kullanma tarihi zorunlu.'); return }
    const t = dolu.reduce((x, z) => x + sayi(z.miktar), 0);
    if (Math.abs(t - miktar) > 0.0001) {
      setHata(`Lot toplami ${t.toLocaleString('tr-TR')} - kalem miktari ${miktar.toLocaleString('tr-TR')}.`);
      return;
    }
    onKaydet(dolu);
  }

  return (
    <Modal
      baslik={`${cikis ? 'Lot Seçimi' : 'Lot / Seri'} — ${stokAdi}`}
      onKapat={onKapat}
      alt={
        <>
          <button className="d onay" onClick={kaydet}>💾 Tamam</button>
          {/* Cikista lot ACILMAZ: stokta olmayan lottan mal cikamaz. */}
          {!cikis && <button className="d" onClick={satirEkle}>＋ Lot Ekle</button>}
          {/* RAF OMRU UST BANTTA ETIKET (kullanici 24.10.2026: "label olarak gelsin, tıklarsam modal olarak
              edit gireyim"): ÜRT girilince SKT, SKT girilince ÜRT bu sureden. */}
          {!cikis && tarihVar && (
            <button type="button" className="d" style={{ marginLeft: 8 }}
                    title={c('Üretim tarihi girilince SKT, SKT girilince üretim tarihi bu süreden hesaplanır. Değiştirmek için tıklayın.')}
                    onClick={() => { setRafTaslak({ sure: rafSure > 0 ? String(rafSure) : '', birim: rafBirim > 0 ? String(rafBirim) : '2' });
                                     setRafDuzenle(true) }}>
              <span className="sonuk">{c('Raf ömrü')}:</span>{' '}
              <b>{rafSure > 0 && rafBirim > 0 ? `${rafSure} ${c(RAF_BIRIM[rafBirim as 1 | 2 | 3])}` : c('tanımsız')}</b>
            </button>
          )}
          {/* TOPLAM OZETI UST BANTTA, TAMAM ILE KAPAT ARASINDA ORTADA (kullanici 24.10.2026): gereken (kalem
              miktari) · girilen (lot toplami) · kalan - uzun listede alttaki "Dağıtılmayan miktar" gorunmuyordu. */}
          <span style={{ flex: 1, display: 'flex', justifyContent: 'center', gap: 18, alignItems: 'baseline' }}>
            {([
              [c('Gereken'), miktar, ''],
              [c('Girilen'), toplam, ''],
              [fark < 0 ? c('Fazla') : c('Kalan'), Math.abs(fark), fark === 0 ? 'ml-alacak' : 'ml-borc'],
            ] as const).map(([ad, deger, sinif]) => (
              <span key={ad}><span className="sonuk">{ad}</span>{' '}
                <b className={sinif || undefined} style={{ fontSize: 16 }}>{deger.toLocaleString('tr-TR')}</b></span>))}
          </span>
          <button className="d kapat-dugmesi" onClick={onKapat}>{c('✖ Kapat')}</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor && <div className="yukleniyor">{c('Lotlar yükleniyor…')}</div>}
        {rafDuzenle && (
          <Modal baslik={c('Raf Ömrü')} onKapat={() => setRafDuzenle(false)} buyutmeYok dar
                 alt={<>
                   <button className="d onay" onClick={() => { void rafKaydet(); setRafDuzenle(false) }}>💾 {c('Kaydet')}</button>
                   <span style={{ marginLeft: 'auto' }} />
                   <button className="d kapat-dugmesi" onClick={() => setRafDuzenle(false)}>✖ {c('Kapat')}</button>
                 </>}>
            <div style={{ display: 'flex', gap: 6, alignItems: 'center', padding: 4 }}>
              <input className="hiza-sag" style={{ width: 70 }} autoFocus value={rafTaslak.sure} placeholder={c('Süre')}
                     onChange={e => setRafTaslak(t => ({ ...t, sure: e.target.value.replace(/[^0-9]/g, '') }))}
                     onKeyDown={e => { if (e.key === 'Enter') { void rafKaydet(); setRafDuzenle(false) } }} />
              <select value={rafTaslak.birim} onChange={e => setRafTaslak(t => ({ ...t, birim: e.target.value }))}>
                <option value="1">{c('Gün')}</option>
                <option value="2">{c('Ay')}</option>
                <option value="3">{c('Yıl')}</option>
              </select>
            </div>
            <div className="not" style={{ padding: '6px 4px 0' }}>
              {c('Üretim tarihi girilince SKT, SKT girilince üretim tarihi bu süreden hesaplanır; stok kartına yazılır.')}</div>
          </Modal>
        )}

        {rafNot && <div className="bilgi-kutusu">{rafNot}</div>}
        {cikis && !yukleniyor && liste.length === 0 && (
          <div className="bilgi-kutusu">Bu stokta kalan lot yok — önce giriş yapılmalı.</div>
        )}
        <div className="kagrup">
          <table className="detay-tablo">
            <thead>
              <tr>
                {/* Zorunluluk yildizi yalniz GIRISTE: cikista bu alanlar
                    stoktan gelir, kullanici doldurmaz. */}
                <th>Lot No{!cikis && kural.lot && <b className="zorunlu"> *</b>}</th>
                {seriVar && <th>Seri No{!cikis && kural.seri && <b className="zorunlu"> *</b>}</th>}
                {tarihVar && <th>{c('Ürt. Tarihi')}</th>}
                {tarihVar && <th>SKT{!cikis && kural.skt && <b className="zorunlu"> *</b>}</th>}
                {/* Giriste DURUM (girişte 0), cikista o lottan KALAN gosterilir. */}
                <th>{cikis ? 'Kalan' : 'Durum'}</th>
                <th className="hiza-sag">Miktar</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {liste.map((z, i) => (
                <tr key={z.seriLotId ?? i}>
                  {/* CIKISTA lot bilgisi stoktan gelir - yalniz miktar girilir. */}
                  <td><input value={z.lotNo} autoFocus={!cikis && i === 0} readOnly={cikis} disabled={cikis}
                             ref={el => { if (el && i === odakSatir) { el.focus(); setOdakSatir(null) } }}
                             onChange={e => degis(i, 'lotNo', e.target.value)} /></td>
                  {seriVar && <td><input value={z.seriNo} readOnly={cikis} disabled={cikis}
                             onChange={e => degis(i, 'seriNo', e.target.value)} /></td>}
                  {tarihVar && <td><input type="date" value={z.uretimTarihi} readOnly={cikis} disabled={cikis}
                             onChange={e => degis(i, 'uretimTarihi', e.target.value)} /></td>}
                  {tarihVar && <td>
                    <input type="date" value={z.sonKullanmaTarihi} readOnly={cikis} disabled={cikis}
                           className={z.sonKullanmaTarihi && z.sonKullanmaTarihi < bugunIso() ? 'skt-gecmis' : undefined}
                           title={z.sonKullanmaTarihi && z.sonKullanmaTarihi < bugunIso()
                             ? 'Son kullanma tarihi GEÇMİŞ' : undefined}
                           onChange={e => degis(i, 'sonKullanmaTarihi', e.target.value)} />
                  </td>}
                  {cikis
                    ? <td className="hiza-sag">{(z.kalan ?? 0).toLocaleString('tr-TR')}</td>
                    /* Giriste tek durum var; kod listesi genisleyince combo olur. */
                    : <td><input value="Girişte" readOnly disabled /></td>}
                  <td><input className="hiza-sag" value={z.miktar}
                             onChange={e => degis(i, 'miktar', e.target.value.replace(/-/g, ''))} /></td>
                  <td>
                    {cikis
                      ? (sayi(z.miktar) > 0 && (
                          <button type="button" className="mini" title="Seçimi kaldır"
                                  onClick={() => degis(i, 'miktar', '')}>×</button>))
                      : (
                        <button type="button" className="mini" title={c('Satırı sil')}
                                onClick={() => satirSil(i)}>×</button>)}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={2 + (seriVar ? 1 : 0) + (tarihVar ? 2 : 0)}>
                  {/* SKT gecmisse ENGEL DEGIL UYARI: mal fiilen gelmis olabilir
                      (iade, imha oncesi giris) - karar kullanicinin. */}
                  {gecmisSkt > 0 && (
                    <div className="hata-metin" style={{ marginBottom: 4 }}>
                      ⚠ {gecmisSkt} lotta son kullanma tarihi geçmiş.
                    </div>
                  )}
                  {fark === 0 ? 'Dağıtım tamam.'
                    : fark > 0 ? `Dağıtılmayan miktar: ${fark.toLocaleString('tr-TR')}`
                    : `Fazla dağıtım: ${Math.abs(fark).toLocaleString('tr-TR')}`}
                </td>
                <td className="hiza-sag">
                  <b className={fark === 0 ? '' : 'hata-metin'}>
                    {toplam.toLocaleString('tr-TR')} / {miktar.toLocaleString('tr-TR')}
                  </b>
                </td>
                <td />
              </tr>
            </tfoot>
          </table>
        </div>
      </>
    </Modal>
  );
}
