import { useContext, useEffect, useRef } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { mesaj } from '../bilesenler/mesaj';
import { TarafArama } from '../bilesenler/TarafArama';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { c } from '../dil/ceviri';
import { EkranSekmesiBaglami } from '../bilesenler/sekmeBaglami';
import { MuayeneHastaBandi, useMuayeneHastaBilgisi } from '../bilesenler/MuayeneSekmesiz';

/** Reçete sekmesinin üstündeki hasta bandı (sekmesiz muayeneyle aynı). */
function ReceteHastaBandi({ muayeneId, hastaId }: { muayeneId: number; hastaId: number }) {
  const bilgi = useMuayeneHastaBilgisi(muayeneId, 0, hastaId);
  return bilgi ? <MuayeneHastaBandi bilgi={bilgi} /> : null;
}
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
export function ReceteKartiSayfa({ listeYolu }: { listeYolu: string }) {
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const konum = useLocation();
  // Sekme adı "Reçete Kartı" (kullanıcı 15.10.2026).
  useEffect(() => { ekranSekmesi?.baslik(c('Reçete Kartı'), konum.pathname) }, [ekranSekmesi, konum.pathname]);
  const secildi = useRef(false);
  const listeye = () => { if (ekranSekmesi) ekranSekmesi.kapat(); else git(listeYolu) };
  // YENİ REÇETE ÖNCE HASTA (kullanıcı 15.10.2026): jenerik hasta araması; seçilen hastanın açık
  //   muayenesinde taslak açılır ve kart onunla gelir. Vazgeçilirse sekme kapanır.
  if (id === 'yeni') return (
    <TarafArama acik kaynaklar={['hasta']} kartYok
      yerTutucu={c('Hasta ara (ad, dosya no, kimlik no, telefon)…')}
      onKapat={() => { if (!secildi.current) listeye() }}
      onSec={h => {
        secildi.current = true;
        void api.receteHastaTaslak(Number(h.id))
          .then(y => git(`${listeYolu}/${y.receteId}${y.yeni ? '?yeni=1' : ''}`, { replace: true }))
          .catch(e => { mesaj(hataMetni(e)); listeye() });
      }} />
  );
  const receteId = Number(id);
  if (!(receteId > 0)) return null;
  const bosTaslakSil = sorgu.get('yeni') === '1';
  // EKRAN SEKMESİNDE (kullanıcı 15.10.2026): kart kendi sekmesinde, Kapat sekmeyi kapatır.
  if (ekranSekmesi) return <ReceteKarti receteId={receteId} sayfa onKapat={() => ekranSekmesi.kapat()} bosTaslakSil={bosTaslakSil}
                                        bantCiz={(m, h) => <ReceteHastaBandi muayeneId={m} hastaId={h} />} />;
  return <ReceteKarti receteId={receteId} bosTaslakSil={bosTaslakSil} onKapat={() => git(sorgu.get('geri') ?? listeYolu)} />;
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
