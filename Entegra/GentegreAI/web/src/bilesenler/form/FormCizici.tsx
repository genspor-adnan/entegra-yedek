import type { ReactNode } from 'react';
import type { FormAlan, FormBolum, FormCevap, FormTanimi } from '../../api/uclar/form';

/**
 * FORM ÇİZİCİ (form motoru 740): jsonb tanımı ekrana çizer, değerleri
 * `cevap` sözlüğünde tutar. Aynı bileşen üç yerde: hastanın telefonu (açık
 * sayfa, yalnız hasta bölümleri), iç ekran / tablet (tüm bölümler, sahip
 * rozetiyle) ve şablon editörü önizlemesi. İş kuralı yazmaz: zorunluluk,
 * koşul ve skor tanımdan gelir; skor sunucuda da hesaplanır (gösterim burada).
 */
export const SAHIP_ADI: Record<string, string> = {
  hasta: 'Hasta', calisan: 'Çalışan', hekim: 'Hekim', hemsire: 'Hemşire', anestezi: 'Anestezi', cerrah: 'Cerrah',
};

/** Metin bloklarındaki {hasta.ad} {islem} gibi yer tutucular: parametre → cevap → boş. */
export function metinDoldur(metin: string, parametreler: Record<string, string>, cevap: FormCevap): string {
  return metin.replace(/\{([\w.]+)\}/g, (_, k: string) => {
    const p = parametreler[k]; if (p !== undefined && p !== '') return p;
    const c = cevap[k]; if (c === undefined || c === null || c === '') return '…';
    return Array.isArray(c) ? c.join(', ') : String(c);
  });
}

/** Koşullu alan: `kosul.alan` değeri `kosul.deger`e eşitse (dizi ise içeriyorsa) görünür. */
export function alanGorunur(a: FormAlan, cevap: FormCevap): boolean {
  if (!a.kosul) return true;
  const v = cevap[a.kosul.alan];
  if (Array.isArray(v)) return v.includes(a.kosul.deger);
  if (a.kosul.deger === true) return v === true || v === 'Evet' || (v !== undefined && v !== '' && v !== false);
  return v === a.kosul.deger;
}

/** Skor: skor tablosu satır puanları toplamı; `hesap.kaynak` verilmişse o ölçek; ortalama ise ölçeklerin ortalaması. */
export function skorHesapla(tanim: FormTanimi, cevap: FormCevap): { skor: number | null; esik?: { ad: string; renk?: string; gorev?: string } } {
  let toplam = 0; let var_ = false; const olcekler: number[] = [];
  for (const b of tanim.bolumler ?? []) for (const a of b.alanlar ?? []) {
    if (a.tip === 'skor') {
      const sec = (cevap[a.kod] ?? {}) as Record<string, number>;
      for (const s of a.satirlar ?? []) { const i = sec[s.kod]; const p = typeof i === 'number' ? s.secenek[i]?.puan : undefined; if (typeof p === 'number') { toplam += p; var_ = true } }
    } else if (a.tip === 'olcek') {
      const v = Number(cevap[a.kod]); if (!Number.isNaN(v) && cevap[a.kod] !== undefined && cevap[a.kod] !== '') { olcekler.push(v); if (tanim.hesap?.kaynak === a.kod) { toplam = v; var_ = true } }
    }
  }
  if (!var_ && tanim.hesap?.ortalama && olcekler.length) { toplam = Math.round(olcekler.reduce((x, y) => x + y, 0) / olcekler.length * 100) / 100; var_ = true }
  if (!var_) return { skor: null };
  const esik = tanim.hesap?.esikler?.find(e => toplam >= e.min && toplam <= e.max);
  return { skor: toplam, esik };
}

export function zorunluEksikler(bolumler: FormBolum[], cevap: FormCevap): string[] {
  const eksik: string[] = [];
  for (const b of bolumler) for (const a of b.alanlar ?? []) {
    if (!a.zorunlu || !alanGorunur(a, cevap) || a.tip === 'metinblok') continue;
    const v = cevap[a.kod];
    const bos = v === undefined || v === null || v === '' || v === false || (Array.isArray(v) && v.length === 0)
      || (a.tip === 'skor' && Object.keys((v as object) ?? {}).length < (a.satirlar?.length ?? 0));
    if (bos) eksik.push(a.etiket ?? a.kod);
  }
  return eksik;
}

export function FormCizici({ bolumler, cevap, onChange, salt, parametreler = {}, sahipRozeti, buyuk, tanim }: {
  bolumler: FormBolum[]; cevap: FormCevap; onChange: (kod: string, deger: unknown) => void;
  salt?: boolean | ((b: FormBolum) => boolean); parametreler?: Record<string, string>;
  sahipRozeti?: boolean; buyuk?: boolean; tanim?: FormTanimi;
}) {
  const saltMi = (b: FormBolum) => typeof salt === 'function' ? salt(b) : !!salt;
  const hesap = tanim ? skorHesapla(tanim, cevap) : null;
  return (
    <div className={`fm-cizici${buyuk ? ' fm-buyuk' : ''}`}>
      {bolumler.map(b => (
        <section key={b.kod} className={`fm-bolum${saltMi(b) ? ' fm-bolum-salt' : ''}`}>
          <h3 className="fm-bolum-bas">
            {b.ad}
            {sahipRozeti && <span className={`rozet fm-sahip-${b.sahip}`}>{SAHIP_ADI[b.sahip] ?? b.sahip}</span>}
            {saltMi(b) && <span className="sonuk fm-salt-not">salt okunur</span>}
          </h3>
          {(b.alanlar ?? []).filter(a => alanGorunur(a, cevap)).map(a => (
            <Alan key={a.kod} a={a} cevap={cevap} salt={saltMi(b)} parametreler={parametreler} onChange={onChange} />
          ))}
        </section>
      ))}
      {hesap && hesap.skor !== null && (
        <div className={`fm-skor fm-skor-${hesap.esik?.renk ?? 'gri'}`}>
          Toplam <b>{hesap.skor}</b>
          {hesap.esik && <span className={`rozet ${rozetSinifi(hesap.esik.renk)}`}>{hesap.esik.ad}</span>}
          {hesap.esik?.gorev && <span className="sonuk"> · öneri: {hesap.esik.gorev}</span>}
        </div>
      )}
    </div>
  );
}

export function rozetSinifi(renk?: string): string {
  return renk === 'kir' ? 'hata' : renk === 'sari' ? 'uyari' : renk === 'ok' ? 'ok' : 'mor';
}

function Alan({ a, cevap, salt, parametreler, onChange }: {
  a: FormAlan; cevap: FormCevap; salt: boolean; parametreler: Record<string, string>; onChange: (kod: string, deger: unknown) => void;
}) {
  const v = cevap[a.kod];
  const etiket = (a.etiket ?? a.kod) + (a.zorunlu ? ' *' : '');
  const sar = (icerik: ReactNode, genis?: boolean) => (
    <div className={`fm-alan fm-tip-${a.tip}${genis ? ' fm-genis' : ''}`}>
      {a.tip !== 'onay' && a.tip !== 'metinblok' && <label className="fm-etiket">{etiket}</label>}
      {icerik}
      {a.yardim && <div className="sonuk fm-yardim">{a.yardim}</div>}
    </div>
  );
  switch (a.tip) {
    case 'metinblok':
      return <div className="fm-metinblok">{metinDoldur(a.metin ?? '', parametreler, cevap)}</div>;
    case 'metin':
      return sar(<input className="fm-giris" value={(v as string) ?? ''} disabled={salt} onChange={e => onChange(a.kod, e.target.value)} />);
    case 'uzunmetin':
      return sar(<textarea className="fm-giris" rows={3} value={(v as string) ?? ''} disabled={salt} onChange={e => onChange(a.kod, e.target.value)} />, true);
    case 'sayi':
      return sar(<input className="fm-giris" type="number" value={(v as string) ?? ''} disabled={salt} onChange={e => onChange(a.kod, e.target.value === '' ? '' : Number(e.target.value))} />);
    case 'tarih':
      return sar(<input className="fm-giris" type="date" value={(v as string) ?? ''} disabled={salt} onChange={e => onChange(a.kod, e.target.value)} />);
    case 'secim':
      return sar(
        <div className="fm-cipler">
          {(a.secenek ?? []).map(s => (
            <button key={s} type="button" className={`fm-cip${v === s ? ' on' : ''}`} disabled={salt} onClick={() => onChange(a.kod, v === s ? '' : s)}>{s}</button>
          ))}
        </div>, true);
    case 'coklu': {
      const dizi = Array.isArray(v) ? (v as string[]) : [];
      return sar(
        <div className="fm-cipler">
          {(a.secenek ?? []).map(s => (
            <button key={s} type="button" className={`fm-cip${dizi.includes(s) ? ' on' : ''}`} disabled={salt}
                    onClick={() => onChange(a.kod, dizi.includes(s) ? dizi.filter(x => x !== s) : [...dizi, s])}>{s}</button>
          ))}
        </div>, true);
    }
    case 'evethayir': {
      const evet = v === true || v === 'Evet'; const hayir = v === false || v === 'Hayır';
      const acik = (cevap[`${a.kod}_aciklama`] as string) ?? '';
      return sar(
        <div className="fm-eh-sar">
          <div className="fm-eh">
            <button type="button" className={`fm-cip fm-cip-evet${evet ? ' on' : ''}`} disabled={salt} onClick={() => onChange(a.kod, evet ? '' : true)}>Evet</button>
            <button type="button" className={`fm-cip fm-cip-hayir${hayir ? ' on' : ''}`} disabled={salt} onClick={() => onChange(a.kod, hayir ? '' : false)}>Hayır</button>
          </div>
          {a.aciklamaEvetse && evet && (
            <input className="fm-giris" placeholder="Açıklama" value={acik} disabled={salt} onChange={e => onChange(`${a.kod}_aciklama`, e.target.value)} />
          )}
        </div>, true);
    }
    case 'onay':
      return (
        <label className={`fm-alan fm-onay${v === true ? ' on' : ''}`}>
          <input type="checkbox" checked={v === true} disabled={salt} onChange={e => onChange(a.kod, e.target.checked)} />
          <span>{etiket}</span>
        </label>
      );
    case 'olcek': {
      const max = a.max ?? 10; const min = max === 10 ? 0 : 1;
      const sayilar = Array.from({ length: max - min + 1 }, (_, i) => min + i);
      return sar(
        <div className="fm-olcek">
          {sayilar.map(n => <button key={n} type="button" className={`fm-olcek-nokta${v === n ? ' on' : ''}`} disabled={salt} onClick={() => onChange(a.kod, v === n ? '' : n)}>{n}</button>)}
        </div>, true);
    }
    case 'skor': {
      const sec = (v ?? {}) as Record<string, number>;
      return sar(
        <div className="fm-skor-tablo">
          {(a.satirlar ?? []).map(s => (
            <div key={s.kod} className="fm-skor-satir">
              <div className="fm-skor-etiket">{s.etiket}</div>
              <div className="fm-skor-secenekler">
                {s.secenek.map((o, i) => (
                  <button key={i} type="button" className={`fm-skor-sec${sec[s.kod] === i ? ' on' : ''}`} disabled={salt}
                          onClick={() => onChange(a.kod, { ...sec, [s.kod]: i })}>
                    <span>{o.ad}</span><small>{o.puan}</small>
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>, true);
    }
    case 'imza':
      return sar(<div className="sonuk">İmza alanı — formun sonundaki imza bloğundan.</div>);
    default:
      return sar(<input className="fm-giris" value={(v as string) ?? ''} disabled={salt} onChange={e => onChange(a.kod, e.target.value)} />);
  }
}
