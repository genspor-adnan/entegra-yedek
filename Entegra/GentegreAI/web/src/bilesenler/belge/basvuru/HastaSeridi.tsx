import { basHarfler } from '../../basHarfler';
import { useEffect, useState } from 'react';
import { api } from '../../../api/istemci';
import { paraYaz } from '../../bicim';
import { MUSTEHAKLIK } from './alanlar';
import { c } from '../../../dil/ceviri';
import { useMuayeneHastaBilgisi } from '../../MuayeneSekmesiz';

/**
 * SECILI HASTA SERIDI (298) - v3 (kullanici 27.10.2026, mockup Ekranlar/Kayıt Kabul/basvuru_hasta_bandi_v3.html):
 * TEK KAT, her hucre EN COK IKI SATIR, ince (46 px). Sira (kullanici): Kimlik · Odeyen Kurum (+ provizyon) ·
 * Izinler · Uyari · Durum · Acik Tahsilat · Acik Belge. Kabul boyunca ekranda kalir - memur hastayi, kimin
 * odedigini, provizyonu ve bekleyen isleri tek bakista gorsun.
 *
 * VERI UYDURULMAZ: izinlerde yalniz kaydi olanlar (KVKK acik riza = imzali 'kvkk_riza' formu; SMS / e-posta
 * izni hasta kaydindaki bayraklar). Uyari muayene bandinin kaynagindan (alerji, kronik, hasta uyarisi, ayni ad).
 * Durum: avans, baska acik basvuru, 65+ onceligi, e-Nabiz (USS) gonderimi - yalniz VARSA rozet.
 */
const PROVIZYON: Record<number, { ad: string; sinif: string }> = {
  0: { ad: '⚠ alınmadı', sinif: 'uyari' },
  1: { ad: '✓', sinif: 'olumlu' },
  2: { ad: '✗ reddedildi', sinif: 'teh' },
  3: { ad: '◐ kısmi onay', sinif: 'uyari' },
  4: { ad: 'iptal', sinif: 'gri' },
};

export function HastaSeridi({ tarafId, mustehaklik, acikBelge,
                              sysTakipNo, paylasimli, avans = 0,
                              kurumAdi, acikBorc, taraflar,
                              provizyon, belgeId, protokolNo }: {
  tarafId?: number | null;
  /** BELGENIN odeyen kurumu (kullanici): hastanin sigortasi degil, bu basvuruyu odeyecek kurum. */
  kurumAdi?: string;
  /** Bu BASVURUNUN acik borcu = ucretlendirme genel toplami - tahsilat. Verilmezse hastanin genel bakiyesi. */
  acikBorc?: number;
  /** ACIK BELGE (495): kovalarin faturaya/tahakkuka cevrilmemis kismi (sunucudan). */
  acikBelge?: number | null;
  /** PAYLASIMLI KURUMDA (ÖSS/SGK) tutarlar tarafa gore ikiye ayrilir: hastadan ve kurumdan. */
  taraflar?: {
    tahsilat: { hasta: number; kurum: number };
    belge: { hasta: number; kurum: number };
  } | null;
  /** Belgenin SGK mustehaklik durumu (299) - kurumun yanina rozet. */
  mustehaklik?: number | null;
  /** USS SYS TAKIP NO (608): paylasimli kurumda durum rozeti (gonderildi / gonderilmedi). */
  sysTakipNo?: string;
  /** ÖDEYEN KURUM PAYLASIMLI MI (ÖSS / SGK). */
  paylasimli?: boolean;
  /** HASTANIN ACIK AVANSI (781) - karttan; yalniz varsa durum rozeti. */
  avans?: number;
  /**
   * PROVIZYON (v3, kullanici: "ödeyen kurum kısmında provizyon durumu da"): kurum oderken provizyonun durumu
   * (kod listesi provizyon.durum) ve numarasi; null = hasta kendisi oder, provizyon gerekmez.
   */
  provizyon?: { durum: number; no: string } | null;
  /** Bu basvurunun kimligi - "baska acik basvuru" aranirken kendisi sayilmasin. */
  belgeId?: number | null;
  /** Basvurunun protokol (belge) numarasi - kimlik satirinda. */
  protokolNo?: string;
}) {
  const [h, setH] = useState<Record<string, unknown> | null>(null);
  const [kvkk, setKvkk] = useState<string | null>(null);
  const [acikBasvuru, setAcikBasvuru] = useState<{ id: number; tarih: string } | null>(null);
  const bant = useMuayeneHastaBilgisi(0, 0, tarafId ?? 0);

  useEffect(() => {
    if (!tarafId) { setH(null); setKvkk(null); setAcikBasvuru(null); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: tarafId } });
        if (!iptal) setH(y.satirlar[0] ?? null);
      } catch { if (!iptal) setH(null) }
      // KVKK ACIK RIZA: imzali (tamamlanmis) 'kvkk_riza' formu - form motoru (740).
      try {
        const f = await api.liste('form-istek', { sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [{ alan: 'hastaId', op: 'esit', deger: tarafId },
                                          { alan: 'sablonKod', op: 'esit', deger: 'kvkk_riza' }] },
          sirala: [{ alan: 'tamamlanma', yon: 'desc' }] });
        const t = f.satirlar[0]?.tamamlanma;
        if (!iptal) setKvkk(t ? String(t).slice(0, 10).split('-').reverse().join('.') : '');
      } catch { if (!iptal) setKvkk(null) }
      // BASKA ACIK BASVURU (KomutPaleti / Liste.basvuruAc ile ayni kural): tamamlanmamis en yeni basvuru.
      try {
        const b = await api.liste('belge', { sayfa: 1, boyut: 2,
          sirala: [{ alan: 'belgeTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'tarafId', op: 'esit', deger: tarafId }, { alan: 'tur', op: 'esit', deger: 19 },
            { alan: 'tipi', op: 'esit', deger: 30 }, { alan: 'tamamlanma', op: 'kucuk', deger: 100 }] } });
        const r = b.satirlar.find(x => Number(x.id) !== Number(belgeId ?? 0));
        if (!iptal) setAcikBasvuru(r ? { id: Number(r.id), tarih: String(r.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.') } : null);
      } catch { if (!iptal) setAcikBasvuru(null) }
    })();
    return () => { iptal = true };
  }, [tarafId, belgeId]);

  if (!tarafId) return null;

  const ad = String(h?.unvan ?? '');
  const cinsiyetAdi = String(h?.cinsiyetAdi ?? '');
  // İKONSUZ, "y"siz (kullanıcı 28.10.2026: "cinsiyet ikonu ve yaşı simgeleyen y harfini kaldır"): "E · 69".
  const cinsiyet = cinsiyetAdi.startsWith('E') ? 'E' : cinsiyetAdi.startsWith('K') ? 'K' : '';
  const borc = acikBorc != null ? acikBorc : Number(h?.acikBorc ?? 0);
  const dogum = String(h?.dogumTarihi ?? '').slice(0, 10);
  const yas = h?.yas != null && h.yas !== '' ? Number(h.yas) : null;
  const kimlik2 = [[cinsiyet, yas != null ? String(yas) : ''].filter(Boolean).join(' · '),
                   dogum ? dogum.split('-').reverse().join('.') : '',
                   // D / P önekleri yok (kullanıcı 28.10.2026): numaralar kendi biçiminden tanınıyor (H-… / P-…).
                   h?.kod ? String(h.kod) : '', protokolNo || ''].filter(Boolean).join(' · ');

  // UYARI: alerji (kirmizi), kronik (sari), hasta uyarisi - en cok 2 rozet + "+n" (tamami ipucunda).
  const uyarilar: { ad: string; sinif: string; ipucu?: string }[] = [];
  if (bant) {
    if (bant.alerji.length > 0)
      uyarilar.push({ ad: `⚠ ${String(bant.alerji[0].etken ?? bant.alerji[0].etkenMadde ?? '')}${bant.alerji.length > 1 ? ` +${bant.alerji.length - 1}` : ''}`,
                      sinif: 'hata', ipucu: bant.alerji.map(a => String(a.etken ?? a.etkenMadde ?? '')).join(', ') });
    for (const k of bant.kronik) uyarilar.push({ ad: String(k.taniAd ?? k.icdKod ?? ''), sinif: 'uyari' });
    if (String(bant.ust?.uyari ?? '').trim()) uyarilar.push({ ad: String(bant.ust?.uyari), sinif: 'uyari' });
    if (Number(bant.band.ayniAd ?? 0) > 0) uyarilar.push({ ad: `${c('Aynı ad')} ×${bant.band.ayniAd}`, sinif: 'gri' });
  }

  // DURUM: yalniz varsa.
  const durumlar: { ad: string; sinif: string; ipucu?: string }[] = [];
  if (avans > 0) durumlar.push({ ad: `${c('Avans')} ${paraYaz(avans)}`, sinif: 'olumlu',
                                 ipucu: c('Hastanın kullanılmamış avansı — Tahsilat sekmesinden bu başvuruya mahsup edilir.') });
  if (acikBasvuru) durumlar.push({ ad: `📂 ${c('Açık başvuru')} ${acikBasvuru.tarih}`, sinif: 'uyari',
                                   ipucu: c('Bu hastanın kapanmamış başka başvurusu var') });
  if (yas != null && yas >= 65) durumlar.push({ ad: '♿ 65+', sinif: 'bilgi', ipucu: c('65 yaş üstü - öncelikli') });
  if (paylasimli) durumlar.push(sysTakipNo
    ? { ad: `USS ✓`, sinif: 'olumlu', ipucu: `e-Nabız SYS Takip No: ${sysTakipNo}` }
    : { ad: `USS ${c('gönderilmedi')}`, sinif: 'gri', ipucu: c('Başvuru e-Nabız\'a (USS) henüz gönderilmedi') });

  const rozetler = (l: { ad: string; sinif: string; ipucu?: string }[], bos: string) => (
    <span className="hs3-roz" title={l.length > 2 ? l.map(x => x.ad).join(' · ') : undefined}>
      {l.length === 0 ? <span className="hs3-bos">{bos}</span> : <>
        {l.slice(0, 2).map((x, i) => <span key={i} className={`rozet ${x.sinif}`} title={x.ipucu}>{x.ad}</span>)}
        {l.length > 2 && <span className="rozet gri">+{l.length - 2}</span>}
      </>}
    </span>
  );
  const izin = (ad: string, d: '✓' | '✗' | '?', ipucu: string) => (
    <span title={ipucu}><b className={d === '✓' ? 'iz-v' : d === '✗' ? 'iz-y' : 'iz-b'}>{d}</b>{ad}</span>
  );
  const smsIzin = Number(h?.postaIzin ?? 0) === 1, epostaIzin = Number(h?.epostaIzin ?? 0) === 1;
  const prov = provizyon ? PROVIZYON[provizyon.durum] ?? PROVIZYON[0] : null;

  return (
    <div className="hasta-serit hs3">
      {/* KIMLIK: ad / cinsiyet · yas · dogum · dosya · protokol. */}
      <span className="hs hs3-kimlik">
        <span className="avatar">{basHarfler(ad) || '—'}</span>
        <span className="hs3-kim">
          <span className="hs3-ad">{ad || '—'}</span>
          <span className="hs3-s2">{kimlik2 || '—'}</span>
        </span>
      </span>
      {/* ÖDEYEN KURUM + PROVIZYON (kullanici): etiket ustte, kurum + provizyon altta tek satir. */}
      <span className="hs">
        <span className="k">Ödeyen Kurum</span>
        <span className="v">
          {kurumAdi || String(h?.sigortaAdi ?? '') || '—'}
          {mustehaklik != null && mustehaklik > 0 && (
            <span className={`rozet ${MUSTEHAKLIK[mustehaklik]?.sinif ?? ''}`}>{MUSTEHAKLIK[mustehaklik]?.ad}</span>
          )}
          {prov
            ? <span className={`rozet ${prov.sinif}`} title={c('Provizyon')}>
                {c('Prov.')} {prov.ad}{provizyon?.no && provizyon.durum !== 0 ? ` ${provizyon.no}` : ''}</span>
            : <span className="hs3-bos" title={c('Hasta kendisi öder - provizyon alınmaz')}> · {c('prov. gerekmez')}</span>}
        </span>
      </span>
      {/* IZINLER: yalniz kaydi olanlar. ? = sorulmadi / kayit yok. */}
      <span className="hs">
        <span className="k">{c('İzinler')}</span>
        <span className="hs3-izin">
          {izin('KVKK', kvkk ? '✓' : '?', kvkk ? `KVKK açık rıza formu imzalı (${kvkk})` : 'KVKK açık rıza formu imzalanmamış')}
          {izin('SMS', smsIzin ? '✓' : '?', smsIzin ? 'SMS / posta izni var' : 'SMS / posta izni kayıtlı değil')}
          {izin('E-posta', epostaIzin ? '✓' : '?', epostaIzin ? 'E-posta izni var' : 'E-posta izni kayıtlı değil')}
        </span>
      </span>
      <span className="hs">
        <span className="k">{c('Uyarı')}</span>
        {uyarilar.length === 0 && bant && bant.alerji.length === 0
          ? <span className="hs3-roz"><span className="rozet olumlu">{c('Alerji: yok')}</span></span>
          : rozetler(uyarilar, '—')}
      </span>
      <span className="hs">
        <span className="k">{c('Durum')}</span>
        {rozetler(durumlar, '—')}
      </span>
      {/* ACIK TAHSILAT / ACIK BELGE: paylasimli kurumda iki satir (hastadan / kurumdan). */}
      {taraflar ? (
        <span className="hs sag ikili-taraf">
          <span className="k">{c('Açık Tahsilat')}</span>
          <span className="taraf-satir">
            <span className="ikon" title={c('Hastadan')}>👤</span>
            <span className={`v ${taraflar.tahsilat.hasta > 0 ? 'teh' : 'olumlu'}`}>{paraYaz(taraflar.tahsilat.hasta)}</span>
            <span className="ikon" title={c('Kurumdan')}>🏛️</span>
            <span className={`v ${taraflar.tahsilat.kurum > 0 ? 'teh' : 'olumlu'}`}>{paraYaz(taraflar.tahsilat.kurum)}</span>
          </span>
        </span>
      ) : (
        <span className="hs sag">
          {/* Ucret > tahsilat KIRMIZI "Açık Tahsilat", tahsilat > ucret YESIL "Alacaklı", esit notr. */}
          <span className="k">{borc < 0 ? 'Alacaklı' : 'Açık Tahsilat'}</span>
          <span className={`v ${borc > 0 ? 'teh' : borc < 0 ? 'olumlu' : ''}`}>{paraYaz(Math.abs(borc))}</span>
        </span>
      )}
      {taraflar ? (
        <span className="hs sag ikili-taraf">
          <span className="k">{c('Açık Belge')}</span>
          <span className="taraf-satir">
            <span className="ikon" title={c('Hastaya kesilecek')}>👤</span>
            <span className={`v ${taraflar.belge.hasta > 0 ? 'teh' : 'olumlu'}`}>{paraYaz(taraflar.belge.hasta)}</span>
            <span className="ikon" title={c('Kuruma kesilecek')}>🏛️</span>
            <span className={`v ${taraflar.belge.kurum > 0 ? 'teh' : 'olumlu'}`}>{paraYaz(taraflar.belge.kurum)}</span>
          </span>
        </span>
      ) : (
        <span className="hs sag">
          <span className="k">{c('Açık Belge')}</span>
          <span className={`v ${Number(acikBelge ?? 0) > 0 ? 'teh' : 'olumlu'}`}>{paraYaz(Number(acikBelge ?? 0))}</span>
        </span>
      )}
    </div>
  );
}

// ============================================================ BASVURU ====
