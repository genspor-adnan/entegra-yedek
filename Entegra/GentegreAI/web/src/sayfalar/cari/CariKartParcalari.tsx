import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useOturum } from '../../kimlik/OturumBaglami';
import { CariDevirPenceresi } from './CariDevirPenceresi';
import { api } from '../../api/istemci';
import type { CariKartOzeti } from '../../api/uclar/cariListe';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { GenGrid } from '../../bilesenler/GenGrid';
import { para, sayi, tarihSaat } from '../../bilesenler/bicim';
import { Avatar, dovizBakiyeMetni, Egri } from '../../bilesenler/grid/satirHucre';
import { BelgeKarti } from '../BelgeKarti';
import { KasaIslemKarti } from '../KasaIslemKarti';
import { c } from '../../dil/ceviri';

/**
 * MÜŞTERİ KARTI VER3 (mockup Ekranlar/musteri_karti_ver3.html) - kart eklentisinin parçaları
 * (`kartEklentileri.tsx` › `cari`):
 *  · CariOzetSeridi   kimlik şeridinin altında her sekmede: bakiye, vadesi geçen, risk,
 *                     açık sipariş, portföydeki çek, bu yıl ciro, son satış
 *  · CariYanPanel     sağ sütun: dikkat, sabit not, yaşlandırma, ana kişiler, son olaylar
 *  · CariFinansal     Finansal sekmesi: para birimi özeti, yaşlandırma, vadesi geçen belgeler, çekler
 *  · CariBelgeler     Belgeler sekmesi: carinin bütün belgeleri, türe göre çip
 *  · CariCrm          CRM sekmesi: görevler + satış fırsatları
 *  · CariHizliIslemler araç çubuğu: Fatura / Sipariş / Teklif / Tahsilat bu cariyle dolu
 *
 * Rakamların hepsi tek uçtan (GET /api/cari/{id}/kart-ozet) - şerit, panel ve sekme aynı
 * isteği paylaşır (aynı kart + tazeleme için tek istek).
 */

const bekleyen = new Map<string, Promise<CariKartOzeti>>();
/** Aynı kart / tazeleme için tek istek (şerit, yan panel ve Finansal birlikte çizilir). */
function ozetGetir(id: number, tazele: number): Promise<CariKartOzeti> {
  const anahtar = `${id}:${tazele}`;
  let p = bekleyen.get(anahtar);
  if (!p) {
    p = api.cariKartOzet(id);
    bekleyen.set(anahtar, p);
    // Eski anahtarlar birikmesin; bir sonraki tazelemede yeniden istenir.
    void p.finally(() => setTimeout(() => bekleyen.delete(anahtar), 2000));
  }
  return p;
}

export function useCariKartOzeti(id: number, tazele: number) {
  const [veri, setVeri] = useState<CariKartOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    let iptal = false;
    setHata(null);
    ozetGetir(id, tazele).then(v => { if (!iptal) setVeri(v) }, h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [id, tazele]);
  return { veri, hata };
}

const isaret = (n: number) => (n > 0.005 ? ' B' : n < -0.005 ? ' A' : '');
const kisaTarih = (t: string | null | undefined) => (t ? tarihSaat(t).slice(0, 10) : '—');
const gunOnce = (t: string | null) => (t ? Math.max(0, Math.round((Date.now() - new Date(t).getTime()) / 86400000)) : null);

// ------------------------------------------------------------ özet şeridi ----
export function CariOzetSeridi({ id, tazele, git, ad, tedarikci }: { id: number; tazele: number; ad: string; git(yol: string): void; tedarikci?: boolean }) {
  const { veri, hata } = useCariKartOzeti(id, tazele);
  if (hata) return <div className="hata-kutusu" style={{ margin: '6px 12px' }}>{hata}</div>;
  const o = veri?.ozet;
  const dovizli = (veri?.dovizler ?? []).filter(d => d.doviz !== 'TL' && Math.abs(d.bakiye) >= 0.005);
  const degisim = o && o.ciroGecenYil > 0 ? Math.round((o.ciroBuYil / o.ciroGecenYil - 1) * 100) : null;
  const sonSatis = gunOnce(o?.sonSatis ?? null);
  const risk = Number(o?.riskYuzde ?? 0);
  // TEDARİKÇİ GÖZÜ (1162, mockup tedarikci_karti_ver3.html): borcumuz, vadesi geçen ödeme, 30 günde
  //   ödenecek, verilen çek, bu yıl alım, son alım / ödeme. Yalnız tedarikçi rolündeki cari.
  const ted = !!tedarikci || (!!o && Number(o.tedarikci) === 1 && Number(o.musteri) !== 1);
  if (ted) {
    const alisDegisim = o && o.alisGecenYil > 0 ? Math.round((o.alisBuYil / o.alisGecenYil - 1) * 100) : null;
    const sonAlis = gunOnce(o?.sonAlis ?? null);
    return (
      <div className="mk-ozet">
        <button type="button" title={`${c('Cari ekstresini aç')} - ${ad}`} onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>
          <span>{c('Borcumuz')}</span>
          <b className={o && o.bakiye < -0.005 ? 'ml-borc' : o && o.bakiye > 0.005 ? 'ml-alacak' : undefined}>
            {o ? `${para.format(Math.abs(o.bakiye))}${isaret(o.bakiye)}` : '…'}</b>
          <small>{dovizli.length ? dovizBakiyeMetni(dovizli.map(d => `${d.doviz}:${d.bakiye}`).join(';')) : c('A = biz borçluyuz · TL karşılığı')}</small>
        </button>
        <div><span>{c('Vadesi geçen ödeme')}</span>
          <b className={o && o.vadesiGecenOdeme > 0.005 ? 'ml-borc' : undefined}>{o ? para.format(o.vadesiGecenOdeme) : '…'}</b>
          <small>{o?.tedVadeGun ? `${c('vade')} ${o.tedVadeGun} ${c('gün')}` : c('vade günü tanımsız (Satınalma Koşulları)')}</small></div>
        <div><span>{c('30 günde ödenecek')}</span><b>{o ? para.format(o.odenecek30) : '…'}</b>
          <small>{o?.krediLimiti ? `${c('bize tanınan limit')} ${para.format(o.krediLimiti)}` : c('alış faturaları, vadeye göre')}</small></div>
        <div><span>{c('Açık sipariş (gelecek mal)')}</span><b>{o ? para.format(o.acikSiparis) : '…'}</b>
          <small>{o ? `${sayi.format(o.acikSiparisAdet)} ${c('sipariş')}` : ''}</small></div>
        <div><span>{c('Verilen çek')}</span><b>{o ? para.format(o.verilenCekTutar) : '…'}</b>
          <small>{o?.verilenCekAdet ? `${o.verilenCekAdet} ${c('çek')} · ${c('ilk vade')} ${kisaTarih(o.verilenCekIlkVade)}` : c('yok')}</small></div>
        <div><span>{c('Bu yıl alım')}</span><b>{o ? para.format(o.alisBuYil) : '…'}</b>
          <small className={alisDegisim !== null && alisDegisim < 0 ? 'ml-borc' : undefined}>
            {alisDegisim !== null ? `${c('geçen yıl')} ${para.format(o!.alisGecenYil)} · ${alisDegisim >= 0 ? '↑' : '↓'} %${Math.abs(alisDegisim)}` : c('KDV dahil')}</small></div>
        <div><span>{c('Son alım')}</span><b>{sonAlis !== null ? `${sayi.format(sonAlis)} ${c('gün')}` : '—'}</b>
          <small>{c('Son ödeme')} {kisaTarih(o?.sonOdeme)}</small></div>
      </div>
    );
  }
  return (
    <div className="mk-ozet">
      <button type="button" title={`${c('Cari ekstresini aç')} - ${ad}`}
              onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>
        <span>{c('Bakiye')}</span>
        <b className={o && o.bakiye > 0.005 ? 'ml-borc' : o && o.bakiye < -0.005 ? 'ml-alacak' : undefined}>
          {o ? `${para.format(Math.abs(o.bakiye))}${isaret(o.bakiye)}` : '…'}</b>
        <small>{dovizli.length ? dovizBakiyeMetni(dovizli.map(d => `${d.doviz}:${d.bakiye}`).join(';')) : c('TL karşılığı')}</small>
      </button>
      <div><span>{c('Vadesi geçen')}</span>
        <b className={o && o.vadesiGecen > 0.005 ? 'ml-borc' : undefined}>{o ? para.format(o.vadesiGecen) : '…'}</b>
        <small>{o?.vadeGun ? `${c('vade')} ${o.vadeGun} ${c('gün')}` : c('vade günü tanımsız')}</small></div>
      <div><span>{o?.riskLimiti ? `${c('Risk limiti')} · ${para.format(o.riskLimiti)}` : c('Risk limiti')}</span>
        <b className={risk > 100 ? 'ml-borc' : undefined}>{o ? (o.riskLimiti ? `%${sayi.format(risk)}` : c('limitsiz')) : '…'}</b>
        {o?.riskLimiti ? <span className="mk-bar"><i style={{ width: `${Math.min(100, risk)}%` }}
                               className={risk > 100 ? 'mk-bar-kir' : risk >= 70 ? 'mk-bar-sari' : ''} /></span>
                       : <small>{c('Satış & Risk sekmesinden')}</small>}</div>
      <div><span>{c('Açık sipariş')}</span><b>{o ? para.format(o.acikSiparis) : '…'}</b>
        <small>{o ? `${sayi.format(o.acikSiparisAdet)} ${c('sipariş')}` : ''}</small></div>
      <div><span>{c('Portföydeki çek')}</span><b>{o ? para.format(o.cekTutar) : '…'}</b>
        <small>{o?.cekAdet ? `${o.cekAdet} ${c('çek')} · ${c('ilk vade')} ${kisaTarih(o.cekIlkVade)}` : c('yok')}</small></div>
      <div><span>{c('Bu yıl ciro')}</span><b>{o ? para.format(o.ciroBuYil) : '…'}</b>
        <small className={degisim !== null && degisim < 0 ? 'ml-borc' : undefined}>
          {degisim !== null ? `${c('geçen yıl')} ${para.format(o!.ciroGecenYil)} · ${degisim >= 0 ? '↑' : '↓'} %${Math.abs(degisim)}` : c('KDV dahil')}</small></div>
      <div><span>{c('Son satış')}</span><b>{sonSatis !== null ? `${sayi.format(sonSatis)} ${c('gün')}` : '—'}</b>
        <small>{c('Son tahsilat')} {kisaTarih(o?.sonTahsilat)}</small></div>
    </div>
  );
}

// ------------------------------------------------------------- yan panel ----
export function CariYanPanel({ id, tazele, git, gitKart }: { id: number; tazele: number; git(yol: string): void; gitKart(yol: string): void }) {
  const { veri } = useCariKartOzeti(id, tazele);
  const [kisiler, setKisiler] = useState<ListeSatiri[] | null>(null);
  const [olaylar, setOlaylar] = useState<ListeSatiri[] | null>(null);
  useEffect(() => {
    api.liste('kisi', { sayfa: 1, boyut: 3, filtre: { alan: 'bagId', op: 'esit', deger: id } })
       .then(y => setKisiler(y.satirlar)).catch(() => setKisiler([]));
    api.liste('cari-ekstre', { sayfa: 1, boyut: 5, filtre: { alan: 'tarafId', op: 'esit', deger: id },
                               sirala: [{ alan: 'islemTarihi', yon: 'desc' }] })
       .then(y => setOlaylar(y.satirlar)).catch(() => setOlaylar([]));
  }, [id, tazele]);
  const y = veri?.yaslandirma;
  const toplam = y ? y.gelmemis + y.d30 + y.d60 + y.d90 : 0;
  const pay = (n: number) => `${toplam > 0 ? (n / toplam) * 100 : 0}%`;
  return (
    <div className="pl-oniz">
      <div className="pl-bl"><h5>{c('Dikkat')}</h5>
        {!veri ? <div className="sonuk">{c('yükleniyor')}…</div>
          : veri.uyarilar.length === 0 ? <div className="sonuk">{c('Dikkat gerektiren durum yok.')}</div>
          : veri.uyarilar.map((u, i) => <div key={i} className={`mk-uyari mk-uyari-${u.seviye}`}>{u.seviye === 'kirmizi' ? '⛔' : '⚠'} {u.metin}</div>)}
      </div>
      {veri?.ozet.notlar && (
        <div className="pl-bl"><h5>{c('Not')}</h5>
          <div className="mk-not">{veri.ozet.notlar}</div></div>
      )}
      {y && toplam > 0.005 && (
        <div className="pl-bl"><h5>{c('Yaşlandırma')}</h5>
          <div className="mk-yasl">
            <i style={{ width: pay(y.gelmemis), background: '#9cc4ee' }} />
            <i style={{ width: pay(y.d30), background: '#e0a33a' }} />
            <i style={{ width: pay(y.d60), background: '#d9783a' }} />
            <i style={{ width: pay(y.d90), background: '#c0413d' }} />
          </div>
          <div className="mk-yl">
            <span>{c('Gelmemiş')}<b>{para.format(y.gelmemis)}</b></span><span>0–30<b>{para.format(y.d30)}</b></span>
            <span>31–60<b>{para.format(y.d60)}</b></span><span>60+<b className="ml-borc">{para.format(y.d90)}</b></span>
          </div>
        </div>
      )}
      {veri && veri.ozet.ciroEgri && veri.ozet.ciroEgri.split(',').some(x => Number(x)) && (
        <div className="pl-bl"><h5>{c('Satış eğilimi (12 ay)')} · {para.format(veri.ozet.ciro12Ay)}</h5>
          <Egri degerler={veri.ozet.ciroEgri.split(',').map(Number)} genislik={250} yukseklik={36} /></div>
      )}
      <div className="pl-bl"><h5>{c('Ana kişiler')}</h5>
        {kisiler === null ? <div className="sonuk">…</div> : kisiler.length === 0 ? <div className="sonuk">{c('İlgili kişi yok.')}</div>
          : kisiler.map(k => (
            <div key={String(k.id)} className="mk-kisi" onDoubleClick={() => gitKart(`/kisi/${k.id}`)} title={c('Çift tıkla: kişi kartı')}>
              <Avatar ad={String(k.unvan ?? '')} />
              <span><b>{String(k.unvan ?? '')}</b><small>{[k.gorev, k.cepTel || k.telefon, k.eposta].filter(Boolean).join(' · ')}</small></span>
            </div>
          ))}
      </div>
      <div className="pl-bl"><h5>{c('Son olaylar')}
        <button type="button" className="pl-bag" onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>{c('Ekstre')} ›</button></h5>
        {olaylar === null ? <div className="sonuk">…</div> : olaylar.length === 0 ? <div className="sonuk">{c('Hareket yok.')}</div>
          : <div className="mk-zaman">{olaylar.map(o => {
              const b = Number(o.borc ?? 0), a = Number(o.alacak ?? 0);
              return (
                <div key={String(o.id)} className={a ? 'mk-z-ok' : ''}>
                  {String(o.turAdi ?? '')}{o.belgeNo ? ` ${o.belgeNo}` : ''} · {para.format(b || a)}{o.dovizCinsi && o.dovizCinsi !== 'TL' ? ` ${o.dovizCinsi}` : ''}
                  <small>{kisaTarih(String(o.islemTarihi ?? ''))}{o.aciklama ? ` · ${o.aciklama}` : ''}</small>
                </div>
              );
            })}</div>}
      </div>
    </div>
  );
}

// ------------------------------------------------------ devir sorusu ----
/**
 * YENİ KART KAYDEDİLDİ (mockup cari_devir_girisi.html › 1): kayıttan sonra kart `?devirSor=1` ile
 * açık kalır ve bir kez sorar. "Bakiyesi yok" / "Sonra" parametreyi kaldırır - kalıcı giriş yeri
 * Finansal sekmesi.
 */
export function CariDevirSorusu({ id, onDegisti }: { id: number; onDegisti(): void }) {
  const [arama, setArama] = useSearchParams();
  const { yetki } = useOturum();
  const [acik, setAcik] = useState(false);
  if (arama.get('devirSor') !== '1' || !yetki('finans.devir', 'ekle')) return null;
  const kapat = () => { const y = new URLSearchParams(arama); y.delete('devirSor'); setArama(y, { replace: true }) };
  return (
    <div className="mk-soru">
      <span className="mk-soru-ic">💼</span>
      <div><b>{c('Bu carinin açılış bakiyesi var mı?')}</b>
        <span>{c('Firma bizimle daha önce çalışıyorduysa (eski programda ya da elle tutulan hesapta) devreden borç / alacağını şimdi girin — ekstre, vadesi geçen, risk ve cari icmali bu tutardan başlar.')}</span></div>
      <button type="button" className="d bir" onClick={() => setAcik(true)}>＋ {c('Devir Bakiyesi Gir')}</button>
      <button type="button" className="d" onClick={kapat}>{c('Bakiyesi yok')}</button>
      <button type="button" className="d" onClick={kapat}>{c('Sonra')}</button>
      {acik && <CariDevirPenceresi tarafId={id} onKapat={() => setAcik(false)} onKaydedildi={() => { kapat(); onDegisti() }} />}
    </div>
  );
}

// ----------------------------------------------------------- Finansal ----
export function CariFinansal({ id, tazele, onDegisti }: { id: number; tazele: number; onDegisti?(): void }) {
  const { veri, hata } = useCariKartOzeti(id, tazele);
  const { yetki } = useOturum();
  const [belge, setBelge] = useState<number | null>(null);
  const [devir, setDevir] = useState(false);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">{c('Yükleniyor')}…</div>;
  const y = veri.yaslandirma;
  const toplam = y.gelmemis + y.d30 + y.d60 + y.d90;
  const yerelToplam = veri.dovizler.reduce((t, d) => t + Number(d.yerel), 0);
  const pay = (n: number) => `${toplam > 0 ? (n / toplam) * 100 : 0}%`;
  // TEDARİKÇİ (1162): ödeme yaşlandırması (vadesi geçen / 30 gün / sonrası) ve verilen çekler.
  const ted = Number(veri.ozet.tedarikci) === 1 && Number(veri.ozet.musteri) !== 1;
  const oy = veri.odemeYaslandirma;
  const oyToplam = oy.gecen + oy.d30 + oy.sonra;
  const oyPay = (n: number) => `${oyToplam > 0 ? (n / oyToplam) * 100 : 0}%`;
  return (
    <div className="mk-finans">
      <div className="kagrup"><h6 style={{ display: 'flex', alignItems: 'center' }}>{c('Hesap Özeti')}
        {/* DEVİR / AÇILIŞ BAKİYESİ (cari_devir_girisi.html): kartta kalıcı giriş yeri. */}
        {yetki('finans.devir', 'gor') && (
          <button type="button" className="d mini" style={{ marginLeft: 'auto' }} onClick={() => setDevir(true)}>
            💼 {c('Devir / Açılış Bakiyesi')}</button>
        )}</h6>
        <table className="detay-tablo">
          <thead><tr><th>{c('Para birimi')}</th><th className="hiza-sag">{c('Borç')}</th><th className="hiza-sag">{c('Alacak')}</th>
            <th className="hiza-sag">{c('Bakiye')}</th><th className="hiza-sag">{c('TL karşılığı')}</th></tr></thead>
          <tbody>
            {veri.dovizler.length === 0 && <tr><td colSpan={5} className="bos">{c('Hareket yok.')}</td></tr>}
            {veri.dovizler.map(d => (
              <tr key={d.doviz}><td>{d.doviz}</td><td className="hiza-sag">{para.format(d.borc)}</td>
                <td className="hiza-sag">{para.format(d.alacak)}</td>
                <td className={`hiza-sag ${d.bakiye > 0.005 ? 'ml-borc' : d.bakiye < -0.005 ? 'ml-alacak' : ''}`}>
                  {para.format(Math.abs(d.bakiye))}{isaret(d.bakiye)}</td>
                <td className="hiza-sag">{para.format(d.yerel)}</td></tr>
            ))}
          </tbody>
          <tfoot><tr className="genel"><td colSpan={4}>{c('Toplam (TL karşılığı)')}</td>
            <td className="hiza-sag"><b>{para.format(Math.abs(yerelToplam))}{isaret(yerelToplam)}</b></td></tr></tfoot>
        </table>
        <div className="not">{c('Son tahsilat')}: {kisaTarih(veri.ozet.sonTahsilat)}</div>
      </div>

      {ted && (
        <div className="kagrup"><h6>{c('Ödeme Yaşlandırması')}</h6>
          {oyToplam < 0.005 ? <div className="sonuk">{c('Ödenecek açık alış belgesi yok.')}</div> : (<>
            <div className="mk-yasl mk-yasl-buyuk">
              <i style={{ width: oyPay(oy.gecen), background: '#c0413d' }} /><i style={{ width: oyPay(oy.d30), background: '#e0a33a' }} />
              <i style={{ width: oyPay(oy.sonra), background: '#9cc4ee' }} />
            </div>
            <div className="mk-yl">
              <span>{c('Vadesi geçen')}<b className="ml-borc">{para.format(oy.gecen)}</b></span><span>{c('30 gün içinde')}<b>{para.format(oy.d30)}</b></span>
              <span>{c('30+ gün')}<b>{para.format(oy.sonra)}</b></span>
            </div>
          </>)}
          {veri.vadesiGecenOdemeler.length > 0 && (
            <table className="detay-tablo" style={{ marginTop: 10 }}>
              <thead><tr><th>{c('Vadesi geçen belge')}</th><th>{c('Tarih')}</th><th>{c('Vade')}</th>
                <th className="hiza-orta">{c('Gecikme')}</th><th className="hiza-sag">{c('Kalan')}</th></tr></thead>
              <tbody>{veri.vadesiGecenOdemeler.map((g, i) => (
                <tr key={i} onDoubleClick={() => g.belgeId && setBelge(g.belgeId)} title={g.belgeId ? c('Çift tıkla: belgeyi aç') : undefined}>
                  <td>{g.turAdi} <b>{g.belgeNo}</b></td><td>{kisaTarih(g.tarih)}</td><td>{kisaTarih(g.vade)}</td>
                  <td className={`hiza-orta ${g.gecikme > 60 ? 'ml-borc' : ''}`}>{sayi.format(g.gecikme)} {c('gün')}</td>
                  <td className="hiza-sag">{para.format(g.kalan)}</td></tr>
              ))}</tbody>
            </table>
          )}
          <div className="not">{c('Ödeme önce vadesi en eski borcumuzu kapatır; vade = alış belgesinin vadesi, yoksa işlem tarihi + Satınalma Koşulları vade günü.')}</div>
        </div>
      )}
      {ted && (
        <div className="kagrup"><h6>{c('Verilen Çekler')}</h6>
          {veri.verilenCekler.length === 0 ? <div className="sonuk">{c('Ödenmemiş verilen çek / senet yok.')}</div> : (
            <table className="detay-tablo">
              <thead><tr><th>{c('Tür')}</th><th>{c('Seri No')}</th><th>{c('Banka')}</th><th>{c('Vade')}</th><th className="hiza-sag">{c('Tutar')}</th></tr></thead>
              <tbody>{veri.verilenCekler.map(k => (
                <tr key={k.id}><td>{k.tur === 2 ? c('Senet') : c('Çek')}</td><td>{k.seriNo}</td><td>{k.banka}</td><td>{kisaTarih(k.vade)}</td>
                  <td className="hiza-sag">{para.format(k.tutar)}{k.doviz && k.doviz !== 'TL' ? ` (${para.format(k.dovizTutar)} ${k.doviz})` : ''}</td></tr>
              ))}</tbody>
            </table>
          )}
        </div>
      )}

      <div className="kagrup"><h6>{ted ? c('Alacak Yaşlandırması (iade / avans)') : c('Yaşlandırma')}</h6>
        {toplam < 0.005 ? <div className="sonuk">{c('Açık borç yok.')}</div> : (<>
          <div className="mk-yasl mk-yasl-buyuk">
            <i style={{ width: pay(y.gelmemis), background: '#9cc4ee' }} /><i style={{ width: pay(y.d30), background: '#e0a33a' }} />
            <i style={{ width: pay(y.d60), background: '#d9783a' }} /><i style={{ width: pay(y.d90), background: '#c0413d' }} />
          </div>
          <div className="mk-yl">
            <span>{c('Vadesi gelmemiş')}<b>{para.format(y.gelmemis)}</b></span><span>0–30 {c('gün')}<b>{para.format(y.d30)}</b></span>
            <span>31–60 {c('gün')}<b>{para.format(y.d60)}</b></span><span>60+ {c('gün')}<b className="ml-borc">{para.format(y.d90)}</b></span>
          </div>
        </>)}
        {veri.vadesiGecenler.length > 0 && (
          <table className="detay-tablo" style={{ marginTop: 10 }}>
            <thead><tr><th>{c('Vadesi geçen belge')}</th><th>{c('Tarih')}</th><th>{c('Vade')}</th>
              <th className="hiza-orta">{c('Gecikme')}</th><th className="hiza-sag">{c('Kalan')}</th></tr></thead>
            <tbody>{veri.vadesiGecenler.map((g, i) => (
              <tr key={i} onDoubleClick={() => g.belgeId && setBelge(g.belgeId)} title={g.belgeId ? c('Çift tıkla: belgeyi aç') : undefined}>
                <td>{g.turAdi} <b>{g.belgeNo}</b></td><td>{kisaTarih(g.tarih)}</td><td>{kisaTarih(g.vade)}</td>
                <td className={`hiza-orta ${g.gecikme > 60 ? 'ml-borc' : ''}`}>{sayi.format(g.gecikme)} {c('gün')}</td>
                <td className="hiza-sag">{para.format(g.kalan)}</td></tr>
            ))}</tbody>
          </table>
        )}
        <div className="not">{c('Tahsilat önce vadesi en eski borcu kapatır; vade = belgenin vade tarihi, yoksa işlem tarihi + carinin vade günü.')}</div>
      </div>

      <div className="kagrup"><h6>{c('Çek / Senet Portföyü')}</h6>
        {veri.cekler.length === 0 ? <div className="sonuk">{c('Portföyde, tahsilde ya da teminatta müşteri çeki yok.')}</div> : (
          <table className="detay-tablo">
            <thead><tr><th>{c('Tür')}</th><th>{c('Seri No')}</th><th>{c('Banka / Keşideci')}</th><th>{c('Vade')}</th>
              <th>{c('Durum')}</th><th className="hiza-sag">{c('Tutar')}</th></tr></thead>
            <tbody>{veri.cekler.map(k => (
              <tr key={k.id}><td>{k.tur === 2 ? c('Senet') : c('Çek')}</td><td>{k.seriNo}</td><td>{k.banka}</td><td>{kisaTarih(k.vade)}</td>
                <td><span className={`rozet ${k.durum === 10 ? 'bilgi' : 'uyari'}`}>
                  {k.durum === 10 ? c('Portföyde') : k.durum === 30 ? c('Bankada Tahsilde') : c('Teminatta')}</span></td>
                <td className="hiza-sag">{para.format(k.tutar)}{k.doviz && k.doviz !== 'TL' ? ` (${para.format(k.dovizTutar)} ${k.doviz})` : ''}</td></tr>
            ))}</tbody>
          </table>
        )}
      </div>
      {belge !== null && <BelgeKarti id={belge} onKapat={() => setBelge(null)} />}
      {devir && <CariDevirPenceresi tarafId={id} onKapat={() => setDevir(false)} onKaydedildi={onDegisti} />}
    </div>
  );
}

// ----------------------------------------------------------- Belgeler ----
export function CariBelgeler({ id }: { id: number }) {
  const [belge, setBelge] = useState<number | null>(null);
  return (
    <>
      <GenGrid kaynak="belge" gomulu boyut={25}
               sabitFiltre={{ alan: 'tarafId', op: 'esit', deger: id }}
               kolonSirasi={['belgeTarihi', 'turAdi', 'belgeNo', 'genelToplam', 'kapanmaAdi', 'eBelgeDurumAdi']}
               gizliKolonlar={['tarafUnvan']}
               cipler={[
                 { ad: 'Tümü' },
                 { ad: 'Faturalar', filtre: { alan: 'tur', op: 'icinde', deger: [11, 15, 16, 17] } },
                 { ad: 'Siparişler', filtre: { alan: 'tur', op: 'icinde', deger: [9, 19] } },
                 { ad: 'Teklifler', filtre: { alan: 'tur', op: 'esit', deger: 18 } },
                 { ad: 'İrsaliyeler', filtre: { alan: 'tur', op: 'icinde', deger: [10, 14] } },
               ]}
               onSatirAc={s => setBelge(Number(s.id))} />
      <div className="not">{c('Belgeye çift tıkla: belge kartı açılır.')}</div>
      {belge !== null && <BelgeKarti id={belge} onKapat={() => setBelge(null)} />}
    </>
  );
}

// --------------------------------------------------------------- CRM ----
export function CariCrm({ id, gitKart }: { id: number; gitKart(yol: string): void }) {
  return (
    <>
      <div className="kagrup"><h6>{c('Görevler')}</h6>
        <GenGrid kaynak="gorev" gomulu boyut={10} seritGizli
                 sabitFiltre={{ alan: 'tarafId', op: 'esit', deger: id }}
                 gizliKolonlar={['cari']}
                 onSatirAc={s => gitKart(`/gorev/${s.id}`)} />
      </div>
      <div className="kagrup"><h6>{c('Satış Fırsatları')}</h6>
        <GenGrid kaynak="firsat" gomulu boyut={10} seritGizli
                 sabitFiltre={{ alan: 'tarafId', op: 'esit', deger: id }}
                 gizliKolonlar={['tarafUnvan']}
                 onSatirAc={s => gitKart(`/firsat/${s.id}`)} />
      </div>
    </>
  );
}

// ---------------------------------------------------- hızlı işlemler ----
type Acik = { tur: 'belge'; belgeTuru: number } | { tur: 'tahsilat' };

export function CariHizliIslemler({ id, ad, yetki, tazele }: {
  id: number; ad: string; yetki(kod: string, islem?: 'gor' | 'ekle' | 'degistir' | 'sil'): boolean; tazele(): void;
}) {
  const [acik, setAcik] = useState<Acik | null>(null);
  const kapat = () => { setAcik(null); tazele() };
  const belge = yetki('belge', 'ekle');
  return (
    <>
      {belge && <button type="button" className="d" onClick={() => setAcik({ tur: 'belge', belgeTuru: 15 })}>🧾 {c('Satış Faturası')}</button>}
      {belge && <button type="button" className="d" onClick={() => setAcik({ tur: 'belge', belgeTuru: 19 })}>📝 {c('Sipariş')}</button>}
      {belge && <button type="button" className="d" onClick={() => setAcik({ tur: 'belge', belgeTuru: 18 })}>📋 {c('Teklif')}</button>}
      {yetki('kasa_islem', 'ekle') && <button type="button" className="d" onClick={() => setAcik({ tur: 'tahsilat' })}>💰 {c('Tahsilat')}</button>}
      {acik?.tur === 'belge' && <BelgeKarti tur={acik.belgeTuru} tarafId={id} tarafUnvan={ad} onKapat={kapat} onKaydedildi={tazele} />}
      {/* 21 = nakit tahsilat; kartta tür şeridinden banka / POS / çek seçilir. */}
      {acik?.tur === 'tahsilat' && <KasaIslemKarti acilis={{ tur: 21, tarafId: id, tarafUnvan: ad }} onKapat={kapat} onKaydedildi={tazele} />}
    </>
  );
}
