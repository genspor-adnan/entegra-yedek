import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { c, ilacAdi } from '../dil/ceviri';
import { HastaKayitPenceresi } from './HastaKayitPenceresi';

/**
 * MUAYENE BAĞLAM ŞERİDİ (461) — mockup `Ekranlar/Muayene/muayene_karti.html`
 * üstündeki dört kutu: <b>Hasta · Alerji/Kronik · Aktif ilaçlar · Bugün</b>.
 *
 * <b>Neden kartın üstünde:</b> hekim muayeneyi yazarken alerjiyi ve kullanılan
 * ilacı görmek zorunda; bunları ayrı sekmede aramak, ilaç yazarken bakılmayan
 * bilgi demektir. Mockup bu yüzden şeridi her sekmenin üstünde tutuyor.
 *
 * <b>Client'ta iş kuralı yok:</b> şerit yalnız sunucudan gelen kayıtları
 * çizer - "bu ilaç bu alerjiyle çelişir" gibi bir karar burada verilmez.
 * Yetkisi olmayan kullanıcıda liste isteği zaten boş döner (kaynak yetkisi).
 */

type Satir = Record<string, unknown>;

const metin = (v: unknown) => String(v ?? '').trim();

/**
 * ŞERİTTE KISA AD (kullanıcı: "alerji/kronik ve ilaçlar çok yer kaplıyor"):
 * ilaç/etken adının ilk rakamlı kelimeye kadarki kısmı, en çok iki kelime -
 * "DEPOSİLİN 1.200.000 I.U. ENJEKSİYONLUK…" -> "DEPOSİLİN". Tam ad rozetin
 * ipucunda ve tıklayınca açılan pencerede kalır.
 */
const kisaAd = (ad: string) => {
  const kelimeler: string[] = [];
  for (const k of ad.split(/\s+/).filter(Boolean)) {
    if (/\d/.test(k) || kelimeler.length === 2) break;
    kelimeler.push(k);
  }
  return kelimeler.join(' ') || ad;
};
/** Şeritte gösterilen en çok rozet; fazlası "+n". */
const SERIT_ROZET = 3;

const ZAMAN = (v: unknown, saatli: boolean) => {
  const d = v ? new Date(String(v)) : null;
  if (!d || Number.isNaN(d.getTime())) return '';
  const g = d.toLocaleDateString('tr-TR');
  const sa = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return saatli ? `${g} ${sa}` : sa;
};

/** "25 dk" · "1 sa 05 dk" - baslamamissa bos. Bitis yoksa SUREN muayene. */

/** Listeyi bir kez çeker; hata olursa şerit sessizce boş kalır. */
async function listele(kaynak: string, hastaId: number): Promise<Satir[]> {
  try {
    const y = await api.liste(kaynak, {
      sayfa: 1, boyut: 20,
      filtre: { alan: 'hastaId', op: 'esit', deger: hastaId },
    });
    return (y.satirlar ?? []) as Satir[];
  } catch { return [] }
}

/**
 * KART BAŞLIĞINDA DOSYA + PROTOKOL NO (kullanıcı: teknik "sürüm" rozetinin
 * yerine). Kart değerinde numaralar yok (kod alanları id tutar); şeritle
 * aynı yoldan muayene listesinin tek satırı okunur.
 */
export function MuayeneBaslikNumaralari({ muayeneId }: { muayeneId: number }) {
  const [no, setNo] = useState<{ dosya: string; protokol: string } | null>(null);
  useEffect(() => {
    if (!(muayeneId > 0)) { setNo(null); return }
    let iptal = false;
    void api.liste('muayene', { sayfa: 1, boyut: 1,
      filtre: { alan: 'id', op: 'esit', deger: muayeneId } })
      .then(y => {
        const r = (y.satirlar?.[0] ?? null) as Satir | null;
        if (!iptal) setNo(r ? { dosya: metin(r.dosyaNo), protokol: metin(r.protokolNo) } : null);
      }).catch(() => { /* baslik zorunlu degil */ });
    return () => { iptal = true };
  }, [muayeneId]);
  if (!no || (!no.dosya && !no.protokol)) return null;
  return (
    <span className="rozet gri" title={c('Dosya no · Protokol no')}>
      {[no.dosya, no.protokol].filter(Boolean).join(' · ')}
    </span>
  );
}

export function MuayeneBaglamSeridi({ muayeneId, onBugun }:
  { muayeneId: number; onBugun?(): void }) {
  // KART DEGERI YETMIYOR: kartta hastanin ADI ve protokol NUMARASI yok
  //   (kod alanlari id tutar). Ayni bilgi muayene LISTESINDE hazir - tek
  //   satir cekmek, hasta/protokol/tur/hekim icin ayri ayri sorgudan ucuz.
  const [ust, setUst] = useState<Satir | null>(null);
  const [alerji, setAlerji] = useState<Satir[]>([]);
  const [kronik, setKronik] = useState<Satir[]>([]);
  const [ilac, setIlac] = useState<Satir[]>([]);
  const [yuklendi, setYuklendi] = useState(false);
  /** Acik hasta kayitlari penceresi (alerji+kronik ya da aktif ilac). */
  const [pencere, setPencere] = useState<'alerji' | 'ilac' | null>(null);
  const [tazele, setTazele] = useState(0);

  useEffect(() => {
    if (!(muayeneId > 0)) { setYuklendi(true); return }
    let iptal = false;
    void (async () => {
      let satir: Satir | null = null;
      try {
        const y = await api.liste('muayene', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: muayeneId },
        });
        satir = (y.satirlar?.[0] ?? null) as Satir | null;
      } catch { /* serit zorunlu degil */ }
      if (iptal) return;
      setUst(satir);

      const hastaId = Number(satir?.tarafId ?? 0);
      if (!(hastaId > 0)) { setYuklendi(true); return }
      const [a, k, i] = await Promise.all([
        listele('hasta-alerji', hastaId),
        listele('hasta-kronik', hastaId),
        listele('hasta-ilac', hastaId),
      ]);
      if (iptal) return;
      // AKTİF olanlar önce ve yalnız onlar: geçmişte kesilmiş ilacı "aktif
      //   ilaç" diye göstermek, hekimi yanlış bilgiyle yazdırır.
      setAlerji(a.filter(x => Number(x.aktif ?? 1) === 1));
      setKronik(k.filter(x => Number(x.durum ?? 1) !== 0));
      setIlac(i.filter(x => Number(x.aktif ?? 1) === 1));
      setYuklendi(true);
    })();
    return () => { iptal = true };
  }, [muayeneId, tazele]);

  if (!(muayeneId > 0)) return null;

  const hastaAdi = metin(ust?.hastaAdi);
  const hastaIdSerit = Number(ust?.tarafId ?? 0);
  /** Kutuyu tiklanir yapar (fare + klavye). */
  const tikla = (tur: 'alerji' | 'ilac') => hastaIdSerit > 0 ? {
    role: 'button', tabIndex: 0, title: c('Ekle / düzenle'),
    onClick: () => setPencere(tur),
    onKeyDown: (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); setPencere(tur) }
    },
  } : {};
  const bolum = metin(ust?.bolumAdi);
  const hekim = metin(ust?.hekimAdi);
  const cinsiyet = metin(ust?.cinsiyetKisa);
  const yas = metin(ust?.yasMetni);
  // Muayenenin gun icindeki penceresi: "06.09.2026 15:24 – 15:49 · 25 dk".
  //   Bitis bossa muayene SURUYOR - gecen sure yine yazilir.
  const bas = ZAMAN(ust?.baslangic, true);
  const bit = ZAMAN(ust?.bitis ?? ust?.tamamlanma, false);

  return (
    <div className="kart-baglam">
      {/* ETIKET KUTUNUN USTUNDE (kullanici): kutu icinde ilk satiri
          yiyordu; disarida durunca kutunun tamami veriye kaliyor. */}
      <div className="kb-hucre kb-hasta">
        <div className="kb-bas">Hasta</div>
        <div className="kb-kutu">
        <div className="kb-ic">
          <b>{hastaAdi || '—'}</b>
          {/* CINSIYET + YAS ADIN SAGINDA (kullanici: "K 45y"): doz, referans
              araligi ve tetkik karari once bu ikisine bakar. Ikisi de
              SUNUCUDAN hazir metin gelir - yas hesabini ekran yapmaz. */}
          {/* ROZET DEGIL DUZ METIN (kullanici): ad satirinda ikinci bir
              cerceve gorsel gurultuydu. */}
          {(cinsiyet || yas) && (
            <span className="sonuk" title={c('Cinsiyet · yaş')}>
              {/* Cinsiyet SIMGESI + harf (kullanici: "Ali Er ♂E 48y"): simge
                  bir bakista, harf de yazidan okunanla ayni olsun. */}
              {cinsiyet === 'E' ? '♂' : cinsiyet === 'K' ? '♀' : ''}
              {cinsiyet}{yas ? ` ${yas}` : ''}
            </span>
          )}
        </div>
        {/* Dosya ve protokol numarasi KART BASLIGINDA (kullanici: surum
            rozetinin yerine) - MuayeneBaslikNumaralari. */}
        </div>
      </div>

      <div className="kb-hucre">
        <div className="kb-bas">{c('Alerji / Kronik')}{hastaIdSerit > 0 ? <span className="kb-kalem" title="Düzenle" aria-label="Düzenle"> ✎</span> : null}</div>
        {/* TIKLANINCA EKLE / DUZENLE (kullanici): hastanin alerji ve kronik
            tanilari muayeneden cikmadan girilir. */}
        <div className={`kb-kutu${hastaIdSerit > 0 ? ' kb-tikla' : ''}`} {...tikla('alerji')}>
        <div className="kb-ic kb-ozet">
          {/* ALERJİ YOKSA DA YAZILIR: boş kutu "bakılmadı" ile "yok"u
              ayırt ettirmez; mockup da "Alerji: yok" rozetini gösteriyor. */}
          {alerji.length === 0
            ? <span className={`rozet ${yuklendi ? 'olumlu' : 'gri'}`}>
                {yuklendi ? 'Alerji: yok' : 'Alerji: …'}
              </span>
            : alerji.slice(0, SERIT_ROZET).map((a, i) => {
                const ad = metin(a.etken) || metin(a.etkenMadde) || 'Alerji';
                return (
                  <span key={i} className="rozet hata"
                        title={`${ad} · ${metin(a.turAdi)} · ${metin(a.reaksiyon)}`}>
                    {kisaAd(ad)}
                  </span>
                );
              })}
          {/* KRONİK: tanı ADI, KOD YOK (kullanıcı: "buralarda kod istemiyorum");
              uzun ad rozet genişliğinde "…" ile kesilir, tamamı ipucunda.
              Alerjilerle birlikte en çok SERIT_ROZET rozet; fazlası "+n". */}
          {kronik.slice(0, Math.max(0, SERIT_ROZET - Math.min(alerji.length, SERIT_ROZET)))
            .map((k, i) => (
              <span key={`k${i}`} className="rozet uyari" title={metin(k.taniAd) || metin(k.icdKod)}>
                {metin(k.taniAd) || metin(k.icdKod)}
              </span>
            ))}
          {(() => {
            const gizli = Math.max(0, alerji.length - SERIT_ROZET)
              + Math.max(0, kronik.length - Math.max(0, SERIT_ROZET - Math.min(alerji.length, SERIT_ROZET)));
            return gizli > 0 && (
              <span className="rozet gri kb-fazla"
                    title={[...alerji.map(a => metin(a.etken) || metin(a.etkenMadde)),
                            ...kronik.map(k => metin(k.taniAd) || metin(k.icdKod))].join('\n')}>
                +{gizli}
              </span>
            );
          })()}
        </div>
        </div>
      </div>

      <div className="kb-hucre">
        <div className="kb-bas">{c('Aktif ilaçlar')}{hastaIdSerit > 0 ? <span className="kb-kalem" title="Düzenle" aria-label="Düzenle"> ✎</span> : null}</div>
        <div className={`kb-kutu${hastaIdSerit > 0 ? ' kb-tikla' : ''}`} {...tikla('ilac')}>
        <div className="kb-ic kb-ozet">
          {ilac.length === 0
            ? <span className={`rozet ${yuklendi ? 'olumlu' : 'gri'}`}>
                {yuklendi ? 'Aktif ilaç: yok' : 'Aktif ilaç: …'}
              </span>
            : (
              <>
                {/* KISA AD, DOZSUZ (kullanıcı: özet): tam ad + doz + etken ipucunda. */}
                {ilac.slice(0, SERIT_ROZET).map((x, i) => {
                  const ad = ilacAdi(metin(x.ilacAd));
                  return (
                    <span key={i} className="rozet mavi kb-ilac"
                          title={[ad, metin(x.doz), ilacAdi(metin(x.etkenMadde))].filter(Boolean).join(' · ')}>
                      {kisaAd(ad)}
                    </span>
                  );
                })}
                {ilac.length > SERIT_ROZET && (
                  <span className="rozet gri kb-fazla"
                        title={ilac.slice(SERIT_ROZET).map(x => ilacAdi(metin(x.ilacAd))).join('\n')}>
                    +{ilac.length - SERIT_ROZET}
                  </span>
                )}
              </>
            )}
        </div>
        </div>
      </div>

      {/* BUGUN: mockup'ta "acilden yonlendirme · panik sonuc" gibi o gune ait
          notlar var. Elimizdeki karsilik: muayene turu, bolum/hekim, bekleyen
          istem ve ana tani - hepsi SUNUCUDAN gelen alanlar.
          TIKLANINCA kimlik alanlari (tur, bolum, hekim, baslama/bitis, isteyen
          muayene) modalda acilir (kullanici): bu alanlar arada bir duzeltilir,
          kart izgarasinda surekli yer kaplamalari gerekmiyor. */}
      <div className="kb-hucre">
        <div className="kb-bas">Bugün{onBugun ? <span className="kb-kalem" title="Düzenle" aria-label="Düzenle"> ✎</span> : null}</div>
        <div className={`kb-kutu${onBugun ? ' kb-tikla' : ''}`}
             role={onBugun ? 'button' : undefined}
             tabIndex={onBugun ? 0 : undefined}
             title={onBugun ? 'Muayene bilgilerini aç' : undefined}
             onClick={onBugun}
             onKeyDown={e => {
               if (onBugun && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); onBugun() }
             }}>
        <div className="kb-ic kb-tek" title={[bolum, hekim, bas ? `${bas} – ${bit || "…"}` : ""].filter(Boolean).join(" · ")}>
          {bolum ? <span>{bolum}</span> : null}
          {hekim ? <span className="sonuk">· {hekim}</span> : null}
          {/* "n sonuc bekliyor" GOSTERILMEZ (kullanici): bekleyen istemler
              Istem & Sonuclar sekmesinde. */}
          {/* TARIH-SAAT VE SURE "sonuc bekliyor" rozetinin SAGINDA, TEK SATIR
              (kullanici): ayri alt satir kalkti. Sure rozet - bandaki
              olculerle ayni gorunum. */}
          {bas ? (
            <>
              <span className="sonuk">{bas} – {bit || '…'}</span>
              {/* SURE Bugun kutusunda GOSTERILMEZ (kullanici): durum bandinda var. */}
            </>
          ) : <span className="sonuk">{c('Muayeneye alınmadı')}</span>}
          {/* ANA TANI ve MUAYENE TURU (Yuz yuze) GOSTERILMEZ (kullanici: "cok
              bilgi var.. taniyi kaldir.. yuz yuzeyi kaldir"): tani Muayene
              sekmesindeki gridde, tur kimlik penceresinde. */}
        </div>
        </div>
      </div>
      {pencere && hastaIdSerit > 0 && (
        <HastaKayitPenceresi
          baslik={pencere === 'alerji' ? `${c('Alerji / Kronik')} — ${hastaAdi}` : `${c('Aktif ilaçlar')} — ${hastaAdi}`}
          hastaId={hastaIdSerit}
          hastaAdi={hastaAdi}
          muayeneId={muayeneId}
          bolumler={pencere === 'alerji'
            ? [{ kaynak: 'hasta-alerji', baslik: c('Alerjiler'),
                 ekVarsayilan: { kayitMuayeneId: muayeneId } },
               { kaynak: 'hasta-kronik', baslik: c('Kronik hastalıklar') }]
            : [{ kaynak: 'hasta-ilac', baslik: c('Kullanılan ilaçlar') }]}
          onKapat={() => setPencere(null)}
          onDegisti={() => setTazele(t => t + 1)} />
      )}
    </div>
  );
}
