import { useEffect, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { ApiHatasi } from '../../api/sozlesme';
import {
  type IzlemSatiri, bosIzlem, izlemKurali, tariheEkle, bugunIso, RAF_BIRIM,
} from '../../sayfalar/belgeSatir';

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
export function IzlemPenceresi({ stokAdi, stokId, depoId, izleme, miktar, satirlar, cikis,
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

  // RAF OMRU (stok karti): ÜRT <-> SKT donusumu bununla yapilir. Kartta yoksa
  //   kullanicidan BURADA sorulur ve karta yazilir - lot girisini yarida kesip
  //   stok kartina gitmek zorunda kalmasin.
  const [rafSure, setRafSure] = useState(0);
  const [rafBirim, setRafBirim] = useState(0);
  const [rafSurum, setRafSurum] = useState<string | undefined>();
  const [rafSoruluyor, setRafSoruluyor] = useState(false);
  const [rafTaslak, setRafTaslak] = useState({ sure: '', birim: '2' });
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
        // Tanimsizsa hemen sor: SKT hesabi buna bagli.
        if (sure <= 0 || birim <= 0) setRafSoruluyor(true);
      })
      .catch(() => { /* kart okunamazsa raf omru sorulmaz, elle girilir */ });
    return () => { iptal = true };
  }, [cikis, stokId]);

  /** Raf omru kullanicidan alindi: STOK KARTINA yazilir, sonra hesaplama acilir. */
  async function rafKaydet() {
    const sure = Number(rafTaslak.sure.replace(',', '.')) || 0;
    const birim = Number(rafTaslak.birim) || 0;
    if (sure <= 0 || birim <= 0) { setHata('Raf ömrü ve birimi girilmeli.'); return }
    setRafSure(sure); setRafBirim(birim); setRafSoruluyor(false); setHata(null);
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
          if (eski.length > 0) return eski;          // kalem yeniden acildi
          return lotlar.map(l => ({
            seriLotId: l.seriLotId,
            kalan: l.kalan,
            lotNo: l.lotNo,
            seriNo: l.seriNo,
            uretimTarihi: (l.uretimTarihi ?? '').slice(0, 10),
            sonKullanmaTarihi: (l.sonKullanmaTarihi ?? '').slice(0, 10),
            durum: 0,
            miktar: '',
          }));
        });
      })
      .catch(h => setHata(h instanceof ApiHatasi ? h.message : String(h)))
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [cikis, stokId, depoId]);

  const sayi = (m: string) => Number(m.replace(',', '.')) || 0;
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

  const satirEkle = () =>
    // Yeni satir KALAN miktarla acilir - kullanici hesap yapmasin.
    setListe(l => [...l, bosIzlem(fark > 0 ? String(fark) : '')]);

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
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor && <div className="yukleniyor">Lotlar yükleniyor…</div>}

        {/* RAF OMRU kartta tanimli degil: burada sorulur, karta yazilir.
            Lot girisini birakip stok kartina gitmeye gerek kalmasin. */}
        {rafSoruluyor && (
          <div className="bilgi-kutusu">
            <b>Bu stokta raf ömrü tanımlı değil.</b> Girilirse üretim tarihinden SKT
            (ya da SKT'den üretim tarihi) otomatik hesaplanır ve stok kartına yazılır.
            <div className="ikili" style={{ marginTop: 6, maxWidth: 320 }}>
              <input className="hiza-sag" placeholder="Süre" value={rafTaslak.sure}
                     onChange={e => setRafTaslak(t => ({ ...t, sure: e.target.value.replace(/[^0-9]/g, '') }))} />
              <select value={rafTaslak.birim}
                      onChange={e => setRafTaslak(t => ({ ...t, birim: e.target.value }))}>
                <option value="1">Gün</option>
                <option value="2">Ay</option>
                <option value="3">Yıl</option>
              </select>
              <button type="button" className="d bir" onClick={() => void rafKaydet()}>Kaydet</button>
              <button type="button" className="d" onClick={() => setRafSoruluyor(false)}>Şimdilik geç</button>
            </div>
          </div>
        )}
        {rafNot && <div className="bilgi-kutusu">{rafNot}</div>}
        {!cikis && !rafSoruluyor && rafSure > 0 && rafBirim > 0 && (
          <div className="not">
            Raf ömrü <b>{rafSure} {RAF_BIRIM[rafBirim as 1 | 2 | 3]}</b> — üretim tarihi
            girilince SKT, SKT girilince üretim tarihi otomatik hesaplanır.
          </div>
        )}
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
                <th>Seri No{!cikis && kural.seri && <b className="zorunlu"> *</b>}</th>
                <th>Ürt. Tarihi</th>
                <th>SKT{!cikis && kural.skt && <b className="zorunlu"> *</b>}</th>
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
                             onChange={e => degis(i, 'lotNo', e.target.value)} /></td>
                  <td><input value={z.seriNo} readOnly={cikis} disabled={cikis}
                             onChange={e => degis(i, 'seriNo', e.target.value)} /></td>
                  <td><input type="date" value={z.uretimTarihi} readOnly={cikis} disabled={cikis}
                             onChange={e => degis(i, 'uretimTarihi', e.target.value)} /></td>
                  <td>
                    <input type="date" value={z.sonKullanmaTarihi} readOnly={cikis} disabled={cikis}
                           className={z.sonKullanmaTarihi && z.sonKullanmaTarihi < bugunIso() ? 'skt-gecmis' : undefined}
                           title={z.sonKullanmaTarihi && z.sonKullanmaTarihi < bugunIso()
                             ? 'Son kullanma tarihi GEÇMİŞ' : undefined}
                           onChange={e => degis(i, 'sonKullanmaTarihi', e.target.value)} />
                  </td>
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
                        <button type="button" className="mini" title="Satırı sil"
                                onClick={() => satirSil(i)}>×</button>)}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={5}>
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
