import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

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

const ZAMAN = (v: unknown, saatli: boolean) => {
  const d = v ? new Date(String(v)) : null;
  if (!d || Number.isNaN(d.getTime())) return '';
  const g = d.toLocaleDateString('tr-TR');
  const sa = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return saatli ? `${g} ${sa}` : sa;
};

/** "25 dk" · "1 sa 05 dk" - baslamamissa bos. Bitis yoksa SUREN muayene. */
function sure(baslangic: unknown, bitis: unknown): string {
  const b = baslangic ? new Date(String(baslangic)).getTime() : NaN;
  if (!Number.isFinite(b)) return '';
  const s = bitis ? new Date(String(bitis)).getTime() : Date.now();
  const dk = Math.max(0, Math.round((s - b) / 60000));
  return dk < 60 ? `${dk} dk`
                 : `${Math.floor(dk / 60)} sa ${String(dk % 60).padStart(2, '0')} dk`;
}

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
  }, [muayeneId]);

  if (!(muayeneId > 0)) return null;

  const hastaAdi = metin(ust?.hastaAdi);
  const protokol = metin(ust?.protokolNo);
  const bolum = metin(ust?.bolumAdi);
  const hekim = metin(ust?.hekimAdi);
  const tur = metin(ust?.turAdi);
  const bekleyen = Number(ust?.bekleyenIstem ?? 0);
  const anaTani = metin(ust?.anaTani);
  const cinsiyet = metin(ust?.cinsiyetKisa);
  const yas = metin(ust?.yasMetni);
  // Muayenenin gun icindeki penceresi: "06.09.2026 15:24 – 15:49 · 25 dk".
  //   Bitis bossa muayene SURUYOR - gecen sure yine yazilir.
  const bas = ZAMAN(ust?.baslangic, true);
  const bit = ZAMAN(ust?.bitis ?? ust?.tamamlanma, false);
  const gecen = sure(ust?.baslangic, ust?.bitis ?? ust?.tamamlanma);

  return (
    <div className="kart-baglam">
      <div className="kb-kutu">
        <div className="kb-bas">Hasta</div>
        <div className="kb-ic">
          <b>{hastaAdi || '—'}</b>
          {/* CINSIYET + YAS ADIN SAGINDA (kullanici: "K 45y"): doz, referans
              araligi ve tetkik karari once bu ikisine bakar. Ikisi de
              SUNUCUDAN hazir metin gelir - yas hesabini ekran yapmaz. */}
          {(cinsiyet || yas) && (
            <span className="rozet gri" title="Cinsiyet · yaş">
              {[cinsiyet, yas].filter(Boolean).join(' ')}
            </span>
          )}
        </div>
        {/* Dosya ve protokol numarasi ADIN ALTINDA (kullanici): ad satirini
            uzatmiyor. ETIKETSIZ (kullanici): numaralarin bicimi kendini
            soyluyor, "Dosya"/"Protokol" kelimeleri satiri sisiriyordu. */}
        <div className="kb-ic sonuk">
          {metin(ust?.dosyaNo) ? <span>{metin(ust?.dosyaNo)}</span> : null}
          {protokol ? <span>· {protokol}</span> : null}
          {!metin(ust?.dosyaNo) && !protokol ? <span>—</span> : null}
        </div>
      </div>

      <div className="kb-kutu">
        <div className="kb-bas">Alerji / Kronik</div>
        <div className="kb-ic">
          {/* ALERJİ YOKSA DA YAZILIR: boş kutu "bakılmadı" ile "yok"u
              ayırt ettirmez; mockup da "Alerji: yok" rozetini gösteriyor. */}
          {alerji.length === 0
            ? <span className={`rozet ${yuklendi ? 'olumlu' : 'gri'}`}>
                {yuklendi ? 'Alerji: yok' : 'Alerji: …'}
              </span>
            : alerji.slice(0, 4).map((a, i) => (
                <span key={i} className="rozet hata"
                      title={`${metin(a.turAdi)} · ${metin(a.reaksiyon)}`}>
                  {metin(a.etken) || metin(a.etkenMadde) || 'Alerji'}
                </span>
              ))}
          {kronik.slice(0, 4).map((k, i) => (
            <span key={`k${i}`} className="rozet uyari" title={metin(k.icdKod)}>
              {metin(k.taniAd) || metin(k.icdKod)}
            </span>
          ))}
          {kronik.length > 4 && <span className="rozet gri">+{kronik.length - 4}</span>}
        </div>
      </div>

      <div className="kb-kutu">
        <div className="kb-bas">Aktif ilaçlar</div>
        <div className="kb-ic">
          {ilac.length === 0
            ? <span className="sonuk">{yuklendi ? 'Kayıtlı ilaç yok' : '…'}</span>
            : (
              <>
                {ilac.slice(0, 4).map((x, i) => (
                  <span key={i} className="kb-ilac" title={metin(x.etkenMadde)}>
                    {metin(x.ilacAd)}
                    {metin(x.doz) ? <span className="sonuk"> {metin(x.doz)}</span> : null}
                  </span>
                ))}
                {ilac.length > 4 && <span className="rozet gri">+{ilac.length - 4}</span>}
              </>
            )}
        </div>
      </div>

      {/* BUGUN: mockup'ta "acilden yonlendirme · panik sonuc" gibi o gune ait
          notlar var. Elimizdeki karsilik: muayene turu, bolum/hekim, bekleyen
          istem ve ana tani - hepsi SUNUCUDAN gelen alanlar.
          TIKLANINCA kimlik alanlari (tur, bolum, hekim, baslama/bitis, isteyen
          muayene) modalda acilir (kullanici): bu alanlar arada bir duzeltilir,
          kart izgarasinda surekli yer kaplamalari gerekmiyor. */}
      <div className={`kb-kutu${onBugun ? ' kb-tikla' : ''}`}
           role={onBugun ? 'button' : undefined}
           tabIndex={onBugun ? 0 : undefined}
           title={onBugun ? 'Muayene bilgilerini aç' : undefined}
           onClick={onBugun}
           onKeyDown={e => {
             if (onBugun && (e.key === 'Enter' || e.key === ' ')) { e.preventDefault(); onBugun() }
           }}>
        <div className="kb-bas">Bugün{onBugun ? <span className="sonuk"> · düzenle</span> : null}</div>
        <div className="kb-ic">
          {tur ? <span className="rozet gri">{tur}</span> : null}
          {bolum ? <span>{bolum}</span> : null}
          {hekim ? <span className="sonuk">· {hekim}</span> : null}
          {bekleyen > 0 && (
            <span className="rozet uyari">{bekleyen} sonuç bekliyor</span>
          )}
          {anaTani ? <span className="rozet olumlu" title="Ana tanı">{anaTani}</span> : null}
          {!tur && !bolum && !hekim && bekleyen === 0 && !anaTani
            && <span className="sonuk">—</span>}
        </div>
        {/* ALT SATIR (kullanici): baslama tarihi-saati, bitis saati ve sure. */}
        <div className="kb-ic sonuk">
          {bas ? (
            <>
              <span>{bas} – {bit || '…'}</span>
              {/* Sure ROZET (kullanici): bandaki olculerle ayni gorunum. */}
              {gecen ? <span className="rozet gri">{gecen}</span> : null}
            </>
          ) : <span>Muayeneye alınmadı</span>}
        </div>
      </div>
    </div>
  );
}
