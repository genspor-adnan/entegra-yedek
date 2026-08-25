import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type AcikSatir, type BelgeYaniti } from '../api/sozlesme';
import { Modal } from './GenForm';
import { para, say4 } from './bicim';


/**
 * Numarasi KARSI TARAFTA uretilen belgeler: alis faturasinin numarasi
 * tedarikcinin fatura numarasidir, sayacimiz uretemez - kullanici girer.
 * Sunucudaki DisNumaraliTur ile ayni liste.
 */
const DIS_NUMARALI = new Set([11]);

/**
 * Kaynak turden hangi hedeflere donusulebilir (belge turu kod uzayi, 073
 * katalogu).
 *
 * Siparis ve irsaliye YALNIZ faturaya/irsaliyeye degil; FIS ve TAHAKKUK da
 * hedef olabilir (kullanici):
 *   - Fis (12/16): fatura kesilmeden stok/cari hareketi yazilan ic belge
 *     (perakende satis, numune cikisi gibi) - e-Belge'ye gitmez.
 *   - Tahakkuk (13/17): mal hareketi olmayan alacak/borc kaydi; siparis ya da
 *     irsaliye tutari faturalanmadan cari hesaba islenmek istendiginde.
 * Yon KAYNAKTAN gelir: alis zincirinde alis hedefleri, satista satis.
 */
const HEDEFLER: Record<number, { kod: number; ad: string }[]> = {
  // Alis siparisi
  9:  [{ kod: 10, ad: 'Alış İrsaliyesi' }, { kod: 11, ad: 'Alış Faturası' },
       { kod: 12, ad: 'Alış Fişi' }, { kod: 17, ad: 'Borç Tahakkuku' }],
  // Satis siparisi
  19: [{ kod: 14, ad: 'Satış İrsaliyesi' }, { kod: 15, ad: 'Satış Faturası' },
       { kod: 16, ad: 'Satış Fişi' }, { kod: 13, ad: 'Alacak Tahakkuku' }],
  // Irsaliyeler (konsinye dahil): mal zaten cikti/girdi, sirada belgelenmesi var
  10:  [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 17, ad: 'Borç Tahakkuku' }],
  14:  [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 13, ad: 'Alacak Tahakkuku' }],
  109: [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 17, ad: 'Borç Tahakkuku' }],
  119: [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 13, ad: 'Alacak Tahakkuku' }],
};

interface Props {
  belgeId: number;
  belgeTur: number;
  /**
   * Arac cubugundaki dugmenin sectigi hedef ("İrsaliyeye Dönüştür" -> 14).
   * Listede yoksa ya da 0 ise ilk hedefe duser; kullanici combodan degistirir.
   */
  varsayilanHedef?: number;
  onKapat(): void;
  /** Donusum bittiginde cagrilir - cagiran yalnizca grid'i tazeler. */
  onTamam(yeni: BelgeYaniti): void;
}

/**
 * Sipariş → irsaliye → fatura dönüşümü.
 *
 * KISMI donusum esastir: kullanici her satirdan ne kadarini aktaracagini secer,
 * kalan kaynak belgede durur. Miktar kontrolu SUNUCUDA yapilir (kaynak satirlar
 * kilitlenerek) - buradaki sinir yalnizca kullaniciyi erken uyarmak icindir.
 */
export function BelgeDonusumModali({ belgeId, belgeTur, varsayilanHedef, onKapat, onTamam }: Props) {
  const [satirlar, setSatirlar] = useState<AcikSatir[]>([]);
  const [miktarlar, setMiktarlar] = useState<Record<number, string>>({});
  const [secili, setSecili] = useState<Record<number, boolean>>({});
  const [hedefTur, setHedefTur] = useState<number>(() => {
    const liste = HEDEFLER[belgeTur] ?? [];
    return liste.some(h => h.kod === varsayilanHedef)
      ? varsayilanHedef! : (liste[0]?.kod ?? 0);
  });
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [belgeNo, setBelgeNo] = useState('');
  /* Taslak kutusu kaldirildi (kullanici) - donusum hep KESIN belge uretir. */
  const taslak = false;
  const [yukleniyor, setYukleniyor] = useState(true);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  /** Uretilen belgenin turu - basari kutusunda yazar (combo sonradan degisebilir). */
  const [sonucAd, setSonucAd] = useState('');

  useEffect(() => {
    void (async () => {
      try {
        const s = await api.belgeAcikSatirlar(belgeId);
        setSatirlar(s);
        setSecili(Object.fromEntries(s.map(x => [x.satirId, true])));
        setMiktarlar(Object.fromEntries(s.map(x => [x.satirId, String(x.kalanMiktar)])));
      } catch (h) {
        setHata(h instanceof ApiHatasi ? h.message : String(h));
      } finally { setYukleniyor(false) }
    })();
  }, [belgeId]);

  const hedefler = HEDEFLER[belgeTur] ?? [];
  const disNumarali = DIS_NUMARALI.has(hedefTur);
  const sayi = (m: string) => Number(m.replace(/\./g, '').replace(',', '.')) || 0;

  const toplam = useMemo(() =>
    satirlar.reduce((t, s) => secili[s.satirId]
      ? t + sayi(miktarlar[s.satirId] ?? '0') * Number(s.birimFiyat ?? 0) : t, 0),
    [satirlar, secili, miktarlar]);

  const seciliSayi = satirlar.filter(s => secili[s.satirId] && sayi(miktarlar[s.satirId] ?? '0') > 0).length;

  async function donustur() {
    setHata(null);
    const gonderilecek = satirlar
      .filter(s => secili[s.satirId] && sayi(miktarlar[s.satirId] ?? '0') > 0)
      .map(s => ({ satirId: s.satirId, miktar: sayi(miktarlar[s.satirId]) }));

    if (gonderilecek.length === 0) { setHata('En az bir satır seçilmeli.'); return }
    if (!hedefTur) { setHata('Hedef belge türü seçilmeli.'); return }

    const asan = gonderilecek.find(g => {
      const s = satirlar.find(x => x.satirId === g.satirId)!;
      return g.miktar > Number(s.kalanMiktar);
    });
    if (asan) { setHata('Bir satırda girilen miktar kalanı aşıyor.'); return }
    if (disNumarali && !taslak && belgeNo.trim() === '') {
      setHata('Tedarikçi belge numarası girilmeli.'); return;
    }

    setCalisiyor(true);
    try {
      const yeni = await api.belgeDonustur(belgeId, hedefTur, gonderilecek, tarih, taslak,
                                           disNumarali ? belgeNo.trim() : undefined);
      setSonuc(yeni);
      setSonucAd(hedefler.find(h => h.kod === hedefTur)?.ad ?? 'Belge');
      setBelgeNo('');
      // Kalan satirlari tazele: ayni siparisten ikinci bir belge kesilebilir.
      setSatirlar(await api.belgeAcikSatirlar(belgeId));
      onTamam(yeni);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setCalisiyor(false) }
  }

  return (
    <Modal
      baslik="Belge Dönüştür"
      onKapat={onKapat}
      alt={
        <>
          <button className="d bir" disabled={calisiyor || satirlar.length === 0}
                  onClick={() => void donustur()}>
            {calisiyor ? 'Dönüştürülüyor…' : sonuc ? '⇢ Kalanı Dönüştür' : '⇢ Dönüştür'}
          </button>
          <button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* Hata varken ONCEKI basari kutusu gizlenir: iki kutu yan yana durunca
          "hem oldu hem olmadi" gibi okunuyordu (yesil kutu bir onceki
          donusumun sonucu). */}
      {sonuc && !hata && (
        <div className="bilgi-kutusu">
          {/* Hedef adi DONUSUM ANINDA sabitlenir: combo sonradan degistirilince
              "Satış Fişi oluşturuldu" yazip aslinda tahakkuk uretmis gibi
              gorunuyordu. */}
          <b>{sonucAd || 'Belge'} oluşturuldu.</b>{' '}
          No: <b>{String(sonuc.belge.belgeNo || '—')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

      {hedefler.length === 0 ? (
        <div className="bilgi-kutusu">Bu belge türü için tanımlı bir dönüşüm hedefi yok.</div>
      ) : (
        <>
          <div className="kagrup">
            <h6>Hedef</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">Hedef Belge</span>
                <select value={hedefTur} onChange={e => setHedefTur(Number(e.target.value))}>
                  {hedefler.map(h => <option key={h.kod} value={h.kod}>{h.ad}</option>)}
                </select>
              </label>
              {/* Alis faturasinda numara TEDARIKCININ - sayac uretmez, sorulur. */}
              {disNumarali && (
                <label className="alan">
                  <span className="etiket zorunlu-isaret">Tedarikçi Fatura No</span>
                  <input value={belgeNo} maxLength={20} placeholder="örn. ABC2026000001234"
                         onChange={e => setBelgeNo(e.target.value)} />
                </label>
              )}
              <label className="alan">
                <span className="etiket">Belge Tarihi</span>
                <input type="date" value={tarih} onChange={e => setTarih(e.target.value)} />
              </label>
              {/* TASLAK kutusu KALKTI (kullanici): donusumden cikan belge de
                  kesindir - kart tarafinda da ayni kural. */}
            </div>
          </div>

          <div className="kagrup">
            <h6>Dönüştürülecek Satırlar</h6>
            {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th style={{ width: 34 }} />
                    <th>Stok / Açıklama</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Dönüşen</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
                    <th className="hiza-sag" style={{ width: 120 }}>Bu Belgeye</th>
                    <th className="hiza-sag" style={{ width: 110 }}>Birim Fiyat</th>
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map(s => (
                    // Satira tiklamak da isaretler: burada secim = "bu satiri
                    //   donustur" isareti, coklu secim ASILDIR - o yuzden duz tik
                    //   digerlerini kaldirmaz (liste gridlerinin aksine).
                    <tr key={s.satirId}
                        className={secili[s.satirId] ? 'secili' : ''}
                        onClick={() => setSecili(x => ({ ...x, [s.satirId]: !x[s.satirId] }))}>
                      <td className="hiza-orta">
                        <input
                          type="checkbox"
                          checked={!!secili[s.satirId]}
                          onClick={e => e.stopPropagation()}
                          onChange={e => setSecili(x => ({ ...x, [s.satirId]: e.target.checked }))}
                        />
                      </td>
                      <td>
                        {s.stokKodu ? <><code>{s.stokKodu}</code> {s.stokAdi}</> : s.aciklama}
                      </td>
                      <td className="hiza-sag">{say4.format(Number(s.miktar))}</td>
                      <td className="hiza-sag">{say4.format(Number(s.kapatilanMiktar))}</td>
                      <td className="hiza-sag"><b>{say4.format(Number(s.kalanMiktar))}</b></td>
                      <td>
                        <input
                          className="hiza-sag"
                          value={miktarlar[s.satirId] ?? ''}
                          disabled={!secili[s.satirId]}
                          onClick={e => e.stopPropagation()}
                          onChange={e => setMiktarlar(x => ({ ...x, [s.satirId]: e.target.value }))}
                        />
                      </td>
                      <td className="hiza-sag">{para.format(Number(s.birimFiyat ?? 0))}</td>
                    </tr>
                  ))}
                  {satirlar.length === 0 && (
                    <tr><td colSpan={7} className="bos">Dönüştürülecek açık satır yok.</td></tr>
                  )}
                </tbody>
                <tfoot>
                  <tr className="genel">
                    <td colSpan={5}>{seciliSayi} satır seçili</td>
                    <td className="hiza-sag" colSpan={2}>
                      {para.format(toplam)} (KDV hariç, önizleme)
                    </td>
                  </tr>
                </tfoot>
              </table>
            )}
          </div>

          <div className="not">
            Kalan miktar kaynağında durur; aynı siparişten birden fazla irsaliye/fatura
            kesilebilir. Miktar kontrolü sunucuda, kaynak satırlar kilitlenerek yapılır.
          </div>
        </>
      )}
    </Modal>
  );
}
