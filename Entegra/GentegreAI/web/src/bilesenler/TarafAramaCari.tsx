import { useEffect, useState } from 'react';
import type { ListeSatiri } from '../api/sozlesme';
import { para, sayi } from './bicim';
import { c } from '../dil/ceviri';
import { type CariEk, cariEkGetir } from './cariArama';
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
  if (s.riskYuzde == null || s.riskYuzde === '') return <span className="gh-sonuk">—</span>;
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
  if (v == null || v === '') return <span className="gh-sonuk">—</span>;
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
      <td>{metin(s.kod) || <span className="gh-sonuk">—</span>}</td>
      <td className="ad">
        <b>{unvan}</b>
        {fatura && fatura.toLocaleLowerCase('tr') !== unvan.toLocaleLowerCase('tr') && <small>fatura: {fatura}</small>}
      </td>
      <td><span className="ta-kirp">{yer || <span className="gh-sonuk">—</span>}</span></td>
      <td><span className="ta-kirp dar">{metin(s.telefon) || metin(s.cepTel) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{metin(s.ilgiliKisi) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="ta-g2"><span className="ta-kirp">{metin(s.temsilci) || <span className="gh-sonuk">—</span>}</span></td>
      <td className="hiza-sag"><Bakiye v={b.tedarikci ? -sayiya(s.bakiye) : s.bakiye} /></td>
      <td className="hiza-sag">{vade > 0 ? <span className="ta-borc">{para.format(vade)}</span> : para.format(0)}</td>
      {!b.tedarikci && <td><RiskCubugu s={s} /></td>}
      <td className="hiza-orta"><Gun v={b.tedarikci ? s.sonAlisGun : s.sonSatisGun} /></td>
      <td className="hiza-orta">{Number(s.efatura) === 1 ? <span className="ta-ef">e-Fat</span> : ''}</td>
    </>
  );
}

/** Ekstre YENİ TARAYICI SEKMESİNDE: pencere modal, uygulama sekmesine gitmek arkadaki belge kartını düşürürdü. */
export function CariEkDugmeler({ s }: { s: ListeSatiri | undefined }) {
  return (
    <button type="button" className="d" disabled={!s} title="Cari ekstresi (yeni sekmede)"
            onClick={() => s && window.open(`${import.meta.env.BASE_URL}ekstre?tur=cari&id=${s.id}`, '_blank')}>
      📄 Ekstre
    </button>
  );
}

/** Panel başlığı + kapat düğmesi (düzenler ortak). */
export function OnizlemeBasligi({ onKapat }: { onKapat(): void }) {
  return (
    <div className="ta-on-bas"><span>{c('Önizleme')}</span>
      <button type="button" title="Önizlemeyi kapat" onClick={onKapat}>◨</button></div>
  );
}

export function CariOnizleme({ s, b, onKapat }: { s: ListeSatiri | undefined; b: TarafBaglam; onKapat(): void }) {
  const tedarikci = b.tedarikci;
  // Okunan ek bilgi id ile birlikte tutulur: satır değişince eski carinin notu bir an bile görünmez.
  const [ekDurum, setEkDurum] = useState<{ id: number; ek: CariEk } | null>(null);
  const id = s ? Number(s.id) : 0;
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

  if (!s) return <div className="ta-on"><OnizlemeBasligi onKapat={onKapat} /><div className="gh-sonuk">{c('Satır seçin')}</div></div>;
  const risk = s.riskYuzde == null || s.riskYuzde === '' ? null : sayiya(s.riskYuzde);
  const bakiye = tedarikci ? -sayiya(s.bakiye) : sayiya(s.bakiye);
  const vade = sayiya(tedarikci ? s.vadesiGecenOdeme : s.vadesiGecen);
  const adres = [metin(s.adres), [metin(s.ilce), metin(s.il)].filter(Boolean).join(' / ')].filter(Boolean);
  const sonTarih = tarihYaz(tedarikci ? s.sonOdeme : s.sonTahsilat);
  const iletisimVar = adres.length > 0 || metin(s.telefon) || metin(s.cepTel) || metin(s.eposta) || metin(s.ilgiliKisi);
  return (
    <div className="ta-on">
      <OnizlemeBasligi onKapat={onKapat} />
      <h4>{metin(s.unvan)}</h4>
      <div className="ta-kod">
        {metin(s.kod)}{metin(s.kod) && ' · '}<TipRozeti s={s} />
        {Number(s.efatura) === 1 && <> · <span className="ta-ef">e-Fatura</span></>}
      </div>
      {risk !== null && risk > 100 && (
        <div className="ta-uyar kir">⚠ Risk limiti aşılmış (%{sayi.format(risk)}). Belge kaydında onay istenir.</div>)}
      {risk !== null && risk >= 70 && risk <= 100 && (
        <div className="ta-uyar">⚠ Risk limitinin %{sayi.format(risk)}'inde. Bu belgeyle sınır aşılırsa kayıtta onay istenir.</div>)}

      <div className="ta-blok"><h5>İletişim</h5>
        {adres.length > 0 && (
          <div className="ta-sat"><span>Adres</span>
            <span>{adres.map((x, i) => <span key={i}>{i > 0 && <br />}{x}</span>)}</span></div>)}
        {metin(s.telefon) && <div className="ta-sat"><span>Telefon</span><span>{metin(s.telefon)}</span></div>}
        {metin(s.cepTel) && <div className="ta-sat"><span>Cep</span><span>{metin(s.cepTel)}</span></div>}
        {metin(s.eposta) && <div className="ta-sat"><span>E-posta</span><span>{metin(s.eposta)}</span></div>}
        {metin(s.ilgiliKisi) && <div className="ta-sat"><span>İlgili kişi</span><span>{metin(s.ilgiliKisi)}</span></div>}
        {!iletisimVar && <div className="gh-sonuk">—</div>}
      </div>

      <div className="ta-blok"><h5>Hesap</h5>
        <div className="ta-sat"><span>{tedarikci ? 'Borcumuz' : 'Bakiye'}</span><span><Bakiye v={bakiye} /></span></div>
        <div className="ta-sat"><span>Vadesi geçen</span>
          <span className={vade > 0 ? 'ta-borc' : ''}>{para.format(vade)}</span></div>
        {!tedarikci && sayiya(s.riskLimiti) > 0 && (
          <div className="ta-sat"><span>Risk limiti</span>
            <span>{para.format(sayiya(s.riskLimiti))}<RiskCubugu s={s} genis /></span></div>)}
        {metin(s.dovizBakiye) && <div className="ta-sat"><span>Döviz</span><span>{metin(s.dovizBakiye)}</span></div>}
        {sonTarih && (
          <div className="ta-sat"><span>{tedarikci ? 'Son ödeme' : 'Son tahsilat'}</span><span>{sonTarih}</span></div>)}
      </div>

      {ek && !ek.kartYok && (ek.fiyatListesi || ek.vadeGun || metin(s.temsilci)) && (
        <div className="ta-blok"><h5>{tedarikci ? 'Alış koşulları (belgeye geçer)' : 'Satış koşulları (belgeye geçer)'}</h5>
          {ek.fiyatListesi && <div className="ta-sat"><span>Fiyat listesi</span><span>{ek.fiyatListesi}</span></div>}
          {ek.vadeGun && <div className="ta-sat"><span>Ödeme vadesi</span><span>{ek.vadeGun} gün</span></div>}
          {metin(s.temsilci) && <div className="ta-sat"><span>Temsilci</span><span>{metin(s.temsilci)}</span></div>}
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
    </div>
  );
}
