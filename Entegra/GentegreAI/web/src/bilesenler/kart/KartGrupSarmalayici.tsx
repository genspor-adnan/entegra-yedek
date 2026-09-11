import type { ReactNode } from 'react';
import { KartGrupSekmesi } from './KartGrupSekmesi';
import { GenDetayTablo, type DetayDurumu, bosDetay } from '../GenDetayTablo';
import { TekKayit } from '../TekKayit';
import { RandevuUygunSaatler } from '../RandevuUygunSaatler';
import { RandevuOzetSeridi } from '../RandevuOzetSeridi';
import { RandevuTetkikUyum } from '../RandevuTetkikUyum';
import type { Deger } from '../kartAlanCizim';
import type { KartAlanMeta, KartMetaYaniti } from '../../api/sozlesme';
import type { SekmeTanimi } from '../kartSekmeleri';

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
  detayGrupta?: Record<string, { grup: string; salt?: boolean; gridKipi?: boolean;
                                 sinif?: string; sade?: boolean; ekleGizli?: boolean;
                                 gizli?: string[]; etiket?: string[]; ustte?: boolean }>;
  detayIzgara?: Record<string, { sinif?: string; baslik?: string;
                                 alanSirasi?: string[]; not?: ReactNode }>;
  sekmeSarmalayici?(baslik: string, icerik: ReactNode, deger: Record<string, Deger>,
                    izgaraCiz?: (detayAd: string) => ReactNode): ReactNode;
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
        const govde = (
        <KartGrupSekmesi
          aktif={aktif} kaynak={kaynak} id={id} yeniMi={yeniMi} meta={meta}
          salt={salt} personelGibiKart={personelGibiKart}
          deger={deger} setDeger={setDeger}
          detaylar={detaylar} setDetaylar={setDetaylar}
          alanHatalari={alanHatalari} gizliSekmeler={gizliSekmeler}
          resimYerTutucu={resimYerTutucu} gruplar={gruplar}
          altGruplaVar={altGruplaVar} renderAlanListesi={renderAlanListesi}
          aramaAc={(alan, kaynak, uygula) => setAramaAlani({ alan, kaynak, uygula })}
          secilenAdlar={secilenAdlar}
        />
        );
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
              onSec={saat => alanDegistir(
                'baslangic', `${String(deger.baslangic ?? '').slice(0, 10)}T${saat}`)}
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
          .filter(d => detayGrupta?.[d.ad]?.grup === aktif.baslik);
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
        const izgaraCiz = (detayAd: string) => {
          const d = (meta?.detaylar ?? []).find(x => x.ad === detayAd);
          if (!d) return null;
          const ayar = detayIzgara?.[detayAd] ?? {};
          return (
            <div className={ayar.sinif}>
              <TekKayit
                meta={d}
                durum={detaylar[d.ad] ?? bosDetay()}
                saltOkunur={salt || d.saltOkunur}
                onDegis={yeni => setDetaylar(t => ({ ...t, [d.ad]: yeni }))}
                baslik={ayar.baslik ?? d.baslik}
                alanSirasi={ayar.alanSirasi}
                not={ayar.not}
              />
            </div>
          );
        };
        return sekmeSarmalayici
          ? sekmeSarmalayici(aktif.baslik, tumu, deger, izgaraCiz) : tumu;
}
