import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';

/**
 * RADYOLOJI ISTEM ACMA (304).
 *
 * Iki mockup'in ortak ekrani: radyoloji_hekim_istem.html (IC istem -
 * poliklinikteki hekim basvuruya tetkik ister) ve radyoloji_kayit_kabul.html
 * (DIS istem - baska kurumun hekiminden gelen hasta). Fark yalnizca
 * ISTEYENIN kim oldugu; tetkik secimi, klinik bilgi, ucret ve accession
 * uretimi ayni oldugu icin tek bilesen.
 *
 * Bir seferde COK TETKIK secilir: her biri AYRI istem (ayri accession) olur -
 * PACS ve raporlama accession bazlidir.
 */

interface Tetkik { id: number; kod: string; ad: string; modalite: number;
                   modaliteAdi: string; kdv: number }
interface Hekim { id: number; ad: string; bolumAdi: string }
interface Gecmis { hizmetId: number; tetkikAdi: string; tarih: string }

/** Secili tetkik: listedeki tetkik + isteme ozel secimler. */
interface Secim { tetkik: Tetkik; oncelik: number; kontrast: number }

const ONCELIK = [
  { deger: 1, ad: 'Normal' },
  { deger: 2, ad: 'Acil' },
  { deger: 3, ad: 'Çok Acil' },
];

const KONTRAST = [
  { deger: 0, ad: 'Verilmeyecek' },
  { deger: 1, ad: 'Verilecek' },
];

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

export function IstemModali({ acik, hastaId, hastaAdi, belgeId, disIstem, onKapat, onTamam }: {
  acik: boolean;
  hastaId: number;
  hastaAdi: string;
  /** Basvuru (protokol) - ucret satirlari buraya eklenir. */
  belgeId?: number | null;
  /** DIS istem mi: disaridan gelen hastanin istem kagidi (hekim/kurum adi elle). */
  disIstem?: boolean;
  onKapat(): void;
  onTamam?(accessionlar: string[]): void;
}) {
  const [tetkikler, setTetkikler] = useState<Tetkik[]>([]);
  const [hekimler, setHekimler] = useState<Hekim[]>([]);
  /** Kayitli dis hekim secildiyse id; "listede yok" ise serbest metin. */
  const [disHekimId, setDisHekimId] = useState<number | null>(null);
  const [disHekimSecim, setDisHekimSecim] = useState('');
  const [hekimArama, setHekimArama] = useState(false);
  const [gecmis, setGecmis] = useState<Gecmis[]>([]);
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<Secim[]>([]);
  const [istekHekimId, setIstekHekimId] = useState<number | null>(null);
  const [disHekimAd, setDisHekimAd] = useState('');
  const [istekKurumId, setIstekKurumId] = useState<number | null>(null);
  /** Secili kurumun ADI - kutuda id degil ad gorunur. */
  const [istekKurumAd, setIstekKurumAd] = useState('');
  const [kurumArama, setKurumArama] = useState(false);
  const [onTani, setOnTani] = useState('');
  const [klinikBilgi, setKlinikBilgi] = useState('');
  const [ucretEkle, setUcretEkle] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.radyolojiIstemSecenekleri(hastaId);
      setTetkikler(y.tetkikler as unknown as Tetkik[]);
      setHekimler(y.hekimler as unknown as Hekim[]);
      setGecmis(y.gecmis as unknown as Gecmis[]);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);

  useEffect(() => { if (acik) void yukle() }, [acik, yukle]);

  /** Modaliteye gore gruplu, aramayla suzulmus tetkik agaci. */
  const agac = useMemo(() => {
    const k = ara.trim().toLocaleLowerCase('tr');
    const suz = k
      ? tetkikler.filter(t => t.ad.toLocaleLowerCase('tr').includes(k)
                           || t.kod.toLocaleLowerCase('tr').includes(k))
      : tetkikler;
    const gruplar = new Map<string, Tetkik[]>();
    suz.forEach(t => {
      const g = t.modaliteAdi || 'Diğer';
      if (!gruplar.has(g)) gruplar.set(g, []);
      gruplar.get(g)!.push(t);
    });
    return [...gruplar.entries()];
  }, [tetkikler, ara]);

  const ekle = (t: Tetkik) => {
    if (secili.some(s => s.tetkik.id === t.id)) return;
    setSecili(x => [...x, { tetkik: t, oncelik: 1, kontrast: 0 }]);
  };
  const cikar = (id: number) => setSecili(x => x.filter(s => s.tetkik.id !== id));
  const degistir = (id: number, y: Partial<Secim>) =>
    setSecili(x => x.map(s => (s.tetkik.id === id ? { ...s, ...y } : s)));

  /** Son 12 ayda ayni tetkik cekilmis mi (mockup mukerrer tetkik uyarisi). */
  const mukerrer = secili
    .map(s => gecmis.find(g => g.hizmetId === s.tetkik.id))
    .filter(Boolean) as Gecmis[];

  const kaydet = async () => {
    setHata('');
    if (secili.length === 0) { setHata('En az bir tetkik seçilmeli.'); return }
    if (!klinikBilgi.trim()) {
      setHata('Klinik bilgi / istem gerekçesi yazılmalı — radyolog raporu buradan yazar.');
      return;
    }
    setKaydediyor(true);
    try {
      const y = await api.radyolojiIstemAc({
        hastaId, belgeId: belgeId ?? null,
        // DIS istemde de istekHekimId dolabilir: kayitli dis hekim secildiyse
        //   kayit ona baglanir (kart "gonderdigi tetkik" sayaci bundan besleniyor),
        //   secilmediyse serbest metin yazilir.
        istekHekimId: disIstem ? disHekimId : istekHekimId,
        disHekimAd: disIstem && !disHekimId ? disHekimAd : '',
        istekKurumId: disIstem ? istekKurumId : null,
        onTani, klinikBilgi,
        oncelik: 1,
        ucretEkle: ucretEkle && !!belgeId,
        tetkikler: secili.map(s => ({ hizmetId: s.tetkik.id, oncelik: s.oncelik,
                                      kontrast: s.kontrast })),
      });
      mesaj(`${y.idler.length} istem açıldı: ${y.accessionlar.join(', ')}`);
      onTamam?.(y.accessionlar);
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  if (!acik) return null;

  return (
    <Modal baslik={`Radyoloji İstemi — ${hastaAdi}`} onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Açılıyor…' : `✔ İstemi Aç (${secili.length})`}
               </button>
               <button className="d" onClick={onKapat}>✖ Vazgeç</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="istem-duzen">
        {/* --- SOL: tetkik agaci --- */}
        <div className="kagrup istem-agac">
          <h6>Tetkik Seçimi</h6>
          <div className="kagov">
            <input value={ara} placeholder="🔍 Tetkik ara (kod / ad)…"
                   onChange={e => setAra(e.target.value)} />
            {agac.length === 0 && (
              <div className="not">
                Modalitesi tanımlı tetkik yok. Hizmet kartında “Modalite” alanı
                doldurulan hizmetler burada listelenir.
              </div>
            )}
            {agac.map(([grup, liste]) => (
              <div className="agac-grup" key={grup}>
                <div className="agac-baslik">{grup}</div>
                {liste.map(t => (
                  <div className="agac-satir" key={t.id} onClick={() => ekle(t)}>
                    <span className="sonuk">{t.kod}</span> {t.ad}
                  </div>
                ))}
              </div>
            ))}
          </div>
        </div>

        {/* --- SAG: secilenler + istem bilgisi --- */}
        <div className="istem-sag">
          <div className="kagrup">
            <h6>Seçilen Tetkikler ({secili.length})</h6>
            <table className="detay-tablo">
              <thead>
                <tr><th>Kod</th><th>Tetkik</th><th>Öncelik</th><th>Kontrast</th><th /></tr>
              </thead>
              <tbody>
                {secili.length === 0 && (
                  <tr><td colSpan={5} className="bos">Soldaki listeden tetkik seçin.</td></tr>
                )}
                {secili.map(s => (
                  <tr key={s.tetkik.id}>
                    <td className="sonuk">{s.tetkik.kod}</td>
                    <td>{s.tetkik.ad}</td>
                    <td>
                      <select value={s.oncelik}
                              onChange={e => degistir(s.tetkik.id,
                                                      { oncelik: Number(e.target.value) })}>
                        {ONCELIK.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
                      </select>
                    </td>
                    <td>
                      <select value={s.kontrast}
                              onChange={e => degistir(s.tetkik.id,
                                                      { kontrast: Number(e.target.value) })}>
                        {KONTRAST.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
                      </select>
                    </td>
                    <td>
                      <button className="d mini teh" title="Listeden çıkar"
                              onClick={() => cikar(s.tetkik.id)}>✕</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* MUKERRER TETKIK: engel degil UYARI - hekim gerekcelendirsin. */}
          {mukerrer.length > 0 && (
            <div className="uyari-kutusu">
              Son 12 ayda aynı tetkik yapılmış:{' '}
              {mukerrer.map(m => `${m.tetkikAdi} (${gun(m.tarih)})`).join(' · ')}.
              Yeni istemi klinik bilgide gerekçelendirin.
            </div>
          )}

          <div className="kagrup">
            <h6>İstem Bilgisi</h6>
            <div className="alan-izgara dort-sutun">
              {disIstem ? (
                <>
                  {/* Kayitli dis hekim (305) JENERIK ARAMA EKRANINDAN secilir
                      (kullanici): combo, hekim sayisi artinca kullanilmaz hale
                      gelirdi - arama ekraninda brans/kurum kolonlariyla
                      "hangi Ortopedi hekimiydi" sorusu cevaplanabiliyor.
                      Secilen hekim istemin istek_hekim_id'sine yazilir ve
                      hekim kartindaki "gonderdigi tetkik" sayaci isler. */}
                  {/* genis-2: arama kutusu + iki dugme dort-sutunluk dar hucreye
                      sigmiyor, secili ad "Öz…" diye kirpiliyordu. */}
                  <label className="alan genis-2">
                    <span className="etiket">İsteyen Hekim (dış)</span>
                    <span className="ikili">
                      <input value={disHekimSecim} readOnly
                             placeholder="Kayıtlı hekim seç…"
                             onClick={() => setHekimArama(true)} />
                      <button type="button" className="d mini"
                              title="Dış hekim ara"
                              onClick={() => setHekimArama(true)}>…</button>
                      {disHekimId != null && (
                        <button type="button" className="d mini" title="Seçimi kaldır"
                                onClick={() => { setDisHekimId(null); setDisHekimSecim('') }}>
                          ✕
                        </button>
                      )}
                    </span>
                  </label>
                  {/* Kayitli hekim SECILMEDIYSE serbest metin - bir kerelik
                      gelen, kaydedilmeye degmeyen hekim icin. */}
                  {!disHekimId && (
                    <label className="alan">
                      <span className="etiket">Hekim Adı (kayıtsız)</span>
                      <input value={disHekimAd} placeholder="örn. Op. Dr. Kerem ATALAY"
                             onChange={e => setDisHekimAd(e.target.value)} />
                    </label>
                  )}
                  {/* ISTEYEN KURUM da JENERIK ARAMA (kullanici): combo yalniz
                      ilk 200 cariyi tasiyordu - sevk eden hastane listede
                      yoksa alan bos birakiliyordu. Arama ekraninda "+ Yeni"
                      ile kurum aninda cari olarak acilabiliyor. */}
                  <label className="alan genis-2">
                    <span className="etiket">İsteyen Kurum</span>
                    <span className="ikili">
                      <input value={istekKurumAd} readOnly
                             placeholder="Kurum seç…"
                             onClick={() => setKurumArama(true)} />
                      <button type="button" className="d mini" title="Kurum ara"
                              onClick={() => setKurumArama(true)}>…</button>
                      {istekKurumId != null && (
                        <button type="button" className="d mini" title="Seçimi kaldır"
                                onClick={() => { setIstekKurumId(null); setIstekKurumAd('') }}>
                          ✕
                        </button>
                      )}
                    </span>
                  </label>
                </>
              ) : (
                <label className="alan genis-2">
                  <span className="etiket">İsteyen Hekim</span>
                  <select value={istekHekimId ?? ''}
                          onChange={e => setIstekHekimId(
                            e.target.value ? Number(e.target.value) : null)}>
                    <option value="">— Seçiniz —</option>
                    {hekimler.map(h => (
                      <option key={h.id} value={h.id}>
                        {h.ad}{h.bolumAdi ? ` · ${h.bolumAdi}` : ''}
                      </option>
                    ))}
                  </select>
                </label>
              )}
              <label className="alan">
                <span className="etiket">Ön Tanı (ICD-10)</span>
                <input value={onTani} maxLength={20} placeholder="örn. M51.1"
                       onChange={e => setOnTani(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Ücret</span>
                <span className="deger-serit">
                  <input type="checkbox" checked={ucretEkle} disabled={!belgeId}
                         onChange={e => setUcretEkle(e.target.checked)} />
                  <span className={belgeId ? '' : 'sonuk'}>
                    {belgeId ? 'Başvuruya ücret satırı ekle' : 'Başvuru yok — ücret eklenmez'}
                  </span>
                </span>
              </label>

              <label className="alan genis-4">
                <span className="etiket zorunlu-isaret">Klinik Bilgi / İstem Gerekçesi</span>
                <textarea rows={3} value={klinikBilgi}
                          placeholder="örn. 3 aydır süren bel ağrısı, sağ bacağa yayılım. Konservatif tedaviye yanıtsız."
                          onChange={e => setKlinikBilgi(e.target.value)} />
              </label>
            </div>
            <div className="not">
              Klinik bilgi radyoloğun raporunda “Klinik Bilgi” bölümüne düşer —
              boş istem radyologa “neden çekildi” sorusunu bıraktığı için zorunludur.
              Kaydedince her tetkik için ayrı istem (accession no) üretilir ve
              çalışma listesine düşer.
            </div>
          </div>
        </div>
      </div>

      {/* Dis hekim arama - jenerik taraf arama ekrani, kaynak 'dis-hekim'.
          enUst: bu modalin uzerinde acilmali. */}
      <TarafArama
        acik={hekimArama}
        kaynaklar={['dis-hekim']}
        yerTutucu="Dış hekimi ad / kurum ile ara…"
        onKapat={() => setHekimArama(false)}
        onSec={sec => {
          setDisHekimId(sec.id);
          setDisHekimSecim(sec.unvan);
          setDisHekimAd('');
          setHekimArama(false);
        }}
      />

      {/* Isteyen kurum - jenerik cari aramasi (hekim aramasiyla ayni desen). */}
      <TarafArama
        acik={kurumArama}
        kaynaklar={['cari']}
        yerTutucu="Kurum / cari ara…"
        onKapat={() => setKurumArama(false)}
        onSec={sec => {
          setIstekKurumId(sec.id);
          setIstekKurumAd(sec.unvan);
          setKurumArama(false);
        }}
      />
    </Modal>
  );
}
