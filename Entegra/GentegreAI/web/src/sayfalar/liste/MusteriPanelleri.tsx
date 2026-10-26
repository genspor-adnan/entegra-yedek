import { EkstreIkon } from '../../bilesenler/EkstreIkon';
import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { MusteriGostergesi as Gosterge, TedarikciGostergesi as TedGosterge } from '../../api/uclar/cariListe';
import type { ListeSatiri } from '../../api/sozlesme';
import { para, sayi, tarihSaat } from '../../bilesenler/bicim';
import { Avatar, dovizBakiyeMetni, Egri } from '../../bilesenler/grid/satirHucre';
import { useOturum } from '../../kimlik/OturumBaglami';
import { BelgeKarti } from '../BelgeKarti';
import { KasaIslemKarti } from '../KasaIslemKarti';
import { CariAksiyonMenusu } from '../../bilesenler/CariAksiyonMenusu';
import { c } from '../../dil/ceviri';

/**
 * MÜŞTERİ LİSTESİ VER3 (1150, mockup Ekranlar/musteri_listesi_ver3.html).
 *
 *  · MusteriGostergesi - üst şerit: aktif, alacak, vadesi geçen, limit aşan, 90 gündür
 *    satış yok, bu yıl ciro. Kutu listenin AKILLI ÇİPİNİ açar (aynı koşul, aynı sayı).
 *  · MusteriOnizleme - sağ panel: seçili müşterinin mali durumu, son 5 cari hareketi,
 *    iletişim ve hızlı işlemler (Aksiyon ▾ menüsü: belge / tahsilat-ödeme bu müşteriyle dolu, kendi sekmesinde).
 *
 * Rakamlar satırdan ve sunucudan gelir; panel hesap yapmaz.
 */

/** listeTanimlari.Cari Müşteri Listesi çip sırası: Aktif, Pasif, Tümü, Borçlu, Vadesi geçen, Limit aşan, Satış yok 90+, Dövizli. */
const CIP = { aktif: 0, tumu: 2, borclu: 3, vadeli: 4, limit: 5, uyuyan: 6 } as const;

const kisa = (n: number) => Math.abs(n) >= 1e6
  ? `${sayi.format(Math.round(n / 1e5) / 10)} M` : para.format(n);

export function MusteriGostergesi({ yenile, cipIndeks, onCip }:
                                  { yenile: number; cipIndeks?: number; onCip(i: number): void }) {
  const [g, setG] = useState<Gosterge | null>(null);
  useEffect(() => { api.musteriGosterge().then(y => setG(y.gosterge)).catch(() => setG(null)) }, [yenile]);
  const degisim = g && g.ciroGecenYil > 0 ? Math.round((g.ciroBuYil / g.ciroGecenYil - 1) * 100) : null;
  const kutular: { cip: number | null; deger: string; ad: string; ek?: string; sinif?: string }[] = [
    { cip: CIP.aktif, deger: g ? sayi.format(g.aktif) : '…', ad: 'Aktif müşteri',
      ek: g?.yeniBuAy ? `+${g.yeniBuAy} ${c('bu ay')}` : undefined },
    { cip: CIP.borclu, deger: g ? kisa(g.alacak) : '…', ad: 'Toplam alacağımız',
      ek: g ? `${sayi.format(g.borclu)} ${c('borçlu')}` : undefined, sinif: g?.alacak ? 'kirmizi' : undefined },
    { cip: CIP.vadeli, deger: g ? kisa(g.vadesiGecen) : '…', ad: 'Vadesi geçen',
      ek: g ? `${sayi.format(g.vadeli)} ${c('cari')}` : undefined, sinif: g?.vadesiGecen ? 'kirmizi' : undefined },
    { cip: CIP.limit, deger: g ? sayi.format(g.limitAsan) : '…', ad: 'Risk limiti aşan',
      sinif: g?.limitAsan ? 'uyari' : undefined },
    { cip: CIP.uyuyan, deger: g ? sayi.format(g.uyuyan) : '…', ad: '90 gündür satış yok',
      ek: g?.uyuyanCiro ? `${c('12 ay')} ${kisa(g.uyuyanCiro)}` : undefined },
    { cip: null, deger: g ? kisa(g.ciroBuYil) : '…', ad: 'Bu yıl ciro (KDV dahil)',
      ek: degisim !== null ? `${c('geçen yıla göre')} ${degisim >= 0 ? '↑' : '↓'} %${Math.abs(degisim)}` : undefined },
  ];
  return (
    <div className="pl-kpi ml-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" disabled={k.cip === null}
                className={`pl-k${k.cip !== null && cipIndeks === k.cip ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                title={k.cip !== null ? c('Listeyi bu kümeye süz (tekrar tıkla: tümü)') : undefined}
                onClick={() => k.cip !== null && onCip(cipIndeks === k.cip ? CIP.tumu : k.cip)}>
          <b>{k.deger}</b><span>{c(k.ad)}{k.ek ? ` · ${k.ek}` : ''}</span>
        </button>
      ))}
    </div>
  );
}

/** Tedarikçi Listesi çip sırası (listeTanimlari.Cari): Aktif 0, Pasif 1, Tümü 2, Borçlu olduğumuz 3, Vadesi geçen ödeme 4, 30 günde ödenecek 5, Alım yok 6, Dövizli 7. */
const TED_CIP = { aktif: 0, tumu: 2, borclu: 3, vadeli: 4, odenecek: 5, uyuyan: 6 } as const;

/** TEDARİKÇİ LİSTESİ VER3 (1162, mockup tedarikci_listesi_ver3.html): borcumuz, ödeme takvimi, alım. */
export function TedarikciGostergesi({ yenile, cipIndeks, onCip }:
                                    { yenile: number; cipIndeks?: number; onCip(i: number): void }) {
  const [g, setG] = useState<TedGosterge | null>(null);
  useEffect(() => { api.tedarikciGosterge().then(y => setG(y.gosterge)).catch(() => setG(null)) }, [yenile]);
  const degisim = g && g.alisGecenYil > 0 ? Math.round((g.alisBuYil / g.alisGecenYil - 1) * 100) : null;
  const kutular: { cip: number | null; deger: string; ad: string; ek?: string; sinif?: string }[] = [
    { cip: TED_CIP.aktif, deger: g ? sayi.format(g.aktif) : '…', ad: 'Aktif tedarikçi', ek: g?.yeniBuAy ? `+${g.yeniBuAy} ${c('bu ay')}` : undefined },
    { cip: TED_CIP.borclu, deger: g ? kisa(g.borc) : '…', ad: 'Toplam borcumuz', ek: g ? `${sayi.format(g.borclu)} ${c('tedarikçiye')}` : undefined, sinif: g?.borc ? 'kirmizi' : undefined },
    { cip: TED_CIP.vadeli, deger: g ? kisa(g.vadesiGecen) : '…', ad: 'Vadesi geçen ödeme', ek: g ? `${sayi.format(g.vadeli)} ${c('tedarikçi')}` : undefined, sinif: g?.vadesiGecen ? 'kirmizi' : undefined },
    { cip: TED_CIP.odenecek, deger: g ? kisa(g.odenecek30) : '…', ad: '30 gün içinde ödenecek', ek: g ? `${sayi.format(g.odenecekCari)} ${c('tedarikçi')} · ${c('7 günde çek')} ${kisa(g.cekHafta)}` : undefined, sinif: g?.odenecek30 ? 'uyari' : undefined },
    { cip: TED_CIP.uyuyan, deger: g ? sayi.format(g.uyuyan) : '…', ad: '90 gündür alım yok' },
    { cip: null, deger: g ? kisa(g.alisBuYil) : '…', ad: 'Bu yıl alım (KDV dahil)',
      ek: degisim !== null ? `${c('geçen yıla göre')} ${degisim >= 0 ? '↑' : '↓'} %${Math.abs(degisim)}` : undefined },
  ];
  return (
    <div className="pl-kpi ml-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" disabled={k.cip === null}
                className={`pl-k${k.cip !== null && cipIndeks === k.cip ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                title={k.cip !== null ? c('Listeyi bu kümeye süz (tekrar tıkla: tümü)') : undefined}
                onClick={() => k.cip !== null && onCip(cipIndeks === k.cip ? TED_CIP.tumu : k.cip)}>
          <b>{k.deger}</b><span>{c(k.ad)}{k.ek ? ` · ${k.ek}` : ''}</span>
        </button>
      ))}
    </div>
  );
}

export function MusteriOnizleme({ satir, yenile, tazele, git, gitKart, tedarikci }: {
  satir: ListeSatiri | null; yenile: number; tazele(): void;
  git(yol: string): void; gitKart(yol: string): void;
  /** Tedarikçi Listesi (1162): etiketler ve hızlı işlemler tedarikçi gözüyle (alış faturası, ödeme). */
  tedarikci?: boolean;
}) {
  const { yetki } = useOturum();
  const id = satir ? Number(satir.id) : 0;
  const [hareket, setHareket] = useState<ListeSatiri[] | null>(null);
  /** Son hareketlerde çift tıklanan kayıt (kasa işlemi ya da belge). */
  const [acik, setAcik] = useState<{ kasa?: number; belge?: number } | null>(null);
  const ekstreYetkisi = yetki('mali_hareket', 'gor');
  useEffect(() => {
    setHareket(null);
    if (!(id > 0) || !ekstreYetkisi) return;
    api.liste('cari-ekstre', { sayfa: 1, boyut: 5, filtre: { alan: 'tarafId', op: 'esit', deger: id },
                               sirala: [{ alan: 'islemTarihi', yon: 'desc' }] })
       .then(y => setHareket(y.satirlar)).catch(() => setHareket([]));
  }, [id, yenile, ekstreYetkisi]);

  if (!(id > 0) || !satir) return <div className="pl-oniz bos sonuk">{tedarikci ? c('Önizleme için bir tedarikçi seçin.') : c('Önizleme için bir müşteri seçin.')}</div>;
  const ad = String(satir.unvan ?? '');
  const bakiye = Number(satir.bakiye ?? 0), vade = Number(satir.vadesiGecen ?? 0);
  const limit = Number(satir.riskLimiti ?? 0), risk = satir.riskYuzde;
  const doviz = dovizBakiyeMetni(satir.dovizBakiye);
  const egri = String((tedarikci ? satir.alisEgri : satir.ciroEgri) ?? '').split(',').filter(Boolean).map(Number);
  const kapat = () => { setAcik(null); tazele() };
  const kart = () => gitKart(tedarikci ? `/tedarikci/${id}` : `/cari/${id}`);
  const vadeOdeme = Number(satir.vadesiGecenOdeme ?? 0), odenecek = Number(satir.odenecek30 ?? 0);

  return (
    <div className="pl-oniz">
      <div className="pl-kimlik"><Avatar ad={ad} buyuk soluk={Number(satir.durum ?? 1) !== 1} />
        <div><b>{ad}</b>
          <small>{[satir.kod, satir.il, satir.temsilci && `${c('Temsilci')}: ${satir.temsilci}`].filter(Boolean).join(' · ')}</small>
          <small>{Number(satir.efatura) === 1 ? 'e-Fatura' : 'e-Arşiv'}{Number(satir.durum ?? 1) !== 1 ? ` · ${c('Pasif')}` : ''}</small></div></div>

      <div className="ml-hizli">
        {/* AKSİYON ▾ (kullanıcı 26.10.2026: "müş/ted listesi sağ panele de aksiyon menüsü koy.. fat sip tah/öde
            kaldır"): ekstredeki menünün aynısı (müşteriye satış + tahsilat, tedarikçiye alış + ödeme, ikisiyse geniş menü). */}
        <CariAksiyonMenusu id={id} ad={ad} git={gitKart} />
        {ekstreYetkisi && <button type="button" className="d"
                onClick={() => git(`/ekstre?tur=cari&id=${id}`)}><EkstreIkon /> {c('Ekstre')}</button>}
        <button type="button" className="d bir" onClick={kart}>{c('Kartı Aç')} ↗</button>
      </div>

      <div className="pl-bl"><h5>{tedarikci ? c('Ödeme durumu') : c('Mali durum')}</h5>
        <div className="ml-mali">
          <div><span>{tedarikci ? c('Borcumuz') : c('Bakiye')}</span>
            <b className={bakiye > 0.005 ? (tedarikci ? 'ml-alacak' : 'ml-borc') : bakiye < -0.005 ? (tedarikci ? 'ml-borc' : 'ml-alacak') : undefined}>
              {para.format(Math.abs(bakiye))} {bakiye > 0.005 ? 'B' : bakiye < -0.005 ? 'A' : ''}</b></div>
          {tedarikci ? <>
            <div><span>{c('Vadesi geçen ödeme')}</span><b className={vadeOdeme > 0.005 ? 'ml-borc' : undefined}>{para.format(vadeOdeme)}</b></div>
            <div><span>{c('30 günde ödenecek')}</span><b>{para.format(odenecek)}</b></div>
            <div><span>{c('Son ödeme')}</span><b>{satir.sonOdeme ? tarihSaat(satir.sonOdeme).slice(0, 10) : '—'}</b></div>
          </> : <>
            <div><span>{c('Vadesi geçen')}</span><b className={vade > 0.005 ? 'ml-borc' : undefined}>{para.format(vade)}</b></div>
            <div><span>{c('Risk limiti')}</span>
              <b>{limit > 0 ? `${para.format(limit)} · %${sayi.format(Number(risk ?? 0))}` : c('limitsiz')}</b></div>
            <div><span>{c('Son tahsilat')}</span><b>{satir.sonTahsilat ? tarihSaat(satir.sonTahsilat).slice(0, 10) : '—'}</b></div>
          </>}
        </div>
        {doviz && <div className="sonuk pl-kucuk" style={{ marginTop: 4 }}>{c('Döviz')}: {doviz}</div>}
      </div>

      {egri.length > 1 && egri.some(x => x) && (
        <div className="pl-bl"><h5>{tedarikci ? c('Alım eğilimi (12 ay)') : c('Satış eğilimi (12 ay)')} · {para.format(Number((tedarikci ? satir.alis12Ay : satir.ciro12Ay) ?? 0))}</h5>
          <Egri degerler={egri} genislik={300} yukseklik={40} />
          {tedarikci
            ? (satir.sonAlisGun !== null && satir.sonAlisGun !== undefined &&
               <div className="sonuk pl-kucuk">{c('Son alım')}: {sayi.format(Number(satir.sonAlisGun))} {c('gün önce')}</div>)
            : (satir.sonSatisGun !== null && satir.sonSatisGun !== undefined &&
               <div className="sonuk pl-kucuk">{c('Son satış')}: {sayi.format(Number(satir.sonSatisGun))} {c('gün önce')}</div>)}
        </div>
      )}

      {ekstreYetkisi && (
        <div className="pl-bl"><h5>{c('Son hareketler')}
          <button type="button" className="pl-bag"
                  onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>{c('Tam ekstre')} ›</button></h5>
          {hareket === null ? <div className="sonuk">{c('yükleniyor')}…</div>
            : hareket.length === 0 ? <div className="sonuk">{c('Hareket yok.')}</div> : (
            <table className="ml-hareket"><tbody>
              {hareket.map(h => {
                const b = Number(h.borc ?? 0), a = Number(h.alacak ?? 0);
                const kasa = Number(h.kasaIslemId ?? 0), belge = Number(h.belgeId ?? 0);
                return (
                  // Çift tık: hareketi ÜRETEN kayıt (önce kasa işlemi, yoksa belge) - ekstre kuralı.
                  <tr key={String(h.id)} title={c('Çift tıkla: kaydı aç')}
                      onDoubleClick={() => (kasa || belge) && setAcik(kasa ? { kasa } : { belge })}>
                    <td>{tarihSaat(h.islemTarihi).slice(0, 10)}</td>
                    <td title={String(h.aciklama ?? '')}>{String(h.turAdi ?? '')}{h.belgeNo ? ` ${h.belgeNo}` : ''}</td>
                    <td className={`hiza-sag ${b ? 'ml-borc' : 'ml-alacak'}`}>
                      {para.format(b || a)}{h.dovizCinsi && h.dovizCinsi !== 'TL' ? ` ${h.dovizCinsi}` : ''}</td>
                  </tr>
                );
              })}
            </tbody></table>
          )}
        </div>
      )}

      <div className="pl-bl"><h5>{c('İletişim')}</h5>
        {satir.telefon ? <div className="pl-satir"><span>{c('Telefon')}</span>{String(satir.telefon)}</div> : null}
        {satir.cepTel ? <div className="pl-satir"><span>{c('Cep')}</span>{String(satir.cepTel)}</div> : null}
        {satir.eposta ? <div className="pl-satir"><span>{c('E-posta')}</span><span className="pl-kes" title={String(satir.eposta)}>{String(satir.eposta)}</span></div> : null}
        {satir.vkno ? <div className="pl-satir"><span>{c('VKN / TCKN')}</span>{String(satir.vkno)}</div> : null}
        {satir.adres ? <div className="pl-satir"><span>{c('Adres')}</span><span>{[satir.adres, satir.ilce, satir.il].filter(Boolean).join(', ')}</span></div> : null}
        {!satir.telefon && !satir.cepTel && !satir.eposta && <div className="sonuk">{c('İletişim bilgisi yok.')}</div>}
      </div>

      {acik?.kasa && <KasaIslemKarti kayitIdProp={acik.kasa} onKapat={kapat} />}
      {acik?.belge && <BelgeKarti id={acik.belge} onKapat={kapat} />}
    </div>
  );
}
