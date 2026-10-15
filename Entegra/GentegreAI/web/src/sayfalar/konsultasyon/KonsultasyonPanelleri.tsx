import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { KonsultasyonOnizleme, KonsultasyonOzet } from '../../api/uclar/konsultasyon';
import { tarihSaat } from '../../bilesenler/bicim';
import { LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { c } from '../../dil/ceviri';
import { KonsultasyonIslemPenceresi, type KonsIslem } from './KonsultasyonIslemPenceresi';

/**
 * KONSÜLTASYON LİSTESİ PANELLERİ (1107) - mockup Ekranlar/Muayene/konsultasyon_listesi.html.
 *
 *   useKonsultasyonSuzgeci · KonsultasyonUstPanel (sekmeler + özet kutuları) ·
 *   KonsultasyonOnizlemePaneli (seçili istemin "neden çağrıldım"ı + geçmiş).
 *
 * Sekme süzgeci sunucunun verdiği kullanıcı ve bölümleriyle kurulur (istemci kural
 * yazmaz; "bana / bölümüme gelen" hedef hekim ya da hekimsiz bölüm). Terim "yanıtla".
 */
export type KonsSekme = 'gelen' | 'istedigim' | 'bolum';
type KonsKutu = 'suresiGecen' | 'yanitBekleyen' | 'yanitladiklarim' | 'bugunYanitlanan' | 'disMerkez';

/** Liste aksiyonundan pencere açma isteği (yönlendir / reddet) - paneldeki pencere dinler. */
export const KONS_ISLEM_OLAYI = 'gentegre-kons-islem';

export const KONS_ACILIYET: Record<number, string> = { 1: 'Rutin · 24 sa', 2: 'Acil · 2 sa', 3: 'Çok acil · 30 dk' };
export const KONS_KARSILAMA: Record<number, string> = {
  1: 'Yatak başı', 2: 'Konsültan polikliniği', 3: 'İsteyen poliklinik', 4: 'Acil servis', 5: 'Görüntüleme / tetkik odası', 9: 'Diğer',
};

export function useKonsultasyonSuzgeci(aktif: boolean, yenile: number) {
  const [sekme, setSekme] = useState<KonsSekme>('gelen');
  const [kutu, setKutu] = useState<KonsKutu | null>(null);
  const [ozet, setOzet] = useState<KonsultasyonOzet | null>(null);
  useEffect(() => {
    if (!aktif) return;
    let iptal = false;
    api.konsultasyonOzet(sekme).then(y => { if (!iptal) setOzet(y) }).catch(() => { if (!iptal) setOzet(null) });
    return () => { iptal = true };
  }, [aktif, sekme, yenile]);

  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    // Kullanıcı / bölüm gelene kadar boş liste (yanlış kişinin listesi bir an bile görünmesin).
    if (!ozet) l.push({ alan: 'id', op: 'esit', deger: -1 });
    else {
      const { ben, bolumler } = ozet;
      if (sekme === 'istedigim') l.push({ alan: 'isteyenHekimId', op: 'esit', deger: ben });
      else if (sekme === 'bolum') { if (bolumler.length) l.push({ alan: 'hedefBolumId', op: 'icinde', deger: bolumler }) }
      else l.push(bolumler.length
        ? { op: 'or', kosullar: [
            { alan: 'hedefHekimId', op: 'esit', deger: ben },
            { op: 'and', kosullar: [{ alan: 'hedefHekimId', op: 'bos' }, { alan: 'hedefBolumId', op: 'icinde', deger: bolumler }] },
          ] }
        : { alan: 'hedefHekimId', op: 'esit', deger: ben });
      if (kutu === 'suresiGecen') l.push({ alan: 'sureGecti', op: 'esit', deger: 1 });
      if (kutu === 'yanitBekleyen') l.push({ alan: 'durum', op: 'esit', deger: 1 });
      if (kutu === 'yanitladiklarim') l.push({ alan: 'durum', op: 'esit', deger: 2 }, { alan: 'yanitlayanId', op: 'esit', deger: ben });
      if (kutu === 'bugunYanitlanan') l.push({ alan: 'durum', op: 'icinde', deger: [3, 4] });
      if (kutu === 'disMerkez') l.push({ alan: 'merkez', op: 'esit', deger: 2 }, { alan: 'acik', op: 'esit', deger: 1 });
    }
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { sekme, setSekme: (s: KonsSekme) => { setSekme(s); setKutu(null) }, kutu, setKutu, ozet, filtre };
}
export type KonsultasyonSuzgeci = ReturnType<typeof useKonsultasyonSuzgeci>;

export function KonsultasyonUstPanel({ s }: { s: KonsultasyonSuzgeci }) {
  const o = s.ozet?.ozet;
  // LİSTE AKSİYONUNDAN PENCERE (yönlendir / reddet): aksiyon olayla ister, pencere burada.
  const [islem, setIslem] = useState<{ id: number; islem: KonsIslem } | null>(null);
  useEffect(() => {
    const dinle = (e: Event) => setIslem((e as CustomEvent<{ id: number; islem: KonsIslem }>).detail);
    window.addEventListener(KONS_ISLEM_OLAYI, dinle);
    return () => window.removeEventListener(KONS_ISLEM_OLAYI, dinle);
  }, []);
  const sekmeler: { k: KonsSekme; ad: string; sayi?: number }[] = [
    { k: 'gelen', ad: '📥 Bana / bölümüme gelen', sayi: s.sekme === 'gelen' ? o?.acik : undefined },
    { k: 'istedigim', ad: '📤 İstediklerim', sayi: s.sekme === 'istedigim' ? o?.acik : undefined },
    { k: 'bolum', ad: '🏥 Bölüm geneli', sayi: s.sekme === 'bolum' ? o?.acik : undefined },
  ];
  const kutular: { k: KonsKutu | null; ad: string; deger: string; alt: string; sinif?: string }[] = [
    { k: 'suresiGecen', ad: 'Süresi geçen', deger: String(o?.suresiGecen ?? '…'), alt: 'süre sınırını aşan açık istek', sinif: o?.suresiGecen ? 'kirmizi' : undefined },
    { k: 'yanitBekleyen', ad: 'Yanıt bekleyen', deger: String(o?.yanitBekleyen ?? '…'), alt: 'henüz kimse yanıtlamaya almadı', sinif: o?.yanitBekleyen ? 'uyari' : undefined },
    { k: 'yanitladiklarim', ad: 'Yanıtladıklarım (açık)', deger: String(o?.yanitladiklarim ?? '…'), alt: 'yanıt muayenesi sürüyor' },
    { k: 'bugunYanitlanan', ad: 'Bugün yanıtlanan', deger: String(o?.bugunYanitlanan ?? '…'), alt: o?.bugunYanitlanan ? `ort. ${o.ortalamaDk} dk` : '' },
    { k: null, ad: 'e-Nabız 252', deger: o ? `${o.enabizGonderilen} / ${o.enabizToplam}` : '…', alt: 'gönderildi' },
    { k: 'disMerkez', ad: 'Dış merkez', deger: String(o?.disMerkez ?? '…'), alt: 'yanıt bekliyor' },
  ];
  return (
    <div className="kns-ust">
      <div className="kns-sekmeler">
        {sekmeler.map(x => (
          <button key={x.k} type="button" className={s.sekme === x.k ? 'on' : ''} onClick={() => s.setSekme(x.k)}>
            {c(x.ad)}{x.sayi ? <span className="rozet">{x.sayi}</span> : null}
          </button>
        ))}
      </div>
      <div className="pl-kpi">
        {kutular.map(k => (
          <button key={k.ad} type="button" disabled={k.k === null}
                  className={`pl-k${k.k && s.kutu === k.k ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                  onClick={() => k.k && s.setKutu(s.kutu === k.k ? null : k.k)}>
            <b>{k.deger}</b><span>{c(k.ad)}</span>{k.alt && <small>{c(k.alt)}</small>}
          </button>
        ))}
      </div>
      {islem && (
        <KonsultasyonIslemPenceresi id={islem.id} islem={islem.islem} onKapat={() => setIslem(null)}
          onTamam={() => { setIslem(null); window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'konsultasyon' })) }} />
      )}
    </div>
  );
}

/** "Neden çağrıldım": soru, tanılar, son lab, ilaç, alerji + bu hastanın geçmiş konsültasyonları. */
export function KonsultasyonOnizlemePaneli({ satir, yenile, onYanitla, onAc }: {
  satir: ListeSatiri | null; yenile: number; onYanitla(): void; onAc(id: number): void;
}) {
  const id = Number(satir?.id ?? 0);
  const [v, setV] = useState<KonsultasyonOnizleme | null>(null);
  useEffect(() => {
    if (!id) { setV(null); return }
    let iptal = false;
    api.konsultasyonOnizleme(id).then(y => { if (!iptal) setV(y) }).catch(() => { if (!iptal) setV(null) });
    return () => { iptal = true };
  }, [id, yenile]);
  if (!id) return <div className="kns-onizleme bos">{c('Ön izleme için bir istek seçin.')}</div>;
  if (!v) return <div className="kns-onizleme bos">{c('Yükleniyor…')}</div>;
  const k = v.k;
  return (
    <div className="kns-onizleme">
      <div className="kagrup">
        <h6>{c('Seçili istem')} · {k.no}
          <span className="not">{k.basvuruNo ? ` başvuru ${k.basvuruNo}` : ''}{k.istekBolum ? ` · ${k.istekBolum}` : ''}</span>
          <span style={{ marginLeft: 'auto' }} />
          {(k.durum === 1 || k.durum === 2) && <button type="button" className="d bir" onClick={onYanitla}>✋ {c('Yanıtla')}</button>}
          <button type="button" className="d" onClick={() => onAc(id)}>{c('Kartı aç')}</button>
        </h6>
        <KonsAlinti baslik={`İSTEK NOTU · ${k.isteyen} · ${tarihSaat(k.istekZamani)}${k.sorumlu ? ` · sorumlu: ${k.sorumlu}` : ''}`} metin={k.soru} />
        <div className="kns-sat"><span>{c('Tanılar')}</span><b>{v.tanilar.join(' · ') || '—'}</b></div>
        <div className="kns-sat"><span>{c('Son lab')}</span><b>{v.lab.join(' · ') || '—'}</b></div>
        <div className="kns-sat"><span>{c('İlaçlar')}</span><b>{v.ilaclar.join(' · ') || '—'}</b></div>
        <div className="kns-sat"><span>{c('Alerji')}</span><b className={v.alerjiler.length ? 'kns-kir' : ''}>{v.alerjiler.join(' · ') || c('yok')}</b></div>
        {k.yonlendirmeNotu && <div className="kns-sat"><span>{c('Yönlendirme')}</span><b>{k.yonlendirmeNotu}</b></div>}
        {k.retGerekce && <div className="kns-sat"><span>{c('Ret gerekçesi')}</span><b className="kns-kir">{k.retGerekce}</b></div>}
      </div>
      <div className="kagrup">
        <h6>{c('Geçmiş konsültasyonlar')} <span className="not">{c('bu hasta')}</span></h6>
        {v.gecmis.length === 0 ? <p className="not ic">{c('Bu hastanın yanıtlanmış başka konsültasyonu yok.')}</p>
          : v.gecmis.map(g => (
            <KonsAlinti key={g.id} cevap baslik={`YANIT · ${g.yanitlayan} · ${tarihSaat(g.zaman)}${g.bolum ? ` · ${g.bolum}` : ''}`}
                        metin={g.yanit || '—'} />
          ))}
        <KonsAkis v={v} />
      </div>
    </div>
  );
}

export function KonsAlinti({ baslik, metin, cevap }: { baslik: string; metin: string; cevap?: boolean }) {
  return <div className={`kns-alinti${cevap ? ' cevap' : ''}`}><small>{baslik}</small>{metin}</div>;
}

/** AKIŞ ŞERİDİ (mockup kart 2): İstek → Yanıtlanıyor → Hastada → Yanıtlandı → İsteyen gördü → e-Nabız 252. */
export function KonsAkis({ v }: { v: KonsultasyonOnizleme }) {
  const k = v.k;
  const saat = (z?: string | null) => (z ? tarihSaat(z).slice(-5) : '');
  const reddedildi = k.durum === 9;
  const adimlar: { ad: string; zaman: string; ok: boolean }[] = [
    { ad: 'İstek', zaman: saat(k.istekZamani), ok: k.durum !== 6 },
    { ad: 'Yanıtlanıyor', zaman: saat(k.yanitlamaZamani), ok: !!k.yanitlamaZamani },
    { ad: 'Hastada', zaman: saat(k.hastadaZamani), ok: !!k.hastadaZamani },
    { ad: reddedildi ? 'Reddedildi' : 'Yanıtlandı', zaman: saat(k.yanitZamani), ok: k.durum === 3 || k.durum === 4 || reddedildi },
    { ad: 'İsteyen gördü', zaman: saat(k.gorduZamani), ok: !!k.gorduZamani },
    { ad: 'e-Nabız 252', zaman: '', ok: v.enabiz },
  ];
  const su = adimlar.findIndex(a => !a.ok);
  return (
    <div className="kns-akis">
      {adimlar.map((a, i) => (
        <div key={a.ad} className={`kns-ad${a.ok ? ' ok' : i === su ? ' su' : ''}${reddedildi && i === 3 ? ' ret' : ''}`}>
          {c(a.ad)}{a.zaman ? ` · ${a.zaman}` : ''}
        </div>
      ))}
    </div>
  );
}
