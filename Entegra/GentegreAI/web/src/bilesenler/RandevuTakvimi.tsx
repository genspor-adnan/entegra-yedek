import { type ReactNode, useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { type ListeSatiri, hataMetni } from '../api/sozlesme';

/**
 * RANDEVU TAKVİMİ (243) - günlük ve haftalık görünüm (kullanıcı isteği).
 *
 * Saat aralıkları ve çalışma günleri Randevu Ayarları'ndan gelir
 * (referans: randevu.baslangic_saat / bitis_saat / slot_dk / calisma_gunleri).
 * Hücreye tıklamak o saat için yeni randevu açar; dolu randevuya tıklamak
 * kartı açar - liste görünümüyle aynı kart, ikinci bir ekran yok.
 */
type Gorunum = 'gun' | 'hafta' | 'hekim' | 'cihaz';

interface Ayarlar {
  baslangicSaat: string;
  bitisSaat: string;
  slotDk: number;
  calismaGunleri: number[];   // 1 Pzt … 7 Paz
}

const VARSAYILAN: Ayarlar = {
  baslangicSaat: '09:00', bitisSaat: '18:00', slotDk: 15,
  calismaGunleri: [1, 2, 3, 4, 5, 6],
};

const GUN_ADI = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/** Takvimin bir sutunu: gunluk/haftalik gorunumde bir GUN, hekim gorunumunde
    bir HEKIM (o gunun icinde). */
interface Sutun {
  anahtar: string;
  baslik: string;
  gun: string;
  hekim?: number;
  /** CIHAZ gorunumunde (316) sutunun cihazi - radyoloji randevusu cihaza verilir. */
  cihaz?: number;
}

/** "09:00" -> 540 (dakika). */
const dk = (saat: string) => {
  const [s, d] = (saat || '0:0').split(':').map(Number);
  return (s || 0) * 60 + (d || 0);
};
const saatMetni = (toplam: number) =>
  `${String(Math.floor(toplam / 60)).padStart(2, '0')}:${String(toplam % 60).padStart(2, '0')}`;

const isoGun = (t: Date) => t.toISOString().slice(0, 10);
/** Pazartesi başlangıçlı hafta. */
function haftaBasi(t: Date) {
  const g = new Date(t);
  const fark = (g.getDay() + 6) % 7;
  g.setDate(g.getDate() - fark);
  return g;
}

export function RandevuTakvimi({ ayarlar, onYeni, onAc, onAralik, yenile,
                                 bolum, hekimId, hekimler = [], cihazlar = [],
                                 yanPanel, onBirak, onKapatmaIste }: {
  ayarlar?: Partial<Ayarlar>;
  /** Ust seritteki bolum/hekim suzgeci (251) - takvim de ayni secimi gosterir. */
  bolum?: number;
  hekimId?: number;
  /**
   * HEKIM GORUNUMU (kullanici: "hekim bazli sutunlu gorunum") icin sutun
   * kaynagi: secili bolumun hekimleri (bolum secili degilse tumu). Ust
   * seritteki suzgecle AYNI liste - iki yerde farkli kadro gorunmesin.
   */
  hekimler?: { id: number; ad: string }[];
  /**
   * CIHAZ GORUNUMU (316): radyolojide randevu hekime degil CIHAZA verilir -
   * sutunlar cihazlardir. Liste bos gelirse buton hic gorunmez (poliklinik
   * kurulumunda radyoloji cihazi yoktur).
   */
  cihazlar?: { id: number; ad: string }[];
  /** Boş hücre: o tarih-saatte yeni randevu (sütunun hekimi ya da cihazıyla). */
  onYeni(baslangic: string, hekimId?: number, cihazId?: number): void;
  /** Dolu randevu: kartı aç. */
  onAc(id: number): void;
  /**
   * Fareyle YUKARIDAN AŞAĞI sürüklenerek seçilen aralık (kullanıcı): başlangıç
   * ve süre "＋ Yeni"ye taşınır. Seçim tek başına kart AÇMAZ - kullanıcı önce
   * aralığı işaretler, sonra Yeni'ye basar.
   */
  onAralik?(baslangic: string | null, sureDk: number, hekimId?: number,
            cihazId?: number): void;
  /**
   * TAKVİMİN SOLUNDAKİ PANEL (316): radyolojide "randevu bekleyen istemler".
   * Takvim içeriğini bilmez - yalnız yer verir; sürüklenen yükü onBirak taşır.
   */
  yanPanel?: ReactNode;
  /**
   * Boş hücreye bırakma (316): dataTransfer'daki istem takvimin o saatine
   * randevulanır. Yalnız CİHAZ sütununda anlamlıdır (randevunun kaynağı cihaz).
   * Yük ham metin olarak geçer - takvim içeriğini çözmez, panelin işidir.
   */
  onBirak?(veri: string, baslangic: string, cihazId?: number): void;
  /**
   * CIHAZI KAPAT (318): takvimde isaretlenen aralik bakim/ariza/tatil olarak
   * kapatilir. Buton yalniz CIHAZ gorunumunde ve bir aralik secildiginde
   * etkindir - kapatma her zaman bir cihaza ve bir araliga aittir.
   */
  onKapatmaIste?(cihazId: number, baslangic: string, bitis: string): void;
  /** Dışarıdan tazeleme sayacı (kayıt sonrası). */
  yenile?: number;
}) {
  const ayar = { ...VARSAYILAN, ...ayarlar };
  const [gorunum, setGorunum] = useState<Gorunum>('gun');
  const [gun, setGun] = useState(() => isoGun(new Date()));
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  // Gorunume gore tarih araligi.
  const gunler = useMemo(() => {
    // Hekim gorunumu de TEK GUNluktur (sutunlar hekimlerdir) - haftalik dala
    //   dusunce veri araligi haftaya cikiyor ve secili gun calisma gunu
    //   degilse (Pazar) listeden tamamen eleniyordu.
    if (gorunum !== 'hafta') return [gun];
    const bas = haftaBasi(new Date(gun));
    return Array.from({ length: 7 }, (_, i) => {
      const t = new Date(bas);
      t.setDate(bas.getDate() + i);
      return isoGun(t);
    }).filter((_, i) => ayar.calismaGunleri.includes(i + 1));
  }, [gorunum, gun, ayar.calismaGunleri]);

  const yukle = useCallback(async () => {
    if (gunler.length === 0) return;
    setYukleniyor(true); setHata('');
    try {
      const y = await api.liste('randevu', {
        sayfa: 1, boyut: 500,
        sirala: [{ alan: 'baslangic', yon: 'asc' }],
        filtre: {
          op: 'and',
          kosullar: [
            { alan: 'tarih', op: 'arasinda', deger: [gunler[0], gunler[gunler.length - 1]] },
            { alan: 'durum', op: 'esitDegil', deger: 4 },
            ...(bolum ? [{ alan: 'bolum', op: 'esit' as const, deger: bolum }] : []),
            ...(hekimId ? [{ alan: 'hekimId', op: 'esit' as const, deger: hekimId }] : []),
          ],
        },
      });
      setSatirlar(y.satirlar);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [gunler, bolum, hekimId]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  /**
   * Bekleyen istem paneli açıkken takvim CİHAZ görünümüyle açılır: panelden
   * sürüklenen istem yalnız cihaz sütununa bırakılabilir, kullanıcıyı önce
   * görünüm değiştirmeye zorlamak gereksiz. Bir kez uygulanır - sonradan
   * kullanıcı başka görünüme geçerse orada kalır.
   */
  const ilkCihazGorunumu = useRef(false);
  useEffect(() => {
    if (!yanPanel || cihazlar.length === 0 || ilkCihazGorunumu.current) return;
    ilkCihazGorunumu.current = true;
    setGorunum('cihaz');
  }, [yanPanel, cihazlar.length]);

  // Saat dilimleri (slot).
  const slotlar = useMemo(() => {
    const bas = dk(ayar.baslangicSaat);
    const bit = dk(ayar.bitisSaat);
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    const liste: number[] = [];
    for (let t = bas; t < bit; t += adim) liste.push(t);
    return liste;
  }, [ayar.baslangicSaat, ayar.bitisSaat, ayar.slotDk]);

  /**
   * SUTUNLAR: gunluk/haftalik gorunumde GUN, hekim gorunumunde HEKIM. Hucre
   * mantigi ikisinde de ayni oldugu icin tek soyutlama - gun ve hekim suzgeci
   * sutunun kendisinde tasiniyor.
   */
  const sutunlar = useMemo<Sutun[]>(() => {
    if (gorunum === 'cihaz') {
      return cihazlar.map(c => ({ anahtar: `c${c.id}`, baslik: c.ad, gun, cihaz: c.id }));
    }
    if (gorunum === 'hekim') {
      const liste = hekimId ? hekimler.filter(h => h.id === hekimId) : hekimler;
      return liste.map(h => ({ anahtar: `h${h.id}`, baslik: h.ad, gun, hekim: h.id }));
    }
    return gunler.map(g => {
      const t = new Date(g);
      return {
        anahtar: g,
        baslik: `${GUN_ADI[(t.getDay() + 6) % 7]} ${g.slice(8, 10)}.${g.slice(5, 7)}`,
        gun: g,
        hekim: undefined,
      };
    });
  }, [gorunum, gunler, gun, hekimler, hekimId, cihazlar]);

  /**
   * KAPALI ARALIKLAR (318): cihazin bakim/ariza/tatil kapatmalari ve ogle
   * arasi. Kural veritabani tetiginde (316) - burada YALNIZ gorunurluk var;
   * kullanici bos gordugu saate randevu vermeye calisip hata almasin.
   */
  const [kapatmalar, setKapatmalar] = useState<
    { cihazId: number; bas: number; bit: number; gun: string; metin: string }[]>([]);

  const kapatmaYukle = useCallback(async () => {
    if (gunler.length === 0 || cihazlar.length === 0) { setKapatmalar([]); return }
    try {
      const y = await api.radyolojiCihazKapatma(
        `${gunler[0]}T00:00`, `${gunler[gunler.length - 1]}T23:59`);
      const liste: { cihazId: number; bas: number; bit: number; gun: string; metin: string }[] = [];
      y.kapatmalar.forEach(k => {
        const b = String(k.baslangic ?? ''), s = String(k.bitis ?? '');
        // Cok gunluk kapatma her gune ayri blok olarak dusurulur: takvim
        //   gun bazli cizer, aralik gunun disina tasarsa gun sinirina kirpilir.
        gunler.forEach(g => {
          if (b.slice(0, 10) > g || s.slice(0, 10) < g) return;
          liste.push({
            cihazId: Number(k.cihazId),
            bas: b.slice(0, 10) === g ? dk(b.slice(11, 16)) : 0,
            bit: s.slice(0, 10) === g ? dk(s.slice(11, 16)) : 24 * 60,
            gun: g,
            metin: String(k.aciklama ?? 'Kapalı'),
          });
        });
      });
      y.ogleArasi.forEach(c => {
        const b = String(c.ogleBaslangic ?? ''), s = String(c.ogleBitis ?? '');
        if (!b || !s) return;
        gunler.forEach(g => liste.push({
          cihazId: Number(c.id), bas: dk(b), bit: dk(s), gun: g, metin: 'Öğle arası',
        }));
      });
      setKapatmalar(liste);
    } catch { /* kapatma okunamazsa takvim eskisi gibi calisir */ }
  }, [gunler, cihazlar.length]);

  useEffect(() => { void kapatmaYukle() }, [kapatmaYukle, yenile]);

  /** Hucre kapali mi (318): sutunun cihazinda o slotu ortenkapatma. */
  const kapali = (sutun: Sutun, slot: number) => {
    if (sutun.cihaz === undefined) return undefined;
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    return kapatmalar.find(k => k.cihazId === sutun.cihaz && k.gun === sutun.gun
                                && k.bas < slot + adim && k.bit > slot);
  };

  /** sutun + slot -> o aralikta baslayan randevular. */
  const hucre = (sutun: Sutun, slot: number) => {
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    return satirlar.filter(r => {
      if (String(r.tarih ?? '').slice(0, 10) !== sutun.gun) return false;
      if (sutun.hekim !== undefined && Number(r.hekimId) !== sutun.hekim) return false;
      if (sutun.cihaz !== undefined && Number(r.cihazId) !== sutun.cihaz) return false;
      const b = dk(String(r.saat ?? ''));
      return b >= slot && b < slot + adim;
    });
  };

  /**
   * SÜRÜKLEYEREK ARALIK SEÇİMİ: mousedown başlatır, hücre üzerinden geçerken
   * genişler, mouseup bitirir. Tek hücrede bırakılırsa (sürükleme yok) eski
   * davranış korunur - o saate yeni randevu açılır.
   */
  const [secim, setSecim] = useState<
    { sutun: string; gun: string; hekim?: number; cihaz?: number; bas: number; bit: number } | null>(null);
  const [suruklu, setSuruklu] = useState(false);

  const araliktaMi = (s: Sutun, slot: number) =>
    !!secim && secim.sutun === s.anahtar
    && slot >= Math.min(secim.bas, secim.bit) && slot <= Math.max(secim.bas, secim.bit);

  const secimBasla = (s: Sutun, slot: number) => {
    setSecim({ sutun: s.anahtar, gun: s.gun, hekim: s.hekim, cihaz: s.cihaz, bas: slot, bit: slot });
    setSuruklu(true);
  };
  const secimGenislet = (s: Sutun, slot: number) => {
    if (!suruklu || !secim || secim.sutun !== s.anahtar) return;
    setSecim(o => (o ? { ...o, bit: slot } : o));
  };
  const secimBitir = (s: Sutun, slot: number) => {
    if (!suruklu) return;
    setSuruklu(false);
    const bas = secim ? Math.min(secim.bas, slot) : slot;
    const bit = secim ? Math.max(secim.bit, slot) : slot;
    const adim = Math.max(5, Number(ayar.slotDk) || 15);
    if (bas === bit) {
      // Tek hücre = tiklama: eskisi gibi o saate yeni randevu. Hekim
      //   gorunumunde SUTUNUN hekimi de forma tasinir.
      setSecim(null);
      onAralik?.(null, 0);
      if (hucre(s, bas).length === 0) onYeni(`${s.gun}T${saatMetni(bas)}`, s.hekim, s.cihaz);
      return;
    }
    // Son slot da dahil: 09:00-09:30 isaretlenirse sure 45 dk degil 45'tir
    //   (bitis slotunun kendisi de secili sayilir).
    onAralik?.(`${s.gun}T${saatMetni(bas)}`, bit - bas + adim, s.hekim, s.cihaz);
  };

  /**
   * SÜRÜKLE-BIRAK HEDEFİ (316): panelden gelen istem yalnız BOŞ hücreye ve
   * yalnız cihaz sütununa bırakılabilir - poliklinik sütununda cihaz yoktur,
   * randevunun kaynağı belirsiz kalırdı.
   */
  const [birakHedefi, setBirakHedefi] = useState<string | null>(null);
  const birakilabilir = (s: Sutun, slot: number) =>
    !!onBirak && s.cihaz !== undefined && hucre(s, slot).length === 0
    && !kapali(s, slot);

  const kaydir = (yon: number) => {
    const t = new Date(gun);
    t.setDate(t.getDate() + (gorunum === 'gun' ? yon : yon * 7));
    setGun(isoGun(t));
  };

  return (
    // Gridin ALTINDA ayri katman: ust bosluk olmadan liste seridine (Tüm/Son/
    //   Sık dugmeleri) yapisip onlari kirpiyordu (kullanici).
    <div className="kagrup" style={{ marginTop: 16 }}>
      <div className="numaralama-bas bitisik">
        <h6>Takvim</h6>
        <button type="button" className={`cip${gorunum === 'gun' ? ' on' : ''}`}
                onClick={() => setGorunum('gun')}>Günlük</button>
        <button type="button" className={`cip${gorunum === 'hafta' ? ' on' : ''}`}
                onClick={() => setGorunum('hafta')}>Haftalık</button>
        {/* Hekim gorunumu: secili GUN icin sutunlar hekimlerdir (kullanici). */}
        <button type="button" className={`cip${gorunum === 'hekim' ? ' on' : ''}`}
                onClick={() => setGorunum('hekim')}>Hekim</button>
        {/* CIHAZ gorunumu yalniz cihaz tanimliysa (316) - poliklinik
            kurulumunda bu buton hic cikmaz. */}
        {cihazlar.length > 0 && (
          <button type="button" className={`cip${gorunum === 'cihaz' ? ' on' : ''}`}
                  onClick={() => setGorunum('cihaz')}>Cihaz</button>
        )}
        <button type="button" className="d" onClick={() => kaydir(-1)}>‹</button>
        <input type="date" value={gun} onChange={e => setGun(e.target.value)} />
        <button type="button" className="d" onClick={() => kaydir(1)}>›</button>
        <button type="button" className="d" onClick={() => setGun(isoGun(new Date()))}>
          Bugün
        </button>
        {/* CIHAZI KAPAT (318): once aralik isaretlenir, sonra buton. */}
        {onKapatmaIste && gorunum === 'cihaz' && (
          <button type="button" className="d"
                  disabled={!secim || secim.cihaz === undefined || secim.bas === secim.bit}
                  title={secim && secim.cihaz !== undefined && secim.bas !== secim.bit
                         ? 'İşaretli aralığı bakım/arıza/tatil olarak kapat'
                         : 'Önce cihaz sütununda bir saat aralığı işaretleyin'}
                  onClick={() => {
                    if (!secim || secim.cihaz === undefined) return;
                    const adim = Math.max(5, Number(ayar.slotDk) || 15);
                    const bas = Math.min(secim.bas, secim.bit);
                    const bit = Math.max(secim.bas, secim.bit) + adim;
                    onKapatmaIste(secim.cihaz, `${secim.gun}T${saatMetni(bas)}`,
                                  `${secim.gun}T${saatMetni(bit)}`);
                  }}>🔒 Cihazı Kapat</button>
        )}
        {yukleniyor && <span style={{ fontSize: 11, opacity: .7 }}>Yükleniyor…</span>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className={yanPanel ? 'takvim-duzen' : undefined}>
      {yanPanel && (
        <div className="takvim-yan">
          {gorunum !== 'cihaz' && cihazlar.length > 0 && (
            // Panelden sürüklenen istem yalnız cihaz sütununa düşer - başka
            //   görünümdeyken kullanıcı boşuna uğraşmasın.
            <div className="takvim-yan-uyari">
              Bırakmak için cihaz görünümü gerekir.
              <button type="button" className="d" onClick={() => setGorunum('cihaz')}>
                Cihaz görünümü
              </button>
            </div>
          )}
          {yanPanel}
        </div>
      )}

      <div style={{ overflowX: 'auto', flex: 1, minWidth: 0 }}>
        <table className="grid randevu-takvim">
          <thead>
            <tr>
              <th style={{ width: 64 }}>Saat</th>
              {sutunlar.map(s => (
                <th key={s.anahtar} style={{ textAlign: 'center' }}>{s.baslik}</th>
              ))}
              {sutunlar.length === 0 && (
                <th style={{ textAlign: 'center', fontWeight: 400, opacity: .7 }}>
                  Bu bölümde randevu verilebilir personel yok
                </th>
              )}
            </tr>
          </thead>
          <tbody>
            {slotlar.map(slot => (
              <tr key={slot}>
                <td style={{ textAlign: 'center', opacity: .75 }}>{saatMetni(slot)}</td>
                {sutunlar.map(sut => {
                  const kayitlar = hucre(sut, slot);
                  const secili = araliktaMi(sut, slot);
                  const hedef = birakHedefi === sut.anahtar + slot;
                  const kapaliBlok = kapali(sut, slot);
                  // Blogun ILK sluttunda metin yazilir, devaminda bos tarama:
                  //   her satirda "Bakım" tekrar etmesi takvimi okunmaz yapardi.
                  const kapatmaBasi = kapaliBlok
                    && kapaliBlok.bas >= slot
                    && kapaliBlok.bas < slot + Math.max(5, Number(ayar.slotDk) || 15);
                  return (
                    <td key={sut.anahtar + slot}
                        className={hedef ? 'birak-hedef' : undefined}
                        style={{ cursor: 'pointer', verticalAlign: 'top',
                                 background: secili ? 'var(--sec, var(--mor2))' : undefined,
                                 userSelect: 'none' }}
                        onMouseDown={() => kayitlar.length === 0 && !kapaliBlok
                                           && secimBasla(sut, slot)}
                        onMouseEnter={() => secimGenislet(sut, slot)}
                        onMouseUp={() => secimBitir(sut, slot)}
                        onDragOver={e => {
                          if (!birakilabilir(sut, slot)) return;
                          e.preventDefault();
                          e.dataTransfer.dropEffect = 'move';
                          setBirakHedefi(sut.anahtar + slot);
                        }}
                        onDragLeave={() => setBirakHedefi(o => (hedef ? null : o))}
                        onDrop={e => {
                          setBirakHedefi(null);
                          if (!birakilabilir(sut, slot)) return;
                          const veri = e.dataTransfer.getData('application/x-radyoloji-istem');
                          if (!veri) return;
                          e.preventDefault();
                          onBirak?.(veri, `${sut.gun}T${saatMetni(slot)}`, sut.cihaz);
                        }}>
                      {kapaliBlok && (
                        <div className="takvim-kapali" title={kapaliBlok.metin}>
                          {kapatmaBasi && <span>🔒 {kapaliBlok.metin}</span>}
                        </div>
                      )}
                      {kayitlar.map(r => (
                        <div key={String(r.id)}
                             onClick={e => { e.stopPropagation(); onAc(Number(r.id)) }}
                             title={`${String(r.hekim ?? '')} · ${String(r.bolumAdi ?? '')}`}
                             style={{
                               background: Number(r.durum) === 2 ? 'var(--okzem)'
                                          : Number(r.durum) === 3 ? 'var(--hatazem)'
                                          : 'var(--yuz2)',
                               border: '1px solid var(--cizgi)', borderRadius: 4,
                               padding: '2px 6px', marginBottom: 2, fontSize: 11.5,
                             }}>
                          <b>{String(r.hasta ?? '')}</b>
                          <div style={{ opacity: .75 }}>
                            {String(r.saat ?? '')}–{String(r.bitis ?? '')} · {String(r.hekim ?? '')}
                          </div>
                        </div>
                      ))}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      </div>
    </div>
  );
}
