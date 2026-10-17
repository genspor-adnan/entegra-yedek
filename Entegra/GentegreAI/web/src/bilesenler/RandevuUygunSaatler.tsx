import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { type CalismaBlok, type RandevuBolumDugumu, hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';

/**
 * UYGUN SAATLER ŞERİDİ (Ekranlar/randevu_karti.html): seçili hekim ve tarih
 * için o günün slotları. Dolu saatler çizili ve tıklanamaz, seçili saat
 * maviyle işaretli; boş bir saate tıklamak kartın başlangıcını oraya taşır.
 *
 * SAAT DÜZENİ ÇALIŞMA PLANINDAN (kullanıcı: "çalışma planları varken randevu
 * ayarlarına gerek kaldı mı"): doktorun o günkü blokları ve blokların slot
 * süresi; öğle arası iki blok arasındaki boşluktur, izinli / kapalı gün
 * sebebiyle yazılır. Doktorun HİÇ planı yoksa eski miras zinciri (251):
 * hekimin kendi ayarı → bölümün ayarı → Genel Ayarlar. Kartın kendi süresi slot adımını değiştirmez; süre
 * yalnız DOLULUK hesabında kullanılır (20 dk'lık randevu iki 15 dk'lık slotu
 * kapatır).
 *
 * CİHAZ SEÇİLİYSE (kullanıcı 16.10.2026: "randevu kartı açarken cihaz seçiliydi.. onun saatleri
 * gelmeli"): kaynak cihazdır - saatler cihazın mesaisi / öğlesi / slotu ve çalışma günlerinden,
 * doluluk o cihazın randevularından; cihaz kapatmaları (bakım / arıza) kapalı, eşzaman kadar
 * randevu aynı slota sığar. Hekim planı bakılmaz.
 */
interface Ayar {
  baslangicSaat: string;
  bitisSaat: string;
  ogleBaslangic: string;
  ogleBitis: string;
  slotDk: number;
}

const VARSAYILAN: Ayar = {
  baslangicSaat: '09:00', bitisSaat: '18:00',
  ogleBaslangic: '', ogleBitis: '', slotDk: 15,
};

const dk = (saat: string) => {
  const [s, d] = (saat || '').split(':').map(Number);
  return Number.isFinite(s) ? (s || 0) * 60 + (d || 0) : NaN;
};
const saatMetni = (t: number) =>
  `${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}`;

export function RandevuUygunSaatler({ hekimId, hekimAdi, cihazId = null, cihazAdi, bolum, tarih, sureDk, seciliSaat,
                                      hariçId, saltOkunur, onSec }: {
  hekimId: number | null;
  /** Randevunun cihazı - doluysa saatler hekimden değil cihazdan. */
  cihazId?: number | null;
  cihazAdi?: string;
  /** Baslikta gosterilir (mockup: "Uygun Saatler — 02.09.2026 · Uzm. Dr. ..."). */
  hekimAdi?: string;
  bolum: number | null;
  /** yyyy-mm-dd */
  tarih: string;
  sureDk: number;
  /** HH:mm - kartta seçili saat. */
  seciliSaat: string;
  /** Düzenlenen randevu (kendi saatini "dolu" saymamak için). */
  hariçId?: number | null;
  /** Salt okunur kart (ör. randevuyu yalnız GÖREN uzman doktor): seçim değişmez. */
  saltOkunur?: boolean;
  /**
   * Seçim ARALIKTIR (kullanıcı: "takvimde işaretlediklerim gelmeli, artırıp
   * azaltabilmeli ya da işaretleri kaldırıp başka saatlerden işaretleyebilmeliyim"):
   * başlangıç + süre birlikte döner.
   */
  onSec(saat: string, sureDk: number): void;
}) {
  const [dolu, setDolu] = useState<{ bas: number; bit: number }[]>([]);
  const [agac, setAgac] = useState<RandevuBolumDugumu[]>([]);
  const [genel, setGenel] = useState<Ayar>(VARSAYILAN);
  const [hata, setHata] = useState('');
  /** Doktorun o gunku plan bloklari; planli=false ise ayarlar kullanilir. */
  const [plan, setPlan] = useState<{ planli: boolean; bloklar: CalismaBlok[] } | null>(null);
  /** Cihaz modu: cihazın randevu ayarı + o günün kapatmaları. */
  const [cihaz, setCihaz] = useState<{ ayar: Ayar & { eszaman: number; gunler: number[]; randevuVerilir: boolean };
                                       kapatma: { bas: number; bit: number; metin: string }[] } | null>(null);
  useEffect(() => {
    if (!cihazId || !tarih) { setCihaz(null); return }
    let iptal = false;
    void (async () => {
      try {
        const [a, k] = await Promise.all([
          api.radyolojiCihazRandevuAyar(cihazId),
          api.radyolojiCihazKapatma(`${tarih}T00:00`, `${tarih}T23:59`).catch(() => ({ kapatmalar: [], ogleArasi: [] })),
        ]);
        if (iptal) return;
        const x = a.cihaz;
        setCihaz({
          ayar: {
            baslangicSaat: x.baslangicSaat, bitisSaat: x.bitisSaat,
            ogleBaslangic: x.ogleBaslangic, ogleBitis: x.ogleBitis, slotDk: Number(x.slotDk) || 15,
            eszaman: Math.max(1, Number(x.eszaman) || 1), randevuVerilir: Number(x.randevuVerilir) === 1,
            gunler: x.calismaGunleri.split(',').map(g => Number(g.trim())).filter(g => g >= 1 && g <= 7),
          },
          // Cok gunluk kapatma gun sinirina kirpilir (takvimdeki gibi).
          kapatma: k.kapatmalar.filter(r => Number(r.cihazId) === cihazId).map(r => {
            const b = String(r.baslangic ?? ''), s = String(r.bitis ?? '');
            return { bas: b.slice(0, 10) === tarih ? dk(b.slice(11, 16)) : 0,
                     bit: s.slice(0, 10) === tarih ? dk(s.slice(11, 16)) : 24 * 60,
                     metin: String(r.aciklama ?? c('Kapalı')) };
          }),
        });
      } catch (h) { if (!iptal) { setCihaz(null); setHata(hataMetni(h)) } }
    })();
    return () => { iptal = true };
  }, [cihazId, tarih]);
  /** Cihaz o gün çalışıyor mu (1 Pzt … 7 Paz; gün listesi boşsa her gün). */
  const cihazGunu = (() => {
    if (!cihaz || !tarih) return true;
    const g = new Date(`${tarih}T12:00`).getDay();
    return cihaz.ayar.gunler.length === 0 || cihaz.ayar.gunler.includes(g === 0 ? 7 : g);
  })();

  useEffect(() => {
    if (!hekimId || !tarih || cihazId) { setPlan(null); return }
    let iptal = false;
    api.calismaPlani({ bas: tarih, bit: tarih, hekimId })
      .then(y => { if (!iptal) setPlan({ planli: y.hekimler.some(h => h.id === hekimId)
                                                 || y.bloklar.length > 0,
                                         bloklar: y.bloklar.filter(b => b.hekimId === hekimId) }) })
      .catch(() => { if (!iptal) setPlan(null) /* plan okunamazsa ayarlar */ });
    return () => { iptal = true };
  }, [hekimId, tarih, cihazId]);
  const planli = !cihazId && !!plan?.planli;
  const calisma = (plan?.bloklar ?? []).filter(b => b.saatBas && b.saatBit);
  const kapaliGun = planli && calisma.length === 0
    ? (plan?.bloklar ?? []).find(b => b.kaynak === 3 || b.kaynak === 4) : undefined;

  // Genel ayarlar + bölüm/hekim düzeni: kart açıkken bir kez.
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const [ayarlar, dugumler] = await Promise.all([
          api.ayarlar(), api.randevuBolumleri(),
        ]);
        if (iptal) return;
        const bul = (a: string) => ayarlar.find(x => x.anahtar === a)?.deger ?? '';
        setGenel({
          baslangicSaat: bul('randevu.baslangic_saat') || VARSAYILAN.baslangicSaat,
          bitisSaat: bul('randevu.bitis_saat') || VARSAYILAN.bitisSaat,
          ogleBaslangic: bul('randevu.ogle_baslangic'),
          ogleBitis: bul('randevu.ogle_bitis'),
          slotDk: Number(bul('randevu.slot_dk')) || VARSAYILAN.slotDk,
        });
        setAgac(dugumler);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, []);

  /** Hekim → bölüm → genel: ilk dolu değer kazanır. */
  const ayar = useMemo<Ayar>(() => {
    if (cihaz) return cihaz.ayar;
    const bolumDugum = agac.find(d => d.departmanId === bolum)
      ?? agac.find(d => d.hekimler.some(h => h.hekimId === hekimId));
    const hekimAyar = bolumDugum?.hekimler.find(h => h.hekimId === hekimId);
    const ilk = (...a: (string | number | null | undefined)[]) =>
      a.find(v => v !== '' && v !== null && v !== undefined);
    return {
      baslangicSaat: String(ilk(hekimAyar?.baslangicSaat, bolumDugum?.ayar.baslangicSaat,
                                genel.baslangicSaat)),
      bitisSaat: String(ilk(hekimAyar?.bitisSaat, bolumDugum?.ayar.bitisSaat, genel.bitisSaat)),
      ogleBaslangic: String(ilk(hekimAyar?.ogleBaslangic, bolumDugum?.ayar.ogleBaslangic,
                                genel.ogleBaslangic) ?? ''),
      ogleBitis: String(ilk(hekimAyar?.ogleBitis, bolumDugum?.ayar.ogleBitis,
                            genel.ogleBitis) ?? ''),
      slotDk: Number(ilk(hekimAyar?.slotDk, bolumDugum?.ayar.slotDk, genel.slotDk)) || 15,
    };
  }, [agac, bolum, hekimId, genel, cihaz]);

  // O hekimin o günkü randevuları (iptaller hariç).
  const yukle = useCallback(async () => {
    if ((!hekimId && !cihazId) || !tarih) { setDolu([]); return }
    try {
      const y = await api.liste('randevu', {
        sayfa: 1, boyut: 200,
        filtre: {
          op: 'and',
          kosullar: [
            // Cihaz seçiliyse doluluk CİHAZIN randevuları (hekimden bağımsız).
            cihazId ? { alan: 'cihazId', op: 'esit', deger: cihazId } : { alan: 'hekimId', op: 'esit', deger: hekimId },
            { alan: 'tarih', op: 'esit', deger: tarih },
            { alan: 'durum', op: 'esitDegil', deger: 4 },
          ],
        },
      });
      setDolu(y.satirlar
        .filter(r => !hariçId || Number(r.id) !== hariçId)
        .map(r => {
          const bas = dk(String(r.saat ?? ''));
          return { bas, bit: bas + (Number(r.sureDk) || 0) };
        })
        .filter(x => Number.isFinite(x.bas)));
    } catch (h) { setHata(hataMetni(h)) }
  }, [hekimId, cihazId, tarih, hariçId]);

  useEffect(() => { void yukle() }, [yukle]);

  const slotlar = useMemo(() => {
    if (planli) {
      // Her blok kendi slot suresiyle; bloklar arasi bosluk = ogle / ara.
      const liste: number[] = [];
      calisma.forEach(b => {
        const adim = Math.max(5, Number(b.slotDk) || ayar.slotDk);
        for (let t = dk(String(b.saatBas)); t < dk(String(b.saatBit)); t += adim) liste.push(t);
      });
      return [...new Set(liste)].sort((a, b) => a - b);
    }
    const bas = dk(ayar.baslangicSaat);
    const bit = dk(ayar.bitisSaat);
    if (!Number.isFinite(bas) || !Number.isFinite(bit)) return [];
    if (cihaz && (!cihazGunu || !cihaz.ayar.randevuVerilir)) return [];
    const liste: number[] = [];
    for (let t = bas; t < bit; t += ayar.slotDk) liste.push(t);
    return liste;
  }, [ayar, planli, calisma, cihaz, cihazGunu]);

  const secili = dk(seciliSaat);
  /** Slotun kendi adımı (planlı doktorda bloğun slotu). */
  const adimOf = (t: number) => {
    if (planli) {
      const b = calisma.find(x => t >= dk(String(x.saatBas)) && t < dk(String(x.saatBit)));
      if (b) return Math.max(5, Number(b.slotDk) || ayar.slotDk);
    }
    return Math.max(5, ayar.slotDk);
  };
  const sure = Number(sureDk) || adimOf(secili);
  const seciliBit = Number.isFinite(secili) ? secili + sure : NaN;
  const seciliMi = (t: number) => Number.isFinite(secili) && t >= secili && t < seciliBit;
  const ogleBas = dk(ayar.ogleBaslangic);
  const ogleBit = dk(ayar.ogleBitis);

  /**
   * Slot KENDİ adımı boyunca dolu bir randevuyla ya da öğle arasıyla çakışıyor mu.
   * (Eskiden randevunun tüm süresine bakılıyordu; seçim artık slot slot
   * genişlediği için her slot kendi başına değerlendirilir.)
   */
  const kapali = (t: number) => {
    const son = t + adimOf(t);
    // Plan: randevu suresi blogun disina tasiyorsa kapali (ogle = bloklar arasi).
    if (planli) {
      if (!calisma.some(b => t >= dk(String(b.saatBas)) && son <= dk(String(b.saatBit)))) return true;
    } else if (Number.isFinite(ogleBas) && Number.isFinite(ogleBit)
        && t < ogleBit && son > ogleBas) return true;
    if (cihaz) {
      if (cihaz.kapatma.some(k => t < k.bit && son > k.bas)) return true;
      // EŞZAMAN: cihaz aynı anda N hasta alıyorsa slot N randevuya kadar açık.
      return dolu.filter(d => t < d.bit && son > d.bas).length >= cihaz.ayar.eszaman;
    }
    return dolu.some(d => t < d.bit && son > d.bas);
  };

  /** Aralıktaki her slot boş mu (genişletirken dolu slotun üzerinden geçilmez). */
  const araBos = (bas: number, bit: number) => slotlar.filter(t => t >= bas && t < bit).every(t => !kapali(t) || seciliMi(t))
    && slotlar.some(t => t === bas);

  const tikla = (t: number, shift: boolean) => {
    const a = adimOf(t);
    if (!Number.isFinite(secili)) { onSec(saatMetni(t), a); return }
    if (seciliMi(t)) {
      // UÇTAN KISALT: tek slot kaldıysa seçim durur (randevunun saati zorunlu).
      if (t === secili && t + a < seciliBit) onSec(saatMetni(t + a), seciliBit - (t + a));
      else if (t + a >= seciliBit && t > secili) onSec(saatMetni(secili), t - secili);
      return;
    }
    if (kapali(t)) return;
    // SHIFT: seçimden tıklanan slota kadar (arada dolu yoksa).
    if (shift) {
      const bas = Math.min(secili, t), bit = Math.max(seciliBit, t + a);
      if (araBos(bas, bit)) { onSec(saatMetni(bas), bit - bas); return }
    }
    if (t === seciliBit) { onSec(saatMetni(secili), sure + a); return }       // sona ekle
    if (t + a === secili) { onSec(saatMetni(t), sure + a); return }            // başa ekle
    onSec(saatMetni(t), a);                                                     // yeniden seç
  };

  if (!hekimId && !cihazId) {
    return (
      <div className="kagrup" style={{ marginTop: 12 }}>
        <div className="numaralama-bas bitisik"><h6>{c('Uygun Saatler')}</h6></div>
        <div style={{ padding: '8px 12px', fontSize: 11.5, opacity: .7 }}>
          Hekim seçilince o günün uygun saatleri listelenir.
        </div>
      </div>
    );
  }

  return (
    <div className="kagrup" style={{ marginTop: 12 }}>
      <div className="numaralama-bas bitisik">
        <h6>
          Uygun Saatler — {tarih.split('-').reverse().join('.')}
          {cihazId ? (cihazAdi ? ` · ${cihazAdi}` : '') : hekimAdi ? ` · ${hekimAdi}` : ''}
        </h6>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="saat-serit">
        {slotlar.map(t => {
          const dolulukVar = kapali(t);
          const bu = seciliMi(t);
          return (
            <button key={t} type="button"
                    className={`saat${dolulukVar ? ' dolu' : ''}${bu ? ' secili' : ''}`}
                    disabled={saltOkunur || (dolulukVar && !bu)}
                    title={bu ? c('Uçtaki slota tıkla: kısalt') : c('Seçimin yanına tıkla: uzat · başka saate tıkla: yeniden seç · Shift+tık: oraya kadar genişlet')}
                    onClick={e => tikla(t, e.shiftKey)}>
              {saatMetni(t)}
            </button>
          );
        })}
        {slotlar.length === 0 && (
          <span style={{ fontSize: 11.5, opacity: .7 }}>
            {cihaz ? (!cihaz.ayar.randevuVerilir ? c('Bu cihaza randevu verilmiyor.')
                      : !cihazGunu ? c('Cihaz bu gün çalışmıyor.') : c('Bu cihaz için mesai saati tanımlı değil.'))
             : kapaliGun ? `${kapaliGun.aciklama || (kapaliGun.kaynak === 4 ? c('İzinli') : c('Kapalı'))} — ${c('bu gün randevu verilemez.')}`
             : planli ? c('Doktorun bu gün çalışma planı yok.')
             : c('Bu doktor için çalışma saati tanımlı değil.')}
          </span>
        )}
      </div>
      <div style={{ padding: '2px 12px 8px', fontSize: 11, opacity: .7 }}>
        {Number.isFinite(secili)
          ? <>{c('Seçili')}: <b>{saatMetni(secili)}–{saatMetni(seciliBit)}</b> ({sure} dk) · </>
          : null}
        {c('Dolu saatler üzeri çizili. Seçimin yanındaki slota tıkla: uzat · uçtaki seçili slota tıkla: kısalt · başka saate tıkla: yeniden seç · Shift+tık: oraya kadar genişlet.')}
      </div>
    </div>
  );
}
