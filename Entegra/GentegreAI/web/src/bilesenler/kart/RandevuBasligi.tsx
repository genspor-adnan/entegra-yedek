import { useEffect, useState, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { basHarfler } from '../basHarfler';
import type { KartMetaYaniti } from '../../api/sozlesme';
import { anGirdiMetni } from '../bicim';
import { c } from '../../dil/ceviri';
import type { Deger } from '../kartAlanCizim';

/**
 * RANDEVU KARTI BAŞLIĞI (mockup Ekranlar/Randevu/randevu_karti_baslik.html; kullanıcı 19.11.2026: "hasta arama/seçme
 * kısmı şu an iyi onu değiştirmeden diğer kısımları yap.. view/edit mode olarak da uygula").
 *
 *  * Solda HASTA BANDI (kullanıcı 19.11.2026: "hasta adı için mockup gibi avatar yap.. hasta adı edit modda olmasın
 *    mockup başlık gibi gelsin aynısı"): avatar (baş harfler, cinsiyet rengi), ad + dosya no + "↗ hasta kartı", altında
 *    TC (maskeli) · cinsiyet · yaş · telefon · kurum. Hasta seçiliyse İKİ KİPTE DE bant - arama kutusu yalnız hasta
 *    yokken (yeni randevu); yeni randevuyu düzenlerken hasta değiştirmek için arama kutusu alt satırda da durur.
 *  * Sağda üç kutu: RANDEVU (saat aralığı büyük; gün, "bugün / yarın / n gün sonra / geçti", süre), DOKTOR ya da
 *    CİHAZ (altında bölüm / doktor), DURUM (renkli rozet + SMS). Sol kenar çizgisi durumun rengi (liste ile aynı).
 *  * ✎ tüm kartı açar / kapatır (GenForm kipli kart). Tarih / saat, süre ve durum kutuları yalnız düzenlemede,
 *    bandın altında. Başvuruya dönüşmüş randevu kilitli (✎ pasif) - iz şeridi başvuruyu gösterir.
 */
const GUN = ['Paz', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt'];

/** Hasta listesinin tek satırı (bant bilgisi) - liste ucu bütün kolonları döner. */
function useHastaSatiri(hastaId: number) {
  const [h, setH] = useState<Record<string, unknown> | null>(null);
  useEffect(() => {
    if (!(hastaId > 0)) { setH(null); return }
    let iptal = false;
    Promise.resolve().then(() => api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: hastaId } }))
      .then(y => { if (!iptal) setH(y.satirlar[0] ?? null) })
      .catch(() => { if (!iptal) setH(null) });
    return () => { iptal = true };
  }, [hastaId]);
  return h;
}
const tcMaske = (v: string) => (v.length >= 11 ? `${v.slice(0, 3)}******${v.slice(-2)}` : v);

function HastaBandi({ hastaId, h, yedekAd }: { hastaId: number; h: Record<string, unknown> | null; yedekAd: string }) {
  const git = useNavigate();
  const ad = String(h?.unvan ?? '') || yedekAd;
  const cins = Number(h?.cinsiyet ?? 0);
  const yas = String(h?.yasKisa ?? '') || (h?.yas != null && h.yas !== '' ? `${String(h.yas)} ${c('yaş')}` : '');
  const tel = String(h?.cepTel ?? h?.telefon ?? '');
  const alt = [
    String(h?.vkno ?? '') && `TC ${tcMaske(String(h?.vkno))}`,
    [cins === 1 ? 'E' : cins === 2 ? 'K' : '', yas].filter(Boolean).join(' · '),
    tel && `☎ ${tel}`,
    String(h?.kurum ?? h?.kurumAdi ?? ''),
  ].filter(Boolean);
  return (
    <div className="rv-hasta" data-testid="randevu-hasta-bandi">
      <span className={`rv-avatar${cins === 2 ? ' k' : ''}`}>{basHarfler(ad) || '?'}</span>
      <div className="rv-kim">
        <div className="rv-ad">{ad || '—'}
          {String(h?.kod ?? '') && <span className="rv-kod">{String(h?.kod)}</span>}
          <a href={`/hasta/${hastaId}`} onClick={e => { e.preventDefault(); git(`/hasta/${hastaId}`) }}>↗ {c('hasta kartı')}</a>
        </div>
        <div className="rv-hasta-alt">{alt.map((x, i) => <span key={i}>{x}</span>)}
          {h && !tel && <span className="uyari">☎ {c('cep telefonu yok')}</span>}</div>
      </div>
    </div>
  );
}
const DURUM_SINIF: Record<number, string> = { 1: 'planli', 2: 'geldi', 3: 'gelmedi', 4: 'iptal', 5: 'ertele' };

function zamanBilgisi(baslangic: unknown, sureDk: number) {
  const m = anGirdiMetni(baslangic).slice(0, 16);
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(m)) return null;
  const [g, s] = m.split('T');
  const [y, a, d] = g.split('-').map(Number);
  const [sa, dk] = s.split(':').map(Number);
  const bas = new Date(y, a - 1, d, sa, dk);
  const bit = new Date(bas.getTime() + Math.max(0, sureDk) * 60000);
  const p2 = (n: number) => String(n).padStart(2, '0');
  const bugun = new Date(); bugun.setHours(0, 0, 0, 0);
  const fark = Math.round((new Date(y, a - 1, d).getTime() - bugun.getTime()) / 86400000);
  const goreli = fark === 0 ? c('bugün') : fark === 1 ? c('yarın') : fark === -1 ? c('dün')
               : fark > 1 ? `${fark} ${c('gün sonra')}` : `${-fark} ${c('gün önce')}`;
  return {
    aralik: `${p2(sa)}:${p2(dk)} – ${p2(bit.getHours())}:${p2(bit.getMinutes())}`,
    alt: `${c(GUN[bas.getDay()])} ${p2(d)}.${p2(a)}.${y} · ${goreli}${sureDk ? ` · ${sureDk} dk` : ''}`,
    gecti: fark < 0,
  };
}

export function RandevuBasligi({ deger, meta, salt, gosterKipi, yeniMi, hastaAlani, digerAlanlar, onKalem }: {
  deger: Record<string, Deger>;
  meta: KartMetaYaniti | null | undefined;
  salt: boolean;
  /** Görüntüleme kipi (✎ kapalı ya da yetki yok). */
  gosterKipi: boolean;
  yeniMi: boolean;
  /** Hasta arama / seçme alanı - bugünkü bileşen (renderAlanListesi); yalnız hasta yokken / yeni randevuda. */
  hastaAlani: ReactNode;
  /** Tarih / saat, süre, durum - yalnız düzenlemede. */
  digerAlanlar: ReactNode;
  onKalem(): void;
}) {
  const git = useNavigate();
  const hastaId = Number(deger.hastaId) || 0;
  const hastaSatiri = useHastaSatiri(hastaId);
  const ad = (alan: string) => {
    const v = String(deger[alan] ?? '');
    return v ? meta?.alanlar.find(a => a.ad === alan)?.kodlar?.[v] ?? '' : '';
  };
  const durum = Number(deger.durum ?? 1) || 1;
  const z = zamanBilgisi(deger.baslangic, Number(deger.sureDk) || 0);
  const cihazli = Number(deger.cihazId) > 0;
  const kaynakAd = cihazli ? ad('cihazId') : ad('hekimId');
  const kaynakAlt = cihazli ? (ad('hekimId') || ad('bolum')) : ad('bolum');
  const belgeId = Number(deger.belgeId) || 0;
  const kilitli = belgeId > 0;
  const sms = deger.smsGonder === true || Number(deger.smsGonder) === 1;

  return (
    <div className={`rv-baslik rv-d-${DURUM_SINIF[durum] ?? 'planli'}`} data-testid="randevu-basligi">
      <div className="rv-bant">
        {hastaId > 0
          ? <HastaBandi hastaId={hastaId} h={hastaSatiri} yedekAd={ad('hastaId')} />
          : <div className={`rv-bant-hasta${gosterKipi ? ' kaid-goster' : ''}`} inert={gosterKipi || undefined}>
              {hastaAlani}
            </div>}
        <div className="rv-kutular">
          <div className={`rv-kutu rv-kutu-zaman${z?.gecti && durum === 1 ? ' gecti' : ''}`}>
            <small>{c('Randevu')}</small>
            <b>{z?.aralik ?? '—'}</b>
            <i>{z?.alt ?? c('saat seçilmedi')}</i>
          </div>
          <div className="rv-kutu">
            <small>{cihazli ? c('Cihaz') : c('Doktor')}</small>
            <b>{kaynakAd || '—'}</b>
            <i>{kaynakAlt || ' '}</i>
          </div>
          <div className="rv-kutu rv-kutu-durum">
            <small>{c('Durum')}</small>
            <b><span className="rv-rozet">{ad('durum') || c('Planlandı')}</span></b>
            <i>{sms ? `📱 ${c('SMS açık')}` : c('SMS yok')}</i>
          </div>
          <button type="button" className={`bs-kalem rv-kalem${gosterKipi ? '' : ' acik'}`} data-testid="randevu-kalem"
                  disabled={salt || (kilitli && !yeniMi)}
                  title={salt ? c('Düzenleme yetkisi yok')
                         : kilitli ? c('Başvuruya dönüşmüş randevu değiştirilemez')
                         : gosterKipi ? c('Randevuyu düzenle') : c('Düzenlemeyi kapat')}
                  onClick={onKalem}>✎</button>
        </div>
      </div>
      {kilitli && (
        <div className="rv-iz">➜ {c('Başvuruya dönüştü')}:{' '}
          <a href={`/basvuru/${belgeId}`} onClick={e => { e.preventDefault(); git(`/basvuru/${belgeId}`) }}>
            {c('Başvuruyu aç')}</a></div>
      )}
      {!gosterKipi && (
        <div className="alan-izgara rv-alt-alanlar">
          {/* YENİ RANDEVUDA HASTA DEĞİŞTİRME: bant seçilen hastayı gösterir, arama kutusu burada. */}
          {yeniMi && hastaId > 0 && <div className="rv-hasta-degistir">{hastaAlani}</div>}
          {digerAlanlar}
        </div>
      )}
    </div>
  );
}
