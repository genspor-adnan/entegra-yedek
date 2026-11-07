import { useEffect, useState } from 'react';
import type { ListeSatiri } from '../api/sozlesme';
import { para, sayi } from './bicim';
import { type CariEk, cariEkGetir } from './cariArama';
import { Bos, IletisimBlok, Sat, yoksaTire } from './TarafAramaOrtak';
import { type TarafBaglam, metin, sayiya, tarihYaz } from './tarafDuzeni';

/**
 * MÜŞTERİ / TEDARİKÇİ ARAMASI - cari düzeninin bileşenleri (kurallar cariArama.ts, düzen tarafDuzenleri.ts; mockup
 * Ekranlar/taraf_arama.html, kullanıcı 05.11.2026). Kolonlar belge kesen kullanıcının seçmeden önce görmesi
 * gerekenler (il, ilgili kişi, bakiye, vade, risk, son satış); sağda önizleme: iletişim, hesap, belgeye geçecek
 * koşullar, son belgeler, not. Alış belgesinde (b.tedarikci) tedarikçi gözü: Borcumuz / vadesi geçen ödeme / Son Alım.
 */

export function TipRozeti({ s }: { s: ListeSatiri }) {
  const m = Number(s.musteri) === 1, t = Number(s.tedarikci) === 1;
  if (m && t) return <span className="ta-roz iki">Müş./Ted.</span>;
  if (m) return <span className="ta-roz mus">Müşteri</span>;
  if (t) return <span className="ta-roz ted">Tedarikçi</span>;
  if (Number(s.aday) === 1) return <span className="ta-roz aday">Aday</span>;
  return <span className="ta-roz">Cari</span>;
}

/** +borç "B", -alacak "A" (bakiye:dovizBakiye biçimiyle aynı okuma). */
function Bakiye({ v }: { v: unknown }) {
  const n = sayiya(v);
  if (Math.abs(n) < 0.005) return <>{para.format(0)}</>;
  return <span className={n > 0 ? 'ta-borc' : 'ta-alacak'}>{para.format(Math.abs(n))} {n > 0 ? 'B' : 'A'}</span>;
}

function RiskCubugu({ s, genis }: { s: ListeSatiri; genis?: boolean }) {
  if (s.riskYuzde == null || s.riskYuzde === '') return <Bos />;
  const n = sayiya(s.riskYuzde);
  const sinif = n > 100 ? 'kir' : n >= 70 ? 'sari' : '';
  return (
    <span className="gh-cubuk gh-risk" style={genis ? { marginLeft: 6 } : undefined}>
      <span className="yol"><span style={{ width: `${Math.min(100, Math.max(0, n))}%` }} className={sinif} /></span>
      %{sayi.format(n)}
    </span>
  );
}

function Gun({ v }: { v: unknown }) {
  if (v == null || v === '') return <Bos />;
  const n = sayiya(v);
  if (n <= 0) return <>bugün</>;
  return <span className={`gh-gun${n >= 90 ? ' kir' : n >= 30 ? ' sari' : ''}`}>{sayi.format(n)} gün</span>;
}

export function CariBasliklar({ b }: { b: TarafBaglam }) {
  return (
    <>
      <th>Tip</th>
      <th>Kod</th>
      <th className="ad">Ünvan</th>
      <th>İl / İlçe</th>
      <th>Telefon</th>
      {/* Önizleme açıkken gizli (ta-g2): ikisi de panelde yazılı, grid panele yer açar. */}
      <th className="ta-g2">İlgili Kişi</th>
      <th className="ta-g2">Temsilci</th>
      <th className="hiza-sag">{b.tedarikci ? 'Borcumuz' : 'Bakiye'}</th>
      <th className="hiza-sag" title={b.tedarikci ? 'Vadesi geçen ödeme' : undefined}>Vadesi Geçen</th>
      {!b.tedarikci && <th>Risk</th>}
      <th className="hiza-orta">{b.tedarikci ? 'Son Alım' : 'Son Satış'}</th>
      <th className="hiza-orta">e-Fat</th>
    </>
  );
}

export function CariHucreler({ s, b }: { s: ListeSatiri; b: TarafBaglam }) {
  const unvan = metin(s.unvan), fatura = metin(s.faturaUnvan);
  const yer = [metin(s.il), metin(s.ilce)].filter(Boolean).join(' / ');
  const vade = sayiya(b.tedarikci ? s.vadesiGecenOdeme : s.vadesiGecen);
  return (
    <>
      <td><TipRozeti s={s} /></td>
      <td>{yoksaTire(s.kod)}</td>
      <td className="ad">
        <b>{unvan}</b>
        {fatura && fatura.toLocaleLowerCase('tr') !== unvan.toLocaleLowerCase('tr') && <small>fatura: {fatura}</small>}
      </td>
      <td><span className="ta-kirp">{yer || <Bos />}</span></td>
      <td><span className="ta-kirp dar">{metin(s.telefon) || metin(s.cepTel) || <Bos />}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{yoksaTire(s.ilgiliKisi)}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{yoksaTire(s.temsilci)}</span></td>
      <td className="hiza-sag"><Bakiye v={b.tedarikci ? -sayiya(s.bakiye) : s.bakiye} /></td>
      <td className="hiza-sag">{vade > 0 ? <span className="ta-borc">{para.format(vade)}</span> : para.format(0)}</td>
      {!b.tedarikci && <td><RiskCubugu s={s} /></td>}
      <td className="hiza-orta"><Gun v={b.tedarikci ? s.sonAlisGun : s.sonSatisGun} /></td>
      <td className="hiza-orta">{Number(s.efatura) === 1 ? <span className="ta-ef">e-Fat</span> : ''}</td>
    </>
  );
}

export function CariOnizleme({ s, b }: { s: ListeSatiri; b: TarafBaglam }) {
  const tedarikci = b.tedarikci;
  // Okunan ek bilgi id ile birlikte tutulur: satır değişince eski carinin notu bir an bile görünmez.
  const [ekDurum, setEkDurum] = useState<{ id: number; ek: CariEk } | null>(null);
  const id = Number(s.id);
  useEffect(() => {
    if (!(id > 0)) return;
    let iptal = false;
    // Ok tuşuyla hızla gezerken her satır için istek atılmasın.
    const z = window.setTimeout(() => {
      cariEkGetir(id, tedarikci).then(ek => { if (!iptal) setEkDurum({ id, ek }) }, () => {});
    }, 250);
    return () => { iptal = true; window.clearTimeout(z) };
  }, [id, tedarikci]);
  const ek = ekDurum?.id === id ? ekDurum.ek : null;

  const risk = s.riskYuzde == null || s.riskYuzde === '' ? null : sayiya(s.riskYuzde);
  const bakiye = tedarikci ? -sayiya(s.bakiye) : sayiya(s.bakiye);
  const vade = sayiya(tedarikci ? s.vadesiGecenOdeme : s.vadesiGecen);
  const adres = [metin(s.adres), [metin(s.ilce), metin(s.il)].filter(Boolean).join(' / ')].filter(Boolean);
  const sonTarih = tarihYaz(tedarikci ? s.sonOdeme : s.sonTahsilat);
  return (
    <>
      <h4>{metin(s.unvan)}</h4>
      <div className="ta-kod">
        {metin(s.kod)}{metin(s.kod) && ' · '}<TipRozeti s={s} />
        {Number(s.efatura) === 1 && <> · <span className="ta-ef">e-Fatura</span></>}
      </div>
      {risk !== null && risk > 100 && (
        <div className="ta-uyar kir">⚠ Risk limiti aşılmış (%{sayi.format(risk)}). Belge kaydında onay istenir.</div>)}
      {risk !== null && risk >= 70 && risk <= 100 && (
        <div className="ta-uyar">⚠ Risk limitinin %{sayi.format(risk)}'inde. Bu belgeyle sınır aşılırsa kayıtta onay istenir.</div>)}

      <IletisimBlok s={s} adres={adres} ilgiliKisi />

      <div className="ta-blok"><h5>Hesap</h5>
        <Sat etiket={tedarikci ? 'Borcumuz' : 'Bakiye'} v={<Bakiye v={bakiye} />} />
        <Sat etiket="Vadesi geçen" v={para.format(vade)} sinif={vade > 0 ? 'ta-borc' : undefined} />
        {!tedarikci && sayiya(s.riskLimiti) > 0 && (
          <Sat etiket="Risk limiti" v={<>{para.format(sayiya(s.riskLimiti))}<RiskCubugu s={s} genis /></>} />)}
        <Sat etiket="Döviz" v={metin(s.dovizBakiye)} />
        <Sat etiket={tedarikci ? 'Son ödeme' : 'Son tahsilat'} v={sonTarih} />
      </div>

      {ek && !ek.kartYok && (ek.fiyatListesi || ek.vadeGun || metin(s.temsilci)) && (
        <div className="ta-blok"><h5>{tedarikci ? 'Alış koşulları (belgeye geçer)' : 'Satış koşulları (belgeye geçer)'}</h5>
          <Sat etiket="Fiyat listesi" v={ek.fiyatListesi} />
          <Sat etiket="Ödeme vadesi" v={ek.vadeGun ? `${ek.vadeGun} gün` : ''} />
          <Sat etiket="Temsilci" v={metin(s.temsilci)} />
        </div>)}

      {ek && !ek.belgeYok && ek.belgeler.length > 0 && (
        <div className="ta-blok"><h5>Son belgeler</h5>
          <div className="ta-belge">
            {ek.belgeler.map((x, i) => (
              <span key={i} style={{ display: 'contents' }}>
                <span className="t">{x.tarih}</span>
                <span className="kirp">{x.ad}</span>
                <span>{x.tutar ? para.format(x.tutar) : '—'}</span>
              </span>))}
          </div>
        </div>)}

      {ek && ek.notlar && <div className="ta-blok"><h5>Not</h5><div className="ta-not">{ek.notlar}</div></div>}
    </>
  );
}
