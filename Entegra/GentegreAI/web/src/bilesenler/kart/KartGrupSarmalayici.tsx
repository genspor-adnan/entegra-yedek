import { useState, type ReactNode } from 'react';
import { c } from '../../dil/ceviri';
import { KartGrupSekmesi } from './KartGrupSekmesi';
import { GenDetayTablo, type DetayDurumu, bosDetay } from '../GenDetayTablo';
import { TekKayit } from '../TekKayit';
import { RandevuUygunSaatler } from '../RandevuUygunSaatler';
import { RandevuOzetSeridi } from '../RandevuOzetSeridi';
import { RandevuTetkikUyum } from '../RandevuTetkikUyum';
import type { Deger } from '../kartAlanCizim';
import type { KartAlanMeta, KartMetaYaniti } from '../../api/sozlesme';
import type { AltGrupBaslik, SekmeParcalari, SekmeTanimi } from '../kartSekmeleri';

export interface KartGrupSarmalayiciOzellikleri {
  /** Acik sekme (tur === 'grup' oldugu YERDE cagrilir). */
  aktif: Extract<SekmeTanimi, { tur: 'grup' }>;
  kaynak: string;
  id: number | 'yeni';
  yeniMi: boolean;
  meta: KartMetaYaniti;
  salt: boolean;
  personelGibiKart: boolean;
  deger: Record<string, Deger>;
  setDeger: React.Dispatch<React.SetStateAction<Record<string, Deger>>>;
  alanDegistir(ad: string, v: Deger): void;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar: React.Dispatch<React.SetStateAction<Record<string, DetayDurumu>>>;
  alanHatalari: Record<string, string>;
  /** Ekrana ozel gizlenen sekmeler - aday kartinda adres kutusunun yerini belirler. */
  gizliSekmeler?: string[];
  /** Resim kutusu yerine yer tutucu (yeni kayitta id yok). */
  resimYerTutucu?: boolean;
  gruplar: [string, KartAlanMeta[]][];
  /** Alan cizim yardimcilari (kartAlanCizim fabrikasindan). */
  altGruplaVar(alanlar: KartAlanMeta[]): [string, KartAlanMeta[]][];
  renderAlanListesi(alanlar: KartAlanMeta[]): ReactNode;
  /** Jenerik arama modalini acar (305): 1:1 uzanti formundaki kurum secimi. */
  setAramaAlani(v: { alan: string; kaynak: string;
                     uygula?: (deger: string) => void } | null): void;
  secilenAdlar: Record<string, string>;
  /** Gruba GOMULU detaylar (mockup "Fizik Muayene"): ayri sekme degil. */
  detayGrupta?: Record<string, { grup: string | readonly string[]; salt?: boolean; gridKipi?: boolean;
                                 sinif?: string; sade?: boolean; ekleGizli?: boolean;
                                 gizli?: string[]; etiket?: string[]; ustte?: boolean;
                                 yeni?: () => void; kolonBaslikEk?: Record<string, ReactNode>;
                                 baslikEk?(satirlar: Record<string, unknown>[]): ReactNode;
                                 ekKolon?: { baslik: string; genislik?: number; ciz(satir: Record<string, unknown>): ReactNode };
                                 oneri?: Record<string, string> }>;
  detayIzgara?: Record<string, { sinif?: string; baslik?: string;
                                 alanSirasi?: string[]; not?: ReactNode;
                                 /** Veri yoksa yalniz baslik (kapali), varsa acik. */
                                 katlanir?: boolean;
                                 /** HESAPLANAN alanlar (vital BKİ): girdi değil etiket, değer anında hesaplanır. */
                                 hesaplanan?: Record<string, (satir: Record<string, unknown>) => string> }>;
  sekmeSarmalayici?(baslik: string, icerik: ReactNode, deger: Record<string, Deger>,
                    izgaraCiz?: (detayAd: string, kutuTikla?: (alanAd: string) => void, alt?: ReactNode) => ReactNode,
                    parcalar?: SekmeParcalari): ReactNode;
}

/**
 * KART GRUP SEKMESININ SARMALAYICISI.
 *
 * Alan izgarasini `KartGrupSekmesi` ciziyor; burasi onun etrafindaki ekran-ozel
 * yerlesimi kuruyor: randevunun uygun saat/ozet seritleri, gruba GOMULU detay
 * tablolari (mockup "Fizik Muayene"de sablon alanlarinin altindaki tablo) ve
 * ekranin istedigi yere konabilen izgara cizici.
 *
 * `GenForm` govdesinden ayrildi - orada 100 satirlik bir IIFE idi.
 */
export function KartGrupSarmalayici({
  aktif, kaynak, id, yeniMi, meta, salt, personelGibiKart,
  deger, setDeger, alanDegistir, detaylar, setDetaylar, alanHatalari,
  gizliSekmeler, resimYerTutucu, gruplar, altGruplaVar, renderAlanListesi,
  setAramaAlani, secilenAdlar, detayGrupta, detayIzgara, sekmeSarmalayici,
}: KartGrupSarmalayiciOzellikleri) {
        const grupCiz = (sekme: typeof aktif, altBaslik?: AltGrupBaslik) => (
        <KartGrupSekmesi
          aktif={sekme} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
          aramaAc={(alan, kaynak, uygula) => setAramaAlani({ alan, kaynak, uygula })}
          secilenAdlar={secilenAdlar} altBaslik={altBaslik}
        />
        );
        const govde = grupCiz(aktif);
        const tam = kaynak === 'randevu' ? (
          <>
            {govde}
            {/* TETKİK-CİHAZ uyumu ve protokol süresi (317): hasta gelmeden
                randevu alındığı için yanlış cihaz ancak hasta geldiğinde fark
                edilirdi. Engelleme veritabanı tetiğinde, bu erken uyarı. */}
            <RandevuTetkikUyum
              hizmetId={Number(deger.hizmetId) || null}
              cihazId={Number(deger.cihazId) || null}
              sureDk={Number(deger.sureDk) || 0}
              onSure={dk => alanDegistir('sureDk', String(dk))}
            />
            {/* UYGUN SAATLER (mockup): secili hekim + tarih icin o gunun
                slotlari; bos saate tiklamak kartin baslangicini tasir. */}
            <RandevuUygunSaatler
              hekimId={Number(deger.hekimId) || null}
              hekimAdi={meta.alanlar.find(a => a.ad === 'hekimId')
                            ?.kodlar?.[String(deger.hekimId ?? '')]}
              bolum={Number(deger.bolum) || null}
              tarih={String(deger.baslangic ?? '').slice(0, 10)}
              sureDk={Number(deger.sureDk) || 0}
              seciliSaat={String(deger.baslangic ?? '').slice(11, 16)}
              hariçId={yeniMi ? null : Number(id)}
              saltOkunur={salt}
              onSec={(saat, sure) => {
                alanDegistir('baslangic', `${String(deger.baslangic ?? '').slice(0, 10)}T${saat}`);
                alanDegistir('sureDk', String(sure));
              }}
            />
            {/* Ozet serit EN ALTTA (mockup .ozet): hasta no, son randevu,
                acik bakiye, olusturma. */}
            <RandevuOzetSeridi
              hastaId={Number(deger.hastaId) || null}
              hariçId={yeniMi ? null : Number(id)}
              olusturan={String(deger.eklemeTarihi ?? '')}
            />
          </>
        ) : govde;
        // GRUBA GOMULU DETAY (mockup "Fizik Muayene"): sablon alanlarinin
        //   ALTINDA sistem/normal/bulgu tablosu - ayri sekme degil.
        const gomulu = (meta?.detaylar ?? [])
          // Grup birden çok ad alabilir (sekme yeniden adlandırılınca eski ad
          //   da tanınsın - eski API ile çalışan ekran detayı kaybetmesin).
          .filter(d => ([] as string[]).concat(detayGrupta?.[d.ad]?.grup ?? []).includes(aktif.baslik));
        const tablolar = gomulu.map(d => (
              <GenDetayTablo
                key={d.ad}
                meta={d}
                durum={detaylar[d.ad] ?? bosDetay()}
                saltOkunur={salt || d.saltOkunur || !!detayGrupta?.[d.ad]?.salt}
                modalDuzenle={detayGrupta?.[d.ad]?.gridKipi}
                ikonlu={detayGrupta?.[d.ad]?.gridKipi}
                hatalar={alanHatalari}
                kutuSinif={detayGrupta?.[d.ad]?.sinif}
                sadeGrid={detayGrupta?.[d.ad]?.sade}
                ekleGizli={detayGrupta?.[d.ad]?.ekleGizli}
                onYeni={detayGrupta?.[d.ad]?.yeni}
                kolonBaslikEk={detayGrupta?.[d.ad]?.kolonBaslikEk}
                baslikEk={detayGrupta?.[d.ad]?.baslikEk}
                ekKolon={detayGrupta?.[d.ad]?.ekKolon}
                oneriAlanlari={detayGrupta?.[d.ad]?.oneri}
                gizliAlanlar={detayGrupta?.[d.ad]?.gizli
                  ? new Set(detayGrupta[d.ad].gizli) : undefined}
                etiketAlanlari={detayGrupta?.[d.ad]?.etiket
                  ? new Set(detayGrupta[d.ad].etiket) : undefined}
                onDegis={yeni => setDetaylar(t => ({ ...t, [d.ad]: yeni }))}
              />
        ));
        // USTTE: tanida tablo ONCE gelir (mockup) - hekim once ICD girer,
        //   sevk/takip alanlari karari yazarken doldurulur.
        const ustte = gomulu.some(d => detayGrupta?.[d.ad]?.ustte);
        const tumu = gomulu.length === 0 ? tam
          : ustte ? <>{tablolar}{tam}</> : <>{tam}{tablolar}</>;
        // IZGARA CIZICI: ekran bir DETAYI (or. vitaller) istedigi yere
        //   etiket+kutu izgarasi olarak koyabilsin - anamnez sekmesinin sag
        //   paneli boyle: hekim sikayeti yazarken vitali AYNI ekranda girer.
        const izgaraCiz = (detayAd: string, kutuTikla?: (alanAd: string) => void, alt?: ReactNode) => {
          const d = (meta?.detaylar ?? []).find(x => x.ad === detayAd);
          if (!d) return null;
          const ayar = detayIzgara?.[detayAd] ?? {};
          const durum = detaylar[d.ad] ?? bosDetay();
          // Grafiği olan kutu: çağıran kutuTikla verdiyse ve alan grafik listesindeyse.
          const grafikli = (ad: string) => !!kutuTikla && GRAFIKLI_ALANLAR.has(ad);
          const kutu = (acik: boolean, tikla?: () => void) => acik ? (
            <TekKayit
              meta={d}
              durum={durum}
              saltOkunur={salt || d.saltOkunur}
              onDegis={yeni => setDetaylar(t => ({ ...t, [d.ad]: yeni }))}
              baslik={ayar.baslik ?? d.baslik}
              alanSirasi={ayar.alanSirasi}
              hesaplanan={ayar.hesaplanan}
              // ALT SATIR (vital: 📈 Geçmiş kısayolları) çerçevenin İÇİNDE; yoksa ızgaranın notu.
              not={alt ?? ayar.not}
              onBaslikTikla={tikla}
              // DÜZENLEMEDE 💾 (kullanıcı): tıklayınca kutulara döner; değerler kartın Kaydet'iyle yazılır.
              baslikSonEk={tikla ? <span title={c('Kutulara dön · kart Kaydet ile yazılır')}>💾</span> : undefined}
            />
          ) : (
            <div className="kasira"><div className="kagrup katlanir-kapali">
              <h6 className="katlanir-bas" onClick={tikla}>
                {ayar.baslik ?? d.baslik}<span className="katlanir-sag" title={c('Düzenle')}>✎</span></h6>
              {/* ÖZET KUTULARI (kullanıcı 14.10.2026, mockup muayene_karti_v7): dolu ölçümler
                  etiket + değer kutusu; başlığa tıklayınca düzenleme, tekrar tıklayınca buraya döner. */}
              {ozetKutulari(d, durum.guncel[0], ayar.alanSirasi).length > 0 && (
                <div className="vt-kutular">
                  {ozetKutulari(d, durum.guncel[0], ayar.alanSirasi).map(k => (
                    <div key={k.ad} className={`vt-kutu${grafikli(k.ad) ? ' tik' : ''}${k.kir ? ' kir' : ''}`} title={grafikli(k.ad) ? c('Geçmiş grafiği') : undefined}
                         onClick={grafikli(k.ad) ? () => kutuTikla!(k.ad) : undefined}>
                      <div className="vt-b">{c(k.baslik)}{grafikli(k.ad) && <span className="vt-gr"> 📈</span>}</div><div className="vt-d">{k.deger}</div></div>
                  ))}
                </div>
              )}
              {alt && <div className="izg-alt">{alt}</div>}
            </div></div>
          );
          return (
            <div className={ayar.sinif}>
              {ayar.katlanir
                ? <KatlanirIzgara dolu={durum.guncel.length > 0} ciz={kutu} />
                : kutu(true)}
            </div>
          );
        };
        // PARCALAR: ekran gomulu tabloyu alanlardan ayri yere koyabilsin.
        const parcalar: SekmeParcalari = {
          alanlar: tam,
          tablolar: Object.fromEntries(gomulu.map((d, i) => [d.ad, tablolar[i]])),
          alanDegistir,
          altGrupCiz: (alt, baslik) => {
            const alanlar = aktif.alanlar.filter(a => (a.altGrup ?? '') === alt);
            return alanlar.length ? grupCiz({ ...aktif, alanlar }, baslik) : null;
          },
        };
        return sekmeSarmalayici
          ? sekmeSarmalayici(aktif.baslik, tumu, deger, izgaraCiz, parcalar) : tumu;
}

/**
 * KATLANIR IZGARA (kullanici: "vital bulgular seyrek kullaniliyor"): veri
 * yoksa yalniz baslik, varsa acik. Baslik tiklaninca acilir/kapanir; sonradan
 * veri gelirse (kart tazelendi) kendiliginden acilir.
 */
function KatlanirIzgara({ ciz }: {
  dolu: boolean;
  ciz(acik: boolean, tikla: () => void): ReactNode;
}) {
  // Kullanıcı 14.10.2026: varsayılan KUTU görünümü (doluysa ölçüm kutuları, boşsa yalnız
  //   başlık); başlığa tıklayınca düzenleme, tekrar tıklayınca kutular.
  const [acik, setAcik] = useState(false);
  return <>{ciz(acik, () => setAcik(a => !a))}</>;
}

/**
 * VİTAL REFERANS ARALIKLARI - sunucunun ölçüm geçmişi grafiğiyle AYNI sınırlar
 * (MuayeneUclari.OlcumGecmisi VitalSerileri). Dışındaki değer kutuda kırmızı (mockup v7).
 */
const VITAL_ARALIK: Record<string, [number, number]> = {
  sistolik: [90, 140], diyastolik: [60, 90], nabiz: [60, 100], spo2: [95, 100], ates: [36, 37.5],
  solunum: [12, 20], agriVas: [0, 3], bki: [18.5, 25], glukozParmak: [70, 140],
};
const disinda = (ad: string, n: number) => { const r = VITAL_ARALIK[ad]; return !!r && (n < r[0] || n > r[1]) };

/** Geçmiş grafiği olan vital alanları (sunucu ölçüm geçmişi ucunun anahtarları). */
const GRAFIKLI_ALANLAR = new Set(['sistolik', 'nabiz', 'spo2', 'ates', 'solunum', 'kiloKg', 'bki']);

/**
 * Katlanmış ızgaranın ÖZET KUTULARI: güncel satırın dolu alanları, ızgaranın alan sırasıyla.
 * Tansiyon tek kutu (sistolik/diyastolik), SpO₂ "%", ağrı "/10"; sıfır ve boş yazılmaz.
 */
function ozetKutulari(d: { alanlar: { ad: string; baslik?: string | null }[] },
                      satir: Record<string, unknown> | undefined, sira?: string[]) {
  if (!satir) return [];
  const sayi = (v: unknown) => { const n = Number(v); return v != null && v !== '' && Number.isFinite(n) && n !== 0 ? n : null };
  const bicim = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 1 });
  const adlar = [...(sira ?? d.alanlar.map(a => a.ad))];
  // Boy + kilo TEK kutu ("180 / 77"); grafiği kilonun. BKİ girilen boy / kilodan anında.
  const boy = sayi(satir.boyCm), kilo = sayi(satir.kiloKg);
  if (boy && kilo) satir = { ...satir, bki: Math.round(kilo / ((boy / 100) ** 2) * 10) / 10 };
  const kutular: { ad: string; baslik: string; deger: string; kir: boolean }[] = [];
  for (const ad of adlar) {
    if (ad === 'diyastolik' || ad === 'kiloKg') continue;
    if (ad === 'boyCm') {
      if (boy || kilo) kutular.push({ ad: 'kiloKg', baslik: 'Boy / Kilo', deger: `${boy ? bicim(boy) : '—'} / ${kilo ? bicim(kilo) : '—'}`, kir: false });
      continue;
    }
    const alan = d.alanlar.find(a => a.ad === ad);
    if (!alan) continue;
    if (ad === 'sistolik') {
      const s = sayi(satir.sistolik), di = sayi(satir.diyastolik);
      if (s) kutular.push({ ad, baslik: 'TA', deger: di ? `${bicim(s)}/${bicim(di)}` : bicim(s),
                            kir: disinda('sistolik', s) || (di !== null && disinda('diyastolik', di)) });
      continue;
    }
    const n = sayi(satir[ad]);
    if (n !== null) {
      const deger = ad === 'spo2' ? `%${bicim(n)}` : ad === 'agriVas' ? `${bicim(n)}/10` : bicim(n);
      kutular.push({ ad, baslik: alan.baslik ?? ad, deger, kir: disinda(ad, n) });
    } else if (typeof satir[ad] === 'string' && String(satir[ad]).trim() && Number.isNaN(Number(satir[ad]))) {
      kutular.push({ ad, baslik: alan.baslik ?? ad, deger: String(satir[ad]).trim(), kir: false });
    }
  }
  return kutular;
}
