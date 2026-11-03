import { useContext, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { EkranSekmesiBaglami } from './sekmeBaglami';

/**
 * AD → KART SEKMESİ (kullanıcı 03.11.2026: "İrsaliye-Fatura Eşleşme İcmali nde veya diğer icmallerde müşteri / tedarikçi /
 * kişi / personel / kurum adı tıklanınca kartı hemen yanına sekme olarak açılsın"). Finans icmallerinin useCariKarti
 * deseninin ortak hali: ekran sekmesi varsa kartaGit (icmalin sağına), yoksa adrese gider.
 *
 * Tıklama satıra YAYILMAZ (stopPropagation): icmal satırlarının kendi tıklaması (seç, aç-kapa, süz, belge aç) bozulmaz.
 * Kimlik yoksa düz metin çizilir.
 */
export type KartTuru = 'musteri' | 'tedarikci' | 'kisi' | 'personel' | 'hasta' | 'kurum' | 'dis-hekim' | 'telerad-kurum';

const YOL: Record<KartTuru, string> = {
  musteri: '/cari', tedarikci: '/tedarikci', kisi: '/kisi', personel: '/personel', hasta: '/hasta',
  kurum: '/kurum', 'dis-hekim': '/dis-hekim', 'telerad-kurum': '/telerad-kurum',
};

/** Kart yolu: tür + kimlik. */
export const kartYolu = (tur: KartTuru, id: number) => `${YOL[tur]}/${id}`;

/**
 * YOLU EKRAN SEKMESİNDE AÇ (kart sekmesi deseni): ekran sekmesi varsa kartaGit (açan ekranın sağına), yoksa adrese gider.
 * İcmallerin her birinde ayrı yazılan `if (ekranSekmesi) kartaGit(yol); else git(yol)` satırının tek yeri.
 */
export function useSekmedeAc() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
}

/** Kartı ekran sekmesinde açan işlev (bileşen dışı kullanım: düğme, araç çubuğu). */
export function useKartSekmesi() {
  const ac = useSekmedeAc();
  return (tur: KartTuru, id: number | null | undefined) => { if (id) ac(kartYolu(tur, id)) };
}

export function KartAdi({ tur, id, children, title }: {
  tur: KartTuru;
  id: number | null | undefined;
  children: ReactNode;
  title?: string;
}) {
  const ac = useKartSekmesi();
  if (!id) return <>{children}</>;
  return (
    <span className="lnk" role="link" title={title ?? 'Kartı yeni sekmede aç'}
          onClick={e => { e.stopPropagation(); ac(tur, id) }}
          onDoubleClick={e => e.stopPropagation()}>
      {children}
    </span>
  );
}

/** Adın tıklaması başka iş yapıyorsa (başka icmale geçiş) yanına konan küçük kart düğmesi. */
export function KartSimgesi({ tur, id }: { tur: KartTuru; id: number | null | undefined }) {
  const ac = useKartSekmesi();
  if (!id) return null;
  return (
    <span className="lnk kart-simgesi" role="link" title="Kartı yeni sekmede aç" style={{ marginLeft: 4 }}
          onClick={e => { e.stopPropagation(); ac(tur, id) }} onDoubleClick={e => e.stopPropagation()}>↗</span>
  );
}
