import { useContext } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { EkranSekmesiBaglami } from '../bilesenler/sekmeBaglami';
import { ReceteKarti } from '../bilesenler/recete/ReceteKarti';
import { AlerjiKarti } from '../bilesenler/hasta/AlerjiKarti';
import { KronikTaniKarti } from '../bilesenler/hasta/KronikTaniKarti';
import { IlacKaydiKarti } from '../bilesenler/hasta/IlacKaydiKarti';
import { GecmisOlayKarti } from '../bilesenler/hasta/GecmisOlayKarti';

/**
 * LİSTE EKRANLARINDAN AÇILAN ÖZEL KARTLAR (mockup'lı reçete, alerji,
 * kronik tanı, kullanılan ilaç ve geçmiş olay kartları): rota `/{liste}/:id` listeyi arkada çizer, bu sayfa kartı üstte
 * açar; kapatınca `geri` (verildiyse) ya da listenin kendisine dönülür.
 */
/** Kartı KENDİ EKRAN SEKMESİNDE açılan özel kart rotaları (Kabuk kart sekmesi haritası). */
export const OZEL_KART_SEKME_YOLLARI: Record<string, string> = { '/recete': 'Reçete', '/medula-recete': 'Reçete' };

export function ReceteKartiSayfa({ listeYolu }: { listeYolu: string }) {
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const receteId = Number(id);
  if (!(receteId > 0)) return null;
  // EKRAN SEKMESİNDE (kullanıcı 15.10.2026): kart kendi sekmesinde, Kapat sekmeyi kapatır.
  if (ekranSekmesi) return <ReceteKarti receteId={receteId} sayfa onKapat={() => ekranSekmesi.kapat()} />;
  return <ReceteKarti receteId={receteId} onKapat={() => git(sorgu.get('geri') ?? listeYolu)} />;
}

/** Özel kart rotası: ekran sekmesindeyse yalnız kart (liste kendi sekmesinde), değilse liste + kart. */
export function OzelKartRota({ liste, kart, sekmeli }: { liste: React.ReactNode; kart: React.ReactNode; sekmeli: boolean }) {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  return <>{!(sekmeli && ekranSekmesi) && liste}{kart}</>;
}

/** Hasta kayıt kartları (alerji / kronik tanı / kullanılan ilaç) için ortak rota okuması. */
function useHastaKaydiRotasi(listeYolu: string) {
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const git = useNavigate();
  const kayit = id === 'yeni' ? 'yeni' as const : Number(id);
  return {
    gecerli: kayit === 'yeni' || kayit > 0,
    kayit,
    hastaId: Number(sorgu.get('hastaId')) || undefined,
    kapat: () => git(sorgu.get('geri') ?? listeYolu),
  };
}

export function KronikTaniKartiSayfa() {
  const r = useHastaKaydiRotasi('/hasta-kronik');
  return r.gecerli ? <KronikTaniKarti id={r.kayit} hastaId={r.hastaId} onKapat={r.kapat} /> : null;
}

export function IlacKaydiKartiSayfa() {
  const r = useHastaKaydiRotasi('/hasta-ilac');
  return r.gecerli ? <IlacKaydiKarti id={r.kayit} hastaId={r.hastaId} onKapat={r.kapat} /> : null;
}

export function GecmisOlayKartiSayfa() {
  const r = useHastaKaydiRotasi('/hasta-gecmis');
  return r.gecerli ? <GecmisOlayKarti id={r.kayit} hastaId={r.hastaId} onKapat={r.kapat} /> : null;
}

export function AlerjiKartiSayfa() {
  const r = useHastaKaydiRotasi('/hasta-alerji');
  return r.gecerli ? <AlerjiKarti id={r.kayit} hastaId={r.hastaId} onKapat={r.kapat} /> : null;
}
